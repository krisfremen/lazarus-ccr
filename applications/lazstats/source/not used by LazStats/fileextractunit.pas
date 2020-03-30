unit FileExtractUnit;

{$MODE Delphi}

interface

uses
  LCLIntf, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, GLOBALS, OS3MainUnit, DATAPROCS, DICTIONARYUNIT,
  LResources, Buttons;

type
  TFileExtractFrm = class(TForm)
    Memo1: TMemo;
    Label2: TLabel;
    NoLinesEdit: TEdit;
    Label3: TLabel;
    NoFieldsEdit: TEdit;
    FormatGrp: TRadioGroup;
    Label4: TLabel;
    KeyVarNoEdit: TEdit;
    Label5: TLabel;
    ValueEdit: TEdit;
    LabelsChk: TCheckBox;
    FmtGrid: TStringGrid;
    CancelBtn: TButton;
    OKBtn: TButton;
    ResetBtn: TButton;
    ExtractBtn: TButton;
    OpenDialog1: TOpenDialog;
    FileSelBtn: TButton;
    Label1: TLabel;
    NoGotEdit: TEdit;
    Label6: TLabel;
    RecdReadEdit: TEdit;
    TypeBox: TComboBox;
    procedure ResetBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormatGrpClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ExtractBtnClick(Sender: TObject);
    procedure FileSelBtnClick(Sender: TObject);
    procedure TypeBoxChange(Sender: TObject);
  private
    { Private declarations }
    FileName : string;

  public
    { Public declarations }
    function GetValues(VAR TheFile : TextFile;
                       NoLines : integer;
                       NoFlds : integer;
                       Token : integer;
                       VAR StrValues : StrDyneVec) : boolean;
    procedure PutGrid(RecdNo : integer;
                      NoFlds : integer;
                      LabelsFirst : boolean;
                      VAR StrValues : StrDyneVec);
    function GetFmtValues(VAR TheFile : TextFile;
                          NoLines : integer;
                          NoFlds : integer;
                          VAR StrValues : StrDyneVec) : boolean;
  end;

var
  FileExtractFrm: TFileExtractFrm;

implementation


procedure TFileExtractFrm.ResetBtnClick(Sender: TObject);
begin
    NoLinesEdit.Text := '1';
    NoFieldsEdit.Text := '';
    KeyVarNoEdit.Text := '';
    ValueEdit.Text := '';
    NoGotEdit.Text := '';
    RecdReadEdit.Text := '';
    FormatGrp.ItemIndex := 0;
    LabelsChk.Checked := false;
    FmtGrid.Cells[0,0] := 'Field';
    FmtGrid.Cells[1,0] := 'Start';
    FmtGrid.Cells[2,0] := 'End';
    FmtGrid.Cells[3,0] := 'Data Type';
    FmtGrid.Cells[4,0] := 'Line No.';
    FmtGrid.Cells[5,0] := 'Label';
    FmtGrid.Visible := false;
    TypeBox.Text := 'Types';
    TypeBox.Visible := false;
end;
//--------------------------------------------------------

procedure TFileExtractFrm.FormShow(Sender: TObject);
begin
    ResetBtnClick(self);
end;
//---------------------------------------------------------

procedure TFileExtractFrm.CancelBtnClick(Sender: TObject);
begin
    FileExtractFrm.Hide;
end;
//--------------------------------------------------------------

procedure TFileExtractFrm.FormatGrpClick(Sender: TObject);
begin
    if FormatGrp.ItemIndex = 3 then
    begin
        FmtGrid.RowCount := StrToInt(NoFieldsEdit.Text) + 1;
        FmtGrid.Visible := true;
        TypeBox.Visible := true;
    end
    else begin
        FmtGrid.Visible := false;
        TypeBox.Visible := false;
    end;
end;
//-------------------------------------------------------------

procedure TFileExtractFrm.OKBtnClick(Sender: TObject);
begin
    FileExtractFrm.Hide;
