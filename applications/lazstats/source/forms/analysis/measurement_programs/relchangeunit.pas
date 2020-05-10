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
    Bevel2: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
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
  Math, Utils;

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

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

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
  oldRel, newRel, oldVar, newVar: double;
begin
  if (OldRelEdit.Text = '') or not TryStrToFloat(OldRelEdit.Text, oldRel) then
  begin
    OldRelEdit.SetFocus;
    ErrorMsg('Valid number required.');
    exit;
  end;
  if (OldVarEdit.Text = '') or not TryStrToFloat(OldVarEdit.Text, oldVar) then
  begin
    OldVarEdit.SetFocus;
    ErrorMsg('Valid number required.');
    exit;
  end;
  if (NewVarEdit.Text = '') or not TryStrToFloat(NewVarEdit.Text, newVar) then
  begin
    NewVarEdit.SetFocus;
    ErrorMsg('Valid number required.');
    exit;
  end;
  newRel := 1.0 - (oldVar / newVar) * (1.0 - oldRel);
  NewRelEdit.Text := FormatFloat('0.00000', newRel);
end;


initialization
  {$I relchangeunit.lrs}

end.

