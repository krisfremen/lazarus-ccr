unit ExpSmoothUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TExpSmoothFrm }

  TExpSmoothFrm = class(TForm)
    AlphaEdit: TEdit;
    Bevel1: TBevel;
    CancelBtn: TButton;
    OKBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    AlphaScroll: TScrollBar;
    procedure AlphaScrollChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    alpha : double;
  end; 

var
  ExpSmoothFrm: TExpSmoothFrm;

implementation

uses
  Math;

{ TExpSmoothFrm }

procedure TExpSmoothFrm.FormActivate(Sender: TObject);
begin
  OKBtn.Constraints.MinWidth := MaxValue([OKBtn.Width, CancelBtn.Width]);
  CancelBtn.Constraints.MinWidth := OKBtn.Constraints.MinWidth;
end;

procedure TExpSmoothFrm.FormShow(Sender: TObject);
begin
    AlphaEdit.Text := '0.99';
    AlphaScroll.Position := 99;
    alpha := 0.99;
end;

procedure TExpSmoothFrm.AlphaScrollChange(Sender: TObject);
begin
    AlphaEdit.Text := FloatToStr(AlphaScroll.Position / 100.0);
    alpha := AlphaScroll.Position / 100.0;
end;


initialization
  {$I expsmoothunit.lrs}

end.

