unit MCItemUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ExtDlgs,
  OutputUnit;

type

  { TMCItemForm }

  TMCItemForm = class(TForm)
    AnswerEdit: TEdit;
    AnswerLabel: TLabel;
    ChoiceAEdit: TEdit;
    ChoiceDEdit: TEdit;
    ChoiceEEdit: TEdit;
    ChoiceCEdit: TEdit;
    ChoiceBEdit: TEdit;
    CodeBrowseBtn: TButton;
    GroupBox1: TGroupBox;
    Memo1: TLabel;
    NoChoicesEdit: TEdit;
    Image1: TImage;
    ItemCodeLabel: TLabel;
    ItemSaveBtn: TButton;
    ItemStemEdit: TEdit;
    ItemStemLabel: TLabel;
    jpegBrowseBtn: TButton;
    jpeglabel: TLabel;
    jpegnameEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    MajorCodeEdit: TEdit;
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
    procedure NoChoicesEditChange(Sender: TObject);
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
  MCItemForm: TMCItemForm;

implementation

uses
  ItemBankingUnit;

{ TMCItemForm }

procedure TMCItemForm.jpegBrowseBtnClick(Sender: TObject);
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

procedure TMCItemForm.NoChoicesEditChange(Sender: TObject);
var
  nochoices : integer;
begin
     nochoices := StrToInt(NoChoicesEdit.Text);
     if nochoices > 0 then ChoiceAEdit.Visible := true else ChoiceAEdit.Visible := false;
     if nochoices > 1 then ChoiceBEdit.Visible := true else ChoiceBEdit.Visible := false;
     if nochoices > 2 then ChoiceCEdit.Visible := true else ChoiceCEdit.Visible := false;
     if nochoices > 3 then ChoiceDEdit.Visible := true else ChoiceDEdit.Visible := false;
     if nochoices > 4 then ChoiceEEdit.Visible := true else ChoiceEEdit.Visible := false;
end;

procedure TMCItemForm.PreviousBtnClick(Sender: TObject);
Var
  response : string;
  itemno : integer;
  JPEG : TJPEGImage;
  nochoices : integer;
begin
  response := InputBox('Save current item?','Save','Y');
  if response = 'Y' then ItemSaveBtnClick(self);
  Image1.Canvas.Clear;
  ChoiceAEdit.Text := '';
  ChoiceBEdit.Text := '';
  ChoiceCEdit.Text := '';
  ChoiceDEdit.Text := '';
  ChoiceEEdit.Text := '';
  response := InputBox('Code Number:','Number:','1');
  itemno := StrToInt(response);
  if itemno <= ItemBankFrm.BankInfo.NMCItems then
  begin
       nochoices := ItemBankFrm.MCItemInfo[itemno].NoChoices;
       ItemNoEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[itemno].ItemNumber);
       MajorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[itemno].majorcode);
       MinorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[itemno].minorcode);
       NoChoicesEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[itemno].NoChoices);
       ItemStemEdit.Text := ItemBankFrm.MCItemInfo[itemno].ItemStem ;
       if nochoices > 0 then ChoiceAEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceOne;
       if nochoices > 1 then ChoiceBEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceTwo;
       if nochoices > 2 then ChoiceCEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceThree;
       if nochoices > 3 then ChoiceDEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceFour;
       if nochoices > 4 then ChoiceEEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceFive;
       AnswerEdit.Text := ItemBankFrm.MCItemInfo[itemno].CorrectChoice;
       jpegnameEdit.Text := ItemBankFrm.MCItemInfo[itemno].PicName;
       if jpegnameEdit.Text <> 'none' then
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

procedure TMCItemForm.ReturnBtnClick(Sender: TObject);
begin
  MCItemForm.Hide;
  Close;
end;

procedure TMCItemForm.ItemSaveBtnClick(Sender: TObject);
var
  currentno : integer;
  count : integer;
  nochoices : integer;
