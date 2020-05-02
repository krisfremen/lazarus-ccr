unit GradingUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Grids,
  OutputUnit;

type

  { TGradingFrm }

  TGradingFrm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    Label4: TLabel;
    AssignedGrid: TStringGrid;
    Label5: TLabel;
    Grades: TStringGrid;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    SaveBtn: TButton;
    LoadBtn: TButton;
    ResetBtn: TButton;
    CloseBtn: TButton;
    DistUseGroup: TRadioGroup;
    CategoriesGroup: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    DownThroughLabel: TLabel;
    SaveDialog1: TSaveDialog;
    ScoresGrid: TStringGrid;
    GradesGrid: TStringGrid;
    TopScoreGrid: TStringGrid;
    LowScoreGrid: TStringGrid;
    TopScoreLabel: TLabel;
    procedure CategoriesGroupClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DistUseGroupClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure LowScoreGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ResetBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
  private
    { private declarations }
    NInts: integer;
    NCases: integer;
    Col: integer;
    NCats: integer;
    Sorted: array[0..50] of double;
  public
    { public declarations }
  end; 

var
  GradingFrm: TGradingFrm;

implementation

uses
  Math,
  Utils, GradebookUnit;

{ TGradingFrm }

procedure TGradingFrm.DistUseGroupClick(Sender: TObject);
var
  i, j, btn, nscores: integer;
  RawScores: array[0..50] of double;
  RawFreq: array[0..50] of double;
  temp, X, Y: double;
begin
  if DistUseGroup.ItemIndex < 0 then
    exit;

  col := GradebookFrm.tno + 3; // column of raw scores for test number tno
  btn := DistUseGroup.ItemIndex;
  nscores := GradebookFrm.nints;
  ScoresGrid.RowCount := nscores;
  ncases := GradebookFrm.NoStudents;
  case btn of
    0 : TopScoreGrid.Cells[0,0] := IntToStr(GradebookFrm.nitems);
    1 : TopScoreGrid.Cells[0,0] := FloatToStr(3.0);
    2 : TopScoreGrid.Cells[0,0] := FloatToStr(90.0);
    3 : TopScoreGrid.Cells[0,0] := FloatToStr(100.0);
  end;

  for i := 1 to ncases do
    RawScores[i-1] := StrToFloat(GradeBookFrm.Grid.cells[col+btn, i]);

  // sort RawScores into ascending order
  for i := 1 to ncases - 1 do
  begin
    for j := i+1 to ncases do
    begin
      X := RawScores[i-1];
      Y := RawScores[j-1];
      if RawScores[i-1] < RawScores[j-1] then // switch
        Exchange(RawScores[i-1], RawScores[j-1]);
    end;
  end;

   // get frequency of each score
  nints := 1;
  for i := 1 to ncases do RawFreq[i-1] := 0;
  X := RawScores[0];
  Sorted[0] := X;
  for i := 1 to ncases do
  begin
    if (X = RawScores[i-1])then
      RawFreq[nints-1] := RawFreq[nints-1] + 1
    else // new value
    begin
      nints := nints + 1;
      RawFreq[nints-1] := RawFreq[nints-1] + 1;
      X := RawScores[i-1];
      Sorted[nints-1] := X;
    end;
  end;

  // put data in grid
  ScoresGrid.RowCount := nints+1;
  GradesGrid.RowCount := nints + 1;
  for i := 0 to nints-1 do
  begin
    ScoresGrid.Cells[0,i] := FloatToStr(Sorted[i]);
    ScoresGrid.Cells[1,i] := FloatToStr(RawFreq[i]);
  end;
end;

procedure TGradingFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CancelBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TGradingFrm.FormShow(Sender: TObject);
var
  i, j: integer;
