// Data file for testing: anova2.laz
// - Row, Col --> Fixed effect independent variables
// - Cov1, Col2 --> Covariates (continuous)
// - X --> Continuouse dependent variables
// - Begin definition of an interaction, click Row, Col, end definition

unit GLMUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  MainUnit, MatrixLib, Globals, OutputUnit, FunctionsLib,
  DictionaryUnit, StdCtrls, Buttons, ExtCtrls, ContextHelpUnit;

type

  { TGLMFrm }

  TGLMFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    HelpBtn: TButton;
    Memo2: TLabel;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    ShowDesignChk: TCheckBox;
    ContDepInBtn: TBitBtn;
    GroupBox2: TGroupBox;
    RndIndepOutBtn: TBitBtn;
    CovInBtn: TBitBtn;
    CovOutBtn: TBitBtn;
    ContDepOutBtn: TBitBtn;
    CatDepInBtn: TBitBtn;
    CatDepOutBtn: TBitBtn;
    ReptDepInBtn: TBitBtn;
    ReptDepOutBtn: TBitBtn;
    FixedIndepInBtn: TBitBtn;
    FixedIndepOutBtn: TBitBtn;
    RndIndepInBtn: TBitBtn;
    ContDepCode: TListBox;
    CatDepCode: TListBox;
    ReptDepCode: TListBox;
    FixedIndepCode: TListBox;
    RndIndepCode: TListBox;
    CovariateCode: TListBox;
    RepTrtCode: TListBox;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DescChk: TCheckBox;
    CorsChk: TCheckBox;
    Label12: TLabel;
    IndOrderBox: TListBox;
    TypeGroup: TRadioGroup;
    ResidChk: TCheckBox;
    EndDefBtn: TButton;
    GroupBox1: TGroupBox;
    InterDefList: TListBox;
    Label11: TLabel;
    InteractList: TListBox;
    ShowModelBtn: TButton;
    DepContList: TListBox;
    ModelEdit: TEdit;
    FixedList: TListBox;
    Label10: TLabel;
    Label6: TLabel;
    DepCatList: TListBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    CovariateList: TListBox;
    RepTrtList: TListBox;
    RandomList: TListBox;
    RepeatList: TListBox;
    VarList: TListBox;
    StartInterBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure CatDepInBtnClick(Sender: TObject);
    procedure CatDepOutBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure ContDepCodeSelectionChange(Sender: TObject; User: boolean);
    procedure ContDepInBtnClick(Sender: TObject);
    procedure ContDepOutBtnClick(Sender: TObject);
    procedure CovariateListClick(Sender: TObject);
    procedure CovInBtnClick(Sender: TObject);
    procedure CovOutBtnClick(Sender: TObject);
    procedure EndDefBtnClick(Sender: TObject);
    procedure FixedIndepInBtnClick(Sender: TObject);
    procedure FixedIndepOutBtnClick(Sender: TObject);
    procedure FixedListClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure Panel9Resize(Sender: TObject);
    procedure RandomListClick(Sender: TObject);
    procedure ReptDepInBtnClick(Sender: TObject);
    procedure ReptDepOutBtnClick(Sender: TObject);
    procedure RepTrtListClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure RndIndepInBtnClick(Sender: TObject);
    procedure RndIndepOutBtnClick(Sender: TObject);
    procedure ShowModelBtnClick(Sender: TObject);
    procedure StartInterBtnClick(Sender: TObject);
  private
    { private declarations }
    IntDef : boolean;
    DefLine : integer; // number of interaction terms - 1
    NoInterDefs : integer; // number of interactions in the model
    NContDep : integer; // no. of continuous dependent variables
    NCatDep : integer; // no. of categorical dependent variables
    NReptDep : integer; // no. of repeated dependent variables
    NFixedIndep : integer; // no. of fixed effect independent variables
    NRndIndep : integer; // no. of random effect independent variables
    NCovIndep : integer; // no. of covariate independent variables
    model : integer; // 1 if multreg, 2 if canonical
    novars : integer; // total no. of vectors in analysis grid
    totalobs : integer; // total no. of data grid observations
    gencount, oldcount : integer; // no. columns generated in datagrid
    ContDepID : IntDyneVec; // grid col. no.s of continuous dependent var.s
    CatDepID : IntDyneVec; // grid col. no.s of categorical dependent var.s
    ReptDepID : IntDyneVec; // grid col. no.s of repeated dep. variables
    FixedIndepID : IntDyneVec; // grid col. no.s of fixed independent var.s
    RndIndepID : IntDyneVec; // grid col. no.s of random independent var.s
    CovIndepID : IntDyneVec; // grid col. no.s of covariates
    DataGrid : DblDyneMat; // array for generated vectors and values
    GenLabels : StrDyneVec; // array of labels for data matrix
    ContDepPos : IntDyneVec; // datagrid position of continuous variables
    CatDepPos : IntDyneVec; // beginning datagrid position of categorical var. vectors
    ReptDepPos : IntDyneVec; // datagrid position of repeated variable
    ReptIndepPos : IntDyneVec; // datagrid pos. of subject vectors
    ReptTrtPos : IntDyneVec; // datagrid pos. of repeated treatment vectors
    FixedIndepPos : IntDyneVec; // datagrid position of first vector for cat indep. var.
    RndIndepPos : IntDyneVec; // datagrid position of first vector for rnd. indep. var.
    CovIndepPos : IntDyneVec; // datagrid positions of covariates
    InteractPos : IntDyneVec; // datagrid positions of interactions
    Labels : StrDyneVec; // labels for the analyses
    ColSelected : IntDyneVec; // datagrid columns of variables in the analysis
    NFixVecIndep : IntDyneVec; // no. of vectors for fixed independent vars.
    NRndVecIndep : IntDyneVec; // no. of vectors for random indep. vars.
    NFixVecDep : IntDyneVec; // no. of vectors for fixed dependent vars.
    NInteractVecs : IntDyneVec; // no. of vectors for each interaction
    OldR2 : double; // Previously obtained R^2 for stepwise addition
    R2 : double; // Squared mult. R obtained from RegAnal
    rmatrix : DblDyneMat; // correlation matrix
    indmatrix : DblDyneMat; // correlations among independent variable
    rxy : DblDyneVec; // correlations between dependent and independent var.s
    invmatrix : DblDyneMat; // inverse of independent correlations
    means : DblDyneVec; // means of variables
    Vars : DblDyneVec; // variances of variables
    StdDevs : DblDyneVec; // standard deviations of variables
    B : DblDyneVec; // raw regression coefficients
    Beta : DblDyneVec; // standardized regression coefficients
    workmat : DblDyneMat; // work matrix for inverse referenced at 1 (not zero)
    TypeISS : DblDyneVec; // Incremental SS
    TypeIISS : DblDyneVec; // Unique SS
    TypeIMS : DblDyneVec; // Incremental SS
    TypeIIMS : DblDyneVec; // Unique MS
    TypeIDF1 : DblDyneVec; // numerator d.f. for incremental ms
    TypeIIDF1 : DblDyneVec; // numerator d.f. for unique ms
    TypeIDF2 : DblDyneVec; // denominator d.f. for incremental ms
    TypeIIDF2 : DblDyneVec; // denominator d.f. for unique ms
    TypeIF : DblDyneVec; // F for incremental ms
    TypeIProb : DblDyneVec; // Probability of F for incremental ms
    TypeIIF : DblDyneVec; // F for unique MS
    TypeIIProb : DblDyneVec; // Probability for unique ms

    procedure AllocateIDMem;
    procedure GetIDs;
    function GetVarCount : integer;
    procedure AllocateGridMem;
    procedure DeallocateGridMem;
    procedure DeallocateIDMem;
    procedure DummyCodes(min, max: integer; const CodePattern: IntDyneMat);
    procedure EffectCodes(min, max: integer; const CodePattern: IntDyneMat);
    procedure OrthogCodes(min, max: integer; const CodePattern: IntDyneMat);
    procedure RegAnal(Nentered: integer; AReport: TStrings);
    procedure PartIEntry;
    procedure PartIIEntry;
    procedure ModelIAnalysis(AReport: TStrings);
    procedure ModelIIAnalysis(AReport: TStrings);
    procedure ModelIIIAnalysis(AReport: TStrings);
    function CntIntActVecs(linestr : string) : integer;
    procedure GenInterVecs(linestr : string);
    procedure CanCor(NLeft : integer; NRight : integer; GridPlace : IntDyneVec; AReport: TStrings);
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  GLMFrm: TGLMFrm;

implementation

uses
  Math,
  Utils;

{ TGLMFrm }

procedure TGLMFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
    VarList.Items.Clear;
    DepCatList.Items.Clear;
    DepContList.Items.Clear;
    RepeatList.Items.Clear;
    RepTrtList.Items.Clear;
    RepTrtCode.Items.Clear;
    FixedList.Items.Clear;
    RandomList.Items.Clear;
    CovariateList.Items.Clear;
    InterDefList.Items.Clear;
    InteractList.Items.Clear;
    ContDepCode.Items.Clear;
    CatDepCode.Items.Clear;
    ReptDepCode.Items.Clear;
    FixedIndepCode.Items.Clear;
    RndIndepCode.Items.Clear;
    CovariateCode.Items.Clear;
    IndOrderBox.Items.Clear;
    ModelEdit.Text := '';
    NContDep := 0;
    NCatDep := 0;
    NReptDep := 0;
    NFixedIndep := 0;
    NRndIndep := 0;
    NCovIndep := 0;
    DescChk.Checked := false;
    CorsChk.Checked := false;
    ResidChk.Checked := false;
    TypeGroup.ItemIndex := 0;
    ContDepOutBtn.Enabled := false;
    CatDepOutBtn.Enabled := false;
    ReptDepOutBtn.Enabled := false;
    FixedIndepOutBtn.Enabled := false;
    RndIndepOutBtn.Enabled := false;
    CovOutBtn.Enabled := false;
    IntDef := false;
    DefLine := 0;
    NoInterDefs := 0;
    for i := 1 to NoVariables do VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TGLMFrm.RndIndepInBtnClick(Sender: TObject);
var
  i: integer;
  codestr: string;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      RandomList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      NRndIndep := NRndIndep + 1;
      codestr := Format('IR%d', [NRndIndep]);
      RndIndepCode.Items.Add(codestr);
      IndOrderBox.Items.Add(codestr);
      i := 0;
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

  (*
var
  index: integer;
  codestr: string;
begin
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    RandomList.Items.Add(VarList.Items[index]);
    VarList.Items.Delete(index);
    NRndIndep := NRndIndep + 1;
    codestr := format('IR%d',[NRndIndep]);
    RndIndepCode.Items.Add(codestr);
    IndOrderBox.Items.Add(codestr);
  end;
end;
    *)
procedure TGLMFrm.RndIndepOutBtnClick(Sender: TObject);
var
  i, index: integer;
  cellstring: string;
begin
  index := RandomList.ItemIndex;
  if index > -1 then
  begin
    VarList.Items.Add(RandomList.Items[index]);
    RandomList.Items.Delete(index);
    cellstring := RndIndepCode.Items[index];
    RndIndepCode.Items.Delete(index);
    for i := IndOrderBox.Items.Count - 1 downto 0 do
      if cellstring = IndOrderBox.Items.Strings[i] then
        IndOrderBox.Items.Delete(i);
    NRndIndep := NRndIndep - 1;
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.ShowModelBtnClick(Sender: TObject);
var
    i : integer;
    codestr : string;

begin
    // add all dependent variable codes
    if NContDep > 0 then
    begin
        for i := 0 to NContDep - 1 do
        begin
            ModelEdit.Text := ModelEdit.Text + ContDepCode.Items.Strings[i];
            if i < NContDep - 1 then ModelEdit.Text := ModelEdit.Text + ' + ';
        end;
    end;
    if NCatDep > 0 then
    begin
        if ModelEdit.Text <> '' then ModelEdit.Text := ModelEdit.Text + ' + ';
        for i := 0 to NCatDep - 1 do
        begin
            ModelEdit.Text := ModelEdit.Text + CatDepCode.Items.Strings[i];
            if i < NCatDep - 1 then ModelEdit.Text := ModelEdit.Text + ' + ';
        end;
    end;
    if NReptDep > 0 then
    begin
        if ModelEdit.Text <> '' then ModelEdit.Text := ModelEdit.Text + ' + ';
        ModelEdit.Text := ModelEdit.Text + 'Rep';
    end;

    // now add the independent variable codes
    ModelEdit.Text := ModelEdit.Text + ' = ';
    if NFixedIndep > 0 then
    begin
        for i := 0 to NFixedIndep - 1 do
        begin
            ModelEdit.Text := ModelEdit.Text + FixedIndepCode.Items.Strings[i];
            if i < NFixedIndep - 1 then
                ModelEdit.Text := ModelEdit.Text + ' + ';
        end;
    end;
    if NRndIndep > 0 then
    begin
        if NFixedIndep > 0 then ModelEdit.Text := ModelEdit.Text + ' + ';
        for i := 0 to NRndIndep - 1 do
        begin
            ModelEdit.Text := ModelEdit.Text + RndIndepCode.Items.Strings[i];
            if i < NRndIndep - 1 then
                ModelEdit.Text := ModelEdit.Text + ' + ';
        end;
    end;
    if NCovIndep > 0 then
    begin
        if (NFixedIndep > 0) or (NRndIndep > 0) then
            ModelEdit.Text := ModelEdit.Text + ' + ';
        for i := 0 to NCovIndep - 1 do
        begin
            ModelEdit.Text := ModelEdit.Text + CovariateCode.Items.Strings[i];
            if i < NCovIndep - 1 then
                ModelEdit.Text := ModelEdit.Text + ' + ';
        end;
    end;

    // now add interactions
    if NoInterDefs > 0 then
    begin
        ModelEdit.Text := ModelEdit.Text + ' + ';
        for i := 0 to NoInterDefs - 1 do
        begin
            ModelEdit.Text := ModelEdit.Text + InterActList.Items.Strings[i];
            if i < NoInterDefs - 1 then
                ModelEdit.Text := ModelEdit.Text + ' + ';
        end;
    end;

    // Now add person vectors
    if NReptDep > 0 then
    begin
        ModelEdit.Text := ModelEdit.Text + ' + ';
        for i := 0 to NReptDep - 1 do
        begin
            codestr := format('IP%d',[i+1]);
            ModelEdit.Text := ModelEdit.Text + codestr;
            if i < NReptDep - 1 then
                ModelEdit.Text := ModelEdit.Text + ' + ';
        end;
    end;
    // Now add repeated treatments
    if NReptDep > 0 then
    begin
        ModelEdit.Text := ModelEdit.Text + ' + ';
        for i := 0 to NReptDep - 1 do
        begin
            codestr := format('IR%d',[i+1]);
            ModelEdit.Text := ModelEdit.Text + codestr;
            if i < NReptDep - 1 then
                ModelEdit.Text := ModelEdit.Text + ' + ';
        end;
    end;
end;

