unit FunctionsUnit;

{$MODE Delphi}

interface

uses SysUtils, ItemBankGlobals;

function ReadMCItem(item : integer; VAR R3 : MCItemRcd) : boolean;
function ReadTFItem(item : integer; VAR R5 : TFItemRcd) : boolean;
function ReadMAItem(item : integer; VAR R1 : MatchItemsRcd) : boolean;
function ReadCOItem(item : integer; VAR R2 : BlankItemRcd) : boolean;
function ReadESItem(item : integer; VAR R4 : EssayItemRcd) : boolean;
procedure WriteMCItem(item : integer; VAR R3 : MCItemRcd);
procedure WriteTFItem(item : integer; VAR R5 : TFItemRcd);
procedure WriteMAItem(item : integer; VAR R1 : MatchItemsRcd);
procedure WriteCOItem(item : integer; VAR R2 : BlankItemRcd);
procedure WriteESItem(item : integer; VAR R4 : EssayItemRcd);

implementation

function ReadMCItem(item : integer; VAR R3 : MCItemRcd) : boolean;
var
   found : boolean;
   F3 : File of MCItemRcd;
   filename : string;

begin
     found := false;
     if FileExists(MCFName) { *Converted from FileExists*  } then // multiple choice items
     begin
          filename := MCFName;
          AssignFile(F3,filename);
          Reset(F3);
          Seek(F3,item-1);
          Read(F3,R3);
          found := true;
     end;
     CloseFile(F3);
     Result := found;
end;
//-------------------------------------------------------------------

function ReadTFItem(item : integer; VAR R5 : TFItemRcd) : boolean;
var
   found : boolean;
   F5 : File of TFItemRcd;
   filename : string;

begin
     found := false;
     if FileExists(TFFName) { *Converted from FileExists*  } then // true-false items
     begin
          filename := TFFName;
          AssignFile(F5,filename);
          Reset(F5);
          Seek(F5,item-1);
          Read(F5,R5);
          found := true;
     end;
     CloseFile(F5);
     Result := found;
end;
//-------------------------------------------------------------------

function ReadMAItem(item : integer; VAR R1 : MatchItemsRcd) : boolean;
var
   found : boolean;
   F1 : File of MatchItemsRcd;
   filename : string;

begin
     found := false;
     if FileExists(MatchFName) { *Converted from FileExists*  } then // matching items
     begin
          filename := MatchFName;
          AssignFile(F1,filename);
          Reset(F1);
          Seek(F1,item-1);
          Read(F1,R1);
          found := true;
     end;
     CloseFile(F1);
     Result := found;
end;
//-------------------------------------------------------------------

function ReadCOItem(item : integer; VAR R2 : BlankItemRcd) : boolean;
var
   found : boolean;
   F2 : File of BlankItemRcd;
   filename : string;

begin
     found := false;
     if FileExists(BlankFName) { *Converted from FileExists*  } then // completion items
     begin
          filename := BlankFName;
          AssignFile(F2,filename);
          Reset(F2);
          Seek(F2,item-1);
          Read(F2,R2);
          found := true;
     end;
     CloseFile(F2);
     Result := found;
end;
//-------------------------------------------------------------------

function ReadESItem(item : integer; VAR R4 : EssayItemRcd) : boolean;
var
   found : boolean;
   F4 : File of EssayItemRcd;
   filename : string;

begin
     found := false;
     if FileExists(EssayFName) { *Converted from FileExists*  } then // essay items
     begin
          filename := EssayFName;
          AssignFile(F4,filename);
          Reset(F4);
          Seek(F4,item-1);
          Read(F4,R4);
          found := true;
     end;
     CloseFile(F4);
     Result := found;
end;
//-------------------------------------------------------------------

procedure WriteMCItem(item : integer; VAR R3 : MCItemRcd);
var
   F3 : File of MCItemRcd;
   filename : string;
begin
     if FileExists(MCFName) { *Converted from FileExists*  } then // multiple choice items
     begin
          filename := MCFName;
          AssignFile(F3,filename);
          Reset(F3);
          Seek(F3,item-1);
          write(F3,R3);
     end;
     CloseFile(F3);
end;
//-------------------------------------------------------------------

procedure WriteTFItem(item : integer; VAR R5 : TFItemRcd);
var
   F5 : File of TFItemRcd;
   filename : string;
begin
     if FileExists(TFFName) { *Converted from FileExists*  } then // true-false items
     begin
          filename := TFFName;
          AssignFile(F5,filename);
          Reset(F5);
          Seek(F5,item-1);
          write(F5,R5);
     end;
     CloseFile(F5);
end;
//-------------------------------------------------------------------

procedure WriteMAItem(item : integer; VAR R1 : MatchItemsRcd);
var
   F1 : File of MatchItemsRcd;
   filename : string;
begin
     if FileExists(MatchFName) { *Converted from FileExists*  } then // matching items
     begin
          filename := MatchFName;
          AssignFile(F1,filename);
          Reset(F1);
          Seek(F1,item-1);
          write(F1,R1);
     end;
     CloseFile(F1);
end;
//-------------------------------------------------------------------

procedure WriteCOItem(item : integer; VAR R2 : BlankItemRcd);
var
   F2 : File of BlankItemRcd;
   filename : string;
begin
     if FileExists(BlankFName) { *Converted from FileExists*  } then // completion items
     begin
          filename := BlankFName;
          AssignFile(F2,filename);
          Reset(F2);
          Seek(F2,item-1);
          write(F2,R2);
     end;
     CloseFile(F2);
end;
//-------------------------------------------------------------------

procedure WriteESItem(item : integer; VAR R4 : EssayItemRcd);
var
   F4 : File of EssayItemRcd;
   filename : string;
begin
     if FileExists(EssayFName) { *Converted from FileExists*  } then // essay items
     begin
          filename := EssayFName;
          AssignFile(F4,filename);
          Reset(F4);
          Seek(F4,item-1);
          write(F4,R4);
     end;
     CloseFile(F4);
end;
//-------------------------------------------------------------------

end.
