// No data file needed for testing
//
// Test input:
// - Mean for NULL Hypothesis: 100
// - Mean for alternative Nullhyothesis: 115
// - Standard deviation of the distribution: 15

unit ErrorCurvesUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  BlankFrmUnit, FunctionsLib, Globals;

type
  TwoCol = array[1..2, 1..100] of double;

type

  { TErrorCurvesFrm }

  TErrorCurvesFrm = class(TForm)
    Bevel1: TBevel;
    NullType: TRadioGroup;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    NullMeanEdit: TEdit;
    AltMeanEdit: TEdit;
    SDEdit: TEdit;
    TypeIEdit: TEdit;
    TypeIIEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    procedure PltPts(RealPts: TwoCol; Xmax, Xmin, Ymax, Ymin: double;
      Npts, XAxisStart, YAxisStart, XAxisRange, YAxisRange: integer;
      AColor: TColor);
    procedure Hscale(Xmin, Xmax: double; NSteps: integer; AColor: TColor;
      FontSize: integer; X, Y, XLength: integer; CharLabel: string);
    procedure Vscale(Ymin, Ymax: double; NSteps: integer; AColor: TColor;
      FontSize: integer; X, Y, YLength: integer; CharLabel: string);
    procedure NormPts(zMin, zMax: double; NPts: integer; var RealPts: TwoCol);

  public
    { public declarations }
  end; 

var
  ErrorCurvesFrm: TErrorCurvesFrm;

implementation

uses
  Math;

{ TErrorCurvesFrm }

procedure TErrorCurvesFrm.ResetBtnClick(Sender: TObject);
begin
  NullMeanEdit.Text := '';
  AltMeanEdit.Text := '';
  SDEdit.Text := '';
  TypeIEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  TypeIIEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
end;

procedure TErrorCurvesFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

{ Generate a null and alternate hypothesis for a specified effect size,
  Type I error rate and Type II error rate using the normal distribution z-test.
  Estimate the N needed.
  Uses the Plot.h header file and form FrmPlot. }
procedure TErrorCurvesFrm.ComputeBtnClick(Sender: TObject);
var
  Clwidth, Clheight, X, Y, XaxisStart, XaxisEnd, YaxisStart, YaxisEnd: integer;
  Xrange, Yrange, t, range, Nsize: integer;
  alpha, beta, nullmean, altmean, Diff, StdDev, CriticalX, zalpha: double;
  zbeta, Xprop, stderrmean, xlow, xhigh: double;
  charLabel: string;
  RealPts: TwoCol;
