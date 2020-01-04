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
    btnClear: TButton;
    btnSolve: TButton;
    btnEdit: TButton;
    SGrid: TStringGrid;
    procedure btnClearClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnSolveClick(Sender: TObject);
    procedure EditorKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure SGridPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      {%H-}aState: TGridDrawState);
    procedure SGridSelectEditor(Sender: TObject; {%H-}aCol, {%H-}aRow: Integer;
      var Editor: TWinControl);
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

procedure TForm1.btnEditClick(Sender: TObject);
begin
  SGrid.Options := SGrid.Options + [goEditing];
  SGrid.SetFocus;
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  SGrid.Clean;
end;

procedure TForm1.btnSolveClick(Sender: TObject);
begin
  SGrid.Options := SGrid.Options - [goEditing];
  SolveSudoku;
  ShowSolution;
end;

procedure TForm1.EditorKeyPress(Sender: TObject; var Key: char);
var
  Ed: TStringCellEditor;
begin
  if (Sender is TStringCellEditor) then
  begin
    Ed := TStringCellEditor(Sender);
    Ed.SelectAll; //Key will now overwrite selection, in effect allowing to enter only 1 key
    if not (Key in [#8, '1'..'9']) then Key := #0;
  end;
end;


procedure TForm1.FormActivate(Sender: TObject);
begin
  Self.OnActivate := nil;
  SGrid.ClientWidth := 9 * SGrid.DefaultColWidth;
  SGrid.ClientHeight := 9 * SGrid.DefaultRowHeight;
  ClientWidth := 2 * SGrid.Left + SGrid.Width;
end;


procedure TForm1.SGridPrepareCanvas(sender: TObject; aCol, aRow: Integer;
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

procedure TForm1.SGridSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
var
  Ed: TStringCellEditor;
begin
  if Editor is TStringCellEditor then
  begin
    Ed := TStringCellEditor(Editor);
    Ed.OnKeyPress := @EditorKeyPress;
  end;
end;


function TForm1.SolveSudoku: Boolean;
var
  aSudoku: TSudoku;
  Col, Row: Integer;
  Steps, AValue: Integer;
begin
  theValues := Default(TValues); //initialize all to zero
  for Col := 0 to 8 do begin
    for Row := 0 to 8 do begin
      if Length(SGrid.Cells[Col, Row]) >= 1 then
      begin
        if TryStrToInt(SGrid.Cells[Col, Row][1], AValue) then
          theValues[Col + 1, Row + 1] := AValue;
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
      Ch := IntToStr(theValues[Col + 1, Row + 1])[1];
      if Ch = '0' then
        Ch := #32;
      SGrid.Cells[Col, Row] := Ch;
    end;
  end;
end;

end.

