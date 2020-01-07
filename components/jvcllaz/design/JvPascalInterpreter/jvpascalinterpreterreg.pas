unit JvPascalInterpreterReg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure Register;

implementation

{$R ..\..\resource\jvpascalinterpreterreg.res}

uses
  JvDsgnConsts, JvInterpreter;

procedure Register;
begin
  RegisterComponents(RsPaletteJvclVisual, [TJvInterpreterProgram]); //, TJvInterpreterFm]);
end;

end.

