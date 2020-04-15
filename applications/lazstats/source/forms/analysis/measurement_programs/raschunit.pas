// File for testing: itemdata2.laz
// Select the variables VAR1...VAR5

unit RaschUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, GraphLib, Globals,
  DataProcs, ContextHelpUnit;

type

  { TRaschFrm }

  TRaschFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    ProxChk: TCheckBox;
    PlotItemsChk: TCheckBox;
    PlotScrsChk: TCheckBox;
    ItemInfoChk: TCheckBox;
    TestInfoChk: TCheckBox;
    GroupBox1: TGroupBox;
    InBtn: TBitBtn;
    Label2: TLabel;
    ItemList: TListBox;
    OutBtn: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
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

    procedure Analyze(const itemfail, grpfail: IntDyneVec;
      const f: IntDyneMat; var T: integer; const grppass, itempass: IntDyneVec;
      r, C1: integer; out min, max: double; const p2: DblDyneVec);
    procedure Expand(v1, v2: double; out xExpand, yExpand: Double);
    procedure FinishIt(r: integer; const i5: IntDyneVec;
      const rptbis, rbis, slope, mean: DblDyneVec;
      const itemfail: IntDyneVec; const P: DblDyneVec; AReport: TStrings);
    procedure Frequencies(C1, r: integer; const f: IntDyneMat;
      const rowtot, i5, s5: IntDyneVec; T: integer; const S: IntDyneVec;
      AReport: TStrings);
    procedure GetLogs(const L, L1, L2, g, g2, f2: DblDyneVec;
      const rowtot: IntDyneVec; k: integer; const s5, S: IntDyneVec;
      T, r, C1: integer; var v1, v2: double; AReport: TStrings);
    procedure GetScores(NoSelected: integer; const Selected: IntDyneVec;
      NoCases: integer; const f: IntDyneMat; const Mean, XSqr, SumXY: DblDyneVec;
      const S, X: IntDyneVec; out sumx, sumx2: double; var N: integer;
      AReport: TStrings);
    procedure Maxability(const expdcnt, d2, e2: DblDyneVec; const p1: DblDyneMat;
      const p2, P: DblDyneVec; C1, r: integer; const D: DblDyneMat;
      const s5: IntDyneVec; noloops: integer; AReport: TStrings);
    function MaxItem(const R1, d1: DblDyneVec; const p1, D: DblDyneMat;
      const e1, p2, P: DblDyneVec; const S, rowtot: IntDyneVec;
      T, r, C1 : integer) : double;
    procedure MaxOut(r, C1: integer; const i5, s5: IntDyneVec;
      const P, p2: DblDyneVec; AReport: TStrings);
    procedure Prox(const P,  p2: DblDyneVec; k, r, C1: integer;
      const L1: DblDyneVec; yexpand, xexpand: double; const g: DblDyneVec;
      T: integer; const rowtot, i5, s5: IntDyneVec; AReport: TStrings);
    function Reduce(k: integer; out r, T, C1: integer;
      const i5, rowtot, s5: IntDyneVec; const f: IntDyneMat; const S: IntDyneVec;
      AReport: TStrings): integer;
    procedure Slopes(const rptbis, rbis, slope: DblDyneVec; N: integer;
      sumx, sumx2: double; const sumxy: DblDyneVec; r: integer;
      const xsqr, mean: DblDyneVec);
    procedure TestFit(r, C1: integer; const f: IntDyneMat; const S: IntDyneVec;
      const P, P2: DblDyneVec; T: integer; AReport: TStrings);

    procedure PlotInfo(k, r: integer; const Info, A: DblDyneMat;
      const Slope, P: DblDyneVec);
    procedure Plot(const xyArray: DblDyneMat; ArraySize: integer;
      const Title: string; Vdivisions, Hdivisions: integer);
    procedure PlotItems(r: integer; const i5: IntDyneVec; const P: DblDyneVec);
    procedure PlotScrs(C1: integer; const s5: IntDyneVec; const p2: DblDyneVec);
    procedure PlotTest(const TestInfo: DblDyneMat; ArraySize: integer;
      const Title: string; Vdivisions, Hdivisions: integer);
  public
    { public declarations }
  end; 

var
  RaschFrm: TRaschFrm;

implementation

uses
  Math, Utils;

{ TRaschFrm }

procedure TRaschFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  ItemList.Clear;
  ProxChk.Checked := false;
  PlotItemsChk.Checked := false;
  PlotScrsChk.Checked := false;
  ItemInfoChk.Checked := false;
  TestInfoChk.Checked := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TRaschFrm.FormActivate(Sender: TObject);
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

