// Use file "bubbleplot2.laz" for testing.

unit BubblePlotUnit;

{$mode objfpc}{$H+}
{$I ../../../LazStats.inc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Clipbrd, Buttons, ExtCtrls, Math,
  MainUnit, Globals, DataProcs, DictionaryUnit, ContextHelpUnit;


type

  { TBubbleForm }

  TBubbleForm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    TransformChk: TCheckBox;
    YLabelEdit: TEdit;
    Label8: TLabel;
    XLabelEdit: TEdit;
    Label7: TLabel;
    TitleEdit: TEdit;
    Label6: TLabel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    IDInBtn: TBitBtn;
    IDOutBtn: TBitBtn;
    XInBtn: TBitBtn;
    XOutBtn: TBitBtn;
    YInBtn: TBitBtn;
    YOutBtn: TBitBtn;
    SizeInBtn: TBitBtn;
    SizeOutBtn: TBitBtn;
    BubbleEdit: TEdit;
    SizeEdit: TEdit;
    YEdit: TEdit;
    XEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure IDInBtnClick(Sender: TObject);
    procedure IDOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure SizeInBtnClick(Sender: TObject);
    procedure SizeOutBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure XInBtnClick(Sender: TObject);
    procedure XOutBtnClick(Sender: TObject);
    procedure YInBtnClick(Sender: TObject);
    procedure YOutBtnClick(Sender: TObject);
  private
    { private declarations }
    BubbleCol, XCol, YCol, SizeCol: Integer;
    FAutoSized: boolean;
    procedure PlotBubbles(
      {$IFNDEF USE_TACHART}NoReplications: Integer; XMax, XMin: Integer;{$ENDIF}
      YMax, YMin, BubMax, BubMin: Double);
    procedure UpdateBtnStates;
  public
    { public declarations }
    procedure Reset;
  end; 

var
  BubbleForm: TBubbleForm;

implementation

{$R *.lfm}

uses
  {$IFDEF USE_TACHART}
  TAMultiSeries,
  ChartUnit,
  {$ELSE}
  BlankFrmUnit,
  {$ENDIF}
  OutputUnit;

{ TBubbleForm }

procedure TBubbleForm.ComputeBtnClick(Sender: TObject);
var
  i, j, cell: integer;
  Xmin, Xmax, intcell, noreplications, minrep, maxrep: integer;
  nobubbles: integer;
  varname: string;
  Ymin, Ymax, xvalue, yvalue, sizeValue, cellValue: double;
  BubMin, BubMax: double;
  ncases, ncols, BubbleID, newcol: integer;
  GrandYMean, GrandSizeMean: double;
  Data: DblDyneMat = nil;
  Ymeans: DblDyneVec = nil;
  CaseYMeans: DblDyneVec = nil;
  SizeMeans: DblDyneVec = nil;
  CaseSizeMeans: DblDyneVec = nil;
  outline: string;
  labels: StrDyneVec = nil;
  lReport: TStrings;
begin
  BubbleCol := 0;
  XCol := 0;
  YCol := 0;
  SizeCol := 0;
  for i := 1 to NoVariables do
  begin
    varname := OS3MainFrm.DataGrid.Cells[i,0];
    if (varname = BubbleEdit.Text) then BubbleCol := i;
    if (varname = XEdit.Text) then XCol := i;
    if (varname = YEdit.Text) then YCol := i;
    if (varname = SizeEdit.Text) then SizeCol := i;
  end;
  if ((BubbleCol = 0) or (XCol = 0) or (YCol = 0) or (SizeCol = 0)) then
  begin
    MessageDlg('One or more variables not found.', mtError, [mbOK], 0);
    ModalResult := mrNone;
    Exit;
  end;

  // get number of bubbles and replications per bubble (number of bubble id's)
  minrep := 1000;
  maxrep := -1;
  for i := 1 to NoCases do
  begin
    intcell := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
    if (intcell > maxrep) then maxrep := intcell;
    if (intcell < minrep) then minrep := intcell;
  end;
  nobubbles := maxrep - minrep + 1;
  noreplications := 1;
  intcell := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,1]);
  for i := 2 to NoCases do
  begin
    cell := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
    if (cell = intcell) then noreplications := noreplications + 1;
  end;

  // get min, max and range of Y
  Ymin := 1.0e308;
  Ymax := -1.0e308;
  for i := 1 to NoCases do
  begin
    cellvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
    if (cellvalue > Ymax) then Ymax := cellvalue;
    if (cellvalue < Ymin) then Ymin := cellvalue;
  end;

  // get min, max and range of X
  Xmin := 10000;
  Xmax := -1;
  for i := 1 to NoCases do
  begin
    intcell := StrToInt(OS3MainFrm.DataGrid.Cells[XCol,i]);
    if (intcell > Xmax) then Xmax := intcell;
    if (intcell < Xmin) then Xmin := intcell;
  end;

  // get min, max, range, and increment of bubble sizes
  BubMin := Infinity;
  BubMax := -Infinity;
  for i := 1 to NoCases do
  begin
    cellvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[SizeCol,i]);
    if (cellvalue > BubMax) then BubMax := cellvalue;
    if (cellvalue < BubMin) then BubMin := cellvalue;
  end;

  // Display basic statistics
  nCases := NoCases div NoReplications;
  GrandYMean := 0.0;
  GrandSizeMean := 0.0;
  SetLength(CaseYMeans, nCases);
  SetLength(CaseSizeMeans, nCases);
  SetLength(YMeans, NoReplications);
  SetLength(SizeMeans, NoReplications);
  for i := 0 to nCases - 1 do
  begin
    CaseYMeans[i] := 0.0;
    CaseSizeMeans[i] := 0.0;
  end;
  for i := 0 to NoReplications - 1 do
  begin
    YMeans[i] := 0.0;
    SizeMeans[i] := 0.0;
  end;

  i := 1;
  while (i <= NoCases) do
  begin
    for j := 0 to NoReplications - 1 do
    begin
      bubbleID := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
      yvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
      sizevalue := StrToFloat(OS3MainFrm.DataGrid.Cells[SizeCol,i]);
      GrandYMean := GrandYMean + yvalue;
      GrandSizeMean := GrandSizeMean + sizevalue;
      Ymeans[j] := Ymeans[j] + yvalue;
      SizeMeans[j] := SizeMeans[j] + sizevalue;
      CaseYMeans[bubbleID-1] := CaseYMeans[bubbleID-1] + yvalue;
      CaseSizeMeans[bubbleID-1] := CaseSizeMeans[bubbleID-1] + sizevalue;
      inc(i);
    end;
  end;

  GrandYMean := GrandYMean / (ncases * noreplications);
  GrandSizeMean := GrandSizeMean  / (ncases * noreplications);
  for j := 0 to NoReplications - 1 do
  begin
    Ymeans[j] := Ymeans[j] / ncases;
    SizeMeans[j] := SizeMeans[j] / ncases;
  end;
  for i := 0 to ncases - 1 do
  begin
    CaseYMeans[i] := CaseYMeans[i] / noreplications;
    CaseSizeMeans[i] := CaseSizeMeans[i] / noreplications;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('MEANS FOR Y AND SIZE VARIABLES');
    lReport.Add('');
    lReport.Add('Grand Mean for Y:         %8.3f', [GrandYMean]);
    lReport.Add('Grand Mean for Size:      %8.3f', [GrandSizeMean]);
    lReport.Add('');
    lReport.Add('REPLICATION MEAN Y VALUES (ACROSS OBJECTS)');
    for j := 0 to NoReplications - 1 do
      lReport.Add('Replication %5d   Mean: %8.3f', [j+1, Ymeans[j]]);
    lReport.Add('');
    lReport.Add('REPLICATION MEAN SIZE VALUES (ACROSS OBJECTS)');
    for j := 0 to NoReplications - 1 do
      lReport.Add('Replication %5d   Mean: %8.3f', [j+1, SizeMeans[j]]);
    lReport.Add('');
    lReport.Add('MEAN Y VALUES FOR EACH BUBBLE (OBJECT)');
    for i := 0 to NCases - 1 do
      lReport.Add('     Object %5d   Mean: %8.3f', [i+1, CaseYMeans[i]]);
    lReport.Add('');
    lReport.Add('MEAN SIZE VALUES FOR EACH BUBBLE (OBJECT)');
    for i := 0 to NCases - 1 do
      lReport.Add('     Object %5d   Mean: %8.3f', [i+1, CaseSizeMeans[i]]);

    // Show the report
    if DisplayReport(lReport) then
      // Plot the bubbles
      PlotBubbles(
        {$IFNDEF USE_TACHART}NoReplications, XMax, XMin, {$ENDIF}
        YMax, YMin, BubMax, BubMin
      );

  finally
    lReport.Free;
    SizeMeans := nil;
    Ymeans := nil;
    CaseSizeMeans := nil;
    CaseYMeans := nil;
  end;

  // Transform data matrix if elected
  if TransformChk.Checked then
  begin
    ncases := nobubbles;
    ncols := noreplications * 3 + 1;

    // Note - columns: 1:=object ID, 2 to noreplications := X,
    // next noreplications := Y, next noreplications := size
    SetLength(Data, ncases, ncols);
    i := 1;
    while (i <= NoCases) do
    begin
      for j := 1 to noreplications do
      begin
        bubbleID := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
        xvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol,i]);
        yvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
        sizevalue := StrToFloat(OS3MainFrm.DataGrid.Cells[SizeCol,i]);
        Data[bubbleID-1,0] := bubbleID;
        Data[bubbleID-1,j] := xvalue;
        Data[bubbleID-1,noreplications+j] := yvalue;
        Data[bubbleID-1,noreplications*2+j] := sizevalue;
        inc(i);
      end;
    end;

    SetLength(labels, NoVariables+1);
    for i := 1 to NoVariables do labels[i] := OS3MainFrm.DataGrid.Cells[i,0];
    ClearGrid;
    OS3MainFrm.DataGrid.RowCount := ncases + 1;
    OS3MainFrm.DataGrid.ColCount := ncols + 1;

    for i := 1 to ncases do
    begin
      OS3MainFrm.DataGrid.Cells[0,i] := IntToStr(i);
      for j := 1 to ncols do
        OS3MainFrm.DataGrid.Cells[j,i] := FloatToStr(Data[i-1,j-1]);
    end;
    OS3MainFrm.DataGrid.Cells[1,0] := labels[1];

    for j := 2 to NoVariables do // clear dictionary
    begin
      for i := 0 to 7 do DictionaryFrm.DictGrid.Cells[i,j] := '';
      DictionaryFrm.DictGrid.RowCount := DictionaryFrm.DictGrid.RowCount - 1;
      VarDefined[j] := false;
    end;
    DictionaryFrm.DictGrid.Cells[1,1] := labels[1];

    for j := 1 to noreplications do
    begin
      outline := labels[2] + IntToStr(j);
      newcol := j + 1;
      if (newcol+1 > DictionaryFrm.DictGrid.RowCount) then
        DictionaryFrm.DictGrid.RowCount := DictionaryFrm.DictGrid.RowCount + 1;
      DictionaryFrm.Defaults(Self,newcol);
      VarDefined[newcol] := true;
      DictionaryFrm.DictGrid.Cells[1,newcol] := outline;
      OS3MainFrm.DataGrid.Cells[newcol,0] := outline;
    end;

    for j := 1 to noreplications do
    begin
      outline := labels[3] + IntToStr(j);
      newcol := j + 1 + noreplications;
      OS3MainFrm.DataGrid.Cells[newcol,0] := outline;
      if (newcol+1 > DictionaryFrm.DictGrid.RowCount) then
        DictionaryFrm.DictGrid.RowCount := DictionaryFrm.DictGrid.RowCount + 1;
      DictionaryFrm.Defaults(Self,newcol);
      VarDefined[newcol] := true;
      DictionaryFrm.DictGrid.Cells[1,newcol] := outline;
    end;

    for j := 1 to noreplications do
    begin
      outline := labels[4] + IntToStr(j);
      newcol := j + 1 + noreplications * 2;
      OS3MainFrm.DataGrid.Cells[newcol,0] := outline;

      if (newcol+1 > DictionaryFrm.DictGrid.RowCount) then
        DictionaryFrm.DictGrid.RowCount := DictionaryFrm.DictGrid.RowCount + 1;
      DictionaryFrm.Defaults(Self,newcol);
      VarDefined[newcol] := true;

      DictionaryFrm.DictGrid.Cells[1,newcol] := outline;
    end;

    NoVariables := ncols;
    NoCases := ncases;
    OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
    Data := nil;
    labels := nil;
  end;
