unit formattests;

{$mode objfpc}{$H+}

interface
{ Formatted date/time/number tests
This unit tests writing out to and reading back from files.
Tests that verify reading from an Excel/LibreOffice/OpenOffice file are located in other
units (e.g. datetests).
}

uses
  {$IFDEF Unix}
  //required for formatsettings
  clocale,
  {$ENDIF}
  // Not using Lazarus package as the user may be working with multiple versions
  // Instead, add .. to unit search path
  Classes, SysUtils, fpcunit, testutils, testregistry,
  fpsallformats, fpspreadsheet, xlsbiff8 {and a project requirement for lclbase for utf8 handling},
  testsutility;

var
  // Norm to test against - list of strings that should occur in spreadsheet
  SollNumberStrings: array[0..6, 0..7] of string;
  SollNumbers: array[0..6] of Double;
  SollNumberFormats: array[0..7] of TsNumberFormat;
  SollNumberDecimals: array[0..7] of word;

  SollDateTimeStrings: array[0..4, 0..9] of string;
  SollDateTimes: array[0..4] of TDateTime;
  SollDateTimeFormats: array[0..9] of TsNumberFormat;
  SollDateTimeFormatStrings: array[0..9] of String;

  SollColWidths: array[0..1] of Single;
  SollRowHeights: Array[0..2] of Single;
  SollBorders: array[0..19] of TsCellBorders;
  SollBorderLineStyles: array[0..6] of TsLineStyle;
  SollBorderColors: array[0..5] of TsColor;

  procedure InitSollFmtData;

type
  { TSpreadWriteReadFormatTests }
  //Write to xls/xml file and read back
  TSpreadWriteReadFormatTests = class(TTestCase)
  private
  protected
    // Set up expected values:
    procedure SetUp; override;
    procedure TearDown; override;

    // Test alignments
    procedure TestWriteReadAlignment(AFormat: TsSpreadsheetFormat);
    // Test border
    procedure TestWriteReadBorder(AFormat: TsSpreadsheetFormat);
    // Test border styles
    procedure TestWriteReadBorderStyles(AFormat: TsSpreadsheetFormat);
    // Test column widths
    procedure TestWriteReadColWidths(AFormat: TsSpreadsheetFormat);
    // Test row heights
    procedure TestWriteReadRowHeights(AFormat: TsSpreadsheetFormat);
    // Test text rotation
    procedure TestWriteReadTextRotation(AFormat:TsSpreadsheetFormat);
    // Test word wrapping
    procedure TestWriteReadWordWrap(AFormat: TsSpreadsheetFormat);
    // Test number formats
    procedure TestWriteReadNumberFormats(AFormat: TsSpreadsheetFormat);
    // Repeat with date/times
    procedure TestWriteReadDateTimeFormats(AFormat: TsSpreadsheetFormat);

  published
    // Writes out numbers & reads back.
    // If previous read tests are ok, this effectively tests writing.

    { BIFF2 Tests }
    procedure TestWriteRead_BIFF2_Alignment;
    procedure TestWriteRead_BIFF2_Border;
    procedure TestWriteRead_BIFF2_ColWidths;
    procedure TestWriteRead_BIFF2_RowHeights;
    procedure TestWriteRead_BIFF2_DateTimeFormats;
    procedure TestWriteRead_BIFF2_NumberFormats;
    // These features are not supported by Excel2 --> no test cases required!
    // - BorderStyle
    // - TextRotation
    // - Wordwrap

    { BIFF5 Tests }
    procedure TestWriteRead_BIFF5_Alignment;
    procedure TestWriteRead_BIFF5_Border;
    procedure TestWriteRead_BIFF5_BorderStyles;
    procedure TestWriteRead_BIFF5_ColWidths;
    procedure TestWriteRead_BIFF5_RowHeights;
    procedure TestWriteRead_BIFF5_DateTimeFormats;
    procedure TestWriteRead_BIFF5_NumberFormats;
    procedure TestWriteRead_BIFF5_TextRotation;
    procedure TestWriteRead_BIFF5_WordWrap;

    { BIFF8 Tests }
    procedure TestWriteRead_BIFF8_Alignment;
    procedure TestWriteRead_BIFF8_Border;
    procedure TestWriteRead_BIFF8_BorderStyles;
    procedure TestWriteRead_BIFF8_ColWidths;
    procedure TestWriteRead_BIFF8_RowHeights;
    procedure TestWriteRead_BIFF8_DateTimeFormats;
    procedure TestWriteRead_BIFF8_NumberFormats;
    procedure TestWriteRead_BIFF8_TextRotation;
    procedure TestWriteRead_BIFF8_WordWrap;

    { ODS Tests }
    procedure TestWriteRead_ODS_Alignment;
    procedure TestWriteRead_ODS_Border;
    procedure TestWriteRead_ODS_BorderStyles;
    procedure TestWriteRead_ODS_ColWidths;
    procedure TestWriteRead_ODS_RowHeights;
    procedure TestWriteRead_ODS_DateTimeFormats;
    procedure TestWriteRead_ODS_NumberFormats;
    procedure TestWriteRead_ODS_TextRotation;
    procedure TestWriteRead_ODS_WordWrap;

    { OOXML Tests }
    procedure TestWriteRead_OOXML_Border;
    procedure TestWriteRead_OOXML_BorderStyles;
    procedure TestWriteRead_OOXML_DateTimeFormats;
    procedure TestWriteRead_OOXML_NumberFormats;

  end;

