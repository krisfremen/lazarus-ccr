unit Utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs,
  Globals;

function AnySelected(AListbox: TListBox): Boolean;

procedure ErrorMsg(const AMsg: String);
procedure ErrorMsg(const AMsg: String; const AParams: array of const);

procedure Exchange(var a, b: Double); overload;
procedure Exchange(var a, b: Integer); overload;
procedure Exchange(var a, b: String); overload;

procedure SortOnX(X, Y: DblDyneVec);

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

procedure SortOnX(X, Y: DblDyneVec);
var
  i, j, N: Integer;
begin
  N := Length(X);
  if N <> Length(Y) then
    raise Exception.Create('[SortOnX] Both arrays must have the same length');

  for i := 0 to N - 2 do
  begin
    for j := i + 1 to N - 1 do
    begin
      if X[i] > X[j] then //swap
      begin
        Exchange(X[i], X[j]);
        Exchange(Y[i], Y[j]);
      end;
    end;
  end;
end;

end.

