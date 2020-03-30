// Use file "abranova.laz" for testing.

unit ABRANOVAUnit;

{$mode objfpc}{$H+}

interface

uses
  contexthelpunit, Classes, SysUtils, FileUtil, LResources, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, GraphLib, Globals, DataProcs, MatrixLib;

type

  { TABRAnovaFrm }

  TABRAnovaFrm = class(TForm)
    AInBtn: TBitBtn;
    AOutBtn: TBitBtn;
    Bevel1: TBevel;
    BInBtn: TBitBtn;
    BOutBtn: TBitBtn;
    CInBtn: TBitBtn;
    COutBtn: TBitBtn;
    ACodes: TEdit;
    BCodes: TEdit;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    TestChk: TCheckBox;
    PlotChk: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    CList: TListBox;
    VarList: TListBox;
    procedure ACodesChange(Sender: TObject);
    procedure AInBtnClick(Sender: TObject);
    procedure AOutBtnClick(Sender: TObject);
    procedure BInBtnClick(Sender: TObject);
    procedure BOutBtnClick(Sender: TObject);
    procedure CInBtnClick(Sender: TObject);
    procedure CListSelectionChange(Sender: TObject; User: boolean);
    procedure ComputeBtnClick(Sender: TObject);
    procedure COutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    ColNoSelected: IntDyneVec;
    ACol, BCol, NoSelected, MinA, MaxA, MinB, MaxB, NoAGrps, NoBGrps : integer;
    group, MaxRows, MaxCols, TotalN, NinGrp : integer;
    SubjTot, GrandTotal, SumXSqr : double;
    DFA, DFB, DFC, DFAB, DFAC, DFBC, DFABC, DFBetween : double;
    DFerrorBetween, DFWithin, DFerrorWithin : double;
    SSA, SSB, SSC, SSAB, SSAC, SSBC, SSABC, SSBetweenSubjects : double;
    SSerrorBetween, SSWithinSubjects, SSerrorWithin : double;
    MSA, MSB, MSC, MSAB, MSAC, MSBC, MSABC, MSerrorBetween, MSerrorWithin : double;
    FA, FB, FC, FAB, FAC, FBC, FABC : double;
    ProbA, ProbB, ProbC, ProbAB, ProbAC, ProbBC, ProbABC : double;
    Acnt, Bcnt, Ccnt : IntDyneVec;
    ASums, BSums, CSums, SumPSqr : DblDyneVec;
    ABSums, ACSums, BCSums, AMatrix, PooledMat : DblDyneMat;
    ABCSums : DblDyneCube;
    ABCNcnt : IntDyneCube;
    RowLabels, ColLabels : StrDyneVec;
    selected : integer;

    function InitData: Boolean;
    procedure GetData;
    procedure Calculate;
    procedure Summarize(AReport: TStrings);
    procedure MeansReport(AReport: TStrings);
    procedure BoxTests(AReport: TStrings);
    procedure GraphMeans;
    procedure CleanUp;
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  ABRAnovaFrm: TABRAnovaFrm;

implementation

uses
  Math;

{ TABRAnovaFrm }

procedure TABRAnovaFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Items.Clear;
  CList.Items.Clear;
  ACodes.Text := '';
  BCodes.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  PlotChk.Checked := false;
  TestChk.Checked := false;
  UpdateBtnStates;
end;

procedure TABRAnovaFrm.FormActivate(Sender: TObject);
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

  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TABRAnovaFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TABRAnovaFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TABRAnovaFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TABRAnovaFrm.ACodesChange(Sender: TObject);
begin
  UpdateBtnStates;
end;

procedure TABRAnovaFrm.AInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (ACodes.Text = '') then
  begin
    ACodes.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TABRAnovaFrm.AOutBtnClick(Sender: TObject);
begin
  if ACodes.Text <> '' then
  begin
    VarList.Items.Add(ACodes.Text);
    ACodes.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TABRAnovaFrm.BInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (BCodes.Text = '') then
  begin
    BCodes.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TABRAnovaFrm.BOutBtnClick(Sender: TObject);
begin
  if BCodes.Text <> '' then
  begin
    VarList.Items.Add(BCodes.Text);
    BCodes.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TABRAnovaFrm.CInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      CList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TABRAnovaFrm.ComputeBtnClick(Sender: TObject);
var
  lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
    if InitData then
    begin
      GetData;
      Calculate;
      Summarize(lReport);
      MeansReport(lReport);
      if TestChk.Checked then BoxTests(lReport);
      DisplayReport(lReport);
      if PlotChk.Checked then GraphMeans;
    end;
  finally
    lReport.Free;
    CleanUp;
  end;
