// File for testing: cansas.laz
// - Selected dependent variable --> jumps
// - Seleckted predictor variables --> weight
// - variables partialed out --> waist, pulse

unit PartialsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, MatrixLib, FunctionsLib, OutputUnit, Globals, ContextHelpUnit;

type

  { TPartialsFrm }

  TPartialsFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    HelpBtn: TButton;
    PredInBtn: TBitBtn;
    PredOutBtn: TBitBtn;
    PartInBtn: TBitBtn;
    PartOutBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DepVar: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PartList: TListBox;
    PredList: TListBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure PartInBtnClick(Sender: TObject);
    procedure PartOutBtnClick(Sender: TObject);
    procedure PredInBtnClick(Sender: TObject);
    procedure PredOutBtnClick(Sender: TObject);
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
  PartialsFrm: TPartialsFrm;

implementation

uses
  Math, Utils;

{ TPartialsFrm }

procedure TPartialsFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  DepVar.Text := '';
  VarList.Clear;
  PartList.Clear;
  PredList.Clear;
  for i := 1 to OS3MainFrm.DataGrid.ColCount - 1 do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TPartialsFrm.FormActivate(Sender: TObject);
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

  w := 2 * Max(Label2.Width, Label3.Width) + DepInBtn.Width + 4 * VarList.BorderSpacing.Left;
  Constraints.MinWidth := w; //Max(Width, w);
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TPartialsFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TPartialsFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TPartialsFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TPartialsFrm.PartInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      PartList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TPartialsFrm.PartOutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < PartList.Items.Count do
  begin
    if PartList.Selected[i] then
    begin
      VarList.Items.Add(PartList.Items[i]);
      PartList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TPartialsFrm.PredInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      PredList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TPartialsFrm.PredOutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < PredList.Items.Count do
  begin
    if PredList.Selected[i] then
    begin
      VarList.Items.Add(PredList.Items[i]);
      PredList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TPartialsFrm.DepInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepVar.Text = '') then
  begin
    DepVar.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TPartialsFrm.DepOutBtnClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TPartialsFrm.ComputeBtnClick(Sender: TObject);
var
  rmatrix, workmat: DblDyneMat;
  Means, Variances, StdDevs, W, Betas: DblDyneVec;
  R2Full, R2Cntrl, SemiPart, Partial, df1, df2, F, Prob: double;
  NoPredVars, NoCntrlVars, DepVarNo, TotNoVars, pcnt, ccnt, count: integer;
  PredVars, CntrlVars: IntDyneVec;
  MatVars: IntDyneVec;
  outline, varstring: string;
  i, j, K, L: integer;
  errorcode: boolean;
  vtimesw, W1, v: DblDyneMat;
  lReport: TStrings;

