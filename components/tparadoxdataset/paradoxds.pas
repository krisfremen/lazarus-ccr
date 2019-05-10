unit paradoxds;

{ TParadoxdataSet
  Christian Ulrich christian@ullihome.de
  License: LGPL
}

{$mode objfpc}{$H+}

interface

uses                               
  Classes, SysUtils, db, lconvencoding;


const
    { Paradox codes for field types }
    pxfAlpha        = $01;
    pxfDate         = $02;
    pxfShort        = $03;
    pxfLong         = $04;
    pxfCurrency     = $05;
    pxfNumber       = $06;
    pxfLogical      = $09;
    pxfMemoBLOb     = $0C;
    pxfBLOb         = $0D;
    pxfFmtMemoBLOb  = $0E;
    pxfOLE          = $0F;
    pxfGraphic      = $10;
    pxfTime         = $14;
    pxfTimestamp    = $15;
    pxfAutoInc      = $16;
    pxfBCD          = $17;
    pxfBytes        = $18;


type
  {Internal Record information}
  PRecInfo = ^TRecInfo;
  TRecInfo = packed record
    RecordNumber: PtrInt;
    BookmarkFlag: TBookmarkFlag;
  end;
  
  PLongWord = ^Longword;

  { field information record used in TPxHeader below }
  PFldInfoRec = ^TFldInfoRec;
  TFldInfoRec = packed record
    fType: byte;
    fSize: byte;
  end;

  PPxHeader = ^TPxHeader;
  TPxHeader =  packed record
    recordSize              :  word;
    headerSize              :  word;
    fileType                :  byte;
    maxTableSize            :  byte;
    numRecords              :  longint;
    nextBlock               :  word;
    fileBlocks              :  word;
    firstBlock              :  word;
    lastBlock               :  word;
    unknown12x13            :  word;
    modifiedFlags1          :  byte;
    indexFieldNumber        :  byte;
    primaryIndexWorkspace   :  longint;   // currently not used; cast to "pointer"
    unknownPtr1A            :  longint;   // not used; cast to pointer;
    unknown1Ex20            :  array[$001E..$0020] of byte;
    numFields               :  smallint;
    primaryKeyFields        :  smallint;
    encryption1             :  longint;
    sortOrder               :  byte;
    modifiedFlags2          :  byte;
    unknown2Bx2C            :  array[$002B..$002C] of byte;
    changeCount1            :  byte;
    changeCount2            :  byte;
    unknown2F               :  byte;
    tableNamePtrPtr         :  longint;  // must be cast to ^pchar
    fldInfo                 :  longint;  // use FFieldInfoPtr instead
    writeProtected          :  byte;
    fileVersionID           :  byte;
    maxBlocks               :  word;
    unknown3C               :  byte;
    auxPasswords            :  byte;
    unknown3Ex3F            :  array[$003E..$003F] of byte;
    cryptInfoStartPtr       :  longint;    // not used; cast to pointer
    cryptInfoEndPtr         :  longint;    // not used; cast to pointer
    unknown48               :  byte;
    autoIncVal              :  longint;
    unknown4Dx4E            :  array[$004D..$004E] of byte;
    indexUpdateRequired     :  byte;
    unknown50x54            :  array[$0050..$0054] of byte;
    refIntegrity            :  byte;
    unknown56x57            :  array[$0056..$0057] of byte;
    case smallint of
      3:   (fieldInfo35     :  array[1..255] of TFldInfoRec);
      4:   (fileVerID2      :  smallint;
            fileVerID3      :  smallint;
            encryption2     :  longint;
            fileUpdateTime  :  longint;  { 4.0 only }
            hiFieldID       :  word;
            hiFieldIDinfo   :  word;
            sometimesNumFields:smallint;
            dosCodePage     :  word;
            unknown6Cx6F    :  array[$006C..$006F] of byte;
            changeCount4    :  smallint;
            unknown72x77    :  array[$0072..$0077] of byte;
            fieldInfo       :  array[1..255] of TFldInfoRec);

    { This is only the first part of the file header.  The last field
      is described as an array of 255 elements, but its size is really
      determined by the number of fields in the table.  The actual
      table header has more information that follows. }
  end;

  {Paradox Data Block Header}
  PDataBlock  = ^TDataBlock;
  TDataBlock  = packed RECORD
    nextBlock     : word;
    prevBlock     : word;
    addDataSize   : smallint;
    fileData      : array[0..$0FF9] of byte;
    { fileData size varies according to maxTableSize }
  end;

