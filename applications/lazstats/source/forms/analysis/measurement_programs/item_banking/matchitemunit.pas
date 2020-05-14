unit MatchItemUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ExtDlgs, OutputUnit;

type

  { TMatchItemForm }

  TMatchItemForm = class(TForm)
    AnswerEdit: TEdit;
    Bevel1: TBevel;
    Bevel2: TBevel;
    CodeBrowseBtn: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    ItemCodeLabel: TLabel;
    Left1Edit: TEdit;
    Left2Edit: TEdit;
    Left5Edit: TEdit;
    Left4Edit: TEdit;
    Left3Edit: TEdit;
    MajorCodeEdit: TEdit;
    Memo1: TLabel;
    MinorCodeEdit: TEdit;
    MinorCodeLabel: TLabel;
    Right1Edit: TEdit;
    Right5Edit: TEdit;
    Right4Edit: TEdit;
    Right3Edit: TEdit;
    Right2Edit: TEdit;
    Image1: TImage;
    ItemSaveBtn: TButton;
    jpegBrowseBtn: TButton;
    jpeglabel: TLabel;
    jpegnameEdit: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    PreviousBtn: TButton;
    ReturnBtn: TButton;
    SelectImageBtn: TButton;
    ShowNextBtn: TButton;
    StartNewBtn: TButton;
    ItemNoEdit: TEdit;
    TFItemNoLabel: TLabel;
    procedure CodeBrowseBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ItemSaveBtnClick(Sender: TObject);
    procedure jpegBrowseBtnClick(Sender: TObject);
    procedure PreviousBtnClick(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
    procedure SelectImageBtnClick(Sender: TObject);
    procedure ShowNextBtnClick(Sender: TObject);
    procedure StartNewBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  MatchItemForm: TMatchItemForm;

implementation

uses
  Utils, ItemBankingUnit;

{ TMatchItemForm }

procedure TMatchItemForm.jpegBrowseBtnClick(Sender: TObject);
VAR
  JPEG: TJPEGImage;
begin
  OpenPictureDialog1.Options := OpenPictureDialog1.Options+[ofFileMustExist];
  if not OpenPictureDialog1.Execute then
    exit;

  try
    JPEG := TJPEGImage.Create;
    try
      JPEG.LoadFromFile(OpenPictureDialog1.FileName);
      Image1.Picture.Assign(JPEG);
    finally
      JPEG.Free;
    end;
  except
    on E: Exception do begin
      Image1.Picture.Clear;
      ErrorMsg(E.Message);
    end;
  end;
  Image1.Proportional := true;
end;

procedure TMatchItemForm.PreviousBtnClick(Sender: TObject);
Var
  response: string;
  itemno: integer;
  JPEG: TJPEGImage;
  noleft, noright: integer;
begin
  response := InputBox('Code Number:', 'Number:', '1');
  itemno := StrToInt(response);
  if itemno <= ItemBankFrm.BankInfo.NMatchItems then
  begin
    Image1.Canvas.Clear;
    ItemNoEdit.Text := IntToStr(ItemBankFrm.MatchInfo[itemno].ItemNumber);
    MajorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[itemno].majorcode);
    MinorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[itemno].minorcode);
    noleft := ItemBankFrm.MatchInfo[itemno].NLeft;
    noright := ItemBankFrm.MatchInfo[itemno].NRight;
    if noleft > 0 then Left1Edit.Text := ItemBankFrm.MatchInfo[itemno].Left1;
    if noleft > 1 then Left2Edit.Text := ItemBankFrm.MatchInfo[itemno].Left2;
    if noleft > 2 then Left3Edit.Text := ItemBankFrm.MatchInfo[itemno].Left3;
    if noleft > 3 then Left4Edit.Text := ItemBankFrm.MatchInfo[itemno].Left4;
    if noleft > 4 then Left5Edit.Text := ItemBankFrm.MatchInfo[itemno].Left5;
    if noright > 0 then Right1Edit.Text := ItemBankFrm.MatchInfo[itemno].Right1;
    if noright > 1 then Right2Edit.Text := ItemBankFrm.MatchInfo[itemno].Right2;
    if noright > 2 then Right3Edit.Text := ItemBankFrm.MatchInfo[itemno].Right3;
    if noright > 3 then Right4Edit.Text := ItemBankFrm.MatchInfo[itemno].Right4;
    if noright > 4 then Right5Edit.Text := ItemBankFrm.MatchInfo[itemno].Right5;
    AnswerEdit.Text := ItemBankFrm.MatchInfo[itemno].CorrectChoice;
    jpegnameEdit.Text := ItemBankFrm.MatchInfo[itemno].PicName;
    if (jpegnameEdit.Text <> 'none') and FileExists(jpegnameEdit.Text) then
    begin
      JPEG := TJPEGImage.Create;
      try
        JPEG.LoadFromFile(jpegnameEdit.Text);
        Image1.Picture.Assign(JPEG);
      finally
        JPEG.Free;
        Image1.Proportional := true;
      end;
    end else
      Image1.Picture.Clear;
  end;
