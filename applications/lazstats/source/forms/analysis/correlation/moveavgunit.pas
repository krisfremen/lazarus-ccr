unit MoveAvgUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Grids,
  Globals, ContextHelpUnit;

type

  { TMoveAvgFrm }

  TMoveAvgFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    CancelBtn: TButton;
    OKBtn: TButton;
    OrderEdit: TEdit;
    Label1: TLabel;
    WeightGrid: TStringGrid;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure OrderEditEditingDone(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure WeightGridEditingDone(Sender: TObject);
    procedure WeightGridSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  private
    { private declarations }
    FOrder: Integer;
    FWeights: DblDyneVec;
    FRawWeights: DblDyneVec;
    function GetRawWeights: DblDyneVec;
    procedure NormalizeWeights;
    procedure SetOrder(AValue: Integer);
    procedure SetRawWeights(const AValue: DblDyneVec);
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
    property RawWeights: DblDyneVec read GetRawWeights write SetRawWeights;
    property Weights: DblDyneVec read FWeights;
    property Order: Integer read FOrder write SetOrder;

  end; 

var
  MoveAvgFrm: TMoveAvgFrm;

implementation

uses
  Math;

{ TMoveAvgFrm }

procedure TMoveAvgFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, ResetBtn.Width, CancelBtn.Width, OKBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  OKBtn.Constraints.MinWidth := w;
end;

procedure TMoveAvgFrm.FormCreate(Sender: TObject);
begin
  ResetBtnClick(self);
end;

function TMoveAvgFrm.GetRawWeights: DblDyneVec;
var
  r: Integer;
begin
  SetLength(Result, WeightGrid.RowCount - 1);
  for r := 1 to WeightGrid.RowCount - 1 do
    if WeightGrid.cells[1, r] = '' then
      Result[r-1] := 0.0
    else
      Result[r-1] := StrToFloat(WeightGrid.Cells[1, r]);
end;

procedure TMoveAvgFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

// Normalize all values so that their sum 1.
// (Except for center weight w[0] which must remain 1.0)
procedure TMoveAvgFrm.NormalizeWeights;
var
  sum, x: double;
  r: integer;
begin
  if WeightGrid.RowCount = 1 then
    exit;

  r := 1;
  if not TryStrToFloat(WeightGrid.Cells[1, r], sum) then
    sum := 0;
  for r := 2 to WeightGrid.RowCount-1 do
    if TryStrToFloat(WeightGrid.Cells[1, r], x) then
      sum := sum + x * 2;

  if sum = 0 then
  begin
    FWeights[0] := 1.0;
    for r := 1 to FOrder do Weights[r] := 0;
  end else
    for r := 1 to WeightGrid.RowCount-1 do
    begin
      if not TryStrToFloat(WeightGrid.Cells[1, r], x) then x := 0;
      FWeights[r-1] := x / sum;
    end;

  for r := 1 to WeightGrid.RowCount-1 do
    WeightGrid.Cells[2, r] := FormatFloat('0.000', FWeights[r-1]);
end;

procedure TMoveAvgFrm.OKBtnClick(Sender: TObject);
var
  msg: String;
  C: TWinControl;
begin
  if not Validate(msg, C) then
  begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    ModalResult := mrNone;
    exit;
  end;
  NormalizeWeights;
end;

procedure TMoveAvgFrm.OrderEditEditingDone(Sender: TObject);
var
  n: Integer;
begin
  if TryStrToInt(OrderEdit.Text, n) then
    SetOrder(n);
end;

procedure TMoveAvgFrm.ResetBtnClick(Sender: TObject);
begin
  SetOrder(FOrder);
end;

procedure TMoveAvgFrm.SetOrder(AValue: Integer);
var
  i: Integer;
begin
  FOrder := AValue;
  SetLength(FWeights, FOrder + 1);
  OrderEdit.Text := IntToStr(FOrder);
  WeightGrid.RowCount := Length(FWeights) + WeightGrid.FixedRows;
  WeightGrid.Cells[0, 1] := '0 (center)';
  for i := 2 to WeightGrid.RowCount-1 do
    WeightGrid.Cells[0, i] := IntToStr(i-1);
  NormalizeWeights;
end;

procedure TMoveAvgFrm.SetRawWeights(const AValue: DblDyneVec);
var
  r: Integer;
begin
  FRawWeights := AValue;
  if Length(FRawWeights) > FOrder+1 then
    SetOrder(Length(FRawWeights) - 1);
  for r := 1 to WeightGrid.RowCount-1 do
    if r-1 < Length(FRawWeights) then
      WeightGrid.Cells[1, r] := Format('%.3g', [FRawWeights[r-1]])
    else
      WeightGrid.Cells[1, r] := '';
  NormalizeWeights;
end;

function TMoveAvgFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
  x: Double;
begin
  Result := false;

  if OrderEdit.Text = '' then
  begin
    AControl := OrderEdit;
    AMsg := 'Input required.';
    exit;
  end;
  if not TryStrToInt(OrderEdit.Text, n) or (n < 0) then
  begin
    AControl := OrderEdit;
    AMsg := 'Non-negative integer value required.';
    exit;
  end;

  for n := 1 to WeightGrid.RowCount-1 do
  begin
    if WeightGrid.Cells[1, n] = '' then
    begin
      AMsg := 'Input required.';
      WeightGrid.Row := n;
      WeightGrid.Col := 1;
      AControl := WeightGrid;
      exit;
    end;
    if not TryStrToFloat(WeightGrid.Cells[1, n], x) then
    begin
      AMsg := 'Number required.';
      WeightGrid.Row := n;
      WeightGrid.Col := 1;
      AControl := WeightGrid;
      exit;
    end;
  end;

  Result := true;
end;

procedure TMoveAvgFrm.WeightGridEditingDone(Sender: TObject);
begin
  NormalizeWeights;
end;

procedure TMoveAvgFrm.WeightGridSelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  if ACol = 2 then
    Editor := nil;
end;

initialization
  {$I moveavgunit.lrs}

end.

