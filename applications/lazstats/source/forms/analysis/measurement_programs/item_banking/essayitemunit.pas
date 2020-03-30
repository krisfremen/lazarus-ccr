unit EssayItemUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ExtDlgs,
  OutputUnit;

type

  { TEssayItemForm }

  TEssayItemForm = class(TForm)
    AnswerEdit: TEdit;
    AnswerLabel: TLabel;
    CodeBrowseBtn: TButton;
    Image1: TImage;
    ItemCodeLabel: TLabel;
    ItemSaveBtn: TButton;
    ItemStemEdit: TEdit;
    ItemStemLabel: TLabel;
    jpegBrowseBtn: TButton;
    jpeglabel: TLabel;
    jpegnameEdit: TEdit;
    MajorCodeEdit: TEdit;
    Memo1: TLabel;
    MinorCodeEdit: TEdit;
    MinorCodeLabel: TLabel;
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
  EssayItemForm: TEssayItemForm;

implementation

uses
  ItemBankingUnit;

{ TEssayItemForm }

procedure TEssayItemForm.ReturnBtnClick(Sender: TObject);
begin
  EssayItemForm.Hide;
  Close;
end;

procedure TEssayItemForm.SelectImageBtnClick(Sender: TObject);
begin
  jpegnameEdit.Text := OpenPictureDialog1.FileName;
end;

procedure TEssayItemForm.ShowNextBtnClick(Sender: TObject);
var
  count : integer;
  itemno : integer;
  JPEG : TJPEGImage;
begin
  itemno := StrToInt(ItemNoEdit.Text) + 1;
  count :=  ItemBankFrm.BankInfo.NEssayItems;
  if count <= itemno then
  begin
       ItemNoEdit.Text := IntToStr(ItemBankFrm.EssayInfo[itemno].ItemNumber);
       MajorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[itemno].majorcode) ;
       MinorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[itemno].minorcode);
       ItemStemEdit.Text := ItemBankFrm.EssayInfo[itemno].ItemStem;
       AnswerEdit.Text := ItemBankFrm.EssayInfo[itemno].Answer;
       jpegnameEdit.Text := ItemBankFrm.EssayInfo[itemno].PicName;
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

procedure TEssayItemForm.StartNewBtnClick(Sender: TObject);
var
  currentno : integer;
begin
  currentno := ItemBankFrm.BankInfo.NEssayItems + 1;
  ItemNoEdit.Text := IntToStr(currentno);
  currentno := StrToInt(MinorCodeEdit.Text);
  MinorCodeEdit.Text := IntToStr(currentno + 1);
  ItemStemEdit.Text := '';
  AnswerEdit.Text := '';
  jpegnameEdit.Text := 'none';
  Image1.Picture.Clear;
end;

procedure TEssayItemForm.ItemSaveBtnClick(Sender: TObject);
var
  currentno : integer;
  count : integer;
begin
  count := ItemBankFrm.BankInfo.NEssayItems;
  currentno := StrToInt(ItemNoEdit.Text);
  if currentno > count then
  begin
    ItemBankFrm.BankInfo.NEssayItems := currentno;
    ItemBankFrm.NEssayText.Text := IntToStr(currentno);
  end;
  ItemBankFrm.EssayInfo[currentno].ItemNumber := currentno;
  ItemBankFrm.EssayInfo[currentno].majorcode := StrToInt(MajorCodeEdit.Text);
  ItemBankFrm.EssayInfo[currentno].minorcode := StrToInt(MinorCodeEdit.Text);
  ItemBankFrm.EssayInfo[currentno].ItemStem := ItemStemEdit.Text;
  ItemBankFrm.EssayInfo[currentno].Answer := AnswerEdit.text;
  ItemBankFrm.EssayInfo[currentno].PicName := jpegnameEdit.Text;
end;

procedure TEssayItemForm.FormShow(Sender: TObject);
Var
  nitems : integer;
  JPEG : TJPEGImage;
begin
  if ItemBankFrm.BankInfo.NEssayItems  > 0 then
  begin
       nitems := ItemBankFrm.BankInfo.NEssayItems;
       ItemNoEdit.Text := '1'; //IntToStr(ItemBankFrm.TFItemInfo[1].ItemNumber);
       MajorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[1].majorcode) ;
       MinorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[1].minorcode);
       ItemStemEdit.Text := ItemBankFrm.EssayInfo[1].ItemStem;
       AnswerEdit.Text := ItemBankFrm.EssayInfo[1].Answer;
       jpegnameEdit.Text := ItemBankFrm.EssayInfo[1].PicName;
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
  end else
  begin
       ItemNoEdit.Text := '1';
       MajorCodeEdit.Text := '1';
       MinorCodeEdit.Text := '0';
       ItemStemEdit.Text := '';
       AnswerEdit.Text := '';
       jpegnameEdit.Text := 'none';
       Image1.Picture.Clear;
  end;
end;

procedure TEssayItemForm.CodeBrowseBtnClick(Sender: TObject);
var
  count : integer;
  i : integer;
  outline : string;
begin
  OutputFrm.RichEdit.Clear;
  count := ItemBankFrm.BankInfo.NTFItems;
  OutputFrm.RichEdit.Lines.Add('Current Items');
  OutputFrm.RichEdit.Lines.Add('');

  for i := 1 to count do
  begin
       outline := format('Item number %3d',[ItemBankFrm.EssayInfo[i].itemnumber]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('Major Code %3d',[ItemBankFrm.EssayInfo[i].majorcode]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('Minor Code %3d',[ItemBankFrm.EssayInfo[i].minorcode]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('Item Stem %s',[ItemBankFrm.EssayInfo[i].ItemStem]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('Breif Answer %s',[ItemBankFrm.EssayInfo[i].Answer]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('Graphic Image %s',[ItemBankFrm.EssayInfo[i].PicName]);
       OutputFrm.RichEdit.Lines.Add(outline);
       OutputFrm.RichEdit.Lines.Add('');
  end;
  OutputFrm.ShowModal;
end;

procedure TEssayItemForm.FormActivate(Sender: TObject);
begin
  if FAutoSized then
    exit;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  FAutoSized := True;
end;

procedure TEssayItemForm.FormCreate(Sender: TObject);
begin
  Assert(ItemBankFrm <> nil);

  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TEssayItemForm.jpegBrowseBtnClick(Sender: TObject);
VAR
  JPEG : TJPEGImage;
begin
  OpenPictureDialog1.Options := OpenPictureDialog1.Options+[ofFileMustExist];
  if not OpenPictureDialog1.Execute then exit;
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
      MessageDlg('Error','Error: '+E.Message,mtError,[mbOk],0);
    end;
  end;
  Image1.Proportional := true;
end;

procedure TEssayItemForm.PreviousBtnClick(Sender: TObject);
Var
  response : string;
  itemno : integer;
  JPEG : TJPEGImage;
begin
  response := InputBox('Code Number:','Number:','1');
  itemno := StrToInt(response);
  if itemno <= ItemBankFrm.BankInfo.NEssayItems then
  begin
       ItemNoEdit.Text := IntToStr(ItemBankFrm.EssayInfo[itemno].ItemNumber);
       MajorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[itemno].majorcode);
       MinorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[itemno].minorcode);
       ItemStemEdit.Text := ItemBankFrm.EssayInfo[itemno].ItemStem ;
       AnswerEdit.Text := ItemBankFrm.EssayInfo[itemno].Answer;
       jpegnameEdit.Text := ItemBankFrm.EssayInfo[itemno].PicName;
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
       end;
  end;
end;

initialization
  {$I essayitemunit.lrs}

end.

