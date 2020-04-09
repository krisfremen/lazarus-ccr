{
  License: modified LGPL with linking exception (like RTL, FCL and LCL)

  See the file COPYING.modifiedLGPL.txt, included in the Lazarus distribution,
  for details about the license.

  See also: https://wiki.lazarus.freepascal.org/FPC_modified_LGPL
}

unit mvTypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  TILE_SIZE = 256;
  PALETTE_PAGE = 'Misc';

Type
    { TArea }
  TArea = record
    top, left, bottom, right: Int64;
  end;

  { TRealPoint }
  TRealPoint = Record
    Lon : Double;
    Lat : Double;
  end;

  { TRealArea }
  TRealArea = Record
    TopLeft : TRealPoint;
    BottomRight : TRealPoint;
  end;

implementation

end.

