unit fpsSYLK;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  fpstypes, fpsReaderWriter, xlsCommon;

type
  TsSYLKField = record
    Name: Char;
    Value: String;
  end;
  TsSYLKFields = array of TsSYLKField;


  { TsSYLKReader }

  TsSYLKReader = class(TsCustomSpreadReader)
  private
    FWorksheetName: String;
    FPointSeparatorSettings: TFormatSettings;
    FDateMode: TDateMode;
    FPrevX: Integer;
    FPrevY: Integer;
    FNumRows, FNumCols: Integer;
    FRecordLine: String;
    FLineNumber: Integer;
  protected
    function GetFieldValue(const AFields: TsSYLKFields; AFieldName: Char): String;
    procedure ProcessBounds(const AFields: TsSYLKFields);
    procedure ProcessCell(const AFields: TsSYLKFields);
    procedure ProcessFormat(const AFields: TsSYLKFields);
    procedure ProcessLine(const ALine: String);
    procedure ProcessNumFormat(const AFields: TsSYLKFields);
    procedure ProcessRecord(ARecordType: String; const AFields: TsSYLKFields);
  public
    constructor Create(AWorkbook: TsBasicWorkbook); override;
    procedure ReadFromFile(AFileName: String; APassword: String = '';
      AParams: TsStreamParams = []); override;
    procedure ReadFromStrings(AStrings: TStrings; AParams: TsStreamParams = []); override;
  end;


  { TsSYLKWriter }
  TsSYLKWriter = class(TsCustomSpreadWriter)
  private
    FPointSeparatorSettings: TFormatSettings;
    FDateMode: TDateMode;
    FSheetIndex: Integer;
    function GetFormatStr(ACell: PCell): String;
    function GetFormulaStr(ACell: PCell): String;
  protected
    procedure WriteBool(AStream: TStream; const ARow, ACol: Cardinal;
      const AValue: Boolean; ACell: PCell); override;
    procedure WriteCellToStream(AStream: TStream; ACell: PCell); override;
    procedure WriteComment(AStream: TStream; ACell: PCell); override;
    procedure WriteDateTime(AStream: TStream; const ARow, ACol: Cardinal;
      const AValue: TDateTime; ACell: PCell); override;
    procedure WriteDimensions(AStream: TStream);
    procedure WriteEndOfFile(AStream: TStream);
    procedure WriteHeader(AStream: TStream);
    procedure WriteLabel(AStream: TStream; const ARow, ACol: Cardinal;
      const AValue: string; ACell: PCell); override;
    procedure WriteNumber(AStream: TStream; const ARow, ACol: Cardinal;
      const AValue: double; ACell: PCell); override;
    procedure WriteNumberFormatList(AStream: TStream);
    procedure WriteOptions(AStream: TStream);
  public
    constructor Create(AWorkbook: TsBasicWorkbook); override;
    procedure WriteToStream(AStream: TStream; AParams: TsStreamParams = []); override;
  end;

  TSYLKSettings = record
    SheetIndex: Integer;      // W
    DateMode: TDateMode;      // R/W
  end;

const
  STR_FILEFORMAT_SYLK = 'SYLK';

var
  {@@ Default settings for reading/writing of SYLK files }
  SYLKSettings: TSYLKSettings = (
    SheetIndex: 0;
    DateMode: dm1900
  );

  {@@ File format identifier }
  sfidSYLK: Integer;

implementation

uses
  fpsUtils, fpsNumFormat, fpspreadsheet;

{==============================================================================}
{                               TsSYLKReader                                   }
{==============================================================================}

constructor TsSYLKReader.Create(AWorkbook: TsBasicWorkbook);
begin
  inherited Create(AWorkbook);
  FWorksheetName := 'Sheet1';  // will be replaced by filename
  FDateMode := SYLKSettings.DateMode;
  FPointSeparatorSettings := DefaultFormatSettings;
  FPointSeparatorSettings.DecimalSeparator := '.';
end;

function TsSYLKReader.GetFieldValue(const AFields: TsSYLKFields;
  AFieldName: Char): String;
var
  i: Integer;
