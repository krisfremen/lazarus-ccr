unit MoveAvgUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  ContextHelpUnit;

type

  { TMoveAvgFrm }

  TMoveAvgFrm = class(TForm)
    HelpBtn: TButton;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    OKBtn: TButton;
    ThetaList: TListBox;
    ThetaEdit: TEdit;
    Label2: TLabel;
    OrderEdit: TEdit;
    Label1: TLabel;
    procedure ApplyBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure OrderEditEditingDone(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure ThetaEditEditingDone(Sender: TObject);
    procedure ThetaListClick(Sender: TObject);
  private
    { private declarations }
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
    W: array[0..20] of double;
    order : integer;
    currentindex : integer;

  end; 

var
  MoveAvgFrm: TMoveAvgFrm;

implementation

uses
  Math;

{ TMoveAvgFrm }

procedure TMoveAvgFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  OrderEdit.Text := '';
  ThetaEdit.Text := '';
  ThetaList.Clear;
  CurrentIndex := 0;
  for i := 0 to 20 do W[i] := 1.0;
end;

procedure TMoveAvgFrm.ThetaEditEditingDone(Sender: TObject);
var
  cellString: String;
begin
  if CurrentIndex < 1 then
    exit;
  cellString := Format('Theta(%d) = %s', [currentIndex + 1, ThetaEdit.Text]);
  ThetaList.Items[CurrentIndex] := cellString;
  W[currentIndex + 1] := StrToFloat(ThetaEdit.Text);
end;
                        (*
procedure TMoveAvgFrm.ThetaEditKeyPress(Sender: TObject; var Key: char);
var
  cellstring: string;
begin
  if currentindex < 1 then exit;
  if ord(Key) <> 13 then exit;
  cellstring := 'Theta(' + IntToStr(currentindex + 1) + ') = ' + ThetaEdit.Text;
  W[currentindex + 1] := StrToFloat(ThetaEdit.Text);
end;                      *)

procedure TMoveAvgFrm.ThetaListClick(Sender: TObject);
var
  index: integer;
begin
  index := ThetaList.ItemIndex;
  if index >= 0 then
  begin
    currentindex := index;
    ThetaEdit.Text := '1.0';
    ThetaEdit.SetFocus;
  end;
end;

procedure TMoveAvgFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TMoveAvgFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
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
  end;
end;

procedure TMoveAvgFrm.ApplyBtnClick(Sender: TObject);
var
  sum: double;
  i: integer;
  cellstring: string;
begin
  ThetaList.Clear;
  sum := W[0];
  for i := 1 to order do
    sum := sum + 2.0 * W[i];
  for i := 0 to order do
  begin
    W[i] := W[i] / sum;
    cellstring := 'Theta(' + IntToStr(i+1) + ') = ' + FloatToStr(W[i]);
    ThetaList.Items.Add(cellstring);
  end;
end;

procedure TMoveAvgFrm.FormActivate(Sender: TObject);
var
  wid: Integer;
begin
  wid := MaxValue([HelpBtn.Width, ResetBtn.Width, ApplyBtn.Width, CancelBtn.Width, OKBtn.Width]);
  HelpBtn.Constraints.MinWidth := wid;
  ResetBtn.Constraints.MinWidth := wid;
  ApplyBtn.Constraints.MinWidth := wid;
  CancelBtn.Constraints.MinWidth := wid;
  OKBtn.Constraints.MinWidth := wid;
end;

procedure TMoveAvgFrm.OrderEditEditingDone(Sender: TObject);
var
  i: Integer;
begin
  ThetaList.Items.BeginUpdate;
  try
    ThetaList.Clear;
    Order := StrToInt(orderEdit.Text);
    for i := 1 to Order do
      ThetaList.Items.Add('Theta(' + IntToStr(i) + ')');
  finally
    ThetaList.Items.EndUpdate;
  end;
end;

           (*
procedure TMoveAvgFrm.OrderEditKeyPress(Sender: TObject; var Key: char);
var
  cellstring: string;
  i: integer;
begin
  if ord(Key) <> 13 then exit;
  ThetaList.Clear;
  order := StrToInt(OrderEdit.Text);
  for i := 1 to order do
  begin
    cellstring := 'Theta(' + IntToStr(i) + ')';
    ThetaList.Items.Add(cellstring);
  end;
end;
*)

function TMoveAvgFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
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

  if ThetaEdit.Text <> '' then
  begin
    AControl := ThetaEdit;
    AMsg := 'Please press ENTER to add this input.';
    exit;
  end;

  Result := true;
end;

initialization
  {$I moveavgunit.lrs}

end.