implementation

uses
  TypInfo, fpsutils;

const
  FmtNumbersSheet = 'NumbersFormat'; //let's distinguish it from the regular numbers sheet
  FmtDateTimesSheet = 'DateTimesFormat';
  ColWidthSheet = 'ColWidths';
  RowHeightSheet = 'RowHeights';
  BordersSheet = 'CellBorders';
  AlignmentSheet = 'TextAlignments';
  TextRotationSheet = 'TextRotation';
  WordwrapSheet = 'Wordwrap';

// Initialize array with variables that represent the values
// we expect to be in the test spreadsheet files.
//
// When adding tests, add values to this array
// and increase array size in variable declaration
procedure InitSollFmtData;
var
  i: Integer;
  fs: TFormatSettings;
  myworkbook: TsWorkbook;
begin
  // Set up norm - MUST match spreadsheet cells exactly

  // The workbook uses a slightly modified copy of the DefaultFormatSettings
  // We create a copy here in order to better define the predicted strings.
  myWorkbook := TsWorkbook.Create;
  fs := MyWorkbook.FormatSettings;
  myWorkbook.Free;

  // Numbers
  SollNumbers[0] := 0.0;
  SollNumbers[1] := 1.0;
  SollNumbers[2] := -1.0;
  SollNumbers[3] :=  1.23456E6;
  SollNumbers[4] := -1.23456E6;
  SollNumbers[5] :=  1.23456E-6;
  SollNumbers[6] := -1.23456E-6;

  SollNumberFormats[0] := nfGeneral;      SollNumberDecimals[0] := 0;
  SollNumberFormats[1] := nfFixed;        SollNumberDecimals[1] := 0;
  SollNumberFormats[2] := nfFixed;        SollNumberDecimals[2] := 2;
  SollNumberFormats[3] := nfFixedTh;      SollNumberDecimals[3] := 0;
  SollNumberFormats[4] := nfFixedTh;      SollNumberDecimals[4] := 2;
  SollNumberFormats[5] := nfExp;          SollNumberDecimals[5] := 2;
  SollNumberFormats[6] := nfPercentage;   SollNumberDecimals[6] := 0;
  SollNumberFormats[7] := nfPercentage;   SollNumberDecimals[7] := 2;

  for i:=Low(SollNumbers) to High(SollNumbers) do
  begin
    SollNumberStrings[i, 0] := FloatToStr(SollNumbers[i], fs);
    SollNumberStrings[i, 1] := FormatFloat('0', SollNumbers[i], fs);
    SollNumberStrings[i, 2] := FormatFloat('0.00', SollNumbers[i], fs);
    SollNumberStrings[i, 3] := FormatFloat('#,##0', SollNumbers[i], fs);
    SollNumberStrings[i, 4] := FormatFloat('#,##0.00', SollNumbers[i], fs);
    SollNumberStrings[i, 5] := FormatFloat('0.00E+00', SollNumbers[i], fs);
    SollNumberStrings[i, 6] := FormatFloat('0', SollNumbers[i]*100, fs) + '%';
    SollNumberStrings[i, 7] := FormatFloat('0.00', SollNumbers[i]*100, fs) + '%';
  end;

  // Date/time values
  SollDateTimes[0] := EncodeDate(2012, 1, 12) + EncodeTime(13, 14, 15, 567);
  SolLDateTimes[1] := EncodeDate(2012, 2, 29) + EncodeTime(0, 0, 0, 1);
  SollDateTimes[2] := EncodeDate(2040, 12, 31) + EncodeTime(12, 0, 0, 0);
  SollDateTimes[3] := 1 + EncodeTime(3,45, 0, 0);
  SollDateTimes[4] := EncodeTime(12, 0, 0, 0);

  SollDateTimeFormats[0] := nfShortDateTime;   SollDateTimeFormatStrings[0] := '';
  SollDateTimeFormats[1] := nfShortDate;       SollDateTimeFormatStrings[1] := '';
  SollDateTimeFormats[2] := nfShortTime;       SollDateTimeFormatStrings[2] := '';
  SollDateTimeFormats[3] := nfLongTime;        SollDateTimeFormatStrings[3] := '';
  SollDateTimeFormats[4] := nfShortTimeAM;     SollDateTimeFormatStrings[4] := '';
  SollDateTimeFormats[5] := nfLongTimeAM;      SollDateTimeFormatStrings[5] := '';
  SollDateTimeFormats[6] := nfCustom;          SollDateTimeFormatStrings[6] := 'dd/mmm';
  SolLDateTimeFormats[7] := nfCustom;          SollDateTimeFormatStrings[7] := 'mmm/yy';
  SollDateTimeFormats[8] := nfCustom;          SollDateTimeFormatStrings[8] := 'nn:ss';
  SollDateTimeFormats[9] := nfTimeInterval;    SollDateTimeFormatStrings[9] := '';

  for i:=Low(SollDateTimes) to High(SollDateTimes) do
  begin
    SollDateTimeStrings[i, 0] := DateToStr(SollDateTimes[i], fs) + ' ' + FormatDateTime('t', SollDateTimes[i], fs);
    SollDateTimeStrings[i, 1] := DateToStr(SollDateTimes[i], fs);
    SollDateTimeStrings[i, 2] := FormatDateTime(fs.ShortTimeFormat, SollDateTimes[i], fs);
    SolLDateTimeStrings[i, 3] := FormatDateTime(fs.LongTimeFormat, SollDateTimes[i], fs);
    SollDateTimeStrings[i, 4] := FormatDateTime(fs.ShortTimeFormat + ' am/pm', SollDateTimes[i], fs);   // dont't use "t" - it does the hours wrong
    SollDateTimeStrings[i, 5] := FormatDateTime(fs.LongTimeFormat + ' am/pm', SollDateTimes[i], fs);
    SollDateTimeStrings[i, 6] := FormatDateTime(SpecialDateTimeFormat('dm', fs, false), SollDateTimes[i], fs);
    SollDateTimeStrings[i, 7] := FormatDateTime(SpecialDateTimeFormat('my', fs, false), SollDateTimes[i], fs);
    SollDateTimeStrings[i, 8] := FormatDateTime(SpecialDateTimeFormat('ms', fs, false), SollDateTimes[i], fs);
    SollDateTimeStrings[i, 9] := FormatDateTime('[h]:mm:ss', SollDateTimes[i], fs, [fdoInterval]);
  end;

  // Column width
  SollColWidths[0] := 20;  // characters based on width of "0" of default font
  SollColWidths[1] := 40;

  // Row heights
  SollRowHeights[0] := 1;  // Lines of default font
  SollRowHeights[1] := 2;
  SollRowHeights[2] := 4;

  // Cell borders
  SollBorders[0] := [];
  SollBorders[1] := [cbEast];
  SollBorders[2] := [cbSouth];
  SollBorders[3] := [cbWest];
  SollBorders[4] := [cbNorth];
  SollBorders[5] := [cbEast, cbSouth];
  SollBorders[6] := [cbEast, cbWest];
  SollBorders[7] := [cbEast, cbNorth];
  SollBorders[8] := [cbSouth, cbWest];
  SollBorders[9] := [cbSouth, cbNorth];
  SollBorders[10] := [cbWest, cbNorth];
  SollBorders[11] := [cbEast, cbSouth, cbWest];
  SollBorders[12] := [cbEast, cbSouth, cbNorth];
  SollBorders[13] := [cbSouth, cbWest, cbNorth];
  SollBorders[14] := [cbWest, cbNorth, cbEast];
  SollBorders[15] := [cbEast, cbSouth, cbWest, cbNorth];     // BIFF2/5 end here
  SollBorders[16] := [cbDiagUp];
  SollBorders[17] := [cbDiagDown];
  SollBorders[18] := [cbDiagUp, cbDiagDown];
  SollBorders[19] := [cbEast, cbSouth, cbWest, cbNorth, cbDiagUp, cbDiagDown];

  SollBorderLineStyles[0] := lsThin;
  SollBorderLineStyles[1] := lsMedium;
  SollBorderLineStyles[2] := lsThick;
  SollBorderLineStyles[3] := lsDashed;
  SollBorderLineStyles[4] := lsDotted;
  SollBorderLineStyles[5] := lsDouble;
  SollBorderLineStyles[6] := lsHair;

  SollBorderColors[0] := scBlue;
  SollBorderColors[1] := scRed;
  SollBorderColors[2] := scBlue;
  SollBorderColors[3] := scGray;
  SollBorderColors[4] := scSilver;
  SollBorderColors[5] := scMagenta;
