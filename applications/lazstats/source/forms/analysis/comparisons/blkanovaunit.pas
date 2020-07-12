// Use file "anova2.laz" for testing

unit BlkANOVAUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit, DataProcs, GraphLib,
  ANOVATestsUnit, ContextHelpUnit;

type

  { TBlksAnovaFrm }

  TBlksAnovaFrm = class(TForm)
    Bevel1: TBevel;
    BrownForsythe: TCheckBox;
    Label5: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Welch: TCheckBox;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    Fact1In: TBitBtn;
    Fact1Out: TBitBtn;
    Fact2In: TBitBtn;
    Fact2Out: TBitBtn;
    Fact3In: TBitBtn;
    Fact3Out: TBitBtn;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    Scheffe: TCheckBox;
    Plot3DLines: TCheckBox;
    TukeyHSD: TCheckBox;
    TukeyB: TCheckBox;
    TukeyKramer: TCheckBox;
    NewmanKeuls: TCheckBox;
    Bonferoni: TCheckBox;
    OrthoContrasts: TCheckBox;
    PlotMeans: TCheckBox;
    Plot2DLines: TCheckBox;
    DepVar: TEdit;
    Factor1: TEdit;
    Factor2: TEdit;
    Factor3: TEdit;
    OverallAlpha: TEdit;
    PostAlpha: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    VarList: TListBox;
    Fact1Grp: TRadioGroup;
    Fact2Grp: TRadioGroup;
    Fact3Grp: TRadioGroup;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure VarChange(Sender: TObject);
    procedure Fact1OutClick(Sender: TObject);
    procedure Fact2InClick(Sender: TObject);
    procedure Fact2OutClick(Sender: TObject);
    procedure Fact3InClick(Sender: TObject);
    procedure Fact3OutClick(Sender: TObject);
    procedure Fact1InClick(Sender: TObject);
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
    outline, cellstring: string;
    SSDep, SSErr, SSF1, SSF2, SSF3, SSF1F2, SSF1F3, SSF2F3, SSF1F2F3: double;
    MSDep, MSErr, MSF1, MSF2, MSF3, MSF1F2, MSF1F3, MSF2F3, MSF1F2F3: double;
    DFTot, DFErr, DFF1, DFF2, DFF3, DFF1F2, DFF1F3, DFF2F3, DFF1F2F3: double;
    Omega, OmegaF1, OmegaF2, OmegaF3, OmegaF1F2, F: Double;
    MinSize: Double;
    OmegaF1F3, OmegaF2F3, OmegaF1F2F3: double;
    FF1, FF2, FF1F2, ProbF1, ProbF2, ProbF3, ProbF1F2, ProbF1F3: double;
    FF3, FF2F3, FF1F3, FF1F2F3, ProbF2F3, ProbF1F2F3: double;
    DepVarCol, F1Col, F2Col, F3Col, Nf1cells, Nf2cells, Nf3cells: integer;
    MeanDep, MeanF1, MeanF2, MeanF3: double;
    minf1, maxf1, minf2, maxf2, minf3, maxf3, nofactors, totcells: integer;
    cellcnts: IntDyneVec;    // array of cell counts
    cellvars: DblDyneVec;    // arrray of cell sums of squares then variances
    cellsums: DblDyneVec;    // array of cell sums then means
    equal_grp: boolean;   // check for equal groups for post-hoc tests
    counts: IntDyneMat;      // matrix for 2-way containing cell sizes
    sums: DblDyneMat;        // matrix for 2-way containing cell sums
    vars: DblDyneMat;        // matrix for 2-way containing sums of squares
    RowSums: DblDyneVec;     // 2 way row sums
    ColSums: DblDyneVec;     // 2 way col sums
    RowCount: IntDyneVec;    // 2 way row count
    ColCount: IntDyneVec;    // 2 way col count
    SlcSums: DblDyneVec;     // 3 way slice sums
    SlcCount: IntDyneVec;    // 3 way slice counts
    NoGrpsA, NoGrpsB, NoGrpsC: integer;
    OrdMeansA, OrdMeansB, OrdMeansC: DblDyneVec; // reordered means for f1, f2, f3
    AllAlpha, PostHocAlpha: double; // alphas for tests
//   wsum : array[1..20,1..20,1..20] of double; // sums for 3 way
//   ncnt : array[1..20,1..20,1..20] of integer; //  n in 3 way cells
//  wx2 : array[1..20,1..20,1..20] of double; // sums of squares for 3 way cells
    wsum, wx2: DblDyneCube;
    ncnt: IntDyneCube;
    OKterms: array[1..14] of integer;
    CompError: boolean;

    procedure GetLevels;
    procedure Calc1Way;
    procedure OneWayTable(AReport: TStrings);
    procedure OneWayPlot;
    procedure Calc2Way;
    procedure TwoWayTable(AReport: TStrings);
    procedure TwoWayPlot;
    procedure TwoWayContrasts(AReport: TStrings);
    procedure Calc3Way;
    procedure ThreeWayTable(AReport: TStrings);
    procedure ThreeWayPlot;
    procedure ThreeWayContrasts(AReport: TStrings);
    procedure BrownForsytheOneWay(AReport: TStrings);
    procedure WelchOneWay(AReport: TStrings);
    procedure WelchtTests(AReport: TStrings);

    procedure UpdateBtnStates;
    function Validate(out AMsg: String; out AControl: TWinControl;
      DepVarIndex, Fact1Index, Fact2Index, Fact3Index: Integer): Boolean;

  public
    { public declarations }
  end; 

var
  BlksAnovaFrm: TBlksAnovaFrm;

implementation

uses
  Math, Utils;

{ TBlksAnovaFrm }

procedure TBlksAnovaFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  DepVar.Text := '';
  Factor1.Text := '';
  Factor2.Text := '';
  Factor3.Text := '';
  Fact1Grp.ItemIndex := 0;
  Fact2Grp.ItemIndex := 0;
  Fact3Grp.ItemIndex := 0;
  PlotMeans.Checked := false;
  Scheffe.Checked := false;
  TukeyHSD.Checked := false;
  TukeyB.Checked := false;
  TukeyKramer.Checked := false;
  NewmanKeuls.Checked := false;
  Bonferoni.Checked := false;
  PostAlpha.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  OverAllalpha.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TBlksAnovaFrm.FormActivate(Sender: TObject);
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

  VarList.Constraints.MinWidth := OverallAlpha.Left + OverallAlpha.Width - VarList.Left;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TBlksAnovaFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);

  OverallAlpha.Text := FloatToStr(DEFAULT_ALPHA_LEVEL);
  PostAlpha.Text := FloatToStr(DEFAULT_ALPHA_LEVEL);
end;

procedure TBlksAnovaFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TBlksAnovaFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TBlksAnovaFrm.DepInClick(Sender: TObject);
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

procedure TBlksAnovaFrm.ComputeBtnClick(Sender: TObject);
var
  i: integer;
  msg: String;
  C: TWinControl;
  lReport: TStrings;
begin
  // initialize values
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
  N := 0;
  NoSelected := 0;
  minf1 := 0;
  maxf1 := 0;
  minf2 := 0;
  maxf2 := 0;
  minf3 := 0;
  maxf3 := 0;

  lReport := TStringList.Create;
  try
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
      if cellstring = Factor3.Text then
      begin
        F3Col := i;
        NoSelected := NoSelected + 1;
        ColNoSelected[NoSelected-1] := F3Col;
      end;
    end;

    if not Validate(msg, C, DepVarCol, F1Col, F2Col, F3Col) then begin
      C.SetFocus;
      ErrorMsg(msg);
      exit;
    end;

    if F2Col = 0 then nofactors := 1 else nofactors := 2;
    if F3Col <> 0 then nofactors := 3;

    allAlpha := StrToFloat(OverAllalpha.Text);
    PostHocAlpha := StrToFloat(PostAlpha.Text);

    // get min and max of each factor code
    GetLevels;

    // allocate space
    SetLength(cellcnts, totcells);  // array of cell counts
    SetLength(cellvars, totcells);  // arrray of cell sums of squares then variances
    SetLength(cellsums, totcells);  // array of cell sums then means

    // initialize array values
    for i := 0 to totcells-1 do
    begin
      cellsums[i] := 0.0;
      cellvars[i] := 0.0;
      cellcnts[i] := 0;
    end;

    // do analysis
    case nofactors of
      1 :   // single factor anova
        begin
          Calc1Way;
          if CompError then
            exit;
          OneWayTable(lReport);   // output the results
          if Scheffe.Checked then
            ScheffeTest(MSErr, cellsums, cellcnts, minf1, maxf1,N, posthocAlpha, lReport);
          if TukeyHSD.Checked and equal_grp then
            Tukey(MSErr, DFErr, MinSize, cellsums, cellcnts, minf1, maxf1, posthocAlpha, lReport);
          if TukeyB.Checked and equal_grp then
            TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, MinSize, posthocAlpha, lReport);
          if TukeyKramer.Checked then
            Tukey_Kramer(MSErr, DFErr, MinSize, cellsums, cellcnts, minf1, maxf1, posthocAlpha, lReport);
          if NewmanKeuls.Checked and equal_grp then
            Newman_Keuls(MSErr, DFErr, MinSize, cellsums, cellcnts, minf1, maxf1, posthocAlpha, lReport);
          if Bonferoni.Checked then
            Bonferroni(cellsums, cellcnts, cellvars, minf1, maxf1, posthocAlpha, lReport);
          if OrthoContrasts.Checked then
            Contrasts(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, allAlpha, posthocAlpha, lReport);
          if BrownForsythe.Checked then
            BrownForsytheOneWay(lReport);
          if Welch.Checked then
            WelchOneWay(lReport);

          if not DisplayReport(lReport) then
            exit;

          if PlotMeans.Checked or Plot2DLines.Checked or Plot3DLines.Checked then
            OneWayPlot;
       end;

     2 : // two-way anova
       begin
         SetLength(counts,Nf1cells,Nf2cells); // matrix for 2-way containing cell sizes
         SetLength(sums,Nf1cells,Nf2cells);  // matrix for 2-way containing cell sums
         SetLength(vars,Nf1cells,Nf2cells);  // matrix for 2-way containing sums of squares
         SetLength(RowSums,Nf1cells);  // 2 way row sums
         SetLength(ColSums,Nf2cells);  // 2 way col sums
         SetLength(RowCount,Nf1cells); // 2 way row count
         SetLength(ColCount,Nf2cells); // 2 way col count
         SetLength(OrdMeansA,Nf1cells); // ordered means for factor 1
         SetLength(OrdMeansB,Nf2cells); // ordered means for factor 2

         Calc2Way;
         if not CompError then
         begin
           TwoWayTable(lReport);
           TwoWayContrasts(lReport);

           if not DisplayReport(lReport) then
             exit;

           if PlotMeans.Checked or Plot2DLines.Checked or Plot3DLines.Checked then
             TwoWayPlot;
         end;

         OrdMeansB := nil;
         OrdMeansA := nil;
         ColCount := nil;
         RowCount := nil;
         ColSums := nil;
         RowSums := nil;
         vars := nil;
         sums := nil;
         counts := nil;
       end;

     3 : // three way anova
       begin
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
           ThreeWayTable(lReport);
           ThreeWayContrasts(lReport);

           if not DisplayReport(lReport) then
             exit;

           if (PlotMeans.Checked) or (Plot2DLines.Checked) or (Plot3DLines.Checked) then
             ThreeWayPlot;
         end;

         ncnt := nil;
         wx2 := nil;
         wsum := nil;
         OrdMeansC := nil;
         OrdMeansB := nil;
         OrdMeansA := nil;
         SlcCount := nil;
         SlcSums := nil;
         ColCount := nil;
         ColSums := nil;
         RowCount := nil;
         RowSums := nil;
       end;
     end;

  finally
     lReport.Free;
     cellcnts := nil;
     cellvars := nil;
     cellsums := nil;
     ColNoSelected := nil;
  end;
end;

procedure TBlksAnovaFrm.DepOutClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TBlksAnovaFrm.VarChange(Sender: TObject);
begin
  UpdateBtnStates;
end;

procedure TBlksAnovaFrm.Fact1OutClick(Sender: TObject);
begin
  if Factor1.Text <> '' then
  begin
    VarList.Items.Add(Factor1.Text);
    Factor1.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TBlksAnovaFrm.Fact2InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Factor2.Text = '') then
  begin
    Factor2.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TBlksAnovaFrm.Fact2OutClick(Sender: TObject);
begin
  if Factor2.Text <> '' then
  begin
    VarList.Items.Add(Factor2.Text);
    Factor2.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TBlksAnovaFrm.Fact3InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Factor3.Text = '') then
  begin
    Factor3.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TBlksAnovaFrm.Fact3OutClick(Sender: TObject);
begin
  if Factor3.Text <> '' then
  begin
    VarList.Items.Add(Factor3.Text);
    Factor3.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TBlksAnovaFrm.Fact1InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Factor1.Text = '') then
  begin
    Factor1.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TBlksAnovaFrm.GetLevels;
var
  i, intValue: integer;
