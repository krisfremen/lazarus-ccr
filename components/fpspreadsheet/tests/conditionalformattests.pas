{ Tests for conditional formatting
  These unit tests write out to and read back from files.
}

unit conditionalformattests;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  // Not using Lazarus package as the user may be working with multiple versions
  // Instead, add .. to unit search path
  Classes, SysUtils, fpcunit, testutils, testregistry, testsutility,
  Math, Variants,
  fpsTypes, fpsUtils, fpsAllFormats, fpSpreadsheet, fpsConditionalFormat;

type
  { TSpreadWriteReadCFTests }
  //Write to xls/xml file and read back
  TSpreadWriteReadCFTests = class(TTestCase)
  private
  protected
    // Set up expected values:
    procedure SetUp; override;
    procedure TearDown; override;

    // Test conditional cell format
    procedure TestWriteRead_CF_CellFmt(AFileFormat: TsSpreadsheetFormat;
      ACondition: TsCFCondition; AValue1, AValue2: Variant; ACellFormat: TsCellFormat);
    procedure TestWriteRead_CF_CellFmt(AFileFormat: TsSpreadsheetFormat;
      ACondition: TsCFCondition; AValue1: Variant; ACellFormat: TsCellFormat);
    procedure TestWriteRead_CF_CellFmt(AFileFormat: TsSpreadsheetFormat;
      ACondition: TsCFCondition; ACellFormat: TsCellFormat);

    procedure TestWriteRead_CF_ColorRange(AFileFormat: TsSpreadsheetFormat;
      ThreeColors: Boolean; FullSyntax: Boolean);

    procedure TestWriteRead_CF_DataBars(AFileFormat: TsSpreadsheetFormat;
      FullSyntax: Boolean);

  published
    procedure TestWriteRead_CF_CellFmt_XLSX_Equal_Const;
    procedure TestWriteRead_CF_CellFmt_XLSX_NotEqual_Const;
    procedure TestWriteRead_CF_CellFmt_XLSX_GreaterThan_Const;
    procedure TestWriteRead_CF_CellFmt_XLSX_LessThan_Const;
    procedure TestWriteRead_CF_CellFmt_XLSX_GreaterEqual_Const;
    procedure TestWriteRead_CF_CellFmt_XLSX_LessEqual_Const;
    procedure TestWriteRead_CF_CellFmt_XLSX_Between_Const;
    procedure TestWriteRead_CF_CellFmt_XLSX_NotBetween_Const;
    procedure TestWriteRead_CF_CellFmt_XLSX_AboveAverage;
    procedure TestWriteRead_CF_CellFmt_XLSX_BelowAverage;
    procedure TestWriteRead_CF_CellFmt_XLSX_AboveEqualAverage;
    procedure TestWriteRead_CF_CellFmt_XLSX_BelowEqualAverage;
    procedure TestWriteRead_CF_CellFmt_XLSX_AboveAverage_2StdDev;
    procedure TestWriteRead_CF_CellFmt_XLSX_BelowAverage_2StdDev;
    procedure TestWriteRead_CF_CellFmt_XLSX_Top3;
    procedure TestWriteRead_CF_CellFmt_XLSX_Top10Percent;
    procedure TestWriteRead_CF_CellFmt_XLSX_Bottom3;
    procedure TestWriteRead_CF_CellFmt_XLSX_Bottom10Percent;
    procedure TestWriteRead_CF_CellFmt_XLSX_BeginsWith;
    procedure TestWriteRead_CF_CellFmt_XLSX_EndsWith;
    procedure TestWriteRead_CF_CellFmt_XLSX_Contains;
    procedure TestWriteRead_CF_CellFmt_XLSX_NotContains;
    procedure TestWriteRead_CF_CellFmt_XLSX_Unique;
    procedure TestWriteRead_CF_CellFmt_XLSX_Duplicate;
    procedure TestWriteRead_CF_CellFmt_XLSX_ContainsErrors;
    procedure TestWriteRead_CF_CellFmt_XLSX_NotContainsErrors;
    procedure TestWriteRead_CF_CellFmt_XLSX_Background;
    procedure TestWriteRead_CF_CellFmt_XLSX_Border;

    procedure TestWriteRead_CF_ColorRange_XLSX_3C_Full;
    procedure TestWriteRead_CF_ColorRange_XLSX_2C_Full;
    procedure TestWriteRead_CF_ColorRange_XLSX_3C_Simple;
    procedure TestWriteRead_CF_ColorRange_XLSX_2C_Simple;

    procedure TestWriteRead_CF_Databars_XLSX_Full;
    procedure TestWriteRead_CF_Databars_XLSX_Simple;

  end;

