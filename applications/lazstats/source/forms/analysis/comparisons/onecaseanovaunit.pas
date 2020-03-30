unit OneCaseANOVAUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit, DataProcs, GraphLib,
  ANOVATestsUnit, contexthelpunit;

type

  { TOneCaseAnovaForm }

  TOneCaseAnovaForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    ComputeBtn: TButton;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    DepVar: TEdit;
    Fact1In: TBitBtn;
    Fact1Out: TBitBtn;
    Fact2In: TBitBtn;
    Fact2Out: TBitBtn;
    Fact3In: TBitBtn;
    Fact3Out: TBitBtn;
    Factor1: TEdit;
    Factor2: TEdit;
    Factor3: TEdit;
    GroupBox1: TGroupBox;
    InteractBtn: TCheckBox;
    HelpBtn: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    NewmanKeulsChk: TCheckBox;
    OverAllAlpha: TEdit;
    Panel1: TPanel;
    PostAlpha: TEdit;
    PlotOptionsBox: TRadioGroup;
    ResetBtn: TButton;
    CloseBtn: TButton;
    ScheffeChk: TCheckBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    TukeyBChk: TCheckBox;
    TukeyHSDChk: TCheckBox;
    TukeyKramerChk: TCheckBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure Fact1InClick(Sender: TObject);
    procedure Fact1OutClick(Sender: TObject);
    procedure Fact2InClick(Sender: TObject);
    procedure Fact2OutClick(Sender: TObject);
    procedure Fact3InClick(Sender: TObject);
    procedure Fact3OutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: Boolean;
    NoSelected, N: integer;
    ColNoSelected: IntDyneVec;
    DepVarCol, F1Col, F2Col, F3Col, Nf1cells, Nf2cells, Nf3cells: integer;
    minf1, maxf1, minf2, maxf2, minf3, maxf3, nofactors, totcells: integer;
    NoGrpsA, NoGrpsB, NoGrpsC: integer;
    SSDep, SSErr, SSF1, SSF2, SSF3, SSF1F2, SSF1F3, SSF2F3, SSF1F2F3: double;
    MSDep, MSErr, MSF1, MSF2, MSF3, MSF1F2, MSF1F3, MSF2F3: double;
    DFTot, DFErr, DFF1, DFF2, DFF3, DFF1F2, DFF1F3, DFF2F3: double;
    Omega, OmegaF1, OmegaF2, OmegaF3, OmegaF1F2: double;
    OmegaF1F3, OmegaF2F3: double;
    FF1, FF2, FF1F2, ProbF1, ProbF2, ProbF3, ProbF1F2, ProbF1F3: double;
    FF3, FF2F3, FF1F3, ProbF2F3: double;
    MeanDep, MeanF1, MeanF2, MeanF3: double;
    SSNonAdd, SSBalance,MSNonAdd, MSBalance, GrandMean, DFBalance: double;
    FNonAdd, ProbNonAdd: double;
    cellcnts : DblDyneVec;    // array of cell counts
    cellvars : DblDyneVec;    // arrray of cell sums of squares then variances
    cellsums : DblDyneVec;    // array of cell sums then means
    counts : DblDyneMat;      // matrix for 2-way containing cell sizes
    sums : DblDyneMat;        // matrix for 2-way containing cell sums
    vars : DblDyneMat;        // matrix for 2-way containing sums of squares
    RowSums : DblDyneVec;     // 2 way row sums
    ColSums : DblDyneVec;     // 2 way col sums
    RowCount : DblDyneVec;    // 2 way row count
    ColCount : DblDyneVec;    // 2 way col count
    SlcSums : DblDyneVec;     // 3 way slice sums
    SlcCount : DblDyneVec;    // 3 way slice counts
    OrdMeansA, OrdMeansB, OrdMeansC : DblDyneVec; // reordered means for f1, f2, f3
    OverAll, PostHocAlpha : double; // alphas for tests
    wsum, wx2 : DblDyneCube; // : DblDyneCube
    ncnt : IntDyneCube; // : IntDyneCube;
    CompError : boolean;
    equal_grp : boolean;   // check for equal groups for post-hoc tests
    comparisons : boolean;
//    interacts : boolean;  // true if 2 way interactions to be included in 3 way design

    procedure Init;
    procedure GetLevels;
    procedure Calc2Way;
    procedure TwoWayTable(AReport: TStrings);
    procedure TwoWayContrasts(AReport: TStrings);
    procedure TwoWayPlot;
    procedure Calc3Way;
    procedure ThreeWayTable(AReport: TStrings);
    procedure ThreeWayContrasts(AReport: TStrings);
    procedure ThreeWayPlot;

    procedure UpdateBtnStates;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;

  public
    { public declarations }
  end; 

var
  OneCaseAnovaForm: TOneCaseAnovaForm;

implementation

uses
  Math;

{ TOneCaseAnovaForm }

procedure TOneCaseAnovaForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  DepVar.Text := '';
  Factor1.Text := '';
  Factor2.Text := '';
  Factor3.Text := '';
  //PlotMeans.Checked := false;
  ScheffeChk.Checked := false;
  TukeyHSDChk.Checked := false;
  TukeyBChk.Checked := false;
  TukeyKramerChk.Checked := false;
  NewmanKeulsChk.Checked := false;
//  BonferroniChk.Checked := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TOneCaseAnovaForm.FormActivate(Sender: TObject);
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

  Panel1.Constraints.MinWidth := 2*PlotoptionsBox.Width;
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TOneCaseAnovaForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);

  OverallAlpha.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  PostAlpha.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
end;

procedure TOneCaseAnovaForm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TOneCaseAnovaForm.DepInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepVar.Text = '') then
  begin
    DepVar.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TOneCaseAnovaForm.DepOutClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TOneCaseAnovaForm.Fact1InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Factor1.Text = '') then
  begin
    Factor1.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TOneCaseAnovaForm.Fact1OutClick(Sender: TObject);
begin
  if Factor1.Text <> '' then
  begin
    VarList.Items.Add(Factor1.Text);
    Factor1.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TOneCaseAnovaForm.Fact2InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Factor2.Text = '') then
  begin
    Factor2.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TOneCaseAnovaForm.Fact2OutClick(Sender: TObject);
begin
  if Factor2.Text <> '' then
  begin
    VarList.Items.Add(Factor2.Text);
    Factor2.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TOneCaseAnovaForm.Fact3InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Factor3.Text = '') then
  begin
    Factor3.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TOneCaseAnovaForm.Fact3OutClick(Sender: TObject);
begin
  if Factor3.Text <> '' then
  begin
    VarList.Items.Add(Factor3.Text);
    Factor3.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TOneCaseAnovaForm.ComputeBtnClick(Sender: TObject);
var
  lReport: TStrings;
  msg: String;
  C: TWinControl;
begin
  NoFactors := 0;
  if (Factor1.Text <> '') and (Factor2.Text <> '') then
  begin
    NoFactors := 2;
    if (Factor3.Text <> '') then
      NoFactors := 3;
  end;
  if (NoFactors < 2) then
  begin
    MessageDlg('Selection of 2 or 3 factors required.', mtError, [mbOK], 0);
    exit;
  end;

  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  // initialize values
  Init;

  // get min and max of each factor code
  GetLevels;

  // Analysis
  case NoFactors of
    2 : begin    // two-way anova
          SetLength(counts, Nf1cells, Nf2cells); // matrix for 2-way containing cell sizes
          SetLength(sums, Nf1cells, Nf2cells);  // matrix for 2-way containing cell sums
          SetLength(vars, Nf1cells, Nf2cells);  // matrix for 2-way containing sums of squares
          SetLength(RowSums, Nf1cells);  // 2 way row sums
          SetLength(ColSums, Nf2cells);  // 2 way col sums
          SetLength(RowCount, Nf1cells); // 2 way row count
          SetLength(ColCount, Nf2cells); // 2 way col count
          SetLength(OrdMeansA, Nf1cells); // ordered means for factor 1
          SetLength(OrdMeansB, Nf2cells); // ordered means for factor 2
          Calc2Way;
          if not CompError then
          begin
            lReport := TStringList.Create;
            try
              TwoWayTable(lReport);
              TwoWayContrasts(lReport);
              DisplayReport(lReport);
              if PlotOptionsBox.ItemIndex > 0 then
                TwoWayPlot;
            finally
              lReport.Free;
            end;
          end;
          vars := nil;
          sums := nil;
          counts := nil;
        end;

    3 : begin  // three way anova
          SetLength(RowSums, Nf1cells);  // 2 way row sums
          SetLength(ColSums, Nf2cells);  // 2 way col sums
          SetLength(RowCount, Nf1cells); // 2 way row count
          SetLength(ColCount, Nf2cells); // 2 way col count
          SetLength(SlcSums, Nf3cells);  // 3 way slice sums
          SetLength(SlcCount, Nf3cells); // 3 way slice counts
          SetLength(OrdMeansA, Nf1cells); // ordered means for factor 1
          SetLength(OrdMeansB, Nf2cells); // ordered means for factor 2
          SetLength(OrdMeansC, Nf3cells); // ordered means for factor 3
          SetLength(wsum, Nf1cells, Nf2cells, Nf3cells);
          SetLength(wx2, Nf1cells, Nf2cells, Nf3cells);
          SetLength(ncnt, Nf1cells, Nf2cells, Nf3cells);
          Calc3Way;
          if not CompError then
          begin
            lReport := TStringList.Create;
            try
              ThreeWayTable(lReport);
              ThreeWayContrasts(lReport);
              DisplayReport(lReport);
              if PlotOptionsBox.ItemIndex > 0 then
                ThreeWayPlot;
            finally
              lReport.Free;
            end;
            ncnt := nil;
            wx2 := nil;
            wsum := nil;
            OrdMeansC := nil;
            SlcCount := nil;
            SlcSums := nil;
          end;
        end;
  end; // end switch

  cellcnts := nil;
  cellvars := nil;
  cellsums := nil;
  ColNoSelected := nil;
  OrdMeansB := nil;
  OrdMeansA := nil;
  ColCount := nil;
  RowCount := nil;
  ColSums := nil;
  RowSums := nil;