procedure TGLMFrm.StartInterBtnClick(Sender: TObject);
begin
    IntDef := true;
end;

procedure TGLMFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TGLMFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TGLMFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TGLMFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TGLMFrm.RandomListClick(Sender: TObject);
VAR index : integer;
begin
    if IntDef then
    begin
        index := RandomList.ItemIndex;
        InterDefList.Items.Add(RndIndepCode.Items.Strings[index]);
        DefLine := DefLine + 1; // counter for number of terms - 1
    end;
end;

procedure TGLMFrm.ReptDepInBtnClick(Sender: TObject);
var
  i: integer;
  codestr: string;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      RepeatList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      NReptDep := NReptDep + 1;
      codestr := Format('DR%d', [NReptDep]);
      if NReptDep = 1 then
      begin
        ReptDepCode.Items.Add(codestr);
        codestr := Format('IP%d', [NReptDep]);
        IndOrderBox.Items.Add(codestr);
        codestr := Format('IR%d', [NReptDep]);
        IndOrderBox.Items.Add(codestr);
        RepTrtCode.Items.Add(codestr);
        codestr := Format('Rep.Trt.%d', [NReptDep]);
        RepTrtList.Items.Add(codestr);
      end;
      i := 0;
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.ReptDepOutBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := RepeatList.ItemIndex;
  if index > -1 then
  begin
    VarList.Items.Add(RepeatList.Items[index]);
    RepeatList.Items.Delete(index);
    ReptDepCode.Items.Delete(index);
    NReptDep := NReptDep - 1;
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.RepTrtListClick(Sender: TObject);
VAR index : integer;
begin
    if IntDef then
    begin
        index := RepTrtList.ItemIndex;
        InterDefList.Items.Add(RepTrtCode.Items.Strings[index]);
        DefLine := DefLine + 1; // counter for number of terms
    end;
end;

procedure TGLMFrm.ContDepInBtnClick(Sender: TObject);
var
  index: integer;
  codestr: string;
begin
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    DepContList.Items.Add(VarList.Items[index]);
    VarList.Items.Delete(index);
    NContDep := NContDep + 1;
    codestr := Format('DC%d',[NContDep]);
    ContDepCode.Items.Add(codestr);
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.ContDepOutBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := DepContList.ItemIndex;
  if index > -1 then
  begin
    VarList.Items.Add(DepContList.Items[index]);
    DepContList.Items.Delete(index);
    ContDepCode.Items.Delete(index);
    NContDep := NContDep - 1;
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.CatDepInBtnClick(Sender: TObject);
var
  index: integer;
  codestr: string;
begin
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    DepCatList.Items.Add(VarList.Items[index]);
    VarList.Items.Delete(index);
    NCatDep := NCatDep + 1;
    codestr := format('DF%d',[NCatDep]);
    CatDepCode.Items.Add(codestr);
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.CatDepOutBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := DepCatList.ItemIndex;
  if index > -1 then
  begin
    VarList.Items.Add(DepCatList.Items[index]);
    DepCatList.Items.Delete(index);
    CatDepCode.Items.Delete(index);
    NCatDep := NCatDep - 1;
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.ComputeBtnClick(Sender: TObject);
var
  i, j: integer;  // no. of variables in the analysis
  cellstring: string;
  lReport: TStrings;
begin
  if (NContDep = 0) and (NCatDep = 0) and (NReptDep = 0) then
  begin
    ErrorMsg('No variables selected.');
    exit;
  end;

  if (NContDep > 0) and (NReptDep > 0) then
  begin
    ErrorMsg('One cannot have both continuous and repeated dependent variables!');
    exit;
  end;

  gencount := 0; // counter for generated variables
  totalobs := 0; // initialize total no. of observations in data grid
  AllocateIDMem; // get heap space for arrays
  GetIDs; // get var. no.s of dependent and independent variables
  novars := GetVarCount; // get total no. of variables to generate
  AllocateGridMem; // create data array for values and codes

  // Note, the Data Grid first subscript is row (subject) and second the var.
  if (NCatDep > 0) or (NContDep > 1) then
    model := 2
  else
    model := 1; // use mult.reg for model 1, canonical reg. for model 2
  if NReptDep > 0 then
    model := 3;

  // This procedure first creates the vectors of dependent variables then the
  // vectors for independent variables.  A case no. is placed in the first
  // column of a data grid followed by the dependent variables and then the
  // independent variables.  If multiple dependent variables are created, the
  // type of analysis is a canonical correlation analysis, otherwise a
  // multiple regression analysis.  Analyses are performed to obtain both
  // Type I SS's and Type II SS's (stepwise addition and unique contribution)

  // PART I.  ENTRY OF DEPENDENT VARIABLES (AND OBSERVATION NO.)
  // Place case labels in data grid and for repeated measures, spread out
  // the repeated measures over NoCases * No. repeated measures
  PartIEntry;

  // PART II.  CREATION OF INDEPENDENT VARIABLE VECTORS
  // First, if there are repeated measures, generate (n - 1) person vectors
  PartIIEntry;

  lReport := TStringList.Create;
  try
    // Now, do the analyses
    case model of
      1: ModelIAnalysis(lReport);    // models with 1 dependent variable
      2: ModelIIAnalysis(lReport);   // models with 2 or more dependent var.s
      3: ModelIIIAnalysis(lReport);  // Repeated measures designs
    end;

    // Place generated data into the main form's grid
    if ShowDesignChk.Checked then
    begin
      if NoVariables < gencount then
      begin
        j := NoVariables;
        for i := j+1 to gencount do
          DictionaryFrm.NewVar(j);
      end;

      OS3MainFrm.DataGrid.RowCount := totalobs+1;

      for i := 1 to totalobs do
        for j := 1 to gencount do
          OS3MainFrm.DataGrid.Cells[j,i] := FloatToStr(DataGrid[i-1,j-1]);

      for i := 1 to gencount do
      begin
        OS3MainFrm.DataGrid.Cells[i,0] := GenLabels[i-1];
        DictionaryFrm.Defaults(Self,i);
        DictionaryFrm.DictGrid.Cells[1,i] := GenLabels[i-1];
      end;

      for i := 1 to totalobs do
      begin
        cellstring := format('CASE%d',[i]);
        OS3MainFrm.DataGrid.Cells[0,i] := cellstring;
      end;

      OS3MainFrm.NoCasesEdit.Text := IntToStr(totalobs);
      OS3MainFrm.NoVarsEdit.Text := IntToStr(gencount);
      NoVariables := gencount;
      NoCases := totalobs;
      OS3MainFrm.FileNameEdit.Text := '';
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;
    DeallocateGridMem; // free up heap allocated to data array
    DeallocateIDMem; // free up heap space
  end;
end;

procedure TGLMFrm.ContDepCodeSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TGLMFrm.CovariateListClick(Sender: TObject);
var
  index: integer;
begin
  if IntDef then
  begin
    index := CovariateList.ItemIndex;
    if index > -1 then
    begin
      InterDefList.Items.Add(CovariateCode.Items[index]);
      DefLine := DefLine + 1; // counter for number of terms - 1
    end;
  end;
end;

procedure TGLMFrm.CovInBtnClick(Sender: TObject);
var
  i: integer;
  codestr: string;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      CovariateList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      NCovIndep := NCovIndep + 1;
      codestr := Format('IC%d', [NCovIndep]);
      CovariateCode.Items.Add(codestr);
      IndOrderBox.Items.Add(codestr);
      i := 0;
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;
{
var
  index: integer;
  codestr: string;
begin
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    CovariateList.Items.Add(VarList.Items[index]);
    VarList.Items.Delete(index);
    NCovIndep := NCovIndep + 1;
    codestr := Format('IC%d', [NCovIndep]);
    CovariateCode.Items.Add(codestr);
    IndOrderBox.Items.Add(codestr);
  end;
  UpdateBtnStates;
end;
}
procedure TGLMFrm.CovOutBtnClick(Sender: TObject);
var
  i, index: integer;
  cellstring: string;
begin
  index := CovariateList.ItemIndex;
  if index > -1 then
  begin
    VarList.Items.Add(CovariateList.Items[index]);
    CovariateList.Items.Delete(index);
    cellstring := CovariateCode.Items[index];
    CovariateCode.Items.Delete(index);
    for i := IndOrderBox.Items.Count - 1 downto 0 do
      if cellstring = IndOrderBox.Items[i] then
        IndOrderBox.Items.Delete(i);
    NCovIndep := NCovIndep - 1;
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.EndDefBtnClick(Sender: TObject);
var
  index: integer;
  nolines: integer;
  LineStr: string;
begin
  LineStr := '';
  nolines := InterDefList.Items.Count;
  if nolines > 0 then
  begin
    for index := 0 to nolines - 1 do
    begin
      LineStr := LineStr + InterDefList.Items.Strings[index];
      if index < nolines - 1 then LineStr := LineStr + ' * ';
    end;
    InteractList.Items.Add(LineStr);
    IndOrderBox.Items.Add(LineStr);
    NoInterDefs := NoInterDefs + 1;
  end;
  InterDefList.Clear;
end;

procedure TGLMFrm.FixedIndepInBtnClick(Sender: TObject);
var
  i: integer;
  codestr: string;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      FixedList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      NFixedIndep := NFixedIndep + 1;
      codestr := Format('IF%d', [NFixedIndep]);
      FixedIndepCode.Items.Add(codestr);
      IndOrderBox.Items.Add(codestr);
      i := 0;
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.FixedIndepOutBtnClick(Sender: TObject);
var
  i, index: integer;
  cellstring: string;
begin
  index := FixedList.ItemIndex;
  if index > -1 then
  begin
    VarList.Items.Add(FixedList.Items[index]);
    FixedList.Items.Delete(index);
    cellstring := FixedIndepCode.Items[index];
    FixedIndepCode.Items.Delete(index);
    NFixedIndep := NFixedIndep - 1;
    for i := IndOrderBox.Items.Count - 1 downto 0 do
      if IndOrderBox.Items.Strings[i] = cellstring then
        IndOrderBox.Items.Delete(i);
  end;
  UpdateBtnStates;
end;

procedure TGLMFrm.FixedListClick(Sender: TObject);
var
  index: integer;
begin
  if IntDef then
  begin
    index := FixedList.ItemIndex;
    if index > -1 then begin
      InterDefList.Items.Add(FixedIndepCode.Items[index]);
       DefLine := DefLine + 1; // counter for number of terms
    end;
  end;
end;

procedure TGLMFrm.AllocateIDMem;
begin
  if NContDep > 0 then
  begin
    SetLength(ContDepID, NContDep);
    SetLength(ContDepPos, NContDep);
  end;

  if NCatDep > 0 then
  begin
    SetLength(CatDepID, NCatDep);
    SetLength(CatDepPos, NCatDep);
    SetLength(NFixVecDep, NCatDep);
  end;

  if NReptDep > 0 then
  begin
    SetLength(ReptDepID, NReptDep);
    SetLength(ReptDepPos, NReptDep);
    SetLength(ReptIndepPos, NoCases);
    SetLength(ReptTrtPos, NReptDep);
  end;

  if NFixedIndep > 0 then
  begin
    SetLength(FixedIndepID, NFixedIndep);
    SetLength(FixedIndepPos, NFixedIndep);
    SetLength(NFixVecIndep, NFixedIndep);
  end;

  if NRndIndep > 0 then
  begin
    SetLength(RndIndepID, NRndIndep);
    SetLength(RndIndepPos, NRndIndep);
    SetLength(NRndVecIndep, NRndIndep);
  end;

  if NCovIndep > 0 then
  begin
    SetLength(CovIndepID, NCovIndep);
    SetLength(CovIndepPos, NCovIndep);
  end;

  if NoInterDefs > 0 then
  begin
    SetLength(NInteractVecs, NoInterDefs);
    SetLength(InteractPos, NoInterDefs);
  end;
end;

procedure TGLMFrm.GetIDs;
var
  cellstring: string;
  i, j: integer;
begin
  if NContDep > 0 then
  begin
    for i := 0 to NContDep - 1 do
    begin
      cellstring := DepContList.Items[i];
      for j := 1 to NoVariables do
        if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
          ContDepID[i] := j;
    end;
  end;

  if NCatDep > 0 then
  begin
    for i := 0 to NCatDep - 1 do
    begin
      cellstring := DepCatList.Items[i];
      for j := 1 to NoVariables do
        if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
          CatDepID[i] := j;
    end;
  end;

  if NReptDep > 0 then
  begin
    for i := 0 to NReptDep - 1 do
    begin
      cellstring := RepeatList.Items[i];
      for j := 1 to NoVariables do
        if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
          ReptDepID[i] := j;
    end;
  end;

  if NFixedIndep > 0 then
  begin
    for i := 0 to NFixedIndep - 1 do
    begin
      cellstring := FixedList.Items[i];
      for j := 1 to NoVariables do
        if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
          FixedIndepID[i] := j;
    end;
  end;

  if NRndIndep > 0 then
  begin
    for i := 0 to NRndIndep - 1 do
    begin
      cellstring := RandomList.Items[i];
      for j := 1 to NoVariables do
        if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
          RndIndepID[i] := j;
      end;
  end;

  if NCovIndep > 0 then
  begin
    for i := 0 to NCovIndep - 1 do
    begin
      cellstring := CovariateList.Items[i];
      for j := 1 to NoVariables do
        if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
          CovIndepID[i] := j;
    end;
  end;
end;

function TGLMFrm.GetVarCount: integer;
var
  count, i, j, col, nvectors: integer;
  min, max: integer; // use to get no. of coding vectors for categorical var.s
  group: integer;
  linestr: string;
begin
  count := 1; // one column for case id's
  count := count  + NContDep + NCovIndep; // sum of continuous variables
  if NReptDep > 0 then count := count + 1; // one col. for repeated dep. measure
  // plus person vectors for repeated measures (independent predictors)
  if NReptDep > 0 then count := count + (NoCases - 1); // person vectors
  if NReptDep > 0 then count := count + (NreptDep - 1); // repeated treatment vectors

  // calculate min and max for each var. to get no. of vectors
  if NCatDep > 0 then
  begin
    for i := 0 to NCatDep - 1 do
    begin
      col := CatDepID[i];
      min := round(StrToFloat(OS3MainFrm.DataGrid.Cells[col,1]));
      max := min;
      for j := 1 to NoCases do
      begin
        group := round(StrToFLoat(OS3MainFrm.DataGrid.Cells[col,j]));
        if group < min then min := group;
        if group > max then max := group;
      end;
      count := count + (max - min); // 1 less than the no. of groups
      NFixVecDep[i] := count;
    end;
  end;

  // add no. of vectors to count
  if NFixedIndep > 0 then
  begin
    for i := 0 to NFixedIndep - 1 do
    begin
      col := FixedIndepID[i];
      min := round(StrToFloat(OS3MainFrm.DataGrid.Cells[col,1]));
      max := min;
      for j := 1 to NoCases do
      begin
        group := round(StrToFloat(OS3MainFrm.DataGrid.Cells[col,j]));
        if group < min then min := group;
        if group > max then max := group;
      end;
      count := count + (max - min); // 1 less than the no. of groups
      NFixVecIndep[i] := max - min;
    end;
  end;

  // add no. of vectors to count
  if NRndIndep > 0 then
  begin
    for i := 0 to NRndIndep - 1 do
    begin
      col := RndIndepID[i];
      min := round(StrToFloat(OS3MainFrm.DataGrid.Cells[col,1]));
      max := min;
      for j := 1 to NoCases do
      begin
        group := round(StrToFloat(OS3MainFrm.DataGrid.Cells[col,j]));
        if group < min then min := group;
        if group > max then max := group;
      end;
      count := count + (max - min); // 1 less than the no. of groups
      NRndVecIndep[i] := max - min;
    end;
  end;

  // get no. of vectors for each interaction
  if NoInterDefs > 0 then
  begin
    for i := 0 to NoInterDefs - 1 do
    begin
      linestr := InterActList.Items.Strings[i];
      // parse the line for variable definitions and get no. of columns
      // and vectors for the products of these variables
      nvectors := CntIntActVecs(linestr);
      NInteractVecs[i] := nvectors;
      count := count + nvectors;
    end;
  end;

  Result := count;
