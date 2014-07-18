unit fpsStreams;

interface

uses
  SysUtils, Classes;

const
  DEFAULT_STREAM_BUFFER_SIZE = 1024; // * 1024;

type
  { A buffered stream }
  TBufStream = class(TStream)
  private
    FFileStream: TFileStream;
    FMemoryStream: TMemoryStream;
    FBufWritten: Boolean;
    FBufSize: Int64;
    FKeepTmpFile: Boolean;
    FFileName: String;
  protected
    procedure CreateFileStream;
    function GetPosition: Int64; override;
    function GetSize: Int64; override;
  public
    constructor Create(ATempFile: String; AKeepFile: Boolean = false;
      ABufSize: Cardinal = DEFAULT_STREAM_BUFFER_SIZE); overload;
    constructor Create(ABufSize: Cardinal = DEFAULT_STREAM_BUFFER_SIZE); overload;
    destructor Destroy; override;
    procedure FlushBuffer;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function Write(const ABuffer; ACount: Longint): Longint; override;
  end;

procedure ResetStream(var AStream: TStream);

implementation

uses
  Math;

{ Resets the stream position to the beginning of the stream. }
procedure ResetStream(var AStream: TStream);
begin
  AStream.Position := 0;
end;


constructor TBufStream.Create(ATempFile: String; AKeepFile: Boolean = false;
  ABufSize: Cardinal = DEFAULT_STREAM_BUFFER_SIZE);
begin
  if ATempFile = '' then
    ATempFile := ChangeFileExt(GetTempFileName, '.~abc');
  // Change extension because of naming conflict if the name of the main file
  // is determined by GetTempFileName also. Happens in internaltests suite.
  FFileName := ATempFile;
  FKeepTmpFile := AKeepFile;
  FMemoryStream := TMemoryStream.Create;
  // The file stream is only created when needed because of possible conflicts
  // of random file names.
  FBufSize := ABufSize;
end;

constructor TBufStream.Create(ABufSize: Cardinal = DEFAULT_STREAM_BUFFER_SIZE);
begin
  Create('', false, ABufSize);
end;

destructor TBufStream.Destroy;
begin
  // Write current buffer content to file
  FlushBuffer;

  // Free streams and delete temporary file, if requested
  FreeAndNil(FMemoryStream);
  FreeAndNil(FFileStream);
  if not FKeepTmpFile and (FFileName <> '') then DeleteFile(FFileName);

  inherited Destroy;
end;

{ Creation of the file stream is delayed because of naming conflicts of other
  streams are needed with random file names as well (the files do not yet exist
  when the streams are created and therefore get the same name by GetTempFileName! }
procedure TBufStream.CreateFileStream;
begin
  if FFileStream = nil then begin
    if FFileName = '' then FFileName := ChangeFileExt(GetTempFileName, '.~abc');
    FFileStream := TFileStream.Create(FFileName, fmCreate + fmOpenRead);
  end;
end;

{ Flushes the contents of the memory stream to file }
procedure TBufStream.FlushBuffer;
begin
  if (FMemoryStream.Size > 0) and not FBufWritten then begin
    FMemoryStream.Position := 0;
    CreateFileStream;
    FFileStream.CopyFrom(FMemoryStream, FMemoryStream.Size);
    FMemoryStream.Clear;
    FBufWritten := true;
  end;
end;

{ Returns the buffer position. This is the buffer position of the bytes written
  to file, plus the current position in the memory buffer }
function TBufStream.GetPosition: Int64;
begin
  if FFileStream = nil then
    Result := FMemoryStream.Position
  else
    Result := FFileStream.Position + FMemoryStream.Position;
end;

function TBufStream.GetSize: Int64;
var
  n: Int64;
begin
  if FFileStream <> nil then
    n := FFileStream.Size
  else
    n := 0;
  if n = 0 then n := FMemoryStream.Size;
  Result := Max(n, GetPosition);
end;

function TBufStream.Read(var Buffer; Count: Longint): Longint;
begin
  // Case 1: All "Count" bytes are contained in memory stream
  if FMemoryStream.Position + Count <= FMemoryStream.Size then begin
    Result := FMemoryStream.Read(Buffer, Count);
    exit;
  end;

  // Case 2: Memory stream is empty
  if FMemoryStream.Size = 0 then begin
    CreateFileStream;
    Result := FFileStream.Read(Buffer, Count);
    exit;
  end;

  // Case 3: Memory stream is not empty but contains only part of the bytes requested
  FlushBuffer;
  Result := FFileStream.Read(Buffer, Count);
end;

function TBufStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  oldPos: Int64;
  newPos: Int64;
begin
  oldPos := GetPosition;
  case Origin of
    soBeginning : newPos := Offset;
    soCurrent   : newPos := oldPos + Offset;
    soEnd       : newPos := GetSize - Offset;
  end;

  // case #1: New position is within buffer, no file stream yet
  if (FFileStream = nil) and (newPos < FMemoryStream.Size) then begin
    FMemoryStream.Position := newPos;
    exit;
  end;

  CreateFileStream;

  // case #2: New position is within buffer, file stream exists
  if (newPos >= FFileStream.Position) and (newPos < FFileStream.Position + FMemoryStream.Size)
  then begin
    FMemoryStream.Position := newPos - FFileStream.Position;
    exit;
  end;

  // case #3: New position is outside buffer
  FlushBuffer;
  FFileStream.Position := newPos;
end;

function TBufStream.Write(const ABuffer; ACount: LongInt): LongInt;
var
  savedPos: Int64;
begin
  // Case #1: Bytes fit into buffer
  if FMemoryStream.Position + ACount < FBufSize then begin
    Result := FMemoryStream.Write(ABuffer, ACount);
    FBufWritten := false;
    exit;
  end;

  // Case #2: Buffer would overflow
  savedPos := GetPosition;
  FlushBuffer;
  FFileStream.Position := savedPos;
  Result := FFileStream.Write(ABuffer, ACount);
end;


end.
