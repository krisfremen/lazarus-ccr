unit ItemBankingUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Menus, StdCtrls, FileCtrl,
  Globals, OutputUnit, ItemCodesUnit, TFItemUnit, EssayItemUnit,
  MCItemUnit, MatchItemUnit, TestSpecsUnit;

type
  Bank = Record
    BankName : string;
    NMCItems : integer;
    NTFItems : integer;
    NMatchItems : integer;
    NEssayItems : integer;
    NCodes : integer;
    TestItems : integer;
  end;

type
  MCItem = Record
    ItemNumber : integer;
    MajorCode : integer;
    MinorCode : integer;
    NoChoices : integer;
    ItemStem  : string;
    ChoiceOne : string;
    ChoiceTwo : string;
    ChoiceThree : string;
    ChoiceFour : string;
    ChoiceFive : string;
    CorrectChoice : char;
    PicName : string;
  end;

type
  TFItem = Record
    ItemNumber : integer;
    MajorCode : integer;
    MinorCode : integer;
    ItemStem  : string;
    CorrectChoice : char;
    PicName   : string;
  end;

type
  MatchItem = Record
    ItemNumber : integer;
    MajorCode : integer;
    MinorCode : integer;
    NLeft : integer;
    NRight : integer;
    Left1 : string;
    Left2 : string;
    Left3 : string;
    Left4 : string;
    Left5 : string;
    Right1 : string;
    Right2 : string;
    Right3 : string;
    Right4 : string;
    Right5 : string;
    CorrectChoice : char;
    PicName : string;
  end;

type
  EssayItem = Record
    ItemNumber : integer;
    MajorCode : integer;
    MinorCode : integer;
    ItemStem  : string;
    Answer    : string;
    PicName   : string;
  end;


type CodeData = record
  codenumber : integer;
  majorcodes : integer;
  minorcodes : integer;
  Description : string;
end;
type testspec = record
  ItemNumber : integer;
  MajorCode : integer;
  MinorCode : integer;
  ItemType : string;
end;

type

  { TItemBankFrm }

  TItemBankFrm = class(TForm)
    BankNameLabel: TLabel;
    BankNameText: TEdit;
    Button1: TButton;
    DirectoryEdit1: TEdit;
    NSpecifiedEdit: TEdit;
    Label3: TLabel;
    TestSpecifiedEdit: TEdit;
    FileListBox1: TFileListBox;
    FilesLabel: TLabel;
    Label2: TLabel;
    ShowCodes: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveBankMenu: TMenuItem;
    NEssayText: TEdit;
    NEssayLabel: TLabel;
    NMatchItemsText: TEdit;
    NMatchLabel: TLabel;
    NTFItemsText: TEdit;
    SaveDialog1: TSaveDialog;
    SelDir: TSelectDirectoryDialog;
    TFItemsLabel: TLabel;
    NMCItemsText: TEdit;
    NMCItemsLabel: TLabel;
    NItemCodesText: TEdit;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MCItems: TMenuItem;
    MatchingItems: TMenuItem;
    EssayItems: TMenuItem;
    ListItems: TMenuItem;
    ExitThis: TMenuItem;
    CreateCodes: TMenuItem;
    PrintTest: TMenuItem;
    TestSpecs: TMenuItem;
    TestOptions: TMenuItem;
    TFItems: TMenuItem;
    Operations: TMenuItem;
    NewItemBank: TMenuItem;
    OpenItemBank: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure CreateCodesClick(Sender: TObject);
    procedure EssayItemsClick(Sender: TObject);
    procedure ExitThisClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListItemsClick(Sender: TObject);
    procedure MatchingItemsClick(Sender: TObject);
    procedure MCItemsClick(Sender: TObject);
    procedure NewItemBankClick(Sender: TObject);
    procedure OpenItemBankClick(Sender: TObject);
    procedure PrintTestClick(Sender: TObject);
    procedure SaveBankMenuClick(Sender: TObject);
    procedure ShowCodesClick(Sender: TObject);
    procedure TestSpecsClick(Sender: TObject);
    procedure TFItemsClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    CodesInfo  : array[1..100] of CodeData;
    MCItemInfo : array[1..100] of MCItem;
    TFItemInfo : array[1..100] of TFItem;
    MatchInfo  : array[1..100] of MatchItem;
    EssayInfo  : array[1..100] of EssayItem;
    TestContents  : array[1..100] of testspec;
    BankInfo : Bank;
 //   FileName : string;

  end; 

