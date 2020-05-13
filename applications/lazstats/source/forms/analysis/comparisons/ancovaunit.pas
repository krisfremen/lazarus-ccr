// Use file "ancova.laz" for testing.
//   Y --> Dependent Variable
//   Group --> Fixed Factors
//   X, Z ---> Covariables

unit ANCOVAUnit;

{$mode objfpc}{$H+}
{.$DEFINE ANCOVA_DEBUG}

interface

uses
  {$IFDEF ANCOVA_DEBUG}
  LazLogger,
  {$ENDIF}
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, GraphLib,
  Globals, DataProcs, MatrixLib, DictionaryUnit, ContextHelpUnit;

type

  { TANCOVAfrm }

  TANCOVAfrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    HelpBtn: TButton;
    MultCompChk: TCheckBox;
    Panel1: TPanel;
    Panel2: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    PlotMeans: TCheckBox;
    PrintInverseMat: TCheckBox;
    CorrelationMats: TCheckBox;
    DescriptiveStats: TCheckBox;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    FixedIn: TBitBtn;
    FixedOut: TBitBtn;
    CovIn: TBitBtn;
    CovOut: TBitBtn;
    DepVar: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    FixedList: TListBox;
    Label4: TLabel;
    CovList: TListBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure CovInClick(Sender: TObject);
    procedure CovOutClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure FixedInClick(Sender: TObject);
    procedure FixedOutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    NCases, NoSelected, NoFixed, NoCovs, DepColNo : integer;
    ColNoSelected : IntDyneVec; // Grid col. no's of predictors
    RowLabels, ColLabels : StrDyneVec;
    CorMat : DblDyneMat; // correlation matrix
    IndMat : DblDyneMat; // correlation matrix among independent variables
    BetaWeights : DblDyneVec; // standardized regression weights
    Means, Variances, StdDevs : DblDyneVec;
    PrintIt : boolean; // true to print correlations in reg procedure
    probout : double; // probability for removing a variable
    Testout : boolean; // true if testing for retention of variables
    plot : boolean; // if true, plot group means
    StdErrEst : double; // standard error of estimate
    multcomp : boolean; // if true make multiple comparisons
    R2 : double; // squared multiple correlation coefficient
    FixedCols : IntDyneVec; // grid columns of fixed variables
    CovCols : IntDyneVec; // grid columns of covariates
    mingrp, maxgrp : IntDyneVec; // min and max group codes
    Block : IntDyneMat; // descriptors for group codings
    // values 1 to 5 contain group min, max, startcol, endcol and no. of vectors
    NoBlocks : integer; // number of vector blocks created for groups and inter.
    errorcode : boolean; // returned by routines that use an errorcode
    IndepIndex : IntDyneVec; // sequential number of predictors in corr. matrix
    BlockLabel : StrDyneVec;
    NoTestVecs : integer; // no. of vectors for group interactions with covariates
    constant : double; // regression constant
    noind : integer; // no. of independent variables in a regression analysis
    BWeights : DblDyneVec; // raw regression weights
//    BStdErrs : DblDyneVec; // standard errors of regression weights
//    BTtests : DblDyneVec;

    procedure GetParms;
    procedure CodeGroups;
    procedure GenInteractions;
    procedure DoRegs(AReport: TStrings);
    procedure CleanUp;
    procedure EntryOpt1(AReport: TStrings);
    procedure GenCovInteracts;
    procedure AdjustMeans(AReport: TStrings);
    procedure MultCompare(AReport: TStrings);

    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  ANCOVAfrm: TANCOVAfrm;

implementation

uses
  Math;

{ TANCOVAfrm }

procedure TANCOVAfrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  DepVar.Text := '';
  VarList.Clear;
  CovList.Clear;
  FixedList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  DescriptiveStats.Checked := false;
  CorrelationMats.Checked := false;
  PrintInverseMat.Checked := false;
  PlotMeans.Checked := false;
  NoBlocks := 0;
  UpdateBtnStates;
end;

procedure TANCOVAfrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TANCOVAfrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TANCOVAfrm.DepInClick(Sender: TObject);
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

procedure TANCOVAfrm.CovInClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      CovList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TANCOVAfrm.ComputeBtnClick(Sender: TObject);
var
  lReport: TStrings;
begin
  if DepVar.Text = '' then
  begin
    MessageDlg('No dependent variable selected.', mtError, [mbOK], 0);
    exit;
  end;

  NoFixed := FixedList.Items.Count;
  NoCovs := CovList.Items.Count;
  if (NoFixed <= 0) or (NoCovs <= 0) then
  begin
    MessageDlg('You must have at least one group variable and one covariate', mtError, [mbOK], 0);
    exit;
  end;

  lReport := TStringList.Create;
  try
    GetParms;
    CodeGroups;
    GenInteractions;
    GenCovInteracts;
    DoRegs(lReport);
    DisplayReport(lReport);
  finally
    CleanUp;
    lReport.Free;
  end;
end;

