unit ExEditCtrls;

{$mode objfpc}{$H+}
{$codepage utf8} //because of the µ-sign

{.$define debug_editctrls}

interface

uses
  Classes, SysUtils, LCLVersion, Controls, SpinEx, Math;

type
  { TCustomCurrEditEx }
  TSpinEditCurrencyFormat = (
    secfCurrVal,               // 0: $1
    secfValCurr,               // 1: 1$
    secfCurrSpaceVal,          // 2: $ 1
    secfValSpaceCurr           // 3: 1 $
  );
  TSpinEditNegCurrencyFormat = (
    sencfParCurrValPar,        // 0: ($1)
    sencfMinusCurrVal,         // 1: -1$
    sencfCurrMinusVal,         // 2: $-1
    sencfCurrValMinus,         // 3: $1-
    sencfParValCurrPar,        // 4: (1$)
    sencfMinusValCurr,         // 5: -1$
    sencfValMinusCurr,         // 6: 1-$
    sencfValCurrMinus,         // 7: 1$-
    sencfMinusValSpaceCurr,    // 8: -1 $
    sencfMinusCurrSpaceVal,    // 9: -$ 1
    sencfValSpaceCurrMinus,    //10: 1 $-
    sencfCurrSpaceValMinus,    //11: $ 1-
    sencfCurrSpaceMinusVal,    //12: $ -1
    sencfValMinusSpaceCurr,    //13: 1- $
    sencfParCurrSpaceValPar,   //14: ($ 1)
    sencfParValSpaceCurrPar    //15: (1 $)
  );

  TSpinEditCurrencyDecimals = 0..4;

  TCustomCurrSpinEditEx = class(specialize TSpinEditExBase<Currency>)
  private
    FCurrencyString: String;
    FDecimals: TSpinEditCurrencyDecimals;
    FCurrencyFormat: TSpinEditCurrencyFormat;
    FDecimalSeparator: Char;
    FNegCurrencyFormat: TSpinEditNegCurrencyFormat;
    FThousandSeparator: Char;
    function IsIncrementStored: Boolean;
    procedure SetCurrencyFormat(AValue: TSpinEditCurrencyFormat);
    procedure SetCurrencyString(AValue: String);
    procedure SetDecimals(AValue: TSpinEditCurrencyDecimals);
    procedure SetDecimalSeparator(AValue: Char);
    procedure SetNegCurrencyFormat(AValue: TSpinEditNegCurrencyFormat);
    procedure SetThousandSeparator(AValue: Char);
  protected
    procedure EditKeyPress(var Key: char); override;
    function SafeInc(AValue: Currency): Currency; override;
    function SafeDec(AValue: Currency): Currency; override;
    function TextIsNumber(const S: String; out ANumber: Currency): Boolean; override;
    function TryExtractCurrency(AText: String; out AValue: Currency;
      const AFormatSettings: TFormatSettings): Boolean;
    function UsedFormatSettings: TFormatSettings;
  public
    constructor Create(AOwner: TComponent); override;
    function ValueToStr(const AValue: Currency): String; override;
    procedure ResetFormatSettings;
    function StrToValue(const S: String): Currency; override;
  public
    property Increment stored IsIncrementStored;
    property CurrencyFormat: TSpinEditCurrencyFormat
      read FCurrencyFormat write SetCurrencyFormat;
    property CurrencyString: String
      read FCurrencyString write SetCurrencyString;
    property Decimals: TSpinEditCurrencyDecimals
      read FDecimals write SetDecimals;
    property DecimalSeparator: Char
      read FDecimalSeparator write SetDecimalSeparator;
    property NegCurrencyFormat: TSpinEditNegCurrencyFormat
      read FNegCurrencyFormat write SetNegCurrencyFormat;
    property ThousandSeparator: Char
      read FThousandSeparator write SetThousandSeparator;
  end;

  { TCurrSpinEdit }

  TCurrSpinEditEx = class(TCustomCurrSpinEditEx)
  public
    property AutoSelected;
  published
    //From TCustomEdit
    property AutoSelect;
    property AutoSizeHeightIsEditHeight;
    property AutoSize default True;
    property Action;
    property Align;
    property Alignment default taRightJustify;
    property Anchors;
    property BiDiMode;
    property BorderSpacing;
    property BorderStyle default bsNone;
    property CharCase;
    property Color;
    property Constraints;
    property Cursor;
    property DirectInput;
    property EchoMode;
    property Enabled;
    property FocusOnBuddyClick;
    property Font;
    property Hint;
    property Layout;
    property MaxLength;
    property NumbersOnly;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TextHint;
    property Visible;

    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnContextPopup;
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

    //From TCustomFloatSpinEditEx
    property ArrowKeys;
    property CurrencyFormat;
    property CurrencyString;
    property Decimals;
    property DecimalSeparator;
    property Increment;
    property MaxValue;
    property MinValue;
    property MinRepeatValue;
    property NegCurrencyFormat;
    property NullValue;
    property NullValueBehaviour;
    property Spacing;
    property ThousandSeparator;
    property UpDownVisible;
    property Value;
  end;

  { TCustomFloatSISpinEdit (Author: Bart Broersma) }

  TSIPrefix = (Yotta,Zetta,Exa,Peta,Tera,Giga,Mega,kilo,kiloUC,One,
    milli,micro,microU,microalt,nano,pico,femto,atto,zepto,yocto);

  TCustomFloatSISpinEditEx = class(TCustomFloatSpinEditEx)
  private
    function EndsWithSIPrefix(var S: String; out APrefix: TSIPrefix): Boolean;
  protected
    procedure EditKeyPress(var Key: char); override;
    function TextIsNumber(const S: String; out ANumber: Double): Boolean; override;
  public
    function ValueToStr(const AValue: Double): String; override;
  end;

  TFloatSISpinEditEx = class(TCustomFloatSISpinEditEx)
  published
    //From TCustomEdit
    property AutoSelect;
    property AutoSizeHeightIsEditHeight;
    property AutoSize default True;
    property Action;
    property Align;
    property Alignment default taRightJustify;
    property Anchors;
    property BiDiMode;
    property BorderSpacing;
    property BorderStyle default bsNone;
    property CharCase;
    property Color;
    property Constraints;
    property Cursor;
    property DirectInput;
    property EchoMode;
    property Enabled;
    property FocusOnBuddyClick;
    property Font;
    property Hint;
    property Layout;
    property MaxLength;
    property NumbersOnly;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TextHint;
    property Visible;

    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnContextPopup;
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

    //From TCustomFloatSpinEditEx
    property ArrowKeys;
    property DecimalSeparator;
    property DecimalPlaces;
    property Increment;
    property MaxValue;
    property MinValue;
    property MinRepeatValue;
    property NullValue;
    property NullValueBehaviour;
    property Spacing;
    property UpDownVisible;
    property Value;
  end;


