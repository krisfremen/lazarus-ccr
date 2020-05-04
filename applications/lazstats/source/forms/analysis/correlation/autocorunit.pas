// File for testing:
// --- not found (the pdf docs mention "strikes.tab" - but this does not exist.
// -- created test file autocorr.laz

// TODO: Crashes when multiple smoothing options are applied.

unit AutoCorUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, FunctionsLib, OutputUnit, Globals, GraphLib, DataProcs, MatrixLib,
  PointsUnit, DifferenceUnit,
  ContextHelpUnit;

type

  { TAutoCorrFrm }

  TAutoCorrFrm = class(TForm)
    AlphaEdit: TEdit;
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    PlotChk: TCheckBox;
    StatsChk: TCheckBox;
    RMatChk: TCheckBox;
    PartialsChk: TCheckBox;
    YuleWalkerChk: TCheckBox;
    ResidChk: TCheckBox;
    GroupBox5: TGroupBox;
    MaxLagEdit: TEdit;
    InBtn: TBitBtn;
    Label5: TLabel;
    Label6: TLabel;
    OutBtn: TBitBtn;
    DepVarEdit: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    VarList: TListBox;
    MRegSmoothChk: TCheckBox;
    PolyChk: TCheckBox;
    FourierSmoothChk: TCheckBox;
    ExpSmoothChk: TCheckBox;
    MoveAvgChk: TCheckBox;
    DifferenceChk: TCheckBox;
    MeanChk: TCheckBox;
    GroupBox4: TGroupBox;
    Label2: TLabel;
    ProjPtsEdit: TEdit;
    ProjectChk: TCheckBox;
    FromCaseEdit: TEdit;
    GroupBox3: TGroupBox;
    ToCaseEdit: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    ColBtn: TRadioButton;
    AllCasesBtn: TRadioButton;
    OnlyCasesBtn: TRadioButton;
    RowBtn: TRadioButton;
    procedure ColBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure RowBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;

  private
    FExpSmoothAlpha: Double;
    function CalcMean(const pts: DblDyneVec; NoPts: Integer): Double;
    procedure ExponentialSmooth(var Pts: DblDyneVec; NoPts: Integer);
    procedure Four1(var data: DblDyneVec; nn: LongWord; isign: integer);
    procedure Fourier(var data: DblDyneVec; n, npts: integer);
    procedure FourierSmooth(var Pts: DblDyneVec; NoPts: Integer);
    procedure GetPts(var pts: DblDyneVec; var NoPts: Integer; DepVar: Integer);
    procedure MovingAverage(var Pts: DblDyneVec; NoPts: Integer);
    procedure PlotDifferencesForLag(var Pts: DblDyneVec; NoPts: Integer);
    procedure PolyFit(const pts: DblDyneVec; var avg: DblDyneVec; NoPts: integer);
    procedure PolynomialSmooth(var Pts: DblDyneVec; NoPts: Integer);
    procedure RealFT(var data: DblDyneVec; n: LongWord; isign: integer);
    procedure RemoveMeans(var Pts: DblDyneVec; NoPts: Integer; AMean: Double);

  public
    { public declarations }
  end; 

var
  AutoCorrFrm: TAutoCorrFrm;

implementation

uses
  Math,
  MoveAvgUnit, AutoPlotUnit, PolynomialUnit, ExpSmoothUnit, FFTUnit;

{ TAutoCorrFrm }

procedure TAutoCorrFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  DepVarEdit.Text := '';
  MaxLagEdit.Text := '30';
  StatsChk.Checked := false;
  RmatChk.Checked := false;
  PartialsChk.Checked := false;
  PlotChk.Checked := true;
  ResidChk.Checked := false;
  DifferenceChk.Checked := false;
  PolyChk.Checked := false;
  MeanChk.Checked := false;
  MoveAvgChk.Checked := false;
  ExpSmoothChk.Checked := false;
  FourierSmoothChk.Checked := false;
  YuleWalkerChk.Checked := false;
  FromCaseEdit.Text := '';
  ToCaseEdit.Text := '';
  AllCasesBtn.Checked := true;
  AlphaEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  ProjPtsEdit.Text := '';
  if ColBtn.Checked then
    for i := 1 to OS3MainFrm.DataGrid.ColCount - 1 do
      VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0])
  else
    for i := 1 to NoCases do
    begin
      if IsFiltered(i) then continue;
      VarList.Items.Add(OS3MainFrm.DataGrid.Cells[0,i]);
    end;
  FExpSmoothAlpha := 0.99;
  UpdateBtnStates;
end;

procedure TAutoCorrFrm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TAutoCorrFrm.RowBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  for i := 1 to NoCases do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[0,i]);
  GroupBox2.Caption := 'Include Columns:';
  AllCasesBtn.Caption := 'All Variables';
  OnlyCasesBtn.Caption := 'Only Columns From:';
end;

procedure TAutoCorrFrm.FormActivate(Sender: TObject);
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

  Panel1.Constraints.MinWidth := GroupBox2.Left + GroupBox2.Width - Panel1.Left;
  Panel1.Constraints.MinHeight := Panel2.Top + Panel2.Height - Panel1.Top;

  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
  Constraints.MaxWidth := Width;

  FAutoSized := true;
end;

procedure TAutoCorrFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if PointsFrm = nil then Application.CreateForm(TPointsFrm, PointsFrm);
  FExpSmoothAlpha := 0.99;
end;

procedure TAutoCorrFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TAutoCorrFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TAutoCorrFrm.ComputeBtnClick(Sender: TObject);
var
  X, Y, count, covzero, mean: double;
  uplimit, lowlimit, varresid, StdErr, lAlpha: double;
  NoPts, DepVar, maxlag, lag, noproj: integer;
  i, j, k, ncors, npoints: integer;
  Means, StdDevs, PartCors, residual, betas, rxy, pts, avg: DblDyneVec;
  correlations, a: DblDyneMat;
  RowLabels, ColLabels: StrDyneVec;
  Title: string;
  r, vx, vy, sx, sy, mx, my, UCL, LCL, Yhat, Constant: double;
  ColNoSelected: IntDyneVec;
  NoSelected: integer;
  zconf, samptrans: double;
  confidence: double;
  lReport: TStrings;
