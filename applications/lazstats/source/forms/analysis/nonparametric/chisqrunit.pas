unit ChiSqrUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons,
  MainUnit, OutputUnit, FunctionsLib, GraphLib, Globals, MatrixLib,
  DataProcs, DictionaryUnit;

type

  { TChiSqrFrm }

  TChiSqrFrm = class(TForm)
    Bevel1: TBevel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    ObsChk: TCheckBox;
    ExpChk: TCheckBox;
    PropsChk: TCheckBox;
    CellChiChk: TCheckBox;
    SaveFChk: TCheckBox;
    OptionsGroup: TGroupBox;
    YatesChk: TCheckBox;
    RowIn: TBitBtn;
    RowOut: TBitBtn;
    ColIn: TBitBtn;
    ColOut: TBitBtn;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    NCasesEdit: TEdit;
    NCasesLabel: TLabel;
    RowEdit: TEdit;
    ColEdit: TEdit;
    DepEdit: TEdit;
    InputGrp: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    AnalyzeLabel: TLabel;
    VarList: TListBox;
    procedure ColInClick(Sender: TObject);
    procedure ColOutClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InputGrpClick(Sender: TObject);
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
  ChiSqrFrm: TChiSqrFrm;

implementation

uses
  Math;

{ TChiSqrFrm }

procedure TChiSqrFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  RowEdit.Text := '';
  ColEdit.Text := '';
  DepEdit.Text := '';
  DepEdit.Enabled := false;
  NCasesLabel.Enabled := false;
  AnalyzeLabel.Enabled := false;
  NCasesEdit.Text := '';
  NCasesEdit.Enabled := false;
  InputGrp.ItemIndex := 0;
  ObsChk.Checked := false;
  ExpChk.Checked := false;
  PropsChk.Checked := false;
  CellChiChk.Checked := false;
  SaveFChk.Checked := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TChiSqrFrm.RowInClick(Sender: TObject);
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

procedure TChiSqrFrm.RowOutClick(Sender: TObject);
begin
  if RowEdit.Text <> '' then
  begin
    VarList.Items.Add(RowEdit.Text);
    RowEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TChiSqrFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TChiSqrFrm.ColInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (ColEdit.Text = '') then
  begin
    ColEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TChiSqrFrm.ColOutClick(Sender: TObject);
begin
  if ColEdit.Text <> '' then
  begin
    VarList.Items.Add(ColEdit.Text);
    ColEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TChiSqrFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, RowNo, ColNo, DepNo, MinRow, MaxRow, MinCol, MaxCol : integer;
   Row, Col, NoSelected, Ncases, Nrows, Ncols, FObs, df : integer;
   RowLabels, ColLabels : StrDyneVec;
   ColNoSelected : IntDyneVec;
   cellstring: string;
   Freq : IntDyneMat;
   Prop, Expected, CellChi : DblDyneMat;
   PObs, ChiSquare, ProbChi, phi, SumX, SumY, VarX, VarY, liklihood : double;
   yates : boolean;
   title : string;
   Adjchisqr, probliklihood, G, pearsonr, MantelHaenszel, MHprob : double;
   Adjprobchi, CoefCont, CramerV : double;
   lReport: TStrings;
