unit ABCLogLinUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Grids, Math, OutPutUnit, MainUnit,
  FunctionsLib, Globals, DataProcs, contexthelpunit;

type

  { TABCLogLinearFrm }

  TABCLogLinearFrm = class(TForm)
    HelpBtn: TButton;
    RowInBtn: TBitBtn;
    RowOutBtn: TBitBtn;
    ColInBtn: TBitBtn;
    ColOutBtn: TBitBtn;
    SliceBtnIn: TBitBtn;
    SliceBtnOut: TBitBtn;
    FreqInBtn: TBitBtn;
    FreqOutBtn: TBitBtn;
    NslicesEdit: TEdit;
    Label7: TLabel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    NRowsEdit: TEdit;
    NColsEdit: TEdit;
    RowVarEdit: TEdit;
    ColVarEdit: TEdit;
    SliceVarEdit: TEdit;
    FreqVarEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Grid: TStringGrid;
    VarList: TListBox;
    FileFromGrp: TRadioGroup;
    procedure ColInBtnClick(Sender: TObject);
    procedure ColOutBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FileFromGrpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FreqInBtnClick(Sender: TObject);
    procedure FreqOutBtnClick(Sender: TObject);
    procedure NColsEditKeyPress(Sender: TObject; var Key: char);
    procedure NRowsEditKeyPress(Sender: TObject; var Key: char);
    procedure NslicesEditKeyPress(Sender: TObject; var Key: char);
    procedure ResetBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure RowInBtnClick(Sender: TObject);
    procedure RowOutBtnClick(Sender: TObject);
    procedure SliceBtnInClick(Sender: TObject);
    procedure SliceBtnOutClick(Sender: TObject);
  private
    { private declarations }
    procedure ModelEffect(Nrows,Ncols,Nslices : integer;
                          VAR Data : DblDyneCube;
                          VAR RowMarg : DblDyneVec;
                          VAR ColMarg : DblDyneVec;
                          VAR SliceMarg : DblDyneVec;
                          VAR AB : DblDyneMat;
                          VAR AC : DblDyneMat;
                          VAR BC : DblDyneMat;
                          VAR Total : double;
                          Model : integer);
    procedure Iterate(Nrows, Ncols, Nslices : integer;
                      VAR Data : DblDyneCube;
                      VAR RowMarg : DblDyneVec;
                      VAR ColMarg : DblDyneVec;
                      VAR SliceMarg : DblDyneVec;
                      VAR Total : double;
                      VAR Expected : DblDyneCube;
                      VAR NewRowMarg : DblDyneVec;
                      VAR NewColMarg : DblDyneVec;
                      VAR NewSliceMarg : DblDyneVec;
                      VAR NewTotal : double);
    procedure PrintTable(Nrows, Ncols, Nslices : integer;
                         VAR Data : DblDyneCube;
                         VAR RowMarg : DblDyneVec;
                         VAR ColMarg : DblDyneVec;
                         VAR SliceMarg : DblDyneVec;
                         Total : double);
    procedure PrintLamdas(Nrows,Ncols,Nslices : integer;
                          Var CellLambdas : DblDyneQuad;
                          mu : double);
    procedure PrintMatrix(VAR X : DblDyneMat;
                          Nrows, Ncols: integer;
                          Title : string);

  public
    { public declarations }
  end; 

var
  ABCLogLinearFrm: TABCLogLinearFrm;

implementation

{ TABCLogLinearFrm }

procedure TABCLogLinearFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     Grid.ColCount := 4;
     Grid.RowCount := 2;
     Grid.Cells[0,0] := 'ROW';
     Grid.Cells[1,0] := 'COL';
     Grid.Cells[2,0] := 'SLICE';
     Grid.Cells[3,0] := 'FREQ.';
     VarList.Clear;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     RowVarEdit.Text := '';
     ColVarEdit.Text := '';
     SliceVarEdit.Text := '';
     FreqVarEdit.Text := '';
     NRowsEdit.Text := '';
     NColsEdit.Text := '';
     NSlicesEdit.Text := '';
     VarList.Visible := false;
     RowInBtn.Visible := false;
     RowOutBtn.Visible := false;
     ColInBtn.Visible := false;
     ColOutBtn.Visible := false;
     SliceBtnIn.Visible := false;
     SliceBtnOut.Visible := false;
     FreqInBtn.Visible := false;
     FreqOutBtn.Visible := false;
     Label1.Visible := false;
     Label2.Visible := false;
     Label3.Visible := false;
     Label4.Visible := false;
     Label5.Visible := false;
     Label6.Visible := false;
     Label7.Visible := false;
     RowVarEdit.Visible := false;
     ColVarEdit.Visible := false;
     SliceVarEdit.Visible := false;
     FreqVarEdit.Visible := false;
     NRowsEdit.Visible := false;
     NColsEdit.Visible := false;
     NSlicesEdit.Visible := false;
     Grid.Visible := false;
