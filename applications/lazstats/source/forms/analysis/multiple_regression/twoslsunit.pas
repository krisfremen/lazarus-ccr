unit TwoSLSUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, math,
  Globals, MainUnit, MainDM, MatrixLib, DictionaryUnit, OutputUnit, ContextHelpUnit;

type

  { TTwoSLSFrm }

  TTwoSLSFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    ProxyRegShowChk: TCheckBox;
    SaveItChk: TCheckBox;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    ExpIn: TBitBtn;
    ExpOut: TBitBtn;
    GroupBox1: TGroupBox;
    InstIn: TBitBtn;
    InstOut: TBitBtn;
    DepVarEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Explanatory: TListBox;
    Instrumental: TListBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure ExpInClick(Sender: TObject);
    procedure ExpOutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InstInClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure PredictIt(ColNoSelected : IntDyneVec; NoVars : integer;
              Means, StdDevs, BetaWeights : DblDyneVec;
              StdErrEst : double; NoIndepVars : integer);

  private
    { private declarations }
    FAutoSized: boolean;

  public
    { public declarations }
  end; 

var
  TwoSLSFrm: TTwoSLSFrm;

implementation

{ TTwoSLSFrm }

procedure TTwoSLSFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     Explanatory.Clear;
     Instrumental.Clear;
     DepVarEdit.Text := '';
     ProxyRegShowChk.Checked := false;
     DepIn.Enabled := true;
     DepOut.Enabled := false;
     ExpIn.Enabled := true;
     ExpOut.Enabled := false;
     InstIn.Enabled := true;
     InstOut.Enabled := false;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TTwoSLSFrm.FormActivate(Sender: TObject);
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

  FAutoSized := True;
end;

procedure TTwoSLSFrm.FormCreate(Sender: TObject);
begin
   Assert(OS3MainFrm <> nil);
   if OutputFrm = nil then Application.CreateForm(TOutputFrm, OutputFrm);
   if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TTwoSLSFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TTwoSLSFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TTwoSLSFrm.InstInClick(Sender: TObject);
VAR i : integer;
begin
     if (VarList.Items.Count < 1) then exit;
     i := 0;
     while (i < VarList.Items.Count) do
     begin
         if (VarList.Selected[i]) then
         begin
              Instrumental.Items.Add(VarList.Items.Strings[i]);
         end;
         i := i + 1;
     end;
     InstOut.Enabled := true;
     if (VarList.Items.Count < 1) then InstIn.Enabled := false;
end;

procedure TTwoSLSFrm.DepInClick(Sender: TObject);
VAR index : integer;
begin
     if (VarList.Items.Count < 1) then exit;
     index := VarList.ItemIndex;
     DepVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     DepOut.Enabled := true;
     DepIn.Enabled := false;
end;

procedure TTwoSLSFrm.ComputeBtnClick(Sender: TObject);
label cleanup;
VAR
     i, j, k, DepCol,  NoInst, NoExp, NoProx, Noindep : integer;
     IndepCols, ProxSrcCols, ExpCols, InstCols, ProxCols : IntDyneVec;
     DepProx,  NCases, col, counter : integer;
     ExpLabels, InstLabels, ProxLabels, RowLabels, ProxSrcLabels : StrDyneVec;
     outstr : string;
     R2, stderrest, X, Y : double;
     Means, Variances, StdDevs, BWeights : DblDyneVec;
     BetaWeights, BStdErrs, Bttests, tprobs : DblDyneVec;
     ProxVals : DblDyneMat;
     errorcode, PrintDesc, PrintCorrs, PrintInverse, PrintCoefs, SaveCorrs : boolean;
     found : boolean;