end;

procedure TOneCaseAnovaForm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TOneCaseAnovaForm.Init;
var
  i: Integer;
  cellstring: String;
begin
  comparisons := ScheffeChk.Checked or TukeyHSDChk.Checked or
    TukeyBChk.Checked or TukeyKramerChk.Checked or NewmanKeulsChk.Checked;

  SetLength(ColNoSelected, NoVariables);
  DepVarCol := 0;
  F1Col := 0;
  F2Col := 0;
  F3Col := 0;
  SSDep := 0.0;
  SSF1 := 0.0;
  SSF2 := 0.0;
  SSF3 := 0.0;
  SSF1F2 := 0.0;
  SSF1F3 := 0.0;
  SSF2F3 := 0.0;
  SSF1F2F3 := 0.0;
  MeanDep := 0.0;
  MeanF1 := 0.0;
  MeanF2 := 0.0;
  MeanF3 := 0.0;
  Nf1cells := 0;
  Nf2cells := 0;
  Nf3cells := 0;
  //N := 0;
  NoSelected := 0;
  minf1 := 0;
  maxf1 := 0;
  minf2 := 0;
  maxf2 := 0;
  minf3 := 0;
  maxf3 := 0;

  //  Get column numbers of dependent variable and factors
  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = DepVar.Text) then
    begin
      DepVarCol := i;
      NoSelected := NoSelected + 1;
      ColNoSelected[NoSelected-1] := DepVarCol;
    end else
    if (cellstring = Factor1.Text) then
    begin
      F1Col := i;
      NoSelected := NoSelected + 1;
      ColNoSelected[NoSelected-1] := F1Col;
    end else
    if (cellstring = Factor2.Text) then
    begin
      F2Col := i;
      NoSelected := NoSelected + 1;
      ColNoSelected[NoSelected-1] := F2Col;
    end else
    if (cellstring = Factor3.Text) then
    begin
      F3Col := i;
      NoSelected := NoSelected + 1;
      ColNoSelected[NoSelected-1] := F3Col;
    end;
  end;
  OverAll := StrToFloat(OverAllAlpha.Text);
  PostHocAlpha := StrToFloat(PostAlpha.Text);
 end;

procedure TOneCaseAnovaForm.GetLevels;
var
  i: integer;
  intValue: Integer;
begin
  minf1 := ceil(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,1])));
  maxf1 := minf1;
  for i := 2 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    intValue := floor(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
    if (intValue > maxf1) then maxf1 := intValue;
    if (intValue < minf1) then minf1 := intValue;
  end;
  Nf1cells := maxf1 - minf1 + 1;

  if (nofactors > 1) then
  begin
    minf2 := floor(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F2Col,1])));
    maxf2 := minf2;
    for i := 2 to NoCases do
    begin
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      intValue := floor(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i])));
      if (intValue > maxf2) then  maxf2 := intValue;
      if (intValue < minf2) then  minf2 := intValue;
    end;
    Nf2cells := maxf2 - minf2 + 1;
  end;

  if (nofactors = 3) then
  begin
    minf3 := floor(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F3Col,1])));
    maxf3 := minf3;
    for i := 2 to NoCases do
    begin
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      intValue := floor(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F3Col,i])));
      if (intValue > maxf3) then maxf3 := intValue;
      if (intValue < minf3) then minf3 := intValue;
    end;
    Nf3cells := maxf3 - minf3 + 1;
  end;

  totcells := Nf1cells + Nf2cells + Nf3cells;

  // allocate space
  SetLength(cellcnts, totcells);  // array of cell counts
  SetLength(cellvars, totcells);  // arrray of cell sums of squares  variances
  SetLength(cellsums, totcells);  // array of cell sums  means

  // initialize array values
  for i := 1 to totcells do
  begin
    cellsums[i-1] := 0.0;
    cellvars[i-1] := 0.0;
    cellcnts[i-1] := 0;
  end;
end;

procedure TOneCaseAnovaForm.Calc2Way;
var
  i, j, grpA, grpB: integer;
  Constant, RowsTotCnt, ColsTotCnt, SSCells: double;
  X, rowMean, colmean: Double;
begin
  CompError := false;

  // initialize matrix values
  NoGrpsA := maxf1 - minf1 + 1;
  NoGrpsB := maxf2 - minf2 + 1;
  for i := 1 to NoGrpsA do
  begin
    RowSums[i-1] := 0.0;
    RowCount[i-1] := 0.0;
    for j := 1 to NoGrpsB do
    begin
      counts[i-1,j-1] := 0.0;
      sums[i-1,j-1] := 0.0;
      vars[i-1,j-1] := 0.0;
    end;
  end;

  for i := 1 to NoGrpsB do
  begin
    ColCount[i-1] := 0.0;
    ColSums[i-1] := 0.0;
  end;

  N := 0;
  MeanDep := 0.0;
  SSDep := 0.0;
  SSCells := 0.0;
  RowsTotCnt := 0.0;
  ColsTotCnt := 0.0;
  SSNonAdd := 0.0;
  SSBalance := 0.0;
  MSNonAdd := 0.0;
  MSBalance := 0.0;

  // get working totals
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    grpA := floor(StrToFloat(OS3MainFrm.DataGrid.Cells[F1Col,i]));
    grpB := floor(StrToFloat(OS3MainFrm.DataGrid.Cells[F2Col,i]));
    X := StrToFloat(OS3MainFrm.DataGrid.Cells[DepVarCol,i]);
    grpA := grpA - minf1 + 1;
    grpB := grpB - minf2 + 1;
    counts[grpA-1,grpB-1] := counts[grpA-1,grpB-1] + 1;
    sums[grpA-1,grpB-1] := sums[grpA-1,grpB-1] + X;
    vars[grpA-1,grpB-1] := vars[grpA-1,grpB-1] + X * X;
    RowSums[grpA-1] := RowSums[grpA-1] + X;
    ColSums[grpB-1] := ColSums[grpB-1] + X;
    RowCount[grpA-1] := RowCount[grpA-1] + 1.0;
    ColCount[grpB-1] := ColCount[grpB-1] + 1.0;
    MeanDep := MeanDep + X;
    SSDep := SSDep + X * X;
    N := N + 1;
  end;

  // Calculate results
  for i := 0 to NoGrpsA - 1 do
  begin
    SSF1 := SSF1 + sqr(RowSums[i]) / RowCount[i];
    RowsTotCnt := RowsTotCnt + RowCount[i];
  end;
  for j := 0 to NoGrpsB - 1 do
  begin
    SSF2 := SSF2 + sqr(ColSums[j]) / ColCount[j];
    ColsTotCnt := ColsTotCnt + ColCount[j];
  end;

  GrandMean := MeanDep / N;

  for i := 0 to NoGrpsA - 1 do
  begin
    rowmean := RowSums[i] / RowCount[i];
    for j := 0 to NoGrpsB - 1 do
    begin
      colmean := ColSums[j] / ColCount[j];
      SSNonAdd := SSNonAdd + (colmean - GrandMean) * (rowmean - GrandMean) * sums[i,j];
    end;
  end;

  if (N > 0) then
    Constant := (MeanDep * MeanDep) / N
  else
    Constant := 0.0;
  SSF1 := SSF1 - Constant;
  SSF2 := SSF2 - Constant;
  SSDep := SSDep - Constant;
  SSErr := SSDep - (SSF1 + SSF2);
  SSNonAdd := (SSNonAdd * SSNonAdd) / ((SSF1 * SSF2) / (NoGrpsA * NoGrpsB)  );
  MSNonAdd := SSNonAdd;
  SSBalance := SSErr - SSNonAdd;
  if ((SSF1 < 0) or (SSF2 < 0)) then
  begin
    MessageDlg('A negative SS found. Unbalanced design? Ending analysis.', mtInformation, [mbOK], 0);
    CompError := true;
    exit;
  end;

  DFTot := N - 1;
  DFF1 := NoGrpsA - 1;
  DFF2 := NoGrpsB - 1;
  DFErr := DFF1 * DFF2;
  DFBalance := DFErr - 1;
  MSF1 := SSF1 / DFF1;
  MSF2 := SSF2 / DFF2;
  MSErr := SSErr / DFErr;
  MSDep := SSDep / DFTot;
  MSBalance := SSBalance / DFBalance;
  OmegaF1 := (SSF1 - DFF1 * MSErr) / (SSDep + MSErr);
  OmegaF2 := (SSF2 - DFF2 * MSErr) / (SSDep + MSErr);
  Omega := OmegaF1 + OmegaF2;
  MeanDep := MeanDep / N;

  // F tests for fixed effects
  FF1 := abs(MSF1 / MSErr);
  FF2 := abs(MSF2 / MSErr);
  if (MSBalance > 0.0) then
    FNonAdd := MSNonAdd / MSBalance
  else
    FNonAdd := 0.0;
  ProbF1 := probf(FF1,DFF1,DFErr);
  ProbF2 := probf(FF2,DFF2,DFErr);
  ProbNonAdd := probf(FNonAdd,1.0,DFBalance);
  if (ProbF1 > 1.0) then ProbF1 := 1.0;
  if (ProbF2 > 1.0) then ProbF2 := 1.0;

  // Obtain omega squared (proportion of dependent variable explained)
  if (OmegaF1 < 0.0) then OmegaF1 := 0.0;
  if (OmegaF2 < 0.0) then OmegaF2 := 0.0;
  if (Omega < 0.0) then Omega := 0.0;
