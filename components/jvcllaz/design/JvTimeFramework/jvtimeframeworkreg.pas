unit JvTimeFrameworkReg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure Register;

implementation

{$R ../../resource/jvtimeframeworkreg.res}

uses
  //Controls,
  JvDsgnConsts,
  JvTFGlance, JvTFGlanceTextViewer, JvTFMonths, JvTFWeeks, JvTFDays,
  JvTFAlarm, JvTFManager;

procedure Register;
begin
  RegisterComponents(RsPaletteJvclVisual, [
    TJvTFScheduleManager,
    TJvTFMonths, TJvTFWeeks, TJvTFDays, TJvTFAlarm, TJvTFGlanceTextViewer,
    TJvTFUniversalPrinter, TJvTFDaysPrinter
  ]);

//  RegisterPropertyEditor(TypeInfo(TJvTFGlanceCells, TJvTFMonths, 'Cells', nil);

  (*
//  RegisterPropertyEditor(TypeInfo(string), TJvTFControl, 'Version', TutfVersionEditor);
//  RegisterPropertyEditor(TypeInfo(string), TJvTFScheduleManager, 'Version', TutfVersionEditor);
  RegisterComponents(RsPaletteTimeFramework, [TJvTFGlanceTextViewer, TJvTFMonths,
    TJvTFWeeks, TJvTFAlarm]);
//  RegisterPropertyEditor(TypeInfo(TJvTFGlanceCells), '', 'Cells',
//    TJvTFGlanceCellsProperty);

  // register a nil property editor for now, so cells cannot be added,
  // deleted, or moved at design time... BAD THINGS HAPPEN
  RegisterPropertyEditor(TypeInfo(TJvTFGlanceCells), TJvTFMonths, 'Cells', nil);
  RegisterComponents(RsPaletteTimeFramework, [TJvTFDays, TJvTFDaysPrinter]);
*)
end;

end.

