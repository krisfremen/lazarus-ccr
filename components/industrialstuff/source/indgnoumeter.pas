{**********************************************************************
 GnouMeter is a meter which can display an integer or a float value (Single).
 Just like a progress bar or a gauge, all you have do do is to define
 the Minimum and maximum values as well as the actual value.

 Above the meter, one can display the name of the data being measured (optional)
 and its actual value with its corresponding unit.
 The minimum and maximum values are respectively shown at the bottom and the
 top of the meter with their corresponding units.
 The meter is filled with the color ColorFore and its background color
 is defined by the ColorBack Property.

 THIS COMPONENT IS ENTIRELY FREEWARE

 Author: Jérôme Hersant
         jhersant@post4.tele.dk
***********************************************************************}

unit indGnouMeter;

{$mode objfpc}{$H+}

interface

uses
  Classes, Controls, Graphics, SysUtils,
  LMessages, Types, LCLType, LCLIntf;

const
  DEFAULT_BAR_THICKNESS = 5;
  DEFAULT_GAP_TOP = 20;
  DEFAULT_GAP_BOTTOM = 10;
  DEFAULT_MARKER_DIST = 4;
  DEFAULT_MARKER_SIZE = 6;

type
  TindGnouMeter = class(TGraphicControl)
  private
    fValue: Double;
    fColorFore: TColor;
    fColorBack: TColor;
    fSignalUnit: ShortString;
    fValueMax: Double;
    fValueMin: Double;
    fDigits: Byte;
    fIncrement: Double;
    fShowIncrements: Boolean;
    fGapTop: Word;
    fGapBottom: Word;
    fBarThickness: Word;
    fMarkerColor: TColor;
    fMarkerDist: Integer;
    fMarkerSize: Integer;
    fShowMarker: Boolean;
    //Variables used internally
    TopTextHeight: Word;
    LeftMeter: Integer;
    DisplayValue: String;
    DrawStyle: integer;
    TheRect: TRect;
    //End of variables used internally
    function IsBarThicknessStored: Boolean;
    function IsGapBottomStored: Boolean;
    function IsGapTopStored: Boolean;
    function IsMarkerDistStored: Boolean;
    function IsMarkerSizeStored: Boolean;
    procedure SetValue(val: Double);
    procedure SetColorBack(val: TColor);
    procedure SetColorFore(val: TColor);
    procedure SetSignalUnit(val: ShortString);
    procedure SetValueMin(val: Double);
    procedure SetValueMax(val: Double);
    procedure SetDigits(val: Byte);
    procedure SetTransparent(val: Boolean);
    function GetTransparent: Boolean;
    procedure SetIncrement(val: Double);
    procedure SetShowIncrements(val: Boolean);
    procedure SetGapTop(val: Word);
    procedure SetGapBottom(val: Word);
    procedure SetBarThickness(val: Word);
    procedure SetMarkerColor(val: TColor);
    procedure SetMarkerDist(val: Integer);
    procedure SetMarkerSize(val: Integer);
    procedure SetShowMarker(val: Boolean);
    procedure DrawTopText;
    procedure DrawMeterBar;
    procedure DrawIncrements;
    function ValueToPixels(val: Double): integer;
    procedure DrawValueMax;
    procedure DrawValueMin;
    procedure DrawMarker;
  protected
    procedure CMTextChanged(var {%H-}Message: TLMessage); message CM_TEXTCHANGED;
    procedure DoAutoAdjustLayout(const AMode: TLayoutAdjustmentPolicy;
      const AXProportion, AYProportion: Double); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Caption;
    property Visible;
    property ShowHint;
    property Value: Double read fValue write SetValue;
    property Color;
    property Font;
    property ParentColor;
    property ColorFore: Tcolor read fColorFore write SetColorFore default clRed;
    property ColorBack: Tcolor read fColorBack write SetColorBack default clBtnFace;
    property SignalUnit: ShortString read fSignalUnit write SetSignalUnit;
    property ValueMin: Double read fValueMin write SetValueMin;
    property ValueMax: Double read fValueMax write SetValueMax;
    property Digits: Byte read fDigits write SetDigits;
    property Increment: Double read fIncrement write SetIncrement;
    property ShowIncrements: Boolean read fShowIncrements write SetShowIncrements default true;
    property Transparent: Boolean read GetTransparent write SetTransparent default true;
    property GapTop: Word
      read fGapTop write SetGapTop stored IsGapTopStored;
    property GapBottom: Word
      read fGapBottom write SetGapBottom stored IsGapBottomStored;
    property BarThickness: Word
      read fBarThickness write SetBarThickness stored IsBarThicknessStored;
    property MarkerColor: TColor read fMarkerColor write SetMarkerColor;
    property MarkerDist: Integer
      read fMarkerDist write SetMarkerDist stored IsMarkerDistStored;
    property MarkerSize: Integer
      read fMarkerSize write SetMarkerSize stored IsMarkerSizeStored;
    property ShowMarker: Boolean read fShowMarker write SetShowMarker default true;
  end;


