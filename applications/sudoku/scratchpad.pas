unit ScratchPad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls,
  Math,
  SudokuType, DigitSetEditor;

type

  { TScratchForm }

  TCopyValuesEvent = procedure(Sender: TObject; Values: TValues) of Object;
  TCopyRawDataEvent = procedure(Sender: TObject; RawData: TRawGrid) of Object;

  TScratchForm = class(TForm)
    btnCopy: TButton;
    btnCopyRaw: TButton;
    ScratchGrid: TStringGrid;
    procedure btnCopyClick(Sender: TObject);
    procedure btnCopyRawClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ScratchGridClick(Sender: TObject);
    procedure ScratchGridPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      {%H-}aState: TGridDrawState);
  private
    FRawData: TRawGrid;
    FOnCopyValues: TCopyValuesEvent;
    FOnCopyRawData: TCopyRawDataEvent;
    procedure GridToRawData(out RawData: TRawGrid);
    procedure SetRawData(Data: TRawGrid);
    procedure GridToValues(out Values: TValues);
    procedure KeepInView;
    procedure EditCell(ACol, ARow: Integer);
  public
    property RawData: TRawGrid write SetRawData;
    property OnCopyValues: TCopyValuesEvent read FOnCopyValues write FOnCopyValues;
    property OnCopyRawData: TCopyRawDataEvent read FOnCopyRawData write FOnCopyRawData;
  end;

var
  ScratchForm: TScratchForm;

implementation

{$R *.lfm}

function DigitSetToStr(ASet: TDigitSet): String;
  function Get(D: Integer): Char;
  begin
    if (D in ASet) then
      Result := Char(Ord('0') + D)
    else
      Result := #32;//'x'
  end;
begin
  Result := Format('%s %s %s'+LineEnding+'%s %s %s'+LineEnding+'%s %s %s',[Get(1),Get(2),Get(3),Get(4),Get(5),Get(6),Get(7),Get(8),Get(9)]);
end;

function StrToDigitSet(const S: String): TDigitSet;
var
  Ch: Char;
begin
  Result := [];
  for Ch in S do
    if (Ch in ['1'..'9']) then
      Include(Result, Ord(Ch) - Ord('0'));
end;

{

}
function TryCellTextToDigit(const AText: String; out Value: TDigits): Boolean;
var
  Ch: Char;
  S: String;
begin
  Result := False;
  S := '';
  for Ch in AText do
    if (Ch in ['1'..'9']) then S := S + Ch;
  if (Length(S) = 1) then
  begin
    Ch := S[1];
    if (Ch in ['1'..'9']) then
    begin
      Value := Ord(Ch) - Ord('0');
      Result := True;
    end;
  end;
end;

{ TScratchForm }

procedure TScratchForm.FormActivate(Sender: TObject);
begin
  Self.OnActivate := nil;
  ScratchGrid.ClientWidth := 9 * ScratchGrid.DefaultColWidth;
  ScratchGrid.ClientHeight := 9 * ScratchGrid.DefaultRowHeight;
  //writeln(format('ScratchGrid: %d x %d',[ScratchGrid.ClientWidth,ScratchGrid.ClientHeight]));
  ClientWidth := 2 * ScratchGrid.Left + ScratchGrid.Width;
  //writeln(format('btnCopy.Top: %d, btnCopy.Height: %d',[btnCopy.Top,btnCopy.Height]));
  Self.ReAlign;
  //ClientHeight := btnCopy.Top + btnCopy.Height + 10;
  //Above doesn't work: at this time btnCopy.Top still holds designtime value, even when it's top is anchored to the grid
  ClientHeight := ScratchGrid.Top + ScratchGrid.Height + 10 + btnCopy.Height + 10 + btnCopyRaw.Height + 10;
  btnCopy.AutoSize := False;
  btnCopy.Width := btnCopyRaw.Width;
  //writeln(format('ClientHeight: %d',[ClientHeight]));
  KeepInView;
end;

procedure TScratchForm.btnCopyClick(Sender: TObject);
var
  Values: TValues;
begin
  if Assigned(FOnCopyValues) then
  begin
    GridToValues(Values);
    FOnCopyValues(Self, Values);
    ModalResult := mrOk;
    //Close;
  end;
end;

procedure TScratchForm.btnCopyRawClick(Sender: TObject);
var
  ARawData: TRawGrid;
begin
  if Assigned(FOnCopyRawData) then
  begin
    GridToRawData(ARawData);
    FOnCopyRawData(Self, ARawData);
    ModalResult := mrOk;
    //Close;
  end;
end;

procedure TScratchForm.FormCreate(Sender: TObject);
var
  DefWH: Integer;
