// File for testing: "BoltSizes.laz"
//   Lot No --> Group variable
//   BoltLngth --> Measurement variable
//   Delta --> 0.01
//   Alpha --> 0.05
//   Beta ---> 0.20

unit CUMSUMUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, DataProcs, OutputUnit, BlankFrmUnit, ContextHelpUnit;

type

  { TCUMSUMFrm }

  TCUMSUMFrm = class(TForm)
    Bevel2: TBevel;
    ComputeBtn: TButton;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    CloseBtn: TButton;
    ReturnBtn1: TButton;
    TargetEdit: TEdit;
    TargetChk: TCheckBox;
    DeltaEdit: TEdit;
    AlphaEdit: TEdit;
    BetaEdit: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
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
    FAutoSized: boolean;
    semean: double;
    procedure PlotMeans(var Means: DblDyneVec; NoGrps: integer; GrandMean: double);
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  CUMSUMFrm: TCUMSUMFrm;

implementation

uses
  Math;

{ TCUMSUMFrm }

procedure TCUMSUMFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     GroupEdit.Text := '';
     MeasEdit.Text := '';
     DeltaEdit.Text := '';
     TargetEdit.Text := '';
     TargetChk.Checked := false;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TCUMSUMFrm.VarListClick(Sender: TObject);
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

procedure TCUMSUMFrm.FormActivate(Sender: TObject);
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

  VarList.Constraints.MinWidth :=  GroupBox1.Width * 8 div 10;
  VarList.Constraints.MinHeight :=  GroupBox2.Top + GroupBox2.Height - VarList.Top;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TCUMSUMFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
  AlphaEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  BetaEdit.Text := FormatFloat('0.00', DEFAULT_BETA_LEVEL);
end;

procedure TCUMSUMFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TCUMSUMFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TCUMSUMFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, GrpVar, MeasVar, mingrp, maxgrp, G, range, grpsize : integer;
   oldgrpsize : integer;
   X, UCL, LCL : double;
   xmin, xmax, GrandMean, GrandSD : double;
   Target, GrandSum : double;
   Means, StdDev, CumSums: DblDyneVec;
   count : IntDyneVec;
   cellstring: string;
   sizeError: boolean;
   ColNoSelected : IntDyneVec;
   NoSelected : integer;
   lReport: TStrings;
   msg: String;
   C: TWinControl;

   procedure CleanUp;
   begin
     CumSums := nil;
     StdDev := nil;
     Count := nil;
     Means := nil;
     ColNoSelected := nil;
   end;

begin
  if not Validate(msg, C) then
  begin
     C.SetFocus;
     MessageDlg(msg, mtError, [mbOK], 0);
     exit;
  end;

  SetLength(ColNoSelected,NoVariables);
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
  NoSelected := 2;
  ColNoSelected[0] := GrpVar;
  ColNoSelected[1] := MeasVar;

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

  SetLength(means,range);
  SetLength(count,range);
  SetLength(stddev,range);
  SetLength(cumsums,range);

  for i := 0 to range-1 do
  begin
      count[i] := 0;
      means[i] := 0.0;
      stddev[i] := 0.0;
      cumsums[i] := 0.0;
  end;
  semean := 0.0;
  GrandMean := 0.0;
  sizeerror := false;
  GrandSum := 0.0;
  if TargetChk.Checked then Target := StrToFloat(TargetEdit.Text)
  else Target := 0.0;

  // calculate group ranges, grand mean, group sd's, semeans
  for j := 1 to range do // groups
  begin
      xmin := 10000.0;
      xmax := -10000.0;
      for i := 1 to NoCases do
      begin
           if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
           G := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpVar,i])));
           G := G - mingrp + 1;
           if G = j then
           begin
                X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar,i]));
                if X > xmax then xmax := X;
                if X < xmin then xmin := X;
                count[G-1] := count[G-1] + 1;
                stddev[G-1] := stddev[G-1] + (X * X);
                semean := semean + (X * X);
                means[G-1] := means[G-1] + X;
                GrandMean := GrandMean + X;
           end;
      end; // next case
      stddev[j-1] := stddev[j-1] - (means[j-1] * means[j-1] / count[j-1]);
      stddev[j-1] := stddev[j-1] / (count[j-1] - 1);
      stddev[j-1] := sqrt(stddev[j-1]);
      grpsize := count[j-1];
      means[j-1] := means[j-1] / count[j-1];
      if j = 1 then oldgrpsize := grpsize;
      if oldgrpsize <> grpsize then sizeerror := true;
  end; // next group

  // now get cumulative deviations of means from target
  if Target = 0.0 then Target := means[range-1];
  cumsums[0] := means[0] - Target;
  GrandSum := GrandSum + (means[0] - Target);
  for j := 2 to range do
  begin
      cumsums[j-1] := cumsums[j-2] + (means[j-1] - Target);
      GrandSum := GrandSum + (means[j-1] - Target);
  end;

  if (grpsize < 2) or (grpsize > 25) or (sizeerror) then
  begin
      MessageDlg('Group sizes error.', mtError, [mbOK], 0);
      CleanUp;
      exit;
  end;

  semean := semean - ((GrandMean * GrandMean) / NoCases);
  semean := semean / (NoCases - 1);
  semean := sqrt(semean);
  GrandSD := semean;
  semean := semean / sqrt(NoCases);
  GrandMean := GrandMean / NoCases; // mean of all observations
  GrandSum := GrandSum / range; // mean of the group means
  UCL := GrandMean + (3.0 * semean);
  LCL := GrandMean - (3.0 * semean);
  if (LCL < 0.0) then LCL := 0.0;

  // printed results
  lReport := TStringList.Create;
  try
    lReport.Clear;
    lReport.Add('CUMSUM Chart Results');
    lReport.Add('');
    lReport.Add('Group Size Mean      Std.Dev.  Cum.Dev. of');
    lReport.Add('                               Mean from Target');
    lReport.Add('----- ---- --------  --------  ----------------');
    for i := 0 to range-1 do
      lReport.Add(' %3d %3d %8.2f %8.2f      %8.2f', [i+1, count[i], means[i], stddev[i], cumsums[i]]);
    lReport.Add('');
    lReport.Add('Mean of group deviations:  %8.3f', [GrandSum]);
    lReport.Add('Mean of all observations:  %8.3f', [GrandMean]);
    lReport.Add('Std. Dev. of Observations: %8.3f', [GrandSD]);
    lReport.Add('Standard Error of Mean:    %8.3f', [seMean]);
    lReport.Add('Target Specification:      %8.3f', [Target]);
    lReport.Add('Lower Control Limit:       %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:       %8.3f', [UCL]);

    DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // show graph
  PlotMeans(cumsums, range, GrandSum);

  // Clean up
  CleanUp;
