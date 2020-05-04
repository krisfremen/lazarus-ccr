unit Globals; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;

const TOL = 0.0005;

Type IntDyneVec = array of integer;

Type DblDyneVec = array of double;

Type BoolDyneVec = array of boolean;

Type DblDyneMat  = array of array of double;

Type IntDyneMat = array of array of integer;

Type DblDyneCube = array of array of array of double;

Type IntDyneCube = array of array of array of integer;

Type DblDyneQuad = array of array of array of array of double;

Type IntDyneQuad = array of array of array of array of integer;

Type StrDyneVec  = array of string;

Type StrDyneMat = array of array of string;

Type CharDyneVec = array of char;

type POINT3D = record
  x, y, z : double;
end;

Type POINTint = record
  x, y : integer;
end;

type
  TFractionType = (ftPoint, ftComma);
  TMissingValueCode = (mvcSpace, mvcPeriod, mvcZero, mvcNines);
  TJustification = (jLeft, jCenter, jRight);

  TOptions = record
    DefaultPath: string;
    FractionType: TFractionType;
    DefaultMiss: TMissingValueCode;
    DefaultJust: TJustification;
  end;

var
  NoCases : integer;
  NoVariables : integer;
  VarDefined : array[0..500] of boolean;
  TempStream : TMemoryStream;
  TempVarItm : TMemoryStream;
  DictLoaded : boolean;
  FilterOn : boolean;
  FilterCol : integer;
  OpenStatPath : string;
  AItems : array[0..8] of string;
  LoggedOn : boolean = false;

  Options: TOptions = (
    DefaultPath: '';
    FractionType: ftPoint;
    DefaultMiss: mvcNines;
    DefaultJust: jLeft
  );


const
  FractionTypeChars: array[TFractionType] of char = ('.', ',');
  MissingValueCodes: array[TMissingValueCode] of string = (' ', '.', '0', '99999');
  JustificationCodes: array[TJustification] of string[1] = ('L', 'C', 'R');

  DEFAULT_CONFIDENCE_LEVEL_PERCENT = 95.0;
  DEFAULT_ALPHA_LEVEL = 0.05;
  DEFAULT_BETA_LEVEL = 0.20;

  DATA_COLORS: array[0..11] of TColor = (
    clMaroon, clRed, clBlue, clGreen, clNavy, clTeal,
    clAqua, clLime, clFuchsia, clGray, clSilver, clOlive
  );

  DIVIDER = '===========================================================================';
  DIVIDER_SMALL = '---------------------------------------------------------------------------';

  GRAPH_BACK_COLOR = clCream;
  GRAPH_WALL_COLOR = clGray;
  GRAPH_FLOOR_COLOR = clLtGray;

  TWO_PI = 2.0 * PI;

implementation

end.

