{@@ ----------------------------------------------------------------------------
  Unit fpsUtils provides a variety of <b>utility functions</b> used
  throughout the fpspreadsheet library.

  LICENSE: See the file COPYING.modifiedLGPL.txt, included in the Lazarus
           distribution, for details about the license.
-------------------------------------------------------------------------------}
unit fpsutils;

// to do: Remove the patched FormatDateTime when the feature of square brackets
//        in time format codes is in the rtl
// to do: Remove the declaration UTF8FormatSettings and InitUTF8FormatSettings
//        when this same modification is in LazUtils of Laz stable


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, //StrUtils,
  fpstypes;

// Exported types
type
  {@@ Selection direction along column or along row }
  TsSelectionDirection = (fpsVerticalSelection, fpsHorizontalSelection);

  {@@ Color value, composed of r(ed), g(reen) and b(lue) components }
  TRGBA = record r, g, b, a: byte end;

const
  {@@ Date formatting string for unambiguous date/time display as strings
      Can be used for text output when date/time cell support is not available }
  ISO8601Format='yyyymmdd"T"hhmmss';
  {@@ Extended ISO 8601 date/time format, used in e.g. ODF/opendocument }
  ISO8601FormatExtended='yyyy"-"mm"-"dd"T"hh":"mm":"ss';
  {@@  ISO 8601 date-only format, used in ODF/opendocument }
  ISO8601FormatDateOnly='yyyy"-"mm"-"dd';
  {@@  ISO 8601 time-only format, used in ODF/opendocument }
  ISO8601FormatTimeOnly='"PT"hh"H"nn"M"ss"S"';
  {@@ ISO 8601 time-only format, with hours overflow }
  ISO8601FormatHoursOverflow='"PT"[hh]"H"nn"M"ss.zz"S"';

// Endianess helper functions
function WordToLE(AValue: Word): Word;
function DWordToLE(AValue: Cardinal): Cardinal;
function IntegerToLE(AValue: Integer): Integer;
function WideStringToLE(const AValue: WideString): WideString;

function WordLEtoN(AValue: Word): Word;
function DWordLEtoN(AValue: Cardinal): Cardinal;
function WideStringLEToN(const AValue: WideString): WideString;

// Cell, column and row strings
function ParseIntervalString(const AStr: string;
  out AFirstCellRow, AFirstCellCol, ACount: Cardinal;
  out ADirection: TsSelectionDirection): Boolean;
function ParseCellRangeString(const AStr: string;
  out AFirstCellRow, AFirstCellCol, ALastCellRow, ALastCellCol: Cardinal;
  out AFlags: TsRelFlags): Boolean; overload;
function ParseCellRangeString(const AStr: string;
  out AFirstCellRow, AFirstCellCol, ALastCellRow, ALastCellCol: Cardinal): Boolean; overload;
function ParseCellRangeString(const AStr: String;
  out ARange: TsCellRange; out AFlags: TsRelFlags): Boolean; overload;
function ParseCellRangeString(const AStr: String;
  out ARange: TsCellRange): Boolean; overload;
function ParseCellString(const AStr: string;
  out ACellRow, ACellCol: Cardinal; out AFlags: TsRelFlags): Boolean; overload;
function ParseCellString(const AStr: string;
  out ACellRow, ACellCol: Cardinal): Boolean; overload;
function ParseSheetCellString(const AStr: String;
  out ASheetName: String; out ACellRow, ACellCol: Cardinal): Boolean;
function ParseCellRowString(const AStr: string;
  out AResult: Cardinal): Boolean;
function ParseCellColString(const AStr: string;
  out AResult: Cardinal): Boolean;

function GetColString(AColIndex: Integer): String;

function GetCellString(ARow,ACol: Cardinal;
  AFlags: TsRelFlags = [rfRelRow, rfRelCol]): String;
function GetCellString_R1C1(ARow, ACol: Cardinal; AFlags: TsRelFlags = [rfRelRow, rfRelCol];
  ARefRow: Cardinal = Cardinal(-1); ARefCol: Cardinal = Cardinal(-1)): String;

function GetCellRangeString(ARow1, ACol1, ARow2, ACol2: Cardinal;
  AFlags: TsRelFlags = rfAllRel; Compact: Boolean = false): String; overload;
function GetCellRangeString(ARange: TsCellRange;
  AFlags: TsRelFlags = rfAllRel; Compact: Boolean = false): String; overload;

function GetErrorValueStr(AErrorValue: TsErrorValue): String;
function TryStrToErrorValue(AErrorStr: String; out AErr: TsErrorValue): boolean;

function GetFileFormatName(AFormat: TsSpreadsheetFormat): string;
function GetFileFormatExt(AFormat: TsSpreadsheetFormat): String;
function GetFormatFromFileName(const AFileName: TFileName;
  out SheetType: TsSpreadsheetFormat): Boolean;

function IfThen(ACondition: Boolean; AValue1,AValue2: TsNumberFormat): TsNumberFormat; overload;

procedure FloatToFraction(AValue: Double; AMaxDenominator: Int64;
  out ANumerator, ADenominator: Int64);
function TryStrToFloatAuto(AText: String; out ANumber: Double;
  out ADecimalSeparator, AThousandSeparator: Char; out AWarning: String): Boolean;
function TryFractionStrToFloat(AText: String; out ANumber: Double;
  out AIsMixed: Boolean; out AMaxDigits: Integer): Boolean;

function TwipsToPts(AValue: Integer): Single; inline;
function PtsToTwips(AValue: Single): Integer; inline;
function cmToPts(AValue: Double): Double; inline;
function PtsToCm(AValue: Double): Double; inline;
function InToMM(AValue: Double): Double; inline;
function InToPts(AValue: Double): Double; inline;
function PtsToIn(AValue: Double): Double; inline;
function mmToPts(AValue: Double): Double; inline;
function mmToIn(AValue: Double): Double; inline;
function PtsToMM(AValue: Double): Double; inline;
function pxToPts(AValue, AScreenPixelsPerInch: Integer): Double; inline;
function PtsToPx(AValue: Double; AScreenPixelsPerInch: Integer): Integer; inline;
function HTMLLengthStrToPts(AValue: String; DefaultUnits: String = 'pt'): Double;

function UTF8TextToXMLText(AText: ansistring): ansistring;
function ValidXMLText(var AText: ansistring; ReplaceSpecialChars: Boolean = true): Boolean;

function ColorToHTMLColorStr(AValue: TsColor; AExcelDialect: Boolean = false): String;
function HTMLColorStrToColor(AValue: String): TsColor;

function GetColorName(AColor: TsColor): String;
function HighContrastColor(AColor: TsColor): TsColor;
function IsPaletteIndex(AColor: TsColor): Boolean;
function LongRGBToExcelPhysical(const RGB: DWord): DWord;
function SetAsPaletteIndex(AIndex: Integer): TsColor;
function TintedColor(AColor: TsColor; tint: Double): TsColor;

function AnalyzeCompareStr(AString: String; out ACompareOp: TsCompareOperation): String;

procedure FixLineEndings(var AText: String; var ARichTextParams: TsRichTextParams);
function UnquoteStr(AString: String): String;

function InitSortParams(ASortByCols: Boolean = true; ANumSortKeys: Integer = 1;
  ASortPriority: TsSortPriority = spNumAlpha): TsSortParams;

procedure SplitHyperlink(AValue: String; out ATarget, ABookmark: String);
procedure FixHyperlinkPathDelims(var ATarget: String);

procedure InitCell(out ACell: TCell); overload;
procedure InitCell(ARow, ACol: Cardinal; out ACell: TCell); overload;
procedure InitFormatRecord(out AValue: TsCellFormat);
procedure InitPageLayout(out APageLayout: TsPageLayout);

procedure CopyCellValue(AFromCell, AToCell: PCell);
function HasFormula(ACell: PCell): Boolean;
function SameCellBorders(AFormat1, AFormat2: PsCellFormat): Boolean;
function SameFont(AFont1, AFont2: TsFont): Boolean; overload;
function SameFont(AFont: TsFont; AFontName: String; AFontSize: Single;
  AStyle: TsFontStyles; AColor: TsColor; APos: TsFontPosition): Boolean; overload;

//function GetUniqueTempDir(Global: Boolean): String;

procedure AppendToStream(AStream: TStream; const AString: String); inline; overload;
procedure AppendToStream(AStream: TStream; const AString1, AString2: String); inline; overload;
procedure AppendToStream(AStream: TStream; const AString1, AString2, AString3: String); inline; overload;

{ For silencing the compiler... }
procedure Unused(const A1);
procedure Unused(const A1, A2);
procedure Unused(const A1, A2, A3);

var
  {@@ Default value for the screen pixel density (pixels per inch). Is needed
  for conversion of distances to pixels}
  ScreenPixelsPerInch: Integer = 96;

  {@@ FPC format settings for which all strings have been converted to UTF8 }
  UTF8FormatSettings: TFormatSettings;


implementation

uses
  Math, lazutf8, lazfileutils, fpsStrings;

{******************************************************************************}
{                       Endianess helper functions                             }
{******************************************************************************}

{ Excel files are all written with little endian byte order,
  so it's necessary to swap the data to be able to build a
  correct file on big endian systems.

  The routines WordToLE, DWordToLE, IntegerToLE etc are preferable to
  System unit routines because they ensure that the correct overloaded version
  of the conversion routines will be used, avoiding typecasts which are less readable.

  They also guarantee delphi compatibility. For Delphi we just support
  big-endian isn't support, because Delphi doesn't support it.
}

{@@ ----------------------------------------------------------------------------
  WordLEToLE converts a word value from big-endian to little-endian byte order.

  @param   AValue  Big-endian word value
  @return          Little-endian word value
-------------------------------------------------------------------------------}
function WordToLE(AValue: Word): Word;
begin
  {$IFDEF FPC}
    Result := NtoLE(AValue);
  {$ELSE}
    Result := AValue;
  {$ENDIF}
end;

{@@ ----------------------------------------------------------------------------
  DWordLEToLE converts a DWord value from big-endian to little-endian byte-order.

  @param   AValue  Big-endian DWord value
  @return          Little-endian DWord value
-------------------------------------------------------------------------------}
function DWordToLE(AValue: Cardinal): Cardinal;
begin
  {$IFDEF FPC}
    Result := NtoLE(AValue);
  {$ELSE}
    Result := AValue;
  {$ENDIF}
