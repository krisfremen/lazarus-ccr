unit spkt_Types;

(*******************************************************************************
*                                                                              *
*  Plik: spkt_Types.pas                                                        *
*  Opis: Definicje typ�w u�ywanych podczas pracy toolbara                      *
*  Copyright: (c) 2009 by Spook. Jakiekolwiek u�ycie komponentu bez            *
*             uprzedniego uzyskania licencji od autora stanowi z�amanie        *
*             prawa autorskiego!                                               *
*                                                                              *
*******************************************************************************)

interface

uses Windows, Controls, Classes, ContNrs, SysUtils, Dialogs,
     spkt_Exceptions;

type TSpkListState = (lsNeedsProcessing, lsReady);

type TSpkComponent = class(TComponent)
     private
     protected
       FParent : TComponent;

     // *** Gettery i settery ***
       function GetParent: TComponent;
       procedure SetParent(const Value: TComponent);
     public
     // *** Konstruktor ***
       constructor Create(AOwner : TComponent); override;

     // *** Obs�uga parenta ***
       function HasParent : boolean; override;
       function GetParentComponent : TComponent; override;
       procedure SetParentComponent(Value : TComponent); override;

       property Parent : TComponent read GetParent write SetParent;
     end;

type TSpkCollection = class(TPersistent)
     private
     protected
       FList : TObjectList;
       FNames : TStringList;
       FListState : TSpkListState;
       FRootComponent : TComponent;

     // *** Metody reakcji na zmiany w li�cie ***
       procedure Notify(Item : TComponent; Operation : TOperation); virtual;
       procedure Update; virtual;

     // *** Wewn�trzne metody dodawania i wstawiania element�w ***
       procedure AddItem(AItem : TComponent);
       procedure InsertItem(index : integer; AItem : TComponent);

     // *** Gettery i settery ***
       function GetItems(index: integer): TComponent; virtual;
     public
     // *** Konstruktor, destruktor ***
       constructor Create(RootComponent : TComponent); reintroduce; virtual;
       destructor Destroy; override;

     // *** Obs�uga listy ***
       procedure Clear;
       function Count : integer;
       procedure Delete(index : integer); virtual;
       function IndexOf(Item : TComponent) : integer;
       procedure Remove(Item : TComponent); virtual;
       procedure RemoveReference(Item : TComponent);
       procedure Exchange(item1, item2 : integer);
       procedure Move(IndexFrom, IndexTo : integer);

     // *** Reader, writer i obs�uga designtime i DFM ***
       procedure WriteNames(Writer : TWriter); virtual;
       procedure ReadNames(Reader : TReader); virtual;
       procedure ProcessNames(Owner : TComponent); virtual;

       property ListState : TSpkListState read FListState;
       property Items[index : integer] : TComponent read GetItems; default;
     end;

implementation

{ TSpkCollection }

procedure TSpkCollection.AddItem(AItem: TComponent);
begin
// Ta metoda mo�e by� wywo�ywana bez przetworzenia nazw (w szczeg�lno�ci, metoda
// przetwarzaj�ca nazwy korzysta z AddItem)

Notify(AItem, opInsert);
FList.Add(AItem);

Update;
end;

procedure TSpkCollection.Clear;
begin
FList.Clear;

Update;
end;

function TSpkCollection.Count: integer;
begin
result:=FList.Count;
end;

constructor TSpkCollection.Create(RootComponent : TComponent);
begin
inherited Create;
FRootComponent:=RootComponent;

FNames:=TStringList.create;

FList:=TObjectList.Create;
FList.OwnsObjects:=true;

FListState:=lsReady;
end;

procedure TSpkCollection.Delete(index: integer);
begin
if (index<0) or (index>=FList.count) then
   raise InternalException.Create('TSpkCollection.Delete: Nieprawid�owy indeks!');

Notify(TComponent(FList[index]), opRemove);

FList.Delete(index);

Update;
end;

destructor TSpkCollection.Destroy;
begin
  FNames.Free;
  FList.Free;
  inherited;
end;

procedure TSpkCollection.Exchange(item1, item2: integer);
begin
FList.Exchange(item1, item2);
Update;
end;

function TSpkCollection.GetItems(index: integer): TComponent;
begin
if (index<0) or (index>=FList.Count) then
   raise InternalException.create('TSpkCollection.GetItems: Nieprawid�owy indeks!');

result:=TComponent(FList[index]);
end;

function TSpkCollection.IndexOf(Item: TComponent): integer;
begin
result:=FList.IndexOf(Item);
end;

procedure TSpkCollection.InsertItem(index: integer; AItem: TComponent);
begin
if (index<0) or (index>FList.Count) then
   raise InternalException.Create('TSpkCollection.Insert: Nieprawid�owy indeks!');

Notify(AItem, opInsert);

FList.Insert(index, AItem);

Update;
end;

procedure TSpkCollection.Move(IndexFrom, IndexTo: integer);
begin
if (indexFrom<0) or (indexFrom>=FList.Count) or
   (indexTo<0) or (indexTo>=FList.Count) then
   raise InternalException.Create('TSpkCollection.Move: Nieprawid�owy indeks!');

FList.Move(IndexFrom, IndexTo);

Update;
end;

procedure TSpkCollection.Notify(Item: TComponent; Operation: TOperation);
begin
//
end;

procedure TSpkCollection.ProcessNames(Owner : TComponent);

var s : string;

begin
FList.Clear;

if Owner<>nil then
   for s in FNames do
       AddItem(Owner.FindComponent(s));

FNames.Clear;
FListState:=lsReady;
end;

procedure TSpkCollection.ReadNames(Reader: TReader);

begin
Reader.ReadListBegin;

FNames.Clear;
while not(Reader.EndOfList) do
      FNames.Add(Reader.ReadString);

Reader.ReadListEnd;

FListState:=lsNeedsProcessing;
end;

procedure TSpkCollection.Remove(Item: TComponent);

var i : integer;

begin
i:=FList.IndexOf(Item);

if i>=0 then
   begin
   Notify(Item, opRemove);

   FList.Delete(i);

   Update;
   end;
end;

procedure TSpkCollection.RemoveReference(Item: TComponent);

var i : integer;

begin
i:=FList.IndexOf(Item);

if i>=0 then
   begin
   Notify(Item, opRemove);

   FList.Extract(Item);

   Update;
   end;
end;

procedure TSpkCollection.Update;
begin
//
end;

procedure TSpkCollection.WriteNames(Writer: TWriter);

var Item : pointer;

begin
Writer.WriteListBegin;

for Item in FList do
    Writer.WriteString(TComponent(Item).Name);

Writer.WriteListEnd;
end;

{ TSpkComponent }

constructor TSpkComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParent:=nil;
end;

function TSpkComponent.GetParent: TComponent;
begin
  result:=GetParentComponent;
end;

function TSpkComponent.GetParentComponent: TComponent;
begin
  result:=FParent;
end;

function TSpkComponent.HasParent: boolean;
begin
  result:=FParent<>nil;
end;

procedure TSpkComponent.SetParent(const Value: TComponent);
begin
  SetParentComponent(Value);
end;

procedure TSpkComponent.SetParentComponent(Value: TComponent);
begin
  FParent:=Value;
end;

end.
