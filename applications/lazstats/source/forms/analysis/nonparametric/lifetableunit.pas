unit LifeTableUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Grids,
  MainUnit, Globals, FunctionsLib, OutputUnit,
  GraphLib, ContextHelpUnit;

type

  { TLifeTableForm }

  TLifeTableForm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    CIEdit: TEdit;
    Label7: TLabel;
    Memo1: TLabel;
    NoCensoredEdit: TEdit;
    Label6: TLabel;
    NoDiedEdit: TEdit;
    Label5: TLabel;
    NoAliveEdit: TEdit;
    Label4: TLabel;
    ObsEndEdit: TEdit;
    Label3: TLabel;
    ObsStartEdit: TEdit;
    Label2: TLabel;
    ObsStartInBtn: TBitBtn;
    ObsEndInBtn: TBitBtn;
    AliveInBtn: TBitBtn;
    NoDiedInBtn: TBitBtn;
    NoCensoredInBtn: TBitBtn;
    ObsStartOutBtn: TBitBtn;
    ObsEndOutBtn: TBitBtn;
    AliveOutBtn: TBitBtn;
    NoDiedOutBtn: TBitBtn;
    NoCensoredOutBtn: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    Label1: TLabel;
    Grid: TStringGrid;
    Splitter1: TSplitter;
    VarList: TListBox;
    procedure AliveInBtnClick(Sender: TObject);
    procedure AliveOutBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure NoCensoredInBtnClick(Sender: TObject);
    procedure NoCensoredOutBtnClick(Sender: TObject);
    procedure NoDiedInBtnClick(Sender: TObject);
    procedure NoDiedOutBtnClick(Sender: TObject);
    procedure ObsEndInBtnClick(Sender: TObject);
    procedure ObsEndOutBtnClick(Sender: TObject);
    procedure ObsStartInBtnClick(Sender: TObject);
    procedure ObsStartOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  LifeTableForm: TLifeTableForm;

implementation

uses
  Math;

{ TLifeTableForm }

procedure TLifeTableForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := True;
end;

procedure TLifeTableForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  CIEdit.Text := FormatFloat('0.00', DEFAULT_CONFIDENCE_LEVEL_PERCENT * 0.01);
end;

procedure TLifeTableForm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TLifeTableForm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TLifeTableForm.NoCensoredInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (NoCensoredEdit.Text = '') then
  begin
    NoCensoredEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.NoCensoredOutBtnClick(Sender: TObject);
begin
  if NoCensoredEdit.Text <> '' then
  begin
    VarList.Items.Add(NoCensoredEdit.Text);
    NoCensoredEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.NoDiedInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (NoDiedEdit.Text = '') then
  begin
    NoDiedEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.NoDiedOutBtnClick(Sender: TObject);
begin
  if NoDiedEdit.Text <> '' then
  begin
    VarList.Items.Add(NoDiedEdit.Text);
    NoDiedEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.AliveInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (NoAliveEdit.Text = '') then
  begin
    NoAliveEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.AliveOutBtnClick(Sender: TObject);
begin
  if NoAliveEdit.Text <> '' then
  begin
    VarList.Items.Add(NoAliveEdit.Text);
    NoAliveEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.ComputeBtnClick(Sender: TObject);
var
  i : integer;
  varcols : IntDyneVec;
  AtRisk, ProbDie, CumProbLive, StdErr, Up95, Low95 : double;
  N, P, Q, mu, CI, z : double;
  outline : string;
