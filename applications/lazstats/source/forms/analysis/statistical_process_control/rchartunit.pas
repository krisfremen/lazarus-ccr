unit RChartUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  BasicSPCUnit;

type
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
  Globals, Utils, MainUnit;

procedure TRChartForm.Compute;
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
var
  i, j: Integer;
  grp: String;
  grpIndex, grpSize, oldGrpSize, numGrps: Integer;
  groups: StrDyneVec = nil;
  means: DblDyneVec = nil;
  stddev: DblDyneVec = nil;
  ranges: DblDynevec = nil;
  count: IntDyneVec = nil;
  ColNoSelected: IntDyneVec = nil;
  X, Xsq, xmin, xmax: Double;
  seMean, grandMean, grandRange, grandSD, UCL, LCL: Double;
  D3Value, D4Value: Double;
  sizeError: boolean;
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
  seMean := 0.0;
  grandMean := 0.0;
  grandRange := 0.0;
  sizeError := false;

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
        seMean := seMean + Xsq;
        grandMean := grandMean + X;
      end;
    end; // next case

    ranges[j] := xMax - xMin;
    grandRange := grandRange + ranges[j];
    grpSize := count[j];
    if j = 0 then oldGrpSize := grpSize;
    if oldGrpSize <> grpSize then sizeError := true;
  end;

  if (grpsize < 2) or (grpsize > 25) or sizeError then
  begin
    ErrorMsg('Group size error.');
    exit;
  end;

  for i := 0 to numGrps-1 do
  begin
    stddev[i] := stddev[i] - sqr(means[i]) / count[i];
    stddev[i] := stddev[i] / (count[i] - 1);
    stddev[i] := sqrt(stddev[i]);
    means[i] := means[i] / count[i];
  end;
  seMean := seMean - grandMean * grandMean / NoCases;
  seMean := seMean / (NoCases - 1);
  seMean := sqrt(seMean);
  GrandSD := seMean;
  seMean := seMean / sqrt(NoCases);
  grandMean := grandMean / NoCases;
  grandRange := grandRange / numGrps;
  D3Value := D3[grpSize-1];
  D4Value := D4[grpSize-1];
  UCL := D4Value * grandRange;
  LCL := D3Value * grandRange;

  // print results
  lReport := TStringList.Create;
  try
    lReport.Add('Range Chart Results');
    lReport.Add('');
    lReport.Add(' Group  Size   Mean   Std.Dev.  Ranges ');
    lReport.Add('------- ---- -------- -------- --------');
    for i := 0 to numGrps-1 do
      lReport.Add('%7d %4d %8.2f %8.2f %8.2f', [i+1, count[i], means[i], stddev[i], ranges[i]]);
    lReport.Add('');
    lReport.Add('Grand Mean:             %8.3f', [GrandMean]);
    lReport.Add('Standard Deviation:     %8.3f', [GrandSD]);
    lReport.Add('Standard Error of Mean: %8.3f', [semean]);
    lReport.Add('Mean Range:             %8.3f', [GrandRange]);
    lReport.Add('Lower Control Limit:    %8.3f', [LCL]);
    lReport.Add('Upper Control Limit:    %8.3f', [UCL]);

    ReportMemo.Lines.Assign(lReport);
  finally
    lReport.Free;
  end;

  // show graph
  // show graph
  PlotMeans(
    Format('Range Chart for "%s"', [GetFileName]),
    GroupEdit.Text, Format('Range(%s)', [MeasEdit.Text]),
    'Group ranges', 'Mean range',
    groups, ranges,
    UCL, LCL, grandRange,
    NaN, NaN, NaN
  );
end;


end.

