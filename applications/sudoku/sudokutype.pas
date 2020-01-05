unit SudokuType;

{
 ***************************************************************************
 *   Copyright (C) 2006  Matthijs Willemstein                              *
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.        *
 *                                                                         *
 ***************************************************************************
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls;
  
type
  TDigits = 1..9;
  TDigitSet = set of TDigits;
  TSquare = record
    Value: Integer;   // The value of this square.
    Locked: Boolean;  // Wether or not the value is known.
    DigitsPossible: TDigitSet;
  end;
  TValues = Array[1..9,1..9] of Integer;
  TRawGrid = Array[1..9, 1..9] of TSquare;

  { TSudoku }

  TSudoku = class(TObject)
    function GiveSolution(var Values: TValues; out Steps: Integer): Boolean;
  private
    Grid: TRawGrid;
    procedure CalculateValues(out IsSolved: Boolean);
    procedure CheckRow(Col, Row: Integer);
    procedure CheckCol(Col, Row: Integer);
    procedure CheckBlock(Col, Row: Integer);
    procedure CheckDigits(ADigit: Integer);
    procedure FillGridFromValues(Values: TValues);
    function Solve(out Steps: Integer): Boolean;
    //function Solved: Boolean;
  end;

implementation

const
  cmin : Array[1..9] of Integer = (1, 1, 1, 4, 4, 4, 7, 7, 7);
  cmax : Array[1..9] of Integer = (3, 3, 3, 6, 6, 6, 9, 9, 9);

{
Counts the number of TDigitSet in ASet.
aValue only has meaning if Result = 1 (which means this cell is solved)
}
function CountSetMembers(const ASet: TDigitSet; out aValue: Integer): Integer;
var
  D: Integer;
begin
  Result := 0;
  aValue := 0;
  for D := 1 to 9 do begin
    if D in ASet then begin
      Inc(Result);
      aValue := D;
    end;
  end;
end;

{ TSudoku }

procedure TSudoku.FillGridFromValues(Values: TValues);
var
  c, r: Integer;
begin
  for c := 1 to 9 do begin
    for r := 1 to 9 do begin
      if Values[c, r] in [1..9] then begin
        Grid[c, r].Locked := True;
        Grid[c, r].Value := Values[c, r];
        Grid[c, r].DigitsPossible := [(Values[c, r])];
      end else begin
        Grid[c, r].Locked := False;
        Grid[c, r].Value := 0;
        Grid[c, r].DigitsPossible := [1, 2, 3, 4, 5, 6, 7, 8, 9];
      end;
    end;
  end;
end;

function TSudoku.Solve(out Steps: Integer): Boolean;
var
  c, r: Integer;
begin
  Steps := 0;
  repeat
    inc(Steps);
    for c := 1 to 9  do begin
      for r := 1 to 9 do begin
        if not Grid[c, r].Locked then begin
          CheckRow(c, r);
          CheckCol(c, r);
          CheckBlock(c, r);
        end;
      end;
    end;
    for c := 1 to 9 do CheckDigits(c);
    CalculateValues(Result);
  until Result or (Steps > 50);
end;

function TSudoku.GiveSolution(var Values: TValues; out Steps: Integer): Boolean;
var
  c, r: Integer;
begin
  FillGridFromValues(Values);
  Result := Solve(Steps);
  for c := 1 to 9 do begin
    for r := 1 to 9 do begin
      Values[c, r] := Grid[c, r].Value;
    end;
  end;
end;

procedure TSudoku.CalculateValues(out IsSolved: Boolean);
var
  c, r: Integer;
  Value, Count: Integer;
begin
  Count := 0;
  for c := 1 to 9 do
  begin
    for r := 1 to 9 do
    begin
      if Grid[c, r].Locked then
        Inc(Count)
      else
      begin
        if CountSetMembers(Grid[c, r].DigitsPossible, Value) = 1 then
        begin
          Grid[c, r].Value := Value;
          Grid[c, r].Locked := True;
          Inc(Count);
        end;
      end;
    end;
  end;
  IsSolved := Count = 9 * 9;
end;

procedure TSudoku.CheckCol(Col, Row: Integer);
var
  i, d: Integer;
begin
  for i := 1 to 9 do begin
    if i = Row then continue;
    for d := 1 to 9 do begin
      if Grid[Col, i].Value = d then exclude(Grid[Col, Row].DigitsPossible, d);
    end;
  end;
end;

procedure TSudoku.CheckRow(Col, Row: Integer);
var
  i, d: Integer;
begin
  for i := 1 to 9 do begin
    if i = Col then continue;
    for d := 1 to 9 do begin
      if Grid[i, Row].Value = d then exclude(Grid[Col, Row].DigitsPossible, d);
    end;
  end;
end;

procedure TSudoku.CheckBlock(Col, Row: Integer);
var
  i, j, d: Integer;
begin
  for i := cmin[Col] to cmax[Col] do begin
    for j := cmin[Row] to cmax[Row] do begin
      if not ((i = Col) and (j = Row)) then begin
        for d := 1 to 9 do begin
          if Grid[i, j].Value = d then exclude(Grid[Col, Row].DigitsPossible, d);
        end;
      end;
    end;
  end;
end;

procedure TSudoku.CheckDigits(ADigit: Integer);
var
  OtherPossible: Boolean;
  c, r: Integer;
  i: Integer;
  value: Integer;
begin
  for c := 1 to 9 do begin
    for r := 1 to 9 do begin
      if Grid[c, r].Locked
        or (CountSetMembers(Grid[c, r].DigitsPossible, Value) = 1) then continue;
      if ADigit in Grid[c, r].DigitsPossible then begin
        OtherPossible := False;
        for i := 1 to 9 do begin
          if i <> c then OtherPossible := (ADigit in Grid[i, r].DigitsPossible);
          if OtherPossible then Break;
        end;
        if not OtherPossible then begin
          Grid[c, r].DigitsPossible := [ADigit];
        end else begin
          OtherPossible := False;
          for i := 1 to 9 do begin
            if i <> r then OtherPossible := (ADigit in Grid[c, i].DigitsPossible);
            if OtherPossible then Break;
          end;
          if not OtherPossible then begin
            Grid[c, r].DigitsPossible := [ADigit];
          end;
        end;
      end;
    end;
  end;
end;

//function TSudoku.Solved: Boolean;
//var
//  c, r: Integer;
//begin
//  result := True;
//  for c := 1 to 9 do begin
//    for r := 1 to 9 do begin
//      if not Grid[c, r].Locked then begin
//        Result := False;
//        Break;
//      end;
//    end;
//    if not result then Break;
//  end;
//end;

end.
