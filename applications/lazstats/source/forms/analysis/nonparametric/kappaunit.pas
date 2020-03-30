unit KappaUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, OutputUnit, FunctionsLib, DictionaryUnit, DataProcs,
  MatrixLib, ContextHelpUnit;

type

  { TWeightedKappaFrm }

  TWeightedKappaFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    ObsChk: TCheckBox;
    ExpChk: TCheckBox;
    PropChk: TCheckBox;
    ChiChk: TCheckBox;
    YatesChk: TCheckBox;
    SaveChk: TCheckBox;
    OptionsGroup: TGroupBox;
    NCasesEdit: TEdit;
    NCasesLbl: TLabel;
    RowIn: TBitBtn;
    RowOut: TBitBtn;
    ColIn: TBitBtn;
    ColOut: TBitBtn;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    RaterAEdit: TEdit;
    RaterBEdit: TEdit;
    DepEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    DepLbl: TLabel;
    VarList: TListBox;
    InputGroup: TRadioGroup;
    procedure ColInClick(Sender: TObject);
    procedure ColOutClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InputGroupClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure RowInClick(Sender: TObject);
    procedure RowOutClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  WeightedKappaFrm: TWeightedKappaFrm;

implementation

uses
  Math;

{ TWeightedKappaFrm }

procedure TWeightedKappaFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  RaterAEdit.Text := '';
  RaterBEdit.Text := '';
  DepEdit.Text := '';
  NCasesEdit.Text := '';
  InputGroup.ItemIndex := 0;
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TWeightedKappaFrm.RowInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (RaterAEdit.Text = '') then
  begin
    RaterAEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TWeightedKappaFrm.RowOutClick(Sender: TObject);
begin
  if RaterAEdit.Text <> '' then
  begin
    VarList.Items.Add(RaterAEdit.Text);
    RaterAEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TWeightedKappaFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  // Autosizing is not working for whatever reason...
  //AutoSize := false;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  //VarList.Constraints.MinHeight := OptionsGroup.Top + OptionsGroup.Height - NCasesEdit.Height - VarList.BorderSpacing.Bottom;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := OptionsGroup.Top + OptionsGroup.Height + CloseBtn.Height + 2*CloseBtn.BorderSpacing.Bottom;

  FAutoSized := true;
end;

procedure TWeightedKappaFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TWeightedKappaFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TWeightedKappaFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TWeightedKappaFrm.InputGroupClick(Sender: TObject);
begin
  (*
  case InputGroup.ItemIndex of
    0: begin    // have to count cases in each row and col. combination
         NCasesEdit.Enabled := false;
         NCasesLbl.Enabled := false;
         DepEdit.Enabled := false;
       end;
    1: begin   // frequencies available for each row and column combo
         DepLbl.Enabled := true;
         NCasesLbl.Enabled := false;
         NCasesEdit.Enabled := false;
         DepEdit.Enabled := true;
       end;
    2: begin   // only proportions available - get N size
         DepLbl.Enabled := true;
         NCasesEdit.Enabled := true;
         NCasesLbl.Enabled := true;
         DepEdit.Visible := Enabled;
       end;
  end;
  *)
  UpdateBtnStates;
(*
     if (index = 2) then  // only proportions available - get N size
     begin
          DepLbl.Visible := true;
          NCasesEdit.Visible := true;
          NCasesEdit.SetFocus;
          DepIn.Enabled := true;
          DepOut.Enabled := false;
          DepIn.Visible := true;
          DepOut.Visible := true;
          DepEdit.Visible := true;
          NCasesLbl.Visible := true;
     end;
     if (index = 1) then  // frequencies available for each row and column combo
     begin
         DepLbl.Visible := true;
         NCasesEdit.Visible := false;
         DepIn.Enabled := true;
         DepOut.Enabled := false;
         DepIn.Visible := true;
         DepOut.Visible := true;
         DepEdit.Visible := true;
         NCasesLbl.Visible := false;
     end;
     if (index = 0) then  // have to count cases in each row and col. combination
     begin
          NCasesEdit.Visible := false;
          DepIn.Visible := false;
          DepOut.Visible := false;
          DepEdit.Visible := false;
          DepLbl.Visible := false;
          NCasesLbl.Visible := false;
     end;
     *)
