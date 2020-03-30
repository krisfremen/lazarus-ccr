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
    CancelBtn: TButton;
    ReturnBtn: TButton;
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
    ProbOut: TEdit;
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
    ListBox1: TListBox;
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
  private
    { private declarations }
    FAutoSized: boolean;
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
VAR i : integer;
begin
     VarList.Clear;
     ListBox1.Clear;
     for i := 1 to NoVariables do
     begin
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     end;
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
     DepInBtn.Enabled := true;
     DepOutBtn.Enabled := false;
     DepVar.Text := '';
     InProb.Text := '0.05';
     ProbOut.Text := '0.10';
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

  w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := Max(200, GroupBox2.Top + Groupbox2.Height - VarList.Top);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TStepFwdFrm.FormCreate(Sender: TObject);
begin
   Assert(OS3MainFrm <> nil);
   if OutputFrm = nil then Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TStepFwdFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TStepFwdFrm.AllBtnClick(Sender: TObject);
var count, index : integer;
begin
     count := VarList.Items.Count;
     for index := 0 to count-1 do
     begin
          ListBox1.Items.Add(VarList.Items.Strings[index]);
     end;
     VarList.Clear;
end;

procedure TStepFwdFrm.ComputeBtnClick(Sender: TObject);
Label CleanUp, lastone;
var
   i, j, k, k1, NoVars, NCases,errcnt : integer;
   errorcode : boolean;
   Index, NoIndepVars : integer;
   largest, R2, Constant: double;
   StdErrEst, NewR2, LargestPartial : double;
   pdf1, pdf2, PartF, PartProb, LargestProb, POut : double;
   SmallestProb : double;
   BetaWeights : DblDyneVec;
   cellstring, outline: string;
   corrs : DblDyneMat;
   Means : DblDyneVec;
   Variances : DblDyneVec;
   StdDevs : DblDyneVec;
   ColNoSelected : IntDyneVec;
   title : string;
   RowLabels : StrDyneVec;
   ColLabels : StrDyneVec;
   IndRowLabels : StrDyneVec;
   IndColLabels : StrDyneVec;
   IndepCorrs : DblDyneMat;
   IndepInverse : DblDyneMat;
   IndepIndex : IntDyneVec;
   XYCorrs : DblDyneVec;
   matched : boolean;
   Partial : DblDyneVec;
   Candidate : IntDyneVec;
   TempNoVars : Integer;
   StepNo : integer;
   filename : string;
begin
     if NoVariables = 0 then NoVariables := 200;
     SetLength(corrs,NoVariables+1,NoVariables+1);
     SetLength(IndepCorrs,NoVariables,NoVariables);
     SetLength(IndepInverse,NoVariables,NoVariables);
     SetLength(Means,NoVariables);
     SetLength(Variances,NoVariables);
     SetLength(StdDevs,NoVariables);
     SetLength(RowLabels,NoVariables);
     SetLength(ColLabels,NoVariables);
     SetLength(XYCorrs,NoVariables);
     SetLength(IndepIndex,NoVariables);
     SetLength(IndColLabels,NoVariables);
     SetLength(IndRowLabels,NoVariables);
     SetLength(BetaWeights,NoVariables);
     SetLength(Partial,NoVariables);
     SetLength(Candidate,NoVariables);
     SetLength(ColNoSelected,NoVariables);

     OutputFrm.RichEdit.Clear;
