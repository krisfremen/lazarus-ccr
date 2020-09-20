{ This unit was checked against a commercial statistical software  and
  creates correct results.

  Data file for testing: "boltsize.laz"
  Group variable:         LotNo
  Selected variable:      BoltLngth
}

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
var
  UCL, LCL: Double;
  grpSize, oldGrpSize: Integer;
  ColNoSelected: IntDyneVec = nil;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stddev: DblDyneVec = nil;
  count: IntDyneVec = nil;
  numGrps: Integer = 0;
  numValues: Integer = 0;
  grp: String;
  grpIndex: Integer;
  X, Xsq, Xmin, Xmax: Double;
  seMean, grandMean, grandSigma, grandSD: Double;
  B, C4: Double;
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

  // Count "good" data points
  numValues := 0;
  for i := 1 to NoCases do
    if GoodRecord(i, Length(ColNoSelected), ColNoSelected) then inc(numValues);

  // calculate group ranges, grand mean, group sd's, semeans
  for j := 0 to numGrps-1 do // groups
  begin
    xmin := Infinity;
    xmax := -Infinity;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, Length(ColNoSelected), ColNoSelected) then continue;
      grp := Trim(OS3MainFrm.DataGrid.Cells[GrpVar, i]);
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

    grpSize := count[j];
    if (grpSize < 2) then
    begin
      ErrorMsg('Groups with at least two values required.');
      exit;
    end;
    if j = 0 then oldGrpSize := grpSize;
    if oldGrpSize <> grpSize then
    begin
      ErrorMsg('All groups must have the same size.');
      exit;
    end;

    stddev[j] := stddev[j] - sqr(means[j]) / count[j];
    stddev[j] := stddev[j] / (count[j] - 1);
    stddev[j] := sqrt(stddev[j]);
    means[j] := means[j] / count[j];
    grandSigma := grandSigma + stddev[j];
  end;

  seMean := seMean - sqr(grandMean)/numValues;
  seMean := seMean / (numValues - 1);
  seMean := sqrt(seMean);
  grandSD := seMean;
  seMean := seMean / sqrt(numValues);
  grandMean := grandMean / numValues;
  grandSigma := grandSigma / numGrps;

  C4 := CalcC4(grpSize);
  B := grandSigma * sqrt(1.0 - sqr(C4)) / C4;
  UCL := grandSigma + 3.0 * B;
  LCL := grandSigma - 3.0 * B;
  if (LCL < 0.0) then LCL := 0.0;

  // print results
  lReport := TStringList.Create;
  try
    lReport.Add('Sigma Chart Results');
    lReport.Add('');
    lReport.Add('Number of values:       %8d',   [numValues]);
    lReport.Add('Number of groups:       %8d',   [numGrps]);
    lReport.Add('Group size:             %8d',   [grpSize]);
    lReport.Add('');
    lReport.Add('Grand Mean:             %8.3f', [grandMean]);
    lReport.Add('Standard Deviation:     %8.3f', [grandSD]);
    lReport.Add('Standard Error of Mean: %8.3f', [seMean]);
    lReport.Add('');
    lReport.Add('Mean Sigma:             %8.3f', [grandSigma]);
    lReport.Add('Lower Control Limit:    %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:    %8.3f', [UCL]);
    lReport.Add('');
    lReport.Add(' Group  Size   Mean   Std.Dev.');
    lReport.Add('------- ---- -------- --------');
    for i := 0 to numGrps - 1 do
      lReport.Add('%7d %4d %8.2f %8.2f', [i+1, count[i], means[i], stddev[i]]);

    FReportFrame.DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // show graph
  PlotMeans(
    Format('Sigma Chart for "%s"', [GetFileName]),
    GroupEdit.Text, Format('StdDev(%s)', [MeasEdit.Text]),
    'Group Sigma', 'Avg',
    groups, stdDev,
    UCL, LCL, grandSigma,
    NaN, NaN, NaN
  );
end;

end.

