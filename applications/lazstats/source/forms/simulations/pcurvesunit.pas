unit PCurvesUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  GraphLib, OutputUnit, FunctionsLib, Globals;

type

  { TPCurvesFrm }

  TPCurvesFrm = class(TForm)
    Bevel1: TBevel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    Prob01: TCheckBox;
    Prob025: TCheckBox;
    Prob05: TCheckBox;
    Prob075: TCheckBox;
    Prob10: TCheckBox;
    Prob20: TCheckBox;
    NullEdit: TEdit;
    SDEdit: TEdit;
    NEdit: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  PCurvesFrm: TPCurvesFrm;

implementation

uses
  Math;

{ TPCurvesFrm }

procedure TPCurvesFrm.ResetBtnClick(Sender: TObject);
begin
     Prob01.Checked := false;
     Prob025.Checked := false;
     Prob05.Checked := false;
     Prob075.Checked := false;
     Prob10.Checked := false;
     Prob20.Checked := false;
     NullEdit.Text := '';
     SDEdit.Text := '';
     NEdit.Text := '';
     NullEdit.SetFocus;
end;

procedure TPCurvesFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TPCurvesFrm.ComputeBtnClick(Sender: TObject);
var
  mean, stddev, increment, althyp, power, zbeta, beta, StdErr: double;
  XMax, offset: double;
  N: Integer;
  ii: integer;
  j, NoPlots, SetNo: integer;
  alphas: array[1..6] of double;
  zalphas: array[1..6] of double;
  xalphas: array[1..6] of double;
  XPlotPts: DblDyneMat;
  YPlotPts: DblDyneMat;
  LabelStr, outline: string;
  oldCursor: TCursor;
  lReport: TStrings;
  msg: String;
  C: TWinControl;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOk], 0);
    exit;
  end;

  SetLength(YPlotPts, 6, 80);
  SetLength(XPlotPts, 1, 80);

  XMax := 0.0;
  mean := StrToFloat(NullEdit.Text);
  stddev := StrToFloat(SDEdit.Text);
  N := StrToInt(NEdit.Text);
  StdErr := stddev / sqrt(N);  // standard error of mean;
  increment := 4.0 * StdErr / 80.0;  //scale for 80 points

  // Initialize alternative type I error arrays
  for ii := 1 to 6 do
  begin
    alphas[ii] := 0.0;
    zalphas[ii] := 0.0;
    xalphas[ii] := 0.0;
  end;

  // Get the desired alpha (Beta) curve options
  if Prob01.Checked then alphas[1] := 0.01;
  if Prob025.Checked then alphas[2] := 0.025;
  if Prob05.Checked then alphas[3] := 0.05;
  if Prob075.Checked then alphas[4] := 0.075;
  if Prob10.Checked then  alphas[5] := 0.10;
  if Prob20.Checked then alphas[6] := 0.20;

  msg := 'At least one probability must be selected.';
  for ii := 1 to 6 do
    if alphas[ii] <> 0.0 then
    begin
      msg := '';
      break;
    end;
  if msg <> '' then begin
    Prob01.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  oldCursor := Screen.Cursor;
  Screen.Cursor := TCursor(crHourGlass);
  lReport := TStringList.Create;
  try
    // For curves selected, obtain corresponding z and x values
    for ii := 1 to 6 do
    begin
      if (alphas[ii] <> 0.0) then
      begin
        zalphas[ii] := inversez(1.0 - alphas[ii]);
        xalphas[ii] := (zalphas[ii] * StdErr) + mean;
        if (xalphas[ii] > XMax) then XMax := xalphas[ii];
      end;
    end;

    // For each curve, obtain and plot 80 alternative hypotheses and
    // their corresponding probabilities
    NoPlots := 1;
    for ii := 1 to 6 do // possible curves
    begin
      if (alphas[ii] <> 0.0) then   // curve selected?
      begin
        Offset := 0.0;
        for  j := 1 to 80 do  //get points to plot
        begin
          althyp := mean + Offset;
          zbeta := (xalphas[ii] - althyp ) / StdErr;
          if (abs(zbeta) < 5.0) then
            beta := probz(zbeta)
          else
            beta := 0.0;
          power := 1.0 - beta;
          XPlotPts[0,j-1] := althyp;
          YPlotPts[NoPlots-1,j-1] := power;
          Offset := offset + increment;
        end;
        NoPlots := NoPlots + 1;
      end; // if alphas[i] <> 0
    end; // next curve i

    // Plot the points
    GraphFrm.ShowLeftWall := true;
    GraphFrm.ShowRightWall := true;
    GraphFrm.ShowBottomWall := true;
    GraphFrm.ShowBackWall := true;
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
    GraphFrm.Heading := Format('z-Test Power. Pop. Mean: %.2f, Sigma: %.2f, N: %d', [mean, stddev, N]);
    GraphFrm.XTitle := Format('%.2f x INCREMENT ABOVE HYPOTHESIZED MEAN', [increment]);
    GraphFrm.YTitle := 'PROBABILITIES';
    GraphFrm.nosets := NoPlots-1;
    GraphFrm.nbars := 80;
    GraphFrm.barwideprop := 0.5;
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := 1.0;
    GraphFrm.AutoScaled := false;
    GraphFrm.GraphType := 5; // 2d line charts
    GraphFrm.PtLabels := false;

    SetNo := 1;
    for ii := 1 to 6 do
    begin
      if (alphas[ii] <> 0.0) then
      begin
        LabelStr := Format('%4.2f', [alphas[ii]]);
        GraphFrm.SetLabels[SetNo] := LabelStr;
        SetNo := SetNo + 1;
      end;
    end;
    GraphFrm.Ypoints := YPlotPts;
    GraphFrm.Xpoints := XPlotPts;

    Screen.Cursor := oldCursor;
    GraphFrm.ShowModal;

    lReport.Add('Power of the z-test for Alternate Hypotheses');
    lReport.Add('');
    outline := 'Alpha Levels: ';
    for ii := 1 to 6 do
    begin
      if (alphas[ii] <> 0.0) then
      begin
        LabelStr := Format(' %4.2f  ', [alphas[ii]]);
        outline := outline + LabelStr;
      end;
    end;
    lReport.Add(outline);
    lReport.Add('');

    outline := '';
    for ii := 1 to 80 do
    begin
      outline := Format('X: %8.2f   ', [XPlotPts[0, ii-1]]);
      SetNo := 1;
      for j := 1 to 6 do
      begin
        if (alphas[j] <> 0.0) then
        begin
          outline := outline + Format('%5.3f  ', [YPlotPts[SetNo-1, ii-1]]);
          SetNo := SetNo + 1;
        end;
      end;
      lReport.Add(outline);
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;
    Screen.Cursor := oldCursor;

    XPlotPts := nil;
    YPlotPts := nil;
  end;
