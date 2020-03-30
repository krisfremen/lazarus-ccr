unit JpegUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ExtDlgs;

type

  { TJPEGform }

  TJPEGform = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    PropBtn: TButton;
    StretchBtn: TButton;
    NormalBtn: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    ReturnBtn: TButton;
    LoadBtn: TButton;
    Image1: TImage;
    procedure LoadBtnClick(Sender: TObject);
    procedure NormalBtnClick(Sender: TObject);
    procedure PropBtnClick(Sender: TObject);
    procedure StretchBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  JPEGform: TJPEGform;

implementation

{ TJPEGform }

procedure TJPEGform.LoadBtnClick(Sender: TObject);
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
       Caption := OpenPictureDialog1.FileName;
     except
       on E: Exception do begin
         MessageDlg('Error','Error: '+E.Message,mtError,[mbOk],0);
       end;
     end;
end;

procedure TJPEGform.NormalBtnClick(Sender: TObject);
begin
  Image1.Proportional := false;
  Image1.Stretch := false;
end;

procedure TJPEGform.PropBtnClick(Sender: TObject);
begin
  Image1.Proportional := true;
end;

procedure TJPEGform.StretchBtnClick(Sender: TObject);
begin
  Image1.Proportional := false;
  Image1.Stretch := true;
end;

initialization
  {$I jpegunit.lrs}

end.