end;

procedure TABRAnovaFrm.COutBtnClick(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while i < CList.Items.Count do
  begin
    if CList.Selected[i] then
    begin
      VarList.Items.Add(CList.Items[i]);
      CList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  VarList.ItemIndex := -1;
  CList.ItemIndex := -1;
  UpdateBtnStates;
end;

function TABRAnovaFrm.InitData: Boolean;
var
  cellstring: string;
  i, j, k: integer;
begin
  Result := false;

  SetLength(ColNoSelected,NoVariables);
  ACol := 0;
  BCol := 0;
  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = ACodes.Text) then ACol := i;
    if (cellstring = BCodes.Text) then BCol := i;
  end;
  if ( (ACol = 0) or (BCol = 0)) then
  begin
    MessageDlg('Select a variable for the A and B Variable Codes.', mtError, [mbOK], 0);
    exit;
  end;

  NoSelected := CList.Items.Count;
  MinA := 10000;
  MaxA := -10000;
  MinB := 10000;
  MaxB := -10000;
  for i := 1 to NoCases do
  begin
    if not ValidValue(i,ACol) then continue;
    cellstring := Trim(OS3MainFrm.DataGrid.Cells[ACol,i]);
    group := round(StrToFloat(cellstring));
    if (group > MaxA) then MaxA := group;
    if (group < MinA) then MinA := group;

    cellstring := Trim(OS3MainFrm.DataGrid.Cells[BCol,i]);
    if not ValidValue(i,BCol) then continue;
    group := round(StrToFLoat(cellstring));
    if (group > MaxB) then MaxB := group;
    if (group < MinB) then MinB := group;
  end;
  NoAGrps := MaxA - MinA + 1;
  NoBGrps := MaxB - MinB + 1;
  MaxRows := NoAGrps * NoBGrps;
  MaxCols := NoSelected;
  if (NoBGrps > NoSelected) then MaxCols := NoBGrps;
  if (MaxCols > MaxRows) then MaxRows := MaxCols;

  // allocate storage for arrays
  SetLength(ASums,NoAGrps);
  SetLength(Bsums,NoBGrps);
  SetLength(Csums,NoCases);
  SetLength(ABSums,NoAGrps,NoBGrps);
  SetLength(ACSums,NoAGrps,NoSelected);
  SetLength(BCSums,NoBGrps,NoSelected);
  SetLength(AMatrix,MaxRows,MaxRows);
  SetLength(SumPSqr,NoCases);
  SetLength(Acnt,NoAGrps);
  SetLength(Bcnt,NoBGrps);
  SetLength(Ccnt,MaxRows);
  SetLength(RowLabels,NoSelected);
  SetLength(ColLabels,NoSelected);
  SetLength(ABCSums,NoAGrps,NoBGrps,NoSelected);
  SetLength(ABCNcnt,NoAGrps,NoBGrps,NoSelected);

  // initialize arrays
  for i := 0 to NoAGrps-1 do
  begin
    ASums[i] := 0.0;
    Acnt[i] := 0;
    for j := 0 to NoBGrps-1 do
    begin
      ABSums[i,j] := 0.0;
      for k := 0 to NoSelected-1 do
      begin
        ABCSums[i,j,k] := 0.0;
        ABCNcnt[i,j,k] := 0;
      end;
    end;
    for j := 0 to NoSelected-1 do
    begin
      ACSums[i,j] := 0.0;
    end;
  end;
  for i := 0 to NoBGrps-1 do
  begin
    BSums[i] := 0.0;
    Bcnt[i] := 0;
    for j := 0 to NoSelected-1 do
    begin
      BCSums[i,j] := 0.0;
    end;
  end;
  for i := 0 to NoSelected-1 do
  begin
    CSums[i] := 0.0;
    Ccnt[i] := 0;
  end;
  for i := 0 to NoCases-1 do SumPSqr[i] := 0.0;
  GrandTotal := 0.0;
  TotalN := 0;
  SumXSqr := 0.0;

  Result := true;
end;

procedure TABRAnovaFrm.GetData;
var
  i, j, SubjA, SubjB: integer;
  cellstring: string;
  X: double;