begin
  SetLength(ColNoSelected, NoVariables);
  if ColBtn.Checked then
  begin
    // get column of the selected variable
    DepVar := 0;
    for i := 1 to NoVariables do
      if (OS3MainFrm.DataGrid.Cells[i,0] = DepVarEdit.Text) then DepVar := i;
    if (DepVar = 0)then
    begin
      MessageDlg('No variable selected to analyze.', mtError, [mbOK], 0);
      exit;
    end;
    ColNoSelected[0] := DepVar;
    NoSelected := 1;

    // get no. of valid points
    NoPts := 0;
    for i := 1 to NoCases do
      if ValidValue(i,DepVar) then NoPts := NoPts + 1;
  end else
  begin // get row of the selected case
    DepVar := 0;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, NoSelected, ColNoSelected) then continue;
      if (OS3MainFrm.DataGrid.Cells[0,i] = DepVarEdit.Text) then DepVar := i;
    end;
    if (DepVar = 0)then
    begin
      MessageDlg('No variable selected to analyze.', mtError,[mbOK], 0);
      exit;
    end;
    ColNoSelected[0] := DepVar;
    NoSelected := 1;
    NoPts := NoVariables;
  end;

  // Get the alpha level and the maximum lag values
  if AlphaEdit.Text = '' then
  begin
    AlphaEdit.Setfocus;
    MessageDlg('Alpha level is not specified.', mtError, [mbOK], 0);
    exit;
  end;
  if TryStrToFloat(AlphaEdit.Text, lAlpha) and (lAlpha > 0) and (lAlpha < 1) then
    lAlpha := 1.0 - lAlpha
  else
  begin
    AlphaEdit.SetFocus;
    MessageDlg('Alpha level must be a valid number between 0 and 1.', mtError, [mbOK], 0);
    exit;
  end;

  if MaxLagEdit.Text = '' then
  begin
    MaxLagEdit.SetFocus;
    MessageDlg('Input required.', mtError, [mbOK], 0);
    exit;
  end;
  if TryStrToInt(MaxLagEdit.Text, maxlag) then
  begin
    if maxlag > NoPts div 2 then
      maxlag := NoPts div 2;
    if StrToInt(MaxLagEdit.Text) > maxlag then
      MaxLagEdit.Text := IntToStr(maxlag);
    nPoints := maxlag + 2;
  end else
  begin
    MaxLagEdit.SetFocus;
    MessageDlg('Valid number required.', mtError, [mbOK], 0);
    exit;
  end;
                          {
  maxlag := StrToInt(MaxLagEdit.Text);
  if maxlag > NoPts div 2 then
    maxlag := NoPts div 2;
  if StrToInt(MaxLagEdit.Text) > maxlag then
    MaxLagEdit.Text := IntToStr(maxlag);
  npoints := maxlag + 2;   }

  noProj := 0;
  if ProjectChk.Checked then
  begin
    if ProjPtsEdit.Text = '' then
    begin
      ProjPtsEdit.SetFocus;
      MessageDlg('Projection points not specified', mtError, [mbOK], 0);
      exit;
    end;
    if not TryStrToInt(ProjPtsEdit.Text, noProj) or (noProj < 0) then
    begin
      ProjPtsEdit.SetFocus;
      MessageDlg('Valid positive number required.', mtError, [mbOK], 0);
      exit;
    end;
    noproj := StrToInt(ProjPtsEdit.Text)
  end;

  // allocate space for covariance and correlation matrices, etc.
  SetLength(correlations, npoints+1, npoints+1);
  SetLength(Means, npoints);
  SetLength(StdDevs, npoints);
  SetLength(RowLabels, npoints);
  SetLength(ColLabels, npoints);
  SetLength(PartCors, npoints);
  SetLength(a, npoints, npoints);
  SetLength(betas, npoints);
  SetLength(rxy, npoints);
  SetLength(pts, NoPts+noproj+10);
  SetLength(avg, NoPts+noproj+10);
  SetLength(residual, NoPts+noproj+10);

  lReport := TStringList.Create;
  try
  // Initialize arrays
    for i := 0 to npoints-1 do
    begin
      for j := 0 to npoints - 1 do
      begin
        correlations[i,j] := 0.0;
        a[i,j] := 0.0;
      end;
      Means[i] := 0.0;
      StdDevs[i] := 0.0;
      RowLabels[i] := 'Lag ' + IntToStr(i);
      ColLabels[i] := RowLabels[i];
      PartCors[i] := 0.0;
      betas[i] := 0.0;
    end;

    uplimit := 0.0;
    lowlimit := 0.0;
    covzero := 0.0;

    // Get points to analyze
    GetPts(pts, noPts, DepVar);
    if noPts = 0 then
    begin
      MessageDlg('No data points found.', mtError, [mbOk], 0);
      exit;
    end;
    count := NoPts;

    // Calculate mean of all values
    mean := CalcMean(pts, NoPts);

    // Remove mean from all observations if elected
    if MeanChk.Checked then
      RemoveMeans(pts, noPts, mean);

    correlations[0,0] := 1.0;

    // Get differences for lag specified
    if DifferenceChk.Checked then
      PlotDifferencesForLag(Pts, NoPts);

    // Get moving average if checked
    if MoveAvgChk.Checked then
      MovingAverage(Pts, NoPts);

    // Do exponential smoothing if requested
    if ExpSmoothChk.Checked then
      ExponentialSmooth(pts, NoPts);

    // Fast Fourier smoothing, if requested
    if FourierSmoothChk.Checked then
      FourierSmooth(pts, NoPts);

    // Get polynomial regression fit if elected
    if PolyChk.Checked then
      PolynomialSmooth(pts, NoPts);

    // get mean and variance of (transformed?) points
    mean := 0.0;
    for i := 0 to NoPts - 1 do
      mean := mean + pts[i];
    mean := mean / NoPts;
    for i := 0 to NoPts-1 do
      if MeanChk.Checked then
        covzero := covzero + sqr(pts[i])
      else
        covzero := covzero + sqr(pts[i] - mean);
    covzero := covzero / NoPts;

    // get correlations for each lag 0 to maxlag
    if StatsChk.Checked then
    begin
      lReport.Add('Overall mean: %8.3f', [mean]);
      lReport.Add('Variance:     %8.3f', [covzero]);
      lReport.Add('');

      lReport.Add(' Lag     Rxy      MeanX     MeanY   Std.Dev.X   Std.Dev.Y    Cases      LCL       UCL   ');
      lReport.Add('-----  --------  --------  --------  ----------  ----------  --------  --------  --------');
    end;

    confidence := StrToFloat(AlphaEdit.Text);
    ncors := 0;
    if maxlag > NoPts - 3 then
    begin
      maxlag := NoPts - 3;
      maxlagedit.Text := IntToStr(maxlag);
    end;

    for lag := 0 to maxlag do
    begin
      r := 0.0;
      vx := 0.0;
      vy := 0.0;
      mx := 0.0;
      my := 0.0;
      Count := 0.0;
