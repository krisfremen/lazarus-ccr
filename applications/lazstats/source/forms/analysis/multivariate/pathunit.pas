// Sample file for testing: cansas.laz,
// all variables to center list, 
//   waist --> caused variables
//   weight --> causing variables

unit PathUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, Globals, MatrixLib, DataProcs;

type

  { TPathFrm }

  TPathFrm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    SaveDialog1: TSaveDialog;
    StatsChk: TCheckBox;
    ModelChk: TCheckBox;
    Reprochk: TCheckBox;
    SaveChk: TCheckBox;
    GroupBox1: TGroupBox;
    ResetModelBtn: TButton;
    CausedInBtn: TBitBtn;
    CausedOutBtn: TBitBtn;
    CausingInBtn: TBitBtn;
    CausingOutBtn: TBitBtn;
    CausedEdit: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    CausingList: TListBox;
    ModelNo: TEdit;
    InBtn: TBitBtn;
    Label3: TLabel;
    OutBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    VarList: TListBox;
    ScrollBar: TScrollBar;
    ListBox1: TListBox;
    procedure CausedInBtnClick(Sender: TObject);
    procedure CausedOutBtnClick(Sender: TObject);
    procedure CausingInBtnClick(Sender: TObject);
    procedure CausingOutBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure ResetModelBtnClick(Sender: TObject);
    procedure ScrollBarChange(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    Model: integer;
    ModelDefined: BoolDyneVec;
    causedseq: IntDyneVec;
    nocausing: IntDyneVec;
    causingseq: IntDyneMat;
    NoModels: integer;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  PathFrm: TPathFrm;

implementation

uses
  Math, Utils;

{ TPathFrm }

procedure TPathFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  SetLength(causingseq,NoVariables,NoVariables);
  SetLength(ModelDefined,NoVariables);
  SetLength(nocausing,NoVariables);
  SetLength(causedseq,NoVariables);
  ListBox1.Clear;
  CausingList.Clear;
  VarList.Clear;
  ModelNo.Text := '1';
  ScrollBar.Position := 1;
  CausedEdit.Text := '';
  StatsChk.Checked := true;
  ModelChk.Checked := true;
  ReproChk.Checked := true;
  SaveChk.Checked := false;
  NoModels := 0;
  for i := 1 to NoVariables do
    ListBox1.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  for i := 1 to NoVariables do
    ModelDefined[i-1] := false;
  UpdateBtnStates;
end;

procedure TPathFrm.ResetModelBtnClick(Sender: TObject);
var
  i: integer;
begin
  Model := ScrollBar.Position;
  if CausedEdit.Text <> '' then CausedOutBtnClick(self);
  if CausingList.Items.Count > 0 then CausingList.Clear;
  causedseq[Model-1] := 0;
  nocausing[Model-1] := 0;
  for i := 1 to nocausing[Model-1] do causingseq[Model-1,i-1] := 0;
  ModelDefined[Model-1] := false;
end;

procedure TPathFrm.ScrollBarChange(Sender: TObject);
var
   i, j, col : integer;
   cellstring : string;
begin
     ScrollBar.Max := NoVariables + 1;
     if ScrollBar.Position > NoVariables then
     begin
          ScrollBar.Position := NoVariables;
          exit;
     end;
     if ScrollBar.Position > NoModels then
     begin
          if (CausedEdit.Text <> '') and (CausingList.Items.Count > 0) then
          begin // save model information
               Model := ScrollBar.Position - 1;
               ModelDefined[Model-1] := true;
               nocausing[Model-1] := CausingList.Items.Count;
               NoModels := NoModels + 1;
               for i := 1 to NoVariables do
               begin
                    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
                    if cellstring = CausedEdit.Text then causedseq[Model-1] := i;
                    for j := 0 to CausingList.Items.Count - 1 do
                    begin
                         if cellstring = CausingList.Items.Strings[j] then
                            causingseq[Model-1,j] := i;
                    end;
               end;
               CausingList.Clear;
               CausedEdit.Text := '';
               CausedInBtn.Enabled := true;
               CausedOutBtn.Enabled := false;
               CausingInBtn.Enabled := true;
               CausingOutBtn.Enabled := false;
          end;
     end;

     if ScrollBar.Position <> Model then
     begin
          CausingList.Clear;
          ModelNo.Text := IntToStr(ScrollBar.Position);
          Model := ScrollBar.Position;
          CausedEdit.Text := '';
          if ModelDefined[Model-1] then // model exists - reload data
          begin
               col := causedseq[Model-1];
               if col <> 0 then
               begin
                  CausedEdit.Text := OS3MainFrm.DataGrid.Cells[col,0];
                  CausingList.Clear;
               end
               else
               begin
                    CausedEdit.Text := '';
                    CausingList.Clear;
                    exit;
               end;
               for i := 1 to nocausing[Model-1] do
               begin
                    col := causingseq[Model-1,i-1];
                    cellstring := OS3MainFrm.DataGrid.Cells[col,0];
                    CausingList.Items.Add(cellstring);
               end;
          end;
     end;
end;

procedure TPathFrm.FormActivate(Sender: TObject);
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

procedure TPathFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TPathFrm.FormShow(Sender: TObject);
begin
  causedseq := nil;
  nocausing := nil;
  causingseq := nil;
  ModelDefined := nil;
  ResetBtnClick(self);
end;

procedure TPathFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < ListBox1.Items.Count do
  begin
    if ListBox1.Selected[i] then
    begin
      VarList.Items.Add(ListBox1.Items[i]);
      ListBox1.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TPathFrm.ListBox1SelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TPathFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      ListBox1.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

         (*
VAR index : integer;
begin
     index := VarList.ItemIndex;
     if index < 0 then
     begin
          OutBtn.Enabled := false;
          exit;
     end;
     VarList.Items.Delete(index);
end;       *)

procedure TPathFrm.CausedInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (CausedEdit.Text = '') then
  begin
    CausedEdit.Text := VarList.Items[index];
    CausedOutBtn.Enabled := true;
    CausedInBtn.Enabled := false;
  end;
  UpdateBtnStates;
end;

procedure TPathFrm.CausedOutBtnClick(Sender: TObject);
begin
  if CausedEdit.Text <> '' then
    CausedEdit.Text := '';
  UpdateBtnStates;
end;

procedure TPathFrm.CausingInBtnClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to VarList.Items.Count-1 do
  begin
    if VarList.Selected[i] then
      CausingList.Items.Add(VarList.Items[i]);
  end;
  UpdateBtnStates;
end;

procedure TPathFrm.CausingOutBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := CausingList.ItemIndex;
  if index > -1 then
    CausingList.Items.Delete(index);
  UpdateBtnStates;
end;

procedure TPathFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k, col, row, NoVars, nocaused, NoSelected, NoIndepVars : integer;
   count, IER, noexogenous, L: integer;
   constant, StdErrEst, ProbOut, R2, d2, sum, absdiff : double;
   cellstring: string;
   ColNoSelected, selected : IntDyneVec;
   IndepIndex : IntDyneVec;
   rmat, WorkMat, PathCoef, IndMatrix, e, W : DblDyneMat;
   means, variances, stddevs, beta, p : DblDyneVec;
   zvals : DblDyneMat; // z scores for path model
   genedz : IntDyneVec; // list of z's created for path models
   causal : IntDyneMat;
   exogenous : IntDyneVec;
   RowLabels, ColLabels, Labels: StrDyneVec;
   title : string;
   matched : boolean;
   prtopt : boolean;
   errorcode : boolean = false;
   done : boolean;
   zscore : double;
   lReport: TStrings;
begin
   if CausedEdit.Text = '' then
   begin
     MessageDlg('No "Caused" variable selected.', mtError, [mbOK], 0);
     exit;
   end;

   if CausingList.Items.Count = 0 then
   begin
     MessageDlg('No "Causing" variable(s) selected.',mtError, [mbOK], 0);
     exit;
   end;

   if NoModels < ScrollBar.Position then
   begin
     Model := ScrollBar.Position;
     ModelDefined[Model-1] := true;
     nocausing[Model-1] := CausingList.Items.Count;
     NoModels := NoModels + 1;
     for i := 1 to NoVariables do
     begin
       cellstring := OS3MainFrm.DataGrid.Cells[i,0];
       if cellstring = CausedEdit.Text then causedseq[Model-1] := i;
       for j := 0 to CausingList.Items.Count - 1 do
       begin
         if cellstring = CausingList.Items.Strings[j] then
           causingseq[Model-1,j] := i;
       end;
     end;
     CausingList.Clear;
     CausedEdit.Text := '';
     CausedInBtn.Enabled := true;
     CausedOutBtn.Enabled := false;
     CausingInBtn.Enabled := true;
     CausingOutBtn.Enabled := false;
   end;

   nocaused := NoModels;
   SetLength(rmat,NoVariables+1,NoVariables+1);
   SetLength(WorkMat,NoVariables+1,NoVariables+1);
   SetLength(PathCoef,NoVariables,NoVariables);
   SetLength(IndMatrix,NoVariables,NoVariables);
   SetLength(e,NoVariables,NoVariables);
   SetLength(W,NoVariables,NoVariables);
   SetLength(means,NoVariables);
   SetLength(variances,NoVariables);
   SetLength(stddevs,NoVariables);
   SetLength(beta,NoVariables);
   SetLength(p,NoVariables*NoVariables);
   SetLength(Causal,2,NoVariables*NoVariables);
   SetLength(RowLabels,NoCases);
   SetLength(ColLabels,NoVariables);
   SetLength(Labels,NoVariables);
   SetLength(IndepIndex,NoVariables);
   SetLength(exogenous,NoVariables);
   SetLength(ColNoSelected,NoVariables);
   SetLength(selected,NoVariables);
   SetLength(zvals,NoCases,NoVariables);
   SetLength(genedz,NoVariables);

   // get and show model parameters
   lReport := TStringList.Create;
   try
     lReport.Add('PATH ANALYSIS RESULTS');
     lReport.Add('');

     for i := 1 to nocaused do
     begin
       col := causedseq[i-1];
       lReport.Add('CAUSED VARIABLE: ' + OS3MainFrm.DataGrid.Cells[col,0]);
       lReport.Add('     Causing Variables:');
       for j := 1 to nocausing[i-1] do
       begin
         col := causingseq[i-1,j-1];
         lReport.Add('    ' + OS3MainFrm.DataGrid.Cells[col,0]);
       end;
     end;
     lReport.Add('');
     lReport.Add(DIVIDER);
     lReport.Add('');

     // get correlations among all variables selected for the analysis
     NoSelected := VarList.Items.Count;
     for j := 1 to NoVariables do
     begin
       cellstring := OS3MainFrm.DataGrid.Cells[j,0];
       for i := 1 to NoSelected do
       begin
         if cellstring = VarList.Items.Strings[i-1] then
         begin
           ColNoSelected[i-1] := j;
           RowLabels[i-1] := cellstring;
         end;
       end;
     end;

     count := NoCases;
     Correlations(NoSelected,ColNoSelected,rmat,means,variances,stddevs, errorcode,count);
     if SaveChk.Checked then
     begin
       SaveDialog1.Filter := 'Matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
       SaveDialog1.FilterIndex := 1;
       if SaveDialog1.Execute then
         MatSave(rmat, NoSelected, NoSelected, means, stddevs, count, RowLabels, RowLabels,SaveDialog1.FileName);
     end;

     if StatsChk.Checked then
     begin
       title := 'Correlation Matrix';
       MatPrint(rmat, NoSelected, NoSelected, title, RowLabels, RowLabels, count, lReport);

       title := 'MEANS';
       DynVectorPrint(means, NoSelected, title, RowLabels, count, lReport);

       title := 'VARIANCES';
       DynVectorPrint(variances, NoSelected, title, RowLabels, count, lReport);

       title := 'STANDARD DEVIATIONS';
       DynVectorPrint(stddevs, NoSelected, title, RowLabels, count, lReport);

       lReport.Add(DIVIDER);
       lReport.Add('');
     end;

     // initialize reconstruction matrix, weights matrix and path coefficients
     for i := 0 to NoSelected-1 do
     begin
       for j := 0 to NoSelected-1 do
       begin
         e[i,j] := 0.0;
         W[i,j] := 0.0;
         PathCoef[i,j] := 0.0;
       end;
     end;

     //Now, do the regression analysis for each model
     for i := 1 to nocaused do
     begin
       NoVars := nocausing[i-1] + 1;
       for j := 1 to nocausing[i-1] do
       begin
         col := causingseq[i-1,j-1];
         IndepIndex[j-1] := j; // independents
         selected[j-1] := col;
         Labels[j-1] := OS3MainFrm.DataGrid.Cells[col,0];
       end;
       row := causedseq[i-1]; //sequence no. of caused variable
       IndepIndex[NoVars-1] := row; // dependent
       selected[NoVars-1] := row;
       Labels[NoVars-1] := OS3MainFrm.DataGrid.Cells[row,0];

       // get correlation matrix for this model
       Correlations(NoVars, selected, WorkMat, means, variances, stddevs, errorcode, count);
       if ModelChk.Checked then
       begin
         lReport.Add('Dependent Variable: %s', [OS3MainFrm.DataGrid.Cells[row,0]]);
         lReport.Add('');
         title := 'Correlation Matrix';
         MatPrint(WorkMat, NoVars, NoVars, title, Labels, Labels, count, lReport);

         title := 'MEANS';
         DynVectorPrint(means, NoVars, title, Labels, count, lReport);

         title := 'VARIANCES';
         DynVectorPrint(variances, NoVars, title, Labels, count, lReport);

         title := 'STANDARD DEVIATIONS';
         DynVectorPrint(stddevs, NoVars, title, Labels, count, lReport);

         lReport.Add(DIVIDER);
         lReport.Add('');
       end;

       // Get regression analysis for this model
       ProbOut := 0.999;
       NoIndepVars := NoVars - 1;
       if StatsChk.Checked then
       begin
         lReport.Add('Dependent Variable: %s', [OS3MainFrm.DataGrid.Cells[row,0]]);
         lReport.Add('');
       end;

       prtopt := StatsChk.Checked;

       MReg2(count, NoVars, NoIndepVars, IndepIndex, WorkMat, IndMatrix,
             Labels, R2, beta, means, variances, IER, StdErrEst, constant,
             ProbOut, prtopt, false, false, lReport);

       if prtopt then
       begin
         lReport.Add('');
         lReport.Add(DIVIDER);
         lReport.Add('');
       end;

       for j := 1 to nocausing[i-1] do
       begin
         col := causingseq[i-1,j-1];
         PathCoef[row-1,col-1] := beta[j-1];
       end;
     end; // next i (caused regressions)

     //Now, reconstruct the correlation matrix from path coefficients
     //First, obtain list of exogenous variables
     noexogenous := 0;
     for i := 1 to NoSelected do
     begin
       matched := false;
       col := ColNoSelected[i-1];
       for j := 1 to nocaused do
         if (causedseq[j-1] = col) then matched := true;
       if not matched then
       begin
         exogenous[noexogenous] := col;
         noexogenous := noexogenous + 1;
       end;
     end;

     // transform raw scores to z scores for exogenous variables
     Correlations(NoSelected, ColNoSelected, rmat, means, variances, stddevs, errorcode, count);

     for i := 1 to noselected do
       genedz[i-1] := 0; // initialize
     for k := 1 to noexogenous do
     begin
       col := exogenous[k-1];
       // find position of corresponding mean and std.dev.
       for j := 1 to noselected do
         if ColNoSelected[j-1] = col then row := j;
       for i := 1 to NoCases do
       begin
         zvals[i-1,col-1] := StrToFloat(OS3MainFrm.DataGrid.Cells[col,i]);
         zvals[i-1,col-1] := (zvals[i-1,col-1] - means[row-1]) / stddevs[row-1];
         RowLabels[i-1] := format('Subject %d',[i]);
       end;
       genedz[col-1] := 1; // mark as generated
     end;
{
     // print matrix of path z scores for exogenous variables
     title := 'Data Array of Subject exogenous z Scores';
     MAT_PRINT(zvals,NoCases,NoSelected,title,RowLabels,ColLabels,NoCases);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
}

     for i := 1 to NoVariables do
     begin
       cellstring := OS3MainFrm.DataGrid.Cells[i,0];
       for j := 1 to NoSelected do
       begin
         if cellstring = VarList.Items.Strings[j-1] then
         begin
           RowLabels[i-1] := cellstring;
           ColLabels[i-1] := cellstring;
         end;
       end;
     end;

     //Build matrix of path coefficients
     for i := 1 to nocaused do
     begin
       row := causedseq[i-1];
       for j := 1 to nocausing[i-1] do
       begin
         col := causingseq[i-1,j-1];
         W[row-1,col-1] := PathCoef[row-1,col-1];
       end;
     end;

     //Print results
     if StatsChk.Checked then
     begin
       title := 'Matrix of Path Coefficients in Rows';
       MatPrint(W, NoSelected, NoSelected, title, ColLabels, ColLabels, count, lReport);
       lReport.Add(DIVIDER);
       lReport.Add('');
    end;

     //Build models vectors
     k := 0;
     for i := 1 to nocaused do
     begin
       for j := 1 to nocausing[i-1] do
       begin
         k := k + 1;
         causal[0,k-1] := causedseq[i-1];
         causal[1,k-1] := causingseq[i-1,j-1];
         row := causedseq[i-1];
         col := causingseq[i-1,j-1];
         p[k-1] := PathCoef[row-1,col-1];
       end;
     end;
     NoModels := k;

     //Sort on resultant then causing variables
     for i := 1 to NoModels - 1 do
     begin
       for j := i + 1 to NoModels do
       begin
         if (causal[0,i-1] > causal[0,j-1]) then // swap
         begin
           Exchange(causal[0, i-1], causal[0, j-1]);
           {
           t := causal[0,i-1];
           causal[0,i-1] := causal[0,j-1];
           causal[0,j-1] := t;
           }
           Exchange(causal[1, i-1], causal[1, j-1]);
           {
           t := causal[1,i-1];
           causal[1,i-1] := causal[1,j-1];
           causal[1,j-1] := t;
           }
           Exchange(p[i-1], p[j-1]);
           {
           Temp := p[i-1];
           p[i-1] := p[j-1];
           p[j-1] := Temp;
           }
         end;
       end;
     end;
     for i := 1 to NoModels - 1 do
     begin
       for j := i + 1 to NoModels do
       begin
         if ((causal[0,i-1] = causal[0,j-1]) and (causal[1,i-1] > causal[1,j-1])) then
         begin
           Exchange(causal[0, i-1], causal[0, j-1]);
           {
           t := causal[0,i-1];
           causal[0,i-1] := causal[0,j-1];
           causal[0,j-1] := t;
           }
           Exchange(causal[1, i-1], causal[1, j-1]);
           {
                t := causal[1,i-1];
                causal[1,i-1] := causal[1,j-1];
                causal[1,j-1] := t;
           }
           Exchange(p[i-1], p[j-1]);
           {
                Temp := p[i-1];
                p[i-1] := p[j-1];
                p[j-1] := Temp;
           }
         end;
       end;
     end;

     lReport.Add('SUMMARY OF CAUSAL MODELS');
     lReport.Add('Var. Caused    Causing Var.   Path Coefficient');
     lReport.Add('------------   ------------   ----------------');

     for i := 1 to NoModels do
        lReport.Add('%12s   %12s   %12.3f', [
          OS3MainFrm.DataGrid.Cells[causal[0,i-1],0],
          OS3MainFrm.DataGrid.Cells[causal[1,i-1],0],
          p[i-1]
        ]);
     lReport.Add('');
     lReport.Add(DIVIDER);
     lReport.Add('');

     //Get reproduced correlation matrix in e
     done := false;
     while not done do
     begin
       for i := 1 to nocaused do // check each caused for use of existing z values
       begin
         for j := 1 to nocausing[i-1] do
         begin
           count := 0;
           for L := 1 to noselected do
             if genedz[L-1] = 1 then count := count + 1;
         end;
         if count >= nocausing[i-1] then // calculate path z
         begin
           row := causedseq[i-1]; // generation z column & row of path coef.
           for j := 1 to nocausing[i-1] do
           begin  // sum of Path coefficients times corresponding z's
             col := causingseq[i-1,j-1]; // column of path coefficient
             for k := 1 to NoCases do
             begin
               zscore := zvals[k-1,col-1]; // causing z score
               zvals[k-1,row-1] := zvals[k-1,row-1] + zscore * PathCoef[row-1,col-1];
             end;
           end;
           genedz[row-1] := 1; // mark as generated
         end; // if count equals no. of causing variables

         count := 0; // check for completion of all z's
         for j := 1 to noselected do
           if genedz[j-1] = 1 then count := count + 1;
         if count = noselected then done := true;
       end; // next i caused variable
     end; // while not done

     // print matrix of path z scores
     for i := 1 to NoCases do RowLabels[i-1] := Format('Subject %d',[i]);
     title := 'Data Array of Subject Path z Scores';
     MatPrint(zvals, NoCases, NoSelected, title, RowLabels, ColLabels, NoCases, lReport);
     lReport.Add(DIVIDER);
     lReport.Add('');

     // now calculate the correlation among the generated z values
     for i := 1 to noselected do
     begin // initialize arrays
       for j := 1 to noselected do
         e[i-1,j-1] := 0.0;
       means[i-1] := 0.0;
       stddevs[i-1] := 0.0;
     end;
     for k := 1 to NoCases do
     begin
       for i := 1 to noselected do
       begin
         for j := 1 to noselected do
           e[i-1,j-1] := e[i-1,j-1] + zvals[k-1,i-1] * zvals[k-1,j-1];
         means[i-1] := means[i-1] + zvals[k-1,i-1];
         stddevs[i-1] := stddevs[i-1] + (zvals[k-1,i-1] * zvals[k-1,i-1]);
       end;
     end;
     for i := 1 to noselected do
     begin
       stddevs[i-1] := stddevs[i-1] - (means[i-1] * means[i-1] / NoCases);
       stddevs[i-1] := stddevs[i-1] / (NoCases - 1);
       stddevs[i-1] := sqrt(stddevs[i-1]);
       for j := 1 to noselected do
       begin // covariances
         e[i-1,j-1] := e[i-1,j-1] - (means[i-1] * means[j-1] / NoCases);
         e[i-1,j-1] := e[i-1,j-1] / (NoCases - 1);
       end;
       means[i-1] := means[i-1] / NoCases;
     end;
     for i := 1 to noselected do
     begin
       for j := 1 to noselected do
         e[i-1,j-1] := e[i-1,j-1] / (stddevs[i-1]*stddevs[j-1]);
     end;

     if ReproChk.Checked then
     begin
       title := 'Reproduced Correlation Matrix';
       MatPrint(e, NoSelected, NoSelected, title, ColLabels, ColLabels, count, lReport);
     end;

     //Examine discrepencies
     d2 := 0.0;
     sum := 0.0;
     for i := 1 to NoSelected do
     begin
       for j := 1 to NoSelected do
       begin
         absdiff := abs(rmat[i-1,j-1] - e[i-1,j-1]);
         sum := sum + absdiff;
         if (absdiff > d2) then d2 := absdiff;
       end;
     end;

     lReport.Add('Average absolute difference between observed and reproduced');
     lReport.Add('Coefficients:             %5.3f', [sum / (NoSelected * NoSelected)]);
     lReport.Add('Maximum difference found: %5.3f', [d2]);

     DisplayReport(lReport);

   finally
     lReport.Free;
     genedz := nil;
     zvals := nil;
     selected := nil;
     ColNoSelected := nil;
     exogenous := nil;
     IndepIndex := nil;
     Labels := nil;
     ColLabels := nil;
     RowLabels := nil;
     Causal := nil;
     p := nil;
     beta := nil;
     stddevs := nil;
     variances := nil;
     means := nil;
     W := nil;
     e := nil;
     IndMatrix := nil;
     PathCoef := nil;
     WorkMat := nil;
     rmat := nil;
   end;
end;

procedure TPathFrm.UpdateBtnStates;
var
  varSelected: Boolean;
begin
  varSelected := AnySelected(VarList);
  InBtn.Enabled := AnySelected(ListBox1);
  OutBtn.Enabled := varSelected;
  CausedInBtn.Enabled := varSelected and (CausedEdit.Text = '');
  CausedOutBtn.Enabled := (CausedEdit.Text <> '');
  CausingInBtn.Enabled := varSelected;
  CausingOutBtn.Enabled := AnySelected(CausingList);
end;

initialization
  {$I pathunit.lrs}

end.

