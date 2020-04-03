unit StepFwdMRUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Globals, MainUnit, MatrixLib, OutputUnit, FunctionsLib, DataProcs;

type

  { TStepFwdFrm }

  TStepFwdFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    GroupBox2: TGroupBox;
    OpenDialog1: TOpenDialog;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    PredictChkBox: TCheckBox;
    MatSaveChkBox: TCheckBox;
    MatInChkBox: TCheckBox;
    SaveDialog1: TSaveDialog;
    SDChkBox: TCheckBox;
    VarChkBox: TCheckBox;
    MeansChkBox: TCheckBox;
    CorrsChkBox: TCheckBox;
    CovChkBox: TCheckBox;
    CPChkBox: TCheckBox;
    GroupBox1: TGroupBox;
    InProb: TEdit;
    OutProb: TEdit;
    InBtn: TBitBtn;
    Label4: TLabel;
    Label5: TLabel;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    DepVar: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SelList: TListBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure SelListSelectionChange(Sender: TObject; User: boolean);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end;

var
  StepFwdFrm: TStepFwdFrm;

implementation

uses
  Math;

{ TStepFwdFrm }

procedure TStepFwdFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  SelList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);

  DepVar.Text := '';
  InProb.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  OutProb.Text := FormatFloat('0.00', 0.10);

  CPChkBox.Checked := false;
  CovChkBox.Checked := false;
  CorrsChkBox.Checked := true;
  MeansChkBox.Checked := true;
  VarChkBox.Checked := false;
  SDChkBox.Checked := true;
  MatInChkBox.Checked := false;
  MatSaveChkBox.Checked := false;
  PredictChkBox.Checked := false;
end;

procedure TStepFwdFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := Max(200, AllBtn.Top + AllBtn.Height - VarList.Top); //GroupBox2.Top + Groupbox2.Height - VarList.Top);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TStepFwdFrm.FormCreate(Sender: TObject);
begin
   Assert(OS3MainFrm <> nil);
end;

procedure TStepFwdFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TStepFwdFrm.AllBtnClick(Sender: TObject);
var
  index: integer;