end;

{ TSpreadWriteReadFormatTests }

procedure TSpreadWriteReadFormatTests.SetUp;
begin
  inherited SetUp;
  InitSollFmtData; //just for security: make sure the variables are reset to default
end;

procedure TSpreadWriteReadFormatTests.TearDown;
begin
  inherited TearDown;
end;


{ --- Number format tests --- }

procedure TSpreadWriteReadFormatTests.TestWriteReadNumberFormats(AFormat: TsSpreadsheetFormat);
var
  MyWorksheet: TsWorksheet;
  MyWorkbook: TsWorkbook;
  ActualString: String;
  Row, Col: Integer;
  TempFile: string; //write xls/xml to this file and read back from it
begin
  {// Not needed: use workbook.writetofile with overwrite=true
  if fileexists(TempFile) then
    DeleteFile(TempFile);
  }
  // Write out all test values
  MyWorkbook := TsWorkbook.Create;
  MyWorkSheet:= MyWorkBook.AddWorksheet(FmtNumbersSheet);
  for Row := Low(SollNumbers) to High(SollNumbers) do
    for Col := ord(Low(SollNumberFormats)) to ord(High(SollNumberFormats)) do
    begin
      MyWorksheet.WriteNumber(Row, Col, SollNumbers[Row], SollNumberFormats[Col], SollNumberDecimals[Col]);
      ActualString := MyWorksheet.ReadAsUTF8Text(Row, Col);
      CheckEquals(SollNumberStrings[Row, Col], ActualString,
        'Test unsaved string mismatch cell ' + CellNotation(MyWorksheet,Row,Col));
    end;
  TempFile:=NewTempFile;
  MyWorkBook.WriteToFile(TempFile, AFormat, true);
  MyWorkbook.Free;

  // Open the spreadsheet
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(TempFile, AFormat);
  if AFormat = sfExcel2 then
    MyWorksheet := MyWorkbook.GetFirstWorksheet
  else
    MyWorksheet := GetWorksheetByName(MyWorkBook, FmtNumbersSheet);
  if MyWorksheet=nil then
    fail('Error in test code. Failed to get named worksheet');
  for Row := Low(SollNumbers) to High(SollNumbers) do
    for Col := Low(SollNumberFormats) to High(SollNumberFormats) do
    begin
      ActualString := MyWorkSheet.ReadAsUTF8Text(Row,Col);
      CheckEquals(SollNumberStrings[Row,Col], ActualString,
        'Test saved string mismatch cell '+CellNotation(MyWorkSheet,Row,Col));
    end;

  // Finalization
  MyWorkbook.Free;

  DeleteFile(TempFile);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF2_NumberFormats;
