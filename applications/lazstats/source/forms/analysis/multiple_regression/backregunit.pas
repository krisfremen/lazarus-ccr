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
    ComputeBtn: TButton;
    CloseBtn: TButton;
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
    SelList: TListBox;
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
    procedure CloseBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  BackRegFrm: TBackRegFrm;

implementation

{ TBackRegFrm }

procedure TBackRegFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  SelList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);

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
end;

procedure TBackRegFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TBackRegFrm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TBackRegFrm.FormActivate(Sender: TObject);
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

procedure TBackRegFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TBackRegFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TBackRegFrm.AllBtnClick(Sender: TObject);
var
  index: integer;
begin
  for index := 0 to VarList.Items.Count-1 do
    SelList.Items.Add(VarList.Items.Strings[index]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TBackRegFrm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TBackRegFrm.ComputeBtnClick(Sender: TObject);
var
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
   lReport: TStrings;
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

     lReport := TStringList.Create;
     try
       lReport.Add('STEP BACKWARD MULTIPLE REGRESSION by Bill Miller');
       errcode := false;
       errorcode := 0;

       if MatInChkBox.Checked then
       begin
          OpenDialog1.Filter := 'LazStats matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
          OpenDialog1.FilterIndex := 1;
          if OpenDialog1.Execute then
          begin
               filename := OpenDialog1.FileName;
               MatRead(Corrs, NoVars, NoVars, Means, StdDevs, NCases, RowLabels, ColLabels, filename);
               for i := 0 to NoVars-1 do
               begin
                    Variances[i] := sqr(StdDevs[i]);
                    ColNoSelected[i] := i+1;
               end;
               DepVar.Text := RowLabels[NoVars-1];
               for i := 0 to NoVars-2 do SelList.Items.Add(RowLabels[i]);
               CPChkBox.Checked := false;
               CovChkBox.Checked := false;
               MatSaveChkBox.Checked := false;
               MessageDlg('Last variable in matrix is the dependent variable.', mtInformation, [mbOK], 0);
          end;
       end;

       if not MatInChkBox.Checked then
       begin
          { get variable columns }
          NoVars := SelList.Items.Count;
          if NoVars < 1 then
          begin
               MessageDlg('No variables selected.', mtError, [mbOK], 0);
               exit;
          end;
          for i := 1 to NoVars do
          begin
               cellstring := SelList.Items[i-1];
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
               MessageDlg('No Dependent variable selected.', mtError, [mbOK], 0);
               exit;
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
          if StepNo > 1 then
            lReport.Add('');
          lReport.Add('');
          lReport.Add('----------------- STEP %3d ------------------', [StepNo]);
          if CPChkBox.Checked then
          begin
               title := 'Cross-Products Matrix';
               GridXProd(NoVars, ColNoSelected, Corrs, errcode, NCases);
               MatPrint(Corrs, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
          end;
          if CovChkBox.Checked then
          begin
               title := 'Variance-Covariance Matrix';
               GridCovar(NoVars, ColNoSelected, Corrs, Means, Variances, StdDevs, errcode, NCases);
               MatPrint(Corrs, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
          end;
          if not MatInChkBox.Checked then
               Correlations(NoVars, ColNoSelected, Corrs, Means, Variances, StdDevs, errcode, NCases);
          if CorrsChkBox.Checked then
          begin
               title := 'Product-Moment Correlations Matrix';
               MatPrint(Corrs, NoVars, NoVars, title, RowLabels, ColLabels, NCases, lReport);
          end;
          if MatSaveChkBox.Checked then
          begin
               SaveDialog1.Filter := 'LazStats matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
               SaveDialog1.FilterIndex := 1;
               if SaveDialog1.Execute then
               begin
                    filename := SaveDialog1.FileName;
                    MatSave(Corrs, NoVars, NoVars, Means, StdDevs, NCases, RowLabels, ColLabels, filename);
               end;
               MatSaveChkBox.Checked := false; // only save first one
          end;
          if MeansChkBox.Checked then
          begin
            title := 'Means';
            DynVectorPrint(Means, NoVars, title, ColLabels, NCases, lReport);
          end;
          if VarChkBox.Checked then
          begin
            title := 'Variances';
            DynVectorPrint(Variances, NoVars, title, ColLabels, NCases, lReport);
          end;
          if SDChkBox.Checked then
          begin
            title := 'Standard Deviations';
            DynVectorPrint(StdDevs, NoVars, title, ColLabels, NCases, lReport);
          end;
          if errorcode > 0 then
          begin
            MessageDlg('A selected variable has no variability-run aborted.', mtError, [mbOK], 0);
            exit;
          end;

          { get determinant of the correlation matrix }
          determinant := 0.0;
          for i := 1 to NoVars do
              for j := 1 to NoVars do
                  CorrMat[i-1,j-1] := Corrs[i-1,j-1];
          Determ(CorrMat, NoVars, NoVars, determinant, errcode);
          if (determinant < 0.000001) then
          begin
               MessageDlg('Matrix is singular!', mtError,[mbOK], 0);
//               goto cleanup;
          end;
          lReport.Add('Determinant of correlation matrix = %8.4f', [determinant]);
          lReport.Add('');

          NoIndepVars := NoVars-1;
          for i := 1 to NoIndepVars do IndepIndex[i-1] := i;
          MReg2(NCases,NoVars,NoIndepVars,IndepIndex,corrs,InverseMat,
               RowLabels,R2,BetaWeights,
               Means,Variances,errorcode,StdErrEst,constant,POut,true, false,false, lReport);

          // Get partial correlation matrix
          for i := 1 to NoVars do
              for j := 1 to NoVars do
                   InverseMat[i-1,j-1] := Corrs[i-1,j-1];
          SVDinverse(InverseMat, NoVars);
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
          if PartialsChkBox.Checked then
          begin
              title := 'Partial Correlations';
              DynVectorPrint(BetaWeights, NoIndepVars, title, ColLabels, NCases, lReport);
          end;

          { eliminate variable with lowest partial }
          if NoVars > 2 then
          begin
              lReport.Add('Variable %d (%s) eliminated', [Index, ColLabels[Index-1]]);
              for i := Index to NoVars-1 do
              begin
                   ColNoSelected[i-1] := ColNoSelected[i];
                   ColLabels[i-1] := ColLabels[i];
                   RowLabels[i-1] := RowLabels[i];
              end;
              NoVars := NoVars - 1;
              StepNo := StepNo + 1;
         end
         else
              NoVars := 0;
       end;

       DisplayReport(lReport);

     finally
       lReport.Free;

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
     end;
end;

procedure TBackRegFrm.DepInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := varList.ItemIndex;
  if (index > -1) and (DepVar.Text = '') then
  begin
    DepVar.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TBackRegFrm.DepOutBtnClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    SelList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TBackRegFrm.InBtnClick(Sender: TObject);
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
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TBackRegFrm.OutBtnClick(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while i < SelList.Items.Count do
  begin
    if SelList.Selected[i] then
    begin
      VarList.Items.Add(SelList.Items[i]);
      SelList.Items.Delete(i);
      i := 0;
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TBackRegFrm.UpdateBtnStates;
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
  DepInBtn.Enabled := lSelected and (DepVar.Text = '');
  InBtn.Enabled := lSelected;

  DepOutBtn.Enabled := DepVar.Text <> '';

  lSelected := false;
  for i := 0 to SelList.Items.Count-1 do
    if SelList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;
end;


initialization
  {$I backregunit.lrs}

end.

