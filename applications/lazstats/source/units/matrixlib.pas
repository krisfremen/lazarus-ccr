unit MatrixLib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs,
  Globals, DictionaryUnit, FunctionsLib, DataProcs, MainUnit;

procedure GridDotProd(col1, col2: integer; out Product: double; var Ngood: integer);

procedure GridXProd(NoSelected : integer;
                    {VAR} Selected : IntDyneVec;
                    {VAR} Product : DblDyneMat;
                    Augment : boolean;
                    VAR Ngood : integer);

procedure GridCovar(NoSelected: integer; const Selected: IntDyneVec;
  const Covar: DblDyneMat; const Means, Variances, StdDevs: DblDyneVec;
  var ErrorCode: boolean; var NGood: Integer);

procedure Correlations(NoSelected: integer; const Selected: IntDyneVec;
  const Correlations: DblDyneMat; const Means, Variances, StdDevs: DblDyneVec;
  var ErrorCode: boolean; var NGood: integer);

procedure MatAxB(const A, B, C: DblDyneMat; BRows, BCols, CRows, CCols: Integer;
  out ErrorCode: boolean);

procedure MatTrn(var A, B: DblDyneMat; BRows, BCols: Integer);

procedure nonsymroots(a : DblDyneMat; nv : integer;
                      var nf : integer; c : real;
                      var v : DblDyneMat; var e : DblDyneVec;
                      var  px : DblDyneVec;
                      var t : double;
                      var ev : double);

procedure ludcmp(const a: DblDyneMat; n: integer; const indx: IntDyneVec; out d: double);

procedure DETERM(const a: DblDyneMat; Rows, Cols: integer;
  out determ: double; out errorcode: boolean);

procedure EffectCode(GridCol, min, max : integer;
                    FactLetter : string;
                    VAR startcol : integer;
                    VAR endcol : integer;
                    VAR novectors : integer);
procedure MReg(NoIndep: integer; const IndepCols: IntDyneVec; DepCol: integer;
  const RowLabels: StrDyneVec;
  const Means, Variances, StdDevs, BWeights, BetaWeights, BStdErrs, Bttests, tProbs: DblDyneVec;
  out R2, StdErrEst: double; NCases: integer; out ErrorCode: boolean;
  PrintAll: boolean; AReport: TStrings);

procedure Dynnonsymroots(var a : DblDyneMat; nv : integer;
                      var nf : integer; c : real;
                      var v : DblDyneMat; var e : DblDyneVec;
                      var  px : DblDyneVec;
                      var t : double;
                      var ev : double);

function DynCorrelations(novars : integer;
                          VAR ColSelected : IntDyneVec;
                          VAR DataGrid : DblDyneMat;
                          VAR rmatrix : DblDyneMat;
                          VAR means : DblDyneVec;
                          VAR vars : DblDyneVec;
                          VAR stddevs : DblDyneVec;
                          NCases : integer;
                          ReturnType : integer) : integer;

procedure Predict(VAR ColNoSelected : IntDyneVec;
                  NoVars : integer;
                  VAR IndepInverse : DblDyneMat;
                  VAR Means : DblDyneVec;
                  VAR StdDevs : DblDyneVec;
                  VAR BetaWeights : DblDyneVec;
                  StdErrEst : double;
                  VAR IndepIndex : IntDyneVec;
                  NoIndepVars : integer);

procedure MReg2(NCases : integer;
               NoVars : integer;
               VAR NoIndepVars : integer;
               VAR IndepIndex : IntDyneVec;
               VAR corrs : DblDyneMat;
               VAR IndepCorrs : DblDyneMat;
               VAR RowLabels : StrDyneVec;
               out R2: double;
               VAR BetaWeights : DblDyneVec;
               VAR Means : DblDyneVec;
               VAR Variances : DblDyneVec;
               out errorcode : integer;
               out StdErrEst: double;
               out constant: double;
               probout : double;
               Printit : boolean;
               TestOut : boolean;
               PrintInv : boolean;
               AReport: TStrings);

procedure MatSub(const a, b, c: DblDyneMat;
  brows, bcols, crows, ccols: integer; out errorcode: boolean);

procedure IntArrayPrint(const mat: IntDyneMat; rows, cols: integer;
  const YTitle: string; const RowLabels, ColLabels: StrDyneVec;
  const Title: string; AReport: TStrings);

procedure eigens(VAR a: DblDyneMat; Var d : DblDyneVec; n : integer);

PROCEDURE tred2(VAR a: DblDyneMat; n: integer; VAR d,e: DblDyneVec);

PROCEDURE tqli(VAR d,e: DblDyneVec; n: integer; VAR z: DblDyneMat);

function SEVS(nv,nf : integer;
               c : double;
               var r : DblDyneMat;
               VAR v : DblDyneMat;
               VAR e : DblDyneVec;
               var p : DblDyneVec;
               VAR nd : integer) : integer ;

function SCPF(VAR x,y : DblDyneMat; kx,ky,n,nd : integer) : double;

procedure MatPrint(const xmat: DblDyneMat; Rows,Cols: Integer; const Title: String;
  const RowLabels, ColLabels: StrDyneVec; NCases: Integer; AReport: TStrings);

procedure DynVectorPrint(const AVector: DblDyneVec; NoVars: integer;
  Title: string; const Labels: StrDyneVec; NCases: integer; AReport: TStrings);

procedure ScatPlot(const x, y: DblDyneVec; NoCases: integer;
  const TitleStr, x_axis, y_axis: string; x_min, x_max, y_min, y_max: double;
  const VarLabels: StrDyneVec; AReport: TStrings);

procedure DynIntMatPrint(Mat: IntDyneMat; Rows, Cols: integer; YTitle: string;
  RowLabels, ColLabels: StrDyneVec; Title: string; AReport: TStrings);

procedure SymMatRoots(A : DblDyneMat; M : integer; VAR E : DblDyneVec; VAR V : DblDyneMat);
procedure matinv(a, vtimesw, v, w: DblDyneMat; n: integer);


implementation

uses
  StrUtils, Utils;

procedure GridDotProd(col1, col2: integer; out Product: double; var Ngood: integer);
// Get the cross-product of two vectors
// col1 and col2 are grid columns of the main form's DataGrid
// Product is the vector product
// Ngood are the number of elements in the product not missing or filtered

// wp: "vector product" -- misleading name because the procedure return the "dot" product.
// ==> Renamed from "GridVecProd" to "GridDotProd"
var
  i: integer;
  Selected: IntDyneVec;
  X1, X2: double;
begin
  SetLength(Selected,2);
  Product := 0.0;
  Selected[0] := col1;
  Selected[1] := col2;
  for i := 1 to NoCases do
  begin
     if not GoodRecord(i,2,Selected) then continue;
     Ngood := Ngood + 1;
     X1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col1, i]));
     X2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col2, i]));
     Product := Product + X1 * X2;
  end;
  Selected := nil;
end;
//-------------------------------------------------------------------

procedure GridXProd(NoSelected : integer;
                    {VAR} Selected : IntDyneVec;
                    {VAR} Product : DblDyneMat;
                    Augment : boolean;
                    var Ngood : integer);
// Matrix product of a grid matrix and its transpose
// Product contains the cross-products matrix upon return
// Selected is a integer vector of grid columns of the vectors
// NoSelected is an integer of the number of grid vectors selected
// Ngood is the number of elements in a vector product not missing or filtered
// Augment is true if the augment matrix is to be obtained and is required
// to obtain means, variances, standard deviations in the correlation procedure
// and GridCovar procedure
var
   i, j, k : integer;
   Col1, Col2 : integer;
   X1 : double;
   Prod : double;
   NoVars : integer;
   N : double;

begin
     // initialize
     N := 0.0;
     NoVars := 0;
     for i := 1 to NoSelected do
         for j := 1 to NoSelected do
             Product[i-1,j-1] := 0.0;
     if Augment then
     begin
          NoVars := NoSelected + 1;
          for i := 1 to NoVars do
          begin
               Product[i-1,NoVars-1] := 0.0;
               Product[NoVars-1,i-1] := 0.0;
          end;
     end;

     // Do cross-products without augmentation
     for i := 1 to NoSelected do // pre-matrix row (Grid transpose)
     begin
          for j := 1 to NoSelected do // post-matrix column (Grid)
          begin
               Ngood := 0;
               Col1 := Selected[i-1];
               Col2 := Selected[j-1];
               GridDotProd(Col1,Col2,Prod, Ngood);
               Product[i-1,j-1] := Prod;
          end;
     end;

     if Augment then // do last column and row for augmented matrix
     begin
          for j := 1 to NoSelected do
          begin
               Col1 := Selected[j-1];
               for k := 1 to NoCases do
               begin
                    if not GoodRecord(k,NoSelected,Selected) then continue;
                    X1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[Col1,k]));
                    Product[NoVars-1,j-1] := Product[NoVars-1,j-1] + X1;
                    Product[j-1,NoVars-1] := Product[j-1,NoVars-1] + X1;
               end;
          end;
          for i := 1 to NoCases do // last cell of augmented matix
          begin
               if not GoodRecord(i,NoSelected,Selected) then continue;
               N := N + 1.0;
          end;
          Product[NoVars-1,NoVars-1] := N;
          Ngood := round(N);
     end;
end;
//-------------------------------------------------------------------

{ Obtains the variance/covariance matrix of variables in the grid
  NoSelected is the number of variables selected from the grid
  Selected is a vector of integers for the grid columns of selected variables
  Covar is the variance/covariance matrix returned
  Means, StdDevs, Variances are double vectors obtained from the augmented matrix
  errorcode is true if an error occurs due to 0 variance
  Ngood is the number of records in the cross-product of vectors
  This procedure calls the GridXProd procedure with augmentation true
  in order to obtain the means, variances and standard deviations }
procedure GridCovar(NoSelected: integer; const Selected: IntDyneVec;
  const Covar: DblDyneMat; const Means, Variances, StdDevs: DblDyneVec;
  var errorcode: boolean; var NGood: integer);
var
  i, j: integer;
  N: double;
  Augment: boolean;
