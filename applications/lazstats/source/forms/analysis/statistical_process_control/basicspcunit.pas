unit BasicSPCUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Buttons, PrintersDlgs,
  Globals, MainUnit, ContextHelpUnit, ChartFrameUnit;

type

  { TBasicSPCForm }

  TBasicSPCForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    GroupEdit: TEdit;
    HelpBtn: TButton;
    GroupLabel: TLabel;
    MeasLabel: TLabel;
    MeasEdit: TEdit;
    PrintDialog: TPrintDialog;
    ReportMemo: TMemo;
    PageControl: TPageControl;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    SaveDialog: TSaveDialog;
    SpecsPanel: TPanel;
    ButtonPanel: TPanel;
    SpecsSplitter: TSplitter;
    ReportPage: TTabSheet;
    ChartPage: TTabSheet;
    MeasInBtn: TSpeedButton;
    MeasOutBtn: TSpeedButton;
    GroupInBtn: TSpeedButton;
    GroupOutBtn: TSpeedButton;
    tbPrintChart: TToolButton;
    tbPrintReport: TToolButton;
    tbSaveChart: TToolButton;
    tbSaveReport: TToolButton;
    ChartToolBar: TToolBar;
    ReportToolBar: TToolBar;
    tbCopyReport: TToolButton;
    tbCopyChart: TToolButton;
    VarList: TListBox;
    VarListLabel: TLabel;
    procedure CloseBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GroupInBtnClick(Sender: TObject);
    procedure GroupOutBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure MeasInBtnClick(Sender: TObject);
    procedure MeasOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure tbCopyChartClick(Sender: TObject);
    procedure tbCopyReportClick(Sender: TObject);
    procedure tbPrintChartClick(Sender: TObject);
    procedure tbPrintReportClick(Sender: TObject);
    procedure tbSaveChartClick(Sender: TObject);
    procedure tbSaveReportClick(Sender: TObject);
    procedure VarListClick(Sender: TObject);
  private
    FNoGroupsAllowed: Boolean;

  protected
    FPrintY: Integer;
    GrpVar: Integer;
    MeasVar: Integer;
    procedure Compute; virtual;
    function GetGroups: StrDyneVec;
    function GetFileName: String;
    procedure PlotMeans(ATitle, AXTitle, AYTitle, ADataTitle, AGrandMeanTitle: String;
      const Groups: StrDyneVec; const Means: DblDyneVec;
      UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double); virtual;
    procedure PrintText; virtual;
    procedure Reset; virtual;
    procedure UpdateBtnStates; virtual;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean; virtual;

  public
    FChartFrame: TChartFrame;
    property NoGroupsAllowed: Boolean read FNoGroupsAllowed write FNoGroupsAllowed;

  end;

var
  BasicSPCForm: TBasicSPCForm;


implementation

{$R *.lfm}

uses
  Math,
  Printers, OSPrinters,
  TAChartUtils, TALegend, TAChartAxisUtils, TASources, TACustomSeries, TASeries,
  Utils, DataProcs;

const
  LEFT_MARGIN = 200;
  RIGHT_MARGIN = 200;
  TOP_MARGIN = 150;
  BOTTOM_MARGIN = 200;

  FORMAT_MASK = '0.000';


{ TBasicSPCForm }

procedure TBasicSPCForm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;


// To be overridden by descendant forms
procedure TBasicSPCForm.Compute;
begin
  //
end;


procedure TBasicSPCForm.ComputeBtnClick(Sender: TObject);
var
  msg: String;
  C: TWinControl;
  i: Integer;
  cellString: String;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  GrpVar := -1;
  MeasVar := -1;
  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i, 0];
    if GroupEdit.Visible and (cellstring = GroupEdit.Text) then GrpVar := i;
    if MeasEdit.Visible and (cellstring = MeasEdit.Text) then MeasVar := i;
  end;
  if not NoGroupsAllowed and GroupEdit.Visible and (GrpVar = -1) then
  begin
    GroupEdit.SetFocus;
    ErrorMsg('Group variable not found.');
    exit;
  end;
  if MeasEdit.Visible and (MeasVar = -1) then
  begin
    MeasEdit.SetFocus;
    ErrorMsg('Measurement variable not found.');
    exit;
  end;

  Compute;

  UpdateBtnStates;
end;

procedure TBasicSPCForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  SpecsPanel.Constraints.MinWidth := Max(
    VarListLabel.Left + VarListLabel.Width + Varlist.BorderSpacing.Right * 2 + MeasInBtn.Width + MeasLabel.Width,
    CloseBtn.Left + CloseBtn.Width - HelpBtn.Left + HelpBtn.BorderSpacing.Around
  );
  Constraints.MinHeight := MeasEdit.Top + MeasEdit.Height + MeasEdit.BorderSpacing.Bottom + ButtonPanel.Height;
