// Use file "abrdata.laz" for testing

unit AxSANOVAUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, FunctionsLib, GraphLib, Globals,
  DataProcs, ContextHelpUnit;

type

  { TAxSAnovaFrm }

  TAxSAnovaFrm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    PosthocChk: TCheckBox;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    HelpBtn: TButton;
    RepInBtn: TBitBtn;
    RepOutBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    PlotChk: TCheckBox;
    GrpVar: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RepList: TListBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GrpVarChange(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure RepInBtnClick(Sender: TObject);
    procedure RepOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: Boolean;
    procedure PostHocTests(NoSelected: integer; MSerr: double; dferr: integer;
      Count: integer; ColMeans: DblDyneVec; AReport: TStrings);
    procedure UpdateBtnStates;

    // wp: replace the following methods by those in ANOVATestUnit?
    procedure Tukey(
      error_ms    : double;      { mean squared for residual }
      error_df    : double;      { deg. freedom for residual }
      value       : double;      { size of smallest group }
      group_total : DblDyneVec;  { sum of scores in a group }
      group_count : DblDyneVec;  { no. of cases in a group }
      min_grp     : integer;     { minimum group code }
      max_grp     : integer;     { maximum group code }
      AReport     : TStrings);

    procedure ScheffeTest(
      error_ms    : double;      { mean squared residual }
      group_total : DblDyneVec;  { sum of scores in a group }
      group_count : DblDyneVec;  { count of cases in a group }
      min_grp     : integer;     { code of first group }
      max_grp     : integer;     { code of last group  }
      total_n     : double;      { total number of cases }
      AReport     : TStrings);

    procedure Newman_Keuls(
      error_ms    : double;      { residual mean squared }
      error_df    : double;      { deg. freedom for error }
      value       : double;      { number in smallest group }
      group_total : DblDyneVec;  { sum of scores in a group }
      group_count : DblDyneVec;  { count of cases in a group }
      min_grp     : integer;     { lowest group code }
      max_grp     : integer;     { largest group code }
      AReport     : TStrings);

    procedure Tukey_Kramer(
      error_ms    : double;      { residual mean squared }
      error_df    : double;      { deg. freedom for error }
      value       : double;      { number in smallest group }
      group_total : DblDyneVec;  { sum of scores in group }
      group_count : DblDyneVec;  { number of caes in group }
      min_grp     : integer;     { code of lowest group }
      max_grp     : integer;     { code of highst group }
      AReport     : TStrings);

    procedure TukeyBTest(
      ErrorMS     : double;      { within groups error }
      ErrorDF     : double;      { degrees of freedom within }
      group_total : DblDyneVec;   { vector of group sums }
      group_count : DblDyneVec;   { vector of group n's }
      min_grp     : integer;      { smallest group code }
      max_grp     : integer;      { largest group code }
      groupsize   : double;       { size of groups (all equal) }
      AReport     : TStrings);

  public
    { public declarations }
  end; 

var
  AxSAnovaFrm: TAxSAnovaFrm;

implementation

uses
  Math,
  OutputUnit;

{ TAxSAnovaFrm }

procedure TAxSAnovaFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Items.Clear;
  RepList.Items.Clear;
  GrpVar.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  PlotChk.Checked := false;
  UpdateBtnStates;
end;

procedure TAxSAnovaFrm.FormActivate(Sender: TObject);
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

  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TAxSAnovaFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TAxSAnovaFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TAxSAnovaFrm.GrpVarChange(Sender: TObject);
begin
  UpdateBtnStates;
end;

procedure TAxSAnovaFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TAxSAnovaFrm.RepInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if (VarList.Selected[i]) then
    begin
      RepList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  VarList.ItemIndex := -1;
  UpdateBtnStates;
end;

procedure TAxSAnovaFrm.RepOutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < RepList.Items.Count do
  begin
    if RepList.Selected[i] then
    begin
      VarList.Items.Add(RepList.Items[i]);
      RepList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  VarList.ItemIndex := -1;
  RepList.ItemIndex := -1;
  UpdateBtnStates;
end;

procedure TAxSAnovaFrm.DepInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (GrpVar.Text = '') then
  begin
    GrpVar.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  VarList.ItemIndex := -1;
  UpdateBtnStates;
end;

procedure TAxSAnovaFrm.ComputeBtnClick(Sender: TObject);
var
  a1, a2, agrp, i, j, k, v1, totaln, NoSelected, range: integer;
  group, col: integer;
  p, X, f1, f2, f3, probf1, probf2, probf3, fd1, fd2, TotMean: double;
  TotStdDev, den, maxmean: double;
  C, StdDev: DblDyneMat;
  squaredsumx, sumxsquared, coltot, sumsum: DblDyneVec;
  degfree: array[1..8] of integer;
  ColNoSelected: IntDyneVec;
  ss: array[1..8] of double;
  ms: array[1..8] of double;
  coeff: array[1..6] of double;
  N: IntDyneVec;
  value, outline: string;
  lReport: TStrings;
begin
  if GrpVar.Text = '' then
  begin
    MessageDlg('Select a variable for between-groups treatment groups', mtError, [mbOK], 0);
    exit;
  end;

  if RepList.Items.Count < 2 then
  begin
    MessageDlg('This test requires at least two variables for repeated measurements.', mtError, [mbOK], 0);
    exit;
  end;

  SetLength(ColNoSelected,NoVariables+1);
  NoSelected := 1;

  // Get between subjects group variable
  for j := 1 to NoVariables do
    if GrpVar.Text = OS3MainFrm.DataGrid.Cells[j,0] then ColNoSelected[0] := j;
  v1 := ColNoSelected[0]; //A treatment (group) variable

  //get minimum and maximum group codes for Treatment A
  a1 := 1000; //atoi(MainForm.Grid.Cells[v1][1].c_str());
  a2 := 0; //a1;
  for i := 1 to NoCases do
  Begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v1,i])));
    if group < a1 then a1 := group;
    if group > a2 then a2 := group;
  end;
  range := a2 - a1 + 1;
  NoSelected := RepList.Items.Count + 1;
  k := NoSelected - 1; //Number of B (within subject) treatment levels

  // allocate heap
  SetLength(C, range+1, NoSelected+1);
  SetLength(N, range+1);
  SetLength(squaredsumx, range+1);
  SetLength(coltot, NoSelected+1);
  SetLength(sumxsquared, range+1);
  SetLength(sumsum, range+1);
  SetLength(StdDev, range+1, NoSelected+1);

  // initialize arrays
  for i := 0 to range-1 do
  begin
    N[i] := 0;
    squaredsumx[i] := 0.0;
    sumxsquared[i] := 0.0;
    sumsum[i] := 0.0;
    for j := 0 to k-1 do
      C[i,j] := 0.0;
  end;

  for j := 0 to k-1 do
    coltot[j] := 0.0;
  for i :=  0 to range do
    for j := 0 to k do
      StdDev[i,j] := 0.0;
  for i := 1 to 6 do
    coeff[i] := 0.0;
  for i := 1 to 8 do
    degfree[i] := 0;
  TotStdDev := 0.0;
  TotMean := 0.0;
  totaln := 0;

  // Get items selected for repeated measures (B treatments)
  for i := 0 to RepList.Items.Count - 1 do
  begin
    for j := 1 to NoVariables do
      if RepList.Items.Strings[i] = OS3MainFrm.DataGrid.Cells[j,0] then
        ColNoSelected[i+1] := j;
  end;

  //Read data values and get sums and sums of squared values
  for i := 1 to NoCases do
  begin
    if  not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    agrp := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v1,i])));
    agrp := agrp - a1 + 1; // offset to one
    p := 0.0;

    //Now read the B treatment scores
    for j := 1 to k do
    begin
      col := ColNoSelected[j];
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
      C[agrp-1,j-1] := C[agrp-1,j-1] + X;
      StdDev[agrp-1,j-1] := StdDev[agrp-1,j-1] + (X * X);
      coeff[1]:= coeff[1] + X;
      p := p + X;
      sumxsquared[agrp-1] := sumxsquared[agrp-1] + (X * X);
      TotMean := TotMean + X;
      TotStdDev := TotStdDev + (X * X);
    end;
    N[agrp-1] := N[agrp-1] + 1;
    squaredsumx[agrp-1] := squaredsumx[agrp-1] + (p * p);
    sumsum[agrp-1] := sumsum[agrp-1] + p;
  end; // next case

  // Obtain sums of squares for std. dev.s of B treatments
  for i := 1 to k do // column (B treatments)
    for j := 1 to range do // group of A treatments
      StdDev[range,i-1] := StdDev[range,i-1] + StdDev[j-1,i-1];

  // Obtain sums of squares for std. dev.s of A treatments
  for i := 1 to range do
    for j := 1 to k do
      StdDev[i-1,k] := StdDev[i-1,k] + StdDev[i-1,j-1];

  // Obtain cell standard deviations
  for i := 1 to range do // rows
  begin
    for j := 1 to k do // columns
    begin
      StdDev[i-1,j-1] := StdDev[i-1,j-1] - ((C[i-1,j-1] * C[i-1,j-1]) / (N[i-1]));
      StdDev[i-1,j-1] := StdDev[i-1,j-1] / (N[i-1]-1);
      StdDev[i-1,j-1] := sqrt(StdDev[i-1,j-1]);
    end;
  end;

  // Obtain A treatment group standard deviations
  for i := 1 to range do
  begin
    StdDev[i-1,k] := StdDev[i-1,k] - ((sumsum[i-1] * sumsum[i-1]) / (k * N[i-1]));
    StdDev[i-1,k] := StdDev[i-1,k] / (k * N[i-1] - 1);
    StdDev[i-1,k] := sqrt(StdDev[i-1,k]);
  end;

  // Obtain coefficients for the sums of squares
  for i := 1 to range do
  begin
    coeff[2] := coeff[2] + sumxsquared[i-1];
    coeff[3] := coeff[3] + ((sumsum[i-1] * (sumsum[i-1]) / ((N[i-1] * k))));
    coeff[6] := coeff[6] + squaredsumx[i-1];
    totaln := totaln + N[i-1];
  end;
  coeff[1] := (coeff[1] * coeff[1]) / (totaln * k);
  den := k;
  coeff[6] := coeff[6] / den;
  for j := 1 to k do
  begin
    coltot[j-1] := 0.0;
    for i := 1 to range do
    begin
      coltot[j-1] := coltot[j-1] + C[i-1,j-1];
      coeff[5] := coeff[5] + ((C[i-1,j-1] * C[i-1,j-1]) / N[i-1]);
    end;
    coeff[4] := coeff[4] + (coltot[j-1] * coltot[j-1]);
  end;
  den := totaln;
  coeff[4] := coeff[4] / den;

  // Obtain B treatment group standard deviations
  for j := 1 to k do
  begin
    StdDev[range,j-1] := StdDev[range,j-1] - ((coltot[j-1] * coltot[j-1]) / totaln);
    StdDev[range,j-1] := StdDev[range,j-1] / (totaln-1);
    StdDev[range,j-1] := sqrt(StdDev[range,j-1]);
  end;

  // Calculate degrees of freedom for the mean squares
  degfree[1] := totaln - 1; // Between subjects degrees freedom
  degfree[2] := a2 - a1; // between groups degrees of freedom
  degfree[3] := totaln - (a2 - a1 + 1);// subjects within groups deg. frd.
  degfree[4] := totaln * (k - 1); // within subjects degrees of freedom
  degfree[5] := k - 1; // B treatments degrees of freedom
  degfree[6] := degfree[2] * degfree[5]; // A x B interaction degrees of frd.
  degfree[7] := degfree[3] * degfree[5]; // B x Subjects within groups d.f.
  degfree[8] := k * totaln - 1; // total degrees of freedom

  // Calculate the sums of squares
  ss[1] := coeff[6] - coeff[1];
  ss[2] := coeff[3] - coeff[1];
  ss[3] := coeff[6] - coeff[3];
  ss[4] := coeff[2] - coeff[6];
  ss[5] := coeff[4] - coeff[1];
  ss[6] := coeff[5] - coeff[3] - coeff[4] + coeff[1];
  ss[7] := coeff[2] - coeff[5] - coeff[6] + coeff[3];
  ss[8] := coeff[2] - coeff[1];

  // Calculate the mean squares
  for i := 1 to 8 do
    ms[i] := ss[i] / degfree[i];

  // Calculate the f-tests for effects A, B and interaction
  if (ms[3] > 0.0) then f1 := ms[2] / ms[3] else f1 := 1000.0;
  if (ms[7] > 0.0) then
  begin
    f2 := ms[5] / ms[7];
    f3 := ms[6] / ms[7];
  end else
  begin
    f2 := 1000.0;
    f3 := 1000.0;
  end;

  //Now, report results
  lReport := TStringList.Create;
  try
    lReport.Add('ANOVA With One Between Subjects and One Within Subjects Treatments');
    lReport.Add('');
    lReport.Add('------------------------------------------------------------------');
    lReport.Add('Source             df      SS         MS         F         Prob.');
    lReport.Add('------------------------------------------------------------------');

    fd1 := degfree[2];
    fd2 := degfree[3];
    probf1 := probf(f1, fd1, fd2);
    fd1 := degfree[5];
    fd2 := degfree[7];
    probf2 := probf(f2, fd1, fd2);
    fd1 := degfree[6];
    fd2 := degfree[7];
    probf3 := probf(f3, fd1, fd2);
    lReport.Add('Between         %5d %10.3f', [degfree[1], ss[1]]);
    lReport.Add('   Groups (A)   %5d %10.3f %10.3f %10.3f      %6.4f', [degfree[2], ss[2], ms[2], f1, probf1]);
    lReport.Add('   Subjects w.g.%5d %10.3f %10.3f', [degfree[3], ss[3], ms[3]]);
    lReport.Add('');
    lReport.Add('Within Subjects %5d %10.3f', [degfree[4], ss[4]]);
    lReport.Add('   B Treatments %5d %10.3f %10.3f %10.3f      %6.4f', [degfree[5], ss[5], ms[5], f2, probf2]);
    lReport.Add('   A X B inter. %5d %10.3f %10.3f %10.3f      %6.4f', [degfree[6], ss[6], ms[6], f3, probf3]);
    lReport.Add('   B X S w.g.   %5d %10.3f %10.3f', [degfree[7], ss[7], ms[7]]);
    lReport.Add('');
    lReport.Add('TOTAL           %5d %10.3f', [degfree[8], ss[8]]);
    lReport.Add('------------------------------------------------------------------');

    //Calculate and print means
    lReport.Add('Means');
    outline := 'TRT.   ';
    for i := 1 to k do
    begin
      value := Format('B%3d   ', [i]);
      outline := outline + value;
    end;
    outline := outline + 'TOTAL';
    lReport.Add(outline);
    lReport.Add(' A ');
    for i := 1 to range do
    begin
      for j := 1 to k do
        C[i-1,j-1] := C[i-1,j-1] / N[i-1]; //mean of each B treatment within A treatment
      sumsum[i-1] := sumsum[i-1] / (N[i-1] * k); //means in A treatment accross B treatments
    end;
    for j := 1 to k do
      coltot[j-1] := coltot[j-1] / totaln;
    TotStdDev := TotStdDev - ((TotMean * TotMean) / (k * totaln));
    TotStdDev := TotStdDev / (k * totaln - 1);
    TotStdDev := sqrt(TotStdDev);
    TotMean := TotMean / (k * totaln);
    for i := 1 to range do
    begin
      outline := Format('%3d  ', [i+a1-1]);
      for j := 1 to k do
      begin
        value := format('%7.3f', [C[i-1,j-1]]);
        outline := outline + value;
      end;
      value := Format('%7.3f', [sumsum[i-1]]);
      outline := outline + value;
      lReport.Add(outline);
    end;
    outline := 'TOTAL';
    for j := 1 to k do
    begin
      value := Format('%7.3f', [coltot[j-1]]);
      outline := outline + value;
    end;
    value := Format('%7.3f', [TotMean]);
    outline := outline + value;
    lReport.Add(outline);

    // Print standard deviations
    lReport.Add('');
    lReport.Add('Standard Deviations');
    outline := 'TRT.   ';
    for i := 1 to k do
    begin
      value := Format('B%3d   ', [i]);
      outline := outline + value;
    end;
    outline := outline + 'TOTAL';
    lReport.Add(outline);
    lReport.Add(' A ');
    for i := 1 to range do
    begin
      outline := Format('%3d  ', [i+a1-1]);
      for j := 1 to k do
      begin
        value := Format('%7.3f', [StdDev[i-1,j-1]]);
        outline := outline + value;
      end;
      value := Format('%7.3f', [StdDev[i-1,k]]);
      outline := outline + value;
      lReport.Add(outline);
    end;
    outline := 'TOTAL';
    for j := 1 to k do
    begin
      value := Format('%7.3f', [StdDev[range,j-1]]);
      outline := outline + value;
    end;
    value := Format('%7.3f', [TotStdDev]);
    outline := outline + value;
    lReport.Add(outline);

    if PosthocChk.Checked then
    begin
      // Do tests for the A (between groups)
      lReport.Add('');
      lReport.Add('===============================================================');
      lReport.Add('');
      lReport.Add('COMPARISONS FOR THE BETWEEN-GROUP MEANS');
      PostHocTests(range, MS[1], degfree[1], range, sumsum, lReport);
      lReport.Add('');

      // Do tests for the B (repeated measures)
      lReport.Add('');
      lReport.Add('===============================================================');
      lReport.Add('');
      lReport.Add('COMPARISONS FOR THE REPEATED-MEASURES MEANS');
      PostHocTests(k, ms[4], degfree[4], NoCases, coltot, lReport);
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;
  end;

  if PlotChk.Checked then // PlotMeans(C,range,k,this)
  begin
    maxmean := 0.0;
    SetLength(GraphFrm.Ypoints,range,k);
    SetLength(GraphFrm.Xpoints,1,k);
    for i := 1 to range do
    begin
      GraphFrm.SetLabels[i] := 'A ' + IntToStr(i);
      for j := 1 to k do
      begin
        GraphFrm.Ypoints[i-1,j-1] := C[i-1,j-1];
        if C[i-1,j-1] > maxmean then
          maxmean := C[i-1,j-1];
      end;
    end;

    for j := 1 to k do
    begin
      coltot[j-1] := j;
      GraphFrm.Xpoints[0,j-1] := j;
    end;

    GraphFrm.nosets := range;
    GraphFrm.nbars := k;
    GraphFrm.Heading := 'TREATMENTS X SUBJECT REPLICATIONS ANOVA';
    GraphFrm.XTitle := 'WITHIN (B) TREATMENT GROUP';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := false;
    GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := maxmean;
    GraphFrm.BackColor := clCream;
    GraphFrm.WallColor := clDkGray;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;
  end;

  // Clean up
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
  StdDev := nil;
  sumsum := nil;
  sumxsquared := nil;
  coltot := nil;
  squaredsumx := nil;
  N := nil;
  C := nil;
  ColNoSelected := nil;
