unit JvCtrlsReg;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

procedure Register;

implementation

{$R ../../resource/jvctrlsreg.res}

uses
  Classes, ActnList, JvDsgnConsts,
  JvMovableBevel, JvRuler, JvGroupHeader, JvRollOut,
  JvHtControls, {JvDBHTLabel,} JvHint, JvHTHintForm, JvComboListBox,
  PropEdits, Controls;

procedure Register;
begin
  RegisterComponents(RsPaletteJvcl, [
    TJvMovableBevel, TJvMovablePanel, TJvRuler, TJvGroupHeader, TJvRollOut,
    TJvHint, TJvHTLabel, TJvHTListbox, TJvHTCombobox, TJvComboListBox
  ]);
  RegisterPropertyEditor(TypeInfo(TCaption), TJvHTLabel, 'Caption', TJvHintProperty);
  RegisterActions(RsJVCLActionsCategory, [TJvRollOutAction], nil);
end;

end.

