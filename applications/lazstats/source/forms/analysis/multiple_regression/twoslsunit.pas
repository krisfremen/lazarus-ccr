// File for testing: "cansas.laz"
// - dependent variable: jumpgs
// -  exolanatory variables: pulse, chins, situps
// - instrumental variables: pulse, chins, situps, weight, waist

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
    ComputeBtn: TButton;
    CloseBtn: TButton;
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
    procedure ExplanatorySelectionChange(Sender: TObject; User: boolean);
    procedure ExpOutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InstInClick(Sender: TObject);
    procedure InstOutClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure PredictIt(const ColNoSelected: IntDyneVec; NoVars: integer;
              Means, StdDevs, BetaWeights : DblDyneVec;
              StdErrEst : double; NoIndepVars : integer);

  private
    { private declarations }
    FAutoSized: boolean;
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  TwoSLSFrm: TTwoSLSFrm;

implementation

uses
  StrUtils, Utils;

{ TTwoSLSFrm }

procedure TTwoSLSFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  Explanatory.Clear;
  Instrumental.Clear;
  DepVarEdit.Text := '';
  ProxyRegShowChk.Checked := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TTwoSLSFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := True;
end;

procedure TTwoSLSFrm.FormCreate(Sender: TObject);
begin
   Assert(OS3MainFrm <> nil);
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
var
  i: integer;
begin
  i := 0;
  while (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] and (Instrumental.Items.IndexOf(VarList.Items[i]) = -1) then
      Instrumental.Items.Add(VarList.Items[i])
      // DO NOT DELETE Items HERE.
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TTwoSLSFrm.InstOutClick(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while (i < Instrumental.Items.Count) do
  begin
    if Instrumental.Selected[i] then
    begin
      if VarList.Items.IndexOf(Instrumental.Items[i]) = -1 then
        VarList.Items.Add(Instrumental.Items[i]);
      Instrumental.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TTwoSLSFrm.ComputeBtnClick(Sender: TObject);
var
     i, j, k, DepCol,  NoInst, NoExp, NoProx, Noindep : integer;
     IndepCols, ProxSrcCols, ExpCols, InstCols, ProxCols : IntDyneVec;
     DepProx,  NCases, col, counter : integer;
     ExpLabels, InstLabels, ProxLabels, RowLabels, ProxSrcLabels : StrDyneVec;
     X, Y : double;
     Means, Variances, StdDevs, BWeights : DblDyneVec;
     BetaWeights, BStdErrs, Bttests, tprobs : DblDyneVec;
//     ProxVals : DblDyneMat;
     PrintDesc: Boolean;
//     PrintCorrs, PrintInverse, PrintCoefs, SaveCorrs : boolean;
     found : boolean;
     lReport: TStrings;
     errorcode: Boolean = false;
     R2: Double = 0.0;
     stdErrEst: Double = 0.0;
begin
     if DepVarEdit.Text = '' then
     begin
       MessageDlg('Dependent variable not selected.', mtError, [mbOK], 0);
       exit;
     end;
     if Explanatory.Items.Count = 0 then
     begin
       MessageDlg('No explanatory variables selected.', mtError, [mbOK], 0);
       exit;
     end;
     if Instrumental.Items.Count = 0 then
     begin
       MessageDlg('No instrumental variables selected.', mtError, [mbOK], 0);
       exit;
     end;

     if (ProxyRegShowChk.Checked) then
     begin
        PrintDesc := true;
//        PrintCorrs := true;
//        PrintInverse := false;
//        PrintCoefs := true;
//        SaveCorrs := false;
     end
     else
     begin
        PrintDesc := false;
//        PrintCorrs := false;
//        PrintInverse := false;
//        PrintCoefs := false;
//        SaveCorrs := false;
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
//     SetLength(ProxVals,NoCases,NoVariables);

     // Get variables to analyze
     NCases := NoCases;
     NoInst := Instrumental.Items.Count;
     NoExp := Explanatory.Items.Count;
     if (NoInst < NoExp) then
     begin
        MessageDlg('The no. of Instrumental must equal or exceed the Explanatory', mtError, [mbOK], 0);
        exit;
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

     lReport := TStringList.Create;
     try
       // Output Parameters of the Analysis
       lReport.Add('FILE: ' + OS3MainFrm.FileNameEdit.Text);
       lReport.Add('');
       lReport.Add('Dependent: ' + DepVarEdit.Text);
       lReport.Add('');
       lReport.Add('Explanatory Variables:');
       for i := 0 to NoExp - 1 do
         lReport.Add('    ' + ExpLabels[i]);
       lReport.Add('');
       lReport.Add('Instrumental Variables:');
       for i := 0 to NoInst - 1 do
         lReport.Add('    ' + InstLabels[i]);
       lReport.Add('');
       lReport.Add('Proxy Variables:');
       for i := 0 to NoProx - 1 do
         lReport.Add('    ' + ProxLabels[i]);
       lReport.Add('');

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
         lReport.Add('');
         lReport.Add('==================================================================');
         lReport.Add('');
         lReport.Add('Analysis for ' + ProxLabels[i]);
         lReport.Add('-------------' + DupeString('-', Length(ProxLabels[i])));
         lReport.Add('Dependent: ' + ProxSrcLabels[i]);
         lReport.Add('');
         lReport.Add('Independent: ');
         for j := 0 to Noindep - 1 do
           lReport.Add('    ' + RowLabels[j]);
         lReport.Add('');

//         OutputFrm.ShowModal();
         MReg(Noindep, IndepCols, DepProx, RowLabels, Means, Variances, StdDevs,
             BWeights, BetaWeights, BStdErrs, Bttests, tprobs, R2, stderrest,
             NCases, errorcode, PrintDesc, lReport);

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
             OS3MainFrm.DataGrid.Cells[col,j] := Format('%12.5f', [Y]);
         end; // next case
       end; // next proxy
//     OutputFrm.ShowModal();

       lReport.Add('');
       lReport.Add('==================================================================');
       lReport.Add('');

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
//       PrintCorrs := true;
//       PrintInverse := false;
//       PrintCoefs := true;
//       SaveCorrs := false;
       IndepCols[Noindep] := DepCol;
       MReg(Noindep, IndepCols, DepCol, RowLabels, Means, Variances, StdDevs,
         BWeights, BetaWeights, BStdErrs, Bttests, tprobs, R2, stderrest,
         NCases, errorcode, PrintDesc, lReport);

       DisplayReport(lReport);

       if SaveItChk.Checked then
         PredictIt(IndepCols, Noindep+1, Means, StdDevs, BetaWeights, stderrest, Noindep);

     finally
       lReport.Free;
//       ProxVals := nil;
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
end;

procedure TTwoSLSFrm.DepInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepVarEdit.Text = '') then
  begin
    DepVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TTwoSLSFrm.DepOutClick(Sender: TObject);
