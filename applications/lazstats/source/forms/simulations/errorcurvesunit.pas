unit ErrorCurvesUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  BlankFrmUnit, FunctionsLib, Globals;

type
    TwoCol = array[1..2,1..100] of double;

type

  { TErrorCurvesFrm }

  TErrorCurvesFrm = class(TForm)
    Bevel1: TBevel;
    NullType: TRadioGroup;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    procedure PltPts(realpts : TwoCol;
                   Xmax, Xmin, Ymax, Ymin : double;
                   Npts, XaxisStart, YaxisStart, XaxisRange : integer;
                   YaxisRange : integer;
                   acolor : TColor; Sender : TObject);
    procedure Hscale(Xmin, Xmax : double; Nsteps : integer;
                 acolor : TColor; FontSize : integer;
                 X, Y, Xlength : integer;
                 charLabel : string; Sender : TObject);
    procedure Vscale(Ymin, Ymax : double; Nsteps : integer;
                 acolor : TColor; FontSize : integer;
                 X, Y, Ylength : integer;
                 charLabel : string; Sender : TObject);
    procedure NormPts(zMin, zMax : double; Npts : integer;
                  VAR realpts : TwoCol;
                  Sender : TObject);

  public
    { public declarations }
  end; 

var
  ErrorCurvesFrm: TErrorCurvesFrm;

implementation

{ TErrorCurvesFrm }

procedure TErrorCurvesFrm.ResetBtnClick(Sender: TObject);
begin
     NullMeanEdit.Text := '';
     AltMeanEdit.Text := '';
     SDEdit.Text := '';
     TypeIEdit.Text := '0.05';
     TypeIIEdit.Text := '0.05';
     NullMeanEdit.SetFocus;
end;

procedure TErrorCurvesFrm.FormShow(Sender: TObject);
begin
     ResetBtnClick(self);
end;

procedure TErrorCurvesFrm.ComputeBtnClick(Sender: TObject);
var
    // generate a null and alternate hypothesis for a specified effect
    // size, Type I error rate and Type II error rate using the normal
    // distribution z-test. Estimate the N needed.
    // Uses the Plot.h header file and form  FrmPlot.
    Clwidth,Clheight,X,Y,XaxisStart,XaxisEnd,YaxisStart,YaxisEnd : integer;
    Xrange, Yrange, t, range, Nsize: integer;
    alpha, beta, nullmean, altmean, Diff, StdDev, CriticalX, zalpha : double;
    zbeta, Xprop, stderrmean, xlow, xhigh : double;
    valuestr, charLabel : string;
    realpts : TwoCol;