begin
  // initialize
  ErrorCode := false;
  for i := 0 to NoSelected-1 do
  begin
    Means[i] := 0.0;
    Variances[i] := 0.0;
    StdDevs[i] := 0.0;
  end;
  Augment := true; // augment to get intercept, means, variances, std.devs.

  // get cross-products
  GridXProd(NoSelected,Selected,Covar,Augment,Ngood);

  // Get no. of records in cross-products
  N := Ngood;

  //  Sums of squares are in diagonal, cross-products in off-diagonal cells
  //  Sums of X's are in the augmented column
  //  Get means and standard deviations first
  for i := 0 to NoSelected-1 do
  begin
    Means[i] := Covar[i, NoSelected] / N;
    Variances[i] := Covar[i, i] - (Sqr(Covar[i, NoSelected]) / N);
    Variances[i] := Variances[i] / (N - 1.0);
    if Variances[i] > 0.0 then
      StdDevs[i] := sqrt(Variances[i])
    else
    begin
      StdDevs[i] := 0.0;
      ErrorCode := true;
    end;
  end;

  // Now get covariances
  for i := 0 to NoSelected-1 do
  begin
    for j := 0 to NoSelected-1 do
    begin
      Covar[i, j] := Covar[i, j] - ((Covar[i, NoSelected] * Covar[j, NoSelected]) / N);
      Covar[i, j] := Covar[i, j] / (N - 1);
    end;
  end;
end;
//-------------------------------------------------------------------

{ Obtains the correlation matrix among grid variables
  NoSelected is the no. of grid variables selected for analysis
  Selected is a vector of integers of the grid variable columns selected
  Correlations are returned in the Correlations matrix
  Means, Variances, StdDevs are returned as double vectors
  errorcode is true if a 0 variance is detected
  Ngood is the number cases that do not contain missing values or are filtered
  This procedure calls the GridCovar procedure }
procedure Correlations(NoSelected: integer; const Selected: IntDyneVec;
  const Correlations: DblDyneMat; const Means, Variances, StdDevs: DblDyneVec;
  var ErrorCode: boolean; var NGood: integer);
var
  i, j: integer;
begin
  // get covariance matrix, means and standard deviations
  GridCovar(NoSelected, Selected, Correlations, Means, Variances, StdDevs, ErrorCode, Ngood);
  for i := 0 to NoSelected-1 do
  begin
    for j := 0 to NoSelected-1 do
    begin
      if (StdDevs[i] > 0.0) and (StdDevs[j] > 0.0) then
        Correlations[i, j] := Correlations[i, j] / (StdDevs[i] * StdDevs[j])
      else
      begin
        Correlations[i, j] := 0.0;
        ErrorCode := true;
      end;
    end;
  end;
end;
//-------------------------------------------------------------------

// Product of matrix b times c with results returned in a
procedure MatAxB(const A, B, C: DblDyneMat; BRows, BCols, CRows, CCols: Integer;
  out ErrorCode: boolean);
var
  i, j, k: integer;
begin
  ErrorCode := false;
  if (BCols <> CRows) then
    ErrorCode := true
  else
  begin
    for i := 0 to BRows-1 do
    begin
      for j := 0 to CCols-1 do
      begin
        A[i,j] := 0.0;
        for k := 0 to CRows-1 do
          A[i,j] := A[i,j] + B[i,k] * C[k,j];
      end;
    end;
  end;
end; { of MATAxB }

//-------------------------------------------------------------------

// transpose the b matrix and return it in a
procedure MatTrn(var A, B: DblDyneMat; BRows, BCols : integer);
var
  i, j: integer;
begin
  for i := 0 to BRows-1 do
    for j := 0 to BCols-1 do
      A[j,i] := B[i,j];
end; { of mattrn }
//-------------------------------------------------------------------

procedure nonsymroots(a : DblDyneMat; nv : integer;
                      var nf : integer; c : real;
                      var v : DblDyneMat; var e : DblDyneVec;
                      var  px : DblDyneVec;
                      var t : double;
                      var ev : double);
{ roots and vectors of a non symetric matrix.  a is square matrix entered
  and is destroyed in process.  nv is number of variables (rows and columns )
  of a.  nf is the number of factorsto be extracted - is output as the number
  which exceeded c, the minimum eigenvalue to be extracted.  v is the output
  matrix of column vectors of loadings.  e is the output vector of roots.  px
  is the percentages of trace for factors. t is the trace of the matrix and
  ev is the percent of trace extracted }
label 40;
var
   y, z : DblDyneVec;
   ek, e2, d : real;
   i, j, k, m : integer;
begin
     SetLength(y,nv);
     SetLength(z,nv);
     t := 0.0;
     for i := 0 to nv-1 do t := t + a[i,i];
     for k := 0 to nf-1 do
     begin
          for i := 0 to nv-1 do
          begin
               px[i] := 1.0;
               y[i] := 1.0;
          end;
          e[k] := 1.0;
          ek := 1.0;
          for m := 1 to 25 do
          begin
               for i := 0 to nv-1 do
               begin
                    v[i,k] := px[i] / e[k];
                    z[i] := y[i] / ek;
               end;
               for i := 0 to nv-1 do
               begin
                    px[i] := 0.0;
                    for j := 0 to nv-1 do  px[i] := px[i] + a[i,j] * v[j,k];
                    y[i] := 0.0;
                    for j := 0 to nv-1 do y[i] := y[i] + a[j,i] * z[j];
               end;
               e2 := 0.0;
               for j := 0 to nv-1 do e2 := e2 + px[j] * v[j,k];
               e[k] := sqrt(abs(e2));
               ek := 0.0;
               for j := 0 to nv-1 do ek := ek + y[j] * z[j];
               ek := sqrt(abs(ek));
          end;
          if e2 >= sqr(c) then
          begin
               d := 0.0;
               for j := 0 to nv-1 do d := d + v[j,k] * z[j];
               d := e[k] / d;
               for i := 0 to nv-1 do
                   for j := 0 to nv-1 do
                       a[i,j] := a[i,j] - v[i,k] * z[j] * d;
          end
          else begin
               nf := k - 1;
               goto 40;
          end;
     end;
     40 : for i := 0 to nf-1 do px[i] := e[i] / t * 100.0;
          ev := 0.0;
          for i := 0 to nf-1 do ev := ev + px[i];
          z := nil;
          y := nil;
end; { of procedure nonsymroots }
//-------------------------------------------------------------------

PROCEDURE ludcmp(const a: DblDyneMat; n: integer; const indx: IntDyneVec; out d: double);
const
  tiny = 1.0e-20;
var
  k,j,imax,i: integer;
  sum,dum,big: double;
  vv: DblDyneVec;
BEGIN
   SetLength(vv,n);
   d := 1.0;
   imax := 0;
   for i := 1 to n do begin
      big := 0.0;
      for j := 1 to n do
        if (abs(a[i-1,j-1]) > big) then big := abs(a[i-1,j-1]);
      if (big = 0.0) then
      begin
         MessageDlg('Singular matrix in Lower-Upper Decomposition routine', mtError, [mbOK], 0);
         exit;
      end;
      vv[i-1] := 1.0/big;
   end;

   for j := 1 to n do
   begin
      if (j > 1) then
      begin
         for i := 1 to j-1 do
         begin
            sum := a[i-1,j-1];
            if (i > 1) then
            begin
               for k := 1 to i-1 do
                  sum := sum - a[i-1,k-1] * a[k-1,j-1];
               a[i-1,j-1] := sum
            end;
         end;
      end;

      big := 0.0;
      for i := j to n do
      begin
         sum := a[i-1,j-1];
         if (j > 1) then
         begin
            for k := 1 to j-1 do
               sum := sum - a[i-1,k-1] * a[k-1,j-1];
            a[i-1,j-1] := sum
         END;
         dum := vv[i-1] * abs(sum);
         if (dum > big) then
         begin
            big := dum;
            imax := i
         end;
      end;

      if (j <> imax) then
      begin
         for k := 1 to n do
         begin
            dum := a[imax-1,k-1];
            a[imax-1,k-1] := a[j-1,k-1];
            a[j-1,k-1] := dum;
         end;
         d := -d;
         vv[imax-1] := vv[j-1]
      end;
      indx[j-1] := imax;
      if (j <> n) then
      begin
         if (a[j-1,j-1] = 0.0) then
           a[j-1,j-1] := tiny;
         dum := 1.0/a[j-1,j-1];
         for i := j+1 to n do
            a[i-1,j-1] := a[i-1,j-1] * dum;
      end;
   end;

   if (a[n-1,n-1] = 0.0) then
     a[n-1,n-1] := tiny;

   vv := nil;
end;
//-------------------------------------------------------------------

procedure Determ(const a: DblDyneMat; Rows, Cols: integer; out determ: double;
  out ErrorCode: boolean);
var
  indx: IntDyneVec;
  i: integer;
begin
  SetLength(indx,rows);
  ErrorCode := false;
  if (rows <> cols) then
    ErrorCode := true
  else
  begin
    LUDCMP(a, rows, indx, determ);
    for i := 0 to rows-1 do
      determ := determ * a[i, i];
  end;
end; { of determ }
//-------------------------------------------------------------------

procedure EffectCode(GridCol, min, max: integer; FactLetter: string;
  var StartCol, EndCol, NoVectors: integer);
var
  levels, i, j, grp, col, cval: integer;
  coef: IntDyneMat;
  labelstr: string;
begin
   Assert(OS3MainFrm <> nil);
   Assert(DictionaryFrm <> nil);

   // Routine for creating coded vectors representing group membership
   // for purposes of multiple regression effects of group membership
   levels := max - min + 1;
   SetLength(coef,levels,levels);
   novectors := levels - 1;
   startcol := NoVariables + 1;
   endcol := startcol + novectors - 1;

   // setup grid for additional columns
   for i := 1 to levels - 1 do
   begin
     labelstr := FactLetter + IntToStr(i);
     col := NoVariables + 1;
     DictionaryFrm.NewVar(col);
     DictionaryFrm.DictGrid.Cells[1,col] := labelstr;
     OS3MainFrm.DataGrid.Cells[col,0] := labelstr;
   end;

   // get coefficients for effect coding
   for i := 1 to levels do // group code
   begin
     for j := 1 to levels - 1 do // vector code
     begin
       if i = j then coef[i-1,j-1] := 1;
       if i = levels then coef[i-1,j-1] := -1;
       if (i <> j) and (i <> levels) then coef[i-1,j-1] := 0;
     end;
   end;

   // code the cases using coefficients above
   col := NoVariables - (levels - 1);
   for i := 1 to levels - 1 do
   begin
     col := col + 1;
     for j := 1 to NoCases do
     begin
       // subject group code
       grp := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GridCol,j]))) - min + 1;
       // vector code
       cval := coef[grp-1,i-1];
       OS3MainFrm.DataGrid.Cells[col,j] := IntToStr(cval);
     end;
   end;

   OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
   coef := nil;
