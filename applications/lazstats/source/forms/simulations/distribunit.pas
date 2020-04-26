// Testing: no file needed
//
// Test input parameters:
// - F distribution: DF1 = 3, DF2 = 20

unit DistribUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Printers, ExtCtrls, Math,
  BlankFrmUnit, FunctionsLib, Globals;

  type
    TwoCol = array[1..2, 1..100] of double;

type

  { TDistribFrm }

  TDistribFrm = class(TForm)
    AlphaEdit: TEdit;
    Bevel1: TBevel;
    ChiChk: TRadioButton;
    DF1Edit: TEdit;
    DF2Edit: TEdit;
    FChk: TRadioButton;
    MeanEdit: TEdit;
    NDChk: TRadioButton;
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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NDChkClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    procedure NDPlot;
    procedure ChiPlot;
    procedure FPlot;
    procedure HScale(Xmin, Xmax: double; NSteps: integer; AColor: TColor;
      FontSize: integer; X, Y, XLength: integer; CharLabel: string);
    procedure VScale(Ymin, Ymax: double; NSteps: integer; AColor: TColor;
      FontSize: integer; X, Y, YLength: integer; CharLabel: string);
    procedure NormPts(zMin, zMax: double; NPts: integer; var RealPts: TwoCol);
    procedure PltPts(RealPts: TwoCol; XMax, XMin, YMax, YMin: double;
      Npts, XAxisStart, YAxisStart, XAxisRange, YAxisRange: integer; AColor: TColor);
    procedure ChiPts(cMin, cMax: double; NPts, DF: integer; var RealPts: TwoCol);
    procedure FPts(FMin, FMax: double; NPts, DF1, DF2: integer; var RealPts: TwoCol);
    function Chi2Func(chisqr, df: double): double;
    function FFunc(F: double; DF1, DF2: integer): double;

    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  DistribFrm: TDistribFrm;

implementation

{ TDistribFrm }

procedure TDistribFrm.ResetBtnClick(Sender: TObject);
begin
  NDChk.Checked := false;
  ChiChk.Checked := false;
  FChk.Checked := false;
  AlphaEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  DF1Edit.Text := '';
  DF2Edit.Text := '';
  MeanEdit.Text := '';
  GroupBox2.Enabled := false;
end;

procedure TDistribFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
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

procedure TDistribFrm.NDPlot;
var
  CharLabel: string;
  Clwidth, Clheight,X, Y, XAxisStart, XAxisEnd, YAxisStart, YAxisEnd: integer;
  i, Xrange, Yrange, t: integer;
  alpha, h, z, hprop, zprop: double;
  RealPts: TwoCol;
begin
  for i := 1 to 100 do realpts[1,i] := 0.0;
  for i := 1 to 100 do realpts[2,i] := 0.0;

  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Clear;
  BlankFrm.Image1.Canvas.FloodFill(1,1,clWhite,fsborder);
  BlankFrm.Image1.Canvas.Pen.Width := 2;
  Clwidth :=  BlankFrm.Image1.Width;
  Clheight := BlankFrm.Image1.Height;

  XAxisStart := Clwidth div 8;
  XAxisEnd := Clwidth - Clwidth div 8;
  YAxisStart := (Clheight * 7) div 10;
  YAxisEnd := Clheight div 10;
  XRange := XAxisEnd - XAxisStart;
  YRange := YAxisStart - YAxisEnd;
  alpha := StrToFloat(AlphaEdit.Text);

  BlankFrm.Show;

  // Create values of normal curve
  NormPts(-4.0, 4.0, 100, RealPts);
  PltPts(RealPts, 4.0, -4.0, 0.5, 0.0, 100, XAxisStart, YAxisStart, XRange, YRange, clBlack);

  // Draw line for alpha z := 1.645
  CharLabel := 'Normal Distribution. Alpha: ' + AlphaEdit.Text;
  BlankFrm.Caption := CharLabel;
  z := inversez(1.0 - alpha);
  zprop := (4.0 + z) / 8.0;
  h := (1.0 / sqrt(2.0 * 3.1415)) * (1.0 / exp(z * z / 2.0));
  hprop := (0.5 - h) / 0.5;
  X := round(zprop * XRange) + XAxisStart;
  Y := YAxisEnd + round(hprop * YRange);
  BlankFrm.Image1.Canvas.MoveTo(X, YAxisStart);
  BlankFrm.Image1.Canvas.LineTo(X, Y-10); // alpha cutoff

  // floodfill rejection section with red
  BlankFrm.Image1.Canvas.Brush.Color := clRed;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;

  // create labeled axis
  HScale(-4.0, 4.0, 11, clWhite, 10, XAxisStart, YAxisStart, XRange, 'z SCALE');
  VScale(0.0, 0.5, 11, clWhite, 10, XAxisStart, YAxisStart, YRange, 'DENSITY');

  // Print Heading
  t := BlankFrm.Image1.Canvas.TextWidth(CharLabel);
  X := (BlankFrm.Width - t) div 2;
  BlankFrm.Image1.Canvas.TextOut(X, 0, charLabel);
  CharLabel := 'Critical Value: ' + Format('%.3f',[z]);
  t := BlankFrm.Image1.Canvas.TextWidth(charLabel);
  X := (BlankFrm.Image1.Width - t) div 2;
  Y := BlankFrm.Image1.Canvas.TextHeight(CharLabel);
  BlankFrm.Image1.Canvas.TextOut(X, Y, CharLabel);
