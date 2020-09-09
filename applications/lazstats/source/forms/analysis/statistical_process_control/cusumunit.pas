unit CUSUMUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Globals, BasicSPCUnit;

type

  { TCUSUMChartForm }

  TCUSUMChartForm = class(TBasicSPCForm)
    AlphaEdit: TEdit;
    BetaEdit: TEdit;
    Label1: TLabel;
    VMaskScrollbar: TScrollBar;
    ShowMeanDevChk: TCheckBox;
    DeltaEdit: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TargetChk: TCheckBox;
    TargetEdit: TEdit;
    procedure FormActivate(Sender: TObject);
  private
    SEMean: Double;
    k, h: Double;
  protected
    procedure Compute; override;
    procedure PlotMeans(ATitle, AXTitle, AYTitle, ADataTitle, AGrandMeanTitle: String;
      const Groups: StrDyneVec; const Means: DblDyneVec;
      UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double); override;
    procedure Reset; override;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean; override;
  end;

var
  CUSUMChartForm: TCUSUMChartForm;


implementation

{$R *.lfm}

uses
  Math, TAChartUtils, TASeries,
  Utils, MainUnit, DataProcs;

{ TCUSUMChartForm }

procedure TCUSUMChartForm.Compute;
var
  i, j, grpIndex, numGrps, grpSize, oldGrpSize, numValues: Integer;
  X, Xsq, Xmin, Xmax, target, diff, grandMean, grandSum, grandSD: Double;
  deltaSD, alpha, beta: double;
  sizeError: Boolean;
  grp: String;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stdDev: DblDyneVec = nil;
  cuSums: DblDyneVec = nil;
  count: IntDyneVec = nil;
  ColNoSelected: IntDyneVec = nil;
  lReport: TStrings;

