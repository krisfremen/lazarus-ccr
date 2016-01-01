{
 *****************************************************************************
 *                                                                           *
 *  This file is part of the iPhone Laz Extension                            *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
unit LazFilesUtils;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef Unix}BaseUnix,{$endif}
  Classes, SysUtils, FileUtil, LazFileUtils, Masks,
  LazIDEIntf, ProjectIntf, process;

function ResolveProjectPath(const path: string; project: TLazProject = nil): string;

function BreakPathsStringToOption(const Paths, Switch: String;
  const Quotes: string = '"'; project: TLazProject = nil; AResolvePath: Boolean = false): String;

function RelativeToFullPath(const BasePath, Relative: string): String;
function NeedQuotes(const path: string): Boolean;

function CopySymLinks(const SrcDir, DstDir, FilterMask: string): Boolean;

procedure EnumFilesAtDir(const PathUtf8 : AnsiString; Dst: TStrings);
procedure EnumFilesAtDir(const PathUtf8, AMask : AnsiString; Dst: TStrings);
procedure ExecCmdLineNoWait(const CmdLineUtf8: AnsiString);
function ExecCmdLineStdOut(const CmdLineUtf8: AnsiString; var StdOut: string; var ErrCode: LongWord): Boolean;

implementation

{$ifdef Unix}
function CopySymLinks(const SrcDir, DstDir, FilterMask: string): Boolean;
var
  allfiles  : TStringList;
  i         : Integer;
  pth       : string;
  MaskList  : TMaskList;
  curdir    : string;
  linkdir   : string;
  linkname  : string;
begin
  Result:=DirectoryExistsUTF8(SrcDir) and ForceDirectoriesUTF8(DstDir);
  if not Result then Exit;

  //todo: don't use FindAllFiles(), use sub dir search

  allfiles:=FindAllFiles(SrcDir, AllFilesMask, False);
  Result:=Assigned(allfiles);
  if not Result then Exit;

  MaskList := TMaskList.Create(FilterMask);

  curdir:=IncludeTrailingPathDelimiter(SrcDir);
  linkdir:=IncludeTrailingPathDelimiter(DstDir);
  for i:=0 to allfiles.Count-1 do begin
    pth:=allfiles[i];
    if (FilterMask='') or (not MaskList.Matches(pth)) then begin
      linkname:=linkdir+Copy(pth, length(curdir), length(pth));
      fpSymlink(PAnsiChar(pth), PAnsiChar(linkname));
    end;
  end;
  allfiles.Free;
end;
{$else}
function CopySymLinks(const SrcDir, DstDir, FilterMask: string): Boolean;
begin
  Result:=false;
end;
{$endif}


function GetNextDir(const Path: string; var index: integer; var Name: string): Boolean;
var
  i : Integer;
begin
  Result:=index<=length(Path);
  if not Result then Exit;

  if Path[index]=PathDelim then inc(index);
  Result:=index<=length(Path);
  if not Result then Exit;

  for i:=index to length(Path) do
    if Path[i]=PathDelim then begin
      Name:=Copy(Path, index, i - index);
      index:=i+1;
      Exit;
    end;
  Name:=Copy(Path, index, length(Path) - index+1);
  index:=length(Path)+1;
end;

function RelativeToFullPath(const BasePath, Relative: string): String;
var
  i  : integer;
  nm : string;
begin
  Result:=ExcludeTrailingPathDelimiter(BasePath);
  i:=1;
  while GetNextDir(Relative, i, nm) do
    if nm = '..' then
      Result:=ExtractFileDir(Result)
    else if nm <> '.' then
      Result:=IncludeTrailingPathDelimiter(Result)+nm;
end;

function NeedQuotes(const path: string): Boolean;
var
  i : integer;