end;

procedure MReg(NoIndep: integer; const IndepCols: IntDyneVec; DepCol: integer;
  const RowLabels: StrDyneVec;
  const Means, Variances, StdDevs, BWeights, BetaWeights, BStdErrs, Bttests, tProbs: DblDyneVec;
  out R2, StdErrEst: double; NCases: integer; out ErrorCode: boolean;
  PrintAll: boolean; AReport: TStrings);
var
  i, j, N: integer;
  X: DblDyneMat;
  XT: DblDyneMat;
  XTX: DblDyneMat;
  XTY: DblDyneVec;
  Y: DblDyneVec;
  indx: IntDyneVec;
  ColLabels: StrDyneVec;
  F, Prob, VarY, SDY, MeanY: double;
  value, TOL, VIF, AdjR2: double;
  SSY, SSres, resvar, SSreg: double;
  title: string;
  deplabel: string;
  errcode: boolean;
begin
  Assert(OS3MainFrm <> nil);

  SetLength(X, NoCases+1, NoIndep+1); // augmented independent var. matrix
  SetLength(XT, NoIndep+1, NoCases); // transpose of independent var's
  SetLength(XTX, NoIndep+1, NoIndep+1); // product of transpose X times X
  SetLength(Y, NCases+1); // Y variable values
  SetLength(XTY, NoIndep+1); // X transpose times Y
  SetLength(indx, NoIndep+1);
  SetLength(ColLabels, NCases);

  // initialize
  errcode := false;
  for i := 0 to NCases do
  begin
    for j := 0 to NoIndep do X[i, j] := 0;
    Y[i] := 0.0;
  end;
  for i := 0 to NoIndep do
  begin
    indx[i] := 0;
    XTY[i] := 0.0;
    Y[i] := 0.0;
    tprobs[i] := 0.0;
    Means[i] := 0.0;
    Variances[i] := 0.0;
    StdDevs[i] := 0.0;
    BWeights[i] := 0.0;
    BetaWeights[i] := 0.0;
    for j := 0 to NoCases-1 do XT[i, j] := 0.0;
    for j := 0 to NoIndep do XTX[i, j] := 0.0;
  end;
  for i := 0 to NCases-1 do
    ColLabels[i] := 'Case ' + IntToStr(i+1);

  SSY := 0.0;
  VarY := 0.0;
  SDY := 0.0;
  MeanY := 0.0;

  // get independent matrix and Y vector from the grid
  NCases := 0;
  N := NoIndep + 1;

  for i := 1 to NoCases do
  begin
    if not GoodRecord(i, Noindep, IndepCols) then continue;
    for j := 0 to NoIndep-1 do
    begin
      value := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[IndepCols[j], i]));
      X[NCases, j] := value;
      Means[j] := Means[j] + value;
      Variances[j] := Variances[j] + value * value;
    end;
    value := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepCol, i]));
    Y[NCases] := value;
    MeanY := MeanY + value;
    SSY := SSY + value * value;
    Means[Noindep] := Means[Noindep] + value;
    Variances[Noindep] := Variances[Noindep] + value * value;
    NCases := NCases + 1;
  end;

  deplabel := OS3MainFrm.DataGrid.Cells[DepCol,0];
  RowLabels[NoIndep] := 'Intercept';
  VarY := SSY - (MeanY * MeanY / NCases);
  VarY := VarY / (NCases - 1);
  SDY := sqrt(VarY);

  AReport.Add('Variance Y: %10.3f', [VarY]);
  AReport.Add('SSY:        %10.3f', [SSY]);
  AReport.Add('SDY:        %10.3f', [SDY]);

  // augment the matrix
  for i := 1 to NCases do
    X[i-1, NoIndep] := 1.0;
  Y[NCases] := 1.0;

  // get transpose of augmented X matrix
  MatTrn(XT, X, NCases, NoIndep+1);
  if PrintAll then
  begin
    title := 'XT MATRIX';
    MatPrint(XT, NoIndep+1, NCases, title, RowLabels, ColLabels, NCases, AReport);
  end;

  // get product of the augmented X transpose times augmented X
  MatAXB(XTX, XT, X, NoIndep+1, NCases, NCases, NoIndep+1, errorcode);
  if PrintAll then
  begin
    title := 'XTX MATRIX';
    MatPrint(XTX, Noindep+1, NoIndep+1, title, RowLabels, RowLabels, NCases, AReport);
  end;

  //Get means, variances and standard deviations
  errorcode := false;
  for i := 0 to NoIndep do
  begin
    Variances[i] := XTX[i,i] - sqr(XTX[i, NoIndep])/NCases;
    Variances[i] := Variances[i] / (NCases - 1);
    if (Variances[i] > 0.0) then
      StdDevs[i] := sqrt(Variances[i])
    else
      errorcode := true;
    Means[i] := XTX[N-1,i] / NCases;
  end;

  if PrintAll then
  begin
    DynVectorPrint(Means, NoIndep+1, 'MEANS', RowLabels, NCases, AReport);
    DynVectorPrint(Variances, NoIndep+1,'VARIANCES',RowLabels, NCases, AReport);
    DynVectorPrint(StdDevs, NoIndep+1, 'STD. DEV.S', RowLabels, NCases, AReport);
  end;

  // get product of the augmented X transpose matrix times the Y vector
  for i := 0 to N-1 do
    for j := 0 to NCases-1 do
      XTY[i] := XTY[i] + (XT[i,j] * Y[j]);
  if PrintAll then
    DynVectorPrint(XTY, NoIndep+1, 'XTY VECTOR', RowLabels, NCases, AReport);

   // get inverse of the augmented cross products matrix among independent variables
  SVDInverse(XTX,N);
  if PrintAll then
  begin
    title := 'XTX MATRIX INVERSE';
    MatPrint(XTX, NoIndep+1, NoIndep+1, title, RowLabels, RowLabels, NCases, AReport);
  end;

  // multiply augmented inverse matrix times the XTY vector
  // result is bweights with the intercept last
  for i := 0 to N-1 do
    for j := 0 to N-1 do
      BWeights[i] := BWeights[i] + (XTX[i,j] * XTY[j]);

  //Get Beta weightw
  for i := 0 to N-2 do
    BetaWeights[i] := BWeights[i] * StdDevs[i] / SDY;

  // Get standard errors, squared multiple correlation, tests of significance
  SSres := 0.0;
  for i := 0 to NoIndep do
    SSres := SSres + BWeights[i] * XTY[i];
  SSres := SSY - SSres;
  resvar := SSres / (NCases - N);
  if resvar > 0.0 then StdErrEst := sqrt(resvar) else StdErrest := 0.0;
  for i := 0 to N-1 do  // Standard errors and t-tedt values for weights
  begin
    BStdErrs[i] := sqrt(resvar * XTX[i,i]);
    Bttests[i] := BWeights[i] / BStdErrs[i];
    tprobs[i] := probt(Bttests[i],NCases-N);
  end;
  SSY := VarY * (NCases-1);
  SSreg := SSY - SSres;
  R2 := SSreg / SSY;
  F := (SSreg / (N - 1)) / (SSres / (NCases - N));
  Prob := probf(F,(N-1),(NCases-N));
  AdjR2 := 1.0 - (1.0 - R2) * (NCases - 1) / (NCases - N);
  if PrintAll then
  begin
    AReport.Add('Dependent variable: ' + deplabel);
    AReport.Add('');
    DynVectorPrint(BWeights, NoIndep+1, 'B WEIGHTS', RowLabels, NCases, AReport);
    AReport.Add('');
    AReport.Add('');
    AReport.Add('Dependent variable: ' + deplabel);
    AReport.Add('');
    DynVectorPrint(BetaWeights, NoIndep, 'BETA WEIGHTS', RowLabels, NCases, AReport);
    AReport.Add('');
    AReport.Add('');
    DynVectorPrint(BStdErrs, NoIndep+1, 'B STD.ERRORS', RowLabels, NCases, AReport);
    AReport.Add('');
    DynVectorPrint(Bttests, NoIndep+1, 'B t-test VALUES', RowLabels, NCases, AReport);
    AReport.Add('');
    DynVectorPrint(tprobs, NoIndep+1, 'B t VALUE PROBABILITIES', RowLabels, NCases, AReport);
    AReport.Add('');

    AReport.Add('SSY:                        %10.2f', [SSY]);
    AReport.Add('SSreg:                      %10.2f', [SSreg]);
    AReport.Add('SSres:                      %10.2f', [SSres]);
    AReport.Add('R2:                         %10.4f', [R2]);
    AReport.Add('F:                          %10.2f   (D.F. %d, %d)', [F, N-1, NCases-N]);
//    AReport.Add('D.F. %d %d',                         [N-1, NCases-N]);
    AReport.Add('Probability > F:            %10.4f', [Prob]);
    AReport.Add('Standard Error of Estimate: %10.2f', [stderrest]);
    AReport.Add('');

    //AReport.Add('SSY = %10.2f, SSreg = %10.2f, SSres = %10.2f', [SSY, SSreg, SSres]);
    //AReport.Add('R2 = %6.4f, F = %8.2f, D.F. = %d %d, Prob>F = %6.4f', [R2, F, N-1, NCases-N, Prob]);
    //AReport.Add('Standard Error of Estimate = %8.2f', [stderrest]);
  end;

  RowLabels[N-1] := 'Intercept';
  AReport.Add(' Variable     Beta        B       Std.Err.      t         prob       VIF      TOL');
  AReport.Add('---------- ---------- ---------- ---------- ---------- ---------- --------- ----------');
  Correlations(NoIndep, IndepCols, XTX, Means, Variances, StdDevs, errcode, NCases);
  SVDinverse(XTX, NoIndep);
  for i := 0 to NoIndep do
  begin
    VIF := XTX[i,i];
    if VIF > 0.0 then TOL := 1.0 / VIF else TOL := 0.0;
    AReport.Add('%10s %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f', [
      RowLabels[i], BetaWeights[i], BWeights[i], BStdErrs[i], Bttests[i], tprobs[i], VIF, TOL
    ]);
  end;
  AReport.Add('');
  AReport.Add('SOURCE      DF       SS             MS             F        Prob. > F');
  AReport.Add('---------- --- -------------- -------------- -------------- ----------');
  AReport.Add('Regression %3d  %14.3f %14.3f %14.4f %10.4f', [N-1, SSreg, SSreg/(N-1), F, Prob]);     // df1
  AReport.Add('Residual   %3d  %14.3f %14.3f', [(NCases-N), SSres, SSres/(NCases-N)]);            // df2
  AReport.Add('Total      %3d  %14.3f', [NCases-1, SSY]);
  AReport.Add('');

  AReport.Add('R2:                         %10.4f', [R2]);
  AReport.Add('F:                          %10.2f   (D.F. %d, %d)', [F, N-1, NCases-N]);
