unit SpBrUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  ContextHelpUnit;

type

  { TSpBrFrm }

  TSpBrFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    OldRelEdit: TEdit;
    MultKEdit: TEdit;
    NewRelEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  SpBrFrm: TSpBrFrm;

implementation

uses
  Math;

{ TSpBrFrm }

procedure TSpBrFrm.ResetBtnClick(Sender: TObject);
begin
  OldRelEdit.Text := '';
  NewRelEdit.Text := '';
  MultKEdit.Text := '';
end;

procedure TSpBrFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;
end;

procedure TSpBrFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TSpBrFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TSpBrFrm.ComputeBtnClick(Sender: TObject);
var
  oldrel, newrel, Factor : double;
begin
  oldrel := StrToFloat(OldRelEdit.Text);
  Factor := StrToFloat(MultKEdit.Text);
  newrel := (Factor * oldrel) / (1.0 + (Factor - 1.0) * oldrel);
  NewRelEdit.Text := FormatFloat('0.00000', NewRel);  //FloatToStr(newrel);
end;


initialization
  {$I spbrunit.lrs}

end.