begin
  for i := 0 to NoSelected - 1 do
  begin
    cellstring := CList.Items.Strings[i];
    for j := 1 to NoVariables do
      if (OS3MainFrm.DataGrid.Cells[j,0] = cellstring) then ColNoSelected[i] := j;
  end;

  ColNoSelected[NoSelected] := ACol;
  ColNoSelected[NoSelected+1] := BCol;
  selected := NoSelected + 2;

  // read data and store sums
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,selected,ColNoSelected) then continue;
    SubjA := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ACol,i])));
    SubjA := SubjA - MinA + 1;
    SubjB := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[BCol,i])));
    SubjB := SubjB - MinB + 1;
    SubjTot := 0.0;
    for j := 1 to NoSelected do
    begin
      X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ColNoSelected[j-1],i]));
      SubjTot := SubjTot + X;
      SumXSqr := SumXSqr + (X * X);
      ABCSums[SubjA-1,SubjB-1,j-1] := ABCSums[SubjA-1,SubjB-1,j-1] + X;
      ABCNcnt[SubjA-1,SubjB-1,j-1] := ABCNcnt[SubjA-1,SubjB-1,j-1] + 1;
      Acnt[SubjA-1] := Acnt[SubjA-1] + 1;
      Bcnt[SubjB-1] := Bcnt[SubjB-1] + 1;
      Ccnt[j-1] := Ccnt[j-1] + 1;
      TotalN := TotalN + 1;
    end;
    SumPSqr[i-1] := SumPSqr[i-1] + (SubjTot * SubjTot);
    GrandTotal := GrandTotal + SubjTot;
    NinGrp := ABCNcnt[0,0,0];
  end;
end;

procedure TABRAnovaFrm.Calculate;
var
   SumA, SumB, SumC, SumAB, SumAC, SumBC, SumABC : double;
   Term1, Term2, Term3, Term4, Term5, Term6, Term7, Term8, Term9, Term10 : double;
   i, j, k, CountA, CountB, CountC: integer;
