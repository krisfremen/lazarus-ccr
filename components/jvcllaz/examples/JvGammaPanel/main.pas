unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, JvGammaPanel,
  JvTypes;

type

  { TDemoForm }

  TDemoForm = class(TForm)
    JvGammaPanel1: TJvGammaPanel;
    DemoLabel: TLabel;
    procedure JvGammaPanel1ChangeColor(Sender: TObject; Foreground,
      Background: TColor);
  private

  public

  end;

var
  DemoForm: TDemoForm;

implementation

{$R *.lfm}

{ TDemoForm }

procedure TDemoForm.JvGammaPanel1ChangeColor(Sender: TObject; Foreground,
  Background: TColor);
begin
  DemoLabel.Color := Background;
  DemoLabel.Font.Color := Foreground;
end;

end.

