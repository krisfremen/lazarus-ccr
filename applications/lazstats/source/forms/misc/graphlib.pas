unit GraphLib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Printers, Math,
  Globals;


type

  { TGraphFrm }

  TGraphFrm = class(TForm)
    Bevel1: TBevel;
    SaveBtn: TButton;
    Image1: TImage;
    PrintBtn: TButton;
    ReturnBtn: TButton;
    Panel1: TPanel;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
  private
    { private declarations }
    ImageWidth : integer;
    ImageHeight : integer;
    XOffset : integer;
    YOffset : integer;
    XAxisLength : integer;
    YAxisLength : integer;
    DegAngle : real;
    RadAngle : real;
    TanAngle : real;
    BarWidth : integer;
    XStart : integer;
    XEnd : integer;
    YStart : integer;
    YEnd : integer;
    Gtype : integer;
    NoBars : integer;
    NSets : integer;
    YMax : real;
    YMin : real;
    XProp : real;
    Colors : Array[0..11] of integer;

    procedure Bar2D(Sender: TObject);
    procedure Bar3D(Sender: TObject);
    procedure Pie2D(Sender: TObject);
    procedure Pie3D(Sender: TObject);
    procedure Line2D(Sender: TObject);
    procedure Line3D(Sender: TObject);
    procedure Plot2D(Sender: TObject);
    procedure Plot3D(Sender: TObject);
    procedure MakeXAxis(Sender: TObject);
    procedure MakeYAxis(Sender: TObject);
    procedure MakeHXaxis(Sender: TObject);
    procedure MakeHYaxis(Sender: TObject);
    procedure HBar2D(Sender: TObject);
    procedure HBar3D(Sender: TObject);
    procedure Walls(Sender: TObject);
    procedure pBar2D(Sender: TObject);
    procedure pBar3D(Sender: TObject);
    procedure pPie2D(Sender: TObject);
    procedure pExPie(Sender: TObject);
    procedure pLine2D(Sender: TObject);
    procedure pLine3D(Sender: TObject);
    procedure pPlot2D(Sender: TObject);
    procedure pPlot3D(Sender: TObject);
    procedure pMakeXAxis(Sender: TObject);
    procedure pMakeYaxis(Sender: TObject);
    procedure pMakeHXaxis(Sender: TObject);
    procedure pMakeHYaxis(Sender: TObject);
    procedure pHBar2D(Sender: TObject);
    procedure pHBar3D(Sender: TObject);
    procedure pWalls(Sender: TObject);

  public
    { public declarations }
    nosets : integer; //number of data sets to plot
    nbars  : integer; // maximum number of bars to plot in any set
    Heading : String; // Major Heading for graph
    XTitle : string;  // title for x-axis
    YTitle : string;  // title for vertical axis
    barwideprop : real;  // proportional width of bar (0 to 1.0)
    GraphType : integer; //1=2dbar,2=3dbar,3=2dpie,4=3dpie,5=2dline,6=3dline
                         //7=2dpoints,8=3dpoints
    Ypoints, Xpoints : DblDyneMat;
    SetLabels : array[1..20] of string[21]; // labels for multiple sets
    PointLabels : array[1..1000] of string[3]; // individual point labels
    PtLabels : boolean; // true to print point labels (for 2D Plot only)
    AutoScaled : boolean; // if true, program uses computed min and max values
    ShowLeftWall : boolean;
    ShowRightWall : boolean;
    ShowBottomWall : boolean;
    ShowBackWall : boolean;
    BackColor : integer;
    WallColor : integer;
    FloorColor : integer;
    miny : double; // specified by user if autoscaled is false
    maxy : double; // specified by user if autoscaled is false

  end; 

var
  GraphFrm: TGraphFrm;

implementation

{ TGraphFrm }

procedure TGraphFrm.PrintBtnClick(Sender: TObject);
begin
     Printer.Orientation := poLandscape;
     ImageWidth := Printer.PageWidth - 100;
     ImageHeight := Printer.PageHeight - 100;
     XOffset := ImageWidth div 10;
     YOffset := ImageHeight div 10;
     XStart := Xoffset;
     XEnd := ImageWidth - XOffset;
     XAxisLength := XEnd - XStart;
     YStart := ImageHeight - YOffset;
     YEnd := YOffset;
     YAxisLength := YStart - YEnd;
     DegAngle := 45.0;
     RadAngle := DegToRad(DegAngle);
     TanAngle := Tan(RadAngle);
     NoBars := nbars;
     NSets := nosets;
     XProp := barwideprop;
     BarWidth := XAxisLength div NoBars;
     // draw border around graph
     Printer.BeginDoc;
     BackColor := clWhite;
     Printer.Canvas.Brush.Color := BackColor;
     Printer.Canvas.Rectangle(100,100,ImageWidth,ImageHeight);
     Printer.Canvas.TextOut(ImageWidth div 2,YEnd - 100,Heading);
     Caption := Heading;
     if (GType < 1) or (GType > 10) then
     begin
//          Application.MessageBox('No graph type defined.','ERROR!',MB_OK);
          Printer.Enddoc;
          exit;
     end
     else case GType of
          1 : pBar2D(self); // two dimension vertical bars
          2 : pBar3D(self); // three dimension vertical bars
          3 : pPie2D(self); // two dimension pie chart
          4 : pExPie(self); // exploded pie chart
          5 : pLine2D(self); // Two dimension lines
          6 : pLine3D(self); // three dimension lines
          7 : pPlot2D(self); // two dimension points
          8 : pPlot3D(self); // three dimension points
          9 : pHBar2D(self); // Two dimension horizontal bars
          10: pHBar3D(self); // Three dimension horizontal bars
     end;
    Printer.EndDoc;	{ finish printing }
    Printer.Orientation := poPortrait;

end;

procedure TGraphFrm.FormShow(Sender: TObject);
var
  i, j: integer;
begin
  Gtype := 1; // default type is a 2 dimension bar graph
  ImageWidth := Image1.Width;
  ImageHeight := Image1.Height;
  XOffset := ImageWidth div 10;
  YOffset := ImageHeight div 10;
  XStart := Xoffset;
  XEnd := ImageWidth - XOffset;
  XAxisLength := XEnd - XStart;
  YStart := ImageHeight - YOffset;
  YEnd := YOffset;
  YAxisLength := YStart - YEnd;
  DegAngle := 45.0;
  RadAngle := DegToRad(DegAngle);
  TanAngle := Tan(RadAngle);
  NoBars := nbars;
  NSets := nosets;
  XProp := barwideprop;
  BarWidth := XAxisLength div NoBars;
  GType := GraphType;
  Colors := DATA_COLORS;

  // draw border around graph
  Image1.Canvas.Brush.Color := BackColor;
  Image1.Canvas.Rectangle(0,0, ImageWidth, ImageHeight);
  Image1.Canvas.TextOut((ImageWidth - Image1.Canvas.TextWidth(Heading)) div 2, 2, Heading);

  Caption := Heading;

  if AutoScaled then
  begin
    YMin := YPoints[0,0];
    YMax := YMin;
    for i := 1 to NSets do
    begin
      for j := 2 to NoBars do
      begin
        if YPoints[i-1,j-1] > YMax then YMax := YPoints[i-1,j-1];
        if YPoints[i-1,j-1] < YMin then YMin := YPoints[i-1,j-1];
      end;
    end;
  end else
  begin
    YMin := miny;
    YMax := maxy;
  end;

  case GType of
    1 : Bar2D(self);
    2 : Bar3D(self);
    3 : Pie2D(self);
    4 : Pie3D(self);
    5 : Line2D(self);
    6 : Line3D(self);
    7 : Plot2D(self);
    8 : Plot3D(self);
    9 : HBar2D(self);
    10: HBar3D(self);
    else exit;
  end;