begin
    Term1 := (GrandTotal * GrandTotal) / TotalN;
    Term2 := SumXSqr;
    Term3 := 0.0;
    countA := 0;
    for i := 1 to NoAGrps do
    begin
        SumA := 0.0;
        countA := countA + Acnt[i-1];
        for j := 1 to NoBGrps do
            for k := 1 to NoSelected do SumA := SumA + ABCSums[i-1,j-1,k-1];
        ASums[i-1] := ASums[i-1] + SumA;
        Term3 := Term3 + (SumA * SumA);
    end;
    Term3 := Term3 / (NinGrp * NoBGrps * NoSelected);

    Term4 := 0;
    countB := 0;
    for j := 1 to NoBGrps do
    begin
        SumB := 0.0;
        CountB := CountB + Bcnt[j-1];
        for i := 1 to NoAGrps do
            for k := 1 to NoSelected do SumB := SumB + ABCSums[i-1,j-1,k-1];
        BSums[j-1] := BSums[j-1] + SumB;
        Term4 := Term4 + (SumB * SumB);
    end;
    Term4 := Term4 / (NinGrp * NoAGrps * NoSelected);

    Term5 := 0.0;
    countC := 0;
    for k := 1 to NoSelected do
    begin
        SumC := 0.0;
        CountC := CountC + Ccnt[k-1];
        for i := 1 to NoAGrps do
            for j := 1 to NoBGrps do SumC := SumC + ABCSums[i-1,j-1,k-1];
        CSums[k-1] := CSums[k-1] + SumC;
        Term5 := Term5 + (SumC * SumC);
    end;
    Term5 := Term5 / (NinGrp * NoAGrps * NoBGrps);


    Term6 := 0.0;
    for i := 1 to NoAGrps do
    begin
        for j := 1 to NoBGrps do
        begin
            SumAB := 0.0;
            //CountAB := CountAB + ABcnt^[i,j];
            for k := 1 to NoSelected do SumAB := SumAB + ABCSums[i-1,j-1,k-1];
            ABSums[i-1,j-1] := ABSums[i-1,j-1] + SumAB;
            Term6 := Term6 + (SumAB * SumAB);
        end;
    end;
    Term6 := Term6 / (NinGrp * NoSelected);

    Term7 := 0.0;
    for i := 1 to NoAGrps do
    begin
        for k := 1 to NoSelected do
        begin
            SumAC := 0.0;
            for j := 1 to NoBGrps do SumAC := SumAC + ABCSums[i-1,j-1,k-1];
            ACSums[i-1,k-1] := ACSums[i-1,k-1] + SumAC;
            Term7 := Term7 + (SumAC * SumAC);
        end;
    end;
    Term7  := Term7 / (NinGrp * NoBGrps);

    Term8 := 0.0;
    for j := 1 to NoBGrps do
    begin
        for k := 1 to NoSelected do
        begin
            SumBC := 0.0;
            for i := 1 to NoAGrps do SumBC := SumBC + ABCSums[i-1,j-1,k-1];
            BCSums[j-1,k-1] := BCSums[j-1,k-1] + SumBC;
            Term8 := Term8 + (SumBC * SumBC);
        end;
    end;
    Term8 := Term8 / (NinGrp * NoAGrps);

    Term9 := 0.0;
    for i := 1 to NoAGrps do
    begin
        for j := 1 to NoBGrps do
        begin
            for k := 1 to NoSelected do
            begin
                SumABC := ABCSums[i-1,j-1,k-1];
                //CountABC := CountABC + ABCNcnt[i,j,k];
                Term9 := Term9 + (SumABC * SumABC);
            end;
        end;
    end;
    Term9 := Term9 / NinGrp;

    Term10 := 0.0;
    for i := 1 to NoCases do Term10 := Term10 + SumPSqr[i-1];
    Term10 := Term10 / NoSelected;

    //Get DF, SS, MS, F and Probabilities
    DFBetween := (NinGrp * NoAGrps * NoBGrps) - 1.0;
    DFA := NoAGrps - 1.0;
    DFB := NoBGrps - 1.0;
    DFAB := (NoAGrps - 1.0) * (NoBGrps - 1.0);
    DFerrorBetween := (NoAGrps * NoBGrps) * (NinGrp - 1.0);
    DFWithin := (NinGrp * NoAGrps * NoBGrps) * (NoSelected - 1.0);
    DFC := NoSelected - 1.0;
    DFAC := (NoAGrps - 1.0) * (NoSelected - 1.0);
    DFBC := (NoBGrps - 1.0) * (NoSelected - 1.0);
    DFABC := (NoAGrps - 1.0) * (NoBGrps - 1.0) * (NoSelected - 1.0);
    DFerrorWithin := NoAGrps * NoBGrps * (NinGrp - 1.0) * (NoSelected - 1.0);
    SSBetweenSubjects := Term10 - Term1;
    SSA := Term3 - Term1;
    SSB := Term4 - Term1;
    SSAB := Term6 - Term3 - Term4 + Term1;
    SSerrorBetween := Term10 - Term6;
    SSWithinSubjects := Term2 - Term10;
    SSC := Term5 - Term1;
    SSAC := Term7 - Term3 - Term5 + Term1;
    SSBC := Term8 - Term4 - Term5 + Term1;
    SSABC := Term9 - Term6 - Term7 - Term8 + Term3 + Term4 + Term5 - Term1;
    SSerrorWithin := Term2 - Term9 - Term10 + Term6;
    MSA := SSA / DFA;
    MSB := SSB / DFB;
    MSAB := SSAB / DFAB;
    MSerrorBetween := SSerrorBetween / DFerrorBetween;
    MSC := SSC / DFC;
    MSAC := SSAC / DFAC;
    MSBC := SSBC / DFBC;
    MSABC := SSABC / DFABC;
    MSerrorWithin := SSerrorWithin / DFerrorWithin;
    FA := MSA / MSerrorBetween;
    FB := MSB / MSerrorBetween;
    FAB := MSAB / MSerrorBetween;
    FC := MSC / MSerrorWithin;
    FAC := MSAC / MSerrorWithin;
    FBC := MSBC / MSerrorWithin;
    FABC := MSABC / MSerrorWithin;
    ProbA := probf(FA,DFA,DFerrorBetween);
    ProbB := probf(FB,DFB,DFerrorBetween);
    ProbAB := probf(FAB,DFAB,DFerrorBetween);
    ProbC := probf(FC,DFC,DFerrorWithin);
    ProbAC := probf(FAC,DFAC,DFerrorWithin);
    ProbBC := probf(FBC,DFBC,DFerrorWithin);
    ProbABC := probf(FABC,DFABC,DFerrorWithin);
end;

