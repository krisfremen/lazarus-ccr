// Use file "anova2.laz" for testing

unit BoxPlotUnit;

{$mode objfpc}{$H+}
{$I ../../../LazStats.inc}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Printers,
  MainUnit, Globals, DataProcs, OutputUnit, ContextHelpUnit;


type

  { TBoxPlotFrm }

  TBoxPlotFrm = class(TForm)
    HorCenterBevel: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    ShowChk: TCheckBox;
    GroupBox1: TGroupBox;
    MeasEdit: TEdit;
    GroupEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    function Percentile(nScoreGrps: integer; APercentile: Double;
      const Freq, CumFreq, Scores: DblDyneVec) : double;
    {$IFDEF USE_TACHART}
    procedure BoxPlot(const LowQrtl, HiQrtl, TenPcnt, NinetyPcnt, Medians: DblDyneVec);
    {$ELSE}
    procedure BoxPlot(NBars: integer; AMax, AMin: double;
      const LowQrtl, HiQrtl, TenPcnt, NinetyPcnt, Means, Median: DblDyneVec);
    {$ENDIF}

  public
    { public declarations }
  end; 

var
  BoxPlotFrm: TBoxPlotFrm;

implementation

{$R *.lfm}

uses
  {$IFDEF USE_TACHART}
  TAChartUtils, TAMultiSeries,
  ChartUnit,
  {$ELSE}
  BlankFrmUnit,
  {$ENDIF}
  Math, Utils;

const
  BOX_COLORS: Array[0..3] of TColor = (clBlue, clGreen, clFuchsia, clLime);


{ TBoxPlotFrm }

procedure TBoxPlotFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  GroupEdit.Text := '';
  MeasEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;


procedure TBoxPlotFrm.VarListClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    if (GroupEdit.Text = '') then
      GroupEdit.Text := VarList.Items[index]
    else
      MeasEdit.Text := VarList.Items[index];
  end;
end;


procedure TBoxPlotFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;


procedure TBoxPlotFrm.ComputeBtnClick(Sender: TObject);
var
  lReport: TStrings;
  i, j, k, GrpVar, MeasVar, mingrp, maxgrp, G, NoGrps, cnt: integer;
  nScoreGrps: integer;
  X, tmp: Double;
//  X, tenpcnt, ninepcnt, qrtile1, qrtile2, qrtile3: double;
  MinScore, MaxScore, IntervalSize, lastX: double;
  cellstring: string;
  done: boolean;
  NoSelected: integer;
  Freq: DblDyneVec = nil;
  Scores: DblDyneVec = nil;
  CumFreq: DblDyneVec = nil;
  pRank: DblDyneVec = nil;
  GrpSize: IntDyneVec = nil;
  Means: DblDyneVec = nil;
  LowQrtl: DblDyneVec = nil;
  HiQrtl: DbldyneVec = nil;
  TenPcntile: DblDyneVec = nil;
  NinetyPcntile: DblDyneVec = nil;
  Median: DblDyneVec = nil;
  ColNoSelected: IntDyneVec = nil;