implementation

uses
  TypInfo;


{ TSpreadWriteReadCFTests }

procedure TSpreadWriteReadCFTests.SetUp;
begin
  inherited SetUp;
end;

procedure TSpreadWriteReadCFTests.TearDown;
begin
  inherited TearDown;
end;


{-------------------------------------------------------------------------------
                        Conditional cell format tests
-------------------------------------------------------------------------------}
procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt(
  AFileFormat: TsSpreadsheetFormat; ACondition: TsCFCondition; ACellFormat: TsCellFormat);
var
  dummy: variant;
begin
  VarClear(dummy);
  TestWriteRead_CF_CellFmt(AFileFormat, ACondition, dummy, dummy, ACellFormat);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt(
  AFileFormat: TsSpreadsheetFormat; ACondition: TsCFCondition;
  AValue1: Variant; ACellFormat: TsCellFormat);
var
  dummy: Variant;
begin
  VarClear(dummy);
  TestWriteRead_CF_CellFmt(AFileFormat, ACondition, AValue1, dummy, ACellFormat);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt(
  AFileFormat: TsSpreadsheetFormat; ACondition: TsCFCondition;
  AValue1, AValue2: Variant; ACellFormat: TsCellFormat);
const
  SHEET_NAME = 'CF';
  TEXTS: array[0..6] of String = ('abc', 'def', 'ghi', 'abc', 'jkl', 'akl', 'ab');
var
  worksheet: TsWorksheet;
  workbook: TsWorkbook;
  row, col: Cardinal;
  tempFile: string;
  sollFmtIdx: Integer;
  sollRange: TsCellRange;
  actFMT: TsCellFormat;
  actFmtIdx: Integer;
  actRange: TsCellRange;
  actCondition: TsCFCondition;
  actValue1, actValue2: Variant;
  cf: TsConditionalFormat;