end;

procedure TPCurvesFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TPCurvesFrm.FormCreate(Sender: TObject);
begin
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

function TPCurvesFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
  n: Integer;
begin
  Result := false;

  if NullEdit.Text = '' then
  begin
    AMsg := 'Mean must not be empty.';
    AControl := NullEdit;
    exit;
  end;
  if not TryStrToFloat(NullEdit.Text, x) then
  begin
    AMsg := 'No valid number specified for Mean.';
    AControl := NullEdit;
    exit;
  end;

  if SDEdit.Text = '' then
  begin
    AMsg := 'Standard deviation must not be empty.';
    AControl := SDEdit;
    exit;
  end;
  if not TryStrToFloat(SDEdit.Text, x) or (x <= 0) then
  begin
    AMsg := 'Standard deviation must be a positive number.';
    AControl := SDEdit;
    exit;
  end;

  if NEdit.Text = '' then
  begin
    AMsg := 'Sample size not specified.';
    AControl := NEdit;
    exit;
  end;
  if not TryStrToInt(NEdit.Text, n) or (n <= 0) then
  begin
    AMsg := 'Sample size must be a positive integer number.';
    AControl := NEdit;
    exit;
  end;

  Result := true;
end;

initialization
  {$I pcurvesunit.lrs}

end.

