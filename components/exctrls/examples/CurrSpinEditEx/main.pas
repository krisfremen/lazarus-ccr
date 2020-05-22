unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  SpinEx, ExEditCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    Bevel1: TBevel;
    sePayment: TCurrSpinEditEx;
    seFutureValue: TCurrSpinEditEx;
    seInterestRate: TFloatSpinEditEx;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    seYears: TSpinEditEx;
    procedure Calculate(Sender: TObject);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  Math;

procedure TMainForm.Calculate(Sender: TObject);
begin
  seFutureValue.Value := -FutureValue(seInterestRate.Value/100, seYears.Value, sePayment.Value*12, 0.0, ptEndOfPeriod);
end;

end.

