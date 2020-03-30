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
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    DepIn1: TBitBtn;
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
    procedure DepIn1Click(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure Fact1InClick(Sender: TObject);
    procedure Fact1OutClick(Sender: TObject);
    procedure Fact2InClick(Sender: TObject);
    procedure Fact2OutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);

  private
    { private declarations }
    FAutoSized: boolean;
    CumRowResiduals : DblDyneVec;
    CumColResiduals : DblDyneVec;
    function Median(VAR X : DblDyneVec; size : integer) : double;
    procedure PrintObsTable(ObsTable : DblDyneMat; nrows, ncols : integer);
    procedure PrintResults(ObsTable : DblDyneMat; rowmedian,rowresid : DblDyneVec;
         comedian, colresid : DblDyneVec; nrows, ncols : integer);
    procedure sortvalues(VAR X : DblDyneVec; size : integer);
    procedure TwoWayPlot(NF1cells : integer; RowSums : DblDyneVec;
    graphtitle : string; Heading : string);
    procedure InteractPlot(NF1cells, NF2Cells : integer;
           ObsTable :DblDyneMat; graphtitle : string;
           Heading : string);
  public
    { public declarations }
  end; 

var
  MedianPolishForm: TMedianPolishForm;

implementation

uses
  Math;

{ TMedianPolishForm }

procedure TMedianPolishForm.ResetBtnClick(Sender: TObject);
var i : integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
       VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  DepVar.Text := '';
  Factor1.Text := '';
  Factor2.Text := '';
  DepIn1.Enabled := true;
  DepOut.Enabled := false;
  Fact1In.Enabled := true;
  Fact1Out.Enabled := false;
  Fact2In.Enabled := true;
  Fact2out.Enabled := false;
  ItersBtn.Checked := false;
  NormChk.Checked := false;
end;

procedure TMedianPolishForm.ComputeBtnClick(Sender: TObject);
VAR
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
begin
     OutputFrm.RichEdit.Clear;
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
          intvalue := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i]));
          if intvalue > maxrow then maxrow := intvalue;
          if intvalue < minrow then minrow := intvalue;
          intvalue := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i]));
          if intvalue > maxcol then maxcol := intvalue;
          if intvalue < mincol then mincol := intvalue;
     end;
     xrange := maxrow - minrow + 1;
     yrange := maxcol - mincol + 1;
    // get no. of observations in each cell
     SetLength(CellCount,xrange,yrange);
     for i := 0 to xrange-1 do
     begin
          for j := 0 to yrange-1 do
          begin
               CellCount[i,j] := 0;
          end;
     end;
     count := 0;
     single := false;
     for i := 1 to NoCases do
     begin
          row := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i]));
          row := row - minrow;
          col := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i]));
          col := col - mincol;
          CellCount[row,col] := CellCount[row,col] + 1;
          count := count + 1;
     end;
     if count = (xrange * yrange) then single := true;
     SetLength(Observed,NoCases,xrange,yrange);
     SetLength(Residuals,NoCases,xrange,yrange);
     SetLength(RowResiduals,xrange);
     SetLength(ColResiduals,yrange);
     SetLength(GroupScores,NoCases);
     SetLength(RowMedian,xrange);
     SetLength(ColMedian,yrange);
     SetLength(CumRowResiduals,xrange);
     SetLength(CumColResiduals,yrange);
     SetLength(WholeTable,xrange * yrange);
     SetLength(RowEffects,xrange);
     SetLength(ColEffects,yrange);

     for i := 0 to NoCases-1 do
     begin
          for j := 0 to xrange-1 do
          begin
               for k := 0 to yrange-1 do
               begin
                    Observed[i,j,k] := 0.0;
                    Residuals[i,j,k] := 0.0;
               end;
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
     begin
          for j := 0 to yrange-1 do
          begin
               CellCount[i,j] := 0;
          end;
     end;
     for i := 1 to NoCases do
     begin
          row := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[F1Col,i]));
          row := row - minrow;
          col := StrToInt(Trim(OS3MainFrm.DataGrid.Cells[F2Col,i]));
          col := col - mincol;
          X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[DepVarCol,i]));
          CellCount[row,col] := CellCount[row,col] + 1;
          N := CellCount[row,col];
          Observed[N-1,row,col] := X;
     end;

     // if not single case in each cell, obtain median for each cell
     if not single then
     begin
          for i := 0 to xrange-1 do
          begin
               for j := 0 to yrange-1 do
               begin
                    for k := 0 to CellCount[i,j]-1 do
                    begin
                         GroupScores[k] := Observed[k,i,j];
                    end;
                    M := Median(GroupScores,CellCount[i,j]);
                    Observed[0,i,j] := M;
               end;
          end;
     end;
     SetLength(ObsTable,xrange,yrange);
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
     sortvalues(WholeTable,xrange*yrange);
     Q1 := Quartiles(2,0.25,xrange*yrange,WholeTable);
     Q3 := Quartiles(2,0.75,xrange*yrange,WholeTable);
     Qrange1 := Q3 - Q1;
     cellstring := format('Quartiles of original data = %8.3f %8.3f',[Q1,Q3]);
     OutputFrm.RichEdit.Lines.Add(cellstring);

     if NormChk.Checked = true then
     begin
     // Bill Miller's solution
     // get deviations of each cell from the grand mean, row and column residuals
     // and row and column absolute deviations
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
     sortvalues(WholeTable,xrange*yrange);
     M := Median(WholeTable,xrange*yrange);
     GrandMedian := M;
