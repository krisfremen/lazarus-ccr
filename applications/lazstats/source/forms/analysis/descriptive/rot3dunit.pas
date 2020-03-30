unit Rot3dUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Printers, PrintersDlgs,
  MainUnit, Globals, DataProcs;


type

  { TRot3DFrm }

  TRot3DFrm = class(TForm)
    Image1: TImage;
    PrintDialog: TPrintDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    ResetBtn: TButton;
    PrintBtn: TButton;
    CloseBtn: TButton;
    ZEdit: TEdit;
    Label15: TLabel;
    YEdit: TEdit;
    Label14: TLabel;
    XEdit: TEdit;
    Label13: TLabel;
    XDegEdit: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    XScroll: TScrollBar;
    YScroll: TScrollBar;
    ZScroll: TScrollBar;
    VarList: TListBox;
    YDegEdit: TEdit;
    ZDegEdit: TEdit;
    procedure CancelBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListClick(Sender: TObject);
    procedure XScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure YScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ZScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
  private
    { private declarations }
    DXmax, DXmin, DYmax, DYmin : integer;
    WXleft, WXright, WYtop, WYbottom, RX, RY, RZ : double;
    SINRX, COSRX, SINRY, COSRY, SINRZ, COSRZ : double;
    GridColX, GridColY, GridColZ : integer;
    degX, degY, degZ : double;
    XScaled : DblDyneVec;
    YScaled : DblDyneVec;
    ZScaled : DblDyneVec;

    procedure Rotate(Sender: TObject);
    function DegToRad(deg : double; Sender: TObject) : double;
    function World3DToWorld2D(p : POINT3D; Sender: TObject) : POINT3D;
    function World2DToDevice(p :POINT3D; Sender: TObject) : POINTint;
    procedure DrawPoint( p1 : POINT3D; Sender: TObject);
    procedure DrawLine(p1, p2 : POINT3D; Sender: TObject);
    procedure DrawAxis(Sender: TObject);
    procedure SetAxesAngles(rx1, ry1, rz1 : double; Sender: TObject);
    procedure ScaleValues(Sender: TObject);
    procedure EraseAxis(Sender: TObject);

  public
    { public declarations }
  end; 

var
  Rot3DFrm: TRot3DFrm;

implementation

uses
  Math;

{ TRot3DFrm }

procedure TRot3DFrm.ResetBtnClick(Sender: TObject);
var i : integer;
begin
    VarList.Items.Clear;
    for i := 1 to NoVariables do
        VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
    XScroll.Position := 0;
    YScroll.Position := 0;
    ZScroll.Position := 0;
    // set device limits
    DXmin := 36;
    DXmax := 436;
    DYmin := 36;
    DYmax := 436;
    // set world limits
    WXleft := -1.0;
    WYbottom := -1.0;
    WXright := 1.0;
    WYtop := 1.0;
    XDegEdit.Text := '0';
    YDegEdit.Text := '0';
    ZDegEdit.Text := '0';
    XEdit.Text := '';
    YEdit.Text := '';
    ZEdit.Text := '';
end;

procedure TRot3DFrm.VarListClick(Sender: TObject);
var
   i, index : integer;
   Xvar, Yvar, Zvar : string;

begin
    index := VarList.ItemIndex;
    if XEdit.Text = '' then
    begin
        XEdit.Text := VarList.Items.Strings[index];
        exit;
    end;
    if YEdit.Text = '' then
    begin
        YEdit.Text := VarList.Items.Strings[index];
        exit;
    end;
    ZEdit.Text := VarList.Items.Strings[index];
    // Get column no.s of selected variables
    Xvar := XEdit.Text;
    Yvar := YEdit.Text;
    Zvar := ZEdit.Text;
    for i := 1 to NoVariables do
    begin
        if Xvar = OS3MainFrm.DataGrid.Cells[i,0] then GridColX := i;
        if Yvar = OS3MainFrm.DataGrid.Cells[i,0] then GridColY := i;
        if Zvar = OS3MainFrm.DataGrid.Cells[i,0] then GridColZ := i;
    end;
    ScaleValues(self); // get scaled X, y and Z values (-1.0 to 1.0)
    XScroll.Position := 20;
    YScroll.Position := -15;
    ZScroll.Position := -5;
    Canvas.Pen.Color := clBlack;
    Rotate(self);
