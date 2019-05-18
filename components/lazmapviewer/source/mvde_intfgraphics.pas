unit mvDE_IntfGraphics;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Types, LazVersion,
  FPImage, FPCanvas, IntfGraphics,
  mvDrawingEngine;

type
  TIntfGraphicsDrawingEngine = class(TMvCustomDrawingEngine)
  private
    FBuffer: TLazIntfImage;
    FCanvas: TFPCustomCanvas;
    FFontName: String;
    FFontColor: TColor;
    FFontSize: Integer;
    FFontStyle: TFontStyles;
    procedure CreateLazIntfImageAndCanvas(out ABuffer: TLazIntfImage;
      out ACanvas: TFPCustomCanvas; AWidth, AHeight: Integer);
  protected
    function GetBrushColor: TColor; override;
    function GetBrushStyle: TBrushStyle; override;
    function GetFontColor: TColor; override;
    function GetFontName: String; override;
    function GetFontSize: Integer; override;
    function GetFontStyle: TFontStyles; override;
    function GetPenColor: TColor; override;
    function GetPenWidth: Integer; override;
    procedure SetBrushColor(AValue: TColor); override;
    procedure SetBrushStyle(AValue: TBrushStyle); override;
    procedure SetFontColor(AValue: TColor); override;
    procedure SetFontName(AValue: String); override;
    procedure SetFontSize(AValue: Integer); override;
    procedure SetFontStyle(AValue: TFontStyles); override;
    procedure SetPenColor(AValue: TColor); override;
    procedure SetPenWidth(AValue: Integer); override;
  public
    destructor Destroy; override;
    procedure CreateBuffer(AWidth, AHeight: Integer); override;
    procedure DrawLazIntfImage(X, Y: Integer; AImg: TLazIntfImage); override;
    procedure Ellipse(X1, Y1, X2, Y2: Integer); override;
    procedure FillRect(X1, Y1, X2, Y2: Integer); override;
    procedure Line(X1, Y1, X2, Y2: Integer); override;
    procedure PaintToCanvas(ACanvas: TCanvas); override;
    procedure Rectangle(X1, Y1, X2, Y2: Integer); override;
    function SaveToImage(AClass: TRasterImageClass): TRasterImage; override;
    function TextExtent(const AText: String): TSize; override;
    procedure TextOut(X, Y: Integer; const AText: String); override;
  end;


implementation

uses
  FPImgCanv, GraphType;

{$IF Laz_FullVersion < 1090000}
// Workaround for http://mantis.freepascal.org/view.php?id=27144
procedure CopyPixels(ASource, ADest: TLazIntfImage;
  XDst: Integer = 0; YDst: Integer = 0;
  AlphaMask: Boolean = False; AlphaTreshold: Word = 0);
var
  SrcHasMask, DstHasMask: Boolean;
  x, y, xStart, yStart, xStop, yStop: Integer;
  c: TFPColor;
  SrcRawImage, DestRawImage: TRawImage;
begin
  ASource.GetRawImage(SrcRawImage);
  ADest.GetRawImage(DestRawImage);

  if DestRawImage.Description.IsEqual(SrcRawImage.Description) and (XDst =  0) and (YDst = 0) then
  begin
    // same description -> copy
    if DestRawImage.Data <> nil then
      System.Move(SrcRawImage.Data^, DestRawImage.Data^, DestRawImage.DataSize);
    if DestRawImage.Mask <> nil then
      System.Move(SrcRawImage.Mask^, DestRawImage.Mask^, DestRawImage.MaskSize);
    Exit;
  end;

  // copy pixels
  XStart := IfThen(XDst < 0, -XDst, 0);
  YStart := IfThen(YDst < 0, -YDst, 0);
  XStop := IfThen(ADest.Width - XDst < ASource.Width, ADest.Width - XDst, ASource.Width) - 1;
  YStop := IfTHen(ADest.Height - YDst < ASource.Height, ADest.Height - YDst, ASource.Height) - 1;

  SrcHasMask := SrcRawImage.Description.MaskBitsPerPixel > 0;
  DstHasMask := DestRawImage.Description.MaskBitsPerPixel > 0;

  if DstHasMask then begin
    for y:= yStart to yStop do
      for x:=xStart to xStop do
        ADest.Masked[x+XDst,y+YDst] := SrcHasMask and ASource.Masked[x,y];
  end;

  for y:=yStart to yStop do
    for x:=xStart to xStop do
    begin
      c := ASource.Colors[x,y];
      if not DstHasMask and SrcHasMask and (c.alpha = $FFFF) then // copy mask to alpha channel
        if ASource.Masked[x,y] then
          c.alpha := 0;

      ADest.Colors[x+XDst,y+YDst] := c;
      if AlphaMask and (c.alpha < AlphaTreshold) then
        ADest.Masked[x+XDst,y+YDst] := True;
    end;