begin
  DefWH := Max(ScratchGrid.Canvas.TextWidth(' 8-8-8 '), 3 * ScratchGrid.Canvas.TextHeight('8')) + 10;
  ScratchGrid.DefaultColWidth := DefWH;
  ScratchGrid.DefaultRowHeight := DefWH;
end;

procedure TScratchForm.ScratchGridClick(Sender: TObject);
var
  Col, Row: Integer;
begin
  Col := ScratchGrid.Col;
  Row := ScratchGrid.Row;
  if not FRawData[Col+1,Row+1].Locked then
    EditCell(Col, Row);
end;

procedure TScratchForm.ScratchGridPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
var
  NeedsColor: Boolean;
  GridTextStyle: TTextStyle;
begin
  GridTextStyle := (Sender as TStringGrid).Canvas.TextStyle;
  GridTextStyle.Alignment := taCenter;
  GridTextStyle.Layout := tlCenter;
  GridTextStyle.SingleLine := False;
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
  //if (aRow=0) and (aCol=0) then
  if FRawData[aCol+1, aRow+1].Locked then
  begin
    (Sender as TStringGrid).Canvas.Brush.Color := $00F8E3CB; // $00F1CEA3;
    (Sender as TStringGrid).Canvas.Font.Color := clRed;
    (Sender as TStringGrid).Canvas.Font.Style := [fsBold]
  end;
end;

procedure TScratchForm.SetRawData(Data: TRawGrid);
var
  Row, Col: Integer;
  S: String;
begin
  FRawData := Data;
  for Col := 1 to 9 do
  begin
    for Row := 1 to 9 do
    begin
      //writeln('Col: ',Col,', Row: ',Row,', Square: ',DbgS(Data[Col,Row]));
      if Data[Col,Row].Locked then
        S := IntToStr(Data[Col,Row].Value)
      else
        //S := DbgS(Data[Col,Row].DigitsPossible);
        S := DigitSetToStr(Data[Col,Row].DigitsPossible);
      ScratchGrid.Cells[Col-1,Row-1] := S;
    end;
  end;
end;

procedure TScratchForm.GridToRawData(out RawData: TRawGrid);
var
  Col, Row: Integer;
  ADigit: TDigits;
  DigitSet: TDigitSet;
  S: String;
begin
  for Col := 0 to 8 do
  begin
    for Row := 0 to 8 do
    begin
      S := ScratchGrid.Cells[Col, Row];
      if TryCellTextToDigit(S, ADigit) then
      begin
        RawData[Col+1,Row+1].Value := ADigit;
        RawData[Col+1,Row+1].DigitsPossible := [];
        RawData[Col+1,Row+1].Locked := True;
      end
      else
      begin
        DigitSet := StrToDigitSet(S);
        RawData[Col+1,Row+1].Value := 0;
        RawData[Col+1,Row+1].DigitsPossible := DigitSet;
        RawData[Col+1,Row+1].Locked := False;
      end;
    end;
  end;
end;

procedure TScratchForm.GridToValues(out Values: TValues);
var
  Col, Row: Integer;
  AValue: TDigits;
  S: String;
begin
  Values := Default(TValues);
  for Col := 0 to 8 do
  begin
    for Row := 0 to 8 do
    begin
      S := ScratchGrid.Cells[Col, Row];
      //DigitSet := StrToDigitSet(S);
      if Length(S) >= 1 then
      begin
        if TryCellTextToDigit(S, AValue) then
          Values[Col + 1, Row + 1] := AValue;
      end;
    end;
  end;
end;

procedure TScratchForm.KeepInView;
var
  SW, FR, Diff, FL: Integer;
begin
  SW := Screen.Width;
  FR := Left + Width + 8;
  FL := Left;
  Diff := FR - SW;
  if (Diff > 0) then FL := Left - Diff;
  if (FL < 0) then FL := 0;
  Left := FL;
end;

procedure TScratchForm.EditCell(ACol, ARow: Integer);
var
  S: String;
  CurrentDigitSet: TDigitSet;
begin
  S := ScratchGrid.Cells[ACol, ARow];
  CurrentDigitSet := StrToDigitSet(S);
  DigitSetEditorForm.OriginalDigitsPossible := FRawData[ACol+1,ARow+1].DigitsPossible; //always set this first
  DigitSetEditorForm.CurrentDigitSet := CurrentDigitSet;
  DigitSetEditorForm.Top := Top;
  DigitSetEditorForm.PreferredRight := Left;
  if (DigitSetEditorForm.ShowModal = mrOK) then
  begin
    S := DigitSetToStr(DigitSetEditorForm.CurrentDigitSet);
    ScratchGrid.Cells[ACol, ARow] := S;
  end;
end;

end.

