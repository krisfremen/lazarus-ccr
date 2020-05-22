unit ExCtrlsReg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure Register;

implementation

uses
  ExCheckCtrls, ExEditCtrls;

{$R exctrlsreg.res}

procedure Register;
begin
  RegisterComponents('ExCtrls', [
    TCheckboxEx, TRadioButtonEx, TCheckGroupEx, TRadioGroupEx
  ]);
  RegisterComponents('LazControls', [
    TCurrSpinEditEx
  ]);
end;


end.

