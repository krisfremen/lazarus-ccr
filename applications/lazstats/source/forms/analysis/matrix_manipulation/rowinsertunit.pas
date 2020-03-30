unit RowInsertUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TRowInsertFrm }

  TRowInsertFrm = class(TForm)
    BeforeEdit: TEdit;
    AfterEdit: TEdit;
    Bevel1: TBevel;
    CancelBtn: TButton;
    ReturnBtn: TButton;
    GridNoEdit: TEdit;
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
  RowInsertFrm: TRowInsertFrm;

implementation

uses
  Math, MatManUnit;

{ TRowInsertFrm }

procedure TRowInsertFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([CancelBtn.Width, ReturnBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure TRowInsertFrm.FormCreate(Sender: TObject);
begin
  if MatManFrm = nil then
    Application.CreateForm(TMatManFrm, MatManFrm);
end;

procedure TRowInsertFrm.FormShow(Sender: TObject);
begin
  BeforeEdit.Text := '';
  AfterEdit.Text := '';
  GridNoEdit.Text := matmanfrm.GridNoEdit.Text;
end;

initialization
  {$I rowinsertunit.lrs}

end.

