// Use file "cansas.laz" for testing

unit PlotXYUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls,
  MainUnit, Globals, FunctionsLib, DataProcs, ReportFrameUnit, ChartFrameUnit;

type

  { TPlotXYFrm }

  TPlotXYFrm = class(TForm)
    Bevel1: TBevel;
    ConfEdit: TEdit;
    Label4: TLabel;
    PageControl1: TPageControl;
    ParamsPanel: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    LineChk: TCheckBox;
    MeansChk: TCheckBox;
    ConfChk: TCheckBox;
    OptionsGroup: TGroupBox;
    ParamsSplitter: TSplitter;
    ReportPage: TTabSheet;
    ChartPage: TTabSheet;
    YEdit: TEdit;
    Label3: TLabel;
    XEdit: TEdit;
    Label2: TLabel;
    XinBtn: TBitBtn;
    XOutBtn: TBitBtn;
    YInBtn: TBitBtn;
    YOutBtn: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure CloseBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure XinBtnClick(Sender: TObject);
    procedure XOutBtnClick(Sender: TObject);
    procedure YInBtnClick(Sender: TObject);
    procedure YOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    FReportFrame: TReportFrame;
    FChartFrame: TChartFrame;
    procedure PlotXY(XPoints, YPoints, UpConf, LowConf: DblDyneVec;
      XMean, YMean, R, Slope, Intercept: Double);
    procedure UpdateBtnStates;
    function Validate(out AMsg: String; out AControl: TWinControl;
      Xcol,Ycol: Integer): Boolean;
  public
    { public declarations }
    procedure Reset;
  end; 

var
  PlotXYFrm: TPlotXYFrm;

implementation

{$R *.lfm}

uses
  TAChartUtils, TAChartAxisUtils, TALegend, TASources, TACustomSeries, TASeries,
  Math, Utils;


{ TPlotXYFrm }

procedure TPlotXYfrm.Reset;
var
  i: integer;
begin
  XEdit.Text := '';
  YEdit.Text := '';
  ConfEdit.Text := FormatFloat('0.0', DEFAULT_CONFIDENCE_LEVEL_PERCENT);
  LineChk.Checked := false;
  MeansChk.Checked := false;
  ConfChk.Checked := false;
  VarList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  FChartFrame.Clear;
  FReportFrame.Clear;
  UpdateBtnStates;
end;


procedure TPlotXYFrm.ResetBtnClick(Sender: TObject);
begin
  Reset;
end;


procedure TPlotXYFrm.XinBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (XEdit.Text = '') then
  begin
    XEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TPlotXYFrm.XOutBtnClick(Sender: TObject);
begin
  if XEdit.Text <> '' then
  begin
    VarList.Items.Add(XEdit.Text);
    XEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TPlotXYFrm.YInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (YEdit.Text = '') then
  begin
    YEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TPlotXYFrm.YOutBtnClick(Sender: TObject);
begin
  if YEdit.Text <> '' then
  begin
    VarList.Items.Add(YEdit.Text);
    YEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TPlotXYFrm.ComputeBtnClick(Sender: TObject);
var
  Xmin, Xmax, Ymin, Ymax, SSx, SSY, t, DF: double;
  Xmean, Ymean, Xvariance, Yvariance, Xstddev, Ystddev, ConfBand: double;
  X, Y, R, SEPred, Slope, Intercept, predicted, sedata: double;
  i: integer;
  Xcol, Ycol, N, NoSelected: integer;
  Xpoints: DblDyneVec = nil;
  Ypoints: DblDyneVec = nil;
  UpConf: DblDyneVec = nil;
  lowConf: DblDyneVec = nil;
  cellstring: string;
  ColNoSelected: IntDyneVec= nil;
  C: TWinControl;
  msg: String;
  lReport: TStrings;