end;

procedure TGLMFrm.AllocateGridMem;
var
  norows: integer;
begin
  if NReptDep > 0 then
    norows := NoCases * NReptDep
  else
    norows := NoCases;
  SetLength(DataGrid, norows+1, novars+4); // grid data for generated data
  SetLength(GenLabels, novars+4);          // column labels of new data grid
  SetLength(Labels, novars+4);             // labels of variables entered into analysis
  SetLength(ColSelected, novars+4);        // datagrid columns selected for analysis
end;

procedure TGLMFrm.DeallocateGridMem;
begin
  ColSelected := nil;
  Labels := nil;
  GenLabels := nil;
  DataGrid := nil;
end;

procedure TGLMFrm.DeallocateIDMem;
begin
  InteractPos := nil;
  NInteractVecs := nil;
  CovIndepPos := nil;
  CovIndepID := nil;
  NRndVecIndep := nil;
  RndIndepPos := nil;
  RndIndepID := nil;
  NFixVecIndep := nil;
  FixedIndepPos := nil;
  FixedIndepID := nil;
  ReptTrtPos := nil;
  ReptIndepPos := nil;
  ReptDepPos := nil;
  ReptDepID := nil;
  NFixVecDep := nil;
  CatDepPos := nil;
  CatDepID := nil;
  ContDepPos := nil;
  ContDepID := nil;
end;

procedure TGLMFrm.DummyCodes(min, max: integer; const  CodePattern: IntDyneMat);
var
  ngrps: integer;
  vects: integer;
  i, j: integer;
begin
  ngrps := max - min + 1;
  vects := ngrps - 1;
  for j := 1 to vects do
    for i := 1 to ngrps do
      if i = j then CodePattern[i,j] := 1 else CodePattern[i,j] := 0;
end;

procedure TGLMFrm.EffectCodes(min, max: integer; const CodePattern: IntDyneMat);
var
  ngrps: integer;
  vects: integer;
  i, j: integer;
begin
  ngrps := max - min + 1;
  vects := ngrps - 1;
  for i := 1 to ngrps do
    for j := 1 to vects do
    begin
      if i = j then CodePattern[i,j] := 1;
      if i = ngrps then CodePattern[i,j] := -1;
      if (i <> j) and (i <> ngrps) then CodePattern[i,j] := 0;
    end;
end;

procedure TGLMFrm.OrthogCodes(min, max: integer; const CodePattern: IntDyneMat);
var
  ngrps: integer;
  vects: integer;
  i, j: integer;
begin
  ngrps := max - min + 1;
  vects := ngrps - 1;
  for i := 1 to ngrps do
    for j := 1 to vects do
    begin
      if i <= j then CodePattern[i,j] := 1;
      if i-1 = j then CodePattern[i,j] := -j;
      if i > j+1 then CodePattern[i,j] := 0;
    end;
end;

procedure TGLMFrm.Panel9Resize(Sender: TObject);
begin
  Bevel3.Constraints.MinHeight := Panel8.Height;
end;

procedure TGLMFrm.RegAnal(Nentered: integer; AReport: TStrings);
var
  i, j, nvars, ncases: integer;
  title: string;
begin
  nvars := Nentered;
  ncases := totalobs;
  SetLength(rmatrix, nvars+1, nvars+1);
  SetLength(indmatrix, nvars-1, nvars-1);
  SetLength(rxy, nvars);
  SetLength(invmatrix, nvars ,nvars);
  SetLength(B, nvars);
  SetLength(Beta, nvars);
  SetLength(means, nvars);
  SetLength(Vars, nvars);
  SetLength(StdDevs, nvars);
  SetLength(workmat, nvars, nvars);

  DynCorrelations(nvars, ColSelected, DataGrid, rmatrix, means, vars, StdDevs, ncases, 3);

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  if DescChk.Checked then
  begin
    title := 'Means';
    DynVectorPrint(means, Nentered, title, Labels, ncases, AReport);
  end;

  if CorsChk.Checked then
  begin
    title := 'Correlations';
    MatPrint(rmatrix, Nentered, Nentered, title, Labels, Labels, ncases, AReport);
  end;

  for i := 1 to nvars - 1 do
  begin
    rxy[i-1] := rmatrix[i,0]; // r's with dependent var
    for j := 1 to nvars - 1 do
    begin
      indmatrix[i-1,j-1] := rmatrix[i,j]; // intercorr.s of indep. var.s
      workmat[i-1,j-1] := rmatrix[i,j]; // used to get inverse
    end;
  end;
  SVDinverse(workmat, nvars-1);

  // Copy inverse to zero indexed matrix
  for i := 1 to nvars-1 do
      for j := 1 to nvars-1 do
        invmatrix[i-1,j-1] := workmat[i-1,j-1];

  title := 'inverse of indep. matrix';

  // get betas and squared multiple correlation
  R2 := 0.0;
  for i := 1 to nvars-1 do
  begin
    Beta[i-1] := 0.0;
    for j := 1 to nvars-1 do
      Beta[i-1] := Beta[i-1] + invmatrix[i-1,j-1] * rxy[j-1];
    R2 := R2 + Beta[i-1] * rxy[i-1];
  end;

  //    outline := format('Squared Multiple Correlation = %6.4f',[R2]);
  //    OutputFrm.RichEdit.Lines.Add(outline);
  //    title := 'Standardized regression coefficients';
  //    DynVectorPrint(Beta,Nentered-1,title,Labels,ncases);

  // get raw coefficients
  for i := 1 to nvars - 1 do
  begin
    if StdDevs[i] > 0.0 then
      B[i-1] := Beta[i-1] * (StdDevs[0] / StdDevs[i])
    else
      B[i-1] := 0.0;
  end;

  //    title := 'Raw regression coefficients';
  //    DynVectorPrint(B,Nentered-1,title,Labels,ncases);
  //    OutputFrm.ShowModal;
end;

procedure TGLMFrm.PartIEntry;
var
    i, j, k, vect : integer;
    min, max, group, ngrps : integer;
    CodePattern : IntDyneMat;
    cellstring: string;

begin
    if NReptDep > 0 then // create observations for each replication of the N cases
    begin
        for i := 1 to NreptDep do
        begin
            ReptDepPos[i-1] := i; // datagrid pos. of a repeated measure
            for j := 1 to NoCases do
            begin
                DataGrid[totalobs,gencount] := j; // case no. in col. 0
                k := ReptDepID[i-1];
                DataGrid[totalobs,gencount+1] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,j]));
                totalobs := totalobs + 1;
            end;
        end; // next i repeated measure
        gencount := gencount + 2;
    end
    else
    begin // no repeated measures - just need case numbers in data grid pos 0
        for i := 1 to NoCases do DataGrid[i-1,gencount] := i;
        totalobs := NoCases;
        gencount := gencount + 1;
    end;
    GenLabels[0] := 'Obs.';
    if NReptDep > 0 then GenLabels[1] := 'Repeated';

    // Enter the continuous dependent variables into the data grid
    if NContDep > 0 then
    begin
        for j := 1 to NContDep do
        begin
            ContDepPos[j-1] := gencount;
            for i := 1 to NoCases do
            begin
                k := ContDepID[j-1];
                DataGrid[i-1,gencount] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i]));
            end;
            GenLabels[gencount] := ContDepCode.Items.Strings[j-1];
            gencount := gencount + 1;
        end;
    end; // end if NContDep > 0

    // Enter categorical dependent variables in the data grid
    if NCatDep > 0 then
    begin
        // get no. of categories - 1 for no of vectors to generate for each
        // categorical variable
        for j := 1 to NCatDep do
        begin
            CatDepPos[j-1] := gencount;
            k := CatDepID[j-1];
            min := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,1])));
            max := min;
            for i := 1 to NoCases do
            begin
                group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i])));
                if group > max then max := group;
                if group < min then min := group;
            end;
            ngrps := max-min+1;
            SetLength(CodePattern,ngrps+1,ngrps+1);
            if TypeGroup.ItemIndex = 0 then // dummy coding
                DummyCodes(min,max,CodePattern);
            if TypeGroup.ItemIndex = 1 then // effect coding
                EffectCodes(min,max,CodePattern);
            if TypeGroup.ItemIndex = 2 then // orthogonal coding
                OrthogCodes(min,max,CodePattern);
            // Now, generate vectors for the categorical variable j
            for vect := 1 to (max - min) do // vector no.
            begin
                for i := 1 to NoCases do
                begin
                    group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i])));
                    DataGrid[i-1,gencount + vect - 1] := CodePattern[group,vect];
                end;
                cellstring := format('%s_%d',[CatDepCode.Items.Strings[j-1],vect]);
                GenLabels[gencount + vect - 1] := cellstring;
            end;
            gencount := gencount + (max - min); // new no. of variables
        end; // next categorical variable j
    end; // if no. of dependent categorical variables greater than zero
    codepattern := nil;
end;

procedure TGLMFrm.PartIIEntry;
var
    i, j, k, vect, lastdep, row : integer;
    min, max, group, ngrps : integer;
    CodePattern : IntDyneMat;
    cellstring : string;
    value : double;

begin
    lastdep := gencount; // datagrid position of last dependent variable
    // This section develops vectors for the independent variables.  If there
    // are repeated measures, generate person vectors first.
    if NReptDep > 0 then
    begin
        min := 1;
        max := NoCases;
        ngrps := max-min+1;
        SetLength(CodePattern,ngrps+1,ngrps+1);
        if TypeGroup.ItemIndex = 0 then // dummy coding
                DummyCodes(min,max,CodePattern);
        if TypeGroup.ItemIndex = 1 then // effect coding
                EffectCodes(min,max,CodePattern);
        if TypeGroup.ItemIndex = 2 then // orthogonal coding
                OrthogCodes(min,max,CodePattern);
        for vect := 1 to (max - min) do // vector no.
        begin
            for i := 1 to totalobs do // NoCases
            begin
                group := round(DataGrid[i-1,0]);
                DataGrid[i-1,gencount + vect - 1] := CodePattern[group,vect];
            end;
            ReptIndepPos[vect-1] := gencount + vect - 1;
            cellstring := Format('p%d', [vect]);
            GenLabels[gencount + vect - 1] := cellstring;
        end;
        gencount := gencount + (max - min); // new no. of variables
    end; // end generation of person codes

    // generate vectors for the repeated treatments if replications used
    if NReptDep > 0 then
    begin
        min := 1;
        max := NReptDep;
        ngrps := max-min+1;
        SetLength(CodePattern,ngrps+1,ngrps+1);
        if TypeGroup.ItemIndex = 0 then // dummy coding
                DummyCodes(min,max,CodePattern);
        if TypeGroup.ItemIndex = 1 then // effect coding
                EffectCodes(min,max,CodePattern);
        if TypeGroup.ItemIndex = 2 then // orthogonal coding
                OrthogCodes(min,max,CodePattern);
        for vect := 1 to (max - min) do // vector no.
        begin
            for i := 1 to totalobs do // NoCases
            begin
                group := ((i - 1) div NoCases) + 1;
                DataGrid[i-1,gencount + vect - 1] := CodePattern[group,vect];
            end;
            ReptTrtPos[vect-1] := gencount + vect - 1;
            cellstring := format('IR_%d',[vect]);
            GenLabels[gencount + vect - 1] := cellstring;
        end;
        gencount := gencount + (max - min); // new no. of variables
    end;

    oldcount := gencount;
    // Next, add vectors for independent fixed categorical variables
    if NFixedIndep > 0 then
    begin
        // get no. of categories - 1 for no of vectors to generate for each
        // categorical variable
        for j := 1 to NFixedIndep do
        begin
            FixedIndepPos[j-1] := gencount; // first vector position in datagrid
            k := FixedIndepID[j-1];
            min := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,1])));
            max := min;
            for i := 1 to NoCases do
            begin
                group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i])));
                if group > max then max := group;
                if group < min then min := group;
            end;
            ngrps := max-min+1;
            SetLength(CodePattern,ngrps+1,ngrps+1);
            if TypeGroup.ItemIndex = 0 then // dummy coding
                DummyCodes(min,max,CodePattern);
            if TypeGroup.ItemIndex = 1 then // effect coding
                EffectCodes(min,max,CodePattern);
            if TypeGroup.ItemIndex = 2 then // orthogonal coding
                OrthogCodes(min,max,CodePattern);
            // Now, generate vectors for the categorical variable j
            for vect := 1 to (max - min) do // vector no.
            begin
                for i := 1 to NoCases do
                begin
                    group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i])));
                    DataGrid[i-1,gencount + vect - 1] := CodePattern[group,vect];
                end;
                cellstring := format('%s_%d',[FixedIndepCode.Items.Strings[j-1],vect]);
                GenLabels[gencount + vect - 1] := cellstring;
            end;
            gencount := gencount + (max - min); // new no. of variables
        end; // next categorical variable j
    end; // end generation of fixed effect codes

    // Next, add vectors for independent random categorical variables
    oldcount := gencount;
    if NRndIndep > 0 then
    begin
        // get no. of categories - 1 for no of vectors to generate for each
        // categorical variable
        for j := 1 to NRndIndep do
        begin
            RndIndepPos[j-1] := gencount; // pos. of first vector in datagrid
            k := RndIndepID[j-1];
            min := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,1])));
            max := min;
            for i := 1 to NoCases do
            begin
                group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i])));
                if group > max then max := group;
                if group < min then min := group;
            end;
            ngrps := max-min+1;
            SetLength(CodePattern,ngrps+1,ngrps+1);
            if TypeGroup.ItemIndex = 0 then // dummy coding
                DummyCodes(min,max,CodePattern);
            if TypeGroup.ItemIndex = 1 then // effect coding
                EffectCodes(min,max,CodePattern);
            if TypeGroup.ItemIndex = 2 then // orthogonal coding
                OrthogCodes(min,max,CodePattern);
            // Now, generate vectors for the categorical variable j
            for vect := 1 to (max - min) do // vector no.
            begin
                for i := 1 to NoCases do
                begin
                    group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i])));
                    DataGrid[i-1,gencount + vect - 1] := CodePattern[group,vect];
                end;
                cellstring := format('%s_%d',[RndIndepCode.Items.Strings[j-1],vect]);
                GenLabels[gencount + vect - 1] := cellstring;
            end;
            gencount := gencount + (max - min); // new no. of variables
        end; // next categorical variable j
    end; // end generation of random effect codes


    // Next, add covariates
    if NCovIndep > 0 then
    begin
        for j := 1 to NCovIndep do
        begin
            CovIndepPos[j-1] := gencount;
            for i := 1 to NoCases do
            begin
                k := CovIndepID[j-1];
                DataGrid[i-1,gencount] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i]));
            end;
            GenLabels[gencount] := CovariateCode.Items.Strings[j-1];
            gencount := gencount + 1;
        end;
    end; // end generation of covariate codes

    // if repeated measures used, copy generated vectors for each replication
    if NReptDep > 0 then
    begin
         for j := 1 to NReptDep - 1 do
         begin
              for i := 1 to NoCases do
              begin
                   for k := lastdep + (NoCases-1) +(NReptDep-1) + 1 to gencount do
                   begin
                        value := DataGrid[i-1,k-1];
                        row := (j * NoCases) + i - 1;
                        DataGrid[row,k-1] := value;
                   end; // next k column in data grid
              end; // next case
         end; // next repeated measure
    end; // if repeated measures used

    // Now generate product vectors for the interactions
    if NoInterDefs > 0 then
    begin
        for j := 0 to NoInterDefs - 1 do
        begin
            // parse an interaction line into components (abbreviations) and
            // get product of vectors corresponding to each
            InteractPos[j] := gencount;
            cellstring := InteractList.Items.Strings[j];
            GenInterVecs(cellstring);
            gencount := gencount + NInteractVecs[j];
        end;
    end; // end generation of interaction codes
    codepattern := nil;