begin
  for index := 0 to VarList.Items.Count-1 do
    SelList.Items.Add(VarList.Items[index]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TStepFwdFrm.ComputeBtnClick(Sender: TObject);
Label
  lastone;
var
   i, j, k, k1, NoVars, NCases,errcnt : integer;
   Index, NoIndepVars : integer;
   largest, R2, Constant: double;
   StdErrEst, NewR2, LargestPartial : double;
   pdf1, pdf2, PartF, PartProb, LargestProb, POut : double;
   SmallestProb : double;
   BetaWeights : DblDyneVec;
   cellstring: string;
   corrs : DblDyneMat;
   Means : DblDyneVec;
   Variances : DblDyneVec;
   StdDevs : DblDyneVec;
   ColNoSelected : IntDyneVec;
   title : string;
   RowLabels : StrDyneVec;
   ColLabels : StrDyneVec;
//   IndRowLabels : StrDyneVec;
//   IndColLabels : StrDyneVec;
//   IndepCorrs : DblDyneMat;
   IndepInverse : DblDyneMat;
   IndepIndex : IntDyneVec;
//   XYCorrs : DblDyneVec;
   matched : boolean;
   Partial : DblDyneVec;
   Candidate : IntDyneVec;
   TempNoVars : Integer;
   StepNo : integer;
   filename : string;
   errorcode : boolean = false;
   lReport: TStrings;
   tmp: Double;
begin
  if InProb.Text = '' then
  begin
    InProb.SetFocus;
    MessageDlg('Probability to enter not specified.', mtError, [mbOK], 0);
    exit;
  end;
  if OutProb.Text = '' then
  begin
    OutProb.SetFocus;
    MessageDlg('Probability to retain not specified.', mtError, [mbOK], 0);
    exit;
  end;
  if not TryStrToFloat(InProb.Text, tmp) then
  begin
    InProb.SetFocus;
    MessageDlg('No valid number.', mtError, [mbOK], 0);
    exit;
  end;
  if not TryStrToFloat(OutProb.Text, tmp) then
  begin
    OutProb.SetFocus;
    MessageDlg('No valid number.', mtError, [mbOK], 0);
    exit;
  end;

  if NoVariables = 0 then
    NoVariables := 200;
  SetLength(corrs, NoVariables+1, NoVariables+1);
//  SetLength(IndepCorrs, NoVariables, NoVariables);
  SetLength(IndepInverse, NoVariables, NoVariables);
  SetLength(Means, NoVariables);
  SetLength(Variances, NoVariables);
  SetLength(StdDevs, NoVariables);
  SetLength(RowLabels, NoVariables);
  SetLength(ColLabels, NoVariables);
//  SetLength(XYCorrs, NoVariables);
  SetLength(IndepIndex, NoVariables);
//  SetLength(IndColLabels, NoVariables);
//  SetLength(IndRowLabels, NoVariables);
  SetLength(BetaWeights, NoVariables);
  SetLength(Partial, NoVariables);
  SetLength(Candidate, NoVariables);
  SetLength(ColNoSelected, NoVariables);

  lReport := TStringList.Create;
  try
    lReport.Add('STEPWISE MULTIPLE REGRESSION by Bill Miller');
    StepNo := 1;
    errcnt := 0;
    errorcode := false;
    if MatInChkBox.Checked then
    begin
      OpenDialog1.Filter := 'LazStats matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
      OpenDialog1.FilterIndex := 1;
      if OpenDialog1.Execute then
      begin
        filename := OpenDialog1.FileName;
        MatRead(Corrs, NoVars, NoVars, Means, StdDevs, NCases, RowLabels, ColLabels, filename);
        for i := 0 to NoVars-1 do
        begin
          Variances[i] := sqr(StdDevs[i]);
          ColNoSelected[i] := i+1;
        end;
        DepVar.Text := RowLabels[NoVars-1];
        for i := 0 to NoVars-2 do SelList.Items.Add(RowLabels[i]);
        Messagedlg('Last variable in matrix is the dependent variable.', mtInformation, [mbOK], 0);
      end;
    end;

    if not MatInChkBox.Checked then
    begin
      { get independent item columns }
      NoVars := SelList.Items.Count;
      if NoVars < 1 then
      begin
        MessageDlg('No independent variables selected.', mtError, [mbOK], 0);
        exit;
      end;

      for i := 0 to NoVars-1 do
      begin
        cellstring := SelList.Items.Strings[i];
        for j := 1 to NoVariables do
        begin
          if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
          begin
            ColNoSelected[i] := j;
            RowLabels[i] := cellstring;
            ColLabels[i] := cellstring;
          end;
        end;
      end;

      { get dependendent variable column }
      if DepVar.Text = '' then
      begin
        MessageDlg('No Dependent variable selected.', mtError, [mbOK], 0);
        exit;
      end;

      NoVars := NoVars + 1;
      for j := 1 to NoVariables do
      begin
        if DepVar.Text = OS3MainFrm.DataGrid.Cells[j,0] then
        begin
          ColNoSelected[NoVars-1] := j;
          RowLabels[NoVars-1] := DepVar.Text;
          ColLabels[NoVars-1] := DepVar.Text;
        end;
      end;

      if CPChkBox.Checked then
      begin
        title := 'Cross-Products Matrix';
        GridXProd(NoVars, ColNoSelected, Corrs, errorcode, NCases);
        MatPrint(Corrs, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
        lReport.Add('');
      end;

      if CovChkBox.Checked then
      begin
        title := 'Variance-Covariance Matrix';
        GridCovar(NoVars, ColNoSelected, Corrs, Means, Variances, StdDevs, errorcode, NCases);
        MatPrint(Corrs, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
        lReport.Add('');
      end;

      Correlations(NoVars, ColNoSelected, Corrs, Means, Variances, StdDevs, errorcode, NCases);
    end;

    if CorrsChkBox.Checked then
     begin
       title := 'Product-Moment Correlations Matrix';
       MatPrint(Corrs, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
       lReport.Add('');
     end;

    if MatSaveChkBox.Checked then
    begin
      SaveDialog1.Filter := 'LazStats matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
      SaveDialog1.FilterIndex := 1;
      if SaveDialog1.Execute then
      begin
        filename := SaveDialog1.FileName;
        MatSave(Corrs, NoVars, NoVars, Means, StdDevs, NCases, RowLabels, ColLabels, filename);
      end;
    end;

    if MeansChkBox.Checked = true then
    begin
      title := 'Means';
      DynVectorPrint(Means, NoVars, title, ColLabels, NCases, lReport);
      lReport.Add('');
    end;

    if VarChkBox.Checked  then
    begin
      title := 'Variances';
      DynVectorPrint(Variances, NoVars, title, ColLabels, NCases, lReport);
      lReport.Add('');
    end;

    if SDChkBox.Checked = true then
    begin
      title := 'Standard Deviations';
      DynVectorPrint(StdDevs, NoVars, title, ColLabels, NCases, lReport);
      lReport.Add('');
    end;

    if errorcode then
    begin
      lReport.Add('One or more correlations could not be computed due to zero variance of a variable.');
      DisplayReport(lReport);
      MessageDlg('A selected variable has no variability-run aborted.', mtError, [mbOk], 0);
      exit;
    end;

    lReport.Add('');
    lReport.Add('=====================================================================');
    lReport.Add('');

    lReport.Add('STEPWISE MULTIPLE REGRESSION by Bill Miller');

    {  Select largest correlation to begin. Note: dependent is last variable }
    largest := 0.0;
    Index := 1;
    for i := 1 to NoVars - 1 do
    begin
      if abs(corrs[i-1,NoVars-1]) > largest then
      begin
        largest := abs(corrs[i-1,NoVars-1]);
        Index := i;
      end;
    end;
    NoIndepVars := 1;
    IndepIndex[NoIndepVars-1] := Index;
    POut := StrToFloat(OutProb.Text);
    lReport.Add('');
    lReport.Add('----------------- STEP %d ------------------', [StepNo]);
    MReg2(NCases, NoVars, NoIndepVars, IndepIndex, corrs, IndepInverse,
          RowLabels, R2, BetaWeights,
          Means, Variances, errcnt, StdErrEst, constant, POut, true, true, false,
          lReport);

    lReport.Add('');
    lReport.Add('=====================================================================');
    lReport.Add('');

    while NoIndepVars < NoVars-1 do
    begin
      { select the next independent variable based on the largest
        semipartial correlation with the dependent variable.  The
        squared semipartial for each remaining independent variable
        is the difference between the squared MC of the dependent
        variable with all previously entered variables plus a candidate
        variable and the squared MC with just the previously entered
        variables ( the previously obtained R2 ). }

      { build list of candidates }
      StepNo := StepNo + 1;
      k := 0;
      for i := 1 to NoVars - 1 do
      begin
        matched := false;
        for j := 0 to NoIndepVars-1 do
          if IndepIndex[j] = i then matched := true;
        if not matched then
        begin
          k := k + 1;
          Candidate[k-1] := i;
        end;
      end;   { k is the no. of candidates }

      lReport.Add('');
      lReport.Add('Candidates for entry in next step:');
      lReport.Add('');
      lReport.Add('Candidate  Partial  F Statistic  Prob.  DF1  DF2');

      LargestProb := 0.0;
      SmallestProb := 1.0;
      for k1 := 1 to k do
      begin
        { get Mult Corr. with previously entered plus candidate }
        IndepIndex[NoIndepVars] := Candidate[k1-1];
        TempNoVars := NoIndepVars + 1;
        MReg2(NCases, NoVars, TempNoVars, IndepIndex, corrs, IndepInverse,
              RowLabels, NewR2, BetaWeights, Means, Variances,
              errcnt, StdErrEst, constant, POut, false, false,false, lReport);
        Partial[k1-1] := (NewR2 - R2) / (1.0 - R2);
        pdf1 := 1;
        pdf2 := NCases - TempNoVars - 1;
        PartF := ((NewR2 - R2) * pdf2) / (1.0 - NewR2);
        PartProb := probf(PartF, pdf1, pdf2);
        if PartProb < SmallestProb then SmallestProb := PartProb;
        if PartProb > LargestProb then LargestProb := PartProb;
        lReport.Add('%-10s  %6.4f   %7.4f    %6.4f   %3.0f  %3.0f', [
          RowLabels[Candidate[k1-1]-1],
          sqrt(abs(Partial[k1-1])),
          PartF, PartProb, pdf1, pdf2
        ]);
      end;

      if (SmallestProb > StrToFloat(InProb.Text)) then
      begin
        lReport.Add('No further steps meet criterion for entry.');
        goto lastone;
      end;

      { select variable with largest partial to enter next }
      largestpartial := 0.0;
      Index := 1;
      for i := 1 to k do
      begin
        if Partial[i-1] > LargestPartial then
        begin
          Index := Candidate[i-1];
          LargestPartial := Partial[i-1];
        end;
      end;

      lReport.Add('Variable %s will be added', [RowLabels[Index-1]]);
      NoIndepVars := NoIndepVars + 1;
      IndepIndex[NoIndepVars-1] := Index;
      lReport.Add('');
      lReport.Add('----------------- STEP %d ------------------', [StepNo]);
      MReg2(NCases, NoVars, NoIndepVars, IndepIndex, corrs, IndepInverse,
            RowLabels, R2, BetaWeights, Means, Variances,
            errcnt, StdErrEst, constant, POut, true, true, false, lReport);

      if (errcnt > 0) or (NoIndepVars = NoVars-1)  then { out tolerance exceeded - finish up }
lastone:
      begin
        lReport.Add('');
        lReport.Add('-------------FINAL STEP-----------');
        MReg2(NCases, NoVars, NoIndepVars, IndepIndex, corrs, IndepInverse,
              RowLabels, NewR2, BetaWeights, Means, Variances,
              errcnt, StdErrEst, constant, POut, true, false, false, lReport);
        k1 := NoIndepVars; { store temporarily }
        NoIndepVars := NoVars; { this stops loop }
      end;
    end; { while not done }

    lReport.Add('');
    lReport.Add('=====================================================================');
    lReport.Add('');

    NoIndepVars := k1;
    { add [predicted scores, residual scores, etc. to grid if options elected }
    if MatInChkBox.Checked then PredictChkBox.Checked := false;
    if PredictChkBox.Checked then
      Predict(ColNoSelected, NoVars, IndepInverse, Means, StdDevs, BetaWeights, StdErrEst, IndepIndex, NoIndepVars);

    DisplayReport(lReport);

  finally
    lReport.Free;
    ColNoSelected := nil;
    Candidate := nil;
    Partial := nil;
    BetaWeights := nil;
//    IndColLabels := nil;
//    IndRowLabels := nil;
    IndepIndex := nil;
//    XYCorrs := nil;
    ColLabels := nil;
    RowLabels := nil;
    StdDevs := nil;
    Variances := nil;
    Means := nil;
    IndepInverse := nil;
//    IndepCorrs := nil;
    corrs := nil;
  end;
end;

procedure TStepFwdFrm.DepInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepVar.Text = '') then
  begin
    DepVar.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TStepFwdFrm.DepOutBtnClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TStepFwdFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      SelList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TStepFwdFrm.SelListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TStepFwdFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < SelList.Items.Count do
  begin
    if SelList.Selected[i] then
    begin
      VarList.Items.Add(SelList.Items[i]);
      SelList.Items.Delete(i);
      i := 0;
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TStepFwdFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  DepInBtn.Enabled := (VarList.ItemIndex > -1) and (DepVar.Text = '');
  DepOutBtn.Enabled := (DepVar.Text <> '');

  lSelected := false;
  for i:=0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to SelList.Items.Count-1 do
    if SelList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;
end;


initialization
  {$I stepfwdmrunit.lrs}

end.