//     OutputFrm.RichEdit.Clear;
     cellstring := Format('Grand Median = %9.3f',[M]);
     OutputFrm.RichEdit.Lines.Add(cellstring);
     OutputFrm.RichEdit.Lines.Add('');
     PrintObsTable(ObsTable,xrange,yrange);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
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
          begin
               GroupScores[j] := ObsTable[i,j];
          end;
          sortvalues(GroupScores,yrange);
          M := Median(GroupScores,yrange);
          RowMedian[i] := M;
     end;

     for i := 0 to xrange-1 do
     begin
          for j := 0 to yrange-1 do
          begin
               RowResiduals[i] := RowResiduals[i] + (ObsTable[i,j] - RowMedian[i]);
          end;
          CumRowResiduals[i] := CumRowResiduals[i] + abs(RowResiduals[i]);
     end;

     for j := 0 to yrange-1 do
     begin
          for i := 0 to xrange-1 do
          begin
               GroupScores[i] := ObsTable[i,j];
          end;
          sortvalues(GroupScores,xrange);
          M := Median(GroupScores,xrange);
          ColMedian[j] := M;
     end;

     for j := 0 to yrange-1 do
     begin
          for i := 0 to xrange-1 do
          begin
               ColResiduals[j] := ColResiduals[j] + (ObsTable[i,j] - ColMedian[j]);
          end;
          CumColResiduals[j] := CumColResiduals[j] + abs(ColResiduals[j]);
     end;
     PrintResults(ObsTable,RowMedian,RowResiduals,ColMedian,ColResiduals,xrange,yrange);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
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
     begin
          for j := 0 to yrange-1 do
          begin
               scale := scale + ObsTable[i,j];
          end;
     end;
     scale := scale / (xrange * yrange);
     for i := 0 to xrange-1 do
     begin
           for j := 0 to yrange-1 do
           begin
                ObsTable[i,j] := ObsTable[i,j] - scale;
                TableSum := TableSum + abs(ObsTable[i,j]);
           end;
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Normalized Data');
     PrintObsTable(ObsTable,xrange,yrange);
     scale := 0;
     for i := 0 to xrange-1 do scale := scale + RowMedian[i];
     scale := scale / xrange;
     for i := 0 to xrange-1 do RowMedian[i] := RowMedian[i] - scale;
     scale := 0;
     for j := 0 to yrange-1 do scale := scale + ColMedian[j];
     scale := scale / yrange;
     for j := 0 to yrange-1 do ColMedian[j] := ColMedian[j] - scale;

     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Normalized  Adjusted Data');
     PrintResults(ObsTable,RowMedian,RowResiduals,ColMedian,ColResiduals,xrange,yrange);
     OutputFrm.RichEdit.Lines.Add('');

     for i := 0 to xrange-1 do
     begin
          for j := 0 to yrange-1 do
          begin
               ObsTable[i,j] := ObsTable[i,j] - (RowMedian[i] + ColMedian[j]);
          end;
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Normalized Table minus Row and Column Medians');
     PrintObsTable(ObsTable,xrange,yrange);
     for i := 0 to xrange-1 do RowResiduals[i] := 0.0;
     for j := 0 to yrange-1 do ColResiduals[j] := 0.0;
     TotResid := 0.0;
     for i := 0 to xrange-1 do
     begin
          for j := 0 to yrange-1 do
          begin
               RowResiduals[i] := RowResiduals[i] + ObsTable[i,j];
               ColResiduals[j] := ColResiduals[j] + ObsTable[i,j];
               TotResid := TotResid + ObsTable[i,j];
          end;
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Normalized  Adjusted Data');
     PrintResults(ObsTable,RowMedian,RowResiduals,ColMedian,ColResiduals,xrange,yrange);
     OutputFrm.RichEdit.Lines.Add('');
     cellstring := format('Total Table Residuals = %8.3f',[TotResid]);
     OutputFrm.RichEdit.Lines.Add(cellstring);

     SumAbsRows := 0.0;
     SumAbsCols := 0.0;
     SumAbsTable := 0.0;
     for i := 0 to xrange-1 do SumAbsRows := SumAbsRows + abs(RowMedian[i]);
     for j := 0 to yrange-1 do SumAbsCols := SumAbsCols + abs(ColMedian[j]);
     for i := 0 to xrange - 1 do
         for j := 0 to yrange - 1 do
             SumAbsTable := SumAbsTable + abs(ObsTable[i,j]);
     cellstring := format('Absolute Sums of Row, Col and Interactions = %8.3f %8.3f %8.3f',
        [SumAbsRows, SumAbsCols, SumAbsTable]);
     OutputFrm.RichEdit.Lines.Add(cellstring);
     total := SumAbsRows + SumAbsCols + SumAbsTable;
     cellstring := format('Absolute Sums of Table Values prior to Extracting Row and Col. = %8.3f',
        [TableSum]);
     OutputFrm.RichEdit.Lines.Add(cellstring);
     cellstring := format('Percentages explained by rows, col.s, interactions plus error %8.3f %8.3f %8.3f',
        [100*SumAbsRows/total, 100*SumAbsCols/total, 100*SumAbsTable/total]);
     OutputFrm.RichEdit.Lines.Add(cellstring);
     explained := 100*SumAbsRows/total + 100*SumAbsCols/total + 100*SumAbsTable/total;
     cellstring := format('Percentage explained = %8.3f percent',[explained]);
     OutputFrm.RichEdit.Lines.Add(cellstring);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;

     TwoWayPlot(xrange, RowMedian,'Rows','ROW MEDIANS');
     TwoWayPlot(yrange, ColMedian,'Columns','COL. MEDIANS');
     end; // Bills method

     // Now do traditional median smoothing
     OutputFrm.RichEdit.Lines.Add('Tukey Iterative Median Smoothing Method');
     OutputFrm.RichEdit.Lines.Add('');
     NoIterations := StrToInt(MaxEdit.Text);
     done := false;
     iteration := 1;
     for i := 0 to xrange-1 do RowEffects[i] := 0.0;
     for j := 0 to yrange-1 do ColEffects[j] := 0.0;
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
               sortvalues(GroupScores,count);
               M := Median(GroupScores,count);
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
               sortvalues(GroupScores,count);
               M := Median(GroupScores,count);
               ColMedian[i] := M;
               for j := 0 to xrange-1 do Observed[0,j,i] := Observed[0,j,i] - M;
               for j := 0 to xrange-1 do ColResiduals[i] := ColResiduals[i] + Observed[0,j,i];
               CumColResiduals[i] := CumColResiduals[i] + abs(ColResiduals[i]);
          end;

          // build table of results
          for i := 0 to xrange-1 do
          begin
               for j := 0 to yrange-1 do
               begin
                    ObsTable[i,j] := Observed[0,i,j]; // Residuals[0,i,j];
               end;
          end;

