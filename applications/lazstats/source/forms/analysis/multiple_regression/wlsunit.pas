unit WLSUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Globals, MainUnit, DictionaryUnit, FunctionsLib, Matrixlib, PlotXYUnit,
  OutputUnit, DataProcs, BlankFrmUnit, ContextHelpUnit;

type

  { TWLSFrm }

  TWLSFrm = class(TForm)
    Bevel1: TBevel;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    HelpBtn: TButton;
    IndInBtn: TBitBtn;
    IndOutBtn: TBitBtn;
    WghtInBtn: TBitBtn;
    WghtOutBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    OLSChk: TCheckBox;
    PlotChk: TCheckBox;
    RegResChk: TCheckBox;
    SaveChk: TCheckBox;
    WeightChk: TCheckBox;
    OriginChk: TCheckBox;
    UserWghtsChk: TCheckBox;
    Origin2Chk: TCheckBox;
    DepVarEdit: TEdit;
    WghtVarEdit: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    IndVarList: TListBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure IndInBtnClick(Sender: TObject);
    procedure IndOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure WghtInBtnClick(Sender: TObject);
    procedure WghtOutBtnClick(Sender: TObject);
    procedure PredictIt(ColNoSelected : IntDyneVec; NoVars : integer;
              Means, StdDevs, BetaWeights : DblDyneVec;
              StdErrEst : double; NoIndepVars : integer);
    procedure PlotXY(Xpoints, Ypoints, UpConf, LowConf : DblDyneVec;
                        ConfBand, Xmean, Ymean, R, Slope, Intercept : double;
                        Xmax,  Xmin, Ymax, Ymin : double;
                        N : integer; XLabel, YLabel : string);

  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  WLSFrm: TWLSFrm;

implementation

uses
  Math;

{ TWLSFrm }

procedure TWLSFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     for i := 0 to NoVariables - 1 do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i+1,0]);
     IndVarList.Clear;
     DepVarEdit.Text := '';
     WghtVarEdit.Text := '';
     DepInBtn.Enabled := true;
     DepOutBtn.Enabled := false;
     IndInBtn.Enabled := true;
     IndOutBtn.Enabled := false;
     WghtInBtn.Enabled := true;
     WghtOutBtn.Enabled := false;
     OLSChk.Checked := true;
     PlotChk.Checked := true;
     RegResChk.Checked := true;
     WeightChk.Checked := true;
     UserWghtsChk.Checked := false;
     OriginChk.Checked := true;
     Origin2Chk.Checked := true;
end;

procedure TWLSFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TWLSFrm.WghtInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (WghtVarEdit.Text = '') then
  begin
    WghtVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TWLSFrm.WghtOutBtnClick(Sender: TObject);
begin
  if (WghtVarEdit.Text <> '') then
  begin
    VarList.Items.Add(WghtVarEdit.Text);
    WghtVarEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TWLSFrm.FormActivate(Sender: TObject);
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

  FAutoSized := True;
end;

procedure TWLSFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if BlankFrm = nil then Application.CreateForm(TBlankFrm, BlankFrm);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TWLSFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TWLSFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TWLSFrm.IndInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (i < VarList.Items.Count) do
  begin
    if (VarList.Selected[i]) then
    begin
      IndVarList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TWLSFrm.IndOutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (i < IndVarList.Items.Count) do
  begin
    if IndVarlist.Selected[i] then
    begin
      VarList.Items.Add(IndVarList.Items[i]);
      IndVarlist.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TWLSFrm.DepInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepVarEdit.Text = '') then
  begin
     DepVarEdit.Text := VarList.Items[index];
     VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TWLSFrm.DepOutBtnClick(Sender: TObject);
begin
  if (DepVarEdit.Text <> '') then
  begin
    VarList.Items.Add(DepVarEdit.Text);
    DepVarEdit.Text := '';
  end;
  UpdateBtnStates;
end;


