unit ChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ExtDlgs, PrintersDlgs,
  TAGraph, TACustomSeries, TASeries, TATypes,
  Globals;

type

  TPlotType = (ptLines, ptSymbols, ptLinesAndSymbols, ptHorBars, ptVertBars,
    ptArea);

  { TChartForm }

  TChartForm = class(TForm)
    ButtonBevel: TBevel;
    Chart: TChart;
    CloseBtn: TButton;
    ButtonPanel: TPanel;
    Panel1: TPanel;
    PrintBtn: TButton;
    PrintDialog: TPrintDialog;
    SaveBtn: TButton;
    SavePictureDialog: TSavePictureDialog;
    procedure CloseBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
  private
    procedure Constline(xy: Double; ADirection: TLineStyle;
      AColor: TColor; ALineStyle: TPenStyle; ALegendTitle: String);

  public
    procedure Clear;

    procedure GetXRange(out XMin, XMax: Double; Logical: Boolean = true);
    procedure GetYRange(out YMin, YMax: Double; Logical: Boolean = true);

    procedure HorLine(y: Double; AColor: TColor; ALineStyle: TPenStyle; ALegendTitle: String);
    function PlotXY(AType: TPlotType; x, y: DblDyneVec; LegendTitle: string;
      AColor: TColor; ASymbol: TSeriesPointerStyle = psCircle): TChartSeries;
    procedure Vertline(x: Double; AColor: TColor; ALineStyle: TPenStyle; ALegendTitle: String);

    procedure SetFooter(const ATitle: String);
    procedure SetTitle(const ATitle: String);
    procedure SetXTitle(const ATitle: String);
    procedure SetYTitle(const ATitle: String);

  end;

var
  ChartForm: TChartForm;

implementation

{$R *.lfm}

uses
  Math, Printers, OSPrinters,
  TAChartUtils, TADrawerSVG, TAPrint;

{ TChartForm }

procedure TChartForm.Clear;
begin
  Caption := 'Plot Window';
  Chart.ClearSeries;
  Chart.Title.Text.Clear;
  Chart.Foot.Text.Clear;
  Chart.BottomAxis.Title.Caption := '';
  Chart.LeftAxis.Title.Caption := '';
end;

procedure TChartForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([SaveBtn.Width, PrintBtn.Width, CloseBtn.Width]);
  SaveBtn.Constraints.MinWidth := w;
  PrintBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TChartForm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TChartForm.FormCreate(Sender: TObject);
begin
  Clear;
end;

procedure TChartForm.PrintBtnClick(Sender: TObject);
const
  MARGIN = 10;
var
  R: TRect;
  d: Integer;
begin
  if not PrintDialog.Execute then
    exit;

  Printer.BeginDoc;
  try
    R := Rect(0, 0, Printer.PageWidth, Printer.PageHeight div 2);

    d := R.Right - R.Left;
    R.Left += d div MARGIN;
    R.Right -= d div MARGIN;

    d := R.Bottom - R.Top;
    R.Top += d div MARGIN;
    R.Bottom -= d div MARGIN;

    Chart.Draw(TPrinterDrawer.Create(Printer, true), R);
  finally
    Printer.EndDoc;
  end;
end;

procedure TChartForm.GetXRange(out XMin, XMax: Double; Logical: Boolean = true);
var
  ext: TDoubleRect;
begin
  if Logical then
    ext := Chart.LogicalExtent
  else
    ext := Chart.CurrentExtent;
  XMin := ext.a.x;
  XMax := ext.b.x;
end;

procedure TChartForm.GetYRange(out YMin, YMax: Double; Logical: Boolean = true);
var
  ext: TDoubleRect;
begin
  if Logical then
    ext := Chart.LogicalExtent
  else
    ext := Chart.CurrentExtent;
  YMin := ext.a.y;
  YMax := ext.b.y;
end;