end;

procedure TOneCaseAnovaForm.TwoWayTable(AReport: TStrings);
var
  i, j, groupsize: integer;
  MinVar, MaxVar, sumvars, sumDFrecip, XBar, V, S, RowSS, ColSS: double;
  sumfreqlogvar: double;
begin
  if CompError then
    exit;

  AReport.Add('TWO-WAY ANALYSIS OF VARIANCE');
  AReport.Add('');
  AReport.Add('Variable analyzed:           %s', [DepVar.Text]);
  AReport.Add('');
  AReport.Add('Factor A (rows) variable:    %s', [Factor1.Text]);
  AReport.Add('Factor B (columns) variable: %s', [Factor2.Text]);
  AReport.Add('');
  AReport.Add('SOURCE         D.F.    SS        MS         F      PROB.> F   Omega Squared');
  AReport.Add('');
  AReport.Add('Among Rows     %4.0f  %8.3f  %8.3f  %8.3f  %6.3f     %6.3f', [DFF1, SSF1, MSF1, FF1, ProbF1, OmegaF1]);
  AReport.Add('Among Columns  %4.0f  %8.3f  %8.3f  %8.3f  %6.3f     %6.3f', [DFF2, SSF2, MSF2, FF2, ProbF2, OmegaF2]);
  AReport.Add('Residual       %4.0f  %8.3f  %8.3f', [DFErr, SSErr, MSErr]);
  AReport.Add(' NonAdditivity %4.0f  %8.3f  %8.3f  %8.3f  %6.3f', [1.0, SSNonAdd, MSNonAdd, FNonAdd, ProbNonAdd]);
  AReport.Add(' Balance       %4.0f  %8.3f  %8.3f', [DFBalance, SSBalance, MSBalance]);
  AReport.Add('Total          %4.0f  %8.3f  %8.3f', [DFTot, SSDep, MSDep]);
  AReport.Add('');
  AReport.Add('Omega squared for combined effects = %8.3f', [Omega]);
  AReport.Add('');
  AReport.Add('Descriptive Statistics');
  AReport.Add('');
  AReport.Add('GROUP Row Col.  N     MEAN   VARIANCE  STD.DEV.');

  groupsize := ceil(counts[0,0]);
  equal_grp := true;
  MaxVar := -1e308;
  MinVar := 1e308;
  sumvars := 0.0;
  sumfreqlogvar := 0.0;
  sumDFrecip := 0.0;

  // Display cell means, variances, standard deviations
  V := 0.0;
  XBar := 0.0;
  S := 0.0;
  for i := 0 to NoGrpsA - 1 do
  begin
    for j := 0 to NoGrpsB - 1 do
    begin
      if (counts[i,j] > 1) then
      begin
        XBar := sums[i][j] / counts[i,j];
        V := vars[i][j] - sqr(sums[i,j]) / counts[i,j];
        V := V / (counts[i,j] - 1.0);
        S := sqrt(V);
        sumvars  := sumvars + V;
        if (V > MaxVar) then MaxVar := V;
        if (V < MinVar) then MinVar := V;
        sumDFrecip := sumDFrecip + 1.0 / (counts[i,j] - 1.0);
        sumfreqlogvar := sumfreqlogvar + (counts[i,j] - 1.0) * ln(V);
        if (counts[i,j] <> groupsize) then equal_grp := false;
      end
      else
        XBar := sums[i][j];
      AReport.Add('Cell %3d %3d  %3.0f  %8.3f  %8.3f  %8.3f', [minf1+i, minf2+j, counts[i,j], XBar, V, S]);
    end;
  end;

  //Display Row means, variances, standard deviations
  for i := 0 to NoGrpsA - 1 do
  begin
    XBar := RowSums[i] / RowCount[i];
    OrdMeansA[i] := XBar;
    RowSS := 0.0;
    for j := 0 to NoGrpsB - 1 do RowSS := RowSS + vars[i,j];
    V := RowSS - sqr(RowSums[i]) / RowCount[i];
    V := V / (RowCount[i] - 1.0);
    S := sqrt(V);
    AReport.Add('Row  %3d      %3.0f  %8.3f  %8.3f  %8.3f', [minf1+i, RowCount[i], XBar, V, S]);
  end;

  //Display means, variances and standard deviations for columns
  for j := 0 to NoGrpsB - 1 do
  begin
    XBar := ColSums[j] / ColCount[j];
    OrdMeansB[j] := XBar;
    ColSS := 0.0;
    for i := 0 to NoGrpsA - 1 do ColSS := ColSS + vars[i,j];
    if (ColCount[j] > 0) then V := ColSS - sqr(ColSums[j]) / ColCount[j];
    if (ColCount[j] > 1) then V := V / (ColCount[j] - 1.0);
    if (V > 0.0) then S := sqrt(V);
    AReport.Add('Col  %3d      %3.0f  %8.3f  %8.3f  %8.3f', [minf2+j, ColCount[j], XBar, V, S]);
  end;

  AReport.Add('TOTAL         %3d  %8.3f  %8.3f  %8.3f', [N, MeanDep, MSDep, sqrt(MSDep)]);
  AReport.Add('');
end;

procedure TOneCaseAnovaForm.TwoWayPlot;
var
  i, j: integer;
  maxmean, XBar: double;
  XValue: DblDyneVec;
  plottype: integer;
begin
  if CompError then
    exit;

  case PlotOptionsBox.ItemIndex of
    0: exit;
    1: plotType := 2;    // 3D bars
    2: plotType := 1;    // 2D bars
    3: plotType := 9;    // 2D horizontal bars
    else raise Exception.Create('Plot type not supported.');
  end;

  SetLength(XValue, Nf1cells+Nf2cells);

  //  Factor A first
  GraphFrm.SetLabels[1] := 'FACTOR A';
  maxmean := 0.0;
  SetLength(GraphFrm.Xpoints, 1, Nf1cells);
  SetLength(GraphFrm.Ypoints, 1, Nf1cells);
  for i := 1 to Nf1cells do
  begin
    RowSums[i-1] := RowSums[i-1] / RowCount[i-1];
    GraphFrm.Ypoints[0,i-1] := RowSums[i-1];
    if (RowSums[i-1] > maxmean) then  maxmean := RowSums[i-1];
    XValue[i-1] := minf1 + i - 1;
    GraphFrm.Xpoints[0,i-1] := XValue[i-1];
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := Nf1cells;
  GraphFrm.Heading := Factor1.Text;
  GraphFrm.XTitle := Factor1.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clCream;
  GraphFrm.WallColor := clDkGray;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal();
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;

  //  Factor B next
  GraphFrm.SetLabels[1] := 'FACTOR B';
  maxmean := 0.0;
  SetLength(GraphFrm.Xpoints, 1, Nf2cells);
  SetLength(GraphFrm.Ypoints, 1, Nf2cells);
  for i := 1 to Nf2cells do
  begin
    ColSums[i-1] := ColSums[i-1] / ColCount[i-1];
    GraphFrm.Ypoints[0,i-1] := ColSums[i-1];
    if (ColSums[i-1] > maxmean) then maxmean := ColSums[i-1];
    XValue[i-1] := minf1 + i - 1;
    GraphFrm.Xpoints[0,i-1] := XValue[i-1];
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := Nf2cells;
  GraphFrm.Heading := Factor2.Text;
  GraphFrm.XTitle := FActor2.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clCream;
  GraphFrm.WallColor := clDkGray;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal();
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;

  //  Factor A x B Interaction next
  maxmean := 0.0;
  SetLength(GraphFrm.Ypoints, Nf1cells, Nf2cells);
  SetLength(GraphFrm.Xpoints, 1, Nf2cells);
  for i := 1 to Nf1cells do
  begin
    GraphFrm.SetLabels[i] := Factor1.Text + ' ' + IntToStr(i);
    for j := 1 to Nf2cells do
    begin
      XBar := sums[i-1,j-1] / counts[i-1,j-1];
      if (XBar > maxmean) then maxmean := XBar;
      GraphFrm.Ypoints[i-1,j-1] := XBar;
    end;
  end;
  for j := 1 to Nf2cells do
  begin
    XValue[j-1] := minf2 + j - 1;
    GraphFrm.Xpoints[0,j-1] := XValue[j-1];
  end;
  GraphFrm.nosets := Nf1cells;
  GraphFrm.nbars := Nf2cells;
  GraphFrm.Heading := 'Factor A x Factor B';
  GraphFrm.XTitle := Factor2.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clCream;
  GraphFrm.WallColor := clDkGray;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal();
  XValue := nil;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;

