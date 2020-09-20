unit RChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  BasicSPCUnit;

type

  { TRChartForm }

  TRChartForm = class(TBasicSPCForm)
  protected
    procedure Compute; override;
  end;

var
  RChartForm: TRChartForm;

implementation

{$R *.lfm}

uses
  Math,
  Globals, Utils, MainUnit, DataProcs;

// Constants for correction of standard deviation
const
  D3: array[2..25] of double = (
    0, 0, 0, 0, 0, 0.076, 0.136, 0.184, 0.223,  // 2..10
    0.256, 0.283, 0.307, 0.328, 0.347, 0.363, 0.378, 0.391, 0.403, 0.415, // 11..20
    0.425, 0.434, 0.443, 0.451, 0.459    // 21..25
  );
  D4: array[2..25] of double = (
    3.267, 2.574, 2.282, 2.114, 2.004, 1.924, 1.864, 1.816, 1.777,   // 2..10
    1.744, 1.717, 1.693, 1.672, 1.653, 1.637, 1.622, 1.608, 1.597, 1.585, // 11..20
    1.575, 1.566, 1.557, 1.548, 1.541    // 21..25
  );

procedure TRChartForm.Compute;
var
  i, j: Integer;
  grp: String;
  grpIndex, grpSize, oldGrpSize, numGrps, numValues: Integer;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stddev: DblDyneVec = nil;
  ranges: DblDynevec = nil;
  count: IntDyneVec = nil;
  ColNoSelected: IntDyneVec = nil;
  X, Xsq, xmin, xmax: Double;
  grandMean, grandRange, grandSD, SEMean, UCL, LCL: Double;
  D3Value, D4Value: Double;
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
  SetLength(ranges, numGrps);
  grandMean := 0.0;
  grandRange := 0.0;
  grandSD := 0.0;

  // Count "good" data points
  numValues := 0;
  for i := 1 to NoCases do
    if GoodRecord(i, Length(ColNoSelected), ColNoSelected) then inc(numValues);

  // calculate group ranges, grand mean, group sd's, semeans
  for j := 0 to numGrps-1 do
  begin
    xmin := 1E308;
    xmax := -1E308;
    for i := 1 to NoCases do
    begin
      grp := Trim(OS3MainFrm.DataGrid.Cells[GrpVar, i]);
      grpIndex := IndexOfString(groups, grp);
      if grpIndex = j then
      begin
        X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[MeasVar, i]));
        Xsq := X * X;
        if X > xmax then xmax := X;
        if X < xmin then xmin := X;
        means[grpIndex] := means[grpIndex] + X;
        count[grpIndex] := count[grpIndex] + 1;
        stddev[grpIndex] := stddev[grpIndex] + Xsq;
        grandMean := grandMean + X;
        grandSD := grandSD + Xsq;
      end;
    end; // next case

    ranges[j] := xMax - xMin;
    grandRange := grandRange + ranges[j];
    grpSize := count[j];
    if j = 0 then oldGrpSize := grpSize;
    if oldGrpSize <> grpSize then
    begin
      ErrorMsg('All groups must have the same size.');
      exit;
    end;
  end;

  if (grpsize < 2) then
  begin
    ErrorMsg('Groups with at least two values required.');
    exit;
  end;
  if (grpsize > 25) then
  begin
    ErrorMsg('Groups are too large (max 25).');
    exit;
  end;

  for i := 0 to numGrps-1 do
  begin
    stddev[i] := stddev[i] - sqr(means[i]) / count[i];
    stddev[i] := stddev[i] / (count[i] - 1);
    stddev[i] := sqrt(stddev[i]);
    means[i] := means[i] / count[i];
  end;

  grandSD := grandSD - sqr(grandMean) / numValues;
  grandSD := sqrt(grandSD / (numValues - 1));
  SEMean := grandSD / sqrt(numValues);
  grandMean := grandMean / numValues;
  grandRange := grandRange / numGrps;
  D3Value := D3[grpSize];
  D4Value := D4[grpSize];
  UCL := D4Value * grandRange;
  LCL := D3Value * grandRange;

  // print results
  lReport := TStringList.Create;
  try
    lReport.Add('Range Chart Results');
    lReport.Add('');
    lReport.Add('Number of values:        %8d',   [numValues]);
    lReport.Add('Grand Mean:              %8.3f', [GrandMean]);
    lReport.Add('Standard Deviation:      %8.3f', [GrandSD]);
    lReport.Add('Standard Error of Mean:  %8.3f', [SEMean]);
    lReport.Add('');
    lReport.Add('Mean Range:              %8.3f', [GrandRange]);
    lReport.Add('Lower Control Limit:     %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:     %8.3f', [UCL]);
    lReport.Add('');
    lReport.Add(' Group   Size    Mean    Std.Dev.   Ranges ');
    lReport.Add('-------  ----  --------  --------  --------');
    for i := 0 to numGrps-1 do
      lReport.Add('%7d  %4d  %8.2f  %8.2f  %8.2f', [i+1, count[i], means[i], stddev[i], ranges[i]]);

    FReportFrame.DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // Show graph
  PlotMeans(
    Format('Range Chart for "%s"', [GetFileName]),
    GroupEdit.Text, Format('Range(%s)', [MeasEdit.Text]),
    'Group ranges', 'Avg',
    groups, ranges,
    UCL, LCL, grandRange,
    NaN, NaN, NaN
  );
end;


end.

