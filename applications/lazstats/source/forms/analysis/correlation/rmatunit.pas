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
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
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
    ListBox1: TListBox;
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
    procedure PairsCalc(NoVars : integer;
                    VAR ColNoSelected : IntDyneVec;
                    VAR Matrix : DblDyneMat;
                    VAR ColLabels : StrDyneVec);

  public
    { public declarations }
  end; 

var
  RMatFrm: TRMatFrm;

implementation

uses
  Math;

{ TRMatFrm }

procedure TRMatFrm.ResetBtnClick(Sender: TObject);
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

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TRMatFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TRMatFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TRMatFrm.AllBtnClick(Sender: TObject);
VAR count, index : integer;
begin
     count := VarList.Items.Count;
     for index := 0 to count-1 do
     begin
          ListBox1.Items.Add(VarList.Items.Strings[index]);
     end;
     VarList.Clear;
end;

procedure TRMatFrm.ComputeBtnClick(Sender: TObject);
label cleanit;
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
begin
     errorcode := false;
     OutputFrm.RichEdit.Clear;
     NoVars := ListBox1.Items.Count;
     Augment := false;
     Ngood := 0;

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

     if PairsChkBox.Checked then
     begin
             PairsCalc(NoVars,ColNoSelected,Matrix,ColLabels);
             goto cleanit;
     end;

     if AugmentChk.Checked then
     begin
          Augment := true;
          ColLabels[NoVars] := 'Intercept';
          RowLabels[NoVars] := 'Intercept';
     end;

     // get cross-products if elected
     if CPChkBox.Checked = true then
     begin
          GridXProd(NoVars,ColNoSelected,Matrix,Augment,Ngood);
          title := 'Cross-Products Matrix';
          if NOT Augment then
          MAT_PRINT(Matrix,NoVars,NoVars,title,RowLabels,ColLabels,Ngood)
          else
          MAT_PRINT(Matrix,NoVars+1,NoVars+1,title,RowLabels,ColLabels,Ngood);
     end;

     if CovChkBox.Checked = true then // get variance-covariance mat. if elected
     begin
          title := 'Variance-Covariance Matrix';
          GridCovar(NoVars,ColNoSelected,Matrix,Means,Variances,StdDevs,errorcode, Ngood);
          MAT_PRINT(Matrix,NoVars,NoVars,title,RowLabels,ColLabels,Ngood);
     end;

     if CorrsChkBox.Checked = true then // get correlations
     begin
          title := 'Product-Moment Correlations Matrix';
          Correlations(NoVars,ColNoSelected,Matrix,Means,Variances,StdDevs,errorcode,Ngood);
          MAT_PRINT(Matrix,NoVars,NoVars,title,RowLabels,ColLabels,Ngood);
          N := Ngood;
          for i := 1 to NoVars do
          begin
               for j := i+1 to NoVars do
               begin
                    t := Matrix[i-1][j-1] * (sqrt((N-2.0) /
                         (1.0 - (Matrix[i-1][j-1] * Matrix[i-1][j-1]))));
                    TestMat[i-1,j-1] := t;
                    Probr := probt(t,N - 2.0);
                    TestMat[j-1,i-1] := Probr;
                    TestMat[i-1,i-1] := 0.0;

               end;
          end;
          title := 't-test values (upper) and probabilities of t (lower)';
          MAT_PRINT(TestMat,NoVars,NoVars,title,RowLabels,ColLabels,Ngood);
     end;

     title := 'Means';
     if MeansChkBox.Checked = true then
             DynVectorPrint(Means,NoVars,title,ColLabels,Ngood);

     title := 'Variances';
     if VarChkBox.Checked = true then
             DynVectorPrint(Variances,NoVars,title,ColLabels,Ngood);

     title := 'Standard Deviations';
     if SDChkBox.Checked = true then
             DynVectorPrint(StdDevs,NoVars,title,ColLabels,Ngood);

     if errorcode then
          OutputFrm.RichEdit.Lines.Add('One or more correlations could not be computed due to zero variance of a variable.');

     OutputFrm.ShowModal;

     if GridMatChk.Checked then MatToGrid(Matrix,NoVars);
     // clean up the heap
cleanit:
     ColLabels := nil;
     RowLabels := nil;
     StdDevs := nil;
     Variances := nil;
     Means := nil;
     Matrix := nil;
     ColNoSelected := nil;
end;

procedure TRMatFrm.InBtnClick(Sender: TObject);
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

procedure TRMatFrm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
   index := ListBox1.ItemIndex;
   VarList.Items.Add(ListBox1.Items.Strings[index]);
   ListBox1.Items.Delete(index);
   InBtn.Enabled := true;
end;

procedure TRMatFrm.PairsCalc(NoVars: integer; var ColNoSelected: IntDyneVec;
  var Matrix: DblDyneMat; var ColLabels: StrDyneVec);
