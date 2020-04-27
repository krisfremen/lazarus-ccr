// File for testing according to pdf help: KappaTest3.laz
// BUT: Yields different results than pdf
// --> using file genkappa.laz for the chm

unit GenKappaUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, MainUnit,
  Globals, OutputUnit, FunctionsLib, ContextHelpUnit;
type

  { TGenKappaFrm }

  TGenKappaFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Label4: TLabel;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    CatIn: TBitBtn;
    CatOut: TBitBtn;
    CatEdit: TEdit;
    ObjectEdit: TEdit;
    RaterEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ObjIn: TBitBtn;
    ObjOut: TBitBtn;
    RaterIn: TBitBtn;
    RaterOut: TBitBtn;
    VarList: TListBox;
    procedure CatInClick(Sender: TObject);
    procedure CatOutClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ObjInClick(Sender: TObject);
    procedure ObjOutClick(Sender: TObject);
    procedure RaterInClick(Sender: TObject);
    procedure RaterOutClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    NoCats: integer;
    NoObjects: integer;
    NoRaters: integer;
    function compute_term1(R: IntDyneCube; i, j, k: integer): double;
    function compute_term2(R: IntDyneCube; i, j, l: integer): double;
    function compute_denom(R: IntDyneCube): double;
    function compute_partial_pchance(R: IntDyneCube; i, j: integer; denom: double): double;
    function compute_partial_pobs(R: IntDyneCube; k, l: integer): double;
    function KappaVariance(R: IntDyneCube; n, m, K1: integer): double;

    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  GenKappaFrm: TGenKappaFrm;

implementation

uses
  Math, Utils;

{ TGenKappaFrm }

procedure TGenKappaFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     CatIn.Enabled := true;
     CatOut.Enabled := false;
     ObjIn.Enabled := true;
     ObjOut.Enabled := false;
     RaterIn.Enabled := true;
     RaterOut.Enabled := false;
     CatEdit.Text := '';
     ObjectEdit.Text := '';
     RaterEdit.Text := '';
     VarList.Clear;
     for i := 0 to NoVariables - 1 do
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i+1,0]);
end;

procedure TGenKappaFrm.CatInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (CatEdit.Text = '') then
  begin
    CatEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TGenKappaFrm.CatOutClick(Sender: TObject);
begin
  if CatEdit.Text <> '' then
  begin
    VarList.Items.Add(CatEdit.Text);
    CatEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TGenKappaFrm.ComputeBtnClick(Sender: TObject);
