// Use file "cansas.laz" for testing

unit PlotXYUnit;

{$mode objfpc}{$H+}
{$I ../../../LazStats.inc}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, OutputUnit, FunctionsLib, DataProcs;

type

  { TPlotXYFrm }

  TPlotXYFrm = class(TForm)
    Bevel1: TBevel;
    ConfEdit: TEdit;
    Label4: TLabel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DescChk: TCheckBox;
    LineChk: TCheckBox;
    MeansChk: TCheckBox;
    ConfChk: TCheckBox;
    GroupBox1: TGroupBox;
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
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure XinBtnClick(Sender: TObject);
    procedure XOutBtnClick(Sender: TObject);
    procedure YInBtnClick(Sender: TObject);
    procedure YOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    {$IFDEF USE_TACHART}
    function PlotXY(XPoints, YPoints, UpConf, LowConf: DblDyneVec;
      XMean, YMean, R, Slope, Intercept: Double): Boolean;
    {$ELSE}
    function PlotXY(XPoints, YPoints, UpConf, LowConf: DblDyneVec;
      XMean, YMean, R, Slope, Intercept, XMax, XMin, YMax, YMin: Double;
      N: Integer): Boolean;
    {$ENDIF}
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
  {$IFDEF USE_TACHART}
  TAChartUtils,
  ChartFrameUnit, ChartUnit,
  {$ELSE}
  BlankFrmUnit,
  {$ENDIF}
  Math, Utils;


{ TPlotXYFrm }

procedure TPlotXYfrm.Reset;
var
  i: integer;
begin
  XEdit.Text := '';
  YEdit.Text := '';
  ConfEdit.Text := FormatFloat('0.0', DEFAULT_CONFIDENCE_LEVEL_PERCENT);
  DescChk.Checked := false;
  LineChk.Checked := false;
  MeansChk.Checked := false;
  ConfChk.Checked := false;
  VarList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
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
  X, Y, R, temp, SEPred, Slope, Intercept, predicted, sedata: double;
  i, j: integer;
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
  if DescChk.Checked then
  begin
    lReport := TStringList.Create;
    try
      lReport.Add('X vs. Y PLOT');
      lReport.Add('');
      lReport.Add('X = %s, Y = %s from file: %s', [XEdit.Text, YEdit.Text, OS3MainFrm.FileNameEdit.Text]);
      lReport.Add('');
      lReport.Add('Variable     Mean   Variance  Std.Dev.');
      lReport.Add('%-10s%8.2f  %8.2f  %8.2f', [XEdit.Text, XMean, XVariance, XStdDev]);
      lReport.Add('%-10s%8.2f  %8.2f  %8.2f', [YEdit.Text, YMean, YVariance, YStdDev]);
      lReport.Add('');
      lReport.Add('Correlation:                %8.3f', [R]);
      lReport.Add('Slope:                      %8.3f', [Slope]);
      lReport.Add('Intercept:                  %8.3f', [Intercept]);
      lReport.Add('Standard Error of Estimate: %8.3f', [SEPred]);
      lReport.Add('Number of good cases:       %8d',   [N]);

      DisplayReport(lReport);
    finally
      lReport.Free;
    end;
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
  PlotXY(
    Xpoints, Ypoints, UpConf, LowConf, XMean, YMean, R, Slope, Intercept
    {$IFNDEF USE_TACHART},Xmax, Xmin, Ymax, Ymin, N{$ENDIF}
  );

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

  VarList.Constraints.MinHeight := GroupBox1.Top + GroupBox1.Height - VarList.Top;
  VarList.Constraints.MinWidth := GroupBox1.Width;

  Constraints.MinWidth := GroupBox1.Width * 2 + XInBtn.Width + 4 * VarList.BorderSpacing.Left;
  Constraints.MinHeight := Height;

  Position := poDesigned;
  FAutoSized := True;
end;


procedure TPlotXYFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  Reset;
end;


{$IFDEF USE_TACHART}
function TPlotXYFrm.PlotXY(XPoints, YPoints, UpConf, LowConf: DblDyneVec;
  XMean, YMean, R, Slope, Intercept: Double): boolean;
var
  tmpX, tmpY: DblDyneVec;
  ext: TDoubleRect;
  xmin, xmax, ymin, ymax: Double;