procedure TABRAnovaFrm.Summarize(AReport: TStrings);
begin
    AReport.Add('SOURCE              DF       SS        MS        F         PROB.');
    AReport.Add('');
    AReport.Add('Between Subjects  %5.0f%10.3f',[DFBetween,SSBetweenSubjects]);
    AReport.Add('   A Effects      %5.0f%10.3f%10.3f%10.3f%10.3f', [DFA, SSA, MSA, FA, ProbA]);
    AReport.Add('   B Effects      %5.0f%10.3f%10.3f%10.3f%10.3f', [DFB, SSB, MSB, FB, ProbB]);
    AReport.Add('   AB Effects     %5.0f%10.3f%10.3f%10.3f%10.3f', [DFAB, SSAB, MSAB, FAB, ProbAB]);
    AReport.Add('   Error Between  %5.0f%10.3f%10.3f', [DFerrorBetween,SSerrorBetween,MSerrorBetween]);
    AReport.Add('');
    AReport.Add('Within Subjects   %5.0f%10.3f', [DFWithin,SSWithinSubjects]);
    AReport.Add('   C Replications %5.0f%10.3f%10.3f%10.3f%10.3f', [DFC, SSC, MSC, FC, ProbC]);
    AReport.Add('   AC Effects     %5.0f%10.3f%10.3f%10.3f%10.3f', [DFAC, SSAC, MSAC, FAC, ProbAC]);
    AReport.Add('   BC Effects     %5.0f%10.3f%10.3f%10.3f%10.3f', [DFBC, SSBC, MSBC, FBC, ProbBC]);
    AReport.Add('   ABC Effects    %5.0f%10.3f%10.3f%10.3f%10.3f', [DFABC, SSABC, MSABC, FABC, ProbABC]);
    AReport.Add('   Error Within   %5.0f%10.3f%10.3f', [DFerrorWithin, SSerrorWithin, MSerrorWithin]);
    AReport.Add('');
    AReport.Add('Total             %5.0f%10.3f', [DFBetween + DFWithin, SSBetweenSubjects + SSWithinSubjects]);
    AReport.Add('');
//    OutputFrm.ShowModal;
end;

procedure TABRAnovaFrm.MeansReport(AReport: TStrings);
var
  ColHeader, LabelStr: string;
  Title: string;
  i, j, k, row: integer;
begin
  row := 1;
  //OutputFrm.Clear;
  Title := 'ABR Means Table';
  ColHeader := 'Repeated Measures';
  for i := 1 to NoAGrps do
  begin
    for j := 1 to NoBGrps do
    begin
      LabelStr := format('A%d B%d',[i,j]);
      RowLabels[row-1] := LabelStr;
      for k := 1 to NoSelected do
      begin
        AMatrix[row-1,k-1] := ABCSums[i-1,j-1,k-1] / NinGrp;
        ColLabels[k-1] := OS3MainFrm.DataGrid.Cells[ColNoSelected[k-1],0];
      end;
      inc(row);
    end;
  end;
  MatPrint(AMatrix,MaxRows,NoSelected,Title,RowLabels,ColLabels,NinGrp, AReport);

  Title := 'AB Means Table';
  ColHeader := 'B Levels';
  for i := 1 to NoAGrps do
  begin
    LabelStr := format('A%d',[i]);
    RowLabels[i-1] := LabelStr;
    for j := 1 to NoBGrps do
      AMatrix[i-1,j-1] := ABSums[i-1,j-1] / (NinGrp * NoSelected);
  end;
  for j := 1 to NoBGrps do
  begin
    LabelStr := format('B %d',[j]);
    ColLabels[j-1] := LabelStr;
  end;
  MatPrint(AMatrix,NoAgrps,NoBgrps,Title,RowLabels,ColLabels,NinGrp*NoSelected, AReport);

  Title := 'AC Means Table';
  ColHeader := 'C Levels';
  for i := 1 to NoAGrps do
  begin
    LabelStr := format('A%d',[i-1]);
    RowLabels[i-1] := LabelStr;
    for j := 1 to NoSelected do
      AMatrix[i-1,j-1] := ACSums[i-1,j-1] / (NinGrp * NoBGrps);
  end;
  for j := 1 to NoSelected do
  begin
    LabelStr := format('C%d',[j-1]);
    ColLabels[j-1] := LabelStr;
  end;
  MatPrint(AMatrix,NoAGrps,NoSelected,Title,RowLabels,ColLabels,NinGrp*NoBGrps, AReport);

  Title := 'BC Means Table';
  ColHeader := 'C Levels';
  for i := 1 to NoBGrps do
  begin
    LabelStr := format('B%d',[i]);
    RowLabels[i-1] := LabelStr;
    for j := 1 to NoSelected do
      AMatrix[i-1,j-1] := BCSums[i-1,j-1] / (NinGrp * NoAGrps);
  end;
  for j := 1 to NoSelected do
  begin
    LabelStr := format('C%d',[j]);
    ColLabels[j-1] := LabelStr;
  end;
  MatPrint(AMatrix,NoBGrps,NoSelected,Title,RowLabels,ColLabels,NinGrp*NoAGrps, AReport);

//  OutputFrm.ShowModal;
end;