end;

procedure TRot3DFrm.XScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  Rotate(self);
end;

procedure TRot3DFrm.YScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  Rotate(self);
end;

procedure TRot3DFrm.ZScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  Rotate(self);
end;

procedure TRot3DFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TRot3DFrm.PrintBtnClick(Sender: TObject);
var
   labelstr : string;
   p1, p2, p, pa, pb : POINT3D;
   p11, p22 : POINTint;
   i, t, X : integer;
   offset, Clwidth, Clheight : double;

begin
  if not PrintDialog.Execute then
    exit;

  labelstr := '3D PLOT';
  Clwidth :=  Printer.PageWidth;
  Clheight := Clwidth;
  offset := Clwidth / 20.0;

  Clwidth := Clwidth - (Clwidth / 20.0);
  Printer.BeginDoc;
  try
    // First, draw axis
    p1.x := -1;
    p1.y := 0;
    p1.z := 0;
    p2.x := 1;
    p2.y := 0;
    p2.z := 0;
    Printer.Canvas.Pen.Color := clRed;

    //draw a 3d line
    p1.z := -p1.z;
    p2.z := -p2.z;
    pa := World3DToWorld2D(p1,self);
    pb := World3DToWorld2D(p2,self);

    // scale it up
    p11.x := round((WXleft-pa.x)*(Clwidth-offset) / (WXleft - WXright)+ offset + 0.5);
    p11.y := round((WYtop-pa.y)*(Clheight-offset) / (WYtop-WYbottom) + offset + 0.5);
    p22.x := round((WXleft-pb.x)*(Clwidth-offset) / (WXleft - WXright) + offset + 0.5);
    p22.y := round((WYtop-pb.y)*(Clheight-offset) / (WYtop-WYbottom) + offset + 0.5);
    Printer.Canvas.MoveTo(p11.x,p11.y);
    Printer.Canvas.LineTo(p22.x,p22.y);
    p1.x := 0;
    p1.y := -1;
    p2.x := 0;
    p2.y := 1;
    p2.z := 0;
    Printer.Canvas.Pen.Color := clBlue;

    //draw a 3d line
    p1.z := -p1.z;
    p2.z := -p2.z;
    pa := World3DToWorld2D(p1,self);
    pb := World3DToWorld2D(p2,self);

    // scale it up
    p11.x := round((WXleft-pa.x)*(Clwidth-offset) / (WXleft - WXright)+ offset + 0.5);
    p11.y := round((WYtop-pa.y)*(Clheight-offset) / (WYtop-WYbottom) + offset + 0.5);
    p22.x := round((WXleft-pb.x)*(Clwidth-offset) / (WXleft - WXright) + offset + 0.5);
    p22.y := round((WYtop-pb.y)*(Clheight-offset) / (WYtop-WYbottom) + offset + 0.5);
    Printer.Canvas.MoveTo(p11.x,p11.y);
    Printer.Canvas.LineTo(p22.x,p22.y);
    p1.y := 0;
    p1.z := -1;
    p2.x := 0;
    p2.y := 0;
    p2.z := 1;
    Printer.Canvas.Pen.Color := clGreen;

    //draw a 3d line
    p1.z := -p1.z;
    p2.z := -p2.z;
    pa := World3DToWorld2D(p1,self);
    pb := World3DToWorld2D(p2,self);

    // scale it up
    p11.x := round((WXleft-pa.x)*(Clwidth-offset) / (WXleft - WXright)+ offset + 0.5);
    p11.y := round((WYtop-pa.y)*(Clheight-offset) / (WYtop-WYbottom) + offset + 0.5);
    p22.x := round((WXleft-pb.x)*(Clwidth-offset) / (WXleft - WXright) + offset + 0.5);
    p22.y := round((WYtop-pb.y)*(Clheight-offset) / (WYtop-WYbottom) + offset + 0.5);
    Printer.Canvas.MoveTo(p11.x,p11.y);
    Printer.Canvas.LineTo(p22.x,p22.y);
    Printer.Canvas.Pen.Color := clBlack;

    //Now, plot points
    for i := 1 to NoCases do
    begin
        p.x := XScaled[i];
        p.y := YScaled[i];
        p.z := ZScaled[i];
        // draws a 3d point
        p.z := -p.z;
        pa := World3DToWorld2D(p,self);
        // scale it up
        p11.x := round((WXleft-pa.x)*(Clwidth-offset) / (WXleft - WXright) + offset + 0.5);
        p11.y := round((WYtop-pa.y)*(Clheight-offset) / (WYtop-WYbottom) + offset + 0.5);
        Printer.Canvas.Rectangle(p11.x - 4,p11.y - 4,p11.x + 4, p11.y + 4);
    end;

    // Print Heading
    t := Printer.Canvas.TextWidth(labelstr);
    X := round((Clwidth / 2.0) - (t / 2.0));
    Printer.Canvas.TextOut(X,0,labelstr);
    labelstr := 'RED := X, BLUE := Y, GREEN := Z';
    t := Printer.Canvas.TextWidth(labelstr);
    X := round((Clwidth / 2.0) - (t / 2.0));
    Printer.Canvas.TextOut(X,round(Clheight),labelstr);
    labelstr := XEdit.Text;
    labelstr := labelstr + '  ';
    labelstr := labelstr + YEdit.Text;
    labelstr := labelstr + '  ';
    labelstr := labelstr + ZEdit.Text;
    t := Printer.Canvas.TextWidth(labelstr);
    X := round((Clwidth / 2.0) - (t / 2.0));
    Printer.Canvas.TextOut(X,round(Clheight+40.0),labelstr);
    labelstr := 'ROTATION: X deg. := ';
    labelstr := labelstr + XDegEdit.Text;
    labelstr := labelstr + '  Y deg. := ';
    labelstr := labelstr + YDegEdit.Text;
    labelstr := labelstr + '  Z deg. := ';
    labelstr := labelstr + ZDegEdit.Text;
    t := Printer.Canvas.TextWidth(labelstr);
    X := round((Clwidth / 2.0) - (t / 2));
    Printer.Canvas.TextOut(X,round(Clheight+80.0),labelstr);

  finally
    Printer.EndDoc;    // finish printing
  end;
