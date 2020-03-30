unit ScriptOptsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TScriptOptsFrm }

  TScriptOptsFrm = class(TForm)
    CancelBtn: TButton;
    ReturnBtn: TButton;
    CheckGroup1: TCheckGroup;
    procedure FormActivate(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  ScriptOptsFrm: TScriptOptsFrm;

implementation

uses
  Math;

{ TScriptOptsFrm }

procedure TScriptOptsFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([CancelBtn.Width, ReturnBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure TScriptOptsFrm.ReturnBtnClick(Sender: TObject);
var
   scriptopts : textfile;
   checked : integer;
begin
     AssignFile(scriptopts, 'Options.SCR');
     Rewrite(scriptopts);
     if CheckGroup1.Checked[0] then checked := 1 else checked := 0;
     Writeln(scriptopts,checked);
     if CheckGroup1.Checked[1] then checked := 1 else checked := 0;
     Writeln(scriptopts,checked);
     closefile(scriptopts);
end;

initialization
  {$I scriptoptsunit.lrs}

end.

