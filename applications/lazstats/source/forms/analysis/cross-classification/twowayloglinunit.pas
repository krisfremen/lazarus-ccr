unit TwoWayLogLinUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Grids,
  OutputUnit, MainUnit, Globals, DataProcs, ContextHelpUnit;

type

  { TTwoWayLogLinFrm }

  TTwoWayLogLinFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    Notebook1: TNotebook;
    Page1: TPage;
    Page2: TPage;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    RowInBtn: TBitBtn;
    RowOutBtn: TBitBtn;
    ColInBtn: TBitBtn;
    ColOutBtn: TBitBtn;
    FreqInBtn: TBitBtn;
    FreqOutBtn: TBitBtn;
    NoRowsEdit: TEdit;
    NoColsEdit: TEdit;
    NoRowsLabel: TLabel;
    NoColsLabel: TLabel;
    RowVarEdit: TEdit;
    ColVarEdit: TEdit;
    FreqVarEdit: TEdit;
    FileFromGrp: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Grid: TStringGrid;
    VarList: TListBox;
    procedure ColInBtnClick(Sender: TObject);
    procedure ColOutBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FileFromGrpClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FreqInBtnClick(Sender: TObject);
    procedure FreqOutBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure NoColsEditKeyPress(Sender: TObject; var Key: char);
    procedure NoRowsEditKeyPress(Sender: TObject; var Key: char);
    procedure ResetBtnClick(Sender: TObject);
    procedure RowInBtnClick(Sender: TObject);
    procedure RowOutBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;

    procedure PrintTable(Nrows, Ncols: integer; const Data: DblDyneMat;
      const RowMarg, ColMarg: DblDyneVec; Total: double; AReport: TStrings);
    procedure Iterate(Nrows, Ncols: integer;
      const Data: DblDyneMat; const RowMarg, ColMarg: DblDyneVec;
      var Total: double;
      const Expected: DblDyneMat; const NewRowMarg, NewColMarg: DblDyneVec;
      var NewTotal: double);
    procedure PrintLamdas(Nrows, Ncols : integer; const CellLambdas: DblDyneCube;
      mu: double; AReport: TStrings);

  public
    { public declarations }
  end; 

var
  TwoWayLogLinFrm: TTwoWayLogLinFrm;

implementation

uses
  Math;

{ TTwoWayLogLinFrm }

procedure TTwoWayLogLinFrm.ResetBtnClick(Sender: TObject);
VAR i, j : integer;
begin
     for i := 0 to Grid.RowCount - 1 do
         for j := 0 to Grid.ColCount - 1 do
             Grid.Cells[j,i] := '';
     Grid.ColCount := 3;
     Grid.RowCount := 2;
     Grid.Cells[0,0] := 'ROW';
     Grid.Cells[1,0] := 'COL';
     Grid.Cells[2,0] := 'FREQ';
     VarList.Clear;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     RowVarEdit.Text := '';
     ColVarEdit.Text := '';
     FreqVarEdit.Text := '';
     NoRowsEdit.Text := '';
     NoColsEdit.Text := '';
     FileFromGrp.ItemIndex := -1;
     Notebook1.Hide;
     {
     VarList.Visible := false;
     RowInBtn.Enabled := false;
     RowOutBtn.Enabled := false;
     ColInBtn.Enabled := false;
     ColOutBtn.Enabled := false;
     FreqInBtn.Enabled := false;
     FreqOutBtn.Enabled := false;
     Label1.Visible := false;
     Label2.Visible := false;
     Label3.Visible := false;
     RowVarEdit.Visible := false;
     ColVarEdit.Visible := false;
     FreqVarEdit.Visible := false;
//     Memo1.Visible := false;
     NoRowsLabel.Visible := false;
     NoColsLabel.Visible := false;
     NoRowsEdit.Visible := false;
     NoColsEdit.Visible := false;
     Grid.Visible := false;
     }
end;

procedure TTwoWayLogLinFrm.RowInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (RowVarEdit.Text = '') then
  begin
    RowVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TTwoWayLogLinFrm.RowOutBtnClick(Sender: TObject);
begin
  if RowVarEdit.Text <> '' then
  begin
    VarList.Items.Add(RowVarEdit.Text);
    RowVarEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TTwoWayLogLinFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TTwoWayLogLinFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TTwoWayLogLinFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TTwoWayLogLinFrm.FreqInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (FreqVarEdit.Text = '') then
  begin
    FreqVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TTwoWayLogLinFrm.FreqOutBtnClick(Sender: TObject);