end;

procedure TAxSAnovaFrm.DepOutBtnClick(Sender: TObject);
begin
  if GrpVar.Text <> '' then
  begin
    VarList.Items.Add(GrpVar.Text);
    GrpVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TAxSAnovaFrm.PostHocTests(NoSelected: Integer; MSerr: double;
  dferr: integer; Count: integer; ColMeans: DblDyneVec; AReport: TStrings);
var
  group_total: DblDyneVec;
  group_count: DblDyneVec;
  i, mingrp: integer;
begin
  SetLength(group_total,NoSelected);
  SetLength(group_count,NoSelected);
  for i := 0 to NoSelected - 1 do
  begin
    group_count[i] := double(Count);
    group_total[i] := double(Count) * ColMeans[i];
  end;

  mingrp := 1;
  Tukey(MSerr, dferr, Count, group_total, group_count, mingrp, NoSelected, AReport);
  Tukey_Kramer(MSerr, dferr, Count, group_total, group_count, mingrp, NoSelected, AReport);
  TukeyBTest(MSerr, dferr, group_total, group_count, mingrp,NoSelected, Count, AReport);
  ScheffeTest(MSerr, group_total, group_count, mingrp, NoSelected, Count*NoSelected, AReport);
  Newman_Keuls(MSerr, dferr, Count, group_total, group_count, mingrp, NoSelected, AReport);
