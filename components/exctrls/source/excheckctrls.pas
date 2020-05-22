{ Extended checked controls (radiobutton, checkbox, radiogroup, checkgroup)

  Copyright (C) 2020 Lazarus team

  This library is free software; you can redistribute it and/or modify it
  under the same terms as the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in the Lazarus distribution,
  for details about the license.

}

unit ExCheckCtrls;

{$mode objfpc}{$H+}

interface

uses
  LCLType, LCLIntf, LCLProc, LMessages,
  Graphics, Classes, SysUtils, Types, Themes, Controls,
  StdCtrls, ExtCtrls, ImgList;

type
  TGetImageIndexEvent = procedure (Sender: TObject; AHover, APressed, AEnabled: Boolean;
    AState: TCheckboxState; var AImgIndex: Integer) of object;

  { TCustomCheckControlEx }

  TCustomCheckControlEx = class(TCustomControl)
  private
    type
      TCheckControlKind = (cckCheckbox, cckRadioButton);
  private
    FAlignment: TLeftRight;
    FAllowGrayed: Boolean;
    FThemedBtnSize: TSize;
    FBtnLayout: TTextLayout;
    FDistance: Integer;        // between button and caption
    FDrawFocusRect: Boolean;
    FFocusBorder: Integer;
    FGroupLock: Integer;
    FHover: Boolean;
    FImages: TCustomImageList;
    FImagesWidth: Integer;
    FKind: TCheckControlKind;
    FPressed: Boolean;
    FReadOnly: Boolean;
    FState: TCheckBoxState;
    FTextLayout: TTextLayout;
    FThemedCaption: Boolean;
//    FTransparent: Boolean;
    FWordWrap: Boolean;
    FOnChange: TNotifyEvent;
    FOnGetImageIndex: TGetImageIndexEvent;
    function GetCaption: TCaption;
    function GetChecked: Boolean;
    procedure SetAlignment(const AValue: TLeftRight);
    procedure SetBtnLayout(const AValue: TTextLayout);
    procedure SetCaption(const AValue: TCaption);
    procedure SetChecked(const AValue: Boolean);
    procedure SetDrawFocusRect(const AValue: Boolean);
    procedure SetImages(const AValue: TCustomImageList);
    procedure SetImagesWidth(const AValue: Integer);
    procedure SetState(const AValue: TCheckBoxState);
    procedure SetTextLayout(const AValue: TTextLayout);
    procedure SetThemedCaption(const AValue: Boolean);
    //procedure SetTransparent(const AValue: Boolean);
    procedure SetWordWrap(const AValue: Boolean);

  protected
    procedure AfterSetState; virtual;
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer;
      {%H-}WithThemeSpace: Boolean); override;
    procedure CMBiDiModeChanged(var {%H-}Message: TLMessage); message CM_BIDIMODECHANGED;
    procedure CreateHandle; override;
    procedure DoAutoAdjustLayout(const AMode: TLayoutAdjustmentPolicy;
      const AXProportion, AYProportion: Double); override;
    procedure DoClick;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DrawBackground;
    procedure DrawButton(AHovered, APressed, AEnabled: Boolean; AState: TCheckboxState);
    procedure DrawButtonText(AHovered, APressed, AEnabled: Boolean;
      AState: TCheckboxState);
    function GetBtnSize: TSize; virtual;
    function GetDrawTextFlags: Cardinal;
    function GetTextExtent(const ACaption: String): TSize;
    function GetThemedButtonDetails(AHovered, APressed, AEnabled: Boolean;
      AState: TCheckboxState): TThemedElementDetails; virtual; abstract;
//    procedure InitBtnSize(Scaled: Boolean);
    procedure LockGroup;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure TextChanged; override;
    procedure UnlockGroup;
    procedure WMSize(var Message: TLMSize); message LM_SIZE;

    property Alignment: TLeftRight read FAlignment write SetAlignment default taRightJustify;
    property AllowGrayed: Boolean read FAllowGrayed write FAllowGrayed default False;
    property ButtonLayout: TTextLayout read FBtnLayout write SetBtnLayout default tlCenter;
    property Caption: TCaption read GetCaption write SetCaption;
    property Checked: Boolean read GetChecked write SetChecked default false;
    property DrawFocusRect: Boolean read FDrawFocusRect write SetDrawFocusRect default true;
    property Images: TCustomImageList read FImages write SetImages;
    property ImagesWidth: Integer read FImagesWidth write SetImagesWidth default 0;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default false;
    property State: TCheckBoxState read FState write SetState default cbUnchecked;
    property TextLayout: TTextLayout read FTextLayout write SetTextLayout default tlCenter;
    property ThemedCaption: Boolean read FThemedCaption write SetThemedCaption default true;
    //property Transparent: Boolean read FTransparent write SetTransparent default true;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default false;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnGetImageIndex: TGetImageIndexEvent read FOnGetImageIndex write FOnGetImageIndex;

  public
    constructor Create(AOwner: TComponent); override;

  end;

  { TCustomCheckboxEx }

  TCustomCheckboxEx = class(TCustomCheckControlEx)
  private
  protected
    function GetThemedButtonDetails(AHovered, APressed, AEnabled: Boolean;
      AState: TCheckboxState): TThemedElementDetails; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;


{ TCheckBoxEx }

  TCheckBoxEx = class(TCustomCheckBoxEx)
  published
    //property Action;
    property Align;
    property Alignment;
    property AllowGrayed;
    property Anchors;
    property AutoSize default true;
    property BiDiMode;
    property BorderSpacing;
    property ButtonLayout;
    property Caption;
    property Checked;
    property Color;
    property Constraints;
    property Cursor;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DrawFocusRect;
    property Enabled;
    property Font;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property Images;
    property ImagesWidth;
    property Left;
    property Name;
    property ParentBiDiMode;
    property ParentColor;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property ReadOnly;
    property ShowHint;
    property State;
    property TabOrder;
    property TabStop;
    property Tag;
    property TextLayout;
    property ThemedCaption;
    property Top;
    //property Transparent;
    property Visible;
    property Width;
    property WordWrap;
    property OnChange;
    property OnChangeBounds;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEditingDone;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDrag;
    property OnUTF8KeyPress;
  end;

  { TCustomRadioButtonEx }

  TCustomRadioButtonEx = class(TCustomCheckControlEx)
  protected
    procedure AfterSetState; override;
    function GetThemedButtonDetails(AHovered, APressed, AEnabled: Boolean;
      AState: TCheckboxState): TThemedElementDetails; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
  end;

  { TRadioButtonEx }

  TRadioButtonEx = class(TCustomRadioButtonEx)
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize default true;
    property BiDiMode;
    property BorderSpacing;
    property ButtonLayout;
    property Caption;
    property Checked;
    property Color;
    property Constraints;
    property Cursor;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DrawFocusRect;
    property Enabled;
    property Font;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property Images;
    property ImagesWidth;
    property Left;
    property Name;
    property ParentBiDiMode;
    property ParentColor;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property State;
    property TabOrder;
    property TabStop;
    property Tag;
    property TextLayout;
    property ThemedCaption;
    //property Transparent;
    property Visible;
    property WordWrap;
    property Width;

    property OnChange;
    property OnChangeBounds;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDrag;
    property OnGetImageIndex;
  end;