begin
  lReport := TStringList.Create;
  try
    lReport.Add('BOX PLOTS OF GROUPS');
    lReport.Add('');

    GrpVar := 0;
    MeasVar := 0;
    for i := 1 to NoVariables do
    begin
      cellstring := OS3MainFrm.DataGrid.Cells[i,0];
      if cellstring = GroupEdit.Text then GrpVar := i;
      if cellstring = MeasEdit.Text then MeasVar := i;
    end;
    if GrpVar = 0 then
    begin
      ErrorMsg('Group variable not selected.');
      exit;
    end;
    if MeasVar = 0 then
    begin
      ErrorMsg('Measurement variable not selected.');
      exit;
    end;

    NoSelected := 2;
    SetLength(ColNoSelected, NoSelected);
    ColNoSelected[0] := GrpVar;
    ColNoSelected[1] := MeasVar;

    // get minimum and maximum group values
    minGrp := MaxInt;
    maxGrp := -MaxInt;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, NoSelected, ColNoSelected) then continue;
      G := round(StrToFloat(OS3MainFrm.DataGrid.Cells[GrpVar, i]));
      minGrp := Min(G, minGrp);
      maxGrp := Max(G, maxGrp);
    end;
    NoGrps := maxGrp - minGrp + 1;
    if NoGrps > 30 then
    begin
      ErrorMsg('Too many groups for a meaningful plot (max: 20)');
      exit;
    end;

    // get minimum and maximum scores and score interval
    IntervalSize := Infinity;
    lastX := 0.0;
    X := StrToFloat(OS3MainFrm.DataGrid.Cells[MeasVar, 1]);
    MinScore := X;
    MaxScore := X;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, NoSelected ,ColNoSelected) then continue;
      X := StrToFloat(OS3MainFrm.DataGrid.Cells[MeasVar, i]);
      MaxScore := Max(MaxScore, X);
      MinScore := Min(MinScore, X);
      if i > 1 then // get interval size as minimum difference between 2 scores
      begin
        if (X <> lastX) and (abs(X - lastX) < IntervalSize) then
          IntervalSize := abs(X - lastX);
        lastX := X;
      end else
        lastX := X;
    end;

    SetLength(Scores, 2*NoCases + 1);  // over-dimensioned, will be trimmed later.

    //  check for excess no. of intervals and reset if needed
    nScoreGrps := round((MaxScore - MinScore) / IntervalSize);
    if nScoreGrps > 2 * NoCases then
      Intervalsize := (MaxScore - MinScore) / NoCases;

    // setup score groups
    done := false;
    Scores[0] := MinScore - IntervalSize / 2.0;
    nScoreGrps := 0;
    lastX := MaxScore + IntervalSize + IntervalSize / 2.0;

    while not done do
    begin
      inc(nScoreGrps);
      Scores[nScoreGrps] := MinScore + (nScoreGrps * IntervalSize) - IntervalSize / 2.0;
      if Scores[nScoreGrps] > lastX then done := true;
    end;
    Scores[nScoreGrps + 1] := Scores[nScoreGrps] + IntervalSize;
    if Scores[0] < MinScore then MinScore := Scores[0];
    if Scores[nScoreGrps] > MaxScore then MaxScore := Scores[nScoreGrps];

    SetLength(Scores, nScoreGrps+1);     // trim to used length
    SetLength(Freq, nScoreGrps);
    SetLength(CumFreq, nScoreGrps);
    SetLength(pRank, nScoreGrps);

    SetLength(GrpSize, NoGrps);
    SetLength(Means, NoGrps);
    SetLength(LowQrtl, NoGrps);
    SetLength(HiQrtl, NoGrps);
    SetLength(TenPcntile, NoGrps);
    SetLength(NinetyPcntile, NoGrps);
    SetLength(Median, NoGrps);

    // do analysis for each group
    for j := 0 to NoGrps-1 do // group
    begin
      Means[j] := 0.0;
      GrpSize[j] := 0;

      // get score groups for this group j
      for i := 0 to nScoreGrps-1 do
      begin
        CumFreq[i] := 0.0;
        Freq[i] := 0.0;
      end;
      cnt := 0;
      for i := 1 to NoCases do
      begin // get scores for this group j
        if not GoodRecord(i,NoSelected, ColNoSelected) then continue;
        G := round(StrToFloat(OS3MainFrm.DataGrid.Cells[GrpVar, i]));
        G := G - minGrp + 1;
        if G = j+1 then // subject in this group
        begin
          inc(cnt);
          X := StrToFloat(OS3MainFrm.DataGrid.Cells[MeasVar, i]);
          Means[j] := Means[j] + X;
          // find score interval and add to the frequency
          for k := 0 to nScoreGrps do
            if (X >= Scores[k]) and (X < Scores[k+1]) then
              Freq[k] := Freq[k] + 1.0;
        end;
      end;
      GrpSize[j] := cnt;
      if GrpSize[j] > 0 then Means[j] := Means[j] / GrpSize[j];

      // accumulate frequencies
      CumFreq[0] := Freq[0];
      for i := 1 to nScoreGrps-1 do
        CumFreq[i] := CumFreq[i-1] + Freq[i];
      CumFreq[nScoreGrps] := CumFreq[nScoreGrps-1];

      // get percentile ranks
      pRank[0] := ((CumFreq[0] / 2.0) / GrpSize[j]) * 100.0;
      for i := 1 to nScoreGrps-1 do
        pRank[i] := ((CumFreq[i-1] + (Freq[i] / 2.0)) / GrpSize[j]) * 100.0;

      // get centiles required.
      TenPcntile[j] := Percentile(nScoreGrps, 0.10 * GrpSize[j], Freq, CumFreq, Scores);
      NinetyPcntile[j] := Percentile(nScoreGrps, 0.90 * GrpSize[j], Freq, CumFreq, Scores);
      LowQrtl[j] := Percentile(nScoreGrps, 0.25 * GrpSize[j], Freq, CumFreq, Scores);
      Median[j] := Percentile(nScoreGrps, 0.50 * GrpSize[j], Freq, CumFreq, Scores);
      HiQrtl[j] := Percentile(nScoreGrps, 0.75 * GrpSize[j], Freq, CumFreq, Scores);

      if ShowChk.Checked then
      begin
        if j > 0 then lReport.Add('');
        lReport.Add('RESULTS FOR GROUP %d, MEAN = %.3f', [j+1, Means[j]]);
        lReport.Add('');
        lReport.Add('Centile       Value');
        lReport.Add('------------ ------');
        lReport.Add('Ten          %6.3f', [TenPcntile[j]]);
        lReport.Add('Twenty five  %6.3f', [LowQrtl[j]]);
        lReport.Add('Median       %6.3f', [Median[j]]);
        lReport.Add('Seventy five %6.3f', [HiQrtl[j]]);
        lReport.Add('Ninety       %6.3f', [NinetyPcntile[j]]);
        lReport.Add('');
        lReport.Add('Score Range     Frequency Cum.Freq. Percentile Rank');
        lReport.Add('--------------- --------- --------- ---------------');
        for i := 0 to nScoreGrps-1 do
          lReport.Add('%6.2f - %6.2f    %6.2f    %6.2f     %6.2f', [
            Scores[i], Scores[i+1], Freq[i], CumFreq[i], pRank[i]
          ]);
        lReport.Add('');
      end;
    end; // get values for next group

    // Show the report with the frequencies
    if ShowChk.Checked then
      DisplayReport(lReport);

    // Plot the boxes
    {$IFDEF USE_TACHART}
    BoxPlot(LowQrtl, HiQrtl, TenPcntile, NinetyPcntile, Median);
    {$ELSE}
    BoxPlot(NoGrps, MaxScore, MinScore, LowQrtl, HiQrtl, TenPcntile, NinetyPcntile, Means, Median);
    {$ENDIF}

  finally
    lReport.Free;

    // Clean up
    Median := nil;
    NinetyPcntile := nil;
    TenPcntile := nil;
    HiQrtl := nil;
    LowQrtl := nil;
    Means := nil;
    GrpSize := nil;
    CumFreq := nil;
    Scores := nil;
    Freq := nil;
    ColNoSelected := nil;
  end;
