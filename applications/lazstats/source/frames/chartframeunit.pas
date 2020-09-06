unit ChartFrameUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtDlgs, PrintersDlgs,
  TAGraph, TATypes, TACustomSource, TACustomSeries, TASeries, TATools,
  Globals;

type
  TPlotType = (ptLines, ptSymbols, ptLinesAndSymbols, ptHorBars, ptVertBars,
    ptArea);

  { TChartFrame }

  TChartFrame = class(TFrame)
    Chart: TChart;
    ChartToolset: TChartToolset;
    PanDragTool: TPanDragTool;
    PrintDialog: TPrintDialog;
    SavePictureDialog: TSavePictureDialog;
    ZoomDragTool: TZoomDragTool;

  protected
    procedure Constline(xy: Double; ADirection: TLineStyle; AColor: TColor;
      ALineStyle: TPenStyle; ALegendTitle: String);

  public
    procedure Clear;
    procedure GetXRange(out XMin, XMax: Double; Logical: Boolean = true);
    procedure GetYRange(out YMin, YMax: Double; Logical: Boolean = true);
    procedure HorLine(y: Double; AColor: TColor; ALineStyle: TPenStyle;
      ALegendTitle: String);
    function PlotXY(AType: TPlotType; x, y: DblDyneVec; xLabels: StrDyneVec;
      yErrorBars: DblDyneVec; LegendTitle: string; AColor: TColor;
      ASymbol: TSeriesPointerStyle = psCircle): TChartSeries;
    procedure Print;
    procedure Save;
    procedure SetFooter(const ATitle: String);
    procedure SetTitle(const ATitle: String; Alignment: TAlignment = taCenter);
    procedure SetXTitle(const ATitle: String);
    procedure SetYTitle(const ATitle: String);
    procedure VertLine(x: Double; AColor: TColor; ALineStyle: TPenStyle;
      ALegendTitle: String);
  end;

implementation

{$R *.lfm}

uses
  Math, Printers, OSPrinters,
  TAChartUtils, TADrawerSVG, TAPrint;

procedure TChartFrame.Clear;
begin
  Chart.ClearSeries;
  Chart.Title.Text.Clear;
  Chart.Foot.Text.Clear;
  Chart.BottomAxis.Title.Caption := '';
  Chart.LeftAxis.Title.Caption := '';
  Chart.Legend.Visible := false;
end;


procedure TChartFrame.Constline(xy: Double; ADirection: TLineStyle;
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


procedure TChartFrame.GetXRange(out XMin, XMax: Double; Logical: Boolean = true);
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


procedure TChartFrame.GetYRange(out YMin, YMax: Double; Logical: Boolean = true);
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


procedure TChartFrame.HorLine(y: Double; AColor: TColor; ALineStyle: TPenStyle;
  ALegendTitle: String);
begin
  ConstLine(y, lsHorizontal, AColor, ALineStyle, ALegendTitle);
end;


procedure TChartFrame.VertLine(x: Double; AColor: TColor; ALineStyle: TPenStyle;
  ALegendTitle: String);
begin
  ConstLine(x, lsVertical, AColor, ALineStyle, ALegendTitle);
end;


function TChartFrame.PlotXY(AType: TPlotType; x, y: DblDyneVec; xLabels: StrDyneVec;
  yErrorBars: DblDyneVec; LegendTitle: string; AColor: TColor;
  ASymbol: TSeriesPointerStyle = psCircle): TChartSeries;
var
  i, n, ns, ne: Integer;
  s: String;
  xval: Double;
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
        if yErrorBars <> nil then
        begin
          TLineSeries(Result).YErrorBars.Visible := true;
          TLineSeries(Result).ListSource.YCount := 2;
          TLineSeries(Result).ListSource.YErrorBarData.Kind := ebkChartSource;
          TLineSeries(Result).ListSource.YErrorBarData.IndexPlus := 1;
          TLineSeries(Result).ListSource.YErrorBarData.IndexMinus := -1;
        end;
      end;
    ptHorBars, ptVertBars:
      Result := TBarSeries.Create(self);
    ptArea:
      Result := TAreaSeries.Create(self);
    else
      raise Exception.Create('Unknown plot type.');
  end;

  ns := Length(xLabels);
  ne := Length(yErrorBars);
  if x = nil then
    n := Length(y)
  else
    n := Min(Length(x), Length(y));
  for i := 0 to n-1 do begin
    if x = nil then xval := i+1 else xval := x[i];
    if i < ns then s := xLabels[i] else s := '';
    if i < ne then
      Result.AddXY(xval, y[i], [yErrorBars[i]], s)
    else
      Result.AddXY(xval, y[i], s);
  end;

  Result.Title := LegendTitle;
  Chart.AddSeries(Result);
  Chart.Legend.Visible := Chart.SeriesCount > 0;
end;


procedure TChartFrame.Print;
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


procedure TChartFrame.Save;
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


procedure TChartFrame.SetFooter(const ATitle: String);
begin
  Chart.Foot.Text.Text := ATitle;
  Chart.Foot.Visible := ATitle <> '';
end;


procedure TChartFrame.SetTitle(const ATitle: String; Alignment: TAlignment = taCenter);
begin
  Chart.Title.Text.Text := ATitle;
  Chart.Title.Visible := ATitle <> '';
  Chart.Title.Alignment := Alignment;
end;


procedure TChartFrame.SetXTitle(const ATitle: String);
begin
  Chart.BottomAxis.Title.Caption := ATitle;
  Chart.BottomAxis.Title.Visible := ATitle <> '';
end;


procedure TChartFrame.SetYTitle(const ATitle: String);
begin
  Chart.LeftAxis.Title.Caption := ATitle;
  Chart.LeftAxis.Title.Visible := ATitle <> '';
end;


end.

