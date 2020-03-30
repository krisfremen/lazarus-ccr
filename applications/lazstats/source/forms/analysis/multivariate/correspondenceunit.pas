unit CorrespondenceUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit, ContextHelpUnit, MatrixLib, BlankFrmUnit;

type

  { TCorrespondenceForm }

  TCorrespondenceForm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Memo1: TLabel;
    Panel1: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    ObsChk: TCheckBox;
    CheckPChk: TCheckBox;
    RowCorres: TCheckBox;
    ColCorrChk: TCheckBox;
    BothCorrChk: TCheckBox;
    PlotChk: TCheckBox;
    PropsChk: TCheckBox;
    ExpChk: TCheckBox;
    ChiChk: TCheckBox;
    YatesChk: TCheckBox;
    ShowQChk: TCheckBox;
    QCheckChk: TCheckBox;
    EigenChk: TCheckBox;
    ShowABChk: TCheckBox;
    ColList: TListBox;
    GroupBox1: TGroupBox;
    RowEdit: TEdit;
    RowIn: TBitBtn;
    ColIn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RowOut: TBitBtn;
    ColOut: TBitBtn;
    VarList: TListBox;
    procedure ColInClick(Sender: TObject);
    procedure ColOutClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure plotxy(Xpoints, Ypoints : DblDyneVec; Xmax, Xmin, Ymax,
                    Ymin : double; N : integer;
                    PtLabels : StrDyneVec; titlestr,
                    Xlabel, Ylabel : string);
    procedure RowInClick(Sender: TObject);
    procedure RowOutClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  CorrespondenceForm: TCorrespondenceForm;

implementation

uses
  Math;

{ TCorrespondenceForm }

procedure TCorrespondenceForm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
  VarList.Clear;
  ColList.Clear;
  RowEdit.Text := '';
  RowIn.Enabled := true;
  RowOut.Enabled := false;
  ColIn.Enabled := true;
  ColOut.Enabled := false;
  for i := 1 to NoVariables do
      VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TCorrespondenceForm.ColInClick(Sender: TObject);
VAR i, index : integer;
begin
  index := VarList.Items.Count;
  i := 0;
  while (i < index) do
  begin
      if (VarList.Selected[i]) then
      begin
         ColList.Items.Add(VarList.Items.Strings[i]);
         VarList.Items.Delete(i);
         index := index - 1;
         i := 0;
      end
      else i := i + 1;
  end;
  ColOut.Enabled := true;
end;

procedure TCorrespondenceForm.ColOutClick(Sender: TObject);
VAR index : integer;
begin
  index := ColList.ItemIndex;
  if (index < 0) then
  begin
       ColOut.Enabled := false;
       exit;
  end;
  VarList.Items.Add(ColList.Items.Strings[index]);
  ColList.Items.Delete(index);
end;

procedure TCorrespondenceForm.ComputeBtnClick(Sender: TObject);
VAR
     i, j, RowNo: integer;
     Row, Col, Ncases, Nrows, Ncols, df : integer;
     RowLabels, ColLabels : StrDyneVec;
     ColNoSelected : IntDyneVec;
     cellstring, outline, title: string;
	prompt, xtitle, ytitle : string;
     Freq : IntDyneMat;
     Prop, Expected, CellChi : DblDyneMat;
     ChiSquare, ProbChi, liklihood, probliklihood : double;
     SumX, SumY, VarX, VarY, MantelHaenszel, MHprob : double;
	yates : boolean;
     Adjchisqr, Adjprobchi, phi, pearsonr : double;
     IX, IY : integer;
	CoefCont, CramerV : double;

    Trans : DblDyneMat; // transpose work matrix
    P : DblDyneMat; // relative frequencies (n by q correspondence matrix)
    r : DblDyneVec; // row vector of proportions
    c : DblDyneVec; // column vector of proportions
    Dr : DblDyneMat; // Diagonal matrix of row proportions
    Dc : DblDyneMat; // Diagonal matric of column proportions
    A : DblDyneMat; // n by q matrix whose columns are theleft generalized SVD vectors
    Du : DblDyneMat; // q by q diagonal matrix of singular values
    B : DblDyneMat; // m by q matrix whose columns are the right generalized SVD vectors
    Q : DblDyneMat; // matrix to be decomposed by SVD into U x Da x V'
    U : DblDyneMat; // left column vectors of SVD of Q
    V : DblDyneMat; // right vectors of SVD of Q
    W : DblDyneMat; // work matrix for transposing a matrix
    F : DblDyneMat; // Row Coordinates
    Gc : DblDyneMat; // Column Coordinates
    n, q1: integer;  // number of rows and columns of the P matrix
    largest :integer;
    X, Y : DblDyneVec;
    Xmax, Xmin, Ymax, Ymin, Inertia : double;
    labels : StrDyneVec;
    errorcode : boolean = false;

