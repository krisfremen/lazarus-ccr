program everett_demo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, umainform
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Demo of TEverett';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tmainform, mainform);
  Application.Run;
end.

