// wp: Unit not tested due to missing documentation
//     Tried to reproduce https://www.youtube.com/watch?v=RtC9ZMOYgk8
//     --> does not work...

unit MedianPolishUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit, GraphLib;

type

  { TMedianPolishForm }

  TMedianPolishForm = class(TForm)
    Bevel1: TBevel;
    NormChk: TCheckBox;
    MaxEdit: TEdit;
    Label4: TLabel;
    ItersBtn: TRadioButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    DepVar: TEdit;
    Fact1In: TBitBtn;
    Fact1Out: TBitBtn;
    Fact2In: TBitBtn;
    Fact2Out: TBitBtn;
    Factor1: TEdit;
    Factor2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    StaticText1: TStaticText;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure Fact1InClick(Sender: TObject);
    procedure Fact1OutClick(Sender: TObject);
    procedure Fact2InClick(Sender: TObject);
    procedure Fact2OutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: boolean;
    CumRowResiduals: DblDyneVec;
    CumColResiduals: DblDyneVec;
    function Median(const X: DblDyneVec; ASize: integer): double;
    procedure PrintObsTable(const ObsTable: DblDyneMat; NRows, NCols: integer;
      AReport: TStrings);
    procedure PrintResults(const ObsTable: DblDyneMat; const
      RowMedian, RowResid, ColMedian, ColResid: DblDyneVec;
      NRows, NCols: integer; AReport: TStrings);
    procedure SortValues(const X: DblDyneVec; ASize: integer);
    procedure TwoWayPlot(NF1cells: integer; const RowSums: DblDyneVec;
      const AGraphTitle, AHeading: string);
    procedure InteractPlot(NF1cells, NF2Cells: integer; const ObsTable: DblDyneMat;
      const AGraphTitle, AHeading: string);
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  MedianPolishForm: TMedianPolishForm;

implementation

uses
  Math, Utils;

{ TMedianPolishForm }

procedure TMedianPolishForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  DepVar.Text := '';
  Factor1.Text := '';
  Factor2.Text := '';
  ItersBtn.Checked := false;
  NormChk.Checked := false;
  UpdateBtnStates;
end;

procedure TMedianPolishForm.ComputeBtnClick(Sender: TObject);
var
  NoSelected, DepVarCol, F1Col, F2Col, i, j, k : integer;
  minrow, maxrow, mincol, maxcol : integer;
  intvalue, xrange, yrange, row, col, N, count, iteration : integer;
  X, M, sumrowmedians, sumcolmedians, GrandMedian, scale, TotResid : double;
  SumAbsRows, SumAbsCols, SumAbsTable, TableSum, explained : double;
  Q1, Q3, Qrange1, Qrange2, total : double;
  ColNoSelected : IntDyneVec;
  Observed : DblDyneCube;
  Residuals : DblDyneCube;
  RowResiduals : DblDyneVec;
  ColResiduals : DblDyneVec;
  RowMedian : DblDyneVec;
  ColMedian : DblDyneVec;
  CellCount : IntDyneMat;
  GroupScores : DblDyneVec;
  ObsTable : DblDyneMat;
  cellstring : string;
  single : boolean;
  NoIterations : integer;
  done : boolean;
  WholeTable : DblDyneVec;
  RowEffects : DblDyneVec;
  ColEffects : DblDyneVec;
  floatValue: Double;
  lReport: TStrings;
