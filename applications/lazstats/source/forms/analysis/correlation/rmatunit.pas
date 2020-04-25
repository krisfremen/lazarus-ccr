unit RMatUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, MatrixLib, OutputUnit, DataProcs, FunctionsLib,
  ContextHelpUnit;

type

  { TRMatFrm }

  TRMatFrm = class(TForm)
    Bevel1: TBevel;
    GridMatChk: TCheckBox;
    HelpBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    AugmentChk: TCheckBox;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    CPChkBox: TCheckBox;
    CovChkBox: TCheckBox;
    CorrsChkBox: TCheckBox;
    MeansChkBox: TCheckBox;
    VarChkBox: TCheckBox;
    SDChkBox: TCheckBox;
    PairsChkBox: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    SelList: TListBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure PairsCalc(NoVars: integer; const ColNoSelected: IntDyneVec;
      const Matrix: DblDyneMat; const ColLabels: StrDyneVec; AReport: TStrings);
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  RMatFrm: TRMatFrm;

implementation

uses
  Math, Utils;

{ TRMatFrm }

procedure TRMatFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     SelList.Clear;
     for i := 1 to NoVariables do
     begin
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     end;
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
     AugmentChk.Checked := false;
     PairsChkBox.Checked := false;
     CPChkBox.Checked := false;
     CovChkBox.Checked := false;
     CorrsChkBox.Checked := true;
     MeansChkBox.Checked := true;
     VarChkBox.Checked := false;
     SDChkBox.Checked := true;
end;

procedure TRMatFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TRMatFrm.FormActivate(Sender: TObject);
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

procedure TRMatFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TRMatFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TRMatFrm.AllBtnClick(Sender: TObject);
var
  index: Integer;
