// Testing: no file needed
//
// Test input parameters:
// - F distribution: DF1 = 3, DF2 = 20

// ToDo: Fix calculation of t distribution

unit DistribUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TAFuncSeries, TASeries, TATools,
  PrintersDlgs, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Printers, ExtCtrls, ExtDlgs, Math, FunctionsLib, Globals;

type

  { TDistribFrm }

  TDistribFrm = class(TForm)
    AlphaEdit: TEdit;
    Bevel1: TBevel;
    Bevel2: TBevel;
    ShowCriticalValuesChk: TCheckBox;
    HorLineSeries: TLineSeries;
    ChartToolset: TChartToolset;
    CumulativeChk: TCheckBox;
    PanDragTool: TPanDragTool;
    tChk: TRadioButton;
    ZoomDragTool: TZoomDragTool;
    PrintDialog: TPrintDialog;
    SavePictureDialog: TSavePictureDialog;
    VertLineSeries: TLineSeries;
    FuncSeries: TFuncSeries;
    ParameterPanel: TPanel;
    SaveBtn: TButton;
    PrintBtn: TButton;
    Chart: TChart;
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
    procedure CumulativeChkChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
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
    procedure SaveBtnClick(Sender: TObject);
  private
    { private declarations }
    DF1: Integer;
    DF2: Integer;
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

uses
  TAChartUtils, TADrawerSVG, TAPrint,
  MathUnit;


{ TDistribFrm }

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
  FuncSeries.OnCalculate := nil;
  VertLineSeries.Active := false;
  Chart.Title.Visible := false;
  Chart.BottomAxis.Title.Caption := 'Scale';
end;


procedure TDistribFrm.SaveBtnClick(Sender: TObject);
var
  ext: String;
begin
  if SavePictureDialog.Execute then
  begin
    ext := Lowercase(ExtractFileExt(SavePictureDialog.FileName));
    case ext of
      '.bmp': Chart.SaveToFile(TBitmap, SavePictureDialog.Filename);
      '.png': Chart.SaveToFile(TPortableNetworkGraphic, SavePictureDialog.FileName);
      '.jpg', '.jpeg', '.jpe', '.jfif': Chart.SaveToFile(TJpegImage, SavePictureDialog.FileName);
      '.svg': Chart.SaveToSVGFile(SavePictureDialog.FileName);
    end;
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
const
  MARGIN = 10;
var
  R: TRect;
  d: Integer;
begin
  if not PrintDialog.Execute then
    exit;

  Printer.BeginDoc;
  try
    R := Rect(0, 0, Printer.PageWidth, Printer.PageHeight div 2);

    d := R.Right - R.Left;
    R.Left += d div MARGIN;
    R.Right -= d div MARGIN;

    d := R.Bottom - R.Top;
    R.Top += d div MARGIN;
    R.Bottom -= d div MARGIN;

    Chart.Draw(TPrinterDrawer.Create(Printer, true), R);
  finally
    Printer.EndDoc;
  end;
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

procedure TDistribFrm.CumulativeChkChange(Sender: TObject);
begin
  if CumulativeChk.Checked then
    Chart.LeftAxis.Title.Caption := 'Cumulative probability'
  else
    Chart.LeftAxis.Title.Caption := 'Probability density';
end;


procedure TDistribFrm.NormalDistPlot;
var
  alpha: Double;
  zMax, zMin, zCrit, pCrit: Double;
begin
  alpha := StrToFloat(AlphaEdit.Text);
  zMax := InverseZ(0.9999);
  zMin := -zMax;
  zCrit := inversez(1.0 - alpha);
  CalcND(zCrit, pCrit);

  Chart.Title.Text.Clear;
  Chart.Title.Text.Add('<b>Normal Distribution</b>');
  Chart.Title.Text.Add(Format('&alpha; = %.3g', [alpha]));
  Chart.Title.Text.Add(Format('Critical value = %.3f', [zCrit]));
  Chart.Title.Visible := true;
  Chart.BottomAxis.Title.Caption := 'z';
  FuncSeries.Extent.XMin := zMin;
  FuncSeries.Extent.XMax := zMax;
  FuncSeries.Extent.UseXMin := true;
  FuncSeries.Extent.UseXMax := true;
  if CumulativeChk.Checked then
    FuncSeries.OnCalculate := @CalcND_Cumulative
  else
    FuncSeries.OnCalculate := @CalcND;
  FuncSeries.DomainExclusions.Clear;

  VertlineSeries.Clear;
  if CumulativeChk.Checked then
  begin
    HorLineSeries.Clear;
    HorLineSeries.AddXY(zMin, 1.0 - alpha);
    HorLineSeries.AddXY(zCrit, 1.0 - alpha);
    VertlineSeries.AddXY(zCrit, 1.0 - alpha);
    VertLineSeries.AddXY(zCrit, 0);
  end else
  begin
    VertLineSeries.AddXY(zCrit, 0);
    VertLineSeries.AddXY(zCrit, pCrit);
  end;
  HorLineSeries.Active := ShowCriticalValuesChk.Checked and CumulativeChk.Checked;
  VertLineSeries.Active := ShowCriticalValuesChk.Checked;
