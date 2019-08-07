program JvTimeFrameDemo;

{%File 'dbUTF'}

uses
  InterfaceBase, SysUtils, Dialogs,
  Forms, datetimectrls, printer4lazarus, Interfaces,
  tfMain in 'PhotoOpUnit.pas' {PhotoOpMain},
  tfVisibleResources in 'VisibleResourcesUnit.pas' {VisibleResources},
  tfShare in 'ShareUnit.pas' {Share},
  tfApptEdit in 'ApptEditUnit.pas' {ApptEdit},
  tfPrintProgress in 'PrintProgressUnit.pas' {PrintProgress};

{$R *.res}

var
  fn: String;
begin
  Application.Scaled:=True;
  Application.Initialize;

  fn := Application.Location + 'data.sqlite';
  if not FileExists(fn) then begin
    MessageDlg('Database file "' + fn + '" not found. Copy it from the source directory to here.',
      mtError, [mbOK], 0);
    Halt;
  end;

  Application.CreateForm(TPhotoOpMain, PhotoOpMain);
  Application.CreateForm(TVisibleResources, VisibleResources);
  Application.CreateForm(TShare, Share);
  Application.CreateForm(TApptEdit, ApptEdit);
  Application.CreateForm(TPrintProgress, PrintProgress);
  Application.Run;
end.
