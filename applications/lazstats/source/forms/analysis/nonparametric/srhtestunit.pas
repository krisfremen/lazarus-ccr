unit SRHTestUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit, DataProcs, GraphLib,
  ContextHelpUnit;

type

  { TSRHTest }

  TSRHTest = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    DepVar: TEdit;
    Fact1In: TBitBtn;
    Fact1Out: TBitBtn;
    Fact2In: TBitBtn;
    Fact2Out: TBitBtn;
    Factor1: TEdit;
    Factor2: TEdit;
    GroupBox2: TGroupBox;
    HelpBtn: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Memo1: TLabel;
    OverallAlpha: TEdit;
    Plot2DLines: TCheckBox;
    Plot3DLines: TCheckBox;
    PlotMeans: TCheckBox;
    ResetBtn: TButton;
    ReturnBtn: TButton;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure Fact1InClick(Sender: TObject);
    procedure Fact1OutClick(Sender: TObject);
    procedure Fact2InClick(Sender: TObject);
    procedure Fact2OutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: boolean;
    NoSelected, intvalue, N : integer;
    ColNoSelected : IntDyneVec;
    outline, cellstring : string;
    SSDep, SSErr, SSF1, SSF2, SSF1F2 : double;
    MSDep, MSErr, MSF1, MSF2, MSF1F2 : double;
    DFTot, DFErr, DFF1, DFF2, DFF1F2 : double;
    Omega, OmegaF1, OmegaF2, OmegaF1F2: double;
    FF1, FF2, FF1F2, ProbF1, ProbF2, ProbF1F2 : double;
    DepVarCol, F1Col, F2Col, Nf1cells, Nf2cells : integer;
    MeanDep, MeanF1, MeanF2, X : double;
    minf1, maxf1, minf2, maxf2, nofactors, totcells : integer;
    cellcnts : DblDyneVec;    // array of cell counts
    cellvars : DblDyneVec;    // arrray of cell sums of squares then variances
    cellsums : DblDyneVec;    // array of cell sums then means
    equal_grp : boolean;   // check for equal groups for post-hoc tests
    counts : DblDyneMat;      // matrix for 2-way containing cell sizes
    sums : DblDyneMat;        // matrix for 2-way containing cell sums
    vars : DblDyneMat;        // matrix for 2-way containing sums of squares
    RowSums : DblDyneVec;     // 2 way row sums
    ColSums : DblDyneVec;     // 2 way col sums
    RowCount : DblDyneVec;    // 2 way row count
    ColCount : DblDyneVec;    // 2 way col count
    NoGrpsA, NoGrpsB : integer;
    OrdMeansA, OrdMeansB : DblDyneVec; // reordered means for f1, f2
    allAlpha : double; // alphas for tests
    CompError : boolean;

    procedure getlevels(Sender : TObject);
    procedure Calc2Way(Sender: TObject);
    procedure TwoWayTable(Sender: TObject);
    procedure TwoWayPlot(Sender: TObject);

  public
    { public declarations }
  end; 

var
  SRHTest: TSRHTest;

implementation

uses
  Math;

{ TSRHTest }

procedure TSRHTest.ResetBtnClick(Sender: TObject);
Var i : integer;
begin
  VarList.Clear;
  DepIn.Enabled := true;
  Fact1In.Enabled := true;
  Fact2In.Enabled := true;
  DepOut.Enabled := false;
  Fact1Out.Enabled := false;
  Fact2Out.Enabled := false;
  DepVar.Text := '';
  Factor1.Text := '';
  Factor2.Text := '';
  PlotMeans.Checked := false;
  OverAllalpha.Text := '0.05';
  for i := 1 to NoVariables do
       VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TSRHTest.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TSRHTest.DepInClick(Sender: TObject);
VAR index : integer;
begin
  index := VarList.ItemIndex;
  DepVar.Text := VarList.Items.Strings[index];
  DepIn.Enabled := false;
  DepOut.Enabled := true;
  VarList.Items.Delete(index);
end;

procedure TSRHTest.ComputeBtnClick(Sender: TObject);
Var
   i : integer;
