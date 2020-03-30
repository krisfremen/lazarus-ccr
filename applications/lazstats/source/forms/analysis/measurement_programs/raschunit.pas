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
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
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
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure ANALYZE(VAR itemfail : IntDyneVec;
                  VAR grpfail : IntDyneVec;
                  VAR f : IntDyneMat;
                  VAR T : integer;
                  VAR grppass : IntDyneVec;
                  VAR itempass : IntDyneVec;
                  r, C1 : integer;
                  VAR min : double;
                  VAR max : double;
                  VAR p2 : DblDyneVec);
    procedure EXPAND(v1, v2 : double;
               VAR xexpand : double;
               VAR yexpand : double);
    procedure FinishIt(r : integer;
                    VAR i5 : IntDyneVec;
                    VAR rptbis : DblDyneVec;
                    VAR rbis : DblDyneVec;
                    VAR slope : DblDyneVec;
                    VAR mean : DblDyneVec;
                    VAR itemfail : IntDyneVec;
                    VAR P : DblDyneVec );
    procedure FREQUENCIES(C1, r : integer;
                      VAR f : IntDyneMat;
                      VAR rowtot : IntDyneVec;
                      VAR i5 : IntDyneVec;
                      VAR s5 : IntDyneVec;
                      T : integer;
                      VAR S : IntDyneVec);
    procedure GETLOGS(VAR L : DblDyneVec;
                            VAR L1 : DblDyneVec;
                            VAR L2 : DblDyneVec;
                            VAR g : DblDyneVec;
                            VAR g2 : DblDyneVec;
                            VAR f2 : DblDyneVec;
                            VAR rowtot : IntDyneVec;
                            k : integer;
                            VAR s5 : IntDyneVec;
                            VAR S : IntDyneVec;
                            T, r, C1 : integer;
                            VAR v1 : double;
                            VAR v2 : double);
    procedure GETSCORES(VAR noselected : integer;
                              VAR selected : IntDyneVec;
                              NoCases : integer;
                              f : IntDyneMat;
                              VAR mean : DblDyneVec;
                              VAR xsqr : DblDyneVec;
                              VAR sumxy : DblDyneVec;
                              VAR S : IntDyneVec;
                              VAR X : IntDyneVec;
                              VAR sumx : double;
                              VAR sumx2 : double;
                              VAR N : integer);
    procedure MAXABILITY(VAR expdcnt : DblDyneVec;
                               VAR d2 : DblDyneVec;
                               VAR e2 : DblDyneVec;
                               VAR p1 : DblDyneMat;
                               VAR p2 : DblDyneVec;
                               VAR P : DblDyneVec;
                               C1, r : integer;
                               D : DblDyneMat;
                               VAR s5 : IntDyneVec;
                               noloops : integer);
    function MAXITEM(VAR R1 : DblDyneVec;
                           VAR d1 : DblDyneVec;
                           VAR p1 : DblDyneMat;
                           VAR D : DblDyneMat;
                           VAR e1 : DblDyneVec;
                           VAR p2 : DblDyneVec;
                           VAR P : DblDyneVec;
                           VAR S : IntDyneVec;
                           VAR rowtot : IntDyneVec;
                           T, r, C1 : integer) : double;
    procedure MAXOUT(r, C1 : integer;
                           VAR i5 : IntDyneVec;
                           VAR s5 : IntDyneVec;
                           VAR P : DblDyneVec;
                           VAR p2 : DblDyneVec);
    procedure PROX(VAR P : DblDyneVec;
                         VAR p2 : DblDyneVec;
                         k, r, C1 : integer;
                         VAR L1 : DblDyneVec;
                         yexpand, xexpand : double;
                         VAR g : DblDyneVec;
                         T : integer;
                         VAR rowtot : IntDyneVec;
                         VAR i5 : IntDyneVec;
                         VAR s5 : IntDyneVec);
    Function REDUCE(k : integer;
                           VAR r : integer;
                           VAR T : integer;
                           VAR C1 : integer;
                           VAR i5 : IntDyneVec;
                           VAR rowtot : IntDyneVec;
                           VAR s5 : IntDyneVec;
                           VAR f : IntDyneMat;
                           VAR S : IntDyneVec) : integer;
    procedure SLOPES(VAR rptbis : DblDyneVec;
                           VAR rbis : DblDyneVec;
                           VAR slope : DblDyneVec;
                           N : integer;
                           sumx, sumx2 : double;
                           VAR sumxy : DblDyneVec;
                           r : integer;
                           VAR xsqr : DblDyneVec;
                           VAR mean : DblDyneVec);
    procedure TESTFIT(r, C1 : integer;
                            VAR f : IntDyneMat;
                            VAR S : IntDyneVec;
                            VAR P : DblDyneVec;
                            VAR p2 : DblDyneVec;
                            T : integer);
    procedure PLOTINFO(k, r : integer;
                             VAR info : DblDyneMat;
                             VAR A : DblDyneMat;
                             VAR slope : DblDyneVec;
                             VAR P : DblDyneVec);
    procedure plot(VAR xyarray : DblDyneMat;
                         arraysize : integer;
                         Title : string;
                         Vdivisions, Hdivisions : integer);
    procedure PlotItems(r : integer; i5 : IntDyneVec; P : DblDyneVec);
    procedure PlotScrs(C1 : integer; s5 : IntDyneVec; p2 : DblDyneVec);
    procedure PlotTest(VAR TestInfo : DblDyneMat;
                         arraysize : integer;
                         Title : string;
                         Vdivisions, Hdivisions : integer);
  public
    { public declarations }
  end; 