begin
  for i := 0 to Length(AFields)-1 do
    if AFields[i].Name = AFieldName then begin
      Result := AFields[i].Value;
      exit;
    end;
  Result := '';
end;

procedure TsSYLKReader.ProcessBounds(const AFields: TsSYLKFields);
var
  srows, scols: String;
begin
  scols := GetFieldValue(AFields, 'X');
  srows := GetFieldValue(AFields, 'Y');
  if (scols = '') or (srows = '') then
    exit;

  FNumRows := StrToInt(srows);
  FNumCols := StrToInt(scols);
end;

procedure TsSYLKReader.ProcessCell(const AFields: TsSYLKFields);
var
  row, col: Integer;
  sval, expr: String;
  val: Double;
  cell: PCell;
  sheet: TsWorksheet;
  book: TsWorkbook;
  s: String;
begin
  book := FWorkbook as TsWorkbook;
  sheet := FWorksheet as TsWorksheet;

  s := GetFieldValue(AFields, 'X');
  if (s <> '') and TryStrToInt(s, col) then begin
    dec(col);
    FPrevX := col;
  end else
    col := FPrevX;

  s := GetFieldValue(AFields, 'Y');
  if (s <> '') and TryStrToInt(s, row) then begin
    dec(row);
    FPrevY := row;
  end else
    row := FPrevY;

  if (row >= FNumRows) then begin
    FWorkbook.AddErrorMsg('line %d, %s": column is outside range.', [FLineNumber, FRecordLine]);
    exit;
  end;

  if (col >= FNumCols) then begin
    FWorkbook.AddErrorMsg('line%d, "%s": row is outside range.', [FLineNumber, FRecordLine]);
    exit;
  end;

  cell := sheet.GetCell(row, col);

  // Formula
  expr := GetFieldValue(AFields, 'E');  // expression in R1C1 syntax
  if expr <> '' then
    sheet.WriteFormula(cell, expr, false, true);

  book.LockFormulas;  // Protect formulas from being deleted by the WriteXXXX calls
  try
    // Value
    sval := GetFieldValue(AFields, 'K');
    if sval <> '' then begin
      if sval[1] = '"' then
      begin
        sval := UnquoteStr(sval);
        if (sval = 'TRUE') or (sval = 'FALSE') then
          sheet.WriteBoolValue(cell, (sval = 'TRUE'))
        else
          sheet.WriteText(cell, UnquoteStr(sval))
        // to do: error values
      end else begin
        val := StrToFloat(sval, FPointSeparatorSettings);
        sheet.WriteNumber(cell, val);
        // to do: dates
      end;
    end;
  finally
    book.UnlockFormulas;
  end;
end;

procedure TsSYLKReader.ProcessFormat(const AFields: TsSYLKFields);
var
  cell: PCell;
  s, scol, srow, sval, scol1, scol2: String;
  col, row, col1, col2: LongInt;
  ch1, ch2: Char;
  nf: TsNumberFormat;
  nfs: String;
  decs: Integer;
  ha: TsHorAlignment;
  hasStyle: Boolean;
  fill: Boolean;
  val: Double;
  P: PChar;
  n: Integer;
  sheet: TsWorksheet;
  dest: Integer;   // 0=cell format, 1=col format, 2=rowFormat
  fmt: TsCellFormat;
  fmtIdx: Integer;
  b: TsCellBorders;
  i: Integer;
