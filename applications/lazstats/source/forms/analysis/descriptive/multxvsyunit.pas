// Use file "BubblePlot2.laz" for testing

unit MultXvsYUnit;

{$mode objfpc}{$H+}
{$i ../../../LazStats.inc}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Clipbrd,
  MainUnit, Globals, OutputUnit, DataProcs, DictionaryUnit, ContextHelpUnit;

type

  { TMultXvsYFrm }

  TMultXvsYFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    XInBtn: TBitBtn;
    XOutBtn: TBitBtn;
    YInBtn: TBitBtn;
    YOutBtn: TBitBtn;
    GroupInBtn: TBitBtn;
    GroupOutBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DescChk: TCheckBox;
    LinesChk: TCheckBox;
    XEdit: TEdit;
    YEdit: TEdit;
    GroupEdit: TEdit;
    GroupBox1: TGroupBox;
    LabelEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GroupInBtnClick(Sender: TObject);
    procedure GroupOutBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure XInBtnClick(Sender: TObject);
    procedure XOutBtnClick(Sender: TObject);
    procedure YInBtnClick(Sender: TObject);
    procedure YOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    {$IFDEF USE_TACHART}
    procedure PlotXY(const XValues, YValues: DblDyneMat; MinGrp: Integer);
    {$ELSE}
    procedure PlotXY(const XValues, YValues: DblDyneMat;
      MaxX, MinX, MaxY, MinY: double; N, NoY, MinGrp: integer);
    {$ENDIF}
    procedure UpdateBtnStates;

  public
    { public declarations }
    procedure Reset;
  end; 

var
  MultXvsYFrm: TMultXvsYFrm;

implementation

{$R *.lfm}

uses
  {$IFDEF USE_TACHART}
  TATypes,
  ChartFrameUnit, ChartUnit,
  {$ELSE}
  BlankFrmUnit,
  {$ENDIF}
  Math, Utils;


{ TMultXvsYFrm }

procedure TMultXvsYFrm.Reset;
var
  i : integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  XEdit.Text := '';
  YEdit.Text := '';
  GroupEdit.Text := '';
  DescChk.Checked := false;
  LinesChk.Checked := false;
  UpdateBtnStates;
end;


procedure TMultXvsYFrm.ResetBtnClick(Sender: TObject);
begin
  Reset;
end;


procedure TMultXvsYFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


procedure TMultXvsYFrm.GroupInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := VarList.ItemIndex;
  if (i > -1) and (GroupEdit.Text = '') then
  begin
    GroupEdit.Text := VarList.Items[i];
    VarList.Items.Delete(i);
  end;
  UpdateBtnStates;
end;


procedure TMultXvsYFrm.ComputeBtnClick(Sender: TObject);
var
  lReport: TStrings;
  i, N, NoGrps, XCol, YCol, GrpCol, Grp, MinGrp, MaxGrp: integer;
  MinX, MaxX, MinY, MaxY, X, Y: double;
  cellstring: string;
  MaxGrpSize: integer;
  NoInGrp: IntDyneVec = nil;
  XValues: DblDyneMat = nil;
  YValues: DblDyneMat = nil;
  Means: array[0..1] of Double = (0.0, 0.0);
  StdDevs: array[0..1] of Double = (0.0, 0.0);
  selected: array[0..2] of Integer = (0, 0, 0);
  NoSelected: Integer = 3;