procedure TWLSFrm.ComputeBtnClick(Sender: TObject);
VAR
     i, ii, j, Noindep, DepCol, WghtCol, olddepcol, NCases, pos, col : integer;
     IndepCols : IntDyneVec;
     RowLabels : StrDyneVec;
     X, Y : double;
     Means, Variances, StdDevs, BWeights : DblDyneVec;
     BetaWeights, BStdErrs, Bttests, tprobs : DblDyneVec;
     PrintDesc : boolean;
     Xpoints,  Ypoints, UpConf, lowConf : DblDyneVec;
     Xmax, Xmin, Ymax, Ymin, Xmean, Ymean, Xvariance, Yvariance, R : double;
     temp, SEPred, Slope, Intercept, DF, SSx, t, ConfBand, sedata : double;
     Xstddev, Ystddev, predicted : double;
     ColNoSelected : IntDyneVec;
     XLabel, YLabel : string;
     N, Xcol, Ycol, NoSelected : integer;
     lReport: TStrings;
     StdErrEst: Double = 0.0;
     R2: Double = 0.0;
     errorcode: Boolean = false;
begin
  PrintDesc := true;

  SetLength(Means, NoVariables + 2);
  SetLength(Variances, NoVariables + 2);
  SetLength(StdDevs, NoVariables + 2);
  SetLength(BWeights, NoVariables + 2);
  SetLength(BetaWeights, NoVariables + 2);
  SetLength(BStdErrs, NoVariables + 2);
  SetLength(Bttests, NoVariables + 2);
  SetLength(tprobs, NoVariables + 2);
  SetLength(RowLabels, NoVariables + 2);
  SetLength(IndepCols, NoVariables + 2);
  SetLength(Xpoints, NoCases + 1);
  SetLength(Ypoints, NoCases + 1);
  SetLength(UpConf, NoCases + 1);
  SetLength(lowConf, NoCases + 1);
  SetLength(ColNoSelected, 2);

  lReport := TStringList.Create;
  try
    NCases := NoCases;
    Noindep := IndVarList.Items.Count;
    if (Noindep = 0) then
    begin
      MessageDlg('No independent variables selected.', mtError, [mbOK], 0);
      exit;
    end;

    DepCol := 0;
    WghtCol := 0;
    for i := 0 to NoVariables - 1 do
    begin
      if (OS3MainFrm.DataGrid.Cells[i+1,0] = DepVarEdit.Text) then DepCol := i+1;
      if (OS3MainFrm.DataGrid.Cells[i+1,0] = WghtVarEdit.Text) then WghtCol := i+1;
      for j := 0 to Noindep - 1 do
      begin
        if (OS3MainFrm.DataGrid.Cells[i+1,0] = IndVarList.Items.Strings[j]) then
        begin
        IndepCols[j] := i+1;
        RowLabels[j] := IndVarList.Items.Strings[j];
        end;
      end; // next j
    end; // next i

    if (DepCol = 0) then
    begin
      MessageDlg('No dependent variable selected.', mtError, [mbOK], 0);
      exit;
     end;

    // check variable types
    if not ValidValue(DepCol,0) then
    begin
      MessageDlg('Incorrect dependent variable type.', mtError, [mbOK], 0);
      exit;
    end;

    if (WghtCol > 0) then
    begin
      if not ValidValue(WghtCol,0) then
      begin
        MessageDlg('Incorrect weight variable type.', mtError, [mbOK], 0);
        exit;
      end;
    end;

     for j := 0 to Noindep - 1 do
     begin
       if not ValidValue(IndepCols[j],0) then
       begin
         MessageDlg('Incorrect dependent variable type.', mtError, [mbOK], 0);
         exit;
       end;
     end;

     IndepCols[NoIndep] := DepCol;
     olddepcol := DepCol; // save dependent column so we can reuse DepCol

     // Get OLS regression
     if OLSChk.Checked then
     begin
       lReport.Add('OLS REGRESSION RESULTS');
       MReg(Noindep, IndepCols, DepCol, RowLabels, Means, Variances, StdDevs,
          BWeights, BetaWeights, BStdErrs, Bttests, tprobs, R2, stderrest,
          NCases, errorcode, PrintDesc, lReport);

      // Get predicted z score, residual z score, predicted raw score,
      // residual raw score and squared raw residual score.  Place in the DataGrid
      PredictIt(IndepCols, Noindep+1, Means, StdDevs, BetaWeights, stderrest, Noindep);

      lReport.Add('');
      lReport.Add('==================================================================================');
      lReport.Add('');
     end;

     if RegResChk.Checked and OLSChk.Checked then
     begin
       // Regress the squared residuals on the predictors
       DepCol := NoVariables;
       lReport.Add('REGRESSION OF SQUARED RESIDUALS ON INDEPENDENT VARIABLES');
       MReg(Noindep, IndepCols, DepCol, RowLabels, Means, Variances, StdDevs,
          BWeights, BetaWeights, BStdErrs, Bttests, tprobs, R2, stderrest,
          NCases, errorcode, PrintDesc, lReport);
       DisplayReport(lReport);
       lReport.Clear;
