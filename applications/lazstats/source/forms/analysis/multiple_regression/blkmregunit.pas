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
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
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
    procedure CancelBtnClick(Sender: TObject);
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
  private
    { private declarations }
    FAutoSized: Boolean;
    BlkVarCols : IntDyneMat;
    NoBlocks : integer;
    VarsInBlk : IntDyneVec;
    NoVars : integer;

  public
    { public declarations }
  end; 

var
  BlkMregFrm: TBlkMregFrm;

implementation

uses
  Math;

{ TBlkMregFrm }

procedure TBlkMregFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     BlockList.Items.Clear;
     VarList.Items.Clear;
     BlockNoEdit.Text := '1';
     NoBlocks := 1;
     for i := 1 to NoVariables do
     begin
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     end;
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
     DepInBtn.Enabled := true;
     DepOutBtn.Enabled := false;
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
     InProb.Text := '0.05';
     SetLength(BlkVarCols,NoVariables,NoVariables);
     SetLength(VarsInBlk,NoVariables);
end;

procedure TBlkMregFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;
  w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TBlkMregFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then Application.CreateForm(TOutputFrm, OutputFrm);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TBlkMregFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TBlkMregFrm.AllBtnClick(Sender: TObject);
VAR count, index : integer;
begin
     count := VarList.Items.Count;
     for index := 0 to count-1 do
     begin
          BlockList.Items.Add(VarList.Items.Strings[index]);
     end;
     VarList.Clear;
end;

procedure TBlkMregFrm.CancelBtnClick(Sender: TObject);
begin
  if VarsInBlk <> nil then VarsInBlk := nil;
  if BlkVarCols <> nil then BlkVarCols := nil;
  Close;
end;

procedure TBlkMregFrm.ComputeBtnClick(Sender: TObject);
Label CleanUp;
var
   i, j, k, errorcode, NCases : integer;
   NoIndepVars, DepVarCol, NEntered, StepNo : integer;
   R2, df1, df2: double;
   StdErrEst, F, FProbF, OldR2 : double;
   pdf1, pdf2, probin, prout : double;
   BetaWeights : DblDyneVec;
   outline : string;
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
   errcode : boolean = false;
begin
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
     OutputFrm.RichEdit.Clear;
