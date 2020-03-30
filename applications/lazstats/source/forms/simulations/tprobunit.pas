unit tProbUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  Functionslib;

type

  { TTprobForm }

  TTprobForm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    Panel1: TPanel;
    tValueEdit: TEdit;
    ComputeBtn: TButton;
    DFEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ProbEdit: TEdit;
    ResetBtn: TButton;
    ReturnBtn: TButton;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  TprobForm: TTprobForm;

implementation

uses
  Math;

{ TTprobForm }

procedure TTprobForm.ResetBtnClick(Sender: TObject);
begin
  tValueEdit.Text := '';
  DFEdit.Text := '';
  ProbEdit.Text := '';
end;

procedure TTprobForm.ComputeBtnClick(Sender: TObject);
VAR
  tvalue, dfvalue, prob : double;
  outvalue : string;
begin
  tvalue := StrToFloat(tValueEdit.Text);
  dfvalue := StrToFloat(DFEdit.Text);
  if tvalue >= 0.0 then prob := 0.5 * probt(tvalue,dfvalue);
  if tvalue < 0.0 then prob :=  1.0 - probt(tvalue,dfvalue) +
     (0.5 * probt(tvalue,dfvalue)) ;
  if tvalue = 0.0 then prob := 0.50;
  outvalue := format('%6.4f',[prob]);
  ProbEdit.Text := outvalue;
end;

procedure TTprobForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([CancelBtn.Width, ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

initialization
  {$I tprobunit.lrs}

end.

