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
  private
    FMaxSteps: Integer;
    Grid: TRawGrid;
    procedure CalculateValues(out IsSolved: Boolean);
    procedure CheckRow(Col, Row: Integer);
    procedure CheckCol(Col, Row: Integer);
    procedure CheckBlock(Col, Row: Integer);
    procedure CheckDigits(ADigit: Integer);
    procedure CheckInput(Values: TValues);
    procedure ValuesToGrid(Values: TValues);
    function GridToValues: TValues;
    function Solve(out Steps: Integer): Boolean;
  public
    constructor Create;
    function GiveSolution(var Values: TValues; out RawData: TRawGrid; out Steps: Integer): Boolean;
    function GiveSolution(var RawData: TRawGrid; out Values: TValues; out Steps: Integer): Boolean;
    property MaxSteps: Integer read FMaxSteps write FMaxSteps default 50;
  end;

  ESudoku = class(Exception);

const
  AllDigits: TDigitSet = [1, 2, 3, 4, 5, 6, 7, 8, 9];

function DbgS(ASet: TDigitSet): String; overload;
function DbgS(ASquare: TSquare): String; overload;

implementation

const
  cmin : Array[1..9] of Integer = (1, 1, 1, 4, 4, 4, 7, 7, 7);
  cmax : Array[1..9] of Integer = (3, 3, 3, 6, 6, 6, 9, 9, 9);

function DbgS(ASet: TDigitSet): String; overload;
var
  D: TDigits;
begin
  Result := '[';
  for D in ASet do
  begin
    Result := Result + IntToStr(D) + ',';
  end;
  if (Result[Length(Result)] = ',') then System.Delete(Result, Length(Result), 1);
  Result := Result + ']';
end;

function DbgS(ASquare: TSquare): String; overload;
const
  BoolStr: Array[Boolean] of String = ('False','True');
begin
  Result := '[Value: ' + IntToStr(ASquare.Value) + ', ';
  Result := Result + 'Locked: ' + BoolStr[ASquare.Locked] + ', ';
  Result := Result + 'DigitsPossible: ' + DbgS(ASquare.DigitsPossible) + ']';
end;

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
  for D := 1 to 9 do
  begin
    if D in ASet then
    begin
      Inc(Result);
      aValue := D;
    end;
  end;
end;

function IsEqualGrid(const A, B: TRawGrid): Boolean;
var
  Col, Row: Integer;
begin
  Result := False;
  for Col := 1 to 9 do
  begin
    for Row := 1 to 9 do
    begin
      if (A[Col,Row].DigitsPossible <> B[Col,Row].DigitsPossible) or
         (A[Col,Row].Locked <> B[Col,Row].Locked) or
         (A[Col,Row].Value <> B[Col,Row].Value) then
         Exit;
    end;
  end;
  Result := True;
end;

{ TSudoku }

procedure TSudoku.ValuesToGrid(Values: TValues);
var
  c, r: Integer;
begin
  for c := 1 to 9 do
  begin
    for r := 1 to 9 do
    begin
      if Values[c, r] in [1..9] then
      begin
        Grid[c, r].Locked := True;
        Grid[c, r].Value := Values[c, r];
        Grid[c, r].DigitsPossible := [(Values[c, r])];
      end
      else
      begin
        Grid[c, r].Locked := False;
        Grid[c, r].Value := 0;
        Grid[c, r].DigitsPossible := AllDigits;
      end;
    end;
  end;
end;

function TSudoku.GridToValues: TValues;
var
  Col, Row: Integer;
begin
  for Col := 1 to 9 do
  begin
    for Row := 1 to 9 do
    begin
      Result[Col, Row] := Grid[Col, Row].Value;
    end;
  end;
end;

function TSudoku.Solve(out Steps: Integer): Boolean;
var
  c, r: Integer;
  OldState: TRawGrid;
begin
  Steps := 0;
  repeat
    inc(Steps);
    OldState := Grid;
    for c := 1 to 9  do
    begin
      for r := 1 to 9 do
      begin
        if not Grid[c, r].Locked then
        begin
          CheckRow(c, r);
          CheckCol(c, r);
          CheckBlock(c, r);
        end;
      end;
    end;
    for c := 1 to 9 do CheckDigits(c);
    CalculateValues(Result);

    //if IsConsole then
    //  writeln('Steps = ',Steps,', IsEqualGrid(OldState, Grid) = ',IsEqualGrid(OldState, Grid));

  until Result or (Steps >= FMaxSteps) or (IsEqualGrid(OldState, Grid));
end;

constructor TSudoku.Create;
begin
  inherited Create;
  FMaxSteps := 50;
end;