{  APdoxBlk = packed record
    Next,
    Prev,
    Last: Word;
  end;}

  {10-byte Blob Info Block}
  TPxBlobInfo = packed record
    FileLoc: LongWord;
    Length: LongWord;
    ModCount: Word;
  end;

  {Blob Pointer Array Entry}
  TPxBlobIndex = packed record
    Offset: Byte;
    Len16: Byte;
    ModCount: Word;
    Len: Byte;
  end;


  { TParadoxDataSet }

  TParadoxDataSet = class(TDataSet)
  private
    FActive: Boolean;
    FStream: TStream;
    FBlobStream: TStream;
    FFileName: TFileName;
    FHeader: PPxHeader;
    FaRecord: Longword;
    FaBlockstart: LongInt;
    FaBlock: PDataBlock;
    FaBlockIdx: word;
    FBlockReaded: Boolean;
    FBookmarkOfs: LongWord;
    FFieldInfoPtr: PFldInfoRec;
    FTableNameLen: Integer;
    FInputEncoding: String;
    FTargetEncoding: String;

    procedure SetFileName(const AValue: TFileName);
    function GetEncrypted: Boolean;
    function GetInputEncoding: String; inline;
    function GetTargetEncoding: String; inline;
    function GetVersion: real;
    function IsStoredTargetEncoding: Boolean;
    procedure ReadBlock;
    procedure ReadNextBlockHeader;
    procedure ReadPrevBlockHeader;
    procedure SetTargetEncoding(AValue: String);
  protected
    procedure InternalOpen; override;
    procedure InternalClose; override;
    procedure InternalInitFieldDefs; override;
    function  AllocRecordBuffer: PChar; override;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    function  GetRecordCount: Integer; override;
    function  IsCursorOpen: Boolean; override;
    procedure InternalFirst; override;
    procedure InternalHandleException; override;
    procedure InternalInitRecord(Buffer: PChar); override;
    procedure InternalLast; override;
    procedure InternalPost; override;
    procedure InternalEdit; override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    procedure InternalGotoBookmark(ABookmark: Pointer); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function  GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    function  GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function  GetRecordSize: Word; override;
    function  GetCanModify: Boolean;override;
    procedure SetRecNo(Value: Integer); override;
    function  GetRecNo: Integer; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    property Encrypted: Boolean read GetEncrypted;
  published
    property TableName: TFileName read FFileName write SetFileName;
    property TableLevel: real read GetVersion;
    property InputEncoding: String read GetInputEncoding;
    property TargetEncoding: string read FTargetEncoding write SetTargetEncoding stored IsStoredTargetEncoding;
    property FieldDefs;
    property Active;
    property AutoCalcFields;
    property Filtered;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
//    property BeforeRefresh;
//    property AfterRefresh;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

implementation

uses
  Forms;

{ TParadoxDataSet }

procedure TParadoxDataSet.SetFileName(const AValue: TFileName);
begin
  if Active then
    Close;
  FFilename := AValue;
end;

function TParadoxDataSet.GetEncrypted: Boolean;
begin
  if not Assigned(FHeader) then exit;
  If (FHeader^.fileVersionID <= 4) or not (FHeader^.fileType in [0,2,3,5]) then
    Result := (FHeader^.encryption1 <> 0)
  else
    Result := (FHeader^.encryption2 <> 0)