end;

procedure TGLMFrm.ModelIAnalysis(AReport: TStrings);
var
  block, i, j, k, NEntered, index, noblocks, priorentered : integer;
  cellstring : string;
  labelstr : string;
  R, R2Increment, SSx, sum, constant, FullR2 : double;
  df1, df2, F, FProbF, StdErrB, PredSS, PredMS : double;
  SSt, VarEst, SSres, StdErrEst, AdjR2 : double;
begin
  NEntered := 0;
  priorentered := 0;
  OldR2 := 0;

  // enter the dependent variable first
  if NContDep > 0 then
  begin
      ColSelected[0] := ContDepPos[0];
      Labels[0] := GenLabels[1];
  end
  else begin
      ColSelected[0] := ReptDepPos[0];
      Labels[0] := GenLabels[1];
  end;
  NEntered := NEntered + 1;

  // Enter independent variables as indicated in indorderbox then interactions
  // until the total model is analyzed.  Then delete each term to get a
  // restricted model and compare to the full model.
  noblocks := IndOrderBox.Items.Count;
  SetLength(TypeISS,noblocks);
  SetLength(TypeIISS,noblocks);
  SetLength(TypeIMS,noblocks);
  SetLength(TypeIIMS,noblocks);
  SetLength(TypeIDF1,noblocks);
  SetLength(TypeIDF2,noblocks);
  SetLength(TypeIIDF1,noblocks);
  SetLength(TypeIIDF2,noblocks);
  SetLength(TypeIF,noblocks);
  SetLength(TypeIProb,noblocks);
  SetLength(TypeIIF,noblocks);
  SetLength(TypeIIProb,noblocks);

  for block := 0 to noblocks - 1 do
  begin
    // get index of the abbreviation of term to enter and find corresponding

      // vector(s) to place in the equation
    cellstring := IndOrderBox.Items.Strings[block];
    // check for covariates first
    if NCovIndep > 0 then
    begin
      for i := 0 to NCovIndep-1 do
      begin
        if cellstring = CovariateCode.Items.Strings[i] then // matched!
        begin
          index := i; // index of covariate code
          ColSelected[NEntered] := CovIndepPos[index];
          labelstr := Format('%s', [CovariateCode.Items[index]]);
          Labels[NEntered] := labelstr;
          NEntered := NEntered + 1;
          break;
        end;
      end;
    end;

    // check for fixed effect variables next
    if NFixedIndep > 0 then
    begin
      for i := 0 to NFixedIndep-1 do
      begin
        if cellstring = FixedIndepCode.Items.Strings[i] then
        begin
          index := i;
          for j := 0 to NFixVecIndep[index]-1 do
          begin
            ColSelected[NEntered] := FixedIndepPos[index] + j;
            labelstr := Format('%s_%d',[FixedIndepCode.Items[index],j+1]);
            Labels[NEntered] := labelstr;
            NEntered := NEntered + 1;
          end;
          break;
        end;
      end;
    end;

    // Check for random effects variables next
    if NRndIndep > 0 then
    begin
      for i := 0 to NRndIndep-1 do
      begin
        if cellstring = RndIndepCode.Items.Strings[i] then
        begin
          index := i;
          for j := 0 to NRndVecIndep[index]-1 do
          begin
            ColSelected[NEntered] := RndIndepPos[index] + j;
            labelstr := Format('%s_%d',[RndIndepCode.Items[index],j+1]);
            Labels[NEntered] := labelstr;
            NEntered := NEntered + 1;
          end;
          break;
        end;
      end;
    end;

    // check for interactions next
    if NoInterDefs > 0 then
    begin
      for i := 0 to NoInterDefs-1 do
      begin
        if cellstring = InteractList.Items.Strings[i] then
        begin
          for j := 0 to NInteractVecs[i]-1 do
          begin
            ColSelected[NEntered] := InteractPos[i] + j;
            labelstr := Format('%s%d_%d',['IA',i+1,j+1]);
            Labels[NEntered] := labelstr;
            NEntered := NEntered + 1;
          end;
          break;
        end;
      end;
    end; // check for interaction variables

    // check for repeated measures variables (person codes)
    if NReptDep > 0 then
    begin  // look for 'IP' in cellstring
      labelstr := copy(cellstring,0,2);
      if labelstr = 'IP' then // person vectors were generated
      begin
        for i := 0 to NoCases - 2 do
        begin
          ColSelected[NEntered] := ReptIndepPos[i];
          Labels[NEntered] := GenLabels[ReptIndepPos[i]];
          NEntered := NEntered + 1;
        end;
      end;
    end;

    // check for repeated treatments
    if NReptDep > 0 then
    begin  // look for 'IR' in cellstring
      labelstr := copy(cellstring,0,2);
      if labelstr = 'IR' then // repeated treatment vectors were generated
      begin
        for i := 0 to NReptDep - 2 do
        begin
          ColSelected[NEntered] := ReptTrtPos[i];
          Labels[NEntered] := GenLabels[ReptTrtPos[i]];
          NEntered := NEntered + 1;
        end;
      end;
    end;

    RegAnal(NEntered, AReport);
    R := sqrt(R2);
    df1 := Nentered - 1; // no. of independent variables
    df2 := totalobs - df1 - 1; // N - no. independent - 1
    SSt := (totalobs-1) * Vars[0];
    SSres := SSt * (1.0 - R2);
    VarEst := SSres / df2;
    if (VarEst > 0.0) then
      StdErrEst := sqrt(VarEst)
    else
    begin
      ErrorMsg('Error in computing variance estimate.');
      StdErrEst := 0.0;
    end;
    if (R2 < 1.0) and (df2 > 0.0) then
      F := (R2 / df1) / ((1.0-R2)/ df2)
    else
      F := 0.0;
    FProbF := probf(F,df1,df2);
    AdjR2 := 1.0 - (1.0 - R2) * (totalobs - 1) / df2;

    AReport.Add('   R         R2         F      Prob. > F   DF1   DF2 ');
    AReport.Add('-------- ---------- ---------- ---------- ----- -----');
    AReport.Add('%8.3f %10.3f %10.3f %10.3f %5.0f %5.0f', [R, R2, F, FProbF, df1, df2]);
    AReport.Add('');
    AReport.Add('Adjusted R Squared:     %10.3f', [AdjR2]);
    AReport.Add('Std. Error of Estimate: %10.3f', [StdErrEst]);
    AReport.Add('');
    AReport.Add('Variable      Beta        B      Std.Error      t      Prob. > t ');
    AReport.Add('---------- ---------- ---------- ---------- ---------- ----------');
    df1 := 1.0;
    sum := 0.0;
    for i := 0 to Nentered - 2 do
    begin
      SSx := (totalobs-1) * Vars[i+1];
      sum  := sum + B[i] * means[i+1];
      if invmatrix[i,i] > 1.0e-15 then
      begin
        StdErrB := VarEst / (SSx * (1.0 / invmatrix[i,i]));
        StdErrB := sqrt(StdErrB);
        if StdErrB > 0.0 then F := B[i] / StdErrB else F := 0.0;
        FProbF := probf(F*F,df1,df2);
      end else
      begin
        StdErrB := 0.0;
        F := 0.0;
        FProbF := 0.0;
      end;
      AReport.Add('%10s %10.3f %10.3f %10.3f %10.3f %10.3f', [Labels[i+1], Beta[i] ,B[i], StdErrB, F, FProbF]);
    end;
    AReport.Add('');
    constant := means[0] - sum;
    AReport.Add('Constant:               %10.3f', [constant]);

    // test increment in R2 for this block
    R2Increment := R2 - OldR2;
    if priorentered > 0 then
      df1 := (NEntered-1) - (priorentered-1)
    else
      df1 := NEntered - 1;
    df2 := totalobs - NEntered;
    TypeIDF1[block] := df1;
    TypeIDF2[block] := df2;
    TypeISS[block] := (R2 - OldR2) * SSt;
    TypeIMS[block] := TypeISS[block] / df1;
    F := ((R2 - OldR2)/ df1) / ((1.0 - R2) / df2);
    TypeIF[block] := F;
    FProbF := probf(F,df1,df2);
    TypeIProb[block] := FProbF;
    AReport.Add('Increment in Squared R: %10.3f', [R2Increment]);
    AReport.Add('F:                      %10.3f', [F]);
    AReport.Add('    with d.o.f.         %10.0f and %.0f',[df1, df2]);  // df is double! - why?
    AReport.Add('    and Prob > F        %10.3f', [FProbF]);

    AReport.Add('');
    AReport.Add(DIVIDER);
    AReport.Add('');

    OldR2 := R2;
    priorentered := NEntered;
    // setup for next block analysis
    WorkMat := nil;
    StdDevs := nil;
    Vars := nil;
    means := nil;
    Beta := nil;
    B := nil;
    invmatrix := nil;
    rxy := nil;
    indmatrix := nil;
    rmatrix := nil;
  end; // next variable block

  // Next, obtain the unique (Type II values) by elimination of each block
  // from the full model and testing the decrement in R2
  FullR2 := R2; // save previously obtained full model R2
  for i := 0 to NoBlocks - 1 do
  begin
    NEntered := 0;
    // enter the dependent variable first
    if NContDep > 0 then
    begin
      ColSelected[0] := ContDepPos[0];
      Labels[0] := GenLabels[1];
    end
    else begin
      ColSelected[0] := ReptDepPos[0];
      Labels[0] := GenLabels[1];
    end;
    NEntered := NEntered + 1;
    for block := 0 to NoBlocks - 1 do
    begin
      if i = block then
        continue // delete this block
      else
      begin // enter the remaining blocks
        cellstring := IndOrderBox.Items.Strings[block];
        // if a covariate, include it
        if NCovIndep > 0 then
        begin
          for j := 0 to NCovIndep-1 do
          begin
            if cellstring = CovariateCode.Items.Strings[j] then // matched!
            begin
              index := j; // index of covariate code
              ColSelected[NEntered] := CovIndepPos[index];
              Labels[NEntered] := Format('%s', [CovariateCode.Items[index]]);
              NEntered := NEntered + 1;
              break;
            end;
          end;
        end;
        // check for fixed effect variables next
        if NFixedIndep > 0 then
        begin
          for j := 0 to NFixedIndep-1 do
          begin
            if cellstring = FixedIndepCode.Items.Strings[j] then
            begin
              index := j;
              for k := 0 to NFixVecIndep[index]-1 do
              begin
                ColSelected[NEntered] := FixedIndepPos[index] + k;
                Labels[NEntered] := Format('%s_%d', [FixedIndepCode.Items[index], k+1]);
                NEntered := NEntered + 1;
              end;
              break;
            end;
          end;
        end;
        // Check for random effects variables next
        if NRndIndep > 0 then
        begin
          for j := 0 to NRndIndep-1 do
          begin
            if cellstring = RndIndepCode.Items.Strings[j] then
            begin
              index := j;
              for k := 0 to NRndVecIndep[index]-1 do
              begin
                ColSelected[NEntered] := RndIndepPos[index] + k;
                Labels[NEntered] := Format('%s_%d', [RndIndepCode.Items[index], k+1]);
                NEntered := NEntered + 1;
              end;
            end;
            break;
          end;
        end;
        // check for interactions next
        if NoInterDefs > 0 then
        begin
          for j := 0 to NoInterDefs-1 do
          begin
            if cellstring = InteractList.Items.Strings[j] then
            begin
              for k := 0 to NInteractVecs[j]-1 do
              begin
                ColSelected[NEntered] := InteractPos[j] + k;
                Labels[NEntered] := Format('%s%d_%d', ['IA', j+1, k+1]);
                NEntered := NEntered + 1;
              end;
              break;
            end; // end if
          end; // next j
        end; // end if interdefs > 0
      end; // entry of remaining blocks
    end; // enter next block not equal to block i

    RegAnal(NEntered, AReport); // compute restricted model

    if R2 > 0.0 then R := sqrt(R2) else R := 0.0;
    df1 := Nentered; // no. of independent variables
    df2 := totalobs - df1 - 1; // N - no. independent - 1
    SSt := (totalobs-1) * Vars[0];
    SSres := SSt * (1.0 - R2);
    VarEst := SSres / df2;
    if (VarEst > 0.0) then
      StdErrEst := sqrt(VarEst)
    else
    begin
      ErrorMsg('Error in computing variance estimate.');
      StdErrEst := 0.0;
    end;
    if (R2 < 1.0) and (df2 > 0.0) then F := (R2 / df1) / ((1.0-R2)/ df2)
    else F := 0.0;
    FProbF := probf(F,df1,df2);
    AdjR2 := 1.0 - (1.0 - R2) * (totalobs - 1) / df2;

    AReport.Add('   R         R2         F      Prob. > F   DF1   DF2 ');
    AReport.Add('-------- ---------- ---------- ---------- ----- -----');
    AReport.Add('%8.3f %10.3f %10.3f %10.3f %5.0f %5.0f', [R, R2, F, FProbF, df1, df2]);
    AReport.Add('');
    AReport.Add('Adjusted R Squared:     %10.3f', [AdjR2]);
    AReport.Add('Std. Error of Estimate: %10.3f', [StdErrEst]);
    AReport.Add('');
    AReport.Add('Variable      Beta        B      Std.Error      t      Prob. > t ');
    AReport.Add('---------- ---------- ---------- ---------- ---------- ----------');

    df1 := 1.0;
    sum := 0.0;
    for j := 0 to Nentered - 2 do
    begin
        SSx := (totalobs-1) * Vars[j+1];
        sum  := sum + B[j] * means[j+1];
        if invmatrix[j,j] > 1.0e-18 then
            StdErrB := VarEst / (SSx * (1.0 / invmatrix[j,j]))
        else StdErrB := 0.0;
        if StdErrB > 0.0 then StdErrB := sqrt(StdErrB);
        if StdErrB > 0.0 then F := B[j] / StdErrB else F := 0.0;
        FProbF := probf(F*F,df1,df2);
        AReport.Add('%10s %10.3f %10.3f %10.3f %10.3f %10.3f', [Labels[j+1], Beta[j] ,B[j], StdErrB, F, FProbF]);
    end;
    AReport.Add('');
    constant := means[0] - sum;
    AReport.Add('Constant:               %10.3f', [constant]);

    // Now compute unique contribution of block left out (Type II)
    R2Increment := FullR2 - R2;
    df1 := (novars - 2) - (NEntered - 1); // k1 - k2
    df2 := totalobs - (novars - 2) - 1;
    TypeIIDF1[i] := df1;
    TypeIIDF2[i] := df2;
    TypeIISS[i] := (FullR2 - R2) * SSt;
    TypeIIMS[i] := TypeIISS[i] / df1;
    F := ((FullR2 - R2)/ df1) / ((1.0 - FullR2) / df2);
    TypeIIF[i] := F;
    FProbF := probf(F,df1,df2);
    TypeIIProb[i] := FProbF;

    AReport.Add('Decrement in Squared R: %10.3f', [R2Increment]);
    AReport.Add('F:                      %10.3f', [F]);
    AReport.Add('    with d.o.f.         %10.0f and %.0f',[df1, df2]);
    AReport.Add('    and Prob > F        %10.3f', [FProbF]);

    AReport.Add('');
    AReport.Add(DIVIDER);
    AReport.Add('');

    // setup for next block analysis
    WorkMat := nil;
    StdDevs := nil;
    Vars := nil;
    means := nil;
    Beta := nil;
    B := nil;
    invmatrix := nil;
    rxy := nil;
    indmatrix := nil;
    rmatrix := nil;
  end; // next i block selected for elimination

  // Show summary table of Type I and Type II tests
  AReport.Add('SUMMARY TABLE FOR GLM EFFECTS');
  AReport.Add('');
  AReport.Add('Incremental Effects:');
  AReport.Add('SOURCE     DF1  DF2      SS         MS         F      Prob > F');
  AReport.Add('---------- ---- ---- ---------- ---------- ---------- --------');
  for i := 0 to NoBlocks - 1 do
  begin
    cellstring := IndOrderBox.Items.Strings[i];
    AReport.Add('%10s %4.0f %4.0f %10.3f %10.3f %10.3f %8.3f',
      [cellstring,TypeIDF1[i],TypeIDF2[i],TypeISS[i],TypeIMS[i],TypeIF[i],TypeIProb[i]]
    );
  end;
  AReport.Add('');
  AReport.Add('Unique Effects:');
  AReport.Add('SOURCE     DF1  DF2      SS         MS         F      Prob > F');
  AReport.Add('---------- ---- ---- ---------- ---------- ---------- --------');
  for i := 0 to NoBlocks - 1 do
  begin
    cellstring := IndOrderBox.Items.Strings[i];
    AReport.Add('%10s %4.0f %4.0f %10.3f %10.3f %10.3f %8.3f',
      [cellstring,TypeIIDF1[i],TypeIIDF2[i],TypeIISS[i],TypeIIMS[i],TypeIIF[i],TypeIIProb[i]]
    );
  end;

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  // Show Anova Results for fixed and/or covariates
  if (NRndIndep = 0) and (NReptDep = 0) then // must be fixed and/or covariate only design
  begin
    if (NFixedIndep > 0) or (NCovIndep > 0) then // fixed effects
    begin
      df1 := novars - 2; // k1 (note: novars contains ID variable, dep, independents)
      PredSS := SSt * FullR2;
      PredMS := PredSS / df1;
      df2 := totalobs - df1 - 1; // residual df
      SSres := SSt * (1.0 - FullR2);
      VarEst := SSres / df2; // ms residual
      F := PredMS / VarEst;
      FProbF := probf(F,df1,df2);
      AReport.Add('SOURCE                DF      SS         MS         F      Prob > F');
      AReport.Add('-------------------- ---- ---------- ---------- ---------- --------');
      AReport.Add('%20s %4.0f %10.3f %10.3f %10.3f %8.3f', ['Full Model', df1, PredSS, PredMS, F, FProbF]);
      for i := 0 to NoBlocks - 1 do
      begin
        F := TypeIMS[i] / VarEst;
        FProbF := probf(F,TypeIDF1[i],df2);
        cellstring := IndOrderBox.Items.Strings[i];
        AReport.Add('%20s %4.0f %10.3f %10.3f %10.3f %8.3f', [cellstring, TypeIDF1[i], TypeISS[i], TypeIMS[i], F, FProbF]);
      end;
      AReport.Add('%20s %4.0f %10.3f %10.3f', ['Residual', df2, SSres, VarEst]);
      AReport.Add('%20s %4d %10.3f', ['Total', totalobs-1, SSt]);
      AReport.Add('');
      AReport.Add(DIVIDER);
      AReport.Add('');
    end;
  end;

  // Show Anova Results for random effects and/or covariates
  if (NFixedIndep = 0) and (NReptDep = 0) then // must be random only or covariate only design
  begin
    if (NRndIndep > 0) or (NCovIndep > 0) then // random and/or covariate effects
    begin
      df1 := novars - 2; // k1 (note: novars contains ID variable, dep, independents)
      PredSS := SSt * FullR2;
      PredMS := PredSS / df1;
      df2 := totalobs - df1 - 1; // residual df
      SSres := SSt * (1.0 - FullR2);
      VarEst := SSres / df2; // ms residual
      F := PredMS / VarEst;
      FProbF := probf(F,df1,df2);
      AReport.Add('SOURCE                DF      SS         MS         F      Prob > F');
      AReport.Add('-------------------- ---- ---------- ---------- ---------- --------');
      AReport.Add('%20s %4.0f %10.3f %10.3f %10.3f %8.3f', ['Full Model', df1, PredSS, PredMS, F, FProbF]);
      for i := 0 to NoBlocks - 1 do
      begin
        F := TypeIMS[i] / VarEst;
        FProbF := probf(F,TypeIDF1[i],df2);
        AReport.Add('%20s %4.0f %10.3f %10.3f %10.3f %8.3f', [Labels[i+1], TypeIDF1[i], TypeISS[i], TypeIMS[i], F, FProbF]);
      end;
      AReport.Add('%20s %4.0f %10.3f %10.3f', ['Residual', df2, SSres, VarEst]);
      AReport.Add('%20s %4d %10.3f', ['Total', totalobs-1, SSt]);
      AReport.Add('');
      AReport.Add(DIVIDER);
      AReport.Add('');
    end;
  end;

  // show effects for repeated measures ANOVA (and covariates)
  if NReptDep > 0 then
  begin
    df1 := novars - 2; // k1 (note: novars contains ID variable, dep, independents)
    PredSS := SSt * FullR2;
    PredMS := PredSS / df1;
    df2 := totalobs - df1 - 1; // residual df
    SSres := SSt * (1.0 - FullR2);
    VarEst := SSres / df2; // ms residual
    F := PredMS / VarEst;
    FProbF := probf(F,df1,df2);
    AReport.Add('SOURCE                DF      SS         MS         F      Prob > F');
    AReport.Add('-------------------- ---- ---------- ---------- ---------- --------');
    AReport.Add('%20s %4.0f %10.3f %10.3f %10.3f %8.3f', ['Full Model', df1, PredSS, PredMS, F, FProbF]);
    for i := 0 to NoBlocks - 1 do
    begin
      F := TypeIMS[i] / VarEst;
      FProbF := probf(F,TypeIDF1[i],df2);
      AReport.Add('%20s %4.0f %10.3f %10.3f %10.3f %8.3f', [Labels[i+1], TypeIDF1[i], TypeISS[i], TypeIMS[i], F, FProbF]);
    end;
    AReport.Add('%20s %4.0f %10.3f %10.3f', ['Residual', df2, SSres, VarEst]);
    AReport.Add('%20s %4d %10.3f', ['Total', totalobs-1, SSt]);
    AReport.Add('');
    AReport.Add(DIVIDER);
    AReport.Add('');
  end;

  // clean up the heap
  TypeIIProb := nil;
  TypeIIF := nil;
  TypeIProb := nil;
  TypeIF := nil;
  TypeIIDF2 := nil;
  TypeIIDF1 := nil;
  TypeIDF2 := nil;
  TypeIDF1 := nil;
  TypeIIMS := nil;
  TypeIMS := nil;
  TypeIISS := nil;
  TypeISS := nil;
