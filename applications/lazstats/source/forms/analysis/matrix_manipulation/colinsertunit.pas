unit ColInsertUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TColInsertFrm }

  TColInsertFrm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    ReturnBtn: TButton;
    GridNoEdit: TEdit;
    BeforeColEdit: TEdit;
    AfterColEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  ColInsertFrm: TColInsertFrm;

implementation

uses
  Math, MatManUnit;

{ TColInsertFrm }

procedure TColInsertFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([CancelBtn.Width, ReturnBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure TColInsertFrm.FormCreate(Sender: TObject);
begin
  if MatManFrm = nil then
    Application.CreateForm(TMatManFrm, MatManFrm);
end;

procedure TColInsertFrm.FormShow(Sender: TObject);
begin
  AfterColEdit.Text := '';
  BeforeColEdit.Text := '';
  GridNoEdit.Text := matmanfrm.GridNoEdit.Text;
end;

initialization
  {$I colinsertunit.lrs}

end.

