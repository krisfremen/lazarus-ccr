unit AutoPlotUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Printers,
  Globals;

type

  { TAutoPlotFrm }

  TAutoPlotFrm = class(TForm)
    Image1: TImage;
    PrintBtn: TButton;
    ReturnBtn: TButton;
    Panel1: TPanel;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure AutoPlot(Sender: TObject);

  private
    { private declarations }

  public
    { public declarations }
    correlations, partcors : DblDyneVec;
    uplimit, lowlimit : double;
    npoints : integer;
    DepVarEdit : string;
    PlotPartCors : boolean; // true to plot partial correlations
    PlotLimits : boolean;   // true to show upper and lower limits

  end; 

var
  AutoPlotFrm: TAutoPlotFrm;

implementation

uses
  Math;

{ TAutoPlotFrm }

procedure TAutoPlotFrm.FormShow(Sender: TObject);
begin
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.FillRect(0, 0, Image1.Width, Image1.Height);
//    AutoPlotFrm.Image1.Canvas.Clear;
  AutoPlot(self);
end;

procedure TAutoPlotFrm.PrintBtnClick(Sender: TObject);
var r : Trect;
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

procedure TAutoPlotFrm.AutoPlot(Sender: TObject);
var
    topmarg, botmarg, leftmarg, rightmarg, verthi, horizlong : integer;
    i, X, Y, middle, yincrement, xincrement, labelheight : integer;
    labelstring : string;
    labelstr : string;
    corstep, yprop, scaley : double;

begin
    height := Image1.Canvas.Height;
    width := Image1.Canvas.Width;
    middle := height div 2;
    topmarg := height div 10;
    verthi := height - (2 * topmarg);
    botmarg := topmarg + verthi;
    leftmarg := width div 10;
    horizlong := width - 2 * leftmarg;
    rightmarg := leftmarg + horizlong;
    yincrement := verthi div 20;
    xincrement := horizlong div npoints;

//    AutoPlotFrm.Show;
    Image1.Canvas.Pen.Color := clBlack;

    // print title at top, centered
    labelstring := 'Autocorrelations analysis for :';
    labelstring := labelstring + DepVarEdit;
    X := (leftmarg + horizlong div 2) - (Image1.Canvas.TextWidth(labelstring) div 2);
    Y := 1;
    Image1.Canvas.TextOut(X,Y,labelstring);

    // draw middle (zero correlation) axis
    Y := middle;
    Image1.Canvas.MoveTo(leftmarg,Y);
    X := rightmarg;
    Image1.Canvas.LineTo(X,Y);

    // draw right axis
    X := leftmarg;
    Y := botmarg;
    Image1.Canvas.MoveTo(X,Y);
    Y := topmarg;
    Image1.Canvas.LineTo(X,Y);

    // correlation scale to left of vertical axis
    corstep := 1.0;
    for i := 0 to 20 do
    begin
        Y := topmarg + (i * yincrement);
        labelstr := format('%4.2f -',[corstep]);
        labelstring := labelstr;
        X := leftmarg - Image1.Canvas.TextWidth(labelstring);
        Image1.Canvas.TextOut(X,Y,labelstring);
        corstep := corstep - 0.1;
    end;

    // Make legend axis on bottom
    X := leftmarg;
    Y := botmarg;
    Image1.Canvas.MoveTo(X,Y);
    X := rightmarg;
    Image1.Canvas.LineTo(X,Y);
    for i := 0 to npoints do
    begin
        X := leftmarg + (xincrement * i);
        labelstring := '|';
        Image1.Canvas.TextOut(X,Y,labelstring);
        labelstring := IntToStr(i);
        Y := Y + 5;
        if (i mod 2) = 1 then Image1.Canvas.TextOut(X,Y,labelstring);
        Y := botmarg;
    end;
    labelstring := 'LAG VALUE';
    X := (leftmarg + horizlong div 2) - (Image1.Canvas.TextWidth(labelstring) div 2);
    Y := botmarg + Image1.Canvas.TextHeight(labelstring);
    Image1.Canvas.TextOut(X,Y,labelstring);

    // Plot lines from correlation to correlation
    Image1.Canvas.Pen.Color := clRed;
    for i := 0 to npoints - 1 do
    begin
         yprop := (1.0 - correlations[i]) / 2.0;
         scaley := yprop * verthi;
         X := leftmarg + round(xincrement * i);
         Y := topmarg + round(scaley);
         if (i = 0)then Image1.Canvas.MoveTo(X,Y)
           else Canvas.LineTo(X,Y);
         Image1.Canvas.Ellipse(X-3,Y-3,X+3,Y+3);
    end;

    // Plot partial correlations
    if PlotPartCors then
    begin
         Image1.Canvas.Pen.Color := clBlue;
         for i := 0 to npoints - 1 do
         begin
              yprop := (1.0 - partcors[i]) / 2.0;
              scaley := yprop * verthi;
              X := leftmarg + round(xincrement * i);
              Y := topmarg + round(scaley);
              if (i = 0) then Image1.Canvas.MoveTo(X,Y)
              else Image1.Canvas.LineTo(X,Y);
              Image1.Canvas.Ellipse(X-3,Y-3,X+3,Y+3);
         end;
    end;

    // Plot lines for upper and lower 95% confidence levels
    if PlotLimits then
    begin
         Image1.Canvas.Pen.Color := clGreen;
         yprop := (1.0 - uplimit) / 2.0;
         scaley := yprop * verthi;
         Y := topmarg + round(scaley);
         Image1.Canvas.MoveTo(leftmarg,Y);
         X := rightmarg;
         Image1.Canvas.LineTo(X,Y);
         yprop := (1.0 - lowlimit) / 2.0;
         scaley := yprop * verthi;
         Y := topmarg + round(scaley);
         Image1.Canvas.MoveTo(leftmarg,Y);
         X := rightmarg;
         Image1.Canvas.LineTo(X,Y);
    end;

    // Show legend at right
    X := rightmarg;
    labelstring := 'Correlations';
    labelheight := Image1.Canvas.TextHeight(labelstring);
    Y := 5 * labelheight;
    Image1.Canvas.Font.Color := clRed;
    Image1.Canvas.TextOut(X,Y,labelstring);
    if PlotPartCors then
    begin
         labelstring := 'Partials';
         Y := 6 * labelheight;
         Image1.Canvas.Font.Color := clBlue;
         Image1.Canvas.TextOut(X,Y,labelstring);
    end;
    if PlotLimits then
    begin
         Y := 7 * labelheight;
         labelstring := '95% C.I.';
         Image1.Canvas.Font.Color := clGreen;
         Image1.Canvas.TextOut(X,Y,labelstring);
    end;
end;

procedure TAutoPlotFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([PrintBtn.Width, ReturnBtn.Width]);
  PrintBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

initialization
  {$I autoplotunit.lrs}

end.

