unit RotateUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Printers,
  Globals;

type

  { TRotateFrm }

  TRotateFrm = class(TForm)
    Bevel1: TBevel;
    Image1: TImage;
    NextBtn: TButton;
    PrintBtn: TButton;
    ReturnBtn: TButton;
    DegEdit: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    ScrollBar1: TScrollBar;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
  private
    { private declarations }
    Axis1, Axis2 : integer;
    ClWidth, ClHeight, XStart, XEnd, YStart, YEnd : integer;
    Xoffset, Yoffset, XaxisLength, YaxisLength : integer;
    Axis1Pos, Axis2Pos : integer;
    q : DblDyneMat;
    procedure PlotPts(AxisOne, AxisTwo : integer; acolor : TColor; Sender : TObject);
    procedure DrawAxis(Sender : TObject);

  public
    { public declarations }
    Loadings : DblDyneMat;
    NoVars : integer;
    NoRoots : integer;
    RowLabels : StrDyneVec;
    ColLabels : StrDyneVec;
    Order : IntDyneVec;
  end; 

var
  RotateFrm: TRotateFrm;

implementation

uses
  Math;

{ TRotateFrm }

procedure TRotateFrm.ReturnBtnClick(Sender: TObject);
VAR i, j : integer;
begin
     for i := 1 to NoVars do
     BEGIN
          for j := 1 to NoRoots do Loadings[i-1,j-1] := q[i-1,j-1];
     END;
     q := nil;
     Close;
end;

procedure TRotateFrm.ScrollBar1Change(Sender: TObject);
var
   D, A, B : double;
   i, j, l : integer;
   AxisOne, AxisTwo : integer;
begin
     AxisOne := Axis1;
     AxisTwo := Axis2;
     PlotPts(AxisOne,AxisTwo,clWhite,self); // erase previous
     DrawAxis(self);
     for i := 1 to NoVars do
     begin
          for j := 1 to NoRoots do q[i-1,j-1] := Loadings[i-1,j-1];
     end;

     D := ScrollBar1.Position;
     DegEdit.Text := FloatToStr(D);
     D := D / 57.2958; // convert to radians
     for l := 1 to NoVars do
     BEGIN
          A := sin(D);
          B := cos(D);
          q[l-1,AxisOne-1] := Loadings[l-1,AxisOne-1] * B - Loadings[l-1,AxisTwo-1] * A;
          q[l-1,AxisTwo-1] := Loadings[l-1,AxisOne-1] * A + Loadings[l-1,AxisTwo-1] * B;
     END;

     PlotPts(AxisOne,AxisTwo,clBlack,self); // plot new
end;

procedure TRotateFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([NextBtn.Width, PrintBtn.Width, ReturnBtn.Width]);
  NextBtn.Constraints.MinWidth := w;
  PrintBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure TRotateFrm.FormShow(Sender: TObject);
VAR i, j : integer;
begin
     if NoRoots < 2 then
     begin
          ShowMessage('ERROR! Only 1 factor-exiting');
          exit;
     end;
     SetLength(q,NoVars,NoVars);
     for i := 1 to NoVars do
     begin
          for j := 1 to NoRoots do q[i-1,j-1] := Loadings[i-1,j-1];
     end;
     ClWidth := Image1.Width;
     ClHeight := Image1.Height;
     XOffset := ClWidth div 10;
     YOffset := ClHeight div 10;
     XStart := Xoffset;
     XEnd := ClWidth - XOffset;
     XAxisLength := XEnd - XStart;
     YStart := ClHeight - YOffset;
     YEnd := YOffset;
     YAxisLength := YStart - YEnd;
     Image1.Canvas.Brush.Color := clWhite;
     Image1.Canvas.Pen.Color := clBlack;
     Image1.Canvas.Rectangle(0,0,ClWidth,ClHeight);
     Axis1 := 1;
     Axis2 := 2;
     Axis2Pos := XAxisLength div 2 + XStart; // position of y axis from left
     Axis1Pos := YAxisLength div 2 + YEnd; // position of X axis from top
     ScrollBar1.Position := 0;
     DrawAxis(self);
     PlotPts(Axis1, Axis2, clBlack, self);
