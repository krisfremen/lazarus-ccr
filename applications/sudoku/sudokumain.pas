unit sudokumain;

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
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Grids,
  Buttons, StdCtrls, sudokutype;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonSolve: TButton;
    ButtonFill: TButton;
    Label1: TLabel;
    StringGrid1: TStringGrid;
    procedure ButtonFillClick(Sender: TObject);
    procedure ButtonSolveClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
  private
    { private declarations }
    theValues: TValues;
    procedure SolveSudoku;
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

// Voor delphi is de volgende regel noodzakelijk. Spatie tussen { en $ verwijderen
{ $R *.dfm }

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
var
  c, r: Integer;
begin
  StringGrid1.Options := StringGrid1.Options - [goEditing];
  SolveSudoku;
  StringGrid1.Clean;
  for c := 1 to 9 do begin
    for r := 1 to 9 do begin
      StringGrid1.Cells[c - 1, r - 1] := theValues[c, r];
      if StringGrid1.Cells[c - 1, r - 1] = '0' then
        StringGrid1.Cells[c - 1, r - 1] := ' ';
    end;
  end;
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  Kleur: Boolean;
begin
  Kleur := False;
  if Col in [0..2, 6..8] then begin
    if Row in [0..2, 6..8] then begin
      Kleur := True;
    end;
  end else begin
    if Row in [3..5] then begin
      Kleur := True;
    end;
  end;
  if Kleur then begin
    inc(aRect.Top, 1);
    inc(aRect.Left, 1);
    dec(aRect.Bottom, 1);
    dec(aRect.Right, 1);
    StringGrid1.Canvas.Brush.Color := clLtGray;
    StringGrid1.Canvas.FillRect(aRect);
// Volgende regel is alleen in Delphi noodzakelijk.
//    StringGrid1.Canvas.TextOut(aRect.Left, aRect.Top, StringGrid1.Cells[Col, Row]);
  end;
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

procedure TForm1.SolveSudoku;
var
  aSudoku: TSudoku;
  c, r: Integer;
  Stappen: Integer;
begin
  for c := 0 to 8 do begin
    for r := 0 to 8 do begin
      if Length(StringGrid1.Cells[c, r]) >= 1 then begin
        theValues[c + 1, r + 1] := StringGrid1.Cells[c, r][1];
      end else begin
        theValues[c + 1, r + 1] := ' ';
      end;
    end;
  end;
  aSudoku := TSudoku.Create;
  Stappen := aSudoku.GiveSolution(theValues);
  aSudoku.Free;
  ShowMessage('Sudoku solved in ' + IntToStr(Stappen) + ' steps.');
end;

initialization
// Voor lazarus is deze regel nodig.
  {$I sudokumain.lrs}
end.

