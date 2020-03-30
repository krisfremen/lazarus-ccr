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
    Cancelbtn: TButton;
    ReturnBtn: TButton;
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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure LowScoreGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ResetBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
  private
    { private declarations }
    nints : integer;
    ncases : integer;
    col : integer;
    ncats : integer;
    sorted : array[0..50] of double;
  public
    { public declarations }
  end; 

var
  GradingFrm: TGradingFrm;

implementation

uses
  Math,
  gradebookunit;

{ TGradingFrm }

procedure TGradingFrm.DistUseGroupClick(Sender: TObject);
VAR
   i, j, btn, nscores : integer;
   RawScores : array[0..50] of double;
   RawFreq : array[0..50] of double;
   temp, X, Y : double;
begin
     if DistUseGroup.ItemIndex < 0 then exit;
     col := gradebookfrm.tno + 3; // column of raw scores for test number tno
     btn := DistUseGroup.ItemIndex;
     nscores := gradebookfrm.nints;
     ScoresGrid.RowCount := nscores;
     ncases := gradebookfrm.NoStudents;
     case btn of
     0 : TopScoreGrid.Cells[0,0] := IntToStr(gradebookfrm.nitems);
     1 : TopScoreGrid.Cells[0,0] := FloatToStr(3.0);
     2 : TopScoreGrid.Cells[0,0] := FloatToStr(90.0);
     3 : TopScoreGrid.Cells[0,0] := FloatToStr(100.0);
     end;

     case btn of
     0 : for i := 1 to ncases do RawScores[i-1] := StrToFloat(gradebookfrm.Grid.Cells[col,i]);
     1 : for i := 1 to ncases do RawScores[i-1] := StrToFloat(gradebookfrm.Grid.Cells[col+1,i]);
     2 : for i := 1 to ncases do RawScores[i-1] := StrToFloat(gradebookfrm.Grid.Cells[col+2,i]);
     3 : for i := 1 to ncases do RawScores[i-1] := StrToFloat(gradebookfrm.Grid.Cells[col+3,i]);
     end;

     // sort RawScores into ascending order
     for i := 1 to ncases - 1 do
     begin
          for j := i+1 to ncases do
          begin
               X := RawScores[i-1];
               Y := RawScores[j-1];
               if RawScores[i-1] < RawScores[j-1] then // switch
               begin
                    temp := RawScores[i-1];
                    RawScores[i-1] := RawScores[j-1];
                    RawScores[j-1] := temp;
               end;
          end;
     end;

     // get frequency of each score
    nints := 1;
    for i := 1 to ncases do RawFreq[i-1] := 0;
    X := RawScores[0];
    Sorted[0] := X;
    for i := 1 to ncases do
    begin
        if (X = RawScores[i-1])then RawFreq[nints-1] := RawFreq[nints-1] + 1
        else // new value
        begin
            nints := nints + 1;
            RawFreq[nints-1] := RawFreq[nints-1] + 1;
            X := RawScores[i-1];
            Sorted[nints-1] := X;
        end;
    end;

    // put data in grid
//    AssignedGrid.RowCount := nints + 1;
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
  w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure TGradingFrm.FormCreate(Sender: TObject);
begin
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TGradingFrm.FormShow(Sender: TObject);
VAR
   i, j : integer;
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
        FName : string;
        Grading : textfile;
        i, j, choice : integer;
        cellstring, outline, valstr : string;
begin
        OutputFrm.RichEdit.Clear;
        OpenDialog1.DefaultExt := '.GRD';
        OpenDialog1.Filter := 'ALL (*.*)|*.*|Test Grading (*.GRD)|*.GRD';
        OpenDialog1.FilterIndex := 2;
        if OpenDialog1.Execute then
        begin
//             GetNoRecords;
             FName := OpenDialog1.FileName;
             AssignFile(Grading,FName);
             Reset(Grading);
             readln(Grading,ncases);
             readln(Grading,nints);
             readln(Grading,col);
             readln(Grading,choice);
             cellstring := format('Distribution used index = %2d',[choice]);
             OutputFrm.RichEdit.Lines.Add(cellstring);
//             DistUseGroup.ItemIndex := choice;
             readln(Grading,choice);
             cellstring := format('Category index = %2d',[choice]);
             OutputFrm.RichEdit.Lines.Add(cellstring);
//             CategoriesGroup.ItemIndex := choice;
             readln(Grading,choice);
             OutputFrm.RichEdit.Lines.Add('Top Score  Low Score');
             if choice = 0 then
             begin
                  for i := 0 to 4 do
                  begin
                       readln(Grading,cellstring);
                       outline := format('%10s ',[cellstring]);
//                       TopScoreGrid.Cells[0,i] := cellstring;
                       readln(Grading,cellstring);
                       valstr := format('%10s',[cellstring]);
                       outline := outline + valstr;
//                       LowScoreGrid.Cells[0,i] := cellstring;
                       OutputFrm.RichEdit.Lines.Add(outline);
                  end;
             end else
             begin
                  for i := 0 to 11 do
                  begin
                       readln(Grading,cellstring);
                       outline := format('%10s',[cellstring]);
