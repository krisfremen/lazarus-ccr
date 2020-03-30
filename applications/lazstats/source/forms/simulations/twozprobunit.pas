unit TwoZProbUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  FunctionsLib;

type

  { TTwozProbForm }

  TTwozProbForm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    ProbEdit: TEdit;
    Label3: TLabel;
    Z2Edit: TEdit;
    Label2: TLabel;
    Z1Edit: TEdit;
    Label1: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  TwozProbForm: TTwozProbForm;

implementation

{ TTwozProbForm }

procedure TTwozProbForm.ResetBtnClick(Sender: TObject);
begin
  ProbEdit.Text := '';
  Z1Edit.Text := '';
  Z2Edit.Text := '';
end;

procedure TTwozProbForm.ComputeBtnClick(Sender: TObject);
VAR
  z1, z2, prob : double;
  outvalue : string;
begin
     z1 := StrToFloat(Z1Edit.Text);
     z2 := StrToFloat(Z2Edit.Text);
     if z1 < z2 then
     begin
       prob := probz(z2) - probz(z1);
     end;
     if z1 > z2 then
     begin
       prob := probz(z1) - probz(z2);
     end;
     outvalue := format('%6.4f',[prob]);
     ProbEdit.Text := outvalue;
end;

initialization
  {$I twozprobunit.lrs}

end.

