unit PChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, BasicSPCUnit;

type

  { TPChartForm }

  TPChartForm = class(TBasicSPCForm)
    Label3: TLabel;
    Label4: TLabel;
    NEdit: TEdit;
    PEdit: TEdit;
    SigmaOpts: TRadioGroup;
    XSigmaEdit: TEdit;
    procedure FormActivate(Sender: TObject);
  protected
    procedure Compute; override;
    procedure Reset; override;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean; override;
  end;

var
  PChartForm: TPChartForm;


implementation

{$R *.lfm}

uses
  Math, Globals, Utils, MainUnit, DataProcs;

procedure TPChartForm.Compute;
var
  ColNoSelected: IntDyneVec = nil;
  obsP: DblDyneVec = nil;
  X, AVG, P, sigma, variance, stddev, UCL, LCL, maxX: Double;
  i, N, count: Integer;
  lReport: TStrings;
begin
  SetLength(ColNoSelected, 1);
  ColNoSelected[0] := MeasVar;

  case SigmaOpts.ItemIndex of
    0: sigma := 3.0;
    1: sigma := 2.0;
    2: sigma := 1.0;
    3: sigma := StrToFloat(XSigmaEdit.Text);
  end;

  N := StrToInt(NEdit.Text);
  P := StrToFloat(PEdit.Text);
  variance := P * (1.0 - P) / N;
  stddev := sqrt(variance);

  AVG := 0.0;
  count := 0;
  maxX := 0;
  SetLength(obsP, NoCases);
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
    if X > maxX then maxX := X;
  end;

  if maxX > N then
  begin
    ErrorMsg(Format('Maximum number of defects (%.0f) cannot be larger than the sample size (%d)', [maxX, N]));
    exit;
  end;

  for i := 1 to NoCases do
  begin
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
    X := X / N;
    obsP[i - 1] := X;
    AVG := AVG + X;
    inc(count);
  end;
  SetLength(obsP, count);
  AVG := AVG / count; //NoCases;
  UCL := P + Sigma * stddev;
  LCL := P - Sigma * stddev;

  // output results
  lReport := TStringList.Create;
  try
    lReport.Add('DEFECTS P CONTROL CHART RESULS');
    lReport.Add('');
    lReport.Add('Sample No.  Proportion');
    lReport.Add('----------  ----------');
    for i := 1 to NoCases do
      lReport.Add('%10d  %10.3f', [i, obsp[i]]);
    lReport.Add('');
    lReport.Add('Number of data values:            %8d', [count]);
    lReport.Add('Target proportion:                %8.4f', [P]);
    lReport.Add('Sample size for each observation: %8d', [N]);
    lReport.Add('Average proportion observed       %8.4f', [AVG]);

    FReportFrame.DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // Show graph
  PlotMeans(
    Format('P Control Chart for "%s"', [GetFileName]),
    'Sample', MeasEdit.Text + ' proportion', 'Values', 'Mean',
    nil, obsP,
    UCL, LCL, AVG,
    NaN, NaN, NaN
  );
end;

procedure TPChartForm.FormActivate(Sender: TObject);
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
    SigmaOpts.AnchorSideRight.Control := nil;
    VarList.Constraints.MinWidth := VarListLabel.Width;
    SpecsPanel.Constraints.MinWidth := Max(
      CloseBtn.Left + CloseBtn.Width - HelpBtn.Left + HelpBtn.BorderSpacing.Around,
      SigmaOpts.Width * 2 + VarList.BorderSpacing.Right + VarList.BorderSpacing.Left
    );
    Constraints.MinHeight := SigmaOpts.Top + SigmaOpts.Height + SigmaOpts.BorderSpacing.Bottom + ButtonPanel.Height;

    SigmaOpts.AnchorSideRight.Control := MeasEdit;
    SigmaOpts.AnchorSideRight.Side := asrBottom;
  finally
    EnableAutoSizing;
  end;
end;


procedure TPChartForm.Reset;
begin
  inherited;
  XSigmaEdit.Clear;
  NEdit.Clear;
  PEdit.Clear;
end;


function TPChartForm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
  n: Integer;
begin
  Result := inherited;
  if not Result then
    exit;

  Result := false;

  if (NEdit.Text = '') then
  begin
    AMsg := 'No of Parts Sampled not specified.';
    AControl := NEdit;
    exit;
  end;

  if not TryStrToInt(NEdit.Text, n) then
  begin
    AMsg := 'No valid number given for No of Parts Sampled.';
    AControl := NEdit;
    exit;
  end;

  if (PEdit.Text = '') then
  begin
    AMsg := 'Expected proportion of defects not specifed.';
    AControl := PEdit;
    exit;
  end;

  if not TryStrToFloat(PEdit.Text, x) then
  begin
    AMsg := 'No valid number given for expected proportion of defects.';
    AControl := PEdit;
    exit;
  end;

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

  Result := true;
end;

end.