{ TCustomCheckControlGroupEx }

  TCustomCheckControlGroupEx = class(TCustomGroupBox)
  private
    FAutoFill: Boolean;
    FButtonList: TFPList;
    FColumnLayout: TColumnLayout;
    FColumns: integer;
    FImages: TCustomImageList;
    FImagesWidth: Integer;
    FItems: TStrings;
    FIgnoreClicks: boolean;
    FReadOnly: Boolean;
    FUpdatingItems: Boolean;
    FOnClick: TNotifyEvent;
    FOnGetImageIndex: TGetImageIndexEvent;
    FOnSelectionChanged: TNotifyEvent;
    procedure ItemEnter(Sender: TObject);
    procedure ItemExit(Sender: TObject);
    procedure ItemKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure ItemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure ItemKeyPress(Sender: TObject; var Key: Char); virtual;
    procedure ItemUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char); virtual;
    procedure ItemResize(Sender: TObject);
    procedure SetAutoFill(const AValue: Boolean);
    procedure SetColumnLayout(const AValue: TColumnLayout);
    procedure SetColumns(const AValue: integer);
    procedure SetImages(const AValue: TCustomImageList);
    procedure SetImagesWidth(const AValue: Integer);
    procedure SetItems(const AValue: TStrings);
    procedure SetOnGetImageIndex(const AValue: TGetImageIndexEvent);
    procedure SetReadOnly(const AValue: Boolean);
  protected
    procedure UpdateAll;
    procedure UpdateControlsPerLine;
    procedure UpdateInternalObjectList;
    procedure UpdateItems; virtual; abstract;
    procedure UpdateTabStops;
    property AutoFill: Boolean read FAutoFill write SetAutoFill default true;
    property ColumnLayout: TColumnLayout read FColumnLayout write SetColumnLayout default clHorizontalThenVertical;
    property Columns: Integer read FColumns write SetColumns default 1;
    property Images: TCustomImageList read FImages write SetImages;
    property ImagesWidth: Integer read FImagesWidth write SetImagesWidth default 0;
    property Items: TStrings read FItems write SetItems;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default false;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnGetImageIndex: TGetImageIndexEvent read FOnGetImageIndex write SetOnGetImageIndex;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CanModify: boolean; virtual;
    procedure FlipChildren(AllLevels: Boolean); override;
    function Rows: integer;
  end;

  { TCustomRadioGroupEx }
  TCustomRadioGroupEx = class(TCustomCheckControlGroupEx)
  private
    FCreatingWnd: Boolean;
    FHiddenButton: TRadioButtonEx;
    FItemIndex: integer;
    FLastClickedItemIndex: Integer;
    FReading: Boolean;
    procedure Changed(Sender: TObject);
    procedure Clicked(Sender: TObject);
    function GetButtonCount: Integer;
    function GetButtons(AIndex: Integer): TRadioButtonEx;
    procedure SetItemIndex(const AValue: Integer);
  protected
    procedure CheckItemIndexChanged; virtual;
    procedure InitializeWnd; override;
    procedure ItemKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure ReadState(AReader: TReader); override;
    procedure UpdateItems; override;
    procedure UpdateRadioButtonStates; virtual;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
  public
    property ButtonCount: Integer read GetButtonCount;
    property Buttons[AIndex: Integer]: TRadioButtonEx read GetButtons;
  published
    constructor Create(AOwner: TComponent); override;
  end;

  { TRadioGroupEx }
  TRadioGroupEx = class(TCustomRadioGroupEx)
  published
    property Align;
    property Anchors;
    property AutoFill;
    property AutoSize;
    property BiDiMode;
    property BorderSpacing;
    property Caption;
    property ChildSizing;
    property Color;
    property ColumnLayout;
    property Columns;
    property Constraints;
    property Cursor;
    property DoubleBuffered;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property Images;
    property ImagesWidth;
    property ItemIndex;
    property Items;
    property Left;
    property Name;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Tag;
    property Top;
    property Visible;
    property Width;
    property OnChangeBounds;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnSelectionChanged;
    property OnStartDrag;
    property OnUTF8KeyPress;
  end;

  TCustomCheckGroupEx = class(TCustomCheckControlGroupEx)
  private
    FOnItemClick: TCheckGroupClicked;
    procedure Clicked(Sender: TObject);
    procedure DoClick(AIndex: integer);
    function GetButtonCount: Integer;
    function GetButtons(AIndex: Integer): TCheckBoxEx;
    function GetChecked(AIndex: integer): boolean;
    function GetCheckEnabled(AIndex: integer): boolean;
    procedure RaiseIndexOutOfBounds(AIndex: integer);
    procedure SetChecked(AIndex: integer; const AValue: boolean);
    procedure SetCheckEnabled(AIndex: integer; const AValue: boolean);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure Loaded; override;
    procedure ReadData(Stream: TStream);
    procedure UpdateItems; override;
    procedure WriteData(Stream: TStream);
//    procedure DoOnResize; override;
  public
    constructor Create(AOwner: TComponent); override;
    property ButtonCount: Integer read GetButtonCount;
    property Buttons[AIndex: Integer]: TCheckBoxEx read GetButtons;
  public
    property Checked[Index: integer]: boolean read GetChecked write SetChecked;
    property CheckEnabled[Index: integer]: boolean read GetCheckEnabled write SetCheckEnabled;
    property OnItemClick: TCheckGroupClicked read FOnItemClick write FOnItemClick;
  end;

  { TCheckGroupEx }

  TCheckGroupEx = class(TCustomCheckGroupEx)
  published
    property Align;
    property Anchors;
    property AutoFill;
    property AutoSize;
    property BiDiMode;
    property BorderSpacing;
    property Caption;
    property ChildSizing;
    property ClientHeight;
    property ClientWidth;
    property Color;
    property ColumnLayout;
    property Columns;
    property Constraints;
    property DoubleBuffered;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Images;
    property ImagesWidth;
    property Items;
    property ParentBiDiMode;
    property ParentFont;
    property ParentColor;
    property ParentDoubleBuffered;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;

    property OnChangeBounds;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnItemClick;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDrag;
    property OnUTF8KeyPress;
  end;

implementation

uses
  Math, LCLStrConsts, LResources;

const
  cIndent = 5;

  FIRST_RADIOBUTTON_DETAIL = tbRadioButtonUncheckedNormal;
  FIRST_CHECKBOX_DETAIL = tbCheckBoxUncheckedNormal;
  HOT_OFFSET = 1;
  PRESSED_OFFSET = 2;
  DISABLED_OFFSET = 3;
  CHECKED_OFFSET = 4;
  MIXED_OFFSET = 8;

procedure DrawParentImage(Control: TControl; Dest: TCanvas);
var
  SaveIndex: integer;
  DC: HDC;
  Position: TPoint;
begin
  with Control do
  begin
    if Parent = nil then Exit;
    DC := Dest.Handle;
    SaveIndex := SaveDC(DC);
    GetViewportOrgEx(DC, @Position);
    SetViewportOrgEx(DC, Position.X - Left, Position.Y - Top, nil);
    IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);
    Parent.Perform(LM_ERASEBKGND, DC, 0);
    Parent.Perform(LM_PAINT, DC, 0);
    RestoreDC(DC, SaveIndex);
  end;
end;

function ProcessLineBreaks(const AString: string; ToC: Boolean): String;
var
  idx: Integer;

  procedure AddChar(ch: Char);
  begin
    Result[idx] := ch;
    inc(idx);
    if idx > Length(Result) then
      SetLength(Result, Length(Result) + 100);
  end;

var
  P, PEnd: PChar;
