// File for testing: cansas_rotated.laz

// NOTE: Run Correlation > Product-Moment with option Save Matrix to Grid
//       before executing the Average Link Clustering command in order to
//       have a symmetrical matrix.

unit AvgLinkUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls,
  MainUnit, Globals, OutputUnit, ContextHelpUnit;

type

  { TAvgLinkFrm }

  TAvgLinkFrm = class(TForm)
    Bevel1: TBevel;
    ComputeBtn: TButton;
    HelpBtn: TButton;
    CloseBtn: TButton;
    MatrixTypeGroup: TRadioGroup;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    { private declarations }
    procedure PreTree(NN, CRIT: integer; LST: IntDyneVec; KLUS: IntDyneMat; AReport: TStrings);
    procedure TreePlot(Clusters: IntDyneMat; Lst: IntDyneVec; NoPoints: integer; AReport: TStrings);
  public
    { public declarations }
  end; 

var
  AvgLinkFrm: TAvgLinkFrm;

implementation

uses
  Math;

{ TAvgLinkFrm }

procedure TAvgLinkFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TAvgLinkFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TAvgLinkFrm.FormShow(Sender: TObject);
begin
  MatrixTypeGroup.ItemIndex := 0;
end;

procedure TAvgLinkFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TAvgLinkFrm.ComputeBtnClick(Sender: TObject);
const
  SIM_DIS: array[0..1] of String = ('Similarity', 'Dissimilarity');
VAR
  X : DblDyneMat; // similarity or dissimilarity matrix
  KLUS : IntDyneMat;
  LST : IntDyneVec;
  RX, SAV, SAV2, RRRMIN : double;
  NIN, NVAR : IntDyneVec;
  I, J, K, L, M, MN, N, CRIT, ITR, LIMIT : integer;
  //    ROWS : StrDyneVec;
  nvalues : integer;
  lReport: TStrings;

label
  label300, label60, label70;

begin
   //  Reference:  Anderberg, M. R. (1973).  Cluster analysis for
   //              applications.  New York:  Academic press.
   //
   //  Almost any text on cluster analysis should have a good
   //  description of the average-linkage hierarchical clustering
   //  algorithm.   The algorithm begins with an initial similarity
   //  or dissimilarity matrix between pairs of objects.  The
   //  algorithm proceeds in an iterative way.  At each iteration
   //  the two most similar (we assume similarities for explanation)
   //  objects are combined into one group.  At each successive
   //  iteration, the two most similar objects or groups of objects are
   //  merged.  Similarity between groups is defined as the average
   //  similarity between objects in one group with objects in the other.
   //
   //     INPUT:   A correlation matrix (or some other similarity or
   //              dissimilarity matrix) in a file named MATRIX.DAT
   //              This must contain all the elements of a full
   //              (n x n), symmetrical matrix.  Any format is
   //              allowable, as long as numbers are separated by
   //              blanks.
   //
   //     OUTPUT:  Output consists of a cluster history and a tree
   //              diagram (dendogram).  The cluster history
   //              indicates, for each iteration, the objects
   //              or clusters merged, and the average pairwise
   //              similarity or dissimilarity in the resulting
   //              cluster.
   //
   //  Author:    John Uebersax

  if (NoVariables <= 0) then
  begin
    MessageDlg('You must first load a matrix into the grid.', mtError, [mbOK], 0);
    exit;
  end;

  nvalues := NoVariables;
  SetLength(X,nvalues+1,nvalues+1);
  SetLength(KLUS,nvalues+1,3);
  SetLength(LST,nvalues+1);
  SetLength(NIN,nvalues+1);
  SetLength(NVAR,nvalues+1);

  lReport := TStringList.Create;
  try
    lReport.Add('AVERAGE LINK CLUSTER ANALYSIS');
    lReport.Add('Adopted from ClusBas by John S. Uebersax');
    lReport.Add('');

    // This section does the cluster analysis, taking data from the Main Form.
    // Parameters controlling the analysis are obtained from the dialog form.
    M := nvalues;
    CRIT := MatrixTypeGroup.ItemIndex; // 0 := Similarity, 1 := dissimilarity

    // get matrix of data from OS3MainFrm
    for i := 1 to NoVariables do
    begin
        for j := 1 to NoVariables do
            X[i,j] := StrToFloat(OS3MainFrm.DataGrid.Cells[i,j]);
    end;

    LIMIT := M - 1;
    for i := 1 to M do
    begin
        NVAR[i] := i;
        NIN[i] := 1;
    end;

    // cluster analysis
    ITR := 0;