end;


procedure TDistribFrm.Chi2Plot;
var
  alpha: Double;
  chi2Max, chi2Crit, pCrit: Double;
begin
  alpha := StrToFloat(AlphaEdit.Text);
  DF1 := StrToInt(DF1Edit.Text);
  chi2Max := InverseChi(0.9999, DF1);
  chi2Crit := InverseChi(1.0 - alpha, DF1);
  CalcChi2(chi2Crit, pCrit);

  Chart.Title.Text.Clear;
  Chart.Title.Text.Add('<b>Chi-Squared Distribution</b>');
  Chart.Title.Text.Add(Format('&alpha; = %.3g / Degrees of freedom = %d', [alpha, DF1]));
  Chart.Title.Text.Add(Format('Critical value = %.3f', [Chi2Crit]));
  Chart.Title.Visible := true;
  Chart.BottomAxis.Title.Caption := '&chi;<sup>2</sup>';
  FuncSeries.Extent.XMin := 0;
  FuncSeries.Extent.XMax := chi2Max;
  FuncSeries.Extent.UseXMin := true;
  FuncSeries.Extent.UseXMax := true;
  if CumulativeChk.Checked then
    FuncSeries.OnCalculate := @CalcChi2_Cumulative
  else
    FuncSeries.OnCalculate := @CalcChi2;
  FuncSeries.DomainExclusions.AddRange(-Infinity, 0, [ioOpenEnd]);

  VertLineSeries.Clear;
  if CumulativeChk.Checked then begin
    HorLineSeries.Clear;
    HorLineSeries.AddXY(0, 1.0 - alpha);
    HorLineSeries.AddXY(chi2Crit, 1.0 - alpha);
    VertlineSeries.AddXY(chi2Crit, 1.0 - alpha);
    VertLineSeries.AddXY(chi2Crit, 0);
  end else
  begin
    VertLineSeries.AddXY(chi2Crit, 0);
    VertLineSeries.AddXY(chi2Crit, pCrit);
  end;
  HorLineSeries.Active := ShowCriticalValuesChk.Checked and CumulativeChk.Checked;
  VertLineSeries.Active := ShowCriticalValuesChk.Checked;
end;


procedure TDistribFrm.FPlot;
var
  alpha: Double;
  FMax, FCrit, pCrit: Double;
begin
  alpha := StrToFloat(AlphaEdit.Text);
  DF1 := StrToInt(DF1Edit.Text);
  DF2 := StrToInt(DF2Edit.Text);
  FMax := FPercentPoint(0.999, DF1, DF2);
  FCrit := FPercentPoint(1.0 - alpha, DF1, DF2);
  CalcF(FCrit, pCrit);

  Chart.Title.Text.Clear;
  Chart.Title.Text.Add('<b>F Distribution</b>');
  Chart.Title.Text.Add(Format('&alpha; = %.3g / DF1 = %d, DF2 = %d', [alpha, DF1, DF2]));
  Chart.Title.Text.Add(Format('Critical value = %.3f', [FCrit]));
  Chart.Title.Visible := true;
  Chart.BottomAxis.Title.Caption := 'F';
  FuncSeries.Extent.XMin := 0;
  FuncSeries.Extent.XMax := FMax;
  FuncSeries.Extent.UseXMin := true;
  FuncSeries.Extent.UseXMax := true;
  if CumulativeChk.Checked then
    FuncSeries.OnCalculate := @CalcF_Cumulative
  else
    FuncSeries.OnCalculate := @CalcF;
  FuncSeries.DomainExclusions.AddRange(-Infinity, 0, [ioOpenEnd]);

  VertLineSeries.Clear;
  if CumulativeChk.Checked then
  begin
    HorLineSeries.Clear;
    HorLineSeries.AddXY(0, 1.0 - alpha);
    HorLineSeries.AddXY(FCrit, 1.0 - alpha);
    VertLineSeries.AddXY(FCrit, 1.0 - alpha);
    VertLineSeries.AddXY(FCrit, 0);
  end else
  begin
    VertLineSeries.AddXY(FCrit, 0);
    VertLineSeries.AddXY(FCrit, pCrit);
  end;
  HorLineSeries.Active := ShowCriticalValuesChk.Checked and CumulativeChk.Checked;
  VertLineSeries.Active := ShowCriticalValuesChk.Checked;
