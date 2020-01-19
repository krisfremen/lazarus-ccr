unit MKnob;

{ TmKnob : Marco Caselli's Knob Control rel. 1.0
 This component emulate the volume knob you could find on some HiFi devices;
**********************************************************************
* Feel free to use or give away this software as you see fit.        *
* Please leave the credits in place if you alter the source.         *
*                                                                    *
* This software is delivered to you "as is",                         *
* no guarantees of any kind.                                         *
*                                                                    *
* If you find any bugs, please let me know, I will try to fix them.  *
* If you modify the source code, please send me a copy               *
*                                                                    *
* If you like this component,  and also if you dislike it ;), please *
* send me an E-mail with your comment                                *
* Marco Caselli                                                      *
* Web site : http://members.tripod.com/dartclub                      *
* E-mail   : mcaselli@iname.com                                      *
*                                                                    *
* Thank to guy at news://marcocantu.public.italian.delphi            *
* for some math code. Check the site http://www.marcocantu.com       *
**********************************************************************
*** Sorry for my bad english ...............
 Properties :
      AllowUserDrag : Boolean; Specify if user can or not drag the control
                               to a new value using mouse;
      FaceColor : TColor;      Color of knob face;
      TickColor : TColor;      Color of tick mark;
      Position : Longint;      Current position of the knob;
      MarkStyle: TMarkStyle;   Specify style of the tick mark ( actually only
                               line or filled circle;
      RotationEffect:Boolean;    If True, the knob will shake emulating a rotation
                                  visual effect.
      Position:Longint;        Current value of knob;
      Max : Longint;           Upper limit value for Position;
      Min : Longint;           Lower limit value for Position;

 Events:
    property OnChange :        This event is triggered every time you change the
                               knob value;

 Lazarus port by W.Pamler
*******************************************************************************}

{$mode objfpc}{$H+}

interface

uses
  LclIntf, Types, SysUtils, Classes, Graphics, Math,
  Controls, Forms, Dialogs, ComCtrls;