label300:
    ITR := ITR + 1;
    //
    // determine groups to be merged this iteration
    //
    if (CRIT = 1) then // (BSCAN) dissimilarity matrix
    begin
         // This section looks for the minimum dissimilarity.  It finds
         // element (K, L), where K and L are the most dissimilar objects
         // or groups.
         //
         N := 1;
         RRRMIN := 1000000.0;
         MN := M - 1;
         for i := 1 to MN do
         begin
             N := N + 1;
             for j := N to M do
             begin
                 if (RRRMIN < 0.0) then continue;
                 K := i;
                 L := j;
                 RRRMIN := X[i,j];
             end;
         end;
        RX := RRRMIN;
    end else // SCAN procedure
    begin
        // This section looks for the maximum similarity.  It finds
        // element (K, L), where K and L are the most similar objects or
        // groups.
        //
        N := 1;
        RX := -10000.0;
        for i := 1 to M do
        begin
            N := N + 1;
            for j := N to M do
            begin
                if (RX - X[i,j] > 0.0) then continue;
                K := i;
                L := j;
                RX := X[i,j];
            end;
        end;
    end;

    // ARRANGE
    //
    // This section updates the similarity or dissimilarity matrix.
    // If two objects/groups K and L are merged, it calculates the
    // similarity or dissimilarity of the new group with all other objects
    // or groups.  It does this by averaging the elements in row K of
    // X() with those in row L, and similarly for columns K and L.
    // The new elements are put in row K and column L (K < L).  Row K
    // and column L are deleted.  Columns and rows greater than L are
    // shifted up one column or row to fill in the gap.  The resulting
    // matrix X() thus has one less column and row then at the beginning
    // of the subroutine.

    MN := M - 1;
    SAV := X[K,L];
    SAV2 := X[K,K];
    // Calculate similarity or dissimilarity of group formed by merging I
    // and J to all other groups by averaging the similarities or
    // dissimilarities of I and J with other groups
    for I := 1 to M do
    begin
        X[I,K] := (X[I,K] * NIN[K] + X[I,L] * NIN[L]) / (NIN[K] + NIN[L]);
        X[K,I] := X[I,K];
    end;
    X[K,K] := SAV2 * NIN[K] * (NIN[K] - 1) + X[L,L] * NIN[L] * (NIN[L] - 1);
    X[K,K] := X[K,K] + SAV * 2 * NIN[K] * NIN[L];
    X[K,K] := X[K,K] / ((NIN[K] + NIN[L]) * (NIN[K] + NIN[L] - 1));
    if (L = M) then goto label60;
    for I := 1 to M do
    begin
        // Shift columns after J up one place
        for J := L to MN do X[I,J] := X[I,J+1];
    end;
    for I := L to MN do
    begin
        // Shift rows after J up one place
        for J := 1 to M do X[I,J] := X[I+1,J];
    end;
    NIN[K] := NIN[K] + NIN[L];
    for I := L to MN do NIN[I] := NIN[I+1];
    goto label70;
label60:
    // Update number of objects in each cluster
    NIN[K] := NIN[K] + NIN[L];
