unit RIDITUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit, MatrixLib, ContextHelpUnit;

type

  { TRIDITFrm }

  TRIDITFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    BonChk: TCheckBox;
    AlphaEdit: TEdit;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ReturnBtn: TButton;
    ComputeBtn: TButton;
    Label5: TLabel;
    ObsChk: TCheckBox;
    ExpChk: TCheckBox;
    PropChk: TCheckBox;
    ChiChk: TCheckBox;
    RefGrp: TRadioGroup;
    YatesChk: TCheckBox;
    DetailsChk: TCheckBox;
    ColList: TListBox;
    GroupBox1: TGroupBox;
    RefEdit: TEdit;
    Label4: TLabel;
    RowEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    RowIn: TBitBtn;
    RowOut: TBitBtn;
    ColIn: TBitBtn;
    ColOut: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure ColInClick(Sender: TObject);
    procedure ColListClick(Sender: TObject);
    procedure ColOutClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure RefGrpClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure RowInClick(Sender: TObject);
    procedure RowOutClick(Sender: TObject);
    procedure Analyze(RefCol : integer; ColNoSelected : IntDyneVec;
              RowLabels : StrDyneVec; ColLabels : StrDyneVec;
              NoToAnalyze : integer; Freq : IntDyneMat;
              Props : DblDyneMat; NoRows : integer);

  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  RIDITFrm: TRIDITFrm;

implementation

uses
  Math;

{ TRIDITFrm }

procedure TRIDITFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     ColList.Clear;
     RowEdit.Text := '';
     RefEdit.Text := '';
     AlphaEdit.Text := '0.05';
     BonChk.Checked := true;
     RowIn.Enabled := true;
     RowOut.Enabled := false;
     ColIn.Enabled := true;
     ColOut.Enabled := false;
     Label4.Visible := false;
     RefEdit.Visible := false;
     RefGrp.ItemIndex := 1;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TRIDITFrm.RowInClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     RowEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     RowIn.Enabled := false;
     RowOut.Enabled := true;
end;

procedure TRIDITFrm.RowOutClick(Sender: TObject);
begin
     VarList.Items.Add(RowEdit.Text);
     RowEdit.Text := '';
     RowIn.Enabled := true;
     RowOut.Enabled := false;
end;

procedure TRIDITFrm.FormActivate(Sender: TObject);
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

procedure TRIDITFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TRIDITFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TRIDITFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TRIDITFrm.RefGrpClick(Sender: TObject);
begin
        if (RefGrp.ItemIndex = 0) then // do all variables as reference variable
        begin
                Label4.Visible := false;
                RefEdit.Visible := false;
        end
        else
        begin
                Label4.Visible := true;
                RefEdit.Visible := true;
        end;
end;

procedure TRIDITFrm.ColInClick(Sender: TObject);
VAR index, i : integer;
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

procedure TRIDITFrm.ColListClick(Sender: TObject);
VAR index : integer;
begin
        index := ColList.ItemIndex;

        RefEdit.Text := ColList.Items.Strings[index];

end;

procedure TRIDITFrm.ColOutClick(Sender: TObject);
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

procedure TRIDITFrm.ComputeBtnClick(Sender: TObject);
VAR
     AllRefs : boolean;
     i, j, RowNo, RefColNo, NoToAnalyze : integer;
     Row, Col, Ncases, Nrows, Ncols, df : integer;
     RowLabels, ColLabels : StrDyneVec;
     ColNoSelected : IntDyneVec;
     cellstring : string;
     outline : string;
     Freq : IntDyneMat;
     Prop, Expected, CellChi : DblDyneMat;
     ChiSquare, ProbChi : double;
     yates : boolean;
     Adjchisqr, Adjprobchi: double;
     liklihood, probliklihood, phi : double;
     pearsonr, VarX, VarY, SumX, SumY, MantelHaenszel, MHProb, CoefCont : double;
     CramerV : double;