end;

procedure TCUMSUMFrm.PlotMeans(var Means: DblDyneVec; NoGrps: integer;
  GrandMean: double);
var
   i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
   vhi, hwide, offset, strhi, grpnospc, distx : integer;
   imagehi, maxval, minval, valincr, Yvalue : double;
   alpha, beta, delta, gamma, theta, kfactor, d : double;
   Title : string;
begin
     maxval := -10000.0;
     minval := 10000.0;
     for i := 0 to NoGrps-1 do
     begin
          if means[i] > maxval then maxval := means[i];
          if means[i] < minval then minval := means[i];
     end;
//     BlankFrm.Image1.Canvas.Clear;
     BlankFrm.Show;
     Title := 'CUMSUM CHART FOR : ' + OS3MainFrm.FileNameEdit.Text;
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
     Title := 'AVG.DEV.';
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

     // Draw V Mask
     if DeltaEdit.Text = '' then exit; // not elected
     BlankFrm.Image1.Canvas.Pen.Color := clBlue;
     delta := StrToFloat(DeltaEdit.Text);
     gamma := delta / semean;
     alpha := StrToFloat(AlphaEdit.Text);
     beta := StrToFloat(BetaEdit.Text);
     kfactor := 2.0 * semean;
     d := (2.0 / (gamma * gamma)) * ln((1.0 - beta)/alpha);
     theta := arctan(delta / (2.0 * kfactor));
     grpnospc := round(hwide / NoGrps);
     xpos := hleft + (grpnospc * (NoGrps)); // last group
     ypos := round(vhi * ( (maxval - means[NoGrps-1]) / (maxval - minval)));
     ypos := ypos + vtop;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     xpos := round(xpos + (d * grpnospc / hwide)); // scaled d
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos); // line 0 to A

     // draw upper angle line
     xpos := hleft + (grpnospc * NoGrps); // last group
     xpos := round(xpos + (d * grpnospc / hwide)); // plus scaled d
     ypos := round(vhi * ( (maxval - means[NoGrps-1]) / (maxval - minval)));
     ypos := ypos + vtop;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     ypos := vtop; // draw angle up to top of graph
     distx := round(vhi / tan(theta)); // x unscaled distance
     xpos := round(xpos - (distx * grpnospc / hwide));
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);

     // draw lower angle line
     xpos := hleft + (grpnospc * NoGrps); // last group
     xpos := round(xpos + (d * grpnospc / hwide)); // plus scaled d
     ypos := round(vhi * ( (maxval - means[NoGrps-1]) / (maxval - minval)));
     ypos := ypos + vtop;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     ypos := vbottom;
     xpos  := round(xpos - (distx * grpnospc / hwide));
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
end;

function TCUMSUMFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
begin
  Result := False;

  if GroupEdit.Text = '' then
  begin
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

  if DeltaEdit.Text = '' then
  begin
    AMsg := 'Delta parameter not specified.';
    AControl := DeltaEdit;
    exit;
  end;
  if not TryStrToFloat(DeltaEdit.Text, x) then
  begin
    AMsg := 'Delta parameter is not a valid number.';
    AControl := DeltaEdit;
    exit;
  end;

  if AlphaEdit.Text = '' then
  begin
    AMsg := 'Alpha probability is not specified.';
    AControl := AlphaEdit;
    exit;
  end;
  if not TryStrToFloat(AlphaEdit.Text, x) then
  begin
    AMsg := 'Alpha probability is not a valid number.';
    AControl := AlphaEdit;
    exit;
  end;

  if BetaEdit.Text = '' then
  begin
    AMsg := 'Beta probability is not specified.';
    AControl := BetaEdit;
    exit;
  end;
  if not TryStrtoFloat(BetaEdit.Text, x) then
  begin
    AMsg := 'Beta probability is not a valid number,';
    AControl := BetaEdit;
    exit;
  end;

   if TargetChk.Checked then
   begin
     if TargetEdit.Text = '' then
     begin
       AMsg := 'Target is not specified.';
       AControl := TargetEdit;
       exit;
     end;
     if not TryStrToFloat(TargetEdit.Text, x) then
     begin
       AMsg := 'Target specification is not a valid number.';
       AControl := TargetEdit;
       exit;
     end;
   end;

  Result := true;
end;

initialization
  {$I cumsumunit.lrs}

end.