begin
  if NullMeanEdit.Text = '' then
  begin
    NullMeanEdit.SetFocus;
    MessageDlg('Input requred.', mtError, [mbOk], 0);
    exit;
  end;
  if not TryStrToFloat(NullMeanEdit.Text, nullMean) then
  begin
    NullMeanEdit.SetFocus;
    MessageDlg('Valid number required.', mtError, [mbOk], 0);
    exit;
  end;

  if AltMeanEdit.Text = '' then
  begin
    AltMeanEdit.SetFocus;
    MessageDlg('Input requred.', mtError, [mbOk], 0);
    exit;
  end;
  if not TryStrToFloat(AltMeanEdit.Text, altMean) then
  begin
    AltMeanEdit.SetFocus;
    MessageDlg('Valid number required.', mtError, [mbOk], 0);
    exit;
  end;

  if SDEdit.Text = '' then
  begin
    SDEdit.SetFocus;
    MessageDlg('Input requred.', mtError, [mbOk], 0);
    exit;
  end;
  if not TryStrToFloat(SDEdit.Text, StdDev) or (StdDev <= 0) then
  begin
    SDEdit.SetFocus;
    MessageDlg('Valid positive number required.', mtError, [mbOk], 0);
    exit;
  end;

  if TypeIEdit.Text = '' then
  begin
     TypeIEdit.SetFocus;
     MessageDlg('Input required.', mtError, [mbOK], 0);
     exit;
  end;
  if not TryStrToFloat(TypeIEdit.Text, alpha) or (alpha < 0) or (alpha > 1) then
  begin
     TypeIEdit.Setfocus;
     MessageDlg('Valid number required between 0 and 1.', mtError, [mbOK], 0);
     exit;
  end;

  if TypeIIEdit.Text = '' then
  begin
     TypeIIEdit.SetFocus;
     MessageDlg('Input required.', mtError, [mbOK], 0);
     exit;
  end;
  if not TryStrToFloat(TypeIEdit.Text, beta) or (beta < 0) or (beta > 1) then
  begin
     TypeIIEdit.Setfocus;
     MessageDlg('Valid number required between 0 and 1.', mtError, [mbOK], 0);
     exit;
  end;

  BlankFrm.Show;

  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Clear;
  BlankFrm.Image1.Canvas.FloodFill(1,1,clWhite,fsborder);

  if NullType.ItemIndex = 1 then alpha := alpha / 2.0;

  zalpha := InverseZ(1.0 - alpha);
  zbeta := InverseZ(1.0 - beta);
  Diff := abs(nullmean - altmean);
  Nsize := round((StdDev / Diff) * abs(zbeta + zalpha));
  Nsize := Nsize * Nsize;
  CriticalX := zalpha * (StdDev / sqrt(Nsize)) + nullmean;
  stderrmean := StdDev / sqrt(Nsize);

  Clwidth :=  BlankFrm.Image1.Width;
  Clheight := BlankFrm.Image1.Height;

  // Determine X scale and print it
  YaxisStart := (Clheight * 6) div 10;
  YaxisEnd := Clheight div 10;
  Yrange := YaxisStart - YaxisEnd;
  xlow := nullmean - 4 * stderrmean;
  xhigh := altmean + 4 * stderrmean;
  XaxisStart := Clwidth div 8;
  XaxisEnd := Clwidth - (Clwidth div 8);
  Xrange := XaxisEnd - XaxisStart;
  HScale(xlow, xhigh, 9, clWhite, 8, XaxisStart, YaxisStart, Xrange, 'X SCALE');

  // Create values of the alternative distribution
  Xprop := ((nullmean + 4*stderrmean) - xlow) / (xhigh - xlow);
  range := round(Xprop * Xrange);
  NormPts(-4.0, 4.0, 100, realpts{%H-});
  Xprop := ((altmean - 4 * stderrmean) - xlow) / (xhigh - xlow);
  X := round((Xprop * Xrange) + XaxisStart); // where to start curve
  PltPts(realpts, 4.0, -4.0, 0.5, 0.0, 100, X, YaxisStart, range, Yrange, clBlack);

  //Draw vertical axis at the critical X value
  Xprop := (CriticalX - xlow) / (xhigh - xlow);
  X := round((Xprop * Xrange) + XaxisStart);
  Y := YaxisStart;
  BlankFrm.Image1.Canvas.MoveTo(X,Y);
  BlankFrm.Image1.Canvas.LineTo(X,YaxisEnd);
  CharLabel := 'Critical X: ' + Format('%6.2f', [CriticalX]);
  t := BlankFrm.Image1.Canvas.TextWidth(CharLabel) div 2;
  BlankFrm.Image1.Canvas.TextOut(X-t, YaxisEnd-15, CharLabel);

  // floodfill Alternate distribution area with blue
  Xprop := (CriticalX - xlow) / (xhigh - xlow);
  X := round((Xprop * Xrange) + XaxisStart);
  Y := YaxisStart - 3;
  BlankFrm.Image1.Canvas.Brush.Color := clBlue;
  BlankFrm.Image1.Canvas.FloodFill(X-2, Y, clBlack, fsBorder);
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;

  // Create values of normal curve for null distribution
  NormPts(-4.0, 4.0, 100, realpts);
  Xprop := ( (nullmean + 4*stderrmean) - xlow) / (xhigh - xlow);
  range := round(Xprop * Xrange);
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  PltPts(realpts, 4.0, -4.0, 0.5, 0.0, 100, XaxisStart, YaxisStart, range, Yrange, clBlack);

  //Draw vertical axis at null mean
  Xprop := (nullmean - xlow) / (xhigh - xlow);
  X := round((Xprop * Xrange) + XaxisStart);
  Y := YaxisStart;
  BlankFrm.Image1.Canvas.MoveTo(X,Y);
  BlankFrm.Image1.Canvas.LineTo(X,YaxisEnd);
  CharLabel := 'Null Mean';
  t := BlankFrm.Image1.Canvas.TextWidth(charLabel) div 2;
  BlankFrm.Image1.Canvas.TextOut(X-t, YaxisEnd, CharLabel);

  // floodfill alpha area with red
  Xprop := (CriticalX - xlow) / (xhigh - xlow);
  X := round((Xprop * Xrange) + XaxisStart);
  Y := YaxisStart - 3;
  BlankFrm.Image1.Canvas.Brush.Color := clRed;
  BlankFrm.Image1.Canvas.FloodFill(X+2, Y, clBlack, fsBorder);
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;

  //Draw vertical axis at alternative mean
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  Xprop := (altmean - xlow) / (xhigh - xlow);
  X := round((Xprop * Xrange) + XaxisStart);
  Y := YaxisStart;
  BlankFrm.Image1.Canvas.MoveTo(X,Y);
  BlankFrm.Image1.Canvas.LineTo(X,YaxisEnd);
  charLabel := 'Alternative Mean';
  t := BlankFrm.Image1.Canvas.TextWidth(charLabel) div 2;
  BlankFrm.Image1.Canvas.TextOut(X-t,YaxisEnd,charLabel);

  // draw the vertical density axis scale values
  Vscale(0.0, 0.5, 11, clWhite, 10, XaxisStart, YaxisStart, Yrange, 'DENSITY');

  // Print Heading
  CharLabel := 'Type I and II Error Areas';
  BlankFrm.Caption := CharLabel;
  CharLabel := 'Alpha: ' + TypeIEdit.Text + ', Beta: ' + TypeIIEdit.Text + ', N: ' + IntToStr(Nsize);
  t := BlankFrm.Image1.Canvas.TextWidth(CharLabel);
  X := round((BlankFrm.Image1.Width - t) / 2);
  BlankFrm.Image1.Canvas.TextOut(X, 0, CharLabel);

  // print z scale for the null distribution
  Xprop := ((nullmean + 4*stderrmean) - xlow) / (xhigh - xlow);
  range := round(Xprop * Xrange);
  Hscale(-4.0, 4.0, 11, clWhite, 8, XaxisStart, YaxisStart+50, range,'NULL Z SCALE');
