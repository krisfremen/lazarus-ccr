{ This unit was checked against the commercial statistical package JMP and
  creates correct results.

  Data file for testing: "boltsize.laz"
  Group variable:         LotNo
  Selected variable:      BoltLngth

  The original LazStats help files suggest
    Upper Spec Level      20.05
    Lower Spec Level      19.95
    Target Spec           20.00
  but this would indicate a very poor process. Better values:
    Upper Spec Level      21.00
    Lower Spec Level      19.00
    Target Spec           20.00
}

unit XBarChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, Buttons, PrintersDlgs,
  Globals, BasicSPCUnit;

type

  { TXBarChartForm }

  TXBarChartForm = class(TBasicSPCForm)
    ZonesChk: TCheckBox;
    LevelOptns: TGroupBox;
    LowerSpecChk: TCheckBox;
    LowerSpecEdit: TEdit;
    SigmaOpts: TRadioGroup;
    TargetChk: TCheckBox;
    TargetSpecEdit: TEdit;
    UpperSpecChk: TCheckBox;
    UpperSpecEdit: TEdit;
    XSigmaEdit: TEdit;
    procedure FormActivate(Sender: TObject);
  private
    FAveStdDev: Double;
  protected
    procedure Compute; override;
    procedure PlotMeans(ATitle, AXTitle, AYTitle, ADataTitle, AGrandMeanTitle: String;
      const Groups: StrDyneVec; const Means: DblDyneVec;
      UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double); override;
    procedure Reset; override;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean; override;
  end;

var
  XBarChartForm: TXBarChartForm;


implementation

uses
  Math,
  Utils, MathUnit, MainUnit, DataProcs;

{$R *.lfm}

procedure TXBarChartForm.FormActivate(Sender: TObject);
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
    LevelOptns.AnchorSideRight.Control := nil;
    VarList.Constraints.MinWidth := VarListLabel.Width;
    SpecsPanel.Constraints.MinWidth := Max(
      CloseBtn.Left + CloseBtn.Width - HelpBtn.Left + HelpBtn.BorderSpacing.Around,
      LevelOptns.Width * 2 + VarList.BorderSpacing.Right //* 2 + MeasInBtn.Width
    );
    Constraints.MinHeight := LevelOptns.Top + LevelOptns.Height + LevelOptns.BorderSpacing.Bottom + ButtonPanel.Height;

    LevelOptns.AnchorSideRight.Control := MeasEdit;
    LevelOptns.AnchorSideRight.Side := asrBottom;

    if Height < Constraints.MinHeight then
      Height := 1; // enforce height autosizing
  finally
    EnableAutoSizing;
  end;
end;


procedure TXBarChartForm.Compute;
var
  i, j: Integer;
  upperSpec: Double = NaN;
  lowerSpec: Double = NaN;
  targetSpec: Double = NaN;
  Cp: Double = NaN;
  Cpk: Double = NaN;
  Cpm: Double = NaN;
  Cpu: Double = NaN;
  Cpl: Double = NaN;
  ColNoSelected: IntDyneVec = nil;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stdDev: DblDyneVec = nil;
  count: IntDyneVec = nil;
  numValues, numGrps, grpIndex, grpSize: Integer;
  grp: String;
  X, Xsq, prevX: Double;
  sigma, UCL, LCL, grandMean, grandSD, SEMean: Double;
  //C4Value: Double;
  individualsChart: Boolean;
  lReport: TStrings;
