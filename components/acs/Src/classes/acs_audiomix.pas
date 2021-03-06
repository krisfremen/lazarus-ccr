(*
  this file is a part of audio components suite.
  see the license file for more details.
  you can contact me at mail@z0m3ie.de

$Log: acs_audiomix.pas,v $
Revision 1.6  2006/07/04 17:12:45  z0m3ie
ACS 2.4 alt wiederhergestellt (unterschiedliche Sampleformate ...)

Revision 1.1  2005/12/19 18:34:35  z0m3ie
*** empty log message ***

Revision 1.4  2005/12/04 16:54:33  z0m3ie
All classes are renamed, Style TACS... than T... to avoid conflicts with other components (eg TMixer is TACSMixer now)

Revision 1.3  2005/09/15 20:59:37  z0m3ie
start translate the documentation in the source for pasdoc

Revision 1.2  2005/09/13 21:54:11  z0m3ie
acs is localizeable now (ACS_Strings)

Revision 1.1  2005/09/12 22:04:52  z0m3ie
modified structure again, fileformats are now in an sperat folder.
all File In/Out classes are capsulated from TFileIn and TFileOut

Revision 1.3  2005/08/23 19:45:51  z0m3ie
changed to Version 2.31

Revision 1.2  2005/08/22 20:17:01  z0m3ie
changed Headers to log
changed mail adress
*)

{
@abstract(this unit introduces the base classes for acs)
@author(Andrei Borovsky (2003-2005))
@author(Christian Ulrich (2005))
}

{$hints off}
unit acs_audiomix;

{$ifdef fpc}
{$mode delphi}
{$endif}

interface

uses
  Classes, SysUtils, ACS_Types, ACS_Classes, ACS_Strings;
  
const
  BUF_SIZE = $100000;
  
type
  TACSAudioMixerMode = (amMix, amConcatenate, amRTMix, amCustomMix);
  TACSAudioMixer = class(TACSCustomInput)
  private
    FInput1, FInput2 : TACSCustomInput;
    BufStart, BufEnd : Integer;
    ByteCount : Cardinal;                // add by leozhang
    FVolume1, FVolume2 : Byte;
    EndOfInput1, EndOfInput2 : Boolean;
    InBuf1, InBuf2 : array[1..BUF_SIZE] of Byte;
    Buisy : Boolean;
    FMode : TACSAudioMixerMode;
    FInput2Start: Cardinal;
    FLock : Boolean;
    FFgPlaying : Boolean;
    function GetBPS : Integer; override;
    function GetCh : Integer; override;
    function GetSR : Integer; override;
    procedure SetInput1(aInput : TACSCustomInput);
    procedure SetInput2(aInput : TACSCustomInput);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetData(Buffer : Pointer; BufferSize : Integer): Integer; override;
    procedure Init; override;
    procedure Flush; override;
    property FgPlaying : Boolean read FFgPlaying;
  published
    property Input1 : TACSCustomInput read FInput1 write SetInput1;
    property Input2 : TACSCustomInput read FInput2 write SetInput2;
    property Mode : TACSAudioMixerMode read FMode write FMode;
    property Input2Start :Cardinal read FInput2Start write FInput2Start;
    property Volume1 : Byte read FVolume1 write FVolume1;
    property Volume2 : Byte read FVolume2 write FVolume2;
  end;
  
implementation  

procedure MixChannels16(Buf1, Buf2 : PACSBuffer16; Vol1, Vol2, InSize : Integer);
var      // optimized by leozhang
  i, tmp : Integer;
  V1,V2: Real;
begin
  V1 := Vol1 / 127;
  V2 := Vol2 / 127;
  for i := 0 to (Insize shr 1) - 1 do
  begin
  if Buf2[i] = 0 then
  begin
     Buf2[i] := Round(Buf1[i] * V1);
  end else
  if Buf1[i] = 0 then
  begin
     Buf2[i] := Round(Buf2[i] * V2);
  end else
     Buf2[i] := Round(Buf1[i] * V1) + Round(Buf2[i] * V2);
  end;
