unit sudokumain;

{
 ***************************************************************************
 *   Copyright (C) 2006  Matthijs Willemstein                              *
 *                                                                         *
 *   Note: the original code by Matthijs was checked in as revision 7217   *
 *   in Lazarus-CCR subversion repository                                  *
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
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Grids,
  Buttons, StdCtrls, SudokuType;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonSolve: TButton;
    ButtonFill: TButton;
    StringGrid1: TStringGrid;
    procedure ButtonFillClick(Sender: TObject);
    procedure ButtonSolveClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure StringGrid1PrepareCanvas(sender: TObject; aCol, aRow: Integer;
      {%H-}aState: TGridDrawState);
    procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
  private
    { private declarations }
    theValues: TValues;
    function SolveSudoku: Boolean;
    procedure ShowSolution;
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm }

{ TForm1 }

procedure TForm1.ButtonFillClick(Sender: TObject);
var
  c, r: Integer;
begin
  for c := 0 to pred(StringGrid1.ColCount) do
    for r := 0 to pred(StringGrid1.RowCount) do
      StringGrid1.Cells[c, r] := '';
  StringGrid1.Options := StringGrid1.Options + [goEditing];
  StringGrid1.SetFocus;
end;

procedure TForm1.ButtonSolveClick(Sender: TObject);
begin
  StringGrid1.Options := StringGrid1.Options - [goEditing];
  SolveSudoku;
  ShowSolution;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Self.OnActivate := nil;
  StringGrid1.ClientWidth := 9 * StringGrid1.DefaultColWidth;
  StringGrid1.ClientHeight := 9 * StringGrid1.DefaultRowHeight;
  ClientWidth := 2 * StringGrid1.Left + StringGrid1.Width;
end;

procedure TForm1.StringGrid1PrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var
  NeedsColor: Boolean;
begin
  NeedsColor := False;
  if aCol in [0..2, 6..8] then
  begin
    if aRow in [0..2, 6..8] then
    begin
      NeedsColor := True;
    end;
  end
  else
  begin
    if aRow in [3..5] then
    begin
      NeedsColor := True;
    end;
  end;
  if NeedsColor then
    (Sender as TStringGrid).Canvas.Brush.Color := $00EEEEEE;
end;

procedure TForm1.StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  if (Length(Value) >= 1) and (Value[1] in ['1'..'9']) then begin
    theValues[ACol + 1, ARow + 1] := Value[1];
  end else begin
    theValues[ACol + 1, ARow + 1] := ' ';
  end;
end;

function TForm1.SolveSudoku: Boolean;
var
  aSudoku: TSudoku;
  Col, Row: Integer;
  Steps: Integer;
begin
  for Col := 0 to 8 do begin
    for Row := 0 to 8 do begin
      if Length(StringGrid1.Cells[Col, Row]) >= 1 then
      begin
        theValues[Col + 1, Row + 1] := StringGrid1.Cells[Col, Row][1];
      end
      else
      begin
        theValues[Col + 1, Row + 1] := ' ';
      end;
    end;
  end;
  aSudoku := TSudoku.Create;
  Result := aSudoku.GiveSolution(theValues, Steps);
  aSudoku.Free;
  if Result then
    ShowMessage(Format('Sudoku solved in %d steps.', [Steps]))
  else
    ShowMessage(Format('Unable to completely solve sudoku (tried %d steps).',[Steps]));
end;

procedure TForm1.ShowSolution;
var
  Col, Row: Integer;
  Ch: Char;
begin
  for Col := 0 to 8 do
  begin
    for Row := 0 to 8 do
    begin
      Ch := theValues[Col + 1, Row + 1];
      if Ch = '0' then
        Ch := #32;
      StringGrid1.Cells[Col, Row] := Ch;
    end;
  end;
end;

end.

