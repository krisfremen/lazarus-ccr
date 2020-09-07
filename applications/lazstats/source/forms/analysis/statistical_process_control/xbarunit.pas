// Use file "boltsize.laz" for testing
//   Group Variable --> LotNo
//   Selected Variable --> BoltLength
//   Upper Spec Level --> 20.05
//   Lower Spec Level --> 19.95
//   Target Spec      --> 20.00

unit XBarUnit;

{$mode objfpc}{$H+}
{$include ../../../LazStats.inc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls,
  MainUnit, Globals, ContextHelpUnit, DataProcs, GraphLib,
  {$IFDEF USE_TACHART}
  TAChartUtils, TASources, TACustomSeries, TASeries, TALegend, TAChartAxisUtils,
  ChartFrameUnit;
  {$ELSE}
  OutputUnit, BlankFrmUnit;
  {$ENDIF}

type

  { TXBarFrm }

  TXBarFrm = class(TForm)
    Bevel1: TBevel;
    ErrorBarsChk: TCheckBox;
    HelpBtn: TButton;
    ReportMemo: TMemo;
    PageControl: TPageControl;
    Panel1: TPanel;
    SpecsPanel: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    Splitter1: TSplitter;
    ReportPage: TTabSheet;
    ChartPage: TTabSheet;
    UpSpecEdit: TEdit;
    LowSpecEdit: TEdit;
    TargetSpecEdit: TEdit;
    UpSpecChk: TCheckBox;
    LowSpecChk: TCheckBox;
    TargetChk: TCheckBox;
    GroupBox1: TGroupBox;
    XSigmaEdit: TEdit;
    GroupEdit: TEdit;
    MeasEdit: TEdit;
    VarListLabel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SigmaOpts: TRadioGroup;
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
    {$IFDEF USE_TACHART}
    FChartFrame: TChartFrame;
    {$ENDIF}
//    FAutoSized: Boolean;
    procedure PlotMeans(const Groups: StrDyneVec; const Means, StdDevs: DblDyneVec;
      UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double);
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  XBarFrm: TXBarFrm;

implementation

uses
  Math,
  Utils;

{ TXBarFrm }

procedure TXBarFrm.ResetBtnClick(Sender: TObject);
var
  i : integer;
begin
  VarList.Clear;
  GroupEdit.Text := '';
  MeasEdit.Text := '';
  UpSpecEdit.Text := '';
  LowSpecEdit.Text := '';
  TargetSpecEdit.Text := '';
  XSigmaEdit.Text := '';
  UpSpecChk.Checked := false;
  LowSpecChk.Checked := false;
  TargetChk.Checked := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TXBarFrm.VarListClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    if GroupEdit.Text = '' then
      GroupEdit.Text := VarList.Items[index]
    else
      MeasEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
end;

procedure TXBarFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TXBarFrm.ComputeBtnClick(Sender: TObject);
var
  i, GrpVar, MeasVar, grpIndex: integer;
  X, UCL, LCL, Sigma, UpperSpec, LowerSpec, TargetSpec: double;
  GrandMean, GrandSD, semean: double;
  grp: String;
  numGrps: Integer;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stddev: DblDyneVec = nil;
  count: IntDyneVec = nil;
  cellstring: string;
  ColNoSelected: IntDyneVec = nil;
  NoSelected: integer;
  msg: String;
  C: TWinControl;
  lReport: TStrings;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  SetLength(ColNoSelected, NoVariables);

  GrpVar := 1;
  MeasVar := 2;
  Sigma := 3.0;
  UpperSpec := 0.0;
  LowerSpec := 0.0;
  TargetSpec := 0.0;
  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if cellstring = GroupEdit.Text then GrpVar := i;
    if cellstring = MeasEdit.Text then MeasVar := i;
  end;
  ColNoSelected[0] := MeasVar;
  ColNoSelected[1] := GrpVar;
  NoSelected := 2;

  if UpSpecEdit.Text <> '' then UpperSpec := StrToFloat(UpSpecEdit.Text);
  if LowSpecEdit.Text <> '' then LowerSpec := StrToFloat(LowSpecEdit.Text);
  if TargetSpecEdit.Text <> '' then TargetSpec := StrToFloat(TargetSpecEdit.Text);

  case SigmaOpts.ItemIndex of
    0: Sigma := 3.0;
    1: Sigma := 2.0;
    2: Sigma := 1.0;
    3: Sigma := StrToFloat(XSigmaEdit.Text);
  end;

  numGrps := 0;
  SetLength(groups, NoCases);
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i, NoSelected, ColNoSelected) then continue;
    grp := Trim(OS3MainFrm.DataGrid.Cells[GrpVar, i]);
    if IndexOfString(groups, grp) = -1 then
    begin
      groups[numGrps] := grp;
      inc(numGrps);
    end;
  end;

  SetLength(groups, numGrps);
  SetLength(means, numGrps);
  SetLength(count, numGrps);
  SetLength(stddev, numGrps);
  semean := 0.0;
  GrandMean := 0.0;

  // calculate group means, grand mean, group sd's, semeans
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i, NoSelected, ColNoSelected) then continue;
    grp := Trim(OS3MainFrm.DataGrid.cells[GrpVar, i]);
    grpIndex := IndexOfString(groups, grp);
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
    means[grpIndex] := means[grpIndex] + X;
    count[grpIndex] := count[grpIndex] + 1;
    stddev[grpIndex] := stddev[grpIndex] + sqr(X);
    semean := semean + sqr(X);
    GrandMean := GrandMean + X;
  end;

  for i := 0 to numGrps-1 do
  begin
    if count[i] = 0 then
    begin
      means[i] := NaN;
      stddev[i] := NaN;
    end else
    begin
      if count[i] = 1 then
        stddev[i] := NaN
      else
      begin
        stddev[i] := stddev[i] - sqr(means[i]) / count[i];
        stddev[i] := stddev[i] / (count[i] - 1);
        stddev[i] := sqrt(stddev[i]);
      end;
      means[i] := means[i] / count[i];
    end;
  end;
  semean := semean - sqr(GrandMean) / NoCases;
  semean := sqrt(semean / (NoCases - 1));
  GrandSD := semean;
  semean := semean / sqrt(NoCases);
  GrandMean := GrandMean / NoCases;
  UCL := GrandMean + Sigma * semean;
  LCL := GrandMean - Sigma * semean;

  // printed results
  lReport := TStringList.Create;
  try
    lReport.Add('X BAR CHART RESULTS');
    lReport.Add('');
    lReport.Add('Group Size   Mean     Std.Dev.');
    lReport.Add('----- ---- --------- ----------');
    for i := 0 to numGrps-1 do
      lReport.Add('%5s %4d %9.2f %9.2f', [groups[i], count[i], means[i], stddev[i]]);
    lReport.Add('');
    lReport.Add('Grand Mean:             %8.3f', [GrandMean]);
    lReport.Add('Standard Deviation:     %8.3f', [GrandSD]);
    lReport.Add('Standard Error of Mean: %8.3f', [semean]);
    lReport.Add('');
    lReport.Add('Lower Control Limit:    %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:    %8.3f', [UCL]);

   {$IFDEF USE_TACHART}
    ReportMemo.Lines.Assign(lReport);
   {$ELSE}
    DisplayReport(lReport);
   {$ENDIF}
  finally
    lReport.Free;
  end;

  // show graph
 {$IFNDEF USE_TACHART}
  BlankFrm.Image1.Canvas.Clear;
  BlankFrm.Show;
 {$ENDIF}
  if not ErrorBarsChk.Checked then stddev := nil;
  PlotMeans(groups, means, stddev, UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec);

  // Clean up
  stddev := nil;
  count := nil;
  means := nil;
  groups := nil;
  ColNoSelected := nil;