begin
     BlankFrm.Show;
     BlankFrm.Image1.Canvas.Clear;
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;
     BlankFrm.Image1.Canvas.Clear;
     BlankFrm.Image1.Canvas.FloodFill(1,1,clWhite,fsborder);
     alpha := StrToFloat(TypeIEdit.Text);
     if NullType.ItemIndex = 1 then alpha := alpha / 2.0;
     beta := StrToFloat(TypeIIEdit.Text);
     nullmean := StrToFloat(NullMeanEdit.Text);
     altmean := StrToFloat(AltMeanEdit.Text);
     StdDev := StrToFloat(SDEdit.Text);
     zalpha := inversez(1.0 - alpha);
     zbeta := inversez(1.0 - beta);
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
     Hscale(xlow, xhigh, 9, clWhite, 8, XaxisStart, YaxisStart, Xrange,'X SCALE',BlankFrm);

     // Create values of the alternative distribution
     Xprop := ( (nullmean + 4*stderrmean) - xlow) / (xhigh - xlow);
     range := round(Xprop * Xrange);
     NormPts(-4.0, 4.0, 100, realpts, self);
     Xprop := ((altmean - 4 * stderrmean) - xlow) / (xhigh - xlow);
     X := round((Xprop * Xrange) + XaxisStart); // where to start curve
     PltPts(realpts, 4.0, -4.0, 0.5, 0.0, 100, X, YaxisStart, range,
            Yrange, clBlack, self);

     //Draw vertical axis at the critical X value
     Xprop := (CriticalX - xlow) / (xhigh - xlow);
     X := round((Xprop * Xrange) + XaxisStart);
     Y := YaxisStart;
     BlankFrm.Image1.Canvas.MoveTo(X,Y);
     BlankFrm.Image1.Canvas.LineTo(X,YaxisEnd);
     charLabel := 'Critical X = ';
     valuestr := format('%6.2f',[CriticalX]);
     charLabel := charLabel + valuestr;
     t := BlankFrm.Image1.Canvas.TextWidth(charLabel) div 2;
     BlankFrm.Image1.Canvas.TextOut(X-t,YaxisEnd-15,charLabel);

     // floodfill Alternate distribution area with blue
     Xprop := (CriticalX - xlow) / (xhigh - xlow);
     X := round((Xprop * Xrange) + XaxisStart);
     Y := YaxisStart - 3;
     BlankFrm.Image1.Canvas.Brush.Color := clBlue;
     BlankFrm.Image1.Canvas.FloodFill(X-2,Y,clBlack,fsBorder );
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;

     // Create values of normal curve for null distribution
     NormPts(-4.0, 4.0, 100, realpts, self);
     Xprop := ( (nullmean + 4*stderrmean) - xlow) / (xhigh - xlow);
     range := round(Xprop * Xrange);
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;
     PltPts(realpts, 4.0, -4.0, 0.5, 0.0, 100, XaxisStart, YaxisStart, range,
            Yrange, clBlack, self);

     //Draw vertical axis at null mean
     Xprop := (nullmean - xlow) / (xhigh - xlow);
     X := round((Xprop * Xrange) + XaxisStart);
     Y := YaxisStart;
     BlankFrm.Image1.Canvas.MoveTo(X,Y);
     BlankFrm.Image1.Canvas.LineTo(X,YaxisEnd);
     charLabel := 'Null Mean';
     t := BlankFrm.Image1.Canvas.TextWidth(charLabel) div 2;
     BlankFrm.Image1.Canvas.TextOut(X-t,YaxisEnd,charLabel);

     // floodfill alpha area with red
     Xprop := (CriticalX - xlow) / (xhigh - xlow);
     X := round((Xprop * Xrange) + XaxisStart);
     Y := YaxisStart - 3;
     BlankFrm.Image1.Canvas.Brush.Color := clRed;
     BlankFrm.Image1.Canvas.FloodFill(X+2,Y,clBlack,fsBorder );
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
     Vscale(0.0, 0.5, 11, clWhite, 10, XaxisStart, YaxisStart, Yrange, 'DENSITY', self);

     // Print Heading
     charLabel := 'Type I and II Error Areas';
     BlankFrm.Caption := charLabel;
     charLabel := 'Alpha := ';
     charLabel := charLabel + TypeIEdit.Text;
     charLabel := charLabel + ', Beta := ';
     charLabel := charLabel + TypeIIEdit.Text;
     charLabel := charLabel + ', N := ';
     charLabel := charLabel + IntToStr(Nsize);
     t := BlankFrm.Image1.Canvas.TextWidth(charLabel);
     X := round((BlankFrm.Image1.Width / 2) - (t / 2));
     BlankFrm.Image1.Canvas.TextOut(X,0,charLabel);

     // print z scale for the null distribution
     Xprop := ( (nullmean + 4*stderrmean) - xlow) / (xhigh - xlow);
     range := round(Xprop * Xrange);
     Hscale(-4.0, 4.0, 11, clWhite, 8, XaxisStart, YaxisStart+50, range,'NULL Z SCALE', self);

 end;

procedure TErrorCurvesFrm.FormCreate(Sender: TObject);
begin
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TErrorCurvesFrm.PltPts(realpts: TwoCol; Xmax, Xmin, Ymax,
  Ymin: double; Npts, XaxisStart, YaxisStart, XaxisRange: integer;
  YaxisRange: integer; acolor: TColor; Sender: TObject);
var
   hprop, zprop, z, h : double;
   i, X, Y : integer;
   intpts : array[1..100] of TPoint;