begin
  MaxGrpSize := 0;
  MaxX := -Infinity;
  MinX := Infinity;
  MaxY := -Infinity;
  MinY := Infinity;

  // Get selected variables
  XCol := 0;
  YCol := 0;
  GrpCol := 0;
  for i := 1 to NoVariables do
  begin
    cellstring  :=  OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = XEdit.Text) then selected[0] := i;
    if (cellstring = YEdit.Text) then selected[1] := i;
    if (cellstring = GroupEdit.Text) then selected[2] := i;
  end;
  XCol := selected[0];
  YCol := selected[1];
  GrpCol := selected[2];

  if (XCol = 0) or (YCol = 0) or (GrpCol = 0) then
  begin
    ErrorMsg('No variable selected.');
    exit;
  end;

  // Get number of groups
  MinGrp := MaxInt;
  MaxGrp := -MaxInt;
  for i := 1 to NoCases do
  begin
    Grp := StrToInt(OS3MainFrm.DataGrid.Cells[GrpCol, i]);
    MaxGrp := Max(MaxGrp, Grp);
    MinGrp := Min(MinGrp, Grp);
  end;
  NoGrps := (MaxGrp - MinGrp) + 1;

  SetLength(XValues, NoGrps, NoCases);  // NoCases is over-dimensioned and will be trimmed later.
  SetLength(YValues, NoGrps, NoCases);  // dto.
  SetLength(NoInGrp, NoGrps);
  for i := 0 to NoGrps - 1 do NoInGrp[i] := 0;

  N := 0;
  for i := 1 to NoCases do
  begin
    if (not GoodRecord(i, NoSelected, selected))then continue;
    inc(N);

    X := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol, i]);
    MaxX := Max(MaxX, X);
    MinX := Min(MinX, X);

    Y := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol, i]);
    MaxY := Max(MaxY, Y);
    MinY := Min(MinY, Y);

    Grp := StrToInt(OS3MainFrm.DataGrid.Cells[GrpCol, i]) - MinGrp;
    XValues[Grp, NoInGrp[Grp]] := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol, i]);
    YValues[Grp, NoInGrp[Grp]] := Y;
    inc(NoInGrp[Grp]);
    MaxGrpSize := Max(MaxGrpsize, NoInGrp[Grp]);
  end;

  // Trim XValues and YValues to correct dimension.
  SetLength(XValues, NoGrps);
  SetLength(YValues, NoGrps);
  for grp := 0 to NoGrps-1 do
  begin
    SetLength(XValues[grp], NoInGrp[grp]);
    SetLength(YValues[grp], NoInGrp[grp]);
  end;

  // get descriptive data
  if DescChk.Checked then
  begin
    for i := 1 to NoCases do
    begin
      if (not GoodRecord(i,NoSelected,selected)) then continue;
      Y := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
      X := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol,i]);
      Means[0] := Means[0] + X;
      StdDevs[0] := StdDevs[0] + sqr(X);
      Means[1] :=  Means[1] + Y;
      StdDevs[1] := StdDevs[1] + sqr(Y);
    end;

    for i := 0 to 1 do
    begin
      StdDevs[i] := StdDevs[i] - sqr(Means[i]) / N;
      StdDevs[i] := sqrt(StdDevs[i] / (N - 1));
      Means[i] := Means[i] / N;
    end;

    lReport := TStringList.Create;
    try
      lReport.Add('X VERSUS Y FOR GROUPS PLOT');
      lReport.Add('');
      lReport.Add('X variable: ' + XEdit.Text);
      lReport.Add('Y variable: ' + YEdit.Text);
      lReport.Add('');

      lReport.Add('VARIABLE    MEAN   STANDARD DEVIATION');
      lReport.Add('   X   %9.3f %14.3f', [Means[0], StdDevs[0]]);
      lReport.Add('   Y   %9.3f %14.3f', [Means[1], StdDevs[1]]);
      lReport.Add('');

      DisplayReport(lReport);
    finally
      lReport.Free;
    end;
  end;

  // sort on X
  for i := 0 to NoGrps - 1 do
    SortOnX(XValues[i], YValues[i]);

  // Plot data
  PlotXY(XValues, YValues{$IFNDEF USE_TACHART}, MaxX, MinX, MaxY, MinY, MaxGrpSize, NoGrps{$ENDIF}, MinGrp);

  NoInGrp := nil;
  XValues := nil;
  YValues := nil;
end;


procedure TMultXvsYFrm.FormActivate(Sender: TObject);
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


procedure TMultXvsYFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
  Reset;
end;


procedure TMultXvsYFrm.GroupOutBtnClick(Sender: TObject);
begin
  if GroupEdit.Text <> '' then
  begin
    VarList.Items.Add(GroupEdit.Text);
    GroupEdit.Text := '';
  end;
  UpdateBtnStates;
