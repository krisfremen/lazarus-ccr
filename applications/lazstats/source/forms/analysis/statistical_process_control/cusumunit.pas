unit CUSUMUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons, PrintersDlgs, Globals, BasicSPCUnit;

type

  { TCUSUMChartForm }

  TCUSUMChartForm = class(TBasicSPCForm)
    AlphaEdit: TEdit;
    hEdit: TEdit;
    BetaEdit: TEdit;
    Bevel3: TBevel;
    kEdit: TEdit;
    TabularGroup: TGroupBox;
    Label1: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Notebook: TNotebook;
    TabularPage: TPage;
    StdDevChk: TCheckBox;
    StdDevEdit: TEdit;
    VMaskPage: TPage;
    rbTabular: TRadioButton;
    rbVMask: TRadioButton;
    VMaskScrollbar: TScrollBar;
    DeltaEdit: TEdit;
    VMaskGroup: TGroupBox;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TargetChk: TCheckBox;
    TargetEdit: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure rbTabularChange(Sender: TObject);
  private
    CUSums, CUSumsUpper, CUSumsLower: DblDyneVec;
    SEMean: Double;
    k, h: Double;
  protected
    procedure Compute; override;
    procedure PlotMeans(ATitle, AXTitle, AYTitle, ADataTitle, AGrandMeanTitle: String;
      const Groups: StrDyneVec; const {%H-}Means: DblDyneVec;
      UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double); override;
    procedure Reset; override;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean; override;
  end;

var
  CUSUMChartForm: TCUSUMChartForm;


implementation

{$R *.lfm}

uses
  Math, TAChartUtils, TATypes, TASeries,
  Utils, MainUnit, ChartFrameUnit, DataProcs;

{ TCUSUMChartForm }

procedure TCUSUMChartForm.Compute;
var
  i, j, grpIndex, numGrps, grpSize, oldGrpSize, numValues: Integer;
  X, Xsq, prevX: Double;
  target, stdDev, diff, grandMean, grandSD, aveSD: Double;
  delta, alpha, beta: double;
  grp: String;
  individuals: Boolean;    // Signals that there is no "Groups" column
  UCL: Double = NaN;
  LCL: Double = NaN;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stdDevs: DblDyneVec = nil;
//  count: Integer; //: IntDyneVec = nil;
  ColNoSelected: IntDyneVec = nil;
  lReport: TStrings;

