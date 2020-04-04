unit LSMRUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Globals, MainUnit, MatrixLib, OutPutUnit,
  FunctionsLib, DataProcs, DictionaryUnit;

type

  { TLSMregForm }

  TLSMregForm = class(TForm)
    AllBtn: TBitBtn;
    Bevel1: TBevel;
    IndepVars: TListBox;
    ComputeBtn: TButton;
    CorrsChkBox: TCheckBox;
    CovChkBox: TCheckBox;
    CPChkBox: TCheckBox;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    DepVar: TEdit;
    GroupBox1: TGroupBox;
    InBtn: TBitBtn;
    InProb: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    MatSaveChkBox: TCheckBox;
    MeansChkBox: TCheckBox;
    SaveDialog1: TSaveDialog;
    OutBtn: TBitBtn;
    PredictChkBox: TCheckBox;
    ResetBtn: TButton;
    CloseBtn: TButton;
    SDChkBox: TCheckBox;
    VarChkBox: TCheckBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: boolean;
    IndepVarsCols : IntDyneVec;
    NoVars : integer;
    NoBlocks : integer;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end;

var
  LSMregForm: TLSMregForm;

implementation

uses
  Math;

procedure TLSMregForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  IndepVars.Items.Clear;
  VarList.Items.Clear;
  NoBlocks := 1;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);

  CPChkBox.Checked := false;
  CovChkBox.Checked := false;
  CorrsChkBox.Checked := true;
  MeansChkBox.Checked := true;
  VarChkBox.Checked := false;
  SDChkBox.Checked := true;
  MatSaveChkBox.Checked := false;
  PredictChkBox.Checked := false;

  NoVars := 0;
  DepVar.Text := '';
  InProb.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  SetLength(IndepVarsCols, NoVariables+1);

  UpdateBtnStates;
end;

procedure TLSMregForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinWidth := IndepVars.Width;
  IndepVars.Constraints.MinHeight := Max(200, GroupBox1.Top + GroupBox1.Height - IndepVars.Top);

  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TLSMregForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TLSMregForm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TLSMregForm.AllBtnClick(Sender: TObject);
var
  index: integer;
