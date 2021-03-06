// File for testing: ABCLogLinData.laz
// Use all variables in original order
// Click the button and define Min/max values:
//   variable "Row":   1 .. 2
//   variable "Col":   1 .. 2
//   variable "Slice": 1 .. 3
//   variable  "X":    1 .. 9
//
// NOTE: the calculation crashes

unit LogLinScreenUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Grids,
  Globals, MainUnit, FunctionsLib, OutputUnit, DataProcs, ContextHelpUnit;

type

  { TLogLinScreenFrm }

  TLogLinScreenFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    InBtn: TBitBtn;
    Label1: TLabel;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    MarginsChk: TCheckBox;
    GenlModelChk: TCheckBox;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    SelectList: TListBox;
    MinMaxGrid: TStringGrid;
    VarList: TListBox;
    CountVarChk: TCheckBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure CountVarChkChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure SelectListSelectionChange(Sender: TObject; User: boolean);
    function ArrayPosition(NumDims: integer; const Data: DblDyneVec;
      const Subscripts, DimSize: IntDyneVec): integer;
    procedure Marginals(NumDims, ArraySize: integer; const Indexes: IntDyneMat;
      const Data: DblDyneVec; const Margins: IntDyneMat);

    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
    procedure UpdateMinMaxGrid;

    procedure Screen(VAR NVAR : integer;
                 VAR MP : integer; VAR MM : integer;
                 VAR NTAB : integer; VAR TABLE : DblDyneVec;
                 VAR DIM : IntDyneVec; VAR GSQ : DblDyneVec;
                 VAR DGFR : IntDyneVec; VAR PART : DblDyneMat;
                 VAR MARG : DblDyneMat; VAR DFS : IntDyneMat;
                 VAR IP : IntDyneMat; VAR IM : IntDyneMat;
                 VAR ISET : IntDyneVec; VAR JSET : IntDyneVec;
                 VAR CONFIG : IntDyneMat; VAR FIT : DblDyneVec;
                 VAR SIZE : IntDyneVec; VAR COORD : IntDyneVec;
                 VAR X : DblDyneVec; VAR Y : DblDyneVec;
                 VAR IFAULT : integer);

    procedure CONF(VAR N : integer; VAR M : integer;
               VAR MP : integer;
               VAR MM : integer;
               VAR ISET : IntDyneVec; VAR JSET : IntDyneVec;
               VAR IP : IntDyneMat; VAR IM : IntDyneMat; VAR NP : integer);

    procedure COMBO(VAR ISET : IntDyneVec;
                   N, M : Integer;
                   VAR LAST : boolean);

    procedure EVAL(VAR IAR : IntDyneMat;
                 NC, NV, IBEG, NVAR, MAX : integer;
                 VAR CONFIG : IntDyneMat;
                 VAR DIM : IntDyneVec; VAR DF : integer);

    procedure RESET(VAR FIT : DblDyneVec; NTAB : Integer;
                  AVG : Double);

    procedure LIKE(VAR GSQ : Double; VAR FIT : DblDyneVec;
                 VAR TABLE : DblDyneVec; NTAB : integer);

    procedure LOGFIT(NVAR, NTAB, NCON : integer;
                 VAR DIM : IntDyneVec;
                 VAR CONFIG : IntDyneMat; VAR TABLE : DblDyneVec;
                 VAR FIT : DblDyneVec; VAR SIZE : IntDyneVec;
                 VAR COORD : IntDyneVec; VAR X : DblDyneVec;
                 VAR Y : DblDyneVec);

    procedure MaxCombos(NumDims: integer; out MM, MP: integer);

  public
    { public declarations }
  end; 

var
  LogLinScreenFrm: TLogLinScreenFrm;

implementation

uses
  Math, LCLIntf, LCLType, Utils;

{ TLogLinScreenFrm }

procedure TLogLinScreenFrm.ResetBtnClick(Sender: TObject);
var
  i : integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  SelectList.Clear;
  UpdateBtnStates;
  UpdateMinMaxGrid;
end;

procedure TLogLinScreenFrm.SelectListSelectionChange(Sender: TObject;
  User: boolean);
begin
  UpdateBtnStates;
end;

procedure TLogLinScreenFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      SelectList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateMinMaxGrid;
  UpdateBtnStates;
end;

procedure TLogLinScreenFrm.FormActivate(Sender: TObject);
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

  MinMaxGrid.ClientWidth := 3 * MinMaxGrid.Canvas.TextWidth('Maximum ') + 6*varCellPadding;

  Constraints.MinWidth := MinMaxGrid.Width * 3 + AllBtn.Width + 4 * VarList.BorderSpacing.Left;
  Constraints.MinHeight := Height;
  AutoSize := false;
  Height := 2*Height;

  Position := poMainFormCenter;

  FAutoSized := true;
end;

procedure TLogLinScreenFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TLogLinScreenFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TLogLinScreenFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TLogLinScreenFrm.AllBtnClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to VarList.Items.Count-1 do
    SelectList.Items.Add(VarList.Items[i]);
  VarList.Clear;
  UpdateBtnStates;
  UpdateMinMaxGrid;