begin
  TestWriteReadNumberFormats(sfExcel2);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF5_NumberFormats;
begin
  TestWriteReadNumberFormats(sfExcel5);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF8_NumberFormats;
begin
  TestWriteReadNumberFormats(sfExcel8);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_ODS_NumberFormats;
begin
  TestWriteReadNumberFormats(sfOpenDocument);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_OOXML_NumberFormats;
begin
  TestWriteReadNumberFormats(sfOOXML);
end;


{ --- Date/time formats --- }

procedure TSpreadWriteReadFormatTests.TestWriteReadDateTimeFormats(AFormat: TsSpreadsheetFormat);
var
  MyWorksheet: TsWorksheet;
  MyWorkbook: TsWorkbook;
  ActualString: String;
  Row,Col: Integer;
  TempFile: string; //write xls/xml to this file and read back from it
begin
  // Write out all test values
  MyWorkbook := TsWorkbook.Create;
  MyWorksheet := MyWorkbook.AddWorksheet(FmtDateTimesSheet);
  for Row := Low(SollDateTimes) to High(SollDateTimes) do
    for Col := Low(SollDateTimeFormats) to High(SollDateTimeFormats) do
    begin
      if (AFormat = sfExcel2) and (SollDateTimeFormats[Col] in [nfCustom, nfTimeInterval]) then
        Continue;  // The formats nfFmtDateTime and nfTimeInterval are not supported by BIFF2
      MyWorksheet.WriteDateTime(Row, Col, SollDateTimes[Row], SollDateTimeFormats[Col], SollDateTimeFormatStrings[Col]);
      ActualString := MyWorksheet.ReadAsUTF8Text(Row, Col);
      CheckEquals(
        Lowercase(SollDateTimeStrings[Row, Col]),
        Lowercase(ActualString),
        'Test unsaved string mismatch cell ' + CellNotation(MyWorksheet,Row,Col)
      );
    end;
  TempFile:=NewTempFile;
  MyWorkBook.WriteToFile(TempFile, AFormat, true);
  MyWorkbook.Free;

  // Open the spreadsheet, as biff8
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(TempFile, AFormat);
  if AFormat = sfExcel2 then
    MyWorksheet := MyWorkbook.GetFirstWorksheet
  else
    MyWorksheet := GetWorksheetByName(MyWorkbook, FmtDateTimesSheet);
  if MyWorksheet = nil then
    fail('Error in test code. Failed to get named worksheet');
  for Row := Low(SollDateTimes) to High(SollDateTimes) do
    for Col := Low(SollDateTimeFormats) to High(SollDateTimeFormats) do
    begin
      if (AFormat = sfExcel2) and (SollDateTimeFormats[Col] in [nfCustom, nfTimeInterval]) then
        Continue;  // The formats nfFmtDateTime and nfTimeInterval are not supported by BIFF2
      ActualString := MyWorksheet.ReadAsUTF8Text(Row,Col);
      CheckEquals(
        Lowercase(SollDateTimeStrings[Row, Col]),
        Lowercase(ActualString),
        'Test saved string mismatch cell '+CellNotation(MyWorksheet,Row,Col)
      );
    end;

  // Finalization
  MyWorkbook.Free;

  DeleteFile(TempFile);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF2_DateTimeFormats;
begin
  TestWriteReadDateTimeFormats(sfExcel2);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF5_DateTimeFormats;
begin
  TestWriteReadDateTimeFormats(sfExcel5);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF8_DateTimeFormats;
begin
  TestWriteReadDateTimeFormats(sfExcel8);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_ODS_DateTimeFormats;
begin
  TestWriteReadDateTimeFormats(sfOpenDocument);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_OOXML_DateTimeFormats;
begin
  TestWriteReadDateTimeFormats(sfOOXML);
end;

{ --- Alignment tests --- }

procedure TSpreadWriteReadFormatTests.TestWriteReadAlignment(AFormat: TsSpreadsheetFormat);
const
  CELLTEXT = 'This is a text.';
var
  MyWorksheet: TsWorksheet;
  MyWorkbook: TsWorkbook;
  horAlign: TsHorAlignment;
  vertAlign: TsVertAlignment;
  row, col: Integer;
  MyCell: PCell;
  TempFile: string; //write xls/xml to this file and read back from it
