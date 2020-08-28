unit MathUnit;

{ extract some math functions from functionslib for easier testing }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function erf(x: Double): Double;
function erfc(x: Double) : Double;
function NormalDist(x: Double): Double;

function Beta(a, b: Double): Extended;
function BetaI(a,b,x: Double): Extended;

function GammaLn(x: double): Extended;

function tDist(x: Double; N: Integer; OneSided: Boolean): Double;
function tDensity(x: Double; N: Integer): Double;

function FDensity(x: Double; DF1, DF2: Integer): Double;

function Chi2Density(x: Double; N: Integer): Double;

implementation

uses
  Math;

// Calculates the error function
//                              /x
//       erf(x) = 2/sqrt(pi) * | exp(-t²) dt
//                            /0
// borrowed from NumLib
function erf(x: Double): Double;
const
  xup = 6.25;
  SQRT_PI = 1.7724538509055160;
  c: array[1..18] of Double = (
       1.9449071068178803e0,  4.20186582324414e-2, -1.86866103976769e-2,
       5.1281061839107e-3,   -1.0683107461726e-3,   1.744737872522e-4,
      -2.15642065714e-5,      1.7282657974e-6,     -2.00479241e-8,
      -1.64782105e-8,         2.0008475e-9,         2.57716e-11,
      -3.06343e-11,           1.9158e-12,           3.703e-13,
      -5.43e-14,             -4.0e-15,              1.2e-15
  );
  d: array[1..17] of Double = (
       1.4831105640848036e0, -3.010710733865950e-1, 6.89948306898316e-2,
      -1.39162712647222e-2,   2.4207995224335e-3,  -3.658639685849e-4,
       4.86209844323e-5,     -5.7492565580e-6,      6.113243578e-7,
      -5.89910153e-8,         5.2070091e-9,        -4.232976e-10,
       3.18811e-11,          -2.2361e-12,           1.467e-13,
      -9.0e-15,               5.0e-16
  );
var
  t, s, s1, s2, x2: Double;
  bovc, bovd, j: Integer;
  sgn: Integer;
begin
  bovc := SizeOf(c) div SizeOf(Double);
  bovd := SizeOf(d) div SizeOf(Double);
  t := abs(x);
  if t <= 2 then
  begin
    x2 := sqr(x) - 2;
    s1 := d[bovd];
    s2 := 0;
    j := bovd - 1;
    s := x2*s1 - s2 + d[j];
    while j > 1 do
    begin
      s2 := s1;
      s1 := s;
      j := j-1;
      s := x2*s1 - s2 + d[j];
    end;
    Result := (s - s2) * x / 2;
  end else
  if t < xup then
  begin
    x2 := 2 - 20 / (t+3);
    s1 := c[bovc];
    s2 := 0;
    j := bovc - 1;
    s := x2*s1 - s2 + c[j];
    while j > 1 do
    begin
      s2 := s1;
      s1 := s;
      j := j-1;
      s := x2*s1 - s2 + c[j];
    end;
    x2 := ((s-s2) / (2*t)) * exp(-sqr(x)) / SQRT_PI;
    if x < 0 then sgn := -1 else sgn := +1;
    Result := (1 - x2) * sgn
  end
  else
  if x < 0 then
    Result := -1.0
  else
    Result := +1.0;
end;


{ calculates the complementary error function erfc(x) = 1 - erf(x) }
function erfc(x: Double) : Double;
begin
  Result := 1.0 - erf(x);
end;


// Cumulative normal distribution
// x = -INF ... INF --> 0 ... 1
function NormalDist(x: Double): Double;
const
  SQRT2 = sqrt(2.0);
begin
  if x > 0 then
    Result := (erf(x / SQRT2) + 1) * 0.5
  else
  if x < 0 then
    Result := (1.0 - erf(-x / SQRT2)) * 0.5
  else
    Result := 0;
end;


function Beta(a, b: Double): Extended;
begin
  if (a > 0) and (b > 0) then
    Result := exp(GammaLn(a) + GammaLn(b) - GammaLn(a+b))
  else
    raise Exception.Create('Invalid argument for beta function.');
end;

function BetaCF(a, b, x: double): Extended;
const
  itmax = 100;
  eps = 3.0e-7;