end;
//---------------------------------------------------------------------

function TFileExtractFrm.GetValues(VAR TheFile : TextFile;
                                   NoLines : integer;
                                   NoFlds : integer;
                                   Token : integer;
                                   VAR StrValues : StrDyneVec) : boolean;
var
    done, endline : boolean;
    i, valcount : integer;
    cellstring : string;
    achar : char;

begin
    done := false;
    valcount := 0;

    if not done then
    begin
        for i := 1 to NoLines do
        begin
            endline := false;
            while not endline do
            begin
                read(TheFile,achar);
                if EOF(TheFile) then
                begin
                    done := true;
                    GetValues := done;
                    exit;
                end;
                if ord(achar) = 10 then continue; //  ignore line feed
                if ord(achar) <> 13 then // not a new line
                begin
                    if ord(achar) <> Token then // not a tab character
                        cellstring := cellstring + achar
                    else
                    begin // Token character found - save string and bump counter
                        StrValues[valcount] := cellstring;
                        cellstring := '';
                        valcount := valcount + 1;
                    end;
                end // not a new line - tab or character found
                else begin
                    endline := true;
                    StrValues[valcount] := cellstring;
                    valcount := valcount + 1;
                    cellstring := '';
                end;
            end; // next line
        end; // next line
    end // net yet at eof
    else done := true;
    if valcount <> NoFlds then
    begin
        ShowMessage('ERROR! Mismatched no. fields - see grid for first record');
        FmtGrid.ColCount := valcount + 1;
        FmtGrid.Visible := true;
        for i := 1 to NoFlds do
            FmtGrid.Cells[i-1,0] := StrValues[i-1];
        done := true;
    end;
    GetValues := done;
end;
//---------------------------------------------------------------------

procedure TFileExtractFrm.PutGrid(RecdNo : integer;
                                  NoFlds : integer;
                                  LabelsFirst : boolean;
                                  VAR StrValues : StrDyneVec);
var
    i : integer;
    cellstring : string;

begin
    if LabelsFirst = true then
    begin
        OS3MainFrm.DataGrid.RowCount := 2;
        OS3MainFrm.DataGrid.Cells[0,0] := 'Case 0';
        for i := 1 to NoFlds do OS3MainFrm.DataGrid.Cells[i,0] := StrValues[i-1];
    end
    else
    begin
        OS3MainFrm.DataGrid.RowCount := RecdNo + 1;
        cellstring := 'Case ' + IntToStr(RecdNo);
        OS3MainFrm.DataGrid.Cells[0,RecdNo] := cellstring;
        for i := 1 to NoFlds do OS3MainFrm.DataGrid.Cells[i,RecdNo] := StrValues[i-1];
    end;
end;
//---------------------------------------------------------------------

procedure TFileExtractFrm.ExtractBtnClick(Sender: TObject);
var
    LabelsFirst : boolean; // first record contains variable labels
    NoFlds : integer; // number of variables
    NoLines : integer; // number of lines per record
    FormatType : integer; // 1 = tab, 2 = comma, 3 = space, 4 = user spec.
    KeyNo : integer; // sequence number of field containing the key
    KeyValue : string; // value of the key field
    TheFile : TextFile; // file handle
    StrValues : StrDyneVec; // pointer to array of strings for record values
    done : boolean;
    NoRecords : integer;
    Token : integer; // tab, comma or space charcter ordinal value
    i, fldno : integer;
    OldCursor : Tcursor;
    NoRead : integer; // no. of records read from big file
    fldtype : string;
    cellstring : string; // for labels provided in the fmtgrid