//     OutputFrm.RichEdit.ParaGraph.Alignment := taLeftJustify;
     OutputFrm.RichEdit.Lines.Add('Stepwise Multiple Regression by Bill Miller');
     StepNo := 1;
     errcnt := 0;
     errorcode := false;
     if MatInChkBox.Checked = true then
     begin
          OpenDialog1.Filter := 'OS3 matrix files (*.MAT)|*.MAT|All files (*.*)|*.*';
          OpenDialog1.FilterIndex := 1;
          if OpenDialog1.Execute then
          begin
               filename := OpenDialog1.FileName;
               MATREAD(Corrs,NoVars,NoVars,Means,StdDevs,NCases,RowLabels,ColLabels,filename);
               for i := 0 to NoVars-1 do
               begin
                    Variances[i] := sqr(StdDevs[i]);
                    ColNoSelected[i] := i+1;
               end;
               DepVar.Text := RowLabels[NoVars-1];
               for i := 0 to NoVars-2 do ListBox1.Items.Add(RowLabels[i]);
               ShowMessage('NOTICE! Last variable in matrix is the dependent variable');
          end;
     end;
     if MatInChkBox.Checked = false then
     begin
          { get independent item columns }
          NoVars := ListBox1.Items.Count;
          if NoVars < 1 then
          begin
               ShowMessage('ERROR! No independent variables selected.');
               goto CleanUp;
          end;
          for i := 0 to NoVars-1 do
          begin
               cellstring := ListBox1.Items.Strings[i];
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
               ShowMessage('ERROR! No Dependent variable selected.');
               goto CleanUp;
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
          if CPChkBox.Checked = true then
          begin
               title := 'Cross-Products Matrix';
               GridXProd(NoVars,ColNoSelected,Corrs,errorcode,NCases);
               MAT_PRINT(Corrs,NoVars,NoVars,title,RowLabels,ColLabels,NCases);
          end;
          if CovChkBox.Checked = true then
          begin
               title := 'Variance-Covariance Matrix';
               GridCovar(NoVars,ColNoSelected,Corrs,Means,Variances,
                      StdDevs,errorcode,NCases);
               MAT_PRINT(Corrs,NoVars,NoVars,title,RowLabels,ColLabels,NCases);
          end;
          Correlations(NoVars,ColNoSelected,Corrs,Means,Variances,
                    StdDevs,errorcode,NCases);
     end;
     if CorrsChkBox.Checked = true then
     begin
          title := 'Product-Moment Correlations Matrix';
          MAT_PRINT(Corrs,NoVars,NoVars,title,RowLabels,ColLabels,NCases);
     end;
     if MatSaveChkBox.Checked = true then
     begin
          SaveDialog1.Filter := 'OS3 matrix files (*.MAT)|*.MAT|All files (*.*)|*.*';
          SaveDialog1.FilterIndex := 1;
          if SaveDialog1.Execute then
          begin
               filename := SaveDialog1.FileName;
               MATSAVE(Corrs,NoVars,NoVars,Means,StdDevs,NCases,RowLabels,ColLabels,filename);
          end;
     end;
     title := 'Means';
     if MeansChkBox.Checked = true then
        DynVectorPrint(Means,NoVars,title,ColLabels,NCases);
     title := 'Variances';
     if VarChkBox.Checked = true then
        DynVectorPrint(Variances,NoVars,title,ColLabels,NCases);
     title := 'Standard Deviations';
     if SDChkBox.Checked = true then
        DynVectorPrint(StdDevs,NoVars,title,ColLabels,NCases);
     if errorcode then
     begin
          OutputFrm.RichEdit.Lines.Add('One or more correlations could not be computed due to zero variance of a variable.');
     end;
     OutputFrm.ShowModal;
     if errorcode then
     begin
          ShowMessage('ERROR! A selected variable has no variability-run aborted.');
          goto CleanUp;
     end;
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Stepwise Multiple Regression by Bill Miller');

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
     POut := StrToFloat(ProbOut.Text);
     OutputFrm.RichEdit.Lines.Add('');
     outline := format('----------------- STEP %d ------------------',[StepNo]);
     OutputFrm.RichEdit.Lines.Add(outline);
     MReg2(NCases,NoVars,NoIndepVars,IndepIndex,corrs,IndepInverse,
          RowLabels,R2,BetaWeights,
          Means,Variances,errcnt,StdErrEst,constant,POut,true, true,false, OutputFrm.RichEdit.Lines);
     OutputFrm.ShowModal;
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
                 begin
                      if IndepIndex[j] = i then matched := true;
                 end;
                 if (matched = false) then
                 begin
                      k := k + 1;
                      Candidate[k-1] := i;
                 end;
            end;   { k is the no. of candidates }
            OutputFrm.RichEdit.Lines.Add('');
            OutputFrm.RichEdit.Lines.Add('Candidates for entry in next step.');
            OutputFrm.RichEdit.Lines.Add('Candidate  Partial  F Statistic  Prob.  DF1  DF2');
            LargestProb := 0.0;
            SmallestProb := 1.0;
            for k1 := 1 to k do
            begin
                 { get Mult Corr. with previously entered plus candidate }
                 IndepIndex[NoIndepVars] := Candidate[k1-1];
                 TempNoVars := NoIndepVars + 1;
                 MReg2(NCases,NoVars,TempNoVars,IndepIndex,corrs,IndepInverse,
                    RowLabels,NewR2,BetaWeights, Means,Variances,
                    errcnt, StdErrEst, constant, POut, false, false,false, OutputFrm.RichEdit.Lines);
                 Partial[k1-1] := (NewR2 - R2) / (1.0 - R2);
                 pdf1 := 1;
                 pdf2 := NCases - TempNoVars - 1;
                 PartF := ((NewR2 - R2) * pdf2) / (1.0 - NewR2);
                 PartProb := probf(PartF,pdf1,pdf2);
                 if PartProb < SmallestProb then SmallestProb := PartProb;
                 if PartProb > LargestProb then LargestProb := PartProb;
                 outline := format('%-10s  %6.4f   %7.4f    %6.4f   %3.0f  %3.0f',
                    [RowLabels[Candidate[k1-1]-1], sqrt(abs(Partial[k1-1])), PartF, PartProb, pdf1, pdf2]);
                 OutputFrm.RichEdit.Lines.Add(outline);
            end;

            if (SmallestProb > StrToFloat(InProb.Text)) then
            begin
                 OutputFrm.RichEdit.Lines.Add('No further steps meet criterion for entry.');
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

            outline := format('Variable %s will be added',[RowLabels[Index-1]]);
            OutputFrm.RichEdit.Lines.Add(outline);
            NoIndepVars := NoIndepVars + 1;
            IndepIndex[NoIndepVars-1] := Index;
            OutputFrm.RichEdit.Lines.Add('');
            outline := format('----------------- STEP %d ------------------',[StepNo]);
            OutputFrm.RichEdit.Lines.Add(outline);
            MReg2(NCases,NoVars,NoIndepVars,IndepIndex,corrs,IndepInverse,
                    RowLabels,R2,BetaWeights, Means,Variances,
                    errcnt, StdErrEst, constant,POut,true,true,false, OutputFrm.RichEdit.Lines);
            if (errcnt > 0) or (NoIndepVars = NoVars-1)  then { out tolerance exceeded - finish up }