procedure TRaschFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TRaschFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TRaschFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TRaschFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k1, N, C1, r, T,noloops : integer;
   sumx, sumx2, v1, v2, xexpand, yexpand, d9, min, max : double;
   X, rowtot, itemfail, itempass, grpfail, grppass, S, s5, i5 : IntDyneVec;
   f : IntDyneMat;
   mean, xsqr, sumxy, L, L1, L2, g, g2, f2, P, p2, R1, d1, e1 : DblDyneVec;
   expdcnt, d2 : DblDyneVec;
   e2, rptbis, rbis, slope : DblDyneVec;
   p1, D, info, A : DblDyneMat;
   NoSelected : integer;
   ColNoSelected : IntDyneVec;
   finished : boolean;
   cellstring : string;
   error : integer;
   lReport: TStrings;
begin
   SetLength(ColNoSelected,NoVariables);
   SetLength(mean,NoVariables);
   SetLength(xsqr,NoVariables);
   SetLength(sumxy,NoVariables);
   SetLength(L,NoVariables);
   SetLength(L1,NoVariables);
   SetLength(L2,NoVariables);
   SetLength(g,NoVariables);
   SetLength(g2,NoVariables);
   SetLength(f2,NoVariables);
   SetLength(P,NoVariables);
   SetLength(p2,NoVariables);
   SetLength(R1,NoVariables);
   SetLength(d1,NoVariables);
   SetLength(e1,NoVariables);
   SetLength(expdcnt,NoVariables);
   SetLength(d2,NoVariables);
   SetLength(e2,NoVariables);
   SetLength(rptbis,NoVariables);
   SetLength(rbis,NoVariables);
   SetLength(slope,NoVariables);
   SetLength(p1,NoVariables,NoVariables);
   SetLength(D,NoVariables,NoVariables);
   SetLength(info,52,52);
   SetLength(A,52,2);
   SetLength(X,NoVariables);
   SetLength(rowtot,NoVariables);
   SetLength(itemfail,NoVariables);
   SetLength(itempass,NoVariables);
   SetLength(grpfail,NoVariables);
   SetLength(grppass,NoVariables);
   SetLength(S,NoVariables+2);
   SetLength(s5,NoVariables);
   SetLength(i5,NoVariables);
   SetLength(f,NoVariables+2,NoVariables+2);
   if (NoVariables < 1) then
   begin
    	MessageDlg('You must have data in your data grid.', mtError, [mbOK], 0);
        exit;
   end;

   // Get selected variables
   NoSelected := ItemList.Items.Count;
   for i := 1 to NoSelected do
   begin
        for j := 1 to NoVariables do
        begin
             cellstring := OS3MainFrm.DataGrid.Cells[j,0];
             if cellstring = ItemList.Items.Strings[i-1] then
                  ColNoSelected[i-1] := j;
        end;
   end;

   //begin ( main program )
   finished := false;
   N := NoCases;
   k1 := NoSelected;

   lReport := TStringList.Create;
   try
     GetScores(NoSelected, ColNoSelected, NoCases, f, mean, xsqr, sumxy, S, X, sumx, sumx2, N, lReport);
     error := Reduce(k1, r, T, C1, i5, rowtot, s5, f, S, lReport);
     if error = 1 then
       exit;

     Frequencies(C1, r, f, rowtot, i5, s5, T, S, lReport);
     v1 := 0.0;
     v2 := 0.0;
     GetLogs(L, L1, L2, g, g2, f2, rowtot, k1, s5, S, T, r, C1, v1, v2, lReport);
     Expand(v1, v2, xexpand, yexpand);
     Prox(P, p2, k1, r, C1, L1, yexpand, xexpand, g, T, rowtot, i5, s5, lReport);
     // start iterations for the maximum-likelihood (SetLengthton-Rhapson procedure)
     // estimates
     noloops := 0;

     while (not finished) do
     begin
       d9 := MaxItem(R1, d1, p1, D, e1, p2, P, S, rowtot, T, r, C1);
       if (d9 < 0.01) then
         finished := true
       else
         Maxability(expdcnt, d2, e2, p1, p2, P, C1, r, D, s5, noloops, lReport);
           noloops := noloops + 1;
           if (noloops > 25) then
           begin
             MessageDlg('Maximum Likelihood failed to converge after 25 iterations', mtInformation, [mbOK], 0);
             finished := true;
           end;
     end;
     MaxOut(r, C1, i5, s5, P, p2, lReport);
     TestFit(r, C1, f, S, P, p2, T, lReport);
     Slopes(rptbis, rbis, slope, N, sumx, sumx2, sumxy, r, xsqr, mean);
     Analyze(itemfail, grpfail, f, T, grppass, itempass, r, C1, min, max, p2);

     if PlotItemsChk.Checked then PlotItems(r, i5, P);
     if PlotScrsChk.Checked then PlotScrs(C1, s5, p2);
     if TestInfoChk.Checked then PlotInfo(k1, r, info, A, slope, P);

     FinishIt(r, i5, rptbis, rbis, slope, mean, itemfail, P, lReport);

     DisplayReport(lReport);

   finally
      // cleanup
      lReport.Free;
      A := nil;
      info := nil;
      D := nil;
      p1 := nil;
      f := nil;
      grppass := nil;
      grpfail := nil;
      itempass := nil;
      itemfail := nil;
      i5 := nil;
      s5 := nil;
      S := nil;
      sumxy := nil;
      xsqr := nil;
      mean := nil;
      rowtot := nil;
      X := nil;
      d1 := nil;
      R1 := nil;
      p2 := nil;
      P := nil;
      f2 := nil;
      g2 := nil;
      g := nil;
      L2 := nil;
      L1 := nil;
      L := nil;
      e1 := nil;
      expdcnt := nil;
      d2 := nil;
      e2 := nil;
      slope := nil;
      rbis := nil;
      rptbis := nil;
      ColNoSelected := nil;
   end;
