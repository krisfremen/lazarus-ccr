unit DigitSetEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  SudokuType;

type

  { TDigitSetEditorForm }

  TDigitSetEditorForm = class(TForm)
    btnOK: TButton;
    DigitCG: TCheckGroup;
    procedure DigitCGItemClick(Sender: TObject; {%H-}Index: integer);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
  private
    FPreferredRight: Integer;
    FOriginalDigitsPossible: TDigitSet;
    function GetCurrentDigitSet: TDigitSet;
    procedure SetCurrentDigitSet(ASet: TDigitSet);
    procedure SetOriginalDigitsPossible(ASet: TDigitSet);
    procedure SetRight({%H-}Data: PtrInt);
    procedure UpdateButtonState;

  public
    property CurrentDigitSet: TDigitSet read GetCurrentDigitSet write SetCurrentDigitSet;
    property OriginalDigitsPossible: TDigitSet read FOriginalDigitsPossible write SetOriginalDigitsPossible;  //set this before CurrentDigitSet!
    property PreferredRight: Integer read FPreferredRight write FPreferredRight;
  end;

var
  DigitSetEditorForm: TDigitSetEditorForm;

implementation

{$R *.lfm}

{ TDigitSetEditorForm }

procedure TDigitSetEditorForm.FormKeyPress(Sender: TObject; var Key: char);
var
  Digit: Integer;
begin
  if (Key in ['1'..'9']) then
  begin
    Digit := Ord(Key) - Ord('0');
    if Digit in FOriginalDigitsPossible then
      DigitCG.Checked[Pred(Digit)] := not DigitCG.Checked[Pred(Digit)];
    Key := #0;
    UpdateButtonState;
  end;
  if (Key = #27) then //escape
  begin
    Key := #0;
    ModalResult := mrCancel;
  end;
end;

procedure TDigitSetEditorForm.FormShow(Sender: TObject);
begin
  Application.QueueAsyncCall(@SetRight, FPreferredRight)
end;

procedure TDigitSetEditorForm.FormActivate(Sender: TObject);
begin
  OnACtivate := nil;
  ClientWidth := 2 * DigitCG.Left + DigitCG.Width;
  ClientHeight := btnOK.Top + btnOK.Height + DigitCG.Top;
end;


procedure TDigitSetEditorForm.DigitCGItemClick(Sender: TObject; Index: integer);
begin
  UpdateButtonState;
end;


function TDigitSetEditorForm.GetCurrentDigitSet: TDigitSet;
var
  i: Integer;
begin
  Result := [];
  for i := 0 to DigitCG.Items.Count - 1 do
    if DigitCG.Checked[i] and (Succ(i) in FOriginalDigitsPossible)then Include(Result, Succ(i));
end;

procedure TDigitSetEditorForm.SetCurrentDigitSet(ASet: TDigitSet);
var
  D: TDigits;
begin
  for D in TDigits do
  begin
    DigitCG.Checked[D-1] := (D in ASet) and DigitCG.CheckEnabled[D-1];  //don't use Pred(D) here, gives RangeCheckError when D=1
  end;
end;

procedure TDigitSetEditorForm.SetOriginalDigitsPossible(ASet: TDigitSet);
var
  D: TDigits;
begin
  if FOriginalDigitsPossible = ASet then Exit;
  FOriginalDigitsPossible := ASet;
  for D in TDigits do
  begin
    DigitCG.CheckEnabled[D-1] := (D in ASet);  //don't use Pred(D) here, gives RangeCheckError when D=1
  end;
end;

procedure TDigitSetEditorForm.SetRight(Data: PtrInt);
begin
  Left := FPreferredRight - Width;
end;

procedure TDigitSetEditorForm.UpdateButtonState;
begin
  btnOk.Enabled := (GetCurrentDigitSet <> []);
end;

end.

