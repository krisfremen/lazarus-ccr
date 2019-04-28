unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, JvPicClip;

type

  { TForm1 }

  TForm1 = class(TForm)
    CombinedImage: TImage;
    Label1: TLabel;
    SplitImage: TImage;
    JvPicClip1: TJvPicClip;
    Trackbar: TTrackBar;
    procedure CombinedImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure TrackbarChange(Sender: TObject);
  private
    procedure CreateCombinedImage(ABitmap: TBitmap;
      out ANumCols, ANumRows: Integer);

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  bmp: TBitmap;
  nCols, nRows: Integer;
begin
  bmp := TBitmap.Create;
  try
    CreateCombinedImage(bmp, nCols, nRows);

    // Image for combined bitmap
    CombinedImage.Width := bmp.Width;
    CombinedImage.Height := bmp.Height;
    CombinedImage.Picture.Assign(bmp);

    // Image for separated bitmaps
    SplitImage.Width := bmp.Width div nCols;
    SplitImage.Height := bmp.Height div nRows;

    JvPicClip1.Picture := CombinedImage.Picture;
    JvPicClip1.Cols := nCols;
    JvPicClip1.Rows := nRows;

    Trackbar.Min := 0;
    Trackbar.Max := nCols * nRows - 1;
    Trackbar.Position := 0;

    TrackbarChange(nil);
  finally
    bmp.Free;
  end;
end;

procedure TForm1.CombinedImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  r, c: Integer;
begin
  c := X div SplitImage.Width;
  r := Y div SplitImage.Height;
  Trackbar.Position := JvPicClip1.GetIndex(c, r);
end;

procedure TForm1.TrackbarChange(Sender: TObject);
begin
  SplitImage.Picture.Assign(JvPicClip1.GraphicCell[Trackbar.Position]);
  Label1.Caption := 'Index ' + IntToStr(Trackbar.Position);
end;

procedure TForm1.CreateCombinedImage(ABitmap: TBitmap;
  out ANumCols, ANumRows: Integer);
var
  pic: TPicture;
  c, r, i: Integer;
  L: TStrings;
  W, H: Integer;
begin
  L := TStringList.Create;
  try
    L.Add('../design/JvMM/images/tjvbmpanimator.bmp');                  //0
    L.Add('../design/JvMM/images/tjvfullcoloraxiscombo.bmp');
    L.Add('../design/JvMM/images/tjvfullcolorcircle.bmp');
    L.Add('../design/JvMM/images/tjvfullcolorcircledialog.bmp');
    L.Add('../design/JvMM/images/tjvfullcolorgroup.bmp');
    L.Add('../design/JvMM/images/tjvfullcolorlabel.bmp');
    L.Add('../design/JvMM/images/tjvfullcolorpanel.bmp');
    L.Add('../design/JvMM/images/tjvfullcolorspacecombo.bmp');
    L.Add('../design/JvMM/images/tjvfullcolortrackbar.bmp');
    L.Add('../design/JvMM/images/tjvgradient.bmp');
    L.Add('../design/JvMM/images/tjvgradientheaderpanel.bmp');   // 10
    L.Add('../design/JvMM/images/tjvid3v2.bmp');
    L.Add('../design/JvMM/images/tjvpicclip.bmp');
    L.Add('../design/JvMM/images/tjvspecialprogress.bmp');
    L.Add('../design/JvHMI/images/tjvdialbutton.bmp');
    L.Add('../design/JvHMI/images/tjvled.bmp');
    L.Add('../design/JvDB/images/tjvdbcalcedit.bmp');
    L.Add('../design/JvDB/images/tjvdbhtlabel.bmp');
    L.Add('../design/JvDB/images/tjvdbsearchcombobox.bmp');
    L.Add('../design/JvDB/images/tjvdbsearchedit.bmp');
    L.Add('../design/JvDB/images/tjvdbtreeview.bmp');  // 20
    L.Add('../design/JvCustomControls/images/tjvimagelistviewer.png');
    L.Add('../design/JvCustomControls/images/tjvimagesviewer.png');
    L.Add('../design/JvCustomControls/images/tjvmoderntabbarpainter.bmp');
    L.Add('../design/JvCustomControls/images/tjvoutlookbar.png');
    L.Add('../design/JvCustomControls/images/tjvownerdrawviewer.png');
    L.Add('../design/JvCustomControls/images/tjvtabbar.bmp');
    L.Add('../design/JvCustomControls/images/tjvthumbimage.png');
    L.Add('../design/JvCustomControls/images/tjvthumbnail.png');
    L.Add('../design/JvCustomControls/images/tjvthumbview.png');
    L.Add('../design/JvCustomControls/images/tjvtimeline.png');   // 30
    L.Add('../design/JvCustomControls/images/tjvtmtimeline.png');
    L.Add('../design/JvCustomControls/images/tjvvalidateedit.png');    // 32
    ANumCols := 8;
    ANumRows := 4;

    pic := TPicture.Create;
    try
      pic.LoadFromFile(L[0]);
      W := pic.Width;
      H := pic.Height;
    finally
      pic.Free;
    end;

    ABitmap.SetSize(ANumCols * W, ANumRows * H);
    ABitmap.Canvas.Brush.Color := clWhite;
    Abitmap.Canvas.FillRect(0, 0, ABitmap.Width, ABitmap.Height);
    c := 0;
    r := 0;
    pic := TPicture.Create;
    try
      for i:=0 to L.Count-1 do begin
        pic.LoadFromFile(L[i]);
        ABitmap.Canvas.Draw(c * W, r * H, pic.Bitmap);
        inc(c);
        if c = ANumCols then begin
          c := 0;
          inc(r);
        end;
      end;
    finally
      pic.Free;
    end;
  finally
    L.Free;
  end;
end;

end.