end;

function TParadoxDataset.GetInputEncoding: String;
begin
  if FInputEncoding = '' then
    Result := GetDefaultTextEncoding
  else
    Result := FInputEncoding;
end;

function TParadoxDataset.GetTargetEncoding: String;
begin
  if (FTargetEncoding = '') or SameText(FTargetEncoding, 'utf-8') then
    Result := EncodingUTF8
  else
    Result := FTargetEncoding;
end;

function TParadoxDataset.IsStoredTargetEncoding: Boolean;
begin
  Result := not SameText(FTargetEncoding, EncodingUTF8);
end;

procedure TParadoxDataSet.ReadBlock;
var
  L   : longint;
begin
  L := FaBlockIdx-1;
  L := (L * FHeader^.maxTableSize * $0400) + FHeader^.headerSize;
  FStream.Position := L;
  FStream.Read(FaBlock^, FHeader^.maxTableSize * $0400);
  FBlockReaded := True;
end;

procedure TParadoxDataSet.ReadNextBlockHeader;
var
  L   : longint;
begin
  if FaBlock^.nextBlock = 0 then exit; //last block
  //Increment Blockstart
  FaBlockStart := FaBlockStart+(FaBlock^.addDataSize div FHeader^.recordSize)+1;
  FaRecord := FaBlockStart+1;
  L := FaBlock^.nextBlock-1;
  L := (L * FHeader^.maxTableSize * $0400) + FHeader^.headerSize;
  FaBlockIdx := FaBlock^.nextBlock;
  FBlockReaded := False;
  FStream.Position := L;
  FStream.Read(FaBlock^,6); //read only Block header
end;

procedure TParadoxDataSet.ReadPrevBlockHeader;
var
  L: LongWord;
begin
  L := FaBlock^.prevBlock-1;
  L := (L * FHeader^.maxTableSize * $0400) + FHeader^.headerSize;
  FaBlockIdx := FaBlock^.prevBlock;
  FBlockReaded := False;
  FStream.Position := L;
  FStream.Read(FaBlock^,6); //read only Block header
  //decrement Blockstart
  L := ((FaBlock^.addDataSize div FHeader^.recordSize)+1);
  FaBlockStart := FaBlockStart-L;
  FaRecord := FaBlockStart+1;
end;

function TParadoxDataSet.GetVersion: real;
begin
  Result := 0;
  if not FActive then exit;
  if not Assigned(FHeader) then exit;
  case FHeader^.fileVersionID of
  $3:Result := 3.0;
  $4:Result := 3.5;
  $5..$9:Result := 4.0;
  $a..$b:Result := 5.0;
  $c:Result := 7.0;
  end;
end;

procedure TParadoxDataset.SetTargetEncoding(AValue: String);
begin
  if AValue = FTargetEncoding then exit;
  FTargetEncoding := Uppercase(AValue);
end;

procedure TParadoxDataSet.InternalOpen;
var
  hdrSize: Word;
  blobfn: String;
  cp: Word;