end;

procedure TGLMFrm.ModelIIAnalysis(AReport: TStrings);
var
    block, i, j, NEntered, index, noblocks : integer;
    NLeft, NRight : integer;
    cellstring : string;
    labelstr : string;
begin
    NEntered := 0;
    OldR2 := 0;
    // enter the dependent variables first
    if NContDep > 0 then
    begin
         for i := 0 to NContDep - 1 do
         begin
              ColSelected[i] := ContDepPos[i];
              Labels[i] := GenLabels[i+1];
              NEntered := NEntered + 1;
         end;
    end;
    if NReptDep > 0 then
    begin
         for i := 0 to NReptDep - 1 do
         begin
              ColSelected[NEntered+i] := ReptDepPos[i];
              Labels[NEntered+i] := GenLabels[NEntered+i+1];
              NEntered := NEntered + 1;
         end;
    end;
    if NCatDep > 0 then
    begin
         for i := 0 to NCatDep - 1 do
         begin
              for j := 0 to NFixVecDep[i]-1 do
              begin
                   ColSelected[NEntered+j] := CatDepPos[j];
                   Labels[NEntered+j] := GenLabels[NEntered+j+1];
                   NEntered := NEntered + 1;
              end;
         end;
    end;

    // Enter the no. of dependent variables in the left list box of canonical
    NLeft := NEntered;

    // Enter independent variables as indicated in indorderbox then interactions
    // until the total model is analyzed.  Then delete each term to get a
    // restricted model and compare to the full model.
    noblocks := IndOrderBox.Items.Count;
    SetLength(TypeISS,noblocks);
    SetLength(TypeIISS,noblocks);
    SetLength(TypeIMS,noblocks);
    SetLength(TypeIIMS,noblocks);
    SetLength(TypeIDF1,noblocks);
    SetLength(TypeIDF2,noblocks);
    SetLength(TypeIIDF1,noblocks);
    SetLength(TypeIIDF2,noblocks);
    SetLength(TypeIF,noblocks);
    SetLength(TypeIProb,noblocks);
    SetLength(TypeIIF,noblocks);
    SetLength(TypeIIProb,noblocks);

    for block := 0 to noblocks - 1 do
    begin
        // get index of the abbreviation of term to enter and find corresponding
        // vector(s) to place in the equation
        cellstring := IndOrderBox.Items.Strings[block];
        // check for covariates first
        if NCovIndep > 0 then
        begin
            for i := 0 to NCovIndep-1 do
            begin
                if cellstring = CovariateCode.Items.Strings[i] then // matched!
                begin
                    index := i; // index of covariate code
                    ColSelected[NEntered] := CovIndepPos[index];
                    labelstr := format('%s',[CovariateCode.Items.Strings[index]]);
                    Labels[NEntered] := labelstr;
                    NEntered := NEntered + 1;
                    break;
                end;
            end;
        end;
        // check for fixed effect variables next
        if NFixedIndep > 0 then
        begin
            for i := 0 to NFixedIndep-1 do
            begin
                if cellstring = FixedIndepCode.Items.Strings[i] then
                begin
                    index := i;
                    for j := 0 to NFixVecIndep[index]-1 do
                    begin
                        ColSelected[NEntered] := FixedIndepPos[index] + j;
                        labelstr := format('%s_%d',[FixedIndepCode.Items.Strings[index],j+1]);
                        Labels[NEntered] := labelstr;
                        NEntered := NEntered + 1;
                    end;
                    break;
                end;
            end;
        end;
        // Check for random effects variables next
        if NRndIndep > 0 then
        begin
            for i := 0 to NRndIndep-1 do
            begin
                if cellstring = RndIndepCode.Items.Strings[i] then
                begin
                    index := i;
                    for j := 0 to NRndVecIndep[index]-1 do
                    begin
                        ColSelected[NEntered] := RndIndepPos[index] + j;
                        labelstr := format('%s_%d',[RndIndepCode.Items.Strings[index],j+1]);
                        Labels[NEntered] := labelstr;
                        NEntered := NEntered + 1;
                    end;
                end;
                break;
            end;
        end;
        // check for interactions next
        if NoInterDefs > 0 then
        begin
            for i := 0 to NoInterDefs-1 do
            begin
                if cellstring = InteractList.Items.Strings[i] then
                begin
                    for j := 0 to NInteractVecs[i]-1 do
                    begin
                        ColSelected[NEntered] := InteractPos[i] + j;
                        labelstr := format('%s%d_%d',['IA',i+1,j+1]);
                        Labels[NEntered] := labelstr;
                        NEntered := NEntered + 1;
                    end;
                end;
                break;
            end;
        end; // check for interaction variables

        // check for repeated measures variables (person codes)
        if NReptDep > 0 then
        begin  // look for 'IP' in cellstring
             labelstr := copy(cellstring,0,2);
             if labelstr = 'IP' then // person vectors were generated
             begin
                  for i := 0 to NoCases - 2 do
                  begin
                       ColSelected[NEntered] := ReptIndepPos[i];
                       Labels[NEntered] := GenLabels[ReptIndepPos[i]];
                       NEntered := NEntered + 1;
                  end;
             end;
        end;

        // Enter the independent variables in the right list of canonical.
        NRight := NEntered - NLeft;

        // call cancor routine for this block
        CanCor(NLeft, NRight, ColSelected, AReport);
    end; // next block

    TypeIIProb := nil;
    TypeIIF := nil;
    TypeIProb := nil;
    TypeIIDF2 := nil;
    TypeIIDF1 := nil;
    TypeIDF2 := nil;
    TypeIDF1 := nil;
    TypeIIMS := nil;
    TYPEIMS := nil;
    TypeIISS := nil;
    TypeISS := nil;
end;

