unit OutputUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, Printers, clipbrd, PrintersDlgs;

type

  { TOutputFrm }

  TOutputFrm = class(TForm)
    PrintDialog: TPrintDialog;
    RichEdit: TMemo;
    ReturnBtn: TButton;
    PrintBtn: TButton;
    PasteBtn: TButton;
    CopyBtn: TButton;
    CutBtn: TButton;
    FontBtn: TButton;
    FontDialog: TFontDialog;
    OpenFileBtn: TButton;
    SaveFileBtn: TButton;
    OpenDialog: TOpenDialog;
    Panel1: TPanel;
    SaveDialog: TSaveDialog;
    procedure CopyBtnClick(Sender: TObject);
    procedure CutBtnClick(Sender: TObject);
    procedure FontBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OpenFileBtnClick(Sender: TObject);
    procedure PasteBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure SaveFileBtnClick(Sender: TObject);
  private
    { private declarations }
    FPrintY: Integer;
    procedure PrintText;
  public
    { public declarations }
    procedure AddLine(const ALine: String); overload;
    procedure AddLine(const Fmt: String; const Args: array of const); overload;
    procedure AddLines(AList: TStrings);
    procedure Clear;
  end;

var
  OutputFrm: TOutputFrm;

procedure DisplayReport(AReport: TStrings);


implementation

const
  LEFT_MARGIN = 200;
  RIGHT_MARGIN = 200;
  TOP_MARGIN = 150;
  BOTTOM_MARGIN = 200;

procedure DisplayReport(AReport: TStrings);
begin
  if AReport.Count > 0 then
  begin
    if OutputFrm = nil then
      OutputFrm := TOutputFrm.Create(Application)
    else
      OutputFrm.Clear;
    OutputFrm.AddLines(AReport);
    OutputFrm.ShowModal;
  end;
end;


{ TOutputFrm }

procedure TOutputFrm.AddLine(const ALine: String);
begin
  RichEdit.Lines.Add(ALine);
end;

procedure TOutputFrm.AddLine(const Fmt: String; const Args: array of const);
begin
  RichEdit.Lines.Add(Format(Fmt, Args));
end;

procedure TOutputFrm.AddLines(AList: TStrings);
begin
  RichEdit.Lines.AddStrings(AList);
end;

procedure TOutputFrm.Clear;
begin
  RichEdit.Clear;
end;

procedure TOutputFrm.PrintText;
var
  i: Integer;
  x: Integer;
  xmax, ymax: Integer;
  pageNo: Integer;
  oldFontSize: Integer;
  h: Integer;
begin
  with Printer do
  begin
    x := LEFT_MARGIN;
    FPrintY := TOP_MARGIN;
    xMax := PaperSize.Width - RIGHT_MARGIN;
    yMax := PaperSize.Height - BOTTOM_MARGIN;
    pageNo := 1;
    try
      Canvas.Brush.Style := bsClear;  // no text background color
      Canvas.Font.Assign(RichEdit.Font);
      if Canvas.Font.Size = 0 then
        Canvas.Font.Size := 10;
      oldFontSize := Canvas.Font.Size;
      for i:=0 to RichEdit.Lines.Count-1 do begin
        // Print page number
        if FPrintY = TOP_MARGIN then begin
          Canvas.Font.Size := 10;
          h := Canvas.TextHeight('Page 9') + 4;
          Canvas.TextOut(x+1, FPrintY, 'Page ' + IntToStr(PageNo));
          Canvas.Pen.Width := 3;
          Canvas.Line(LEFT_MARGIN, FPrintY+h, xmax, FPrintY+h);
          inc(FPrintY, 2*h);
          Canvas.Font.Size := oldFontSize;
        end;
        Canvas.TextOut(x, FPrintY, RichEdit.Lines[i]);
        inc(FPrintY, Canvas.TextHeight('Tg'));
        if FPrintY > yMax then begin
          NewPage;
          FPrintY := TOP_MARGIN;
          inc(PageNo);
        end;
      end;
    except
      on E: EPrinter do ShowMessage('Printer Error: ' +  E.Message);
      on E: Exception do showMessage('Unexpected error when printing.');
    end;
  end;
