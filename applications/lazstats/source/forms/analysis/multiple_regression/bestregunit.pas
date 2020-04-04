unit BestRegUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Globals, MainUnit, MatrixLib, OutputUnit, FunctionsLib, DataProcs;


type

  { TBestRegFrm }

  TBestRegFrm = class(TForm)
    Bevel1: TBevel;
    CPChkBox: TCheckBox;
    ComboShowChkBox: TCheckBox;
    CovChkBox: TCheckBox;
    CorrsChkBox: TCheckBox;
    MeansChkBox: TCheckBox;
    VarChkBox: TCheckBox;
    SDChkBox: TCheckBox;
    MatSaveChkBox: TCheckBox;
    PredictChkBox: TCheckBox;
    MatInChkBox: TCheckBox;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DepVar: TEdit;
    InProb: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    BlockList: TListBox;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    VarList: TListBox;

    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);


  private
    { private declarations }
    FAutoSized: boolean;
    pred_labels  : StrDyneVec;
    y_ptr, v     : integer;
    ii, jj       : integer;
    pointer      : integer;
    sets         : integer;
    selected     : IntDyneVec;
    max_set      : IntDyneVec;
    cross_prod   : DblDyneMat;
    ind_mat      : DblDyneMat;
    end_of_set   : boolean;
    all_done     : boolean;
    more_to_do   : boolean;
    no_predictors: integer;
    last_set     : integer;
    first_pt     : integer;
    testval      : integer;
    sumx         : DblDyneVec;
    mean         : DblDyneVec;
    stddev       : DblDyneVec;
    variance     : DblDyneVec;
    xycross      : DblDyneVec;
    raw_b        : DblDyneVec;
    count        : double;
    b_zero       : double;
    stop_prob    : double;
    mult_R2      : double;
    biggest_R2   : double;
    last_R2      : double;
    f_test       : double;
    t, beta      : double;
    ss_res       : double;
    ms_res       : double;
    ss_reg       : double;
    ms_reg       : double;
    df_reg       : integer;
    df_res       : integer;
    df1          : integer;
    df_tot       : integer;
    prob_f       : double;
    ss_total     : double;
    seb          : double;
    R2_diff      : double;
    prout        : double;
    errorcode    : integer;
    errcode      : boolean;
    DepVarCol    : integer;
    RowLabels    : StrDyneVec;
    ColLabels    : StrDyneVec;
    ColNoSelected : IntDyneVec;
    NCases       : integer;
    NoVars       : integer;

    procedure Init;
    procedure Regress(AReport: TStrings);
    procedure BestSetStats(AReport: TStrings);
    procedure BumpOne;
    procedure StartSet;
    procedure Reset;

    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  BestRegFrm: TBestRegFrm;

implementation

uses
  Math;

{ TBestRegFrm }

procedure TBestRegFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  BlockList.Clear;
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  DepVar.Text := '';

  CPChkBox.Checked := false;
  CovChkBox.Checked := false;
  CorrsChkBox.Checked := true;
  MeansChkBox.Checked := true;
  VarChkBox.Checked := false;
  SDChkBox.Checked := true;
  MatSaveChkBox.Checked := false;
  PredictChkBox.Checked := false;

  UpdateBtnStates;
end;

procedure TBestRegFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TBestRegFrm.ComputeBtnClick(Sender: TObject);
var
  i, j: integer;
  title: string;
  cellstring: string;
  filename: string;
  R2: double;
  StdErrEst: double;
  IndepIndex: IntDyneVec;
  constant: double;
  lReport: TStrings;
