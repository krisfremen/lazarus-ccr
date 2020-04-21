// File for testing: cansas.laz

unit CanonUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, GraphLib, Globals, MatrixLib,
  ContextHelpUnit;

type

  { TCannonFrm }

  TCannonFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    CorsChk: TCheckBox;
    InvChk: TCheckBox;
    EigenChk: TCheckBox;
    RedundChk: TCheckBox;
    GroupBox1: TGroupBox;
    LeftIn: TBitBtn;
    LeftOut: TBitBtn;
    RightIn: TBitBtn;
    RightOut: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LeftList: TListBox;
    RightList: TListBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure LeftInClick(Sender: TObject);
    procedure LeftOutClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure RightInClick(Sender: TObject);
    procedure RightOutClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  CannonFrm: TCannonFrm;

implementation

uses
  Math,
  Utils;

{ TCannonFrm }

procedure TCannonFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  LeftList.Clear;
  RightList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TCannonFrm.RightInClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      RightList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TCannonFrm.RightOutClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < RightList.Items.Count do
  begin
    if RightList.Selected[i] then
    begin
      VarList.Items.Add(RightList.Items[i]);
      RightList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TCannonFrm.FormActivate(Sender: TObject);
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

procedure TCannonFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TCannonFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TCannonFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TCannonFrm.ComputeBtnClick(Sender: TObject);
const
  SEPARATOR = '===========================================================================';
var
  i, j, k, count, a_size, b_size, no_factors, novars, IER: integer;
  cellstring, gridstring: string;
  s, m, n, df1, df2, q, w, pcnt_extracted, trace : double;
  minroot, critical_prob, Lambda, Pillia : double;
  chisqr, HLTrace, chiprob, ftestprob, Roys, f, Hroot : double;
  raa, rbb, rab, rba, bigmat, prod, first_prod, second_prod : DblDyneMat;
  char_equation, raainv, rbbinv, eigenvectors, norm_a, norm_b : DblDyneMat;
  raw_a, raw_b, a_cors, b_cors, eigentrans, theta, tempmat : DblDyneMat;
  mean, variance, stddev, roots, root_chi, chi_prob, pv_a, pv_b : DblDyneVec;
  rd_a, rd_b, pcnt_trace : DblDyneVec;
  root_df, a_vars, b_vars : IntDyneVec;
  selected : IntDyneVec;
  RowLabels, ColLabels : StrDyneVec;
  CanLabels : StrDyneVec;
  title : string;
  NCases: integer = 0;
  errorcode: boolean = false;
  lReport: TStrings;