end;
{$IFEND}


destructor TIntfGraphicsDrawingEngine.Destroy;
begin
  FCanvas.Free;
  FBuffer.Free;
  inherited;
end;

procedure TIntfGraphicsDrawingEngine.CreateBuffer(AWidth, AHeight: Integer);
begin
  FCanvas.Free;
  FBuffer.Free;
  CreateLazIntfImageAndCanvas(FBuffer, FCanvas, AWidth, AHeight);
end;

procedure TIntfGraphicsDrawingEngine.CreateLazIntfImageAndCanvas(
  out ABuffer: TLazIntfImage;
  out ACanvas: TFPCustomCanvas; AWidth, AHeight: Integer);
var
  rawImg: TRawImage;
begin
  rawImg.Init;
  {$IFDEF DARWIN}
  rawImg.Description.Init_BPP32_A8R8G8B8_BIO_TTB(AWidth, AHeight);
  {$ELSE}
  rawImg.Description.Init_BPP32_B8G8R8_BIO_TTB(AWidth, AHeight);
  {$ENDIF}
  rawImg.CreateData(True);
  ABuffer := TLazIntfImage.Create(rawImg, true);
  ACanvas := TFPImageCanvas.Create(ABuffer);
  ACanvas.Brush.FPColor := colWhite;
  ACanvas.FillRect(0, 0, AWidth, AHeight);
end;

procedure TIntfGraphicsDrawingEngine.DrawLazIntfImage(X, Y: Integer;
  AImg: TLazIntfImage);