//     OutputFrm.RichEdit.ParaGraph.Alignment := taLeftJustify;
     OutputFrm.RichEdit.Lines.Add('Block Entry Multiple Regression by Bill Miller');
     errorcode := 0;

     { get dependendent variable column }
     if DepVar.Text = '' then
     begin
          ShowMessage('ERROR! No Dependent variable selected.');
          goto CleanUp;
     end;
     DepVarCol := 0;
     NoVars := NoVars + 1;
     for j := 1 to NoVariables do
          if DepVar.Text = OS3MainFrm.DataGrid.Cells[j,0] then DepVarCol := j;
     R2 := 0.0;
     OldR2 := 0.0;
     pdf1 := 0.0;
     pdf2 := 0.0;
     for i := 1 to NoBlocks-1 do Candidate[i-1] := i;
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
          OutputFrm.RichEdit.Lines.Add('');
          outline := format('----------------- Trial Block %d Variables Added ------------------',[StepNo]);
          OutputFrm.RichEdit.Lines.Add(outline);
          if CPChkBox.Checked = true then
          begin
               title := 'Cross-Products Matrix';
               GridXProd(NEntered,ColEntered,Corrs,errcode,NCases);
               MAT_PRINT(Corrs,NEntered,NEntered,title,IndRowLabels,IndColLabels,NCases);
          end;
          if CovChkBox.Checked = true then
          begin
               title := 'Variance-Covariance Matrix';
               GridCovar(NEntered,ColEntered,Corrs,Means,Variances,
                      StdDevs,errcode,NCases);
               MAT_PRINT(Corrs,NEntered,NEntered,title,IndRowLabels,IndColLabels,NCases);
          end;
          Correlations(NEntered,ColEntered,Corrs,Means,Variances,
                    StdDevs,errcode,NCases);
          if CorrsChkBox.Checked = true then
          begin
               title := 'Product-Moment Correlations Matrix';
               MAT_PRINT(Corrs,NEntered,NEntered,title,IndRowLabels,IndColLabels,NCases);
          end;
          title := 'Means';
          if MeansChkBox.Checked = true then
             DynVectorPrint(Means,NEntered,title,IndColLabels,NCases);
          title := 'Variances';
          if VarChkBox.Checked = true then
             DynVectorPrint(Variances,NEntered,title,IndColLabels,NCases);
          title := 'Standard Deviations';
          if SDChkBox.Checked = true then
             DynVectorPrint(StdDevs,NEntered,title,IndColLabels,NCases);
          if errorcode > 0 then
          begin
               ShowMessage('ERROR! A selected variable has no variability-run aborted.');
               goto CleanUp;
          end;
          NoIndepVars := NEntered - 1;
          for i := 1 to NoIndepVars do IndepIndex[i-1] := i;
          MReg2(NCases,NEntered,NoIndepVars,IndepIndex,corrs,IndepInverse,
               IndRowLabels,R2,BetaWeights,
               Means,Variances,errorcode,StdErrEst,constant,prout,true, false,false, OutputFrm.RichEdit.Lines);
          outline := format('Increase in R Squared = %6.3f',[R2-OldR2]);
          OutputFrm.RichEdit.Lines.Add(outline);
          df1 := NoIndepVars - pdf1;
          df2 := NCases - NoIndepVars - 1;
          F := ((R2 - OldR2) / (1.0 - R2)) * df2 / df1;
          FProbF := probf(F,df1,df2);
          outline := format('F = %6.3f with probability = %6.3f',[F,FProbF]);
          OutputFrm.RichEdit.Lines.Add(outline);
          if FProbF < probin then
          begin
               outline := format('Block %d met entry requirements',[StepNo]);
               OutputFrm.RichEdit.Lines.Add(outline);
          end
          else
          begin
               Candidate[StepNo-1] := 0;
               NoIndepVars := NoIndepVars - VarsInBlk[StepNo-1];
               outline := format('Block %d did not meet entry requirements',[StepNo]);
               OutputFrm.RichEdit.Lines.Add(outline);
          end;
          OldR2 := R2;
          pdf1 := NoIndepVars;
     end;

   { add [predicted scores, residual scores, etc. to grid if options elected }
   if PredictChkBox.Checked = true then
   begin
        prout := 1.0;
        Correlations(NEntered,ColEntered,Corrs,Means,Variances,
                    StdDevs,errcode,NCases);

        MReg2(NCases,NEntered,NoIndepVars,IndepIndex,corrs,IndepInverse,
                    IndRowLabels,R2,BetaWeights,
                    Means,Variances,errorcode,StdErrEst,constant,prout,true, false,false, OutputFrm.RichEdit.Lines);

        Predict(ColEntered, NEntered, IndepInverse, Means, StdDevs,
                BetaWeights, StdErrEst, IndepIndex, NoIndepVars);
   end;

{   if HeteroChk.Checked = true then // do BPG test
   begin
        OutputFrm.RichEdit.Lines.Add('');
        OutputFrm.RichEdit.Lines.Add('=====================================================');
        OutputFrm.RichEdit.Lines.Add('Breusch-Pagan-Godfrey Test of Heteroscedasticity');
        OutputFrm.RichEdit.Lines.Add('=====================================================');
        OutputFrm.RichEdit.Lines.Add('');
        OutputFrm.RichEdit.Lines.Add('Auxiliary Regression');
        OutputFrm.RichEdit.Lines.Add('');
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
               MAT_PRINT(Corrs,NEntered,NEntered,title,IndRowLabels,IndColLabels,NCases);
          end;
          title := 'Means';
          if MeansChkBox.Checked = true then
             DynVectorPrint(Means,NEntered,title,IndColLabels,NCases);
          title := 'Variances';
          if VarChkBox.Checked = true then
             DynVectorPrint(Variances,NEntered,title,IndColLabels,NCases);
          title := 'Standard Deviations';
          if SDChkBox.Checked = true then
             DynVectorPrint(StdDevs,NEntered,title,IndColLabels,NCases);
        MReg2(NCases,NEntered,NoIndepVars,IndepIndex,corrs,IndepInverse,
                    IndRowLabels,R2,BetaWeights,
                    Means,Variances,errorcode,StdErrEst,constant,prout,true, false,false);
        BPG := ( R2 * Variances[NEntered-1] * (Ncases-1) ) / 2;
        chiprob := 1.0 - chisquaredprob(BPG,NEntered-1);
        OutputFrm.RichEdit.Lines.Add('');
        OutputFrm.RichEdit.Lines.Add('Breusch-Pagan-Godfrey Test of Heteroscedasticity');
        outline := format('Chi-Square = %8.3f with probability greater value = %8.3f',[BPG,chiprob]);
        OutputFrm.RichEdit.Lines.Add(outline);
        OutputFrm.RichEdit.Lines.Add('');
   end;
}
     if MatSaveChkBox.Checked = true then
     begin
          SaveDialog1.Filter := 'FreeStat matrix files (*.MAT)|*.MAT|All files (*.*)|*.*';
          SaveDialog1.FilterIndex := 1;
          if SaveDialog1.Execute then
          begin
               filename := SaveDialog1.FileName;
               MATSAVE(Corrs,NoVars,NoVars,Means,StdDevs,NCases,IndRowLabels,IndColLabels,filename);
          end;
     end;
     OutputFrm.ShowModal;
CleanUp:
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

procedure TBlkMregFrm.DepInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     DepVar.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     DepOutBtn.Enabled := true;
     DepInBtn.Enabled := false;
end;

procedure TBlkMregFrm.DepOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(DepVar.Text);
     DepVar.Text := '';
     DepInBtn.Enabled := true;
end;

procedure TBlkMregFrm.InBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            BlockList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     OutBtn.Enabled := true;
end;

procedure TBlkMregFrm.NextBlkBtnClick(Sender: TObject);
var
   blkno, i, j, count : integer;
   cellstring : string;
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
     BlockList.Clear;
end;

procedure TBlkMregFrm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
   index := BlockList.ItemIndex;
   VarList.Items.Add(BlockList.Items.Strings[index]);
   BlockList.Items.Delete(index);
   InBtn.Enabled := true;
   if BlockList.Items.Count = 0 then OutBtn.Enabled := false;
end;

initialization
  {$I blkmregunit.lrs}

end.