begin
  if DepVar.Text = '' then
  begin
     MessageDlg('No dependant variable selected.', mtError, [mbOK], 0);
     exit;
  end;
  if Factor1.Text = '' then
  begin
     MessageDlg('No Factor 1 variable selected.', mtError, [mbOK], 0);
     exit;
  end;
  if Factor2.Text = '' then
  begin
     MessageDlg('No Factor 2 variable selected.', mtError, [mbOK], 0);
     exit;
  end;
  if MaxEdit.Text = '' then
  begin
     MaxEdit.SetFocus;
     MessageDlg('Max. iterations not specified.', mtError, [mbOK], 0);
     exit;
  end;
  if not TryStrToInt(MaxEdit.Text, NoIterations) or (NoIterations < 0) then
  begin
    MaxEdit.SetFocus;
    MessageDlg('Invalid input for Max iterations.', mtError, [mbOk], 0);
    exit;
  end;

  lReport := TStringList.Create;
  try
    for i := 1 to NoVariables do
    begin
      cellstring := Trim(OS3MainFrm.DataGrid.Cells[i,0]);
      if cellstring = DepVar.Text then DepVarCol := i;
      if cellstring = Factor1.Text then F1Col := i;
      if cellstring = Factor2.Text then F2Col := i;
    end;
    NoSelected := 3;
    SetLength(ColNoSelected,3);
    ColNoSelected[0] := DepVarCol;
    ColNoSelected[1] := F1Col;
    ColNoSelected[2] := F2Col;

    // get no. of rows and columns (Factor 1 and Factor 2)
    mincol := 10000;
    maxcol := 0;
    minrow := 10000;
    maxrow := 0;
    for i := 1 to NoCases do
    begin
      if TryStrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i]), floatValue) and
         (Frac(floatValue) = 0) then
      begin
        intValue := trunc(floatValue);
        if intvalue > maxrow then maxrow := intvalue;
        if intvalue < minrow then minrow := intvalue;
      end else
      begin
        MessageDlg(Format('Integer value expected in cell at column %d and cell %d', [F1Col, i]), mtError, [mbOK], 0);
        exit;
      end;

      if TryStrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i]), floatValue) and
        (Frac(floatvalue) = 0) then
      begin
        intValue := trunc(floatValue);
        if intvalue > maxcol then maxcol := intvalue;
        if intvalue < mincol then mincol := intvalue;
      end else
      begin
        MessageDlg(Format('Integer value expected in cell at column %d and cell %d', [F2Col, i]), mtError, [mbOK], 0);
        exit;
      end;
    end;

    xrange := maxrow - minrow + 1;
    yrange := maxcol - mincol + 1;

    // get no. of observations in each cell
    SetLength(CellCount,xrange,yrange);
    for i := 0 to xrange-1 do
      for j := 0 to yrange-1 do
        CellCount[i,j] := 0;

    count := 0;
    for i := 1 to NoCases do
    begin
      row := trunc(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i])));
      row := row - minrow;
      col := trunc(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i])));
      col := col - mincol;
      CellCount[row,col] := CellCount[row,col] + 1;
      count := count + 1;
    end;
    single := (count = (xrange * yrange));

    SetLength(Observed, NoCases, xrange, yrange);
    SetLength(Residuals, NoCases, xrange, yrange);
    SetLength(RowResiduals, xrange);
    SetLength(ColResiduals, yrange);
    SetLength(GroupScores, NoCases);
    SetLength(RowMedian, xrange);
    SetLength(ColMedian, yrange);
    SetLength(CumRowResiduals, xrange);
    SetLength(CumColResiduals, yrange);
    SetLength(WholeTable, xrange * yrange);
    SetLength(RowEffects, xrange);
    SetLength(ColEffects, yrange);

    for i := 0 to NoCases-1 do
    begin
      for j := 0 to xrange-1 do
        for k := 0 to yrange-1 do
        begin
          Observed[i,j,k] := 0.0;
          Residuals[i,j,k] := 0.0;
        end;
    end;

    for j := 0 to xrange-1 do
    begin
      RowResiduals[j] := 0.0;
      CumRowResiduals[j] := 0.0;
    end;

    for j := 0 to yrange-1 do
    begin
      ColResiduals[j] := 0.0;
      CumColResiduals[j] := 0.0;
    end;

    // Get observed scores
    for i := 0 to xrange-1 do
      for j := 0 to yrange-1 do
        CellCount[i,j] := 0;
    for i := 1 to NoCases do
    begin
      row := trunc(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i]))) - minrow;
      col := trunc(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i]))) - minCol;
      X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepVarCol,i]));
      CellCount[row, col] := CellCount[row, col] + 1;
      N := CellCount[row, col];
      Observed[N-1, row, col] := X;
    end;

    // if not single case in each cell, obtain median for each cell
    if not single then
    begin
      for i := 0 to xrange-1 do
      begin
        for j := 0 to yrange-1 do
        begin
          for k := 0 to CellCount[i,j]-1 do
            GroupScores[k] := Observed[k,i,j];
          M := Median(GroupScores,CellCount[i,j]);
          Observed[0,i,j] := M;
        end;
      end;
    end;

    SetLength(ObsTable, xrange, yrange);
    k := 0;
    for i := 0 to xrange-1 do
    begin
      for j := 0 to yrange-1 do
      begin
        ObsTable[i,j] := Observed[0,i,j];
        WholeTable[k] := Observed[0,i,j];
        k := k + 1;
      end;
    end;

    SortValues(WholeTable, xrange * yrange);
    Q1 := Quartiles(2, 0.25, xrange*yrange, WholeTable);
    Q3 := Quartiles(2, 0.75, xrange*yrange, WholeTable);
    QRange1 := Q3 - Q1;
    lReport.Add('Quartiles of original data: %8.3f and %.3f', [Q1,Q3]);
    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // Bill Miller's solution

    if NormChk.Checked then
    begin
      lReport.Add('BILL MILLER''s SOLUTION');
      lReport.Add('');
      // get deviations of each cell from the grand mean, row and column residuals
      // and row and column absolute deviations
      k := 0;
      for i := 0 to xrange-1 do
        for j := 0 to yrange-1 do
        begin
          ObsTable[i,j] := Observed[0,i,j];
          WholeTable[k] := Observed[0,i,j];
          k := k + 1;
        end;

      SortValues(WholeTable, xrange * yrange);
      GrandMedian := Median(WholeTable, xrange * yrange);

      lReport.Add('Grand Median: %9.3f', [GrandMedian]);
      lReport.Add('');

      PrintObsTable(ObsTable, xrange, yrange, lReport);

      lReport.Add('');
      lReport.Add(DIVIDER);
      lReport.Add('');

      for i := 0 to xrange-1 do
      begin
        RowMedian[i] := 0.0;
        RowResiduals[i] := 0.0;
        CumRowResiduals[i] := 0.0;
      end;
      for j := 0 to yrange-1 do
      begin
        ColMedian[j] := 0.0;
        ColResiduals[j] := 0.0;
        CumColResiduals[j] := 0.0;
      end;

      for i := 0 to xrange-1 do
      begin
        for j := 0 to yrange-1 do
          GroupScores[j] := ObsTable[i,j];
        SortValues(GroupScores, yrange);
        RowMedian[i] := Median(GroupScores, yrange);
      end;

      for i := 0 to xrange-1 do
      begin
        for j := 0 to yrange-1 do
          RowResiduals[i] := RowResiduals[i] + (ObsTable[i,j] - RowMedian[i]);
        CumRowResiduals[i] := CumRowResiduals[i] + abs(RowResiduals[i]);
      end;

      for j := 0 to yrange-1 do
      begin
        for i := 0 to xrange-1 do
          GroupScores[i] := ObsTable[i,j];
        SortValues(GroupScores, xrange);
        ColMedian[j] := Median(GroupScores, xrange);
      end;

      for j := 0 to yrange-1 do
      begin
        for i := 0 to xrange-1 do
          ColResiduals[j] := ColResiduals[j] + (ObsTable[i,j] - ColMedian[j]);
        CumColResiduals[j] := CumColResiduals[j] + abs(ColResiduals[j]);
      end;

      PrintResults(ObsTable, RowMedian, RowResiduals, ColMedian, ColResiduals, xrange, yrange, lReport);

      lReport.Add('');
      lReport.Add(DIVIDER);
      lReport.Add('');

      //     TwoWayPlot(xrange, RowMedian,'Rows','ROW MEDIANS');
      //     TwoWayPlot(yrange, ColMedian,'Columns','COL. MEDIANS');

      // Normalize medians and raw data
      // This will result in the sum of column, row and table residuals all
      // summing to zero.  The model is X = Total Median + Row effects +
      // col. effects + interaction effects and the row, col and interaction
      // effects each sum to zero (as in ANOVA)
      TableSum := 0.0;
      scale := 0;
      for i := 0 to xrange-1 do
        for j := 0 to yrange-1 do
          scale := scale + ObsTable[i,j];
      scale := scale / (xrange * yrange);
      for i := 0 to xrange-1 do
        for j := 0 to yrange-1 do
        begin
          ObsTable[i,j] := ObsTable[i,j] - scale;
          TableSum := TableSum + abs(ObsTable[i,j]);
        end;

      lReport.Add('Normalized Data');
      PrintObsTable(ObsTable, xrange, yrange, lReport);
      lReport.Add('');

      scale := 0;
      for i := 0 to xrange-1 do scale := scale + RowMedian[i];
      scale := scale / xrange;
      for i := 0 to xrange-1 do RowMedian[i] := RowMedian[i] - scale;
      scale := 0;
      for j := 0 to yrange-1 do scale := scale + ColMedian[j];
      scale := scale / yrange;
      for j := 0 to yrange-1 do ColMedian[j] := ColMedian[j] - scale;

      lReport.Add('Normalized  Adjusted Data');
      PrintResults(ObsTable, RowMedian, RowResiduals, ColMedian, ColResiduals, xrange, yrange, lReport);
      lReport.Add('');

      for i := 0 to xrange-1 do
        for j := 0 to yrange-1 do
          ObsTable[i,j] := ObsTable[i,j] - (RowMedian[i] + ColMedian[j]);

      lReport.Add('Normalized Table minus Row and Column Medians');
      PrintObsTable(ObsTable, xrange, yrange, lReport);
      lReport.Add('');

      for i := 0 to xrange-1 do RowResiduals[i] := 0.0;
      for j := 0 to yrange-1 do ColResiduals[j] := 0.0;
      TotResid := 0.0;
      for i := 0 to xrange-1 do
        for j := 0 to yrange-1 do
        begin
          RowResiduals[i] := RowResiduals[i] + ObsTable[i,j];
          ColResiduals[j] := ColResiduals[j] + ObsTable[i,j];
          TotResid := TotResid + ObsTable[i,j];
        end;

      lReport.Add('Normalized  Adjusted Data');
      PrintResults(ObsTable, RowMedian, RowResiduals, ColMedian, ColResiduals, xrange, yrange, lReport);
      lReport.Add('');
      lReport.Add('Total Table Residuals:         %8.3f', [TotResid]);
      lReport.Add('');

      SumAbsRows := 0.0;
      SumAbsCols := 0.0;
      SumAbsTable := 0.0;
      for i := 0 to xrange-1 do
        SumAbsRows := SumAbsRows + abs(RowMedian[i]);
      for j := 0 to yrange-1 do
        SumAbsCols := SumAbsCols + abs(ColMedian[j]);
      for i := 0 to xrange - 1 do
        for j := 0 to yrange - 1 do
          SumAbsTable := SumAbsTable + abs(ObsTable[i,j]);
      lReport.Add('Absolute Sums of Row:          %8.3f', [SumAbsRows]);
      lReport.Add('              of Col:          %8.3f', [SumAbsCols]);
      lReport.Add('              of Interactions: %8.3f', [SumAbsTable]);
      total := SumAbsRows + SumAbsCols + SumAbsTable;
      lReport.Add('Absolute Sums of Table Values prior to Extracting Row and Col.: %8.3f', [TableSum]);
      lReport.Add('Percentages explained by rows:                                  %8.3f %%', [100.0 * SumAbsRows / total]);
      lReport.Add('                         cols:                                  %8.3f %%', [100.0 * SumAbscols / total]);
      lReport.Add('                         interactions plus error:               %8.3f %%', [100*SumAbsTable/total]);

      explained := 100*SumAbsRows/total + 100*SumAbsCols/total + 100*SumAbsTable/total;
      lReport.Add('Percentage explained:                                           %8.3f %%', [explained]);

      lReport.Add('');
      lReport.Add(DIVIDER);
      lReport.Add('');

      TwoWayPlot(xrange, RowMedian, 'Rows', 'ROW MEDIANS');
      TwoWayPlot(yrange, ColMedian, 'Columns', 'COL. MEDIANS');
    end; // Bills method

    // Now do traditional median smoothing
    lReport.Add('TUKEY ITERATIVE MEDIAN SMOOTHING METHOD');
    lReport.Add('');

    done := false;
    iteration := 1;
    for i := 0 to xrange-1 do
      RowEffects[i] := 0.0;
    for j := 0 to yrange-1 do
      ColEffects[j] := 0.0;
    while not done do
    begin
      // Get residuals from the median for each row
      count := 0;
      for i := 0 to xrange-1 do
      begin
        count := 0;
        for j := 0 to yrange-1 do
        begin
          GroupScores[count] := Observed[0,i,j];
          count := count + 1;
        end;
        SortValues(GroupScores, count);
        M := Median(GroupScores, count);
        RowMedian[i] := M;
        for j := 0 to yrange-1 do Observed[0,i,j] := Observed[0,i,j] - M;
        for j := 0 to yrange-1 do RowResiduals[i] := RowResiduals[i] + Observed[0,i,j];
        CumRowResiduals[i] := CumRowResiduals[i] + abs(RowResiduals[i]);
      end;

      // get sum of residuals for cols
      count := 0;
      for i := 0 to yrange-1 do
      begin
        count := 0;
        for j := 0 to xrange-1 do
        begin
          GroupScores[count] := Observed[0,j,i];
          count := count + 1;
        end;
        SortValues(GroupScores, count);
        M := Median(GroupScores, count);
        ColMedian[i] := M;
        for j := 0 to xrange-1 do Observed[0,j,i] := Observed[0,j,i] - M;
        for j := 0 to xrange-1 do ColResiduals[i] := ColResiduals[i] + Observed[0,j,i];
        CumColResiduals[i] := CumColResiduals[i] + abs(ColResiduals[i]);
      end;

      // build table of results
      for i := 0 to xrange-1 do
        for j := 0 to yrange-1 do
          ObsTable[i,j] := Observed[0,i,j]; // Residuals[0,i,j];