//      lagvalue[lag] := lag;
      for i := 1 to (NoPts - lag) do
      begin
        X := pts[i-1];
        Y := pts[i-1+lag];
        if MeanChk.Checked then
          r := r + X * Y
        else
          r := r + (X - mean) * (Y - mean);
        vx := vx + sqr(X);
        vy := vy + sqr(Y);
        mx := mx + X;
        my := my + Y;
        Count := Count + 1.0;
      end;
      r := r / NoPts;
      vx := vx - sqr(mx) / Count;
      vx := vx / (Count - 1.0);
      sx := sqrt(vx);

      vy := vy - sqr(my) / Count;
      vy := vy / (Count - 1.0);
      sy := sqrt(vy);

      mx := mx / Count;
      my := my / Count;
      r := r / covzero;
      if (abs(r) < 1.0) then
        samptrans := ln((1.0 + r) / (1.0 - r)) / 2.0;
      stdErr := sqrt(1.0 / (NoPts - 3.0));
      zconf := abs(InverseZ(confidence * 0.5));
      if (abs(r) < 1.0) then
      begin
        //z := samptrans / StdErr;
        UCL := samptrans + zconf * StdErr;
        LCL := samptrans - zconf * StdErr;
        UCL := (exp(2.0 * UCL) - 1.0) / (exp(2.0 * UCL) + 1.0);
        LCL := (exp(2.0 * LCL) - 1.0) / (exp(2.0 * LCL) + 1.0);
      end else
      begin
        UCL := 1.0;
        LCL := 1.0;
      end;
      if StatsChk.Checked then
        lReport.Add('%4d %9.4f %9.4f %9.4f %11.4f %11.4f %9.0f %9.4f %9.4f',
          [lag, r, mx, my, sx, sy, Count, LCL, UCL]
        );
      ncors := ncors + 1;
      correlations[0,lag] := r;
      correlations[lag,0] := r;
    end; // next lag

    // build correlation matrix
    for i := 0 to maxlag do
      correlations[i,i] := 1.0;
    for i := 1 to maxlag do
      for j := i+1 to maxlag do
      begin
        correlations[i,j] := correlations[0,j-i];
        correlations[j,i] := correlations[i,j];
      end;

    // Print the correlation matrix if elected
    if RmatChk.Checked then
    begin
      if lReport.Count > 0 then
      begin
        lReport.Add('');
        lReport.Add(DIVIDER);
        lReport.Add('');
      end;
      Title := 'Matrix of Lagged Variable: ' + DepVarEdit.Text;
      MatPrint(correlations, maxlag+1, maxlag+1, Title, RowLabels, ColLabels, NoPts, lReport);
    end;

    // Calculate partial correlations
    PartCors[0] := 1.0;
    for i := 1 to  maxlag do // start at lag 1
    begin
      for j := 1 to i do
      begin
        for k := 1 to i do
          a[j-1,k-1] := correlations[j,k];
        rxy[j-1] := correlations[0,j];
      end;

      SVDinverse(a, i);

      // get betas as product of inverse times vector
      for j := 1 to i do
      begin
        betas[j-1] := 0.0;
        for k := 1 to i do
          betas[j-1] := betas[j-1] + (a[j-1,k-1] * rxy[k-1]);
      end;

      // get regression constant
      // Note - since variance of Y and each X is the same, B = beta for an X
      Constant := 0;
      if not MeanChk.Checked then
      begin
        for j := 1 to i do
          Constant := Constant + betas[j-1] * Mean;
        Constant := Mean - Constant;
      end;

      // calculate predicted value and residual
      // Note - the dependent variable predicted is the next value in the
      // time series using each of the previous time period values
      Yhat := 0.0;
      for j := 0 to i-1 do
        Yhat := Yhat + (betas[j] * pts[j]);
      Yhat := Yhat + Constant;
      avg[i] := Yhat;
      residual[i] := pts[i] - Yhat;

      // print betas if elected
      if YuleWalkerChk.Checked then
      begin
        if lReport.Count > 0 then
        begin
          lReport.Add('');
          if i = 1 then lReport.Add(DIVIDER) else lReport.Add(DIVIDER_SMALL);
          lReport.Add('');
        end;
        Title := 'Yule-Walker Coefficients for lag ' + IntToStr(i);
        DynVectorPrint(betas, i, Title, ColLabels, NoPts, lReport);
        lReport.Add('Constant: %10.3f', [Constant]);
      end;

      PartCors[i] := betas[i-1];
    end; // next i (lag from 1 to maxlag)

    // print partial correlations if elected
    if PartialsChk.Checked then
    begin
      if lReport.Count > 0 then
      begin
        lReport.Add('');
        lReport.Add(DIVIDER);
        lReport.Add('');
      end;
      Title := 'Partial Correlation Coefficients';
      DynVectorPrint(PartCors, maxlag, Title, ColLabels, NoPts, lReport);
    end;

    // plot correlations if elected
    uplimit := 1.96 * (1.0 / sqrt(count));
    lowlimit := -1.96 * (1.0 / sqrt(count));
    if PlotChk.Checked then
    begin
      if AutoPlotFrm = nil then
        Application.CreateForm(TAutoPlotFrm, AutoPlotFrm);
      for i := 0 to maxlag do
        rxy[i] := correlations[0][i];
      AutoPlotFrm.PlotPartCors := true;
      AutoPlotFrm.PlotLimits := true;
      AutoPlotFrm.correlations := rxy;
      AutoPlotFrm.partcors := PartCors;
      AutoPlotFrm.uplimit := uplimit;
      AutoPlotFrm.lowlimit := lowlimit;
      AutoPlotFrm.npoints := maxlag+1;
      AutoPlotFrm.DepVarEdit := DepVarEdit.Text;
      AutoPlotFrm.ShowModal;
    end;

    if MRegSmoothChk.Checked then
    begin
      // calculate predicted values and residuals for remaining points
      // Note - the dependent variable predicted is the next value in
      // the time series using each of the previous time period values
      // as predictors
      for i := maxlag to (NoPts + noproj - 1) do
      begin
        Yhat := 0.0;
        for j := 0 to maxlag do
          Yhat := Yhat + (betas[j] * pts[i-maxlag+j]);
        Yhat := Yhat + Constant;
        avg[i] := Yhat;
        residual[i] := pts[i] - Yhat;
      end;

      // plot points smoothed by autoregression
      avg[0] := pts[0];
      PointsFrm.pts := pts;
      PointsFrm.avg := avg;
      PointsFrm.NoCases := NoPts + noproj;
      PointsFrm.LabelOne := 'Original';
      PointsFrm.LabelTwo := 'Smoothed';
      PointsFrm.Title := 'Autoregressive Smoothed';
      PointsFrm.Caption := 'Autoregression Smoothing';
      PointsFrm.ShowModal;

      // plot residuals if elected
      if ResidChk.Checked then
      begin
        varresid := 0.0;
        residual[0] := 0.0;
        for i := 1 to maxlag do
          varresid := varresid + sqr(residual[i]);
        varresid := varresid / maxlag;
        StdErr := sqrt(varresid);

        // plot the residuals
        PointsFrm.pts := pts;
        PointsFrm.avg := residual;
        PointsFrm.NoCases := NoPts;
        PointsFrm.MsgEdit.Text := 'Std. Err. Residuals: ' + FloatToStr(StdErr);
        PointsFrm.LabelOne := 'Original';
        PointsFrm.LabelTwo := 'Residuals';
        PointsFrm.Title := 'Residuals from Autoregression Smoothing';
        PointsFrm.Caption := 'Autoregressive Residuals';
        PointsFrm.ShowModal;
      end;
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;

    residual := nil;
    avg := nil;
    pts := nil;
    rxy := nil;
    betas := nil;
    a := nil;
    PartCors := nil;
    ColLabels := nil;
    RowLabels := nil;
    StdDevs := nil;
    Means := nil;
    correlations := nil;
    ColNoSelected := nil;
  end;