end;

procedure TGraphFrm.SaveBtnClick(Sender: TObject);
VAR
   response : string;
begin
     response := InputBox('NAME?','Name of bitmap file:','image.bmp');
     Image1.Picture.SaveToFile(response);
end;

procedure TGraphFrm.Bar2D(Sender: TObject);
var
   j : integer;
   x1, y1, x2, y2 : integer;
   bwidth : integer;
   xpos : integer;
   yprop : real;
   ydist : real;
begin
     MakeXAxis(self);
     MakeYAxis(self);
     { Make bar for each y data point }
     for j := 1 to NoBars do
     begin
          Image1.Canvas.Brush.Color := Colors[j mod 12];
          bwidth := round(XProp * BarWidth);
          xpos := XStart + (BarWidth * j) - (BarWidth div 2);
          x1 := xpos - (bwidth div 2);
          x2 := x1 + bwidth;
          y1 := YStart;
//          yprop := (YPoints[1]^[j]- YMin) / (YMax - YMin);
          yprop := (YPoints[0,j-1] - YMin) / (YMax - YMin);
          ydist := yprop * YAxisLength;
          y2 := YStart - round(ydist);
          Image1.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x2,y2),Point(x1,y2)]);
     end;
end;
//---------------------------------------------------------------------

procedure TGraphFrm.HBar2D(Sender: TObject);
var
   j : integer;
   x1, y1, x2, y2 : integer;
   bwidth : integer;
   ypos : integer;
   xdist : real;
   yprop : real;
begin
     BarWidth := YAxisLength div NoBars;
     MakeHXAxis(self);
     MakeHYAxis(self);
     { Make bar for each y data point }
     for j := 1 to NoBars do
     begin
          Image1.Canvas.Brush.Color := Colors[j mod 12];
          bwidth := round(XProp * BarWidth);
          ypos := YStart - (BarWidth * j) + (BarWidth div 2); // bar center
          y1 := ypos - (bwidth div 2);
          y2 := y1 + bwidth;
          x1 := XStart;
          yprop := (YPoints[0,j-1] - YMin) / (YMax - YMin);
          xdist := yprop * XAxisLength;
          x2 := XStart + round(xdist);
          Image1.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x2,y2),Point(x1,y2)]);
     end;
end;
//----------------------------------------------------------------------

procedure TGraphFrm.HBar3D(Sender: TObject);
var
   i, j : integer;
   x1, x2, x3, x4, y1, y2, y3, y4 : integer;
   triheight : integer;
   bwidth : integer;
   ypos : integer;
   xdist : real;
   yprop : real;
//   yoffset : integer;
//   xoffset : integer;
   triwidth : integer;

begin
     Walls(self); // create left and bottom wall and axes
     BarWidth := YAxisLength div NoBars;
     Image1.Canvas.Brush.Color := BackColor;
     MakeHXAxis(self);
     MakeHYAxis(self);
     bwidth := round(XProp * BarWidth);
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     for i := 1 to NSets do
     begin
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          { Make bar for each y data point }
          for j := 1 to NoBars do
          begin
               // do face
               Image1.Canvas.Brush.Color := Colors[j mod 12];
               ypos := YStart - (BarWidth * j) + (BarWidth div 2); // bar center
               y1 := ypos - (bwidth div 2) - yoffset;
               y2 := y1 + bwidth;
               x1 := XStart + xoffset;
               yprop := (YPoints[0,j-1] - YMin) / (YMax - YMin);
               xdist := yprop * XAxisLength;
               x2 := XStart + round(xdist) + xoffset;
               Image1.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x2,y2),Point(x1,y2)]);
               // do side (end of bar )
               x1 := x2;
               x2 := x1 + triwidth;
               y1 := y2;
               y2 := y1 - triheight;
               y3 := y2 - bwidth;
               y4 := y1 - bwidth;
               Image1.Canvas.Polygon([Point(x1,y1),Point(x2,y2),Point(x2,y3),Point(x1,y4)]);
               // do top of bar
               x3 := XStart + xoffset;
               x4 := x3 + triwidth;
               Image1.Canvas.Polygon([Point(x3,y4),Point(x1,y4),Point(x2,y3),Point(x4,y3)]);
          end;
     end;
end;
//----------------------------------------------------------------------

procedure TGraphFrm.Bar3D(Sender: TObject);
var
   i, j : integer;
   x1, x2, x3, x4, y1, y2, y3, y4 : integer;
   triheight : integer;
   bwidth : integer;
   yprop : real;
//   yoffset : integer;
//   xoffset : integer;
   xpos : integer;
   ydist : integer;
   triwidth : integer;

begin
     Walls(self); // create left and bottom wall and axes
     Image1.Canvas.Brush.Color := BackColor;
     MakeXAxis(self);
     MakeYAxis(self);
     bwidth := round(XProp * BarWidth);
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     for i := NSets downto 1 do
     begin
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          for j := 1 to NoBars do
          begin
               Image1.Canvas.Brush.Color := Colors[j mod 12];
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x1 := xpos - (bwidth div 2);
               x2 := x1 + bwidth;
               y1 := YStart;
               yprop := (YPoints[i-1,j-1] - YMin) / (YMax - YMin);
               ydist := round(yprop * YAxisLength);
               y2 := YStart - round(ydist);
               x1 := x1 + xoffset;
               x2 := x2 + xoffset;
               y1 := y1 - yoffset;
               y2 := y2 - yoffset;
               // draw face
               Image1.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x2,y2),Point(x1,y2)]);
               // draw side
               x1 := x2;
               x2 := x1 + triwidth;
               y2 := y1 - triheight;
               y3 := y1 - round(ydist);
               y4 := y2 - round(ydist);
               Image1.Canvas.Polygon([Point(x1,y1),Point(x2,y2),Point(x2,y4),Point(x1,y3)]);
               // draw top
               x1 := xpos - (bwidth div 2) + xoffset;
               x2 := x1 + bwidth;
               x3 :=  x2 + triwidth;
               x4 := x1 + triwidth;
               y1 := YStart - yoffset {%H-}- round(ydist);
               y2 := y1 - triheight;
               Image1.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x3,y2),Point(x4,y2)]);
          end;
          x1 := XStart + XAxisLength + xoffset;
          y1 := YStart - triheight * i;
          Image1.Canvas.Brush.Color := clWhite;
          Image1.Canvas.TextOut(x1,y1,SetLabels[i]);
     end;
