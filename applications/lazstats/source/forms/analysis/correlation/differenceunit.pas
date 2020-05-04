unit DifferenceUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, contexthelpunit;

type

  { TDifferenceFrm }

  TDifferenceFrm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    HelpBtn: TButton;
    OKBtn: TButton;
    LagEdit: TEdit;
    OrderEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { private declarations }
    function Validate(out AMsg: String; out AControl: TWinControl): boolean;
  public
    { public declarations }
  end; 

var
  DifferenceFrm: TDifferenceFrm;

implementation

uses
  Math;

{ TDifferenceFrm }

procedure TDifferenceFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, CancelBtn.Width, OKBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  OKBtn.Constraints.MinWidth := w;
end;

procedure TDifferenceFrm.FormShow(Sender: TObject);
begin
  LagEdit.Text := '1';
  OrderEdit.Text := '1';
end;

procedure TDifferenceFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TDifferenceFrm.OKBtnClick(Sender: TObject);
var
  msg: String;
  C: TWinControl;
begin
  if not Validate(msg, C) then
  begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    ModalResult := mrNone;
  end;
end;

function TDifferenceFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
begin
  Result := false;
  if LagEdit.Text = '' then
  begin
    AMsg := 'Input required.';
    AControl := LagEdit;
    exit;
  end;
  if not TryStrToInt(LagEdit.Text, n) or (n < 0) then
  begin
    AMsg := 'Non-negative integer value required.';
    AControl := LagEdit;
    exit;
  end;

  if OrderEdit.Text = '' then
  begin
    AMsg := 'Input required.';
    AControl := OrderEdit;
    exit;
  end;
  if not TryStrToInt(OrderEdit.Text, n) or (n < 0) then
  begin
    AMsg := 'Non-negative integer value required.';
    AControl := OrderEdit;
    exit;
  end;

  Result := true;
end;


initialization
  {$I differenceunit.lrs}

end.

