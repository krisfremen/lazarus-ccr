unit ExCtrlsReg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure Register;

implementation

uses
  ExButtons, ExCheckCtrls, ExEditCtrls;

{$R exctrlsreg.res}

procedure Register;
begin
  RegisterComponents('ExCtrls', [
    TButtonEx, TCheckboxEx, TRadioButtonEx, TCheckGroupEx, TRadioGroupEx
  ]);
  RegisterComponents('LazControls', [
    TCurrSpinEditEx
  ]);
end;


end.