implementation

constructor TindGnouMeter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable, csSetCaption];
  Width := 100;
  Height := 200;
  fColorFore := clRed;
  fColorBack := clBtnFace;
  fMarkerColor := clBlue;
  fValueMin := 0;
  fValueMax := 100;
  fIncrement := 10;
  fShowIncrements := True;
  fShowMarker := True;
  fValue := 0;
  fGapTop := Scale96ToFont(DEFAULT_GAP_TOP);
  fGapBottom := Scale96ToFont(DEFAULT_GAP_BOTTOM);
  fBarThickness := Scale96ToFont(DEFAULT_BAR_THICKNESS);
  fMarkerDist := Scale96ToFont(DEFAULT_MARKER_DIST);
  fMarkerSize := Scale96ToFont(DEFAULT_MARKER_SIZE);
  fSignalUnit := 'Units';
end;

destructor TindGnouMeter.Destroy;
begin
  inherited Destroy;
end;

procedure TindGnouMeter.CMTextChanged(var Message: TLMessage);
begin
  Invalidate;
end;

procedure TindGnouMeter.DoAutoAdjustLayout(
  const AMode: TLayoutAdjustmentPolicy;
  const AXProportion, AYProportion: Double);
begin
  inherited DoAutoAdjustLayout(AMode, AXProportion, AYProportion);
  if AMode in [lapAutoAdjustWithoutHorizontalScrolling, lapAutoAdjustForDPI] then
  begin
    DisableAutosizing;
    try
      if IsBarThicknessStored then
        FBarThickness := Round(FBarThickness * AXProportion);
      if IsGapBottomStored then
        FGapBottom := Round(FGapBottom * AYProportion);
      if IsGapTopStored then
        FGapTop := Round(FGapTop * AYProportion);
      if IsMarkerDistStored then
        FMarkerDist := Round(FMarkerDist * AXProportion);
      if IsMarkerSizeStored then
        FMarkerSize := Round(FMarkerSize * AXProportion);
    finally
      EnableAutoSizing;
    end;
  end;
end;

function TindGnouMeter.IsBarThicknessStored: Boolean;
begin
  Result := FBarThickness <> Scale96ToFont(DEFAULT_BAR_THICKNESS);
end;

function TindGnouMeter.IsGapBottomStored: Boolean;
begin
  Result := FGapBottom <> Scale96ToFont(DEFAULT_GAP_BOTTOM);
end;

function TindGnouMeter.IsGapTopStored: Boolean;
begin
  Result := FGapTop <> Scale96ToFont(DEFAULT_GAP_TOP);
end;

function TindGnouMeter.IsMarkerDistStored: Boolean;
begin
  Result := FMarkerDist <> Scale96ToFont(DEFAULT_MARKER_DIST);
end;

function TindGnouMeter.IsMarkerSizeStored: Boolean;
begin
  Result := FMarkerSize <> Scale96ToFont(DEFAULT_MARKER_SIZE);
end;

procedure TindGnouMeter.SetValue(val: Double);
begin
  if (val <> fValue) and (val >= fValueMin) and (val <= fValueMax) then
  begin
    fValue := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetColorFore(val: TColor);
begin
  if val <> fColorFore then
  begin
    fColorFore := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetColorBack(val: TColor);
begin
  if val <> fColorBack then
  begin
    fColorBack := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetSignalUnit(val: ShortString);
begin
  if val <> fSignalUnit then
  begin
    fSignalUnit := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetValueMin(val: Double);
