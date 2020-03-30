unit AboutUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TAboutBox }

  TAboutBox = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OKButton: TButton;
    Panel1: TPanel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

procedure ShowAboutBox;


implementation

procedure ShowAboutBox;
begin
  with TAboutBox.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;


initialization
  {$I aboutunit.lrs}

end.
 