end;

procedure TWeightedKappaFrm.ColInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (RaterBEdit.Text = '') then
  begin
    RaterBEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TWeightedKappaFrm.ColOutClick(Sender: TObject);
begin
  if RaterBEdit.Text <> '' then
  begin
    VarList.Items.Add(RaterBEdit.Text);
    RaterBEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TWeightedKappaFrm.ComputeBtnClick(Sender: TObject);
var
     i, j, k, RowNo, ColNo, DepNo, MinRow, MaxRow, MinCol, MaxCol : integer;
     Row, Col, NoSelected, Ncases, Nrows, Ncols, FObs, df : integer;
     RowLabels, ColLabels : StrDyneVec;
     ColNoSelected : IntDyneVec;
     cellstring : string;
     outline : string;
     Freq : IntDyneMat;
     Prop, Expected, CellChi : DblDyneMat;
     PObs, ChiSquare, ProbChi, likelihood, Fval, phi : double;
     yates, aresult : boolean;
     title : string;
     Adjchisqr, Adjprobchi, problikelihood, pearsonr : double;
     pobserved, SumX, SumY, VarX, VarY, obsdiag, expdiag, expnondiag : double;
     pexpected, MantelHaenszel, MHprob, CoefCont, CramerV, Kappa : double;
     Frq : integer;
     weights, quadweights : DblDyneMat;
     lReport: TStrings;
