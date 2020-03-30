// File for testing: "defects.laz"
//   Defects --> Measurement Variable
//   No of parts sampled ---> 1000
//   Expected proportion of defects --> 0.01

unit PChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  MainUnit, Globals, Math, OutputUnit, Buttons, BlankFrmUnit, ContextHelpUnit;

type

  { TpChartFrm }

  TpChartFrm = class(TForm)
    Bevel2: TBevel;
    ComputeBtn: TButton;
    HelpBtn: TButton;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Panel1: TPanel;
    ResetBtn: TButton;
    CloseBtn: TButton;
    XSigmaEdit: TEdit;
    NEdit: TEdit;
    PEdit: TEdit;
    Label3: TLabel;
    Label4: TLabel;
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
    procedure PlotMeans(var means: DblDyneVec; NoGrps: integer;
      UCL, LCL, GrandMean, Target: double);
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  pChartFrm: TpChartFrm;

implementation

{ TpChartFrm }

procedure TpChartFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  MeasEdit.Text := '';
  NEdit.Text := '';
  PEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TpChartFrm.VarListClick(Sender: TObject);
var
  index : integer;
begin
  index := VarList.ItemIndex;
  if index > -1 then begin
    MeasEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
end;

procedure TpChartFrm.FormActivate(Sender: TObject);
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

  VarList.Constraints.MinHeight := SigmaOpts.Top + SigmaOpts.Height - VarList.Top;
  VarList.Constraints.MinWidth := SigmaOpts.Width * 3 div 4;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TpChartFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if BlankFrm = nil then
    Application.CreateForm(TBlankfrm, BlankFrm);
end;

procedure TpChartFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TpChartFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TpChartFrm.ComputeBtnClick(Sender: TObject);
var
  P, N, variance, stddev, UCL, LCL, X, Sigma, AVG: double;
  i, measvar: integer;
  cellstring: string;
  obsp: DblDyneVec;
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

  AVG := 0.0;
  measvar := 1;
  Sigma := 3;
  N := StrToFloat(NEdit.Text);
  P := StrToFloat(PEdit.Text);
  case SigmaOpts.ItemIndex of
    0: Sigma := 3.0;
    1: Sigma := 2.0;
    2: Sigma := 1.0;
    3:  Sigma := StrToFloat(XSigmaEdit.Text);
  end;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if cellstring = MeasEdit.Text then measvar := i;
  end;
  variance := P * (1.0 - P) / N;
  stddev := Sqrt(variance);
  SetLength(obsp, NoCases + 1);
  for i := 1 to NoCases do
  begin
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[measvar,i]));
    X := X / N;
    obsp[i] := X;
    AVG := AVG + X;
  end;
  AVG := AVG / NoCases;
  UCL := P + Sigma * stddev;
  LCL := P - Sigma * stddev;

  // output results
  lReport := TStringList.Create;
  try
    lReport.Add('DEFECTS P CONTROL CHART RESULS');
    lReport.Add('');
    lReport.Add('Sample No.  Proportion');
    lReport.Add('----------  ----------');
    for i := 1 to NoCases do
      lReport.Add('   %5d        %6.3f', [i, obsp[i]]);
    lReport.Add('');
    lReport.Add('Target proportion:                %6.4f', [P]);
    lReport.Add('Sample size for each observation: %6.0f', [N]);
    lReport.Add('Average proportion observed       %6.4f', [AVG]);

    DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // Now create plot
  PlotMeans(obsp,NoCases,UCL,LCL, Avg, P);

  obsp := nil;
end;

procedure TpChartFrm.PlotMeans(var Means: DblDyneVec; NoGrps: integer;
  UCL, LCL, GrandMean, Target: double);
var
   i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
   vhi, hwide, offset, strhi, oldxpos : integer;
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
     BlankFrm.Image1.Canvas.Clear;
     BlankFrm.Show;
     Title := 'p CONTROL CHART FOR ' + OS3MainFrm.FileNameEdit.Text;
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
     BlankFrm.Image1.Canvas.Pen.Color := clBlue;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     Title := 'MEAN';
     strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
     ypos := ypos - strhi div 2;
     BlankFrm.Image1.Canvas.Brush.Style := bsClear;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

     // draw target
     ypos := round(vhi * ( (maxval - Target) / (maxval - minval)));
     ypos := ypos + vtop;
     xpos := hleft;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     xpos := hright;
     BlankFrm.Image1.Canvas.Pen.Color := clRed;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     Title := 'TARGET';
     strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
     ypos := ypos - strhi div 2;
     BlankFrm.Image1.Canvas.Brush.Style := bsClear;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

     // draw horizontal axis
     BlankFrm.Image1.Canvas.MoveTo(hleft,vbottom + 20);
     BlankFrm.Image1.Canvas.LineTo(hright,vbottom + 20);
     oldxpos := 0;
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
          if xpos > oldxpos then
          begin
               BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
               oldxpos := xpos + (offset * 2);
          end;
          xpos := 10;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,'GROUPS:');
     end;

     // Draw vertical axis
     valincr := (maxval - minval) / 10.0;
     for i := 1 to 11 do
     begin
          Title := format('%.3f',[maxval - ((i-1)*valincr)]);
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

function TPChartFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
  x: Double;
begin
  Result := false;

  if MeasEdit.Text = '' then
  begin
    AMsg := 'Measurement variable not specified.';
    AControl := MeasEdit;
    exit;
  end;

  if NEdit.Text = '' then
  begin
    AMsg := 'Number of sampled parts is not specified.';
    AControl := NEdit;
    exit;
  end;
  if not TryStrToInt(NEdit.Text, n) then
  begin
    AMsg := 'Number of sampled parts is not valid.';
    AControl := NEdit;
    exit;
  end;

  if PEdit.Text = '' then
  begin
    AMsg := 'Expected proportion of defects is not specified.';
    AControl := PEdit;
    exit;
  end;
  if not TryStrToFloat(PEdit.Text, x) then
  begin
    AMsg := 'Expected proporton of defects is not a valid number.';
    AControl := PEdit;
    exit;
  end;

  if SigmaOpts.ItemIndex = 3 then
  begin
    if XSigmaEdit.Text = '' then
    begin
      AMsg := 'X Sigma is not specified.';
      AControl := XSigmaEdit;
      exit;
    end;
    if not TryStrToFloat(XSigmaEdit.Text, x) then
    begin
      AMsg := 'X Sigma is not a valid number.';
      AControl := XSigmaEdit;
      exit;
    end;
  end;

  Result := true;
end;

initialization
  {$I pchartunit.lrs}

end.