begin
  // Write out all test values
  workbook := TsWorkbook.Create;
  try
    workbook.Options := [boAutoCalc];
    workSheet:= workBook.AddWorksheet(SHEET_NAME);

    row := 0;
    for Col := 0 to High(TEXTS) do
      worksheet.WriteText(row, col, TEXTS[col]);

    row := 1;
    for col := 0 to 9 do
      worksheet.WriteNumber(row, col, col+1);
    worksheet.WriteFormula(row, col, '=1/0');

    // Write format used by the cells detected by conditional formatting
    sollFmtIdx := workbook.AddCellFormat(ACellFormat);

    // Write instruction for conditional formatting
    sollRange := Range(0, 0, 1, 10);
    if VarIsEmpty(AValue1) and VarIsEmpty(AValue2) then
      worksheet.WriteConditionalCellFormat(sollRange, ACondition, sollFmtIdx)
    else
    if VarIsEmpty(AValue2) then
      worksheet.WriteConditionalCellFormat(sollRange, ACondition, AValue1, sollFmtIdx)
    else
      worksheet.WriteConditionalCellFormat(sollRange, ACondition, AValue1, AValue2, sollFmtIdx);

    // Save to file
    tempFile := NewTempFile;
    workBook.WriteToFile(tempFile, AFileFormat, true);
  finally
    workbook.Free;
  end;

  // Open the spreadsheet
  workbook := TsWorkbook.Create;
  try
    workbook.ReadFromFile(TempFile, AFileFormat);
    worksheet := GetWorksheetByName(workBook, SHEET_NAME);

    if worksheet=nil then
      fail('Error in test code. Failed to get named worksheet');

    // Check count of conditional formats
    CheckEquals(1, workbook.GetNumConditionalFormats, 'ConditionalFormat count mismatch.');

    // Read conditional format
    cf := Workbook.GetConditionalFormat(0);

    //Check range
    actRange := cf.CellRange;
    CheckEquals(sollRange.Row1, actRange.Row1, 'Conditional format range mismatch (Row1)');
    checkEquals(sollRange.Col1, actRange.Col1, 'Conditional format range mismatch (Col1)');
    CheckEquals(sollRange.Row2, actRange.Row2, 'Conditional format range mismatch (Row2)');
    checkEquals(sollRange.Col2, actRange.Col2, 'Conditional format range mismatch (Col2)');

    // Check rules count
    CheckEquals(1, cf.RulesCount, 'Conditional format rules count mismatch');

    // Check rules class
    CheckEquals(TsCFCellRule, cf.Rules[0].ClassType, 'Conditional format rule class mismatch');

    if cf.Rules[0] is TsCFCellRule then
    begin
      // Check condition
      actCondition := TsCFCellRule(cf.Rules[0]).Condition;
      CheckEquals(
        GetEnumName(TypeInfo(TsCFCondition), integer(ACondition)),
        GetEnumName(typeInfo(TsCFCondition), integer(actCondition)),
        'Conditional format condition mismatch.'
      );

      // Check 1st parameter
      actValue1 := TsCFCellRule(cf.Rules[0]).Operand1;
      if not VarIsEmpty(AValue1) then
      begin
        if VarIsStr(AValue1) then
          CheckEquals(VarToStr(AValue1), VarToStr(actValue1), 'Conditional format parameter 1 mismatch')
        else if VarIsNumeric(AValue1) then
          CheckEquals(Double(AValue1), Double(actValue1), 'Conditional format parameter 1 mismatch')
        else
          raise Exception.Create('Unknown data type in variant');
      end else
        CheckEquals(true, VarIsEmpty(actValue1), 'Omitted parameter 1 detected.');

      // Check 2nd parameter
      actValue2 := TsCFCellRule(cf.Rules[0]).Operand2;
      if not (VarIsEmpty(AValue2) or VarIsNull(AValue2)) then
      begin
        if VarIsStr(AValue2) then
          CheckEquals(VarToStr(AValue2), VarToStr(actValue2), 'Conditional format parameter 2 mismatch')
        else
          CheckEquals(Double(AValue2), Double(actValue2),  'Conditional format parameter 2 mismatch');
      end else
        CheckEquals(true, VarIsEmpty(actValue2), 'Omitted parameter 2 detected.');

      // Check format

      // - Index
      actFmtIdx := TsCFCellRule(cf.Rules[0]).FormatIndex;
      CheckEquals(sollFmtIdx, actFmtIdx, 'Conditional format index mismatch');

      actFmt := workbook.GetCellFormat(actFmtIdx);

      // - formatting fields
      CheckEquals(integer(ACellFormat.UsedFormattingFields), integer(actFmt.UsedFormattingFields), 'Conditional formatting fields mismatch');

      // - background
      if (uffBackground in ACellFormat.UsedFormattingFields) then
      begin
        CheckEquals(ACellFormat.Background.BgColor, actFmt.Background.BgColor, 'Conditional format background color mismatch');
        CheckEquals(ACellFormat.Background.FgColor, actFmt.Background.FgColor, 'Conditional format foreground color mismatch');
        CheckEquals(
          GetEnumName(TypeInfo(TsFillStyle), integer(ACellFormat.Background.Style)),
          GetEnumName(TypeInfo(TsFillStyle), integer(actFmt.Background.Style)),
          'Conditional format style mismatch'
        );
      end;

      // - borders
      if (uffBorder in ACellFormat.UsedFormattingFields) then
      begin
        CheckEquals(integer(ACellFormat.Border), integer(actFmt.Border), 'Conditional format border elements mismatch.');
        CheckEquals(
          GetEnumName(TypeInfo(TsLineStyle), integer(ACellFormat.BorderStyles[cbNorth].LineStyle)),
          GetEnumName(TypeInfo(TsLineStyle), integer(actFmt.BorderStyles[cbNorth].LineStyle)),
          'Conditional format northern border line style mismatch.'
        );
        CheckEquals(
          GetEnumName(TypeInfo(TsLineStyle), integer(ACellFormat.BorderStyles[cbEast].LineStyle)),
          GetEnumName(TypeInfo(TsLineStyle), integer(actFmt.BorderStyles[cbEast].LineStyle)),
          'Conditional format eastern border line style mismatch.'
        );
        CheckEquals(
          GetEnumName(TypeInfo(TsLineStyle), integer(ACellFormat.BorderStyles[cbSouth].LineStyle)),
          GetEnumName(TypeInfo(TsLineStyle), integer(actFmt.BorderStyles[cbSouth].LineStyle)),
          'Conditional format southern border line style mismatch.'
        );
        CheckEquals(
          GetEnumName(TypeInfo(TsLineStyle), integer(ACellFormat.BorderStyles[cbWest].LineStyle)),
          GetEnumName(TypeInfo(TsLineStyle), integer(actFmt.BorderStyles[cbWest].LineStyle)),
          'Conditional format western border line style mismatch.'
        );
        CheckEquals(
          integer(ACellFormat.BorderStyles[cbNorth].Color),
          integer(actFmt.BorderStyles[cbNorth].Color),
          'Conditional format northern border color mismatch.'
        );
        CheckEquals(
          integer(ACellFormat.BorderStyles[cbEast].Color),
          integer(actFmt.BorderStyles[cbEast].Color),
          'Conditional format eastern border color mismatch.'
        );
        CheckEquals(
          integer(ACellFormat.BorderStyles[cbSouth].Color),
          integer(actFmt.BorderStyles[cbSouth].Color),
          'Conditional format southern border color mismatch.'
        );
        CheckEquals(
          integer(ACellFormat.BorderStyles[cbWest].Color),
          integer(actFmt.BorderStyles[cbWest].Color),
          'Conditional format western border color mismatch.'
        );
      end;

      // - fonts  // not working for xlsx
      if (uffFont in ACellFormat.UsedFormattingFields) then
      begin
        if AFileFormat <> sfOOXML then
        begin
        end;
      end;

      // - Number format  // not yet implemented for xlsx
      if (uffNumberFormat in ACEllFormat.UsedFormattingFields) then
      begin
        if AFileFormat <> sfOOXML then
        begin
        end;
      end;
    end;

  finally
    workbook.Free;
    DeleteFile(tempFile);
  end;
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Equal_Const;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcEqual, 5, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_NotEqual_Const;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcNotEqual, 5, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_GreaterThan_Const;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcGreaterThan, 5, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_LessThan_Const;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcLessThan, 5, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_GreaterEqual_Const;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcGreaterEqual, 5, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_LessEqual_Const;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcLessEqual, 5, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Between_Const;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcBetween, 3, 7, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_NotBetween_Const;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcNotBetween, 3, 7, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_AboveAverage;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcAboveAverage, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_BelowAverage;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcBelowAverage, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_AboveEqualAverage;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcAboveEqualAverage, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_BelowEqualAverage;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcBelowEqualAverage, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_AboveAverage_2StdDev;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcAboveAverage, 2.0, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_BelowAverage_2StdDev;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcBelowAverage, 2.0, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Top3;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcTop, 3, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Top10Percent;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcTopPercent, 10, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Bottom3;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcBottom, 3, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Bottom10Percent;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcBottomPercent, 10, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_BeginsWith;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcBeginsWith, 'ab', fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_EndsWith;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcEndsWith, 'kl', fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Contains;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcEndsWith, 'b', fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_NotContains;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcEndsWith, 'b', fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Unique;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcUnique, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Duplicate;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcDuplicate, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_ContainsErrors;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcContainsErrors, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_NotContainsErrors;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackgroundColor(scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcNotContainsErrors, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Background;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBackground(fsHatchDiag, scYellow, scRed);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcEqual, 5, fmt);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_CellFmt_XLSX_Border;
var
  fmt: TsCellFormat;