label70: // end of ARRANGE procedure

    // continuation of CLUSV1 procedure
    // OUTPUT
    lReport.Add('Group %3d is joined by group %3d. N is %3d ITER: %3d %s: %10.3f', [NVAR[K], NVAR[L], NIN[K], ITR, SIM_DIS[CRIT], RX]);
    {
    if (CRIT = 0) then
        lReport.Add('Group %3d is joined by group %3d. N is %3d ITER: %3d SIM: %10.3f', [NVAR[K], NVAR[L], NIN[K], ITR, RX])
    else
        lReport.Add('Group %3d is joined by group %3d. N is %3d ITER: %3d DIS: %10.3f', [NVAR[K], NVAR[L], NIN[K], ITR, RX]);
    }

    KLUS[ITR,1] := NVAR[K]; // save in KLUS rather than write out to file as in
    KLUS[ITR,2] := NVAR[L]; // original program
    if not(L = M) then
    begin
        MN := M - 1;
        for i := L to MN do NVAR[i] := NVAR[i+1];
    end;
    M := M - 1;
    if (ITR < LIMIT) then goto label300;
    lReport.Add('');
    // End of CLUSV1 procedure

    // do pre-tree processing
    PreTree(nvalues, CRIT, LST, KLUS, lReport);
    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // do TREE procedure
    TreePlot(KLUS, LST, nvalues, lReport);

    DisplayReport(lReport);

  finally
    lReport.Free;
    NVAR := nil;
    NIN := nil;
    LST := nil;
    KLUS := nil;
    X := nil;
  end;
end;

procedure TAvgLinkFrm.TreePlot(Clusters: IntDyneMat; Lst: IntDyneVec;
  NoPoints: integer; AReport: TStrings);
VAR
     outline : array[0..501] of char;
     aline : array[0..82] of char;
     valstr : string;
     tempstr : string;
     plotline : string;
     star : char;
     blank : char;
     col1, col2, colpos1, colpos2 : integer;
     noparts, startcol, endcol : integer;
     Results : StrDyneVec;
     ColPos : IntDyneVec;
     i, j, k, L, linecount, newcol, howlong, count: integer;
begin
     linecount := 1;
     star := '*';
     blank := ' ';
     SetLength(ColPos,NoPoints+2);
     SetLength(Results,NoPoints*2+3);
     //AReport.Add('');

     // store initial column positions of vertical linkages
     for i := 1 to NoPoints do ColPos[Lst[i]] := 4 + (i * 5);

     // create column heading indented 10 spaces
     tempstr := 'UNIT ';
     for i := 1 to NoPoints do
     begin
         valstr := format('%5d',[Lst[i]]);
         tempstr := tempstr + valstr;
     end;
     Results[linecount] := tempstr;
     linecount := linecount + 1;

     // create beginning of vertical linkages
     plotline := 'STEP ';
     for i := 1 to NoPoints do  plotline := plotline + '    *';
     Results[linecount] := plotline;
     linecount := linecount + 1;

     // start dendoplot
     for i := 1 to NoPoints - 1 do
     begin
         outline := '';
         valstr := Format('%5d',[i]); // put step no. first
         outline := valstr;
         // clear remainder of outline
         for j := 5 to (5 + NoPoints * 5) do outline[j] := ' ';
         outline[6 + NoPoints * 5] := #0;
         col1 := Clusters[i,1];
         col2 := Clusters[i,2];
         // find column positions for each variable
         colpos1 := ColPos[col1];
         colpos2 := ColPos[col2];

         for k := colpos1 to colpos2 do outline[k] := star;
         // change column positions 1/2 way between the matched ones
         newcol := colpos1 + ((colpos2 - colpos1) div 2);
         for k := 1 to NoPoints do
            if ((ColPos[k] = colpos1) or (ColPos[k] = colpos2)) then ColPos[k] := newcol;
         for k := 1 to NoPoints do
         begin
             L := ColPos[k];
             if ((L <> colpos1) and (L <> colpos2)) then outline[L] := star;
         end;
         Results[linecount] := outline;
         linecount := linecount + 1;

         // add a line of connectors to next grouping
         outline := '     ';
         for j := 5 to (5 + NoPoints * 5) do outline[j] := blank;
         for j := 1 to NoPoints do
         begin
             colpos1 := ColPos[j];
             outline[colpos1] := star;
         end;
         Results[linecount] := outline;
         linecount := linecount + 1;
     end;

     // output the Results in parts
     // determine number of pages needed for whole plot
     noparts := 0;
     howlong := Length(Results[1]);
     noparts := round(howlong / 80.0);
     if (noparts <= 0) then noparts := 1;

     if (noparts = 1) then // simply print the list
         for i := 0 to linecount - 1 do
             AReport.Add(Results[i])
     else // break lines into strings of 15 units
     begin
         startcol := 0;
         endcol := 80;
         for i := 1 to noparts do
         begin
             AReport.Add('PART %d OUTPUT', [i]);
             for j := 0 to 80 do
               aline[j] := blank;

             for j := 0 to linecount - 1 do
             begin
                 count := 0;
                 outline := Results[j];
                 for k := startcol to endcol do
                 begin
                     aline[count] := outline[k];
                     count := count + 1;
                 end;
                 aline[count+1] := #0;
                 AReport.Add(aline);
             end;
             AReport.Add('');
             startcol := endcol + 1;
             endcol := endcol + 80;
             if (endcol > howlong) then endcol := howlong;
         end;
     end;
     Results := nil;
     ColPos := nil;