procedure TOneCaseAnovaForm.Calc3Way;
var
  i, j, k, grpA, grpB, grpC: integer;
  Constant, RowsTotCnt, ColsTotCnt, SlcsTotCnt, SSCells, p, n2: double;
  X, rowMean, colMean, sliceMean: Double;
begin
  CompError := false;

  // initialize matrix values
  NoGrpsA := maxf1 - minf1 + 1;
  NoGrpsB := maxf2 - minf2 + 1;
  NoGrpsC := maxf3 - minf3 + 1;
  for i := 0 to NoGrpsA - 1 do
  begin
    RowSums[i] := 0.0;
    RowCount[i] := 0.0;
    for j := 0 to NoGrpsB - 1 do
    begin
      for k := 0 to NoGrpsC - 1 do
      begin
        wsum[i,j,k] := 0.0;
        ncnt[i,j,k] := 0;
        wx2[i,j,k] := 0.0;
      end;
    end;
  end;

  for i := 0 to NoGrpsB - 1 do
  begin
    ColCount[i] := 0.0;
    ColSums[i] := 0.0;
  end;

  for i := 0 to NoGrpsC - 1 do
  begin
    SlcCount[i] := 0.0;
    SlcSums[i] := 0.0;
  end;

  N := 0;
  MeanDep := 0.0;
  SSDep := 0.0;
  RowsTotCnt := 0.0;
  ColsTotCnt := 0.0;
  SlcsTotCnt := 0.0;
  SSF1 := 0.0;
  SSF2 := 0.0;
  SSF3 := 0.0;
  SSF1F2 := 0.0;
  SSF1F3 := 0.0;
  SSF2F3 := 0.0;
  SSF1F2F3 := 0.0;
  SSCells := 0.0;
  SSNonAdd := 0.0;

  // get working totals
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    grpA := floor(StrToFloat(OS3MainFrm.DataGrid.Cells[F1Col,i]));
    grpB := floor(StrToFloat(OS3MainFrm.DataGrid.Cells[F2Col,i]));
    grpC := floor(StrToFloat(OS3MainFrm.DataGrid.Cells[F3Col,i]));
    X := StrToFloat(OS3MainFrm.DataGrid.Cells[DepVarCol,i]);
    grpA := grpA - minf1 + 1;
    grpB := grpB - minf2 + 1;
    grpC := grpC - minf3 + 1;
    ncnt[grpA-1,grpB-1,grpC-1] := ncnt[grpA-1,grpB-1,grpC-1] + 1;
    wsum[grpA-1,grpB-1,grpC-1] := wsum[grpA-1,grpB-1,grpC-1] + X;
    wx2[grpA-1,grpB-1,grpC-1] := wx2[grpA-1,grpB-1,grpC-1] + X * X;
    RowSums[grpA-1] := RowSums[grpA-1] + X;
    ColSums[grpB-1] := ColSums[grpB-1] + X;
    SlcSums[grpC-1] := SlcSums[grpC-1] + X;
    RowCount[grpA-1] := RowCount[grpA-1] + 1.0;
    ColCount[grpB-1] := ColCount[grpB-1] + 1.0;
    SlcCount[grpC-1] := SlcCount[grpC-1] + 1.0;
    MeanDep := MeanDep + X;
    SSDep := SSDep + X * X;
    N := N + 1;
  end;

  // Calculate results
  Constant := (MeanDep * MeanDep) / N;
  GrandMean := MeanDep /  N;

  // get ss for rows
  for i := 0 to NoGrpsA - 1 do
  begin
    SSF1 := SSF1 + RowSums[i] * RowSums[i] / RowCount[i];
    RowsTotCnt := RowsTotCnt + RowCount[i];
  end;
  SSF1 := SSF1 - Constant;

  // get ss for columns
  for j := 0 to NoGrpsB - 1 do
  begin
    SSF2 := SSF2 + ColSums[j] * ColSums[j] / ColCount[j];
    ColsTotCnt := ColsTotCnt + ColCount[j];
  end;
  SSF2 := SSF2 - Constant;

  // get ss for slices
  for k := 0 to NoGrpsC - 1 do
  begin
    SSF3 := SSF3 + SlcSums[k] * SlcSums[k] / SlcCount[k];
    SlcsTotCnt := SlcsTotCnt + SlcCount[k];
  end;
  SSF3 := SSF3 - Constant;

  // get ss for row x col interaction
  p := 0.0;
  n2 := 0.0;
  for i := 0 to NoGrpsA - 1 do
  begin
    for j := 0 to NoGrpsB - 1 do
    begin
      for k := 0 to NoGrpsC - 1 do
      begin
        p := p + wsum[i,j,k];
        n2 := n2 + ncnt[i,j,k];
      end;
      SSF1F2 := SSF1F2 + p * p / n2;
      p := 0.0;
      n2 := 0.0;
    end;
  end;
  SSF1F2 := SSF1F2 - SSF1 - SSF2 - Constant;

  // get ss for row x slice interaction
  for i := 0 to NoGrpsA - 1 do
  begin
    for k := 0 to NoGrpsC - 1 do
    begin
      for j := 0 to NoGrpsB - 1 do
      begin
        p := p + wsum[i,j,k];
        n2 := n2 + ncnt[i,j,k];
      end;
      SSF1F3 := SSF1F3 + p * p / n2;
      p := 0.0;
      n2 := 0.0;
    end;
  end;
  SSF1F3 := SSF1F3 - SSF1 - SSF3 - Constant;

  // get ss for columns x slices interaction
  for j := 0 to NoGrpsB - 1 do
  begin
    for k := 0 to NoGrpsC - 1 do
    begin
      for i := 0 to NoGrpsA - 1 do
      begin
        p := p + wsum[i,j,k];
        n2 := n2 + ncnt[i,j,k];
      end;
      SSF2F3 := SSF2F3 + p * p / n2;
      p := 0.0;
      n2 := 0.0;
    end;
  end;
  SSF2F3 := SSF2F3 - SSF2 - SSF3 - Constant;