end;

procedure TRaschFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      ItemList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TRaschFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < ItemList.Items.Count do
  begin
    if ItemList.Selected[i] then
    begin
      VarList.Items.Add(ItemList.Items[i]);
      ItemList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TRaschFrm.Analyze(const itemfail, grpfail: IntDyneVec;
  const f: IntDyneMat; var T: integer; const grppass, itempass: IntDyneVec;
  r, C1: integer; out min, max: double; const p2: DblDyneVec);
var
  i, j: integer;
begin
  for i := 0 to r-1 do itemfail[i] := 0;
  for j := 0 to C1-1 do grpfail[j] := 0;
  for i := 0 to r-1 do
  begin
    for j := 0 to C1-1 do
    begin
      grpfail[j] := grpfail[j] + f[i,j];
      itemfail[i] := itemfail[i] + f[i,j];
    end;
  end;
  T := 0;
  for j := 0 to C1-1 do T := T + grpfail[j];
  for j := 0 to C1-1 do grppass[j] := T - grpfail[j];
  for i := 0 to r-1 do itempass[i] := T - itemfail[i];
  min := p2[0];
  max := p2[0];
  for i := 0 to C1-1 do
  begin
    if (p2[i] < min) then min := p2[i];
    if (p2[i] > max) then max := p2[i];
  end;
end;

procedure TRaschFrm.Expand(v1, v2: double; out xExpand, yExpand: Double);
begin
  yExpand := sqrt( (1.0 + (v2 / 2.89)) / (1.0 - (v1 * v2 / 8.35)) );
  xExpand := sqrt( (1.0 + (v1 / 2.89)) / (1.0 - (v1 * v2 / 8.35)) );
end;

procedure TRaschFrm.FinishIt(r: integer; const i5: IntDyneVec;
  const rptbis, rbis, slope, mean: DblDyneVec; const itemfail: IntDyneVec;
  const P: DblDyneVec; AReport: TStrings);
var
  i: integer;
begin
  AReport.Add('');
  AReport.Add('Item Data Summary');
  AReport.Add('');
  AReport.Add('ITEM  PT.BIS.R.  BIS.R.  SLOPE   PASSED  FAILED  RASCH DIFF');
  AReport.Add('----  ---------  ------  -----   ------  ------  ----------');
             //xxx     xxxxxx   xxxxxx  xxxxx   xxxxxx   xxxx     xxxxxx
  for i := 0 to r-1 do
    AReport.Add('%3d     %6.3f   %6.3f  %5.2f   %6.2f   %4d     %6.3f', [
      i5[i], rptbis[i], rbis[i], slope[i], mean[i], itemfail[i], P[i]
    ]);
  AReport.Add('');
end;

procedure TRaschFrm.Frequencies(C1, r: integer;
  const f: IntDyneMat; const rowtot, i5, s5: IntDyneVec; T: integer;
  const S: IntDyneVec; AReport: TStrings);
var
  i, j, c2, c3: integer;
  done: boolean;
  outline: string;
begin
  done := false;
  c3 := C1;
  c2 := 1;
  if (c3 > 16) then
    c3 := 16;

  while not done do
  begin
    AReport.Add('Matrix of Item Failures in Score Groups');
    outline := '   Score Group';
    for j := c2 to c3 do
        outline := outline + Format('%4d', [s5[j-1]]);
    outline := outline + '     Total';
    AReport.Add(outline);

    AReport.Add('ITEM' );
    AReport.Add('');
    for i := 1 to r do
    begin
      outline := Format('%4d          ', [i5[i-1]]);
      for j := c2 to c3 do
        outline := outline + Format('%4d', [f[i-1, j-1]]);
      outline := outline + Format('%7d', [rowtot[i-1]]);
      AReport.Add(outline);
    end;

    outline := 'Total         ';
    for j := c2 to c3 do
      outline := outline + Format('%4d', [S[j-1]]);
    outline := outline + Format('%7d', [T]);
    AReport.Add(outline);
    AReport.Add( '');

    if (c3 = C1) then
      done := true
    else begin
      c2 := c3 + 1;
      c3 := c2 + 15;
      if (c3 > C1) then c3 := C1;
    end;
  end; // end while not done
end; // end sub frequencies

