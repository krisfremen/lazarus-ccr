unit BlankUnit;

{$MODE Delphi}

interface

uses
  //Windows, Messages,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ItemBankGlobals, FunctionsUnit;

type
  TBlankFrm = class(TForm)
    ContinueBtn: TButton;
    Label1: TLabel;
    AnswerEdit: TEdit;
    Image1: TImage;
    AnswerMemo: TMemo;
    procedure ContinueBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
   FontHi, FontWide, Indent, LineWidth, LineHi, PageHi, PageWide : integer;
   ImageHi, ImageWide, linecnt : integer;
   Grect : TRect;
   Bitmap : TBitmap;
   R1 : MatchItemsRcd;
   R2 : BlankItemRcd;
   R3 : MCItemRcd;
   R4 : EssayItemRcd;
   R5 : TFItemRcd;
  public
    { Public declarations }
    Response : string;
    CorrectAnswer : string;
    Cont : boolean;
    itemtype, itemno, item : integer;
   procedure ShowMCItem(Sender : TObject; itemno,item : integer);
   procedure ShowTFItem(Sender : TObject; itemno,item : integer);
   procedure ShowMAItem(Sender : TObject; itemno,item : integer);
   procedure ShowCOItem(Sender : TObject; itemno,item : integer);
   procedure ShowESItem(Sender : TObject; itemno,item : integer);
  end;

var
  BlankFrm: TBlankFrm;

implementation

uses CompTestUnit;

{$R *.lfm}

procedure TBlankFrm.ContinueBtnClick(Sender: TObject);
var
   i : integer;

begin
     Response := '';
     case itemtype of
          1,2 : Response := AnswerEdit.Text; // MC, TF items
          3,4,5 : begin // MA, CO items
                  for i := 0 to AnswerMemo.Lines.Count-1 do
                      Response := Response + AnswerMemo.Lines[i];
              end;
     end;
     Cont := true;
     BlankFrm.Hide;
end;
//-------------------------------------------------------------------
procedure TBlankFrm.ShowMCItem(Sender : TObject; itemno,item : integer);
var
   i, j : integer;
   S : string;
   X, Y : integer;

begin
     ReadMCItem(item, R3);
     CorrectAnswer := '';
     for i := 1 to 5 do
     begin
          if R3.CorWeights[i] > 0.0 then
          begin
               CorrectAnswer := CorrectAnswer + R3.CorChoices[i] + '*' + FloatToStr(R3.CorWeights[i]);
               if i < 5 then CorrectAnswer := CorrectAnswer + ' ';
          end;
     end;
     linecnt := 1;
     Y := linecnt * LineHi;
     X := indent;
     S := format('Item %d (Multiple Choice)',[itemno]);
     Image1.Canvas.TextOut(X,Y,S);
     linecnt := linecnt + 1;
     if length(R3.Picture) > 0 then
     begin
          Grect.Top := linecnt * LineHi;
          Grect.Left := indent;
          Grect.Right := (3 * ClientWidth div 4) - indent;
          Grect.Bottom := Grect.Top + ClientHeight div 3;
          BitMap := TBitMap.Create;
          if FileExists(R3.Picture) { *Converted from FileExists*  } then
          begin
               Bitmap.LoadFromFile(R3.Picture);
               Image1.Canvas.stretchdraw(Grect,Bitmap);
          end
          else ShowMessage('Image ' + R3.Picture + ' missing.');
          Bitmap.Free;
          linecnt := linecnt + (ClientHeight div 3) div LineHi;
          linecnt := linecnt + 2;
     end;
     for j := 1 to 10 do
     begin
          if length(R3.ItemStem[j]) > 0 then
          begin
               S := trim(R3.ItemStem[j]);
               X := indent;
               Y := linecnt * LineHi;
               Image1.Canvas.TextOut(X,Y,S);
               linecnt := linecnt + 1;
          end;
     end;
     for j := 1 to 5 do
     begin
          if length(R3.Choices[j]) > 0 then
          begin
               S := chr(j-1 + ord('A')) + ': ';
               S := S + R3.Choices[j];
               X := indent + 50;
               Y := linecnt * LineHi;
               Image1.Canvas.TextOut(X,Y,S);
               linecnt := linecnt + 1;
          end;
     end;
end;
//-------------------------------------------------------------------

procedure TBlankFrm.ShowTFItem(Sender : TObject; itemno,item : integer);
var
   j : integer;
   S : string;
   X, Y : integer;

