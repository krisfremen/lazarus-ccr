// Testing: no file needed
//
// Test input parameters:
// - F distribution: DF1 = 3, DF2 = 20

// ToDo: Fix calculation of t distribution

unit DistribUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LCLVersion, TAFuncSeries, //TAGraph, TAFuncSeries, TASeries,
  //PrintersDlgs, LResources,
  Forms, Controls, Graphics, Dialogs, StdCtrls,
  //Printers,
  ExtCtrls, ExtDlgs, ComCtrls, Math,
  Globals, FunctionsLib, ChartFrameUnit;

type

  { TDistribFrm }

  TDistribFrm = class(TForm)
    AlphaEdit: TEdit;
    Bevel2: TBevel;
    ShowCriticalValuesChk: TCheckBox;
    CumulativeChk: TCheckBox;
    tChk: TRadioButton;
    ToolBar1: TToolBar;
    tbSave: TToolButton;
    tbPrint: TToolButton;
    tbErase: TToolButton;
    ParameterPanel: TPanel;
    ChiChk: TRadioButton;
    DF1Edit: TEdit;
    DF2Edit: TEdit;
    FChk: TRadioButton;
    NDChk: TRadioButton;
    ChartPanel: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    GroupBox2: TGroupBox;
    AlphaLabel: TLabel;
    DF1Label: TLabel;
    DF2Label: TLabel;
    GroupBox1: TGroupBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CalcChi2(const AX: Double; out AY: Double);
    procedure CalcChi2_Cumulative(const AX: Double; out AY: Double);
    procedure CalcF(const AX: Double; out AY: Double);
    procedure CalcF_Cumulative(const AX: Double; out AY: Double);
    procedure CalcND(const AX: Double; out AY: Double);
    procedure CalcND_Cumulative(const AX: Double; out AY: Double);
    procedure CalcT(const AX: Double; out AY: Double);
    procedure CalcT_Cumulative(const AX: Double; out AY: Double);
    procedure DistributionClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure ShowCriticalValuesChkChange(Sender: TObject);
    procedure tbEraseClick(Sender: TObject);
    procedure tbPrintClick(Sender: TObject);
    procedure tbSaveClick(Sender: TObject);
  private
    { private declarations }
    ChartFrame: TChartFrame;
    Alpha: Double;
    DF1: Integer;
    DF2: Integer;
    procedure AddSeries(ATitle: string; XMin, XMax: Double;
      xCrit, yCrit: Double; Cumulative: Boolean; ACalcFunc: TFuncCalculateEvent);
    procedure NormalDistPlot;
    procedure Chi2Plot;
    procedure FPlot;
    procedure tPlot;

    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  DistribFrm: TDistribFrm;

implementation

{$R *.lfm}

uses
  TAChartUtils, TALegend, TASeries,
  MathUnit;

const
  P_LIMIT = 0.9999;

{ TDistribFrm }

procedure TDistribFrm.AddSeries(ATitle: string; XMin, XMax: Double;
  xCrit, yCrit: Double; Cumulative: Boolean; ACalcFunc: TFuncCalculateEvent);
var
  funcSer: TFuncSeries;
  vertSer, horSer: TLineSeries;
  i: Integer;
  ext: TDoubleRect;
  allCumulative: Boolean;
  allDensity: Boolean;
