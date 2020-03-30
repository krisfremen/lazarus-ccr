// File for testing: "defects.laz"
//  - Measurement variable: "Defects"
//  - No. inspected per group: 1000

unit UChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, OutputUnit, DataProcs, BlankFrmUnit, ContextHelpUnit;

type

  { TUChartFrm }

  TUChartFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    ComputeBtn: TButton;
    HelpBtn: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel1: TPanel;
    ResetBtn: TButton;
    CloseBtn: TButton;
    XSigmaEdit: TEdit;
    NoInspEdit: TEdit;
    Label3: TLabel;
    MeasEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
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
    FAutoSized: Boolean;
    procedure PlotMeans(var Means: DblDyneVec; NoGrps: integer;
      UCL, LCL, GrandMean: double);
    function Validate(out AMsg: String; out AControl: TWinControl): boolean;
  public
    { public declarations }
  end; 

var
  UChartFrm: TUChartFrm;

implementation

uses
  Math;

{ TUChartFrm }

procedure TUChartFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  MeasEdit.Text := '';
  NoInspEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TUChartFrm.VarListClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    MeasEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
end;

procedure TUChartFrm.FormActivate(Sender: TObject);
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

  VarList.Constraints.MinWidth := SigmaOpts.Width * 3 div 4;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TUChartFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TUChartFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TUChartFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TUChartFrm.ComputeBtnClick(Sender: TObject);
var
  i, MeasVar: integer;
  X, size, count, UCL, LCL, Sigma: double;
  GrandMean, meanc, stddevc: double;
  means, defperunit: DblDyneVec;
  cellstring: string;
  ColNoSelected: IntDyneVec;
  NoSelected: integer;
  msg: String;
  C: TWinControl;
  lReport: TStrings;
begin
  if not Validate(msg, C) then
  begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  SetLength(ColNoSelected,2);
  MeasVar := 0;
  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if cellstring = MeasEdit.Text then MeasVar := i;
  end;
  NoSelected := 1;
  ColNoSelected[0] := MeasVar;

  case SigmaOpts.ItemIndex of
    0: Sigma := 3.0;
    1: Sigma := 2.0;
    2: Sigma := 1.0;
    3: Sigma := StrToFloat(XSigmaEdit.Text);
  end;

  SetLength(means, NoCases + 1);
  SetLength(defperunit, NoCases + 1);
  GrandMean := 0.0;
  size := 0.0;
  count := StrToFloat(NoInspEdit.Text);

  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar,i]));
    means[i] := X;
    GrandMean := GrandMean + X;
    defperunit[i] := means[i] / count;
    size := size + count;
  end;

  meanc := GrandMean / size;
  stddevc := sqrt(meanc / count);
  UCL := meanc + Sigma * stddevc;
  LCL := meanc - Sigma * stddevc;

  // printed results
  lReport := TStringList.Create;
  try
    lReport.Add('DEFECTS c CONTROL CHART RESULTS');
    lReport.Add('');
    lReport.Add('Sample  No Defects  Defects Per Unit');
    lReport.Add('------  ----------  ----------------');
    for i := 1 to NoCases do
      lReport.Add(' %3d      %8.2f       %8.2f', [i, means[i], defperunit[i]]);
    lReport.Add('');
    lReport.Add('Total Nonconformities: %8.2f', [GrandMean]);
    lReport.Add('No. of Samples:        %8d',   [NoCases]);
    lReport.Add('Def. / unit Mean:      %8.3f', [meanc]);
    lReport.Add('   and StdDev:         %8.3f', [stddevc]);
    lReport.Add('Lower Control Limit:   %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:   %8.3f', [UCL]);
    DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // show graph
  PlotMeans(defperunit, NoCases, UCL, LCL, meanc);

  defperunit := nil;
  means := nil;
  ColNoSelected := nil;
end;

procedure TUChartFrm.PlotMeans(var Means: DblDyneVec; NoGrps: integer;
  UCL, LCL, GrandMean: double);
var
   i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
   vhi, hwide, offset, strhi : integer;
   imagehi, maxval, minval, valincr, Yvalue : double;
   Title : string;