begin
     ReadTFItem(item,R5);
     CorrectAnswer := '';
     CorrectAnswer := CorrectAnswer + R5.CorChoice;
     linecnt := 1;
     Y := linecnt * LineHi;
     X := indent;
     S := format('Item %d (True-False)',[itemno]);
     Image1.Canvas.TextOut(X,Y,S);
     linecnt := linecnt + 1;
     if length(R5.Picture) > 0 then
     begin
          Grect.Top := linecnt * LineHi;
          Grect.Left := indent;
          Grect.Right := (3 * ClientWidth div 4) - indent;
          Grect.Bottom := Grect.Top + ClientHeight div 3;
          BitMap := TBitMap.Create;
          if FileExists(R5.Picture) { *Converted from FileExists*  } then
          begin
               Bitmap.LoadFromFile(R5.Picture);
               Image1.Canvas.stretchdraw(Grect,Bitmap);
          end
          else ShowMessage('Image ' + R5.Picture + ' missing.');
          Bitmap.Free;
          linecnt := linecnt + (ClientHeight div 3) div LineHi;
          linecnt := linecnt + 2;
     end;
     for j := 1 to 10 do
     begin
          if length(R5.ItemStem[j]) > 0 then
          begin
               S := trim(R5.ItemStem[j]);
               X := indent;
               Y := linecnt * LineHi;
               Image1.Canvas.TextOut(X,Y,S);
               linecnt := linecnt + 1;
          end;
     end;
     S := chr(ord('A')) + ': ';
     S := S + 'TRUE';
     X := indent + 50;
     Y := linecnt * LineHi;
     Image1.Canvas.TextOut(X,Y,S);
     linecnt := linecnt + 1;
     S := chr(1 + ord('A')) + ': ';
     S := S + 'FALSE';
     X := indent + 50;
     Y := linecnt * LineHi;
     Image1.Canvas.TextOut(X,Y,S);
     linecnt := linecnt + 1;
end;
//-------------------------------------------------------------------

procedure TBlankFrm.ShowMAItem(Sender : TObject; itemno,item : integer);
var
   i,j : integer;
   S : string;
   X, Y : integer;
   anscol, itemstartY : integer;

begin
     linecnt := 1;
     anscol := indent + Image1.Width div 2;
     ReadMAItem(item, R1);
     CorrectAnswer := '';
     for i := 1 to R1.NoItems do
     begin
          CorrectAnswer := CorrectAnswer + R1.CorChoices[i];
          if i < R1.NoItems then CorrectAnswer := CorrectAnswer + ', ';
     end;
     X := 1;
     Y := linecnt * LineHi;
     S := 'Directions: Enter a sequence of letter choices separated by commas';
     Image1.Canvas.TextOut(X,Y,S);
     linecnt := linecnt + 1;
     Y := linecnt * LineHi;
     S := '            in the answer area below the items.';
     Image1.Canvas.TextOut(X,Y,S);
     linecnt := linecnt + 2;
     Y := linecnt * LineHi;
     X := 1;
     S := format('Matching Item Set %d',[R1.SetNo]);
     Image1.Canvas.TextOut(X,Y,S);
     linecnt := linecnt + 1;
     if length(R1.Picture) > 0 then
     begin
          Grect.Top := linecnt * LineHi;
          Grect.Left := indent;
          Grect.Right := (3 * ClientWidth div 4) - indent;
          Grect.Bottom := Grect.Top + ClientHeight div 3;
          BitMap := TBitMap.Create;
          if FileExists(R1.Picture) { *Converted from FileExists*  } then
          begin
               Bitmap.LoadFromFile(R1.Picture);
               Image1.Canvas.stretchdraw(Grect,Bitmap);
          end
          else ShowMessage('Image ' + R1.Picture + ' missing.');
          Bitmap.Free;
          linecnt := linecnt + (ClientHeight div 3) div LineHi;
          linecnt := linecnt + 2;
     end;
     itemstartY := linecnt;
     for j := 1 to R1.NoItems do
     begin
          X := 1;
          Y := linecnt * LineHi;
          S := format('Item %d (Matching Item)',[itemno]);
          Image1.Canvas.TextOut(X,Y,S);
          linecnt := linecnt + 1;
          S := trim(R1.ItemStems[j]);
          X := 10;
          Y := linecnt * LineHi;
          Image1.Canvas.TextOut(X,Y,S);
          linecnt := linecnt + 1;
          itemno := itemno + 1;
     end;
     linecnt := itemstartY;
     for j := 1 to R1.NoChoices do
     begin
          S := chr(j-1 + ord('A')) + ': ';
          S := S + trim(R1.ItemChoices[j]);
          X := anscol;
          Y := linecnt * LineHi;
          Image1.Canvas.TextOut(X,Y,S);
          linecnt := linecnt + 2;
     end;
     CompTestFrm.itemno := itemno - 1;