begin
     if RowEdit.Text = '' then
     begin
       MessageDlg('Row variable not selected.', mtError, [mbOK], 0);
       exit;
     end;
     if ColEdit.Text = '' then
     begin
       MessageDlg('Column variable not selected.', mtError, [mbOK], 0);
       exit;
     end;
     if DepEdit.Text = '' then
     begin
       MessageDlg('Variable to analyze is not selected', mtError, [mbOK], 0);
       exit;
     end;
     if InputGrp.ItemIndex = 2 then
     begin
       if NCasesEdit.Text = '' then
       begin
         NCasesEdit.SetFocus;
         MessageDlg('Total number of cases not selected.', mtError, [mbOk], 0);
         exit;
       end;
       if not TryStrToInt(NCasesEdit.Text, i) then
       begin
         NCasesEdit.SetFocus;
         Messagedlg('Numberical input expected for total number of cases.', mtError, [mbOK], 0);
         exit;
       end;
     end;

     SetLength(ColNoSelected,NoVariables);
     yates := false;
     RowNo := 0;
     ColNo := 0;
     DepNo := 0;
     for i := 1 to NoVariables do
     begin
          cellstring := OS3MainFrm.DataGrid.Cells[i,0];
          if cellstring = RowEdit.Text then RowNo := i;
          if cellstring = ColEdit.Text then ColNo := i;
          if cellstring = DepEdit.Text then DepNo := i;
     end;
     ColNoSelected[0] := RowNo;
     ColNoSelected[1] := ColNo;
     NoSelected := 2;
     if InputGrp.ItemIndex > 0 then // for reading proportions or frequencies
     begin
          NoSelected := 3;
          ColNoSelected[2] := DepNo;
     end;
     // get min and max of row and col numbers
     MinRow := 1000;
     MaxRow := 0;
     MinCol := 1000;
     MaxCol := 0;
     for i := 1 to NoCases do
     begin
          if NOT GoodRecord(i,NoSelected,ColNoSelected) then continue;
          Row := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[RowNo,i])));
          Col := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ColNo,i])));
          if Row > MaxRow then MaxRow := Row;
          if Row < MinRow then MinRow := Row;
          if Col > MaxCol then MaxCol := Col;
          if Col < MinCol then MinCol := Col;
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
         for j := 1 to Ncols + 1 do Freq[i-1,j-1] := 0;

     // get cell data
     NCases := 0;
     case InputGrp.ItemIndex of
     0 : begin // count number of cases in each row and column combination
              for i := 1 to NoCases do
              begin
                   if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
                   NCases := NCases + 1;
                   Row := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[RowNo,i])));
                   Col := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ColNo,i])));
                   Row := Row - MinRow + 1;
                   Col := Col - MinCol + 1;
                   Freq[Row-1,Col-1] := Freq[Row-1,Col-1] + 1;
              end;
         end;
     1 : begin // read frequencies data from grid
              for i := 1 to NoCases do
              begin
                   if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
                   Row := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[RowNo,i])));
                   Col := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ColNo,i])));
                   Row := Row - MinRow + 1;
                   Col := Col - MinCol + 1;
                   FObs := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepNo,i])));
                   Freq[Row-1,Col-1] := Freq[Row-1,Col-1] + FObs;
                   NCases := NCases + FObs;
              end;
         end;
     2 : begin // get no. of cases and proportions for each cell
               NCases := StrToInt(NCasesEdit.Text);
              for i := 1 to NoCases do
              begin
                   if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
                   Row := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[RowNo,i])));
                   Col := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ColNo,i])));
                   Row := Row - MinRow + 1;
                   Col := Col - MinCol + 1;
                   PObs := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepNo,i]));
                   Freq[Row-1,Col-1] := Freq[Row-1,Col-1] + round(PObs * NCases);
              end;
         end;
     end; // end case
     Freq[Nrows,Ncols] := NCases;

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
     AdjChisqr := 0.0;
     if (YatesChk.Checked) and (Nrows = 2) and (Ncols = 2) then yates := true;
     for i := 1 to Nrows do
     begin
          for j := 1 to Ncols do
          begin
               Expected[i-1,j-1] := Freq[Nrows,j-1] * Freq[i-1,Ncols] / NCases;
               if Expected[i-1,j-1] > 0.0 then
                  CellChi[i-1,j-1] := sqr(Freq[i-1,j-1] - Expected[i-1,j-1]) / Expected[i-1,j-1]
               else begin
                    MessageDlg('Zero expected value found.', mtError, [mbOK], 0);
                    CellChi[i-1,j-1] := 0.0;
               end;
               ChiSquare := ChiSquare + CellChi[i-1,j-1];
          end;
     end;
     df := (Nrows - 1) * (Ncols - 1);
     if yates = true then // 2 x 2 corrected chi-square
     begin
          Adjchisqr := abs((Freq[0,0] * Freq[1,1]) - (Freq[0,1] * Freq[1,0]));
          Adjchisqr := sqr(Adjchisqr - NCases / 2.0) * NCases; // numerator
          Adjchisqr := Adjchisqr / (Freq[0,2] * Freq[1,2] * Freq[2,0] * Freq[2,1]);
          Adjprobchi := 1.0 - chisquaredprob(Adjchisqr,df);
     end;
     ProbChi := 1.0 - chisquaredprob(ChiSquare,df); // prob. larger chi

    //Print results to output form
    lReport := TStringList.Create;
    try
      lReport.Add('CHI-SQUARE ANALYSIS RESULTS');

      // print tables requested by use
      for i := 1 to Nrows do RowLabels[i-1] := Format('Row %d', [i]);
      RowLabels[Nrows] := 'Total';
      for j := 1 to Ncols do ColLabels[j-1] := Format('COL.%d', [j]);
      ColLabels[Ncols] := 'Total';

      if ObsChk.Checked then
      begin
        IntArrayPrint(Freq, Nrows+1, Ncols+1,'Rows',
                      RowLabels, ColLabels,'OBSERVED FREQUENCIES', lReport);
        lReport.Add('------------------------------------------------------------------------------');
        lReport.Add('');
      end;

      if ExpChk.Checked then
      begin
         title := 'EXPECTED FREQUENCIES';
         MatPrint(Expected,Nrows,Ncols,title,RowLabels,ColLabels,NCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');
      end;

      if PropsChk.Checked then
      begin
         title := 'ROW PROPORTIONS';
         for i := 1 to Nrows + 1 do
         begin
              for j := 1 to Ncols do
              begin
                   if Freq[i-1,Ncols] > 0.0 then
                        Prop[i-1,j-1] := Freq[i-1,j-1] / Freq[i-1,Ncols]
                   else Prop[i-1,j-1] := 0.0;
              end;
              if Freq[i-1,Ncols] > 0.0 then Prop[i-1,Ncols] := 1.0
              else Prop[i-1,Ncols] := 0.0;
         end;
         MatPrint(Prop,Nrows+1,Ncols+1,title,RowLabels,ColLabels,NCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');
         title := 'COLUMN PROPORTIONS';
         for j := 1 to Ncols + 1 do
         begin
              for i := 1 to Nrows do
              begin
                   if Freq[Nrows,j-1] > 0.0 then
                       Prop[i-1,j-1] := Freq[i-1,j-1] / Freq[Nrows,j-1]
                   else Prop[i-1,j-1] := 0.0;
              end;
              if Freq[Nrows,j-1] > 0.0 then Prop[NRows,j-1] := 1.0
              else Prop[NRows,j-1] := 0.0;
         end;
         MatPrint(Prop,Nrows+1,Ncols+1,title,RowLabels,ColLabels,NCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');
         Title := 'PROPORTIONS OF TOTAL N';
         for i := 1 to Nrows + 1 do
              for j := 1 to Ncols + 1 do Prop[i-1,j-1] := Freq[i-1,j-1] / NCases;
         Prop[Nrows,Ncols] := 1.0;
         MatPrint(Prop,Nrows+1,Ncols+1,title,RowLabels,ColLabels,NCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');
      end;

      if CellChiChk.Checked then
      begin
         title := 'CHI-SQUARED VALUE FOR CELLS';
         MatPrint(CellChi,Nrows,Ncols,title,RowLabels,ColLabels,NCases, lReport);
         lReport.Add('------------------------------------------------------------------------------');
         lReport.Add('');
      end;

      lReport.Add('Chi-square: %.3f with D.F. = %d. Prob. > value %.3f', [ChiSquare, df, ProbChi]);
      lReport.Add('');
      if yates then
        lReport.Add('Chi-square using Yates correction: %.3f and Prob > value: %.3f', [Adjchisqr, Adjprobchi]);

      liklihood := 0.0;
      for i := 0 to Nrows-1 do
        for j := 0 to Ncols-1 do
             if (Freq[i,j] > 0.0) then
                liklihood := Liklihood + (Freq[i,j] * (ln(Expected[i,j] / Freq[i,j])));
      liklihood := -2.0 * liklihood;
      probliklihood := 1.0 - chisquaredprob(liklihood,df);
      lReport.Add('Likelihood Ratio: %.3f with prob. > value %.4f', [liklihood, probliklihood]);

      G := 0.0;
      for i := 0 to Nrows-1 do
        for j := 0 to Ncols-1 do
                if (Expected[i,j] > 0) then
                   G :=  G + Freq[i,j] * (ln(Freq[i,j] / Expected[i,j]));
      G := 2.0 * G;
      probliklihood := 1.0 - chisquaredprob(G,df);
      lReport.Add('G statistic: %.3f with prob. > value %.4f', [G, probliklihood]);

      if ((Nrows > 1) and (Ncols > 1)) then
      begin
        phi := sqrt(ChiSquare / Ncases);
        lReport.Add('phi correlation: %.4f', [phi]);
        lReport.Add('');

        pearsonr := 0.0;
        SumX := 0.0;
        SumY := 0.0;
        VarX := 0.0;
        VarY := 0.0;
        for i := 0 to Nrows-1 do SumX := SumX + ( (i+1) * Freq[i,Ncols] );
        for j := 0 to Ncols-1 do SumY := SumY + ( (j+1) * Freq[Nrows,j] );
        for i := 0 to Nrows-1 do VarX := VarX + ( ((i+1)*(i+1)) * Freq[i,Ncols] );
        for j := 0 to Ncols-1 do VarY := VarY + ( ((j+1)*(j+1)) * Freq[Nrows,j] );
        VarX := VarX - ((SumX * SumX) / Ncases);
        VarY := VarY - ((SumY * SumY) / Ncases);
        for i := 0 to Nrows-1 do
                for j := 0 to Ncols-1 do
                        pearsonr := pearsonr + ((i+1)*(j+1) * Freq[i,j]);
        pearsonr := pearsonr - (SumX * SumY / Ncases);
        pearsonr := pearsonr / sqrt(VarX * VarY);
        lReport.Add('Pearson Correlation r: %.4f', [pearsonr]);
        lReport.Add('');

        MantelHaenszel := (Ncases-1) * (pearsonr * pearsonr);
        MHprob := 1.0 - chisquaredprob(MantelHaenszel,1);
        lReport.Add('Mantel-Haenszel Test of Linear Association: %.3f with probability > value %.4f', [MantelHaenszel, MHprob]);
        lReport.Add('');

        CoefCont := sqrt(ChiSquare / (ChiSquare + Ncases));
        lReport.Add('The coefficient of contingency: %.3f', [CoefCont]);
        lReport.Add('');

        if (Nrows < Ncols) then
           CramerV := sqrt(ChiSquare / (Ncases * ((Nrows-1))))
        else
           CramerV := sqrt(ChiSquare / (Ncases * ((Ncols-1))));
        lReport.Add('Cramers V: %.3f', [CramerV]);
        lReport.Add('');
      end;

      DisplayReport(lReport);
    finally
      lReport.Free;
    end;

    // save frequency data file if elected
    if SaveFChk.Checked then
    begin
         OS3MainFrm.CloseFileBtnClick(self);
         OS3MainFrm.FileNameEdit.Text := '';
         for i := 1 to DictionaryFrm.DictGrid.RowCount - 1 do
              for j := 0 to 7 do DictionaryFrm.DictGrid.Cells[j,i] := '';
         DictionaryFrm.DictGrid.RowCount := 1;
//         DictionaryFrm.FileNameEdit.Text := '';

         // get labels for new file
         ColLabels[0] := 'ROW';
         ColLabels[1] := 'COL';
         ColLabels[2] := 'FREQ';
         // create new variables
         Row := 0;
         OS3MainFrm.DataGrid.ColCount := 4;
         DictionaryFrm.DictGrid.ColCount := 8;
         NoVariables := 0;
         for i := 1 to 3 do
         begin
              col := NoVariables + 1;
              DictionaryFrm.NewVar(col);
              DictionaryFrm.DictGrid.Cells[1,col] := ColLabels[i-1];
              OS3MainFrm.DataGrid.Cells[col,0] := ColLabels[i-1];
              NoVariables := NoVariables + 1;
         end;
         OS3MainFrm.DataGrid.RowCount := (Nrows * NCols) + 1;
         for i := 1 to Nrows do
         begin
              for j := 1 to Ncols do
              begin
                   Row := Row + 1;
                   OS3MainFrm.DataGrid.Cells[0,Row] := Format('Case:%d',[Row]);
                   OS3MainFrm.DataGrid.Cells[1,Row] := IntToStr(i);
                   OS3MainFrm.DataGrid.Cells[2,Row] := IntToStr(j);
                   OS3MainFrm.DataGrid.Cells[3,Row] := IntToStr(Freq[i-1,j-1]);
              end;
         end;
         NoCases := Row;
         OS3MainFrm.FileNameEdit.Text := 'ChiSqrFreq.LAZ';
         OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
         OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
//         OS3MainFrm.SaveFileBtnClick(self);
    end;

    //clean up
    ColLabels := nil;
    RowLabels := nil;
    CellChi := nil;
    Expected := nil;
    Prop := nil;
    Freq := nil;
    ColNoSelected := nil;
    ResetBtnClick(self);
end;

procedure TChiSqrFrm.DepInClick(Sender: TObject);
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

procedure TChiSqrFrm.DepOutClick(Sender: TObject);
begin
  if DepEdit.Text <> '' then
  begin
    VarList.Items.Add(DepEdit.Text);
    DepEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TChiSqrFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight :=
    OptionsGroup.Top + OptionsGroup.Height - VarList.Top - NCasesEdit.Height - NCasesEdit.BorderSpacing.Top;
  Constraints.MinWidth := OptionsGroup.Width * 2 + 3 * VarList.BorderSpacing.Left;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TChiSqrFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TChiSqrFrm.InputGrpClick(Sender: TObject);
begin
  case InputGrp.ItemIndex of
    0: begin   // have to count cases in each row and col. combination
         NCasesLabel.Enabled := false;
         NCasesEdit.Enabled := false;
         DepIn.Enabled := false;
         DepOut.Enabled := false;
         DepEdit.Enabled := false;
       end;
    1: begin   // frequencies available for each row and column combo
         NCasesLabel.Enabled := false;
         NCasesEdit.Enabled := false;
         DepIn.Enabled := true;
         DepEdit.Enabled := true;
         AnalyzeLabel.Enabled := true;
       end;
    2: begin   // only proportions available - get N size
         NCasesLabel.Enabled := true;
         AnalyzeLabel.Enabled := true;
         NCasesEdit.Enabled := true;
         NCasesEdit.SetFocus;
         DepIn.Enabled := true;
         DepOut.Enabled := false;
         DepEdit.Enabled := true;
       end;
  end;
end;

procedure TChiSqrFrm.UpdateBtnStates;
begin
  RowIn.Enabled := (VarList.Items.Count > 0) and (RowEdit.Text = '');
  ColIn.Enabled := (VarList.Items.Count > 0) and (ColEdit.Text = '');
  DepIn.Enabled := (VarList.Items.Count > 0) and (DepEdit.Text = '');

  RowOut.Enabled := (RowEdit.Text <> '');
  ColOut.Enabled := (ColEdit.Text <> '');
  DepOut.Enabled := (DepEdit.Text <> '');
end;

procedure TChiSqrFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I chisqrunit.lrs}

end.