end;

procedure TXBarFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  {
  if FAutoSized then
    exit;
  }
  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinWidth := VarListLabel.Width;
  SpecsPanel.Constraints.MinWidth := VarListLabel.Left + VarListLabel.Width + VarList.BorderSpacing.Right + GroupBox1.Width;
//  VarList.Constraints.MinHeight := GroupBox1.Top + GroupBox1.Height - VarList.Top;
//  SpecsPanel.Constraints.MinWidth := SpecsPanel.Width;
//  PageControl.Constraints.MinWidth := SpecsPanel.Width ;

  //AutoSize := false;
  Constraints.MinHeight := GroupBox1.Top + GroupBox1.Height + Bevel1.Height + CloseBtn.Height + CloseBtn.BorderSpacing.Top * 2; //  Height;
  //Constraints.MinWidth := Width;

 // FAutoSized := true;
end;

procedure TXBarFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
 {$IFDEF USE_TACHART}
  FChartFrame := TChartFrame.Create(self);
  FChartFrame.Parent := ChartPage;
  FChartFrame.Align := alClient;
  FChartFrame.BorderSpacing.Around := Scale96ToFont(8);
  FChartFrame.Chart.Legend.SymbolWidth := Scale96ToFont(30);
  FChartFrame.Chart.Legend.Alignment := laBottomCenter;
  FChartFrame.Chart.Legend.ColumnCount := 3;
  with FChartFrame.Chart.AxisList.Add do
  begin
    Alignment := calRight;
    Marks.Source := TListChartSource.Create(self);
    Marks.Style := smsLabel;
  end;
 {$ELSE}
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
 {$ENDIF}