begin
  {// Not needed: use workbook.writetofile with overwrite=true
  if fileexists(TempFile) then
    DeleteFile(TempFile);
  }
  // Write out all test values: HorAlignments along columns, VertAlignments along rows
  MyWorkbook := TsWorkbook.Create;
  MyWorkSheet:= MyWorkBook.AddWorksheet(AlignmentSheet);

  row := 0;
  for horAlign in TsHorAlignment do
  begin
    col := 0;
    if AFormat = sfExcel2 then
    begin
      // BIFF2 can only do horizontal alignment --> no need for vertical alignment.
      MyWorksheet.WriteUTF8Text(row, col, CELLTEXT);
      MyWorksheet.WriteHorAlignment(row, col, horAlign);
      MyCell := MyWorksheet.FindCell(row, col);
      if MyCell = nil then
        fail('Error in test code. Failed to get cell.');
      CheckEquals(ord(horAlign),  ord(MyCell^.HorAlignment),
        'Test unsaved horizontal alignment, cell ' + CellNotation(MyWorksheet,0,0));
    end
    else
      for vertAlign in TsVertAlignment do
      begin
        MyWorksheet.WriteUTF8Text(row, col, CELLTEXT);
        MyWorksheet.WriteHorAlignment(row, col, horAlign);
        MyWorksheet.WriteVertAlignment(row, col, vertAlign);
        MyCell := MyWorksheet.FindCell(row, col);
        if MyCell = nil then
          fail('Error in test code. Failed to get cell.');
        CheckEquals(ord(vertAlign),ord(MyCell^.VertAlignment),
          'Test unsaved vertical alignment, cell ' + CellNotation(MyWorksheet,0,0));
        CheckEquals(ord(horAlign), ord(MyCell^.HorAlignment),
          'Test unsaved horizontal alignment, cell ' + CellNotation(MyWorksheet,0,0));
        inc(col);
      end;
    inc(row);
  end;
  TempFile:=NewTempFile;
  MyWorkBook.WriteToFile(TempFile, AFormat, true);
  MyWorkbook.Free;

  // Open the spreadsheet
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(TempFile, AFormat);
  if AFormat = sfExcel2 then begin
    MyWorksheet := MyWorkbook.GetFirstWorksheet;
    if MyWorksheet=nil then
      fail('Error in test code. Failed to get named worksheet');
    for row :=0 to MyWorksheet.GetLastRowIndex do
    begin
      MyCell := MyWorksheet.FindCell(row, col);
      if MyCell = nil then
        fail('Error in test code. Failed to get cell.');
      horAlign := TsHorAlignment(row);
      CheckEquals(ord(horAlign), ord(MyCell^.HorAlignment),
        'Test save horizontal alignment mismatch, cell '+CellNotation(MyWorksheet,row,col));
    end
  end
  else begin
    MyWorksheet := GetWorksheetByName(MyWorkBook, AlignmentSheet);
    if MyWorksheet=nil then
      fail('Error in test code. Failed to get named worksheet');
    for row :=0 to MyWorksheet.GetLastRowIndex do
      for col := 0 to MyWorksheet.GetlastColIndex do
      begin
        MyCell := MyWorksheet.FindCell(row, col);
        if MyCell = nil then
          fail('Error in test code. Failed to get cell.');
        vertAlign := TsVertAlignment(col);
        if (vertAlign = vaDefault) and (AFormat <> sfOpenDocument) then
          vertAlign := vaBottom;
        CheckEquals(ord(vertAlign), ord(MyCell^.VertAlignment),
          'Test saved vertical alignment mismatch, cell '+CellNotation(MyWorksheet,row,col));
        horAlign := TsHorAlignment(row);
        CheckEquals(ord(horAlign), ord(MyCell^.HorAlignment),
          'Test saved horizontal alignment mismatch, cell '+CellNotation(MyWorksheet,row,col));
      end;
  end;

  MyWorkbook.Free;

  DeleteFile(TempFile);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF2_Alignment;
begin
  TestWriteReadAlignment(sfExcel2);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF5_Alignment;
begin
  TestWriteReadAlignment(sfExcel5);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF8_Alignment;
begin
  TestWriteReadAlignment(sfExcel8);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_ODS_Alignment;
begin
  TestWriteReadAlignment(sfOpenDocument);
end;


{ --- Border on/off tests --- }

procedure TSpreadWriteReadFormatTests.TestWriteReadBorder(AFormat: TsSpreadsheetFormat);
const
  row = 0;
var
  MyWorksheet: TsWorksheet;
  MyWorkbook: TsWorkbook;
  MyCell: PCell;
  col, maxCol: Integer;
  expected: String;
  current: String;
  TempFile: string; //write xls/xml to this file and read back from it
begin
  {// Not needed: use workbook.writetofile with overwrite=true
  if fileexists(TempFile) then
    DeleteFile(TempFile);
  }
  // Write out all test values
  MyWorkbook := TsWorkbook.Create;
  MyWorkSheet:= MyWorkBook.AddWorksheet(BordersSheet);
  if AFormat in [sfExcel2, sfExcel5] then
    maxCol := 15   // no diagonal border support in BIFF2 and BIFF5
  else
    maxCol := High(SollBorders);
  for col := Low(SollBorders) to maxCol do
  begin
    MyWorksheet.WriteUsedFormatting(row, col, [uffBorder]);
    MyCell := MyWorksheet.GetCell(row, col);
    Include(MyCell^.UsedFormattingFields, uffBorder);
    MyCell^.Border := SollBorders[col];
  end;
  TempFile:=NewTempFile;
  MyWorkBook.WriteToFile(TempFile, AFormat, true);
  MyWorkbook.Free;

  // Open the spreadsheet
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(TempFile, AFormat);
  if AFormat = sfExcel2 then
    MyWorksheet := MyWorkbook.GetFirstWorksheet
  else
    MyWorksheet := GetWorksheetByName(MyWorkBook, BordersSheet);
  if MyWorksheet=nil then
    fail('Error in test code. Failed to get named worksheet');
  for col := 0 to MyWorksheet.GetLastColIndex do
  begin
    MyCell := MyWorksheet.FindCell(row, col);
    if MyCell = nil then
      fail('Error in test code. Failed to get cell');
    current := GetEnumName(TypeInfo(TsCellBorders), byte(MyCell^.Border));
    expected := GetEnumName(TypeInfo(TsCellBorders), byte(SollBorders[col]));
    CheckEquals(expected, current,
      'Test saved border mismatch, cell ' + CellNotation(MyWorksheet, row, col));
  end;
  // Finalization
  MyWorkbook.Free;

  DeleteFile(TempFile);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF2_Border;
