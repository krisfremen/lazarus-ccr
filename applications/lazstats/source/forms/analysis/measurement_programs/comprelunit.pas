// File for testing: CompRelData.laz, use all variables

unit CompRelUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, Globals, DataProcs, MatrixLib,
  DictionaryUnit, ContextHelpUnit;

type

  { TCompRelFrm }

  TCompRelFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    RMatChk: TCheckBox;
    GridScrChk: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    ItemList: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    WeightList: TListBox;
    RelList: TListBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure ItemListSelectionChange(Sender: TObject; User: boolean);
    procedure OutBtnClick(Sender: TObject);
    procedure RelListClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure WeightListClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  CompRelFrm: TCompRelFrm;

implementation

uses
  Math, Utils;

{ TCompRelFrm }

procedure TCompRelFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  ItemList.Clear;
  RelList.Clear;
  WeightList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TCompRelFrm.WeightListClick(Sender: TObject);
var
  response: string;
  index: integer;
begin
  response := InputBox('Test Weight', 'Test weight:', '1.0');
  index := WeightList.ItemIndex;
  WeightList.Items.Strings[index] := response;
end;

procedure TCompRelFrm.FormActivate(Sender: TObject);
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

  w := Max(Label1.Width, Label3.Width);
  VarList.Constraints.MinWidth := w;
  ItemList.constraints.MinWidth := w;
  RelList.Constraints.MinWidth := w;
  WeightList.Constraints.MinWidth := 2;

  //AutoSize := false;
  Constraints.MinHeight := Height;
  Width := 4 * w + AllBtn.Width + 6 * VarList.BorderSpacing.Left;
  Constraints.MinWidth := Width;

  FAutoSized := True;
end;

procedure TCompRelFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TCompRelFrm.FormResize(Sender: TObject);
var
  w: Integer;
begin
  w := (Width - AllBtn.Width - 6*VarList.BorderSpacing.Left) div 4;
  VarList.Width := w;
  ItemList.Width := w;
  RelList.Width := w;
  WeightList.Width := w;
end;

procedure TCompRelFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TCompRelFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContexthelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TCompRelFrm.AllBtnClick(Sender: TObject);
var
  i: integer;
  cellstring : string;
begin
  cellstring := '1.0';
  for i := 1 to VarList.Items.Count do
  begin
    ItemList.Items.Add(VarList.Items[i-1]);
    RelList.Items.Add(cellstring);
    WeightList.Items.Add(cellstring);
  end;
  VarList.Clear;
  InBtn.Enabled := false;
  OutBtn.Enabled := true;
end;

procedure TCompRelFrm.ComputeBtnClick(Sender: TObject);
var
  errorcode: boolean = false;
  i, j, NoVars, count, col: integer;
  Rmat, RelMat: DblDyneMat;
  Weights, Reliabilities, VectProd, means, variances, stddevs: DblDyneVec;
  CompRel, numerator, denominator, compscore: double;
  colnoselected: IntDyneVec;
  cellstring: string;
  title: string;
  RowLabels: StrDyneVec;
  lReport: TStrings;