end;

  constructor TACSAudioMixer.Create;
  begin
    inherited Create(AOwner);
    FVolume1 := 127;
    FVolume2 := 127;
    FInput2Start := 0;
  end;

  destructor TACSAudioMixer.Destroy;
  begin
    inherited Destroy;
  end;

  function TACSAudioMixer.GetBPS;
  begin
    if not Assigned(FInput1) then
    raise EACSException.Create(strInputnotAssigned);
    Result := FInput1.BitsPerSample;
  end;

  function TACSAudioMixer.GetCh;
  begin
    if not Assigned(FInput1) then
    raise EACSException.Create(strInputnotAssigned);
    Result:= FInput1.Channels;
  end;

  function TACSAudioMixer.GetSR;
  begin
    if not Assigned(FInput1) then
    raise EACSException.Create(strInputnotAssigned);
    Result := FInput1.SampleRate;
  end;

  procedure TACSAudioMixer.Init;
  var
    In2StartByte : Cardinal;     // add by zhangl.
  begin
    Buisy := True;
    FPosition := 0;
    BufStart := 1;
    BufEnd := 0;
    EndOfInput1 := False;
    EndOfInput2 := False;
    if not Assigned(FInput1) then
    raise EACSException.Create(strInputnotAssigned);
    if FMode = amRTMix then
    begin
      FInput1.Init;
      FSize := FInput1.Size;
      if Assigned(FInput2) then
      begin
        FInput2.Init;
        FFgPlaying := True;
      end else EndOfInput2 := True;
      FLock := False;
    end else
    begin
      if not Assigned(FInput2) then
      raise EACSException.Create(strInputnotAssigned);
      FInput1.Init;
      FInput2.Init;
      case FMode of
        amMix :
        if FInput1.Size > FInput2.Size then FSize := FInput1.Size
        else FSize := FInput2.Size;
        amConcatenate :
        FSize := FInput1.Size + FInput2.Size;     //determine the size of the output stream in bytes
        amCustomMix:
        // add by leozhang
        begin
           In2StartByte :=  Round(Int((FInput2Start * FInput2.SampleRate) /1000) *
                            (FInput2.Channels) * ((FInput2.BitsPerSample) shr 3));
           ByteCount := In2StartByte;
           if Cardinal(FInput1.Size) > In2StartByte + FInput2.Size then
                FSize := FInput1.Size
           else
                FSize := In2StartByte + FInput2.Size;
           FLock := False;
        end;
        // leozhang
      end;
    end;
  end;
  procedure TACSAudioMixer.Flush;
  begin
    FInput1.Flush;
    if (FMode <> amRTMix) or Assigned(FInput2) then
    FInput2.Flush;
    Buisy := False;
  end;
  function TACSAudioMixer.GetData;
  var
    l1, l2 : Integer;
    InSize : Integer;
  begin
    if not Buisy then  raise EACSException.Create(strStreamnotopen);
    if BufStart > BufEnd then
    begin
      if EndOfInput1 and  EndOfInput2 then
      begin
        Result := 0;
        Exit;
      end;
      if (FMode = amRTMix) and  EndOfInput1 then
      begin
        Result := 0;
        Exit;
      end;
      BufStart := 1;
      case Mode of
        amMix :
        begin
          l1 := 0;
          l2 := 0;
          FillChar(InBuf1[1], BUF_SIZE, 0);
          FillChar(InBuf2[1], BUF_SIZE, 0);
          if not EndOfInput1 then
          begin
            l1 := FInput1.GetData(@InBuf1[1], BUF_SIZE);
            InSize := l1;
            while (InSize <> 0) and (l1 < BUF_SIZE) do
            begin
              InSize := FInput1.GetData(@InBuf1[l1+1], BUF_SIZE - l1);
              Inc(l1, InSize);
            end;
            if InSize = 0 then EndOfInput1 := True;
          end;
          if not EndOfInput2 then
          begin
            l2 := FInput2.GetData(@InBuf2[1], BUF_SIZE);
            InSize := l2;
            while (InSize <> 0) and (l2 < BUF_SIZE) do
            begin
              InSize := FInput2.GetData(@InBuf2[l2+1], BUF_SIZE - l2);
              Inc(l2, InSize);
            end;
            if InSize = 0 then EndOfInput2 := True;
          end;
          if (l1 = 0) and (l2 = 0) then
          begin
            Result := 0;
            Exit;
          end;
          if l1 > l2 then BufEnd := l1 else BufEnd := l2;
          MixChannels16(@InBuf1[1], @InBuf2[1], FVolume1, FVolume2, BufEnd);
        end;
        amConcatenate :
        begin
          if not EndOfInput1 then
          begin
            l1 := FInput1.GetData(@InBuf2[1], BUF_SIZE);
            if l1 = 0 then EndOfInput1 := True
            else BufEnd := l1;
          end;
          if EndOfInput1 then
          begin
            l2 := FInput2.GetData(@InBuf2[1], BUF_SIZE);
            if l2 = 0 then
            begin
              Result := 0;
              Exit;
            end
            else BufEnd := l2;
          end;
        end;
        // add by leo.zhang
        amCustomMix:
        begin
          l1 := 0;
          l2 := 0;
          FillChar(InBuf1[1], BUF_SIZE, 0);
          FillChar(InBuf2[1], BUF_SIZE, 0);
          if not EndOfInput1 then
          begin
            l1 := FInput1.GetData(@InBuf1[1], BUF_SIZE);
            InSize := l1;
            while (InSize <> 0) and (l1 < BUF_SIZE) do
            begin
              InSize := FInput1.GetData(@InBuf1[l1+1], BUF_SIZE - l1);
              Inc(l1, InSize);
            end;
            if InSize = 0 then EndOfInput1 := True;
          end;
          if not (FLock or EndOfInput2) then
          begin
             FLock := True;
             if ByteCount > BUF_SIZE then
             begin
                ByteCount := ByteCount - BUF_SIZE;
                l2 := BUF_SIZE; InSize := l2;
             end else
             begin
                  l2 := FInput2.GetData(@InBuf2[ByteCount+1],BUF_SIZE - ByteCount);
                  InSize := l2;
                  if ByteCount <> 0 then
                  begin
                    Inc(l2,ByteCount);
                    InSize := l2;
                    ByteCount := 0;
                  end;
                  while (InSize <> 0) and (l2 < BUF_SIZE) do
                  begin
                     InSize := FInput2.GetData(@InBuf2[l2+1], BUF_SIZE - l2);
                     Inc(l2, InSize);
                  end;
             end;
             if InSize = 0 then EndOfInput2 := True;
             FLock := False;
          end;
          if (l1 = 0) and (l2 = 0) then
          begin
            Result := 0;
            Exit;
          end;
          if l1 > l2 then BufEnd := l1 else BufEnd := l2;
          MixChannels16(@InBuf1[1], @InBuf2[1], FVolume1, FVolume2, BufEnd);
        end;
        // leo.zhang.
        amRTMix :
        begin
          l1 := 0;
          l2 := 0;
          FillChar(InBuf1[1], BUF_SIZE, 0);
          FillChar(InBuf2[1], BUF_SIZE, 0);
          if not EndOfInput1 then
          begin
            l1 := FInput1.GetData(@InBuf1[1], BUF_SIZE);
            InSize := l1;
            while (InSize <> 0) and (l1 < BUF_SIZE) do
            begin
              InSize := FInput1.GetData(@InBuf1[l1+1], BUF_SIZE - l1);
              Inc(l1, InSize);
            end;
            if InSize = 0 then EndOfInput1 := True;
          end;
          if not (FLock or EndOfInput2) then
          begin
            FLock := True;
            l2 := FInput2.GetData(@InBuf2[1], BUF_SIZE);
            InSize := l2;
            while (InSize <> 0) and (l2 < BUF_SIZE) do
            begin
              InSize := FInput2.GetData(@InBuf2[l2+1], BUF_SIZE - l2);
              Inc(l2, InSize);
            end;
            if InSize = 0 then
            begin
              EndOfInput2 := True;
              FFGPlaying := False;
              FInput2.Flush;
              FInput2 := nil;
            end;
            FLock := False;
          end;
          if (l1 = 0) and (l2 = 0) then
          begin
            Result := 0;
            Exit;
          end;
          if l1 > l2 then BufEnd := l1 else BufEnd := l2;
          MixChannels16(@InBuf1[1], @InBuf2[1], FVolume1, FVolume2, BufEnd);
        end;
      end;       // case end.
    end;  // endif.
    if BufferSize < (BufEnd - BufStart + 1)
    then Result := BufferSize
    else Result := BufEnd - BufStart + 1;
    Move(InBuf2[BufStart], Buffer^, Result);
    Inc(BufStart, Result);
    Inc(FPosition, Result);
  end; // procedure end.
  procedure TACSAudioMixer.SetInput1;
  begin
    if Buisy then
    raise EACSException.Create(strBusy);
    FInput1 := aInput;
  end;
  procedure TACSAudioMixer.SetInput2;
  begin
    if not Buisy then  FInput2 := aInput
    else
    if FMode = amRTMix then
    begin
      if FFgPlaying then
      begin
        while Flock do;
        FLock := True;
        Input2.Flush;
      end;
      FInput2 := aInput;
      Finput2.Init;
      Flock := False;
      FFgPlaying := True;
      EndOfInput2 := False;
    end else
    raise EACSException.Create(strNotinFBMode);
  end;

end.