//       lReport.Add('');
//       lReport.Add('==================================================================================');
//       lReport.Add('');
     end;

     if WeightChk.Checked and RegResChk.Checked then
     begin
       // Get predicted squared residuals and save recipricols as weights
       col := NoVariables + 1;
       OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
       DictionaryFrm.NewVar(col);
       DictionaryFrm.DictGrid.Cells[1,col] := 'PredResid2';
       OS3MainFrm.DataGrid.Cells[col,0] := 'PredResid2';

       col := NoVariables + 1;
       OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
       DictionaryFrm.NewVar(col);
       DictionaryFrm.DictGrid.Cells[1,col] := 'WEIGHT';
       OS3MainFrm.DataGrid.Cells[col,0] := 'WEIGHT';
       OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);

       for i := 1 to NoCases do
       begin
         if (ValidValue(i,col-2)) then // do we have a valid squared OLS residual?
         begin
           predicted := 0.0;
           for j := 0 to Noindep - 1 do
           begin
             pos := IndepCols[j];
             X := StrToFloat(OS3MainFrm.DataGrid.Cells[pos,i]);
             predicted := predicted + BWeights[j] * X;
           end;
           predicted := predicted + BWeights[Noindep];
           predicted := abs(predicted);
           OS3MainFrm.DataGrid.Cells[col-1,i] := Format('%8.3f', [predicted]);
           if (predicted > 0.0) then
             predicted := 1.0 / sqrt(predicted)
           else
             predicted := 0.0;
           OS3MainFrm.DataGrid.Cells[col,i] := Format('%8.3f', [predicted]);
         end; // if valid case
       end; // next i
     end; // if regresChk

     // Now, plot squared residuals against each independent variable
     if PlotChk.Checked and RegResChk.Checked then
     begin
       Xcol := DepCol;
       for ii := 0 to NoIndep - 1 do
       begin
         Ycol := IndepCols[ii];
         N := 0;
         ColNoSelected[0] := Xcol;
         ColNoSelected[1] := Ycol;
         NoSelected := 2;
         XLabel := OS3MainFrm.DataGrid.Cells[Xcol,0];
         YLabel := OS3MainFrm.DataGrid.Cells[Ycol,0];
         Xmax := -1.0e308;
         Xmin := 1.0e308;
         Ymax := -1.0e308;
         Ymin := 1.0e308;
         Xmean := 0.0;
         Ymean := 0.0;
         Xvariance := 0.0;
         Yvariance := 0.0;
         R := 0.0;
         for i := 1 to NoCases do
         begin
           if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
           N := N + 1;
           X := StrToFloat(OS3MainFrm.DataGrid.Cells[Xcol,i]);
           Y := StrToFloat(OS3MainFrm.DataGrid.Cells[Ycol,i]);
           Xpoints[N] := X;
           Ypoints[N] := Y;
           if (X > Xmax) then Xmax := X;
           if (X < Xmin) then Xmin := X;
           if (Y > Ymax) then Ymax := Y;
           if (Y < Ymin) then Ymin := Y;
           Xmean := Xmean + X;
           Ymean := Ymean + Y;
           Xvariance := Xvariance + X * X;
           Yvariance := Yvariance + Y * Y;
           R := R + X * Y;
         end;

         // sort on X
         for i := 1 to N - 1 do
         begin
           for j := i + 1 to N do
           begin
             if (Xpoints[i] > Xpoints[j]) then //swap
             begin
               temp := Xpoints[i];
               Xpoints[i] := Xpoints[j];
               Xpoints[j] := temp;
               temp := Ypoints[i];
               Ypoints[i] := Ypoints[j];
               Ypoints[j] := temp;
             end;
           end;
         end;

         // calculate statistics
         Xvariance := Xvariance - Xmean * Xmean / N;
         SSx := Xvariance;
         Xvariance := Xvariance / (N - 1);
         Xstddev := sqrt(Xvariance);

         Yvariance := Yvariance - Ymean * Ymean / N;
         Yvariance := Yvariance / (N - 1);
         Ystddev := sqrt(Yvariance);

         R := R - Xmean * Ymean / N;
         R := R / (N - 1);
         R := R / (Xstddev * Ystddev);

         SEPred := sqrt(1.0 - R * R) * Ystddev;
         SEPred := SEPred * sqrt((N - 1) / (N - 2));
         Xmean := Xmean / N;
         Ymean := Ymean / N;
         Slope := R * Ystddev / Xstddev;
         Intercept := Ymean - Slope * Xmean;

         // Now, print the descriptive statistics if requested
         lReport.Add('X versus Y Plot');
         lReport.Add('');
         lReport.Add('X = %s, Y = %s from file %s', [
           OS3MainFrm.DataGrid.Cells[Xcol,0],
           OS3MainFrm.DataGrid.Cells[Ycol,0],
           OS3MainFrm.FileNameEdit.Text
         ]);
         lReport.Add('');
         lReport.Add('Variable     Mean   Variance  Std.Dev.');
         lReport.Add('%-10s%8.2f  %8.2f  %8.2f', [OS3MainFrm.DataGrid.Cells[Xcol,0], Xmean, Xvariance, Xstddev]);
         lReport.Add('%-10s%8.2f  %8.2f  %8.2f', [OS3MainFrm.DataGrid.Cells[Ycol,0], Ymean, Yvariance, Ystddev]);
         lReport.Add('');
         lReport.Add('Correlation:                %8.4f', [R]);
         lReport.Add('Slope:                      %8.2f', [Slope]);
         lReport.Add('Intercept:                  %8.2f', [Intercept]);
         lReport.Add('Standard Error of Estimate: %8.2f', [SEPred]);
         lReport.Add('Number of good cases:       %8d', [N]);

         DisplayReport(lReport);
         lReport.Clear;
