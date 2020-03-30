unit GridHelpUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TGridHelpFrm }

  TGridHelpFrm = class(TForm)
    ReturnBtn: TButton;
    Memo1: TMemo;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  GridHelpFrm: TGridHelpFrm;

implementation

initialization
  {$I gridhelpunit.lrs}

end.

