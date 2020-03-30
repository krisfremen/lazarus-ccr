unit PointsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Printers,
  Globals;

type

  { TPointsFrm }

  TPointsFrm = class(TForm)
    Image1: TImage;
    PrintBtn: TButton;
    ReturnBtn: TButton;
    MsgEdit: TEdit;
    Panel1: TPanel;
//    procedure FormPaint(Sender: TObject);
//    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure PtsPlot(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);

  private
    { private declarations }

  public
    { public declarations }
    pts : DblDyneVec;
    avg : DblDyneVec;
    LabelOne : string;
    LabelTwo : string;
    NoCases : integer;
    Title : string;
//    Caption : string;

  end; 

var
  PointsFrm: TPointsFrm;

implementation

{ TPointsFrm }

uses
  Math;

procedure TPointsFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([PrintBtn.Width, ReturnBtn.Width]);
  PrintBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure TPointsFrm.FormShow(Sender: TObject);
begin
//    Image1.Canvas.Clear;
    Image1.Canvas.Brush.Color := clWhite;
    Image1.Canvas.FillRect(0, 0, Image1.Width, Image1.Height);
    PtsPlot(self);
end;

procedure TPointsFrm.PrintBtnClick(Sender: TObject);
var
        r : Trect;
begin
        with Printer do
        begin
                Printer.Orientation := poPortrait;
                r := Rect(20,20,printer.pagewidth-20,printer.pageheight div 2 + 20);
                BeginDoc;
                Canvas.StretchDraw(r,Image1.Picture.BitMap);
                EndDoc;
        end;
end;

procedure TPointsFrm.PtsPlot(Sender: TObject);
var
    topmarg, botmarg, leftmarg, rightmarg, verthi, horizlong : integer;
    X, Y, yincrement, labelheight, i: integer;
    labelstring, labelstr : string;
    Xstep, Ystep, yprop, scaley, xprop, scalex, Min, Max : double;
begin
    height := Image1.Canvas.Height;
    width := Image1.Canvas.Width;
    topmarg := height div 10;
    verthi := height - (2 * topmarg);
    botmarg := topmarg + verthi;
    botmarg := height;
    leftmarg := width div 10;
    horizlong := width - 2 * leftmarg;
    rightmarg := leftmarg + horizlong;
    // get max and min of values to plot
    Max := -1000.0;
    Min := 1000.0;
    for i := 0 to NoCases - 1 do
    begin
        if (pts[i] > Max) then Max := pts[i];
        if (avg[i] > Max) then Max := avg[i];
        if (pts[i] < Min) then Min := pts[i];
        if (avg[i] < Min) then Min := avg[i];
    end;
    yincrement := verthi div 20;
    Image1.Canvas.Pen.Color := clBlack;

    // print title at top, centered
    labelstring := 'Plot of Original and ';
    labelstring := labelstring + Title;
//    labelstring := labelstring + DepVarEdit.Text;
    X := (leftmarg + horizlong div 2) - (Image1.Canvas.TextWidth(labelstring) div 2);
    Y := 1;
    Image1.Canvas.TextOut(X,Y,labelstring);

    // draw left axis
    X := leftmarg;
    Y := botmarg;
    Image1.Canvas.MoveTo(X,Y);
    Y := topmarg;
    Image1.Canvas.LineTo(X,Y);

    // scale to left of vertical axis
    Ystep := (Max - Min) / 20;
    for i := 0 to 20 do
    begin
        Y := topmarg + (i * yincrement);
        labelstr := format('%4.2f -',[Max - (Ystep * i)]);
        labelstring := labelstr;
        X := leftmarg - Image1.Canvas.TextWidth(labelstring);
        Image1.Canvas.TextOut(X,Y,labelstring);
    end;

    // Make legend axis on bottom
    X := leftmarg;
    Y := botmarg;
    Xstep := horizlong / 20;
    xprop := NoCases / 20;
    Image1.Canvas.MoveTo(X,Y);
    X := rightmarg;
    Image1.Canvas.LineTo(X,Y);
    for i := 0 to 20 do
    begin
        X := leftmarg + round(Xstep * i);
        labelstring := '|';
        Image1.Canvas.TextOut(X,Y,labelstring);
        labelstring := IntToStr(round((xprop * i) + 1));
        Y := Y + 5;
        Image1.Canvas.TextOut(X,Y,labelstring);
        Y := botmarg;
    end;
    labelstring := 'CASES';
    X := (leftmarg + horizlong div 2) - (Canvas.TextWidth(labelstring) div 2);
    Y := botmarg + Image1.Canvas.TextHeight(labelstring);
    Image1.Canvas.TextOut(X,Y,labelstring);

    // Plot lines from point to point
    Image1.Canvas.Pen.Color := clRed;
    for i := 0 to NoCases - 1 do
    begin
        yprop := (Max - pts[i]) / (Max - Min);
        scaley := yprop * verthi;
        xprop := i / NoCases;
        scalex := xprop * horizlong;
        X := leftmarg + round(scalex);
        Y := topmarg + round(scaley);
        if (i = 0) then Image1.Canvas.MoveTo(X,Y)
          else Image1.Canvas.LineTo(X,Y);
        Image1.Canvas.Ellipse(X-3,Y-3,X+3,Y+3);
    end;

    // Plot average points
    Image1.Canvas.Pen.Color := clBlue;
    for i := 0 to NoCases - 1 do
    begin
        yprop := (Max - avg[i]) / (Max - Min);
        scaley := yprop * verthi;
        xprop := i / NoCases;
        scalex := xprop * horizlong;
        X := leftmarg + round(scalex);
        Y := topmarg + round(scaley);
        if (i = 0) then Image1.Canvas.MoveTo(X,Y)
          else Image1.Canvas.LineTo(X,Y);
        Image1.Canvas.Ellipse(X-3,Y-3,X+3,Y+3);
    end;

    // Show legend at right
    X := rightmarg;
    labelstring := LabelOne;
    labelheight := Image1.Canvas.TextHeight(labelstring);
    Y := 5 * labelheight;
    Image1.Canvas.Font.Color := clRed;
    Image1.Canvas.TextOut(X,Y,labelstring);
    labelstring := LabelTwo;
    Y := 6 * labelheight;
    Image1.Canvas.Font.Color := clBlue;
    Image1.Canvas.TextOut(X,Y,labelstring);
end;

procedure TPointsFrm.ReturnBtnClick(Sender: TObject);
begin
  PointsFrm.Hide;
end;

{
procedure TPointsFrm.FormPaint(Sender: TObject);
begin
    PtsPlot;
end;

procedure TPointsFrm.FormResize(Sender: TObject);
begin
    PtsPlot;
end;
}
initialization
  {$I pointsunit.lrs}

end.