begin
  funcSer := TFuncSeries.Create(ChartFrame);
  funcSer.OnCalculate := ACalcFunc;
  funcSer.ExtentAutoY := true;
  funcSer.Extent.XMin := XMin;
  funcSer.Extent.XMax := XMax;
  funcSer.Extent.UseXMin := true;
  funcSer.Extent.UseXMax := true;
  funcSer.Pen.Color := DATA_COLORS[(ChartFrame.Chart.SeriesCount div 3) mod Length(DATA_COLORS)];
  funcSer.Title := ATitle;
  if Cumulative then funcSer.Tag := 1;
  if XMin = 0 then
    funcSer.DomainExclusions.AddRange(
      -Infinity, 0
      {$IF LCL_FullVersion >= 2010000}, [ioOpenEnd] {$IFEND}
    );
  ChartFrame.Chart.AddSeries(funcSer);

  if Cumulative then
    yCrit := 1.0 - Alpha;

  // vertical indicator
  vertSer := TLineSeries.Create(ChartFrame);
  vertSer.LinePen.Color := funcSer.Pen.Color;
  vertSer.LinePen.Style := psDot;
  vertser.Legend.Visible := false;
  vertSer.AddXY(xCrit, yCrit);
  vertSer.AddXY(xCrit, 0);
  if Cumulative then vertSer.Tag := 1;
  vertSer.Active := ShowCriticalValuesChk.Checked;
  ChartFrame.Chart.AddSeries(vertSer);

  // horizontal indicator
  horSer := TLineSeries.Create(ChartFrame);
  horSer.LinePen.Color := funcSer.Pen.Color;
  horSer.LinePen.Style := psDot;
  horSer.Legend.Visible := false;
  horSer.AddXY(0, yCrit);
  horSer.AddXY(xCrit, yCrit);
  if Cumulative then horSer.Tag := 1;
  horSer.Active := ShowCriticalValuesChk.Checked and Cumulative;
  ChartFrame.Chart.AddSeries(horSer);

  ext := ChartFrame.Chart.GetFullExtent();
  i := 2;
  while i < ChartFrame.Chart.SeriesCount do
  begin
    (ChartFrame.Chart.Series[i] as TLineSeries).XValue[0] := ext.a.x;
    inc(i, 3);
  end;

  allCumulative := true;
  allDensity := true;
  i := 0;
  while i < ChartFrame.Chart.SeriesCount-1 do
  begin
    case ChartFrame.Chart.Series[i].Tag of
      0: allCumulative := false;
      1: allDensity := false;
    end;
    inc(i);
  end;
  if allCumulative then
    ChartFrame.SetYTitle('Cumulative Probability')
  else
  if allDensity then
    ChartFrame.SetYTitle('Probability Density')
  else
    ChartFrame.SetYTitle('Probability Density, Cumulative Probability');
  ChartFrame.SetXTitle('x Value');
  ChartFrame.Chart.Legend.Visible := true;
end;


procedure TDistribFrm.ResetBtnClick(Sender: TObject);
begin
  NDChk.Checked := false;
  tChk.Checked := false;
  FChk.Checked := false;
  ChiChk.Checked := false;
  AlphaEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  DF1Edit.Text := '';
  DF2Edit.Text := '';
  GroupBox2.Enabled := false;
  ChartFrame.Clear;
end;


procedure TDistribFrm.ShowCriticalValuesChkChange(Sender: TObject);
var
  i: Integer;
begin
  i := 1;
  while i < ChartFrame.Chart.SeriesCount do
  begin
    ChartFrame.Chart.Series[i].Active := ShowCriticalValuesChk.Checked;
    ChartFrame.Chart.Series[i+1].Active := ShowCriticalValuesChk.Checked;
    inc(i, 3);
  end;
end;


procedure TDistribFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;


procedure TDistribFrm.CalcF(const AX: Double; out AY: Double);
begin
  AY := FDensity(AX, DF1, DF2);
end;


procedure TDistribFrm.CalcF_Cumulative(const AX: Double; out AY: Double);
begin
  AY := 1.0 - ProbF(AX, DF1, DF2);
end;


procedure TDistribFrm.CalcND(const AX: Double; out AY: Double);
begin
  AY := 1.0 / sqrt(TWO_PI) * exp(-sqr(AX)/ 2.0);
end;


procedure TDistribFrm.CalcND_Cumulative(const AX: Double; out AY: Double);
begin
  // AY := ProbZ(AX);  -- very slow
  AY := NormalDist(AX);  // borrowed from NumLib
end;


procedure TDistribFrm.CalcChi2(const AX: Double; out AY: Double);
begin
  AY := Chi2Density(AX, DF1);
