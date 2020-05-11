unit Utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs;

function AnySelected(AListbox: TListBox): Boolean;

procedure ErrorMsg(const AMsg: String);
procedure ErrorMsg(const AMsg: String; const AParams: array of const);

procedure Exchange(var a, b: Double); overload;
procedure Exchange(var a, b: Integer); overload;
procedure Exchange(var a, b: String); overload;

implementation

function AnySelected(AListBox: TListBox): Boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to AListbox.Items.Count-1 do
    if AListbox.Selected[i] then
    begin
      Result := true;
      exit;
    end;
end;

procedure ErrorMsg(const AMsg: String);
begin
  MessageDlg(AMsg, mtError, [mbOK], 0);
end;

procedure ErrorMsg(const AMsg: String; const AParams: array of const);
begin
  ErrorMsg(Format(AMsg, AParams));
end;

procedure Exchange(var a, b: Double);
var
  tmp: Double;
begin
  tmp := a;
  a := b;
  b := tmp;
end;

procedure Exchange(var a, b: Integer);
var
  tmp: Integer;
begin
  tmp := a;
  a := b;
  b := tmp;
end;

procedure Exchange(var a, b: String);
var
  tmp: String;
begin
  tmp := a;
  a := b;
  b := tmp;
end;

end.