end;


procedure TMultXvsYFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;


procedure TMultXvsYFrm.XInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := VarList.ItemIndex;
  if (i > -1) and (XEdit.Text = '') then
  begin
    XEdit.Text := VarList.Items[i];
    VarList.Items.Delete(i);
  end;
  UpdateBtnStates;
end;


procedure TMultXvsYFrm.XOutBtnClick(Sender: TObject);
begin
  if XEdit.Text <> '' then
  begin
    VarList.Items.Add(XEdit.Text);
    XEdit.Text := '';
  end;
  UpdateBtnStates;
end;


procedure TMultXvsYFrm.YInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := VarList.ItemIndex;
  if (i > -1) and (YEdit.Text = '') then
  begin
    YEdit.Text := VarList.Items[i];
    VarList.Items.Delete(i);
  end;
  UpdateBtnStates;
end;


procedure TMultXvsYFrm.YOutBtnClick(Sender: TObject);
begin
  if YEdit.Text <> '' then
  begin
    VarList.Items.Add(YEdit.Text);
    YEdit.Text := '';
  end;
  UpdateBtnStates;
end;


// Routine to plot X versus multiple Y values for several groups
// 1st index: group index, 2nd index: point index within group
{$IFDEF USE_TACHART}
procedure TMultXvsYFrm.PlotXY(const XValues, YValues: DblDyneMat; MinGrp: Integer);
var
  pt: TPlotType;
  grp: Integer;
  clr: TColor;
  grpName: String;
  sym: TSeriesPointerStyle;
begin
  if Length(XValues) <> Length(YValues) then
  begin
    ErrorMsg('Incorrect dimension of XValues and YValues');
    exit;
  end;

  if ChartForm = nil then
    ChartForm := TChartForm.Create(Application)
  else
    ChartForm.Clear;

  // Titles
  ChartForm.SetTitle(LabelEdit.Text);
  ChartForm.SetXTitle(XEdit.Text);
  chartForm.SetYTitle(YEdit.Text);

  if LinesChk.Checked then pt := ptLinesAndSymbols else pt := ptSymbols;

  for grp := 0 to Length(XValues)-1 do
  begin
    clr := DATA_COLORS[grp mod Length(DATA_COLORS)];
    sym := DATA_SYMBOLS[grp mod Length(DATA_SYMBOLS)];
    grpName := Format('%s = %d', [GroupEdit.Text, grp + MinGrp]);
    ChartForm.PlotXY(pt, XValues[grp], YValues[grp], nil, nil, grpName, clr, sym);
  end;

  ChartForm.Show;
end;
{$ELSE}
procedure TMultXvsYFrm.PlotXY(const XValues, YValues: DblDyneMat;
  MaxX, MinX, MaxY, MinY: double;  N, NoY, MinGrp: integer);
var
  xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
  vhi, hwide, offset, strhi, imagehi, i, j, Grp : integer;
  valincr, Yvalue, Xvalue, value : double;
  Title: string;
