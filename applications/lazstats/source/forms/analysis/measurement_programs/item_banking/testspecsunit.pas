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
    Memo: TMemo;
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
    procedure ShowMCItem(AIndex: integer);
    procedure ShowTFItem(AIndex: integer);
    procedure ShowEssayItem(AIndex: integer);
    procedure ShowMatchItem(AIndex: integer);
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
  i, response: Integer;
begin
  case Index of
    0 : begin // Select multiple choice items
          SelectedEdit.Text := 'MC';
          for i := 1 to StrToInt(MCNoEdit.Text) do
          begin
            ShowMCItem(i);
            response := MessageDlg('Add item to test?', mtConfirmation, [mbYes, mbNo], 0);
            if response = mrYes then SelectItemBtnClick(self) else SkipBtnClick(self);
          end;
        end;
    1 : begin // Select true or false items
          SelectedEdit.Text := 'TF';
          for i := 1 to StrToInt(TFNoEdit.Text) do
          begin
            ShowTFItem(i);
            response := MessageDlg('Add item to test?', mtConfirmation, [mbYes, mbNo], 0);
            if response = mrYes then SelectItemBtnclick(self) else SkipBtnClick(self);
          end;
        end;
    2 : begin // Select Essay items
          SelectedEdit.Text := 'Essay';
          for i := 1 to StrToInt(EssayNoEdit.Text) do
          begin
            ShowEssayItem(i);
            response := MessageDlg('Add item to test?', mtConfirmation, [mbYes, mbNo], 0);
            if response = mrYes then selectItemBtnClick(self) else SkipBtnClick(self);
          end;
        end;
    3 : begin // Select matching items
          SelectedEdit.Text := 'Matching';
          for i := 1 to StrToInt(MatchNoEdit.Text) do // was: "nomc", should probably be "nomatch"
          begin
            ShowMatchItem(i);
            response := MessageDlg('Add item to test?', mtConfirmation, [mbYes, mbNo], 0);
            if response = mrYes then SelectItemBtnClick(self) else SkipBtnClick(self);
          end;
        end;
  end;
end;

procedure TTestSpecsForm.SkipBtnClick(Sender: TObject);
begin
  ShowMessage('Item skipped');
end;

procedure TTestSpecsForm.ShowMCItem(AIndex : integer);
var
  nochoices: integer;
begin
  ItemNoEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[AIndex].itemnumber);
  MajorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[AIndex].MajorCode);
  MinorCodeEdit.Text := IntToStr(ItemBankFrm.MCItemInfo[AIndex].MinorCode);

  Memo.Lines.Clear;
  Memo.Lines.Add(ItemBankFrm.MCItemInfo[AIndex].ItemStem);

  nochoices := ItemBankFrm.MCItemInfo[AIndex].NoChoices ;
  if nochoices > 0 then
    Memo.Lines.Add(Format('Choice A %s', [ItemBankFrm.MCItemInfo[AIndex].ChoiceOne]));
  if nochoices > 1 then
    Memo.Lines.Add(Format('Choice B %s', [ItemBankFrm.MCItemInfo[AIndex].ChoiceTwo]));
  if nochoices > 2 then
    Memo.Lines.Add(Format('Choice C %s', [ItemBankFrm.MCItemInfo[AIndex].ChoiceThree]));
  if nochoices > 3 then
    Memo.Lines.Add(Format('Choice D %s', [ItemBankFrm.MCItemInfo[AIndex].ChoiceFour]));
  if nochoices > 4 then
    Memo.Lines.Add(Format('Choice E %s', [ItemBankFrm.MCItemInfo[AIndex].ChoiceFive]));
  Memo.Lines.Add(Format('Correct Choice %s', [ItemBankFrm.MCItemInfo[AIndex].CorrectChoice]));
  Memo.Lines.Add(Format('Graphic Image %s', [ItemBankFrm.MCItemInfo[AIndex].PicName]));