end;

procedure TAutoCorrFrm.ColBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  for i := 1 to OS3MainFrm.DataGrid.ColCount - 1 do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  GroupBox2.Caption := 'Include Cases:';
  AllCasesBtn.Caption := 'All Cases';
  OnlyCasesBtn.Caption := 'Only Cases From:';
end;

procedure TAutoCorrFrm.InBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepVarEdit.Text = '') then
  begin
    DepVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TAutoCorrFrm.OutBtnClick(Sender: TObject);
begin
  if DepVarEdit.Text <> '' then
  begin
    VarList.Items.Add(DepVarEdit.Text);
    DepVarEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TAutoCorrFrm.Four1(var data: DblDyneVec; nn: longword; isign: integer);
var
  n, mmax, m, j, istep, i: longword;
  wtemp, wr, wpr, wpi, wi, theta: double;
  tempr, tempi: double;
begin
  n := 2 * nn;
  j := 1;
  i := 1;
  while i < n do
  begin
    if (j > i) then
    begin
      tempr := data[j];
      tempi := data[j+1];
      data[j] := data[i];
      data[j+1] := data[i+1];
      data[i] := tempr;
      data[i+1] := tempi;
    end;
    m := n div 2;
    while (m >= 2) and (j > m) do
    begin
      j := j - m;
      m := m div 2;
    end;
    j := j + m;
    i := i + 2;
  end;
  mmax := 2;
  while (n > mmax) do
  begin
    istep := 2 * mmax;
    theta := isign * TWO_PI / mmax;
    wtemp := sin(0.5 * theta);
    wpr := -2.0 * wtemp * wtemp;
    wpi := sin(theta);
    wr := 1.0;
    wi := 0.0;
    m := 1;
    while m < mmax do
    begin
      i := m;
      while i <= n do
      begin
        j := i + mmax;
	tempr := wr * data[j] - wi * data[j+1];
	tempi := wr * data[j+1] + wi * data[j];
	data[j] := data[i] - tempr;
	data[j+1] := data[i+1] - tempi;
	data[i] := data[i] + tempr;
	data[i+1] := data[i+1] + tempi;
        i := i + istep;
      end;
      wtemp := wr;
      wr := wr * wpr - wi * wpi + wr;
      wi := wi * wpr + wtemp * wpi + wi;
      m := m + 2;
    end;
    mmax := istep;
  end;
end;