//  AReport.Add('D.F. %d and %d',                     [N-1, NCases-N]);
  AReport.Add('Probability > F:            %10.4f', [Prob]);
  AReport.Add('Adjusted R2:                %10.4f', [AdjR2]);
  AReport.Add('Standard Error of Estimate: %10.2f', [stderrest]);

  //AReport.Add('R2 = %6.4f,  F = %8.2f,  D.F. = %d %d  Prob.>F = %6.4f', [R2, F, N-1, NCases-N, Prob]);
  //AReport.Add('Adjusted R2 = %6.4f', [AdjR2]);
  //AReport.Add('Standard Error of Estimate = %8.2f', [stderrest]);

  // clean up the heap
  ColLabels := nil;
  indx := nil;
  XTY := nil;
  Y := nil;
  XTX := nil;
  XT := nil;
  X := nil;
end;
//-------------------------------------------------------------------

procedure Dynnonsymroots(var a : DblDyneMat; nv : integer;
                      var nf : integer; c : real;
                      var v : DblDyneMat; var e : DblDyneVec;
                      var  px : DblDyneVec;
                      var t : double;
                      var ev : double);
{ roots and vectors of a non symetric matrix.  a is square matrix entered
  and is destroyed in process.  nv is number of variables (rows and columns )
  of a.  nf is the number of factorsto be extracted - is output as the number
  which exceeded c, the minimum eigenvalue to be extracted.  v is the output
  matrix of column vectors of loadings.  e is the output vector of roots.  px
  is the percentages of trace for factors. t is the trace of the matrix and
  ev is the percent of trace extracted }
label 40;
var
   y, z : DblDyneVec;
   ek, e2, d : real;
   i, j, k, m : integer;
begin
     SetLength(y,nv);
     SetLength(z,nv);
     t := 0.0;
     for i := 0 to nv-1 do t := t + a[i,i];
     for k := 0 to nf-1 do
     begin
          for i := 0 to nv-1 do
          begin
               px[i] := 1.0;
               y[i] := 1.0;
          end;
          e[k] := 1.0;
          ek := 1.0;
          for m := 1 to 25 do
          begin
               for i := 0 to nv-1 do
               begin
                    v[i,k] := px[i] / e[k];
                    z[i] := y[i] / ek;
               end;
               for i := 0 to nv - 1 do
               begin
                    px[i] := 0.0;
                    for j := 0 to nv-1 do  px[i] := px[i] + a[i,j] * v[j,k];
                    y[i] := 0.0;
                    for j := 0 to nv-1 do y[i] := y[i] + a[j,i] * z[j];
               end;
               e2 := 0.0;
               for j := 0 to nv-1 do e2 := e2 + px[j] * v[j,k];
               e[k] := sqrt(abs(e2));
               ek := 0.0;
               for j := 0 to nv-1 do ek := ek + y[j] * z[j];
               ek := sqrt(abs(ek));
          end;
          if e2 >= sqr(c) then
          begin
               d := 0.0;
               for j := 0 to nv - 1 do d := d + v[j,k] * z[j];
               d := e[k] / d;
               for i := 0 to nv - 1 do
                   for j := 0 to nv - 1 do
                       a[i,j] := a[i,j] - v[i,k] * z[j] * d;
          end
          else begin
               nf := k - 1;
               goto 40;
          end;
     end;
     40 : for i := 0 to nf-1 do px[i] := e[i] / t * 100.0;
          ev := 0.0;
          for i := 0 to nf-1 do ev := ev + px[i];
          z := nil;
          y := nil;
end; { of procedure nonsymroots }
//-----------------------------------------------------------------------------

function DynCorrelations(novars : integer;
                          VAR ColSelected : IntDyneVec;
                          VAR DataGrid : DblDyneMat;
                          VAR rmatrix : DblDyneMat;
                          VAR means : DblDyneVec;
                          VAR vars : DblDyneVec;
                          VAR stddevs : DblDyneVec;
                          NCases : integer;
                          ReturnType : integer) : integer;
var
    i, j, k, row, col, errorcode : integer;
    X, Y : double;
begin
     errorcode := 0;
     for i := 0 to novars - 1 do
     begin
          means[i] := 0.0;
          vars[i] := 0.0;
          stdDevs[i] := 0.0;
          for j := 0 to novars - 1 do
          begin
               rmatrix[i,j] := 0.0;
          end;
     end;
     { get cross products }
     for i := 0 to NCases - 1 do
     begin
          if IsFiltered(i) then continue;
          for j := 0 to novars - 1 do
          begin
               row := ColSelected[j];
               X := DataGrid[i,row];
               means[j] := means[j] + X;
               vars[j] := vars[j] + (X * X);
               for k := 0 to novars - 1 do
               begin
                    col := ColSelected[k];
                    Y := DataGrid[i,col];
                    rmatrix[j,k] := rmatrix[j,k] + (X * Y);
               end;
          end;
     end;
     for j := 0 to novars - 1 do
     begin
          vars[j] := vars[j] - (means[j] * means[j] / NCases);
          vars[j] := vars[j] / (NCases-1);
          if (vars[j] > 0.0) then stddevs[j] := sqrt(vars[j])
          else stddevs[j] := 0.0;
     end;
     if ReturnType = 1 then {return cross-products, variances, std.devs, means }
     begin
          for i := 0 to novars - 1 do
          begin
               means[i] := means[i] / NCases;
          end;
          DynCorrelations := errorcode;
          exit;
     end;

     for i := 0 to novars - 1 do {get variance-covariance matrix }
     begin
          for j := 0 to novars - 1 do
          begin
               rmatrix[i,j] := rmatrix[i,j] - (means[i] * means[j] / NCases);
               rmatrix[i,j] := rmatrix[i,j] / (NCases - 1);
          end;
     end;
     if ReturnType = 2 then
     begin
          for i := 0 to novars - 1 do
          begin
               means[i] := means[i] / NCases;
          end;
          DynCorrelations := errorcode;
          exit;
     end;

     for i := 0 to novars - 1 do { get product-moment correlations }
     begin
          for j := 0 to novars - 1 do
          begin
               if ((stddevs[i] > 0.0) and (stddevs[j] > 0.0)) then
               rmatrix[i,j] := rmatrix[i,j] / (stddevs[i] * stddevs[j])
               else
               begin
                    rmatrix[i,j] := 9.999;
                    errorcode := 1;
               end;
          end;
     end;
     for i := 0 to novars - 1 do
     begin
          means[i] := means[i] / NCases;
     end;
     DynCorrelations := errorcode;
end;
//---------------------------------------------------------------------------

procedure Predict(VAR ColNoSelected : IntDyneVec;
                  NoVars : integer;
                  VAR IndepInverse : DblDyneMat;
                  VAR Means : DblDyneVec;
                  VAR StdDevs : DblDyneVec;
                  VAR BetaWeights : DblDyneVec;
                  StdErrEst : double;
                  VAR IndepIndex : IntDyneVec;
                  NoIndepVars : integer);
var
   col, i, j, k, index, IndexX, IndexY : integer;
   predicted, zpredicted, z1, z2, resid, Term1, Term2 : double;
   StdErrPredict, t95, Hi95, Low95 : double;