end;

procedure TAvgLinkFrm.PreTree(NN, CRIT: integer; LST: IntDyneVec;
  KLUS: IntDyneMat; AReport: TStrings);
VAR
    I, II, J, NI, NJ, L, M, N, Ina, INEND, NHOLD, NLINES, INDX, ICOL, JCOL: integer;
    KSH, JEND, MSH: integer;
    JHOLD, NIN1: IntDyneVec;
    outline: string;
label
  label2015, label2020, label2030, label2040, label2055, label2060;
begin
    // PRETRE procedure
    SetLength(JHOLD,NN+1);
    SetLength(NIN1,NN+1);
//    int NN := nvalues;
    N := NN - 1;
    AReport.Add('No. of objects: %3d', [NN]);
    if (CRIT = 0) then
      AReport.Add('Matrix defined similarities among objects.')
    else
      AReport.Add('Matrix defined dissimilarities among objects.');

    for I := 1 to NN do
    begin
        LST[I] := I;
        NIN1[I] := 1;
    end;

    for II := 1 to N do
    begin
        // name tabs
        I := KLUS[II][1];
        J := KLUS[II][2];
        NI := NIN1[I];
        NJ := NIN1[J];
        L := 1;
label2015:
        if (LST[L] = I) then goto label2020;
        L := L + 1;
        if (L <= NN) then goto label2015;
label2020:
        ICOL := L;
        Ina := ICOL + NI;
        INEND := Ina + NJ - 1;
        L := L + 1;
label2030:
        if (LST[L] = J) then goto label2040;
        L := L + 1;
        if (L <= NN) then goto label2030;
label2040:
        JCOL := L;
        JEND := JCOL + NJ - 1;
        NHOLD := 1;

        // remove J vector and store in HOLD
        for M := JCOL to JEND do
        begin
            JHOLD[NHOLD] := LST[M];
            NHOLD := NHOLD + 1;
        end;

        // shift
        MSH := JEND;
label2055:
        if (MSH = INEND) then goto label2060;
        KSH := MSH - NJ;
        LST[MSH] := LST[KSH];
        MSH := MSH - 1;
        goto label2055;

        // insert hold vector
label2060:
        NHOLD := 1;
        for M := Ina to INEND do
        begin
            LST[M] := JHOLD[NHOLD];
            NHOLD := NHOLD + 1;
        end;
        NIN1[I] := NI + NJ;
    end;

    NLINES := (NN div 20) + 1;
    INDX := 0;
    for I := 1 to NLINES do
    begin
        outline := '      ';
        for J := 1 to 20 do
        begin
            INDX := INDX + 1;
            if (INDX <= NN) then                  // wp: This outline is not printed anywhere !!!
                 outline := outline + Format(' %3d', [LST[INDX]]);
        end;
    end;
    AReport.Add(outline);  // wp: added, without it outline would not be used anywhere

    NIN1 := nil;
    JHOLD := nil;
    // End of PRETRE procedure
end;

initialization
  {$I avglinkunit.lrs}

end.

