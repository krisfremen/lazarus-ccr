unit BackRegUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Math,
  Globals, MainDM, MainUnit, MatrixLib, OutputUnit, FunctionsLib, DataProcs;

type

  { TBackRegFrm }

  TBackRegFrm = class(TForm)
    Bevel1: TBevel;
    OpenDialog1: TOpenDialog;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    MatInChkBox: TCheckBox;
    MatSaveChkBox: TCheckBox;
    CPChkBox: TCheckBox;
    CovChkBox: TCheckBox;
    CorrsChkBox: TCheckBox;
    MeansChkBox: TCheckBox;
    SaveDialog1: TSaveDialog;
    VarChkBox: TCheckBox;
    SDChkBox: TCheckBox;
    PartialsChkBox: TCheckBox;
    DepVar: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
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
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  BackRegFrm: TBackRegFrm;

implementation

{ TBackRegFrm }

procedure TBackRegFrm.ResetBtnClick(Sender: TObject);
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
     CPChkBox.Checked := false;
     CovChkBox.Checked := false;
     CorrsChkBox.Checked := true;
     MeansChkBox.Checked := true;
     VarChkBox.Checked := false;
     SDChkBox.Checked := true;
     MatInChkBox.Checked := false;
     MatSaveChkBox.Checked := false;
     PartialsChkBox.Checked := false;
     DepVar.Text := '';
     DepInBtn.Enabled := true;
     DepOutBtn.Enabled := false;
end;

procedure TBackRegFrm.ReturnBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TBackRegFrm.FormActivate(Sender: TObject);
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

procedure TBackRegFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TBackRegFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TBackRegFrm.AllBtnClick(Sender: TObject);
VAR count, index : integer;
begin
     count := VarList.Items.Count;
     for index := 0 to count-1 do
     begin
          ListBox1.Items.Add(VarList.Items.Strings[index]);
     end;
     VarList.Clear;
end;

procedure TBackRegFrm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TBackRegFrm.ComputeBtnClick(Sender: TObject);
Label CleanUp;
VAR
   NoVars, NoIndepVars, i, j, NCases, StepNo : integer;
   Index: integer;
   R2, determinant, stderrest, POut, LowestPartial : double;
   errorcode : integer;
   errcode : boolean;
   filename : string;
   cellstring, outline: string;
   Corrs : DblDyneMat;
   Means : DblDyneVec;
   Variances : DblDyneVec;
   StdDevs : DblDyneVec;
   ColNoSelected : IntDyneVec;
   title : string;
   RowLabels : StrDyneVec;
   ColLabels : StrDyneVec;
   InverseMat : DblDyneMat;
   ProdMat : DblDyneMat;
   CorrMat : DblDyneMat;
   BetaWeights : DblDyneVec;
   IndepIndex : IntDyneVec;
   constant : double;
begin
     if NoVariables = 0 then NoVariables := 200;
     SetLength(Corrs,NoVariables+1,NoVariables+1);
     SetLength(Means,NoVariables);
     SetLength(Variances,NoVariables);
     SetLength(StdDevs,NoVariables);
     SetLength(RowLabels,NoVariables);
     SetLength(ColLabels,NoVariables);
     SetLength(InverseMat,NoVariables+1,NoVariables+1);
     SetLength(ProdMat,NoVariables+1,NoVariables+1);
     SetLength(CorrMat,NoVariables+1,NoVariables+1);
     SetLength(BetaWeights,NoVariables);
     SetLength(IndepIndex,NoVariables);
     SetLength(ColNoSelected,NoVariables);

     OutputFrm.RichEdit.Clear;
//     OutputFrm.RichEdit.ParaGraph.Alignment := taLeftJustify;
     OutputFrm.RichEdit.Lines.Add('Step Backward Multiple Regression by Bill Miller');
     errcode := false;
     errorcode := 0;
     if MatInChkBox.Checked = true then
     begin
          OpenDialog1.Filter := 'FreeStat matrix files (*.MAT)|*.MAT|All files (*.*)|*.*';
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
               CPChkBox.Checked := false;
               CovChkBox.Checked := false;
               MatSaveChkBox.Checked := false;
               ShowMessage('NOTICE! Last variable in matrix is the dependent variable');
          end;
     end;
     if MatInChkBox.Checked = false then
     begin
          { get variable columns }
          NoVars := ListBox1.Items.Count;
          if NoVars < 1 then
          begin
               ShowMessage('ERROR! No variables selected.');
               goto CleanUp;
          end;
          for i := 1 to NoVars do
          begin
               cellstring := ListBox1.Items.Strings[i-1];
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
     end;
     POut := 1.0;
     StepNo := 1;
     while NoVars > 1 do
     begin
          OutputFrm.RichEdit.Lines.Add('');
          outline := format('----------------- STEP %3d ------------------',[StepNo]);
          OutputFrm.RichEdit.Lines.Add(outline);
          if CPChkBox.Checked = true then
          begin
               title := 'Cross-Products Matrix';
               GridXProd(NoVars,ColNoSelected,Corrs,errcode,NCases);
               MAT_PRINT(Corrs,NoVars,NoVars,title,RowLabels,ColLabels,NCases);
          end;
          if CovChkBox.Checked = true then
          begin
               title := 'Variance-Covariance Matrix';
               GridCovar(NoVars,ColNoSelected,Corrs,Means,Variances,
                      StdDevs,errcode,NCases);
               MAT_PRINT(Corrs,NoVars,NoVars,title,RowLabels,ColLabels,NCases);
          end;
          if MatInChkBox.Checked = false then
               Correlations(NoVars,ColNoSelected,Corrs,Means,Variances,
                    StdDevs,errcode,NCases);
          if CorrsChkBox.Checked = true then
          begin
               title := 'Product-Moment Correlations Matrix';
               MAT_PRINT(Corrs,NoVars,NoVars,title,RowLabels,ColLabels,NCases);
          end;
          if MatSaveChkBox.Checked = true then
          begin
               SaveDialog1.Filter := 'FreeStat matrix files (*.MAT)|*.MAT|All files (*.*)|*.*';
               SaveDialog1.FilterIndex := 1;
               if SaveDialog1.Execute then
               begin
                    filename := SaveDialog1.FileName;
                    MATSAVE(Corrs,NoVars,NoVars,Means,StdDevs,NCases,RowLabels,ColLabels,filename);
               end;
               MatSaveChkBox.Checked := false; // only save first one
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
          if errorcode > 0 then
          begin
               ShowMessage('ERROR! A selected variable has no variability-run aborted.');
               goto CleanUp;
          end;

          { get determinant of the correlation matrix }
          determinant := 0.0;
          for i := 1 to NoVars do
              for j := 1 to NoVars do
                  CorrMat[i-1,j-1] := Corrs[i-1,j-1];
          Determ(CorrMat,NoVars,NoVars,determinant,errcode);
          if (determinant < 0.000001) then
          begin
               ShowMessage('ERROR! Matrix is singular!');
