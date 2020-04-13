unit SmoothDataUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, DictionaryUnit;

type

  { TDataSmoothingForm }

  TDataSmoothingForm = class(TForm)
    Bevel1: TBevel;
    Label3: TLabel;
    Memo1: TLabel;
    RepeatEdit: TEdit;
    RepeatChk: TCheckBox;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    SelectedEdit: TEdit;
    Label2: TLabel;
    VarInBtn: TBitBtn;
    VarOutBtn: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarInBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure VarOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  DataSmoothingForm: TDataSmoothingForm;

implementation

uses
  Math;

{ TDataSmoothingForm }

procedure TDataSmoothingForm.ResetBtnClick(Sender: TObject);
var
  i : integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  RepeatEdit.Text := '1';
  SelectedEdit.Text := '';
  UpdateBtnStates;
end;

procedure TDataSmoothingForm.ComputeBtnClick(Sender: TObject);
var
  DataPts, OutPts: DblDyneVec;
  N, Reps, i, j, VarCol: integer;
  VarLabel, strValue: string;
begin
  if SelectedEdit.Text = '' then
  begin
    MessageDlg('No variable selected.', mtError, [mbOk], 0);
    exit;
  end;

  if RepeatChk.Checked then
  begin
    if RepeatEdit.Text = '' then
    begin
      MessageDlg('Repeat count not specified.', mtError, [mbOK], 0);
      exit;
    end;
    if not TryStrToInt(RepeatEdit.Text, Reps) and (Reps < 1) then
    begin
      MessageDlg('Repeat count must be >= 1.', mtError, [mbOK], 0);
      exit;
    end;
  end else
    Reps := 1;

  N := NoCases;
  SetLength(DataPts,N);
  SetLength(OutPts,N);

  Varlabel := SelectedEdit.Text;
  for i := 1 to NoVariables do
    if VarLabel = OS3MainFrm.DataGrid.Cells[i,0] then VarCol := i;
  for i := 0 to N - 1 do
    DataPts[i] := StrToFloat(OS3MainFrm.DataGrid.Cells[VarCol,i+1]);

  // repeat smoothing for number of times elected
  OutPts[0] := DataPts[0];
  OutPts[N-1] := DataPts[N-1];
  for j := 1 to Reps do
  begin
    for i := 1 to N - 2 do
      OutPts[i] := (DataPts[i-1] + DataPts[i] + DataPts[i+1]) / 3.0;
    if j < reps then
      for i := 0 to N - 1 do DataPts[i] := OutPts[i];
  end;

  // create a new variable and copy smoothed data into it
  if Reps = 1 then
    strvalue := Format('%s_Smoothed', [VarLabel])
  else
    strvalue := Format('%s_Smoothed_%dx', [VarLabel, Reps]);
  DictionaryFrm.NewVar(NoVariables+1);
  DictionaryFrm.DictGrid.Cells[1,NoVariables] := strvalue;
  OS3MainFrm.DataGrid.Cells[NoVariables,0] := strvalue;
  for i := 0 to N - 1 do
    OS3MainFrm.DataGrid.Cells[NoVariables,i+1] := Format('%0.3f', [OutPts[i]]);

  // clean up
  OutPts := nil;
  DataPts := nil;
end;

procedure TDataSmoothingForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  FAutoSized := True;
end;

procedure TDataSmoothingForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TDataSmoothingForm.VarInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (SelectedEdit.Text = '') then
  begin
    SelectedEdit.Text := VarList.Items.Strings[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TDataSmoothingForm.VarListSelectionChange(Sender: TObject;
  User: boolean);
begin
  UpdateBtnStates;
end;

procedure TDataSmoothingForm.VarOutBtnClick(Sender: TObject);
begin
  if SelectedEdit.Text <>  '' then
  begin
    VarList.Items.Add(SelectedEdit.Text);
    SelectedEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TDataSmoothingForm.UpdateBtnStates;
begin
  VarInBtn.Enabled := (VarList.ItemIndex > -1) and (SelectedEdit.Text = '');
  VarOutBtn.Enabled := (SelectedEdit.Text <> '');
end;


initialization
  {$I smoothdataunit.lrs}

end.