//        if ItersBtn.Checked then
//        begin
      lReport.Add('Iteration %d', [iteration]);
      PrintResults(ObsTable, RowMedian, RowResiduals, ColMedian, ColResiduals, xrange, yrange, lReport);
      lReport.Add('');

      lReport.Add('Row Effects');
      for i := 0 to xrange-1 do
        GroupScores[i] := RowMedian[i];

      SortValues(GroupScores, xrange);
      M := Median(GroupScores, xrange);
      lReport.Add('Overall Median: %8.3f', [M]);
      lReport.Add('');

      for i := 0 to xrange-1 do
      begin
        RowEffects[i] := RowEffects[i] + (RowMedian[i] - M);
        lReport.Add('Row %3d Effect: %8.3f', [i+1, RowEffects[i]]);
      end;
      lReport.Add('');

      lReport.Add('Column Effects');
      for j := 0 to yrange-1 do
      begin
        ColEffects[j] := ColEffects[j] + ColMedian[j];
        lReport.Add('Col. %3d Effect: %8.3f', [j+1, ColEffects[j]]);
      end;
      lReport.Add('');
//             OutputFrm.ShowModal;
//             OutputFrm.RichEdit.Clear;
//        end;

      for i := 0 to xrange-1 do RowResiduals[i] := 0.0;
      for j := 0 to yrange-1 do ColResiduals[j] := 0.0;
      NoIterations := NoIterations - 1;
      iteration := iteration + 1;
      if NoIterations = 0 then done := true;
      sumrowmedians := 0.0;
      sumcolmedians := 0.0;
      for i := 0 to xrange-1 do sumrowmedians := sumrowmedians + RowMedian[i];
      for i := 0 to yrange-1 do sumcolmedians := sumcolmedians + ColMedian[i];
      if (sumrowmedians + sumcolmedians) = 0.0 then done := true;
      if done then
      begin
        lReport.Add('SUMMARY OF THE ANALYSIS');
        PrintResults(ObsTable, RowMedian, RowResiduals, ColMedian, ColResiduals, xrange, yrange, lReport);
        for i := 0 to xrange-1 do
        begin
          RowEffects[i] := RowEffects[i] + (RowMedian[i] - M);
          lReport.Add('Row %3d Effect: %8.3f', [i+1, RowEffects[i]]);
        end;
        lReport.Add('');
        lReport.Add('Column Effects');
        for j := 0 to yrange-1 do
        begin
          ColEffects[j] := ColEffects[j] + ColMedian[j];
          lReport.Add('Col. %3d Effect: %8.3f', [j+1, ColEffects[j]]);
        end;
        lReport.Add('');

        k := 0;
        for i := 0 to xrange-1 do
          for j := 0 to yrange-1 do
          begin
            WholeTable[k] := ObsTable[i,j];
            k := k + 1;
          end;

        SortValues(WholeTable, xrange * yrange);
        M := Median(WholeTable, xrange * yrange);
        Q1 := Quartiles(2, 0.25, xrange * yrange, WholeTable);
        Q3 := Quartiles(2, 0.75, xrange * yrange, WholeTable);
        lReport.Add('Quartiles of the residuals: %8.3f and %.3f', [Q1, Q3]);
        Qrange2 := Q3 - Q1;
        lReport.Add('Original interquartile and final interquartile ranges: %8.3f and %.3f', [Qrange1, Qrange2]);
        if QRange1 <> 0 then
          lReport.Add('Quality of the additive fit: %8.3f %%', [100 * (QRange1 - QRange2) / QRange1]);
      end;
    end; // while not done

    DisplayReport(lReport);