begin
  if GroupEdit.Text <> '' then
  begin
    SetLength(ColNoSelected, 2);
    ColNoSelected[0] := GrpVar;
    ColNoSelected[1] := MeasVar;
    individuals := false;
    groups := GetGroups;
  end else
  begin
    SetLength(ColNoSelected, 1);
    ColNoSelected[0] := MeasVar;
    individuals := true;
    SetLength(groups, NoCases)
  end;

  numGrps := Length(groups);
  grpSize := 0;
  oldGrpSize := 0;

  SetLength(means, numGrps);
  SetLength(stdDevs, numGrps);
  grandMean := 0.0;
  grandSD := 0.0;

  // Count "good" data points (for grand mean and grand std dev).
  numValues := 0;
  for i := 1 to NoCases do
    if GoodRecord(i, Length(ColNoSelected), ColNoSelected) then inc(numValues);

  // Get group size
  if individuals then
    grpSize := 1
  else
  begin
    for j := 0 to numGrps - 1 do // groups
    begin
      grpSize := 0;
      for i := 1 to NoCases do
      begin
        if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
        grp := Trim(OS3MainFrm.DataGrid.Cells[GrpVar, i]);
        grpIndex := IndexOfString(groups, grp);
        if grpIndex = j then
          inc(grpSize);
      end; // next case

      if j = 0 then
        oldgrpSize := grpSize
      else
        if (oldGrpSize <> grpSize) then
        begin
          ErrorMsg('All groups must have the same size.');
          exit;
        end;
    end; // next group
  end;

  // Calculate group ranges, grand mean, group sd's, SEMeans
  if individuals or (grpSize < 2) then
  begin
    // x-bar chart of individual measurements, no groups
    grpIndex := 0;
    prevX := NaN;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
      X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
      Xsq := X*X;
      groups[grpIndex] := IntToStr(i);
      means[grpIndex] := means[grpIndex] + X;
      if not IsNaN(prevX) then
        stdDevs[grpIndex-1] := abs(X - prevX);  // assume std dev to be moving range;
        // -1 --> skip empty 1st value
      grandMean := grandMean + X;
      grandSD := grandSD + Xsq;
      inc(grpIndex);
      prevX := X;
    end;
    SetLength(stdDevs, numGrps - 1);  // skip empty 1st value
  end else
  begin
    for j := 0 to numGrps - 1 do // groups
    begin
      for i := 1 to NoCases do
      begin
        if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
        grp := Trim(OS3MainFrm.DataGrid.Cells[GrpVar, i]);
        grpIndex := IndexOfString(groups, grp);
        if grpIndex = j then
        begin
          X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
          Xsq := X * X;
          means[grpIndex] := means[grpIndex] + X;
          stdDevs[grpIndex] := stdDevs[grpIndex] + Xsq;
          grandMean := grandMean + X;
          grandSD := grandSD + Xsq;
        end;
      end; // next case

      stdDevs[j] := stdDevs[j] - sqr(means[j]) / grpSize;
      stdDevs[j] := stdDevs[j] / (grpSize - 1);
      stdDevs[j] := sqrt(stdDevs[j]);
      means[j] := means[j] / grpSize;
    end; // next group
  end;

  grandSD := grandSD - sqr(grandMean) / numValues;
  grandSD := sqrt(grandSD / (numValues - 1));  // std dev of all (ungrouped) values
  SEMean := grandSD / sqrt(numValues);         // std error of grand mean
  grandMean := grandMean/numValues;            // grand mean of all observations
  if individuals then
  begin
    aveSD := 0;
    for i := 0 to High(stdDevs) do
      aveSD := aveSD + stdDevs[i];
    aveSD := aveSD / Length(stdDevs) / 1.128;    // 1.128 is the value of d2 fo n = 2.
  end else
    aveSD := grandSD / sqrt(grpSize);

  if TargetChk.Checked then
    target := StrToFloat(TargetEdit.Text)
  else
    target := grandMean; //means[numGrps-1];

  if StdDevChk.Checked then
    stdDev := StrToFloat(StdDevEdit.Text)
  else
    stdDev := aveSD;

  if rbTabular.Checked then
  begin
    k := StrToFloat(kEdit.Text) * stdDev;
    h := StrToFloat(hEdit.Text) * stdDev;
    UCL := h;
    LCL := -h;
  end else
  begin
    if DeltaEdit.Text <> '' then
    begin
      delta := StrToFloat(DeltaEdit.Text) / stdDev;
        // This is in multiples of std deviations

      // see : https://www.itl.nist.gov/div898/handbook/pmc/section3/pmc323.htm
      alpha := StrToFloat(AlphaEdit.Text);
      beta := StrToFloat(BetaEdit.Text);

      k := stdDev * delta  / 2.0;
      h := stdDev / delta * ln((1-beta) / alpha);
    end;
  end;

  // Now get cumulative deviations of means from target
  diff := means[0] - target;
  if rbVMask.Checked then
  begin
    SetLength(CUSums, numGrps);
    FillChar(CUSums[0], numGrps*SizeOf(Double), 0);
    CUSums[0] := diff;
  end;
  if rbTabular.Checked then
  begin
    SetLength(CUSumsUpper, numGrps);
    FillChar(CUSumsUpper[0], numGrps*SizeOf(Double), 0);
    CUSumsUpper[0] := 0; //Max(0, diff);
    SetLength(CUSumsLower, numGrps);
    FillChar(CUSumsLower[0], numGrps*SizeOf(Double), 0);
    CUSumsLower[0] := 0; //Min(0, diff);
  end;
  for j := 1 to numGrps-1 do
  begin
    diff := means[j] - target;
    if rbVMask.Checked then
      CUSums[j] := CUSums[j-1] + diff;
    if rbTabular.Checked then
    begin
      CUSumsUpper[j] := Max(0, diff - k + CUSumsUpper[j-1]);
      CUSumsLower[j] := Min(0, diff + k + CUSumsLower[j-1]);
      // wp: There's a lot of garbage in the internet on these formulas!
    end;
  end;

  // Print results
  lReport := TStringList.Create;
  try
    lReport.Clear;
    lReport.Add    ('CUSUM Chart Results');
    lReport.Add    ('');
    lReport.Add    ('Number of values:          %8d',   [numValues]);
    lReport.Add    ('Number of groups:          %8d',   [numGrps]);
    lReport.Add    ('Group size:                %8d',   [grpSize]);
    lReport.Add    ('');
    lReport.Add    ('Mean of all observations:  %8.3f', [grandMean]);
    lReport.Add    ('Std. Dev. of observations: %8.3f', [grandSD]);
    lReport.Add    ('Standard error of Mean:    %8.3f', [SEMean]);
    lReport.Add    ('Target specification:      %8.3f', [target]);
    lReport.Add    ('Average group std dev:     %8.3f', [aveSD]);

    if rbTabular.Checked then
    begin
      lReport.Add  ('UCL:                       %8.3f', [h]);
      lReport.Add  ('LCL:                       %8.3f', [-h]);
      lReport.Add  ('');
      lReport.Add  ('Tabular CUSUM parameters:');
      lReport.Add  ('  k:                       %8.3f (%s sigma)', [k, kEdit.Text]);
      lReport.Add  ('  h:                       %8.3f (%s sigma)', [h, hEdit.Text]);
      lReport.Add  ('');

      lReport.Add  ('Group  Size    Mean    Mean Dev      Cum. Deviation   ' );
      lReport.Add  ('                                    Upper      Lower  ');
      lReport.Add  ('-----  ----  --------  --------  ---------------------');
      for i := 0 to numGrps - 1 do
      begin
        lReport.Add('%5s  %4d  %8.3f  %8.3f  %9.3f  %9.3f', [
          groups[i], grpSize, means[i], means[i]-target, CUSumsUpper[i], CUSumsLower[i]
        ]);
      end;
    end;

    if rbVMask.Checked then
    begin
      if DeltaEdit.Text <> '' then
      begin
        lReport.Add    ('');
        lReport.Add('V-Mask parameters:');
        lReport.Add('  Alpha (Type I error)     %8.3f', [alpha]);
        lReport.Add('  Beta (Type II error)     %8.3f', [beta]);
        lReport.Add('  k:                       %8.3f (%.2f sigma)', [k, k/SEMean]);
        lReport.Add('  h:                       %8.3f (%.2f sigma)', [h, h/SEMean]);
      end;
      lReport.Add  ('');
      lReport.Add  ('Group  Size    Mean    Mean Dev    Cum.Dev. of'   );
      lReport.Add  ('                                 Mean from Target');
      lReport.Add  ('-----  ----  --------  --------  ----------------');
      for i := 0 to numGrps - 1 do
      begin
        lReport.Add('%5s  %4d  %8.3f  %8.3f  %10.3f', [
          groups[i], grpSize, means[i], means[i]-target, cusums[i]
        ]);
      end;
    end;

    FReportFrame.DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // Show graph
  VMaskScrollbar.Max := numGrps;
  PlotMeans(
    Format('Cumulative Sum Chart for "%s"', [GetFileName]),  // chart title
    GroupEdit.Text,                                          // x title
    'CUSUM of ' + MeasEdit.Text + ' differences',            // y title
    'Data',                                                  // series title
    'Mean',                                                  // mean label at right
    groups, nil,    // y values will be applied in overridden method
    UCL, LCL, NaN,
    NaN, NaN, NaN
  );