begin
  if FreqVarEdit.Text <> '' then
  begin
    VarList.Items.Add(FreqVarEdit.Text);
    FreqVarEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TTwoWayLogLinFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TTwoWayLogLinFrm.NoColsEditKeyPress(Sender: TObject; var Key: char);
var
   i, j, row : integer;
   Ncols, Nrows : integer;

begin
     if ord(Key) = 13 then
     begin
          Nrows := StrToInt(NoRowsEdit.Text);
          Ncols := StrToInt(NoColsEdit.Text);
          Grid.RowCount := (Nrows * Ncols) + 1;
          // setup row and column values in the grid
          row := 1;
          for j := 1 to Ncols do
          begin
               for i := 1 to Nrows do
               begin
                    Grid.Cells[0,row] := IntToStr(i);
                    Grid.Cells[1,row] := IntToStr(j);
                    row := row + 1;
               end;
          end;
          Grid.SetFocus;
     end;
end;

procedure TTwoWayLogLinFrm.NoRowsEditKeyPress(Sender: TObject; var Key: char);
begin
     if ord(Key) = 13 then NoColsEdit.SetFocus;
end;

procedure TTwoWayLogLinFrm.ComputeBtnClick(Sender: TObject);
var
   Data : DblDyneMat;
   NewData : DblDyneMat;
   Prop : DblDyneMat;
   LogData : DblDyneMat;
   Expected : DblDyneMat;
   i, j, k : integer;
   RowMarg : DblDyneVec;
   NewRowMarg : DblDyneVec;
   RowLogs : DblDyneVec;
   ColMarg : DblDyneVec;
   NewColMarg : DblDyneVec;
   ColLogs : DblDyneVec;
   CellLambdas : DblDyneCube;
   Total : double;
   NewTotal : double;
   TotalLogs : double;
   mu : double;
   row, col : integer;
   ModelTotal : double;
   astr : string;
   Ysqr : double;
   DF : integer;
   chisqr: double;
   odds : double;
   Nrows, Ncols : integer;
   RowCol, ColCol, Fcol : integer;
   GridPos : IntDyneVec;
   value : integer;
   Fx : double;
   lReport: TStrings;