//   if ItersBtn.Checked then
//   begin
    TwoWayPlot(xrange, RowEffects,'Rows','CUMULATIVE ROW EFFECTS');
    TwoWayPlot(yrange, ColEffects,'Columns','CUMULATIVE COL. EFFECTS');
    InteractPlot(xrange, yrange, ObsTable, 'Interaction', 'RESIDUALS OF ROWS AND COLUMNS');
//   end;
  finally
    lReport.Free;
    ColEffects := nil;
    RowEffects := nil;
    WholeTable := nil;
    CumColResiduals := nil;
    CumRowResiduals := nil;
    ObsTable := nil;
    ColMedian := nil;
    RowMedian := nil;
    GroupScores := nil;
    CellCount := nil;
    ColResiduals := nil;
    RowResiduals := nil;
    Residuals := nil;
    Observed := nil;
    ColNoSelected := nil;
  end;
end;

procedure TMedianPolishForm.DepInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepVar.Text = '') then
  begin
     DepVar.Text := VarList.Items[index];
     VarList.Items.Delete(index);
     UpdateBtnStates;
  end;
end;

procedure TMedianPolishForm.DepOutClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TMedianPolishForm.Fact1InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Factor1.Text = '') then
  begin
    Factor1.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TMedianPolishForm.Fact1OutClick(Sender: TObject);