Label nextpart;
var
   i, j, k, XCol, YCol, Npairs, N : integer;
   X, Y, XMean, XVar, XSD, YMean, YVar, YSD, pmcorr, z, rprob : double;
   strout : string;
   NMatrix : IntDyneMat;
   tMatrix : DblDyneMat;
   ProbMat : DblDyneMat;
   startpos, endpos : integer;

begin
     OutputFrm.RichEdit.Clear;
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
               strout := ColLabels[i-1];
               strout := strout + ' vs ';
               strout := strout + ColLabels[j-1];
               OutputFrm.RichEdit.Lines.Add(strout);
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
               begin
                   strout := format('CrossProducts[%d,%d]=%6.4f, N cases = %d',[i,j,pmcorr,Npairs]);
                   OutputFrm.RichEdit.Lines.Add(strout);
               end;
               pmcorr := pmcorr - (XMean * YMean) / Npairs;
               pmcorr := pmcorr / (Npairs - 1);
               if CovChkBox.Checked then
               begin
                    strout := format('Covariance[%d,%d]=%6.4f, N cases = %d',[i,j,pmcorr,Npairs]);
                    OutputFrm.RichEdit.Lines.Add(strout);
               end;
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
                    strout := format('r[%d,%d]=%6.4f, N cases = %d',[i,j,pmcorr,Npairs]);
                    OutputFrm.RichEdit.Lines.Add(strout);
                    strout := format('t value with d.f. %d = %8.4f with Probability > t = %6.4f',[Npairs-2,z,rprob]);
                    OutputFrm.RichEdit.Lines.Add(strout);
                    tMatrix[i-1,j-1] := z;
                    tMatrix[j-1,i-1] := z;
                    ProbMat[i-1,j-1] := rprob;
                    ProbMat[j-1,i-1] := rprob;
               end;
               if MeansChkBox.Checked or VarChkBox.Checked or SDChkBox.Checked then
               begin
                    strout := format('Mean X = %8.4f, Variance X = %8.4f, Std.Dev. X = %8.4f',[XMean,XVar,XSD]);
                    OutputFrm.RichEdit.Lines.Add(strout);
                    strout := format('Mean Y = %8.4f, Variance Y = %8.4f, Std.Dev. Y = %8.4f',[YMean,YVar,YSD]);
                    OutputFrm.RichEdit.Lines.Add(strout);
               end;
               OutputFrm.RichEdit.Lines.Add('');
          end; // next j variable
          Matrix[i-1,i-1] := 1.0;
     end; // next i variable
     Matrix[NoVars-1,NoVars-1] := 1.0;
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Intercorrelation Matrix and Statistics');
     OutputFrm.RichEdit.Lines.Add('');
//     strout := 'Correlation Matrix Summary (Ns in lower triangle)';
//     MAT_PRINT(Matrix,NoVars,NoVars,strout,ColLabels,ColLabels,NoCases);
     startpos := 1;
     endpos := 6;
     if endpos > NoVars then endpos := NoVars;
     for i := 1 to NoVars do
     begin
nextpart:
          strout := '          ';
          for j := startpos to endpos do
               strout := strout + format('     %5d',[j]);
          OutputFrm.RichEdit.Lines.Add(strout);
          strout := format('%2d PMCorr.',[i]);
          for j := startpos to endpos do
              strout := strout + format('   %7.4f',[Matrix[i-1,j-1]]);
          OutputFrm.RichEdit.Lines.Add(strout);
          strout := format('%2d N Size ',[i]);
          for j := startpos to endpos do
          begin
               if j <> i then
                  strout := strout + format('   %3d    ',[NMatrix[i-1,j-1]])
               else begin
                    Npairs := 0;
                    for k := 1 to NoCases do
                    begin
                         if ValidValue(k,ColNoSelected[j-1])
                         then Npairs := Npairs + 1;
                    end;
                    strout := strout + format('   %3d    ',[Npairs]);
               end;
          end;
          OutputFrm.RichEdit.Lines.Add(strout);
          strout := format('%2d t Value',[i]);
          for j := startpos to endpos do
          begin
              if j <> i then
                   strout := strout + format('   %7.4f',[tMatrix[i-1,j-1]])
              else strout := strout + '          ';
          end;
          OutputFrm.RichEdit.Lines.Add(strout);
          strout := format('%2d Prob. t',[i]);
          for j := startpos to endpos do
          begin
              if j <> i then
                 strout := strout + format('   %7.4f',[ProbMat[i-1,j-1]])
              else strout := strout + '          ';
          end;
          OutputFrm.RichEdit.Lines.Add(strout);
          OutputFrm.RichEdit.Lines.Add('');
          if endpos < NoVars then
          begin
               startpos := endpos + 1;
               endpos := endpos + 6;
               if endpos > NoVars then endpos := NoVars;
               goto nextpart;
          end;
     end;
     OutputFrm.ShowModal;

     ProbMat := nil;
     tMatrix := nil;
     NMatrix := nil;
end;

initialization
  {$I rmatunit.lrs}

end.