end;

procedure TRot3DFrm.CancelBtnClick(Sender: TObject);
begin
     ZScaled := nil;
     YScaled := nil;
     XScaled := nil;
     Close;
end;

procedure TRot3DFrm.Rotate(Sender: TObject);
var
  p: POINT3D;
  i: integer;
begin
  Image1.Canvas.Brush.Style := bsSolid;
  Image1.Canvas.Brush.Color := clLtGray;
  Image1.Canvas.FillRect(0, 0, Image1.Width, Image1.Height);

  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Rectangle(20,20,460,460);

  //First, erase current points
  Image1.Canvas.Pen.Color := clWhite;
  Image1.Canvas.Brush.Color := clWhite;
  for i := 1 to NoCases do
  begin
    p.x := XScaled[i];
    p.y := YScaled[i];
    p.z := ZScaled[i];
    DrawPoint(p,self);
  end;
  EraseAxis(self);
  Image1.Canvas.Brush.Color := clBlack;
  Image1.Canvas.Pen.Color := clBlack;
  degX := XScroll.Position;
  degY := YScroll.Position;
  degZ := ZScroll.Position;
  XDegEdit.Text := IntToStr(XScroll.Position);
  YDegEdit.Text := IntToStr(YScroll.Position);
  ZDegEdit.Text := IntToStr(ZScroll.Position);
  SetAxesAngles(degX, degY, degZ,self);
  DrawAxis(self);
  for i := 1 to NoCases do
  begin
    p.x := XScaled[i];
    p.y := YScaled[i];
    p.z := ZScaled[i];
    DrawPoint(p,self);
  end;