begin
  if Factor1.Text <> '' then
  begin
    VarList.Items.Add(Factor1.Text);
    Factor1.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TMedianPolishForm.Fact2InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Factor2.Text = '') then
  begin
    Factor2.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TMedianPolishForm.Fact2OutClick(Sender: TObject);
begin
  if Factor2.Text <> '' then
  begin
    VarList.Items.Add(Factor2.Text);
    Factor2.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TMedianPolishForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Panel1.Constraints.MinWidth := NormChk.Width * 2 - DepIn.Width div 2;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TMedianPolishForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

function TMedianPolishForm.Median(const X: DblDyneVec; ASize: integer): double;
var
  midpt: integer;
begin
  if ASize > 2 then
  begin
    midpt := ASize div 2;
    if odd(ASize) then
      Result := X[midPt]
    else
      Result := (X[midPt-1] + x[midPt]) / 2;
    {
    if 2 * midpt = ASize then  // even no. of values
      Result := (X[midpt-1] + X[midpt]) / 2
    else
      Result := X[midpt];  // odd no. of values
      }
  end
  else if ASize = 2 then
    Result := (X[0] + X[1]) / 2;
end;

procedure TMedianPolishForm.PrintObsTable(const ObsTable: DblDyneMat;
  NRows, NCols: integer; AReport: TStrings);