end;

procedure TAxSAnovaFrm.Tukey(
  error_ms    : double;     { mean squared for residual }
  error_df    : double;     { deg. freedom for residual }
  value       : double;     { size of smallest group }
  group_total : DblDyneVec; { sum of scores in a group }
  group_count : DblDyneVec; { no. of cases in a group }
  min_grp     : integer;    { minimum group code }
  max_grp     : integer;    { maximum group code }
  AReport     : TStrings);
var
  sig: boolean;
  divisor: double;
  df1: integer;
  alpha: double;
  contrast, mean1, mean2: double;
  q_stat: double;
  i,j: integer;
  outline: string;
begin
  alpha := DEFAULT_ALPHA_LEVEL;
  AReport.Add('---------------------------------------------------------------');
  AReport.Add('             Tukey HSD Test for Differences Between Means');
  AReport.Add('                            alpha selected = %.2f', [alpha]);
  AReport.Add('');
  AReport.Add('Groups     Difference  Statistic      Probability  Significant?');
  AReport.Add('---------------------------------------------------------------');

  divisor := sqrt(error_ms / value);
  for i := min_grp to max_grp - 1 do
    for j := i + 1 to max_grp do
    begin
      outline := Format('%2d - %2d     ', [i,j]);
      mean1 := group_total[i-1] / group_count[i-1];
      mean2 := group_total[j-1] / group_count[j-1];
      contrast := mean1 - mean2;
      outline := outline + Format('%7.3f     q = ', [contrast]);
      contrast := abs(contrast / divisor) ;
      outline := outline + Format('%6.3f  ', [contrast]);
      df1 := max_grp - min_grp + 1;
      q_stat := STUDENT(contrast, error_df, df1);
      outline := outline + Format('       %6.4f', [q_stat]);
      if alpha >= q_stat then sig := TRUE else sig := FALSE;
      if sig = TRUE then
        outline := outline + '       YES '
      else
        outline := outline + '       NO';
      AReport.Add(outline);
    end;

  AReport.Add('---------------------------------------------------------------');
