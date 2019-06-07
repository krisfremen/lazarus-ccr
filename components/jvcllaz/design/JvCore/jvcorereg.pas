unit JvCoreReg;

{$mode objfpc}{$H+}

interface

procedure Register;

implementation

uses
  PropEdits,
  JvTypes, JvDsgnEditors;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TJvPersistentProperty), nil, '', TJvPersistentPropertyEditor);
end;

end.