begin
  count := ItemBankFrm.BankInfo.NMCItems;
  currentno := StrToInt(ItemNoEdit.Text);
  if currentno > count then
  begin
    ItemBankFrm.BankInfo.NMCItems := currentno;
    ItemBankFrm.NMCItemsText.Text := IntToStr(currentno);
  end;
  nochoices := StrToInt(NoChoicesEdit.Text);
  ItemBankFrm.MCItemInfo[currentno].ItemNumber := currentno;
  ItemBankFrm.MCItemInfo[currentno].majorcode := StrToInt(MajorCodeEdit.Text);
  ItemBankFrm.MCItemInfo[currentno].minorcode := StrToInt(MinorCodeEdit.Text);
  ItemBankFrm.MCItemInfo[currentno].NoChoices := nochoices;
  ItemBankFrm.MCItemInfo[currentno].ItemStem := ItemStemEdit.Text;
  if nochoices > 0 then ItemBankFrm.MCItemInfo[currentno].ChoiceOne := ChoiceAEdit.Text;
  if nochoices > 1 then ItemBankFrm.MCItemInfo[currentno].ChoiceTwo := ChoiceBEdit.Text;
  if nochoices > 2 then ItemBankFrm.MCItemInfo[currentno].ChoiceThree := ChoiceCEdit.Text;
  if nochoices > 3 then ItemBankFrm.MCItemInfo[currentno].ChoiceFour := ChoiceDEdit.Text;
  if nochoices > 4 then ItemBankFrm.MCItemInfo[currentno].ChoiceFive := ChoiceEEdit.Text;
  ItemBankFrm.MCItemInfo[currentno].CorrectChoice := AnswerEdit.Text[1];
  ItemBankFrm.MCItemInfo[currentno].PicName := jpegnameEdit.Text;
end;

procedure TMCItemForm.FormShow(Sender: TObject);
Var
  JPEG : TJPEGImage;
  nochoices : integer;
begin
  ChoiceAEdit.Text := '';
  ChoiceBEdit.Text := '';
  ChoiceCEdit.Text := '';
  ChoiceDEdit.Text := '';
  ChoiceEEdit.Text := '';
  Image1.Canvas.Clear;
  if ItemBankFrm.BankInfo.NMCItems  > 0 then
  begin
       ItemNoEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[1].ItemNumber);
       MajorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[1].majorcode) ;
       MinorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[1].minorcode);
       nochoices := ItemBankFrm.MCItemInfo[1].NoChoices;
       NoChoicesEdit.Text := IntToStr(nochoices);
       ItemStemEdit.Text := ItemBankFrm.MCItemInfo[1].ItemStem;
       AnswerEdit.Text := ItemBankFrm.MCItemInfo[1].CorrectChoice;
       if nochoices > 0 then ChoiceAEdit.Text := ItemBankFrm.MCItemInfo[1].ChoiceOne;
       if nochoices > 1 then ChoiceBEdit.Text := ItemBankFrm.MCItemInfo[1].ChoiceTwo;
       if nochoices > 2 then ChoiceCEdit.Text := ItemBankFrm.MCItemInfo[1].ChoiceThree;
       if nochoices > 3 then ChoiceDEdit.Text := ItemBankFrm.MCItemInfo[1].ChoiceFour;
       if nochoices > 4 then ChoiceEEdit.Text := ItemBankFrm.MCItemInfo[1].ChoiceFive;
       jpegnameEdit.Text := ItemBankFrm.MCItemInfo[1].PicName;
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

procedure TMCItemForm.CodeBrowseBtnClick(Sender: TObject);
var
  count : integer;
  i : integer;
  outline : string;
  nochoices : integer;