end;

procedure TMatchItemForm.ReturnBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMatchItemForm.ItemSaveBtnClick(Sender: TObject);
var
  currentno: integer;
  count: integer;
  noleft, noright: integer;
begin
  count := ItemBankFrm.BankInfo.NMatchItems;
  currentno := StrToInt(ItemNoEdit.Text);
  noleft := 0;
  if Left1Edit.Text <> '' then noleft := noleft + 1;
  if Left2Edit.Text <> '' then noleft := noleft + 1;
  if Left3Edit.Text <> '' then noleft := noleft + 1;
  if Left4Edit.Text <> '' then noleft := noleft + 1;
  if Left5Edit.Text <> '' then noleft := noleft + 1;
  noright := 0;
  if Right1Edit.Text <> '' then noright := noright + 1;
  if Right2Edit.Text <> '' then noright := noright + 1;
  if Right3Edit.Text <> '' then noright := noright + 1;
  if Right4Edit.Text <> '' then noright := noright + 1;
  if Right5Edit.Text <> '' then noright := noright + 1;
  if currentno > count then
  begin
    ItemBankFrm.BankInfo.NMatchItems := currentno;
    ItemBankFrm.NEssayText.Text := IntToStr(currentno);
  end;
  ItemBankFrm.MatchInfo[currentno].ItemNumber := currentno;
  ItemBankFrm.MatchInfo[currentno].majorcode := StrToInt(MajorCodeEdit.Text);
  ItemBankFrm.MatchInfo[currentno].minorcode := StrToInt(MinorCodeEdit.Text);
  ItemBankFrm.MatchInfo[currentno].NLeft := noleft;
  ItemBankFrm.MatchInfo[currentno].NRight := noright;
  if noleft > 0 then ItemBankFrm.MatchInfo[currentno].Left1 := Left1Edit.Text;
  if noleft > 1 then ItemBankFrm.MatchInfo[currentno].Left2 := Left2Edit.Text;
  if noleft > 2 then ItemBankFrm.MatchInfo[currentno].Left3 := Left3Edit.Text;
  if noleft > 3 then ItemBankFrm.MatchInfo[currentno].Left4 := Left4Edit.Text;
  if noleft > 4 then ItemBankFrm.MatchInfo[currentno].Left5 := Left5Edit.Text;
  if noright > 0 then ItemBankFrm.MatchInfo[currentno].Right1 := Right1Edit.Text;
  if noright > 1 then ItemBankFrm.MatchInfo[currentno].Right2 := Right2Edit.Text;
  if noright > 2 then ItemBankFrm.MatchInfo[currentno].Right3 := Right3Edit.Text;
  if noright > 3 then ItemBankFrm.MatchInfo[currentno].Right4 := Right4Edit.Text;
  if noright > 4 then ItemBankFrm.MatchInfo[currentno].Right5 := Right5Edit.Text;
  ItemBankFrm.MatchInfo[currentno].CorrectChoice := AnswerEdit.Text[1];
  ItemBankFrm.MatchInfo[currentno].PicName := jpegnameEdit.Text;
end;

procedure TMatchItemForm.FormShow(Sender: TObject);
var
  nitems: integer;
  noleft, noright: integer;
  JPEG: TJPEGImage;