end;

{@@ ----------------------------------------------------------------------------
  Converts an integer value from big-endian to little-endian byte-order.

  @param   AValue  Big-endian integer value
  @return          Little-endian integer value
-------------------------------------------------------------------------------}
function IntegerToLE(AValue: Integer): Integer;
begin
  {$IFDEF FPC}
    Result := NtoLE(AValue);
  {$ELSE}
    Result := AValue;
  {$ENDIF}
end;

{@@ ----------------------------------------------------------------------------
  Converts a word value from little-endian to big-endian byte-order.

  @param   AValue  Little-endian word value
  @return          Big-endian word value
-------------------------------------------------------------------------------}
function WordLEtoN(AValue: Word): Word;
begin
  {$IFDEF FPC}
    Result := LEtoN(AValue);
  {$ELSE}
    Result := AValue;
  {$ENDIF}
end;

{@@ ----------------------------------------------------------------------------
  Converts a DWord value from little-endian to big-endian byte-order.

  @param   AValue  Little-endian DWord value
  @return          Big-endian DWord value
-------------------------------------------------------------------------------}
function DWordLEtoN(AValue: Cardinal): Cardinal;
begin
  {$IFDEF FPC}
    Result := LEtoN(AValue);
  {$ELSE}
    Result := AValue;
  {$ENDIF}
end;

{@@ ----------------------------------------------------------------------------
  Converts a widestring from big-endian to little-endian byte-order.

  @param   AValue  Big-endian widestring
  @return          Little-endian widestring
-------------------------------------------------------------------------------}
function WideStringToLE(const AValue: WideString): WideString;
{$IFNDEF FPC}
var
  j: integer;
{$ENDIF}
begin
  {$IFDEF FPC}
    {$IFDEF FPC_LITTLE_ENDIAN}
      Result:=AValue;
    {$ELSE}
      Result:=AValue;
      for j := 1 to Length(AValue) do begin
        PWORD(@Result[j])^:=NToLE(PWORD(@Result[j])^);
      end;
    {$ENDIF}
  {$ELSE}
    Result:=AValue;
  {$ENDIF}
end;

{@@ ----------------------------------------------------------------------------
  Converts a widestring from little-endian to big-endian byte-order.

  @param   AValue  Little-endian widestring
  @return          Big-endian widestring
-------------------------------------------------------------------------------}
function WideStringLEToN(const AValue: WideString): WideString;
{$IFNDEF FPC}
var
  j: integer;
{$ENDIF}
begin
  {$IFDEF FPC}
    {$IFDEF FPC_LITTLE_ENDIAN}
      Result:=AValue;
    {$ELSE}
      Result:=AValue;
      for j := 1 to Length(AValue) do begin
        PWORD(@Result[j])^:=LEToN(PWORD(@Result[j])^);
      end;
    {$ENDIF}
  {$ELSE}
    Result:=AValue;
  {$ENDIF}
end;

{@@ ----------------------------------------------------------------------------
  Parses strings like A5:A10 into an selection interval information

  @param  AStr           Cell range string, such as A5:A10
  @param  AFirstCellRow  Row index of the first cell of the range (output)
  @param  AFirstCellCol  Column index of the first cell of the range (output)
  @param  ACount         Number of cells included in the range (output)
  @param  ADirection     fpsVerticalSelection if the range is along a column,
                         fpsHorizontalSelection if the range is along a row

  @return                false if the string is not a valid cell range
-------------------------------------------------------------------------------}
function ParseIntervalString(const AStr: string;
  out AFirstCellRow, AFirstCellCol, ACount: Cardinal;
  out ADirection: TsSelectionDirection): Boolean;
var
  //Cells: TStringList;
  LastCellRow, LastCellCol: Cardinal;
  p: Integer;
  s1, s2: String;
begin
  Result := True;

  { Simpler:
  use "pos" instead of the TStringList overhead.
  And: the StringList is not free'ed here

  // First get the cells
  Cells := TStringList.Create;
  ExtractStrings([':'],[], PChar(AStr), Cells);

  // Then parse each of them
  Result := ParseCellString(Cells[0], AFirstCellRow, AFirstCellCol);
  if not Result then Exit;
  Result := ParseCellString(Cells[1], LastCellRow, LastCellCol);
  if not Result then Exit;
  }

  // First find the position of the colon and split into parts
  p := pos(':', AStr);
  if p = 0 then exit(false);
  s1 := copy(AStr, 1, p-1);
  s2 := copy(AStr, p+1, Length(AStr));

  // Then parse each of them
  Result := ParseCellString(s1, AFirstCellRow, AFirstCellCol);
  if not Result then Exit;
  Result := ParseCellString(s2, LastCellRow, LastCellCol);
  if not Result then Exit;

  if AFirstCellRow = LastCellRow then
  begin
    ADirection := fpsHorizontalSelection;
    ACount := LastCellCol - AFirstCellCol + 1;
  end
  else if AFirstCellCol = LastCellCol then
  begin
    ADirection := fpsVerticalSelection;
    ACount := LastCellRow - AFirstCellRow + 1;
  end
  else Exit(False);
end;

{@@ ----------------------------------------------------------------------------
  Parses strings like A5:C10 into a range selection information.
  Returns in AFlags also information on relative/absolute cells.

  @param  AStr           Cell range string, such as A5:C10
  @param  AFirstCellRow  Row index of the top/left cell of the range (output)
  @param  AFirstCellCol  Column index of the top/left cell of the range (output)
  @param  ALastCellRow   Row index of the bottom/right cell of the range (output)
  @param  ALastCellCol   Column index of the bottom/right cell of the range (output)
  @param  AFlags         a set containing an element for AFirstCellRow, AFirstCellCol,
                         ALastCellRow, ALastCellCol if they represent relative
                         cell addresses.

  @return                false if the string is not a valid cell range
-------------------------------------------------------------------------------}
function ParseCellRangeString(const AStr: string;
  out AFirstCellRow, AFirstCellCol, ALastCellRow, ALastCellCol: Cardinal;
  out AFlags: TsRelFlags): Boolean;
var
  p: Integer;
  s: String;
  f: TsRelFlags;
begin
  Result := True;

  // First find the colon
  p := pos(':', AStr);
  if p = 0 then exit(false);

  // Analyze part after the colon
  s := copy(AStr, p+1, Length(AStr));
  Result := ParseCellString(s, ALastCellRow, ALastCellCol, f);
  if not Result then exit;

  // Analyze part before the colon
  s := copy(AStr, 1, p-1);
  Result := ParseCellString(s, AFirstCellRow, AFirstCellCol, AFlags);

  // Add flags of 2nd part
  if rfRelRow in f then Include(AFlags, rfRelRow2);
  if rfRelCol in f then Include(AFlags, rfRelCol2);
end;


{@@ ----------------------------------------------------------------------------
  Parses strings like A5:C10 into a range selection information.
  Information on relative/absolute cells is ignored.

  @param  AStr           Cell range string, such as A5:C10
  @param  AFirstCellRow  Row index of the top/left cell of the range (output)
  @param  AFirstCellCol  Column index of the top/left cell of the range (output)
  @param  ALastCellRow   Row index of the bottom/right cell of the range (output)
  @param  ALastCellCol   Column index of the bottom/right cell of the range (output)
  @return                false if the string is not a valid cell range
--------------------------------------------------------------------------------}
function ParseCellRangeString(const AStr: string;
  out AFirstCellRow, AFirstCellCol, ALastCellRow, ALastCellCol: Cardinal): Boolean;
var
  flags: TsRelFlags;
begin
  Result := ParseCellRangeString(AStr,
    AFirstCellRow, AFirstCellCol,
    ALastCellRow, ALastCellCol,
    flags
  );
end;

{@@ ----------------------------------------------------------------------------
  Parses strings like A5:C10 into a range selection information.
  Returns in AFlags also information on relative/absolute cells.

  @param  AStr           Cell range string, such as A5:C10
  @param  ARange         TsCellRange record of the zero-based row and column
                         indexes of the top/left and right/bottom corrners
  @param  AFlags         a set containing an element for ARange.Row1 (top row),
                         ARange.Col1 (left column), ARange.Row2 (bottom row),
                         ARange.Col2 (right column) if they represent relative
                         cell addresses.
  @return                false if the string is not a valid cell range
--------------------------------------------------------------------------------}
function ParseCellRangeString(const AStr: String;
  out ARange: TsCellRange; out AFlags: TsRelFlags): Boolean;
begin
  Result := ParseCelLRangeString(AStr, ARange.Row1, ARange.Col1, ARange.Row2,
    ARange.Col2, AFlags);
end;

{@@ ----------------------------------------------------------------------------
  Parses strings like A5:C10 into a range selection information.
  Information on relative/absolute cells is ignored.

  @param  AStr           Cell range string, such as A5:C10
  @param  ARange         TsCellRange record of the zero-based row and column
                         indexes of the top/left and right/bottom corrners
  @return                false if the string is not a valid cell range
--------------------------------------------------------------------------------}
function ParseCellRangeString(const AStr: String;
  out ARange: TsCellRange): Boolean;
begin
  Result := ParseCellRangeString(AStr, ARange.Row1, ARange.Col1, ARange.Row2,
    ARange.Col2);
end;


