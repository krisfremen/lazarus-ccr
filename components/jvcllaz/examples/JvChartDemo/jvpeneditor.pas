unit jvPenEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ButtonPanel, Contnrs, Types,
  JvChart;

type
  TPenObj = class
    Legend: String;
    Color: TColor;
    Style: TPenStyle;
    Marker: TJvChartPenMarkerKind;
  end;

  { TPenEditorForm }

  TPenEditorForm = class(TForm)
    btnPenColor: TButton;
    btnAdd: TButton;
    btnDelete: TButton;
    btnClear: TButton;
    ButtonPanel1: TButtonPanel;
    ColorDialog: TColorDialog;
    edPenLegend: TEdit;
    lblLegend: TLabel;
    lbPens: TListBox;
    rgMarker: TRadioGroup;
    rgPenStyle: TRadioGroup;
    ColorSample: TShape;
    procedure btnAddClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnPenColorClick(Sender: TObject);
    procedure edPenLegendEditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbPensDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure lbPensSelectionChange(Sender: TObject; User: boolean);
    procedure rgMarkerClick(Sender: TObject);
    procedure rgPenStyleClick(Sender: TObject);
  private
    FPens: TObjectList;
    procedure ControlsToPen(AIndex: Integer);
    procedure PenToControls(AIndex: Integer);
    function GetCurrentPen: TPenObj;

  public
    procedure ApplyToChart(AChart: TJvChart);
    procedure UseChart(AChart: TJvChart);

  end;


implementation

{$R *.lfm}

uses
  LCLType;


{ TPenEditorForm }

procedure TPenEditorForm.ApplyToChart(AChart: TJvChart);
var
  i: Integer;
  pen: TPenObj;
begin
  Assert(AChart <> nil);
  AChart.Options.PenCount := FPens.Count;
  AChart.Options.PenLegends.Clear;
  for i := 0 to FPens.Count - 1 do
  begin
    pen := TPenObj(FPens[i]);
    AChart.Options.PenLegends.Add(pen.Legend);
    AChart.Options.PenColor[i] := pen.Color;
    AChart.Options.PenStyle[i] := pen.Style;
    AChart.Options.PenMarkerKind[i] := pen.Marker;
  end;
end;

procedure TPenEditorForm.btnAddClick(Sender: TObject);
var
  pen: TPenObj;
begin
  pen := TPenObj.Create;
  pen.Legend := '';
  pen.Style := psSolid;
  pen.Color := clBlack;
  pen.Marker := pmkNone;
  FPens.Add(pen);
  lbPens.Items.Add('');
end;

procedure TPenEditorForm.btnClearClick(Sender: TObject);
begin
  FPens.Clear;
  lbPens.Items.Clear;
end;

procedure TPenEditorForm.btnDeleteClick(Sender: TObject);
begin
  if lbPens.ItemIndex = -1 then
    exit;
  FPens.Delete(lbPens.ItemIndex);
  lbPens.Items.Delete(lbPens.ItemIndex);
end;

procedure TPenEditorForm.btnPenColorClick(Sender: TObject);
var
  pen: TPenObj;
begin
  pen := GetCurrentPen;
  if pen = nil then
    exit;

  ColorDialog.Color := pen.Color;
  if ColorDialog.Execute then begin
    pen.Color := ColorDialog.Color;
    lbPens.Invalidate;
  end;
end;

procedure TPenEditorForm.ControlsToPen(AIndex: Integer);
var
  pen: TPenObj;
begin
  if AIndex = -1 then
    exit;
  pen := TPenObj(FPens[AIndex]);
  pen.Legend := edPenLegend.Text;
  if rgPenStyle.ItemIndex = rgPenStyle.Items.Count-1 then
    pen.Style := psClear
  else
    pen.Style := TPenStyle(rgPenStyle.ItemIndex);
  pen.Marker := TJvChartPenMarkerKind(rgMarker.ItemIndex);
  pen.Color := ColorSample.Brush.Color;
end;

procedure TPenEditorForm.edPenLegendEditingDone(Sender: TObject);
var
  pen: TPenObj;
begin
  pen := GetCurrentPen;
  if pen = nil then
    exit;
  pen.Legend := edPenLegend.Text;
  lbPens.Invalidate;
end;

procedure TPenEditorForm.FormCreate(Sender: TObject);
begin
  FPens := TObjectList.Create;
end;

procedure TPenEditorForm.FormDestroy(Sender: TObject);
begin
  FPens.Free;
end;

function TPenEditorForm.GetCurrentPen: TPenObj;
begin
  if lbPens.ItemIndex = -1 then
    Result := nil
  else
    Result := TPenObj(FPens[lbPens.ItemIndex]);
end;

procedure TPenEditorForm.lbPensDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  R: TRect;
  pen: TPenObj;
  x, y, dx, dy: Integer;
