unit CChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, BasicSPCUnit;

type

  { TCChartForm }

  TCChartForm = class(TBasicSPCForm)
    SigmaOptns: TRadioGroup;
    XSigmaEdit: TEdit;
    procedure FormActivate(Sender: TObject);
  protected
    procedure Compute; override;
    procedure Reset; override;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean; override;

  end;

var
  CChartForm: TCChartForm;

implementation

{$R *.lfm}

uses
  Math,
  Globals, MainUnit, DataProcs;


{ TCChartForm }

procedure TCChartForm.Compute;
var
  i: Integer;
  ColNoSelected: IntDyneVec = nil;
  means: DblDyneVec = nil;
  X: Double;
  meanC, stdDevC, UCL, LCL, sigma, grandMean: Double;
  numData: Integer;
  lReport: TStrings;
begin
  SetLength(ColNoSelected, 1);
  ColNoSelected[0] := MeasVar;

  case SigmaOptns.ItemIndex of
    0: sigma := 3.0;
    1: sigma := 2.0;
    2: sigma := 1.0;
    3: sigma := StrToFloat(XSigmaEdit.Text);
  end;

  SetLength(means, NoCases + 1);
  grandMean := 0.0;
  numData := 0;
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
    means[i-1] := X;
    grandMean := grandMean + X;
    inc(numData);
  end;
  SetLength(means, numData);

  meanc := grandMean / numData;
  stdDevc := sqrt(meanc);
  UCL := meanc + sigma * stddevc;
  LCL := meanc - sigma * stddevc;

  // printed results
  lReport := TStringList.Create;
  try
    lReport.Add('DEFECTS c CONTROL CHART RESULTS');
    lReport.Add('');
    lReport.Add('No. of samples:            %8d',   [numData]); //NoCases]);
    lReport.Add('Total Nonconformities:     %8.3f', [GrandMean]);
    lReport.Add('Poisson mean and variance: %8.3f', [meanc]);
    lReport.Add('Lower Control Limit:       %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:       %8.3f', [UCL]);
    lReport.Add('');
    lReport.Add('Sample  Number of ');
    lReport.Add('        Nonconformities');
    lReport.Add('------  ---------------');
    for i := 1 to NoCases do
      lReport.Add('%6d %15.2f', [i, means[i]]);

    FReportFrame.DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // Show graph
  PlotMeans(
    Format('Defect Control C Chart for "%s"', [GetFileName]),
    'Sample', MeasEdit.Text, 'Data', 'Mean',
    nil, means,
    UCL, LCL, meanc,
    NaN, NaN, NaN
  );
end;

procedure TCChartForm.FormActivate(Sender: TObject);
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
    SigmaOptns.AnchorSideRight.Control := nil;
    VarList.Constraints.MinWidth := VarListLabel.Width;
    SpecsPanel.Constraints.MinWidth := Max(
      CloseBtn.Left + CloseBtn.Width - HelpBtn.Left + HelpBtn.BorderSpacing.Around,
      SigmaOptns.Width * 2 + VarList.BorderSpacing.Right + VarList.BorderSpacing.Left
    );
    Constraints.MinHeight := SigmaOptns.Top + SigmaOptns.Height + SigmaOptns.BorderSpacing.Bottom + ButtonPanel.Height;

    SigmaOptns.AnchorSideRight.Control := MeasEdit;
    SigmaOptns.AnchorSideRight.Side := asrBottom;
  finally
    EnableAutoSizing;
  end;
end;


procedure TCChartForm.Reset;
begin
  inherited;
  XSigmaEdit.Clear;
end;


function TCChartForm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
begin
  Result := inherited;
  if not Result then
    exit;

  Result := false;

  if SigmaOptns.ItemIndex = -1 then
  begin
    AMsg := 'Number of sigma units for UCL and LCL not specified.';
    AControl := SigmaOptns;
    exit;
  end;

  if SigmaOptns.ItemIndex = 3 then
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

