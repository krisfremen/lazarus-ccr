unit DistribUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Printers, ExtCtrls, Math,
  BlankFrmUnit, FunctionsLib, Globals;

  type
    TwoCol = array[1..2,1..100] of double;

type

  { TDistribFrm }

  TDistribFrm = class(TForm)
    AlphaEdit: TEdit;
    DF1Edit: TEdit;
    DF2Edit: TEdit;
    MeanEdit: TEdit;
    Panel1: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    GroupBox2: TGroupBox;
    AlphaLabel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    NDChk: TCheckBox;
    ChiChk: TCheckBox;
    FChk: TCheckBox;
    GroupBox1: TGroupBox;
    procedure ChiChkClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FChkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NDChkClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    procedure NDPlot(Sender : TObject);
    procedure ChiPlot(Sender : TObject);
    procedure FPlot(Sender : TObject);
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
    procedure PltPts(realpts : TwoCol;
                   Xmax, Xmin, Ymax, Ymin : double;
                   Npts, XaxisStart, YaxisStart, XaxisRange : integer;
                   YaxisRange : integer;
                   acolor : TColor; Sender : TObject);
    procedure ChiPts(cMin, cMax : double;
                             Npts, df : integer;
                             VAR realpts : TwoCol;
                             Sender : TObject);
    procedure  FPts(FMin, FMax : double;
                            Npts, df1, df2 : integer;
                            VAR realpts : TwoCol;
                            Sender : TObject);
    function chi2func(chisqr, df : double) : double;
    function Ffunc(F : double; df1, df2 : integer) : double;

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
     AlphaEdit.Text := '0.05';
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
     Label2.Enabled := false;
     Label3.Enabled := false;
     Label4.Enabled := false;
     DF2Edit.Enabled := false;
     MeanEdit.Enabled := false;
   end
   else
     GroupBox2.Enabled := false;
end;

procedure TDistribFrm.ComputeBtnClick(Sender: TObject);
begin
     if NDChk.Checked then
     begin
          NDPlot(self);
     end;
     if ChiChk.Checked then
     begin
          ChiPlot(self);
     end;
     if FChk.Checked then
     begin
          FPlot(self);
     end;
end;

procedure TDistribFrm.FChkClick(Sender: TObject);
begin
     if FChk.Checked then
     begin
          GroupBox2.Enabled := true;
          Label3.Enabled := true;
          AlphaLabel.Enabled := true;
          AlphaEdit.Enabled := true;
          DF1Edit.Enabled := true;
          DF2Edit.Enabled := true;
          Label2.Enabled := true;
          Label4.Enabled := false;
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
          Label2.Enabled := true;
          DF1Edit.Enabled := true;
          Label3.Enabled := false;
          Label4.Enabled := false;
          AlphaLabel.Enabled := true;
          AlphaEdit.Enabled := true;
          DF2Edit.Enabled := false;
          MeanEdit.Enabled := false;
     end else
          GroupBox2.Enabled := false;
end;

procedure TDistribFrm.NDPlot(Sender: TObject);
var
   charLabel : string;
   Clwidth, Clheight,X, Y, XaxisStart, XaxisEnd, YaxisStart, YaxisEnd : integer;
   i, Xrange, Yrange, t : integer;
   alpha, h, z, hprop, zprop : double;
   realpts : TwoCol;

