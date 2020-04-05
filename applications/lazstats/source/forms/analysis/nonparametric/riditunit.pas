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
    CloseBtn: TButton;
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
    procedure Analyze(RefCol: integer; ColNoSelected: IntDyneVec;
              RowLabels: StrDyneVec; ColLabels: StrDyneVec;
              NoToAnalyze: integer; Freq: IntDyneMat;
              Props: DblDyneMat; NoRows: integer; AReport: TStrings);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  RIDITFrm: TRIDITFrm;

implementation

uses
  Math,
  Utils;

{ TRIDITFrm }

procedure TRIDITFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  ColList.Clear;
  RowEdit.Text := '';
  RefEdit.Text := '';
  AlphaEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  BonChk.Checked := true;
  Label4.Visible := false;
  RefEdit.Visible := false;
  RefGrp.ItemIndex := 0;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TRIDITFrm.RowInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (RowEdit.Text = '') then
  begin
    RowEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TRIDITFrm.RowOutClick(Sender: TObject);
begin
  if RowEdit.Text <> '' then
  begin
    VarList.Items.Add(RowEdit.Text);
    RowEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TRIDITFrm.FormActivate(Sender: TObject);
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

procedure TRIDITFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
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
  RefEdit.Visible := RefGrp.ItemIndex > 0;
  Label4.Visible := RefEdit.Visible;
end;

procedure TRIDITFrm.ColInClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] then
    begin
      ColList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TRIDITFrm.ColListClick(Sender: TObject);
var
  index: integer;
begin
  index := ColList.ItemIndex;
  if index > -1 then
    RefEdit.Text := ColList.Items[index];
  UpdateBtnStates;
end;

procedure TRIDITFrm.ColOutClick(Sender: TObject);
var
  index: integer;
begin
  index := ColList.ItemIndex;
  if index > -1 then
  begin
    VarList.Items.Add(ColList.Items[index]);
    ColList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TRIDITFrm.ComputeBtnClick(Sender: TObject);
var
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
  likelihood, problikelihood, phi: double;
  pearsonr, VarX, VarY, SumX, SumY, MantelHaenszel, MHProb, CoefCont: double;
  CramerV: double;
  tmp: Double;
  lReport: TStrings;