begin
  Nf1cells := 0;
  Nf2Cells := 0;
  Nf3Cells := 0;

  minf1 := MaxInt;
  maxf1 := -MaxInt;
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col, i])));
    if intvalue > maxf1 then maxf1 := intvalue;
    if intvalue < minf1 then minf1 := intvalue;
  end;
  Nf1cells := maxf1 - minf1 + 1;

  if nofactors > 1 then
  begin
    minf2 := MaxInt;
    maxf2 := -MaxInt;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F2Col, i])));
      if intvalue > maxf2 then maxf2 := intvalue;
      if intvalue < minf2 then minf2 := intvalue;
    end;
    Nf2cells := maxf2 - minf2 + 1;
  end;

  if nofactors = 3 then
  begin
    minf3 := MaxInt;
    maxf3 := -MaxInt;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F3Col, i])));
      if intvalue > maxf3 then maxf3 := intvalue;
      if intvalue < minf3 then minf3 := intvalue;
    end;
    Nf3cells := maxf3 - minf3 + 1;

    Caption := IntToStr(Nf3Cells);
  end;

  totcells := Nf1cells + Nf2cells + Nf3cells;
end;

procedure TBlksAnovaFrm.Calc1Way;
var
  i, intValue: integer;
  X, X2: Double;
begin
  CompError := false;

  // get working totals
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepVarCol,i]));
    X2 := X*X;
    intvalue := intvalue - minf1;
    cellcnts[intvalue] := cellcnts[intvalue] + 1;
    cellsums[intvalue] := cellsums[intvalue] + X;
    cellvars[intvalue] := cellvars[intvalue] + X2;
    MeanDep := MeanDep + X;
    SSDep := SSDep + X2;
    N := N + 1;
  end;

  DFF1 := 0;
  for i := 0 to Nf1cells-1 do
  begin
    if cellcnts[i] > 0 then
    begin
      SSF1 := SSF1 + (sqr(cellsums[i]) / cellcnts[i]);
      DFF1 := DFF1 + 1;
    end;
  end;

  SSF1 := SSF1 - (sqr(MeanDep) / N);
  SSDep := SSDep - (sqr(MeanDep) / N);
  SSErr := SSDep - SSF1;
  DFTot := N - 1;
  DFF1 := DFF1 - 1;
  DFErr := DFTot - DFF1;
  MSF1 := SSF1 / DFF1;
  MSErr := SSErr / DFErr;
  MSDep := SSDep / DFTot;
  Omega := (SSF1 - DFF1 * MSErr) / (SSDep + MSErr);
  F := MSF1 / MSErr;
  ProbF1 := probf(F,DFF1, DFErr);
  MeanDep := MeanDep / N;
end;

procedure TBlksAnovaFrm.OneWayTable(AReport: TStrings);
var
  i, grpsize: integer;
  minvar, maxvar, sumvar, sumfreqlogvar, sumDFrecip: double;
  c, bartlett, cochran, hartley, chiprob: double;
  maxSize: Integer;
begin
  AReport.Add(DIVIDER);
  AReport.Add('ONE WAY ANALYSIS OF VARIANCE RESULTS');
  AReport.Add(DIVIDER);
  AReport.Add('Dependent variable is:   %s', [DepVar.Text]);
  AReport.Add('Independent variable is: %s', [Factor1.Text]);
  AReport.Add('');
  AReport.Add(DIVIDER_SMALL);
  AReport.Add('SOURCE    D.F.      SS        MS        F         PROB.>F   OMEGA SQR.');
  AReport.Add(DIVIDER_SMALL);
  AReport.Add('BETWEEN   %4.0f%10.2f%10.2f%10.2f%10.2f%10.2f', [DFF1, SSF1, MSF1, F, ProbF1, Omega]);
  AReport.Add('WITHIN    %4.0f%10.2f%10.2f', [DFErr, SSErr, MSErr]);
  AReport.Add('TOTAL     %4.0f%10.2f', [DFTot, SSDep]);
  AReport.Add(DIVIDER_SMALL);
  AReport.Add('');
  AReport.Add('MEANS AND VARIABILITY OF THE DEPENDENT VARIABLE');
  AReport.Add('FOR LEVELS OF THE INDEPENDENT VARIABLE');
  AReport.Add('');
  AReport.Add('GROUP    MEAN      VARIANCE    STD.DEV.      N');
  AReport.Add('-----  ---------  ----------  ----------  ---------');
  //           xxxx xxxxxxxxx  xxxxxxxxxx  xxxxxxxxxx      xxxx

  equal_grp := true;
  minvar := 1e20;
  maxvar := 0.0;
  sumvar := 0.0;
  sumDFrecip := 0.0;
  sumfreqlogvar := 0.0;
  grpsize := round(cellcnts[0]);
  MinSize := grpsize; // initialized minimum group size
  maxSize := grpsize; // initialize maximum group size
  for i := 0 to NF1cells-1 do
  begin
    grpsize := round(cellcnts[i]);
    if grpsize < MinSize then
    begin
      MinSize := grpsize;
      equal_grp := false;
    end;
    if grpsize > maxSize then
      maxSize := grpsize;

    if cellcnts[i] > 1 then
    begin
      cellvars[i] := cellvars[i] - (sqr(cellsums[i]) / cellcnts[i]);
      cellvars[i] := cellvars[i] / (cellcnts[i] - 1);
      if cellvars[i] > maxvar then maxvar := cellvars[i];
      if cellvars[i] < minvar then minvar := cellvars[i];
      sumvar :=sumvar + cellvars[i];
      sumDFrecip := sumDFrecip + (1.0 / (cellcnts[i] - 1.0));
      sumfreqlogvar := sumfreqlogvar + (cellcnts[i] - 1) * Log10(cellvars[i]);
    end;

    if cellcnts[i] > 0 then
      AReport.Add('%4d %9.2f  %10.2f  %10.2f    %4d', [
        i+1, cellsums[i] / cellcnts[i], cellvars[i], sqrt(cellvars[i]), cellcnts[i]
      ]);
  end;

  AReport.Add('---------------------------------------------------');
  AReport.Add('TOTAL%9.2f  %10.2f  %10.2f    %4d', [MeanDep, MSDep, sqrt(MSDep), N]);
  AReport.Add('---------------------------------------------------');
  AReport.Add('');

  c := 1.0 + (1.0 / (3 * DFF1)) * (sumDFrecip - (1.0 / DFErr));
  bartlett := (2.303 / c) * ((DFErr * Log10(MSErr)) - sumfreqlogvar);
  chiprob := 1.0 - chisquaredprob(bartlett,round(DFF1));
  cochran := maxvar / sumvar;
  hartley := maxvar / minvar;

  AReport.Add(DIVIDER);
  AReport.Add('TESTS FOR HOMOGENEITY OF VARIANCE');
  AReport.Add('');
  AReport.Add('Hartley Fmax test statistic:                   %8.2f  (%d and %d d.f.)', [hartley, NF1cells, maxSize-1]);
  AReport.Add('Cochran C statistic:                           %8.2f  (%d and %d d.f.)', [cochran, Nf1cells, maxSize-1]);
  AReport.Add('Bartlett Chi-square:                           %8.2f  (%.0f d.f)', [bartlett, DFF1]);
  AReport.Add('   probability > Chi-Square:                   %8.3f', [chiprob]);
  AReport.Add(DIVIDER);
end;

procedure TBlksAnovaFrm.OneWayPlot;
var
  i : integer;
  maxmean : double;
  plottype : integer;
begin
  plotType := 2;
  if PlotMeans.Checked then plottype := 2;
  if Plot2DLines.Checked then plottype := 5;
  if Plot3DLines.Checked then plottype := 6;

  GraphFrm.SetLabels[1] := 'FACTOR A';
  SetLength(GraphFrm.YPoints,1,NF1cells);
  SetLength(GraphFrm.Xpoints,1,NF1cells);

  maxmean := 0.0;
  for i := 0 to NF1cells-1 do
  begin
    cellsums[i] := cellsums[i] / cellcnts[i];
    GraphFrm.Ypoints[0, i] := cellsums[i];
    if cellsums[i] > maxmean then maxmean := cellsums[i];
    GraphFrm.Xpoints[0,i] := minF1 + i;
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := NF1cells;
  GraphFrm.Heading := Factor1.Text;
  GraphFrm.XTitle := 'FACTOR A LEVEL';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype; // 3d Vertical Bar Chart
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;

  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;

procedure TBlksAnovaFrm.Calc2Way;
var
  i, j : integer;
  grpA, grpB : integer;
  Constant, RowsTotCnt, ColsTotCnt, SSCells : double;
  X, X2: Double;
begin
  CompError := false;

  // initialize matrix values
  NoGrpsA := maxf1 - minf1 + 1;
  NoGrpsB := maxf2 - minf2 + 1;
  for i := 0 to NoGrpsA-1  do
  begin
    RowSums[i] := 0.0;
    RowCount[i] := 0;
    for j := 0 to NoGrpsB-1 do
    begin
      counts[i, j] := 0;
      sums[i, j] := 0.0;
      vars[i, j] := 0.0;
    end;
  end;

  for i := 0 to NoGrpsB-1 do
  begin
    ColCount[i] := 0;
    ColSums[i] := 0.0;
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
    X2 := X*X;
    grpA := grpA - minf1 + 1;
    grpB := grpB - minf2 + 1;
    counts[grpA-1,grpB-1] := counts[grpA-1,grpB-1] + 1;
    sums[grpA-1,grpB-1] := sums[grpA-1,grpB-1] + X;
    vars[grpA-1,grpB-1] := vars[grpA-1,grpB-1] + X2;
    RowSums[GrpA-1] := RowSums[GrpA-1] + X;
    ColSums[GrpB-1] := ColSums[GrpB-1] + X;
    RowCount[GrpA-1] := RowCount[GrpA-1] + 1;
    ColCount[GrpB-1] := ColCount[GrpB-1] + 1;
    MeanDep := MeanDep + X;
    SSDep := SSDep + X2;
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
    ErrorMsg('A negative SS found. Unbalanced design? Ending analysis.');
    CompError := true;
    exit;
  end;

  DFTot := N - 1;
  DFF1 := NoGrpsA - 1;
  DFF2 := NoGrpsB - 1;
  DFF1F2 := DFF1 * DFF2;
  DFErr := DFTot - DFF1 - DFF2 - DFF1F2;
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

  // F tests for fixed effects
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 0) then
  begin
    FF1 := abs(MSF1 / MSErr);
    FF2 := abs(MSF2 / MSErr);
    FF1F2 := abs(MSF1F2 / MSErr);
    ProbF1 := probf(FF1,DFF1,DFErr);
    ProbF2 := probf(FF2,DFF2,DFErr);
    ProbF1F2 := probf(FF1F2,DFF1F2,DFErr);
  end;

  // F tests if both factors are random
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 1) then
  begin
    FF1 := abs(MSF1 / MSF1F2);
    FF2 := abs(MSF2 / MSF1F2);
    FF1F2 := abs(MSF1F2 / MSErr);
    ProbF1 := probf(FF1,DFF1,DFF1F2);
    ProbF2 := probf(FF2,DFF2,DFF1F2);
    ProbF3 := probf(FF1F2,DFF1F2,DFErr);
  end;

  // F test if factor A is random
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 0) then
  begin
    FF1 := abs(MSF1 / MSErr);
    FF2 := abs(MSF2 / MSF1F2);
    FF1F2 := abs(MSF1F2 / MSErr);
    ProbF1 := probf(FF1,DFF1,DFErr);
    ProbF2 := probf(FF2,DFF2,DFF1F2);
    ProbF3 := probf(FF1F2,DFF1F2,DFErr);
  end;

  // F test if factor b is random
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 1) then
  begin
    FF1 := abs(MSF1 / MSF1F2);
    FF2 := abs(MSF2 / MSErr);
    FF1F2 := abs(MSF1F2 / MSErr);
    ProbF1 := probf(FF1,DFF1,DFF1F2);
    ProbF2 := probf(FF2,DFF2,DFErr);
    ProbF3 := probf(FF1F2,DFF1F2,DFErr);
  end;

  if (ProbF1 > 1.0) then ProbF1 := 1.0;
  if (ProbF2 > 1.0) then ProbF2 := 1.0;
  if (ProbF1F2 > 1.0) then ProbF1F2 := 1.0;


  // Obtain omega squared (proportion of dependent variable explained)
  if (OmegaF1 < 0.0) then OmegaF1 := 0.0;
  if (OmegaF2 < 0.0) then OmegaF2 := 0.0;
  if (OmegaF1F2 < 0.0) then OmegaF1F2 := 0.0;
  if (Omega < 0.0) then Omega := 0.0;
end;

procedure TBlksAnovaFrm.TwoWayTable(AReport: TStrings);
var
  groupsize: integer;
  MinVar, MaxVar, sumvars, sumDFrecip: double;
  i, j: integer;
  XBar, V, S, RowSS, ColSS: double;
  sumfreqlogvar, c, bartlett, cochran, hartley, chiprob: double;