begin
  for index := 0 to VarList.Items.Count-1 do
    SelList.Items.Add(VarList.Items[index]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TRMatFrm.ComputeBtnClick(Sender: TObject);
var
  i, j : integer;
  cellstring : string;
  NoVars : integer;
  ColNoSelected : IntDyneVec;
  Matrix : DblDyneMat;
  TestMat : DblDyneMat;
  Means : DblDyneVec;
  Variances : DblDyneVec;
  StdDevs : DblDyneVec;
  RowLabels, ColLabels : StrDyneVec;
  Augment : boolean;
  title : string;
  errorcode : boolean;
  Ngood : integer;
  t, Probr, N: double;
  lReport: TStrings;
begin
  errorcode := false;
  NoVars := SelList.Items.Count;
  Augment := false;
  Ngood := 0;

  if NoVars = 0 then
  begin
    MessageDlg('No variable(s) selected.', mtError, [mbOK], 0);
    exit;
  end;

  SetLength(ColNoSelected,NoVars+1);
  SetLength(Matrix,NoVars+1,NoVars+1); // 1 more for possible augmentation
  SetLength(TestMat,NoVars,NoVars);
  SetLength(Means,NoVars+1);
  SetLength(Variances,NoVars+1);
  SetLength(StdDevs,NoVars+1);
  SetLength(RowLabels,NoVars+1);
  SetLength(ColLabels,NoVars+1);

  // identify the included variable locations and their labels
  for i := 1 to NoVars do
  begin
    cellstring := SelList.Items.Strings[i-1];
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

  lReport := TStringList.Create;
  try
    if PairsChkBox.Checked then
    begin
      PairsCalc(NoVars, ColNoSelected, Matrix, ColLabels, lReport);
      exit;
    end;

    if AugmentChk.Checked then
    begin
      Augment := true;
      ColLabels[NoVars] := 'Intercept';
      RowLabels[NoVars] := 'Intercept';
    end;

    // get cross-products if elected
    if CPChkBox.Checked then
    begin
      GridXProd(NoVars, ColNoSelected, Matrix, Augment, Ngood);
      title := 'Cross-Products Matrix';
      if not Augment then
        MatPrint(Matrix, NoVars, NoVars, title, RowLabels, ColLabels, Ngood, lReport)
      else
        MatPrint(Matrix, NoVars+1, NoVars+1, title, RowLabels, ColLabels, Ngood, lReport);
    end;

    // get variance-covariance mat. if elected
    if CovChkBox.Checked then
    begin
      title := 'Variance-Covariance Matrix';
      GridCovar(NoVars, ColNoSelected, Matrix, Means, Variances, StdDevs, errorcode, Ngood);
      MatPrint(Matrix, NoVars, NoVars, title, RowLabels, ColLabels, Ngood, lReport);
    end;

    // get correlations
    if CorrsChkBox.Checked then
    begin
      title := 'Product-Moment Correlations Matrix';
      Correlations(NoVars, ColNoSelected, Matrix, Means, Variances, StdDevs, errorcode, Ngood);
      MatPrint(Matrix, NoVars, NoVars, title, RowLabels, ColLabels, Ngood, lReport);
      N := Ngood;
      for i := 1 to NoVars do
      begin
        for j := i+1 to NoVars do
        begin
          t := Matrix[i-1][j-1] * (sqrt((N-2.0) / (1.0 - (Matrix[i-1][j-1] * Matrix[i-1][j-1]))));
          TestMat[i-1,j-1] := t;
          Probr := probt(t,N - 2.0);
          TestMat[j-1,i-1] := Probr;
          TestMat[i-1,i-1] := 0.0;
        end;
      end;
      title := 't-test values (upper) and probabilities of t (lower)';
      MatPrint(TestMat, NoVars, NoVars, title, RowLabels, ColLabels, Ngood, lReport);
    end;

    if MeansChkBox.Checked then
    begin
      title := 'Means';
      DynVectorPrint(Means, NoVars, title, ColLabels, Ngood, lReport);
    end;

    if VarChkBox.Checked then
    begin
      title := 'Variances';
      DynVectorPrint(Variances, NoVars, title, ColLabels, Ngood, lReport);
    end;

    if SDChkBox.Checked then
    begin
      title := 'Standard Deviations';
      DynVectorPrint(StdDevs, NoVars, title, ColLabels, Ngood, lReport);
    end;

    if errorcode then
      lReport.Add('One or more correlations could not be computed due to zero variance of a variable.');

    if GridMatChk.Checked then
      MatToGrid(Matrix,NoVars);

    DisplayReport(lReport);

  finally
    lReport.Free;
    ColLabels := nil;
    RowLabels := nil;
    StdDevs := nil;
    Variances := nil;
    Means := nil;
    Matrix := nil;
    ColNoSelected := nil;
  end;
end;

procedure TRMatFrm.InBtnClick(Sender: TObject);
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
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TRMatFrm.OutBtnClick(Sender: TObject);
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
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TRMatFrm.PairsCalc(NoVars: integer; const ColNoSelected: IntDyneVec;
  const Matrix: DblDyneMat; const ColLabels: StrDyneVec; AReport: TStrings);
var
  i, j, k, XCol, YCol, Npairs, N: integer;
  X, Y, XMean, XVar, XSD, YMean, YVar, YSD, pmcorr, z, rprob: double;
  strout: string;
  NMatrix: IntDyneMat;
  tMatrix: DblDyneMat;
  ProbMat: DblDyneMat;
  startpos, endpos: integer;
begin
  SetLength(NMatrix,NoVars,NoVars);
  SetLength(tMatrix,NoVars,NoVars);
  SetLength(ProbMat,NoVars,NoVars);

  for i := 1 to NoVars - 1 do
  begin
    for j := i + 1 to NoVars do
    begin
      XMean := 0.0;
      XVar := 0.0;
      XCol := ColNoSelected[i-1];
      YMean := 0.0;
      YVar := 0.0;
      YCol := ColNoSelected[j-1];
      pmcorr := 0.0;
      Npairs := 0;
      AReport.Add(ColLabels[i-1] + ' vs ' + ColLabels[j-1]);

      for k := 1 to NoCases do
      begin
        if not ValidValue(k,XCol) then continue;
        if not ValidValue(k,YCol) then continue;
        X := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol,k]);
        Y := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,k]);
        pmcorr := pmcorr + (X * Y);
        XMean := XMean + X;
        YMean := YMean + Y;
        XVar := XVar + (X * X);
        YVar := YVar + (Y * Y);
        Npairs := NPairs + 1;
      end;

      if CPChkBox.Checked then
        AReport.Add('CrossProducts[%d,%d]: %6.4f,  N cases: %d', [i, j, pmcorr, Npairs]);

      pmcorr := pmcorr - (XMean * YMean) / Npairs;
      pmcorr := pmcorr / (Npairs - 1);
      if CovChkBox.Checked then
        AReport.Add('Covariance[%d,%d]:    %6.4f,  N cases: %d', [i, j, pmcorr, Npairs]);

      XVar := XVar - (XMean * XMean) / Npairs;
      XVar := XVar / (Npairs - 1);
      XSD := sqrt(XVar);
      YVar := YVar - (YMean * YMean) / Npairs;
      YVar := YVar / (Npairs - 1);
      YSD := sqrt(YVar);
      XMean := XMean / Npairs;
      YMean := YMean / Npairs;
      pmcorr := pmcorr / (XSD * YSD);
      Matrix[i-1,j-1] := pmcorr;
      Matrix[j-1,i-1] := pmcorr;
      NMatrix[i-1,j-1] := Npairs;
      NMatrix[j-1,i-1] := NPairs;
      if CorrsChkBox.Checked then
      begin
        N := Npairs - 2;
        z := abs(pmcorr) * (sqrt((N-2)/(1.0 - (pmcorr * pmcorr))));
        rprob := probt(z,N);