begin
  Total := 0.0;
  TotalLogs := 0.0;
  Nrows := 0;
  Ncols := 0;

  if FileFromGrp.ItemIndex = 0 then // mainfrm input
  begin
      SetLength(GridPos,3);
      for i := 1 to NoVariables do
      begin
           if RowVarEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then GridPos[0] := i;
           if ColVarEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then GridPos[1] := i;
           if FreqVarEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then GridPos[2] := i;
      end;
      // get no. of rows and columns
      for i := 1 to OS3MainFrm.DataGrid.RowCount - 1 do
      begin
           value := StrToInt(OS3MainFrm.DataGrid.Cells[GridPos[0],i]);
           if value > Nrows then Nrows := value;
           value := StrToInt(OS3MainFrm.DataGrid.Cells[GridPos[1],i]);
           if value > Ncols then Ncols := value;
      end;

      // Get data
      SetLength(Data,Nrows+1,Ncols+1);
      SetLength(CellLambdas,Nrows+1,Ncols+1,4);
      SetLength(RowMarg,Nrows+1);
      SetLength(RowLogs,Nrows+1);
      SetLength(ColMarg,Ncols+1);
      SetLength(ColLogs,Ncols+1);
      SetLength(Prop,Nrows+1,Ncols+1);
      SetLength(LogData,Nrows+1,Ncols+1);
      SetLength(Expected,Nrows+1,Ncols+1);
      SetLength(NewData,Nrows+1,Ncols+1);
      SetLength(NewRowMarg,Nrows+1);
      SetLength(NewColMarg,Ncols+1);

      for i := 1 to Nrows do
          for j := 1 to Ncols do
              Data[i,j] := 0.0;
      rowcol := GridPos[0];
      colcol := GridPos[1];
      Fcol := GridPos[2];
      for i := 1 to OS3MainFrm.DataGrid.RowCount - 1 do
      begin
           if Not GoodRecord(i, 3, GridPos) then continue;
           row := StrToInt(OS3MainFrm.DataGrid.Cells[rowcol,i]);
           col := StrToInt(OS3MainFrm.DataGrid.Cells[colcol,i]);
           Fx := StrToInt(OS3MainFrm.DataGrid.Cells[Fcol,i]);
           Data[row,col] := Data[row,col] + Fx;
           Total := Total + Fx;
      end;
      GridPos := nil;
  end;

  if FileFromGrp.ItemIndex = 1 then // form data
  begin
      Nrows := StrToInt(NoRowsEdit.Text);
      Ncols := StrToInt(NoColsEdit.Text);
      SetLength(Data,Nrows+1,Ncols+1);
      SetLength(CellLambdas,Nrows+1,Ncols+1,4);
      SetLength(RowMarg,Nrows+1);
      SetLength(RowLogs,Nrows+1);
      SetLength(ColMarg,Ncols+1);
      SetLength(ColLogs,Ncols+1);
      SetLength(Prop,Nrows+1,Ncols+1);
      SetLength(LogData,Nrows+1,Ncols+1);
      SetLength(Expected,Nrows+1,Ncols+1);
      SetLength(NewData,Nrows+1,Ncols+1);
      SetLength(NewRowMarg,Nrows+1);
      SetLength(NewColMarg,Ncols+1);
  end;

  for i := 1 to Nrows do
      for j := 1 to Ncols do
          for k := 1 to 3 do CellLambdas[i,j,k] := 0.0;

  for i := 1 to Nrows do
  begin
      RowMarg[i] := 0.0;
      RowLogs[i] := 0.0;
  end;

  for j := 1 to Ncols do
  begin
      ColMarg[j] := 0.0;
      ColLogs[j] := 0.0;
  end;

  if FileFromGrp.ItemIndex = 1 then // get data from grid
  begin
      for i := 1 to (Nrows * Ncols) do
      begin
           row := StrToInt(Grid.Cells[0,i]);
           col := StrToInt(Grid.Cells[1,i]);
           Data[row,col] := StrToFloat(Grid.Cells[2,i]);
           Total := Total + Data[row,col];
      end;
  end;

  for i := 1 to Nrows do
  begin
      for j := 1 to Ncols do
      begin
           RowMarg[i] := RowMarg[i] + Data[i,j];
           ColMarg[j] := ColMarg[j] + Data[i,j];
           Prop[i,j] := Prop[i,j] / Total;
           LogData[i,j] := ln(Data[i,j]);
      end;
  end;

  // report cross-products odds and log odds ratios
  lReport := TStringList.Create;
  try
    lReport.Add('ANALYSES FOR AN I BY J CLASSIFICATION TABLE');
    lReport.Add('');
    lReport.Add('Reference: G.J.G. Upton, The Analysis of Cross-tabulated Data, 1980');
    lReport.Add('');
    if (Nrows = 2) and (Ncols = 2) then
    begin
      odds := (Data[1,1] * Data[2,2]) / (Data[1,2] * Data[2,1]);
      lReport.Add('Cross-Products Odds Ratio:            %6.3f', [odds]);
      lReport.Add('Log odds of the cross-products ratio: %6.3f', [ln(odds)]);
      lReport.Add('');
    end;
    for i := 1 to Nrows do
    begin
      for j := 1 to Ncols do
      begin
           RowLogs[i] := RowLogs[i] + LogData[i,j];
           ColLogs[j] := ColLogs[j] + LogData[i,j];
           TotalLogs := TotalLogs + LogData[i,j];
      end;
    end;

    for i := 1 to Nrows do RowLogs[i] := RowLogs[i] / Ncols;
    for j := 1 to Ncols do ColLogs[j] := ColLogs[j] / Nrows;
    TotalLogs := TotalLogs / (Nrows * Ncols);
    mu := TotalLogs;

    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           CellLambdas[i,j,1] := RowLogs[i] - TotalLogs;
           CellLambdas[i,j,2] := ColLogs[j] - TotalLogs;
           CellLambdas[i,j,3] := LogData[i,j] - RowLogs[i]  - ColLogs[j] + TotalLogs;
      end;

    // Get expected values for saturated model
    for i := 1 to Nrows do
    begin
      for j := 1 to Ncols do
      begin
           ModelTotal := mu;
           for k := 1 to 3 do
                ModelTotal := ModelTotal + CellLambdas[i,j,k];
           Expected[i,j] := exp(ModelTotal);
      end;
    end;

    // Get Y square for saturated model
    Ysqr := 0.0;
    for i := 1 to Nrows do
     for j := 1 to Ncols do
         Ysqr := Ysqr + Data[i,j] * (ln(Data[i,j]) - ln(Expected[i,j]));
    Ysqr := 2.0 * Ysqr;

    // write out values for saturated model
    lReport.Add('Saturated Model Results');
    lReport.Add('');
    lReport.Add('Observed Frequencies');
    PrintTable(Nrows, Ncols, Data, RowMarg, ColMarg, Total, lReport);
    lReport.Add('Log frequencies, row average and column average of log frequencies');
    PrintTable(Nrows, Ncols, LogData, RowLogs, ColLogs, TotalLogs, lReport);
    lReport.Add('Expected Frequencies');
    PrintTable(Nrows, Ncols, Expected, RowMarg, ColMarg, Total, lReport);

    lReport.Add('Cell Parameters');
    PrintLamdas(Nrows, Ncols, CellLambdas, mu, lReport);

    lReport.Add('Y squared statistic for model fit: ' + format('%.3f',[Ysqr]) + ' D.F. 0');

    lReport.Add('');
    lReport.Add('=======================================================================');
    lReport.Add('');

    // Do the model of independence
    lReport.Add('Independent Effects Model Results');
    lReport.Add('');

    lReport.Add('Expected Frequencies');
    Iterate(Nrows,Ncols, Data, RowMarg, ColMarg, Total, Expected, NewRowMarg, NewColMarg, NewTotal);
    PrintTable(Nrows, Ncols, Expected, NewRowMarg, NewColMarg, NewTotal, lReport);
    for i := 1 to Nrows do
      for j := 1 to Ncols do
           LogData[i,j] := ln(Expected[i,j]);
    for i := 1 to Nrows do RowLogs[i] := 0.0;
    for j := 1 to Ncols do ColLogs[j] := 0.0;
    TotalLogs := 0.0;
    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           RowLogs[i] := RowLogs[i] + LogData[i,j];
           ColLogs[j] := ColLogs[j] + LogData[i,j];
           TotalLogs := TotalLogs + LogData[i,j];
      end;

    for i := 1 to Nrows do RowLogs[i] := RowLogs[i] / Ncols;
    for j := 1 to Ncols do ColLogs[j] := ColLogs[j] / Nrows;
    TotalLogs := TotalLogs / (Nrows * Ncols);
    mu := TotalLogs;

    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           CellLambdas[i,j,1] := RowLogs[i] - TotalLogs;
           CellLambdas[i,j,2] := ColLogs[j] - TotalLogs;
           CellLambdas[i,j,3] := LogData[i,j] - RowLogs[i]  - ColLogs[j] + TotalLogs;
      end;
    lReport.Add('Cell Parameters');
    PrintLamdas(Nrows, Ncols, CellLambdas, mu, lReport);

    Ysqr := 0.0;
    for i := 1 to Nrows do
     for j := 1 to Ncols do
         Ysqr := Ysqr + Data[i,j] * (ln(Data[i,j]) - ln(Expected[i,j]));
    Ysqr := 2.0 * Ysqr;
    lReport.Add('');
    astr := 'Y squared statistic for model fit: ' + Format('%.3f',[Ysqr]);
    DF := (NRows - 1) * (NCols - 1);
    astr := astr + ', D.F. = ' + IntToStr(DF);
    lReport.Add(astr);

    chisqr := 0.0;
    for i := 1 to Nrows do
     for j := 1 to Ncols do
         chisqr := chisqr + (power((Data[i,j] - Expected[i,j]),2) / Expected[i,j]);
    lReport.Add('Chi-squared = %.3f with %d D.F.', [chisqr, DF]);

    lReport.Add('');
    lReport.Add('=======================================================================');
    lReport.Add('');

    // Do no Column Effects model
    lReport.Add('No Column Effects Model Results');
    lReport.Add('');
    for i := 1 to Nrows do
     for j := 1 to Ncols do
         Expected[i,j] := RowMarg[i] / Ncols;
    for i := 1 to Nrows do NewRowMarg[i] := 0.0;
    for j := 1 to Ncols do NewColMarg[j] := 0.0;
    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           NewRowMarg[i] := NewRowMarg[i] + Expected[i,j];
           NewColMarg[j] := NewColMarg[j] + Expected[i,j];
      end;
    lReport.Add('Expected Frequencies');
    PrintTable(Nrows, Ncols, Expected, NewRowMarg, NewColMarg, NewTotal, lReport);

    for i := 1 to Nrows do
      for j := 1 to Ncols do
           LogData[i,j] := ln(Expected[i,j]);
    for i := 1 to Nrows do RowLogs[i] := 0.0;
    for j := 1 to Ncols do ColLogs[j] := 0.0;
    TotalLogs := 0.0;
    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           RowLogs[i] := RowLogs[i] + LogData[i,j];
           ColLogs[j] := ColLogs[j] + LogData[i,j];
           TotalLogs := TotalLogs + LogData[i,j];
      end;

    for i := 1 to Nrows do RowLogs[i] := RowLogs[i] / Ncols;
    for j := 1 to Ncols do ColLogs[j] := ColLogs[j] / Nrows;
    TotalLogs := TotalLogs / (Nrows * Ncols);
    mu := TotalLogs;

    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           CellLambdas[i,j,1] := RowLogs[i] - TotalLogs;
           CellLambdas[i,j,2] := ColLogs[j] - TotalLogs;
           CellLambdas[i,j,3] := LogData[i,j] - RowLogs[i]  - ColLogs[j] + TotalLogs;
      end;

    lReport.Add('Cell Parameters');
    PrintLamdas(Nrows, Ncols, CellLambdas, mu, lReport);

    Ysqr := 0.0;
    for i := 1 to Nrows do
     for j := 1 to Ncols do
         Ysqr := Ysqr + Data[i,j] * (ln(Data[i,j]) - ln(Expected[i,j]));
    Ysqr := 2.0 * Ysqr;
    lReport.Add('');

    astr := 'Y squared statistic for model fit: ' + Format('%.3f',[Ysqr]);
    DF := (Nrows - 1) * Ncols;
    astr := astr + ', D.F. ' + IntToStr(DF);
    lReport.Add(astr);

    lReport.Add('');
    lReport.Add('=======================================================================');
    lReport.Add('');

    // Do no Row Effects model
    lReport.Add('No Row Effects Model Results');
    lReport.Add('');
    for i := 1 to Nrows do
     for j := 1 to Ncols do
         Expected[i,j] := ColMarg[j] / Nrows;
    for i := 1 to Nrows do  NewRowMarg[i] := 0.0;
    for j := 1 to Ncols do  NewColMarg[j] := 0.0;
    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           NewRowMarg[i] := NewRowMarg[i] + Expected[i,j];
           NewColMarg[j] := NewColMarg[j] + Expected[i,j];
      end;

    lReport.Add('Expected Frequencies');
    PrintTable(Nrows, Ncols, Expected, NewRowMarg, NewColMarg, NewTotal, lReport);
    for i := 1 to Nrows do
      for j := 1 to Ncols do
           LogData[i,j] := ln(Expected[i,j]);
    for i := 1 to Nrows do RowLogs[i] := 0.0;
    for j := 1 to Ncols do ColLogs[j] := 0.0;
    TotalLogs := 0.0;
    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           RowLogs[i] := RowLogs[i] + LogData[i,j];
           ColLogs[j] := ColLogs[j] + LogData[i,j];
           TotalLogs := TotalLogs + LogData[i,j];
      end;

    for i := 1 to Nrows do RowLogs[i] := RowLogs[i] / Ncols;
    for j := 1 to Ncols do ColLogs[j] := ColLogs[j] / Nrows;
    TotalLogs := TotalLogs / (Nrows * Ncols);
    mu := TotalLogs;

    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           CellLambdas[i,j,1] := RowLogs[i] - TotalLogs;
           CellLambdas[i,j,2] := ColLogs[j] - TotalLogs;
           CellLambdas[i,j,3] := LogData[i,j] - RowLogs[i]  - ColLogs[j] + TotalLogs;
      end;

    lReport.Add('Cell Parameters');
    PrintLamdas(Nrows, Ncols, CellLambdas, mu, lReport);
    Ysqr := 0.0;
    for i := 1 to Nrows do
     for j := 1 to Ncols do
         Ysqr := Ysqr + Data[i,j] * (ln(Data[i,j]) - ln(Expected[i,j]));
    Ysqr := 2.0 * Ysqr;
    lReport.Add('');
    astr := 'Y squared statistic for model fit: ' + Format('%.3f', [Ysqr]);
    DF := (Ncols - 1) * Nrows;
    astr := astr + ', D.F. ' + IntToStr(DF);
    lReport.Add(astr);

    lReport.Add('');
    lReport.Add('=======================================================================');
    lReport.Add('');

    // Do equiprobability model
    lReport.Add('Equiprobability Effects Model Results');
    lReport.Add('');
    for i := 1 to Nrows do
     for j := 1 to Ncols do
         Expected[i,j] := Total / (Nrows * Ncols);
    for i := 1 to Nrows do NewRowMarg[i] := Total / (Nrows * Ncols);
    for j := 1 to 2 do NewColMarg[j] := Total / (Nrows * Ncols);

    lReport.Add('Expected Frequencies');
    PrintTable(Nrows, Ncols, Expected, NewRowMarg, NewColMarg, NewTotal, lReport);
    for i := 1 to Nrows do
      for j := 1 to Ncols do
           LogData[i,j] := ln(Expected[i,j]);
    for i := 1 to Nrows do RowLogs[i] := 0.0;
    for j := 1 to Ncols do ColLogs[j] := 0.0;
    TotalLogs := 0.0;
    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           RowLogs[i] := RowLogs[i] + LogData[i,j];
           ColLogs[j] := ColLogs[j] + LogData[i,j];
           TotalLogs := TotalLogs + LogData[i,j];
      end;

    for i := 1 to Nrows do RowLogs[i] := RowLogs[i] / Ncols;
    for j := 1 to Ncols do ColLogs[j] := ColLogs[j] / Nrows;
    TotalLogs := TotalLogs / (Nrows * Ncols);
    mu := TotalLogs;

    for i := 1 to Nrows do
      for j := 1 to Ncols do
      begin
           CellLambdas[i,j,1] := RowLogs[i] - TotalLogs;
           CellLambdas[i,j,2] := ColLogs[j] - TotalLogs;
           CellLambdas[i,j,3] := LogData[i,j] - RowLogs[i]  - ColLogs[j] + TotalLogs;
      end;

    lReport.Add('Cell Parameters');
    PrintLamdas(Nrows, Ncols, CellLambdas, mu, lReport);
    Ysqr := 0.0;
    for i := 1 to Nrows do
      for j := 1 to Ncols do
         Ysqr := Ysqr + Data[i,j] * (ln(Data[i,j]) - ln(Expected[i,j]));
    Ysqr := 2.0 * Ysqr;
    lReport.Add('');
    astr := 'Y squared statistic for model fit: ' + format('%.3f',[Ysqr]);
    DF := Nrows * Ncols - 1;
    astr := astr + ', D.F. ' + IntToStr(DF);
    lReport.Add(astr);

    DisplayReport(lReport);

  finally
    lReport.Free;

    NewColMarg := nil;
    NewRowMarg := nil;
    NewData := nil;
    Expected := nil;
    LogData := nil;
    Prop := nil;
    ColLogs := nil;
    ColMarg := nil;
    RowLogs := nil;
    RowMarg := nil;
    CellLambdas := nil;
    Data := nil;
  end;