end;


procedure TBubbleForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Panel1.Constraints.MinHeight := SizeOutBtn.Top + SizeOutBtn.Height;
  Panel1.Constraints.MinWidth := 2*Label2.Width + IDInBtn.Width + 2*VarList.BorderSpacing.Right;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := True;
end;


procedure TBubbleForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
  Reset;
end;


procedure TBubbleForm.IDInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (BubbleEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if (VarList.Selected[i]) then
    begin
      BubbleEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;


procedure TBubbleForm.IDOutBtnClick(Sender: TObject);
begin
  if BubbleEdit.Text <> '' then
    VarList.Items.Add(BubbleEdit.Text);
  UpdateBtnStates;
end;


procedure TBubbleForm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;


{$IFDEF USE_TACHART}
procedure TBubbleForm.PlotBubbles(YMax, YMin, BubMax, BubMin: Double);
var
  ser: TBubbleSeries;
  bubbleIDs: TStringList;
  i, j: Integer;
  id: Integer;
  xValue, yValue, sizeValue: Double;
  s: String;
  yRange, bubRange: Double;
begin
  yRange := YMax - YMin;
  BubRange := BubMax - BubMin;

  if ChartForm = nil then
    ChartForm := TChartForm.Create(Application)
  else
    ChartForm.Clear;

  // Titles
  ChartForm.Caption := 'Bubble Plot of ' + OS3MainFrm.FileNameEdit.Text + LineEnding + TitleEdit.Text;
  ChartForm.SetTitle(TitleEdit.Text);
  if XLabelEdit.Text <> '' then
    ChartForm.SetXTitle(XLabelEdit.Text)
  else
    ChartForm.SetXTitle(XEdit.Text);
  if YLabelEdit.Text <> '' then
    ChartForm.SetYTitle(YLabelEdit.Text)
  else
    ChartForm.SetYTitle(YEdit.Text);

  // Collect bubble IDs and create a bubble series for each unique ID.
  bubbleIDs := TStringList.Create;
  try
    for i := 1 to NoCases do
    begin
      s := OS3MainFrm.DataGrid.Cells[BubbleCol, i];
      if bubbleIDs.IndexOf(s) = -1 then   // Add each ID only once!
        bubbleIDs.Add(s);
    end;
    for i := 0 to bubbleIDs.Count-1 do
    begin
      ser := TBubbleSeries.Create(ChartForm);
      ser.BubbleBrush.Color := DATA_COLORS[i mod Length(DATA_COLORS)];
      ser.BubbleRadiusUnits := bruY;
      ser.Title := bubbleIDs[i];
      ser.Tag := StrToInt(bubbleIDs[i]);
      ChartForm.Chart.AddSeries(ser);
    end;
  finally
    bubbleIDs.Free;
  end;

  for i := 1 to NoCases do begin
    id := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol, i]);
    // Find the series having this ID
    for j := 0 to ChartForm.Chart.SeriesCount-1 do
      if (ChartForm.Chart.Series[j] is TBubbleSeries) and
         (TBubbleSeries(ChartForm.Chart.Series[j]).Tag = id) then
      begin
        ser := TBubbleSeries(ChartForm.Chart.Series[j]);
        break;
      end;

    xValue := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol, i]);
    yValue := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol, i]);
    sizeValue := StrToFloat(OS3MainFrm.DataGrid.Cells[SizeCol, i]);
    sizeValue := ((sizeValue - BubMin) / BubRange * 0.91 + 0.09) * YRange * 0.1;
    // This scaling makes the larges bubble equal to 10% of the y range;
    // the ratio of largest to smallest bubble is about 10:1.

    ser.AddXY(xValue, yValue, sizeValue);
  end;

  ChartForm.Chart.Legend.Visible := true;
  ChartForm.Show;