begin
  SetLength(Xpoints, NoCases);
  SetLength(Ypoints, NoCases);
  SetLength(UpConf, NoCases);
  SetLength(lowConf, NoCases);
  SetLength(ColNoSelected, NoVariables);

  Xcol := 0;
  Ycol := 0;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if cellstring = XEdit.Text then Xcol := i;
    if cellstring = YEdit.Text then Ycol := i;
  end;

  // Validation
  if not Validate(msg, C, Xcol, Ycol) then
  begin
    C.SetFocus;
    ErrorMsg(msg);
    ModalResult := mrNone;
    exit;
  end;

  NoSelected := 2;
  ColNoSelected[0] := Xcol;
  ColNoSelected[1] := Ycol;
  Xmax := -Infinity;
  Xmin := Infinity;
  Ymax := -Infinity;
  Ymin := Infinity;
  Xmean := 0.0;
  Ymean := 0.0;
  XVariance := 0.0;
  YVariance := 0.0;
  SSX := 0.0;
  SSY := 0.0;
  R := 0.0;

  N := 0;
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i, NoSelected, ColNoSelected) then continue;
    inc(N);
    X := StrToFloat(OS3MainFrm.DataGrid.Cells[Xcol,i]);
    Y := StrToFloat(OS3MainFrm.DataGrid.Cells[Ycol,i]);
    XPoints[N-1] := X;
    YPoints[N-1] := Y;
    XMax := Max(X, XMax);
    XMin := Min(X, XMin);
    YMax := Max(Y, YMax);
    YMin := Min(Y, YMin);
    XMean := XMean + X;
    YMean := YMean + Y;
    SSX := SSX + sqr(X);
    SSY := SSY + sqr(Y);
    R := R + X * Y;
  end;

  if N < 1 then
  begin
    ErrorMsg('No data values.');
    exit;
  end;

  // Trim array lengths
  SetLength(Xpoints, NoCases);
  SetLength(Ypoints, NoCases);
  SetLength(UpConf, NoCases);
  SetLength(lowConf, NoCases);

  // sort on X
  SortOnX(XPoints, YPoints);

  // calculate statistics
  XVariance := SSX - sqr(XMean) / N;
  XVariance := XVariance / (N - 1);
  XStdDev := sqrt(XVariance);

  YVariance := SSY - sqr(YMean) / N;
  YVariance := YVariance / (N - 1);
  YStdDev := sqrt(YVariance);

  R := R - Xmean * Ymean / N;
  R := R / (N - 1);
  R := R / (XStdDev * YStdDev);
  SEPred := sqrt(1.0 - sqr(R)) * YStdDev;
  SEPred := SEPred * sqrt((N - 1) / (N - 2));
  XMean := XMean / N;
  YMean := YMean / N;
  Slope := R * YStdDev / XStdDev;
  Intercept := YMean - Slope * XMean;

  // Now, print the descriptive statistics to the output form if requested
  lReport := TStringList.Create;
  try
    lReport.Add('X vs. Y PLOT');
    lReport.Add('');
    lReport.Add('Data file: %s', [OS3MainFrm.FileNameEdit.Text]);
    lReport.Add('');
    lReport.Add('Variables:');
    lReport.Add('  X: %s', [XEdit.Text]);
    lReport.Add('  Y: %s', [YEdit.Text]);
    lReport.Add('');
    lReport.Add('Variable      Mean    Variance  Std.Dev.');
    lReport.Add('----------  --------  --------  --------');
    lReport.Add('%-10s  %8.2f  %8.2f  %8.2f', [XEdit.Text, XMean, XVariance, XStdDev]);
    lReport.Add('%-10s  %8.2f  %8.2f  %8.2f', [YEdit.Text, YMean, YVariance, YStdDev]);
    lReport.Add('');
    lReport.Add('Regression:');
    lReport.Add('  Correlation:                %8.3f', [R]);
    lReport.Add('  Slope:                      %8.3f', [Slope]);
    lReport.Add('  Intercept:                  %8.3f', [Intercept]);
    lReport.Add('  Standard Error of Estimate: %8.3f', [SEPred]);
    lReport.Add('  Number of good cases:       %8d',   [N]);

    FReportFrame.DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // Get upper and lower confidence points for each X value
  if ConfChk.Checked then
  begin
    ConfBand := StrToFloat(ConfEdit.Text) / 100.0;
    DF := N - 2;
    t := InverseT(ConfBand, DF);
    for i := 0 to N-1 do
    begin
      X := XPoints[i];
      predicted := slope * X + intercept;
      sedata := SEPred * sqrt(1.0 + (1.0 / N) + (sqr(X - XMean) / SSx));
      UpConf[i] := predicted + (t * sedata);
      lowConf[i] := predicted - (t * sedata);
      YMax := Max(YMax, UpConf[i]);
      YMin := Min(YMin, LowConf[i]);
    end;
  end
  else
    ConfBand := 0.0;

  // Plot the values (and optional line and confidence band if elected)
  PlotXY(Xpoints, Ypoints, UpConf, LowConf, XMean, YMean, R, Slope, Intercept);

  // cleanup
  ColNoSelected := nil;
  lowConf := nil;
  UpConf := nil;
  Ypoints := nil;
  Xpoints := nil;
end;


procedure TPlotXYFrm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;


procedure TPlotXYFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  ParamsPanel.Constraints.MinHeight := OptionsGroup.Top + OptionsGroup.Height +
    OptionsGroup.BorderSpacing.Bottom + Bevel1.Height +
    CloseBtn.Height + CloseBtn.BorderSpacing.Top;
  ParamsPanel.Constraints.MinWidth := OptionsGroup.Width * 2 - XInBtn.Width div 2 - XInBtn.BorderSpacing.Left;

  Constraints.MinHeight := ParamsPanel.Constraints.MinHeight + ParamsPanel.BorderSpacing.Around*2;
  Constraints.MinWidth := ParamsPanel.Constraints.MinWidth + 200;
  if Height < Constraints.MinHeight then Height := 1;
  if Width < Constraints.MinWidth then Width := 1;

  Position := poDesigned;
  FAutoSized := True;
end;