var
  outline: string;
  i, j: integer;
begin
  AReport.Add('Observed Data');
  AReport.Add('ROW            COLUMNS');

  outline := '  ';
  for i := 1 to NCols do
    outline := outline + Format('%10d', [i]);
  AReport.Add(outline);

  for i := 1 to NRows do
  begin
    outline := Format('%3d ', [i]);
    for j := 1 to ncols do
      outline := outline + Format('%9.3f ', [ObsTable[i-1, j-1]]);
    AReport.Add(outline);
  end;
end;

procedure TMedianPolishForm.PrintResults(const ObsTable: DblDyneMat;
  const RowMedian, RowResid, ColMedian, ColResid: DblDyneVec;
  NRows, NCols: integer; AReport: TStrings);
var
  i, j: integer;
  outline: string;
begin
  AReport.Add('Adjusted Data');
  outline := 'MEDIAN';
  for i := 1 to NCols do
    outline := outline + Format('%10d',[i]);
  outline := outline + '     Residuals';
  AReport.Add(outline);

  AReport.Add('---------------------------------------------------------');

  for i := 0 to NRows-1 do
  begin
    outline := Format('%9.3f ', [rowmedian[i]]);
    for j := 0 to NCols-1 do
      outline := outline + Format('%9.3f ', [ObsTable[i,j]]);
    AReport.Add(outline + Format('%9.3f ', [RowResid[i]]));
  end;

  AReport.Add('---------------------------------------------------------');

  outline := 'Col.Resid.';
  for j := 0 to NCols-1 do
    outline := outline + Format('%9.3f ', [ColResid[j]]);
  AReport.Add(outline);

  outline := 'Col.Median';
  for j := 0 to NCols-1 do
    outline := outline + Format('%9.3f ', [ColMedian[j]]);
  AReport.Add(outline);
  AReport.Add('');

  AReport.Add('Cumulative absolute value of Row Residuals');
  for j := 0 to NRows-1 do
    AReport.Add('Row %3d:  Cum.Residuals: %9.3f', [j+1, CumRowResiduals[j]]);
  AReport.Add('');

  AReport.Add('Cumulative absolute value of Column Residuals');
  for j := 0 to NCols-1 do
    AReport.Add('Column %3d:  Cum.Residuals: %9.3f', [j+1, CumColResiduals[j]]);