end;

procedure TAxSAnovaFrm.ScheffeTest(
  error_ms   : double;       { mean squared residual }
  group_total : DblDyneVec;  { sum of scores in a group }
  group_count : DblDyneVec;  { count of cases in a group }
  min_grp     : integer;     { code of first group }
  max_grp     : integer;     { code of last group  }
  total_n     : double;      { total number of cases }
  AReport     : TStrings);
var
  statistic, stat_var, stat_sd: double;
  mean1, mean2, alpha, difference, prob_scheffe, f_prob, df1, df2: double;
  outline: string;
  i, j: integer;
begin
  alpha := DEFAULT_ALPHA_LEVEL;
  AReport.Add('');
  AReport.Add('----------------------------------------------------------------');
  AReport.Add('                 Scheffe contrasts among pairs of means.');
  AReport.Add('                            alpha selected = %.2f', [alpha]);
  AReport.Add('');
  AReport.Add('Group vs Group  Difference   Scheffe    Critical  Significant?');
  AReport.Add('                             Statistic  Value');
  AReport.Add('----------------------------------------------------------------');

  alpha := 1.0 - alpha ;
  for i:= min_grp to max_grp - 1 do
    for j := i + 1 to max_grp do
    begin
      outline := Format('%2d        %2d      ', [i,j]);
      mean1 := group_total[i-1] / group_count[i-1];
      mean2 := group_total[j-1] / group_count[j-1];
      difference := mean1 - mean2;
      outline := outline + Format('%8.2f ', [difference]);
      stat_var := error_ms * ( 1.0 / group_count[i-1] + 1.0 / group_count[j-1]);
      stat_sd := sqrt(stat_var);
      statistic := abs(difference / stat_sd);
      outline := outline + Format('%8.2f   ', [statistic]);
      df1 := max_grp - min_grp;
      df2 := total_n - df1 + 1;
      f_prob := fpercentpoint(alpha, round(df1), round(df2) );
      prob_scheffe := sqrt(df1 * f_prob);
      outline := outline + Format('%8.3f     ', [prob_scheffe]);
      if statistic > prob_scheffe then
        outline := outline + 'YES'
      else
        outline := outline + 'NO';
      AReport.Add(outline);
    end;

  AReport.Add('----------------------------------------------------------------');