{@@ ----------------------------------------------------------------------------
  Parses a cell string, like 'A1' into zero-based column and row numbers
  Note that there can be several letters to address for more than 26 columns.
  'AFlags' indicates relative addresses.

  @param  AStr      Cell range string, such as A1
  @param  ACellRow  Row index of the top/left cell of the range (output)
  @param  ACellCol  Column index of the top/left cell of the range (output)
  @param  AFlags    A set containing an element for ACellRow and/or ACellCol,
                    if they represent a relative cell address.
  @return           False if the string is not a valid cell range

  @example "AMP$200" --> (rel) column 1029 (= 26*26*1 + 26*16 + 26 - 1)
                         (abs) row = 199 (abs)
-------------------------------------------------------------------------------}
function ParseCellString(const AStr: String; out ACellRow, ACellCol: Cardinal;
  out AFlags: TsRelFlags): Boolean;

  function Scan(AStartPos: Integer): Boolean;
  const
    LETTERS = ['A'..'Z'];
    DIGITS  = ['0'..'9'];
  var
    i: Integer;
    isAbs: Boolean;
  begin
    Result := false;

    i := AStartPos;
    // Scan letters
    while (i <= Length(AStr)) do begin
      if (UpCase(AStr[i]) in LETTERS) then begin
        ACellCol := Cardinal(ord(UpCase(AStr[i])) - ord('A')) + 1 + ACellCol * 26;
        if ACellCol >= MAX_COL_COUNT then
          // too many columns (dropping this limitation could cause overflow
          // if a too long string is passed
          exit;
        inc(i);
      end
      else
      if (AStr[i] in DIGITS) or (AStr[i] = '$') then
        break
      else begin
        ACellCol := 0;
        exit;      // Only letters or $ allowed
      end;
    end;
    if AStartPos = 1 then Include(AFlags, rfRelCol);

    if i > Length(AStr) then
      exit;

    isAbs := (AStr[i] = '$');
    if isAbs then inc(i);

    if i > Length(AStr) then
      exit;

    // Scan digits
    while (i <= Length(AStr)) do begin
      if (AStr[i] in DIGITS) then begin
        ACellRow := Cardinal(ord(AStr[i]) - ord('0')) + ACellRow * 10;
        inc(i);
      end
      else begin
        ACellCol := 0;
        ACellRow := 0;
        AFlags := [];
        exit;
      end;
    end;

    dec(ACellCol);
    dec(ACellRow);
    if not isAbs then Include(AFlags, rfRelRow);

    Result := true;
  end;

begin
  ACellCol := 0;
  ACellRow := 0;
  AFlags := [];

  if AStr = '' then
    Exit(false);

  if (AStr[1] = '$') then
    Result := Scan(2)
  else
    Result := Scan(1);
end;

{@@ ----------------------------------------------------------------------------
  Parses a cell string, like 'A1' into zero-based column and row numbers
  Note that there can be several letters to address for more than 26 columns.

  For compatibility with old version which does not return flags for relative
  cell addresses.

  @param  AStr      Cell range string, such as A1
  @param  ACellRow  Row index of the top/left cell of the range (output)
  @param  ACellCol  Column index of the top/left cell of the range (output)
  @return           False if the string is not a valid cell range
-------------------------------------------------------------------------------}
function ParseCellString(const AStr: string;
  out ACellRow, ACellCol: Cardinal): Boolean;
var
  flags: TsRelFlags;
begin
  Result := ParseCellString(AStr, ACellRow, ACellCol, flags);
end;

function ParseSheetCellString(const AStr: String; out ASheetName: String;
  out ACellRow, ACellCol: Cardinal): Boolean;
var
  p: Integer;
begin
  p := UTF8Pos('!', AStr);
  if p = 0 then begin
    Result := ParseCellString(AStr, ACellRow, ACellCol);
    ASheetName := '';
  end else begin
    ASheetName := UTF8Copy(AStr, 1, p-1);
    Result := ParseCellString(UTF8Copy(AStr, p+1, UTF8Length(AStr)), ACellRow, ACellCol);
  end;
end;

{@@ ----------------------------------------------------------------------------
  Parses a cell row string to a zero-based row number.

  @param  AStr      Cell row string, such as '1', 1-based!
  @param  AResult   Index of the row (zero-based!) (putput)
  @return           False if the string is not a valid cell row string
-------------------------------------------------------------------------------}
function ParseCellRowString(const AStr: string; out AResult: Cardinal): Boolean;
begin
  try
    AResult := StrToInt(AStr) - 1;
  except
    Result := False;
  end;
  Result := True;
end;

{@@ ----------------------------------------------------------------------------
  Parses a cell column string, like 'A' or 'CZ', into a zero-based column number.
  Note that there can be several letters to address more than 26 columns.

  @param  AStr      Cell range string, such as A1
  @param  AResult   Zero-based index of the column (output)
  @return           False if the string is not a valid cell column string
-------------------------------------------------------------------------------}
function ParseCellColString(const AStr: string; out AResult: Cardinal): Boolean;
const
  INT_NUM_LETTERS = 26;
begin
  Result := False;
  AResult := 0;

  if Length(AStr) = 1 then AResult := Ord(AStr[1]) - Ord('A')
  else if Length(AStr) = 2 then
  begin
    AResult := (Ord(AStr[1]) - Ord('A') + 1) * INT_NUM_LETTERS
     + Ord(AStr[2]) - Ord('A');
  end
  else if Length(AStr) = 3 then
  begin
    AResult := (Ord(AStr[1]) - Ord('A') + 1) * INT_NUM_LETTERS * INT_NUM_LETTERS
     + (Ord(AStr[2]) - Ord('A') + 1) * INT_NUM_LETTERS
     +  Ord(AStr[3]) - Ord('A');
  end
  else Exit(False);

  Result := True;
end;

function Letter(AValue: Integer): char;
begin
  Result := Char(AValue + ord('A'));
end;