lastone:    begin
                 OutputFrm.RichEdit.Lines.Add('');
                 OutputFrm.RichEdit.Lines.Add('-------------FINAL STEP-----------');
                 MReg2(NCases,NoVars,NoIndepVars,IndepIndex,corrs,IndepInverse,
                      RowLabels,NewR2,BetaWeights,Means,Variances,
                      errcnt,StdErrEst,constant,POut,true,false,false, OutputFrm.RichEdit.Lines);
                 k1 := NoIndepVars; { store temporarily }
                 NoIndepVars := NoVars; { this stops loop }
            end;
     end; { while not done }
     OutputFrm.ShowModal;

     NoIndepVars := k1;
     { add [predicted scores, residual scores, etc. to grid if options elected }
     if MatInChkBox.Checked = true then PredictChkBox.Checked := false;
     if PredictChkBox.Checked = true then
        Predict(ColNoSelected, NoVars, IndepInverse, Means, StdDevs,
                 BetaWeights, StdErrEst, IndepIndex, NoIndepVars);

CleanUp:
     ColNoSelected := nil;
     Candidate := nil;
     Partial := nil;
     BetaWeights := nil;
     IndColLabels := nil;
     IndRowLabels := nil;
     IndepIndex := nil;
     XYCorrs := nil;
     ColLabels := nil;
     RowLabels := nil;
     StdDevs := nil;
     Variances := nil;
     Means := nil;
     IndepInverse := nil;
     IndepCorrs := nil;
     corrs := nil;
end;

procedure TStepFwdFrm.DepInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := ListBox1.ItemIndex;
     DepVar.Text := ListBox1.Items.Strings[index];
     ListBox1.Items.Delete(index);
     DepOutBtn.Enabled := true;
     DepInBtn.Enabled := false;
end;

procedure TStepFwdFrm.DepOutBtnClick(Sender: TObject);
begin
     ListBox1.Items.Add(DepVar.Text);
     DepVar.Text := '';
     DepInBtn.Enabled := true;
end;

procedure TStepFwdFrm.InBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            ListBox1.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     OutBtn.Enabled := true;
end;

procedure TStepFwdFrm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
   index := ListBox1.ItemIndex;
   VarList.Items.Add(ListBox1.Items.Strings[index]);
   ListBox1.Items.Delete(index);
   InBtn.Enabled := true;
end;

initialization
  {$I stepfwdmrunit.lrs}

end.

