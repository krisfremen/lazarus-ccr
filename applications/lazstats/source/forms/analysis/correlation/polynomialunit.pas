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
    procedure HelpBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { private declarations }
    function GetOrder: Integer;
    procedure SetOrder(const AValue: Integer);
  public
    { public declarations }
    property Order: Integer read GetOrder write SetOrder;
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

function TPolynomialFrm.GetOrder: Integer;
begin
  Result := StrToInt(PolyEdit.Text);
end;

procedure TPolynomialFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TPolynomialFrm.OKBtnClick(Sender: TObject);
var
  n: Integer;
begin
  if PolyEdit.Text = '' then
  begin
    PolyEdit.SetFocus;
    MessageDlg('Polynomial order not specified.', mtError, [mbOK], 0);
    ModalResult := mrNone;
  end else
  if not TryStrToInt(PolyEdit.Text, n) or (n < 0) then
  begin
    PolyEdit.SetFocus;
    MessageDlg('Polynomial order must be a valid integer > 0', mtError, [mbOK], 0);
    ModalResult := mrNone;
  end;
end;

procedure TPolynomialFrm.SetOrder(const AValue: Integer);
begin
  PolyEdit.Text := IntToStr(AValue);
end;

initialization
  {$I polynomialunit.lrs}

end.

