unit FunctionsLib;

{$mode objfpc}{$H+}

interface

uses
  Forms, Controls, LResources, ExtCtrls, Classes, SysUtils, Globals,
  Graphics, Dialogs, Math,
  MainUnit, dataprocs;

function chisquaredprob(X : double; k : integer) : double;
function gammln(xx : double) : double;
PROCEDURE matinv(VAR a, vtimesw, v, w: DblDyneMat; n: integer);
FUNCTION sign(a,b: double): double;
FUNCTION isign(a,b : integer): integer;
function inversez(prob : double) : double;
function zprob(p : double; VAR errorstate : boolean) : double;
function probz(z : double) : double;
function simpsonintegral(a,b : real) : real;
function zdensity(z : real) : real;
function probf(f,df1,df2 : extended) : extended;
FUNCTION alnorm(x : double; upper : boolean): double;
procedure ppnd7 (p : double; VAR normal_dev : double; VAR ifault : integer);
function poly(const c: Array of double; nord: integer; x: double): double; // RESULT(fn_val)
procedure swilk (var init : boolean; const x: DblDyneVec; n, n1, n2: integer;
  const a: DblDyneVec; var w, pw: double; out ifault: integer);
procedure SVDinverse(VAR a : DblDyneMat; N : integer);
function probt(t,df1 : double) : double;
function inverset(Probt, DF : double) : double;
function inversechi(p : double; k : integer) : double;
function STUDENT(q,v,r : real) : real;
function realraise(base,power : double ): double;
function fpercentpoint(p : real; k1,k2 : integer) : real;
function lngamma(w : real) : real;
function betaratio(x,a,b,lnbeta : real) : real;
function inversebetaratio(ratio,a,b,lnbeta : real) : real;
function ProdSums(N, A : double) : double;
function combos(X, N : double) : double;
function ordinate(z : double) : double;
procedure Rank(v1col : integer; VAR Values : DblDyneVec);
procedure PRank(v1col : integer; VAR Values : DblDyneVec; AReport: TStrings);
function UniStats(N : integer; VAR X : DblDyneVec; VAR z : DblDyneVec;
                  VAR Mean : double; VAR variance : double; VAR SD : double;
                  VAR Skew : double; VAR Kurtosis : double; VAR SEmean : double;
                  VAR SESkew : double; VAR SEkurtosis : double; VAR min : double;
                  VAR max : double; VAR Range : double; VAR MissValue : string) :
                  integer;
function WholeValue(value : double) : double;
function FractionValue(value : double) : double;
function Quartiles(TypeQ : integer; pcntile : double; N : integer;
         VAR values : DblDyneVec) : double;

function KolmogorovProb(z: double): double;
function KolmogorovTest(na: integer; const a: DblDyneVec; nb: integer;
  const b: DblDyneVec; option: String; AReport: TStrings): double;

procedure poisson_cdf ( x : integer; a : double; VAR cdf : double );
procedure poisson_cdf_values (VAR n : integer; VAR a : double; VAR x : integer;
                              VAR fx : double );
procedure poisson_cdf_inv (VAR cdf : double; VAR a : double; VAR x : integer );
procedure poisson_check ( a : double );
function factorial(x : integer) : integer;
procedure poisson_pdf ( x : integer; VAR a : double; VAR pdf : double );


implementation

function chisquaredprob(X : double; k : integer) : double;
var
   factor : double;   // factor which multiplies sum of series
   g      : double;   // lngamma(k1+1)
   k1     : double;   // adjusted degrees of freedom
   sum    : double;   // temporary storage for partial sums
   term   : double;   // term of series
   x1     : double;   // adjusted argument of funtion
   chi2prob : double; // chi-squared probability
begin
     // the distribution function of the chi-squared distribution based on k d.f.
     if (X < 0.01) or (X > 1000.0) then
     begin
          if X < 0.01 then chi2prob := 0.0001
          else chi2prob := 0.999;
     end
     else
     begin
    	x1 := 0.5 * X;
    	k1 := 0.5 * k;
    	g := gammln(k1 + 1);
    	factor := exp(k1 * ln(x1) - g - x1);
    	sum := 0.0;
    	if factor > 0 then
    	begin
        	term := 1.0;
          	sum := 1.0;
          	while ((term / sum) > 0.000001) do
          	begin
                     k1 := k1 + 1;
                     term  := term * (x1 / k1);
                     sum := sum + term;
                end;
        end;
    	chi2prob := sum * factor;
     end; //end if .. else
     Result := chi2prob;
end;
//---------------------------------------------------------------------

function gammln(xx : double) : double;
var
   X, tmp, ser : double;
   cof : array[0..5] of double;
   j : integer;

begin
    cof[0] := 76.18009173;
    cof[1] := -86.50532033;
    cof[2] := 24.01409822;
    cof[3] := -1.231739516;
    cof[4] := 0.00120858003;
    cof[5] := -0.00000536382;

    X := xx - 1.0;
    tmp := X + 5.5;
    tmp := tmp - ((X + 0.5) * ln(tmp));
    ser := 1.0;
    for j := 0 to 5 do
    begin
        X := X + 1.0;
        ser := ser + cof[j] / X;
    end;
    Result := ( -tmp + ln(2.50662827465 * ser) );
end;
//-------------------------------------------------------------------

PROCEDURE matinv(VAR a, vtimesw, v, w: DblDyneMat; n: integer);
(* adapted from the singular value decomposition of a matrix *)
(* a is a symetric matrix with the inverse returned in a *)

label
  Lbl1, Lbl2, Lbl3;

var
//   vtimesw, v, ainverse : matrix;
//   w : vector;
   ainverse : array of array of double;
   m, nm,l,k,j,its,i: integer;
   z,y,x,scale,s,h,g,f,c,anorm: double;
   rv1: array of double;

BEGIN
   setlength(rv1,n);
   setlength(ainverse,n,n);
   m := n;
//   mp := n;
//   np := n;
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
            IF ((abs(rv1[l])+anorm) = anorm) THEN GOTO Lbl2;
            IF ((abs(w[nm,nm])+anorm) = anorm) THEN GOTO Lbl1
         END;
Lbl1:
//         c := 0.0;
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
Lbl2:    z := w[k,k];
         IF (l = k) THEN BEGIN
            IF (z < 0.0) THEN BEGIN
               w[k,k] := -z;
               FOR j := 0 to n-1 DO BEGIN
               v[j,k] := -v[j,k]
            END
         END;
         GOTO Lbl3
         END;
         IF (its = 30) THEN BEGIN
           { showmessage('No convergence in 30 SVDCMP iterations');}
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
Lbl3:
   END;
{     mat_print(m,a,'U matrix');
     mat_print(n,v,'V matrix');
     writeln(lst,'Diagonal values of W inverse matrix');
      for i := 1 to n do
         write(lst,1/w[i]:6:3);
     writeln(lst);  }
     for i := 0 to n-1 do
         for j := 0 to n-1 do
         begin
              if w[j,j] < 1.0e-6 then vtimesw[i,j] := 0
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
END;
//-------------------------------------------------------------------

FUNCTION sign(a,b: double): double;
BEGIN
      IF (b >= 0.0) THEN sign := abs(a) ELSE sign := -abs(a)
END;
//-------------------------------------------------------------------

FUNCTION isign(a,b : integer): integer;
BEGIN
     IF (b >= 0) then isign := abs(a) ELSE isign := -abs(a)
END;
//-------------------------------------------------------------------

function inversez(prob : double) : double;
var
   z, p : double;
   flag : boolean = false;
begin
	// obtains the inverse of z, that is, the z for a probability associated
        // with a normally distributed z score.
        p := prob;
        if (prob > 0.5) then p := 1.0 - prob;
        z := zprob(p,flag);
        if (prob > 0.5) then z := abs(z);
        inversez := z;
end;    //End of inversez Function
//-------------------------------------------------------------------

function zprob(p : double; VAR errorstate : boolean) : double;
VAR
   z, xp, lim, p0, p1, p2, p3, p4, q0, q1, q2, q3, q4, Y : double;
begin
     // value of probability between approx. 0 and .5 entered in p and the
     // z value is returned  z
     errorstate := true;
     lim := 1E-19;
     p0 := -0.322232431088;
     p1 := -1.0;
     p2 := -0.342242088547;
     p3 := -0.0204231210245;
     p4 := -4.53642210148E-05;
     q0 := 0.099348462606;
     q1 := 0.588581570495;
     q2 := 0.531103462366;
     q3 := 0.10353775285;
     q4 := 0.0038560700634;
     xp := 0.0;
     if (p > 0.5) then p := 1 - p;
     if (p < lim) then z := xp
     else
     begin
          errorstate := false;
          if (p = 0.5) then z := xp
          else
          begin
               Y := sqrt(ln(1.0 / (p * p)));
               xp := Y + ((((Y * p4 + p3) * Y + p2) * Y + p1) * Y + p0) /
                    ((((Y * q4 + q3) * Y + q2) * Y + q1) * Y + q0);
               if (p < 0.5) then xp := -xp;
               z := xp;
          end;
     end;
     zprob := z;