begin
  if AString = '' then
  begin
    Result := '';
    exit;
  end;

  SetLength(Result, Length(AString));
  idx := 1;
  P := @AString[1];
  PEnd := P + Length(AString);

  if ToC then
    // Replace line breaks by '\n'
    while P < PEnd do begin
      if (P^ = #13) then begin
        AddChar('\');
        AddChar('n');
        inc(P);
        if P^ <> #10 then dec(P);
      end else
      if P^ = #10 then
      begin
        AddChar('\');
        AddChar('n');
      end else
      if P^ = '\' then
      begin
        AddChar('\');
        AddChar('\');
      end else
        AddChar(P^);
      inc(P);
    end
  else
    // Replace '\n' by LineEnding
    while (P < PEnd) do
    begin
      if (P^ = '\') and (P < PEnd-1) then
      begin
        inc(P);
        if (P^ = 'n') or (P^ = 'N') then
          AddChar(#10)
        else
          AddChar(P^);
      end else
        AddChar(P^);
      inc(P);
    end;
  SetLength(Result, idx-1);
end;

{ TCheckboxControlEx }

constructor TCustomCheckControlEx.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle  + [csParentBackground, csReplicatable] - [csOpaque]
    - csMultiClicks - [csClickEvents, csNoStdEvents];  { inherited Click not used }

  FAlignment := taRightJustify;
  FBtnLayout := tlCenter;
  FDrawFocusRect := true;
  FKind := cckCheckbox;
  FDistance := cIndent;
  FFocusBorder := FDistance div 2;
  FTextLayout := tlCenter;
  FThemedCaption := true;
//  FTransparent := true;

  AutoSize := true;
  TabStop := true;
end;

// Is called after the State has changed in SetState. Will be overridden by
// TCustomRadioButtonEx to uncheck all other iteme.s
procedure TCustomCheckControlEx.AfterSetState;
begin
end;

procedure TCustomCheckControlEx.CalculatePreferredSize(var PreferredWidth,
  PreferredHeight: Integer; WithThemeSpace: Boolean);
var
  flags: Cardinal;
  textSize: TSize;
  R: TRect;
  captn: String;
  details: TThemedElementDetails;
  btnSize: TSize;
begin
  captn := inherited Caption;
  if (captn = '') then
  begin
    btnSize := GetBtnSize;
    PreferredWidth := btnSize.CX;
    PreferredHeight := btnSize.CY;
    exit;
  end;

  Canvas.Font.Assign(Font);

  R := ClientRect;
  btnSize := GetBtnSize;
  dec(R.Right, btnSize.CX + FDistance);
  R.Bottom := MaxInt;   // Max height possible

  flags := GetDrawTextFlags + DT_CALCRECT;

  // rectangle available for text
  if FThemedCaption then
  begin
    details := GetThemedButtonDetails(false, false, true, cbChecked);
    if FWordWrap then
    begin
      with ThemeServices.GetTextExtent(Canvas.Handle, details, captn, flags, @R) do begin
        textSize.CX := Right;
        textSize.CY := Bottom;
      end;
    end else
      with ThemeServices.GetTextExtent(Canvas.Handle, details, captn, flags, nil) do begin
        textSize.CX := Right;
        textSize.CY := Bottom;
      end;
  end else
  begin
    DrawText(Canvas.Handle, PChar(captn), Length(captn), R, flags);
    textSize.CX := R.Right - R.Left;
    textSize.CY := R.Bottom - R.Top;
  end;

  PreferredWidth := btnSize.CX + FDistance + textSize.CX + FFocusBorder;
  PreferredHeight := Max(btnSize.CY, textSize.CY + 2*FFocusBorder);
end;

procedure TCustomCheckControlEx.CMBiDiModeChanged(var Message: TLMessage);
begin
  Invalidate;
end;

procedure TCustomCheckControlEx.CreateHandle;
var
  w, h: Integer;
begin
  inherited;
  if (Width = 0) or (Height = 0) then begin
    CalculatePreferredSize(w{%H-}, h{%H-}, false);
    if Width <> 0 then w := Width;
    if Height <> 0 then h := Height;
    SetBounds(Left, Top, w, h);
  end;
end;

procedure TCustomCheckControlEx.DoAutoAdjustLayout(
  const AMode: TLayoutAdjustmentPolicy;
  const AXProportion, AYProportion: Double);
begin
  inherited;
  if AMode in [lapAutoAdjustWithoutHorizontalScrolling, lapAutoAdjustForDPI] then
  begin
    FDistance := Round(cIndent * AXProportion);
    FFocusBorder := FDistance div 2;
  end;
end;

procedure TCustomCheckControlEx.DoClick;
begin
  if FReadOnly then
    exit;

  if AllowGrayed then begin
    case FState of
      cbUnchecked: SetState(cbGrayed);
      cbGrayed: SetState(cbChecked);
      cbChecked: SetState(cbUnchecked);
    end;
  end else
    Checked := not Checked;
end;

procedure TCustomCheckControlEx.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomCheckControlEx.DoExit;
begin
  inherited DoExit;
  Invalidate;
end;

procedure TCustomCheckControlEx.DrawBackground;
var
  R: TRect;
begin
  R := Rect(0, 0, Width, Height);
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(R);
end;

procedure TCustomCheckControlEx.DrawButton(AHovered, APressed, AEnabled: Boolean; AState: TCheckboxState);
var
  btnRect: TRect;
  btnPoint: TPoint = (X:0; Y:0);
  details: TThemedElementDetails;
  imgIndex: Integer;
  imgRes: TScaledImageListResolution;
  btnSize: TSize;
begin
  // Checkbox/Radiobutton size and position
  btnSize := GetBtnSize;
  case FAlignment of
    taLeftJustify:
      if not IsRightToLeft then btnPoint.X := ClientWidth - btnSize.CX;
    taRightJustify:
      if IsRightToLeft then btnPoint.X := ClientWidth - btnSize.CX;
  end;
  case FBtnLayout of
    tlTop: btnPoint.Y := FFocusBorder;
    tlCenter: btnPoint.Y := (ClientHeight - btnSize.CY) div 2;
    tlBottom: btnPoint.Y := ClientHeight - btnSize.CY - FFocusBorder;
  end;
  btnRect := Rect(0, 0, btnSize.CX, btnSize.CY);
  OffsetRect(btnRect, btnPoint.X, btnPoint.Y);

  imgIndex := -1;
  if (FImages <> nil) and Assigned(FOnGetImageIndex) then
    FOnGetImageIndex(Self, AHovered, APressed, AEnabled, AState, imgIndex);

  if imgIndex > -1 then
  begin
    ImgRes := FImages.ResolutionForPPI[FImagesWidth, Font.PixelsPerInch, GetCanvasScaleFactor];
    ImgRes.Draw(Canvas, btnRect.Left, btnRect.Top, imgIndex, AEnabled);
  end else
  begin
    // Drawing style of button
    details := GetThemedButtonDetails(AHovered, APressed, AEnabled, AState);
    // Draw button
    ThemeServices.DrawElement(Canvas.Handle, details, btnRect);
  end;
end;

procedure TCustomCheckControlEx.DrawButtonText(AHovered, APressed, AEnabled: Boolean;
  AState: TCheckboxState);
var
  R: TRect;
//  textStyle: TTextStyle;
  delta: Integer;
  details: TThemedElementDetails;
  flags: Cardinal;
  textSize: TSize;
  captn: TCaption;
  btnSize: TSize;
begin
  captn := inherited Caption;   // internal string with line breaks

  if captn = '' then
    exit;

  // Determine text drawing parameters
  flags := GetDrawTextFlags;

  btnSize := GetBtnSize;
  delta := btnSize.CX + FDistance;
  R := ClientRect;
  dec(R.Right, delta);
  Canvas.Font.Assign(Font);
  if FThemedCaption then
  begin
    R.Bottom := MaxInt;   // max height for word-wrap
    details := GetThemedButtonDetails(AHovered, APressed, AEnabled, AState);
    with ThemeServices.GetTextExtent(Canvas.Handle, details, captn, flags, @R) do begin
      textSize.CX := Right;
      textSize.CY := Bottom;
    end;
  end else
  begin
    if not AEnabled then Canvas.Font.Color := clGrayText;
    DrawText(Canvas.Handle, PChar(captn), Length(captn), R, flags + DT_CALCRECT);
    textSize.CX := R.Right - R.Left;
    textSize.CY := R.Bottom - R.Top;
  end;

  R := ClientRect;

  case FTextLayout of
    tlTop:
      R.Top := 0;
    tlCenter:
      R.Top := (R.Top + R.Bottom - textSize.CY) div 2;
    tlBottom:
      R.Top := R.Bottom - textSize.CY;
  end;
  R.Bottom := R.Top + textSize.CY;

  if (FAlignment = taRightJustify) and IsRightToLeft then
  begin
    dec(R.Right, delta);
    R.Left := R.Right - textSize.CX;
  end else
  begin
    inc(R.Left, delta);
    R.Right := R.Left + textSize.CX;
  end;

  // Draw text
  if FThemedCaption then
  begin
    ThemeServices.DrawText(Canvas, details, captn, R, flags, 0);
  end else
  begin
    Canvas.Brush.Style := bsClear;
    DrawText(Canvas.Handle, PChar(captn), Length(captn), R, flags);
  end;

  // Draw focus rect
  if Focused and FDrawFocusRect then begin
    InflateRect(R, FFocusBorder, 0);
    if R.Left + R.Width > ClientWidth then R.Width := ClientWidth - R.Left;
    if R.Left < 0 then R.Left := 0;
    //LCLIntf.SetBkColor(Canvas.Handle, ColorToRGB(clBtnFace));
    Canvas.Font.Color := clBlack;
    LCLIntf.DrawFocusRect(Canvas.Handle, R);
  end;
end;

function TCustomCheckControlEx.GetBtnSize: TSize;
var
  ImgRes: TScaledImageListResolution;
begin
  if (FImages <> nil) then begin
    ImgRes := FImages.ResolutionForPPI[FImagesWidth, Font.PixelsPerInch, GetCanvasScaleFactor];
    Result.CX := ImgRes.Width;
    Result.CY := ImgRes.Height;
  end else
  begin
    with ThemeServices do
      if FKind = cckCheckbox then
        Result := GetDetailSize(GetElementDetails(tbCheckBoxCheckedNormal))
      else
      if FKind = cckRadioButton then
        Result := GetDetailSize(GetElementDetails(tbRadioButtonCheckedNormal));
      //Result.CX := Scale96ToFont(Result.CX);
      //Result.CY := Scale96ToFont(Result.CY);
  end;
end;

// Replaces linebreaks in the inherited Caption by '\n'  (and '\' by '\\') so
// that line breaks can be entered at designtime.
function TCustomCheckControlEx.GetCaption: TCaption;
const
  TO_C = true;
begin
  Result := ProcessLineBreaks(inherited Caption, TO_C);
end;

function TCustomCheckControlEx.GetChecked: Boolean;
begin
  Result := (FState = cbChecked);
end;

// Determine text drawing parameters for the DrawText command
function TCustomCheckControlEx.GetDrawTextFlags: Cardinal;
begin
  Result := 0;
  case FTextLayout of
    tlTop: inc(Result, DT_TOP);
    tlCenter: inc(Result, DT_VCENTER);
    tlBottom: inc(Result, DT_BOTTOM);
  end;

  if (FAlignment = taRightJustify) and IsRightToLeft then
    inc(Result, DT_RIGHT)
  else
    inc(Result, DT_LEFT);

  if IsRightToLeft then inc(Result, DT_RTLREADING);
  if FWordWrap then inc(Result, DT_WORDBREAK);
end;

function TCustomCheckControlEx.GetTextExtent(const ACaption: String): TSize;
var
  L: TStrings;
  s: String;
begin
  Result := Size(0, 0);
  L := TStringList.Create;
  try
    L.Text := ACaption;
    for s in L do
    begin
      Result.CY := Result.CY + Canvas.TextHeight(s);
      Result.CX := Max(Result.CX, Canvas.TextWidth(s));
    end;
  finally
    L.Free;
  end;
end;
              (*
procedure TCustomCheckControlEx.InitBtnSize(Scaled: Boolean);
var
  ImgRes: TScaledImageListResolution;
begin
  if (FImages <> nil) then begin
    if Scaled then begin
      ImgRes := FImages.ResolutionForPPI[FImagesWidth, Font.PixelsPerInch, GetCanvasScaleFactor];
      FBtnSize.CX := ImgRes.Width;
      FBtnSize.CY := ImgRes.Height;
    end else
    begin
      FBtnSize.CX := FImages.Width;
      FBtnSize.CY := FImages.Height;
    end;
  end else
  begin
    with ThemeServices do
      if FKind = cckCheckbox then
        FBtnSize := GetDetailSize(GetElementDetails(tbCheckBoxCheckedNormal))
      else if FKind = cckRadioButton then
        FBtnSize := GetDetailSize(GetElementDetails(tbRadioButtonCheckedNormal));
    if Scaled then
    begin
      FBtnSize.CX := Scale96ToFont(FBtnSize.CX);
      FBtnSize.CY := Scale96ToFont(FBtnSize.CY);
    end;
  end;
end;
*)

procedure TCustomCheckControlEx.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key in [VK_RETURN, VK_SPACE]) and not (ssCtrl in Shift) and (not FReadOnly) then
  begin
    FPressed := True;
    Invalidate;
  end;
end;

procedure TCustomCheckControlEx.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if (Key in [VK_RETURN, VK_SPACE]) and not (ssCtrl in Shift) then
  begin
    FPressed :=  False;
    DoClick;
  end;
end;

procedure TCustomCheckControlEx.LockGroup;
begin
  inc(FGroupLock);
end;

procedure TCustomCheckControlEx.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and FHover and not FReadOnly then
  begin
    FPressed := True;
    Invalidate;
  end;
  SetFocus;
end;

procedure TCustomCheckControlEx.MouseEnter;
begin
  FHover := true;
  Invalidate;
  inherited;
end;

procedure TCustomCheckControlEx.MouseLeave;
begin
  FHover := false;
  Invalidate;
  inherited;
end;

procedure TCustomCheckControlEx.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then begin
    if PtInRect(ClientRect, Point(X, Y)) then DoClick;
    FPressed := False;
  end;
end;

procedure TCustomCheckControlEx.Paint;
begin
  {
  if FTransparent then
    DrawParentImage(Self, Self.Canvas)
  else
    DrawBackground;
  }
  DrawButton(FHover, FPressed, IsEnabled, FState);
  DrawButtonText(FHover, FPressed, IsEnabled, FState);
end;

procedure TCustomCheckControlEx.SetAlignment(const AValue: TLeftRight);
begin
  if AValue = FAlignment then exit;
  FAlignment := AValue;
  Invalidate;
end;

procedure TCustomCheckControlEx.SetBtnLayout(const AValue: TTextLayout);
begin
  if AValue = FBtnLayout then exit;
  FBtnLayout := AValue;
  Invalidate;
end;

procedure TCustomCheckControlEx.SetCaption(const AValue: TCaption);
const
  FROM_C = false;
begin
  if AValue = GetCaption then exit;
  inherited Caption := ProcessLineBreaks(AValue, FROM_C);
end;

procedure TCustomCheckControlEx.SetChecked(const AValue: Boolean);
begin
  if AValue then
    State := cbChecked
  else
    State := cbUnChecked;
end;

procedure TCustomCheckControlEx.SetDrawFocusRect(const AValue: Boolean);
begin
  if AValue = FDrawFocusRect then exit;
  FDrawFocusRect := AValue;
  Invalidate;
end;

procedure TCustomCheckControlEx.SetImages(const AValue: TCustomImageList);
begin
  if AValue = FImages then exit;
  FImages := AValue;
//  InitBtnSize(true);
  InvalidatePreferredSize;
  AdjustSize;
end;

procedure TCustomCheckControlEx.SetImagesWidth(const AValue: Integer);
begin
  if AValue = FImagesWidth then exit;
  FImagesWidth := AValue;
//  InitBtnSize(true);
  InvalidatePreferredSize;
  AdjustSize;
end;

procedure TCustomCheckControlEx.SetTextLayout(const AValue: TTextLayout);
begin
  if AValue = FTextLayout then exit;
  FTextLayout := AValue;
  Invalidate;
end;

procedure TCustomCheckControlEx.SetThemedCaption(const AValue: Boolean);
begin
  if AValue = FThemedCaption then exit;
  FThemedCaption := AValue;
  Invalidate;
end;

procedure TCustomCheckControlEx.SetState(const AValue: TCheckboxState);
begin
  if (FState = AValue) then exit;
  FState := AValue;
  if [csLoading, csDestroying, csDesigning] * ComponentState = [] then begin
    if Assigned(OnEditingDone) then OnEditingDone(self);
    if Assigned(OnChange) then OnChange(self);
    {
    // Execute only when Action.Checked is changed
    if not CheckFromAction then begin
      if Assigned(OnClick) then
        if not (Assigned(Action) and
          CompareMethods(TMethod(Action.OnExecute), TMethod(OnClick)))
          then OnClick(self);
      if (Action is TCustomAction) and
        (TCustomAction(Action).Checked <> (AValue = cbChecked))
        then ActionLink.Execute(self);
    end;
    }
    AfterSetState;
  end;
  Invalidate;
end;
{
procedure TCustomCheckControlEx.SetTransparent(const AValue: Boolean);
begin
  if AValue = FTransparent then exit;
  FTransparent := AValue;
  Invalidate;
end;
}

procedure TCustomCheckControlEx.SetWordWrap(const AValue: Boolean);
begin
  if AValue = FWordWrap then exit;
  FWordWrap := AValue;
  Invalidate;
end;

procedure TCustomCheckControlEx.TextChanged;
begin
  inherited TextChanged;
  Invalidate;
end;

procedure TCustomCheckControlEx.UnlockGroup;
begin
  dec(FGroupLock);
end;

procedure TCustomCheckControlEx.WMSize(var Message: TLMSize);
begin
  inherited WMSize(Message);
  Invalidate;
end;


{ TCustomRadioButtonEx }

constructor TCustomRadioButtonEx.Create(AOwner: TComponent);
begin
  inherited;
  FKind := cckRadioButton;
//  InitBtnSize(false);
end;

{ Is called by SetState and is supposed to uncheck all other radiobuttons in the
  same group, i.e. having the same parent. Provides a locking mechanism because
  uncheding another radiobutton would trigger AfterSetState again. }
procedure TCustomRadioButtonEx.AfterSetState;
var
  i: Integer;
  C: TControl;
begin
  if (FGroupLock > 0) or (Parent = nil) then
    exit;
  for i := 0 to Parent.ControlCount-1 do
  begin
    C := Parent.Controls[i];
    if (C is TCustomRadioButtonEx) and (C <> self) then
      with TCustomRadioButtonEx(C) do
      begin
        LockGroup;
        try
          State := cbUnChecked;
        finally
          UnlockGroup;
        end;
      end;
  end;
//  Parent.Invalidate;
end;

function TCustomRadioButtonEx.GetThemedButtonDetails(
  AHovered, APressed, AEnabled: Boolean; AState: TCheckboxState): TThemedElementDetails;
var
  offset: Integer = 0;
  tb: TThemedButton;
begin
  offset := ord(FIRST_RADIOBUTTON_DETAIL);
  if APressed then
    inc(offset, PRESSED_OFFSET)
  else if AHovered then
    inc(offset, HOT_OFFSET);
  if not AEnabled then inc(offset, DISABLED_OFFSET);
  if AState = cbChecked then inc(offset, CHECKED_OFFSET);
  tb := TThemedButton(offset);
  Result := ThemeServices.GetElementDetails(tb);
end;
(*
  offset := 0
const                     // hovered      pressed      state
  caEnabledDetails: array [False..True, False..True, cbUnChecked..cbChecked] of TThemedElementDetails =
    (
     (
      (tbRadioButtonUncheckedNormal, tbRadioButtonCheckedNormal),
      (tbRadioButtonUncheckedPressed, tbRadioButtonCheckedPressed)
     ),
     (
      (tbRadioButtonUncheckedHot, tbRadioButtonCheckedHot),
      (tbRadioButtonUncheckedPressed, tbRadioButtonCheckedPressed)
     )
    );

  caDisabledDetails: array [cbUnchecked..cbChecked] of TThemedButton =
    (tbRadioButtonUncheckedDisabled, tbRadioButtonCheckedDisabled);
begin
  if Enabled then
    Result := caEnabledDetails[AHovered, APressed, AState]
  else
    Result := caDisabledDetails[AState];
end;
            *)


{==============================================================================}
{                               TCustomCheckboxEx                              }
{==============================================================================}

constructor TCustomCheckboxEx.Create(AOwner: TComponent);
begin
  inherited;
  FKind := cckCheckbox;
//  InitBtnSize(false);
end;

function TCustomCheckBoxEx.GetThemedButtonDetails(
  AHovered, APressed, AEnabled: Boolean; AState: TCheckboxState): TThemedElementDetails;
var
  offset: Integer = 0;
  tb: TThemedButton;
begin
  offset := ord(FIRST_CHECKBOX_DETAIL);
  if APressed then
    inc(offset, PRESSED_OFFSET)
  else if AHovered then
    inc(offset, HOT_OFFSET);
  if not AEnabled then inc(offset, DISABLED_OFFSET);
  case AState of
    cbChecked: inc(offset, CHECKED_OFFSET);
    cbGrayed: inc(offset, MIXED_OFFSET);
  end;
  tb := TThemedButton(offset);
  Result := ThemeServices.GetElementDetails(tb);
end;
      (*

const                     // hovered    pressed      state
  caEnabledDetails: array [False..True, False..True, cbUnchecked..cbGrayed] of TThemedButton =
    (
     (
      (tbCheckBoxUncheckedNormal, tbCheckBoxCheckedNormal, tbCheckBoxMixedNormal),
      (tbCheckBoxUncheckedPressed, tbCheckBoxCheckedPressed, tbCheckBoxMixedPressed)
     ),
     (
      (tbCheckBoxUncheckedHot, tbCheckBoxCheckedHot, tbCheckBoxMixedHot),
      (tbCheckBoxUncheckedPressed, tbCheckBoxCheckedPressed, tbCheckBoxMixedPressed)
     )
    );

  caDisabledDetails: array [cbUnchecked..cbGrayed] of TThemedButton =
    (tbCheckBoxUncheckedDisabled, tbCheckBoxCheckedDisabled, tbCheckBoxMixedDisabled);
var
  tb: TThemedButton;
begin
  if Enabled then
    tb := caEnabledDetails[AHovered, APressed, AState]
  else
    tb := caDisabledDetails[AState];
  Result := ThemeServices.GetElementDetails(tb);
end;    *)


{==============================================================================}
{                       TCustomCheckControlGroupEx                             }
{==============================================================================}
constructor TCustomCheckControlGroupEx.Create(AOwner: TComponent);
begin
  inherited;
  FAutoFill := true;
  FButtonList := TFPList.Create;
  FColumns := 1;
  FColumnLayout := clHorizontalThenVertical;
  ChildSizing.Layout := cclLeftToRightThenTopToBottom;
  ChildSizing.ControlsPerLine := FColumns;
  ChildSizing.ShrinkHorizontal := crsScaleChilds;
  ChildSizing.ShrinkVertical := crsScaleChilds;
  ChildSizing.EnlargeHorizontal := crsHomogenousChildResize;
  ChildSizing.EnlargeVertical := crsHomogenousChildResize;
  ChildSizing.LeftRightSpacing := 6;
  ChildSizing.TopBottomSpacing := 0;
end;

destructor TCustomCheckControlGroupEx.Destroy;
var
  i: Integer;
begin
  for i:=0 to FButtonList.Count-1 do
    TCustomCheckControlEx(FButtonList[i]).Free;
  FButtonList.Free;
  FItems.Free;
  inherited;
end;

function TCustomCheckControlGroupEx.CanModify: Boolean;
begin
  Result := not FReadOnly;
end;

procedure TCustomCheckControlgroupEx.FlipChildren(AllLevels: Boolean);
begin
  // no flipping
end;

procedure TCustomCheckControlGroupEx.ItemEnter(Sender: TObject);
begin
  DoEnter;
end;

procedure TCustomCheckControlGroupEx.ItemExit(Sender: TObject);
begin
  DoExit;
end;

procedure TCustomCheckControlGroupEx.ItemKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> 0 then
    KeyDown(Key, Shift);
end;

procedure TCustomCheckControlGroupEx.ItemKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <> 0 then
    KeyUp(Key, Shift);
end;

procedure TCustomCheckControlGroupEx.ItemKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #0 then
    KeyPress(Key);
end;

procedure TCustomCheckControlGroupEx.ItemUTF8KeyPress(Sender: TObject;
  var UTF8Key: TUTF8Char);
begin
  UTF8KeyPress(UTF8Key);
end;

procedure TCustomCheckControlGroupEx.ItemResize(Sender: TObject);
begin
  //
end;

function TCustomCheckControlGroupEx.Rows: integer;
begin
  if FItems.Count > 0 then
    Result := ((FItems.Count-1) div Columns) + 1
  else
    Result := 0;
end;

procedure TCustomCheckControlGroupEx.SetAutoFill(const AValue: Boolean);
begin
  if FAutoFill = AValue then exit;
  FAutoFill := AValue;
  DisableAlign;
  try
    if FAutoFill then begin
      ChildSizing.EnlargeHorizontal := crsHomogenousChildResize;
      ChildSizing.EnlargeVertical := crsHomogenousChildResize;
    end else begin
      ChildSizing.EnlargeHorizontal := crsAnchorAligning;
      ChildSizing.EnlargeVertical := crsAnchorAligning;
    end;
  finally
    EnableAlign;
  end;
end;

procedure TCustomCheckControlGroupEx.SetColumnLayout(const AValue: TColumnLayout);
begin
  if FColumnLayout = AValue then exit;
  FColumnLayout := AValue;
  if FColumnLayout = clHorizontalThenVertical then
    ChildSizing.Layout := cclLeftToRightThenTopToBottom
  else
    ChildSizing.Layout := cclTopToBottomThenLeftToRight;
  UpdateControlsPerLine;
end;

procedure TCustomCheckControlGroupEx.SetColumns(const AValue: integer);
begin
  if AValue <> FColumns then begin
    if (AValue < 1) then
       raise Exception.Create('TCustomRadioGroup: Columns must be >= 1');
    FColumns := AValue;
    UpdateControlsPerLine;
  end;
end;

procedure TCustomCheckControlGroupEx.SetOnGetImageIndex(const AValue: TGetImageIndexEvent);
var
  i: Integer;
begin
  FOnGetImageIndex := AValue;
  for i := 0 to FButtonList.Count - 1 do
    TCustomCheckControlEx(FButtonList[i]).OnGetImageIndex := AValue;
end;

procedure TCustomCheckControlGroupEx.SetImages(const AValue: TCustomImagelist);
var
  i: Integer;
begin
  if AValue = FImages then exit;
  FImages := AValue;
  for i:=0 to FButtonList.Count-1 do
    TCustomCheckControlEx(FButtonList[i]).Images := FImages;
end;

procedure TCustomCheckControlGroupEx.SetImagesWidth(const AValue: Integer);
var
  i: Integer;
begin
  if AValue = FImagesWidth then exit;
  FImagesWidth := AValue;
  for i := 0 to FButtonList.Count - 1 do
    TCustomCheckControlEx(FButtonList[i]).ImagesWidth := FImagesWidth;
end;

procedure TCustomCheckControlGroupEx.SetItems(const AValue: TStrings);
begin
  if (AValue <> FItems) then
  begin
    FItems.Assign(AValue);
    UpdateItems;
    UpdateControlsPerLine;
  end;
end;

procedure TCustomCheckControlGroupEx.SetReadOnly(const AValue: Boolean);
var
  i: Integer;
begin
  if AValue = FReadOnly then exit;
  FReadOnly := AValue;
  for i := 0 to FButtonList.Count -1 do
    TCustomCheckControlEx(FButtonList[i]).ReadOnly := FReadOnly;
end;

procedure TCustomCheckControlGroupEx.UpdateAll;
begin
  UpdateItems;
  UpdateControlsPerLine;
  OwnerFormDesignerModified(Self);
end;

procedure TCustomCheckControlGroupEx.UpdateControlsPerLine;
var
  newControlsPerLine: LongInt;
begin
  if ChildSizing.Layout = cclLeftToRightThenTopToBottom then
    newControlsPerLine := Max(1, FColumns)
  else
    newControlsPerLine := Max(1, Rows);
  ChildSizing.ControlsPerLine := NewControlsPerLine;
end;

procedure TCustomCheckControlGroupEx.UpdateInternalObjectList;
begin
  UpdateItems;
end;

procedure TCustomCheckControlGroupEx.UpdateTabStops;
var
  i: Integer;
  btn: TCustomCheckControlEx;
begin
  for i := 0 to FButtonList.Count - 1 do
  begin
    btn := TCustomCheckControlEx(FButtonList[i]);
    btn.TabStop := btn.Checked;
  end;
end;

{==============================================================================}
{                           TRadioGroupExStringList                            }
{==============================================================================}

type
  TRadioGroupExStringList = class(TStringList)
  private
    FRadioGroup: TCustomRadioGroupEx;
  protected
    procedure Changed; override;
  public
    constructor Create(ARadioGroup: TCustomRadioGroupEx);
    procedure Assign(Source: TPersistent); override;
  end;

constructor TRadioGroupExStringList.Create(ARadioGroup: TCustomRadioGroupEx);
begin
  inherited Create;
  FRadioGroup := ARadioGroup;
end;

procedure TRadioGroupExStringList.Assign(Source: TPersistent);
var
  savedIndex: Integer;
begin
  savedIndex := FRadioGroup.ItemIndex;
  inherited Assign(Source);
  if savedIndex < Count then FRadioGroup.ItemIndex := savedIndex;
end;

procedure TRadioGroupExStringList.Changed;
begin
  inherited Changed;
  if (UpdateCount = 0) then
    FRadioGroup.UpdateAll
  else
    FRadioGroup.UpdateInternalObjectList;
  FRadioGroup.FLastClickedItemIndex := FRadioGroup.FItemIndex;
end;


{==============================================================================}
{                           TCustomRadioGroupEx                                }
{==============================================================================}

constructor TCustomRadioGroupEx.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TRadioGroupExStringList.Create(Self);
  FItemIndex := -1;
  FLastClickedItemIndex := -1;
end;

procedure TCustomRadioGroupEx.Changed(Sender: TObject);
begin
  CheckItemIndexChanged;
end;

procedure TCustomRadioGroupEx.CheckItemIndexChanged;
begin
  if FCreatingWnd or FUpdatingItems then
    exit;
  if [csLoading,csDestroying]*ComponentState<>[] then exit;
  UpdateRadioButtonStates;
  if [csDesigning]*ComponentState<>[] then exit;
  if FLastClickedItemIndex=FItemIndex then exit;
  FLastClickedItemIndex:=FItemIndex;
  EditingDone;
  // for Delphi compatibility: OnClick should be invoked, whenever ItemIndex
  // has changed
  if Assigned (FOnClick) then FOnClick(Self);
  // And a better named LCL equivalent
  if Assigned (FOnSelectionChanged) then FOnSelectionChanged(Self);
end;

procedure TCustomRadioGroupEx.Clicked(Sender: TObject);
begin
  if FIgnoreClicks then exit;
  CheckItemIndexChanged;
end;

function TCustomRadioGroupEx.GetButtonCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to ControlCount-1 do
    if (Controls[i] is TCustomRadioButtonEx) and (Controls[i] <> FHiddenButton) then
      inc(Result);
end;

function TCustomRadioGroupEx.GetButtons(AIndex: Integer): TRadioButtonEx;
begin
  Result := Controls[AIndex] as TRadioButtonEx;
end;

procedure TCustomRadioGroupEx.InitializeWnd;

  procedure RealizeItemIndex;
  var
    i: Integer;
  begin
    if (FItemIndex <> -1) and (FItemIndex<FButtonList.Count) then
      TRadioButtonEx(FButtonList[FItemIndex]).Checked := true
    else if FHiddenButton<>nil then
      FHiddenButton.Checked := true;
    for i:=0 to FItems.Count-1 do begin
      TRadioButtonEx(FButtonList[i]).Checked := (FItemIndex = i);
    end;
  end;

begin
  if FCreatingWnd then RaiseGDBException('TCustomRadioGroup.InitializeWnd');
  FCreatingWnd := true;
  UpdateItems;
  inherited InitializeWnd;
  RealizeItemIndex;
  //debugln(['TCustomRadioGroup.InitializeWnd END']);
  FCreatingWnd := false;
end;

procedure TCustomRadioGroupEx.ItemKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  procedure MoveSelection(HorzDiff, VertDiff: integer);
  var
    Count: integer;
    StepSize: integer;
    BlockSize : integer;
    NewIndex : integer;
    WrapOffset: integer;
  begin
    if FReadOnly then
      exit;

    Count := FButtonList.Count;
    if FColumnLayout = clHorizontalThenVertical then begin
      //add a row for ease wrapping
      BlockSize := Columns * (Rows+1);
      StepSize := HorzDiff + VertDiff * Columns;
      WrapOffSet := VertDiff;
    end
    else begin
      //add a column for ease wrapping
      BlockSize := (Columns+1) * Rows;
      StepSize := HorzDiff * Rows + VertDiff;
      WrapOffSet := HorzDiff;
    end;
    NewIndex := ItemIndex;
    repeat
      Inc(NewIndex, StepSize);
      if (NewIndex >= Count) or (NewIndex < 0) then begin
        NewIndex := (NewIndex + WrapOffSet + BlockSize) mod BlockSize;
        // Keep moving in the same direction until in valid range
        while NewIndex >= Count do
           NewIndex := (NewIndex + StepSize) mod BlockSize;
      end;
    until (NewIndex = ItemIndex) or TCustomCheckControlEx(FButtonList[NewIndex]).Enabled;
    ItemIndex := NewIndex;
    TCustomCheckControlEx(FButtonList[ItemIndex]).SetFocus;
    Key := 0;
  end;

begin
  if Shift=[] then begin
    case Key of
      VK_LEFT: MoveSelection(-1,0);
      VK_RIGHT: MoveSelection(1,0);
      VK_UP: MoveSelection(0,-1);
      VK_DOWN: MoveSelection(0,1);
    end;
  end;
  if Key <> 0 then
    KeyDown(Key, Shift);
end;

procedure TCustomRadioGroupEx.ReadState(AReader: TReader);
begin
  FReading := True;
  inherited ReadState(AReader);
  FReading := False;
  if (FItemIndex < -1) or (FItemIndex >= FItems.Count) then
    FItemIndex := -1;
  FLastClickedItemIndex := FItemIndex;
end;

procedure TCustomRadioGroupEx.SetItemIndex(const AValue: integer);
var
  oldItemIndex: LongInt;
  oldIgnoreClicks: Boolean;
begin
  if (AValue = FItemIndex) or FReadOnly then exit;

  // needed later if handle isn't allocated
  oldItemIndex := FItemIndex;

  if FReading then
    FItemIndex := AValue
  else begin
    if (AValue < -1) or (AValue >= FItems.Count) then
      raise Exception.CreateFmt(rsIndexOutOfBounds, [ClassName, AValue, FItems.Count-1]);

    if HandleAllocated then
    begin
      // the radiobuttons are grouped by the widget interface
      // and some does not allow to uncheck all buttons in a group
      // Therefore there is a hidden button
      FItemIndex := AValue;
      oldIgnoreClicks := FIgnoreClicks;
      FIgnoreClicks := true;
      try
        if (FItemIndex <> -1) then
          TCustomCheckControlEx(FButtonList[FItemIndex]).Checked := true
        else
          FHiddenButton.Checked := true;
        // uncheck old radiobutton
        if (OldItemIndex <> -1) then begin
          if (OldItemIndex >= 0) and (OldItemIndex < FButtonList.Count) then
            TCustomCheckControlEx(FButtonList[OldItemIndex]).Checked := false
        end else
          FHiddenButton.Checked := false;
      finally
        FIgnoreClicks := OldIgnoreClicks;
      end;
      // this has automatically unset the old button. But they do not recognize
      // it. Update the states.
      CheckItemIndexChanged;
      UpdateTabStops;
      OwnerFormDesignerModified(Self);
    end else
    begin
      FItemIndex := AValue;

      // maybe handle was recreated. issue #26714
      FLastClickedItemIndex := -1;

      // trigger event to be delphi compat, even if handle isn't allocated.
      // issue #15989
      if (AValue <> oldItemIndex) and not FCreatingWnd then
      begin
        if Assigned(FOnClick) then FOnClick(Self);
        if Assigned(FOnSelectionChanged) then FOnSelectionChanged(Self);
        FLastClickedItemIndex := FItemIndex;
      end;
    end;
  end;
end;

procedure TCustomRadioGroupEx.UpdateItems;
var
  i: integer;
  button: TCustomCheckControlEx;
begin
  if FUpdatingItems then exit;
  FUpdatingItems := true;
  try
    // destroy radiobuttons, if there are too many
    while FButtonList.Count > FItems.Count do
    begin
      TObject(FButtonList[FButtonList.Count-1]).Free;
      FButtonList.Delete(FButtonList.Count-1);
    end;

    // create as many TRadioButtons as needed
    while (FButtonList.Count < FItems.Count) do
    begin
      button := TRadioButtonEx.Create(Self);
      with TCustomCheckControlEx(button) do
      begin
        Name := 'RadioButtonEx' + IntToStr(FButtonList.Count);
        OnClick := @Self.Clicked;
        OnChange := @Self.Changed;
        OnEnter := @Self.ItemEnter;
        OnExit := @Self.ItemExit;
        OnKeyDown := @Self.ItemKeyDown;
        OnKeyUp := @Self.ItemKeyUp;
        OnKeyPress := @Self.ItemKeyPress;
        OnUTF8KeyPress := @Self.ItemUTF8KeyPress;
        OnResize := @Self.ItemResize;
        ParentFont := True;
        ReadOnly := Self.ReadOnly;
        BorderSpacing.CellAlignHorizontal := ccaLeftTop;
        BorderSpacing.CellAlignVertical := ccaCenter;
        ControlStyle := ControlStyle + [csNoDesignSelectable];
      end;
      FButtonList.Add(button);
    end;
    if FHiddenButton = nil then begin
      FHiddenButton := TRadioButtonEx.Create(nil);
      with FHiddenButton do
      begin
        Name := 'HiddenRadioButton';
        Visible := False;
        ControlStyle := ControlStyle + [csNoDesignSelectable, csNoDesignVisible];
      end;
    end;

    if (FItemIndex >= FItems.Count) and not (csLoading in ComponentState) then
      FItemIndex := FItems.Count-1;

    if FItems.Count > 0 then
    begin
      // to reduce overhead do it in several steps

      // assign Caption and then Parent
      for i:=0 to FItems.Count-1 do
      begin
        button := TCustomCheckControlEx(FButtonList[i]);
        button.Caption := FItems[i];
        button.Parent := Self;
      end;
      FHiddenButton.Parent := Self;

      // the checked and unchecked states can be applied only after all other
      for i := 0 to FItems.Count-1 do
      begin
        button := TCustomCheckControlEx(FButtonList[i]);
        button.Checked := (i = FItemIndex);
        button.Visible := true;
      end;

      //FHiddenButton must remain the last item in Controls[], so that Controls[] is in sync with Items[]
      Self.RemoveControl(FHiddenButton);
      Self.InsertControl(FHiddenButton);
      if HandleAllocated then
        FHiddenButton.HandleNeeded;
      FHiddenButton.Checked := (FItemIndex = -1);
      UpdateTabStops;
    end;
  finally
    FUpdatingItems := false;
  end;
end;

procedure TCustomRadioGroupEx.UpdateRadioButtonStates;
var
  i: Integer;
begin
  if FReadOnly then
    exit;

  FItemIndex := -1;
  FHiddenButton.Checked;
  for i:=0 to FButtonList.Count-1 do
    if TCustomRadioButtonEx(FButtonList[i]).Checked then FItemIndex := i;
  UpdateTabStops;
end;


{==============================================================================}
{                       TCheckGroupExStringList                                }
{==============================================================================}

type
  TCheckGroupExStringList = class(TStringList)
  private
    FCheckGroup: TCustomCheckGroupEx;
    procedure RestoreCheckStates(const AStates: TByteDynArray);
    procedure SaveCheckStates(out AStates: TByteDynArray);
  protected
    procedure Changed; override;
  public
    constructor Create(ACheckGroup: TCustomCheckGroupEx);
    procedure Delete(AIndex: Integer); override;
  end;


constructor TCheckGroupExStringList.Create(ACheckGroup: TCustomCheckGroupEx);
begin
  inherited Create;
  FCheckGroup := ACheckGroup;
end;

procedure TCheckGroupExStringList.Changed;
begin
  inherited Changed;
  if UpdateCount = 0 then
    FCheckGroup.UpdateAll
  else
    FCheckGroup.UpdateInternalObjectList;
end;

procedure TCheckGroupExStringList.Delete(AIndex: Integer);
// Deleting destroys the checked state of the items -> we must save and restore it
// Issue https://bugs.freepascal.org/view.php?id=34327.
var
  b: TByteDynArray;
  i: Integer;
begin
  SaveCheckStates(b);

  inherited Delete(AIndex);

  for i:= AIndex to High(b)-1 do b[i] := b[i+1];
  SetLength(b, Length(b)-1);
  RestoreCheckStates(b);
end;

procedure TCheckGroupExStringList.RestoreCheckStates(const AStates: TByteDynArray);
var
  i: Integer;
begin
  Assert(Length(AStates) = FCheckGroup.Items.Count);
  for i:=0 to FCheckgroup.Items.Count-1 do begin
    FCheckGroup.Checked[i] := AStates[i] and 1 <> 0;
    FCheckGroup.CheckEnabled[i] := AStates[i] and 2 <> 0;
  end;
end;

procedure TCheckGroupExStringList.SaveCheckStates(out AStates: TByteDynArray);
var
  i: Integer;
begin
  SetLength(AStates, FCheckgroup.Items.Count);
  for i:=0 to FCheckgroup.Items.Count-1 do begin
    AStates[i] := 0;
    if FCheckGroup.Checked[i] then inc(AStates[i]);
    if FCheckGroup.CheckEnabled[i] then inc(AStates[i], 2);
  end;
end;


{==============================================================================}
{                         TCustomCheckGroupEx                                  }
{==============================================================================}

constructor TCustomCheckGroupEx.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TCheckGroupExStringList.Create(Self);
end;

procedure TCustomCheckGroupEx.Clicked(Sender: TObject);
var
  index: Integer;
begin
  index := FButtonList.IndexOf(Sender);
  if index < 0 then exit;
  DoClick(index);
end;

procedure TCustomCheckGroupEx.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', @ReadData, @WriteData, FItems.Count > 0);
end;

procedure TCustomCheckGroupEx.DoClick(AIndex: integer);
begin
  if [csLoading,csDestroying, csDesigning] * ComponentState <> [] then exit;
  EditingDone;
  if Assigned(FOnItemClick) then FOnItemClick(Self, AIndex);
end;

function TCustomCheckGroupEx.GetButtonCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to ControlCount-1 do
    if (Controls[i] is TCustomCheckBoxEx) then
      inc(Result);
end;

function TCustomCheckGroupEx.GetButtons(AIndex: Integer): TCheckBoxEx;
begin
  Result := Controls[AIndex] as TCheckBoxEx;
end;

function TCustomCheckGroupEx.GetChecked(AIndex: Integer): Boolean;
begin
  if (AIndex < -1) or (AIndex >= FItems.Count) then
    RaiseIndexOutOfBounds(AIndex);
  Result := TCustomCheckControlEx(FButtonList[AIndex]).Checked;
end;

function TCustomCheckGroupEx.GetCheckEnabled(AIndex: integer): boolean;
begin
  if (AIndex < -1) or (AIndex >= FItems.Count) then
    RaiseIndexOutOfBounds(AIndex);
  Result := TCustomCheckControlEx(FButtonList[AIndex]).Enabled;
end;

procedure TCustomCheckGroupEx.Loaded;
begin
  inherited Loaded;
  UpdateItems;
end;

procedure TCustomCheckGroupEx.RaiseIndexOutOfBounds(AIndex: integer);
begin
  raise Exception.CreateFmt(rsIndexOutOfBounds, [ClassName, AIndex, FItems.Count - 1]);
end;

procedure TCustomCheckGroupEx.ReadData(Stream: TStream);
var
  ChecksCount: integer;
  Checks: string;
  i: Integer;
  v: Integer;
begin
  ChecksCount := ReadLRSInteger(Stream);
  if ChecksCount > 0 then begin
    SetLength(Checks, ChecksCount);
    Stream.ReadBuffer(Checks[1], ChecksCount);
    for i:=0 to ChecksCount-1 do begin
      v := ord(Checks[i+1]);
      Checked[i] := ((v and 1) > 0);
      CheckEnabled[i] := ((v and 2) > 0);
    end;
  end;
end;

procedure TCustomCheckGroupEx.SetChecked(AIndex: integer; const AValue: boolean);
begin
  if (AIndex < -1) or (AIndex >= FItems.Count) then
    RaiseIndexOutOfBounds(AIndex);
  // disable OnClick
  TCheckBox(FButtonList[AIndex]).OnClick := nil;
  // set value
  TCheckBox(FButtonList[AIndex]).Checked := AValue;
  // enable OnClick
  TCheckBox(FButtonList[AIndex]).OnClick := @Clicked;
end;

procedure TCustomCheckGroupEx.SetCheckEnabled(AIndex: integer;
  const AValue: boolean);
begin
  if (AIndex < -1) or (AIndex >= FItems.Count) then
    RaiseIndexOutOfBounds(AIndex);
  TCustomCheckControlEx(FButtonList[AIndex]).Enabled := AValue;
end;

procedure TCustomCheckGroupEx.UpdateItems;
var
  i: integer;
  btn: TCustomCheckControlEx;
begin
  if FUpdatingItems then exit;
  FUpdatingItems := true;
  try
    // destroy checkboxes, if there are too many
    while FButtonList.Count > FItems.Count do begin
      TObject(FButtonList[FButtonList.Count-1]).Free;
      FButtonList.Delete(FButtonList.Count-1);
    end;

    // create as many TCheckBoxes as needed
    while (FButtonList.Count < FItems.Count) do begin
      btn := TCheckBoxEx.Create(Self);
      with TCheckBoxEx(btn) do begin
        Name := 'CheckBoxEx' + IntToStr(FButtonList.Count);
        OnClick := @Self.Clicked;
        OnKeyDown := @Self.ItemKeyDown;
        OnKeyUp := @Self.ItemKeyUp;
        OnKeyPress := @Self.ItemKeyPress;
        OnUTF8KeyPress := @Self.ItemUTF8KeyPress;
        AutoSize := False;
        Parent := Self;
        ParentFont := true;
        ReadOnly := Self.ReadOnly;
        BorderSpacing.CellAlignHorizontal := ccaLeftTop;
        BorderSpacing.CellAlignVertical := ccaCenter;
        ControlStyle := ControlStyle + [csNoDesignSelectable];
      end;
      FButtonList.Add(btn);
    end;

    for i:=0 to FItems.Count-1 do begin
      btn := TCustomCheckControlEx(FButtonList[i]);
      btn.Caption := FItems[i];
    end;
  finally
    FUpdatingItems := false;
  end;
end;

procedure TCustomCheckGroupEx.WriteData(Stream: TStream);
var
  ChecksCount: integer;
  Checks: string;
  i: Integer;
  v: Integer;
begin
  ChecksCount := FItems.Count;
  WriteLRSInteger(Stream, ChecksCount);
  if ChecksCount > 0 then begin
    SetLength(Checks, ChecksCount);
    for i := 0 to ChecksCount-1 do begin
      v := 0;
      if Checked[i] then inc(v, 1);
      if CheckEnabled[i] then inc(v, 2);
      Checks[i+1] := chr(v);
    end;
    Stream.WriteBuffer(Checks[1], ChecksCount);
  end;
end;

end.

