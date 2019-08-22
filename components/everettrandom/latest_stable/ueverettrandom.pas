unit ueverettrandom;

{ Random integer generation via beam-splitter quantum event generator

  Code copyright (C)2019 minesadorada@charcodelvalle.com

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.

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
Details of the online resource below:

================================================================================
webpage: https://qrng.anu.edu.au/

To get a set of numbers generated online by a quantum number generator:
Post to: https://qrng.anu.edu.au/API/jsonI.php?length=[array length]&type=[data type]&size=[block size]
If the request is successful, the random numbers are returned in a JSON encoded array named 'data'
(Note: block size parameter is only needed for data type=hex16)
The random numbers are generated in real-time in our lab by measuring the quantum fluctuations of the vacuum

Example to get 10 numbers of range 0-255 is
https://qrng.anu.edu.au/API/jsonI.php?length=10&type=uint8
JSON returned:
{"type":"uint8","length":10,"data":[241,83,235,48,81,154,222,4,77,120],"success":true}

Example to get 10 numbers of range  0–65535 is
https://qrng.anu.edu.au/API/jsonI.php?length=10&type=uint16
JSON returned:
{"type":"uint16","length":10,"data":[50546,25450,24289,44825,10457,49509,48848,30970,33829,47807],"success":true}

Example to get 10 hexadecimal numbers of range  00–FF is
https://qrng.anu.edu.au/API/jsonI.php?length=10&type=hex16
JSON returned:
{"type":"string","length":10,"size":1,"data":["5d","f9","aa","bf","5e","02","3c","55","6e","9e"],"success":true}

Example to get 10 hexadecimal numbers of range  0000–FFFF (blocksize=2) is
https://qrng.anu.edu.au/API/jsonI.php?length=10&type=hex16&size=2
JSON returned:
{"type":"string","length":10,"size":2,"data":["2138","592e","0643","8cdf","b955","e42f","eda6","c62a","2c66","f009"],"success":true}

Example to get 10 hexadecimal numbers of range  000000–FFFFFF (blocksize=3) is
https://qrng.anu.edu.au/API/jsonI.php?length=10&type=hex16&size=3
JSON returned:
{"type":"string","length":10,"size":3,"data":["add825","ac3530","79b708","ee8d42","683647","b6bb25","a92571","a8ae6a","963131","f62ec2"],"success":true}


Javascript:
var json = eval('('+ ajaxobject.responseText +')'); /* JSON is here*/
  document.getElementById('json_success').innerHTML = json.success;
  document.getElementById('dataHere').innerHTML = ajaxobject.responseText;
================================================================================
Version History:
V0.1.2.0 - initial commit
V0.1.3.0 - cleanup
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Controls, Forms, StdCtrls, Variants,
  everett_httpclient, open_ssl, fpjson, fpjsonrtti;

const
  C_QUANTUMSERVERLIMIT = 1024;
  C_URL = 'https://qrng.anu.edu.au/API/jsonI.php?length=%d&type=%s&size=%d';

resourcestring
  rsSSLLibraries = 'SSL libraries unavailable and/or unable to be downloaded '
    + 'on this system. Please fix.';
  rsFailedTooMan = 'Failed - Too many requests to the Quantum server%s%s';
  rsFailedQuantu = 'Failed - Quantum server refused with code %d';
  rsQuantumServe = 'Quantum server did not deliver a valid array';
  rsFailedQuantu2 = 'Failed - Quantum server refused with code %s';
  rsPleaseWaitCo = 'Please wait. Contacting Quantum Server';

type
  TQuantumNumberType = (uint8, uint16, hex16);
  TQuantumNumberDataObject = class; // Forward declaration

  // This is a persistent class with an owner
  { TEverett }
  TEverett = class(TComponent)
  private
    fHttpClient: TFPHTTPClient;
    fQuantumNumberType: TQuantumNumberType;
    fQuantumNumberDataObject: TQuantumNumberDataObject;
    fShowWaitDialog: boolean;
    fWaitDialogCaption: string;
    fArraySize,fHexSize:Integer;
    procedure SetArraySize(AValue:Integer);
  protected
    // Main worker function
    function FetchQuantumRandomNumbers(AQuantumNumberType: TQuantumNumberType;
      Alength: integer; ABlocksize: integer = 1): boolean; virtual;
    // Object that contains array results
    property QuantumNumberDataObject: TQuantumNumberDataObject
      read fQuantumNumberDataObject;
  public
    // (Dynamic) Array results
    IntegerArray: array of integer;
    HexArray: array of string;

    // TEverett should have an owner so that cleanup is easy
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Fetch a single random number
    function GetSingle8Bit: integer;
    function GetSingle16Bit: integer;
    function GetSingleHex: String;

    // Array functions will put results into:
    // (uint8, uint16) IntegerArray[0..Pred(ArraySize)]
    // (hex16) HexArray[0..Pred(ArraySize)]
    function GetInteger8BitArray:Boolean;
    function GetInteger16BitArray:Boolean;
    function GetHexArray:Boolean;
  published
    property NumberType: TQuantumNumberType read fQuantumNumberType
      write fQuantumNumberType default uint8;
    property ShowWaitDialog: boolean
      read fShowWaitDialog write fShowWaitDialog default True;
    property WaitDialogCaption: string read fWaitDialogCaption write fWaitDialogCaption;
    property ArraySize:Integer read fArraySize write SetArraySize default 1;
    property HexSize:Integer read fHexSize write fHexSize default 1;
  end;

  // DeStreamer.JSONToObject populates all the properties
  // Do not change any of the properties
  TQuantumNumberDataObject = class(TObject)
  private
    fNumberType: string;
    fNumberLength: integer;
    fNumbersize: integer;
    fNumberData: variant;
    fNumberSuccess: string;
  public
  published
    // Prefix property name with & to avoid using a reserved pascal word
    // Note: This bugs out the JEDI code formatter
    property &type: string read fNumberType write fNumberType;
    property length: integer read fNumberLength write fNumberLength;
    property size: integer read fNumbersize write fNumbersize;
    // Note: property "data" must be lowercase.  JEDI changes it to "Data"
    property data: variant read fNumberData write fNumberData;
    property success: string read fNumberSuccess write fNumberSuccess;
  end;

implementation

procedure TEverett.SetArraySize(AValue: Integer);
// Property setter
begin
  if Avalue <=C_QUANTUMSERVERLIMIT then
    fArraySize:=AValue
  else
    fArraySize:=1;
end;

// This is the core function.
// If successful, it populates either IntegerArray or HexArray
// Parameters:
// AQuantumNumberType can be uint8, uint16 or hex16
// ALength is the size of the returned array
// ABlocksize is only relavent if AQuantumNumberType=hex16
// it is the size of the hex number in HexArray (1=FF, 2=FFFF, 3=FFFFFF etc)
function TEverett.FetchQuantumRandomNumbers(AQuantumNumberType: TQuantumNumberType;
  Alength: integer; ABlocksize: integer): boolean;
var
  szURL: string;
  JSON: TJSONStringType;
  DeStreamer: TJSONDeStreamer;
  ct: integer;
  frmWaitDlg: TForm;
  lbl_WaitDialog: TLabel;
begin
  Result := False; // assume failure
  // Reset arrays
  SetLength(IntegerArray, 0);
  SetLength(HexArray, 0);
  // Parameter checks
  if Alength > C_QUANTUMSERVERLIMIT then
    Exit;
  if ABlocksize > C_QUANTUMSERVERLIMIT then
    Exit;

  // Is SSL installed? If not, download it.
  // If this fails then just early return FALSE;
  if not CheckForOpenSSL then
  begin
    ShowMessage(rsSSLLibraries);
    exit;
  end;

  // Make up the Quantum Server URL query
  case AQuantumNumberType of
    uint8:
      szURL := Format(C_URL, [Alength, 'uint8', ABlocksize]);
    uint16:
      szURL := Format(C_URL, [Alength, 'uint16', ABlocksize]);
    hex16:
      szURL := Format(C_URL, [Alength, 'hex16', ABlocksize]);
    else
      exit;
  end;
  try
    // Create the Wait Dialog
    frmWaitDlg := TForm.CreateNew(nil);
    with frmWaitDlg do
    begin
      // Set Dialog properties
      Height := 100;
      Width := 200;
      position := poOwnerFormCenter;
      borderstyle := bsNone;
      Caption := '';
      formstyle := fsSystemStayOnTop;
      lbl_WaitDialog := TLabel.Create(frmWaitDlg);
      with lbl_WaitDialog do
      begin
        align := alClient;
        alignment := tacenter;
        Caption := fWaitDialogCaption;
        ParentFont := True;
        Cursor := crHourGlass;
        parent := frmWaitDlg;
      end;
      Autosize := True;
      // Show it or not
      if fShowWaitDialog then
        Show;
      Application.ProcessMessages;
    end;
    with fhttpclient do
    begin
      // Set up the JSON destramer
      DeStreamer := TJSONDeStreamer.Create(nil);
      DeStreamer.Options := [jdoIgnorePropertyErrors];
      // Set up the http client
      ResponseHeaders.NameValueSeparator := ':';
      AddHeader('Accept', 'application/json;charset=UTF-8');
      //DEBUG:ShowMessage(szURL);

      // Go get the data!
      JSON := Get(szURL);
      // DEBUG: ShowMessageFmt('Response code = %d',[ResponseStatusCode]);

      // Any response other than 200 is bad news
      if (ResponseStatusCode <> 200) then
        case ResponseStatusCode of
          429:
          begin
            ShowMessageFmt(rsFailedTooMan,
              [LineEnding, JSON]);
            Exit(False);
          end;
          else
          begin
            ShowMessageFmt(rsFailedQuantu,
              [ResponseStatusCode]);
            Exit(False);
          end;
        end;
      try
        // Stream it to the object list
        DeStreamer.JSONToObject(JSON, fQuantumNumberDataObject);
        // Populate IntegerArray/Hexarray
        if VarIsArray(QuantumNumberDataObject.Data) then
        begin
          case AQuantumNumberType of
            uint8, uint16:
            begin
              SetLength(IntegerArray,
                fQuantumNumberDataObject.fNumberLength);
              for ct := 0 to Pred(fQuantumNumberDataObject.fNumberLength) do
                IntegerArray[ct] :=
                  StrToInt(fQuantumNumberDataObject.Data[ct]);
            end;
            hex16:
            begin
              SetLength(HexArray,
                fQuantumNumberDataObject.fNumberLength);
              for ct := 0 to Pred(fQuantumNumberDataObject.fNumberLength) do
                HexArray[ct] :=
                  fQuantumNumberDataObject.Data[ct];
            end;
          end;
        end
        else
        begin
          ShowMessage(rsQuantumServe);
          Exit;
        end;
      except
        On E: Exception do
          showmessagefmt(rsFailedQuantu2, [E.Message]);
        On E: Exception do
          Result := False;
      end;
    end;
  finally
    // No matter what - free memory
    DeStreamer.Free;
    frmWaitDlg.Free;
  end;
  Result := True; //SUCCESS!
  // DEBUG ShowMessage(fQuantumNumberDataObject.fNumberSuccess);
end;

constructor TEverett.Create(AOwner: TComponent);
begin
  inherited;
  fQuantumNumberType := uint8; // default is 8-bit (byte)
  fShowWaitDialog := True; // Show dialog whilst fetching data online
  fWaitDialogCaption := rsPleaseWaitCo;
  fHttpClient := TFPHTTPClient.Create(Self);
  fQuantumNumberDataObject := TQuantumNumberDataObject.Create;
  fArraySize:=1; // default
  fHexSize:=1; // default
  SetLength(IntegerArray, 0);
  SetLength(HexArray, 0);
end;

destructor TEverett.Destroy;
begin
  FreeAndNil(fQuantumNumberDataObject);
  FreeAndNil(fHttpClient);
  inherited;
end;

function TEverett.GetSingle8Bit: integer;
begin
  Result := 0;
  if FetchQuantumRandomNumbers(uint8, 1, 1) then
    Result := IntegerArray[0];
end;

function TEverett.GetSingle16Bit: integer;
begin
  Result := 0;
  if FetchQuantumRandomNumbers(uint16, 1, 1) then
    Result := IntegerArray[0];
end;

function TEverett.GetSingleHex: String;
begin
  Result:='00';
  if FetchQuantumRandomNumbers(hex16, 1, 1) then
    Result := HexArray[0];
end;

function TEverett.GetInteger8BitArray: Boolean;
// Populates IntegerArray
begin
  Result:=FetchQuantumRandomNumbers(uint8, fArraySize, 1);
end;

function TEverett.GetInteger16BitArray: Boolean;
// Populates IntegerArray
begin
  Result:=FetchQuantumRandomNumbers(uint16, fArraySize, 1);
end;

function TEverett.GetHexArray: Boolean;
// Populates HexArray
begin
  Result:=FetchQuantumRandomNumbers(hex16, fArraySize, fHexSize);
end;

end.