procedure TRaschFrm.GetLogs(const L, L1,L2, g, g2, f2: DblDyneVec;
  const rowtot: IntDyneVec; k : integer; const s5, S: IntDyneVec;
  T, r, C1 : integer; var v1, v2: Double; AReport: TStrings);
var
  tx, rowtx, rx, t2, t3, e : double;
  i, j : integer;
begin
  t2 := 0.0;
  tx := T;
  rx := r;
  for i := 0 to r-1 do
  begin
    rowtx := rowtot[i];
    L[i] := ln(rowtx / (tx - rowtx));
    t2 := t2 + L[i];
  end;
  t2 := t2 / rx;
  for i := 0 to r-1 do
  begin
    L1[i] := L[i] - t2;
    L2[i] := L1[i] * L1[i];
    v1 := v1 + L2[i];
  end;
  v1 := v1 / rx;

  AReport.Add('Item  Log Odds  Deviation  Squared Deviation');
  AReport.Add('----  --------  ---------  -----------------');
             //xxxx   xxxxxx    xxxxxx         xxxxxx
  for i := 0 to r-1 do
    AReport.Add('%4d   %6.2f    %6.2f         %6.2f', [i+1, L[i], L1[i], L2[i]]);

  t3 := 0.0;
  v2 := 0.0;
  for j := 0 to C1-1 do
  begin
    e := s5[j];
    g[j] := ln(e / (k - e));
    g2[j] := S[j] * g[j];
    t3 := t3 + g2[j];
    f2[j] := S[j] * (g[j] * g[j]);
    v2 := v2 + f2[j];
  end;
  t3 := t3 / tx;
  v2 := v2 / (tx - (t3 * t3));

  AReport.Add('');
  AReport.Add('Score  Frequency  Log Odds  Freq.x Log  Freq.x Log Odds Squared');
  AReport.Add('-----  ---------  --------  ----------  -----------------------');
             // xxx      xxx      xxxxxx     xxxxx             xxxxxx
  for j := 0 to C1-1 do
    AReport.Add(' %3d      %3d      %6.2f     %6.2f             %6.2f', [s5[j], S[j], g[j], g2[j], f2[j]]);
  AReport.Add('');
end;

procedure TRaschFrm.GetScores(NoSelected: integer; const Selected: IntDyneVec;
  NoCases: integer; const f: IntDyneMat; const Mean, XSqr, SumXY: DblDyneVec;
  const S, X: IntDyneVec; out sumx, sumx2: double; var N: integer;
  AReport: TStrings);
var
  i, j, k1, T, item: integer;
  outline: string;
begin
   AReport.Add('RASCH ONE-PARAMETER LOGISTIC TEST SCALING (ITEM RESPONSE THEORY)');
   AReport.Add('Written by William G. Miller');
   AReport.Add('');

   k1 := NoSelected;
   for i := 1 to k1 do
   begin
     for j := 1 to k1 + 2 do
       f[i-1,j-1] := 0;
     Mean[i-1] := 0.0;
     XSqr[i-1] := 0.0;
     SumXY[i-1] := 0.0;
   end;
   for j := 1 to k1 + 2 do
     S[j-1] := 0;
   N := 0;
   SumX := 0.0;
   SumX2 := 0.0;

   // Read each case and scores for each item.  Eliminate rows (subjects)
   // that have a total score of zero or all items correct
   for i := 1 to NoCases do
   begin
     if not GoodRecord(i, NoSelected, Selected) then
       continue;

     T := 0;
     for j := 1 to k1 do
     begin
       item := Selected[j-1];
       X[j-1] := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[item,i])));
       T := T + X[j-1];
     end;

     if (T < k1) and (T > 0) then
     begin
       outline := format('Case %3d:  Total Score: %3d  Item scores', [i, T]);
       SumX := SumX + T;
       SumX2 := SumX2 + T * T;
       for j := 0 to k1-1 do
       begin
         Mean[j] := Mean[j] + X[j];
         XSqr[j] := XSqr[j] + X[j] * X[j];
         SumXY[j] := SumXY[j] + X[j] * T;
         outline := outline + Format('%2d', [X[j]]);
         if (X[j] = 0) then
           f[j,T-1] := f[j,T-1] + 1;
       end;
       AReport.Add(outline);

       S[T-1] := S[T-1] + 1;
       N := N + 1;
     end else
       AReport.Add('Case %3d eliminated.  Total score was %3d', [i, T]);
   end;
   AReport.Add('');
end;

procedure TRaschFrm.Maxability(const expdcnt, d2, e2: DblDyneVec;
  const p1: DblDyneMat; const p2, P: DblDyneVec; C1, r: integer;
  const D: DblDyneMat; const s5: IntDyneVec; noloops: integer; AReport: TStrings);
var
  i, j: integer;
  d9: double;