procedure TANCOVAfrm.CovOutClick(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while i < CovList.Items.Count do
  begin
    if CovList.Selected[i] then
    begin
      Varlist.Items.Add(CovList.Items[i]);
      CovList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TANCOVAfrm.DepOutClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TANCOVAfrm.FixedInClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      FixedList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TANCOVAfrm.FixedOutClick(Sender: TObject);
var
  i : integer;
begin
  i := 0;
  while i < FixedList.Items.Count do
  begin
    if FixedList.Selected[i] then
    begin
      VarList.Items.Add(FixedList.Items[i]);
      FixedList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TANCOVAfrm.FormActivate(Sender: TObject);
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

procedure TANCOVAfrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TANCOVAfrm.GetParms;
var
  i, j: integer;
begin
  SetLength(ColNoSelected, NoVariables);
  SetLength(FixedCols, NoFixed);
  SetLength(CovCols, NoCovs);
  SetLength(mingrp, NoFixed);
  SetLength(maxgrp, NoFixed);
  SetLength(Block, 100, 5);
  SetLength(BlockLabel, 100);

  NoSelected := 0;
  NoBlocks := 0;
  plot := PlotMeans.Checked;
  multcomp := MultCompChk.Checked;

  for i := 1 to NoVariables do
  begin
    if DepVar.Text = OS3MainFrm.DataGrid.Cells[i,0] then
    begin
      DepColNo := i;
      ColNoSelected[0] := i;
      NoSelected := 1;
      break;
    end;
  end;

  for i := 0 to NoFixed - 1 do
  begin
    for j := 1 to NoVariables do
    begin
      if FixedList.Items.Strings[i] = OS3MainFrm.DataGrid.Cells[j,0] then
      begin
        FixedCols[i] := j;
        ColNoSelected[NoSelected] := j;
        NoSelected := NoSelected + 1;
        break;
      end;
    end;
  end;

  for i := 0 to NoCovs - 1 do
  begin
    for j := 1 to NoVariables do
    begin
      if CovList.Items.Strings[i] = OS3MainFrm.DataGrid.Cells[j,0] then
      begin
        CovCols[i] := j;
        ColNoSelected[NoSelected] := j;
        NoSelected := NoSelected + 1;
        break;
      end;
    end;
  end;

  // create a "Block" for each covariate
  for i := 0 to NoCovs-1 do
  begin
    NoBlocks := NoBlocks + 1;
    Block[i,0] := 0;  // group min
    Block[i,1] := 0;  // group max
    Block[i,2] := CovCols[i]; // start column in grid
    Block[i,3] := CovCols[i]; // end column in grid
    Block[i,4] := 1;           // no. of vectors
    BlockLabel[i] := 'Cov' + IntToStr(i);
  end;
end;

procedure TANCOVAfrm.CodeGroups;
var
  col, i, j, value: integer;
  factlabel, cellstring: string;
  startcol: Integer = 0;   // to silence the compiler
  endcol: Integer = 0;
  noVectors: Integer = 0;
begin
  // create a block for code vectors of each fixed variable
  for i := 0 to NoFixed-1 do
  begin
    col := FixedCols[i];
    factlabel := chr(ord('A')+i);
    mingrp[i] := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,1])));
    maxgrp[i] := mingrp[i];
    for j := 1 to NoCases do
    begin
      if not GoodRecord(j,NoSelected,ColNoSelected) then continue;
      cellstring := Trim(OS3MainFrm.DataGrid.Cells[col,j]);
      value := round(StrToFloat(cellstring));
      if value < mingrp[i] then mingrp[i] := value;
      if value > maxgrp[i] then maxgrp[i] := value;
    end;

    // create fixed effect coding for levels - 1 of the fixed effect var.
    EffectCode(col, mingrp[i], maxgrp[i], factlabel, startcol, endcol, novectors);
    NoBlocks := NoBlocks + 1;
    Block[NoBlocks-1,0] := mingrp[i];
    Block[NoBlocks-1,1] := maxgrp[i];
    Block[NoBlocks-1,2] := startcol;
    Block[NoBlocks-1,3] := endcol;
    Block[NoBlocks-1,4] := novectors;
    BlockLabel[NoBlocks-1] := factlabel;
  end; // next factor block
end;

procedure TANCOVAfrm.GenInteractions;
type
  Twoway = array[0..9,0..1] of integer;
  Threeway = array[0..9,0..2] of integer;
  Fourway = array[0..4,0..3] of integer;
const
  Twoways: Twoway = (
    (1,2), (1,3), (2,3), (1,4), (2,4), (3,4), (1,5), (2,5), (3,5), (4,5)
  );
  Threeways: Threeway = (
    (1,2,3), (1,2,4), (1,3,4), (2,3,4), (1,2,5),
    (1,3,5), (1,4,5), (2,3,5), (2,4,5), (3,4,5)
  );
  Fourways: Fourway = (
    (1,2,3,4), (1,2,3,5), (1,2,4,5), (1,3,4,5), (2,3,4,5)
  );
var
  i, j, k, l, m, n, col, value: integer;
  labelstr: string;
  startcol, endcol, novectors, oldnovars: integer;
  cell1, cell2, cell3, cell4: string;
  TwoWayCombos, ThreeWayCombos, FourwayCombos: double;
  Block1, Block2, Block3, Block4, Start1, End1, Start2, End2, Start3, End3: integer;
  Start4, End4: integer;
