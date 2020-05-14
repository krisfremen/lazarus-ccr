unit TestSpecsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TTestSpecsForm }

  TTestSpecsForm = class(TForm)
    GroupBox1: TGroupBox;
    NoItemsEdit: TEdit;
    Label8: TLabel;
    SelectedEdit: TEdit;
    Label7: TLabel;
    SkipBtn: TButton;
    SelectItemBtn: TButton;
    ItemCodeLabel: TLabel;
    ItemNoEdit: TEdit;
    MajorCodeEdit: TEdit;
    MinorCodeEdit: TEdit;
    MinorCodeLabel: TLabel;
    Panel1: TPanel;
    TFItemNoLabel: TLabel;
    TFNoEdit: TEdit;
    EssayNoEdit: TEdit;
    MatchNoEdit: TEdit;
    MCNoEdit: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SelectChoiceBox: TCheckGroup;
    SpecFileEdit: TEdit;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    ReturnBtn: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormShow(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
    procedure SelectItemBtnClick(Sender: TObject);
    procedure SelectChoiceBoxItemClick(Sender: TObject; Index: integer);
    procedure SkipBtnClick(Sender: TObject);
    procedure ShowMCItem(Sender: TObject; index : integer);
    procedure ShowTFItem(Sender: TObject; index : integer);
    procedure ShowEssayItem(Sender: TObject; index : integer);
    procedure ShowMatchItem(Sender: TObject; index : integer);
  private
    { private declarations }
  public
    { public declarations }
    testno : integer;
  end; 

var
  TestSpecsForm: TTestSpecsForm;

implementation

uses
  ItemBankingUnit;

{ TTestSpecsForm }

procedure TTestSpecsForm.ReturnBtnClick(Sender: TObject);
begin
  ItemBankFrm.BankInfo.TestItems := testno;
  ItemBankFrm.NSpecifiedEdit.Text := IntToStr(testno);
  Close;
end;

procedure TTestSpecsForm.SelectItemBtnClick(Sender: TObject);
begin
  testno := testno + 1;
  ItemBankFrm.TestContents[testno].ItemNumber := StrToInt(ItemNoEdit.Text);
  ItemBankFrm.TestContents[testno].MajorCode := StrToInt(MajorCodeEdit.Text);
  ItemBankFrm.TestContents[testno].MinorCode := StrToInt(MinorCodeEdit.Text);
  ItemBankFrm.TestContents[testno].ItemType := SelectedEdit.Text;
  NoItemsEdit.Text := IntToStr(testno);
end;

procedure TTestSpecsForm.FormShow(Sender: TObject);
begin
  testno := 0;
  NoItemsEdit.Text := '0';
end;

procedure TTestSpecsForm.SelectChoiceBoxItemClick(Sender: TObject; Index: integer);
var
  nomc, notf, nomatch, noessay, i : integer;
  response : string;
begin
  nomc := StrToInt(MCNoEdit.Text);
  notf := StrToInt(TFNoEdit.Text);
  nomatch := StrToInt(MatchNoEdit.Text);
  noessay := StrToInt(EssayNoEdit.Text);
  case Index of
    0 : begin // Select multiple choice items
          SelectedEdit.Text := 'MC';
          for i := 1 to nomc do
          begin
            ShowMCItem(self,i);
            response := InputBox('Add item to test','Add?','Y');
            if response = 'Y' then SelectItemBtnClick(self) else SkipBtnClick(self);
          end;
        end;
    1 : begin // Select true or false items
          SelectedEdit.Text := 'TF';
          for i := 1 to notf do
          begin
            ShowTFItem(self,i);
            response := InputBox('Add item to test','Add?','Y');
            if response = 'Y' then SelectItemBtnClick(self) else SkipBtnClick(self);
          end;
        end;
    2 : begin // Select Essay items
          SelectedEdit.Text := 'Essay';
          for i := 1 to noessay do
          begin
            ShowEssayItem(self,i);
            response := InputBox('Add item to test','Add?','Y');
            if response = 'Y' then SelectItemBtnClick(self) else SkipBtnClick(self);
          end;
        end;
    3 : begin // Select matching items
          SelectedEdit.Text := 'Matching';
          for i := 1 to nomc do
          begin
            ShowMatchItem(self,i);
            response := InputBox('Add item to test','Add?','Y');
            if response = 'Y' then SelectItemBtnClick(self) else SkipBtnClick(self);
          end;
        end;
  end;
end;

procedure TTestSpecsForm.SkipBtnClick(Sender: TObject);
begin
  ShowMessage('Item skipped');
end;

// ToDoo: This must be moved to OnPaint handler.
procedure TTestSpecsForm.ShowMCItem(Sender: TObject; index : integer);
var
  outline: string;
  nochoices: integer;
  space: integer;
begin
  Panel1.Canvas.Clear;
  space := Panel1.Canvas.Height div 9;
  ItemNoEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[index].itemnumber);
  MajorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[index].MajorCode);
  MinorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[index].MinorCode);

  outline := ItemBankFrm.MCItemInfo[index].ItemStem;
  Panel1.Canvas.TextOut(1, space, outline);

  nochoices := ItemBankFrm.MCItemInfo[index].NoChoices ;
  if nochoices > 0 then
  begin
    outline := Format('Choice A %s', [ItemBankFrm.MCItemInfo[index].ChoiceOne]);
    Panel1.Canvas.TextOut(1, space*2, outline);
  end;

  if nochoices > 1 then
  begin
    outline := Format('Choice B %s', [ItemBankFrm.MCItemInfo[index].ChoiceTwo]);
    Panel1.Canvas.TextOut(1, space*3, outline);
  end;

  if nochoices > 2 then
  begin
    outline := Format('Choice C %s', [ItemBankFrm.MCItemInfo[index].ChoiceThree]);
    Panel1.Canvas.TextOut(1, space*4, outline);
  end;

  if nochoices > 3 then
  begin
    outline := Format('Choice D %s', [ItemBankFrm.MCItemInfo[index].ChoiceFour]);
    Panel1.Canvas.TextOut(1, space*5, outline);
  end;

  if nochoices > 4 then
  begin
    outline := Format('Choice E %s', [ItemBankFrm.MCItemInfo[index].ChoiceFive]);
    Panel1.Canvas.TextOut(1, space*6, outline);
  end;

  outline := Format('Correct Choice %s', [ItemBankFrm.MCItemInfo[index].CorrectChoice]);
  Panel1.Canvas.TextOut(1, space*7, outline);

  outline := Format('Graphic Image %s', [ItemBankFrm.MCItemInfo[index].PicName]);
  Panel1.Canvas.TextOut(1, space*8, outline);
