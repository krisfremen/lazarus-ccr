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
    NoCasesEdit: TEdit;
    Panel1: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    LabelEdit: TEdit;
    Label3: TLabel;
    StartAtEdit: TEdit;
    IncrEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    RadioGroup1: TRadioGroup;
    StaticText1: TStaticText;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NoCasesEditExit(Sender: TObject);
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
    i, col : integer;
    First, Increment : double;
begin
    if StartAtEdit.Text = '' then
    begin
        ShowMessage('Error! No starting value provided.');
        exit;
    end;
    if IncrEdit.Text = '' then
    begin
        ShowMessage('Error! No increment value provided.');
        exit;
    end;
    if LabelEdit.Text = '' then
    begin
        ShowMessage('Error! No variable label provided.');
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
        OS3MainFrm.DataGrid.Cells[col,i] := format('%8.3f',[First]);
        First := First + Increment;
    end;
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
end;

procedure TGenSeqFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TGenSeqFrm.NoCasesEditExit(Sender: TObject);
begin
    if RadioGroup1.ItemIndex = 1 then Ncases := StrToInt(NoCasesEdit.Text);
    if (Ncases <= 0) and (RadioGroup1.ItemIndex = 1) then
    begin
        ShowMessage('Error!  No. of cases to generate not specified.');
        exit;
    end;
end;

procedure TGenSeqFrm.RadioGroup1Click(Sender: TObject);
begin
    if RadioGroup1.ItemIndex = 0 then
    begin
        if NoCases <= 0 then
        begin
            ShowMessage('Error! There are currently no cases!');
            exit;
        end
        else Ncases := NoCases;
    end
    else NoCasesEdit.SetFocus;
end;

initialization
  {$I gensequnit.lrs}

end.

