{
 /***************************************************************************
                                indSliders
                                ----------
                      sliders for the Industrial package

  The initial version of this unit was published in the Lazarus forum
  by user bylaardt
  (https://forum.lazarus.freepascal.org/index.php/topic,45063.msg318180.html#msg318180)
  and extended by wp.

  License: modified LGPL like Lazarus LCL
 *****************************************************************************
}

unit indSliders;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, Types;

const
  DEFAULT_SIZE = 28;
  DEFAULT_TRACK_THICKNESS = 7;
  DEFAULT_MULTISLIDER_WIDTH = 250;
  DEFAULT_MULTISLIDER_HEIGHT = DEFAULT_SIZE * 5 div 4;

Type

  { TMultiSlider }

  TSliderMode = (smSingle, smMinMax, smMinValueMax);

  TThumbKind = (tkMin, tkMax, tkValue);

  TThumbstyle = (tsGrip, tsCircle, tsRect, tsRoundedRect,
    tsTriangle, tsTriangleOtherSide);

  TSliderPositionEvent = procedure (
    Sender: TObject; AKind: TThumbKind; AValue: Integer) of object;

  TMultiSlider = class(TCustomControl)
  private
    FAutoRotate: Boolean;
    FTrackSize: TPoint;
    FBtnSize: TPoint;
    FCapture: ShortInt;
    FCaptureOffset, FTrackStart: Integer;
    FColorAbove: TColor;
    FColorBelow: TColor;
    FColorBetween: TColor;
    FColorThumb: TColor;
    FFlat: Boolean;
    FVertical: boolean;
    FMaxPosition, FMinPosition, FPosition: Integer;
    FDefaultSize: Integer;
    FSliderMode: TSliderMode;
    FThumbStyle: TThumbstyle;
    FTrackThickness: Integer;
    FOnPositionChange: TSliderPositionEvent;
    FRangeMax, FRangeMin: Integer;
    function IsDefaultSizeStored: Boolean;
    function IsTrackThicknessStored: Boolean;
    procedure SetColorAbove(AValue: TColor);
    procedure SetColorBelow(AValue: TColor);
    procedure SetColorBetween(AValue: TColor);
    procedure SetColorThumb(AValue: TColor);
    procedure SetDefaultSize(AValue: Integer);
    procedure SetFlat(AValue: Boolean);
    procedure SetMaxPosition(AValue: Integer);
    procedure SetMinPosition(AValue: Integer);
    procedure SetPosition(AValue: Integer);
    procedure SetRangeMax(AValue: Integer);
    procedure SetRangeMin(AValue: Integer);
    procedure SetSliderMode(AValue: TSliderMode);
    procedure SetThumbStyle(AValue: TThumbStyle);
    procedure SetTrackThickness(AValue: Integer);
    procedure SetVertical(AValue: Boolean);
  protected
    function BtnLength: Integer;
    procedure DoAutoAdjustLayout(const AMode: TLayoutAdjustmentPolicy;
      const AXProportion, AYProportion: Double); override;
    procedure DoPositionChange(AKind: TThumbKind; AValue: Integer);
    function ExtendedThumbs: Boolean;
    function GetRectFromPoint(APosition: Integer; Alignment: TAlignment): TRect;
    function GetThumbCenter(ARect: TRect): TPoint;
    function GetTrackLength: Integer;
    function IsInFirstHalf(APoint: TPoint; ARect: TRect): Boolean;
    procedure Loaded; override;
    function PointToPosition(P: TPoint): Integer;
    procedure UpdateBounds;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure MouseLeave; override;

  published
    property AutoRotate: Boolean
      read FAutoRotate write FAutoRotate default true;
    property ColorAbove: TColor
      read FColorAbove write SetColorAbove default clInactiveCaption;
    property ColorBelow: TColor
      read FColorBelow write SetColorBelow default clInactiveCaption;
    property ColorBetween: TColor
      read FColorBetween write SetColorBetween default clActiveCaption;
    property ColorThumb: TColor
      read FColorThumb write SetColorThumb default clBtnFace;
    property DefaultSize: Integer
      read FDefaultSize write SetDefaultSize stored IsDefaultSizeStored;
    property Flat: Boolean
      read FFlat write SetFlat default false;
    property MaxPosition: Integer
      read FMaxPosition write SetMaxPosition default 80;
    property MinPosition: Integer
      read FMinPosition write SetMinPosition default 20;
    property Position: Integer
      read FPosition write SetPosition default 50;
    property RangeMax: Integer
      read FRangeMax write SetRangeMax default 100;
    property RangeMin: Integer
      read FRangeMin write SetRangeMin default 0;
    property SliderMode: TSliderMode
      read FSliderMode write SetSliderMode default smMinMax;
    property ThumbStyle: TThumbStyle
      read FThumbStyle write SetThumbStyle default tsGrip;
    property TrackThickness: integer
      read FTrackThickness write SetTrackThickness stored IsTrackThicknessStored;
    property Vertical: boolean
      read FVertical write SetVertical default false;

    property Height default DEFAULT_SIZE;
    property Width default DEFAULT_MULTISLIDER_WIDTH;
    property OnPositionChange: TSliderPositionEvent
      read FOnPositionChange write FOnPositionChange;

    property Align;
    property BorderSpacing;
    property Constraints;
    property Enabled;
//    property Font;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Left;
//    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Tag;
    property Top;
    property Visible;

    property OnChangeBounds;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnMouseWheelHorz;
    property OnMouseWheelLeft;
    property OnMouseWheelRight;
    property OnResize;
end;

implementation

uses
  Math;

constructor TMultiSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FAutoRotate := true;
  FCapture := -1;
  FColorAbove := clInactiveCaption;
  FColorBelow := clInactiveCaption;
  FColorBetween := clActiveCaption;
  FColorThumb := clBtnFace;
  FDefaultSize := Scale96ToFont(DEFAULT_SIZE);
  FTrackThickness := Scale96ToFont(DEFAULT_TRACK_THICKNESS);
  FTrackStart := FDefaultSize*9 div 16 + 2;
  SetVertical(false);
  FRangeMin := 0;
  FRangeMax := 100;
  FMinPosition := 20;
  FMaxPosition := 80;
  FPosition := 50;
  FSliderMode := smMinMax;

  Width := DEFAULT_MULTISLIDER_WIDTH;
  Height := DEFAULT_MULTISLIDER_HEIGHT;
  Enabled := true;
end;

destructor TMultiSlider.Destroy;
begin
  inherited Destroy;
end;

function TMultiSlider.BtnLength: Integer;
begin
  Result := IfThen(FVertical, FBtnSize.Y, FBtnSize.X) div 2;
end;

procedure TMultiSlider.DoAutoAdjustLayout(
  const AMode: TLayoutAdjustmentPolicy;
  const AXProportion, AYProportion: Double);
begin
  inherited DoAutoAdjustLayout(AMode, AXProportion, AYProportion);
  if AMode in [lapAutoAdjustWithoutHorizontalScrolling, lapAutoAdjustForDPI] then
  begin
    DisableAutosizing;
    try
      if IsTrackThicknessStored then
        if FVertical then
          FTrackThickness := Round(FTrackThickness * AXProportion)
        else
          FTrackThickness := Round(FTrackThickness * AYProportion);
    finally
      EnableAutoSizing;
    end;
  end;
end;

procedure TMultiSlider.DoPositionChange(AKind: TThumbKind; AValue: Integer);
begin
  if Assigned(FOnPositionChange) then FOnPositionChange(self, AKind, AValue);
end;

function TMultiSlider.ExtendedThumbs: Boolean;
begin
  Result := not (FThumbStyle in [tsTriangle, tsTriangleOtherSide]);
end;

function TMultiSlider.GetRectFromPoint(APosition: Integer;
  Alignment: TAlignment): TRect;
var
  relPos: Double;
begin
  relPos := (APosition - FRangeMin) / (FRangeMax - FRangeMin);
  if FVertical then begin
    if ExtendedThumbs then
      case Alignment of
        taLeftJustify:
          Result.Top := FTrackStart + Round(FTrackSize.Y * relPos) - FBtnSize.Y;
        taCenter:
          if FSliderMode = smSingle then
           Result.Top := FTrackStart + Round((FTrackSize.Y + FBtnSize.Y) * relPos) - FBtnSize.Y
          else
            Result.Top := FTrackStart + Round((FTrackSize.Y - FBtnSize.Y) * relPos);
        taRightJustify:
          Result.Top := FTrackStart + Round(FTrackSize.Y * relPos);
      end
    else
      Result.Top := FTrackStart + Round(FTrackSize.Y * relPos) - FBtnSize.Y div 2;
    Result.Left := (Width - FBtnSize.X) div 2;
  end else begin
    if ExtendedThumbs then
      case Alignment of
        taLeftJustify:
          Result.Left := FTrackStart + Round(FTrackSize.X * relpos) - FBtnSize.X;
        taCenter:
          if FSliderMode = smSingle then
            Result.Left := FTrackStart + Round((FTrackSize.X + FBtnSize.X) * relPos) - FBtnSize.X
          else
            Result.Left := FTrackStart + Round((FTrackSize.X - FBtnSize.X) * relPos);
        taRightJustify:
          Result.Left := FTrackStart + Round(FTrackSize.X * relPos);
      end
    else
      Result.Left := FTrackStart + Round(FTrackSize.X * relPos) - FBtnSize.X div 2;
    Result.Top := (Height - FBtnSize.Y) div 2;
  end;
  Result.Right := Result.Left + FBtnSize.X;
  Result.Bottom := Result.Top + FBtnSize.Y;
end;

function TMultiSlider.GetThumbCenter(ARect: TRect): TPoint;
begin
  Result := Point((ARect.Left + ARect.Right) div 2, (ARect.Top + ARect.Bottom) div 2);
end;

function TMultiSlider.GetTrackLength: Integer;
begin
  if FVertical then
    Result := FTrackSize.Y
  else
    Result := FTrackSize.X;
end;

function TMultiSlider.IsDefaultSizeStored: Boolean;
begin
  Result := FDefaultSize <> Scale96ToFont(DEFAULT_SIZE);
end;

function TMultiSlider.IsInFirstHalf(APoint: TPoint; ARect: TRect): Boolean;
begin
  if FVertical then begin
    ARect.Right := GetThumbCenter(ARect).X;
    Result := PtInRect(ARect, APoint);
  end else begin
    ARect.Bottom := GetThumbCenter(ARect).Y;
    Result := PtInRect(ARect, APoint);
  end;
end;

function TMultiSlider.IsTrackThicknessStored: Boolean;
begin
  Result := FTrackThickness <> Scale96ToFont(DEFAULT_TRACK_THICKNESS);
end;

procedure TMultiSlider.Loaded;
begin
  inherited;
  exit;
  if FAutoRotate then begin
    if (FVertical and (Width > Height)) or ((not FVertical) and (Width < Height)) then
      SetBounds(Left, Top, Height, Width);
  end;
end;

procedure TMultiSlider.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X,Y: Integer);
var
  p: TPoint;
  btn1, btn2, btn3: TRect;
  inFirstHalf3: Boolean;
begin
  if Enabled then begin
    p := Point(x,y);
    btn1 := GetRectFromPoint(FMinPosition, taLeftJustify);
    btn2 := GetRectFromPoint(FMaxPosition, taRightJustify);
    btn3 := GetRectFromPoint(FPosition, taCenter);
    FCapture := -1;
    if (FSliderMode <> smSingle) and PtInRect(btn1, p) then begin
      FCapture := ord(tkMin);
      if ExtendedThumbs then
        FCaptureOffset := IfThen(FVertical, Y - btn1.Bottom, X - btn1.Right)
      else
        FCaptureOffset := IfThen(FVertical, Y - GetThumbCenter(btn1).Y, X - GetThumbCenter(btn1).X);
    end else
    if (FSliderMode <> smSingle) and PtInRect(btn2, p) then begin
      FCapture := ord(tkMax);
      if ExtendedThumbs then
        FCaptureOffset := IfThen(FVertical, Y - btn2.Top, X - btn2.Left)
      else
        FCaptureOffset := IfThen(FVertical, Y - GetThumbCenter(btn2).Y, X - GetThumbCenter(btn2).X)
    end else
    if (FSliderMode <> smMinMax) and PtInRect(btn3, p) then begin
      FCapture := ord(tkValue);
      if ExtendedThumbs then
        FCaptureOffset := IfThen(FVertical, Y - btn3.Top, X - btn3.Left)
      else
        FCaptureOffset := IfThen(FVertical, Y - GetThumbCenter(btn3).Y, X - GetThumbCenter(btn3).X);
    end;
    if (FCapture > -1) and (not ExtendedThumbs and PtInRect(btn3, p)) then begin
      inFirstHalf3 := IsInFirstHalf(p, btn3);
      if (TThumbKind(FCapture) in [tkMin, tkMax]) and (
           (inFirstHalf3 and (FThumbStyle = tsTriangleOtherSide)) or
           ((not inFirstHalf3) and (FThumbStyle = tsTriangle))
         ) then
      begin
        FCapture := ord(tkValue);
      end;
    end;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TMultiSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
  btn: TRect;
  pos: Integer;
begin
  if Enabled then begin
    p := Point(X, Y);
    case FCapture of
      -1: begin
            btn := GetRectFromPoint(FMinPosition, taLeftJustify);
            if PtInRect(btn, p) then begin
              Cursor := crHandPoint;
            end else begin
              btn := GetRectFromPoint(FMaxPosition, taRightJustify);
              if PtInRect(btn, p) then begin
                Cursor := crHandPoint;
              end else
                Cursor := crDefault;
            end;
          end;
      else
        pos := PointToPosition(p);
        case TThumbKind(FCapture) of
          tkMin: if FSliderMode <> smSingle then SetMinPosition(pos);
          tkMax: if FSliderMode <> smSingle then SetMaxPosition(pos);
          tkValue: if FSliderMode <> smMinMax then SetPosition(pos);
        end;
    end;
  end;
  inherited MouseMove(Shift,x,y);
end;

procedure TMultiSlider.MouseLeave;
begin
  inherited MouseLeave;
  FCapture := -1;
end;

procedure TMultiSlider.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FCapture := -1;
  inherited MouseUp(Button,Shift,x,y);
end;

procedure TMultiSlider.Paint;

  procedure DrawLine(ARect: TRect; AColor, AShadow, AHilight: TColor);
  var
    start, ending, distances, centerpoint, loop: Integer;
  begin
    distances := FDefaultSize div 8;
    start := ARect.Left + FBtnSize.x div 2 - distances*8 div 5;
    ending := start + distances*16 div 5;
    centerPoint := (ARect.Bottom - ARect.Top) div 2 + ARect.Top;
    for loop := -1 to 1 do begin
      Canvas.Pen.Color := AHilight;
      Canvas.MoveTo(start, centerPoint - 1 + loop * distances);
      Canvas.LineTo(ending, centerPoint - 1 + loop * distances);

      Canvas.Pen.Color := AColor;
      Canvas.MoveTo(start, centerPoint + loop * distances);
      Canvas.LineTo(ending, centerPoint + loop * distances);

      Canvas.Pen.Color := AShadow;
      Canvas.MoveTo(start, centerPoint + 1 + loop * distances);
      Canvas.LineTo(ending, centerPoint + 1 + loop * distances);
    end;
  end;

  procedure DrawRect(ARect: TRect; X1,Y1, X2,Y2, R: Integer; AColor: TColor);
  begin
    Canvas.Pen.Color := AColor;
    Canvas.Pen.Width := 1;
    Canvas.Brush.Color := Canvas.Pen.Color;
    Canvas.RoundRect(
      ARect.Left + X1,
      ARect.Top + Y1,
      ARect.Right + X2,
      ARect.Bottom + Y2,
      R, R);
  end;

  procedure DrawThumb(ARect, ATrackRect: TRect; InFirstHalf: Boolean);
  var
    radius: Integer;
    center: TPoint;
    P: array[0..2] of TPoint;
  begin
    case FThumbStyle of
      tsGrip, tsRoundedRect:
        begin
          radius := Min(FBtnSize.X, FBtnSize.Y) div 2;
          if FFlat then
            DrawRect(ARect, 0, 0, 0, 0, radius, FColorThumb)
          else begin
            DrawRect(ARect, 0, 0, -1, -1, radius, clBtnHighlight);
            DrawRect(ARect, 1, 1, 0, 0, radius, clBtnShadow);
            DrawRect(ARect, 1, 1, -1, -1, radius, FColorThumb);
          end;
          if FThumbStyle = tsGrip then
            DrawLine(ARect, FColorThumb, clBtnShadow, clBtnHighlight);
        end;
      tsCircle:
        begin
          center := Point((ARect.Left + ARect.Right) div 2, (ARect.Top + ARect.Bottom) div 2);
          radius := Min(ARect.Right - ARect.Left, ARect.Bottom - ARect.Top) div 2;
          if not FFlat then begin
            Canvas.Brush.Style := bsClear;
            Canvas.Pen.Color := clBtnHighlight;
            Canvas.Ellipse(center.X - radius - 1, center.Y - radius - 1, center.X + radius - 1, center.Y + radius - 1);
            Canvas.Pen.Color := clBtnShadow;
            Canvas.Ellipse(center.X - radius + 1, center.Y - radius + 1, center.X + radius + 1, center.Y + radius + 1);
          end;
          Canvas.Brush.Style := bsSolid;
          Canvas.Brush.Color := FColorThumb;
          Canvas.Pen.Color := FColorThumb;
          Canvas.Ellipse(center.X - radius, center.Y - radius, center.X + radius, center.Y + radius);
        end;
      tsRect:
        begin
          if not FFlat then begin
            Canvas.Brush.Style := bsClear;
            Canvas.Pen.Color := clBtnHighlight;
            Canvas.Rectangle(ARect.Left - 1, ARect.Top - 1, ARect.Right - 1, ARect.Bottom - 1);
            Canvas.Pen.Color := clBtnShadow;
            Canvas.Rectangle(ARect.Left + 1, ARect.Top + 1, ARect.Right + 1, ARect.Bottom + 1);
          end;
          Canvas.Brush.Style := bsSolid;
          Canvas.Brush.Color := FColorThumb;
          Canvas.Pen.Color := FColorThumb;
          Canvas.Rectangle(ARect);
        end;
      tsTriangle, tsTriangleOtherSide:
        begin
          if FVertical then begin
            if InFirstHalf then begin
              P[0] := Point(ARect.Left, ARect.Top);
              P[1] := Point(ARect.Left, ARect.Bottom);
              P[2] := Point(ATrackRect.Left, GetThumbCenter(ARect).Y);
            end else begin
              P[0] := Point(ARect.Right, ARect.Top);
              P[1] := Point(ARect.Right, ARect.Bottom);
              P[2] := Point(ATrackRect.Right, GetThumbCenter(ARect).Y);
            end;
          end else begin
            if InFirstHalf then begin
              P[0] := Point(ARect.Left, ARect.Bottom);
              P[1] := Point(ARect.Right, ARect.Bottom);
              P[2] := Point(GetThumbCenter(ARect).X, ATrackRect.Bottom);
            end else begin
              P[0] := Point(ARect.Left, ARect.Top);
              P[1] := Point(ARect.Right, ARect.Top);
              P[2] := Point(GetThumbCenter(ARect).X, ATrackRect.Top);
            end;
          end;
          if not FFlat then begin
            Canvas.Brush.Style := bsClear;
            Canvas.Pen.Color := clBtnHighlight;
            Canvas.Polygon([Point(P[0].X-1, P[0].Y-1), Point(P[1].X-1, P[1].Y-1), Point(P[2].X-1, P[2].Y-1)]);
            Canvas.Pen.Color := clBtnShadow;
            Canvas.Polygon([Point(P[0].X+1, P[0].Y+1), Point(P[1].X+1, P[1].Y+1), Point(P[2].X+1, P[2].Y+1)]);
          end;
          Canvas.Brush.Style := bsSolid;
          Canvas.Brush.Color := FColorThumb;
          Canvas.Pen.Color := FColorThumb;
          Canvas.Polygon(P);
        end;
    end;
  end;

var
  R: Integer;
  track, rang, btn1, btn2, btn: TRect;
  rectBelow, rectAbove: TRect;
  dx, dy: Integer;
begin
  if FVertical then begin
    track.Left := (Width - FTrackSize.X) div 2;
    track.Top := FTrackStart;
  end else begin
    track.Left := FTrackStart;
    track.Top := (Height - FTrackSize.Y) div 2;
  end;
  track.Right := track.Left + FTrackSize.x;
  track.Bottom := track.Top + FTrackSize.y;

  btn1 := GetRectFromPoint(FMinPosition, taLeftJustify);
  btn2 := GetRectFromPoint(FMaxPosition, taRightJustify);
  btn := GetRectFromPoint(FPosition, taCenter);

  if FVertical then begin
    dx := 0;
    dy := IfThen(ExtendedThumbs, FBtnSize.Y, 0);
    rang.Top := IfThen(ExtendedThumbs, btn1.Bottom, GetThumbCenter(btn1).Y);
    rang.Bottom := IfThen(ExtendedThumbs, btn2.Top, GetThumbCenter(btn2).Y);
    rang.Left := track.Left;
    rang.Right := track.Right;
    if FSliderMode = smSingle then begin
      rectBelow := Rect(track.Left, track.Top, track.Right, IfThen(ExtendedThumbs, btn.Top, GetThumbCenter(btn).Y));
      rectAbove := Rect(track.Left, IfThen(ExtendedThumbs, btn.Bottom, GetThumbCenter(btn).Y), track.Right, track.bottom);
    end else begin
      rectBelow := Rect(track.Left, track.Top, track.Right, rang.Top);
      rectAbove := Rect(track.Left, rang.Bottom, track.Right, track.Bottom);
    end;
  end else begin
    dx := IfThen(ExtendedThumbs, FBtnSize.X, 0);
    dy := 0;
    rang.Top := track.Top;
    rang.Bottom := track.Bottom;
    rang.Left := IfThen(ExtendedThumbs, btn1.Right, GetThumbCenter(btn1).X);
    rang.Right := IfThen(ExtendedThumbs, btn2.Left, GetThumbCenter(btn2).X);
    if FSliderMode = smSingle then begin
      rectBelow := Rect(track.Left, track.Top, IfThen(ExtendedThumbs, btn.Left, GetThumbCenter(btn).X), track.Bottom);
      rectAbove := Rect(IfThen(ExtendedThumbs, btn.Right, GetThumbCenter(btn).X), track.Top, track.Right, track.Bottom);
    end else begin
      rectBelow := Rect(track.Left, track.Top, rang.Left, track.Bottom);
      rectAbove := Rect(rang.Right, track.Top, track.Right, track.Bottom)
    end;
  end;

  R := IfThen(ExtendedThumbs, Min(FTrackSize.X, FTrackSize.Y), 0);
  if not Flat then begin
    DrawRect(track, -(dx+2), -(dy+2), dx, dy, R, clBtnShadow);
    DrawRect(track, -dx, -dy, dx+2, dy+2, R, clBtnHighlight);
  end;
  DrawRect(rectBelow, -(dx+1), -(dy+1), dx+1, dy+1, R, FColorBelow);
  DrawRect(rectAbove, -(dx+1), -(dy+1), dx+1, dy+1, R, FColorAbove);
  if FSliderMode <> smSingle then
    DrawRect(rang, -1, -1, 1, 1, 0, FColorBetween);

  if (FSliderMode <> smSingle) then begin
    DrawThumb(btn1, track, FThumbStyle = tsTriangleOtherSide);
    DrawThumb(btn2, track, FThumbStyle = tsTriangleOtherSide);
  end;
  if (FSliderMode <> smMinMax) then
    DrawThumb(btn, track, FThumbStyle <> tsTriangleOtherSide);
end;

function TMultiSlider.PointToPosition(P: TPoint): Integer;
var
  pos_start, pos_range: Integer;
  coord: Integer;
  coord_range: Integer;
  coord_start: Integer;
  btn1, btn2: TRect;
begin
  if FVertical then
    coord := P.Y
  else
    coord := P.X;
  if (TThumbKind(FCapture) = tkValue) and (FSliderMode <> smSingle) then begin
    btn1 := GetRectFromPoint(FMinPosition, taLeftJustify);
    btn2 := GetRectFromPoint(FMaxPosition, taRightJustify);
    pos_start := FMinPosition;
    pos_range := FMaxPosition - FMinPosition;
    if ExtendedThumbs then begin
      if FVertical then begin
        coord_start := btn1.Bottom + FCaptureOffset;
        coord_range := btn2.Top - btn1.Bottom;
      end else begin
        coord_start := btn1.Right + FCaptureOffset;
        coord_range := btn2.Left - btn1.Right;
      end;
    end else begin
      if FVertical then begin
        coord_start := GetThumbCenter(btn1).Y + FCaptureOffset;
        coord_range := btn2.Top - btn1.Top;
      end else begin
        coord_start := GetThumbCenter(btn1).X + FCaptureOffset;
        coord_range := btn2.Left - btn1.Left;
      end;
    end;
    {
    if FThumbStyle = tsTriangle then begin
      if FVertical then begin
      end else begin
        coord_start := (btn1.Left + btn1.Right) div 2 + FCaptureOffset;
        coord_range := btn2.Left - btn1.Left;
      end
    end else begin
      if FVertical then begin
        coord_start := btn1.Top + FCaptureOffset;
        coord_range := btn2.Top - btn1.Bottom;
      end else begin
        coord_start := btn1.Right + FCaptureOffset;
        coord_range := btn2.Left - btn1.Right;
      end;
    end;
    }
  end else begin
    pos_start := FRangeMin;
    pos_range := FRangeMax - FRangeMin;
    coord_start := FTrackStart + FCaptureOffset;
    coord_range := GetTracklength;
  end;
  Result := round(pos_start + pos_range * (coord - coord_start) / coord_range);
end;

procedure TMultiSlider.Resize;
begin
  inherited;
  UpdateBounds;
end;
                         {
procedure TMultiSlider.SetColor(AValue: TColor);
begin
  inherited;
  if AValue = clNone then
    ControlStyle := ControlStyle - [csOpaque]
  else
    ControlStyle := ControlStyle + [csOpaque];
end;                      }

procedure TMultiSlider.SetColorAbove(AValue: TColor);
begin
  if AValue = FColorAbove then exit;
  FColorAbove := AValue;
  Invalidate;
end;

procedure TMultiSlider.SetColorBelow(AValue: TColor);
begin
  if AValue = FColorBelow then exit;
  FColorBelow := AValue;
  Invalidate;
end;

procedure TMultiSlider.SetColorBetween(AValue: TColor);
begin
  if AValue = FColorBetween then exit;
  FColorBetween := AValue;
  Invalidate;
end;

procedure TMultiSlider.SetColorThumb(AValue: TColor);
begin
  if AValue = FColorThumb then exit;
  FColorThumb := AValue;
  Invalidate;
end;

procedure TMultiSlider.SetDefaultSize(AValue: Integer);
begin
  if FDefaultSize = AValue then exit;
  FDefaultSize := AValue;
  if AutoSize then begin
    if FVertical then Width := FDefaultSize else Height := FDefaultSize;
  end;
  UpdateBounds;
end;

procedure TMultiSlider.SetFlat(AValue: Boolean);
begin
  if FFlat = AValue then exit;
  FFlat := AValue;
  Invalidate;
end;

procedure TMultiSlider.SetMaxPosition(AValue: Integer);
var
  newPos: Integer;
begin
  newPos := Min(Max(AValue, FRangeMin), FRangeMax);
  if (newPos = FMaxPosition) then exit;
  if (newPos < FMinPosition) and (FSliderMode <> smSingle) then newPos := FMinPosition;
  if (newPos < FPosition) and (FSliderMode <> smMinMax) then newPos := FPosition;
  FMaxPosition := newPos;
  DoPositionChange(tkMax, FMaxPosition);
  Invalidate;
end;

procedure TMultiSlider.SetMinPosition(AValue: Integer);
var
  newPos: Integer;
begin
  newPos := Max(Min(AValue, FRangeMax), FRangeMin);
  if (newPos = FMinPosition) then exit;
  if (newPos > FMaxPosition) and (FSliderMode <> smSingle) then newPos := FMaxPosition;
  if (newPos > FPosition) and (FSliderMode <> smMinMax) then newPos := FPosition;
  FMinPosition := newPos;
  DoPositionChange(tkMin, FMinPosition);
  Invalidate;
end;

procedure TMultiSlider.SetPosition(AValue: Integer);
var
  newPos: Integer;
begin
  newPos := Max(Min(AValue, FRangeMax), FRangeMin);
  if (newPos = FPosition) then exit;
  if (FSliderMode <> smSingle) then begin
    if (newPos < FMinPosition) then newPos := FMinPosition;
    if (newPos > FMaxPosition) then newPos := FMaxPosition;
  end;
  FPosition := newPos;
  DoPositionChange(tkValue, FPosition);
  Invalidate;
end;

procedure TMultiSlider.SetRangeMax(AValue:Integer);
begin
  if FRangeMax = AValue then exit;
  FRangeMax := AValue;
  DoPositionChange(tkMax, FRangeMax);
  Invalidate;
end;

procedure TMultiSlider.SetRangeMin(AValue: Integer);
begin
  if FRangeMin = AValue then exit;
  FRangeMin := AValue;
  DoPositionChange(tkMin, FRangeMin);
  Invalidate;
end;

procedure TMultiSlider.SetThumbStyle(AValue: TThumbStyle);
begin
  if FThumbStyle = AValue then exit;
  FThumbStyle := AValue;
  Invalidate;
end;

procedure TMultiSlider.SetTrackThickness(AValue: Integer);
begin
  if FTrackThickness = AValue then exit;
  FTrackThickness := AValue;
  UpdateBounds;
end;

procedure TMultiSlider.SetVertical(AValue: Boolean);
begin
  if FVertical = AValue then exit;
  FVertical := AValue;
  //if not (csLoading in ComponentState) then begin
    if FAutoRotate then begin
      if (FVertical and (Width > Height)) or ((not FVertical) and (Width < Height)) then
        SetBounds(Left, Top, Height, Width);
    end;
    UpdateBounds;
  //end;
end;

procedure TMultiSlider.SetSliderMode(AValue: TSliderMode);
begin
  if FSliderMode = AValue then exit;
  FSliderMode := AValue;
  Invalidate;
end;

procedure TMultiSlider.UpdateBounds;
var
  buttonSize: Integer;
begin
  buttonSize := FDefaultSize*5 div 8;
  if FVertical then begin
    FBtnSize := Point(FDefaultSize, buttonSize);
    FTrackSize := Point(FTrackThickness, Height - FTrackStart * 2);
  end else begin
    FBtnSize:= Point(buttonSize, FDefaultSize);
    FTrackSize := Point(Width - FTrackStart * 2, FTrackThickness);
  end;
  Invalidate;
end;

end.


