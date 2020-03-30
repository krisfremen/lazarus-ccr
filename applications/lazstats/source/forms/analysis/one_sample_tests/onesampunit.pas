unit OneSampUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TOneSampFrm }

  TOneSampFrm = class(TForm)
    Bevel1: TBevel;
    ComputeBtn: TButton;
    ResetBtn: TButton;
    CloseBtn: TButton;
    Statistic: TEdit;
    Parameter: TEdit;
    Size: TEdit;
    CInterval: TEdit;
    StdDev: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  OneSampFrm: TOneSampFrm;

implementation

uses
  Math,
  Globals, OutputUnit, FunctionsLib;

{ TOneSampFrm }

procedure TOneSampFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TOneSampFrm.FormCreate(Sender: TObject);
begin
  CInterval.Text := FormatFloat('0', DEFAULT_CONFIDENCE_LEVEL_PERCENT);
end;

procedure TOneSampFrm.ResetBtnClick(Sender: TObject);
begin
  Statistic.Text := '';
  Parameter.Text := '';
  Size.Text := '';
  StdDev.Text := '';
end;

procedure TOneSampFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TOneSampFrm.RadioGroup1Click(Sender: TObject);
begin
  Label5.Enabled := RadioGroup1.ItemIndex = 0;
  StdDev.Enabled := RadioGroup1.ItemIndex = 0;
{     if RadioGroup1.ItemIndex <> 0 then
     begin
          Label5.Visible := false;
          StdDev.Visible := false;
     end
     else
     begin
          Label5.Visible := true;
          StdDev.Visible := true;
     end;
}
end;

procedure TOneSampFrm.ComputeBtnClick(Sender: TObject);
var
   N : integer;
   sampmean, sampprop, sampcor, sampvar, Confidence, alpha, df : double;
   popmean, popprop, popcor, popvar, stderr : double;
   z, zprobability, zreject, zconf, UCL, LCL, sampsd : double;
   t, tprobability, testt : double;
   poptrans, samptrans, chisqrval, chiprob, lowchi, hichi, testchi : double;
   lReport: TStrings;
   msg: String;
   C: TWinControl;