end;
//---------------------------------------------------------------------

procedure TGraphFrm.Pie2D(Sender: TObject);
var
   i : integer;
   x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6 : integer;
   yprop : real;
   xcenter, ycenter : double;
   Total : double;
   radians : double;
   radius : integer;
   cum : double;
   value : string;

begin
   xcenter := ImageWidth div 2;
   ycenter := ImageHeight div 2;

   // get the total for obtaining proportions that each y point is of the total
   Total := 0.0;
   cum := 0.0;
   radius := round(ycenter) - YOffset;
   x1 := ImageWidth div 2 - Image1.Canvas.TextWidth(XTitle) div 2;
   Image1.Canvas.TextOut(x1,YStart + 25,XTitle);
   x1 := round(xcenter-radius); // left of rectangle
   y1 := round(ycenter-radius); // top of rectangle
   x2 := round(xcenter + radius); // right of rectangle
   y2 := round(ycenter + radius); // bottom of rectangle
   x3 := x2;
   y3 := round(ycenter);
   for i := 1 to NoBars do Total := Total + YPoints[0,i-1];
   // plot an arc corresponding to each proportion starting at radian 0
   for i := 1 to NoBars do
   begin
        yprop := YPoints[0,i-1] / Total;
        cum := cum + yprop;
        radians := cum * 2.0 * Pi;
        x4 := round(xcenter + radius * cos(radians));
        y4 := round(ycenter - (radius * sin(radians)));
        Image1.Canvas.Brush.Color := Colors[i mod 12];
        if yprop > 0.0 then
        begin
           Image1.Canvas.Pie(x1,y1,x2,y2,x3,y3,x4,y4);
           radians := (cum - (yprop / 2.0)) * 2.0 * Pi;
           x5 := round(xcenter + radius * cos(radians));
           y5 := round(ycenter - radius * sin(radians));
           Image1.Canvas.MoveTo(x5,y5);
           if x5 >= round(xcenter) then x6 := x5 + 20
           else x6 := x5 - 20;
           if y5 >= round(ycenter) then y6 := y5 + 20
           else y6 := y5 - 20;
           Image1.Canvas.LineTo(x6,y6);
           Image1.Canvas.Brush.Color := BackColor;
           value := format('%8.5g',[XPoints[0,i-1]]);
           Image1.Canvas.TextOut(x6,y6,value);
           if x5 >= round(xcenter) then x6 := x5 - 20
           else x6 := x5 + 20;
           if y5 >= round(ycenter) then y6 := y5 - 20
           else y6 := y5 + 20;
           value := format('%4.2f',[yprop*100.0]);
           value := value + '%';
           Image1.Canvas.TextOut(x6,y6,value);
           x3 := x4;
           y3 := y4;
        end;
   end;
end;
//---------------------------------------------------------------------

procedure TGraphFrm.Pie3D(Sender: TObject);
var
   i : integer;
   x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6 : integer;
   yprop : real;
   xcenter, ycenter : double;
   Total : double;
   radians : double;
   midradians : double;
   radius : integer;
   cum : double;
   value : string;

begin
   ycenter := ImageHeight div 2;
   // get the total for obtaining proportions that each y point is of the total
   Total := 0.0;
   cum := 0.0;
   radius := round(ycenter) - YOffset;
   x1 := ImageWidth div 2 - Image1.Canvas.TextWidth(XTitle) div 2;
   Image1.Canvas.TextOut(x1,YStart + 25,XTitle);
   for i := 1 to NoBars do Total := Total + YPoints[0,i-1];
   // plot an arc corresponding to each proportion starting at radian 0
   for i := 1 to NoBars do
   begin
        xcenter := ImageWidth div 2;
        ycenter := ImageHeight div 2;
        yprop := YPoints[0,i-1] / Total;
        cum := cum + yprop;
        radians := cum * 2.0 * Pi;
        midradians := (cum - (yprop / 2.0)) * 2.0 * Pi;
        x5 := round(xcenter + radius * cos(midradians));
        y5 := round(ycenter - radius * sin(midradians));
        // explode pie by shifting slices away from center
        if x5 >= round(xcenter) then xcenter := xcenter + 10
        else xcenter := xcenter - 10;
        if y5 >= round(ycenter) then ycenter := ycenter + 10
        else ycenter := ycenter - 10;
        x1 := round(xcenter-radius); // left of rectangle
        y1 := round(ycenter-radius); // top of rectangle
        x2 := round(xcenter + radius); // right of rectangle
        y2 := round(ycenter + radius); // bottom of rectangle
        midradians := (cum - yprop ) * 2.0 * Pi;
        x3 := round(xcenter + radius * cos(midradians));
        y3 := round(ycenter - radius * sin(midradians));
        x4 := round(xcenter + radius * cos(radians));
        y4 := round(ycenter - (radius * sin(radians)));
        Image1.Canvas.Brush.Color := Colors[i mod 12];
        if yprop > 0.0 then
        begin
           Image1.Canvas.Pie(x1,y1,x2,y2,x3,y3,x4,y4);
           radians := (cum - (yprop / 2.0)) * 2.0 * Pi;
           x5 := round(xcenter + radius * cos(radians));
           y5 := round(ycenter - radius * sin(radians));
           Image1.Canvas.MoveTo(x5,y5);
           if x5 >= round(xcenter) then x6 := x5 + 20
           else x6 := x5 - 20;
           if y5 >= round(ycenter) then y6 := y5 + 20
           else y6 := y5 - 20;
           Image1.Canvas.LineTo(x6,y6);
           Image1.Canvas.Brush.Color := BackColor;
           value := format('%8.5g',[XPoints[0,i-1]]);
           Image1.Canvas.TextOut(x6,y6,value);
           if x5 >= round(xcenter) then x6 := x5 - 20
           else x6 := x5 + 20;
           if y5 >= round(ycenter) then y6 := y5 - 20
           else y6 := y5 + 20;
           value := format('%4.2f',[yprop*100.0]);
           value := value + '%';
           Image1.Canvas.TextOut(x6,y6,value);
        end;
   end;
end;
//---------------------------------------------------------------------

procedure TGraphFrm.Line2D(Sender: TObject);
{ This procedure draws lines for 1 or more sets (on top of each other if
  multiple sets) }
var
   i, j : integer;
   x1, y1, x2, y2 : integer;
   xpos : integer;
   yprop : real;
   ydist : real;
begin
     MakeXAxis(self);
     MakeYAxis(self);
     { Make lines for each set of y data point }
     For i := NSets downto 1 do
     begin
          Image1.Canvas.Pen.Color := Colors[i mod 12];
          x1 := XStart + BarWidth div 2;
          x2 := x1;
          yprop := (YPoints[i-1,0] - YMin) / (YMax - YMin);
          ydist := yprop * YAxisLength;
          y1 := YStart - round(ydist);
          y2 := y1;
          Image1.Canvas.MoveTo(x1,y1);
          for j := 2 to NoBars do
          begin
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x2 := xpos;
               yprop := (YPoints[i-1,j-1] - YMin) / (Ymax - YMin);
               ydist := yprop * YAxisLength;
               y2 := YStart - round(ydist);
               Image1.Canvas.LineTo(x2,y2);
          end;
          Image1.Canvas.Pen.Color := clBlack;
          x1 := x2;
          y1 := y2;
          Image1.Canvas.Brush.Color := clWhite;
          Image1.Canvas.TextOut(x1,y1,SetLabels[i]);
     end;
     Image1.Canvas.Pen.Color := clBlack;