Label  cleanit;
label  nexttwo;
begin
  OutputFrm.RichEdit.Clear;
  // initialize values
  SetLength(ColNoSelected,NoVariables);
  DepVarCol := 0;
  F1Col := 0;
  F2Col := 0;
  SSDep := 0.0;
  SSF1 := 0.0;
  SSF2 := 0.0;
  SSF1F2 := 0.0;
  MeanDep := 0.0;
  MeanF1 := 0.0;
  MeanF2 := 0.0;
  Nf1cells := 0;
  Nf2cells := 0;
  N := 0;
  NoSelected := 0;
  minf1 := 0;
  maxf1 := 0;
  minf2 := 0;
  maxf2 := 0;

  //  Get column numbers of dependent variable and factors
  for i := 1 to NoVariables do
  begin
       cellstring := OS3MainFrm.DataGrid.Cells[i,0];
       if cellstring = DepVar.Text then
       begin
            DepVarCol := i;
            NoSelected := NoSelected + 1;
            ColNoSelected[NoSelected-1] := DepVarCol;
       end;
       if cellstring = Factor1.Text then
       begin
            F1Col := i;
            NoSelected := NoSelected + 1;
            ColNoSelected[NoSelected-1] := F1Col;
       end;
       if cellstring = Factor2.Text then
       begin
            F2Col := i;
            NoSelected := NoSelected + 1;
            ColNoSelected[NoSelected-1] := F2Col;
       end;
  end;
  nofactors := 2;
  allAlpha := StrToFloat(OverAllalpha.Text);

  // get min and max of each factor code
  getlevels(self);

  // allocate space
  SetLength(cellcnts,totcells);  // array of cell counts
  SetLength(cellvars,totcells);  // arrray of cell sums of squares then variances
  SetLength(cellsums,totcells);  // array of cell sums then means

  // initialize array values
  for i := 1 to totcells do
  begin
       cellsums[i-1] := 0.0;
       cellvars[i-1] := 0.0;
       cellcnts[i-1] := 0;
  end;

  // do analysis
  SetLength(counts,Nf1cells,Nf2cells); // matrix for 2-way containing cell sizes
  SetLength(sums,Nf1cells,Nf2cells);  // matrix for 2-way containing cell sums
  SetLength(vars,Nf1cells,Nf2cells);  // matrix for 2-way containing sums of squares
  SetLength(RowSums,Nf1cells);  // 2 way row sums
  SetLength(ColSums,Nf2cells);  // 2 way col sums
  SetLength(RowCount,Nf1cells); // 2 way row count
  SetLength(ColCount,Nf2cells); // 2 way col count
  SetLength(OrdMeansA,Nf1cells); // ordered means for factor 1
  SetLength(OrdMeansB,Nf2cells); // ordered means for factor 2

  Calc2Way(self);
  if CompError then goto nexttwo;
  TwoWayTable(self);
  OutputFrm.ShowModal;
  if (PlotMeans.Checked) or (Plot2DLines.Checked)
             or (Plot3DLines.Checked) then TwoWayPlot(self);
nexttwo:    OrdMeansB := nil;
   OrdMeansA := nil;
   ColCount := nil;
   RowCount := nil;
   ColSums := nil;
   RowSums := nil;
   vars := nil;
   sums := nil;
   counts := nil;

cleanit:
  cellcnts := nil;
  cellvars := nil;
  cellsums := nil;
  ColNoSelected := nil;
end;

procedure TSRHTest.DepOutClick(Sender: TObject);
begin
  VarList.Items.Add(DepVar.Text);
  DepVar.Text := '';
  DepOut.Enabled := false;
  DepIn.Enabled := true;
end;

procedure TSRHTest.Fact1InClick(Sender: TObject);
VAR index : integer;
begin
  index := VarList.ItemIndex;
  if index = -1 then exit;
  Factor1.Text := VarList.Items.Strings[index];
  Fact1In.Enabled := false;
  Fact1Out.Enabled := true;
  VarList.Items.Delete(index);
end;

procedure TSRHTest.Fact1OutClick(Sender: TObject);
begin
  VarList.Items.Add(Factor1.Text);
  Factor1.Text := '';
  Fact1Out.Enabled := false;
  Fact1In.Enabled := true;
end;

procedure TSRHTest.Fact2InClick(Sender: TObject);
VAR index : integer;
begin
  index := VarList.ItemIndex;
  if index = -1 then exit;
  Factor2.Text := VarList.Items.Strings[index];
  Fact2In.Enabled := false;
  Fact2Out.Enabled := true;
  VarList.Items.Delete(index);
end;

procedure TSRHTest.Fact2OutClick(Sender: TObject);
begin
  VarList.Items.Add(Factor2.Text);
  Factor2.Text := '';
  Fact2Out.Enabled := false;
  Fact2In.Enabled := true;