var
  RaschFrm: TRaschFrm;

implementation

uses
  Math;

{ TRaschFrm }

procedure TRaschFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     ItemList.Clear;
     OutBtn.Enabled := false;
     InBtn.Enabled := true;
     ProxChk.Checked := false;
     PlotItemsChk.Checked := false;
     PlotScrsChk.Checked := false;
     ItemInfoChk.Checked := false;
     TestInfoChk.Checked := false;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TRaschFrm.FormActivate(Sender: TObject);
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
    	  ShowMessage('ERROR! You must have data in your data grid!');
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

     GETSCORES(NoSelected, ColNoSelected, NoCases, f, mean, xsqr, sumxy, S, X,
                sumx, sumx2, N);
     error := REDUCE(k1, r, T, C1, i5, rowtot, s5, f, S);
     if error = 1 then exit;
     FREQUENCIES(C1, r, f, rowtot, i5, s5, T, S );
     v1 := 0.0;
     v2 := 0.0;
     GETLOGS(L, L1, L2, g, g2, f2, rowtot, k1, s5, S, T, r, C1, v1, v2);
     EXPAND(v1, v2, xexpand, yexpand);
     PROX(P, p2, k1, r, C1, L1, yexpand, xexpand, g, T, rowtot, i5, s5);
     // start iterations for the maximum-liklihood (SetLengthton-Rhapson procedure)
     // estimates
     noloops := 0;

     while (not finished) do
      begin
      	   d9 := MAXITEM(R1, d1, p1, D, e1, p2, P, S, rowtot, T, r, C1);
           if (d9 < 0.01) then finished := true
           else	MAXABILITY(expdcnt, d2, e2, p1, p2, P, C1, r, D, s5, noloops);
           noloops := noloops + 1;
           if (noloops > 25) then
           begin
               ShowMessage('WARNING! Maximum Liklihood failed to converge after 25 iterations');
            	finished := true;
           end;
      end;
      MAXOUT(r, C1, i5, s5, P, p2);
      TESTFIT(r, C1, f, S, P, p2, T);
      SLOPES(rptbis, rbis, slope, N, sumx, sumx2, sumxy, r, xsqr, mean);
      ANALYZE(itemfail, grpfail, f, T, grppass, itempass, r, C1, min, max, p2);
      if PlotItemsChk.Checked then PlotItems(r, i5, P);
      if PlotScrsChk.Checked then PlotScrs(C1, s5, p2);
      PLOTINFO(k1, r, info, A, slope, P);
      FinishIt(r, i5, rptbis, rbis, slope, mean, itemfail, P);

      // cleanup
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

