program MetadataViewer;

uses
  Forms,
  mdvMain in 'mdvMain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  MainForm.BeforeRun;
  Application.Run;
end.