//                  Using Fisher's z transform below gives SPSS results
//                    N := Npairs - 3;
//                    z := 0.5 * ln( (1.0 + pmcorr)/(1.0 - pmcorr) );
//                    z := z / sqrt(1.0/N);
//                    rprob := probz(z);
        AReport.Add('r[%d, %d]: %6.4f,  N cases: %d', [i, j, pmcorr, Npairs]);
        AReport.Add('t value with d.f. %d: %8.4f with Probability > t %6.4f', [Npairs - 2, z, rprob]);
        tMatrix[i-1,j-1] := z;
        tMatrix[j-1,i-1] := z;
        ProbMat[i-1,j-1] := rprob;
        ProbMat[j-1,i-1] := rprob;
      end;

      if MeansChkBox.Checked or VarChkBox.Checked or SDChkBox.Checked then
      begin
        AReport.Add('Mean X: %8.4f,  Variance X: %8.4f,  Std.Dev. X: %8.4f', [XMean, XVar, XSD]);
        AReport.Add('Mean Y: %8.4f,  Variance Y: %8.4f,  Std.Dev. Y: %8.4f', [YMean, YVar, YSD]);
      end;
      AReport.Add('');
    end; // next j variable
    Matrix[i-1,i-1] := 1.0;
  end; // next i variable

  Matrix[NoVars-1,NoVars-1] := 1.0;

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  AReport.Add('Intercorrelation Matrix and Statistics');
  AReport.Add('');

//     strout := 'Correlation Matrix Summary (Ns in lower triangle)';
//     MAT_PRINT(Matrix,NoVars,NoVars,strout,ColLabels,ColLabels,NoCases);
  startpos := 1;
  endpos := 6;
  if endpos > NoVars then endpos := NoVars;

  for i := 1 to NoVars do
  begin
    strout := '          ';
    for j := startpos to endpos do
      strout := strout + Format('     %5d', [j]);
    AReport.Add(strout);

    strout := format('%2d PMCorr.',[i]);
    for j := startpos to endpos do
      strout := strout + Format('   %7.4f', [Matrix[i-1,j-1]]);
    AReport.Add(strout);

    strout := Format('%2d N Size ', [i]);
    for j := startpos to endpos do
    begin
      if j <> i then
        strout := strout + Format('   %3d    ', [NMatrix[i-1,j-1]])
      else begin
        Npairs := 0;
        for k := 1 to NoCases do
        begin
          if ValidValue(k,ColNoSelected[j-1]) then
            Npairs := Npairs + 1;
        end;
        strout := strout + Format('   %3d    ', [Npairs]);
      end;
    end;

    AReport.Add(strout);

    strout := Format('%2d t Value', [i]);
    for j := startpos to endpos do
      if j <> i then
        strout := strout + Format('   %7.4f', [tMatrix[i-1, j-1]])
      else
        strout := strout + '          ';
    AReport.Add(strout);

    strout := Format('%2d Prob. t', [i]);
    for j := startpos to endpos do
      if j <> i then
        strout := strout + Format('   %7.4f', [ProbMat[i-1, j-1]])
      else
        strout := strout + '          ';
    AReport.Add(strout);
    AReport.Add('');

    if endpos < NoVars then
    begin
      startpos := endpos + 1;
      endpos := endpos + 6;
      if endpos > NoVars then endpos := NoVars;
      Continue;
    end;
  end;

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  ProbMat := nil;
  tMatrix := nil;
  NMatrix := nil;
end;

procedure TRMatFrm.UpdateBtnStates;
begin
  InBtn.Enabled := AnySelected(VarList);
  OutBtn.Enabled := AnySelected(SelList);
  AllBtn.Enabled := Varlist.Count > 0;
end;

initialization
  {$I rmatunit.lrs}

end.

