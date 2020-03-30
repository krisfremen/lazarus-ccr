unit BlankFrmUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, PrintersDlgs, LResources, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, StdCtrls, ExtDlgs, Clipbrd, Printers;

type

  { TBlankFrm }

  TBlankFrm = class(TForm)
    Bevel1: TBevel;
    PrintDialog1: TPrintDialog;
    SaveBtn: TButton;
    PrintBtn: TButton;
    CloseBtn: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    Image1: TImage;
    Panel1: TPanel;
    SavePictureDialog1: TSavePictureDialog;
    procedure CloseBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  BlankFrm: TBlankFrm;

implementation

uses
  Math;

{ TBlankFrm }

procedure TBlankFrm.CloseBtnClick(Sender: TObject);
begin
//        Bitmap.FreeImage;
  Close;
end;

procedure TBlankFrm.FormActivate(Sender: TObject);
var
   w: Integer;
begin
  w := MaxValue([SaveBtn.Width, PrintBtn.Width, CloseBtn.Width]);
  SaveBtn.Constraints.MinWidth := w;
  PrintBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TBlankFrm.FormShow(Sender: TObject);
begin
//        Image1.Canvas.Clear;
//        Bitmap := GetFormImage;
//        Clipboard.Assign(Bitmap);
//        Image1.Picture.Assign(Clipboard);
end;

procedure TBlankFrm.PrintBtnClick(Sender: TObject);
var
  r: Trect;
begin
  if not PrintDialog1.Execute then
    exit;

  with Printer do
  begin
    Printer.Orientation := poPortrait;
    r := Rect(20,20,printer.pagewidth-20,printer.pageheight div 2 + 20);
    BeginDoc;
    try
      Canvas.StretchDraw(r,Image1.Picture.BitMap);
    finally
      EndDoc;
    end;
  end;
end;

procedure TBlankFrm.SaveBtnClick(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
  begin
    Image1.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

initialization
  {$I blankfrmunit.lrs}

end.

