// Use file "itemdata2.laz" for testing

unit WithinANOVAUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Math,
  MainUnit, FunctionsLib, OutputUnit, MatrixLib, Globals, DataProcs,
  GraphLib, ContextHelpUnit;

type

  { TWithinANOVAFrm }

  TWithinANOVAFrm = class(TForm)
    AssumpChk: TCheckBox;
    Bevel1: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    PlotChk: TCheckBox;
    RelChk: TCheckBox;
    GroupBox1: TGroupBox;
    InBtn: TBitBtn;
    Label2: TLabel;
    SelList: TListBox;
    OutBtn: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  WithinANOVAFrm: TWithinANOVAFrm;

implementation

{ TWithinANOVAFrm }

procedure TWithinANOVAFrm.ResetBtnClick(Sender: TObject);
VAR
  i: integer;
begin
  VarList.Clear;
  SelList.Clear;
  PlotChk.Checked := false;
  RelChk.Checked := false;
  AssumpChk.Checked := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TWithinANOVAFrm.FormActivate(Sender: TObject);
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

procedure TWithinANOVAFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TWithinANOVAFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TWithinANOVAFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TWithinANOVAFrm.ComputeBtnClick(Sender: TObject);
var
  i, j, k, f3: integer;
  LabelStr: string;
  NoSelected, count, row: integer;
  SSrows, SScols, SSwrows, SSerr, SStot: double;
  MSrows, MScols, MSwrows, MSerr, MStot: double;
  dfrows, dfcols, dfwrows, dferr, dftot: double;
  f1, probf1, GrandMean, Term1, Term2, Term3, Term4: double;
  r1, r2, r3, r4, X, avgvar, avgcov: double;
  determ1, determ2, M2, C2, chi2, prob: double;
  errorfound: boolean;
  Selected: IntDyneVec;
  ColLabels: StrDyneVec;
  ColMeans, ColVar, RowMeans, RowVar, ColStdDev: DblDyneVec;
  varcovmat, vcmat, workmat: DblDyneMat;
  title: string;
  lReport: TStrings;
