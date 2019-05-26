program testCalLite;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, uMainTestCalLite;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