//          if ItersBtn.Checked then
//          begin
               OutputFrm.RichEdit.Lines.Add('');
               cellstring := format('Iteration = %d',[iteration]);
               OutputFrm.RichEdit.Lines.Add(cellstring);
               PrintResults(ObsTable,RowMedian,RowResiduals,ColMedian,ColResiduals,xrange,yrange);
               OutputFrm.RichEdit.Lines.Add('');
               OutputFrm.RichEdit.Lines.Add('Row Effects');
               for i := 0 to xrange-1 do
               begin
                    GroupScores[i] := RowMedian[i];
               end;
               sortvalues(GroupScores,xrange);
               M := Median(GroupScores,xrange);
               cellstring := format('Overall Median = %8.3f',[m]);
               OutputFrm.RichEdit.Lines.Add(cellstring);
               OutputFrm.RichEdit.Lines.Add('');
               for i := 0 to xrange-1 do
               begin
                    RowEffects[i] := RowEffects[i] + (RowMedian[i] - M);
                    cellstring := format('Row %d Effect = %8.3f',[i+1,RowEffects[i]]);
                    OutputFrm.RichEdit.Lines.Add(cellstring);
               end;
               OutputFrm.RichEdit.Lines.Add('');
               OutputFrm.RichEdit.Lines.Add('Column Effects');
               for j := 0 to yrange-1 do
               begin
                    ColEffects[j] := ColEffects[j] + ColMedian[j];
                    cellstring := format('Col. %d Effect = %8.3f',[j+1,ColEffects[j]]);
                    OutputFrm.RichEdit.Lines.Add(cellstring);
               end;
