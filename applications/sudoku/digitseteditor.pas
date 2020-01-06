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
    procedure FormActivate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
  private
    FPreferredRight: Integer;
    function GetDigitSet: TDigitSet;
    procedure SetDigitSet(ASet: TDigitSet);
    procedure SetRight({%H-}Data: PtrInt);

  public
    property DigitSet: TDigitSet read GetDigitSet write SetDigitSet;
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
    DigitCG.Checked[Pred(Digit)] := not DigitCG.Checked[Pred(Digit)];
    Key := #0;
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

function TDigitSetEditorForm.GetDigitSet: TDigitSet;
var
  i: Integer;
begin
  Result := [];
  for i := 0 to DigitCG.Items.Count - 1 do
    if DigitCG.Checked[i] then Include(Result, Succ(i));
end;

procedure TDigitSetEditorForm.SetDigitSet(ASet: TDigitSet);
var
  D: TDigits;
begin
  for D in TDigits do
  begin
    DigitCG.Checked[D-1] := (D in ASet);  //don't use Pred(D) here, gives RangeCheckError when D=1
  end;
end;

procedure TDigitSetEditorForm.SetRight(Data: PtrInt);
begin
  Left := FPreferredRight - Width;
end;

end.