end;

procedure TDistribFrm.ChiPlot;
var
  charLabel: string;
  ClWidth, ClHeight, X, Y, XAxisStart, XAxisEnd, YAxisStart, YAxisEnd: integer;
  i, Xrange, Yrange, df, t: integer;
  alpha, h, z, hprop, zprop, MaxChi, MaxProb: double;
  RealPts: TwoCol;
begin
  for i := 1 to 100 do realpts[1,i] := 0.0;
  for i := 1 to 100 do realpts[2,i] := 0.0;

  MaxProb := 0.0;
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Clear;
  BlankFrm.Image1.Canvas.FloodFill(1, 1, clWhite, fsBorder);
  BlankFrm.Image1.Canvas.Pen.Width := 2;
  ClWidth :=  BlankFrm.Image1.Width;
  ClHeight := BlankFrm.Image1.Height;

  XAxisStart := ClWidth div 8;
  XAxisEnd := ClWidth - ClWidth div 8;
  YAxisStart := (ClHeight * 7) div 10;
  YAxisEnd := ClHeight div 10;
  XRange := XAxisEnd - XAxisStart;
  YRange := YAxisStart - YAxisEnd;
  alpha := StrToFloat(AlphaEdit.Text);
  charLabel := 'Chi Squared Distribution. Alpha: ' + AlphaEdit.Text;
  df := StrToInt(DF1Edit.Text);
  if (df < 1) or (df > 100) then
    exit;

  charLabel := charLabel + ' D.F.: ' + DF1Edit.Text;
  BlankFrm.Caption := charLabel;
  BlankFrm.Show;

  // Create values of chi-squared curve
  MaxChi := 125.0;
  ChiPts(0.0, MaxChi, 100, df, realpts);
  for i := 1 to 100 do
    if (RealPts[2,i] > MaxProb) then
      MaxProb := RealPts[2,i];
  PltPts(RealPts, MaxChi, 0.0, MaxProb, 0.0, 100, XAxisStart, YAxisStart, XRange, YRange, clBlack);

  // Draw line for alpha
  z := InverseChi(1.0-alpha, df);
  zprop := z / MaxChi;
  h := Chi2Func(z, df);
  hprop := (MaxProb - h) / MaxProb;
  X := round(zprop * Xrange) + XaxisStart;
  Y := YaxisEnd + round(hprop * Yrange);
  BlankFrm.Image1.Canvas.MoveTo(X, YaxisStart);
  BlankFrm.Image1.Canvas.LineTo(X, Y); // alpha cutoff

  // floodfill main section with blue
  BlankFrm.Image1.Canvas.Brush.Color := clBlue;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;

  // create charLabeled axis
  HScale(0.0, MaxChi, 11, clWhite, 10, XAxisStart, YAxisStart, XRange, 'CHI SQUARED SCALE');
  VScale(0.0, MaxProb, 11, clWhite, 10, XAxisStart, YAxisStart, YRange, 'DENSITY');

  // Print Heading
  t := BlankFrm.Image1.Canvas.TextWidth(CharLabel);
  X := (BlankFrm.Width - t) div 2;
  BlankFrm.Image1.Canvas.TextOut(X,0,CharLabel);

  CharLabel := 'Critical Value: ' + Format('%6.3f',[z]);
  t := BlankFrm.Image1.Canvas.TextWidth(CharLabel);
  X := (BlankFrm.Image1.Width - t) div 2;
  Y := BlankFrm.Image1.Canvas.TextHeight(CharLabel);
  BlankFrm.Image1.Canvas.TextOut(X, Y, CharLabel);