procedure TPlotXYFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  FReportFrame := TReportFrame.Create(self);
  FReportFrame.Parent := ReportPage;
  FReportFrame.Align := alClient;

  FChartFrame := TChartFrame.Create(self);
  FChartFrame.Parent := ChartPage;
  FChartFrame.Align := alClient;
  FChartFrame.Chart.Legend.Alignment := laBottomCenter;
  FChartFrame.Chart.Legend.ColumnCount := 3;
  FChartFrame.Chart.Legend.TextFormat := tfHTML;
  FChartFrame.Chart.BottomAxis.Intervals.MaxLength := 80;
  FChartFrame.Chart.BottomAxis.Intervals.MinLength := 30;
  with FChartFrame.Chart.AxisList.Add do
  begin
    Alignment := calRight;
    Marks.Source := TListChartSource.Create(self);
    Marks.Style := smsLabel;
    Grid.Visible := false;
  end;
  with FChartFrame.Chart.AxisList.Add do
  begin
    Alignment := calTop;
    Marks.Source := TListChartSource.Create(self);
    Marks.Style := smsLabel;
    Grid.Visible := false;
  end;
  FChartFrame.ChartToolbar.Transparent := false;
  FChartFrame.ChartToolbar.Color := clForm;

  Reset;
end;


procedure TPlotXYFrm.PlotXY(XPoints, YPoints, UpConf, LowConf: DblDyneVec;
  XMean, YMean, R, Slope, Intercept: Double);
var
  tmpX, tmpY: array[0..1] of Double;
  xmin, xmax, ymin, ymax: Double;
  rightLabels: TListChartSource;
  topLabels: TListChartSource;
  ser: TChartSeries;
begin
  rightLabels := FChartFrame.Chart.AxisList[2].Marks.Source as TListChartSource;
  rightLabels.Clear;
  topLabels := FChartFrame.Chart.AxisList[3].Marks.Source as TListChartSource;
  topLabels.Clear;
  FChartFrame.Clear;

  // Titles
  FChartFrame.SetTitle('X vs. Y plot using file ' + OS3MainFrm.FileNameEdit.Text);
  FChartFrame.SetFooter(Format('R(X,Y) = %.3f, Slope = %.3f, Intercept = %.3f', [
    R, Slope, Intercept
  ]));
  FChartFrame.SetXTitle(XEdit.Text);
  FChartFrame.SetYTitle(YEdit.Text);

  // Draw upper confidence band
  if ConfChk.Checked then
  begin
    ser := FChartFrame.PlotXY(ptLines, XPoints, UpConf, nil, nil, 'Upper confidence band', clRed);
    rightLabels.Add(ser.yValue[ser.Count-1], ser.YValue[ser.Count-1], 'UCL');
  end;

  // Plot data points
  FChartFrame.PlotXY(ptSymbols, XPoints, YPoints, nil, nil, 'Data values', clNavy);

  // Draw lower confidence band
  if ConfChk.Checked then
  begin
    ser := FChartFrame.PlotXY(ptLines, XPoints, LowConf, nil, nil, 'Lower confidence band', clRed);
    rightLabels.Add(ser.yValue[ser.Count-1], ser.YValue[ser.Count-1], 'LCL');
  end;

  FChartFrame.Chart.Prepare;
  FChartFrame.GetXRange(xmin, xmax, false);
  FChartFrame.GetYRange(ymin, ymax, false);

  // Draw means
  if MeansChk.Checked then
  begin
    FChartFrame.VertLine(XMean, clGreen, psDashDot, 'Mean ' + XEdit.Text);
    topLabels.Add(XMean, XMean, 'Mean ' + XEdit.Text);
    FChartFrame.HorLine(YMean, clGreen, psDash, 'Mean ' + YEdit.Text);
    rightLabels.Add(YMean, YMean, 'Mean ' + YEdit.Text);
  end;

  // Draw regression line
  if LineChk.Checked then
  begin
    tmpX[0] := xmin;    tmpY[0] := tmpX[0] * slope + intercept;
    tmpX[1] := xmax;    tmpY[1] := tmpX[1] * slope + intercept;
    ser := FChartFrame.PlotXY(ptLines, tmpX, tmpY, nil, nil, 'Predicted', clBlack);
    rightLabels.Add(tmpY[1], tmpY[1], 'Predicted');
  end;

  FChartFrame.Chart.Legend.Visible := false;
end;


procedure TPlotXYFrm.UpdateBtnStates;
begin
  XinBtn.Enabled := (VarList.ItemIndex > -1) and (XEdit.Text = '');
  XoutBtn.Enabled := (XEdit.Text <> '');
  YinBtn.Enabled := (VarList.ItemIndex > -1) and (YEdit.Text = '');
  YoutBtn.Enabled := (YEdit.Text <> '');
end;


function TPlotXYFrm.Validate(out AMsg: String; out AControl: TWinControl;
  Xcol, Ycol: Integer): Boolean;
begin
  Result := false;

  if (Xcol = 0) then
  begin
    AControl := XEdit;
    AMsg := 'No case selected for X.';
    exit;
  end;

  if (Ycol = 0) then
  begin
    AControl := YEdit;
    AMsg := 'No case selected for Y.';
    exit;
  end;
  Result := true;
end;


procedure TPlotXYFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


end.

