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
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
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
  private
    { private declarations }
    FAutoSized: Boolean;
    NoCats : integer;
    NoObjects : integer;
    NoRaters : integer;
    function compute_term1(R : IntDyneCube; i, j, k : integer) : double;
    function compute_term2(R : IntDyneCube; i, j, l : integer) : double;
    function compute_denom(R : IntDyneCube) : double;
    function compute_partial_pchance(R : IntDyneCube; i, j : integer;
                denom : double) : double;
    function compute_partial_pobs(R : IntDyneCube; k, l : integer) : double;
    function KappaVariance(R : IntDyneCube; n, m, K1 : integer) : double;

  public
    { public declarations }
  end; 

var
  GenKappaFrm: TGenKappaFrm;

implementation

uses
  Math;

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
VAR index : integer;
begin
     index := VarList.ItemIndex;
     CatEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     CatIn.Enabled := false;
     CatOut.Enabled := true;
end;

procedure TGenKappaFrm.CatOutClick(Sender: TObject);
begin
     VarList.Items.Add(CatEdit.Text);
     CatEdit.Text := '';
     CatIn.Enabled := true;
     CatOut.Enabled := false;
end;

procedure TGenKappaFrm.ComputeBtnClick(Sender: TObject);
VAR
     CatCol, ObjCol, RaterCol, frequency, i, j, k, l : integer;
     value, rater, category, anobject: integer;
//     int CatCol:=0, ObjCol:=0, RaterCol:=0;
//     int value, rater, category, object;
     R : IntDyneCube;
//     int ***R;
     pobs, pchance, kappa, num, denom, partial_pchance, a_priori : double;
     average_frequency : DblDyneVec;
     outline : array[0..131] of char;
//     char outline[131], astring[21];
     z : double;

begin
     CatCol:=0;
     ObjCol:=0;
     RaterCol:=0;
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Generalized Kappa Coefficient Procedure');
     OutputFrm.RichEdit.Lines.Add('adapted from the program written by Giovanni Flammia');
     OutputFrm.RichEdit.Lines.Add('copywritten 1995, M.I.T. Lab. for Computer Science');
     OutputFrm.RichEdit.Lines.Add('');

     // get columns for the variables
     for i := 0 to NoVariables - 1 do
     begin
         if (OS3MainFrm.DataGrid.Cells[i+1,0] = CatEdit.Text) then CatCol := i+1;
         if (OS3MainFrm.DataGrid.Cells[i+1,0] = RaterEdit.Text) then RaterCol := i+1;
         if (OS3MainFrm.DataGrid.Cells[i+1,0] = ObjectEdit.Text) then ObjCol := i+1;
     end;
     if ((CatCol = 0) or (RaterCol = 0) or (ObjCol = 0)) then
     begin
         ShowMessage('ERROR!  One or more variables not defined.');
         exit;
     end;
     // get max no of codes for objects, raters, categories
     NoCats := 0;
     NoObjects := 0;
     NoRaters := 0;
     for i := 0 to NoCases - 1 do
     begin
         value := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[CatCol,i+1]));
//        result := GetValue(i+1,CatCol,intvalue,dblvalue,strvalue);
//         if (result :=:= 1) value := 0;
//         else value := intvalue;
         if (value > NoCats) then NoCats := value;
         value := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[ObjCol,i+1]));
//         result := GetValue(i+1,ObjCol,intvalue,dblvalue,strvalue);
//         if (result :=:= 1) value := 0;
//         else value := intvalue;
         if (value > NoObjects) then NoObjects := value;
         value := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[RaterCol,i+1]));