begin
  if SelList.Items.Count = 0 then
  begin
     MessageDlg('No variables selected.', mtError, [mbOK], 0);
     exit;
  end;
  if SelList.Items.Count = 1 then
  begin
     MessageDlg('At least two variables must be selected.', mtError, [mbOK], 0);
     exit;
  end;

  errorfound := false;
  NoSelected := SelList.Items.Count;
  Caption := IntToStr(NoSelected);

  SetLength(Selected,NoSelected);
  SetLength(ColLabels,NoSelected);
  SetLength(ColMeans,NoSelected);
  SetLength(ColVar,NoSelected);
  SetLength(RowMeans,NoCases);
  SetLength(RowVar,NoCases);

  for i := 0 to NoSelected - 1 do
  begin
    LabelStr := SelList.Items[i];
    for j := 1 to NoVariables do
      if LabelStr = OS3MainFrm.DataGrid.Cells[j, 0] then
      begin
         Selected[i] := j;
         ColLabels[i] := labelStr;
         break;
      end;
  end;

  // Initialize values
  SScols := 0.0;
  SSrows := 0.0;
  SStot := 0.0;
  dfwrows := 0.0;
  dftot := 0.0;
  GrandMean := 0.0;
  count := 0;

  for i := 0 to NoSelected-1 do
  begin
    ColMeans[i] := 0.0;
    ColVar[i] := 0.0;
  end;
  for j := 0 to NoCases-1 do
  begin
    RowMeans[j] := 0.0;
    RowVar[j] := 0.0;
  end;

  // Read data and compute sums while reading
  row := 0;
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,Selected) then continue;
    count := count + 1;
    for j := 1 to NoSelected do
    begin
      k := Selected[j-1];
      X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i]));
      RowMeans[row] := RowMeans[row] + X;
      RowVar[row] := RowVar[row] + (X * X);
      ColMeans[j-1] := ColMeans[j-1] + X;
      ColVar[j-1] := ColVar[j-1] + (X * X);
      GrandMean := GrandMean + X;
      SStot := SStot + (X * X);
    end;
    row := row + 1;
  end;

  // Calculate ANOVA results
  Term1 := (GrandMean * GrandMean) / (count * NoSelected);
  Term2 := SStot;
  for i := 1 to count do SSrows := SSrows + (RowMeans[i-1] * RowMeans[i-1]);
  Term4 := SSrows / NoSelected;
  for i := 1 to NoSelected do SScols := SScols + (ColMeans[i-1] * ColMeans[i-1]);
  Term3 := SScols / count;
  SSrows := Term4 - Term1;
  SScols := Term3 - Term1;
  SSwrows := Term2 - Term4;
  SSerr := Term2 - Term3 - Term4 + Term1;
  SStot := Term2 - Term1;
  dfrows := count - 1;
  dfcols := NoSelected - 1;
  dfwrows := count * (NoSelected - 1);
  dferr := (count - 1) * (NoSelected - 1);
  dftot := (count * NoSelected) - 1;
  MSrows := SSrows / dfrows;
  MScols := SScols / dfcols;
  MSwrows := SSwrows / dfwrows;
  MSerr := SSerr / dferr;
  MStot := SStot / dftot; // variance of all scores
  GrandMean := GrandMean / (count * NoSelected);
  for i := 0 to count-1 do
  begin
    RowVar[i] := RowVar[i] - (RowMeans[i] * RowMeans[i] / NoSelected);
    RowVar[i] := RowVar[i] / (NoSelected - 1);
    RowMeans[i] := RowMeans[i] / NoSelected;
  end;
  for i := 0 to NoSelected-1 do
  begin
    ColVar[i] := ColVar[i] - (ColMeans[i] * ColMeans[i] / count);
    ColVar[i] := ColVar[i] / (count - 1);
    ColMeans[i] := ColMeans[i] / count;
  end;
  f1 := MScols / MSerr; // treatment F statistic
  probf1 := probf(f1,dfcols,dferr);

  // Do reliability terms if requested
  if RelChk.Checked then
  begin
    r1 := 1.0 - (MSwrows / MSrows); // unadjusted reliability of test
    r2 := (MSrows - MSwrows) / (MSrows + (NoSelected - 1) * MSwrows);
    // r2 is unadjusted reliability of a single item
    r3 := (MSrows - MSerr) / MSrows; // Cronbach alpha for test
    r4 := (MSrows - MSerr) / (MSrows + (NoSelected - 1) * MSerr);
    // r4 is adjusted reliability of a single item
  end;

  // do homogeneity of variance and covariance checks if requested

  lReport := TStringList.Create;
  try
    // print results
    lReport.Add('Treatments by Subjects (AxS) ANOVA Results.');
    lReport.Add('');
    lReport.Add('Data File = ' + OS3MainFrm.FileNameEdit.Text);
    lReport.Add('');
    lReport.Add('');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('SOURCE           DF        SS        MS        F  Prob. > F');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('SUBJECTS       %4.0f%10.3f%10.3f', [dfrows, SSrows, MSrows]);
    lReport.Add('WITHIN SUBJECTS%4.0f%10.3f%10.3f', [dfwrows, SSwrows, MSwrows]);
    lReport.Add('   TREATMENTS  %4.0f%10.3f%10.3f%10.3f%10.3f', [dfcols, SScols, MScols, f1, probf1]);
    lReport.Add('   RESIDUAL    %4.0f%10.3f%10.3f', [dferr, SSerr, MSerr]);
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('TOTAL          %4.0f%10.3f%10.3f', [dftot, SStot, MStot]);
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('');
    lReport.Add('');
    lReport.Add('TREATMENT (COLUMN) MEANS AND STANDARD DEVIATIONS');
    lReport.Add('VARIABLE  MEAN      STD.DEV.');
    for i := 1 to NoSelected do
      lReport.Add('%-8s%10.3f%10.3f', [ColLabels[i-1], ColMeans[i-1], sqrt(ColVar[i-1])]);
    lReport.Add('');
    lReport.Add('Mean of all scores = %.3f with standard deviation = %.3f', [GrandMean, sqrt(MStot)]);
    lReport.Add('');
    lReport.Add('');

    // Do reliability estimates if requested
    if RelChk.Checked then
    begin
      lReport.Add('RELIABILITY ESTIMATES');
      lReport.Add('');
      lReport.Add('TYPE OF ESTIMATE              VALUE');
      lReport.Add('Unadjusted total reliability %7.3f', [r1]);
      lReport.Add('Unadjusted item reliability  %7.3f', [r2]);
      lReport.Add('Adjusted total (Cronbach)    %7.3f', [r3]);
      lReport.Add('Adjusted item reliability    %7.3f', [r4]);
      lReport.Add('');
      lReport.Add('');
    end;

    // Test assumptions of variance - covariance homogeneity if requested
    if AssumpChk.Checked then
    begin
      SetLength(varcovmat,NoSelected+1,NoSelected+1);
      SetLength(vcmat,NoSelected+1,NoSelected+1);
      SetLength(workmat,NoSelected+1,NoSelected+1);
      SetLength(ColStdDev,NoSelected);
      errorfound := false;
      count := NoCases;
      lReport.Add('BOX TEST FOR HOMOGENEITY OF VARIANCE-COVARIANCE MATRIX');
      lReport.Add('');
      GridCovar(NoSelected, Selected, varcovmat, ColMeans, ColVar, ColStdDev, errorfound, count);
      title := 'SAMPLE COVARIANCE MATRIX';
      MatPrint(varcovmat, NoSelected, NoSelected, title, ColLabels, ColLabels, NoCases, lReport);
      if errorfound then
        MessageDlg('Zero variance found for a variable.', mtError, [mbOK], 0);

      // get average of variances into workmat diagonal and average of
      // covariances into workmat off-diagonals (See Winer, pg 371)
      avgvar := 0.0;
      avgcov := 0.0;
      for i := 0 to NoSelected-1 do
        vcmat[i,i] := varcovmat[i,i];
      for i := 0 to NoSelected-2 do
      begin
        for j := i+1 to NoSelected-1 do
        begin
          vcmat[i,j] := varcovmat[i,j];
          vcmat[j,i] := vcmat[i,j];
        end;
      end;

      for i := 0 to NoSelected-1 do
        avgvar := avgvar + varcovmat[i,i];
      for i := 0 to NoSelected-2 do
        for j := i+1 to NoSelected-1 do
          avgcov := avgcov + varcovmat[i,j];
      avgvar := avgvar / NoSelected;
      avgcov := avgcov / (NoSelected * NoSelected - 1) / 2.0;
      for i := 0 to NoSelected-1 do
        workmat[i,i] := avgvar;
      for i := 0 to NoSelected-2 do
      begin
        for j := i+1 to NoSelected-1 do
        begin
          workmat[i,j] := avgcov;
          workmat[j,i] := workmat[i,j];
        end;
      end;

      // get determinants of varcov and workmat
      determ1 := 0.0;
      determ2 := 0.0;
      M2 := 0.0;
      C2 := 0.0;
      chi2 := 0.0;
      prob := 0.0;
      Determ(vcmat,NoSelected,NoSelected,determ1,errorfound);
      if determ1 < 0.0 then determ1 := 0.0;
      Determ(workmat,NoSelected,NoSelected,determ2,errorfound);
      if determ2 < 0.0 then determ2 := 0.0;
      count := NoCases;
      GridCovar(NoSelected,Selected,varcovmat,ColMeans,ColVar,ColStdDev,errorfound,count);
      errorfound := false;
      if ((determ1 > 0.0) and (determ2 > 0.0)) then
        M2 := -(NoCases*NoSelected - 1) * ln(determ1 / determ2)
      else
      begin
        M2 := 0.0;
        errorfound := true;
        MessageDlg('A determinant <= zero was found.', mtError, [mbOK], 0);
      end;
      if not errorfound then
      begin
        C2 := NoSelected * (NoSelected+1) * (NoSelected + 1) * (2 * NoSelected - 3);
        C2  := C2 / (6 * (count - 1)*(NoSelected - 1) * (NoSelected * NoSelected + NoSelected - 4));
        chi2 := (1.0 - C2) * M2;
        f3 := (NoSelected * NoSelected + NoSelected - 4) div 2;
        if ((chi2 > 0.01) and (chi2 < 1000.0)) then
          prob := chisquaredprob(chi2,f3)
        else
        begin
          if chi2 <= 0.0 then prob := 1.0;
          if chi2 >= 1000.0 then prob := 0.0;
        end;
      end;
      title := 'ASSUMED POP. COVARIANCE MATRIX';
      for i := 0 to NoSelected-1 do
        for j := 0 to NoSelected-1 do
          varcovmat[i,j] := workmat[i,j];
      MatPrint(varcovmat, NoSelected, NoSelected, title, ColLabels, ColLabels, NoCases, lReport);
      lReport.Add('Determinant of variance-covariance matrix = %10.3g', [determ1]);
      lReport.Add('Determinant of homogeneity matrix = %10.3g', [determ2]);
      if not errorfound then
      begin
        lReport.Add('ChiSquare = %10.3f with %3d degrees of freedom', [chi2,f3]);
        lReport.Add('Probability of larger chisquare = %6.3g', [1.0-prob]);
      end;
    end;

    DisplayReport(lReport);

  finally
     lReport.Free;
     ColStdDev := nil;
     workmat := nil;
     vcmat := nil;
     varcovmat := nil;
  end;

  { Now, plot values if indicated in options list }
  if PlotChk.Checked then
  begin
    SetLength(GraphFrm.Xpoints,1,NoSelected);
    SetLength(GraphFrm.Ypoints,1,NoSelected);

    // use rowvar to hold variable no.
    for i := 1 to NoSelected do
    begin
      rowvar[i-1] := Selected[i-1];
      GraphFrm.Xpoints[0,i-1] := Selected[i-1];
      GraphFrm.Ypoints[0,i-1] := ColMeans[i-1];
    end;
    GraphFrm.nosets := 1;
    GraphFrm.nbars := NoSelected;
    GraphFrm.Heading := 'WITHIN SUBJECTS ANOVA';
    GraphFrm.XTitle := 'Repeated Measure Var. No.';
    GraphFrm.YTitle := 'Mean';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScaled := true;
    GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
    GraphFrm.BackColor := clYellow;
    GraphFrm.WallColor := clBlack;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;
  end;

  // Clean-up
  RowVar := nil;
  RowMeans := nil;
  ColVar := nil;
  ColMeans := nil;
  ColLabels := nil;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
  Selected := nil;
end;

procedure TWithinANOVAFrm.InBtnClick(Sender: TObject);
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
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TWithinANOVAFrm.OutBtnClick(Sender: TObject);
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
    end else
      inc(i);
  end;
  VarList.ItemIndex := -1;
  SelList.ItemIndex := -1;
  UpdateBtnStates;
end;

procedure TWithinANOVAFrm.UpdateBtnStates;
var
  i: Integer;
  lEnabled: Boolean;
begin
  lEnabled := false;
  for i:=0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lEnabled := true;
      break;
    end;
  InBtn.Enabled := lEnabled;

  lEnabled := false;
  for i:=0 to SelList.Items.Count-1 do
    if SelList.Selected[i] then
    begin
      lEnabled := true;
      break;
    end;
  OutBtn.Enabled := lEnabled;
end;

procedure TWithinANOVAFrm.VarListSelectionChange(Sender: TObject;
  User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I withinanovaunit.lrs}

end.