end;

procedure TSRHTest.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := OverallAlpha.Top + OverallAlpha.Height - VarList.Top;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := True;
end;

procedure TSRHTest.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TSRHTest.getlevels(Sender: TObject);
VAR i : integer;
begin
  minf1 := 10000;
  maxf1 := -10000;
  for i := 1 to NoCases do
  begin
       if Not GoodRecord(i,NoSelected,ColNoSelected) then continue;
       intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
       if intvalue > maxf1 then maxf1 := intvalue;
       if intvalue < minf1 then minf1 := intvalue;
  end;
  Nf1cells := maxf1 - minf1 + 1;
  if nofactors > 1 then
  begin
       minf2 := 10000;
       maxf2 := -10000;
       for i := 1 to NoCases do
       begin
            if Not GoodRecord(i,NoSelected,ColNoSelected) then continue;
            intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i])));
            if intvalue > maxf2 then maxf2 := intvalue;
            if intvalue < minf2 then minf2 := intvalue;
       end;
       Nf2cells := maxf2 - minf2 + 1;
  end;
  totcells := Nf1cells + Nf2cells;
end;

procedure TSRHTest.Calc2Way(Sender: TObject);
var
   i, j : integer;
   grpA, grpB : integer;
   Constant, RowsTotCnt, ColsTotCnt, SSCells : double;
begin
  CompError := false;
  // initialize matrix values
  NoGrpsA := maxf1 - minf1 + 1;
  NoGrpsB := maxf2 - minf2 + 1;
  for i := 1 to NoGrpsA  do
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
  // get working totals
  for i := 1 to NoCases do
  begin
       if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
       grpA := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
       grpB := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i])));
       X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepVarCol,i]));
       grpA := grpA - minf1 + 1;
       grpB := grpB - minf2 + 1;
       counts[grpA-1,grpB-1] := counts[grpA-1,grpB-1] + 1;
       sums[grpA-1,grpB-1] := sums[grpA-1,grpB-1] + X;
       vars[grpA-1,grpB-1] := vars[grpA-1,grpB-1] + (X * X);
       RowSums[GrpA-1] := RowSums[GrpA-1] + X;
       ColSums[GrpB-1] := ColSums[GrpB-1] + X;
       RowCount[GrpA-1] := RowCount[GrpA-1] + 1.0;
       ColCount[GrpB-1] := ColCount[GrpB-1] + 1.0;
       MeanDep := MeanDep + X;
       SSDep := SSDep + (X * X);
       N := N + 1;
  end;

  // Calculate results
  for i := 0 to NoGrpsA-1 do
  begin
       SSF1 := SSF1 + ((RowSums[i] * RowSums[i]) / RowCount[i]);
       RowsTotCnt := RowsTotCnt + RowCount[i];
  end;
  for j := 0 to NoGrpsB-1 do
  begin
       SSF2 := SSF2 + ((ColSums[j] * ColSums[j]) / ColCount[j]);
       ColsTotCnt := ColsTotCnt + ColCount[j];
  end;
  for i := 0 to NoGrpsA-1 do
  begin
       for j := 0 to NoGrpsB-1 do
           if counts[i,j] > 0 then
              SSCells := SSCells + ((sums[i,j] * sums[i,j]) / counts[i,j]);
  end;
  if N > 0 then Constant := (MeanDep * MeanDep) / N else Constant := 0.0;
  SSF1 := SSF1 - Constant;
  SSF2 := SSF2 - Constant;
  SSF1F2 := SSCells - SSF1 - SSF2 - Constant;
  SSErr := SSDep - SSCells;
  SSDep := SSDep - Constant;


  if (SSF1F2 < 0) or (SSF1 < 0) or (SSF2 < 0) then
  begin
       ShowMessage('ERROR! A negative SS found. Unbalanced design? Ending analysis.');
       CompError := true;
       exit;
  end;
  DFTot := N - 1;
  DFF1 := NoGrpsA - 1;
  DFF2 := NoGrpsB - 1;
  DFF1F2 := DFF1 * DFF2;
  DFErr := DFTot - DFF1 - DFF2 - DFF1F2;