//         result := GetValue(i+1,RaterCol,intvalue,dblvalue,strvalue);
//         if (result :=:= 1) value := 0;
//         else value := intvalue;
         if (value > NoRaters) then NoRaters := value;
     end;

     outline := format('%d Raters using %d Categories to rate %d Objects',
         [NoRaters, NoCats, NoObjects]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');

     // get memory for R and set to zero
     SetLength(R,NoRaters+1,NoCats+1,NoObjects+1);
     for i := 0 to NoRaters - 1 do
     begin
         for k := 0 to NoCats - 1 do
         begin
             for l := 0 to NoObjects - 1 do
             begin
                 R[i,k,l] := 0;
             end;
         end;
     end;

     // get memory for average_frequency
     SetLength(average_frequency,NoCats+1);
     for k := 0 to NoCats - 1 do average_frequency[k] := 0.0;

     // read data and store in R
     for i := 0 to NoCases - 1 do
     begin
         rater := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[RaterCol,i+1]));
         anobject := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[ObjCol,i+1]));
         category := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[CatCol,i+1]));
         R[rater-1,category-1,anobject-1] := 1;
     end;

     //compute chance probability of agreement pchance for all raters
     pchance := 0.0;
     denom := compute_denom(R);
     for i := 0 to NoRaters - 1 do
     begin
         for j := 0 to NoRaters - 1 do
         begin
             if (i <> j) then
             begin
                partial_pchance := compute_partial_pchance(R,i,j,denom);
                pchance := pchance + partial_pchance;
             end;
         end;
         for k := 0 to NoCats - 1 do
         begin
             frequency := 0;
             for l := 0 to NoObjects - 1 do
             begin
                 frequency := frequency + R[i,k,l];
             end;
             a_priori := frequency / NoObjects;
             outline := format('Frequency[%d,%d] := %f',[i+1,k+1,a_priori]);
             OutputFrm.RichEdit.Lines.Add(outline);
         end;
     end;

     for k := 0 to NoCats - 1 do
     begin
         for l := 0 to NoObjects - 1 do
         begin
             for i := 0 to NoRaters - 1 do
             begin
                 average_frequency[k] := average_frequency[k] + R[i,k,l];
             end;
         end;
     end;

     for k := 0 to NoCats - 1 do
     begin
         average_frequency[k] := average_frequency[k] / (NoObjects * NoRaters);
         outline := format('Average_Frequency[%d] := %f',[k+1,average_frequency[k]]);
         OutputFrm.RichEdit.Lines.Add(outline);
     end;
     outline := format('PChance := %f',[pchance]);
     OutputFrm.RichEdit.Lines.Add(outline);

     // compute observed probability of agreement among all raters
     num := 0.0;
     for k := 0 to NoCats - 1 do
     begin
         for l := 0 to NoObjects - 1 do
         begin
             num := num + compute_partial_pobs(R,k,l);
         end;
     end;
     if (denom > 0.0) then pobs := num / denom
     else pobs := 0.0;
     outline := format('PObs := %f',[pobs]);
     OutputFrm.RichEdit.Lines.Add(outline);

     kappa := (pobs - pchance) / (1.0 - pchance);
     outline := format('Kappa := %f',[kappa]);
     OutputFrm.RichEdit.Lines.Add(outline);
     z := KappaVariance(R,NoObjects,NoRaters,NoCats);
     if (z > 0.0) then z := kappa / sqrt(z);
     outline := format('z for Kappa := %8.3f with probability > %8.3f',[z,1.0-probz(z)]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.ShowModal;

     // clean up space allocated
     average_frequency := nil;
     R := nil;
end;

procedure TGenKappaFrm.FormActivate(Sender: TObject);
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

procedure TGenKappaFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TGenKappaFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TGenKappaFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

function TGenKappaFrm.compute_term1(R : IntDyneCube; i, j, k : integer) : double;
VAR
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
  begin
    for ll := 0 to NoObjects - 1 do
    begin
      denom_i := denom_i + R[i,kk,ll];
      denom_j := denom_j + R[j,kk,ll];
    end;
  end;

  for l := 0 to NoObjects - 1 do
  begin
    num_i := num_i + R[i,k,l];
    num_j := num_j + R[j,k,l];
  end;

  result := ((num_i / denom_i) * (num_j / denom_j));
end;

function TGenKappaFrm.compute_term2(R : IntDyneCube; i, j, l : integer) : double;
VAR
   sum_i, sum_j, k : integer;
begin
  sum_i:=0;
  sum_j:=0;

  for k := 0 to NoCats - 1 do
  begin
    sum_i := sum_i + R[i,k,l];
    sum_j := sum_j + R[j,k,l];
  end;

  result := (sum_i * sum_j );
end;

//---------------------------------------------------------------------------

function TGenKappaFrm.compute_denom(R : IntDyneCube) : double;
VAR
   sum : IntDyneVec;
   aresult : double;
   i, k, l : integer;
begin
  aresult := 0;

  SetLength(sum,NoObjects); //  sum := (int *)calloc(num_points,sizeof(int));
  for l := 0 to NoObjects - 1 do
  begin
    sum[l] := 0;
    for i := 0 to NoRaters - 1 do
    begin
      for k := 0 to NoCats - 1 do
      begin
         sum[l] := sum[l] + R[i,k,l];
      end;
    end;
  end;
  for l := 0 to NoObjects - 1 do
  begin
    aresult := aresult + sum[l] * ( sum[l] - 1);
  end;
  sum := nil;
  result := aresult;
end;

function TGenKappaFrm.compute_partial_pchance(R : IntDyneCube; i, j : integer;
                denom : double) : double;
VAR
   term1, term2 : double;
   k, l : integer;
begin
  term1 := 0;
  term2 := 0;

  for k := 0 to NoCats - 1 do
  begin
    term1 := term1 + compute_term1(R,i,j,k);
  end;

  for l := 0 to NoObjects - 1 do
  begin
    term2 := term2 + compute_term2(R,i,j,l);
  end;
  if (denom > 0.0) then result := ( term1 * ( term2 / denom ) )
  else result := 0.0;
end;
//---------------------------------------------------------------------------

function TGenKappaFrm.compute_partial_pobs(R : IntDyneCube; k, l : integer) : double;
VAR
   sum, i : integer;
begin
  sum := 0;

  for i := 0 to NoRaters - 1 do
  begin
    sum := sum + R[i,k,l];
  end;

  result := (sum * (sum - 1));
end;

function TGenKappaFrm.KappaVariance(R : IntDyneCube; n, m, K1 : integer) : double;
VAR
   xij, variance, term1, term2 : double;
   i, j, k : integer;
   pj : DblDyneVec;

begin
       // calculates the variance of Kappa
       // R contains 1's or 0's for raters, categories and objects (row, col, slice)
       // m is number of raters
       // n is number of subjects
       // K1 is the number of categories

       term1 := 0.0;
       term2 := 0.0;
       SetLength(pj,K1);
       for j := 0 to K1 - 1 do pj[j] := 0.0;

       // get proportion of values in each category
       for j := 0 to K1 - 1 do // accross categories
       begin
           xij := 0.0;
           for i := 0 to m - 1 do // accross raters
           begin
               for k := 0 to n - 1 do // accross objects
               begin
                   xij := xij + R[i,j,k];
               end;
           end;
           pj[j] := pj[j] + xij;
       end;
       for j := 0 to K1 - 1 do pj[j] := pj[j] / (n * m);
       for j := 0 to K1 - 1 do
       begin
           term1 := term1 +(pj[j] * (1.0 - pj[j]));
           term2 := term2 + (pj[j] * (1.0 - pj[j]) * (1.0 - 2.0 * pj[j]));
       end;
       term1 := term1 * term1;
       if ((term1 > 0) and (term2 > 0)) then
           variance := (2.0 / (n * m * (m-1) * term1)) * (term1 - term2)
       else variance := 0.0;
       pj := nil;
       result := variance;
end;

procedure TGenKappaFrm.ObjInClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;

     ObjectEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     ObjIn.Enabled := false;
     ObjOut.Enabled := true;
end;

procedure TGenKappaFrm.ObjOutClick(Sender: TObject);
begin
     VarList.Items.Add(ObjectEdit.Text);
     ObjectEdit.Text := '';
     ObjIn.Enabled := true;
     ObjOut.Enabled := false;
end;

procedure TGenKappaFrm.RaterInClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;

     RaterEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     RaterIn.Enabled := false;
     RaterOut.Enabled := true;
end;

procedure TGenKappaFrm.RaterOutClick(Sender: TObject);
begin
     VarList.Items.Add(RaterEdit.Text);
     RaterEdit.Text := '';
     RaterIn.Enabled := true;
     RaterOut.Enabled := false;
end;

initialization
  {$I genkappaunit.lrs}

end.

