{   This file is part of the Web Service Toolkit
    Copyright (c) 2008 by Inoussa OUEDRAOGO

    This file is provide under modified LGPL licence
    ( the files COPYING.modifiedLGPL and COPYING.LGPL).


    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
{$INCLUDE wst_global.inc}
unit date_utils;

interface
uses
  SysUtils;
  
type

  TDateTimeRec = packed record
    Date : TDateTime;
    HourOffset : Shortint;
    MinuteOffset : Shortint;
  end;

  TTimeRec = packed record
    Hour   : Byte;
    Minute : Byte;
    Second : Byte;
    MilliSecond : Word;
    HourOffset : Shortint;
    MinuteOffset : Shortint;
  end;

const
  ZERO_DATE : TDateTimeRec = ( Date : 0; HourOffset : 0; MinuteOffset : 0; );
  ZERO_TIME : TTimeRec = (
                Hour         : 0;
                Minute       : 0;
                Second       : 0;
                MilliSecond  : 0;
                HourOffset   : 0;
                MinuteOffset : 0;
              );

  function xsd_TryStrToDate(const AStr : string; out ADate : TDateTimeRec) : Boolean;
  function xsd_StrToDate(const AStr : string) : TDateTimeRec; {$IFDEF USE_INLINE}inline;{$ENDIF}

  function xsd_DateTimeToStr(const ADate : TDateTimeRec) : string;overload;
  function xsd_DateTimeToStr(const ADate : TDateTime) : string;overload;

  function xsd_TimeToStr(const ATime : TTimeRec) : string;
  function xsd_TryStrToTime(const AStr : string; out ADate : TTimeRec) : Boolean;
  function xsd_StrToTime(const AStr : string) : TTimeRec;  {$IFDEF USE_INLINE}inline;{$ENDIF}
  function xsd_EncodeTime(
    const AHour,
          AMin,
          ASec     : Byte;
    const AMiliSec : Word
  ) : TTimeRec; overload; {$IFDEF USE_INLINE}inline;{$ENDIF}
  function xsd_EncodeTime(
    const AHour,
          AMin,
          ASec     : Byte;
    const AMiliSec : Word;
    const AHourOffset   : Shortint;
    const AMinuteOffset : Shortint
  ) : TTimeRec; overload; {$IFDEF USE_INLINE}inline;{$ENDIF}
  function DateTimeToTimeRec(const ADateTime : TDateTime) : TTimeRec; {$IFDEF USE_INLINE}inline;{$ENDIF}
  function TimeRecToDateTime(const ATime : TTimeRec) : TDateTime; {$IFDEF USE_INLINE}inline;{$ENDIF}


  function IncHour(const AValue: TDateTime; const ANumberOfHours: Int64): TDateTime;{$IFDEF USE_INLINE}inline;{$ENDIF}
  function IncMinute(const AValue: TDateTime; const ANumberOfMinutes: Int64): TDateTime;{$IFDEF USE_INLINE}inline;{$ENDIF}

  function NormalizeToUTC(const ADate : TDateTimeRec) : TDateTime; overload;
  function NormalizeToUTC(const ATime : TTimeRec) : TTimeRec; overload;
  function Equals(const AA,AB: TDateTimeRec) : Boolean; overload;
  function Equals(const AA,AB: TTimeRec) : Boolean; overload;

resourcestring
  SERR_InvalidDate = '"%s" is not a valid date.';
  SERR_InvalidTime = '"%s" is not a valid time.';

implementation

uses Math, DateUtils;

function IncHour(const AValue: TDateTime; const ANumberOfHours: Int64): TDateTime;
begin
  Result := DateOf(AValue) + DateUtils.IncHour(TimeOf(AValue),ANumberOfHours);
end;

function IncMinute(const AValue: TDateTime; const ANumberOfMinutes: Int64): TDateTime;
begin
  Result := DateOf(AValue) + DateUtils.IncMinute(TimeOf(AValue),ANumberOfMinutes);
end;

function NormalizeToUTC(const ADate : TDateTimeRec) : TDateTime;
begin
  Result := ADate.Date;
  if ( ADate.HourOffset <> 0 ) then
    Result := IncHour(Result,-ADate.HourOffset);
  if ( ADate.MinuteOffset <> 0 ) then
    Result := IncMinute(Result,-ADate.MinuteOffset);
end;

function NormalizeToUTC(const ATime : TTimeRec) : TTimeRec;
var
  locDate : TDateTime;
  e_h, e_mn, e_ss, e_ms : Word;
begin
  locDate := TimeRecToDateTime(ATime);
  if ( ATime.HourOffset <> 0 ) then
    locDate := IncHour(locDate,ATime.HourOffset);
  if ( ATime.MinuteOffset <> 0 ) then
    locDate := IncMinute(locDate,ATime.MinuteOffset);
  DecodeTime(locDate,e_h,e_mn,e_ss,e_ms);
  Result.Hour := e_h;
  Result.Minute := e_mn;
  Result.Second := e_ss;
  Result.MilliSecond := e_ms;
  Result.HourOffset := 0;
  Result.MinuteOffset := 0;
end;

{$HINTS OFF}
function Equals(const AA,AB: TDateTimeRec) : Boolean;
var
  e, a : TDateTime;
  e_y, e_m, e_d, e_h, e_mn, e_ss, e_ms : Word;
  a_y, a_m, a_d, a_h, a_mn, a_ss, a_ms : Word;
begin
  e := NormalizeToUTC(AA);
  a := NormalizeToUTC(AB);
  DecodeDateTime(e, e_y, e_m, e_d, e_h, e_mn, e_ss, e_ms);
  DecodeDateTime(a, a_y, a_m, a_d, a_h, a_mn, a_ss, a_ms);
  Result := ( e_y = a_y ) and ( e_m = a_m ) and ( e_d = a_d ) and
            (e_h = a_h ) and ( e_mn = a_mn ) and ( e_ss = a_ss ) and ( e_ms = a_ms );
end;
{$HINTS ON}

function Equals(const AA,AB: TTimeRec) : Boolean;
var
  a, b : TTimeRec;
begin
  a := NormalizeToUTC(AA);
  b := NormalizeToUTC(AB);
  Result := ( a.Hour = b.Hour ) and
            ( a.Minute = b.Minute ) and
            ( a.Second = b.Second ) and
            ( a.MilliSecond = b.MilliSecond ) and
            ( a.HourOffset = b.HourOffset ) and
            ( a.MinuteOffset = b.MinuteOffset );
end;

function xsd_TryStrToDate(const AStr : string; out ADate : TDateTimeRec) : Boolean;
const
  DATE_SEP_CHAR = '-'; TIME_MARKER_CHAR = 'T'; TIME_SEP_CHAR = ':';
var
  buffer : string;
  bufferPos, bufferLen : Integer;

  function ReadInt(out AValue : Integer; const ASeparatorAtEnd : Char) : Boolean;
  var
    locStartPos : Integer;
  begin
    while ( bufferPos <= bufferLen ) and ( buffer[bufferPos] < #33 ) do begin
      Inc(bufferPos);
    end;
    locStartPos := bufferPos;
    if ( bufferPos <= bufferLen ) and ( buffer[bufferPos] in ['-','+'] ) then
      Inc(bufferPos);
    while ( bufferPos <= bufferLen ) and ( buffer[bufferPos] in ['0'..'9'] ) do begin
      Inc(bufferPos);
    end;
    Result := ( bufferPos > locStartPos ) and
              ( ( ASeparatorAtEnd = #0 ) or
                ( ( bufferPos <= bufferLen ) and
                  ( buffer[bufferPos] = ASeparatorAtEnd )
                )
              );
    if Result then
      Result := TryStrToInt(Copy(buffer,locStartPos,(bufferPos-locStartPos)),AValue);
  end;

  function ReadMiliSeconds(out AValue : Integer; const ASeparatorAtEnd : Char) : Boolean;
  var
    locDigitCount, locRes, itemp, locErcode : Integer;
  begin
    while ( bufferPos <= bufferLen ) and ( buffer[bufferPos] < #33 ) do begin
      Inc(bufferPos);
    end;
    locRes := 0;
    locDigitCount := 0;
    while ( locDigitCount < 3 ) and ( bufferPos <= bufferLen ) and ( buffer[bufferPos] in ['0'..'9'] ) do begin
      Val(buffer[bufferPos],itemp,locErcode);
      locRes := ( locRes * 10 ) + itemp;
      Inc(bufferPos);
      Inc(locDigitCount);
    end;
    Result := ( locDigitCount > 0 );
    if Result then begin
      if ( locDigitCount < 3 ) and ( locRes > 0 ) then begin
        while ( locDigitCount < 3 ) do begin
          locRes := locRes * 10;
          Inc(locDigitCount);
        end;
      end;
      AValue := locRes;
    end;
  end;

var
  d, m, y : Integer;
  hh, mn, ss, ssss : Integer;
  tz_hh, tz_mn : Integer;
  tz_negative : Boolean;
  ok : Boolean;
begin
  //'-'? yyyy '-' mm '-' dd 'T' hh ':' mm ':' ss ('.' s+)? (zzzzzz)?

  buffer := Trim(AStr);
  bufferPos := 1;
  bufferLen := Length(buffer);
  if ( bufferLen > 0 ) then begin
    Result := False;
    FillChar(ADate,SizeOf(ADate),#0);

    if ReadInt(y,DATE_SEP_CHAR) then begin
      Inc(bufferPos);
      if ReadInt(m,DATE_SEP_CHAR) then begin
        Inc(bufferPos);
        if ReadInt(d,#0) then begin
          Inc(bufferPos);
          tz_hh := 0;
          tz_mn := 0;
          if ( bufferPos > bufferLen ) then begin
            hh := 0;
            mn := 0;
            ss := 0;
            ssss := 0;
            ok := True;
          end else begin
            ok := ( buffer[bufferPos -1] = TIME_MARKER_CHAR ) and ReadInt(hh,TIME_SEP_CHAR);
            if ok then begin
              Inc(bufferPos);
              ok := ReadInt(mn,TIME_SEP_CHAR);
              if ok then begin
                Inc(bufferPos);
                ok := ReadInt(ss,#0);
                if ok and ( bufferPos < bufferLen ) and ( buffer[bufferPos] = '.' ) then begin
                  Inc(bufferPos);
                  ok := ReadMiliSeconds(ssss,#0);
                end else begin
                  ssss := 0;
                end;
                if ok and ( bufferPos < bufferLen ) then begin
                  tz_negative := ( buffer[bufferPos] = '-' );
                  Inc(bufferPos);
                  ok := ReadInt(tz_hh,TIME_SEP_CHAR);
                  if ok then begin
                    Inc(bufferPos);
                    ok := ReadInt(tz_mn,#0);
                    if ok and tz_negative then begin
                      tz_hh := -tz_hh;
                      tz_mn := -tz_mn;
                    end;
                  end;
                end;
              end;
            end;
          end;
          if ok then begin
            if ( ( y + m + d + hh + mn + ss + ssss ) = 0 ) then
              ADate.Date := 0
            else
              ADate.Date := EncodeDate(y,m,d) + EncodeTime(hh,mn,ss,ssss);
            ADate.HourOffset := tz_hh;
            ADate.MinuteOffset := tz_mn;
            Result := True;
          end;
        end;
      end;
    end;
  end else begin
    FillChar(ADate,SizeOf(ADate),#0);
    Result := True;
  end;
end;

function xsd_StrToDate(const AStr : string) : TDateTimeRec;
begin
  if not xsd_TryStrToDate(AStr,Result) then
    raise EConvertError.CreateFmt(SERR_InvalidDate,[AStr]);
end;

function xsd_DateTimeToStr(const ADate : TDateTimeRec) : string;
var
  locDate : TDateTime;
  d, m, y : Word;
  hh, mn, ss, ssss : Word;
begin
  //'-'? yyyy '-' mm '-' dd 'T' hh ':' mm ':' ss ('.' s+)? (zzzzzz)?
  locDate := ADate.Date;
  if ( ADate.HourOffset <> 0 ) then
    locDate := IncHour(locDate,-ADate.HourOffset);
  if ( ADate.MinuteOffset <> 0 ) then
    locDate := IncMinute(locDate,-ADate.MinuteOffset);
  DecodeDateTime(locDate,y,m,d,hh,mn,ss,ssss);
  if ( ssss = 0 ) then
    Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2dZ',[y,m,d, hh,mn,ss])
  else
    Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%.3dZ',[y,m,d, hh,mn,ss,ssss]);
end;

function xsd_DateTimeToStr(const ADate : TDateTime) : string;
var
  tmpDate : TDateTimeRec;
begin
  FillChar(tmpDate,SizeOf(TDateTimeRec),#0);
  tmpDate.Date := ADate;
  Result := xsd_DateTimeToStr(tmpDate);
end;

function xsd_TimeToStr(const ATime : TTimeRec) : string;
var
  buffer : string;
begin
  //hh ':' mm ':' ss ('.' s+)? (zzzzzz)?
  if ( ( ATime.Hour < 0 ) or ( ATime.Hour > 23 ) ) or
     ( ( ATime.Minute < 0 ) or ( ATime.Minute > 59 ) ) or
     ( ( ATime.Second < 0 ) or ( ATime.Second > 59 ) ) or
     ( ATime.MilliSecond < 0 )
  then begin
    buffer := Format('{ Hour : %d; Minute : %d; Second : %d; SecondFractional : %d}',[ATime.Hour,ATime.Minute,ATime.Second,ATime.MilliSecond]);
    raise EConvertError.CreateFmt(SERR_InvalidTime,[buffer]);
  end;
  if ( ATime.MilliSecond = 0 ) then
    buffer := Format('%.2d:%.2d:%.2d',[ATime.Hour,ATime.Minute,ATime.Second])
  else
    buffer := Format('%.2d:%.2d:%.2d.%.3d',[ATime.Hour,ATime.Minute,ATime.Second,ATime.MilliSecond]);
  if ( ATime.HourOffset <> 0 ) then begin
    if ( ATime.HourOffset > 0 ) then
      buffer := Format('%s+%.2d',[buffer,ATime.HourOffset])
    else
      buffer := Format('%s-%.2d',[buffer,-ATime.HourOffset]);
    if ( ATime.MinuteOffset > 0 ) then
      buffer := Format('%s:%.2d',[buffer,ATime.MinuteOffset])
    else if ( ATime.MinuteOffset < 0 ) then
      buffer := Format('%s:%.2d',[buffer,-ATime.MinuteOffset]);
  end else if ( ATime.MinuteOffset <> 0 ) then begin
    if ( ATime.MinuteOffset > 0 ) then
      buffer := Format('%s+00:%.2d',[buffer,ATime.MinuteOffset])
    else if ( ATime.MinuteOffset < 0 ) then
      buffer := Format('%s-00:%.2d',[buffer,-ATime.MinuteOffset]);
  end;
  if ( ATime.HourOffset = 0 ) and ( ATime.MinuteOffset = 0 ) then
    buffer := buffer + 'Z';
  Result := buffer;
end;

function xsd_TryStrToTime(const AStr : string; out ADate : TTimeRec) : Boolean;
const
  TIME_SEP_CHAR = ':';
var
  buffer : string;
  bufferPos, bufferLen : Integer;

  function ReadInt(out AValue : Integer; const ASeparatorAtEnd : Char) : Boolean;
  var
    locStartPos : Integer;
  begin
    while ( bufferPos <= bufferLen ) and ( buffer[bufferPos] < #33 ) do begin
      Inc(bufferPos);
    end;
    locStartPos := bufferPos;
    if ( bufferPos <= bufferLen ) and ( buffer[bufferPos] in ['-','+'] ) then
      Inc(bufferPos);
    while ( bufferPos <= bufferLen ) and ( buffer[bufferPos] in ['0'..'9'] ) do begin
      Inc(bufferPos);
    end;
    Result := ( bufferPos > locStartPos ) and
              ( ( ASeparatorAtEnd = #0 ) or
                ( ( bufferPos <= bufferLen ) and
                  ( buffer[bufferPos] = ASeparatorAtEnd )
                )
              );
    if Result then
      Result := TryStrToInt(Copy(buffer,locStartPos,(bufferPos-locStartPos)),AValue);
  end;

var
  hh, mn, ss, ssss : Integer;
  tz_hh, tz_mn : Integer;
  tz_negative : Boolean;
  ok : Boolean;
begin
  //hh ':' mm ':' ss ('.' s+)? (zzzzzz)?
  buffer := Trim(AStr);
  bufferPos := 1;
  bufferLen := Length(buffer);
  ok := False;
  if ( bufferLen > 0 ) then begin
    if ReadInt(hh,#0) then begin
      Inc(bufferPos);
      mn := 0;
      ss := 0;
      ssss := 0;
      tz_hh := 0;
      tz_mn := 0;
      ok := True;
      if ( bufferPos < bufferLen ) then begin
        ok := ( buffer[bufferPos -1] = TIME_SEP_CHAR ) and ReadInt(mn,#0);
        if ok then begin
          Inc(bufferPos);
          if ( bufferPos < bufferLen ) then begin
            ok := ReadInt(ss,#0);
            if ok then begin
              if ( bufferPos < bufferLen ) then begin
                if ( buffer[bufferPos] = '.' ) then begin
                  Inc(bufferPos);
                  ok := ReadInt(ssss,#0);
                end else begin
                  ssss := 0;
                end;
                if ok and ( bufferPos < bufferLen ) then begin
                  ok := ( buffer[bufferPos] in ['+','-'] );
                  if ok then begin
                    tz_negative := ( buffer[bufferPos] = '-' );
                    Inc(bufferPos);
                    ok := ReadInt(tz_hh,#0);
                    if ok then begin
                      Inc(bufferPos);
                      if ( bufferPos < bufferLen ) then
                        ok := ReadInt(tz_mn,#0)
                      else
                        tz_mn := 0;
                      if ok and tz_negative then begin
                        tz_hh := -tz_hh;
                        tz_mn := -tz_mn;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
      if ok then begin
        ok := ( ( hh = 24 ) and ( mn = 0 ) and ( ss = 0 ) and ( ssss = 0 )
              ) or
              ( ( hh >= 0 ) and ( hh < 24 ) and
                ( mn >= 0 ) and ( mn < 60 ) and
                ( ss >= 0 ) and ( ss < 60 ) and
                ( ssss >= 0 ) and ( ssss < 1000 )
              );
        ok := ok and
              ( tz_hh > -60 ) and ( tz_hh < 60 ) and
              ( tz_mn > -60 ) and ( tz_mn < 60 );
      end;
      if ok then begin
        ADate.Hour := hh;
        ADate.Minute := mn;
        ADate.Second := ss;
        ADate.MilliSecond := ssss;
        ADate.HourOffset := tz_hh;
        ADate.MinuteOffset := tz_mn;
      end;
    end;
  end;
  Result := ok;
end;

function xsd_StrToTime(const AStr : string) : TTimeRec;
begin
  if not xsd_TryStrToTime(AStr,Result) then
    raise EConvertError.CreateFmt(SERR_InvalidTime,[AStr]);
end;

function xsd_EncodeTime(
  const AHour,
        AMin,
        ASec     : Byte;
  const AMiliSec : Word
) : TTimeRec;
begin
  Result := xsd_EncodeTime(AHour,AMin,ASec,AMiliSec,0,0);
end;

function xsd_EncodeTime(
  const AHour,
        AMin,
        ASec     : Byte;
  const AMiliSec : Word;
  const AHourOffset   : Shortint;
  const AMinuteOffset : Shortint
) : TTimeRec;
begin
  Result.Hour := AHour;
  Result.Minute := AMin;
  Result.Second := ASec;
  Result.MilliSecond := AMiliSec;
  Result.HourOffset := AHourOffset;
  Result.MinuteOffset := AMinuteOffset;
end;

function DateTimeToTimeRec(const ADateTime : TDateTime) : TTimeRec;
var
  hh, mn, ss, ssss : Word;
begin
  DecodeTime(ADateTime,hh,mn,ss,ssss);
  Result.Hour := hh;
  Result.Minute := mn;
  Result.Second := ss;
  Result.MilliSecond := ssss;
end;

function TimeRecToDateTime(const ATime : TTimeRec) : TDateTime;
begin
  Result := EncodeTime(ATime.Hour,ATime.Minute,ATime.Second,ATime.MilliSecond);
end;

end.