begin
     AllRefs := true;
     if (RefGrp.ItemIndex = 1) then AllRefs := false;
     SetLength(ColNoSelected,NoVariables+1);
     yates := false;
     RowNo := 0;
     for i := 1 to NoVariables do
     begin
          cellstring := OS3MainFrm.DataGrid.Cells[i,0];
          if (cellstring = RowEdit.Text) then RowNo := i;
     end;
{
     results := VarTypeChk(RowNo,2);
     if (result = 1)
     begin
        delete[] ColNoSelected;
        return;
     end;
}
     Nrows := NoCases;
     Ncols := ColList.Items.Count;
     SetLength(RowLabels,Nrows+1);
     SetLength(ColLabels,Ncols+1);

     if (RowNo = 0) then
     begin
        ShowMessage('ERROR! A variable for the row labels was not entered.');
        ColNoSelected := nil;
        exit;
     end;
     ColNoSelected[0] := RowNo;

     // Get Column labels
     for i := 0 to Ncols - 1 do
     begin
        ColLabels[i] := ColList.Items.Strings[i];
        for j := 1 to NoVariables do
        begin
                cellstring := OS3MainFrm.DataGrid.Cells[j,0];
                if (cellstring = ColLabels[i]) then
                begin
                        ColNoSelected[i+1] := j;
                       { result := VarTypeChk(j,1);
                        if (result = 1)
                        begin
                                delete[] ColLabels;
                                delete[] RowLabels;
                                delete[] ColNoSelected;
                                return;
                        end; }
                end;
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
                   Freq[i-1,j-1] := StrToInt(OS3MainFrm.DataGrid.Cells[Col,Row]);