procedure TRaschFrm.InBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            ItemList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     OutBtn.Enabled := true;

end;

procedure TRaschFrm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := ItemList.ItemIndex;
     if index < 0 then
     begin
          OutBtn.Enabled := false;
          exit;
     end;
     VarList.Items.Add(ItemList.Items.Strings[index]);
     ItemList.Items.Delete(index);
end;

procedure TRaschFrm.ANALYZE(VAR itemfail : IntDyneVec;
                  VAR grpfail : IntDyneVec;
                  VAR f : IntDyneMat;
                  VAR T : integer;
                  VAR grppass : IntDyneVec;
                  VAR itempass : IntDyneVec;
                  r, C1 : integer;
                  VAR min : double;
                  VAR max : double;
                  VAR p2 : DblDyneVec);
var
   i, j : integer;

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
end;  // End Sub 'end analyze procedure

procedure TRaschFrm.EXPAND(v1, v2 : double;
               VAR xexpand : double;
               VAR yexpand : double);
begin
     yexpand := sqrt( (1.0 + (v2 / 2.89)) / (1.0 - (v1 * v2 / 8.35)) );
     xexpand := sqrt( (1.0 + (v1 / 2.89)) / (1.0 - (v1 * v2 / 8.35)) );
end; //End Sub 'end of expand

procedure TRaschFrm.FinishIt(r : integer;
                    VAR i5 : IntDyneVec;
                    VAR rptbis : DblDyneVec;
                    VAR rbis : DblDyneVec;
                    VAR slope : DblDyneVec;
                    VAR mean : DblDyneVec;
                    VAR itemfail : IntDyneVec;
                    VAR P : DblDyneVec );
var
   i : integer;
   outline : string;
begin
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Item Data Summary');
     OutputFrm.RichEdit.Lines.Add( 'ITEM  PT.BIS.R.  BIS.R.  SLOPE   PASSED  FAILED  RASCH DIFF');
     for i := 0 to r-1 do
     begin
        outline := format('%3d   %6.3f  %6.3f    %5.2f  %6.2f  %4d      %6.3f',
           [i5[i],rptbis[i],rbis[i],slope[i],mean[i],itemfail[i],P[i]]);
        OutputFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.ShowModal;
end; // end FinishIt procedure

procedure TRaschFrm.FREQUENCIES(C1, r : integer;
                      VAR f : IntDyneMat;
                      VAR rowtot : IntDyneVec;
                      VAR i5 : IntDyneVec;
                      VAR s5 : IntDyneVec;
                      T : integer;
                      VAR S : IntDyneVec);
var
   i, j, c2, c3 : integer;
   Done : boolean;
   outline, strvalue : string;

begin
     Done := false;
     c3 := C1;
     c2 := 1;
     if (c3 > 16) then c3 := 16;
     while (not Done) do
     begin
      OutputFrm.RichEdit.Lines.Add('Matrix of Item Failures in Score Groups');
      outline := '   Score Group';
      for j := c2 to c3 do
      begin
        strvalue := format('%4d',[s5[j-1]]);
        outline := outline + strvalue;
      end;
      outline := outline + '     Total';
      OutputFrm.RichEdit.Lines.Add(outline);
      OutputFrm.RichEdit.Lines.Add('ITEM' );
      OutputFrm.RichEdit.Lines.Add('');
      for i := 1 to r do
      begin
      	outline := format('%4d          ',[i5[i-1]]);
        for j := c2 to c3 do
        begin
           strvalue := format('%4d',[f[i-1,j-1]]);
           outline := outline + strvalue;
        end;
        strvalue := format('%7d',[rowtot[i-1]]);
        outline := outline + strvalue;
        OutputFrm.RichEdit.Lines.Add(outline);
      end;
      outline := 'Total         ';
      for j := c2 to c3 do
      begin
       	  strvalue := format('%4d',[S[j-1]]);
          outline := outline + strvalue;
      end;
      strvalue := format('%7d',[T]);
      outline := outline + strvalue;
      OutputFrm.RichEdit.Lines.Add(outline);
      OutputFrm.RichEdit.Lines.Add( '');
      if (c3 = C1) then Done := true
      else begin
         c2 := c3 + 1;
         c3 := c2 + 15;
         if (c3 > C1) then c3 := C1;
      end;
     end; // end while not done
