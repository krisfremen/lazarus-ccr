unit TFItemUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ExtDlgs, OutputUnit;

type

  { TTFItemForm }

  TTFItemForm = class(TForm)
    Memo1: TLabel;
    ShowNextBtn: TButton;
    PreviousBtn: TButton;
    ItemSaveBtn: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    StartNewBtn: TButton;
    ReturnBtn: TButton;
    SelectImageBtn: TButton;
    Image1: TImage;
    jpegBrowseBtn: TButton;
    CodeBrowseBtn: TButton;
    AnswerEdit: TEdit;
    jpegnameEdit: TEdit;
    ItemStemEdit: TEdit;
    ItemStemLabel: TLabel;
    AnswerLabel: TLabel;
    jpeglabel: TLabel;
    MinorCodeEdit: TEdit;
    MinorCodeLabel: TLabel;
    MajorCodeEdit: TEdit;
    ItemCodeLabel: TLabel;
    TFItemNoEdit: TEdit;
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
  TFItemForm: TTFItemForm;

implementation
uses ItemBankingUnit;
{ TTFItemForm }

procedure TTFItemForm.jpegBrowseBtnClick(Sender: TObject);
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
         MessageDlg('Error','Error: '+E.Message,mtError,[mbOk],0);
       end;
     end;
     Image1.Proportional := true;
end;

procedure TTFItemForm.PreviousBtnClick(Sender: TObject);
Var
  response : string;
  itemno : integer;
  JPEG : TJPEGImage;
begin
     response := InputBox('Code Number:','Number:','1');
     itemno := StrToInt(response);
     if itemno <= ItemBankFrm.BankInfo.NTFItems then
     begin
          TFItemNoEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[itemno].ItemNumber);
          MajorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[itemno].majorcode);
          MinorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[itemno].minorcode);
          ItemStemEdit.Text := ItemBankFrm.TFItemInfo[itemno].ItemStem ;
          AnswerEdit.Text := ItemBankFrm.TFItemInfo[itemno].CorrectChoice;
          jpegnameEdit.Text := ItemBankFrm.TFItemInfo[itemno].PicName;
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

procedure TTFItemForm.ReturnBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TTFItemForm.ItemSaveBtnClick(Sender: TObject);
var
  currentno : integer;
  count : integer;
begin
     count := ItemBankFrm.BankInfo.NTFItems;
     currentno := StrToInt(TFItemNoEdit.Text);
     if currentno > count then
     begin
       ItemBankFrm.BankInfo.NTFItems := currentno;
       ItemBankFrm.NTFItemsText.Text := IntToStr(currentno);
     end;
     ItemBankFrm.TFItemInfo[currentno].ItemNumber := currentno;
     ItemBankFrm.TFItemInfo[currentno].majorcode := StrToInt(MajorCodeEdit.Text);
     ItemBankFrm.TFItemInfo[currentno].minorcode := StrToInt(MinorCodeEdit.Text);
     ItemBankFrm.TFItemInfo[currentno].ItemStem := ItemStemEdit.Text;
     ItemBankFrm.TFItemInfo[currentno].CorrectChoice := AnswerEdit.text[1];
     ItemBankFrm.TFItemInfo[currentno].PicName := jpegnameEdit.Text;
end;

procedure TTFItemForm.CodeBrowseBtnClick(Sender: TObject);
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
          outline := format('Item number %3d',[ItemBankFrm.TFItemInfo[i].itemnumber]);
          OutputFrm.RichEdit.Lines.Add(outline);
          outline := format('Major Code %3d',[ItemBankFrm.TFItemInfo[i].majorcode]);
          OutputFrm.RichEdit.Lines.Add(outline);
          outline := format('Minor Code %3d',[ItemBankFrm.TFItemInfo[i].minorcode]);
          OutputFrm.RichEdit.Lines.Add(outline);
          outline := format('Item Stem %s',[ItemBankFrm.TFItemInfo[i].ItemStem]);
          OutputFrm.RichEdit.Lines.Add(outline);
          outline := format('Correct Choice %s',[ItemBankFrm.TFItemInfo[i].CorrectChoice]);
          OutputFrm.RichEdit.Lines.Add(outline);
          outline := format('Graphic Image %s',[ItemBankFrm.TFItemInfo[i].PicName]);
          OutputFrm.RichEdit.Lines.Add(outline);
          OutputFrm.RichEdit.Lines.Add('');
     end;
     OutputFrm.ShowModal;
end;

procedure TTFItemForm.FormActivate(Sender: TObject);
begin
  if FAutoSized then
    exit;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  FAutoSized := true;
end;

procedure TTFItemForm.FormCreate(Sender: TObject);
begin
  Assert(ItemBankFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TTFItemForm.FormShow(Sender: TObject);
Var
  nitems : integer;
  JPEG : TJPEGImage;
begin
     nitems := ItemBankFrm.BankInfo.NTFItems;
     if nItems  > 0 then
     begin
          TFItemNoEdit.Text := '1'; //IntToStr(ItemBankFrm.TFItemInfo[1].ItemNumber);
          MajorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[1].majorcode) ;
          MinorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[1].minorcode);
          ItemStemEdit.Text := ItemBankFrm.TFItemInfo[1].ItemStem;
          AnswerEdit.Text := ItemBankFrm.TFItemInfo[1].CorrectChoice;
          jpegnameEdit.Text := ItemBankFrm.TFItemInfo[1].PicName;
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
            Image1.Picture.Clear;;
     end else
     begin
          TFItemNoEdit.Text := '1';
          MajorCodeEdit.Text := '1';
          MinorCodeEdit.Text := '0';
          ItemStemEdit.Text := '';
          AnswerEdit.Text := '';
          jpegnameEdit.Text := '';
          Image1.Picture.Clear;
     end;
end;

procedure TTFItemForm.SelectImageBtnClick(Sender: TObject);
begin
     jpegnameEdit.Text := OpenPictureDialog1.FileName;
end;

procedure TTFItemForm.ShowNextBtnClick(Sender: TObject);
var
  count : integer;
  itemno : integer;
  JPEG : TJPEGImage;
begin
     itemno := StrToInt(TFItemNoEdit.Text) + 1;
     count :=  ItemBankFrm.BankInfo.NTFItems;
     if count <= itemno then
     begin
          TFItemNoEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[itemno].ItemNumber);
          MajorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[itemno].majorcode) ;
          MinorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[itemno].minorcode);
          ItemStemEdit.Text := ItemBankFrm.TFItemInfo[itemno].ItemStem;
          AnswerEdit.Text := ItemBankFrm.TFItemInfo[itemno].CorrectChoice;
          jpegnameEdit.Text := ItemBankFrm.TFItemInfo[itemno].PicName;
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
          end;
     end;
end;

procedure TTFItemForm.StartNewBtnClick(Sender: TObject);
var
  currentno : integer;
begin
     currentno := ItemBankFrm.BankInfo.NTFItems + 1;
     TFItemNoEdit.Text := IntToStr(currentno);
     currentno := StrToInt(MinorCodeEdit.Text);
     MinorCodeEdit.Text := IntToStr(currentno + 1);
     ItemStemEdit.Text := '';
     AnswerEdit.Text := '';
     jpegnameEdit.Text := 'none';
     Image1.Canvas.Clear;
end;

initialization
  {$I tfitemunit.lrs}

end.