begin
  novectors := 0;

  // Do two-way interactions
  if NoFixed < 2 then
    exit;
  TwoWayCombos := round(combos(2.0, NoFixed));
  oldnovars := NoVariables;
  for i := 0 to round(TwoWayCombos)-1 do
  begin
    Block1 := TwoWays[i,0] + NoCovs - 1;
    Block2 := TwoWays[i,1] + NoCovs - 1;
    Start1 := Block[Block1,2];
    End1 := Block[Block1,3];
    Start2 := Block[Block2,2];
    End2 := Block[Block2,3];
    oldnovars := NoVariables;
    startcol := Block[NoBlocks-1,3] + 1;
    col := NoVariables;
    for j := Start1 to End1 do
    begin
      for k := Start2 to End2 do
      begin
        col := col + 1;
        novectors := novectors + 1;
        DictionaryFrm.NewVar(col);
        labelstr := OS3MainFrm.DataGrid.Cells[j,0] + 'x';
        labelstr := labelstr + OS3MainFrm.DataGrid.Cells[k,0];
        OS3MainFrm.DataGrid.Cells[col,0] := labelstr;
        DictionaryFrm.DictGrid.Cells[1,col] := labelstr;
        for m := 1 to NoCases do
        begin
          if not GoodRecord(m,NoSelected,ColNoSelected) then Continue;
          cell1 := Trim(OS3MainFrm.DataGrid.Cells[j,m]);
          cell2 := Trim(OS3MainFrm.DataGrid.Cells[k,m]);
          value := round(StrToFloat(cell1)) * round(StrToFloat(cell2));
          OS3MainFrm.DataGrid.Cells[col,m] := IntToStr(value);
        end;
      end;
      endcol := col;
      NoBlocks := NoBlocks + 1;
      Block[NoBlocks-1,0] := 0; // zeroes for interactions
      Block[NoBlocks-1,1] := 0; // zeroes for interactions
      Block[NoBlocks-1,2] := startcol; // grid start col for 2-way interactions
      Block[NoBlocks-1,3] := endcol; // grid end col for 2-way interactions
      Block[NoBlocks-1,4] := novectors; // no. of vectors for 2-way interaction
      BlockLabel[NoBlocks-1] := BlockLabel[Block1] + 'x' + BlockLabel[Block2];
      NoVariables := oldnovars + novectors;
      OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
      novectors := 0;
    end; // end of interaction of fixed effect vectors j and fixed effect vectors k
  end; // end of 2 way interactions

  // do 3-way interactions using group vectors and two way interaction vectors
  if (NoFixed < 3) then
    exit;
  ThreeWayCombos := Combos(3.0, NoFixed);
  for i := 0 to round(ThreeWayCombos)-1 do
  begin
    startcol := Block[NoBlocks-1,3] + 1; // next column after last block
    col := NoVariables;
    Block1 := ThreeWays[i,0] + NoCovs - 1;
    Block2 := ThreeWays[i,1] + NoCovs - 1;
    Block3 := ThreeWays[i,2] + NoCovs - 1;
    Start1 := Block[Block1,2];
    End1 := Block[Block1,3];
    Start2 := Block[Block2,2];
    End2 := Block[Block2,3];
    Start3 := Block[Block3,2];
    End3 := Block[Block3,3];
    oldnovars := NoVariables;
    novectors := 0;
    for j := Start1 to End1 do
    begin
      for k := Start2 to End2 do
      begin
        for l := Start3 to End3 do // no. vectors in first factor
        begin
          col := col + 1;
          novectors := novectors + 1;
          DictionaryFrm.NewVar(col);
          labelstr := OS3MainFrm.DataGrid.Cells[j,0] + 'x';
          labelstr := labelstr + OS3MainFrm.DataGrid.Cells[k,0];
          labelstr := labelstr + 'x' + OS3MainFrm.DataGrid.Cells[l,0];
          OS3MainFrm.DataGrid.Cells[col,0] := labelstr;
          DictionaryFrm.DictGrid.Cells[1,col] := labelstr;
          for m := 1 to NoCases do
          begin
            if not GoodRecord(m,NoSelected,ColNoSelected) then Continue;
            cell1 := Trim(OS3MainFrm.DataGrid.Cells[j,m]);
            cell2 := Trim(OS3MainFrm.DataGrid.Cells[k,m]);
            cell3 := Trim(OS3MainFrm.DataGrid.Cells[l,m]);
            value := round(StrToFloat(cell1)) * round(StrToFloat(cell2)) * round(StrToFloat(cell3));
            OS3MainFrm.DataGrid.Cells[col,m] := IntToStr(value);
          end; // next case m
        end; // next third variable
      end; // next second variable
    end; // end of interaction of fixed effects vectors for j, k and l
    endcol := col; // last grid column containing three-way interaction vectors
    NoBlocks := NoBlocks + 1;
    Block[NoBlocks-1,0] := 0; // zeroes for interactions
    Block[NoBlocks-1,1] := 0; // zeroes for interactions
    Block[NoBlocks-1,2] := startcol; // grid start col for 2-way interactions
    Block[NoBlocks-1,3] := endcol; // grid end col for 2-way interactions
    Block[NoBlocks-1,4] := novectors; // no. of vectors for 2-way interaction
    BlockLabel[NoBlocks-1] := BlockLabel[Block1] + 'x' + BlockLabel[Block2] + 'x' + BlockLabel[Block3];
    NoVariables := oldnovars + novectors;
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
  end; // end of three way interactions

  // do 4-way interactions using group and 3-way interaction vectors
  if (NoFixed < 4) then
    exit;
  FourWayCombos := combos(4.0,NoFixed);
  for i := 0 to round(FourWayCombos) - 1 do
  begin
    startcol := Block[NoBlocks-1][3] + 1;
    col := NoVariables;
    Block1 := FourWays[i][0] + NoCovs - 1; // block # for first fixed effect
    Block2 := FourWays[i][1] + NoCovs - 1; // block # for second fixed effect
    Block3 := FourWays[i][2] + NoCovs - 1; // block # for third fixed effect
    Block4 := FourWays[i][3] + NoCovs - 1; // block # for fourth fixed effect
    Start1 := Block[Block1][2];
    End1 := Block[Block1][3];
    Start2 := Block[Block2][2];
    End2 := Block[Block2][3];
    Start3 := Block[Block3][2];
    End3 := Block[Block3][3];
    Start4 := Block[Block4][2];
    End4 := Block[Block4][3];
    oldnovars := NoVariables;
    novectors := 0;
    for j := Start1 to End1 do  // vector in first fixed factor
    begin
      for k := Start2 to End2 do // vector in second fixed factor
      begin
        for l := Start3 to End3 do  // vector in third fixed factor
        begin
          for m := Start4 to End4 do  // vecotr in fourth fixed factor
          begin
            col := col + 1;
            novectors := novectors + 1;
            DictionaryFrm.NewVar(col);
            labelstr := OS3MainFrm.DataGrid.Cells[j,0] + 'x';
            labelstr := labelstr + OS3MainFrm.DataGrid.Cells[k,0];
            labelstr := labelstr + 'x' + OS3MainFrm.DataGrid.Cells[l,0];
            OS3MainFrm.DataGrid.Cells[col,0] := labelstr;
            DictionaryFrm.DictGrid.Cells[1,col] := labelstr;
            for n := 1 to NoCases do
            begin
              cell1 := Trim(OS3MainFrm.DataGrid.Cells[j,n]);
              cell2 := Trim(OS3MainFrm.DataGrid.Cells[k,n]);
              cell3 := Trim(OS3MainFrm.DataGrid.Cells[l,n]);
              cell4 := Trim(OS3MainFrm.DataGrid.Cells[m,n]);
              value := round(StrToFloat(cell1)) *
                       round(StrToFloat(cell2)) *
                       round(StrToFloat(cell3)) *
                       round(StrToFloat(cell4));
              OS3MainFrm.DataGrid.Cells[col,n] := IntToStr(value);
            end; // next case n
          end; // next fourth vector m
        end; // next third vector
      end; // next second vector
    end; // end of interaction of fixed effects vectors for j, k and l and m

    endcol := col; // last grid column containing four-way interaction vectors
    NoBlocks := NoBlocks + 1;
    Block[NoBlocks-1][0] := 0; // zeroes for interactions
    Block[NoBlocks-1][1] := 0; // zeroes for interactions
    Block[NoBlocks-1][2] := startcol; // grid start col for 4-way interactions
    Block[NoBlocks-1][3] := endcol; // grid end col for 4-way interactions
    Block[NoBlocks-1][4] := novectors; // no. of vectors for 2-way interaction
    BlockLabel[NoBlocks-1] := BlockLabel[Block1] + 'x' +
                              BlockLabel[Block2] + 'x' +
                              BlockLabel[Block3] + 'x' + BlockLabel[Block4];
    NoVariables := oldnovars + novectors;
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
  end; // end of four-way combinations