procedure TGLMFrm.ModelIIIAnalysis(AReport: TStrings);
var
  block, i, j, NEntered, index, noblocks: integer;
  cellstring : string;
  labelstr : string;
  effstr : string;
  R, SSx, sum, constant: double;
  df1, df2, F, FProbF, StdErrB: double;
  SSt, VarEst, SSres, StdErrEst, AdjR2 : double;
  dfbetween, dferrbetween, dfwithin, dferrwithin : double;
  ssbetween, sserrbetween, mserrbetween, sswithin, sserrwithin,  mserrwithin : double;
  betweenblock : integer;
  totalss, totaldf : double;
begin
  OldR2 := 0;
  ColSelected[0] := ReptDepPos[0];
  Labels[0] := GenLabels[1];
  // Complete an individual regression analysis for each between subjects var.
  // Enter each block containing between subjects variance including:
  // (1)  covariates
  // (2)  person vectors
  // (3)  fixed or random factors
  // (4)  the interactions among only fixed or random effects
  noblocks := IndOrderBox.Items.Count;
  SetLength(TypeISS,noblocks); // use for between subject effects
  SetLength(TypeIISS,noblocks);// use for within subject effects
  SetLength(TypeIMS,noblocks);
  SetLength(TypeIIMS,noblocks);
  SetLength(TypeIDF1,noblocks);
  SetLength(TypeIDF2,noblocks);
  SetLength(TypeIIDF1,noblocks);
  SetLength(TypeIIDF2,noblocks);
  SetLength(TypeIF,noblocks);
  SetLength(TypeIProb,noblocks);
  SetLength(TypeIIF,noblocks);
  SetLength(TypeIIProb,noblocks);

  for i := 0 to noblocks - 1 do
  begin
    TypeISS[i] := -1.0; // store indicator for block (-1 indicates no use)
    TypeIISS[i] := -1.0;
  end;

  for block := 0 to noblocks - 1 do
  begin
    ColSelected[0] := ReptDepPos[0];
    Labels[0] := GenLabels[1];
    NEntered := 1;
    cellstring := IndOrderBox.Items.Strings[block];
    effstr := cellstring;
    j := Pos('IR',cellstring);
    if j <> 0 then continue;

    // check for repeated measures variables (person codes)
    if NReptDep > 0 then
    begin  // look for 'IP' in cellstring
      labelstr := copy(cellstring,0,2);
      if labelstr = 'IP' then // person vectors were generated
      begin
        betweenblock := block; // save block no. of between subject vectors
        for i := 0 to NoCases - 2 do
        begin
          ColSelected[NEntered] := ReptIndepPos[i];
          Labels[NEntered] := GenLabels[ReptIndepPos[i]];
          NEntered := NEntered + 1;
        end;
      end;
    end;

    // check for fixed effect variables next
    if NFixedIndep > 0 then
    begin
      for i := 0 to NFixedIndep-1 do
      begin
        if cellstring = FixedIndepCode.Items.Strings[i] then
        begin
          index := i;
          for j := 0 to NFixVecIndep[index]-1 do
          begin
            ColSelected[NEntered] := FixedIndepPos[index] + j;
            labelstr := Format('%s_%d', [FixedIndepCode.Items[index], j+1]);
            Labels[NEntered] := labelstr;
            NEntered := NEntered + 1;
          end;
          break;
        end;
      end;
    end;

    // Check for random effects variables next
    if NRndIndep > 0 then
    begin
      for i := 0 to NRndIndep-1 do
      begin
        if cellstring = RndIndepCode.Items.Strings[i] then
        begin
          index := i;
          for j := 0 to NRndVecIndep[index]-1 do
          begin
            ColSelected[NEntered] := RndIndepPos[index] + j;
            labelstr := Format('%s_%d', [RndIndepCode.Items[index], j+1]);
            Labels[NEntered] := labelstr;
            NEntered := NEntered + 1;
          end;
          break;
        end;
      end;
    end;

    // check for interactions next
    if NoInterDefs > 0 then
    begin
      for i := 0 to NoInterDefs-1 do
      begin
        if cellstring = InteractList.Items.Strings[i] then
        begin
          // eliminate any interactions containing 'IR'
          j := Pos('IR',cellstring);
          if j <> 0 then continue;
          for j := 0 to NInteractVecs[i]-1 do
          begin
            ColSelected[NEntered] := InteractPos[i] + j;
            labelstr := Format('%s%d_%d', ['IA',i+1,j+1]);
            Labels[NEntered] := labelstr;
            NEntered := NEntered + 1;
          end;
          break;
        end;
      end;
    end; // check for interaction variables

    // check for covariates
    if NCovIndep > 0 then
    begin
      for i := 0 to NCovIndep-1 do
      begin
        if cellstring = CovariateCode.Items.Strings[i] then // matched!
        begin
          index := i; // index of covariate code
          ColSelected[NEntered] := CovIndepPos[index];
          labelstr := Format('%s', [CovariateCode.Items[index]]);
          Labels[NEntered] := labelstr;
          NEntered := NEntered + 1;
          break;
        end;
      end;
    end;

    // do reg analysis and save sum of squares
    RegAnal(NEntered, AReport);
    R := sqrt(R2);
    df1 := Nentered - 1; // no. of independent variables
    TypeIDF1[block] := df1;
    df2 := totalobs - df1 - 1; // N - no. independent - 1
    SSt := (totalobs-1) * Vars[0];
    SSres := SSt * (1.0 - R2);
    VarEst := SSres / df2;

    if (VarEst > 0.0) then
      StdErrEst := sqrt(VarEst)
    else
    begin
      ErrorMsg('Error in computing variance estimate.');
      StdErrEst := 0.0;
    end;

    if (R2 < 1.0) and (df2 > 0.0) then
      F := (R2 / df1) / ((1.0-R2)/ df2)
    else
      F := 0.0;
    FProbF := probf(F,df1,df2);
    AdjR2 := 1.0 - (1.0 - R2) * (totalobs - 1) / df2;

    AReport.Add('   R         R2         F      Prob. > F   DF1   DF2 ');
    AReport.Add('-------- ---------- ---------- ---------- ----- -----');
    AReport.Add('%8.3f %10.3f %10.3f %10.3f %5.0f %5.0f', [R, R2, F, FProbF, df1, df2]);
    AReport.Add('Adjusted R Squared:     %10.3f', [AdjR2]);
    AReport.Add('');
    AReport.Add('Std. Error of Estimate: %10.3f', [StdErrEst]);
    AReport.Add('');
    AReport.Add('Variable      Beta        B      Std.Error      t      Prob. > t ');
    AReport.Add('---------- ---------- ---------- ---------- ---------- ----------');

    df1 := 1.0;
    sum := 0.0;
    for i := 0 to Nentered - 2 do
    begin
      SSx := (totalobs-1) * Vars[i+1];
      sum  := sum + B[i] * means[i+1];
      if invmatrix[i,i] > 1.0e-15 then
      begin
        StdErrB := VarEst / (SSx * (1.0 / invmatrix[i,i]));
        StdErrB := sqrt(StdErrB);
        if StdErrB > 0.0 then F := B[i] / StdErrB else F := 0.0;
        FProbF := probf(F*F,df1,df2);
      end
      else begin
        StdErrB := 0.0;
        F := 0.0;
        FProbF := 0.0;
      end;
      cellstring := Format('%10s', [Labels[i+1]]);
      AReport.Add('%10s %10.3f %10.3f %10.3f %10.3f %10.3f', [cellstring, Beta[i] ,B[i], StdErrB, F, FProbF]);
    end;
    constant := means[0] - sum;
    AReport.Add('Constant:          %10.3f', [constant]);
    TypeISS[block] := R2 * SST;
    AReport.Add('BETWEEN SUBJECT EFFECT:');
    AReport.Add('SS for %-10s: %10.3f',[effstr,TypeISS[block]]);
    AReport.Add('SS TOTAL:          %10.3f',[SST]);
    AReport.Add('');
    AReport.Add(DIVIDER);
    AReport.Add('');
  end;

  // Summarize between subject effects
  totalss := 0.0;
  totaldf := 0.0;
  for i := 0 to noblocks - 1 do
  begin
    if TypeISS[i] < 0.0 then continue;
    if betweenblock = i then
    begin
      ssbetween := TypeISS[i];
      dfbetween := TypeIDF1[i];
    end
    else
    begin
      totalss := totalss + TypeISS[i];
      totaldf := totaldf + TypeIDF1[i];
    end;
  end;
  sserrbetween := ssbetween - totalss;
  dferrbetween := dfbetween - totaldf;
  mserrbetween := sserrbetween / dferrbetween;

  AReport.Add('SUMMARY OF BETWEEN SUBJECT EFFECTS');
  AReport.Add('SOURCE                DF       SS        MS        F       Prob > F');
  AReport.Add('-------------------- ---- ---------- ---------- ---------- --------');
  AReport.Add('%-20s %4.0f %10.3f', ['Between Subjects', dfbetween, ssbetween]);
  for i := 0 to noblocks - 1 do
  begin
    if TypeISS[i] < 0.0 then continue;
    if betweenblock = i then continue; // already done above
    TypeIMS[i] := TypeISS[i] / TypeIDF1[i];
    TypeIF[i] := TypeIMS[i] / mserrbetween;
    TypeIDF2[i] := dferrbetween;
    TypeIProb[i] := probf(TypeIF[i],TypeIDF1[i],TypeIDF2[i]);
    AReport.Add('%20s %4.0f %10.3f %10.3f %10.3f %10.3f',
      [IndOrderBox.Items[i], TypeIDF1[i], TypeISS[i], TypeIMS[i], TypeIF[i], TypeIProb[i]]
    );
  end;
  AReport.Add('%20s %4.0f %10.3f %10.3f', ['Error Between', dferrbetween, sserrbetween, mserrbetween]);
  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  // Now, get within subject effects
  sswithin := SST - SSbetween;
  dfwithin := totalobs - dfbetween - 1;
  for block := 0 to noblocks - 1 do
  begin
    ColSelected[0] := ReptDepPos[0];
    Labels[0] := GenLabels[1];
    NEntered := 1;
    cellstring := IndOrderBox.Items.Strings[block];
    effstr := cellstring;
    j := Pos('IR',cellstring);
    if j = 0 then continue; // only select those for rep. treatments or interactions

    // check for treatments
    if NReptDep > 0 then
    begin  // look for 'IR' in cellstring
      labelstr := copy(cellstring,0,2);
      if labelstr = 'IR' then // repeated treatment vectors were generated
      begin
        for i := 0 to NReptDep - 2 do
        begin
          ColSelected[NEntered] := ReptTrtPos[i];
          Labels[NEntered] := GenLabels[ReptTrtPos[i]];
          NEntered := NEntered + 1;
        end;
      end;
    end;

    // check for interactions next
    if NoInterDefs > 0 then
    begin
      for i := 0 to NoInterDefs-1 do
      begin
        if cellstring = InteractList.Items.Strings[i] then
        begin
          for j := 0 to NInteractVecs[i]-1 do
          begin
            ColSelected[NEntered] := InteractPos[i] + j;
            labelstr := format('%s%d_%d',['IA',i+1,j+1]);
            Labels[NEntered] := labelstr;
            NEntered := NEntered + 1;
          end;
          break;
        end;
      end;
    end; // check for interaction variables

    // do reg analysis and save sum of squares
    if NEntered < 2 then continue;
    RegAnal(NEntered, AReport);
    R := sqrt(R2);
    df1 := Nentered - 1; // no. of independent variables
    TypeIIDF1[block] := df1;
    df2 := totalobs - df1 - 1; // N - no. independent - 1
    SSt := (totalobs-1) * Vars[0];
    SSres := SSt * (1.0 - R2);
    VarEst := SSres / df2;
    if (VarEst > 0.0) then
      StdErrEst := sqrt(VarEst)
    else
    begin
      MessageDlg('Error in computing variance estimate.', mtError,[mbOK], 0);
      StdErrEst := 0.0;
    end;
    if (R2 < 1.0) and (df2 > 0.0) then
      F := (R2 / df1) / ((1.0-R2)/ df2)
    else
      F := 0.0;
    FProbF := probf(F,df1,df2);
    AdjR2 := 1.0 - (1.0 - R2) * (totalobs - 1) / df2;

    AReport.Add('   R         R2         F      Prob. > F   DF1   DF2 ');
    AReport.Add('-------- ---------- ---------- ---------- ----- -----');
    AReport.Add('%8.3f %10.3f %10.3f %10.3f %5.0f %5.0f', [R, R2, F, FProbF, df1, df2]);
    AReport.Add('');
    AReport.Add('Adjusted R Squared:     %10.3f', [AdjR2]);
    AReport.Add('Std. Error of Estimate: %10.3f', [StdErrEst]);
    AReport.Add('');
    AReport.Add('Variable      Beta        B      Std.Error      t      Prob. > t ');
    AReport.Add('---------- ---------- ---------- ---------- ---------- ----------');

    df1 := 1.0;
    sum := 0.0;
    for i := 0 to Nentered - 2 do
    begin
      SSx := (totalobs-1) * Vars[i+1];
      sum  := sum + B[i] * means[i+1];
      if invmatrix[i,i] > 1.0e-15 then
      begin
        StdErrB := VarEst / (SSx * (1.0 / invmatrix[i,i]));
        StdErrB := sqrt(StdErrB);
        if StdErrB > 0.0 then F := B[i] / StdErrB else F := 0.0;
        FProbF := probf(F*F,df1,df2);
      end
      else begin
        StdErrB := 0.0;
        F := 0.0;
        FProbF := 0.0;
      end;
      cellstring := Format('%10s', [Labels[i+1]]);
      AReport.Add('%10s %10.3f %10.3f %10.3f %10.3f %10.3f', [cellstring, Beta[i] ,B[i], StdErrB, F, FProbF]);
    end;
    constant := means[0] - sum;
    AReport.Add('Constant:               %10.3f', [constant]);

    TypeIISS[block] := R2 * SST;
    AReport.Add('BETWEEN SUBJECT EFFECT:');
    AReport.Add('SS for %-10s: %10.3f',[effstr, TypeIISS[block]]);
    AReport.Add('SS TOTAL:          %10.3f',[SST]);
    AReport.Add('');
    AReport.Add(DIVIDER);
    AReport.Add('');
  end;

  totalss := 0.0;
  totaldf := 0.0;
  for i := 0 to noblocks - 1 do // add sums of squares for within effects
  begin
    if TypeIISS[i] < 0.0 then continue;
    totalss := totalss + TypeIISS[i];
    totaldf := totaldf + TypeIIDF1[i];
  end;
  sserrwithin := sswithin - totalss;
  dferrwithin := dfwithin - totaldf;
  mserrwithin := sserrwithin / dferrwithin;

  AReport.Add('           SUMMARY OF WITHIN SUBJECT EFFECTS');
  AReport.Add('SOURCE                DF      SS         MS         F      Prob > F');
  AReport.Add('-------------------- ---- ---------- ---------- ---------- --------');
  AReport.Add('%-20s %4.0f %10.3f', ['Within Subjects', dfwithin, sswithin]);
  for i := 0 to noblocks - 1 do
  begin
    if TypeIISS[i] < 0.0 then continue;
    TypeIIMS[i] := TypeIISS[i] / TypeIIDF1[i];
    TypeIIF[i] := TypeIIMS[i] / mserrwithin;
    TypeIIDF2[i] := dferrwithin;
    TypeIIProb[i] := probf(TypeIIF[i],TypeIIDF1[i],TypeIIDF2[i]);
    AReport.Add('%20s %4.0f %10.3f %10.3f %10.3f %10.3f',
      [IndOrderBox.Items.Strings[i],TypeIIDF1[i],TypeIISS[i],TypeIIMS[i],TypeIIF[i],TypeIIProb[i]]
    );
  end;
  AReport.Add('%20s %4.0f %10.3f %10.3f', ['Error Within', dferrwithin, sserrwithin, mserrwithin]);
  AReport.Add('%20s %4d %10.3f', ['TOTAL', totalobs-1, SST]);

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  // clean up the heap
  TypeIIProb := nil;
  TypeIIF := nil;
  TypeIProb := nil;
  TypeIF := nil;
  TypeIIDF2 := nil;
  TypeIIDF1 := nil;
  TypeIDF2 := nil;
  TypeIDF1 := nil;
  TypeIIMS := nil;
  TypeIMS := nil;
  TypeIISS := nil;
  TypeISS := nil;
