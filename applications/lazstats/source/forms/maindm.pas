unit MainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Controls, LazHelpCHM;

type

  { TMainDataModule }

  TMainDataModule = class(TDataModule)
    CHMHelpDatabase: TCHMHelpDatabase;
    ImageList: TImageList;
    LHelpConnector: TLHelpConnector;
  private

  public

  end;

var
  MainDataModule: TMainDataModule;

implementation

initialization
  {$I maindm.lrs}

end.