var
  ItemBankFrm: TItemBankFrm;

implementation

{ TItemBankFrm }

procedure TItemBankFrm.OpenItemBankClick(Sender: TObject);
var
  FileName : string;
  BankFile : TextFile;
  i : integer;
  cellvalue : integer;
  nochoices : integer;
begin
  OpenDialog1.DefaultExt := '.BNK';
  OpenDialog1.Filter := 'ALL (*.*)|*.*|Item Bank (*.BNK)|*.BNK';
  OpenDialog1.FilterIndex := 2;
  if OpenDialog1.Execute then
  begin
       FileName := OpenDialog1.FileName;
       BankNameText.Text := FileName;
       FileName := OpenDialog1.FileName;
       AssignFile(BankFile,FileName);
       Reset(BankFile);
       // place all data from the records in this file
       // read general BankInfo first
       Readln(BankFile,BankInfo.BankName);
       Readln(BankFile,BankInfo.NMCItems);
       NMCItemsText.Text := IntToStr(BankInfo.NMCItems);
       Readln(BankFile,BankInfo.NTFItems);
       NTFItemsText.Text := IntToStr(BankInfo.NTFItems);
       Readln(BankFile,BankInfo.NMatchItems);
       NMatchItemsText.Text := IntToStr(BankInfo.NMatchItems );
       Readln(BankFile,BankInfo.NEssayItems);
       NEssayText.Text := IntToStr(BankInfo.NEssayItems );
       Readln(BankFile,BankInfo.NCodes);
       NItemCodesText.Text := IntToStr(BankInfo.NCodes);
       Readln(BankFile,BankInfo.TestItems);
       NSpecifiedEdit.Text := IntToStr(BankInfo.TestItems);
//       ShowMessage('Read no. of items by type');
       // now read codes
       if BankInfo.Ncodes > 0 then
       begin
            for i := 1 to BankInfo.NCodes do
            begin
                 Readln(BankFile,cellvalue);
                 CodesInfo[i].codenumber := cellvalue;
                 Readln(BankFile,cellvalue);
                 CodesInfo[i].majorcodes := cellvalue;
                 Readln(BankFile,cellvalue);
                 CodesInfo[i].minorcodes := cellvalue;
                 Readln(BankFile,CodesInfo[i].Description);
            end;
//            ShowMessage('Read item codes');
       end;
       // now read MC items
       if BankInfo.NMCItems > 0 then
       begin
            for i := 1 to BankInfo.NMCItems do
            begin
                 Readln(BankFile,MCItemInfo[i].ItemNumber);
                 Readln(BankFile,MCItemInfo[i].MajorCode);
                 Readln(BankFile,MCItemInfo[i].MinorCode);
                 Readln(BankFile,MCItemInfo[i].NoChoices);
                 Readln(BankFile,MCItemInfo[i].ItemStem);
                 nochoices := McItemInfo[i].NoChoices;
                 if nochoices > 0 then Readln(BankFile,MCItemInfo[i].ChoiceOne);
                 if nochoices > 1 then Readln(BankFile,MCItemInfo[i].ChoiceTwo);
                 if nochoices > 2 then Readln(BankFile,MCItemInfo[i].ChoiceThree);
                 if nochoices > 3 then Readln(BankFile,MCItemInfo[i].ChoiceFour);
                 if nochoices > 4 then Readln(BankFile,MCItemInfo[i].ChoiceFive);
                 Readln(BankFile,MCItemInfo[i].CorrectChoice);
                 Readln(BankFile,MCItemInfo[i].PicName);
            end;
//            ShowMessage('Read MC items');
       end;
       // now read T-F items
       if BankInfo.NTFItems > 0 then
       begin
            for i := 1 to BankInfo.NTFItems do
            begin
                 readln(BankFile,TFItemInfo[i].ItemNumber);
                 Readln(BankFile,TFItemInfo[i].MajorCode);
                 Readln(BankFile,TFItemInfo[i].MinorCode);
                 Readln(BankFile,TFItemInfo[i].ItemStem);
                 Readln(BankFile,TFItemInfo[i].CorrectChoice);
                 Readln(BankFile,TFItemInfo[i].PicName);
            end;