end;

procedure TErrorCurvesFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TErrorCurvesFrm.FormCreate(Sender: TObject);
begin
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TErrorCurvesFrm.PltPts(realpts: TwoCol; Xmax, Xmin, Ymax,
  Ymin: double; Npts, XAxisStart, YAxisStart, XAxisRange, YAxisRange: integer;
  AColor: TColor);
var
  hprop, zprop, z, h: double;
  i, X, Y: integer;
  intpts: array[1..100] of TPoint;
begin
  for i := 1 to Npts do
  begin
    z := RealPts[1, i];
    h := RealPts[2, i];
    zprop := (z - Xmin) / (Xmax - Xmin);
    X := round((zprop * XAxisRange) + XAxisStart);
    hprop := (h - Ymin) / (Ymax - Ymin);
    Y := round(YAxisStart - (hprop * YAxisRange));
    intpts[i] := Point(X,Y);
  end;

  BlankFrm.Image1.Canvas.Pen.Color := AColor;
  BlankFrm.Image1.Canvas.Polyline(Slice(intpts, Npts - 1));
end;

procedure TErrorCurvesFrm.Hscale(Xmin, Xmax: double; Nsteps: integer;
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
  for i := 0 to Nsteps + 1 do
  begin
    Xpos := round(Xlength/Nsteps * i + X);
    BlankFrm.Image1.Canvas.MoveTo(Xpos, Y);
    BlankFrm.Image1.Canvas.LineTo(Xpos, TickEnd);
    TextX := Xpos - 8;
    Xval := Xmin + i*Xincr;
    BlankFrm.Image1.Canvas.TextOut(TextX, Y+15, Format('%.2f', [Xval]));
  end;

  // print label below X axis
  Ypos := Y + 30;
  Xpos := round((BlankFrm.Image1.Width / 2) - (BlankFrm.Image1.Canvas.TextWidth(CharLabel) / 2));
  BlankFrm.Image1.Canvas.TextOut(Xpos, Ypos, CharLabel);
end;

procedure TErrorCurvesFrm.Vscale(Ymin, Ymax: double; NSteps: integer;
  AColor: TColor; FontSize: integer; X, Y, YLength: integer; CharLabel: string);
var
  TickEnd, Ypos, Xpos, TextY: integer;
  Yincr, Yval: double;
  chpixs, i: integer;
begin
  BlankFrm.Image1.Canvas.MoveTo(X,Y);
  BlankFrm.Image1.Canvas.LineTo(X,Y-Ylength);
  BlankFrm.Image1.Canvas.Font.Size := FontSize;
  BlankFrm.Image1.Canvas.Brush.Color := acolor;
  TickEnd := X - 10;
  Yincr := (Ymax - Ymin) / Nsteps;
  TextY := 0;

  for i := 0 to Nsteps + 1 do
  begin
    Ypos := round(Y - Ylength/Nsteps*i);
    BlankFrm.Image1.Canvas.MoveTo(X, Ypos);
    BlankFrm.Image1.Canvas.LineTo(TickEnd, Ypos);
    TextY := TickEnd - 30;
    Yval := Ymin + i*Yincr;
    BlankFrm.Image1.Canvas.TextOut(TextY, Ypos-8, Format('%.2f', [Yval]));
  end;

  // print label vertically
  Xpos := TextY - 15;
  chpixs := BlankFrm.Image1.Canvas.TextHeight(CharLabel);
  for i := 1 to Length(CharLabel) do
  begin
    Ypos := round(Y - Ylength/2 - Length(CharLabel)*chpixs/2  + chpixs*i);
    BlankFrm.Image1.Canvas.TextOut(Xpos,Ypos, CharLabel[i]);
  end;
end;

procedure TErrorCurvesFrm.NormPts(zMin, zMax: double; Npts: integer;
  var realpts: TwoCol);
var
  zIncr, z, h: double;
  i: integer;
begin
  zIncr := (zMax - zMin) / Npts;
  for i := 1 to Npts do
  begin
    z := zMin + (zIncr * i);
      h := (1.0 / sqrt(2.0 * PI)) * (1.0 / exp(z * z / 2.0));
      realpts[1, i] := z;
      realpts[2, i] := h;
  end;
end;

initialization
  {$I errorcurvesunit.lrs}

end.