begin
     if (ProxyRegShowChk.Checked) then
     begin
        PrintDesc := true;
        PrintCorrs := true;
        PrintInverse := false;
        PrintCoefs := true;
        SaveCorrs := false;
     end
     else
     begin
        PrintDesc := false;
        PrintCorrs := false;
        PrintInverse := false;
        PrintCoefs := false;
        SaveCorrs := false;
     end;
     SetLength(Means,NoVariables+2);
     SetLength(Variances,NoVariables+2);
     SetLength(StdDevs,NoVariables+2);
     SetLength(BWeights,NoVariables+2);
     SetLength(BetaWeights,NoVariables+2);
     SetLength(BStdErrs,NoVariables+2);
     SetLength(Bttests,NoVariables+2);
     SetLength(tprobs,NoVariables+2);
     SetLength(ExpLabels,NoVariables+2);
     SetLength(ExpCols,NoVariables+2);
     SetLength(InstLabels,NoVariables+2);
     SetLength(InstCols,NoVariables+2);
     SetLength(ProxCols,NoVariables);
     SetLength(ProxLabels,NoVariables);
     SetLength(IndepCols,NoVariables);
     SetLength(RowLabels,NoVariables);
     SetLength(ProxSrcCols,NoVariables);
     SetLength(ProxSrcLabels,NoVariables);
     SetLength(ProxVals,NoCases,NoVariables);

     // Get variables to analyze
     NCases := NoCases;
     NoInst := Instrumental.Items.Count;
     NoExp := Explanatory.Items.Count;
     if (NoInst < NoExp) then
     begin
        ShowMessage('The no. of Instrumental must equal or exceed the Explanatory');
        goto cleanup;
     end;
     for i := 0 to NoVariables - 1 do
     begin
         if (OS3MainFrm.DataGrid.Cells[i+1,0] = DepVarEdit.Text) then
         begin
                DepCol := i + 1;
//                result := VarTypeChk(DepCol,0);
//                if (result :=:= 1) goto cleanup;
         end;
         for j := 0 to NoExp - 1 do
         begin
             if (OS3MainFrm.DataGrid.Cells[i+1,0] = Explanatory.Items.Strings[j]) then
             begin
                ExpCols[j] := i+1;
//                result := VarTypeChk(i+1,0);
//                if (result :=:= 1) goto cleanup;
                ExpLabels[j] := Explanatory.Items.Strings[j];
             end;
         end; // next j
         for j := 0 to NoInst - 1 do
         begin
             if (OS3MainFrm.DataGrid.Cells[i+1,0] = Instrumental.Items.Strings[j]) then
             begin
                InstCols[j] := i+1;
//                result := VarTypeChk(i+1,0);
//                if (result :=:= 1) goto cleanup;
                InstLabels[j] := Instrumental.Items.Strings[j];
             end;
         end; // next j
     end; // next i

     // Get prox variables which are the variables common to exp and inst lists
     NoProx := 0;
     for i := 0 to NoInst - 1 do
     begin
         for j := 0 to NoExp - 1 do
         begin
             if (ExpLabels[j] = InstLabels[i]) then
             begin
                ProxLabels[NoProx] := 'P_' + InstLabels[i];
                ProxSrcLabels[NoProx] := InstLabels[i];
                ProxCols[NoProx] := InstCols[i];
                NoProx := NoProx + 1;
             end;
         end;
     end;

     // Output Parameters of the Analysis
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('FILE: ' + OS3MainFrm.FileNameEdit.Text);
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Dependent := ' + DepVarEdit.Text);
     OutputFrm.RichEdit.Lines.Add('Explanatory Variables:');
     for i := 0 to NoExp - 1 do OutputFrm.RichEdit.Lines.Add(ExpLabels[i]);
     OutputFrm.RichEdit.Lines.Add('Instrumental Variables:');
     for i := 0 to NoInst - 1 do OutputFrm.RichEdit.Lines.Add(InstLabels[i]);
     OutputFrm.RichEdit.Lines.Add('Proxy Variables:');
     for i := 0 to NoProx - 1 do OutputFrm.RichEdit.Lines.Add(ProxLabels[i]);
     OutputFrm.RichEdit.Lines.Add('');

     // Compute the prox regressions for the instrumental variables
     for i := 0 to NoProx - 1 do
     begin
         DictionaryFrm.DictGrid.ColCount := 8;
         col := NoVariables + 1;
//         NoVariables := col;
         DictionaryFrm.NewVar(col); // create column for proxy (predicted values)
         DictionaryFrm.DictGrid.Cells[1,col] := ProxLabels[i];
         OS3MainFrm.DataGrid.Cells[col,0] := ProxLabels[i];
         ProxSrcCols[i] := col;
         DepProx := ProxCols[i];
         Noindep := 0;
         for j := 0 to NoInst - 1 do
         begin
             if (DepProx <> InstCols[j]) then // don't include the prox itself!
             begin
                IndepCols[Noindep] := InstCols[j];
                RowLabels[Noindep] := InstLabels[j];
                Noindep := Noindep + 1;
             end;
         end;
         for j := 0 to NoExp - 1 do
         begin
             found := false;
             for k := 0 to NoProx - 1 do
                 if (ExpCols[j] = ProxCols[k]) then found := true; // don't include the proxs themselves
             if (not found) then
             begin
                IndepCols[Noindep] := ExpCols[j];
                RowLabels[Noindep] := ExpLabels[j];
                Noindep := Noindep + 1;
             end;
         end;
         IndepCols[Noindep] := DepProx;
         OutputFrm.RichEdit.Lines.Add('Analysis for ' + ProxLabels[i]);
         OutputFrm.RichEdit.Lines.Add('Dependent: ' + ProxSrcLabels[i]);
         OutputFrm.RichEdit.Lines.Add('Independent: ');
         for j := 0 to Noindep - 1 do OutputFrm.RichEdit.Lines.Add(RowLabels[j]);
