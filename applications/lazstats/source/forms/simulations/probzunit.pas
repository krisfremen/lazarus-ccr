unit ProbZUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  FunctionsLib;

type

  { TProbzForm }

  TProbzForm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    ReturnBtn: TButton;
    CancelBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ProbzEdit: TEdit;
    Label2: TLabel;
    zEdit: TEdit;
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
  ProbzForm: TProbzForm;

implementation

uses
  Math;

{ TProbzForm }

procedure TProbzForm.ResetBtnClick(Sender: TObject);
begin
  zEdit.Text := '';
  ProbzEdit.Text := '';
end;

procedure TProbzForm.ComputeBtnClick(Sender: TObject);
VAR
   zprob, z : double;
   outvalue : string;
begin
   z := StrToFloat(zEdit.Text);
   zprob := 1.0 - probz(z);
   outvalue := format('%6.4f',[zprob]);
   ProbzEdit.Text := outvalue;
end;

procedure TProbzForm.FormActivate(Sender: TObject);
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
  {$I probzunit.lrs}

end.

