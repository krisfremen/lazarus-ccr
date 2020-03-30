// Use file "boltsize.laz" for testing
//   Group Variable --> LotNo
//   Selected Variable --> BoltLength
//   Upper Spec Level --> 20.05
//   Lower Spec Level --> 19.95
//   Target Spec      --> 20.00

unit XBarUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, ContextHelpUnit, DataProcs, OutputUnit, GraphLib, BlankFrmUnit;

type

  { TXBarFrm }

  TXBarFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
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
    Label1: TLabel;
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
    FAutoSized: Boolean;
    procedure PlotMeans(var Means: DblDyneVec; NoGrps: integer;
      UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec: double);
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  XBarFrm: TXBarFrm;

implementation

uses
  Math;

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
  i, GrpVar, MeasVar, mingrp, maxgrp, G, range: integer;
  X, UCL, LCL, Sigma, UpperSpec, LowerSpec, TargetSpec: double;
  GrandMean, GrandSD, semean: double;
  means, stddev: DblDyneVec;
  count: IntDyneVec;
  cellstring: string;
  ColNoSelected: IntDyneVec;
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

  mingrp := 10000;
  maxgrp := -10000;
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    G := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpVar,i])));
    if G < mingrp then mingrp := G;
    if G > maxgrp then maxgrp := G;
  end;
  range := maxgrp - mingrp + 1;

  SetLength(means, range);
  SetLength(count, range);
  SetLength(stddev, range);
  for i := 0 to range-1 do
  begin
    count[i] := 0;
    means[i] := 0.0;
    stddev[i] := 0.0;
  end;
  semean := 0.0;
  GrandMean := 0.0;

  // calculate group means, grand mean, group sd's, semeans
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    G := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpVar,i])));
    G := G - mingrp + 1;
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar,i]));
    means[G-1] := means[G-1] + X;
    count[G-1] := count[G-1] + 1;
    stddev[G-1] := stddev[G-1] + (X * X);
    semean := semean + (X * X);
    GrandMean := GrandMean + X;
  end;

  for i := 0 to range-1 do
  begin
    stddev[i] := stddev[i] - sqr(means[i]) / count[i];
    if count[i] > 1 then
    begin
      stddev[i] := stddev[i] / (count[i] - 1);
      stddev[i] := sqrt(stddev[i]);
    end
    else
      stddev[i] := 0.0;
    means[i] := means[i] / count[i];
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
    lReport.Add('Group Size Mean      Std.Dev.');
    lReport.Add('----- ---- --------- ----------');
    for i := 0 to range-1 do
      lReport.Add(' %3d %3d %8.2f  %8.2f', [i+1, count[i], means[i], stddev[i]]);
    lReport.Add('');
    lReport.Add('Grand Mean:             %8.3f', [GrandMean]);
    lReport.Add('Standard Deviation:     %8.3f', [GrandSD]);
    lReport.Add('Standard Error of Mean: %8.3f', [semean]);
    lReport.Add('');
    lReport.Add('Lower Control Limit:    %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:    %8.3f', [UCL]);

    DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // show graph
  BlankFrm.Image1.Canvas.Clear;
  BlankFrm.Show;
  PlotMeans(means, range, UCL, LCL, GrandMean, TargetSpec, LowerSpec, UpperSpec);

  // Clean up
  stddev := nil;
  count := nil;
  means := nil;
  ColNoSelected := nil;
end;

procedure TXBarFrm.FormActivate(Sender: TObject);
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

  VarList.Constraints.MinWidth := GroupBox1.Width;
  VarList.Constraints.MinHeight := GroupBox1.Top + GroupBox1.Height - VarList.Top;

  AutoSize := false;
//  ClientHeight := GroupBox1.Top + GroupBox1.Height + Panel1.BorderSpacing.Top + Panel1.Height + Bevel1.Height + CloseBtn.Height + CloseBtn.BorderSpacing.Top*2;
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TXBarFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TXBarFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TXBarFrm.PlotMeans(var means: DblDyneVec; NoGrps: integer;
  UCL, LCL, GrandMean: double; TargetSpec, LowerSpec, UpperSpec: double);
var
  i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide: integer;
  vhi, hwide, offset, strhi: integer;
  imagehi, maxval, minval, valincr, Yvalue: double;
  title: String;
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
  BlankFrm.Image1.Canvas.Pen.Style := psDash;
  BlankFrm.Image1.Canvas.Pen.Color := clRed;
  BlankFrm.Image1.Canvas.Line(hleft, ypos, hright, ypos);
  title := 'UCL';
  strhi := BlankFrm.Image1.Canvas.TextHeight(title);
  ypos := ypos - strhi div 2;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos, title);

  ypos := round(vhi * ( (maxval - LCL) / (maxval - minval)));
  ypos := ypos + vtop;
  BlankFrm.Image1.Canvas.Pen.Color := clRed;
  BlankFrm.Image1.Canvas.Line(hleft, ypos, hright, ypos);
  title := 'LCL';
  strhi := BlankFrm.Image1.Canvas.TextHeight(title);
  ypos := ypos - strhi div 2;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos, title);

  // Draw lines for specified values
  BlankFrm.Image1.Canvas.Pen.Color := clGreen;
  if UpSpecChk.Checked then
  begin
    ypos := round(vhi * (maxval - UpperSpec) / (maxval - minval));
    ypos := ypos + vtop;
    BlankFrm.Image1.Canvas.Pen.Style := psSolid;
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
    BlankFrm.Image1.Canvas.Pen.Color := clGreen;
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
    BlankFrm.Image1.Canvas.Pen.Color := clBlue;
    BlankFrm.Image1.Canvas.Line(hleft, ypos, hright, ypos);
    title := 'TARGET';
    strhi := BlankFrm.Image1.Canvas.TextHeight(title);
    ypos := ypos - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, title);
  end;
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

