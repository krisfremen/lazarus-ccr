unit CUMSUMUnit;

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
  X, Xsq, Xmin, Xmax, target, grandMean, grandSum, grandSD, UCL, LCL: Double;
  sizeError: Boolean;
  grp: String;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stdDev: DblDyneVec = nil;
  cumSums: DblDyneVec = nil;
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
  SetLength(cumSums, numGrps);
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
  cumsums[0] := means[0] - target;
  grandSum := grandSum + (means[0] - target);
  for j := 1 to numGrps-1 do
  begin
    cumsums[j] := cumsums[j-1] + (means[j] - target);
    grandSum := grandSum + (means[j] - target);
  end;

  SEMean := SEMean - sqr(grandMean)/numValues;
  SEMean := sqrt(SEMean/(numValues - 1));
  grandSD := SEMean;
  SEMean := SEMean/sqrt(numValues);
  grandMean := grandMean/numValues; // mean of all observations
  grandSum := grandSum/numGrps;     // mean of the group means
  UCL := grandMean + 3.0*SEMean;
  LCL := grandMean - 3.0*SEMean;
  if (LCL < 0.0) then LCL := 0.0;

  // Print results
  lReport := TStringList.Create;
  try
    lReport.Clear;
    lReport.Add('CUMSUM Chart Results');
    lReport.Add('');
    lReport.Add(' Group   Size    Mean    Std.Dev.    Cum.Dev. of'   );
    lReport.Add('                                   Mean from Target');
    lReport.Add('-------  ----  --------  --------  ----------------');
    for i := 0 to numGrps - 1 do
      lReport.Add('%7d  %4d  %8.2f  %8.2f  %16.2f', [i+1, count[i], means[i], stddev[i], cumsums[i]]);
    lReport.Add('');
    lReport.Add('Mean of group deviations:  %8.3f', [grandSum]);
    lReport.Add('Mean of all observations:  %8.3f', [grandMean]);
    lReport.Add('Std. Dev. of Observations: %8.3f', [grandSD]);
    lReport.Add('Standard Error of Mean:    %8.3f', [SEMean]);
    lReport.Add('Target Specification:      %8.3f', [target]);
    lReport.Add('Lower Control Limit:       %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:       %8.3f', [UCL]);

    ReportMemo.Lines.Assign(lReport);
  finally
    lReport.Free;
  end;

  // Show graph
  PlotMeans(
    Format('Cumulative Sum Chart for "%s"', [GetFileName]),  // chart title
    GroupEdit.Text,                                          // x title
    'CUSUM of ' + MeasEdit.Text,                             // y title
    'Data',                                                  // series title
    'Mean deviation',                                        // mean label at right
    groups, cumSums,
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
  alpha, beta, delta, deltaSD, gamma, d, h, k: Double;
  ser: TLineSeries;
  ext: TDoubleRect;
  x0, y0, x1, y1, x2, y2, x3, y3: Double;
begin
  inherited;
  if DeltaEdit.Text = '' then
    exit;

  alpha := StrToFloat(AlphaEdit.Text);
  beta := StrToFloat(BetaEdit.Text);
  delta := StrToFloat(DeltaEdit.Text);  // This is in data units
  deltaSD := delta / SEMean;     // This is in multiples of std deviations

  // see : https://www.itl.nist.gov/div898/handbook/pmc/section3/pmc323.htm
  d := 2.0 / sqr(deltaSD) * ln((1.0 - beta)/alpha);
  k := deltaSD * SEMean / 2.0;
  h := d * k;

  ser := TLineSeries.Create(FChartFrame.Chart);
  FChartFrame.Chart.AddSeries(ser);
  ser.SeriesColor := clBlue;
  ser.Title := 'V-Mask';

  ext := FChartFrame.Chart.GetFullExtent;
  x1 := Length(Means);         // 1-based!
  y1 := Means[High(Means)] + h;
  x0 := 1;
  y0 := y1 - k*(x0 - x1);

  x2 := x1;
  y2 := Means[High(Means)] - h;
  x3 := x0;
  y3 := y2 + k*(x3 - x2);

  ser.AddXY(x0, y0);
  ser.AddXY(x1, y1);
  ser.AddXY(x2, y2);
  ser.AddXY(x3, y3);
end;


procedure TCUSUMChartForm.Reset;
begin
  inherited;
  DeltaEdit.Clear;
  AlphaEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  BetaEdit.Text := FormatFloat('0.00', DEFAULT_BETA_LEVEL);
  TargetEdit.Clear;
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

