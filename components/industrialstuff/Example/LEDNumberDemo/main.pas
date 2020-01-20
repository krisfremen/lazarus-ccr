unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LedNumber;

type

  { TForm1 }

  TForm1 = class(TForm)
    Bevel1: TBevel;
    cbZeroToO: TCheckBox;
    cbSlanted: TCheckBox;
    edCaption: TEdit;
    lblSize: TLabel;
    lblCaption: TLabel;
    LEDNumber1: TLEDNumber;
    Panel1: TPanel;
    sbSize: TScrollBar;
    procedure cbSlantedChange(Sender: TObject);
    procedure cbZeroToOChange(Sender: TObject);
    procedure edCaptionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbSizeChange(Sender: TObject);
  private
    procedure UpdateLED;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.cbSlantedChange(Sender: TObject);
begin
  LEDNumber1.Slanted := cbSlanted.Checked;
end;

procedure TForm1.cbZeroToOChange(Sender: TObject);
begin
  LEDNumber1.ZeroToO := cbZeroToO.Checked;
end;

procedure TForm1.edCaptionChange(Sender: TObject);
begin
  UpdateLED;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  UpdateLED;
end;

procedure TForm1.sbSizeChange(Sender: TObject);
begin
  LEDNumber1.Size := sbSize.Position;
end;

procedure TForm1.UpdateLED;
var
  i, n: Integer;
begin
  n := 0;
  for i := 1 to Length(edCaption.Text) do
    if not (edCaption.Text[i] in ['.', ',']) then inc(n);
  LEDNumber1.Columns := n;
  LEDNumber1.Caption := edCaption.Text;
end;

end.

