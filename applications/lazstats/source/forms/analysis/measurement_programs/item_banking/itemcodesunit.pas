unit ItemCodesUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  OutputUnit;

type

  { TCodesForm }

  TCodesForm = class(TForm)
    Bevel1: TBevel;
    EditOneBtn: TButton;
    Memo1: TLabel;
    ReturnBtn: TButton;
    DisplayBtn: TButton;
    StartNewBtn: TButton;
    SaveCodeBtn: TButton;
    DescLabel: TLabel;
    DescriptionEdit: TEdit;
    MinorEdit: TEdit;
    MinorLabel: TLabel;
    MajorEdit: TEdit;
    ItemNoEdit: TEdit;
    ItemNoLabel: TLabel;
    MajorLabel: TLabel;
    procedure EditOneBtnClick(Sender: TObject);
    procedure DisplayBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
    procedure SaveCodeBtnClick(Sender: TObject);
    procedure StartNewBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end;

var
  CodesForm: TCodesForm;

implementation

uses
  ItemBankingUnit;

{ TCodesForm }

procedure TCodesForm.SaveCodeBtnClick(Sender: TObject);
var
  currentno: integer;
begin
  currentno := StrToInt(ItemNoEdit.Text);
  if currentno > ItemBankFrm.BankInfo.NCodes then
    ItemBankFrm.BankInfo.NCodes := currentno;

  ItemBankFrm.NItemCodesText.Text := IntToStr(currentno);
  ItemBankFrm.CodesInfo[currentno].codenumber := currentno;
  ItemBankFrm.CodesInfo[currentno].majorcodes := StrToInt(MajorEdit.Text);
  ItemBankFrm.CodesInfo[currentno].minorcodes := StrToInt(MinorEdit.Text);
  ItemBankFrm.CodesInfo[currentno].Description := DescriptionEdit.Text;
end;

procedure TCodesForm.DisplayBtnClick(Sender: TObject);
var
  currentno: integer;
  i: integer;
  lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
    lReport.Add('Current Item Codes');
    lReport.Add('');

    currentno := ItemBankFrm.BankInfo.NCodes;
    for i := 1 to currentno do
    begin
      lReport.Add('Item number %d', [ItemBankFrm.CodesInfo[i].codenumber]);
      lReport.Add('Major Code  %d', [ItemBankFrm.CodesInfo[i].majorcodes]);
      lReport.Add('Minor Code  %d', [ItemBankFrm.CodesInfo[i].minorcodes]);
      lReport.Add('Description %s', [ItemBankFrm.CodesInfo[i].Description]);
      lReport.Add('');
    end;
    DisplayReport(lReport);
  finally
     lReport.Free;
  end;
end;

procedure TCodesForm.EditOneBtnClick(Sender: TObject);
var
  response: string;
  codeno: integer;
begin
  response := InputBox('Code Number:','Number:', '1');
  codeno := StrToInt(response);
  if codeno <= ItemBankFrm.BankInfo.NCodes then
  begin
    ItemNoEdit.Text := IntToStr(ItemBankFrm.CodesInfo[codeno].codenumber);
    MajorEdit.Text := IntToStr(ItemBankFrm.CodesInfo[codeno].majorcodes);
    MinorEdit.Text := IntToStr(ItemBankFrm.CodesInfo[codeno].minorcodes);
    DescriptionEdit.Text := ItemBankFrm.CodesInfo[codeno].Description;
  end;
end;

procedure TCodesForm.FormActivate(Sender: TObject);
begin
  if FAutoSized then
    exit;
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
  FAutoSized := true;
end;

procedure TCodesForm.FormCreate(Sender: TObject);
begin
  Assert(ItemBankFrm <> nil);
end;

procedure TCodesForm.FormShow(Sender: TObject);
var
  ncodes: integer;
begin
  if ItemBankFrm.NItemCodesText.Text <> '' then
  begin
    ncodes := StrToInt(ItemBankFrm.NItemCodesText.Text);
    ItemNoEdit.Text := IntToStr(ItemBankFrm.CodesInfo[ncodes].codenumber);
    MajorEdit.Text := IntToStr(ItemBankFrm.CodesInfo[ncodes].majorcodes) ;
    MinorEdit.Text := IntToStr(ItemBankFrm.CodesInfo[ncodes].minorcodes);
    DescriptionEdit.Text := ItemBankFrm.CodesInfo[ncodes].Description;
  end else
  begin
    ItemNoEdit.Text := '1';
    MajorEdit.Text := '1';
    MinorEdit.Text := '0';
    DescriptionEdit.Text := '';
  end;
end;

procedure TCodesForm.ReturnBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TCodesForm.StartNewBtnClick(Sender: TObject);
var
  currentno: integer;
  newnumber: integer;
begin
  currentno := StrToInt(ItemNoEdit.Text);
  newnumber := currentno + 1;
  ItemNoEdit.Text := IntToStr(newnumber);
  currentno := StrToInt(MinorEdit.Text);
  newnumber := currentno + 1;
  MinorEdit.Text := IntToStr(newnumber);
  DescriptionEdit.Text := '';
  if newnumber > StrToInt(ItemBankFrm.NItemCodesText.Text) then
  begin
    ItemBankFrm.NItemCodesText.Text := IntToStr(newnumber);
    ItemBankFrm.CodesInfo[newnumber].codenumber := newnumber;
  end;
end;


initialization
  {$I itemcodesunit.lrs}

end.