begin
  Assert(OS3MainFrm <> nil);
  Assert(DictionaryFrm <> nil);

  { use the next available grid column to store the z predicted score }
  col := NoVariables + 1;
  DictionaryFrm.NewVar(col);
  DictionaryFrm.DictGrid.Cells[1,col] := 'Pred.z';
  OS3MainFrm.DataGrid.Cells[col,0] := 'Pred.z';
  col := NoVariables + 1;
  DictionaryFrm.NewVar(col);
  DictionaryFrm.DictGrid.Cells[1,col] := 'z Resid.';
  OS3MainFrm.DataGrid.Cells[col,0] := 'z Resid.';
  for i := 1 to NoCases do
  begin
       zpredicted := 0.0;
       for j := 1 to NoIndepVars do
       begin
            Index := IndepIndex[j-1];
            k := ColNoSelected[Index-1];
            z1 := (StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[k,i])) -
                       Means[Index-1]) / StdDevs[index-1];
            zpredicted := zpredicted + (z1 * BetaWeights[j-1]);
            OS3MainFrm.DataGrid.Cells[col-1,i] := format('%8.4f',[zpredicted]);
       end;
       Index := ColNoSelected[NoVars-1];
       z2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[Index,i]));
       z2 := (z2 - Means[NoVars-1]) / StdDevs[NoVars-1];
       OS3MainFrm.DataGrid.Cells[col,i] := format('%8.4f',[(z2 - zpredicted)]);
  end;
  col := NoVariables + 1;
  DictionaryFrm.NewVar(col);
  DictionaryFrm.DictGrid.Cells[1,col] := 'Pred.Raw';
  OS3MainFrm.DataGrid.Cells[col,0] := 'Pred.Raw';
  { calculate raw predicted scores and store in grid at col }
  for i := 1 to NoCases do
  begin
       predicted := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col-2,i])) *
                    StdDevs[NoVars-1] + Means[NoVars-1];
       OS3MainFrm.DataGrid.Cells[col,i] := format('%8.3f',[predicted]);
  end;
  { Calculate residuals of predicted raw scores }
  col := NoVariables +1;
  DictionaryFrm.NewVar(col);
  DictionaryFrm.DictGrid.Cells[1,col] := 'Raw Resid.';
  OS3MainFrm.DataGrid.Cells[col,0] := 'Raw Resid.';
  for i := 1 to NoCases do
  begin
       Index := ColNoSelected[NoVars-1];
       resid := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col-1,i])) -
                   StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[Index,i]));
       OS3MainFrm.DataGrid.Cells[col,i] := Format('%8.3f',[resid]);
  end;
  { Calculate Confidence Interval for raw predicted score }
  col := NoVariables + 1;
  DictionaryFrm.NewVar(col);
  DictionaryFrm.DictGrid.Cells[1,col] := 'StdErrPred';
  OS3MainFrm.DataGrid.Cells[col,0] := 'StdErrPred';
  col := NoVariables + 1;
  DictionaryFrm.NewVar(col);
  DictionaryFrm.DictGrid.Cells[1,col] := 'Low 95%';
  OS3MainFrm.DataGrid.Cells[col,0] := 'Low 95%';
  col := NoVariables + 1;
  DictionaryFrm.NewVar(col);
  DictionaryFrm.DictGrid.Cells[1,col] := 'Top 95%';
  OS3MainFrm.DataGrid.Cells[col,0] := 'Top 95%';
  for i := 1 to NoCases do
  begin
       { get term1 of the std. err. prediction }
       Term1 := 0.0;
       for j := 1 to NoIndepVars do
       begin
            Index := IndepIndex[j-1];
            col := ColNoSelected[Index-1];
            z1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
            z1 := (z1 - Means[Index-1]) / StdDevs[Index-1];
            z1 := (z1 * z1) * IndepInverse[j-1,j-1];
            Term1 := Term1 + z1;
       end;
       { get term2 of the std err. of prediction }
       term2 := 0.0;
       for j := 1 to NoIndepVars - 1 do
       begin
            for k := j + 1 to NoIndepVars do
            begin
                 IndexX := IndepIndex[j-1];
                 col := ColNoSelected[IndexX-1];
                 z1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
                 IndexY := IndepIndex[k-1];
                 col := ColNoSelected[IndexY-1];
                 z2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
                 z1 := (z1 - Means[IndexX-1]) / StdDevs[IndexX-1];
                 z2 := (z2 - Means[IndexY-1]) / StdDevs[IndexY-1];
                 Term2 := Term2 + IndepInverse[j-1,k-1] * z1 * z2;
            end;
       end;
       term2 := 2.0 * Term2;
       StdErrPredict := sqrt(NoCases + 1 + Term1 + Term2);
       StdErrPredict := (StdErrEst / sqrt(NoCases)) * StdErrPredict;
       t95 := Inverset(0.975,NoCases-NoIndepVars-1);
       low95 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[NoVars+4,i]));
       hi95 := low95;
       low95 := low95 - (t95 * StdErrPredict);
       hi95 := hi95 + (t95 * StdErrPredict);
       OS3MainFrm.DataGrid.Cells[NoVariables,i] := Format('%8.3f',[hi95]);
       OS3MainFrm.DataGrid.Cells[NoVariables-1,i] := Format('%8.3f',[low95]);
       OS3MainFrm.DataGrid.Cells[NoVariables-2,i] := Format('%8.3f',[StdErrPredict]);
  end; { next case }
end;
//---------------------------------------------------------------------------

procedure MReg2(NCases : integer;
               NoVars : integer;
               VAR NoIndepVars : integer;
               VAR IndepIndex : IntDyneVec;
               VAR corrs : DblDyneMat;
               VAR IndepCorrs : DblDyneMat;
               VAR RowLabels : StrDyneVec;
               out R2: double;
               VAR BetaWeights : DblDyneVec;
               VAR Means : DblDyneVec;
               VAR Variances : DblDyneVec;
               out errorcode : integer;
               out StdErrEst: double;
               out constant: double;
               probout : double;
               Printit : boolean;
               TestOut : boolean;
               PrintInv : boolean;
               AReport: TStrings);
{
  The following routine obtains multiple regression results for a
  correlation matrix consisting of 1 to NoVars.  The last variable
  represents the dependent variable.  The number of independent
  variables is passed as NoIndepVars.  The inverse matrix of independent
  variables may be obtained by the calling program using the variable
  IndepCorrs.  The user may request printing of the inverse using the
  boolean variable Printit.
}
var
   i, j, k, l     : integer;
   IndexX, IndexY : integer;
   IndRowLabels   : StrDyneVec;
   IndColLabels   : StrDyneVec;
   XYCorrs        : DblDyneVec;
   df1, df2, df3  : double;
   SSt, SSres, SSreg : double;
   VarEst, F      : double;
   FprobF         : double;
   outline        : string;
   valstring      : string;
   title          : string;
   deplabel       : string;
   sum, B, Beta   : double;
   SSx, StdErrB   : double;
   AdjR2          : double;
   VIF, TOL       : double;
   outcount       : integer;
   varsout        : IntDyneVec;
begin
  Assert(AReport <> nil);

  SetLength(IndRowLabels,NoVars);
  SetLength(IndColLabels,NoVars);
  SetLength(XYCorrs,NoVars);
  SetLength(varsout,NoVars);

  errorcode := 0;
  outcount := 0;
  VIF := 0.0;
  deplabel := RowLabels[NoVars-1];
  for i := 0 to NoIndepVars-1 do
  begin
    IndexX := IndepIndex[i];
    for j := 0 to NoIndepVars-1 do
    begin
      IndexY := IndepIndex[j];
      IndepCorrs[i,j] := corrs[IndexX-1,IndexY-1];
    end;
  end;
  for i := 0 to NoIndepVars-1 do
  begin
    IndRowLabels[i] := RowLabels[IndepIndex[i]-1];
    IndColLabels[i] := RowLabels[IndepIndex[i]-1];
    XYCorrs[i] := corrs[IndepIndex[i]-1,NoVars-1];
  end;
  SVDinverse(IndepCorrs, NoIndepVars);

  if PrintInv then
  begin
    title := 'Inverse of independent variables matrix';
    MatPrint(IndepCorrs, NoIndepVars, NoIndepVars, title, IndRowLabels, IndColLabels, NCases, AReport);
  end;

  { Get product of inverse matrix times vector of correlations
    between independent and dependent variables }
  R2 := 0.0;
  for i := 0 to NoIndepVars-1 do
  begin
    BetaWeights[i] := 0.0;
    for j := 0 to NoIndepVars-1 do
      BetaWeights[i] := BetaWeights[i] + IndepCorrs[i,j] * XYCorrs[j];
    R2 := R2 + BetaWeights[i] * XYCorrs[i];
  end;

  df1 := NoIndepVars;
  df2 := NCases - NoIndepVars - 1;
  df3 := NCases - 1;
  SSt := (NCases-1) * Variances[NoVars-1];
  SSres := SSt * (1.0 - R2);
  SSreg := SSt - SSres;
  VarEst := SSres / df2;
  if (VarEst > 0.0) then
    StdErrEst := sqrt(VarEst)
  else
  begin
    MessageDlg('Error in computing variance estimate.', mtError, [mbOK], 0);
    StdErrEst := 0.0;
  end;

  if (R2 < 1.0) and (df2 > 0.0) and (df1 > 0.0) then
    F := (R2 / df1) / ((1.0-R2)/ df2)
  else
    F := 0.0;
  FProbF := probf(F,df1,df2);

  AReport.Add('SOURCE      DF        SS             MS             F        Prob. > F');
  AReport.Add('---------- ---- -------------- -------------- -------------- ---------');
  AReport.Add('Regression %4.0f %14.3f %14.3f %14.3f %9.3f', [df1, SSreg, SSreg/df1, F, FprobF]);
  AReport.Add('Residual   %4.0f %14.3f %14.3f', [df2, SSres, SSres/df2]);
  AReport.Add('Total      %4.0f %14.3f', [df3, SSt]);
  AReport.Add('');

  AdjR2 := 1.0 - (1.0 - R2) * (NCases - 1) / df2;
  if PrintIt then
  begin
    AReport.Add('Dependent Variable: ' + deplabel);
    AReport.Add('');
    AReport.Add('%8s %10s %10s %10s %5s %5s', ['R', 'R2', 'F', 'Prob.>F', 'DF1', 'DF2']);
    AReport.Add('-------- ---------- ---------- ---------- ----- -----');
    AReport.Add('%8.3f %10.3f %10.3f %10.3f %5.0f %5.0f',  [sqrt(R2), R2, F, FProbF, df1, df2]);
    AReport.Add('Adjusted R Squared:     %10.3f', [AdjR2]);
    AReport.Add('');
    AReport.Add('Std. Error of Estimate: %10.3f', [StdErrEst]);
    AReport.Add('');
    AReport.Add('Variable      Beta        B      Std.Error      t      Prob. > t     VIF        TOL');
    Areport.Add('---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------');
  end;

  df1 := 1.0;
  df2 := NCases - NoIndepVars - 1;
  sum := 0.0;
  for i := 0 to NoIndepVars-1 do
  begin
    beta := BetaWeights[i];
    B := beta * sqrt(Variances[NoVars-1]) / sqrt(Variances[IndepIndex[i]-1]);
    sum  := sum + B * Means[IndepIndex[i]-1];
    SSx := (NCases-1) * Variances[IndepIndex[i]-1];
    if (IndepCorrs[i,i] > 0.0) and (VarEst > 0.0) then
    begin
      StdErrB := sqrt(VarEst / (SSx * (1.0 / IndepCorrs[i,i])));
      F := B / StdErrB;
      FProbF := probf(F*F,df1,df2);
      VIF := IndepCorrs[i,i];
      TOL := 1.0 / VIF;
    end
    else
    begin
      MessageDlg('Error in estimating std.err. of a B', mtError, [mbOK], 0);
      StdErrB := 0.0;
      F := 0.0;
      FProbF := 0.0;
    end;

    if PrintIt then
    begin
      valstring := Format('%10s', [IndRowLabels[i]]);
      outline := Format('%10s %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.3f',
        [valstring, beta ,B, StdErrB, F, FProbF, VIF, TOL]);
      if FprobF > ProbOut then
        outline := outline + ' Exceeds limit - to be removed.';
      AReport.Add(outline);
    end;

    if FprobF > ProbOut then
    begin
      outcount := outcount + 1;
      varsout[outcount-1] := IndepIndex[i];
    end;
  end;

  if PrintIt then
    AReport.Add('');

  { Get constant }
  constant := Means[NoVars-1] - sum;
  if PrintIt then
    AReport.Add('Constant:  %10.3f', [constant]);

  { Now remove any variables that exceed tolerance }
  if (outcount > 0) and (TestOut = true) then
  begin
    for i := 0 to outcount-1 do
    begin
      k := varsout[i]; { variable to eliminate }
      for j := 0 to NoIndepVars-1 do
      begin
        if IndepIndex[j] = k then {eliminate this one }
        begin
          for l := j to NoIndepVars-2 do
            IndepIndex[l] := IndepIndex[l+1];
        end;
      end;
    end;
    NoIndepVars := NoIndepVars - outcount;
    errorcode := outcount;
  end;

  varsout := nil;
  XYCorrs := nil;
  IndColLabels := nil;
  IndRowLabels := nil;