end;

procedure TABCLogLinearFrm.HelpBtnClick(Sender: TObject);
begin
    ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TABCLogLinearFrm.RowInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     RowVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     RowOutBtn.Visible := true;
     RowInBtn.Visible := false;
end;

procedure TABCLogLinearFrm.RowOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(RowVarEdit.Text);
     RowInBtn.Visible := true;
     RowOutBtn.Visible := false;
     RowVarEdit.Text := '';
end;

procedure TABCLogLinearFrm.SliceBtnInClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     SliceVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     SliceBtnOut.Visible := true;
     SliceBtnIn.Visible := false;
end;

procedure TABCLogLinearFrm.SliceBtnOutClick(Sender: TObject);
begin
     VarList.Items.Add(SliceVarEdit.Text);
     SliceBtnIn.Visible := true;
     SliceBtnOut.Visible := false;
     FreqVarEdit.Text := '';
end;

procedure TABCLogLinearFrm.FileFromGrpClick(Sender: TObject);
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
          Label3.Visible := true;
          RowVarEdit.Visible := true;
          ColVarEdit.Visible := true;
          SliceVarEdit.Visible := true;
          FreqVarEdit.Visible := true;
          Label1.Visible := false;
          Label2.Visible := false;
          Label7.Visible := false;
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
          Label3.Visible := false;
          RowVarEdit.Visible := false;
          ColVarEdit.Visible := false;
          SliceVarEdit.Visible := false;
          FreqVarEdit.Visible := false;
          Label1.Visible := true;
          Label2.Visible := true;
          Label7.Visible := true;
          NRowsEdit.Visible := true;
          NColsEdit.Visible := true;
          NSlicesEdit.Visible := true;
          Grid.Visible := true;
     end;
end;

procedure TABCLogLinearFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TABCLogLinearFrm.FreqInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     FreqVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     FreqOutBtn.Visible := true;
     FreqInBtn.Visible := false;
end;

procedure TABCLogLinearFrm.FreqOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(FreqVarEdit.Text);
     FreqInBtn.Visible := true;
     FreqOutBtn.Visible := false;
     FreqVarEdit.Text := '';
end;

procedure TABCLogLinearFrm.NColsEditKeyPress(Sender: TObject; var Key: char);
begin
     if ord(Key) = 13 then NslicesEdit.SetFocus;
end;

procedure TABCLogLinearFrm.NRowsEditKeyPress(Sender: TObject; var Key: char);
begin
     if ord(Key) = 13 then NcolsEdit.SetFocus;
end;

procedure TABCLogLinearFrm.NslicesEditKeyPress(Sender: TObject; var Key: char);
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

procedure TABCLogLinearFrm.ColInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     ColVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     ColOutBtn.Visible := true;
     ColInBtn.Visible := false;
end;

procedure TABCLogLinearFrm.ColOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(ColVarEdit.Text);
     ColInBtn.Visible := true;
     ColOutBtn.Visible := false;
     ColVarEdit.Text := '';
end;

procedure TABCLogLinearFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k, row, col, slice, Nrows, Ncols, Nslices : integer;
   Data : DblDyneCube;
   AB, AC, BC : DblDyneMat;
   RowMarg, ColMarg, SliceMarg : DblDyneVec;
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
               if RowVarEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then GridPos[0] := i;
               if ColVarEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then GridPos[1] := i;
               if SliceVarEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then GridPos[2] := i;
               if FreqVarEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then GridPos[3] := i;
          end;
          // get no. of rows, columns and slices
          for i := 1 to OS3MainFrm.DataGrid.RowCount - 1 do
          begin
               value := StrToInt(OS3MainFrm.DataGrid.Cells[GridPos[0],i]);
               if value > Nrows then Nrows := value;
               value := StrToInt(OS3MainFrm.DataGrid.Cells[GridPos[1],i]);
               if value > Ncols then Ncols := value;
               value := StrToInt(OS3MainFrm.DataGrid.Cells[GridPos[2],i]);
               if value > Nslices then Nslices := value;
          end;
          SetLength(AB,Nrows+1,Ncols+1);
          SetLength(AC,Nrows+1,Nslices+1);
          SetLength(BC,Ncols+1,Nslices+1);
          SetLength(Data,Nrows+1,Ncols+1,Nslices+1);
          SetLength(RowMarg,Nrows+1);
          SetLength(ColMarg,Ncols+1);
          SetLength(SliceMarg,Nslices+1);

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
          for i := 1 to OS3MainFrm.DataGrid.RowCount - 1 do
          begin
               if Not GoodRecord(i, 4, GridPos) then continue;
               row := StrToInt(OS3MainFrm.DataGrid.Cells[rowcol,i]);
               col := StrToInt(OS3MainFrm.DataGrid.Cells[colcol,i]);
               slice := StrToInt(OS3MainFrm.DataGrid.Cells[slicecol,i]);
               Fx := StrToInt(OS3MainFrm.DataGrid.Cells[Fcol,i]);
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
          SetLength(AB,Nrows+1,Ncols+1);
          SetLength(AC,Nrows+1,Nslices+1);
          SetLength(BC,Ncols+1,Nslices+1);
          SetLength(Data,Nrows+1,Ncols+1,Nslices+1);
          SetLength(RowMarg,Nrows+1);
          SetLength(ColMarg,Ncols+1);
          SetLength(SliceMarg,Nslices+1);

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
     SliceMarg := nil;
     ColMarg := nil;
     RowMarg := nil;
     Data := nil;
     BC := nil;
     AC := nil;
     AB := nil;