//                       TopScoreGrid.Cells[0,i] := cellstring;
                       readln(Grading,cellstring);
                       valstr := format('%10s',[cellstring]);
                       outline := outline + valstr;
//                       LowScoreGrid.Cells[0,i] := cellstring;
                       OutputFrm.RichEdit.Lines.Add(outline);
                  end;
             end;
             OutputFrm.RichEdit.Lines.Add('');
             OutputFrm.RichEdit.Lines.Add('Assigned Grid');
             for i := 0 to nints-1 do
             begin
                 readln(Grading,cellstring);
                 outline := cellstring;
                 OutputFrm.RichEdit.Lines.Add(outline);
//                 AssignedGrid.Cells[0,i] := cellstring;
             end;
//             readln(Grading,cellstring);
             OutputFrm.RichEdit.Lines.Add('Score      Frequency');
             for i := 0 to nints - 1 do
             begin
                  outline := '';
                  for j := 0 to 1 do
                  begin
                       readln(Grading,cellstring);
                       valstr := format('%10s ',[cellstring]);
                       outline := outline + valstr;
//                       ScoresGrid.Cells[j,i] := cellstring;
                  end;
                  OutputFrm.RichEdit.Lines.Add(outline);
             end;
        end;
        OutputFrm.ShowModal;
        CloseFile(Grading);
end;

procedure TGradingFrm.LowScoreGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
VAR
   i, row, freq, intervals: integer;
   lowval, hival, score1 : double;

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
     if row < ncats-1 then
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
        FName : string;
        Grading : textfile;
        i, j : integer;
begin
        SaveDialog1.DefaultExt := '.GRD';
        SaveDialog1.Filter := 'ALL (*.*)|*.*|Test Grading (*.GRD)|*.GRD';
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
             if CategoriesGroup.ItemIndex = 0 then
             begin
                  for i := 0 to 4 do
                  begin
                       writeln(Grading,TopScoreGrid.Cells[0,i]);
                       writeln(Grading,LowScoreGrid.Cells[0,i]);
                  end;
             end else
             begin
                  for i := 0 to 11 do
                  begin
                       writeln(Grading,TopScoreGrid.Cells[0,i]);
                       writeln(Grading,LowScoreGrid.Cells[0,i]);
                  end;
             end;
             for i := 0 to AssignedGrid.RowCount-1 do
                 writeln(Grading,AssignedGrid.Cells[0,i]);
             for i := 0 to ScoresGrid.RowCount - 1 do
             begin
                  for j := 0 to 1 do writeln(Grading,ScoresGrid.Cells[j,i]);
             end;
        end;
        CloseFile(Grading);
end;


procedure TGradingFrm.CategoriesGroupClick(Sender: TObject);
VAR
   btn : integer;
begin
     btn := CategoriesGroup.ItemIndex;
     if btn = 0 then ncats := 5 else ncats := 12;
     if btn = 0 then Grades.RowCount := 5 else Grades.RowCount := 12;
     if btn = 0 then TopScoreGrid.RowCount := 5 else TopScoreGrid.RowCount := 12;
     if btn = 0 then LowScoreGrid.RowCount := 5 else LowScoreGrid.RowCount := 12;
     if btn = 0 then AssignedGrid.RowCount := 5 else AssignedGrid.RowCount := 12;
     if btn = 0 then
     begin
          Grades.Cells[0,0] := 'A';
          Grades.Cells[0,1] := 'B';
          Grades.Cells[0,2] := 'C';
          Grades.Cells[0,3] := 'D';
          Grades.Cells[0,4] := 'F';
     end;
     if btn = 1 then
     begin
          Grades.Cells[0,0] := 'A';
          Grades.Cells[0,1] := 'A-';
          Grades.Cells[0,2] := 'B+';
          Grades.Cells[0,3] := 'B';
          Grades.Cells[0,4] := 'B-';
          Grades.Cells[0,5] := 'C+';
          Grades.Cells[0,6] := 'C';
          Grades.Cells[0,7] := 'C-';
          Grades.Cells[0,8] := 'D+';
          Grades.Cells[0,9] := 'D';
          Grades.Cells[0,10] := 'D-';
          Grades.Cells[0,11] := 'F';
     end;
end;

procedure TGradingFrm.ComputeBtnClick(Sender: TObject);
VAR
   i, j: integer;
   X, Y, low, hi : double;
begin
  // build AssignedGrid of grades for each Score in the ScoresGrid
  for i := 0 to ncats - 1 do
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
       Y := StrToFloat(gradebookfrm.grid.Cells[col,i]);
       for j := 0 to nints - 1 do // Grade of values in the ScoreGrid
       begin
            X := StrToFloat(ScoresGrid.Cells[0,j]);
            if X = Y then gradebookfrm.Grid.Cells[col+4,i] := gradesGrid.Cells[0,j];
       end;
  end;
end;

initialization
  {$I gradingunit.lrs}

end.