begin
  if AlphaEdit.Text = '' then
  begin
    AlphaEdit.SetFocus;
    MessageDlg('Alpha level not specified.', mtError, [mbOK], 0);
    exit;
  end;
  if not TryStrToFloat(AlphaEdit.Text, tmp) then
  begin
    AlphaEdit.Setfocus;
    MessageDlg('Numeric input required for alpha level.', mtError, [mbOK], 0);
    exit;
  end;
  if (tmp <= 0) or (tmp >= 1) then
  begin
    AlphaEdit.Setfocus;
    MessageDlg('Alpha level must be > 0 and < 1', mtError, [mbOK], 0);
    exit;
  end;

  AllRefs := RefGrp.ItemIndex = 0;

  SetLength(ColNoSelected,NoVariables+1);
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
    MessageDlg('A variable for the row labels was not entered.', mtError, [mbOK], 0);
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
    RowLabels[i-1] := OS3MainFrm.DataGrid.Cells[RowNo,i];

  // allocate and initialize
  SetLength(Freq, Nrows+1, Ncols+1);
  SetLength(Prop, Nrows+1, Ncols+1);
  SetLength(Expected, Nrows, Ncols);
  SetLength(CellChi, Nrows, Ncols);
  for i := 1 to Nrows + 1 do
    for j := 1 to Ncols + 1 do
      Freq[i-1,j-1] := 0;
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
//    result := GetValue(Row,Col,intvalue,dblvalue,strvalue);
//    if (result = 1) Freq[i-1][j-1] := 0;
//    else Freq[i-1][j-1] := intvalue;
      Ncases := Ncases + Freq[i-1,j-1];
    end;
  end;
  Freq[Nrows][Ncols] := Ncases;

  // Now, calculate expected values

  // Get row totals first
  for i := 1 to Nrows do
    for j := 1 to Ncols do
      Freq[i-1,Ncols] := Freq[i-1,Ncols] + Freq[i-1,j-1];

  // Get col totals next
  for j := 1 to Ncols do
    for i := 1 to Nrows do
      Freq[Nrows,j-1] := Freq[Nrows,j-1] + Freq[i-1,j-1];

  // Then get expected values and cell chi-squares
  ChiSquare := 0.0;
  Adjchisqr := 0.0;
  yates := YatesChk.Checked and (Nrows = 2) and (Ncols = 2);
  if (Nrows > 1) and (Ncols > 1) then
  begin
    for i := 1 to Nrows do
    begin
      for j := 1 to Ncols do
      begin
        Expected[i-1,j-1] := Freq[Nrows,j-1] * Freq[i-1,Ncols] / Ncases;
        if (Expected[i-1,j-1] > 0.0) then
          CellChi[i-1,j-1] := sqr(Freq[i-1,j-1] - Expected[i-1,j-1])/ Expected[i-1,j-1]
        else
        begin
          MessageDlg('Zero expected value found.', mtError, [mbOK], 0);
          CellChi[i-1,j-1] := 0.0;
        end;
        ChiSquare := ChiSquare + CellChi[i-1,j-1];
      end;
    end;
    df := (Nrows - 1) * (Ncols - 1);

    if yates then // 2 x 2 corrected chi-square
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
  lReport := TStringList.Create;
  try
    lReport.Add('CHI-SQUARE ANALYSIS RESULTS');
    lReport.Add('No. of Cases: %d', [Ncases]);
    lReport.Add('');

    // print tables requested by use
    if ObsChk.Checked then
       IntArrayPrint(Freq, Nrows+1, Ncols+1, 'Frequencies', RowLabels, ColLabels, 'OBSERVED FREQUENCIES', lReport);

    if ExpChk.Checked then
    begin
      outline := 'EXPECTED FREQUENCIES';
      MatPrint(Expected, Nrows, Ncols, outline, RowLabels, ColLabels, NoCases, lReport);
    end;

    for i := 1 to Nrows + 1 do
    begin
      for j := 1 to Ncols do
      begin
        if (Freq[i-1,Ncols] > 0.0) then
          Prop[i-1,j-1] := Freq[i-1,j-1] / Freq[i-1,Ncols]
        else
          Prop[i-1,j-1] := 0.0;
      end;
      if (Freq[i-1,Ncols] > 0.0) then
        Prop[i-1,Ncols] := 1.0
      else
        Prop[i-1,Ncols] := 0.0;
    end;

    if PropChk.Checked then
    begin
      outline := 'ROW PROPORTIONS';
      MatPrint(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels, NoCases, lReport);
    end;

    for j := 1 to Ncols + 1 do
    begin
      for i := 1 to Nrows do
      begin
        if (Freq[Nrows,j-1] > 0.0) then
          Prop[i-1,j-1] :=  Freq[i-1,j-1] / Freq[Nrows,j-1]
        else
          Prop[i-1,j-1] := 0.0;
      end;
      if (Freq[Nrows,j-1] > 0.0) then
        Prop[Nrows,j-1] := 1.0
      else
        Prop[Nrows,j-1] := 0.0;
    end;
    if (PropChk.Checked) then
    begin
      outline := 'COLUMN PROPORTIONS';
      MatPrint(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels, NoCases, lReport);
    end;

    if ChiChk.Checked then
    begin
      outline := 'CHI-SQUARED VALUE FOR CELLS';
      MatPrint(CellChi, Nrows, Ncols, outline, RowLabels, ColLabels, NoCases, lReport);
    end;

    lReport.Add('');
    lReport.Add(  'Chi-square:                        %8.3f', [ChiSquare]);
    lReport.Add(  '   with D.F.                       %8d', [df]);
    lReport.Add(  '   and Probability > value:        %8.3f', [ProbChi]);
    lReport.Add('');

    if yates then
    begin
      lReport.Add('Chi-square using Yates correction: %8.3f', [AdjChiSqr]);
      lReport.Add('   and Probability > value:        %8.3f', [Adjprobchi]);
    end;

    likelihood := 0.0;
    for i := 0 to Nrows - 1 do
        for j := 0 to Ncols - 1 do
             if (Freq[i,j] > 0.0) then
               likelihood := likelihood + Freq[i,j] * (ln(Expected[i,j] / Freq[i,j]));
    likelihood := -2.0 * likelihood;
    problikelihood := 1.0 - ChiSquaredProb(likelihood, df);
    lReport.Add(  'Likelihood Ratio:                  %8.3f', [likelihood]);
    lReport.Add(  '    with Probability > value:      %8.4f', [problikelihood]);
    lReport.Add('');

    if ((Nrows > 1) and (Ncols > 1)) then
    begin
      phi := sqrt(ChiSquare / Ncases);
      lReport.Add('phi correlation:                   %8.4f', [phi]);
      lReport.Add('');

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
      lReport.Add('Pearson Correlation r:             %8.4f', [pearsonr]);
      lReport.Add('');

      MantelHaenszel :=  (Ncases-1) * (pearsonr * pearsonr);
      MHprob := 1.0 - chisquaredprob(MantelHaenszel,1);
      lReport.Add('Mantel-Haenszel Test of Linear Association: %.3f with probability > value %.4f', [MantelHaenszel, MHprob]);
      lReport.Add('');

      CoefCont := sqrt(ChiSquare / (ChiSquare +  Ncases));
      lReport.Add('The coefficient of contingency:    %8.3f', [CoefCont]);
      lReport.Add('');

      if (Nrows < Ncols) then
        CramerV := sqrt(ChiSquare / (Ncases * ((Nrows-1))))
      else
        CramerV := sqrt(ChiSquare / (Ncases * ((Ncols-1))));
      lReport.Add('Cramers V:                         %8.3f', [CramerV]);
    end;

    lReport.Add('');
    lReport.Add('=============================================================================');
    lReport.Add('');

    // Now do RIDIT analysis
    NoToAnalyze := ColList.Items.Count;

    // do an analysis for each variable as a reference variable
    if AllRefs then
    begin
      NoToAnalyze := ColList.Items.Count;
      for i := 0 to NoToAnalyze - 1 do
      begin
        RefColNo := ColNoSelected[i+1] - 2;
        Analyze(RefColNo, ColNoSelected, RowLabels,ColLabels, NoToAnalyze, Freq, Prop, Nrows, lReport);
      end;
    end else
    // only one selected reference variable
    begin
      NoToAnalyze := ColList.Items.Count;
      // get column of reference variable
      for i := 1 to NoVariables do
        if (RefEdit.Text = OS3MainFrm.DataGrid.Cells[i,0]) then RefColNo := i;

      for j := 0 to NoToAnalyze - 1 do
        if (ColNoSelected[j+1] = RefColNo) then RefColNo := j;

      Analyze(RefColNo, ColNoSelected, RowLabels,ColLabels, NoToAnalyze, Freq, Prop, Nrows, lReport);
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;

    ColLabels := nil;
    RowLabels := nil;
    CellChi := nil;
    Expected := nil;
    Prop := nil;
    Freq := nil;
    ColNoSelected := nil;
  end;
