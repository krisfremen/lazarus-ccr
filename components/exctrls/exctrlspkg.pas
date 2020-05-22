{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ExCtrlsPkg;

{$warn 5023 off : no warning about unused units}
interface

uses
  ExCheckCtrls, ExEditCtrls, ExCtrlsReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ExCtrlsReg', @ExCtrlsReg.Register);
end;

initialization
  RegisterPackage('ExCtrlsPkg', @Register);
end.