begin
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm)
  else
    BlankFrm.Image1.Canvas.Clear;
  BlankFrm.Show;

  Title := LabelEdit.Text;
  BlankFrm.Caption := Title;
  BlankFrm.Show;

  imagewide := BlankFrm.Image1.Width;
  imagehi := BlankFrm.Image1.Height;
  vtop := 40;
  vbottom := ceil(imagehi) - 60;
  vhi := vbottom - vtop;
  hleft := 100;
  hright := imagewide - 80;
  hwide := hright - hleft;

  // Draw chart border and background
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Rectangle(0, 0, imagewide, imagehi);

  // Draw title
  if Title <> '' then
  begin
    xpos := (imagewide - BlankFrm.Image1.Canvas.TextWidth(Title)) div 2;
    yPos := 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  end;

  // draw horizontal axis
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.MoveTo(hleft, vbottom);
  BlankFrm.Image1.Canvas.LineTo(hright, vbottom);
  valincr := (MaxX - MinX) / 10.0;
  for i := 1 to 11 do
  begin
    ypos := vbottom;
    Xvalue := MinX + valincr * (i - 1);
    xpos := hLeft + ceil(hwide * ((Xvalue - MinX) / (MaxX - MinX)));
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    ypos := ypos + 10;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
    Title := Format('%.2f', [Xvalue]);
    offset := BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
    xpos := xpos - offset;
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  end;
  xpos := hleft + (hwide - BlankFrm.Image1.Canvas.TextWidth(XEdit.Text)) div 2;
  ypos := vbottom + 30;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos, XEdit.Text);

  // Draw vertical axis
  Title := 'Y VALUES';
  xpos := hleft - BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
  ypos := 8;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  xpos := hleft;
  ypos := vtop;
  BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
  ypos := vbottom;
  BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
  valincr := (MaxY - MinY) / 10.0;
  for i := 1 to 11 do
  begin
    value := MaxY - ((i-1) * valincr);
    Title := Format('%.2f',[value]);
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    xpos := hleft - 20 - BlankFrm.Image1.Canvas.TextWidth(Title);
    Yvalue := MaxY - (valincr * (i-1));
    ypos := ceil(vhi * ( (MaxY - Yvalue) / (MaxY - MinY)));
    ypos := ypos + vtop - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
    xpos := hleft;
    ypos := ypos + strhi div 2;
    BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
    xpos := hleft - 10;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
  end;

  // draw points for x and y pairs
  for j := 0 to NoY - 1 do
  begin
    BlankFrm.Image1.Canvas.Brush.Style := bsSolid;
    BlankFrm.Image1.Canvas.Brush.Color := DATA_COLORS[j mod Length(DATA_COLORS)];
    BlankFrm.Image1.Canvas.Pen.Color := DATA_COLORS[j mod Length(DATA_COLORS)];
    BlankFrm.Image1.Canvas.Font.Color := DATA_COLORS[j mod Length(DATA_COLORS)];
    Grp := MinGrp + j;
    Title := 'GROUP ' + IntToStr(Grp);
    for i := 0 to N - 1 do
    begin
      xpos := hleft + ceil(hwide * ( (XValues[j, i] - MinX) / (MaxX - MinX)));
      ypos := vtop + ceil(vhi * ( (MaxY - YValues[j, i]) / (MaxY - MinY)));
      if (i = 0) then
        BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
      if LinesChk.Checked then
        BlankFrm.Image1.Canvas.LineTo(xpos, ypos);
      BlankFrm.Image1.Canvas.Ellipse(xpos, ypos, xpos+5, ypos+5);
    end;
    (*
    for i := 1 to N do
    begin
      ypos := vtop + ceil(vhi * ( (MaxY - YValues[i-1,j]) / (MaxY - MinY)));
      xpos := hleft + ceil(hwide * ( (XValues[i-1,j] - MinX) / (MaxX - MinX)));
      if (i = 1) then
        BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
      if LinesChk.Checked then
        BlankFrm.Image1.Canvas.LineTo(xpos, ypos);
      BlankFrm.Image1.Canvas.Ellipse(xpos, ypos, xpos+5, ypos+5);
    end;
    *)
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    BlankFrm.Image1.Canvas.Brush.Color := clWhite;
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    xpos := hwide + hleft;
    BlankFrm.Image1.Canvas.MoveTo(xpos, ypos-strhi);
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  end;

  BlankFrm.Image1.Canvas.Font.Color := clBlack;
end;
{$ENDIF}


procedure TMultXvsYFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  lSelected := false;
  for i:=0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;

  XInBtn.Enabled := lSelected and (XEdit.Text = '');
  YInBtn.Enabled := lSelected and (YEdit.Text = '');
  GroupInBtn.Enabled := lSelected and (GroupEdit.Text = '');
  XOutBtn.Enabled := (XEdit.Text <> '');
  YOutBtn.Enabled := (YEdit.Text <> '');
  GroupOutBtn.Enabled := (GroupEdit.Text <> '');
end;


end.