type
  TKnobAngleRange = (
    arTop270, arTop180, arTop120, arTop90,
    arBottom270, arBottom180, arBottom120, arBottom90,
    arLeft270, arLeft180, arLeft120, arLeft90,
    arRight270, arRight180, arRight120, arRight90
  );
  TKnobChangeEvent = procedure(Sender: TObject; AValue: Longint) of object;
  TKnobMarkStyle = (msLine, msCircle, msTriangle);
  TKnobMarkSizeKind = (mskPercentage, mskPixels);

  TmKnob = class(TCustomControl)
  private
    const
      DEFAULT_KNOB_MARK_SIZE = 20;
  private
    FMaxValue: Integer;
    FMinValue: Integer;
    FCurValue: Integer;
    FFaceColor: TColor;
    FTickColor: TColor;
    FBorderColor: TColor;
    FAllowDrag: Boolean;
    FOnChange: TKnobChangeEvent;
    FFollowMouse: Boolean;
    FMarkSize: Integer;
    FMarkSizeKind: TKnobMarkSizeKind;
    FMarkStyle: TKnobMarkStyle;
    FAngleRange: TKnobAngleRange;
    FRotationEffect: Boolean;
    FShadow: Boolean;
    FShadowColor: TColor;
    FTransparent: Boolean;
    function GetAngleOrigin: Double;
    function GetAngleRange: Double;
    procedure SetAllowDrag(AValue: Boolean);
    procedure SetAngleRange(AValue: TKnobAngleRange);
    procedure SetBorderColor(AValue: TColor);
    procedure SetCurValue(AValue: Integer);
    procedure SetFaceColor(AColor: TColor);
    procedure SetMarkSize(AValue: Integer);
    procedure SetMarkSizeKind(AValue: TKnobMarkSizeKind);
    procedure SetMarkStyle(AValue: TKnobMarkStyle);
    procedure SetMaxValue(AValue: Integer);
    procedure SetMinValue(AValue: Integer);
    procedure SetShadow(AValue: Boolean);
    procedure SetShadowColor(AValue: TColor);
    procedure SetTickColor(AValue: TColor);
    procedure SetTransparent(AValue: Boolean);
    procedure UpdatePosition(X, Y: Integer);

  protected
    procedure DoAutoAdjustLayout(const AMode: TLayoutAdjustmentPolicy;
      const AXProportion, AYProportion: Double); override;
    class function GetControlClassDefaultSize: TSize; override;
    procedure KnobChange;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;

  published
    property Align;
    property AllowUserDrag: Boolean read FAllowDrag write SetAllowDrag default True;
    property AngleRange: TKnobAngleRange read FAngleRange write SetAngleRange default arTop270;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clBtnHighlight;
    property BorderSpacing;
    property Color;
    property FaceColor: TColor read FFaceColor write SetFaceColor default clSilver;
    property TickColor: TColor read FTickColor write SetTickColor default clBlack;
    property Position: Integer read FCurValue write SetCurValue;
    property RotationEffect: Boolean read FRotationEffect write FRotationEffect default false;
    property Enabled;
    property MarkSize: Integer read FMarkSize write SetMarkSize default DEFAULT_KNOB_MARK_SIZE;
    property MarkSizeKind: TKnobMarkSizeKind read FMarkSizeKind write SetMarkSizeKind default mskPercentage;
    property MarkStyle: TKnobMarkStyle read FMarkStyle write SetMarkStyle default msLine;
    property Max: Integer read FMaxValue write SetMaxValue default 100;
    property Min: Integer read FMinValue write SetMinvalue default 0;
    property OnChange: TKnobChangeEvent read FOnChange write FOnChange;
    property ParentColor;
    property ParentShowHint;
    property Shadow: Boolean read FShadow write SetShadow default true;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clBtnShadow;
    property ShowHint;
    property Transparent: Boolean read FTransparent write SetTransparent default true;
    property Visible;
  end;


implementation

{ Rotates point P around the Center by the angle given by its sin and cos.
  The angle is relative to the upward y axis in clockwise direction. }
function Rotate(P, Center: TPoint; SinAngle, CosAngle: Double): TPoint;
begin
  P.X := P.X - Center.X;
  P.Y := P.Y - Center.Y;
  Result.X := round(cosAngle * P.X - sinAngle * P.Y) + Center.X;
  Result.Y := round(sinAngle * P.X + cosAngle * P.Y) + Center.Y;
end;


{ TmKnob }

constructor TmKnob.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, CX, CY);
  ControlStyle := ControlStyle + [csOpaque];
  FMaxValue := 100;
  FMinValue := 0;
  FCurValue := 0;
  FRotationEffect := false;
  FMarkStyle := msLine;
  FMarkSize := DEFAULT_KNOB_MARK_SIZE;
  FTickColor := clBlack;
  FFaceColor := clSilver;
  FBorderColor := clBtnHighlight;
  FFollowMouse := false;
  FAllowDrag := true;
  FAngleRange := arTop270;
  FTransparent := true;
  FShadow := true;
  FShadowColor := clBtnShadow;
end;

procedure TmKnob.DoAutoAdjustLayout(
  const AMode: TLayoutAdjustmentPolicy;
  const AXProportion, AYProportion: Double);
begin
  inherited DoAutoAdjustLayout(AMode, AXProportion, AYProportion);
  if AMode in [lapAutoAdjustWithoutHorizontalScrolling, lapAutoAdjustForDPI] then
  begin
    if FMarkSizeKind = mskPixels then
      FMarkSize := Round(FMarkSize * AXProportion);
  end;
end;

function TmKnob.GetAngleOrigin: Double;
const
  ORIGIN: array[TKnobAngleRange] of Double = (
      0,   0,   0,   0,
    180, 180, 180, 180,
     90,  90,  90,  90,
    270, 270, 270, 270
  );
