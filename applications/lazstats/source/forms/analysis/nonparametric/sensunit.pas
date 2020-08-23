// File for testing: boltsize.laz, use BoltLngth variable

// NOTE: THE OUTPUT DOES NOT EXACTLY MATCH THAT OF THE PDF DOCUMENTATION !!!!

unit SensUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit,
  ContextHelpUnit, MatrixLib, GraphLib;

type

  { TSensForm }

  TSensForm = class(TForm)
    AllBtn: TBitBtn;
    AlphaEdit: TEdit;
    Bevel1: TBevel;
    Memo1: TLabel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    InBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SelectedList: TListBox;
    OutBtn: TBitBtn;
    VarList: TListBox;
    PrtRanksChk: TCheckBox;
    PrtSlopesChk: TCheckBox;
    PrtDataChk: TCheckBox;
    GroupBox3: TGroupBox;
    SlopesChk: TCheckBox;
    PlotChk: TCheckBox;
    GroupBox2: TGroupBox;
    StandardizeChk: TCheckBox;
    AvgSlopeChk: TCheckBox;
    GroupBox1: TGroupBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; {%H-}User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  SensForm: TSensForm;

implementation

uses
  Math, Utils;

{ TSensForm }

procedure TSensForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  AlphaEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  StandardizeChk.Checked := false;
  PlotChk.Checked := false;
  SlopesChk.Checked := false;
  AvgSlopeChk.Checked := false;
  SelectedList.Clear;
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TSensForm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      SelectedList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TSensForm.AllBtnClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to VarList.Items.Count-1 do
    SelectedList.Items.Add(VarList.Items[i]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TSensForm.ComputeBtnClick(Sender: TObject);
var
  //NoVars,
  noselected, count, half, q, tp, low, hi, col: integer;
  Values, Slopes, AvgSlopes: DblDyneMat;
  RankedQ, Sorted: DblDyneVec;
  RowLabels, ColLabels, RankLabels: StrDyneVec;
  selected: IntDyneVec;
  MedianSlope, MannKendall, Z, C, M1, M2, Alpha, mean, stddev: double;
  cellstring, outline: string;
  i, j, k, no2do: integer;
  Standardize, Plot, SlopePlot, AvgSlope: boolean;
  lReport: TStrings;
begin
  NoSelected := SelectedList.Items.Count;
  if noselected = 0 then
  begin
    MessageDlg('First select variables to analyze.', mtError, [mbOk], 0);
    exit;
  end;

  if AlphaEdit.Text = '' then begin
    AlphaEdit.SetFocus;
    MessageDlg('Input required.', mtError, [mbOk], 0);
    exit;
  end;
  if not TryStrToFloat(AlphaEdit.Text, Alpha) or (Alpha <= 0) or (Alpha >= 1) then
  begin
    AlphaEdit.SetFocus;
    MessageDlg('Numeric value required in range > 0 and < 1.', mtError, [mbOk], 0);
    exit;
  end;
  Alpha := 1.0 - Alpha;

  Standardize := StandardizeChk.Checked;
  Plot := PlotChk.Checked;
  SlopePlot := SlopesChk.Checked;
  AvgSlope := AvgSlopeChk.Checked;

  SetLength(RowLabels, NoCases);
  SetLength(ColLabels, NoCases);
  SetLength(selected, noselected);
  SetLength(Values,NoCases, noselected+1);
  SetLength(Slopes,NoCases, NoCases);
  //SetLength(RankedQ, NoVars);        // !!!!!!!!!!!!!!!!!!! NoVars is not initialized !!!!!!!!!!!!!!!!!!!!!!
  SetLength(Sorted, NoCases);
  SetLength(AvgSlopes, NoCases, NoCases);

  for i := 0 to NoCases-1 do
  begin
    RowLabels[i] := OS3MainFrm.DataGrid.Cells[0,i+1];
    ColLabels[i] := RowLabels[i];
    for j := 0 to NoCases-1 do Slopes[i,j] := 0.0;
  end;

  // get selected variables
  for i := 0 to noselected-1 do
  begin
    cellstring := SelectedList.Items.Strings[i];
    for j := 1 to NoVariables do
      if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
        selected[i] := j;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('SENS DETECTION AND ESTIMATION OF TRENDS');
    lReport.Add('Number of data points: %4d', [NoCases]);
    lReport.Add('Confidence Interval:   %4.2f', [Alpha]);
    lReport.Add('');

    //Get the data
    if AvgSlope then
      for i := 0 to NoCases-1 do
        Values[i, noselected] := 0.0;

    for j := 0 to noselected-1 do
    begin
      col := selected[j];
      for i := 1 to NoCases do
      begin
        // Values[i-1, j] := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col, i])));  // wp: why round?
        Values[i-1, j] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col, i]));
        if AvgSlope then
          Values[i-1, noselected] := Values[i-1, noselected] + Values[i-1, j];
      end;
    end;

    if PrtDataChk.Checked then
    begin
      outline := 'CASE';
      MatPrint(Values, NoCases, noselected, outline, RowLabels, ColLabels, NoCases, lReport);
      lReport.Add(DIVIDER);
      lReport.Add('');
    end;

    // standardize if more than one variable and standardization elected
    if (noselected > 1) and standardize then
    begin
      for j := 0 to noselected-1 do
      begin
        mean := 0.0;
        stddev := 0.0;
        for i := 0 to NoCases-1 do
        begin
          mean := mean + Values[i,j];
          stddev := stddev + sqr(Values[i,j]);
        end;
        stddev := stddev - sqr(mean) / NoCases;
        stddev := stddev / (NoCases - 1);
        stddev := sqrt(stddev);
        mean := mean / NoCases;
        for i := 0 to NoCases-1 do
          Values[i,j] := (Values[i,j] - mean) / stddev;
        col := selected[j];
        lReport.Add('Variable: %s,  mean: %8.3f,  standard deviation: %8.3f', [OS3MainFrm.DataGrid.Cells[col,0], mean, stddev]);
      end;
    end;

    // average the values if elected
    if AvgSlope then
      for i := 0 to NoCases - 1 do
        Values[i, noselected] := Values[i,noselected] / noselected;

    // get interval slopes
    no2do := noselected;
    if AvgSlope then
      no2do := no2do + 1;
    for j := 0 to no2do - 1 do
    begin
      if j < noselected then
      begin
        col := selected[j];
        cellstring := OS3MainFrm.DataGrid.Cells[col,0];
      end else
      begin
        col := 0;
        cellstring := 'Combined Scores';
      end;

      for i := 0 to NoCases-2 do
        for k := i + 1 to NoCases-1 do
          Slopes[i,k] := (Values[k,j] - Values[i,j]) / (k-i);

      if PrtSlopesChk.Checked then
      begin
        outline := 'CASE';
        MatPrint(Slopes, NoCases, NoCases, outline, RowLabels, ColLabels, NoCases, lReport);
      end;

      // get ranked slopes and median estimator
      SetLength(RankedQ, 500);       // wp: overcome initialization issue with NoVars.
      count := 0;
      for i := 0 to NoCases-2 do
        for k := i+1 to NoCases-1 do
        begin
          RankedQ[count] := Slopes[i,k];
          count := count + 1;
          if count = Length(RankedQ) then
            SetLength(RankedQ, Length(RankedQ) + 500);
        end;
      SetLength(RankedQ, count);

      //sort into ascending order
      for i := 0 to count - 2 do
        for k := i + 1 to count-1 do
          if RankedQ[i] > RankedQ[k] then
            Exchange(RankedQ[i], RankedQ[k]);

      if PrtRanksChk.Checked then
      begin
        SetLength(RankLabels, count);
        for k := 0 to count-1 do
          RankLabels[k] := IntToStr(k+1);
        lReport.Add('Ranked Slopes');
        for i := 0 to count-1 do
          lReport.Add('Label: %s, Ranked Q: %8.3f', [RankLabels[i], RankedQ[i]]);
          // lReport.Add('Label: %d, Ranked Q: %8.3f', [k+1, RankedQ[i]]); <--- wp: test this. It should avoid using the RankLabela array
        lReport.Add('');
        lReport.Add(DIVIDER);
        lReport.Add('');
        RankLabels := nil;
      end;

      // get median slope
      half := count div 2;
      if (2 * half) < count then       // wp: Isn't this the same as "odd(count)"?
        MedianSlope := RankedQ[half]
      else
        MedianSlope := (RankedQ[half-1] + RankedQ[half]) / 2.0;

      // get Mann-Kendall statistic based on tied values
      for i := 0 to NoCases-1 do
        Sorted[i] := Values[i,j];
      for i := 0 to NoCases-2 do
      begin
        for k := i+1 to NoCases-1 do
        begin
          if Sorted[i] > Sorted[k] then
            Exchange(Sorted[i], Sorted[k]);
        end;
      end;

      MannKendall := 0.0;
      q := 0;
      i := -1;
      while (i < NoCases-2) do
      begin
        i := i + 1;
        tp := 1; // no. of ties for pth (i) value
        for k := i + 1 to NoCases-1 do
        begin
          if Sorted[k] <> Sorted[i] then
          begin
            i := k-1;
            break;
          end else
            tp := tp + 1;
        end; // next k

        if tp > 1 then
        begin
          q := q + 1;
          MannKendall := MannKendall + (tp * (tp-1) * (2 * tp + 5));
        end;
      end; // end next i
      MannKendall := (NoCases * (NoCases-1) * (2 * NoCases + 5) - MannKendall) / 18.0;
      Z := inversez(Alpha);
      if MannKendall > 0 then
      begin
        C := Z * sqrt(MannKendall);
        M1 := (count - C) / 2.0;
        M2 := (count + C) / 2.0;
      end else
        lReport.Add('Error: z: %8.3f, Mann-Kendall: %8.3f', [Z, MannKendall]);

      // show results
      if j < noselected then
        lReport.Add('Results for %s', [cellstring])
      else
        lReport.Add('Results for Averaged Values');

      if (noselected > 1) and Standardize then
      begin
        mean := 0.0;
        stddev := 0.0;
        for i := 0 to NoCases-1 do
        begin
          mean := mean + Values[i,j];
          stddev := stddev + sqr(Values[i,j]);
        end;
        stddev := stddev - sqr(mean) / NoCases;
        stddev := stddev / (NoCases - 1);
        stddev := sqrt(stddev);
        mean := mean / NoCases;
        lReport.Add('Mean: %8.3f,  Standard Deviation = %8.3f', [mean, stddev]);
      end;

      lReport.Add('Median Slope for %d values: %8.3f', [count, MedianSlope]);
      lReport.Add('Mann-Kendall Variance statistic: %8.3f (%d ties)', [MannKendall, q]);
      lReport.Add('Ranks of the lower and upper confidence: %8.3f, %8.3f', [M1, M2+1]);

      low := round(M1 - 1.0);
      if ((M1-1) - low) > 0.5 then low := round(M1-1);
      hi := round(M2);
      if (M2 - hi) > 0.5 then hi := round(M2);
      if (low > 0) or (hi <= count) then
        lReport.Add('Corresponding lower and upper slopes: %8.3f, %8.3f', [RankedQ[low], RankedQ[hi]])
      else
        lReport.Add('ERROR! low rank = %d, hi rank = %d', [low, hi]);
      lReport.Add('');

      // plot slopes if elected
      if Plot then
      begin
        SetLength(GraphFrm.Xpoints,1,NoCases+1);
        SetLength(GraphFrm.Ypoints,1,NoCases+1);
        GraphFrm.GraphType := 2;
        GraphFrm.nosets := 1;
        GraphFrm.nbars := NoCases;
        GraphFrm.BackColor := GRAPH_BACK_COLOR;
        GraphFrm.WallColor := GRAPH_WALL_COLOR;
        GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
        if j < noselected then
          GraphFrm.Heading := OS3MainFrm.DataGrid.Cells[col,0]
        else
          GraphFrm.Heading := 'Average Values';
        GraphFrm.barwideprop := 1.0;
        GraphFrm.AutoScaled := true;
        GraphFrm.ShowLeftWall := true;
        GraphFrm.ShowRightWall := true;
        GraphFrm.ShowBottomWall := true;
        GraphFrm.YTitle := 'Measure';
        GraphFrm.XTitle := 'Time';
        for k := 0 to NoCases - 1 do
        begin
          GraphFrm.Ypoints[0,k] := Values[k,j];
          GraphFrm.Xpoints[0,k] := k+1;
        end;
        if GraphFrm.ShowModal <> mrOK then
          exit;

        GraphFrm.Ypoints := nil;
        GraphFrm.Xpoints := nil;
      end;

      // plot ranked slopes if elected
      if SlopePlot then
      begin
        SetLength(GraphFrm.Xpoints,1,count+1);
        SetLength(GraphFrm.Ypoints,1,count+1);
        GraphFrm.GraphType := 2;
        GraphFrm.nosets := 1;
        GraphFrm.nbars := count;
        GraphFrm.BackColor := GRAPH_BACK_COLOR;
        GraphFrm.WallColor := GRAPH_WALL_COLOR;
        GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
        GraphFrm.Heading := 'Ranked Slopes';
        GraphFrm.barwideprop := 1.0;
        GraphFrm.AutoScaled := true;
        GraphFrm.ShowLeftWall := true;
        GraphFrm.ShowRightWall := true;
        GraphFrm.ShowBottomWall := true;
        GraphFrm.YTitle := 'Slope';
        GraphFrm.XTitle := 'Rank';
        for k := 0 to count - 1 do
        begin
          GraphFrm.Ypoints[0,k] := RankedQ[k];
          GraphFrm.Xpoints[0,k] := k+1;
        end;
        if not GraphFrm.ShowModal = mrOK then
          exit;

        GraphFrm.Ypoints := nil;
        GraphFrm.Xpoints := nil;
      end;

      lReport.Add('');
      lReport.Add(DIVIDER);
      lReport.Add('');
    end; // next variable j

    if AvgSlope then
      for i := 0 to NoCases-2 do
        for k := i + 1 to NoCases-1 do
          AvgSlopes[i,k] := AvgSlopes[i,k] + Slopes[i,k];

    // Average multiple measures
    if AvgSlope then
    begin
      lReport.Add('Results for Averaged Slopes');
      for i := 0 to NoCases-2 do
        for k := i + 1 to NoCases-1 do
          AvgSlopes[i,k] := AvgSlopes[i,k] / noselected;

      // get ranked slopes and median estimator
      count := 0;
      for i := 0 to NoCases-2 do
      begin
        for j := i + 1 to NoCases-1 do
        begin
          RankedQ[count] := AvgSlopes[i,j];
          count := count + 1;
        end;
      end;
      for i := 0 to Count-2 do
        for j := i + 1 to count - 1 do
          if RankedQ[i] > RankedQ[j] then
            Exchange(RankedQ[i], RankedQ[j]);

      // get median slope
      half := count div 2;
      if (2 * half) < count then       // again: should be "odd(count)"
        MedianSlope := RankedQ[half + 1]
      else
        MedianSlope := (RankedQ[half] + RankedQ[half+1]) / 2.0;

      // get Mann-Kendall statistic based on tied values
      MannKendall := 0.0;
      q := 0;
      i := -1;
      while (i < count-1) do
      begin
        i := i + 1;
        tp := 1; // no. of ties for pth (i) value
        for j := i + 1 to count-1 do
        begin
          if RankedQ[j] <> RankedQ[i] then
          begin
            i := j - 1;
            break;
          end else
            tp := tp + 1;
        end;
        if tp > 1 then
        begin
          q := q + 1;
          MannKendall := MannKendall + (tp * (tp-1) * (2 * tp + 5));
        end;
      end; // end do while
      MannKendall := (NoCases * (NoCases-1) * (2 * NoCases + 5) - MannKendall) / 18.0;
      Z := inversez(Alpha);
      if MannKendall < 0.0 then
        MessageDlg(Format('Error in calculating Mann-Kendall: %8.3f', [MannKendall]), mtError, [mbOK], 0);
      if MannKendall > 0.0 then
        C := Z * sqrt(MannKendall)
      else
        C := Z;
      M1 := (count - C) / 2.0;
      M2 := (count + C) / 2.0;

      // Show results
      lReport.Add('Median Slope for %d values: %8.3f for averaged measures', [count, MedianSlope]);
      lReport.Add('Mann-Kendall Variance statistic: %8.3f (%d ties observed)', [MannKendall, q]);
      lReport.Add('Ranks of the lower and upper confidence: (%8.3f, %8.3f)', [M1, M2]);

      low := round(M1) - 1;
      if ((M1-1) - low) > 0.5 then low := round(M1 - 1);
      hi := round(M2);
      if (M2 - hi) > 0.5 then hi := round(M2);
      lReport.Add('Corresponding lower and upper slopes: (%8.3f, %8.3f)', [RankedQ[low],RankedQ[hi]]);
    end; // end if average slope

    DisplayReport(lReport);

  finally
    lReport.Free;
    AvgSlopes := nil;
    Sorted := nil;
    RankedQ := nil;
    Slopes := nil;
    Values := nil;
    selected := nil;
    ColLabels := nil;
    RowLabels := nil;
  end;
end;

procedure TSensForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TSensForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TSensForm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < SelectedList.Items.Count do
  begin
    if SelectedList.Selected[i] then
    begin
      VarList.Items.Add(SelectedList.Items[i]);
      SelectedList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TSensForm.UpdateBtnStates;
begin
  InBtn.Enabled := AnySelected(VarList);
  OutBtn.Enabled := AnySelected(SelectedList);
  AllBtn.Enabled := Varlist.Items.Count > 0;
end;

procedure TSensForm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I sensunit.lrs}

end.