begin
  if ChartForm = nil then
    ChartForm := TChartForm.Create(Application)
  else
    ChartForm.Clear;

  // Titles
  ChartForm.SetTitle('X vs. Y plot using file ' + OS3MainFrm.FileNameEdit.Text);
  ChartForm.SetFooter(Format('R(X,Y) = %.3f, Slope = %.3f, Intercept = %.3f', [
    R, Slope, Intercept
  ]));
  ChartForm.SetXTitle(XEdit.Text);
  ChartForm.SetYTitle(YEdit.Text);

  // Draw upper confidence band
  if ConfChk.Checked then
    ChartForm.PlotXY(ptLines, XPoints, UpConf, nil, nil, 'Upper confidence band', clRed);

  // Plot data points
  ChartForm.PlotXY(ptSymbols, XPoints, YPoints, nil, nil, 'Data values', clNavy);

  // Draw lower confidence band
  if ConfChk.Checked then
    ChartForm.PlotXY(ptLines, XPoints, LowConf, nil, nil, 'Lower confidence band', clRed);

  ChartForm.Chart.Prepare;
  ChartForm.GetXRange(xmin, xmax, false);
  ChartForm.GetYRange(ymin, ymax, false);

  // Draw means
  if MeansChk.Checked then
  begin
    ChartForm.HorLine(YMean, clGreen, psDash, 'Mean ' + YEdit.Text);
    ChartForm.VertLine(XMean, clGreen, psDashDot, 'Mean ' + XEdit.Text);
  end;

  // Draw regression line
  if LineChk.Checked then
  begin
    SetLength(tmpX, 2);
    SetLengtH(tmpY, 2);
    tmpX[0] := xmin;    tmpY[0] := tmpX[0] * slope + intercept;
    tmpX[1] := xmax;    tmpY[1] := tmpX[1] * slope + intercept;
    ChartForm.PlotXY(ptLines, tmpX, tmpY, nil, nil, 'Predicted', clBlack);
  end;

  // Show chart
  Result := ChartForm.ShowModal <> mrClose;
end;
{$ELSE}
function TPlotXYFrm.PlotXY(XPoints, YPoints, UpConf, LowConf: DblDyneVec;
  {ConfBand, }XMean, YMean, R, Slope, Intercept, XMax, XMin, YMax, YMin: Double;
  N: Integer): Boolean;
var
   i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
   vhi, hwide, offset, strhi, imagehi : integer;
   valincr, Yvalue, Xvalue : double;
   Title : string;

