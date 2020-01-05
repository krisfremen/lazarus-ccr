unit ScratchPad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls,
  SudokuType;

type

  { TScratchForm }

  TCopyValuesEvent = procedure(Sender: TObject; Values: TValues) of Object;

  TScratchForm = class(TForm)
    btnCopy: TButton;
    ScratchGrid: TStringGrid;
    procedure btnCopyClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FRawData: TRawGrid;
    FOnCopyValues: TCopyValuesEvent;
    procedure SetRawData(Data: TRawGrid);
    procedure GridToValues(out Values: TValues);
    procedure KeepInView;
  public
    property RawData: TRawGrid write SetRawData;
    property OnCopyValues: TCopyValuesEvent read FOnCopyValues write FOnCopyValues;
  end;

var
  ScratchForm: TScratchForm;

implementation

{$R *.lfm}

function DbgS( ASet: TDigitSet): String; overload;
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

{ TScratchForm }

procedure TScratchForm.FormActivate(Sender: TObject);
begin
  Self.OnActivate := nil;
  ScratchGrid.ClientWidth := 9 * ScratchGrid.DefaultColWidth;
  ScratchGrid.ClientHeight := 9 * ScratchGrid.DefaultRowHeight;
  ClientWidth := 2 * ScratchGrid.Left + ScratchGrid.Width;
  ClientHeight := btnCopy.Top + btnCopy.Height + 10;
  KeepInView;
end;

procedure TScratchForm.btnCopyClick(Sender: TObject);
var
  Values: TValues;
begin
  if not Assigned(FOnCopyValues) then Exit;
  GridToValues(Values);
  FOnCopyValues(Self, Values);
  Close;
end;

procedure TScratchForm.FormCreate(Sender: TObject);
begin
  ScratchGrid.DefaultColWidth := ScratchGrid.Canvas.TextWidth(' [1,2,3,4,5,6,7,8,9] ') + 8;
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
        S := DbgS(Data[Col,Row].DigitsPossible);
      ScratchGrid.Cells[Col-1,Row-1] := S;
    end;
  end;
end;

procedure TScratchForm.GridToValues(out Values: TValues);
var
  Col, Row: Integer;
  AValue: Longint;
  S: String;
begin
  Values := Default(TValues);
  for Col := 0 to 8 do
  begin
    for Row := 0 to 8 do
    begin
      S := ScratchGrid.Cells[Col, Row];
      if Length(S) >= 1 then
      begin
        if TryStrToInt(S, AValue) then
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

end.

