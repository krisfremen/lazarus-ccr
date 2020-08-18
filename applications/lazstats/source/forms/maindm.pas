unit MainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Controls, LazHelpCHM;

type

  { TMainDataModule }

  TMainDataModule = class(TDataModule)
    ImageList: TImageList;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    CHMHelpDatabase: TCHMHelpDatabase;
    LHelpConnector: TLHelpConnector;

  end;

var
  MainDataModule: TMainDataModule;

implementation

{ TMainDataModule }

procedure TMainDataModule.DataModuleCreate(Sender: TObject);
begin
  CHMHelpDatabase := TCHMHelpDatabase.Create(self);
  CHMHelpDatabase.KeywordPrefix := 'html';
  CHMHelpDatabase.AutoRegister := true;

  LHelpConnector := TLHelpConnector.Create(self);
  LHelpConnector.AutoRegister := true;
end;

initialization
  {$I maindm.lrs}

end.