begin
     if RaterAEdit.Text = '' then
     begin
       MessageDlg('Rater A is not specified.', mtError, [mbOK], 0);
       exit;
     end;

     if RaterBEdit.Text = '' then
     begin
       MessageDlg('Rater B is not specified.', mtError, [mbOK], 0);
       exit;
     end;

     if InputGroup.ItemIndex > 0 then
     begin
       if DepEdit.Text = '' then
       begin
         MessageDlg('Dependent variable is not specified.', mtError, [mbOK], 0);
         exit;
       end;
     end;

     if InputGroup.ItemIndex = 2 then
     begin
       if NCasesEdit.Text = '' then
       begin
         NCasesEdit.SetFocus;
         MessageDlg('Total number of cases is not specified.', mtError, [mbOK], 0);
         exit;
       end;
       if not TryStrToInt(NCasesEdit.Text, i) then
       begin
         NCasesEdit.SetFocus;
         MessageDlg('Total number of cases is not a valid number.', mtError, [mbOK], 0);
         exit;
       end;
     end;

     SetLength(ColNoSelected,NoVariables);
     yates := false;
     RowNo := 0;
     ColNo := 0;
     DepNo := 0;
     pobserved := 0.0;
     pexpected := 0.0;

     for i := 1 to NoVariables do
     begin
          cellstring := OS3MainFrm.DataGrid.Cells[i,0];
          if (cellstring = RaterAEdit.Text) then RowNo := i;
          if (cellstring = RaterBEdit.Text) then ColNo := i;
          if (cellstring = DepEdit.Text) then DepNo := i;
     end;
     (*
     if ((InputGroup.ItemIndex > 0) and (DepNo = 0)) then
     begin
        ShowMessage('ERROR!  You must select a dependent variable.');
        ColNoSelected := nil;
        exit;
     end;
     if ((RowNo = 0) or (ColNo = 0)) then  //  || (DepNo == 0))
     begin
        ShowMessage('ERROR!  A required variable has not been selected.');
        ColNoSelected := nil;
        exit;
     end;
     *)

     aresult := ValidValue(RowNo,1);
     if not aresult then
     begin
        ColNoSelected := nil;
        exit;
     end;
     aresult := ValidValue(ColNo,1);
     if not aresult then
     begin
        ColNoSelected := nil;
        exit;
     end;

     ColNoSelected[0] := RowNo;
     ColNoSelected[1] := ColNo;
     NoSelected := 2;
     if (InputGroup.ItemIndex > 0) then  // for reading proportions or frequencies
     begin
          NoSelected := 3;
          ColNoSelected[2] := DepNo;
     end;
     if (InputGroup.ItemIndex = 1) then
     begin
        aresult := ValidValue(DepNo,1);
        if (aresult = false) then
        begin
                ColNoSelected := nil;
                exit;
        end;
     end;
     if (InputGroup.ItemIndex = 2) then
     begin
        aresult := ValidValue(DepNo,0);
        if (aresult = false) then
        begin
                ColNoSelected := nil;
                exit;
        end;
     end;

     // get min and max of row and col numbers
     MinRow := 1000;
     MaxRow := 0;
     MinCol := 1000;
     MaxCol := 0;
     for i := 1 to NoCases do
     begin
          if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
          Row := round(StrToFloat(OS3MainFrm.DataGrid.Cells[RowNo,i]));
          Col := round(StrToFloat(OS3MainFrm.DataGrid.Cells[ColNo,i]));
          if (Row > MaxRow) then MaxRow := Row;
          if (Row < MinRow) then MinRow := Row;
          if (Col > MaxCol) then MaxCol := Col;
          if (Col < MinCol) then MinCol := Col;
     end;
     Nrows := MaxRow - MinRow + 1;
     Ncols := MaxCol - MinCol + 1;

     // allocate and initialize
     SetLength(Freq,Nrows+1,Ncols+1);
     SetLength(Prop,Nrows+1,Ncols+1);
     SetLength(Expected,Nrows,Ncols);
     SetLength(CellChi,Nrows,Ncols);
     SetLength(RowLabels,Nrows+1);
     SetLength(ColLabels,Ncols+1);
     for i := 1 to Nrows + 1 do
         for j := 1 to Ncols + 1 do  Freq[i-1,j-1] := 0;
    for i := 1 to Nrows do
        RowLabels[i-1] := Format('Row %d', [i]);
    RowLabels[Nrows] := 'Total';
    for j := 1 to Ncols do
        ColLabels[j-1] := Format('COL. %d', [j]);
    ColLabels[Ncols] := 'Total';

     // get cell data
     Ncases := 0;
     if (InputGroup.ItemIndex = 0) then
     begin // count number of cases in each row and column combination
              for i := 1 to NoCases do
              begin
                   if (not GoodRecord(i,NoSelected,ColNoSelected)) then
                     continue;
                   Ncases := Ncases + 1;
                   Row := round(StrToFloat(OS3MainFrm.DataGrid.Cells[RowNo,i]));
                   Col := round(StrToFloat(OS3MainFrm.DataGrid.Cells[ColNo,i]));
                   Row := Row - MinRow + 1;
                   Col := Col - MinCol + 1;
                   Freq[Row-1,Col-1] := Freq[Row-1,Col-1] + 1;
              end;
     end;
     if (InputGroup.ItemIndex = 1) then  // read frequencies data from grid
     begin
              for i := 1 to NoCases do
              begin
                   if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
                   Row := round(StrToFloat(OS3MainFrm.DataGrid.Cells[RowNo,i]));
                   Col := round(StrToFloat(OS3MainFrm.DataGrid.Cells[ColNo,i]));
                   Row := Row - MinRow + 1;
                   Col := Col - MinCol + 1;
                   FObs := round(StrToFloat(OS3MainFrm.DataGrid.Cells[DepNo,i]));
                   Freq[Row-1,Col-1] := Freq[Row-1,Col-1] + FObs;
                   Ncases := Ncases + FObs;
              end;
     end;
     if (InputGroup.ItemIndex = 2) then // get no. of cases and proportions for each cell
     begin
              Ncases := StrToInt(NCasesEdit.Text);
              for i := 1 to NoCases do
              begin
                   if (not GoodRecord(i,NoSelected,ColNoSelected)) then  continue;
                   Row := round(StrToFloat(OS3MainFrm.DataGrid.Cells[RowNo,i]));
                   Col := round(StrToFloat(OS3MainFrm.DataGrid.Cells[ColNo,i]));
                   Row := Row - MinRow + 1;
                   Col := Col - MinCol + 1;
                   PObs := round(StrToFloat(OS3MainFrm.DataGrid.Cells[DepNo,i]));
                   Frq := round(PObs * Ncases);
                   Fval := PObs * Ncases;
                   if (Fval - Frq < 0.5) then Frq := round(Fval)
                   else Frq := ceil(Fval);
                   Freq[Row-1,Col-1] := Freq[Row-1,Col-1] + Frq;
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
     for i := 1 to Nrows do
     begin
          for j := 1 to Ncols do
          begin
               Expected[i-1,j-1] := Freq[Nrows,j-1] * Freq[i-1,Ncols] / Ncases;
               if (Expected[i-1,j-1] > 0.0) then
                  CellChi[i-1,j-1] := sqr(Freq[i-1,j-1] - Expected[i-1,j-1]) / Expected[i-1,j-1]
               else
               begin
                    MessageDlg('Zero expected value found.', mtError, [mbOK], 0);
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
     ProbChi := 1.0 - chisquaredprob(ChiSquare,df); // prob. larger chi

    //Print results to output form
    lReport := TStringList.Create;
    try
      lReport.Add('CHI-SQUARE ANALYSIS RESULTS FOR ' + RaterAEdit.Text + ' AND ' + RaterBEdit.Text);
      lReport.Add('No. of Cases = %d', [Ncases]);
      lReport.Add('');

      // print tables requested by use
      if (ObsChk.Checked) then
      begin
        IntArrayPrint(Freq, Nrows+1, Ncols+1, 'Frequencies',
                      RowLabels, ColLabels, 'OBSERVED FREQUENCIES', lReport);
        lReport.Add('------------------------------------------------------------------------------');
        lReport.Add('');
      end;

      if (ExpChk.Checked) then
      begin
         outline := 'EXPECTED FREQUENCIES';
         MatPrint(Expected, Nrows, Ncols, outline, RowLabels, ColLabels, NoCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');
      end;

      if (PropChk.Checked) then
      begin
         outline := 'ROW PROPORTIONS';
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
                   Prop[i-1][Ncols] := 0.0;
         end;
         MatPrint(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels, NoCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');

         outline := 'COLUMN PROPORTIONS';
         for j := 1 to Ncols + 1 do
         begin
              for i := 1 to Nrows do
              begin
                   if (Freq[Nrows,j-1] > 0.0) then
                       Prop[i-1,j-1] := Freq[i-1,j-1] / Freq[Nrows,j-1]
                   else
                       Prop[i-1,j-1] := 0.0;
              end;
              if (Freq[Nrows,j-1] > 0.0) then
                  Prop[Nrows][j-1] := 1.0
              else
                  Prop[Nrows,j-1] := 0.0;
         end;
         MatPrint(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels, NoCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');

         outline := 'PROPORTIONS OF TOTAL N';
         for i := 1 to Nrows + 1 do
              for j := 1 to Ncols + 1 do Prop[i-1,j-1] := Freq[i-1,j-1] / Ncases;
         Prop[Nrows,Ncols] := 1.0;
         MatPrint(Prop, Nrows+1, Ncols+1, outline, RowLabels, ColLabels, NoCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');
    end;

    if (ChiChk.Checked) then
    begin
         outline := 'CHI-SQUARED VALUE FOR CELLS';
         MatPrint(CellChi, Nrows, Ncols, outline, RowLabels, ColLabels, NoCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');
    end;

    lReport.Add('');
    lReport.Add('Chi-square: %.3f with D.F. %d. Prob. > value %.3f', [ChiSquare, df, ProbChi]);
    lReport.Add('');

    if yates then
         lReport.Add('Chi-square using Yates correction %.3f and Prob > value %.3f', [Adjchisqr, Adjprobchi]);

    likelihood := 0.0;
    for i := 0 to Nrows - 1 do
        for j := 0 to Ncols - 1 do
            likelihood :=  likelihood + Freq[i,j] * (ln(Expected[i,j] / Freq[i,j]));
    likelihood := -2.0 * likelihood;
    problikelihood := 1.0 - chisquaredprob(likelihood,df);
    lReport.Add('Likelihood Ratio %.3f with prob. > value %.4f', [likelihood, problikelihood]);
    lReport.Add('');

    phi := sqrt(ChiSquare / Ncases);
    lReport.Add('phi correlation: %.4f', [phi]);
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
    VarX := VarX - ((SumX * SumX) /  Ncases);
    VarY := VarY - ((SumY * SumY) /  Ncases);
    for i := 0 to Nrows - 1 do
        for j := 0 to Ncols - 1 do
            pearsonr := pearsonr + ((i+1)*(j+1) * Freq[i,j]);
    pearsonr := pearsonr - (SumX * SumY /  Ncases);
    pearsonr := pearsonr / sqrt(VarX * VarY);
    lReport.Add('Pearson Correlation r = %6.4f', [pearsonr]);
    lReport.Add('');

    MantelHaenszel := (Ncases-1) * (pearsonr * pearsonr);
    MHprob := 1.0 - chisquaredprob(MantelHaenszel,1);
    lReport.Add('Mantel-Haenszel Test of Linear Association: %.3f with probability > value = %.4f', [MantelHaenszel, MHprob]);
    lReport.Add('');

    CoefCont := sqrt(ChiSquare / (ChiSquare + Ncases));
    lReport.Add('The coefficient of contingency: %.3f', [CoefCont]);
    lReport.Add('');

    if (Nrows < Ncols) then
      CramerV := sqrt(ChiSquare / (Ncases * ((Nrows-1))))
    else
      CramerV := sqrt(ChiSquare / (Ncases * ((Ncols-1))));
    lReport.Add('Cramers V: %.3f', [CramerV]);

    // kappa
    if (Nrows = Ncols) then
    begin
       obsdiag := 0.0;
       expdiag := 0.0;
       for i := 0 to Nrows - 1 do
       begin
           obsdiag := obsdiag + Freq[i,i];
           expdiag := expdiag + Expected[i,i];
       end;
       expnondiag := Ncases - expdiag;
       Kappa := (obsdiag - expdiag) / expnondiag;
       lReport.Add('');
       lReport.Add('Unweighted Kappa: %.4f', [Kappa]);

       // get linear weights
       SetLength(weights,Nrows,Ncols);
       SetLength(quadweights,Nrows,Ncols);
       for i := 0 to Nrows - 1 do
       begin
           for j := 0 to Ncols - 1 do
           begin
               weights[i,j] := 0.0;
               quadweights[i,j] := 0.0;
           end;
       end;
       for i := 0 to Nrows - 1 do
       begin
           for j := 0 to Ncols - 1 do
           begin
               weights[i,j] := 1.0 - (abs((i-j)) / (Nrows-1));
               quadweights[i,j] := 1.0 - ( abs((i-j)*(i-j)) / ((Nrows-1)*(Nrows-1)) );
           end;
       end;

       outline := 'Observed Linear Weights';
       MatPrint(weights, Nrows, Ncols, outline, RowLabels, ColLabels, NoCases, lReport);
       lReport.Add('------------------------------------------------------------------------------');
       lReport.Add('');

       outline := 'Observed Quadratic Weights';
       MatPrint(quadweights, Nrows, Ncols, outline, RowLabels, ColLabels, NoCases, lReport);
       lReport.Add('------------------------------------------------------------------------------');
       lReport.Add('');

       for i := 0 to Nrows - 1 do
       begin
           for j := 0 to Ncols - 1 do
           begin
               pobserved := pobserved + (Freq[i][j] / Ncases) * weights[i,j];
               pexpected := pexpected + (Expected[i,j] / Ncases) * weights[i,j];
           end;
       end;
       Kappa := (pobserved - pexpected) / (1.0 - pexpected);
       lReport.Add('Linear Weighted Kappa: %.4f', [Kappa]);

       pobserved := 0.0;
       pexpected := 0.0;
       for i := 0 to Nrows - 1 do
       begin
           for j := 0 to Ncols - 1 do
           begin
               pobserved :=  pobserved + (Freq[i,j] / Ncases) * quadweights[i,j];
               pexpected :=  pexpected + (Expected[i,j] / Ncases) * quadweights[i,j];
           end;
       end;
       Kappa := (pobserved - pexpected) / (1.0 - pexpected);
       lReport.Add('Quadratic Weighted Kappa: %.4f', [Kappa]);
       quadweights := nil;
       weights := nil;
      end;

      DisplayReport(lReport);
    finally
      lReport.Free;
    end;

    // save frequency data file if elected
    if ((SaveChk.Checked) and (InputGroup.ItemIndex = 0)) then
    begin
       ClearGrid;
       for i := 1 to 3 do DictionaryFrm.NewVar(i);
       DictionaryFrm.DictGrid.Cells[1,1] := 'ROW';
       DictionaryFrm.DictGrid.Cells[1,2] := 'COL';
       DictionaryFrm.DictGrid.Cells[1,3] := 'FREQ.';
       OS3MainFrm.DataGrid.Cells[1,0] := 'ROW';
       OS3MainFrm.DataGrid.Cells[2,0] := 'COL';
       OS3MainFrm.DataGrid.Cells[3,0] := 'Freq.';
       k := 1;
       for i := 1 to Nrows do
       begin
           for j := 1 to Ncols do
           begin
               OS3MainFrm.DataGrid.RowCount := k + 1;
               OS3MainFrm.DataGrid.Cells[1,k] := IntToStr(i);
               OS3MainFrm.DataGrid.Cells[2,k] := IntToStr(j);
               OS3MainFrm.DataGrid.Cells[3,k] := IntToStr(Freq[i-1,j-1]);
               k := k + 1;
           end;
       end;
       for i := 1 to k - 1 do
       begin
           title := 'CASE ' + IntToStr(i);
           OS3MainFrm.DataGrid.Cells[0,i] := title;
       end;
       title := InputBox('FILE:','File Name:','Frequencies.LAZ');
       OS3MainFrm.FileNameEdit.Text := title;
       OS3MainFrm.NoVarsEdit.Text := IntToStr(3);
       OS3MainFrm.NoCasesEdit.Text := IntToStr(k-1);
       NoVariables := 3;
       NoCases := k-1;

       SaveOS2File;
    end;

    //clean up
    ColLabels := nil;
    RowLabels := nil;
    CellChi := nil;
    Expected := nil;
    Prop := nil;
    Freq := nil;
    ColNoSelected := nil;
end;

procedure TWeightedKappaFrm.DepInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepEdit.Text = '') then
  begin
    DepEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TWeightedKappaFrm.DepOutClick(Sender: TObject);
begin
  if DepEdit.Text <> '' then
  begin
    VarList.Items.Add(DepEdit.Text);
    DepEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TWeightedKappaFrm.UpdateBtnStates;
begin
  RowIn.Enabled := (VarList.ItemIndex > -1) and (RaterAEdit.Text = '');
  RowOut.Enabled := (RaterAEdit.Text <> '');

  ColIn.Enabled := (VarList.ItemIndex > -1) and (RaterBEdit.Text = '');
  ColOut.Enabled := (RaterBEdit.Text <> '');

  DepIn.Enabled := (InputGroup.ItemIndex > 0) and (VarList.ItemIndex > -1) and (DepEdit.Text = '');
  DepOut.Enabled := (InputGroup.ItemIndex > 0) and (DepEdit.Text <> '');
  DepEdit.Enabled := (InputGroup.ItemIndex > 0);
  DepLbl.Enabled := DepEdit.Enabled;

  NCasesEdit.Enabled := (InputGroup.ItemIndex = 2);
  NCasesLbl.Enabled := NCasesEdit.Enabled;
end;

procedure TWeightedKappaFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
   {$I kappaunit.lrs}

end.