begin
  d9 := 0.0;
  AReport.Add('Maximum Likelihood Iteration Number %d', [noloops]);
  for j := 0 to C1-1 do
  begin
    expdcnt[j] := 0.0;
    d2[j] := 0.0;
  end;
  for i := 0 to r-1 do
    for j := 0 to C1-1 do
      p1[i,j] := exp(p2[j] - P[i]) / (1.0 + exp(p2[j] - P[i]));
  for j := 0 to C1-1 do
    for i := 0 to r-1 do
    begin
      expdcnt[j] := expdcnt[j] + p1[i,j];
      // expected number in score group
      D[i,j] := exp(p2[j] - P[i]) / (sqrt(1.0 + exp(p2[j] - P[i])));
      d2[j] := d2[j] + D[i,j]; // rate of change value
    end;
  for j := 0 to C1-1 do
  begin
    e2[j] := expdcnt[j] - s5[j];  // discrepency
    e2[j] := e2[j] / d2[j];
    if (abs(e2[j]) > d9) then d9 := abs(e2[j]);
    p2[j] := p2[j] - e2[j];
  end;
{    Debug check in old sample program
	'     writeln
	'     writeln('Actual and Estimated Scores')
	'     writeln
	'     writeln('Score  Estimated  Adjustment')
	'     for j := 1 to c1 do
	'         writeln(s5(j):3,'   ',expdcnt(j):6:2,'       ',e2(j):6:2)
	'     writeln
}
end; // end of maxability

function TRaschFrm.MaxItem(const R1, d1: DblDyneVec; const p1, D: DblDyneMat;
  const e1, p2, P: DblDyneVec; const S, rowtot: IntDyneVec;
  T, r, C1: integer): double;
var
  i, j: integer;
  d9: double;
begin
  d9 := 0.0;
  for i := 0 to r-1 do
  begin
    R1[i] := 0.0;
    d1[i] := 0.0;
  end;
  for i := 0 to r-1 do
    for j := 0 to C1-1 do
      p1[i,j] := exp(p2[j] - P[i]) / (1.0 + exp(p2[j] - P[i]));
  for i := 0 to r-1 do
  begin
    for j := 0 to C1-1 do R1[i] := R1[i] + S[j] * p1[i,j];
    e1[i] := R1[i] - (T - rowtot[i]);
  end;

  // e1(i) contains the difference between actual and expected passes
  // now calculate derivatives and adjustments
  for i := 0 to r-1 do
  begin
    for j := 0 to C1-1 do
    begin
      D[i,j] := exp(p2[j] - P[i]) / (sqrt(1.0 + exp(p2[j] - P[i])));
      d1[i] := d1[i] + (S[j] * D[i,j]);
    end;
    e1[i] := e1[i] / d1[i];

    // adjustment for item difficulty estimates
    if (abs(e1[i]) > d9) then d9 := abs(e1[i]);
    P[i] := P[i] + e1[i];
  end;

{    debug check from old sample program
	'     writeln
	'     writeln('actual and estimated items right')
	'     writeln
	'     writeln('item  actual  estimated  adjustment')
	'     for i := 1 to r do
	'     begin
	'          writeln(i:3,'  ',(t-rowtot(i)):3,'           ',e1(i):6:2)
	'     end
	'     writeln
}

  Result := d9;
end;

procedure TRaschFrm.MAXOUT(r, C1: integer; const i5, s5: IntDyneVec;
  const P, p2: DblDyneVec; AReport: TStrings);
var
  i, j: integer;
begin
  AReport.Add('');
  AReport.Add('Maximum Likelihood Estimates');
  AReport.Add('');

  AReport.Add('Item   Log Difficulty');
  AReport.Add('----   --------------');
             //xxx        xxxxxx
  for i := 0 to r-1 do
    AReport.Add('%3d        %6.2f', [i5[i], P[i]]);

  AReport.Add('');
  AReport.Add('Score   Log Ability');
  AReport.Add('-----   -----------');
             // xxx       xxxxxx
  for j := 0 to C1-1 do
    AReport.Add(' %3d       %6.2f', [s5[j], p2[j]]);
end;

procedure TRaschFrm.Prox(const P, p2: DblDyneVec; k, r, C1 : integer;
  const L1: DblDyneVec; yexpand, xexpand: double; const g: DblDyneVec;
  T: integer; const rowtot, i5, s5: IntDyneVec; AReport: TStrings);
var
  tx, rowtx, errorterm, stdError: double;
  i, j: integer;