end;
{$ELSE}
procedure TBubbleForm.PlotBubbles(NoReplications: Integer;
  XMax, XMin: Integer; YMax, YMin, BubMax, BubMin: Double);
var
  i, j: Integer;
  XLabel, YLabel, Title, valStr, aString: String;
  ImageWide, ImageHi, Xstart, Xend, Ystart, Yend, Yincr: integer;
  LabelWide, TextHi, Xpos: Integer;
  BubColor, place: integer;
  X1, Y1, X2, Y2: integer;
  dx, dy: Integer;
  XRange, XStep: Integer;
  YRange, YStep, BubRange: Double;
  ratio, value: Double;
  intCell: Integer;
  xValue, cellvalue: Double;
  yProp: Integer;
begin
  if BlankFrm = nil then
    BlankFrm := TBlankFrm.Create(Application);

  XRange := Xmax - Xmin;
  XStep := XRange div (NoReplications - 1);
  YRange := Ymax - Ymin;
  YStep := Yrange / 10;
  BubRange := BubMax - BubMin;

  BlankFrm.Show;
  BlankFrm.Caption := 'BUBBLE PLOT of ' + OS3MainFrm.FileNameEdit.Text;
  Xlabel := XlabelEdit.Text;
  Ylabel := YlabelEdit.Text;
  Title := TitleEdit.Text;
  ImageHi := BlankFrm.Image1.Height;
  ImageWide := BlankFrm.Image1.Width;
  Xstart := ImageWide div 10;
  Xend := (ImageWide * 9) div 10;
  Ystart := ImageHi div 10;
  Yend := (ImageHi * 8) div 10;
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Rectangle(0,0,ImageWide,ImageHi);
  BlankFrm.Image1.Canvas.FloodFill(0,0,clWhite,fsBorder);
  BlankFrm.Image1.Canvas.TextOut(Xstart-10,Ystart-30,Ylabel);
  LabelWide := BlankFrm.Image1.Canvas.TextWidth(Xlabel);
  BlankFrm.Image1.Canvas.TextOut((Xend-Xstart) div 2 - LabelWide,Yend + 40,Xlabel);
  LabelWide := BlankFrm.Image1.Canvas.TextWidth(Title);
  BlankFrm.Image1.Canvas.TextOut((Xend-Xstart) div 2 - LabelWide div 2, Ystart - 40,Title);

  // draw axis lines
  BlankFrm.Image1.Canvas.MoveTo(Xstart,Yend);
  BlankFrm.Image1.Canvas.LineTo(Xend,Yend);
  BlankFrm.Image1.Canvas.MoveTo(Xstart,Yend);
  BlankFrm.Image1.Canvas.LineTo(Xstart,Ystart);

  // create y axis values
  Yincr := (Yend - Ystart) div 10;
  for i := 0 to 10 do  // print Y axis values
  begin
    place := Yend - Yincr * i;
    value := Ymin + Ystep * i;
    valStr := Format('%.2f', [value]);
    TextHi := BlankFrm.Image1.Canvas.TextHeight(valStr);
    BlankFrm.Image1.Canvas.TextOut(Xstart-30,place-TextHi, valStr);
  end;

  // create x axis values
  for i := 1 to NoReplications do  // print x axis
  begin
    value := Xmin + ((i-1) * Xstep);
    ratio := i / NoReplications;
    Xpos := round(ratio * (Xend - Xstart));
    valStr := Format('%.0f',[value]);
    BlankFrm.Image1.Canvas.TextOut(Xpos,Yend + 20, valStr);
  end;

  // Plot the bubbles
  for i := 1 to NoCases do
  begin
    intcell := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
    xvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol,i]);
    cellvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
    yprop := Yend - round(((cellvalue-Ymin) / Yrange) * (Yend - Ystart));
    cellvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[SizeCol,i]);
    astring := Trim(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
    cellvalue := ((cellvalue - BubMin) / BubRange) * 20;
    cellvalue := cellvalue + 10;
    ratio := ((xvalue - Xmin) / Xstep) + 1;
    ratio := (ratio / noreplications) * (Xend - Xstart);
    Xpos := ceil(ratio);
    BubColor := intcell - 1;
    while (Bubcolor > 11) do Bubcolor := 12 - Bubcolor;
    BlankFrm.Image1.Canvas.Brush.Color := DATA_COLORS[Bubcolor];
    X1 := Xpos - ceil(cellvalue);
    Y1 := yprop - ceil(cellvalue);
    X2 := Xpos + ceil(cellvalue);
    Y2 := yprop + ceil(cellvalue);
    BlankFrm.Image1.Canvas.Ellipse(X1,Y1,X2,Y2);
    BlankFrm.Image1.Canvas.Brush.Color := clWhite;
    dx := BlankFrm.Image1.Canvas.TextWidth(astring) div 2;
    dy := BlankFrm.Image1.Canvas.TextHeight(astring) div 2;
    BlankFrm.Image1.Canvas.TextOut(Xpos-dx, yprop-dy, astring);
  end;
end;
{$ENDIF}


procedure TBubbleForm.Reset;
var
  i: integer;
begin
  BubbleEdit.Text := '';
  XEdit.Text := '';
  YEdit.Text := '';
  SizeEdit.Text := '';
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;


procedure TBubbleForm.ResetBtnClick(Sender: TObject);
begin
  Reset;
end;


procedure TBubbleForm.SizeInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (SizeEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] then
    begin
      SizeEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;


procedure TBubbleForm.SizeOutBtnClick(Sender: TObject);
begin
  if SizeEdit.Text <> '' then
     VarList.Items.Add(SizeEdit.Text);
  UpdateBtnStates;
end;


procedure TBubbleForm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i:=0 to VarList.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;

  IDInBtn.Enabled := lSelected and (BubbleEdit.Text = '');
  XInBtn.Enabled := lSelected and (XEdit.Text = '');
  YInBtn.Enabled := lSelected and (YEdit.Text = '');
  SizeInBtn.Enabled := lSelected and (SizeEdit.Text = '');
  IDOutBtn.Enabled := BubbleEdit.Text <> '';
  XOutBtn.Enabled := XEdit.Text <> '';
  YOutBtn.Enabled := YEdit.Text <> '';
  SizeOutBtn.Enabled := SizeEdit.Text <> '';
end;


procedure TBubbleForm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


procedure TBubbleForm.XInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (XEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] then
    begin
      XEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;


procedure TBubbleForm.XOutBtnClick(Sender: TObject);
begin
  if XEdit.Text <> '' then
    VarList.Items.Add(XEdit.Text);
  UpdateBtnStates;
end;


procedure TBubbleForm.YInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (YEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] then
    begin
      YEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;


procedure TBubbleForm.YOutBtnClick(Sender: TObject);
begin
  if YEdit.Text <> '' then
    VarList.Items.Add(YEdit.Text);
  UpdateBtnStates;
end;


end.

