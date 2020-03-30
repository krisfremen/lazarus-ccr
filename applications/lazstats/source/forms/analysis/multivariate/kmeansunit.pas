unit KMeansUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, DataProcs, OutputUnit, ContextHelpUnit;

type

  { TKMeansFrm }

  TKMeansFrm = class(TForm)
    Bevel1: TBevel;
    DescChkBox: TCheckBox;
    HelpBtn: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    VarInBtn: TBitBtn;
    VarOutBtn: TBitBtn;
    AllBtn: TBitBtn;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    StdChkBox: TCheckBox;
    RepChkBox: TCheckBox;
    GroupBox1: TGroupBox;
    ItersEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    VarList: TListBox;
    NoClustersEdit: TEdit;
    Label1: TLabel;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarInBtnClick(Sender: TObject);
    procedure VarOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure KMNS(VAR A : DblDyneMat; M, N : integer;
                   VAR C : DblDyneMat; K : integer; VAR IC1 : IntDyneVec;
                   VAR IC2 : IntDyneVec; VAR NC : IntDyneVec;
                   VAR AN1 : DblDyneVec; VAR AN2 : DblDyneVec;
                   VAR NCP : IntDyneVec; VAR D : DblDyneVec;
                   VAR ITRAN : IntDyneVec; VAR LIVE : IntDyneVec;
                   ITER : integer; VAR WSS : DblDyneVec; IFAULT : integer);
    procedure OPTRA(VAR A : DblDyneMat; M, N : integer;
                    VAR C : DblDyneMat; K : integer;
                    VAR IC1 : IntDyneVec; VAR IC2 : IntDyneVec;
                    VAR NC : IntDyneVec; VAR AN1 : DblDyneVec;
                    VAR AN2 : DblDyneVec; VAR NCP : IntDyneVec;
                    VAR D : DblDyneVec; VAR ITRAN : IntDyneVec;
                    VAR LIVE : IntDyneVec; INDX : integer);
   procedure QTRAN(VAR A : DblDyneMat; M, N : integer;
                           VAR C : DblDyneMat; K : integer;
                           VAR IC1 : IntDyneVec; VAR IC2 : IntDyneVec;
                           VAR NC : IntDyneVec; VAR AN1 : DblDyneVec;
                           VAR AN2 : DblDyneVec; VAR NCP : IntDyneVec;
                           VAR D : DblDyneVec; VAR ITRAN : IntDyneVec;
                           INDX : integer);

  public
    { public declarations }
  end; 

var
  KMeansFrm: TKMeansFrm;

implementation

uses
  Math;

{ TKMeansFrm }

procedure TKMeansFrm.ResetBtnClick(Sender: TObject);
VAR cellstring : string;
    i : integer;
begin
     VarList.Clear;
     ListBox1.Clear;
     for i := 1 to NoVariables do
     begin
         cellstring := OS3MainFrm.DataGrid.Cells[i,0];
         VarList.Items.Add(cellstring);
     end;
     RepChkBox.Checked := false;
     StdChkBox.Checked := true;
     VarOutBtn.Enabled := false;
     DescChkBox.Checked := false;
     NoClustersEdit.Text := '';
     ItersEdit.Text := '100';
end;

procedure TKMeansFrm.VarInBtnClick(Sender: TObject);
VAR
   index, count, i : integer;
   cellstring : string;
begin
     count := 0;
     index := ListBox1.Items.Count;
     for i := 0 to index - 1 do
     begin
         if (VarList.Selected[i]) then
         begin
            cellstring := VarList.Items.strings[i];
            ListBox1.Items.Add(cellstring);
            count := count + 1;
         end;
     end;

     while (count > 0) do
     begin
           for i := 0 to VarList.Items.Count - 1 do
           begin
               if (VarList.Selected[i]) then
               begin
                  VarList.Items.Delete(i);
                  count := count - 1;
               end;
           end;
     end;
     VarOutBtn.Enabled := true;
end;

procedure TKMeansFrm.VarOutBtnClick(Sender: TObject);
VAR index : integer;
    cellstring : string;
begin
     index := ListBox1.ItemIndex;
     cellstring := ListBox1.Items.Strings[index];
     VarList.Items.Add(cellstring);
     ListBox1.Items.Delete(index);
end;

procedure TKMeansFrm.FormActivate(Sender: TObject);
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