end;

procedure TAxSAnovaFrm.Newman_Keuls(
  error_ms    : double;      { residual mean squared }
  error_df    : double;      { deg. freedom for error }
  value       : double;      { number in smallest group }
  group_total : DblDyneVec;  { sum of scores in a group }
  group_count : DblDyneVec;  { count of cases in a group }
  min_grp     : integer;     { lowest group code }
  max_grp     : integer;     { largest group code }
  AReport     : TStrings);
var
  i, j: integer;
  temp1, temp2: double;
  groupno: IntDyneVec;
  alpha: double;
  contrast, mean1, mean2: double;
  q_stat: double;
  divisor: double;
  tempno: integer;
  df1: integer;
  sig: boolean;
  outline: string;
begin
  SetLength(groupno, max_grp - min_grp + 1);

  for i := min_grp to max_grp do
    groupno[i-1] := i;

  for i := min_grp to max_grp - 1 do
  begin
    for j := i + 1 to max_grp do
    begin
      if group_total[i-1] / group_count[i-1] > group_total[j-1] / group_count[j-1] then
      begin
        temp1 := group_total[i-1];
        temp2 := group_count[i-1];
        tempno := groupno[i-1];
        group_total[i-1] := group_total[j-1];
        group_count[i-1] := group_count[j-1];
        groupno[i-1] := groupno[j-1];
        group_total[j-1] := temp1;
        group_count[j-1] := temp2;
        groupno[j-1] := tempno;
      end;
    end;
  end;

  alpha := DEFAULT_ALPHA_LEVEL;
  AReport.Add('');
  AReport.Add('----------------------------------------------------------------------');
  AReport.Add('            Neuman-Keuls Test for Contrasts on Ordered Means');
  AReport.Add('                            alpha selected = %.2f', [alpha]);
  AReport.Add('');
  AReport.Add('Group     Mean');
  for i := 1 to max_grp do
    AReport.Add('%3d  %10.3f', [groupno[i-1], group_total[i-1] / group_count[i-1]]);
  AReport.Add('');
  AReport.Add('Groups     Difference  Statistic      d.f.   Probability  Significant?');
  AReport.Add('----------------------------------------------------------------------');

  divisor := sqrt(error_ms / value);
  for i := min_grp to max_grp - 1 do
  begin
    for j := i + 1 to max_grp do
    begin
      outline := Format('%2d - %2d     ', [groupno[i-1], groupno[j-1]]);
      mean1 := group_total[i-1] / group_count[i-1];
      mean2 := group_total[j-1] / group_count[j-1];
      contrast := mean1 - mean2;
      outline := outline + Format('%7.3f      q = ', [contrast]);
      contrast := abs(contrast / divisor );
      df1 := j - i + 1;
      outline := outline + Format('%6.3f   %2d  %3.0f  ', [contrast, df1, error_df]);
      q_stat := STUDENT(contrast, error_df, df1);
      outline := outline + Format('   %6.4f', [q_stat]);
      sig := alpha > q_stat;
      if sig then
        outline := outline + '       YES'
      else
        outline := outline + '       NO';
      AReport.Add(outline);
    end;
  end;

  AReport.Add('----------------------------------------------------------------------');
  groupno := nil;