begin
  SetLength(ColNoSelected,NoVariables+1);
  yates := false;
  RowNo := 0;
  for i := 1 to NoVariables do
  begin
       cellstring := OS3MainFrm.DataGrid.Cells[i,0];
       if (cellstring = RowEdit.Text) then RowNo := i;
  end;
  Nrows := NoCases;
  Ncols := ColList.Items.Count;
  SetLength(RowLabels,Nrows+1);
  SetLength(ColLabels,Ncols+1);

  if (RowNo = 0) then
  begin
     ShowMessage('ERROR! A variable for the row labels was not entered.');
     ColNoSelected := nil;
     RowLabels := nil;
     ColLabels := nil;
     exit;
  end;
  ColNoSelected[0] := RowNo;

  // Get Column labels
  for i := 0 to Ncols-1 do
  begin
     ColLabels[i] := ColList.Items.Strings[i];
     for j := 1 to NoVariables do
     begin
             cellstring := OS3MainFrm.DataGrid.Cells[j,0];
             if (cellstring = ColLabels[i])then  ColNoSelected[i+1] := j;
     end;
  end;

     // Get row labels
  for i := 1 to NoCases do
  begin
     RowLabels[i-1] := OS3MainFrm.DataGrid.Cells[RowNo,i];
  end;

  // allocate and initialize
  SetLength(Freq,Nrows+1,Ncols+1);
  SetLength(Prop,Nrows+1,Ncols+1);
  SetLength(Expected,Nrows,Ncols);
  SetLength(CellChi,Nrows,Ncols);
  for i := 1 to Nrows + 1 do
      for j := 1 to Ncols + 1 do Freq[i-1,j-1] := 0;
 RowLabels[Nrows] := 'Total';
 ColLabels[Ncols] := 'Total';

  // get cell data
  Ncases := 0;
  for i := 1 to NoCases do
  begin
     Row := i;
     for j := 1 to Ncols do
     begin
                Col := ColNoSelected[j];
                Freq[i-1,j-1] := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[Col,Row])));
          Ncases := Ncases + Freq[i-1,j-1];
     end;
  end;
  Freq[Nrows,Ncols] := Ncases;

  // Now, calculate expected values
  // Get row totals first
  for i := 1 to Nrows do
  begin
       for j := 1 to Ncols do
       begin
            Freq[i-1,Ncols] := Freq[i-1,Ncols] + Freq[i-1,j-1];
       end;
  end;
  // Get col totals next
  for j := 1 to Ncols do
  begin
      for i := 1 to Nrows do
      begin
          Freq[Nrows,j-1] := Freq[Nrows,j-1] + Freq[i-1,j-1];
      end;
  end;

  // Then get expected values and cell chi-squares
  ChiSquare := 0.0;
  Adjchisqr := 0.0;
  if ((YatesChk.Checked) and (Nrows = 2) and (Ncols = 2)) then yates := true;
  if ((Nrows > 1) and (Ncols > 1)) then
  begin
     for i := 1 to Nrows do
     begin
       for j := 1 to Ncols do
       begin
            Expected[i-1,j-1] := Freq[Nrows,j-1] * Freq[i-1,Ncols] / Ncases;
            if (Expected[i-1,j-1] > 0.0) then
               CellChi[i-1,j-1] := sqr(Freq[i-1,j-1] - Expected[i-1,j-1]) / Expected[i-1,j-1]
            else
            begin
                 ShowMessage('ERROR! Zero expected value found.');
                 CellChi[i-1,j-1] := 0.0;
            end;
            ChiSquare := ChiSquare + CellChi[i-1,j-1];
       end;
     end;
     df := (Nrows - 1) * (Ncols - 1);
     if (yates = true) then  // 2 x 2 corrected chi-square
     begin
       Adjchisqr := abs((Freq[0,0] * Freq[1,1]) - (Freq[0,1] * Freq[1,0]));
       Adjchisqr := sqr(Adjchisqr - Ncases / 2.0) * Ncases; // numerator
       Adjchisqr := Adjchisqr / (Freq[0,2] * Freq[1,2] * Freq[2,0] * Freq[2,1]);
       Adjprobchi := 1.0 - chisquaredprob(Adjchisqr,df);
     end;
  end;
  if (Nrows = 1) then // equal probability
  begin
     for j := 0 to Ncols - 1 do
     begin
             Expected[0,j] := Ncases / Ncols;
             if (Expected[0,j] > 0) then
                CellChi[0,j] := sqr(Freq[0,j] - Expected[0,j]) / Expected[0,j];
             ChiSquare := ChiSquare + CellChi[0,j];
     end;
     df := Ncols - 1;
  end;

  if (Ncols = 1) then // equal probability
  begin
     for i := 0 to Nrows - 1 do
     begin
             Expected[i,0] := Ncases / Nrows;
             if (Expected[i,0] > 0) then
                CellChi[i,0] := sqr(Freq[i,0] - Expected[i,0]) / Expected[i,0];
             ChiSquare := ChiSquare + CellChi[i,0];
     end;
     df := Nrows - 1;
  end;

  ProbChi := 1.0 - chisquaredprob(ChiSquare,df); // prob. larger chi

 // Print acknowledgements
 OutputFrm.RichEdit.Lines.Add('CORRESPONDENCE ANALYSIS');
 OutputFrm.RichEdit.Lines.Add('Based on formulations of Bee-Leng Lee');
 OutputFrm.RichEdit.Lines.Add('Chapter 11 Correspondence Analysis for ViSta');
 OutputFrm.RichEdit.Lines.Add('Results are based on the Generalized Singular Value Decomposition');
 OutputFrm.RichEdit.Lines.Add('of P := A x D x B where P is the relative frequencies observed,');
 OutputFrm.RichEdit.Lines.Add('A are the left generalized singular vectors,');
 OutputFrm.RichEdit.Lines.Add('D is a diagonal matrix of generalized singular values, and');
 OutputFrm.RichEdit.Lines.Add('B is the transpose of the right generalized singular vectors.');
 OutputFrm.RichEdit.Lines.Add('NOTE: The first value and corresponding vectors are 1 and are');
 OutputFrm.RichEdit.Lines.Add('to be ignored.');
 OutputFrm.RichEdit.Lines.Add('An intermediate step is the regular SVD of the matrix Q := UDV');
 OutputFrm.RichEdit.Lines.Add('where Q := Dr^-1/2 x P x Dc^-1/2 where Dr is a diagonal matrix');
 OutputFrm.RichEdit.Lines.Add('of total row relative frequencies and Dc is a diagonal matrix');
 OutputFrm.RichEdit.Lines.Add('of total column relative frequencies.');
 OutputFrm.ShowModal;

 //Print results to output form
 OutputFrm.RichEdit.Clear;
 OutputFrm.RichEdit.Lines.Add('Chi-square Analysis Results');
 outline := format('No. of Cases := %d',[Ncases]);
 OutputFrm.RichEdit.Lines.Add(outline);
 OutputFrm.RichEdit.Lines.Add('');

 // print tables requested by use
 if (ObsChk.Checked) then
 begin
    IntArrayPrint(Freq, Nrows+1, Ncols+1,'Frequencies',
                  RowLabels, ColLabels,'OBSERVED FREQUENCIES');
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear;

 end;

 if (ExpChk.Checked)then
 begin
      outline := 'EXPECTED FREQUENCIES';
      MAT_PRINT(Expected, Nrows, Ncols, outline, RowLabels, ColLabels, NoCases);
      OutputFrm.ShowModal;
      OutputFrm.RichEdit.Clear;
 end;

 outline := 'ROW PROPORTIONS';
 for i := 1 to Nrows + 1 do
 begin
           for j := 1 to Ncols do
           begin
                if (Freq[i-1,Ncols] > 0.0) then
                     Prop[i-1,j-1] := Freq[i-1,j-1] / Freq[i-1,Ncols]
                else Prop[i-1,j-1] := 0.0;
           end;
           if (Freq[i-1,Ncols] > 0.0) then Prop[i-1,Ncols] := 1.0
           else Prop[i-1,Ncols] := 0.0;
 end;
 if (PropsChk.Checked) then
 begin
     MAT_PRINT(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels, NoCases);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
 end;

 outline := 'COLUMN PROPORTIONS';
 for j := 1 to Ncols + 1 do
 begin
           for i := 1 to Nrows do
           begin
                if (Freq[Nrows,j-1] > 0.0) then
                    Prop[i-1,j-1] := Freq[i-1,j-1] / Freq[Nrows,j-1]
                else Prop[i-1,j-1] := 0.0;
           end;
           if (Freq[Nrows,j-1] > 0.0) then Prop[Nrows,j-1] := 1.0
           else Prop[Nrows,j-1] := 0.0;
 end;
 if (PropsChk.Checked) then
 begin
     MAT_PRINT(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels, NoCases);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
 end;

 outline := 'PROPORTIONS OF TOTAL N';
 for i := 1 to Nrows + 1 do
           for j := 1 to Ncols + 1 do Prop[i-1,j-1] := Freq[i-1,j-1] / Ncases;
 Prop[Nrows,Ncols] := 1.0;
 MAT_PRINT(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels,NoCases);
 OutputFrm.ShowModal;
 OutputFrm.RichEdit.Clear;

 if (ChiChk.Checked) then
 begin
      outline := 'CHI-SQUARED VALUE FOR CELLS';
      MAT_PRINT(CellChi, Nrows, Ncols, outline, RowLabels, ColLabels, NoCases);
      OutputFrm.ShowModal;
      OutputFrm.RichEdit.Clear;
 end;

 OutputFrm.RichEdit.Lines.Add('');
 outline := format('Chi-square := %8.3f with D.F. := %d. Prob. > value := %8.3f',[ChiSquare,df,ProbChi]);
 OutputFrm.RichEdit.Lines.Add(outline);
 OutputFrm.RichEdit.Lines.Add('');

 if (yates = true) then
 begin
      outline := format('Chi-square using Yates correction = %8.3f and Prob > value := %8.3f',
              [Adjchisqr,Adjprobchi]);
      OutputFrm.RichEdit.Lines.Add(outline);
 end;

 liklihood := 0.0;
 for i := 0 to Nrows - 1 do
     for j := 0 to Ncols - 1 do
          if (Freq[i,j] > 0.0) then liklihood :=  liklihood + Freq[i,j] * (ln(Expected[i,j] / Freq[i,j]));
 liklihood := -2.0 * liklihood;
 probliklihood := 1.0 - chisquaredprob(liklihood,df);
 outline := format('Liklihood Ratio := %8.3f with prob. > value := %6.4f',[liklihood,probliklihood]);
 OutputFrm.RichEdit.Lines.Add(outline);
 OutputFrm.RichEdit.Lines.Add('');

 if ((Nrows > 1) and (Ncols > 1)) then
 begin
     phi := sqrt(ChiSquare / Ncases);
     outline := format('phi correlation := %6.4f',[phi]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');

     pearsonr := 0.0;
     SumX := 0.0;
     SumY := 0.0;
     VarX := 0.0;
     VarY := 0.0;
     for i := 0 to Nrows - 1 do SumX := SumX + ( (i+1) * Freq[i,Ncols] );
     for j := 0 to Ncols - 1 do SumY := SumY +( (j+1) * Freq[Nrows,j] );
     for i := 0 to Nrows - 1 do VarX := VarX + ( ((i+1)*(i+1)) * Freq[i,Ncols] );
     for j := 0 to Ncols - 1 do VarY := VarY +( ((j+1)*(j+1)) * Freq[Nrows,j] );
     VarX := VarX - ((SumX * SumX) / Ncases);
     VarY := VarY - ((SumY * SumY) / Ncases);
     for i := 0 to Nrows - 1 do
             for j := 0 to Ncols - 1 do
                     pearsonr := pearsonr + ((i+1)*(j+1) * Freq[i,j]);
     pearsonr := pearsonr - (SumX * SumY / Ncases);
     pearsonr := pearsonr / sqrt(VarX * VarY);
     outline := format('Pearson Correlation r := %6.4f',[pearsonr]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');

     MantelHaenszel := (Ncases-1) * (pearsonr * pearsonr);
     MHprob := 1.0 - chisquaredprob(MantelHaenszel,1);
     outline := format('Mantel-Haenszel Test of Linear Association := %8.3f with probability > value := %6.4f',
         [MantelHaenszel, MHprob]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');

     CoefCont := sqrt(ChiSquare / (ChiSquare + Ncases));
     outline := format('The coefficient of contingency := %8.3f',[CoefCont]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');

     if (Nrows < Ncols) then CramerV := sqrt(ChiSquare / (Ncases *  (Nrows-1)))
     else CramerV := sqrt(ChiSquare / (Ncases * ((Ncols-1))));
     outline := format('Cramers V := %8.3f',[CramerV]);
     OutputFrm.RichEdit.Lines.Add(outline);
 end;
 OutputFrm.ShowModal;
 OutputFrm.RichEdit.Clear;

 n := Nrows;
 q1 := Ncols;
 if (n > q1) then largest := n
 else largest := q1;
 SetLength(P,n,q1);
 SetLength(r,largest+1);
 SetLength(c,q1);
 SetLength(Dr,n,n);
 SetLength(Dc,q1,q1);
 SetLength(A,n,q1);
 SetLength(Du,largest,largest);
 SetLength(B,n,q1);
 SetLength(Q,n,q1);
 SetLength(U,n,n);
 SetLength(V,q1,q1);
 SetLength(W,largest+1,largest+1);
 SetLength(Trans,q1,q1);
 SetLength(F,n,q1);
 SetLength(Gc,q1,q1);

 // get proportion matices and vectors
 for i := 0 to n - 1 do
     for j := 0 to q1 - 1do P[i,j] := Prop[i,j];
 for i := 0 to n - 1 do r[i] := Prop[i,q1];
 for j := 0 to q1 - 1 do c[j] := Prop[n,j];

 // get Dr^-1/2 and Dc^-1/2
 for i := 0 to n - 1 do
 begin
     for j := 0 to n - 1 do
     begin
             if (i <> j) then Dr[i,j] := 0.0
             else Dr[i,j] := 1.0 / sqrt(r[i]);
     end;
 end;
 for i := 0 to q1 - 1 do
 begin
     for j := 0 to q1 -1 do
     begin
             if (i <> j) then Dc[i,j] := 0.0
             else Dc[i,j] := 1.0 / sqrt(c[j]);
     end;
 end;

 // get q1 := Dr^-1/2 times P times Dc^-1/2
 MATAxB(W,Dr,P,n,n,n,q1,errorcode);
 MATAxB(q,W,Dc,n,q1,q1,q1,errorcode);
 if (ShowqChk.Checked) then
 begin
     outline := 'Q Matrix';
     MAT_PRINT(q,n,q1,outline,RowLabels,ColLabels,NoCases);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
(*
     Instr := InputBox('Save q1 to Main Grid?','Y','N');
     if (Instr = 'Y') then
     begin
             OS3MainFrm.CloseFileBtnClick(self);
             OS3MainFrm.DataGrid.RowCount := n + 1;
             OS3MainFrm.DataGrid.ColCount := q1 + 1;
             for i := 0 to n - 1 do
                     for j := 0 to q1 - 1 do
                             OS3MainFrm.DataGrid.Cells[j+1,i+1] := q1[i,j];
             for i := 1 to n do
                     OS3MainFrm.DataGrid.Cells[0,i] := 'CASE ' + IntToStr(i);
             for j := 1 to q1 do
                     OS3MainFrm.DataGrid.Cells[j,0] := 'VAR' + IntToStr(j);
     end;
 end;
*)
 //Obtain ordinary SVD analysis of q1
 matinv(q,U,Du,V,q1);

 if (EigenChk.Checked) then
 begin
     outline := 'U Matrix';
     MAT_PRINT(U,n,q1,outline,RowLabels,ColLabels,NoCases);
     outline := 'Singular Values';
     MAT_PRINT(Du,q1,q1,outline,ColLabels,ColLabels,NoCases);
     outline := 'V Matrix';
     MAT_PRINT(V,q1,q1,outline,ColLabels,ColLabels,NoCases);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
 end;
 if (qCheckChk.Checked) then
 begin
     // Check to see if q1 is reproduced by U x D x V'
     MATAxB(W,U,Du,n,q1,q1,q1,errorcode);
     for i := 0 to q1 - 1 do
             for j := 0 to q1 - 1 do Trans[i,j] := V[j,i];
     MATAxB(q,W,Trans,n,q1,q1,q1,errorcode);
     outline := 'Reproduced Q = UDV';
     MAT_PRINT(q,n,q1,outline,RowLabels,ColLabels,NoCases);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
 end;

 // Get A := Dr^1/2 times U
 for i := 0 to n - 1 do
 begin
     for j := 0 to n - 1 do
     begin
             if (i <> j) then Dr[i,j] := 0.0
             else Dr[i,j] := sqrt(r[i]);
     end;
 end;
 MATAxB(A,Dr,U,n,n,n,q1,errorcode);
 if (ShowABChk.Checked) then
 begin
      outline := 'A Matrix';
      MAT_PRINT(A,n,q1,outline,RowLabels,ColLabels,NoCases);
      OutputFrm.ShowModal;
      OutputFrm.RichEdit.Clear;
 end;

 // Get B := Dc^1/2 times V
 for i := 0 to q1 - 1 do
 begin
     for j := 0 to q1-1 do
     begin
             if (i <> j) then Dc[i,j] := 0.0
             else Dc[i,j] := sqrt(c[j]);
     end;
 end;
 MATAxB(B,Dc,V,q1,q1,q1,q1,errorcode);
 if (ShowABChk.Checked) then
 begin
      outline := 'B Matrix';
      MAT_PRINT(B,q1,q1,outline,ColLabels,ColLabels,NoCases);
      OutputFrm.ShowModal;
      OutputFrm.RichEdit.Clear;
 end;

 if (CheckPChk.Checked) then
 begin    // see if P := A x Du x B'
     for i := 0 to q1 - 1 do
             for j := 0 to q1 - 1 do Trans[j,i] := B[i,j];
     MATAxB(W,A,Du,n,q1,q1,q1,errorcode);
     MATAxB(P,W,Trans,n,q1,q1,q1,errorcode);
     outline := 'P = ';
     MAT_PRINT(P,n,q1,outline,RowLabels,ColLabels,NoCases);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
 end;

 // show intertia and scree plot
 Inertia := ChiSquare / Freq[Nrows,Ncols];
 outline := format('Inertia := %8.4f',[Inertia]);
 OutputFrm.RichEdit.Lines.Add(outline);
 OutputFrm.RichEdit.Lines.Add('');
 OutputFrm.ShowModal;
 OutputFrm.RichEdit.Clear;
 if (PlotChk.Checked) then
 begin
     SetLength(X,n);
     SetLength(Y,n);
     SetLength(labels,q1);
     Xmax := -10000.0;
     Ymax := Xmax;
     Xmin := 10000.0;
     Ymin := Xmin;
     X[0] := 1;
     Y[0] := sqr(Du[1,1]);
     for i := 1 to q1 - 1 do
     begin
             X[i] := i;
             Y[i] := sqr(Du[i,i]);
             outline := format('%4.3f%',[(Y[i] / Inertia)*100.0]);
             labels[i] := outline; // 'Dim.' + IntToStr(i);
             if (X[i] > Xmax) then Xmax := X[i];
             if (X[i] < Xmin) then Xmin := X[i];
             if (Y[i] > Ymax) then Ymax := Y[i];
             if (Y[i] < Ymin) then Ymin := Y[i];
     end;
     title := 'Goodness of Fit Plot';
     plotxy(X,Y,Xmax,Xmin,Ymax,Ymin,q1,labels, title,'Dimension',' ');
     BlankFrm.ShowModal;
     labels := nil;
     Y := nil;
     X := nil;
 end;

//    if (RowCorres.Checked)then
//    begin
     // Get Row coordinates F (for row profile analysis)
     for i := 0 to n - 1 do
     begin
             for j := 0 to n - 1 do
             begin
                     if (i <> j) then Dr[i,j] := 0.0
                     else Dr[i,j] := 1.0 / r[i];
             end;
     end;
     MATAxB(W,Dr,A,n,n,n,q1,errorcode);
//        ArrayPrint(W,n,q1,'Dr x A matrix',RowLabels,ColLabels,'Dr x A Matrix');
//        FrmOutPut.ShowModal;
     MATAxB(F,W,Du,n,q1,q1,q1,errorcode);
     if (RowCorres.Checked) then
     begin
         outline := 'Row Dimensions (Ignore Col. 1';
         MAT_PRINT(F,n,q1,outline,RowLabels,ColLabels,NoCases);
         OutputFrm.ShowModal;
         OutputFrm.RichEdit.Clear;
     end;
     // Get Column coordinates G (row profile analysis)
     for i := 0 to q1 - 1 do
     begin
             for j := 0 to q1 - 1 do
             begin
                     if (i <> j) then Dc[i,j] := 0.0
                     else Dc[i,j] := 1.0 / c[j];
             end;
     end;
     MATAxB(Gc,Dc,B,q1,q1,q1,q1,errorcode);
     if (RowCorres.Checked) then
     begin
             outline := 'Col. Dimensions (Ignore Col. 1';
             MAT_PRINT(Gc,q1,q1,outline,ColLabels,ColLabels,NoCases);
             OutputFrm.ShowModal;
             OutputFrm.RichEdit.Clear;
     end;
     if ((PlotChk.Checked) and (RowCorres.Checked))then
     begin
             prompt := InputBox('X Axis Dimension','1','1');
             IX := StrToInt(prompt);
             prompt := InputBox('Y Axis Dimension','2','2');
             IY := StrToInt(prompt);
             xtitle := 'Dimension ' + IntToStr(IX);
             ytitle := 'Dimension ' + IntToStr(IY);
             SetLength(X,n);
             SetLength(Y,n);
             Xmax := -10000.0;
             Ymax := Xmax;
             Xmin := 10000.0;
             Ymin := Xmin;
             for i := 0 to n - 1 do
             begin
                     X[i] := F[i,IX];
                     if (X[i] > Xmax) then Xmax := X[i];
                     if (X[i] < Xmin) then Xmin := X[i];
                     Y[i] := F[i,IY];
                     if (Y[i] > Ymax) then Ymax := Y[i];
                     if (Y[i] < Ymin) then Ymin := Y[i];
             end;
             title := 'Row Dimensions';
             plotxy(X,Y,Xmax,Xmin,Ymax,Ymin,n,RowLabels, title,xtitle,ytitle);
             BlankFrm.ShowModal;
             Y := nil;
             X := nil;
             SetLength(X,q1);
             SetLength(Y,q1);
             Xmax := -10000.0;
             Ymax := Xmax;
             Xmin := 10000.0;
             Ymin := Xmin;
             for i := 0 to q1 - 1 do
             begin
                     X[i] := Gc[i,IX];
                     if (X[i] > Xmax) then Xmax := X[i];
                     if (X[i] < Xmin) then Xmin := X[i];
                     Y[i] := Gc[i,IY];
                     if (Y[i] > Ymax) then Ymax := Y[i];
                     if (Y[i] < Ymin) then Ymin := Y[i];
             end;
             title := 'Column Dimensions';
             plotxy(X,Y,Xmax,Xmin,Ymax,Ymin,q1,ColLabels, title,xtitle,ytitle);
             BlankFrm.ShowModal;
             Y := nil;
             X := nil;
     end;
//    end;

 // do column correspondence analysis if checked
//    if (ColCorrChk.Checked) then
//    begin
     for i := 0 to q1 - 1 do
        for j := 0 to q1 - 1 do W[i,j] := Gc[i,j]; // use last Gc
     MATAxB(Gc,W,Du,q1,q1,q1,q1,errorcode); // multiply times Du
     if (ColCorrChk.Checked) then
     begin
             outline := 'Column Dimensions (Ignore Col. 1';
             MAT_PRINT(Gc,q1,q1,outline,ColLabels,ColLabels,NoCases);
             OutputFrm.ShowModal;
     end;
     MATAxB(F,Dr,A,n,n,n,q1,errorcode); // Get new F
     if (ColCorrChk.Checked) then
     begin
             outline := 'Row Dimensions (Ignore Col. 1)';
             MAT_PRINT(F,n,q1,outline,RowLabels,ColLabels,NoCases);
             OutputFrm.ShowModal;
             OutputFrm.RichEdit.Clear;
     end;
     if ((PlotChk.Checked) and (ColCorrChk.Checked)) then
     begin
             prompt := InputBox('X Axis Dimension','1','1');
             IX := StrToInt(prompt);
             prompt := InputBox('Y Axis Dimension','2','2');
             IY := StrToInt(prompt);
             SetLength(X,q1);
             SetLength(Y,q1);
             xtitle := 'Dimension ' + IntToStr(IX);
             ytitle := 'Dimension ' + IntToStr(IY);
             Xmax := -10000.0;
             Ymax := Xmax;
             Xmin := 10000.0;
             Ymin := Xmin;
             for i := 0 to q1 - 1 do
             begin
                     X[i] := Gc[i,IX];
                     if (X[i] > Xmax) then Xmax := X[i];
                     if (X[i] < Xmin) then Xmin := X[i];
                     Y[i] := Gc[i,IY];
                     if (Y[i] > Ymax) then Ymax := Y[i];
                     if (Y[i] < Ymin) then Ymin := Y[i];
             end;
             title := 'Column Dimensions';
             plotxy(X,Y,Xmax,Xmin,Ymax,Ymin,q1,ColLabels, title,xtitle,ytitle);
             BlankFrm.ShowModal;
             Y := nil;
             X := nil;
             SetLength(X,n);
             SetLength(Y,n);
             Xmax := -10000.0;
             Ymax := Xmax;
             Xmin := 10000.0;
             Ymin := Xmin;
             for i := 0 to n - 1 do
             begin
                     X[i] := F[i,IX];
                     if (X[i] > Xmax) then Xmax := X[i];
                     if (X[i] < Xmin) then Xmin := X[i];
                     Y[i] := F[i,IY];
                     if (Y[i] > Ymax) then Ymax := Y[i];
                     if (Y[i] < Ymin) then Ymin := Y[i];
             end;
             title := 'Row Dimensions';
             plotxy(X,Y,Xmax,Xmin,Ymax,Ymin,n,RowLabels, title,xtitle,ytitle);
             BlankFrm.ShowModal;
             Y := nil;
             X := nil;
     end;
//    end;

 // do both if checked
 if (BothCorrChk.Checked) then
 begin
     // F is same as for Row correspondence and Gc is same as for columns
     for i := 0 to n - 1 do
             for j := 0 to q1 - 1 do W[i,j] := F[i,j];
     MATAxB(F,W,Du,n,q1,q1,q1,errorcode);
     outline := 'Row Dimensions (Ignore Col. 1';
     MAT_PRINT(F,n,q1,outline,RowLabels,ColLabels,NoCases);
     OutputFrm.ShowModal;
     outline := 'Column Dimensions (Ignore Col. 1)';
     MAT_PRINT(Gc,q1,q1,outline,ColLabels,ColLabels,NoCases);
     OutputFrm.ShowModal;
     if (PlotChk.Checked)then
     begin
             prompt := InputBox('X Axis Dimension','1','1');
             IX := StrToInt(prompt);
             prompt := InputBox('Y Axis Dimension','2','2');
             IY := StrToInt(prompt);
             xtitle := 'Dimension ' + IntToStr(IX);
             ytitle := 'Dimension ' + IntToStr(IY);
             SetLength(X,n);
             SetLength(Y,n);
             Xmax := -10000.0;
             Ymax := Xmax;
             Xmin := 10000.0;
             Ymin := Xmin;
             for i := 0 to n - 1 do
             begin
                     X[i] := F[i,IX];
                     if (X[i] > Xmax) then Xmax := X[i];
                     if (X[i] < Xmin) then Xmin := X[i];
                     Y[i] := F[i,IY];
                     if (Y[i] > Ymax) then Ymax := Y[i];
                     if (Y[i] < Ymin) then Ymin := Y[i];
             end;
             title := 'Row Dimensions';
             plotxy(X,Y,Xmax,Xmin,Ymax,Ymin,n,RowLabels, title,xtitle,ytitle);
             BlankFrm.ShowModal;
             Y := nil;
             X := nil;
             SetLength(X,q1);
             SetLength(Y,q1);
             Xmax := -10000.0;
             Ymax := Xmax;
             Xmin := 10000.0;
             Ymin := Xmin;
             for i := 0 to q1 - 1 do
             begin
                     X[i] := Gc[i,IX];
                     if (X[i] > Xmax) then Xmax := X[i];
                     if (X[i] < Xmin) then Xmin := X[i];
                     Y[i] := Gc[i,IY];
                     if (Y[i] > Ymax) then Ymax := Y[i];
                     if (Y[i] < Ymin) then Ymin := Y[i];
             end;
             title := 'Column Dimensions';
             plotxy(X,Y,Xmax,Xmin,Ymax,Ymin,q1,ColLabels, title,xtitle,ytitle);
             BlankFrm.ShowModal;
             Y := nil;
             X := nil;
     end;
 end;
//    FrmOutPut.ShowModal;

// clean up memory
 Gc := nil;
 F := nil;
 Trans := nil;
 W := nil;
 V := nil;
 q := nil;
 B := nil;
 Du := nil;
 A := nil;
 Dc := nil;
 Dr := nil;
 c := nil;
 r := nil;
 P := nil;
 ColLabels := nil;
 RowLabels := nil;
 CellChi := nil;
 Expected := nil;
 Prop := nil;
 Freq := nil;
 ColNoSelected := nil;
end;
end;

procedure TCorrespondenceForm.FormActivate(Sender: TObject);
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

procedure TCorrespondenceForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TCorrespondenceForm.HelpBtnClick(Sender: TObject);
begin
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TCorrespondenceForm.plotxy(Xpoints, Ypoints : DblDyneVec; Xmax, Xmin, Ymax,
                Ymin : double; N : integer;
                PtLabels : StrDyneVec; titlestr,
                Xlabel, Ylabel : string);
VAR
    i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide :integer;
    vhi, hwide, offset, strhi, imagehi : integer;
    valincr, Yvalue, Xvalue, value : double;
    Title, astring, outline : string;

begin
 Title := 'X versus Y PLOT';
 BlankFrm.Caption := Title;
 imagewide := BlankFrm.Image1.Width;
 imagehi := BlankFrm.Image1.Height;
 BlankFrm.Image1.Canvas.FloodFill(0,0,clYellow,fsBorder);
 vtop := 20;
 vbottom := round(imagehi) - 80;
 vhi := vbottom - vtop;
 hleft := 100;
 hright := imagewide - 80;
 hwide := hright - hleft;
 BlankFrm.Image1.Canvas.Pen.Color := clBlack;
 BlankFrm.Image1.Canvas.Brush.Color := clWhite;

 // Draw chart border
 BlankFrm.Image1.Canvas.Rectangle(0,0,imagewide,imagehi);

 // draw horizontal axis
 BlankFrm.Image1.Canvas.Pen.Color := clBlack;
 BlankFrm.Image1.Canvas.MoveTo(hleft,vbottom);
 BlankFrm.Image1.Canvas.LineTo(hright,vbottom);
 valincr := (Xmax - Xmin) / 10.0;
 for i := 1 to 11 do
 begin
      ypos := vbottom;
      Xvalue := Xmin + valincr * (i - 1);
      xpos := round(hwide * ((Xvalue - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
      ypos := ypos + 10;
      BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
      outline := format('%6.2f',[Xvalue]);
      Title := outline;
      offset := BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
      xpos := xpos - offset;
      BlankFrm.Image1.Canvas.Pen.Color := clBlack;
      BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
 end;
 astring := Xlabel; // 'Dimension 1';
 xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(astring) div 2);
 ypos := vbottom + 20;
 BlankFrm.Image1.Canvas.TextOut(xpos,ypos,astring);

 // Draw vertical axis
 Title := Ylabel; // 'Dimension 2';
 xpos := hleft - BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
 ypos := vtop - BlankFrm.Image1.Canvas.TextHeight(Title);
 BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
 xpos := hleft;
 ypos := vtop;
 BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
 ypos := vbottom;
 BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
 valincr := (Ymax - Ymin) / 10.0;
 for i := 1 to 11 do
 begin
      value := Ymax - ((i-1) * valincr);
      outline := format('%8.3f',[value]);
      Title := outline;
      strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
      xpos := 10;
      Yvalue := Ymax - (valincr * (i-1));
      ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
      ypos := ypos + vtop - strhi div 2;
      BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
      xpos := hleft;
      ypos := ypos + strhi div 2;
      BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
      xpos := hleft - 10;
      BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
 end;

 // draw points for x and y pairs
 BlankFrm.Image1.Canvas.Font.Size :=  8;
 for i := 0 to N - 1 do
 begin
      ypos := round(vhi * ( (Ymax - Ypoints[i]) / (Ymax - Ymin)));
      ypos := ypos + vtop;
      xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      BlankFrm.Image1.Canvas.Brush.Color := clNavy;
      BlankFrm.Image1.Canvas.Brush.Style := bsSolid;
      BlankFrm.Image1.Canvas.Pen.Color := clNavy;
      BlankFrm.Image1.Canvas.Ellipse(xpos,ypos,xpos+5,ypos+5);
      BlankFrm.Image1.Canvas.Pen.Color := clBlack;
      BlankFrm.Image1.Canvas.Brush.Color := clWhite;
      BlankFrm.Image1.Canvas.TextOut(xpos+3,ypos-5,PtLabels[i]);
 end;
 xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(titlestr) div 2);
 ypos := vbottom + 40;
 BlankFrm.Image1.Canvas.TextOut(xpos,ypos,titlestr);
end;

procedure TCorrespondenceForm.RowInClick(Sender: TObject);
VAR
  index : integer;
begin
  index := VarList.ItemIndex;
  RowEdit.Text := VarList.Items.Strings[index];
  VarList.Items.Delete(index);
  RowIn.Enabled := false;
  RowOut.Enabled := true;
end;

procedure TCorrespondenceForm.RowOutClick(Sender: TObject);
begin
  VarList.Items.Add(RowEdit.Text);
  RowEdit.Text := '';
  RowIn.Enabled := true;
  RowOut.Enabled := false;
end;

initialization
  {$I correspondenceunit.lrs}

end.

