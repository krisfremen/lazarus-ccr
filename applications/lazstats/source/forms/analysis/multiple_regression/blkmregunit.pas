{ File for testing: Longley.laz
  - dependent variable: y
  - independent variables: the others }

unit BlkMRegUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Globals, MainUnit, MatrixLib, OutputUnit, FunctionsLib,
  DataProcs, DictionaryUnit;


type

  { TBlkMregFrm }

  TBlkMregFrm = class(TForm)
    Bevel1: TBevel;
    Bevel3: TBevel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    CPChkBox: TCheckBox;
    CovChkBox: TCheckBox;
    CorrsChkBox: TCheckBox;
    MeansChkBox: TCheckBox;
    SaveDialog1: TSaveDialog;
    VarChkBox: TCheckBox;
    SDChkBox: TCheckBox;
    MatSaveChkBox: TCheckBox;
    PredictChkBox: TCheckBox;
    GroupBox1: TGroupBox;
    InProb: TEdit;
    Label5: TLabel;
    NextBlkBtn: TButton;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    BlockNoEdit: TEdit;
    InBtn: TBitBtn;
    Label4: TLabel;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    DepVar: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BlockList: TListBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure NextBlkBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    BlkVarCols : IntDyneMat;
    NoBlocks : integer;
    VarsInBlk : IntDyneVec;
    NoVars : integer;
    procedure UpdateBtnStates;
    function Valid(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  BlkMregFrm: TBlkMregFrm;

implementation

uses
  Utils, Math;

{ TBlkMregFrm }

procedure TBlkMregFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  BlockList.Items.Clear;
  VarList.Items.Clear;
  BlockNoEdit.Text := '1';
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
//     HeteroChk.Checked := false;

  NoVars := 0;
  DepVar.Text := '';
  InProb.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);

  SetLength(BlkVarCols,NoVariables,NoVariables);
  SetLength(VarsInBlk,NoVariables);
end;

procedure TBlkMregFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TBlkMregFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TBlkMregFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TBlkMregFrm.AllBtnClick(Sender: TObject);
var
  index: integer;
