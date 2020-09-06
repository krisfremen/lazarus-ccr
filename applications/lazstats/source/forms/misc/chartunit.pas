unit ChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  TAGraph, TATypes, TACustomSeries, TASeries,
  Globals, ChartFrameUnit;

type

  { TChartForm }

  TChartForm = class(TForm)
    ButtonBevel: TBevel;
    CloseBtn: TButton;
    ButtonPanel: TPanel;
    ChartPanel: TPanel;
    PrintBtn: TButton;
    SaveBtn: TButton;
    procedure CloseBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);

  private
    function GetChart: TChart;

  public
    ChartFrame: TChartFrame;
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

    property Chart: TChart read GetChart;

  end;

var
  ChartForm: TChartForm;

implementation

{$R *.lfm}

uses
  Math;


{ TChartForm }

procedure TChartForm.Clear;
begin
  Caption := 'Plot Window';
  ChartFrame.Clear;
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
  ChartFrame := TChartFrame.Create(self);
  ChartFrame.parent := ChartPanel;
  ChartFrame.Align := alClient;
end;


procedure TChartForm.PrintBtnClick(Sender: TObject);
begin
  ChartFrame.Print;
end;


function TChartForm.GetChart: TChart;
begin
  Result := ChartFrame.Chart;
end;


procedure TChartForm.GetXRange(out XMin, XMax: Double; Logical: Boolean = true);
begin
  ChartFrame.GetXRange(XMin, XMax, Logical);
end;


procedure TChartForm.GetYRange(out YMin, YMax: Double; Logical: Boolean = true);
begin
  ChartFrame.GetYRange(YMin, YMax, Logical);
end;


procedure TChartForm.HorLine(y: Double; AColor: TColor; ALineStyle: TPenStyle;
  ALegendTitle: String);
begin
  ChartFrame.HorLine(y, AColor, ALineStyle, ALegendTitle);
end;


procedure TChartForm.VertLine(x: Double; AColor: TColor; ALineStyle: TPenStyle;
  ALegendTitle: String);
begin
  ChartFrame.VertLine(x, AColor, ALineStyle, ALegendTitle);
end;


function TChartForm.PlotXY(AType: TPlotType; x, y: DblDyneVec;
  LegendTitle: string; AColor: TColor; ASymbol: TSeriesPointerStyle = psCircle): TChartSeries;
begin
  Result := ChartFrame.PlotXY(AType, x, y, LegendTitle, AColor, ASymbol);
end;


procedure TChartForm.SaveBtnClick(Sender: TObject);
begin
  ChartFrame.Save;
end;


procedure TChartForm.SetFooter(const ATitle: String);
begin
  ChartFrame.SetFooter(ATitle);
end;


procedure TChartForm.SetTitle(const ATitle: String);
begin
  ChartFrame.SetTitle(ATitle);
end;


procedure TChartForm.SetXTitle(const ATitle: String);
begin
  ChartFrame.SetXTitle(ATitle);
end;


procedure TChartForm.SetYTitle(const ATitle: String);
begin
  ChartFrame.SetYTitle(ATitle);
end;


end.