//         OutputFrm.ShowModal();
         mreg(Noindep, IndepCols, DepProx, RowLabels, Means, Variances, StdDevs,
             BWeights, BetaWeights, BStdErrs, Bttests, tprobs, R2, stderrest,
             NCases, errorcode, PrintDesc);
         // save predicted scores at column := NoVariables and in ProxVals array
         for j := 1 to NoCases do
         begin
             Y := 0.0;
             for k := 0 to Noindep - 1 do
             begin
                 col := IndepCols[k];
                 X := StrToFloat(OS3MainFrm.DataGrid.Cells[col,j]);
                 Y := Y + BWeights[k] * X;
             end;
             Y := Y + BWeights[Noindep];  // intercept
             col := NoVariables;
             outstr := format('%12.5f',[Y]);
             OS3MainFrm.DataGrid.Cells[col,j] := outstr;
         end; // next case
     end; // next proxy
//     OutputFrm.ShowModal();

     // Compute the OLS using the Prox values and explanatory
     Noindep := 0;
     counter := 0;
     for i := 0 to NoExp - 1 do
     begin
         for j := 0 to NoInst - 1 do
         begin
             if (ExpLabels[i] = InstLabels[j]) then // use proxy
             begin
                IndepCols[Noindep] := ProxSrcCols[counter];
                RowLabels[Noindep] := ProxLabels[counter];
                counter := counter + 1;
                break;
             end
             else
             begin
                 IndepCols[Noindep] := ExpCols[i];
                 RowLabels[Noindep] := ExpLabels[i];
             end;
         end;
         Noindep := Noindep + 1;
     end;
     PrintDesc := true;
     PrintCorrs := true;
     PrintInverse := false;
     PrintCoefs := true;
     SaveCorrs := false;
     IndepCols[Noindep] := DepCol;
     mreg(Noindep, IndepCols, DepCol, RowLabels, Means, Variances, StdDevs,
         BWeights, BetaWeights, BStdErrs, Bttests, tprobs, R2, stderrest,
         NCases, errorcode, PrintDesc);
     OutputFrm.ShowModal;
     if (SaveItChk.Checked) then
     begin
        PredictIt(IndepCols, Noindep+1, Means, StdDevs, BetaWeights, stderrest, Noindep);
     end;

     // cleanup
cleanup:
     ProxVals := nil;
     ProxSrcLabels := nil;
     ProxSrcCols := nil;
     RowLabels := nil;
     IndepCols := nil;
     ProxLabels := nil;
     ProxCols := nil;
     InstCols := nil;
     InstLabels := nil;
     ExpCols := nil;
     ExpLabels := nil;
     tprobs := nil;
     Bttests := nil;
     BStdErrs := nil;
     BetaWeights := nil;
     BWeights := nil;
     StdDevs := nil;
     Variances := nil;
     Means := nil;
end;

procedure TTwoSLSFrm.DepOutClick(Sender: TObject);
begin
     if (DepVarEdit.Text = '') then exit;
     VarList.Items.Add(DepVarEdit.Text);
     DepVarEdit.Text := '';
     DepIn.Enabled := true;
     DepOut.Enabled := false;
end;

procedure TTwoSLSFrm.ExpInClick(Sender: TObject);
VAR i : integer;
begin
     if (VarList.Items.Count < 1) then exit;
     i := 0;
     while (i < VarList.Items.Count) do
     begin
         if (VarList.Selected[i]) then
         begin
              Explanatory.Items.Add(VarList.Items.Strings[i]);
         end;
         i := i + 1;
     end;
     ExpOut.Enabled := true;
     if (VarList.Items.Count < 1) then ExpIn.Enabled := false;
end;