end;
//---------------------------------------------------------------------

procedure TGraphFrm.Line3D(Sender: TObject);
{ This procedure draws lines for multiple sets but staggers each set back and
  to the right }
var
   i, j : integer;
   x1, x2, x3, x4, y1, y2, y3, y4 : integer;
   triheight : integer;
   bwidth : integer;
   yprop : double;
   points : array[0..4] of TPoint;
   xpos : integer;
   ydist : integer;
   triwidth : integer;
begin

     Walls(self); // create left and bottom wall and axes
     Image1.Canvas.Brush.Color := BackColor;
     MakeXAxis(self);
     MakeYAxis(self);
     bwidth := BarWidth;
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     for i := NSets downto 1 do
     begin
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          Image1.Canvas.Brush.Color := Colors[i mod 12];
          for j := 1 to NoBars-1 do
          begin
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x1 := xpos - (bwidth div 2) + xoffset;
               x2 := x1 + bwidth;
               x3 := x2 + triwidth;
               x4 := x1 + triwidth;
               yprop := (YPoints[i-1,j-1] - YMin) / (YMax - YMin);
               ydist := round(yprop * YAxisLength);
               y1 := YStart - yoffset - ydist;
               y2 := y1 - triheight;
               yprop := (YPoints[i-1,j] - YMin) / (YMax - YMin);
               ydist := round(yprop * YAxisLength);
               y3 := ystart - yoffset - ydist;
               y4 := y3 - triheight;
               points[0] := Point(x1,y1);
               points[1] := Point(x2,y2);
               points[2] := Point(x3,y4);
               points[3] := Point(x4,y3);
               Image1.Canvas.Polygon(points,4);
          end;
          x1 := XStart + XAxisLength + xoffset;
          y1 := YStart - triheight * i;
          Image1.Canvas.Brush.Color := clWhite;
          Image1.Canvas.TextOut(x1,y1,SetLabels[i]);
     end;
end;
//---------------------------------------------------------------------

procedure TGraphFrm.Plot2D(Sender: TObject);
var
   i, j : integer;
   x1, y1 : integer;
   triheight : integer;
   bwidth : integer;
   yprop : real;
//   yoffset : integer;
//   xoffset : integer;
   xpos : integer;
   ydist : integer;
   triwidth : integer;
begin
     //Walls(self); // create left and bottom wall and axes
     Image1.Canvas.Brush.Color := BackColor;
     MakeXAxis(self);
     MakeYAxis(self);
     bwidth := round(XProp * BarWidth);
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     { Make points for each set of y data point }
     for i := NSets downto 1 do
     begin
          Image1.Canvas.Brush.Color := Colors[i mod 12];
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          for j := 1 to NoBars do
          begin
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x1 := xpos;
               yprop := (YPoints[i-1,j-1] - YMin) / (YMax - YMin);
               ydist := round(yprop * YAxisLength);
               y1 := YStart - round(ydist);
               x1 := x1 + xoffset;
               y1 := y1 - yoffset;
               if PtLabels then
               begin
                    Image1.Canvas.Brush.Color := BackColor;
                    Image1.Canvas.TextOut(x1,y1,PointLabels[j]);
               end
               else
                   Image1.Canvas.Ellipse(x1-5,y1-5,x1+5,y1+5);
          end;
          Image1.Canvas.Pen.Color := clBlack;
          x1 := XStart + XAxisLength + xoffset;
          y1 := YStart - triheight * i;
          Image1.Canvas.Brush.Color := clWhite;
          Image1.Canvas.TextOut(x1,y1,SetLabels[i]);
     end;
end;
//---------------------------------------------------------------------

procedure TGraphFrm.Plot3D(Sender: TObject);
var
   i, j : integer;
   x1, y1 : integer;
   yprop : real;
   triheight : integer;
   bwidth : integer;
//   yoffset : integer;
//   xoffset : integer;
   xpos : integer;
   ydist : integer;
   triwidth : integer;
begin
     Walls(self); // create left and bottom wall and axes
     Image1.Canvas.Brush.Color := BackColor;
     MakeXAxis(self);
     MakeYAxis(self);
     bwidth := round(XProp * BarWidth);
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     { Make points for each set of y data point }
     for i := NSets downto 1 do
     begin
          Image1.Canvas.Brush.Color := Colors[i mod 12];
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          for j := 1 to NoBars do
          begin
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x1 := xpos;
               yprop := (YPoints[i-1,j-1] - YMin) / (YMax - YMin);
               ydist := round(yprop * YAxisLength);
               y1 := YStart - round(ydist);
               x1 := x1 + xoffset;
               y1 := y1 - yoffset;
               // change next to a ball by drawing multiple Ellipses around
               // vertical axis ?
               Image1.Canvas.Ellipse(x1-5,y1-5,x1+5,y1+5);
               Image1.Canvas.Ellipse(x1-4,y1-5,x1+4,y1+5);
               Image1.Canvas.Ellipse(x1-3,y1-5,x1+3,y1+5);
               Image1.Canvas.Ellipse(x1-2,y1-5,x1+2,y1+5);
          end;
          Image1.Canvas.Pen.Color := clBlack;
          x1 := XStart + XAxisLength + xoffset;
          y1 := YStart - triheight * i;
          Image1.Canvas.Brush.Color := clWhite;
          Image1.Canvas.TextOut(x1,y1,SetLabels[i]);
     end;
end;
//---------------------------------------------------------------------

procedure TGraphFrm.MakeXAxis(Sender: TObject);
var
  i, valstart, valend, oldend: integer;
  xpos: integer;
  value: string;
begin
  Image1.Canvas.Line(XStart, YStart, XEnd, YStart);
  oldend := 0;
  for i := 1 to NoBars do
  begin
    xpos := XStart + (BarWidth * i) - (BarWidth div 2);
    Image1.Canvas.Line(xpos, YStart, xpos, YStart + 5);
    value := Format('%.5g', [XPoints[0, i-1]]);
    valstart := xpos - Image1.Canvas.TextWidth(value) div 2;
    valend := valstart + Image1.Canvas.TextWidth(value);
    if valstart > oldend then
    begin
      Image1.Canvas.TextOut(valstart,YStart+10,value);
      oldend := valend;
    end;
  end;
  xpos := (ImageWidth - Image1.Canvas.TextWidth(XTitle)) div 2;
  Image1.Canvas.TextOut(xpos, YStart + 25, XTitle);
end;

procedure TGraphFrm.MakeYAxis(Sender: TObject);
var
  ypos: integer;
  i: integer;
  incr: Double;
  value: Double;
  valstring: string;
  h: Integer;
  w: Integer;
