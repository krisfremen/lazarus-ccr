unit JvCtrlsReg;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

procedure Register;

implementation

{$R ../../resource/jvctrlsreg.res}

uses
  Classes, Controls, ActnList, PropEdits, JvDsgnConsts,
  JvMovableBevel, JvRuler, JvGroupHeader, JvRollOut,
  JvHtControls, JvHint, JvHTHintForm, JvComboListBox, JvInstallLabel,
  JvOfficeColorPanel,
  JvAutoComplete;   // original JVCL has this in package JvCore

procedure Register;
begin
  RegisterComponents(RsPaletteJvclVisual, [
    TJvMovableBevel, TJvMovablePanel, TJvRuler, TJvGroupHeader, TJvRollOut,
    TJvHint, TJvHTLabel, TJvHTListbox, TJvHTCombobox, TJvComboListBox,
    TJvOfficeColorPanel,
    TJvLookupAutoComplete, TJvInstallLabel
  ]);
  RegisterPropertyEditor(TypeInfo(TCaption), TJvHTLabel, 'Caption', TJvHintProperty);
  RegisterActions(RsJVCLActionsCategory, [TJvRollOutAction], nil);
end;

end.

