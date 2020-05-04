unit FFTUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TFFTFrm }

  TFFTFrm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    Memo1: TLabel;
    OKBtn: TButton;
    NptsEdit: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FFTFrm: TFFTFrm;

implementation

uses
  Math;

{ TFFTFrm }

procedure TFFTFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([CancelBtn.Width, OKBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  OKBtn.Constraints.MinWidth := w;
end;

procedure TFFTFrm.OKBtnClick(Sender: TObject);
var
  n: Integer;
begin
  if NptsEdit.Text = '' then
  begin
    NptsEdit.SetFocus;
    MessageDlg('Number of points not specified.', mtError, [mbOK], 0);
    ModalResult := mrNone;
  end else
  if not TryStrToInt(NptsEdit.Text, n) or (n <= 0) then
  begin
    NptsEdit.SetFocus;
    MessageDlg('Number of points must be a valid and positive integer.', mtError, [mbOK], 0);
    ModalResult := mrNone;
  end;
end;

initialization
  {$I fftunit.lrs}

end.