end;

procedure TDistribFrm.FPlot;
var
  CharLabel: string;
  ClWidth, ClHeight, X, Y, XAxisStart, XAxisEnd, YAxisStart, YAxisEnd: integer;
  i, Xrange, Yrange, t, df1, df2: integer;
  RealPts: TwoCol;
  alpha, h, F, hprop, Fprop, MaxProb, MaxF: double;
  done: boolean;
begin
  for i := 1 to 100 do
  begin
    realpts[1,i] := 0.0;
    realpts[2,i] := 0.0;
  end;

  MaxProb := 0.0;
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Clear;
  BlankFrm.Image1.Canvas.FloodFill(1,1,clWhite,fsborder);
  BlankFrm.Image1.Canvas.Pen.Width := 2;
  ClWidth :=  BlankFrm.Image1.Width;
  ClHeight := BlankFrm.Image1.Height;
  XAxisStart := ClWidth div 8;
  XAxisEnd := ClWidth - ClWidth div 8;
  YAxisStart := (ClHeight * 7) div 10;
  YAxisEnd := ClHeight div 10;
  XRange := XAxisEnd - XAxisStart;
  YRange := YAxisStart - YAxisEnd;

  alpha := StrToFloat(AlphaEdit.Text);
  charLabel := 'F Distribution. Alpha: ' + AlphaEdit.Text;
  df1 := StrToInt(DF1Edit.Text);
  CharLabel := CharLabel + ',  D.F.1: ';
  CharLabel := CharLabel + DF1Edit.Text;
  df2 := StrToInt(DF2Edit.Text);
  CharLabel := CharLabel + ', D.F.2: ';
  CharLabel := CharLabel + DF2Edit.Text;
  BlankFrm.Caption := CharLabel;
  BlankFrm.Show;

  // Create values of F curve
  MaxF := 20.0;
  done := false;
  while not done do
  begin
    h := Ffunc(MaxF, df1, df2);
    if h < 0.001  then
      MaxF := MaxF - 1.0
    else
      done := true;
  end;

  FPts(0.0, MaxF, 100, df1, df2, RealPts);
  for i := 1 to 100 do
    if (RealPts[2,i] > MaxProb) then
      MaxProb := RealPts[2,i];
  PltPts(RealPts, MaxF, 0.0, MaxProb, 0.0, 100, XAxisStart, YAxisStart, XRange, YRange, clBlack);

  // Draw line for alpha
  F := FPercentPoint(1.0-alpha, df1, df2);
  Fprop := F / MaxF;
  h := Ffunc(F, df1, df2);
  hprop := (MaxProb - h) / MaxProb;
  X := round(Fprop * XRange) + XAxisStart;
  Y := YAxisEnd + round(hprop * YRange);
  BlankFrm.Image1.Canvas.MoveTo(X, YAxisStart);
  BlankFrm.Image1.Canvas.LineTo(X, Y); // alpha cutoff

  // floodfill main section with blue
  BlankFrm.Canvas.Brush.Color := clBlue;

  // create charLabeled axis
  HScale(0.0, MaxF, 11, clWhite, 10, XAxisStart, YAxisStart, XRange, 'F SCALE');
  VScale(0.0, MaxProb, 11, clWhite, 10, XAxisStart, YAxisStart, YRange, 'DENSITY');

  // Print Heading
  t := BlankFrm.Image1.Canvas.TextWidth(CharLabel);
  X := (BlankFrm.Image1.Width - t) div 2;
  BlankFrm.Image1.Canvas.TextOut(X, 0, CharLabel);
  charLabel := 'Critical Value: ' + Format('%.3f', [F]);
  t := BlankFrm.Image1.Canvas.TextWidth(charLabel);
  X := (BlankFrm.Image1.Width - t) div 2;
  Y := BlankFrm.Image1.Canvas.TextHeight(CharLabel);
  BlankFrm.Image1.Canvas.TextOut(X, Y, CharLabel);
