unit GradeBookUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Menus, StdCtrls, EditBtn, FileCtrl, ComCtrls, Grids, ExtCtrls,
  Globals, OutputUnit, GraphLib, GradingUnit;

  Type
      TestRcd = Record
      TestNo : integer;
      NoItems : integer;
      Mean, Variance, StdDev : double;
      KR21Rel : double;
      Weight : double;
  end;

  Type DblDyneMat  = array of array of double;
  Type DblDyneVec = array of double;

type

  { TGradebookFrm }

  TGradebookFrm = class(TForm)
    ExitBtn: TButton;
    Label3: TLabel;
    ExitMnu: TMenuItem;
    CompScrMnu: TMenuItem;
    ClassRptMnu: TMenuItem;
    EditMnu: TMenuItem;
    DelRowMnu: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    StudRptsMnu: TMenuItem;
    TestAnalMnu: TMenuItem;
    SaveGBMnu: TMenuItem;
    OpenGBMnu: TMenuItem;
    NewGBMnu: TMenuItem;
    RadioGroup1: TRadioGroup;
    ResetBtn: TButton;
    DirectoryEdit1: TDirectoryEdit;
    FileListBox1: TFileListBox;
    FileNameEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    MainMenu1: TMainMenu;
    FilesMenu: TMenuItem;
    ComputeMenu: TMenuItem;
    HelpMenu: TMenuItem;
    ReportsMenu: TMenuItem;
    Grid: TStringGrid;
    procedure ClassRptMnuClick(Sender: TObject);
    procedure CompScrMnuClick(Sender: TObject);
    procedure DelRowMnuClick(Sender: TObject);
    procedure DirectoryEdit1Change(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure ExitMnuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridExit(Sender: TObject);
    procedure NewGBMnuClick(Sender: TObject);
    procedure OpenGBMnuClick(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure SaveGBMnuClick(Sender: TObject);
    procedure StudRptsMnuClick(Sender: TObject);
    procedure TestAnalMnuClick(Sender: TObject);

  private
    { private declarations }
   TestNo, GridCol, GridRow, NoTests : integer;

  public
    { public declarations }
    nints, tno, NoStudents, nitems : integer;
    freq : array[0..50] of double;
    scores : array[0..50] of double;
    sortedraw : DblDyneVec;
    pcntiles : DblDyneMat;
    tscores : DblDyneVec;
    zscores : DblDyneVec;
    pcntilerank : array[0..50] of double;

  end; 

var
  GradebookFrm: TGradebookFrm;

implementation

{ TGradebookFrm }

procedure TGradebookFrm.ExitBtnClick(Sender: TObject);
var response : string ;
begin
     response := InputBox('SAVE','Save gradebook (Y or N)?','N');
     if response = 'Y' then SaveGBMnuClick(Self);
     Close;
end;

procedure TGradebookFrm.ExitMnuClick(Sender: TObject);
var response : string ;
begin
     response := InputBox('SAVE','Save gradebook (Y or N)?','N');
     if response = 'Y' then SaveGBMnuClick(Self);
     Close;
end;

procedure TGradebookFrm.DirectoryEdit1Change(Sender: TObject);
begin
  //DirectoryEdit1.Directory := GetCurrentDir;
  FileListBox1.Directory := DirectoryEdit1.Directory;
end;

procedure TGradebookFrm.DelRowMnuClick(Sender: TObject);
VAR
   row, i, j : integer;
begin
   row := Grid.Row;
   for i := 0 to 57 do Grid.Cells[i,row] := '';
   if Grid.Cells[0,row+1] <> '' then
   begin
        for i := row + 1 to NoStudents do
        begin
             for j := 0 to 57 do Grid.Cells[j,i-1] := Grid.Cells[j,i];
        end;
        for j := 0 to 57 do Grid.Cells[j,NoStudents] := '';
        NoStudents := NoStudents - 1;
   end;
end;

procedure TGradebookFrm.CompScrMnuClick(Sender: TObject);
var
   i, j, k, NoVars, count, col : integer;
   DataMat : array[1..50,1..10] of double;
   Rmat, RelMat : array[1..10,1..10] of double;
   Weights, Reliabilities, VectProd, means, variances, stddevs : array[1..10] of double;
   X, Y, CompRel, numerator, denominator: double;
   outline, cellstring : string;
   title : string;
   RowLabels : array[1..10] of string;
   response : string;
   nomiss : integer;
   found : boolean;

begin
    OutputFrm.RichEdit.Clear;
    NoVars := 0;
    // get number of tests
    for i := 1 to 10 do
    begin
         tno := i * 5 - 5;
         col := tno + 3; // column of raw scores for test number
         found := false;
         for j := 1 to NoStudents do
         begin
              if Grid.Cells[col,j] <> '' then found := true;
         end;
         if found then
         begin
              NoVars := NoVars + 1;
              RowLabels[NoVars] := 'Test ' + IntToStr(NoVars);
         end;
    end;
    count := NoStudents;

    // get data
    for i := 1 to NoVars do
    begin
         nomiss := 0;
         tno := i * 5 - 5;
         col := tno + 3; // column of raw scores for test number
         for j := 1 to NoStudents do
         begin
              if Grid.Cells[col,j] <> '' then
                    DataMat[j,i] := StrToFloat(Grid.Cells[col,j])
                  else nomiss := nomiss + 1;
         end;
         if nomiss >= NoStudents then NoVars := NoVars - 1;
    end;

    OutputFrm.RichEdit.Lines.Add('Composite Test Reliability');
    OutputFrm.RichEdit.Lines.Add('');
    outline := 'File Analyzed: ' + FileNameEdit.Text;
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');

    // get correlation matrix
    for i := 1 to NoVars do
    begin
         means[i] := 0.0;
         variances[i] := 0.0;
        for j := 1 to NoVars do Rmat[i,j] := 0.0;
    end;

    for i := 1 to NoStudents do // get cross-products matrix
    begin
         for j := 1 to NoVars do
         begin
              X := DataMat[i,j];
              means[j] := means[j] + X;
              variances[j] := variances[j] + (X * X);
              for k := 1 to NoVars do
              begin
                   Y := DataMat[i,k];
                   Rmat[j,k] := Rmat[j,k] + (X * Y);
              end;
         end;
    end;

    for j := 1 to NoVars do // calculate variances and standard dev.s
    begin
         variances[j] := variances[j] - (means[j] * means[j] / NoStudents);
         variances[j] := variances[j] / (NoStudents - 1.0);
         if variances[j] <= 0.0 then
         begin
              ShowMessage('No variance found in test '+ IntToStr(j));
              exit;
         end
         else stddevs[j] := sqrt(variances[j]);
    end;

    for j := 1 to NoVars do // get variance-covariance matrix
    begin
         for k := 1 to NoVars do
         begin
              Rmat[j,k] := Rmat[j,k] - (means[j] * means[k] / NoStudents);
              Rmat[j,k] := Rmat[j,k] / (NoStudents - 1.0);
         end;
    end;

    for j := 1 to NoVars do // get correlation matrix
        for k := 1 to NoVars do Rmat[j,k] := Rmat[j,k] / (stddevs[j] * stddevs[k]);

    for j := 1 to NoVars do means[j] := means[j] / NoStudents;

    OutputFrm.RichEdit.Lines.Add('');
    title := 'Correlations Among Tests';
    OutputFrm.RichEdit.Lines.Add(title);
    outline := 'Test No.';
    for j := 1 to NoVars do
         outline := outline + format('%7s',[rowlabels[j]]);
    OutputFrm.RichEdit.Lines.Add(outline);
    for j := 1 to NoVars do
    begin
         outline := format('%8s',[rowlabels[j]]);
         for k := 1 to NoVars do
         begin
              outline := outline + format('%7.3f',[Rmat[j,k]]);
         end;
         OutputFrm.RichEdit.Lines.Add(outline);
    end;
    outline := 'Means   ';
    for j := 1 to NoVars do outline := outline + format('%7.2f',[means[j]]);
    OutputFrm.RichEdit.Lines.Add(outline);
    outline := 'Std.Devs';
    for j := 1 to NoVars do outline := outline + format('%7.2f',[stddevs[j]]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');

    for i := 1 to NoVars do
        for j := 1 to NoVars do
            RelMat[i,j] := Rmat[i,j];
    for i := 1 to NoVars do
    begin
        response := InputBox('No. of items in Test ' + IntToStr(i),'Number:','0');
        nitems := StrToInt(response);
        Reliabilities[i] := (nitems / (nitems-1) *
       (1.0 - (means[i] * (nitems - means[i]))/(nitems * variances[i])));
        RelMat[i,i] := Reliabilities[i];
        cellstring := 'Weight for Test ' + IntToStr(i);
        response := InputBox(cellstring,'Weight:','1');
        Weights[i] := StrToFloat(response);
    end;
    // get numerator and denominator of composite reliability
    for i := 1 to NoVars do VectProd[i] := 0.0;
    numerator := 0.0;
    denominator := 0.0;
    for i := 1 to NoVars do
        for j := 1 to NoVars do
            VectProd[i] := VectProd[i] + (Weights[i] * RelMat[j,i]);
    for i := 1 to NoVars do numerator := numerator + (VectProd[i] * Weights[i]);

    for i := 1 to NoVars do VectProd[i] := 0.0;
    for i := 1 to NoVars do
        for j := 1 to NoVars do
            VectProd[i] := VectProd[i] + (Weights[i] * Rmat[j,i]);
    for i := 1 to NoVars do denominator := denominator +
        (VectProd[i] * Weights[i]);
    CompRel := numerator / denominator;
    OutputFrm.RichEdit.Lines.Add('');
    outline := 'Test No.  Weight Reliability';
    OutputFrm.RichEdit.Lines.Add(outline);
    for i := 1 to NoVars do
    begin
         outline := format('   %3d  %6.2f   %6.2f',[i,Weights[i],Reliabilities[i]]);
         OutputFrm.RichEdit.Lines.Add(outline);
    end;
    outline := format('Composite reliability = %6.3f',[CompRel]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.ShowModal;
    response := InputBox('COMPOSITE','Save the composit score?','Yes');
    if response = 'Yes' then
    begin
        col := 53;
        for i := 1 to NoStudents do
        begin
             X := 0.0;
             for j := 1 to NoVars do
                  X := X + (DataMat[i,j] * Weights[j]);
             Grid.Cells[col,i] := FloatToStr(X);
        end;
    end;
end;

procedure TGradebookFrm.ClassRptMnuClick(Sender: TObject);
VAR
   i, j, pos : integer;
   outline : string;
   valstr : string;
   raw, z, t, p : double;

begin
     // confirm no. of students
     NoStudents := 0;
     for i := 1 to 40 do
     begin
             if Grid.Cells[0,i] <> '' then NoStudents := NoStudents + 1;
     end;
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Class Report');
     for i := 1 to NoStudents do
     begin
          outline := Grid.Cells[1,i] + ' ';
          if Grid.Cells[2,i] <> '' then outline := outline + Grid.Cells[2,i] + ' ';
          outline := outline + Grid.Cells[0,i];
          outline := 'Report for: ' + outline;
          OutputFrm.RichEdit.Lines.Add(outline);
          OutputFrm.RichEdit.Lines.Add('');
          OutputFrm.RichEdit.Lines.Add('TEST      RAW       Z         T          PERCENTILE GRADE');
          OutputFrm.RichEdit.Lines.Add(' NO.      SCORE     SCORE     SCORE      RANK');
          for j := 0 to 10 do
          begin
               pos := j * 5 + 3;
               valstr := format('%3d   ',[j+1]);
               outline := valstr;
               if Grid.Cells[pos,i] <> '' then
               begin
                    raw := StrToFloat(Grid.Cells[pos,i]);
                    z := StrToFloat(Grid.Cells[pos+1,i]);
                    t := strToFloat(Grid.Cells[pos+2,i]);
                    p := StrToFloat(Grid.Cells[pos+3,i]);
                    valstr := format('%10.0f',[raw]);
                    outline := outline + valstr;
                    valstr := format('%9.3f  %9.3f  %9.3f   %3s',[z, t, p, Grid.Cells[pos+4,i]]);
                    outline := outline + valstr;
                    OutputFrm.RichEdit.Lines.Add(outline);
               end;
          end;
          OutputFrm.RichEdit.Lines.Add('');
          OutputFrm.RichEdit.Lines.Add('');
     end;
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
end;

procedure TGradebookFrm.FormCreate(Sender: TObject);
begin
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);

  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);

  DirectoryEdit1.Directory := GetCurrentDir;
  FileListBox1.Directory := DirectoryEdit1.Directory;
  FileNameEdit.Text := '';
end;

procedure TGradebookFrm.FormShow(Sender: TObject);
begin
  Grid.ColWidths[0] := 100;
  Grid.Cells[0,0] := 'Last Name';
  Grid.ColWidths[1] := 100;
  Grid.Cells[1,0] := 'First Name';
  Grid.ColWidths[2] := 40;
  Grid.Cells[2,0] := 'M.I.';
  Grid.ColWidths[3] := 60;
  Grid.Cells[3,0] := 'Test 1 Raw';
  Grid.ColWidths[4] := 50;
  Grid.Cells[4,0] := 'Test 1 z';
  Grid.ColWidths[5] := 50;
  Grid.Cells[5,0] := 'Test 1 T';
  Grid.ColWidths[6] := 55;
  Grid.Cells[6,0] := '%ile Rank';
  Grid.ColWidths[7] := 50;
  Grid.Cells[7,0] := 'Grade 1';
  Grid.ColWidths[8] := 60;
  Grid.Cells[8,0] := 'Test 2 Raw';
  Grid.ColWidths[9] := 50;
  Grid.Cells[9,0] := 'Test 2 z';
  Grid.ColWidths[10] := 50;
  Grid.Cells[10,0] := 'Test 2 T';
  Grid.ColWidths[11] := 55;
  Grid.Cells[11,0] := '%ile Rank';
  Grid.ColWidths[12] := 50;
  Grid.Cells[12,0] := 'Grade 2';
  Grid.ColWidths[13] := 60;
  Grid.Cells[13,0] := 'Test 3 Raw';
  Grid.ColWidths[14] := 50;
  Grid.Cells[14,0] := 'Test 3 z';
  Grid.ColWidths[15] := 50;
  Grid.Cells[15,0] := 'Test 3 T';
  Grid.ColWidths[16] := 55;
  Grid.Cells[16,0] := '%ile Rank';
  Grid.ColWidths[17] := 50;
  Grid.Cells[17,0] := 'Grade 3';
  Grid.ColWidths[18] := 60;
  Grid.Cells[18,0] := 'Test 4 Raw';
  Grid.ColWidths[19] := 50;
  Grid.Cells[19,0] := 'Test 4 z';
  Grid.ColWidths[20] := 50;
  Grid.Cells[20,0] := 'Test 4 T';
  Grid.ColWidths[21] := 55;
  Grid.Cells[21,0] := '%ile Rank';
  Grid.ColWidths[22] := 50;
  Grid.Cells[22,0] := 'Grade 4';
  Grid.ColWidths[23] := 60;
  Grid.Cells[23,0] := 'Test 5 Raw';
  Grid.ColWidths[24] := 50;
  Grid.Cells[24,0] := 'Test 5 z';
  Grid.ColWidths[25] := 50;
  Grid.Cells[25,0] := 'Test 5 T';
  Grid.ColWidths[26] := 55;
  Grid.Cells[26,0] := '%ile Rank';
  Grid.ColWidths[27] := 50;
  Grid.Cells[27,0] := 'Grade 5';
  Grid.ColWidths[28] := 60;
  Grid.Cells[28,0] := 'Test 6 Raw';
  Grid.ColWidths[29] := 50;
  Grid.Cells[29,0] := 'Test 6 z';
  Grid.ColWidths[30] := 50;
  Grid.Cells[30,0] := 'Test 6 T';
  Grid.ColWidths[31] := 55;
  Grid.Cells[31,0] := '%ile Rank';
  Grid.ColWidths[32] := 50;
  Grid.Cells[32,0] := 'Grade 6';
  Grid.ColWidths[33] := 60;
  Grid.Cells[33,0] := 'Test 7 Raw';
  Grid.ColWidths[34] := 50;
  Grid.Cells[34,0] := 'Test 7 z';
  Grid.ColWidths[35] := 50;
  Grid.Cells[35,0] := 'Test 7 T';
  Grid.ColWidths[36] := 55;
  Grid.Cells[36,0] := '%ile Rank';
  Grid.ColWidths[37] := 50;
  Grid.Cells[37,0] := 'Grade 7';
  Grid.ColWidths[38] := 60;
  Grid.Cells[38,0] := 'Test 8 Raw';
  Grid.ColWidths[39] := 50;
  Grid.Cells[39,0] := 'Test 8 z';
  Grid.ColWidths[40] := 50;
  Grid.Cells[40,0] := 'Test 8 T';
  Grid.ColWidths[41] := 55;
  Grid.Cells[41,0] := '%ile Rank';
  Grid.ColWidths[42] := 50;
  Grid.Cells[42,0] := 'Grade 8';
  Grid.ColWidths[43] := 60;
  Grid.Cells[43,0] := 'Test 9 Raw';
  Grid.ColWidths[44] := 50;
  Grid.Cells[44,0] := 'Test 9 z';
  Grid.ColWidths[45] := 50;
  Grid.Cells[45,0] := 'Test 9 T';
  Grid.ColWidths[46] := 55;
  Grid.Cells[46,0] := '%ile Rank';
  Grid.ColWidths[47] := 50;
  Grid.Cells[47,0] := 'Grade 9';
  Grid.ColWidths[48] := 60;
  Grid.Cells[48,0] := 'Test 10 Raw';
  Grid.ColWidths[49] := 50;
  Grid.Cells[49,0] := 'Test 10 z';
  Grid.ColWidths[50] := 50;
  Grid.Cells[50,0] := 'Test 10 T';
  Grid.ColWidths[51] := 55;
  Grid.Cells[51,0] := '%ile Rank';
  Grid.ColWidths[52] := 50;
  Grid.Cells[52,0] := 'Grade 10';
  Grid.ColWidths[53] := 60;
  Grid.Cells[53,0] := 'Total Raw';
  Grid.ColWidths[54] := 50;
  Grid.Cells[54,0] := 'Total z';
  Grid.ColWidths[55] := 50;
  Grid.Cells[55,0] := 'Total T';
  Grid.ColWidths[56] := 55;
  Grid.Cells[56,0] := '%ile Rank';
  Grid.ColWidths[57] := 60;
  Grid.Cells[57,0] := 'Final Grade';
end;

procedure TGradebookFrm.GridExit(Sender: TObject);
begin
  GridCol := Grid.Col;
  GridRow := Grid.Row;
  if (Grid.Cells[GridCol,GridRow] = ' ') then exit else
  begin
       NoStudents := GridRow;
       if GridCol > 3 then
       begin
            GridCol := GridCol - 3;
            if (GridCol >= 1) and (GridCol <= 5) then
            begin
                 TestNo := 1;
                 exit;
            end;
            if (GridCol >= 6) and (GridCol <= 10) then
            begin
                 TestNo := 2;
                 exit;
            end;
            if (GridCol >= 11) and (GridCol <= 15) then
            begin
                 TestNo := 3;
                 exit;
            end;
            if (GridCol >= 16) and (GridCol <= 20) then
            begin
                 TestNo := 4;
                 exit;
            end;
            if (GridCol >= 21) and (GridCol <= 25) then
            begin
                 TestNo := 5;
                 exit;
            end;
            if (GridCol >= 26) and (GridCol <= 30) then
            begin
                 TestNo := 6;
                 exit;
            end;
            if (GridCol >= 31) and (GridCol <= 35) then
            begin
                 TestNo := 7;
                 exit;
            end;
            if (GridCol >= 36) and (GridCol <= 40) then
            begin
                 TestNo := 8;
                 exit;
            end;
            if (GridCol >= 41) and (GridCol <= 45) then
            begin
                 TestNo := 9;
                 exit;
            end;
            if (GridCol >= 46) and (GridCol <= 50) then
            begin
                 TestNo := 10;
                 exit;
            end;
            if (GridCol >= 51) and (GridCol <= 55) then
            begin
                 TestNo := 11;
                 exit;
            end;
       end;
  end;
  if TestNo > NoTests then NoTests := TestNo;
end;

procedure TGradebookFrm.NewGBMnuClick(Sender: TObject);
VAR
   i, j : integer;
begin
     for i := 1 to 40 do
     begin
          for j := 0 to 57 do Grid.Cells[j,i] := '';
     end;
     FileNameEdit.text := '';
end;

procedure TGradebookFrm.OpenGBMnuClick(Sender: TObject);
var
        FName : string;
        Book : textfile;
        i, j: integer;
        cellstr : string;
begin
        OpenDialog1.DefaultExt := '.GBK';
        OpenDialog1.Filter := 'ALL (*.*)|*.*|Grade Book (*.GBK)|*.GBK';
        OpenDialog1.FilterIndex := 2;
        if OpenDialog1.Execute then
        begin
             FName := OpenDialog1.FileName;
             FileNameEdit.text := FName;
             AssignFile(Book,FName);
             Reset(Book);
             readln(Book,NoStudents);
             for i := 1 to 40 do
             begin
                  for j := 0 to 57 do
                  begin
                       readln(Book,cellstr);
                       Grid.Cells[j,i] := cellstr;
                  end;
             end;
             CloseFile(Book);
        end;
end;

procedure TGradebookFrm.RadioGroup1Click(Sender: TObject);
begin
  if RadioGroup1.ItemIndex = 1 then Grid.FixedCols := 0 else Grid.FixedCols := 3;
end;

procedure TGradebookFrm.SaveGBMnuClick(Sender: TObject);
var
        FName : string;
        Book : textfile;
        i, j: integer;
        cellstr : string;
begin
        // confirm no. of students
        NoStudents := 0;
        for i := 1 to 40 do
        begin
             if Grid.Cells[0,i] <> '' then NoStudents := NoStudents + 1;
        end;
        SaveDialog1.DefaultExt := '.GBK';
        SaveDialog1.Filter := 'ALL (*.*)|*.*|Grade Book (*.GBK)|*.GBK';
        SaveDialog1.FilterIndex := 2;
        if SaveDialog1.Execute then
        begin
//             GetNoRecords;
             FName := SaveDialog1.FileName;
             AssignFile(Book,FName);
             Rewrite(Book);
             writeln(Book,NoStudents);
             for i := 1 to 40 do
             begin
                  for j := 0 to 57 do
                  begin
                       cellstr := Grid.Cells[j,i];
                       writeln(Book,cellstr);
                  end;
             end;
             CloseFile(Book);
        end;
        FileNameEdit.text := '';
end;

procedure TGradebookFrm.StudRptsMnuClick(Sender: TObject);
VAR
   i, j, pos : integer;
   outline : string;
   valstr : string;
   raw, z, t, p : double;
begin
     // confirm no. of students
     NoStudents := 0;
     for i := 1 to 40 do
     begin
             if Grid.Cells[0,i] <> '' then NoStudents := NoStudents + 1;
     end;
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Individual Student Report');
     for i := 1 to NoStudents do
     begin
          outline := Grid.Cells[1,i] + ' ';
          if Grid.Cells[2,i] <> '' then outline := outline + Grid.Cells[2,i] + ' ';
          outline := outline + Grid.Cells[0,i];
          outline := 'Report for: ' + outline;
          OutputFrm.RichEdit.Lines.Add(outline);
          OutputFrm.RichEdit.Lines.Add('');
          OutputFrm.RichEdit.Lines.Add('TEST      RAW       Z         T          PERCENTILE GRADE');
          OutputFrm.RichEdit.Lines.Add(' NO.      SCORE     SCORE     SCORE      RANK');
          for j := 0 to 10 do
          begin
               pos := j * 5 + 3;
               valstr := format('%3d   ',[j+1]);
               outline := valstr;
               if Grid.Cells[pos,i] <> '' then
               begin
                    raw := StrToFloat(Grid.Cells[pos,i]);
                    z := StrToFloat(Grid.Cells[pos+1,i]);
                    t := strToFloat(Grid.Cells[pos+2,i]);
                    p := StrToFloat(Grid.Cells[pos+3,i]);
                    valstr := format('%10.0f',[raw]);
                    outline := outline + valstr;
                    valstr := format('%9.3f  %9.3f  %9.3f   %3s',[z, t, p, Grid.Cells[pos+4,i]]);
                    outline := outline + valstr;
                    OutputFrm.RichEdit.Lines.Add(outline);
               end;
          end;
          OutputFrm.ShowModal;
          OutputFrm.RichEdit.Clear;
     end;
end;

procedure TGradebookFrm.TestAnalMnuClick(Sender: TObject);
var
   i, j, k, col : integer;
   X, mean, variance, stddev, Xtemp : double;
   z, t: double;
   response : string;
   cumfreq : array[0..50] of double;
   cumfreqmid : array[0..50] of double;
   ncnt : integer;
   outline : string;
   KR21 : double;
   minf, maxf : double;

begin
     response := InputBox('Which test (number)','TEST:','0');
     if StrToInt(response) = 0 then
     begin
          ShowMessage('You must select a test no. between 1 and 11');
          exit;
     end;
     tno := StrToInt(response);
     tno := tno * 5 - 5;
     col := tno + 3; // column of raw scores for test number tno
     // get no. of students
     NoStudents := 0;
     for i := 1 to 40 do
     begin
          if Grid.Cells[col,i] = '' then continue else NoStudents := NoStudents + 1;
     end;
     SetLength(sortedraw,41);
     SetLength(pcntiles,41,41);
     SetLength(tscores,41);
     SetLength(zscores,41);
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Test Analysis Results');
     mean := 0.0;
     variance := 0.0;
     for i := 1 to NoStudents do
     begin
          X := StrToFloat(Grid.Cells[col,i]);
          sortedraw[i-1] := X;
          mean := mean + X;
          variance := variance + (X * X);
     end;
     variance := variance - (mean * mean / NoStudents);
     Variance := Variance / (NoStudents - 1.0);
     stddev := sqrt(variance);
     mean := mean / NoStudents;
     outline := format('Mean = %8.2f, Variance = %8.3f, Std.Dev. = %8.3f',
        [mean,variance,stddev]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');
     response := InputBox('No. of Test Items or maximum score possible','Number:','0');
     nitems := StrToInt(response);
     if nitems = 0 then
     begin
          ShowMessage('Enter the maximum score or no. of items!');
          exit;
     end;
     KR21 := (nitems / (nitems-1) *
       (1.0 - (mean * (nitems - mean))/(nitems * variance)));
     outline := format('Kuder-Richardson Formula 21 Reliability Estimate = %6.4f',[KR21]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');

     // get z scores and T scores
     for i := 1 to NoStudents do
     begin
          z := (sortedraw[i-1] - mean) / stddev;
          outline := format('%5.3f',[z]);
          Grid.Cells[col+1,i] := outline;
          t := z * 10 + 50;
          outline := format('%5.1f',[t]);
          Grid.Cells[col+2,i] := outline;
     end;
     // sort raw scores in ascending order
     for i := 1 to NoStudents-1 do
     begin
          for j := i + 1 to NoStudents do
          begin
               if sortedraw[i-1] > sortedraw[j-1] then // switch
               begin
                    Xtemp := sortedraw[i-1];
                    sortedraw[i-1] := sortedraw[j-1];
                    sortedraw[j-1] := Xtemp;
               end;
          end;
     end;
     // get percentile rank
    ncnt := NoStudents;
    nints := 1;
    for i := 1 to ncnt do freq[i-1] := 0;
    X := sortedraw[0];
    Scores[0] := X;
    for i := 1 to ncnt do
    begin
        if (X = sortedraw[i-1])then freq[nints-1] := freq[nints-1] + 1
        else // new value
        begin
            nints := nints + 1;
            freq[nints-1] := freq[nints-1] + 1;
            X := sortedraw[i-1];
            Scores[nints-1] := X;
        end;
    end;
    // get min and max frequencies
    minf := NoStudents;
    maxf := 0;
    for i := 0 to nints - 1 do
    begin
         if freq[i] > maxf then maxf := freq[i];
         if freq[i] < minf then minf := freq[i];
    end;
    // now get cumulative frequencies
    cumfreq[0] := freq[0];
    for i := 1 to nints-1 do cumfreq[i] := freq[i] + cumfreq[i-1];

    // get cumulative frequences to midpoints and percentile ranks
    cumfreqmid[0] := freq[0] / 2.0;
    pcntilerank[0] := (cumfreq[0] / 2.0) / ncnt;
    for i := 1 to nints-1 do
    begin
        cumfreqmid[i] := (freq[i] / 2.0) + cumfreq[i-1];
        pcntilerank[i] := cumfreqmid[i] / ncnt;
    end;

    OutputFrm.RichEdit.Lines.Add('PERCENTILE RANKS');
    OutputFrm.RichEdit.Lines.Add('Score Value   Frequency   Cum.Freq. Percentile Rank');
    OutputFrm.RichEdit.Lines.Add('___________   __________  __________ ______________');
    for i := 1 to nints do
    begin
        outline := format('  %8.3f     %6.2f     %6.2f      %6.2f',
             [Scores[i-1], freq[i-1],cumfreq[i-1],pcntilerank[i-1]*100.0]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;
    OutputFrm.RichEdit.Lines.Add('');

    // get grades
    if GradingFrm = nil then
      Application.CreateForm(TGradingFrm, GradingFrm);
    GradingFrm.ShowModal;

     // Now place results in testgrid
     for i := 1 to ncnt do
     begin
          X := StrToFloat(Grid.Cells[col,i]);
          for j := 0 to nints do
          begin
               if X = scores[j] then
                   Grid.Cells[col+3,i] := format('%5.2f',[pcntilerank[j]*100.0]);
          end;
     end;
     OutputFrm.ShowModal;

     // graph raw scores
     if maxf = minf then exit;
     GraphFrm.Heading := 'Frequency of Raw Scores';
     GraphFrm.XTitle := 'Category';
     GraphFrm.YTitle := 'Frequency';
     SetLength(GraphFrm.Ypoints,1,nints);
     SetLength(GraphFrm.Xpoints,1,nints);
     for k := 1 to nints do
     begin
//          GraphFrm.PointLabels[k-1] := GradingSpecs[p].GridData[k,1];
          GraphFrm.Ypoints[0,k-1] := freq[k];
          GraphFrm.Xpoints[0,k-1] := Scores[k];
//          GraphFrm.Ypoints[0,k-1] := freq[k];
//          GraphFrm.Xpoints[0,k-1] := k;
     end;
     // enter parameters for 2 dimension bars in graph package
     GraphFrm.barwideprop := 0.5;
     GraphFrm.nosets := 1;
     GraphFrm.miny := minf;
     GraphFrm.maxy := maxf;
     GraphFrm.nbars := nints-1;
     GraphFrm.GraphType := 2; // 3d bars
     GraphFrm.AutoScaled := false; // use min and max
     GraphFrm.ShowLeftWall := true;
     GraphFrm.ShowRightWall := true;
     GraphFrm.ShowBottomWall := true;
     GraphFrm.ShowBackWall := true;
     GraphFrm.BackColor := clYellow;
     GraphFrm.WallColor := clBlack;
     GraphFrm.PtLabels := true;
     GraphFrm.ShowModal;

     GraphFrm.Ypoints := nil;
     GraphFrm.Xpoints := nil;

// cleanup
     sortedraw := nil;
//     grades := nil;
     zscores := nil;
     tscores := nil;
     pcntiles := nil;
end;


initialization
  {$I gradebookunit.lrs}

end.

