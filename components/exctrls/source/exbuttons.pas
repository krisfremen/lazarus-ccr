unit ExButtons;

{$mode objfpc}{$H+}

interface

uses
  Graphics, Classes, SysUtils, LMessages, Types, Controls, StdCtrls, Forms;

type
  TButtonExState = (bxsNormal, bxsHot, bxsDown, bxsFocused, bxsDisabled);
  TButtonExBorderWidth = 1..10;

  TButtonEx = class;

  TButtonExBorder = class(TPersistent)
  private
    FButton: TButtonEx;
    FColorNormal: TColor;
    FColorHot: TColor;
    FColorDown: TColor;
    FColorDisabled: TColor;
    FColorFocused: TColor;
    FWidthNormal: TButtonExBorderWidth;
    FWidthHot: TButtonExBorderWidth;
    FWidthDown: TButtonExBorderWidth;
    FWidthDisabled: TButtonExBorderWidth;
    FWidthFocused: TButtonExBorderWidth;
    procedure SetWidthNormal(const Value: TButtonExBorderWidth);
    procedure SetColorNormal(const Value: TColor);
  public
    constructor Create(AButton: TButtonEx);
  published
    property ColorNormal: TColor read FColorNormal write SetColorNormal;
    property ColorHot: TColor read FColorHot write FColorHot;
    property ColorDown: TColor read FColorDown write FColorDown;
    property ColorDisabled: TColor read FColorDisabled write FColorDisabled;
    property ColorFocused: TColor read FColorFocused write FColorFocused;
    property WidthNormal: TButtonExBorderWidth read FWidthNormal write SetWidthNormal;
    property WidthHot: TButtonExBorderWidth read FWidthHot write FWidthHot;
    property WidthDown: TButtonExBorderWidth read FWidthDown write FWidthDown;
    property WidthDisabled: TButtonExBorderWidth read FWidthDisabled write FWidthDisabled;
    property WidthFocused: TButtonExBorderWidth read FWidthFocused write FWidthFocused;
  end;

  TButtonExColors = class(TPersistent)
  private
    FButton: TButtonEx;
    FColorNormalFrom: TColor;
    FColorNormalTo: TColor;
    FColorHotFrom: TColor;
    FColorHotTo: TColor;
    FColorDownFrom: TColor;
    FColorDownTo: TColor;
    FColorDisabledFrom: TColor;
    FColorDisabledTo: TColor;
    FColorFocusedFrom: TColor;
    FColorFocusedTo: TColor;
    procedure SetColorNormalFrom(const Value: TColor);
    procedure SetColorNormalTo(const Value: TColor);
  public
    constructor Create(AButton: TButtonEx);
  published
    property ColorNormalFrom: TColor read FColorNormalFrom write SetColorNormalFrom;
    property ColorNormalTo: TColor read FColorNormalTo write SetColorNormalTo;
    property ColorHotFrom: TColor read FColorHotFrom write FColorHotFrom;
    property ColorHotTo: TColor read FColorHotTo write FColorHotTo;
    property ColorDownFrom: TColor read FColorDownFrom write FColorDownFrom;
    property ColorDownTo: TColor read FColorDownTo write FColorDownTo;
    property ColorDisabledFrom: TColor read FColorDisabledFrom write FColorDisabledFrom;
    property ColorDisabledTo: TColor read FColorDisabledTo write FColorDisabledTo;
    property ColorFocusedFrom: TColor read FColorFocusedFrom write FColorFocusedFrom;
    property ColorFocusedTo: TColor read FColorFocusedTo write FColorFocusedTo;
  end;

  TButtonEx = class(TCustomButton)
  private
    FAlignment: TAlignment;
    FBorder: TButtonExBorder;
    FCanvas: TCanvas;
    FColors: TButtonExColors;
    FDefaultDrawing: Boolean;
    FFontDisabled: TFont;
    FFontDown: TFont;
    FFontFocused: TFont;
    FFontHot: TFont;
    FGradient: Boolean;
    FMargin: integer;
    FShowFocusRect: Boolean;
    FState: TButtonExState;
    FWordwrap: Boolean;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetDefaultDrawing(const Value: Boolean);
    procedure SetGradient(const Value: Boolean);
    procedure SetShowFocusRect(const Value: Boolean);
    procedure SetMargin(const Value: integer);
    procedure SetWordWrap(const Value: Boolean);
  protected
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer;
      WithThemeSpace: Boolean); override;
    class function GetControlClassDefaultSize: TSize; override;
    function GetDrawTextFlags: Cardinal;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure PaintCustomButton;
    procedure PaintThemedButton;
    procedure WMKillFocus(var Message: TLMKillFocus); message LM_KILLFOCUS;
    procedure WMPaint(var Msg: TLMPaint); message LM_PAINT;
    procedure WMSetFocus(var Message: TLMSetFocus); message LM_SETFOCUS;
    procedure WndProc(var Message: TLMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BorderSpacing;
    property Cancel;
    property Caption;
    //property Color;  removed for new property Colors
    property Constraints;
    property Cursor;
    property Default;
    //property DoubleBuffered;   // PaintButton is not called when this is set.
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property Left;
    property ModalResult;
    property ParentBiDiMode;
    //property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Tag;
    property Top;
    property Visible;
    property Width;

    property OnChangeBounds;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDrag;
    property OnUTF8KeyPress;

    property Alignment: TAlignment read FAlignment write SetAlignment default taCenter;
    property Border: TButtonExBorder read FBorder write FBorder;
    property Colors: TButtonExColors read FColors write FColors;
    property DefaultDrawing: Boolean read FDefaultDrawing write SetDefaultDrawing default true;
    property FontDisabled: TFont read FFontDisabled write FFontDisabled;
    property FontDown: TFont read FFontDown write FFontDown;
    property FontFocused: TFont read FFontFocused write FFontFocused;
    property FontHot: TFont read FFontHot write FFontHot;
    property Gradient: Boolean read FGradient write SetGradient default true;
    property Margin: integer read FMargin write SetMargin;
    property ShowFocusRect: Boolean read FShowFocusRect write SetShowFocusRect default true;
    property Wordwrap: Boolean read FWordWrap write SetWordWrap default false;
  end;


implementation

uses
  LCLType, LCLIntf, Themes;


{ TButtonExBorder }

constructor TButtonExBorder.Create(AButton: TButtonEx);
begin
  inherited Create;
  FButton := AButton;
end;

procedure TButtonExBorder.SetColorNormal(const Value: TColor);
begin
  if FColorNormal = Value then exit;
  FColorNormal := Value;
  FButton.Invalidate;
end;

procedure TButtonExBorder.SetWidthNormal(const Value: TButtonExBorderWidth);
begin
  if FWidthNormal = Value then exit;
  FWidthNormal := Value;
  FButton.Invalidate;
end;


{ TButtonExColors }

constructor TButtonExColors.Create(AButton: TButtonEx);
begin
  inherited Create;
  FButton := AButton;
end;

procedure TButtonExColors.SetColorNormalFrom(const Value: TColor);
begin
  if FColorNormalFrom = Value then
    exit;
  FColorNormalFrom := Value;
  FButton.Invalidate;
end;

procedure TButtonExColors.SetColorNormalTo(const Value: TColor);
begin
  if FColorNormalTo = Value then
    exit;
  FColorNormalTo := Value;
  FButton.Invalidate;
end;


{ TButtonEx }

constructor TButtonEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;

  FDefaultDrawing := true;
  FGradient := true;
  FShowFocusRect := true;

  // Background colors
  FColors := TButtonExColors.Create(Self);
  FColors.ColorNormalFrom := $00FCFCFC;
  FColors.ColorNormalTo := $00CFCFCF;
  FColors.ColorHotFrom := $00FCFCFC;
  FColors.ColorHotTo := $00F5D9A7;
  FColors.ColorDownFrom := $00FCFCFC;
  FColors.ColorDownTo := $00DBB368;
  FColors.ColorDisabledFrom := $00F4F4F4;
  FColors.ColorDisabledTo := $00F4F4F4;
  FColors.ColorFocusedFrom := $00FCFCFC;
  FColors.ColorFocusedTo := $00CFCFCF;

  // Fonts
  FFontDisabled := TFont.Create;
  FFontDisabled.Assign(Font);
  FFontDisabled.Color := clGrayText;
  FFontDisabled.OnChange := @FontChanged;
  FFontDown := TFont.Create;
  FFontDown.Assign(Font);
  FFontDown.OnChange := @FontChanged;
  FFontFocused := TFont.Create;
  FFontFocused.Assign(Font);
  FFontFocused.OnChange := @FontChanged;
  FFontHot := TFont.Create;
  FFontHot.Assign(Font);
  FFontHot.OnChange := @FontChanged;

  // Border
  FBorder := TButtonExBorder.Create(Self);
  FBorder.ColorNormal := $00707070;
  FBorder.ColorHot := $00B17F3C;
  FBorder.ColorDown := $008B622C;
  FBorder.ColorDisabled := $00B5B2AD;
  FBorder.ColorFocused := $00B17F3C;
  FBorder.WidthNormal := 1;
  FBorder.WidthHot := 1;
  FBorder.WidthDown := 1;
  FBorder.WidthDisabled := 1;
  FBorder.WidthFocused := 1;

  // Other
  FMargin := 5;
  FAlignment := taCenter;
  FState := bxsNormal;
end;

destructor TButtonEx.Destroy;
begin
  FFontHot.Free;
  FFontDown.Free;
  FFontDisabled.Free;
  FFontFocused.Free;
  FColors.Free;
  FBorder.Free;
  FCanvas.Free;
  inherited;
end;

procedure TButtonEx.CalculatePreferredSize(var PreferredWidth,
  PreferredHeight: Integer; WithThemeSpace: Boolean);
var
  flags: Cardinal;
  txtSize: TSize;
  R: TRect;
  details: TThemedElementDetails;
begin
  FCanvas.Font.Assign(Font);

  R := ClientRect;
  InflateRect(R, -FMargin, 0);
  R.Bottom := MaxInt;   // Max height possible

  flags := GetDrawTextFlags + DT_CALCRECT;

  // rectangle available for text
  details := ThemeServices.GetElementDetails(tbPushButtonNormal);
  if FWordWrap then
  begin
    with ThemeServices.GetTextExtent(FCanvas.Handle, details, Caption, flags, @R) do begin
      txtSize.CX := Right;
      txtSize.CY := Bottom;
    end;
  end else
    with ThemeServices.GetTextExtent(FCanvas.Handle, details, Caption, flags, nil) do begin
      txtSize.CX := Right;
      txtSize.CY := Bottom;
    end;

  PreferredHeight := txtSize.CY + 2 * FMargin;
  PreferredWidth := txtSize.CX + 2 * FMargin;

  if not FWordWrap then
    PreferredHeight := 0;
end;

class function TButtonEx.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 75;
  Result.CY := 25;
end;

function TButtonEx.GetDrawTextFlags: Cardinal;
begin
  Result := DT_VCENTER or DT_NOPREFIX;
  case FAlignment of
    taLeftJustify:
      if IsRightToLeft then Result := Result or DT_RIGHT else Result := Result or DT_LEFT;
    taRightJustify:
      if IsRightToLeft then Result := Result or DT_LEFT else Result := Result or DT_RIGHT;
    taCenter:
      Result := Result or DT_CENTER;
  end;
  if IsRightToLeft then
    result := Result or DT_RTLREADING;
  if FWordWrap then
    Result := Result or DT_WORDBREAK and not DT_SINGLELINE
  else
    Result := Result or DT_SINGLELINE and not DT_WORDBREAK;;
end;

procedure TButtonEx.MouseEnter;
begin
  if FState <> bxsDisabled then
  begin
    FState := bxsHot;
    Invalidate;
  end;
  inherited;
end;

procedure TButtonEx.MouseLeave;
begin
  if (FState <> bxsDisabled) then
  begin
    if Focused then
      FState := bxsFocused
    else
      FState := bxsNormal;
    Invalidate;
  end;
  inherited;
end;

procedure TButtonEx.PaintThemedButton;
var
  btn: TThemedButton;
  details: TThemedElementDetails;
  lRect: TRect;
  flags: Cardinal;
  txtSize: TSize;
  txtPt: TPoint;
begin
  if (csDestroying in ComponentState) or not HandleAllocated then
    exit;

  lRect.Left := 0;
  lRect.Right := Width;
  lRect.Top := 0;
  lRect.Bottom := Height;

  if FState = bxsDisabled then
    btn := tbPushButtonDisabled
  else if FState = bxsDown then
    btn := tbPushButtonPressed
  else if FState = bxsHot then
    btn := tbPushButtonHot
  else
  if Focused or Default then
    btn := tbPushButtonDefaulted
  else
    btn := tbPushButtonNormal;

  // Background
  details := ThemeServices.GetElementDetails(btn);
  InflateRect(lRect, 1, 1);
  ThemeServices.DrawElement(FCanvas.Handle, details, lRect);
  InflateRect(lRect, -1, -1);

  // Text
  FCanvas.Font.Assign(Font);
  flags := GetDrawTextFlags;

  with ThemeServices.GetTextExtent(FCanvas.Handle, details, Caption, flags, @lRect) do begin
    txtSize.CX := Right;
    txtSize.CY := Bottom;
  end;

  case FAlignment of
    taLeftJustify:
      if IsRightToLeft then
        txtPt.X := Width - txtSize.CX - FMargin
      else
        txtPt.X := FMargin;
    taRightJustify:
      if IsRightToLeft then
        txtPt.X := FMargin
      else
        txtPt.X := Width - txtSize.CX - FMargin;
    taCenter:
      txtPt.X := (Width - txtSize.CX) div 2;
  end;
  txtPt.Y := (Height + 1 - txtSize.CY) div 2;
  lRect := Rect(txtPt.X, txtPt.Y, txtPt.X + txtSize.CX, txtPt.Y + txtSize.CY);
  ThemeServices.DrawText(FCanvas, details, Caption, lRect, flags, 0);
end;

procedure TButtonEx.PaintCustomButton;
var
  lCanvas: TCanvas;
  lBitmap: TBitmap;
  lRect, R: TRect;
  lBorderColor: TColor;
  lBorderWidth: integer;
  lColorFrom: TColor;
  lColorTo: TColor;
  lTextFont: TFont;
  lAlignment: TAlignment;
  flags: Cardinal;
  i: integer;
  txtSize: TSize;
  txtPt: TPoint;
begin
  if (csDestroying in ComponentState) or not HandleAllocated then
    exit;

  // Bitmap
  lBitmap := TBitmap.Create;
  lBitmap.Width := Width;
  lBitmap.Height := Height;
  lCanvas := lBitmap.Canvas;

  // State
  lBorderColor := Border.ColorNormal;
  lColorFrom := Colors.ColorNormalFrom;
  lColorTo := Colors.ColorNormalTo;
  lTextFont := Font;
  lBorderWidth := Border.WidthNormal;

  if not (csDesigning in ComponentState) then
  begin
    case FState of
      bxsFocused:
      begin
        lBorderColor := FBorder.ColorFocused;
        lColorFrom := FColors.ColorFocusedFrom;
        lColorTo := FColors.ColorFocusedTo;
        lTextFont := FFontFocused;
        lBorderWidth := FBorder.WidthFocused;
      end;
      bxsHot:
      begin
        lBorderColor := FBorder.ColorHot;
        lColorFrom := FColors.ColorHotFrom;
        lColorTo := FColors.ColorHotTo;
        lTextFont := FFontHot;
        lBorderWidth := FBorder.WidthHot;
      end;
      bxsDown:
      begin
        lBorderColor := FBorder.ColorDown;
        lColorFrom := FColors.ColorDownFrom;
        lColorTo := FColors.ColorDownTo;
        lTextFont := FFontDown;
        lBorderWidth := FBorder.WidthDown;
      end;
      bxsDisabled:
      begin
        lBorderColor := FBorder.ColorDisabled;
        lColorFrom := FColors.ColorDisabledFrom;
        lColorTo := FColors.ColorDisabledTo;
        lTextFont := FFontDisabled;
        lBorderWidth := FBorder.WidthDisabled;
      end;
    end;
  end;

  // Background
  lRect.Left := 0;
  lRect.Right := Width;
  lRect.Top := 0;
  lRect.Bottom := Height;

  if FGradient then
    lCanvas.GradientFill(lRect, lColorFrom, lColorTo, gdVertical)
  else
  begin
    lCanvas.Brush.Style := bsSolid;
    lCanvas.Brush.Color := lColorFrom;
    lCanvas.FillRect(lRect);
  end;

  // Border
  lCanvas.Pen.Width := 1;
  lCanvas.Pen.Color := lBorderColor;
  for i := 1 to lBorderWidth do
  begin
    lCanvas.MoveTo(i - 1, i - 1);
    lCanvas.LineTo(Width - i, i - 1);
    lCanvas.LineTo(Width - i, Height - i);
    lCanvas.LineTo(i - 1, Height - i);
    lCanvas.LineTo(i - 1, i - 1);
  end;

  // Caption
  lCanvas.Pen.Width := 1;
  lCanvas.Brush.Style := bsClear;
  lCanvas.Font.Assign(lTextFont);

  flags := GetDrawTextFlags;
  R := lRect;
  DrawText(FCanvas.Handle, PChar(Caption), Length(Caption), R, flags + DT_CALCRECT);
  txtSize.CX := R.Right - R.Left;
  txtSize.CY := R.Bottom - R.Top;

  lAlignment := FAlignment;
  if IsRightToLeft then begin
    if lAlignment = taLeftJustify then
      lAlignment := taRightJustify
    else if lAlignment = taRightJustify then
      lAlignment := taLeftJustify;
  end;

  case lAlignment of
    taLeftJustify:
      txtPt.X := FMargin;
    taRightJustify:
      txtPt.X := Width - txtSize.CX - FMargin;
    taCenter:
      txtPt.X := (Width - txtSize.CX) div 2;
  end;
  txtPt.Y := (Height - txtSize.CY + 1) div 2;
  R := Rect(txtPt.X, txtPt.Y, txtPt.X + txtSize.CX, txtPt.Y + txtSize.CY);
  DrawText(lCanvas.Handle, PChar(Caption), -1, R, flags);

  // Draw focus rectangle
  if FShowFocusRect and Focused then
  begin
    InflateRect(lRect, -2, -2);
    DrawFocusRect(lCanvas.Handle, lRect);
  end;

  // Draw the button
  FCanvas.Draw(0, 0, lBitmap);

  lBitmap.Free;
end;

procedure TButtonEx.SetAlignment(const Value: TAlignment);
begin
  if FAlignment = Value then
    exit;
  FAlignment := Value;
  Invalidate;
end;

procedure TButtonEx.SetDefaultDrawing(const Value: Boolean);
begin
  if FDefaultDrawing = Value then
    exit;
  FDefaultDrawing := Value;
  Invalidate;
end;

procedure TButtonEx.SetGradient(const Value: Boolean);
begin
  if FGradient = Value then
    exit;
  FGradient := Value;
  Invalidate;
end;

procedure TButtonEx.SetShowFocusRect(const Value: Boolean);
begin
  if FShowFocusRect = Value then
    exit;
  FShowFocusRect := Value;
  if Focused then Invalidate;
end;

procedure TButtonEx.SetMargin(const Value: integer);
begin
  if FMargin = Value then
    exit;
  FMargin := Value;
  Invalidate;
end;

procedure TButtonEx.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap = Value then
    exit;
  FWordWrap := Value;
  Invalidate;
end;

procedure TButtonEx.WMKillFocus(var Message: TLMKillFocus);
begin
  inherited WMKillFocus(Message);
  if (FState = bxsFocused) then
  begin
    FState := bxsNormal;
    Invalidate;
  end;
end;

procedure TButtonEx.WMSetFocus(var Message: TLMSetFocus);
begin
  inherited WMSetFocus(Message);
  if (FState = bxsNormal) then
  begin
    FState := bxsFocused;
    Invalidate;
  end;
end;

procedure TButtonEx.WMPaint(var Msg: TLMPaint);
begin
  inherited;
  if FDefaultDrawing then
    PaintThemedButton
  else
    PaintCustomButton;
end;

procedure TButtonEx.WndProc(var Message: TLMessage);
begin
  if not (csDesigning in ComponentState) then
  begin
    case Message.Msg of
      LM_KEYDOWN:
        begin
          if (Message.WParam = VK_RETURN) or (Message.WParam = VK_SPACE) then
            if FState <> bxsDisabled then
              FState := bxsDown;
              Invalidate;
            end;
      LM_KEYUP:
        begin
          if (Message.WParam = VK_RETURN) or (Message.WParam = VK_SPACE) then
            if FState <> bxsDisabled then
              FState := bxsFocused;
              Invalidate;
            end;
      CM_DIALOGKEY:
        begin
          if (Message.WParam = VK_RETURN) and Default and (not Focused) and (FState <> bxsDisabled) then
            Click;
          if (Message.WParam = VK_ESCAPE) and Cancel and (FState <> bxsDisabled) then
            Click;
        end;
      CM_ENABLEDCHANGED:
        begin
          if not Enabled then
            FState := bxsDisabled
          else
            FState := bxsNormal;
          Invalidate;
        end;
      LM_LBUTTONDOWN:
        begin
          FState := bxsDown;
          Invalidate;
        end;
      LM_LBUTTONUP:
        begin
          if (FState <> bxsNormal) and (FState <> bxsFocused) and (FState <> bxsDisabled) then
          begin
            FState := bxsHot;
            Invalidate;
          end;
      end;
    end;
  end;

  inherited;
end;

end.