end;
//---------------------------------------------------------------------------

procedure MatSub(const a, b, c: DblDyneMat;
  brows, bcols, crows, ccols: integer; out errorcode: boolean);
// Subtracts matrix c from b and returns the results in matrix a
var
  i, j: integer;
begin
  errorcode := false;
  if (brows <> crows) or (bcols <> ccols) then
    errorcode := true
  else
  begin
    for i := 0 to brows-1 do
      for j := 0 to bcols-1 do
        a[i,j] := b[i,j] - c[i,j];
  end;
end;  { of matsub }

procedure IntArrayPrint(const Mat: IntDyneMat; Rows, Cols: integer;
  const YTitle: string; const RowLabels, ColLabels: StrDyneVec;
  const Title: string; AReport: TStrings);
var
  i, j, first, last, nflds: integer;
  done : boolean;
  outline: string;
begin
  AReport.Add('');
  AReport.Add(Title);
  AReport.Add('');
  nflds := 4;
  done := FALSE;
  first := 1;

  while not done do
  begin
    AReport.Add('                        ' + ytitle);;
    AReport.Add('Variables');

    outline := DupeString(' ', 12+1);
    last := first + nflds;
    if last >= cols then
    begin
      done := TRUE;
      last := cols
    end;
    for i := first to last do
      outline := outline + Format('%12s ', [ColLabels[i-1]]);
    AReport.Add(outline);

    for i := 1 to rows do
    begin
      outline := Format('%12s ', [RowLabels[i-1]]);
      for j := first to last do
        outline := outline + Format('%12d ',[mat[i-1,j-1]]);
      AReport.Add(outline);
    end;
    AReport.Add('');
    first := last + 1;
  end;
  AReport.Add('');
end;
//---------------------------------------------------------------------------

procedure eigens(VAR a: DblDyneMat; Var d : DblDyneVec; n : integer);

var e : DblDyneVec;
    i : integer;

begin
     SetLength(e,n);
     for i := 1 to n do
     begin
          d[i-1] := 0.0;
          e[i-1] := 0.0;
     end;

     tred2(a, n, d ,e ); { Upon return, d contains diagonal values, e contains
                           off diagonal values, and a contains the orthogonal
                           matrix from the tridiagonalization of the a matrix }

     tqli(d, e, n, a);  { Upon return, d contains eigenvalues, a the column
                          eigenvectors of the tridiagonal matrix (in d and e). }
     e := nil;
end; { Procedure eigens }
//-------------------------------------------------------------------

PROCEDURE tred2(VAR a: DblDyneMat; n: integer; VAR d,e: DblDyneVec);
(* Programs using routine TRED2 must define the types
TYPE
   glnp = ARRAY [1..np] OF real;
   glnpnp = ARRAY [1..np,1..np] OF real;
where 'np by np' is the physical dimension of the matrix to be analyzed. *)

VAR
   l,k,j,i: integer;
   scale,hh,h,g,f: double;
BEGIN
   IF (n > 1) THEN BEGIN
      FOR i := n DOWNTO 2 DO BEGIN
         l := i-1;
         h := 0.0;
         scale := 0.0;
         IF (l > 1) THEN BEGIN
            FOR k := 1 to l DO BEGIN
               scale := scale+abs(a[i-1,k-1])
            END;
            IF (scale = 0.0) THEN BEGIN
               e[i-1] := a[i-1,l-1]
            END ELSE BEGIN
               FOR k := 1 to l DO BEGIN
                  a[i-1,k-1] := a[i-1,k-1]/scale;
                  h := h+sqr(a[i-1,k-1])
               END;
               f := a[i-1,l-1];
               g := -sign(sqrt(h),f);
               e[i-1] := scale*g;
               h := h-f*g;
               a[i-1,l-1] := f-g;
               f := 0.0;
               FOR j := 1 to l DO BEGIN
            (* Next statement can be omitted if eigenvectors not wanted *)
                  a[j-1,i-1] := a[i-1,j-1]/h;
                  g := 0.0;
                  FOR k := 1 to j DO BEGIN
                     g := g+a[j-1,k-1]*a[i-1,k-1]
                  END;
                  IF (l > j) THEN FOR k := j+1 to l DO g := g+a[k-1,j-1]*a[i-1,k-1];
                  e[j-1] := g/h;
                  f := f+e[j-1]*a[i-1,j-1]
               END;
               hh := f/(h+h);
               FOR j := 1 to l DO BEGIN
                  f := a[i-1,j-1];
                  g := e[j-1]-hh*f;
                  e[j-1] := g;
                  FOR k := 1 to j DO a[j-1,k-1] := a[j-1,k-1]-f*e[k-1]-g*a[i-1,k-1]
               END
            END
         END ELSE BEGIN
            e[i-1] := a[i-1,l-1]
         END;
         d[i-1] := h
      END
   END;
   (* Next statement can be omitted if eigenvectors not wanted *)
   d[0] := 0.0;
   e[0] := 0.0;
   FOR i := 1 to n DO BEGIN
   (* Contents of this loop can be omitted if eigenvectors not wanted,
      except for statement d[i] := a[i,i]; *)
      l := i-1;
      IF (d[i-1] <> 0.0) THEN BEGIN
         FOR j := 1 to l DO BEGIN
            g := 0.0;
            FOR k := 1 to l DO BEGIN
               g := g+a[i-1,k-1]*a[k-1,j-1]
            END;
            FOR k := 1 to l DO BEGIN
               a[k-1,j-1] := a[k-1,j-1]-g*a[k-1,i-1]
            END
         END
      END;
      d[i-1] := a[i-1,i-1];
      a[i-1,i-1] := 1.0;
      IF (l >= 1) THEN BEGIN
         FOR j := 1 to l DO BEGIN
            a[i-1,j-1] := 0.0;
            a[j-1,i-1] := 0.0
         END
      END
   END
END;
//-------------------------------------------------------------------

PROCEDURE tqli(VAR d,e: DblDyneVec; n: integer; VAR z: DblDyneMat);
LABEL 1,2;
VAR
   m,l,iter,i,k: integer;
   s,r,p,g,f,dd,c,b: double;
BEGIN
   IF  (n > 1)  THEN BEGIN
      FOR i := 2 to n DO BEGIN
         e[i-2] := e[i-1]
      END;
      e[n-1] := 0.0;
      FOR l := 1 to n DO BEGIN
         iter := 0;
1:         FOR m := l to n-1 DO BEGIN
            dd := abs(d[m-1])+abs(d[m]);
            IF  (abs(e[m-1])+ dd = dd) THEN  GOTO 2
         END;
         m := n;
2:         IF (m <> l) THEN BEGIN
            IF (iter = 30) THEN BEGIN
               ShowMessage('Too many iterations in routine tqli');
               exit;
            END;
            iter := iter+1;
            g := (d[l]-d[l-1])/(2.0*e[l-1]);
            r := sqrt(sqr(g)+1.0);
            g := d[m-1] - d[l-1] + e[l-1] / (g+sign(r,g));
            s := 1.0;
            c := 1.0;
            p := 0.0;
            FOR i := m-1 DOWNTO l DO BEGIN
               f := s * e[i-1];
               b := c * e[i-1];
               IF (abs(f) >= abs(g)) THEN BEGIN
                  c := g / f;
                  r := sqrt(sqr(c) + 1.0);
                  e[i] := f * r;
                  s := 1.0 / r;
                  c := c * s
               END ELSE BEGIN
                  s := f / g;
                  r := sqrt(sqr(s) + 1.0);
                  e[i] := g * r;
                  c := 1.0 / r;
                  s := s * c
               END;
               g := d[i] - p;
               r := (d[i-1] - g) * s + 2.0 * c * b;
               p := s * r;
               d[i] := g + p;
               g := c * r - b;
            (* Next loop can be omitted if eigenvectors not wanted *)
               FOR k := 1 to n DO BEGIN
                  f := z[k-1,i];
                  z[k-1,i] := s * z[k-1,i-1] + c * f;
                  z[k-1,i-1] := c * z[k-1,i-1] - s * f
               END
            END;
            d[l-1] := d[l-1] - p;
            e[l-1] := g;
            e[m-1] := 0.0;
            GOTO 1
         END
      END
   END
END;
//-------------------------------------------------------------------

function SEVS(nv,nf : integer;
               c : double;
               var r : DblDyneMat;
               VAR v : DblDyneMat;
               VAR e : DblDyneVec;
               var p : DblDyneVec;
               VAR nd : integer) : integer ;

{ extracts roots and denormal vectors from a symetric matrix. Veldman, 1967,
  page 209 }

label 1,2;

var t, ee, ev : double;
    i, j, k, m : integer;

begin
     t := 0.0;
     for i := 1 to nv do t := t + r[i-1,i-1];
     for k := 1 to nf do { compute roots in e[k] and vector in v^[.k] }
     begin
          for i := 1 to nv do p[i-1] := 1.0;
          begin
             e[k-1] := 1.0;
             for m := 1 to 25 do
             begin
               for i := 1 to nv do  v[i-1,k-1] := p[i-1] / e[k-1];
               for i := 1 to nv do p[i-1] := SCPF(r,v,-i,k,nv,nd);
               ee := 0.0;
               for j := 1 to nv do ee := ee + p[j-1] * v[j-1,k-1];
               e[k-1] := sqrt(abs(ee));
             end;
          end;
          if ee < (c * c) then goto 1;
               for i := 1 to nv do
                   for j := 1 to nv do
                       r[i-1,j-1] := r[i-1,j-1] - (v[i-1,k-1] * v[j-1,k-1]);
     end;
     goto 2;