//            ShowMessage('Read True-False items');
       end;
       // now read matching items
       if BankInfo.NMatchItems > 0 then
       begin
            for i := 1 to BankInfo.NMatchItems do
            begin
                 Readln(BankFile,MatchInfo[i].ItemNumber);
                 Readln(BankFile,MatchInfo[i].MajorCode);
                 Readln(BankFile,MatchInfo[i].MinorCode);
                 Readln(BankFile,MatchInfo[i].NLeft);
                 Readln(BankFile,MatchInfo[i].NRight);
                 nochoices := MatchInfo[i].NLeft;
                 if nochoices > 0 then Readln(BankFile,MatchInfo[i].Left1);
                 if nochoices > 1 then Readln(BankFile,MatchInfo[i].Left2);
                 if nochoices > 2 then Readln(BankFile,MatchInfo[i].Left3);
                 if nochoices > 3 then Readln(BankFile,MatchInfo[i].Left4);
                 if nochoices > 4 then Readln(BankFile,MatchInfo[i].Left5);
                 nochoices := MatchInfo[i].NRight;
                 if nochoices > 0 then Readln(BankFile,MatchInfo[i].Right1);
                 if nochoices > 1 then Readln(BankFile,MatchInfo[i].Right2);
                 if nochoices > 2 then Readln(BankFile,MatchInfo[i].Right3);
                 if nochoices > 3 then Readln(BankFile,MatchInfo[i].Right4);
                 if nochoices > 4 then Readln(BankFile,MatchInfo[i].Right5);
                 Readln(BankFile,MatchInfo[i].CorrectChoice);
                 Readln(BankFile,MatchInfo[i].PicName);
            end;
//            ShowMessage('Read Matching items');
       end;
       // now read essay items
       if BankInfo.NEssayItems > 0 then
       begin
            for i := 1 to BankInfo.NEssayItems do
            begin
                 Readln(BankFile,EssayInfo[i].ItemNumber);
                 Readln(BankFile,EssayInfo[i].MajorCode);
                 Readln(BankFile,EssayInfo[i].MinorCode);
                 Readln(BankFile,EssayInfo[i].ItemStem);
                 Readln(BankFile,EssayInfo[i].Answer);
                 Readln(BankFile,EssayInfo[i].PicName);
            end;
//            ShowMessage('Read Essay items');
       end;
       if BankInfo.TestItems > 0 then
       begin
            TestSpecifiedEdit.Text := 'Y';
            for i := 1 to BankInfo.TestItems do
            begin
                 readln(BankFile,TestContents[i].ItemNumber);
                 readln(BankFile,TestContents[i].MajorCode);
                 readln(BankFile,TestContents[i].MinorCode);
                 readln(BankFile,TestContents[i].ItemType);
            end;
       end;
       CloseFile(BankFile);
  end;
end;

procedure TItemBankFrm.PrintTestClick(Sender: TObject);
Var
  outline : string[180];
  i, nmc, ntf, nessay, nmatch, itemno : integer;
  mcitem, tfitem, essayitem, matchitem : integer;
  nleft, nright : integer;