(*
  // get ss for cells
  for (i := 0; i < NoGrpsA; i++)
       for (j := 0; j < NoGrpsB; j++)
            for (k := 0; k < NoGrpsC; k++)
                 SSCells := SSCells + ((wsum[i][j][k] * wsum[i][j][k]) / ncnt[i][j][k]);

  SSF1F2F3 := SSCells - SSF1 - SSF2 - SSF3 - SSF1F2 - SSF1F3 - SSF2F3 - Constant;
*)

  for i := 0 to NoGrpsA - 1 do
  begin
    rowmean := RowSums[i] / RowCount[i];
    for j := 0 to NoGrpsB - 1 do
    begin
      colmean := ColSums[j] / ColCount[j];
      for k := 0 to NoGrpsC - 1 do
      begin
        slicemean := SlcSums[k] / SlcCount[k];
        SSNonAdd := SSNonAdd + (colmean-GrandMean) * (rowmean-GrandMean) * (slicemean-GrandMean) * wsum[i,j,k];
      end;
    end;
  end;

  SSDep := SSDep - Constant;
  if not InteractBtn.Checked then
    SSErr := SSDep - (SSF1 + SSF2 + SSF3)
  else
    SSErr := SSDep - (SSF1 + SSF2 + SSF3 + SSF1F2 + SSF1F3 + SSF2F3);
  SSNonAdd := SSNonAdd * SSNonAdd / (SSF1 * SSF2 * SSF3);
  SSNonAdd := SSNonAdd * NoGrpsA * NoGrpsB * NoGrpsC * NoGrpsA * NoGrpsB * NoGrpsC;
  MSNonAdd := SSNonAdd;
  SSBalance := SSErr - SSNonAdd;

  if ((SSF1 < 0.0) or (SSF2 < 0.0) or (SSF3 < 0.0) or (SSF1F2 < 0.0) or (SSF1F3 < 0.0) or (SSF2F3 < 0.0)) then
  begin
    MessageDlg('A negative SS found. Unbalanced Design? Ending analysis.', mtInformation, [mbOK], 0);
    CompError := true;
    exit;
  end;

  DFTot := N - 1;
  DFF1 := NoGrpsA - 1;
  DFF2 := NoGrpsB - 1;
  DFF3 := NoGrpsC - 1;
  DFF1F2 := DFF1 * DFF2;
  DFF1F3 := DFF1 * DFF3;
  DFF2F3 := DFF2 * DFF3;
  if not InteractBtn.Checked then
    DFErr := DFTot - DFF1 - DFF2 - DFF3
  else
    DFErr := DFTot - DFF1 - DFF2 - DFF3 - DFF1F2 - DFF1F3 - DFF2F3;
  DFBalance := DFErr - 1;
  MSF1 := SSF1 / DFF1;
  MSF2 := SSF2 / DFF2;
  MSF3 := SSF3 / DFF3;
  MSF1F2 := SSF1F2 / DFF1F2;
  MSF1F3 := SSF1F3 / DFF1F3;
  MSF2F3 := SSF2F3 / DFF2F3;
  MSErr := SSErr / DFErr;
  MSDep := SSDep / DFTot;
  MSBalance := SSBalance / DFBalance;
  OmegaF1 := (SSF1 - DFF1 * MSErr) / (SSDep + MSErr);
  OmegaF2 := (SSF2 - DFF2 * MSErr) / (SSDep + MSErr);
  OmegaF3 := (SSF3 - DFF3 * MSErr) / (SSDep + MSErr);
  OmegaF1F2 := (SSF1F2 - DFF1F2 * MSErr) / (SSDep + MSErr);
  OmegaF1F3 := (SSF1F3 - DFF1F3 * MSErr) / (SSDep + MSErr);
  OmegaF2F3 := (SSF2F3 - DFF2F3 * MSErr) / (SSDep + MSErr);
  if not InteractBtn.Checked then
    Omega := OmegaF1 + OmegaF2 + OmegaF3
  else
    Omega := OmegaF1 + OmegaF2 + OmegaF3 + OmegaF1F2 + OmegaF1F3 +  OmegaF2F3;
  MeanDep := MeanDep / N;

  FF1 := abs(MSF1 / MSErr);
  FF2 := abs(MSF2 / MSErr);
  FF3 := abs(MSF3 / MSErr);
  FF1F2 := abs(MSF1F2 / MSErr);
  FF1F3 := abs(MSF1F3 / MSErr);
  FF2F3 := abs(MSF2F3 / MSErr);
  if (MSBalance > 0.0) then
    FNonAdd := MSNonAdd / MSBalance
  else
    FNonAdd := 0.0;

  ProbF1 := probf(FF1,DFF1,DFErr);
  ProbF2 := probf(FF2,DFF2,DFErr);
  ProbF3 := probf(FF3,DFF3,DFErr);
  ProbF1F2 := probf(FF1F2,DFF1F2,DFErr);
  ProbF1F3 := probf(FF1F3,DFF1F3,DFErr);
  ProbF2F3 := probf(FF2F3,DFF2F3,DFErr);
  ProbNonAdd := probf(FNonAdd,1.0,DFBalance);

  if (ProbF1 > 1.0) then ProbF1 := 1.0;
  if (ProbF2 > 1.0) then ProbF2 := 1.0;
  if (ProbF3 > 1.0) then ProbF3 := 1.0;
  if (ProbF1F2 > 1.0) then ProbF1F2 := 1.0;
  if (ProbF1F3 > 1.0) then ProbF1F3 := 1.0;
  if (ProbF2F3 > 1.0) then ProbF2F3 := 1.0;

  // Obtain omega squared (proportion of dependent variable explained)
  if (OmegaF1 < 0.0) then OmegaF1 := 0.0;
  if (OmegaF2 < 0.0) then OmegaF2 := 0.0;
  if (OmegaF3 < 0.0) then OmegaF3 := 0.0;
  if (OmegaF1F2 < 0.0) then OmegaF1F2 := 0.0;
  if (OmegaF1F3 < 0.0) then OmegaF1F3 := 0.0;
  if (OmegaF2F3 < 0.0) then OmegaF2F3 := 0.0;
  if (Omega < 0.0) then Omega := 0.0;
end;

procedure TOneCaseAnovaForm.ThreeWayTable(AReport: TStrings);
var
  i, j, k: integer;
  XBar, V, S, RowSS, ColSS, SlcSS: double;
begin
  if CompError then
    exit;

  AReport.Add('THREE-WAY ANALYSIS OF VARIANCE');
  AReport.Add('');
  AReport.Add('Variable analyzed:           %s', [DepVar.Text]);
  AReport.Add('');
  AReport.Add('Factor A (rows) variable:    %s', [Factor1.Text]);
  AReport.Add('Factor B (columns) variable: %s', [Factor2.Text]);
  AReport.Add('Factor C (slices) variable:  %s', [Factor3.Text]);
  AReport.Add('');
  AReport.Add('SOURCE         D.F.        SS            MS             F      PROB.> F   Omega Squared');
  AReport.Add('');
  AReport.Add('Among Rows     %4.0f  %12.4f  %12.4f  %12.4f  %6.3f     %6.3f', [DFF1, SSF1, MSF1, FF1, ProbF1, OmegaF1]);
  AReport.Add('Among Columns  %4.0f  %12.4f  %12.4f  %12.4f  %6.3f     %6.3f', [DFF2, SSF2, MSF2, FF2, ProbF2, OmegaF2]);
  AReport.Add('Among Slices   %4.0f  %12.4f  %12.4f  %12.4f  %6.3f     %6.3f', [DFF3, SSF3, MSF3, FF3, ProbF3, OmegaF3]);

  if InteractBtn.Checked then
  begin
    AReport.Add('A x B Inter.   %4.0f  %12.4f  %12.4f  %12.4f  %6.3f     %6.3f', [DFF1F2, SSF1F2, MSF1F2, FF1F2, ProbF1F2, OmegaF1F2]);
    AReport.Add('A x C Inter.   %4.0f  %12.4f  %12.4f  %12.4f  %6.3f     %6.3f', [DFF1F3, SSF1F3, MSF1F3, FF1F3, ProbF1F3, OmegaF1F3]);
    AReport.Add('B x C Inter.   %4.0f  %12.4f  %12.4f  %12.4f  %6.3f     %6.3f', [DFF2F3, SSF2F3, MSF2F3, FF2F3, ProbF2F3, OmegaF2F3]);
  end;
  AReport.Add('Residual       %4.0f  %12.4f  %12.4f', [DFErr, SSErr, MSErr]);
  AReport.Add(' NonAdditivity %4.0f  %12.4f  %12.4f  %12.4f  %6.3f', [1.0, SSNonAdd, MSNonAdd, FNonAdd, ProbNonAdd]);
  AReport.Add(' Balance       %4.0f  %12.4f  %12.4f', [DFBalance, SSBalance, MSBalance]);
  AReport.Add('Total          %4.0f  %12.4f  %12.4f', [DFTot, SSDep, MSDep]);
  AReport.Add('');
  AReport.Add('Omega squared for combined effects := %8.4f', [Omega]);
  AReport.Add('');
  AReport.Add('');
  AReport.Add('Descriptive Statistics');
  AReport.Add('');
  AReport.Add('GROUP              N     MEAN   VARIANCE  STD.DEV.');
  equal_grp := true;

  // Display cell means, variances, standard deviations
  for i := 0 to NoGrpsA - 1 do
  begin
    for j := 0 to NoGrpsB - 1 do
    begin
      for k := 0 to NoGrpsC - 1 do
      begin
        XBar := wsum[i,j,k] / ncnt[i,j,k];        // wp: why this? Result is not used and overwritten in next loop.
        V := 0.0;                                 //   dto.
        S := 0.0;                                 //   dto.
      end;
    end;
  end;

  //Display Row means, variances, standard deviations
  for i := 0 to NoGrpsA - 1 do
  begin
    XBar := RowSums[i] / RowCount[i];
    OrdMeansA[i] := XBar;
    RowSS := 0.0;
    for j := 0 to NoGrpsB - 1 do
      for k := 0 to NoGrpsC - 1 do
        RowSS := RowSS + wx2[i,j,k];
    V := RowSS - (RowSums[i] * RowSums[i] / RowCount[i]);
    V := V / (RowCount[i] - 1.0);
    S := sqrt(V);
    AReport.Add('Row   %3d         %3.0f  %8.3f  %8.3f  %8.3f', [minf1+i, RowCount[i], XBar, V, S]);
  end;

  //Display means, variances and standard deviations for columns
  for j := 0 to NoGrpsB - 1 do
  begin
    XBar := ColSums[j] / ColCount[j];
    OrdMeansB[j] := XBar;
    ColSS := 0.0;
    for i := 0 to NoGrpsA - 1 do
      for k := 0 to NoGrpsC - 1 do
        ColSS := ColSS + wx2[i,j,k];
    V := ColSS - (ColSums[j] * ColSums[j] / ColCount[j]);
    V := V / (ColCount[j] - 1.0);
    S := sqrt(V);
    AReport.Add('Col   %3d         %3.0f  %8.3f  %8.3f  %8.3f', [minf2+j, ColCount[j], XBar, V, S]);
  end;

  //Display means, variances and standard deviations for slices
  for k := 0 to NoGrpsC - 1 do
  begin
    XBar := SlcSums[k] / SlcCount[k];
    OrdMeansC[k] := XBar;
    SlcSS := 0.0;
    for i := 0 to NoGrpsA - 1 do
      for j := 0 to NoGrpsB - 1 do
        SlcSS := SlcSS + wx2[i,j,k];
    V := SlcSS - (SlcSums[k] * SlcSums[k] / SlcCount[k]);
    V := V / (SlcCount[k] - 1.0);
    S := sqrt(V);
    AReport.Add('Slice %3d         %3.0f  %8.3f  %8.3f  %8.3f', [minf3+k, SlcCount[k], XBar, V, S]);
  end;

  AReport.Add('TOTAL             %3d  %8.3f  %8.3f  %8.3f', [N, MeanDep, MSDep, sqrt(MSDep)]);
  AReport.Add('');
  AReport.Add('');
