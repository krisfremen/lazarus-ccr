// Use file "anova2.laz" for testing

unit BoxPlotUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Printers, ComCtrls, Buttons,
  MainUnit, Globals, DataProcs, ContextHelpUnit, ReportFrameUnit, ChartFrameUnit;


type

  { TBoxPlotFrm }

  TBoxPlotFrm = class(TForm)
    Bevel2: TBevel;
    HelpBtn: TButton;
    PageControl1: TPageControl;
    ParamsPanel: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    MeasEdit: TEdit;
    GroupEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ParamsSplitter: TSplitter;
    ReportPage: TTabSheet;
    ChartPage: TTabSheet;
    VarList: TListBox;
    GrpInBtn: TBitBtn;
    GrpOutBtn: TBitBtn;
    MeasInBtn: TBitBtn;
    MeasOutBtn: TBitBtn;
    procedure CloseBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GrpOutBtnClick(Sender: TObject);
    procedure GrpInBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure MeasInBtnClick(Sender: TObject);
    procedure MeasOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListDblClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: Boolean;
    FReportFrame: TReportFrame;
    FChartFrame: TChartFrame;
    procedure BoxPlot(const LowQrtl, HiQrtl, TenPcnt, NinetyPcnt, Medians: DblDyneVec);
    function Percentile(nScoreGrps: integer; APercentile: Double;
      const Freq, CumFreq, Scores: DblDyneVec): double;
    procedure UpdateBtnStates;

  public
    { public declarations }
    procedure Reset;
  end; 

var
  BoxPlotFrm: TBoxPlotFrm;

implementation

{$R *.lfm}

uses
  TAChartUtils, TALegend, TAMultiSeries,
  Math, Utils;

const
  BOX_COLORS: Array[0..3] of TColor = (clBlue, clGreen, clFuchsia, clLime);


{ TBoxPlotFrm }

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

  FChartFrame.Clear;

  // Titles
  FChartFrame.SetTitle('Box-and-Whisker Plot for ' + OS3MainFrm.FileNameEdit.Text);
  FChartFrame.SetFooter('BLACK: median, BOX: 25th to 75th percentile, WHISKERS: 10th and 90th percentile');
  FChartFrame.SetXTitle(GroupEdit.Text);
  FChartFrame.SetYTitle(MeasEdit.Text);

  ser := TBoxAndWhiskerSeries.create(FChartFrame);
  for i := 0 to nBars-1 do
  begin
    clr := BOX_COLORS[i mod Length(BOX_COLORS)];
    ser.AddXY(i+1, TenPcnt[i], LowQrtl[i], Medians[i], HiQrtl[i], NinetyPcnt[i], '', clr);
  end;
  FChartFrame.Chart.BottomAxis.Marks.Source := ser.ListSource;
  FChartFrame.Chart.BottomAxis.Marks.Style := smsXValue;
  FChartFrame.Chart.AddSeries(ser);

  FChartFrame.UpdateBtnStates;
end;


procedure TBoxPlotFrm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;