end;

procedure TANCOVAfrm.DoRegs(AReport: TStrings);
var
  count: integer;
  i, j: integer;
begin
  {$IFDEF ANCOVA_DEBUG}
  DebugLn('ENTER DoRegs');
  {$ENDIF}

  // get count of variables used
  count := 0;
  for i := 0 to NoBlocks - 1 do
    for j := 0 to Block[i,4] do count := count + 1;

  {$IFDEF ANCOVA_DEBUG}
  WriteLn('DoRegs: Count = ', count);
  {$ENDIF}

  SetLength(BetaWeights,count+1);
  SetLength(BWeights,count+2);
//  SetLength(BStdErrs,count+1);
//  SetLength(BTtests,count+1);
  SetLength(Means,count+1);
  SetLength(Variances,count+1);
  SetLength(StdDevs,count+1);
  SetLength(RowLabels,count+1);
  SetLength(ColLabels,count+1);
  SetLength(Cormat,count+1,count+1);
  SetLength(Indmat,count+1,count+1);
  SetLength(IndepIndex,count+1);
  SetLength(ColNoSelected,count+1);

  PrintIt := CorrelationMats.Checked;

  Testout := false;
  Probout := 0.99;
  AReport.Add('ANALYSIS OF COVARIANCE USING MULTIPLE REGRESSION');
  AReport.Add('');
  AReport.Add('File Analyzed: ' + OS3MainFrm.FileNameEdit.Text);
  AReport.Add('');

  EntryOpt1(AReport); // factors, interactions and covariats concurrently

  IndepIndex := nil;
  {$IFDEF ANCOVA_DEBUG}
  DebugLn('EXIT DoRegs');
  {$ENDIF}
end;

procedure TANCOVAfrm.CleanUp;
begin
     Indmat := nil;
     Cormat := nil;
     ColLabels := nil;
     RowLabels := nil;
     StdDevs := nil;
     Variances := nil;
     Means := nil;
//     BTtests := nil;
//     BStdErrs := nil;
     BWeights := nil;
     BetaWeights := nil;
     maxgrp := nil;
     mingrp := nil;
     CovCols := nil;
     FixedCols := nil;
     ColNoSelected := nil
end;

procedure TANCOVAfrm.EntryOpt1(AReport: TStrings);
var
  i, j, k, col, count: integer;
  Title: string;
  FullR2: double;
  F: double;
  Prob: double;
  df1, df2: double;
  SSGroups: double;
  MSGroups: double;
  SSError: double;
  MSError: double;
  SSTotal: double;
//  SSExplained: double;
  SSGrpTot: double = 0.0;
  tProbs: DblDyneVec;
  BTtests: DblDyneVec;
  BStdErrs: DblDyneVec; // standard errors of regression weights
  localReport: TStrings;
begin
  {$IFDEF ANCOVA_DEBUG}
  DebugLn('ENTER EntryOpt1');
  {$ENDIF}

  // factors, interactions and covariates concurrently (full model)
  // get grid column numbers of all vectors and dependent variable

  AReport.Add('');
  AReport.Add('MODEL FOR TESTING ASSUMPTION OF ZERO INTERACTIONS WITH COVARIATES');
  AReport.Add('');

  count := 0;
  for i := 1 to NoBlocks do // no. of vector blocks
  begin
    for j := 1 to Block[i-1,4] do // no of vectors in block
    begin
      col := Block[i-1,2] + j - 1; // count from beginning col.
      count := count + 1;
      ColNoSelected[count-1] := col;
      IndepIndex[count-1] := count;
      RowLabels[count-1] := OS3MainFrm.DataGrid.Cells[col,0];
    end;
  end;
  count := count + 1;
  noind := count - 1;
  ColNoSelected[count-1] := DepColNo;
  IndepIndex[count-1] := count;
  RowLabels[count-1] := OS3MainFrm.DataGrid.Cells[DepColNo,0];

  // Get correlation matrix (note: dependent is last variable)
  Correlations(count,ColNoSelected,CorMat,Means,Variances,StdDevs,errorcode,NCases);
  if CorrelationMats.Checked then
  begin
    AReport.Add('');
    AReport.Add('================================================================================');
