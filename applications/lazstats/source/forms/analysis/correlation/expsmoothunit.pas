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
    procedure OKBtnClick(Sender: TObject);
  private
    { private declarations }
    FAlpha: Double;
    procedure SetAlpha(AValue: Double);
  public
    { public declarations }
    property Alpha: Double read FAlpha write SetAlpha;
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

procedure TExpSmoothFrm.OKBtnClick(Sender: TObject);
begin
  if AlphaEdit.Text = '' then
  begin
    AlphaEdit.SetFocus;
    MessageDlg('Alpha cannot be empty.', mtError, [mbOK], 0);
    ModalResult := mrNone;
  end else
  if not TryStrToFloat(AlphaEdit.Text, FAlpha) or (FAlpha < 0.0) or (FAlpha > 1.0) then
  begin
    AlphaEdit.SetFocus;
    MessageDlg('Alpha must be > 0 and < 1', mtError, [mbOK], 0);
    ModalResult := mrNone;
  end;
end;

procedure TExpSmoothFrm.SetAlpha(AValue: Double);
begin
  if (AValue = FAlpha) then exit;
  FAlpha := AValue;
  AlphaScroll.Position := Round(100 * FAlpha);
  AlphaEdit.Text := FormatFloat('0.00', FAlpha);
end;

procedure TExpSmoothFrm.AlphaScrollChange(Sender: TObject);
begin
  FAlpha := AlphaScroll.Position / 100.0;
  AlphaEdit.Text := FormatFloat('0.00', FAlpha);
end;


initialization
  {$I expsmoothunit.lrs}

end.