end;

procedure TLogLinScreenFrm.ComputeBtnClick(Sender: TObject);
var
   ArraySize : integer;
   N : integer;
   index, index2, i, j, k, l, NoVars : integer;
   count : integer;
   Data : DblDyneVec;
   Subscripts : IntDyneVec;
   DimSize : IntDyneVec;
   GridPos : IntDyneVec;
   Labels  : StrDyneVec;
   Margins : IntDyneMat;
   Expected : DblDyneVec;
   WorkVec : IntDyneVec;
   Indexes : IntDyneMat;
   LogM : DblDyneVec;
   M : DblDyneMat;
   astr, HeadStr : string;
   MaxDim, MP, MM  : integer;
   U, Mu : Double;
   Chi2, G2 : double;
   DF : integer;
   ProbChi2, ProbG2 : double;
   GSQ : DblDyneVec;
   DGFR : IntDyneVec;
   PART : DblDyneMat;
   MARG : DblDyneMat;
   DFS : IntDyneMat;
   IP : IntDyneMat;
   IM : IntDyneMat;
   ISET : IntDyneVec;
   JSET : IntDyneVec;
   CONFIG : IntDyneMat;
   FIT : DblDyneVec;
   SIZE : IntDyneVec;
   COORD : IntDyneVec;
   X, Y : DblDyneVec;
   IFAULT : integer;
   TABLE : DblDyneVec;
   DIM : IntDyneVec;
   NoDims: Integer;
   Minimums: IntDyneVec;
   Maximums: IntDyneVec;
