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
  Buttons, StdCtrls, SudokuType, ScratchPad;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnClear: TButton;
    btnLoad: TButton;
    btnSave: TButton;
    btnSolve: TButton;
    btnEdit: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    SGrid: TStringGrid;
    procedure btnClearClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnSolveClick(Sender: TObject);
    procedure EditorKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SGridPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      {%H-}aState: TGridDrawState);
    procedure SGridSelectEditor(Sender: TObject; {%H-}aCol, {%H-}aRow: Integer;
      var Editor: TWinControl);
  private
    { private declarations }
    //theValues: TValues;
    procedure OnCopyBackValues(Sender: TObject; Values: TValues);
    function SolveSudoku(out Values: TValues; out RawData: TRawGrid; out Steps: Integer): Boolean;
    procedure GridToValues(out Values: TValues);
    procedure ValuesToGrid(const Values: TValues);
    procedure ShowScratchPad(RawData: TRawGrid);
    procedure LoadSudokuFromFile(const Fn: String);
    procedure SaveSudokuToFile(const Fn: String);
    function IsValidSudokuFile(Lines: TStrings): Boolean;
    procedure LinesToGrid(Lines: TStrings);
    procedure GridToLines(Lines: TStrings);
  public
    { public declarations }
  end;

  ESudokuFile = Class(Exception);

var
  Form1: TForm1; 

implementation

{$R *.lfm }

const
  FileEmptyChar   = '-';
  VisualEmptyChar = #32;
  AllFilesMask = {$ifdef windows}'*.*'{$else}'*'{$endif};  //Window users are used to see '*.*', so I redefined this constant
  SudokuFileFilter = 'Sudoku files|*.sudoku|All files|' + AllFilesMask;

{ TForm1 }

procedure TForm1.btnEditClick(Sender: TObject);
begin
  SGrid.Options := SGrid.Options + [goEditing];
  SGrid.SetFocus;
end;

procedure TForm1.btnLoadClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  try
    LoadSudokuFromFile(OpenDialog.Filename);
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  try
    SaveSudokuToFile(SaveDialog.Filename);
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  SGrid.Clean;
end;

procedure TForm1.btnSolveClick(Sender: TObject);
var
  Res: Boolean;
  RawData: TRawGrid;
  Values: TValues;
  Steps: Integer;
begin
  SGrid.Options := SGrid.Options - [goEditing];
  Res := SolveSudoku(Values, RawData, Steps);
  ValuesToGrid(Values);
  if Res then
    ShowMessage(Format('Sudoku solved in %d steps.', [Steps]))
  else
  begin
    ShowMessage(Format('Unable to completely solve sudoku (tried %d steps).',[Steps]));
    ShowScratchPad(RawData);
  end;
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  OpenDialog.Filter := SudokuFileFilter;
  SaveDialog.Filter := SudokuFileFilter;
end;


procedure TForm1.SGridPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var
  NeedsColor: Boolean;
  GridTextStyle: TTextStyle;
begin
  GridTextStyle := (Sender as TStringGrid).Canvas.TextStyle;
  GridTextStyle.Alignment := taCenter;
  GridTextStyle.Layout := tlCenter;
  (Sender as TStringGrid).Canvas.TextStyle := GridTextStyle;
  NeedsColor := False;
  if aCol in [0..2, 6..8] then
  begin
    if aRow in [0..2, 6..8] then
      NeedsColor := True;
  end
  else
  begin
    if aRow in [3..5] then
      NeedsColor := True;
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


function TForm1.SolveSudoku(out Values: TValues; out RawData: TRawGrid; out Steps: Integer): Boolean;
var
  aSudoku: TSudoku;
begin
  GridToValues(Values);
  RawData := Default(TRawGrid);
  aSudoku := TSudoku.Create;
  Result := aSudoku.GiveSolution(Values, RawData, Steps);
  aSudoku.Free;
end;

procedure TForm1.GridToValues(out Values: TValues);
var
  Col, Row: Integer;
  S: String;
  AValue: Longint;
begin
  Values := Default(TValues); //initialize all to zero
  for Col := 0 to 8 do
  begin
    for Row := 0 to 8 do
    begin
      S := Trim(SGrid.Cells[Col, Row]);
      if Length(S) = 1 then
      begin
        if TryStrToInt(S, AValue) then
          Values[Col + 1, Row + 1] := AValue;
      end;
    end;
  end;