begin
  DistUseGroup.ItemIndex := -1;
  CategoriesGroup.ItemIndex := -1;
  for i := 0 to ScoresGrid.RowCount-1 do
    for j := 0 to 1 do ScoresGrid.Cells[j,i] := '';
  ScoresGrid.RowCount := 5;
  for i := 0 to Grades.RowCount-1 do Grades.Cells[0,i] := '';
  Grades.RowCount := 5;
  for i := 0 to GradesGrid.RowCount-1 do GradesGrid.Cells[0,i] := '';
  GradesGrid.RowCount := 5;
  for i := 0 to TopScoreGrid.RowCount-1 do TopScoreGrid.Cells[0,i] := '';
  TopScoreGrid.RowCount := 5;
  for i := 0 to LowScoreGrid.RowCount-1 do LowScoreGrid.Cells[0,i] := '';
  LowScoreGrid.RowCount := 5;
  for i := 0 to AssignedGrid.RowCount-1 do AssignedGrid.Cells[0,i] := '';
  AssignedGrid.RowCount := 5;
end;

procedure TGradingFrm.LoadBtnClick(Sender: TObject);
var
  FName: string;
  Grading: textfile;
  i, j, choice: integer;
  cellstring, outline: string;
  lReport: TStrings;
begin
  OpenDialog1.DefaultExt := '.grd';
  OpenDialog1.Filter := 'All (*.*)|*.*|Test Grading (*.grd)|*.grd;*.GRD';
  OpenDialog1.FilterIndex := 2;

  if OpenDialog1.Execute then
  begin
    FName := OpenDialog1.FileName;

    AssignFile(Grading, FName);
    Reset(Grading);

    ReadLn(Grading, NCases);
    ReadLn(Grading, NInts);
    ReadLn(Grading, Col);
    ReadLn(Grading, choice);

    lReport := TStringList.Create;
    try
      lReport.Add('Distribution used index = %2d', [choice]);
      ReadLn(Grading, choice);
      lReport.Add('Category index: %2d', [choice]);
      ReadLn(Grading, choice);
      lReport.Add('Top Score   Low Score');
      lReport.Add('----------  ----------');
      if choice = 0 then
      begin
        for i := 0 to 4 do
        begin
          ReadLn(Grading, cellstring);
          outline := Format('%10s ',[cellstring]);
          Readln(Grading, cellstring);
          outline := outline + Format('  %10s', [cellstring]);
          lReport.Add(outline);
        end;
      end else
      begin
        for i := 0 to 11 do
        begin
          ReadLn(Grading, cellstring);
          outline := Format('%10s', [cellstring]);
          Readln(Grading, cellstring);
          outline := outline + Format('  %10s', [cellstring]);
          lReport.Add(outline);
        end;
      end;
      lReport.Add('');

      lReport.Add('Assigned Grid');
      for i := 0 to NInts-1 do
      begin
        ReadLn(Grading, cellstring);
        lReport.Add(cellString);
      end;
      lReport.Add('Score       Frequency');
      lReport.Add('----------- -----------');
      for i := 0 to NInts - 1 do
      begin
        outline := '';
        for j := 0 to 1 do
        begin
          ReadLn(Grading, cellstring);
          outline := outline + Format('%11s  ',[cellstring]);
        end;
        lReport.Add(outline);
      end;

      DisplayReport(lReport);
    finally
      lReport.Free;
    end;

    CloseFile(Grading);
  end;
end;

procedure TGradingFrm.LowScoreGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i, row, freq, intervals: integer;
  lowval, hival, score1: double;
begin
  if Key = 13 then // enter key
  begin
    intervals := ScoresGrid.RowCount-1;
    row := LowScoreGrid.Row;
    freq := 0;
    lowval := StrToFloat(LowScoreGrid.Cells[0,row]);
    hival := StrToFloat(TopScoreGrid.Cells[0,row]);
    for i := 0 to intervals-1 do
    begin
      score1 := StrToFloat(ScoresGrid.Cells[0,i]);
      if (score1 >= lowval) and (score1 <= hival) then
        freq := freq + StrToInt(ScoresGrid.Cells[1,i]);
    end;

    AssignedGrid.Cells[0,row] := IntToStr(freq);
    if row < NCats-1 then
    begin
      if DistUseGroup.ItemIndex = 1 then  // z score
        TopScoreGrid.Cells[0,row+1] := FloatToStr(lowval-0.001);
      if DistUseGroup.ItemIndex = 0 then // raw score
        TopScoreGrid.Cells[0,row+1] := FloatToStr(lowval-1);
      if DistUseGroup.ItemIndex = 2 then // T score
        TopScoreGrid.Cells[0,row+1] := FloatToStr(lowval-0.1);
      if DistUseGroup.ItemIndex = 3 then // Percentile rank
        TopScoreGrid.Cells[0,row+1] := FloatToStr(lowval-0.01);
    end;
  end;
