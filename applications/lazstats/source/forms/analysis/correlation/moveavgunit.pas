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
    Panel1: TPanel;
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
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure OrderEditKeyPress(Sender: TObject; var Key: char);
    procedure ResetBtnClick(Sender: TObject);
    procedure ThetaEditKeyPress(Sender: TObject; var Key: char);
    procedure ThetaListClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    W : array[0..20] of double;
    order : integer;
    currentindex : integer;

  end; 

var
  MoveAvgFrm: TMoveAvgFrm;

implementation

{ TMoveAvgFrm }

procedure TMoveAvgFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
    OrderEdit.Text := '';
    ThetaEdit.Text := '';
    ThetaList.Clear;
    currentindex := 0;
    for i := 0 to 20 do W[i] := 1.0;
end;

procedure TMoveAvgFrm.ThetaEditKeyPress(Sender: TObject; var Key: char);
var cellstring : string;

begin
    if currentindex < 1 then exit;
    if ord(Key) <> 13 then exit;
    cellstring := 'Theta(' + IntToStr(currentindex + 1) + ') = ';
    cellstring := cellstring + ThetaEdit.Text;
    W[currentindex + 1] := StrToFloat(ThetaEdit.Text);
end;

procedure TMoveAvgFrm.ThetaListClick(Sender: TObject);
VAR index : integer;
begin
    index := ThetaList.ItemIndex;
    if index < 0 then exit;
    currentindex := index;
    ThetaEdit.Text := '1.0';
    ThetaEdit.SetFocus;
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

procedure TMoveAvgFrm.ApplyBtnClick(Sender: TObject);
var
    sum : double;
    i : integer;
    cellstring : string;

begin
    ThetaList.Clear;
    sum := W[0];
    for i := 1 to order do sum := sum + (2.0 * W[i]);
    for i := 0 to order do
    begin
        W[i] := W[i] / sum;
        cellstring := 'Theta(' + IntToStr(i+1) + ') = ';
        cellstring := cellstring + FloatToStr(W[i]);
        ThetaList.Items.Add(cellstring);
    end;
end;

procedure TMoveAvgFrm.OrderEditKeyPress(Sender: TObject; var Key: char);
VAR    cellstring : string;
    i : integer;

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

initialization
  {$I moveavgunit.lrs}

end.