end;

procedure TOneCaseAnovaForm.ThreeWayPlot;
var
  i, j, k: integer;
  maxmean, XBar: double;
  XValue: DblDyneVec;
  plottype: integer;
begin
  if CompError then
    exit;

  case PlotOptionsBox.ItemIndex of
    0: exit;
    1: plotType := 2;    // 3D bars
    2: plotType := 1;    // 2D bars
    3: plotType := 9;    // 2D horizontal bars
    else raise Exception.Create('Plot type not supported.');
  end;

  SetLength(XValue,totcells);

  //  Factor A first
  GraphFrm.SetLabels[1] := 'FACTOR A';
  maxmean := 0.0;
  SetLength(GraphFrm.Xpoints, 1, Nf1cells);
  SetLength(GraphFrm.Ypoints, 1, Nf1cells);
  for i := 0 to Nf1cells - 1 do
  begin
    RowSums[i] := RowSums[i] / RowCount[i];
    GraphFrm.Ypoints[0,i] := RowSums[i];
    if (RowSums[i] > maxmean) then maxmean := RowSums[i];
    XValue[i] := minf1 + i;
    GraphFrm.Xpoints[0,i] := XValue[i];
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := Nf1cells;
  GraphFrm.Heading := Factor1.Text;
  GraphFrm.XTitle := Factor1.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clCream;
  GraphFrm.WallColor := clDkGray;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;

  //  Factor B next
  GraphFrm.SetLabels[1] := 'FACTOR B';
  maxmean := 0.0;
  SetLength(GraphFrm.Xpoints, 1, Nf2cells);
  SetLength(GraphFrm.Ypoints, 1, Nf2cells);
  for i := 0 to Nf2cells - 1 do
  begin
    ColSums[i] := ColSums[i] / ColCount[i];
    GraphFrm.Ypoints[0,i] := ColSums[i];
    if (ColSums[i] > maxmean) then maxmean := ColSums[i];
    XValue[i] := minf2 + i;
    GraphFrm.Xpoints[0,i] := XValue[i];
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := Nf2cells;
  GraphFrm.Heading := Factor2.Text;
  GraphFrm.XTitle := Factor2.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clCream;
  GraphFrm.WallColor := clDkGray;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;

  //  Factor C next
  GraphFrm.SetLabels[1] := 'FACTOR C';
  maxmean := 0.0;
  SetLength(GraphFrm.Xpoints, 1, Nf3cells);
  SetLength(GraphFrm.Ypoints, 1, Nf3cells);
  for i := 0 to Nf3cells - 1 do
  begin
    SlcSums[i] := SlcSums[i] / SlcCount[i];
    GraphFrm.Ypoints[0,i] := SlcSums[i];
    if (SlcSums[i] > maxmean) then  maxmean := SlcSums[i];
    XValue[i] := minf3 + i;
    GraphFrm.Xpoints[0,i] := XValue[i];
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := Nf3cells;
  GraphFrm.Heading := Factor3.Text;
  GraphFrm.XTitle := Factor2.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clCream;
  GraphFrm.WallColor := clDkGray;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;

  //  Factor A x B Interaction within each slice next
  SetLength(GraphFrm.Ypoints, Nf1cells, Nf2cells);
  SetLength(GraphFrm.Xpoints, 1, Nf2cells);
  for k := 0 to Nf3cells - 1 do
  begin
    maxmean := 0.0;
    for i := 0 to Nf1cells - 1 do
    begin
      GraphFrm.SetLabels[i+1] := Factor1.Text + ' ' + IntToStr(i+1);
      for j := 0 to Nf2cells - 1 do
      begin
        XBar := wsum[i,j,k] / ncnt[i,j,k];
        if (XBar > maxmean) then maxmean := XBar;
        GraphFrm.Ypoints[i,j] := XBar;
      end;
    end;
    for j := 0 to Nf2cells - 1 do
    begin
      XValue[j] := minf2 + j ;
      GraphFrm.Xpoints[0,j] := XValue[j];
    end;

    GraphFrm.nosets := Nf1cells;
    GraphFrm.nbars := Nf2cells;
    GraphFrm.Heading := 'Factor A x Factor B Within C ' + IntToStr(k+1);
    GraphFrm.XTitle := Factor2.Text + ' Codes';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.2;
    GraphFrm.AutoScaled := false;
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.GraphType := plottype;
    GraphFrm.BackColor := clCream;
    GraphFrm.WallColor := clDkGray;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;
  end;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;

  //  Factor A x C Interaction within each Column next
  SetLength(GraphFrm.Xpoints, 1, Nf3cells);
  SetLength(GraphFrm.Ypoints, Nf1cells, Nf3cells);
  for j := 0 to Nf2cells - 1 do
  begin
    maxmean := 0.0;
    for i := 0 to Nf1cells - 1 do
    begin
      GraphFrm.SetLabels[i+1] := Factor1.Text + ' ' + IntToStr(i+1);
      for k := 0 to Nf3cells - 1 do
      begin
        XBar := wsum[i,j,k] / ncnt[i,j,k];
        if (XBar > maxmean) then maxmean := XBar;
        GraphFrm.Ypoints[i,k] := XBar;
      end;
    end;
    for k := 0 to Nf3cells - 1 do
    begin
      XValue[k] := minf3 + k;
      GraphFrm.Xpoints[0,k] := XValue[k];
    end;

    GraphFrm.nosets := Nf1cells;
    GraphFrm.nbars := Nf3cells;
    GraphFrm.Heading := 'Factor A x Factor C Within B ' + IntToStr(j+1);
    GraphFrm.XTitle := Factor3.Text + ' Codes';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.2;
    GraphFrm.AutoScaled := false;
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.GraphType := plottype;
    GraphFrm.BackColor := clCream;
    GraphFrm.WallColor := clDkGray;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;
  end;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;

  //  Factor B x C Interaction within each row next
  SetLength(GraphFrm.Xpoints, 1, Nf3cells);
  SetLength(GraphFrm.Ypoints, Nf2cells, Nf3cells);
  for i := 0 to Nf1cells - 1 do
  begin
    maxmean := 0.0;
    for j := 0 to Nf2cells - 1 do
    begin
      GraphFrm.SetLabels[j+1] := Factor2.Text + ' ' + IntToStr(j+1);
      for k := 0 to Nf3cells - 1 do
      begin
        XBar := wsum[i,j,k] / ncnt[i,j,k];
        if (XBar > maxmean) then maxmean := XBar;
        GraphFrm.Ypoints[j,k] := XBar;
      end;
    end;
    for j := 0 to Nf3cells - 1 do
    begin
      XValue[j] := minf3 + j;
      GraphFrm.Xpoints[0,j] := XValue[j];
    end;

    GraphFrm.nosets := Nf2cells;
    GraphFrm.nbars := Nf3cells;
    GraphFrm.Heading := 'Factor B x Factor C Within A ' + IntToStr(i+1);
    GraphFrm.XTitle := Factor3.Text + ' Codes';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.2;
    GraphFrm.AutoScaled := false;
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.GraphType := plottype;
    GraphFrm.BackColor := clCream;
    GraphFrm.WallColor := clDkGray;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;
  end; // next row
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
  XValue := nil;
end;

procedure TOneCaseAnovaForm.TwoWayContrasts(AReport: TStrings);
var
  i, j: integer;
  value, alpha: double;
  variances: DblDyneVec;
  RowSS, ColSS: double;
