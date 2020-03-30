unit HelpUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
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

implementation

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
begin
  ShowHelpOrErrorForKeyword('','HTML/LAZTOC.html');
end;

initialization
  {$I helpunit.lrs}

end.