end;

// ToDoo: This must be moved to OnPaint handler.
procedure TTestSpecsForm.ShowTFItem(Sender: TObject; index : integer);
var
  outline: string;
  space: integer;
begin
  Panel1.Canvas.Clear;
  space := Panel1.Canvas.Height div 9;
  ItemNoEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[index].itemnumber);
  MajorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[index].MajorCode);
  MinorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[index].MinorCode);
  Panel1.Canvas.TextOut(1,space,ItemBankFrm.TFItemInfo[index].ItemStem);
  Panel1.Canvas.TextOut(1,space*2,ItemBankFrm.TFItemInfo[index].CorrectChoice);
  Panel1.Canvas.TextOut(1,space*3,ItemBankFrm.TFItemInfo[index].PicName);
end;

// ToDo: This must be moved to OnPaint handler
procedure TTestSpecsForm.ShowEssayItem(Sender: TObject; index : integer);
var
  outline: string;
  space: integer;
begin
  Panel1.Canvas.Clear;
  space := Panel1.Canvas.Height div 9;
  ItemNoEdit.Text := IntToStr(ItemBankFrm.EssayInfo[index].itemnumber);
  MajorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[index].MajorCode);
  MinorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[index].MinorCode);
  Panel1.Canvas.TextOut(1, space, ItemBankFrm.EssayInfo[index].ItemStem);
  Panel1.Canvas.TextOut(1, space*2, ItemBankFrm.EssayInfo[index].Answer);
  Panel1.Canvas.TextOut(1, space*3, ItemBankFrm.EssayInfo[index].PicName);
end;

// ToDo: This must be moved to OnPaint handler
procedure TTestSpecsForm.ShowMatchItem(Sender: TObject; index : integer);
var
  outline: string;
  space: integer;
  noleft, noright: integer;
begin
  Panel1.Canvas.Clear;
  noleft := ItemBankFrm.MatchInfo[index].NLeft;
  noright := ItemBankFrm.MatchInfo[index].NRight;
  space := Panel1.Canvas.Height div 13;
  ItemNoEdit.Text := IntToStr(ItemBankFrm.MatchInfo[index].itemnumber);
  MajorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[index].MajorCode);
  MinorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[index].MinorCode);
  // do left and right stems
  if noleft > 0 then
  begin
    outline := Format('Left Item 1 %s', [ItemBankFrm.MatchInfo[index].Left1]);
    Panel1.Canvas.TextOut(1, space, outline);
  end;
  if noright > 0 then
  begin
    outline := Format('   Right Item 1 %s', [ItemBankFrm.MatchInfo[index].Right1]);
    Panel1.Canvas.TextOut(1, space*2, outline);
  end;
  if noleft > 1 then
  begin
    outline := Format('Left Item 2 %s', [ItemBankFrm.MatchInfo[index].Left2]);
    Panel1.Canvas.TextOut(1, space*3, outline);
  end;
  if noright > 1 then
  begin
    outline := Format('   Right Item 2 %s', [ItemBankFrm.MatchInfo[index].Right2]);
    Panel1.Canvas.TextOut(1, space*4, outline);
  end;
  if noleft > 2 then
  begin
    outline := Format('Left Item 3 %s', [ItemBankFrm.MatchInfo[index].Left3]);
    Panel1.Canvas.TextOut(1, space*5, outline);
  end;
  if noright > 2 then
  begin
    outline := Format('   Right Item 3 %s', [ItemBankFrm.MatchInfo[index].Right3]);
    Panel1.Canvas.TextOut(1, space*6, outline);
  end;
  if noleft > 3 then
  begin
    outline := Format('Left Item 4 %s', [ItemBankFrm.MatchInfo[index].Left4]);
    Panel1.Canvas.TextOut(1, space*7, outline);
  end;
  if noright > 3 then
  begin
    outline := Format('   Right Item 4 %s', [ItemBankFrm.MatchInfo[index].Right4]);
    Panel1.Canvas.TextOut(1, space*8, outline);
  end;
  if noleft > 4 then
  begin
    outline := Format('Left Item 5 %s', [ItemBankFrm.MatchInfo[index].Left5]);
    Panel1.Canvas.TextOut(1, space*9, outline);
  end;
  if noright > 4 then
  begin
    outline := Format('   Right Item 5 %s', [ItemBankFrm.MatchInfo[index].Right5]);
    Panel1.Canvas.TextOut(1, space*10, outline);
  end;
  Panel1.Canvas.TextOut(1, space*11, ItemBankFrm.MatchInfo[index].CorrectChoice);
  Panel1.Canvas.TextOut(1, space*12, ItemBankFrm.MatchInfo[index].PicName);
end;

initialization
  {$I testspecsunit.lrs}

end.

