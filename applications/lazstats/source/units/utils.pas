unit Utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, StdCtrls, ComCtrls, Dialogs,
  Globals;

type
  TToolbarPosition = (tpTop, tpLeft, tpRight);

procedure AddButtonToToolbar(AToolButton: TToolButton; AToolBar: TToolBar);
procedure InitToolbar(AToolbar: TToolbar; APosition: TToolbarPosition);

function AnySelected(AListbox: TListBox): Boolean;

procedure ErrorMsg(const AMsg: String);
procedure ErrorMsg(const AMsg: String; const AParams: array of const);

procedure Exchange(var a, b: Double); overload;
procedure Exchange(var a, b: Integer); overload;
procedure Exchange(var a, b: String); overload;

procedure SortOnX(X, Y: DblDyneVec);
procedure SortOnX(X: DblDyneVec; Y: DblDyneMat);

function IndexOfString(L: StrDyneVec; s: String): Integer;


implementation

uses
  ToolWin;

// https://stackoverflow.com/questions/4093595/create-ttoolbutton-runtime
procedure AddButtonToToolbar(AToolButton: TToolButton; AToolBar: TToolBar);
var
  lastBtnIdx: integer;
begin
  lastBtnIdx := AToolBar.ButtonCount - 1;
  if lastBtnIdx > -1 then
    AToolButton.Left := AToolBar.Buttons[lastBtnIdx].Left + AToolBar.Buttons[lastBtnIdx].Width
  else
    AToolButton.Left := 0;
  AToolButton.Parent := AToolBar;
end;


procedure InitToolbar(AToolbar: TToolbar; APosition: TToolbarPosition);
begin
//  AToolbar.Transparent := false;
//  AToolbar.Color := clForm;
  case APosition of
    tpTop:
      begin
        AToolbar.Align := alTop;
        AToolbar.EdgeBorders := [ebBottom];
      end;
    tpLeft:
      begin
        AToolbar.Align := alLeft;
        AToolbar.EdgeBorders := [ebRight];
      end;
    tpRight:
      begin
        AToolbar.Align := alRight;
        AToolbar.EdgeBorders := [ebLeft];
      end;
  end;
end;


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

// NOTE: The matrix Y is transposed relative to the typical usage in LazStats
procedure SortOnX(X: DblDyneVec; Y: DblDyneMat);
var
  i, j, k, N, Ny: Integer;
begin
  N := Length(X);
  if N <> Length(Y[0]) then
    raise Exception.Create('[SortOnX] Arrays X and Y (2nd index) must have the same length');
  Ny := Length(Y);

  for i := 0 to N-2 do
  begin
    for j := i+1 to N-1 do
      if X[i] > X[j] then
      begin
        Exchange(X[i], X[j]);
        for k := 0 to Ny-1 do
          Exchange(Y[k, i], Y[k, j]);
      end;
  end;
end;

function IndexOfString(L: StrDyneVec; s: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(L) do
    if L[i] = s then
    begin
      Result := i;
      exit;
    end;
end;

end.