begin
  for i := 0 to r-1 do P[i] := L1[i] * yexpand;
  for j := 0 to C1-1 do p2[j] := g[j] * xexpand;

  if not ProxChk.Checked then
    exit;

  AReport.Add('');
  AReport.Add('Prox values and Standard Errors' );
  AReport.Add('');
  AReport.Add('Item   Scale Value   Standard Error');
  AReport.Add('----   -----------   --------------');
             //xxx      xxxxxxx        xxxxxxx

  tx := T;
  for i := 0 to r-1 do
  begin
    rowtx := rowtot[i];
    errorterm := tx / ((tx - rowtx) * rowtx);
    stdError := yexpand * sqrt(errorterm);
    if ProxChk.checked then
      AReport.Add('%3d      %7.3f        %7.3f', [i5[i], P[i], stdError]);
  end;
  AReport.Add('Y expansion factor: %8.4f', [yexpand]);
  AReport.Add('');
  AReport.Add('Score   Scale Value   Standard Error');
  AReport.Add('-----   -----------   --------------');
            //  xxx      xxxxxxx         xxxxxxx

  for j := 0 to C1-1 do
   begin
     stdError := xexpand * sqrt(k / (s5[j] * (k - s5[j])));
     AReport.Add(' %3d      %7.3f         %7.3f', [s5[j], p2[j], stdError]);
   end;
  AReport.Add('X expansion factor: %8.4f', [xexpand]);
  AReport.Add('');
end;

Function TRaschFrm.Reduce(k: integer; out r, T, C1: Integer;
  const i5, RowTot, s5: IntDyneVec; const f: IntDyneMat; const S: IntDyneVec;
  AReport: TStrings): integer;
var
  done: boolean;
  check, i, j, column, row: integer;
begin
  // NOW REDUCE THE MATRIX BY ELIMINATING 0 OR 1 ROWS AND COLUMNS
  AReport.Add('');

  //Store item numbers in i5 array and initialize row totals
  for i := 0 to k-1 do
  begin
    i5[i] := i+1;
    rowtot[i] := 0;
  end;

  //Store group numbers in s5 array
  r := k;
  T := 0;
  C1 := k - 1; // No. of score groups (all correct group eliminated)
  for j := 0 to C1-1 do
  begin
    s5[j] := j+1;
    T := T + S[j];
  end;

  //Get row totals of the failures matrix (item totals)
  for i := 0 to r-1 do
    for j := 0 to C1-1 do rowtot[i] := rowtot[i] + f[i,j];

  // now check for item elimination
  done := false;
  while not done do
  begin
    for i := 1 to r do
    begin
      if (rowtot[i-1] = 0) or (rowtot[i-1] = T) then
      begin
        AReport.Add('Row %3d for item %3d eliminated.', [i, i5[i-1]]);
        if (i < r) then
        begin
          for j := i to r-1 do //move rows up to replace row i
          begin
            for column := 1 to C1 do
              f[j-1, column-1] := f[j, column-1];
              rowtot[j-1] := rowtot[j];
              i5[j-1] := i5[j];
          end;
        end;
        r := r - 1;
      end; // end if
    end; // end for i

    check := 1;
    for i := 0 to r-1 do
      if ((rowtot[i] = 0) or (rowtot[i] = T)) then check := 0;
    if (check = 1) then
      done := true;
  end;

  // check for group elimination
  done := false;
  j := 1;
  while (not done) do
  begin
    if (S[j-1] = 0) then
    begin
      AReport.Add('Column %3d score group %3d eliminated - total group count = %3d', [j, s5[j-1], S[j-1]]);
      if (j < C1) then
      begin
        for i := j to C1 - 1 do
        begin
          for row := 1 to r do
            f[row-1, i-1] := f[row-1, i];
          S[i-1] := S[i];
          s5[i-1] := s5[i];
        end;
        C1 := C1 - 1;
      end
      else
        C1 := C1 - 1;
    end;

    if C1 = 0 then
    begin
      MessageDlg('Too many cases or variables eliminated', mtError, [mbOK], 0);
      DisplayReport(AReport);
      AReport.clear;
      Result := 1;
      exit;
    end;

    if (S[j-1] > 0) then
      j := j + 1;

    if (j >= C1) then
    begin
      while (S[C1-1] <= 0) do
      begin
        C1 := C1 - 1;
        if C1 = 0 then
        begin
          MessageDlg('Too many cases or variables eliminated', mtError, [mbOK], 0);
          DisplayReport(AReport);
          AReport.Clear;
          Result := 1;
          exit;
        end;
      end;
      done := true;
    end;
  end;

  AReport.Add('Total number of score groups: %4d', [C1]);
  AReport.Add('');
  Result := 0;
end; // end of reduce

procedure TRaschFrm.Slopes(const rptbis, rbis, slope: DblDyneVec;
  N: integer; sumx, sumx2: double; const sumxy: DblDyneVec; r: integer;
  const xsqr, mean: DblDyneVec);
var
  propi, term1, term2, z, Y: double;
  j: integer;