end;


procedure TDistribFrm.CalcChi2_Cumulative(const AX: Double; out AY: Double);
begin
  AY := ChiSquaredProb(AX, DF1);
end;


procedure TDistribFrm.Calct(const AX: Double; out AY: Double);
begin
  AY := tDensity(AX, DF1);
end;


procedure TDistribFrm.CalcT_Cumulative(const AX: Double; out AY: Double);
const
  ONE_SIDED = true;
begin
  if AX < 0 then
    AY := tDist(-AX, DF1, ONE_SIDED)
  else
    AY := 1.0 - tDist(AX, DF1, ONE_SIDED);
end;


procedure TDistribFrm.DistributionClick(Sender: TObject);
var
  rb: TRadiobutton;
begin
  rb := Sender as TRadioButton;

  GroupBox2.Enabled := rb.Checked;

  AlphaLabel.Enabled := rb.Checked;
  AlphaEdit.Enabled := rb.Checked;

  DF1Edit.Enabled := (rb <> NDChk) and rb.Checked;
  DF1Label.Enabled := DF1Edit.Enabled;

  DF2Edit.Enabled := (rb = FChk) and rb.Checked;
  DF2Label.Enabled := DF2Edit.Enabled;
end;


procedure TDistribFrm.PrintBtnClick(Sender: TObject);
begin
  ChartFrame.Print;
end;


procedure TDistribFrm.ComputeBtnClick(Sender: TObject);
var
  msg: String;
  C: TWinControl;
  ok: Boolean;
begin
  if not Validate(msg, C) then
  begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  ok := false;
  if NDChk.Checked then
  begin
    NormalDistPlot();
    ok := true;
  end;

  if tChk.Checked then
  begin
    tPlot();
    ok := true;
  end;

  if ChiChk.Checked then
  begin
    Chi2Plot();
    ok := true;
  end;

  if FChk.Checked then
  begin
    FPlot();
    ok := true;
  end;

  if not ok then
    MessageDlg('Please select a distribution.', mtError, [mbOK], 0);
end;


procedure TDistribFrm.NormalDistPlot;
var
  zMax, zMin, zCrit, pCrit: Double;
  title: String;
  func: TFuncCalculateEvent;
begin
  zMax := inverseZ(P_LIMIT);
  zMin := -zMax;
  zCrit := inversez(1.0 - Alpha);
  CalcND(zCrit, pCrit);

  title := Format('Normal (&alpha;=%s, x<sub>crit</sub>=%.3f)', [AlphaEdit.Text, zCrit]);
  if CumulativeChk.Checked then
    func := @CalcND_Cumulative
  else
    func := @CalcND;
  AddSeries(title, zMin, zMax, zCrit, pCrit, CumulativeChk.Checked, func);
end;


procedure TDistribFrm.Chi2Plot;
var
  chi2Max, chi2Crit, pCrit: Double;
  title: String;
  func: TFuncCalculateEvent;
begin
  chi2Max := InverseChi(P_LIMIT, DF1);
  chi2Crit := InverseChi(1.0 - Alpha, DF1);
  CalcChi2(chi2Crit, pCrit);

  title := Format('Chi-sq (&alpha=%s; DF=%d; x<sub>crit</sub>=%.3f)', [AlphaEdit.Text, DF1, Chi2Crit]);
  if CumulativeChk.Checked then
    func := @CalcChi2_Cumulative
  else
    func := @CalcChi2;
  AddSeries(title, 0.0, chi2Max, chi2Crit, pCrit, CumulativeChk.Checked, func);
end;


procedure TDistribFrm.FPlot;
var
  FMax, FCrit, pCrit: Double;
  title: String;
  func: TFuncCalculateEvent;