begin
  if FFileName = '' then
    DatabaseError('Tablename is not set');
  if not FileExists(FFileName) then
    DatabaseError(Format('Paradox file "%" does not exist.', [FFileName]));

  FStream := TFileStream.Create(FFilename,fmOpenRead or fmShareDenyNone);
  FStream.Position := 2;
  hdrSize := FStream.ReadWord;
  FHeader := AllocMem(hdrSize);
  FStream.Position := 0;
  if not FStream.Read(FHeader^, hdrSize) = hdrSize then
    DatabaseError('No valid Paradox file !');
  if not ((FHeader^.maxTableSize >= 1) and (FHeader^.maxTableSize <= 32)) then
    DatabaseError('No valid Paradox file !');

  if (FHeader^.fileVersionID >= 12) then
    FTableNameLen := 261
  else
    FTableNameLen := 79;

  if (FHeader^.fileVersionID <= 4) or not (FHeader^.FileType in [0,2,3,5]) then
    FFieldInfoPtr := @FHeader^.FieldInfo35
   else begin
     FFieldInfoPtr := @FHeader^.FieldInfo;
     cp := FHeader^.DosCodePage;
     FInputEncoding := 'cp' + IntToStr(cp);
   end;

  if Encrypted then
    exit;

  FBlobStream := nil;
  blobfn := ChangeFileExt(FFileName, '.mb');
  if FileExists(blobfn) then
    FBlobStream := TFileStream.Create(blobfn, fmOpenRead + fmShareDenyNone)
  else begin
    blobfn := ChangeFileExt(FFileName, '.MB');
    if FileExists(blobfn) then
      FBlobStream := TFileStream.Create(blobfn, fmOpenRead + fmShareDenyNone);
  end;

  FaBlock := AllocMem(FHeader^.maxTableSize * $0400);
  BookmarkSize := SizeOf(longword);
  InternalFirst;
  InternalInitFieldDefs;
  if DefaultFields then CreateFields;
  BindFields(True);
  FActive := True;
end;

procedure TParadoxDataSet.InternalClose;
begin
  BindFields(FALSE);
  if DefaultFields then // Destroy the TField
    DestroyFields;
  FreeMem(FHeader);
  FreeMem(FaBlock);
  FreeAndNil(FBlobStream);
  FreeAndNil(FStream);
  FActive := False;
end;

procedure TParadoxDataSet.InternalInitFieldDefs;
var
  i: integer;
  F: PFldInfoRec;
  FNamesStart: PChar;
  fname: String;
begin
  FieldDefs.Clear;
  F := FFieldInfoPtr;                  { begin with the first field identifier }
  FNamesStart := Pointer(F);
  inc(FNamesStart, SizeOf(F^)*(FHeader^.numFields));      //Jump over Fielddefs
  inc(FNamesStart, SizeOf(LongInt));                      //over TableName pointer
  inc(FNamesStart, SizeOf(LongInt)*(FHeader^.numFields)); //over FieldName pointers
  inc(FNamesStart, FTableNameLen);                        // over Tablename and padding
  for i := 1 to FHeader^.NumFields do
  begin
    fname := ConvertEncoding(StrPas(FNamesStart), GetInputEncoding, GetTargetEncoding);
    case F^.fType of
      pxfAlpha:       FieldDefs.Add(fname, ftString, F^.fSize);
      pxfDate:        FieldDefs.Add(fname, ftDate, 0);
      pxfShort:       FieldDefs.Add(fname, ftSmallInt, F^.fSize);
      pxfLong:        FieldDefs.Add(fname, ftInteger, F^.fSize);
      pxfCurrency:    FieldDefs.Add(fname, ftCurrency, F^.fSize);
      pxfNumber:      FieldDefs.Add(fname, ftFloat, F^.fSize);
      pxfLogical:     FieldDefs.Add(fname, ftBoolean, 0); //F^.fSize);
      pxfMemoBLOb:    FieldDefs.Add(fname, ftMemo, F^.fSize);
      pxfBLOb:        FieldDefs.Add(fname, ftBlob, F^.fSize);
      pxfFmtMemoBLOb: FieldDefs.Add(fname, ftMemo, F^.fSize);
      pxfOLE:         FieldDefs.Add(fname, ftBlob, F^.fSize);
      pxfGraphic:     FieldDefs.Add(fname, ftGraphic, F^.fSize);  // was: ftBlob
      pxfTime:        FieldDefs.Add(fname, ftTime, 0); //F^.fSize);
      pxfTimestamp:   FieldDefs.Add(fname, ftDateTime, 0);
      pxfAutoInc:     FieldDefs.Add(fname, ftAutoInc, F^.fSize);
      pxfBCD:         FieldDefs.Add(fname, ftBCD, F^.fSize);
      pxfBytes:       FieldDefs.Add(fname, ftBytes, F^.fSize);  // was: ftString
    end;
    inc(FNamesStart, Length(fname)+1);
    inc(F);
  end;
