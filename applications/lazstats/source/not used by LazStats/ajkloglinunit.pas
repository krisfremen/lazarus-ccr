unit AJKLogLinUnit;

interface

uses
  //Windows, Messages,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, Math, OutPutUnit, Buttons, ExtCtrls, MainUnit, FunctionsUnit,
  GlobalDefs, DataProcs;

type cube = array[1..10,1..10,1..10] of double;
type matrix = array[1..10,1..10] of double;
type vector = array[1..10] of double;
type quad = array[1..10,1..10,1..10,1..7] of double;

type
  TAJKLogLinearFrm = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    NrowsEdit: TEdit;
    Label2: TLabel;
    NcolsEdit: TEdit;
    Label3: TLabel;
    NslicesEdit: TEdit;
    Grid: TStringGrid;
    ComputeBtn: TButton;
    ExitBtn: TButton;
    FileFromGrp: TRadioGroup;
    VarList: TListBox;
    RowInBtn: TBitBtn;
    RowOutBtn: TBitBtn;
    Label4: TLabel;
    RowVarEdit: TEdit;
    ColInBtn: TBitBtn;
    ColOutBtn: TBitBtn;
    Label5: TLabel;
    ColVarEdit: TEdit;
    FreqInBtn: TBitBtn;
    FreqOutBtn: TBitBtn;
    Label6: TLabel;
    FreqVarEdit: TEdit;
    CancelBtn: TButton;
    ResetBtn: TButton;
    SliceBtnIn: TBitBtn;
    SliceBtnOut: TBitBtn;
    Label7: TLabel;
    SliceVarEdit: TEdit;
    procedure FormShow(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure NrowsEditKeyPress(Sender: TObject; var Key: Char);
    procedure NcolsEditKeyPress(Sender: TObject; var Key: Char);
    procedure NslicesEditKeyPress(Sender: TObject; var Key: Char);
    procedure ComputeBtnClick(Sender: TObject);
    procedure ModelEffect(Nrows,Ncols,Nslices : integer;
                          VAR Data : cube;
                          VAR RowMarg : vector;
                          VAR ColMarg : vector;
                          VAR SliceMarg : vector;
                          VAR AB : matrix;
                          VAR AC : matrix;
                          VAR BC : matrix;
                          VAR Total : double;
                          Model : integer);
    procedure Iterate(Nrows, Ncols, Nslices : integer;
                      VAR Data : cube;
                      VAR RowMarg : vector;
                      VAR ColMarg : vector;
                      VAR SliceMarg : vector;
                      VAR Total : double;
                      VAR Expected : cube;
                      VAR NewRowMarg : vector;
                      VAR NewColMarg : vector;
                      VAR NewSliceMarg : vector;
                      VAR NewTotal : double);
    procedure PrintTable(Nrows, Ncols, Nslices : integer;
                         VAR Data : cube;
                         VAR RowMarg : vector;
                         VAR ColMarg : vector;
                         VAR SliceMarg : vector;
                         Total : double);
    procedure PrintLamdas(Nrows,Ncols,Nslices : integer;
                          Var CellLambdas : Quad;
                          mu : double);
    procedure PrintMatrix(VAR X : matrix;
                          Nrows, Ncols: integer;
                          Title : string);
    procedure CancelBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure FileFromGrpClick(Sender: TObject);
    procedure RowInBtnClick(Sender: TObject);
    procedure RowOutBtnClick(Sender: TObject);
    procedure ColInBtnClick(Sender: TObject);
    procedure ColOutBtnClick(Sender: TObject);
    procedure SliceBtnInClick(Sender: TObject);
    procedure SliceBtnOutClick(Sender: TObject);
    procedure FreqInBtnClick(Sender: TObject);
    procedure FreqOutBtnClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AJKLogLinearFrm: TAJKLogLinearFrm;

implementation

{$R *.DFM}

procedure TAJKLogLinearFrm.FormShow(Sender: TObject);
begin
     ResetBtnClick(Self);
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.ExitBtnClick(Sender: TObject);
begin
     Close;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.NrowsEditKeyPress(Sender: TObject;
  var Key: Char);
begin
     if ord(Key) = 13 then NcolsEdit.SetFocus;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.NcolsEditKeyPress(Sender: TObject;
  var Key: Char);
begin
     if ord(Key) = 13 then NslicesEdit.SetFocus;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.NslicesEditKeyPress(Sender: TObject;
  var Key: Char);
var
   i, j, k, row : integer;
   Nslices, Ncols, Nrows : integer;
begin
     if ord(Key) = 13 then
     begin
          Nrows := StrToInt(NrowsEdit.Text);
          Ncols := StrToInt(NcolsEdit.Text);
          Nslices := StrToInt(NslicesEdit.Text);
          Grid.RowCount := Nrows * Ncols * Nslices + 1;
          row := 1;
          for k := 1 to Nslices do
          begin
               for j := 1 to Ncols do
               begin
                    for i := 1 to Nrows do
                    begin
                         Grid.Cells[0,row] := IntToStr(i);
                         Grid.Cells[1,row] := IntToStr(j);
                         Grid.Cells[2,row] := IntToStr(k);
                         row := row + 1;
                    end;
               end;
          end;
          Grid.SetFocus;
     end;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k, row, col, slice, Nrows, Ncols, Nslices : integer;
   Data : cube;
   AB, AC, BC : matrix;
   RowMarg, ColMarg, SliceMarg : vector;
   Total : double;
   arraysize : integer;
   Model : integer;
   astr, Title : string;
   RowCol, ColCol, SliceCol, Fcol : integer;
   GridPos : IntDyneVec;
   value : integer;
   Fx : double;

begin
     Nrows := 0;
     Ncols := 0;
     Nslices := 0;
     Total := 0.0;

     if FileFromGrp.ItemIndex = 0 then // mainfrm input
     begin
          SetLength(GridPos,4);
          for i := 1 to NoVariables do
          begin
               if RowVarEdit.Text = MainFrm.Grid.Cells[i,0] then GridPos[0] := i;
               if ColVarEdit.Text = MainFrm.Grid.Cells[i,0] then GridPos[1] := i;
               if SliceVarEdit.Text = MainFrm.Grid.Cells[i,0] then GridPos[2] := i;
               if FreqVarEdit.Text = MainFrm.Grid.Cells[i,0] then GridPos[3] := i;
          end;
          // get no. of rows, columns and slices
          for i := 1 to MainFrm.Grid.RowCount - 1 do
          begin
               value := StrToInt(MainFrm.Grid.Cells[GridPos[0],i]);
               if value > Nrows then Nrows := value;
               value := StrToInt(MainFrm.Grid.Cells[GridPos[1],i]);
               if value > Ncols then Ncols := value;
               value := StrToInt(MainFrm.Grid.Cells[GridPos[2],i]);
               if value > Nslices then Nslices := value;
          end;
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  AB[i,j] := 0.0;
          for i := 1 to Nrows do
              for k := 1 to Nslices do
                  AC[i,k] := 0.0;
          for j := 1 to Ncols do
              for k := 1 to Nslices do
                  BC[j,k] := 0.0;
          arraysize := Nrows * Ncols * Nslices;
          // Get data
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Data[i,j,k] := 0.0;
          rowcol := GridPos[0];
          colcol := GridPos[1];
          slicecol := GridPos[2];
          Fcol := GridPos[3];
          for i := 1 to MainFrm.Grid.RowCount - 1 do
          begin
               if Not GoodRecord(i, 4, GridPos) then continue;
               row := StrToInt(MainFrm.Grid.Cells[rowcol,i]);
               col := StrToInt(MainFrm.Grid.Cells[colcol,i]);
               slice := StrToInt(MainFrm.Grid.Cells[slicecol,i]);
               Fx := StrToInt(MainFrm.Grid.Cells[Fcol,i]);
               Data[row,col,slice] := Data[row,col,slice] + Fx;
               Total := Total + Fx;
               RowMarg[row] := RowMarg[row] + Fx;
               ColMarg[col] := ColMarg[col] + Fx;
               SliceMarg[slice] := SliceMarg[slice] + Fx;
               AB[row,col] := AB[row,col] + Fx;
               AC[row,slice] := AC[row,slice] + Fx;
               BC[col,slice] := BC[col,slice] + Fx;
          end;
          GridPos := nil;
     end;

     if FileFromGrp.ItemIndex = 1 then // form input
     begin
          Nrows := StrToInt(NrowsEdit.Text);
          Ncols := StrToInt(NcolsEdit.Text);
          Nslices := StrToInt(NslicesEdit.Text);
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  AB[i,j] := 0.0;
          for i := 1 to Nrows do
              for k := 1 to Nslices do
                  AC[i,k] := 0.0;
          for j := 1 to Ncols do
              for k := 1 to Nslices do
                  BC[j,k] := 0.0;
          arraysize := Nrows * Ncols * Nslices;

          // get data
          for i := 1 to arraysize do
          begin
               row := StrToInt(Grid.Cells[0,i]);
               col := StrToInt(Grid.Cells[1,i]);
               slice := StrToInt(Grid.Cells[2,i]);
               Data[row,col,slice] := StrToInt(Grid.Cells[3,i]);
               AB[row,col] := AB[row,col] + Data[row,col,slice];
               AC[row,slice] := AC[row,slice] + Data[row,col,slice];
               BC[col,slice] := BC[col,slice] + Data[row,col,slice];
               Total := Total + Data[row,col,slice];
               RowMarg[row] := RowMarg[row] + Data[row,col,slice];
               ColMarg[col] := ColMarg[col] + Data[row,col,slice];
               SliceMarg[slice] := SliceMarg[slice] + Data[row,col,slice];
          end;
     end;

     // print heading of output
     OutPutFrm.RichEdit.Clear;
     OutPutFrm.RichEdit.Lines.Add('Log-Linear Analysis of a Three Dimension Table');
     OutPutFrm.RichEdit.Lines.Add('');

     // print observed matrix
     astr := 'Observed Frequencies';
     OutPutFrm.RichEdit.Lines.Add(astr);
     PrintTable(Nrows,Ncols,Nslices,Data,RowMarg,ColMarg,SliceMarg,Total);
     OutPutFrm.RichEdit.Lines.Add('');

     // Print sub-matrices
     Title := 'Sub-matrix AB';
     PrintMatrix(AB,Nrows,Ncols,Title);
     Title := 'Sub-matrix AC';
     PrintMatrix(AC,Nrows,Nslices,Title);
     Title := 'Sub-matrix BC';
     PrintMatrix(BC,Ncols,Nslices,Title);
     OutPutFrm.ShowModal;
     OutPutFrm.RichEdit.Clear;


     for Model := 1 to 9 do
         ModelEffect(Nrows,Ncols,Nslices,Data,RowMarg,ColMarg,
                   SliceMarg,AB,AC,BC,Total,Model);


end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.ModelEffect(Nrows,Ncols,Nslices : integer;
                        VAR Data : cube;
                        VAR RowMarg : vector;
                        VAR ColMarg : vector;
                        VAR SliceMarg : vector;
                        VAR AB : matrix;
                        VAR AC : matrix;
                        VAR BC : matrix;
                        VAR Total : double;
                        Model : integer);
var
   i, j, k, l : integer;
   CellLambdas : Quad;
   LogData, Expected : cube;
   Title, astr : string;
   NewRowMarg,NewColMarg,NewSliceMarg : vector;
   LogRowMarg, LogColMarg, LogSliceMarg : vector;
   NewTotal : double;
   ABLogs, ACLogs, BCLogs : matrix;
   LogTotal, mu, ModelTotal, Ysqr : double;
   DF : integer;

begin
     // Get expected values for chosen model
     if Model = 1 then // Saturated model
     begin
          Title := 'Saturated Model';
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Expected[i,j,k] := Data[i,j,k];
     end;

     if Model = 2 then // independence
     begin
          Title := 'Model of Independence';
          Iterate(Nrows,Ncols,Nslices,Data,RowMarg,ColMarg,SliceMarg,Total,
             Expected,NewRowMarg,NewColMarg,NewSliceMarg,NewTotal);
     end;

     if Model = 3 then // no AB effect
     begin
          Title := 'No AB Effect';
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Expected[i,j,k] := AC[i,k] * BC[j,k] / SliceMarg[k];
     end;
     if Model = 4 then // no AC effect
     begin
          Title := 'No AC Effect';
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Expected[i,j,k] := AB[i,j] * BC[j,k] / ColMarg[j];
     end;
     if Model = 5 then // no BC effect
     begin
          Title := 'No BC Effect';
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Expected[i,j,k] := AB[i,j] * AC[i,k] / RowMarg[i];
     end;
     if Model = 6 then // no C effect
     begin
          Title := 'Model of No Slice (C) effect';
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Expected[i,j,k] := (RowMarg[i] / Total) *
                                    (ColMarg[j] / Total) * (Total / Nslices);
     end;

     if Model = 7 then // no B effect
     begin
          Title := 'Model of no Column (B) effect';
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Expected[i,j,k] := (RowMarg[i] / Total) *
                                    (SliceMarg[k] / Total) * (Total / Ncols);
     end;

     if Model = 8 then // no A effect
     begin
          Title := 'Model of no Row (A) effect';
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Expected[i,j,k] := (ColMarg[j] / Total) *
                                    (SliceMarg[k] / Total) * (Total / Nrows);
     end;

     if Model = 9 then // Equiprobability Model
     begin
          Title := 'Equi-probability Model';
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Expected[i,j,k] := Total /
                                         (Nrows * NCols * Nslices);
     end;
     LogTotal := 0.0;
     for i := 1 to Nrows do
     begin
          NewRowMarg[i] := 0.0;
          LogRowMarg[i] := 0.0;
     end;
     for j := 1 to Ncols do
     begin
          NewColMarg[j] := 0.0;
          LogColMarg[j] := 0.0;
     end;
     for k := 1 to Nslices do
     begin
          NewSliceMarg[k] := 0.0;
          LogSliceMarg[k] := 0.0;
     end;

     for i := 1 to Nrows do
         for j := 1 to Ncols do
             ABLogs[i,j] := 0.0;

     for i := 1 to Nrows do
         for k := 1 to Nslices do
             ACLogs[i,k] := 0.0;

     for j := 1 to Ncols do
         for k := 1 to Nslices do
             BCLogs[j,k] := 0.0;

     for i := 1 to Nrows do
     begin
          for j := 1 to Ncols do
          begin
               for k := 1 to Nslices do
               begin
                    NewRowMarg[i] := NewRowMarg[i] + Expected[i,j,k];
                    NewColMarg[j] := NewColMarg[j] + Expected[i,j,k];
                    NewSliceMarg[k] := NewSliceMarg[k] + Expected[i,j,k];
               end;
          end;
     end;

     for i := 1 to Nrows do
          for j := 1 to Ncols do
              for k := 1 to Nslices do
                  LogData[i,j,k] := ln(Expected[i,j,k]);

     for i := 1 to Nrows do
     begin
          for j := 1 to Ncols do
          begin
               for k := 1 to Nslices do
               begin
                    LogRowMarg[i] := LogRowMarg[i] + LogData[i,j,k];
                    LogColMarg[j] := LogColMarg[j] + LogData[i,j,k];
                    LogSliceMarg[k] := LogSliceMarg[k] + LogData[i,j,k];
                    ABLogs[i,j] := ABLogs[i,j] + LogData[i,j,k];
                    ACLogs[i,k] := ACLogs[i,k] + LogData[i,j,k];
                    BCLogs[j,k] := BCLogs[j,k] + LogData[i,j,k];
                    LogTotal := LogTotal + LogData[i,j,k];
               end;
          end;
     end;

     for i := 1 to Nrows do LogRowMarg[i] := LogRowMarg[i] / (Ncols * Nslices);
     for j := 1 to Ncols do LogColMarg[j] := LogColMarg[j] / (Nrows * Nslices);
     for k := 1 to Nslices do LogSliceMarg[k] := LogSliceMarg[k] / (Ncols * Nrows);
     LogTotal := LogTotal / (Ncols * Nrows * Nslices);
     for i := 1 to Nrows do
         for j := 1 to Ncols do
             ABLogs[i,j] := ABLogs[i,j] / Nslices;
     for i := 1 to Nrows do
         for k := 1 to Nslices do
             ACLogs[i,k] := ACLogs[i,k] / Ncols;
     for j := 1 to Ncols do
         for k := 1 to Nslices do
             BCLogs[j,k] := BCLogs[j,k] / Nrows;

     for i := 1 to Nrows do
     begin
          for j := 1 to Ncols do
          begin
               for k := 1 to Nslices do
               begin
                    CellLambdas[i,j,k,1] := LogRowMarg[i] - LogTotal;
                    CellLambdas[i,j,k,2] := LogColMarg[j] - LogTotal;
                    CellLambdas[i,j,k,3] := LogSliceMarg[k] - LogTotal;
                    CellLambdas[i,j,k,4] := ABLogs[i,j] - LogRowMarg[i]
                                            - LogColMarg[j] + LogTotal;
                    CellLambdas[i,j,k,5] := ACLogs[i,k] - LogRowMarg[i]
                                            - LogSliceMarg[k] + LogTotal;
                    CellLambdas[i,j,k,6] := BCLogs[j,k] - LogColMarg[j]
                                            - LogSliceMarg[k] + LogTotal;
                    CellLambdas[i,j,k,7] := LogData[i,j,k] + LogRowMarg[i]
                                            + LogColMarg[j] + LogSliceMarg[k]
                                            - ABLogs[i,j] - ACLogs[i,k]
                                            - BCLogs[j,k] - LogTotal;
               end;
          end;
     end;
     mu := LogTotal;

     // Get Y square for model
     Ysqr := 0.0;
     for i := 1 to Nrows do
         for j := 1 to Ncols do
             for k := 1 to Nslices do
                 Ysqr := Ysqr + (Data[i,j,k] * ln(Data[i,j,k] / Expected[i,j,k]));
     Ysqr := 2.0 * Ysqr;

     OutPutFrm.RichEdit.Lines.Add(Title);
     OutPutFrm.RichEdit.Lines.Add('');

     astr := 'Expected Frequencies';
     OutPutFrm.RichEdit.Lines.Add(astr);
     PrintTable(Nrows,Ncols,Nslices,Expected,NewRowMarg,NewColMarg,
                NewSliceMarg,NewTotal);
     OutPutFrm.RichEdit.Lines.Add('');

     astr := 'Log Frequencies';
     OutPutFrm.RichEdit.Lines.Add(astr);
     PrintTable(Nrows,Ncols,Nslices,LogData,LogRowMarg,LogColMarg,LogSliceMarg,LogTotal);
     OutPutFrm.RichEdit.Lines.Add('');

     OutPutFrm.ShowModal;
     OutPutFrm.RichEdit.Clear;

     astr := 'Cell Parameters';
     OutPutFrm.RichEdit.Lines.Add(astr);
     PrintLamdas(Nrows,Ncols,Nslices,CellLambdas, mu);
     OutPutFrm.RichEdit.Lines.Add('');

     astr := 'G squared statistic for model fit = ' + format('%6.3f',[Ysqr]);
     case Model of
     1 : DF := 0; // saturated
     2 : DF := Nrows * Ncols * Nslices - Nrows - Ncols - Nslices + 2; // independence
     3 : DF := Nslices * (Nrows - 1) * (Ncols - 1); //no AB effect
     4 : DF := Ncols * (Nrows - 1) * (Nslices - 1); // no AC effect
     5 : DF := Nrows * (Ncols - 1) * (Nslices - 1); // no BC effect
     6 : DF := Nrows * Ncols * Nslices - Nrows - Ncols + 1; // no C effect
     7 : DF := Nrows * Ncols * Nslices - Nrows - Nslices + 1; // no B effect
     8 : DF := Nrows * Ncols * Nslices - Ncols - Nslices + 1; // no A effect
     9 : DF := Nrows * Ncols * Nslices - 1; // Equiprobability
     end;
     astr := astr + ' D.F. = ' + IntToStr(DF);
     OutPutFrm.RichEdit.Lines.Add(astr);
     OutPutFrm.ShowModal;
     OutPutFrm.RichEdit.Clear;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.Iterate(Nrows, Ncols, Nslices : integer;
                                 VAR Data : cube;
                                 VAR RowMarg : vector;
                                 VAR ColMarg : vector;
                                 VAR SliceMarg : vector;
                                 VAR Total : double;
                                 VAR Expected : cube;
                                 VAR NewRowMarg : vector;
                                 VAR NewColMarg : vector;
                                 VAR NewSliceMarg : vector;
                                 VAR NewTotal : double);

Label Step;
var
   previous : cube;
   i, j, k : integer;
   delta : double;
   difference : double;

begin
     delta := 0.1;
     difference := 0.0;
     for i := 1 to Nrows do newrowmarg[i] := 0.0;
     for j := 1 to Ncols do newcolmarg[j] := 0.0;
     for k := 1 to Nslices do newslicemarg[k] := 0.0;

     // initialize expected values
     for i := 1 to Nrows do
     begin
         for j := 1 to Ncols do
         begin
              for k := 1 to Nslices do
              begin
                   expected[i,j,k] := 1.0;
                   previous[i,j,k] := 1.0;
              end;
         end;
     end;

Step:
     // step 1: initialize new row margins and calculate expected value
     for i := 1 to Nrows do
          for j := 1 to Ncols do
              for k := 1 to Nslices do
                  newrowmarg[i] := newrowmarg[i] + expected[i,j,k];
     for i := 1 to Nrows do
         for j := 1 to Ncols do
             for k := 1 to Nslices do
                 expected[i,j,k] := (RowMarg[i] / newrowmarg[i]) * expected[i,j,k];

     // step 2: initialize new col margins and calculate expected values
     for i := 1 to Nrows do
          for j := 1 to Ncols do
              for k := 1 to Nslices do
                  newcolmarg[j] := newcolmarg[j] + expected[i,j,k];
     for i := 1 to Nrows do
         for j := 1 to Ncols do
             for k := 1 to Nslices do
                 expected[i,j,k] := (ColMarg[j] / newcolmarg[j]) * expected[i,j,k];

     // step 3: initialize new slice margins and calculate expected values
     for i := 1 to Nrows do
         for j := 1 to Ncols do
             for k := 1 to Nslices do
                 newslicemarg[k] := newslicemarg[k] + expected[i,j,k];
     for i := 1 to Nrows do
         for j := 1 to Ncols do
             for k := 1 to Nslices do
                 expected[i,j,k] := (SliceMarg[k] / newslicemarg[k]) * expected[i,j,k];

     // step 4: check for change and quit if smaller than delta
     for i := 1 to Nrows do
         for j := 1 to Ncols do
             for k := 1 to Nslices do
                 if abs(Previous[i,j,k]-expected[i,j,k]) > difference then
                    difference := abs(Previous[i,j,k]-expected[i,j,k]);

     if difference < delta then
     begin
          newtotal := 0.0;
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      newtotal := newtotal + expected[i,j,k];
          exit;
     end
     else begin
          for i := 1 to Nrows do
              for j := 1 to Ncols do
                  for k := 1 to Nslices do
                      Previous[i,j,k] := expected[i,j,k];
          for i := 1 to Nrows do newrowmarg[i] := 0.0;
          for j := 1 to Ncols do newcolmarg[j] := 0.0;
          for k := 1 to Nslices do newslicemarg[k] := 0.0;
          difference := 0.0;
          goto step;
     end;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.PrintTable(Nrows, Ncols, Nslices : integer;
                                    VAR Data : cube;
                                    VAR RowMarg : vector;
                                    VAR ColMarg : vector;
                                    VAR SliceMarg : vector;
                                    Total : double);
var
   astr : string;
   i, j,k : integer;
begin
     astr := ' A   B   C    VALUE ';
     for i := 1 to Nrows do
     begin
          for j := 1 to Ncols do
          begin
               for k := 1 to Nslices do
               begin
                    astr := format('%3d %3d %3d   %8.3f',[i,j,k,Data[i,j,k]]);
                    OutPutFrm.RichEdit.Lines.Add(astr);
               end;
          end;
     end;
     astr := 'Totals for Dimension A';
     OutPutFrm.RichEdit.Lines.Add(astr);
     for i := 1 to Nrows do
     begin
          astr := format('Row %d %8.3f',[i,RowMarg[i]]);
          OutPutFrm.RichEdit.Lines.Add(astr);
     end;
     astr := 'Totals for Dimension B';
     OutPutFrm.RichEdit.Lines.Add(astr);
     for j := 1 to Ncols do
     begin
          astr := format('Col %d %8.3f',[j,ColMarg[j]]);
          OutPutFrm.RichEdit.Lines.Add(astr);
     end;
     astr := 'Totals for Dimension C';
     OutPutFrm.RichEdit.Lines.Add(astr);
     for k := 1 to Nslices do
     begin
          astr := format('Slice %d %8.3f',[k,SliceMarg[k]]);
          OutPutFrm.RichEdit.Lines.Add(astr);
     end;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.PrintLamdas(Nrows,Ncols,Nslices : integer;
                                     Var CellLambdas : Quad;
                                     mu : double);
var
   i, j, k, l : integer;
   astr : string;
begin
     astr := 'ROW COL SLICE     MU        LAMBDA A     LAMBDA B     LAMBDA C';
     OutPutFrm.RichEdit.Lines.Add(astr);
     astr := '               LAMBDA AB    LAMBDA AC    LAMBDA BC    LAMBDA ABC';
     OutPutFrm.RichEdit.Lines.Add(astr);
     OutPutFrm.RichEdit.Lines.Add('');
     for i := 1 to Nrows do
     begin
          for j := 1 to Ncols do
          begin
               for k := 1 to Nslices do
               begin
                    astr := format('%3d %3d %3d ',[i,j,k]);
                    astr := astr + format(' %8.3f    ',[mu]);
                    for l := 1 to 3 do
                        astr := astr + format(' %8.3f    ',[CellLambdas[i,j,k,l]]);
                    OutPutFrm.RichEdit.Lines.Add(astr);
                    astr := '            ';
                    for l := 4 to 7 do
                        astr := astr + format(' %8.3f    ',[CellLambdas[i,j,k,l]]);
                    OutPutFrm.RichEdit.Lines.Add(astr);
                    OutPutFrm.RichEdit.Lines.Add('');
               end;
          end;
     end;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.PrintMatrix(VAR X : matrix;
                                       Nrows, Ncols: integer;
                                       Title : string);
Label loop;
var
i, j : integer;
first, last : integer;
astr : string;

begin
     OutPutFrm.RichEdit.Lines.Add(Title);
     OutPutFrm.RichEdit.Lines.Add('');
     first := 1;
     last := Ncols;
     if last > 6 then last := 6;
loop:
     astr := 'ROW/COL';
     for j := first to last do astr := astr + format('   %3d    ',[j]);
     OutPutFrm.RichEdit.Lines.Add(astr);
     for i := 1 to Nrows do
     begin
          astr := format('  %3d  ',[i]);
          for j := first to last do astr := astr + format(' %8.3f ',[X[i,j]]);
          OutPutFrm.RichEdit.Lines.Add(astr);
     end;
     if last < Ncols then
     begin
          first := last + 1;
          last := Ncols;
          if last > 6 then last := 6;
          goto loop;
     end;
     OutPutFrm.RichEdit.Lines.Add('');
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.CancelBtnClick(Sender: TObject);
begin
     AJKLogLinearFrm.Hide;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.ResetBtnClick(Sender: TObject);
var
   i, j : integer;
begin
//     for i := 0 to Grid.RowCount - 1 do
//         for j := 0 to Grid.ColCount - 1 do
//             Grid.Cells[j,i] := '';
     Grid.ColCount := 4;
     Grid.RowCount := 2;
     Grid.Cells[0,0] := 'ROW';
     Grid.Cells[1,0] := 'COL';
     Grid.Cells[2,0] := 'SLICE';
     Grid.Cells[3,0] := 'FREQ.';
     VarList.Clear;
     for i := 1 to NoVariables do
         VarList.Items.Add(MainFrm.Grid.Cells[i,0]);
     RowVarEdit.Text := '';
     ColVarEdit.Text := '';
     FreqVarEdit.Text := '';
     NRowsEdit.Text := '';
     NColsEdit.Text := '';
     NSlicesEdit.Text := '';
     VarList.Visible := false;
     RowInBtn.Visible := false;
     RowOutBtn.Visible := false;
     ColInBtn.Visible := false;
     ColOutBtn.Visible := false;
     FreqInBtn.Visible := false;
     FreqOutBtn.Visible := false;
     Label4.Visible := false;
     Label5.Visible := false;
     Label6.Visible := false;
     Label7.Visible := false;
     RowVarEdit.Visible := false;
     ColVarEdit.Visible := false;
     SliceVarEdit.Visible := false;
     FreqVarEdit.Visible := false;
     Memo1.Visible := false;
     Label1.Visible := false;
     Label2.Visible := false;
     Label3.Visible := false;
     NRowsEdit.Visible := false;
     NColsEdit.Visible := false;
     NSlicesEdit.Visible := false;
     Grid.Visible := false;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.FileFromGrpClick(Sender: TObject);
begin
     if FileFromGrp.ItemIndex = 0 then // file from main form
     begin
          VarList.Visible := true;
          RowInBtn.Visible := true;
          RowOutBtn.Visible := false;
          ColInBtn.Visible := true;
          ColOutBtn.Visible := false;
          SliceBtnIn.Visible := true;
          SliceBtnOut.Visible := false;
          FreqInBtn.Visible := true;
          FreqOutBtn.Visible := false;
          Label4.Visible := true;
          Label5.Visible := true;
          Label6.Visible := true;
          Label7.Visible := true;
          RowVarEdit.Visible := true;
          ColVarEdit.Visible := true;
          SliceVarEdit.Visible := true;
          FreqVarEdit.Visible := true;
          Memo1.Visible := false;
          Label1.Visible := false;
          Label2.Visible := false;
          Label3.Visible := false;
          NRowsEdit.Visible := false;
          NColsEdit.Visible := false;
          NSlicesEdit.Visible := false;
          Grid.Visible := false;
     end;
     if FileFromGrp.ItemIndex = 1 then // data from this form
     begin
          VarList.Visible := false;
          RowInBtn.Visible := false;
          RowOutBtn.Visible := false;
          ColInBtn.Visible := false;
          ColOutBtn.Visible := false;
          SliceBtnIn.Visible := false;
          SliceBtnOut.Visible := false;
          FreqInBtn.Visible := false;
          FreqOutBtn.Visible := false;
          Label4.Visible := false;
          Label5.Visible := false;
          Label6.Visible := false;
          Label7.Visible := false;
          RowVarEdit.Visible := false;
          ColVarEdit.Visible := false;
          SliceVarEdit.Visible := false;
          FreqVarEdit.Visible := false;
          Memo1.Visible := true;
          Label1.Visible := true;
          Label2.Visible := true;
          Label3.Visible := true;
          NRowsEdit.Visible := true;
          NColsEdit.Visible := true;
          NSlicesEdit.Visible := true;
          Grid.Visible := true;
     end;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.RowInBtnClick(Sender: TObject);
var
   index : integer;

begin
     index := VarList.ItemIndex;
     RowVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     RowOutBtn.Visible := true;
     RowInBtn.Visible := false;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.RowOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(RowVarEdit.Text);
     RowInBtn.Visible := true;
     RowOutBtn.Visible := false;
     RowVarEdit.Text := '';
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.ColInBtnClick(Sender: TObject);
var
   index : integer;
begin
     index := VarList.ItemIndex;
     ColVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     ColOutBtn.Visible := true;
     ColInBtn.Visible := false;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.ColOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(ColVarEdit.Text);
     ColInBtn.Visible := true;
     ColOutBtn.Visible := false;
     ColVarEdit.Text := '';
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.SliceBtnInClick(Sender: TObject);
var
   index : integer;
begin
     index := VarList.ItemIndex;
     SliceVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     SliceBtnOut.Visible := true;
     SliceBtnIn.Visible := false;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.SliceBtnOutClick(Sender: TObject);
begin
     VarList.Items.Add(SliceVarEdit.Text);
     SliceBtnIn.Visible := true;
     SliceBtnOut.Visible := false;
     FreqVarEdit.Text := '';
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.FreqInBtnClick(Sender: TObject);
var
   index : integer;
begin
     index := VarList.ItemIndex;
     FreqVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     FreqOutBtn.Visible := true;
     FreqInBtn.Visible := false;
end;
//-------------------------------------------------------------------

procedure TAJKLogLinearFrm.FreqOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(FreqVarEdit.Text);
     FreqInBtn.Visible := true;
     FreqOutBtn.Visible := false;
     FreqVarEdit.Text := '';
end;
//-------------------------------------------------------------------

end.