begin
  if ObsStartEdit.Text = '' then
  begin
    MessageDlg('Observation Start not specified.', mtError, [mbOK], 0);
    exit;
  end;

  if ObsEndEdit.Text = '' then
  begin
    MessageDlg('Observation End not specified.', mtError, [mbOK], 0);
    exit;
  end;

  if NoAliveEdit.Text = '' then
  begin
    MessageDlg('Number Alive not specified.', mtError, [mbOK], 0);
    exit;
  end;

  if NoDiedEdit.Text = '' then
  begin
    MessageDlg('Number Died not specified.', mtError, [mbOK], 0);
    exit;
  end;

  if NoCensoredEdit.Text = '' then
  begin
    MessageDlg('Number Censored not specified.', mtError, [mbOK], 0);
    exit;
  end;

  CI := StrToFloat(CIEdit.Text);
  z := InverseZ(CI);
  SetLength(varcols, 5);
  for i := 1 to 5 do
  begin
          if (OS3MainFrm.DataGrid.Cells[i,0] = ObsStartEdit.Text) then varcols[0] := i;
          if (OS3MainFrm.DataGrid.Cells[i,0] = ObsEndEdit.Text) then varcols[1] := i;
          if (OS3MainFrm.DataGrid.Cells[i,0] = NoAliveEdit.Text) then varcols[2] := i;
          if (OS3MainFrm.DataGrid.Cells[i,0] = NoDiedEdit.Text) then varcols[3] := i;
          if (OS3MainFrm.DataGrid.Cells[i,0] = NoCensoredEdit.Text) then varcols[4] := i;
  end;

  for i := 1 to NoCases do
  begin
          Grid.Cells[0,i] := 'CASE ' + IntToStr(i);
          Grid.Cells[1,i] := Trim(OS3MainFrm.DataGrid.Cells[varcols[0],i]);
          Grid.Cells[2,i] := Trim(OS3MainFrm.DataGrid.Cells[varcols[1],i]);
          Grid.Cells[3,i] := Trim(OS3MainFrm.DataGrid.Cells[varcols[2],i]);
          Grid.Cells[4,i] := Trim(OS3MainFrm.DataGrid.Cells[varcols[3],i]);
          Grid.Cells[5,i] := Trim(OS3MainFrm.DataGrid.Cells[varcols[4],i]);
  end;
  for i := 1 to NoCases do
  begin
          AtRisk := StrToFloat(Grid.Cells[3,i]);
          AtRisk := AtRisk - (StrToFloat(Grid.Cells[5,i]) / 2.0);
          Grid.Cells[6,i] := Format('%.4f', [AtRisk]);
          ProbDie := StrToFloat(Grid.Cells[4,i]) / AtRisk;
          Grid.Cells[7,i] := Format('%.4f', [ProbDie]);
          Grid.Cells[8,i] := Format('%.4f', [1.0-ProbDie]);
  end;

  N := StrToFloat(Grid.Cells[3,1]);
  Grid.Cells[9,1] := Grid.Cells[8,1];

  P := StrToFloat(Grid.Cells[9,1]);
  Q := 1.0 - P;
  StdErr := sqrt(N * P * Q);
  Grid.Cells[10,1] := format('%.4f', [StdErr]);

  mu := N * P;
  Grid.Cells[10,1] := Format('%.4f', [StdErr]);

  Up95 := mu + z * StdErr;
  Low95 := mu - z * StdErr;
  Grid.Cells[11,1] := Format('%.4f', [Low95]);
  Grid.Cells[12,1] := Format('%.4f', [Up95]);

  for i := 2 to NoCases do
  begin
          CumProbLive := StrToFloat(Grid.Cells[9,i-1]) * StrToFloat(Grid.Cells[8,i]);
          Grid.Cells[9,i] := Format('%.4f', [CumProbLive]);
          P := CumProbLive;
          Q := 1.0 - P;
          StdErr := sqrt(N * P * Q);
          mu := N * P;
          Grid.Cells[10,i] := Format('%.4f', [StdErr]);
          Up95 := mu + z * StdErr;
          Low95 := mu - z * StdErr;
          Grid.Cells[11,i] := Format('%.4f', [Low95]);
          Grid.Cells[12,i] := Format('%.4f', [Up95]);
  end;
  varcols := nil;
end;

procedure TLifeTableForm.ObsEndInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (OBsEndEdit.Text = '') then
  begin
    ObsEndEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.ObsEndOutBtnClick(Sender: TObject);
begin
  if ObsEndEdit.Text <> '' then
  begin
    VarList.Items.Add(ObsEndEdit.Text);
    ObsEndEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.ObsStartInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (ObsStartEdit.Text = '') then
  begin
    ObsStartEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.ObsStartOutBtnClick(Sender: TObject);
begin
  if ObsStartEdit.Text <> '' then
  begin
    VarList.Items.Add(ObsStartEdit.Text);
    ObsStartEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TLifeTableForm.ResetBtnClick(Sender: TObject);

VAR i : integer;
    j : integer;
begin
//  outline := format('NoCases = %d',[NoCases]);
//  ShowMessage(outline);
//  outline := format('No.Variables = %d',[NoVariables]);
//  ShowMessage(outline);
  VarList.Clear;
  ObsStartEdit.Text := '';
  ObsEndEdit.Text := '';
  NoAliveEdit.Text := '';
  NoDiedEdit.Text := '';
  NoCensoredEdit.Text := '';
  Grid.RowCount := NoCases+1;
  Grid.ColCount := 13;
  Grid.Cells[1,0] := 'Obs.Start';
  Grid.Cells[2,0] := 'Obs.End';
  Grid.Cells[3,0] := 'Alive';
  Grid.Cells[4,0] := 'Died';
  Grid.Cells[5,0] := 'Censored';
  Grid.Cells[6,0] := 'At Risk';
  Grid.Cells[7,0] := 'Prob.Die';
  Grid.Cells[8,0] := 'Prob.Alive';
  Grid.Cells[9,0] := 'Cum.P.Alive';
  Grid.Cells[10,0] := 'S.E. Alive';
  Grid.Cells[11,0] := 'Low 95%';
  Grid.Cells[12,0] := 'Hi 95%';
  for i := 0 to 12 do
    for j := 1 to NoCases do Grid.Cells[i,j] := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TLifeTableForm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TLifeTableForm.UpdateBtnStates;
begin
  ObsStartInBtn.Enabled := (VarList.ItemIndex > -1) and (ObsStartEdit.Text = '');
  ObsEndInBtn.Enabled := (VarList.ItemIndex > -1) and (ObsEndEdit.Text = '');
  AliveInBtn.Enabled := (VarList.ItemIndex > -1) and (NoAliveEdit.Text = '');
  NoDiedInBtn.Enabled := (VarList.itemIndex > -1) and (NoDiedEdit.Text = '');
  NoCensoredInBtn.Enabled := (VarList.ItemIndex > -1) and (NoCensoredEdit.Text = '');

  ObsStartOutBtn.Enabled := (ObsStartEdit.Text <> '');
  ObsEndOutBtn.Enabled := (ObsEndEdit.Text > '');
  AliveOutBtn.Enabled := (NoAliveEdit.Text <> '');
  NoDiedOutBtn.Enabled := (NoDiedEdit.Text <> '');
  NoCensoredOutBtn.Enabled := (NoCensoredEdit.Text > '');
end;

initialization
  {$I lifetableunit.lrs}

end.