end;  // End function zprob
//-------------------------------------------------------------------

function probz(z : double) : double;
(* the distribution function of the standard normal distribution derived *)
(* by integration using simpson's rule .                                 *)

begin
  Result := 0.5 + simpsonintegral(0.0,z);
end;
//-----------------------------------------------------------------------

function simpsonintegral(a,b : real) : real;
(* integrates the function f from lower a to upper limit b choosing an *)
(* interval length so that the error is less than a given amount -     *)
(* the default value is 1.0e-06                                        *)
const error = 1.0e-4 ;

var h : real; (* current length of interval *)
    i : integer; (* counter *)
    integral : real; (* current approximation to integral *)
    lastint : real; (* previous approximation *)
    n : integer; (* no. of intervals *)
    sum1,sum2,sum4 : real; (* sums of function values *)

begin
     n := 2 ; h := 0.5 * (b - a);
     sum1 := h * (zdensity(a) + zdensity(b) );
     sum2 := 0;
     sum4 := zdensity( 0.5 * (a + b));
     integral := h * (sum1 + 4 * sum4);
     repeat
           lastint := integral; n := n + n; h := 0.5*h;
           sum2 := sum2 + sum4;
           sum4 := 0; i := 1;
           repeat
                 sum4 := sum4 + zdensity(a + i*h);
                 i := i + 2
           until i > n;
           integral := h * (sum1 + 2*sum2 + 4*sum4);
     until abs(integral - lastint) < error;
     simpsonintegral := integral/3
end; (* of SimpsonIntegral *)


{ Density function of the standard normal distribution }
function zdensity(z : real) : real;
const
   a = 0.39894228; (* 1 / sqrt(2*pi) *)
begin
     Result := a * exp(-0.5 * z*z )
end; (* of normal *)


function probf(f,df1,df2 : extended) : extended;
var
    term1, term2, term3, term4, term5, term6 : extended;

FUNCTION gammln(xx: extended): extended;

CONST
   stp = 2.50662827465;
//   half = 0.5;
   one = 1.0;
   fpf = 5.5;

VAR
   x,tmp,ser: double;
   j: integer;
   cof: ARRAY [1..6] OF extended;

BEGIN
   cof[1] := 76.18009173;
   cof[2] := -86.50532033;
   cof[3] := 24.01409822;
   cof[4] := -1.231739516;
   cof[5] := 0.120858003e-2;
   cof[6] := -0.536382e-5;
   x := xx - 1.0;
   tmp := x + fpf;
   term1 := ln(tmp);
   term2 := (x + 0.5) * term1;
   tmp := term2 - tmp;
   ser := one;
   FOR j := 1 to 6 DO BEGIN
      x := x + 1.0;
      ser := ser + cof[j] / x
   END;
   gammln := tmp +ln(stp * ser)
END;
//-----------------------------------------------------------------

function betacf(a,b,x: double): extended;
CONST
   itmax=100;
   eps=3.0e-7;
VAR
   tem,qap,qam,qab,em,d: extended;
   bz,bpp,bp,bm,az,app: extended;
   am,aold,ap: extended;
   m: integer;
BEGIN
   am := 1.0;
   bm := 1.0;
   az := 1.0;
   qab := a+b;
   qap := a+1.0;
   qam := a-1.0;
   bz := 1.0 - qab * x / qap;
   FOR m := 1 to itmax DO BEGIN
      em := m;
      tem := em+em;
      d := em * (b - m) * x / ((qam + tem) * (a + tem));
      ap := az + d * am;
      bp := bz + d * bm;
      term1 := -(a + em);
      term2 := qab + em;
      term3 := term1 * term2 * x;
      term4 := a + tem;
      term5 := qap + tem;
      term6 := term4 * term5;
      d := term3 / term6;
      app := ap + d * az;
      bpp := bp + d * bz;
      aold := az;
      am := ap/bpp;
      bm := bp/bpp;
      az := app/bpp;
      bz := 1.0;
      IF ((abs(az-aold)) < (eps*abs(az))) THEN
        Break;
   END;
  { ShowMessage('WARNING! a or b too big, or itmax too small in betacf');}
   Result := az
END;

FUNCTION betai(a,b,x: extended): extended;
VAR
   bt: extended;
BEGIN
   IF ((x <= 0.0) OR (x >= 1.0)) THEN BEGIN
     { ShowMessage('ERROR! Problem in routine BETAI');}
      betai := 0.5;
      exit;
   END;
   IF ((x <= 0.0) OR (x >= 1.0)) THEN bt := 0.0
   ELSE
       begin
            term1 := gammln(a + b) -
                     gammln(a) - gammln(b);
            term2 := a * ln(x);
            term3 := b * ln(1.0 - x);
            term4 := term1 + term2 + term3;
            bt    := exp(term4);
            term5 := (a + 1.0) / (a + b + 2.0);
       end;
   IF x < term5 then betai := bt * betacf(a,b,x) / a
   ELSE betai := 1.0 - bt * betacf(b,a,1.0-x) / b
END;

begin { fprob function }
     if f <= 0.0 then probf := 1.0 else
     probf := (betai(0.5*df2,0.5*df1,df2/(df2+df1*f)) +
                   (1.0-betai(0.5*df1,0.5*df2,df1/(df1+df2/f))))/2.0;
end; // of fprob function
//--------------------------------------------------------------------

{  Algorithm AS66 Applied Statistics (1973) vol.22, no.3

   Evaluates the tail area of the standardised normal curve
   from x to infinity if upper is .true. or
   from minus infinity to x if upper is .false.
   ELF90-compatible version by Alan Miller
   Latest revision - 29 November 1997 }
function alnorm(x: double; upper: boolean): double;
label
  Lbl20, Lbl30, Lbl40;
const
   zero = 0.0;
   one = 1.0;
   half = 0.5;
   con = 1.28;
   ltone = 7.0;
   utzero = 18.66;
   p = 0.398942280444;
   q = 0.39990348504;
   r = 0.398942280385;
   a1 = 5.75885480458;
   a2 = 2.62433121679;
   a3 = 5.92885724438;
   b1 = -29.8213557807;
   b2 = 48.6959930692;
   c1 = -3.8052E-8;
   c2 = 3.98064794E-4;
   c3 = -0.151679116635;
   c4 = 4.8385912808;
   c5 = 0.742380924027;
   c6 = 3.99019417011;
   d1 = 1.00000615302;
   d2 = 1.98615381364;
   d3 = 5.29330324926;
   d4 = -15.1508972451;
   d5 = 30.789933034;
var
  fn_val: double;
  z, y: double;
  up: boolean;
begin
  up := upper;
  z := x;

  if (z <  zero) then begin
    up := not up;
    z := -z;
  end;

  if ((z <= ltone) or (up) and (z <= utzero)) then GOTO Lbl20;

  fn_val := zero;
  GOTO Lbl40;

Lbl20 :
  y := half*z*z;
  if (z > con) then GOTO Lbl30;

  fn_val := half - z*(p-q*y/(y+a1+b1/(y+a2+b2/(y+a3))));
  GOTO Lbl40;

Lbl30 :
  fn_val := r*exp(-y)/(z+c1+d1/(z+c2+d2/(z+c3+d3/(z+c4+d4/(z+c5+d5/(z+c6))))));

Lbl40 :
  if (not up) then
    fn_val := one - fn_val;

  result := fn_val;
END; // FUNCTION alnorm
//-----------------------------------------------------------------------------------

procedure ppnd7 (p : double; VAR normal_dev : double; VAR ifault : integer);
// ALGORITHM AS241  APPL. STATIST. (1988) VOL. 37, NO. 3, 477- 484.
// Produces the normal deviate Z corresponding to a given lower tail area of P;
// Z is accurate to about 1 part in 10**7.

// This ELF90-compatible version by Alan Miller - 20 August 1996
// N.B. The original algorithm is as a function; this is a subroutine

var
	zero, one, half, split1, split2, const1, const2, q, r : double;
      a0, a1, a2, a3, b1, b2, b3 : double;
	c0, c1, c2, c3, d1, d2 : double;
	e0, e1, e2, e3, f1, f2 : double;

begin
	zero := 0.0;
	one := 1.0;
	half := 0.5;
	split1 := 0.425;
	split2 := 5.0;
	const1 := 0.180625;
	const2 := 1.6;
	a0 := 3.3871327179E+00;
	a1 := 5.0434271938E+01;
    a2 := 1.5929113202E+02;
	a3 := 5.9109374720E+01;
    b1 := 1.7895169469E+01;
	b2 := 7.8757757664E+01;
	b3 := 6.7187563600E+01;
	c0 := 1.4234372777E+00;
	c1 := 2.7568153900E+00;
	c2 := 1.3067284816E+00;
	c3 := 1.7023821103E-01;
	d1 := 7.3700164250E-01;
	d2 := 1.2021132975E-01;
	e0 := 6.6579051150E+00;
	e1 := 3.0812263860E+00;
	e2 := 4.2868294337E-01;
	e3 := 1.7337203997E-02;
	f1 := 2.4197894225E-01;
	f2 := 1.2258202635E-02;
	ifault := 0;
	q := p - half;
	IF (ABS(q) <= split1) THEN
	begin
		r := const1 - q * q;
		normal_dev := q * (((a3 * r + a2) * r + a1) * r + a0) / (((b3 * r + b2) * r + b1) * r + one);
		exit; // RETURN
	end
	ELSE begin
		IF (q < zero) THEN r := p ELSE r := one - p;
  		IF (r <= zero) THEN
		begin
    			ifault := 1;
    			normal_dev := zero;
    			exit; //RETURN
  		END; // IF
  		r := SQRT(-ln(r));
  		IF (r <= split2) THEN
		begin
    			r := r - const2;
    			normal_dev := (((c3 * r + c2) * r + c1) * r + c0) / ((d2 * r + d1) * r + one);
        end
		ELSE begin
    			r := r - split2;
    			normal_dev := (((e3 * r + e2) * r + e1) * r + e0) / ((f2 * r + f1) * r + one);
  		END; // IF
  		IF (q < zero) then normal_dev := - normal_dev;
		exit;
	end; // if
end; // procedure ppnd7

{  Algorithm AS 181.2   Appl. Statist.  (1982) Vol. 31, No. 2
   Calculates the algebraic polynomial of order nored-1 with
   array of coefficients c.  Zero order coefficient is c(1) }
function poly(const c: Array of double; nord: integer; x: double): double;
var
  fn_val, p: double;
  i, j, n2: integer;
  c2: array[1..6] of double;
begin
  // copy into array for access starting at 1 instead of zero
  for i := 1 to nord do
    c2[i] := c[i-1];

  fn_val := c2[1];
  if (nord = 1) then
  begin
    result := fn_val;
    exit;
  end;

  p := x * c2[nord];
  if (nord <> 2) then
  begin
    n2 := nord - 2;
    j := n2 + 1;
    for i := 1 to n2 do
    begin
      p := (p + c2[j])*x;
      j := j - 1;
    end;
  end;
  Result := fn_val + p;
end; // FUNCTION poly

procedure swilk (var init: boolean; const x: DblDyneVec; n, n1, n2: integer;
  const a: DblDyneVec; var w, pw: double; out ifault: integer);

//        ALGORITHM AS R94 APPL. STATIST. (1995) VOL.44, NO.4
//        Calculates the Shapiro-Wilk W test and its significance level

// ARGUMENTS:
//   INIT     Set to .FALSE. on the first call so that weights A(N2) can be
//            calculated.   Set to .TRUE. on exit unless IFAULT = 1 or 3.
//   X(N1)    Sample values in ascending order.
//   N        The total sample size (including any right-censored values).
//   N1       The number of uncensored cases (N1 <= N).
//   N2       Integer part of N/2.
//   A(N2)    The calculated weights.
//   W        The Shapiro-Wilks W-statistic.
//   PW       The P-value for W.
//   IFAULT   Error indicator:
//            = 0 for no error
//            = 1 if N1 < 3
//            = 2 if N > 5000 (a non-fatal error)
//            = 3 if N2 < N/2
//            = 4 if N1 > N or (N1 < N and N < 20).
//            = 5 if the proportion censored (N - N1)/N > 0.8.
//            = 6 if the data have zero range.
//            = 7 if the X's are not sorted in increasing order

// Fortran 90 version by Alan.Miller @ vic.cmis.csiro.au
// Latest revision - 4 December 1998

label
  70;
const
  z90  = 1.2816;
  z95  = 1.6449;
  z99  = 2.3263;
  zm   = 1.7509;
  zss  = 0.56268;
  bf1  = 0.8378;
  xx90 = 0.556;
  xx95 = 0.622;
  zero = 0.0;
  one  = 1.0;
  two  = 2.0;
  three= 3.0;
  sqrth= 0.70711;
  qtr  = 0.25;
  th = 0.375;
  small= 1E-19;
  pi6  = 1.909859;
  stqr = 1.047198;
  c1: array[1..6] of double = (0.0, 0.221157, -0.147981, -2.07119, 4.434685, -2.706056);
  c2: array[1..6] of double = (0.0, 0.042981, -0.293762, -1.752461, 5.682633, -3.582633);
  c3: array[1..4] of double = (0.5440, -0.39978, 0.025054, -0.6714E-3);
  c4: array[1..4] of double = (1.3822, -0.77857, 0.062767, -0.0020322);
  c5: array[1..4] of double = (-1.5861, -0.31082, -0.083751, 0.0038915);
  c6: array[1..3] of double = (-0.4803, -0.082676, 0.0030302);
  c7: array[1..2] of double = (0.164, 0.533);
  c8: array[1..2] of double = (0.1736, 0.315);
  c9: array[1..2] of double = (0.256, -0.00635);
  g: array[1..2] of double = (-2.273, 0.459);
var
  summ2, ssumm2, fac, rsn, an, an25, a1, a2, delta, range: double;
  sa, sx, ssx, ssa, sax, asa, xsx, ssassx, w1, y, xx, xi: double;
  gamma, m, s, ld, bf, z90f, z95f, z99f, zfm, zsd, zbar: double;
  ncens, nn2, i, i1, j: integer;
  upper: boolean;
begin
  upper := true;
  pw  :=  one;
  if (w >= zero) then w := one;
  an := n;
  ifault := 3;
  nn2 := n div 2;
  if (n2 < nn2) then exit;
  ifault := 1;
  if (n < 3) then exit;

  // If INIT is false, calculate coefficients for the test
  if (not init) then
  begin
    if (n = 3) then
      a[1] := sqrth
    else
    begin
      an25 := an + qtr;
      summ2 := zero;
      for i := 1 to n2 do
      begin
        ppnd7((i - th)/an25, a[i], ifault);
      	summ2 := summ2 + (a[i] * a[i]);
      end;
      summ2 := summ2 * two;
      ssumm2 := SQRT(summ2);
      rsn := one / SQRT(an);
      a1 := poly(c1, 6, rsn) - a[1] / ssumm2;

      // Normalize coefficients
      if (n > 5) then
      begin
        i1 := 3;
      	a2 := -a[2]/ssumm2 + poly(c2,6,rsn);
      	fac := SQRT(
          (summ2 - two * a[1] * a[1]  - two * a[2] * a[2])/
          (one - two * power(a1,2) - two * power(a2,2))
        );
      	a[1] := a1;
      	a[2] := a2;
      end
      else begin
        i1 := 2;
      	fac := SQRT((summ2 - two * a[1] * a[1])/ (one - two * a1 * a1));
	a[1] := a1;
      end;
      for i := i1 to nn2 do
        a[i] := -a[i]/fac;
    end;
    init := true;
  end;
  if (n1 < 3) then
    exit;

  ncens := n - n1;
  ifault := 4;
  if (ncens < 0) or ((ncens > 0) and (n < 20)) then exit;
  ifault := 5;
  delta := ncens/an;
  if (delta > 0.8) then exit;

//  If W input as negative, calculate significance level of -W
  if (w < zero) then
  begin
    w1 := one + w;
    ifault := 0;
    GOTO 70;
  end; // IF

// Check for zero range
  ifault := 6;
  range := x[n1] - x[1];
  if (range < small) then exit; //RETURN

// Check for correct sort order on range - scaled X
  ifault := 7;
  xx := x[1] / range;
  sx := xx;
  sa := -a[1];
  j := n - 1;
  for i := 2 to n1 do
  begin
    xi := x[i]/range;
    if (xx-xi > small) then
    begin
      { ShowMessage('x[i]s out of order'); // WRITE(*, *) 'x(i)s out of order'}
      exit;// RETURN
    end; // IF
    sx := sx + xi;
    if (i <> j) then sa := sa + SIGN(1, i - j) * a[MIN(i, j)];
    xx := xi;
    j := j - 1;
  end; // DO

  ifault := 0;
  if (n > 5000) then ifault := 2;

// Calculate W statistic as squared correlation
// between data and coefficients
  sa := sa/n1;
  sx := sx/n1;
  ssa := zero;
  ssx := zero;
  sax := zero;
  j := n;
  for i := 1 to n1 do
  begin
    if (i <> j) then
      asa := SIGN(1, i - j) * a[MIN(i, j)] - sa
    else
      asa := -sa;
    xsx := x[i]/range - sx;
    ssa := ssa + asa * asa;
    ssx := ssx + xsx * xsx;
    sax := sax + asa * xsx;
    j := j - 1;
  end; // DO

//  W1 equals (1-W) claculated to avoid excessive rounding error
//  for W very near 1 (a potential problem in very large samples)
  ssassx := SQRT(ssa * ssx);
  w1 := (ssassx - sax) * (ssassx + sax)/(ssa * ssx);
70:  w := one - w1;

//  Calculate significance level for W (exact for N=3)
  if (n = 3) then
  begin
    pw := pi6 * (ARCSIN(SQRT(w)) - stqr);
    exit; //RETURN
  end; // IF
  y := LN(w1);
  xx := LN(an);
//	m := zero;
//	s := one;
  if (n <= 11) then
  begin
    gamma := poly(g, 2, an);
    if (y >= gamma) then
    begin
      pw := small;
      exit; //RETURN
    end; // IF
    y := -LN(gamma - y);
    m := poly(c3, 4, an);
    s := EXP(poly(c4, 4, an));
  end
  else begin
    m := poly(c5, 4, xx);
    s := EXP(poly(c6, 3, xx));
  end; // IF
  if (ncens > 0) then
  begin
//  Censoring by proportion NCENS/N.  Calculate mean and sd
//  of normal equivalent deviate of W.
    ld := -LN(delta);
    bf := one + xx * bf1;
    z90f := z90 + bf * power(poly(c7, 2, power(xx90,xx)),ld);
    z95f := z95 + bf * power(poly(c8, 2, power(xx95,xx)),ld);
    z99f := z99 + bf * power(poly(c9, 2, xx),ld);

//  Regress Z90F,...,Z99F on normal deviates Z90,...,Z99 to get
//  pseudo-mean and pseudo-sd of z as the slope and intercept
    zfm := (z90f + z95f + z99f)/three;
    zsd := (z90*(z90f-zfm)+z95*(z95f-zfm)+z99*(z99f-zfm))/zss;
    zbar := zfm - zsd * zm;
    m := m + zbar * s;
    s := s * zsd;
  end; // IF
  pw := alnorm((y - m)/s, upper);
end; // procedure
//-----------------------------------------------------------------------

procedure SVDinverse(VAR a : DblDyneMat; N : integer);
// a shorter version of the matinv routine that ignores v, w, and vtimes w
// matrices in the singular value decompensation inverse procedure
var
   v, w, vtimesw : DblDyneMat;
begin
     SetLength(v,N,N);
     SetLength(w,N,N);
     SetLength(vtimesw,N,N);
     matinv(a,vtimesw,v,w,N);
end;
//-------------------------------------------------------------------

function probt(t,df1 : double) : double;
var
   F, prob : double;
begin
    // Returns the probability corresponding to a two-tailed t test.
    F := t * t;
    prob := probf(F,1.0,df1);
    Result := prob;
end;
//------------------------------------------------------------------------

function inverset(Probt, DF : double) : double;
var
   z, W, tValue: double;
begin
    // Returns the t value corresponding to a two-tailed t test probability.
    z := inversez(Probt);
    W := z * ((8.0 * DF + 3.0) / (1.0 + 8.0 * DF));
    tValue := sqrt(DF * (exp(W * W / DF) - 1.0));
    inverset := tValue;
end;
//---------------------------------------------------------------------

function inversechi(p : double; k : integer) : double;
var
   a1, w, z : double;
begin
       z := inversez(p);
       a1 := 2.0 / ( 9.0 * k);
       w := 1.0 - a1 + z * sqrt(a1);
       Result := (k * w * w * w);
end;
//---------------------------------------------------------------------

function STUDENT(q,v,r : real) : real;

{ Yields the probability of a sample value of Q or larger from a population
  with r means and degrees of freedom for the mean square error of v.}
var
   probq : real;
//   done : boolean;
   ifault : integer;
//   ch : char;

function alnorm(x: real; upper: boolean): real;
{ algorithm AS 66 from Applied Statistics, 1973, Vol. 22, No.3, pg.424-427 }

var
   ltone, utzero, zero, half, one, con, z, y : real;
   up : boolean;
   altemp: real;

begin
     // altemp := 0.0;
     ltone := 7.0;
     utzero := 18.66;
     zero := 0.0;
     half := 0.5;
     one := 1.0;
     con := 1.28;
     up := upper;
     z := x;
     if z < zero then
     begin
          up := not up;
          z := -z;
     end;
     if (z <= ltone) or (up) and (z <= utzero) then
     begin
          y := half * z * z;
          if z > con then
          begin
               altemp := 0.398942280385 * exp(-y) /
               (z - 3.8052e-8 + 1.00000615302 /
               (z + 3.98064794e-4 + 1.98615381364 /
               (z - 0.151679116635 + 5.29330324926 /
               (z + 4.8385912808 - 15.1508972451 /
               (z + 0.742380924027 + 30.789933034 /
               (z + 3.99019417011))))));
          end
          else altemp := half - z * (0.398942280444 - 0.399903438504 * y /
               (y + 5.75885480458 - 29.8213557808 /
               (y + 2.62433121679 + 48.6959930692 /
               (y + 5.92885724438))));
     end
     else altemp := zero;
     if not up then altemp := one - altemp;
     alnorm := altemp;
end;
//----------------------------------------------------------------------------

procedure prtrng(q, v, r : real; var ifault : integer; var sumprob : real);

{ algorithm as 190 appl. Statistics, 1983, Vol.32, No.2
  evaluates the probability from 0 to q for a studentized range having
  v degrees of freedom and r samples. }

label 21, 22, 25;

var
   pcutj, pcutk, step, vmax, zero, fifth, half, one, two : real;
   cv1, cv2, cvmax : real;
   vw, qw : array[1..30] of real;
   cv : array[1..4] of real;
   jmin, jmax, kmin, kmax : integer;
   g, gmid, r1, c, h, v2, gstep, gk, pk, pk1, pk2, w0, pz : real;
   x, hj, ehj, pj : real;
   j, jj, jump, k : integer;

begin
   sumprob := 0.0;
   pcutj := 0.00003; pcutk := 0.0001; step := 0.45; vmax := 120.0;
   zero := 0.0; fifth := 0.2; half := 0.5; one := 1.0; two := 2.0;
   cv1 := 0.193064705; cv2 := 0.293525326; cvmax := 0.39894228;
   cv[1] := 0.318309886; cv[2] := -0.268132716e-2;
   cv[3] := 0.347222222e-2; cv[4] := 0.833333333e-1;
   jmin := 3; jmax := 13; kmin := 7; kmax := 15;
   { check initial values }
//   prtrng := zero;
   ifault := 0;
   if (v < one) or (r < two) then ifault := 1;
   if (q >= zero) and (ifault = 0) then
   begin  { main body of function }
      g := step * realraise(r,-fifth);
      gmid := half * ln(r);
      r1 := r - one;
      c := ln(r * g * cvmax);
      if c <= vmax then
      begin
         h := step * realraise(v,-half);
         v2 := v * half;
         if v = one then c := cv1;
         if v = two then c := cv2;
         if NOT ((v = one) or (v = two)) then c := sqrt(v2) * cv[1] /
            (one + ((cv[2] / v2 + cv[3]) / v2 + cv[4]) / v2);
         c := ln(c * r * g * h);
      end;
   { compute integral.
     Given a row k, the procedure starts at the midpoint and works outward
     (index j) in calculating the probability at nodes symetric about the
     midpoint.  The rows (index k) are also processed outwards symmetrically
     about the midpoint.  The center row is unpaired. }
     gstep := g;
     qw[1] := -one;
     qw[jmax + 1] := -one;
     pk1 := one;
     pk2 := one;
     for k := 1 to kmax do
     begin
       gstep := gstep - g;
21:    gstep := -gstep;
       gk := gmid + gstep;
       pk := zero;
       if (pk2 > pcutk) or (k <= kmin) then
       begin
             w0 := c - gk * gk * half;
             pz := alnorm(gk,TRUE);
             x := alnorm(gk - q,TRUE) - pz;
             if (x > zero) then pk := exp(w0 + r1 * ln(x));
             if v <= vmax then
             begin
                jump := -jmax;
          22:   jump := jump + jmax;
                for j := 1 to jmax do
                begin
                    jj := j + jump;
                    if (qw[jj] <= zero) then
                    begin
                        hj := h * j;
                        if j < jmax then qw[jj + 1] := -one;
                        ehj := exp(hj);
                        qw[jj] := q * ehj;
                        vw[jj] := v * (hj + half - ehj * ehj * half);
                      end;
                      pj := zero;
                      x := alnorm(gk - qw[jj],TRUE) - pz;
                      if x > zero then pj := exp(w0 + vw[jj] + r1 * ln(x));
                      pk := pk + pj;
                      if pj <= pcutj then
                      begin
                           if(jj > jmin) or (k > kmin) then goto 25;
                      end;
                  end; { for j := 1 to jmax }
         25:    h := -h;
                if h < zero then goto 22;
             end; { if v less than or equal vmax }
       end;  { if pk2 > pcutk or k <= kmin }
       sumprob := sumprob + pk;
       if (k <= kmin) or (pk > pcutk) or (pk1 > pcutk) then
       begin
           pk2 := pk1;
           pk1 := pk;
           if gstep > zero then goto 21;
       end;
     end; { for k := 1 to kmax }
   end; { main body of function }
//   prtrng := sumprob;
end; { of function }

begin { program main body }
   ifault := 0;
      probq := 0.0;
      prtrng(q,v,r,ifault,probq);
      probq := 1.0 - probq;
     { if ifault = 1 then ShowMessage('ERROR! Fault in calculating Student Q.');}
      student := probq;
 end; { end of student function }
//-------------------------------------------------------------------

function realraise(base,power : double ): double;
begin
     if power = 0 then realraise := 1.0
     else if power < 0 then realraise := 1 / realraise(base,-power)
     else realraise := exp(power * ln(base))
end;   (* End of realraise *)
//-------------------------------------------------------------------

function fpercentpoint(p : real; k1,k2 : integer) : real;

(* Calculates the inverse F distribution function based on k1 and k2 *)
(* degrees of freedom.  Uses function lngamma, betaratio and the     *)
(* inversebetaratio routines.                                        *)

var h1,h2 : real; (* half degrees of freedom k1, k2 *)
    lnbeta : real; (* log of complete beta function with params h1 and h2 *)
    ratio : real; (* beta ratio *)
    x : real; (* inverse beta ratio *)

begin
     h1 := 0.5 * k2;
     h2 := 0.5 * k1;
     ratio := 1 - p;
     lnbeta := lngamma(h1) + lngamma(h2) - lngamma(h1 + h2);
     x := inversebetaratio(ratio,h1,h2,lnbeta);
     fpercentpoint := k2 * (1 - x) / (k1 * x)
end; (* of fpercentpoint *)
//-------------------------------------------------------------------

function lngamma(w : real) : real;

(* Calculates the logarithm of the gamma function.  w must be such that *)
(*   2*w is an integer > 0.                                             *)

const a = 0.57236494; (* ln(sqrt(pi)) *)

var sum:real; (* a temporary store for summation of values *)

begin
     sum := 0;
     w := w-1;
     while w > 0.0 do
     begin
          sum := sum + ln(w);
          w := w - 1
     end; (* of summation loop *)
     if w < 0.0
        then lngamma := sum + a  (* note!!! is something is missing here? *)
        else lngamma := sum
end; (* of lngamma *)
//-------------------------------------------------------------------

function betaratio(x,a,b,lnbeta : real) : real;

(* calculates the incomplete beta function ratio with parameters a    *)
(* and b.  LnBeta is the logarithm of the complete beta function with *)
(* parameters a and b.                                                *)

const error = 1.0E-7;

var c : real; (* c = a + b *)
    factor1,factor2,factor3 : real; (* factors multiplying terms in series *)
    i,j : integer; (* counters *)
    sum : real; (* current sum of series *)
    temp : real; (* temporary store for exchanges *)
    term : real; (* term of series *)
    xlow : boolean; (* status of x which determines the end from which the *)
                    (* series is evaluated *)
    // ylow : real; (* adjusted argument *)
    y : real;

begin
     if (x=0) or (x=1)
     then
         sum := x
     else begin
          c := a + b;
          if a < c*x
          then begin
               xlow := true;
               y := x;
               x := 1 - x;
               temp := a;
               a := b;
               b := temp
          end
          else begin
               xlow := false;
               y := 1 - x;
          end;
          term := 1;
          j := 0;
          sum := 1;
          i := trunc(b + c * y) + 1;
          factor1 := x/y;
          repeat
                j := j + 1;
                i := i - 1;
                if i >= 0
                then begin
                     factor2 := b - j;
                     if i = 0 then factor2 := x;
                end;
                if abs(a+j) < 1.0e-6 then
                begin
                     betaratio := sum;
                     exit;
                end;
                term := term*factor2*factor1/(a+j);
                sum := sum + term;
          until (abs(term) <= sum) and (abs(term) <= error*sum);
          factor3 := exp(a*ln(x) + (b-1)*ln(y) - lnbeta);
          sum := sum*factor3/a;
          if xlow
             then sum := 1 - sum;
     end;
     betaratio := sum;
end; (* of betaratio *)
//-------------------------------------------------------------------

function inversebetaratio(ratio,a,b,lnbeta : real) : real;

(* Calculates the inverse of the incomplete beta function ratio with *)
(* parameters a and b.  LnBeta is the logarithm of the complete beta *)
(* function with parameters a and b.  Uses function betaratio.       *)

const error = 1.0E-7;

var
//   c: real; (* c = a + b *)
    largeratio : boolean;
    temp1,temp2,temp3,temp4 : real; (* temporary variables *)
    x,x1 : real; (* successive estimates of inverse ratio *)
    y : real; (* adjustment during newton iteration *)

begin
     if (ratio = 0) or (ratio = 1)
     then
         x := ratio
     else begin
          largeratio := false;
          if ratio > 0.5
          then begin
               largeratio := true;
               ratio := 1 - ratio;
               temp1 := a;
               b := a;
               a := temp1
          end;
//          c := a + b;
          (* calcuates initial estimate for x *)
          temp1 := sqrt(-ln(ratio*ratio));
          temp2 := 1.0 + temp1*(0.99229 + 0.04481*temp1);
          temp2 := temp1 - (2.30753 + 0.27061*temp1)/temp2;
          if (a > 1) and (b > 1)
          then begin
               temp1 := (temp2*temp2 - 3.0)/6.0;
               temp3 := 1.0/(a + a -1.0);
               temp4 := 1.0/ (b + b - 1.0);
               x1 := 2.0 /(temp3 + temp4);
               x := temp1 + 5.0/6.0 - 2.0/(3.0*x1);
               x := temp2*sqrt(x1 + temp1)/x1 - x*(temp4 - temp3);
               x := a/(a + b*exp(x + x))
          end
          else begin
               temp1 := b + b;
               temp3 := 1.0/(9.0*b);
               temp3 := 1.0 - temp3 + temp2*sqrt(temp3);
               temp3 := temp1*temp3*temp3*temp3;
               if temp3 > 0
               then begin
                    temp3 := (4.0*a + temp1 - 2.0)/temp3;
                    if temp3 > 1 then x := 1.0-2.0/(1 + temp3)
                    else x := exp((ln(ratio*a) + lnbeta)/a)
               end
               else x := 1.0 - exp((ln((1-ratio)*b) + lnbeta)/b);
          end;

          (* Newton iteration *)
          repeat
                y := betaratio(x,a,b,lnbeta);
                y := (y-ratio)*exp((1-a)*ln(x)+(1-b)*ln(1-x)+lnbeta);
                temp4 := y;
                x1 := x - y;
                while (x1 <= 0) or (x1 >= 1) do
                begin
                     temp4 := temp4/2;
                     x1 := x - temp4
                end;
                x := x1;
          until abs(y) < error;
          if largeratio then x := 1 - x;
     end;
     inversebetaratio := x
end; (* of inversebetaratio *)
//-------------------------------------------------------------------

function ProdSums(N, A : double) : double;
var
   Total, i : double;
begin
    Total := 1.0;
    i := A;
    while i <= N do
    begin
        Total := Total * i;
        i := i + 1.0;
    end;
    Result := Total;
end;
//-------------------------------------------------------------------

function combos(X, N : double) : double;
var
   Y, numerator, denominator : double;
begin
    Y := N - X;
    if Y > X then
    begin
        numerator := ProdSums(N, Y + 1);
        denominator := ProdSums(X, 1);
    end
    else begin
        numerator := ProdSums(N, X + 1);
        denominator := ProdSums(Y, 1);
    end;
    Result := numerator / denominator;
end;
//-------------------------------------------------------------------

function ordinate(z : double) : double;
var pi : double;
begin
     pi := 3.14159;
     Result := (1.0 / sqrt(2.0 * pi)) * (1.0 / exp(z * z / 2.0));
end; // End ord function
//-------------------------------------------------------------------

procedure Rank(v1col : integer; VAR Values : DblDyneVec);
// calculates the ranks for values stored in the data grid in column v1col
var
   pcntiles, CatValues : DblDyneVec;
   freq : IntDyneVec;
   i, j, nocats : integer;
   Temp, cumfreq, upper, lower : double;

begin
    SetLength(freq, NoCases);
    SetLength(pcntiles, NoCases);
    SetLength(CatValues, NoCases);

    // get values to be sorted into values vector
    for i := 1 to NoCases do
        Values[i-1] := StrToFloat(OS3MainFrm.DataGrid.Cells[v1col,i]);

    // sort the values
    for i := 1 to NoCases - 1 do //order from high to low
    begin
        for j := i + 1 to NoCases do
        begin
            if (Values[i-1] < Values[j-1]) then // swap
            begin
                Temp := Values[i-1];
                Values[i-1] := Values[j-1];
                Values[j-1] := Temp;
            end;
        end;
    end;

    // now get no. of unique values and frequency of each
    nocats := 1;
    for i := 1 to NoCases do freq[i-1] := 0;
    Temp := Values[0];
    CatValues[0] := Temp;
    for i := 1 to NoCases do
    begin
        if (Temp = Values[i-1]) then  freq[nocats-1] := freq[nocats-1] + 1
        else // new value
        begin
            nocats := nocats + 1;
            freq[nocats-1] := freq[nocats-1] + 1;
            Temp := Values[i-1];
            CatValues[nocats-1] := Temp;
        end;
    end;

    // get ranks
    cumfreq := 0.0;
    for i := 1 to nocats do
    begin
        upper := NoCases-cumfreq;
        cumfreq := cumfreq + freq[i-1];
        lower := NoCases - cumfreq + 1;
        pcntiles[i-1] := (upper - lower) / 2.0 + lower;
    end;

    // convert original values to their corresponding ranks
    for i := 1 to NoCases do
    begin
        Temp := StrToFloat(OS3MainFrm.DataGrid.Cells[v1col,i]);
        for j := 1 to nocats do
        begin
            if (Temp = CatValues[j-1]) then Values[i-1] := pcntiles[j-1];
        end;
    end;

    // clean up the heap
    CatValues := nil;
    pcntiles := nil;
    freq := nil;
end;
//--------------------------------------------------------------------

procedure PRank(v1col: integer; var Values: DblDyneVec; AReport: TStrings);
// computes the percentile ranks of values stored in the data grid
// at column v1col
var
  pcntiles, cumfm, CatValues: DblDyneVec;
  freq, cumf: IntDyneVec;
  Temp: double;
  i, j, nocats, ncases: integer;
begin
  SetLength(freq, NoCases);
  SetLength(pcntiles, NoCases);
  SetLength(cumf, NoCases);
  SetLength(cumfm, NoCases);
  SetLength(CatValues, NoCases);
  ncases := 0;

  // get values to be sorted into values vector
  for i := 1 to NoCases do
  begin
    if not ValidValue(i,v1col) then continue;
    ncases := ncases + 1;
    Values[ncases-1] := StrToFloat(OS3MainFrm.DataGrid.Cells[v1col,i]);
  end;

  // sort the values
  for i := 1 to ncases - 1 do //order from low to high
  begin
    for j := i + 1 to ncases do
    begin
      if (Values[i-1] > Values[j-1]) then // swap
      begin
        Temp := Values[i-1];
        Values[i-1] := Values[j-1];
        Values[j-1] := Temp;
      end;
    end;
  end;

  // now get no. of unique values and frequency of each
  nocats := 1;
  for i := 1 to ncases do freq[i-1] := 0;
  Temp := Values[0];
  CatValues[0] := Temp;
  for i := 1 to ncases do
  begin
    if (Temp = Values[i-1])then
      freq[nocats-1] := freq[nocats-1] + 1
    else // new value
    begin
      nocats := nocats + 1;
      freq[nocats-1] := freq[nocats-1] + 1;
      Temp := Values[i-1];
      CatValues[nocats-1] := Temp;
    end;
  end;

  // now get cumulative frequencies
  cumf[0] := freq[0];
  for i := 1 to nocats-1 do
    cumf[i] := freq[i] + cumf[i-1];

  // get cumulative frequences to midpoints and percentile ranks
  cumfm[0] := freq[0] / 2.0;
  pcntiles[0] := (cumf[0] / 2.0) / ncases;
  for i := 1 to nocats-1 do
  begin
    cumfm[i] := (freq[i] / 2.0) + cumf[i-1];
    pcntiles[i] := cumfm[i] / ncases;
  end;

  AReport.Add('PERCENTILE RANKS');
  AReport.Add('Score Value   Frequency  Cum.Freq.  Percentile Rank');
  AReport.Add('-----------   ---------  ---------  ---------------');
//  AReport.Add('___________   __________  __________ ______________');
  for i := 1 to nocats do
    AReport.Add(' %10.3f    %8d   %8d    %12.2f%%', [CatValues[i-1], freq[i-1], cumf[i-1], pcntiles[i-1]*100.0]);
  AReport.Add('');

  // convert original values to their corresponding percentile ranks
  for i := 1 to ncases do
  begin
    Temp := StrToFloat(OS3MainFrm.DataGrid.Cells[v1col,i]);
    for j := 1 to nocats do
      if (Temp = CatValues[j-1]) then Values[i-1] := pcntiles[j-1];
  end;

  // clean up the heap
  CatValues := nil;
  cumfm := nil;
  cumf := nil;
  pcntiles := nil;
  freq := nil;
end;
//--------------------------------------------------------------------

function UniStats(N : integer; VAR X : DblDyneVec; VAR z : DblDyneVec;
                  VAR Mean : double; VAR variance : double; VAR SD : double;
                  VAR Skew : double; VAR Kurtosis : double; VAR SEmean : double;
                  VAR SESkew : double; VAR SEkurtosis : double; VAR min : double;
                  VAR max : double; VAR Range : double; VAR MissValue : string) :
                  integer;
VAR
   NoGood : integer; // No. of good cases returned by the function
   i : integer; // index for loops
   num, den, sum, M2, M3, M4, deviation, devsqr : double;
   valuestr : string;

begin
     Mean := 0.0;
     variance := 0.0;
     SD := 0.0;
     Skew := 0.0;
     Kurtosis := 0.0;
     SEmean := 0.0;
     SESkew := 0.0;
     SEKurtosis := 0.0;
     min := 1.0e20;
     max := -1.0e20;
     range := 0.0;
     NoGood := 0;
     sum := 0.0;
     M2 := 0.0;
     M3 := 0.0;
     M4 := 0.0;

     for i := 0 to N-1 do
     begin
          ValueStr := FloatToStr(X[i]);
          if Trim(MissValue) = ValueStr then continue;
          NoGood := NoGood + 1;
          sum := sum + X[i];
          variance := variance + (X[i] * X[i]);
          if X[i] < min then min := X[i];
          if X[i] > max then max := X[i];
     end;

     if NoGood > 0 then
     begin
          Mean := sum / NoGood;
          range := max - min;
     end;

     if NoGood > 1 then
     begin
          variance := variance - (sum * sum) / NoGood;
          variance := variance / (NoGood - 1);
          SD := sqrt(variance);
          SEmean := sqrt(variance / NoGood);
          for i := 0 to N-1 do
          begin
               ValueStr := FloatToStr(X[i]);
               if Trim(MissValue) = ValueStr then continue;
               deviation := X[i] - Mean;
               z[i] := deviation / SD;
               devsqr := deviation * deviation;
               M2 := M2 + devsqr;
               M3 := M3 + (deviation * devsqr);
               M4 := M4 + (devsqr * devsqr);
          end;
     end;
     if NoGood > 3 then
     begin
          Skew := (NoGood * M3) / ((NoGood - 1) * (NoGood - 2) * SD * variance);
          num := 6.0 * NoGood * (NoGood - 1);
          den := (NoGood - 2) * (NoGood + 1) * (NoGood + 3);
          SESkew := sqrt(num / den);
          Kurtosis := (NoGood * (NoGood + 1) * M4) - (3.0 * M2 * M2 * (NoGood - 1));
          Kurtosis := Kurtosis / ((NoGood - 1) * (NoGood - 2) * (NoGood - 3) *
                      (variance * variance));
          SeKurtosis := sqrt((4.0 * (NoGood * NoGood - 1) * (SESkew * SESkew)) /
                        ((NoGood - 3) * (NoGood + 5)));
     end;
     Result := NoGood;
end;
//-------------------------------------------------------------------

function WholeValue(value : double) : double;
        { split a value into the whole and fractional parts}
VAR
        whole : double;
begin
        whole := Floor(value);
        Result := whole;
end;
//---------------------------------------------------------------------------
function FractionValue(value : double) : double;
        { split a value into the whole and fractional parts }
VAR
        fraction : double;
begin
        fraction := value - Floor(value);
        Result := fraction;
end;
//---------------------------------------------------------------------------

Function Quartiles(TypeQ : integer; pcntile : double; N : integer;
         VAR values : DblDyneVec) : double;
VAR
        whole, fraction, Myresult, np, avalue, avalue1 : double;
        subscript : integer;
begin
{        for i := 0 to N - 1 do // this is for debugging
        begin
             outline := format('Value = %8.3f',[values[i]]);
             OutPutFrm.RichEdit.Lines.Add(outline);
        end;
        OutPutFrm.ShowModal;
        OutPutFrm.RichEdit.Clear; }
        case TypeQ of
                1 :  np := pcntile * N;
                2 :  np := pcntile * (N + 1);
                3 :  np := pcntile * N;
                4 :  np := pcntile * N;
                5 :  np := pcntile * (N - 1);
                6 :  np := pcntile * N + 0.5;
                7 :  np := pcntile * (N + 1);
                8 :  np := pcntile * (N + 1);
        end;
        whole := WholeValue(np);
        fraction := FractionValue(np);
        subscript := Trunc(whole) - 1;
        avalue := values[subscript];
        avalue1 := values[subscript + 1];
        case TypeQ of
           1 : Myresult := ((1.0 - fraction) * values[subscript]) +
                         fraction * values[subscript + 1];
           2 : Myresult := ((1.0 - fraction) * avalue) +
                         fraction * avalue1; // values[subscript + 1];
           3 : if (fraction = 0.0) then Myresult := values[subscript]
               else Myresult := values[subscript + 1];
           4 : if (fraction = 0.0) then Myresult := 0.5 * (values[subscript] + values[subscript + 1])
               else Myresult := values[subscript + 1];
           5 : if (fraction = 0.0) then Myresult := values[subscript + 1]
               else Myresult := values[subscript + 1] + fraction * (values[subscript + 2] -
                    values[subscript + 1]);
           6 : Myresult := values[subscript];
           7 : if (fraction = 0.0) then Myresult := values[subscript]
               else Myresult := fraction * values[subscript] +
                  (1.0 - fraction) * values[subscript + 1];
           8 : begin
               if (fraction = 0.0) then Myresult := values[subscript];
               if (fraction = 0.5) then Myresult := 0.5 * (values[subscript] + values[subscript + 1]);
               if (fraction < 0.5) then Myresult := values[subscript];
               if (fraction > 0.5) then Myresult := values[subscript + 1];
               end;
        end;
        Result := Myresult;
end;

function KolmogorovProb(z : double) : double;
VAR
   fj : array[0..3] of double; // = {-2,-8,-18,-32};
   r : array[0..4] of double;
   u : double;
   p, V : double;
   j, Maxj : integer;
const
   w = 2.50662827;
   // c1 - -pi**2/8, c2 = 9*c1, c3 = 25*c1
   c1 = -1.2337005501361697;
   c2 = -11.103304951225528;
   c3 = -30.842513753404244;


   // Calculates the Kolmogorov distribution function,
   // which gives the probability that Kolmogorov's test statistic will exceed
   // the value z assuming the null hypothesis. This gives a very powerful
   // test for comparing two one-dimensional distributions.
   // see, for example, Eadie et al, "statistocal Methods in Experimental
   // Physics', pp 269-270).
   //
   // This function returns the confidence level for the null hypothesis, where:
   //   z = dn*sqrt(n), and
   //   dn  is the maximum deviation between a hypothetical distribution
   //       function and an experimental distribution with
   //   n    events
   //
   // NOTE: To compare two experimental distributions with m and n events,
   //       use z = sqrt(m*n/(m+n))*dn
   //
   // Accuracy: The function is far too accurate for any imaginable application.
   //           Probabilities less than 10^-15 are returned as zero.
   //           However, remember that the formula is only valid for "large" n.
   // Theta function inversion formula is used for z <= 1
   //
   // This function was translated by Rene Brun from PROBKL in CERNLIB.

begin
   u := Abs(z);
   fj[0] := -2;
   fj[1] := -8;
   fj[2] := -18;
   fj[3] := -32;
   if (u < 0.2) then p := 1
   else if (u < 0.755) then
   begin
        v := 1./(u*u);
        p := 1 - w * (Exp(c1 * v) + Exp(c2 * v) + Exp(c3 * v)) / u;
   end
   else if (u < 6.8116) then
   begin
      r[1] := 0;
      r[2] := 0;
      r[3] := 0;
      v := u * u;
      maxj := round(max(1,(3. / u)));
      for j := 0 to maxj -1 do r[j] := Exp(fj[j] * v);
      p := 2 * (r[0] - r[1] + r[2] - r[3]);
   end
   else p := 0;
   result := p;
end;

function KolmogorovTest(na : integer; const a: DblDyneVec; nb: integer;
         const b: DblDyneVec; option: String; AReport: TStrings): double;
VAR
   prob : double;
   opt : string;
   rna : double; // = na;
   rnb : double; // = nb;
   sa : double;  // = 1./rna;
   sb : double;  // = 1./rnb;
   rdiff, rdmax, x, z : double;
   i, ia, ib : integer;
   ok : boolean;
begin
//  Statistical test whether two one-dimensional sets of points are compatible
//  with coming from the same parent distribution, using the Kolmogorov test.
//  That is, it is used to compare two experimental distributions of unbinned data.
//
//  Input:
//  a,b: One-dimensional arrays of length na, nb, respectively.
//       The elements of a and b must be given in ascending order.
//  option is a character string to specify options
//         "D" Put out a line of "Debug" printout
//         "M" Return the Maximum Kolmogorov distance instead of prob
//
//  Output:
//  The returned value prob is a calculated confidence level which gives a
//  statistical test for compatibility of a and b.
//  Values of prob close to zero are taken as indicating a small probability
//  of compatibility. For two point sets drawn randomly from the same parent
//  distribution, the value of prob should be uniformly distributed between
//  zero and one.
//
//  in case of error the function return -1
//  If the 2 sets have a different number of points, the minimum of
//  the two sets is used.
//
//  Method:
//  The Kolmogorov test is used. The test statistic is the maximum deviation
//  between the two integrated distribution functions, multiplied by the
//  normalizing factor (rdmax*sqrt(na*nb/(na+nb)).
//
//  Code adapted by Rene Brun from CERNLIB routine TKOLMO (Fred James)
//   (W.T. Eadie, D. Drijard, F.E. James, M. Roos and B. Sadoulet,
//      Statistical Methods in Experimental Physics, (North-Holland,
//      Amsterdam 1971) 269-271)
//
//  Method Improvement by Jason A Detwiler (JADetwiler@lbl.gov)
//  -----------------------------------------------------------
//   The nuts-and-bolts of the TMath::KolmogorovTest() algorithm is a for-loop
//   over the two sorted arrays a and b representing empirical distribution
//   functions. The for-loop handles 3 cases: when the next points to be
//   evaluated satisfy a>b, a<b, or a=b:
//   For the last case, a=b, the algorithm advances each array by one index in an
//   attempt to move through the equality. However, this is incorrect when one or
//   the other of a or b (or both) have a repeated value, call it x. For the KS
//   statistic to be computed properly, rdiff needs to be calculated after all of
//   the a and b at x have been tallied (this is due to the definition of the
//   empirical distribution function; another way to convince yourself that the
//   old CERNLIB method is wrong is that it implies that the function defined as the
//   difference between a and b is multi-valued at x -- besides being ugly, this
//   would invalidate Kolmogorov's theorem).
//
//  NOTE1
//  A good description of the Kolmogorov test can be seen at:
//    http://www.itl.nist.gov/div898/handbook/eda/section3/eda35g.htm

   opt := option;
//   opt.ToUpper();

   prob := -1;
//      Require at least two points in each graph
   if (na <= 2) or (nb <= 2) then
   begin
      ShowMessage('KolmogorovTest - Sets must have more than 2 points');
      exit;
   end;
//     Constants needed
   rna := na;
   rnb := nb;
   sa  := 1./rna;
   sb  := 1. / rnb;
//     Starting values for main loop
   if (a[0] < b[0]) then
   begin
      rdiff := -sa;
      ia := 2;
      ib := 1;
   end
   else
   begin
      rdiff := sb;
      ib := 2;
      ia := 1;
   end;
   rdmax := Abs(rdiff);

//    Main loop over point sets to find max distance
//    rdiff is the running difference, and rdmax the max.
   ok := FALSE;
   for i := 0 to na + nb - 1 do
   begin
      if (a[ia-1] < b[ib-1]) then
      begin
         rdiff := rdiff - sa;
         ia := ia + 1;
         if (ia > na) then
         begin
              ok := TRUE;
              break;
         end;
      end
      else if (a[ia-1] > b[ib-1]) then
      begin
         rdiff := rdiff + sb;
         ib := ib + 1;
         if (ib > nb) then
         begin
              ok := TRUE;
              break;
         end;
      end
      else
      begin
         x := a[ia-1];
         while((a[ia-1] = x) and (ia <= na)) do
         begin
            rdiff := rdiff - sa;
            ia := ia + 1;
         end;
         while ((b[ib-1] = x) and (ib <= nb)) do
         begin
            rdiff := rdiff + sb;
            ib := ib + 1;
         end;
         if (ia > na) then
         begin
              ok := TRUE;
              break;
         end;
         if (ib > nb) then
         begin
              ok := TRUE;
              break;
         end;
      end;
      rdmax := Max(rdmax,Abs(rdiff));
   end;
//    Should never terminate this loop with ok = kFALSE!

   if (ok) then
   begin
      rdmax := Max(rdmax,Abs(rdiff));
      z := rdmax * Sqrt(rna * rnb / (rna + rnb));
      prob := KolmogorovProb(z);
   end;

      // debug printout
   if (opt = 'D') then
      AReport.Add(' Kolmogorov Probability: %g, Max Dist: %g', [prob, rdmax]);
   if(opt = 'M') then
     result := rdmax
   else
     result := prob;
end;


procedure poisson_cdf ( x : integer; a : double; VAR cdf : double );
VAR
  i : integer;
  last, new1, sum2 : double;
begin
//
//*******************************************************************************
//
//// POISSON_CDF evaluates the Poisson CDF.
//
//
//  Definition:
//
//    CDF(X,A) is the probability that the number of events observed
//    in a unit time period will be no greater than X, given that the
//    expected number of events in a unit time period is A.
//
//  Modified:
//
//    28 January 1999
//
//  Author:
//
//    John Burkardt
//
//  Parameters:
//
//    Input, integer X, the argument of the CDF.
//    X >= 0.
//
//    Input, real A, the parameter of the PDF.
//    0.0E+00 < A.
//
//    Output, real CDF, the value of the CDF.
//
  if ( x < 0 ) then cdf := 0.0E+00
  else
  begin
    new1 := exp ( - a );
    sum2 := new1;
    for i := 1 to x do
    begin
      last := new1;
      new1 := last * a /  i ;
      sum2 := sum2 + new1;
    end;
    cdf := sum2;
  end;
end;

procedure poisson_cdf_values (VAR n : integer; VAR a : double; VAR x : integer;
                              VAR fx : double );
VAR
   avec : DblDyneVec;
   fxvec : DblDyneVec;
   xvec : IntDyneVec;
begin
   SetLength(avec,21);
   SetLength(fxvec,21);
   SetLength(xvec,21);
   avec[0] := 0.02e0;
   avec[1] := 0.10e0;
   avec[2] := 0.10e0;
   avec[3] := 0.50e0;
   avec[4] := 0.50e0;
   avec[5] := 0.50e0;
   avec[6] := 1.00e0;
   avec[7] := 1.00e0;
   avec[8] := 1.00e0;
   avec[9] := 1.00e0;
   avec[10] := 2.00e0;
   avec[11] := 2.00e0;
   avec[12] := 2.00e0;
   avec[13] := 2.00e0;
   avec[14] := 5.00E+00;
   avec[15] := 5.00E+00;
   avec[16] := 5.00E+00;
   avec[17] := 5.00E+00;
   avec[18] := 5.00E+00;
   avec[19] := 5.00E+00;
   avec[20] := 5.00E+00;
   fxvec[0] := 0.980E+00;
   fxvec[1] := 0.905E+00;
   fxvec[2] := 0.995E+00;
   fxvec[3] := 0.607E+00;
   fxvec[4] := 0.910E+00;
   fxvec[5] := 0.986E+00;
   fxvec[6] := 0.368E+00;
   fxvec[7] := 0.736E+00;
   fxvec[8] := 0.920E+00;
   fxvec[9] := 0.981E+00;
   fxvec[10] := 0.135E+00;
   fxvec[11] := 0.406E+00;
   fxvec[12] := 0.677E+00;
   fxvec[13] := 0.857E+00;
   fxvec[14] := 0.007E+00;
   fxvec[15] := 0.040E+00;
   fxvec[16] := 0.125E+00;
   fxvec[17] := 0.265E+00;
   fxvec[18] := 0.441E+00;
   fxvec[19] := 0.616E+00;
   fxvec[20] := 0.762E+00;
   xvec[0] := 0;
   xvec[1] := 0;
   xvec[2] := 1;
   xvec[3] := 0;
   xvec[4] := 1;
   xvec[5] := 2;
   xvec[6] := 0;
   xvec[7] := 1;
   xvec[8] := 2;
   xvec[9] := 3;
   xvec[10] := 0;
   xvec[11] := 1;
   xvec[12] := 2;
   xvec[13] := 3;
   xvec[14] := 0;
   xvec[15] := 1;
   xvec[16] := 2;
   xvec[17] := 3;
   xvec[18] := 4;
   xvec[19] := 5;
   xvec[20] := 6;

//
//*******************************************************************************
//
//// POISSON_CDF_VALUES returns some values of the Poisson CDF.
//
//
//  Discussion:
//
//    CDF(X)(A) is the probability of at most X successes in unit time,
//    given that the expected mean number of successes is A.
//
//  Modified:
//
//    28 May 2001
//
//  Reference:
//
//    Milton Abramowitz and Irene Stegun,
//    Handbook of Mathematical Functions,
//    US Department of Commerce, 1964.
//
//    Daniel Zwillinger,
//    CRC Standard Mathematical Tables and Formulae,
//    30th Edition, CRC Press, 1996, pages 653-658.
//
//  Author:
//
//    John Burkardt
//
//  Parameters:
//
//    Input/output, integer N.
//    On input, if N is 0, the first test data is returned, and N is set
//    to the index of the test data.  On each subsequent call, N is
//    incremented and that test data is returned.  When there is no more
//    test data, N is set to 0.
//
//    Output, real A, integer X, the arguments of the function.
//
//    Output, real FX, the value of the function.
//
//
  if ( n < 0 ) then n := 0;
  n := n + 1;
  if ( n > 21 ) then
  begin
    n := 0;
    a := 0.0;
    x := 0;
    fx := 0.0E+00;
    exit;
  end;

  a := avec[n];
  x := xvec[n];
  fx := fxvec[n];
  xvec := nil;
  fxvec := nil;
  avec := nil;
end;

procedure poisson_cdf_inv (VAR cdf : double; VAR a : double; VAR x : integer );
VAR
  i, xmax : integer;
  last, new1, sum2, sumold : double;
begin
//
//*******************************************************************************
//
//// POISSON_CDF_INV inverts the Poisson CDF.
//
//
//  Modified:
//
//    08 December 1999
//
//  Author:
//
//    John Burkardt
//
//  Parameters:
//
//    Input, real CDF, a value of the CDF.
//    0 <= CDF < 1.
//
//    Input, real A, the parameter of the PDF.
//    0.0E+00 < A.
//
//    Output, integer X, the corresponding argument.
//
//  Now simply start at X = 0, and find the first value for which
//  CDF(X-1) <= CDF <= CDF(X).
//
  xmax := 100;
  sum2 := 0.0E+00;
  for i := 0 to xmax do
  begin
    sumold := sum2;
    if ( i = 0 ) then
    begin
      new1 := exp ( - a );
      sum2 := new1;
    end
    else
    begin
      last := new1;
      new1 := last * a / i;
      sum2 := sum2 + new1;
    end;
    if (( sumold <= cdf) and (cdf <= sum2 )) then
    begin
      x := i;
      exit;
    end;
  end;
  ShowMessage('POISSON_SAMPLE - Warning. Exceeded XMAX = 100');
  x := xmax;
end;


procedure poisson_check ( a : double );
begin
//
//*******************************************************************************
//
//// POISSON_CHECK checks the parameter of the Poisson PDF.
//
//
//  Modified:
//
//    08 December 1999
//
//  Author:
//
//    John Burkardt
//
//  Parameters:
//
//    Input, real A, the parameter of the PDF.
//    0.0E+00 < A.
//
  if ( a <= 0.0E+00 ) then
     ShowMessage('POISSON_CHECK - Fatal error.  A <= 0.');
end;

function factorial(x : integer) : longint; //integer;
VAR
   decx : longint; // integer;
   product : longint; //integer;
begin
   decx := x;
   product := 1;
   while (decx > 0) do
   begin
        product := decx * product;
        decx := decx - 1;
   end;
   result := product;
end;


procedure poisson_pdf ( x : integer; VAR a : double; VAR pdf : double );
begin
//
//*******************************************************************************
//
//// POISSON_PDF evaluates the Poisson PDF.
//
//
//  Formula:
//
//    PDF(X)(A) = EXP ( - A ) * A**X / X//
//
//  Discussion:
//
//    PDF(X)(A) is the probability that the number of events observed
//    in a unit time period will be X, given the expected number
//    of events in a unit time.
//
//    The parameter A is the expected number of events per unit time.
//
//    The Poisson PDF is a discrete version of the Exponential PDF.
//
//    The time interval between two Poisson events is a random
//    variable with the Exponential PDF.
//
//  Modified:
//
//    01 February 1999
//
//  Author:
//
//    John Burkardt
//
//  Parameters:
//
//    Input, integer X, the argument of the PDF.
//    0 <= X
//
//    Input, real A, the parameter of the PDF.
//    0.0E+00 < A.
//
//    Output, real PDF, the value of the PDF.
//
  if ( x < 0 ) then pdf := 0.0E+00
  else
    pdf := exp ( - a ) * power(a,x) / factorial ( x );
//      pdf := exp ( - a ) * power(a,x) / exp(logfactorial( x ));
end;

end.