end;

procedure TDistribFrm.HScale(XMin, XMax: double; Nsteps: integer;
  AColor: TColor; FontSize: integer; X, Y, XLength: integer; CharLabel: string);
var
  i, TickEnd, Xpos, Ypos, TextX: integer;
  Xincr, Xval: double;
begin
  BlankFrm.Image1.Canvas.MoveTo(X,Y);
  BlankFrm.Image1.Canvas.LineTo(X+Xlength,Y);
  BlankFrm.Image1.Canvas.Font.Size := FontSize;
  BlankFrm.Image1.Canvas.Brush.Color := AColor;
  TickEnd := Y + 10;
  Xincr := (Xmax - Xmin) / Nsteps;
  for i := 0 to Nsteps do
  begin
    XPos := round(Xlength/Nsteps*i + X);
    BlankFrm.Image1.Canvas.MoveTo(XPos, Y);
    BlankFrm.Image1.Canvas.LineTo(XPos, TickEnd);
    TextX := XPos - 8;
    Xval := Xmin + i*Xincr;
    BlankFrm.Image1.Canvas.TextOut(TextX, Y+15, Format('%.2f', [Xval]));
  end;

  // print charLabel below X axis
  YPos := Y + 30;
  XPos := round((BlankFrm.Width / 2) - (BlankFrm.Image1.Canvas.TextWidth(CharLabel) / 2));
  BlankFrm.Image1.Canvas.TextOut(Xpos, Ypos, CharLabel);
end;

procedure TDistribFrm.VScale(YMin, YMax: double; NSteps: integer;
  AColor: TColor; FontSize: integer; X, Y, YLength: integer; CharLabel: string);
var
  TickEnd, Ypos, Xpos, TextY: integer;
  Yincr, Yval: double;
  chpixs, i: integer;
begin
  BlankFrm.Image1.Canvas.MoveTo(X,Y);
  BlankFrm.Image1.Canvas.LineTo(X,Y-Ylength);
  BlankFrm.Image1.Canvas.Font.Size := FontSize;
  BlankFrm.Image1.Canvas.Brush.Color := AColor;

  TickEnd := X - 10;
  Yincr := (YMax - YMin) / Nsteps;
  TextY := 0;
  for i := 0 to NSteps do
  begin
    YPos := round(Y - Ylength / NSteps * i);
    BlankFrm.Image1.Canvas.MoveTo(X, YPos);
    BlankFrm.Image1.Canvas.LineTo(TickEnd, YPos);
    TextY := TickEnd - 30;
    Yval := Ymin + i * Yincr;
    BlankFrm.Image1.Canvas.TextOut(TextY, Ypos-8, Format('%.2f', [Yval]));
  end;

  // print charLabel vertically
  chpixs := BlankFrm.Image1.Canvas.TextHeight(CharLabel);
  XPos := TextY - 15;
  for i := 1 to Length(CharLabel) do
  begin
    YPos := round(Y - YLength / 2 - Length(charLabel) * chpixs / 2 + chpixs*i);
    BlankFrm.Image1.Canvas.TextOut(XPos, YPos, CharLabel[i]);
  end;
end;

procedure TDistribFrm.NormPts(zMin, zMax: double; NPts: integer;
  var RealPts: TwoCol);
var
  zIncr, z, h: double;
  i: integer;
begin
  zIncr := (zMax - zMin) / Npts;
  for i := 1 to Npts do
  begin
    z := zMin + (zIncr * i);
    h := (1.0 / sqrt(2.0 * PI)) * (1.0 / exp(z * z / 2.0));
    RealPts[1, i] := z;
    RealPts[2, i] := h;
  end;
end;

procedure TDistribFrm.PltPts(RealPts: TwoCol; Xmax, Xmin, Ymax, Ymin: double;
  NPts, XAxisStart, YAxisStart, XAxisRange, YAxisRange: integer; AColor: TColor);
