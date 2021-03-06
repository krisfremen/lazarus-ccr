{ Classes for interpreting the output of svn commands

  Copyright (C) 2007 Vincent Snijders vincents@freepascal.org

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
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
unit SvnCommand;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  process,
  FileUtil;

function ExecuteSvnCommand(const Command: string; Output: TStream): integer;
function ExecuteSvnCommand(const Command: string): integer;
procedure DumpStream(const AStream: TStream);
function GetSvnVersionNumber: string;

property SvnVersion: string read GetSvnVersionNumber;

var
  SvnExecutable: string;

implementation

var
  SvnVersionNumber: string;

procedure InitializeSvnVersionNumber;
var
  OutputStream: TStream;
  FirstDot, SecondDot: integer;
begin
  OutputStream := TMemoryStream.Create;
  try
    ExecuteSvnCommand('--version --quiet', OutputStream);
    SetLength(SvnVersionNumber, OutputStream.Size);
    OutputStream.Seek(0,soBeginning);
    OutputStream.Read(SvnVersionNumber[1],Length(SvnVersionNumber));
  finally
    OutputStream.Free;
  end;
end;

procedure InitializeSvnExecutable;
begin
  if FileExists(SvnExecutable) then exit;
{$IFDEF windows}
  SvnExecutable := GetEnvironmentVariable('ProgramFiles') + '\Subversion\bin\svn.exe';
{$ENDIF}
  if not FileExists(SvnExecutable) then
    SvnExecutable := FindDefaultExecutablePath('svn');
  if not FileExists(SvnExecutable) then
    raise Exception.Create('No svn executable found');
end;

function ExecuteSvnCommand(const Command: string; Output: TStream): integer;
var
  SvnProcess: TProcess;
  
  function ReadOutput: boolean;
  // returns true if output was actually read
  const
    BufSize = 4096;
  var
    Buffer: array[0..BufSize-1] of byte;
    ReadBytes: integer;
  begin
    Result := false;
    while SvnProcess.Output.NumBytesAvailable>0 do begin
      ReadBytes := SvnProcess.Output.Read(Buffer, BufSize);
      Output.Write(Buffer, ReadBytes);
      Result := true;
    end;
  end;
  
  function GetOutput: string;
  begin
    SetLength(Result, Output.Size);
    Output.Seek(0,soBeginning);
    Output.Read(Result[1],Length(Result));
  end;
begin
  if SvnExecutable='' then InitializeSvnExecutable;

  SvnProcess := TProcess.Create(nil);
  try
    SvnProcess.CommandLine := SvnExecutable + ' ' + Command;
    SvnProcess.Options := [poUsePipes];
    SvnProcess.ShowWindow := swoHIDE;
    SvnProcess.Execute;
    while SvnProcess.Running do begin
      if not ReadOutput then
        Sleep(100);
    end;
    ReadOutput;
    Result := SvnProcess.ExitStatus;
    if Result<>0 then begin
      Raise Exception.CreateFmt(
        'svn %s failed: Result %d' + LineEnding + '%s',
        [Command, Result, GetOutput]);
    end;
  finally
    SvnProcess.Free;
  end;
end;

function ExecuteSvnCommand(const Command: string): integer;
var
  Output: TMemoryStream;
begin
  Output := TMemoryStream.Create;
  try
    Result := ExecuteSvnCommand(Command, Output);
  finally
    Output.Free;
  end;
end;

procedure DumpStream(const AStream: TStream);
var
  lines: TStrings;
begin
  lines := TStringList.Create;
  AStream.Position := 0;
  lines.LoadFromStream(AStream);
  writeln(lines.Text);
  lines.Free;
end;

function GetSvnVersionNumber: string;
begin
  if SvnVersionNumber='' then
    InitializeSvnVersionNumber;
  Result := SvnVersionNumber;
end;


end.