end;

function TParadoxDataSet.AllocRecordBuffer: PChar;
begin
  if Assigned(Fheader) then
    Result := AllocMem(GetRecordSize)
  else
    Result := nil;
end;

procedure TParadoxDataSet.FreeRecordBuffer(var Buffer: PChar);
begin
  if Assigned(Buffer) then
    FreeMem(Buffer);
end;

function TParadoxDataSet.GetRecordCount: Integer;
begin
  if Assigned(FHeader) then
    Result := FHeader^.numRecords
  else
    Result := 0;
end;

function TParadoxDataSet.IsCursorOpen: Boolean;
begin
  Result := FActive;
end;

procedure TParadoxDataSet.InternalFirst;
begin
  FaBlockIdx := FHeader^.firstBlock;
  FaBlockstart := 0;
  FaRecord := 0;
  ReadBlock;
end;

procedure TParadoxDataSet.InternalHandleException;
begin
  Application.HandleException(Self);
end;

procedure TParadoxDataSet.InternalInitRecord(Buffer: PChar);
begin
end;

procedure TParadoxDataSet.InternalLast;
begin
  while FaBlockIdx <> FHeader^.lastBlock do
    ReadNextBlockHeader;
  inc(FaRecord,(FaBlock^.addDataSize div FHeader^.recordSize)+1);
end;

procedure TParadoxDataSet.InternalPost;
begin
end;

procedure TParadoxDataSet.InternalEdit;
begin
end;

procedure TParadoxDataSet.InternalSetToRecord(Buffer: PChar);
begin
  if (State <> dsInsert) then
    InternalGotoBookmark(@PRecInfo(Buffer + FHeader^.recordSize)^.RecordNumber);
end;

procedure TParadoxDataSet.InternalGotoBookmark(ABookmark: Pointer);
begin
  SetrecNo(PLongWord(ABookmark)^);
end;

procedure TParadoxDataSet.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  //TODO
end;

function TParadoxDataSet.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
  Result := PRecInfo(Buffer + FHeader^.recordSize)^.BookmarkFlag;
end;

function TParadoxDataSet.GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  OK : Boolean;
  L: Longword;
begin
  Result := grOK;
  case GetMode of
  gmNext:
    begin
      inc(FaRecord);
      if (FaBlockIdx = FHeader^.lastBlock) and (FaRecord > FaBlockStart+(FaBlock^.addDataSize div FHeader^.recordSize)+1) then
        Result := grEOF
      else
        begin
          if FaRecord > FaBlockStart+1+(FaBlock^.addDataSize div FHeader^.recordSize) then
            ReadNextBlockHeader;
        end;
    end;
  gmPrior:
    begin
      dec(FaRecord);
      if (FaBlockIdx = FHeader^.firstBlock) and (FaRecord < 1) then
        Result := grBOF
      else
        begin
          if FaRecord <= FaBlockStart then
            begin
              ReadPrevBlockHeader;
              FaRecord := FaBlockStart+(FaBlock^.addDataSize div FHeader^.recordSize)+1;
            end;
        end;
    end;
  gmCurrent:
    begin
      if (FaRecord > RecordCount) or (FaRecord < 1) then
        result := grError;
    end;
  end;
  if Result = grOK then
    begin
      if not FBlockreaded then
        ReadBlock;
      L := ((faRecord-(FaBlockstart+1))*FHeader^.recordSize)+6;
      if (faRecord-(FaBlockstart+1)) >= 0 then
        begin
          Move(PChar(FaBlock)[L],Buffer[0],FHeader^.recordSize);
        end
      else
        result := grError;
      with PRecInfo(Buffer + FHeader^.recordSize)^ do
        begin
          BookmarkFlag := bfCurrent;
          RecordNumber := FaRecord;
        end;
    end;