begin
  SetLength(ColNoSelected, 2);
  ColNoSelected[0] := GrpVar;
  ColNoSelected[1] := MeasVar;

  groups := GetGroups();
  numGrps := Length(groups);
  grpSize := 0;
  oldGrpSize := 0;

  SetLength(means, numGrps);
  SetLength(count, numGrps);
  SetLength(stdDev, numGrps);
  SetLength(cuSums, numGrps);
  SEMean := 0.0;
  grandMean := 0.0;
  grandSum := 0.0;
  sizeError := false;

  // Count "good" data points
  numValues := 0;
  for i := 1 to NoCases do
    if GoodRecord(i, Length(ColNoSelected), ColNoSelected) then inc(numValues);

  // calculate group ranges, grand mean, group sd's, semeans
  for j := 0 to numGrps - 1 do // groups
  begin
    Xmin := Infinity;
    Xmax := -Infinity;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
      grp := Trim(OS3MainFrm.DataGrid.Cells[GrpVar, i]);
      grpIndex := IndexOfString(groups, grp);
      if grpIndex = j then
      begin
        X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
        Xsq := X * X;
        if X > Xmax then Xmax := X;
        if X < Xmin then Xmin := X;
        inc(count[grpIndex]);
        means[grpIndex] := means[grpIndex] + X;
        stddev[grpIndex] := stddev[grpIndex] + Xsq;
        SEMean := SEMean + Xsq;
        grandMean := grandMean + X;
      end;
    end; // next case

    grpSize := count[j];
    if j = 0 then oldgrpSize := grpSize;
    if (oldGrpsize <> grpSize) or (grpSize < 2) then
    begin
      sizeError := true;
      break;
    end;

    stdDev[j] := stddev[j] - sqr(means[j]) / grpSize;
    stddev[j] := stddev[j] / (grpSize - 1);
    stddev[j] := sqrt(stddev[j]);
    means[j] := means[j] / grpSize;
  end; // next group

  if (grpSize < 2) or (grpSize > 25) or sizeError then
  begin
    ErrorMsg('Group size error.');
    exit;
  end;

  // now get cumulative deviations of means from target
  if TargetChk.Checked then
    target := StrToFloat(TargetEdit.Text)
  else
    target := means[numGrps-1];
  cusums[0] := means[0] - target;
  grandSum := grandSum + (means[0] - target);
  for j := 1 to numGrps-1 do
  begin
    diff := means[j] - target;
    cusums[j] := cusums[j-1] + diff;
    grandSum := grandSum + diff;
  end;

  SEMean := SEMean - sqr(grandMean)/numValues;
  SEMean := sqrt(SEMean/(numValues - 1));
  grandSD := SEMean;
  SEMean := SEMean/sqrt(numValues);
  grandMean := grandMean/numValues; // mean of all observations
  grandSum := grandSum/numGrps;     // mean of the group means

  if DeltaEdit.Text <> '' then
  begin
    deltaSD := StrToFloat(DeltaEdit.Text) / SEMean;
      // This is in multiples of std deviations

    // see : https://www.itl.nist.gov/div898/handbook/pmc/section3/pmc323.htm
    alpha := StrToFloat(AlphaEdit.Text);
    beta := StrToFloat(BetaEdit.Text);
    k := deltaSD * SEMean / 2.0;
    h := SEMean / deltaSD * ln((1 - beta) / alpha);
  end;

  // Print results
  lReport := TStringList.Create;
  try
    lReport.Clear;
    lReport.Add('CUSUM Chart Results');
    lReport.Add('');
    lReport.Add('Mean of group deviations:  %8.3f', [grandSum]);
    lReport.Add('Mean of all observations:  %8.3f', [grandMean]);
    lReport.Add('Std. Dev. of Observations: %8.3f', [grandSD]);
    lReport.Add('Standard Error of Mean:    %8.3f', [SEMean]);
    lReport.Add('Target Specification:      %8.3f', [target]);

    lReport.Add('');
    lReport.Add('Differences in data units');
    lReport.Add('');

    lReport.Add('Group  Size    Mean    Std.Dev.  Mean-Dev  Cum.Dev. of'   );
    lReport.Add('                                           Mean from Target');
    lReport.Add('-----  ----  --------  --------  --------  ----------------');
    for i := 0 to numGrps - 1 do
    begin
      lReport.Add('%5s  %4d  %8.3f  %8.3f  %8.3f  %10.3f', [
        groups[i], count[i], means[i], stddev[i], means[i]-target, cusums[i]
      ]);
    end;

    if DeltaEdit.Text <> '' then
    begin
      lReport.Add('');
      lReport.Add('V-Mask parameters:');
      lReport.Add('  Alpha (Type I error)     %8.3f', [alpha]);
      lReport.Add('  Beta (Type II error)     %8.3f', [beta]);
      lReport.Add('  k:                       %8.3f (%.2f sigma)', [k, k/SEMean]);
      lReport.Add('  h:                       %8.3f (%.2f sigma)', [h, h/SEMean]);
    end;

    ReportMemo.Lines.Assign(lReport);
  finally
    lReport.Free;
  end;

  // Show graph
  VMaskScrollbar.Max := numGrps;
  if not ShowMeanDevChk.Checked then
    grandSum := NaN;
  PlotMeans(
    Format('Cumulative Sum Chart for "%s"', [GetFileName]),  // chart title
    GroupEdit.Text,                                          // x title
    'CUSUM of ' + MeasEdit.Text + ' differences',            // y title
    'Data',                                                  // series title
    'Mean',                                                  // mean label at right
    groups, cuSums,
    NaN, NaN, grandSum,
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
    GroupBox2.Anchors := GroupBox2.Anchors - [akRight];
    VarList.Constraints.MinWidth := VarListLabel.Width;
    SpecsPanel.Constraints.MinWidth := Max(
      CloseBtn.Left + CloseBtn.Width - HelpBtn.Left + HelpBtn.BorderSpacing.Around,
      GroupBox2.Width * 2 + VarList.BorderSpacing.Right + VarList.BorderSpacing.Left
    );
    Constraints.MinHeight := GroupBox2.Top + GroupBox2.Height + GroupBox2.BorderSpacing.Bottom + ButtonPanel.Height;
    GroupBox2.Anchors := GroupBox2.Anchors + [akRight];
  finally
    EnableAutoSizing;
  end;
end;

{ Overridden to draw the V-Mark }
procedure TCUSUMChartForm.PlotMeans(ATitle, AXTitle, AYTitle, ADataTitle, AGrandMeanTitle: String;
  const Groups: StrDyneVec; const Means: DblDyneVec;
  UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double);
var
  ser: TLineSeries;
  xVM, yVM, x1, y1, x2, y2, x3, y3, x4, y4: Double;
begin
  inherited;
  if DeltaEdit.Text = '' then
    exit;

  ser := TLineSeries.Create(FChartFrame.Chart);
  FChartFrame.Chart.AddSeries(ser);
  ser.SeriesColor := clBlue;
  ser.Title := 'V-Mask';

  // Position of V mask point
  xVM := VMaskScrollbar.Position;
  yVM := Means[VMaskScrollbar.Position-1];

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
  ser.AddXY(x2, NaN);  // Do not draw the vertical line
  ser.AddXY(x3, y3);
  ser.AddXY(x4, y4);
end;


procedure TCUSUMChartForm.Reset;
begin
  inherited;
  ShowMeanDevChk.Checked := false;
  TargetEdit.Clear;
  DeltaEdit.Clear;
  AlphaEdit.Text := FormatFloat('0.00000', 0.0027); //DEFAULT_ALPHA_LEVEL);
  BetaEdit.Text := FormatFloat('0.00000', 0.01); //DEFAULT_BETA_LEVEL);
  VMaskScrollbar.Min := 2;
  VMaskScrollbar.Max := 1000;
  VMaskScrollbar.Position := VMaskScrollbar.Max;
end;


function TCUSUMChartForm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
  n: Integer;
begin
  Result := inherited;
  if not Result then
    exit;

  Result := false;

  if (DeltaEdit.Text <> '') then
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

  Result := true;
end;

end.

