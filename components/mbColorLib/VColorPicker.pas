unit VColorPicker;

interface

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

uses
  {$IFDEF FPC}
  LCLIntf, LCLType, LMessages,
  {$ELSE}
  Windows, Messages,
  {$ENDIF}
  SysUtils, Classes, Controls, Forms, Graphics,
  RGBHSVUtils, mbTrackBarPicker, HTMLColors, Scanlines;

type
  TVColorPicker = class(TmbTrackBarPicker)
  private
    FHue, FSat, FVal: integer;
 // FVBmp: TBitmap;

    function ArrowPosFromVal(l: integer): integer;
    function ValFromArrowPos(p: integer): integer;
    function GetSelectedColor: TColor;
    procedure SetSelectedColor(c: TColor);
//    procedure CreateVGradient;
    procedure SetHue(h: integer);
    procedure SetSat(s: integer);
    procedure SetValue(v: integer);
  protected
    procedure Execute(tbaAction: integer); override;
    function GetArrowPos: integer; override;
    function GetGradientColor(AValue: Integer): TColor; override;
    function GetSelectedValue: integer; override;
  public
    constructor Create(AOwner: TComponent); override;
//  destructor Destroy; override;
  published
    property Hue: integer read FHue write SetHue default 0;
    property Saturation: integer read FSat write SetSat default 0;
    property Value: integer read FVal write SetValue default 255;
    property SelectedColor: TColor read GetSelectedColor write SetSelectedColor default clRed;
    property Layout default lyVertical;
  end;

procedure Register;

implementation

{$IFDEF FPC}
  {$R VColorPicker.dcr}

{uses
  IntfGraphics, fpimage;}
{$ENDIF}

procedure Register;
begin
  RegisterComponents('mbColor Lib', [TVColorPicker]);
end;

{TVColorPicker}

constructor TVColorPicker.Create(AOwner: TComponent);
begin
  inherited;
  FGradientWidth := 256;
  FGradientHeight := 12;
  {
  FVBmp := TBitmap.Create;
  FVBmp.PixelFormat := pf32bit;
  FVBmp.SetSize(12, 255);
  }
//  Width := 22;
//  Height := 267;
  SetInitialBounds(0, 0, 22, 267);
  Layout := lyVertical;
  FHue := 0;
  FSat := 0;
  FArrowPos := ArrowPosFromVal(255);
  FChange := false;
  SetValue(255);
  HintFormat := 'Value: %value';
  FManual := false;
  FChange := true;
end;

function TVColorPicker.GetGradientColor(AValue: Integer): TColor;
begin
  Result := HSVtoColor(FHue, FSat, AValue);
end;

procedure TVColorPicker.SetHue(h: integer);
begin
  if h > 360 then h := 360;
  if h < 0 then h := 0;
  if FHue <> h then
  begin
    FHue := h;
    FManual := false;
    CreateGradient;
    Invalidate;
    if FChange and Assigned(OnChange) then OnChange(Self);
  end;
end;

procedure TVColorPicker.SetSat(s: integer);
begin
  if s > 255 then s := 255;
  if s < 0 then s := 0;
  if FSat <> s then
  begin
    FSat := s;
    FManual := false;
    CreateGradient;
    Invalidate;
    if FChange and Assigned(OnChange) then OnChange(Self);
  end;
end;

function TVColorPicker.ArrowPosFromVal(l: integer): integer;
var
  a: integer;
begin
  if Layout = lyHorizontal then
  begin
    a := Round(((Width - 12)/255)*l);
    if a > Width - FLimit then a := Width - FLimit;
  end
  else
  begin
    l := 255 - l;
    a := Round(((Height - 12)/255)*l);
    if a > Height - FLimit then a := Height - FLimit;
  end;
  if a < 0 then a := 0;
  Result := a;
end;

function TVColorPicker.ValFromArrowPos(p: integer): integer;
var
  r: integer;
begin
  if Layout = lyHorizontal then
    r := Round(p/((Width - 12)/255))
  else
    r := Round(255 - p/((Height - 12)/255));
  if r < 0 then r := 0;
  if r > 255 then r := 255;
  Result := r;
end;

procedure TVColorPicker.SetValue(V: integer);
begin
  if v < 0 then v := 0;
  if v > 255 then v := 255;
  if FVal <> v then
  begin
    FVal := v;
    FArrowPos := ArrowPosFromVal(v);
    FManual := false;
    Invalidate;
    if FChange and Assigned(OnChange) then OnChange(Self);
  end;
end;

function TVColorPicker.GetSelectedColor: TColor;
begin
  if not WebSafe then
    Result := HSVtoColor(FHue, FSat, FVal)
  else
    Result := GetWebSafe(HSVtoColor(FHue, FSat, FVal));
end;

function TVColorPicker.GetSelectedValue: integer;
begin
  Result := FVal;
end;

procedure TVColorPicker.SetSelectedColor(c: TColor);
var
  h, s, v: integer;
begin
  if WebSafe then c := GetWebSafe(c);
  RGBToHSV(GetRValue(c), GetGValue(c), GetBValue(c), h, s, v);
  FChange := false;
  SetHue(h);
  SetSat(s);
  SetValue(v);
  FManual := false;
  FChange := true;
  if Assigned(OnChange) then OnChange(Self);
end;

function TVColorPicker.GetArrowPos: integer;
begin
  Result := ArrowPosFromVal(FVal);
end;

procedure TVColorPicker.Execute(tbaAction: integer);
begin
  case tbaAction of
    TBA_Resize:
      SetValue(FVal);
    TBA_MouseMove:
      FVal := ValFromArrowPos(FArrowPos);
    TBA_MouseDown:
      FVal := ValFromArrowPos(FArrowPos);
    TBA_MouseUp:
      FVal := ValFromArrowPos(FArrowPos);
    TBA_WheelUp:
      SetValue(FVal + Increment);
    TBA_WheelDown:
      SetValue(FVal - Increment);
    TBA_VKRight:
      SetValue(FVal + Increment);
    TBA_VKCtrlRight:
      SetValue(255);
    TBA_VKLeft:
      SetValue(FVal - Increment);
    TBA_VKCtrlLeft:
      SetValue(0);
    TBA_VKUp:
      SetValue(FVal + Increment);
    TBA_VKCtrlUp:
      SetValue(255);
    TBA_VKDown:
      SetValue(FVal - Increment);
    TBA_VKCtrlDown:
      SetValue(0);
    else
      inherited;
  end;
end;

end.