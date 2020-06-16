unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ComCtrls, ExButtons;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cbBorderColorDisabled: TColorButton;
    clbFontColorDisabled: TColorButton;
    clbFontColorDown: TColorButton;
    clbFontColorFocused: TColorButton;
    clbFontColorHot: TColorButton;
    clbFontColorNormal: TColorButton;
    cbColorDownFrom: TColorButton;
    cbBorderColorDown: TColorButton;
    cbColorDownTo: TColorButton;
    cbBorderColorFocused: TColorButton;
    cbBorderColorHot: TColorButton;
    cbBorderColorNormal: TColorButton;
    cbColorNormalFrom: TColorButton;
    cbColorNormalTo: TColorButton;
    cbColorHotFrom: TColorButton;
    cbColorHotTo: TColorButton;
    cbColorDisabledFrom: TColorButton;
    cbColorDisabledTo: TColorButton;
    cbColorFocusedFrom: TColorButton;
    cbColorFocusedTo: TColorButton;
    cbEnabled: TCheckBox;
    cbGradient: TCheckBox;
    cbShowFocusRect: TCheckBox;
    cbAutoSize: TCheckBox;
    cbFontNormalBold: TCheckBox;
    cbFontHotBold: TCheckBox;
    cbFontDisabledBold: TCheckBox;
    cbFontFocusedBold: TCheckBox;
    cbFontDownBold: TCheckBox;
    cbDefaultDrawing: TCheckBox;
    cbWordWrap: TCheckBox;
    cmbAlignment: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    seBorderWidthNormal: TSpinEdit;
    seBorderWidthHot: TSpinEdit;
    seBorderWidthDisabled: TSpinEdit;
    seBorderWidthFocused: TSpinEdit;
    seBorderWidthDown: TSpinEdit;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    udFontSizeNormal: TUpDown;
    procedure Button2Click(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure cbAutoSizeChange(Sender: TObject);
    procedure cbColorDisabledFromToChanged(Sender: TObject);
    procedure cbColorDownFromToChanged(Sender: TObject);
    procedure cbColorFocusedFromToChanged(Sender: TObject);
    procedure cbColorHotFromToChanged(Sender: TObject);
    procedure cbColorNormalFromToChanged(Sender: TObject);
    procedure cbEnabledChange(Sender: TObject);
    procedure cbGradientChange(Sender: TObject);
    procedure cbShowFocusRectChange(Sender: TObject);
    procedure cbFontBoldChange(Sender: TObject);
    procedure cbDefaultDrawingChange(Sender: TObject);
    procedure cbWordWrapChange(Sender: TObject);
    procedure cmbAlignmentChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure seBorderWidthDisabledChange(Sender: TObject);
    procedure seBorderWidthDownChange(Sender: TObject);
    procedure seBorderWidthFocusedChange(Sender: TObject);
    procedure seBorderWidthHotChange(Sender: TObject);
    procedure seBorderWidthNormalChange(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit1EditingDone(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit2EditingDone(Sender: TObject);
    procedure udFontSizeNormalClick(Sender: TObject; Button: TUDBtnType);
  private
    FButton1: TButtonEx;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  Unit2;

{ TForm1 }

procedure TForm1.Button2Click(Sender: TObject);
var
  F: TForm2;
  res: TModalResult;
begin
  F := TForm2.Create(nil);
  try
    res := F.ShowModal;
    case res of
      mrOK: ShowMessage('ModalResult = mrOK');
      mrCancel: ShowMessage('ModalResult = mrCancel');
      mrNone: ShowMessage('ModalResult = mrNone');
      else ShowMessage('unexpected ModalResult');
    end;
  finally
    F.Free;
  end;
end;

procedure TForm1.ButtonClick(Sender: TObject);
var
  s: String;
begin
  if Sender = FButton1 then
    s := 'Ex '
  else
    s := '   ';
  Memo1.Lines.Add(s + FormatDateTime('hh:nn:ss.zzz', now))
end;

procedure TForm1.cbAutoSizeChange(Sender: TObject);
begin
  //FButton1.Width := 100;
  //Button1.Width := 100;
  FButton1.AutoSize := cbAutoSize.Checked;
  Button1.AutoSize := cbAutoSize.Checked;
end;

procedure TForm1.cbColorDisabledFromToChanged(Sender: TObject);
var
  colorBtn: TColorButton;
begin
  if not (Sender is TColorButton) then exit;
  colorBtn := TColorButton(Sender);
  if colorBtn.Caption = 'From' then
    FButton1.Colors.ColorDisabledFrom := colorBtn.ButtonColor
  else if colorBtn.Caption = 'To' then
    FButton1.Colors.ColorDisabledTo := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Color' then
    FButton1.Border.ColorDisabled := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Font' then
    FButton1.FontDisabled.Color := colorBtn.ButtonColor;
end;

procedure TForm1.cbColorDownFromToChanged(Sender: TObject);
var
  colorBtn: TColorButton;
begin
  if not (Sender is TColorButton) then exit;
  colorBtn := TColorButton(Sender);
  if colorBtn.Caption = 'From' then
    FButton1.Colors.ColorDownFrom := colorBtn.ButtonColor
  else if colorBtn.Caption = 'To' then
    FButton1.Colors.ColorDownTo := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Color' then
    FButton1.Border.ColorDown := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Font' then
    FButton1.FontDown.Color := colorBtn.ButtonColor;
end;

procedure TForm1.cbColorFocusedFromToChanged(Sender: TObject);
var
  colorBtn: TColorButton;
begin
  if not (Sender is TColorButton) then exit;
  colorBtn := TColorButton(Sender);
  if colorBtn.Caption = 'From' then
    FButton1.Colors.ColorFocusedFrom := colorBtn.ButtonColor
  else if colorBtn.Caption = 'To' then
    FButton1.Colors.ColorFocusedTo := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Color' then
    FButton1.Border.ColorFocused := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Font' then
    FButton1.FontFocused.Color := colorBtn.ButtonColor;
end;

procedure TForm1.cbColorHotFromToChanged(Sender: TObject);
var
  colorBtn: TColorButton;
begin
  if not (Sender is TColorButton) then exit;
  colorBtn := TColorButton(Sender);
  if colorBtn.Caption = 'From' then
    FButton1.Colors.ColorHotFrom := colorBtn.ButtonColor
  else if colorBtn.Caption = 'To' then
    FButton1.Colors.ColorHotTo := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Color' then
    FButton1.Border.ColorHot := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Font' then
    FButton1.FontHot.Color := colorBtn.ButtonColor;
end;

procedure TForm1.cbColorNormalFromToChanged(Sender: TObject);
var
  colorBtn: TColorButton;
begin
  if not (Sender is TColorButton) then exit;
  colorBtn := TColorButton(Sender);
  if colorBtn.Caption = 'From' then
    FButton1.Colors.ColorNormalFrom := colorBtn.ButtonColor
  else if colorBtn.Caption = 'To' then
    FButton1.Colors.ColorNormalTo := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Color' then
    FButton1.Border.ColorNormal := colorBtn.ButtonColor
  else if colorBtn.Caption = 'Font' then
    FButton1.Font.Color := colorBtn.ButtonColor;
end;

procedure TForm1.cbEnabledChange(Sender: TObject);
begin
  FButton1.Enabled := cbEnabled.Checked;
  Button1.Enabled := cbEnabled.Checked;
end;

procedure TForm1.cbGradientChange(Sender: TObject);
begin
  FButton1.Gradient := cbGradient.Checked;
end;

procedure TForm1.cbShowFocusRectChange(Sender: TObject);
begin
  FButton1.ShowFocusRect := cbShowFocusRect.Checked;
end;

procedure TForm1.cbWordWrapChange(Sender: TObject);
begin
  FButton1.WordWrap := cbWordwrap.Checked;
end;

procedure TForm1.cbDefaultDrawingChange(Sender: TObject);
begin
  FButton1.DefaultDrawing := cbDefaultDrawing.Checked;
end;

procedure TForm1.cmbAlignmentChange(Sender: TObject);
begin
  Fbutton1.Alignment := TAlignment(cmbAlignment.ItemIndex);
end;

procedure TForm1.cbFontBoldChange(Sender: TObject);
var
  fnt: TFont;
begin
  if Sender = cbFontNormalBold then
    fnt := FButton1.Font
  else if Sender = cbFontHotBold then
    fnt := FButton1.FontHot
  else if Sender = cbFontDisabledBold then
    fnt := FButton1.FontDisabled
  else if Sender = cbFontFocusedBold then
    fnt := FButton1.FontFocused
  else if Sender = cbFontDownBold then
    fnt := FButton1.FontDown
  else
    raise Exception.Create('Unknown font');
  if TCheckbox(Sender).Checked then
    fnt.Style := fnt.Style + [fsBold]
  else
    fnt.Style := fnt.Style - [fsBold];
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FButton1 := TButtonEx.Create(self);
  FButton1.Parent := self;
  FButton1.Left := 10;
  Fbutton1.Top := 12;
  FButton1.Width := 250;
  FButton1.Caption := 'This is the new multi-line TButtonEx control';
  FButton1.OnClick := @ButtonClick;
  //FButton1.DoubleBuffered := true;

  cbColorNormalFrom.ButtonColor := FButton1.Colors.ColorNormalFrom;
  cbColorNormalTo.ButtonColor := FButton1.Colors.ColorNormalTo;
  cbColorHotFrom.ButtonColor := FButton1.Colors.ColorHotFrom;
  cbColorHotTo.ButtonColor := FButton1.Colors.ColorHotTo;
  cbColorDisabledFrom.ButtonColor := FButton1.Colors.ColorDisabledFrom;
  cbColorDisabledTo.ButtonColor := FButton1.Colors.ColorDisabledTo;
  cbColorFocusedFrom.ButtonColor := FButton1.Colors.ColorFocusedFrom;
  cbColorFocusedTo.ButtonColor := FButton1.Colors.ColorFocusedTo;
  cbColorDownFrom.ButtonColor := FButton1.Colors.ColorDownFrom;
  cbColorDownTo.ButtonColor := FButton1.Colors.ColorDownTo;
  cbBorderColorNormal.ButtonColor := FButton1.Border.ColorNormal;
  cbBorderColorHot.ButtonColor := FButton1.Border.ColorHot;
  cbBorderColorDisabled.ButtonColor := FButton1.Border.ColorDisabled;
  cbBorderColorFocused.ButtonColor := FButton1.Border.ColorFocused;
  cbBorderColorDown.ButtonColor := FButton1.Border.ColorDown;
  clbFontColorNormal.ButtonColor := ColorToRGB(FButton1.Font.Color);
  clbFontColorDisabled.ButtonColor := ColorToRGB(FButton1.FontDisabled.Color);
  clbFontColorHot.ButtonColor := ColorToRGB(FButton1.FontHot.Color);
  clbFontColorFocused.ButtonColor := ColorToRGB(FButton1.FontFocused.Color);
  clbFontColorDown.ButtonColor := ColorToRGB(FButton1.FontDown.Color);

  udFontSizeNormal.Position := Screen.SystemFont.Size;

  seBorderWidthNormal.Value := FButton1.Border.WidthNormal;
  seBorderWidthHot.Value := FButton1.Border.WidthHot;
  seBorderWidthDisabled.Value := FButton1.Border.WidthDisabled;
  seBorderWidthFocused.Value := FButton1.Border.WidthFocused;
  seBorderWidthDown.Value := FButton1.Border.WidthDown;

  ActiveControl := FButton1;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  SpinEdit1.Value := FButton1.Width;
  SpinEdit2.Value := FButton1.Height;
end;

procedure TForm1.seBorderWidthDisabledChange(Sender: TObject);
begin
  FButton1.Border.WidthDisabled := seBorderWidthDisabled.Value;
end;

procedure TForm1.seBorderWidthDownChange(Sender: TObject);
begin
  FButton1.Border.WidthDown := seBorderWidthDown.Value;
end;

procedure TForm1.seBorderWidthFocusedChange(Sender: TObject);
begin
  FButton1.Border.WidthFocused := seBorderWidthFocused.Value;
end;

procedure TForm1.seBorderWidthHotChange(Sender: TObject);
begin
  FButton1.Border.WidthHot := seBorderWidthHot.Value;
end;

procedure TForm1.seBorderWidthNormalChange(Sender: TObject);
begin
  FButton1.Border.WidthNormal := seBorderWidthNormal.Value;
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  FButton1.Width := SpinEdit1.Value;
end;

procedure TForm1.SpinEdit1EditingDone(Sender: TObject);
begin
  FButton1.Width := SpinEdit1.Value;
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
  FButton1.Height := SpinEdit2.Value;
end;

procedure TForm1.SpinEdit2EditingDone(Sender: TObject);
begin
  FButton1.Height := SpinEdit2.Value;
end;

procedure TForm1.udFontSizeNormalClick(Sender: TObject; Button: TUDBtnType);
begin
  FButton1.Font.Size := udFontSizeNormal.Position;
end;

end.