begin
  h := Image1.Canvas.TextHeight('g');
  Image1.Canvas.Line(XStart, YStart, XStart, YEnd);
  incr := (YMax - YMin) / 20.0;
  for i := 1 to 21 do
  begin
    value := YMin + incr * (i-1);
    ypos := YStart - (i-1) * YAxisLength div 20;
    Image1.Canvas.MoveTo(XStart, ypos);
    Image1.Canvas.LineTo(XStart-10, ypos);
    valstring := Format('%.2f', [value]);
    w := Image1.Canvas.TextWidth(valstring);
    Image1.Canvas.TextOut(XStart - 20 - w, ypos - h div 2, valstring);
  end;
  ypos := YEnd - 10 - Canvas.TextHeight(YTitle);
  Image1.Canvas.TextOut(2, ypos, YTitle);
end;

procedure TGraphFrm.MakeHXaxis(Sender: TObject);
var
   xpos : integer;
   i : integer;
   incr : real;
   value : real;
   valstring : string;

begin
     Image1.Canvas.MoveTo(XStart,YStart);
     Image1.Canvas.LineTo(XEnd,YStart);
     incr := (YMax - YMin) / 20.0;
     for i := 1 to 21 do
     begin
          value := YMin + (incr * (i-1));
          xpos := XStart + ((i-1) * XAxisLength div 20);
          Image1.Canvas.MoveTo(xpos,YStart);
          Image1.Canvas.LineTo(xpos,YStart + 5);
          valstring := format('%6.2f',[value]);
          Image1.Canvas.TextOut(xpos - Image1.Canvas.TextWidth(valstring) div 2,
               YStart + 10,FloatToStr(value));
     end;
     xpos := XAxisLength div 2 - Image1.Canvas.TextWidth(YTitle) div 2;
     Image1.Canvas.TextOut(xpos,YStart + 20,YTitle);
end;
//---------------------------------------------------------------------

procedure TGraphFrm.MakeHYaxis(Sender: TObject);
var
   i : integer;
   ypos : integer;
   value : string;
begin
     Image1.Canvas.MoveTo(XStart,YStart);
     Image1.Canvas.LineTo(XStart,YEnd);
     for i := 1 to NoBars do
     begin
          ypos := YStart - (BarWidth * i) + (BarWidth div 2);
          Image1.Canvas.MoveTo(XStart,ypos);
          Image1.Canvas.LineTo(XStart - 10,ypos);
          value := format('%6.5g',[XPoints[0,i-1]]);
          Image1.Canvas.TextOut(XStart-10-Image1.Canvas.TextWidth(value),
              ypos,value);
     end;
     ypos := YEnd;
     Image1.Canvas.TextOut(0,ypos,XTitle);
end;

procedure TGraphFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([SaveBtn.Width, PrintBtn.Width, ReturnBtn.Width]);
  SaveBtn.Constraints.MinWidth := w;
  PrintBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

//---------------------------------------------------------------------

procedure TGraphFrm.Walls(Sender: TObject);
var
   deep : integer;
   triheight  : integer;
   x1, x2,x3, x4, y1, y2, y3, y4 : integer; // polygon vertices
   bwide : integer;
//   xoffset : integer;

begin
     bwide := round(BarWidth * XProp);
     xoffset := round(bwide * cos(RadAngle));
     XAxisLength := XAxisLength - (NSets * xoffset); // new length of X Axis
     XEnd := XStart + XAxisLength;
     BarWidth := XAxisLength div NoBars; //Adjusted bar width
     bwide := round(BarWidth * XProp);
     xoffset := round(bwide * cos(RadAngle));
     deep := xoffset * NSets;
     triheight := round(bwide * sin(RadAngle) * NSets); // total height of additional y needed
     triheight := triheight div 2; // scale down depth of view
     YAxisLength := YAxisLength - triheight;
     YEnd := YStart - YAxisLength;
     // do left wall
     x1 := XStart;
     x2 := x1 + deep;
     y1 := YStart;
     y2 := YStart - triheight;
     y3 := YStart - YAxisLength - triheight;
     y4 := YEnd;
     Image1.Canvas.Brush.Color := WallColor;
     Image1.Canvas.Polygon([Point(x1,y1),Point(x2,y2),Point(x2,y3),Point(x1,y4)]);
     // do floor
     x1 := XStart;
     x2 := XStart + deep;
     x3 := XEnd;
     x4 := XEnd + deep;
     y1 := YStart;
     y2 := YStart - triheight;
     Image1.Canvas.Brush.Color := FloorColor;
     Image1.Canvas.Polygon([Point(x1,y1),Point(x3,y1),Point(x4,y2),Point(x2,y2)]);
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pHBar2D(Sender: TObject);
var
   j : integer;
   x1, y1, x2, y2 : integer;
   bwidth : integer;
   ypos : integer;
   xdist : real;
   yprop : real;
begin
     BarWidth := YAxisLength div NoBars;
     pMakeHXAxis(self);
     pMakeHYAxis(self);
     { Make bar for each y data point }
     for j := 1 to NoBars do
     begin
          Printer.Canvas.Brush.Color := Colors[j mod 12];
          bwidth := round(XProp * BarWidth);
          ypos := YStart - (BarWidth * j) + (BarWidth div 2); // bar center
          y1 := ypos - (bwidth div 2);
          y2 := y1 + bwidth;
          x1 := XStart;
          yprop := (YPoints[0,j-1] - YMin) / (YMax - YMin);
          xdist := yprop * XAxisLength;
          x2 := XStart + round(xdist);
          Printer.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x2,y2),Point(x1,y2)]);
     end;
end;
//-----------------------------------------------------------------------

procedure TGraphFrm.pHBar3D(Sender: TObject);
var
   i, j : integer;
   x1, x2, x3, x4, y1, y2, y3, y4 : integer;
   triheight : integer;
   bwidth : integer;
   ypos : integer;
   xdist : real;
   yprop : real;
//   yoffset : integer;
//   xoffset : integer;
   triwidth : integer;

begin
     pWalls(self); // create left and bottom wall and axes
     BarWidth := YAxisLength div NoBars;
     Printer.Canvas.Brush.Color := BackColor;
     pMakeHXAxis(self);
     pMakeHYAxis(self);
     bwidth := round(XProp * BarWidth);
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     for i := 1 to NSets do
     begin
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          { Make bar for each y data point }
          for j := 1 to NoBars do
          begin
               // do face
               Printer.Canvas.Brush.Color := Colors[j mod 12];
               ypos := YStart - (BarWidth * j) + (BarWidth div 2); // bar center
               y1 := ypos - (bwidth div 2) - yoffset;
               y2 := y1 + bwidth;
               x1 := XStart + xoffset;
               yprop := (YPoints[0,j-1] - YMin) / (YMax - YMin);
               xdist := yprop * XAxisLength;
               x2 := XStart + round(xdist) + xoffset;
               Printer.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x2,y2),Point(x1,y2)]);
               // do side (end of bar )
               x1 := x2;
               x2 := x1 + triwidth;
               y1 := y2;
               y2 := y1 - triheight;
               y3 := y2 - bwidth;
               y4 := y1 - bwidth;
               Printer.Canvas.Polygon([Point(x1,y1),Point(x2,y2),Point(x2,y3),Point(x1,y4)]);
               // do top of bar
               x3 := XStart + xoffset;
               x4 := x3 + triwidth;
               Printer.Canvas.Polygon([Point(x3,y4),Point(x1,y4),Point(x2,y3),Point(x4,y3)]);
          end;
     end;
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pWalls(Sender: TObject);
var
   deep : integer;
   triheight  : integer;
   x1, x2,x3, x4, y1, y2, y3, y4 : integer; // polygon vertices
   bwide : integer;