begin
  if not Validate(msg, C) then
  begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  lReport := TStringList.Create;
  try
    N := round(StrToFloat(Size.Text));
    Confidence := StrToFloat(CInterval.Text) / 100.0;
    case RadioGroup1.ItemIndex of
      0 : begin
            sampmean := StrToFloat(Statistic.Text);
            popmean := StrToFloat(Parameter.Text);
            sampsd := StrToFloat(StdDev.Text);
            df := N;
            stderr := sampsd / sqrt(df);
            df := N-1;
            t := (sampmean - popmean) / stderr;
            tprobability := probt(t,df);
            alpha := (1.0 - confidence) / 2.0;
            testt := inverset((1.0 - alpha),df);
            UCL := sampmean + testt * stderr;
            LCL := sampmean - testt * stderr;
            lReport.Add('ANALYSIS OF A SAMPLE MEAN');
            lReport.Add('');
            lReport.Add('Sample Mean:                    %9.3f', [sampmean]);
            lReport.Add('Population Mean:                %9.3f', [popmean]);
            lReport.Add('Sample Size:                    %9d',   [N]);
            lReport.Add('Standard error of Mean:         %9.3f', [stderr]);
            lReport.Add('t test statistic:               %9.3f', [t]);
            lReport.Add('  with probability:             %9.3f', [tprobability]);
            lReport.Add('t value required for rejection: %9.3f', [testt]);
            lReport.Add('Confidence Interval:            (%.3f ... %.3f)', [LCL, UCL]);
          end;
      1 : begin
            sampprop := StrToFloat(Statistic.Text);
            popprop := StrToFloat(Parameter.Text);
            stderr := sqrt((sampprop * (1.0 - sampprop)) / N);
            z := (sampprop - popprop) / StdErr;
            zprobability := 1.0 - probz(z);
            zreject := inversez(confidence);
            zconf := abs(inversez((1.0 - confidence) / 2.0));
            UCL := sampprop + (zconf * stderr);
            LCL := sampprop - (zconf * stderr);
            lReport.Add('ANALYSIS OF A SAMPLE PROPORTION');
            lReport.Add('');
            lReport.Add('Sample Proportion:              %9.3f', [sampprop]);
            lReport.Add('Population Proportion:          %9.3f', [popprop]);
            lReport.Add('Sample Size:                    %9d',   [N]);
            lReport.Add('Standard error of proportion:   %9.3f', [stderr]);
            lReport.Add('z test statistic:               %9.3f', [z]);
            lReport.Add('  with probability > P:         %9.3f', [zprobability]);
            lReport.Add('z value required for rejection: %9.3f', [zreject]);
            lReport.Add('Confidence Interval:            (%.3f ... %.3f)', [LCL, UCL]);
          end;
      2 : begin
            sampcor := StrToFloat(Statistic.Text);
            popcor := StrToFloat(Parameter.Text);
            zconf := abs(inversez((1.0 - confidence) / 2.0));
            samptrans := ln((1.0 + sampcor) / (1.0 - sampcor)) / 2.0;
            poptrans := ln((1.0 + popcor) / (1.0 - popcor)) / 2.0;
            stderr := sqrt(1.0 / (N - 3.0));
            z := (samptrans - poptrans) / stderr;
            zprobability := probz(z);
            alpha := (1.0 - confidence) / 2.0;
            zreject := inversez(1.0 - alpha);
            UCL := samptrans + (zconf * stderr);
            LCL := samptrans - (zconf * stderr);
            UCL := (exp(2.0 * UCL) - 1.0) / (exp(2.0 * UCL) + 1.0);
            LCL := (exp(2.0 * LCL) - 1.0) / (exp(2.0 * LCL) + 1.0);
            lReport.Add('ANALYSIS OF A SAMPLE CORRELATION');
            lReport.Add('');
            lReport.Add('Sample Correlation:                    %9.3f', [sampcor]);
            lReport.Add('Population Correlation:                %9.3f', [popcor]);
            lReport.Add('Sample Size:                           %9d',   [N]);
            lReport.Add('z Transform of sample correlation:     %9.3f', [samptrans]);
            lReport.Add('z Transform of population correlation: %9.3f', [poptrans]);
            lReport.Add('Standard error of transform:           %9.3f', [stderr]);
            lReport.Add('z test statistic:                      %9.3f', [z]);
            lReport.Add('  with probability:                    %9.3f', [zprobability]);
            lReport.Add('z value required for rejection:        %9.3f', [zreject]);
            lReport.Add('Confidence Interval for sample correlation: (%.3f ... %.3f)', [LCL, UCL]);
          end;
      3 : begin
            sampvar := StrToFloat(Statistic.Text);
            popvar := StrToFloat(Parameter.Text);
            alpha := 1.0 - confidence;
            chisqrval := ((N - 1.0) * sampvar) / Popvar;
            chiprob := 1.0 - chisquaredprob(chisqrval,N-1);
            lowchi := inversechi((1.0 - alpha / 2.0),N-1);
            hichi := inversechi((alpha / 2.0),N-1);
            LCL := ((N - 1.0) * sampvar) / lowchi;
            UCL := ((N - 1.0) * sampvar) / hichi;
            if sampvar > popvar then
              testchi := lowchi
            else
              testchi := hichi;
            lReport.Add('ANALYSIS OF A SAMPLE VARIANCE');
            lReport.Add('');
            lReport.Add('Sample Variance:                         %9.3f', [sampvar]);
            lReport.Add('Population Variance:                     %9.3f', [popvar]);
            lReport.Add('Sample Size:                             %9d',   [N]);
            lReport.Add('Chi-square statistic                     %9.3f', [chisqrval]);
            lReport.Add('  with probability > chisquare           %9.3f', [chiprob]);
            lReport.Add('  and D.F.                               %9d',   [N-1]);
            lReport.Add('Chi-square value required for rejection: %9.3f', [testchi]);
            lReport.Add('Chi-square Confidence Interval:          (%.3f ... %.3f)', [lowchi, hichi]);
            lReport.Add('Variance Confidence Interval:            (%.3f ... %.3f)', [LCL, UCL]);
          end;
    end;
    DisplayReport(lReport);
  finally
    lReport.Free;
  end;
end;

function TOneSampFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
  n: Integer;
begin
  Result := false;

  if Statistic.Text = '' then
  begin
    AMsg := 'Value of sample proportion missing.';
    AControl := Statistic;
    exit;
  end;
  if not TryStrtoFloat(Statistic.Text, x) then
  begin
    AMsg := 'Sample proportion is not a valid number.';
    AControl := Statistic;
    exit;
  end;

  if Parameter.Text = '' then
  begin
    AMsg := 'Value of population parameter is missing.';
    AControl := Parameter;
    exit;
  end;
  if not TryStrToFloat(Parameter.Text, x) then
  begin
    AMsg := 'Population parameter is not a valid number.';
    AControl := Parameter;
    exit;
  end;

  if Size.Text = '' then
  begin
    AMsg := 'Value of sample size is missing.';
    AControl := Size;
    exit;
  end;
  if not TryStrToInt(Size.Text, n) then
  begin
    AMsg := 'Sample size is not a valid number.';
    AControl := Size;
    exit;
  end;

  if RadioGroup1.ItemIndex = 0 then
  begin
    if StdDev.Text = '' then
    begin
      AMsg := 'Sample standard deviation is not specified.';
      AControl := StdDev;
      exit;
    end;
    if not TryStrToFloat(StdDev.Text, x) then
    begin
      AMsg := 'Sample standard deviation is not a valid number.';
      AControl := StdDev;
      exit;
    end;
  end;

  if CInterval.Text = '' then
  begin
    AMsg := 'Confidence level is not specified.';
    AControl := CInterval;
    exit;
  end;
  if not TryStrToFloat(CInterval.Text, x) then
  begin
    AMsg := 'Confidence level is not a valid number.';
    AControl := CInterval;
    exit;
  end;

  Result := true;
end;

initialization
  {$I onesampunit.lrs}

end.