end;

procedure TGradingFrm.ResetBtnClick(Sender: TObject);
begin
  FormShow(self);
end;

procedure TGradingFrm.SaveBtnClick(Sender: TObject);
var
  FName: string;
  Grading: textfile;
  i, j, n : integer;
begin
  SaveDialog1.DefaultExt := '.grd';
  SaveDialog1.Filter := 'All Files (*.*)|*.*|Test Grading Files(*.grd)|*.grd;*.GRD';
  SaveDialog1.FilterIndex := 2;
  if SaveDialog1.Execute then
  begin
    FName := SaveDialog1.FileName;
    AssignFile(Grading,FName);
    Rewrite(Grading);
    writeln(Grading,ncases);
    writeln(Grading,nints);
    writeln(Grading,col);
    writeln(Grading,DistUseGroup.ItemIndex);
    writeln(Grading,CategoriesGroup.ItemIndex);
    if CategoriesGroup.ItemIndex = 0 then n := 5 else n := 12;
    for i := 0 to n-1 do
    begin
      writeln(Grading,TopScoreGrid.Cells[0,i]);
      writeln(Grading,LowScoreGrid.Cells[0,i]);
    end;
    for i := 0 to AssignedGrid.RowCount-1 do
      writeln(Grading,AssignedGrid.Cells[0,i]);
    for i := 0 to ScoresGrid.RowCount - 1 do
      for j := 0 to 1 do writeln(Grading,ScoresGrid.Cells[j,i]);
  end;

  CloseFile(Grading);
end;


procedure TGradingFrm.CategoriesGroupClick(Sender: TObject);
const
  CATS_COUNT: array[0..1] of Integer = (5, 12);
  GRADES_5: array[0..4] of Char = ('A', 'B', 'C', 'D', 'F');
  GRADES_12: array[0..11] of String[2] = ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-', 'F');
var
  i: Integer;
begin
  NCats := CATS_COUNT[CategoriesGroup.ItemIndex];
  Grades.RowCount := NCats;
  TopScoreGrid.RowCount := NCats;
  LowScoreGrid.RowCount := Ncats;
  AssignedGrid.RowCount := NCats;
  for i := 0 to NCats - 1 do
    case CategoriesGroup.ItemIndex of
      0: Grades.Cells[0, i] := GRADES_5[i];
      1: Grades.Cells[0, i] := GRADES_12[i];
    end;
end;

procedure TGradingFrm.ComputeBtnClick(Sender: TObject);
var
  i, j: integer;
  X, Y, low, hi: double;
begin
  // build AssignedGrid of grades for each Score in the ScoresGrid
  for i := 0 to NCats - 1 do
  begin
    hi := StrToFloat(TopScoreGrid.Cells[0,i]);
    low := StrToFloat(LowScoreGrid.Cells[0,i]);
    for j := 0 to nints-1 do
    begin
      X := StrToFloat(ScoresGrid.Cells[0,j]);
      if (X >= low) and (X <= hi) then GradesGrid.cells[0,j] := Grades.cells[0,i];
    end;
  end;

  // Now assign grades in the gradebook
  for i := 1 to ncases do // gradebook grade cells
  begin
    Y := StrToFloat(GradeBookFrm.grid.Cells[col,i]);
    for j := 0 to nints - 1 do // Grade of values in the ScoreGrid
    begin
      X := StrToFloat(ScoresGrid.Cells[0,j]);
      if X = Y then GradeBookFrm.Grid.Cells[col+4,i] := GradesGrid.Cells[0,j];
    end;
  end;
end;

initialization
  {$I gradingunit.lrs}

end.