//               goto cleanup;
          end;
          outline := format('Determinant of correlation matrix = %8.4f',[determinant]);
          OutputFrm.RichEdit.Lines.Add(outline);
          OutputFrm.RichEdit.Lines.Add('');
         NoIndepVars := NoVars-1;
          for i := 1 to NoIndepVars do IndepIndex[i-1] := i;
          MReg2(NCases,NoVars,NoIndepVars,IndepIndex,corrs,InverseMat,
               RowLabels,R2,BetaWeights,
               Means,Variances,errorcode,StdErrEst,constant,POut,true, false,false, OutputFrm.RichEdit.Lines);
        // Get partial correlation matrix
         for i := 1 to NoVars do
              for j := 1 to NoVars do
                   InverseMat[i-1,j-1] := Corrs[i-1,j-1];
         SVDinverse(InverseMat,NoVars);
         for i := 1 to NoVars do
         begin
    	      for j := 1 to NoVars do
              begin
                   ProdMat[i-1,j-1] := -(1.0 / sqrt(InverseMat[i-1,i-1])) *
            	   InverseMat[i-1,j-1] * (1.0 / sqrt(InverseMat[j-1,j-1]));
              end;
         end;
         LowestPartial := 1.0;
         Index := NoIndepVars;
         for i := 1 to NoIndepVars do
         begin
              BetaWeights[i-1] := ProdMat[i-1,NoVars-1];
              if abs(BetaWeights[i-1]) < LowestPartial then
              begin
                   LowestPartial := abs(BetaWeights[i-1]);
                   Index := i;
              end;
        end;
         if PartialsChkBox.Checked = true then
         begin
              title := 'Partial Correlations';
              DynVectorPrint(BetaWeights,NoIndepVars,title,ColLabels,NCases);
         end;
         OutputFrm.ShowModal;

         { eliminate variable with lowest partial }
         if NoVars > 2 then
         begin
              outline := format('Variable %d (%s) eliminated',[Index,ColLabels[Index-1]]);
              OutputFrm.RichEdit.Lines.Add(outline);
              for i := Index to NoVars-1 do
              begin
                   ColNoSelected[i-1] := ColNoSelected[i];
                   ColLabels[i-1] := ColLabels[i];
                   RowLabels[i-1] := RowLabels[i];
              end;
              NoVars := NoVars - 1;
              StepNo := StepNo + 1;
         end
         else NoVars := 0;
     end;
     OutputFrm.ShowModal;

CleanUp:
     ColNoSelected := nil;
     IndepIndex := nil;
     BetaWeights := nil;
     CorrMat := nil;
     ProdMat := nil;
     InverseMat := nil;
     ColLabels := nil;
     RowLabels := nil;
     StdDevs := nil;
     Variances := nil;
     Means := nil;
     Corrs := nil;
     Close;
end;

procedure TBackRegFrm.DepInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := ListBox1.ItemIndex;
     DepVar.Text := ListBox1.Items.Strings[index];
     ListBox1.Items.Delete(index);
     DepOutBtn.Enabled := true;
     DepInBtn.Enabled := false;
end;

procedure TBackRegFrm.DepOutBtnClick(Sender: TObject);
begin
     ListBox1.Items.Add(DepVar.Text);
     DepVar.Text := '';
     DepInBtn.Enabled := true;
end;

procedure TBackRegFrm.InBtnClick(Sender: TObject);
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

procedure TBackRegFrm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
   index := ListBox1.ItemIndex;
   VarList.Items.Add(ListBox1.Items.Strings[index]);
   ListBox1.Items.Delete(index);
   InBtn.Enabled := true;
end;

initialization
  {$I backregunit.lrs}

end.

