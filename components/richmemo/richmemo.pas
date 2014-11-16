{
 richmemo.pas
 
 Author: Dmitry 'skalogryz' Boyarintsev 

 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}

unit RichMemo; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, StdCtrls, 
  WSRichMemo; 

type

  TFontParams     = WSRichMemo.TIntFontParams;
  TParaAlignment  = (paLeft, paRight, paCenter, paJustify);
  TParaMetric     = WSRichMemo.TIntParaMetric;
  TParaNumStyle   = WSRichMemo.TParaNumStyle;
  TParaNumbering  = WSRichMemo.TIntParaNumbering;

  TTextModifyMask  = set of (tmm_Color, tmm_Name, tmm_Size, tmm_Styles);

  { TCustomRichMemo }

  TCustomRichMemo = class(TCustomMemo)
  private
    fHideSelection  : Boolean;
  protected
    class procedure WSRegisterClass; override;
    procedure CreateWnd; override;    
    procedure UpdateRichMemo; virtual;
    procedure SetHideSelection(AValue: Boolean);
    function GetContStyleLength(TextStart: Integer): Integer;
    
    procedure SetSelText(const SelTextUTF8: string); override;
    
  public
    procedure CopyToClipboard; override;
    procedure CutToClipboard; override;
    procedure PasteFromClipboard; override;
    
    procedure SetTextAttributes(TextStart, TextLen: Integer; const TextParams: TFontParams); virtual;
    function GetTextAttributes(TextStart: Integer; var TextParams: TFontParams): Boolean; virtual;
    function GetStyleRange(CharOfs: Integer; var RangeStart, RangeLen: Integer): Boolean; virtual;

    function GetParaAllignment(TextStart: Integer; var AAlign: TParaAlignment): Boolean; virtual;
    procedure SetParaAlignment(TextStart, TextLen: Integer; AAlign: TParaAlignment); virtual;
    function GetParaMetric(TextStart: Integer; var AMetric: TParaMetric): Boolean; virtual;
    procedure SetParaMetric(TextStart, TextLen: Integer; const AMetric: TParaMetric); virtual;
    function GetParaNumbering(TextStart: Integer; var ANumber: TParaNumbering): Boolean; virtual;
    procedure SetParaNumbering(TextStart, TextLen: Integer; const ANumber: TParaNumbering); virtual;

    procedure SetTextAttributes(TextStart, TextLen: Integer; AFont: TFont);
    procedure SetRangeColor(TextStart, TextLength: Integer; FontColor: TColor);
    procedure SetRangeParams(TextStart, TextLength: Integer; ModifyMask: TTextModifyMask;
      const FontName: String; FontSize: Integer; FontColor: TColor; AddFontStyle, RemoveFontStyle: TFontStyles);

    function LoadRichText(Source: TStream): Boolean; virtual;
    function SaveRichText(Dest: TStream): Boolean; virtual;

    property HideSelection : Boolean read fHideSelection write SetHideSelection;
  end;
  
  TRichMemo = class(TCustomRichMemo)
  published
    property Align;
    property Alignment;
    property Anchors;
    property BidiMode;
    property BorderSpacing;
    property BorderStyle;
    property Color;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property Lines;
    property MaxLength;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditingDone;
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
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDrag;
    property OnUTF8KeyPress;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property PopupMenu;
    property ParentShowHint;
    property ReadOnly;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property WantReturns;
    property WantTabs;
    property WordWrap;
  end;
  
function GetFontParams(styles: TFontStyles): TFontParams; overload;
function GetFontParams(color: TColor; styles: TFontStyles): TFontParams; overload;
function GetFontParams(const Name: String; color: TColor; styles: TFontStyles): TFontParams; overload;
function GetFontParams(const Name: String; Size: Integer; color: TColor; styles: TFontStyles): TFontParams; overload;

var
  RTFLoadStream : function (AMemo: TCustomRichMemo; Source: TStream): Boolean = nil;
  RTFSaveStream : function (AMemo: TCustomRichMemo; Dest: TStream): Boolean = nil;

implementation

const
  ParaAlignCode : array [TParaAlignment] of Integer = (AL_LEFT, AL_RIGHT, AL_CENTER, AL_JUSTIFY);

function GetFontParams(styles: TFontStyles): TFontParams; overload;
begin 
  Result := GetFontParams('', 0, 0, styles);
end;

function GetFontParams(color: TColor; styles: TFontStyles): TFontParams; overload;
begin
  Result := GetFontParams('', 0, color, styles);