var
  CatCol, ObjCol, RaterCol, frequency, i, j, k, l: integer;
  value, rater, category, anobject: integer;
  R: IntDyneCube;
  pobs, pchance, kappa, num, denom, partial_pchance, a_priori: double;
  average_frequency: DblDyneVec;
  z: double;
  lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
    lReport.Add('GENERALIZED KAPPA COEFFICIENT PROCEDURE');
    lReport.Add('Adapted from the program written by Giovanni Flammia');
    lReport.Add('Copy-write 1995, M.I.T. Lab. for Computer Science');
    lReport.Add('');

    // get columns for the variables
    CatCol := 0;
    ObjCol := 0;
    RaterCol := 0;
    for i := 1 to NoVariables do
    begin
      if (OS3MainFrm.DataGrid.Cells[i, 0] = CatEdit.Text) then CatCol := i;
      if (OS3MainFrm.DataGrid.Cells[i, 0] = RaterEdit.Text) then RaterCol := i;
      if (OS3MainFrm.DataGrid.Cells[i, 0] = ObjectEdit.Text) then ObjCol := i;
    end;
    if ((CatCol = 0) or (RaterCol = 0) or (ObjCol = 0)) then
    begin
      MessageDlg('One or more variables not defined.', mtError, [mbOK], 0);
      exit;
    end;

    // get max no of codes for objects, raters, categories
    NoCats := 0;
    NoObjects := 0;
    NoRaters := 0;
    for i := 1 to NoCases do
    begin
      value := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[CatCol, i])));
      if (value > NoCats) then NoCats := value;

      value := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ObjCol, i])));
      if (value > NoObjects) then NoObjects := value;

      value := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[RaterCol, i])));
      if (value > NoRaters) then NoRaters := value;
    end;

    lReport.Add('%d Raters using %d Categories to rate %d Objects', [NoRaters, NoCats, NoObjects]);
    lReport.Add('');

    // get memory for R and set to zero
    SetLength(R, NoRaters+1, NoCats+1, NoObjects+1);
    for i := 0 to NoRaters - 1 do
      for k := 0 to NoCats - 1 do
        for l := 0 to NoObjects - 1 do
          R[i,k,l] := 0;

    // get memory for average_frequency
    SetLength(average_frequency, NoCats+1);
    for k := 0 to NoCats - 1 do
      average_frequency[k] := 0.0;

    // read data and store in R
    for i := 1 to NoCases do
    begin
      rater := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[RaterCol, i])));
      anobject := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ObjCol, i])));
      category := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[CatCol, i])));
      R[rater-1, category-1, anobject-1] := 1;
    end;

    //compute chance probability of agreement pchance for all raters
    pchance := 0.0;
    denom := compute_denom(R);
    for i := 0 to NoRaters - 1 do
    begin
      for j := 0 to NoRaters - 1 do
        if (i <> j) then
        begin
          partial_pchance := compute_partial_pchance(R,i,j,denom);
          pchance := pchance + partial_pchance;
        end;
      for k := 0 to NoCats - 1 do
      begin
        frequency := 0;
        for l := 0 to NoObjects - 1 do
          frequency := frequency + R[i,k,l];
        a_priori := frequency / NoObjects;
        lReport.Add('Frequency[%d,%d]: %f', [i+1, k+1, a_priori]);
      end;
    end;

    for k := 0 to NoCats - 1 do
      for l := 0 to NoObjects - 1 do
        for i := 0 to NoRaters - 1 do
          average_frequency[k] := average_frequency[k] + R[i,k,l];

    for k := 0 to NoCats - 1 do
    begin
      average_frequency[k] := average_frequency[k] / (NoObjects * NoRaters);
      lReport.Add('Average_Frequency[%d]: %f', [k+1, average_frequency[k]]);
    end;

    lReport.Add('PChance: %f', [pchance]);

    // compute observed probability of agreement among all raters
    num := 0.0;
    for k := 0 to NoCats - 1 do
      for l := 0 to NoObjects - 1 do
        num := num + compute_partial_pobs(R,k,l);
    if (denom > 0.0) then
      pobs := num / denom
    else
      pobs := 0.0;
    lReport.Add('PObs: %f', [pobs]);

    kappa := (pobs - pchance) / (1.0 - pchance);
    lReport.Add('Kappa: %f', [kappa]);

    z := KappaVariance(R,NoObjects,NoRaters,NoCats);
    if (z > 0.0) then z := kappa / sqrt(z);
    lReport.Add('z for Kappa: %.3f with probability > %.3f', [z, 1.0-probz(z)]);

    DisplayReport(lReport);

  finally
    lReport.Free;
    average_frequency := nil;
    R := nil;
  end;
end;

procedure TGenKappaFrm.FormActivate(Sender: TObject);
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

  FAutoSized := true;
end;

procedure TGenKappaFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TGenKappaFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TGenKappaFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

function TGenKappaFrm.compute_term1(R: IntDyneCube; i, j, k: integer): double;
var
  kk : integer;            // range over 0 .. num_categories-1 */
  l,ll : integer;          // range over 0 .. num_points-1 */
  denom_i : integer;       //:=0;
  denom_j : integer;       //:=0;
  num_i : integer;         //:=0;
  num_j : integer;         //:=0;
begin
  denom_i := 0;
  denom_j := 0;
  num_i := 0;
  num_j := 0;

  for kk := 0 to NoCats - 1 do
    for ll := 0 to NoObjects - 1 do
    begin
      denom_i := denom_i + R[i, kk, ll];
      denom_j := denom_j + R[j, kk, ll];
    end;

  for l := 0 to NoObjects - 1 do
  begin
    num_i := num_i + R[i, k, l];
    num_j := num_j + R[j, k, l];
  end;

  result := (num_i * num_j) / (denom_i * denom_j); //((num_i / denom_i) * (num_j / denom_j));
end;

function TGenKappaFrm.compute_term2(R: IntDyneCube; i, j, l: integer): double;
var
  sum_i, sum_j, k: integer;
begin
  sum_i := 0;
  sum_j := 0;

  for k := 0 to NoCats - 1 do
  begin
    sum_i := sum_i + R[i, k, l];
    sum_j := sum_j + R[j, k, l];
  end;

  Result := sum_i * sum_j;