//   Response: BoolDyneVec;
//   Interact: BoolDyneVec;
   lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
     // Allocate space for labels, DimSize and SubScripts
     NoDims := MinMaxGrid.RowCount - 1;
     NoVars := SelectList.Items.Count;

     SetLength(Labels, NoVars);
     SetLength(GridPos, NoVars);
     SetLength(Minimums, NoDims);
     SetLength(Maximums, NoDims);
     SetLength(DimSize, NoDims);
     SetLength(Subscripts, NoDims);

     for i := 1 to NoDims do
     begin
       if not TryStrToInt(MinMaxGrid.Cells[1, i], Minimums[i-1]) then
       begin
         MessageDlg('Integer number > 0 expected.', mtError, [mbOK], 0);
         exit;
       end;
       if not TryStrToInt(MinMaxGrid.Cells[2, i], Maximums[i-1]) then
       begin
         MessageDlg('Integer number > 0 expected.', mtError, [mbOK], 0);
         exit;
       end;
     end;

     // get variable labels and column positions
     for i := 1 to NoVars do
     begin
       astr := SelectList.Items.Strings[i-1];
       for j := 1 to NoVariables do
       begin
         if OS3MainFrm.DataGrid.Cells[j,0] = astr then
         begin
           Labels[i-1] := astr;
           GridPos[i-1] := j;
           break;
         end;
       end;
     end;

     // Get no. of categories for each dimension (DimSize)
     MaxDim := 0;
     ArraySize := 1;
     for i := 0 to NoDims - 1 do
     begin
       DimSize[i] := Maximums[i] - Minimums[i] + 1;
       if DimSize[i] > MaxDim then MaxDim := DimSize[i];
       ArraySize := ArraySize * DimSize[i];
     end;

     // Allocate space for Data and marginals
     SetLength(WorkVec,MaxDim);
     SetLength(Data,ArraySize);
     SetLength(Margins,NoDims,MaxDim);
     SetLength(Expected,ArraySize);
     SetLength(Indexes,ArraySize+1,NoDims);
     SetLength(LogM,ArraySize);
     SetLength(M,ArraySize,NoDims);

     // Initialize data and margins arrays
     for i := 1 to NoDims do
       for j := 1 to MaxDim do
         Margins[i-1,j-1] := 0;
     for i := 1 to ArraySize do
       Data[i-1] := 0;

     // Read and store frequencies in Data
     for i := 1 to NoCases do
     begin
       if GoodRecord(i, NoVars, GridPos) then // casewise check
       begin
         // get cell subscripts
         for j := 1 to NoDims do
         begin
           index := StrToInt(OS3MainFrm.DataGrid.Cells[GridPos[j-1],i]);
           index := index - Minimums[j-1] + 1;
           Subscripts[j-1] := index;
         end;

         index := ArrayPosition(NoDims, Data, Subscripts, DimSize);

         // save subscripts for later use
         for j := 1 to NoDims do
           Indexes[index,j-1] := Subscripts[j-1];

         if CountVarChk.Checked then
         begin
           k := GridPos[NoVars-1];
           Data[index] := Data[index] + StrToInt(OS3MainFrm.DataGrid.Cells[k,i]);
         end else
           Data[index] := Data[index] + 1;
       end;
     end;

     // get total N
     N := 0;
     for i := 1 to ArraySize do
       N := N + Round(Data[i-1]);

     // Get marginal frequencies
     Marginals(NoDims, ArraySize, Indexes, Data, Margins);

     // Print Marginal totals if requested
     if MarginsChk.Checked then
     begin
          lReport.Add('FILE: '+ OS3MainFrm.FileNameEdit.Text);
          lReport.Add('');
          for i := 1 to NoDims do
          begin
               HeadStr := 'Marginal Totals for ' + Labels[i-1];
               k := DimSize[i-1];
               for j := 0 to k-1 do WorkVec[j] := Margins[i-1,j];
               VecPrint(WorkVec,k,HeadStr, lReport);
          end;
     end;
     lReport.Add('');
     lReport.Add('Total Frequencies: %d', [N]);
     lReport.Add('');
     lReport.Add(DIVIDER);
     lReport.Add('');

     // Get Expected cell values
     U := 0.0; // overall mean (mu) of log linear model
     for i := 1 to ArraySize do // indexes point to each cell
     begin
          Expected[i-1] := 1.0;
          for j := 1 to NoDims do
          begin
               k := Indexes[i-1,j-1];
               Expected[i-1] := Expected[i-1] * (Margins[j-1,k-1] / N);
          end;
          Expected[i-1] := Expected[i-1] * N;
          LogM[i-1] := ln(Expected[i-1]);
     end;
     for i := 1 to ArraySize do U := U + LogM[i-1];
     U := U / ArraySize;

     // print expected values
     lReport.Add('FILE: '+ OS3MainFrm.FileNameEdit.Text);
     lReport.Add('');
     lReport.Add('EXPECTED CELL VALUES FOR MODEL OF COMPLETE INDEPENDENCE');
     lReport.Add('');
     astr := 'Cell';
     for j := 2 to NoDims do astr := astr + '    ';
     lReport.Add(astr + 'Observed  Expected  Log Expected');
     astr := '';
     for j := 1 to NoDims do astr := astr + '--- ';
     astr := astr + '---------- ---------- ----------';
     lReport.Add(astr);
     for i := 1 to ArraySize do
     begin
          astr := '';
          for j := 1 to NoDims do astr := astr + format('%3d ',[Indexes[i-1,j-1]]);
          astr := astr + format('%10.0f %10.2f %10.3f',[Data[i-1],Expected[i-1],LogM[i-1]]);
          lReport.Add(astr);
     end;

     // Calculate chi-squared and G squared statistics
     chi2 := 0.0;
     G2 := 0.0;
     for i := 1 to ArraySize do
     begin
          chi2 := chi2 + Sqr(Data[i-1] - Expected[i-1]) / Expected[i-1];
          G2 := G2 + Data[i-1] * ln(Data[i-1] / Expected[i-1]);
     end;
     G2 := 2.0 * G2;
     DF := 1;
     for i := 1 to NoDims do DF := DF * (DimSize[i-1]-1);
     ProbChi2 := 1.0 - ChiSquaredProb(chi2,DF);
     ProbG2 := 1.0 - ChiSquaredProb(G2,DF);
     lReport.Add('Chisquare: %10.3f with probability %10.3f (DF = %d)', [chi2, ProbChi2, DF]);
     lReport.Add('G squared: %10.3f with probability %10.3f (DF = %d)', [G2, ProbG2, DF]);
     lReport.Add('');
     lReport.Add('U (mu) for general loglinear model: %10.2f', [U]);

     lReport.Add('');
     lReport.Add(DIVIDER);
     lReport.Add('');

     // Get log linear model values for each cell
     // get M's for each cell
     lReport.Add('First Order LogLinear Model Factors and N of Cells in Each');
     astr := 'CELL              ';
     for i := 1 to NoDims do astr := astr + format(' U%d  N Cells   ',[i]);
     lReport.Add(astr);
     lReport.Add('');
     for i := 1 to ArraySize do // cell
     begin
          astr := '';
          for j := 1 to NoDims do
              astr := astr + format('%3d ',[Indexes[i-1,j-1]]);
          for j := 1 to NoDims do  // jth mu
          begin
               index := Indexes[i-1,j-1]; // sum for this mu
               count := 0;
               Mu := 0.0;
               for k := 1 to ArraySize do
               begin
                    if index = Indexes[k-1,j-1] then
                    begin
                         count := count + 1;
                         Mu := Mu + LogM[k-1];
                    end;
               end;
               Mu := Mu / count - U;
               astr := astr + format('%10.3f %3d ',[Mu,count]);
          end;
          lReport.Add(astr);
     end;
     lReport.Add('');
     lReport.Add(DIVIDER);
     lReport.Add('');

     // get second order interactions
     lReport.Add('Second Order Loglinear Model Terms and N of Cells in Each');
     astr := 'CELL              ';
     for i := 1 to NoDims-1 do
         for j := i + 1 to NoDims do
             astr := astr + format('U%d%d  N Cells  ',[i,j]);
     lReport.Add(astr);
     lReport.Add('');
     for i := 1 to ArraySize do // cell
     begin
          astr := '';
          for j := 1 to NoDims do
              astr := astr + format('%3d ',[Indexes[i-1,j-1]]);
          for j := 1 to NoDims-1 do  // jth
          begin
               index := Indexes[i-1,j-1]; // sum for this mu using j and k
               for k := j+1 to NoDims do // with kth
               begin
                    index2 := Indexes[i-1,k-1];
                    Mu := 0.0;
                    count := 0;
                    for l := 1 to ArraySize do
                    begin
                         if ((index = Indexes[l-1,j-1]) and (index2 = Indexes[l-1,k-1])) then
                         begin
                              Mu := Mu + LogM[l-1];
                              count := count + 1;
                         end;
                    end; // next l
                    Mu := Mu / count - U;
                    astr := astr + Format('%10.3f %3d', [Mu, count]);
               end; // next k (second term subscript)
          end; // next j (first term subscript)
          lReport.Add(astr);
     end; // next i

     lReport.Add('');
     lReport.Add(DIVIDER);
     lReport.Add('');

     // get maximum no. of interactions in saturated model
     MaxCombos(NoDims, MM, MP);

     SetLength(GSQ,NoDims+1);
     SetLength(DGFR,NoDims+1);
     SetLength(PART,NoDims+1,MP+1);
     SetLength(MARG,NoDims+1,MP+1);
     SetLength(DFS,NoDims+1,MP+1);
     SetLength(IP,NoDims+1,MP+1);
     SetLength(IM,NoDims+1,MM+1);
     SetLength(ISET,NoDims+1);
     SetLength(JSET,NoDims+1);
     SetLength(CONFIG,NoDims+1,MP+1);
     SetLength(FIT,ArraySize+1);
     SetLength(SIZE,NoDims+1);
     SetLength(COORD,NoDims+1);
     SetLength(X,ArraySize+1);
     SetLength(Y,ArraySize+1);
     SetLength(TABLE,ArraySize+1);
     SetLength(DIM,NoDims+1);

     // Load TABLE and DIM one up from Data
     for i := 1 to ArraySize do Table[i] := Data[i-1];
     for i := 1 to NoDims do DIM[i] := DimSize[i-1];

     Screen(NoDims,MP,MM,ArraySize,TABLE,DIM,
          GSQ,DGFR,PART,MARG,DFS,IP,IM,ISET,JSET,CONFIG,FIT,SIZE,
          COORD,X,Y,IFAULT);

     // show results
     lReport.Add('SCREEN FOR INTERACTIONS AMONG THE VARIABLES');
     lReport.Add('Adapted from the Fortran program by Lustbader and Stodola printed in');
     lReport.Add('Applied Statistics, Volume 30, Issue 1, 1981, pages 97-105 as Algorithm');
     lReport.Add('AS 160 Partial and Marginal Association in Multidimensional Contingency Tables');
     lReport.Add('');
     lReport.Add('Statistics for tests that the interactions of a given order are zero');
     lReport.Add('ORDER     STATISTIC      D.F.       PROB.');
     lReport.Add('-----     ----------     ----     ----------');
     for i := 1 to NoDims do
     begin
          ProbChi2 := 1.0 - ChiSquaredProb(GSQ[i],DGFR[i]);
          lReport.Add('%5d     %10.3f     %4d     %10.3f',[i,GSQ[i],DGFR[i],ProbChi2]);
     end;
     lReport.Add('');
     lReport.Add('Statistics for Marginal Association Tests');
     lReport.Add('VARIABLE     ASSOC.    PART ASSOC.   MARGINAL ASSOC.   D.F.   PROB');
     lReport.Add('--------     ------    -----------   ---------------   ----   ----------');
     for i := 1 to NoDims-1 do
     begin
          for j := 1 to MP do
          begin
               ProbChi2 := 1.0 - ChiSquaredProb(MARG[i,j],DFS[i,j]);
               lReport.Add('%6d        %5d     %10.3f    %12.3f      %3d    %10.3f',
                       [i,j,Part[i,j],MARG[i,j], DFS[i,j],ProbChi2]);
          end;
     end;

     DisplayReport(lReport);

  finally
     lReport.Free;
     TABLE := nil;
     DIM := nil;
     Y := nil;
     X := nil;
     COORD := nil;
     SIZE := nil;
     FIT := nil;
     CONFIG := nil;
     JSET := nil;
     ISET := nil;
     IM := nil;
     IP := nil;
     DFS := nil;
     MARG := nil;
     PART := nil;
     DGFR := nil;
     GSQ := nil;
     M := nil;
     LogM := nil;
     Indexes := nil;
     Expected := nil;
     Margins := nil;
     Data := nil;
     WorkVec := nil;
     GridPos := nil;
     Subscripts := nil;
     DimSize := nil;
     Labels := nil;
  end;
