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
{
  TButtonExPictures = class(TPersistent)
  private
    FButton: TButtonEx;
    FAlignment: TLeftRight;
    FTransparent: boolean;
    FPictureNormal: TPicture;
    FPictureHot: TPicture;
    FPictureDown: TPicture;
    FPictureDisabled: TPicture;
    FPictureFocused: TPicture;
    procedure SetPictureNormal(const Value: TPicture);
    procedure SetPictureDisabled(const Value: TPicture);
    procedure SetPictureDown(const Value: TPicture);
    procedure SetPictureFocused(const Value: TPicture);
    procedure SetPictureHot(const Value: TPicture);
    procedure SetAlignment(const Value: TLeftRight);
    procedure SetTransparent(const Value: boolean);
  public
    constructor Create(AButton: TButtonEx);
    destructor Destroy; override;
  published
    property PictureNormal: TPicture read FPictureNormal write SetPictureNormal;
    property PictureHot: TPicture read FPictureHot write SetPictureHot;
    property PictureDown: TPicture read FPictureDown write SetPictureDown;
    property PictureDisabled: TPicture read FPictureDisabled write SetPictureDisabled;
    property PictureFocused: TPicture read FPictureFocused write SetPictureFocused;
    property Alignment: TLeftRight read FAlignment write SetAlignment default taLeftJustify;
    property Transparent: boolean read FTransparent write SetTransparent default False;
  end;
}
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
//    procedure SetSpacing(const Value: integer);
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
    //procedure Click; override;
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
//    property DoubleBuffered;   // PaintButton is not called when this is set.
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
//    property ParentDoubleBuffered;
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


(*
{ TButtonExPictures }

constructor TButtonExPictures.Create(AButton: TButtonEx);
begin
  inherited Create;
  FButton := AButton;
  FAlignment := taLeftJustify;
  FTransparent := False;
  FPictureNormal := TPicture.Create;
  FPictureHot := TPicture.Create;
  FPictureDown := TPicture.Create;
  FPictureDisabled := TPicture.Create;
  FPictureFocused := TPicture.Create;
end;

destructor TButtonExPictures.Destroy;
begin
  FPictureNormal.Free;
  FPictureHot.Free;
  FPictureDown.Free;
  FPictureDisabled.Free;
  FPictureFocused.Free;
  inherited;
end;

procedure TButtonExPictures.SetAlignment(const Value: TLeftRight);
begin
  if FAlignment = Value then
    exit;
  FAlignment := Value;
  FButton.Invalidate;
end;

procedure TButtonExPictures.SetPictureDisabled(const Value: TPicture);
begin
  FPictureDisabled.Assign(Value);
end;

procedure TButtonExPictures.SetPictureDown(const Value: TPicture);
begin
  FPictureDown.Assign(Value);
end;

procedure TButtonExPictures.SetPictureFocused(const Value: TPicture);
begin
  FPictureFocused.Assign(Value);
end;

procedure TButtonExPictures.SetPictureHot(const Value: TPicture);
begin
  FPictureHot.Assign(Value);
end;

procedure TButtonExPictures.SetPictureNormal(const Value: TPicture);
begin
  FPictureNormal.Assign(Value);
  FButton.Invalidate;
end;

procedure TButtonExPictures.SetTransparent(const Value: boolean);
begin
  FTransparent := Value;
  FButton.Invalidate;
end;
*)


{ TButtonEx }

constructor TButtonEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;

  FDefaultDrawing := true;
  FGradient := true;
  FShowFocusRect := true;

  FBorder := TButtonExBorder.Create(Self);
  FColors := TButtonExColors.Create(Self);
  //FPictures := TButtonExPictures.Create(Self);

  // Button
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
//  FSpacing := 5;
  FMargin := 5;
  FAlignment := taCenter;
  FState := bxsNormal;
//  TabStop := True;
//  FModalResult := 0;
//  FCancel := False;
//  FDefault := False;
//  Width := 85;
//  Height := 30;
end;

