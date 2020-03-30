// File for testing: "boltsize.laz"
//  LotNo --> Group Variable
//  BoltLngth --> Measurement Variable

unit RChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Printers, ExtCtrls, Buttons,
  MainUnit, Globals, OutputUnit, GraphLib, BlankFrmUnit, ContextHelpUnit;


type

  { TRChartFrm }

  TRChartFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    Panel4: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
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
    procedure PlotMeans(VAR means : DblDyneVec;
                        NoGrps : integer;
                        UCL, LCL, GrandMean : double);
  public
    { public declarations }
  end; 

var
  RChartFrm: TRChartFrm;

implementation

uses
  Math;

{ TRChartFrm }

procedure TRChartFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  GroupEdit.Text := '';
  MeasEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TRChartFrm.VarListClick(Sender: TObject);
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

procedure TRChartFrm.FormActivate(Sender: TObject);
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

procedure TRChartFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if BlankFrm = nil then
    Application.CreateForm(TBlankfrm, BlankFrm);
end;

procedure TRChartFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TRChartFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TRChartFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, GrpVar, MeasVar, mingrp, maxgrp, G, range, grpsize : integer;
   oldgrpsize : integer;
   X, UCL, LCL: double;
   xmin, xmax, GrandMean, GrandSD, semean, D3Value, D4Value : double;
   GrandRange : double;
   means, stddev, ranges : DblDyneVec;
   count : IntDyneVec;
   cellstring: string;
   sizeError : boolean;
   lReport: TStrings;
const
  D3: array[1..24] of double = (
    0,0,0,0,0,0.076,0.136,0.184,0.223,0.256,0.283,0.307,0.328,
    0.347,0.363,0.378,0.391,0.403,0.415,0.425,0.434,0.443,
    0.451,0.459
  );
  D4: array[1..24] of double = (
    3.267, 2.574, 2.282, 2.114, 2.004, 1.924, 1.864, 1.816,1.777,
    1.744, 1.717, 1.693, 1.672, 1.653, 1.637, 1.622, 1.608,1.597,
    1.585, 1.575, 1.566, 1.557, 1.548, 1.541
  );
