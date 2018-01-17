// Upgraded to Delphi 2009: Sebastian Zierer

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower SysTools
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 1996-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{*********************************************************}
{* SysTools: StUranus.pas 4.04                           *}
{*********************************************************}
{* SysTools: Astronomical Routines (for Uranus)          *}
{*********************************************************}

{$IFDEF FPC}
 {$mode DELPHI}
{$ENDIF}

//{$I StDefine.inc}

unit StUranus;

interface

uses
  StAstroP;

function ComputeUranus(JD : Double) : TStEclipticalCord;

implementation

function GetLongitude(Tau, Tau2, Tau3, Tau4, Tau5 : Double) : Double;
var
  L0, L1,
  L2, L3,
  L4, L5  : Double;
begin
  L0 := 5.48129294300 * cos(0.00000000000 +   0.00000000000 * Tau)
      + 0.09260408252 * cos(0.89106421530 +  74.78159856700 * Tau)
      + 0.01504247826 * cos(3.62719262190 +   1.48447270830 * Tau)
      + 0.00365981718 * cos(1.89962189070 +  73.29712585900 * Tau)
      + 0.00272328132 * cos(3.35823710520 + 149.56319713000 * Tau)
      + 0.00070328499 * cos(5.39254431990 +  63.73589830300 * Tau)
      + 0.00068892609 * cos(6.09292489050 +  76.26607127600 * Tau)
      + 0.00061998592 * cos(2.26952040470 +   2.96894541660 * Tau)
      + 0.00061950714 * cos(2.85098907570 +  11.04570026400 * Tau)
      + 0.00026468869 * cos(3.14152087890 +  71.81265315100 * Tau)
      + 0.00025710505 * cos(6.11379842940 + 454.90936653000 * Tau)
      + 0.00021078897 * cos(4.36059465140 + 148.07872443000 * Tau)
      + 0.00017818665 * cos(1.74436982540 +  36.64856292900 * Tau)
      + 0.00014613471 * cos(4.73732047980 +   3.93215326310 * Tau)
      + 0.00011162535 * cos(5.82681993690 + 224.34479570000 * Tau)
      + 0.00010997934 * cos(0.48865493179 + 138.51749687000 * Tau)
      + 0.00009527487 * cos(2.95516893090 +  35.16409022100 * Tau)
      + 0.00007545543 * cos(5.23626440670 + 109.94568879000 * Tau)
      + 0.00004220170 * cos(3.23328535510 +  70.84944530400 * Tau)
      + 0.00004051850 * cos(2.27754158720 + 151.04766984000 * Tau)
      + 0.00003490352 * cos(5.48305567290 + 146.59425172000 * Tau)
      + 0.00003354607 * cos(1.06549008890 +   4.45341812490 * Tau)
      + 0.00003144093 * cos(4.75199307600 +  77.75054398400 * Tau)
      + 0.00002926671 * cos(4.62903695490 +   9.56122755560 * Tau)
      + 0.00002922410 * cos(5.35236743380 +  85.82729883100 * Tau)
      + 0.00002272790 * cos(4.36600802760 +  70.32818044200 * Tau)
      + 0.00002148599 * cos(0.60745800902 +  38.13303563800 * Tau)
      + 0.00002051209 * cos(1.51773563460 +   0.11187458460 * Tau)
      + 0.00001991726 * cos(4.92437290830 + 277.03499374000 * Tau)
      + 0.00001666910 * cos(3.62744580850 + 380.12776796000 * Tau)
      + 0.00001533223 * cos(2.58593414270 +  52.69019803900 * Tau)
      + 0.00001376208 * cos(2.04281409050 +  65.22037101200 * Tau)
      + 0.00001372100 * cos(4.19641615560 + 111.43016150000 * Tau)
      + 0.00001284183 * cos(3.11346336880 + 202.25339517000 * Tau)
      + 0.00001281641 * cos(0.54269869505 + 222.86032299000 * Tau)
      + 0.00001244342 * cos(0.91612680579 +   2.44768055480 * Tau)
      + 0.00001220998 * cos(0.19901396193 + 108.46121608000 * Tau)
      + 0.00001150993 * cos(4.17898207050 +  33.67961751300 * Tau)
      + 0.00001150416 * cos(0.93344454002 +   3.18139373770 * Tau)
      + 0.00001090461 * cos(1.77501638910 +  12.53017297200 * Tau)
      + 0.00001072008 * cos(0.23564502877 +  62.25142559500 * Tau)
      + 0.00000946195 * cos(1.19249463070 + 127.47179661000 * Tau)
      + 0.00000707875 * cos(5.18285226580 + 213.29909544000 * Tau)
      + 0.00000653401 * cos(0.96586909116 +  78.71375183000 * Tau)
      + 0.00000627562 * cos(0.18210181975 + 984.60033162000 * Tau)
      + 0.00000606827 * cos(5.43209728950 + 529.69096509000 * Tau)
      + 0.00000559370 * cos(3.35776737700 +   0.52126486180 * Tau)
      + 0.00000524495 * cos(2.01276707000 + 299.12639427000 * Tau)
      + 0.00000483219 * cos(2.10553990150 +   0.96320784650 * Tau)
      + 0.00000471288 * cos(1.40664336450 + 184.72728736000 * Tau)
      + 0.00000467211 * cos(0.41484068933 + 145.10977901000 * Tau)
      + 0.00000433532 * cos(5.52142978260 + 183.24281465000 * Tau)
      + 0.00000404891 * cos(5.98689011390 +   8.07675484730 * Tau)
      + 0.00000398996 * cos(0.33810765436 + 415.55249061000 * Tau)
      + 0.00000395614 * cos(5.87039580950 + 351.81659231000 * Tau)
      + 0.00000378609 * cos(2.34975805010 +  56.62235130300 * Tau)
      + 0.00000309885 * cos(5.83301304670 + 145.63104387000 * Tau)
      + 0.00000300379 * cos(5.64353974150 +  22.09140052800 * Tau)
      + 0.00000294172 * cos(5.83916826230 +  39.61750834600 * Tau)
      + 0.00000251792 * cos(1.63696775580 + 221.37585029000 * Tau)
      + 0.00000249229 * cos(4.74617120580 + 225.82926841000 * Tau)
      + 0.00000239334 * cos(2.35045874710 + 137.03302416000 * Tau)
      + 0.00000224097 * cos(0.51574863468 +  84.34282612300 * Tau)
      + 0.00000222588 * cos(2.84309380330 +   0.26063243090 * Tau)
      + 0.00000219621 * cos(1.92212987980 +  67.66805156700 * Tau)
      + 0.00000216549 * cos(6.14211862700 +   5.93789083320 * Tau)
      + 0.00000216480 * cos(4.77847481360 + 340.77089205000 * Tau)
      + 0.00000207828 * cos(5.58020570040 +  68.84370773400 * Tau)
      + 0.00000201963 * cos(1.29693040860 +   0.04818410980 * Tau)
      + 0.00000199146 * cos(0.95634155010 + 152.53214255000 * Tau)
      + 0.00000193652 * cos(1.88800122610 + 456.39383924000 * Tau)
      + 0.00000192998 * cos(0.91616058506 + 453.42489382000 * Tau)
      + 0.00000187474 * cos(1.31924326250 +   0.16005869440 * Tau)
      + 0.00000181934 * cos(3.53624029240 +  79.23501669200 * Tau)
      + 0.00000173145 * cos(1.53860728050 + 160.60889740000 * Tau)
      + 0.00000171968 * cos(5.67952685530 + 219.89137758000 * Tau)
      + 0.00000170300 * cos(3.67717520690 +   5.41662597140 * Tau)
      + 0.00000168648 * cos(5.87874000880 +  18.15924726500 * Tau)
      + 0.00000164588 * cos(1.42379714840 + 106.97674337000 * Tau)
      + 0.00000162792 * cos(3.05029377670 + 112.91463421000 * Tau)
      + 0.00000158028 * cos(0.73811997211 +  54.17467074800 * Tau)
      + 0.00000146653 * cos(1.26300172260 +  59.80374504000 * Tau)
      + 0.00000143058 * cos(1.29995487560 +  35.42472265200 * Tau)
      + 0.00000139453 * cos(5.38597723400 +  32.19514480500 * Tau)
      + 0.00000138585 * cos(4.25994786670 + 909.81873305000 * Tau)
      + 0.00000123840 * cos(1.37359990340 +   7.11354700080 * Tau)
      + 0.00000110163 * cos(2.02685778980 + 554.06998748000 * Tau)
      + 0.00000109376 * cos(5.70581833290 +  77.96299230500 * Tau)
      + 0.00000104414 * cos(5.02820888810 +   0.75075952540 * Tau)
      + 0.00000103562 * cos(1.45770270250 +  24.37902238800 * Tau)
      + 0.00000103277 * cos(0.68095301267 +  14.97785352700 * Tau);

  L1 := 75.02543121600 * cos(0.00000000000 +   0.00000000000 * Tau)
      + 0.00154458244 * cos(5.24201658070 +  74.78159856700 * Tau)
      + 0.00024456413 * cos(1.71255705310 +   1.48447270830 * Tau)
      + 0.00009257828 * cos(0.42844639064 +  11.04570026400 * Tau)
      + 0.00008265977 * cos(1.50220035110 +  63.73589830300 * Tau)
      + 0.00007841715 * cos(1.31983607250 + 149.56319713000 * Tau)
      + 0.00003899105 * cos(0.46483574024 +   3.93215326310 * Tau)
      + 0.00002283777 * cos(4.17367534000 +  76.26607127600 * Tau)
      + 0.00001926600 * cos(0.53013080152 +   2.96894541660 * Tau)
      + 0.00001232727 * cos(1.58634458240 +  70.84944530400 * Tau)
      + 0.00000791206 * cos(5.43641224140 +   3.18139373770 * Tau)
      + 0.00000766954 * cos(1.99555409580 +  73.29712585900 * Tau)
      + 0.00000481671 * cos(2.98401996910 +  85.82729883100 * Tau)
      + 0.00000449798 * cos(4.13826237510 + 138.51749687000 * Tau)
      + 0.00000445600 * cos(3.72300400330 + 224.34479570000 * Tau)
      + 0.00000426554 * cos(4.73126059390 +  71.81265315100 * Tau)
      + 0.00000353752 * cos(2.58324496890 + 148.07872443000 * Tau)
      + 0.00000347735 * cos(2.45372261290 +   9.56122755560 * Tau)
      + 0.00000317084 * cos(5.57855232070 +  52.69019803900 * Tau)
      + 0.00000205585 * cos(2.36263144250 +   2.44768055480 * Tau)
      + 0.00000189068 * cos(4.20242881380 +  56.62235130300 * Tau)
      + 0.00000183762 * cos(0.28371004654 + 151.04766984000 * Tau)
      + 0.00000179920 * cos(5.68367730920 +  12.53017297200 * Tau)
      + 0.00000171084 * cos(3.00060075290 +  78.71375183000 * Tau)
      + 0.00000158029 * cos(2.90931969500 +   0.96320784650 * Tau)
      + 0.00000154670 * cos(5.59083925610 +   4.45341812490 * Tau)
      + 0.00000153515 * cos(4.65186885940 +  35.16409022100 * Tau)
      + 0.00000151984 * cos(2.94217326890 +  77.75054398400 * Tau)
      + 0.00000143464 * cos(2.59049246730 +  62.25142559500 * Tau)
      + 0.00000121452 * cos(4.14839204920 + 127.47179661000 * Tau)
      + 0.00000115546 * cos(3.73224603790 +  65.22037101200 * Tau)
      + 0.00000102022 * cos(4.18754517990 + 145.63104387000 * Tau)
      + 0.00000101718 * cos(6.03385875010 +   0.11187458460 * Tau)
      + 0.00000088202 * cos(3.99035787990 +  18.15924726500 * Tau)
      + 0.00000087549 * cos(6.15520787580 + 202.25339517000 * Tau)
      + 0.00000080530 * cos(2.64124743930 +  22.09140052800 * Tau)
      + 0.00000072047 * cos(6.04545933580 +  70.32818044200 * Tau)
      + 0.00000068570 * cos(4.05071895260 +  77.96299230500 * Tau)
      + 0.00000059173 * cos(3.70413919080 +  67.66805156700 * Tau)
      + 0.00000047267 * cos(3.54312460520 + 351.81659231000 * Tau)
      + 0.00000044339 * cos(5.90865821910 +   7.11354700080 * Tau)
      + 0.00000042534 * cos(5.72357370900 +   5.41662597140 * Tau)
      + 0.00000038544 * cos(4.91519003850 + 222.86032299000 * Tau)
      + 0.00000036116 * cos(5.89964278800 +  33.67961751300 * Tau)
      + 0.00000035605 * cos(3.29197259180 +   8.07675484730 * Tau)
      + 0.00000035524 * cos(3.32784616140 +  71.60020483000 * Tau)
      + 0.00000034996 * cos(5.08034112150 +  38.13303563800 * Tau)
      + 0.00000031454 * cos(5.62015632300 + 984.60033162000 * Tau)
      + 0.00000030811 * cos(5.49591403860 +  59.80374504000 * Tau)
      + 0.00000030608 * cos(5.46414592600 + 160.60889740000 * Tau)
      + 0.00000029866 * cos(1.65980844670 + 447.79581953000 * Tau)
      + 0.00000029206 * cos(1.14722640420 + 462.02291353000 * Tau)
      + 0.00000028947 * cos(4.51867390410 +  84.34282612300 * Tau)
      + 0.00000026627 * cos(5.54127301040 + 131.40394987000 * Tau)
      + 0.00000026605 * cos(6.14640604130 + 299.12639427000 * Tau)
      + 0.00000025753 * cos(4.99362028420 + 137.03302416000 * Tau)
      + 0.00000025373 * cos(5.73584678600 + 380.12776796000 * Tau);

  L2 := 0.00053033277 * cos(0.00000000000 +   0.00000000000 * Tau)
      + 0.00002357636 * cos(2.26014661700 +  74.78159856700 * Tau)
      + 0.00000769129 * cos(4.52561041820 +  11.04570026400 * Tau)
      + 0.00000551533 * cos(3.25814281020 +  63.73589830300 * Tau)
      + 0.00000541532 * cos(2.27573907420 +   3.93215326310 * Tau)
      + 0.00000529473 * cos(4.92348433830 +   1.48447270830 * Tau)
      + 0.00000257521 * cos(3.69059216860 +   3.18139373770 * Tau)
      + 0.00000238835 * cos(5.85806638400 + 149.56319713000 * Tau)
      + 0.00000181904 * cos(6.21763603410 +  70.84944530400 * Tau)
      + 0.00000053504 * cos(1.44225240950 +  76.26607127600 * Tau)
      + 0.00000049401 * cos(6.03101301720 +  56.62235130300 * Tau)
      + 0.00000044753 * cos(3.90904910520 +   2.44768055480 * Tau)
      + 0.00000044530 * cos(0.81152639478 +  85.82729883100 * Tau)
      + 0.00000038222 * cos(1.78467827780 +  52.69019803900 * Tau)
      + 0.00000037403 * cos(4.46228598030 +   2.96894541660 * Tau)
      + 0.00000033029 * cos(0.86388149962 +   9.56122755560 * Tau)
      + 0.00000029423 * cos(5.09818697710 +  73.29712585900 * Tau)
      + 0.00000024292 * cos(2.10702559050 +  18.15924726500 * Tau)
      + 0.00000022491 * cos(5.99320728690 + 138.51749687000 * Tau)
      + 0.00000022135 * cos(4.81730808580 +  78.71375183000 * Tau)
      + 0.00000021392 * cos(2.39880709310 +  77.96299230500 * Tau)
      + 0.00000020578 * cos(2.16918786540 + 224.34479570000 * Tau)
      + 0.00000017226 * cos(2.53537183200 + 145.63104387000 * Tau)
      + 0.00000016777 * cos(3.46631344090 +  12.53017297200 * Tau)
      + 0.00000012012 * cos(0.01941361902 +  22.09140052800 * Tau)
      + 0.00000011010 * cos(0.08496274370 + 127.47179661000 * Tau)
      + 0.00000010476 * cos(5.16453084070 +  71.60020483000 * Tau)
      + 0.00000010466 * cos(4.45556032590 +  62.25142559500 * Tau)
      + 0.00000008668 * cos(4.25550086980 +   7.11354700080 * Tau)
      + 0.00000008387 * cos(5.50115930050 +  67.66805156700 * Tau)
      + 0.00000007160 * cos(1.24903906390 +   5.41662597140 * Tau)
      + 0.00000006109 * cos(3.36320161280 + 447.79581953000 * Tau)
      + 0.00000006087 * cos(5.44611674380 +  65.22037101200 * Tau)
      + 0.00000006013 * cos(4.51836836350 + 151.04766984000 * Tau)
      + 0.00000006003 * cos(5.72500086740 + 462.02291353000 * Tau);

  L3 := 0.00000120936 * cos(0.02418789918 +  74.78159856700 * Tau)
      + 0.00000068064 * cos(4.12084267730 +   3.93215326310 * Tau)
      + 0.00000052828 * cos(2.38964061260 +  11.04570026400 * Tau)
      + 0.00000045806 * cos(0.00000000000 +   0.00000000000 * Tau)
      + 0.00000045300 * cos(2.04423798410 +   3.18139373770 * Tau)
      + 0.00000043754 * cos(2.95965039730 +   1.48447270830 * Tau)
      + 0.00000024969 * cos(4.88741307920 +  63.73589830300 * Tau)
      + 0.00000021061 * cos(4.54511486860 +  70.84944530400 * Tau)
      + 0.00000019897 * cos(2.31320314140 + 149.56319713000 * Tau)
      + 0.00000008901 * cos(1.57548871760 +  56.62235130300 * Tau)
      + 0.00000004271 * cos(0.22777319552 +  18.15924726500 * Tau)
      + 0.00000003613 * cos(5.39244611310 +  76.26607127600 * Tau)
      + 0.00000003572 * cos(0.95052448578 +  77.96299230500 * Tau)
      + 0.00000003488 * cos(4.97622811780 +  85.82729883100 * Tau)
      + 0.00000003479 * cos(4.12969359980 +  52.69019803900 * Tau)
      + 0.00000002696 * cos(0.37287796344 +  78.71375183000 * Tau)
      + 0.00000002328 * cos(0.85770961794 + 145.63104387000 * Tau)
      + 0.00000002156 * cos(5.65647821520 +   9.56122755560 * Tau);

  L4 := 0.00000113855 * cos(3.14159265360 +   0.00000000000 * Tau)
      + 0.00000005599 * cos(4.57882424420 +  74.78159856700 * Tau)
      + 0.00000003203 * cos(0.34623003207 +  11.04570026400 * Tau)
      + 0.00000001217 * cos(3.42199121830 +  56.62235130300 * Tau);

  L5 := 0.00000000000;
  Result := (L0 + L1*Tau + L2*Tau2 + L3*Tau3 + L4*Tau4 + L5*Tau5);