begin
  z := 0.0;
  term1 := N * sumx2 - sumx * sumx;
  for j := 0 to r-1 do
  begin
    rptbis[j] := N * sumxy[j] - mean[j] * sumx;
    term2 := N * xsqr[j] - (mean[j] * mean[j]);
    if ((term1 > 0) and (term2 > 0)) then
      rptbis[j] := rptbis[j] / sqrt(term1 * term2)
    else
      rptbis[j] := 1.0;

    propi := mean[j] / N;
    if ((propi > 0.0) and (propi < 1.0)) then
      z := inversez(propi);
    if (propi <= 0.0) then
      z := -3.0;
    if (propi >= 1.0) then
      z := 3.0;

    Y := ordinate(z);
    if (Y > 0) then
      rbis[j] := rptbis[j] * (sqrt(propi * (1.0 - propi)) / Y)
    else
      rbis[j] := 1.0;
    if (rbis[j] <= -1.0) then
      rbis[j] := -0.99999;
    if (rbis[j] >= 1.0) then
      rbis[j] := 0.99999;
    slope[j] := rbis[j] / sqrt(1.0 - (rbis[j] * rbis[j]));
  end;
end; // end of slopes procedure

procedure TRaschFrm.TestFit(r, C1: integer; const f: IntDyneMat;
  const S: IntDyneVec; const P, P2: DblDyneVec; T: integer; AReport: TStrings);
var
  ct, ch, prob: double;
  i, j: integer;
  outline: string;
begin
  AReport.Add('');
  AReport.Add('Goodness of Fit Test for Each Item');
  AReport.Add('');
  AReport.Add('Item  Chi-Squared  Degrees of  Probability');
  AReport.Add('No.   Value        Freedom     of Larger Value');
  AReport.Add('----  -----------  ----------  ---------------');
             //xxxx    xxxxxxx       xxxx         xxxxxx
  ct := 0.0;
  for i := 0 to r-1 do
  begin
    ch := 0.0;
    for j := 0 to C1-1 do
      ch := ch + (exp(p2[j] - P[i]) * f[i,j]) + (exp(P[i] - p2[j]) * (S[j] - f[i,j]));
    prob := 1.0 - chisquaredprob(ch, T - C1);
    outline := format('%4d    %7.2f       %4d         %6.4f', [i+1,ch,(T-C1),prob]);
    AReport.Add(outline);
    ct := ct + ch;
  end;
  AReport.Add('');
end;

procedure TRaschFrm.PlotInfo(k, r : integer; const Info, A: DblDyneMat;
  const Slope, P: DblDyneVec);
var
   min, max, cg, hincrement, Ymax, elg, term1, term2, jx : double;
   headstring, valstring : string;
   i, j, jj, size : integer;
   TestInfo: DblDyneMat;
begin
     min := -3.5;
     max := 3.5;
     size := 0;
     hincrement := (max - min) / 50;
     SetLength(TestInfo, 52,2);
     cg := 0.2;
     Ymax := 0;
     for i := 1 to r do // item loop
     begin
          TestInfo[i-1,0] := 0.0;
          TestInfo[i-1,1] := 0.0;
          jj := 1;
          jx := min;
          while (jx <= (max + hincrement)) do
          begin
               if (slope[i-1] > 30) then slope[i-1] := 30;
               elg := 1.7 * slope[i-1] * (P[i-1] - jx);
               elg := exp(elg);
               term1 := 2.89 * (slope[i-1]) * (1.0 - cg) * (slope[i-1]) * (1.0 - cg);
               term2 := (cg + elg) * (1.0 + 1.0 / elg) * (1.0 + 1.0 / elg);
               info[i-1,jj-1] := term1 / term2;
               if (info[i-1,jj-1] > Ymax) then Ymax := info[i-1,jj-1];
               jj := jj + 1;
               jx := jx + hincrement;
          end;
          size := jj-1;
     end;
     for i := 1 to r do //item loop
     begin
          headstring := 'Item Information Function for Item ';
     	  valstring := format('%3d',[i]);
          headstring := headstring + valstring;
          for j := 1 to size do
          begin
                A[j-1,0] := min + (hincrement * j );
                A[j-1,1] := info[i-1,j-1];
                TestInfo[j-1,1] := TestInfo[j-1,1] + info[i-1,j-1];
          end;
          if ItemInfoChk.Checked then plot(A, size, headstring, 50, 50);
     end;
     for j := 1 to size do TestInfo[j-1,0] := min + (hincrement * j );

     headstring := 'Item Information Function for Test';
     PlotTest(TestInfo,size,headstring,50,50);

     TestInfo := nil;
end; //end of PlotInfo

procedure TRaschFrm.Plot(const xyArray: DblDyneMat; Arraysize: integer;
  const Title: string; Vdivisions, Hdivisions: integer);
var
    i : integer;
    //xvalue, yvalue : DblDyneVec;
begin
    // Allocate space for point sets of means
    //SetLength(xvalue,arraysize);
    //SetLength(yvalue,arraysize);
    SetLength(GraphFrm.Ypoints, 1, ArraySize);
    SetLength(GraphFrm.Xpoints, 1, ArraySize);

    // store points for means
    for i := 0 to ArraySize-1 do
    begin
         GraphFrm.XPoints[0, i] := xyArray[i, 0];
         GraphFrm.YPoints[0, i] := xyArray[i, 1];
         {
         yvalue[i] := xyarray[i,1];
         xvalue[i] := xyarray[i,0];
         GraphFrm.Ypoints[0,i] := yvalue[i];
         GraphFrm.Xpoints[0,i] := xvalue[i];
         }
    end;
    GraphFrm.nosets := 1;
    GraphFrm.nbars := arraysize;
    GraphFrm.Heading := Title;
    GraphFrm.XTitle := 'log ability';
    GraphFrm.YTitle := 'Info';