//    AReport.Add('');
    title := 'CORRELATION MATRIX';
    MatPrint(Cormat, count, count, title, RowLabels, RowLabels, NCases, AReport);
  end;

  if DescriptiveStats.Checked then
  begin
    AReport.Add('');
    AReport.Add('================================================================================');
    DynVectorPrint(Means, count, 'MEANS', RowLabels, NCases, AReport);
    AReport.Add('================================================================================');
    DynVectorPrint(Variances, count, 'VARIANCES', RowLabels, NCases, AReport);
    AReport.Add('================================================================================');
    DynVectorPrint(StdDevs, count, 'STD. DEV.S', RowLabels, NCases, AReport);
    AReport.Add('================================================================================');
    AReport.Add('');
  end;

  // Get regression
  SetLength(tProbs, count);
  printIt := false;

  SetLength(BStdErrs, noind+1);
  SetLength(BTtests, noind+1);
  MReg(
    noind, ColNoSelected, DepColNo, RowLabels ,Means, Variances, StdDevs,
    BWeights, BetaWeights, BStdErrs, BTtests, tProbs, R2, StdErrEst, NCases, errorcode,
    printIt, AReport
  );
  if not ErrorCode then
  begin
    FullR2 := R2;
    SSTotal := Variances[count-1] * (NCases - 1);
    SSGroups := FullR2 * SSTotal;
    SSError := (1.0 - FullR2) * SSTotal;
    df1 := noind;
    df2 := NCases - noind - 1;
    MSGroups := SSGroups / df1;
    MSError := SSError / df2;
    F := MSGroups / MSError;
    Prob := probf(F,df1,df2);
    AReport.Add('');
    AReport.Add('================================================================================');
    AReport.Add('');
    AReport.Add('Analysis of Variance for the Model to Test Regression Homogeneity');
    AReport.Add('    SOURCE      Deg.F.      SS          MS          F           Prob>F');
    AReport.Add('%10s  %10.0f  %10.2f  %10.2f  %10.3f  %10.4f', ['Explained', df1, SSGroups, MSGroups, F, Prob]);
    AReport.Add('%10s  %10.0f  %10.2f  %10.2f', ['Error', df2, SSError, MSError]);
    AReport.Add('%10s  %10d  %10.2f', ['Total', NCases-1, SSTotal]);
    AReport.Add('');
    AReport.Add('%12s  %10.3f',['R Squared = ',R2]);
    AReport.Add('');
  end;

  // Now do analysis without the interactions (Ancova model)
  AReport.Add('');
  AReport.Add('================================================================================');
  AReport.Add('');
  AReport.Add('Model for Analysis of Covariance');
  AReport.Add('');

  count := 0;
  for i := 1 to NoBlocks - 1 do // no. of vector blocks
  begin
    for j := 1 to Block[i-1,4] do // no of vectors in block
    begin
      col := Block[i-1,2] + j - 1; // count from beginning col.
      count := count + 1;
      ColNoSelected[count-1] := col;
      IndepIndex[count-1] := count;
      RowLabels[count-1] := OS3MainFrm.DataGrid.Cells[col,0];
    end;
  end;
  count := count + 1;
  noind := count - 1;
  ColNoSelected[count-1] := DepColNo;
  IndepIndex[count-1] := count;
  RowLabels[count-1] := OS3MainFrm.DataGrid.Cells[DepColNo,0];

  // Get correlation matrix (note dependent is last variable)
  Correlations(count,ColNoSelected,Cormat,Means,Variances,StdDevs,errorcode,NCases);
  // save in IndMat
  for i := 0 to count-1 do
    for j := 0 to count - 1 do
      IndMat[i,j] := Cormat[i,j];

  if CorrelationMats.Checked then
  begin
    AReport.Add('');
    Title := 'Correlation Matrix';
    MatPrint(Cormat, count, count, title, RowLabels, RowLabels, NCases, AReport);
  end;
  if DescriptiveStats.Checked then
  begin
    AReport.Add('');
    AReport.Add('================================================================================');
    DynVectorPrint(Means, count, 'MEANS', RowLabels, NCases, AReport);
    AReport.Add('================================================================================');
    DynVectorPrint(Variances, count, 'VARIANCES', RowLabels, NCases, AReport);
    AReport.Add('================================================================================');
    DynVectorPrint(StdDevs, count, 'STD. DEV.S', RowLabels, NCases, AReport);
    AReport.Add('================================================================================');
    AReport.Add('');
  end;

  // Get regression
  PrintIt := true;
  SetLength(BStdErrs, noind+1);
  SetLength(BTtests, noind+1);

  MReg(
    noind, ColNoSelected, DepColNo, RowLabels, Means, Variances, StdDevs,
    BWeights, BetaWeights, BStdErrs, BTtests, tProbs, R2, StdErrEst, NCases,
    errorcode, false, AReport
  );

  if not ErrorCode then
  begin
    // test differences between previous and current models (= beta test)
    constant := BWeights[noind];
    df1 := NoTestVecs;
    F := ((FullR2 - R2) / df1) / ((1.0 - FullR2) / df2);
    Prob := probf(F,df1,df2);
    AReport.Add('');
    AReport.Add('================================================================================');
    AReport.Add('');
    AReport.Add('Test for Homogeneity of Group Regression Coefficients');
    AReport.Add('Change in R2 = %6.4f. F = %10.3f  Prob.> F = %6.4f with d.f. %8.0f and %8.0f', [(FullR2 - R2), F, Prob, df1, df2]);
    AReport.Add('');
    AReport.Add('%12s  %10.3f',['R Squared = ', R2]);

    FullR2 := R2;
    SSTotal := Variances[count-1] * (NCases - 1);
    SSGroups := FullR2 * SSTotal;
    SSError := (1.0 - FullR2) * SSTotal;
    df1 := noind;
    df2 := NCases - noind - 1;
    MSGroups := SSGroups / df1;
    MSError := SSError / df2;

    // obtain Adjusted means
  //     AdjustMeans(self);
       // Make Comparisons among means
  //     if multcomp then MultCompare(self);
    F := MSGroups / MSError;
    Prob := probf(F,df1,df2);
    AReport.Add('');
    AReport.Add('================================================================================');
    AReport.Add('');
    AReport.Add('Analysis of Variance for the ANCOVA Model');
    AReport.Add('    SOURCE      Deg.F.      SS          MS          F           Prob>F');
    AReport.Add('%10s  %10.0f  %10.2f  %10.2f  %10.3f  %10.4f', ['Explained', df1, SSGroups, MSGroups, F, Prob]);
    AReport.Add('%10s  %10.0f  %10.2f  %10.2f', ['Error', df2, SSError, MSError]);
    AReport.Add('%10s  %10d  %10.2f', ['Total', NCases-1, SSTotal]);
    AReport.Add('');
    AReport.Add('');
  end;

  // Obtain adjusted means
  AdjustMeans(AReport);

  // make comparisons among groups
  if multcomp then MultCompare(AReport);

  // Now do regression, eliminating each block to test effects of that term
  PrintIt := false;
  AReport.Add('');
  AReport.Add('================================================================================');
  AReport.Add('');
  AReport.Add('TEST FOR EACH SOURCE OF VARIANCE - Type III SS');
  AReport.Add('');
  AReport.Add('--------------------------------------------------------------------------');
  AReport.Add('    SOURCE        Deg.F.      SS          MS          F             Prob>F');
  AReport.Add('--------------------------------------------------------------------------');

  localReport := TStringList.Create;
  try
    for i := 1 to NoBlocks - 1 do // covariates, fixed effects, interactions
    begin
      count := 0;
      for j := 1 to NoBlocks-1 do
      begin
        if j = i then continue; // exclude the factor to be tested
        for k := 1 to Block[j-1,4] do // no of vectors in block
        begin
          col := Block[j-1,2] + k - 1; // count from beginning col.
          count := count + 1;
          ColNoSelected[count-1] := col;
          IndepIndex[count-1] := count;
          RowLabels[count-1] := OS3MainFrm.DataGrid.Cells[col,0];
        end;
      end; // get next block of vectors for factors to be included
      count := count + 1;
      noind := count - 1;
      ColNoSelected[count-1] := DepColNo;
      IndepIndex[count-1] := count;
      RowLabels[count-1] := OS3MainFrm.DataGrid.Cells[DepColNo,0];
      Correlations(count,ColNoSelected,Cormat,Means,Variances,StdDevs,errorcode,NCases);

      // Get regression
      SetLength(BStdErrs, noind+1);
      SetLength(BTtests, noind+1);
      localReport.Add(Blocklabel[i-1]);
      localReport.Add('');
      MReg(
        noind, ColNoSelected, DepColNo, RowLabels, Means, Variances, StdDevs,
        BWeights, BetaWeights, BStdErrs, BTtests, tProbs, R2, StdErrEst, NCases,
        errorcode, false, localReport
      );
      localReport.Add('');

      df1 := Block[i-1,4];
      SSGroups := (FullR2 - R2)* SSTotal;
      SSGrpTot := SSGrpTot + SSGroups;
      MSGroups := SSGroups / df1;
      F := MSGroups / MSError;
      Prob := probf(F,df1,df2);

      AReport.Add('%10s  %10.0f  %10.2f  %10.2f  %10.3g  %10.4f', [BlockLabel[i-1], df1, SSGroups, MSGroups, F, Prob]);
    end; // get next Block to eliminate

    AReport.Add('');
    AReport.Add('----------------------------------------------------------------------');
    AReport.Add('%10s  %10.0f  %10.2f  %10.2f', ['ERROR', df2, SSError, MSError]);
    AReport.Add('----------------------------------------------------------------------');
    AReport.Add('%10s  %10d  %10.2f', ['TOTAL', NCases-1, SSTotal]);

    AReport.Add('');
    AReport.AddStrings(localReport);
  finally
    localReport.Free;
  end;

    {
     df1 := NoCovs;
     SSGroups := SSExplained - SSGrpTot;
     MSGroups := SSGroups / df1;
     F := MSGroups / MSError;
     Prob := probf(F,df1,df2);
     outline := format('%10s  %10.0f  %10.2f  %10.2f  %10.3f  %10.4f',
                            ['Covariates',df1,SSGroups,MSGroups,F,Prob]);
     OutputFrm.RichEdit.Lines.Add(outline);

     outline := format('%10s  %10.0f  %10.2f  %10.2f',
                            ['Error',df2,SSError,MSError]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('%10s  %10d  %10.2f',
                            ['Total',NCases-1,SSTotal]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('');
}
  tProbs := nil;
  BTTests := nil;
  BStdErrs := nil;

  {$IFDEF ANCOVA_DEBUG}
  DebugLn('EXIT EntryOpt1');
  {$ENDIF}
end;

procedure TANCOVAfrm.GenCovInteracts;
var
  i, j, l, m, vect1col, vect2col, col: integer;
  value: double;
  labelstr, cell1, cell2: string;
  startcol, endcol, novectors, oldnovars: integer;
  lastblock, firstblock: integer;
begin
  col := NoVariables;
  oldnovars := NoVariables;
  novectors := 0;
  NoTestVecs := 0;
  startcol := Block[NoBlocks-1,3] + 1;
  lastblock := NoBlocks;
  firstblock := NoCovs + 1;

  // product vectors for each covariate
  for i := 1 to NoCovs do
  begin
    vect1col := Block[i-1,2];
    for j := firstblock to lastblock do
    begin
      for l := 1 to Block[j-1,4] do
      begin
        vect2col := Block[j-1,2] + l - 1; // first vector col. of B
        col := col + 1;
        novectors := novectors + 1;
        NoTestVecs := NoTestVecs + 1;

        DictionaryFrm.NewVar(col);
        labelstr := OS3MainFrm.DataGrid.Cells[vect1col,0] + 'x';
        labelstr := labelstr + OS3MainFrm.DataGrid.Cells[vect2col,0];
        OS3MainFrm.DataGrid.Cells[col,0] := labelstr;
        DictionaryFrm.DictGrid.Cells[1,col] := labelstr;
        for m := 1 to NoCases do
        begin
          if not GoodRecord(m,NoSelected,ColNoSelected) then Continue;
          cell1 := Trim(OS3MainFrm.DataGrid.Cells[vect1col,m]);
          cell2 := Trim(OS3MainFrm.DataGrid.Cells[vect2col,m]);
          value := StrToFloat(cell1) * StrToFloat(cell2);
          OS3MainFrm.DataGrid.Cells[col,m] := FloatToStr(value);
        end; // next case m
      end; // next l vector
    end; // next fixed effects factor j and interactions
  end; // next covariate i

  endcol := col; // last grid column containing two-way interaction vectors
  NoBlocks := NoBlocks + 1;
  Block[NoBlocks-1,0] := 0; // zeroes for interactions
  Block[NoBlocks-1,1] := 0; // zeroes for interactions
  Block[NoBlocks-1,2] := startcol; // grid start col for 2-way interactions
  Block[NoBlocks-1,3] := endcol; // grid end col for 2-way interactions
  Block[NoBlocks-1,4] := novectors; // no. of vectors for 2-way interaction
  BlockLabel[NoBlocks-1] := BlockLabel[i-1] + 'xFixed';
  NoVariables := oldnovars + novectors;
  OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
end;

procedure TANCOVAfrm.AdjustMeans(AReport: TStrings);
var
   sum : double;
   GrpCovMeans : DblDyneMat;
   AdjMeans : DblDyneVec;
   Intercepts : DblDyneVec;
   i, j, k, col, grp, nogrps : integer;
   value : double;
   Labels : StrDyneVec;
   noingrp : IntDyneVec;
   XValue : DblDyneVec;
   maxmean : double;
   cell1 : string;
begin
     SetLength(GrpCovMeans,noind,noind);
     SetLength(AdjMeans,noind);
     SetLength(Intercepts,noind);
     SetLength(Labels,noind);
     SetLength(noingrp,noind);
     SetLength(XValue,noind);

     // get means for groups and covariates
     for j := 1 to NoFixed do // for each fixed variable
     begin
          nogrps := maxgrp[j-1] - mingrp[j-1] + 1;
          maxmean := 0.0;
          for i := 1 to nogrps do
          begin
               XValue[i-1] := i;
               noingrp[i-1] := 0;
               for k := 1 to NoCovs do GrpCovMeans[i-1,k-1] := 0.0;
          end;
          for i := 1 to nogrps do AdjMeans[i-1] := 0.0;
          for i := 1 to NoCases do
          begin
               cell1 := Trim(OS3MainFrm.DataGrid.Cells[FixedCols[j-1],i]);
               if cell1 = '' then continue;
               grp := round(StrToFloat(cell1));
               grp := grp - mingrp[j-1] + 1;
               noingrp[grp-1] := noingrp[grp-1] + 1;
               for k := 1 to NoCovs do
               begin
                    col := CovCols[k-1];
                    cell1 := Trim(OS3MainFrm.DataGrid.Cells[col,i]);
                    if cell1 = '' then continue;
                    value := StrToFloat(cell1);
                    GrpCovMeans[grp-1,k-1] := GrpCovMeans[grp-1,k-1] + value;
               end;
               cell1 := Trim(OS3MainFrm.DataGrid.Cells[DepColNo,i]);
               if cell1 = '' then continue;
               value := StrToFloat(cell1);
               AdjMeans[grp-1] := AdjMeans[grp-1] + value;
          end; // next case i

          SetLength(GraphFrm.Ypoints,1,nogrps);
          SetLength(GraphFrm.Xpoints,1,nogrps);
          for k := 1 to nogrps do
          begin
               AdjMeans[k-1] := AdjMeans[k-1] / noingrp[k-1];
               GraphFrm.Ypoints[0,k-1] := AdjMeans[k-1];
               GraphFrm.Xpoints[0,k-1] := k;
               if AdjMeans[k-1] > maxmean then maxmean := AdjMeans[k-1];
               for i := 1 to NoCovs do
               begin
                    GrpCovMeans[k-1,i-1] := GrpCovMeans[k-1,i-1] / noingrp[k-1];
               end;
          end;

          // print unadjusted means
          AReport.Add('================================================================================');
          AReport.Add('');
          AReport.Add('Unadjusted Group Means for Group Variables ' + OS3MainFrm.DataGrid.Cells[FixedCols[j-1] ,0]);
          DynVectorPrint(AdjMeans,nogrps,'Means',Labels,NCases, AReport);
          AReport.Add('');

          // plot group means if requested
          if plot then
          begin
               GraphFrm.nosets := 1;
               GraphFrm.nbars := nogrps;
               GraphFrm.Heading := 'Unadjusted Means';
               GraphFrm.XTitle := 'GROUP';
               GraphFrm.YTitle := 'Mean';
               GraphFrm.barwideprop := 0.5;
               GraphFrm.AutoScaled := false;
               GraphFrm.miny := 0.0;
               GraphFrm.maxy := maxmean;
               GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
               GraphFrm.BackColor := clCream;
               GraphFrm.WallColor := clDkGray;
               GraphFrm.FloorColor := clLtGray;
               GraphFrm.ShowBackWall := true;
               GraphFrm.ShowModal;
          end;
          // get intercepts for group equations for this fixed effect variable
          sum := 0.0;
          for k := 1 to nogrps - 1 do // no. vectors is 1 less than no. groups
          begin
               intercepts[k-1] := constant + BWeights[NoCovs+k-1];
               sum := sum + BWeights[NoCovs+k-1];
          end;
          intercepts[nogrps-1] := constant - sum;

          // get adjusted means
          for k := 1 to nogrps do
          begin
               sum := 0.0;
               for i := 1 to NoCovs do
                    sum := sum + BWeights[i-1] * (GrpCovMeans[k-1,i-1]-Means[i-1]);
               AdjMeans[k-1] := AdjMeans[k-1] - sum;
               GraphFrm.Ypoints[0,k-1] := AdjMeans[k-1];
               Labels[k-1] := 'Group ' + IntToStr(k);
          end;

          // plot group means if requested
          if plot then
          begin
               GraphFrm.nosets := 1;
               GraphFrm.nbars := nogrps;
               GraphFrm.Heading := 'Adjusted Means';
               GraphFrm.XTitle := 'GROUP';
               GraphFrm.YTitle := 'Mean';
               GraphFrm.barwideprop := 0.5;
               GraphFrm.AutoScaled := false;
               GraphFrm.miny := 0.0;
               GraphFrm.maxy := maxmean;
               GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
               GraphFrm.BackColor := clCream;
               GraphFrm.WallColor := clDkGray;
               GraphFrm.FloorColor := clLtGray;
               GraphFrm.ShowBackWall := true;
               GraphFrm.ShowModal;
          end;

          // print results for intercepts
          AReport.Add('================================================================================');
          AReport.Add('');
          AReport.Add('Intercepts for Each Group Regression Equation for Variable: ' + OS3MainFrm.DataGrid.Cells[FixedCols[j-1] ,0]);
          DynVectorPrint(Intercepts, nogrps, 'Intercepts', Labels, NCases, AReport);
          AReport.Add('');

          // print adjusted means
          AReport.Add('================================================================================');
          AReport.Add('');
          AReport.Add('Adjusted Group Means for Group Variables ' + OS3MainFrm.DataGrid.Cells[FixedCols[j-1] ,0]);
          DynVectorPrint(AdjMeans, nogrps, 'Means', Labels, NCases, AReport);
          AReport.Add('');
     end;
     //OutputFrm.ShowModal;
     //OutputFrm.RichEdit.Clear;
     XValue := nil;
     noingrp := nil;
     Labels := nil;
     intercepts := nil;
     AdjMeans := nil;
     GrpCovMeans := nil;
     GraphFrm.Xpoints := nil;
     GraphFrm.Ypoints := nil;
end;

procedure TANCOVAfrm.MultCompare(AReport: TStrings);
var
   i, j, size : integer;
   covmat : DblDyneMat;
   title : string;
   Labels : StrDyneVec;
   sum : double;
   df1, df2, F, Prob : double;

begin
     SetLength(covmat,noind,noind);
     SetLength(Labels,noind);

     AReport.Add('================================================================================');
     AReport.Add('');
     AReport.Add('Multiple Comparisons Among Group Means');
     AReport.Add('');
     SVDInverse(IndMat,noind);
     size := noind - NoCovs;
     title := 'Inverse of Independents Matrix';
     for i := 1 to noind do Labels[i-1] := 'Group ' + IntToStr(i);
     for i := 1 to noind-NoCovs do
          for j := 1 to noind-NoCovs do
               covmat[i-1,j-1] := sqr(StdErrEst) * IndMat[NoCovs+i-1,NoCovs+j-1] /
               (Variances[NoCovs+j-1] * (NoCases-1));
     for i := 1 to size+1 do Labels[i-1] := 'Group ' + IntToStr(i);

     // augment matrix
     for i := 1 to size do
     begin
          sum := 0.0;
          for j := 1 to size do
          begin
               sum := sum + covmat[i-1,j-1];
          end;
          covmat[i-1,size] := -sum;
          covmat[size,i-1] := -sum;
     end;

     sum := 0.0;
     for i := 1 to size do sum := sum + covmat[i-1,size];
     covmat[size,size] := -sum;
     if PrintInverseMat.Checked then
     begin
          AReport.Add('================================================================================');
          AReport.Add('');
          title := 'Augmented Covariance Among Group Vectors';
          for i := 1 to size do Labels[i-1] := 'Group ' + IntToStr(i);
          MatPrint(covmat,size+1,size+1,title,Labels,Labels,NoCases, AReport);
     end;

     // Now, contrast the b coefficients
     // Get last B weight from effect coding as - sum of other B weights
     BWeights[noind] := 0.0;
     for i := 0 to noind-1 do BWeights[noind] := BWeights[noind] - BWeights[i];
     for i := 1 to size do
     begin
          for j := i + 1 to size + 1 do
          begin
               df1 := 1.0;
               df2 := NoCases - noind - 1;
               F := sqr(BWeights[NoCovs+i-1] - BWeights[NoCovs+j-1]);
               F := F / (covmat[i-1,i-1] + covmat[j-1,j-1] - (covmat[i-1,j-1] + covmat[j-1,i-1]));
               Prob := probf(F,df1,df2);
               AReport.Add('Comparison of Group %3d with Group %3d', [i,j]);
               AReport.Add('F = %10.3f, probability = %5.3f with degrees of freedom %5.0f and %5.0f', [F, Prob, df1, df2]);
          end;
     end;
     AReport.Add('');
     Labels := nil;
     covmat := nil;
end;

procedure TANCOVAfrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  DepIn.Enabled := (VarList.ItemIndex > -1) and (DepVar.Text = '');
  DepOut.Enabled := (DepVar.Text <> '');

  lSelected := false;
  for i := 0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  FixedIn.Enabled := lSelected;
  CovIn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to FixedList.Items.Count-1 do
    if FixedList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  FixedOut.Enabled := lSelected;

  lSelected := false;
  for i := 0 to CovList.Items.Count-1 do
    if CovList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  CovOut.Enabled := lSelected;
end;

procedure TANCOVAfrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I ancovaunit.lrs}

end.