procedure TAutoCorrFrm.RealFt(var data: DblDyneVec; n: longword; isign: integer);
var
  i,i1,i2,i3,i4,np3 : integer;  // was: longword;
  c1,c2,h1r,h1i,h2r,h2i : double;
  wr,wi,wpr,wpi,wtemp,theta : double;
begin
  c1 := 0.5;
  theta := PI / ( n div 2);
  if (isign = 1) then
  begin
    c2 := -0.5;
    Four1(data, n div 2, 1);
  end else
  begin
    c2 := 0.5;
    theta := -theta;
  end;
  wtemp := sin(0.5 * theta);
  wpr := -2.0 * wtemp * wtemp;
  wpi := sin(theta);
  wr := 1.0 + wpr;
  wi := wpi;
  np3 := n + 3;
  for i := 2 to n div 2 do
  begin
    i1 := i + i - 1;
    i2 := 1 + i1;
    i3 := np3 - i2;
    i4 := 1 + i3;
    h1r := c1 * (data[i1] + data[i3]);
    h1i := c1 * (data[i2] - data[i4]);
    h2r := -c2 * (data[i2] + data[i4]);
    h2i := c2 * (data[i1] - data[i3]);
    data[i1] := h1r + wr * h2r - wi * h2i;
    data[i2] := h1i + wr * h2i + wi * h2r;
    data[i3] := h1r - wr * h2r + wi * h2i;
    data[i4] := -h1i + wr * h2i + wi * h2r;
    wtemp := wr;
    wr := wtemp * wpr - wi * wpi + wr;
    wi := wi * wpr + wtemp * wpi + wi;
  end;

  if (isign = 1) then
  begin
    h1r := data[1];
    data[1] := h1r + data[2];
    data[2] := h1r - data[2];
  end else
  begin
    h1r := data[1];
    data[1] := c1 * (h1r + data[2]);
    data[2] := c1 * (h1r - data[2]);
    Four1(data,n div 2,-1);
  end;
end;

procedure TAutoCorrFrm.Fourier(var data: DblDyneVec; n, npts: integer);
var
  nmin, m, mo2, i, k, j: integer;
  yn, y1, rn1, fac, cnst: double;
  y: DblDyneVec;
begin
  m := 2;
  nmin := n + 2*npts;
  while (m < nmin) do m := m * 2;

  cnst := sqr(npts / m);

  SetLength(y, m+1);
  for i := 0 to n - 1 do
    y[i+1] := data[i];
  y1 := y[1];
  yn := y[n];
  rn1 := 1.0 / (n - 1);
  for j := 1 to n do
    y[j] := y[j] + (-rn1 * (y1 * (n - j) + y1 * (j - 1)));
  for j := n+1 to m do
    y[j] := 0.0;
  mo2 := m div 2;

  RealFT(y, mo2, 1);

  y[1] := y[1] / mo2;
  fac := 1.0;
  for j := 1 to mo2 - 1 do
  begin
    k := 2 * j + 1;
    if (fac <> 0) then
    begin
      fac := (1.0 - cnst * j * j) / mo2;
      if (fac < 0.0) then fac := 0.0;
      y[k] := fac * y[k];
      y[k + 1] := fac * y[k + 1];
    end
    else
      y[k + 1] := 0.0;
    y[k] := 0.0;
  end;

  fac := (1.0 - 0.25 * npts * npts) / mo2;
  if (fac < 0.0) then fac := 0.0;
  y[2] := y[2] * fac;

  RealFT(y,mo2,-1);

  for j := 1 to n do
    y[j] := y[j] + rn1 * (y1 * (n - j) + yn * (j - 1));
  for j := 0 to n - 1 do
    data[j] := y[j+1];

  y := nil;
end;

procedure TAutoCorrFrm.PolyFit(const pts: DblDyneVec; var avg: DblDyneVec;
  NoPts: integer);
var
  X: DblDyneMat;
  XY: DblDyneVec;
  XTX: DblDyneMat;
  Beta: DblDyneVec;
  t, Yhat: double;
  i, j, k, order: integer;
  RowLabels, ColLabels: StrDyneVec;
begin
  order := StrToInt(PolynomialFrm.PolyEdit.Text);
  SetLength(X,NoPts,order+1);
  SetLength(XTX,order+2,order+2);
  SetLength(XY,order+1);
  SetLength(Beta,order+1);
  SetLength(RowLabels,NoPts+1);
  SetLength(ColLabels,NoPts+1);

  // initialize
  for i := 0 to NoPts - 1 do
    for j := 0 to order do
      X[i,j] := 0.0;

  for i := 0 to order do
  begin
    XY[i] := 0.0;
    Beta[i] := 0.0;
    for j := 0 to order do
      XTX[i,j] := 0.0;
  end;

  for i := 0 to NoPts - 1 do
    for j := 0 to order do
    begin
      t := i+1;
      X[i,j] := Power(t,j);
    end;

  // print the X matrix as a check
  for i := 0 to NoPts - 1 do
    RowLabels[i] := 'Case' + IntToStr(i+1);

  for i := 0 to order+1 do
    ColLabels[i] := 'Order' + IntToStr(i);

  {
    OutputFrm.RichEdit.Clear;
    Title := 'X Matrix';
    DynMatPrint(X,NoPts,order+1,Title,RowLabels,ColLabels,NoPts);
    OutputFrm.ShowModal;
}
  // Get X transpose times X
  for j := 0 to order do
  begin
    for k := 0 to order do
    begin
      XTX[j,k] := 0.0;
      for i := 0 to NoPts - 1 do
        XTX[j,k] := XTX[j,k] + (X[i,j] * X[i,k]);
    end;
  end;
{
    // print the XTX matrix
    OutputFrm.RichEdit.Clear;
    Title := 'XTX Matrix (Offset by 1)';
    DynMatPrint(XTX,order+2,order+2,Title,ColLabels,ColLabels,NoPts);
    OutputFrm.ShowModal;
}
  // Get X transpose Y
  for j := 0 to order do
    for i := 0 to NoPts - 1 do
      XY[j] := XY[j] + (X[i,j] * pts[i]);
{
    // print the XY vector
    OutputFrm.RichEdit.Clear;
    Title := 'XY vector';
    DynVectorPrint(XY,order+1,Title,ColLabels,NoPts);
    OutputFrm.ShowModal;
}
  // get inverse of XTX
  SVDinverse(XTX, order+1);
{
    // print the inverse matrix
    OutputFrm.RichEdit.Clear;
    Title := 'XTX Inverse Matrix';
    DynMatPrint(XTX,order+2,order+2,Title,ColLabels,ColLabels,NoPts);
    OutputFrm.ShowModal;
}
  // get betas
  for j := 0 to order do
    for k := 0 to order do
      Beta[j] := Beta[j] + (XTX[j,k] * XY[k]);

  {
    // print the betas
    OutputFrm.RichEdit.Clear;
    Title := 'Betas vector';
    DynVectorPrint(Beta,order+1,Title,ColLabels,NoPts);
    OutputFrm.ShowModal;
}
  // get predicted values
  for i := 0 to NoPts - 1 do
  begin
    Yhat := 0.0;
    t := i;
    for j := 0 to order do
      Yhat := Yhat + (Beta[j] * Power(t,j));
    avg[i] := Yhat;
  end;

  //cleanup
  ColLabels := nil;
  RowLabels := nil;
  Beta := nil;
  XY := nil;
  XTX := nil;
  X := nil;