//               OutputFrm.ShowModal;
//               OutputFrm.RichEdit.Clear;
//          end;
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
               OutputFrm.RichEdit.Lines.Add('');
               OutputFrm.RichEdit.Lines.Add('SUMMARY OF THE ANALYSIS');
               PrintResults(ObsTable,RowMedian,RowResiduals,ColMedian,ColResiduals,xrange,yrange);
               for i := 0 to xrange-1 do
               begin
                    RowEffects[i] := RowEffects[i] + (RowMedian[i] - M);
                    cellstring := format('Row %d Effect = %8.3f',[i+1,RowEffects[i]]);
                    OutputFrm.RichEdit.Lines.Add(cellstring);
               end;
               OutputFrm.RichEdit.Lines.Add('');
               OutputFrm.RichEdit.Lines.Add('Column Effects');
               for j := 0 to yrange-1 do
               begin
                    ColEffects[j] := ColEffects[j] + ColMedian[j];
                    cellstring := format('Col. %d Effect = %8.3f',[j+1,ColEffects[j]]);
                    OutputFrm.RichEdit.Lines.Add(cellstring);
               end;
               k := 0;
               OutputFrm.RichEdit.Lines.Add('');
               for i := 0 to xrange-1 do
               begin
                    for j := 0 to yrange-1 do
                    begin
                         WholeTable[k] := ObsTable[i,j];
                         k := k + 1;
                    end;
               end;
               sortvalues(WholeTable,xrange*yrange);
               M := Median(WholeTable,xrange*yrange);
               Q1 := Quartiles(2,0.25,xrange*yrange,WholeTable);
               Q3 := Quartiles(2,0.75,xrange*yrange,WholeTable);
               cellstring := format('Quartiles of the residuals = %8.3f %8.3f',
                  [Q1, Q3]);
               OutputFrm.RichEdit.Lines.Add(cellstring);
               Qrange2 := Q3 - Q1;
               cellstring := format('Original interquartile and final interquartile ranges = %8.3f %8.3f',
                    [Qrange1, Qrange2]);
               OutputFrm.RichEdit.Lines.Add(cellstring);
               cellstring := format('Quality of the additive fit = %8.3f percent',
                 [100 * (Qrange1 - Qrange2) / Qrange1]);
               OutputFrm.RichEdit.Lines.Add(cellstring);
               OutputFrm.ShowModal;
               OutputFrm.RichEdit.Clear;
          end;
     end; // while not done
//     if ItersBtn.Checked then
//     begin
          TwoWayPlot(xrange, RowEffects,'Rows','CUMULATIVE ROW EFFECTS');
          TwoWayPlot(yrange, ColEffects,'Columns','CUMULATIVE COL. EFFECTS');
          InteractPlot(xrange, yrange, ObsTable, 'Interaction',
           'RESIDUALS OF ROWS AND COLUMNS');
//     end;
     // cleanup
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

procedure TMedianPolishForm.DepIn1Click(Sender: TObject);
var index : integer;
begin
     index := VarList.ItemIndex;
     DepVar.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     DepIn1.Enabled := false;
     DepOut.Enabled := true;;
end;

procedure TMedianPolishForm.DepOutClick(Sender: TObject);
begin
  VarList.Items.Add(DepVar.Text);
  DepVar.Text := '';
  DepIn1.Enabled := true;
  DepOut.Enabled := false;
end;

procedure TMedianPolishForm.Fact1InClick(Sender: TObject);
var index : integer;
begin
     index := VarList.ItemIndex;
     Factor1.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     Fact1In.Enabled := false;
     Fact1Out.Enabled := true;;
end;

procedure TMedianPolishForm.Fact1OutClick(Sender: TObject);
begin
     VarList.Items.Add(Factor1.Text);
     Factor1.Text := '';
     Fact1In.Enabled := true;
     Fact1Out.Enabled := false;