begin
  if LeftList.Items.Count = 0 then
  begin
    MessageDlg('No left-hand variable selected.', mtError, [mbOK], 0);
    exit;
  end;

  if RightList.Items.Count = 0 then
  begin
    MessageDlg('No right-hand variable selected.', mtError, [mbOK], 0);
    exit;
  end;

  k := 0;
  no_factors := 0;
  pcnt_extracted := 0.0;
  trace := 0.0;
  minroot := 0.0;
  critical_prob := 0.0;
  Pillia := 0.0;
  chisqr := 0.0;
  HLTrace := 0.0;
  chiprob := 0.0;

  // Get size of the Left and Right matrices (predictors and dependents)
  a_size := LeftList.Items.Count;
  b_size := RightList.Items.Count;
  novars := a_size + b_size;

  // allocate memory for matrices and vectors
  SetLength(raa,a_size,a_size);
  SetLength(rbb,b_size,b_size);
  SetLength(rab,a_size,b_size);
  SetLength(rba,b_size,a_size);
  SetLength(bigmat,novars+1,novars+1);
  SetLength(prod,novars,novars);
  SetLength(first_prod,novars,novars);
  SetLength(second_prod,novars,novars);
  SetLength(char_equation,novars,novars);
  SetLength(raainv,a_size,a_size);
  SetLength(rbbinv,b_size,b_size);
  SetLength(eigenvectors,novars,novars);
  SetLength(norm_a,novars,novars);
  SetLength(norm_b,novars,novars);
  SetLength(raw_a,novars,novars);
  SetLength(raw_b,novars,novars);
  SetLength(a_cors,novars,novars);
  SetLength(b_cors,novars,novars);
  SetLength(eigentrans,novars,novars);
  SetLength(theta,novars,novars);
  SetLength(tempmat,novars,novars);

  SetLength(mean,novars);
  SetLength(variance,novars);
  SetLength(stddev,novars);
  SetLength(roots,novars);
  SetLength(root_chi,novars);
  SetLength(chi_prob,novars);
  SetLength(pv_a,novars);
  SetLength(pv_b,novars);
  SetLength(rd_a,novars);
  SetLength(rd_b,novars);
  SetLength(pcnt_trace,novars);

  SetLength(root_df,novars);
  SetLength(a_vars,a_size);
  SetLength(b_vars,b_size);
  SetLength(CanLabels,novars);
  SetLength(RowLabels,novars);
  SetLength(ColLabels,novars);
  SetLength(Selected,novars);

  //------------ WORK STARTS HERE! -------------------------------------

  // Build labels for canonical functions 1 to novars
  for i := 1 to b_size do
    CanLabels[i-1]:='Var. ' + IntToStr(i);

  // identify variables selected for left and right variables
  for i := 0 to a_size - 1 do // identify left variables
  begin
    cellstring := LeftList.Items.Strings[i];
    for j := 1 to NoVariables do
    begin
      gridstring := OS3MainFrm.DataGrid.Cells[j,0];
      if (cellstring = gridstring) then
      begin
        a_vars[i] := j;
        RowLabels[i] := gridstring;
      end;
    end;
  end;

  // identify left variables
  for i := 0 to b_size - 1 do
  begin
    cellstring := RightList.Items.Strings[i];
    for j := 1 to NoVariables do
    begin
      gridstring := OS3MainFrm.DataGrid.Cells[j,0];
      if (cellstring = gridstring) then
      begin
        b_vars[i] := j;
        ColLabels[i] := gridstring;
      end;
    end;
  end;

  // build list of all variables selected
  for i := 1 to a_size do
    selected[i-1] := a_vars[i-1];
  for i := 1 to b_size do
    selected[i-1 + a_size] := b_vars[i-1];

  lReport := TStringList.Create;
  try
    lReport.Add('CANONICAL CORRELATION ANALYSIS');
    lReport.Add('');

    // Get means, standard deviations, etc. for total matrix
    Correlations(novars,selected,bigmat,mean,variance,stddev,errorcode,Ncases);
    count := Ncases;
    if (IER = 1)then
    begin
      MessageDlg('Zero variance found for a variable-terminating', mtError, [mbOK], 0);
      exit;
    end;

    //partition matrix into quadrants
    for i := 1 to a_size do
      for j := 1 to a_size do raa[i-1,j-1]:= bigmat[i-1,j-1];

    for i := a_size + 1 to novars do
      for j := a_size + 1 to novars do
        rbb[i-1-a_size,j-1-a_size] := bigmat[i-1,j-1];

    for i := 1 to a_size do
      for j := a_size + 1 to novars do
        rab[i-1,j-1-a_size] := bigmat[i-1,j-1];

    for i := a_size + 1 to novars do
      for j := 1 to a_size do
        rba[i-1-a_size,j-1] := bigmat[i-1,j-1];

    if CorsChk.Checked then
    begin
      title := 'Left Correlation Matrix';
      MatPrint(raa, a_size, a_size, title, RowLabels, RowLabels, NCases, lReport);
      title := 'Right Correlation Matrix';
      MatPrint(rbb, b_size, b_size, title, ColLabels, ColLabels, NCases, lReport);
      title := 'Left-Right Correlation Matrix';
      MatPrint(rab, a_size, b_size, title, RowLabels, ColLabels, NCases, lReport);
      lReport.Add('');
      lReport.Add(SEPARATOR);
      lReport.Add('');
    end;

    // get inverses of left and right hand matrices raa and rbb
    for i := 1 to a_size do
      for j := 1 to a_size do
        raainv[i-1,j-1] := raa[i-1,j-1];
    SVDinverse(raainv, a_size);
    if InvChk.Checked then
    begin
      title := 'Inverse of Left Matrix';
      MatPrint(raainv, a_size, a_size, title, RowLabels, RowLabels, NCases, lReport);
    end;

    for i := 1 to b_size do
      for j := 1 to b_size do
        rbbinv[i-1,j-1] := rbb[i-1,j-1];
    SVDinverse(rbbinv,b_size);
    if InvChk.Checked then
    begin
      title := 'Inverse of Right Matrix';
      MatPrint(rbbinv, b_size, b_size, title, ColLabels, ColLabels, NCases, lReport);
    end;

    // get products of raainv x rab and the rbbinv x rba matrix
    MatAxB(first_prod,rbbinv,rba,b_size,b_size,b_size,a_size,errorcode);
    MatAxB(second_prod,raainv,rab,a_size,a_size,a_size,b_size,errorcode);
    title := 'Right Inverse x Right-Left Matrix';
    MatPrint(first_prod, b_size, a_size, title, ColLabels, RowLabels, NCases, lReport);
    title := 'Left Inverse x Left-Right Matrix';
    MatPrint(second_prod, a_size, b_size, title, RowLabels, ColLabels, NCases, lReport);

    //get characteristic equations matrix (product of last two product matrices
    //The product should yeild rows and cols representing the smaller of the two sets
    MatAxB(char_equation,first_prod,second_prod,b_size,a_size, a_size,b_size,errorcode);
    title := 'Canonical Function';
    MatPrint(char_equation, b_size, b_size, title, CanLabels, CanLabels, NCases, lReport);

    lReport.Add('');
    lReport.Add(SEPARATOR);
    lReport.Add('');

    //  now get roots and vectors of the characteristic equation using
    // NonSymRoots routine
    minroot := 0.0;
    for i := 1 to b_size do
    begin
      roots[i-1] := 0.0;
      pcnt_trace[i-1] := 0.0;
      for j := 1 to b_size do eigenvectors[i-1,j-1] := 0.0;
    end;
    trace := 0.0;
    no_factors := b_size;
    nonsymroots(char_equation, b_size, no_factors, minroot, eigenvectors, roots,
                pcnt_trace, trace, pcnt_extracted);
    lReport.Add('Trace of the matrix:        %10.4f', [trace]);
    lReport.Add('Percent of trace extracted: %10.4f', [pcnt_extracted]);

    // Normalize smaller set weights and coumpute larger set weights
    MatTrn(eigentrans, eigenvectors, b_size, b_size);
    MatAxB(tempmat,eigentrans,rbb,b_size,b_size,b_size,b_size,errorcode);
    MatAxB(theta,tempmat,eigenvectors,b_size,b_size,b_size,b_size,errorcode);
    for j := 1 to b_size do
    begin
      q := 1.0 / sqrt(theta[j-1,j-1]);
      for i := 1 to b_size do
      begin
        norm_b[i-1,j-1] := eigenvectors[i-1,j-1] * q;
        raw_b[i-1,j-1] := norm_b[i-1,j-1] / stddev[a_size+i-1];
      end;
    end;
    MatAxB(norm_a,second_prod,norm_b,a_size,b_size,b_size,b_size,errorcode);
    for j := 1 to b_size do
    begin
      for i := 1 to a_size do
      begin
        norm_a[i-1,j-1] := norm_a[i-1,j-1] * (1.0 / sqrt(roots[j-1]));
        raw_a[i-1,j-1] := norm_a[i-1,j-1] / stddev[i-1];
      end;
    end;

    // Compute the correlations between variables and canonical variables
    MatAxB(a_cors,raa,norm_a,a_size,a_size,a_size,b_size,errorcode);
    for j := 1 to b_size do
    begin
      q := 0.0;
      for i := 1 to a_size do q := q + norm_a[i-1,j-1] * a_cors[i-1,j-1];
      q := 1.0 / sqrt(q);
      for i := 1 to a_size do a_cors[i-1,j-1] := a_cors[i-1,j-1] * q;
    end;
    MatAxB(b_cors,rbb,norm_b,b_size,b_size,b_size,b_size,errorcode);
    for j := 1 to b_size do
    begin
      q := 0.0;
      for i := 1 to b_size do q := q + norm_b[i-1,j-1] * b_cors[i-1,j-1];
      q := 1.0 / sqrt(q);
      for i := 1 to b_size do b_cors[i-1,j-1] := b_cors[i-1,j-1] * q;
    end;

    // Compute the Proportions of Variance (PVs) and Redundancy Coefficients
    for j := 1 to b_size do
    begin
      pv_a[j-1] := 0.0;
      for i := 1 to a_size do pv_a[j-1] := pv_a[j-1] + (a_cors[i-1,j-1] * a_cors[i-1,j-1]);
      pv_a[j-1] := pv_a[j-1] / a_size;
      rd_a[j-1] := pv_a[j-1] * roots[j-1];
    end;
    for j := 1 to b_size do
    begin
      pv_b[j-1] := 0.0;
      for i := 1 to b_size do pv_b[j-1] := pv_b[j-1] + (b_cors[i-1,j-1] * b_cors[i-1,j-1]);
      pv_b[j-1] := pv_b[j-1] / b_size;
      rd_b[j-1] := pv_b[j-1] * roots[j-1];
    end;

    // Compute tests of the roots
    q := a_size + b_size + 1;
    q := -(count - 1.0 - (q / 2.0));
    k := 0;
    for i := 1 to b_size do
    begin
      w := 1.0;
      for j := i to b_size do w := w * (1.0 - roots[j-1]);
      root_chi[i-1] := q * ln(w);
      root_df[i-1] := (a_size - i + 1) * (b_size - i + 1);
      chi_prob[i-1] := 1.0 - chisquaredprob(root_chi[i-1],root_df[i-1]);
      if (chi_prob[i-1] < critical_prob) then k := k + 1;
    end;
    Roys := roots[0] / (1.0 - roots[0]);
    Lambda := 1.0;
    for i := 1 to b_size do
    begin
      Hroot := roots[i-1] / (1.0 - roots[i-1]);
      Lambda := Lambda * (1.0 / (1.0 + Hroot));
      Pillia := Pillia + (Hroot / (1.0 + Hroot));
      HLTrace := HLTrace + Hroot;
    end;

    // Print remaining results
    lReport.Add('   Canonical R   Root     % Trace   Chi-Sqr  D.F.  Prob.  ');
    lReport.Add('-- ----------- --------  --------- --------- ---- --------');
    for i := 1 to b_size do
      lReport.Add('%2d %11.6f %8.3f %9.3f %9.3f %4d %8.3f',
          [i, sqrt(roots[i-1]), roots[i-1], pcnt_trace[i-1], root_chi[i-1], root_df[i-1], chi_prob[i-1]]
      );
    chisqr := -ln(Lambda) * (count - 1.0 - 0.5 * (a_size + b_size - 1.0));
    chiprob := 1.0 - chisquaredprob(chisqr,a_size * b_size);
    lReport.Add('');
    lReport.Add('Overall Tests of Significance:');
    lReport.Add('');
    lReport.Add('       Statistic           Approx. Stat.   Value    D.F.  Prob > Value');
    lReport.Add('------------------------- -------------- ---------- ----- ------------');
    lReport.Add('Wilk''s Lambda             Chi-Squared    %10.4f %3d   %12.4f', [chisqr, a_size * b_size, chiprob]);

    s := b_size;
    m := 0.5 * (a_size - b_size - 1);
    n := 0.5 * (count - b_size - a_size - 2);
    f := (HLTrace * 2.0 * (s * n + 1)) / (s * s * (2.0 * m + s + 1.0));
    df1 := s * (2.0 * m + s + 1.0);
    df2 := 2.0 * ( s * n  + 1.0);
    ftestprob := probf(f,df1,df2);
    lReport.Add('Hotelling-Lawley Trace    F-Test         %10.4f %2.0f %2.0f %12.4f', [f, df1,df2, ftestprob]);

    df2 := s * (2.0 * n + s + 1.0);
    f := (Pillia / (s - Pillia)) * ( (2.0 * n + s +1.0) / (2.0 * m + s + 1.0) );
    ftestprob := probf(f,df1,df2);
    lReport.Add('Pillai Trace              F-Test         %10.4f %2.0f %2.0f %12.4f', [f, df1,df2, ftestprob]);

    Roys := Roys * (count - 1 - a_size + b_size)/ a_size ;
    df1 := a_size;
    df2 := count - 1 - a_size + b_size;
    ftestprob := probf(Roys,df1,df2);
    lReport.Add('Roys Largest Root         F-Test         %10.4f %2.0f %2.0f %12.4f', [Roys, df1, df2, ftestprob]);

    lReport.Add('');
    lReport.Add(SEPARATOR);
    lReport.Add('');

    if EigenChk.Checked then
    begin
      title := 'Eigenvectors';
      MatPrint(eigenvectors, b_size, b_size, title, CanLabels, CanLabels, NCases, lReport);
      lReport.Add('');
      lReport.Add(SEPARATOR);
      lReport.Add('');
    end;

    title := 'Standardized Right Side Weights';
    MatPrint(norm_a, a_size, b_size, title, RowLabels, CanLabels, NCases, lReport);

    title := 'Standardized Left Side Weights';
    MatPrint(norm_b, b_size, b_size, title, ColLabels, CanLabels, NCases, lReport);

    lReport.Add('');
    lReport.Add(SEPARATOR);
    lReport.Add('');

    title := 'Raw Right Side Weights';
    MatPrint(raw_a, a_size, b_size, title, RowLabels, CanLabels, NCases, lReport);

    title := 'Raw Left Side Weights';
    MatPrint(raw_b, b_size, b_size, title, ColLabels, CanLabels, NCases, lReport);

    lReport.Add('');
    lReport.Add(SEPARATOR);
    lReport.Add('');

    title := 'Right Side Correlations with Function';
    MatPrint(a_cors, a_size, b_size, title, RowLabels, CanLabels, NCases, lReport);

    title := 'Left Side Correlations with Function';
    MatPrint(b_cors, b_size, b_size, title, ColLabels, CanLabels, NCases, lReport);

    lReport.Add('');
    lReport.Add(SEPARATOR);
    lReport.Add('');

    if RedundChk.Checked then
    begin
      lReport.Add('Redundancy Analysis for Right Side Variables');
      lReport.Add('');
      lReport.Add('            Variance Prop.    Redundancy  ');
      lReport.Add('---------- --------------- ---------------');
      for i := 1 to b_size do
        lReport.Add('%8d   %15.5f %12.5f', [i, pv_a[i-1], rd_a[i-1]]);
      lReport.Add('');

      lReport.Add('Redundancy Analysis for Left Side Variables');
      lReport.Add('');
      lReport.Add('            Variance Prop.  Redundancy ');
      lReport.Add('---------- --------------- ------------');
      for i := 1 to b_size do
        lReport.Add('%8d   %15.5f %12.5f', [i, pv_b[i-1], rd_b[i-1]]);

      lReport.Add('');
      lReport.Add(SEPARATOR);
      lReport.Add('');
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;
    Selected := nil;
    ColLabels := nil;
    RowLabels := nil;
    CanLabels := nil;
    b_vars := nil;
    a_vars := nil;
    root_df := nil;
    pcnt_trace := nil;
    rd_b := nil;
    rd_a := nil;
    pv_b := nil;
    pv_a := nil;
    chi_prob := nil;
    root_chi := nil;
    roots := nil;
    stddev := nil;
    variance := nil;
    mean := nil;
    tempmat := nil;
    theta := nil;
    eigentrans := nil;
    b_cors := nil;
    a_cors := nil;
    raw_b := nil;
    raw_a := nil;
    norm_b := nil;
    norm_a := nil;
    eigenvectors := nil;
    rbbinv := nil;
    raainv := nil;
    char_equation := nil;
    second_prod := nil;
    first_prod := nil;
    prod := nil;
    rba := nil;
    rab := nil;
    rbb := nil;
    raa := nil;
  end;
end;

procedure TCannonFrm.LeftInClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      LeftList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TCannonFrm.LeftOutClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < LeftList.Items.Count do
  begin
    if LeftList.Selected[i] then
    begin
      VarList.Items.Add(LeftList.Items[i]);
      LeftList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TCannonFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TCannonFrm.UpdateBtnStates;
var
  lSelected: Boolean;
begin
  lSelected := AnySelected(Varlist);
  LeftIn.Enabled := lSelected;
  RightIn.Enabled := lSelected;
  LeftOut.Enabled := AnySelected(LeftList);
  RightOut.Enabled := AnySelected(RightList);
end;

initialization
  {$I canonunit.lrs}

end.

