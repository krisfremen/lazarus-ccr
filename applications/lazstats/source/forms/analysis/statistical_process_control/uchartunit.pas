unit UChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, BasicSPCUnit;

type

  { TUChartForm }

  TUChartForm = class(TBasicSPCForm)
    Label3: TLabel;
    NoInspEdit: TEdit;
    SigmaOpts: TRadioGroup;
    XSigmaEdit: TEdit;
    procedure FormActivate(Sender: TObject);
  protected
    procedure Compute; override;
    procedure Reset; override;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean; override;
  end;

var
  UChartForm: TUChartForm;


implementation

{$R *.lfm}

uses
  Math, Globals, MainUnit, DataProcs;

{ TUChartForm }

procedure TUChartForm.Compute;
var
  ColNoSelected: IntDyneVec = nil;
  means: DblDyneVec = nil;
  defPerUnit: DblDyneVec = nil;
  X, meanC, stdDevC, grandMean, sigma, UCL, LCL: Double;
  i, size, count, numSamples: Integer;
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

  SetLength(means, NoCases);
  SetLength(defperunit, NoCases);
  GrandMean := 0.0;
  size := 0;
  count := StrToInt(NoInspEdit.Text);
  numSamples := 0;

  for i := 1 to NoCases do
  begin
    if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
    means[i-1] := X;
    grandMean := grandMean + X;
    defPerUnit[i-1] := X / count;
    size := size + count;
    inc(numSamples);
  end;

  meanC := grandMean / size;
  stdDevC := sqrt(meanC / count);
  UCL := meanc + sigma * stddevc;
  LCL := meanc - sigma * stddevc;

  // Print results
  lReport := TStringList.Create;
  try
    lReport.Add('DEFECTS c CONTROL CHART RESULTS');
    lReport.Add('');
    lReport.Add('No. of Samples:        %8d',   [numSamples]);
    lReport.Add('Total Nonconformities: %8.2f', [grandMean]);
    lReport.Add('Def. / unit Mean:      %8.3f', [meanC]);
    lReport.Add('   and StdDev:         %8.3f', [stdDevC]);
    lReport.Add('Lower Control Limit:   %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:   %8.3f', [UCL]);
    lReport.Add('');
    lReport.Add('Sample  No Defects  Defects Per Unit');
    lReport.Add('------  ----------  ----------------');
    for i := 0 to numSamples-1 do
      lReport.Add('%6d  %10.2f  %16.2f', [i, means[i], defPerUnit[i]]);

    ReportMemo.Lines.Assign(lReport);
  finally
    lReport.Free;
  end;

  // Show graph
  PlotMeans(
    Format('Defect Control Chart for "%s"', [GetFileName]),
    'Sample', MeasEdit.Text + ' per Unit', 'Values', 'Mean',
    nil, defPerUnit,
    UCL, LCL, meanC,
    NaN, NaN, NaN
  );
end;


procedure TUChartForm.FormActivate(Sender: TObject);
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


procedure TUChartForm.Reset;
begin
  inherited;
  NoInspEdit.Clear;
  XSigmaEdit.Clear;
end;


function TUChartForm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
  n: Integer;
begin
  Result := inherited;
  if not Result then
    exit;

  Result := false;

  if (NoInspEdit.Text = '') then
  begin
    AMsg := 'Number of inspected parts per group not specified.';
    AControl := NoInspEdit;
    exit;
  end;

  if not TryStrToInt(NoInspEdit.Text, n) then
  begin
    AMsg := 'No valid number given for number of inspected parts per group.';
    AControl := NoInspEdit;
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