end;

procedure TAutoCorrFrm.UpdateBtnStates;
begin
  InBtn.Enabled := (VarList.ItemIndex > -1) and (DepVarEdit.Text = '');
  OutBtn.Enabled := (DepVarEdit.Text <> '');
end;

procedure TAutoCorrFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


{ Routines called from ComputeBtnClick }

function TAutoCorrFrm.CalcMean(const Pts: DblDyneVec; NoPts: Integer): Double;
var
  i: Integer;
begin
  Result := 0.0;
  for i := 0 to NoPts-1 do
    Result := Result + Pts[i];
  Result := Result / NoPts;
end;

procedure TAutoCorrFrm.ExponentialSmooth(var Pts: DblDyneVec; NoPts: Integer);
var
  F: TExpSmoothFrm;
  noProj: Integer;
  avg: DblDyneVec;
  residual: DblDyneVec;
  i: Integer;
  varRes: Double;
  stdErr: Double;
begin
  F := TExpSmoothFrm.Create(nil);
  try
    F.Alpha := FExpSmoothAlpha;
    if F.ShowModal <> mrOK then
      exit;

    FExpSmoothAlpha := F.Alpha;

    if ProjectChk.Checked then
      noProj := StrToInt(ProjPtsEdit.Text)
    else
      noProj := 0;

    SetLength(avg, NoPts + noProj);
    avg[0] := pts[0];   // set first value = to observed
    for i := 1 to NoPts - 1 do // case pointer
      avg[i] := FExpSmoothAlpha * pts[i] + (1.0 - FExpSmoothAlpha) * avg[i-1];

    if ProjectChk.Checked then
    begin
      for i := 0 to noproj-1 do
      begin
        avg[NoPts + i] := FExpSmoothAlpha * pts[NoPts + i - 1];
        avg[NoPts + i] := avg[NoPts + i] + (1.0 - FExpSmoothAlpha) * avg[NoPts + i - 1];
        pts[NoPts + i] := avg[NoPts + i];
      end;
    end;

    // plot the points
    PointsFrm.pts := pts;
    PointsFrm.avg := avg;
    PointsFrm.NoCases := NoPts + noproj;
    PointsFrm.LabelOne := 'Original';
    PointsFrm.LabelTwo := 'Smoothed';
    PointsFrm.Title := 'Exponential Smoothed';
    PointsFrm.Caption := 'Exponential Smoothing';
    PointsFrm.ShowModal;

    if ResidChk.Checked then // calculate and plot residuals;
    begin
      SetLength(residual, NoPts);
      varRes := 0.0;
      for i := 0 to NoPts - 1 do
      begin
        residual[i] := pts[i] - avg[i];
        varRes := varRes + sqr(residual[i]);
      end;
      varRes := varRes / NoPts;
      StdErr := sqrt(varRes);

      // plot the residuals
      PointsFrm.pts := pts;
      PointsFrm.avg := residual;
      PointsFrm.NoCases := NoPts;
      PointsFrm.MsgEdit.Text := 'Std. Err. Residuals: ' + FloatToStr(StdErr);
      PointsFrm.LabelOne := 'Original';
      PointsFrm.LabelTwo := 'Residuals';
      PointsFrm.Title := 'Residuals from Exponential Smoothing';
      PointsFrm.Caption := 'Exponential Residuals';
      PointsFrm.ShowModal;
    end;

    // replace original points with smoothed values
    for i := 0 to (NoPts + noproj - 1) do
      pts[i] := avg[i];

  finally
    F.Free;
  end;
end;

procedure TAutoCorrFrm.FourierSmooth(var Pts: DblDyneVec; NoPts: Integer);
var
  F: TFFTFrm;
  avg: DblDyneVec;
  residual: DblDyneVec;
  NValues: Integer;
  i: Integer;
  noProj: Integer;
  varRes: double;
  stdErr: Double;