end;


procedure TDistribFrm.tPlot;
var
  alpha: Double;
  tMin, tMax, tCrit, pCrit: Double;
begin
  alpha := StrToFloat(AlphaEdit.Text);
  DF1 := StrToInt(DF1Edit.Text);
  tMax := Inverset(0.9999, DF1);
  tMin := -tMax;
  tCrit := Inverset(1.0 - alpha, DF1);
  Calct(tCrit, pCrit);

  Chart.Title.Text.Clear;
  Chart.Title.Text.Add('<b>Student t Distribution</b>');
  Chart.Title.Text.Add(Format('&alpha; = %.3g / Degrees of freedom = %d', [alpha, DF1]));
  Chart.Title.Text.Add(Format('Critical value = %.3f', [tCrit]));
  Chart.Title.Visible := true;
  Chart.BottomAxis.Title.Caption := 't';
  FuncSeries.Extent.XMin := tMin;
  FuncSeries.Extent.XMax := tMax;
  FuncSeries.Extent.UseXMin := true;
  FuncSeries.Extent.UseXMax := true;
  if CumulativeChk.Checked then
    FuncSeries.OnCalculate := @CalcT_Cumulative
  else
    FuncSeries.OnCalculate := @CalcT;
  FuncSeries.DomainExclusions.Clear;

  VertLineSeries.Clear;
  if CumulativeChk.Checked then
  begin
    HorLineSeries.Clear;
    HorLineSeries.AddXY(tMin, 1.0 - alpha);
    HorLineSeries.AddXY(tCrit, 1.0 - alpha);
    VertLineSeries.AddXY(tCrit, 1.0 - alpha);
    VertLineSeries.AddXY(tCrit, 0);
  end else
  begin
    VertLineSeries.AddXY(tCrit, 0);
    VertLineSeries.AddXY(tCrit, pCrit);
  end;
  HorLineSeries.Active := ShowCriticalValuesChk.Checked and CumulativeChk.Checked;
  VertLineSeries.Active := ShowCriticalValuesChk.Checked;
end;


procedure TDistribFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([SaveBtn.Width, PrintBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  SaveBtn.Constraints.MinWidth := w;
  PrintBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;


function TDistribFrm.Validate(out AMsg: String; out AControl: TWinControl): boolean;
var
  x: Double;
  n: Integer;
begin
  Result := false;
  if AlphaEdit.Text = '' then
  begin
    AMsg := 'Input required.';
    AControl := AlphaEdit;
    exit;
  end;
  if not TryStrToFloat(AlphaEdit.Text, x) or (x <= 0) or (x >= 1.0) then
  begin
    AMsg := 'Numerical value between 0 and 1 required.';
    AControl := AlphaEdit;
    exit;
  end;

  if ChiChk.Checked or FChk.Checked then
  begin
    if DF1Edit.Text = '' then
    begin
      AMsg := 'Input required.';
      AControl := DF1Edit;
      exit;
    end;
    if not TryStrToInt(DF1Edit.Text, n) or (n <= 0) then
    begin
      AMsg := 'Positive numerical value required.';
      AControl := DF1Edit;
      exit;
    end;
  end;

  if FChk.Checked then
  begin
    if DF2Edit.Text = '' then
    begin
      AMsg := 'Input required.';
      AControl := DF2Edit;
      exit;
    end;
    if not TryStrToInt(DF2Edit.Text, n) or (n <= 0) then
    begin
      AMsg := 'Positive numerical value required.';
      AControl := DF2Edit;
      exit;
    end;
  end;

  (*
  if MeanEdit.Text = '' then
  begin
    AMsg := 'Input required.';
    AControl := MeanEdit;
    exit;
  end;
  if not TryStrToFloat(MeanEdit.Text, x) then
  begin
    AMsg := 'Numerical value required.';
    AControl := MeanEdit;
    exit;
  end;
  *)

  Result := true;
end;

initialization
  {$I distribunit.lrs}

end.