end;


procedure TBoxPlotFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;


procedure TBoxPlotFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;


procedure TBoxPlotFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;


function TBoxPlotFrm.Percentile(nScoreGrps: integer;
  APercentile: double; const Freq, CumFreq, Scores: DblDyneVec) : double;
var
  i, interval: integer;
  LLimit, ULimit, cumLower, intervalFreq: double;
begin
  interval := 0;
  for i := 0 to nScoreGrps-1 do
  begin
    if CumFreq[i] > APercentile then
    begin
      interval := i;
      Break;
    end;
  end;

  if interval > 0 then
  begin
    LLimit := Scores[interval];
    ULimit := Scores[interval+1];
    cumLower := CumFreq[interval-1];
    intervalFreq := Freq[interval];
  end
  else
  begin // Percentile in first interval
    LLimit := Scores[0];
    ULimit := Scores[1];
    cumLower := 0.0;
    intervalFreq := Freq[0];
  end;

  if intervalFreq > 0 then
    Result := LLimit + ((APercentile - cumLower) / intervalFreq) * (ULimit- LLimit)
  else
    Result := LLimit;
end;


{$IFDEF USE_TACHART}
procedure TBoxPlotFrm.BoxPlot(const LowQrtl, HiQrtl, TenPcnt, NinetyPcnt, Medians: DblDyneVec);
var
  i: Integer;
  ser: TBoxAndWhiskerSeries;
  clr: TColor;
  nBars: Integer;