1 :  nf := k - 1;
2 :  for i := 1 to nf do p[i-1] := e[i-1] / t * 100.0;
     ev := 0.0;
     for i := 1 to nf do ev := ev + p[i-1];
{
     stopit;
     writeln(lst);
     writeln(lst,'Root  % Extracted');
     for i := 1 to nf do writeln(lst,i:3,'   ',p^[i]:6:3);
     writeln(lst,' Trace = ',t:6:3,'  % Extracted = ',ev:6:3);
     writeln(lst);
}
     result := nf;
end; { of SEVS procedure }
//-------------------------------------------------------------------

function SCPF(VAR x,y : DblDyneMat; kx,ky,n,nd : integer) : double;

{ sum of cross products of two vectors. Veldman, 1967, pp 128-129 }
var j,k,i : integer;
    scp : double;

begin
     scp := 0.0;
     scpf := 0.0;
     j := abs(kx);
     k := abs(ky);
     if ((kx = 0) and (ky = 0)) then exit;
     if ((kx < 0) and (ky < 0)) then
     begin
          for i := 1 to n do scp := scp + x[j-1,i-1] * y[k-1,i-1];
     end;
     if ((kx < 0) and (ky > 0)) then
     begin
          for i := 1 to n do scp := scp + x[j-1,i-1] * y[i-1,k-1];
     end;
     if ((kx > 0) and (ky < 0)) then
     begin
          for i := 1 to n do scp := scp + x[i-1,j-1] * y[k-1,i-1];
     end;
     if ((kx > 0) and (ky > 0)) then
     begin
          for i := 1 to n do scp := scp + x[i-1,j-1] * y[i-1,k-1];
     end;
     scpf := scp;
end; { of SCPF }

procedure MatPrint(const xmat: DblDyneMat; Rows, Cols: integer; const Title: string;
  const RowLabels, ColLabels: StrDyneVec; NCases: integer; AReport: TStrings);
var
  i, j, first, last, nflds: integer;
  done: boolean;
  outline: string;
  valstring: string;
begin
  Assert(AReport <> nil);

  AReport.Add('%s with %d cases.', [Title, NCases]);
  AReport.Add('');
  nflds := 4;
  done := FALSE;
  first := 1;
  while not done do
  begin
    AReport.Add('Variables');
    outline := DupeString(' ', 12+1); //'             ';
    last := first + nflds;
    if last >= cols then
    begin
      done := true;
      last := cols;
    end;
    for i := first to last do
      outline := outline + Format('%12s ',[ColLabels[i-1]]);
    AReport.Add(outline);

    for i := 1 to rows do
    begin
      outline := format('%12s ',[RowLabels[i-1]]);
      for j := first to last do
      begin
        valstring := format('%12.3f ',[xmat[i-1,j-1]]);
        outline := outline + valstring;
      end;
      AReport.Add(outline);
    end;
    if not done then AReport.Add('');
    first := last + 1;
  end;
  AReport.Add('');
end;

procedure DynVectorPrint(const AVector: DblDyneVec; NoVars: integer;
  Title: string; const Labels: StrDyneVec; NCases: integer; AReport: TStrings);
var
  i, j, first, last, nflds: integer;
  done: boolean;
  outline: string;
  valstring: string;
begin
  Assert(AReport <> nil);

//  AReport.Add('');
  AReport.Add('%s with %d valid cases.', [Title, NCases]);

  nflds := 4;
  done := FALSE;
  first := 0;
  while not done do
  begin
    AReport.Add('');
    last := first + nflds;
    if last >= NoVars -1 then
    begin
      done := true;
      last := NoVars-1;
    end;

    outline := 'Variables    ';     // 12+1 long
    for i := first to last do
      outline := outline + Format('%12s ', [Labels[i]]);
    AReport.Add(outline);

    outline := DupeString(' ', 12+1); //'          ';
    for j := first to last do
    begin
      valstring := Format('%12.3f ', [AVector[j]]);
      outline := outline + valstring;
    end;
    AReport.Add(outline);
    first := last + 1
  end;
  AReport.Add('');
end;
//--------------------------------------------------------------------------

procedure ScatPlot(const x, y: DblDyneVec; NoCases: integer;
  const TitleStr, x_axis, y_axis: string; x_min, x_max, y_min, y_max: double;
  const VarLabels: StrDyneVec; AReport: TStrings);
var
  i, j, l, row, xslot : integer;
  maxy: double;
  incrementx, incrementy, rangex, rangey: double;
  plotstring  : array[0..51,0..61] of char;
  height      : integer;
  overlap     : boolean;
  valuestring : string[2];
  howlong     : integer;
  outline     : string;
  Labels      : StrDyneVec;
begin
  SetLength(Labels,NoVariables);
  for i := 1 to nocases do Labels[i-1] := VarLabels[i-1];
  height := 40;
  rangex := x_max - x_min ;
  incrementx := rangex / 15.0;
//  xdelta := rangex / 60;
//  xmed := rangex / 2;
  rangey := y_max - y_min;
  incrementy := rangey / height;
//  ymed := rangey / 2;

  { sort in descending order }
  for i := 1 to (NoCases - 1) do
  begin
      for j := (i + 1) to NoCases do
      begin
           if y[i-1] < y[j-1] then
           begin
             Exchange(y[i-1], y[j-1]);
             {
                swap := y[i-1];
                y[i-1] := y[j-1];
                y[j-1] := swap;
             }
             Exchange(x[i-1], x[j-1]);
             {
                swap := x[i-1];
                x[i-1] := x[j-1];
                x[j-1] := swap;
             }
             Exchange(Labels[i-1], Labels[j-1]);
             {
                outline := Labels[i-1];
                Labels[i-1] := Labels[j-1];
                Labels[j-1] := outline;
             }
           end;
      end;
  end;

  AReport.Add('             SCATTERPLOT - ' + TitleStr);
  AReport.Add('');
  AReport.Add(y_axis);
  maxy := y_max;
  for i := 1 to 60 do
      for j := 1 to height+1 do plotstring[j,i] := ' ';

  { Set up the plot strings with the data }
  row := 0;
  while maxy >  y_min  do
  begin
      row := row + 1;
      plotstring[row,30] := '|';
      if (row = (height / 2)) then
           for i := 1 to 60 do plotstring[row,i] := '-';
      for i := 1 to nocases do
      begin
           if ((maxy >= y[i-1]) and (y[i-1] > (maxy - incrementy))) then
           begin
                xslot := round(((x[i-1] - x_min) / rangex) * 60);
                if xslot < 1 then xslot := 1;
                if xslot > 60 then xslot := 60;
                overlap := false;
                str(i:2,valuestring);
                howlong := 1;
                if (valuestring[1] <> ' ') then howlong := 2;
                for l := xslot to (xslot + howlong - 1) do
                  if (plotstring[row,l] = '*') then overlap := true;
                if (overlap) then plotstring[row,xslot] := '*'
                else
                begin
                  if (howlong < 2) then
                    plotstring[row,xslot] := valuestring[2]
                  else for l := 1 to 2 do
                    plotstring[row,xslot + l - 1] := valuestring[l];
                end;
           end;
      end;
      maxy := maxy - incrementy;
  end;

  { print the plot }
  for i := 1 to row do
  begin
      outline := ' |';
      for j := 1 to 60 do outline := outline + Format('%1s', [plotstring[i,j]]);
      outline := outline + Format('|-%6.2f-%6.2f',
          [(y_max - i * incrementy),(y_max - i * incrementy + incrementy)]);
      AReport.Add(outline);
  end;

  outline := '';
  for i := 1 to 63 do outline := outline + '-';
  AReport.Add(outline);

  outline := '';
  for i := 1 to 16 do outline := outline + '  | ';
  outline := outline + x_axis;
  AReport.Add(outline);

  outline := '';
  for i := 1 to 16 do outline := outline + Format('%4.1f', [(x_min + i * incrementx - incrementx)]);
  AReport.Add(outline);
  AReport.Add('');
  AReport.Add('Labels:');
  for i := 1 to nocases do
    AReport.Add('%2d = %s', [i, Labels[i-1]]);

  Labels := nil;
end; { of scatplot procedure }

procedure DynIntMatPrint(Mat: IntDyneMat; Rows, Cols: integer; YTitle: string;
  RowLabels, ColLabels: StrDyneVec; Title: string; AReport: TStrings);
var
   i, j, first, last, nflds: integer;
   done: boolean;
   outline: string;
   valstring: string;
begin
  Assert(AReport <> nil);

  AReport.Add(Title);
  AReport.Add('');

  nflds := 4;
  done := false;
  first := 0;
  while not done do
  begin
    AReport.Add('');
    AReport.Add('                        ' + ytitle);
    AReport.Add('Variables');
    outline := '         ';
    last := first + nflds;
    if last >= Cols-1 then
    begin
      done := true;
      last := Cols-1;
    end;
    for i := first to last do
      outline := outline + Format('%13s', [ColLabels[i]]);
    AReport.Add(outline);

    for i := 0 to rows-1 do
    begin
      outline := Format('%10s', [RowLabels[i]]);
      for j := first to last do
      begin
        valstring := Format('%12d ', [Mat[i,j]]);
        outline := outline + valstring;
      end;
      AReport.Add(outline);
    end;
    AReport.Add('');
    first := last + 1
  end;
  AReport.Add('');
  AReport.Add('');
end;

procedure SymMatRoots(A: DblDyneMat; M: integer; var E: DblDyneVec;
var V: DblDyneMat);
Label one, three, nine, fifteen;
var
   L, IT, j, k : integer;
   Test, sum1, sum2 : double;
   X, Y, Z : DblDyneVec;

begin
//  Adapted from: "Multivariate Data Analysis" by William W. Cooley and Paul
//  R. Lohnes, 1971, page 121
     SetLength(X, M);
     SetLength(Y, M);
     SetLength(Z, M);
     sum2 := 0.0;
     L := 0;
     Test := 0.00000001;
one:
     IT := 0;
     for j := 0 to M-1 do Y[j] := 1.0;
