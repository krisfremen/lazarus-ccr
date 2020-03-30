// Use file "cansas.laz" for testing, all variables.

unit SimultRegUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Globals, MainUnit, MatrixLib, OutputUnit, FunctionsLib, DataProcs;

type

  { TSimultFrm }

  TSimultFrm = class(TForm)
    Bevel1: TBevel;
    OpenDialog1: TOpenDialog;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    MatInChkBox: TCheckBox;
    MatSaveChkBox: TCheckBox;
    CPChkBox: TCheckBox;
    CovChkBox: TCheckBox;
    CorrsChkBox: TCheckBox;
    MeansChkBox: TCheckBox;
    SaveDialog1: TSaveDialog;
    VarChkBox: TCheckBox;
    SDChkBox: TCheckBox;
    InvMatChkBox: TCheckBox;
    GroupBox1: TGroupBox;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  SimultFrm: TSimultFrm;

implementation

uses
  Math;

{ TSimultFrm }

procedure TSimultFrm.ResetBtnClick(Sender: TObject);
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
end;

procedure TSimultFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TSimultFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TSimultFrm.AllBtnClick(Sender: TObject);
var
  index: integer;
begin
  for index := 0 to VarList.Items.Count-1 do
    ListBox1.Items.Add(VarList.Items[index]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TSimultFrm.ComputeBtnClick(Sender: TObject);
var
   NoVars, i, j, NCases, errcode: integer;
   StdErr, df1, df2, x, determinant : double;
   errorcode : boolean = false;
   filename : string;
   cellstring, outline, valstring : string;
   Corrs : DblDyneMat;
   Means : DblDyneVec;
   Variances : DblDyneVec;
   StdDevs : DblDyneVec;
   ColNoSelected : IntDyneVec;
   title : string;
   RowLabels : StrDyneVec;
   ColLabels : StrDyneVec;
   InverseMat : DblDyneMat;
   R2s : DblDyneVec;
   W : DblDyneVec;
   ProdMat : DblDyneMat;
   FProbs : DblDyneVec;
   CorrMat : DblDyneMat;
   lReport: TStrings;

begin
     SetLength(Corrs,NoVariables+1,NoVariables+1);
     SetLength(Means,NoVariables);
     SetLength(Variances,NoVariables);
     SetLength(StdDevs,NoVariables);
     SetLength(RowLabels,NoVariables);
     SetLength(ColLabels,NoVariables);
     SetLength(InverseMat,NoVariables,NoVariables);
     SetLength(R2s,NoVariables);
     SetLength(W,NoVariables);
     SetLength(ProdMat,NoVariables+1,NoVariables+1);
     SetLength(Fprobs,NoVariables);
     SetLength(CorrMat,NoVariables+1,NoVariables+1);
     SetLength(ColNoSelected,NoVariables);

     lReport := TStringList.Create;
     try
       lReport.Add('SIMULTANEOUS MULTIPLE REGRESSION by Bill Miller');
       lReport.Add('------------------------------------------------------------------');
       lReport.Add('');
       errcode := 0;
       if MatInChkBox.Checked  then
       begin
          OpenDialog1.Filter := 'FreeStat matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
          OpenDialog1.FilterIndex := 1;
          if OpenDialog1.Execute then
          begin
               filename := OpenDialog1.FileName;
               MATREAD(Corrs,NoVars,NoVars,Means,StdDevs,NCases,RowLabels,ColLabels,filename);
               for i := 1 to NoVars do Variances[i-1] := sqr(StdDevs[i-1]);
               MessageDlg('Last variable in matrix is the dependent variable', mtInformation, [mbOK], 0);
          end;
       end else
       begin
          { get variable columns }
          NoVars := ListBox1.Items.Count;
          if NoVars < 1 then
          begin
               MessageDlg('No variables selected.',mtError, [mbOK], 0);
               exit;
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
       end;

       if CPChkBox.Checked then
       begin
          title := 'Cross-Products Matrix';
          GridXProd(NoVars,ColNoSelected,Corrs,errorcode,NCases);
          MatPrint(Corrs,NoVars,NoVars,title,RowLabels,ColLabels,NCases, lReport);
          lReport.Add('------------------------------------------------------------------');
          lReport.Add('');
       end;

       if CovChkBox.Checked then
       begin
          title := 'Variance-Covariance Matrix';
          GridCovar(NoVars,ColNoSelected,Corrs,Means,Variances,
                      StdDevs,errorcode,NCases);
          MatPrint(Corrs,NoVars,NoVars,title,RowLabels,ColLabels,NCases, lReport);
          lReport.Add('------------------------------------------------------------------');
          lReport.Add('');
       end;

       Correlations(NoVars,ColNoSelected,Corrs,Means,Variances, StdDevs,errorcode,NCases);

       if CorrsChkBox.Checked = true then
       begin
         for i := 1 to NoVars do
           for j := 1 to NoVars do InverseMat[i-1,j-1] := Corrs[i-1,j-1];
         title := 'Product-Moment Correlations Matrix';
         MatPrint(Corrs,NoVars,NoVars,title,RowLabels,ColLabels,NCases, lReport);
         lReport.Add('------------------------------------------------------------------');
         lReport.Add('');
       end;

       if MatSaveChkBox.Checked then
       begin
          SaveDialog1.Filter := 'OpenStat matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
          SaveDialog1.FilterIndex := 1;
          if SaveDialog1.Execute then
          begin
               filename := SaveDialog1.FileName;
               MATSAVE(Corrs,NoVars,NoVars,Means,StdDevs,NCases,RowLabels,ColLabels,filename);
          end;
       end;

       title := 'Means';
       if MeansChkBox.Checked = true then
       begin
         title := 'Means';
         DynVectorPrint(Means,NoVars,title,ColLabels,NCases, lReport);
         lReport.Add('------------------------------------------------------------------');
         lReport.Add('');
       end;

       if VarChkBox.Checked  then
       begin
          title := 'Variances';
          DynVectorPrint(Variances,NoVars,title,ColLabels,NCases, lReport);
          lReport.Add('------------------------------------------------------------------');
          lReport.Add('');
       end;

       if SDChkBox.Checked then
       begin
          title := 'Standard Deviations';
          DynVectorPrint(StdDevs,NoVars,title,ColLabels,NCases, lReport);
          lReport.Add('------------------------------------------------------------------');
          lReport.Add('');
       end;

       if errcode > 0 then
       begin
         lReport.Add('One or more correlations could not be computed due to zero variance of a variable.');
         MessageDlg('A selected variable has no variability-run aborted.', mtError, [mbOK], 0);
         exit;
       end;

       determinant := 0.0;
       for i := 1 to NoVars do
         for j := 1 to NoVars do
           CorrMat[i-1,j-1] := Corrs[i-1,j-1];
       Determ(CorrMat,NoVars,NoVars,determinant,errorcode);
       if (determinant < 0.000001) then
       begin
         MessageDlg('Matrix is singular.', mtError, [mbOK], 0);
         exit;
       end;
       lReport.Add('Determinant of correlation matrix = %8.4f', [Determinant]);
       lReport.Add('');

       SVDinverse(InverseMat, NoVars);
       if InvMatChkBox.Checked then
       begin
         title := 'Inverse of correlation matrix';
         MatPrint(InverseMat,NoVars,NoVars,title,RowLabels,ColLabels,NCases, lReport);
         lReport.Add('------------------------------------------------------------------');
         lReport.Add('');
       end;

       lReport.Add('Multiple Correlation Coefficients for Each Variable');
       lReport.Add('');
       lReport.Add('%10s%8s%10s%10s%12s%5s%5s', ['Variable','R','R2','F','Prob.>F','DF1','DF2']);

       df1 := NoVars - 1.0;
       df2 := NCases - NoVars;

       for i := 1  to NoVars do
       begin   // R squared values
         R2s[i-1] := 1.0 - (1.0 / InverseMat[i-1,i-1]);
         W[i-1] := (R2s[i-1] / df1) / ((1.0-R2s[i-1]) / df2);
         FProbs[i-1] := probf(W[i-1],df1,df2);
         valstring := format('%10s',[ColLabels[i-1]]);
         lReport.Add('%10s%10.3f%10.3f%10.3f%10.3f%5.0f%5.0f', [
           valstring,sqrt(R2s[i-1]),R2s[i-1],W[i-1],FProbs[i-1],df1,df2
         ]);
         for j := 1 to NoVars do
         begin  // betas
           ProdMat[i-1,j-1] := -InverseMat[i-1,j-1] / InverseMat[j-1,j-1];
         end;
       end;
       lReport.Add('------------------------------------------------------------------');
       lReport.Add('');

       title := 'Betas in Columns';
       MatPrint(ProdMat,NoVars,NoVars,title,RowLabels,ColLabels,NCases, lReport);
       lReport.Add('Standard Errors of Prediction');
       lReport. Add('Variable     Std.Error');
       for i := 1 to NoVars do
       begin
         StdErr := (NCases-1) * Variances[i-1] * (1.0 / InverseMat[i-1,i-1]);
          StdErr := sqrt(StdErr / (NCases - NoVars));
          valstring := format('%10s', [ColLabels[i-1]]);
          lReport.Add('%10s%10.3f', [valstring,StdErr]);
       end;
       lReport.Add('------------------------------------------------------------------');
       lReport.Add('');

       for i := 1 to NoVars do
         for j := 1 to NoVars do
          if (i <> j) then ProdMat[i-1,j-1] := ProdMat[i-1,j-1] * (StdDevs[j-1]/StdDevs[i-1]);
       title := 'Raw Regression Coefficients';
       MatPrint(ProdMat,NoVars,NoVars,title,RowLabels,ColLabels,NCases, lReport);
       lReport.Add('Variable   Constant');
        for i := 1 to NoVars do
        begin
    	  x := 0.0;
          for j := 1 to NoVars do
          begin
        	if (i <> j) then x := x + (ProdMat[j-1,i-1] * Means[j-1]);
          end;
          x := Means[i-1] - x;
          valstring := format('%10s',[ColLabels[i-1]]);
          lReport.Add('%10s%10.3f', [valstring, x]);
        end;
        lReport.Add('------------------------------------------------------------------');
        lReport.Add('');

        // Get partial correlation matrix
        for i := 1 to NoVars do
        begin
    	  for j := 1 to NoVars do
          begin
        	ProdMat[i-1,j-1] := -(1.0 / sqrt(InverseMat[i-1,i-1])) *
            	InverseMat[i-1,j-1] * (1.0 / sqrt(InverseMat[j-1,j-1]));
          end;
        end;
        title := 'Partial Correlations';
        MatPrint(ProdMat,NoVars,NoVars,title,RowLabels,ColLabels,NCases, lReport);

     finally
       if lReport.Count > 0 then
         DisplayReport(lReport);

       ColNoSelected := nil;
       CorrMat := nil;
       Fprobs := nil;
       ProdMat := nil;
       W := nil;
       R2s := nil;
       InverseMat := nil;
       ColLabels := nil;
       RowLabels := nil;
       StdDevs := nil;
       Variances := nil;
       Means := nil;
       corrs := nil;
     end;
end;

procedure TSimultFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
end;

procedure TSimultFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TSimultFrm.InBtnClick(Sender: TObject);
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
     end
     else
       inc(i);
  end;
  UpdateBtnStates;
end;

procedure TSimultFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < Listbox1.Items.Count do
  begin
     if Listbox1.Selected[i] then
     begin
       VarList.Items.Add(Listbox1.Items[i]);
       Listbox1.Items.Delete(i);
       i := 0;
     end else
       inc(i);
  end;
  UpdateBtnStates;
end;

procedure TSimultFrm.UpdateBtnStates;
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
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to ListBox1.Items.Count-1 do
    if ListBox1.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;

  AllBtn.Enabled := VarList.Items.Count > 0;
end;

initialization
  {$I simultregunit.lrs}

end.

