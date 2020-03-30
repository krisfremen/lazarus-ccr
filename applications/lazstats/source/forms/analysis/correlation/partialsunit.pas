unit PartialsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, MatrixLib, FunctionsLib, OutputUnit, Globals, ContextHelpUnit;

type

  { TPartialsFrm }

  TPartialsFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    HelpBtn: TButton;
    PredInBtn: TBitBtn;
    PredOutBtn: TBitBtn;
    PartInBtn: TBitBtn;
    PartOutBtn: TBitBtn;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    DepVar: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PartList: TListBox;
    PredList: TListBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure PartInBtnClick(Sender: TObject);
    procedure PartOutBtnClick(Sender: TObject);
    procedure PredInBtnClick(Sender: TObject);
    procedure PredOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  PartialsFrm: TPartialsFrm;

implementation

uses
  Math;

{ TPartialsFrm }

procedure TPartialsFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     DepVar.Text := '';
     VarList.Clear;
     PartList.Clear;
     PredList.Clear;
     DepInBtn.Enabled := true;
     DepOutBtn.Enabled := false;
     PredInBtn.Enabled := true;
     PredOutBtn.Enabled := false;
     PartInBtn.Enabled := true;
     PartOutBtn.Enabled := false;
     for i := 1 to OS3MainFrm.DataGrid.ColCount - 1 do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TPartialsFrm.FormActivate(Sender: TObject);
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

procedure TPartialsFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TPartialsFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TPartialsFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TPartialsFrm.PartInBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            PartList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     PartOutBtn.Enabled := true;
end;

procedure TPartialsFrm.PartOutBtnClick(Sender: TObject);
VAR index : integer;
begin
   index := PartList.ItemIndex;
   VarList.Items.Add(PartList.Items.Strings[index]);
   PartList.Items.Delete(index);
   if PartList.Items.Count = 0 then PartOutBtn.Enabled := false;
end;

procedure TPartialsFrm.PredInBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            PredList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     PredOutBtn.Enabled := true;
end;

procedure TPartialsFrm.PredOutBtnClick(Sender: TObject);
VAR index : integer;
begin
   index := PredList.ItemIndex;
   VarList.Items.Add(PredList.Items.Strings[index]);
   PredList.Items.Delete(index);
   if PredList.Items.Count = 0 then PredOutBtn.Enabled := false;
end;

procedure TPartialsFrm.DepInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     if index < 0 then exit;
     DepVar.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     DepOutBtn.Enabled := true;
     DepInBtn.Enabled := false;
end;

procedure TPartialsFrm.ComputeBtnClick(Sender: TObject);
var
   rmatrix, workmat : DblDyneMat;
   Means, Variances, StdDevs, W, Betas : DblDyneVec;
   R2Full, R2Cntrl, SemiPart, Partial, df1, df2, F, Prob : double;
   NoPredVars, NoCntrlVars, DepVarNo, TotNoVars, pcnt, ccnt, count : integer;
   PredVars, CntrlVars : IntDyneVec;
   MatVars : IntDyneVec;
   outline, varstring : string;
   i, j, K, L, NCases : integer;
   errorcode : boolean;
   vtimesw, W1, v : DblDyneMat;