//    GraphFrm.Ypoints[1] := yvalue;
//    GraphFrm.Xpoints[1] := xvalue;
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := true;
    GraphFrm.GraphType := 5; // 2d line chart
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;

//    xvalue := nil;
//    yvalue := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;  //end plot subroutine

procedure TRaschFrm.PlotItems(r: integer; const i5: IntDyneVec;
  const P: DblDyneVec);
var
   i : integer;
//   xvalues : DblDyneVec;
begin
//    SetLength(xvalues,r);
    SetLength(GraphFrm.Ypoints,1,r);
    SetLength(GraphFrm.Xpoints,1,r);
    for i := 0 to r-1 do
    begin
         GraphFrm.XPoints[0, i] := i5[i];
         GraphFrm.YPoints[0, i] := P[i];
    end;
    {
    for i := 1 to r do
    begin
        xvalues[i-1] := i5[i-1];
        GraphFrm.Xpoints[0,i-1] := xvalues[i-1];
        GraphFrm.Ypoints[0,i-1] := P[i-1];
    end;
    }
    GraphFrm.nosets := 1;
    GraphFrm.nbars := r;
    GraphFrm.Heading := 'LOG DIFFICULTIES FOR ITEMS';
    GraphFrm.XTitle := 'ITEM';
    GraphFrm.YTitle := 'LOG DIFFICULTY';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := true;
    GraphFrm.GraphType := 2; // bar chart
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;

    //xvalues := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;

procedure TRaschFrm.PlotScrs(C1: integer; const s5: IntDyneVec; const
  p2: DblDyneVec);
var
   i: integer;
   //xvalues: DblDyneVec;
begin
    //SetLength(xvalues,C1);
    SetLength(GraphFrm.Ypoints,1,C1);
    SetLength(GraphFrm.Xpoints,1,C1);
    for i := 0 to C1-1 do
    begin
         GraphFrm.XPoints[0, i] := s5[i];
         GraphFrm.YPoints[0, i] := p2[i];
    end;
    {
    for i := 1 to C1 do
    begin
        xvalues[i-1] := s5[i-1];
        GraphFrm.Xpoints[0,i-1] := xvalues[i-1];
        GraphFrm.Ypoints[0,i-1] := p2[i-1];
    end;
    }
    GraphFrm.nosets := 1;
    GraphFrm.nbars := C1;
    GraphFrm.Heading := 'LOG ABILITIES FOR SCORE GROUPS';
    GraphFrm.XTitle := 'SCORE';
    GraphFrm.YTitle := 'LOG ABILITY';
//    GraphFrm.Ypoints[1] := p2;
//    GraphFrm.Xpoints[1] := xvalues;
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := true;
    GraphFrm.GraphType := 2; // bar chart
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;

    //xvalues := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;

procedure TRaschFrm.PlotTest(const TestInfo: DblDyneMat;
  ArraySize: integer; const Title: string; Vdivisions, Hdivisions: integer);
var
    i: integer;
//    xvalue, yvalue: DblDyneVec;
begin
    // Allocate space for point sets of means
    //SetLength(xvalue,arraysize);
    //SetLength(yvalue,arraysize);
    SetLength(GraphFrm.Ypoints, 1, Arraysize);
    SetLength(GraphFrm.Xpoints, 1, Arraysize);

    // store points for means
    for i := 0 to ArraySize-1 do
    begin
         GraphFrm.XPoints[0, i] := TestInfo[i, 0];
         GraphFrm.YPoints[0, i] := TestInfo[i, 1];
    end;
    {
    for i := 1 to arraysize do
    begin
         yvalue[i-1] := TestInfo[i-1,1];
         xvalue[i-1] := TestInfo[i-1,0];
         GraphFrm.Ypoints[0,i-1] := yvalue[i-1];
         GraphFrm.Xpoints[0,i-1] := xvalue[i-1];
    end;
    }
    GraphFrm.nosets := 1;
    GraphFrm.nbars := arraysize;
    GraphFrm.Heading := Title;
    GraphFrm.XTitle := 'log ability';
    GraphFrm.YTitle := 'Info';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := true;
    GraphFrm.GraphType := 5; // 2d line chart
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;

    //xvalue := nil;
    //yvalue := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;  //end plot subroutine

procedure TRaschFrm.UpdateBtnStates;
begin
  InBtn.Enabled := AnySelected(VarList);
  OutBtn.Enabled := AnySelected(ItemList);
end;

procedure TRaschFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I raschunit.lrs}

end.