begin
  if (val <> fValueMin) and (val <= fValue) then
  begin
    fValueMin := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetValueMax(val: Double);
begin
  if (val <> fValueMax) and (val >= fValue) then
  begin
    fValueMax := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetDigits(val: Byte);
begin
  if (val <> fDigits) then
  begin
    fDigits := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetIncrement(val: Double);
begin
  if (val <> fIncrement) and (val > 0) then
  begin
    fIncrement := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetShowIncrements(val: Boolean);
begin
  if (val <> fShowIncrements) then
  begin
    fShowIncrements := val;
    Invalidate;
  end;
end;

function TindGnouMeter.GetTransparent: Boolean;
begin
  Result := not (csOpaque in ControlStyle);
end;

procedure TindGnouMeter.SetTransparent(Val: Boolean);
begin
  if Val <> Transparent then
  begin
    if Val then
      ControlStyle := ControlStyle - [csOpaque]
    else
      ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetGapTop(val: Word);
begin
  if (val <> fGapTop) then
  begin
    fGapTop := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetGapBottom(val: Word);
begin
  if (val <> fGapBottom) then
  begin
    fGapBottom := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetBarThickness(val: Word);
begin
  if (val <> fBarThickness) and (val > 0) then
  begin
    fBarThickness := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetMarkerColor(val: TColor);
begin
  if (val <> fMarkerColor) then
  begin
    fMarkerColor := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetMarkerDist(val: Integer);
begin
  if (val <> fMarkerDist) then
  begin
    fMarkerDist := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetMarkerSize(val: Integer);
begin
  if (val <> fMarkerSize) then
  begin
    fMarkerSize := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.SetShowMarker(val: Boolean);
begin
  if (val <> fShowMarker) then
  begin
    fShowMarker := val;
    Invalidate;
  end;
end;

procedure TindGnouMeter.DrawIncrements;
var
  i: Double;
  PosPixels: Word;
begin
  if fShowIncrements then
  begin
    with Canvas do
    begin
      i := fValueMin;
      while i <= fValueMax do
      begin
        PosPixels := ValueToPixels(i);
        pen.color := clGray;
        MoveTo(LeftMeter + BarThickness + 3, PosPixels - 1);
        LineTo(LeftMeter + BarThickness + 7, PosPixels - 1);
        pen.color := clWhite;
        MoveTo(LeftMeter + BarThickness + 3, PosPixels);
        LineTo(LeftMeter + BarThickness + 7, PosPixels);
        i := i + fIncrement;
      end;
    end;
  end;
end;

procedure TindGnouMeter.DrawMarker;
var
  v: Integer;
  dx, dy: Integer;
begin
  if fShowMarker then
  begin
    v := ValueToPixels(fValue);
    with Canvas do
    begin
      dx := FMarkerSize;
      dy := round(FMarkerSize * sin(pi/6));

      // 3D edges
      Pen.Color := clWhite;
      Brush.Style := bsClear;
      MoveTo(LeftMeter - FMarkerDist + 1, v);
      LineTo(LeftMeter - FMarkerDist - dx - 1, v - dy - 1);
      LineTo(LeftMeter - FMarkerDist - dx - 1, v + dy + 1);
      Pen.Color := clGray;
      LineTo(LeftMeter - FMarkerDist + 1, v);

      // Triangle
      Pen.Color := fMarkerColor;
      Brush.Color := fMarkerColor;
      Brush.Style := bsSolid;
      Polygon([
        Point(LeftMeter - FMarkerDist, v),
        Point(LeftMeter - FMarkerDist - dx, v - dy),
        Point(LeftMeter - FMarkerDist - dx, v + dy)
      ]);
    end;
  end;
end;

procedure TindGnouMeter.DrawTopText;
begin
  with Canvas do
  begin
    DisplayValue := Caption;
    Brush.Style := bsClear;
    TheRect := ClientRect;
    DrawStyle := DT_SINGLELINE + DT_NOPREFIX + DT_CENTER + DT_TOP;
    Font.Style := [fsBold];
    TopTextHeight := DrawText(Handle, PChar(DisplayValue),
      Length(DisplayValue), TheRect, DrawStyle);

    Font.Style := [];
    TheRect.Top := TopTextHeight;
    DisplayValue := FloatToStrF(Value, ffFixed, 8, fDigits) + ' ' + fSignalUnit;
    TopTextHeight := TopTextHeight + DrawText(Handle, PChar(DisplayValue),
      Length(DisplayValue), TheRect, DrawStyle);
    TopTextHeight := TopTextHeight + fGapTop;
  end;