begin
  TestWriteReadBorder(sfExcel2);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF5_Border;
begin
  TestWriteReadBorder(sfExcel5);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF8_Border;
begin
  TestWriteReadBorder(sfExcel8);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_ODS_Border;
begin
  TestWriteReadBorder(sfOpenDocument);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_OOXML_Border;
begin
  TestWriteReadBorder(sfOOXML);
end;


{ --- BorderStyle tests --- }

procedure TSpreadWriteReadFormatTests.TestWriteReadBorderStyles(AFormat: TsSpreadsheetFormat);
{ This test paints 10x10 cells with all borders, each separated by an empty
  column and an empty row. The border style varies from border to border
  according to the line styles defined in SollBorderStyles. At first, all border
  lines use the first color in SollBorderColors. When all BorderStyles are used
  the next color is taken, etc. }
var
  MyWorksheet: TsWorksheet;
  MyWorkbook: TsWorkbook;
  MyCell: PCell;
  row, col: Integer;
  b: TsCellBorder;
  expected: Integer;
  current: Integer;
  TempFile: string; //write xls/xml to this file and read back from it
  c, ls: Integer;
  borders: TsCellBorders;
  diagUp_ls: Integer;
  diagUp_clr: integer;
begin
  {// Not needed: use workbook.writetofile with overwrite=true
  if fileexists(TempFile) then
    DeleteFile(TempFile);
  }
  // Write out all test values
  MyWorkbook := TsWorkbook.Create;
  MyWorkSheet:= MyWorkBook.AddWorksheet(BordersSheet);

  borders := [cbNorth, cbSouth, cbEast, cbWest];
  if AFormat in [sfExcel8, sfOpenDocument, sfOOXML] then
    borders := borders + [cbDiagUp, cbDiagDown];

  c := 0;
  ls := 0;
  for row := 1 to 10 do
  begin
    for col := 1 to 10 do
    begin
      MyWorksheet.WriteBorders(row*2, col*2, borders);
      for b in borders do
      begin
        MyWorksheet.WriteBorderLineStyle(row*2, col*2, b, SollBorderLineStyles[ls]);
        MyWorksheet.WriteBorderColor(row*2, col*2, b, SollBorderColors[c]);
        inc(ls);
        if ls > High(SollBorderLineStyles) then
        begin
          ls := 0;
          inc(c);
          if c > High(SollBorderColors) then
            c := 0;
        end;
      end;
    end;
  end;
  TempFile:=NewTempFile;
  MyWorkBook.WriteToFile(TempFile, AFormat, true);
  MyWorkbook.Free;

  // Open the spreadsheet
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(TempFile, AFormat);
  if AFormat = sfExcel2 then
    MyWorksheet := MyWorkbook.GetFirstWorksheet
  else
    MyWorksheet := GetWorksheetByName(MyWorkBook, BordersSheet);
  if MyWorksheet=nil then
    fail('Error in test code. Failed to get named worksheet');
  c := 0;
  ls := 0;
  for row := 1 to 10 do
  begin
    for col := 1 to 10 do
    begin
      MyCell := MyWorksheet.FindCell(row*2, col*2);
      if myCell = nil then
        fail('Error in test code. Failed to get cell.');
      for b in borders do
      begin
        current := ord(MyCell^.BorderStyles[b].LineStyle);
        // In Excel both diagonals have the same line style. The reader picks
        // the line style of the "diagonal-up" border. We use this as expected
        // value in the "diagonal-down" case.
        expected := ord(SollBorderLineStyles[ls]);
        if AFormat in [sfExcel8, sfOOXML] then
          case b of
            cbDiagUp  : diagUp_ls := expected;
            cbDiagDown: expected := diagUp_ls;
          end;
        CheckEquals(expected, current,
          'Test saved border line style mismatch, cell ' + CellNotation(MyWorksheet, row*2, col*2));
        current := MyCell^.BorderStyles[b].Color;
        expected := SollBorderColors[c];
        // In Excel both diagonals have the same line color. The reader picks
        // the color of the "diagonal-up" border. We use this as expected value
        // in the "diagonal-down" case.
        if AFormat in [sfExcel8, sfOOXML] then
          case b of
            cbDiagUp  : diagUp_clr := expected;
            cbDiagDown: expected := diagUp_clr;
          end;
        CheckEquals(expected, current,
          'Test saved border color mismatch, cell ' + CellNotation(MyWorksheet, row*2, col*2));
        inc(ls);
        if ls > High(SollBorderLineStyles) then begin
          ls := 0;
          inc(c);
          if c > High(SollBorderColors) then
            c := 0;
        end;
      end;
    end;
  end;

  // Finalization
  MyWorkbook.Free;

  DeleteFile(TempFile);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF5_BorderStyles;
begin
  TestWriteReadBorderStyles(sfExcel5);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF8_BorderStyles;
begin
  TestWriteReadBorderStyles(sfExcel8);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_ODS_BorderStyles;
begin
  TestWriteReadBorderStyles(sfOpenDocument);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_OOXML_BorderStyles;
