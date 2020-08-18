unit MainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Controls;

type

  { TMainDataModule }

  TMainDataModule = class(TDataModule)
    ImageList: TImageList;
  private

  public

  end;

var
  MainDataModule: TMainDataModule;

implementation

initialization
  {$I maindm.lrs}

end.

