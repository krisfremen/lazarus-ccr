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
    ChartToolset: TChartToolset;
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
    MeanEdit: TEdit;
    NDChk: TRadioButton;
    ChartPanel: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    GroupBox2: TGroupBox;
    AlphaLabel: TLabel;
    DF1Label: TLabel;
    DF2Label: TLabel;
    MeanLabel: TLabel;
    GroupBox1: TGroupBox;
    procedure ChiChkClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FChkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CalcChiSq(const AX: Double; out AY: Double);
    procedure CalcF(const AX: Double; out AY: Double);
    procedure CalcND(const AX: Double; out AY: Double);
    procedure Calct(const AX: Double; out AY: Double);
    procedure NDChkClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure tChkClick(Sender: TObject);
  private
    { private declarations }
    DF1: Integer;
    DF2: Integer;
    procedure NDPlot;
    procedure ChiPlot;
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
  //spe,  // a numlib unit (tDist)
  OSPrinters,
  TAChartUtils, TADrawerSVG, TAPrint;


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
  MeanEdit.Text := '';
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
var
  ratio1, ratio2, ratio3, ratio4: double;
  part1, part2, part3, part4, part5, part6, part7, part8, part9: double;
begin
  // Returns the height of the density curve for the F statistic
  ratio1 := (DF1 + DF2) / 2.0;
  ratio2 := (DF1 - 2.0) / 2.0;
  ratio3 := DF1 / 2.0;
  ratio4 := DF2 / 2.0;
  part1 := exp(lngamma(ratio1));
  part2 := power(DF1, ratio3);
  part3 := power(DF2, ratio4);
  part4 := exp(lngamma(ratio3));
  part5 := exp(lngamma(ratio4));
  part6 := power(AX, ratio2);
  part7 := power((AX*DF1 + DF2), ratio1);
  part8 := (part1 * part2 * part3) / (part4 * part5);
  if (part7 = 0.0) then
    part9 := 0.0
  else
    part9 := part6 / part7;
  AY := part8 * part9;
end;

procedure TDistribFrm.CalcND(const AX: Double; out AY: Double);
begin
  AY := 1.0 / sqrt(TWO_PI) * exp(-sqr(AX)/ 2.0);
end;

procedure TDistribFrm.CalcChiSq(const AX: Double; out AY: Double);
begin
  AY := 1.0 / (power(2.0, DF1*0.5) * exp(lngamma(DF1*0.5))) * power(AX, (DF1-2.0)*0.5) * (1.0 / exp(AX*0.5));
end;

procedure TDistribFrm.Calct(const AX: Double; out AY: Double);
begin
  AY := Student(AX, DF1, 1.0);
  //AY := tDist(AX, DF1, 1);
end;

procedure TDistribFrm.NDChkClick(Sender: TObject);
begin
   if NDChk.Checked then
   begin
     GroupBox2.Enabled := true;
     AlphaLabel.Enabled := true;
     AlphaEdit.Enabled := true;
     DF1Edit.Enabled := false;
     DF1Label.Enabled := false;
     DF2Label.Enabled := false;
     MeanLabel.Enabled := false;
     DF2Edit.Enabled := false;
     MeanEdit.Enabled := false;
   end
   else
     GroupBox2.Enabled := false;
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
    NDPlot();
    ok := true;
  end;

  if tChk.Checked then
  begin
    tPlot();
    ok := true;
  end;

  if ChiChk.Checked then
  begin
    ChiPlot();
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

procedure TDistribFrm.FChkClick(Sender: TObject);
begin
  if FChk.Checked then
  begin
    GroupBox2.Enabled := true;
    DF2Label.Enabled := true;
    AlphaLabel.Enabled := true;
    AlphaEdit.Enabled := true;
    DF1Edit.Enabled := true;
    DF2Edit.Enabled := true;
    DF1Label.Enabled := true;
    MeanLabel.Enabled := false;
    MeanEdit.Enabled := false;
  end
  else
    GroupBox2.Enabled := false;
end;

procedure TDistribFrm.ChiChkClick(Sender: TObject);
begin
  if ChiChk.Checked then
  begin
    GroupBox2.Enabled := true;
    DF1Label.Enabled := true;
    DF1Edit.Enabled := true;
    DF2Label.Enabled := false;
    MeanLabel.Enabled := false;
    AlphaLabel.Enabled := true;
    AlphaEdit.Enabled := true;
    DF2Edit.Enabled := false;
    MeanEdit.Enabled := false;
  end else
    GroupBox2.Enabled := false;
end;

