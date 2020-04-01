unit DataProcs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Clipbrd,
  Globals, OptionsUnit, DictionaryUnit, OutputUnit;

Function GoodRecord(Row, NoVars : integer; VAR GridPos : IntDyneVec): boolean;
procedure FormatCell(Col, Row : integer);
procedure FormatGrid;
function IsNumeric(s : string) : boolean;
procedure VecPrint(vector : IntDyneVec; Size : integer; Heading : string);
procedure SaveOS2File;
procedure OpenOS2File;
procedure OpenOS2File(const AFileName: String; ShowDictionaryForm: Boolean);
procedure DeleteCol;
procedure CopyColumn;
procedure PasteColumn;
procedure InsertCol;
procedure InsertRow;
procedure CutaRow;
procedure CopyaRow;
procedure PasteaRow;
procedure PrintDict;
procedure PrintData;
procedure OpenTabFile;
procedure SaveTabFile;
function ValidValue(row, col : integer) : boolean;
function IsFiltered(GridRow : integer) : boolean;
procedure MatRead(var a: DblDyneMat; out NoRows, NoCols: integer;
  var Means, StdDevs: DblDyneVec; out NCases: integer;
  var RowLabels, ColLabels: StrDyneVec; const filename: string);
procedure MATSAVE(VAR a : DblDyneMat;
                  norows : integer;
                  nocols : integer;
                  VAR means : DblDyneVec;
                  VAR stddevs : DblDyneVec;
                  NCases : integer;
                  VAR RowLabels : StrDyneVec;
                  VAR ColLabels : StrDyneVec;
                  filename : string);
procedure ReOpen(filename : string);
procedure OpenCommaFile;
procedure SaveCommaFile;
procedure OpenSpaceFile;
procedure SaveSpaceFile;
procedure OpenOSData;
procedure ClearGrid;
procedure CopyIt;
procedure PasteIt;
procedure RowColSwap;
procedure MatToGrid(VAR mat : DblDyneMat; nsize : integer);
procedure GetTypes;
function StringsToInt(strcol : integer; VAR newcol : integer; prompt : boolean) : boolean;


implementation

uses MainUnit;

Function GoodRecord(Row, NoVars : integer; VAR GridPos : IntDyneVec): boolean;
var
   i, j : integer;
   isgood : boolean;

begin
     isgood := true;
     for i := 1 to NoVars do
     begin
          j := GridPos[i-1];
          if NOT ValidValue(Row,j) then isgood := false;
     end;
     Result := isgood;
end;
//-------------------------------------------------------------------

procedure FormatCell(Col, Row : integer);
var
  VarType : char;
  NoDec : integer;
  Justify : char;
  missing : string;
  astr : string;
  cellstr : string;
  newcell : string;
  X : double;
  Width : integer;
  cellsize : integer;
  I: Integer;

