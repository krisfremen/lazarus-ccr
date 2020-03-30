unit InverseZUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  Functionslib;

type

  { TInversezForm }

  TInversezForm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ReturnBtn: TButton;
    ZEdit: TEdit;
    Label2: TLabel;
    ProbEdit: TEdit;
    Label1: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  InversezForm: TInversezForm;

implementation

uses
  Math;

{ TInversezForm }

procedure TInversezForm.ResetBtnClick(Sender: TObject);
begin
   ProbEdit.Text := '';
   ZEdit.Text := '';
end;

procedure TInversezForm.ComputeBtnClick(Sender: TObject);
VAR
  Prob, Zscore : double;
  outvalue : string;
begin
  Prob := StrToFloat(ProbEdit.Text);
  Zscore := inversez(Prob);
  outvalue := format('%6.4f',[Zscore]);
  ZEdit.Text := outvalue;
end;

procedure TInversezForm.FormActivate(Sender: TObject);
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
  {$I inversezunit.lrs}

end.