end;


procedure TCUSUMChartForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  DisableAutoSizing;
  try
//    VMaskGroup.Anchors := VMaskGroup.Anchors - [akRight];
    VarList.Constraints.MinWidth := VarListLabel.Width;
    SpecsPanel.Constraints.MinWidth := Max(
      CloseBtn.Left + CloseBtn.Width - HelpBtn.Left + HelpBtn.BorderSpacing.Around,
      GroupBox2.Width * 2 + VarList.BorderSpacing.Right + VarList.BorderSpacing.Left
    );
    TabularGroup.Constraints.MinHeight := VMaskScrollbar.Top + VMaskScrollbar.Height +
      VMaskScrollbar.BorderSpacing.Bottom + TabularGroup.Height - TabularGroup.ClientHeight;
    Notebook.Constraints.MinHeight := TabularGroup.Constraints.MinHeight;
    Notebook.Height := 1;   // Enforce notebook autosizing
    Constraints.MinHeight := Notebook.Top + Notebook.Height + Notebook.BorderSpacing.Bottom + ButtonPanel.Height;
    if Height < Constraints.MinHeight then
      Height := 1; // enforce height autosizing
  //  VMaskGroup.Anchors := VMaskGroup.Anchors + [akRight];
  finally
    EnableAutoSizing;
  end;
end;


procedure TCUSUMChartForm.rbTabularChange(Sender: TObject);
begin
  if (Sender = rbTabular) and rbTabular.Checked then
    Notebook.PageIndex := 0
  else
  if (Sender = rbVMask) and rbVMask.Checked then
    Notebook.PageIndex := 1;
end;


{ Overridden to draw the V-Mark }
procedure TCUSUMChartForm.PlotMeans(ATitle, AXTitle, AYTitle, ADataTitle, AGrandMeanTitle: String;
  const Groups: StrDyneVec; const Means: DblDyneVec;
  UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double);
var
  ser: TLineSeries;
  xVM, yVM, x1, y1, x2, y2, x3, y3, x4, y4: Double;
begin
  // Tabular CUSUM Chart: Plot the lower CUSums in addition to the upper CUSums.
  if rbTabular.Checked then
  begin
    inherited PlotMeans(ATitle, AXTitle, AYTitle, 'Upper CUSums', AGrandMeanTitle,
      Groups, CUSumsUpper, UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec);

    ser := TLineSeries(FChartFrame.PlotXY(ptLinesAndSymbols, nil, CUSUMsLower, Groups, nil, 'Lower CUSums', clBlack));