const
  SpaceChars = [#32,#9];
begin
  for i:=1 to length(path) do
    if path[i] in SpaceChars then begin
      Result:=true;
      Exit;
    end;
  Result:=false;
end;

function QuoteStrIfNeeded(const path: string; const quotes: String): String;
begin
  if NeedQuotes(path) then
    Result:=quotes+path+quotes
  else
    Result:=path;
end;

function ResolveProjectPath(const path: string; project: TLazProject): string;
var
  base : string;
begin
  if project=nil then project:=LazarusIDE.ActiveProject;

  if FilenameIsAbsolute(Path) then
    Result:=Path
  else begin
    base:='';
    base:=ExtractFilePath(project.ProjectInfoFile);
    Result:=RelativeToFullPath(base, Path);
  end;
end;

function BreakPathsStringToOption(const Paths, Switch, Quotes: String; project: TLazProject; AResolvePath: Boolean): String;
var
  i, j  : Integer;
  fixed : String;
begin
  Result:='';
  if not Assigned(project) then
    project:=LazarusIDE.ActiveProject;

  if not Assigned(project) then Exit;

  j:=1;
  for i:=1 to length(paths)-1 do
    if Paths[i]=';' then begin
      fixed:=Trim(Copy(paths,j, i-j)  );
      if fixed<>'' then begin
        if AResolvePath then fixed:=ResolveProjectPath(fixed, project);
        Result:=Result+' ' + Switch + QuoteStrIfNeeded(fixed, quotes);
      end;
      j:=i+1;
    end;

  fixed:=Trim(Copy(paths,j, length(paths)-j+1)  );
  if fixed<>'' then begin
    if AResolvePath then fixed:=ResolveProjectPath(fixed, project);
    Result:=Result+' ' + Switch + QuoteStrIfNeeded(fixed, quotes);
  end;
end;

procedure EnumFilesAtDir(const PathUtf8, AMask : AnsiString; Dst: TStrings);
var
  mask  : TMask;
  sr    : TSearchRec;
  path  : AnsiString;
begin
  if (AMask='') or (trim(AMask)='*') then mask:=nil else mask:=TMask.Create(AMask);
  try
    path:=IncludeTrailingPathDelimiter(PathUtf8);
    if FindFirstUTF8(path+AllFilesMask, faAnyFile, sr) = 0 then begin
      repeat
        if (sr.Name<>'.') and (sr.Name<>'..') then
          if not Assigned(mask) or mask.Matches(sr.Name) then
            Dst.Add(path+sr.Name);
      until FindNextUTF8(sr)<>0;
      FindCloseUTF8(sr);
    end;
  finally
    mask.Free;
  end;
end;

procedure EnumFilesAtDir(const PathUtf8 : AnsiString; Dst: TStrings);
begin
  EnumFilesAtDir(PathUTF8, AllFilesMask, Dst);
end;

procedure ExecCmdLineNoWait(const CmdLineUtf8: AnsiString);
var
  proc  : TProcess;
begin
  proc:=TProcess.Create(nil);
  try
    proc.CommandLine:=CmdLineUtf8;
    proc.Options := [poUsePipes,poNoConsole,poStderrToOutPut];
    proc.Execute;
  finally
    proc.Free;
  end;
end;

function ExecCmdLineStdOut(const CmdLineUtf8: AnsiString; var StdOut: string; var ErrCode: LongWord): Boolean;
var
  //OurCommand   : String;
  //OutputLines  : TStringList;
  MemStream    : TStringStream;
  OurProcess   : TProcess;
  //NumBytes     : LongInt;
begin
  // A temp Memorystream is used to buffer the output
  MemStream := TStringStream.Create('');

  OurProcess := TProcess.Create(nil);
  try
    OurProcess.CommandLine := CmdLineUtf8;
    //OurProcess.Executable := CmdLineUtf8;
    //OurProcess.Parameters.Add(OurCommand);

    // We cannot use poWaitOnExit here since we don't
    // know the size of the output. On Linux the size of the
    // output pipe is 2 kB; if the output data is more, we
    // need to read the data. This isn't possible since we are
    // waiting. So we get a deadlock here if we use poWaitOnExit.
    OurProcess.Options := [poUsePipes];
    OurProcess.Execute;
    while True do
    begin
      // make sure we have room
      //MemStream.SetSize(BytesRead + READ_BYTES);

      // try reading it
      if OurProcess.Output.NumBytesAvailable > 0 then
        MemStream.CopyFrom(OurProcess.Output, OurProcess.Output.NumBytesAvailable)
      else begin
        if not OurProcess.Active then
          Break; // Program has finished execution.
      end;

    end;
    //MemStream.SetSize(BytesRead);

    //OutputLines := TStringList.Create;
    //OutputLines.LoadFromStream(MemStream);
    //OutputLines.Free;

    StdOut:=MemStream.DataString;
    Result:=true;
  finally
    OurProcess.Free;
    MemStream.Free;
  end;
end;


end.

