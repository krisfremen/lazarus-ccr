program fixlp;

uses
  SysUtils, Classes, FileUtil, laz2_xmlread, laz2_xmlwrite, laz2_dom;

const
  PARENTS_OF_NUMBERED_NODES: array[0..9] of string = (
    'BuildModes', 'RequiredPackages', 'RequiredPkgs', 'Files', 'Units',
    'Exceptions', 'JumpHistory', 'Modes', 'HistoryLists', 'OtherDefines'
  );

{ Rename the given node. ANode.NodeName is readonly. Therefore, we create
  a new empty node, give it the new name and copy all children and attributes
  from the old node to the new node.
  NOTE:
  We cannot call parentNode.CloneNode because this would copy the node name
  --> we must do everything manually step by step. }
procedure RenameNode(ANode: TDOMNode; ANewName: String);
var
  doc: TDOMDocument;
  parentNode: TDOMNode;
  newNode: TDOMNode;
  childNode: TDOMNode;
  newChildNode: TDOMNode;
  i: Integer;
begin
  parentNode := ANode.ParentNode;
  doc := ANode.OwnerDocument;

  // Create a new node
  newNode := doc.CreateElement(ANewName);

  // copy children of old node to new node
  childNode := ANode.FirstChild;
  while childNode <> nil do begin
    newChildNode := childNode.CloneNode(true);
    newNode.AppendChild(newChildNode);
    childNode := childNode.NextSibling;
  end;

  // Copy attributes to the new node
  for i := 0 to ANode.Attributes.Length - 1 do
    TDOMElement(newNode).SetAttribute(
      ANode.Attributes[i].NodeName,
      ANode.Attributes[i].NodeValue
    );

  // Replace old node by new node in xml document
  parentNode.Replacechild(newNode, ANode);

  // Destroy old node
  ANode.Free;
end;

procedure FixNode(ANode: TDOMNode);
var
  nodeName: String;
  subnode: TDOMNode;
  nextSubNode: TDOMNode;
  numItems: Integer;
  i: Integer;
  found: Boolean;
begin
  if ANode = nil then
    exit;

  nodeName := ANode.NodeName;
  found := false;
  for i := Low(PARENTS_OF_NUMBERED_NODES) to High(PARENTS_OF_NUMBERED_NODES) do
    if PARENTS_OF_NUMBERED_NODES[i] = nodeName then
    begin
      found := true;
      break;
    end;

  if found then
  begin
    subnode := ANode.FirstChild;
    numItems := 0;
    while subnode <> nil do begin
      nodeName := subnode.NodeName;
      nextSubNode := subNode.NextSibling;
      // 1-based numbered nodes
      if (nodeName = 'Item') or (nodeName = 'Position') then
      begin
        inc(numItems);
        RenameNode(subnode, nodeName + IntToStr(numItems));
      end else
      // 0-based numbered nodes
      if (nodeName = 'Unit') or (nodeName = 'Mode') or (nodeName = 'List') or
         (nodeName = 'Define') then
      begin
        RenameNode(subnode, nodeName + IntToStr(numItems));
        inc(numItems);
      end;
      subnode := nextSubNode;
    end;
    if numItems > 0 then
      TDOMElement(ANode).SetAttribute('Count', IntToStr(numItems));
  end;

  FixNode(ANode.FirstChild);
  FixNode(ANode.NextSibling);
end;

procedure FixXML(AFileName: string);
var
  L: TStrings;
  doc: TXMLDocument;
  ext: String;
  fn: String;
begin
  if (pos('*', AFileName) > 0) or (pos('?', AFileName) > 0) then
  begin
    L := TStringList.Create;
    try
      FindAllFiles(L, ExtractFileDir(AFileName), ExtractFileName(AfileName), true);
      for fn in L do
        FixXML(fn);
    finally
      L.Free;
    end;
    exit;
  end;

  ext := Lowercase(ExtractFileExt(AFileName));
  if not ((ext = '.lpi') or (ext = '.lpk') or (ext = '.lps')) then
    exit;

  WriteLn('Processing ', AFilename, '...');

  ReadXMLFile(doc, AFileName);
  try
    FixNode(doc.DocumentElement);
    fn := AFileName + '.bak';
    if FileExists(fn) then DeleteFile(fn);
    RenameFile(AFileName, fn);
    WriteXMLFile(doc, AFileName);
  finally
    doc.Free;
  end;
end;

procedure WriteHelp;
begin
  WriteLn('fixlp <filename1>[, <filename2> [...]]');
  WriteLn('  Wildcards allowed in file names.');
end;

var
  i: Integer;
begin
  if ParamCount = 0 then
  begin
    WriteHelp;
    Halt;
  end;

  for i := 1 to ParamCount do
    FixXML(ParamStr(i));
end.