end;

function GetFontParams(const Name: String; color: TColor; styles: TFontStyles): TFontParams; overload;
begin
  Result := GetFontParams(Name, 0, color, styles);
end;

function GetFontParams(const Name: String; Size: Integer; color: TColor; styles: TFontStyles): TFontParams; overload;
begin
  Result.Name := Name;
  Result.Size := Size;
  Result.Color := color;
  Result.Style := styles;
end;

{ TCustomRichMemo }

procedure TCustomRichMemo.SetHideSelection(AValue: Boolean);
begin
  if HandleAllocated then 
    TWSCustomRichMemoClass(WidgetSetClass).SetHideSelection(Self, AValue);
  fHideSelection := AValue;   
end;

class procedure TCustomRichMemo.WSRegisterClass;  
begin
  inherited;
  WSRegisterCustomRichMemo;
end;

procedure TCustomRichMemo.CreateWnd;  
begin
  inherited CreateWnd;  
  UpdateRichMemo;
end;

procedure TCustomRichMemo.UpdateRichMemo; 
begin
  if not HandleAllocated then Exit;
  TWSCustomRichMemoClass(WidgetSetClass).SetHideSelection(Self, fHideSelection);
end;

procedure TCustomRichMemo.SetTextAttributes(TextStart, TextLen: Integer;  
  AFont: TFont); 
var
  params  : TFontParams;
begin
  params.Name := AFont.Name;
  params.Color := AFont.Color;
  params.Size := AFont.Size;
  params.Style := AFont.Style;
  SetTextAttributes(TextStart, TextLen, {TextStyleAll,} params);
end;

procedure TCustomRichMemo.SetTextAttributes(TextStart, TextLen: Integer;  
  {SetMask: TTextStyleMask;} const TextParams: TFontParams);
begin
  if not HandleAllocated then HandleNeeded;
  if HandleAllocated then
    TWSCustomRichMemoClass(WidgetSetClass).SetTextAttributes(Self, TextStart, TextLen, {SetMask,} TextParams);
end;

function TCustomRichMemo.GetTextAttributes(TextStart: Integer; var TextParams: TFontParams): Boolean; 
begin
  if not HandleAllocated then HandleNeeded;
  if HandleAllocated then
    Result := TWSCustomRichMemoClass(WidgetSetClass).GetTextAttributes(Self, TextStart, TextParams)
  else
    Result := false;
end;

function TCustomRichMemo.GetStyleRange(CharOfs: Integer; var RangeStart,
  RangeLen: Integer): Boolean;
begin
  if HandleAllocated then begin
    Result := TWSCustomRichMemoClass(WidgetSetClass).GetStyleRange(Self, CharOfs, RangeStart, RangeLen);
    if Result and (RangeLen = 0) then RangeLen := 1;
  end else begin
    RangeStart := -1;
    RangeLen := -1;
    Result := false;
  end;
end;

function TCustomRichMemo.GetParaAllignment(TextStart: Integer;
  var AAlign: TParaAlignment): Boolean;
var
  ac: Integer;
begin
  Result := HandleAllocated and
    TWSCustomRichMemoClass(WidgetSetClass).GetParaAlignment(Self, TextStart, ac);
  if Result then begin
    case ac of
      AL_LEFT: AAlign:=paLeft;
      AL_RIGHT: AAlign:=paRight;
      AL_CENTER: AAlign:=paCenter;
      AL_JUSTIFY: AAlign:=paJustify
    else
      AAlign:=paLeft;
    end;
  end;
end;

procedure TCustomRichMemo.SetParaAlignment(TextStart, TextLen: Integer;
  AAlign: TParaAlignment);
begin
  if HandleAllocated then
    TWSCustomRichMemoClass(WidgetSetClass).SetParaAlignment(Self, TextStart, TextLen, ParaAlignCode[AAlign]);
end;

function TCustomRichMemo.GetParaMetric(TextStart: Integer;
  var AMetric: TParaMetric): Boolean;
begin
  if HandleAllocated then
    Result := TWSCustomRichMemoClass(WidgetSetClass).GetParaMetric(Self, TextStart, AMetric)
  else
    Result := false;
end;

procedure TCustomRichMemo.SetParaMetric(TextStart, TextLen: Integer;
  const AMetric: TParaMetric);
begin
  if HandleAllocated then
    TWSCustomRichMemoClass(WidgetSetClass).SetParaMetric(Self, TextStart, TextLen, AMetric);