begin
  TestWriteReadBorderStyles(sfOOXML);
end;


{ --- Column widths tests --- }

procedure TSpreadWriteReadFormatTests.TestWriteReadColWidths(AFormat: TsSpreadsheetFormat);
var
  MyWorksheet: TsWorksheet;
  MyWorkbook: TsWorkbook;
  ActualColWidth: Single;
  Col: Integer;
  lpCol: PCol;
  lCol: TCol;
  TempFile: string; //write xls/xml to this file and read back from it
begin
  {// Not needed: use workbook.writetofile with overwrite=true
  if fileexists(TempFile) then
    DeleteFile(TempFile);
  }
  // Write out all test values
  MyWorkbook := TsWorkbook.Create;
  MyWorkSheet:= MyWorkBook.AddWorksheet(ColWidthSheet);
  for Col := Low(SollColWidths) to High(SollColWidths) do
  begin
    lCol.Width := SollColWidths[Col];
    //MyWorksheet.WriteNumber(0, Col, 1);
    MyWorksheet.WriteColInfo(Col, lCol);
  end;
  TempFile:=NewTempFile;
  MyWorkBook.WriteToFile(TempFile, AFormat, true);
  MyWorkbook.Free;

  // Open the spreadsheet, as biff8
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(TempFile, AFormat);
  if AFormat = sfExcel2 then
    MyWorksheet := MyWorkbook.GetFirstWorksheet
  else
    MyWorksheet := GetWorksheetByName(MyWorkBook, ColWidthSheet);
  if MyWorksheet=nil then
    fail('Error in test code. Failed to get named worksheet');
  for Col := Low(SollColWidths) to High(SollColWidths) do
  begin
    lpCol := MyWorksheet.GetCol(Col);
    if lpCol = nil then
      fail('Error in test code. Failed to return saved column width');
    ActualColWidth := lpCol^.Width;
    if abs(SollColWidths[Col] - ActualColWidth) > 1E-2 then   // take rounding errors into account
      CheckEquals(SollColWidths[Col], ActualColWidth,
        'Test saved colwidth mismatch, column '+ColNotation(MyWorkSheet,Col));
  end;
  // Finalization
  MyWorkbook.Free;

  DeleteFile(TempFile);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF2_ColWidths;
begin
  TestWriteReadColWidths(sfExcel2);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF5_ColWidths;
begin
  TestWriteReadColWidths(sfExcel5);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF8_ColWidths;
begin
  TestWriteReadColWidths(sfExcel8);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_ODS_ColWidths;
begin
  TestWriteReadColWidths(sfOpenDocument);
end;

{ --- Row height tests --- }

procedure TSpreadWriteReadFormatTests.TestWriteReadRowHeights(AFormat: TsSpreadsheetFormat);
var
  MyWorksheet: TsWorksheet;
  MyWorkbook: TsWorkbook;
  ActualRowHeight: Single;
  Row: Integer;
  TempFile: string; //write xls/xml to this file and read back from it
begin
  {// Not needed: use workbook.writetofile with overwrite=true
  if fileexists(TempFile) then
    DeleteFile(TempFile);
  }
  // Write out all test values
  MyWorkbook := TsWorkbook.Create;
  MyWorkSheet:= MyWorkBook.AddWorksheet(RowHeightSheet);
  for Row := Low(SollRowHeights) to High(SollRowHeights) do
    MyWorksheet.WriteRowHeight(Row, SollRowHeights[Row]);
  TempFile:=NewTempFile;
  MyWorkBook.WriteToFile(TempFile, AFormat, true);
  MyWorkbook.Free;

  // Open the spreadsheet, as biff8
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(TempFile, AFormat);
  if AFormat = sfExcel2 then
    MyWorksheet := MyWorkbook.GetFirstWorksheet
  else
    MyWorksheet := GetWorksheetByName(MyWorkBook, RowHeightSheet);
  if MyWorksheet=nil then
    fail('Error in test code. Failed to get named worksheet');
  for Row := Low(SollRowHeights) to High(SollRowHeights) do
  begin
    ActualRowHeight := MyWorksheet.GetRowHeight(Row);
    // Take care of rounding errors
    if abs(ActualRowHeight - SollRowHeights[Row]) > 1e-2 then
      CheckEquals(SollRowHeights[Row], ActualRowHeight,
        'Test saved row height mismatch, row '+RowNotation(MyWorkSheet,Row));
  end;
  // Finalization
  MyWorkbook.Free;

  DeleteFile(TempFile);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF2_RowHeights;
begin
  TestWriteReadRowHeights(sfExcel2);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF5_RowHeights;
begin
  TestWriteReadRowHeights(sfExcel5);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF8_RowHeights;
begin
  TestWriteReadRowHeights(sfExcel8);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_ODS_RowHeights;
begin
  TestWriteReadRowHeights(sfOpenDocument);
end;


{ --- Text rotation tests --- }

procedure TSpreadWriteReadFormatTests.TestWriteReadTextRotation(AFormat: TsSpreadsheetFormat);
const
  col = 0;
var
  MyWorksheet: TsWorksheet;
  MyWorkbook: TsWorkbook;
  MyCell: PCell;
  tr: TsTextRotation;
  row: Integer;
  TempFile: string; //write xls/xml to this file and read back from it