begin
  pen := TPenObj(FPens[Index]);
  lbPens.Canvas.Font.Assign(lbPens.Font);

  // Background
  if [odSelected, odFocused] * State <> [] then
  begin
    lbPens.Canvas.Brush.Color := clHighlight;
    lbPens.Canvas.Font.Color := clHighlightText;
  end else
  begin
    lbPens.Canvas.Brush.Color := lbPens.Color;
    lbPens.Canvas.Font.Color := lbPens.Font.Color;
  end;
  lbPens.Canvas.FillRect(ARect);

  // Line
  R := ARect;
  R.Right := R.Left + 50;
  InflateRect(R, -2, -2);
  lbPens.Canvas.Pen.Style := pen.Style;
  lbPens.Canvas.Pen.Color := pen.Color;
  lbPens.Canvas.Line(R.Left, (R.Top + R.Bottom) div 2, R.Right, (R.Top + R.Bottom) div 2);

  // Marker
  x := (R.Left + R.Right) div 2;
  y := (R.Top + R.Bottom) div 2;
  dx := (R.Bottom - R.Top) div 2;
  dy := dx;
  lbPens.Canvas.Pen.Style := psSolid;
  case pen.Marker of
    pmkNone: ;
    pmkDiamond:
      begin
        lbPens.Canvas.Brush.Color := pen.Color;
        lbPens.Canvas.Brush.Style := bsSolid;
        lbPens.Canvas.Polygon([Point(x, y-dy), Point(x-dx, y), Point(x, y+dy), Point(x+dx, y)]);
      end;
    pmkCircle:
      begin
        lbPens.Canvas.Brush.Style := bsClear;
        lbPens.Canvas.Ellipse(x-dx, y-dy, x+dx, y+dy);
      end;
    pmkSquare:
      begin
        lbPens.Canvas.Brush.Style := bsClear;
        lbPens.Canvas.Rectangle(x-dx, y-dy, x+dx, y+dy);
      end;
    pmkCross:
      begin
        lbPens.Canvas.Line(x-dx, y, x+dx, y);
        lbPens.Canvas.Line(x, y-dy, x, y+dy);
      end;
    else
      raise Exception.Create('Marker style not supported.');
  end;

  // Text
  lbPens.Canvas.Brush.Style := bsClear;
  lbPens.Canvas.TextOut(R.Right + 2, (R.Top + R.Bottom - lbPens.Canvas.TextHeight('Rg')) div 2, pen.Legend);

  // Focus rect
  if odFocused in State then
    lbPens.Canvas.DrawFocusRect(ARect);
end;

procedure TPenEditorForm.lbPensSelectionChange(Sender: TObject; User: boolean);
begin
  PenToControls(lbPens.ItemIndex);
end;

procedure TPenEditorForm.PenToControls(AIndex: Integer);
var
  pen: TPenObj;
begin
  if AIndex = -1 then
    exit;

  pen := TPenObj(FPens[AIndex]);
  edPenLegend.Text := pen.Legend;
  if pen.Style = psClear then
    rgPenStyle.ItemIndex := rgPenStyle.Items.Count-1
  else
    rgPenStyle.ItemIndex := ord(pen.Style);
  rgMarker.ItemIndex := ord(pen.Marker);
  ColorSample.Brush.Color := pen.Color;

  edPenLegend.Enabled := true;
  rgPenStyle.Enabled := true;
  rgMarker.Enabled := true;
  btnPenColor.Enabled := true;
  ColorSample.Visible := true;
end;

procedure TPenEditorForm.rgMarkerClick(Sender: TObject);
var
  pen: TPenObj;
begin
  pen := GetCurrentPen;
  if pen = nil then
    exit;
  pen.Marker := TJvChartPenMarkerKind(rgMarker.ItemIndex);
  lbPens.Invalidate;
end;

procedure TPenEditorForm.rgPenStyleClick(Sender: TObject);
var
  pen: TPenObj;
begin
  pen := GetCurrentPen;
  if pen = nil then
    exit;

  if rgPenStyle.itemIndex = rgPenStyle.Items.Count -1 then
    pen.Style := psClear
  else
    pen.Style := TPenStyle(rgPenStyle.ItemIndex);
  lbPens.Invalidate;
end;

procedure TPenEditorForm.UseChart(AChart: TJvChart);
var
  i: Integer;
  pen: TPenObj;
begin
  Assert(AChart <> nil);

  FPens.Clear;
  lbPens.Items.Clear;
  for i := 0 to AChart.Options.PenLegends.Count - 1 do
  begin
    pen := TPenObj.Create;
    pen.Legend := AChart.Options.PenLegends[i];
    pen.Color := AChart.Options.PenColor[i];
    pen.Style := AChart.Options.PenStyle[i];
    pen.Marker := AChart.Options.PenMarkerKind[i];
    FPens.Add(pen);
    lbPens.Items.Add('');
  end;

  edPenLegend.Enabled := false;
  rgPenStyle.Enabled := false;
  rgMarker.Enabled := false;
  btnPenColor.Enabled := false;
  ColorSample.Visible := false;
end;

end.