end;

procedure TRotateFrm.NextBtnClick(Sender: TObject);
VAR i, j : integer;
begin
     if (Axis2 = NoRoots) and (Axis1 = NoRoots-1) then
     begin
          ShowMessage('ALL DONE! All pairs completed.');
          exit;
     end;
     PlotPts(Axis1,Axis2,clWhite,self);
     for i := 1 to NoVars do
     BEGIN
          for j := 1 to NoRoots do Loadings[i-1,j-1] := q[i-1,j-1];
     END;

     Axis2 := Axis2 + 1;
     if Axis2 <= NoRoots then
     begin
          ScrollBar1.Position := 0;
          DrawAxis(self);
          PlotPts(Axis1,Axis2,clBlack,self);
          exit;
     end;
     Axis1 := Axis1 + 1;
     Axis2 := Axis1 + 1;
     if Axis2 > NoRoots then exit;
     ScrollBar1.Position := 0;
     DrawAxis(self);
     PlotPts(Axis1,Axis2,clBlack,self);
end;

procedure TRotateFrm.PrintBtnClick(Sender: TObject);
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

procedure TRotateFrm.PlotPts(AxisOne, AxisTwo: integer; acolor: TColor;
  Sender: TObject);
var i, xpos, ypos, xmid, ymid, size : integer;
begin
     xmid := Axis2Pos;
     ymid := Axis1Pos;
     Image1.Canvas.Pen.Color := acolor;
//     if color <> clWhite then size := 2 else size := 4;
     size := 4;
     for i := 1 to NoVars do
     begin
          if q[i-1,AxisOne-1] >= 0 then  // positive x value
          begin
               xpos := round(q[i-1,AxisOne-1] * (XAxisLength div 2));
               xpos := xpos + xmid;
          end
          else // negative x value (factor 1)
          begin
               xpos := round(abs(q[i-1,AxisOne-1]) * (XAxisLength div 2));
               xpos := xmid - xpos;
          end;
          if q[i-1,AxisTwo-1] >= 0 then // positive y value (factor 2)
          begin
               ypos := round(q[i-1,AxisTwo-1] * (YAxisLength div 2));
               ypos := ymid - ypos;
          end
          else  // negative y factor loading
          begin
               ypos := round(abs(q[i-1,AxisTwo-1]) * (YAxisLength div 2));
               ypos := ymid + ypos;
          end;

          Image1.Canvas.Ellipse(xpos-size,ypos-size,xpos+size,Ypos+size);
     end;
     DrawAxis(self);
end;

procedure TRotateFrm.DrawAxis(Sender: TObject);
var
   i, xincr, yincr, TextLong : integer;
   step : double;
   Title : string;
begin
     xincr := XAxisLength div 10;
     yincr := YAxisLength div 10;

     // draw X axis
     Image1.Canvas.MoveTo(XOffset,Axis1Pos);
     Image1.Canvas.LineTo(XEnd,Axis1Pos);
     Title := 'Factor ' + IntToStr(Axis1);
     Image1.Canvas.TextOut(0,Axis1Pos,Title);
     step := -1.0;
     for i := 0 to 10 do
     begin
          Title := format('%4.1f',[step]);
          Image1.Canvas.TextOut(XOffset+xincr*i,Axis1Pos+2,Title);
          step := step + 0.2;
     end;
     // draw Y axis
     Image1.Canvas.MoveTo(Axis2Pos,YEnd);
     Image1.Canvas.LineTo(Axis2Pos,YStart);
     Title := 'Factor ' + IntToStr(Axis2);
     Image1.Canvas.TextOut(Axis2Pos,0,Title);
     step := -1.0;
     for i := 0 to 10 do
     begin
          Title := format('%4.1f',[step]);
          TextLong := Image1.Canvas.TextWidth(Title);
          Image1.Canvas.TextOut(Axis2Pos-TextLong,YStart-(i*yincr),Title);
          step := step + 0.2;
     end;
end;


initialization
  {$I rotateunit.lrs}

end.