procedure TABRAnovaFrm.BoxTests(AReport: TStrings);
const
  EPS = 1E-35;
var
  XVector, XSums : DblDyneVec;
  DetMat, MeanCovMat : DblDyneMat;
  M1, M2, Sum1, C1, C2, f1, f2, chi, ProbChi, X, avgvar,avgcov : double;
  ColHeader, LabelStr : string;
  Title : string;
  i, j, k, l, row, SubjA, SubjB, N, p, quad : integer;
  errorcode : boolean = false;  // to silence the compiler
  Det: Double = 0.0;
begin
  SetLength(XVector,NoSelected);
  SetLength(XSums,NoSelected);
  SetLength(DetMat,NoSelected+1,NoSelected+1);
  SetLength(MeanCovMat,NoSelected+1,NoSelected+1);
  SetLength(PooledMat,NoSelected+1,NoSelected+1);

  for i := 1 to NoSelected do
  begin
    LabelStr := format('C%d',[i]);
    RowLabels[i-1] := LabelStr;
    ColLabels[i-1] := LabelStr;
    for j := 1 to NoSelected do PooledMat[i-1,j-1] := 0.0;
  end;

  // get variance-covariance AMatrix for the repeated measures within
  // each combination of A and B levels.  Pool them for the pooled
  // covariance AMatrix.  Get Determinants of each AMatrix.
  //OutputFrm.Clear;
  Sum1 := 0.0;
  for i := 1 to NoAGrps do
  begin
    for j := 1 to NoBGrps do
    begin
      LabelStr := format('Variance-Covariance AMatrix for A%d B%d', [i,j]);
      Title := LabelStr;
      ColHeader := 'C Levels';

      // initialize AMatrix for this combination
      for k := 1 to NoSelected do
      begin
        for l := 1 to NoSelected do AMatrix[k-1,0] := 0.0;
        XSums[k-1] := 0.0;
      end;

      // read data and add to covariances
      for row := 1 to NoCases do
      begin
        if not GoodRecord(row,selected,ColNoSelected) then
          continue;
        SubjA := round(StrToFLoat(Trim(OS3MainFrm.DataGrid.Cells[ACol,row])));
        SubjA  := SubjA - MinA + 1;
        SubjB := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[BCol,row])));
        SubjB := SubjB - MinB + 1;
        if ((SubjA <> i)or(SubjB <> j)) then
          continue;
        for k := 1 to NoSelected do
        begin
          X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ColNoSelected[k-1],row]));
          XVector[k-1] := X;
          XSums[k-1] := XSums[k-1] + X;
        end;
        for k := 1 to NoSelected do
        begin
          for l := 1 to NoSelected do
            AMatrix[k-1,l-1] := AMatrix[k-1,l-1] + (XVector[k-1] * XVector[l-1]);
        end;
      end; // next case

      // convert sums of cross-products to variance-covariance
      for k := 1 to NoSelected do
      begin
        for l := 1 to NoSelected do
        begin
          AMatrix[k-1,l-1] := AMatrix[k-1,l-1] - (XSums[k-1]*XSums[l-1] / NinGrp);
          AMatrix[k-1,l-1] := AMatrix[k-1,l-1] / (NinGrp - 1);
          PooledMat[k-1,l-1] := PooledMat[k-1,l-1] + AMatrix[k-1,l-1];
        end;
      end;

      MatPrint(AMatrix,NoSelected,NoSelected,Title,RowLabels,ColLabels,NoCases, AReport);

      for k := 1 to NoSelected do
        for l := 1 to NoSelected do
          DetMat[k-1,l-1] := AMatrix[k-1,l-1];
      Determ(DetMat,NoSelected, NoSelected, Det, errorcode);
      //  if (Det > 0.0e35) then   // wp: What's this???
      if Det > EPS then
        Sum1 := sum1 + (NinGrp * ln(Det))
      else
        MessageDlg('Determinant of a covariance AMatrix <= 0.', mtWarning, [mbOK], 0);
    end;// next B level
  end; // next A level

  // get pooled variance-covariance
  for i := 1 to NoSelected do
    for j := 1 to NoSelected do
      PooledMat[i-1,j-1] := PooledMat[i-1,j-1] / (NoAGrps * NoBGrps);

  Title := 'Pooled Variance-Covariance AMatrix';
  MatPrint(PooledMat,NoSelected,NoSelected,Title,RowLabels,ColLabels,NoCases, AReport);

  // calculate F-Max for variance homogeneity

  // calculate Box test for covariance homogeneity
  for i := 1 to NoSelected do
    for j := 1 to NoSelected do
      DetMat[i-1,j-1] := PooledMat[i-1,j-1];
  Determ(DetMat,NoSelected,NoSelected,Det,errorcode);
  //if (Det > 0.0e35) then
  if (Det > EPS) then
  begin
    M1 := (NinGrp*NoAGrps*NoBGrps * ln(Det)) - Sum1;
    C1 := (2.0 * NoSelected * NoSelected + 3.0 * NoSelected - 1.0) /
          (6.0 * (NoSelected+1) * (NoAGrps * NoBGrps - 1.0));
    C1 := C1 * ( (NoAGrps * NoBGrps * (1.0 / NinGrp)) - (1.0 / (NinGrp * NoAGrps * NoBGrps)));
    f1 := (NoSelected * (NoSelected + 1.0) * (NoAGrps * NoBGrps - 1.0))/2.0;
    chi := (1.0 - C1) * M1;
    ProbChi := 1.0 - chisquaredprob(chi,round(f1));
    AReport.Add('Test that sample covariances are from same population:');
    AReport.Add('');
    AReport.Add('Chi-Squared = %0.3f with %d degrees of freedom.', [chi,round(f1)]);
    AReport.Add('Probability of > Chi-Squared = %0.3f', [ProbChi]);
    AReport.Add('');
    AReport.Add('');
  end else
    MessageDlg('Determinant of a pooled covariance AMatrix near 0.', mtError, [mbOK], 0);

  // test that pooled covariance has form of equal variances and equal covariances
  //if (Det > 0.0e35) then // determinant of pooled covariance > 0
  if (Det > EPS) then
  begin
    M2 := Det;
    avgvar := 0.0;
    for i := 1 to NoSelected do
      avgvar := avgvar + PooledMat[i-1,i-1];
    avgvar := avgvar / NoSelected;
    avgcov := 0.0;
    for i := 1 to NoSelected-1 do
      for j := i+1 to NoSelected do
        avgcov := avgcov + PooledMat[i-1,j-1];
    avgcov := avgcov / (NoSelected * (NoSelected - 1) / 2);
    for i := 1 to NoSelected do
      DetMat[i-1,i-1] := avgvar;
    for i := 1 to NoSelected-1 do
    begin
      for j := i+1 to NoSelected do
      begin
        DetMat[i-1,j-1] := avgcov;
        DetMat[j-1,i-1] := avgcov;
      end;
    end;
    Determ(DetMat,NoSelected,NoSelected,Det,errorcode);