begin
  if BlankFrm = nil then Application.CreateForm(TBlankFrm, BlankFrm);

  BlankFrm.Image1.Canvas.Clear;
  BlankFrm.Show;

  Title := 'X versus Y PLOT Using File: ' + OS3MainFrm.FileNameEdit.Text;
  BlankFrm.Caption := Title;

  imagewide := BlankFrm.Image1.Width;
  imagehi := BlankFrm.Image1.Height;
  vtop := 20;
  vbottom := round(imagehi) - 80;
  vhi := vbottom - vtop;
  hleft := 100;
  hright := imagewide - 80;
  hwide := hright - hleft;
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;

  // Draw chart border
  BlankFrm.Image1.Canvas.Rectangle(0,0,imagewide,imagehi);

  // draw Means
  if MeansChk.Checked then
  begin
    ypos := round(vhi * ( (Ymax - Ymean) / (Ymax - Ymin)));
    ypos := ypos + vtop;
    xpos := hleft;
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    xpos := hright;
    BlankFrm.Image1.Canvas.Pen.Color := clGreen;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
    Title := 'MEAN ' + YEdit.Text;
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    ypos := ypos - strhi div 2;
    BlankFrm.Image1.Canvas.Brush.Color := clWhite;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

    xpos := round(hwide * ( (Xmean - Xmin) / (Xmax - Xmin)));
    xpos := xpos + hleft;
    ypos := vtop;
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    ypos := vbottom;
    BlankFrm.Image1.Canvas.Pen.Color := clGreen;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
    Title := 'MEAN ' + XEdit.Text;
    strhi := BlankFrm.Image1.Canvas.TextWidth(Title);
    xpos := xpos - strhi div 2;
    ypos := vtop - BlankFrm.Image1.Canvas.TextHeight(Title);
    BlankFrm.Image1.Canvas.Brush.Color := clWhite;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
  end;

  // draw slope line
  if LineChk.Checked then
  begin
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    Yvalue := (Xpoints[0] * slope) + intercept; // predicted score
    ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
    ypos := ypos + vtop;
    xpos := round(hwide * ( (Xpoints[0]- Xmin) / (Xmax - Xmin)));
    xpos := xpos + hleft;
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);

    Yvalue := (Xpoints[N-1] * slope) + intercept; // predicted score
    ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
    ypos := ypos + vtop;
    xpos := round(hwide * ( (Xpoints[N-1] - Xmin) / (Xmax - Xmin)));
    xpos := xpos + hleft;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
  end;

  // draw horizontal axis
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.MoveTo(hleft,vbottom);
  BlankFrm.Image1.Canvas.LineTo(hright,vbottom);
  valincr := (Xmax - Xmin) / 10.0;
  for i := 1 to 11 do
  begin
    ypos := vbottom;
    Xvalue := Xmin + valincr * (i - 1);
    xpos := round(hwide * ((Xvalue - Xmin) / (Xmax - Xmin)));
    xpos := xpos + hleft;
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    ypos := ypos + 10;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
    Title := format('%.2f',[Xvalue]);
    offset := BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
    xpos := xpos - offset;
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
  end;
  xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(XEdit.Text) div 2);
  ypos := vbottom + 20;
  BlankFrm.Image1.Canvas.TextOut(xpos,ypos,XEdit.Text);
  Title := format('R(X,Y) = %5.3f, Slope = %6.2f, Intercept = %6.2f', [
    R, Slope, Intercept
  ]);
  xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(Title) div 2);
  ypos := ypos + 15;
  BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

  // Draw vertical axis
  Title := YEdit.Text;
  xpos := hleft - BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
  ypos := vtop - BlankFrm.Image1.Canvas.TextHeight(Title);
  BlankFrm.Image1.Canvas.TextOut(xpos,ypos,YEdit.Text);
  xpos := hleft;
  ypos := vtop;
  BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
  ypos := vbottom;
  BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
  valincr := (Ymax - Ymin) / 10.0;
  for i := 1 to 11 do
  begin
    Title := format('%8.2f',[Ymax - ((i-1)*valincr)]);
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    xpos := 10;
    Yvalue := Ymax - (valincr * (i-1));
    ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
    ypos := ypos + vtop - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
    xpos := hleft;
    ypos := ypos + strhi div 2;
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    xpos := hleft - 10;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
  end;

  // draw points for x and y pairs
  for i := 0 to N-1 do
  begin
    ypos := round(vhi * ( (Ymax - Ypoints[i]) / (Ymax - Ymin)));
    ypos := ypos + vtop;
    xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
    xpos := xpos + hleft;
    BlankFrm.Image1.Canvas.Brush.Color := clNavy;
    BlankFrm.Image1.Canvas.Brush.Style := bsSolid;
    BlankFrm.Image1.Canvas.Pen.Color := clNavy;
    BlankFrm.Image1.Canvas.Ellipse(xpos,ypos,xpos+5,ypos+5);
  end;

  // draw confidence bands if requested
//     if ConfBand <> 0.0 then
  if ConfChk.Checked  then
  begin
    BlankFrm.Image1.Canvas.Pen.Color := clRed;
    ypos := round(vhi * ((Ymax - UpConf[0]) / (Ymax - Ymin)));
    ypos := ypos + vtop;
    xpos := round(hwide * ( (Xpoints[0] - Xmin) / (Xmax - Xmin)));
    xpos := xpos + hleft;
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    for i := 1 to N-1 do
    begin
      ypos := round(vhi * ((Ymax - UpConf[i]) / (Ymax - Ymin)));
      ypos := ypos + vtop;
      xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
    end;
    ypos := round(vhi * ((Ymax - lowConf[0]) / (Ymax - Ymin)));
    ypos := ypos + vtop;
    xpos := round(hwide * ( (Xpoints[0] - Xmin) / (Xmax - Xmin)));
    xpos := xpos + hleft;
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    for i := 1 to N-1 do
    begin
      ypos := round(vhi * ((Ymax - lowConf[i]) / (Ymax - Ymin)));
      ypos := ypos + vtop;
      xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
    end;
  end;
end;
{$ENDIF}


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