//         lReport.Add('');
//         lReport.Add('==================================================================================');
//         lReport.Add('');

         // get upper and lower confidence points for each X value
         ConfBand := 0.95;
         DF := N - 2;
         t := inverset(ConfBand,DF);
         for i := 1 to N do
         begin
           X := Xpoints[i];
           predicted := Slope * X + Intercept;
           sedata := SEPred * sqrt(1.0 + (1.0 / N) + ((X - Xmean) * (X - Xmean) / SSx));
           UpConf[i] := predicted + (t * sedata);
           lowConf[i] := predicted - (t * sedata);
           if (UpConf[i] > Ymax) then Ymax := UpConf[i];
           if (lowConf[i] < Ymin) then Ymin := lowConf[i];
         end;

         // plot the values (and optional line and confidence band if elected)
         PlotXY(Xpoints, Ypoints, UpConf, lowConf, ConfBand, Xmean, Ymean, R,
               Slope, Intercept, Xmax, Xmin, Ymax, Ymin, N, XLabel, YLabel);
         BlankFrm.ShowModal;
       end;
     end;

     if UserWghtsChk.Checked then
     begin
       // Weight variables and do OLS regression on weighted variables
       DepCol := olddepcol;
       IndepCols[Noindep] := DepCol;
       for i := 1 to NoCases do
       begin
         Y := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[NoVariables,i])); // weight
         for j := 0 to Noindep do
         begin
           pos := IndepCols[j];
           X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[pos,i]));
           X := X * Y;
           OS3MainFrm.DataGrid.Cells[pos,i] := FloatToStr(X);
         end;
       end;

       // get means of variables and subtract from the values
       if OriginChk.Checked then
       begin
         for j := 0 to Noindep do
         begin
           Means[j] := 0.0;
           NCases := 0;
           pos := IndepCols[j];
           for i := 1 to NoCases do
           begin
             if (ValidValue(i,pos)) then
             begin
               Means[j] := Means[j] + StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[pos,i]));
               NCases := NCases + 1;
             end;
           end;
           Means[j] := Means[j] / NCases;
           for i := 1 to NoCases do
           begin
             if (ValidValue(i,pos)) then
             begin
               X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[pos,i]));
               X := X - Means[j];
               OS3MainFrm.DataGrid.Cells[pos,i] := FloatToStr(X);
             end;
           end;  // next i
         end;  // next j
       end;  // if origin checked

       lReport.Add('WLS REGRESSION RESULTS');
       MReg(Noindep, IndepCols, DepCol, RowLabels, Means, Variances, StdDevs,
          BWeights, BetaWeights, BStdErrs, Bttests, tprobs, R2, stderrest,
          NCases, errorcode, PrintDesc, lReport);
       DisplayReport(lReport);
     end // if useweightschk checked
     else
     // use the weights entered by the user
     if (UserWghtsChk.Checked) then
     begin
       // Weight variables and do OLS regression on weighted variables
       DepCol := olddepcol;
       IndepCols[Noindep] := DepCol;
       for i := 1 to NoCases do
       begin
         Y := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[WghtCol,i])); // weight
         for j := 0 to Noindep do
         begin
           pos := IndepCols[j];
           X := StrToFloat(OS3MainFrm.DataGrid.Cells[pos,i]);
           X := X * Y;
           OS3MainFrm.DataGrid.Cells[pos,i] := FloatToStr(X);
         end;
       end;
       if (OriginChk.Checked) then // get means of variables and subtract from the values
       begin
         for j := 0 to Noindep do
         begin
           Means[j] := 0.0;
           NCases := 0;
           pos := IndepCols[j];
           for i := 1 to NoCases do
           begin
             if (ValidValue(i,pos)) then
             begin
               Means[j] := Means[j] + StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[pos,i]));
               NCases := NCases + 1;
             end;
           end;
           Means[j] := Means[j] / NCases;
           for i := 1 to NoCases do
           begin
             if (ValidValue(i,pos)) then
             begin
               X := StrToFloat(OS3MainFrm.DataGrid.Cells[pos,i]);
               X := X - Means[j];
               OS3MainFrm.DataGrid.Cells[pos,i] := FloatToStr(X);
             end;
           end;  // next i
         end;  // next j
       end;  // if origin checked

       lReport.Add('WLS REGRESSION RESULTS');
       MReg(Noindep, IndepCols, DepCol, RowLabels, Means, Variances, StdDevs,
          BWeights, BetaWeights, BStdErrs, Bttests, tprobs, R2, stderrest,
          NCases, errorcode, PrintDesc, lReport);
       DisplayReport(lReport);
     end;

  finally
    lReport.Free;

    IndepCols := nil;
    RowLabels := nil;
    tprobs := nil;
    Bttests := nil;
    BStdErrs := nil;
    BetaWeights := nil;
    BWeights := nil;
    StdDevs := nil;
    Variances := nil;
    Means := nil;
    ColNoSelected := nil;
    lowConf := nil;
    UpConf := nil;
    Ypoints := nil;
    Xpoints := nil;

    // reset the variables for possible second step of WLS
    //ResetBtnClick(self);
  end;
