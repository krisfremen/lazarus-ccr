program JvChartDemo;

{$MODE OBJFPC}{$H+}

uses
  Interfaces,
  Forms, printer4lazarus,
  JvChartDemoFm in 'JvChartDemoFm.pas' {JvChartDemoForm},
  StatsClasses in 'StatsClasses.pas', jvPenEditor;

{$R *.res}


begin
  Application.Initialize;
  Application.Title:='JvChartDemo';
  Application.Scaled := true;
  Application.CreateForm(TJvChartDemoForm, JvChartDemoForm);
  Application.Run;
end.