three:
     IT := IT + 1;
     for j := 0 to M-1 do
     begin
          X[j] := 0.0;
          for k := 0 to M-1 do X[j] := X[j] + (A[j,k] * Y[k]);
     end;
     E[L] := X[0];
     Sum1 := 0.0;
     for j := 0 to M-1 do
     begin
          V[j,L] := X[j] / X[0];
          Sum1 := Sum1 + abs(Y[j] - V[j,L]);
          Y[j] := V[j,L];
     end;
     if (IT - 10) <> 0 then goto nine;
     if (Sum2 - Sum1) > 0 then goto nine
     else
     begin
          showmessage('Root not converging. Exiting.');
          exit;
     end;
nine:
     Sum2 := Sum1;
     if (Sum1 - Test) > 0 then goto three;
     Sum1 := 0.0;
     for j := 0 to M-1 do Sum1 := Sum1 + (V[j,L] * V[j,L]);
     Sum1 := sqrt(Sum1);
     for j := 0 to M-1 do V[j,L] := V[j,L] / Sum1;
     for j := 0 to M-1 do
         for k := 0 to M-1 do
             A[j,k] := A[j,k] - (V[j,L] * V[k,L] * E[L]);
     if ((M-1)-L) <= 0 then goto fifteen;
     L := L + 1;
     goto one;
fifteen:
     Z := nil;
     Y := nil;
     X := nil;
end;

procedure matinv(a, vtimesw, v, w: DblDyneMat; n: integer);
LABEL 1,2,3;

VAR
   ainverse : array of array of double;
   m,mp,np,nm,l,k,j,its,i: integer;
   z,y,x,scale,s,h,g,f,c,anorm: double;
   rv1: array of double;

begin
   setlength(rv1,n);
   setlength(ainverse,n,n);
   m := n;
   mp := n;
   np := n;
   g := 0.0;
   scale := 0.0;
   anorm := 0.0;
   FOR i := 0 to n-1 DO BEGIN
      l := i+1;
      rv1[i] := scale*g;
      g := 0.0;
      s := 0.0;
      scale := 0.0;
      IF (i <= m-1) THEN BEGIN
         FOR k := i to m-1 DO BEGIN
            scale := scale+abs(a[k,i])
         END;
         IF (scale <> 0.0) THEN BEGIN
            FOR k := i to m-1 DO BEGIN
               a[k,i] := a[k,i]/scale;
               s := s+a[k,i]*a[k,i]
            END;
            f := a[i,i];
            g := -sign(sqrt(s),f);
            h := f*g-s;
            a[i,i] := f-g;
            IF (i <> n-1) THEN BEGIN
               FOR j := l to n-1 DO BEGIN
                  s := 0.0;
                  FOR k := i to m-1 DO BEGIN
                     s := s+a[k,i]*a[k,j]
                  END;
                  f := s/h;
                  FOR k := i to m-1 DO BEGIN
                     a[k,j] := a[k,j]+
                        f*a[k,i]
                  END
               END
            END;
            FOR k := i to m-1 DO BEGIN
               a[k,i] := scale*a[k,i]
            END
         END
      END;
      w[i,i] := scale*g;
      g := 0.0;
      s := 0.0;
      scale := 0.0;
      IF ((i <= m-1) AND (i <> n-1)) THEN BEGIN
         FOR k := l to n-1 DO BEGIN
            scale := scale+abs(a[i,k])
         END;
         IF (scale <> 0.0) THEN BEGIN
            FOR k := l to n-1 DO BEGIN
               a[i,k] := a[i,k]/scale;
               s := s+a[i,k]*a[i,k]
            END;
            f := a[i,l];
            g := -sign(sqrt(s),f);
            h := f*g-s;
            a[i,l] := f-g;
            FOR k := l to n-1 DO BEGIN
               rv1[k] := a[i,k]/h
            END;
            IF (i <> m-1) THEN BEGIN
               FOR j := l to m-1 DO BEGIN
                  s := 0.0;
                  FOR k := l to n-1 DO BEGIN
                     s := s+a[j,k]*a[i,k]
                  END;
                  FOR k := l to n-1 DO BEGIN
                     a[j,k] := a[j,k]
                        +s*rv1[k]
                  END
               END
            END;
            FOR k := l to n-1 DO BEGIN
               a[i,k] := scale*a[i,k]
            END
         END
      END;
      anorm := max(anorm,(abs(w[i,i])+abs(rv1[i])))
   END;
   FOR i := n-1 DOWNTO 0 DO BEGIN
      IF (i < n-1) THEN BEGIN
         IF (g <> 0.0) THEN BEGIN
            FOR j := l to n-1 DO BEGIN
               v[j,i] := (a[i,j]/a[i,l])/g
            END;
            FOR j := l to n-1 DO BEGIN
               s := 0.0;
               FOR k := l to n-1 DO BEGIN
                  s := s+a[i,k]*v[k,j]
               END;
               FOR k := l to n-1 DO BEGIN
                  v[k,j] := v[k,j]+s*v[k,i]
               END
            END
         END;
         FOR j := l to n-1 DO BEGIN
            v[i,j] := 0.0;
            v[j,i] := 0.0
         END
      END;
      v[i,i] := 1.0;
      g := rv1[i];
      l := i
   END;
   FOR i := n-1 DOWNTO 0 DO BEGIN
      l := i+1;
      g := w[i,i];
      IF (i < n-1) THEN BEGIN
         FOR j := l to n-1 DO BEGIN
            a[i,j] := 0.0
         END
      END;
      IF (g <> 0.0) THEN BEGIN
         g := 1.0/g;
         IF (i <> n-1) THEN BEGIN
            FOR j := l to n-1 DO BEGIN
               s := 0.0;
               FOR k := l to m-1 DO BEGIN
                  s := s+a[k,i]*a[k,j]
               END;
               f := (s/a[i,i])*g;
               FOR k := i to m-1 DO BEGIN
                  a[k,j] := a[k,j]+f*a[k,i]
               END
            END
         END;
         FOR j := i to m-1 DO BEGIN
            a[j,i] := a[j,i]*g
         END
      END ELSE BEGIN
         FOR j := i to m-1 DO BEGIN
            a[j,i] := 0.0
         END
      END;
      a[i,i] := a[i,i]+1.0
   END;
   FOR k := n-1 DOWNTO 0 DO BEGIN
      FOR its := 1 to 30 DO BEGIN
         FOR l := k DOWNTO 0 DO BEGIN
            nm := l-1;
            IF ((abs(rv1[l])+anorm) = anorm) THEN GOTO 2;
            IF ((abs(w[nm,nm])+anorm) = anorm) THEN GOTO 1
         END;
1:       c := 0.0;
         s := 1.0;
         FOR i := l to k DO BEGIN
            f := s*rv1[i];
            IF ((abs(f)+anorm) <> anorm) THEN BEGIN
               g := w[i,i];
               h := sqrt(f*f+g*g);
               w[i,i] := h;
               h := 1.0/h;
               c := (g*h);
               s := -(f*h);
               FOR j := 0 to m-1 DO BEGIN
                  y := a[j,nm];
                  z := a[j,i];
                  a[j,nm] := (y*c)+(z*s);
                  a[j,i] := -(y*s)+(z*c)
               END
            END
         END;
2:         z := w[k,k];
         IF (l = k) THEN BEGIN
            IF (z < 0.0) THEN BEGIN
               w[k,k] := -z;
               FOR j := 0 to n-1 DO BEGIN
               v[j,k] := -v[j,k]
            END
         END;
         GOTO 3
         END;
         IF (its = 30) THEN BEGIN
            showmessage('No convergence in 30 SVDCMP iterations');
            exit;
         END;
         x := w[l,l];
         nm := k-1;
         y := w[nm,nm];
         g := rv1[nm];
         h := rv1[k];
         f := ((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y);
         g := sqrt(f*f+1.0);
         f := ((x-z)*(x+z)+h*((y/(f+sign(g,f)))-h))/x;
         c := 1.0;
         s := 1.0;
         FOR j := l to nm DO BEGIN
            i := j+1;
            g := rv1[i];
            y := w[i,i];
            h := s*g;
            g := c*g;
            z := sqrt(f*f+h*h);
            rv1[j] := z;
            c := f/z;
            s := h/z;
            f := (x*c)+(g*s);
            g := -(x*s)+(g*c);
            h := y*s;
            y := y*c;
            FOR nm := 0 to n-1 DO BEGIN
               x := v[nm,j];
               z := v[nm,i];
               v[nm,j] := (x*c)+(z*s);
               v[nm,i] := -(x*s)+(z*c)
            END;
            z := sqrt(f*f+h*h);
            w[j,j] := z;
            IF (z <> 0.0) THEN BEGIN
               z := 1.0/z;
               c := f*z;
               s := h*z
            END;
            f := (c*g)+(s*y);
            x := -(s*g)+(c*y);
            FOR nm := 0 to m-1 DO BEGIN
               y := a[nm,j];
               z := a[nm,i];
               a[nm,j] := (y*c)+(z*s);
               a[nm,i] := -(y*s)+(z*c)
            END
         END;
         rv1[l] := 0.0;
         rv1[k] := f;
         w[k,k] := x
      END;
3:   END;
{     mat_print(m,a,'U matrix');
     mat_print(n,v,'V matrix');
     writeln(lst,'Diagonal values of W inverse matrix');
      for i := 1 to n do
         write(lst,1/w[i]:6:3);
     writeln(lst);  }
     for i := 0 to n-1 do
         for j := 0 to n-1 do
         begin
              if w[i,i] < 1.0e-6 then vtimesw[i,j] := 0
              else vtimesw[i,j] := v[i,j] * (1.0 / w[j,j] );
         end;
{     mat_print(n,vtimesw,'V matrix times w inverse ');  }
     for i := 0 to m-1 do
         for j := 0 to n-1 do
         begin
             ainverse[i,j] := 0.0;
             for k := 0 to m-1 do
             begin
                  ainverse[i,j] := ainverse[i,j] + vtimesw[i,k] * a[j,k]
             end;
         end;
{     mat_print(n,ainverse,'Inverse Matrix'); }
     for i := 0 to n-1 do
         for j := 0 to n-1 do
             a[i,j] := ainverse[i,j];
     ainverse := nil;
     rv1 := nil;
end;

end.