begin
  sheet := FWorksheet as TsWorksheet;

  nf := nfGeneral;
  ha := haDefault;
  decs := 0;
  fill := false;
  b := [];
  InitFormatRecord(fmt);

  // Format
  nfs := '';
  s := GetFieldValue(AFields, 'P');
  if (s <> '') then begin
    if LowerCase(s) = 'general' then
      nf := nfGeneral
    else if TryStrToInt(s, n) then
      nfs := FNumFormatList[n];
  end;

  s := GetFieldValue(AFields, 'F');
  if s <> '' then
  begin
    ch1 := s[1];
    ch2 := s[Length(s)];
    sval := copy(s, 2, Length(s));

    // Number format
    case ch1 of
      'D': nf := nfGeneral;
      'C': nf := nfCurrency;
      'E': nf := nfExp;
      'F': nf := nfFixed;
      'G': nf := nfGeneral;
      '$': ;  // no idea what this is
      '*': ;  // no idea what this is
      '%': nf := nfPercentage;
    end;

    // Decimal places
    TryStrtoInt(sval, decs);

    // Horizontal alignment
    case ch2 of
      'D': ha := haDefault;
      'C': ha := haCenter;
      'G': ;  // "Standard" ???
      'L': ha := haLeft;
      'R': ha := haRight;
      '-': ;  // ???
    end;
  end;

  // Style
  s := GetFieldValue(AFields, 'S');
  if s <> '' then begin
    for i := 1 to Length(s) do begin
      ch1 := s[i];
      case ch1 of
        'S': fill := true;
        'T': Include(b, cbNorth);
        'L': Include(b, cbWest);
        'R': Include(b, cbEast);
        'B': Include(b, cbSouth);
      end;
    end;
  end;

  // Determin to which cell, column or row the format applies
  dest := 0;  // assume cell format
  scol := GetFieldValue(AFields, 'X');
  if (scol <> '') and TryStrToInt(scol, col) then begin
    dec(col);
    FPrevX := col;
  end else
    col := FPrevX;

  srow := GetFieldValue(AFields, 'Y');
  if (srow <> '') and TryStrToInt(srow, row) then begin
    dec(row);
    FPrevY := row;
  end else
    row := FPrevY;

  if (row >= FNumRows) and (FNumRows > 0) then begin
    FWorkbook.AddErrorMsg('line %d, %s": row %d  is outside range.', [FLineNumber, FRecordLine, row]);
    exit;
  end;

  if (col >= FNumCols) and (FNumCols > 0) then begin
    FWorkbook.AddErrorMsg('line%d, "%s": column %d is outside range.', [FLineNumber, FRecordLine, col]);
    exit;
  end;

  // Column format
  scol := GetFieldValue(AFields, 'C');
  if (scol <> '') and TryStrToInt(scol, col) then begin
    dec(col);
    dest := 1; // is column format
  end;

  // Row format
  srow := GetFieldValue(AFields, 'R');
  if (srow <> '') and TryStrToInt(srow, row) then begin
    dec(row);
    dest := 2;  // is row format
  end;

  // Create format record and store in workbook format list
  if ha <> haDefault then begin
    fmt.HorAlignment := ha;
    Include(fmt.UsedFormattingfields, uffHorAlign);
  end;
  if fill then begin
    fmt.Background.Style := fsGray25;
    fmt.Background.FgColor := scBlack;
    fmt.Background.BgColor := scTransparent;
    Include(fmt.UsedFormattingFields, uffBackground);
  end;
  if b <> [] then begin
    fmt.Border := b;
    Include(fmt.UsedFormattingFields, uffBorder);
  end;
  if (nfs = '') then begin
    if nf in [nfCurrency, nfCurrencyRed] then
      nfs := BuildCurrencyFormatString(nf, FWorkbook.FormatSettings, decs, -1, -1, '?', false)
    else
      nfs := BuildNumberFormatString(nf, FWorkbook.FormatSettings, decs);
  end;
  if (nfs <> '') and (nfs <> 'General') then begin
    fmt.NumberFormatIndex := TsWorkbook(FWorkbook).AddNumberFormat(nfs);
    Include(fmt.UsedFormattingFields, uffNumberFormat);
  end;
  fmtIdx := TsWorkbook(FWorkbook).AddCellFormat(fmt);

  // Apply format to cell, col or row
  case dest of
    0: begin
         cell := sheet.GetCell(row, col);
         sheet.WriteCellFormatIndex(cell, fmtIdx);
       end;
    1: sheet.WriteColFormatIndex(col, fmtIdx);
    2: sheet.WriteRowFormatIndex(row, fmtIdx);
  end;

  // Column width
  s := GetFieldValue(AFields, 'W');
  if s <> '' then
  begin
    scol1 := '';
    P := @s[1];
    while P^ <> ' ' do begin
      scol1 := scol1 + P^;
      inc(P);
    end;
    inc(P);
    scol2 := '';
    while (P^ <> ' ') do begin
      scol2 := scol2 + P^;
      inc(P);
    end;
    inc(P);
    sval := '';
    while (P^ <> #0) do begin
      sval := sval + P^;
      inc(P);
    end;
    if TryStrToInt(scol1, col1) and
       TryStrToInt(scol2, col2) and
       TryStrToFloat(sval, val, FPointSeparatorSettings) then
    begin
      if col2 > FNumCols then
        col2 := FNumCols;
      for col := col1-1 to col2-1 do
        sheet.WriteColWidth(col, val, suChars);
    end;
  end;
end;

procedure TsSYLKReader.ProcessLine(const ALine: String);
var
  P: PChar;
  i: Integer;
  rtd, fval: String;
  ftd: Char;
  fields: TsSYLKFields;

  procedure StoreField(AName: Char; const AValue: String);
  begin
    if i >= Length(fields) then SetLength(fields, Length(fields)+100);
    fields[i].Name := AName;
    fields[i].Value := AValue;
    inc(i);
  end;

begin
  // Get record type
  rtd := '';
  P := @ALine[1];
  while (P^ <> ';') do begin
    rtd := rtd + P^;
    inc(P);
  end;
  inc(P);

  if rtd = 'C' then
    ftd := 'C';

  // Get fields
  SetLength(fields, 100);
  i := 0;
  while (P^ <> #0) do begin
    ftd := P^;
    inc(P);
    fval := '';
    while (P^ <> #0) do begin
      case P^ of
        ';' : begin
                inc(P);
                if P^ = ';' then begin
                  fval := fval + P^;
                end else
                begin
                  StoreField(ftd, fval);
                  break;
                end;
              end;
        else  fval := fval + P^;
              inc(P);
      end;
    end;
  end;

  if fval <> '' then
    StoreField(ftd, fval);

  // Process record
  SetLength(fields, i);
  ProcessRecord(rtd, fields);
end;

procedure TsSYLKReader.ProcessNumFormat(const AFields: TsSYLKFields);
var
  s: String;
begin
  s := GetFieldValue(AFields, 'P');
  FNumFormatList.Add(s);
end;

procedure TsSYLKReader.ProcessRecord(ARecordType: String;
  const AFields: TsSYLKFields);
begin
  case ARecordType of
    'ID': ;                          // Begin of file - nothing to do for us
    'B' : ProcessBounds(AFields);    // Bounds of the sheet
    'C' : ProcessCell(AFields);      // Content record
    'F' : ProcessFormat(AFields);    // Format record
    'P' : ProcessNumFormat(AFields); // Excel number format
    'E' : ;                          // End of file
  end;
end;

procedure TsSYLKReader.ReadFromFile(AFileName: String;
  APassword: String = ''; AParams: TsStreamParams = []);
begin
  FWorksheetName := ChangeFileExt(ExtractFileName(AFileName), '');
  inherited ReadFromFile(AFilename, APassword, AParams);
end;

procedure TsSYLKReader.ReadFromStrings(AStrings: TStrings;
  AParams: TsStreamParams = []);
var
  i: Integer;
begin
  Unused(AParams);
  FNumFormatList.Clear;

  // Create worksheet
  FWorksheet := (FWorkbook as TsWorkbook).AddWorksheet(FWorksheetName, true);

  for i:=0 to AStrings.Count-1 do begin
    FRecordLine := AStrings[i];
    FLineNumber := i;
    ProcessLine(AStrings[i]);
  end;
end;


{==============================================================================}
{                               TsSYLKWriter                                   }
{==============================================================================}

constructor TsSYLKWriter.Create(AWorkbook: TsBasicWorkbook);
begin
  inherited Create(AWorkbook);
  FDateMode := SYLKSettings.DateMode;
  FSheetIndex := SYLKSettings.SheetIndex;
  FPointSeparatorSettings := DefaultFormatSettings;
  FPointSeparatorSettings.DecimalSeparator := '.';
end;

function TsSYLKWriter.GetFormatStr(ACell: PCell): String;
var
  cellFmt: PsCellFormat;
  ch1, ch2: Char;
  decs: String;
  nfp: TsNumFormatParams;
  style: String;
  fnt: TsFont;
  wkBook: TsWorkbook;
begin
  Result := '';

  wkBook := FWorkbook as TsWorkbook;

  cellFmt := wkBook.GetPointerToCellFormat(ACell^.FormatIndex);
  if cellFmt <> nil then
  begin
    // Number format --> field ";P"
    ch1 := 'G';  // general number format
    decs := '0'; // decimal places
    if (uffNumberFormat in cellFmt^.UsedFormattingFields) then begin
      Result := Result + Format(';P%d', [cellFmt^.NumberFormatIndex+1]);  // +1 because of General format not in list
      nfp := wkBook.GetNumberFormat(cellFmt^.NumberFormatIndex);
      case nfp.Sections[0].NumFormat of
        nfFixed      : ch1 := 'F';
        nfCurrency   : ch1 := 'C';
        nfPercentage : ch1 := '%';
        nfExp        : ch1 := 'E';
        else           ch1 := 'G';
      end;
      decs := IntToStr(nfp.Sections[0].Decimals);
    end else
      Result := Result + ';P0';

    // Horizontal alignment + old-style number format  --> field ";F"
    ch2 := 'D';  // default alignment
    if (uffHorAlign in cellFmt^.UsedFormattingFields) then
      case cellFmt^.HorAlignment of
        haLeft  : ch2 := 'L';
        haCenter: ch2 := 'C';
        haRight : ch2 := 'R';
      end;
    Result := Result + ';F' + ch1 + decs + ch2;

    // Font style, Borders, background  --> field ";S"
    style := '';
    if (uffFont in cellFmt^.UsedFormattingFields) then
    begin
      fnt := wkBook.GetFont(cellFmt^.FontIndex);
      if (fssBold in fnt.Style) then style := style + 'D';
      if (fssItalic in fnt.Style) then style := style + 'I';
    end;
    if (uffBorder in cellFmt^.UsedFormattingFields) then
    begin
      if (cbWest in cellFmt^.Border) then style := style + 'L';
      if (cbEast in cellFmt^.Border) then style := style + 'R';
      if (cbNorth in cellFmt^.Border) then style := style + 'T';
      if (cbSouth in cellFmt^.Border) then style := style + 'B';
    end;
    if (uffBackground in cellFmt^.UsedFormattingFields) then
      style := style + 'S';

    if style <> '' then
      Result := Result + ';S' + style;
  end;

  Result := 'F' + Result + Format(';Y%d;X%d', [ACell^.Row+1, ACell^.Col+1]);
end;

function TsSYLKWriter.GetFormulaStr(ACell: PCell): String;
begin
  if HasFormula(ACell) then
    Result := ';E' + (FWorksheet as TsWorksheet).ConvertFormulaDialect(ACell, fdExcelR1C1)
  else
    Result := '';
end;

{@@ ----------------------------------------------------------------------------
  Writes a boolean value.
  In the first line, we write the format code -- see GetFormatStr
  In the second line, we write a "C" record containing the fields
  - ";X" cell column index (1-based)
  - ";Y" cell row index (1-based)
  - ";K" boolean value as TRUE or FALSE, no quotes
  - ";E" formula in R1C1 syntax, if available -- see GetFormulaStr
-------------------------------------------------------------------------------}
procedure TsSYLKWriter.WriteBool(AStream: TStream; const ARow, ACol: Cardinal;
  const AValue: Boolean; ACell: PCell);
const
  BOOLSTR: Array[boolean] of String = ('FALSE', 'TRUE');
var
  sval: String;
  sfmt: String;
begin
  // Format codes
  sfmt := GetFormatStr(ACell);
  if sfmt <> '' then
    sfmt := sfmt + LineEnding;

  // Cell coordinates, value, formula
  sval := Format('C;Y$d;X%d;K%s', [ARow+1, ACol+1, BOOLSTR[AValue]]) + GetFormulaStr(ACell);

  // Write out
  AppendToStream(AStream, sval + sfmt + LineEnding);
end;

procedure TsSYLKWriter.WriteCellToStream(AStream: TStream; ACell: PCell);
begin
  case ACell^.ContentType of
    cctBool:
      WriteBool(AStream, ACell^.Row, ACell^.Col, ACell^.BoolValue, ACell);
    cctDateTime:
      WriteDateTime(AStream, ACell^.Row, ACell^.Col, ACell^.DateTimeValue, ACell);
    cctEmpty:
      WriteBlank(AStream, ACell^.Row, ACell^.Col, ACell);
    cctError:
      WriteError(AStream, ACell^.Row, ACell^.Col, ACell^.ErrorValue, ACell);
    cctNumber:
      WriteNumber(AStream, ACell^.Row, ACell^.Col, ACell^.NumberValue, ACell);
    cctUTF8String:
      WriteLabel(AStream, ACell^.Row, ACell^.Col, ACell^.UTF8StringValue, ACell);
  end;
  if (FWorksheet as TsWorksheet).HasComment(ACell) then
    WriteComment(AStream, ACell);
end;

{@@ ----------------------------------------------------------------------------
  Writes a comment record. This is a "C" record containing the fields
  - ";X" cell column index (1-based)
  - ";Y" cell row index (1-based)
  - ";A" comment text, not quoted
-------------------------------------------------------------------------------}
procedure TsSYLKWriter.WriteComment(AStream: TStream; ACell: PCell);
var
  comment: String;
begin
  comment := (FWorksheet as TsWorksheet).ReadComment(ACell);
  if comment <> '' then
    AppendToStream(AStream, Format(
      'C;Y%d;X%d;A%s' + LineEnding, [ACell^.Row+1, ACell^.Col+1, comment]));
end;

{@@ ----------------------------------------------------------------------------
  Writes a date/time value. The date/time cell is just an ordinary number cell,
  just formatted with a date/time format.
-------------------------------------------------------------------------------}
procedure TsSYLKWriter.WriteDateTime(AStream: TStream; const ARow, ACol: Cardinal;
  const AValue: TDateTime; ACell: PCell);
var
  DateSerial: double;
begin
  DateSerial := ConvertDateTimeToExcelDateTime(AValue, FDateMode);
  WriteNumber(AStream, ARow, ACol, DateSerial, ACell);
end;

{@@ ----------------------------------------------------------------------------
  Writes out the size of the worksheet (row and column count)
  In SYLK, this is a "B" record followed by the fields ";Y" and ";X" containing
  the row and column counts.
-------------------------------------------------------------------------------}
procedure TsSYLKWriter.WriteDimensions(AStream: TStream);
var
  sheet: TsWorksheet;
begin
  sheet := FWorksheet as TsWorksheet;
  AppendToStream(AStream, Format(
    'B;Y%d;X%d;D%d %d %d %d' + LineEnding, [
    sheet.GetLastRowIndex+1, sheet.GetLastColIndex+1,
    sheet.GetFirstRowIndex, sheet.GetFirstColIndex,
    sheet.GetLastRowIndex, sheet.GetLastColIndex
  ]));
end;

{@@ ----------------------------------------------------------------------------
  Writes out an "E" record which is the last record of a SYLK file
-------------------------------------------------------------------------------}
procedure TsSYLKWriter.WriteEndOfFile(AStream: TStream);
begin
  AppendToStream(AStream,
    'E' + LineEnding);
end;

procedure TsSYLKWriter.WriteHeader(AStream: TStream);
begin
  AppendToStream(AStream,
    'ID;PFPS' + LineEnding);  // ID + generating app ("FPS" = FPSpreadsheet)
end;

{@@ ----------------------------------------------------------------------------
  Writes a text value.
  In the first line, we write the format code -- see GetFormatStr
  In the second line, we write a "C" record containing the fields
  - ";X" cell column index (1-based)
  - ";Y" cell row index (1-based)
  - ";K" text value in double quotes
  - ";E" formula in R1C1 syntax, if available -- see GetFormulaStr
-------------------------------------------------------------------------------}
procedure TsSYLKWriter.WriteLabel(AStream: TStream; const ARow, ACol: Cardinal;
  const AValue: String; ACell: PCell);
var
  sval: String;
  sfmt: String;
begin
  // Format codes
  sfmt := GetFormatStr(ACell);
  if sfmt <> '' then
    sfmt := sfmt + LineEnding;

  // Cell coordinates, value, formula
  sval := Format('C;Y%d;X%d;K"%s"', [ARow+1, ACol+1, AValue]) + GetFormulaStr(ACell);

  // Write out
  AppendToStream(AStream, sfmt + sval + LineEnding);
end;

{@@ ----------------------------------------------------------------------------
  Writes a number value.
  In the first line, we write the format code -- see GetFormatStr
  In the second line, we write a "C" record containing the fields
  - ";X" cell column index (1-based)
  - ";Y" cell row index (1-based)
  - ";K" number value as unformatted string
  - ";E" formula in R1C1 syntax, if available -- see GetFormulaStr
-------------------------------------------------------------------------------}
procedure TsSYLKWriter.WriteNumber(AStream: TStream; const ARow, ACol: Cardinal;
  const AValue: double; ACell: PCell);
var
  sval: String;
  sfmt: String;
begin
  // Format codes
  sfmt := GetFormatStr(ACell);
  if sfmt <> '' then
    sfmt := sfmt + LineEnding;

  // Cell coordinates, value, formula
  sval := Format('C;Y%d;X%d;K%g', [ARow+1, ACol+1, AValue], FPointSeparatorSettings);
  sval := sval + GetFormulaStr(ACell);

  // Write out
  AppendToStream(AStream, sfmt + sval + LineEnding);
end;

{@@ ----------------------------------------------------------------------------
  Writes the list of number formats.
  In SYLK, this is a sequence of "P" records. Each record contains the Excel
  format string with field identifier ";P"
-------------------------------------------------------------------------------}
procedure TsSYLKWriter.WriteNumberFormatList(AStream: TStream);
var
  nfp: TsNumFormatParams;
  nfs: String;
  i, j: Integer;
  wkbook: TsWorkbook;
begin
  wkbook := FWorkbook as TsWorkbook;

  AppendToStream(AStream,
    'P;PGeneral' + LineEnding);

  for i:=0 to wkBook.GetNumberFormatCount-1 do begin
    nfp := wkBook.GetNumberFormat(i);
    nfs := BuildFormatStringFromSection(nfp.Sections[0]);
    for j:=1 to High(nfp.Sections) do
      nfs := nfs + ';;' + BuildFormatStringFromSection(nfp.Sections[j]);
    AppendToStream(AStream,
      'P;P' + nfs + LineEnding);
  end;
end;

procedure TsSYLKWriter.WriteOptions(AStream: TStream);
var
  dateModeStr: String;
  A1ModeStr: String;
begin
  A1ModeStr := ';L';    // Display formulas in A1 mode.

  case FDateMode of     // Datemode 1900 or 1904
    dm1900: dateModeStr := ';V0';
    dm1904: dateModeStr := ';V4';
  end;

  AppendToStream(AStream,
    'O' + A1ModeStr + dateModeStr + LineEnding
  );
end;

procedure TsSYLKWriter.WriteToStream(AStream: TStream;
  AParams: TsStreamParams = []);
var
  wkBook: TsWorkbook;
begin
  Unused(AParams);
  wkbook := FWorkbook as TsWorkbook;

  if (FSheetIndex < 0) or (FSheetIndex >= wkBook.GetWorksheetCount) then
    raise Exception.Create('[TsSYLKWriter.WriteToStream] Non-existing worksheet.');

  FWorksheet := wkBook.GetWorksheetByIndex(FSheetIndex);

  WriteHeader(AStream);
  WriteNumberFormatList(AStream);
  WriteDimensions(AStream);
  WriteOptions(AStream);
  WriteCellsToStream(AStream, (FWorksheet as TsWorksheet).Cells);
  WriteEndOfFile(AStream);
end;

initialization

  sfidSYLK := RegisterSpreadFormat(sfUser,
    TsSYLKReader, TsSYLKWriter,
    STR_FILEFORMAT_SYLK, 'SYLK', ['.slk', '.sylk']
  );

end.

