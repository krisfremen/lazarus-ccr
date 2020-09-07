program LazStats;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, tachartprint, lhelpcontrolpkg, Globals, LicenseUnit,
  OptionsUnit, MainDM, MainUnit, MathUnit, BasicSPCUnit,
SChartUnit, rchartunit, XBarChartUnit; //, utils, chartunit;

{$R LazStats.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='';
  Application.Scaled:=True;
  Application.Initialize;

  LoadOptions;
  if not LoggedOn then
  begin
    if AcceptLicenseForm then
      LoggedOn := true
    else
      Application.Terminate;
  end;
  Application.CreateForm(TMainDataModule, MainDataModule);
  Application.CreateForm(TOS3MainFrm, OS3MainFrm);
  Application.CreateForm(TRChartForm, RChartForm);
  Application.CreateForm(TXBarChartForm, XBarChartForm);
  Application.Run;
end.