end;

procedure TMedianPolishForm.Fact2InClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     Factor2.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     Fact2In.Enabled := false;
     Fact2Out.Enabled := true;;
end;

procedure TMedianPolishForm.Fact2OutClick(Sender: TObject);
begin
     VarList.Items.Add(Factor2.Text);
     Factor2.Text := '';
     Fact2In.Enabled := true;
     Fact2Out.Enabled := false;
end;

procedure TMedianPolishForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
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

function TMedianPolishForm.Median(VAR X : DblDyneVec; size : integer) : double;
var
   midpt : integer;
   value : double;
begin
(*  check for correct median calculation
     OutputFrm.RichEdit.Lines.Add('Sorted values to get median');
     cellstring := format('size of array = %d',[size]);
     OutputFrm.RichEdit.Lines.Add(cellstring);
     for i := 0 to size do
     begin
          cellstring := format('no. %d = %9.3f',[i+1,X[i]]);
          OutputFrm.RichEdit.Lines.Add(cellstring);
     end;
*)
     if size > 2 then
     begin
          midpt := size div 2;
          if 2 * midpt = size then  // even no. of values
          begin
               value := (X[midpt-1] + X[midpt]) / 2;
          end
          else value := X[midpt];  // odd no. of values
          Median := value;
     end
     else if size = 2 then Median := (X[0] + X[1]) / 2;
//     cellstring := format('Median = %9.3f',[value]);
//     OutputFrm.ShowModal;
end;

procedure TMedianPolishForm.PrintObsTable(ObsTable : DblDyneMat; nrows, ncols : integer);
VAR
   cellstring, outline : string;
   i, j : integer;
begin
     outline := 'Observed Data';
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := 'ROW            COLUMNS';
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := '  ';
     for i := 1 to ncols do
     begin
          outline := outline + format('%10d',[i]);
     end;
     OutputFrm.RichEdit.Lines.Add(outline);
     for i := 1 to nrows do
     begin
          outline := format('%3d ',[i]);
          for j := 1 to ncols do
          begin
               cellstring := format('%9.3f ',[ObsTable[i-1,j-1]]);
               outline := outline + cellstring;
          end;
          OutputFrm.RichEdit.Lines.Add(outline);
     end;
end;

    procedure TMedianPolishForm.PrintResults(ObsTable : DblDyneMat;
         rowmedian,rowresid : DblDyneVec;
         comedian, colresid : DblDyneVec; nrows, ncols : integer);
var
   i, j : integer;
   cellstring, outline : string;
begin
     OutputFrm.RichEdit.Lines.Add('');
     outline := 'Adjusted Data';
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := 'MEDIAN';
     for i := 1 to ncols do
     begin
          outline := outline + format('%10d',[i]);
     end;
     outline := outline + '     Residuals';
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := '---------------------------------------------------------';
     OutputFrm.RichEdit.Lines.Add(outline);
     for i := 0 to nrows-1 do
     begin
          cellstring := format('%9.3f ',[rowmedian[i]]);
          outline := cellstring;
          for j := 0 to ncols-1 do
          begin
               cellstring := format('%9.3f ',[ObsTable[i,j]]);
               outline := outline + cellstring;
          end;
          cellstring := format('%9.3f ',[rowresid[i]]);
          outline := outline + cellstring;
          OutputFrm.RichEdit.Lines.Add(outline);
     end;
     outline := '---------------------------------------------------------';
     OutputFrm.RichEdit.Lines.Add(outline);
     cellstring := 'Col.Resid.';
     outline := cellstring;
     for j := 0 to ncols-1 do
     begin
          cellstring := format('%9.3f ',[colresid[j]]);
          outline := outline + cellstring;
     end;
     OutputFrm.RichEdit.Lines.Add(outline);
     cellstring := 'Col.Median';
     outline := cellstring;
     for j := 0 to ncols-1 do
     begin
          cellstring := format('%9.3f ',[comedian[j]]);
          outline := outline + cellstring;
     end;
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Cumulative absolute value of Row Residuals');
     for j := 0 to nrows-1 do
     begin
          outline := format('Row = %d  Cum.Residuals = %9.3f',[j+1,CumRowResiduals[j]]);
          OutputFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Cumulative absolute value of Column Residuals');
     for j := 0 to ncols-1 do
     begin
          outline := format('Column = %d  Cum.Residuals = %9.3f',[j+1,CumColResiduals[j]]);
           OutputFrm.RichEdit.Lines.Add(outline);
     end;
