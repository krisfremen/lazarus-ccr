================================================================================
Description and purpose
=======================
The Everett interpretation of quantum mechanics ("Many Worlds") is that when
an interaction is made with an elementary wave function (such as an electron or
photon etc) the universe bifurcates.
ref: https://en.wikipedia.org/wiki/Many-worlds_interpretation

This happens naturally of course (just via radioactive decays in atoms of your
body there are about 5000 bifucations per second) but this component brings into
the mix "Free Will".  By requesting a random number from the online source, which
is a beam-splitter based in Austrailia you are bifurcating the Universe deliberately
- that is, based on your Free Will.
You may or may not find that interesting, but nevertheless this component gives
you this ability (to "play God" with the Universe)

The random numbers returned are truly random (i.e. not pseudorandom via algorithm)

This package is a wrapper for querying a quantum number generator based in Austrailia.


Usage
=====
Open everettrandom.lpk and compile it.
In your application, include everettrandom as a required package
In a form unit:
In the Uses clause, add ueverettrandom

Code
====
Declare as a variable:  MyEverett: TEverett;
In form Create: MyEverett := TEverett.Create(Self);
If you don't want to show a dialog whilst querying the server:   MyEverett.ShowWaitDialog:=FALSE;

There are 3 functions that will retrieve a single integer:
// Fetch a single random number
function MyEverett.GetSingle8Bit: integer;
function MyEverett.GetSingle16Bit: integer;
function MyEverett.GetSingleHex: String;

// Array functions will put results into:
// (GetInteger8BitArray, GetInteger16BitArray) populates MyEverett.IntegerArray[0..Pred(ArraySize)]
// (GetHexArray) populates MyEverett.HexArray[0..Pred(ArraySize)]
// First set the properties:
// MyEverett.ArraySize (default=1)
//..and for Hex results
// MyEverett.HexSize (default=1)   e.g. 1=00->FF  2=0000->FFFF  3=000000->FFFFFF etc.
// Result for array functions is TRUE(Success) or FALSE(failure)
function MyEverett.GetInteger8BitArray:Boolean;
function MyEverett.GetInteger16BitArray:Boolean;
function MyEverett.GetHexArray:Boolean;

Demo
====
The Demo app shows the usage of everettrandom 