end; // end sub frequencies

procedure TRaschFrm.GETLOGS(VAR L : DblDyneVec;
                            VAR L1 : DblDyneVec;
                            VAR L2 : DblDyneVec;
                            VAR g : DblDyneVec;
                            VAR g2 : DblDyneVec;
                            VAR f2 : DblDyneVec;
                            VAR rowtot : IntDyneVec;
                            k : integer;
                            VAR s5 : IntDyneVec;
                            VAR S : IntDyneVec;
                            T, r, C1 : integer;
                            VAR v1 : double;
                            VAR v2 : double);
var
   tx, rowtx, rx, t2, t3, e : double;
   i, j : integer;
   outline : string;

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
     OutputFrm.RichEdit.Lines.Add( 'Item Log Odds Deviation Squared Deviation');
     for i := 0 to r-1 do
     begin
          outline := format('%3d  %6.2f   %6.2f     %6.2f',
                     [i+1,L[i],L1[i],L2[i]]);
          OutputFrm.RichEdit.Lines.Add(outline);
     end;
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
     OutputFrm.RichEdit.Lines.Add('Score Frequency Log Odds Freq.x Log  Freq.x Log Odds Squared');
     for j := 0 to C1-1 do
     begin
        outline := format('%3d   %3d      %6.2f      %6.2f     %6.2f',
                [s5[j],S[j],g[j],g2[j],f2[j]]);
        OutputFrm.RichEdit.Lines.Add(outline);
     end;
end; //end of  getlogs

procedure TRaschFrm.GETSCORES(VAR noselected : integer;
                              VAR selected : IntDyneVec;
                              NoCases : integer;
                              f : IntDyneMat;
                              VAR mean : DblDyneVec;
                              VAR xsqr : DblDyneVec;
                              VAR sumxy : DblDyneVec;
                              VAR S : IntDyneVec;
                              VAR X : IntDyneVec;
                              VAR sumx : double;
                              VAR sumx2 : double;
                              VAR N : integer);
var
   i, j, k1, T, item : integer;
   outline, strvalue : string;
begin
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Rasch One-Parameter Logistic Test Scaling (Item Response Theory)');
     OutputFrm.RichEdit.Lines.Add('Written by William G. Miller');
     OutputFrm.RichEdit.Lines.Add('');
     k1 := noselected;
     for i := 1 to k1 do
     begin
          for j := 1 to k1 + 2 do
          begin
             f[i-1,j-1] := 0;
          end;
          mean[i-1] := 0.0;
          xsqr[i-1] := 0.0;
          sumxy[i-1] := 0.0;
     end;
     for j := 1 to k1 + 2 do S[j-1] := 0;
     N := 0;
     sumx := 0.0;
     sumx2 := 0.0;

     //Read each case and scores for each item.  Eliminate rows (subjects)
     //that have a total score of zero or all items correct
     for i := 1 to NoCases do
     begin
          if (not GoodRecord(i,noselected,selected)) then continue;
          T := 0;
          for j := 1 to k1 do
          begin
              item := selected[j-1];
              X[j-1] := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[item,i])));
              T := T + X[j-1];
          end;
          if ((T < k1) and (T > 0)) then
          begin
             outline := format('Case %3d Total Score := %3d Item scores',[i,T]);
             sumx := sumx + T;
             sumx2 := sumx2 + (T * T);
             for j := 0 to k1-1 do
             begin
                mean[j] := mean[j] + X[j];
                xsqr[j] := xsqr[j] + (X[j] * X[j]);
                sumxy[j] := sumxy[j] + (X[j] * T);
                strvalue := format('%2d',[X[j]]);
                outline := outline + strvalue;
                if (X[j] = 0) then f[j,T-1] := f[j,T-1] + 1;
            end;
            OutputFrm.RichEdit.Lines.Add(outline);
            S[T-1] := S[T-1] + 1;
            N := N + 1;
          end
          else begin
               outline := format('case %3d eliminated.  Total score was %3d',
                       [i, T]);
               OutputFrm.RichEdit.Lines.Add(outline);
          end;
     end;
     OutputFrm.RichEdit.Lines.Add('');