begin
     itemno := 0;
     nmc := StrToInt(NMCItemsText.Text);
     ntf := StrToInt(NTFItemsText.Text);
     nessay := StrToInt(NEssayText.Text);
     nmatch := StrToInt(NMatchItemsText.Text);
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Directions: This test may contain a variety of different item types.');
     OutputFrm.RichEdit.Lines.Add('For each item, circle the correct answer or provide the answer if');
     OutputFrm.RichEdit.Lines.Add('required.  You may use the back of the test to provide answers to');
     OutputFrm.RichEdit.Lines.Add('essay questions - just start with the item number.');
     OutputFrm.RichEdit.Lines.Add('Start now!');
     OutputFrm.RichEdit.Lines.Add('');
     if nmc > 0 then
     begin
          OutputFrm.RichEdit.Lines.Add('MULTIPLE CHOICE ITEMS:');
          for i := 1 to BankInfo.TestItems do
          begin
               if TestContents[i].ItemType = 'MC' then
               begin
                    itemno := itemno + 1;
                    outline := format('Item %d',[itemno]);
                    OutputFrm.RichEdit.Lines.Add(outline);
                    mcitem := TestContents[i].ItemNumber;
                    if MCItemInfo[mcitem].PicName <> 'none' then
                    begin
                         outline := format('Reference picture = %s',[MCItemInfo[mcitem].PicName]);
                         OutputFrm.RichEdit.Lines.Add(outline);
                    end;
                   { begin
                         Grect.Top := OutputFrm.RichEdit.Lines.Count ;
                         Grect.Left := 20;
                         Grect.Right := 120;
                         Grect.Bottom := Grect.Top + 120;
                         JPEG := TJPEGImage.Create;
                         JPEG.LoadFromFile(MCItemInfo[mcitem].PicName) ;
                         OutputFrm.Canvas.StretchDraw(Grect,JPEG);
                         JPEG.Free;
                    end; }
                    OutputFrm.RichEdit.Lines.Add(MCItemInfo[mcitem].ItemStem);
                    nleft := MCItemInfo[mcitem].NoChoices;
                    OutputFrm.RichEdit.Lines.Add('A. ' + MCItemInfo[mcitem].ChoiceOne);
                    OutputFrm.RichEdit.Lines.Add('B. ' + MCItemInfo[mcitem].ChoiceTwo);
                    if nleft > 2 then
                       OutputFrm.RichEdit.Lines.Add('C. ' + MCItemInfo[mcitem].ChoiceThree);
                    if nleft > 3 then
                       OutputFrm.RichEdit.Lines.Add('D. ' + MCItemInfo[mcitem].ChoiceFour);
                    if nleft > 4 then
                       OutputFrm.RichEdit.Lines.Add('E. ' + MCItemInfo[mcitem].ChoiceFive);
                    OutputFrm.RichEdit.Lines.Add('');
               end;
          end;
     end;
     if ntf > 0 then
     begin
          OutputFrm.RichEdit.Lines.Add('');
          OutputFrm.RichEdit.Lines.Add('TRUE OR FALSE ITEMS:');
          for i := 1 to BankInfo.TestItems do
          begin
               if TestContents[i].ItemType = 'TF' then
               begin
                 itemno := itemno + 1;
                 outline := format('Item %d',[itemno]);
                 OutputFrm.RichEdit.Lines.Add(outline);
                 tfitem := TestContents[i].ItemNumber;
                 OutputFrm.RichEdit.Lines.Add(TFItemInfo[tfitem].ItemStem);
                 OutputFrm.RichEdit.Lines.Add('A.  TRUE');
                 OutputFrm.RichEdit.Lines.Add('B.  False');
               end;
          end;
          OutputFrm.RichEdit.Lines.Add('');
     end;
     if nessay > 0 then
     begin
       OutputFrm.RichEdit.Lines.Add('');
       OutputFrm.RichEdit.Lines.Add('ESSAY ITEMS:');
       for i := 1 to BankInfo.TestItems do
       begin
            if TestContents[i].ItemType = 'Essay' then
            begin
              itemno := itemno + 1;
              outline := format('Item %d',[itemno]);
              OutputFrm.RichEdit.Lines.Add(outline);
              essayitem := TestContents[i].ItemNumber;
              OutputFrm.RichEdit.Lines.Add(EssayInfo[essayitem].ItemStem);
            end;
       end;
       OutputFrm.RichEdit.Lines.Add('');
     end;
     if nmatch > 0 then
     begin
       OutputFrm.RichEdit.Lines.Add('MATCHING ITEMS:');
       for i := 1 to BankInfo.TestItems do
       begin
            if TestContents[i].ItemType = 'Matching' then
            begin
              itemno := itemno + 1;
              outline := format('Item %d',[itemno]);
              OutputFrm.RichEdit.Lines.Add(outline);
              matchitem := TestContents[i].ItemNumber;
              outline := format('A. %s',[ItemBankFrm.MatchInfo[matchitem].Left1]);
              outline := outline + '     1. ';
              outline := outline + ItemBankFrm.MatchInfo[matchitem].Right1 ;
              OutputFrm.RichEdit.Lines.Add(outline);
              outline := format('B. %s',[ItemBankFrm.MatchInfo[matchitem].Left2]);
              nleft := ItemBankFrm.MatchInfo[matchitem].NLeft;
              nright := ItemBankFrm.MatchInfo[matchitem].NRight;
              if nright > 1 then
              begin
                   outline := outline + '     2. ';
                   outline := outline + ItemBankFrm.MatchInfo[matchitem].Right2;
              end;
              OutputFrm.RichEdit.Lines.Add(outline);
              if nleft > 2 then
              begin
                   outline := format('C. %s',[ItemBankFrm.MatchInfo[matchitem].Left3]);
                   if nright > 2 then
                   begin
                     outline := outline + '     3. ';
                     outline := outline + ItemBankFrm.MatchInfo[matchitem].Right3;
                   end;
                   OutputFrm.RichEdit.Lines.Add(outline);
              end;

              if nleft > 3 then
              begin
                      outline := format('D. %s',[ItemBankFrm.MatchInfo[matchitem].Left4]);
                      if nright > 3 then
                      begin
                        outline := outline + '     4. ';
                        outline := outline + ItemBankFrm.MatchInfo[matchitem].Right4;
                      end;
                      OutputFrm.RichEdit.Lines.Add(outline);
              end;

              if nleft > 4 then
              begin
                      outline := format('E. %s',[ItemBankFrm.MatchInfo[matchitem].Left5]);
                      if nright > 4 then
                      begin
                        outline := outline + '     5. ';
                        outline := outline + ItemBankFrm.MatchInfo[matchitem].Right5;
                      end;
                      OutputFrm.RichEdit.Lines.Add(outline);
              end;

            end;