end;

procedure TTwoWayLogLinFrm.FileFromGrpClick(Sender: TObject);
begin
  Notebook1.PageIndex := FileFromGrp.ItemIndex;
  Notebook1.Show;
end;

procedure TTwoWayLogLinFrm.ColInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (ColVarEdit.Text = '') then
  begin
    ColVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TTwoWayLogLinFrm.ColOutBtnClick(Sender: TObject);
begin
  if ColVarEdit.Text <> '' then
  begin
    VarList.Items.Add(ColVarEdit.Text);
    ColVarEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TTwoWayLogLinFrm.PrintTable(Nrows, Ncols : integer;
  const Data: DblDyneMat; const RowMarg, ColMarg: DblDyneVec;
  Total: double; AReport: TStrings);
var
  astr: string;
  i, j: integer;
begin
  astr := 'ROW/COL   ';
  for j := 1 to Ncols do astr := astr + Format('   %3d    ', [j]);
  astr := astr + '  TOTAL';
  AReport. Add(astr);

  for i := 1 to Nrows do
  begin
    astr := Format('   %3d    ', [i]);
    for j := 1 to Ncols do
      astr := astr + Format(' %8.2f ', [Data[i,j]]);
    astr := astr + Format(' %8.2f ', [RowMarg[i]]);
    AReport.Add(astr);
  end;

  astr := 'TOTAL     ';
  for j := 1 to Ncols do astr := astr + Format(' %8.2f ',[ColMarg[j]]);
  astr := astr + Format(' %8.2f ', [Total]);
  AReport.Add(astr);
  AReport.Add('');