{@@ ----------------------------------------------------------------------------
  Calculates an Excel column name ('A', 'B' etc) from the zero-based column index

  @param  AColIndex   Zero-based column index
  @return  Letter-based column name string. Can contain several letter in case of
           more than 26 columns
-------------------------------------------------------------------------------}
function GetColString(AColIndex: Integer): String;
{ Code adapted from:
  http://stackoverflow.com/questions/12796973/vba-function-to-convert-column-number-to-letter }
var
  n: Integer;
  c: byte;
begin
  Result := '';
  n := AColIndex + 1;
  while (n > 0) do begin
    c := (n - 1) mod 26;
    Result := char(c + ord('A')) + Result;
    n := (n - c) div 26;
  end;
end;

const
  RELCHAR: Array[boolean] of String = ('$', '');

{@@ ----------------------------------------------------------------------------
  Calculates a cell address string from zero-based column and row indexes and
  the relative address state flags.

  @param   ARowIndex   Zero-based row index
  @param   AColIndex   Zero-based column index
  @param   AFlags      An optional set containing an entry for column and row
                       if these addresses are relative. By default, relative
                       addresses are assumed.
  @return  Excel type of cell address containing $ characters for absolute
           address parts.
  @example ARowIndex = 0, AColIndex = 0, AFlags = [rfRelRow] --> $A1
-------------------------------------------------------------------------------}
function GetCellString(ARow, ACol: Cardinal;
  AFlags: TsRelFlags = [rfRelRow, rfRelCol]): String;
begin
  Result := Format('%s%s%s%d', [
    RELCHAR[rfRelCol in AFlags], GetColString(ACol),
    RELCHAR[rfRelRow in AFlags], ARow+1
  ]);
end;

{@@ ----------------------------------------------------------------------------
  Calculates a cell address string in R1C1 notation from zero-based column and
  row indexes and the relative address state flags.

  @param   ARow        Zero-based row index
  @param   ACol        Zero-based column index
  @param   AFlags      An optional set containing an entry for column and row
                       if these addresses are relative. By default, relative
                       addresses are assumed.
  @param   @ARefRow    Zero-based row index of the reference cell in case of
                       relative address.
  @param   @ARefCol    Zero-based column index of the reference cell in case of
                       relative address.
  @return  Excel type of cell address in R1C1 notation.
-------------------------------------------------------------------------------}
function GetCellString_R1C1(ARow, ACol: Cardinal; AFlags: TsRelFlags = [rfRelRow, rfRelCol];
  ARefRow: Cardinal = Cardinal(-1); ARefCol: Cardinal = Cardinal(-1)): String;
var
  delta: LongInt;
begin
  if rfRelRow in AFlags then
  begin
    delta := LongInt(ARow) - LongInt(ARefRow);
    if delta = 0 then
      Result := 'R' else
      Result := 'R[' + IntToStr(delta) + ']';
  end else
    Result := 'R' + IntToStr(ARow+1);

  if rfRelCol in AFlags then
  begin
    delta := LongInt(ACol) - LongInt(ARefCol);
    if delta = 0 then
      Result := Result + 'C' else
      Result := Result + 'C[' + IntToStr(delta) + ']';
  end else
    Result := Result + 'C' + IntToStr(ACol+1);
end;


{@@ ----------------------------------------------------------------------------
  Calculates a cell range address string from zero-based column and row indexes
  and the relative address state flags.

  @param   ARow1       Zero-based index of the first row in the range
  @param   ACol1       Zero-based index of the first column in the range
  @param   ARow2       Zero-based index of the last row in the range
  @param   ACol2       Zero-based index of the last column in the range
  @param   AFlags      A set containing an entry for first and last column and
                       row if their addresses are relative.
  @param   Compact     If the range consists only of a single cell and compact
                       is true then the simple cell string is returned (e.g. A1).
                       If compact is false then the cell is repeated (e.g. A1:A1)
  @return  Excel type of cell address range containing '$' characters for absolute
           address parts and a ':' to separate the first and last cells of the
           range
  @example ARow1 = 0, ACol1 = 0, ARow = 2, ACol = 1, AFlags = [rfRelRow, rfRelRow2]
           --> $A1:$B3
-------------------------------------------------------------------------------}
function GetCellRangeString(ARow1, ACol1, ARow2, ACol2: Cardinal;
  AFlags: TsRelFlags = rfAllRel; Compact: Boolean = false): String;
begin
  if Compact and (ARow1 = ARow2) and (ACol1 = ACol2) then
    Result := GetCellString(ARow1, ACol1, AFlags)
  else
    Result := Format('%s%s%s%d:%s%s%s%d', [
      RELCHAR[rfRelCol in AFlags], GetColString(ACol1),
      RELCHAR[rfRelRow in AFlags], ARow1 + 1,
      RELCHAR[rfRelCol2 in AFlags], GetColString(ACol2),
      RELCHAR[rfRelRow2 in AFlags], ARow2 + 1
    ]);
end;

{@@ ----------------------------------------------------------------------------
  Calculates a cell range address string from a TsCellRange record
  and the relative address state flags.

  @param   ARange      TsCellRange record containing the zero-based indexes of
                       the first and last row and columns of the range
  @param   AFlags      A set containing an entry for first and last column and
                       row if their addresses are relative.
  @param   Compact     If the range consists only of a single cell and compact
                       is true then the simple cell string is returned (e.g. A1).
                       If compact is false then the cell is repeated (e.g. A1:A1)
  @return  Excel type of cell address range containing '$' characters for absolute
           address parts and a ':' to separate the first and last cells of the
           range
-------------------------------------------------------------------------------}
function GetCellRangeString(ARange: TsCellRange;
  AFlags: TsRelFlags = rfAllRel; Compact: Boolean = false): String;
begin
  Result := GetCellRangeString(ARange.Row1, ARange.Col1, ARange.Row2, ARange.Col2,
    AFlags, Compact);
end;

{@@ ----------------------------------------------------------------------------
  Returns the error value code from a string. Result is false, if the string does
  not match one of the predefined error strings.

  @param   AErrorStr   Error string
  @param   AErr        Corresponding error value code (type TsErrorValue)
  @result  TRUE if error code could be determined from the error string,
           FALSE otherwise.
-------------------------------------------------------------------------------}
function TryStrToErrorValue(AErrorStr: String; out AErr: TsErrorValue): boolean;
begin
  Result := true;
  case AErrorStr of
    '#NULL!'   : AErr := errEmptyIntersection;
    '#DIV/0!'  : AErr := errDivideByZero;
    '#VALUE!'  : AErr := errWrongType;
    '#REF!'    : AErr := errIllegalRef;
    '#NAME?'   : AErr := errWrongName;
    '#NUM!'    : AErr := errOverflow;
    '#N/A'     : AErr := errArgError;
    '#FORMULA?': AErr := errFormulaNotSupported;
    ''         : AErr := errOK;
    else         Result := false;
  end;
end;

{@@ ----------------------------------------------------------------------------
  Returns the message text assigned to an error value

  @param   AErrorValue  Error code as defined by TsErrorvalue
  @return  Text corresponding to the error code.
-------------------------------------------------------------------------------}
function GetErrorValueStr(AErrorValue: TsErrorValue): String;
begin
  case AErrorValue of
    errOK                   : Result := '';
    errEmptyIntersection    : Result := '#NULL!';
    errDivideByZero         : Result := '#DIV/0!';
    errWrongType            : Result := '#VALUE!';
    errIllegalRef           : Result := '#REF!';
    errWrongName            : Result := '#NAME?';
    errOverflow             : Result := '#NUM!';
    errArgError             : Result := '#N/A';
    // --- no Excel errors --
    errFormulaNotSupported  : Result := '#FORMULA?';
    else                      Result := '#UNKNOWN ERROR';
  end;
end;

{@@ ----------------------------------------------------------------------------
  Returns the name of the given spreadsheet file format.

  @param   AFormat  Identifier of the file format
  @return  'BIFF2', 'BIFF3', 'BIFF4', 'BIFF5', 'BIFF8', 'OOXML', 'Open Document',
           'CSV, 'WikiTable Pipes', or 'WikiTable WikiMedia"
-------------------------------------------------------------------------------}
function GetFileFormatName(AFormat: TsSpreadsheetFormat): string;
begin
  case AFormat of
    sfExcel2              : Result := 'BIFF2';
    sfExcel5              : Result := 'BIFF5';
    sfExcel8              : Result := 'BIFF8';
    sfooxml               : Result := 'OOXML';
    sfOpenDocument        : Result := 'Open Document';
    sfCSV                 : Result := 'CSV';
    sfHTML                : Result := 'HTML';
    sfWikiTable_Pipes     : Result := 'WikiTable Pipes';
    sfWikiTable_WikiMedia : Result := 'WikiTable WikiMedia';
    else                    Result := rsUnknownSpreadsheetFormat;
  end;
end;

{@@ ----------------------------------------------------------------------------
  Returns the default extension of each spreadsheet file format

  @param  AFormat  Identifier of the file format
  @retur  File extension
-------------------------------------------------------------------------------}
function GetFileFormatExt(AFormat: TsSpreadsheetFormat): String;
begin
  case AFormat of
    sfExcel2,
    sfExcel5,
    sfExcel8              : Result := STR_EXCEL_EXTENSION;
    sfOOXML               : Result := STR_OOXML_EXCEL_EXTENSION;
    sfOpenDocument        : Result := STR_OPENDOCUMENT_CALC_EXTENSION;
    sfCSV                 : Result := STR_COMMA_SEPARATED_EXTENSION;
    sfHTML                : Result := STR_HTML_EXTENSION;
    sfWikiTable_Pipes     : Result := STR_WIKITABLE_PIPES_EXTENSION;
    sfWikiTable_WikiMedia : Result := STR_WIKITABLE_WIKIMEDIA_EXTENSION;
    else                    raise Exception.Create(rsUnknownSpreadsheetFormat);
  end;
end;

{@@ ----------------------------------------------------------------------------
  Determines the spreadsheet type from the file type extension

  @param   AFileName   Name of the file to be considered
  @param   SheetType   File format found from analysis of the extension (output)
  @return  True if the file matches any of the known formats, false otherwise
-------------------------------------------------------------------------------}
function GetFormatFromFileName(const AFileName: TFileName;
  out SheetType: TsSpreadsheetFormat): Boolean;
var
  suffix: String;
begin
  Result := true;
  suffix := Lowercase(ExtractFileExt(AFileName));
  case suffix of
    STR_EXCEL_EXTENSION               : SheetType := sfExcel8;
    STR_OOXML_EXCEL_EXTENSION         : SheetType := sfOOXML;
    STR_OPENDOCUMENT_CALC_EXTENSION   : SheetType := sfOpenDocument;
    STR_COMMA_SEPARATED_EXTENSION     : SheetType := sfCSV;
    STR_HTML_EXTENSION, '.htm'        : SheetType := sfHTML;
    STR_WIKITABLE_PIPES_EXTENSION     : SheetType := sfWikiTable_Pipes;
    STR_WIKITABLE_WIKIMEDIA_EXTENSION : SheetType := sfWikiTable_WikiMedia;
    else                                Result := False;
  end;
end;

{@@ ----------------------------------------------------------------------------
  Helper function to reduce typing: "if a conditions is true return the first
  number format, otherwise return the second format"

  @param   ACondition   Boolean expression
  @param   AValue1      First built-in number format code
  @param   AValue2      Second built-in number format code
  @return  AValue1 if ACondition is true, AValue2 otherwise.
-------------------------------------------------------------------------------}
function IfThen(ACondition: Boolean;
  AValue1, AValue2: TsNumberFormat): TsNumberFormat;
begin
  if ACondition then Result := AValue1 else Result := AValue2;
end;

{@@ ----------------------------------------------------------------------------
  Approximates a floating point value as a fraction and returns the values of
  numerator and denominator.

  @param   AValue           Floating point value to be analyzed
  @param   AMaxDenominator  Maximum value of the denominator allowed
  @param   ANumerator       (out) Numerator of the best approximating fraction
  @param   ADenominator     (out) Denominator of the best approximating fraction
-------------------------------------------------------------------------------}
procedure FloatToFraction(AValue: Double; AMaxDenominator: Int64;
  out ANumerator, ADenominator: Int64);
// Uses method of continued fractions, adapted version from a function in
// Bart Broersma's fractions.pp unit:
// http://svn.code.sf.net/p/flyingsheep/code/trunk/ConsoleProjecten/fractions/
const
  MaxInt64 = High(Int64);
  MinInt64 = Low(Int64);
var
  H1, H2, K1, K2, A, NewA, tmp, prevH1, prevK1: Int64;
  B, test, diff, prevdiff: Double;
  PendingOverflow: Boolean;
  i: Integer = 0;
begin
  if (AValue > MaxInt64) or (AValue < MinInt64) then
    raise Exception.Create('Range error');

  if abs(AValue) < 0.5 / AMaxDenominator then
  begin
    ANumerator := 0;
    ADenominator := AMaxDenominator;
    exit;
  end;

  H1 := 1;
  H2 := 0;
  K1 := 0;
  K2 := 1;
  B := AValue;
  NewA := Round(Floor(B));
  prevH1 := H1;
  prevK1 := K1;
  prevdiff := 1E308;
  repeat
    inc(i);
    A := NewA;
    tmp := H1;
    H1 := A * H1 + H2;
    H2 := tmp;
    tmp := K1;
    K1 := A * K1 + K2;
    K2 := tmp;
    test := H1/K1;
    diff := test - AValue;
    { Use the previous result if the denominator becomes larger than the allowed
      value, or if the difference becomes worse because the "best" result has
      been missed due to rounding error - this is more stable than using a
      predefined precision in comparing diff with zero. }
    if (abs(K1) >= AMaxDenominator) or (abs(diff) > abs(prevdiff)) then
    begin
      H1 := prevH1;
      K1 := prevK1;
      break;
    end;
    if (Abs(B - A) < 1E-30) then
      B := 1E30   //happens when H1/K1 exactly matches Value
    else
      B := 1 / (B - A);
    PendingOverFlow := (B * H1 + H2 > MaxInt64) or
                       (B * K1 + K2 > MaxInt64) or
                       (B > MaxInt64);
    if not PendingOverflow then
      NewA := Round(Floor(B));
    prevH1 := H1;
    prevK1 := K1;
    prevdiff := diff;
  until PendingOverflow;
  ANumerator := H1;
  ADenominator := K1;
end;

{@@ ----------------------------------------------------------------------------
  Converts a string to a floating point number. No assumption on decimal and
  thousand separator are made.
  Is needed for reading CSV files.
-------------------------------------------------------------------------------}
function TryStrToFloatAuto(AText: String; out ANumber: Double;
  out ADecimalSeparator, AThousandSeparator: Char; out AWarning: String): Boolean;
var
  i: Integer;
  testSep: Char;
  testSepPos: Integer;
  lastDigitPos: Integer;
  isPercent: Boolean;
  fs: TFormatSettings;
  done: Boolean;
begin
  Result := false;
  AWarning := '';
  ADecimalSeparator := #0;
  AThousandSeparator := #0;
  if AText = '' then
    exit;

  fs := DefaultFormatSettings;

  // We scan the string starting from its end. If we find a point or a comma,
  // we have a candidate for the decimal or thousand separator. If we find
  // the same character again it was a thousand separator, if not it was
  // a decimal separator.

  // There is one amgiguity: Using a thousand separator for number < 1.000.000,
  // but no decimal separator misinterprets the thousand separator as a
  // decimal separator.

  done := false;      // Indicates that both decimal and thousand separators are found
  testSep := #0;      // Separator candidate to be tested
  testSepPos := 0;    // Position of this separator candidate in the string
  lastDigitPos := 0;  // Position of the last numerical digit
  isPercent := false; // Flag for percentage format

  i := Length(AText);    // Start at end...
  while i >= 1 do        // ...and search towards start
  begin
    case AText[i] of
      '0'..'9':
        if (lastDigitPos = 0) and (AText[i] in ['0'..'9']) then
          lastDigitPos := i;

      'e', 'E':
        ;

      '%':
        begin
          isPercent := true;
          // There may be spaces before the % sign which we don't want
          dec(i);
          while (i >= 1) do
            if AText[i] = ' ' then
              dec(i)
            else
            begin
              inc(i);
              break;
            end;
        end;

      '+', '-':
        ;

      '.', ',':
        begin
          if testSep = #0 then begin
            testSep := AText[i];
            testSepPos := i;
          end;
          // This is the right-most separator candidate in the text
          // It can be a decimal or a thousand separator.
          // Therefore, we continue searching from here.
          dec(i);
          while i >= 1 do
          begin
            if not (AText[i] in ['0'..'9', '+', '-', '.', ',']) then
              exit;

            // If we find the testSep character again it must be a thousand separator,
            // and there are no decimals.
            if (AText[i] = testSep) then
            begin
              // ... but only if there are 3 numerical digits in between
              if (testSepPos - i = 4) then
              begin
                fs.ThousandSeparator := testSep;
                // The decimal separator is the "other" character.
                if testSep = '.' then
                  fs.DecimalSeparator := ','
                else
                  fs.DecimalSeparator := '.';
                AThousandSeparator := fs.ThousandSeparator;
                ADecimalSeparator := #0; // this indicates that there are no decimals
                done := true;
                i := 0;
              end else
              begin
                Result := false;
                exit;
              end;
            end
            else
            // If we find the "other" separator character, then testSep was a
            // decimal separator and the current character is a thousand separator.
            // But there must be 3 digits in between.
            if AText[i] in ['.', ','] then
            begin
              if testSepPos - i <> 4 then  // no 3 digits in between --> no number, maybe a date.
                exit;
              fs.DecimalSeparator := testSep;
              fs.ThousandSeparator := AText[i];
              ADecimalSeparator := fs.DecimalSeparator;
              AThousandSeparator := fs.ThousandSeparator;
              done := true;
              i := 0;
            end;
            dec(i);
          end;
        end;

      else
        exit;  // Non-numeric character found, no need to continue

    end;
    dec(i);
  end;

  // Only one separator candicate found, we assume it is a decimal separator
  if (testSep <> #0) and not done then
  begin
    // Warning in case of ambiguous detection of separator. If only one separator
    // type is found and it is at the third position from the string's end it
    // might by a thousand separator or a decimal separator. We assume the
    // latter case, but create a warning.
    if (lastDigitPos - testSepPos = 3) and not isPercent then
      AWarning := Format(rsAmbiguousDecThouSeparator, [AText]);
    fs.DecimalSeparator := testSep;
    ADecimalSeparator := fs.DecimalSeparator;
    // Make sure that the thousand separator is different from the decimal sep.
    if testSep = '.' then fs.ThousandSeparator := ',' else fs.ThousandSeparator := '.';
  end;

  // Delete all thousand separators from the string - StrToFloat does not like them...
  AText := StringReplace(AText, fs.ThousandSeparator, '', [rfReplaceAll]);

  // Is the last character a percent sign?
  if isPercent then
    while (Length(AText) > 0) and (AText[Length(AText)] in ['%', ' ']) do
      Delete(AText, Length(AText), 1);

  // Try string-to-number conversion
  Result := TryStrToFloat(AText, ANumber, fs);

  // If successful ...
  if Result then
  begin
    // ... take care of the percentage sign
    if isPercent then
      ANumber := ANumber * 0.01;
  end;
end;

{@@ ----------------------------------------------------------------------------
  Assumes that the specified text is a string representation of a mathematical
  fraction and tries to extract the floating point value of this number.
  Returns also the maximum count of digits used in the numerator or
  denominator of the fraction

  @param  AText       String to be considered
  @param  ANumber     (out) value of the converted floating point number
  @param  AMaxDigits  Maximum count of digits used in the numerator or
                      denominator of the fraction

  @return TRUE if a number value can be retrieved successfully, FALSE otherwise

  @example  AText := '1 3/4' --> ANumber = 1.75; AMaxDigits = 1; Result = true
-------------------------------------------------------------------------------}
function TryFractionStrToFloat(AText: String; out ANumber: Double;
  out AIsMixed: Boolean; out AMaxDigits: Integer): Boolean;
var
  p: Integer;
  s, sInt, sNum, sDenom: String;
  i,num,denom: Integer;
begin
  Result := false;
  s := '';
  sInt := '';
  sNum := '';
  sDenom := '';

  p := 1;
  while p <= Length(AText) do begin
    case AText[p] of
      '0'..'9': s := s + AText[p];
      ' ': begin sInt := s; s := ''; end;
      '/': begin sNum := s; s := ''; end;
      else exit;
    end;
    inc(p);
  end;
  sDenom := s;

  if (sInt <> '') and not TryStrToInt(sInt, i) then
    exit;
  if (sNum = '') or not TryStrtoInt(sNum, num) then
    exit;
  if (sDenom = '') or not TryStrToInt(sDenom, denom) then
    exit;
  if denom = 0 then
    exit;

  ANumber := num / denom;
  if sInt <> '' then
    ANumber := ANumber + i;

  AIsMixed := (sInt <> '');
  AMaxDigits := Length(sDenom);

  Result := true;
end;

{@@ ----------------------------------------------------------------------------
  Excel's unit of row heights is "twips", i.e. 1/20 point.
  Converts Twips to points.

  @param   AValue   Length value in twips
  @return  Value converted to points
-------------------------------------------------------------------------------}
function TwipsToPts(AValue: Integer): Single;
begin
  Result := AValue / 20;
end;

{@@ ----------------------------------------------------------------------------
  Converts points to twips (1 twip = 1/20 point)

  @param   AValue   Length value in points
  @return  Value converted to twips
-------------------------------------------------------------------------------}
function PtsToTwips(AValue: Single): Integer;
begin
  Result := round(AValue * 20);
end;

{@@ ----------------------------------------------------------------------------
  Converts centimeters to points (72 pts = 1 inch)

  @param   AValue  Length value in centimeters
  @return  Value converted to points
-------------------------------------------------------------------------------}
function cmToPts(AValue: Double): Double;
begin
  Result := AValue * 72 / 2.54;
end;

{@@ ----------------------------------------------------------------------------
  Converts points to centimeters

  @param   AValue   Length value in points
  @return  Value converted to centimeters
-------------------------------------------------------------------------------}
function PtsToCm(AValue: Double): Double;
begin
  Result := AValue / 72 * 2.54;
end;

{@@ ----------------------------------------------------------------------------
  Converts inches to millimeters

  @param   AValue   Length value in inches
  @return  Value converted to mm
-------------------------------------------------------------------------------}
function InToMM(AValue: Double): Double;
begin
  Result := AValue * 25.4;
end;

{@@ ----------------------------------------------------------------------------
  Converts millimeters to inches

  @param   AValue   Length value in millimeters
  @return  Value converted to inches
-------------------------------------------------------------------------------}
function mmToIn(AValue: Double): Double;
begin
  Result := AValue / 25.4;
end;

{@@ ----------------------------------------------------------------------------
  Converts inches to points (72 pts = 1 inch)

  @param   AValue   Length value in inches
  @return  Value converted to points
-------------------------------------------------------------------------------}
function InToPts(AValue: Double): Double;
begin
  Result := AValue * 72;
end;

{@@ ----------------------------------------------------------------------------
  Converts points to inches (72 pts = 1 inch)

  @param   AValue   Length value in points
  @return  Value converted to inches
-------------------------------------------------------------------------------}
function PtsToIn(AValue: Double): Double;
begin
  Result := AValue / 72;
end;

{@@ ----------------------------------------------------------------------------
  Converts millimeters to points (72 pts = 1 inch)

  @param   AValue   Length value in millimeters
  @return  Value converted to points
-------------------------------------------------------------------------------}
function mmToPts(AValue: Double): Double;
begin
  Result := AValue * 72 / 25.4;
end;

{@@ ----------------------------------------------------------------------------
  Converts points to millimeters

  @param    AValue   Length value in points
  @return   Value converted to millimeters
-------------------------------------------------------------------------------}
function PtsToMM(AValue: Double): Double;
begin
  Result := AValue / 72 * 25.4;
end;

{@@ ----------------------------------------------------------------------------
  Converts pixels to points.

  @param   AValue                Length value given in pixels
  @param   AScreenPixelsPerInch  Pixels per inch of the screen
  @return  Value converted to points
-------------------------------------------------------------------------------}
function pxToPts(AValue, AScreenPixelsPerInch: Integer): Double;
begin
  Result := (AValue / AScreenPixelsPerInch) * 72;
end;

{@@ ----------------------------------------------------------------------------
  Converts points to pixels
  @param   AValue                Length value given in points
  @param   AScreenPixelsPerInch  Pixels per inch of the screen
  @return  Value converted to pixels
-------------------------------------------------------------------------------}
function PtsToPx(AValue: Double; AScreenPixelsPerInch: Integer): Integer;
begin
  Result := Round(AValue / 72 * AScreenPixelsPerInch);
end;

{@@ ----------------------------------------------------------------------------
  Converts a HTML length string to points. The units are assumed to be the last
  two digits of the string, such as '1.25in'

  @param   AValue   HTML string representing a length with appended units code,
                    such as '1.25in'. These unit codes are accepted:
                    'px' (pixels), 'pt' (points), 'in' (inches), 'mm' (millimeters),
                    'cm' (centimeters).
  @param   DefaultUnits  String identifying the units to be used if not contained
                         in AValue.
  @return  Extracted length in points
-------------------------------------------------------------------------------}
function HTMLLengthStrToPts(AValue: String; DefaultUnits: String = 'pt'): Double;
var
  units: String;
  x: Double;
  res: Word;
begin
  if (Length(AValue) > 1) and (AValue[Length(AValue)] in ['a'..'z', 'A'..'Z']) then begin
    units := lowercase(Copy(AValue, Length(AValue)-1, 2));
    if units = '' then units := DefaultUnits;
    val(copy(AValue, 1, Length(AValue)-2), x, res);
    // No hasseling with the decimal point...
  end else begin
    units := DefaultUnits;
    val(AValue, x, res);
  end;
  if res <> 0 then
    raise Exception.CreateFmt('No valid number or units (%s)', [AValue]);

  if (units = 'pt') or (units = '') then
    Result := x
  else
  if units = 'in' then
    Result := InToPts(x)
  else if units = 'cm' then
    Result := cmToPts(x)
  else if units = 'mm' then
    Result := mmToPts(x)
  else if units = 'px' then
    Result := pxToPts(Round(x), ScreenPixelsPerInch)
  else
    raise Exception.Create('Unknown length units');
end;

{@@ ----------------------------------------------------------------------------
  Determines the name of a color from its rgb value
-------------------------------------------------------------------------------}
function GetColorName(AColor: TsColor): string;
var
  rgba: TRGBA absolute AColor;
begin
  case AColor of
    scAqua       : Result := rsAqua;
    scBeige      : Result := rsBeige;
    scBlack      : Result := rsBlack;
    scBlue       : Result := rsBlue;
    scBlueGray   : Result := rsBlueGray;
    scBrown      : Result := rsBrown;
    scCoral      : Result := rsCoral;
    scCyan       : Result := rsCyan;
    scDarkBlue   : Result := rsDarkBlue;
    scDarkGreen  : Result := rsDarkGreen;
    scDarkPurple : Result := rsDarkPurple;
    scDarkRed    : Result := rsDarkRed;
    scDarkTeal   : Result := rsDarkTeal;
    scGold       : Result := rsGold;
    scGray       : Result := rsGray;
    scGray10pct  : Result := rsGray10pct;
    scGray20pct  : Result := rsGray20pct;
    scGray40pct  : Result := rsGray40pct;
    scGray80pct  : Result := rsGray80pct;
    scGreen      : Result := rsGreen;
    scIceBlue    : Result := rsIceBlue;
    scIndigo     : Result := rsIndigo;
    scIvory      : Result := rsIvory;
    scLavander   : Result := rsLavander;
    scLightBlue  : Result := rsLightBlue;
    scLightGreen : Result := rsLightGreen;
    scLightOrange: Result := rsLightOrange;
    scLightTurquoise: Result := rsLightTurquoise;
    scLightYellow: Result := rsLightYellow;
    scLime       : Result := rsLime;
    scMagenta    : Result := rsMagenta;
    scNavy       : Result := rsNavy;
    scOceanBlue  : Result := rsOceanBlue;
    scOlive      : Result := rsOlive;
    scOliveGreen : Result := rsOliveGreen;
    scOrange     : Result := rsOrange;
    scPaleBlue   : Result := rsPaleBlue;
    scPeriwinkle : Result := rsPeriwinkle;
    scPink       : Result := rsPink;
    scPlum       : Result := rsPlum;
    scPurple     : Result := rsPurple;
    scRed        : Result := rsRed;
    scRose       : Result := rsRose;
    scSeaGreen   : Result := rsSeaGreen;
    scSilver     : Result := rsSilver;
    scSkyBlue    : Result := rsSkyBlue;
    scTan        : Result := rsTan;
    scTeal       : Result := rsTeal;
    scVeryDarkGreen: Result := rsVeryDarkGreen;
//    scViolet     : Result := rsViolet;
    scWheat      : Result := rsWheat;
    scWhite      : Result := rsWhite;
    scYellow     : Result := rsYellow;
    scTransparent: Result := rsTransparent;
    scNotDefined : Result := rsNotDefined;
    else
      case rgba.a of
        $00:
          Result := Format('R%d G%d B%d', [rgba.r, rgba.g, rgba.b]);
        scPaletteIndexMask shr 24:
          Result := Format(rsPaletteIndex, [AColor and $00FFFFFF]);
        else
          Result := '';
      end;
  end;
end;

{@@ ----------------------------------------------------------------------------
  Converts a HTML color string to a TsColor alue. Needed for the ODS file format.

  @param   AValue         HTML color string, such as '#FF0000'
  @return  rgb color value in little endian byte-sequence. This value is
           compatible with the TColor data type of the graphics unit.
-------------------------------------------------------------------------------}
function HTMLColorStrToColor(AValue: String): TsColor;
var
  c: Integer;
begin
  if AValue = '' then
    Result := scNotDefined
  else
  if AValue[1] = '#' then begin
    AValue[1] := '$';
    Result := LongRGBToExcelPhysical(DWord(StrToInt(AValue)));
  end else begin
    AValue := lowercase(AValue);
    if AValue = 'red' then
      Result := $0000FF
    else if AValue = 'cyan' then
      Result := $FFFF00
    else if AValue = 'blue' then
      Result := $FF0000
    else if AValue = 'purple' then
      Result := $800080
    else if AValue = 'yellow' then
      Result := $00FFFF
    else if AValue = 'lime' then
      Result := $00FF00
    else if AValue = 'white' then
      Result := $FFFFFF
    else if AValue = 'black' then
      Result := $000000
    else if (AValue = 'gray') or (AValue = 'grey') then
      Result := $808080
    else if AValue = 'silver' then
      Result := $C0C0C0
    else if AValue = 'maroon' then
      Result := $000080
    else if AValue = 'green' then
      Result := $008000
    else if AValue = 'olive' then
      Result := $008080
    else if TryStrToInt('$' + AValue, c) then
      Result := LongRGBToExcelPhysical(DWord(StrToInt('$' + AValue)))
    else
      Result := scNotDefined
  end;
end;

{@@ ----------------------------------------------------------------------------
  Converts an rgb color value to a string as used in HTML code (for ods)

  @param   AValue          RGB color value (compatible with the TColor data type
                           of the graphics unit)
  @param   AExcelDialect   If TRUE, returned string is in Excels format for xlsx,
                           i.e. in AARRGGBB notation, like '00FF0000' for "red"
  @return  HTML-compatible string, like '#FF0000' (AExcelDialect = false)
-------------------------------------------------------------------------------}
function ColorToHTMLColorStr(AValue: TsColor;
  AExcelDialect: Boolean = false): String;
var
  rgb: TRGBA absolute AValue;
begin
  if AExcelDialect then
    Result := Format('00%.2x%.2x%.2x', [rgb.r, rgb.g, rgb.b])
  else
    Result := Format('#%.2x%.2x%.2x', [rgb.r, rgb.g, rgb.b]);
end;

{@@ ----------------------------------------------------------------------------
  Converts a string encoded in UTF8 to a string usable in XML. For this purpose,
  some characters must be translated.

  @param   AText  input string encoded as UTF8
  @return  String usable in XML with some characters replaced by the HTML codes.
-------------------------------------------------------------------------------}
function UTF8TextToXMLText(AText: ansistring): ansistring;
var
  Idx: Integer;
  AppoSt:ansistring;
begin
  Result := '';
  idx := 1;
  while idx <= Length(AText) do
  begin
    case AText[Idx] of
      '&': begin
        AppoSt := Copy(AText, Idx, 6);
        if (Pos('&amp;',  AppoSt) = 1) or
           (Pos('&lt;',   AppoSt) = 1) or
           (Pos('&gt;',   AppoSt) = 1) or
           (Pos('&quot;', AppoSt) = 1) or
           (Pos('&apos;', AppoSt) = 1) or
           (Pos('&#37;',  AppoSt) = 1)     // %
        then begin
          //'&' is the first char of a special chat, it must not be converted
          Result := Result + AText[Idx];
        end else begin
          Result := Result + '&amp;';
        end;
      end;
      '<': Result := Result + '&lt;';
      '>': Result := Result + '&gt;';
      '"': Result := Result + '&quot;';
      '''':Result := Result + '&apos;';
      '%': Result := Result + '&#37;';
      {     this breaks multi-line labels in xlsx
      #10: begin
             Result := Result + '<br />';
             if (idx < Length(AText)) and (AText[idx+1] = #13) then inc(idx);
           end;
      #13: begin
             Result := Result + '<br />';
             if (idx < Length(AText)) and (AText[idx+1] = #10) then inc(idx);
           end;
           }
      {
      #10: WrkStr := WrkStr + '&#10;';
      #13: WrkStr := WrkStr + '&#13;';
      }
    else
      Result := Result + AText[Idx];
    end;
    inc(idx);
  end;
end;

{@@ ----------------------------------------------------------------------------
  Checks a string for characters that are not permitted in XML strings.
  The function returns FALSE if a character <#32 is contained (except for
  #9, #10, #13), TRUE otherwise. Invalid characters are replaced by a box symbol.

  If ReplaceSpecialChars is TRUE, some other characters are converted
  to valid HTML codes by calling UTF8TextToXMLText

  @param  AText                String to be checked. Is replaced by valid string.
  @param  ReplaceSpecialChars  Special characters are replaced by their HTML
                               codes (e.g. '>' --> '&gt;')
  @return FALSE if characters < #32 were replaced, TRUE otherwise.
-------------------------------------------------------------------------------}
function ValidXMLText(var AText: ansistring;
  ReplaceSpecialChars: Boolean = true): Boolean;
const
  BOX = #$E2#$8E#$95;
var
  i: Integer;
begin
  Result := true;
  for i := Length(AText) downto 1 do
    if (AText[i] < #32) and not (AText[i] in [#9, #10, #13]) then begin
      // Replace invalid character by box symbol
      Delete(AText, i, 1);
      Insert(BOX, AText, i);
//      AText[i] := '?';
      Result := false;
    end;
  if ReplaceSpecialChars then
    AText := UTF8TextToXMLText(AText);
end;


{@@ ----------------------------------------------------------------------------
  Extracts compare information from an input string such as "<2.4".
  Is needed for some Excel-strings.

  @param  AString     Input string starting with "<", "<=", ">", ">=", "<>" or "="
                      If this start code is missing a "=" is assumed.
  @param  ACompareOp  Identifier for the comparing operation extracted
                      - see TsCompareOperation
  @return Input string with the comparing characters stripped.
-------------------------------------------------------------------------------}
function AnalyzeComparestr(AString: String; out ACompareOp: TsCompareOperation): String;

  procedure RemoveChars(ACount: Integer; ACompare: TsCompareOperation);
  begin
    ACompareOp := ACompare;
    if ACount = 0 then
      Result := AString
    else
      Result := Copy(AString, 1+ACount, Length(AString));
  end;

begin
  if Length(AString) > 1 then
    case AString[1] of
      '<' : case AString[2] of
              '>' : RemoveChars(2, coNotEqual);
              '=' : RemoveChars(2, coLessEqual);
              else  RemoveChars(1, coLess);
            end;
      '>' : case AString[2] of
              '=' : RemoveChars(2, coGreaterEqual);
              else  RemoveChars(1, coGreater);
            end;
      '=' : RemoveChars(1, coEqual);
      else  RemoveChars(0, coEqual);
    end
  else
    RemoveChars(0, coEqual);
end;

{@@ ----------------------------------------------------------------------------
  Replaces CRLF line endings by LF (#10) alone because this is what xml returns.
  This is required to keep the character indexes of the rich text formatting
  runs in synch when reading xml files.
-------------------------------------------------------------------------------}
procedure FixLineEndings(var AText: String; var ARichTextParams: TsRichTextParams);
var
  i, j: Integer;
begin
  if AText = '' then
    exit;

  i := 1;
  if AText[Length(AText)] = #13 then
    Delete(AText, Length(AText), 1);

  while i <= Length(AText) - 1 do
  begin
    if (AText[i] = #13) and (AText[i+1] = #10) then
    begin
      Delete(AText, i, 1);
      for j := 0 to High(ARichTextParams) do
        if ARichTextParams[j].FirstIndex > i then dec(ARichTextParams[j].FirstIndex);
    end;
    inc(i);
  end;
end;

{@@ ----------------------------------------------------------------------------
  Removes quotation characters which enclose a string
-------------------------------------------------------------------------------}
function UnquoteStr(AString: String): String;
begin
  Result := AString;
  if Result = '' then exit;
  if ((Result[1] = '''') and (Result[Length(Result)] = '''')) or
     (Result[1] = '"') and (Result[Length(Result)] = '"') then
  begin
    Delete(Result, 1, 1);
    Delete(Result, Length(Result), 1);
  end;
end;

{@@ ----------------------------------------------------------------------------
  Initializes a Sortparams record. This record sets paramaters used when cells
  are sorted.

  @param  ASortByCols     If true sorting occurs along columns, i.e. the
                          ColRowIndex of the sorting keys refer to column indexes.
                          If False, sorting occurs along rows, and the
                          ColRowIndexes refer to row indexes
                          Default: true
  @param  ANumSortKeys    Determines how many columns or rows are used as sorting
                          keys. (Default: 1). Every sort key is initialized for
                          ascending sort direction and case-sensitive comparison.
  @param  ASortPriority   Determines the order or text and numeric data in
                          mixed content type cell ranges.
                          Default: spNumAlpha, i.e. numbers before text (in
                          ascending sort)
  @return The initializaed TsSortParams record
-------------------------------------------------------------------------------}
function InitSortParams(ASortByCols: Boolean = true; ANumSortKeys: Integer = 1;
  ASortPriority: TsSortPriority = spNumAlpha): TsSortParams;
var
  i: Integer;
begin
  Result.SortByCols := ASortByCols;
  Result.Priority := ASortPriority;
  SetLength(Result.Keys, ANumSortKeys);
  for i:=0 to High(Result.Keys) do begin
    Result.Keys[i].ColRowIndex := i;
    Result.Keys[i].Options := [];  // Ascending & case-sensitive
  end;
end;

{@@ ----------------------------------------------------------------------------
  Splits a hyperlink string at the # character.

  @param  AValue     Hyperlink string to be processed
  @param  ATarget    Part before the # ("Target")
  @param  ABookmark  Part after the # ("Bookmark")
-------------------------------------------------------------------------------}
procedure SplitHyperlink(AValue: String; out ATarget, ABookmark: String);
var
  p: Integer;
begin
  p := pos('#', AValue);
  if p = 0 then
  begin
    ATarget := AValue;
    ABookmark := '';
  end else
  begin
    ATarget := Copy(AValue, 1, p-1);
    ABookmark := Copy(AValue, p+1, Length(AValue));
  end;
end;

{@@ ----------------------------------------------------------------------------
  Replaces backslashes by forward slashes in hyperlink path names
-------------------------------------------------------------------------------}
procedure FixHyperlinkPathDelims(var ATarget: String);
var
  i: Integer;
begin
  for i:=1 to Length(ATarget) do
    if ATarget[i] = '\' then ATarget[i] := '/';
end;

{@@ ----------------------------------------------------------------------------
  Initalizes a new cell.
  @return  New cell record
-------------------------------------------------------------------------------}
procedure InitCell(out ACell: TCell);
begin
  ACell.FormulaValue := '';
  ACell.UTF8StringValue := '';
  FillChar(ACell, SizeOf(ACell), 0);
end;

{@@ ----------------------------------------------------------------------------
  Initalizes a new cell and presets the row and column fields of the cell record
  to the parameters passed to the procedure.

  @param  ARow   Row index of the new cell
  @param  ACol   Column index of the new cell
  @return New cell record with row and column fields preset to passed values.
-------------------------------------------------------------------------------}
procedure InitCell(ARow, ACol: Cardinal; out ACell: TCell);
begin
  InitCell(ACell);
  ACell.Row := ARow;
  ACell.Col := ACol;
end;

{@@ ----------------------------------------------------------------------------
  Initializes the fields of a TsCellFormaRecord
-------------------------------------------------------------------------------}
procedure InitFormatRecord(out AValue: TsCellFormat);
begin
  AValue.Name := '';
  AValue.NumberFormatStr := '';
  FillChar(AValue, SizeOf(AValue), 0);
  AValue.BorderStyles := DEFAULT_BORDERSTYLES;
  AValue.Background := EMPTY_FILL;
  AValue.NumberFormatIndex := -1;  // GENERAL format not contained in NumFormatList
end;

{@@ ----------------------------------------------------------------------------
  Initializes the fields of a TsPageLayout record
-------------------------------------------------------------------------------}
procedure InitPageLayout(out APageLayout: TsPageLayout);
var
  i: Integer;
begin
  with APageLayout do begin
    Orientation := spoPortrait;
    PageWidth := 210;
    PageHeight := 297;
    LeftMargin := InToMM(0.7);
    RightMargin := InToMM(0.7);
    TopMargin := InToMM(0.78740157499999996);
    BottomMargin := InToMM(0.78740157499999996);
    HeaderMargin := InToMM(0.3);
    FooterMargin := InToMM(0.3);
    StartPageNumber := 1;
    ScalingFactor := 100;   // Percent
    FitWidthToPages := 0;   // use as many pages as needed
    FitHeightToPages := 0;
    Copies := 1;
    Options := [];
    for i:=0 to 2 do Headers[i] := '';
    for i:=0 to 2 do Footers[i] := '';
  end;
end;

{@@ ----------------------------------------------------------------------------
  Copies the value of a cell to another one. Does not copy the formula, erases
  the formula of the destination cell if there is one!

  @param  AFromCell   Cell from which the value is to be copied
  @param  AToCell     Cell to which the value is to be copied
-------------------------------------------------------------------------------}
procedure CopyCellValue(AFromCell, AToCell: PCell);
begin
  Assert(AFromCell <> nil);
  Assert(AToCell <> nil);

  AToCell^.ContentType := AFromCell^.ContentType;
  AToCell^.NumberValue := AFromCell^.NumberValue;
  AToCell^.DateTimeValue := AFromCell^.DateTimeValue;
  AToCell^.BoolValue := AFromCell^.BoolValue;
  AToCell^.ErrorValue := AFromCell^.ErrorValue;
  AToCell^.UTF8StringValue := AFromCell^.UTF8StringValue;
  AToCell^.FormulaValue := '';    // This is confirmed with Excel
end;

{@@ ----------------------------------------------------------------------------
  Returns TRUE if the cell contains a formula.

  @param   ACell   Pointer to the cell checked
-------------------------------------------------------------------------------}
function HasFormula(ACell: PCell): Boolean;
begin
  Result := Assigned(ACell) and (Length(ACell^.FormulaValue) > 0);
end;

{@@ ----------------------------------------------------------------------------
  Checks whether two format records have same border attributes

  @param  AFormat1  Pointer to the first one of the two format records to be compared
  @param  AFormat2  Pointer to the second one of the two format records to be compared
-------------------------------------------------------------------------------}
function SameCellBorders(AFormat1, AFormat2: PsCellFormat): Boolean;

  function NoBorder(AFormat: PsCellFormat): Boolean;
  begin
    Result := (AFormat = nil) or
      not (uffBorder in AFormat^.UsedFormattingFields) or
      (AFormat^.Border = []);
  end;

var
  nobrdr1, nobrdr2: Boolean;
  cb: TsCellBorder;
begin
  nobrdr1 := NoBorder(AFormat1);
  nobrdr2 := NoBorder(AFormat2);
  if (nobrdr1 and nobrdr2) then
    Result := true
  else
  if (nobrdr1 and (not nobrdr2) ) or ( (not nobrdr1) and nobrdr2) then
    Result := false
  else begin
    Result := false;
    if AFormat1^.Border <> AFormat2^.Border then
      exit;
    for cb in TsCellBorder do begin
      if AFormat1^.BorderStyles[cb].LineStyle <> AFormat2^.BorderStyles[cb].LineStyle then
        exit;
      if AFormat1^.BorderStyles[cb].Color <> AFormat2^.BorderStyles[cb].Color then
        exit;
    end;
    Result := true;
  end;
end;

{@@ ----------------------------------------------------------------------------
  Checks whether two fonts are equal

  @param  AFont1  Pointer to the first font to be compared
  @param  AFont2  Pointer to the second font to be compared
-------------------------------------------------------------------------------}
function SameFont(AFont1, AFont2: TsFont): Boolean;
const
  EPS = 1E-3;
begin
  if (AFont1 = nil) and (AFont2 = nil) then
    Result := true
  else
  if (AFont2 <> nil) then
    Result := SameFont(AFont1, AFont2.FontName, AFont2.Size, AFont2.Style, AFont2.Color, AFont2.Position)
  else
    Result := false;
end;

{@@ ----------------------------------------------------------------------------
  Checks whether two fonts are equal

  @param  AFont1  Pointer to the first font to be compared
  @param  AFont2  Pointer to the second font to be compared
-------------------------------------------------------------------------------}
function SameFont(AFont: TsFont; AFontName: String; AFontSize: Single;
  AStyle: TsFontStyles; AColor: TsColor; APos: TsFontPosition): Boolean;
const
  EPS = 1E-3;
begin
  Result := (AFont <> nil) and
            SameText(AFont.FontName, AFontName) and
            SameValue(AFont.Size, AFontSize, EPS) and
            (AFont.Style = AStyle) and
            (AFont.Color = AColor) and
            (AFont.Position = APos);
end;

{@@ ----------------------------------------------------------------------------
  Constructs a string of length "Len" containing random uppercase characters
-------------------------------------------------------------------------------}
function GetRandomString(Len: Integer): String;
begin
  Result := '';
  While Length(Result) < Len do
    Result := Result + char(ord('A') + random(26));
end;
  (*
{@@ ----------------------------------------------------------------------------
  Constructs a unique folder name in the temp directory of the OS
-------------------------------------------------------------------------------}
function GetUniqueTempDir(Global: Boolean): String;
var
  tempdir: String;
begin
  tempdir := AppendPathDelim(GetTempDir(Global));
  repeat
    Result := tempdir + AppendPathDelim(GetRandomString(8));
  until not DirectoryExists(Result);
end;
    *)
{@@ ----------------------------------------------------------------------------
  Appends a string to a stream

  @param  AStream   Stream to which the string will be added
  @param  AString   String to be written to the stream
-------------------------------------------------------------------------------}
procedure AppendToStream(AStream: TStream; const AString: string);
begin
  if Length(AString) > 0 then
    AStream.WriteBuffer(AString[1], Length(AString));
end;

{@@ ----------------------------------------------------------------------------
  Appends two strings to a stream

  @param  AStream   Stream to which the strings will be added
  @param  AString1  First string to be written to the stream
  @param  AString2  Second string to be written to the stream
-------------------------------------------------------------------------------}
procedure AppendToStream(AStream: TStream; const AString1, AString2: String);
begin
  AppendToStream(AStream, AString1);
  AppendToStream(AStream, AString2);
end;

{@@ ----------------------------------------------------------------------------
  Appends three strings to a stream

  @param  AStream   Stream to which the strings will be added
  @param  AString1  First string to be written to the stream
  @param  AString2  Second string to be written to the stream
  @param  AString3  Third string to be written to the stream
-------------------------------------------------------------------------------}
procedure AppendToStream(AStream: TStream; const AString1, AString2, AString3: String);
begin
  AppendToStream(AStream, AString1);
  AppendToStream(AStream, AString2);
  AppendToStream(AStream, AString3);
end;

{ Modifying colors }
{ Next function are copies of GraphUtils to avoid a dependence on the Graphics unit. }

const
  HUE_000 = 0;
  HUE_060 = 43;
  HUE_120 = 85;
  HUE_180 = 128;
  HUE_240 = 170;

procedure RGBtoHLS(const R, G, B: Byte; out H, L, S: Byte);
var
  cMax, cMin: Integer;          // max and min RGB values
  Rdelta, Gdelta, Bdelta: Byte; // intermediate value: % of spread from max
  diff: Integer;
begin
  // calculate lightness
  cMax := MaxIntValue([R, G, B]);
  cMin := MinIntValue([R, G, B]);
  L := (integer(cMax) + cMin + 1) div 2;
  diff := cMax - cMin;

  if diff = 0
  then begin
    // r=g=b --> achromatic case
    S := 0;
    H := 0;
  end
  else begin
    // chromatic case
    // saturation
    if L <= 128
    then S := integer(diff * 255) div (cMax + cMin)
    else S := integer(diff * 255) div (510 - cMax - cMin);

    // hue
    Rdelta := (cMax - R);
    Gdelta := (cMax - G);
    Bdelta := (cMax - B);

    if R = cMax
    then H := (HUE_000 + integer(Bdelta - Gdelta) * HUE_060 div diff) and $ff
    else if G = cMax
    then H := HUE_120 + integer(Rdelta - Bdelta) * HUE_060 div diff
    else H := HUE_240 + integer(Gdelta - Rdelta) * HUE_060 div diff;
  end;
end;


procedure HLStoRGB(const H, L, S: Byte; out R, G, B: Byte);

  // utility routine for HLStoRGB
  function HueToRGB(const n1, n2: Byte; Hue: Integer): Byte;
  begin
    if Hue > 255
    then Dec(Hue, 255)
    else if Hue < 0
    then Inc(Hue, 255);

    // return r,g, or b value from this tridrant
    case Hue of
      HUE_000..HUE_060 - 1: Result := n1 + (n2 - n1) * Hue div HUE_060;
      HUE_060..HUE_180 - 1: Result := n2;
      HUE_180..HUE_240 - 1: Result := n1 + (n2 - n1) * (HUE_240 - Hue) div HUE_060;
    else
      Result := n1;
    end;
  end;

var
  n1, n2: Integer;
begin
  if S = 0
  then begin
    // achromatic case
    R := L;
    G := L;
    B := L;
  end
  else begin
    // chromatic case
    // set up magic numbers
    if L < 128
    then begin
      n2 := Integer(L) + Integer(L) * S div 255;
      n1 := 2 * L - n2;
    end
    else begin
      n2 := Integer(S) + L - Integer(L) * S div 255;
      n1 := 2 * L - n2 - 1;
    end;

    // get RGB
    R := HueToRGB(n1, n2, H + HUE_120);
    G := HueToRGB(n1, n2, H);
    B := HueToRGB(n1, n2, H - HUE_120);
  end;
end;

{@@ ----------------------------------------------------------------------------
  Constructs a TsColor from a palette index. It has bit 15 in the high-order
  byte set.
-------------------------------------------------------------------------------}
function SetAsPaletteIndex(AIndex: Integer): TsColor;
begin
  Result := (DWord(AIndex) and scRGBMask) or scPaletteIndexMask;
end;

{@@ ----------------------------------------------------------------------------
  Checks whether the specified TsColor represents a palette index
-------------------------------------------------------------------------------}
function IsPaletteIndex(AColor: TsColor): Boolean;
begin
  Result := AColor and scPaletteIndexMask = scPaletteIndexMask;
end;

{@@ ----------------------------------------------------------------------------
  Excel defines theme colors and applies a "tint" factor (-1...+1) to darken
  or brighten them.

  This method "tints" a given color with a factor

  The algorithm is described in
  http://msdn.microsoft.com/en-us/library/documentformat.openxml.spreadsheet.backgroundcolor.aspx

  @param   AColor   rgb color to be modified
  @param   tint     Factor (-1...+1) to be used for the operation
  @return  Modified color
-------------------------------------------------------------------------------}
function TintedColor(AColor: TsColor; tint: Double): TsColor;
const
  HLSMAX = 255;
var
  r, g, b: byte;
  h, l, s: Byte;
  lum: Double;
begin
  if (tint = 0) or (TRGBA(AColor).a <> 0) then begin
    Result := AColor;
    exit;
  end;

  r := TRGBA(AColor).r;
  g := TRGBA(AColor).g;
  b := TRGBA(AColor).b;
  RGBToHLS(r, g, b, h, l, s);

  lum := l;
  if tint < 0 then
    lum := lum * (1.0 + tint)
  else
  if tint > 0 then
    lum := lum * (1.0-tint) + (HLSMAX - HLSMAX * (1.0-tint));
  l := Min(255, round(lum));
  HLSToRGB(h, l, s, r, g, b);

  TRGBA(Result).r := r;
  TRGBA(Result).g := g;
  TRGBA(Result).b := b;
  TRGBA(Result).a := 0;
end;

{@@ ----------------------------------------------------------------------------
  Returns the color index for black or white depending on a color being "bright"
  or "dark".

  @param   AColor      rgb color to be analyzed
  @return  The color index for black (scBlack) if AColorValue is a "bright" color,
           or white (scWhite) if AColorValue is a "dark" color.
-------------------------------------------------------------------------------}
function HighContrastColor(AColor: TsColor): TsColor;
begin
  if TRGBA(AColor).r + TRGBA(AColor).g + TRGBA(AColor).b < 3*128 then
    Result := scWhite
  else
    Result := scBlack;
end;

{@@ ----------------------------------------------------------------------------
  Converts the RGB part of a LongRGB logical structure to its physical representation.
  In other words: RGBA (where A is 0 and omitted in the function call) => ABGR
  Needed for conversion of palette colors.

  @param  RGB   DWord value containing RGBA bytes in big endian byte-order
  @return       DWord containing RGB bytes in little-endian byte-order (A = 0)
-------------------------------------------------------------------------------}
function LongRGBToExcelPhysical(const RGB: DWord): DWord;
begin
  {$IFDEF FPC}
  {$IFDEF ENDIAN_LITTLE}
  result := RGB shl 8; //tags $00 at end for the A byte
  result := SwapEndian(result); //flip byte order
  {$ELSE}
  //Big endian
  result := RGB; //leave value as is //todo: verify if this turns out ok
  {$ENDIF}
  {$ELSE}
  // messed up result
  {$ENDIF}
end;


{$PUSH}{$HINTS OFF}
{@@ Silence warnings due to an unused parameter }
procedure Unused(const A1);
// code "borrowed" from TAChart
begin
end;

{@@ Silence warnings due to two unused parameters }
procedure Unused(const A1, A2);
// code "borrowed" from TAChart
begin
end;

{@@ Silence warnings due to three unused parameters }
procedure Unused(const A1, A2, A3);
// code adapted from TAChart
begin
end;
{$POP}


{@@ ----------------------------------------------------------------------------
  Creates a FPC format settings record in which all strings are encoded as
  UTF8.
-------------------------------------------------------------------------------}
procedure InitUTF8FormatSettings;
// remove when available in LazUtils
var
  i: Integer;
begin
  UTF8FormatSettings := DefaultFormatSettings;
  UTF8FormatSettings.CurrencyString := AnsiToUTF8(DefaultFormatSettings.CurrencyString);
  for i:=1 to 12 do begin
    UTF8FormatSettings.LongMonthNames[i] := AnsiToUTF8(DefaultFormatSettings.LongMonthNames[i]);
    UTF8FormatSettings.ShortMonthNames[i] := AnsiToUTF8(DefaultFormatSettings.ShortMonthNames[i]);
  end;
  for i:=1 to 7 do begin
    UTF8FormatSettings.LongDayNames[i] := AnsiToUTF8(DefaultFormatSettings.LongDayNames[i]);
    UTF8FormatSettings.ShortDayNames[i] := AnsiToUTF8(DefaultFormatSettings.ShortDayNames[i]);
  end;
end;


initialization
  InitUTF8FormatSettings;

end.