begin
  if CompError then
    exit;

  AReport.Add('Two Way Analysis of Variance');
  AReport.Add('');
  AReport.Add('Variable analyzed: %s', [DepVar.Text]);
  AReport.Add('');

  outline := format('Factor A (rows) variable: %s',[Factor1.Text]);
  if Fact1Grp.ItemIndex = 0 then
    outline := outline + ' (Fixed Levels)'
  else
     outline := outline + ' (Random Levels)';
  AReport.Add(outline);

  outline := format('Factor B (columns) variable: %s',[Factor2.Text]);
  if Fact2Grp.ItemIndex = 0 then
    outline := outline + ' (Fixed Levels)'
  else
    outline := outline + ' (Random Levels)';
  AReport.Add(outline);
  AReport.Add('');

  AReport.Add('SOURCE         D.F.    SS        MS         F      PROB.> F   Omega Squared');
  AReport.Add('');
  AReport.Add('Among Rows     %4.0f  %8.3f  %8.3f  %8.3f  %6.3f     %6.3f', [DFF1, SSF1, MSF1, FF1, ProbF1, OmegaF1]);
  AReport.Add('Among Columns  %4.0f  %8.3f  %8.3f  %8.3f  %6.3f     %6.3f', [DFF2, SSF2, MSF2, FF2, ProbF2, OmegaF2]);
  AReport.Add('Interaction    %4.0f  %8.3f  %8.3f  %8.3f  %6.3f     %6.3f', [DFF1F2, SSF1F2, MSF1F2, FF1F2, ProbF1F2, OmegaF1F2]);
  AReport.Add('Within Groups  %4.0f  %8.3f  %8.3f', [DFErr, SSErr, MSErr]);
  AReport.Add('Total          %4.0f  %8.3f  %8.3f', [DFTot, SSDep, MSDep]);
  AReport.Add('');
  AReport.Add('Omega squared for combined effects = %8.3f', [Omega]);
  AReport.Add('');
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 0) then
    AReport.Add('Note: Denominator of F ratio is MSErr');
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 1) then
    AReport.Add('Note: Denominator of F ratio is MSAxB');
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 1) then
  begin
    AReport.Add('Note: Denominator of F ratio for A is MSAxB');
    AReport.Add('and denominator for B and AxB is MSErr');
  end;
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 0) then
  begin
     AReport.Add('Note: Denominator of F ratio for B is MSAxB');
     AReport.Add('and denominator for A and AxB is MSErr');
  end;
  AReport.Add('');
  AReport.Add('Descriptive Statistics');
  AReport.Add('');
  AReport.Add('GROUP  Row Col.  N     MEAN   VARIANCE  STD.DEV.');
  groupsize := counts[0, 0];
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
      AReport.Add('Cell  %3d %3d  %3d  %8.3f  %8.3f  %8.3f', [minf1+i, minf2+j, counts[i,j], XBar, V, S]);
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
    AReport.Add('Row  %3d      %3d  %8.3f  %8.3f  %8.3f', [minf1+i, RowCount[i], XBar, V, S]);
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
    AReport.Add('Col  %3d      %3d  %8.3f  %8.3f  %8.3f', [minf2+j, ColCount[j], XBar, V, S]);
  end;

  AReport.Add('TOTAL         %3d  %8.3f  %8.3f  %8.3f', [N, MeanDep, MSDep, sqrt(MSDep)]);
  AReport.Add('');
  AReport.Add('');

  c := 1.0 + (1.0 / (3.0 * NoGrpsA * NoGrpsB - 1.0)) * (sumDFrecip - (1.0 / DFErr));
  bartlett := (2.303 / c) * ((DFErr * ln(MSErr)) - sumfreqlogvar);
  chiprob := 1.0 - chisquaredprob(bartlett,round(NoGrpsA * NoGrpsB - 1));
  cochran := maxvar / sumvars;
  hartley := maxvar / minvar;

  AReport.Add(DIVIDER);
  AReport.Add('TESTS FOR HOMOGENEITY OF VARIANCE');
  AReport.Add(DIVIDER_SMALL);
  AReport.Add('Hartley Fmax test statistic: %.2f with deg.s freedom: %d and %d.', [hartley, NoGrpsA*NoGrpsB, groupsize-1]);
  AReport.Add('Cochran C statistic: %.2f with deg.s freedom: %d and %d.', [cochran, NoGrpsA*NoGrpsB, groupsize - 1]);
  AReport.Add('Bartlett Chi-square statistic: %.2f with %d D.F.; prob. larger value %.3f', [bartlett, NoGrpsA*NoGrpsB - 1, chiprob]);
  AReport.Add(DIVIDER);
end;

procedure TBlksAnovaFrm.TwoWayPlot;
var
  i, j : integer;
  maxmean, XBar : double;
  plottype : integer;
begin
  if CompError then
    exit;

  plottype := 2;
  if PlotMeans.Checked then plottype := 2;
  if Plot2DLines.Checked then plottype := 5;
  if Plot3DLines.Checked then plottype := 6;

  // do Factor A first
  GraphFrm.SetLabels[1] := 'FACTOR A';
  SetLength(GraphFrm.Xpoints, 1, NF1cells);
  SetLength(GraphFrm.Ypoints, 1, NF1cells);

  maxmean := 0.0;
  for i := 1 to NF1cells do
  begin
    RowSums[i-1] := RowSums[i-1] / RowCount[i-1];
    GraphFrm.Ypoints[0,i-1] := RowSums[i-1];
    if RowSums[i-1] > maxmean then maxmean := RowSums[i-1];
    GraphFrm.Xpoints[0,i-1] := minF1 + i - 1;
  end;

  GraphFrm.nosets := 1;
  GraphFrm.nbars := NF1cells;
  GraphFrm.Heading := Factor1.Text;
  GraphFrm.XTitle := Factor1.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;
  if GraphFrm.ShowModal <> mroK then
    exit;

  // do Factor B next
  GraphFrm.SetLabels[1] := 'FACTOR B';
  SetLength(GraphFrm.Xpoints, 1, NF2cells);
  SetLength(GraphFrm.Ypoints, 1, NF2cells);

  maxmean := 0.0;
  for i := 1 to NF2cells do
  begin
    ColSums[i-1] := ColSums[i-1] / ColCount[i-1];
    GraphFrm.Ypoints[0,i-1] := ColSums[i-1];
    if ColSums[i-1] > maxmean then maxmean := ColSums[i-1];
    GraphFrm.Xpoints[0,i-1] := minF1 + i - 1;
  end;

  GraphFrm.nosets := 1;
  GraphFrm.nbars := NF2cells;
  GraphFrm.Heading := Factor2.Text;
  GraphFrm.XTitle := Factor2.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;
  if GraphFrm.ShowModal <> mrOK then
    exit;

  // do Factor A x B Interaction next
  SetLength(GraphFrm.Ypoints, NF1cells, NF2cells);
  SetLength(GraphFrm.Xpoints, 1, NF2cells);
  maxmean := 0.0;
  for i := 1 to NF1cells do
  begin
    GraphFrm.SetLabels[i] := Factor1.Text + ' ' + IntToStr(i);
    for j := 1 to NF2cells do
    begin
      XBar := sums[i-1,j-1] / counts[i-1,j-1];
      if XBar > maxmean then maxmean := XBar;
      GraphFrm.Ypoints[i-1,j-1] := XBar;
    end;
  end;

  for j := 1 to NF2cells do
    GraphFrm.Xpoints[0,j-1] := minF2 + j - 1;

  GraphFrm.nosets := NF1cells;
  GraphFrm.nbars := NF2cells;
  GraphFrm.Heading := 'Factor A x Factor B';
  GraphFrm.XTitle := Factor2.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;

  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;

procedure TBlksAnovaFrm.Calc3Way;
var
  i, j, k : integer;
  grpA, grpB, grpC : integer;
  Constant, RowsTotCnt, ColsTotCnt, SlcsTotCnt, SSCells : double;
  p, n2 : double;
  X, X2: Double;