procedure TKMeansFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TKMeansFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TKMeansFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TKMeansFrm.AllBtnClick(Sender: TObject);
VAR
   index, noitems : integer;
   cellstring : string;
begin
     noitems := VarList.Items.Count;
     for index := 0 to noitems - 1 do
     begin
          cellstring := VarList.Items.Strings[index];
          ListBox1.Items.Add(cellstring);
     end;
     VarList.Clear;
     VarOutBtn.Enabled := true;
end;

procedure TKMeansFrm.ComputeBtnClick(Sender: TObject);
VAR
   i, j, L, Ncols, N, M, K,IFAULT, ITER, col : integer;
   center, itemp : integer;
   IC1, IC2, NC, NCP, ITRAN, LIVE, ColSelected : IntDyneVec;
   A, C : DblDyneMat;
   D, AN1, AN2, WSS, DT : DblDyneVec;
   cellstring: string;
   outline : string;
   strval : string;
   varlabels, rowlabels : StrDyneVec;
   Mean, stddev : double;
label cleanup;

begin
     Ncols := ListBox1.Items.Count;
     if (Ncols <= 0) then
     begin
        ShowMessage('ERROR!  No variables selected to cluster.');
        exit;
     end;

     N := Ncols;
     M := NoCases;
     K := StrToInt(NoClustersEdit.Text);
     IFAULT := 0;
     ITER := StrToInt(ItersEdit.Text);

     SetLength(varlabels,Ncols);
     SetLength(rowlabels,NoCases);
     SetLength(ColSelected,Ncols);
     SetLength(A,M+1,N+1);
     SetLength(C,K+1,N+1);
     SetLength(D,M+1);
     SetLength(AN1,K+1);
     SetLength(AN2,K+1);
     SetLength(WSS,K+1);
     SetLength(DT,3);
     SetLength(IC1,M+1);
     SetLength(IC2,M+1);
     SetLength(NC,K+1);
     SetLength(NCP,K+1);
     SetLength(ITRAN,K+1);
     SetLength(LIVE,K+1);

     if (K <= 0) then
     begin
        ShowMessage('ERROR! You must enter the desired number of clusters.');
        goto cleanup;
     end;

     // initialize arrays
     for i := 1 to K do
     begin
         AN1[i] := 0.0;
         AN2[i] := 0.0;
         WSS[i] := 0.0;
         NC[i] := 0;
         NCP[i] := 0;
         ITRAN[i] := 0;
         LIVE[i] := 0;
         for j := 1 to N do C[i,j] := 0.0;
     end;
     for i := 1 to M do
     begin
         IC1[i] := 0;
         IC2[i] := 0;
         D[i] := 0.0;
     end;

     //Get labels and columns of selected variables
     for i := 0 to Ncols - 1 do
     begin
        cellstring := ListBox1.Items.Strings[i];
        for j := 0 to NoVariables - 1 do
        begin
            if (cellstring = OS3MainFrm.DataGrid.Cells[j+1,0]) then
            begin
                varlabels[i] := cellstring;
                ColSelected[i] := j+1;
            end;
        end;
     end;

     // Get labels of rows
     for i := 0 to NoCases - 1 do rowlabels[i] := OS3MainFrm.DataGrid.Cells[0,i+1];

     // read the data
     for i := 1 to M do
     begin
         if (NOT GoodRecord(i,N,ColSelected)) then continue;
         for j := 1 to N do
         begin
             col := ColSelected[j-1];
             A[i,j] := StrToFloat(OS3MainFrm.DataGrid.Cells[col,i]);
         end;
     end;

     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('K-Means Clustering.  Adapted from AS 136  APPL. STATIST. (1979) VOL.28, NO.1');
     OutputFrm.RichEdit.Lines.Add('');
     outline := format('File := %s',[OS3MainFrm.FileNameEdit.Text]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('No. Cases := %d, No. Variables := %d, No. Clusters := %d',[M,N,K]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');

     // transform to z scores if needed
     if (StdChkBox.Checked = true) then
     begin
        for j := 1 to N do
        begin
            Mean := 0.0;
            stddev := 0.0;
            for i := 1 to M do
            begin
                Mean := Mean + A[i,j];
                stddev := stddev + (A[i,j] * A[i,j]);
            end;
            stddev := stddev - Mean * Mean / M;
            stddev := stddev / (M - 1);
            Mean := Mean / M;
            if (DescChkBox.Checked) then
            begin
               outline := format('Mean := %8.3f, Std.Dev. := %8.3f for %s',[Mean,stddev,varlabels[j-1]]);
               OutputFrm.RichEdit.Lines.Add(outline);
            end;
            for i := 1 to M do
            begin
                A[i,j] := (A[i,j] - Mean) / stddev;
                if (RepChkBox.Checked = true) then
                begin
                   col := ColSelected[j-1];
                   outline := format('%8.5f',[A[i,j]]);
                   OS3MainFrm.DataGrid.Cells[col,i] := outline;
                end;
            end;
        end;
     end;

     // Now enter initial points
     for L := 1 to K do
     begin
         center := 1 + (L-1) * (M div K); // initial cluster center
         for j := 1 to N do C[L,j] := A[center,j];
     end;

     // do analysis
     KMNS(A,M,N,C,K,IC1,IC2,NC,AN1,AN2,NCP,D,ITRAN,LIVE,ITER,WSS,IFAULT);

     // show results

     // sort subjects by cluster
     for i := 1 to M do IC2[i] := i; // store ids in here
     for i := 1 to M - 1 do
     begin
         for j := i+1 to M do
         begin
             if (IC1[i] > IC1[j]) then // swap these clusters and ids
             begin
                itemp := IC1[i];
                IC1[i] := IC1[j];
                IC1[j] := itemp;
                itemp := IC2[i];
                IC2[i] := IC2[j];
                IC2[j] := itemp;
             end;
         end;
     end;

     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('NUMBER OF SUBJECTS IN EACH CLUSTER');
     for i := 1 to K do
     begin
         outline := format('Cluster := %d with %d cases.',[i,NC[i]]);
         OutputFrm.RichEdit.Lines.Add(outline);
     end;

     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('PLACEMENT OF SUBJECTS IN CLUSTERS');
     OutputFrm.RichEdit.Lines.Add('CLUSTER SUBJECT');
     for i := 1 to M do
     begin
         outline := format('   %3d    %3d',[IC1[i],IC2[i]]);
         OutputFrm.RichEdit.Lines.Add(outline);
     end;

     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('AVERAGE VARIABLE VALUES BY CLUSTER');
     outline := '               VARIABLES';
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := 'CLUSTER';
     for j := 1 to N do
     begin
         strval := format('  %3d ',[j]);
         outline := outline + strval;
     end;
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('       ');
     for i := 1 to K do
     begin
         outline := format('   %3d ',[i]);
         for j := 1 to N do
         begin
             strval := format('%5.2f ',[C[i,j]]);
             outline := outline + strval;
         end;
         OutputFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('WITHIN CLUSTER SUMS OF SQUARES');
     for i := 1 to K do
     begin
         outline := format('Cluster %d := %6.3f',[i,WSS[i]]);
         OutputFrm.RichEdit.Lines.Add(outline);
     end;

     OutputFrm.ShowModal;

     // cleanup
cleanup:
     LIVE := nil;
     ITRAN := nil;
     NCP := nil;
     NC := nil;
     IC2 := nil;
     IC1 := nil;
     DT := nil;
     WSS := nil;
     AN2 := nil;
     AN1 := nil;
     D := nil;
     C := nil;
     A := nil;
     ColSelected := nil;
     rowlabels := nil;
     varlabels := nil;
end;

procedure TKMeansFrm.KMNS(VAR A : DblDyneMat; M, N : integer;
                           VAR C : DblDyneMat; K : integer; VAR IC1 : IntDyneVec;
                           VAR IC2 : IntDyneVec; VAR NC : IntDyneVec;
                           VAR AN1 : DblDyneVec; VAR AN2 : DblDyneVec;
                           VAR NCP : IntDyneVec; VAR D : DblDyneVec;
                           VAR ITRAN : IntDyneVec; VAR LIVE : IntDyneVec;
                           ITER : integer; VAR WSS : DblDyneVec; IFAULT : integer);
VAR
      DT : array[0..2] of double;
      BIG : double;
      ZERO : double;
      ONE : double;
      DA, DB, DC, TEMP, AA : double;
      L, II, INDX, I, J, IL, IJ : integer;
label cont50, cont40, cont150;

begin
      //      SUBROUTINE KMNS(A, M, N, C, K, IC1, IC2, NC, AN1, AN2, NCP, D,
      //     *    ITRAN, LIVE, ITER, WSS, IFAULT)
      //
      //     ALGORITHM AS 136  APPL. STATIST. (1979) VOL.28, NO.1
      //     Divide M points in N-dimensional space into K clusters so that
      //     the within cluster sum of squares is minimized.
      //
      //      INTEGER IC1(M), IC2(M), NC(K), NCP(K), ITRAN(K), LIVE(K)
      //      REAL    A(M,N), D(M), C(K,N), AN1(K), AN2(K), WSS(K), DT(2)
      //      REAL    ZERO, ONE
      //
      //     Define BIG to be a very large positive number
      //
      //      DATA BIG /1.E30/, ZERO /0.0/, ONE /1.0/
      //
      BIG := 1.0e30;
      ZERO := 0.0;
      ONE := 1.0;
      IFAULT := 3;
      if ((K <= 1) or (K >= M)) then
      begin
         ShowMessage('The no. of clusters must be less than the no. of variables.');
         exit;
      end;

      //     For each point I, find its two closest centres, IC1(I) and
      //     IC2(I).     Assign it to IC1(I).
      //
      for I := 1 to M do
      begin
	      IC1[I] := 1;
	      IC2[I] := 2;
	      for IL := 1 to 2 do
              begin
	          DT[IL] := ZERO;
	          for J := 1 to N do
                  begin
	              DA := A[I,J] - C[IL,J];
	              DT[IL] := DT[IL] + (DA * DA); //(squared difference for this comparison)
                  end; // 10   CONTINUE
              end; // 10 CONTINUE
	      if (DT[1] > DT[2]) then // THEN swap
              begin
	          IC1[I] := 2;
	          IC2[I] := 1;
	          TEMP := DT[1];
	          DT[1] := DT[2];
	          DT[2] := TEMP;
              end; // END IF
	      for L := 3 to K do // (remaining clusters)
              begin
	          DB := ZERO;
	          for J := 1 to N do // (variables)
                  begin
	              DC := A[I,J] - C[L,J];
	              DB := DB + DC * DC;
	              if (DB >= DT[2]) then  goto cont50;
                  end;
	          if (DB < DT[1]) then goto cont40;
	          DT[2] := DB;
	          IC2[I] := L;
	          goto cont50;
cont40:           DT[2] := DT[1];
	          IC2[I] := IC1[I];
	          DT[1] := DB;
	          IC1[I] := L;
cont50:       end;
      end; // 50 CONTINUE (next case)

      //     Update cluster centres to be the average of points contained
      //     within them.
      //
      for L := 1 to K do  // (clusters)
      begin
	      NC[L] := 0;
	      for J := 1 to N do C[L,J] := ZERO;  //(initialize clusters)
      end;
      for I := 1 to M do // (subjects)
      begin
	      L := IC1[I];  // which cluster the Ith case is in
	      NC[L] := NC[L] + 1; // no. in the cluster L
	      for J := 1 to N do  C[L,J] := C[L,J] + A[I,J]; // sum of var. values in the cluster L
      end;

      //     Check to see if there is any empty cluster at this stage
      //
      for L := 1 to K do
      begin
          if (NC[L] = 0) then
          begin
	          IFAULT := 1;
                  exit;
          end;
	  AA := NC[L];
	  for J := 1 to N do C[L,J] := C[L,J] / AA; // average the values in the cluster

          //     Initialize AN1, AN2, ITRAN & NCP
          //     AN1(L) := NC(L) / (NC(L) - 1)
          //     AN2(L) := NC(L) / (NC(L) + 1)
          //     ITRAN(L) := 1 if cluster L is updated in the quick-transfer stage,
          //              := 0 otherwise
          //     In the optimal-transfer stage, NCP(L) stores the step at which
          //     cluster L is last updated.
          //     In the quick-transfer stage, NCP(L) stores the step at which
          //     cluster L is last updated plus M.
          //
	  AN2[L] := AA / (AA + ONE);
	  AN1[L] := BIG;
	  if (AA > ONE) then AN1[L] := AA / (AA - ONE);
	  ITRAN[L] := 1;
	  NCP[L] := -1;
      end;
      INDX := 0;
      for IJ := 1 to ITER do
      begin
          //
          //     In this stage, there is only one pass through the data.   Each
          //     point is re-allocated, if necessary, to the cluster that will
          //     induce the maximum reduction in within-cluster sum of squares.
          //
	  OPTRA(A, M, N, C, K, IC1, IC2, NC, AN1, AN2, NCP, D, ITRAN, LIVE, INDX);
          //
          //     Stop if no transfer took place in the last M optimal transfer
          //     steps.
          //
	  if (INDX = M) then goto cont150;
          //
          //     Each point is tested in turn to see if it should be re-allocated
          //     to the cluster to which it is most likely to be transferred,
          //     IC2(I), from its present cluster, IC1(I).   Loop through the
          //     data until no further change is to take place.
          //
	  QTRAN(A, M, N, C, K, IC1, IC2, NC, AN1, AN2, NCP, D, ITRAN, INDX);
          //
          //     If there are only two clusters, there is no need to re-enter the
          //     optimal transfer stage.
          //
	  if (K = 2) then goto cont150;
          //
          //     NCP has to be set to 0 before entering OPTRA.
          //
	  for L := 1 to K do NCP[L] := 0;
      end;
      //
      //     Since the specified number of iterations has been exceeded, set
      //     IFAULT := 2.   This may indicate unforeseen looping.
      //
      IFAULT := 2;
      //
      //     Compute within-cluster sum of squares for each cluster.
      //
cont150:
      for L := 1 to K do
      begin
	      WSS[L] := ZERO;
	      for J := 1 to N do C[L,J] := ZERO;
      end;
      for I := 1 to M do
      begin
	      II := IC1[I];
	      for J := 1 to N do C[II,J] := C[II,J] + A[I,J];
      end;
      for J := 1 to N do
      begin
	      for L := 1 to K do C[L,J] := C[L,J] / (NC[L]);
	      for I := 1 to M do
              begin
	          II := IC1[I];
	          DA := A[I,J] - C[II,J];
	          WSS[II] := WSS[II] + DA * DA;
              end;
      end; // 190 CONTINUE
end;


procedure TKMeansFrm.OPTRA(VAR A : DblDyneMat; M, N : integer;
                           VAR C : DblDyneMat; K : integer;
                           VAR IC1 : IntDyneVec; VAR IC2 : IntDyneVec;
                           VAR NC : IntDyneVec; VAR AN1 : DblDyneVec;
                           VAR AN2 : DblDyneVec; VAR NCP : IntDyneVec;
                           VAR D : DblDyneVec; VAR ITRAN : IntDyneVec;
                           VAR LIVE : IntDyneVec; INDX : integer);
VAR
      ZERO, ONE, BIG,DE, DF, DD, DC, DB, DA, R2, RR, AL1, AL2, ALT, ALW : double;
      I, J, L, L1, L2, LL : integer;
label cont30, cont60, cont70, cont90;

begin
      //      SUBROUTINE OPTRA(A, M, N, C, K, IC1, IC2, NC, AN1, AN2, NCP, D,
      //     *      ITRAN, LIVE, INDX)
      //
      //     ALGORITHM AS 136.1  APPL. STATIST. (1979) VOL.28, NO.1
      //
      //     This is the optimal transfer stage.
      //
      //     Each point is re-allocated, if necessary, to the cluster that
      //     will induce a maximum reduction in the within-cluster sum of
      //     squares.
      //
      //  INTEGER IC1(M), IC2(M), NC(K), NCP(K), ITRAN(K), LIVE(K)
      //  REAL    A(M,N), D(M), C(K,N), AN1(K), AN2(K), ZERO, ONE
      //
      //     Define BIG to be a very large positive number.
      //
      //  DATA BIG /1.0E30/, ZERO /0.0/, ONE/1.0/
      //
      //     If cluster L is updated in the last quick-transfer stage, it
      //     belongs to the live set throughout this stage.   Otherwise, at
      //     each step, it is not in the live set if it has not been updated
      //     in the last M optimal transfer steps.
      //

      ZERO := 0.0;
      ONE := 1.0;
      BIG := 1.0e30;

      for L := 1 to K do
      begin
	      if (ITRAN[L] = 1) then  LIVE[L] := M + 1;
      end; // 10 CONTINUE

      for I := 1 to M do
      begin
	      INDX := INDX + 1;
	      L1 := IC1[I];
	      L2 := IC2[I];
	      LL := L2;
          //
          //     If point I is the only member of cluster L1, no transfer.
          //
	  if (NC[L1] = 1) then goto cont90; // GO TO 90
          //
          //     If L1 has not yet been updated in this stage, no need to
          //     re-compute D(I).
          //
	  if (NCP[L1] = 0) then goto cont30; // GO TO 30
	  DE := ZERO;
	  for J := 1 to N do
          begin
	          DF := A[I,J] - C[L1,J];
	          DE := DE + DF * DF;
          end;
	  D[I] := DE * AN1[L1];
          //
          //     Find the cluster with minimum R2.
          //
cont30:
          DA := ZERO;
	  for J := 1 to N do
          begin
	          DB := A[I,J] - C[L2,J];
	          DA := DA + DB * DB;
          end;
	  R2 := DA * AN2[L2];
	  for L := 1 to K do
          begin
              //
              //     If I >:= LIVE(L1), then L1 is not in the live set.   If this is
              //     true, we only need to consider clusters that are in the live set
              //     for possible transfer of point I.   Otherwise, we need to consider
              //     all possible clusters.
              //
	      if ((I >= LIVE[L1]) and (I >= LIVE[L]) or (L = L1) or (L = LL)) then goto cont60;
	      RR := R2 / AN2[L];
	      DC := ZERO;
	      for J := 1 to N do
              begin
	              DD := A[I,J] - C[L,J];
	              DC := DC + DD * DD;
	              if (DC >= RR) then goto cont60;
              end;
	      R2 := DC * AN2[L];
	      L2 := L;
cont60:
          end; // 60     CONTINUE
	  if (R2 < D[I]) then goto cont70;
          //
          //     If no transfer is necessary, L2 is the new IC2(I).
          //
	  IC2[I] := L2;
	  goto cont90; // GO TO 90
          //
          //     Update cluster centres, LIVE, NCP, AN1 & AN2 for clusters L1 and
          //     L2, and update IC1(I) & IC2(I).
          //
cont70:
          INDX := 0;
	  LIVE[L1] := M + I;
	  LIVE[L2] := M + I;
	  NCP[L1] := I;
	  NCP[L2] := I;
	  AL1 := NC[L1];
	  ALW := AL1 - ONE;
	  AL2 := NC[L2];
	  ALT := AL2 + ONE;
	  for J := 1 to N do
          begin
	          C[L1,J] := (C[L1,J] * AL1 - A[I,J]) / ALW;
	          C[L2,J] := (C[L2,J] * AL2 + A[I,J]) / ALT;
          end;
	  NC[L1] := NC[L1] - 1;
	  NC[L2] := NC[L2] + 1;
	  AN2[L1] := ALW / AL1;
	  AN1[L1] := BIG;
	  if (ALW > ONE) then AN1[L1] := ALW / (ALW - ONE);
	  AN1[L2] := ALT / AL2;
	  AN2[L2] := ALT / (ALT + ONE);
	  IC1[I] := L2;
	  IC2[I] := L1;
cont90:
          // 90   CONTINUE
	  if (INDX = M) then exit;
      end; // 100 CONTINUE
      for L := 1 to K do
      begin
              //
              //     ITRAN(L) := 0 before entering QTRAN.   Also, LIVE(L) has to be
              //     decreased by M before re-entering OPTRA.
              //
	      ITRAN[L] := 0;
	      LIVE[L] := LIVE[L] - M;
      end; // 110 CONTINUE
end;

procedure TKMeansFrm.QTRAN(VAR A : DblDyneMat; M, N : integer;
                           VAR C : DblDyneMat; K : integer;
                           VAR IC1 : IntDyneVec; VAR IC2 : IntDyneVec;
                           VAR NC : IntDyneVec; VAR AN1 : DblDyneVec;
                           VAR AN2 : DblDyneVec; VAR NCP : IntDyneVec;
                           VAR D : DblDyneVec; VAR ITRAN : IntDyneVec;
                           INDX : integer);
VAR
      BIG, ZERO, ONE, DA, DB, DE, DD, R2, AL1, ALW, AL2, ALT : double;
      I, J, ICOUN, ISTEP, L1, L2 : integer;
label cont10, cont30, cont60;

begin
      //      SUBROUTINE QTRAN(A, M, N, C, K, IC1, IC2, NC, AN1, AN2, NCP, D,
      //     *    ITRAN, INDX)
      //
      //     ALGORITHM AS 136.2  APPL. STATIST. (1979) VOL.28, NO.1
      //
      //     This is the quick transfer stage.
      //     IC1(I) is the cluster which point I belongs to.
      //     IC2(I) is the cluster which point I is most likely to be
      //         transferred to.
      //     For each point I, IC1(I) & IC2(I) are switched, if necessary, to
      //     reduce within-cluster sum of squares.  The cluster centres are
      //     updated after each step.
      //
      // INTEGER IC1(M), IC2(M), NC(K), NCP(K), ITRAN(K)
      // REAL    A(M,N), D(M), C(K,N), AN1(K), AN2(K), ZERO, ONE
      //
      //     Define BIG to be a very large positive number
      //
      // DATA BIG /1.0E30/, ZERO /0.0/, ONE /1.0/
      //
      //     In the optimal transfer stage, NCP(L) indicates the step at which
      //     cluster L is last updated.   In the quick transfer stage, NCP(L)
      //     is equal to the step at which cluster L is last updated plus M.
      //
      BIG := 1.0e30;
      ZERO := 0.0;
      ONE := 1.0;
      ICOUN := 0;
      ISTEP := 0;
cont10:
      for I := 1 to M do
      begin
	  ICOUN := ICOUN + 1;
	  ISTEP := ISTEP + 1;
	  L1 := IC1[I];
	  L2 := IC2[I];
          //
          //     If point I is the only member of cluster L1, no transfer.
          //
	  if (NC[L1] = 1) then goto cont60;
          //
          //     If ISTEP > NCP(L1), no need to re-compute distance from point I to
          //     cluster L1.   Note that if cluster L1 is last updated exactly M
          //     steps ago, we still need to compute the distance from point I to
          //     cluster L1.
          //
	  if (ISTEP > NCP[L1]) then goto cont30;
	  DA := ZERO;
	  for J := 1 to N do
          begin
	          DB := A[I,J] - C[L1,J];
	          DA := DA + DB * DB;
          end;
	  D[I] := DA * AN1[L1];
          //
          //     If ISTEP >:= both NCP(L1) & NCP(L2) there will be no transfer of
          //     point I at this step.
          //
cont30:
          if ((ISTEP >= NCP[L1]) and (ISTEP >= NCP[L2])) then goto cont60;
	  R2 := D[I] / AN2[L2];
	  DD := ZERO;
	  for J := 1 to N do
          begin
	          DE := A[I,J] - C[L2,J];
	          DD := DD + DE * DE;
	          if (DD >= R2) then goto cont60;
          end; // 40   CONTINUE
          //
          //     Update cluster centres, NCP, NC, ITRAN, AN1 & AN2 for clusters
          //     L1 & L2.   Also update IC1(I) & IC2(I).   Note that if any
          //     updating occurs in this stage, INDX is set back to 0.
          //
	  ICOUN := 0;
	  INDX := 0;
	  ITRAN[L1] := 1;
	  ITRAN[L2] := 1;
	  NCP[L1] := ISTEP + M;
	  NCP[L2] := ISTEP + M;
	  AL1 := NC[L1];
	  ALW := AL1 - ONE;
	  AL2 := NC[L2];
	  ALT := AL2 + ONE;
	  for J := 1 to N do
          begin
	          C[L1,J] := (C[L1,J] * AL1 - A[I,J]) / ALW;
	          C[L2,J] := (C[L2,J] * AL2 + A[I,J]) / ALT;
          end; // 50   CONTINUE
	  NC[L1] := NC[L1] - 1;
	  NC[L2] := NC[L2] + 1;
	  AN2[L1] := ALW / AL1;
	  AN1[L1] := BIG;
	  if (ALW > ONE) then AN1[L1] := ALW / (ALW - ONE);
	  AN1[L2] := ALT / AL2;
	  AN2[L2] := ALT / (ALT + ONE);
	  IC1[I] := L2;
	  IC2[I] := L1;
          //
          //     If no re-allocation took place in the last M steps, return.
          //
cont60:
          if (ICOUN = M) then exit;
      end; // 70 CONTINUE
      goto cont10;
end;

initialization
  {$I kmeansunit.lrs}

end.