end;

procedure TLogLinScreenFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < SelectList.Items.Count do
  begin
    if SelectList.Selected[i] then
    begin
      VarList.Items.Add(SelectList.Items[i]);
      SelectList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
  UpdateMinMaxGrid;
end;

procedure TLogLinScreenFrm.Screen(var NVAR: integer; var MP: integer;
  var MM: integer; var NTAB: integer; var TABLE: DblDyneVec;
  var DIM: IntDyneVec; var GSQ: DblDyneVec; var DGFR: IntDyneVec;
  var PART: DblDyneMat; var MARG: DblDyneMat; var DFS: IntDyneMat;
  var IP: IntDyneMat; var IM: IntDyneMat; var ISET: IntDyneVec;
  var JSET: IntDyneVec; var CONFIG: IntDyneMat; var FIT: DblDyneVec;
  var SIZE: IntDyneVec; var COORD: IntDyneVec; var X: DblDyneVec;
  var Y: DblDyneVec; var IFAULT: integer);
Label 160, 170;
VAR ISZ, MAX, LIM, I, J, NV1, M, M1, ITP, NP, NP1, L3, DF : integer;
    ZERO, G21, G22, G23, AVG : double;

begin
//      SUBROUTINE SCREEN(NVAR, MP, MM, NTAB, TABLE, DIM, GSQ, DGFR,
//     *   PART, MARG, DFS, IP, IM, ISET, JSET, CONFIG, FIT, SIZE,
//     *   COORD, X, Y, IFAULT)
//
//     ALGORITHM AS 160 APPL. STATIST. (1981) VOL.30, NO.1
//
//     Screen all efects for partial and marginal association.
//
//      INTEGER NVAR, MP, MM, NTAB, IP(NVAR,MP), IM(NVAR,MM), DGFR(NVAR),
//     *   DFS(NVAR,MP), ISET(NVAR), JSET(NVAR), CONFIG(NVAR,MP),
//     *   DIM(NVAR), DF, SIZE(NVAR), COORD(NVAR)
//      REAL GSQ(NVAR), PART(NVAR,MP), MARG(NVAR,MP), TABLE(NTAB),
//     *   FIT(NTAB), X(NTAB), Y(NTAB), ZERO
//      DATA ZERO /0.0/
//
//     Check for input errors
//
      ZERO := 0.0;
      IFAULT := 1;
      IF (NVAR <= 1) then exit;
      ISZ := 1;
      for I := 1 to NVAR do
      begin
           if (DIM[I] <= 1) then IFAULT := 2;
           ISZ := ISZ * DIM[i];
      end;
      IF (ISZ <> NTAB) then IFAULT := 2;
      MAX := 1;
      LIM := NVAR div 2;
      for I := 1 to LIM do MAX := MAX * (NVAR - I + 1) div I;
      IF (MP < MAX) then IFAULT := 3;
      MAX := 1;
      LIM := (NVAR - 1) div 2;
      for I := 1 to LIM do MAX := MAX * (NVAR - I) div I;
      MAX := MAX * NVAR;
      IF (MM < MAX) then IFAULT := 4;
      IF (IFAULT > 1) then exit;