end;

procedure TTwoWayLogLinFrm.Iterate(Nrows, Ncols: integer;
  const Data: DblDyneMat; const RowMarg, ColMarg: DblDyneVec; var Total: double;
  const Expected: DblDyneMat; const NewRowMarg, NewColMarg: DblDyneVec; var NewTotal: double);
Label Step;
var
  Aprevious: DblDyneMat;
  i, j: integer;
  delta: double;
  difference: double;
begin
  delta := 0.1;
  difference := 0.0;
  SetLength(Aprevious, Nrows+1, Ncols+1);

  // initialize expected values
  for i := 1 to Nrows do
    for j := 1 to Ncols do
    begin
      expected[i,j] := 1.0;
      Aprevious[i,j] := 1.0;
    end;

Step:
  // step 1: initialize new row margins and calculate expected value
  for i := 1 to Nrows do
    for j := 1 to Ncols do
      newrowmarg[i] := newrowmarg[i] + expected[i,j];

  for i := 1 to Nrows do
    for j := 1 to Ncols do
      expected[i,j] := (RowMarg[i] / newrowmarg[i]) * expected[i,j];

  // step 2: initialize new col margins and calculate expected values
  for i := 1 to Nrows do
    for j := 1 to Ncols do
      newcolmarg[j] := newcolmarg[j] + expected[i,j];

  for i := 1 to Nrows do
    for j := 1 to Ncols do
      expected[i,j] := (ColMarg[j] / newcolmarg[j]) * expected[i,j];

  // step 3: check for change and quit if smaller than delta
  for i := 1 to Nrows do
    for j := 1 to Ncols do
      if abs(APrevious[i,j]-expected[i,j]) > difference then
        difference := abs(APrevious[i,j]-expected[i,j]);

  if difference < delta then
  begin
    newtotal := 0.0;
    for i := 1 to Nrows do
      for j := 1 to Ncols do
        newtotal := newtotal + expected[i,j];
    exit;
  end else
  begin
    for i := 1 to Nrows do
      for j := 1 to Ncols do
        APrevious[i,j] := expected[i,j];
    for i := 1 to Nrows do newrowmarg[i] := 0.0;
    for j := 1 to Ncols do newcolmarg[j] := 0.0;
    difference := 0.0;
    goto step;
  end;
  Aprevious := nil;