begin
  if ItemList.Count = 0 then
  begin
    MessageDlg('No items selected.', mtError, [mbOK], 0);
    exit;
  end;

  SetLength(colnoselected,NoVariables);
  SetLength(Rmat,NoVariables+1,NoVariables+1);
  SetLength(RelMat,NoVariables+1,NoVariables+1);
  SetLength(Weights,NoVariables);
  SetLength(Reliabilities,NoVariables);
  SetLength(VectProd,NoVariables);
  SetLength(means,NoVariables);
  SetLength(variances,NoVariables);
  SetLength(stddevs,NoVariables);
  SetLength(RowLabels,NoVariables);

  // get variable col. no.s selected
  NoVars := ItemList.Items.Count;
  for i := 0 to NoVars-1 do
  begin
    cellstring := ItemList.Items.Strings[i];
    for j := 1 to NoVariables do
    begin
      if (cellstring = OS3MainFrm.DataGrid.Cells[j,0]) then
      begin
        colnoselected[i] := j;
        RowLabels[i] := cellstring;
      end;
    end;
  end;
  count := NoCases;

  lReport := TStringList.Create;
  try
    lReport.Add('COMPOSITE TEST RELIABILITY');
    lReport.Add('');
    lReport.Add('File Analyzed: ' + OS3MainFrm.FileNameEdit.Text);
    lReport.Add('');

    // get correlation matrix
    Correlations(NoVars, colnoselected, Rmat, means, variances, stddevs, errorcode, count);

    if errorcode then
      MessageDlg('Zero variance found for a variable.', mtError, [mbOK], 0);

    if RmatChk.Checked then
    begin
      title := 'Correlations Among Tests';
      MatPrint(Rmat, NoVars, NoVars, title, RowLabels, RowLabels, count, lReport);
      title := 'Means';
      DynVectorPrint(means, NoVars, title, RowLabels, count, lReport);
      title := 'Variances';
      DynVectorPrint(variances, NoVars, title, RowLabels, count, lReport);
      title := 'Standard Deviations';
      DynVectorPrint(stddevs, NoVars, title, RowLabels, count, lReport);
    end;

    for i := 0 to NoVars do
      for j := 0 to NoVars do
        RelMat[i, j] := Rmat[i, j];

    for i := 0 to NoVars-1 do
    begin
      Reliabilities[i] := StrToFloat(RelList.Items.Strings[i]);
      RelMat[i, i] := Reliabilities[i];
      Weights[i] := StrToFloat(WeightList.Items.Strings[i]);
    end;

    // get numerator and denominator of composite reliability
    for i := 0 to NoVars-1 do
      VectProd[i] := 0.0;
    numerator := 0.0;
    denominator := 0.0;
    for i := 0 to NoVars-1 do
      for j := 0 to NoVars-1 do
        VectProd[i] := VectProd[i] + (Weights[i] * RelMat[j, i]);
    for i := 0 to NoVars-1 do
      numerator := numerator + (VectProd[i] * Weights[i]);

    for i := 0 to NoVars-1 do
      VectProd[i] := 0.0;
    for i := 0 to NoVars-1 do
      for j := 0 to NoVars-1 do
        VectProd[i] := VectProd[i] + (Weights[i] * Rmat[j, i]);
    for i := 0 to NoVars-1 do
      denominator := denominator + VectProd[i] * Weights[i];
    CompRel := numerator / denominator;

    title := 'Test Weights';
    DynVectorPrint(Weights, NoVars, title, RowLabels, count, lReport);
    title := 'Test Reliabilities';
    DynVectorPrint(Reliabilities, NoVars, title, RowLabels, count, lReport);
    lReport.Add('Composite reliability: %6.3f', [CompRel]);

    DisplayReport(lReport);

    if GridScrChk.Checked then
    begin
      cellstring := 'Composite';
      col := NoVariables + 1;
      DictionaryFrm.NewVar(col);
      DictionaryFrm.DictGrid.Cells[1,col] := cellstring;
      col := NoVariables;
      OS3MainFrm.DataGrid.Cells[col,0] := cellstring;
      col := NoVariables;
      for i := 1 to NoCases do
      begin
        if not GoodRecord(i, NoVars, ColNoSelected) then
          continue;
        compscore := 0.0;
        for j := 0 to NoVars-1 do
          compscore := compscore + (Weights[j] * StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[colnoselected[j],i])));
        OS3MainFrm.DataGrid.Cells[col,i] := FloatToStr(compscore);
      end;
    end;

  finally
    lReport.Free;
    RowLabels := nil;
    stddevs := nil;
    variances := nil;
    means := nil;
    VectProd := nil;
    Reliabilities := nil;
    Weights := nil;
    RelMat := nil;
    Rmat := nil;
    colnoselected := nil;
  end;
end;

procedure TCompRelFrm.InBtnClick(Sender: TObject);
var
  i: integer;
  cellstring: string;
begin
  cellstring := '1.0';
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      ItemList.Items.Add(VarList.Items[i]);
      RelList.Items.Add(cellstring);
      WeightList.Items.Add(cellstring);
      VarList.Items.Delete(i);
      i := 0;
    end
    else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TCompRelFrm.ItemListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TCompRelFrm.OutBtnClick(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while i < ItemList.Items.Count do
  begin
    if ItemList.Selected[i] then
    begin
      VarList.Items.Add(ItemList.Items[i]);
      ItemList.Items.Delete(i);
      RelList.Items.Delete(i);
      WeightList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TCompRelFrm.RelListClick(Sender: TObject);
var
  response: string;
  index: integer;
begin
  response := InputBox('Reliability', 'Reliability estimate: ', '1.0');
  index := RelList.ItemIndex;
  RelList.Items[index] := response;
end;

procedure TCompRelFrm.UpdateBtnStates;
begin
  InBtn.Enabled := AnySelected(VarList);
  OutBtn.Enabled := AnySelected(ItemList);
  AllBtn.Enabled := VarList.Items.Count > 0;
end;

initialization
  {$I comprelunit.lrs}

end.

