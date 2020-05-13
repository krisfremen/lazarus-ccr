unit TestScoreUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MatrixLib, MainUnit, Globals, DataProcs, OutputUnit, FunctionsLib,
  GraphLib, DictionaryUnit;

type

  { TTestScoreFrm }

  TTestScoreFrm = class(TForm)
    Bevel1: TBevel;
    MeansPlotChk: TCheckBox;
    HoytChk: TCheckBox;
    DescChk: TCheckBox;
    Panel1: TPanel;
    PlotChk: TCheckBox;
    CorrsChk: TCheckBox;
    SimultChk: TCheckBox;
    FirstChk: TCheckBox;
    ReplaceChk: TCheckBox;
    AddChk: TCheckBox;
    ListChk: TCheckBox;
    AlphaChk: TCheckBox;
    StepChk: TCheckBox;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    LastInBtn: TBitBtn;
    FirstInBtn: TBitBtn;
    IDInBtn: TBitBtn;
    Label14: TLabel;
    Label15: TLabel;
    ScoreEdit: TEdit;
    Label13: TLabel;
    ResponseEdit: TEdit;
    Label12: TLabel;
    RespNoEdit: TEdit;
    ItemNoEdit: TEdit;
    FractEdit: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LastNameEdit: TEdit;
    FirstNameEdit: TEdit;
    IDNoEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ItemList: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    NoCorBtn: TRadioButton;
    FractWrongBtn: TRadioButton;
    ItemScroll: TScrollBar;
    ResponseScroll: TScrollBar;
    SumRespBtn: TRadioButton;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FirstChkClick(Sender: TObject);
    procedure FirstInBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IDInBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure ItemScrollChange(Sender: TObject);
    procedure LastInBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure ResponseScrollChange(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
   FAutoSized: Boolean;
   NoItems : integer;
   NoSelected : integer;
   NCases : integer; // count of good records (not counting key if included)
   ColNoSelected : IntDyneVec;
   ColLabels, RowLabels : StrDyneVec;
   Responses: array[1..5] of StrDyneVec;
   RespWghts: array[1..5] of DblDyneVec;
   Means, Variances, StdDevs : DblDyneVec;
   CorMat : DblDyneMat; // correlations among items and total score
   Data : DblDyneMat; //store item scores and total score
   IDCol, FNameCol, LNameCol : integer;
   MaxRespNo: integer;
   procedure ItemScores;
   procedure ScoreReport(AReport: TStrings);
   procedure Alpha(AReport: TStrings);
   procedure Cors(AReport: TStrings);
   procedure SimMR(AReport: TStrings);
   procedure Hoyt(AReport: TStrings);
   procedure StepKR(AReport: TStrings);
   procedure PlotScores;
   procedure PlotMeans;

   procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  TestScoreFrm: TTestScoreFrm;

implementation

uses
  Math, Utils;

{ TTestScoreFrm }

procedure TTestScoreFrm.ResetBtnClick(Sender: TObject);
var
  i, j: integer;
begin
  ItemScroll.Min := 1;
  ResponseScroll.Min := 1;
  ItemScroll.Position := 1;
  ResponseScroll.Position := 1;
  //InBtn.Enabled := true;
  //OutBtn.Enabled := false;
  VarList.Items.Clear;
  ItemList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  ItemNoEdit.Text := '1';
  RespNoEdit.Text := '1';
  ResponseEdit.Text := '1';
  ScoreEdit.Text := '1';
  FractEdit.Text := '4';
  LastNameEdit.Text := '';
  FirstNameEdit.Text := '';
  IDNoEdit.Text := '';
  NoCorBtn.Checked := true;
  ReplaceChk.Checked := false;
  AddChk.Checked := false;
  ListChk.Checked := false;
  AlphaChk.Checked := false;
  SimultChk.Checked := false;
  CorrsChk.Checked := false;
  PlotChk.Checked := false;
  DescChk.Checked := false;
  FirstChk.Checked := true;
  GroupBox2.Visible := false;
  MaxRespNo := 0;
  //LastInBtn.Visible := true;
  //FirstInBtn.Visible := true;
  //IDInBtn.Visible := true;
  StepChk.Checked := false;
  HoytChk.Checked := false;
  MeansPlotChk.Checked := false;

  UpdateBtnStates;

  //allocate space on heap
  SetLength(ColNoSelected, NoVariables);
  SetLength(ColLabels, NoVariables+1);
  SetLength(RowLabels, NoVariables+1);
  SetLength(Means, NoVariables+1);
  SetLength(Variances, NoVariables+1);
  SetLength(StdDevs, NoVariables+1);
  SetLength(CorMat, NoVariables+2, NoVariables+2);
  SetLength(Data, NoCases+1, NoVariables+2);

  for i := 1 to 5 do
  begin
    SetLength(RespWghts[i], NoVariables);
    SetLength(Responses[i], NoVariables);
  end;

  for i := 1 to 5 do
    for j := 0 to NoVariables-1 do
    begin
      RespWghts[i, j] := 1.0;
      Responses[i, j] := '1';
  end;
end;

procedure TTestScoreFrm.ResponseScrollChange(Sender: TObject);
var
   item, respno : integer;
begin
     item := StrToInt(ItemNoEdit.Text);
     if item <= 0 then exit;
     respno := StrToInt(RespNoEdit.Text);
     if respno > 5 then exit; // already at max
     if respno > MaxRespNo then MaxRespNo := respno;
     // save current response
     Responses[respno][item-1] := ResponseEdit.Text;
     RespWghts[respno][item-1] := StrToFloat(ScoreEdit.Text);
     // display new position response
     respno := ResponseScroll.Position;
     RespNoEdit.Text := IntToStr(respno);
     ResponseEdit.Text := Responses[respno][item-1];
     ScoreEdit.Text := FloatToStr(RespWghts[respno][item-1]);
end;

procedure TTestScoreFrm.FormActivate(Sender: TObject);
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

procedure TTestScoreFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TTestScoreFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TTestScoreFrm.IDInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (IDNoEdit.Text = '') then begin
    IDNoEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TTestScoreFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      ItemList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;

  ItemScroll.Max := ItemList.Items.Count;
end;

procedure TTestScoreFrm.ItemScrollChange(Sender: TObject);
var
   item, respno : integer;
begin
     item := StrToInt(ItemNoEdit.Text);
     respno := StrToInt(RespNoEdit.Text);
     if respno > MaxRespNo then MaxRespNo := respno;
     // save last one
     if (item <> ItemScroll.Position) then
     begin
          Responses[respno][item-1] := ResponseEdit.Text;
          RespWghts[respno][item-1] := StrToFloat(ScoreEdit.Text);
     end;
     item := ItemScroll.Position;
     ItemNoEdit.Text := IntToStr(item);
     respno := 1;
     ResponseScroll.Position := 1; // first response
     RespNoEdit.Text := '1'; // default
     ScoreEdit.Text := '1'; // default
     // load previous one
     ResponseEdit.Text := Responses[respno][item-1];
     ScoreEdit.Text := FloatToStr(RespWghts[respno][item-1]);
end;

procedure TTestScoreFrm.LastInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (LastNameEdit.Text = '') then
  begin
    LastNameEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TTestScoreFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < ItemList.Items.Count do
  begin
    if ItemList.Selected[i] then
    begin
      VarList.Items.Add(ItemList.Items[i]);
      ItemList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TTestScoreFrm.ComputeBtnClick(Sender: TObject);
var
  i, j, col, start, count: integer;
  cellstring: string;
  lReport: TStrings;
begin
  NoItems := ItemList.Items.Count;

  // Insure last item scoring definition is saved
  if not FirstChk.Checked then
    ItemScroll.Position := 1;

  // items to analyze
  for i := 1 to NoItems do
  begin
    // variables in grid
    for j := 1 to NoVariables do
    begin
      cellstring := OS3MainFrm.DataGrid.Cells[j,0];
      if cellstring = ItemList.Items[i-1] then
      begin // matched - save info
        ColNoSelected[i-1] := j;
        ColLabels[i-1] := cellstring;
        RowLabels[i-1] := cellstring;
      end; // end match
    end; // next j
  end; // next i
  ColLabels[NoItems] := 'TOTAL';
  RowLabels[NoItems] := 'TOTAL';

  for j := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[j,0];
    if cellstring = IDNoEdit.Text then IDCol := j;
    if cellstring = LastNameEdit.Text then LNameCol := j;
    if cellstring = FirstNameEdit.Text then FNameCol := j;
  end;

  if FirstChk.Checked then // first record is the key
  begin
    for i := 1 to NoItems do
    begin
      col := ColNoSelected[i-1];
      Responses[1][i-1] := Trim(OS3MainFrm.DataGrid.Cells[col,1]);
      RespWghts[1][i-1] := 1.0;
      MaxRespNo := 1;
    end;
  end;

  // check to see if grid item values are numeric or string
  // if numeric, insure that they are integers, not floating values
  for i := 1 to NoItems do
  begin
    col := ColNoSelected[i-1];
    if IsNumeric(OS3MainFrm.DataGrid.Cells[col,2]) then // second case
    begin
      if DictionaryFrm.DictGrid.Cells[5,col] <> '0' then
      begin
        ErrorMsg('Sorry, you must format cell values with 0 decimal parts.');
        exit;
      end;
    end;
  end;

  // now score the responses
  ItemScores();

  // place item scores in grid if elected
  if ReplaceChk.Checked then
  begin
    if FirstChk.Checked then start := 2 else start := 1;
    count := 0;
    for i := start to NoCases do
    begin
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      count := count + 1;
      for j := 1 to NoItems do
      begin
        col := ColNoSelected[j-1];
        OS3MainFrm.DataGrid.Cells[col,i] := FloatToStr(Data[count-1,j-1]);
      end;
    end;
  end;

  // add total to grid if elected
  if AddChk.Checked then
  begin
    cellstring := 'TOTAL';
    col := NoVariables + 1;
    DictionaryFrm.NewVar(col);
    DictionaryFrm.DictGrid.Cells[1,NoVariables] := cellstring;
    OS3MainFrm.DataGrid.Cells[NoVariables,0] := cellstring;
    DictionaryFrm.DictGrid.Cells[1,col] := cellstring;
    count := 0;
    if FirstChk.Checked then start := 2 else start := 1;
    for i := start to NoCases do
    begin
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      count := count + 1;
      col := NoVariables;
      OS3MainFrm.DataGrid.Cells[col,i] := FloatToStr(Data[count-1,NoItems]);
    end;
  end;

  lReport := TStringList.Create;
  try
    // list the scores if elected
    if ListChk.Checked then ScoreReport(lReport);

    // get Cronbach Alpha reliability estimate if elected
    if AlphaChk.Checked then Alpha(lReport);

    // get intraclass reliabilities (Hoyt) if elected
    if HoytChk.Checked then Hoyt(lReport);

    // get step kr#20 if elected
    if StepChk.Checked then StepKR(lReport);

    // get interitem correlation matrix if elected
    if CorrsChk.Checked then Cors(lReport);

    // Get simultaneous multiple regressions if elected
    if SimultChk.Checked then SimMR(lReport);

    if lReport.Count > 0 then DisplayReport(lReport);

    // plot subject scores if elected
    if PlotChk.Checked then PlotScores();

    // Plot item means if elected
    if MeansPlotChk.Checked then PlotMeans();

  finally
    lReport.Free;
  end;
end;

procedure TTestScoreFrm.FirstChkClick(Sender: TObject);
begin
     if FirstChk.Checked then GroupBox2.Visible := false else
        GroupBox2.Visible := true;
end;

procedure TTestScoreFrm.FirstInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (FirstNameEdit.Text = '') then
  begin
    FirstNameEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TTestScoreFrm.ItemScores;
var
  start, i, j, k, count, col: integer;
  score, denom, fract: double;
  response: string;
begin
  if FirstChk.Checked then start := 2 else start := 1;
  count := 0;

  for i := start to NoCases do
  begin
    score := 0.0;
    if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
    count := count + 1;
    for j := 1 to NoItems do
    begin
      col := ColNoSelected[j-1];
      response := Trim(OS3MainFrm.DataGrid.Cells[col,i]);
      for k := 1 to MaxRespNo do
      begin
        if (response = Responses[k][j-1])then
        begin
          if SumRespBtn.Checked then
          begin
            score := score + RespWghts[k][j-1];
            Data[count-1,j-1] := RespWghts[k][j-1];
          end;

          if NoCorBtn.Checked then
          begin
            score := score + 1;
            Data[count-1,j-1] := 1;
          end;

          if FractWrongBtn.Checked then
          begin
            denom := StrToFloat(FractEdit.Text);
            fract := 1.0 / denom;
            score := score + RespWghts[k][j-1] - (fract * RespWghts[k][j-1]);
            Data[count-1,j-1] :=RespWghts[k][j-1] - (fract * RespWghts[k][j-1]);
          end;
        end;
      end;
    end;  // next item in scale

    Data[count-1,NoItems] := score;
  end; // next case

  NCases := count;
end;

procedure TTestScoreFrm.ScoreReport(AReport: TStrings);
var
  i, start, count, col: integer;
  outline, namestr: string;
begin
  AReport.Add('TEST SCORING REPORT');
  AReport.Add('');

  if FirstChk.Checked then start := 2 else start := 1;

  outline := '';
  if IDNoEdit.Text <> '' then
    outline := outline + 'PERSON ID NUMBER '
  else
    outline := outline + 'CASE            ';
  if FirstNameEdit.Text <> '' then
    outline := outline + 'FIRST NAME ';
  if LastNameEdit.Text <> '' then
  outline := outline + 'LAST NAME TEST SCORE';
  AReport.Add(outline);

  count := 0;
  for i := start to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then
      continue;

    count := count + 1;
    outline := '';
    if IDNoEdit.Text <> '' then
    begin
      col := IDCol;
      namestr := Trim(OS3MainFrm.DataGrid.Cells[col,i]);
      outline := outline + Format('%16s ', [namestr]);
    end else
    begin
      namestr := Trim(OS3MainFrm.DataGrid.Cells[0,i]);
      outline := outline + Format('%-16s ', [namestr]);
    end;

    if FirstNameEdit.Text <> '' then
    begin
      col := FNameCol;
      namestr := Trim(OS3MainFrm.DataGrid.Cells[col,i]);
      outline := outline + Format('%10s ', [namestr]);
    end;

    if LastNameEdit.Text <> '' then
    begin
      col := LNameCol;
      namestr := Trim(OS3MainFrm.DataGrid.Cells[col,i]);
      outline := outline + Format('%10s ', [namestr]);
    end;

    outline := outline + Format('%6.2f', [Data[count-1,NoItems]]);
    AReport.Add(outline);
  end;

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');
end;

procedure TTestScoreFrm.Alpha(AReport: TStrings);
var
  i, j: integer;
  AlphaRel, SEMeas: double;
begin
  AlphaRel := 0.0;

  // get item variances
  for j := 0 to NoItems do
  begin
    Variances[j] := 0.0;
    Means[j] := 0.0;
  end;

  for j := 0 to NoItems do
    for i := 0 to NCases - 1 do
    begin
      Variances[j] := Variances[j] + sqr(Data[i, j]);
      Means[j] := Means[j] + Data[i, j];
    end;

  for j := 0 to NoItems do
  begin
    Variances[j] := Variances[j] - sqr(Means[j] / NCases);
    Variances[j] := Variances[j] / (NCases - 1);
    Means[j] := Means[j] / NCases;
  end;

  // sum of item variances
  for i := 0 to NoItems-1 do
    AlphaRel := AlphaRel + variances[i];
  AlphaRel  := AlphaRel / variances[NoItems];
  AlphaRel := 1.0 - AlphaRel;
  AlphaRel := (NoItems / (NoItems - 1.0)) * AlphaRel;
  if AlphaRel > 1.0 then AlphaRel := 1.0;
  SEMeas := sqrt(Variances[NoItems] * (1.0 - AlphaRel));

  AReport.Add('Alpha Reliability Estimate for Test: %.4f', [AlphaRel]);
  AReport.Add('S.E. of Measurement:                 %.3f', [SEMeas]);

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');
end;

procedure TTestScoreFrm.Cors(AReport: TStrings);
var
  i, j, k: integer;
  title: string;
begin
  for i := 1 to NoItems +1 do
  begin
    for j := 1 to NoItems + 1 do
      CorMat[i-1,j-1] := 0.0;
    Means[i-1] := 0.0;
    Variances[i-1] := 0.0;
  end;

  for i := 1 to NCases do
    for j := 1 to NoItems + 1 do
    begin
      for k := 1 to NoItems + 1 do
          CorMat[j-1,k-1] := Cormat[j-1,k-1] + (Data[i-1,j-1] * Data[i-1,k-1]);
      Means[j-1] := Means[j-1] + Data[i-1,j-1];
      Variances[j-1] := Variances[j-1] + sqr(Data[i-1,j-1]);
    end;

  for i := 1 to NoItems + 1 do
  begin
    Variances[i-1] := Variances[i-1]  - (sqr(Means[i-1]) / NCases);
    Variances[i-1] := Variances[i-1] / (NCases - 1);
    StdDevs[i-1] := sqrt(Variances[i-1]);
  end;

  for i := 1 to NoItems + 1 do
    for j := 1 to NoItems + 1 do
    begin
      CorMat[i-1,j-1] := CorMat[i-1,j-1] - (Means[i-1] * Means[j-1] / NCases);
      CorMat[i-1,j-1] := CorMat[i-1,j-1] / (NCases - 1);
      if (StdDevs[i-1] > 0) and (StdDevs[j-1] > 0) then
        CorMat[i-1,j-1] := CorMat[i-1,j-1] / (StdDevs[i-1] * StdDevs[j-1])
      else begin
        ErrorMsg('A zero variance found.');
        CorMat[i-1,j-1] := 99.99;
      end;
    end;

  for i := 1 to NoItems + 1 do
    Means[i-1] := Means[i-1] / NCases;

  if CorrsChk.Checked then
  begin
    title := 'Item and Total Score Intercorrelations';
    MatPrint(CorMat, NoItems + 1, NoItems + 1, title, RowLabels, ColLabels, NCases, AReport);
  end;

  if DescChk.Checked then
  begin
    title := 'Means';
    DynVectorPrint(means, NoItems+1, title, ColLabels, NCases, AReport);

    title := 'Variances';
    DynVectorPrint(variances, NoItems+1, title, ColLabels, NCases, AReport);

    title := 'Standard Deviations';
    DynVectorPrint(stddevs, NoItems+1, title, ColLabels, NCases, AReport);
  end;

  if CorrsChk.Checked or DescChk.Checked then
  begin
    AReport.Add('');
    AReport.Add(DIVIDER);
    AReport.Add('');
  end;
end;

procedure TTestScoreFrm.SimMR(AReport: TStrings);
var
  i, j: integer;
  determinant, df1, df2, StdErr, x: double;
  valstring: string;
  CorrMat: DblDyneMat;
  ProdMat: DblDyneMat;
  R2s: DblDyneVec;
  W: DblDyneVec;
  FProbs: DblDyneVec;
  errorcode: boolean = false;
  title: string;
begin
  SetLength(CorrMat,NoVariables+1,NoVariables+1);
  SetLength(R2s,NoVariables);
  SetLength(W,NoVariables);
  SetLength(FProbs,NoVariables);
  SetLength(ProdMat,NoVariables+1,NoVariables+1);

  if not CorrsChk.Checked then Cors(AReport);

  determinant := 0.0;
  for i := 0 to NoItems-1 do
    for j := 0 to NoItems-1 do
      CorrMat[i,j] := CorMat[i,j];

  Determ(CorrMat,NoItems,NoItems,determinant,errorcode);
  if (determinant < 0.000001) then
  begin
    ErrorMsg('Matrix is singular!');
    exit;
  end;

  AReport.Add('Determinant of correlation matrix: %8.4f', [determinant]);
  AReport.Add('');

  for i := 0 to NoItems-1 do
    for j := 0 to NoItems-1 do
      CorrMat[i,j] := CorMat[i,j];

  SVDinverse(CorrMat,NoItems);

  AReport.Add('Multiple Correlation Coefficients for Each Variable');
  AReport.Add('');
  AReport.Add('%10s%8s%10s%10s%12s%5s%5s', ['Variable','R','R2','F','Prob.>F','DF1','DF2']);

  df1 := NoItems - 1.0;
  df2 := NCases - NoItems;

  for i := 0  to NoItems-1 do
  begin
    // R squared values
    R2s[i] := 1.0 - (1.0 / CorrMat[i,i]);
    W[i] := (R2s[i] / df1) / ((1.0-R2s[i]) / df2);
    FProbs[i] := probf(W[i],df1,df2);
    valstring := Format('%10s', [ColLabels[i]]);
    AReport.Add('%10s%10.3f%10.3f%10.3f%10.3f%5.0f%5.0f', [valstring,sqrt(R2s[i]),R2s[i],W[i],FProbs[i],df1,df2]);
    // betas
    for j := 0 to NoItems-1 do
      ProdMat[i,j] := -CorrMat[i,j] / CorrMat[j,j];
  end;

  title := 'Betas in Columns';
  MatPrint(ProdMat, NoItems, NoItems, title, RowLabels, ColLabels, NCases, AReport);

  AReport.Add('Standard Errors of Prediction');
  AReport.Add('Variable     Std.Error');

  for i := 0 to NoItems-1 do
  begin
    StdErr := (NCases-1) * Variances[i] * (1.0 / CorrMat[i,i]);
    StdErr := sqrt(StdErr / (NCases - NoItems));
    AReport.Add('%10s%10.3f', [ColLabels[i], StdErr]);
  end;

  for i := 0 to NoItems-1 do
    for j := 0 to NoItems-1 do
      if (i <> j) then ProdMat[i,j] := ProdMat[i,j] * (StdDevs[j]/StdDevs[i]);

  title := 'Raw Regression Coefficients';
  MatPrint(ProdMat, NoItems, NoItems, title, RowLabels, ColLabels, NCases,AReport);
  AReport.Add('Variable   Constant');

  for i := 0 to NoItems-1 do
  begin
    x := 0.0;
    for j := 0 to NoItems-1 do
      if (i <> j) then x := x + (ProdMat[j,i] * Means[j]);
    x := Means[i] - x;
    AReport.Add('%10s%10.3f',[ColLabels[i], x]);
  end;

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  ProdMat := nil;
  FProbs := nil;
  W := nil;
  R2s := nil;
  CorrMat := nil;
end;

procedure TTestScoreFrm.Hoyt(AReport: TStrings);
var
  i, j: integer;
  Hoyt1, Hoyt2, Hoyt3, Hoyt4, SEMeas1, SEMeas2, SEMeas3, SEMeas4: double;
  SSError, SSCases, SSItems, SSWithin, TotalSS, TotalX, Constant: double;
  MSItems, MSWithin, MSTotal, MSCases, MSError, score, ItemTotal: double;
  F1, F2, prob1, prob2, dfcases, dfwithin, dferror, dftotal: double;
  dfitems: double;
begin
  if not CorrsChk.Checked then
    Cors(AReport);

  SSCases := 0.0;
  SSItems := 0.0;
  TotalSS := 0.0;
  TotalX := 0.0;

  for j := 1 to NoItems do
  begin
    ItemTotal := 0.0;
    for i := 1 to NCases do //subject loop
    begin
      score := Data[i-1,j-1];
      ItemTotal := ItemTotal + score;
      TotalSS := TotalSS + (score * score);
    end;
    TotalX := TotalX + ItemTotal;
    SSItems := SSItems + (ItemTotal * ItemTotal) / NCases;
  end;

  for i := 1 to NCases do // subject loop
  begin
    score := Data[i-1,NoItems];
    SSCases := SSCases + (score * score);
  end;

  SSCases := SSCases / NoItems;
  Constant := (TotalX * TotalX) / (NCases * NoItems);
  SSCases := SSCases - Constant;
  TotalSS := TotalSS - Constant;
  SSWithin := TotalSS - SSCases;
  SSItems := SSItems - Constant;
  MSItems := SSItems / (NoItems - 1);
  SSError := SSWithin - SSItems;
  MSWithin := SSWithin / (NCases * (NoItems - 1));
  MSTotal := TotalSS / ((NCases * NoItems) - 1.0);
  MSCases := SSCases / (NCases - 1.0);
  MSError := SSError / ((NCases - 1.0) * (NoItems - 1.0));
  dfcases := NCases - 1;
  dfitems := NoItems - 1;
  dfwithin := NCases * (NoItems - 1);
  dferror := (NCases - 1) * (NoItems - 1);
  dftotal := (NCases * NoITems) - 1;
  F1 := MSCases / MSError;
  F2 := MSItems / MSError;
  prob1 := probf(F1,dfcases,dferror);
  prob2 := probf(F2,dfitems,dferror);

  AReport.Add('Analysis of Variance for Hoyt Reliabilities');
  AReport.Add('');
  AReport.Add('SOURCE    D.F.          SS        MS        F        PROB');
  AReport.Add('Subjects  %3.0f       %8.2f  %8.2f  %8.2f  %8.2f', [dfcases, SSCases, MSCases, F1, prob1]);
  AReport.Add('Within    %3.0f       %8.2f  %8.2f', [dfwithin, SSWithin, MSWithin]);
  AReport.Add('Items     %3.0f       %8.2f  %8.2f  %8.2f  %8.2f', [dfitems, SSItems, MSItems, F2, prob2]);
  AReport.Add('Error     %3.0f       %8.2f  %8.2f', [dferror, SSerror, MSerror]);
  AReport.Add('Total     %3.0f       %8.2f', [dftotal, TotalSS,  MSTotal]);
  AReport.Add('');

  Hoyt1 := 1.0 - (MSWithin / MSCases);
  Hoyt2 := (MSCases - MSError) / MSCases;
  Hoyt4 := (MSCases - MSError) / (MSCases + (NoItems-1.0) * MSError);
  Hoyt3 := (MSCases - MSWithin) / (MSCases + (NoItems-1.0) * MSWithin);

  SEMeas1 := stddevs[NoItems] * sqrt(1.0 - Hoyt1);
  AReport.Add('Hoyt Unadjusted Test Rel. for scale %s  = %6.4f  S.E. of Measurement = %8.3f', [ColLabels[NoItems], Hoyt1, SEMeas1]);

  SEMeas2 := stddevs[NoItems] * sqrt(1.0 - Hoyt2);
  AReport.Add('Hoyt Adjusted Test Rel. for scale %s    = %6.4f  S.E. of Measurement = %8.3f', [ColLabels[NoItems], Hoyt2, SEMeas2]);

  SEMeas3 := stddevs[NoItems] * sqrt(1.0 - Hoyt3);
  AReport.Add('Hoyt Unadjusted Item Rel. for scale %s  = %6.4f  S.E. of Measurement = %8.3f', [ColLabels[NoItems], Hoyt3, SEMeas3]);

  SEMeas4 := stddevs[NoItems] * sqrt(1.0 - Hoyt4);
  AReport.Add('Hoyt Adjusted Item Rel. for scale %s    = %6.4f  S.E. of Measurement = %8.3f', [ColLabels[NoItems], Hoyt4, SEMeas4]);

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');
end;

procedure TTestScoreFrm.StepKR(AReport: TStrings);
var
  i, j, col: integer;
  score, KR20, meanscore, scorevar, sumvars, hicor: double;
  selected: IntDyneVec;
  v1, v2, nselected, incount: integer;
  invalues: IntDyneVec;
  PtBis: DblDyneVec;
  done: boolean;
begin
  SetLength(selected,NoVariables);
  SetLength(invalues,NoVariables);
  SetLength(PtBis,NoVariables);

  Cors(AReport);

  v1 := 0;
  v2 := 0;
  nselected := NoItems;
  for i := 1 to nselected do selected[i-1] := i;

  // pick highest correlation for items to start
  hicor := -1.0;
  for i := 1 to nselected - 1 do
    for j := i + 1 to nselected do
      if CorMat[i-1,j-1] > hicor then
      begin
        hicor := CorMat[i-1,j-1];
        v1 := i;
        v2 := j;
      end;

  invalues[0] := v1; // cor matrix col
  invalues[1] := v2; // cor matrix row
  incount := 2;

  // now add items based on highest pt.bis. with subscores
  done := false;
  repeat
    meanscore := 0.0;
    scorevar := 0.0;
    sumvars := 0.0;

    for j := 1 to nselected do
      PtBis[j-1] := 0.0;

    // first get score for each subject
    for i := 1 to NCases do
    begin
      score := 0;
      for j := 1 to incount do
      begin
        col := selected[invalues[j-1]-1];
        score := score + Data[i-1,col-1];
      end;

      meanscore := meanscore + score;
      scorevar := scorevar + sqr(score);

      for j := 1 to nselected do
      begin
        col := selected[j-1];
        PtBis[j-1] := PtBis[j-1] + (score * Data[i-1,col-1]);
      end;
    end;

    scorevar := scorevar - (sqr(meanscore) / NCases);
    scorevar := scorevar / (NCases - 1);

    for j := 1 to nselected do
    begin
      if (Variances[j-1] > 0) and (scorevar > 0) then
      begin
        PtBis[j-1] := PtBis[j-1] - (meanscore * Means[j-1]);
        PtBis[j-1] := PtBis[j-1] / (NCases - 1);
        PtBis[j-1] := PtBis[j-1] / sqrt(Variances[j-1] * scorevar);
      end else
        PtBis[j-1] := 0.0;
    end;

    meanscore := meanscore / NCases;

    // get sum of item variances
    for j := 1 to incount do
      sumvars := sumvars + Variances[invalues[j-1]-1];

    KR20 := (incount / (incount - 1)) * (1.0 - sumvars / scorevar);
    AReport.Add('KR#20 = %6.4f for the test with mean = %6.3f and variance = %6.3f', [KR20, meanscore, scorevar]);
    AReport.Add('Item  Mean    Variance   Pt.Bis.r');

    for j := 1 to incount do
      AReport.Add('%3d   %6.3f  %6.3f     %6.4f', [
        selected[invalues[j-1]-1], Means[invalues[j-1]-1], Variances[invalues[j-1]-1], PtBis[invalues[j-1]-1]
      ]);

    if incount = nselected then
      done := true
    else
    begin
      hicor := -1.0;
      for j := 1 to incount do
        PtBis[invalues[j-1]-1] := -2.0;
      for j := 1 to nselected do
      begin
        if PtBis[j-1] > hicor then
        begin
          v1 := j;
          hicor := PtBis[j-1];
        end;
      end;
      incount := incount + 1;
      invalues[incount-1] := v1;
    end;

  until done;

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  // cleanup
  PtBis := nil;
  invalues := nil;
  selected := nil;
end;

procedure TTestScoreFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TTestScoreFrm.PlotScores;
var
  rowvar: DblDyneVec;
  totscrs: DblDyneVec;
  i, j: integer;
begin
  SetLength(rowvar, NoCases);
  SetLength(totscrs, NoCases);

  // use rowvar to hold case no.
  for i := 1 to NCases do rowvar[i-1] := i;

  // use totscrs to hold total subject scores
  for i := 1 to NCases do totscrs[i-1] := Data[i-1,NoItems];

  // sort into ascending order
  for i := 1 to NCases - 1 do
  begin
    for j := i + 1 to NCases do
    begin
      if totscrs[i-1] > totscrs[j-1] then // swap
      begin
        Exchange(totscrs[i-1], totscrs[j-1]);
        Exchange(rowvar[i-1], rowvar[j-1]);
      end;
    end;
  end;

  SetLength(GraphFrm.Ypoints,1,NoCases);
  SetLength(GraphFrm.Xpoints,1,NoCases);
  for i := 1 to NoCases do
  begin
    GraphFrm.Ypoints[0,i-1] := totscrs[i-1];
    GraphFrm.Xpoints[0,i-1] := rowvar[i-1];
  end;

  GraphFrm.nosets := 1;
  GraphFrm.nbars := NoCases;
  GraphFrm.Heading := 'DISTRIBUTION OF TOTAL SCORES';
  GraphFrm.XTitle := 'Case';
  GraphFrm.YTitle := 'Score';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := true;
  GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;

  rowvar := nil;
  totscrs := nil;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;

procedure TTestScoreFrm.PlotMeans;
var
  rowvar: DblDyneVec;
  i: integer;
begin
  SetLength(rowvar,NoItems);
  SetLength(GraphFrm.Ypoints,1,NoItems);
  SetLength(GraphFrm.Xpoints,1,NoItems);

  // use rowvar to hold variable no.
  for i := 1 to NoItems do
  begin
    rowvar[i-1] := i;
    GraphFrm.Xpoints[0,i-1] := i;
    GraphFrm.Ypoints[0,i-1] := Means[i-1];
  end;

  GraphFrm.nosets := 1;
  GraphFrm.nbars := NoItems;
  GraphFrm.Heading := 'ITEM MEANS';
  GraphFrm.XTitle := 'Item No.';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := true;
  GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
  GraphFrm.BackColor := GRAPH_BACK_COLOR;
  GraphFrm.WallColor := GRAPH_WALL_COLOR;
  GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;

  rowvar := nil;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;

procedure TTestScoreFrm.UpdateBtnStates;
begin
  InBtn.Enabled := AnySelected(VarList);
  OutBtn.Enabled := AnySelected(ItemList);
  LastInBtn.Enabled := (Varlist.ItemIndex > -1) and (LastNameEdit.Text = '');
  FirstInBtn.Enabled := (VarList.ItemIndex > -1) and (FirstNameEdit.Text = '');
  IDInBtn.Enabled := (VarList.ItemIndex > -1) and (IDNoEdit.Text = '');
end;


initialization
  {$I testscoreunit.lrs}

end.