end;


procedure TBasicSPCForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  FChartFrame := TChartFrame.Create(self);
  FChartFrame.Parent := ChartPage;
  FChartFrame.Align := alClient;
  FChartFrame.BorderSpacing.Around := Scale96ToFont(8);
  FChartFrame.Chart.Legend.SymbolWidth := Scale96ToFont(30);
  FChartFrame.Chart.Legend.Alignment := laBottomCenter;
  FChartFrame.Chart.Legend.ColumnCount := 3;
  FChartFrame.Chart.Title.TextFormat := tfHtml;
  with FChartFrame.Chart.AxisList.Add do
  begin
    Alignment := calRight;
    Marks.Source := TListChartSource.Create(self);
    Marks.Style := smsLabel;
  end;
end;


procedure TBasicSPCForm.FormShow(Sender: TObject);
begin
  Reset;
end;


function TBasicSPCForm.GetGroups: StrDyneVec;
var
  numGrps: Integer = 0;
  ColNoSelected: IntDyneVec = nil;
  grp: String;
  i: Integer;
begin
  SetLength(ColNoSelected, 2);
  ColNoSelected[0] := GrpVar;
  ColNoSelected[1] := MeasVar;
  SetLength(Result, NoCases);
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then
      continue;
    grp := Trim(OS3MainFrm.DataGrid.Cells[GrpVar, i]);
    if IndexOfString(Result, grp) = -1 then
    begin
      Result[numGrps] := grp;
      inc(numGrps);
    end;
  end;
  SetLength(Result, numGrps);
end;


function TBasicSPCForm.GetFileName: String;
begin
  Result := ExtractFileName(OS3MainFrm.FileNameEdit.Text);
end;


procedure TBasicSPCForm.GroupInBtnClick(Sender: TObject);
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


procedure TBasicSPCForm.GroupOutBtnClick(Sender: TObject);
begin
  if GroupEdit.Text <> '' then
  begin
    VarList.Items.Add(GroupEdit.Text);
    GroupEdit.Text := '';
    UpdateBtnStates;
  end;
end;


procedure TBasicSPCForm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;


procedure TBasicSPCForm.MeasInBtnClick(Sender: TObject);
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


procedure TBasicSPCForm.MeasOutBtnClick(Sender: TObject);
begin
  if MeasEdit.Text <> '' then
  begin
    VarList.Items.Add(MeasEdit.Text);
    MeasEdit.Text := '';
    UpdateBtnStates;
  end;
end;


procedure TBasicSPCForm.PlotMeans(ATitle, AXTitle, AYTitle, ADataTitle, AGrandMeanTitle: String;
  const Groups: StrDyneVec; const Means: DblDyneVec;
  UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double);
const
  TARGET_COLOR = clBlue;
  CL_COLOR = clRed;
  SPEC_COLOR = clGreen;
  CL_STYLE = psDash;
  SPEC_STYLE = psSolid;
var
  ser: TChartSeries;
  constLine: TConstantLine;
  rightLabels: TListChartSource;
  s: String;
begin
  rightLabels := FChartFrame.Chart.AxisList[2].Marks.Source as TListChartSource;
  rightLabels.Clear;

  FChartFrame.Clear;
  FChartFrame.SetTitle(ATitle);
  FChartFrame.SetXTitle(AXTitle);
  FChartFrame.SetYTitle(AYTitle);

  ser := FChartFrame.PlotXY(ptSymbols, nil, Means, Groups, nil, ADataTitle, clBlack);
  if Length(Groups) > 0 then
  begin
    FChartFrame.Chart.BottomAxis.Marks.Source := ser.Source;
    FChartFrame.Chart.BottomAxis.Marks.style := smsLabel;
  end;

  if not IsNaN(GrandMean) then
  begin
    FChartFrame.HorLine(GrandMean, clRed, psSolid, AGrandMeanTitle);
    rightLabels.Add(GrandMean, GrandMean, AGrandMeanTitle + '=' + FormatFloat(FORMAT_MASK, GrandMean));
  end;

  if not IsNaN(UCL) then
  begin
    FChartFrame.HorLine(UCL, CL_COLOR, CL_STYLE, 'UCL/LCL');
    rightLabels.Add(UCL, UCL, 'UCL=' + FormatFloat(FORMAT_MASK, UCL));
  end;

  if not IsNaN(LCL) then
  begin
    FChartFrame.HorLine(LCL, CL_COLOR, CL_STYLE, '');
    rightLabels.Add(UCL, LCL, 'LCL=' + FormatFloat(FORMAT_MASK, LCL));
  end;

  if not IsNan(UpperSpec) then
  begin
    if IsNaN(LowerSpec) then
      s := 'Upper Spec'
    else
      s := 'Upper/Lower Spec';
    FChartFrame.HorLine(UpperSpec, SPEC_COLOR, SPEC_STYLE, s);
    rightLabels.Add(UpperSpec, UpperSpec, 'USL=' + FormatFloat(FORMAT_MASK, UpperSpec));
  end;

  if not IsNaN(TargetSpec) then begin
    FChartFrame.HorLine(TargetSpec, TARGET_COLOR, psSolid, 'Target');
    rightLabels.Add(TargetSpec, TargetSpec, 'Target=' + FormatFloat(FORMAT_MASK, TargetSpec));
  end;

  if not IsNaN(LowerSpec) then
  begin
    if IsNaN(UpperSpec) then
      s := 'Lower Spec'
    else
      s := 'Upper/Lower Spec';
    constLine := FChartFrame.HorLine(LowerSpec, SPEC_COLOR, SPEC_STYLE, s);
    constLine.Legend.Visible := IsNaN(UpperSpec);
    rightLabels.Add(LowerSpec, LowerSpec, 'LSL=' + FormatFloat(FORMAT_MASK, LowerSpec));
  end;

  FChartFrame.Chart.Legend.Visible := false;
