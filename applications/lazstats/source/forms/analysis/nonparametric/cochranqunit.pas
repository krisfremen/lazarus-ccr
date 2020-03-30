unit CochranQUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, OutputUnit, DataProcs, FunctionsLib, contexthelpunit;

type

  { TCochranQFrm }

  TCochranQFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    InBtn: TBitBtn;
    Label2: TLabel;
    SelList: TListBox;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
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
  CochranQFrm: TCochranQFrm;

implementation

uses
  Math;

{ TCochranQFrm }

procedure TCochranQFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  SelList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TCochranQFrm.FormActivate(Sender: TObject);
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

  FAutoSized := true;
end;

procedure TCochranQFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TCochranQFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TCochranQFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TCochranQFrm.AllBtnClick(Sender: TObject);
var
  index: integer;
begin
  for index := 0 to VarList.Items.Count - 1 do
    SelList.Items.Add(VarList.Items[index]);
  UpdateBtnStates;
end;

procedure TCochranQFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k, col : integer;
   ColNoSelected : IntDyneVec;
   R1, L1, L2, C1, g1, Q, g2, chiprob : double;
   cellstring, outline : string;
   lReport: TStrings;
begin
  if SelList.Items.Count = 0 then
  begin
    MessageDlg('No variable(s) selected.', mtError, [mbOK], 0);
    exit;
  end;

  SetLength(ColNoSelected,NoVariables);
  C1 := 0.0;
  k := SelList.Items.Count;

  // Get column numbers and labels of variables selected
  for i := 1 to k do
  begin
    cellstring := SelList.Items.Strings[i-1];
    for j := 1 to NoVariables do
      if (cellstring = OS3MainFrm.DataGrid.Cells[j,0]) then
        ColNoSelected[i-1] := j;
  end;

  // Calculate results
  R1 := 0.0;
  L1 := 0.0;
  L2 := 0.0;
  g1 := 0.0;
  g2 := 0.0;
  for i := 1 to NoCases do
  begin
    if (not GoodRecord(i,k,ColNoSelected)) then continue;
    for j := 1 to k do
    begin
      col := ColNoSelected[j-1];
      R1 := R1 + StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
    end;
    L1 := L1 + R1;
    L2 := L2 + (R1 * R1);
    R1 := 0.0;
  end;

  for j := 1 to k do
  begin
    for i := 1 to NoCases do
    begin
      if (not GoodRecord(i,k,ColNoSelected)) then continue;
        col := ColNoSelected[j-1];
        C1 := C1 + StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
    end;
    g1 := g1 + C1;
    g2 := g2 + (C1 * C1);
    C1 := 0.0;
  end;

  if (k * L1 - L2) > 0.0 then
  begin
    Q := ((k - 1) * ((k * g2) - (g1 * g1))) / ((k * L1) - L2);
    chiprob := 1.0 - chisquaredprob(Q, k - 1);
  end else
  begin
    Q := 0.0;
    chiprob := 1.0;
    Messagedlg('Error in obtaining Q and the probability.', mtError, [mbOK], 0);
  end;

  //present results
  lReport := TStringList.Create;
  try
    lReport.Add('COCHRAN Q TEST FOR RELATED SAMPLES');
    lReport.Add('See pages 161-166 in S. Siegel: Nonparametric Statistics for the Behavioral Sciences');
    lReport.Add('McGraw-Hill Book Company, New York, 1956');
    lReport.Add('');
    lReport.Add('Cochran Q Statistic: %6.3f', [Q]);
    lReport.Add('which is distributed as chi-square with %d D.F. and probability %.4f', [k-1, chiprob]);
    DisplayReport(lReport);
  finally
    lReport.Free;
    ColNoSelected := nil;
  end;
end;

procedure TCochranQFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      SelList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TCochranQFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < SelList.Items.Count do
  begin
    if SelList.Selected[i] then
    begin
      VarList.Items.Add(SelList.Items[i]);
      SelList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TCochranQFrm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i:=0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i:=0 to SelList.Items.Count-1 do
    if SelList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;

  AllBtn.Enabled := VarList.Items.Count > 0;
end;

procedure TCochranQFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I cochranqunit.lrs}

end.