begin
  Result := DegToRad(ORIGIN[FAngleRange]);
end;

function TmKnob.GetAngleRange: Double;
const
  ANGLE: array[TKnobAngleRange] of Double = (
    270, 180, 120, 90,
    270, 180, 120, 90,
    270, 180, 120, 90,
    270, 180, 120, 90
    );
begin
  Result := DegToRad(ANGLE[FAngleRange]);
end;

class function TmKnob.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 60;
  Result.CY := 60;
end;

procedure TmKnob.KnobChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self, FCurValue);
end;

procedure TmKnob.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if FAllowDrag then
  begin
    FFollowMouse := True;
    UpdatePosition(X,Y);
    Refresh;
  end;
end;

procedure TmKnob.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FFollowMouse := False;
end;

procedure TmKnob.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if FFollowMouse then
    UpdatePosition(X,Y)
end;

procedure TmKnob.Paint;
var
  R: TRect;
  bmp: TBitmap;
  Angle, sinAngle, cosAngle: Double;
  W, H: Integer;
  i: Integer;
  P: array[0..3] of TPoint;
  margin: Integer;
  markerSize: Integer;
  radius: Integer;
  ctr: TPoint;
  penwidth: Integer;
begin
  margin := 4;
  penwidth := 1;

  { Initialize offscreen BitMap }
  bmp := TBitmap.Create;
  try
    bmp.Width := Width;
    bmp.Height := Height;
    if FTransparent then
    begin
      bmp.Transparent := true;
      bmp.TransparentColor := clForm;
      bmp.Canvas.Brush.Color := bmp.TransparentColor;
    end else
    begin
      bmp.Transparent := false;
      if Color = clDefault then
        bmp.Canvas.Brush.Color := clForm
      else
        bmp.Canvas.Brush.Color := Color;
    end;
    ctr := Point(Width div 2, Height div 2);
    R := Rect(0, 0, Width, Height);
    W := R.Right - R.Left - margin;
    H := R.Bottom - R.Top - margin;
    if H < W then
      radius := H div 2
    else
      radius := W div 2;

    { This weird thing make knob "shake", emulating a rotation effect.
      Not so pretty, but I like it..............}
    if FRotationEffect and (Position mod 2 <> 0) then
      inc(H);

    with bmp.Canvas do
    begin
      FillRect(R);

      Brush.Color := FaceColor;
      Pen.Color := cl3dLight;
      Pen.Width := penwidth * 2;
      Pen.Style := psSolid;
      R := Rect(ctr.X, ctr.Y, ctr.X, ctr.Y);
      InflateRect(R, radius - penwidth, radius - penwidth);
      if FShadow then
        OffsetRect(R, -penwidth, -penwidth);
      Ellipse(R);

      if FShadow then
      begin
        Pen.Color := FShadowColor;
        OffsetRect(R, 3*penwidth, 3*penwidth);
        Ellipse(R);
      end;

      Pen.Color := FBorderColor;
      Pen.Width := 1;
      if FShadow then
        OffsetRect(R, -2*penwidth, -2*penwidth);
      Ellipse(R);

      if Position >= 0 then
      begin
        case FMarkSizeKind of
          mskPercentage:
            markersize := radius * FMarkSize div 100;
          mskPixels:
            markerSize := FMarkSize;
        end;
        if markersize < 2 then markersize := 2;

        Angle := (Position - (Min + Max)/2 ) / (Max - Min) * GetAngleRange + GetAngleOrigin;
        SinCos(Angle, sinAngle, cosAngle);

        case MarkStyle of
          msLine:
            begin
              Pen.Width := 3;
              Pen.Color := TickColor;
              P[0] := Point(ctr.X, ctr.Y - radius + penwidth);
              P[1] := Point(ctr.X, ctr.Y - radius + penwidth + markersize);
              for i:=0 to 1 do
                P[i] := Rotate(P[i], ctr, sinAngle, cosAngle);
              MoveTo(P[0].X, P[0].Y);
              LineTo(P[1].X, P[1].Y);
            end;
          msCircle:
            begin
              Brush.Color := TickColor;
              Pen.Style := psClear;
              P[0] := Point(ctr.X, ctr.Y - radius + markersize + 2*penwidth);
              P[0] := Rotate(P[0], ctr, sinAngle, cosAngle);
              R := Rect(P[0].X, P[0].Y, P[0].X, P[0].Y);
              InflateRect(R, markersize, markersize);
              Ellipse(R);
            end;
          msTriangle:
            begin
              Brush.Color := TickColor;
              Pen.Style := psClear;