end;

procedure TRIDITFrm.Analyze(RefCol : integer; ColNoSelected : IntDyneVec;
              RowLabels : StrDyneVec; ColLabels : StrDyneVec;
              NoToAnalyze : integer; Freq : IntDyneMat;
              Props : DblDyneMat; NoRows : integer;
              AReport: TStrings);
var
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
  details : boolean;
  term1,term2,term3,term4 : double;

begin
  SetLength(probdists,NoRows,NoToAnalyze);
  SetLength(refprob,NoRows,4);
  SetLength(sizes,NoToAnalyze);
  SetLength(meanridits,NoToAnalyze);
  SetLength(Cratios,NoToAnalyze);
  SetLength(StdErr,NoToAnalyze);

  alpha := StrToFloat(AlphaEdit.Text);
  details := DetailsChk.Checked;

  AReport.Add('ANALYSIS FOR STANDARD %s', [ColLabels[RefCol]]);
//  AReport.Add('');

  // print frequencies
  outline := 'Frequencies Observed';
  IntArrayPrint(Freq, NoRows, NoToAnalyze, 'Frequencies', RowLabels, ColLabels, outline, AReport);

  // print column proportions
  outline := 'Column Proportions Observed';
  MatPrint(Props, NoRows, NoToAnalyze, outline, RowLabels, ColLabels, NoCases, AReport);

  // Get sizes in each column
  for i := 0 to NoToAnalyze - 1 do
    sizes[i] := Freq[NoRows,i];

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
      outline := 'Ridit calculations for ' + ColLabels[j];
      MatPrint(refprob, NoRows, 4, outline, RowLabels, ColLabels, NoCases, AReport);
    end;

    // store results in probdists
    for i := 0 to NoRows - 1 do probdists[i,j] := refprob[i,3];
  end;
  outline := 'Ridits for all variables';
  MatPrint(probdists, NoRows, NoToAnalyze, outline, RowLabels, ColLabels, NoCases, AReport);

  // obtain mean ridits for the all variables using the reference variable
  for i := 0 to NoToAnalyze - 1 do
  begin
    meanridits[i] := 0.0;
    for j := 0 to NoRows - 1 do
      meanridits[i] := meanridits[i] + (probdists[j,RefCol] * Freq[j,i]);
    meanridits[i] := meanridits[i] / sizes[i];
  end;

  // print the means using the reference variable
  outline := 'Mean RIDITS Using the Reference Values';
  DynVectorPrint(meanridits, NoToAnalyze, outline, ColLabels, NoCases, AReport);

  // obtain the weighted grand mean ridit
  OverMeanRidit := 0.0;
  for i := 0 to NoToAnalyze - 1 do
    if (i <> RefCol) then OverMeanRidit := OverMeanRidit + sizes[i] * meanridits[i];
  OverMeanRidit := OverMeanRidit / (Freq[NoRows,NoToAnalyze] - sizes[RefCol]);

  AReport.Add('Overall mean for RIDITS in non-reference groups: %8.4f', [OverMeanRidit]);

  // obtain chisquare
  chisquare := 0.0;
  term4 := sqr(OverMeanRidit - 0.5);
  term3 := 0.0;
  for i := 0 to NoToAnalyze - 1 do
    if (i <> RefCol) then term3 := term3 + sizes[i] * sizes[i];
  term3 := 12.0 * term3;
  term2 := Freq[NoRows,NoToAnalyze];
  term1 := 0.0;
  for i := 0 to NoToAnalyze - 1 do
    if (i <> RefCol) then
      term1 := term1 + sizes[i] * sqr(meanridits[i] - 0.5);
  term1 := term1 * 12.0;
  chisquare := term1 - (term3 / term2) * term4;
  probchi := 1.0 - ChiSquaredProb(chisquare, NoToAnalyze-1);
  AReport.Add('Chisquared:            %8.4f', [chisquare]);
  AReport.Add('    with probability < %8.4f', [probchi]);

  // do pairwise comparisons
  Cratios[RefCol] := 0.0;
  for i := 0 to NoToAnalyze - 1 do
    if (i <> RefCol) then
    begin
      StdErr[i] := sqrt(sizes[RefCol] + sizes[i]) / (2.0 * sqrt(3.0 * sizes[RefCol] * sizes[i]));
      Cratios[i] := (meanridits[i] - 0.5) / StdErr[i];
    end;

  outline := 'z critical ratios';
  DynVectorPrint(Cratios, NoToAnalyze, outline, ColLabels, NoCases, AReport);

  alpha := alpha / 2.0;
  if (BonChk.Checked) then alpha := alpha / (NoToAnalyze - 1);
  Bonferroni := InverseZ(1.0 - alpha);
  AReport.Add('Significance level used for comparisons: %8.3f', [Bonferroni]);
  AReport.Add('');

  for i := 0 to NoToAnalyze - 1 do
    if (i <> RefCol) then
    begin
      if (abs(Cratios[i]) > Bonferroni) then
        AReport.Add('%s vs %s: significant', [ColLabels[i], ColLabels[RefCol]])
      else
        AReport.Add('%s vs %s: not significant', [ColLabels[i], ColLabels[RefCol]]);
    end;

  // cleanup
  StdErr := nil;
  Cratios := nil;
  meanridits := nil;
  sizes := nil;
  refprob := nil;
  probdists := nil;
end;

procedure TRIDITFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TRIDITFrm.UpdateBtnStates;
begin
  RowIn.Enabled := (VarList.ItemIndex > -1) and (RowEdit.Text = '');
  RowOut.Enabled := (RowEdit.Text <> '');

  ColIn.Enabled := AnySelected(VarList);
  ColOut.Enabled := (ColList.ItemIndex > -1);
end;

initialization
  {$I riditunit.lrs}

end.