var
  hprop, zprop, z, h: double;
  i, X, Y: integer;
  intpts: array[1..100] of TPoint;
begin
  for i := 1 to NPts do
  begin
    z := RealPts[1,i];
    h := RealPts[2,i];
    zprop := (z - XMin) / (XMax - XMin);
    X := round(zprop * XAxisRange + XAxisStart);
    hprop := (h - Ymin) / (Ymax - Ymin);
    Y := round(YAxisStart - hprop * YAxisRange);
    intpts[i] := Point(X, Y);
  end;
  BlankFrm.Image1.Canvas.Pen.Color := AColor;
  BlankFrm.Image1.Canvas.Polyline(Slice(intpts, Npts - 1));
end;

procedure TDistribFrm.ChiPts(cMin, cMax: double; NPts, DF: integer;
  var RealPts: TwoCol);
var
  ratio1, ratio2, ratio3, cIncr, chi, h: double;
  i: integer;
begin
  ratio1 := DF / 2.0;
  ratio2 := (DF - 2.0) / 2.0;
  cIncr := (cMax - cMin) / NPts;
  for i := 1 to NPts do
  begin
    chi := cMin + cIncr*i;
//         h := inversechi(chi, df);
    ratio3 := chi / 2.0;
    h := (1.0 / (power(2.0, ratio1) * exp(lngamma(ratio1)))) * power(chi, ratio2) * (1.0 / exp(ratio3));
    RealPts[1,i] := chi;
    RealPts[2,i] := h;
  end;
end;

procedure TDistribFrm.FPts(FMin, FMax: double; NPts, DF1, DF2: integer;
  var RealPts: TwoCol);
var
  FIncr, F, h: double;
  i: integer;
begin
  FIncr := (FMax - FMin) / NPts;
  for i := 1 to NPts do
  begin
    F := FMin + FIncr * i;
    h := Ffunc(F, DF1, DF2);
    RealPts[1,i] := F;
    RealPts[2,i] := h;
  end;
end;

function TDistribFrm.Chi2Func(ChiSqr, DF: double): double;
var
  ratio1, ratio2, ratio3: double;
begin
  // Returns the height of the density curve for the chi-squared statistic
  ratio1 := df / 2.0;
  ratio2 := (df - 2.0) / 2.0;
  ratio3 := chisqr / 2.0;
  Result := (1.0 / (power(2.0,ratio1) * exp(lngamma(ratio1)))) * power(chisqr,ratio2) * (1.0 / exp(ratio3));
end;

function TDistribFrm.FFunc(F: double; DF1, DF2: integer): double;
var
  ratio1, ratio2, ratio3, ratio4: double;
  part1, part2, part3, part4, part5, part6, part7, part8, part9: double;
begin
  // Returns the height of the density curve for the F statistic
  ratio1 := (df1 + df2) / 2.0;
  ratio2 := (df1 - 2.0) / 2.0;
  ratio3 := df1 / 2.0;
  ratio4 := df2 / 2.0;
  part1 := exp(lngamma(ratio1));
  part2 := power(df1, ratio3);
  part3 := power(df2, ratio4);
  part4 := exp(lngamma(ratio3));
  part5 := exp(lngamma(ratio4));
  part6 := power(F,ratio2);
  part7 := power((F*df1 + df2), ratio1);
  part8 := (part1 * part2 * part3) / (part4 * part5);
  if (part7 = 0.0) then
    part9 := 0.0
  else
    part9 := part6 / part7;
  Result := part8 * part9;
{
     ratio1 := (df1 + df2) / 2.0;
     ratio2 := (df1 - 2.0) / 2.0;
     ratio3 := df1 / 2.0;
     ratio4 := df2 / 2.0;
     ffunc := ((gamma(ratio1) * realraise(df1,ratio3) *
              realraise(df2,ratio4)) /
              (gamma(ratio3) * gamma(ratio4))) *
              (realraise(f,ratio2) / realraise((f*df1+df2),ratio1));
}
end;

procedure TDistribFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TDistribFrm.FormCreate(Sender: TObject);
begin
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
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