procedure TBoxPlotFrm.ComputeBtnClick(Sender: TObject);
var
  lReport: TStrings;
  i, j, k, GrpVar, MeasVar, mingrp, maxgrp, G, NoGrps, cnt: integer;
  nScoreGrps, numValues: integer;
  X: Double;
  MinScore, MaxScore, IntervalSize, lastX: double;
  cellstring: string;
  done: boolean;
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
  ColNoSelected: IntDyneVec;
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

    SetLength(ColNoSelected, 2);
    ColNoSelected[0] := GrpVar;
    ColNoSelected[1] := MeasVar;

    // get minimum and maximum group values
    minGrp := MaxInt;
    maxGrp := -MaxInt;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
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
    numValues := 0;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
      inc(numValues);
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

    SetLength(Scores, 2*numValues + 1);  // over-dimensioned, will be trimmed later.

    //  check for excess no. of intervals and reset if needed
    nScoreGrps := round((MaxScore - MinScore) / IntervalSize);
    if nScoreGrps > 2 * numValues then
      Intervalsize := (MaxScore - MinScore) / numValues;

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
        if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
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
      if GrpSize[j] = 0 then
      begin
        Means[j] := NaN;
        Median[j] := NaN;
        Continue;
      end;

      Means[j] := Means[j] / GrpSize[j];

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

      if j > 0 then lReport.Add('');
      lReport.Add('RESULTS FOR GROUP %d, MEAN %.3f', [j+1, Means[j]]);
      lReport.Add('');
      lReport.Add('Centile        Value');
      lReport.Add('------------  -------');
      lReport.Add('Ten           %6.3f', [TenPcntile[j]]);
      lReport.Add('Twenty five   %6.3f', [LowQrtl[j]]);
      lReport.Add('Median        %6.3f', [Median[j]]);
      lReport.Add('Seventy five  %6.3f', [HiQrtl[j]]);
      lReport.Add('Ninety        %6.3f', [NinetyPcntile[j]]);
      lReport.Add('');
      lReport.Add('Score Range     Frequency Cum.Freq. Percentile Rank');
      lReport.Add('--------------- --------- --------- ---------------');
      for i := 0 to nScoreGrps-1 do
        lReport.Add('%6.2f - %6.2f    %6.2f    %6.2f     %6.2f', [
          Scores[i], Scores[i+1], Freq[i], CumFreq[i], pRank[i]
        ]);
      lReport.Add('');
    end; // get values for next group

    // Show the report with the frequencies
    FReportFrame.DisplayReport(lReport);

    // Plot the boxes
    BoxPlot(LowQrtl, HiQrtl, TenPcntile, NinetyPcntile, Median);
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

  ParamsPanel.Constraints.MinWidth := Max(
    4*w + 3*HelpBtn.BorderSpacing.Right,
    Max(Label1.Width, Label3.Width) * 2 + MeasInBtn.Width + 2 * MeasInBtn.BorderSpacing.Left
  );
  ParamsPanel.Constraints.MinHeight := VarList.Top + VarList.Constraints.MinHeight +
    Bevel2.Height + CloseBtn.Height + CloseBtn.BorderSpacing.Top;

  Constraints.MinHeight := ParamsPanel.Constraints.MinHeight + ParamsPanel.BorderSpacing.Around*2;
  Constraints.MinWidth := ParamsPanel.Constraints.MinWidth + 200;
  if Height < Constraints.MinHeight then Height := 1;  // Enforce autosizing
  if Width < Constraints.MinWidth then Width := 1;

  Position := poDesigned;
  FAutoSized := true;
end;


procedure TBoxPlotFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  FReportFrame := TReportFrame.Create(self);
  FReportFrame.Parent := ReportPage;
  FReportFrame.Align := alClient;

  FChartFrame := TChartFrame.Create(self);
  FChartFrame.Parent := ChartPage;
  FChartFrame.Align := alClient;
  FChartFrame.Chart.Legend.Alignment := laBottomCenter;
  FChartFrame.Chart.Legend.ColumnCount := 3;
  FChartFrame.Chart.Legend.TextFormat := tfHTML;
  FChartFrame.Chart.BottomAxis.Intervals.MaxLength := 80;
  FChartFrame.Chart.BottomAxis.Intervals.MinLength := 30;
  InitToolbar(FChartFrame.ChartToolbar, tpTop);

  Reset;
end;


procedure TBoxPlotFrm.GrpInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (GroupEdit.Text = '') then
  begin
    GroupEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;


procedure TBoxPlotFrm.GrpOutBtnClick(Sender: TObject);
begin
  if GroupEdit.Text <> '' then
  begin
    VarList.Items.Add(GroupEdit.Text);
    GroupEdit.Text := '';
    UpdateBtnStates;
  end;
end;


procedure TBoxPlotFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;


procedure TBoxPlotFrm.MeasInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (MeasEdit.Text = '') then
  begin
    MeasEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TBoxPlotFrm.MeasOutBtnClick(Sender: TObject);
begin
  if MeasEdit.Text <> '' then
  begin
    VarList.Items.Add(MeasEdit.Text);
    MeasEdit.Text := '';
    UpdateBtnStates;
  end;
end;


function TBoxPlotFrm.Percentile(nScoreGrps: integer;
  APercentile: double; const Freq, CumFreq, Scores: DblDyneVec): double;
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
  end else
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


procedure TBoxPlotFrm.Reset;
var
  i: integer;
begin
  VarList.Clear;
  GroupEdit.Text := '';
  MeasEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;


procedure TBoxPlotFrm.ResetBtnClick(Sender: TObject);
begin
  Reset;
end;


procedure TBoxPlotFrm.UpdateBtnStates;
begin
  MeasinBtn.Enabled := (VarList.ItemIndex > -1) and (MeasEdit.Text = '');
  MeasoutBtn.Enabled := (MeasEdit.Text <> '');

  GrpinBtn.Enabled := (VarList.ItemIndex > -1) and (GroupEdit.Text = '');
  grpoutBtn.Enabled := (GroupEdit.Text <> '');

  FReportFrame.UpdateBtnStates;
  FChartFrame.UpdateBtnStates;
end;


procedure TBoxPlotFrm.VarListDblClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    if MeasEdit.Text = '' then
      MeasEdit.Text := VarList.Items[index]
    else
      GroupEdit.Text := VarList.Items[index];
  end;
  VarList.Items.Delete(index);
  UpdateBtnStates;
end;


procedure TBoxPlotFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


end.