//     DFCells := N - (NoGrpsA * NoGrpsB);
  MSF1 := SSF1 / DFF1;
  MSF2 := SSF2 / DFF2;
  MSF1F2 := SSF1F2 / DFF1F2;
  MSErr := SSErr / DFErr;
  MSDep := SSDep / DFTot;
  OmegaF1 := (SSF1 - DFF1 * MSErr) / (SSDep + MSErr);
  OmegaF2 := (SSF2 - DFF2 * MSErr) / (SSDep + MSErr);
  OmegaF1F2 := (SSF1F2 - DFF1F2 * MSErr) / (SSDep + MSErr);
  Omega := OmegaF1 + OmegaF2 + OmegaF1F2;
  MeanDep := MeanDep / N;
  // f tests for fixed effects
  FF1 := abs(MSF1 / MSErr);
  FF2 := abs(MSF2 / MSErr);
  FF1F2 := abs(MSF1F2 / MSErr);
  ProbF1 := probf(FF1,DFF1,DFErr);
  ProbF2 := probf(FF2,DFF2,DFErr);
  ProbF1F2 := probf(FF1F2,DFF1F2,DFErr);
  if (ProbF1 > 1.0) then ProbF1 := 1.0;
  if (ProbF2 > 1.0) then ProbF2 := 1.0;
  if (ProbF1F2 > 1.0) then ProbF1F2 := 1.0;

  // Obtain omega squared (proportion of dependent variable explained)
  if (OmegaF1 < 0.0) then OmegaF1 := 0.0;
  if (OmegaF2 < 0.0) then OmegaF2 := 0.0;
  if (OmegaF1F2 < 0.0) then OmegaF1F2 := 0.0;
  if (Omega < 0.0) then Omega := 0.0;
end;

procedure TSRHTest.TwoWayTable(Sender: TObject);
var
   groupsize : integer;
   MinVar, MaxVar, sumvars, sumDFrecip : double;
   i, j : integer;
   XBar, V, S, RowSS, ColSS : double;
   sumfreqlogvar, c, bartlett, cochran, hartley, chiprob : double;
   H, HProb : double;