end;

procedure TTwoWayLogLinFrm.PrintLamdas(Nrows,Ncols: integer;
  const CellLambdas: DblDyneCube; mu: double; AReport: TStrings);
var
  i, j, k: integer;
  astr: string;
begin
  AReport.Add('ROW COL   MU      LAMBDA ROW   LAMBDA COL   LAMBDA ROW x COL');

  for i := 1 to Nrows do
  begin
    for j := 1 to Ncols do
    begin
      astr := Format('%3d %3d ', [i, j]);
      astr := astr + Format('%6.3f    ', [mu]);
      for k := 1 to 3 do
        astr := astr + format(' %6.3f      ', [CellLambdas[i,j,k]]);
      AReport.Add(astr);
    end;
  end;
  AReport.Add('');
end;

procedure TTwoWayLogLinFrm.UpdateBtnStates;
begin
  RowInBtn.Enabled := (VarList.ItemIndex > -1) and (RowVarEdit.Text = '');
  ColInBtn.Enabled := (VarList.ItemIndex > -1) and (ColVarEdit.Text = '');
  FreqInBtn.Enabled := (VarList.ItemIndex > -1) and (FreqVarEdit.Text = '');
  RowOutBtn.Enabled := (RowVarEdit.Text <> '');
  ColOutBtn.Enabled := (ColVarEdit.Text <> '');
  FreqOutBtn.Enabled := (FreqVarEdit.Text <> '');
end;

procedure TTwoWayLogLinFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I twowayloglinunit.lrs}

end.