end;

procedure TTestSpecsForm.ShowTFItem(AIndex : integer);
begin
  ItemNoEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[AIndex].itemnumber);
  MajorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[AIndex].MajorCode);
  MinorCodeEdit.Text := IntToStr(ItemBankFrm.TFItemInfo[AIndex].MinorCode);

  Memo.Lines.Clear;
  Memo.Lines.Add(ItemBankFrm.TFItemInfo[AIndex].ItemStem);
  Memo.Lines.Add(ItemBankFrm.TFItemInfo[AIndex].CorrectChoice);
  Memo.Lines.Add(ItemBankFrm.TFItemInfo[AIndex].PicName);
end;

procedure TTestSpecsForm.ShowEssayItem(AIndex : integer);
begin
  ItemNoEdit.Text := IntToStr(ItemBankFrm.EssayInfo[AIndex].itemnumber);
  MajorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[AIndex].MajorCode);
  MinorCodeEdit.Text := IntToStr(ItemBankFrm.EssayInfo[AIndex].MinorCode);

  Memo.Lines.Clear;
  Memo.Lines.Add(ItemBankFrm.EssayInfo[Aindex].ItemStem);
  Memo.Lines.Add(ItemBankFrm.EssayInfo[AIndex].Answer);
  Memo.Lines.Add(ItemBankFrm.EssayInfo[AIndex].PicName);
end;

procedure TTestSpecsForm.ShowMatchItem(AIndex : integer);
var
  noleft, noright: integer;
begin
  noleft := ItemBankFrm.MatchInfo[AIndex].NLeft;
  noright := ItemBankFrm.MatchInfo[AIndex].NRight;
  ItemNoEdit.Text := IntToStr(ItemBankFrm.MatchInfo[AIndex].itemnumber);
  MajorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[AIndex].MajorCode);
  MinorCodeEdit.Text := IntToStr(ItemBankFrm.MatchInfo[AIndex].MinorCode);

  // do left and right stems
  Memo.Lines.Clear;
  if noleft > 0 then
    Memo.Lines.Add(Format('Left Item 1 %s', [ItemBankFrm.MatchInfo[AIndex].Left1]));
  if noright > 0 then
    Memo.Lines.Add(Format('   Right Item 1 %s', [ItemBankFrm.MatchInfo[AIndex].Right1]));
  if noleft > 1 then
    Memo.Lines.Add(Format('Left Item 2 %s', [ItemBankFrm.MatchInfo[AIndex].Left2]));
  if noright > 1 then
    Memo.Lines.Add(Format('   Right Item 2 %s', [ItemBankFrm.MatchInfo[AIndex].Right2]));
  if noleft > 2 then
    Memo.Lines.Add(Format('Left Item 3 %s', [ItemBankFrm.MatchInfo[AIndex].Left3]));
  if noright > 2 then
    Memo.Lines.Add(Format('   Right Item 3 %s', [ItemBankFrm.MatchInfo[AIndex].Right3]));
  if noleft > 3 then
    Memo.Lines.Add(Format('Left Item 4 %s', [ItemBankFrm.MatchInfo[AIndex].Left4]));
  if noright > 3 then
    Memo.Lines.Add(Format('   Right Item 4 %s', [ItemBankFrm.MatchInfo[AIndex].Right4]));
  if noleft > 4 then
    Memo.Lines.Add(Format('Left Item 5 %s', [ItemBankFrm.MatchInfo[AIndex].Left5]));
  if noright > 4 then
    Memo.Lines.Add(Format('   Right Item 5 %s', [ItemBankFrm.MatchInfo[AIndex].Right5]));
  Memo.Lines.Add(ItemBankFrm.MatchInfo[AIndex].CorrectChoice);
  Memo.Lines.Add(ItemBankFrm.MatchInfo[AIndex].PicName);
end;

initialization
  {$I testspecsunit.lrs}

end.

