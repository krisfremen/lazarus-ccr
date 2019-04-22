unit u_industrial;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IndLed, Sensors, LedNumber, IndGnouMeter, AdvLed,
  A3nalogGauge, indSliders, Forms, Controls, Graphics, Dialogs, Arrow, ComCtrls,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    A3nalogGauge1: TA3nalogGauge;
    AdvLed1: TAdvLed;
    AnalogSensor1: TAnalogSensor;
    Arrow1: TArrow;
    ComboBox1: TComboBox;
    indGnouMeter1: TindGnouMeter;
    indLed1: TindLed;
    LEDNumber1: TLEDNumber;
    MultiSlider1: TMultiSlider;
    StopLightSensor1: TStopLightSensor;
    procedure ComboBox1Change(Sender: TObject);
    procedure MultiSlider1PositionChange(Sender: TObject; AKind: TThumbKind;
      AValue: Integer);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MultiSlider1PositionChange(Sender: TObject; AKind: TThumbKind;
  AValue: Integer);
begin
  case AKind of
    tkValue:
      begin
        A3nalogGauge1.Position := MultiSlider1.Position;
        indGnouMeter1.Value := MultiSlider1.Position;
        AnalogSensor1.Value := MultiSlider1.Position;
      end;
    tkMin:
      begin
        A3nalogGauge1.IndMinimum := MultiSlider1.MinPosition;
        AnalogSensor1.ValueRed := MultiSlider1.MinPosition;
      end;
    tkMax:
      begin
        A3nalogGauge1.IndMaximum := MultiSlider1.MaxPosition;
        AnalogSensor1.ValueYellow := MultiSlider1.MaxPosition;
      end;
  end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  AnalogSensor1.AnalogKind := TAnalogKind(ComboBox1.ItemIndex);
end;

end.

