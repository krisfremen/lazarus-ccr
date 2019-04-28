program BmpAnimDemo;

uses
  Interfaces,
  Forms,
  BmpAnimMainFormU in 'BmpAnimMainFormU.pas' {BmpAnimMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TBmpAnimMainForm, BmpAnimMainForm);
  Application.Run;
end.