end;
//---------------------------------------------------------------------------

function TRot3DFrm.DegToRad(deg : double; Sender: TObject) : double;
begin
  Result :=  deg * PI / 180.0;
end;
//---------------------------------------------------------------------------

function TRot3DFrm.World3DToWorld2D(p : POINT3D; Sender: TObject) : POINT3D;
var
   ptemp : POINT3D;
begin
    ptemp := p;
    if RX <> 0.0 then begin
        ptemp.x := p.x;
        ptemp.y := COSRX * p.y - SINRX * p.z;
        ptemp.z := SINRX * p.y + COSRX * p.z;
        p := ptemp;
    end;
    if RY <> 0.0 then begin
        ptemp.x := COSRY * p.x + SINRY * p.z;
        ptemp.y := p.y;
        ptemp.z := SINRY * p.x + COSRY * p.z;
        p := ptemp;
    end;
    if RZ <> 0.0 then begin
        ptemp.x := COSRZ * p.x - SINRZ * p.y;
        ptemp.y := SINRZ * p.x + COSRZ * p.y;
        ptemp.z := p.z;
    end;
    if abs(ptemp.x) < TOL then ptemp.x := 0.0;
    if abs(ptemp.y) < TOL then ptemp.y := 0.0;
    if abs(ptemp.z) < TOL then ptemp.z := 0.0;
    Result := ptemp;
end;
//---------------------------------------------------------------------------

function TRot3DFrm.World2DToDevice(p :POINT3D; Sender: TObject) : POINTint;
var
   ptemp : POINTint;
begin
    ptemp.x := round((WXleft - p.x) * (DXmax - DXmin) / (WXleft - WXright) + DXmin + 0.5);
    ptemp.y := round((WYtop -  p.y) * (DYmax - DYmin) / (WYtop - WYbottom) + DYmin + 0.5);
    Result := ptemp;
end;
//---------------------------------------------------------------------------

procedure TRot3DFrm.DrawPoint( p1 : POINT3D; Sender: TObject);
var
   p2 : POINTint;
begin
    // draws a 3d point
    p1.z := -p1.z;
    p2 := World2DToDevice(World3DToWorld2D(p1,self),self);
    Image1.Canvas.Rectangle(p2.x - 2,p2.y - 2,p2.x + 2, p2.y + 2);
end;
//---------------------------------------------------------------------------

procedure TRot3DFrm.DrawLine(p1, p2 : POINT3D; Sender: TObject);
var
   p11, p22 : POINTint;
begin
    //draws a 3d line
    p1.z := -p1.z;
    p2.z := -p2.z;
    p11 := World2DToDevice(World3DToWorld2D(p1,self),self);
    p22 := World2DToDevice(World3DToWorld2D(p2,self),self);
    Image1.Canvas.MoveTo(p11.x,p11.y);
    Image1.Canvas.LineTo(p22.x,p22.y);
end;
//---------------------------------------------------------------------------

procedure TRot3DFrm.DrawAxis(Sender: TObject);
var
   p1, p2 : POINT3D;
begin
    p1.x := -1;
    p1.y := 0;
    p1.z := 0;
    p2.x := 1;
    p2.y := 0;
    p2.z := 0;
    Image1.Canvas.Pen.Color := clRed;
    drawline(p1,p2,self);
    p1.x := 0;
    p1.y := -1;
    p2.x := 0;
    p2.y := 1;
    p2.z := 0;
    Image1.Canvas.Pen.Color := clBlue;
    drawline(p1,p2,self);
    p1.y := 0;
    p1.z := -1;
    p2.x := 0;
    p2.y := 0;
    p2.z := 1;
    Image1.Canvas.Pen.Color := clGreen;
    drawline(p1,p2,self);
    Image1.Canvas.Pen.Color := clWhite;
end;
//---------------------------------------------------------------------------