begin
  {// Not needed: use workbook.writetofile with overwrite=true
  if fileexists(TempFile) then
    DeleteFile(TempFile);
  }
  // Write out all test values
  MyWorkbook := TsWorkbook.Create;
  MyWorkSheet:= MyWorkBook.AddWorksheet(TextRotationSheet);
  for tr := Low(TsTextRotation) to High(TsTextRotation) do
  begin
    row := ord(tr);
    MyWorksheet.WriteTextRotation(row, col, tr);
    MyCell := MyWorksheet.GetCell(row, col);
    CheckEquals(ord(tr), ord(MyCell^.TextRotation),
      'Test unsaved textrotation mismatch, cell ' + CellNotation(MyWorksheet, row, col));
  end;
  TempFile:=NewTempFile;
  MyWorkBook.WriteToFile(TempFile, AFormat, true);
  MyWorkbook.Free;

  // Open the spreadsheet
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(TempFile, AFormat);
  if AFormat = sfExcel2 then
    MyWorksheet := MyWorkbook.GetFirstWorksheet
  else
    MyWorksheet := GetWorksheetByName(MyWorkBook, TextRotationSheet);
  if MyWorksheet=nil then
    fail('Error in test code. Failed to get named worksheet');
  for row := 0 to MyWorksheet.GetLastRowIndex do
  begin
    MyCell := MyWorksheet.FindCell(row, col);
    if MyCell = nil then
      fail('Error in test code. Failed to get cell');
    tr := MyCell^.TextRotation;
    CheckEquals(ord(TsTextRotation(row)), ord(MyCell^.TextRotation),
      'Test saved textrotation mismatch, cell ' + CellNotation(MyWorksheet, row, col));
  end;
  // Finalization
  MyWorkbook.Free;

  DeleteFile(TempFile);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF5_TextRotation;
begin
  TestWriteReadTextRotation(sfExcel5);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF8_TextRotation;
begin
  TestWriteReadTextRotation(sfExcel8);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_ODS_TextRotation;
begin
  TestWriteReadTextRotation(sfOpenDocument);
end;


{ --- Wordwrap tests --- }

procedure TSpreadWriteReadFormatTests.TestWriteReadWordWrap(AFormat: TsSpreadsheetFormat);
const
  LONGTEXT = 'This is a very, very, very, very long text.';
var
  MyWorksheet: TsWorksheet;
  MyWorkbook: TsWorkbook;
  MyCell: PCell;
  TempFile: string; //write xls/xml to this file and read back from it
begin
  {// Not needed: use workbook.writetofile with overwrite=true
  if fileexists(TempFile) then
    DeleteFile(TempFile);
  }
  // Write out all test values:
  // Cell A1 is word-wrapped, Cell B1 is NOT word-wrapped
  MyWorkbook := TsWorkbook.Create;
  MyWorkSheet:= MyWorkBook.AddWorksheet(WordwrapSheet);
  MyWorksheet.WriteUTF8Text(0, 0, LONGTEXT);
  MyWorksheet.WriteUsedFormatting(0, 0, [uffWordwrap]);
  MyCell := MyWorksheet.FindCell(0, 0);
  if MyCell = nil then
    fail('Error in test code. Failed to get word-wrapped cell.');
  CheckEquals(true, (uffWordWrap in MyCell^.UsedFormattingFields), 'Test unsaved word wrap mismatch cell ' + CellNotation(MyWorksheet,0,0));
  MyWorksheet.WriteUTF8Text(1, 0, LONGTEXT);
  MyWorksheet.WriteUsedFormatting(1, 0, []);
  MyCell := MyWorksheet.FindCell(1, 0);
  if MyCell = nil then
    fail('Error in test code. Failed to get word-wrapped cell.');
  CheckEquals(false, (uffWordWrap in MyCell^.UsedFormattingFields), 'Test unsaved non-wrapped cell mismatch, cell ' + CellNotation(MyWorksheet,0,0));
  TempFile:=NewTempFile;
  MyWorkBook.WriteToFile(TempFile, AFormat, true);
  MyWorkbook.Free;

  // Open the spreadsheet, as biff8
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(TempFile, AFormat);
  if AFormat = sfExcel2 then
    MyWorksheet := MyWorkbook.GetFirstWorksheet
  else
    MyWorksheet := GetWorksheetByName(MyWorkBook, WordwrapSheet);
  if MyWorksheet=nil then
    fail('Error in test code. Failed to get named worksheet');
  MyCell := MyWorksheet.FindCell(0, 0);
  if MyCell = nil then
    fail('Error in test code. Failed to get word-wrapped cell.');
  CheckEquals(true, (uffWordWrap in MyCell^.UsedFormattingFields), 'failed to return correct word-wrap flag, cell ' + CellNotation(MyWorksheet,0,0));
  MyCell := MyWorksheet.FindCell(1, 0);
  if MyCell = nil then
    fail('Error in test code. Failed to get non-wrapped cell.');
  CheckEquals(false, (uffWordWrap in MyCell^.UsedFormattingFields), 'failed to return correct word-wrap flag, cell ' + CellNotation(MyWorksheet,0,0));
  MyWorkbook.Free;

  DeleteFile(TempFile);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF5_Wordwrap;
begin
  TestWriteReadWordwrap(sfExcel5);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_BIFF8_Wordwrap;
begin
  TestWriteReadWordwrap(sfExcel8);
end;

procedure TSpreadWriteReadFormatTests.TestWriteRead_ODS_Wordwrap;
begin
  TestWriteReadWordwrap(sfOpenDocument);
end;


initialization
  RegisterTest(TSpreadWriteReadFormatTests);
  InitSollFmtData;

end.