end;


procedure TBasicSPCForm.PrintText;
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
      on E: Exception do showMessage('Unexpected error when printing.');
    end;
  end;
end;

procedure TBasicSPCForm.Reset;
var
  i : integer;
begin
  VarList.Clear;
  GroupEdit.Text := '';
  MeasEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  FChartFrame.Clear;
  (FChartFrame.Chart.AxisList[2].Marks.Source as TListChartSource).Clear;
  UpdateBtnStates;
end;


procedure TBasicSPCForm.ResetBtnClick(Sender: TObject);
begin
  Reset;
end;


procedure TBasicSPCForm.tbCopyChartClick(Sender: TObject);
begin
  FChartFrame.Chart.CopyToClipboardBitmap;
end;


procedure TBasicSPCForm.tbCopyReportClick(Sender: TObject);
begin
  with ReportMemo do
  begin
    SelectAll;
    CopyToClipboard;
    SelLength := 0;
  end;
end;


procedure TBasicSPCForm.tbPrintChartClick(Sender: TObject);
begin
  FChartFrame.Print;
end;


procedure TBasicSPCForm.tbPrintReportClick(Sender: TObject);
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


procedure TBasicSPCForm.tbSaveChartClick(Sender: TObject);
begin
  FChartFrame.Save;
end;


procedure TBasicSPCForm.tbSaveReportClick(Sender: TObject);
begin
  SaveDialog.Filter := 'LazStats text files (*.txt)|*.txt;*.TXT|All files (*.*)|*.*';
  SaveDialog.FilterIndex := 1; {text file}
  SaveDialog.Title := 'Save to File';
  if SaveDialog.Execute then
    ReportMemo.Lines.SaveToFile(SaveDialog.FileName);
end;


procedure TBasicSPCForm.UpdateBtnStates;
begin
  MeasInBtn.Enabled := (VarList.ItemIndex <> -1) and (MeasEdit.Text = '');
  MeasOutBtn.Enabled := (MeasEdit.Text <> '');
  GroupInBtn.Enabled := (VarList.ItemIndex <> -1) and (GroupEdit.Text = '');
  GroupOutBtn.Enabled := (GroupEdit.Text <> '');

  tbSaveReport.Enabled := ReportMemo.Lines.Count > 0;
  tbPrintReport.Enabled := ReportMemo.Lines.Count > 0;
  tbCopyReport.Enabled := ReportMemo.Lines.Count > 0;

  tbSaveChart.Enabled :=  FChartFrame.Chart.SeriesCount > 0;
  tbPrintChart.Enabled :=  FChartFrame.Chart.SeriesCount > 0;
  tbCopyChart.Enabled :=  FChartFrame.Chart.SeriesCount > 0;
end;


function TBasicSPCForm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
   x: Double;
begin
  Result := false;
  if GroupEdit.Visible and (GroupEdit.Text = '') then begin
    AMsg := 'Group variable not specified.';
    AControl := GroupEdit;
    exit;
  end;
  if MeasEdit.Visible and (MeasEdit.Text = '') then
  begin
    AMsg := 'Measurement variable not specified.';
    AControl := MeasEdit;
    exit;
  end;
  Result := true;
end;


procedure TBasicSPCForm.VarListClick(Sender: TObject);
//var
//  index: integer;
begin
  UpdateBtnStates;
  {
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    if GroupEdit.Visible and (GroupEdit.Text = '') then
      GroupEdit.Text := VarList.Items[index]
    else
      MeasEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  }
end;

end.

