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
    CancelBtn: TButton;
    HelpBtn: TButton;
    Label3: TLabel;
    ComputeBtn: TButton;
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
VAR i : integer;
begin
     VarList.Clear;
     for i := 1 to NoVariables do
        VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     RepeatEdit.Text := '1';
     VariableEdit.Text := '';
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
end;

procedure TSmoothDataForm.InBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     VariableEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     InBtn.Enabled := false;
     OutBtn.Enabled := true;
end;

procedure TSmoothDataForm.ComputeBtnClick(Sender: TObject);
VAR
  DataPts, OutPts : DblDyneVec;
  value, avg : double;
  VarCol, N, Reps, i, j, col : integer;
  varlabel, strvalue : string;
begin
     N := NoCases;
     SetLength(DataPts,N);
     SetLength(OutPts,N);
     Reps := StrToInt(RepeatEdit.Text);
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
     DictionaryFrm.DictGrid.Cells[1,NoVariables] := strvalue;
     OS3MainFrm.DataGrid.Cells[NoVariables,0] := strvalue;
     for i := 0 to N-1 do OS3MainFrm.DataGrid.Cells[col,i+1] := FloatToStr(OutPts[i]);
end;

procedure TSmoothDataForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ComputeBtn.Width, ResetBtn.Width, CancelBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TSmoothDataForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
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
  VarList.Items.Add(VariableEdit.Text);
  VariableEdit.Text := '';
  OutBtn.Enabled := false;
  InBtn.Enabled := true;
end;

initialization
  {$I datasmoothunit.lrs}

end.

