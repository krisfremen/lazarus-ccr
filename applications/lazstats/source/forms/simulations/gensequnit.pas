unit GenSeqUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Globals,
  MainUnit, DictionaryUnit;


type

  { TGenSeqFrm }

  TGenSeqFrm = class(TForm)
    Bevel1: TBevel;
    NoCasesEdit: TEdit;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    LabelEdit: TEdit;
    Label3: TLabel;
    StartAtEdit: TEdit;
    IncrEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    RadioGroup1: TRadioGroup;
    StaticText1: TStaticText;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    Ncases : integer;
  public
    { public declarations }
  end; 

var
  GenSeqFrm: TGenSeqFrm;

implementation

uses
  Math;

{ TGenSeqFrm }

procedure TGenSeqFrm.ResetBtnClick(Sender: TObject);
begin
  RadioGroup1.ItemIndex := 1;
  NoCasesEdit.Text := '';
  StartAtEdit.Text := '';
  IncrEdit.Text := '';
  LabelEdit.Text := '';
end;

procedure TGenSeqFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TGenSeqFrm.ComputeBtnClick(Sender: TObject);
var
  i, col: integer;
  First, Increment: double;
begin
  if RadioGroup1.ItemIndex = 1 then begin
    if NoCasesEdit.Text = '' then
    begin
      NoCasesEdit.Setfocus;
      MessageDlg('Number of cases to generate not specified.', mtError, [mbOK], 0);
      exit;
    end;
    if not TryStrToInt(NoCasesEdit.Text, NCases) or (NCases <= 0) then
    begin
      NoCasesEdit.SetFocus;
      MessageDlg('Number of cases must be a valid, positive integer.', mtError, [mbOK], 0);
      exit;
    end;
  end else
    NCases := NoCases;

  if (StartAtEdit.Text = '') or not TryStrToFloat(StartAtEdit.Text, First) then
  begin
    StartAtEdit.Setfocus;
    MessageDlg('No starting value provided.', mtError, [mbOK], 0);
    exit;
  end;

  if (IncrEdit.Text = '') then
  begin
    IncrEdit.SetFocus;
    MessageDlg('No increment value provided.', mtError, [mbOK], 0);
    exit;
  end;
  if not TryStrToFloat(IncrEdit.Text, Increment) or (Increment <= 0) then
  begin
    IncrEdit.SetFocus;
    MessageDlg('No valid increment value provided.', mtError, [mbOK], 0);
    exit;
  end;

  if LabelEdit.Text = '' then
  begin
    LabelEdit.SetFocus;
    MessageDlg('No variable label provided.', mtError, [mbOK], 0);
    exit;
  end;

  if NoCases < Ncases then
  begin
    OS3MainFrm.DataGrid.RowCount := NCases + 1;
    OS3MainFrm.NoCasesEdit.Text := IntToStr(NCases);
    NoCases := Ncases;
  end;

  if NoVariables <= 0 then // a new data file
  begin
    OS3MainFrm.DataGrid.ColCount := 2;
    OS3MainFrm.DataGrid.RowCount := Ncases + 1;
    for i := 1 to Ncases do
      OS3MainFrm.DataGrid.Cells[0,i] := format('Case %d',[i]);
    col := 1;
    DictionaryFrm.DictGrid.RowCount := 1;
    DictionaryFrm.DictGrid.ColCount := 8;
    DictionaryFrm.NewVar(col);
    DictionaryFrm.DictGrid.Cells[1,col] := LabelEdit.Text;
    OS3MainFrm.DataGrid.Cells[1,0] := LabelEdit.Text;
    DictionaryFrm.DictGrid.RowCount := 2;
    NoVariables := 1;
  end
  else // existing data file
  begin
    col := NoVariables + 1;
    DictionaryFrm.NewVar(col);
    DictionaryFrm.DictGrid.Cells[1,col] := LabelEdit.Text;
  end;

  First := StrToFloat(StartAtEdit.Text);
  Increment := StrToFloat(IncrEdit.Text);
  for i := 1 to Ncases do
  begin
    OS3MainFrm.DataGrid.Cells[col,i] := Format('%.3f', [First]);
    First := First + Increment;
  end;
  OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
end;

procedure TGenSeqFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TGenSeqFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TGenSeqFrm.RadioGroup1Click(Sender: TObject);
begin
  if RadioGroup1.ItemIndex = 0 then
  begin
    if NoCases <= 0 then
    begin
      MessageDlg('There are currently no cases.', mtError, [mbOK], 0);
      exit;
    end else
      Ncases := NoCases;
  end else
    NoCasesEdit.SetFocus;
end;

initialization
  {$I gensequnit.lrs}

end.