begin
  for index := 0 to VarList.Items.Count-1 do
    IndepVars.Items.Add(VarList.Items.Strings[index]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TLSMregForm.ComputeBtnClick(Sender: TObject);
var
   i, j, NCases: integer;
   NoIndepVars, DepVarCol, NEntered: integer;
   R2, df1, df2: double;
   StdErrEst, F, FProbF, OldR2 : double;
   pdf1, probin, prout : double;
   errorcode : boolean;
   BetaWeights : DblDyneVec;
   BWeights : DblDyneVec;
   BStdErrs : DblDyneVec;
   Bttests : DblDyneVec;
   tProbs : DblDyneVec;
   cellstring: string;
   corrs : DblDyneMat;
   Means : DblDyneVec;
   Variances : DblDyneVec;
   StdDevs : DblDyneVec;
   title : string;
   IndRowLabels : StrDyneVec;
   IndColLabels : StrDyneVec;
   IndepInverse : DblDyneMat;
   ColEntered : IntDyneVec;
   filename : string;
   constant : double;
   errcode: boolean = false;
   anerror: Integer = 0;
   lReport: TStrings;
begin
  NCases := NoCases;
  SetLength(corrs,NoVariables+1,NoVariables+1);
  SetLength(IndepInverse,NoVariables,NoVariables+1);
  SetLength(IndepVarsCols,NoVariables+1);
  SetLength(BWeights,NoVariables+1);
  SetLength(BStdErrs,NoVariables+1);
  SetLength(Bttests,NoVariables+1);
  SetLength(tProbs,NoVariables+1);
  SetLength(Means,NoVariables+1);
  SetLength(Variances,NoVariables+1);
  SetLength(StdDevs,NoVariables+1);
  SetLength(IndepVarsCols,NoVariables+1);
  SetLength(IndColLabels,NoVariables+1);
  SetLength(IndRowLabels,NoVariables+1);
  SetLength(BetaWeights,NoVariables+1);
  SetLength(ColEntered,NoVariables+2);
  probin := StrToFloat(InProb.Text); // probability to include a block
  prout := 1.0;

  if DepVar.Text = '' then
  begin
    MessageDlg('No dependent variable selected.', mtError, [mbOK], 0);
    exit;
  end;
  if IndepVars.Items.Count = 0 then
  begin
    MessageDlg('No independent variable selected.', mtError, [mbOK], 0);
    exit;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('LEAST SQUARES MULTIPLE REGRESSION by Bill Miller');
    lReport.Add('');
    errorcode := false;

    { get dependendent variable column }
    DepVarCol := 0;
    NoVars := NoVars + 1;
    for j := 1 to NoVariables do
      if DepVar.Text = OS3MainFrm.DataGrid.Cells[j,0] then DepVarCol := j;

    R2 := 0.0;
    OldR2 := 0.0;
    pdf1 := 0.0;
    NEntered := 0;

    { get independendent variable column }
    for i := 0 to IndepVars.Count-1 do
    begin
      //cellstring := OS3Mainfrm.DataGrid.Cells[i+1,0];   // bug
      cellstring := IndepVars.Items[i];     //Bugfix by tatamata
      for j := 1 to NoVariables do
      begin
        if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
        begin
          IndepVarsCols[i] := j;
          ColEntered[i] := j;
          NEntered := NEntered + 1;
          IndRowLabels[NEntered-1] := cellstring;
          IndColLabels[NEntered-1] := cellstring;
        end;
      end;
    end;
    NEntered := NEntered + 1; // dependent variable last
    ColEntered[NEntered-1] := DepVarCol;
    IndRowLabels[NEntered-1] := OS3MainFrm.DataGrid.Cells[DepVarCol,0];
    IndColLabels[NEntered-1] := OS3MainFrm.DataGrid.Cells[DepVarCol,0];

    if CPChkBox.Checked  then
    begin
      title := 'Cross-Products Matrix';
      GridXProd(NEntered, ColEntered, Corrs, errcode, NCases);
      MatPrint(Corrs, NEntered, NEntered, title, IndRowLabels, IndColLabels, NCases, lReport);
      lReport.Add('--------------------------------------------------------------------');
    end;

    if CovChkBox.Checked then
    begin
      title := 'Variance-Covariance Matrix';
      GridCovar(NEntered,ColEntered, Corrs, Means, Variances, StdDevs, errcode, NCases);
      MatPrint(Corrs, NEntered, NEntered, title, IndRowLabels, IndColLabels, NCases, lReport);
      lReport.Add('--------------------------------------------------------------------');
    end;
    Correlations(NEntered,ColEntered,Corrs,Means,Variances, StdDevs,errcode,NCases);

    if CorrsChkBox.Checked then
    begin
      title := 'Product-Moment Correlations Matrix';
      MatPrint(Corrs, NEntered, NEntered, title, IndRowLabels, IndColLabels, NCases, lReport);
      lReport.Add('--------------------------------------------------------------------');
    end;

    if MeansChkBox.Checked then
    begin
      title := 'Means';
      DynVectorPrint(Means, NEntered, title, IndColLabels, NCases, lReport);
      lReport.Add('--------------------------------------------------------------------');
    end;

    if VarChkBox.Checked = true then
    begin
      title := 'Variances';
      DynVectorPrint(Variances, NEntered, title, IndColLabels, NCases, lReport);
      lReport.Add('--------------------------------------------------------------------');
    end;

    if SDChkBox.Checked = true then
    begin
      title := 'Standard Deviations';
      DynVectorPrint(StdDevs, NEntered, title, IndColLabels, NCases, lReport);
      lReport.Add('--------------------------------------------------------------------');
    end;

    if errorcode then
    begin
      MessageDlg('A selected variable has no variability. Run aborted.', mtError, [mbOK], 0);
      exit;
    end;
    NoIndepVars := NEntered - 1;

    MReg(NoIndepVars, ColEntered, DepVarCol, IndRowLabels, Means, Variances,
         StdDevs, BWeights, BetaWeights, BStdErrs, Bttests, tProbs, R2,
         StdErrEst, NCases, errorcode, true, lReport);

    df1 := NoIndepVars - pdf1;
    df2 := NCases - NoIndepVars - 1;
    F := ((R2 - OldR2) / (1.0 - R2)) * df2 / df1;
    FProbF := probf(F,df1,df2);
    if FProbF < probin then
      lReport.Add('Entry requirements met')
    else
      lReport.Add('Entry requirements not met');

    lReport.Add('');
    lReport.Add('====================================================================');
    lReport.Add('');

    { add [predicted scores, residual scores, etc. to grid if options elected }
    if PredictChkBox.Checked then
    begin
      prout := 1.0;
      Correlations(NEntered, ColEntered, Corrs, Means, Variances, StdDevs, errcode, NCases);

      MReg2(NCases, NEntered, NoIndepVars, ColEntered, corrs, IndepInverse,
            IndRowLabels, R2, BetaWeights, Means, Variances, anerror,
            StdErrEst, constant, prout, true, false, false, lReport);

      Predict(ColEntered, NEntered, IndepInverse, Means, StdDevs,
              BetaWeights, StdErrEst, IndepVarsCols, NoIndepVars);
    end;

//   OutputFrm.ShowModal;
//   OutputFrm.RichEdit.Clear;

    if MatSaveChkBox.Checked then
    begin
      SaveDialog1.Filter := 'LazStats matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
      SaveDialog1.FilterIndex := 1;
      if SaveDialog1.Execute then
      begin
        filename := SaveDialog1.FileName;
        MatSave(Corrs, NoVars, NoVars, Means, StdDevs, NCases, IndRowLabels, IndColLabels, filename);
      end;
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;
    ColEntered := nil;
    BetaWeights := nil;
    IndColLabels := nil;
    IndRowLabels := nil;
    StdDevs := nil;
    Variances := nil;
    Means := nil;
    IndepInverse := nil;
    corrs := nil;
    IndepVarsCols := nil;
  end;
end;

procedure TLSMregForm.DepInBtnClick(Sender: TObject);
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

procedure TLSMregForm.DepOutBtnClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TLSMregForm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      IndepVars.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TLSMregForm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < IndepVars.Items.Count do
  begin
    if IndepVars.Selected[i] then
    begin
      VarList.Items.Add(IndepVars.Items[i]);
      IndepVars.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TLSMregForm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i := 0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  DepInBtn.Enabled := lSelected;
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to IndepVars.Items.Count-1 do
    if IndepVars.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;
  DepOutBtn.Enabled := DepVar.Text <> '';
  AllBtn.Enabled := VarList.Items.Count > 0;
end;

procedure TLSMregForm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I lsmrunit.lrs}

end.