var
  tem,qap,qam,qab,em,d: extended;
  bz,bpp,bp,bm,az,app: extended;
  am,aold,ap: extended;
  term1, term2, term3, term4, term5, term6: extended;
  m: integer;
BEGIN
  am := 1.0;
  bm := 1.0;
  az := 1.0;
  qab := a+b;
  qap := a+1.0;
  qam := a-1.0;
  bz := 1.0 - qab * x / qap;
  for m := 1 to itmax do begin
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
    if ((abs(az-aold)) < (eps*abs(az))) then
      Break;
  end;

  { ShowMessage('WARNING! a or b too big, or itmax too small in betacf');}
  Result := az
end;

function BetaI(a,b,x: Double): extended;
var
  bt: extended;
  term1, term2, term3, term4, term5: extended;
begin
  if ((x < 0.0) or (x > 1.0)) then begin
     { ShowMessage('ERROR! Problem in routine BETAI');}
    Result := 0.5;
    exit;
  end;

  if ((x <= 0.0) or (x >= 1.0)) then
    bt := 0.0
  else
  begin
    term1 := GammaLn(a + b) - GammaLn(a) - GammaLn(b);
    term2 := a * ln(x);
    term3 := b * ln(1.0 - x);
    term4 := term1 + term2 + term3;
    bt    := exp(term4);
  end;
  term5 := (a + 1.0) / (a + b + 2.0);
  if x < term5 then
    Result := bt * betacf(a,b,x) / a
  else
    Result := 1.0 - bt * betacf(b,a,1.0-x) / b
end;

function GammaLn(x: double): Extended;
var
  tmp, ser: double;
  cof: array[0..5] of double;
  j: integer;
begin
   cof[0] := 76.18009173;
   cof[1] := -86.50532033;
   cof[2] := 24.01409822;
   cof[3] := -1.231739516;
   cof[4] := 0.00120858003;
   cof[5] := -0.00000536382;

   x := x - 1.0;
   tmp := x + 5.5;
   tmp := tmp - (x + 0.5) * ln(tmp);
   ser := 1.0;
   for j := 0 to 5 do
   begin
     x := x + 1.0;
     ser := ser + cof[j] / x;
   end;
   Result := -tmp + ln(2.50662827465 * ser);
end;

// Calculates the (cumulative) t distribution function for N degrees of freedom
function tDist(x: Double; N: Integer; OneSided: Boolean): Double;
begin
  Result :=  betai(0.5*N, 0.5, N/(N + sqr(x)));
  if OneSided then Result := Result * 0.5;
end;

// Returns the density curve for the t statistic with N degrees of freedom
function tDensity(x: Double; N: Integer): Double;
var
  factor: Double;
begin
  factor := exp(gammaLn((N+1)/2) - gammaLn(N/2)) / sqrt(N * pi);
  Result := factor * Power(1 + sqr(x)/N, (1-n)/2);
end;

// Returns the density curve for the F statistic for DF1 and DF2 degrees of freedom.
function FDensity(x: Double; DF1, DF2: Integer): Double;
var
  ratio1, ratio2, ratio3, ratio4: double;
  part1, part2, part3, part4, part5, part6, part7, part8, part9: double;
begin
  ratio1 := (DF1 + DF2) / 2.0;
  ratio2 := (DF1 - 2.0) / 2.0;
  ratio3 := DF1 / 2.0;
  ratio4 := DF2 / 2.0;
  part1 := exp(gammaln(ratio1));
  part2 := power(DF1, ratio3);
  part3 := power(DF2, ratio4);
  part4 := exp(gammaln(ratio3));
  part5 := exp(gammaln(ratio4));
  part6 := power(x, ratio2);
  part7 := power((x*DF1 + DF2), ratio1);
  part8 := (part1 * part2 * part3) / (part4 * part5);
  if (part7 = 0.0) then
    part9 := 0.0
  else
    part9 := part6 / part7;
  Result := part8 * part9;
end;


// Returns the density curve of the chi2 statistic for N degrees of freedom
function Chi2Density(x: Double; N: Integer): Double;
var
  factor: Double;
begin
  factor := Power(2.0, N * 0.5) * exp(gammaLN(N * 0.5));
  Result := power(x, (N-2.0) * 0.5) / (factor * exp(x * 0.5));
end;

end.