end; //end sub getscores

procedure TRaschFrm.MAXABILITY(VAR expdcnt : DblDyneVec;
                               VAR d2 : DblDyneVec;
                               VAR e2 : DblDyneVec;
                               VAR p1 : DblDyneMat;
                               VAR p2 : DblDyneVec;
                               VAR P : DblDyneVec;
                               C1, r : integer;
                               D : DblDyneMat;
                               VAR s5 : IntDyneVec;
                               noloops : integer);
var
   i, j : integer;
   d9 : double;
   outline : string;

begin
     d9 := 0.0;
     outline := format('Maximum Likelihood Iteration Number %2d',[noloops]);
     OutputFrm.RichEdit.Lines.Add(outline);
     for j := 0 to C1-1 do
     begin
          expdcnt[j] := 0.0;
          d2[j] := 0.0;
     end;
     for i := 0 to r-1 do
     begin
          for j := 0 to C1-1 do
             p1[i,j] := exp(p2[j] - P[i]) / (1.0 + exp(p2[j] - P[i]));
     end;
     for j := 0 to C1-1 do
     begin
          for i := 0 to r-1 do
          begin
               expdcnt[j] := expdcnt[j] + p1[i,j];
               // expected number in score group
               D[i,j] := exp(p2[j] - P[i]) / (sqrt(1.0 + exp(p2[j] - P[i])));
               d2[j] := d2[j] + D[i,j]; // rate of change value
          end;
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

function TRaschFrm.MAXITEM(VAR R1 : DblDyneVec;
                           VAR d1 : DblDyneVec;
                           VAR p1 : DblDyneMat;
                           VAR D : DblDyneMat;
                           VAR e1 : DblDyneVec;
                           VAR p2 : DblDyneVec;
                           VAR P : DblDyneVec;
                           VAR S : IntDyneVec;
                           VAR rowtot : IntDyneVec;
                           T, r, C1 : integer) : double;
var
   i, j : integer;
   d9 : double;

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
end; // end of maxitem subroutine

procedure TRaschFrm.MAXOUT(r, C1 : integer;
                           VAR i5 : IntDyneVec;
                           VAR s5 : IntDyneVec;
                           VAR P : DblDyneVec;
                           VAR p2 : DblDyneVec);
var
   i, j : integer;
   outline : string;

begin
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Maximum Likelihood Estimates');
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Item  Log Difficulty');
     for i := 0 to r-1 do
     begin
         outline := format('%3d     %6.2f',[i5[i],P[i]]);
         OutputFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Score   Log Ability');
     for j := 0 to C1-1 do
     begin
         outline := format('%3d    %6.2f',[s5[j],p2[j]]);
         OutputFrm.RichEdit.Lines.Add(outline);
     end;
end; // end  of maxout

procedure TRaschFrm.PROX(VAR P : DblDyneVec;
                         VAR p2 : DblDyneVec;
                         k, r, C1 : integer;
                         VAR L1 : DblDyneVec;
                         yexpand, xexpand : double;
                         VAR g : DblDyneVec;
                         T : integer;
                         VAR rowtot : IntDyneVec;
                         VAR i5 : IntDyneVec;
                         VAR s5 : IntDyneVec);
var
   tx, rowtx, errorterm, stderror : double;
   i, j : integer;
   outline : string;