begin
    // get entered values from the form
    if LabelsChk.Checked then LabelsFirst := true else LabelsFirst := false;
    NoFlds := StrToInt(NoFieldsEdit.Text);
    NoLines := StrToInt(NoLinesEdit.Text);
    FormatType := FormatGrp.ItemIndex + 1;
    KeyNo := StrToInt(KeyVarNoEdit.Text);
    KeyValue := ValueEdit.Text;
    SetLength(StrValues,NoFlds + 1);
    done := false;
    NoRecords := 0;
    Token := ord(' '); // default of a space
    OldCursor := FileExtractFrm.Cursor;
    NoRead := 0;
    OS3MainFrm.DataGrid.ColCount := NoFlds + 1;
    for i := 1 to NoFlds do
    begin
        DictionaryFrm.DictGrid.RowCount := i;
        DictionaryFrm.Defaults(Self,i);
        VarDefined[i] := true;
    end;

    // open file for processing
    AssignFile(TheFile,FileName);
    Reset(TheFile);

    // process first (or second) record according to format type
    case FormatType of
    1, 2, 3 : begin  // tab seperated fields
            FileExtractFrm.Cursor := crHourGlass;
            if not LabelsFirst then
            begin
                // store labels (if not blank) into grid row 0 and type in defs.
                for i := 1 to NoFlds do
                begin
                    cellstring := format('VAR%2d',[i]);
                    OS3MainFrm.DataGrid.Cells[i,0] := cellstring;
                end;
            end;
            while Not done do
            begin
                if FormatType = 1 then Token := 9; // tab character
                if FormatType = 2 then Token := ord(','); // comma
                if FormatType = 3 then Token := ord(' '); // space
                done := GetValues(TheFile,NoLines,NoFlds,Token,StrValues);
                if not done then
                begin
                    NoRead := NoRead + 1;
                    if LabelsFirst then
                    begin
                        PutGrid(0,NoFlds,LabelsFirst,StrValues);
                        LabelsFirst := false;
                    end;
                    RecdReadEdit.Text := IntToStr(NoRead);
                    FileExtractFrm.Repaint;
                    StrValues[KeyNo-1] := Trim(StrValues[KeyNo-1]);
                    if StrValues[KeyNo-1] = KeyValue then // found group record
                    begin
                        NoRecords := NoRecords + 1;
                        PutGrid(NoRecords,NoFlds,LabelsFirst,StrValues);
                        NoGotEdit.Text := IntToStr(NoRecords);
                    end;
                end;
            end;
            FileExtractFrm.Cursor := OldCursor;
            OS3MainFrm.NoCasesEdit.Text := IntToStr(NoRecords);
            OS3MainFrm.NoVarsEdit.Text := IntToStr(NoFlds);
            OS3MainFrm.RowEdit.Text := '1';
            OS3MainFrm.ColEdit.Text := '1';
            OS3MainFrm.DataGrid.Row := 1;
            OS3MainFrm.DataGrid.Col := 1;
            NoVariables := NoFlds;
            NoCases := NoRecords;
        end;
    4 : begin  // user specified format
            FileExtractFrm.Cursor := crHourGlass;
            if not LabelsFirst then
            begin
                // store labels (if not blank) into grid row 0 and type in defs.
                for i := 1 to NoFlds do
                begin
                    fldno := StrToInt(FmtGrid.Cells[0,i]);
                    fldtype := FmtGrid.Cells[3,fldno];
                    DictionaryFrm.DictGrid.Cells[4,fldno] := fldtype[2];
                    cellstring := FmtGrid.Cells[5,fldno];
                    DictionaryFrm.DictGrid.Cells[1,fldno] := cellstring;
                    DictionaryFrm.DictGrid.Cells[2,fldno] := cellstring;
                    if cellstring <> '' then OS3MainFrm.DataGrid.Cells[i,0] := cellstring;
                end;
            end;
            while NOT done do
            begin
                done := GetFmtValues(TheFile,NoLines,NoFlds,StrValues);
                if not done then
                begin
                    NoRead := NoRead + 1;
                    if LabelsFirst then
                    begin
                        PutGrid(0,NoFlds,LabelsFirst,StrValues);
                        LabelsFirst := false;
                    end;
                    RecdReadEdit.Text := IntToStr(NoRead);
                    FileExtractFrm.Repaint;
                    StrValues[KeyNo-1] := Trim(StrValues[KeyNo-1]);
                    if StrValues[KeyNo-1] = KeyValue then // found group record
                    begin
                        NoRecords := NoRecords + 1;
                        PutGrid(NoRecords,NoFlds,LabelsFirst,StrValues);
                        NoGotEdit.Text := IntToStr(NoRecords);
                    end;
                end; // if not done
            end; // while not done
            FileExtractFrm.Cursor := OldCursor;
            OS3MainFrm.NoCasesEdit.Text := IntToStr(NoRecords);
            OS3MainFrm.NoVarsEdit.Text := IntToStr(NoFlds);
            OS3MainFrm.RowEdit.Text := '1';
            OS3MainFrm.ColEdit.Text := '1';
            OS3MainFrm.DataGrid.Row := 1;
            OS3MainFrm.DataGrid.Col := 1;
            NoVariables := NoFlds;
            NoCases := NoRecords;
        end; // end case 4 (formatted input)
    end; // end case switch
    StrValues := nil;
    CloseFile(TheFile);