implementation

uses
  LCLProc, LazUTF8;

resourcestring
  RsDecSepMustNotMatchThSep = 'Decimal and thousand separators most not be equal.';

const
  Digits = ['0'..'9'];
  AllowedControlChars = [#8, #9, ^C, ^X, ^V, ^Z];

  SIPrefixes: array[TSIPrefix] of String = (
    'Y', 'Z', 'E', 'P', 'T', 'G', 'M', 'k', 'K', '',
    'm', 'µ', 'mc', 'u', 'n', 'p', 'f', 'a', 'z', 'y'
  );
  SIFactors:  array[TSIPrefix] of Double = (
    1E+24, 1E+21, 1E+18, 1E+15, 1E+12, 1E+9, 1E+6, 1E+3, 1E+3, 1.0,
    1E-3, 1E-6, 1E-6, 1E-6, 1E-9, 1E-12, 1E-15, 1E-18, 1E-21, 1E-24
  );

function UTF8EndsStr(const ASubStr, AStr: string): Boolean;
var
  TextLen, SubTextLen: PtrInt;
begin
  Result := False;
  if (ASubStr <> '') then
  begin
    TextLen := Utf8Length(AStr);
    SubTextLen := Utf8Length(ASubStr);
    if (TextLen >= SubTextLen) then
      Result := Utf8Copy(AStr,TextLen-SubTextLen+1,SubTextLen) = ASubStr;
  end;
end;

{ TCustomCurrSpinEditEx }

constructor TCustomCurrSpinEditEx.Create(AOwner: TComponent);
begin
  inherited;
  FMaxValue := 0;
  FMinValue := 0;  // --> disable Max/Min check by default
  ResetFormatSettings;
end;

procedure TCustomCurrSpinEditEx.EditKeyPress(var Key: char);
begin
  inherited EditKeyPress(Key);
  {Disallow any key that is not a digit or -
   Tab, BackSpace, Cut, Paste, Copy, Undo of course should be passed onto inherited KeyPress
  }
  if not (Key in (Digits + AllowedControlChars + ['-'])) then Key := #0;
  if (Key = '-') and IsLimited and (MinValue >= 0) then Key := #0;
end;

procedure TCustomCurrSpinEditEx.ResetFormatSettings;
begin
  FDecimals := DefaultFormatSettings.CurrencyDecimals;
  FCurrencyFormat := TSpinEditCurrencyFormat(DefaultFormatSettings.CurrencyFormat);
  FCurrencyString := DefaultFormatSettings.CurrencyString;
  FDecimalSeparator := DefaultFormatSettings.DecimalSeparator;
  FNegCurrencyFormat := TSpinEditNegCurrencyFormat(DefaultFormatSettings.NegCurrFormat);
  FThousandSeparator := DefaultFormatSettings.ThousandSeparator;
end;

function TCustomCurrSpinEditEx.IsIncrementStored: Boolean;
begin
  Result := FIncrement <> 1;
end;

function TCustomCurrSpinEditEx.SafeInc(AValue: Currency): Currency;
begin
  if (AValue > 0) and (AValue > MaxCurrency-FIncrement) then
    Result := MaxCurrency
  else
    Result := AValue + FIncrement;
end;

function TCustomCurrSpinEditEx.SafeDec(AValue: Currency): Currency;
begin
  if (AValue < 0) and (MinCurrency + FIncrement > AValue) then
    Result := MinCurrency
  else
    Result := AValue - FIncrement;
end;

procedure TCustomCurrSpinEditEx.SetCurrencyFormat(AValue: TSpinEditCurrencyFormat);
begin
  if AValue = FCurrencyFormat then exit;
  FCurrencyFormat := AValue;
  UpdateControl;
end;

procedure TCustomCurrSpinEditEx.SetCurrencyString(AValue: string);
begin
  if AValue = FCurrencyString then exit;
  FCurrencyString := AValue;
  UpdateControl;
end;

procedure TCustomCurrSpinEditEx.SetDecimals(AValue: TSpinEditCurrencyDecimals);
begin
  if AValue = FDecimals then exit;
  FDecimals := AValue;
  UpdateControl;
end;

procedure TCustomCurrSpinEditEx.SetDecimalSeparator(AValue: char);
begin
  if AValue = FDecimalSeparator then exit;
  if (AValue = FThousandSeparator) and (ComponentState = []) then
    raise Exception.Create(RsDecSepMustNotMatchThSep);
  FDecimalSeparator := AValue;
  UpdateControl;
end;

procedure TCustomCurrSpinEditEx.SetNegCurrencyFormat(
  AValue: TSpinEditNegCurrencyFormat);
begin
  if AValue = FNegCurrencyFormat then exit;
  FNegCurrencyFormat := AValue;
  UpdateControl;
end;

procedure TCustomCurrSpinEditEx.SetThousandSeparator(AValue: char);
begin
  if AValue = FThousandSeparator then exit;
  if AValue = FDecimalSeparator then
    raise Exception.Create(RsDecSepMustNotMatchThSep);
  FThousandSeparator := AValue;
  UpdateControl;
end;

function TCustomCurrSpinEditEx.TextIsNumber(const S: String; out ANumber: Currency
  ): Boolean;
var
  C: Currency;
begin
  {$ifdef debug_editctrls}
  DbgOut(['TCustomSpinEditEx.TextIsNumber: S = "',S,'" Result = ']);
  {$endif}

  try
    Result := TryExtractCurrency(S, C, UsedFormatSettings);
//    Result := TryStrToCurr(S, C);
    ANumber := C;
  except
    Result := False;
  end;
  {$ifdef debug_editctrls}
  debugln([Result]);
  {$endif}
end;

function TCustomCurrSpinEditEx.TryExtractCurrency(AText: String;
  out AValue: Currency; const AFormatSettings: TFormatSettings): Boolean;
type
  TParenthesis = (pNone, pOpen, pClose);
var
  isNeg: Boolean;
  parenth: TParenthesis;
  P: PChar;
  PEnd: PChar;
  s: String;
  n: Integer;
begin
  Result := false;
  if AText = '' then
    exit;
  isNeg := false;
  parenth := pNone;
  SetLength(s, Length(AText));
  n := 1;
  P := @AText[1];
  PEnd := @AText[Length(AText)];
  while P <= PEnd do begin
    if (P^ in ['0'..'9']) or (P^ in [AFormatSettings.DecimalSeparator]) then
    begin
      s[n] := P^;
      inc(n);
    end else
    if P^ = '-' then
      isNeg := true
    else
    if P^ = '(' then begin
      isNeg := true;
      parenth := pOpen;
    end else
    if P^ = ')' then begin
      if not IsNeg then
        exit;
      parenth := pClose;
    end;
    inc(P);
  end;
  if IsNeg and (parenth = pOpen) then
    exit;
  SetLength(s, n-1);
  Result := TryStrToCurr(s, AValue, AFormatSettings);
  if Result and isNeg then AValue := -AValue;
end;

function TCustomCurrSpinEditEx.UsedFormatSettings: TFormatSettings;
begin
  Result := DefaultFormatSettings;
  Result.CurrencyFormat := ord(FCurrencyFormat);
  Result.NegCurrFormat := ord(FNegCurrencyFormat);
  Result.ThousandSeparator := FThousandSeparator;
  Result.DecimalSeparator := FDecimalSeparator;
  Result.CurrencyString := FCurrencyString;
  Result.CurrencyDecimals := FDecimals;
end;

function TCustomCurrSpinEditEx.ValueToStr(const AValue: Currency): String;
begin
  Result := Format('%m', [AValue], UsedFormatSettings);
end;

function TCustomCurrSpinEditEx.StrToValue(const S: String): Currency;
var
  Def, N: Currency;
begin
  {$ifdef debug_editctrls}
  debugln(['TCustomSpinEditEx.StrToValue: S="',S,'"']);
  {$endif}
  case FNullValueBehaviour of
    nvbShowTextHint: Def := FNullValue;
    nvbLimitedNullValue: Def := GetLimitedValue(FNullValue);
    nvbMinValue: Def := FMinValue;
    nvbMaxValue: Def := MaxValue;
    nvbInitialValue: Def := FInitialValue;
  end;
  try
    if (FNullValueBehaviour = nvbShowTextHint)then
    begin
      if TextIsNumber(S, N)
      then
        Result := N
      else
        Result := Def;
    end
    else
      if TextIsNumber(S, N) then
        Result := GetLimitedValue(N)
      else
        Result := Def
//      Result := GetLimitedValue(StrToCurrDef(S, Def));
  except
    Result := Def;
  end;
  {$ifdef debug_editctrls}
  debugln(['  Result=',(Result)]);
  {$endif}
end;


{ TCustomFloatSISpinEditEx }

function TCustomFloatSISpinEditEx.EndsWithSIPrefix(var S: String; out APrefix: TSIPrefix): Boolean;
var
  PrefixStr: String;
begin
  Result := False;
  for APrefix in TSIPrefix do
  begin
    PrefixStr := SIPrefixes[APrefix];
    if UTF8EndsStr(PrefixStr, S) then
    begin
      System.Delete(S, Length(S)-Length(PrefixStr)+1, Length(PrefixStr));
      Exit(True);
    end;
  end;
end;

procedure TCustomFloatSISpinEditEx.EditKeyPress(var Key: char);
begin
  //allow anything for the moment
end;

function TCustomFloatSISpinEditEx.TextIsNumber(const S: String; out ANumber: Double): Boolean;
var
  ValueStr: String;
  Factor: Double;
  APrefix: TSIPrefix;
begin
  ValueStr := S;
  Factor := 1.0;
  if not EndsWithSIPrefix(ValueStr, APrefix) then
    Exit(inherited TextIsNumber(S, ANumber));
  Factor := SIFactors[APrefix];
  Result := inherited TextIsNumber(ValueStr, ANumber);
  if Result then
    ANumber := Factor * ANumber;
end;

function TCustomFloatSISpinEditEx.ValueToStr(const AValue: Double): String;
var
  Prefix: TSIPrefix;
  LValue, AbsLValue, Factor: Double;
  fs: TFormatSettings;
begin
  LValue := GetLimitedValue(AValue);
  AbsLValue := Abs(LValue);
  for Prefix := Low(SIFactors) to High(SIFactors) do
  begin
    Factor := SIFactors[Prefix];
    if (AbsLValue >= Factor) then
    begin
      {$IF LCL_FullVersion < 2010000}
      fs := DefaultFormatSettings;
      fs.DecimalSeparator := DecimalSeparator;
      //fs.ThousandSeparator := ThousandSeparator;
      {$ELSE}
      fs := GetFormatSettings;
      {$IFEND}
      //since Ord(micro) < Ord(micoralt) this will alway render with a decent mu ('µ') and not with 'mc'
      Result := FloatToStrF(LValue/Factor, ffFixed, 20, DecimalPlaces, fs) + SIPrefixes[Prefix];
      Exit;
    end;
  end;
end;

end.