begin
  if (GroupEdit.Text = '') then
  begin
    MessageDlg('Group variable is not specified.', mtError, [mbOk], 0);
    exit;
  end;

  if (MeasEdit.Text = '') then
  begin
    MessageDlg('Measurement variable is not specified.', mtError, [mbOK], 0);
    exit;
  end;

  GrpVar := 1;
  MeasVar := 2;
  grpsize := 0;
  oldgrpsize := 0;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if cellstring = GroupEdit.Text then GrpVar := i;
    if cellstring = MeasEdit.Text then MeasVar := i;
  end;

  mingrp := MaxInt;
  maxgrp := -MaxInt;
  for i := 1 to NoCases do
  begin
    G := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpVar,i])));
    if G < mingrp then mingrp := G;
    if G > maxgrp then maxgrp := G;
  end;
  range := maxgrp - mingrp + 1;

  SetLength(means,range);
  SetLength(count,range);
  SetLength(stddev,range);
  SetLength(ranges,range);

  for i := 0 to range-1 do
  begin
    count[i] := 0;
    means[i] := 0.0;
    stddev[i] := 0.0;
    ranges[i] := 0.0;
  end;
  semean := 0.0;
  GrandMean := 0.0;
  GrandRange := 0.0;
  sizeError := false;

  // calculate group ranges, grand mean, group sd's, semeans
  for j := 1 to range do // groups
  begin
    xmin := 1E308;
    xmax := -1E308;
    for i := 1 to NoCases do
    begin
      G := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpVar,i])));
      G := G - mingrp + 1;
      if G = j then
      begin
        X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar,i]));
        if X > xmax then xmax := X;
        if X < xmin then xmin := X;
        means[G-1] := means[G-1] + X;
        count[G-1] := count[G-1] + 1;
        stddev[G-1] := stddev[G-1] + X * X;
        semean := semean + X * X;
        GrandMean := GrandMean + X;
      end;
    end; // next case

    ranges[j-1] := xmax - xmin;
    GrandRange := GrandRange + ranges[j-1];
    grpsize := count[j-1];
    if j = 1 then oldgrpsize := grpsize;
    if oldgrpsize <> grpsize then sizeError := true;
  end;

  if (grpsize < 2) or (grpsize > 25) or sizeError then
  begin
    MessageDlg('Group sizes error.', mtError, [mbOk], 0);
    exit;
  end;

  for i := 0 to range-1 do
  begin
    stddev[i] := stddev[i] - sqr(means[i]) / count[i];
    stddev[i] := stddev[i] / (count[i] - 1);
    stddev[i] := sqrt(stddev[i]);
    means[i] := means[i] / count[i];
  end;
  semean := semean - GrandMean * GrandMean / NoCases;
  semean := semean / (NoCases - 1);
  semean := sqrt(semean);
  GrandSD := semean;
  semean := semean / sqrt(NoCases);
  GrandMean := GrandMean / NoCases;
  GrandRange := GrandRange / range;
  D3Value := D3[grpsize-1];
  D4Value := D4[grpsize-1];
{
     C4 = sqrt(2.0 / (double(grpsize)-1));
     double gamma = exp(gammln(double(grpsize)/2.0));
     C4 *= gamma;
     gamma = exp(gammln(double(grpsize-1)/2.0));
     C4 /= gamma;
}
  UCL := D4Value * GrandRange;
  LCL := D3Value * GrandRange;

  // printed results
  lReport := TStringList.Create;
  try
    lReport.Add('X Bar Chart Results');
    lReport.Add('');
    lReport.Add('Group Size Mean      Range   Std.Dev.');
    lReport.Add('----- ---- --------- ------- --------');
    for i := 0 to range-1 do
      lReport.Add(' %3d %3d %8.2f  %8.2f  %8.2f', [i+1, count[i], means[i], ranges[i], stddev[i]]);
    lReport.Add('');
    lReport.Add('Grand Mean:             %8.3f', [GrandMean]);
    lReport.Add('Standard Deviation:     %8.3f', [GrandSD]);
    lReport.Add('Standard Error of Mean: %8.3f', [semean]);
    lReport.Add('Mean Range:             %8.3f', [GrandRange]);
    lReport.Add('Lower Control Limit:    %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:    %8.3f', [UCL]);

    DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // show graph
  PlotMeans(ranges, range, UCL, LCL, GrandRange);

  // Clean up
  ranges := nil;
  stddev := nil;
  count := nil;
  means := nil;
end;

procedure TRChartFrm.PlotMeans(var means: DblDyneVec; NoGrps: integer; UCL,
  LCL, GrandMean: double);
var
   i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
   vhi, hwide, offset, strhi : integer;
   imagehi, maxval, minval, valincr, Yvalue : double;
   Title : string;
begin
     maxval := -10000.0;
     minval := 10000.0;
     for i := 0 to NoGrps-1 do
     begin
          if means[i] > maxval then maxval := means[i];
          if means[i] < minval then minval := means[i];
     end;
     if UCL > maxval then maxval := UCL;
     if LCL < minval then minval := LCL;

     BlankFrm.Show;
     Title := 'RANGE CHART FOR : ' + OS3MainFrm.FileNameEdit.Text;
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
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     xpos := hright;
     BlankFrm.Image1.Canvas.Pen.Color := clRed;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     Title := 'MEAN';
     strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
     ypos := ypos - strhi div 2;
     BlankFrm.Image1.Canvas.Brush.Style := bsClear;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

     // draw horizontal axis
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
          Title := format('%8.2f',[maxval - ((i-1)*valincr)]);
          strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
          xpos := 10;
          Yvalue := maxval - (valincr * (i-1));
          ypos := round(vhi * ( (maxval - Yvalue) / (maxval - minval)));
          ypos := ypos + vtop - strhi div 2;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
     end;

     // draw lines for means of the groups
     ypos := round(vhi * ( (maxval - means[0]) / (maxval - minval)));
     ypos := ypos + vtop;
     xpos := round((hwide / NoGrps) + hleft);
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     for i := 2 to NoGrps do
     begin
          ypos := round(vhi * ( (maxval - means[i-1]) / (maxval - minval)));
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

initialization
  {$I rchartunit.lrs}

end.