begin
  Image1.Canvas.Clear;
  Left1Edit.Text := '';
  Left2Edit.Text := '';
  Left3Edit.Text := '';
  Left4Edit.Text := '';
  Left5Edit.Text := '';
  Right1Edit.Text := '';
  Right2Edit.Text := '';
  Right3Edit.Text := '';
  Right3Edit.Text := '';
  Right5Edit.Text := '';
  AnswerEdit.Text := '';

  if ItemBankFrm.BankInfo.NMatchItems  > 0 then
  begin
    nitems := ItemBankFrm.BankInfo.NMatchItems;
    ItemNoEdit.Text := '1'; //IntToStr(ItemBankFrm.TFItemInfo[1].ItemNumber);
    MajorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[1].majorcode) ;
    MinorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[1].minorcode);
    noleft := ItemBankFrm.MatchInfo[1].NLeft;
    if noleft > 0 then Left1Edit.Text := ItemBankFrm.MatchInfo[1].Left1 ;
    if noleft > 1 then Left2Edit.Text := ItemBankFrm.MatchInfo[1].Left2 ;
    if noleft > 2 then Left3Edit.Text := ItemBankFrm.MatchInfo[1].Left3 ;
    if noleft > 3 then Left4Edit.Text := ItemBankFrm.MatchInfo[1].Left4 ;
    if noleft > 4 then Left5Edit.Text := ItemBankFrm.MatchInfo[1].Left5 ;
    noright  := ItemBankFrm.MatchInfo[1].NRight;
    if noright > 0 then Right1Edit.Text := ItemBankFrm.MatchInfo[1].Right1 ;
    if noright > 1 then Right2Edit.Text := ItemBankFrm.MatchInfo[1].Right2 ;
    if noright > 2 then Right3Edit.Text := ItemBankFrm.MatchInfo[1].Right3 ;
    if noright > 3 then Right4Edit.Text := ItemBankFrm.MatchInfo[1].Right4 ;
    if noright > 4 then Right5Edit.Text := ItemBankFrm.MatchInfo[1].Right5 ;
    AnswerEdit.Text := ItemBankFrm.MatchInfo[1].CorrectChoice;
    jpegnameEdit.Text := ItemBankFrm.MatchInfo[1].PicName;
    if (jpegnameEdit.Text <> 'none') and FileExists(jpegNameEdit.Text) then
    begin
      JPEG := TJPEGImage.Create;
      try
        JPEG.LoadFromFile(jpegnameEdit.Text);
        Image1.Picture.Assign(JPEG);
      finally
        JPEG.Free;
        Image1.Proportional := true;
      end;
    end else
      Image1.Picture.Clear;
  end else
  begin
    ItemNoEdit.Text := '1';
    MajorCodeEdit.Text := '1';
    MinorCodeEdit.Text := '0';
    Left1Edit.Text := '';
    Left2Edit.Text := '';
    Left3Edit.Text := '';
    Left4Edit.Text := '';
    Left5Edit.Text := '';
    Right1Edit.Text := '';
    Right2Edit.Text := '';
    Right3Edit.Text := '';
    Right3Edit.Text := '';
    Right5Edit.Text := '';
    AnswerEdit.Text := '';
    jpegnameEdit.Text := 'none';
    Image1.Picture.Clear;
  end;
end;

procedure TMatchItemForm.CodeBrowseBtnClick(Sender: TObject);
var
  i: integer;
  noleft, noright: integer;
  lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
    lReport.Add('Current Items');
    lReport.Add('');

    for i := 1 to ItemBankFrm.BankInfo.NMatchItems do
    begin
      noleft := ItemBankFrm.MatchInfo[i].NLeft;
      noright := ItemBankFrm.MatchInfo[i].NRight;
      lReport.Add('Item number      %d',[ItemBankFrm.MatchInfo[i].itemnumber]);
      lReport.Add('Major Code       %d',[ItemBankFrm.MatchInfo[i].majorcode]);
      lReport.Add('Minor Code       %d',[ItemBankFrm.MatchInfo[i].minorcode]);
      lReport.Add('No. Left items:  %d', [ItemBankFrm.MatchInfo[i].NLeft]);
      lReport.Add('No. Right items: %d', [ItemBankFrm.MatchInfo[i].NRight]);
      if noleft > 0 then
        lReport.Add('Left Item 1      %s',[ItemBankFrm.MatchInfo[i].Left1]);
      if noright > 0 then
        lReport.Add('   Right Item 1  %s',[ItemBankFrm.MatchInfo[i].Right1]);
      if noleft > 1 then
        lReport.Add('Left Item 2      %s',[ItemBankFrm.MatchInfo[i].Left2]);
      if noright > 1 then
        lReport.Add('   Right Item 2  %s',[ItemBankFrm.MatchInfo[i].Right2]);
      if noleft > 2 then
        lReport.Add('Left Item 3      %s',[ItemBankFrm.MatchInfo[i].Left3]);
      if noright > 2 then
        lReport.Add('   Right Item 3  %s',[ItemBankFrm.MatchInfo[i].Right3]);
      if noleft > 3 then
        lReport.Add('Left Item 4      %s',[ItemBankFrm.MatchInfo[i].Left4]);
      if noright > 3 then
        lReport.Add('   Right Item 4  %s',[ItemBankFrm.MatchInfo[i].Right4]);
      if noleft > 4 then
        lReport.Add('Left Item 5      %s',[ItemBankFrm.MatchInfo[i].Left5]);
      if noright > 4 then
        lReport.Add('   Right Item 5  %s',[ItemBankFrm.MatchInfo[i].Right5]);
      lReport.Add('Correct Choice   %s',[ItemBankFrm.MatchInfo[i].CorrectChoice]);
      lReport.Add('Graphic Image    %s',[ItemBankFrm.MatchInfo[i].PicName]);
      lReport.Add('');
    end;
    DisplayReport(lReport);
  finally
    lReport.Free;
  end;