begin
     DepVarNo := 1;
     errorcode := false;

    // Get no. of predictor and control variables
    NoPredVars := PredList.Items.Count;
    NoCntrlVars := PartList.Items.Count;
    if (NoPredVars = 0) or (NoCntrlVars = 0) then
    begin
        ShowMessage('You must select at least one predictor and one control variable!');
        exit;
    end;
    TotNoVars := NoPredVars + NoCntrlVars + 1;
    count := NoCases;
    NCases := NoCases;

    // Allocate space required
    SetLength(vtimesw,NoVariables,NoVariables);
    SetLength(v,NoVariables,NoVariables);
    SetLength(W1,NoVariables,NoVariables);
    SetLength(rmatrix,NoVariables+1,NoVariables+1); // augmented
    SetLength(workmat,NoVariables+1,NoVariables+1); // augmented
    SetLength(PredVars,NoVariables);
    SetLength(CntrlVars,NoVariables);
    SetLength(Means,NoVariables);
    SetLength(Variances,NoVariables);
    SetLength(StdDevs,NoVariables);
    SetLength(W,NoVariables);
    SetLength(Betas,NoVariables);
    SetLength(MatVars,NoVariables);

    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('Partial and Semi-Partial Correlation Analysis');
    OutputFrm.RichEdit.Lines.Add('');

    // Get column numbers of dependent, predictor and control variables
    pcnt := 1;
    for i := 0 to NoPredVars - 1 do
    begin
        varstring := PredList.Items.Strings[i];
        for j := 1 to NoVariables do
        begin
            if varstring = OS3MainFrm.DataGrid.Cells[j,0] then
            begin
                PredVars[pcnt-1] := j;
                pcnt := pcnt + 1;
            end;
        end;
    end;
    ccnt := 1;
    for i := 0 to NoCntrlVars - 1 do
    begin
        varstring := PartList.Items.Strings[i];
        for j := 1 to NoVariables do
        begin
            if varstring = OS3MainFrm.DataGrid.Cells[j,0] then
            begin
                CntrlVars[ccnt-1] := j;
                ccnt := ccnt + 1;
            end;
        end;
    end;
    varstring := DepVar.Text;
    for i := 1 to NoVariables do
        if varstring = OS3MainFrm.DataGrid.Cells[i,0] then DepVarNo := i;

    outline := format('Dependent variable = %s',[OS3MainFrm.DataGrid.Cells[DepVarNo,0]]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Predictor Variables:');
    for i := 1 to NoPredVars do
    begin
        outline := format('Variable %d = %s',[i+1,OS3MainFrm.DataGrid.Cells[PredVars[i-1],0]]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Control Variables:');
    for i := 1 to NoCntrlVars do
    begin
        outline := format('Variable %d = %s',[i+1,OS3MainFrm.DataGrid.Cells[CntrlVars[i-1],0]]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;
    OutputFrm.RichEdit.Lines.Add('');
    if NoPredVars > 1 then
    begin
        outline := format('Higher order partialling at level = %d',[NoPredVars]);
        OutputFrm.RichEdit.Lines.Add(outline);
        OutputFrm.RichEdit.Lines.Add('');
    end;
    if NoCntrlVars > 1 then
    begin
        outline := format('Multiple partialling with %d variables.',[NoCntrlVars]);
        OutputFrm.RichEdit.Lines.Add(outline);
        OutputFrm.RichEdit.Lines.Add('');
    end;

    // Now, build the correlation matrix
    MatVars[0] := DepVarNo;
    for i := 1 to NoPredVars do MatVars[i] := PredVars[i-1];
    for i := 1 to NoCntrlVars do MatVars[i + NoPredVars] := CntrlVars[i-1];
    Correlations(TotNoVars, MatVars, rmatrix, Means, Variances, StdDevs, errorcode, count);

    // Now do Multiple regression models required
    // Full model first
    for i := 2 to TotNoVars do
        for j := 2 to TotNoVars do
            workmat[i-2,j-2] := rmatrix[i-1,j-1];

    matinv(workmat, vtimesw, v, W1, TotNoVars-1);
    R2Full := 0.0;
    for i := 1 to TotNoVars-1 do // rows
    begin
        W[i-1] := 0.0;
        for j := 1 to TotNoVars - 1 do W[i-1] := W[i-1] + (workmat[i-1,j-1] * rmatrix[0,j]);
        R2Full := R2Full + W[i-1] * rmatrix[0,i];
    end;
    outline := format('Squared Multiple Correlation with all variables = %6.3f',[R2Full]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Standardized Regression Coefficients:');
    for i := 1 to TotNoVars - 1 do
    begin
        outline := format('%10s = %6.3f',[OS3MainFrm.DataGrid.Cells[MatVars[i],0],W[i-1]]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;
    OutputFrm.RichEdit.Lines.Add('');

    // Now do model for Partial and Semi-partial
    for i := 1 to NoCntrlVars do
    begin
        K := i + 1 + NoPredVars;
        for j := 1 to NoCntrlVars do
        begin
            L := j + 1 + NoPredVars;
            workmat[i-1,j-1] := rmatrix[K-1,L-1];
        end;
    end;
    matinv(workmat, vtimesw, v, W1, NoCntrlVars);
    R2Cntrl := 0.0;
    for i := 1 to NoCntrlVars do
    begin
        L := i + 1 + NoPredVars;
        W[i-1] := 0.0;
        for j := 1 to NoCntrlVars do
        begin
                K := j + 1 + NoPredVars;
                W[i-1] := W[i-1] + (workmat[i-1,j-1] * rmatrix[0,K-1]);
        end;
        R2Cntrl := R2Cntrl + W[i-1] * rmatrix[0,L-1];
    end;
    outline := format('Squared Multiple Correlation with control variables = %6.3f',[R2Cntrl]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Standardized Regression Coefficients:');
    for i := 1 to NoCntrlVars do
    begin
        outline := format('%10s = %6.3f',[OS3MainFrm.DataGrid.Cells[MatVars[i+NoPredVars],0],W[i-1]]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;
    OutputFrm.RichEdit.Lines.Add('');

    SemiPart := R2Full - R2Cntrl;
    Partial := SemiPart / (1.0 - R2Cntrl);
    df1 := TotNoVars - 1 - NoCntrlVars;
    df2 := count - TotNoVars;
    F := (SemiPart / (1.0 - R2Full)) * (df2 / df1);
    Prob := probf(F,df1,df2);

    // Report results
    OutputFrm.RichEdit.Lines.Add('');
    outline := format('Partial Correlation = %6.3f',[sqrt(Partial)]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');
    outline := format('Semi-Partial Correlation = %6.3f',[sqrt(SemiPart)]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');
    outline := format('F = %8.3f with probability = %6.4f, D.F.1 = %3.0f and D.F.2 = %3.0f',[F,Prob,df1,df2]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.ShowModal;

    // clean up the heap
    MatVars := nil;
    Betas := nil;
    W := nil;
    Variances := nil;
    StdDevs := nil;
    Means := nil;
    CntrlVars := nil;
    PredVars := nil;
    workmat := nil;
    rmatrix := nil;
    v := nil;
    W1 := nil;
    vtimesw := nil;
end;

procedure TPartialsFrm.DepOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(DepVar.Text);
     DepVar.Text := '';
     DepInBtn.Enabled := true;
     DepOutBtn.Enabled := false;
end;


initialization
  {$I partialsunit.lrs}

end.