begin
  {$IF Laz_FullVersion < 1090000}
  { Workaround for //http://mantis.freepascal.org/view.php?id=27144 }
  CopyPixels(AImg, Buffer, X, Y);
  {$ELSE}
  FBuffer.CopyPixels(AImg, X, Y);
  {$IFEND}
end;

procedure TIntfGraphicsDrawingEngine.Ellipse(X1, Y1, X2, Y2: Integer);
begin
  if FCanvas <> nil then
    FCanvas.Ellipse(X1,Y1, X2, Y2);
end;

procedure TIntfGraphicsDrawingEngine.FillRect(X1, Y1, X2, Y2: Integer);
begin
  if FCanvas <> nil then
    FCanvas.FillRect(X1,Y1, X2, Y2);
end;

function TIntfGraphicsDrawingEngine.GetBrushColor: TColor;
begin
  if FCanvas <> nil then
    Result := FPColorToTColor(FCanvas.Brush.FPColor)
  else
    Result := 0;
end;

function TIntfGraphicsDrawingEngine.GetBrushStyle: TBrushStyle;
begin
  if FCanvas <> nil then
    Result := FCanvas.Brush.Style
  else
    Result := bsSolid;
end;

function TIntfGraphicsDrawingEngine.GetFontColor: TColor;
begin
  Result := FFontColor
end;

function TIntfGraphicsDrawingEngine.GetFontName: String;
begin
  Result := FFontName;
end;

function TIntfGraphicsDrawingEngine.GetFontSize: Integer;
begin
  Result := FFontSize;
end;

function TIntfGraphicsDrawingEngine.GetFontStyle: TFontStyles;
begin
  Result := FFontStyle;
end;

function TIntfGraphicsDrawingEngine.GetPenColor: TColor;
begin
  if FCanvas <> nil then
    Result := FPColorToTColor(FCanvas.Pen.FPColor)
  else
    Result := 0;
end;

function TIntfGraphicsDrawingEngine.GetPenWidth: Integer;
begin
  if FCanvas <> nil then
    Result := FCanvas.Pen.Width
  else
    Result := 0;
end;

procedure TIntfGraphicsDrawingEngine.Line(X1, Y1, X2, Y2: Integer);
begin
  if FCanvas <> nil then
    FCanvas.Line(X1, Y1, X2, Y2);
end;

procedure TIntfGraphicsDrawingEngine.PaintToCanvas(ACanvas: TCanvas);
var
  bmp: TBitmap;
begin
  if FCanvas <> nil then begin
    bmp := TBitmap.Create;
    try
      bmp.PixelFormat := pf32Bit;
      bmp.SetSize(FBuffer.Width, FBuffer.Height);
      bmp.LoadFromIntfImage(FBuffer);
      ACanvas.Draw(0, 0, bmp);
    finally
      bmp.Free;
    end;
  end;
end;

procedure TIntfGraphicsDrawingEngine.Rectangle(X1, Y1, X2, Y2: Integer);
begin
  if FCanvas <> nil then
    FCanvas.Rectangle(X1,Y1, X2, Y2);
end;

function TIntfGraphicsDrawingEngine.SaveToImage(AClass: TRasterImageClass): TRasterImage;
begin
  Result := AClass.Create;
  Result.Width := FBuffer.Width;
  Result.Height := FBuffer.Height;
  Result.Canvas.FillRect(0, 0, Result.Width, Result.Height);
  Result.LoadFromIntfImage(FBuffer);
end;

procedure TIntfGraphicsDrawingEngine.SetBrushColor(AValue: TColor);
begin
  if FCanvas <> nil then
    FCanvas.Brush.FPColor := TColorToFPColor(AValue);
end;

procedure TIntfGraphicsDrawingEngine.SetBrushStyle(AValue: TBrushStyle);
begin
  if FCanvas <> nil then
    FCanvas.Brush.Style := AValue;
end;

procedure TIntfGraphicsDrawingEngine.SetFontColor(AValue: TColor);
begin
  FFontColor := AValue;
end;

procedure TIntfGraphicsDrawingEngine.SetFontName(AValue: String);
begin
  FFontName := AValue;
end;

procedure TIntfGraphicsDrawingEngine.SetFontSize(AValue: Integer);
begin
  FFontSize := AValue;
end;

procedure TIntfGraphicsDrawingEngine.SetFontStyle(AValue: TFontStyles);
begin
  FFontStyle := AValue;
end;

procedure TIntfGraphicsDrawingEngine.SetPenColor(AValue: TColor);
begin
  if FCanvas <> nil then
    FCanvas.Pen.FPColor := TColorToFPColor(AValue);
end;

procedure TIntfGraphicsDrawingEngine.SetPenWidth(AValue: Integer);
begin
  if FCanvas <> nil then
    FCanvas.Pen.Width := AValue;
end;

function TIntfGraphicsDrawingEngine.TextExtent(const AText: String): TSize;
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.SetSize(1, 1);
    bmp.Canvas.Font.Name := FFontName;
    bmp.Canvas.Font.Size := FFontSize;
    bmp.Canvas.Font.Style := FFontStyle;
    Result := bmp.Canvas.TextExtent(AText);
  finally
    bmp.Free;
  end;
end;

procedure TIntfGraphicsDrawingEngine.TextOut(X, Y: Integer; const AText: String);
var
  bmp: TBitmap;
  ex: TSize;
  img: TLazIntfImage;
  brClr: TFPColor;
  imgClr: TFPColor;
  i, j: Integer;
begin
  if (FCanvas = nil) or (AText = '') then
    exit;

  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf32Bit;
    bmp.SetSize(1, 1);
    bmp.Canvas.Font.Name := FFontName;
    bmp.Canvas.Font.Size := FFontSize;
    bmp.Canvas.Font.Style := FFontStyle;
    bmp.Canvas.Font.Color := FFontColor;
    ex := bmp.Canvas.TextExtent(AText);
    bmp.SetSize(ex.CX, ex.CY);
    bmp.Canvas.Brush.Color := GetBrushColor;
    if GetBrushStyle = bsClear then
      bmp.Canvas.Brush.Style := bsSolid
    else
      bmp.Canvas.Brush.Style := GetBrushStyle;
    bmp.Canvas.FillRect(0, 0, bmp.Width, bmp.Height);
    bmp.Canvas.TextOut(0, 0, AText);
    img := bmp.CreateIntfImage;
    try
      if GetBrushStyle = bsClear then begin
        brClr := TColorToFPColor(GetBrushColor);
        for j := 0 to img.Height - 1 do
          for i := 0 to img.Width - 1 do begin
            imgClr := img.Colors[i, j];
            if (imgClr.Red = brClr.Red) and (imgClr.Green = brClr.Green) and (imgClr.Blue = brClr.Blue) then
              Continue;
            FCanvas.Colors[X + i, Y + j] := imgClr;
          end;
      end else
        FCanvas.Draw(X, Y, img);
    finally
      img.Free;
    end;
  finally
    bmp.Free;
  end;
end;

end.