begin
     for i := 1 to 100 do realpts[1,i] := 0.0;
     for i := 1 to 100 do realpts[2,i] := 0.0;
     charLabel := 'Normal Distribution. Alpha = ';
     BlankFrm.Image1.Canvas.Clear;
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;
     BlankFrm.Image1.Canvas.Clear;
     BlankFrm.Image1.Canvas.FloodFill(1,1,clWhite,fsborder);
     BlankFrm.Image1.Canvas.Pen.Width := 2;
     Clwidth :=  BlankFrm.Image1.Width;
     Clheight := BlankFrm.Image1.Height;
     XaxisStart := Clwidth div 8;
     XaxisEnd := Clwidth - (Clwidth div 8);
     YaxisStart := (Clheight * 7) div 10;
     YaxisEnd := Clheight div 10;
     Xrange := XaxisEnd - XaxisStart;
     Yrange := YaxisStart - YaxisEnd;
     alpha := StrToFloat(AlphaEdit.Text);
     BlankFrm.Show;

     // Create values of normal curve
     NormPts(-4.0, 4.0, 100, realpts, self);
     PltPts(realpts, 4.0, -4.0, 0.5, 0.0, 100, XaxisStart, YaxisStart, Xrange,
            Yrange, clBlack, self);

    // Draw line for alpha z := 1.645
     charLabel := charLabel + AlphaEdit.Text;
     BlankFrm.Caption := charLabel;
     z := inversez(1.0 - alpha);
     zprop := (4.0 + z) / 8.0;
     h := (1.0 / sqrt(2.0 * 3.1415)) * (1.0 / exp(z * z / 2.0));
     hprop := (0.5 - h) / 0.5;
     X := round( zprop * Xrange)+ XaxisStart;
     Y := YaxisEnd + round( hprop * Yrange);
     BlankFrm.Image1.Canvas.MoveTo(X,YaxisStart);
     BlankFrm.Image1.Canvas.LineTo(X,Y-10); // alpha cutoff

     // floodfill rejection section with red
     BlankFrm.Image1.Canvas.Brush.Color := clRed;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;

     // create labeled axis
     Hscale(-4.0, 4.0, 11, clWhite, 10, XaxisStart, YaxisStart, Xrange,'z SCALE',self);
     Vscale(0.0, 0.5, 11, clWhite, 10, XaxisStart, YaxisStart, Yrange, 'DENSITY',self);

     // Print Heading
     t := BlankFrm.Image1.Canvas.TextWidth(charLabel);
     X := (BlankFrm.Width div 2) - (t div 2);
     BlankFrm.Image1.Canvas.TextOut(X,0,charLabel);
     charLabel := 'Critical Value = ';
     charLabel := charLabel + format('%6.3f',[z]);
     t := BlankFrm.Image1.Canvas.TextWidth(charLabel);
     X := (BlankFrm.Image1.Width div 2) - (t div 2);
     BlankFrm.Image1.Canvas.TextOut(X,BlankFrm.Image1.Canvas.TextHeight(charLabel),charLabel);
end;

procedure TDistribFrm.ChiPlot(Sender: TObject);
var
   charLabel : string;
   Clwidth, Clheight, X, Y, XaxisStart, XaxisEnd, YaxisStart, YaxisEnd : integer;
   i, Xrange, Yrange, df, t : integer;
   alpha, h, z, hprop, zprop, MaxChi, MaxProb : double;
   realpts : TwoCol;

begin
     BlankFrm.Image1.Canvas.Clear;
     for i := 1 to 100 do realpts[1,i] := 0.0;
     for i := 1 to 100 do realpts[2,i] := 0.0;
     charLabel := 'Chi Squared Distribution. Alpha = ';
     MaxProb := 0.0;
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;
     BlankFrm.Image1.Canvas.Clear;
     BlankFrm.Image1.Canvas.FloodFill(1,1,clWhite,fsborder);
     BlankFrm.Image1.Canvas.Pen.Width := 2;
     Clwidth :=  BlankFrm.Image1.Width;
     Clheight := BlankFrm.Image1.Height;
     XaxisStart := Clwidth div 8;
     XaxisEnd := Clwidth - (Clwidth div 8);
     YaxisStart := (Clheight * 7) div 10;
     YaxisEnd := Clheight div 10;
     Xrange := XaxisEnd - XaxisStart;
     Yrange := YaxisStart - YaxisEnd;
     alpha := StrToFloat(AlphaEdit.Text);
     charLabel := charLabel + AlphaEdit.Text;
     df := StrToInt(DF1Edit.Text);
     if (df < 1) or (df > 100) then exit;
     charLabel := charLabel + ' D.F. = ';
     charLabel := charLabel + DF1Edit.Text;
     BlankFrm.Caption := charLabel;
     BlankFrm.Show;

     // Create values of chi-squared curve
     MaxChi := 125.0;
     ChiPts(0.0, MaxChi, 100, df, realpts, self);
     for i := 1 to 100 do
     begin
         if (realpts[2,i] > MaxProb) then MaxProb := realpts[2,i];
     end;
     PltPts(realpts, MaxChi, 0.0, MaxProb, 0.0, 100, XaxisStart, YaxisStart, Xrange,
            Yrange, clBlack, self);

    // Draw line for alpha
     z := inversechi(1.0-alpha,df);
     zprop := z / MaxChi;
     h := chi2func(z,df);
     hprop := (MaxProb - h) / MaxProb;
     X := round( zprop * Xrange)+ XaxisStart;
     Y := YaxisEnd + round( hprop * Yrange);
     BlankFrm.Image1.Canvas.MoveTo(X,YaxisStart);
     BlankFrm.Image1.Canvas.LineTo(X,Y); // alpha cutoff

     // floodfill main section with blue
     BlankFrm.Image1.Canvas.Brush.Color := clBlue;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;

     // create charLabeled axis
     Hscale(0.0, MaxChi, 11, clWhite, 10, XaxisStart, YaxisStart,
        Xrange,'CHI SQUARED SCALE',self);
     Vscale(0.0, MaxProb, 11, clWhite, 10, XaxisStart, YaxisStart,
        Yrange, 'DENSITY',self);

     // Print Heading
     t := BlankFrm.Image1.Canvas.TextWidth(charLabel);
     X := (BlankFrm.Width div 2) - (t div 2);
     BlankFrm.Image1.Canvas.TextOut(X,0,charLabel);
     charLabel := 'Critical Value = ';
     charLabel := charLabel + format('%6.3f',[z]);
     t := BlankFrm.Image1.Canvas.TextWidth(charLabel);
     X := (BlankFrm.Image1.Width div 2) - (t div 2);
     BlankFrm.Image1.Canvas.TextOut(X,BlankFrm.Image1.Canvas.TextHeight(charLabel),charLabel);
