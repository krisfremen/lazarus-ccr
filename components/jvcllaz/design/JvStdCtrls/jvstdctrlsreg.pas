unit JvStdCtrlsReg;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

procedure Register;

implementation

{$R ../../resource/jvstdctrlsreg.res}

uses
  Classes, Controls, PropEdits,
  JvDsgnConsts, //JvDsgnEditors,
  JvButton, JvCheckbox, JvBaseEdits, JVPanel;

procedure Register;
begin
  RegisterComponents(RsPaletteJvcl, [TJvCheckbox, TJvPanel, TJvCalcEdit]);
//  RegisterPropertyEditor(TypeInfo(TJvArrangeSettings), nil, '', TJvPersistentPropertyEditor);
end;

end.