//   xoffset : integer;

begin
     bwide := round(BarWidth * XProp);
     xoffset := round(bwide * cos(RadAngle));
     XAxisLength := XAxisLength - (NSets * xoffset); // new length of X Axis
     XEnd := XStart + XAxisLength;
     BarWidth := XAxisLength div NoBars; //Adjusted bar width
     bwide := round(BarWidth * XProp);
     xoffset := round(bwide * cos(RadAngle));
     deep := xoffset * NSets;
     triheight := round(bwide * sin(RadAngle) * NSets); // total height of additional y needed
     triheight := triheight div 2; // scale down depth of view
     YAxisLength := YAxisLength - triheight;
     YEnd := YStart - YAxisLength;
     // do left wall
     x1 := XStart;
     x2 := x1 + deep;
     y1 := YStart;
     y2 := YStart - triheight;
     y3 := YStart - YAxisLength - triheight;
     y4 := YEnd;
     Printer.Canvas.Brush.Color := WallColor;
     Printer.Canvas.Polygon([Point(x1,y1),Point(x2,y2),Point(x2,y3),Point(x1,y4)]);
     // do floor
     x1 := XStart;
     x2 := XStart + deep;
     x3 := XEnd;
     x4 := XEnd + deep;
     y1 := YStart;
     y2 := YStart - triheight;
     Printer.Canvas.Brush.Color := FloorColor;
     Printer.Canvas.Polygon([Point(x1,y1),Point(x3,y1),Point(x4,y2),Point(x2,y2)]);
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pBar2D(Sender: TObject);
var
   j : integer;
   x1, y1, x2, y2 : integer;
   bwidth : integer;
   xpos : integer;
   yprop : real;
   ydist : real;
begin
     pMakeXAxis(self);
     pMakeYAxis(self);
     { Make bar for each y data point }
     for j := 1 to NoBars do
     begin
          Printer.Canvas.Brush.Color := Colors[j mod 12];
          bwidth := round(XProp * BarWidth);
          xpos := XStart + (BarWidth * j) - (BarWidth div 2);
          x1 := xpos - (bwidth div 2);
          x2 := x1 + bwidth;
          y1 := YStart;
          yprop := (YPoints[0,j-1] - YMin) / (YMax - YMin);
          ydist := yprop * YAxisLength;
          y2 := YStart - round(ydist);
          Printer.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x2,y2),Point(x1,y2)]);
     end;
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pBar3D(Sender: TObject);
var
   i, j : integer;
   x1, x2, x3, x4, y1, y2, y3, y4 : integer;
   triheight : integer;
   bwidth : integer;
   yprop : real;
//   yoffset : integer;
//   xoffset : integer;
   xpos : integer;
   ydist : integer;
   triwidth : integer;

begin
     pWalls(self); // create left and bottom wall and axes
     Printer.Canvas.Brush.Color := BackColor;
     pMakeXAxis(self);
     pMakeYAxis(self);
     bwidth := round(XProp * BarWidth);
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     for i := NSets downto 1 do
     begin
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          for j := 1 to NoBars do
          begin
               Printer.Canvas.Brush.Color := Colors[j mod 12];
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x1 := xpos - (bwidth div 2);
               x2 := x1 + bwidth;
               y1 := YStart;
               yprop := (YPoints[i-1,j-1] - YMin) / (YMax - YMin);
               ydist := round(yprop * YAxisLength);
               y2 := YStart - round(ydist);
               x1 := x1 + xoffset;
               x2 := x2 + xoffset;
               y1 := y1 - yoffset;
               y2 := y2 - yoffset;
               // draw face
               Printer.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x2,y2),Point(x1,y2)]);
               // draw side
               x1 := x2;
               x2 := x1 + triwidth;
               y2 := y1 - triheight;
               y3 := y1 - round(ydist);
               y4 := y2 - round(ydist);
               Printer.Canvas.Polygon([Point(x1,y1),Point(x2,y2),Point(x2,y4),Point(x1,y3)]);
               // draw top
               x1 := xpos - (bwidth div 2) + xoffset;
               x2 := x1 + bwidth;
               x3 :=  x2 + triwidth;
               x4 := x1 + triwidth;
               y1 := YStart - yoffset {%H-}- round(ydist);
               y2 := y1 - triheight;
               Printer.Canvas.Polygon([Point(x1,y1),Point(x2,y1),Point(x3,y2),Point(x4,y2)]);
          end;
          x1 := XStart + XAxisLength + xoffset;
          y1 := YStart - triheight * i;
          Printer.Canvas.Brush.Color := clWhite;
          Printer.Canvas.TextOut(x1,y1,SetLabels[i]);
     end;
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pPie2D(Sender: TObject);
var
   i : integer;
   x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6 : integer;
   yprop : real;
   xcenter, ycenter : double;
   Total : double;
   radians : double;
   radius : integer;
   cum : double;
   value : string;

begin
   xcenter := ImageWidth div 2;
   ycenter := ImageHeight div 2;

   // get the total for obtaining proportions that each y point is of the total
   Total := 0.0;
   cum := 0.0;
   radius := round(ycenter) - YOffset;
   x1 := ImageWidth div 2 - Printer.Canvas.TextWidth(XTitle) div 2;
   Printer.Canvas.TextOut(x1,YStart + 25,XTitle);
   x1 := round(xcenter-radius); // left of rectangle
   y1 := round(ycenter-radius); // top of rectangle
   x2 := round(xcenter + radius); // right of rectangle
   y2 := round(ycenter + radius); // bottom of rectangle
   x3 := x2;
   y3 := round(ycenter);
   for i := 1 to NoBars do Total := Total + YPoints[0,i-1];
   // plot an arc corresponding to each proportion starting at radian 0
   for i := 1 to NoBars do
   begin
        yprop := YPoints[0,i-1] / Total;
        cum := cum + yprop;
        radians := cum * 2.0 * Pi;
        x4 := round(xcenter + radius * cos(radians));
        y4 := round(ycenter - (radius * sin(radians)));
        Printer.Canvas.Brush.Color := Colors[i mod 12];
        if yprop > 0.0 then
        begin
           Printer.Canvas.Pie(x1,y1,x2,y2,x3,y3,x4,y4);
           radians := (cum - (yprop / 2.0)) * 2.0 * Pi;
           x5 := round(xcenter + radius * cos(radians));
           y5 := round(ycenter - radius * sin(radians));
           Printer.Canvas.MoveTo(x5,y5);
           if x5 >= round(xcenter) then x6 := x5 + 50
           else x6 := x5 - 50;
           if y5 >= round(ycenter) then y6 := y5 + 50
           else y6 := y5 - 50;
           Printer.Canvas.LineTo(x6,y6);
           Printer.Canvas.Brush.Color := BackColor;
           value := format('%8.5g',[XPoints[0,i-1]]);
           Printer.Canvas.TextOut(x6,y6,value);
           if x5 >= round(xcenter) then x6 := x5 - 50
           else x6 := x5 + 50;
           if y5 >= round(ycenter) then y6 := y5 - 50
           else y6 := y5 + 50;
           value := format('%4.2f',[yprop*100.0]);
           value := value + '%';
           Printer.Canvas.TextOut(x6,y6,value);
           x3 := x4;
           y3 := y4;
        end;
   end;
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pExPie(Sender: TObject);
var
   i : integer;
   x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6 : integer;
   yprop : real;
   xcenter, ycenter : double;
   Total : double;
   radians : double;
   midradians : double;
   radius : integer;
   cum : double;
   value : string;