end;

procedure TDistribFrm.FPlot(Sender: TObject);
var
     charLabel : string;
     Clwidth, Clheight, X, Y, XaxisStart, XaxisEnd, YaxisStart, YaxisEnd : integer;
     i, Xrange, Yrange, t, df1, df2 : integer;
     realpts : TwoCol;
     alpha, h, F, hprop, Fprop, MaxProb, MaxF : double;
     done : boolean;
begin
     BlankFrm.Image1.Canvas.Clear;
     for i := 1 to 100 do realpts[1,i] := 0.0;
     for i := 1 to 100 do realpts[2,i] := 0.0;
     MaxProb := 0.0;
     charLabel := 'F Distribution. Alpha = ';
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;
     BlankFrm.Image1.Canvas.Clear;
     BlankFrm.Image1.Canvas.FloodFill(1,1,clWhite,fsborder);
     BlankFrm.Image1.Canvas.Pen.Width := 2;
     Clwidth :=  BlankFrm.Image1.Width;
     Clheight := BlankFrm.Image1.Height;
     XaxisStart := Clwidth div 8;
     XaxisEnd := Clwidth - (Clwidth div 8);
     YaxisStart := (Clheight * 7) div 10;
     YaxisEnd := Clheight div 10;
     Xrange := XaxisEnd - XaxisStart;
     Yrange := YaxisStart - YaxisEnd;
     alpha := StrToFloat(AlphaEdit.Text);
     charLabel := charLabel + AlphaEdit.Text;
     df1 := StrToInt(DF1Edit.Text);
     charLabel := charLabel + ' D.F.1 = ';
     charLabel := charLabel + DF1Edit.Text;
     df2 := StrToInt(DF2Edit.Text);
     charLabel := charLabel + ' , D.F.2 = ';
     charLabel := charLabel + DF2Edit.Text;
     BlankFrm.Caption := charLabel;
     BlankFrm.Show;

     // Create values of F curve
     MaxF := 20.0;
     done := false;
     while not done do
     begin
          h := Ffunc(MaxF, df1, df2);
          if (h < 0.001)  then MaxF := MaxF - 1.0
          else done := true;
     end;

     FPts(0.0, MaxF, 100, df1, df2, realpts, self);
     for i := 1 to 100 do
     begin
         if (realpts[2,i] > MaxProb) then MaxProb := realpts[2,i];
     end;
     PltPts(realpts, MaxF, 0.0, MaxProb, 0.0, 100, XaxisStart, YaxisStart, Xrange,
             Yrange, clBlack, self);

     // Draw line for alpha
     F := fpercentpoint(1.0-alpha,df1,df2);
     Fprop := F / MaxF;
     h := Ffunc(F,df1,df2);
     hprop := (MaxProb - h) / MaxProb;
     X := round( Fprop * Xrange)+ XaxisStart;
     Y := YaxisEnd + round( hprop * Yrange);
     BlankFrm.Image1.Canvas.MoveTo(X,YaxisStart);
     BlankFrm.Image1.Canvas.LineTo(X,Y); // alpha cutoff

     // floodfill main section with blue
     BlankFrm.Canvas.Brush.Color := clBlue;

     // create charLabeled axis
     Hscale(0.0, MaxF, 11, clWhite, 10, XaxisStart, YaxisStart,
        Xrange,'F SCALE',self);
     Vscale(0.0, MaxProb, 11, clWhite, 10, XaxisStart, YaxisStart,
        Yrange, 'DENSITY',self);

     // Print Heading
     t := BlankFrm.Image1.Canvas.TextWidth(charLabel);
     X := (BlankFrm.Image1.Width div 2) - (t div 2);
     BlankFrm.Image1.Canvas.TextOut(X,0,charLabel);
     charLabel := 'Critical Value = ';
     charLabel := charLabel + format('%6.3f',[F]);
     t := BlankFrm.Image1.Canvas.TextWidth(charLabel);
     X := (BlankFrm.Image1.Width div 2) - (t div 2);
     BlankFrm.Image1.Canvas.TextOut(X,BlankFrm.Image1.Canvas.TextHeight(charLabel),charLabel);