end;

{---------------------------------------------------------------------------}

function GetLatitude(Tau, Tau2, Tau3, Tau4, Tau5 : Double) : Double;
var
  B0, B1,
  B2, B3,
  B4, B5  : Double;
begin
  B0 := 0.01346277639 * cos(2.61877810550 +  74.78159856700 * Tau)
      + 0.00062341405 * cos(5.08111175860 + 149.56319713000 * Tau)
      + 0.00061601203 * cos(3.14159265360 +   0.00000000000 * Tau)
      + 0.00009963744 * cos(1.61603876360 +  76.26607127600 * Tau)
      + 0.00009926151 * cos(0.57630387917 +  73.29712585900 * Tau)
      + 0.00003259455 * cos(1.26119385960 + 224.34479570000 * Tau)
      + 0.00002972318 * cos(2.24367035540 +   1.48447270830 * Tau)
      + 0.00002010257 * cos(6.05550401090 + 148.07872443000 * Tau)
      + 0.00001522172 * cos(0.27960386377 +  63.73589830300 * Tau)
      + 0.00000924055 * cos(4.03822927850 + 151.04766984000 * Tau)
      + 0.00000760624 * cos(6.14000431920 +  71.81265315100 * Tau)
      + 0.00000522309 * cos(3.32085194770 + 138.51749687000 * Tau)
      + 0.00000462630 * cos(0.74256727574 +  85.82729883100 * Tau)
      + 0.00000436843 * cos(3.38082524320 + 529.69096509000 * Tau)
      + 0.00000434625 * cos(0.34065281858 +  77.75054398400 * Tau)
      + 0.00000430668 * cos(3.55445034850 + 213.29909544000 * Tau)
      + 0.00000420265 * cos(5.21279984790 +  11.04570026400 * Tau)
      + 0.00000244698 * cos(0.78795150326 +   2.96894541660 * Tau)
      + 0.00000232649 * cos(2.25716421380 + 222.86032299000 * Tau)
      + 0.00000215838 * cos(1.59121704940 +  38.13303563800 * Tau)
      + 0.00000179935 * cos(3.72487952670 + 299.12639427000 * Tau)
      + 0.00000174895 * cos(1.23550262210 + 146.59425172000 * Tau)
      + 0.00000173667 * cos(1.93654269130 + 380.12776796000 * Tau)
      + 0.00000160368 * cos(5.33635436460 + 111.43016150000 * Tau)
      + 0.00000144064 * cos(5.96239326410 +  35.16409022100 * Tau)
      + 0.00000116363 * cos(5.73877190010 +  70.84944530400 * Tau)
      + 0.00000106441 * cos(0.94103112994 +  70.32818044200 * Tau)
      + 0.00000102049 * cos(2.61876256510 +  78.71375183000 * Tau);

  B1 := 0.00206366162 * cos(4.12394311410 +  74.78159856700 * Tau)
      + 0.00008563230 * cos(0.33819986165 + 149.56319713000 * Tau)
      + 0.00001725703 * cos(2.12193159900 +  73.29712585900 * Tau)
      + 0.00001374449 * cos(0.00000000000 +   0.00000000000 * Tau)
      + 0.00001368860 * cos(3.06861722050 +  76.26607127600 * Tau)
      + 0.00000450639 * cos(3.77656180980 +   1.48447270830 * Tau)
      + 0.00000399847 * cos(2.84767037790 + 224.34479570000 * Tau)
      + 0.00000307214 * cos(1.25456766740 + 148.07872443000 * Tau)
      + 0.00000154336 * cos(3.78575467750 +  63.73589830300 * Tau)
      + 0.00000112432 * cos(5.57299891500 + 151.04766984000 * Tau)
      + 0.00000110888 * cos(5.32888676460 + 138.51749687000 * Tau)
      + 0.00000083493 * cos(3.59152795560 +  71.81265315100 * Tau)
      + 0.00000055573 * cos(3.40135416350 +  85.82729883100 * Tau)
      + 0.00000053690 * cos(1.70455769940 +  77.75054398400 * Tau)
      + 0.00000041912 * cos(1.21476607430 +  11.04570026400 * Tau)
      + 0.00000041377 * cos(4.45476669140 +  78.71375183000 * Tau)
      + 0.00000031959 * cos(3.77446207750 + 222.86032299000 * Tau)
      + 0.00000030297 * cos(2.56371683640 +   2.96894541660 * Tau)
      + 0.00000026977 * cos(5.33695500290 + 213.29909544000 * Tau)
      + 0.00000026222 * cos(0.41620628369 + 380.12776796000 * Tau);

  B2 := 0.00009211656 * cos(5.80044305790 +  74.78159856700 * Tau)
      + 0.00000556926 * cos(0.00000000000 +   0.00000000000 * Tau)
      + 0.00000286265 * cos(2.17729776350 + 149.56319713000 * Tau)
      + 0.00000094969 * cos(3.84237569810 +  73.29712585900 * Tau)
      + 0.00000045419 * cos(4.87822046060 +  76.26607127600 * Tau)
      + 0.00000020107 * cos(5.46264485370 +   1.48447270830 * Tau)
      + 0.00000014793 * cos(0.87983715652 + 138.51749687000 * Tau)
      + 0.00000014261 * cos(2.84517742690 + 148.07872443000 * Tau)
      + 0.00000013963 * cos(5.07234043990 +  63.73589830300 * Tau)
      + 0.00000010122 * cos(5.00290894860 + 224.34479570000 * Tau)
      + 0.00000008299 * cos(6.26655615200 +  78.71375183000 * Tau);

  B3 := 0.00000267832 * cos(1.25097888290 +  74.78159856700 * Tau)
      + 0.00000011048 * cos(3.14159265360 +   0.00000000000 * Tau)
      + 0.00000006154 * cos(4.00663614490 + 149.56319713000 * Tau)
      + 0.00000003361 * cos(5.77804694940 +  73.29712585900 * Tau);

  B4 := 0.00000005719 * cos(2.85499529310 +  74.78159856700 * Tau);

  B5 := 0.00000000000;
  Result := (B0 + B1*Tau + B2*Tau2 + B3*Tau3 + B4*Tau4 + B5*Tau5);