begin
  InitFormatRecord(fmt);
  fmt.SetBorders([cbNorth, cbEast, cbSouth, cbWest], scBlue, lsDotted);
  TestWriteRead_CF_CellFmt(sfOOXML, cfcEqual, 5, fmt);
end;

{-------------------------------------------------------------------------------
                            Color range tests
--------------------------------------------------------------------------------}
procedure TSpreadWriteReadCFTests.TestWriteRead_CF_ColorRange(
  AFileFormat: TsSpreadsheetFormat; ThreeColors: Boolean; FullSyntax: Boolean);
const
  SHEET_NAME = 'CF';
var
  worksheet: TsWorksheet;
  workbook: TsWorkbook;
  row, col: Cardinal;
  tempFile: string;
  cf: TsConditionalFormat;
  rule: TsCFColorRangeRule;
  sollRange: TsCellRange;
  sollColor1: TsColor = scRed;
  sollColor2: TsColor = scYellow;
  sollColor3: TsColor = scWhite;
  sollValueKind1: TsCFValueKind = vkMin;
  sollValueKind2: TsCFValueKind = vkPercentile;
  sollValueKind3: TsCFValueKind = vkMax;
  sollValue1: Double = 0.0;
  sollValue2: Double = 50.0;
  sollValue3: Double = 0.0;
  actRange: TsCellRange;