end;

function TGLMFrm.CntIntActVecs(linestr: string): integer;
var
    i, j, listcnt, varcount : integer;
    cellstring : string;
    asterisk : string;
    blank : string;
    abbrevList : array[1..5] of string;
    vectcnt : array[1..5] of integer;
    newline : string;

begin
    asterisk := '*';
    blank := ' ';
    listcnt := 0;
    cellstring := '';
    newline := '';
    for i := 1 to 5 do vectcnt[i] := 0;
    // first, delete imbedded blanks that were there for readability
    for i := 1 to length(linestr) do
    begin
        if linestr[i] <> blank then newline := newline + linestr[i];
    end;
    // Now, strip out substrings to each asterisk or end of string
    while length(newline) > 0 do
    begin
        i := pos(asterisk,newline);
        if i > 0 then // an asterisk found
        begin
            cellstring := copy(newline,0,i-1); // get abbreviation
            delete(newline,1,i); // delete abbreviation and asterisk
            listcnt := listcnt + 1;
            AbbrevList[listcnt] := cellstring;
        end
        else begin // must be last abbreviation
            cellstring := newline;
            listcnt := listcnt + 1;
            AbbrevList[listcnt] := cellstring;
            newline := '';
        end;
    end;
    // now get the associated number of columns for each abbreviation in the list
    for i := 1 to listcnt do
    begin
        cellstring := AbbrevList[i];
        // check for covariates
        if NCovIndep > 0 then
        begin
            for j := 0 to NCovIndep - 1 do
            begin
                if cellstring = CovariateCode.Items.Strings[j] then
                    vectcnt[i] := 1;
            end;
        end;
        // check for fixed effect vectors
        if NFixedIndep > 0 then
        begin
            for j := 0 to NFixedIndep - 1 do
            begin
                if cellstring = FixedIndepCode.Items.Strings[j] then
                    vectcnt[i] := NFixVecIndep[j];
            end;
        end;
        // check for random effect vectors
        if NRndIndep > 0 then
        begin
            for j := 0 to NRndIndep - 1 do
            begin
                if cellstring = RndIndepCode.Items.Strings[j] then
                    vectcnt[i] := NRndVecIndep[j];
            end;
        end;
        // check for repeated measures effect vectors
        if NReptDep > 0 then
        begin
             if cellstring = RepTrtCode.Items.Strings[0] then
                    vectcnt[i] := NReptDep - 1;
        end;
    end; // next i in listcnt
    // get total interaction vector count
    varcount := 1;
    for i := 1 to listcnt do varcount := varcount * vectcnt[i];
    Result := varcount;
end;

procedure TGLMFrm.GenInterVecs(linestr: string);
var
    i, j, k, l, m, n, col, listcnt, pos1, pos2, pos3, pos4, pos5: integer;
    cellstring : string;
    asterisk : string;
    blank : string;
    abbrevList : array[1..5] of string;
    vectcnt : array[1..5] of integer;
    fromcol : array[1..5] of integer;
    newline : string;

begin
    asterisk := '*';
    blank := ' ';
    listcnt := 0;
    cellstring := '';
    newline := '';
    // first, delete imbedded blanks that were there for readability
    for i := 1 to length(linestr) do
    begin
        if linestr[i] <> blank then newline := newline + linestr[i];
    end;
    // Now, strip out substrings to each asterisk or end of string
    while length(newline) > 0 do
    begin
        i := pos(asterisk,newline);
        if i > 0 then // an asterisk found
        begin
            cellstring := copy(newline,0,i-1); // get abbreviation
            delete(newline,1,i); // delete abbreviation and asterisk
            listcnt := listcnt + 1;
            AbbrevList[listcnt] := cellstring;
        end
        else begin // must be last abbreviation
            cellstring := newline;
            listcnt := listcnt + 1;
            AbbrevList[listcnt] := cellstring;
            newline := '';
        end;
    end;
    // now generate the associated number of columns for each abbreviation in the list
    for i := 1 to listcnt do
    begin
        cellstring := AbbrevList[i];
        // check for covariates
        if NCovIndep > 0 then
        begin
            for j := 0 to NCovIndep - 1 do
            begin
                if cellstring = CovariateCode.Items.Strings[j] then
                begin
                    vectcnt[i] := 1;
                    fromcol[i] := CovIndepPos[j];
                    break;
                end;
            end;
        end;
        // check for fixed effect vectors
        if NFixedIndep > 0 then
        begin
            for j := 0 to NFixedIndep - 1 do
            begin
                if cellstring = FixedIndepCode.Items.Strings[j] then
                begin
                    vectcnt[i] := NFixVecIndep[j];
                    fromcol[i] := FixedIndepPos[j];
                    break;
                end;
            end;
        end;
        // check for random effect vectors
        if NRndIndep > 0 then
        begin
            for j := 0 to NRndIndep - 1 do
            begin
                if cellstring = RndIndepCode.Items.Strings[j] then
                begin
                    vectcnt[i] := NRndVecIndep[j];
                    fromcol[i] := RndIndepPos[j];
                    break;
                end;
            end;
        end;
        // check for repeated measures
        if NReptDep > 0 then
        begin
                if cellstring = RepTrtCode.Items.Strings[0] then
                begin
                    vectcnt[i] := NReptDep - 1;
                    fromcol[i] := ReptTrtPos[0];
                end;
        end;
    end; // next i in listcnt

    // now generate the product vectors for 2-way interactions
    col := gencount;
    for i := 1 to vectcnt[1] do
    begin
        pos1 := fromcol[1] + i - 1;
        for j := 1 to vectcnt[2] do
        begin
            pos2 := fromcol[2] + j - 1;
            for m := 0 to totalobs - 1 do
                    datagrid[m,col] := datagrid[m,pos1] * datagrid[m,pos2];
            cellstring := format('%s_%d*%s_%d',[AbbrevList[1],i,AbbrevList[2],j]);
            GenLabels[col] := cellstring;
            col := col + 1;
        end;
    end;

    if listcnt = 3 then // Do 3-way interactions
    begin
        col := gencount;
        for i := 1 to vectcnt[1] do
        begin
            pos1 := fromcol[1] + i - 1;
            for j := 1 to vectcnt[2] do
            begin
                pos2 := fromcol[2] + j - 1;
                for k := 1 to vectcnt[3] do
                begin
                    pos3 := fromcol[3] + k - 1;
                    for m := 0 to totalobs - 1 do
                        datagrid[m,col] := datagrid[m,pos1] * datagrid[m,pos2] * datagrid[m,pos3];
                    cellstring := format('%s*%s*%s',[GenLabels[pos1],GenLabels[pos2],GenLabels[pos3]]);
                    GenLabels[col] := cellstring;
                    col := col + 1;
                end; // next k
            end; // next j
        end; // next i
    end; // if listcnt = 3

    if listcnt = 4 then // Do 4-way interactions
    begin
        col := gencount;
        for i := 1 to vectcnt[1] do
        begin
            pos1 := fromcol[1] + i - 1;
            for j := 1 to vectcnt[2] do
            begin
                pos2 := fromcol[2] + j - 1;
                for k := 1 to vectcnt[3] do
                begin
                    pos3 := fromcol[3] + k - 1;
                    for l := 1 to vectcnt[4] do
                    begin
                        pos4 := fromcol[4] + l - 1;
                        for m := 0 to totalobs - 1 do
                            datagrid[m,col] := datagrid[m,pos1] *
                                 datagrid[m,pos2] * datagrid[m,pos3] * datagrid[m,pos4];
                        cellstring := format('%s*%s*%s*%s',[GenLabels[pos1],
                             GenLabels[pos2],GenLabels[pos3],GenLabels[pos4]]);
                        GenLabels[col] := cellstring;
                        col := col + 1;
                    end; // next l
                end; // next k
            end; // next j
        end; // next i
    end; // if listcnt = 3

    if listcnt = 5 then // Do 5-way interactions
    begin
        col := gencount;
        for i := 1 to vectcnt[1] do
        begin
            pos1 := fromcol[1] + i - 1;
            for j := 1 to vectcnt[2] do
            begin
                pos2 := fromcol[2] + j - 1;
                for k := 1 to vectcnt[3] do
                begin
                    pos3 := fromcol[3] + k - 1;
                    for l := 1 to vectcnt[4] do
                    begin
                        pos4 := fromcol[4] + l - 1;
                        for n := 1 to vectcnt[5] do
                        begin
                            pos5 := fromcol[5] + n - 1;
                            for m := 0 to totalobs - 1 do
                                datagrid[m,col] := datagrid[m,pos1] *
                                   datagrid[m,pos2] * datagrid[m,pos3] *
                                   datagrid[m,pos4] * datagrid[m,pos5];
                            cellstring := Format('%s*%s*%s*%s*%s',[GenLabels[pos1],
                                   GenLabels[pos2],GenLabels[pos3],GenLabels[pos4],
                                   GenLabels[pos5]]);
                            GenLabels[col] := cellstring;
                            col := col + 1;
                        end; // next n
                    end; // next l
                end; // next k
            end; // next j
        end; // next i
    end; // if listcnt = 3
end;

procedure TGLMFrm.CanCor(NLeft: integer; NRight: integer; GridPlace: IntDyneVec;
  AReport: TStrings);
var
   i, j, k, count, a_size, b_size, no_factors, IER: integer;
   s, m, n, df1, df2, q, w, pcnt_extracted, trace : double;
   minroot, critical_prob, Lambda, Pillia : double;
   chisqr, HLTrace, chiprob, ftestprob, Roys, f, Hroot : double;
   raa, rbb, rab, rba, bigmat, first_prod, second_prod : DblDyneMat;
   char_equation, raainv, rbbinv, eigenvectors, norm_a, norm_b : DblDyneMat;
   raw_a, raw_b, a_cors, b_cors, eigentrans, theta, tempmat : DblDyneMat;
   mean, variance, stddev, roots, root_chi, chi_prob, pv_a, pv_b : DblDyneVec;
   rd_a, rd_b, pcnt_trace : DblDyneVec;
   root_df : IntDyneVec;
   a_vars, b_vars : StrDyneVec;
   selected : IntDyneVec;
   RowLabels, ColLabels : StrDyneVec;
   CanLabels : StrDyneVec;
   title : string;
   errorcode : boolean = false;