end;

procedure TMedianPolishForm.SortValues(const X: DblDyneVec; ASize: integer);
var
  i, j: integer;
begin
  for i := 0 to ASize-2 do
    for j := i+1 to ASize-1 do
      if X[i] > X[j] then // swap
        Exchange(X[i], X[j]);
end;

procedure TMedianPolishForm.TwoWayPlot(NF1cells: integer;
  const RowSums: DblDyneVec; const AGraphTitle, AHeading: string);
var
  i: integer;
  minmean, maxmean: double;
begin
  GraphFrm.SetLabels[1] := 'Group';

  SetLength(GraphFrm.Xpoints, 1, NF1cells);
  SetLength(GraphFrm.Ypoints, 1, NF1cells);
  maxmean := -1E308;
  minmean := 1E308;
  for i := 0 to NF1cells - 1 do
  begin
    GraphFrm.XPoints[0, i] := i + 1;
    GraphFrm.YPoints[0, i] := RowSums[i];
    if RowSums[i] > maxMean then maxMean := RowSums[i];
    if RowSums[i] < minMean then minMean := RowSums[i];
  end;
  {
  for i := 1 to NF1cells do
  begin
    GraphFrm.Xpoints[0,i-1] := i;
    GraphFrm.Ypoints[0,i-1] := RowSums[i-1];
    if RowSums[i-1] > maxmean then maxmean := RowSums[i-1];
    if RowSums[i-1] < minmean then minmean := RowSums[i-1];
  end;
  }

  GraphFrm.NoSets := 1;
  GraphFrm.NBars := NF1cells;
  GraphFrm.Heading := AHeading;
  GraphFrm.XTitle := AGraphTitle;
  GraphFrm.YTitle := 'Y Values';
  GraphFrm.BarWideProp := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := minmean;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := 2;
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_WALL_COLOR;
  GraphFrm.ShowBackWall := true;

  GraphFrm.ShowModal;

  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;