//
//     Fit the no effect model
//
      DGFR[NVAR] := NTAB - 1;
      AVG := ZERO;
      IFAULT := 5;
      for I := 1 to NTAB do
      begin
	       IF (TABLE[I] < ZERO) then exit; //RETURN
	       AVG := AVG + TABLE[I];
      end;
      IFAULT := 0;
      AVG := AVG / NTAB;
      RESET(FIT, NTAB, AVG);
      LIKE(GSQ[1], FIT, TABLE, NTAB);
//
//     Begin fitting effects
//
      NV1 := NVAR - 1;
      for M := 1 to NV1 do
      begin
          //      DO 200 M = 1, NV1
          //
          //     Set up the arrays IP and IM
          //
          M1 := M;
          CONF(NVAR, M1, MP, MM, ISET, JSET, IP, IM, NP);
          //
          //    Fit the saturated model
          //
          RESET(FIT, NTAB, AVG);
          EVAL(IP, NP, M, 1, NVAR, MP, CONFIG, DIM, DGFR[M]);
          LOGFIT(NVAR, NTAB, NP, DIM, CONFIG, TABLE, FIT, SIZE, COORD, X, Y);
          LIKE(GSQ[M+1], FIT, TABLE, NTAB);
          //
          //     Move the first column of IP to the last
          //
          for I := 1 to M do
          begin
               // DO 150 I = 1, M
	       ITP := IP[I,1];
	       NP1 := NP - 1;
           for J := 1 to NP1 do IP[I,J] := IP[I,J+1];
	       IP[I,NP] := ITP;
          end; //  150   CONTINUE
          L3 := -M + 1;
          for J := 1 to NP do
          begin
              //  DO 190 J = 1, NP
              //
              //  Fit the effects in IP ignoring the last column
              //
	      RESET(FIT, NTAB, AVG);
	      EVAL(IP, NP-1, M, 1, NVAR, MP, CONFIG, DIM, DF);
	      LOGFIT(NVAR, NTAB, NP-1, DIM, CONFIG, TABLE, FIT, SIZE, COORD, X, Y);
	      LIKE(G21, FIT, TABLE, NTAB);
	      DFS[M,J] := DGFR[M] - DF;
	      PART[M,J] := G21 - GSQ[M+1];
              //
              //     For M = 1, partials and marginals are equal
              //
  	      IF (M > 1) then GOTO 160;
	      MARG[1,J] := PART[1,J];
	      GOTO 170;
              //
              //     Fit the last column alone
              //
  160:        RESET(FIT, NTAB, AVG);
	      EVAL(IP, 1, M, NP, NVAR, MP, CONFIG, DIM, DF);
	      LOGFIT(NVAR, NTAB, 1, DIM, CONFIG, TABLE, FIT, SIZE,
                     COORD, X, Y);
	      LIKE(G22, FIT, TABLE, NTAB);
              //
              //     Locate the appropriate columns of IM and fit them
              //
	      L3 := L3 + M;
	      RESET(FIT, NTAB, AVG);
	      EVAL(IM, M, M-1, L3, NVAR, MM, CONFIG, DIM, DF);
	      LOGFIT(NVAR, NTAB, M, DIM, CONFIG, TABLE, FIT, SIZE,
                     COORD, X, Y);
	      LIKE(G23, FIT, TABLE, NTAB);
	      MARG[M,J] := G23 - G22;
              //
              //     Move the next effect to be ignored to the last in IP
              //
  170:        for I := 1 to M do // DO 180 I = 1, M
              begin
	           ITP := IP[I,NP];
	           IP[I,NP] := IP[I,J];
	           IP[I,J] := ITP;
              end;
              //  180     CONTINUE
          end; //  190   CONTINUE
          //
          DGFR[NVAR] := DGFR[NVAR] - DGFR[M];
          GSQ[M] := GSQ[M] - GSQ[M+1];
      end; // 200 CONTINUE
