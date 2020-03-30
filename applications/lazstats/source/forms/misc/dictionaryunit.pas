unit DictionaryUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Grids, ExtCtrls,
  Globals, OptionsUnit, ContextHelpUnit;

type

  { TDictionaryFrm }

  TDictionaryFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Label2: TLabel;
    DescMemo: TMemo;
    RowDelBtn: TButton;
    RowInstBtn: TButton;
    JustCombo: TComboBox;
    Splitter1: TSplitter;
    TypeCombo: TComboBox;
    Label1: TLabel;
    ReturnBtn: TButton;
    CancelBtn: TButton;
    DictGrid: TStringGrid;
    Panel1: TPanel;
    procedure DictGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DictGridSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure DictGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure JustComboClick(Sender: TObject);
    procedure JustComboSelect(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
    procedure RowDelBtnClick(Sender: TObject);
    procedure RowInstBtnClick(Sender: TObject);
    procedure Defaults(Sender: TObject; row : integer);
    procedure TypeComboSelect(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
    procedure DelRow(row : integer);
    procedure NewVar(row : integer);
    procedure PasteVar(row : integer);
    procedure CopyVar(row : integer);
    procedure Init;
  end; 

var
  DictionaryFrm: TDictionaryFrm;

implementation

{ TDictionaryFrm }

uses MainUnit;

procedure TDictionaryFrm.ReturnBtnClick(Sender: TObject);
var
   i, j, count : integer;
   NoRows : integer;
begin
     // determine number of rows with complete data
     NoRows := 0;
     for i := 1 to DictGrid.RowCount - 1 do
     begin
          count := 0;
          for j := 1 to 5 do
          begin
               if DictGrid.Cells[j,i] <> '' then count := count + 1;
          end;
          if count > 4 then NoRows := NoRows + 1;
     end;
     if NoRows < DictGrid.RowCount - 1 then
     begin
          ShowMessage('Error! A definition entry for one or more variables missing!');
          DictGrid.SetFocus;
          exit;
     end;

     // Place short labels in main grid
     OS3MainFrm.DataGrid.ColCount := NoRows + 1;
     for i := 1 to NoRows do OS3MainFrm.DataGrid.Cells[i,0] := DictGrid.Cells[1,i];

     // Make sure integers have a 0 for decimals
     for i := 1 to NoRows do
        if DictGrid.Cells[4,i] = 'I' then DictGrid.Cells[5,i] := '0';
     OS3MainFrm.NoVarsEdit.Text := IntToStr(OS3MainFrm.DataGrid.ColCount-1);
     if OS3MainFrm.FileNameEdit.Text = '' then exit;
end;

procedure TDictionaryFrm.RowDelBtnClick(Sender: TObject);
var
   index : integer;
   i, j  : integer;

begin
     index := DictGrid.Row;
     if index = DictGrid.RowCount-1 then // last row
     begin
          for i := 0 to 7 do DictGrid.Cells[i,index] := '';
          DictGrid.RowCount := DictGrid.RowCount - 1;
          VarDefined[index] := false;
     end
     else
     begin // move lines below current lines up and delete last
           for i := index+1 to DictGrid.RowCount - 1 do
           begin
                for j := 0 to 6 do DictGrid.Cells[j,i-1] := DictGrid.Cells[j,i];
                VarDefined[i-1] := VarDefined[i];
           end;
           VarDefined[DictGrid.RowCount-1] := false;
           DictGrid.RowCount := DictGrid.RowCount - 1;
           for i := 1 to DictGrid.RowCount - 1 do  // renumber rows
               DictGrid.Cells[0,i] := IntToStr(i);
     end;
end;

procedure TDictionaryFrm.RowInstBtnClick(Sender: TObject);
var
   index : integer;
   i, j  : integer;

begin
   index := DictGrid.Row;
   DictGrid.RowCount := DictGrid.RowCount + 1;  // add new row to grid
   // move all rows from index down 1
   for i := DictGrid.RowCount - 1 downto index+1 do
   begin
        for j := 1 to 6 do
        begin
             DictGrid.Cells[j,i] := DictGrid.Cells[j,i-1];
        end;
        VarDefined[i] := VarDefined[i-1];
   end;

   // place default values in new row
   Defaults(Self,index);
   VarDefined[index] := true;
end;


procedure TDictionaryFrm.FormShow(Sender: TObject);
begin
  ReturnBtn.Constraints.MinWidth := CancelBtn.Width;
  Init;
end;

procedure TDictionaryFrm.Init;
begin
  DictGrid.ColCount := 8;
  if NoVariables = 0 then
    DictGrid.RowCount := 2
  else
    DictGrid.RowCount := NoVariables + 1;

  // insert headings
  DictGrid.Cells[0,0] := 'VAR/CHAR.';
  DictGrid.Cells[1,0] := 'Short Name';
  DictGrid.Cells[2,0] := 'Long Name';
  DictGrid.Cells[3,0] := 'Width';
  DictGrid.Cells[4,0] := 'Type';
  DictGrid.Cells[5,0] := 'Decimals';
  DictGrid.Cells[6,0] := 'Missing';
  DictGrid.Cells[7,0] := 'Justify';
  DictGrid.Cells[0,1] := '1';
  DictGrid.ColWidths[1] := 100;
  DictGrid.ColWidths[2] := 200;
  DictGrid.ColWidths[3] := 50;
  DictGrid.ColWidths[4] := 50;
  DictGrid.ColWidths[5] := DictGrid.Canvas.TextWidth('Decimals') + 2*varCellPadding;
  DictGrid.ColWidths[6] := DictGrid.Canvas.TextWidth('Missing') + 2*varCellPadding;
  DictGrid.ColWidths[7] := DictGrid.Canvas.TextWidth('Justify') + 2*varCellPadding;

  // check for absence of a defined variable
  if VarDefined[1] = false then
  begin
    // load defaults
    Defaults(Self,1);
    VarDefined[1] := true;
  end;
end;

procedure TDictionaryFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TDictionaryFrm.JustComboClick(Sender: TObject);
var
   achar : char;
   astr : string;
   index : integer;
   GRow : integer;

begin
     index := JustCombo.ItemIndex;
     astr := JustCombo.Items.Strings[index];
     achar := astr[2];
     GRow := DictGrid.Row;
     DictGrid.Cells[7,GRow] := achar;
     JustCombo.Text := 'Justification';
end;

procedure TDictionaryFrm.JustComboSelect(Sender: TObject);
var
   achar : char;
   astr : string;
   index : integer;
   GRow : integer;

begin
     index := JustCombo.ItemIndex;
     astr := JustCombo.Items.Strings[index];
     achar := astr[2];
     GRow := DictGrid.Row;
     if GRow>0 then DictGrid.Cells[7,GRow] := achar;
     JustCombo.Text := 'Justification';
     DictGrid.SetFocus;
end;

procedure TDictionaryFrm.DictGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   x, y, v : integer;
begin
     x := DictGrid.Row;
     y := DictGrid.Col;
     v := ord(Key);
     case v of
     13 : if y = 7 then DictGrid.Col := 1 else DictGrid.Col := DictGrid.Col + 1;
     40 : begin // arrow down key
               if x = DictGrid.RowCount - 1 then
               begin
                    if DictGrid.RowCount < (x + 2) then
                        DictGrid.RowCount := DictGrid.RowCount + 1;
                    Defaults(Self,x+1);
                    VarDefined[x+1] := true;
               end;
          end;
     end;
end;

procedure TDictionaryFrm.DictGridSelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  if (aCol in [4, 7]) then
  begin
    Editor := DictGrid.EditorByStyle(cbsPickList);
    if (Editor is TCustomComboBox) then
      with Editor as TCustomComboBox do begin
        Style := csDropDown;
        case ACol of
          4: Items.CommaText := 'I,F,S,M,D';
          7: Items.CommaText := 'L,C,R';
        end;
      end
  end;
end;

procedure TDictionaryFrm.DictGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  if (ACol in [4, 7]) then
    DictGrid.Cells[ACol, ARow] := UpperCase(Value);
end;

procedure TDictionaryFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  {
  if OptionsFrm = nil then
    Application.CreateForm(TOptionsFrm, OptionsFrm);
  }
end;

procedure TDictionaryFrm.Defaults(Sender: TObject; row : integer);
var
  i: integer;
begin
  DictGrid.Cells[0,row] := IntToStr(row);
  DictGrid.Cells[1,row] := 'VAR.' + IntToStr(row);
  DictGrid.Cells[2,row] := 'VARIABLE ' + IntToStr(row);
  DictGrid.Cells[3,row] := '8';
  DictGrid.Cells[4,row] := 'F';
  DictGrid.Cells[5,row] := '2';
  DictGrid.Cells[6, row] := MissingValueCodes[Options.DefaultMiss];
  DictGrid.Cells[7, row] := JustificationCodes[Options.DefaultJust];
  for i := 1 to DictGrid.RowCount - 1 do
    DictGrid.Cells[0,i] := IntToStr(i);
end;

procedure TDictionaryFrm.TypeComboSelect(Sender: TObject);
var
   achar : char;
   astr : string;
   index : integer;
   GRow : integer;
begin
     index := TypeCombo.ItemIndex;
     astr := TypeCombo.Items.Strings[index];
     achar := astr[2];
     GRow := DictGrid.Row;
     if GRow>0 then
     begin
          DictGrid.Cells[4,GRow] := achar;
          if achar='F' then DictGrid.Cells[5,GRow] := '3'   // set decimal digits
          else DictGrid.Cells[5,GRow] := '0';
     end;
     TypeCombo.Text := 'Type';
     DictGrid.SetFocus;
end;

procedure TDictionaryFrm.DelRow(row : integer);
begin
     DictGrid.Row := row;
     TempVarItm.Clear;
     DictGrid.Rows[row].SaveToStream(TempVarItm);
     RowDelBtnClick(Self);
end;
//-------------------------------------------------------------------

procedure TDictionaryFrm.NewVar(row : integer);
var
   i, j : integer;
begin
     DictGrid.RowCount := DictGrid.RowCount + 1; // add new row
     NoVariables := NoVariables + 1;
     if (row < NoVariables) AND (NoVariables > 1) then  // move current rows down 1
     begin
          for i := NoVariables downto row + 1 do
          begin
               for j := 1 to 7 do DictGrid.Cells[j,i] := DictGrid.Cells[j,i-1];
               VarDefined[i] := VarDefined[i-1];
          end;
     end;
     // put default values in new variable
     Defaults(Self,row);
     VarDefined[row] := true;

     // add to grid if grid column does not exist
     if OS3MainFrm.DataGrid.ColCount < row then
     begin
          OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;
          OS3MainFrm.DataGrid.Cells[row,0] := DictGrid.Cells[1,row];
     end;
     ReturnBtnClick(Self);
end;
//-------------------------------------------------------------------

procedure TDictionaryFrm.PasteVar(row : integer);
var i : integer;
begin
     TempVarItm.Position := 0;
     DictGrid.Rows[row].LoadFromStream(TempVarItm);
     for i := 1 to DictGrid.RowCount - 1 do DictGrid.Cells[0,i] := IntToStr(i);
//     FormShow(Self);
end;
//-------------------------------------------------------------------

procedure TDictionaryFrm.CopyVar(row : integer);
begin
     DictGrid.Row := row;
     TempVarItm.Clear;
     DictGrid.Rows[row].SaveToStream(TempVarItm);
end;
//-------------------------------------------------------------------

initialization
  {$I dictionaryunit.lrs}

end.

