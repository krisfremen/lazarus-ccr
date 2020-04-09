{ Map Viewer Download Engine
  Copyright (C) 2011 Maciej Kaczkowski / keit.co

  License: modified LGPL with linking exception (like RTL, FCL and LCL)

  See the file COPYING.modifiedLGPL.txt, included in the Lazarus distribution,
  for details about the license.

  See also: https://wiki.lazarus.freepascal.org/FPC_modified_LGPL
}

unit mvDownloadEngine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TMvCustomDownloadEngine }

  TMvCustomDownloadEngine = class(TComponent)
  public
    procedure DownloadFile(const {%H-}Url: string; {%H-}AStream: TStream); virtual;
  end;


implementation

{ TMvCustomDownloadEngine }

procedure TMvCustomDownloadEngine.DownloadFile(const Url: string; AStream: TStream);
begin
  // to be overridden...
end;

end.