end;

procedure TABCLogLinearFrm.ModelEffect(Nrows,Ncols,Nslices : integer;
                          VAR Data : DblDyneCube;
                          VAR RowMarg : DblDyneVec;
                          VAR ColMarg : DblDyneVec;
                          VAR SliceMarg : DblDyneVec;
                          VAR AB : DblDyneMat;
                          VAR AC : DblDyneMat;
                          VAR BC : DblDyneMat;
                          VAR Total : double;
                          Model : integer);
var
   i, j, k, l : integer;
   CellLambdas : DblDyneQuad;
   LogData, Expected : DblDyneCube;
   Title, astr : string;
   NewRowMarg,NewColMarg,NewSliceMarg : DblDyneVec;
   LogRowMarg, LogColMarg, LogSliceMarg : DblDyneVec;
   NewTotal : double;
   ABLogs, ACLogs, BCLogs : DblDyneMat;
   LogTotal, mu, ModelTotal, Ysqr : double;
   DF : integer;

begin
     // Get expected values for chosen model
     SetLength(Expected,Nrows+1,Ncols+1,Nslices+1);
     SetLength(NewRowMarg,Nrows+1);
     SetLength(NewColMarg,Ncols+1);
     SetLength(NewSliceMarg,Nslices+1);
     SetLength(LogRowMarg,Nrows+1);
     SetLength(LogColMarg,Ncols+1);
     SetLength(LogSliceMarg,Nslices+1);
     SetLength(ABLogs,Nrows+1,Ncols+1);
     SetLength(ACLogs,Nrows+1,Nslices+1);
     SetLength(BCLogs,Ncols+1,Nslices+1);
     SetLength(LogData,Nrows+1,Ncols+1,Nslices+1);
     SetLength(CellLambdas,Nrows+1,Ncols+1,Nslices+1,8);

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
     CellLambdas := nil;
     LogData := nil;
     BCLogs := nil;
     ACLogs := nil;
     ABLogs := nil;
     LogSliceMarg := nil;
     LogColMarg := nil;
     LogRowMarg := nil;
     NewSliceMarg := nil;
     NewColMarg := nil;
     NewRowMarg := nil;
     Expected := nil;
end;
//-------------------------------------------------------------------

procedure TABCLogLinearFrm.Iterate(Nrows, Ncols, Nslices : integer;
                      VAR Data : DblDyneCube;
                      VAR RowMarg : DblDyneVec;
                      VAR ColMarg : DblDyneVec;
                      VAR SliceMarg : DblDyneVec;
                      VAR Total : double;
                      VAR Expected : DblDyneCube;
                      VAR NewRowMarg : DblDyneVec;
                      VAR NewColMarg : DblDyneVec;
                      VAR NewSliceMarg : DblDyneVec;
                      VAR NewTotal : double);

Label Step;
var
   Aprevious : DblDyneCube;
   i, j, k : integer;
   delta : double;
   difference : double;

begin
     SetLength(Aprevious,Nrows+1,Ncols+1,Nslices+1);
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
                   Aprevious[i,j,k] := 1.0;
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
                 if abs(APrevious[i,j,k]-expected[i,j,k]) > difference then
                    difference := abs(APrevious[i,j,k]-expected[i,j,k]);

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
                      APrevious[i,j,k] := expected[i,j,k];
          for i := 1 to Nrows do newrowmarg[i] := 0.0;
          for j := 1 to Ncols do newcolmarg[j] := 0.0;
          for k := 1 to Nslices do newslicemarg[k] := 0.0;
          difference := 0.0;
          goto step;
     end;
     Aprevious := nil;
end;
//-------------------------------------------------------------------

procedure TABCLogLinearFrm.PrintTable(Nrows, Ncols, Nslices : integer;
                         VAR Data : DblDyneCube;
                         VAR RowMarg : DblDyneVec;
                         VAR ColMarg : DblDyneVec;
                         VAR SliceMarg : DblDyneVec;
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

procedure TABCLogLinearFrm.PrintLamdas(Nrows,Ncols,Nslices : integer;
                          Var CellLambdas : DblDyneQuad;
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

procedure TABCLogLinearFrm.PrintMatrix(VAR X : DblDyneMat;
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

initialization
  {$I abcloglinunit.lrs}

end.