begin
   ycenter := ImageHeight div 2;
   // get the total for obtaining proportions that each y point is of the total
   Total := 0.0;
   cum := 0.0;
   radius := round(ycenter) - YOffset;
   x1 := ImageWidth div 2 - Printer.Canvas.TextWidth(XTitle) div 2;
   Printer.Canvas.TextOut(x1,YStart + 25,XTitle);
   for i := 1 to NoBars do Total := Total + YPoints[0,i-1];
   // plot an arc corresponding to each proportion starting at radian 0
   for i := 1 to NoBars do
   begin
        xcenter := ImageWidth div 2;
        ycenter := ImageHeight div 2;
        yprop := YPoints[0,i-1] / Total;
        cum := cum + yprop;
        radians := cum * 2.0 * Pi;
        midradians := (cum - (yprop / 2.0)) * 2.0 * Pi;
        x5 := round(xcenter + radius * cos(midradians));
        y5 := round(ycenter - radius * sin(midradians));
        // explode pie by shifting slices away from center
        if x5 >= round(xcenter) then xcenter := xcenter + 10
        else xcenter := xcenter - 10;
        if y5 >= round(ycenter) then ycenter := ycenter + 10
        else ycenter := ycenter - 10;
        x1 := round(xcenter-radius); // left of rectangle
        y1 := round(ycenter-radius); // top of rectangle
        x2 := round(xcenter + radius); // right of rectangle
        y2 := round(ycenter + radius); // bottom of rectangle
        midradians := (cum - yprop ) * 2.0 * Pi;
        x3 := round(xcenter + radius * cos(midradians));
        y3 := round(ycenter - radius * sin(midradians));
        x4 := round(xcenter + radius * cos(radians));
        y4 := round(ycenter - (radius * sin(radians)));
        Printer.Canvas.Brush.Color := Colors[i mod 12];
        if yprop > 0.0 then
        begin
           Printer.Canvas.Pie(x1,y1,x2,y2,x3,y3,x4,y4);
           radians := (cum - (yprop / 2.0)) * 2.0 * Pi;
           x5 := round(xcenter + radius * cos(radians));
           y5 := round(ycenter - radius * sin(radians));
           Printer.Canvas.MoveTo(x5,y5);
           if x5 >= round(xcenter) then x6 := x5 + 50
           else x6 := x5 - 50;
           if y5 >= round(ycenter) then y6 := y5 + 50
           else y6 := y5 - 50;
           Printer.Canvas.LineTo(x6,y6);
           Printer.Canvas.Brush.Color := BackColor;
           value := format('%8.5g',[XPoints[0,i-1]]);
           Printer.Canvas.TextOut(x6,y6,value);
           if x5 >= round(xcenter) then x6 := x5 - 50
           else x6 := x5 + 50;
           if y5 >= round(ycenter) then y6 := y5 - 50
           else y6 := y5 + 50;
           value := format('%4.2f',[yprop*100.0]);
           value := value + '%';
           Printer.Canvas.TextOut(x6,y6,value);
        end;
   end;
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pLine2D(Sender: TObject);
var
   i, j : integer;
   x1, y1, x2, y2 : integer;
   xpos : integer;
   yprop : real;
   ydist : real;
begin
     pMakeXAxis(self);
     pMakeYAxis(self);
     { Make lines for each set of y data point }
     For i := 1 to NSets do
     begin
          Printer.Canvas.Brush.Color := Colors[i mod 12];
          x1 := XStart + BarWidth div 2;
          yprop := (YPoints[i-1,0] - YMin) / (YMax - YMin);
          ydist := yprop * YAxisLength;
          y1 := YStart - round(ydist);
          Printer.Canvas.MoveTo(x1,y1);
          for j := 2 to NoBars do
          begin
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x2 := xpos;
               yprop := (YPoints[i-1,j-1] - YMin) / (YMax - YMin);
               ydist := yprop * YAxisLength;
               y2 := YStart - round(ydist);
               Printer.Canvas.LineTo(x2,y2);
          end;
     end;
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pLine3D(Sender: TObject);
var
   i, j : integer;
   x1, x2, y1, y2 : integer;
   triheight : integer;
   bwidth : integer;
   yprop : real;
//   yoffset : integer;
//   xoffset : integer;
   xpos : integer;
   ydist : integer;
   triwidth : integer;

begin
     pWalls(self); // create left and bottom wall and axes
     Printer.Canvas.Brush.Color := BackColor;
     pMakeXAxis(self);
     pMakeYAxis(self);
     XProp := 1.0;
     bwidth := round(XProp * BarWidth);
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     for i := NSets downto 1 do
     begin
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          for j := 1 to NoBars do
          begin
               //Image1.Canvas.Brush.Color := Colors[j mod 12];
               Printer.Canvas.Pen.Color := Colors[i mod 12];
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x1 := xpos - (bwidth div 2);
               x2 := x1 + bwidth;
               y1 := YStart;
               yprop := (YPoints[i-1,j-1] - YMin) / (YMax - YMin);
               ydist := round(yprop * YAxisLength);
               y2 := YStart - round(ydist);
               x1 := x1 + xoffset;
               x2 := x2 + xoffset;
               y1 := y1 - yoffset;
               y2 := y2 - yoffset;
               Printer.Canvas.MoveTo(x1,y1);
               Printer.Canvas.LineTo(x2,y2);
          end;
          Printer.Canvas.Pen.Color := clBlack;
          x1 := XStart + XAxisLength + xoffset;
          y1 := YStart - triheight * i;
          Printer.Canvas.Brush.Color := clWhite;
          Printer.Canvas.TextOut(x1,y1,SetLabels[i]);
     end;
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pPlot2D(Sender: TObject);
var
   i, j : integer;
   x1, y1 : integer;
   triheight : integer;
   bwidth : integer;
   yprop : real;
//   yoffset : integer;
//   xoffset : integer;
   xpos : integer;
   ydist : integer;
   triwidth : integer;