end;

procedure TWLSFrm.PredictIt(ColNoSelected: IntDyneVec; NoVars: integer;
              Means, StdDevs, BetaWeights: DblDyneVec;
              StdErrEst: double; NoIndepVars: integer);
VAR
   col, i, j, k, Index: integer;
   predicted, zpredicted, z1, z2, resid, residsqr : double;
begin
   // routine obtains predicted raw and standardized scores and their
   // residuals.  It is assumed that the dependent variable is last in the
   // list of variable column pointers stored in the ColNoSelected vector.
   // Get the z predicted score and its residual
   col := NoVariables + 1;
//   NoVariables := col;
   OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
   DictionaryFrm.DictGrid.ColCount := 8;
   DictionaryFrm.NewVar(col);
   OS3MainFrm.DataGrid.Cells[col,0] := 'Pred.z';
   DictionaryFrm.DictGrid.Cells[1,col] := 'Pred.z';

   col := NoVariables + 1;
//   NoVariables := col;
   DictionaryFrm.NewVar(col);
   OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
   OS3MainFrm.DataGrid.Cells[col,0] := 'z Resid.';
   DictionaryFrm.DictGrid.Cells[1,col] := 'z Resid.';
   OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 2;
   for i := 1 to NoCases do
   begin
       zpredicted := 0.0;
       for j := 0 to NoIndepVars - 1 do
       begin
           k := ColNoSelected[j];
           z1 := (StrToFloat(OS3MainFrm.DataGrid.Cells[k,i]) -  Means[j]) / StdDevs[j];
           zpredicted := zpredicted + (z1 * BetaWeights[j]);
       end;
       OS3MainFrm.DataGrid.Cells[col-1,i] := Format('%8.4f',[zpredicted]);

       if StdDevs[NoVars-1] <> 0.0 then
       begin
         Index := ColNoSelected[NoVars-1];
         z2 := StrToFloat(OS3MainFrm.DataGrid.Cells[Index,i]);
         z2 := (z2 - Means[NoVars-1]) / StdDevs[NoVars-1]; // z score
         OS3MainFrm.DataGrid.Cells[col,i] := Format('%8.4f',[z2 - zpredicted]);  // z residual
       end;
   end;

   // Get raw predicted and residuals
   col := NoVariables + 1;
   OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
   DictionaryFrm.NewVar(col);
   DictionaryFrm.DictGrid.Cells[1,col] := 'Pred.Raw';
   OS3MainFrm.DataGrid.Cells[col,0] := 'Pred.Raw';
   // calculate raw predicted scores and store in DataGrid at col
   for i := 1 to NoCases do
   begin   // predicted raw obtained from previously predicted z score
       predicted := StrToFloat(OS3MainFrm.DataGrid.Cells[col-2,i]) * StdDevs[NoVars-1] + Means[NoVars-1];
       OS3MainFrm.DataGrid.Cells[col,i] := Format('%8.3f',[predicted]);
   end;

   // Calculate residuals of predicted raw scores end;
   col := NoVariables +1;
   OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
   DictionaryFrm.NewVar(col);
   DictionaryFrm.DictGrid.Cells[1,col] := 'Raw Resid.';
   OS3MainFrm.DataGrid.Cells[col,0] := 'Raw Resid.';

   for i := 1 to NoCases do
   begin
       Index := ColNoSelected[NoVars-1];
       resid := StrToFloat(OS3MainFrm.DataGrid.Cells[col-1,i]) -  StrToFloat(OS3MainFrm.DataGrid.Cells[Index,i]);
       OS3MainFrm.DataGrid.Cells[col,i] := Format('%8.3f',[resid]);
   end;

   // get square of raw residuals
   col := NoVariables + 1;
   DictionaryFrm.NewVar(col);
   OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
   DictionaryFrm.DictGrid.Cells[1,col] := 'ResidSqr';
   OS3MainFrm.DataGrid.Cells[col,0] := 'ResidSqr';
   for i := 1 to NoCases do
   begin
       residsqr := StrToFloat(OS3MainFrm.DataGrid.Cells[col-1,i]);
       residsqr := residsqr * residsqr;
       OS3MainFrm.DataGrid.Cells[col,i] := Format('%8.3f',[residsqr]);
   end;
