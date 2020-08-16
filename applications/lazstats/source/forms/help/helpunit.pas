unit HelpUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, {FileUtil, }LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LazHelpHTML, HelpIntfs;

type

  { THelpFrm }

  THelpFrm = class(TForm)
    ReturnBtn: TButton;
    HelpBtn: TButton;
    HTMLBrowserHelpViewer1: THTMLBrowserHelpViewer;
    HTMLHelpDatabase1: THTMLHelpDatabase;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  HelpFrm: THelpFrm;

procedure ShowHelpTopic(AHelpContext: Word); overload;
procedure ShowHelpTopic(AHelpID: PChar); overload;

implementation

uses
  {$IFDEF USE_EXTERNAL_HELP_VIEWER}
  {$IFDEF MSWINDOWS}
  htmlhelp,
  {$ENDIF}
  {$ENDIF}
  LazFileUtils;

procedure ShowHelpTopic(AHelpContext: Word);
var
  fn: UnicodeString;
begin
 {$IFDEF USE_EXTERNAL_HELP_VIEWER}
  {$IFDEF MSWINDOWS}
  // see: http://www.helpware.net/download/delphi/hh_doc.txt
  fn := UnicodeString(Application.HelpFile);
  htmlhelp.HtmlHelpW(0, PWideChar(fn), HH_HELP_CONTEXT, AHelpContext);
  {$ENDIF}
 {$ENDIF}
end;

procedure ShowHelpTopic(AHelpID: PChar);
var
  topic: UnicodeString;
begin
  {$IFDEF USE_EXTERNAL_HELP_VIEWER}
   {$IFDEF MSWINDOWS}
   topic := UnicodeString(Application.HelpFile + '::/' + AHelpID);
   htmlhelp.HtmlHelpW(0, PWideChar(topic), HH_DISPLAY_TOPIC, 0);
   {$ENDIF}
 {$ENDIF}
end;

{ THelpFrm }

procedure THelpFrm.FormShow(Sender: TObject);
begin
//  HelpBtnClick(self);
end;

procedure THelpFrm.FormCreate(Sender: TObject);
begin
  HTMLHelpDatabase1.BaseURL := 'file://html';
end;

procedure THelpFrm.HelpBtnClick(Sender: TObject);
var
  fn: String;
begin
  fn := Application.Location + 'html/LAZTOC.html';
  ShowHelpOrErrorForKeyword('', SwitchPathDelims(fn, true)); //Application.Location + 'html/LAZTOC.html');
end;

initialization
  {$I helpunit.lrs}

end.

