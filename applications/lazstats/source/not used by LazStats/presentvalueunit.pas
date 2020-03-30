unit PresentValueUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TPresentValueFrm }

  TPresentValueFrm = class(TForm)
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    FutureEdit: TEdit;
    PaymentEdit: TEdit;
    NPeriodsEdit: TEdit;
    RateEdit: TEdit;
    PresentEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    PayTimeGrp: TRadioGroup;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    function PresentValue(Rate: Extended; NPeriods: Integer; Payment, FutureValue:
      Extended; PaymentTime: TPaymentTime): Extended;

  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  PresentValueFrm: TPresentValueFrm;

implementation

{ TPresentValueFrm }

procedure TPresentValueFrm.ResetBtnClick(Sender: TObject);
begin
  FutureEdit.Text := '';
  PaymentEdit.Text := '';
  NPeriodsEdit.Text := '';
  RateEdit.Text := '';
  PresentEdit.Text := '';
end;

procedure TPresentValueFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TPresentValueFrm.ComputeBtnClick(Sender: TObject);
VAR
     Rate, Payment, PresentVal, FutureVal, Interest : Extended;
     NPeriods, When : integer;
     Time : TPaymentTime;

begin
     If PayTimeGrp.ItemIndex = 0 then Time := ptStartofPeriod else
        Time := ptEndofPeriod;
     FutureVal := StrToFloat(FutureEdit.Text);
     Rate := StrToFloat(RateEdit.Text);
     NPeriods := StrToInt(NPeriodsEdit.Text);
     Payment := StrToFloat(PaymentEdit.Text);
     PresentVal := PresentValue(Rate, NPeriods, Payment, FutureVal, Time);
     PresentEdit.Text := FloatToStr(PresentVal);

end;

function TPresentValueFrm.PresentValue(Rate: Extended; NPeriods: Integer; Payment, FutureValue:
  Extended; PaymentTime: TPaymentTime): Extended;
var
  Annuity, CompoundRN: Extended;
begin
  if Rate <= -1.0 then ShowMessage('ERROR! PresentValue Rate <= -1.-');
  Annuity := Annuity2(Rate, NPeriods, PaymentTime, CompoundRN);
  if CompoundRN > 1.0E16 then
    PresentValue := -(Payment / Rate * Integer(PaymentTime) * Payment)
  else
    PresentValue := (-Payment * Annuity - FutureValue) / CompoundRN
end;

initialization
  {$I presentvalueunit.lrs}

end.