end;

{---------------------------------------------------------------------------}

function GetRadiusVector(Tau, Tau2, Tau3, Tau4, Tau5 : Double) : Double;
var
  R0, R1,
  R2, R3,
  R4, R5  : Double;
begin
  R0 := 19.21264847900 * cos(0.00000000000 +   0.00000000000 * Tau)
      + 0.88784984055 * cos(5.60377526990 +   74.78159856700 * Tau)
      + 0.03440835545 * cos(0.32836098991 +   73.29712585900 * Tau)
      + 0.02055653495 * cos(1.78295170030 +  149.56319713000 * Tau)
      + 0.00649321851 * cos(4.52247298120 +   76.26607127600 * Tau)
      + 0.00602248144 * cos(3.86003820460 +   63.73589830300 * Tau)
      + 0.00496404171 * cos(1.40139934720 +  454.90936653000 * Tau)
      + 0.00338525522 * cos(1.58002682950 +  138.51749687000 * Tau)
      + 0.00243508222 * cos(1.57086595070 +   71.81265315100 * Tau)
      + 0.00190521915 * cos(1.99809364500 +    1.48447270830 * Tau)
      + 0.00161858251 * cos(2.79137863470 +  148.07872443000 * Tau)
      + 0.00143705902 * cos(1.38368574480 +   11.04570026400 * Tau)
      + 0.00093192359 * cos(0.17437193645 +   36.64856292900 * Tau)
      + 0.00089805842 * cos(3.66105366330 +  109.94568879000 * Tau)
      + 0.00071424265 * cos(4.24509327400 +  224.34479570000 * Tau)
      + 0.00046677322 * cos(1.39976563940 +   35.16409022100 * Tau)
      + 0.00039025681 * cos(3.36234710690 +  277.03499374000 * Tau)
      + 0.00039009624 * cos(1.66971128870 +   70.84944530400 * Tau)
      + 0.00036755160 * cos(3.88648934740 +  146.59425172000 * Tau)
      + 0.00030348875 * cos(0.70100446346 +  151.04766984000 * Tau)
      + 0.00029156264 * cos(3.18056174560 +   77.75054398400 * Tau)
      + 0.00025785805 * cos(3.78537741500 +   85.82729883100 * Tau)
      + 0.00025620360 * cos(5.25656292800 +  380.12776796000 * Tau)
      + 0.00022637152 * cos(0.72519137745 +  529.69096509000 * Tau)
      + 0.00020473163 * cos(2.79639811630 +   70.32818044200 * Tau)
      + 0.00020471584 * cos(1.55588961500 +  202.25339517000 * Tau)
      + 0.00017900561 * cos(0.55455488605 +    2.96894541660 * Tau)
      + 0.00015502809 * cos(5.35405037600 +   38.13303563800 * Tau)
      + 0.00014701566 * cos(4.90434406650 +  108.46121608000 * Tau)
      + 0.00012896507 * cos(2.62154018240 +  111.43016150000 * Tau)
      + 0.00012328151 * cos(5.96039150920 +  127.47179661000 * Tau)
      + 0.00011959355 * cos(1.75044072170 +  984.60033162000 * Tau)
      + 0.00011852996 * cos(0.99342814582 +   52.69019803900 * Tau)
      + 0.00011696085 * cos(3.29825599110 +    3.93215326310 * Tau)
      + 0.00011494701 * cos(0.43774027872 +   65.22037101200 * Tau)
      + 0.00010792699 * cos(1.42104858470 +  213.29909544000 * Tau)
      + 0.00009111446 * cos(4.99638600050 +   62.25142559500 * Tau)
      + 0.00008420550 * cos(5.25350716620 +  222.86032299000 * Tau)
      + 0.00008402147 * cos(5.03877516490 +  415.55249061000 * Tau)
      + 0.00007449125 * cos(0.79491905956 +  351.81659231000 * Tau)
      + 0.00007329454 * cos(3.97277527840 +  183.24281465000 * Tau)
      + 0.00006046370 * cos(5.67960948360 +   78.71375183000 * Tau)
      + 0.00005524133 * cos(3.11499484160 +    9.56122755560 * Tau)
      + 0.00005444878 * cos(5.10575635360 +  145.10977901000 * Tau)
      + 0.00005238103 * cos(2.62960141800 +   33.67961751300 * Tau)
      + 0.00004079167 * cos(3.22064788670 +  340.77089205000 * Tau)
      + 0.00003919476 * cos(4.25015288870 +   39.61750834600 * Tau)
      + 0.00003801606 * cos(6.10985558500 +  184.72728736000 * Tau)
      + 0.00003781219 * cos(3.45840272870 +  456.39383924000 * Tau)
      + 0.00003686787 * cos(2.48718116540 +  453.42489382000 * Tau)
      + 0.00003101743 * cos(4.14031063900 +  219.89137758000 * Tau)
      + 0.00002962641 * cos(0.82977991995 +   56.62235130300 * Tau)
      + 0.00002942239 * cos(0.42393808854 +  299.12639427000 * Tau)
      + 0.00002940492 * cos(2.14637460320 +  137.03302416000 * Tau)
      + 0.00002937799 * cos(3.67657450930 +  140.00196958000 * Tau)
      + 0.00002865128 * cos(0.30996903761 +   12.53017297200 * Tau)
      + 0.00002538032 * cos(4.85457831990 +  131.40394987000 * Tau)
      + 0.00002363550 * cos(0.44253328372 +  554.06998748000 * Tau)
      + 0.00002182572 * cos(2.94040431640 +  305.34616939000 * Tau);

  R1 := 0.01479896370 * cos(3.67205705320 +  74.78159856700 * Tau)
      + 0.00071212085 * cos(6.22601006670 +  63.73589830300 * Tau)
      + 0.00068626972 * cos(6.13411265050 + 149.56319713000 * Tau)
      + 0.00024059649 * cos(3.14159265360 +   0.00000000000 * Tau)
      + 0.00021468152 * cos(2.60176704270 +  76.26607127600 * Tau)
      + 0.00020857262 * cos(5.24625494220 +  11.04570026400 * Tau)
      + 0.00011405346 * cos(0.01848461561 +  70.84944530400 * Tau)
      + 0.00007496775 * cos(0.42360033283 +  73.29712585900 * Tau)
      + 0.00004243800 * cos(1.41692350370 +  85.82729883100 * Tau)
      + 0.00003926694 * cos(3.15513991320 +  71.81265315100 * Tau)
      + 0.00003578446 * cos(2.31160668310 + 224.34479570000 * Tau)
      + 0.00003505936 * cos(2.58354048850 + 138.51749687000 * Tau)
      + 0.00003228835 * cos(5.25499602900 +   3.93215326310 * Tau)
      + 0.00003060010 * cos(0.15321893225 +   1.48447270830 * Tau)
      + 0.00002564251 * cos(0.98076846352 + 148.07872443000 * Tau)
      + 0.00002429445 * cos(3.99440122470 +  52.69019803900 * Tau)
      + 0.00001644719 * cos(2.65349313120 + 127.47179661000 * Tau)
      + 0.00001583766 * cos(1.43045619200 +  78.71375183000 * Tau)
      + 0.00001508028 * cos(5.05996325430 + 151.04766984000 * Tau)
      + 0.00001489525 * cos(2.67559167320 +  56.62235130300 * Tau)
      + 0.00001413112 * cos(4.57461892060 + 202.25339517000 * Tau)
      + 0.00001403237 * cos(1.36985349740 +  77.75054398400 * Tau)
      + 0.00001228220 * cos(1.04703640150 +  62.25142559500 * Tau)
      + 0.00001032731 * cos(0.26459059027 + 131.40394987000 * Tau)
      + 0.00000992085 * cos(2.17168865910 +  65.22037101200 * Tau)
      + 0.00000861867 * cos(5.05530802220 + 351.81659231000 * Tau)
      + 0.00000744445 * cos(3.07640148940 +  35.16409022100 * Tau)
      + 0.00000687470 * cos(2.49912565670 +  77.96299230500 * Tau)
      + 0.00000646851 * cos(4.47290422910 +  70.32818044200 * Tau)
      + 0.00000623602 * cos(0.86253073820 +   9.56122755560 * Tau)
      + 0.00000604362 * cos(0.90717667985 + 984.60033162000 * Tau)
      + 0.00000574710 * cos(3.23070708460 + 447.79581953000 * Tau)
      + 0.00000561839 * cos(2.71778158980 + 462.02291353000 * Tau)
      + 0.00000530364 * cos(5.91655309050 + 213.29909544000 * Tau)
      + 0.00000527794 * cos(5.15136007080 +   2.96894541660 * Tau);

  R2 := 0.00022439904 * cos(0.69953118760 +  74.78159856700 * Tau)
      + 0.00004727037 * cos(1.69901641490 +  63.73589830300 * Tau)
      + 0.00001681903 * cos(4.64833551730 +  70.84944530400 * Tau)
      + 0.00001649559 * cos(3.09660078980 +  11.04570026400 * Tau)
      + 0.00001433755 * cos(3.52119917950 + 149.56319713000 * Tau)
      + 0.00000770188 * cos(0.00000000000 +   0.00000000000 * Tau)
      + 0.00000500429 * cos(6.17229032220 +  76.26607127600 * Tau)
      + 0.00000461009 * cos(0.76676632849 +   3.93215326310 * Tau)
      + 0.00000390371 * cos(4.49605283500 +  56.62235130300 * Tau)
      + 0.00000389945 * cos(5.52673426380 +  85.82729883100 * Tau)
      + 0.00000292097 * cos(0.20389012095 +  52.69019803900 * Tau)
      + 0.00000286579 * cos(3.53357683270 +  73.29712585900 * Tau)
      + 0.00000272898 * cos(3.84707823650 + 138.51749687000 * Tau)
      + 0.00000219674 * cos(1.96418942890 + 131.40394987000 * Tau)
      + 0.00000215788 * cos(0.84812474187 +  77.96299230500 * Tau)
      + 0.00000205449 * cos(3.24758017120 +  78.71375183000 * Tau)
      + 0.00000148554 * cos(4.89840863840 + 127.47179661000 * Tau)
      + 0.00000128834 * cos(2.08146849520 +   3.18139373770 * Tau);

  R3 := 0.00001164382 * cos(4.73453291600 +  74.78159856700 * Tau)
      + 0.00000212367 * cos(3.34255735000 +  63.73589830300 * Tau)
      + 0.00000196408 * cos(2.98004616320 +  70.84944530400 * Tau)
      + 0.00000104527 * cos(0.95807937648 +  11.04570026400 * Tau)
      + 0.00000072540 * cos(0.99701907912 + 149.56319713000 * Tau)
      + 0.00000071681 * cos(0.02528455665 +  56.62235130300 * Tau)
      + 0.00000054875 * cos(2.59436811270 +   3.93215326310 * Tau)
      + 0.00000036377 * cos(5.65035573020 +  77.96299230500 * Tau)
      + 0.00000034029 * cos(3.81553325640 +  76.26607127600 * Tau)
      + 0.00000032081 * cos(3.59825177840 + 131.40394987000 * Tau);

  R4 := 0.00000052996 * cos(3.00838033090 +  74.78159856700 * Tau)
      + 0.00000009887 * cos(1.91399083600 +  56.62235130300 * Tau);

  R5 := 0.00000000000;
  Result := (R0 + R1*Tau + R2*Tau2 + R3*Tau3 + R4*Tau4 + R5*Tau5);
end;

{---------------------------------------------------------------------------}

function ComputeUranus(JD : Double) : TStEclipticalCord;
var
  Tau,
  Tau2,
  Tau3,
  Tau4,
  Tau5      : Double;
begin
  Tau  := (JD - 2451545.0) / 365250.0;
  Tau2 := sqr(Tau);
  Tau3 := Tau * Tau2;
  Tau4 := sqr(Tau2);
  Tau5 := Tau2 * Tau3;

  Result.L0 := GetLongitude(Tau, Tau2, Tau3, Tau4, Tau5);
  Result.B0 := GetLatitude(Tau, Tau2, Tau3, Tau4, Tau5);
  Result.R0 := GetRadiusVector(Tau, Tau2, Tau3, Tau4, Tau5);
end;


end.
