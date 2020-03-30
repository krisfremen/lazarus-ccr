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

initialization
  {$I fftunit.lrs}

end.