begin
  if OS3MainFrm.DataGrid.Cells[Col,Row] = '' then
    exit;

  Width := StrToInt(DictionaryFrm.DictGrid.Cells[3,Col]);

  astr := DictionaryFrm.DictGrid.Cells[4,Col];
  if astr <> '' then VarType := astr[1] else VarType := 'F';

  NoDec := StrToInt(DictionaryFrm.DictGrid.Cells[5,Col]);

  astr := DictionaryFrm.DictGrid.Cells[7,Col];
  if astr <> '' then Justify := astr[1] else Justify := 'L';

  missing := DictionaryFrm.DictGrid.Cells[6,Col];
  cellstr := Trim(OS3MainFrm.DataGrid.Cells[Col,Row]);
  if missing = cellstr then
    exit;

  if (VarType = 'F') and TryStrToFloat(cellStr, X) then
    newcell := FloatToStrF(X, ffFixed, Width, NoDec)
  else
  if (VarType = 'I') and TryStrToInt(cellStr, I) then
    newCell := IntToStr(I)
   (*
   if (VarTyp
   if ((VarType = 'F') or (VarType = 'I')) then
   begin
     if TryStrToFloat(cellstr, X) then
       newcell := FloatToStrF(X, ffFixed, Width, NoDec);
     {
          if IsNumeric(cellstr) then
          begin
               X := StrToFloat(cellstr);
               newcell := FloatToStrF(X,ffFixed,Width,NoDec);
//               Str(X:Width:NoDec,newcell);
          end;

   }
     end
   *)
  else
    newcell := cellstr;

  // now set justification
  cellsize := OS3MainFrm.DataGrid.ColWidths[Col]; // in pixels
  cellsize := cellsize div 8;
  case Justify of
    'L' : newcell := TrimLeft(newcell);
    'C' : begin
            newcell := Trim(newcell);
            while Length(newcell) < cellsize do
              newcell := ' ' + newcell + ' ';
          end;
    'R' : begin
            newcell := Trim(newcell);
            while Length(newcell) < cellsize do  newcell := ' ' + newcell;
          end;
  end;
  OS3MainFrm.DataGrid.Cells[Col,Row] := newcell;
end;
//-------------------------------------------------------------------

procedure FormatGrid;
var
   i, j : integer;

begin
     for i := 1 to NoCases do
          for j := 1 to NoVariables do FormatCell(j,i);
end;
//-------------------------------------------------------------------

function IsNumeric(s : string) : boolean;
var
  i, strlong: integer;
  isnumber: boolean;
begin
     (*
  Assert(OptionsFrm <> nil);

  if OptionsFrm.FractionTypeGrp.ItemIndex = 0 then
  begin
     FractionType := 0;
     DecimalSeparator := '.'
  end
  else begin
     FractionType := 1;
     DecimalSeparator := ',';
  end;
  *)

  isnumber := true;
  strlong := length(s);
  for i := 1 to strlong do
  //     if (not(((s[i] >= '0') and (s[i] <= '9')) or (s[i] = DecimalSeparator) or
  //        (s[i] = '-'))) then isnumber := false;
    if (ord(s[i]) < 44) or (ord(s[i]) > 57 ) or (ord(s[i]) = 47) then
      isnumber := false;
  result := isnumber;
end;
//-----------------------------------------------------------------------------

procedure VecPrint(vector : IntDyneVec; Size : integer; Heading : string);
var
   i, start, last : integer;
   nvals : integer;
   done : boolean;
   astr : string;

begin
     nvals := 8;
     done := false;
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add(Heading);
     OutPutFrm.RichEdit.Lines.Add('');
     start := 1;
     last := nvals;
     if last > Size then last := Size;
     while not done do
     begin
          astr := '';
          for i := start to last do
               astr := astr + format('%8d ',[i]);
          OutPutFrm.RichEdit.Lines.Add(astr);
          astr := '';
          for i := start to last do
               astr := astr + format('%8d ',[vector[i-1]]);
          OutPutFrm.RichEdit.Lines.Add(astr);
          if last < Size then
          begin
               OutPutFrm.RichEdit.Lines.Add('');
               start := last + 1;
               last := start + nvals - 1;
               if last > Size then last := Size;
          end
          else done := true;
     end;
end;
//-------------------------------------------------------------------
procedure SaveOS2File;
var
   F: TextFile;
   filename: string;
   s: string;
   NRows, NCols: integer;
   i, j: integer;
begin
  // check for valid cases - at least one value entered
  NRows := StrToInt(OS3MainFrm.NoCasesEdit.Text);
  NCols := StrToInt(OS3MainFrm.NoVarsEdit.Text);
  if (NRows = 0) or (NCols = 0) then
  begin
    MessageDlg('No data to save.', mtError, [mbOK], 0);
    exit;
  end;

  filename := ChangeFileExt(OS3MainFrm.FileNameEdit.Text, '.laz');
  OS3MainFrm.SaveDialog1.InitialDir := ExtractFileDir(filename);
  OS3MainFrm.SaveDialog1.FileName := ExtractFileName(filename);
  OS3MainFrm.SaveDialog1.DefaultExt := '.laz';
//  OS3MainFrm.SaveDialog1.Filter := 'LazStats (*.laz)|*.laz;*.LAZ|Tab (*.tab)|*.tab;*.TAB|space (*.spc)|*.spc;*.SPC';
  OS3MainFrm.SaveDialog1.Filter := 'LazStats (*.laz)|*.laz;*.LAZ|All files (*.*)|*.*';
  OS3MainFrm.SaveDialog1.FilterIndex := 1;
  if OS3MainFrm.SaveDialog1.Execute then
  begin
    filename := ExpandFileName(OS3MainFrm.SaveDialog1.FileName);
    OS3MainFrm.FileNameEdit.Text := filename;
    AssignFile(F, filename);
    Rewrite(F);

    Writeln(F, NRows);
    Writeln(F, NCols);

    // write dictionary information for file first
    for i := 1 to NCols do
    begin
      for j := 1 to 7 do
      begin
        s := DictionaryFrm.DictGrid.Cells[j, i];
        Writeln(F, s);
      end;
    end;
{          MemLines := DictionaryFrm.DescMemo.Lines.Count;
          Writeln(F,MemLines);
          for i := 0 to MemLines - 1 do
              Writeln(F,DictionaryFrm.DescMemo.Lines[i]); }

    // now save grid cell values, incl col and row headers.
    for i := 0 to NRows do
    begin
      for j := 0 to NCols do
      begin
        s := OS3MainFrm.DataGrid.Cells[j, i];
        Writeln(F, s);
      end;
    end;
    CloseFile(F);
  end;
end;
//-------------------------------------------------------------------

procedure OpenOS2File;
begin
  OS3MainFrm.OpenDialog1.DefaultExt := '.laz';
  OS3MainFrm.OpenDialog1.Filter := 'LazStats (*.laz)|*.laz;*.LAZ|All files (*.*)|*.*';
  OS3MainFrm.OpenDialog1.FilterIndex := 1;
  if OS3MainFrm.OpenDialog1.Execute then
    OpenOS2File(OS3MainFrm.OpenDialog1.FileName, true);
end;

procedure OpenOS2File(const AFileName: String; ShowDictionaryForm: Boolean);
var
  F: TextFile;
  s: string;
  i, j: integer;
  NRows, NCols: integer;
begin
  DictLoaded := false;

  OS3MainFrm.FileNameEdit.Text := ExpandFileName(AFileName);
  if not FileExists(OS3MainFrm.FileNameEdit.Text) then begin
    MessageDlg(Format('File "%s" not found.', [AFileName]), mtError, [mbOK], 0);
    exit;
  end;

  AssignFile(F, AFileName);
  Reset(F);
  ReadLn(F, NRows);
  ReadLn(F, NCols);

  // initialize the dictionary grid for NCols of variables
  // using the default formats (protective measure in case of
  // a screw-up where the dictionary was damaged
  DictionaryFrm.DictGrid.ColCount := 8;
  DictionaryFrm.DictGrid.RowCount := NCols + 1;
  for i := 1 to NCols do
  begin
    DictionaryFrm.DictGrid.Cells[0, i] := IntToStr(i);
    DictionaryFrm.DictGrid.Cells[1, i] := 'VAR.' + IntToStr(i);
    DictionaryFrm.DictGrid.Cells[2, i] := 'VARIABLE ' + IntToStr(i);
    DictionaryFrm.DictGrid.Cells[3, i] := '8';
    DictionaryFrm.DictGrid.Cells[4, i] := 'F';
    DictionaryFrm.DictGrid.Cells[5, i] := '2';
    DictionaryFrm.DictGrid.Cells[6, i] := ' ';
    DictionaryFrm.DictGrid.Cells[7, i] := 'L';
  end;

  // get dictionary info first
  for i := 1 to NCols do
  begin
    for j := 1 to 7 do
    begin
      Readln(F, s);
      DictionaryFrm.DictGrid.Cells[j,i] := s;
    end;
    VarDefined[i] := true;
  end;
  DictLoaded := true;

{          Readln(F, s);
          MemLines := StrToInt(s);
          DictionaryFrm.DescMemo.Clear;
          for i := 0 to MemLines - 1 do
          begin
               readln(F, s);
               DictionaryFrm.DescMemo.Lines.Add(s);
          end;   }

  // Now read grid data
  OS3MainFrm.DataGrid.RowCount := NRows + 1;
  OS3MainFrm.DataGrid.ColCount := NCols + 1;
  OS3MainFrm.NoCasesEdit.Text := IntToStr(NRows);
  OS3MainFrm.NoVarsEdit.Text := IntToStr(NCols);
  NoVariables := NCols;
  NoCases := NRows;
  for i := 0 to NRows do
  begin
    for j := 0 to NCols do
    begin
      ReadLn(F, s);
      OS3MainFrm.DataGrid.Cells[j,i] := s;
    end;
  end;
  CloseFile(F);

  // copy column names into the data dictionary.  Note, this is
  // redundant with the saved dictionary but helps restore in case
  // of a screw-up
  for i := 1 to NCols do
    DictionaryFrm.DictGrid.Cells[1,i] := OS3MainFrm.DataGrid.Cells[i,0];
  for i := 1 to NRows do
    OS3MainFrm.DataGrid.Cells[0,i] := 'CASE ' + IntToStr(i);
  if ShowDictionaryForm then
    DictionaryFrm.ShowModal;
  FormatGrid;
end;
//-------------------------------------------------------------------

procedure DeleteCol;
var
   i, j, col: integer;
   buf : pchar;
begin
     col := OS3MainFrm.DataGrid.Col;
     NoVariables := StrToInt(OS3MainFrm.NoVarsEdit.Text);
//     TempStream.Clear;
//     OS3MainFrm.DataGrid.Cols[col].SaveToStream(TempStream);
     buf := OS3MainFrm.DataGrid.Cols[col].GetText;
     ClipBoard.SetTextBuf(buf);
     if col = NoVariables then // last column
     begin
          for j := 0 to NoCases do OS3MainFrm.DataGrid.Cells[col,j] := '';
          VarDefined[col] := false;
     end
     else // must be a variable in front of another variable
     begin
          for i := col + 1 to NoVariables do //Grid.ColCount - 1 do
               for j := 0 to NoCases do //Grid.RowCount - 1 do
                    OS3MainFrm.DataGrid.Cells[i-1,j] := OS3MainFrm.DataGrid.Cells[i,j];
          for j := 0 to OS3MainFrm.DataGrid.RowCount - 1 do
               OS3MainFrm.DataGrid.Cells[NoVariables,j] := '';
     end;
     varDefined[NoVariables] := false;
     OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount - 1;
     NoVariables := NoVariables - 1;
     OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
     // update dictionary
     DictionaryFrm.DelRow(col);
end;
//-------------------------------------------------------------------

procedure CopyColumn;
var
   col: integer;
   buf : pchar;
begin
     col := OS3MainFrm.DataGrid.Col;
     buf := OS3MainFrm.DataGrid.Cols[col].GetText;
     ClipBoard.SetTextBuf(buf);
//   The following code can be used instead of the above if no clipboard available
//     TempStream.Clear;
//     OS3MainFrm.DataGrid.Cols[col].SaveToStream(TempStream);
//     DictionaryFrm.CopyVar(col);
end;
//-------------------------------------------------------------------

procedure InsertCol;
var
   i, j, col: integer;
begin
     // insert a new, blank column into the data grid
     col := OS3MainFrm.DataGrid.Col;
//     DictionaryFrm.NewVar(col);
     NoVariables := NoVariables + 1;
     OS3MainFrm.DataGrid.ColCount := NoVariables + 1;
     for i := NoVariables downto col do { move to right }
     begin
          for j := 0 to NoCases do
          begin
               OS3MainFrm.DataGrid.Cells[i,j] := OS3MainFrm.DataGrid.Cells[i-1,j];
          end;
     end;
     NoVariables := NoVariables - 1;
     DictionaryFrm.NewVar(col);
     for i := 1 to NoCases do OS3MainFrm.DataGrid.Cells[col,i] := '';
     OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
end;
//-------------------------------------------------------------------

procedure PasteColumn;
var
   col, i, j : integer;
   buf : pchar;
   size : integer;
   strarray : array[0..100000] of char;

begin
     col := OS3MainFrm.DataGrid.Col;
     NoVariables := OS3MainFrm.DataGrid.ColCount-1;
     NoCases := OS3MainFrm.DataGrid.RowCount - 1;
     if col <= NoVariables then
     begin // add a blank column, move current over and update dictionary
           OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;
           for i := NoVariables downto col do
               for j := 0 to NoCases do
                   OS3MainFrm.DataGrid.Cells[i+1,j] := OS3MainFrm.DataGrid.Cells[i,j];
           DictionaryFrm.NewVar(col);
           VarDefined[col] := true;
           OS3MainFrm.ColEdit.Text := IntToStr(OS3MainFrm.DataGrid.ColCount-1);
//           NoVariables := NoVariables + 1;
           OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
     end;
     buf := strarray;
     size := 100000;
     ClipBoard.GetTextBuf(buf,size);
     OS3MainFrm.DataGrid.Cols[col].SetText(buf);
end;
//-------------------------------------------------------------------

procedure CutaRow;
var
   row, i, j : integer;
   buf : pchar;

begin
   row := OS3MainFrm.DataGrid.Row;
   buf := OS3MainFrm.DataGrid.Rows[row].GetText;
   ClipBoard.SetTextBuf(buf);
//   TempStream.Clear;
//   OS3MainFrm.DataGrid.Rows[row].SaveToStream(TempStream);
   for i := 1 to NoVariables do OS3MainFrm.DataGrid.Cells[i,row] := '';
   if row < NoCases then
   begin // move rows below up 1
         for i := row + 1 to NoCases do
             for j := 1 to NoVariables do OS3MainFrm.DataGrid.Cells[j,i-1] := OS3MainFrm.DataGrid.Cells[j,i];
         for j := 1 to NoVariables do OS3MainFrm.DataGrid.Cells[j,NoCases] := '';
   end;
   OS3MainFrm.DataGrid.RowCount := OS3MainFrm.DataGrid.RowCount - 1;
   OS3MainFrm.RowEdit.Text := IntToStr(OS3MainFrm.DataGrid.RowCount-1);
   NoCases := NoCases - 1;
   OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
   // renumber cases
   for i := 1 to NoCases do OS3MainFrm.DataGrid.Cells[0,i] := 'CASE ' + IntToStr(i);
end;
//-------------------------------------------------------------------

procedure CopyaRow;
var
   row : integer;
   buf : pchar;

begin
     row := OS3MainFrm.DataGrid.Row;
     buf := OS3MainFrm.DataGrid.Rows[row].GetText;
     ClipBoard.SetTextBuf(buf);
//     TempStream.Clear;
//     OS3MainFrm.DataGrid.Rows[row].SaveToStream(TempStream);
end;
//-------------------------------------------------------------------

procedure PasteaRow;
var
   row, i, j : integer;
   buf : pchar;
   strarray : array[0..100000] of char;
   size : integer;

begin
     row := OS3MainFrm.DataGrid.Row;
     OS3MainFrm.DataGrid.RowCount := OS3MainFrm.DataGrid.RowCount + 1;
     OS3MainFrm.RowEdit.Text := IntToStr(OS3MainFrm.DataGrid.RowCount-1);
     if row <= NoCases then // move all down before inserting
     begin
          for i := NoCases downto row do
               for j := 1 to NoVariables do
                   OS3MainFrm.DataGrid.Cells[j,i+1] := OS3MainFrm.DataGrid.Cells[j,i];
     end;
     OS3MainFrm.DataGrid.Row := row;
     buf := strarray;
     size := 100000;
     ClipBoard.GetTextBuf(buf,size);
     OS3MainFrm.DataGrid.Rows[row].SetText(buf);
//   Use the following instead of the previous 4 if clipboard is unavailable
//     TempStream.Position := 0;
//     OS3MainFrm.DataGrid.Rows[row].LoadFromStream(TempStream);
     NoCases := NoCases + 1;
     OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
     // renumber cases
     for i := 1 to NoCases do OS3MainFrm.DataGrid.Cells[0,i] := 'CASE ' + IntToStr(i);

end;
//-------------------------------------------------------------------

procedure PrintDict;
var
   outline: string;
   i : integer;

begin
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Alignment := taLeftJustify;
     outline := OS3MainFrm.FileNameEdit.Text + ' VARIABLE DICTIONARY';
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');
     for i:= 0 to NoVariables do
     begin
          outline := '';
          outline := outline + '| ' + format('%9s',[DictionaryFrm.DictGrid.Cells[0,i]]);
          outline := outline + ' | ' + format('%10s',[DictionaryFrm.DictGrid.Cells[1,i]]);
          outline := outline + ' | ' + format('%15s',[DictionaryFrm.DictGrid.Cells[2,i]]);
          outline := outline + ' | ' + format('%6s',[DictionaryFrm.DictGrid.Cells[3,i]]);
          outline := outline + ' | ' + format('%6s',[DictionaryFrm.DictGrid.Cells[4,i]]);
          outline := outline + ' | ' + format('%8s',[DictionaryFrm.DictGrid.Cells[5,i]]);
          outline := outline + ' | ' + format('%7s',[DictionaryFrm.DictGrid.Cells[6,i]]);
          outline := outline + ' | ' + format('%6s',[DictionaryFrm.DictGrid.Cells[7,i]]);
          OutPutFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.ShowModal;
end;
//-------------------------------------------------------------------

procedure PrintData;
var
   outline: string;
   startcol: integer;
   endcol: integer;
   done: boolean;
   cellstring: string;
   i, j: integer;

begin
     OutPutFrm.RichEdit.Clear;
     OutPutFrm.RichEdit.Alignment := taLeftJustify;
     outline := OS3MainFrm.FileNameEdit.Text;
     OutPutFrm.RichEdit.Lines.Add(outline);
     outline := IntToStr(NoCases);
     outline := 'No. of Cases = ' + outline;
     outline := outline + ', No. of Variables = ';
     outline := outline + IntToStr(NoVariables);
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('');
     done := false;
     startcol := 1;
     while done = false do
     begin
          endcol := startcol + 7;
          if endcol > NoVariables then endcol := NoVariables;
          for i:= 0 to NoCases do
          begin
               outline := '';
               outline := format('%10s',[Trim(OS3MainFrm.DataGrid.Cells[0,i])]);
               for j := startcol to endcol do
               begin
                    cellstring := format('%10s',[Trim(OS3MainFrm.DataGrid.Cells[j,i])]);
                    outline := outline + cellstring;
               end;
               OutPutFrm.RichEdit.Lines.Add(outline);
          end;
          if endcol = NoVariables then done := true else
          begin
               startcol := endcol+1;
               OutPutFrm.RichEdit.Lines.Add('');
          end;
     end;
     OutPutFrm.ShowModal;
end;
//-------------------------------------------------------------------

procedure OpenTabFile;
var
  TabFile : TextFile;
  namestr : string;
  s: string;
  ch: char;
  labelsinc : boolean;
  row, col : integer;
  res: TModalResult;
begin
  Assert(OS3MainFrm <> nil);
  Assert(OptionsFrm <> nil);

  labelsinc := false;

  // check for a currently open file
  if NoVariables > 1 then
  begin
    MessageDlg('Close (or Save and Close) the current work.', mtWarning, [mbOK], 0);
    exit;
  end;

  OS3MainFrm.OpenDialog1.Filter := 'Tab field files (*.tab)|*.tab;*.TAB|Text files (*.txt)|*.txt;*.TXT|All files (*.*)|*.*';
  OS3MainFrm.OpenDialog1.FilterIndex := 1;
  OS3MainFrm.OpenDialog1.DefaultExt := 'tab';
  if OS3MainFrm.OpenDialog1.Execute then
  begin
    res := MessageDlg('Are variable labels included?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if res = mrCancel then
      exit;
    labelsInc := (res = mrYes);
    NoCases := 0;
    NoVariables := 0;
    if labelsinc = true then row := 0 else row := 1;
    col := 1;
    AssignFile(TabFile, OS3MainFrm.OpenDialog1.FileName);   { File selected in dialog box }
    Reset(tabfile);
    OS3MainFrm.FileNameEdit.Text := OS3MainFrm.OpenDialog1.FileName;
    s := '';
    while not EOF(TabFile) do
    begin
      Read(TabFile, ch);
      if (ch < #9) or (ch > #127) then
        Continue;
      if (ch = #13) then
        Continue; // line feed character
      if (ch <> #9) and (ch <> #10) then // check for tab or new line
        s := s + ch
      else if ch = #9 then // tab character found
      begin
        if (not labelsinc) and (row = 1) then // create a col. label
        begin
          namestr := 'VAR ' + IntToStr(col);
          OS3MainFrm.DataGrid.Cells[col,0] := namestr;
        end;
        OS3MainFrm.DataGrid.Cells[col,row] := s;
        if col > NoVariables then
        begin
          NoVariables := col;
          OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
        end;
        col := col + 1;
        s := '';
        if col >= OS3MainFrm.DataGrid.ColCount then
          OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;
      end
      else //must be new line character
      begin
        if (not labelsinc) and (row = 1) then // create a col. label
        begin
          namestr := 'VAR ' + IntToStr(col);
          OS3MainFrm.DataGrid.Cells[col,0] := namestr;
        end;
        OS3MainFrm.DataGrid.Cells[col,row] := s;
        s := '';
        if col > NoVariables then
        begin
          NoVariables := col;
          OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
        end;
        col := 1;
        if row > NoCases then NoCases := row;
        OS3MainFrm.DataGrid.Cells[0,row] := 'Case ' + IntToStr(row);
        row := row + 1;
        if row >= OS3MainFrm.DataGrid.RowCount then
          OS3MainFrm.DataGrid.RowCount := OS3MainFrm.DataGrid.RowCount + 1;
      end;
    end;  // END OF FILE
    OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
    CloseFile(TabFile);
    if NoVariables >= OS3MainFrm.DataGrid.ColCount - 1 then
      OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;
    // set up the dictionary
    DictionaryFrm.DictGrid.RowCount := NoVariables + 1;
    DictionaryFrm.DictGrid.ColCount := 8;
    for row := 1 to NoVariables do
    begin
      DictionaryFrm.DictGrid.Cells[0,row] := IntToStr(row);
      DictionaryFrm.DictGrid.Cells[1,row] := 'VAR.' + IntToStr(row);
      DictionaryFrm.DictGrid.Cells[2,row] := 'VARIABLE ' + IntToStr(row);
      DictionaryFrm.DictGrid.Cells[3,row] := '8';
      DictionaryFrm.DictGrid.Cells[4,row] := 'F';
      DictionaryFrm.DictGrid.Cells[5,row] := '2';
      DictionaryFrm.DictGrid.Cells[6,row] := MissingValueCodes[Options.DefaultMiss];
      DictionaryFrm.DictGrid.Cells[7,row] := 'L';
    end;
    for row := 1 to NoVariables do
    begin
      DictionaryFrm.DictGrid.Cells[1,row] := OS3MainFrm.DataGrid.Cells[row,0];
      VarDefined[row] := true;
    end;
    OS3MainFrm.DataGrid.RowCount := (NoCases + 1);
    OS3MainFrm.DataGrid.ColCount := (NoVariables + 1);
  end;
  GetTypes;
end;
//-------------------------------------------------------------------

procedure SaveTabFile;
var
  namestr: string;
  cellvalue: string;
  TabFile: TextFile;
  i, j: integer;
begin
  OS3MainFrm.SaveDialog1.Filter := 'Tab field files (*.tab)|*.tab;*.TAB|Text files (*.txt)|*.txt;*.TXT|All files (*.*)|*.*';
  OS3MainFrm.SaveDialog1.FilterIndex := 1;
  OS3MainFrm.SaveDialog1.DefaultExt := 'tab';
  if OS3MainFrm.SaveDialog1.Execute then
  begin
    namestr := OS3MainFrm.SaveDialog1.FileName;
    Assign(TabFile,namestr);
    ReWrite(TabFile);
    for i := 0 to NoCases do                       // wp: why not NoCases-1 ?
    begin
      for j := 1 to NoVariables do   //write all but last with a tab
      begin
        cellvalue := OS3MainFrm.DataGrid.Cells[j,i];
        if cellvalue = '' then cellvalue := '.';   // wp: why not "missing value"?
        cellvalue := Trim(cellvalue);              // wp: why not before prev line?
        if j < NoVariables then cellvalue := cellvalue + #9;
        write(TabFile,cellvalue);
      end;
      writeln(TabFile);
    end;
  end;
  CloseFile(TabFile);
end;
//-------------------------------------------------------------------

function ValidValue(row, col : integer) : boolean;
var
   valid: boolean;
   xvalue: string;
   cellstring : string;

begin
     valid := true;
     if FilterOn = true then
     begin
          cellstring := Trim(OS3MainFrm.DataGrid.Cells[FilterCol,row]);
          if cellstring = 'NO' then valid := false;
          ValidValue := valid;
          exit;
     end;
     xvalue := Trim(OS3MainFrm.DataGrid.Cells[col,row]);
     if (xvalue = '') and (DictionaryFrm.DictGrid.Cells[4,col] <> 'S')
         then valid := false;
     if valid then  // check for user-defined missing value
     begin
          if Trim(DictionaryFrm.DictGrid.Cells[6,col]) = xvalue then
               valid := false;
     end;
     ValidValue := valid;
end;
//-----------------------------------------------------------------------------

function IsFiltered(GridRow : integer) : boolean;
begin
     if (FilterOn = true) and (Trim(OS3MainFrm.DataGrid.Cells[FilterCol,GridRow]) = 'NO') then
     IsFiltered := true else IsFiltered := false;
end;
//-------------------------------------------------------------------

procedure MATREAD(var a: DblDyneMat;
                  out NoRows, NoCols: integer;
                  var means, stddevs: DblDyneVec;
                  out NCases: integer;
                  var RowLabels, ColLabels: StrDyneVec;
                  const filename: string);
var i, j : integer;
    mat_file : TextFile;
begin
     assign(mat_file,filename);
     reset(mat_file);
     readln(mat_file,norows);
     readln(mat_file,nocols);
     readln(mat_file,NCases);

     // wp: Setlength missing here --> very critical !!!!
     // I understand that the calling routine pre-allocates these arrays
     // But there should be a check whehter Norows, etc do not go beyond array size.

     for i := 1 to norows do readln(mat_file,RowLabels[i-1]);
     for i := 1 to nocols do readln(mat_file,ColLabels[i-1]);
     for i := 1 to nocols do readln(mat_file,means[i-1]);
     for i := 1 to nocols do readln(mat_file,stddevs[i-1]);
     for i := 1 to norows do
         for j := 1 to nocols do
             readln(mat_file,a[i-1,j-1]);
     CloseFile(mat_file);
end; { matrix read routine }
//-------------------------------------------------------------------

procedure MATSAVE(VAR a : DblDyneMat;
                  norows : integer;
                  nocols : integer;
                  VAR means : DblDyneVec;
                  VAR stddevs : DblDyneVec;
                  NCases : integer;
                  VAR RowLabels : StrDyneVec;
                  VAR ColLabels : StrDyneVec;
                  filename : string);
var i, j : integer;
    mat_file : TextFile;
begin
     assign(mat_file,filename);
     rewrite(mat_file);
     writeln(mat_file,norows);
     writeln(mat_file,nocols);
     writeln(mat_file,NCases);
     for i := 1 to norows do writeln(mat_file,RowLabels[i-1]);
     for i := 1 to nocols do writeln(mat_file,ColLabels[i-1]);
     for i := 1 to nocols do writeln(mat_file,means[i-1]);
     for i := 1 to nocols do writeln(mat_file,stddevs[i-1]);
     for i := 1 to norows do
         for j := 1 to nocols do
             writeln(mat_file,a[i-1,j-1]);
     CloseFile(mat_file);
end; { matrix save routine }
//-------------------------------------------------------------------

procedure ReOpen(filename : string);
var
   fileext : string;

begin
     DictLoaded := false;

     if FileExists(filename) then
     begin
          fileext := Uppercase(ExtractFileExt(filename));
          OS3MainFrm.FileNameEdit.Text := filename;
          OS3MainFrm.OpenDialog1.FileName := filename;
          if fileext = '.CSV' then OpenCommaFile
          else if fileext = '.TAB' then OpenTabFile
          else if fileext = '.LAZ' then OpenOS2File
          else if fileext = '.SSV' then OpenSpaceFile;
     end
     else begin
          MessageDlg(filename + ' not found.', mtError, [mbOK], 0);
          exit;
     end;
end;
//-------------------------------------------------------------------

procedure OpenCommaFile;
label getit;
var
   CommaFile : TextFile;
   namestr : string;
   astr : string;
   achar : char;
   respval : string;
   labelsinc : boolean;
   row, col : integer;
   commachar : integer;
begin
    commachar := ord(',');
    labelsinc := false;
    // check for a currently open file
    if NoVariables > 1 then
    begin
       ShowMessage('WARNING! Close (or Save and Close) the current work.');
       exit;
    end;
    respval := InputBox('LABELS?','Are variable labels included?','Y');
    if respval = 'Y' then labelsinc := true;
    OS3MainFrm.OpenDialog1.Filter := 'Comma field files (*.CSV)|*.CSV|Text files (*.txt)|*.TXT|All files (*.*)|*.*';
    OS3MainFrm.OpenDialog1.FilterIndex := 1;
    OS3MainFrm.OpenDialog1.DefaultExt := 'CSV';
    if OS3MainFrm.OpenDialog1.Execute then
    begin
    	NoCases := 0;
        NoVariables := 0;
        if labelsinc = true then row := 0 else row := 1;
        col := 1;
        AssignFile(CommaFile, OS3MainFrm.OpenDialog1.FileName);   { File selected in dialog box }
        Reset(CommaFile);
        OS3MainFrm.FileNameEdit.Text := OS3MainFrm.OpenDialog1.FileName;
        astr := '';
        while not EOF(CommaFile) do
        begin
getit:      read(CommaFile,achar);
            if (ord(achar) < 9) or (ord(achar) > 127) then goto getit;
            if ord(achar) = 13 then goto getit; // line feed character
            if (ord(achar) <> commachar) and (ord(achar) <> 10) then // check for tab or new line
            begin
            	astr := astr + achar;
            end
            else if ord(achar) = commachar then // tab character found
            begin
                if (not labelsinc) and (row = 1) then // create a col. label
                begin
                    namestr := 'VAR ' + IntToStr(col);
                    OS3MainFrm.DataGrid.Cells[col,0] := namestr;
                end;
                OS3MainFrm.DataGrid.Cells[col,row] := astr;
                if col > NoVariables then
                begin
                    NoVariables := col;
                    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
                end;
                col := col + 1;
                astr := '';
                if col >= OS3MainFrm.DataGrid.ColCount then
                    OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;
            end
            else //must be new line character
            begin
                if (not labelsinc) and (row = 1) then // create a col. label
                begin
                    namestr := 'VAR ' + IntToStr(col);
                    OS3MainFrm.DataGrid.Cells[col,0] := namestr;
                end;
            	OS3MainFrm.DataGrid.Cells[col,row] := astr;
                astr := '';
                if col > NoVariables then
                begin
                    NoVariables := col;
                    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
                end;
                col := 1;
                if row > NoCases then NoCases := row;
                OS3MainFrm.DataGrid.Cells[0,row] := 'Case ' + IntToStr(row);
                row := row + 1;
                if row >= OS3MainFrm.DataGrid.RowCount then
                     OS3MainFrm.DataGrid.RowCount := OS3MainFrm.DataGrid.RowCount + 1;
            end;
        end;  // END OF FILE
        OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
        OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
        CloseFile(CommaFile);
        if NoVariables > OS3MainFrm.DataGrid.ColCount - 1 then
           OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;
    end;
    OS3MainFrm.DataGrid.RowCount := (NoCases + 1);
    OS3MainFrm.DataGrid.ColCount := (NoVariables + 1);
    // set up the dictionary
    DictionaryFrm.DictGrid.RowCount := NoVariables + 1;
    DictionaryFrm.DictGrid.ColCount := 8;
    for row := 1 to NoVariables do
    begin
             DictionaryFrm.DictGrid.Cells[0,row] := IntToStr(row);
             DictionaryFrm.DictGrid.Cells[1,row] := 'VAR.' + IntToStr(row);
             DictionaryFrm.DictGrid.Cells[2,row] := 'VARIABLE ' + IntToStr(row);
             DictionaryFrm.DictGrid.Cells[3,row] := '8';
             DictionaryFrm.DictGrid.Cells[4,row] := 'F';
             DictionaryFrm.DictGrid.Cells[5,row] := '2';
             DictionaryFrm.DictGrid.Cells[6,row] := MissingValueCodes[Options.DefaultMiss];
             DictionaryFrm.DictGrid.Cells[7,row] := 'L';
    end;
    for row := 1 to NoVariables do
    begin
            DictionaryFrm.DictGrid.Cells[1,row] := OS3MainFrm.DataGrid.Cells[row,0];
            VarDefined[row] := true;
    end;
    GetTypes;
end;
//-------------------------------------------------------------------

procedure SaveCommaFile;
var
   namestr : string;
   cellvalue : string;
   CommaFile : TextFile;
   i, j : integer;

begin
    OS3MainFrm.SaveDialog1.Filter := 'Comma field files (*.CSV)|*.CSV|Text files (*.txt)|*.TXT|All files (*.*)|*.*';
    OS3MainFrm.SaveDialog1.FilterIndex := 1;
    OS3MainFrm.SaveDialog1.DefaultExt := 'CSV';
    if OS3MainFrm.SaveDialog1.Execute then
    begin
    	namestr := OS3MainFrm.SaveDialog1.FileName;
        Assign(CommaFile,namestr);
        ReWrite(CommaFile);
        for i := 0 to NoCases do
        begin
             for j := 1 to NoVariables do   //write all but last with a tab
             begin
                  cellvalue := OS3MainFrm.DataGrid.Cells[j,i];
                  if cellvalue = '' then cellvalue := '.';
                  cellvalue := Trim(cellvalue);
                  if j < NoVariables then cellvalue := cellvalue + ',';
                  write(CommaFile,cellvalue);
            end;
            writeln(CommaFile);
        end;
    end;
    CloseFile(CommaFile);
end;
//-------------------------------------------------------------------

procedure OpenSpaceFile;
label getit;
var
   SpaceFile : TextFile;
   namestr : string;
   astr : string;
   achar : char;
   respval : string;
   labelsinc : boolean;
   row, col : integer;
   spacechar : integer;
   spacefound : boolean;
begin
  Assert(OS3MainFrm <> nil);
  Assert(DictionaryFrm <> nil);

    spacechar := ord(' ');
    spacefound := false;
    labelsinc := false;
    // check for a currently open file
    if NoVariables > 1 then
    begin
       ShowMessage('WARNING! Close (or Save and Close) the current work.');
       exit;
    end;
    respval := InputBox('LABELS?','Are variable labels included?','Y');
    if respval = 'Y' then labelsinc := true;
    OS3MainFrm.OpenDialog1.Filter := 'Comma field files (*.SSV)|*.SSV|Text files (*.txt)|*.TXT|All files (*.*)|*.*';
    OS3MainFrm.OpenDialog1.FilterIndex := 1;
    OS3MainFrm.OpenDialog1.DefaultExt := 'SSV';
    if OS3MainFrm.OpenDialog1.Execute then
    begin
    	NoCases := 0;
        NoVariables := 0;
        if labelsinc = true then row := 0 else row := 1;
        col := 1;
        AssignFile(SpaceFile, OS3MainFrm.OpenDialog1.FileName);   { File selected in dialog box }
        Reset(SpaceFile);
        OS3MainFrm.FileNameEdit.Text := OS3MainFrm.OpenDialog1.FileName;
        astr := '';
        while not EOF(SpaceFile) do
        begin
getit:      read(SpaceFile,achar);
            if ord(achar) <> spacechar then spacefound := false;
            if (ord(achar) < 9) or (ord(achar) > 127) then goto getit;
            if ord(achar) = 13 then goto getit; // line feed character
            if (ord(achar) <> spacechar) and (ord(achar) <> 10) then // check for space or new line
            begin
            	astr := astr + achar;
            end
            else if ord(achar) = spacechar then // space character found
            begin
                if spacefound then goto getit; // extra space
                if length(astr) = 0 then goto getit; // leading space
                spacefound := true;
                if (not labelsinc) and (row = 1) then // create a col. label
                begin
                    namestr := 'VAR ' + IntToStr(col);
                    OS3MainFrm.DataGrid.Cells[col,0] := namestr;
                end;
                OS3MainFrm.DataGrid.Cells[col,row] := astr;
                if col > NoVariables then
                begin
                    NoVariables := col;
                    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
                end;
                col := col + 1;
                astr := '';
                if col >= OS3MainFrm.DataGrid.ColCount then
                    OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;
            end
            else //must be new line character
            begin
                spacefound := false;
                if (not labelsinc) and (row = 1) then // create a col. label
                begin
                    namestr := 'VAR ' + IntToStr(col);
                    OS3MainFrm.DataGrid.Cells[col,0] := namestr;
                end;
            	OS3MainFrm.DataGrid.Cells[col,row] := astr;
                astr := '';
                if col > NoVariables then
                begin
                    NoVariables := col;
                    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
                end;
                col := 1;
                if row > NoCases then NoCases := row;
                OS3MainFrm.DataGrid.Cells[0,row] := 'Case ' + IntToStr(row);
                row := row + 1;
                if row >= OS3MainFrm.DataGrid.RowCount then
                     OS3MainFrm.DataGrid.RowCount := OS3MainFrm.DataGrid.RowCount + 1;
            end;
        end;  // END OF FILE
        OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
        OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
        CloseFile(SpaceFile);
        if NoVariables > OS3MainFrm.DataGrid.ColCount - 1 then
           OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;
    end;
    OS3MainFrm.DataGrid.RowCount := (NoCases + 1);
    OS3MainFrm.DataGrid.ColCount := (NoVariables + 1);
    // set up the dictionary
    DictionaryFrm.DictGrid.RowCount := NoVariables + 1;
    DictionaryFrm.DictGrid.ColCount := 8;
    for row := 1 to NoVariables do
    begin
             DictionaryFrm.DictGrid.Cells[0,row] := IntToStr(row);
             DictionaryFrm.DictGrid.Cells[1,row] := 'VAR.' + IntToStr(row);
             DictionaryFrm.DictGrid.Cells[2,row] := 'VARIABLE ' + IntToStr(row);
             DictionaryFrm.DictGrid.Cells[3,row] := '8';
             DictionaryFrm.DictGrid.Cells[4,row] := 'F';
             DictionaryFrm.DictGrid.Cells[5,row] := '2';
             Dictionaryfrm.DictGrid.Cells[6,row] := MissingValueCodes[Options.DefaultMiss];
             DictionaryFrm.DictGrid.Cells[7,row] := 'L';
    end;
    for row := 1 to NoVariables do
    begin
            DictionaryFrm.DictGrid.Cells[1,row] := OS3MainFrm.DataGrid.Cells[row,0];
            VarDefined[row] := true;
    end;
    GetTypes;
end;
//-------------------------------------------------------------------

procedure SaveSpaceFile;
var
   namestr : string;
   cellvalue : string;
   SpaceFile : TextFile;
   i, j : integer;

begin
  Assert(OS3MainFrm <> nil);

    OS3MainFrm.SaveDialog1.Filter := 'Comma field files (*.SSV)|*.SSV|Text files (*.txt)|*.TXT|All files (*.*)|*.*';
    OS3MainFrm.SaveDialog1.FilterIndex := 1;
    OS3MainFrm.SaveDialog1.DefaultExt := 'SSV';
    if OS3MainFrm.SaveDialog1.Execute then
    begin
    	namestr := OS3MainFrm.SaveDialog1.FileName;
        Assign(SpaceFile,namestr);
        ReWrite(SpaceFile);
        for i := 0 to NoCases do
        begin
             for j := 1 to NoVariables do   //write all but last with a tab
             begin
                  cellvalue := OS3MainFrm.DataGrid.Cells[j,i];
                  if cellvalue = '' then cellvalue := '.';
                  cellvalue := Trim(cellvalue);
                  if j < NoVariables then cellvalue := cellvalue + ' ';
                  write(SpaceFile,cellvalue);
            end;
            writeln(SpaceFile);
        end;
    end;
    CloseFile(SpaceFile);
end;
//-------------------------------------------------------------------

procedure InsertRow;
var
   i, j, row : integer;

begin
  Assert(OS3MainFrm <> nil);

  row := OS3MainFrm.DataGrid.Row;
  OS3MainFrm.DataGrid.RowCount := OS3MainFrm.DataGrid.RowCount + 1;
  NoCases := OS3MainFrm.DataGrid.RowCount-1;
  OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
  for i := NoCases downto row+1 do
    for j := 1 to NoVariables do
      OS3MainFrm.DataGrid.Cells[j,i] := OS3MainFrm.DataGrid.Cells[j,i-1];
  for j := 1 to NoVariables do
    OS3MainFrm.DataGrid.Cells[j,row] := '';
  for i := 1 to NoCases do
    OS3MainFrm.DataGrid.Cells[0,i] := 'CASE ' + IntToStr(i);
end;
//-------------------------------------------------------------------

procedure OpenOSData;
var
   F : TextFile;
   filename : string;
   astr : string;
   i, j : integer;
   NRows, NCols : integer;
begin
  Assert(OS3MainFrm <> nil);
  Assert(DictionaryFrm <> nil);

     DictLoaded := false;
     OS3MainFrm.OpenDialog1.DefaultExt := '.OS2';
     OS3MainFrm.OpenDialog1.Filter := 'OpenStat2 (*.OS2)|*.OS2|Tab (*.tab)|*.TAB|space (*.SPC)|*.SPC|All files (*.*)|*.*';
     OS3MainFrm.OpenDialog1.FilterIndex := 1;
     if OS3MainFrm.OpenDialog1.Execute then
     begin
          filename := OS3MainFrm.OpenDialog1.FileName;
          OS3MainFrm.FileNameEdit.Text := filename;
          AssignFile(F,filename);
          Reset(F);
          Readln(F,NRows);
          readln(F,NCols);

          // initialize the dictionary grid for NCols of variables
          // using the default formats (protective measure in case of
          // a screw-up where the dictionary was damaged
          DictionaryFrm.DictGrid.ColCount := 8;
          DictionaryFrm.DictGrid.RowCount := NRows+1;
          for i := 1 to NCols do
          begin
               DictionaryFrm.DictGrid.Cells[0,i] := IntToStr(i);
               DictionaryFrm.DictGrid.Cells[1,i] := 'VAR.' + IntToStr(i);
               DictionaryFrm.DictGrid.Cells[2,i] := 'VARIABLE ' + IntToStr(i);
               DictionaryFrm.DictGrid.Cells[3,i] := '8';
               DictionaryFrm.DictGrid.Cells[4,i] := 'F';
               DictionaryFrm.DictGrid.Cells[5,i] := '2';
               DictionaryFrm.DictGrid.Cells[6,i] := ' ';
               DictionaryFrm.DictGrid.Cells[7,i] := 'L';
          end;
          DictionaryFrm.DescMemo.Clear;

          // Now read grid data
          OS3MainFrm.DataGrid.RowCount := NRows + 1;
          OS3MainFrm.DataGrid.ColCount := NCols + 1;
          OS3MainFrm.NoCasesEdit.Text := IntToStr(NRows);
          OS3MainFrm.NoVarsEdit.Text := IntToStr(NCols);
          NoVariables := NCols;
          NoCases := NRows;
          for i := 0 to NRows do // note - labels in row 0
          begin
               for j := 0 to NCols do // note - case no. in col. 0
               begin
                    Readln(F,astr);
                    OS3MainFrm.DataGrid.Cells[j,i] := astr;
               end;
          end;
          CloseFile(F);
          OS3MainFrm.DataGrid.Cells[0,0] := 'CASE/VAR.';

          // copy column names into the data dictionary.
          for i := 1 to NCols do
          begin
             DictionaryFrm.DictGrid.Cells[1,i] := OS3MainFrm.DataGrid.Cells[i,0];
             VarDefined[i] := true;
          end;
          DictionaryFrm.ShowModal;
          FormatGrid;
     end;
end;
//-------------------------------------------------------------------

procedure ClearGrid;
var
   i, j : integer;
begin
  Assert(OS3MainFrm <> nil);

  for i := 0 to NoCases do
  begin
    for j := 0 to NoVariables do OS3MainFrm.DataGrid.Cells[j,i] := '';
  end;

  OS3MainFrm.NoVarsEdit.Text := '0';
  OS3MainFrm.NoCasesEdit.Text := '0';
  NoVariables := 0;
  NoCases := 0;
  OS3MainFrm.DataGrid.RowCount := 2;
  OS3MainFrm.DataGrid.ColCount := 2;
  OS3MainFrm.DataGrid.Cells[0,1] := 'CASE 1';
  OS3MainFrm.DataGrid.Cells[0,0] := 'CASE/VAR.';

end;

procedure CopyIt;
VAR
   rowstart, rowend,colstart, colend, i, j : integer;
   buf : string;
   bf : pchar;

begin
  Assert(OS3MainFrm <> nil);

   Clipboard.Clear;
   rowstart := OS3MainFrm.DataGrid.Selection.Top;
   rowend := OS3MainFrm.DataGrid.Selection.Bottom;
   colstart := OS3MainFrm.DataGrid.Selection.Left;
   colend := OS3MainFrm.DataGrid.Selection.Right;
   buf := '';
   for i := rowstart to rowend do
   begin
        for j := colstart to colend do
        begin
             buf :=  buf + OS3MainFrm.DataGrid.Cells[j,i];
             buf := buf + chr(9); // add a tab
        end;
        buf := buf + chr(13); // add a newline
   end;
   bf := PChar(buf);
   Clipboard.SetTextBuf(bf);
end;

procedure PasteIt;
VAR
     astring, cellstr : string;
     col, howlong, startcol : integer;
     startrows :integer;
     row, i, j : integer;
     buf : pchar;
     strarray : array[0..100000] of char;
     size : integer;
     achar : char;
     pos : integer;

begin
   Assert(OS3MainFrm <> nil);
   Assert(DictionaryFrm <> nil);

     row := OS3MainFrm.DataGrid.Row;
     col := OS3MainFrm.DataGrid.Col;
     startrows := row;
     startcol := col;
     if NoVariables = 0 then NoVariables := 1;
     if VarDefined[col] = false then
     begin
          DictionaryFrm.DictGrid.ColCount := 8;
          DictionaryFrm.NewVar(col);
     end;

//     OS3MainFrm.DataGrid.RowCount := OS3MainFrm.DataGrid.RowCount + 1;
     OS3MainFrm.RowEdit.Text := IntToStr(OS3MainFrm.DataGrid.RowCount-1);
     if row < NoCases then // move all down before inserting
     begin
          for i := NoCases downto row do
               for j := 1 to NoVariables do
                   OS3MainFrm.DataGrid.Cells[j,i+1] := OS3MainFrm.DataGrid.Cells[j,i];
     end;
     OS3MainFrm.DataGrid.Row := startrows;
     OS3MainFrm.DataGrid.Col := startcol;
     buf := strarray;
     size := 100000;

    // get clipboard info
    if (Clipboard.HasFormat(CF_TEXT)) then astring := Clipboard.AsText
    else
    begin
       ShowMessage('The clipboard does not contain text.');
       exit;
    end;

     buf := strarray;
     size := 100000;
     ClipBoard.GetTextBuf(buf,size);
     // put buf in a string to parse
     astring := buf;
     howlong := Length(astring);
     pos := 1;
     cellstr := '';
     DictionaryFrm.DictGrid.ColCount := 8;
     DictionaryFrm.DictGrid.RowCount := 2;
     NoVariables := OS3MainFrm.DataGrid.ColCount - 1;
     while howlong > 0 do
     begin
          achar := astring[pos];
          if ord(achar) = 9 then // tab character - end of a grid cell value
          begin
               OS3MainFrm.DataGrid.Cells[col,row] := cellstr;
               col := col + 1;
               if col >= OS3MainFrm.DataGrid.ColCount then
               begin
                    OS3MainFrm.DataGrid.ColCount := col;
                    DictionaryFrm.NewVar(col);
                    NoVariables := col;
               end;
               cellstr := '';
               pos := pos + 1;
               howlong := howlong - 1;
          end;
          if (ord(achar) = 10) then
          begin
               pos := pos + 1;
               howlong := howlong - 1;
          end;
          if (ord(achar) = 12) then
          begin
               pos := pos + 1;
               howlong := howlong - 1;
          end;
          if (ord(achar) = 13) then // return character or new line - end of a row
          begin
               OS3MainFrm.DataGrid.Cells[col,row] := cellstr;
               col := startcol;
               row := row + 1;
               if row >= OS3MainFrm.DataGrid.RowCount then
               begin
                    OS3MainFrm.DataGrid.RowCount := row+1;
                    OS3MainFrm.DataGrid.Cells[0,row] := 'Case ' + IntToStr(row);
               end;

               cellstr := '';
               pos := pos + 1;
               NoCases := row - 1;
               howlong := howlong - 1;
          end;
          if ord(achar) > 13 then
          begin
               cellstr := cellstr + achar;
               pos := pos + 1;
               howlong := howlong - 1;
          end;
     end;
     // delete extraneous row and column
     OS3MainFrm.DataGrid.Col := NoVariables;
//     DeleteCol;
     OS3MainFrm.DataGrid.Row := NoCases+1;
//     CutaRow;
     OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases+1);
     OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
end;

procedure RowColSwap;
VAR
     i, j, Rows, Cols : integer;
     tempgrid : StrDyneMat;
begin
   Assert(OS3MainFrm <> nil);
   Assert(DictionaryFrm <> nil);

     SetLength(tempgrid,NoCases+1,NoVariables+1);
     Rows := NoCases;
     Cols := NoVariables;

     // store grid values
     for i := 0 to Rows do
     begin
          for j := 0 to Cols do
              tempgrid[i,j] := OS3MainFrm.DataGrid.Cells[j,i];
     end;

     // clear grid
     ClearGrid;

     // clear dictionary
     DictionaryFrm.DictGrid.ColCount := 8;
     DictionaryFrm.DictGrid.RowCount := 1;
     OS3MainFrm.FileNameEdit.Text := '';

     // create new variables = NoCases
     NoVariables := 0;
     for i := 1 to Rows do
     begin
          OS3MainFrm.DataGrid.ColCount := i;
          DictionaryFrm.NewVar(i);
          NoVariables := i;
     end;

     // store previous grid columns into the grid rows
     OS3MainFrm.DataGrid.RowCount := Cols+1;
     for i := 0 to Cols do
     begin
          for j := 1 to Rows do
          begin
               OS3MainFrm.DataGrid.Cells[j,i] := tempgrid[j,i];
          end;
     end;
     for i := 1 to Cols do // OS3MainFrm.DataGrid.Cells[0,i] := 'CASE ' + IntToStr(i);
         OS3MainFrm.DataGrid.Cells[0,i] := tempgrid[0,i];
     // finish up
     NoCases := Cols;
     OS3MainFrm.FileNameEdit.Text := 'SwapTemp';
     OS3MainFrm.NoCasesEdit.Text := IntToStr(Cols);
     OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
     tempgrid := nil;
end;

procedure MatToGrid(VAR mat : DblDyneMat; nsize : integer);
VAR
   i, j : integer;
Begin
  Assert(OS3MainFrm <> nil);
  Assert(DictionaryFrm <> nil);

     // clear grid
     ClearGrid;

     // clear dictionary
     DictionaryFrm.DictGrid.ColCount := 8;
     DictionaryFrm.DictGrid.RowCount := 1;
     OS3MainFrm.FileNameEdit.Text := '';

     // create new variables = NoCases
     NoVariables := 0;
     for i := 1 to nsize do
     begin
          OS3MainFrm.DataGrid.ColCount := i;
          DictionaryFrm.NewVar(i);
          NoVariables := i;
     end;
     // store matrix into the grid rows
     OS3MainFrm.DataGrid.RowCount := nsize + 1;
     for i := 0 to nsize-1 do
     begin
          for j := 0 to nsize-1 do
          begin
               OS3MainFrm.DataGrid.Cells[i+1,j+1] := FloatToStr(mat[i,j]);
          end;
     end;
     for i := 1 to nsize do
     begin
         OS3MainFrm.DataGrid.Cells[0,i] := 'VAR ' + IntToStr(i);
         OS3MainFrm.DataGrid.Cells[i,0] := 'VAR ' + IntToStr(i);
     end;
     // finish up
     NoCases := nsize;
     OS3MainFrm.FileNameEdit.Text := 'MATtemp.LAZ';
     OS3MainFrm.NoCasesEdit.Text := IntToStr(nsize);
     OS3MainFrm.NoVarsEdit.Text := IntToStr(nsize);
end;

procedure GetTypes;
VAR
   row,col,pos,i,strlong,intplaces,decplaces : integer;
   cellstr: string;
   strtype, inttype, floattype,isnumber : boolean;
   comma, period, achar : char;
begin
  Assert(OS3MainFrm <> nil);
  Assert(DictionaryFrm <> nil);

     isnumber := false;
     strtype := false;
     inttype := false;
     floattype := false;
     comma := ',';
     period := '.';

     for col := 1 to NoVariables do
     begin
          for row := 1 to NoCases do
          begin
               cellstr := trim(OS3MainFrm.DataGrid.Cells[col,row]);
               strlong := length(cellstr);
               // check for a number type
               for i := 1 to strlong do
                   if (ord(cellstr[i]) < 44) or (ord(cellstr[i]) > 57 ) or (ord(cellstr[i]) = 47 ) then
                   begin
                        isnumber := false;
                        break;
                   end
                   else isnumber := true;
               if isnumber = false then strtype := true;
               if isnumber = true then
               begin // determine if an integer or float number
                     for i := 1 to strlong do
                     begin
                          achar := cellstr[i];
                          if achar = period then floattype := true;
                          if achar = comma then floattype := true;
                          if floattype = true then
                          begin
                               pos := i;
                               break;
                          end;
                     end;
                     if floattype = false then inttype := true;
                     if floattype = true then
                     begin // get no. of decimal positions
                           intplaces := pos - 1;
                           decplaces := strlong - pos - 1;
                     end;
               end; // end if it is a number
          end; // end of row search
          // set dictionary values
          if strtype = true then
          begin
               DictionaryFrm.DictGrid.Cells[4,col] := 'S';
               DictionaryFrm.DictGrid.Cells[3,col] := IntToStr(strlong);
               DictionaryFrm.DictGrid.Cells[5,col] := '0';
          end;
          if inttype = true then
          begin
               DictionaryFrm.DictGrid.Cells[4,col] := 'I';
               DictionaryFrm.DictGrid.Cells[3,col] := IntToStr(strlong);
               DictionaryFrm.DictGrid.Cells[5,col] := '0';
          end;
          if floattype = true then
          begin
               DictionaryFrm.DictGrid.Cells[4,col] := 'F';
               DictionaryFrm.DictGrid.Cells[3,col] := IntToStr(strlong);
               DictionaryFrm.DictGrid.Cells[5,col] := IntToStr(decplaces);
          end;
          isnumber := false;
          strtype := false;
          inttype := false;
          floattype := false;
     end; // end of column loop
end;

function StringsToInt(strcol: integer; VAR newcol : integer; prompt : boolean) : boolean;
label endit;
VAR
   i, j, k, NoStrings: integer;
   TempString, response : string;
   dup, savenewcol, strtype : boolean;
   StrGrps, OneString : StrDyneVec;

begin
  Assert(OS3MainFrm <> nil);
  Assert(DictionaryFrm <> nil);

 { Procedure to convert group strings into group integers with the option
   to save the integers in the grid }
        strtype := false;
        savenewcol := true;

        // Get memory for arrays
        SetLength(StrGrps,NoCases+1);
        SetLength(OneString,NoCases+1);

        // check to see if strcol is a string variable
        if DictionaryFrm.DictGrid.Cells[4,strcol] = 'S' then strtype :=true
        else begin
                ShowMessage('ERROR! Column selected is not defined as a string variable');
                goto endit;
        end;

        // read the strings into the StrGrps array
        for i := 1 to NoCases do
           StrGrps[i-1] := trim(OS3MainFrm.DataGrid.Cells[strcol,i]);

        // sort the StrGrps array
        for i := 0 to NoCases - 1 do
        begin
             for j := i + 1 to NoCases - 1 do
             begin
                  if (StrGrps[i] > StrGrps[j]) then // swap
                  begin
                       TempString := StrGrps[i];
                       StrGrps[i] := StrGrps[j];
                       StrGrps[j] := TempString;
                  end;
             end;
        end;

        // copy unique strings into the OneString array
        TempString := StrGrps[0];
        OneString[0] := TempString;
        NoStrings := 0;
        for i := 1 to NoCases do
        begin
                if (StrGrps[i] <> TempString) then // a new string found
                begin
                        for k := 0 to NoCases - 1 do // check for existing
                        begin
                                if (TempString = OneString[k]) then dup := true
                                else dup := false;
                        end;
                        if (dup = false) then
                        begin
                                NoStrings := NoStrings + 1;
                                OneString[NoStrings] := StrGrps[i];
                                TempString := StrGrps[i];
                        end;
                end;
        end;

        // make a new variable in the grid for the group integers
        DictionaryFrm.NewVar(NoVariables+1);
        DictionaryFrm.DictGrid.Cells[1,NoVariables] := 'GroupCode';
        OS3MainFrm.DataGrid.Cells[NoVariables,0] := 'GroupCode';
        OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);

        DictionaryFrm.DictGrid.Cells[4,NoVariables] := 'I';
        DictionaryFrm.DictGrid.Cells[5,NoVariables] := '0';
        OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
        newcol := NoVariables;

        // oompare case strings with OneString values and use index + 1
        // for the group code in the data grid
        for i := 1 to NoCases do
        begin
                TempString := OS3MainFrm.DataGrid.Cells[strcol,i];
                for j := 0 to NoCases-1 do
                begin
                        if (TempString = OneString[j]) then
                           OS3MainFrm.DataGrid.Cells[NoVariables,i] := IntToStr(j+1);
                end;
        end;

        // see if user wants to save the generated group codes
        if (prompt = true) then
        begin
                response := InputBox('Save Code in Grid?','Y or N','Y');
                if ((response = 'n') or (response = 'N')) then
                    savenewcol := false;
        end;

        // clean up memory
endit:  OneString := nil;
        StrGrps := nil;

        // return results
        StringsToInt := savenewcol;
end;



end.