end;

procedure TLogLinScreenFrm.CONF(var N: integer; var M: integer;
  var MP: integer; var MM: integer; var ISET: IntDyneVec; var JSET: IntDyneVec;
  var IP: IntDyneMat; var IM: IntDyneMat; var NP: integer);
Label 100, 120;
VAR
     ILAST, JLAST : boolean;
     I, L, NM, JS : integer;
//      SUBROUTINE CONF(N, M, MP, MM, ISET, JSET, IP, IM, NP)
//C
//C     ALGORITHM AS 160.1 APPL. STATIST. (1981) VOL.30, NO.1
//C
//C     Set up the arrays IP and IM for a given N and M.   Essentially
//C     IP contains all possible combinations of (N choose M).   For each
//C     combination found IM contains all combinations of degree M-1.
//C
//      INTEGER ISET(N), JSET(N), IP(N,MP), IM(N,MM)
//      LOGICAL ILAST, JLAST
//C

begin
      ILAST := TRUE;
      NP := 0;
      NM := 0;
      //
      //     Get IP
      //
  100:
      COMBO(ISET, N, M, ILAST);
      IF (ILAST) then exit;
      NP := NP + 1;
      for I := 1 to M do IP[I,NP] := ISET[I];
      IF (M = 1) then GOTO 100;
//
//     Get IM
//
      JLAST := TRUE;
      L := M - 1;
  120:
      COMBO(JSET, M, L, JLAST);
      IF (JLAST) then GOTO 100;
      NM := NM + 1;
      for I := 1 to L do //      DO 130 I = 1, L
      begin
	     JS := JSET[I];
	     IM[I,NM] := ISET[JS];
      end; // 130 CONTINUE
      GOTO 120;
end;

procedure TLogLinScreenFrm.CountVarChkChange(Sender: TObject);
begin
  UpdateMinMaxGrid;
end;

procedure TLogLinScreenFrm.COMBO(var ISET: IntDyneVec; N, M: Integer;
  var LAST: boolean);
label 100, 110, 130, 150;
VAR
	I, K, L : integer;

//      SUBROUTINE COMBO(ISET, N, M, LAST)
//
//     ALGORITHM AS 160.2  APPL. STATIST. (1981) VOL.30, NO.1
//
//     Subroutine to generate all possible combinations of M of the
//     integers from 1 to N in a stepwise fashion.   Prior to the first
//     call, LAST should be set to .FALSE.   Thereafter, as long as LAST
//     is returned .FALSE., a new valid combination has been generated.
//     When LAST goes .TRUE., there are no more combinations.
//
//      LOGICAL LAST
//      INTEGER N, M, ISET(M)
//

begin
      IF (LAST) then GOTO 110;
//
//     Get next element to increment
//
      K := M;
100:  L := ISET[K] + 1;
      IF (L + M - K <= N) then GOTO 150;
      K := K - 1;
//
//     See if we are done
//
      IF (K <= 0) then GOTO 130;
      GOTO 100;
//
//     Initialize first combination
//
110:  for I := 1 to M do ISET[I] := I;
130:  LAST := NOT LAST;
      exit;
//
//     Fill in remainder of combination.
//
150:  for I := K to M do //DO 160 I = K, M
      begin
	     ISET[I] := L;
	     L := L + 1;
      end; //160   CONTINUE
end;

procedure TLogLinScreenFrm.EVAL(var IAR: IntDyneMat; NC, NV, IBEG, NVAR,
  MAX: integer; var CONFIG: IntDyneMat; var DIM: IntDyneVec; var DF: integer);