begin
  if GroupEdit.Text <> '' then
  begin
    SetLength(ColNoSelected, 2);
    ColNoSelected[0] := GrpVar;
    ColNoSelected[1] := MeasVar;
    individualsChart := false;
  end else
  begin
    SetLength(ColNoSelected, 1);
    ColNoSelected[0] := MeasVar;
    individualsChart := true;
  end;

  if UpperSpecChk.Checked and (UpperSpecEdit.Text <> '') then
    upperSpec := StrToFloat(UpperSpecEdit.Text);
  if LowerSpecChk.Checked and (LowerSpecEdit.Text <> '') then
    lowerSpec := StrToFloat(LowerSpecEdit.Text);
  if TargetChk.Checked and (TargetSpecEdit.Text <> '') then
    targetSpec := StrToFloat(TargetSpecEdit.Text);

  case SigmaOpts.ItemIndex of
    0: sigma := 3.0;
    1: sigma := 2.0;
    2: sigma := 1.0;
    3: sigma := StrToFloat(XSigmaEdit.Text);
    else raise Exception.Create('Sigma case not handled.');
  end;

  if individualsChart then
    SetLength(groups, NoCases)
  else
    groups := GetGroups;
  numGrps := Length(groups);

  SetLength(means, numGrps);
  SetLength(stddev, numGrps);
  grandMean := 0.0;
  grandSD := 0.0;
  numValues := 0;

  // calculate group means, grand mean, group std devs, seMean
  if IndividualsChart then
  begin
    // x-bar chart of individual measurements, no groups
    SetLength(count, 0);    // not needed, count is always 1
    prevX := NaN;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
      grpIndex := numValues;  // is counted up in this loop
      X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
      Xsq := X*X;
      groups[grpIndex] := IntToStr(i);
      means[grpIndex] := means[grpIndex] + X;
      if not IsNaN(prevX) then
        stddev[grpIndex-1] := abs(X - prevX);  // assume std dev to be moving range;
        // -1 --> skip empty 1st value
      grandMean := grandMean + X;
      grandSD := grandSD + Xsq;
      inc(numValues);
      prevX := X;
    end;
  end else
  begin
    // grouped x-bar chart
    SetLength(count, numGrps);
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
      grp := Trim(OS3MainFrm.DataGrid.Cells[GrpVar, i]);
      grpIndex := IndexOfString(groups, grp);
      X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
      Xsq := X*X;
      inc(count[grpIndex]);
      means[grpIndex] := means[grpIndex] + X;
      stddev[grpIndex] := stddev[grpIndex] + Xsq;
      grandMean := grandMean + X;
      grandSD := grandSD + Xsq;
      inc(numValues);
    end;
  end;

  grandSD := grandSD - sqr(grandMean) / numValues;
  grandSD := sqrt(grandSD / (numValues - 1));
  SEMean := grandSD / sqrt(numValues);
  grandMean := grandMean / numValues;

  if individualsChart then
  begin
    // Individuals chart
    grpSize := 1;
    SetLength(means, numValues);
    Setlength(count, numValues);
    SetLength(stddev, numValues-1);  // -1 for the missing 1st value
    FAveStdDev := 0;
    for i := 0 to High(stddev) do
      FAveStdDev := FAveStdDev + stdDev[i];
    FAveStdDev := FAveStdDev / Length(stddev) / 1.128;    // 1.128 is the value of d2 fo n = 2.
    UCL := grandMean + sigma * FAveStdDev;
    LCL := grandMean - sigma * FAveStdDev;
  end else
  begin
    // Grouped chart

    // Check group size first; it is assumed that all groups are equally sized
    grpSize := count[0];
    for i := 1 to numGrps-1 do
      if count[i] <> grpSize then
      begin
        ErrorMsg('All groups must have the same size.');
        exit;
      end;

    SetLength(means, numGrps);
    Setlength(count, numGrps);
    SetLength(stddev, numGrps);
    FAveStdDev := 0;
    for i := 0 to numGrps-1 do
    begin
      if count[i] = 0 then
      begin
        means[i] := NaN;
        stddev[i] := NaN;
      end else
      begin
        if count[i] = 1 then
          stddev[i] := NaN
        else
        begin
          stddev[i] := stddev[i] - sqr(means[i]) / count[i];
          stddev[i] := stddev[i] / (count[i] - 1);   // Variance of group i
          FAveStdDev := FAveStdDev + stdDev[i];      // Sum of variances
          stddev[i] := sqrt(stddev[i]);              // StdDev of group i
        end;
        means[i] := means[i] / count[i];
      end;
    end;
//    C4Value := CalcC4(grpSize);
    FAveStdDev := sqrt(FAveStdDev / (numGrps * grpSize)); // / C4Value;
    UCL := grandMean + sigma * FAveStdDev;
    LCL := grandMean - sigma * FAveStdDev;

    //UCL := grandMean + sigma * grandSD / sqrt(grpSize);  // this works, too, a bit more off of JMP than the above...
    //LCL := grandMean - sigma * grandSD / sqrt(grpSize);