procedure TTwoSLSFrm.ExpOutClick(Sender: TObject);
VAR index : integer;
begin
     index := Explanatory.ItemIndex;
     Explanatory.Items.Delete(index);
     ExpIn.Enabled := true;
     if (Explanatory.Items.Count < 1) then ExpOut.Enabled := false;
end;

procedure TTwoSLSFrm.PredictIt(ColNoSelected : IntDyneVec; NoVars : integer;
              Means, StdDevs, BetaWeights : DblDyneVec;
              StdErrEst : double; NoIndepVars : integer);
VAR
   col, i, j, k, Index: integer;
   predicted, zpredicted, z1, z2, resid, residsqr : double;
   astring : string;

begin
   // routine obtains predicted raw and standardized scores and their
   // residuals.  It is assumed that the dependent variable is last in the
   // list of variable column pointers stored in the ColNoSelected vector.
   // Get the z predicted score and its residual
   col := NoVariables + 1;
//   NoVariables := col;
   DictionaryFrm.NewVar(col);
   DictionaryFrm.DictGrid.Cells[1,col] := 'Pred.z';
   OS3MainFrm.DataGrid.Cells[col,0] := 'Pred.z';

   col := NoVariables + 1;
//   NoVariables := col;
   DictionaryFrm.NewVar(col);
   DictionaryFrm.DictGrid.Cells[1,col] := 'zResid.';
   OS3MainFrm.DataGrid.Cells[col,0] := 'zResid.';

//   OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 2;
   for i := 1 to NoCases do
   begin
       zpredicted := 0.0;
       for j := 0 to NoIndepVars - 1 do
       begin
           k := ColNoSelected[j];
           z1 := (StrToFloat(OS3MainFrm.DataGrid.Cells[k,i]) -
                               Means[j]) / StdDevs[j];
           zpredicted := zpredicted + (z1 * BetaWeights[j]);
       end;
       astring := format('%8.4f',[zpredicted]);
       OS3MainFrm.DataGrid.Cells[col-1,i] := astring;
       Index := ColNoSelected[NoVars-1];
       z2 := StrToFloat(OS3MainFrm.DataGrid.Cells[Index,i]);
       z2 := (z2 - Means[NoVars-1]) / StdDevs[NoVars-1]; // z score
       astring := format('%8.4f',[z2 - zpredicted]);  // z residual
       OS3MainFrm.DataGrid.Cells[col,i] := astring;
   end;

   // Get raw predicted and residuals
   col := NoVariables + 1;
//   NoVariables := col;
   DictionaryFrm.NewVar(col);
   DictionaryFrm.DictGrid.Cells[1,col] := 'Pred.Raw';
   OS3MainFrm.DataGrid.Cells[col,0] := 'Pred.Raw';

   // calculate raw predicted scores and store in grid at col
   for i := 1 to NoCases do
   begin   // predicted raw obtained from previously predicted z score
       predicted := StrToFloat(OS3MainFrm.DataGrid.Cells[col-2,i]) *
                            StdDevs[NoVars-1] + Means[NoVars-1];
       astring := format('%8.3f',[predicted]);
       OS3MainFrm.DataGrid.Cells[col,i] := astring;
   end;

   // Calculate residuals of predicted raw scores begin
   col := NoVariables +1;
//   NoVariables := col;
   DictionaryFrm.NewVar(col);
   DictionaryFrm.DictGrid.Cells[1,col] := 'RawResid.';
   OS3MainFrm.DataGrid.Cells[col,0] := 'RawResid.';

   for i := 1 to NoCases do
   begin
       Index := ColNoSelected[NoVars-1];
       resid := StrToFloat(OS3MainFrm.DataGrid.Cells[col-1,i]) -
                           StrToFloat(OS3MainFrm.DataGrid.Cells[Index,i]);
       astring := format('%8.3f',[resid]);
       OS3MainFrm.DataGrid.Cells[col,i] := astring;
   end;

   // get square of raw residuals
   col := NoVariables + 1;
//   NoVariables := col;
   DictionaryFrm.NewVar(col);
   DictionaryFrm.DictGrid.Cells[1,col] := 'ResidSqr';
   OS3MainFrm.DataGrid.Cells[col,0] := 'ResidSqr';
   for i := 1 to NoCases do
   begin
       residsqr := StrToFloat(OS3MainFrm.DataGrid.Cells[col-1,i]);
       residsqr := residsqr * residsqr;
       astring := format('%8.3f',[residsqr]);
       OS3MainFrm.DataGrid.Cells[col,i] := astring;
   end;
end;

initialization
  {$I twoslsunit.lrs}

end.