//                   result := GetValue(Row,Col,intvalue,dblvalue,strvalue);
//                   if (result = 1) Freq[i-1][j-1] := 0;
//                   else Freq[i-1][j-1] := intvalue;
                   Ncases := Ncases + Freq[i-1,j-1];
        end;
     end;
     Freq[Nrows][Ncols] := Ncases;

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
                  CellChi[i-1,j-1] := sqr(Freq[i-1,j-1] - Expected[i-1,j-1])
                                    / Expected[i-1,j-1]
               else
               begin
                    ShowMessage('ERROR! Zero expected value found.');
                    CellChi[i-1,j-1] := 0.0;
               end;
               ChiSquare := ChiSquare + CellChi[i-1,j-1];
          end;
        end;
        df := (Nrows - 1) * (Ncols - 1);
        if (yates = true) then // 2 x 2 corrected chi-square
        begin
          Adjchisqr := abs((Freq[0,0] * Freq[1,1]) - (Freq[0,1] * Freq[1,0]));
          Adjchisqr := sqr(Adjchisqr - Ncases / 2.0) * Ncases; // numerator
          Adjchisqr := Adjchisqr / (Freq[0,2] * Freq[1,2] * Freq[2,0] * Freq[2,1]);
          Adjprobchi := 1.0 - chisquaredprob(Adjchisqr,df);
        end;
     end;
     if (Nrows = 1)  then // equal probability
     begin
        for j := 0 to Ncols - 1 do
        begin
                Expected[0,j] := Ncases / Ncols;
                if (Expected[0][j] > 0) then
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

    //Print results to output form
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('Chi-square Analysis Results');
    outline := format('No. of Cases = %d',[Ncases]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');

    // print tables requested by use
    if (ObsChk.Checked) then
    begin
       IntArrayPrint(Freq, Nrows+1, Ncols+1,'Frequencies',
                     RowLabels, ColLabels,'OBSERVED FREQUENCIES');
    end;

    if (ExpChk.Checked) then
    begin
         outline := 'EXPECTED FREQUENCIES';
         MAT_PRINT(Expected, Nrows, Ncols, outline, RowLabels, ColLabels,
                    NoCases);
    end;

    if (PropChk.Checked) then outline := 'ROW PROPORTIONS';
    for i := 1 to Nrows + 1 do
    begin
              for j := 1 to Ncols do
              begin
                   if (Freq[i-1,Ncols] > 0.0) then
                        Prop[i-1,j-1] := Freq[i-1,j-1] / Freq[i-1,Ncols]
                        else Prop[i-1,j-1] := 0.0;
              end;
              if (Freq[i-1,Ncols] > 0.0) then  Prop[i-1,Ncols] := 1.0
              else Prop[i-1,Ncols] := 0.0;
    end;
    if (PropChk.Checked) then
       MAT_PRINT(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels,
                    NoCases);
    if (PropChk.Checked) then outline := 'COLUMN PROPORTIONS';
    for j := 1 to Ncols + 1 do
    begin
              for i := 1 to Nrows do
              begin
                   if (Freq[Nrows,j-1] > 0.0) then
                       Prop[i-1,j-1] :=  Freq[i-1,j-1] / Freq[Nrows,j-1]
                   else Prop[i-1,j-1] := 0.0;
              end;
              if (Freq[Nrows,j-1] > 0.0) then  Prop[Nrows,j-1] := 1.0
              else Prop[Nrows,j-1] := 0.0;
    end;
    if (PropChk.Checked) then
         MAT_PRINT(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels,
                    NoCases);

    if (ChiChk.Checked) then
    begin
         outline := 'CHI-SQUARED VALUE FOR CELLS';
         MAT_PRINT(CellChi, Nrows, Ncols, outline, RowLabels, ColLabels,
                    NoCases);
    end;

    OutputFrm.RichEdit.Lines.Add('');
    outline := format('Chi-square = %8.3f with D.F. = %d. Prob. > value = %8.3f',
                    [ChiSquare,df,ProbChi]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');
    if (yates = true) then
    begin
         outline := format('Chi-square using Yates correction = %8.3f and Prob > value = %8.3f',
                 [Adjchisqr,Adjprobchi]);
         OutPutFrm.RichEdit.Lines.Add(outline);
    end;

    liklihood := 0.0;
    for i := 0 to Nrows - 1 do
        for j := 0 to Ncols - 1 do
             if (Freq[i,j] > 0.0) then
               liklihood := liklihood + Freq[i,j] * (ln(Expected[i,j] / Freq[i,j]));
    liklihood := -2.0 * liklihood;
    probliklihood := 1.0 - chisquaredprob(liklihood,df);
    outline := format('Liklihood Ratio = %8.3f with prob. > value = %6.4f',
            [liklihood,probliklihood]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');

    if ((Nrows > 1) and (Ncols > 1)) then
    begin
        phi := sqrt(ChiSquare / Ncases);
        outline := format('phi correlation = %6.4f',[phi]);
        OutputFrm.RichEdit.Lines.Add(outline);
        OutputFrm.RichEdit.Lines.Add('');

        pearsonr := 0.0;
        SumX := 0.0;
        SumY := 0.0;
        VarX := 0.0;
        VarY := 0.0;
        for i := 0 to Nrows - 1 do SumX := SumX + ( (i+1) * Freq[i,Ncols] );
        for j := 0 to Ncols - 1 do SumY := SumY + ( (j+1) * Freq[Nrows,j] );
        for i := 0 to Nrows - 1 do VarX := VarX + ( ((i+1)*(i+1)) * Freq[i,Ncols] );
        for j := 0 to Ncols - 1 do VarY := VarY + ( ((j+1)*(j+1)) * Freq[Nrows,j] );
        VarX := VarX - ((SumX * SumX) / Ncases);
        VarY := VarY - ((SumY * SumY) / Ncases);
        for i := 0 to Nrows - 1 do
                for j := 0 to Ncols - 1 do
                        pearsonr := pearsonr + ((i+1)*(j+1) * Freq[i,j]);
        pearsonr := pearsonr - (SumX * SumY /  Ncases);
        pearsonr := pearsonr / sqrt(VarX * VarY);
        outline := format('Pearson Correlation r = %6.4f',[pearsonr]);
        OutputFrm.RichEdit.Lines.Add(outline);
        OutputFrm.RichEdit.Lines.Add('');

        MantelHaenszel :=  (Ncases-1) * (pearsonr * pearsonr);
        MHprob := 1.0 - chisquaredprob(MantelHaenszel,1);
        outline := format('Mantel-Haenszel Test of Linear Association = %8.3f with probability > value = %6.4f',
            [MantelHaenszel, MHprob]);
        OutputFrm.RichEdit.Lines.Add(outline);
        OutputFrm.RichEdit.Lines.Add('');

        CoefCont := sqrt(ChiSquare / (ChiSquare +  Ncases));
        outline := format('The coefficient of contingency = %8.3f',[CoefCont]);
        OutputFrm.RichEdit.Lines.Add(outline);
        OutputFrm.RichEdit.Lines.Add('');

        if (Nrows < Ncols) then CramerV := sqrt(ChiSquare / (Ncases * ((Nrows-1))))
        else CramerV := sqrt(ChiSquare / (Ncases * ((Ncols-1))));
        outline := format('Cramers V = %8.3f',[CramerV]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;
    OutputFrm.ShowModal();
    OutputFrm.RichEdit.Clear();

    // Now do RIDIT analysis
    NoToAnalyze := ColList.Items.Count;

    if (AllRefs) then // do an analysis for each variable as a reference variable
    begin
        NoToAnalyze := ColList.Items.Count;
        for i := 0 to NoToAnalyze - 1 do
        begin
                RefColNo := ColNoSelected[i+1] - 2;
                Analyze(RefColNo, ColNoSelected, RowLabels,ColLabels,
                         NoToAnalyze,Freq,Prop, Nrows);
        end;
    end
    else  // only one selected reference variable
    begin
        NoToAnalyze := ColList.Items.Count;
        // get column of reference variable
        for i := 1 to NoVariables do
        begin
                if (RefEdit.Text = OS3MainFrm.DataGrid.Cells[i,0]) then RefColNo := i;

        end;
        for j := 0 to NoToAnalyze - 1 do
        begin
               if (ColNoSelected[j+1] = RefColNo) then RefColNo := j;
        end;
        Analyze(RefColNo, ColNoSelected, RowLabels,ColLabels,
                NoToAnalyze,Freq, Prop, Nrows);
    end;

    ColLabels := nil;
    RowLabels := nil;
    CellChi := nil;
    Expected := nil;
    Prop := nil;
    Freq := nil;
    ColNoSelected := nil;
end;

procedure TRIDITFrm.Analyze(RefCol : integer; ColNoSelected : IntDyneVec;
              RowLabels : StrDyneVec; ColLabels : StrDyneVec;
              NoToAnalyze : integer; Freq : IntDyneMat;
              Props : DblDyneMat; NoRows : integer);
VAR
        probdists : DblDyneMat;
        refprob : DblDyneMat;
        sizes : DblDyneVec;
        meanridits : DblDyneVec;
        Cratios : DblDyneVec;
        OverMeanRidit : double;
        chisquare : double;
        probchi : double;
        alpha : double;
        StdErr : DblDyneVec;
        Bonferroni : double;
        i, j : integer;
        outline : string;
        outstring : string;
        details : boolean;
        term1,term2,term3,term4 : double;

begin
        details := false;
        SetLength(probdists,NoRows,NoToAnalyze);
        SetLength(refprob,NoRows,4);
        SetLength(sizes,NoToAnalyze);
        SetLength(meanridits,NoToAnalyze);
        SetLength(Cratios,NoToAnalyze);
        SetLength(StdErr,NoToAnalyze);

        alpha := StrToFloat(AlphaEdit.Text);
        if (DetailsChk.Checked) then details := true;

        outline := format('ANALYSIS FOR STANDARD %s',[ColLabels[RefCol]]);
        OutputFrm.RichEdit.Lines.Add(outline);
        OutputFrm.RichEdit.Lines.Add('');

        // print frequencies
         outline := 'Frequencies Observed';
         IntArrayPrint(Freq, NoRows, NoToAnalyze, 'Frequencies', RowLabels, ColLabels,
                    outline);

        // print column proportions
         outline := 'Column Proportions Observed';
         MAT_PRINT(Props, NoRows, NoToAnalyze, outline, RowLabels, ColLabels,
                    NoCases);

        // Get sizes in each column
        for i := 0 to NoToAnalyze - 1 do
        begin
                sizes[i] := Freq[NoRows,i];
        end;
        // Get the reference variable probabilities for all variables
        for j := 0 to NoToAnalyze - 1 do
        begin
                for i := 0 to NoRows - 1 do
                begin
                        refprob[i,0] := Props[i,j];
                        refprob[i,1] := Props[i,j] / 2.0;
                end;
                refprob[0,2] := 0.0;
                for i := 1 to NoRows - 1 do refprob[i,2] := refprob[i-1,2] + refprob[i-1,0];
                for i := 0 to NoRows - 1 do refprob[i,3] := refprob[i,1] + refprob[i,2];
                if (details) then // print calculations table
                begin
                        outstring := 'Ridit calculations for ' + ColLabels[j];
                        outline := outstring;
                        MAT_PRINT(refprob, NoRows, 4, outline, RowLabels, ColLabels,
                           NoCases);
                end;
                // store results in probdists
                for i := 0 to NoRows - 1 do probdists[i,j] := refprob[i,3];
        end;
        outstring := 'Ridits for all variables';
        outline := outstring;
        MAT_PRINT(probdists, NoRows, NoToAnalyze, outline, RowLabels, ColLabels,
                    NoCases);

        // obtain mean ridits for the all variables using the reference variable
        for i := 0 to NoToAnalyze - 1 do
        begin
                meanridits[i] := 0.0;
                for j := 0 to NoRows - 1 do
                begin
                        meanridits[i] := meanridits[i] + (probdists[j,RefCol] * Freq[j,i]);
                end;
                meanridits[i] := meanridits[i] / sizes[i];
        end;
        // print the means using the reference variable
        outline := 'Mean RIDITS Using the Reference Values';
        DynVectorPrint(meanridits,NoToAnalyze,outline,ColLabels,NoCases);
        // obtain the weighted grand mean ridit
        OverMeanRidit := 0.0;
        for i := 0 to NoToAnalyze - 1 do
        begin
                if (i <> RefCol) then OverMeanRidit := OverMeanRidit + sizes[i] * meanridits[i];
        end;
        OverMeanRidit := OverMeanRidit / (Freq[NoRows,NoToAnalyze] - sizes[RefCol]);
        outline := format('Overall mean for RIDITS in non-reference groups := %8.4f',[OverMeanRidit]);
        OutputFrm.RichEdit.Lines.Add(outline);
        // obtain chisquare
        chisquare := 0.0;
        term4 := (OverMeanRidit - 0.5) * (OverMeanRidit - 0.5);
        term3 := 0.0;
        for i := 0 to NoToAnalyze - 1 do
        begin
                if (i <> RefCol) then term3 := term3 + (sizes[i] * sizes[i]);
        end;
        term3 := 12.0 * term3;
        term2 := Freq[NoRows,NoToAnalyze];
        term1 := 0.0;
        for i := 0 to NoToAnalyze - 1 do
        begin
                if (i <> RefCol) then
                   term1 := term1 + (sizes[i] * ((meanridits[i] - 0.5) * (meanridits[i] - 0.5)));
        end;
        term1 := term1 * 12.0;
        chisquare := term1 - ((term3 / term2) * term4);
        probchi := 1.0 - chisquaredprob(chisquare,NoToAnalyze-1);
        outline := format('Chisquared := %8.3f with probability < %8.4f',[chisquare,probchi]);
        OutputFrm.RichEdit.Lines.Add(outline);
        // do pairwise comparisons
        Cratios[RefCol] := 0.0;
        for i := 0 to NoToAnalyze - 1 do
        begin
                if (i <> RefCol) then
                begin
                        StdErr[i] := sqrt(sizes[RefCol] + sizes[i]) /
                             (2.0 * sqrt(3.0 * sizes[RefCol] * sizes[i]));
                        Cratios[i] := ( meanridits[i] - 0.5) / StdErr[i];
                end;
        end;
        outline := 'z critical ratios';
        DynVectorPrint(Cratios,NoToAnalyze,outline,ColLabels,NoCases);
        alpha := alpha / 2.0;
        if (BonChk.Checked) then alpha := alpha / (NoToAnalyze - 1);
        Bonferroni := inversez(1.0 - alpha);
        outline := format('significance level used for comparisons := %8.3f',[Bonferroni]);
        OutputFrm.RichEdit.Lines.Add(outline);
        for i := 0 to NoToAnalyze - 1 do
        begin
                if (i <> RefCol) then
                begin
                        if (abs(Cratios[i]) > Bonferroni) then
                        begin
                                outline := format('%s vs %s significant',[ColLabels[i],ColLabels[RefCol]]);
                                OutputFrm.RichEdit.Lines.Add(outline);
                        end
                        else
                        begin
                                outline := format('%s vs %s not significant',[ColLabels[i],ColLabels[RefCol]]);
                                OutPutFrm.RichEdit.Lines.Add(outline);
                        end;
                end;
        end;
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear;

        // cleanup
        StdErr := nil;
        Cratios := nil;
        meanridits := nil;
        sizes := nil;
        refprob := nil;
        probdists := nil;
end;

initialization
  {$I riditunit.lrs}

end.

