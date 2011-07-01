{$IFNDEF LCL}
{$ifdef ver140}
{$warn Symbol_Platform Off}   
{$endif}
{$ifdef ver150}
{$warn Symbol_Platform Off}
{$Define UseXpMan}
{$endif}
{$ifdef ver170}
{$warn Symbol_Platform Off}
{$Define UseXpMan}
{$endif}
{$ENDIF}

unit mainform;
{A program to demonstrate the ThtmlViewer component}

interface

uses
  {$IFNDEF LCL} Windows, Messages, MMSystem, MPlayer, {$ELSE} LclIntf, LMessages, LclType, LResources, FPimage, HtmlMisc, {$ENDIF}
  SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Menus, Htmlview, StdCtrls,
  Clipbrd, HTMLsubs, {$IFDEF MSWINDOWS} ShellAPI, {$ELSE} Unix, {$ENDIF} 
  {$IFDEF LCL} PrintersDlgs, {$ENDIF}
  {$ifdef UseXpMan} XpMan, {$endif} {$IFNDEF LCL} Gauges, {$ENDIF} ComCtrls;

const
  MaxHistories = 6;  {size of History list}
type

  { TformBrowser }

  TformBrowser = class(TForm)
    OpenDialog: TOpenDialog;   
    MainMenu: TMainMenu;
    Panel1: TPanel;
    Panel2: TPanel;                       
    Panel3: TPanel;
    File1: TMenuItem;
    Open: TMenuItem;
    options1: TMenuItem;
    ShowImages: TMenuItem;
    Fonts: TMenuItem;
    editURL: TEdit;
    ReloadButton: TButton;
    BackButton: TButton;
    FwdButton: TButton;
    HistoryMenuItem: TMenuItem;
    Exit1: TMenuItem;
    PrintDialog: TPrintDialog;
    About1: TMenuItem;
    Edit2: TMenuItem;
    Find1: TMenuItem;
    FindDialog: TFindDialog;
    Viewer: THTMLViewer;
    CopyItem: TMenuItem;
    N2: TMenuItem;
    SelectAllItem: TMenuItem;
    OpenTextFile: TMenuItem;
    OpenImageFile: TMenuItem;
{$IFNDEF LCL}
    MediaPlayer: TMediaPlayer;
{$ENDIF}    
    PopupMenu: TPopupMenu;
    CopyImageToClipboard: TMenuItem;
    Viewimage: TMenuItem;
    N3: TMenuItem;
    OpenInNewWindow: TMenuItem;
    MetaTimer: TTimer;
    Print1: TMenuItem;
    Printpreview: TMenuItem;
    Timer1: TTimer;
    ProgressBar: TProgressBar;
    PrinterSetupDialog: TPrinterSetupDialog;
    PrinterSetup1: TMenuItem;
    procedure editURLKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OpenFileClick(Sender: TObject);
    procedure HotSpotChange(Sender: TObject; const URL: string);
    procedure HotSpotClick(Sender: TObject; const URL: string;
              var Handled: boolean);
    procedure ShowImagesClick(Sender: TObject);
    procedure ReloadButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FwdBackClick(Sender: TObject);
    procedure HistoryClick(Sender: TObject);
    procedure HistoryChange(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FontColorsClick(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SubmitEvent(Sender: TObject; Const AnAction, Target, EncType, Method: String;
      Results: TStringList);
    procedure Find1Click(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure ProcessingHandler(Sender: TObject; ProcessingOn: Boolean);
    procedure CopyItemClick(Sender: TObject);
    procedure Edit2Click(Sender: TObject);
    procedure SelectAllItemClick(Sender: TObject);
    procedure OpenTextFileClick(Sender: TObject);
    procedure OpenImageFileClick(Sender: TObject);
    procedure MediaPlayerNotify(Sender: TObject);
    procedure SoundRequest(Sender: TObject; const SRC: String;
      Loop: Integer; Terminate: Boolean);
    procedure CopyImageToClipboardClick(Sender: TObject);
    procedure ObjectClick(Sender, Obj: TObject; const OnClick: String);
    procedure ViewerImageRequest(Sender: TObject; const SRC: string;
      var Stream: TMemoryStream);
    procedure ViewimageClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ViewerInclude(Sender: TObject; const Command: String;
      Params: TStrings; var S: string);
    procedure RightClick(Sender: TObject;
      Parameters: TRightClickParameters);
    procedure OpenInNewWindowClick(Sender: TObject);
    procedure MetaTimerTimer(Sender: TObject);
    procedure MetaRefreshEvent(Sender: TObject; Delay: Integer;
      const URL: String);
    procedure PrintpreviewClick(Sender: TObject);
    procedure ViewerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure ViewerProgress(Sender: TObject; Stage: TProgressStage;
      PercentDone: Integer);
    procedure ViewerPrintHTMLFooter(Sender: TObject; HFViewer: THTMLViewer;
      NumPage: Integer; LastPage: Boolean; var XL, XR: Integer;
      var StopPrinting: Boolean);
    procedure ViewerPrintHTMLHeader(Sender: TObject; HFViewer: THTMLViewer;
      NumPage: Integer; LastPage: Boolean; var XL, XR: Integer;
      var StopPrinting: Boolean);
    procedure PrinterSetup1Click(Sender: TObject);
  private
    { Private declarations }
{$IFDEF LCLCarbon}
    AppMenu : TMenuItem;
{$ENDIF}
    Histories: array[0..MaxHistories-1] of TMenuItem;
    MediaCount: integer;
    FoundObject: TImageObj;
    NewWindowFile: string;
    NextFile, PresentFile: string;
    TimerCount: integer;
    OldTitle: string;
    HintWindow: THintWindow;
    HintVisible: boolean;   

{$IFNDEF LCL}
    procedure wmDropFiles(var Message: TMessage); message wm_DropFiles;
{$ELSE}
    procedure DropFiles(      Sender   : TObject;
                        const FileNames: array of string);
{$ENDIF}
    procedure CloseAll;
  public
    { Public declarations }
    procedure LoadURL(AURL: string);
  end;

var
  formBrowser: TformBrowser;

implementation

uses
  pageloader, {$IFNDEF LCL} PreviewForm, {$ENDIF} HTMLun2, HTMLabt, Submit, ImgForm, FontDlg;

{$IFNDEF LCL}
{$R *.DFM}
{$ENDIF}

procedure TformBrowser.FormCreate(Sender: TObject);
var
  I: integer;
begin
{$IFNDEF LCL}
if Screen.Width <= 640 then
  Position := poDefault;  {keeps form on screen better}
{$ELSE}
  Position := poScreenCenter;
{$ENDIF}

{$IFNDEF DARWIN}
OpenDialog.InitialDir := ExtractFilePath(ParamStr(0));
{$ELSE}  //Don't default to within app bundle.
OpenDialog.InitialDir := ExtractFilePath(ParamStr(0)) + '../../../';
{$ENDIF}

Caption := 'HTML Demo, Version '+HTMLAbt.Version;

ShowImages.Checked := Viewer.ViewImages;
Viewer.HistoryMaxCount := MaxHistories;  {defines size of history list}

for I := 0 to MaxHistories-1 do
  begin      {create the MenuItems for the history list}
  Histories[I] := TMenuItem.Create(HistoryMenuItem);
  HistoryMenuItem.Insert(I, Histories[I]);
  with Histories[I] do
    begin
    Visible := False;
    OnClick := HistoryClick;
    Tag := I;
    end;
  end;

{$IFDEF LCLCarbon}
  AppMenu := TMenuItem.Create(Self);  //Application menu
  AppMenu.Caption := #$EF#$A3#$BF;  //Unicode Apple logo char
  MainMenu.Items.Insert(0, AppMenu);
  MainMenu.Items.Remove(About1);  //Remove About as separate menu
  AppMenu.Add(About1);  //Add About as item in application menu

  File1.Remove(File1.Items[File1.Count-2]);
  File1.Remove(Exit1);  //Remove Exit since have Quit

  Find1.ShortCut := ShortCut(VK_F, [ssMeta]);
  CopyItem.ShortCut := ShortCut(VK_C, [ssMeta]);
  SelectAllItem.ShortCut := ShortCut(VK_A, [ssMeta]);
{$ENDIF}

{$IFNDEF LCL}
DragAcceptFiles(Handle, True);
{$ELSE}
AllowDropFiles := True;
OnDropFiles := DropFiles;
{$ENDIF}
HintWindow := THintWindow.Create(Self);
HintWindow.Color := $C0FFFF;
end;

procedure TformBrowser.FormShow(Sender: TObject);
var
  S: string;
  I: integer;
begin
  // With OS X app, ParamStr not meaningful unless launched with --args switch.
  if (ParamCount >= 1) {$IFDEF DARWIN} and (Copy(ParamStr(1), 1, 4) <> '-psn') {$ENDIF} then
  begin            {Parameter is file to load}
 {$IFNDEF LCL}
  S := CmdLine;
  I := Pos('" ', S);
  if I > 0 then
    Delete(S, 1, I+1)     {delete EXE name in quotes}
  else Delete(S, 1, Length(ParamStr(0)));  {in case no quote marks}
  I := Pos('"', S);
  while I > 0 do     {remove any quotes from parameter}
    begin
    Delete(S, I, 1);
    I := Pos('"', S);
    end;
 {$ELSE}
  S := ParamStr(1);
 {$ENDIF}  
  Viewer.LoadFromFile(HtmlToDos(Trim(S)));
  end;
end;

procedure TformBrowser.OpenFileClick(Sender: TObject);
begin
  if Viewer.CurrentFile <> '' then
    OpenDialog.InitialDir := ExtractFilePath(Viewer.CurrentFile);
  OpenDialog.Filter := 'HTML Files (*.htm,*.html)|*.htm;*.html';  //might have changed
  if OpenDialog.Execute then
  begin
    Update;
    Viewer.LoadFromFile(OpenDialog.Filename);
    Caption := Viewer.DocumentTitle;
  end;
end;

procedure TformBrowser.editURLKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    LoadURL(editURL.Text);
  end;
end;

procedure TformBrowser.HotSpotChange(Sender: TObject; const URL: string);
{mouse moved over or away from a hot spot.  Change the status line}
var
  Caption: string;
begin
  Caption := '';
  if URL <> '' then
    Caption := Caption+'URL: '+URL+'     ';
  if Viewer.TitleAttr <> '' then
    Caption := Caption+'Title: '+Viewer.TitleAttr;
  Panel1.Caption := Caption;
end;

{This routine handles what happens when a hot spot is clicked.  The assumption
 is made that DOS filenames are being used. .EXE, .WAV, .MID, and .AVI files are
 handled here, but other file types could be easily added.

 If the URL is handled here, set Handled to True.  If not handled here, set it
 to False and ThtmlViewer will handle it.}
procedure TformBrowser.HotSpotClick(Sender: TObject; const URL: string;
          var Handled: boolean);
const
  snd_Async = $0001;  { play asynchronously }
var
  PC: array[0..255] of char;
{$IFDEF LCL}
  PC2: array[0..255] of char;
{$ENDIF}  
  S, Params: string[255];
  Ext: string[5];
  ID: string;
  I, J, K: integer;
begin
  Handled := False;

  {The following looks for a link of the form, "IDExpand_XXX".  This is interpreted
   as meaning a block with an ID="XXXPlus" or ID="XXXMinus" attribute should
   have its Display property toggled.
  }
  I := Pos('IDEXPAND_', Uppercase(URL));
  if I=1 then
  begin
    ID := Copy(URL, 10, Length(URL)-9);
    Viewer.IDDisplay[ID+'Plus'] := not Viewer.IDDisplay[ID+'Plus'];
    Viewer.IDDisplay[ID+'Minus'] := not Viewer.IDDisplay[ID+'Minus'];
    Viewer.Reformat;
    Handled := True;
    Exit;
  end;

  J := Pos('HTTP:', UpperCase(URL));
  if (J > 0) then
  begin
    LoadURL(URL);
    Handled := True;
    Exit;
  end;

I := Pos(':', URL);
J := Pos('FILE:', UpperCase(URL));
if (I <= 2) or (J > 0) then
  begin                      {apparently the URL is a filename}
  S := URL;
  K := Pos(' ', S);     {look for parameters}
  if K = 0 then K := Pos('?', S);  {could be '?x,y' , etc}
  if K > 0 then
    begin
    Params := Copy(S, K+1, 255); {save any parameters}
    S[0] := chr(K-1);            {truncate S}
    end
  else Params := '';
  S := Viewer.HTMLExpandFileName(S);
  Ext := Uppercase(ExtractFileExt(S));
  if Ext = '.WAV' then
    begin
    Handled := True;
{$IFNDEF LCL}
    sndPlaySound(StrPCopy(PC, S), snd_ASync);
{$ENDIF}
    end
  else if Ext = '.EXE' then
    begin
    Handled := True;
{$IFNDEF LCL}
    WinExec(StrPCopy(PC, S+' '+Params), sw_Show);
{$ELSE}
 {$IFDEF MSWINDOWS}
    ShellExecute(Handle, nil, StrPCopy(PC, S), StrPCopy(PC2, Params), 
                 nil, SW_SHOWNORMAL); 
 {$ELSE}  //Not sure if this makes any sense since executable won't have .exe.
  {$IFDEF DARWIN}
    Shell('open -n "' + S + '" --args "' + Params + '"');
  {$ELSE}
    Shell('"' + S + '" "' + Params + '"');
  {$ENDIF}
 {$ENDIF}
{$ENDIF}
    end
  else if (Ext = '.MID') or (Ext = '.AVI')  then
    begin
    Handled := True;
{$IFNDEF LCL}
    WinExec(StrPCopy(PC, 'MPlayer.exe /play /close '+S), sw_Show);
{$ELSE}
 {$IFDEF MSWINDOWS}
    ShellExecute(Handle, nil, 'MPlayer.exe', '/play /close', 
                 nil, SW_SHOWNORMAL); 
 {$ELSE}  //No equivalent to MPlayer?
 {$ENDIF}
{$ENDIF}
    end;
  {else ignore other extensions}
  editURL.Text := URL;
  Exit;
  end;

  I := Pos('MAILTO:', UpperCase(URL));
  if (I > 0) then
  begin
{$IFDEF MSWINDOWS}
  ShellExecute(0, nil, pchar(URL), nil, nil, SW_SHOWNORMAL);
{$ELSE}
 {$IFDEF DARWIN}
  Shell('open "' + URL + '"');
 {$ELSE}
  Shell('"' + URL + '"');  //use LCL's OpenURL?
 {$ENDIF}
{$ENDIF}
  Handled := True;
  Exit;
  end;

  editURL.Text := URL;   {other protocall}
end;

{The Show Images menu item was clicked}
procedure TformBrowser.ShowImagesClick(Sender: TObject);
begin
  Viewer.ViewImages := not Viewer.ViewImages;
  (Sender as TMenuItem).Checked := Viewer.ViewImages;
end;

procedure TformBrowser.ReloadButtonClick(Sender: TObject);
{the Reload button was clicked}
begin
with Viewer do
  begin
  ReLoadButton.Enabled := False;
  ReLoad;
  ReLoadButton.Enabled := CurrentFile <> '';
  Viewer.SetFocus;
  end;
end;

procedure TformBrowser.FwdBackClick(Sender: TObject);
{Either the Forward or Back button was clicked}
begin
with Viewer do
  begin
  if Sender = BackButton then
    HistoryIndex := HistoryIndex +1
  else
    HistoryIndex := HistoryIndex -1;
  Self.Caption := DocumentTitle;      
  end;
end;

procedure TformBrowser.HistoryChange(Sender: TObject);
{This event occurs when something changes history list}
var
  I: integer;
  Cap: string[80];
begin
with Sender as ThtmlViewer do
  begin
  {check to see which buttons are to be enabled}
  FwdButton.Enabled := HistoryIndex > 0;
  BackButton.Enabled := HistoryIndex < History.Count-1;

  {Enable and caption the appropriate history menuitems}
  HistoryMenuItem.Visible := History.Count > 0;
  for I := 0 to MaxHistories-1 do
    with Histories[I] do
      if I < History.Count then
        Begin
        Cap := History.Strings[I];
        if TitleHistory[I] <> '' then
          Cap := Cap + '--' + TitleHistory[I];
        Caption := Cap;    {Cap limits string to 80 char}
        Visible := True;
        Checked := I = HistoryIndex;
        end
      else Histories[I].Visible := False;
  Caption := DocumentTitle;    {keep the caption updated}
  Viewer.SetFocus;  
  end;
end;

procedure TformBrowser.HistoryClick(Sender: TObject);
{A history list menuitem got clicked on}
begin
  {Changing the HistoryIndex loads and positions the appropriate document}
  Viewer.HistoryIndex := (Sender as TMenuItem).Tag;
end;

procedure TformBrowser.Exit1Click(Sender: TObject);
begin
Close;
end;

procedure TformBrowser.FontColorsClick(Sender: TObject);
var
  FontForm: TFontForm;
begin
FontForm := TFontForm.Create(Self);
try
  with FontForm do
    begin
    FontName := Viewer.DefFontName;
    FontColor := Viewer.DefFontColor;
    FontSize := Viewer.DefFontSize;
    HotSpotColor := Viewer.DefHotSpotColor;
    Background := Viewer.DefBackground;
    if ShowModal = mrOK then
      begin
      Viewer.DefFontName := FontName;
      Viewer.DefFontColor := FontColor;
      Viewer.DefFontSize := FontSize;
      Viewer.DefHotSpotColor := HotSpotColor;
      Viewer.DefBackground := Background; 
      ReloadButtonClick(Self);    {reload to see how it looks}
      end;
    end;
finally
  FontForm.Free;
 end;
end;

procedure TformBrowser.Print1Click(Sender: TObject);
begin
with PrintDialog do
  if Execute then
    if PrintRange = prAllPages then
      viewer.Print(1, 9999)
    else
      Viewer.Print(FromPage, ToPage);
end;

procedure TformBrowser.PrinterSetup1Click(Sender: TObject);
begin
{$IFNDEF LCLCarbon}
PrinterSetupDialog.Execute;
{$ELSE}
  MessageDlg('Not yet supported with Carbon widgetset.',
             mtError, [mbOK], 0);
{$ENDIF}
end;

procedure TformBrowser.About1Click(Sender: TObject);
begin
AboutBox := TAboutBox.CreateIt(Self, 'HTMLDemo', 'ThtmlViewer');
try
  AboutBox.ShowModal;
finally
  AboutBox.Free;
  end;
end;


procedure TformBrowser.SubmitEvent(Sender: TObject; const AnAction, Target, EncType, Method: String;
  Results: TStringList);
begin
with SubmitForm do
  begin
  ActionText.Text := AnAction;
  MethodText.Text := Method;
  ResultBox.Items := Results;
  Results.Free;
  Show;
  end;
end;

procedure TformBrowser.Find1Click(Sender: TObject);
begin
FindDialog.Execute;
end;

procedure TformBrowser.FindDialogFind(Sender: TObject);
begin
with FindDialog do
  begin
  if not Viewer.FindEx(FindText, frMatchCase in Options, not (frDown in Options)) then
    MessageDlg('No further occurances of "'+FindText+'"', mtInformation, [mbOK], 0);
  end;
end;

procedure TformBrowser.ProcessingHandler(Sender: TObject; ProcessingOn: Boolean);
begin
if ProcessingOn then
  begin    {disable various buttons and menuitems during processing}
  FwdButton.Enabled := False;
  BackButton.Enabled := False;
  ReLoadButton.Enabled := False;
  Print1.Enabled := False;
  PrintPreview.Enabled := False;
  Find1.Enabled := False;
  SelectAllItem.Enabled := False;
  Open.Enabled := False;
  CloseAll;    {in case hint window is open}
  end
else
  begin
  FwdButton.Enabled := Viewer.HistoryIndex > 0;
  BackButton.Enabled := Viewer.HistoryIndex < Viewer.History.Count-1;
  ReLoadButton.Enabled := Viewer.CurrentFile <> '';
  Print1.Enabled := Viewer.CurrentFile <> '';
  PrintPreview.Enabled := Viewer.CurrentFile <> '';
  Find1.Enabled := Viewer.CurrentFile <> '';
  SelectAllItem.Enabled := Viewer.CurrentFile <> '';
  Open.Enabled := True;
  end;
end;

procedure TformBrowser.CopyItemClick(Sender: TObject);
begin
Viewer.CopyToClipboard;
end;

procedure TformBrowser.Edit2Click(Sender: TObject);
begin
CopyItem.Enabled := Viewer.SelLength <> 0;
end;

procedure TformBrowser.SelectAllItemClick(Sender: TObject);
begin
Viewer.SelectAll;
end;

procedure TformBrowser.OpenTextFileClick(Sender: TObject);
begin
if Viewer.CurrentFile <> '' then
  OpenDialog.InitialDir := ExtractFilePath(Viewer.CurrentFile);
OpenDialog.Filter := 'HTML Files (*.htm,*.html)|*.htm;*.html'+
    '|Text Files (*.txt)|*.txt'+
    '|All Files (*.*)|*.*';
if OpenDialog.Execute then
  begin
  ReloadButton.Enabled := False;
  Update;
  Viewer.LoadTextFile(OpenDialog.Filename);
  if Viewer.CurrentFile  <> '' then
    begin
    Caption := Viewer.DocumentTitle;
    ReLoadButton.Enabled := True;
    end;
  end;
end;

procedure TformBrowser.OpenImageFileClick(Sender: TObject);
begin
if Viewer.CurrentFile <> '' then
  OpenDialog.InitialDir := ExtractFilePath(Viewer.CurrentFile);
OpenDialog.Filter := 'Graphics Files (*.bmp,*.gif,*.jpg,*.jpeg,*.png)|'+
    '*.bmp;*.jpg;*.jpeg;*.gif;*.png|'+
    'All Files (*.*)|*.*';
if OpenDialog.Execute then
  begin
  ReloadButton.Enabled := False;
  Viewer.LoadImageFile(OpenDialog.Filename);
  if Viewer.CurrentFile  <> '' then
    begin
    Caption := Viewer.DocumentTitle;
    ReLoadButton.Enabled := True;
    end;
  end;
end;

{$IFNDEF LCL}
procedure TformBrowser.wmDropFiles(var Message: TMessage);
var
  S: string[200];
  Ext: string;
  Count: integer;
begin
Count := DragQueryFile(Message.WParam, 0, @S[1], 200);
Length(S) := Count;
DragFinish(Message.WParam);
if Count >0 then
  begin
{$ELSE}
procedure TformBrowser.DropFiles(      Sender    : TObject;
                           const FileNames : array of string);
var
  S  : string;
  Ext: string;
begin
  S := FileNames[0];
{$ENDIF}
  Ext := LowerCase(ExtractFileExt(S));
  if (Ext = '.htm') or (Ext = '.html') then
    Viewer.LoadFromFile(S)
  else if (Ext = '.txt') then
    Viewer.LoadTextFile(S)
  else if (Ext = '.bmp') or (Ext = '.gif') or (Ext = '.jpg')
        or (Ext = '.jpeg') or (Ext = '.png') then
    Viewer.LoadImageFile(S);
{$IFNDEF LCL}
  end;
Message.Result := 0;
{$ENDIF}
end;

procedure TformBrowser.MediaPlayerNotify(Sender: TObject);
begin
{$IFNDEF LCL}
try
  With MediaPlayer do
    if NotifyValue = nvSuccessful then
      begin
      if MediaCount > 0 then
        begin
        Play;
        Dec(MediaCount);
        end
      else
        Close;
      end;
except
  end;
{$ENDIF}
end;

procedure TformBrowser.SoundRequest(Sender: TObject; const SRC: String;
  Loop: Integer; Terminate: Boolean);
begin
{$IFNDEF LCL}
try
  with MediaPlayer do
    if Terminate then
      Close
    else
      begin
      Filename := (Sender as ThtmlViewer).HTMLExpandFilename(SRC);
      Notify := True;
      Open;
      if Loop < 0 then MediaCount := 9999
        else if Loop = 0 then MediaCount := 1
        else MediaCount := Loop;
      end;
except
  end;
{$ENDIF}
end;

procedure TformBrowser.ViewimageClick(Sender: TObject);
var
  AForm: TImageForm;
begin
AForm := TImageForm.Create(Self);
with AForm do
  begin
  ImageFormBitmap := FoundObject.Bitmap;
  Caption := '';
  Show;
  end;
end;

procedure TformBrowser.CopyImageToClipboardClick(Sender: TObject);
begin
Clipboard.Assign(FoundObject.Bitmap);
end;

procedure TformBrowser.ObjectClick(Sender, Obj: TObject; const OnClick: String);
var
  S: string;
begin
if OnClick = 'display' then
  begin
  if Obj is TFormControlObj then
    with TFormControlObj(Obj) do
      begin
      if TheControl is TCheckBox then
        with TCheckBox(TheControl) do
          begin
          S := Value + ' is ';
          if Checked then S := S + 'checked'
            else S := S + 'unchecked';
          MessageDlg(S, mtCustom, [mbOK], 0);
          end
      else if TheControl is TRadioButton then
        with TRadioButton(TheControl) do
          begin
          S := Value + ' is checked';
          MessageDlg(S, mtCustom, [mbOK], 0);
          end;
      end;
  end
else if OnClick <> '' then
      MessageDlg(OnClick, mtCustom, [mbOK], 0);
end;

{ In this event we should provide images for the html component }
procedure TformBrowser.ViewerImageRequest(Sender: TObject; const SRC: string;
  var Stream: TMemoryStream);
var
  J: Integer;
  URL: string;
begin
  // Add the base URL if the URL is relative
  J := Pos(':', UpperCase(SRC));
  if J = 0 then
  begin
    URL := MyPageLoader.LastPageURL + Copy(SRC, 2, Length(SRC)-1)
  end
  else URL := SRC;


  J := Pos('HTTP:', UpperCase(URL));
  if (J > 0) then
  begin
    MyPageLoader.LoadBinaryResource(URL, Stream);
    Exit;
  end;
end;


procedure TformBrowser.ViewerInclude(Sender: TObject; const Command: String;
  Params: TStrings; var S: string);
{OnInclude handler}  
var
  Filename: string;
  I: integer;
  MS: TMemoryStream;
begin
if CompareText(Command, 'Date') = 0 then
  S := DateToStr(Date) { <!--#date --> }
else if CompareText(Command, 'Time') = 0 then
  S := TimeToStr(Time)   { <!--#time -->  }
else if CompareText(Command, 'Include') = 0 then
  begin   {an include file <!--#include FILE="filename" -->  }
  if (Params.count >= 1) then
    begin
    I := Pos('file=', Lowercase(Params[0]));
    if I > 0 then
      begin
      Filename := copy(Params[0],  6, Length(Params[0])-5);
      MS := TMemoryStream.Create;
      try
        try
          MS.LoadFromFile(Filename);
          SetString(S, PChar(MS.Memory), MS.Size);
        finally
          MS.Free;
          end;
      except
        end;
      end;
    end;
  end;
Params.Free;
end;

procedure TformBrowser.FormDestroy(Sender: TObject);
begin
HintWindow.Free;
end;

procedure TformBrowser.RightClick(Sender: TObject; Parameters: TRightClickParameters);
var
  Pt: TPoint;
  S, Dest: string;
  I: integer;
  HintWindow: THintWindow;  
  ARect: TRect;
begin
with Parameters do
  begin
  FoundObject := Image;
  ViewImage.Enabled := (FoundObject <> Nil) and (FoundObject.Bitmap <> Nil);
  CopyImageToClipboard.Enabled := (FoundObject <> Nil) and (FoundObject.Bitmap <> Nil);
  if URL <> '' then
    begin
    S := URL;
    I := Pos('#', S);
    if I >= 1 then
      begin
      Dest := System.Copy(S, I, 255);  {local destination}
      S := System.Copy(S, 1, I-1);     {the file name}
      end
    else
      Dest := '';    {no local destination}
    if S = '' then S := Viewer.CurrentFile
      else S := Viewer.HTMLExpandFileName(S);
    NewWindowFile := S+Dest;
    OpenInNewWindow.Enabled := FileExists(S);
    end
  else OpenInNewWindow.Enabled := False;

  GetCursorPos(Pt);
  if Length(CLickWord) > 0 then
    begin
    HintWindow := THintWindow.Create(Self);   
    try
      ARect := Rect(0,0,0,0);
      DrawTextW(HintWindow.Canvas.Handle, @ClickWord[1], Length(ClickWord), ARect, DT_CALCRECT);
      with ARect do
        HintWindow.ActivateHint(Rect(Pt.X+20, Pt.Y-(Bottom-Top)-15, Pt.x+30+Right, Pt.Y-15), ClickWord);
      PopupMenu.Popup(Pt.X, Pt.Y);
    finally
      HintWindow.Free;
      end;
    end
  else PopupMenu.Popup(Pt.X, Pt.Y);
  end;
end;

procedure TformBrowser.OpenInNewWindowClick(Sender: TObject);
var
  PC: array[0..255] of char;
{$IFDEF LCL}
  PC2: array[0..255] of char;
{$ENDIF}
begin
{$IFNDEF LCL}
  WinExec(StrPCopy(PC, ParamStr(0)+' "'+NewWindowFile+'"'), sw_Show);
{$ELSE}
 {$IFDEF MSWINDOWS}
  ShellExecute(Handle, nil, StrPCopy(PC, ParamStr(0)), 
               StrPCopy(PC2, NewWindowFile), nil, SW_SHOWNORMAL); 
 {$ELSE}
  {$IFDEF DARWIN}
  Shell('open -n "' + 
        ExtractFileDir(ExtractFileDir(ExtractFileDir(ParamStr(0)))) + 
        '" --args "' + NewWindowFile + '"');
  {$ELSE}
  Shell('"' + ParamStr(0) + '" "' + NewWindowFile + '"');
  {$ENDIF}
 {$ENDIF}
{$ENDIF}
end;

procedure TformBrowser.MetaTimerTimer(Sender: TObject);
begin
MetaTimer.Enabled := False;
if Viewer.CurrentFile = PresentFile then  {don't load if current file has changed}
  begin
  Viewer.LoadFromFile(NextFile);
  Caption := Viewer.DocumentTitle;
  end;
end;

procedure TformBrowser.MetaRefreshEvent(Sender: TObject; Delay: Integer;
  const URL: String);
begin
NextFile := Viewer.HTMLExpandFilename(URL);  
if FileExists(NextFile) then
  begin
  PresentFile := Viewer.CurrentFile;
  MetaTimer.Interval := Delay*1000;
  MetaTimer.Enabled := True;
  end;
end;

procedure TformBrowser.PrintpreviewClick(Sender: TObject);
{$IFNDEF LCL}
var
  pf: TPreviewForm;
  Abort: boolean;
begin
pf := TPreviewForm.CreateIt(Self, Viewer, Abort);
try
  if not Abort then
    pf.ShowModal;
finally
  pf.Free;
  end;
{$ELSE}
begin
  MessageDlg('Not yet supported with LCL.',
             mtError, [mbOK], 0);
{$ENDIF}
end;

procedure TformBrowser.ViewerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  TitleStr: string;
begin
if not Timer1.Enabled and Assigned(ActiveControl) and ActiveControl.Focused then    {9.25}
  begin
  TitleStr := Viewer.TitleAttr;
  if TitleStr = '' then
    OldTitle := ''
  else if TitleStr <> OldTitle then
    begin
    TimerCount := 0;
    Timer1.Enabled := True;
    OldTitle := TitleStr;
    end;
  end;
end;

procedure TformBrowser.CloseAll;
begin
Timer1.Enabled := False;
HintWindow.ReleaseHandle;
HintVisible := False;
end;

procedure TformBrowser.LoadURL(AURL: string);
begin
  MyPageLoader.LoadFromURL(AURL);
  Viewer.LoadFromString(MyPageLoader.Contents);
  Caption := Viewer.DocumentTitle;
end;

procedure TformBrowser.Timer1Timer(Sender: TObject);
const
  StartCount = 2; {timer counts before hint window opens}
  EndCount = 20;  {after this many timer counts, hint window closes}
var
  Pt, Pt1: TPoint;
  ARect: TRect;
  TitleStr: string;

begin
Inc(TimerCount);
GetCursorPos(Pt);
Pt1 := Viewer.ScreenToClient(Pt);
TitleStr := Viewer.TitleAttr;
if (TitleStr = '') or not PtInRect(Viewer.ClientRect, Pt1)then
  begin
  OldTitle := '';
  CloseAll;
  Exit;
  end;
if TitleStr <> OldTitle then
  begin
  TimerCount := 0;
  OldTitle := TitleStr;
  HintWindow.ReleaseHandle;
  HintVisible := False;
  Exit;
  end;

if TimerCount > EndCount then
  CloseAll
else if (TimerCount >= StartCount) and not HintVisible then
  begin
  {$ifdef ver90}  {Delphi 2}
  ARect := Rect(0,0,0,0);
  DrawText(HintWindow.Canvas.Handle, PChar(TitleStr), Length(TitleStr), ARect, DT_CALCRECT);
  {$else}
  ARect := HintWindow.CalcHintRect(300, TitleStr, Nil);
  {$endif}
  with ARect do
    HintWindow.ActivateHint(Rect(Pt.X, Pt.Y+18, Pt.X+Right, Pt.Y+18+Bottom), TitleStr);
  HintVisible := True;
  end;
end;

procedure TformBrowser.ViewerProgress(Sender: TObject; Stage: TProgressStage;
  PercentDone: Integer);
begin
ProgressBar.Position := PercentDone;
case Stage of
  psStarting:
    ProgressBar.Visible := True;
  psRunning:;
  psEnding:
    ProgressBar.Visible := False;
  end;
ProgressBar.Update;
end;

{HTML for print header and footer}
const
  HFText: string =  '<html><head><style>'+
            'body  {font: Arial 8pt;}'+
          '</style></head>'+
          '<body marginwidth="0">'+
          '<table border="0" cellspacing="2" cellpadding="1" width="100%">'+
            '<tr>'+
              '<td>#left</td><td align="right">#right</td>'+
            '</tr>'+
          '</table></body></html>';

function ReplaceStr(Const S, FromStr, ToStr: string): string;
{replace FromStr with ToStr in string S.
 for Delphi 6, 7, AnsiReplaceStr may be used instead.}
var
  I: integer;
begin
I := Pos(FromStr, S);
if I > 0 then
  begin
  Result := S;
  Delete(Result, I, Length(FromStr));
  Insert(ToStr, Result, I);
  end;
end;

procedure TformBrowser.ViewerPrintHTMLHeader(Sender: TObject;
  HFViewer: THTMLViewer; NumPage: Integer; LastPage: boolean; var XL, XR: integer; var StopPrinting: Boolean);
var
  S: string;
begin
S := ReplaceStr(HFText, '#left', Viewer.DocumentTitle);
S := ReplaceStr(S, '#right', Viewer.CurrentFile);
HFViewer.LoadFromString(S);
end;

procedure TformBrowser.ViewerPrintHTMLFooter(Sender: TObject;
  HFViewer: THTMLViewer; NumPage: Integer; LastPage: boolean; var XL, XR: integer; var StopPrinting: Boolean);
var
  S: string;
begin
S := ReplaceStr(HFText, '#left', DateToStr(Date));
S := ReplaceStr(S, '#right', 'Page '+IntToStr(NumPage));
HFViewer.LoadFromString(S);
end;

initialization
{$IFDEF LCL}
{$I mainform.lrs}  {Include form's resource file}
{$ENDIF}

end.