end;

function TGenKappaFrm.compute_denom(R: IntDyneCube): double;
var
  sum: IntDyneVec;
  i, k, l: integer;
begin
  Result := 0;

  SetLength(sum, NoObjects); //  sum := (int *)calloc(num_points,sizeof(int));
  for l := 0 to NoObjects - 1 do
  begin
    sum[l] := 0;
    for i := 0 to NoRaters - 1 do
      for k := 0 to NoCats - 1 do
         sum[l] := sum[l] + R[i,k,l];
  end;

  for l := 0 to NoObjects - 1 do
    Result := Result + sum[l] * (sum[l] - 1);

  sum := nil;
end;

function TGenKappaFrm.compute_partial_pchance(R: IntDyneCube; i, j: integer;
  denom: double): double;
var
  term1, term2: double;
  k, l: integer;
begin
  term1 := 0;
  term2 := 0;

  for k := 0 to NoCats - 1 do
    term1 := term1 + compute_term1(R,i,j,k);

  for l := 0 to NoObjects - 1 do
    term2 := term2 + compute_term2(R,i,j,l);

  if (denom > 0.0) then
    Result := term1 * term2 / denom
  else
    Result := 0.0;
end;

function TGenKappaFrm.compute_partial_pobs(R: IntDyneCube; k, l: integer): double;
var
  sum, i: integer;
begin
  sum := 0;
  for i := 0 to NoRaters - 1 do
    sum := sum + R[i, k, l];

  Result := sum * (sum - 1);
end;

{ Calculates the variance of Kappa
  R contains 1's or 0's for raters, categories and objects (row, col, slice)
  m is number of raters
  n is number of subjects
  K1 is the number of categories }
function TGenKappaFrm.KappaVariance(R : IntDyneCube; n, m, K1: integer): double;
var
  xij, term1, term2: double;
  i, j, k: integer;
  pj: DblDyneVec;
begin
  term1 := 0.0;
  term2 := 0.0;

  SetLength(pj,K1);
  for j := 0 to K1 - 1 do pj[j] := 0.0;

  // get proportion of values in each category
  for j := 0 to K1 - 1 do // accross categories
  begin
    xij := 0.0;
    for i := 0 to m - 1 do // accross raters
      for k := 0 to n - 1 do // accross objects
        xij := xij + R[i,j,k];
           pj[j] := pj[j] + xij;
  end;

  for j := 0 to K1 - 1 do
    pj[j] := pj[j] / (n * m);

  for j := 0 to K1 - 1 do
  begin
    term1 := term1 + (pj[j] * (1.0 - pj[j]));
    term2 := term2 + (pj[j] * (1.0 - pj[j]) * (1.0 - 2.0 * pj[j]));
  end;

  term1 := term1 * term1;
  if (term1 > 0) and (term2 > 0) then
    Result := (2.0 / (n * m * (m-1) * term1)) * (term1 - term2)
  else
    Result := 0.0;

  pj := nil;
end;

procedure TGenKappaFrm.ObjInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (ObjectEdit.Text = '') then
  begin
    ObjectEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TGenKappaFrm.ObjOutClick(Sender: TObject);
begin
  if ObjectEdit.Text <> '' then
  begin
    VarList.Items.Add(ObjectEdit.Text);
    ObjectEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TGenKappaFrm.RaterInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (RaterEdit.Text = '') then
  begin
    RaterEdit.Text := VarList.Items.Strings[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TGenKappaFrm.RaterOutClick(Sender: TObject);
begin
  if RaterEdit.Text <> '' then
  begin
    VarList.Items.Add(RaterEdit.Text);
    RaterEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TGenKappaFrm.UpdateBtnStates;
var
  lSelected: Boolean;
begin
  lSelected := AnySelected(VarList);

  CatIn.Enabled := lSelected and (CatEdit.Text = '');
  CatOut.Enabled := (CatEdit.Text <> '');

  ObjIn.Enabled := lSelected and (ObjectEdit.Text = '');
  ObjOut.Enabled := (ObjectEdit.Text <> '');

  RaterIn.Enabled := lSelected and (RaterEdit.Text = '');
  RaterOut.Enabled := (RaterEdit.Text <> '');
end;

procedure TGenKappaFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I genkappaunit.lrs}

end.

