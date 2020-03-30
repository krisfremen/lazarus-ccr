unit RangeSelectUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TRangeSelectFrm }

  TRangeSelectFrm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    Label4: TLabel;
    OKBtn: TButton;
    FirstCaseEdit: TEdit;
    LastCaseEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  RangeSelectFrm: TRangeSelectFrm;

implementation

uses
  Math;

{ TRangeSelectFrm }

procedure TRangeSelectFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([CancelBtn.Width, OKBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  OKBtn.Constraints.MinWidth := w;
end;

procedure TRangeSelectFrm.FormShow(Sender: TObject);
begin
     FirstCaseEdit.Text := '';
     LastCaseEdit.Text := '';
end;

initialization
  {$I rangeselectunit.lrs}

end.