begin
  // Write out all test values
  workbook := TsWorkbook.Create;
  try
    workbook.Options := [boAutoCalc];
    workSheet:= workBook.AddWorksheet(SHEET_NAME);

    // Add test cells (numeric)
    row := 0;
    for Col := 0 to 9 do
      worksheet.WriteNumber(row, col, col*10.0);

    // Write conditional formats
    sollRange := Range(0, 0, 0, 9);
    if not FullSyntax then
    begin
      if ThreeColors then
        worksheet.WriteColorrange(sollRange, sollColor1, sollColor2, sollColor3)
      else
        worksheet.WriteColorRange(sollRange, sollColor1, sollColor3);
    end else
    begin
      if ThreeColors then
        worksheet.WriteColorRange(sollRange,
          sollColor1, sollValueKind1, sollValue1,
          sollColor2, sollValueKind2, sollValue2,
          sollColor3, sollValueKind3, sollValue3)
      else
        worksheet.WriteColorRange(sollRange,
          sollColor1, sollValueKind1, sollValue1,
          sollColor3, sollValueKind3, sollValue3);
    end;

    // Save to file
    tempFile := NewTempFile;
    workBook.WriteToFile(tempFile, AFileFormat, true);
  finally
    workbook.Free;
  end;

  // Open the spreadsheet
  workbook := TsWorkbook.Create;
  try
    workbook.ReadFromFile(TempFile, AFileFormat);
    worksheet := GetWorksheetByName(workBook, SHEET_NAME);

    if worksheet=nil then
      fail('Error in test code. Failed to get named worksheet');

    // Check count of conditional formats
    CheckEquals(1, workbook.GetNumConditionalFormats, 'ConditionalFormat count mismatch.');

    // Read conditional format
    cf := Workbook.GetConditionalFormat(0);

    //Check range
    actRange := cf.CellRange;
    CheckEquals(sollRange.Row1, actRange.Row1, 'Conditional format range mismatch (Row1)');
    checkEquals(sollRange.Col1, actRange.Col1, 'Conditional format range mismatch (Col1)');
    CheckEquals(sollRange.Row2, actRange.Row2, 'Conditional format range mismatch (Row2)');
    checkEquals(sollRange.Col2, actRange.Col2, 'Conditional format range mismatch (Col2)');

    // Check rules count
    CheckEquals(1, cf.RulesCount, 'Conditional format rules count mismatch');

    // Check rules class
    CheckEquals(TsCFColorRangeRule, cf.Rules[0].ClassType, 'Conditional format rule class mismatch');

    // Now know that the rule is a TsCFColorRangeRule
    rule := TsCFColorRangeRule(cf.Rules[0]);

    // Check two-color vs three color case
    CheckEquals(ThreeColors, rule.ThreeColors, 'Color range format: three color case mismatch');

    // Start parameters
    CheckEquals(TsColor(sollColor1), TsColor(rule.StartColor), 'Color range format: start color mismatch');
    if FullSyntax then
    begin
      CheckEquals(
        GetEnumName(TypeInfo(TsCFValueKind), integer(sollValueKind1)),
        GetEnumName(TypeInfo(TsCFValueKind), integer(rule.StartValueKind)),
        'Color range format: start value kind mismatch.'
      );
      CheckEquals(sollValue1, rule.StartValue, 'Color range format: start value mismatch');
    end;

    // Center parameters
    if ThreeColors then
    begin
      CheckEquals(TsColor(sollColor2), TsColor(rule.CenterColor), 'Color range format: center color mismatch');
      if FullSyntax then
      begin
        CheckEquals(
          GetEnumName(TypeInfo(TsCFValueKind), integer(sollValueKind2)),
          GetEnumName(TypeInfo(TsCFValueKind), integer(rule.CenterValueKind)),
          'Color range format: center value kind mismatch.'
        );
        CheckEquals(sollValue2, rule.CenterValue, 'Color range format: center value mismatch');
      end;
    end;

    // End parameters
    CheckEquals(TsColor(sollColor3), TsColor(rule.EndColor), 'Color range format: end color mismatch');
    if FullSyntax then
    begin
      CheckEquals(
        GetEnumName(TypeInfo(TsCFValueKind), integer(sollValueKind3)),
        GetEnumName(TypeInfo(TsCFValueKind), integer(rule.EndValueKind)),
        'Color range format: end value kind mismatch.'
      );
      CheckEquals(sollValue3, rule.EndValue, 'Color range format: end value mismatch');
    end;

  finally
    workbook.Free;
    DeleteFile(tempFile);
  end;
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_ColorRange_XLSX_3C_Full;
begin
  TestWriteRead_CF_ColorRange(sfOOXML, true, true);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_ColorRange_XLSX_2C_Full;