begin
  If CompError then exit;
  OutputFrm.RichEdit.Clear;
  OutputFrm.RichEdit.Lines.Add('Two Way Analysis of Variance');
  OutputFrm.RichEdit.Lines.Add('');
  outline := format('Variable analyzed: %s',[DepVar.Text]);
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.RichEdit.Lines.Add('');
  outline := format('Factor A (rows) variable: %s',[Factor1.Text]);
  OutputFrm.RichEdit.Lines.Add(outline);
  outline := format('Factor B (columns) variable: %s',[Factor2.Text]);
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.RichEdit.Lines.Add('');
  OutputFrm.RichEdit.Lines.Add('SOURCE         D.F.    SS        MS         F      PROB.> F   Omega Sqr.  H      H Prob.');
  OutputFrm.RichEdit.Lines.Add('');
  H := SSF1 / MSDep;
  HProb := 1.0 - chisquaredprob(H,round(DFF1));
  outline := format('Among Rows     %4.0f  %8.3f  %8.3f  %8.3f  %6.3f     %6.3f   %6.3f    %6.3f',
       [DFF1,SSF1,MSF1,FF1,ProbF1,OmegaF1, H, HProb]);
  OutputFrm.RichEdit.Lines.Add(outline);
  H := SSF2 / MSDep;
  HProb := 1.0 - chisquaredprob(H,round(DFF2));
  outline := format('Among Columns  %4.0f  %8.3f  %8.3f  %8.3f  %6.3f     %6.3f   %6.3f    %6.3f',
       [DFF2,SSF2,MSF2,FF2,ProbF2,OmegaF2,H , HProb]);
  OutputFrm.RichEdit.Lines.Add(outline);
  H := SSF1F2 / MSDep;
  HProb := 1.0 - chisquaredprob(H,round(DFF1F2));
  outline := format('Interaction    %4.0f  %8.3f  %8.3f  %8.3f  %6.3f     %6.3f   %6.3f    %6.3f',
       [DFF1F2,SSF1F2,MSF1F2,FF1F2,ProbF1F2,OmegaF1F2, H, HProb]);
  OutputFrm.RichEdit.Lines.Add(outline);
  outline := format('Within Groups  %4.0f  %8.3f  %8.3f',
       [DFErr,SSErr,MSErr]);
  OutputFrm.RichEdit.Lines.Add(outline);
  outline := format('Total          %4.0f  %8.3f  %8.3f',
       [DFTot,SSDep,MSDep]);
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.RichEdit.Lines.Add('');
  outline := format('Omega squared for combined effects = %8.3f',[Omega]);
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.RichEdit.Lines.Add('');

  OutputFrm.RichEdit.Lines.Add('');
  OutputFrm.RichEdit.Lines.Add('Descriptive Statistics');
  OutputFrm.RichEdit.Lines.Add('');
  OutputFrm.RichEdit.Lines.Add('GROUP Row Col.  N     MEAN   VARIANCE  STD.DEV.');
  groupsize := round(counts[0,0]);
  equal_grp := true;
  MaxVar := 0.0;
  MinVar := 1e20;
  sumvars := 0.0;
  sumfreqlogvar := 0.0;
  sumDFrecip := 0.0;

  // Display cell means, variances, standard deviations
  V := 0.0;
  XBar := 0.0;
  S := 0.0;
  for i := 0 to NoGrpsA-1 do
  begin
       for j := 0 to NoGrpsB-1 do
       begin
            if counts[i,j] > 1 then
            begin
                 XBar := sums[i,j] / counts[i,j];
                 V := vars[i,j] - ( (sums[i,j] * sums[i,j]) / counts[i,j]);
                 V := V / (counts[i,j] - 1.0);
                 S := sqrt(V);
                 sumvars  := sumvars + V;
                 if V > MaxVar then MaxVar := V;
                 if V < MinVar then MinVar := V;
                 sumDFrecip := sumDFrecip + (1.0 / (counts[i,j] - 1.0));
                 sumfreqlogvar := sumfreqlogvar + ((counts[i,j] - 1.0) * ln(V));
                 if counts[i,j] <> groupsize then equal_grp := false;
            end;
            outline := format('Cell %3d %3d  %3.0f  %8.3f  %8.3f  %8.3f',
                [minf1+i,minf2+j,counts[i,j],XBar,V,S]);
            OutputFrm.RichEdit.Lines.Add(outline);
       end;
  end;

  //Display Row means, variances, standard deviations
  for i := 0 to NoGrpsA-1 do
  begin
       XBar := RowSums[i] / RowCount[i];
       OrdMeansA[i] := XBar;
       RowSS := 0.0;
       for j := 0 to NoGrpsB-1 do RowSS := RowSS + vars[i,j];
       V := RowSS - (RowSums[i] * RowSums[i] / RowCount[i]);
       V := V / (RowCount[i] - 1.0);
       S := sqrt(V);
       outline := format('Row  %3d      %3.0f  %8.3f  %8.3f  %8.3f',
            [minf1+i,RowCount[i],XBar,V,S]);
       OutputFrm.RichEdit.Lines.Add(outline);
  end;

  //Display means, variances and standard deviations for columns
  for j := 0 to NoGrpsB-1 do
  begin
       XBar := ColSums[j] / ColCount[j];
       OrdMeansB[j] := XBar;
       ColSS := 0.0;
       for i := 0 to NoGrpsA-1 do ColSS := ColSS + vars[i,j];
       if ColCount[j] > 0 then V := ColSS - (ColSums[j] * ColSums[j] / ColCount[j]);
       if ColCount[j] > 1 then V := V / (ColCount[j] - 1.0);
       if V > 0.0 then S := sqrt(V);
       outline := format('Col  %3d      %3.0f  %8.3f  %8.3f  %8.3f',
          [minf2+j,ColCount[j],XBar,V,S]);
       OutputFrm.RichEdit.Lines.Add(outline);
  end;

  outline := format('TOTAL         %3d  %8.3f  %8.3f  %8.3f',
       [N,MeanDep,MSDep,sqrt(MSDep)]);
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.RichEdit.Lines.Add('');
  OutputFrm.RichEdit.Lines.Add('');
  c := 1.0 + (1.0 / (3.0 * NoGrpsA * NoGrpsB - 1.0)) * (sumDFrecip - (1.0 / DFErr));
  bartlett := (2.303 / c) * ((DFErr * ln(MSErr)) - sumfreqlogvar);
  chiprob := 1.0 - chisquaredprob(bartlett,round(NoGrpsA * NoGrpsB - 1));
  cochran := maxvar / sumvars;
  hartley := maxvar / minvar;
  OutputFrm.RichEdit.Lines.Add('TESTS FOR HOMOGENEITY OF VARIANCE');
  OutputFrm.RichEdit.Lines.Add('---------------------------------------------------------------------');
  outline := format('Hartley Fmax test statistic = %10.2f with deg.s freedom: %d and %d.',
       [hartley, (NoGrpsA*NoGrpsB),(groupsize-1) ]);
  OutputFrm.RichEdit.Lines.Add(outline);
  outline := format('Cochran C statistic = %10.2f with deg.s freedom: %d and %d.',
       [cochran, (NoGrpsA*NoGrpsB), (groupsize - 1)]);
  OutputFrm.RichEdit.Lines.Add(outline);
  outline := format('Bartlett Chi-square statistic = %10.2f with %4d D.F. Prob. larger value = %6.3f',
       [bartlett, (NoGrpsA*NoGrpsB - 1), chiprob]);
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.RichEdit.Lines.Add('---------------------------------------------------------------------');
end;

