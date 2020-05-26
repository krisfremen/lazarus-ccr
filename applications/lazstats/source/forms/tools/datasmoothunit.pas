unit DataSmoothUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, DictionaryUnit, ContextHelpUnit;

type

  { TSmoothDataForm }

  TSmoothDataForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    CloseBtn: TButton;
    HelpBtn: TButton;
    Label3: TLabel;
    ComputeBtn: TButton;
    Label4: TLabel;
    Memo1: TLabel;
    RepeatEdit: TEdit;
    Label1: TLabel;
    ResetBtn: TButton;
    VariableEdit: TEdit;
    InBtn: TBitBtn;
    Label2: TLabel;
    OutBtn: TBitBtn;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  SmoothDataForm: TSmoothDataForm;

implementation

uses
  Math;

{ TSmoothDataForm }

procedure TSmoothDataForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  RepeatEdit.Text := '1';
  VariableEdit.Text := '';
  UpdateBtnStates;
end;

procedure TSmoothDataForm.InBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (VariableEdit.Text = '') then
  begin
    VariableEdit.Text := VarList.Items.Strings[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TSmoothDataForm.ComputeBtnClick(Sender: TObject);
var
  DataPts, OutPts: DblDyneVec;
  value, avg: double;
  VarCol, N, Reps, i, j, col: integer;
  varlabel, strvalue: string;
begin
  N := NoCases;
  SetLength(DataPts, N);
  SetLength(OutPts, N);
  if not TryStrToInt(RepeatEdit.Text, Reps) or (Reps <= 0) then
  begin
    RepeatEdit.SetFocus;
    MessageDlg('Valid positive number required.', mtError, [mbOK], 0);
    exit;
  end;

  varlabel := VariableEdit.Text;
  for i := 1 to NoVariables do
    if varlabel = OS3MainFrm.DataGrid.Cells[i,0] then VarCol := i;

  for i := 1 to N do
  begin
    value := StrToFloat(OS3MainFrm.DataGrid.Cells[VarCol,i]);
    DataPts[i-1] := value;
  end;

  // repeat smoothing for Reps times
  OutPts[0] := DataPts[0];
  OutPts[N-1] := DataPts[N-1];
  for j := 1 to Reps do
  begin
    for i := 1 to N-2 do
    begin
      avg := (DataPts[i-1] + DataPts[i] + DataPts[i+1]) / 3.0;
      OutPts[i] := avg;
    end;
    if j < Reps then
      for i := 0 to N-1 do DataPts[i] := OutPts[i];
  end;

  // Create a new variable and copy smoothed data into it.
  strvalue := 'Smoothed';
  col := NoVariables + 1;
  DictionaryFrm.NewVar(NoVariables+1);
  DictionaryFrm.DictGrid.Cells[1, NoVariables] := strvalue;
  OS3MainFrm.DataGrid.Cells[NoVariables, 0] := strvalue;
  for i := 0 to N-1 do
    OS3MainFrm.DataGrid.Cells[col, i+1] := FloatToStr(OutPts[i]);
end;

procedure TSmoothDataForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ComputeBtn.Width, ResetBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := (Label1.Width + RepeatEdit.Width + Label3.Width) * 2;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TSmoothDataForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TSmoothDataForm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TSmoothDataForm.OutBtnClick(Sender: TObject);
begin
  if VariableEdit.Text <> '' then
  begin
    VarList.Items.Add(VariableEdit.Text);
    VariableEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TSmoothDataForm.UpdateBtnStates;
begin
  InBtn.Enabled := (VarList.ItemIndex > -1) and (VariableEdit.Text = '');
  OutBtn.Enabled := (VariableEdit.Text <> '');
end;

initialization
  {$I datasmoothunit.lrs}

end.