end;

procedure TXBarFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TXBarFrm.PlotMeans(const Groups: StrDyneVec; const Means, StdDevs: DblDyneVec;
  UCL, LCL, GrandMean: double; TargetSpec, LowerSpec, UpperSpec: double);
const
  TARGET_COLOR = clBlue;
  CL_COLOR = clRed;
  SPEC_COLOR = clGreen;
  CL_STYLE = psDash;
  SPEC_STYLE = psSolid;
var
 {$IFDEF USE_TACHART}
  ser: TChartSeries;
  rightLabels: TListChartSource;
  constLine: TConstantLine;
  s: String;
 {$ELSE}
  i: Integer;
  xpos, ypos, hleft, hright, vtop, vbottom, imagewide: integer;
  maxVal, minVal: Double;
  NoGrps, vhi, hwide, offset, strhi: integer;
  imagehi, valincr, Yvalue: double;
  title: String;
 {$ENDIF}
begin
 {$IFDEF USE_TACHART}
  rightLabels := FChartFrame.Chart.AxisList[2].Marks.Source as TListChartSource;

  FChartFrame.Clear;
  FChartFrame.SetTitle('XBAR chart for ' + OS3MainFrm.FileNameEdit.Text, taLeftJustify);
  FChartFrame.SetXTitle(GroupEdit.Text);
  FChartFrame.SetYTitle(MeasEdit.Text);

  ser := FChartFrame.PlotXY(ptSymbols, nil, Means, Groups, StdDevs, 'Group means', clBlack);
  FChartFrame.Chart.BottomAxis.Marks.Source := ser.Source;
  FChartFrame.Chart.BottomAxis.Marks.style := smsLabel;

  FChartFrame.HorLine(GrandMean, clRed, psSolid, 'Grand mean');
  rightLabels.Add(GrandMean, GrandMean, 'Grand mean');

  FChartFrame.HorLine(UCL, CL_COLOR, CL_STYLE, 'UCL/LCL');
  rightLabels.Add(UCL, UCL, 'UCL');

  FChartFrame.HorLine(LCL, CL_COLOR, CL_STYLE, '');
  rightLabels.Add(UCL, LCL, 'LCL');

  if UpSpecChk.Checked then
  begin
    if LowSpecChk.Checked then
      s := 'Upper/Lower Spec'
    else
      s := 'Upper Spec';
    FChartFrame.HorLine(UpperSpec, SPEC_COLOR, SPEC_STYLE, s);
    rightLabels.Add(UpperSpec, UpperSpec, 'Upper Spec');
  end;

  if TargetChk.Checked then begin
    FChartFrame.HorLine(TargetSpec, TARGET_COLOR, psSolid, 'Target');
    rightLabels.Add(TargetSpec, TargetSpec, 'Target');
  end;

  if LowSpecChk.Checked then
  begin
    if UpSpecChk.Checked then
      s := 'Upper/Lower Spec'
    else
      s := 'Lower Spec';
    constLine := FChartFrame.HorLine(LowerSpec, SPEC_COLOR, SPEC_STYLE, s);
    constLine.Legend.Visible := not UpSpecChk.Checked;
    rightLabels.Add(LowerSpec, LowerSpec, 'Lower Spec');
  end;
 {$ELSE}
  NoGrps := Length(groups);
  maxval := -Infinity;
  minval := Infinity;
  for i := 0 to NoGrps-1 do
  begin
    if means[i] > maxval then maxval := means[i];
    if means[i] < minval then minval := means[i];
  end;
  if UCL > maxval then maxval := UCL;
  if LCL < minval then minval := LCL;
  if UpSpecChk.Checked and (UpperSpec > maxval) then maxval := UpperSpec;
  if LowSpecChk.Checked and (LowerSpec < minval) then minval := LowerSpec;
  if TargetChk.Checked then
  begin
    if TargetSpec > maxval then maxval := TargetSpec;
    if TargetSpec < minval then minval := TargetSpec;
  end;

  BlankFrm.Caption := 'XBAR CHART FOR ' + OS3MainFrm.FileNameEdit.Text;
  imagewide := BlankFrm.Image1.Width;
  imagehi := BlankFrm.Image1.Height;
  vtop := 20;
  vbottom := round(imagehi) - 80;
  vhi := vbottom - vtop;
  hleft := 100;
  hright := imagewide - 100;
  hwide := hright - hleft;

  // Draw outer background
  BlankFrm.Image1.Canvas.Brush.Color := clLtGray;
  BlankFrm.Image1.Canvas.FillRect(0, 0, BlankFrm.Image1.Width, BlankFrm.Image1.Height);

  // Draw chart border and inner background
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Rectangle(hleft,vtop-10,hleft+hwide,vtop+vhi+10);

  // Draw Grand Mean
  xpos := hright + 10;
  ypos := round(vhi * ( (maxval - GrandMean) / (maxval - minval)));
  ypos := ypos + vtop;
  BlankFrm.Image1.Canvas.Pen.Color := clRed;
  BlankFrm.Image1.Canvas.Line(hLeft, ypos, hright, ypos);
  title := 'MEAN';
  strhi := BlankFrm.Image1.Canvas.TextHeight(title);
  BlankFrm.Image1.Canvas.Brush.Style := bsClear;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos - strhi div 2, title);

  // draw horizontal axis
  //BlankFrm.Image1.Canvas.Line(hleft, vbottom + 20, hright, vbottom + 20);
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  for i := 1 to NoGrps do
  begin
    ypos := vbottom + 10;
    xpos := round(hwide / NoGrps * i + hleft);
    BlankFrm.Image1.Canvas.Line(xpos, ypos, xpos, ypos + 10);
    title := Format('%d', [i]);
    offset := BlankFrm.Image1.Canvas.TextWidth(title) div 2;
    strhi := BlankFrm.Image1.Canvas.TextHeight(title);
    xpos := xpos - offset;
    ypos := ypos + strhi;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, title);
    xpos := 10;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, 'GROUPS');
  end;

  // Draw vertical axis
  valincr := (maxval - minval) / 10.0;
  for i := 1 to 11 do
  begin
    title := Format('%.2f', [maxval - (i - 1) * valincr]);
    strhi := BlankFrm.Image1.Canvas.TextHeight(title);
    Yvalue := maxval - valincr * (i - 1);
    ypos := vtop + round(vhi * (maxval - Yvalue) / (maxval - minval));
    BlankFrm.Image1.Canvas.Line(hleft, ypos, hleft-10, ypos);
    xpos := hleft - 20 - BlankFrm.Image1.Canvas.TextWidth(title);;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos - strhi div 2, title);
  end;

  // draw lines for means of the groups
  ypos := round(vhi * (maxval - means[0]) / (maxval - minval));
  ypos := ypos + vtop;
  xpos := round(hwide/NoGrps + hleft);
  BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  for i := 2 to NoGrps do
  begin
    ypos := round(vhi * (maxval - means[i-1]) / (maxval - minval));
    ypos := ypos + vtop;
    xpos := round(hwide/NoGrps* i + hleft);
    BlankFrm.Image1.Canvas.LineTo(xpos, ypos);
  end;

  // Draw upper and lower confidence intervals
  xpos := hright + 10;
  ypos := round(vhi * (maxval - UCL) / (maxval - minval));
  ypos := ypos + vtop;
  BlankFrm.Image1.Canvas.Pen.Style := CL_STYLE;
  BlankFrm.Image1.Canvas.Pen.Color := CL_COLOR;
  BlankFrm.Image1.Canvas.Line(hleft, ypos, hright, ypos);
  title := 'UCL';
  strhi := BlankFrm.Image1.Canvas.TextHeight(title);
  ypos := ypos - strhi div 2;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos, title);

  ypos := round(vhi * ( (maxval - LCL) / (maxval - minval)));
  ypos := ypos + vtop;
  BlankFrm.Image1.Canvas.Pen.Color := CL_COLOR;
  BlankFrm.Image1.Canvas.Line(hleft, ypos, hright, ypos);
  title := 'LCL';
  strhi := BlankFrm.Image1.Canvas.TextHeight(title);
  ypos := ypos - strhi div 2;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos, title);

  // Draw lines for specified values
  if UpSpecChk.Checked then
  begin
    ypos := round(vhi * (maxval - UpperSpec) / (maxval - minval));
    ypos := ypos + vtop;
    BlankFrm.Image1.Canvas.Pen.Color := SPEC_COLOR;
    BlankFrm.Image1.Canvas.Pen.Style := SPEC_STYLE;
    BlankFrm.Image1.Canvas.Line(hleft, ypos, hright, ypos);
    title := 'UPPER SPEC';
    strhi := BlankFrm.Image1.Canvas.TextHeight(title);
    ypos := ypos - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, title);
  end;
  if LowSpecChk.Checked then
  begin
    ypos := round(vhi * (maxval - LowerSpec) / (maxval - minval));
    ypos := ypos + vtop;
    BlankFrm.Image1.Canvas.Pen.Color := SPEC_COLOR;
    BlankFrm.Image1.Canvas.Line(hleft, ypos, hright, ypos);
    title := 'LOWER SPEC';
    strhi := BlankFrm.Image1.Canvas.TextHeight(title);
    ypos := ypos - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, title);
  end;
  if TargetChk.Checked then
  begin
    ypos := round(vhi * (maxval - TargetSpec) / (maxval - minval));
    ypos := ypos + vtop;
    BlankFrm.Image1.Canvas.Pen.Color := TARGET_COLOR;
    BlankFrm.Image1.Canvas.Line(hleft, ypos, hright, ypos);
    title := 'TARGET';
    strhi := BlankFrm.Image1.Canvas.TextHeight(title);
    ypos := ypos - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, title);
  end;
 {$ENDIF}
