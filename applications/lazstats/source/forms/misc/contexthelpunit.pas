unit ContextHelpUnit;

{$mode objfpc}
{$H+}

interface

uses
  IniFiles, Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls;

type

  { TContextHelpForm }

  TContextHelpForm = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure HelpMessage(lTag: integer);
  end; 

var
  ContextHelpForm: TContextHelpForm;

implementation

function ReadIniFileTag(var lTag: Integer): string;
//Read string with index lTag
var
  lIniFile: TIniFile;
  lFilename,lLang: string;
begin
  lFilename := changefileext(paramstr(0),'.ini');
  if (not Fileexists(lFilename)) then begin
    result := 'No contextual help: unable to find '+lFilename;
    exit;
  end;
  result := 'No contextual help found for '+IntToStr(lTag);
  lIniFile := TIniFile.Create(lFilename);
  try
    lLang := lIniFile.ReadString('LANGUAGE', 'DEFAULT', '');
    result := lIniFile.ReadString(lLang, IntToStr(lTag), result);
  finally
    lIniFile.Free;
  end;
end;

procedure TContextHelpForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TContextHelpForm.HelpMessage(lTag: integer);
begin
  Memo1.Lines.Clear;
  Memo1.lines.Add(ReadIniFileTag(lTag));
  ContextHelpForm.Show;
end;

initialization
  {$I contexthelpunit.lrs}

end.