begin
     count := 0;
     k := 0;
     no_factors := 0;
     pcnt_extracted := 0.0;
     trace := 0.0;
     minroot := 0.0;
     critical_prob := 0.0;
     Pillia := 0.0;
     chisqr := 0.0;
     HLTrace := 0.0;
     chiprob := 0.0;

    // Get size of the Left and Right matrices (predictors and dependents)
    a_size := NLeft;
    b_size:= NRight;
    novars:= a_size + b_size;

    // allocate memory for matrices and vectors
    SetLength(raa,NLeft+1,NLeft+1);
    SetLength(rbb,NRight+1,NRight+1);
    SetLength(rab,NLeft+1,NRight+1);
    SetLength(rba,NRight+1,NLeft+1);
    SetLength(bigmat,novars+1,novars+1);
    SetLength(first_prod,novars+1,novars+1);
    SetLength(second_prod,novars+1,novars+1);
    SetLength(char_equation,novars+1,novars+1);
    SetLength(raainv,NLeft,NLeft);
    SetLength(rbbinv,NRight,NRight);
    SetLength(eigenvectors,novars,novars);
    SetLength(norm_a,novars,novars);
    SetLength(norm_b,novars,novars);
    SetLength(raw_a,novars,novars);
    SetLength(raw_b,novars,novars);
    SetLength(a_cors,NLeft+1,NLeft+1);
    SetLength(b_cors,NRight+1,NRight+1);
    SetLength(eigentrans,novars,novars);
    SetLength(theta,novars,novars);
    SetLength(tempmat,novars,novars);

    SetLength(mean,novars);
    SetLength(variance,novars);
    SetLength(stddev,novars);
    SetLength(roots,novars);
    SetLength(root_chi,novars);
    SetLength(chi_prob,novars);
    SetLength(pv_a,novars);
    SetLength(pv_b,novars);
    SetLength(rd_a,novars);
    SetLength(rd_b,novars);
    SetLength(pcnt_trace,novars);

    SetLength(root_df,novars);
    SetLength(a_vars,NLeft);
    SetLength(b_vars,NRight);
    SetLength(CanLabels,novars);
    SetLength(RowLabels,novars);
    SetLength(ColLabels,novars);
    SetLength(selected,novars);

     //------------ WORK STARTS HERE! -------------------------------------

     // Build labels for canonical functions 1 to novars
     if b_size < a_size then
        for i := 0 to b_size-1 do CanLabels[i] := 'CanVar' + IntToStr(i+1)
     else for i := 0 to a_size-1 do CanLabels[i] := 'CanVar' + IntToStr(i+1);

     for i := 0 to a_size - 1 do // identify left variables
     begin
          a_vars[i] := Labels[i];
          selected[i] := GridPlace[i];
     end;

     for i := 0 to b_size - 1 do // identify right variables
     begin
          b_vars[i] := Labels[NLeft+i];
          selected[NLeft+i] := GridPlace[NLeft+i];
     end;

     AReport.Add('CANONICAL CORRELATION ANALYSIS');
     AReport.Add('');

     count := NoCases;
     // Get means, standard deviations, etc. for total matrix
     IER := DynCorrelations(novars,selected,datagrid,bigmat,mean,variance,stddev,totalobs,3);
     if (IER = 1) then
     begin
          ErrorMsg('Zero variance found for a variable-terminating');
          exit;
     end;

     //partition matrix into quadrants
     for i := 0 to a_size - 1 do
         for j := 0 to a_size - 1 do raa[i,j]:= bigmat[i,j];

     for i := a_size to novars - 1 do
         for j := a_size to novars - 1 do
              rbb[i-a_size,j-a_size] := bigmat[i,j];

     for i := 0 to a_size - 1 do
         for j := a_size to novars - 1 do
             rab[i,j-a_size] := bigmat[i,j];

     for i := a_size to novars - 1 do
         for j := 0 to a_size - 1 do
             rba[i-a_size,j] := bigmat[i,j];

     if CorsChk.Checked then
     begin
          title := 'Left Correlation Matrix';
          MatPrint(raa, NLeft, NLeft, title, a_vars, a_vars, totalobs, AReport);
          title := 'Right Correlation Matrix';
          MatPrint(rbb, NRight, NRight, title, b_vars, b_vars, totalobs, AReport);
          title := 'Left-Right Correlation Matrix';
          MatPrint(rab, NLeft, NRight, title, a_vars, b_vars, totalobs, AReport);

          AReport.Add('');
          AReport.Add(DIVIDER);
          AReport.Add('');
     end;

     // get inverses of left and right hand matrices raa and rbb
     for i := 0 to a_size-1 do
         for j := 0 to a_size-1 do
             tempmat[i,j] := raa[i,j];
     SVDInverse(tempmat,a_size);
     for i := 0 to a_size-1 do
        for j := 0 to a_size-1 do raainv[i,j] := tempmat[i,j];
     if CorsChk.Checked then
     begin
          title := 'Inverse of Left Matrix';
          MatPrint(raainv, a_size, a_size, title, a_vars, a_vars, totalobs, AReport);
     end;

     for i := 0 to b_size-1 do
         for j := 0 to b_size-1 do
             tempmat[i,j] := rbb[i,j]; // inverse uses 1 offset
     SVDInverse(tempmat,b_size);
     for i := 0 to b_size-1 do // reset to 0 offset
        for j := 0 to b_size - 1 do rbbinv[i,j] := tempmat[i,j];
     if CorsChk.Checked then
     begin
          title := 'Inverse of Right Matrix';
          MatPrint(rbbinv, b_size, b_size, title, b_vars, b_vars, totalobs, AReport);
     end;

     // get products of raainv x rab and the rbbinv x rba matrix
     for i := 0 to b_size-1 do
          for j := 0 to a_size-1 do first_prod[i,j] := 0.0;
     MatAxB(first_prod,rbbinv,rba,b_size,b_size,b_size,a_size,errorcode);
     for i := 0 to a_size-1 do
         for j := 0 to b_size-1 do second_prod[i,j] := 0.0;
     MatAxB(second_prod,raainv,rab,a_size,a_size,a_size,b_size,errorcode);
     title := 'Right Inverse x Right-Left Matrix';
     MatPrint(first_prod, b_size, a_size, title, b_vars, a_vars, totalobs, AReport);
     title := 'Left Inverse x Left-Right Matrix';
     MatPrint(second_prod, a_size, b_size, title, a_vars, b_vars, totalobs, AReport);

     //get characteristic equations matrix (product of last two product matrices
     //The product should yeild rows and cols representing the smaller of the two sets
     for i := 0 to b_size-1 do
         for j := 0 to b_size - 1 do char_equation[i,j] := 0.0;
     MatAxB(char_equation,first_prod,second_prod,b_size,a_size,a_size,b_size,errorcode);
     title := 'Canonical Function';
     MatPrint(char_equation, b_size, b_size, title, CanLabels, CanLabels, totalobs, AReport);

     AReport.Add('');
     AReport.Add(DIVIDER);
     AReport.Add('');

     //  now get roots and vectors of the characteristic equation using
     // NonSymRoots routine
     minroot := 0.0;
     for i := 0 to b_size - 1 do
     begin
         roots[i] := 0.0;
         pcnt_trace[i] := 0.0;
         for j := 0 to b_size - 1 do eigenvectors[i,j] := 0.0;
     end;
     trace := 0.0;
     no_factors := b_size;
     Dynnonsymroots(char_equation, b_size, no_factors, minroot, eigenvectors, roots,
                pcnt_trace, trace, pcnt_extracted);


     AReport.Add('Trace of the matrix:        %10.4f', [trace]);
     AReport.Add('Percent of trace extracted: %10.4f', [pcnt_extracted]);

     // Normalize smaller set weights and coumpute larger set weights
     for i := 0 to b_size - 1 do // transpose eigenvectors
         for j := 0 to b_size - 1 do eigentrans[j,i] := eigenvectors[i,j];
     for i := 0 to b_size - 1 do
         for j := 0 to b_size-1 do tempmat[i,j] := 0.0;
     MatAxB(tempmat,eigentrans,rbb,b_size,b_size,b_size,b_size,errorcode);
     for i := 0 to b_size-1 do
         for j := 0 to b_size-1 do theta[i,j] := 0.0;
     MatAxB(theta,tempmat,eigenvectors,b_size,b_size,b_size,b_size,errorcode);
     for j := 0 to b_size - 1 do
     begin
          q := 1.0 / sqrt(theta[j,j]);
          for i := 0 to b_size - 1 do
          begin
               norm_b[i,j] := eigenvectors[i,j] * q;
               raw_b[i,j] := norm_b[i,j] / stddev[a_size+i];
          end;
     end;
     for i := 0 to a_size - 1 do
         for j := 0 to b_size - 1 do norm_a[i,j] := 0.0;
     MatAxB(norm_a,second_prod,norm_b,a_size,b_size,b_size,b_size,errorcode);
     for j := 0 to b_size-1 do
     begin
            for i := 0 to a_size-1 do
            begin
                norm_a[i,j] := norm_a[i,j] * (1.0 / sqrt(roots[j]));
                raw_a[i,j] := norm_a[i,j] / stddev[i];
            end;
     end;

     // Compute the correlations between variables and canonical variables
     for i := 0 to a_size-1 do
         for j := 0 to b_size-1 do a_cors[i,j] := 0.0;
     MatAxB(a_cors,raa,norm_a,a_size,a_size,a_size,b_size,errorcode);
     for j := 0 to b_size-1 do
     begin
         q := 0.0;
         for i := 0 to a_size-1 do q := q + norm_a[i,j] * a_cors[i,j];
         q := 1.0 / sqrt(q);
         for i := 0 to a_size-1 do a_cors[i,j] := a_cors[i,j] * q;
     end;
     for i := 0 to b_size-1 do
         for j := 0 to b_size-1 do b_cors[i,j] := 0.0;
     MatAxB(b_cors,rbb,norm_b,b_size,b_size,b_size,b_size,errorcode);
     for j := 0 to b_size-1 do
     begin
         q := 0.0;
         for i := 0 to b_size-1 do q := q + norm_b[i,j] * b_cors[i,j];
         q := 1.0 / sqrt(q);
         for i := 0 to b_size-1 do b_cors[i,j] := b_cors[i,j] * q;
     end;

     // Compute the Proportions of Variance (PVs) and Redundancy Coefficients
     for j := 0 to b_size-1 do
     begin
         pv_a[j] := 0.0;
         for i := 0 to a_size-1 do pv_a[j] := pv_a[j] + (a_cors[i,j] * a_cors[i,j]);
         pv_a[j] := pv_a[j] / a_size;
         rd_a[j] := pv_a[j] * roots[j];
     end;
     for j := 0 to b_size-1 do
     begin
         pv_b[j] := 0.0;
         for i := 0 to b_size-1 do pv_b[j] := pv_b[j] + (b_cors[i,j] * b_cors[i,j]);
         pv_b[j] := pv_b[j] / b_size;
         rd_b[j] := pv_b[j] * roots[j];
     end;

     // Compute tests of the roots
     q := a_size + b_size + 1;
     q := -(count - 1.0 - (q / 2.0));
     k := 0;
     for i := 0 to b_size-1 do
     begin
         w := 1.0;
         for j := i to b_size-1 do w := w * (1.0 - roots[j]);
         root_chi[i] := q * ln(w);
         root_df[i] := (a_size - i) * (b_size - i);
         chi_prob[i] := 1.0 - chisquaredprob(root_chi[i],root_df[i]);
         if (chi_prob[i] < critical_prob) then k := k + 1;
     end;
     Roys := roots[1] / (1.0 - roots[1]);
     Lambda := 1.0;
     for i := 0 to b_size-1 do
     begin
         Hroot := roots[i] / (1.0 - roots[i]);
         Lambda := Lambda * (1.0 / (1.0 + Hroot));
         Pillia := Pillia + (Hroot / (1.0 + Hroot));
         HLTrace := HLTrace + Hroot;
     end;

     // Print remaining results
     AReport.Add('');
     AReport.Add('');
     AReport.Add('   Canonical R   Root  % Trace   Chi-Sqr    D.F.    Prob.');
     for i := 0 to b_size-1 do
         AReport.Add('%2d %10.6f %8.3f %7.3f %8.3f      %2d %8.3f',
            [i+1, sqrt(roots[i]), roots[i], pcnt_trace[i], root_chi[i], root_df[i], chi_prob[i]]);

     chisqr := -ln(Lambda) * (count - 1.0 - 0.5 * (a_size + b_size - 1.0));
     chiprob := 1.0 - chisquaredprob(chisqr,a_size * b_size);
     AReport.Add('');
     AReport.Add('Overall Tests of Significance:');
     AReport.Add('         Statistic      Approx. Stat.   Value   D.F.  Prob.>Value');
     AReport.Add('Wilk''s Lambda           Chi-Squared %10.4f  %3d   %6.4f', [chisqr,a_size * b_size,chiprob]);

     s := b_size;
     m := 0.5 * (a_size - b_size - 1);
     n := 0.5 * (count - b_size - a_size - 2);
     f := (HLTrace * 2.0 * (s * n + 1)) / (s * s * (2.0 * m + s + 1.0));
     df1 := s * (2.0 * m + s + 1.0);
     df2 := 2.0 * ( s * n  + 1.0);
     ftestprob := probf(f,df1,df2);
     AReport.Add('Hotelling-Lawley Trace  F-Test      %10.4f %2.0f %2.0f  %6.4f', [f, df1, df2, ftestprob]);

     df2 := s * (2.0 * n + s + 1.0);
     f := (Pillia / (s - Pillia)) * ( (2.0 * n + s +1.0) / (2.0 * m + s + 1.0) );
     ftestprob := probf(f,df1,df2);
     AReport.Add('Pillai Trace            F-Test      %10.4f %2.0f %2.0f  %6.4f', [f, df1, df2, ftestprob]);

     Roys := Roys * (count - 1 - a_size + b_size)/ a_size ;
     df1 := a_size;
     df2 := count - 1 - a_size + b_size;
     ftestprob := probf(Roys,df1,df2);
     AReport.Add('Roys Largest Root       F-Test      %10.4f %2.0f %2.0f  %6.4f', [Roys, df1, df2, ftestprob]);

     AReport.Add('');
     AReport.Add(DIVIDER);
     AReport.Add('');

     if CorsChk.Checked then
     begin
          title := 'Eigenvectors';
          MatPrint(eigenvectors, b_size, b_size, title, CanLabels, CanLabels, totalobs, AReport);
          AReport.Add('');
          AReport.Add(DIVIDER);
          AReport.Add('');
     end;

     title := 'Standardized Right Side Weights';
     MatPrint(norm_a, a_size, b_size, title, RowLabels, CanLabels, totalobs, AReport);

     title := 'Standardized Left Side Weights';
     MatPrint(norm_b, b_size, b_size, title, ColLabels, CanLabels, totalobs, AReport);

     AReport.Add('');
     AReport.Add(DIVIDER);
     AReport.Add('');

     title := 'Raw Right Side Weights';
     MatPrint(raw_a, a_size, b_size, title, RowLabels, CanLabels, totalobs, AReport);

     title := 'Raw Left Side Weights';
     MatPrint(raw_b, b_size, b_size, title, ColLabels, CanLabels, totalobs, AReport);

     AReport.Add('');
     AReport.Add(DIVIDER);
     AReport.Add('');

     title := 'Right Side Correlations with Function';
     MatPrint(a_cors, a_size, b_size, title, RowLabels, CanLabels, totalobs, AReport);
     title := 'Left Side Correlations with Function';
     MatPrint(b_cors, b_size, b_size, title, ColLabels, CanLabels, totalobs, AReport);

     AReport.Add('');
     AReport.Add(DIVIDER);
     AReport.Add('');

     if CorsChk.Checked then
     begin
          AReport.Add('Redundancy Analysis for Right Side Variables');
          AReport.Add('');
          AReport.Add('            Variance Prop.    Redundancy');
          for i := 0 to b_size-1 do
               AReport.Add('%10d %10.5f     %10.5f', [i, pv_a[i], rd_a[i]]);
          AReport.Add('');
          AReport.Add('Redundancy Analysis for Left Side Variables');
          AReport.Add('            Variance Prop.    Redundancy');
          for i := 0 to b_size-1 do
               AReport.Add('%10d %10.5f     %10.5f', [i, pv_b[i], rd_b[i]]);

          AReport.Add('');
          AReport.Add(DIVIDER);
          AReport.Add('');
     end;

     //------------- Now, clean up memory mess ----------------------------
    selected := nil;
    ColLabels := nil;
    RowLabels := nil;
    CanLabels := nil;
    b_vars := nil;
    a_vars := nil;
    root_df := nil;
    pcnt_trace := nil;
    rd_b := nil;
    rd_a := nil;
    pv_b := nil;
    pv_a := nil;
    chi_prob := nil;
    root_chi := nil;
    roots := nil;
    stddev := nil;
    variance := nil;
    mean := nil;
    tempmat := nil;
    theta := nil;
    eigentrans := nil;
    b_cors := nil;
    a_cors := nil;
    raw_b := nil;
    raw_a := nil;
    norm_b := nil;
    norm_a := nil;
    eigenvectors := nil;
    rbbinv := nil;
    raainv := nil;
    char_equation := nil;
    second_prod := nil;
    first_prod := nil;
    bigmat := nil;
    rba := nil;
    rab := nil;
    rbb := nil;
    raa := nil;
end;

procedure TGLMFrm.UpdateBtnStates;
begin
  ContDepInBtn.Enabled := VarList.ItemIndex > -1;
  ContDepOutBtn.Enabled := DepContList.ItemIndex > -1;

  CatDepInBtn.Enabled := VarList.ItemIndex > -1;
  CatDepOutBtn.Enabled := DepCatList.ItemIndex > -1;

  ReptDepInBtn.Enabled := AnySelected(VarList);
  ReptDepOutBtn.Enabled := RepeatList.ItemIndex > -1;

  FixedIndepInBtn.Enabled := AnySelected(VarList);
  FixedIndepOutBtn.Enabled := FixedList.ItemIndex > -1;

  RndIndepInBtn.Enabled := VarList.ItemIndex > -1;
  RndIndepOutBtn.Enabled := RandomList.ItemIndex > -1;

  CovInBtn.Enabled := VarList.ItemIndex > -1;
  CovOutBtn.Enabled := CovariateList.ItemIndex > -1;
end;

initialization
  {$I glmunit.lrs}

end.