begin
  CompError := false;

  // initialize matrix values
  NoGrpsA := maxf1 - minf1 + 1;
  NoGrpsB := maxf2 - minf2 + 1;
  NoGrpsC := maxf3 - minf3 + 1;

  for i := 0 to NoGrpsA-1  do
  begin
    RowSums[i] := 0.0;
    RowCount[i] := 0;
    for j := 0 to NoGrpsB-1 do
    begin
      for k := 0 to NoGrpsC-1 do
      begin
        wsum[i,j,k] := 0.0;
        ncnt[i,j,k] := 0;
        wx2[i,j,k] := 0.0;
      end;
    end;
  end;

  for i := 0 to NoGrpsB-1 do
  begin
    ColCount[i] := 0;
    ColSums[i] := 0.0;
  end;

  for i := 0 to NoGrpsC-1 do
  begin
    SlcCount[i] := 0;
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

  // get working totals
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    grpA := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
    grpB := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i])));
    grpC := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F3Col,i])));
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepVarCol,i]));
    X2 := X*X;
    grpA := grpA - minf1 + 1;
    grpB := grpB - minf2 + 1;
    grpC := grpC - minf3 + 1;
    ncnt[grpA-1,grpB-1,grpC-1] := ncnt[grpA-1,grpB-1,grpC-1] + 1;
    wsum[grpA-1,grpB-1,grpC-1] := wsum[grpA-1,grpB-1,grpc-1] + X;
    wx2[grpA-1,grpB-1,grpC-1] := wx2[grpA-1,grpB-1,grpC-1] + X2;
    RowSums[GrpA-1] := RowSums[GrpA-1] + X;
    ColSums[GrpB-1] := ColSums[GrpB-1] + X;
    SlcSums[GrpC-1] := SlcSums[GrpC-1] + X;
    RowCount[GrpA-1] := RowCount[GrpA-1] + 1;
    ColCount[GrpB-1] := ColCount[GrpB-1] + 1;
    SlcCount[GrpC-1] := SlcCount[GrpC-1] + 1;
    MeanDep := MeanDep + X;
    SSDep := SSDep + X2;
    N := N + 1;
  end;

  // Calculate results

  Constant := (MeanDep * MeanDep) / N;

  // get ss for rows
  for i := 0 to NoGrpsA-1 do
  begin
    SSF1 := SSF1 + ((RowSums[i] * RowSums[i]) / RowCount[i]);
    RowsTotCnt := RowsTotCnt + RowCount[i];
  end;
  SSF1 := SSF1 - Constant;

  // get ss for columns
  for j := 0 to NoGrpsB-1 do
  begin
    SSF2 := SSF2 + ((ColSums[j] * ColSums[j]) / ColCount[j]);
    ColsTotCnt := ColsTotCnt + ColCount[j];
  end;
  SSF2 := SSF2 - Constant;

  // get ss for slices
  for k := 0 to NoGrpsC-1 do
  begin
    SSF3 := SSF3 + ((SlcSums[k] * SlcSums[k]) / SlcCount[k]);
    SlcsTotCnt := SlcsTotCnt + SlcCount[k];
  end;
  SSF3 := SSF3 - Constant;

  // get ss for row x col interaction
  p := 0.0;
  n2 := 0.0;
  for i := 0 to NoGrpsA-1 do
  begin
    for j := 0 to NoGrpsB-1 do
    begin
      for k := 0 to NoGrpsC-1 do
      begin
        p := p + wsum[i,j,k];
        n2 := n2 + ncnt[i,j,k];
      end;
      SSF1F2 := SSF1F2 + ((p * p) / n2);
      p := 0.0;
      n2 := 0.0;
    end;
  end;
  SSF1F2 := SSF1F2 - SSF1 - SSF2 - Constant;

  // get ss for row x slice interaction
  for i := 0 to NoGrpsA-1 do
  begin
    for k := 0 to NoGrpsC-1 do
    begin
      for j := 0 to NoGrpsB-1 do
      begin
        p := p + wsum[i,j,k];
        n2 := n2 + ncnt[i,j,k];
      end;
      SSF1F3 := SSF1F3 + ((p * p) / n2);
      p := 0.0;
      n2 := 0.0;
    end;
  end;
  SSF1F3 := SSF1F3 - SSF1 - SSF3 - Constant;

  // get ss for columns x slices interaction
  for j := 0 to NoGrpsB-1 do
  begin
    for k := 0 to NoGrpsC-1 do
    begin
      for i := 0 to NoGrpsA-1 do
      begin
        p := p + wsum[i,j,k];
        n2 := n2 + ncnt[i,j,k];
      end;
      SSF2F3 := SSF2F3 + ((p * p) / n2);
      p := 0.0;
      n2 := 0.0;
    end;
  end;
  SSF2F3 := SSF2F3 - SSF2 - SSF3 - Constant;

  // get ss for cells
  for i := 0 to NoGrpsA-1 do
    for j := 0 to NoGrpsB-1 do
      for k := 0 to NoGrpsC-1 do
        SSCells := SSCells + ((wsum[i,j,k] * wsum[i,j,k]) / ncnt[i,j,k]);

  SSF1F2F3 := SSCells - SSF1 - SSF2 - SSF3 - SSF1F2 - SSF1F3 - SSF2F3 - Constant;
  SSErr := SSDep - SSCells;
  SSDep := SSDep - Constant;

  if (SSF1 < 0.0) or (SSF2 < 0.0) or (SSF3 < 0.0) or (SSF1F2 < 0.0) or
     (SSF1F3 < 0.0) or (SSF2F3 < 0.0) or (SSF1F2F3 < 0.0) then
  begin
    ErrorMsg('ERROR! A negative SS found. Unbalanced Design? Ending analysis.');
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
  DFF1F2F3 := DFF1 * DFF2 * DFF3;
  DFErr := DFTot - DFF1 - DFF2 - DFF3 - DFF1F2 - DFF1F3 - DFF2F3 - DFF1F2F3;
  MSF1 := SSF1 / DFF1;
  MSF2 := SSF2 / DFF2;
  MSF3 := SSF3 / DFF3;
  MSF1F2 := SSF1F2 / DFF1F2;
  MSF1F3 := SSF1F3 / DFF1F3;
  MSF2F3 := SSF2F3 / DFF2F3;
  MSF1F2F3 := SSF1F2F3 / DFF1F2F3;
  MSErr := SSErr / DFErr;
  MSDep := SSDep / DFTot;
  OmegaF1 := (SSF1 - DFF1 * MSErr) / (SSDep + MSErr);
  OmegaF2 := (SSF2 - DFF2 * MSErr) / (SSDep + MSErr);
  OmegaF3 := (SSF3 - DFF3 * MSErr) / (SSDep + MSErr);
  OmegaF1F2 := (SSF1F2 - DFF1F2 * MSErr) / (SSDep + MSErr);
  OmegaF1F3 := (SSF1F3 - DFF1F3 * MSErr) / (SSDep + MSErr);
  OmegaF2F3 := (SSF2F3 - DFF2F3 * MSErr) / (SSDep + MSErr);
  OmegaF1F2F3 := (SSF1F2F3 - DFF1F2F3 * MSErr) / (SSDep + MSErr);
  Omega := OmegaF1 + OmegaF2 + OmegaF3 + OmegaF1F2 + OmegaF1F3 + OmegaF2F3 + OmegaF1F2F3;
  MeanDep := MeanDep / N;

  // F tests for fixed effects
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 0) and (Fact3Grp.ItemIndex = 0) then
  begin
    FF1 := abs(MSF1 / MSErr);
    FF2 := abs(MSF2 / MSErr);
    FF3 := abs(MSF3 / MSErr);
    FF1F2 := abs(MSF1F2 / MSErr);
    FF1F3 := abs(MSF1F3 / MSErr);
    FF2F3 := abs(MSF2F3 / MSErr);
    FF1F2F3 := abs(MSF1F2F3 / MSErr);
    ProbF1 := probf(FF1,DFF1,DFErr);
    ProbF2 := probf(FF2,DFF2,DFErr);
    ProbF3 := probf(FF3,DFF3,DFErr);
    ProbF1F2 := probf(FF1F2,DFF1F2,DFErr);
    ProbF1F3 := probf(FF1F3,DFF1F3,DFErr);
    ProbF2F3 := probf(FF2F3,DFF2F3,DFErr);
    ProbF1F2F3 := probf(FF1F2F3,DFF1F2F3,DFErr);
  end;

  // F tests if all factors are random
  for i := 1 to 14 do OKterms[i] := 1; // initialize as OK

  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 1) and (Fact3Grp.ItemIndex = 1) then
  begin
    if  (MSF1F2 + MSF1F3 - MSF1F2F3) < 0.0
      then OKTerms[1] := 0
      else FF1 := abs(MSF1 / (MSF1F2 + MSF1F3 - MSF1F2F3));
    if  (MSF1F2 + MSF2F3 - MSF1F2F3) < 0.0
      then OKTerms[2] := 0
      else FF2 := abs(MSF2 / (MSF1F2 + MSF2F3 - MSF1F2F3));
    if  (MSF1F3 + MSF2F3 - MSF1F2F3) < 0.0
      then OKTerms[3] := 0
      else FF3 := abs(MSF3 / (MSF1F3 + MSF2F3 - MSF1F2F3));
    FF1F2 := abs(MSF1F2 / MSF1F2F3);
    FF1F3 := abs(MSF1F3 / MSF1F2F3);
    FF2F3 := abs(MSF2F3 / MSF1F2F3);
    FF1F2F3 := abs(MSF1F2F3 / MSErr);
    ProbF1 := probf(FF1,DFF1,DFF1F2F3);
    ProbF2 := probf(FF2,DFF2,DFF1F2F3);
    ProbF3 := probf(FF3,DFF3,DFF1F2F3);
    ProbF1F2 := probf(FF1F2,DFF1F2,DFF1F2F3);
    probF1F3 := probf(FF1F3,DFF1F3,DFF1F2F3);
    probF2F3 := probf(FF2F3,DFF2F3,DFF1F2F3);
    probF1F2F3 := probf(FF1F2F3,DFF1F2F3,DFErr);
  end;

  // F test if factor A is random, B and C Fixed
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 0) and (Fact3Grp.ItemIndex = 0) then
  begin
    FF1 := abs(MSF1 / MSErr);
    FF2 := abs(MSF2 / MSF1F2);
    FF3 := abs(MSF3 / MSF1F3);
    FF1F2 := abs(MSF1F2 / MSErr);
    FF1F3 := abs(MSF1F3 / MSErr);
    FF2F3 := abs(MSF2F3 / MSF1F2F3);
    FF1F2F3 := abs(MSF1F2F3 / MSErr);
    ProbF1 := probf(FF1,DFF1,DFErr);
    ProbF2 := probf(FF2,DFF2,DFF1F2);
    ProbF3 := probf(FF3,DFF3,DFF1F3);
    ProbF1F2 := probf(FF1F2,DFF1F2,DFErr);
    ProbF1F3 := probf(FF1F3,DFF1F3,DFErr);
    ProbF2F3 := probf(FF2F3,DFF2F3,DFF1F2F3);
    ProbF1F2F3 := probf(FF1F2F3,DFF1F2F3,DFErr);
  end;

  // F test if factor b is random and A and C are Fixed
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 1) and (Fact3Grp.ItemIndex = 0) then
  begin
    FF1 := abs(MSF1 / MSF1F2);
    FF2 := abs(MSF2 / MSErr);
    FF3 := abs(MSF3 / MSF2F3);
    FF1F2 := abs(MSF1F2 / MSErr);
    FF1F3 := abs(MSF1F3 / MSF1F2F3);
    FF2F3 := abs(MSF2F3 / MSErr);
    FF1F2F3 := abs(MSF1F2F3 / MSErr);
    ProbF1 := probf(FF1,DFF1,DFF1F2);
    ProbF2 := probf(FF2,DFF2,DFErr);
    ProbF3 := probf(FF3,DFF3,DFF2F3);
    ProbF1F2 := probf(FF1F2,DFF1F2,DFErr);
    ProbF1F3 := probf(FF1F3,DFF1F3,DFF1F2F3);
    ProbF2F3 := probf(FF2F3,DFF2F3,DFErr);
    ProbF1F2F3 := probf(FF1F2F3,DFF1F2F3,DFErr);
  end;

  // F test if factor c is random and A and B are Fixed
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 0) and (Fact3Grp.ItemIndex = 1) then
  begin
    FF1 := abs(MSF1 / MSF1F3);
    FF2 := abs(MSF2 / MSF2F3);
    FF3 := abs(MSF3 / MSErr);
    FF1F2 := abs(MSF1F2 / MSF1F2F3);
    FF1F3 := abs(MSF1F3 / MSErr);
    FF2F3 := abs(MSF2F3 / MSErr);
    FF1F2F3 := abs(MSF1F2F3 / MSErr);
    ProbF1 := probf(FF1,DFF1,DFF1F3);
    ProbF2 := probf(FF2,DFF2,DFF2F3);
    ProbF3 := probf(FF3,DFF3,DFErr);
    ProbF1F2 := probf(FF1F2,DFF1F2,DFF1F2F3);
    ProbF1F3 := probf(FF1F3,DFF1F3,DFErr);
    ProbF2F3 := probf(FF2F3,DFF2F3,DFErr);
    ProbF1F2F3 := probf(FF1F2F3,DFF1F2F3,DFErr);
  end;

  // F tests if A is fixed, B and C are random
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 1) and (Fact3Grp.ItemIndex = 1) then
  begin
    if (MSF1F3 + MSF1F2 - MSF1F2F3) < 0.0
      then OKTerms[1] := 0
      else FF1 := abs(MSF1 / (MSF1F3 + MSF1F2 - MSF1F2F3));
    FF2 := abs(MSF2 / MSF2F3);
    FF3 := abs(MSF3 / MSF2F3);
    FF1F2 := abs(MSF1F2 / MSF1F2F3);
    FF1F3 := abs(MSF1F3 / MSF1F2F3);
    FF2F3 := abs(MSF2F3 / MSErr);
    FF1F2F3 := abs(MSF1F2F3 / MSErr);
    if (DFF1F3 + DFF1F2 - DFF1F2F3) <= 0
      then OKTerms[8] := 0
      else ProbF1 := probf(FF1,DFF1,(DFF1F3 + DFF1F2 - DFF1F2F3));
    ProbF2 := probf(FF2,DFF2,DFF2F3);
    ProbF3 := probf(FF3,DFF3,DFF2F3);
    ProbF1F2 := probf(FF1F2,DFF1F2,DFF1F2F3);
    ProbF1F3 := probf(FF1F3,DFF1F3,DFF1F2F3);
    ProbF2F3 := probf(FF2F3,DFF2F3,DFErr);
    ProbF1F2F3 := probf(FF1F2F3,DFF1F2F3,DFErr);
  end;

  // F tests if B is fixed, A and C are random
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 0) and (Fact3Grp.ItemIndex = 1) then
  begin
    FF1 := abs(MSF2 / MSF1F3);
    if (MSF2F3 + MSF1F2 - MSF1F2F3) <= 0.0
      then OKTerms[2] := 0
      else FF2 := abs(MSF1 / (MSF2F3 + MSF1F2 - MSF1F2F3));
    FF3 := abs(MSF3 / MSF1F3);
    FF1F2 := abs(MSF1F2 / MSF1F2F3);
    FF1F3 := abs(MSF1F3 / MSErr);
    FF2F3 := abs(MSF2F3 / MSF1F2F3);
    FF1F2F3 := abs(MSF1F2F3 / MSErr);
    ProbF1 := probf(FF2,DFF2,DFF1F3);
    if (DFF2F3 + DFF1F2 - DFF1F2F3) <= 0
      then OKTerms[9] := 0
      else ProbF2 := probf(FF1,DFF1,(DFF2F3 + DFF1F2 - DFF1F2F3));
    ProbF3 := probf(FF3,DFF3,DFF1F3);
    ProbF1F2 := probf(FF1F2,DFF1F2,DFF1F2F3);
    ProbF1F3 := probf(FF1F3,DFF1F3,DFErr);
    ProbF2F3 := probf(FF2F3,DFF2F3,DFF1F2F3);
    ProbF1F2F3 := probf(FF1F2F3,DFF1F2F3,DFErr);
  end;

  // F tests if C is fixed A and B are random
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 1) and (Fact3Grp.ItemIndex = 0) then
  begin
    FF1 := abs(MSF1 / MSF1F2);
    FF2 := abs(MSF2 / MSF1F2);
    if (MSF2F3 + MSF1F3 - MSF1F2F3) <= 0.0
      then OKTerms[3] := 0
      else FF3 := abs(MSF3 / (MSF2F3 + MSF1F3 - MSF1F2F3));
    FF1F2 := abs(MSF2F3 / MSErr);
    FF1F3 := abs(MSF1F2 / MSF1F2F3);
    FF2F3 := abs(MSF1F3 / MSF1F2F3);
    FF1F2F3 := abs(MSF1F2F3 / MSErr);
    ProbF1 := probf(FF3,DFF3,DFF1F2);
    ProbF2 := probf(FF2,DFF2,DFF1F2);
    if (DFF2F3 + DFF1F3 - DFF1F2F3) <= 0
      then OKTerms[10] := 0
      else ProbF3 := probf(FF1,DFF1,(DFF2F3 + DFF1F3 - DFF1F2F3));
    ProbF1F2 := probf(FF2F3,DFF2F3,DFErr);
    ProbF1F3 := probf(FF1F2,DFF1F2,DFF1F2F3);
    ProbF2F3 := probf(FF1F3,DFF1F3,DFF1F2F3);
    ProbF1F2F3 := probf(FF1F2F3,DFF1F2F3,DFErr);
  end;

  if (ProbF1 > 1.0) then ProbF1 := 1.0;
  if (ProbF2 > 1.0) then ProbF2 := 1.0;
  if ProbF3 > 1.0 then ProbF3 := 1.0;
  if (ProbF1F2 > 1.0) then ProbF1F2 := 1.0;
  if ProbF1F3 > 1.0 then ProbF1F3 := 1.0;
  if ProbF2F3 > 1.0 then ProbF2F3 := 1.0;
  if ProbF1F2F3 > 1.0 then ProbF1F2F3 := 1.0;

  // Obtain omega squared (proportion of dependent variable explained)
  if (OmegaF1 < 0.0) then OmegaF1 := 0.0;
  if (OmegaF2 < 0.0) then OmegaF2 := 0.0;
  if OmegaF3 < 0.0 then OmegaF3 := 0.0;
  if (OmegaF1F2 < 0.0) then OmegaF1F2 := 0.0;
  if OmegaF1F3 < 0.0 then OmegaF1F3 := 0.0;
  if OmegaF2F3 < 0.0 then OmegaF2F3 := 0.0;
  if OmegaF1F2F3 < 0.0 then OmegaF1F2F3 := 0.0;
  if (Omega < 0.0) then Omega := 0.0;
end;

procedure TBlksAnovaFrm.ThreeWayTable(AReport: TStrings);
var
  groupsize: integer;
  MinVar, MaxVar, sumvars, sumDFrecip: double;
  i, j, k: integer;
  XBar, V, S, RowSS, ColSS, SlcSS: double;
  sumfreqlogvar, c, bartlett, cochran, hartley, chiprob: double;
  problem: boolean;