VAR I, J, K, KK, L : integer;
//      SUBROUTINE EVAL(IAR, NC, NV, IBEG, NVAR, MAX, CONFIG, DIM, DF)
//
//     ALGORITHM AS 160.3 APPL. STATIST. (1981) VOL.30, NO.1
//
//     IAR  = array containing the effects to be fitted
//     NC   = number of columns of IAR to be used
//     NV   = number of variables in each effect
//     IBEG = gebinning column
//     DF   = degrees of freedom
//
//     CONFIG is in a format compatible with algorithm AS 51
//
//      INTEGER IAR(NVAR,MAX), CONFIG(NVAR,NC), DIM(NVAR), DF
//
begin
      DF := 0;
      for J := 1 to NC do //DO 110 J = 1, NC
      begin
	     KK := 1;
	     for I := 1 to NV do //DO 100 I = 1, NV
             begin
	          L := IBEG + J - 1;
	          K := IAR[I,L];
	          KK := KK * (DIM[K] - 1);
	          CONFIG[I,J] := K;
             end; // 100   CONTINUE
	     CONFIG[NV+1,J] := 0;
	     DF := DF + KK;
      end; // 110 CONTINUE
end;

procedure TLogLinScreenFrm.RESET(var FIT: DblDyneVec; NTAB: Integer; AVG: Double
  );
VAR I : integer;

begin
//
//      SUBROUTINE RESET(FIT, NTAB, AVG)
//
//     ALGORITHM AS 160.4 APPL. STATIST. (1981) VOL.30, NO.1
//
//     Initialize the fitted values to the average entry
//
//      REAL FIT(NTAB)
//
      for I := 1 to NTAB do //DO 100 I = 1, NTAB
      begin
	     FIT[I] := AVG;
      end; // 100 CONTINUE
end;

procedure TLogLinScreenFrm.LIKE(var GSQ: Double; var FIT: DblDyneVec;
  var TABLE: DblDyneVec; NTAB: integer);
VAR  I : integer;
     ZERO, TWO : Double;

begin
     ZERO := 0.0;
     TWO := 2.0;
//      SUBROUTINE LIKE(GSQ, FIT, TABLE, NTAB)
//
//     ALGORITHM AS 160.5 APPL. STATIST. (1981) VOL.30, NO.1
//
//     Compute the likelihood-ration chi-square
//
//      REAL FIT(NTAB), TABLE(NTAB), ZERO, TWO
//      DATA ZERO /0.0/, TWO /2.0/
//
      GSQ := ZERO;
      for I := 1 to NTAB do //DO 100 I = 1, NTAB
      begin
	     IF (FIT[I] = ZERO) OR (TABLE[I] = ZERO) then continue; // GO TO 100
	     GSQ := GSQ + TABLE[I] * Ln(TABLE[I] / FIT[I]);
      end; // 100 CONTINUE
      GSQ := TWO * GSQ;
end;

procedure TLogLinScreenFrm.LOGFIT(NVAR, NTAB, NCON: integer;
  var DIM: IntDyneVec; var CONFIG: IntDyneMat; var TABLE: DblDyneVec;
  var FIT: DblDyneVec; var SIZE: IntDyneVec; var COORD: IntDyneVec;
  var X: DblDyneVec; var Y: DblDyneVec);
LABEL 110, 130, 150, 170, 180, 200;
VAR
     II, K, KK, L, N, J, I : integer;
     OPTION : boolean;
     MAXDEV, ZERO, XMAX, E : double;
     MAXIT, NV1, ISZ : integer;