begin
  TestWriteRead_CF_ColorRange(sfOOXML, false, true);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_ColorRange_XLSX_3C_Simple;
begin
  TestWriteRead_CF_ColorRange(sfOOXML, true, false);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_ColorRange_XLSX_2C_Simple;
begin
  TestWriteRead_CF_ColorRange(sfOOXML, false, false);
end;


{-------------------------------------------------------------------------------
                             DataBar tests
-------------------------------------------------------------------------------}
procedure TSpreadWriteReadCFTests.TestWriteRead_CF_Databars(
  AFileFormat: TsSpreadsheetFormat; FullSyntax: Boolean);
const
  SHEET_NAME = 'CF';
var
  worksheet: TsWorksheet;
  workbook: TsWorkbook;
  row, col: Cardinal;
  tempFile: string;
  cf: TsConditionalFormat;
  rule: TsCFDataBarRule;
  sollRange: TsCellRange;
  sollColor: TsColor = scRed;
  sollValueKind1: TsCFValueKind = vkMin;
  sollValueKind2: TsCFValueKind = vkMax;
  sollValue1: Double = 0.0;
  sollValue2: Double = 0.0;
  actRange: TsCellRange;
begin
  // Write out all test values
  workbook := TsWorkbook.Create;
  try
    workbook.Options := [boAutoCalc];
    workSheet:= workBook.AddWorksheet(SHEET_NAME);

    // Add test cells (numeric)
    row := 0;
    for Col := 0 to 9 do
      worksheet.WriteNumber(row, col, col*10.0);

    // Write conditional formats
    sollRange := Range(0, 0, 0, 9);
    if FullSyntax then
      worksheet.WriteDataBars(sollRange, sollColor, sollValueKind1, sollValue1, sollValueKind2, sollValue2)
    else
      worksheet.WriteDataBArs(sollRange, sollColor);

    // Save to file
    tempFile := NewTempFile;
    workBook.WriteToFile(tempFile, AFileFormat, true);
  finally
    workbook.Free;
  end;

  // Open the spreadsheet
  workbook := TsWorkbook.Create;
  try
    workbook.ReadFromFile(TempFile, AFileFormat);
    worksheet := GetWorksheetByName(workBook, SHEET_NAME);

    if worksheet=nil then
      fail('Error in test code. Failed to get named worksheet');

    // Check count of conditional formats
    CheckEquals(1, workbook.GetNumConditionalFormats, 'ConditionalFormat count mismatch.');

    // Read conditional format
    cf := Workbook.GetConditionalFormat(0);

    //Check range
    actRange := cf.CellRange;
    CheckEquals(sollRange.Row1, actRange.Row1, 'Conditional format range mismatch (Row1)');
    checkEquals(sollRange.Col1, actRange.Col1, 'Conditional format range mismatch (Col1)');
    CheckEquals(sollRange.Row2, actRange.Row2, 'Conditional format range mismatch (Row2)');
    checkEquals(sollRange.Col2, actRange.Col2, 'Conditional format range mismatch (Col2)');

    // Check rules count
    CheckEquals(1, cf.RulesCount, 'Conditional format rules count mismatch');

    // Check rules class
    CheckEquals(TsCFDataBarRule, cf.Rules[0].ClassType, 'Conditional format rule class mismatch');

    // Now know that the rule is a TsCFDataBarRule
    rule := TsCFDataBarRule(cf.Rules[0]);

    // Color of bars
    CheckEquals(TsColor(sollColor), TsColor(rule.Color), 'Data bar format: bar color mismatch');

    // Parameters
    if FullSyntax then
    begin
      CheckEquals(
        GetEnumName(TypeInfo(TsCFValueKind), integer(sollValueKind1)),
        GetEnumName(TypeInfo(TsCFValueKind), integer(rule.StartValueKind)),
        'Data bar format: start value kind mismatch.'
      );
      if not (sollValueKind1 in [vkMin, vkMax]) then
        CheckEquals(sollValue1, rule.StartValue, 'Data bar format: start value mismatch');

      CheckEquals(
        GetEnumName(TypeInfo(TsCFValueKind), integer(sollValueKind2)),
        GetEnumName(TypeInfo(TsCFValueKind), integer(rule.EndValueKind)),
        'Data bar format: end value kind mismatch.'
      );
      if not (sollValueKind2 in [vkMin, vkMax]) then
        CheckEquals(sollValue2, rule.EndValue, 'Data bar format: end value mismatch');
    end;

  finally
    workbook.Free;
    DeleteFile(tempFile);
  end;
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_Databars_XLSX_Full;
begin
  TestwriteRead_CF_DataBars(sfOOXML, true);
end;

procedure TSpreadWriteReadCFTests.TestWriteRead_CF_Databars_XLSX_Simple;
begin
  TestwriteRead_CF_DataBars(sfOOXML, false);
end;


initialization
  RegisterTest(TSpreadWriteReadCFTests);

end.
