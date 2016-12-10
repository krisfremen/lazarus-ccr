unit SLHColorPicker;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

{$I mxs.inc}

uses
 {$IFDEF FPC}
 LCLIntf, LCLType, LMessages,
 {$ELSE}
 Windows, Messages,
 {$ENDIF}
 SysUtils, Classes, Controls, Graphics, Forms,
 RGBHSLUtils, mbTrackBarPicker, SLColorPicker, HColorPicker, Menus,
 {$IFDEF DELPHI_7_UP} Themes, {$ENDIF} HTMLColors, mbBasicPicker;

type
 TSLHColorPicker = class(TmbBasicPicker)
 private
  FOnChange: TNotifyEvent;
  FSLPicker: TSLColorPicker;
  FHPicker: THColorPicker;
  FSelectedColor: TColor;
  FHValue, FSValue, FLValue: integer;
  FRValue, FGValue, FBValue: integer;
  FSLHint, FHHint: string;
  FSLMenu, FHMenu: TPopupMenu;
  FSLCursor, FHCursor: TCursor;
  PBack: TBitmap;

  function GetManual: boolean;
  procedure SelectColor(c: TColor);
  procedure SetH(v: integer);
  procedure SetS(v: integer);
  procedure SetL(v: integer);
  procedure SetR(v: integer);
  procedure SetG(v: integer);
  procedure SetB(v: integer);
  procedure SetHHint(h: string);
  procedure SetSLHint(h: string);
  procedure SetSLMenu(m: TPopupMenu);
  procedure SetHMenu(m: TPopupMenu);
  procedure SetHCursor(c: TCursor);
  procedure SetSLCursor(c: TCursor);
 protected
  procedure CreateWnd; override;
  procedure Resize; override;
  procedure Paint; override;
  procedure PaintParentBack; override;
  procedure WMSetFocus(var Message: {$IFDEF FPC}TLMSetFocus{$ELSE}TWMSetFocus{$ENDIF});
    message {$IFDEF FPC}LM_SETFOCUS{$ELSE}WM_SETFOCUS{$ENDIF};
  procedure DoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  procedure HPickerChange(Sender: TObject);
  procedure SLPickerChange(Sender: TObject);
  procedure DoChange;
 public
  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;

  function GetColorUnderCursor: TColor;
  function GetHexColorUnderCursor: string;
  function GetSelectedHexColor: string;
  property ColorUnderCursor: TColor read GetColorUnderCursor;
  property HValue: integer read FHValue write SetH default 0;
  property SValue: integer read FSValue write SetS default 240;
  property LValue: integer read FLValue write SetL default 120;
  property RValue: integer read FRValue write SetR default 255;
  property GValue: integer read FGValue write SetG default 0;
  property BValue: integer read FBValue write SetB default 0;
  property Manual: boolean read GetManual;
 published
  property SelectedColor: TColor read FSelectedColor write SelectColor default clRed;
  property HPickerPopupMenu: TPopupMenu read FHMenu write SetHMenu;
  property SLPickerPopupMenu: TPopupMenu read FSLMenu write SetSLMenu;
  property HPickerHintFormat: string read FHHint write SetHHint;
  property SLPickerHintFormat: string read FSLHint write SetSLHint;
  property HPickerCursor: TCursor read FHCursor write SetHCursor default crDefault;
  property SLPickerCursor: TCursor read FSLCursor write SetSLCursor default crDefault;
  property TabStop default true;
  property ShowHint;
  property ParentShowHint;
  property Anchors;
  property Align;
  property Visible;
  property Enabled;
  property TabOrder;
  property Color;
  property ParentColor default true;
  {$IFDEF DELPHI_7_UP}{$IFDEF DELPHI}
  property ParentBackground default true;
  {$ENDIF}{$ENDIF}

  property OnChange: TNotifyEvent read FOnChange write FOnChange;
  property OnMouseMove;
 end;

procedure Register;

implementation

{$IFDEF FPC}
  {$R SLHColorPicker.dcr}
{$ENDIF}

procedure Register;
begin
 RegisterComponents('mbColor Lib', [TSLHColorPicker]);
end;

{TSLHColorPicker}

constructor TSLHColorPicker.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csAcceptsControls] + [csOpaque];
  DoubleBuffered := true;
  PBack := TBitmap.Create;
  PBack.PixelFormat := pf32bit;
  ParentColor := true;
 {$IFDEF DELPHI_7_UP}{$IFDEF DELPHI}
  ParentBackground := true;
 {$ENDIF}{$ENDIF}
  SetInitialBounds(0, 0, 297, 271);
//  Width := 297;
//  Height := 271;
  TabStop := true;
  FSelectedColor := clRed;
  FHPicker := THColorPicker.Create(Self);
  InsertControl(FHPicker);
  FHCursor := crDefault;
  FSLCursor := crDefault;

  // Hue picker
  with FHPicker do
  begin
    SetInitialBounds(257, 0, 40, 271);
    {
    Height := 271;
    Width := 40;
    Top := 0;
    Left := 257;
    }
    Anchors := [akTop, akRight, akBottom];
    Visible := true;
    Layout := lyVertical;
    ArrowPlacement := spBoth;
    NewArrowStyle := true;
    OnChange := HPickerChange;
    OnMouseMove := DoMouseMove;
  end;

  // Saturation-Lightness picker
  FSLPicker := TSLColorPicker.Create(Self);
  InsertControl(FSLPicker);
  with FSLPicker do
  begin
    SetInitialBounds(0, 0, 255, 271);
    {
    Width := 255;
    Height := 271; //255;
    Top := 0; //8;
    Left := 0;
    }
    Anchors := [akLeft, akRight, akTop, akBottom];
    Visible := true;
    SelectedColor := clRed;
    OnChange := SLPickerChange;
    OnMouseMove := DoMouseMove;
  end;
  FHValue := 0;
  FSValue := 255;
  FLValue := 255;
  FRValue := 255;
  FGValue := 0;
  FBValue := 0;
  FHHint := 'Hue: %h';
  FSLHint := 'S: %hslS L: %l'#13'Hex: %hex';