function TSudoku.GiveSolution(var Values: TValues; out RawData: TRawGrid; out Steps: Integer): Boolean;
begin
  CheckInput(Values);
  ValuesToGrid(Values);
  Result := Solve(Steps);
  Values := GridToValues;
  RawData := Grid;
end;

{
Note: no sanity check on RawData is performed!
}
function TSudoku.GiveSolution(var RawData: TRawGrid; out Values: TValues; out Steps: Integer): Boolean;
begin
  Grid := RawData;
  Result := Solve(Steps);
  RawData := Grid;
  Values := GridToValues;
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
  for i := 1 to 9 do
  begin
    if i = Row then continue;
    for d := 1 to 9 do
    begin
      if Grid[Col, i].Value = d then exclude(Grid[Col, Row].DigitsPossible, d);
    end;
  end;
end;

procedure TSudoku.CheckRow(Col, Row: Integer);
var
  i, d: Integer;
begin
  for i := 1 to 9 do
  begin
    if i = Col then continue;
    for d := 1 to 9 do
    begin
      if Grid[i, Row].Value = d then exclude(Grid[Col, Row].DigitsPossible, d);
    end;
  end;
end;

procedure TSudoku.CheckBlock(Col, Row: Integer);
var
  i, j, d: Integer;
begin
  for i := cmin[Col] to cmax[Col] do
  begin
    for j := cmin[Row] to cmax[Row] do
    begin
      if not ((i = Col) and (j = Row)) then
      begin
        for d := 1 to 9 do
        begin
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
  for c := 1 to 9 do
  begin
    for r := 1 to 9 do
    begin
      if Grid[c, r].Locked
        or (CountSetMembers(Grid[c, r].DigitsPossible, Value) = 1) then continue;
      if ADigit in Grid[c, r].DigitsPossible then
      begin
        OtherPossible := False;
        for i := 1 to 9 do
        begin
          if i <> c then OtherPossible := (ADigit in Grid[i, r].DigitsPossible);
          if OtherPossible then Break;
        end;
        if not OtherPossible then
        begin
          Grid[c, r].DigitsPossible := [ADigit];
        end
        else
        begin
          OtherPossible := False;
          for i := 1 to 9 do
          begin
            if i <> r then OtherPossible := (ADigit in Grid[c, i].DigitsPossible);
            if OtherPossible then Break;
          end;
          if not OtherPossible then
          begin
            Grid[c, r].DigitsPossible := [ADigit];
          end;
        end;
      end;
    end;
  end;
end;

procedure TSudoku.CheckInput(Values: TValues);
  procedure CheckColValues;
  var
    Col, Row: Integer;
    DigitSet: TDigitSet;
    D: Integer;
  begin
    for Col :=  1 to 9 do
    begin
      DigitSet := [];
      for Row := 1 to 9 do
      begin
        D := Values[Col, Row];
        if (D <> 0) then
        begin
          if (D in DigitSet) then
            Raise ESudoku.CreateFmt('Duplicate value ("%d") in Col %d',[D, Col]);
          Include(DigitSet, D);
        end;
      end;
    end;
  end;

  procedure CheckRowValues;
  var
    Col, Row: Integer;
    DigitSet: TDigitSet;
    D: Integer;
  begin
    for Row :=  1 to 9 do
    begin
      DigitSet := [];
      for Col := 1 to 9 do
      begin
        D := Values[Col, Row];
        if (D <> 0) then
        begin
          if (D in DigitSet) then
            Raise ESudoku.CreateFmt('Duplicate value ("%d") in Row %d',[D, Row]);
          Include(DigitSet, D);
        end;
      end;
    end;
  end;

  procedure CheckBlockValues(StartCol, StartRow: Integer);
  var
    Col, Row: Integer;
    DigitSet: TDigitSet;
    D: Integer;
  begin
    DigitSet := [];
    for Col := StartCol to StartCol + 2 do
    begin
      for Row := StartRow to StartRow + 2 do
      begin
        D := Values[Col,Row];
        if (D <> 0) then
        begin
          if (D in DigitSet) then
            Raise ESudoku.CreateFmt('Duplicate value ("%d") in block at Row: %d, Col: %d',[D, Row, Col]);
          Include(DigitSet, D);
        end;
      end;
    end;
  end;

begin
  CheckRowValues;
  CheckColValues;
  CheckBlockValues(1,1);
  CheckBlockValues(1,4);
  CheckBlockValues(1,7);
  CheckBlockValues(4,1);
  CheckBlockValues(4,4);
  CheckBlockValues(4,7);
  CheckBlockValues(7,1);
  CheckBlockValues(7,4);
  CheckBlockValues(7,7);
end;


end.