procedure TRot3DFrm.SetAxesAngles(rx1, ry1, rz1 : double; Sender: TObject);
begin
    RX := DegToRad(rx1,self);
    RY := DegToRad(ry1,self);
    RZ := DegToRad(rz1,self);
    COSRX := cos(RX);
    SINRX := sin(RX);
    COSRY := cos(RY);
    SINRY := sin(RY);
    COSRZ := cos(RZ);
    SINRZ := sin(RZ);
end;
//---------------------------------------------------------------------------

procedure TRot3DFrm.ScaleValues(Sender: TObject);
var
    Xmax, Ymax, Zmax, Xmin, Ymin, Zmin, value, prop : double;
    i, NoSelected : integer;
    ColNoSelected : IntDyneVec;

begin
    // This routine scales the X, Y and Z values in the grid to new
    // values ranging from -1 to 1 for each.  The arrays of scaled
    // values are pointed to by the private float pointers XScaled,
    // YScaled and ZScaled;

    SetLength(ColNoSelected,NoVariables);
    SetLength(XScaled,NoCases+1);
    SetLength(YScaled,NoCases+1);
    SetLength(ZScaled,NoCases+1);

    ColNoSelected[0] := GridColX;
    ColNoSelected[1] := GridColY;
    ColNoSelected[2] := GridColZ;
    NoSelected := 3;
    Xmax := StrToFloat(OS3MainFrm.DataGrid.Cells[GridColX,1]);
    Xmin := Xmax;
    Ymin := StrToFloat(OS3MainFrm.DataGrid.Cells[GridColY,1]);
    Ymax := Ymin;
    Zmax := StrToFloat(OS3MainFrm.DataGrid.Cells[GridColZ,1]);
    Zmin := Zmax;
    for i := 1 to NoCases do
    begin
        if Not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        value := StrToFloat(OS3MainFrm.DataGrid.Cells[GridColX,i]);
        if (value > Xmax) then Xmax := value;
        if (value < Xmin) then Xmin := value;
        value := StrToFloat(OS3MainFrm.DataGrid.Cells[GridColY,i]);
        if (value > Ymax) then Ymax := value;
        if (value < Ymin) then Ymin := value;
        value := StrToFloat(OS3MainFrm.DataGrid.Cells[GridColZ,i]);
        if (value > Zmax) then Zmax := value;
        if (value < Zmin) then Zmin := value;
    end;
    // now scale values
    for i := 1 to NoCases do
    begin
        if Not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        value := StrTofloat(OS3MainFrm.DataGrid.Cells[GridColX,i]);
        prop := (Xmax - value) / (Xmax - Xmin);
        XScaled[i] := prop - 0.5;  //scale between -1 and +1
        value := StrToFloat(OS3MainFrm.DataGrid.Cells[GridColY,i]);
        prop := (Ymax - value) / (Ymax - Ymin);
        YScaled[i] := prop - 0.5;
        value := StrToFloat(OS3MainFrm.DataGrid.Cells[GridColZ,i]);
        prop := (Zmax - value) / (Zmax - Zmin);
        ZScaled[i] := prop - 0.5;
    end;
    ColNoSelected := nil;
end;
//-------------------------------------------------------------------

procedure TRot3DFrm.EraseAxis(Sender: TObject);
var
   p1, p2 : POINT3D;
begin
    p1.x := -1;
    p1.y := 0;
    p1.z := 0;
    p2.x := 1;
    p2.y := 0;
    p2.z := 0;
    Image1.Canvas.Pen.Color := clWhite;
    drawline(p1,p2,self);
    p1.x := 0;
    p1.y := -1;
    p2.x := 0;
    p2.y := 1;
    p2.z := 0;
    drawline(p1,p2,self);
    p1.y := 0;
    p1.z := -1;
    p2.x := 0;
    p2.y := 0;
    p2.z := 1;
    drawline(p1,p2,self);
end;

procedure TRot3DFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, PrintBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  PrintBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TRot3DFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TRot3DFrm.FormDestroy(Sender: TObject);
begin
  ZScaled := nil;
  YScaled := nil;
  XScaled := nil;
end;


initialization
  {$I rot3dunit.lrs}

end.

