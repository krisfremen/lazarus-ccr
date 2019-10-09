unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, JvGammaPanel,
  JvTypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    JvGammaPanel1: TJvGammaPanel;
    StaticText1: TLabel;
    procedure JvGammaPanel1ChangeColor(Sender: TObject; Foreground,
      Background: TColor);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.JvGammaPanel1ChangeColor(Sender: TObject; Foreground,
  Background: TColor);
begin
  StaticText1.Color := Background;
  StaticText1.Font.Color := Foreground;
end;

end.