destructor TButtonEx.Destroy;
begin
  FFontHot.Free;
  FFontDown.Free;
  FFontDisabled.Free;
  FFontFocused.Free;
  //FPictures.Free;
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
  {
  if FWordWrap then //and AutoSize then
  begin
    PreferredWidth := 0 ;
    PreferredHeight := txtSize.CY + 2*FMargin;
  end else
  begin
    PreferredWidth := txtSize.CX + 2 * FMargin;
    PreferredHeight := 0;
  end;
  }
end;

  (*
procedure TButtonEx.Click;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if Form <> nil then
    Form.ModalResult := FModalResult;
  inherited;
end;

procedure TButtonEx.FontChanged(Sender: TObject);
begin
  Invalidate;
end;
  *)

class function TButtonEx.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 75;
  Result.CY := 25;
end;

function TButtonEx.GetDrawTextFlags: Cardinal;
begin
  Result := DT_VCENTER;
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
  //lPicture := FPictures.PictureNormal;

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
        {
        if FPictures.PictureFocused.Graphic <> nil then
          lPicture := FPictures.PictureFocused;
          }
      end;
      bxsHot:
      begin
        lBorderColor := FBorder.ColorHot;
        lColorFrom := FColors.ColorHotFrom;
        lColorTo := FColors.ColorHotTo;
        lTextFont := FFontHot;
        lBorderWidth := FBorder.WidthHot;
        {
        if FPictures.PictureHot.Graphic <> nil then
          lPicture := FPictures.PictureHot;
          }
      end;
      bxsDown:
      begin
        lBorderColor := FBorder.ColorDown;
        lColorFrom := FColors.ColorDownFrom;
        lColorTo := FColors.ColorDownTo;
        lTextFont := FFontDown;
        lBorderWidth := FBorder.WidthDown;
        {
        if FPictures.PictureDown.Graphic <> nil then
          lPicture := FPictures.PictureDown;
          }
      end;
      bxsDisabled:
      begin
        lBorderColor := FBorder.ColorDisabled;
        lColorFrom := FColors.ColorDisabledFrom;
        lColorTo := FColors.ColorDisabledTo;
        lTextFont := FFontDisabled;
        lBorderWidth := FBorder.WidthDisabled;
        {
        if FPictures.PictureDisabled.Graphic <> nil then
          lPicture := FPictures.PictureDisabled;
          }
      end;
    end;
  end;

  // Background
  lRect.Left := 0;
  lRect.Right := Width;
  lRect.Top := 0; //lBorderWidth;
  lRect.Bottom := Height; // - lBorderWidth;

  if FGradient then
    lCanvas.GradientFill(lRect, lColorFrom, lColorTo, gdVertical)
  else
  begin
    lCanvas.Brush.Style := bsSolid;
    lCanvas.Brush.Color := lColorFrom;
    lCanvas.FillRect(lRect);
  end;

  {
  // Image
  lPicLeft := 0;
  if lPicture.Graphic <> nil then
  begin
    lPicture.Graphic.Transparent := FPictures.Transparent;
    case FPictures.Alignment of
      taLeftJustify : lPicLeft := Border.WidthNormal + FMargin;
      taRightJustify: lPicLeft := Width - Border.WidthNormal - FMargin - lPicture.Graphic.Width;
    end;
    lPicTop := (Height - lPicture.Height) div 2;
    lCanvas.Draw(lPicLeft, lPicTop, lPicture.Graphic);
  end;
   }
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

  (*
  // Corner
  lCanvas.Pixels[0, 0] := Color;
  lCanvas.Pixels[lBorderWidth, lBorderWidth] := lBorderColor;
  lCanvas.Pixels[Width - 1, 0] := Color;
  lCanvas.Pixels[Width - 1 - lBorderWidth, lBorderWidth] := lBorderColor;
  lCanvas.Pixels[0, Height - 1] := Color;
  lCanvas.Pixels[lBorderWidth, Height - 1 - lBorderWidth] := lBorderColor;
  lCanvas.Pixels[Width - 1, Height - 1] := Color;
  lCanvas.Pixels[Width - 1 - lBorderWidth, Height - 1 - lBorderWidth] := lBorderColor;
    *)

  // Text
  lCanvas.Pen.Width := 1;
  lCanvas.Brush.Style := bsClear;
  lCanvas.Font.Assign(lTextFont);

  flags := GetDrawTextFlags;
  R := lRect;
  DrawText(FCanvas.Handle, PChar(Caption), Length(Caption), R, flags + DT_CALCRECT);
  txtSize.CX := R.Right - R.Left;
  txtSize.CY := R.Bottom - R.Top;

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
  txtPt.Y := (Height - txtSize.CY + 1) div 2;
  R := Rect(txtPt.X, txtPt.Y, txtPt.X + txtSize.CX, txtPt.Y + txtSize.CY);
                 (*
  case FAlignment of
    taLeftJustify:
    begin
      lRect.Left := lRect.Left + FBorder.WidthNormal + FMargin;
      lAlignment := DT_LEFT;
    end;
    taRightJustify:
    begin
      lRect.Right := lRect.Right - FBorder.WidthNormal - FMargin;
      lAlignment := DT_RIGHT;
    end;
    else
      lAlignment := DT_CENTER;
  end;
  *)
  {
  if (lPicture.Graphic <> nil) and (Alignment <> taCenter) then
  begin
    case FPictures.Alignment of
      taLeftJustify: lRect.Left := lPicLeft + lPicture.Graphic.Width + FSpacing;
      taRightJustify: lRect.Right := lPicLeft - FSpacing;
    end;
  end;
  }
  DrawText(lCanvas.Handle, PChar(Caption), -1, R, flags); //lAlignment or DT_NOPREFIX or DT_VCENTER or DT_SINGLELINE);

  // Draw focus rectangle
  if FShowFocusRect and Focused then
  begin
    InflateRect(lRect, -3, -2);
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

