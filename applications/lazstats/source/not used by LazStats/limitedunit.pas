unit LimitedUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TLimitedForm }

  TLimitedForm = class(TForm)
    ReturnBtn: TButton;
    Memo1: TMemo;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  LimitedForm: TLimitedForm;

implementation

initialization
  {$I limitedunit.lrs}

end.