begin
  for index := 0 to VarList.Items.Count-1 do
    BlockList.Items.Add(VarList.Items[index]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TBlkMregFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k, errorcode: integer;
   NoIndepVars, DepVarCol, NEntered, StepNo : integer;
   R2, df1, df2: double;
   StdErrEst, F, FProbF, OldR2 : double;
   pdf1, probin, prout : double;
   BetaWeights : DblDyneVec;
   corrs : DblDyneMat;
   Means : DblDyneVec;
   Variances : DblDyneVec;
   StdDevs : DblDyneVec;
   title : string;
   IndRowLabels : StrDyneVec;
   IndColLabels : StrDyneVec;
   IndepInverse : DblDyneMat;
   IndepIndex : IntDyneVec;
   Candidate : IntDyneVec;
   filename : string;
   ColEntered : IntDyneVec;
   constant : double;
   errcode: boolean = false;
   NCases: Integer = 0;
   msg: String;
   C: TWinControl;
   lReport: TStrings;
begin
   if not Valid(msg, C) then
   begin
     C.SetFocus;
     MessageDlg(msg, mtError, [mbOK], 0);
     exit;
   end;

   SetLength(corrs,NoVariables+1,NoVariables+1);
   SetLength(IndepInverse,NoVariables,NoVariables);
   SetLength(Means,NoVariables);
   SetLength(Variances,NoVariables);
   SetLength(StdDevs,NoVariables);
   SetLength(IndepIndex,NoVariables);
   SetLength(IndColLabels,NoVariables);
   SetLength(IndRowLabels,NoVariables);
   SetLength(BetaWeights,NoVariables);
   SetLength(Candidate,NoVariables);
   SetLength(ColEntered,NoVariables);

   NextBlkBtnClick(self);
   probin := StrToFloat(InProb.Text); // probability to include a block
   prout := 1.0;

   lReport := TStringList.Create;
   try
     lReport.Add('BLOCK ENTRY MULTIPLE REGRESSION by Bill Miller');
     errorcode := 0;

     { get dependendent variable column }
     if DepVar.Text = '' then
     begin
       MessageDlg('No Dependent variable selected.', mtError, [mbOK], 0);
       exit;
     end;

     if BlockList.Items.Count = 0 then
     begin
       MessageDlg('No independent variables selected.', mtError, [mbOK], 0);
       exit;
     end;

     DepVarCol := 0;
     NoVars := NoVars + 1;
     for j := 1 to NoVariables do
       if DepVar.Text = OS3MainFrm.DataGrid.Cells[j,0] then DepVarCol := j;

     R2 := 0.0;
     OldR2 := 0.0;
     pdf1 := 0.0;
     for i := 1 to NoBlocks-1 do
       Candidate[i-1] := i;

     { Now, complete Mult. Regs by adding blocks in each step }
     for StepNo := 1 to NoBlocks-1 do
     begin
       NEntered := 0;
       for i := 1 to StepNo do
       begin
             if (Candidate[StepNo-1] <> 0) then
             begin
                  for j := 1 to VarsInBlk[i-1] do
                  begin
                       NEntered := NEntered + 1;
                       ColEntered[NEntered-1] := BlkVarCols[i-1,j-1];
                       k := BlkVarCols[i-1,j-1];
                       IndRowLabels[NEntered-1] := OS3MainFrm.DataGrid.Cells[k,0];
                       IndColLabels[NEntered-1] := OS3MainFrm.DataGrid.Cells[k,0];
                  end;
             end;
       end;
       NEntered := NEntered + 1; // dependent variable last
       ColEntered[NEntered-1] := DepVarCol;
       IndRowLabels[NEntered-1] := OS3MainFrm.DataGrid.Cells[DepVarCol,0];
       IndColLabels[NEntered-1] := OS3MainFrm.DataGrid.Cells[DepVarCol,0];

       lReport.Add('');
       lReport.Add('----------------- Trial Block %d Variables Added ------------------', [StepNo]);
       if CPChkBox.Checked then
       begin
             title := 'Cross-Products Matrix';
             GridXProd(NEntered,ColEntered,Corrs,errcode,NCases);
             MatPrint(Corrs, NEntered, NEntered, title, IndRowLabels, IndColLabels, NCases, lReport);
       end;

       if CovChkBox.Checked then
       begin
             title := 'Variance-Covariance Matrix';
             GridCovar(NEntered, ColEntered, Corrs, Means, Variances, StdDevs, errcode, NCases);
             MatPrint(Corrs, NEntered, NEntered, title, IndRowLabels, IndColLabels, NCases, lReport);
       end;

        Correlations(NEntered, ColEntered, Corrs, Means, Variances, StdDevs, errcode, NCases);
       if CorrsChkBox.Checked then
       begin
             title := 'Product-Moment Correlations Matrix';
             MatPrint(Corrs, NEntered, NEntered, title, IndRowLabels, IndColLabels, NCases, lReport);
       end;

       if MeansChkBox.Checked then
       begin
          title := 'Means';
          DynVectorPrint(Means, NEntered, title, IndColLabels, NCases, lReport);
       end;

       if VarChkBox.Checked then
       begin
          title := 'Variances';
          DynVectorPrint(Variances, NEntered, title, IndColLabels, NCases, lReport);
       end;

       if SDChkBox.Checked then
       begin
          title := 'Standard Deviations';
          DynVectorPrint(StdDevs, NEntered, title, IndColLabels, NCases, lReport);
       end;

       if errorcode > 0 then
       begin
          DisplayReport(lReport);
          MessageDlg('A selected variable has no variability-run aborted.', mtError,[mbOK], 0);
          exit;
       end;

       NoIndepVars := NEntered - 1;
       for i := 1 to NoIndepVars do IndepIndex[i-1] := i;

       MReg2(NCases,NEntered, NoIndepVars, IndepIndex, corrs, IndepInverse,
         IndRowLabels, R2, BetaWeights,
         Means, Variances, errorcode, StdErrEst, constant, prout, true, false, false, lReport
       );

       lReport.Add('');
       lReport.Add('Increase in R Squared: %10.3f', [R2-OldR2]);

       df1 := NoIndepVars - pdf1;
       df2 := NCases - NoIndepVars - 1;
       F := ((R2 - OldR2) / (1.0 - R2)) * df2 / df1;
       FProbF := probf(F, df1, df2);
       lReport.Add('F:     %26.3f', [F]);
       lReport.Add('with probability       %10.3f', [FProbF]);
       if FProbF < probin then
         lReport.Add('Block %d met entry requirements', [StepNo])
       else
       begin
         Candidate[StepNo-1] := 0;
         NoIndepVars := NoIndepVars - VarsInBlk[StepNo-1];
         lReport.Add('Block %d did not meet entry requirements', [StepNo]);
       end;

       OldR2 := R2;
       pdf1 := NoIndepVars;
     end;

     { add [predicted scores, residual scores, etc. to grid if options elected }
     if PredictChkBox.Checked then
     begin
        prout := 1.0;
        Correlations(NEntered, ColEntered, Corrs, Means, Variances, StdDevs, errcode, NCases);

        MReg2(NCases, NEntered, NoIndepVars, IndepIndex, corrs, IndepInverse,
          IndRowLabels, R2, BetaWeights,
          Means, Variances, errorcode, StdErrEst, constant, prout, true, false, false, lReport
        );

        Predict(ColEntered, NEntered, IndepInverse, Means, StdDevs,
          BetaWeights, StdErrEst, IndepIndex, NoIndepVars
        );
     end;

{   if HeteroChk.Checked = true then // do BPG test
   begin
        lReport.Add('');
        lReport.Add('=====================================================');
        lReport.Add('Breusch-Pagan-Godfrey Test of Heteroscedasticity');
        lReport.Add('=====================================================');
        lReport.Add('');
        lReport.Add('Auxiliary Regression');
        lReport.Add('');
        BPG := 0.0;
        col := NoVariables + 1;
        DictionaryFrm.NewVar(col);
        DictionaryFrm.DictGrid.Cells[1,col] := 'BPGResid.';
        OS3MainFrm.DataGrid.Cells[col,0] := 'BPGResid.';
        NoVariables := NoVariables + 1;
        // get predicted raw score
        for i := 1 to NCases do
        begin
             Y := 0.0;
             for j := 1 to NoIndepVars do
             begin
                  col := IndepIndex[j-1];
                  k := ColEntered[col-1];
                  z := (StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i])) -
                               Means[col-1]) / StdDevs[col-1];
                  Y := Y + (z * BetaWeights[j-1]); // predicted z score
             end;
             Y := Y * StdDevs[NEntered-1] + Means[NEntered-1]; // predicte raw
             k := ColEntered[NEntered-1];
             Y := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i])) - Y; // residual
             BPG := BPG + (Y * Y); // sum of squared residuals
             // save squared value for each case
             OS3MainFrm.DataGrid.Cells[NoVariables,i] := FloatToStr(Y * Y);