//        if (Det > 0.0e35) then
    if (Det > EPS) then
    begin
      N := NoAGrps * NoBGrps * NinGrp;
      p := NoAGrps * NoBGrps;
      quad := NoSelected * NoSelected + NoSelected - 4;
      M2 := ln(M2 / Det);
      M2 := -(N - p) * M2;
      C2 := NoSelected * (NoSelected + 1) * (NoSelected + 1) * (2 * NoSelected - 3);
      C2 := C2 / (6 * (N - p) * (NoSelected - 1) * quad);
      f2 := quad / 2;
      chi := (1.0 - C2) * M2;
      ProbChi := 1.0 - chisquaredprob(chi,round(f2));
      AReport.Add('Test that variance-covariances AMatrix has equal variances and equal covariances:');
      AReport.Add('');
      AReport.Add('Chi-Squared := %0.3f with %d degrees of freedom.', [chi, round(f2)]);
      AReport.Add('Probability of > Chi-Squared := %.3f', [ProbChi]);
      AReport.Add('');
    end else
      MessageDlg('Determinant of theoretical covariance AMatrix near zero.', mtWarning, [mbOK], 0);
  end;
//  OutputFrm.ShowModal;

  // cleanup
  PooledMat := nil;
  MeanCovMat := nil;
  DetMat := nil;
  XSums := nil;
  XVector := nil;
end;

procedure TABRAnovaFrm.GraphMeans;
var
   MaxMean : double;
   i, j : integer;
