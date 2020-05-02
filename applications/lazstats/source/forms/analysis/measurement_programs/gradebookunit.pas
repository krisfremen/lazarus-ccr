// File for testing: testgradebook.gbk
//
// TODO: Fix crash "Compute" > "Calc Composite Score"


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
    NameProtectionChk: TCheckBox;
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
    procedure FileListBox1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridExit(Sender: TObject);
    procedure NameProtectionChkChange(Sender: TObject);
    procedure NewGBMnuClick(Sender: TObject);
    procedure OpenGBMnuClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure SaveGBMnuClick(Sender: TObject);
    procedure StudRptsMnuClick(Sender: TObject);
    procedure TestAnalMnuClick(Sender: TObject);

  private
    { private declarations }
    TestNo, GridCol, GridRow, NoTests : integer;
    function HasData: Boolean;
    procedure OpenGradeBook(const AFileName: String);

  public
    { public declarations }
    nints, tno, NoStudents, nitems: integer;
    freq: array[0..50] of double;
    scores: array[0..50] of double;
    sortedraw: DblDyneVec;
    pcntiles: DblDyneMat;
    tscores: DblDyneVec;
    zscores: DblDyneVec;
    pcntilerank: array[0..50] of double;

  end; 

var
  GradebookFrm: TGradebookFrm;

implementation

uses
  Math,
  Utils;

{ TGradebookFrm }

procedure TGradebookFrm.ExitBtnClick(Sender: TObject);
begin
  if MessageDlg('Save gradebook?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    SaveGBMnuClick(Self);
end;

procedure TGradebookFrm.ExitMnuClick(Sender: TObject);
begin
  if MessageDlg('Save gradebook?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    SaveGBMnuClick(Self)
end;

procedure TGradebookFrm.FileListBox1Click(Sender: TObject);
begin
  OpenGradeBook(FileListbox1.FileName);
end;

procedure TGradebookFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ExitBtn.Width]);
  ResetBtn.Width := w;
  ExitBtn.Width := w;
end;

procedure TGradebookFrm.DirectoryEdit1Change(Sender: TObject);
begin
  //DirectoryEdit1.Directory := GetCurrentDir;
  FileListBox1.Directory := DirectoryEdit1.Directory;
end;

procedure TGradebookFrm.DelRowMnuClick(Sender: TObject);
var
  row, i, j: integer;
begin
  row := Grid.Row;
  for i := 0 to 57 do
    Grid.Cells[i, row] := '';
  if Grid.Cells[0, row+1] <> '' then
   begin
     for i := row + 1 to NoStudents do
       for j := 0 to 57 do
         Grid.Cells[j,i-1] := Grid.Cells[j,i];
     for j := 0 to 57 do
       Grid.Cells[j, NoStudents] := '';
     NoStudents := NoStudents - 1;
  end;
end;

procedure TGradebookFrm.CompScrMnuClick(Sender: TObject);
var
  i, j, k, NoVars, col : integer;
  DataMat : array[1..50,1..10] of double;
  Rmat, RelMat : array[1..10,1..10] of double;
  Weights, Reliabilities, VectProd, means, variances, stddevs : array[1..10] of double;
  X, Y, CompRel, numerator, denominator: double;
  outline, cellstring : string;
  RowLabels : array[1..10] of string;
  response : string;
  nomiss : integer;
  found : boolean;
  lReport: TStrings;