begin
  DepVarNo := 1;
  errorcode := false;

  if DepVar.Text = '' then
  begin
    MessageDlg('No dependent variable selected.', mtError, [mbOK], 0);
    exit;
  end;

  // Get no. of predictor and control variables
  NoPredVars := PredList.Items.Count;
  NoCntrlVars := PartList.Items.Count;
  if (NoPredVars = 0) or (NoCntrlVars = 0) then
  begin
    MessageDlg('You must select at least one predictor and one control variable.', mtError, [mbOK], 0);
    exit;
  end;
  TotNoVars := NoPredVars + NoCntrlVars + 1;
  count := NoCases;

  // Allocate space required
  SetLength(vtimesw,NoVariables,NoVariables);
  SetLength(v,NoVariables,NoVariables);
  SetLength(W1,NoVariables,NoVariables);
  SetLength(rmatrix,NoVariables+1,NoVariables+1); // augmented
  SetLength(workmat,NoVariables+1,NoVariables+1); // augmented
  SetLength(PredVars,NoVariables);
  SetLength(CntrlVars,NoVariables);
  SetLength(Means,NoVariables);
  SetLength(Variances,NoVariables);
  SetLength(StdDevs,NoVariables);
  SetLength(W,NoVariables);
  SetLength(Betas,NoVariables);
  SetLength(MatVars,NoVariables);

  lReport := TStringList.Create;
  try
    lReport.Add('PARTIAL AND SEMI-PARTIAL CORRELATION ANALYSIS');
    lReport.Add('');

    // Get column numbers of dependent, predictor and control variables
    pcnt := 1;
    for i := 0 to NoPredVars - 1 do
    begin
      varstring := PredList.Items.Strings[i];
      for j := 1 to NoVariables do
      begin
        if varstring = OS3MainFrm.DataGrid.Cells[j,0] then
        begin
          PredVars[pcnt-1] := j;
          pcnt := pcnt + 1;
        end;
      end;
    end;
    ccnt := 1;
    for i := 0 to NoCntrlVars - 1 do
    begin
      varstring := PartList.Items.Strings[i];
      for j := 1 to NoVariables do
      begin
        if varstring = OS3MainFrm.DataGrid.Cells[j,0] then
        begin
          CntrlVars[ccnt-1] := j;
          ccnt := ccnt + 1;
          end;
      end;
    end;
    varstring := DepVar.Text;
    for i := 1 to NoVariables do
      if varstring = OS3MainFrm.DataGrid.Cells[i,0] then DepVarNo := i;

    lReport.Add('Dependent variable: %s', [OS3MainFrm.DataGrid.Cells[DepVarNo, 0]]);
    lReport.Add('');
    lReport.Add('Predictor Variables:');
    for i := 1 to NoPredVars do
      lReport.Add('  Variable %d: %s', [i+1, OS3MainFrm.DataGrid.Cells[PredVars[i-1], 0]]);
    lReport.Add('');
    lReport.Add('Control Variables:');
    for i := 1 to NoCntrlVars do
      lReport.Add('  Variable %d: %s', [i+1, OS3MainFrm.DataGrid.Cells[CntrlVars[i-1], 0]]);
    lReport.Add('');
    if NoPredVars > 1 then
    begin
      lReport.Add('Higher order partialling at level: %d', [NoPredVars]);
      lReport.Add('');
    end;
    if NoCntrlVars > 1 then
    begin
      lReport.Add('Multiple partialling with %d variables.', [NoCntrlVars]);
      lReport.Add('');
    end;

    // Now, build the correlation matrix
    MatVars[0] := DepVarNo;
    for i := 1 to NoPredVars do MatVars[i] := PredVars[i-1];
    for i := 1 to NoCntrlVars do MatVars[i + NoPredVars] := CntrlVars[i-1];
    Correlations(TotNoVars, MatVars, rmatrix, Means, Variances, StdDevs, errorcode, count);

    // Now do Multiple regression models required
    // Full model first
    for i := 2 to TotNoVars do
      for j := 2 to TotNoVars do
        workmat[i-2,j-2] := rmatrix[i-1,j-1];

    MatInv(workmat, vtimesw, v, W1, TotNoVars-1);
    R2Full := 0.0;
    for i := 1 to TotNoVars-1 do // rows
    begin
      W[i-1] := 0.0;
      for j := 1 to TotNoVars - 1 do
        W[i-1] := W[i-1] + (workmat[i-1,j-1] * rmatrix[0,j]);
      R2Full := R2Full + W[i-1] * rmatrix[0,i];
    end;
    lReport.Add('Squared Multiple Correlation with all variables:     %6.3f', [R2Full]);
    lReport.Add('');
    lReport.Add('Standardized Regression Coefficients:');
    for i := 1 to TotNoVars - 1 do
      lReport.Add('%15s:  %6.3f', [OS3MainFrm.DataGrid.Cells[MatVars[i],0], W[i-1]]);
    lReport.Add('');

    // Now do model for Partial and Semi-partial
    for i := 1 to NoCntrlVars do
    begin
      K := i + 1 + NoPredVars;
      for j := 1 to NoCntrlVars do
      begin
        L := j + 1 + NoPredVars;
        workmat[i-1,j-1] := rmatrix[K-1,L-1];
      end;
    end;
    MatInv(workmat, vtimesw, v, W1, NoCntrlVars);
    R2Cntrl := 0.0;
    for i := 1 to NoCntrlVars do
    begin
      L := i + 1 + NoPredVars;
      W[i-1] := 0.0;
      for j := 1 to NoCntrlVars do
      begin
        K := j + 1 + NoPredVars;
        W[i-1] := W[i-1] + (workmat[i-1,j-1] * rmatrix[0,K-1]);
      end;
      R2Cntrl := R2Cntrl + W[i-1] * rmatrix[0,L-1];
    end;
    lReport.Add('Squared Multiple Correlation with control variables: %6.3f', [R2Cntrl]);
    lReport.Add('');
    lReport.Add('Standardized Regression Coefficients:');
    for i := 1 to NoCntrlVars do
      lReport.Add('%15s:  %6.3f', [OS3MainFrm.DataGrid.Cells[MatVars[i+NoPredVars],0], W[i-1]]);
    lReport.Add('');

    SemiPart := R2Full - R2Cntrl;
    Partial := SemiPart / (1.0 - R2Cntrl);
    df1 := TotNoVars - 1 - NoCntrlVars;
    df2 := count - TotNoVars;
    F := (SemiPart / (1.0 - R2Full)) * (df2 / df1);
    Prob := probf(F,df1,df2);

    // Report results
    lReport.Add('');
    lReport.Add('Partial Correlation:      %8.3f', [sqrt(Partial)]);
    lReport.Add('');
    lReport.Add('Semi-Partial Correlation: %8.3f', [sqrt(SemiPart)]);
    lReport.Add('');
    lReport.Add('F:                        %8.3f', [F]);
    lReport.Add('   with probability       %8.4f', [Prob]);
    lReport.Add('   D.F.1                  %8.0f', [df1]);
    lReport.Add('   D.F.2                  %8.0f', [df2]);

    DisplayReport(lReport);

  finally
    lReport.Free;
    MatVars := nil;
    Betas := nil;
    W := nil;
    Variances := nil;
    StdDevs := nil;
    Means := nil;
    CntrlVars := nil;
    PredVars := nil;
    workmat := nil;
    rmatrix := nil;
    v := nil;
    W1 := nil;
    vtimesw := nil;
  end;
end;

procedure TPartialsFrm.UpdateBtnStates;
var
  lSelected: Boolean;
begin
  lSelected := AnySelected(VarList);
  DepInBtn.Enabled := lSelected and (DepVar.Text = '');
  PredInBtn.Enabled := lSelected;
  PartInBtn.Enabled := lSelected;

  DepOutBtn.Enabled := DepVar.Text <> '';
  PredOutBtn.Enabled := AnySelected(PredList);
  PartOutBtn.Enabled := AnySelected(Partlist);
end;

procedure TPartialsFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I partialsunit.lrs}

end.