end;

procedure TWLSFrm.PlotXY(Xpoints, Ypoints, UpConf, LowConf : DblDyneVec;
                        ConfBand, Xmean, Ymean, R, Slope, Intercept : double;
                        Xmax,  Xmin, Ymax, Ymin : double;
                        N : integer; XLabel, YLabel : string);
VAR
     i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
     vhi, hwide, offset, strhi, imagehi : integer;
     valincr, Yvalue, Xvalue, value : double;
     Title, outline : string;

begin
     BlankFrm.Image1.Canvas.Clear;
     Title := 'X versus Y PLOT Using File: ' + OS3MainFrm.FileNameEdit.Text;
     BlankFrm.Caption := Title;
     imagewide := BlankFrm.Image1.Width;
     imagehi := BlankFrm.Image1.Height;
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;
     BlankFrm.Image1.Canvas.Rectangle(0,0,imagewide,imagehi);
     BlankFrm.Image1.Canvas.FloodFill(0,0,clWhite,fsBorder);
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

     // draw Means
          ypos := round(vhi * ( (Ymax - Ymean) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          xpos := hright;
          BlankFrm.Image1.Canvas.Pen.Color := clGreen;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          Title := 'MEAN ';
          Title := Title + YLabel;
          strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
          ypos := ypos - strhi div 2;
          BlankFrm.Image1.Canvas.Brush.Color := clWhite;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

          xpos := round(hwide * ( (Xmean - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          ypos := vtop;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          ypos := vbottom;
          BlankFrm.Image1.Canvas.Pen.Color := clGreen;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          Title := 'MEAN ';
          Title := Title + XLabel;
          strhi := BlankFrm.Image1.Canvas.TextWidth(Title);
          xpos := xpos - strhi div 2;
          ypos := vtop - BlankFrm.Image1.Canvas.TextHeight(Title);
          BlankFrm.Image1.Canvas.Brush.Color := clWhite;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

     // draw slope line
          BlankFrm.Image1.Canvas.Pen.Color := clBlack;
          Yvalue := (Xpoints[1] * Slope) + Intercept; // predicted score
          ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[1]- Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          Yvalue := (Xpoints[N] * Slope) + Intercept; // predicted score
          ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[N] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);

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
     xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(XLabel) div 2);
     ypos := vbottom + 20;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,XLabel);
     outline := format('R(X,Y) := %5.3f, Slope := %6.2f, Intercept := %6.2f',
              [R,Slope,Intercept]);
     Title := outline;
     xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(Title) div 2);
     ypos := ypos + 15;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

     // Draw vertical axis
     Title := YLabel;
//     xpos := hleft - 10 - BlankFrm.Image1.Canvas.TextWidth(Title) / 2;
     xpos := 10;
     ypos := vtop - 8 - BlankFrm.Image1.Canvas.TextHeight(Title);
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,YLabel);
     xpos := hleft;
     ypos := vtop;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     ypos := vbottom;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     valincr := (Ymax - Ymin) / 10.0;
     for i := 1 to 11 do
     begin
          value := Ymax - ((i-1) * valincr);
          outline := format('%8.2f',[value]);
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
     for i := 1 to N do
     begin
          ypos := round(vhi * ( (Ymax - Ypoints[i]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.Brush.Color := clNavy;
          BlankFrm.Image1.Canvas.Brush.Style := bsSolid;
          BlankFrm.Image1.Canvas.Pen.Color := clNavy;
          BlankFrm.Image1.Canvas.Ellipse(xpos,ypos,xpos+5,ypos+5);
     end;

     // draw confidence bands if requested
     if not (ConfBand = 0.0) then
     begin
          BlankFrm.Image1.Canvas.Pen.Color := clRed;
          ypos := round(vhi * ((Ymax - UpConf[1]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[1] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          for i := 2 to N do
          begin
               ypos := round(vhi * ((Ymax - UpConf[i]) / (Ymax - Ymin)));
               ypos := ypos + vtop;
               xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
               xpos := xpos + hleft;
               BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          end;
          ypos := round(vhi * ((Ymax - LowConf[1]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[1] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          for i := 2 to N do
          begin
               ypos := round(vhi * ((Ymax - LowConf[i]) / (Ymax - Ymin)));
               ypos := ypos + vtop;
               xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
               xpos := xpos + hleft;
               BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          end;
     end;
end;

procedure TWLSFrm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i:=0 to VarList.Items.Count-1 do
    if Varlist.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  DepInBtn.Enabled := lSelected and (DepVarEdit.Text = '');
  IndInBtn.Enabled := lSelected;
  WghtInBtn.Enabled := lSelected and (WghtVarEdit.Text = '');

  lSelected := false;
  for i:=0 to IndVarList.Items.Count-1 do
    if IndVarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  DepOutBtn.Enabled := (DepVarEdit.Text <> '');
  IndOutBtn.Enabled := lSelected;
  WghtOutBtn.Enabled := (WghtVarEdit.Text <> '');
end;


initialization
  {$I wlsunit.lrs}

end.