//             OS3MainFrm.DataGrid.Cells[NoVariables,i] := Format('%8.3f',[Y * Y]);
        end;
        BPG := BPG / NCases;
        for i := 1 to NCases do
        begin
             Y := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[NoVariables,i])) / BPG;
             OS3MainFrm.DataGrid.Cells[NoVariables,i] := Format('%8.3f',[Y]);
        end;
        // Now, regress Hetero values on the independent variables
        DepVarCol := NoVariables;
        ColEntered[NEntered-1] := NoVariables;
        IndRowLabels[NEntered-1] := OS3MainFrm.DataGrid.Cells[DepVarCol,0];
        IndColLabels[NEntered-1] := OS3MainFrm.DataGrid.Cells[DepVarCol,0];
        Correlations(NEntered,ColEntered,Corrs,Means,Variances,
                    StdDevs,errcode,NCases);
          if CorrsChkBox.Checked = true then
          begin
               title := 'Product-Moment Correlations Matrix';
               MatPrint(Corrs,NEntered,NEntered,title,IndRowLabels,IndColLabels,NCases, lReport);
          end;
          title := 'Means';
          if MeansChkBox.Checked = true then
             DynVectorPrint(Means,NEntered,title,IndColLabels,NCases, lReport);
          title := 'Variances';
          if VarChkBox.Checked = true then
             DynVectorPrint(Variances,NEntered,title,IndColLabels,NCases, lReport);
          title := 'Standard Deviations';
          if SDChkBox.Checked = true then
             DynVectorPrint(StdDevs,NEntered,title,IndColLabels,NCases, lReport);
        MReg2(NCases,NEntered,NoIndepVars,IndepIndex,corrs,IndepInverse,
                    IndRowLabels,R2,BetaWeights,
                    Means,Variances,errorcode,StdErrEst,constant,prout,true, false,false, lReport);
        BPG := ( R2 * Variances[NEntered-1] * (Ncases-1) ) / 2;
        chiprob := 1.0 - chisquaredprob(BPG,NEntered-1);
        lReport.Add('');
        lReport.Add('Breusch-Pagan-Godfrey Test of Heteroscedasticity');
        lReport.Add('Chi-Square = %8.3f with probability greater value = %8.3f',[BPG,chiprob]);
        lReport.Add('');
   end;
}
     DisplayReport(lReport);

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

   finally
     lReport.Free;
     ColEntered := nil;
     Candidate := nil;
     BetaWeights := nil;
     IndColLabels := nil;
     IndRowLabels := nil;
     IndepIndex := nil;
     StdDevs := nil;
     Variances := nil;
     Means := nil;
     IndepInverse := nil;
     corrs := nil;
     VarsInBlk := nil;
     BlkVarCols := nil;
   end;