end;

procedure TindGnouMeter.DrawValueMin;
begin
  with Canvas do
  begin
    TheRect := ClientRect;
    TheRect.Left := LeftMeter + BarThickness + Scale96ToFont(10);
    TheRect.Top := TopTextHeight;
    TheRect.Bottom := Height - fGapBottom + Scale96ToFont(6);
    Brush.Style := bsClear;
    DrawStyle := DT_SINGLELINE + DT_NOPREFIX + DT_LEFT + DT_BOTTOM;
    DisplayValue := FloatToStrF(ValueMin, ffFixed, 8, fDigits) + ' ' + fSignalUnit;
    DrawText(Handle, PChar(DisplayValue), Length(DisplayValue),
      TheRect, DrawStyle);
  end;
end;

procedure TindGnouMeter.DrawValueMax;
begin
  with Canvas do
  begin
    TheRect := ClientRect;
    TheRect.Left := LeftMeter + BarThickness + Scale96ToFont(10);
    TheRect.Top := TopTextHeight - Scale96ToFont(6);
    Brush.Style := bsClear;
    DrawStyle := DT_SINGLELINE + DT_NOPREFIX + DT_LEFT + DT_TOP;
    DisplayValue := FloatToStrF(ValueMax, ffFixed, 8, fDigits) + ' ' + fSignalUnit;
    DrawText(Handle, PChar(DisplayValue), Length(DisplayValue),
      TheRect, DrawStyle);
  end;
end;

procedure TindGnouMeter.DrawMeterBar;
begin
  with Canvas do
  begin
    Pen.Color := fColorBack;
    Brush.Color := fColorBack;
    Brush.Style := bsSolid;
    Rectangle(LeftMeter, ValueToPixels(fValueMax), LeftMeter +
      fBarThickness, ValueToPixels(fValueMin));

    Pen.Color := fColorFore;
    Brush.Color := fColorFore;
    Brush.Style := bsSolid;
    Rectangle(LeftMeter + 1, ValueToPixels(fValue), LeftMeter +
      fBarThickness, ValueToPixels(fValueMin));

    Pen.color := clWhite;
    Brush.Style := bsClear;
    MoveTo(LeftMeter + fBarThickness - 1, ValueToPixels(fValueMax));
    LineTo(LeftMeter, ValueToPixels(fValueMax));
    LineTo(LeftMeter, ValueToPixels(fValueMin) - 1);

    Pen.color := clGray;
    LineTo(LeftMeter + fBarThickness, ValueToPixels(fValueMin) - 1);
    LineTo(LeftMeter + fBarThickness, ValueToPixels(fValueMax));

    if (fValue > fValueMin) and (fValue < fValueMax) then
    begin
      Pen.color := clWhite;
      MoveTo(LeftMeter + 1, ValueToPixels(fValue));
      LineTo(LeftMeter + fBarThickness, ValueToPixels(fValue));
      Pen.color := clGray;
      MoveTo(LeftMeter + 1, ValueToPixels(fValue) - 1);
      LineTo(LeftMeter + fBarThickness, ValueToPixels(fValue) - 1);
    end;
  end;
end;

function TindGnouMeter.ValueToPixels(val: Double): integer;
var
  factor: Double;
begin
  Result := 0;
  if fValueMax > fValueMin then
  begin
    Factor := (Height - fGapBottom - TopTextHeight) / (fValueMin - fValueMax);
    Result := Round(Factor * val - Factor * fValueMax + TopTextHeight);
  end;
end;

procedure TindGnouMeter.Paint;
begin
  LeftMeter := (Width div 2) - Scale96ToFont(10) - fBarThickness;
  with Canvas do
  begin
    if not Transparent then
    begin
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;
      FillRect(ClientRect);
    end;
    Brush.Style := bsClear;
    DrawTopText;
    DrawValueMin;
    DrawValueMax;
    DrawMeterBar;
    DrawMarker;
    DrawIncrements;
  end;
end;

end.