{
procedure TButtonEx.SetSpacing(const Value: integer);
begin
  if FSpacing = Value then
    exit;
  FSpacing := Value;
  Invalidate;
end;
}

procedure TButtonEx.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap = Value then
    exit;
  FWordWrap := Value;
  //if AutoSize then AdjustSize;
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
  {
  if Message.Msg = LM_PAINT then
    PaintButton;

  if Message.Msg = CM_TEXTCHANGED then
    PaintButton;

  if Message.Msg = CM_COLORCHANGED then
  PaintButton;

  if Message.Msg = CM_BORDERCHANGED then
  PaintButton;

  if Message.Msg = LM_ERASEBKGND then
    Exit;
}
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

      {
      LM_CHAR:
      begin
        if (Message.WParam = VK_RETURN) or (Message.WParam = VK_SPACE) and (FState <> bxsDisabled) then
        begin
          Click;
        end;
      end;

      CM_MOUSEENTER:
      begin
        FState := bxsHot;
        PaintButton;
      end;
      CM_MOUSELEAVE:
      begin
        if (FState <> bxsDisabled) then
        begin
          if Focused then
            FState := bxsFocused
          else
            FState := bxsNormal;
          PaintButton;
        end;
      end;
  }
      CM_DIALOGKEY:
      begin
        if (Message.WParam = VK_RETURN) and Default and (not Focused) and (FState <> bxsDisabled) then
          Click;
        if (Message.WParam = VK_ESCAPE) and Cancel and (FState <> bxsDisabled) then
          Click;
      end;

      {
      CM_FOCUSCHANGED:
      begin
        if Focused and (FState = bxsNormal) then
          FState := bxsFocused;
        if (not Focused) and (FState = bxsFocused) then
          FState := bxsNormal;
        PaintButton;
      end;
      }
      CM_ENABLEDCHANGED:
      begin
        if not Enabled then
          FState := bxsDisabled
        else
          FState := bxsNormal;
        Invalidate;
//        PaintButton;
      end;
      LM_LBUTTONDOWN:
      begin
        FState := bxsDown;
        Invalidate;
//        PaintButton;
      end;
      LM_LBUTTONUP:
      begin
        if (FState <> bxsNormal) and (FState <> bxsFocused) and (FState <> bxsDisabled) then
        begin
          FState := bxsHot;
          Invalidate;
          //PaintButton;
        end;
      end;
      {
      LM_LBUTTONDBLCLK:
      begin
        FState := bxsDown;
        PaintButton;
        Click;
      end;
      }
    end;
  end;

  inherited;
end;

end.