end;

procedure TBlkMregFrm.DepInBtnClick(Sender: TObject);
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

procedure TBlkMregFrm.DepOutBtnClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TBlkMregFrm.InBtnClick(Sender: TObject);
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
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TBlkMregFrm.NextBlkBtnClick(Sender: TObject);
var
  blkno, i, j, count: integer;
  cellstring: string;
begin
  {save columns of variables in the current block }
  count := BlockList.Items.Count;
  if count = 0 then
  begin
    VarsInBlk[NoBlocks-1] := 0;
    exit;
  end;

  VarsInBlk[NoBlocks-1] := count;
  for i := 0 to count-1 do
  begin
    for j := 1 to NoVariables do
    begin
      cellstring := OS3MainFrm.DataGrid.Cells[j,0];
      if cellstring = BlockList.Items.Strings[i] then
      begin
        BlkVarCols[NoBlocks-1,i] := j;
        NoVars := NoVars + 1;
      end;
    end;
  end;

  blkno := StrToInt(BlockNoEdit.Text);
  blkno := blkno + 1;
  BlockNoEdit.Text := IntToStr(blkno);
  NoBlocks := blkno;
  //BlockList.Clear;
end;

procedure TBlkMregFrm.OutBtnClick(Sender: TObject);
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
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TBlkMregFrm.UpdateBtnStates;
var
  lSelected: Boolean;
begin
   lSelected := AnySelected(VarList);
   DepInBtn.Enabled := lSelected and (DepVar.Text = '');
   InBtn.Enabled := lSelected;

   DepOutBtn.Enabled := (DepVar.Text <> '');
   OutBtn.Enabled := AnySelected(BlockList);

   AllBtn.Enabled := VarList.Items.Count > 0;
end;

function TBlkMregFrm.Valid(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
  x: Double;
begin
  Result := false;

  if BlockNoEdit.Text = '' then
  begin
    AControl := BlockNoEdit;
    AMsg := 'Block No. not specified.';
    exit;
  end;
  if not TryStrToInt(BlockNoEdit.Text, n) then
  begin
    AControl := BlockNoEdit;
    AMsg := 'Block No. is not a valid integer.';
    exit;
  end;
  if (n <= 0) then
  begin
    AControl := BlockNoEdit;
    AMsg := 'Posivitve value required.';
    exit;
  end;

  if InProb.Text = '' then
  begin
    AControl := InProb;
    AMsg := 'Minimum probability to enter block not specified.';
    exit;
  end;
  if not TryStrToFloat(InProb.Text, x) then
  begin
    AControl := InProb;
    AMsg := 'Minimum probability to enter block is not a valid number.';
    exit;
  end;
  if (x <= 0.0) then
  begin
    AControl := InProb;
    AMsg := 'Positive value required.';
    exit;
  end;

  Result := true;
end;

procedure TBlkMregFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I blkmregunit.lrs}

end.

