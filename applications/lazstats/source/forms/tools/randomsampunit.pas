unit RandomSampUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TRandomSampFrm }

  TRandomSampFrm = class(TForm)
    ResetBtn: TButton;
    CancelBtn: TButton;
    OKBtn: TButton;
    CasesEdit: TEdit;
    ExactEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PcntEdit: TEdit;
    GroupBox1: TGroupBox;
    ApproxBtn: TRadioButton;
    ExactBtn: TRadioButton;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  RandomSampFrm: TRandomSampFrm;

implementation

uses
  Math;

{ TRandomSampFrm }

procedure TRandomSampFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, CancelBtn.Width, OKBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  OKBtn.Constraints.MinWidth := w;
end;

procedure TRandomSampFrm.FormShow(Sender: TObject);
begin
     PcntEdit.Text := '';
     ExactEdit.Text := '';
     CasesEdit.Text := '';
     ApproxBtn.Checked := true;
end;

procedure TRandomSampFrm.ResetBtnClick(Sender: TObject);
begin
     FormShow(self);
end;

initialization
  {$I randomsampunit.lrs}

end.