begin
  if not comparisons then
    exit;
  if CompError then
    exit;

  SetLength(variances, totcells);
  alpha := StrToFloat(PostAlpha.Text);

  //  row comparisons
  if (Nf1cells > 2) and (ProbF1 < Overall) then
  begin
    for i := 0 to NoGrpsA - 1 do
    begin
      RowSS := 0.0;
      for j := 0 to NoGrpsB - 1 do RowSS := RowSS + vars[i,j];
      variances[i] := RowSS - sqr(RowSums[i]) / RowCount[i];
      variances[i] := variances[i] / (RowCount[i] - 1.0);
    end;

    AReport.Add('');
    AReport.Add('COMPARISONS AMONG ROWS');

    // get smallest group size
    value := 1e308;
    for i := 0 to Nf1cells - 1 do
      if (RowCount[i] < value) then value := RowCount[i];

    if ScheffeChk.Checked then
      ScheffeTest(MSErr, RowSums, RowCount, minf1, maxf1, N, posthocAlpha, AReport);
    if TukeyHSDChk.Checked and equal_grp then
      Tukey(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
    if TukeyBChk.Checked and equal_grp then
      TukeyBTest(MSErr, DFErr, RowSums, RowCount, minf1, maxf1, value, posthocAlpha, AReport);
    if TukeyKramerChk.Checked and equal_grp then
      Tukey_Kramer(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
//       if (BonferroniChk.Checked) then
//          Bonferroni(RowSums,RowCount,variances,minf1,maxf1, AReport);
//       if (OrthogonalChk.Checked) then
//           CONTRASTS(MSErr,DFErr,RowSums,RowCount,minf1,maxf1,Alpha, AReport);
    if NewmanKeulsChk.Checked and equal_grp then
      Newman_Keuls(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
  end;

  //  column comparisons
  if (Nf2cells > 2) and (ProbF2 < Alpha) then
  begin
    for j := 0 to NoGrpsB - 1 do
    begin
      ColSS := 0.0;
      for i := 0 to NoGrpsA - 1 do ColSS := ColSS + vars[i,j];
      variances[j] := ColSS - (ColSums[j] * ColSums[j] / ColCount[j]);
      variances[j] := variances[j] / (ColCount[j] - 1.0);
    end;
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG COLUMNS');
    value := 1e308;
    for i := 0 to Nf2cells - 1 do
      if (ColCount[i] < value) then value := ColCount[i];

    if ScheffeChk.Checked then
      ScheffeTest(MSErr, ColSums, ColCount, minf2, maxf2, N, posthocAlpha, AReport);
    if TukeyHSDChk.Checked and equal_grp then
      Tukey(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
    if TukeyBChk.Checked and equal_grp then
      TukeyBTest(MSErr, DFErr, ColSums, ColCount, minf2, maxf2, value, posthocAlpha, AReport);
    if TukeyKramerChk.Checked and equal_grp then
      Tukey_Kramer(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
//       if (BonferroniChk.Checked) then
//          Bonferroni(ColSums,ColCount,variances,minf2,maxf2, AReport);
//       if (OrthogonalChk.Checked) then
//           CONTRASTS(MSErr,DFErr,ColSums,ColCount,minf2,maxf2,Alpha, AReport);
    if NewmanKeulsChk.Checked and equal_grp then
      Newman_Keuls(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
  end;

  //  simple effects for columns within each row
  if (ProbF3 < Alpha) then
  begin
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG COLUMNS WITHIN EACH ROW');
    for i := 0 to Nf1cells - 1 do
    begin
      AReport.Add('');
      AReport.Add('ROW %d COMPARISONS', [i+1]);
      // move cell sums and counts to cellsums and cellcnts
      for j := 0 to Nf2cells - 1 do
      begin
        cellsums[j] := sums[i,j];
        cellcnts[j] := counts[i,j];
        cellvars[j] := vars[i,j];
      end;
      value := 1e308;
      for j := 0 to Nf2cells - 1 do
        if (cellcnts[j] < value) then value := cellcnts[j];

      if ScheffeChk.Checked then
        ScheffeTest(MSErr, cellsums, cellcnts, minf2, maxf2, N, posthocAlpha, AReport);
      if TukeyHSDChk.Checked and equal_grp then
        Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
      if TukeyBChk.Checked and equal_grp then
        TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, value, posthocAlpha, AReport);
      if TukeyKramerChk.Checked and equal_grp then
        Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
//            if (BonferroniChk.Checked) then
//               Bonferroni(cellsums,cellcnts,cellvars,minf2,maxf2, AReport);
//            if (OrthogonalChk.Checked) then
//               CONTRASTS(MSErr,DFErr,cellsums,cellcnts,minf2,maxf2,0.05, AReport);
      if NewmanKeulsChk.Checked and equal_grp then
        Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
    end;
  end;

  //  simple effects for rows within each column
  if (ProbF3 < Alpha) then
  begin
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG ROWS WITHIN EACH COLUMN');
    for j := 0 to Nf2cells - 1 do
    begin
      AReport.Add('');
      AReport.Add('COLUMN %d COMPARISONS', [j+1]);
      // move cell sums and counts to cellsums and cellcnts
      for i := 0 to Nf1cells - 1 do
      begin
        cellsums[i] := sums[i,j];
        cellcnts[i] := counts[i,j];
        cellvars[i] := vars[i,j];
      end;
      value := 1e308;
      for i := 0 to Nf1cells - 1 do
        if (cellcnts[j] < value) then value := cellcnts[j];

      if ScheffeChk.Checked then
        ScheffeTest(MSErr, cellsums, cellcnts, minf1, maxf1, N, posthocAlpha, AReport);
      if TukeyHSDChk.Checked and equal_grp then
        Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
      if TukeyBChk.Checked and equal_grp then
        TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, value, posthocAlpha, AReport);
      if TukeyKramerChk.Checked and equal_grp then
        Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
//            if (BonferroniChk.Checked) then
//               Bonferroni(cellsums,cellcnts,cellvars,minf1,maxf1, AReport);
//            if (OrthogonalChk.Checked) then
//               CONTRASTS(MSErr,DFErr,cellsums,cellcnts,minf1,maxf1,0.05, AReport);
      if NewmanKeulsChk.Checked and equal_grp then
        Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
    end;
  end;
  variances := nil;
end;

procedure TOneCaseAnovaForm.ThreeWayContrasts(AReport: TStrings);
var
  i, j, k: integer;
  value, alpha: double;
  variances: DblDyneVec;
  RowSS, ColSS, SlcSS: double;
begin
  if not comparisons then
    exit;
  if CompError then
    exit;

  alpha := StrToFloat(PostAlpha.Text);
  if not (ScheffeChk.Checked or TukeyHSDChk.Checked or TukeyBChk.Checked or
          TukeyKramerChk.Checked or NewmanKeulsChk.Checked) then exit;

  SetLength(variances, totcells);

  //  row comparisons
  if (Nf1cells > 2) and (ProbF1 < Alpha) then
  begin
    for i := 0 to NoGrpsA - 1 do
    begin
      RowSS := 0.0;
      for j := 0 to NoGrpsB - 1 do
        for k := 0 to NoGrpsC - 1 do
          RowSS := RowSS + wx2[i,j,k];
      variances[i] := RowSS - sqr(RowSums[i]) / RowCount[i];
      variances[i] := variances[i] / (RowCount[i] - 1.0);
    end;
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG ROWS');

    // get smallest group size
    value := 1e308;
    for i := 0 to Nf1cells - 1 do
      if (RowCount[i] < value) then value := RowCount[i];

    if ScheffeChk.Checked then
      ScheffeTest(MSErr, RowSums, RowCount, minf1, maxf1, N, posthocAlpha, AReport);
    if TukeyHSDChk.Checked and equal_grp then
      Tukey(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
    if TukeyBChk.Checked and equal_grp then
      TukeyBTest(MSErr, DFErr, RowSums, RowCount, minf1, maxf1, value, posthocAlpha, AReport);
    if TukeyKramerChk.Checked and equal_grp then
      Tukey_Kramer(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
//       if (BonferroniChk.Checked) then
//          Bonferroni(RowSums,RowCount,variances,minf1,maxf1, AReport);
//       if (OrthogonalChk.Checked) then
//           CONTRASTS(MSErr,DFErr,RowSums,RowCount,minf1,maxf1,Alpha, AReport);
    if NewmanKeulsChk.Checked and equal_grp then
      Newman_Keuls(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
  end;

  //  column comparisons
  if (Nf2cells > 2) and (ProbF2 < Alpha) then
  begin
    for j := 0 to NoGrpsB - 1 do
    begin
      ColSS := 0.0;
      for i := 0 to NoGrpsA - 1 do
        for k := 0 to NoGrpsC - 1 do
          ColSS := ColSS + wx2[i,j,k];
      variances[j] := ColSS - sqr(ColSums[j]) / ColCount[j];
      variances[j] := variances[j] / (ColCount[j] - 1.0);
    end;
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG COLUMNS');
    value := 1e308;
    for i := 0 to Nf2cells - 1 do
      if (ColCount[i] < value) then value := ColCount[i];

    if ScheffeChk.Checked then
      ScheffeTest(MSErr, ColSums, ColCount, minf2, maxf2, N, posthocAlpha, AReport);
    if TukeyHSDChk.Checked and equal_grp then
      Tukey(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
    if TukeyBChk.Checked and equal_grp then
      TukeyBTest(MSErr, DFErr, ColSums, ColCount, minf2, maxf2, value, posthocAlpha, AReport);
    if TukeyKramerChk.Checked and equal_grp then
      Tukey_Kramer(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
//       if (BonferroniChk.Checked) then
//          Bonferroni(ColSums,ColCount,variances,minf2,maxf2, AReport);
//       if (OrthogonalChk.Checked) then
//           CONTRASTS(MSErr,DFErr,ColSums,ColCount,minf2,maxf2,Alpha, AReport);
    if NewmanKeulsChk.Checked and equal_grp then
      Newman_Keuls(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
  end;

  //  slice comparisons
  if (Nf3cells > 2) and (ProbF3 < Alpha) then
  begin
    for k := 0 to NoGrpsC - 1 do
    begin
      SlcSS := 0.0;
      for i := 0 to NoGrpsA - 1 do
        for j := 0  to NoGrpsB - 1 do SlcSS := SlcSS + wx2[i,j,k];
      variances[k] := SlcSS - sqr(SlcSums[k]) / SlcCount[k];
      variances[k] := variances[k] / (SlcCount[k] - 1.0);
    end;
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG SLICES');
    value := 1e308;
    for i := 0 to Nf3cells - 1 do
      if (SlcCount[i] < value) then value := SlcCount[i];

    if ScheffeChk.Checked then
      ScheffeTest(MSErr, SlcSums, SlcCount, minf3, maxf3, N, posthocAlpha, AReport);
    if TukeyHSDChk.Checked and equal_grp then
      Tukey(MSErr, DFErr, value, SlcSums, SlcCount, minf3, maxf3, posthocAlpha, AReport);
    if TukeyBChk.Checked and equal_grp then
      TukeyBTest(MSErr, DFErr, SlcSums, SlcCount, minf3, maxf3, value, posthocAlpha, AReport);
    if TukeyKramerChk.Checked and equal_grp then
      Tukey_Kramer(MSErr, DFErr, value, SlcSums, SlcCount, minf3, maxf3, posthocAlpha, AReport);
//       if (BonferroniChk.Checked) then
//          Bonferroni(SlcSums,SlcCount,variances,minf3,maxf3, AReport);
//       if (OrthogonalChk.Checked) then
//           CONTRASTS(MSErr,DFErr,SlcSums,SlcCount,minf3,maxf3,Alpha, AReport);
    if NewmanKeulsChk.Checked and equal_grp then
      Newman_Keuls(MSErr, DFErr, value, SlcSums, SlcCount, minf3, maxf3, posthocAlpha, AReport);
  end;

  //  simple effects for columns within each row
  if (ProbF1F2 < Alpha) then
  begin
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG COLUMNS WITHIN EACH ROW');
    for i := 0 to Nf1cells - 1 do
    begin
      AReport.Add('');
      AReport.Add('ROW %d COMPARISONS', [i+1]);
      // move cell sums && counts to cellsums && cellcnts
      for j := 0 to Nf2cells - 1 do
      begin
        for k := 0 to Nf3cells - 1 do
        begin
          cellsums[j] := wsum[i,j,k];
          cellcnts[j] := ncnt[i,j,k];
          cellvars[j] := wx2[i,j,k];
        end;
      end;
      value := 1e308;
      for j := 0 to Nf2cells - 1 do
        if (cellcnts[j] < value) then value := cellcnts[j];

      if ScheffeChk.Checked then
        ScheffeTest(MSErr, cellsums, cellcnts, minf2, maxf2, N, posthocAlpha, AReport);
      if TukeyHSDChk.Checked and equal_grp then
        Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
      if TukeyBChk.Checked and equal_grp then
        TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, value, posthocAlpha, AReport);
      if TukeyKramerChk.Checked and equal_grp then
        Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
//            if (BonferroniChk.Checked) then
//               Bonferroni(cellsums,cellcnts,cellvars,minf2,maxf2, AReport);
//            if (OrthogonalChk.Checked) then
//               CONTRASTS(MSErr,DFErr,cellsums,cellcnts,minf2,maxf2,0.05, AReport);
      if NewmanKeulsChk.Checked and equal_grp then
        Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
    end;
  end;

  //  simple effects for rows within each column
  if (ProbF1F2 < Alpha) then
  begin
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG ROWS WITHIN EACH COLUMN');
    for j := 0 to Nf2cells - 1 do
    begin
      AReport.Add('');
      AReport.Add('COLUMN %d COMPARISONS', [j+1]);
      // move cell sums && counts to cellsums && cellcnts
      for i := 0 to Nf1cells - 1 do
      begin
        for k := 0 to Nf3cells - 1 do
        begin
          cellsums[i] := wsum[i,j,k];
          cellcnts[i] := ncnt[i,j,k];
          cellvars[i] := wx2[i,j,k];
        end;
      end;
      value := 1e308;
      for i := 0 to Nf1cells - 1 do
        if (cellcnts[j] < value) then value := cellcnts[j];

      if ScheffeChk.Checked then
        ScheffeTest(MSErr, cellsums, cellcnts, minf1, maxf1, N, posthocAlpha, AReport);
      if TukeyHSDChk.Checked and equal_grp then
        Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
      if TukeyBChk.Checked and equal_grp then
        TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, value, posthocAlpha, AReport);
      if TukeyKramerChk.Checked and equal_grp then
        Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
//            if (BonferroniChk.Checked) then
//               Bonferroni(cellsums,cellcnts,cellvars,minf1,maxf1, AReport);
//            if (OrthogonalChk.Checked) then
//               CONTRASTS(MSErr,DFErr,cellsums,cellcnts,minf1,maxf1,0.05, AReport);
      if NewmanKeulsChk.Checked and equal_grp then
        Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
    end;
  end;

  //  simple effects for columns within each slice
  if (ProbF2F3 < Alpha) then
  begin
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG COLUMNS WITHIN EACH SLICE');
    for k := 0 to Nf3cells - 1 do
    begin
      AReport.Add('');
      AReport.Add('SLICE %d COMPARISONS', [k+1]);
      // move cell sums && counts to cellsums && cellcnts
      for j := 0 to Nf2cells - 1 do
      begin
        for i := 0 to Nf1cells - 1 do
        begin
          cellsums[j] := wsum[i,j,k];
          cellcnts[j] := ncnt[i,j,k];
          cellvars[j] := wx2[i,j,k];
        end;
      end;
      value := 1e308;
      for j := 0 to Nf2cells-1 do
        if (cellcnts[j] < value) then value := cellcnts[j];

      if ScheffeChk.Checked then
        ScheffeTest(MSErr, cellsums, cellcnts, minf2, maxf2, N, posthocAlpha, AReport);
      if TukeyHSDChk.Checked and equal_grp then
        Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
      if TukeyBChk.Checked and equal_grp then
        TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, value, posthocAlpha, AReport);
      if TukeyKramerChk.Checked and equal_grp then
        Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
//            if (BonferroniChk.Checked) then
//               Bonferroni(cellsums, cellcnts, cellvars, minf2, maxf2, posthocAlpha, AReport);
//            if (OrthogonalChk.Checked) then
//               CONTRASTS(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
      if NewmanKeulsChk.Checked and equal_grp then
        Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
    end;
  end;

  //  simple effects for rows within each slice
  if (ProbF1F3 < Alpha) then
  begin
    AReport.Add('');
    AReport.Add('COMPARISONS AMONG ROWS WITHIN EACH SLICE');
    for k := 0 to Nf3cells - 1 do
    begin
      AReport.Add('');
      AReport.Add('SLICE %d COMPARISONS', [k+1]);
      // move cell sums && counts to cellsums && cellcnts
      for i := 0 to Nf1cells - 1 do
      begin
        for j := 0 to Nf2cells - 1 do
        begin
          cellsums[j] := wsum[i,j,k];
          cellcnts[j] := ncnt[i,j,k];
          cellvars[j] := wx2[i,j,k];
        end;
      end;
      value := 1e308;
      for i := 0 to Nf1cells - 1 do
        if (cellcnts[i] < value) then value := cellcnts[i];

      if ScheffeChk.Checked then
        ScheffeTest(MSErr, cellsums, cellcnts, minf1, maxf1, N, posthocAlpha, AReport);
      if TukeyHSDChk.Checked and equal_grp then
        Tukey(MSErr,DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
      if TukeyBChk.Checked and equal_grp then
        TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, value, posthocAlpha, AReport);
      if TukeyKramerChk.Checked and equal_grp then
        Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
//            if (BonferroniChk.Checked) then
//               Bonferroni(cellsums,cellcnts,cellvars,minf1,maxf1, posthocAlpha, AReport);
//            if (OrthogonalChk.Checked) then
//               CONTRASTS(MSErr,DFErr,cellsums,cellcnts,minf1,maxf1,posthocAlpha, AReport);
      if NewmanKeulsChk.Checked and equal_grp then
        Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
    end;
  end;

  variances := nil;
end;

procedure TOneCaseAnovaForm.UpdateBtnStates;
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
  DepIn.Enabled := lSelected and (DepVar.Text = '');
  Fact1In.Enabled := lSelected and (Factor1.Text = '');
  Fact2In.Enabled := lSelected and (Factor2.Text = '');
  Fact3In.Enabled := lSelected and (Factor3.Text = '');
  DepOut.Enabled := DepVar.Text <> '';
  Fact1Out.Enabled := Factor1.Text <> '';
  Fact2Out.Enabled := Factor2.Text <> '';
  Fact3Out.Enabled := Factor3.Text <> '';
end;

procedure TOneCaseAnovaForm.VarListSelectionChange(Sender: TObject;
  User: boolean);
begin
  UpdateBtnStates;
end;

function TOneCaseAnovaForm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  X: Double;
begin
  Result := false;
  if (OverallAlpha.Text = '') then
  begin
    AControl := OverallAlpha;
    AMsg := 'No value specified for overall alpha.';
    exit;
  end;
  if not TryStrToFloat(OverallAlpha.Text, X) then
  begin
    AControl := OverallAlpha;
    AMsg := 'Overall alpha is not a valid number.';
    exit;
  end;

  if (PostAlpha.Text = '') then
  begin
    AControl := PostAlpha;
    AMsg := 'No value specified for post-hoc alpha.';
    exit;
  end;
  if not TryStrToFloat(PostAlpha.Text, x) then
  begin
    AControl := PostAlpha;
    AMsg := 'Post-hoc alpha is not a valid number.';
    exit;
  end;

  Result := true;
end;

initialization
  {$I onecaseanovaunit.lrs}

end.

