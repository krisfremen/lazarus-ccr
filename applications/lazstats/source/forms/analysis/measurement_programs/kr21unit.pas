unit KR21Unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TKR21Frm }

  TKR21Frm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    NoItemsEdit: TEdit;
    MeanEdit: TEdit;
    StdDevEdit: TEdit;
    RelEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  KR21Frm: TKR21Frm;

implementation

{ TKR21Frm }

uses
  Math;

procedure TKR21Frm.ResetBtnClick(Sender: TObject);
begin
  NoItemsEdit.Text := '';
  MeanEdit.Text := '';
  StdDevEdit.Text := '';
  RelEdit.Text := '';
end;

procedure TKR21Frm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TKR21Frm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TKR21Frm.ComputeBtnClick(Sender: TObject);
var
  items, mean, stddev, rel: double;
begin
  items := StrToFloat(NoItemsEdit.Text);
  mean := StrToFloat(MeanEdit.Text);
  stddev := StrToFloat(StdDevEdit.Text);
  rel := (items / (items - 1.0)) * (1.0 - (mean * (items - mean))/(items * sqr(stddev)));
  RelEdit.Text := FormatFloat('0.00000', rel);
end;

initialization
  {$I kr21unit.lrs}

end.

