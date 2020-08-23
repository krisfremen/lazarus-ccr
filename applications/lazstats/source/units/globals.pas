unit Globals; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, TATypes;

type
  IntDyneVec = array of integer;
  DblDyneVec = array of double;
  BoolDyneVec = array of boolean;
  DblDyneMat  = array of array of double;
  IntDyneMat = array of array of integer;
  DblDyneCube = array of array of array of double;
  IntDyneCube = array of array of array of integer;
  DblDyneQuad = array of array of array of array of double;
  IntDyneQuad = array of array of array of array of integer;
  StrDyneVec  = array of string;
  StrDyneMat = array of array of string;
  CharDyneVec = array of char;

  Point3D = record
    x, y, z: double;
  end;

  PointInt = record
    x, y: Integer;
  end;

  TFractionType = (ftPoint, ftComma);
  TMissingValueCode = (mvcSpace, mvcPeriod, mvcZero, mvcNines);
  TJustification = (jLeft, jCenter, jRight);

  TOptions = record
    DefaultDataPath: string;
    FractionType: TFractionType;
    DefaultMiss: TMissingValueCode;
    DefaultJust: TJustification;
    LHelpPath: String;
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
  //OpenStatPath : string;
  AItems : array[0..8] of string;
  LoggedOn : boolean = false;

  Options: TOptions = (
    DefaultDataPath: '';
    FractionType: ftPoint;
    DefaultMiss: mvcNines;
    DefaultJust: jLeft;
    LHelpPath: '<default>';
  );

const
  FractionTypeChars: array[TFractionType] of char = ('.', ',');
  MissingValueCodes: array[TMissingValueCode] of string = (' ', '.', '0', '99999');
  JustificationCodes: array[TJustification] of string[1] = ('L', 'C', 'R');

  TOL = 0.0005;

  DEFAULT_CONFIDENCE_LEVEL_PERCENT = 95.0;
  DEFAULT_ALPHA_LEVEL = 0.05;
  DEFAULT_BETA_LEVEL = 0.20;

  DATA_COLORS: array[0..11] of TColor = (
    clMaroon, clRed, clBlue, clGreen, clNavy, clTeal,
    clAqua, clLime, clFuchsia, clGray, clSilver, clOlive
  );
  DATA_SYMBOLS: array[0..5] of TSeriesPointerStyle = (psRectangle, psCircle, psDiamond,
     psDownTriangle, psHexagon, psFullStar);


  DIVIDER = '===========================================================================';
  DIVIDER_SMALL = '---------------------------------------------------------------------------';

  GRAPH_BACK_COLOR = clCream;
  GRAPH_WALL_COLOR = clGray;
  GRAPH_FLOOR_COLOR = clLtGray;

  TWO_PI = 2.0 * PI;

  TAB_FILE_FILTER = 'Tab field files (*.tab)|*.tab;*.TAB|Text files (*.txt)|*.txt;*.TXT|All files (*.*)|*.*';
  CSV_FILE_FILTER = 'Comma field files (*.csv)|*.csv;*.CSV|Text files (*.txt)|*.txt;*.TXT|All files (*.*)|*.*';
  SSV_FILE_FILTER = 'Space field files (*.ssv)|*.ssv;*.SSV|Text files (*.txt)|*.txt;*.TXT|All files (*.*)|*.*';

implementation

end.