begin
  if CompError then
    exit;

  problem := false;
  AReport.Add('Three Way Analysis of Variance');
  AReport.Add('');
  AReport.Add('Variable analyzed: %s', [DepVar.Text]);
  AReport.Add('');

  outline := format('Factor A (rows) variable: %s', [Factor1.Text]);
  if Fact1Grp.ItemIndex = 0 then
    outline := outline + ' (Fixed Levels)'
  else
     outline := outline + ' (Random Levels)';
  AReport.Add(outline);

  outline := format('Factor B (columns) variable: %s', [Factor2.Text]);
  if Fact2Grp.ItemIndex = 0 then
    outline := outline + ' (Fixed Levels)'
  else
     outline := outline + ' (Random Levels)';
  AReport.Add(outline);

  outline := format('Factor C (slices) variable: %s', [Factor3.Text]);
  if Fact3Grp.ItemIndex = 0 then
    outline := outline + ' (Fixed Levels)'
  else
    outline := outline + ' (Random Levels)';
  AReport.Add(outline);
  AReport.Add('');

  AReport.Add('SOURCE         D.F.      SS          MS           F      PROB.> F   Omega Squared');
  AReport.Add('');
  if (OKTerms[1] = 1) and (OKTerms[8] = 1) then
    AReport.Add('Among Rows     %4.0f  %10.3f  %10.3f  %10.3f  %6.3f     %6.3f', [DFF1, SSF1, MSF1, FF1, ProbF1, OmegaF1])
  else
    AReport.Add('Among Rows     %4.0f  %10.3f  %10.3f --- error ---', [DFF1, SSF1, MSF1 ]);

  if (OKTerms[2] = 1) and (OKTerms[9] = 1) then
    AReport.Add('Among Columns  %4.0f  %10.3f  %10.3f  %10.3f  %6.3f     %6.3f', [DFF2, SSF2, MSF2, FF2, ProbF2, OmegaF2])
  else
    AReport.Add('Among Columns  %4.0f  %10.3f  %10.3f --- error ---', [DFF2, SSF2, MSF2]);

  if (OKTerms[3] = 1) and (OKTerms[10] = 1) then
    AReport.Add('Among Slices   %4.0f  %10.3f  %10.3f  %10.3f  %6.3f     %6.3f', [DFF3, SSF3, MSF3, FF3, ProbF3, OmegaF3])
  else
    AReport.Add('Among Slices   %4.0f  %10.3f  %10.3f --- error ---', [DFF3, SSF3, MSF3]);

  AReport.Add('A x B Inter.   %4.0f  %10.3f  %10.3f  %10.3f  %6.3f     %6.3f', [DFF1F2, SSF1F2, MSF1F2, FF1F2, ProbF1F2, OmegaF1F2]);
  AReport.Add('A x C Inter.   %4.0f  %10.3f  %10.3f  %10.3f  %6.3f     %6.3f', [DFF1F3, SSF1F3, MSF1F3, FF1F3, ProbF1F3, OmegaF1F3]);
  AReport.Add('B x C Inter.   %4.0f  %10.3f  %10.3f  %10.3f  %6.3f     %6.3f', [DFF2F3, SSF2F3, MSF2F3, FF2F3, ProbF2F3, OmegaF2F3]);
  AReport.Add('AxBxC Inter.   %4.0f  %10.3f  %10.3f  %10.3f  %6.3f     %6.3f', [DFF1F2F3, SSF1F2F3, MSF1F2F3, FF1F2F3, ProbF1F2F3, OmegaF1F2F3]);
  AReport.Add('Within Groups  %4.0f  %10.3f  %10.3f', [DFErr, SSErr, MSErr]);
  AReport.Add('Total          %4.0f  %10.3f  %10.3f', [DFTot, SSDep, MSDep]);
  AReport.Add('');
  AReport.Add('Omega squared for combined effects = %8.3f', [Omega]);
  AReport.Add('');
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 0) and (Fact3Grp.ItemIndex = 0) then
    AReport.Add('Note: MSErr denominator for all F ratios.');
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 1) and (Fact3Grp.ItemIndex = 1) then
  begin
    AReport.Add('Note: Error term for A is MSAxB + MSAxC - MSAxBxC');
    AReport.Add('Error term for B is MSAxB + MSBxC - MSAxBxC');
    AReport.Add('Error term for C is MSAxC + MSBxC - MSAxBxC');
    AReport.Add('Error term for AxB, AxC and BxC is MSAxBxC');
    AReport.Add('Error term for AxBxC is MSErr.');
  end;
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 0) and (Fact3Grp.ItemIndex = 0) then
  begin
    AReport.Add('Note: Error term for A is MSErr');
    AReport.Add('Note: Error term for B is MSAxB');
    AReport.Add('Note: Error term for C is MSAxC');
    AReport.Add('Note: Error term for AxB is MSErr');
    AReport.Add('Note: Error term for AxC is MSErr');
    AReport.Add('Note: Error term for BxC is MSAxBxC');
    AReport.Add('Note: Error term for AxBxC is MSErr');
  end;
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 1) and (Fact3Grp.ItemIndex = 0) then
  begin
    AReport.Add('Note: Error term for A is MSAxB');
    AReport.Add('Note: Error term for B is MSErr');
    AReport.Add('Note: Error term for C is MSBxC');
    AReport.Add('Note: Error term for AxB is MSErr');
    AReport.Add('Note: Error term for AxC is MSAxBxC');
    AReport.Add('Note: Error term for BxC is MSErr');
    AReport.Add('Note: Error term for AxBxC is MSErr');
  end;
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 0) and (Fact3Grp.ItemIndex = 1) then
  begin
    AReport.Add('Note: Error term for A is MSAxC');
    AReport.Add('Note: Error term for B is MSBxC');
    AReport.Add('Note: Error term for C is MSErr');
    AReport.Add('Note: Error term for AxB is MSAxBxC');
    AReport.Add('Note: Error term for AxC is MSErr');
    AReport.Add('Note: Error term for BxC is MSErr');
    AReport.Add('Note: Error term for AxBxC is MSErr');
  end;
  if (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 1) and (Fact3Grp.ItemIndex = 1) then
  begin
    AReport.Add('Note: Error term for A is MSAxC + MSAxB - MSAxBxC');
    AReport.Add('Note: Error term for B is MSBxC');
    AReport.Add('Note: Error term for C is MSBxC');
    AReport.Add('Note: Error term for AxB is MSAxBxC');
    AReport.Add('Note: Error term for AxC is MSAxBxC');
    AReport.Add('Note: Error term for BxC is MSErr');
    AReport.Add('Note: Error term for AxBxC is MSErr');
  end;
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 0) and (Fact3Grp.ItemIndex = 1) then
  begin
    AReport.Add('Note: Error term for A is MSAxC');
    AReport.Add('Note: Error term for B is MSBxC + MSAxB - MSAxBxC');
    AReport.Add('Note: Error term for C is MSAxC');
    AReport.Add('Note: Error term for AxB is MSAxBxC');
    AReport.Add('Note: Error term for AxC is MSErr');
    AReport.Add('Note: Error term for BxC is MSAxBxC');
    AReport.Add('Note: Error term for AxBxC is MSErr');
  end;
  if (Fact1Grp.ItemIndex = 1) and (Fact2Grp.ItemIndex = 1) and (Fact3Grp.ItemIndex = 0) then
  begin
    AReport.Add('Note: Error term for A is MSAxB');
    AReport.Add('Note: Error term for B is MSAxB');
    AReport.Add('Note: Error term for C is MSBxC + MSAxC - MSAxBxC');
    AReport.Add('Note: Error term for AxB is MSErr');
    AReport.Add('Note: Error term for AxC is MSAxBxC');
    AReport.Add('Note: Error term for BxC is MSAxBxC');
    AReport.Add('Note: Error term for AxBxC is MSErr');
  end;
  AReport.Add('');

  for i := 1 to 10 do
    if OKTerms[i] = 0 then problem := true;
  if problem then
  begin
    AReport.Add('An error occurred due to either an estimate of MS being negative');
    AReport.Add('or the degrees of freedom being zero.  This may occur in a design');
    AReport.Add('with random factors using the expected values for an exact F-test.');
    AReport.Add('Quasi-F statistics may be employed where this problem exists. See');
    AReport.Add('Winer, B.J., "Statistical Principles in Experimental Design, 1962');
    AReport.Add('Section 5.15, pages 199-202 and Glass, G.V. and Stanley, J.C.,');
    AReport.Add('1970, Section 18.10, pages 481-482.');
  end;

  AReport.Add('');
  AReport.Add('Descriptive Statistics');
  AReport.Add('');
  AReport.Add('GROUP               N     MEAN   VARIANCE  STD.DEV.');

  groupsize := ncnt[1,1,1];
  equal_grp := true;
  MaxVar := 0.0;
  MinVar := 1e20;
  sumvars := 0.0;
  sumfreqlogvar := 0.0;
  sumDFrecip := 0.0;

  // Display cell means, variances, standard deviations
  for i := 0 to NoGrpsA-1 do
  begin
    for j := 0 to NoGrpsB-1 do
    begin
      for k := 0 to NoGrpsC-1 do
      begin
        XBar := wsum[i,j,k] / ncnt[i,j,k];
        V := wx2[i,j,k] - ( (wsum[i,j,k] * wsum[i,j,k]) / ncnt[i,j,k]);
        V := V / (ncnt[i,j,k] - 1.0);
        S := sqrt(V);
        sumvars  := sumvars + V;
        if V > MaxVar then MaxVar := V;
        if V < MinVar then MinVar := V;
        sumDFrecip := sumDFrecip + (1.0 / (ncnt[i,j,k] - 1.0));
        sumfreqlogvar := sumfreqlogvar + ((ncnt[i,j,k] - 1.0) * ln(V));
        if ncnt[i,j,k] <> groupsize then equal_grp := false;
        AReport.Add('Cell  %3d %3d %3d %3d  %8.3f  %8.3f  %8.3f', [minf1+i, minf2+j, minf3+k, ncnt[i,j,k], XBar, V, S]);
      end;
    end;
  end;

  //Display Row means, variances, standard deviations
  for i := 0 to NoGrpsA-1 do
  begin
    XBar := RowSums[i] / RowCount[i];
    OrdMeansA[i] := XBar;
    RowSS := 0.0;
    for j := 0 to NoGrpsB-1 do
      for k := 0 to NoGrpsC-1 do RowSS := RowSS + wx2[i,j,k];
    V := RowSS - (RowSums[i] * RowSums[i] / RowCount[i]);
    V := V / (RowCount[i] - 1.0);
    S := sqrt(V);
    AReport.Add('Row   %3d         %3d  %8.3f  %8.3f  %8.3f', [minf1+i, RowCount[i], XBar, V, S]);
  end;

  //Display means, variances and standard deviations for columns
  for j := 0 to NoGrpsB-1 do
  begin
    XBar := ColSums[j] / ColCount[j];
    OrdMeansB[j] := XBar;
    ColSS := 0.0;
    for i := 0 to NoGrpsA-1 do
      for k := 0 to NoGrpsC-1 do ColSS := ColSS + wx2[i,j,k];
    V := ColSS - (ColSums[j] * ColSums[j] / ColCount[j]);
    V := V / (ColCount[j] - 1.0);
    S := sqrt(V);
    AReport.Add('Col   %3d         %3d  %8.3f  %8.3f  %8.3f', [minf2+j, ColCount[j], XBar, V, S]);
  end;

  //Display means, variances and standard deviations for slices
  for k := 0 to NoGrpsC-1 do
  begin
    XBar := SlcSums[k] / SlcCount[k];
    OrdMeansC[k] := XBar;
    SlcSS := 0.0;
    for i := 0 to NoGrpsA-1 do
      for j := 0 to NoGrpsB-1 do SlcSS := SlcSS + wx2[i,j,k];
    V := SlcSS - (SlcSums[k] * SlcSums[k] / SlcCount[k]);
    V := V / (SlcCount[k] - 1.0);
    S := sqrt(V);
    AReport.Add('Slice %3d         %3d  %8.3f  %8.3f  %8.3f', [minf3+k, SlcCount[k], XBar, V, S]);
  end;

  AReport.ADd('TOTAL             %3d  %8.3f  %8.3f  %8.3f', [N, MeanDep, MSDep, sqrt(MSDep)]);
  AReport.Add('');
  AReport.Add('');

  c := 1.0 + (1.0 / (3.0 * NoGrpsA * NoGrpsB * NoGrpsC - 1.0)) * (sumDFrecip - (1.0 / DFErr));
  bartlett := (2.303 / c) * ((DFErr * ln(MSErr)) - sumfreqlogvar);
  chiprob := chisquaredprob(bartlett,round(NoGrpsA * NoGrpsB * NoGrpsC - 1));
  cochran := maxvar / sumvars;
  hartley := maxvar / minvar;
  AReport.Add(DIVIDER);
  AReport.Add('TESTS FOR HOMOGENEITY OF VARIANCE');
  AReport.Add(DIVIDER_SMALL);
  AReport.Add('Hartley Fmax test statistic:   %8.2f   with deg.s freedom: %d and %d.', [hartley, NoGrpsA*NoGrpsB, groupsize-1]);
  AReport.Add('Cochran C statistic:           %8.2f   with deg.s freedom: %d and %d.', [cochran, NoGrpsA*NoGrpsB, groupsize - 1]);
  AReport.Add('Bartlett Chi-square statistic: %8.2f   with %d D.F. Prob. larger: %.3f', [bartlett, NoGrpsA*NoGrpsB - 1, 1.0 - chiprob]);
  AReport.Add(DIVIDER);
end;

procedure TBlksAnovaFrm.ThreeWayPlot;
var
  i, j, k : integer;
  maxmean, XBar : double;
  plottype : integer;