//    UCL := grandMean + sigma * SEMean;    // old LazStats calculation -- does not agree with JMP software.
//    LCL := grandMean - sigma * SEMean;
  end;

  if not IsNaN(upperSpec) and not IsNaN(lowerSpec) then
  begin
    Cp  := (upperSpec - lowerSpec) / (6 * FAveStdDev);
    Cpu := (UpperSpec - grandMean) / (3 * FAveStdDev);
    Cpl := (grandMean - LowerSpec) / (3 * FAveStdDev);
    Cpk := Min(Cpu, Cpl);
    if not IsNaN(targetSpec) then
      Cpm := (upperSpec - lowerSpec) / (6 * sqrt(sqr(FAveStdDev) + sqr(grandMean - targetSpec)));
  end;

    // Print results
  lReport := TStringList.Create;
  try
    lReport.Add('X BAR CHART RESULTS');
    lReport.Add('');
    lReport.Add('Number of values:        %8d',   [numValues]);
    lReport.Add('Number of groups:        %8d',   [numGrps]);
    lReport.Add('Group size:              %8d',   [grpSize]);
    lReport.Add('');
    lReport.Add('Grand Mean:              %8.3f', [grandMean]);
    lReport.Add('Standard Error of Mean:  %8.3f', [SEMean]);
    lReport.Add('Grand Std Deviation:     %8.3f', [grandSD]);
    lReport.Add('Average Group Std Dev:   %8.3f', [FAveStdDev]);
    lReport.Add('Upper Control Limit:     %8.3f', [UCL]);
    lReport.Add('Lower Control Limit:     %8.3f', [LCL]);
    lReport.Add('');
    if not IsNaN(targetSpec) then
      lReport.Add('Target:                  %8.3f', [targetSpec]);
    if not IsNaN(upperSpec) then
      lReport.Add('Upper Spec Limit:        %8.3f', [upperSpec]);
    if not IsNaN(lowerSpec) then
      lReport.Add('Lower Spec Limit:        %8.3f', [lowerSpec]);
    if not IsNaN(Cp) then
      lReport.Add('Cp:                      %8.3f', [Cp]);
    if not IsNaN(Cpk) then
      lReport.Add('Cpk:                     %8.3f', [Cpk]);
    if not IsNaN(Cpu) then
      lReport.Add('Cpu:                     %8.3f', [Cpu]);
    if not IsNaN(Cpl) then
      lReport.Add('Cpl:                     %8.3f', [Cpl]);
    if not IsNaN(Cpm) then
      lReport.Add('Cpm:                     %8.3f', [Cpm]);
    lReport.Add('');
    lReport.Add(' Group   Size    Mean    Std.Dev.');
    lReport.Add('-------  ----  --------  --------');
    if individualsChart then
    begin
      lReport.Add  ('%7s  %4d  %8.2f', [groups[i], count[i], means[i]]);
      for i := 1 to numGrps-1 do
        lReport.Add('%7s  %4d  %8.2f  %8.2f', [groups[i], count[i], means[i], stddev[i-1]]);
    end else
      for i := 0 to numGrps-1 do
        lReport.Add('%7s  %4d  %8.2f  %8.2f', [groups[i], count[i], means[i], stddev[i]]);

    FReportFrame.DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // Show graph
  PlotMeans(
    Format('x&#772; chart for "%s"', [GetFileName]),
    GroupEdit.Text, MeasEdit.Text, '', 'Avg',
    groups, means,
    UCL, LCL, grandmean,
    targetSpec, lowerSpec, upperSpec
  );
end;

procedure TXBarChartForm.PlotMeans(
  ATitle, AXTitle, AYTitle, ADataTitle, AGrandMeanTitle: String;
  const Groups: StrDyneVec; const Means: DblDyneVec;
  UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double);
const
  EPS = 1E-6;
var
  y: Double;
begin
  inherited;
  if not ZonesChk.Checked then
    exit;

  y := GrandMean + FAveStdDev;
  while y < UCL - EPS do
  begin
    FChartFrame.HorLine(y, clRed, psDot, '');
    y := y + FAveStdDev;
  end;

  y := GrandMean - FAveStdDev;
  while y > LCL + EPS do
  begin
    FChartFrame.HorLine(y, clRed, psDot, '');
    y := y - FAveStdDev;
  end;
end;


procedure TXBarChartForm.Reset;
begin
  inherited;
  UpperSpecEdit.Text := '';
  LowerSpecEdit.Text := '';
  TargetSpecEdit.Text := '';
  XSigmaEdit.Text := '';
  UpperSpecChk.Checked := false;
  LowerSpecChk.Checked := false;
  TargetChk.Checked := false;
  ZonesChk.Checked := false;
end;

function TXBarChartForm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
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

  if SigmaOpts.ItemIndex = -1 then
  begin
    AMsg := 'Number of sigma units for UCL and LCL not specified.';
    AControl := SigmaOpts;
    exit;
  end;

  if SigmaOpts.ItemIndex = 3 then
  begin
    if (XSigmaEdit.Text = '') then
    begin
      AMsg := 'User-defined sigma units missing.';
      AControl := XSigmaEdit;
      exit;
    end;
    if not TryStrToFloat(XSigmaEdit.Text, x) then
    begin
      AMsg := 'No valid number given for sser-defined sigma units.';
      AControl := XSigmaEdit;
      exit;
    end;
  end;

  if UpperSpecChk.Checked then begin
    if UpperSpecEdit.Text = '' then
    begin
      AMsg := 'Upper Spec Level missing.';
      AControl := UpperSpecEdit;
      exit;
    end;
    if not TryStrToFloat(UpperSpecEdit.Text, x) then
    begin
      AMsg := 'Upper Spec Level is not a valid number.';
      AControl := UpperSpecEdit;
      exit;
    end;
  end;

  if LowerSpecChk.Checked then begin
    if LowerSpecEdit.Text = '' then
    begin
      AMsg := 'Lower Spec Level missing.';
      AControl := LowerSpecEdit;
      exit;
    end;
    if not TryStrToFloat(LowerSpecEdit.Text, x) then
    begin
      AMsg := 'Lower Spec Level is not a valid number.';
      AControl := LowerSpecEdit;
      exit;
    end;
  end;

  if TargetChk.Checked then begin
    if TargetSpecEdit.Text = '' then
    begin
      AMsg := 'Target Spec Level missing.';
      AControl := TargetSpecEdit;
      exit;
    end;
    if not TryStrToFloat(TargetSpecEdit.Text, x) then
    begin
      AMsg := 'Target Spec Level is not a valid number.';
      AControl := TargetSpecEdit;
      exit;
    end;
  end;

  Result := true;
end;

end.

