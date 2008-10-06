unit mytoolbar;

{$mode delphi}{$STATIC ON}

interface

uses
  SysUtils,
  MacOSAll, objc, appkit, foundation;

type

  { TMyToolbarController }

  TMyToolbarController = class(NSObject)
  public
    { Extra binding functions }
    constructor Create; override;
    procedure AddMethods; override;
    procedure AttachEventHandlers;
    { Toolbar items }
    OpenToolbarItem, SaveToolbarItem, CloseToolbarItem: NSToolbarItem;
    { Objective-c Methods }
    class function toolbarAllowedItemIdentifiers(_self: objc.id;
     _cmd: SEL; toolbar: objc.id {NSToolbar}): CFArrayRef; cdecl;// static;
    class function toolbarDefaultItemIdentifiers(_self: objc.id;
     _cmd: SEL; toolbar: objc.id {NSToolbar}): CFArrayRef; cdecl;// static;
  end;

const
  Str_toolbarAllowedItemIdentifiers = 'toolbarAllowedItemIdentifiers:';
  Str_toolbarDefaultItemIdentifiers = 'toolbarDefaultItemIdentifiers:';
  Str_toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar = 'toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:';

var
  OpenToolbarItemIdentifier, SaveToolbarItemIdentifier, CloseToolbarItemIdentifier: CFStringRef;
  myToolbarController: TMyToolbarController;

function toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar
      (_self: objc.id; _cmd: SEL; toolbar: objc.id;
      itemIdentifier: CFStringRef; flag: OBJC_BOOL): objc.id; cdecl;// static;

implementation

uses
  model, controller;

{ TMyToolbar }

constructor TMyToolbarController.Create;
begin
  { The class is registered on the Objective-C runtime before the NSObject constructor is called }
  if not CreateClassDefinition(ClassName(), Str_NSObject) then WriteLn('Failed to create objc class ' + ClassName());

  inherited Create;

  { Prepare CFStringRefs for the constants }

  OpenToolbarItemIdentifier := CFStringCreateWithPascalString(nil, 'OpenID', kCFStringEncodingUTF8);
  SaveToolbarItemIdentifier := CFStringCreateWithPascalString(nil, 'SaveID', kCFStringEncodingUTF8);
  CloseToolbarItemIdentifier := CFStringCreateWithPascalString(nil, 'CloseID', kCFStringEncodingUTF8);

  { Create toolbar items }
  OpenToolbarItem := NSToolbarItem.initWithItemIdentifier(OpenToolbarItemIdentifier);
//    [toolbarItem setLabel:@"Save"];
//   [toolbarItem setPaletteLabel:[toolbarItem label]];
//    [toolbarItem setToolTip:@"Save Your Passwords"];}
  OpenToolbarItem.setImage(myModel.imgOpen.Handle);

  SaveToolbarItem := NSToolbarItem.initWithItemIdentifier(SaveToolbarItemIdentifier);
  SaveToolbarItem.setImage(myModel.imgSave.Handle);

  CloseToolbarItem := NSToolbarItem.initWithItemIdentifier(CloseToolbarItemIdentifier);
  CloseToolbarItem.setImage(myModel.imgClose.Handle);
end;

procedure TMyToolbarController.AddMethods;
begin
  AddMethod(Str_toolbarAllowedItemIdentifiers, '@@:@', Pointer(toolbarAllowedItemIdentifiers));
  AddMethod(Str_toolbarDefaultItemIdentifiers, '@@:@', Pointer(toolbarDefaultItemIdentifiers));
  AddMethod(Str_toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar,
   '@@:@@c', @toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar);
end;

procedure TMyToolbarController.AttachEventHandlers;
begin
  OpenToolbarItem.setTarget(myController.Handle);
  OpenToolbarItem.setAction(sel_registerName(PChar('doOpenFile:')));

  SaveToolbarItem.setTarget(myController.Handle);
  SaveToolbarItem.setAction(sel_registerName(PChar('doSaveFile:')));

  CloseToolbarItem.setTarget(myController.Handle);
  CloseToolbarItem.setAction(sel_registerName(PChar('doClose:')));
end;

class function TMyToolbarController.toolbarAllowedItemIdentifiers(_self: objc.id;
  _cmd: SEL; toolbar: objc.id): CFArrayRef; cdecl;
var
  toolbarItems: array[0..4] of CFStringRef;
begin
  WriteLn('OpenToolbarItemIdentifier: ', IntToHex(Cardinal(OpenToolbarItemIdentifier), 8));
  WriteLn('SaveToolbarItemIdentifier: ', IntToHex(Cardinal(SaveToolbarItemIdentifier), 8));
  WriteLn('NSToolbarSpaceItemIdentifier: ', IntToHex(Cardinal(NSToolbarSpaceItemIdentifier), 8));
  WriteLn('CloseToolbarItemIdentifier: ', IntToHex(Cardinal(CloseToolbarItemIdentifier), 8));
  toolbarItems[0] := OpenToolbarItemIdentifier;
  toolbarItems[1] := SaveToolbarItemIdentifier;
  toolbarItems[2] := NSToolbarSpaceItemIdentifier;
  toolbarItems[3] := CloseToolbarItemIdentifier;
  toolbarItems[4] := nil;

  Result := CFArrayCreate(nil, @toolbarItems[0], 4, nil);
end;

class function TMyToolbarController.toolbarDefaultItemIdentifiers(_self: objc.id;
  _cmd: SEL; toolbar: objc.id): CFArrayRef; cdecl;
begin
  Result := toolbarAllowedItemIdentifiers(_self, _cmd, toolbar);
end;

function toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar(_self: objc.id;
  _cmd: SEL; toolbar: objc.id {NSToolbar}; itemIdentifier: CFStringRef;
  flag: OBJC_BOOL): objc.id {NSToolbarItem}; cdecl;
begin
  WriteLn('toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar: ', IntToHex(Cardinal(itemIdentifier), 8));

  with myToolbarController do
  begin
  if CFStringCompare(itemIdentifier, OpenToolbarItemIdentifier, kCFCompareCaseInsensitive) = kCFCompareEqualTo then
    Result := OpenToolbarItem.autorelease
  else if CFStringCompare(itemIdentifier, SaveToolbarItemIdentifier, kCFCompareCaseInsensitive) = kCFCompareEqualTo then
    Result := SaveToolbarItem.autorelease
  else if CFStringCompare(itemIdentifier, CloseToolbarItemIdentifier, kCFCompareCaseInsensitive) = kCFCompareEqualTo then
    Result := CloseToolbarItem.autorelease
  else
    Result := nil;
  end;
end;

end.

