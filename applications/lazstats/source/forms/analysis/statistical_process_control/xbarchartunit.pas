unit XBarChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, BasicSPCUnit;

type

  { TXBarChartForm }

  TXBarChartForm = class(TBasicSPCForm)
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
  protected
    procedure Compute; override;
    procedure Reset; override;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean; override;
  end;

var
  XBarChartForm: TXBarChartForm;


implementation

uses
  Math,
  Globals, Utils, MainUnit, DataProcs;

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
      LevelOptns.Width * 2 + VarList.BorderSpacing.Right + VarList.BorderSpacing.Left
    );
    Constraints.MinHeight := LevelOptns.Top + LevelOptns.Height + LevelOptns.BorderSpacing.Bottom + ButtonPanel.Height;

    LevelOptns.AnchorSideRight.Control := MeasEdit;
    LevelOptns.AnchorSideRight.Side := asrBottom;
  finally
    EnableAutoSizing;
  end;
end;


procedure TXBarChartForm.Compute;
var
  i, j: Integer;
  upperSpec, lowerSpec, targetSpec, sigma: Double;
  ColNoSelected: IntDyneVec = nil;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stdDev: DblDyneVec = nil;
  count: IntDyneVec = nil;
  numGrps: Integer;
  grp: String;
  grpIndex: Integer;
  X, Xsq: Double;
  UCL, LCL, grandMean, grandSD, seMean: Double;
  lReport: TStrings;
begin
  SetLength(ColNoSelected, 2);
  ColNoSelected[0] := GrpVar;
  ColNoSelected[1] := MeasVar;

  if UpperSpecChk.Checked and (UpperSpecEdit.Text <> '') then
    upperSpec := StrToFloat(UpperSpecEdit.Text)
  else
    upperSpec := NaN;
  if LowerSpecChk.Checked and (LowerSpecEdit.Text <> '') then
    lowerSpec := StrToFloat(LowerSpecEdit.Text)
  else
    lowerSpec := NaN;
  if TargetChk.Checked and (TargetSpecEdit.Text <> '') then
    targetSpec := StrToFloat(TargetSpecEdit.Text)
  else
    targetSpec := Nan;

  case SigmaOpts.ItemIndex of
    0: sigma := 3.0;
    1: sigma := 2.0;
    2: sigma := 1.0;
    3: sigma := StrToFloat(XSigmaEdit.Text);
  end;

  groups := GetGroups;
  numGrps := Length(groups);

  SetLength(means, numGrps);
  SetLength(count, numGrps);
  SetLength(stddev, numGrps);
  seMean := 0.0;
  grandMean := 0.0;

  // calculate group means, grand mean, group sd's, semeans
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
    seMean := seMean + Xsq;
    grandMean := grandMean + X;
  end;

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
        stddev[i] := stddev[i] / (count[i] - 1);
        stddev[i] := sqrt(stddev[i]);
      end;
      means[i] := means[i] / count[i];
    end;
  end;
  seMean := seMean - sqr(grandMean) / NoCases;
  seMean := sqrt(seMean / (NoCases - 1));
  grandSD := seMean;
  seMean := seMean / sqrt(NoCases);
  grandMean := grandMean / NoCases;
  UCL := grandMean + sigma * seMean;
  LCL := grandMean - sigma * seMean;

  // printed results
  lReport := TStringList.Create;
  try
    lReport.Add('X BAR CHART RESULTS');
    lReport.Add('');
    lReport.Add(' Group  Size   Mean   Std.Dev.');
    lReport.Add('------- ---- -------- --------');
    for i := 0 to numGrps-1 do
      lReport.Add('%7s %4d %8.2f %8.2f', [groups[i], count[i], means[i], stddev[i]]);
    lReport.Add('');
    lReport.Add('Grand Mean:             %8.3f', [grandMean]);
    lReport.Add('Standard Deviation:     %8.3f', [grandSD]);
    lReport.Add('Standard Error of Mean: %8.3f', [seMean]);
    lReport.Add('');
    lReport.Add('Lower Control Limit:    %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:    %8.3f', [UCL]);

    ReportMemo.Lines.Assign(lReport);
  finally
    lReport.Free;
  end;

  // Show graph
  PlotMeans(
    Format('x&#772; chart for "%s"', [GetFileName]),
    GroupEdit.Text, MeasEdit.Text, 'Group means', 'Grand mean',
    groups, means,
    UCL, LCL, grandmean,
    targetSpec, lowerSpec, upperSpec
  );
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
end;

function TXBarChartForm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
begin
  Result := inherited;
  if not Result then
    exit;

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