begin
  if CompError then exit;

  plottype := 2;
  if PlotMeans.Checked then plottype := 2;
  if Plot2DLines.Checked then plottype := 5;
  if Plot3DLines.Checked then plottype := 6;

  // do Factor A first
  GraphFrm.SetLabels[1] := 'FACTOR A';
  SetLength(GraphFrm.Xpoints,1,NF1cells);
  SetLength(GraphFrm.Ypoints,1,NF1cells);
  maxmean := 0.0;
  for i := 0 to NF1cells-1 do
  begin
    RowSums[i] := RowSums[i] / RowCount[i];
    GraphFrm.Ypoints[0,i] := RowSums[i];
    if RowSums[i] > maxmean then maxmean := RowSums[i];
    GraphFrm.Xpoints[0,i] := minF1 + i;
  end;

  GraphFrm.nosets := 1;
  GraphFrm.nbars := NF1cells;
  GraphFrm.Heading := Factor1.Text;
  GraphFrm.XTitle := Factor1.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;
  if GraphFrm.ShowModal <> mrOK then
    exit;

  // do Factor B next
  GraphFrm.SetLabels[1] := 'FACTOR B';
  maxmean := 0.0;
  SetLength(GraphFrm.Xpoints, 1, NF2cells);
  SetLength(GraphFrm.Ypoints, 1, NF2cells);
  for i := 0 to NF2cells-1 do
  begin
    ColSums[i] := ColSums[i] / ColCount[i];
    GraphFrm.Ypoints[0,i] := ColSums[i];
    if ColSums[i] > maxmean then maxmean := ColSums[i];
    GraphFrm.Xpoints[0,i] := minF2 + i;
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := NF2cells;
  GraphFrm.Heading := Factor2.Text;
  GraphFrm.XTitle := Factor2.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;
  if GraphFrm.ShowModal <> mrOK then
    exit;

  // do Factor C next
  GraphFrm.SetLabels[1] := 'FACTOR C';
  maxmean := 0.0;
  SetLength(GraphFrm.Xpoints, 1, NF3cells);
  SetLength(GraphFrm.Ypoints, 1, NF3cells);
  for i := 0 to NF3cells-1 do
  begin
    SlcSums[i] := SlcSums[i] / SlcCount[i];
    GraphFrm.Ypoints[0,i] := SlcSums[i];
    if SlcSums[i] > maxmean then maxmean := SlcSums[i];
    GraphFrm.Xpoints[0,i] := minF3 + i;
  end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := NF3cells;
  GraphFrm.Heading := Factor3.Text;
  GraphFrm.XTitle := Factor2.Text + ' Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;
  if GraphFrm.ShowModal <> mrOK then
    exit;

  // do Factor A x B Interaction within each slice next
  SetLength(GraphFrm.Ypoints, NF1cells, NF2cells);
  SetLength(GraphFrm.Xpoints, 1, NF2cells);
  for k := 0 to NF3cells-1 do
  begin
    maxmean := 0.0;
    for i := 0 to NF1cells-1 do
    begin
      GraphFrm.SetLabels[i+1] := Factor1.Text + ' ' + IntToStr(i+1);
      for j := 0 to NF2cells-1 do
      begin
        XBar := wsum[i,j,k] / ncnt[i,j,k];
        if XBar > maxmean then maxmean := XBar;
        GraphFrm.Ypoints[i,j] := XBar;
      end;
    end;
    for j := 0 to NF2cells-1 do
      GraphFrm.Xpoints[0,j] := minF2 + j ;

    GraphFrm.nosets := NF1cells;
    GraphFrm.nbars := NF2cells;
    GraphFrm.Heading := 'Factor A x Factor B Within Slice' + IntToStr(k);
    GraphFrm.XTitle := Factor2.Text + ' Codes';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := false;
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.GraphType := plottype;
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
    GraphFrm.ShowBackWall := true;
    if GraphFrm.ShowModal <> mrOK then
      exit;
  end;

  // do Factor A x C Interaction within each Column next
  SetLength(GraphFrm.Ypoints, NF1cells, NF3cells);
  SetLength(GraphFrm.Xpoints, 1, NF3cells);
  for j := 0 to NF2cells-1 do
  begin
    maxmean := 0.0;
    for i := 0 to NF1cells-1 do
    begin
      GraphFrm.SetLabels[i+1] := Factor1.Text + ' ' + IntToStr(i+1);
      for k := 0 to NF3cells-1 do
      begin
        XBar := wsum[i,j,k] / ncnt[i,j,k];
        if XBar > maxmean then maxmean := XBar;
        GraphFrm.Ypoints[i,k] := XBar;
      end;
    end;
    for k := 0 to NF3cells-1 do
      GraphFrm.Xpoints[0,k] := minF3 + k;

    GraphFrm.nosets := NF1cells;
    GraphFrm.nbars := NF3cells;
    GraphFrm.Heading := 'Factor A x Factor C Within Column ' + IntToStr(j+1);
    GraphFrm.XTitle := Factor3.Text + ' Codes';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := false;
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.GraphType := plottype;
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
    GraphFrm.ShowBackWall := true;
    if GraphFrm.ShowModal <> mrOK then
      exit;
  end;

  // do Factor B x C Interaction within each row next
  SetLength(GraphFrm.Ypoints, NF2cells, NF3cells);
  SetLength(GraphFrm.Xpoints, 1, NF3cells);
  for i := 0 to NF1cells-1 do
  begin
    maxmean := 0.0;
    for j := 0 to NF2cells-1 do
    begin
      GraphFrm.SetLabels[j+1] := Factor2.Text + ' ' + IntToStr(j+1);
      for k := 0 to NF3cells-1 do
      begin
        XBar := wsum[i,j,k] / ncnt[i,j,k];
        if XBar > maxmean then maxmean := XBar;
        GraphFrm.Ypoints[j,k] := XBar;
      end;
    end;
    for j := 0 to NF2cells-1 do
      GraphFrm.Xpoints[0,j] := minF2 + j;

    GraphFrm.nosets := NF2cells;
    GraphFrm.nbars := NF3cells;
    GraphFrm.Heading := 'Factor B x Factor C Within Row ' + IntToStr(i+1);
    GraphFrm.XTitle := Factor3.Text + ' Codes';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := false;
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.GraphType := plottype;
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
    GraphFrm.ShowBackWall := true;
    if GraphFrm.ShowModal <> mrOK then
      exit;
  end; // next row

  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;
//-------------------------------------------------------------------
procedure TBlksAnovaFrm.TwoWayContrasts(AReport: TStrings);
var
   i, j : integer;
   value : double;
   variances : DblDyneVec;
   RowSS, ColSS : double;

