unit ProbChiSqrUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  FunctionsLib;

type

  { TChiSqrProbForm }

  TChiSqrProbForm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    ChiSqrEdit: TEdit;
    ComputeBtn: TButton;
    DFEdit: TEdit;
    Panel1: TPanel;
    ProbEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ResetBtn: TButton;
    ReturnBtn: TButton;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  ChiSqrProbForm: TChiSqrProbForm;

implementation

uses
  Math;

{ TChiSqrProbForm }

procedure TChiSqrProbForm.ResetBtnClick(Sender: TObject);
begin
  ChiSqrEdit.Text := '';
  DFEdit.Text := '';
  ProbEdit.Text := '';
end;

procedure TChiSqrProbForm.ComputeBtnClick(Sender: TObject);
VAR
  ChiSqr, Prob : double;
  DF : integer;
  outvalue : string;
begin
  ChiSqr := StrToFloat(ChiSqrEdit.Text);
  DF := StrToInt(DFEdit.Text);
  Prob := 1.0 - chisquaredprob(ChiSqr,DF);
  outvalue := format('%6.4f',[Prob]);
  ProbEdit.Text := outvalue;
end;

procedure TChiSqrProbForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([CancelBtn.Width, ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

initialization
  {$I probchisqrunit.lrs}

end.