end;
//------------------------------------------------------------------------

procedure TFileExtractFrm.FileSelBtnClick(Sender: TObject);
begin
    OpenDialog1.Filter := 'Tab field files (*.tab)|*.TAB|Text files (*.txt)|*.TXT|All files (*.*)|*.*';
    OpenDialog1.FilterIndex := 1;
    OpenDialog1.DefaultExt := 'TAB';
    if OpenDialog1.Execute then FileName := OpenDialog1.FileName
    else ShowMessage('Error in opening File!');
end;
//-------------------------------------------------------------------------

function TFileExtractFrm.GetFmtValues(VAR TheFile : TextFile;
                                      NoLines : integer;
                                      NoFlds : integer;
                                      VAR StrValues : StrDyneVec) : boolean;
var
    done, endline : boolean;
    i, j, endat, startat, stlong, valcount, fldno : integer;
    LineStr : string;
    achar : char;

begin
    done := false;
    valcount := 0;

    if not done then
    begin
        for i := 1 to NoLines do
        begin
            endline := false;
            while not endline do
            begin
                read(TheFile,achar);
                if EOF(TheFile) then
                begin
                    done := true;
                    GetFmtValues := done;
                    exit;
                end;
                if ord(achar) = 10 then continue; //  ignore line feed
                if ord(achar) <> 13 then LineStr := LineStr + achar
                else endline := true;
            end;
            // now, parse values in this line
            for j := 1 to NoFlds do
            begin
                if StrToInt(FmtGrid.Cells[4,j]) <> i then continue; // in line i?
                startat := StrToInt(FmtGrid.Cells[1,j]);
                endat := StrToInt(FmtGrid.Cells[2,j]);
                stlong := endat - startat + 1;
                fldno := StrToInt(FmtGrid.Cells[0,j]);
                StrValues[fldno-1] := Copy(LineStr,startat,stlong);
                valcount := valcount + 1;
            end; // next j
            LineStr := '';
        end; // next line
    end // not yet at eof
    else done := true;
    if valcount <> NoFlds then
    begin
        ShowMessage('ERROR! Mismatched no. fields and actual record data.');
        done := true;
    end;
    GetFmtValues := done;
end;
//-----------------------------------------------------------------------

procedure TFileExtractFrm.TypeBoxChange(Sender: TObject);
var
    index : integer;
    row, col : integer;

begin
    index := TypeBox.ItemIndex;
    row := FmtGrid.Row;
    col := FmtGrid.Col;
    FmtGrid.Cells[col,row] := IntToStr(index);
end;

//-------------------------------------------------------------------------

initialization
  {$i fileextractunit.lrs}
  {$i FILEEXTRACTUNIT.lrs}

end.
