unit RelChangeUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  ContextHelpUnit;

type

  { TRelChangeFrm }

  TRelChangeFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    OldRelEdit: TEdit;
    OldVarEdit: TEdit;
    NewVarEdit: TEdit;
    NewRelEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  RelChangeFrm: TRelChangeFrm;

implementation

uses
  Math;

{ TRelChangeFrm }

procedure TRelChangeFrm.ResetBtnClick(Sender: TObject);
begin
     OldRelEdit.Text := '';
     NewRelEdit.Text := '';
     OldVarEdit.Text := '';
     NewVarEdit.Text := '';
end;

procedure TRelChangeFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;

  FAutoSized := true;
end;

procedure TRelChangeFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TRelChangeFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TRelChangeFrm.ComputeBtnClick(Sender: TObject);
var
   OldRel, NewRel, OldVar, NewVar : double;
begin
     OldRel := StrToFloat(OldRelEdit.Text);
     OldVar := StrToFloat(OldVarEdit.Text);
     NewVar := StrToFloat(NewVarEdit.Text);
     NewRel := 1.0 - ((OldVar / NewVar) * (1.0 - OldRel));
     NewRelEdit.Text := FormatFloat('0.00000', NewRel);  //FloatToStr(NewRel);
end;


initialization
  {$I relchangeunit.lrs}

end.

