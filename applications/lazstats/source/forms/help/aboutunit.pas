unit AboutUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TAboutBox }

  TAboutBox = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OKButton: TButton;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

procedure ShowAboutBox;


implementation

uses
  Types;

procedure ShowAboutBox;
begin
  with TAboutBox.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

{ TAboutBox }

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  Image1.Picture.Icon := Application.Icon;
  Image1.Picture.Icon.Current := Application.Icon.GetBestIndexForSize(Size(256,256));
end;


initialization
  {$I aboutunit.lrs}

end.
 