end;

function TCustomRichMemo.GetParaNumbering(TextStart: Integer;
  var ANumber: TParaNumbering): Boolean;
begin
  if HandleAllocated then
    Result := TWSCustomRichMemoClass(WidgetSetClass).GetParaNumbering(Self, TextStart, ANumber)
  else
    Result := false;
end;

procedure TCustomRichMemo.SetParaNumbering(TextStart, TextLen: Integer;
  const ANumber: TParaNumbering);
begin
  if HandleAllocated then
    TWSCustomRichMemoClass(WidgetSetClass).SetParaNumbering(Self, TextStart, TextLen, ANumber);
end;

function TCustomRichMemo.GetContStyleLength(TextStart: Integer): Integer;
var
  ofs, len  : Integer;
begin
  if GetStyleRange(TextStart, ofs, len) then Result := len - (TextStart-ofs)
  else Result := 1;
  if Result = 0 then Result := 1;
end;

procedure TCustomRichMemo.SetSelText(const SelTextUTF8: string);  
var
  st  : Integer;
begin
  if not HandleAllocated then HandleNeeded;
  Lines.BeginUpdate;
  try
    st := SelStart;
    if HandleAllocated then  
      TWSCustomRichMemoClass(WidgetSetClass).InDelText(Self, SelTextUTF8, SelStart, SelLength);
    SelStart := st;
    SelLength := length(UTF8Decode(SelTextUTF8));
  finally
    Lines.EndUpdate;
  end;
end;

procedure TCustomRichMemo.CopyToClipboard;  
begin
  if HandleAllocated then  
    TWSCustomRichMemoClass(WidgetSetClass).CopyToClipboard(Self);
end;

procedure TCustomRichMemo.CutToClipboard;  
begin
  if HandleAllocated then  
    TWSCustomRichMemoClass(WidgetSetClass).CutToClipboard(Self);
end;

procedure TCustomRichMemo.PasteFromClipboard;  
begin
  if HandleAllocated then  
    TWSCustomRichMemoClass(WidgetSetClass).PasteFromClipboard(Self);
end;

procedure TCustomRichMemo.SetRangeColor(TextStart, TextLength: Integer; FontColor: TColor);
begin
  SetRangeParams(TextStart, TextLength, [tmm_Color], '', 0, FontColor, [], []);
end;

procedure TCustomRichMemo.SetRangeParams(TextStart, TextLength: Integer; ModifyMask: TTextModifyMask;
      const FontName: String; FontSize: Integer; FontColor: TColor; AddFontStyle, RemoveFontStyle: TFontStyles);
var
  i : Integer;
  j : Integer;
  l : Integer;
  p : TFontParams;
begin
  if not HandleAllocated then HandleNeeded;

  if (ModifyMask = []) or (TextLength = 0) then Exit;

  i := TextStart;
  j := TextStart + TextLength;
  while i < j do begin
    GetTextAttributes(i, p);

    if tmm_Name in ModifyMask then p.Name := FontName;
    if tmm_Color in ModifyMask then p.Color := FontColor;
    if tmm_Size in ModifyMask then p.Size := FontSize;
    if tmm_Styles in ModifyMask then p.Style := p.Style + AddFontStyle - RemoveFontStyle;

    l := GetContStyleLength(i);
    if i + l > j then l := j - i;
    if l = 0 then l := 1;
    SetTextAttributes(i, l, p);
    inc(i, l);
  end;
end;


function TCustomRichMemo.LoadRichText(Source: TStream): Boolean;
begin
  if not HandleAllocated then HandleNeeded;
  if Assigned(Source) and HandleAllocated then begin
    if Assigned(RTFLoadStream) then begin
      Self.Lines.BeginUpdate;
      try
        Self.Lines.Clear;
        Result:=RTFLoadStream(Self, Source);
      finally
        Self.Lines.EndUpdate;
      end;
    end;
    if not Result then
      Result := TWSCustomRichMemoClass(WidgetSetClass).LoadRichText(Self, Source);
  end else
    Result := false;
end;

function TCustomRichMemo.SaveRichText(Dest: TStream): Boolean;
begin
  if Assigned(Dest) and HandleAllocated then begin
    Result := TWSCustomRichMemoClass(WidgetSetClass).SaveRichText(Self, Dest);
    if not Result and Assigned(RTFSaveStream) then
      Result:=RTFSaveStream(Self, Dest);
  end else
    Result := false;
end;

end.