end;

procedure TAxSAnovaFrm.Tukey_Kramer(
  error_ms    : double;     { residual mean squared }
  error_df    : double;     { deg. freedom for error }
  value       : double;     { number in smallest group }
  group_total : DblDyneVec; { sum of scores in group }
  group_count : DblDyneVec; { number of caes in group }
  min_grp     : integer;    { code of lowest group }
  max_grp     : integer;    { code of highst group }
  AReport     : TStrings);
var
  sig: boolean;
  divisor: double;
  df1: integer;
  alpha: double;
  contrast, mean1, mean2: double;
  q_stat: double;
  outline: string;
  i, j: integer;
begin
  alpha := DEFAULT_ALPHA_LEVEL;
  AReport.Add('');
  AReport.Add('---------------------------------------------------------------');
  AReport.Add('           Tukey-Kramer Test for Differences Between Means');
  AReport.Add('                     alpha selected = %.2f', [alpha]);
  AReport.Add('');
  AReport.Add('Groups     Difference  Statistic      Probability  Significant?');
  AReport.Add('---------------------------------------------------------------');

  for i := min_grp to max_grp - 1 do
    for j := i + 1 to max_grp do
    begin
      outline := Format('%2d - %2d    ', [i, j]);
      mean1 := group_total[i-1] / group_count[i-1];
      mean2 := group_total[j-1] / group_count[j-1];
      contrast := mean1 - mean2;
      outline := outline + Format('%7.3f     q = ', [contrast]);
      divisor := sqrt(error_ms * ((1.0/group_count[i-1] + 1.0/group_count[j-1]) / 2));
      contrast := abs(contrast / divisor) ;
      outline := outline + Format('%6.3f  ', [Contrast]);
      df1 := max_grp - min_grp + 1;
      q_stat := STUDENT(contrast, error_df, df1);
      outline := outline + Format('       %6.4f', [q_stat]);
      sig := alpha >= q_stat;
      if sig then
        outline := outline + '       YES '
      else
        outline := outline + '       NO';
      AReport.Add(outline);
    end;

  AReport.Add('---------------------------------------------------------------');