end;

function TParadoxDataSet.GetRecordSize: Word;
begin
  Result := FHeader^.recordSize + sizeof(TRecInfo);
end;

procedure TParadoxDataSet.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
  PRecInfo(Buffer + FHeader^.recordSize)^.BookmarkFlag := Value;
end;

procedure TParadoxDataSet.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  //TODO
end;

procedure TParadoxDataSet.SetFieldData(Field: TField; Buffer: Pointer);
begin
end;

function TParadoxDataSet.GetCanModify: Boolean;
begin
  Result:=False;
end;

procedure TParadoxDataSet.SetRecNo(Value: Integer);
begin
  if Value < FaRecord then
    begin
      while (Value <= FaBlockstart) do
        ReadPrevBlockHeader;
      FaRecord := Value;
    end
  else
    begin
      while (Value > FaBlockstart+((FaBlock^.addDataSize div FHeader^.recordSize)+1)) do
        ReadNextBlockHeader;
      FaRecord := Value;
    end;
end;

function TParadoxDataSet.GetRecNo: Integer;
begin
  Result := -1;
  if Assigned(ActiveBuffer) then
    Result := PRecInfo(ActiveBuffer + FHeader^.recordSize)^.RecordNumber;
end;

function TParadoxDataSet.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  b: WordBool;
  F: PFldInfoRec;
  i: Integer;
  size: Integer;
  p: PChar;
  s: array[0..7] of byte;
  si:  SmallInt absolute s;
  int: LongInt  absolute s;
  d:   Double   absolute s;
  str: String;