//            OutputFrm.RichEdit.Lines.Add('');
       end;
       OutputFrm.RichEdit.Lines.Add('');
     end;
     OutputFrm.ShowModal;
end;

procedure TItemBankFrm.SaveBankMenuClick(Sender: TObject);
var
  FileName : string;
  BankFile : TextFile;
  i : integer;
  cellvalue : integer;
  nochoices : integer;
  nspecs : integer;
begin
     if BankNameText.Text = '' then Close;
     SaveDialog1.DefaultExt := '.BNK';
     SaveDialog1.Filter := 'ALL (*.*)|*.*|ItemBank (*.BNK)|*.BNK';
     SaveDialog1.FilterIndex := 2;
     if SaveDialog1.Execute then
     begin
       FileName := SaveDialog1.FileName;
       AssignFile(BankFile,FileName);
       Rewrite(BankFile);
       BankInfo.BankName := FileName;
       // place all data from the records in this file
       // write general BankInfo first
       writeln(BankFile,BankInfo.BankName);
       writeln(BankFile,BankInfo.NMCItems);
       writeln(BankFile,BankInfo.NTFItems);
       writeln(BankFile,BankInfo.NMatchItems);
       writeln(BankFile,BankInfo.NEssayItems);
       writeln(BankFile,BankInfo.NCodes);
       writeln(BankFile,BankInfo.TestItems);
       // now save codes
       if BankInfo.NCodes > 0 then
       begin
            for i := 1 to BankInfo.NCodes do
            begin
                 cellvalue := CodesInfo[i].codenumber;
                 writeln(BankFile,cellvalue);
                 cellvalue := CodesInfo[i].majorcodes ;
                 writeln(BankFile,cellvalue);
                 cellvalue := CodesInfo[i].minorcodes;
                 writeln(BankFile,cellvalue);
                 writeln(BankFile,CodesInfo[i].Description);
            end;
       end;
       // now save MC items
       if BankInfo.NMCItems > 0 then
       begin
            for i := 1 to BankInfo.NMCItems do
            begin
                 nochoices := MCItemInfo[i].NoChoices ;
                 writeln(BankFile,MCItemInfo[i].ItemNumber);
                 writeln(BankFile,MCItemInfo[i].MajorCode);
                 writeln(BankFile,MCItemInfo[i].MinorCode);
                 writeln(BankFile,MCItemInfo[i].NoChoices);
                 writeln(BankFile,MCItemInfo[i].ItemStem);
                 if nochoices > 0 then writeln(BankFile,MCItemInfo[i].ChoiceOne);
                 if nochoices > 1 then writeln(BankFile,MCItemInfo[i].ChoiceTwo);
                 if nochoices > 2 then writeln(BankFile,MCItemInfo[i].ChoiceThree);
                 if nochoices > 3 then writeln(BankFile,MCItemInfo[i].ChoiceFour);
                 if nochoices > 4 then writeln(BankFile,MCItemInfo[i].ChoiceFive);
                 writeln(BankFile,MCItemInfo[i].CorrectChoice);
                 writeln(BankFile,MCItemInfo[i].PicName);
            end;
       end;
       // now save T-F items
       if BankInfo.NTFItems > 0 then
       begin
            for i := 1 to BankInfo.NTFItems do
            begin
                 writeln(BankFile,TFItemInfo[i].ItemNumber);
                 writeln(BankFile,TFItemInfo[i].MajorCode);
                 writeln(BankFile,TFItemInfo[i].MinorCode);
                 writeln(BankFile,TFItemInfo[i].ItemStem);
                 writeln(BankFile,TFItemInfo[i].CorrectChoice);
                 writeln(BankFile,TFItemInfo[i].PicName);
            end;
       end;
       // now save matching items
       if BankInfo.NMatchItems > 0 then
       begin
            for i := 1 to BankInfo.NMatchItems do
            begin
                 nochoices := MatchInfo[i].NLeft;
                 Writeln(BankFile,MatchInfo[i].ItemNumber);
                 writeln(BankFile,MatchInfo[i].MajorCode);
                 writeln(BankFile,MatchInfo[i].MinorCode);
                 writeln(BankFile,MatchInfo[i].NLeft);
                 writeln(BankFile,MatchInfo[i].NRight);
                 if nochoices > 0 then writeln(BankFile,MatchInfo[i].Left1);
                 if nochoices > 1 then writeln(BankFile,MatchInfo[i].Left2);
                 if nochoices > 2 then writeln(BankFile,MatchInfo[i].Left3);
                 if nochoices > 3 then writeln(BankFile,MatchInfo[i].Left4);
                 if nochoices > 4 then writeln(BankFile,MatchInfo[i].Left5);
                 nochoices := MatchInfo[i].NRight;
                 if nochoices > 0 then writeln(BankFile,MatchInfo[i].Right1);
                 if nochoices > 1 then writeln(BankFile,MatchInfo[i].Right2);
                 if nochoices > 2 then writeln(BankFile,MatchInfo[i].Right3);
                 if nochoices > 3 then writeln(BankFile,MatchInfo[i].Right4);
                 if nochoices > 4 then writeln(BankFile,MatchInfo[i].Right5);
                 writeln(BankFile,MatchInfo[i].CorrectChoice);
                 writeln(BankFile,MatchInfo[i].PicName);
            end;
       end;
       // now save essay items
       if BankInfo.NEssayItems > 0 then
       begin
            for i := 1 to BankInfo.NEssayItems do
            begin
                 writeln(BankFile,EssayInfo[i].ItemNumber);
                 writeln(BankFile,EssayInfo[i].MajorCode);
                 writeln(BankFile,EssayInfo[i].MinorCode);
                 writeln(BankFile,EssayInfo[i].ItemStem);
                 writeln(BankFile,EssayInfo[i].Answer);
                 writeln(BankFile,EssayInfo[i].PicName);
            end;
       end;
       // now save test specifications
       nspecs := StrToInt(NSpecifiedEdit.Text);
       if nspecs > 0 then
       begin
         TestSpecifiedEdit.Text := 'Y';
         for i := 1 to TestSpecsForm.testno do
         begin
              writeln(BankFile,TestContents[i].ItemNumber);
              writeln(BankFile,TestContents[i].MajorCode);
              writeln(BankFile,TestContents[i].MinorCode);
              writeln(BankFile,TestContents[i].ItemType);
         end;
       end;
       CloseFile(BankFile);
     end;
