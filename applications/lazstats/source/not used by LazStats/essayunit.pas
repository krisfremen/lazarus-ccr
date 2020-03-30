unit EssayUnit;

{$MODE Delphi}

interface

uses
  //Windows, Messages,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ItemBankGlobals, ExtDlgs, FunctionsUnit;

type
  TEssayFrm = class(TForm)
    Label2: TLabel;
    ItemNoEdit: TEdit;
    ItemNoScroll: TScrollBar;
    Label1: TLabel;
    CodeCombo: TComboBox;
    Label14: TLabel;
    BMPFileEdit: TEdit;
    Label15: TLabel;
    BrowseBtn: TButton;
    ClearBtn: TButton;
    Label16: TLabel;
    BMPImage: TImage;
    Label18: TLabel;
    ItemWeightEdit: TEdit;
    Panel1: TPanel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    PcntEdit: TEdit;
    IRT1Edit: TEdit;
    IRT2Edit: TEdit;
    IRT3Edit: TEdit;
    NoSelEdit: TEdit;
    Label3: TLabel;
    StemMemo: TMemo;
    NewBtn: TButton;
    SaveBtn: TButton;
    DeleteBtn: TButton;
    ReturnBtn: TButton;
    AnswerMemo: TMemo;
    Label4: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    Label5: TLabel;
    SymbolBox: TListBox;
    Label6: TLabel;
    OpenDialog1: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure ShowEssayItem(Sender: TObject; itemno : integer);
    procedure ReturnBtnClick(Sender: TObject);
    procedure NewBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure LoadRecord(VAR NewRcd : EssayItemRcd; Sender : TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure BrowseBtnClick(Sender: TObject);
    procedure ItemNoScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ClearBtnClick(Sender: TObject);
    procedure SymbolBoxClick(Sender: TObject);
    procedure StemMemoEnter(Sender: TObject);
    procedure AnswerMemoEnter(Sender: TObject);
  private
    { Private declarations }
    maxitems : integer;
    ARcd : EssayItemRcd;
    symbol : char;
    EditBox : integer;
  public
    { Public declarations }
  end;

var
  EssayFrm: TEssayFrm;

implementation

{$R *.lfm}

procedure TEssayFrm.FormShow(Sender: TObject);
var
   F : TextFile;
   S  : string;
   TF : File of EssayItemRcd;
   i : integer;
begin
      StemMemo.Clear;
      AnswerMemo.Clear;
      ItemNoScroll.Min := 1;
      ItemNoScroll.Max := 1;
      ItemNoEdit.Text := '1';
      ItemNoScroll.Position := 1;
      CodeCombo.Text := '';
      BMPFileEdit.Text := '';
      PcntEdit.Text := '0';
      IRT1Edit.Text := '0';
      IRT2Edit.Text := '0';
      IRT3Edit.Text := '0';
      NoSelEdit.Text := '0';
      ItemWeightEdit.Text := '0';
      maxitems := 0;
     OpenDialog1.DefaultExt := '.COD';
     OpenDialog1.Filter := 'Code files (*.cod)|*.COD|Text files (*.txt)|*.TXT|All files (*.*)|*.*';
     OpenDialog1.FilterIndex := 1;
     OpenDialog1.FileName := BankPath + ExtractFileName(BankName) + '.COD';
     OpenDialog1.Title := 'Name of Item Code File:';
     if OpenDialog1.Execute then
     begin
           AssignFile(F,OpenDialog1.filename);
           ReSet(F);
           while not EOF(F) do
           begin
                readln(F,S);
                CodeCombo.Items.Add(S);
           end;
      end
      else begin
           ShowMessage('You must first open a file of item codes.');
           exit;
      end;
      CloseFile(F);
      S := BankPath + 'EssayFile' + ExtractFileName(BankName);
      EssayFName := S;
      if FileExists(S) { *Converted from FileExists*  } then
      begin
           AssignFile(TF,S);
           Reset(TF);
           while not EOF(TF) do
           begin
                read(TF,EssayItem);
                maxitems := maxitems + 1;
           end;
           CloseFile(TF);
           if maxitems > ItemNoScroll.Max then
                ItemNoScroll.Max := maxitems;
           ItemNoScroll.Min := 1;
      end
      else begin // create empty file
           AssignFile(TF,S);
           rewrite(TF);
           CloseFile(TF);
      end;
      for i := 1 to 20 do ARcd.BestAns[i] := '';
      if maxitems > 0 then
      begin
           ItemNoScroll.Position := 1;
           ShowEssayItem(self,1);
      end;
      SymbolBox.Clear;
      for i := 127 to 255 do SymbolBox.Items.Add(chr(ord(i)));
end;
//-------------------------------------------------------------------

procedure TEssayFrm.ShowEssayItem(Sender: TObject; itemno : integer);
var
   S : string;
   F : File of EssayItemRcd;
   where : longint;
   Frecd : EssayItemRcd;
   i : integer;

begin
     ItemNoEdit.Text := IntToStr(ItemNoScroll.Position);
     S := BankPath + 'EssayFile' + ExtractFileName(BankName);
     AssignFile(F,S);
     Reset(F);
     where := itemno-1;
     Seek(F,where);
     read(F,FRecd);
     CloseFile(F);
     CodeCombo.Text := Frecd.Code;
     BMPFileEdit.Text := Frecd.Picture;
     PcntEdit.Text := FloatToStr(Frecd.PcntPass);
     if BMPFileEdit.Text <> '' then
     begin
        if FileExists(Frecd.Picture) { *Converted from FileExists*  } then
        begin
             BMPImage.Picture.LoadFromFile(Frecd.Picture);
             BMPImage.Visible := true;
        end
        else begin
//             ShowMessage('Image ' + Frecd.Picture + ' not found.');
             BMPFileEdit.Text := '';
             Frecd.Picture := '';
        end;
     end
     else BMPImage.Visible := false;
     ItemWeightEdit.Text := IntToStr(Frecd.ItemWeight);
     IRT1Edit.Text := FloatToStr(Frecd.IRT[1]);
     IRT2Edit.Text := FloatToStr(Frecd.IRT[2]);
     IRT3Edit.Text := FLoatToStr(Frecd.IRT[3]);
     StemMemo.Clear;
     for i := 1 to 20 do
     begin
          S := Frecd.ItemStem[i];
          if length(S) > 0 then StemMemo.Lines.Add(S);
     end;
     AnswerMemo.Clear;
     for i := 1 to 20 do
     begin
          S := Frecd.BestAns[i];
          if length(S) > 0 then AnswerMemo.Lines.Add(S);
     end;
end;
//-------------------------------------------------------------------

procedure TEssayFrm.ReturnBtnClick(Sender: TObject);
begin
     EssayFrm.Hide;
end;
//-------------------------------------------------------------------

procedure TEssayFrm.NewBtnClick(Sender: TObject);
begin
      StemMemo.Clear;
      AnswerMemo.Clear;
      ItemNoScroll.Max := maxitems + 1;
      ItemNoScroll.Position := ItemNoScroll.Max;
      ItemNoEdit.Text := IntToStr(ItemNoScroll.Position);
      CodeCombo.Text := '';
      BMPFileEdit.Text := '';
      BMPImage.Visible := false;
      PcntEdit.Text := '0';
      IRT1Edit.Text := '0';
      IRT2Edit.Text := '0';
      IRT3Edit.Text := '0';
      NoSelEdit.Text := '0';
      ItemWeightEdit.Text := '0';
      BMPImage.Visible := false;
end;
//-------------------------------------------------------------------

procedure TEssayFrm.SaveBtnClick(Sender: TObject);
var
   NewRcd : EssayItemRcd;
   itemno : integer;

begin
     itemno := ItemNoScroll.Position;
     LoadRecord(NewRcd,self);
     WriteESItem(itemno,NewRcd);
     if itemno > maxitems then
     begin
          maxitems := itemno;
          ItemNoScroll.Max := maxitems+1;
     end;
end;
//-------------------------------------------------------------------

procedure TEssayFrm.LoadRecord(VAR NewRcd : EssayItemRcd; Sender : TObject);
var
   i : integer;
   S : string;
begin
     NewRcd.ItemNo := ItemNoScroll.Position;
     NewRcd.Code := CodeCombo.Text;
     for i := 0 to StemMemo.Lines.Count-1 do
     begin
          S := Trim(StemMemo.Lines[i]);
          NewRcd.ItemStem[i+1] := S;
     end;
     if StemMemo.Lines.Count < 20 then
          for i := StemMemo.Lines.Count+1 to 20 do NewRcd.ItemStem[i] := '';
     for i := 0 to AnswerMemo.Lines.Count-1 do
     begin
          S := Trim(AnswerMemo.Lines[i]);
          NewRcd.BestAns[i+1] := S;
     end;
     if AnswerMemo.Lines.Count < 20 then
        for i := AnswerMemo.Lines.Count+1 to 20 do NewRcd.BestAns[i] := '';
     NewRcd.ItemWeight := StrToInt(ItemWeightEdit.Text);
     NewRcd.Picture := BMPFileEdit.Text;
     NewRcd.PcntPass := StrToFloat(PcntEdit.Text);
     NewRcd.IRT[1] := StrToFloat(IRT1Edit.Text);
     NewRcd.IRT[2] := StrToFloat(IRT2Edit.Text);
     NewRcd.IRT[3] := StrToFloat(IRT3Edit.Text);
     NewRcd.FreqElect := StrToInt(NoSelEdit.Text);
end;
//-------------------------------------------------------------------

procedure TEssayFrm.DeleteBtnClick(Sender: TObject);
var
   FOld : File of EssayItemRcd;
   FNew : File of EssayItemRcd;
   itemno : integer;
   i : integer;
   SOld : string;
   SNew : string;

begin
     itemno := ItemNoScroll.Position;
     SOld := BankPath + 'EssayFile' + ExtractFileName(BankName);
     AssignFile(FOld,SOld);
     ReSet(FOld);
     SNew := BankPath + 'TempEssayFile';
     AssignFile(FNew,SNew);
     Rewrite(FNew);
     // copy up to itemno from old file to new file
     for i := 1 to itemno-1 do
     begin
          if not EOF(FOld) then
          begin
               read(FOld,ARcd);
               write(FNew,ARcd);
          end;
     end;
     // read past itemno to delete
     if not EOF(FOld) then read(FOld,ARcd);
     // write remaining records, if any, from old to new
     if not EOF(FOld) then
     begin
          while not EOF(FOld) do
          begin
               read(FOld,ARcd);
               write(FNew,ARcd);
          end;
     end;
     CloseFile(FOld);
     CloseFile(FNew);
     // delete old file and rename temp file to old file name
     DeleteFile(SOld); { *Converted from DeleteFile*  }
     RenameFile(SNew, Sold); { *Converted from RenameFile*  }
     maxitems := maxitems - 1;
     if maxitems > 0 then ItemNoScroll.Max := maxitems else
        ItemNoScroll.Max := 1;
end;
//-------------------------------------------------------------------

procedure TEssayFrm.BrowseBtnClick(Sender: TObject);
begin
     if OpenPictureDialog1.Execute then
     begin
          BMPFileEdit.Text := OpenPictureDialog1.FileName;
          BMPImage.Picture.LoadFromFile(BMPFileEdit.Text);
          BMPImage.Visible := true;
     end;
end;
//-------------------------------------------------------------------

procedure TEssayFrm.ItemNoScrollScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
var
   itemno : integer;
begin
     itemno := ScrollPos;
     if (itemno > maxitems) or (itemno < 1) then exit;
     ItemNoEdit.Text := IntToStr(itemno);
     ShowEssayItem(self,itemno);
end;
//-------------------------------------------------------------------

procedure TEssayFrm.ClearBtnClick(Sender: TObject);
begin
     BMPFileEdit.Text := '';
     BMPImage.Visible := false;
end;
//-------------------------------------------------------------------

procedure TEssayFrm.SymbolBoxClick(Sender: TObject);
var
   index : integer;
   S : string;
begin
     if EditBox = 1 then
     begin
          index := SymbolBox.ItemIndex;
          S := SymbolBox.Items.Strings[index];
          symbol := S[1];
          index := StemMemo.Lines.Count;
          if index > 0 then
          begin
               S := StemMemo.Lines.Strings[index-1];
               StemMemo.Lines.Delete(index-1);
               S := S + symbol;
               StemMemo.Lines.Insert(index-1,S);
          end
          else begin
               S := StemMemo.Lines.Strings[0];
               StemMemo.Lines.Delete(0);
               S := S + symbol;
               StemMemo.Lines.Add(S);
          end;
     end
     else begin
          index := SymbolBox.ItemIndex;
          S := SymbolBox.Items.Strings[index];
          symbol := S[1];
          index := AnswerMemo.Lines.Count;
          if index > 0 then
          begin
               S := AnswerMemo.Lines.Strings[index-1];
               AnswerMemo.Lines.Delete(index-1);
               S := S + symbol;
               AnswerMemo.Lines.Insert(index-1,S);
          end
          else begin
               S := AnswerMemo.Lines.Strings[0];
               AnswerMemo.Lines.Delete(0);
               S := S + symbol;
               AnswerMemo.Lines.Add(S);
          end;
     end;
end;
//-------------------------------------------------------------------

procedure TEssayFrm.StemMemoEnter(Sender: TObject);
begin
     EditBox := 1;
end;
//-------------------------------------------------------------------

procedure TEssayFrm.AnswerMemoEnter(Sender: TObject);
begin
     EditBox := 2;
end;
//-------------------------------------------------------------------

end.