begin
     if ProxChk.Checked then OutputFrm.RichEdit.Lines.Add('');
     for i := 0 to r-1 do P[i] := L1[i] * yexpand;
     for j := 0 to C1-1 do p2[j] := g[j] * xexpand;
     if ProxChk.Checked then
     begin
          OutputFrm.RichEdit.Lines.Add( 'Prox values and Standard Errors' );
          OutputFrm.RichEdit.Lines.Add(' ');
          OutputFrm.RichEdit.Lines.Add('Item     Scale Value     Standard Error');
     end;
     tx := T;
     for i := 0 to r-1 do
     begin
         rowtx := rowtot[i];
         errorterm := tx / ((tx - rowtx) * rowtx);
         //writeln(lst,'row := ',i:2,' yexpand := ',yexpand:8:2,
         //      total := ',t:8,' row total := ',rowtot(i):8,
         //      error term := ',errorterm:8:2)  end;
         stderror := yexpand * sqrt(errorterm);
         if ProxChk.Checked then
         begin
              outline := format('%3d    %7.3f          %7.3f',[i5[i],P[i],stderror]);
              OutputFrm.RichEdit.Lines.Add(outline);
         end;
     end;
     if ProxChk.Checked then
     begin
          outline := format('Y expansion factor := %8.4f',[yexpand]);
          OutputFrm.RichEdit.Lines.Add(outline);
          OutputFrm.RichEdit.Lines.Add('');
          OutputFrm.RichEdit.Lines.Add('Score    Scale Value     Standard Error');
     end;
     for j := 0 to C1-1 do
     begin
          stderror := xexpand * sqrt(k / (s5[j] * (k - s5[j])));
          if ProxChk.Checked then
          begin
               outline := format('%3d    %7.3f         %7.3f',[s5[j],p2[j],stderror]);
               OutputFrm.RichEdit.Lines.Add(outline);
          end;
     end;
     if ProxChk.Checked then
     begin
          outline := format('X expansion factor = %8.4f',[xexpand]);
          OutputFrm.RichEdit.Lines.Add(outline);
     end;
end; //end of prox

Function TRaschFrm.REDUCE(k : integer;
                           VAR r : integer;
                           VAR T : integer;
                           VAR C1 : integer;
                           VAR i5 : IntDyneVec;
                           VAR rowtot : IntDyneVec;
                           VAR s5 : IntDyneVec;
                           VAR f : IntDyneMat;
                           VAR S : IntDyneVec) : integer;
var
   Done : boolean;
   check, i, j, column, row : integer;
   outline : string;
