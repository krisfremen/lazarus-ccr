program spready;

{$mode objfpc}{$H+}

uses
  Interfaces, // this includes the LCL widgetset
  Forms, mainform, laz_fpspreadsheet_visual,
sCSVParamsForm, sCtrls, sFormatSettingsForm, sSortParamsForm;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  MainFrm.BeforeRun;
  Application.CreateForm(TFormatSettingsForm, FormatSettingsForm);
  Application.CreateForm(TSortParamsForm, SortParamsForm);
  Application.Run;
end.