end;

procedure TAxSAnovaFrm.TukeyBTest(
  ErrorMS : double;         // within groups error
  ErrorDF : double;         // degrees of freedom within
  group_total : DblDyneVec; // vector of group sums
  group_count : DblDyneVec; // vector of group n's
  min_grp     : integer;    // smallest group code
  max_grp     : integer;    // largest group code
  groupsize   : double;     // size of groups (all equal)
  AReport     : TStrings);
var
  alpha : double;
  outline: string;
  i, j: integer;
  df1: double;
  qstat: double;
  tstat: double;
  groupno: IntDyneVec;
  temp1, temp2: double;
  tempno: integer;
  NoGrps: integer;
  contrast: double;
  mean1, mean2: double;
  sig: string[6];
  groups: double;
  divisor: double;
begin
  SetLength(groupno,max_grp-min_grp+1);
  alpha := DEFAULT_ALPHA_LEVEL;

  AReport.Add('');
  AReport.Add('---------------------------------------------------------------');
  AReport.Add('           Tukey B Test for Contrasts on Ordered Means');
  AReport.Add('                          alpha selected = %.2f', [alpha]);
  AReport.Add('---------------------------------------------------------------');
  AReport.Add('');
  AReport.Add('Groups    Difference  Statistic   d.f.     Prob.>value  Significant?');

  divisor := sqrt(ErrorMS / groupsize);
  NoGrps := max_grp - min_grp + 1;
  for i := min_grp to max_grp do
    groupno[i-1] := i;
  for i := 1 to NoGrps - 1 do
  begin
    for j := i + 1 to NoGrps do
    begin
      if group_total[i-1] / group_count[i-1] > group_total[j-1] / group_count[j-1] then
      begin
        temp1 := group_total[i-1];
        temp2 := group_count[i-1];
        tempno := groupno[i-1];
        group_total[i-1] := group_total[j-1];
        group_count[i-1] := group_count[j-1];
        groupno[i-1] := groupno[j-1];
        group_total[j-1] := temp1;
        group_count[j-1] := temp2;
        groupno[j-1] := tempno;
      end;
    end;
  end;

  for i := 1 to NoGrps-1 do
  begin
    for j := i+1 to NoGrps do
    begin
      mean1 := group_total[i-1] / group_count[i-1];
      mean2 := group_total[j-1] / group_count[j-1];
      contrast := abs((mean1 - mean2) / divisor);
      df1 := j - i + 1.0;
      qstat := STUDENT(contrast, ErrorDF, df1);
      groups := NoGrps;
      tstat := STUDENT(contrast, ErrorDF, groups);
      qstat := (qstat + tstat) / 2.0;
      if alpha >= qstat then
        sig := 'YES'
      else
        sig := 'NO';
      outline := Format('%3d - %3d %10.3f  %10.3f  %4.0f,%4.0f  %5.3f       %s', [
        groupno[i-1], groupno[j-1],
        mean1-mean2, contrast, df1, ErrorDF, qstat, sig
      ]);
      AReport.Add(outline);
    end;
  end;
  groupno := nil;
end;

procedure TAxSAnovaFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  DepInBtn.Enabled := (VarList.ItemIndex > -1) and (GrpVar.Text = '');
  DepOutBtn.Enabled := (GrpVar.Text <> '');

  lSelected := false;
  for i := 0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  RepInBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to RepList.Items.Count-1 do
    if RepList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  RepOutBtn.Enabled := lSelected;
end;

procedure TAxSAnovaFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I axsanovaunit.lrs}

end.