end;
//-------------------------------------------------------------------

procedure TBlankFrm.ShowCOItem(Sender : TObject; itemno,item : integer);
var
   j : integer;
   S : string;
   X, Y : integer;

begin
     linecnt := 1;
     ReadCOItem(item,R2);
     CorrectAnswer := '';
     CorrectAnswer := CorrectAnswer + R2.BestAns;
     Y := linecnt * LineHi;
     X := indent;
     S := format('Item %d (Completion)',[itemno]);
     Image1.Canvas.TextOut(X,Y,S);
     linecnt := linecnt + 1;
     if length(R2.Picture) > 0 then
     begin
          Grect.Top := linecnt * LineHi;
          Grect.Left := indent;
          Grect.Right := (3 * ClientWidth div 4) - indent;
          Grect.Bottom := Grect.Top + ClientHeight div 3;
          BitMap := TBitMap.Create;
          if FileExists(R2.Picture) { *Converted from FileExists*  } then
          begin
               Bitmap.LoadFromFile(R2.Picture);
               Image1.Canvas.stretchdraw(Grect,Bitmap);
          end
          else ShowMessage('Image ' + R2.Picture + ' missing.');
          Bitmap.Free;
          linecnt := linecnt + (ClientHeight div 3) div LineHi;
          linecnt := linecnt + 2;
     end;
     for j := 1 to 10 do
     begin
          if length(R2.ItemStem[j]) > 0 then
          begin
               S := trim(R2.ItemStem[j]);
               X := indent;
               Y := linecnt * LineHi;
               Image1.Canvas.TextOut(X,Y,S);
               linecnt := linecnt + 1;
          end;
     end;
end;
//-------------------------------------------------------------------

procedure TBlankFrm.ShowESItem(Sender : TObject; itemno,item : integer);
var
   j : integer;
   S : string;
   X, Y : integer;

begin
     linecnt := 1;
     ReadESItem(item, R4);
     CorrectAnswer := 'None Given';
     Y := linecnt * LineHi;
     X := indent;
     S := format('Item %d (Essay Item)',[itemno]);
     Image1.Canvas.TextOut(X,Y,S);
     linecnt := linecnt + 1;
     if length(R4.Picture) > 0 then
     begin
          Grect.Top := linecnt * LineHi;
          Grect.Left := indent;
          Grect.Right := (3 * ClientWidth div 4) - indent;
          Grect.Bottom := Grect.Top + ClientHeight div 3;
          BitMap := TBitMap.Create;
          if FileExists(R4.Picture) { *Converted from FileExists*  } then
          begin
               Bitmap.LoadFromFile(R4.Picture);
               Image1.Canvas.stretchdraw(Grect,Bitmap);
          end
          else ShowMessage('Image ' + R4.Picture + ' missing.');
          Bitmap.Free;
          linecnt := linecnt + (ClientHeight div 3) div LineHi;
          linecnt := linecnt + 2;
     end;
     for j := 1 to 20 do
     begin
          if length(R4.ItemStem[j]) > 0 then
          begin
               S := trim(R4.ItemStem[j]);
               X := indent;
               Y := linecnt * LineHi;
               Image1.Canvas.TextOut(X,Y,S);
               linecnt := linecnt + 1;
          end;
     end;
end;
//-------------------------------------------------------------------

procedure TBlankFrm.FormShow(Sender: TObject);
begin
     // setup parameters
     FontHi := Image1.Canvas.TextHeight('M');
     FontWide := Image1.Canvas.TextWidth('M');
     Indent := 10 * FontWide;
     LineWidth := 60 * FontWide;
     LineHi := FontHi + 5;
     PageHi := Image1.ClientHeight;
     ImageHi := PageHi;
     PageWide := Image1.ClientWidth;
     ImageWide := PageWide;
     Image1.Canvas.Brush.Color := clWhite;
     Image1.Canvas.Rectangle(0,0,ImageWide,ImageHi);
     case itemtype of
          1: ShowMCItem(Self,itemno,item);
          2: ShowTFItem(Self,itemno,item);
          3: ShowMAItem(Self,itemno,item);
          4: ShowCOItem(Self,itemno,item);
          5: ShowESItem(Self,itemno,item);
     end;
end;

end.
