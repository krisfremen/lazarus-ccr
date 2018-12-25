
{**********************************************************************
 Package industrial Lazarus
 
 This unit is part of Lazarus Project
***********************************************************************}

unit AllIndustrialRegister;

interface


 uses
  Classes, LResources, AdvLed, IndLed, LedNumber, Sensors, IndGnouMeter,
  A3nalogGauge, MKnob, Switches;

procedure Register;

implementation

{$R industrial_icons.res}

//==========================================================
procedure Register;
begin
  RegisterComponents ('Industrial',[
    TAdvLed, TIndLed, TLedNumber, TStopLightSensor,
    TAnalogSensor, TA3nalogGauge, TindGnouMeter, TmKnob, TOnOffSwitch
  ]);

end;

end.