end;

procedure TMedianPolishForm.sortvalues(VAR X : DblDyneVec; size : integer);
VAR
   i, j : integer;
   temp : double;
begin
     for i := 0 to size-2 do
     begin
          for j := i+1 to size-1 do
          begin
               if X[i] > X[j] then // swap
               begin
                    temp := X[i];
                    X[i] := X[j];
                    X[j] := temp;
               end;
          end;
     end;
//     OutputFrm.RichEdit.Lines.Add('Sorted values');
//     for i := 0 to size-1 do
//     begin
//          cellstring := format('no. %d = %9.3f',[i+1,X[i]]);
//          OutputFrm.RichEdit.Lines.Add(cellstring);
//     end;
//     OutputFrm.RichEdit.Lines.Add('');
end;
//-----------------------------------------------------------------------
procedure TMedianPolishForm.TwoWayPlot(NF1cells : integer;
           RowSums : DblDyneVec; graphtitle : string; Heading : string);
var
   i: integer;
   minmean, maxmean: double;
   XValue : DblDyneVec;
   title : string;
   plottype : integer;
   setstring : string[11];

begin
     SetLength(XValue,Nf1cells);
     plottype := 2;
     setstring := 'Group';
     GraphFrm.SetLabels[1] := setstring;
     maxmean := -10000.0;
     minmean := 10000.0;
     SetLength(GraphFrm.Xpoints,1,NF1cells);
     SetLength(GraphFrm.Ypoints,1,NF1cells);
     for i := 1 to NF1cells do
     begin
          GraphFrm.Ypoints[0,i-1] := RowSums[i-1];
          if RowSums[i-1] > maxmean then maxmean := RowSums[i-1];
          if RowSums[i-1] < minmean then minmean := RowSums[i-1];
          XValue[i-1] := i;
          GraphFrm.Xpoints[0,i-1] := XValue[i-1];
     end;
     GraphFrm.nosets := 1;
     GraphFrm.nbars := NF1cells;
     GraphFrm.Heading := Heading;
     title :=  graphtitle;
     GraphFrm.XTitle := title;
     GraphFrm.YTitle := 'Y Values';
     GraphFrm.barwideprop := 0.5;
     GraphFrm.AutoScaled := false;
     GraphFrm.miny := minmean;
     GraphFrm.maxy := maxmean;
     GraphFrm.GraphType := plottype;
     GraphFrm.BackColor := clYellow;
     GraphFrm.WallColor := clBlack;
     GraphFrm.FloorColor := clLtGray;
     GraphFrm.ShowBackWall := true;
     GraphFrm.ShowModal;
     GraphFrm.Xpoints := nil;
     GraphFrm.Ypoints := nil;
end;

procedure TMedianPolishForm.InteractPlot(NF1cells, NF2Cells : integer;
           ObsTable :DblDyneMat; graphtitle : string;
           Heading : string);
VAR
   i, j : integer;
   minmean, maxmean, XBar : double;
   XValue: DblDyneVec;
   title : string;
   plottype : integer;
   setstring : string[11];

begin
     SetLength(GraphFrm.Ypoints,NF1cells,NF2cells);
     SetLength(GraphFrm.Xpoints,1,NF2cells);
     SetLength(XValue,Nf1cells+Nf2cells);
     plottype := 2;
     maxmean := -1e308;
     minmean := 1e308;
     for i := 1 to NF1cells do
     begin
          setstring := 'Row ' + IntToStr(i);
          GraphFrm.SetLabels[i] := setstring;
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

     GraphFrm.nosets := NF1cells;
     GraphFrm.nbars := NF2cells;
     GraphFrm.Heading := 'Factor X x Factor Y';
     title :=  'Column Codes';
     GraphFrm.XTitle := title;
     GraphFrm.YTitle := 'Mean';
     GraphFrm.barwideprop := 0.5;
     GraphFrm.AutoScaled := false;
     GraphFrm.miny := minmean;
     GraphFrm.maxy := maxmean;
     GraphFrm.GraphType := plottype;
     GraphFrm.BackColor := clYellow;
     GraphFrm.WallColor := clBlack;
     GraphFrm.FloorColor := clLtGray;
     GraphFrm.ShowBackWall := true;
     GraphFrm.ShowModal;
     XValue := nil;
     GraphFrm.Xpoints := nil;
     GraphFrm.Ypoints := nil;
end;

initialization
  {$I medianpolishunit.lrs}

end.