begin
    // Do AB interaction
    // Get maximum cell mean
    MaxMean := ABSums[0,0] / (NinGrp*NoSelected);
    SetLength(GraphFrm.Ypoints,NoAGrps,NoBGrps);
    SetLength(GraphFrm.Xpoints,1,NoBGrps);
    for i := 1 to NoAGrps do
    begin
         GraphFrm.SetLabels[i] := 'A ' + IntToStr(i);
         for j := 1 to NoBGrps do
         begin
              GraphFrm.Ypoints[i-1,j-1] := ABSums[i-1,j-1] / (NinGrp * NoSelected);
              if GraphFrm.Ypoints[i-1,j-1] > MaxMean then MaxMean := GraphFrm.Ypoints[i-1,j-1];
         end;
    end;
    for j := 1 to NoBGrps do
    begin
        GraphFrm.Xpoints[0,j-1] := j;
    end;

    GraphFrm.nosets := NoAGrps;
    GraphFrm.nbars := NoBGrps;
    GraphFrm.Heading := 'AxBxR ANOVA';
    GraphFrm.XTitle := 'B TREATMENT GROUP';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := false;
    GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.BackColor := clCream;
    GraphFrm.WallColor := clDkGray;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;

    // Do AC interaction
    MaxMean := ACSums[0,0] / (NinGrp*NoBGrps);
    SetLength(GraphFrm.Ypoints,NoAGrps,NoSelected);
    SetLength(GraphFrm.Xpoints,1,NoSelected);
    for i := 1 to NoAGrps do
    begin
         GraphFrm.SetLabels[i] := 'A ' + IntToStr(i);
         for j := 1 to NoSelected do
         begin
              GraphFrm.Ypoints[i-1,j-1] := ACSums[i-1,j-1] / (NinGrp * NoBGrps);
              if GraphFrm.Ypoints[i-1,j-1] > MaxMean then MaxMean := GraphFrm.Ypoints[i-1,j-1];
         end;
    end;
    for j := 1 to NoSelected do
    begin
        GraphFrm.Xpoints[0,j-1] := j;
    end;
    GraphFrm.nosets := NoAGrps;
    GraphFrm.nbars := NoSelected;
    GraphFrm.Heading := 'AxBxR ANOVA';
    GraphFrm.XTitle := 'C TREATMENT (WITHIN SUBJECTS) GROUP';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := false;
    GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.BackColor := clCream;
    GraphFrm.WallColor := clDkGray;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;

    // Do BC interaction
    SetLength(GraphFrm.Ypoints,NoBGrps,NoSelected);
    SetLength(GraphFrm.Xpoints,NoSelected);
    MaxMean := BCSums[0,0] / (NinGrp*NoAGrps);
    for i := 1 to NoBGrps do
        for j := 1 to NoSelected do
            if ((BCSums[i-1,j-1] / (NinGrp*NoAGrps)) > MaxMean) then
                MaxMean := BCSums[i-1,j-1] / (NinGrp*NoAGrps);
    for i := 1 to NoBGrps do
    begin
         GraphFrm.SetLabels[i] := 'B ' + IntToStr(i);
         for j := 1 to NoSelected do
         begin
              GraphFrm.Ypoints[i-1,j-1] := BCSums[i-1,j-1] / (NinGrp * NoAGrps);
              if GraphFrm.Ypoints[i-1,j-1] > MaxMean then MaxMean := GraphFrm.Ypoints[i-1,j-1];
         end;
    end;
    for j := 1 to NoSelected do
    begin
        GraphFrm.Xpoints[0,j-1] := j;
    end;
    GraphFrm.nosets := NoBGrps;
    GraphFrm.nbars := NoSelected;
    GraphFrm.Heading := 'AxBxR ANOVA';
    GraphFrm.XTitle := 'C TREATMENT (WITHIN SUBJECTS) GROUP';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := false;
    GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.BackColor := clCream;
    GraphFrm.WallColor := clDkGray;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;
    // cleanup the heap
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;

procedure TABRAnovaFrm.CleanUp;
begin
  ABCNcnt := nil;
  ABCSums := nil;
  ColLabels := nil;
  RowLabels := nil;
  Ccnt := nil;
  Bcnt := nil;
  Acnt := nil;
  SumPSqr := nil;
  AMatrix := nil;
  BCSums := nil;
  ACSums := nil;
  ABSums := nil;
  CSums := nil;
  BSums := nil;
  ASums := nil;
  ColNoSelected := nil;
end;

procedure TABRAnovaFrm.CListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TABRAnovaFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  AInBtn.Enabled := (VarList.ItemIndex > -1) and (ACodes.Text = '');
  AOutBtn.Enabled := (ACodes.Text <> '');

  BInBtn.Enabled := (VarList.ItemIndex > -1) and (BCodes.Text = '');
  BOutBtn.Enabled := (BCodes.Text <> '');

  lSelected := false;
  for i := 0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  CInBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to CList.Items.Count-1 do
    if CList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  COutBtn.Enabled := lSelected;
end;

initialization
  {$I abranovaunit.lrs}

end.