begin
//      SUBROUTINE LOGFIT(NVAR, NTAB, NCON, DIM, CONFIG, TABLE, FIT, SIZE,
//     *     COORD, X, Y)
//
//     ALGORITHM AS 160.6 APPL. STATIST. (1981) VOL.30, NO.1
//
//     Iterative proportional fitting of the marginals of a contingency
//     table.   Relevant code from AS 51 is used.
//
//      REAL TABLE(NTAB), FIT(NTAB), MAXDEV, X(NTAB), Y(NTAB), ZERO
//      INTEGER CONFIG(NVAR,NCON), DIM(NVAR), SIZE(NVAR), COORD(NVAR)
//      LOGICAL OPTION
//      DATA MAXDEV /0.25/, MAXIT /25/, ZERO /0.0/

      MAXDEV := 0.25;
      ZERO := 0.0;
      MAXIT := 25;
      for KK := 1 to MAXIT do //DO 230 KK = 1, MAXIT
      begin
           //
           //     XMAX is the maximum deviation between fitted and true marginal
           //
	     XMAX := ZERO;
	     for II := 1 to NCON do //DO 220 II = 1, NCON
             begin
	          OPTION := TRUE;
                  //
                  //     Initialize arrays
                  //
	          SIZE[1] := 1;
	          NV1 := NVAR - 1;
	          for K := 1 to NV1 do //DO 100 K = 1, NV1
                  begin
	               L := CONFIG[K,II];
	               IF (L = 0) then GOTO 110;
	               SIZE[K+1] := SIZE[K] * DIM[L];
                  end; // 100     CONTINUE
	          K := NVAR;
  110:            N := K - 1;
	          ISZ := SIZE[K];
	          for J := 1 to ISZ do //DO 120 J = 1, ISZ
                  begin
	               X[J] := ZERO;
	               Y[J] := ZERO;
                  end; // 120     CONTINUE
                  //
                  //     Initialize co-ordinates
                  //
  130:            for K := 1 to NVAR do COORD[K] := 0;
                  //
                  //     Find locations in tables
                  //
                  I := 1;
  150:            J := 1;
                  for K := 1 to N do //DO 160 K = 1, N
                  begin
	               L := CONFIG[K,II];
	               J := J + COORD[L] * SIZE[K];
                  end; //160     CONTINUE
                  IF (NOT OPTION) then GOTO 170;
                  //
                  //     Compute marginals
                  //
	          X[J] := X[J] + TABLE[I];
	          Y[J] := Y[J] + FIT[I];
	          GOTO 180;
                  //
                  //     Make adjustments
                  //
  170:            IF (Y[J] <= ZERO) then FIT[I] := ZERO;
                  IF (Y[J] > ZERO) then FIT[I] := FIT[I] * X[J] / Y[J];
                  //
                  //     Update co-ordinates
                  //
  180:            I := I + 1;
	          for K := 1 to NVAR do //DO 190 K = 1, NVAR
                  begin
	               COORD[K] := COORD[K] + 1;
	               IF (COORD[K] < DIM[K]) then GOTO 150;
	               COORD[K] := 0;
                  end; //190     CONTINUE
	          IF (NOT OPTION) then GOTO 200;
	          OPTION := FALSE;
	          GOTO 130;
                  //
                  //     Find the largest deviation
                  //
  200:            for I := 1 to ISZ do //DO 210 I = 1, ISZ
                  begin
	               E := ABS(X[I] - Y[I]);
	               IF (E > XMAX) then XMAX := E;
                  end; // 210     CONTINUE
             end; // 220   CONTINUE
             //
             //     Test convergence
             //
	     IF (XMAX < MAXDEV) then exit;
      end; // 230 CONTINUE
end;

procedure TLogLinScreenFrm.MaxCombos(NumDims: integer; out MM, MP: integer);
var
  combos: integer;
  i,j: integer;
begin
  MM := 0;
  MP := 0;
  for i := 1 to NumDims do
  begin
    combos := 1;

    // get numerator factorial products down to i
    for j := NumDims downto i + 1 do
      combos := combos * j;

    // divide by factorial of NumDims - i;
    for j := (NumDims - i) downto 2 do
      combos := combos div j;

    if combos > MP then
      MP := combos;
    if i * combos > MM then
      MM := i * combos;
  end;
end;

function TLogLinScreenFrm.ArrayPosition(NumDims: integer;
  const Data: DblDyneVec; const Subscripts, DimSize: IntDyneVec): integer;
var
  Pos         : integer;
  i, j        : integer;
  PriorSizes  : IntDyneVec;
begin
  // allocate space for PriorSizes
  SetLength(PriorSizes, NumDims);

  // calculate PriorSizes values
  for i := 0 to NumDims - 2 do
    PriorSizes[i] := 1; // initialize

  for i := NumDims - 2 downto 0 do
    for j := 0 to i do PriorSizes[i] := PriorSizes[i] * DimSize[j];

  Pos := Subscripts[0] - 1;
  for i := 0 to NumDims - 2 do
    Pos := Pos + (PriorSizes[i] * (Subscripts[i+1]-1));

  Result := Pos;
  PriorSizes := nil;
end;

procedure TLogLinScreenFrm.Marginals(NumDims, ArraySize: integer;
  const Indexes: IntDyneMat; const Data: DblDyneVec; const Margins: IntDyneMat);
var
  i, j, category: integer;
begin
  for i := 1 to ArraySize do
  begin
    for j := 1 to NumDims do
    begin
      category := Indexes[i-1,j-1];
      Margins[j-1,category-1] := Margins[j-1,category-1] + Round(Data[i-1]);
    end;
  end;
end;

procedure TLogLinScreenFrm.UpdateBtnStates;
begin
  InBtn.Enabled := AnySelected(VarList);
  OutBtn.Enabled := AnySelected(SelectList);
  AllBtn.Enabled := VarList.Items.Count > 0;
end;

procedure TLogLinScreenFrm.UpdateMinMaxGrid;
var
  NumDims, j: Integer;
begin
  if CountVarChk.Checked then
    NumDims := SelectList.Count - 1
  else
    NumDims := SelectList.Count;
  if NumDims < 0 then NumDims := 0;
  MinMaxGrid.RowCount := NumDims + 1;
  for j := 1 to MinMaxGrid.RowCount-1 do
  begin
    MinMaxGrid.Cells[0, j] := SelectList.Items[j-1];
    MinMaxGrid.Cells[1, j] := '';
    MinMaxGrid.Cells[2, j] := '';
  end;
end;

procedure TLogLinScreenFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I loglinscreenunit.lrs}

end.

