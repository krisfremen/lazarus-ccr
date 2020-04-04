unit Utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls;

function AnySelected(AListbox: TListBox): Boolean;

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

end.