begin
  Result := False;
  if (RecordCount = 0) then
    exit;

  F := FFieldInfoPtr;  { begin with the first field identifier }
  p := ActiveBuffer;
  for i := 1 to FHeader^.numFields do
  begin
    if i = Field.FieldNo then
      break;
    if F^.fType = pxfBCD then { BCD field size value not used for field size }
       Inc(p, 17)
     else
      Inc(p, F^.fSize);
    Inc(F);
  end;

  if F^.fType = pxfBCD then { BCD field size value not used for field size }
    size := 17
  else
    size := F^.fSize;

  // These numeric fields are stored as big endian
  if F^.fType in [pxfDate..pxfNumber, pxfTime..pxfAutoInc] then begin
    for i := 0 to pred(size) do
       s[pred(size-i)] := byte(p[i]);
    s[pred(size)] := s[pred(size)] xor $80;
  end;

  case F^.fType of
  pxfAlpha:
    if (Buffer <> nil) then begin
      str := ConvertEncoding(StrPas(p), GetInputEncoding, GetTargetEncoding);
      if str <> '' then begin
        StrLCopy(Buffer, PChar(str), Length(str));
        Result := true;
      end;
    end;
  pxfBytes:
    if Buffer <> nil then begin
      StrLCopy(Buffer, PAnsiChar(p), F^.fSize);
      Result := true;
    end;
  pxfDate:
    begin
      i := int;
      if i <> $FFFFFFFF80000000 then begin     // This transforms to Dec/12/9999 and probably is NULL
        Move(i,Buffer^,sizeof(Integer));
        Result := True;
      end;
    end;
  pxfShort:
    begin
      i := si;
      Move(i,Buffer^,sizeof(Integer));
      Result := True;
    end;
  pxfLong, pxfAutoInc:
    begin
      i := int;
      Move(i,Buffer^,sizeof(Integer));
      Result := True;
    end;
  pxfCurrency, pxfNumber:
    begin
      Move(d,Buffer^,sizeof(d));
      Result := True;
    end;
  pxfLogical:
    begin
      b := not ((p^ = #$80) or (p^ = #0));
      if Assigned(Buffer) then
        Move(b, Buffer^, Sizeof(b));
      Result := true;
    end;
  pxfTime:
    begin
      i := int;
      Move(i,Buffer^,sizeof(Integer));
      Result := True;
    end;
  pxfTimeStamp:
    begin
      Move(s[0], Buffer^, 8);
      Result := true;
    end;
  pxfGraphic:
    begin
      Result := ActiveBuffer <> nil;
    end;
  end;
end;

constructor TParadoxDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHeader := nil;
  FTargetEncoding := Uppercase(EncodingUTF8);
  FInputEncoding := '';
end;

destructor TParadoxDataSet.Destroy;
begin
  inherited Destroy;
end;

function TParadoxDataset.CreateBlobStream(Field: TField;
  Mode: TBlobStreamMode): TStream;
var
  memStream: TMemoryStream;
  F: PFldInfoRec;
  p: PChar;
  header: PAnsiChar;
  idx: Byte;
  loc: Integer;
  s: String;
  blobInfo: TPxBlobInfo;
  blobIndex: TPxBlobIndex;
  i: Integer;
begin
  memStream := TMemoryStream.Create;
  Result := memStream;

  if (Mode <> bmRead) then
    exit;

  F := FFieldInfoPtr;  { begin with the first field identifier }
  p := ActiveBuffer;
  for i := 1 to FHeader^.numFields do
  begin
    if i = Field.FieldNo then
      break;
    if F^.fType = pxfBCD then { BCD field size value not used for field size }
       Inc(p, 17)
     else
      Inc(p, F^.fSize);
    Inc(F);
  end;

  header := p + Field.Size - SizeOf(TPxBlobInfo);
  Move(header^, blobInfo{%H-}, SizeOf(blobInfo));
  if blobInfo.Length = 0 then
    exit;

  if blobInfo.Length > Field.Size - SizeOf(TPxBlobInfo) then
  begin
    if Assigned(FBlobStream) then begin
      idx := blobInfo.FileLoc and $FF;
      loc := blobInfo.FileLoc and $FFFFFF00;
      if idx = $FF then begin
        // Read from a single blob block
        FBlobStream.Seek(loc + 9, soFromBeginning);
        if Field.DataType = ftMemo then begin
          SetLength(s, blobInfo.Length);
          FBlobStream.Read(s[1], blobInfo.Length);
          s := ConvertEncoding(s, GetInputEncoding, GetTargetEncoding);
          memStream.Write(s[1], Length(s));
        end else
        begin
          if Field.DataType = ftGraphic then begin
            memstream.WriteAnsiString('bmp');     // Assuming that Paradox can store only bmp as ftGraphic... Wrong?
            FBlobStream.Position := FBlobStream.Position + 8;
          end;
          memStream.CopyFrom(FBlobStream, blobInfo.Length);
        end;
      end else begin
        // Read from a suballocated block
        FBlobStream.Seek(loc + 12 + 5*idx, soFromBeginning);
        FBlobStream.Read(blobIndex{%H-}, SizeOf(TPxBlobIndex));
        FBlobStream.Seek(loc + 16*blobIndex.Offset, soFromBeginning);
        if Field.DataType = ftMemo then begin
          SetLength(s, blobInfo.Length);
          FBlobStream.Read(s[1], blobInfo.Length);
          s := ConvertEncoding(s, GetInputEncoding, GetTargetEncoding);
          memStream.Write(s[1], Length(s));
        end else
          memStream.CopyFrom(FBlobStream, blobInfo.Length);
      end;
    end;
  end else
  if Field.DataType = ftMemo then begin
    SetLength(s, blobInfo.Length);
    Move(p^, s[1], blobInfo.Length);
    s := ConvertEncoding(s, GetInputEncoding, GetTargetEncoding);
    memStream.Write(s[1], Length(s));
  end else
    memStream.Write(p, blobInfo.Length);

  memStream.Position := 0;
end;


end.