begin
  OutputFrm.RichEdit.Clear;
  count := ItemBankFrm.BankInfo.NMCItems;
  OutputFrm.RichEdit.Lines.Add('Current Items');
  OutputFrm.RichEdit.Lines.Add('');

  for i := 1 to count do
  begin
       ChoiceAEdit.Text := '';
       ChoiceBEdit.Text := '';
       ChoiceCEdit.Text := '';
       ChoiceDEdit.Text := '';
       ChoiceEEdit.Text := '';
       nochoices := ItemBankFrm.MCItemInfo[i].NoChoices;
       outline := format('Item number %3d',[ItemBankFrm.MCItemInfo[i].itemnumber]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('Major Code %3d',[ItemBankFrm.MCItemInfo[i].majorcode]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('Minor Code %3d',[ItemBankFrm.MCItemInfo[i].minorcode]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('No. of Choices %3d',[ItemBankFrm.MCItemInfo[i].NoChoices]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('Item Stem %s',[ItemBankFrm.MCItemInfo[i].ItemStem]);
       OutputFrm.RichEdit.Lines.Add(outline);
       if nochoices > 0 then
       begin
            outline := format('Choice A %s',[ItemBankFrm.MCItemInfo[i].ChoiceOne]);
            OutputFrm.RichEdit.Lines.Add(outline);
       end;
       if nochoices > 1 then
       begin
          outline := format('Choice B %s',[ItemBankFrm.MCItemInfo[i].ChoiceTwo]);
          OutputFrm.RichEdit.Lines.Add(outline);
       end;
       if nochoices > 2 then
       begin
          outline := format('Choice C %s',[ItemBankFrm.MCItemInfo[i].ChoiceThree]);
          OutputFrm.RichEdit.Lines.Add(outline);
       end;
       if nochoices > 3 then
       begin
          outline := format('Choice D %s',[ItemBankFrm.MCItemInfo[i].ChoiceFour]);
          OutputFrm.RichEdit.Lines.Add(outline);
       end;
       if nochoices > 4 then
       begin
          outline := format('Choice E %s',[ItemBankFrm.MCItemInfo[i].ChoiceFive]);
          OutputFrm.RichEdit.Lines.Add(outline);
       end;
       outline := format('Correct Choice %s',[ItemBankFrm.MCItemInfo[i].CorrectChoice]);
       OutputFrm.RichEdit.Lines.Add(outline);
       outline := format('Graphic Image %s',[ItemBankFrm.MCItemInfo[i].PicName]);
       OutputFrm.RichEdit.Lines.Add(outline);
       OutputFrm.RichEdit.Lines.Add('');
  end;
  OutputFrm.ShowModal;
end;

procedure TMCItemForm.FormActivate(Sender: TObject);
begin
  if FAutoSized then
    exit;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  FAutoSized := true;
end;

procedure TMCItemForm.FormCreate(Sender: TObject);
begin
  Assert(ItemBankFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TMCItemForm.SelectImageBtnClick(Sender: TObject);
begin
  jpegnameEdit.Text := OpenPictureDialog1.FileName;
end;

procedure TMCItemForm.ShowNextBtnClick(Sender: TObject);
var
  count : integer;
  itemno : integer;
  JPEG : TJPEGImage;
  nochoices : integer;
  response : string;
begin
  response := InputBox('Save current item?','Save','Y');
  if response = 'Y' then ItemSaveBtnClick(self);
  Image1.Canvas.Clear;
  itemno := StrToInt(ItemNoEdit.Text) + 1;
  count :=  ItemBankFrm.BankInfo.NMCItems;
  if count <= itemno then
  begin
       ChoiceAEdit.Text := '';
       ChoiceBEdit.Text := '';
       ChoiceCEdit.Text := '';
       ChoiceDEdit.Text := '';
       ChoiceEEdit.Text := '';
       nochoices := ItemBankFrm.MCItemInfo[itemno].NoChoices;
       ItemNoEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[itemno].ItemNumber);
       MajorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[itemno].majorcode) ;
       MinorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[itemno].minorcode);
       ItemStemEdit.Text := ItemBankFrm.MCItemInfo[itemno].ItemStem;
       if nochoices > 0 then ChoiceAEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceOne;
       if nochoices > 1 then ChoiceBEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceTwo;
       if nochoices > 2 then ChoiceCEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceThree;
       if nochoices > 3 then ChoiceDEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceFour;
       if nochoices > 4 then ChoiceEEdit.Text := ItemBankFrm.MCItemInfo[itemno].ChoiceFive;
       AnswerEdit.Text := ItemBankFrm.MCItemInfo[itemno].CorrectChoice;
       jpegnameEdit.Text := ItemBankFrm.MCItemInfo[itemno].PicName;
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

procedure TMCItemForm.StartNewBtnClick(Sender: TObject);
var
  currentno : integer;
  response : string;
begin
  response := InputBox('Save current item?','Save','Y');
  if response = 'Y' then ItemSaveBtnClick(self);
  currentno := ItemBankFrm.BankInfo.NMCItems + 1;
  ItemNoEdit.Text := IntToStr(currentno);
  currentno := StrToInt(MinorCodeEdit.Text);
  MinorCodeEdit.Text := IntToStr(currentno + 1);
  NoChoicesEdit.Text := '0';
  ItemStemEdit.Text := '';
  ChoiceAEdit.Text := '';
  ChoiceBEdit.Text := '';
  ChoiceCEdit.Text := '';
  ChoiceDEdit.Text := '';
  ChoiceEEdit.Text := '';
  AnswerEdit.Text := '';
  jpegnameEdit.Text := 'none';
  Image1.Picture.Clear;
end;

initialization
  {$I mcitemunit.lrs}

end.

