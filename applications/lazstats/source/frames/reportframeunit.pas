unit ReportFrameUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, ExtCtrls, StdCtrls, Dialogs,
  PrintersDlgs, MainDM;

type

  { TReportFrame }

  TReportFrame = class(TFrame)
    PrintDialog: TPrintDialog;
    ReportPanel: TPanel;
    ReportMemo: TMemo;
    ReportToolBar: TToolBar;
    SaveDialog: TSaveDialog;
    tbCopyReport: TToolButton;
    tbPrintReport: TToolButton;
    tbSaveReport: TToolButton;
    procedure tbCopyReportClick(Sender: TObject);
    procedure tbPrintReportClick(Sender: TObject);
    procedure tbSaveReportClick(Sender: TObject);
  private
    FPrintY: Integer;
    FMaxLen: Integer;
    function LongestLine(AReport: TStrings): Integer;

  protected
    procedure PrintText; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear; virtual;
    procedure DisplayReport(AReport: TStrings; Add: Boolean = false); virtual;
    procedure UpdateBtnStates; virtual;

  end;

implementation

{$R *.lfm}

uses
  Graphics, StrUtils,
  Printers, OSPrinters,
  Globals;

const
  LEFT_MARGIN = 200;
  RIGHT_MARGIN = 200;
  TOP_MARGIN = 150;
  BOTTOM_MARGIN = 200;


constructor TReportFrame.Create(AOwner: TComponent);
begin
  inherited;
  ReportPanel.Color := ReportMemo.Color;
  UpdateBtnStates;
end;


procedure TReportFrame.Clear;
begin
  ReportMemo.Lines.Clear;
  UpdateBtnStates;
end;


procedure TReportFrame.DisplayReport(AReport: TStrings; Add: Boolean = false);
var
  maxLen: Integer;
  s: String;
begin
  if not Add then
    ReportMemo.Clear;

  maxLen := Longestline(AReport);
  for s in AReport do
    if s = DIVIDER_AUTO then
      ReportMemo.Lines.Add(AddChar('-', '', maxLen))
    else
      ReportMemo.Lines.Add(s);

  UpdateBtnStates;
end;


function TReportFrame.LongestLine(AReport: TStrings): Integer;
var
  len: Integer;
  s: String;
begin
  len := 0;
  for s in AReport do
    if Length(s) > len then len := Length(s);
  Result := len;
end;


procedure TReportFrame.PrintText;
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
      Canvas.Font.Assign(ReportMemo.Font);
      if Canvas.Font.Size < 10 then
        Canvas.Font.Size := 10;
      oldFontSize := Canvas.Font.Size;
      for i:=0 to ReportMemo.Lines.Count-1 do begin
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
        Canvas.TextOut(x, FPrintY, ReportMemo.Lines[i]);
        inc(FPrintY, Canvas.TextHeight('Tg'));
        if FPrintY > yMax then begin
          NewPage;
          FPrintY := TOP_MARGIN;
          inc(PageNo);
        end;
      end;
    except
      on E: EPrinter do ShowMessage('Printer Error: ' +  E.Message);
      on E: Exception do ShowMessage('Unexpected error when printing.');
    end;
  end;
end;


procedure TReportFrame.UpdateBtnStates;
begin
  tbCopyReport.Enabled := ReportMemo.Lines.Count > 0;
  tbPrintReport.Enabled := ReportMemo.Lines.Count > 0;
  tbSaveReport.Enabled := ReportMemo.Lines.Count > 0;
end;


procedure TReportFrame.tbPrintReportClick(Sender: TObject);
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


procedure TReportFrame.tbCopyReportClick(Sender: TObject);
begin
  with ReportMemo do
  begin
    SelectAll;
    CopyToClipboard;
    SelLength := 0;
  end;
end;


procedure TReportFrame.tbSaveReportClick(Sender: TObject);
begin
  SaveDialog.Filter := 'LazStats text files (*.txt)|*.txt;*.TXT|All files (*.*)|*.*';
  SaveDialog.FilterIndex := 1; {text file}
  SaveDialog.Title := 'Save to File';
  if SaveDialog.Execute then
    ReportMemo.Lines.SaveToFile(SaveDialog.FileName);
end;


end.

