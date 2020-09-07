unit SChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  BasicSPCUnit;

type

  { TSChartForm }

  TSChartForm = class(TBasicSPCForm)
  protected
    procedure Compute; override;
  end;

var
  SChartForm: TSChartForm;

implementation

{$R *.lfm}

uses
  Math, Globals, MathUnit, Utils, MainUnit, DataProcs;

procedure TSChartForm.Compute;
const
  D3: array[1..24] of double = (
    0,0,0,0,0,0.076,0.136,0.184,0.223,0.256,0.283,0.307,0.328,
    0.347,0.363,0.378,0.391,0.403,0.415,0.425,0.434,0.443,
    0.451,0.459
  );
  D4 : array[1..24] of double = (
    3.267,2.574,2.282,2.114,2.004,1.924,1.864,1.816,1.777,
    1.744,1.717,1.693,1.672,1.653,1.637,1.622,1.608,1.597,
    1.585,1.575,1.566,1.557,1.548,1.541
  );
var
  UCL, LCL: Double;
  grpSize, oldGrpSize: Integer;
  ColNoSelected: IntDyneVec = nil;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stddev: DblDyneVec = nil;
  count: IntDyneVec = nil;
  numGrps: Integer = 0;
  grp: String;
  grpIndex: Integer;
  X, Xsq: Double;
  seMean, grandMean, grandSigma, grandSD: Double;
  B, C4, gamma, D3Value, D4Value: Double;
  xmin, xmax: Double;
  sizeError: Boolean;
  i, j: Integer;
  lReport: TStrings;
begin
  SetLength(ColNoSelected, 2);
  ColNoSelected[0] := GrpVar;
  ColNoSelected[1] := MeasVar;

  grpSize := 0;
  oldGrpSize := 0;
  groups := GetGroups;
  numGrps := Length(groups);

  SetLength(means, numGrps);
  SetLength(count, numGrps);
  SetLength(stddev, numGrps);
  seMean := 0.0;
  grandMean := 0.0;
  grandSigma := 0.0;
  sizeError := false;

  // calculate group ranges, grand mean, group sd's, semeans
  for j := 0 to numGrps-1 do // groups
  begin
    xmin := Infinity;
    xmax := -Infinity;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
      grp := Trim(OS3MainFrm.DataGrid.Cells[GrpVar,i]);
      grpIndex := IndexOfString(groups, grp);
      if grpIndex = j then
      begin
        X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
        Xsq := X*X;
        if X > xmax then xmax := X;
        if X < xmin then xmin := X;
        inc(count[grpIndex]);
        means[grpIndex] := means[grpIndex] + X;
        stddev[grpIndex] := stddev[grpIndex] + Xsq;
        seMean := seMean + Xsq;
        grandMean := grandMean + X;
      end;
    end; // next case
    stddev[j] := stddev[j] - sqr(means[j]) / count[j];
    stddev[j] := stddev[j] / (count[j] - 1);
    stddev[j] := sqrt(stddev[j]);
    means[j] := means[j] / count[j];
    grandSigma := grandSigma + stddev[j];
    grpSize := count[j];
    if j = 0 then oldGrpSize := grpSize;
    if oldGrpSize <> grpSize then
      sizeError := true;
  end;

  if (grpSize < 2) or (grpSize > 25) or sizeError then
  begin
    ErrorMsg('Group size error.');
    exit;
  end;

  seMean := seMean - sqr(grandMean)/NoCases;
  seMean := seMean / (NoCases - 1);
  seMean := sqrt(seMean);
  grandSD := seMean;
  seMean := seMean / sqrt(NoCases);
  grandMean := grandMean / NoCases;
  grandSigma := grandSigma / numGrps;
  D3Value := D3[grpSize-1];
  D4Value := D4[grpSize-1];
  C4 := sqrt(2.0 / (grpSize - 1));
  gamma := exp(GammaLn(grpSize / 2.0));
  C4 := C4 * gamma;
  gamma := exp(GammaLn((grpSize-1) / 2.0));
  C4 := C4 / gamma;
  B := grandSigma * sqrt(1.0 - (C4 * C4)) / C4;
  UCL := grandSigma + 3.0 * B;
  LCL := grandSigma - 3.0 * B;
  if (LCL < 0.0) then LCL := 0.0;

  // print results
  lReport := TStringList.Create;
  try
    lReport.Add('Sigma Chart Results');
    lReport.Add('');
    lReport.Add(' Group  Size   Mean   Std.Dev.');
    lReport.Add('------- ---- -------- --------');
    for i := 0 to numGrps - 1 do
      lReport.Add('%7d %4d %8.2f %8.2f', [i+1, count[i], means[i], stddev[i]]);
    lReport.Add('');
    lReport.Add('Grand Mean:             %8.3f', [grandMean]);
    lReport.Add('Standard Deviation:     %8.3f', [grandSD]);
    lReport.Add('Standard Error of Mean: %8.3f', [seMean]);
    lReport.Add('Mean Sigma:             %8.3f', [grandSigma]);
    lReport.Add('Lower Control Limit:    %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:    %8.3f', [UCL]);

    ReportMemo.Lines.Assign(lReport);
  finally
    lReport.Free;
  end;

  // show graph
  PlotMeans(
    Format('Sigma Chart for "%s"', [GetFileName]),
    GroupEdit.Text, Format('StdDev(%s)', [MeasEdit.Text]),
    'Group Sigma', 'Mean',
    groups, stdDev,
    UCL, LCL, grandSigma,
    NaN, NaN, NaN
  );
end;

end.

