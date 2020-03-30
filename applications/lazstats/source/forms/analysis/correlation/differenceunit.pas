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
  private
    { private declarations }
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

initialization
  {$I differenceunit.lrs}

end.