end;

procedure TItemBankFrm.ShowCodesClick(Sender: TObject);
Var
  i : integer;
  outline : string;
  ncodes : integer;
begin
if NItemCodesText.Text <> '' then
  begin
    OutputFrm.RichEdit.Lines.Add('Current Item Coding Scheme');
    OutputFrm.RichEdit.Lines.Add('');
    ncodes := StrToInt(NItemCodesText.Text);
    for i := 1 to ncodes do
    begin
         outline := format('Code number %d',[i]);
         OutputFrm.RichEdit.Lines.Add(outline);
         outline := format('Major Code %d',[CodesInfo[i].majorcodes]);
         OutputFrm.RichEdit.Lines.Add(outline);
         outline := format('Minor Code %d',[CodesInfo[i].minorcodes]);
         OutputFrm.RichEdit.Lines.Add(outline);
         outline := format('Description %s',[CodesInfo[i].Description]);
         OutputFrm.RichEdit.Lines.Add(outline);
         OutputFrm.RichEdit.Lines.Add('');
    end;
    OutputFrm.ShowModal;
  end;

end;

procedure TItemBankFrm.TestSpecsClick(Sender: TObject);
begin
  if TestSpecsForm = nil then
    Application.CreateForm(TTestSpecsForm, TestSpecsForm);
  TestSpecsForm.SpecFileEdit.Text := BankNameText.Text;
  TestSpecsForm.MCNoEdit.Text := IntToStr(BankInfo.NMCItems);
  TestSpecsForm.TFNoEdit.Text := IntToStr(BankInfo.NTFItems);
  TestSpecsForm.EssayNoEdit.Text := IntToStr(BankInfo.NEssayItems);
  TestSpecsForm.MatchNoEdit.Text := IntToStr(BankInfo.NMatchItems);
  TestSpecsForm.ShowModal;