begin
     pWalls(self); // create left and bottom wall and axes
     Printer.Canvas.Brush.Color := BackColor;
     pMakeXAxis(self);
     pMakeYAxis(self);
     bwidth := round(XProp * BarWidth);
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     { Make points for each set of y data point }
     for i := NSets downto 1 do
     begin
          Printer.Canvas.Brush.Color := Colors[i mod 12];
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          for j := 1 to NoBars do
          begin
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x1 := xpos;
               yprop := (YPoints[i-1,j-1] - YMin) / (YMax - YMin);
               ydist := round(yprop * YAxisLength);
               y1 := YStart - round(ydist);
               x1 := x1 + xoffset;
               y1 := y1 - yoffset;
               if PtLabels then
               begin
                    Printer.Canvas.Brush.Color := BackColor;
                    Printer.Canvas.TextOut(x1,y1,PointLabels[j]);
               end
               else
                   Printer.Canvas.Ellipse(x1-5,y1-5,x1+5,y1+5);
          end;
          Printer.Canvas.Pen.Color := clBlack;
          x1 := XStart + XAxisLength + xoffset;
          y1 := YStart - triheight * i;
          Printer.Canvas.Brush.Color := clWhite;
          Printer.Canvas.TextOut(x1,y1,SetLabels[i]);
     end;
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pPlot3D(Sender: TObject);
var
   i, j : integer;
   x1, y1 : integer;
   yprop : real;
   triheight : integer;
   bwidth : integer;
//   yoffset : integer;
//   xoffset : integer;
   xpos : integer;
   ydist : integer;
   triwidth : integer;
begin
     pWalls(self); // create left and bottom wall and axes
     Printer.Canvas.Brush.Color := BackColor;
     pMakeXAxis(self);
     pMakeYAxis(self);
     bwidth := round(XProp * BarWidth);
     triwidth := round(bwidth * cos(RadAngle));
     triheight := round(bwidth * sin(RadAngle));
     triheight := triheight div 2; // scale down depth of view
     { Make points for each set of y data point }
     for i := NSets downto 1 do
     begin
          Printer.Canvas.Brush.Color := Colors[i mod 12];
          xoffset := triwidth * (i - 1);
          yoffset := triheight * (i - 1);
          for j := 1 to NoBars do
          begin
               xpos := XStart + (BarWidth * j) - (BarWidth div 2);
               x1 := xpos;
               yprop := (YPoints[i-1,j-1] - YMin) / (YMax - YMin);
               ydist := round(yprop * YAxisLength);
               y1 := YStart - round(ydist);
               x1 := x1 + xoffset;
               y1 := y1 - yoffset;
               // change next to a ball by drawing multiple Ellipses around
               // vertical axis ?
               Printer.Canvas.Ellipse(x1-5,y1-5,x1+5,y1+5);
               Printer.Canvas.Ellipse(x1-4,y1-5,x1+4,y1+5);
               Printer.Canvas.Ellipse(x1-3,y1-5,x1+3,y1+5);
               Printer.Canvas.Ellipse(x1-2,y1-5,x1+2,y1+5);
          end;
          Printer.Canvas.Pen.Color := clBlack;
          x1 := XStart + XAxisLength + xoffset;
          y1 := YStart - triheight * i;
          Printer.Canvas.Brush.Color := clWhite;
          Printer.Canvas.TextOut(x1,y1,SetLabels[i]);
     end;
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pMakeXAxis(Sender: TObject);
var
   i, valstart, valend, oldend : integer;
   xpos : integer;
   value : string;
begin
     Printer.Canvas.MoveTo(XStart,YStart);
     Printer.Canvas.LineTo(XEnd,YStart);
     oldend := 0;
     for i := 1 to NoBars do
     begin
          xpos := XStart + (BarWidth * i) - (BarWidth div 2);
          Printer.Canvas.MoveTo(xpos,YStart);
          Printer.Canvas.LineTo(xpos,YStart + 5);
          value := format('%6.5g',[XPoints[0,i-1]]);
          valstart := xpos - Printer.Canvas.TextWidth(value) div 2;
          valend := valstart + Printer.Canvas.TextWidth(value);
          if valstart > oldend then
          begin
               Printer.Canvas.TextOut(valstart,YStart + 10,value);
               oldend := valend;
          end;
     end;
     xpos := ImageWidth div 2 - Printer.Canvas.TextWidth(XTitle) div 2;
     Printer.Canvas.TextOut(xpos,YStart + 100,XTitle);
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pMakeYaxis(Sender: TObject);
var
   ypos : integer;
   i : integer;
   incr : real;
   value : real;
   valstring : string;

begin
     Printer.Canvas.MoveTo(XStart,YStart);
     Printer.Canvas.LineTo(XStart,YEnd);
     incr := (YMax - YMin) / 20.0;
     for i := 1 to 21 do
     begin
          value := YMin + (incr * (i-1));
          ypos := YStart - ((i-1) * YAxisLength div 20);
          Printer.Canvas.MoveTo(XStart,ypos);
          Printer.Canvas.LineTo(XStart-10,ypos);
          valstring := format('%10.2f',[value]);
          Printer.Canvas.TextOut(XStart - 10 - Printer.Canvas.TextWidth(valstring),ypos,valstring);
     end;
     ypos := YEnd - 10 - Printer.Canvas.TextHeight(YTitle);
     Printer.Canvas.TextOut(100,ypos,YTitle);
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pMakeHXaxis(Sender: TObject);
var
   xpos : integer;
   i : integer;
   incr : real;
   value : real;
   valstring : string;

begin
     Printer.Canvas.MoveTo(XStart,YStart);
     Printer.Canvas.LineTo(XEnd,YStart);
     incr := (YMax - YMin) / 20.0;
     for i := 1 to 21 do
     begin
          value := YMin + (incr * (i-1));
          xpos := XStart + ((i-1) * XAxisLength div 20);
          Printer.Canvas.MoveTo(xpos,YStart);
          Printer.Canvas.LineTo(xpos,YStart + 5);
          valstring := format('%8.2f',[value]);
          Printer.Canvas.TextOut(xpos - Printer.Canvas.TextWidth(valstring) div 2,
               YStart + 10,FloatToStr(value));
     end;
     xpos := XAxisLength div 2 - Printer.Canvas.TextWidth(YTitle) div 2;
     Printer.Canvas.TextOut(xpos,YStart + 100,YTitle);
end;
//-----------------------------------------------------------------------
procedure TGraphFrm.pMakeHYaxis(Sender: TObject);
var
   i : integer;
   ypos : integer;
   value : string;
begin
     Printer.Canvas.MoveTo(XStart,YStart);
     Printer.Canvas.LineTo(XStart,YEnd);
     for i := 1 to NoBars do
     begin
          ypos := YStart - (BarWidth * i) + (BarWidth div 2);
          Printer.Canvas.MoveTo(XStart,ypos);
          Printer.Canvas.LineTo(XStart - 10,ypos);
          value := format('%6.5g',[XPoints[0,i-1]]);
          Printer.Canvas.TextOut(XStart-10-Printer.Canvas.TextWidth(value),
              ypos,value);
     end;
     ypos := YEnd;
     Printer.Canvas.TextOut(100,ypos,XTitle);
end;
//-----------------------------------------------------------------------

initialization
  {$I graphlib.lrs}

end.