begin
  if DepVarEdit.Text <> '' then
  begin
    VarList.Items.Add(DepVarEdit.Text);
    DepVarEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TTwoSLSFrm.ExpInClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] and (Explanatory.Items.IndexOf(VarList.Items[i]) = -1) then
      Explanatory.Items.Add(VarList.Items[i]);
      // DO NOT DELETE Items HERE.
    i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TTwoSLSFrm.ExplanatorySelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TTwoSLSFrm.ExpOutClick(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while (i < Explanatory.Items.Count) do
  begin
    if Explanatory.Selected[i] then
    begin
      if (VarList.Items.IndexOf(Explanatory.Items[i]) = -1) then
        VarList.Items.Add(Explanatory.Items[i]);
      Explanatory.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TTwoSLSFrm.PredictIt(const ColNoSelected: IntDyneVec; NoVars: integer;
  Means, StdDevs, BetaWeights: DblDyneVec;
  StdErrEst: double; NoIndepVars: integer);
var
  col, i, j, k, Index: integer;
  predicted, zpredicted, z1, z2, resid, residsqr: double;
  astring: string;
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

procedure TTwoSLSFrm.UpdateBtnStates;
var
  lSelected: Boolean;
begin
  lSelected := AnySelected(VarList);
  DepIn.Enabled := lSelected and (DepVarEdit.Text = '');
  ExpIn.Enabled := lSelected;
  InstIn.Enabled := lSelected;

  DepOut.Enabled := (DepVarEdit.Text <> '');
  ExpOut.Enabled := AnySelected(Explanatory);
  InstOut.Enabled := AnySelected(Instrumental);
end;

initialization
  {$I twoslsunit.lrs}

end.