end;

procedure TItemBankFrm.TFItemsClick(Sender: TObject);
begin
  if TFItemForm = nil then
    Application.CreateForm(TTFItemForm, TFItemForm);
  TFItemForm.ShowModal;
end;

procedure TItemBankFrm.NewItemBankClick(Sender: TObject);
Var
  response : string;
begin
   response := InputBox('SAVE','Save current item bank (Y or N)?','N');
   if response = 'Y' then SaveBankMenuClick(self);
   BankNameText.Text := '';
   OpenItemBankClick(self);
end;

procedure TItemBankFrm.ExitThisClick(Sender: TObject);
Var
  response : string;
begin
   response := InputBox('SAVE','Save current item bank (Y or N)?','N');
   if response = 'Y' then SaveBankMenuClick(self);
   Close;
end;

procedure TItemBankFrm.FormCreate(Sender: TObject);
begin
   Assert(ItemBankFrm <> nil);

  if OutputFrm = nil then
    Application.Createform(TOutputFrm, OutputFrm);

  DirectoryEdit1.Text := Options.DefaultPath;
  FileListBox1.Directory := DirectoryEdit1.Text;
end;

procedure TItemBankFrm.FormShow(Sender: TObject);
begin
     BankNameText.Text := '';
     NItemCodesText.Text := '';
     NMCItemsText.Text := '';
     NTFItemsText.Text := '';
     NMatchItemsText.Text := '';
     NEssayText.Text := '';
     BankInfo.BankName := '';
     BankInfo.NCodes := 0;
     BankInfo.NEssayItems := 0;
     BankInfo.NMatchItems := 0;
     BankInfo.NTFItems := 0;
     BankInfo.NMCItems := 0;
     TestSpecifiedEdit.Text := 'N';
     NSpecifiedEdit.Text := '';
end;

procedure TItemBankFrm.ListItemsClick(Sender: TObject);
Var
  i : integer;
  outline : string;
begin
     if BankInfo.TestItems > 0 then
       begin
         OutputFrm.RichEdit.Clear;
         for i := 1 to BankInfo.TestItems do
         begin
              outline := format('Item number: %d',[TestContents[i].ItemNumber]);
              OutputFrm.RichEdit.Lines.Add(outline);
              outline := format('Major code: %d',[TestContents[i].MajorCode]);
              OutputFrm.RichEdit.Lines.Add(outline);
              outline := format('Minor code: %d',[TestContents[i].MinorCode]);
              OutputFrm.RichEdit.Lines.Add(outline);
              outline := format('Item type: %s',[TestContents[i].ItemType]);
              OutputFrm.RichEdit.Lines.Add(outline);
         end;
     end;
     OutputFrm.ShowModal;
end;

procedure TItemBankFrm.MatchingItemsClick(Sender: TObject);
begin
  if MatchItemForm = nil then
    Application.CreateForm(TMatchItemForm, MatchItemForm);
  MatchItemForm.ShowModal;
end;

procedure TItemBankFrm.MCItemsClick(Sender: TObject);
begin
  if MCItemForm = nil then
    Application.CreateForm(TMCItemForm, MCItemForm);
  MCItemForm.ShowModal;
end;

procedure TItemBankFrm.CreateCodesClick(Sender: TObject);
begin
  if CodesForm = nil then
    Application.CreateForm(TCodesForm, CodesForm);
  CodesForm.ShowModal;
end;

procedure TItemBankFrm.Button1Click(Sender: TObject);
begin
  DirectoryEdit1.Text := Options.DefaultPath;
  FileListBox1.Directory := DirectoryEdit1.Text;
end;

procedure TItemBankFrm.EssayItemsClick(Sender: TObject);
begin
  if EssayItemForm = nil then
    Application.CreateForm(TEssayItemForm, EssayItemForm);
  EssayItemForm.ShowModal;
end;

initialization
  {$I itembankingunit.lrs}

end.