begin
  if ProjectChk.Checked then
    noProj := StrToInt(ProjPtsEdit.Text)
  else
    noProj := 0;
  NValues := NoPts + noProj + 1;

  F := TFFtFrm.Create(nil);
  try
    F.NptsEdit.Text := IntToStr(NValues);
    if F.ShowModal <> mrOK then
      exit;

    SetLength(avg, NoPts + noProj);
    if ProjectChk.Checked then
    begin
      for i := 0 to noproj - 1 do
      begin
        avg[i] := pts[NoPts-1-noproj+i];
        pts[i] := avg[i];
      end;
    end;

    Fourier(avg, NValues, NValues);

    PointsFrm.pts := pts;
    PointsFrm.avg := avg;
    PointsFrm.NoCases := NoPts + noproj;
    PointsFrm.LabelOne := 'Original';
    PointsFrm.LabelTwo := 'Smoothed';
    PointsFrm.Title := 'Fourier Smoothed';
    PointsFrm.Caption := 'Fourier Smoothing';
    PointsFrm.ShowModal;

    // calculate and plot residuals;
    if ResidChk.Checked then
    begin
      SetLength(residual, NoPts);
      varRes := 0.0;
      for i := 0 to NoPts - 1 do
      begin
        residual[i] := pts[i] - avg[i];
        varRes := varRes + sqr(residual[i]);
      end;
      varRes := varRes / NoPts;
      stdErr := sqrt(varRes);

      // plot the residuals
      PointsFrm.pts := pts;
      PointsFrm.avg := residual;
      PointsFrm.NoCases := NoPts;
      PointsFrm.MsgEdit.Text := 'Std. Err. Residuals: ' + FloatToStr(StdErr);
      PointsFrm.LabelOne := 'Original';
      PointsFrm.LabelTwo := 'Residuals';
      PointsFrm.Title := 'Residuals from Fourier Smoothing';
      PointsFrm.Caption := 'Fourier Residuals';
      PointsFrm.ShowModal;
    end;

    // replace original points with smoothed values
    for i := 0 to (NoPts + noproj - 1) do pts[i] := avg[i];

  finally
    F.Free;
  end;
end;

procedure TAutoCorrFrm.GetPts(var Pts: DblDyneVec; var NoPts: Integer;
  Depvar: Integer);
var
  i: Integer;
begin
  if ColBtn.Checked then
  begin
    if AllCasesBtn.Checked then
    begin
      for i := 1 to NoPts do
        if ValidValue(i, DepVar) then
          Pts[i-1] := StrToFloat(OS3MainFrm.DataGrid.Cells[DepVar, i])
        else
          Pts[i-1] := NaN;  // wp: added thid for defined crash because of undefined values
    end else
    begin
      NoPts := 0;
      for i := StrToInt(FromCaseEdit.Text) to StrToInt(ToCaseEdit.Text) do
      begin
        if  ValidValue(i, DepVar) then continue;
        Pts[NoPts] := StrToFloat(OS3MainFrm.DataGrid.Cells[DepVar, i]);
        NoPts := NoPts + 1;
      end;
    end;
  end else
  begin
    // row button selected
    if AllCasesBtn.Checked then
    begin
      for i := 1 to NoPts do
        if ValidValue(DepVar, i) then
          Pts[i-1] := StrToFloat(OS3MainFrm.DataGrid.Cells[i, DepVar])
        else
          Pts[i-1] := NaN;  // wp: added thid for defined crash because of undefined values
    end else
    begin
      NoPts := 0;
      for i := StrToInt(FromCaseEdit.Text) to StrToInt(ToCaseEdit.Text) do
      begin
        if not ValidValue(DepVar,i) then continue;
        pts[NoPts] := StrToFloat(OS3MainFrm.DataGrid.Cells[i,DepVar]);
        NoPts := NoPts + 1;
      end;
    end;
  end;
end;

procedure TAutoCorrFrm.MovingAverage(var Pts: DblDyneVec; NoPts: Integer);
var
  F: TMoveAvgFrm;
  i, j: Integer;
  nValues: Integer;
  avg: DblDyneVec;
  residual: DblDyneVec;
  noProj: Integer;
  varRes: Double;
  stdErr: Double;
begin
  F := TMoveAvgFrm.Create(nil);
  try
    if F.ShowModal <> mrOK then
      exit;
    nValues := F.Order;
    if nValues <= 0 then
      exit;

    if ProjectChk.Checked then
      noProj := StrToInt(ProjPtsEdit.Text)
    else
      noProj := 0;

    // Calculate moving average
    SetLength(avg, NoPts + NoProj);
    for i := nValues to NoPts - nValues - 1 do
    begin
      avg[i] := Pts[i] * F.W[0]; // middle value
      for j := 1 to nValues do
        avg[i] := avg[i] + Pts[i-j] * F.W[j] + Pts[i+j] * F.W[j];
                            // left values       right values
    end;

    // fill in unestimable averages with original points
    for i := 0 to nValues - 1 do  // left values
    begin
      avg[i] := pts[i] * F.W[0];
      for j := 1 to nvalues do
        avg[i] := avg[i] + (pts[i+j] * 2.0 * F.W[j]);
    end;
    for i := NoPts - nValues to NoPts - 1 do   //right values
    begin
      avg[i] := pts[i] * F.W[0];
      for j := 1 to nvalues do
        avg[i] := avg[i] + (pts[i-j] * 2.0 * F.W[j]);
    end;

    if ProjectChk.Checked then
    begin
      noProj := StrToInt(ProjPtsEdit.Text);
      for i := 0 to NoProj-1 do
      begin
        avg[NoPts + i] := avg[NoPts - 1];
        pts[NoPts + i] := pts[NoPts - 1];
      end;
    end;

    // plot the original points and the smoothed average
    PointsFrm.pts := pts;
    PointsFrm.avg := avg;
    PointsFrm.NoCases := NoPts + noProj;
    PointsFrm.LabelOne := 'Original';
    PointsFrm.LabelTwo := 'Smoothed';
    PointsFrm.MsgEdit.Text := 'No. points: '+ IntToStr(NoPts);
    PointsFrm.Title := 'Moving Average Smoothed';
    PointsFrm.Caption := 'Moving Average Smoothing';
    PointsFrm.ShowModal;

    // calculate and plot residuals;
    if ResidChk.Checked then
    begin
      SetLength(residual, NoPts);
      varRes := 0.0;
      for i := 0 to NoPts - 1 do
      begin
        residual[i] := pts[i] - avg[i];
        varRes := varRes + sqr(residual[i]);
      end;
      varRes := varRes / NoPts;
      stdErr := sqrt(varRes);

      // plot the residuals
      PointsFrm.pts := pts;
      PointsFrm.avg := residual;
      PointsFrm.NoCases := NoPts;
      PointsFrm.MsgEdit.Text := 'Std. Err. Residuals: ' + FloatToStr(StdErr);
      PointsFrm.LabelOne := 'Original';
      PointsFrm.LabelTwo := 'Residuals';
      PointsFrm.Title := 'Residuals from Moving Average';
      PointsFrm.Caption := 'Moving Average Residuals';
      PointsFrm.ShowModal;
    end;

    // replace original points with smoothed values
    for i := 0 to (NoPts + noproj - 1) do
      pts[i] := avg[i];

  finally
    F.Free;
  end;
