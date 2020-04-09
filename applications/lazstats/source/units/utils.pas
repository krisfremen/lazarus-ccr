unit Utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls;

function AnySelected(AListbox: TListBox): Boolean;

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