end;

procedure TOutputFrm.PrintBtnClick(Sender: TObject);
begin
  if PrintDialog.Execute then
  begin
    Printer.BeginDoc;
    try
      PrintText;
    finally
      Printer.EndDoc;
    end;
  end;
end;

(*
procedure TOutputFrm.PrintBtnClick(Sender: TObject);
var
  aline: string;
  NoLines, i, X, Y, txthi : integer;
begin
  Printer.Orientation := poPortrait;
  NoLines := OutputFrm.RichEdit.Lines.Count;
  X := 5; // left margin
  Y := 5; // top margin
  PrintDialog.MinPage := 1;
  PrintDialog.MaxPage := 1;
  PrintDialog.ToPage := 1;
  PrintDialog.Options := [poPageNums];
  Printer.Copies := PrintDialog.Copies;
  if FontDialog.Execute then
  begin
     Printer.Canvas.Font := FontDialog.Font;
     Printer.Canvas.Font.Height := FontDialog.Font.Height;
  end;
  if PrintDialog.Execute then
   begin
//          Printer.Canvas.Font.Height := 50;
     Printer.Canvas.Font.Height := Printer.PageHeight div 80;
     txthi := Printer.Canvas.Font.Height;
     Printer.BeginDoc;
     for i := 0 to NoLines-1 do
     begin
       aline := OutputFrm.RichEdit.Lines[i];
       Printer.Canvas.TextOut(X,Y,aline);
//               txthi := Printer.Canvas.Font.Height;
       Y := Y + abs(txthi);
       if Y >= Printer.PageHeight - 10 then
       begin
         Printer.NewPage;
         Y := 5;
       end;
     end;
     Printer.EndDoc;
  end;
end;
*)

procedure TOutputFrm.OpenFileBtnClick(Sender: TObject);
begin
  OpenDialog.Filter := 'LazStats text files (*.txt)|*.txt;*.TXT|All files (*.*)|*.*';
  OpenDialog.FilterIndex := 1; {text file}
  if OpenDialog.Execute then
    RichEdit.Lines.LoadFromFile(OpenDialog.FileName);
end;

procedure TOutputFrm.CopyBtnClick(Sender: TObject);
begin
  with RichEdit do
  begin
    SelectAll;
    CopyToClipboard;
    SelLength := 0;
  end;
end;

procedure TOutputFrm.CutBtnClick(Sender: TObject);
begin
  RIchEdit.CutToClipboard;
end;

procedure TOutputFrm.PasteBtnClick(Sender: TObject);
begin
  RichEdit.PasteFromClipboard;
end;

procedure TOutputFrm.FontBtnClick(Sender: TObject);
begin
  FontDialog.Execute;
  RichEdit.Font := FontDialog.Font;
end;

procedure TOutputFrm.FormShow(Sender: TObject);
var
  w: Integer;
  i: Integer;
begin
  w := 0;
  for i := 0 to Panel1.ControlCount-1 do
    if Panel1.Controls[i] is TButton then
      if w > TButton(Panel1.Controls[i]).Width then
        w := TButton(Panel1.Controls[i]).Width;
  for i := 0 to Panel1.ControlCount-1 do
    if Panel1.Controls[i] is TButton then
      Panel1.Controls[i].Constraints.MinWidth := w;
end;

procedure TOutputFrm.SaveFileBtnClick(Sender: TObject);
begin
  SaveDialog.Filter := 'LazStats text files (*.txt)|*.txt;*.TXT|All files (*.*)|*.*';
  SaveDialog.FilterIndex := 1; {text file}
  SaveDialog.Title := 'Print to File: ';
  if SaveDialog.Execute then RichEdit.Lines.SaveToFile(SaveDialog.FileName);
end;

initialization
  {$I outputunit.lrs}

end.