begin
  if CompError then
    exit;

  SetLength(variances,totcells);

  // Do row comparisons
  if (NF1cells > 2) then
    if ProbF1 < allAlpha then
      if Fact2Grp.ItemIndex = 0 then
      begin
        for i := 0 to NoGrpsA-1 do
        begin
          RowSS := 0.0;
          for j := 0 to NoGrpsB-1 do RowSS := RowSS + vars[i,j];
          variances[i] := RowSS - (RowSums[i] * RowSums[i] / RowCount[i]);
          variances[i] := variances[i] / (RowCount[i] - 1.0);
        end;

        AReport.Add('');
        AReport.Add('COMPARISONS AMONG ROWS');

        // get smallest group size
        value := 1e308;
        for i := 0 to NF1cells-1 do if RowCount[i] < value then value := RowCount[i];
        if Scheffe.Checked then
          ScheffeTest(MSErr, RowSums, RowCount, minf1, maxf1, N, posthocAlpha, AReport);
        if TukeyHSD.Checked and equal_grp then
          Tukey(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
        if TukeyB.Checked and equal_grp then
          TukeyBTest(MSErr, DFErr, RowSums, RowCount, minf1, maxf1, value, posthocAlpha, AReport);
        if TukeyKramer.Checked and equal_grp then
          Tukey_Kramer(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
        if NewmanKeuls.Checked and equal_grp then
          Newman_Keuls(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
        if Bonferoni.Checked then
          Bonferroni(RowSums, RowCount, variances, minf1, maxf1, posthocAlpha, AReport);
        if OrthoContrasts.Checked then
          Contrasts(MSErr, DFErr, RowSums, RowCount, minf1, maxf1, AllAlpha, posthocAlpha, AReport);
      end;

      // Do column comparisons
      if (NF2cells > 2) and (ProbF2 < allAlpha) and (Fact2Grp.ItemIndex = 0) then
      begin
        for j := 0 to NoGrpsB-1 do
        begin
          ColSS := 0.0;
          for i := 0 to NoGrpsA-1 do ColSS := ColSS + vars[i,j];
          variances[j] := ColSS - (ColSums[j] * ColSums[j] / ColCount[j]);
          variances[j] := variances[j] / (ColCount[j] - 1.0);
        end;
        AReport.Add('');
        AReport.Add('COMPARISONS AMONG COLUMNS');
        value := 1e20;
        for i := 0 to NF2cells-1 do
          if ColCount[i] < value then value := ColCount[i];
        if Scheffe.Checked then
          ScheffeTest(MSErr, ColSums, ColCount, minf2, maxf2, N, posthocAlpha, AReport);
        if TukeyHSD.Checked and equal_grp then
          Tukey(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
        if TukeyB.Checked and equal_grp then
          TukeyBTest(MSErr, DFErr, ColSums, ColCount, minf2, maxf2, value, posthocAlpha, AReport);
        if TukeyKramer.Checked and equal_grp then
          Tukey_Kramer(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
        if NewmanKeuls.Checked and equal_grp then
          Newman_Keuls(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
        if Bonferoni.Checked then
          Bonferroni(ColSums, ColCount, variances, minf2, maxf2, posthocAlpha, AReport);
        if OrthoContrasts.Checked then
          Contrasts(MSErr, DFErr, ColSums, ColCount, minf2, maxf2, AllAlpha, postHocAlpha, AReport);
      end;

      // do simple effects for columns within each row
      if (ProbF3 < allAlpha) and (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 0) then
      begin
        AReport.Add('');
        AReport.Add('COMPARISONS AMONG COLUMNS WITHIN EACH ROW');
        for i := 0 to NF1cells-1 do
        begin
          AReport.Add('');
          AReport.Add('ROW %d COMPARISONS',[i+1]);
          // move cell sums and counts to cellsums and cellcnts
          for j := 0 to NF2cells-1 do
          begin
            cellsums[j] := sums[i,j];
            cellcnts[j] := counts[i,j];
            cellvars[j] := vars[i,j];
          end;
          value := 1e308;
          for j := 0 to NF2cells-1 do
            if cellcnts[j] < value then value := cellcnts[j];
          if Scheffe.Checked then
            ScheffeTest(MSErr, cellsums, cellcnts, minf2, maxf2, N, posthocAlpha, AReport);
          if TukeyHSD.Checked and equal_grp then
            Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
          if TukeyB.Checked and equal_grp then
            TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, value, posthocAlpha, AReport);
          if TukeyKramer.Checked and equal_grp then
            Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
          if NewmanKeuls.Checked and equal_grp then
            Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
          if Bonferoni.Checked then
            Bonferroni(cellsums, cellcnts, cellvars, minf2, maxf2, posthocAlpha, AReport);
          if OrthoContrasts.Checked then
            Contrasts(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, allAlpha, PostHocAlpha, AReport);
        end;
      end;

      // do simple effects for rows within each column
      if (ProbF3 < allAlpha) and (Fact1Grp.ItemIndex = 0) and (Fact2Grp.ItemIndex = 0) then
      begin
        AReport.Add('');
        AReport.Add('COMPARISONS AMONG ROWS WITHIN EACH COLUMN');
        for j := 0 to NF2cells-1 do
        begin
          AReport.Add('');
          AReport.Add('COLUMN %d COMPARISONS', [j+1]);
          // move cell sums and counts to cellsums and cellcnts
          for i := 0 to NF1cells-1 do
          begin
            cellsums[i] := sums[i,j];
            cellcnts[i] := counts[i,j];
            cellvars[i] := vars[i,j];
          end;
          value := 1e308;
          for i := 0 to NF1cells-1 do
            if cellcnts[j] < value then value := cellcnts[j];
          if Scheffe.Checked then
            ScheffeTest(MSErr, cellsums, cellcnts, minf1, maxf1, N, posthocAlpha, AReport);
            if TukeyHSD.Checked and equal_grp then
              Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
            if TukeyB.Checked and equal_grp then
              TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, value, posthocAlpha, AReport);
            if TukeyKramer.Checked and equal_grp then
              Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
            if NewmanKeuls.Checked and equal_grp then
              Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
            if Bonferoni.Checked then
              Bonferroni(cellsums, cellcnts, cellvars, minf1, maxf1, posthocAlpha, AReport);
            if OrthoContrasts.Checked then
              Contrasts(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, allAlpha, postHocAlpha, AReport);
        end;
      end;
      variances := nil;
end;

procedure TBlksAnovaFrm.ThreeWayContrasts(AReport: TStrings);
var
   i, j, k : integer;
   value : double;
   variances : DblDyneVec;
   RowSS, ColSS, SlcSS : double;

begin
     if CompError then
       exit;

     if (Scheffe.Checked = false) and (TukeyHSD.Checked = false) and
        (TukeyB.Checked = false) and (TukeyKramer.Checked = false) and
        (NewmanKeuls.Checked = false) and (Bonferoni.Checked = false) and
        (OrthoContrasts.Checked = false) then exit;
     SetLength(variances,totcells);

     // Do row comparisons
     if (NF1cells > 2) and (ProbF1 < allAlpha) then
     begin
          for i := 0 to NoGrpsA-1 do
          begin
               RowSS := 0.0;
               for j := 0 to NoGrpsB-1 do
                   for k := 0 to NoGrpsC-1 do RowSS := RowSS + wx2[i,j,k];
               variances[i] := RowSS - (RowSums[i] * RowSums[i] / RowCount[i]);
               variances[i] := variances[i] / (RowCount[i] - 1.0);
          end;
          AReport.Add('');
          AReport.Add('COMPARISONS AMONG ROWS');
          // get smallest group size
          value := 1e20;
          for i := 0 to NF1cells-1 do if RowCount[i] < value then value := RowCount[i];
          if Scheffe.Checked then
            ScheffeTest(MSErr, RowSums, RowCount, minf1, maxf1, N, posthocAlpha, AReport);
          if TukeyHSD.Checked and equal_grp then
            Tukey(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
          if TukeyB.Checked and equal_grp then
            TukeyBTest(MSErr, DFErr, RowSums, RowCount, minf1, maxf1, value, posthocAlpha, AReport);
          if TukeyKramer.Checked and equal_grp then
            Tukey_Kramer(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
          if NewmanKeuls.Checked and equal_grp then
            Newman_Keuls(MSErr, DFErr, value, RowSums, RowCount, minf1, maxf1, posthocAlpha, AReport);
          if Bonferoni.Checked then
            Bonferroni(RowSums, RowCount, variances, minf1, maxf1, posthocAlpha, AReport);
          if OrthoContrasts.Checked then
            Contrasts(MSErr, DFErr, RowSums, RowCount, minf1, maxf1, allAlpha, postHocAlpha, AReport);
     end;

     // Do column comparisons
     if (NF2cells > 2) and (ProbF2 < allAlpha) then
     begin
          for j := 0 to NoGrpsB-1 do
          begin
               ColSS := 0.0;
               for i := 0 to NoGrpsA-1 do
                   for k := 0 to NoGrpsC-1 do ColSS := ColSS + wx2[i,j,k];
               variances[j] := ColSS - (ColSums[j] * ColSums[j] / ColCount[j]);
               variances[j] := variances[j] / (ColCount[j] - 1.0);
          end;
          AReport.Add('');
          AReport.Add('COMPARISONS AMONG COLUMNS');
          value := 1e308;
          for i := 0 to NF2cells-1 do
            if ColCount[i] < value then value := ColCount[i];
          if Scheffe.Checked then
            ScheffeTest(MSErr, ColSums, ColCount, minf2, maxf2, N, posthocAlpha, AReport);
          if TukeyHSD.Checked and equal_grp then
            Tukey(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
          if TukeyB.Checked and equal_grp then
            TukeyBTest(MSErr, DFErr, ColSums, ColCount, minf2, maxf2, value, posthocAlpha, AReport);
          if TukeyKramer.Checked and equal_grp then
            Tukey_Kramer(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
          if NewmanKeuls.Checked and equal_grp then
            Newman_Keuls(MSErr, DFErr, value, ColSums, ColCount, minf2, maxf2, posthocAlpha, AReport);
          if Bonferoni.Checked then
            Bonferroni(ColSums, ColCount, variances, minf2, maxf2, posthocAlpha, AReport);
          if OrthoContrasts.Checked then
            Contrasts(MSErr, DFErr, ColSums, ColCount, minf2, maxf2, allAlpha, posthocAlpha, AReport);
     end;

     // Do slice comparisons
     if (NF3cells > 2) and (ProbF3 < allAlpha) then
     begin
          for k := 0 to NoGrpsC-1 do
          begin
               SlcSS := 0.0;
               for i := 0 to NoGrpsA-1 do
                   for j := 0 to NoGrpsB-1 do SlcSS := SlcSS + wx2[i,j,k];
               variances[k] := SlcSS - (SlcSums[k] * SlcSums[k] / SlcCount[k]);
               variances[k] := variances[k] / (SlcCount[k] - 1.0);
          end;
          AReport.Add('');
          AReport.Add('COMPARISONS AMONG SLICES');
          value := 1e308;
          for i := 0 to NF3cells-1 do
            if SlcCount[i] < value then value := SlcCount[i];
          if Scheffe.Checked then
            ScheffeTest(MSErr, SlcSums, SlcCount, minf3, maxf3, N, posthocAlpha, AReport);
          if TukeyHSD.Checked and equal_grp then
            Tukey(MSErr, DFErr, value, SlcSums, SlcCount, minf3, maxf3, posthocAlpha, AReport);
          if TukeyB.Checked and equal_grp then
            TukeyBTest(MSErr, DFErr, SlcSums, SlcCount, minf3, maxf3, value, posthocAlpha, AReport);
          if TukeyKramer.Checked and equal_grp then
            Tukey_Kramer(MSErr, DFErr, value, SlcSums, SlcCount, minf3, maxf3, posthocAlpha, AReport);
          if NewmanKeuls.Checked and equal_grp then
            Newman_Keuls(MSErr, DFErr, value, SlcSums, SlcCount, minf3, maxf3, posthocAlpha, AReport);
          if Bonferoni.Checked then
            Bonferroni(SlcSums, SlcCount, variances, minf3, maxf3, posthocAlpha, AReport);
          if OrthoContrasts.Checked then
            Contrasts(MSErr, DFErr, SlcSums, SlcCount, minf3, maxf3, allAlpha, posthocAlpha, AReport);
     end;

     // do simple effects for columns within each row
     if (ProbF1f2 < allAlpha) then
     begin
          AReport.Add('');
          AReport.Add('COMPARISONS AMONG COLUMNS WITHIN EACH ROW');
          for i := 0 to NF1cells-1 do
          begin
               AReport.Add('');
               AReport.Add('ROW %d COMPARISONS',[i+1]);
               // move cell sums and counts to cellsums and cellcnts
               for j := 0 to NF2cells-1 do
               begin
                    for k := 0 to NF3cells-1 do
                    begin
                         cellsums[j] := wsum[i,j,k];
                         cellcnts[j] := ncnt[i,j,k];
                         cellvars[j] := wx2[i,j,k];
                    end;
               end;
               value := 1e308;
               for j := 0 to NF2cells-1 do
                 if cellcnts[j] < value then value := cellcnts[j];
               if Scheffe.Checked then
                 ScheffeTest(MSErr, cellsums, cellcnts, minf2, maxf2, N, posthocAlpha, AReport);
               if TukeyHSD.Checked and equal_grp then
                 Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
               if TukeyB.Checked and equal_grp then
                 TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, value, posthocAlpha, AReport);
               if TukeyKramer.Checked and equal_grp then
                 Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
               if NewmanKeuls.Checked and equal_grp then
                 Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
               if Bonferoni.Checked then
                 Bonferroni(cellsums, cellcnts, cellvars, minf2, maxf2, posthocAlpha, AReport);
               if OrthoContrasts.Checked then
                 Contrasts(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, allAlpha, posthocAlpha, AReport);
          end;
     end;

     // do simple effects for rows within each column
     if (ProbF1f2 < allAlpha) then
     begin
          AReport.Add('');
          AReport.Add('COMPARISONS AMONG ROWS WITHIN EACH COLUMN');
          for j := 0 to NF2cells-1 do
          begin
               AReport.Add('');
               AReport.Add('COLUMN %d COMPARISONS', [j+1]);
               // move cell sums and counts to cellsums and cellcnts
               for i := 0 to NF1cells-1 do
               begin
                    for k := 0 to NF3cells-1 do
                    begin
                         cellsums[i] := wsum[i,j,k];
                         cellcnts[i] := ncnt[i,j,k];
                         cellvars[i] := wx2[i,j,k];
                    end;
               end;
               value := 1e308;
               for i := 0 to NF1cells-1 do
                 if cellcnts[j] < value then value := cellcnts[j];
               if Scheffe.Checked then
                 ScheffeTest(MSErr, cellsums, cellcnts, minf1, maxf1, N, posthocAlpha, AReport);
               if TukeyHSD.Checked and equal_grp then
                 Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
               if TukeyB.Checked and equal_grp then
                 TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, value, posthocAlpha, AReport);
               if TukeyKramer.Checked and equal_grp then
                 Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
               if NewmanKeuls.Checked and equal_grp then
                 Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
               if Bonferoni.Checked then
                 Bonferroni(cellsums, cellcnts, cellvars, minf1, maxf1, posthocAlpha, AReport);
               if OrthoContrasts.Checked then
                 Contrasts(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, allAlpha, posthocAlpha, AReport);
          end;
     end;

     // do simple effects for columns within each slice
     if (ProbF2F3 < allAlpha) then
     begin
          AReport.Add('');
          AReport.Add('COMPARISONS AMONG COLUMNS WITHIN EACH SLICE');
          for k := 0 to NF3cells-1 do
          begin
               AReport.Add('');
               AReport.Add('SLICE %d COMPARISONS',[k+1]);
               // move cell sums and counts to cellsums and cellcnts
               for j := 0 to NF2cells-1 do
               begin
                    for i := 0 to NF1cells-1 do
                    begin
                         cellsums[j] := wsum[i,j,k];
                         cellcnts[j] := ncnt[i,j,k];
                         cellvars[j] := wx2[i,j,k];
                    end;
               end;
               value := 1e20;
               for j := 1 to NF2cells do if cellcnts[j] < value then value := cellcnts[j];
               if Scheffe.Checked then
                 ScheffeTest(MSErr, cellsums, cellcnts, minf2, maxf2, N, posthocAlpha, AReport);
               if TukeyHSD.Checked and equal_grp then
                  Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
               if TukeyB.Checked and equal_grp then
                 TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, value, posthocAlpha, AReport);
               if TukeyKramer.Checked and equal_grp then
                 Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
               if NewmanKeuls.Checked and equal_grp then
                 Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf2, maxf2, posthocAlpha, AReport);
               if Bonferoni.Checked then
                 Bonferroni(cellsums, cellcnts, cellvars, minf2, maxf2, posthocAlpha, AReport);
               if OrthoContrasts.Checked then
                 Contrasts(MSErr, DFErr, cellsums, cellcnts, minf2, maxf2, allAlpha, posthocAlpha, AReport);
          end;
     end;

     // do simple effects for rows within each slice
     if (ProbF1F3 < allAlpha) then
     begin
          AReport.Add('');
          AReport.Add('COMPARISONS AMONG ROWS WITHIN EACH SLICE');
          for k := 0 to NF3cells-1 do
          begin
               AReport.Add('');
               AReport.Add('SLICE %d COMPARISONS',[k+1]);
               // move cell sums and counts to cellsums and cellcnts
               for i := 0 to NF1cells-1 do
               begin
                    for j := 0 to NF2cells-1 do
                    begin
                         cellsums[j] := wsum[i,j,k];
                         cellcnts[j] := ncnt[i,j,k];
                         cellvars[j] := wx2[i,j,k];
                    end;
               end;
               value := 1e20;
               for i := 0 to NF1cells-1 do if cellcnts[i] < value then value := cellcnts[i];
               if Scheffe.Checked then
                 ScheffeTest(MSErr, cellsums, cellcnts, minf1, maxf1, N, posthocAlpha, AReport);
               if TukeyHSD.Checked and equal_grp then
                 Tukey(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
               if TukeyB.Checked and equal_grp then
                 TukeyBTest(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, value, posthocAlpha, AReport);
               if TukeyKramer.Checked and equal_grp then
                 Tukey_Kramer(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
               if NewmanKeuls.Checked and equal_grp then
                 Newman_Keuls(MSErr, DFErr, value, cellsums, cellcnts, minf1, maxf1, posthocAlpha, AReport);
               if Bonferoni.Checked then
                 Bonferroni(cellsums, cellcnts, cellvars, minf1, maxf1, posthocAlpha, AReport);
               if OrthoContrasts.Checked then
                 Contrasts(MSErr, DFErr, cellsums, cellcnts, minf1, maxf1, allAlpha, posthocAlpha, AReport);
          end;
     end;
     variances := nil
end;

//-------------------------------------------------------------------
procedure TBlksAnovaFrm.BrownForsytheOneWay(AReport: TStrings);
var
  i, intValue: integer;
  c1: array[1..50] of double;
  cellmeans: array[1..50] of double;
  sumc1: double;
  fdegfree: double;
  Fnumerator, Fdenominator, NewF: double;
  X, X2: Double;
begin
  for i := 1 to 50 do
  begin
    c1[i] := 0.0;
    cellmeans[i] := 0.0;
  end;

  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
//      X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepVarCol,i]));
    intvalue := intvalue - minf1;
    cellcnts[intvalue] := 0;
    cellsums[intvalue] := 0.0;
    cellvars[intvalue] := 0.0;
  end;

  MeanDep := 0.0;
  SSDep := 0.0;
  SSF1 := 0.0;
  MSErr := 0.0;
  N := 0;

  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepVarCol,i]));
    X2 := X*X;
    intvalue := intvalue - minf1;
    cellcnts[intvalue] := cellcnts[intvalue] + 1;
    cellsums[intvalue] := cellsums[intvalue] + X;
    cellvars[intvalue] := cellvars[intvalue] + X2;
    MeanDep := MeanDep + X;
    SSDep := SSDep + X2;
    N := N + 1;
  end;

  DFF1 := 0;
  for i := 0 to Nf1cells-1 do
  begin
    if cellcnts[i] > 0 then
    begin
      cellvars[i] := cellvars[i] - (cellsums[i] * cellsums[i] /cellcnts[i]);
      cellvars[i] := cellvars[i] / (cellcnts[i] - 1.0);
      SSF1 := SSF1 + (sqr(cellsums[i]) / cellcnts[i]);
      DFF1 := DFF1 + 1;
    end;
  end;

  SSF1 := SSF1 - (sqr(MeanDep) / N);
  SSDep := SSDep - (sqr(MeanDep) / N);
  SSErr := SSDep - SSF1;
  DFTot := N - 1;
  DFF1 := DFF1 - 1;
  DFErr := DFTot - DFF1;
  MSF1 := SSF1 / DFF1;
  MSErr := SSErr / DFErr;
  MSDep := SSDep / DFTot;
  Omega := (SSF1 - DFF1 * MSErr) / (SSDep + MSErr);
  F := MSF1 / MSErr;
  ProbF1 := probf(F,DFF1,DFErr);
  MeanDep := MeanDep / N;

  AReport.Add('');
  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('BROWN-FORSYTHE ONE WAY ANALYSIS OF VARIANCE RESULTS');
  AReport.Add('');
  AReport.Add('Dependent variable is: %s, Independent variable is: %s', [DepVar.Text, Factor1.Text]);
  AReport.Add('');
  AReport.Add('Traditional One-Way ANOVA Results');
  AReport.Add(DIVIDER_SMALL);
  AReport.Add('SOURCE    D.F.      SS        MS        F         PROB.>F   OMEGA SQR.');
  AReport.Add('-----------------------------------------------------------------------');
  AReport.Add('BETWEEN   %4.0f%10.2f%10.2f%10.2f%10.2f%10.2f', [DFF1, SSF1, MSF1, F, ProbF1, Omega]);
  AReport.Add('WITHIN    %4.0f%10.2f%10.2f', [DFErr, SSErr, MSErr]);
  AReport.Add('TOTAL     %4.0f%10.2f', [DFTot, SSDep]);
  AReport.Add(DIVIDER);

  sumc1 := 0.0;
  MSErr := 0.0;
  for i := 0 to Nf1cells-1 do
  begin
//     MSErr := MSErr + (((1.0 - cellcnts[i] / N) * cellvars[i]));
    c1[i+1] := (1.0 - (cellcnts[i] / N)) * cellvars[i];
    sumc1 := sumc1 + c1[i+1];
  end;
//   MSErr := MSErr / DFF1;
  for i := 1 to Nf1cells do
    c1[i] := c1[i] / sumc1;

  fdegfree := 0.0;
  for i := 1 to Nf1cells do
    fdegfree := fdegfree + ((c1[i] * c1[i]) / (cellcnts[i-1]-1.0));
  fdegfree := round(1.0 / fdegfree);

  Fnumerator := 0.0;
  Fdenominator := 0.0;
  for i := 1 to Nf1cells do
  begin
    cellmeans[i] := cellsums[i-1] / cellcnts[i-1];
    Fnumerator := Fnumerator + (cellcnts[i-1] * (sqr(cellmeans[i] - MeanDep)));
    Fdenominator := Fdenominator + ((1.0 - (cellcnts[i-1] / N)) * cellvars[i-1]);
  end;
  NewF := Fnumerator / Fdenominator;
  ProbF1 := probf(NewF,DFF1, fdegfree);

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('Brown-Forsythe F statistic:                    %8.3f', [NewF]);
  AReport.Add('Brown-Forsythe denominator degrees of freedom: %8.0f', [fdegfree]);
  AReport.Add('Brown-Forsythe F probability:                  %8.3f', [probf1]);
  AReport.Add(DIVIDER);

  {
  if Outputfrm = nil then
    OutputFrm := TOutputFrm.Create(Application)
  else
    OutputFrm.Clear;
  OutputFrm.AddLines(AReport);
  OutputFrm.ShowModal;
  }

  WelchtTests(AReport);
end;

procedure TBlksAnovaFrm.WelchOneWay(AReport: TStrings);
var
  i, intValue: integer;
  W, v, barx, numerator, denominator: double;
  wj: array[1..50] of double;
  c1: array[1..50] of double;
  barxj: array[1..50] of double;
  sumc1: double;
  fdegfree, term1, term2, term3: double;
  X, X2: Double;
begin
  for i := 1 to 50 do
  begin
    wj[i] := 0.0;
    c1[i] := 0.0;
    barxj[i] := 0.0;
  end;

  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
//    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepVarCol,i]));
    intvalue := intvalue - minf1;
    cellcnts[intvalue] := 0;
    cellsums[intvalue] := 0.0;
    cellvars[intvalue] := 0.0;
  end;

  MeanDep := 0.0;
  SSDep := 0.0;
  SSF1 := 0.0;
  MSErr := 0.0;
  N := 0;

  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepVarCol,i]));
    X2 := X*X;
    intvalue := intvalue - minf1;
    cellcnts[intvalue] := cellcnts[intvalue] + 1;
    cellsums[intvalue] := cellsums[intvalue] + X;
    cellvars[intvalue] := cellvars[intvalue] + X2;
    MeanDep := MeanDep + X;
    SSDep := SSDep + X2;
    barxj[intvalue+1] := barxj[intvalue+1] + X;
    N := N + 1;
  end;

  DFF1 := 0;
  W := 0.0;
  barx := 0.0;
  v := 0.0;

  for i := 0 to Nf1cells-1 do
  begin
    if cellcnts[i] > 0 then
    begin
      cellvars[i] := cellvars[i] - (cellsums[i] * cellsums[i] /cellcnts[i]);
      cellvars[i] := cellvars[i] / (cellcnts[i] - 1.0);
      wj[i+1] := cellcnts[i] / cellvars[i];
      W := W + wj[i+1];
      barxj[i+1] := barxj[i+1] / cellcnts[i];
      SSF1 := SSF1 + (sqr(cellsums[i]) / cellcnts[i]);
      DFF1 := DFF1 + 1;
    end;
  end;

  for i := 1 to Nf1cells do
    barx := barx + (wj[i] * barxj[i]);
  barx := barx / W;

  numerator := 0.0;
  for i := 1 to Nf1cells do
    numerator := numerator + (wj[i]* sqr(barxj[i]-barx));
  numerator := numerator / (Nf1cells - 1.0);

  denominator := 0.0;
  for i := 1 to Nf1cells do
    v := v + ( (1.0 /(cellcnts[i-1]-1.0)) * (sqr(1.0 - wj[i]/W)) );
  v := 3.0 * v;
  term1 := sqr(Nf1cells) - 1.0;
  v := term1 / v;
  for i := 1 to Nf1cells do
  begin
    term1 := 1.0 / (cellcnts[i-1] - 1.0);
    term2 := sqr(1.0 - (wj[i] / W));
    denominator := denominator + (term1 * term2);
  end;
  term1 := sqr(Nf1cells) - 1.0;
  term2 := 2.0 * (Nf1cells - 2.0);
  term3 := 1.0;
  denominator := term3 + ((term2 / term1) * denominator);

  F := numerator / denominator;
  DFF1 := Nf1cells - 1;
  SSF1 := SSF1 - (sqr(MeanDep) / float(N));
  SSDep := SSDep - (sqr(MeanDep) / float(N));
  SSErr := SSDep - SSF1;
  DFTot := N - 1;
  DFErr := DFTot - DFF1;
  MSF1 := SSF1 / DFF1;
  MeanDep := MeanDep / float(N);

  sumc1 := 0.0;
  for i := 0 to Nf1cells-1 do
  begin
    MSErr := MSErr + (((1.0 - cellcnts[i] / N) * cellvars[i])/ DFF1);
    c1[i+1] := (1.0 - (cellcnts[i] / N)) * cellvars[i];
    sumc1 := sumc1 + c1[i+1];
  end;

  for i := 1 to Nf1cells do
    c1[i] := c1[i] / sumc1;

  fdegfree := 0.0;
  for i := 1 to Nf1cells do
    fdegfree := fdegfree + (c1[i] * c1[i]) / (cellcnts[i-1]-1.0);
  fdegfree := round(1.0 / fdegfree);

  MSDep := SSDep / DFTot;
  Omega := (SSF1 - DFF1 * MSErr) / (SSDep + MSErr);
