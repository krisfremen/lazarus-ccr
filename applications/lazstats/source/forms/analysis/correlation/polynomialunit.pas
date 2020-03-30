unit PolynomialUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  ContextHelpUnit;

type

  { TPolynomialFrm }

  TPolynomialFrm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    HelpBtn: TButton;
    OKBtn: TButton;
    Panel1: TPanel;
    PolyEdit: TEdit;
    Label1: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  PolynomialFrm: TPolynomialFrm;

implementation

uses
  Math;

{ TPolynomialFrm }

procedure TPolynomialFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, CancelBtn.Width, OKBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  OKBtn.Constraints.MinWidth := w;
end;

procedure TPolynomialFrm.FormShow(Sender: TObject);
begin
    PolyEdit.Text := '1';
end;

procedure TPolynomialFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

initialization
  {$I polynomialunit.lrs}

end.