end;

function TXBarFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
   x: Double;
begin
  Result := false;
  if GroupEdit.Text = '' then begin
    AMsg := 'Group variable not specified.';
    AControl := GroupEdit;
    exit;
  end;
  if MeasEdit.Text = '' then
  begin
    AMsg := 'Measurement variable not specified.';
    AControl := MeasEdit;
    exit;
  end;
  if SigmaOpts.ItemIndex = -1 then
  begin
    AMsg := 'Number of sigma units for UCL and LCL not specified.';
    AControl := SigmaOpts;
    exit;
  end;
  if SigmaOpts.ItemIndex = 3 then
  begin
    if (XSigmaEdit.Text = '') then
    begin
      AMsg := 'User-defined sigma units missing.';
      AControl := XSigmaEdit;
      exit;
    end;
    if not TryStrToFloat(XSigmaEdit.Text, x) then
    begin
      AMsg := 'No valid number given for sser-defined sigma units.';
      AControl := XSigmaEdit;
      exit;
    end;
  end;

  if UpSpecChk.Checked then begin
    if UpSpecEdit.Text = '' then
    begin
      AMsg := 'Upper Spec Level missing.';
      AControl := UpSpecEdit;
      exit;
    end;
    if not TryStrToFloat(UpSpecEdit.Text, x) then
    begin
      AMsg := 'Upper Spec Level is not a valid number.';
      AControl := UpSpecEdit;
      exit;
    end;
  end;

  if LowSpecChk.Checked then begin
    if LowSpecEdit.Text = '' then
    begin
      AMsg := 'Lower Spec Level missing.';
      AControl := LowSpecEdit;
      exit;
    end;
    if not TryStrToFloat(LowSpecEdit.Text, x) then
    begin
      AMsg := 'Lower Spec Level is not a valid number.';
      AControl := LowSpecEdit;
      exit;
    end;
  end;

  if TargetChk.Checked then begin
    if TargetSpecEdit.Text = '' then
    begin
      AMsg := 'Target Spec Level missing.';
      AControl := TargetSpecEdit;
      exit;
    end;
    if not TryStrToFloat(TargetSpecEdit.Text, x) then
    begin
      AMsg := 'Target Spec Level is not a valid number.';
      AControl := TargetSpecEdit;
      exit;
    end;
  end;

  Result := true;
end;

initialization
  {$I xbarunit.lrs}

end.