end;

procedure TMatchItemForm.FormActivate(Sender: TObject);
begin
  if FAutoSized then
    exit;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  FAutoSized := true;
end;

procedure TMatchItemForm.FormCreate(Sender: TObject);
begin
  Assert(ItemBankFrm <> nil);
end;

procedure TMatchItemForm.SelectImageBtnClick(Sender: TObject);
begin
  jpegnameEdit.Text := OpenPictureDialog1.FileName;
end;

procedure TMatchItemForm.ShowNextBtnClick(Sender: TObject);
var
  count: integer;
  itemno: integer;
  JPEG: TJPEGImage;
  noleft, noright: integer;
begin
  itemno := StrToInt(ItemNoEdit.Text) + 1;
  count :=  ItemBankFrm.BankInfo.NMatchItems;
  if count <= itemno then
  begin
    Image1.Canvas.Clear;
    ItemNoEdit.Text := IntToStr(ItemBankFrm.MatchInfo[itemno].ItemNumber);
    MajorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[itemno].majorcode) ;
    MinorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[itemno].minorcode);
    noleft := ItemBankFrm.MatchInfo[itemno].NLeft;
    noright := ItemBankFrm.MatchInfo[itemno].NRight;
    if noleft > 0 then Left1Edit.Text := ItemBankFrm.MatchInfo[itemno].Left1 ;
    if noleft > 1 then Left2Edit.Text := ItemBankFrm.MatchInfo[itemno].Left2;
    if noleft > 2 then Left3Edit.Text := ItemBankFrm.MatchInfo[itemno].Left3;
    if noleft > 3 then Left4Edit.Text := ItemBankFrm.MatchInfo[itemno].Left4;
    if noleft > 4 then Left5Edit.Text := ItemBankFrm.MatchInfo[itemno].Left5;
    if noright > 0 then Right1Edit.Text := ItemBankFrm.MatchInfo[itemno].Right1;
    if noright > 1 then Right2Edit.Text := ItemBankFrm.MatchInfo[itemno].Right2;
    if noright > 2 then Right3Edit.Text := ItemBankFrm.MatchInfo[itemno].Right3;
    if noright > 3 then Right4Edit.Text := ItemBankFrm.MatchInfo[itemno].Right4;
    if noright > 4 then Right5Edit.Text := ItemBankFrm.MatchInfo[itemno].Right5;
    AnswerEdit.Text := ItemBankFrm.MatchInfo[itemno].CorrectChoice;
    jpegnameEdit.Text := ItemBankFrm.MatchInfo[itemno].PicName;
    if (jpegnameEdit.Text <> 'none') and FileExists(jpegnameEdit.Text) then
    begin
      JPEG := TJPEGImage.Create;
      try
        JPEG.LoadFromFile(jpegnameEdit.Text);
        Image1.Picture.Assign(JPEG);
      finally
        JPEG.Free;
        Image1.Proportional := true;
      end;
    end else
      Image1.Picture.Clear;
  end;
end;

procedure TMatchItemForm.StartNewBtnClick(Sender: TObject);
var
  currentno: integer;
begin
  Image1.Canvas.Clear;
  currentno := ItemBankFrm.BankInfo.NMatchItems + 1;
  ItemNoEdit.Text := IntToStr(currentno);
  currentno := StrToInt(MinorCodeEdit.Text);
  MinorCodeEdit.Text := IntToStr(currentno + 1);
  Left1Edit.Text := '';
  Left2Edit.Text := '';
  Left3Edit.Text := '';
  Left4Edit.Text := '';
  Left5Edit.Text := '';
  Right1Edit.Text := '';
  Right2Edit.Text := '';
  Right3Edit.Text := '';
  Right4Edit.Text := '';
  Right5Edit.Text := '';
  AnswerEdit.Text := '';
  jpegnameEdit.Text := 'none';
  Image1.Picture.Clear;
end;

initialization
  {$I matchitemunit.lrs}

end.

