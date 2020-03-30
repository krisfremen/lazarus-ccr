unit ProbSmallerZUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  Functionslib;

type

  { TProbSmallerzForm }

  TProbSmallerzForm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    ProbzEdit: TEdit;
    ResetBtn: TButton;
    ReturnBtn: TButton;
    zEdit: TEdit;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  ProbSmallerzForm: TProbSmallerzForm;

implementation

uses
  Math;

{ TProbSmallerzForm }

procedure TProbSmallerzForm.ResetBtnClick(Sender: TObject);
begin
    zEdit.Text := '';
    ProbzEdit.Text := '';
end;

procedure TProbSmallerzForm.ComputeBtnClick(Sender: TObject);
VAR
   zprob, z : double;
   outvalue : string;
begin
    z := StrToFloat(zEdit.Text);
    zprob := probz(z);
    outvalue := format('%6.4f',[zprob]);
    ProbzEdit.Text := outvalue;
end;

procedure TProbSmallerzForm.FormActivate(Sender: TObject);
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
  {$I probsmallerzunit.lrs}

end.