end;

procedure TForm1.OnCopyBackValues(Sender: TObject; Values: TValues);
begin
  ValuesToGrid(Values);
end;


procedure TForm1.ValuesToGrid(const Values: TValues);
var
  Col, Row: Integer;
  Ch: Char;
begin
  for Col := 0 to 8 do
  begin
    for Row := 0 to 8 do
    begin
      Ch := IntToStr(Values[Col + 1, Row + 1])[1];
      if Ch = '0' then
        Ch := VisualEmptyChar;
      SGrid.Cells[Col, Row] := Ch;
    end;
  end;
end;

procedure TForm1.ShowScratchPad(RawData: TRawGrid);
begin
  ScratchForm.OnCopyValues := @OnCopyBackValues;
  ScratchForm.RawData := RawData;
  ScratchForm.ScratchGrid.Options := SGrid.Options + [goEditing];
  ScratchForm.ScratchGrid.OnPrepareCanvas := @Self.SGridPrepareCanvas;
  ScratchForm.Show;
end;

procedure TForm1.LoadSudokuFromFile(const Fn: String);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(Fn);
    SL.Text := AdjustLineBreaks(SL.Text);
    if not IsValidSudokuFile(SL) then
      Raise ESudokuFile.Create(Format('File does not seem to be a valid Sudoku file:'^m'"%s"',[Fn]));
    LinesToGrid(SL);
  finally
    SL.Free
  end;
end;

procedure TForm1.SaveSudokuToFile(const Fn: String);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.SkipLastLineBreak := True;
    GridToLines(SL);
    {$if fpc_fullversion >= 30200}
    SL.WriteBom := False;
    {$endif}
    SL.SaveToFile(Fn);
  finally
    SL.Free;
  end;
end;

{
A valid SudokuFile consists of 9 lines, each line consists of 9 characters.
Only the characters '1'to '9' and spaces and FileEmptyChar ('-') are allowed.
Empty lines and lines starting with '#' (comments) are discarded
Future implementations may allow for adding a comment when saving the file
}
function TForm1.IsValidSudokuFile(Lines: TStrings): Boolean;
var
  i: Integer;
  S: String;
  Ch: Char;
begin
  Result := False;
  for i := Lines.Count - 1 downto 0 do
  begin
    S := Lines[i];
    if (S = '') or (S[1] = '#') then Lines.Delete(i);
  end;
  if (Lines.Count <> 9) then Exit;
  for i := 0 to Lines.Count - 1 do
  begin
    S := Lines[i];
    if (Length(S) <> 9) then Exit;
    for Ch in S do
    begin
      if not (Ch in [FileEmptyChar, '1'..'9',VisualEmptyChar]) then Exit;
    end;
  end;
  Result := True;
end;

{
Since this should only be called if IsValidSudokuFile retruns True,
We know that all lines consist of 9 chactres exactly and that there are exactly 9 lines in Lines
}
procedure TForm1.LinesToGrid(Lines: TStrings);
var
  Row, Col: Integer;
  S: String;
  Ch: Char;
begin
  for Row := 0 to Lines.Count - 1 do
  begin
    S := Lines[Row];
    for Col := 0 to Length(S) - 1 do
    begin
      Ch := S[Col+1];
      if (Ch = FileEmptyChar) then
        Ch := VisualEmptyChar;
      SGrid.Cells[Col, Row] := Ch;
    end;
  end;
end;

procedure TForm1.GridToLines(Lines: TStrings);
var
  ALine, S: String;
  Ch: Char;
  Row, Col: Integer;
begin
  Lines.Clear;
  for Row := 0 to SGrid.RowCount - 1 do
  begin
    ALine := StringOfChar(FileEmptyChar,9);
    for Col := 0 to SGrid.ColCount - 1 do
    begin
      S := SGrid.Cells[Col, Row];
      if (Length(S) >= 1) then
      begin
        Ch := S[1];
        if (Ch = VisualEmptyChar) then
          Ch := FileEmptyChar;
        ALine[Col+1] := Ch;
      end;
    end;
    Lines.Add(ALine);
  end;
end;

end.