begin
      for i := 1 to Npts do
      begin
          z := realpts[1,i];
          h := realpts[2,i];
          zprop := (z - Xmin) / (Xmax - Xmin);
          X := round((zprop * XaxisRange) + XaxisStart);
          hprop := (h - Ymin) / (Ymax - Ymin);
          Y := round(YaxisStart - (hprop * YaxisRange));
          intpts[i] := Point(X,Y);
      end;
      BlankFrm.Image1.Canvas.Pen.Color := acolor;
      BlankFrm.Image1.Canvas.Polyline(Slice(intpts,Npts - 1));
end;

procedure TErrorCurvesFrm.Hscale(Xmin, Xmax: double; Nsteps: integer;
  acolor: TColor; FontSize: integer; X, Y, Xlength: integer; charLabel: string;
  Sender: TObject);
var
   i, TickEnd, Xpos, Ypos, TextX : integer;
   Xincr, Xval : double;
   Svalue, Ast : string;
begin
    BlankFrm.Image1.Canvas.MoveTo(X,Y);
    BlankFrm.Image1.Canvas.LineTo(X+Xlength,Y);
    BlankFrm.Image1.Canvas.Font.Size := FontSize;
    BlankFrm.Image1.Canvas.Brush.Color := acolor;
    TickEnd := Y + 10;
    Xincr := (Xmax - Xmin) / Nsteps;
    for i := 0 to Nsteps + 1 do
    begin
        Xpos := round(((Xlength / Nsteps) * i) + X);
        BlankFrm.Image1.Canvas.MoveTo(Xpos,Y);
        BlankFrm.Image1.Canvas.LineTo(Xpos,TickEnd);
        TextX := Xpos - 8;
        Xval := Xmin + ( i * Xincr);
        Svalue := format('%4.2f',[Xval]);
        Ast := Svalue;
        BlankFrm.Image1.Canvas.TextOut(TextX, Y+15, Ast);
    end;
    // print label below X axis
    Ypos := Y + 30;
    Xpos := round((BlankFrm.Image1.Width / 2) - (BlankFrm.Image1.Canvas.TextWidth(charLabel) / 2));
    BlankFrm.Image1.Canvas.TextOut(Xpos,Ypos,charLabel);
end;

procedure TErrorCurvesFrm.Vscale(Ymin, Ymax: double; Nsteps: integer;
  acolor: TColor; FontSize: integer; X, Y, Ylength: integer; charLabel: string;
  Sender: TObject);
var
   TickEnd, Ypos, Xpos, TextY : integer;
   Yincr, Yval : double;
   Svalue, symbol, Ast : string;
   chpixs, i : integer;
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
        Ypos := round(Y - ((Ylength / Nsteps) * i));
        BlankFrm.Image1.Canvas.MoveTo(X,Ypos);
        BlankFrm.Image1.Canvas.LineTo(TickEnd,Ypos);
        TextY := TickEnd - 30;
        Yval := Ymin + ( i * Yincr);
        Svalue := format('%4.2f',[Yval]);
        Ast := Svalue;
        BlankFrm.Image1.Canvas.TextOut(TextY, Ypos-8, Ast);
    end;
    // print label vertically
    Xpos := TextY - 15;
    for i := 1 to Length(charLabel) do
    begin
        chpixs := BlankFrm.Image1.Canvas.TextHeight(charLabel);
        Ypos := round(Y - (Ylength / 2) - ( (Length(charLabel) * chpixs) / 2 ) + (chpixs * i));
        symbol := charLabel[i];
//        symbol[2] := 0;
        BlankFrm.Image1.Canvas.TextOut(Xpos,Ypos,symbol);
    end;
end;

procedure TErrorCurvesFrm.NormPts(zMin, zMax: double; Npts: integer;
  var realpts: TwoCol; Sender: TObject);
var
   zIncr, z, h : double;
   i : integer;
begin
     zIncr := (zMax - zMin) / Npts;
     for i := 1 to Npts do
     begin
         z := zMin + (zIncr * i);
         h := (1.0 / sqrt(2.0 * 3.14159265358979)) *
              ( 1.0 / exp(z * z / 2.0));
         realpts[1,i] := z;
         realpts[2,i] := h;
     end;
end;

initialization
  {$I errorcurvesunit.lrs}

end.