end;

destructor TSLHColorPicker.Destroy;
begin
 PBack.Free;
 FHPicker.Free;
 FSLPicker.Free;
 inherited Destroy;
end;

procedure TSLHColorPicker.HPickerChange(Sender: TObject);
begin
  FSLPicker.Hue := FHPicker.Hue;
  DoChange;
end;

procedure TSLHColorPicker.SLPickerChange(Sender: TObject);
begin
 FSelectedColor := FSLPicker.SelectedColor;
 DoChange;
end;

procedure TSLHColorPicker.DoChange;
begin
 FHValue := FHPicker.Hue;
 FSValue := FSLPicker.Saturation;
 FLValue := FSLPicker.Luminance;
 FRValue := GetRValue(FSLPicker.SelectedColor);
 FGValue := GetGValue(FSLPicker.SelectedColor);
 FBValue := GetBValue(FSLPicker.SelectedColor);
 if Assigned(FOnChange) then
  FOnChange(Self);
end;

procedure TSLHColorPicker.SelectColor(c: TColor);
begin
 FSelectedColor := c;
 FHPicker.Hue := GetHValue(c);
 FSLPicker.SelectedColor := c;
end;

procedure TSLHColorPicker.SetH(v: integer);
begin
 FHValue := v;
 FSLPicker.Hue := v;
 FHPicker.Hue := v;
end;

procedure TSLHColorPicker.SetS(v: integer);
begin
 FSValue := v;
 FSLPicker.Saturation := v;
end;

procedure TSLHColorPicker.SetL(v: integer);
begin
 FLValue := v;
 FSLPicker.Luminance := v;
end;

procedure TSLHColorPicker.SetR(v: integer);
begin
 FRValue := v;
 SelectColor(RGB(FRValue, FGValue, FBValue));
end;

procedure TSLHColorPicker.SetG(v: integer);
begin
 FGValue := v;
 SelectColor(RGB(FRValue, FGValue, FBValue));
end;

procedure TSLHColorPicker.SetB(v: integer);
begin
 FBValue := v;
 SelectColor(RGB(FRValue, FGValue, FBValue));
end;

function TSLHColorPicker.GetSelectedHexColor: string;
begin
 Result := ColorToHex(FSelectedColor);
end;

procedure TSLHColorPicker.SetHHint(h: string);
begin
 FHHint := h;
 FHPicker.HintFormat := h;
end;

procedure TSLHColorPicker.SetSLHint(h: string);
begin
 FSLHint := h;
 FSLPicker.HintFormat := h;
end;

procedure TSLHColorPicker.SetSLMenu(m: TPopupMenu);
begin
 FSLMenu := m;
 FSLPicker.PopupMenu := m;
end;

procedure TSLHColorPicker.SetHMenu(m: TPopupMenu);
begin
 FHMenu := m;
 FHPicker.PopupMenu := m;
end;

procedure TSLHColorPicker.DoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 if Assigned(OnMouseMove) then
  OnMouseMove(Self, Shift, x, y);
 inherited;
end;

function TSLHColorPicker.GetColorUnderCursor: TColor;
begin
 Result := FSLPicker.GetColorUnderCursor;
end;

function TSLHColorPicker.GetHexColorUnderCursor: string;
begin
 Result := FSLPicker.GetHexColorUnderCursor;
end;

procedure TSLHColorPicker.SetHCursor(c: TCursor);
begin
 FHCursor := c;
 FHPicker.Cursor := c;
end;

procedure TSLHColorPicker.SetSLCursor(c: TCursor);
begin
 FSLCursor := c;
 FSLPicker.Cursor := c;
end;

procedure TSLHColorPicker.WMSetFocus(
  var Message: {$IFDEF FPC}TLMSetFocus{$ELSE}TWMSetFocus{$ENDIF} );
begin
 FHPicker.SetFocus;
 Message.Result := 1;
end;

function TSLHColorPicker.GetManual:boolean;
begin
 Result := FHPicker.Manual or FSLPicker.Manual;
end;

procedure TSLHColorPicker.Resize;
begin
  inherited;
  PaintParentBack;

  if FSLPicker = nil then
   exit;
  if FHPicker = nil then
   exit;

  FSLPicker.Width := Width - FHPicker.Width - 10;
  FSLPicker.Height := Height - 2;

  FHPicker.Left := Width - FHPicker.Width - 2;
  FHPicker.Height := Height - 2;
end;

procedure TSLHColorPicker.PaintParentBack;
begin
  if PBack = nil then
  begin
    PBack := TBitmap.Create;
    PBack.PixelFormat := pf32bit;
  end;
  PBack.Width := Width;
  PBack.Height := Height;
  PaintParentBack(PBack);
end;

procedure TSLHColorPicker.Paint;
begin
  PaintParentBack;
  Canvas.Draw(0, 0, PBack);
end;

procedure TSLHColorPicker.CreateWnd;
begin
 inherited;
 PaintParentBack;
end;

end.