begin // NOW REDUCE THE MATRIX BY ELIMINATING 0 OR 1 ROWS AND COLUMNS
    OutputFrm.RichEdit.Lines.Add('');
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
     Done := false;
     while (not Done) do
     begin
       for i := 1 to r do
       begin
          if ((rowtot[i-1] = 0) or (rowtot[i-1] = T)) then
          begin
               outline := format('Row %3d for item %3d eliminated.',[i,i5[i-1]]);
               OutputFrm.RichEdit.Lines.Add(outline);
               if (i < r) then
               begin
                    for j := i to r-1 do //move rows up to replace row i
                    begin
                        for column := 1 to C1 do
                            f[j-1,column-1] := f[j,column-1];
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
       if (check = 1) then Done := true;
     end;
     // check for group elimination
     Done := false;
     j := 1;
     while (not Done) do
     begin
          if (S[j-1] = 0) then
          begin
               outline := format('Column %3d score group %3d eliminated - total group count = %3d',
                       [j, s5[j-1], S[j-1]]);
               OutputFrm.RichEdit.Lines.Add(outline);
               if (j < C1) then
               begin
                     for i := j to C1 - 1 do
                     begin
                          for row := 1 to r do
                              f[row-1,i-1] := f[row-1,i];
                          S[i-1] := S[i];
                          s5[i-1] := s5[i];
                     end;
                     C1 := C1 - 1;
               end
               else  C1 := C1 - 1;
          end;
          if C1 = 0 then
          begin
               ShowMessage('Too many cases or variables eliminated');
               OutputFrm.ShowModal;
               Result := 1;
               exit;
          end;
          if (S[j-1] > 0) then j := j + 1;
          if (j >= C1) then
          begin
               while (S[C1-1] <= 0) do
               begin
                    C1 := C1 - 1;
                    if C1 = 0 then
                    begin
                         ShowMessage('Too many cases or variables eliminated');
                         OutputFrm.ShowModal;
                         Result := 1;
                         exit;
                    end;
                end;
               Done := true;
          end;
     end;
     outline := format('Total number of score groups := %4d',[C1]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');
     Result := 0;
end; // end of reduce

procedure TRaschFrm.SLOPES(VAR rptbis : DblDyneVec;
                           VAR rbis : DblDyneVec;
                           VAR slope : DblDyneVec;
                           N : integer;
                           sumx, sumx2 : double;
                           VAR sumxy : DblDyneVec;
                           r : integer;
                           VAR xsqr : DblDyneVec;
                           VAR mean : DblDyneVec);
var
   propi, term1, term2, z, Y : double;
   j : integer;
begin
     z := 0.0;
     term1 := N * sumx2 - sumx * sumx;
     for j := 0 to r-1 do
     begin
          rptbis[j] := N * sumxy[j] - mean[j] * sumx;
          term2 := N * xsqr[j] - (mean[j] * mean[j]);
          if ((term1 > 0) and (term2 > 0)) then
            rptbis[j] := rptbis[j] / sqrt(term1 * term2)
          else rptbis[j] := 1.0;
          propi := mean[j] / N;
          if ((propi > 0.0) and (propi < 1.0)) then z := inversez(propi);
          if (propi <= 0.0) then z := -3.0;
          if (propi >= 1.0) then z := 3.0;
          Y := ordinate(z);
          if (Y > 0) then rbis[j] := rptbis[j] * (sqrt(propi * (1.0 - propi)) / Y)
          else rbis[j] := 1.0;
          if (rbis[j] <= -1.0) then rbis[j] := -0.99999;
          if (rbis[j] >= 1.0) then rbis[j] := 0.99999;
          slope[j] := rbis[j] / sqrt(1.0 - (rbis[j] * rbis[j]));
     end;
end; // end of slopes procedure

procedure TRaschFrm.TESTFIT(r, C1 : integer;
                            VAR f : IntDyneMat;
                            VAR S : IntDyneVec;
                            VAR P : DblDyneVec;
                            VAR p2 : DblDyneVec;
                            T : integer);
var
   ct, ch, prob : double;
    i, j : integer;
    outline : string;
begin
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add( 'Goodness of Fit Test for Each Item');
     OutputFrm.RichEdit.Lines.Add('Item  Chi-Squared  Degrees of  Probability');
     OutputFrm.RichEdit.Lines.Add('No.   Value        Freedom     of Larger Value');
     ct := 0.0;
     for i := 0 to r-1 do
     begin
          ch := 0.0;
          for j := 0 to C1-1 do
               ch := ch + (exp(p2[j] - P[i]) * f[i,j]) + (exp(P[i] -
                    p2[j]) * (S[j] - f[i,j]));
          prob := 1.0 - chisquaredprob(ch, T - C1);
          outline := format('%3d   %8.2f     %3d          %6.4f',[i+1,ch,(T-C1),prob]);
          OutputFrm.RichEdit.Lines.Add(outline);
          ct := ct + ch;
     end;
     OutputFrm.RichEdit.Lines.Add('');
end; // end of testfit

procedure TRaschFrm.PLOTINFO(k, r : integer;
                             VAR info : DblDyneMat;
                             VAR A : DblDyneMat;
                             VAR slope : DblDyneVec;
                             VAR P : DblDyneVec);
var
   min, max, cg, hincrement, Ymax, elg, term1, term2, jx : double;
   headstring, valstring : string;
   i, j, jj, size : integer;
   TestInfo : DblDyneMat;
begin
     min := -3.5;
     max := 3.5;
     size := 0;
     hincrement := (max - min) / 50;
     SetLength(TestInfo,52,2);
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
     if TestInfoChk.Checked then PlotTest(TestInfo,size,headstring,50,50);
     TestInfo := nil;
end; //end of PlotInfo

procedure TRaschFrm.plot(VAR xyarray : DblDyneMat;
                         arraysize : integer;
                         Title : string;
                         Vdivisions, Hdivisions : integer);
var
    i : integer;
    xvalue, yvalue : DblDyneVec;
begin
    // Allocate space for point sets of means
    SetLength(xvalue,arraysize);
    SetLength(yvalue,arraysize);
    SetLength(GraphFrm.Ypoints,1,arraysize);
    SetLength(GraphFrm.Xpoints,1,arraysize);
    // store points for means
    for i := 0 to arraysize-1 do
    begin
         yvalue[i] := xyarray[i,1];
         xvalue[i] := xyarray[i,0];
         GraphFrm.Ypoints[0,i] := yvalue[i];
         GraphFrm.Xpoints[0,i] := xvalue[i];
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
    GraphFrm.BackColor := clYellow;
    GraphFrm.WallColor := clBlack;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;

    xvalue := nil;
    yvalue := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;  //end plot subroutine

procedure TRaschFrm.PlotItems(r : integer; i5 : IntDyneVec; P : DblDyneVec);
var
   i : integer;
   xvalues : DblDyneVec;
begin
    SetLength(xvalues,r);
    SetLength(GraphFrm.Ypoints,1,r);
    SetLength(GraphFrm.Xpoints,1,r);
    for i := 1 to r do
    begin
        xvalues[i-1] := i5[i-1];
        GraphFrm.Xpoints[0,i-1] := xvalues[i-1];
        GraphFrm.Ypoints[0,i-1] := P[i-1];
    end;
    GraphFrm.nosets := 1;
    GraphFrm.nbars := r;
    GraphFrm.Heading := 'LOG DIFFICULTIES FOR ITEMS';
    GraphFrm.XTitle := 'ITEM';
    GraphFrm.YTitle := 'LOG DIFFICULTY';
//    GraphFrm.Ypoints[1] := P;
//    GraphFrm.Xpoints[1] := xvalues;
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := true;
    GraphFrm.GraphType := 2; // bar chart
    GraphFrm.BackColor := clYellow;
    GraphFrm.WallColor := clBlack;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;
    xvalues := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;

procedure TRaschFrm.PlotScrs(C1 : integer; s5 : IntDyneVec; p2 : DblDyneVec);
var
   i : integer;
   xvalues : DblDyneVec;
begin
    SetLength(xvalues,C1);
    SetLength(GraphFrm.Ypoints,1,C1);
    SetLength(GraphFrm.Xpoints,1,C1);
    for i := 1 to C1 do
    begin
        xvalues[i-1] := s5[i-1];
        GraphFrm.Xpoints[0,i-1] := xvalues[i-1];
        GraphFrm.Ypoints[0,i-1] := p2[i-1];
    end;
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
    GraphFrm.BackColor := clYellow;
    GraphFrm.WallColor := clBlack;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;
    xvalues := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;

procedure TRaschFrm.PlotTest(VAR TestInfo : DblDyneMat;
                         arraysize : integer;
                         Title : string;
                         Vdivisions, Hdivisions : integer);
var
    i : integer;
    xvalue, yvalue : DblDyneVec;
begin
    // Allocate space for point sets of means
    SetLength(xvalue,arraysize);
    SetLength(yvalue,arraysize);
    SetLength(GraphFrm.Ypoints,1,arraysize);
    SetLength(GraphFrm.Xpoints,1,arraysize);
    // store points for means
    for i := 1 to arraysize do
    begin
         yvalue[i-1] := TestInfo[i-1,1];
         xvalue[i-1] := TestInfo[i-1,0];
         GraphFrm.Ypoints[0,i-1] := yvalue[i-1];
         GraphFrm.Xpoints[0,i-1] := xvalue[i-1];
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
    GraphFrm.BackColor := clYellow;
    GraphFrm.WallColor := clBlack;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;

    xvalue := nil;
    yvalue := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;  //end plot subroutine


initialization
  {$I raschunit.lrs}

end.