//     F := MSF1 / MSErr;
//     ProbF1 := probf(F,DFF1, DFErr);

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('WELCH ONE WAY ANALYSIS OF VARIANCE RESULTS');
  AReport.Add('');
  AReport.Add('Dependent variable is:   %s', [DepVar.Text]);
  AReport.Add('Independent variable is: %s', [Factor1.Text]);
  AReport.Add('');
{     OutputFrm.RichEdit.Lines.Add('---------------------------------------------------------------------');
     OutputFrm.RichEdit.Lines.Add('SOURCE    D.F.      SS        MS        F         PROB.>F   OMEGA SQR.');
     OutputFrm.RichEdit.Lines.Add('---------------------------------------------------------------------');
     outline :=            format('BETWEEN   %4.0f%10.2f%10.2f%10.2f%10.2f%10.2f',
          [DFF1,SSF1,MSF1,F,ProbF1,Omega]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline :=            format('WITHIN    %4.0f%10.2f%10.2f',[DFErr,SSErr,MSErr]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline :=            format('TOTAL     %4.0f%10.2f',[DFTot,SSDep]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('---------------------------------------------------------------------');
     OutputFrm.RichEdit.Lines.Add(''); }
  AReport.Add('Welch F statistic:                             %8.4f', [F]);
  AReport.Add('Welch denominator degrees of freedom:          %8.0f', [v]);

  probF1 := probf(F,DFF1,v);
  AReport.Add('Welch F probability:                           %8.3f', [probf1]);

  WelchtTests(AReport);
end;

procedure TBlksAnovaFrm.WelchtTests(AReport: TStrings);
var
  i, j, NoCompares: integer;
  t: double;   // Welch t value
  gnu: double; // degrees of freedom
  var1, var2: double; // variance estimates for two variables
  mean1, mean2: double; // means for two variables
  probability: double; // t probability
  numerator, denominator, term1, term2: double; // work values
  v: integer; // rounded degrees of freedom
begin
  NoCompares := Nf1cells;

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('WELCH T-TESTS AMONG GROUPS');
  AReport.Add(DIVIDER_SMALL);

  for i := 1 to NoCompares - 1 do
  begin
    for j := i + 1 to NoCompares do
    begin
      AReport.Add('Comparison of group %d with group %d', [i, j]);
      mean1 := cellsums[i-1] / cellcnts[i-1];
      mean2 := cellsums[j-1] / cellcnts[j-1];
      var1 := cellvars[i-1];
      var2 := cellvars[j-1];
      denominator := sqrt((var1 / cellcnts[i-1]) + (var2 / cellcnts[j-1]));
      numerator := mean1 - mean2;
      t := numerator / denominator;
      AReport.Add('Mean %d: %8.3f, Mean %d: %8.3f', [i, mean1, j, mean2]);
      AReport.Add('Welch t:                                       %8.3f' ,[t]);

      numerator := sqr((var1 /cellcnts[i-1]) + (var2 / cellcnts[j-1]));
      term1 := sqr(var1) / (sqr(cellcnts[i-1]) * (cellcnts[i-1]-1.0));
      term2 := sqr(var2) / (sqr(cellcnts[j-1]) * (cellcnts[j-1]-1.0));
      denominator := term1 + term2;
      numerator := sqr((var1 / cellcnts[i-1]) + (var2 / cellcnts[j-1]));
      gnu := numerator / denominator;
      AReport.Add('Ddegrees of freedom:                           %8.3f', [gnu]);

      v := round(gnu);
      AReport.Add('Rounded degrees of freedom:                    %8d', [v]);

      probability := probt(t,gnu);
      AReport.Add('Probability > t:                               %8.3f', [probability]);
      AReport.Add('');
    end;
  end;
end;

procedure TBlksAnovaFrm.UpdateBtnStates;
begin
  DepIn.Enabled := (VarList.ItemIndex > -1) and (DepVar.Text = '');
  DepOut.Enabled := DepVar.Text <> '';

  Fact1In.Enabled := (VarList.ItemIndex > -1) and (Factor1.Text = '');
  Fact1Out.Enabled := Factor1.Text <> '';

  Fact2In.Enabled := (VarList.ItemIndex > -1) and (Factor2.Text = '');
  Fact2Out.Enabled := Factor2.Text <> '';

  Fact3In.Enabled := (VarList.ItemIndex > -1) and (Factor3.Text = '');
  Fact3Out.Enabled := Factor3.Text <> '';
end;

procedure TBlksAnovaFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

function TBlksAnovaFrm.Validate(out AMsg: String; out AControl: TWinControl;
  DepVarIndex, Fact1Index, Fact2Index, Fact3Index: Integer): Boolean;
var
  a: Double;
begin
  Result := false;

  if (DepVarIndex = 0) then
  begin
    if DepVar.Text <> '' then
    begin
      AMsg := 'Dependent variable not found.';
      AControl := DepVar;
    end else
    begin
      AMsg := 'Dependent variable not specified.';
      AControl := VarList;
    end;
    exit;
  end;

  if (Fact1Index = 0) then
  begin
    if Factor1.Text <> '' then
    begin
      AMsg := 'Factor 1 variable not found';
      AControl := Factor1;
    end else
    begin
      Amsg := 'Factor 1 variable not specified.';
      AControl := VarList;
    end;
    exit;
  end;

  if (Fact2Index = 0) and (Factor2.Text <> '') then
  begin
    AMsg := 'Factor 2 variable not found.';
    AControl := Factor2;
    exit;
  end;

  if (Fact3Index = 0) and (Factor3.Text <> '') then
  begin
    AMsg := 'Factor3 variable not found.';
    AControl := Factor3;
    exit;
  end;

  if OverallAlpha.Text = '' then
  begin
    AMsg := 'Overall alpha level not specified.';
    AControl := OverallAlpha;
    exit;
  end;
  if not TryStrToFloat(OverallAlpha.Text, a) then
  begin
    AMsg := 'Overall alpha level is not a valid number.';
    AControl := OverallAlpha;
    exit;
  end;

  if PostAlpha.Text = '' then
  begin
    AMsg := 'Post-hoc alpha level not specified.';
    AControl := PostAlpha;
    exit;
  end;
  if not TryStrToFloat(PostAlpha.Text, a) then
  begin
    AMsg := 'Post-hoc alpha level is not a valid number.';
    AControl := PostAlpha;
    exit;
  end;

  Result := true;
end;


initialization
  {$I blkanovaunit.lrs}

end.

