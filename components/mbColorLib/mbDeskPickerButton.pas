unit mbDeskPickerButton;

{$MODE DELPHI}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Controls, StdCtrls, Graphics, Forms, ScreenWin;

type
  TmbDeskPickerButton = class(TButton)
  private
    FHintFmt: string;
    FSelColor: TColor;
    FScreenFrm: TScreenForm;
    FShowScreenHint: boolean;
    FOnWheelUp, FOnWheelDown: TMouseWheelUpDownEvent;
    FOnColorPicked: TNotifyEvent;
    FOnKeyDown: TKeyEvent;
  protected
    procedure ColorPicked(Sender: TObject);
    procedure ScreenKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StartPicking;
    procedure WheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
      var Handled: Boolean);
    procedure WheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
      var Handled: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;
    property SelectedColor: TColor read FSelColor;
  published
    property ScreenHintFormat: string read FHintFmt write FHintFmt;
    property ShowScreenHint: boolean read FShowScreenHint write FShowScreenHint default false;
    property OnScreenKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnSelColorChange: TNotifyEvent read FOnColorPicked write FOnColorPicked;
    property OnSelMouseWheelDown: TMouseWheelUpDownEvent read FOnWheelDown write FOnWheelDown;
    property OnSelMouseWheelUp: TMouseWheelUpDownEvent read FOnWheelUp write FOnWheelUp;
  end;


implementation

constructor TmbDeskPickerButton.Create(AOwner: TComponent);
begin
  inherited;
//  DoubleBuffered := true;
// ControlStyle := ControlStyle - [csAcceptsControls] + [csOpaque{$IFDEF DELPHI_7_UP}, csParentBackground{$ENDIF}];
  FHintFmt := 'RGB(%r, %g, %b)'#13'Hex: %h';
  FShowScreenHint := false;
end;

procedure TmbDeskPickerButton.Click;
begin
  inherited;
  StartPicking;
end;

procedure TmbDeskPickerButton.ColorPicked(Sender: TObject);
begin
  FSelColor := FScreenFrm.SelectedColor;
  if Assigned(FOnColorPicked) then
    FOnColorPicked(Self);
end;

procedure TmbDeskPickerButton.StartPicking;
begin
  FScreenFrm := TScreenForm.Create(Application);
  try
    FScreenFrm.OnSelColorChange := ColorPicked;
    FScreenFrm.OnScreenKeyDown := ScreenKeyDown;
    FScreenFrm.OnMouseWheelDown := WheelDown;
    FScreenFrm.OnMouseWheelUp := WheelUp;
    FScreenFrm.ShowHint := FShowScreenHint;
    FScreenFrm.FHintFormat := FHintFmt;
    FScreenFrm.ShowModal;
  finally
    FScreenFrm.Free;
  end;
end;

procedure TmbDeskPickerButton.ScreenKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
end;

procedure TmbDeskPickerButton.WheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FOnWheelUp) then
    FOnWheelUp(Self, Shift, MousePos, Handled);
end;

procedure TmbDeskPickerButton.WheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FOnWheelDown) then
    FOnWheelDown(Self, Shift, MousePos, Handled);
end;

end.