begin
     maxval := -10000.0;
     minval := 10000.0;
     for i := 1 to NoGrps do
     begin
          if means[i] > maxval then maxval := means[i];
          if means[i] < minval then minval := means[i];
     end;
     if UCL > maxval then maxval := UCL;
     if LCL < minval then minval := LCL;
     BlankFrm.Show;
     Title := 'DEFECT CONTROL (c) CHART FOR : ' + OS3MainFrm.FileNameEdit.Text;
     BlankFrm.Caption := Title;
     imagewide := BlankFrm.Image1.Width;
     imagehi := BlankFrm.Image1.Height;
     vtop := 20;
     vbottom := round(imagehi) - 80;
     vhi := vbottom - vtop;
     hleft := 100;
     hright := imagewide - 80;
     hwide := hright - hleft;

     BlankFrm.Image1.Canvas.Brush.Color := clLtGray;
     BlankFrm.Image1.Canvas.FillRect(0, 0, BlankFrm.Image1.Width, BlankFrm.Image1.Height);

     // Draw chart border
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;
     BlankFrm.Image1.Canvas.Rectangle(hleft,vtop-10,hleft+hwide,vtop+vhi+10);

     // draw Grand Mean
     ypos := round(vhi * ( (maxval - GrandMean) / (maxval - minval)));
     ypos := ypos + vtop;
     xpos := hleft;
     BlankFrm.Image1.Canvas.Pen.Color := clRed;
     BlankFrm.Image1.Canvas.Brush.Style := bsClear;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     xpos := hright;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     Title := 'MEAN';
     strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
     ypos := ypos - strhi div 2;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

     // draw horizontal axis
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.MoveTo(hleft,vbottom + 20);
     BlankFrm.Image1.Canvas.LineTo(hright,vbottom + 20);
     for i := 1 to NoGrps do
     begin
          ypos := vbottom + 10;
          xpos := round((hwide / NoGrps)* i + hleft);
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          ypos := ypos + 10;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          Title := format('%d',[i]);
          offset := BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
          strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
          xpos := xpos - offset;
          ypos := ypos + strhi;
          BlankFrm.Image1.Canvas.Pen.Color := clBlack;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
          xpos := 10;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,'GROUPS:');
     end;

     // Draw vertical axis
     valincr := (maxval - minval) / 10.0;
     for i := 1 to 11 do
     begin
          Title := format('%8.3f',[maxval - ((i-1)*valincr)]);
          strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
          xpos := 10;
          Yvalue := maxval - (valincr * (i-1));
          ypos := round(vhi * ( (maxval - Yvalue) / (maxval - minval)));
          ypos := ypos + vtop - strhi div 2;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
     end;

     // draw lines for means of the groups
     ypos := round(vhi * ( (maxval - means[1]) / (maxval - minval)));
     ypos := ypos + vtop;
     xpos := round((hwide / NoGrps) + hleft);
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     for i := 2 to NoGrps do
     begin
          ypos := round(vhi * ( (maxval - means[i]) / (maxval - minval)));
          ypos := ypos + vtop;
          xpos := round((hwide / NoGrps)* i + hleft);
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     end;

     // Draw upper and lower confidence intervals
     ypos := round(vhi * ( (maxval - UCL) / (maxval - minval)));
     ypos := ypos + vtop;
     xpos := hleft;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     xpos := hright;
     BlankFrm.Image1.Canvas.Pen.Color := clRed;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     Title := 'UCL';
     strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
     ypos := ypos - strhi div 2;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

     ypos := round(vhi * ( (maxval - LCL) / (maxval - minval)));
     ypos := ypos + vtop;
     xpos := hleft;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     xpos := hright;
     BlankFrm.Image1.Canvas.Pen.Color := clRed;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     Title := 'LCL';
     strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
     ypos := ypos - strhi div 2;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
end;

function TUChartFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
   n: Integer;
   x: Double;
begin
  Result := false;

  if MeasEdit.Text = '' then
  begin
    AMsg := 'Measurement variable is not specified.';
    AControl := MeasEdit;
    exit;
  end;

  if NoInspEdit.Text = '' then
  begin
    AMsg := 'Number inspected per group is not specified.';
    AControl := NoInspEdit;
    exit;
  end;
  if not TryStrToInt(NoInspEdit.Text, n) then
  begin
    AMsg := 'Number inspected per group is not a valid number.';
    AControl := NoInspEdit;
    exit;
  end;

  if SigmaOpts.ItemIndex = 3 then
  begin
    if XSigmaEdit.Text = '' then
    begin
      AMsg := 'X sigma is not specified.';
      AControl := XSigmaEdit;
      exit;
    end;
    if not TryStrToFloat(XSigmaEdit.Text, x) then
    begin
      AMsg := 'X sigma is not a valid number.';
      AControl := XSigmaEdit;
      exit;
    end;
  end;

  Result := true;
end;
initialization
  {$I uchartunit.lrs}

end.