begin
  nBars := Length(LowQrtl);
  if (nBars <> Length(HiQrtl)) or (nBars <> Length(TenPcnt)) or
     (nBars <> Length(NinetyPcnt)) or (nBars <> Length(Medians)) then
  begin
    ErrorMsg('Box-Plot: all data arrays must have the same lengths.');
    exit;
  end;

  if ChartForm = nil then
    ChartForm := TChartForm.Create(Application)
  else
    ChartForm.Clear;

  // Titles
  ChartForm.SetTitle('Box-and-Whisker Plot for ' + OS3MainFrm.FileNameEdit.Text);
  ChartForm.SetFooter('BLACK: median, BOX: 25th to 75th percentile, WHISKERS: 10th and 90th percentile');
  ChartForm.SetXTitle(GroupEdit.Text);
  ChartForm.SetYTitle(MeasEdit.Text);

  ser := TBoxAndWhiskerSeries.create(ChartForm);
  for i := 0 to nBars-1 do
  begin
    clr := BOX_COLORS[i mod Length(BOX_COLORS)];
    ser.AddXY(i+1, TenPcnt[i], LowQrtl[i], Medians[i], HiQrtl[i], NinetyPcnt[i], '', clr);
  end;
  ChartForm.ChartFrame.Chart.BottomAxis.Marks.Source := ser.ListSource;
  ChartForm.ChartFrame.Chart.BottomAxis.Marks.Style := smsXValue;
  ChartForm.ChartFrame.Chart.AddSeries(ser);

  ChartForm.Show;
end;
{$ELSE}
procedure TBoxPlotFrm.BoxPlot(NBars: integer; AMax, AMin: double;
  const LowQrtl, HiQrtl, TenPcnt, NinetyPcnt, Means, Median: DblDyneVec);
var
  i, HTickSpace, imagewide, imagehi, vtop, vbottom, offset: integer;
  vhi, hleft, hright, hwide, barwidth, Xpos, Ypos, strhi: integer;
  XOffset, YOffset: integer;
  X, Y: integer;
  X1, X2, X3, X9, X10: integer; // X coordinates for box and lines
  Y1, Y2, Y3, Y4, Y9: integer; // Y coordinates for box and lines
  Title: string;
  valincr, Yvalue: double;
begin
  if BlankFrm = nil then Application.CreateForm(TBlankFrm, BlankFrm);
  BlankFrm.Show;

  imagewide := BlankFrm.Image1.width;
  imagehi := BlankFrm.Image1.Height;
  XOffset := imagewide div 10;
  YOffset := imagehi div 10;

  vtop := YOffset;
  vbottom := imagehi - YOffset;
  vhi := vbottom - vtop;
  hleft := XOffset;
  hright := imagewide - hleft - XOffset;
  hwide := hright - hleft;
  HTickSpace := hwide div nbars;
  barwidth := HTickSpace div 2;

  // Show title
  Title := 'BOXPLOT FOR : ' + OS3MainFrm.FileNameEdit.Text;
  BlankFrm.Caption := Title;