begin
  FMax := FPercentPoint(P_LIMIT, DF1, DF2);
  FCrit := FPercentPoint(1.0 - Alpha, DF1, DF2);
  CalcF(FCrit, pCrit);

  title := Format('F (&alpha;=%s; DF1=%d, DF2=%d, x<sub>crit</sub>=%.3f)', [AlphaEdit.Text, DF1, DF2, FCrit]);
  if CumulativeChk.Checked then
    func := @CalcF_Cumulative
  else
    func := @CalcF;
  AddSeries(title, 0.0, FMax, FCrit, pCrit, CumulativeChk.Checked, func);
end;


procedure TDistribFrm.tPlot;
var
  tMin, tMax, tCrit, pCrit: Double;
  title: String;
  func: TFuncCalculateEvent;
begin
  tMax := Inverset(P_LIMIT, DF1);
  tMin := -tMax;
  tCrit := Inverset(1.0 - Alpha, DF1);
  Calct(tCrit, pCrit);

  title := Format('t (&alpha;=%s; DF=%d; x<sub>crit</sub>=%.3f)', [AlphaEdit.Text, DF1, tCrit]);
  if CumulativeChk.Checked then
    func := @CalcT_Cumulative
  else
    func := @CalcT;
  AddSeries(title, tMin, tMax, tCrit, pCrit, CumulativeChk.Checked, func);
end;


procedure TDistribFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinHeight :=
    ShowCriticalValuesChk.Top + ShowCriticalValuesChk.Height + 16 +
    CloseBtn.Height + CloseBtn.BorderSpacing.Bottom;
  Constraints.MinWidth := ParameterPanel.Width * 2;
end;

procedure TDistribFrm.FormCreate(Sender: TObject);
begin
  ChartFrame := TChartFrame.Create(self);
  ChartFrame.Parent := ChartPanel;
  ChartFrame.Align := alClient;
  ChartFrame.Chart.Legend.Alignment := laBottomCenter;
  ChartFrame.Chart.Legend.ColumnCount := 3;
  ChartFrame.Chart.Legend.TextFormat := tfHTML;
  ChartFrame.Chart.BottomAxis.Intervals.MaxLength := 80;
  ChartFrame.Chart.BottomAxis.Intervals.MinLength := 30;
end;


procedure TDistribFrm.tbEraseClick(Sender: TObject);
begin
  ChartFrame.Clear;
end;


procedure TDistribFrm.tbPrintClick(Sender: TObject);
begin
  ChartFrame.Print;
end;


procedure TDistribFrm.tbSaveClick(Sender: TObject);
begin
  ChartFrame.Save;
end;


function TDistribFrm.Validate(out AMsg: String; out AControl: TWinControl): boolean;
begin
  Result := false;
  if AlphaEdit.Text = '' then
  begin
    AMsg := 'Input required.';
    AControl := AlphaEdit;
    Alpha := NaN;
    exit;
  end;
  if not TryStrToFloat(AlphaEdit.Text, Alpha) or (Alpha <= 0) or (Alpha >= 1.0) then
  begin
    AMsg := 'Numerical value between 0 and 1 required.';
    AControl := AlphaEdit;
    Alpha := NaN;
    exit;
  end;

  if tChk.Checked or ChiChk.Checked or FChk.Checked then
  begin
    if DF1Edit.Text = '' then
    begin
      AMsg := 'Input required.';
      AControl := DF1Edit;
      DF1 := -1;
      exit;
    end;
    if not TryStrToInt(DF1Edit.Text, DF1) or (DF1 <= 0) then
    begin
      AMsg := 'Positive numerical value required.';
      AControl := DF1Edit;
      DF1 := -1;
      exit;
    end;
  end;

  if FChk.Checked then
  begin
    if DF2Edit.Text = '' then
    begin
      AMsg := 'Input required.';
      AControl := DF2Edit;
      DF2 := -1;
      exit;
    end;
    if not TryStrToInt(DF2Edit.Text, DF2) or (DF2 <= 0) then
    begin
      AMsg := 'Positive numerical value required.';
      AControl := DF2Edit;
      DF2 := -1;
      exit;
    end;
  end;

  Result := true;
end;

//initialization
//  {$I distribunit.lrs}

end.