procedure TDistribFrm.tChkClick(Sender: TObject);
begin
  if tChk.Checked then
  begin
    GroupBox2.Enabled := true;
    DF1Label.Enabled := true;
    DF1Edit.Enabled := true;
    DF2Label.Enabled := false;
    MeanLabel.Enabled := false;
    AlphaLabel.Enabled := true;
    AlphaEdit.Enabled := true;
    DF2Edit.Enabled := false;
    MeanEdit.Enabled := false;
  end else
    GroupBox2.Enabled := false;
end;


procedure TDistribFrm.NDPlot;
var
  alpha: Double;
  zMax, zCrit, pCrit: Double;
begin
  alpha := StrToFloat(AlphaEdit.Text);
  zMax := InverseZ(0.9999);
  zCrit := inversez(1.0 - alpha);
  CalcND(zCrit, pCrit);

  Chart.Title.Text.Clear;
  Chart.Title.Text.Add('<b>Normal Distribution</b>');
  Chart.Title.Text.Add(Format('&alpha; = %.3g', [alpha]));
  Chart.Title.Text.Add(Format('Critical value = %.3f', [zCrit]));
  Chart.Title.Visible := true;
  Chart.BottomAxis.Title.Caption := 'z';
  FuncSeries.Extent.XMin := -zMax;
  FuncSeries.Extent.XMax := +zMax;
  FuncSeries.Extent.UseXMin := true;
  FuncSeries.Extent.UseXMax := true;
  FuncSeries.OnCalculate := @CalcND;
  FuncSeries.DomainExclusions.Clear;
  VertLineSeries.Clear;
  VertLineSeries.AddXY(zCrit, 0);
  VertLineSeries.AddXY(zCrit, pCrit);
  VertLineSeries.Active := true;
end;

procedure TDistribFrm.ChiPlot;
var
  alpha: Double;
  Chi2Max, Chi2Crit, pCrit: Double;
begin
  alpha := StrToFloat(AlphaEdit.Text);
  DF1 := StrToInt(DF1Edit.Text);
  Chi2Max := InverseChi(0.9999, DF1);
  Chi2Crit := InverseChi(1.0 - alpha, DF1);
  CalcChiSq(Chi2Crit, pCrit);

  Chart.Title.Text.Clear;
  Chart.Title.Text.Add('<b>Chi-Squared Distribution</b>');
  Chart.Title.Text.Add(Format('&alpha; = %.3g / Degrees of freedom = %d', [alpha, DF1]));
  Chart.Title.Text.Add(Format('Critical value = %.3f', [Chi2Crit]));
  Chart.Title.Visible := true;
  Chart.BottomAxis.Title.Caption := '&chi;<sup>2</sup>';
  FuncSeries.Extent.XMin := 0;
  FuncSeries.Extent.XMax := Chi2Max;
  FuncSeries.Extent.UseXMin := true;
  FuncSeries.Extent.UseXMax := true;
  FuncSeries.OnCalculate := @CalcChiSq;
  FuncSeries.DomainExclusions.AddRange(-Infinity, 0, [ioOpenEnd]);
  VertLineSeries.Clear;
  VertLineSeries.AddXY(Chi2Crit, 0);
  VertLineSeries.AddXY(Chi2Crit, pCrit);
  VertLineSeries.Active := true;
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
  FuncSeries.OnCalculate := @CalcF;
  FuncSeries.DomainExclusions.AddRange(-Infinity, 0, [ioOpenEnd]);
  VertLineSeries.Clear;
  VertLineSeries.AddXY(FCrit, 0);
  VertLineSeries.AddXY(FCrit, pCrit);
  VertLineSeries.Active := true;
end;

procedure TDistribFrm.tPlot;
var
  alpha: Double;
  tMax, tCrit, pCrit: Double;
begin
  alpha := StrToFloat(AlphaEdit.Text);
  DF1 := StrToInt(DF1Edit.Text);
  tMax := Inverset(0.9999, DF1);
  tCrit := Inverset(1.0 - alpha, DF1);
  Calct(tCrit, pCrit);

  Chart.Title.Text.Clear;
  Chart.Title.Text.Add('<b>Student t Distribution</b>');
  Chart.Title.Text.Add(Format('&alpha; = %.3g / Degrees of freedom = %d', [alpha, DF1]));
  Chart.Title.Text.Add(Format('Critical value = %.3f', [tCrit]));
  Chart.Title.Visible := true;
  Chart.BottomAxis.Title.Caption := 't';
  FuncSeries.Extent.XMin := -tMax;
  FuncSeries.Extent.XMax := tMax;
  FuncSeries.Extent.UseXMin := true;
  FuncSeries.Extent.UseXMax := true;
  FuncSeries.OnCalculate := @Calct;
  FuncSeries.DomainExclusions.Clear;
  VertLineSeries.Clear;
  VertLineSeries.AddXY(tCrit, 0);
  VertLineSeries.AddXY(tCrit, pCrit);
  VertLineSeries.Active := true;
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