procedure TSRHTest.TwoWayPlot(Sender: TObject);
var
   i, j : integer;
   maxmean, XBar : double;
   XValue : DblDyneVec;
   title : string;
   plottype : integer;
   setstring : string[11];
begin
  if CompError then exit;
  SetLength(XValue,Nf1cells+Nf2cells);
  plottype := 2;
  if PlotMeans.Checked then plottype := 2;
  if Plot2DLines.Checked then plottype := 5;
  if Plot3DLines.Checked then plottype := 6;

  // do Factor A first
  setstring := 'FACTOR A';
  GraphFrm.SetLabels[1] := setstring;
  maxmean := 0.0;
  SetLength(GraphFrm.Xpoints,1,NF1cells);
  SetLength(GraphFrm.Ypoints,1,NF1cells);
  for i := 1 to NF1cells do
  begin
       RowSums[i-1] := RowSums[i-1] / RowCount[i-1];
       GraphFrm.Ypoints[0,i-1] := RowSums[i-1];
       if RowSums[i-1] > maxmean then maxmean := RowSums[i-1];
       XValue[i-1] := minF1 + i - 1;
       GraphFrm.Xpoints[0,i-1] := XValue[i-1];
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := NF1cells;
  GraphFrm.Heading := Factor1.Text;
  title :=  Factor1.Text + ' Codes';
  GraphFrm.XTitle := title;
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clYellow;
  GraphFrm.WallColor := clBlack;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;
  // do Factor B next
  setstring := 'FACTOR B';
  GraphFrm.SetLabels[1] := setstring;
  maxmean := 0.0;
  SetLength(GraphFrm.Xpoints,1,NF2cells);
  SetLength(GraphFrm.Ypoints,1,NF2cells);
  for i := 1 to NF2cells do
  begin
       ColSums[i-1] := ColSums[i-1] / ColCount[i-1];
       GraphFrm.Ypoints[0,i-1] := ColSums[i-1];
       if ColSums[i-1] > maxmean then maxmean := ColSums[i-1];
       XValue[i-1] := minF1 + i - 1;
       GraphFrm.Xpoints[0,i-1] := XValue[i-1];
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := NF2cells;
  GraphFrm.Heading := Factor2.Text;
  title :=  Factor2.Text + ' Codes';
  GraphFrm.XTitle := title;
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clYellow;
  GraphFrm.WallColor := clBlack;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;

  // do Factor A x B Interaction next
  maxmean := 0.0;
  SetLength(GraphFrm.Ypoints,NF1cells,NF2cells);
  SetLength(GraphFrm.Xpoints,1,NF2cells);
  for i := 1 to NF1cells do
  begin
       setstring := Factor1.Text + ' ' + IntToStr(i);
       GraphFrm.SetLabels[i] := setstring;
       for j := 1 to NF2cells do
       begin
            XBar := sums[i-1,j-1] / counts[i-1,j-1];
            if XBar > maxmean then maxmean := XBar;
            GraphFrm.Ypoints[i-1,j-1] := XBar;
       end;
  end;
  for j := 1 to NF2cells do
  begin
     XValue[j-1] := minF2 + j - 1;
     GraphFrm.Xpoints[0,j-1] := XValue[j-1];
  end;

  GraphFrm.nosets := NF1cells;
  GraphFrm.nbars := NF2cells;
  GraphFrm.Heading := 'Factor A x Factor B';
  title :=  Factor2.Text + ' Codes';
  GraphFrm.XTitle := title;
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clYellow;
  GraphFrm.WallColor := clBlack;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;
  XValue := nil;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;

initialization
  {$I srhtestunit.lrs}

end.