end;

procedure TAutoCorrFrm.PlotDifferencesForLag(var Pts: DblDyneVec; NoPts: Integer);
var
  F: TDifferenceFrm;
  lag: Integer;
  avg: DblDyneVec;
  residual: DblDyneVec;
  varRes: Double;
  stdErr: Double;
  i, j: Integer;
begin
  F := TDifferenceFrm.Create(nil);
  try
    if F.ShowModal <> mrOK then
      exit;

    lag := StrToInt(MaxLagEdit.Text);

    SetLength(avg, NoPts);
    for i := 0 to NoPts-1 do
      avg[i] := pts[i];

    for j := 1 to StrToInt(F.OrderEdit.Text) do
      for i := NoPts downto lag do
        avg[i] := avg[i] - avg[i - lag];  // wp: what with avg[0]..avg[lag] ?

    // plot the original and differenced values
    PointsFrm.pts := pts;
    PointsFrm.avg := avg;
    PointsFrm.NoCases := NoPts;
    PointsFrm.LabelOne := 'Original';
    PointsFrm.LabelTwo := 'Differenced';
    PointsFrm.MsgEdit.Text := 'No. points = ' + IntToStr(NoCases);
    PointsFrm.Title := 'Differencing Smoothed';
    PointsFrm.Caption := 'Difference Smoothing';
    PointsFrm.ShowModal;

    // calculate and plot residuals;
    if ResidChk.Checked then
    begin
      SetLength(residual, NoPts);
      varRes := 0.0;
      for i := 0 to NoPts - 1 do
      begin
        residual[i] := pts[i] - avg[i];
        varRes := varRes + sqr(residual[i]);
      end;
      varRes := varRes / NoPts;
      stdErr := sqrt(varRes);

      // plot the residuals
      PointsFrm.pts := pts;
      PointsFrm.avg := residual;
      PointsFrm.NoCases := NoPts;
      PointsFrm.MsgEdit.Text := 'Std. Err. Residuals: ' + FloatToStr(StdErr);
      PointsFrm.LabelOne := 'Original';
      PointsFrm.LabelTwo := 'Residuals';
      PointsFrm.Title := 'Residuals from Difference Smoothing';
      PointsFrm.Caption := 'Difference Residuals';
      PointsFrm.ShowModal;
    end;

    // replace original points by smoothed values
    for i := 0 to NoPts - 1 do
      pts[i] := avg[i];
  finally
    F.Free;
  end;
end;

procedure TAutoCorrFrm.PolynomialSmooth(var Pts: DblDyneVec; NoPts: Integer);
var
  F: TPolynomialFrm;
  noProj: Integer;
  i: Integer;
  avg: DblDyneVec;
  residual: DblDyneVec;
  varRes: Double;
  stdErr: Double;
begin
  F := TPolynomialFrm.Create(nil);
  try
    if F.ShowModal <> mrOK then
      exit;

    if ProjectChk.Checked then
      noProj := StrToInt(ProjPtsEdit.Text)
    else
      noProj := 0;

    SetLength(avg, NoPts + noProj);
    if ProjectChk.Checked then
    begin
      for i := 0 to noproj - 1 do
      begin
        avg[i] := pts[NoPts-1-noproj+i];
        pts[i] := avg[i];
      end;
    end;

    PolyFit(pts, avg, NoPts + noproj);

    // plot original and smoothed data
    PointsFrm.pts := pts;
    PointsFrm.avg := avg;
    PointsFrm.NoCases := NoPts + noproj;
    PointsFrm.LabelOne := 'Original';
    PointsFrm.LabelTwo := 'Smoothed';
    PointsFrm.Title := 'Polynomial Smoothed';
    PointsFrm.Caption := 'Polynomial Smoothing';
    PointsFrm.ShowModal;

    // plot residuals if checked
    if ResidChk.Checked then
    begin
      SetLength(residual, NoPts);
      varRes := 0.0;
      for i := 0 to NoPts - 1 do
      begin
        residual[i] := pts[i] - avg[i];
        varRes := varRes + sqr(residual[i]);
      end;
      varRes := varRes / NoPts;
      stdErr := sqrt(varRes);

      // plot the residuals
      PointsFrm.pts := pts;
      PointsFrm.avg := residual;
      PointsFrm.NoCases := NoPts;
      PointsFrm.MsgEdit.Text := 'Std. Err. Residuals: ' + FloatToStr(StdErr);
      PointsFrm.LabelOne := 'Original';
      PointsFrm.LabelTwo := 'Residuals';
      PointsFrm.Title := 'Residuals from Polynomial Smoothing';
      PointsFrm.Caption := 'Polynomial Residuals';
      PointsFrm.ShowModal;
    end;

    // replace original points with smoothed values
    for i := 0 to (NoPts + noproj - 1) do
      pts[i] := avg[i];

  finally
    F.Free;
  end;
end;

procedure TAutoCorrFrm.RemoveMeans(var Pts: DblDyneVec; NoPts: Integer; AMean: Double);
var
  i: Integer;
begin
  for i := 0 to NoPts-1 do
    Pts[i] := Pts[i] - AMean;
end;


initialization
  {$I autocorunit.lrs}

end.

