unit FProbUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  Functionslib;

type

  { TFForm }

  TFForm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    DF1Edit: TEdit;
    DF2Edit: TEdit;
    Panel1: TPanel;
    ProbEdit: TEdit;
    FEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
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
  FForm: TFForm;

implementation

uses
  Math;

{ TFForm }

procedure TFForm.ResetBtnClick(Sender: TObject);
begin
  FEdit.Text := '';
  DF1Edit.Text := '';
  DF2Edit.Text := '';
  ProbEdit.Text := '';
end;

procedure TFForm.ComputeBtnClick(Sender: TObject);
VAR
  F, df1, df2, prob : extended;
  outvalue : string;
begin
   F := StrToFloat(FEdit.Text);
   df1 := StrToFloat(DF1Edit.Text);
   df2 := StrToFloat(DF2Edit.Text);
   prob := probf(F,df1,df2);
   outvalue := format('%6.4f',[prob]);
   ProbEdit.Text := outvalue;
end;

procedure TFForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([CancelBtn.Width, ResetBtn.Width, ReturnBtn.Width, ComputeBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;


initialization
  {$I fprobunit.lrs}

end.