procedure TChartForm.HorLine(y: Double; AColor: TColor; ALineStyle: TPenStyle;
  ALegendTitle: String);
begin
  ConstLine(y, lsHorizontal, AColor, ALineStyle, ALegendTitle);
end;

procedure TChartForm.VertLine(x: Double; AColor: TColor; ALineStyle: TPenStyle;
  ALegendTitle: String);
begin
  ConstLine(x, lsVertical, AColor, ALineStyle, ALegendTitle);
end;

procedure TChartForm.Constline(xy: Double; ADirection: TLineStyle;
  AColor: TColor; ALineStyle: TPenStyle; ALegendTitle: String);
var
  ser: TConstantLine;
begin
  ser := TConstantLine.Create(self);
  ser.Position := xy;
  ser.LineStyle := ADirection;
  ser.Pen.Color := AColor;
  ser.Pen.Style := ALineStyle;
  ser.Title := ALegendTitle;
  ser.Legend.Visible := ALegendTitle <> '';
  Chart.AddSeries(ser);
end;

function TChartForm.PlotXY(AType: TPlotType; x, y: DblDyneVec;
  LegendTitle: string; AColor: TColor; ASymbol: TSeriesPointerStyle = psCircle): TChartSeries;
var
  i, n: Integer;
begin
  case AType of
    ptLines, ptSymbols, ptLinesAndSymbols:
      begin
        Result := TLineSeries.Create(self);
        TLineSeries(Result).ShowPoints := AType in [ptSymbols, ptLinesAndSymbols];
        TLineSeries(Result).ShowLines := AType in [ptLines, ptLinesAndSymbols];
        TLineSeries(Result).SeriesColor := AColor;
        if AType in [ptSymbols, ptLinesAndSymbols] then
        begin
          TLineSeries(Result).Pointer.Brush.Color := AColor;
          TLineSeries(Result).Pointer.Style := ASymbol;
        end;
      end;
    ptHorBars, ptVertBars:
      Result := TBarSeries.Create(self);
    ptArea:
      Result := TAreaSeries.Create(self);
    else
      raise Exception.Create('Unknown plot type.');
  end;

  n := Min(Length(x), Length(y));
  for i := 0 to n-1 do
    Result.AddXY(x[i], y[i]);

  Result.Title := LegendTitle;
  Chart.AddSeries(Result);
  Chart.Legend.Visible := Chart.SeriesCount > 0;
end;

procedure TChartForm.SaveBtnClick(Sender: TObject);
var
  ext: String;
begin
  if SavePictureDialog.Execute then
  begin
    ext := Lowercase(ExtractFileExt(SavePictureDialog.FileName));
    case ext of
      '.bmp': Chart.SaveToFile(TBitmap, SavePictureDialog.Filename);
      '.png': Chart.SaveToFile(TPortableNetworkGraphic, SavePictureDialog.FileName);
      '.jpg', '.jpeg', '.jpe', '.jfif': Chart.SaveToFile(TJpegImage, SavePictureDialog.FileName);
      '.svg': Chart.SaveToSVGFile(SavePictureDialog.FileName);
    end;
  end;
end;

procedure TChartForm.SetFooter(const ATitle: String);
begin
  Chart.Foot.Text.Text := ATitle;
  Chart.Foot.Visible := ATitle <> '';
end;

procedure TChartForm.SetTitle(const ATitle: String);
begin
  Chart.Title.Text.Text := ATitle;
  Chart.Title.Visible := ATitle <> '';
end;

procedure TChartForm.SetXTitle(const ATitle: String);
begin
  Chart.BottomAxis.Title.Caption := ATitle;
  Chart.BottomAxis.Title.Visible := ATitle <> '';
end;

procedure TChartForm.SetYTitle(const ATitle: String);
begin
  Chart.LeftAxis.Title.Caption := ATitle;
  Chart.LeftAxis.Title.Visible := ATitle <> '';
end;

end.