(*
  // show legend
  Y := BlankFrm.Image1.Canvas.TextHeight(Title) * 2;
  Y := Y + vtop;
  Title := 'RED: mean, BLACK: median, BOX: 25th to 75th percentile, WISKERS: 10th and 90th percentile';
  X := imagewide div 2 - BlankFrm.Canvas.TextWidth(Title) div 2;
  BlankFrm.Image1.Canvas.TextOut(X,Y,Title);
  *)

  // Draw chart background and border
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Rectangle(0,0,imagewide,imagehi);

  // show legend
  Y := 2;
  Title := 'RED: mean, BLACK: median, BOX: 25th to 75th percentile, WISKERS: 10th and 90th percentile';
  X := imagewide div 2 - BlankFrm.Canvas.TextWidth(Title) div 2;
  BlankFrm.Image1.Canvas.TextOut(X,Y,Title);

  // Draw vertical axis
  valincr := (AMax - AMin) / 20.0;
  for i := 1 to 21 do
  begin
    Title := format('%8.2f',[AMax - ((i-1)*valincr)]);
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    xpos := XOffset;
    Yvalue := AMax - (valincr * (i-1));
    ypos := round(vhi * ( (AMax - Yvalue) / (AMax - AMin)));
    ypos := ypos + vtop - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
  end;
  BlankFrm.Image1.Canvas.MoveTo(hleft,vtop);
  BlankFrm.Image1.Canvas.LineTo(hleft,vbottom);

  // draw horizontal axis
  BlankFrm.Image1.Canvas.MoveTo(hleft,vbottom + 10 );
  BlankFrm.Image1.Canvas.LineTo(hright,vbottom + 10);
  for i := 1 to nbars do
  begin
    ypos := vbottom + 10;
    xpos := round((hwide / nbars)* i + hleft);
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    ypos := ypos + 10;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
    Title := format('%d',[i]);
    offset := BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    xpos := xpos - offset;
    ypos := ypos + strhi - 2;
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
    xpos := 20;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,'GROUPS:');
  end;

  for i := 0 to NBars - 1 do
  begin
    BlankFrm.Image1.Canvas.Brush.Color := BOX_COLORS[i mod Length(BOX_COLORS)];

    // plot the box front face
    X9 := round(hleft + ((i+1) * HTickSpace) - (barwidth / 2));
    X10 := X9 + barwidth;
    X1 := X9;
    X2 := X10;
    Y1 := round((((AMax - HiQrtl[i]) / (AMax - AMin)) * vhi) + vtop);
    Y2 := round((((AMax - LowQrtl[i]) / (AMax - AMin)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.Rectangle(X1,Y1,X2,Y2);

    // draw upper 90th percentile line and end
    X3 := round(X1 + barwidth / 2);
    BlankFrm.Image1.Canvas.MoveTo(X3,Y1);
    Y3 := round((((AMax - NinetyPcnt[i]) / (AMax - AMin)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.LineTo(X3,Y3);
    BlankFrm.Image1.Canvas.MoveTo(X1,Y3);
    BlankFrm.Image1.Canvas.LineTo(X2,Y3);

    // draw lower 10th percentile line and end
    BlankFrm.Image1.Canvas.MoveTo(X3,Y2);
    Y4 := round((((AMax - TenPcnt[i]) / (AMax - AMin)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.LineTo(X3,Y4);
    BlankFrm.Image1.Canvas.MoveTo(X1,Y4);
    BlankFrm.Image1.Canvas.LineTo(X2,Y4);

    //plot the means line
    BlankFrm.Image1.Canvas.Pen.Color := clRed;
    BlankFrm.Image1.Canvas.Pen.Style := psDot;
    Y9 := round((((AMax - Means[i]) / (AMax - AMin)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.MoveTo(X9,Y9);
    BlankFrm.Image1.Canvas.LineTo(X10,Y9);
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    BlankFrm.Image1.Canvas.Pen.Style := psSolid;

    //plot the median line
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    Y9 := round((((AMax - Median[i]) / (AMax - AMin)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.MoveTo(X9,Y9);
    BlankFrm.Image1.Canvas.LineTo(X10,Y9);
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  end;
end;
{$ENDIF}


end.