end;

procedure TDistribFrm.Hscale(Xmin, Xmax: double; Nsteps: integer;
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
    for i := 0 to Nsteps do
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
    // print charLabel below X axis
    Ypos := Y + 30;
    Xpos := round((BlankFrm.Width / 2) - (BlankFrm.Image1.Canvas.TextWidth(charLabel) / 2));
    BlankFrm.Image1.Canvas.TextOut(Xpos,Ypos,charLabel);
end;

procedure TDistribFrm.Vscale(Ymin, Ymax: double; Nsteps: integer;
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
    for i := 0 to Nsteps do
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
    // print charLabel vertically
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

procedure TDistribFrm.NormPts(zMin, zMax: double; Npts: integer;
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

procedure TDistribFrm.PltPts(realpts: TwoCol; Xmax, Xmin, Ymax, Ymin: double;
  Npts, XaxisStart, YaxisStart, XaxisRange: integer; YaxisRange: integer;
  acolor: TColor; Sender: TObject);
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

procedure TDistribFrm.ChiPts(cMin, cMax: double; Npts, df: integer;
  var realpts: TwoCol; Sender: TObject);
var
     ratio1, ratio2, ratio3, cIncr, chi, h : double;
     i : integer;
begin
     ratio1 := df / 2.0;
     ratio2 := (df - 2.0) / 2.0;
     cIncr := (cMax - cMin) / Npts;
     for i := 1 to Npts do
     begin
         chi := cMin + (cIncr * i);
//         h := inversechi(chi, df);
         ratio3 := chi / 2.0;
         h := (1.0 / (power(2.0,ratio1) * exp(lngamma(ratio1)))) * power(chi,ratio2) * ( 1.0 / exp(ratio3));
         realpts[1,i] := chi;
         realpts[2,i] := h;
     end;
end;

procedure TDistribFrm.FPts(FMin, FMax: double; Npts, df1, df2: integer;
  var realpts: TwoCol; Sender: TObject);
var
     FIncr, F, h : double;
     i : integer;
begin
     FIncr := (FMax - FMin) / Npts;
     for i := 1 to Npts do
     begin
         F := FMin + (FIncr * i);
         h := Ffunc(F, df1, df2);
         realpts[1,i] := F;
         realpts[2,i] := h;
     end;
end;

function TDistribFrm.chi2func(chisqr, df: double): double;
var
   ratio1, ratio2, ratio3, h : double;
begin
     // Returns the height of the density curve for the chi-squared statistic
     ratio1 := df / 2.0;
     ratio2 := (df - 2.0) / 2.0;
     ratio3 := chisqr / 2.0;
     h := (1.0 / (power(2.0,ratio1) * exp(lngamma(ratio1)))) * power(chisqr,ratio2) * ( 1.0 / exp(ratio3));
     Result := h;
end;

function TDistribFrm.Ffunc(F: double; df1, df2: integer): double;
var
   ratio1, ratio2, ratio3, ratio4, h : double;
   part1, part2, part3, part4, part5, part6, part7, part8, part9 : double;
begin
       // Returns the height of the density curve for the F statistic
       ratio1 := (df1 + df2) / 2.0;
       ratio2 := (df1 - 2.0) / 2.0;
       ratio3 := df1 / 2.0;
       ratio4 := df2 / 2.0;
       part1 := exp(lngamma(ratio1));
       part2 := power(df1,ratio3);
       part3 := power(df2,ratio4);
       part4 := exp(lngamma(ratio3));
       part5 := exp(lngamma(ratio4));
       part6 := power(F,ratio2);
       part7 := power((F*df1+df2),ratio1);
       part8 := (part1 * part2 * part3) / (part4 * part5);
       if (part7 = 0.0) then part9 := 0.0
       else part9 := part6 / part7;
       h := part8 * part9;
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
       Result := h;
end;

procedure TDistribFrm.FormCreate(Sender: TObject);
begin
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
end;

initialization
  {$I distribunit.lrs}

end.