//    ser.Pointer.Style := psDiamond;
    ser.Pointer.Brush.Color := clWhite;
  end;

  // CUSUM Chart with V-Mask
  if rbVMask.Checked then begin
    inherited PlotMeans(ATitle, AXTitle, AYTitle, ADataTitle, AGrandMeanTitle,
      Groups, CUSums, NaN, NaN, GrandMean, TargetSpec, LowerSpec, UpperSpec);

    if (DeltaEdit.Text = '') then
      exit;

    ser := TLineSeries.Create(FChartFrame.Chart);
    FChartFrame.Chart.AddSeries(ser);
    ser.SeriesColor := clBlue;
    ser.Title := 'V-Mask';

    // Position of V mask point
    xVM := VMaskScrollbar.Position;
    yVM := CUSums[VMaskScrollbar.Position-1];

    // Upper part of V mask
    x2 := xVM;
    y2 := yVM + h;
    x1 := 1;              // x values begin with 1
    y1 := y2 - k*(x1 - x2);

    // Lower part of V mask
    x3 := xVM;
    y3 := yVM - h;
    x4 := 1;
    y4 := y3 + k*(x4 - x3);

    ser.AddXY(x1, y1);
    ser.AddXY(x2, y2);
//    ser.AddXY(x2, NaN);  // Do not draw the vertical line
    ser.AddXY(x3, y3);
    ser.AddXY(x4, y4);
  end;
end;


procedure TCUSUMChartForm.Reset;
begin
  inherited;
  TargetEdit.Clear;
  StdDevEdit.Clear;
  DeltaEdit.Clear;
  kEdit.Text := FormatFloat('0.0', 0.5);
  hEdit.Text := '4';
  AlphaEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  BetaEdit.Text := FormatFloat('0.00', DEFAULT_BETA_LEVEL);
  VMaskScrollbar.Min := 2;
  VMaskScrollbar.Max := 1000;
  VMaskScrollbar.Position := VMaskScrollbar.Max;
end;


function TCUSUMChartForm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
begin
  Result := inherited;
  if (not Result) then
  begin
    // This particular chart will handle individual data if GroupEdit is empty.
    if  GroupEdit.Visible and (GroupEdit.Text = '') then
      Result := true
    else
      exit;
  end;

  Result := false;

  if TargetChk.Checked then
  begin
    if (TargetEdit.Text = '') then
    begin
      AMsg := 'Target not specified.';
      AControl := TargetEdit;
      exit;
    end;
    if not TryStrToFloat(TargetEdit.Text, x) then
    begin
      AMsg := 'No valid number given for target specification.';
      AControl := TargetEdit;
      exit;
    end;
  end;

  if StdDevChk.Checked then
  begin
    if (StdDevEdit.Text = '') then
    begin
      AMsg := 'Standard deviation expected, but not specified.';
      AControl := StdDevEdit;
      exit;
    end;
    if not TryStrToFloat(StdDevEdit.Text, x) then
    begin
      AMsg := 'No valid number given for standard deviation.';
      AControl := StdDevEdit;
      exit;
    end;
  end;

  if rbVMask.Checked and (DeltaEdit.Text <> '') then
  begin
    if not TryStrToFloat(DeltaEdit.Text, x) then
    begin
      AMsg := 'No valid number given for Delta.';
      AControl := DeltaEdit;
      exit;
    end;

    if (AlphaEdit.Text = '') then
    begin
      AMsg := 'Alpha not specified.';
      AControl := AlphaEdit;
      exit;
    end;
    if not TryStrToFloat(AlphaEdit.Text, x) then
    begin
      AMsg := 'No valid number given for Alpha.';
      AControl := AlphaEdit;
      exit;
    end;

    if (BetaEdit.Text = '') then
    begin
      AMsg := 'Beta not specified.';
      AControl := BetaEdit;
      exit;
    end;
    if not TryStrToFloat(BetaEdit.Text, x) then
    begin
      AMsg := 'No valid number given for Beta.';
      AControl := BetaEdit;
      exit;
    end;
  end;

  if rbTabular.Checked then
  begin
    if (kEdit.Text = '') then
    begin
      AMsg := 'k not specified.';
      AControl := kEdit;
      exit;
    end;
    if not TryStrToFloat(kEdit.Text, x) then
    begin
      AMsg := 'No valid number given for k.';
      AControl := kEdit;
      exit;
    end;

    if (hEdit.Text = '') then
    begin
      AMsg := 'h not specified.';
      AControl := hEdit;
      exit;
    end;
    if not TryStrToFloat(hEdit.Text, x) then
    begin
      AMsg := 'No valid number given for h.';
      AControl := hEdit;
      exit;
    end;
  end;

  Result := true;
end;

end.