begin
  if InProb.Text = '' then
  begin
    InProb.SetFocus;
    MessageDlg('Probability for inclusion not specified.', mtError, [mbOK], 0);
    exit;
  end;

  if not TryStrToFloat(InProb.Text, stop_prob) then   // probability to include a block
  begin
    InProb.SetFocus;
    MessageDlg('No number given for probability.', mtError, [mbOk], 0);
    exit;
  end;

  if MatInChkBox.Checked then
    NoVariables := 200;

  SetLength(cross_prod, NoVariables+1, NoVariables+1);
  SetLength(ind_mat, NoVariables+1, NoVariables+1);
  SetLength(sumx, NoVariables);
  SetLength(mean, NoVariables);
  SetLength(stddev, NoVariables);
  SetLength(variance, NoVariables);
  SetLength(xycross, NoVariables);
  SetLength(raw_b, NoVariables);
  SetLength(RowLabels, NoVariables);
  SetLength(ColLabels, NoVariables);
  SetLength(IndepIndex, NoVariables);
  SetLength(ColNoSelected, NoVariables);
  SetLength(Selected, NoVariables);
  SetLength(Max_Set, NoVariables);
  SetLength(pred_labels, NoVariables);

  lReport := TStringList.Create;
  try
    lReport.Add('BEST COMBINATION MULTIPLEX REGRESSION by Bill Miller');
    errorcode := 0;
    last_R2 := 0.0;
    last_set := 0 ;
    more_to_do := TRUE;
    prout := 1.0;

    { get data }
    if MatInChkBox.Checked then
    begin
      PredictChkBox.Checked := false;
      MatSaveChkBox.Checked := false;
      CPChkBox.Checked := false;
      OpenDialog1.Filter := 'LazStats matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
      OpenDialog1.FilterIndex := 1;
      if OpenDialog1.Execute then
      begin
        filename := OpenDialog1.FileName;
        MatRead(cross_prod, NoVars, NoVars, Mean, stddev, NCases, RowLabels, ColLabels, filename);
        for i := 1 to NoVars do
          variance[i-1] := sqr(stddev[i-1]);
        MessageDlg('Last variable in matrix is the dependent variable', mtInformation, [mbOK], 0);
        lReport.Add('=====================================================================');
      end;

      if CorrsChkBox.Checked then
      begin
        lReport.Add('');
        title := 'Product-Moment Correlations Matrix';
        MatPrint(cross_prod, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
        lReport.Add('=====================================================================');
      end;

      if MeansChkBox.Checked then
      begin
        lReport.Add('');
        title := 'Means';
        DynVectorPrint(mean, NoVars, title, ColLabels, NCases, lReport);
        lReport.Add('=====================================================================');
      end;

      if VarChkBox.Checked then
      begin
        lReport.Add('');
        title := 'Variances';
        DynVectorPrint(variance, NoVars, title, ColLabels, NCases, lReport);
        lReport.Add('=====================================================================');
      end;

      if SDChkBox.Checked = true then
      begin
        lReport.Add('');
        title := 'Standard Deviations';
        DynVectorPrint(stddev, NoVars, title, ColLabels, NCases, lReport);
        lReport.Add('=====================================================================');
      end;

      DepVarCol := NoVars;
      y_ptr := NoVars;
      DepVar.Text := RowLabels[NoVars];

      { convert correlations to deviation cross-products }
      for i := 1 to NoVars do
        for j := 1 to NoVars do
          cross_prod[i-1,j-1] := cross_prod[i-1,j-1] * stddev[i-1] * stddev[j-1] * (NCases - 1);
    end;

    if not MatInChkBox.Checked then
    begin
      { get independent item columns }
      NoVars := BlockList.Items.Count;
      if NoVars < 1 then
      begin
        MessageDlg('No independent variables selected.', mtError, [mbOK], 0);
        exit;
      end;

      for i := 1 to NoVars do
      begin
        cellstring := BlockList.Items.Strings[i-1];
        for j := 1 to NoVariables do
        begin
          if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
          begin
            ColNoSelected[i-1] := j;
            RowLabels[i-1] := cellstring;
            ColLabels[i-1] := cellstring;
          end;
        end;
      end;

      { get dependendent variable column }
      if DepVar.Text = '' then
      begin
        MessageDlg('No dependent variable selected.', mtError, [mbOK], 0);
        exit;
      end;
      DepVarCol := 0;
      NoVars := NoVars + 1;
      y_ptr := NoVars;
      for j := 1 to NoVariables do
      begin
        if DepVar.Text = OS3MainFrm.DataGrid.Cells[j,0] then
        begin
          DepVarCol := j;
          ColNoSelected[NoVars-1] := j;
          RowLabels[NoVars-1] := OS3MainFrm.DataGrid.Cells[j,0];
          ColLabels[NoVars-1] := RowLabels[NoVars-1];
        end;
      end;

      Init;

      title := 'Cross-Products Matrix';
      GridXProd(NoVars,ColNoSelected,cross_prod,true,NCases);
      for i := 1 to NoVars do
      begin
        sumx[i-1] := cross_prod[i-1,NoVars];
        mean[i-1] := sumx[i-1] / NCases;
        variance[i-1] := cross_prod[i-1,i-1] - (sumx[i-1] * sumx[i-1] / NCases);
        variance[i-1] := variance[i-1] / (NCases-1);
        if variance[i-1] > 0 then
          stddev[i-1] := sqrt(variance[i-1])
        else begin
          MessageDlg('No variance for a variable!',mtError, [mbOK], 0);
          exit;
        end;
      end;

      if CPChkBox.Checked then
      begin
        lReport.Add('');
        MatPrint(cross_prod, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
        lReport.Add('=====================================================================');
      end;

      {get deviation cross-products matrix}
      for i := 1 to NoVars do
        for j := 1 to NoVars do
          cross_prod[i-1,j-1] := cross_prod[i-1,j-1] - (mean[i-1] * mean[j-1] * NCases);
    end;

    if CovChkBox.Checked then
    begin
      lReport.Add('');
      title := 'Deviation Cross-Products Matrix';
      MatPrint(cross_prod, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
      lReport.Add('=====================================================================');
    end;

    v := NoVars;
    no_predictors := v - 1;
    ss_total := cross_prod[y_ptr-1,y_ptr-1];
    biggest_R2 := 0.0;

    { Find best single predictor }
    sets := 1;
    for j := 1 to no_predictors do
    begin
      selected[0] := j;
      Regress(lReport);
    end;
    BestSetStats(lReport);

    { Find best combinations of 2 to no_predictors - 1 }
    sets := 2;
    while sets < no_predictors do
    begin
      end_of_set := FALSE;
      StartSet();
      while not end_of_set do
      begin
        Regress(lReport);
        BumpOne();
      end;
      Regress(lReport);
      BestSetStats(lReport);
      inc(sets);
    end;
    dec(sets);  // no. of predictors

    { Find regression with all of the predictors }
    if more_to_do then
    begin
      sets := no_predictors;
      for i := 1 to sets do  selected[i-1] := i;
      Regress(lReport);
      BestSetStats(lReport);
    end
    else begin
      lReport.Add('');
      lReport.Add('Last variable added failed entry test. Job ended.');
    end;

    if not MatInChkBox.Checked then
    begin
      { get correlation matrix and save if elected }
      Correlations(NoVars, ColNoSelected, cross_prod, mean, variance, stddev, errcode, NCases);
      if CorrsChkBox.Checked then
      begin
        title := 'Product-Moment Correlations Matrix';
        MatPrint(cross_prod, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
        lReport.Add('=====================================================================');
      end;

      if MeansChkBox.Checked then
      begin
        title := 'Means';
        DynVectorPrint(mean, NoVars, title, ColLabels, NCases, lReport);
        lReport.Add('=====================================================================');
      end;

      if VarChkBox.Checked then
      begin
        title := 'Variances';
        DynVectorPrint(variance, NoVars, title, ColLabels, NCases, lReport);
        lReport.Add('=====================================================================');
      end;

      if SDChkBox.Checked then
      begin
        title := 'Standard Deviations';
        DynVectorPrint(stddev, NoVars, title, ColLabels, NCases, lReport);
        lReport.Add('=====================================================================');
      end;

      if MatSaveChkBox.Checked  then
      begin
        SaveDialog1.Filter := 'LazStats matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
        SaveDialog1.FilterIndex := 1;
        if SaveDialog1.Execute then
        begin
          filename := SaveDialog1.FileName;
          MatSave(cross_prod, NoVars, NoVars, mean, stddev, NCases, RowLabels, ColLabels, filename);
        end;
      end;

      { add [predicted scores, residual scores, etc. to grid if options elected }
      if PredictChkBox.Checked then
      begin
        for i := 1 to sets do
        begin
          ii := selected[i-1];
          IndepIndex[i-1] := ii; //ColNoSelected[ii];
        end;
        prout := 1.0;

        MReg2(NCases, NoVars, sets, IndepIndex, cross_prod, ind_mat,
          RowLabels, R2, raw_b, mean, variance,
          errorcode, StdErrEst, constant,prout, true, false,false, lReport
        );

        Predict(ColNoSelected, NoVars, ind_mat, mean, stddev,
          raw_b, StdErrEst, IndepIndex, sets
        );
      end;
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;
    pred_labels := nil;
    Max_Set := nil;
    Selected := nil;
    ColNoSelected := nil;
    IndepIndex := nil;
    ColLabels := nil;
    RowLabels := nil;
    raw_b := nil;
    xycross := nil;
    variance := nil;
    stddev := nil;
    mean := nil;
    sumx := nil;
    ind_mat := nil;
    cross_prod := nil;
  end;
end;

procedure TBestRegFrm.Init;
var
  i, j: integer;
begin
  count := 0.0;
  for i := 1 to NoVariables do
  begin
    sumx[i-1] := 0.0;
    mean[i-1] := 0.0;
    variance[i-1] := 0.0;
    stddev[i-1] := 0.0;
    for j := 1 to v do cross_prod[i-1,j-1] := 0.0;
  end;
end;

procedure TBestRegFrm.Regress(AReport: TStrings);
var
  i, j: integer;
begin
  b_zero := 0.0 ;
  ss_reg := 0.0 ;
  for i := 1 to sets do
    raw_b[i-1] := 0.0 ;

  { Set up matrices of deviation cross_products to use }
  for i := 1 to sets do
  begin
    ii := selected[i-1];
    xycross[i-1] := cross_prod[y_ptr-1,ii-1];
    for j := 1 to sets do
    begin
      jj := selected[j-1];
      ind_mat[i-1,j-1] := cross_prod[ii-1,jj-1];
    end;
  end;

  SVDinverse(ind_mat, sets);

  for i := 1 to sets do
  begin
    ii := selected[i-1];
    for j := 1 to sets do
      raw_b[i-1] := raw_b[i-1] + (ind_mat[i-1,j-1] * xycross[j-1]) ;
    b_zero := b_zero + raw_b[i-1] * mean[ii-1];
  end;
  b_zero := mean[y_ptr-1] - b_zero;

  { Get sum of squares for regression and multiple R }
  for i := 1 to sets do
    ss_reg := ss_reg + raw_b[i-1] * xycross[i-1];
  mult_R2 := ss_reg / ss_total;

  { Now, check to see if this R2 is largest.  If so, save set }
  if mult_R2 > biggest_R2 then
  begin
    biggest_R2 := mult_R2;
    for i := 1 to sets do
      max_set[i-1] := selected[i-1];
  end;

  { print out this combination for testing purposes }
  if ComboShowChkBox.Checked then
  begin
    AReport.Add(' Set %d includes variables:', [sets]);
    for i := 1 to sets do
      AReport.Add('variable %d (%s)', [selected[i-1], ColLabels[selected[i-1]-1]]);
    AReport.Add('');
    AReport.Add('Squared  R: %.4f', [mult_R2]);
    AReport.Add('');
  end;
end;

procedure TBestRegFrm.BestSetStats(AReport: TStrings);
var
  i, j: integer;
  outline: string;
begin
  AReport.Add('');
  AReport.Add('Variables entered in step %d', [sets]);
  for i := 1 to sets do
  begin
    ii := max_set[i-1];
    selected[i-1] := max_set[i-1];
    AReport.Add('%2d %s',[max_set[i-1],ColLabels[ii-1]]);
  end;
  AReport.Add('');

  Regress(AReport);

  AReport.Add('Squared Multiple Correlation: %.4f', [mult_r2]);
  AReport.Add('Dependent variable:  %s', [ColLabels[y_ptr-1]]);
  AReport.Add('');
  AReport.Add('ANOVA for Regression Effects: ');
  AReport.Add('SOURCE      df           SS           MS            F             Prob');

  df_reg := sets;
  df_res := round(NCases) - sets - 1;
  df_tot := round(NCases) - 1;
  ms_reg := ss_reg / df_reg;
  ss_res := ( 1.0 - mult_R2) * ss_total ;
  ms_res := ss_res / df_res ;
  f_test := ms_reg / ms_res ;
  prob_f := probf(f_test, df_reg,df_res);

  { Get variance of b coefficients }
  AReport.Add('Regression %3d %14.4f %14.4f %14.4f %14.4f', [df_reg, ss_reg, ms_reg, f_test, prob_f]);
  AReport.Add('Residual   %3d %14.4f %14.4f', [df_res, ss_res, ms_res]);
  AReport.Add('Total      %3d %14.4f', [df_tot, ss_total]);
  AReport.Add('');

  AReport.Add('Variables in the equation');
  AReport.Add('VARIABLE            b        s.e. b    Beta    t    prob. t');
  for i := 1 to sets do
    for j := 1 to sets do
      ind_mat[i-1,j-1] := ind_mat[i-1,j-1] * ms_res ;
  for i := 1 to sets do
  begin
    ii := selected[i-1];
    pred_labels[i-1] := ColLabels[ii-1];
    outline := Format('%16s %10.5f ',[ColLabels[ii-1],raw_b[i-1]]);
    seb := sqrt(ind_mat[i-1,i-1]);
    t := raw_b[i-1] / seb ;
    f_test := t * t ;
    prob_f := probf(f_test,1,df_res);
    beta := raw_b[i-1] * stddev[ii-1] / stddev[y_ptr-1] ;
    outline := outline + Format('%8.4f %8.4f %6.3f %6.4f', [seb,beta,t,prob_f]);
    AReport.Add(outline);
  end;

  AReport.Add('(Intercept)      %10.5f',[b_zero]);
  AReport.Add('');

{    MAT_PRINT(sets,ind_mat,pred_labels,'Variance-covariance matrix of b s');}

  { Now see if the gain was significant over last step }
  df1 := sets - last_set ;
  f_test := ((mult_R2 - last_R2 ) / df1 ) / ( (1.0 - mult_R2) / df_res) ;
  prob_f :=  probf(f_test, df1,df_res);
  if prob_f > stop_prob then more_to_do := FALSE ;
  R2_diff := mult_R2 - last_R2 ;
  AReport.Add('Increase in squared R for this step: %8.6f', [R2_diff]);
  AReport.Add('F: %.4f with D.F. %d and %d with Probability %.4f', [f_test, df1, df_res, prob_f]);
  AReport.Add('');
  AReport.Add('----------------------------------------------------------');

  last_set := sets;
  last_R2 := mult_R2;
end;

procedure TBestRegFrm.BumpOne;
begin
  if selected[first_pt-1] < no_predictors then
    selected[first_pt-1] := selected[first_pt-1] + 1
  else
  begin
    all_done := false;
    while not all_done do
    begin
      first_pt := first_pt -1;
      if first_pt < 1 then
        all_done := true
      else
      begin
        selected[first_pt-1] := selected[first_pt-1] + 1;
        if selected[first_pt-1] < selected[first_pt] then
        begin
          Reset();
          first_pt := pointer;
          all_done := true;
        end else
          selected[first_pt-1] := selected[first_pt-1] - 1;
      end;
    end;
  end;
end;

procedure TBestRegFrm.StartSet;
var
  i: integer;
begin
  end_of_set := false;
  for i := 1 to sets do
    selected[i-1] := i;
  first_pt := sets;
  pointer := sets;
end;

procedure TBestRegFrm.Reset;
var
  i: integer;
begin
  testval := no_predictors - sets + 1 ;
  if (first_pt = 1) and (selected[first_pt-1] = testval) then
    end_of_set := TRUE
  else
    for i := first_pt + 1 to sets do
      selected[i-1] := selected[i-2] + 1;
end;

procedure TBestRegFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      BlockList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TBestRegFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < BlockList.Items.Count do
  begin
    if BlockList.Selected[i] then
    begin
      VarList.Items.Add(BlockList.Items[i]);
      BlockList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TBestRegFrm.AllBtnClick(Sender: TObject);
var
  index: integer;
begin
  for index := 0 to VarList.Items.Count-1 do
    BlockList.Items.Add(VarList.Items[index]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TBestRegFrm.DepInBtnClick(Sender: TObject);
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

procedure TBestRegFrm.DepOutBtnClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TBestRegFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := AllBtn.Top + AllBtn.Height - VarList.Top;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TBestRegFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  InProb.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
end;

procedure TBestRegFrm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i:=0 to VarList.Items.Count - 1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to BlockList.Items.Count-1 do
    if BlockList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;

  DepInBtn.Enabled := (VarList.ItemIndex > -1) and (DepVar.Text <= '');
  DepOutBtn.Enabled := DepVar.Text <> '';
end;

procedure TBestRegFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I bestregunit.lrs}

end.