procedure TMedianPolishForm.InteractPlot(NF1cells, NF2Cells: integer;
  const ObsTable: DblDyneMat; const AGraphTitle, AHeading: string);
var
  i, j: integer;
  minmean, maxmean, XBar: double;
begin
  SetLength(GraphFrm.Ypoints, NF1cells, NF2cells);
  SetLength(GraphFrm.Xpoints,1, NF2cells);

  maxmean := -1e308;
  minmean := 1e308;
  for i := 0 to NF1Cells-1 do
  begin
    GraphFrm.SetLabels[i+1] := 'Row ' + IntToStr(i+1);
    for j := 0 to NF2Cells - 1 do
    begin
      xbar := ObsTable[i, j];
      if xbar > maxMean then maxMean := xbar;
      if xbar < minMean then minMean := xbar;
      GraphFrm.YPoints[i, j] := xbar;
    end;
  end;
  for j := 0 to NF2cells-1 do
    GraphFrm.XPoints[0, j] := j+1;

  {
  for i := 1 to NF1cells do
  begin
    GraphFrm.SetLabels[i] := 'Row ' + IntToStr(i);
    for j := 1 to NF2cells do
    begin
      XBar := ObsTable[i-1,j-1];
      if XBar > maxmean then maxmean := XBar;
      if XBar < minmean then minmean := XBar;
      GraphFrm.Ypoints[i-1,j-1] := XBar;
    end;
  end;
  for j := 1 to NF2cells do
  begin
    XValue[j-1] := j;
    GraphFrm.Xpoints[0,j-1] := XValue[j-1];
  end;
  }

  GraphFrm.nosets := NF1cells;
  GraphFrm.nbars := NF2cells;
  GraphFrm.Heading := 'Factor X x Factor Y';
  GraphFrm.XTitle := 'Column Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := minmean;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := 2;
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;

  GraphFrm.ShowModal;

  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;

procedure TMedianPolishForm.VarListSelectionChange(Sender: TObject;
  User: boolean);
begin
  UpdateBtnStates;
end;

procedure TMedianPolishForm.UpdateBtnStates;
begin
  DepIn.Enabled := (VarList.ItemIndex > -1) and (DepVar.Text = '');
  Fact1In.Enabled := (VarList.itemIndex > -1) and (Factor1.Text = '');
  Fact2In.Enabled := (VarList.ItemIndex > -1) and (Factor2.Text = '');
  DepOut.Enabled := (DepVar.Text <> '');
  Fact1Out.Enabled := (Factor1.Text <> '');
  Fact2Out.Enabled := (Factor2.Text <> '');
end;


initialization
  {$I medianpolishunit.lrs}

end.