//              P[0] := Point(ctr.X, H div 32);
              P[0] := Point(ctr.X, ctr.Y - radius + 2*penwidth);
              P[1] := Point(P[0].X - markersize, P[0].Y + markersize*2);
              P[2] := Point(P[0].X + markersize, P[0].Y + markersize*2);
              P[3] := P[0];
              for i:=0 to High(P) do
                P[i] := Rotate(P[i], ctr, sinAngle, cosAngle);
              Polygon(P);
            end;
        end;
      end;
    end;

    Canvas.CopyMode := cmSrcCopy;
    Canvas.Draw(0, 0, bmp);
  finally
    bmp.Free;
  end;
end;

procedure TmKnob.SetAllowDrag(AValue: Boolean);
begin
  if AValue <> FAllowDrag then
  begin
    FAllowDrag := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetAngleRange(AValue: TKnobAngleRange);
begin
  if AValue <> FAngleRange then
  begin
    FAngleRange := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetBorderColor(AValue: TColor);
begin
  if AValue <> FBorderColor then
  begin
    FBorderColor := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetCurValue(AValue: Integer);
var
  tmp: Integer;
begin
  if AValue <> FCurValue then
  begin
    if FMinValue > FMaxValue then begin
      tmp := FMinValue;
      FMinValue := FMaxValue;
      FMaxValue := tmp;
    end;
    FCurValue := EnsureRange(AValue, FMinValue, FMaxValue);
    Invalidate;
    KnobChange;
  end;
end;

procedure TmKnob.SetFaceColor(AColor: TColor);
begin
  if FFaceColor <> AColor then begin
    FFaceColor := AColor;
    Invalidate;
  end;
end;

procedure TmKnob.SetMarkSize(AValue: Integer);
begin
  if AValue <> FMarkSize then
  begin
    FMarkSize := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetMarkSizeKind(AValue: TKnobMarkSizeKind);
begin
  if AValue <> FMarkSizeKind then
  begin
    FMarkSizeKind := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetMarkStyle(AValue: TKnobMarkStyle);
begin
  if AValue <> FMarkStyle then
  begin
    FMarkStyle := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetMaxValue(AValue: Integer);
begin
  if AValue <> FMaxValue then
  begin
    FMaxValue := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetMinValue(AValue: Integer);
begin
  if AValue <> FMinValue then
  begin
    FMinValue := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetShadow(AValue: Boolean);
begin
  if AValue <> FShadow then
  begin
    FShadow := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetShadowColor(AValue: TColor);
begin
  if AValue <> FShadowColor then
  begin
    FShadowColor := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetTickColor(AValue: TColor);
begin
  if AValue <> FTickColor then
  begin
    FTickColor := AValue;
    Invalidate;
  end;
end;

procedure TmKnob.SetTransparent(AValue: Boolean);
begin
  if FTransparent = AValue then exit;
  FTransparent := AValue;
  Invalidate;
end;


procedure TmKnob.UpdatePosition(X, Y: Integer);
var
  CX, CY: integer;
  Angle: double;
begin
  CX := Width div 2;
  CY := Height div 2;
  Angle := -ArcTan2(CX-X, CY-Y);
  Position := Round((Angle - GetAngleOrigin) * (Max - Min) / GetAngleRange + (Min + Max) / 2);
  Refresh;
end;


end.