begin
  if not HasData then
  begin
    MessageDlg('No data available', mtError, [mbOK], 0);
    exit;
  end;

  NoVars := 0;

  // get number of tests
  for i := 1 to 10 do
  begin
    tno := i * 5 - 5;
    col := tno + 3; // column of raw scores for test number
    found := false;
    for j := 1 to NoStudents do
      if Grid.Cells[col,j] <> '' then found := true;
    if found then
    begin
      NoVars := NoVars + 1;
      RowLabels[NoVars] := 'Test ' + IntToStr(NoVars);
    end;
  end;

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
      else
        nomiss := nomiss + 1;
    end;
    if nomiss >= NoStudents then
      NoVars := NoVars - 1;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('COMPOSITE TEST RELIABILITY');
    lReport.Add('');
    lReport.Add('File Analyzed: ' + FileNameEdit.Text);
    lReport.Add('');

    // get correlation matrix
    for i := 1 to NoVars do
    begin
      means[i] := 0.0;
      variances[i] := 0.0;
      for j := 1 to NoVars do
        Rmat[i,j] := 0.0;
    end;

    // get cross-products matrix
    for i := 1 to NoStudents do
      for j := 1 to NoVars do
      begin
        X := DataMat[i,j];
        means[j] := means[j] + X;
        variances[j] := variances[j] + X * X;
        for k := 1 to NoVars do
        begin
          Y := DataMat[i,k];
          Rmat[j,k] := Rmat[j,k] + X * Y;
        end;
      end;

    // calculate variances and standard dev.s
    for j := 1 to NoVars do
    begin
      variances[j] := variances[j] - means[j] * means[j] / NoStudents;
      variances[j] := variances[j] / (NoStudents - 1.0);
      if variances[j] <= 0.0 then
      begin
        MessageDlg('No variance found in test '+ IntToStr(j), mtError, [mbOK], 0);
        exit;
      end
      else
        stddevs[j] := sqrt(variances[j]);
    end;

    // get variance-covariance matrix
    for j := 1 to NoVars do
      for k := 1 to NoVars do
      begin
        Rmat[j,k] := Rmat[j,k] - (means[j] * means[k] / NoStudents);
        Rmat[j,k] := Rmat[j,k] / (NoStudents - 1.0);
      end;

    // get correlation matrix
    for j := 1 to NoVars do
      for k := 1 to NoVars do
        Rmat[j,k] := Rmat[j,k] / (stddevs[j] * stddevs[k]);

    for j := 1 to NoVars do
      means[j] := means[j] / NoStudents;

    lReport.Add('');
    lReport.Add('Correlations Among Tests');

    outline := 'Test No.';
    for j := 1 to NoVars do
      outline := outline + Format('%7s', [rowlabels[j]]);
    lReport.Add(outline);
    for j := 1 to NoVars do
    begin
      outline := Format('%8s', [rowlabels[j]]);
      for k := 1 to NoVars do
        outline := outline + Format('%7.3f', [Rmat[j,k]]);
      lReport.Add(outline);
    end;

    outline := 'Means   ';
    for j := 1 to NoVars do
      outline := outline + Format('%7.2f', [means[j]]);
    lReport.Add(outline);

    outline := 'Std.Devs';
    for j := 1 to NoVars do
      outline := outline + Format('%7.2f', [stddevs[j]]);
    lReport.Add(outline);
    lReport.Add('');

    for i := 1 to NoVars do
      for j := 1 to NoVars do
        RelMat[i,j] := Rmat[i,j];

    for i := 1 to NoVars do
    begin
      response := InputBox('No. of items in Test ' + IntToStr(i),'Number:','0');
      nitems := StrToInt(response);
      Reliabilities[i] := nitems/(nitems-1) * (1.0 - (means[i] * (nitems - means[i]))/(nitems * variances[i]));
      RelMat[i,i] := Reliabilities[i];
      cellstring := 'Weight for Test ' + IntToStr(i);
      response := InputBox(cellstring,'Weight:','1');
      Weights[i] := StrToFloat(response);
    end;

    // get numerator and denominator of composite reliability
    numerator := 0.0;
    for i := 1 to NoVars do
      VectProd[i] := 0.0;
    for i := 1 to NoVars do
      for j := 1 to NoVars do
        VectProd[i] := VectProd[i] + Weights[i] * RelMat[j,i];
    for i := 1 to NoVars do
      numerator := numerator + VectProd[i] * Weights[i];

    denominator := 0.0;
    for i := 1 to NoVars do
      VectProd[i] := 0.0;
    for i := 1 to NoVars do
      for j := 1 to NoVars do
        VectProd[i] := VectProd[i] + Weights[i] * Rmat[j,i];
    for i := 1 to NoVars do
      denominator := denominator + VectProd[i] * Weights[i];

    CompRel := numerator / denominator;
    lReport.Add('');
    lReport.Add('Test No.  Weight Reliability');
    for i := 1 to NoVars do
      lReport.Add('   %3d  %6.2f   %6.2f',[i,Weights[i],Reliabilities[i]]);
    lReport.Add('Composite reliability: %6.3f', [CompRel]);

    DisplayReport(lReport);

    if MessageDlg('Save the composite score?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      col := 53;
      for i := 1 to NoStudents do
      begin
        X := 0.0;
        for j := 1 to NoVars do
          X := X + DataMat[i,j] * Weights[j];
          Grid.Cells[col,i] := FloatToStr(X);
      end;
    end;

  finally
    lReport.Free;
  end;
end;

procedure TGradebookFrm.ClassRptMnuClick(Sender: TObject);
var
  i, j, pos: integer;
  outline: string;
  raw, z, t, p: double;
  lReport: TStrings;
begin
  if not HasData then
  begin
    MessageDlg('No data available', mtError, [mbOK], 0);
    exit;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('CLASS REPORT');
    lReport.Add('');

    // confirm no. of students
    NoStudents := 0;
    for i := 1 to 40 do
      if Grid.Cells[0,i] <> '' then
        NoStudents := NoStudents + 1;
    for i := 1 to NoStudents do
    begin
      outline := Grid.Cells[1,i] + ' ';
      if Grid.Cells[2,i] <> '' then outline := outline + Grid.Cells[2,i] + ' ';
      outline := outline + Grid.Cells[0,i];
      lReport.Add('Report for: ' + outline);
      lReport.Add('');
      lReport.Add(' TEST       RAW        Z         T      PERCENTILE   GRADE');
      lReport.Add(' NO.       SCORE     SCORE     SCORE       RANK');
      lReport.Add('------    -------   -------   -------   ----------   -----');
      for j := 0 to 10 do
      begin
        pos := j * 5 + 3;
        outline := format(' %4d    ', [j+1]);
        if Grid.Cells[pos,i] <> '' then
        begin
          raw := StrToFloat(Grid.Cells[pos,i]);
          z := StrToFloat(Grid.Cells[pos+1,i]);
          t := strToFloat(Grid.Cells[pos+2,i]);
          p := StrToFloat(Grid.Cells[pos+3,i]);
          outline := outline + Format('%6.0f    %8.3f  %8.3f    %8.3f      %s',
            [raw, z, t, p, Grid.Cells[pos+4, i]]);
          lReport.Add(outline);
        end;
      end;
      if i <> NoStudents then
      begin
        lReport.Add('');
        lReport.Add(DIVIDER);
        lReport.Add('');
      end;
    end;
    DisplayReport(lReport);
  finally
    lReport.Free;
  end;
end;

procedure TGradebookFrm.FormCreate(Sender: TObject);
begin
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
  if (Grid.Cells[GridCol,GridRow] = ' ') then
    exit
  else
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

  if TestNo > NoTests then
    NoTests := TestNo;
end;

function TGradebookFrm.HasData: Boolean;
var
  i, j: Integer;
begin
  Result := true;
  for i := 1 to Grid.RowCount-1 do
    for j := 0 to 1 do
      if Grid.Cells[j, i] <> '' then
      begin
        Result := true;
        exit;
      end;
end;

procedure TGradebookFrm.NameProtectionChkChange(Sender: TObject);
begin
  if NameProtectionChk.Checked then
    Grid.FixedCols := 3
  else
    Grid.FixedCols := 0;
end;

procedure TGradebookFrm.NewGBMnuClick(Sender: TObject);
var
  i, j: integer;
begin
  for i := 1 to 40 do
    for j := 0 to 57 do Grid.Cells[j,i] := '';
  FileNameEdit.text := '';
end;

procedure TGradebookFrm.OpenGBMnuClick(Sender: TObject);
begin
  OpenDialog1.DefaultExt := '.gbk';
  OpenDialog1.Filter := 'All files (*.*)|*.*|Grade Book Files (*.gbk)|*.gbk;*.GBK';
  OpenDialog1.FilterIndex := 2;
  if OpenDialog1.Execute then
    OpenGradeBook(OpenDialog1.FileName);
end;

procedure TGradeBookFrm.OpenGradeBook(const AFileName: String);
var
  F: TextFile;
  i, j: Integer;
  cellStr: String;
begin
  if Lowercase(ExtractFileExt(AFileName)) <> '.gbk' then
  begin
    MessageDlg(Format('"%s" is not a .gbk file.', [AFileName]), mtError, [mbOK], 0);
    exit;
  end;

  FileNameEdit.Text := AFileName;

  AssignFile(F, AFileName);
  Reset(F);

  ReadLn(F, NoStudents);
  for i := 1 to 40 do
    for j := 0 to 57 do
    begin
      ReadLn(F, cellStr);
      Grid.Cells[j, i] := cellStr;
    end;

  CloseFile(F);
end;

procedure TGradebookFrm.ResetBtnClick(Sender: TObject);
var
  r: Integer;
begin
  FileNameEdit.Text := '';
  for r := 1 to Grid.RowCount-1 do
    Grid.Rows[r].Clear;
end;

procedure TGradebookFrm.SaveGBMnuClick(Sender: TObject);
var
  FName: string;
  Book: textfile;
  i, j: integer;
  cellstr: string;
begin
  // confirm no. of students
  NoStudents := 0;
  for i := 1 to 40 do
    if Grid.Cells[0,i] <> '' then
      NoStudents := NoStudents + 1;

  SaveDialog1.DefaultExt := '.fbk';
  SaveDialog1.Filter := 'All Files (*.*)|*.*|Grade Book Files(*.gbk)|*.gbk;*.GBK';
  SaveDialog1.FilterIndex := 2;
  if SaveDialog1.Execute then
  begin
    // GetNoRecords;
    FName := SaveDialog1.FileName;
    AssignFile(Book, FName);
    Rewrite(Book);

    WriteLn(Book, NoStudents);
    for i := 1 to 40 do
      for j := 0 to 57 do
      begin
        cellstr := Grid.Cells[j,i];
        writeln(Book, cellstr);
      end;

    CloseFile(Book);
  end;

  FileNameEdit.text := '';
end;

procedure TGradebookFrm.StudRptsMnuClick(Sender: TObject);
var
  i, j, pos: integer;
  outline: string;
  raw, z, t, p: double;
  lReport: TStrings;
begin
  if not HasData then
  begin
    MessageDlg('No data available', mtError, [mbOK], 0);
    exit;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('INDIVIDUAL STUDENT REPORTS');
    lReport.Add('');

    // confirm no. of students
    NoStudents := 0;
    for i := 1 to 40 do
      if Grid.Cells[0,i] <> '' then
        NoStudents := NoStudents + 1;

    for i := 1 to NoStudents do
    begin
      outline := Grid.Cells[1,i] + ' ';
      if Grid.Cells[2,i] <> '' then
        outline := outline + Grid.Cells[2,i] + ' ';
      outline := outline + Grid.Cells[0,i];
      lReport.Add('Report for: ' + outline);
      lReport.Add('');
      lReport.Add(' TEST       RAW        Z         T      PERCENTILE   GRADE');
      lReport.Add(' NO.       SCORE     SCORE     SCORE       RANK');
      lReport.Add('------    -------   -------   -------   ----------   -----');
      for j := 0 to 10 do
      begin
        pos := j * 5 + 3;
        outline := format(' %4d    ',[j+1]);
        if Grid.Cells[pos, i] <> '' then
        begin
          raw := StrToFloat(Grid.Cells[pos, i]);
          z := StrToFloat(Grid.Cells[pos+1, i]);
          t := strToFloat(Grid.Cells[pos+2, i]);
          p := StrToFloat(Grid.Cells[pos+3, i]);
          outline := outline + Format('%6.0f    %8.3f  %8.3f    %8.3f      %s',
            [raw, z, t, p, Grid.Cells[pos+4, i]]);
          lReport.Add(outline);
        end;
      end;
      if i <> NoStudents then
      begin
        lReport.Add('');
        lReport.Add(DIVIDER);
        lReport.Add('');
      end;
    end;

    DisplayReport(lReport);
  finally
    lReport.Free;
  end;
end;

procedure TGradebookFrm.TestAnalMnuClick(Sender: TObject);
var
  i, j, k, col: integer;
  X, mean, variance, stddev: double;
  z, t: double;
  response: string;
  cumfreq: array[0..50] of double;
  cumfreqmid: array[0..50] of double;
  ncnt: integer;
  KR21: double;
  minf, maxf: double;
  lReport: TStrings;
begin
  if not HasData then
  begin
    MessageDlg('No data available', mtError, [mbOK], 0);
    exit;
  end;

  response := InputBox('Which test (number)','Test: ', '');
  if (response = '') or not TryStrToInt(response, tno) then
  begin
    MessageDlg('You must select a test number between 1 and 11.', mtError, [mbOK], 0);
    exit;
  end;

  tno := tno * 5 - 5;
  col := tno + 3; // column of raw scores for test number tno

  // get no. of students
  NoStudents := 0;
  for i := 1 to 40 do
    if Grid.Cells[col,i] <> '' then
      NoStudents := NoStudents + 1;

  SetLength(sortedraw, 41);
  SetLength(pcntiles, 41, 41);
  SetLength(tscores, 41);
  SetLength(zscores, 41);

  lReport := TStringList.Create;
  try
    lReport.Add('TEST ANALYSIS RESULTS');
    mean := 0.0;
    variance := 0.0;
    for i := 1 to NoStudents do
    begin
      X := StrToFloat(Grid.Cells[col,i]);
      sortedraw[i-1] := X;
      mean := mean + X;
      variance := variance + X * X;
    end;
    variance := variance - sqr(mean) / NoStudents;
    variance := variance / (NoStudents - 1.0);
    stddev := sqrt(variance);
    mean := mean / NoStudents;
    lReport.Add('Mean:     %8.2f', [mean]);
    lReport.Add('Variance: %8.3f', [variance]);
    lReport.Add('Std.Dev.: %8.3f', [stddev]);
    lReport.Add('');

    response := InputBox('Count of Test Items or maximum score possible', 'Value:', '');
    if (response = '') then
    begin
      MessageDlg('Enter the maximum score or the count of test items.', mtError, [mbOK], 0);
      exit;
    end;

    if not TryStrToInt(response, nItems) or (nItems <= 0) then
    begin
      MessageDlg('Positive number required.', mtError, [mbOK], 0);
      exit;
    end;

    KR21 := nitems / (nitems-1) * (1.0 - mean * (nitems - mean)/(nitems * variance));
    lReport.Add('Kuder-Richardson Formula 21 Reliability Estimate: %6.4f', [KR21]);
    lReport.Add('');

    // get z scores and T scores
    for i := 1 to NoStudents do
    begin
      z := (SortedRaw[i-1] - mean) / stddev;
      Grid.Cells[col+1, i] := Format('%.3f', [z]);
      t := z * 10 + 50;
      Grid.Cells[col+2, i] := Format('%.1f', [t]);
    end;

    // sort raw scores in ascending order
    for i := 1 to NoStudents-1 do
      for j := i + 1 to NoStudents do
        if sortedraw[i-1] > sortedraw[j-1] then // switch
          Exchange(sortedRaw[i-1], sortedRaw[j-1]);

    // get percentile rank
    ncnt := NoStudents;
    nints := 1;
    for i := 1 to ncnt do
      freq[i-1] := 0;
    X := sortedraw[0];
    Scores[0] := X;
    for i := 1 to ncnt do
      if (X = sortedraw[i-1]) then
        freq[nints-1] := freq[nints-1] + 1
      else // new value
      begin
        nints := nints + 1;
        freq[nints-1] := freq[nints-1] + 1;
        X := sortedraw[i-1];
        Scores[nints-1] := X;
      end;

    // get min and max frequencies
    minf := NoStudents;
    maxf := 0;
    for i := 0 to nints - 1 do
    begin
      if freq[i] > maxf then
        maxf := freq[i];
      if freq[i] < minf then
        minf := freq[i];
    end;

    // now get cumulative frequencies
    cumfreq[0] := freq[0];
    for i := 1 to nints-1 do
      cumfreq[i] := freq[i] + cumfreq[i-1];

    // get cumulative frequences to midpoints and percentile ranks
    cumfreqmid[0] := freq[0] * 0.5;
    pcntilerank[0] := cumfreq[0] * 0.5 / ncnt;
    for i := 1 to nints-1 do
    begin
      cumfreqmid[i] := freq[i] * 0.5 + cumfreq[i-1];
      pcntilerank[i] := cumfreqmid[i] / ncnt;
    end;

    lReport.Add('PERCENTILE RANKS');
    lReport.Add('Score Value   Frequency   Cum.Freq.  Percentile Rank');
    lReport.Add('-----------   ----------  ---------  --------------');
    for i := 1 to nints do
      lReport.Add('  %8.3f     %6.2f     %6.2f       %6.2f',
        [Scores[i-1], freq[i-1], cumfreq[i-1], pcntilerank[i-1]*100.0]);
    lReport.Add('');

    // get grades
    if GradingFrm = nil then
      Application.CreateForm(TGradingFrm, GradingFrm);
    if GradingFrm.ShowModal <> mrOK then
      exit;

    // Now place results in testgrid
    for i := 1 to ncnt do
    begin
      X := StrToFloat(Grid.Cells[col,i]);
      for j := 0 to nints do
        if X = scores[j] then
          Grid.Cells[col+3,i] := Format('%.2f', [pcntilerank[j]*100.0]);
    end;

    DisplayReport(lReport);

    // graph raw scores
    if maxf = minf then exit;
    GraphFrm.Heading := 'Frequency of Raw Scores';
    GraphFrm.XTitle := 'Category';
    GraphFrm.YTitle := 'Frequency';
    SetLength(GraphFrm.Ypoints, 1, nints);
    SetLength(GraphFrm.Xpoints, 1, nints);
    for k := 1 to nints do
    begin
//          GraphFrm.PointLabels[k-1] := GradingSpecs[p].GridData[k,1];
      GraphFrm.Xpoints[0, k-1] := Scores[k];
      GraphFrm.Ypoints[0, k-1] := freq[k];
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
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.PtLabels := true;
    GraphFrm.ShowModal;

  finally
    lReport.Free;
    GraphFrm.Ypoints := nil;
    GraphFrm.Xpoints := nil;
    sortedraw := nil;
    zscores := nil;
    tscores := nil;
    pcntiles := nil;
  end;
end;


initialization
  {$I gradebookunit.lrs}

end.

