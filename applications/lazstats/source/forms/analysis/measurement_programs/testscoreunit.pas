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
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
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
    procedure CancelBtnClick(Sender: TObject);
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
    procedure ReturnBtnClick(Sender: TObject);
  private
    { private declarations }
   FAutoSized: Boolean;
   NoItems : integer;
   NoSelected : integer;
   NCases : integer; // count of good records (not counting key if included)
   ColNoSelected : IntDyneVec;
   ColLabels, RowLabels : StrDyneVec;
   Responses : array[1..5] of StrDyneVec;
   RespWghts : array[1..5] of DblDyneVec;
   Means, Variances, StdDevs : DblDyneVec;
   CorMat : DblDyneMat; // correlations among items and total score
   Data : DblDyneMat; //store item scores and total score
   IDCol, FNameCol, LNameCol : integer;
   MaxRespNo : integer;
   procedure ItemScores(Sender: TObject);
   procedure ScoreReport(Sender: TObject);
   procedure Alpha(Sender: TObject);
   procedure Cors(Sender: TObject);
   procedure SimMR(Sender: TObject);
   procedure Hoyt(Sender: TObject);
   procedure StepKR(Sender: TObject);
   procedure PlotScores(Sender: TObject);
   procedure PlotMeans(Sender: TObject);

  public
    { public declarations }
  end; 

var
  TestScoreFrm: TTestScoreFrm;

implementation

uses
  Math;

{ TTestScoreFrm }

procedure TTestScoreFrm.ResetBtnClick(Sender: TObject);
VAR i, j : integer;
begin
     ItemScroll.Min := 1;
     ResponseScroll.Min := 1;
     ItemScroll.Position := 1;
     ResponseScroll.Position := 1;
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
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
     LastInBtn.Visible := true;
     FirstInBtn.Visible := true;
     IDInBtn.Visible := true;
     StepChk.Checked := false;
     HoytChk.Checked := false;
     MeansPlotChk.Checked := false;

     //allocate space on heap
     SetLength(ColNoSelected,NoVariables);
     SetLength(ColLabels,NoVariables+1);
     SetLength(RowLabels,NoVariables+1);
     SetLength(Means,NoVariables+1);
     SetLength(Variances,NoVariables+1);
     SetLength(StdDevs,NoVariables+1);
     SetLength(CorMat,NoVariables+2,NoVariables+2);
     SetLength(Data,NoCases+1,NoVariables+2);

     for i := 1 to 5 do
     begin
          SetLength(RespWghts[i],NoVariables);
          SetLength(Responses[i],NoVariables);
     end;
     for i := 1 to 5 do
     begin
          for j := 1 to NoVariables do
          begin
               RespWghts[i][j-1] := 1.0;
               Responses[i][j-1] := '1';
          end;
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

procedure TTestScoreFrm.ReturnBtnClick(Sender: TObject);
begin
  CancelBtnClick(self);
end;

procedure TTestScoreFrm.FormActivate(Sender: TObject);
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

procedure TTestScoreFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
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
VAR index : integer;
begin
     index := VarList.ItemIndex;
     if index < 0 then exit;
     IDNoEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     IDInBtn.Visible := false;
end;

procedure TTestScoreFrm.InBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     if VarList.ItemIndex < 0 then
     begin
          InBtn.Enabled := false;
          exit;
     end;
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            ItemList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     OutBtn.Enabled := true;
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
VAR index : integer;
begin
     index := VarList.ItemIndex;
     if index < 0 then exit;
     LastNameEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     LastInBtn.Visible := false;
end;

procedure TTestScoreFrm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
   index := ItemList.ItemIndex;
   if index < 0 then
   begin
        OutBtn.Enabled := false;
        exit;
   end;
   VarList.Items.Add(ItemList.Items.Strings[index]);
   ItemList.Items.Delete(index);
   InBtn.Enabled := true;
end;

procedure TTestScoreFrm.CancelBtnClick(Sender: TObject);
VAR i : integer;
begin
     for i := 1 to 5 do
     begin
          Responses[i] := nil;
          RespWghts[i] := nil;
     end;
     Data := nil;
     CorMat := nil;
     StdDevs := nil;
     Variances := nil;
     Means := nil;
     RowLabels := nil;
     ColLabels := nil;
     ColNoSelected := nil;

     Close;
end;

procedure TTestScoreFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, col, start, count : integer;
   cellstring : string;
begin
     OutputFrm.RichEdit.Clear;
     NoItems := ItemList.Items.Count;
     // Insure last item scoring definition is saved
     if FirstChk.Checked = false then ItemScroll.Position := 1;
     for i := 1 to NoItems do // items to analyze
     begin
          for j := 1 to NoVariables do // variables in grid
          begin
               cellstring := OS3MainFrm.DataGrid.Cells[j,0];
               if cellstring = ItemList.Items.Strings[i-1] then
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
          if isnumeric(OS3MainFrm.DataGrid.Cells[col,2]) then // second case
          begin
               if DictionaryFrm.DictGrid.Cells[5,col] <> '0' then
               begin
                    ShowMessage('Sorry, you must format cell values with 0 decimal parts.');
                    exit;
               end;
          end;
     end;

     // now score the responses
     ItemScores(self);

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

     // list the scores if elected
     if ListChk.Checked then ScoreReport(self);

     // get Cronbach Alpha reliability estimate if elected
     if AlphaChk.Checked then Alpha(self);

     // get intraclass reliabilities (Hoyt) if elected
     if HoytChk.Checked then Hoyt(self);

     // get step kr#20 if elected
     if StepChk.Checked then StepKR(self);

     // get interitem correlation matrix if elected
     if CorrsChk.Checked then Cors(self);

     // Get simultaneous multiple regressions if elected
     if SimultChk.Checked then SimMR(self);

     // plot subject scores if elected
     if PlotChk.Checked then PlotScores(self);

     // Plot item means if elected
     if MeansPlotChk.Checked then PlotMeans(self);
end;

procedure TTestScoreFrm.FirstChkClick(Sender: TObject);
begin
     if FirstChk.Checked then GroupBox2.Visible := false else
        GroupBox2.Visible := true;
end;

procedure TTestScoreFrm.FirstInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     if index < 0 then exit;
     FirstNameEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     FirstInBtn.Visible := false;
end;


procedure TTestScoreFrm.ItemScores(Sender: TObject);
var
   start, i, j, k, count, col : integer;
   score, denom, fract : double;
   response : string;

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
                          if SumRespBtn.Checked = true then
                          begin
                               score := score + RespWghts[k][j-1];
                               Data[count-1,j-1] := RespWghts[k][j-1];
                          end;
                          if NoCorBtn.Checked = true then
                          begin
                               score := score + 1;
                               Data[count-1,j-1] := 1;
                          end;
                         if FractWrongBtn.Checked = true then
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

procedure TTestScoreFrm.ScoreReport(Sender: TObject);
var
   i, start, count, col : integer;
   outline, namestr : string;

begin
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('TEST SCORING REPORT');
     OutputFrm.RichEdit.Lines.Add('');
     if FirstChk.Checked then start := 2 else start := 1;
     outline := '';
     if IDNoEdit.Text <> '' then outline := outline + 'PERSON ID NUMBER '
     else outline := outline + 'CASE            ';
     if FirstNameEdit.Text <> '' then outline := outline + 'FIRST NAME ';
     if LastNameEdit.Text <> '' then outline := outline + 'LAST NAME ';
     outline := outline + 'TEST SCORE';
     OutputFrm.RichEdit.Lines.Add(outline);
     count := 0;
     for i := start to NoCases do
     begin
          if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
          count := count + 1;
          outline := '';
          if IDNoEdit.Text <> '' then
          begin
               col := IDCol;
               namestr := Trim(OS3MainFrm.DataGrid.Cells[col,i]);
               outline := outline + format('%16s ',[namestr]);
          end
          else
          begin
               namestr := Trim(OS3MainFrm.DataGrid.Cells[0,i]);
               outline := outline + format('%-16s ',[namestr]);
          end;
          if FirstNameEdit.Text <> '' then
          begin
               col := FNameCol;
               namestr := Trim(OS3MainFrm.DataGrid.Cells[col,i]);
               outline := outline + format('%10s ',[namestr]);
          end;
          if LastNameEdit.Text <> '' then
          begin
               col := LNameCol;
               namestr := Trim(OS3MainFrm.DataGrid.Cells[col,i]);
               outline := outline + format('%10s ',[namestr]);
          end;
          outline := outline + format('%6.2f',[Data[count-1,NoItems]]);
          OutputFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.ShowModal;
end;

procedure TTestScoreFrm.Alpha(Sender: TObject);
var
   i, j : integer;
   AlphaRel, SEMeas : double;
   outline : string;

begin
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('');
     AlphaRel := 0.0;
     // get item variances
     for j := 1 to NoItems + 1 do
     begin
          Variances[j-1] := 0.0;
          Means[j-1] := 0.0;
     end;

     for j := 1 to NoItems + 1 do
     begin
          for i := 1 to NCases do
          begin
               Variances[j-1] := Variances[j-1] + sqr(Data[i-1,j-1]);
               Means[j-1] := Means[j-1] + Data[i-1,j-1];
          end;
     end;

     for j := 1 to NoItems + 1 do
     begin
          Variances[j-1] := Variances[j-1] - (sqr(Means[j-1]) / NCases);
          Variances[j-1] := Variances[j-1] / (NCases - 1);
          Means[j-1] := Means[j-1] / NCases;
     end;

     for i := 1 to NoItems do
     begin
          AlphaRel := AlphaRel + variances[i-1]; // sum of item variances
     end;
     AlphaRel  := AlphaRel / variances[NoItems];
     AlphaRel := 1.0 - AlphaRel;
     AlphaRel := (NoItems / (NoItems - 1.0)) * AlphaRel;
     if AlphaRel > 1.0 then AlphaRel := 1.0;
     SEMeas := sqrt(Variances[NoItems]) * sqrt(1.0 - AlphaRel);
     outline := format('Alpha Reliability Estimate for Test = %6.4f  S.E. of Measurement = %8.3f',
                [AlphaRel,SEMeas]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.ShowModal;
end;

procedure TTestScoreFrm.Cors(Sender: TObject);
var
   i, j, k : integer;
   title : string;
begin
     OutputFrm.RichEdit.Clear;
     for i := 1 to NoItems +1 do
     begin
          for j := 1 to NoItems + 1 do
          begin
               CorMat[i-1,j-1] := 0.0;
          end;
          Means[i-1] := 0.0;
          Variances[i-1] := 0.0;
     end;

     for i := 1 to NCases do
     begin
          for j := 1 to NoItems + 1 do
          begin
               for k := 1 to NoItems + 1 do
               begin
                    CorMat[j-1,k-1] := Cormat[j-1,k-1] + (Data[i-1,j-1] * Data[i-1,k-1]);
               end;
               Means[j-1] := Means[j-1] + Data[i-1,j-1];
               Variances[j-1] := Variances[j-1] + sqr(Data[i-1,j-1]);
          end;
     end;
     for i := 1 to NoItems + 1 do
     begin
          Variances[i-1] := Variances[i-1]  - (sqr(Means[i-1]) / NCases);
          Variances[i-1] := Variances[i-1] / (NCases - 1);
          StdDevs[i-1] := sqrt(Variances[i-1]);
     end;
     for i := 1 to NoItems + 1 do
     begin
          for j := 1 to NoItems + 1 do
          begin
               CorMat[i-1,j-1] := CorMat[i-1,j-1] - (Means[i-1] * Means[j-1] / NCases);
               CorMat[i-1,j-1] := CorMat[i-1,j-1] / (NCases - 1);
               if (StdDevs[i-1] > 0) and (StdDevs[j-1] > 0) then
                  CorMat[i-1,j-1] := CorMat[i-1,j-1] / (StdDevs[i-1] * StdDevs[j-1])
               else begin
                    ShowMessage('ERROR! A zero variance found.');
                    CorMat[i-1,j-1] := 99.99;
               end;
          end;
     end;
     for i := 1 to NoItems + 1 do Means[i-1] := Means[i-1] / NCases;
     if CorrsChk.Checked then
     begin
          title := 'Item and Total Score Intercorrelations';
          MAT_PRINT(CorMat,NoItems + 1,NoItems + 1,title,RowLabels,ColLabels,NCases);
     end;
     if DescChk.Checked then
     begin
          title := 'Means';
          DynVectorPrint(means,NoItems+1,title,ColLabels,NCases);
          title := 'Variances';
          DynVectorPrint(variances,NoItems+1,title,ColLabels,NCases);
          title := 'Standard Deviations';
          DynVectorPrint(stddevs,NoItems+1,title,ColLabels,NCases);
     end;
     if (CorrsChk.Checked) or (DescChk.Checked) then OutputFrm.ShowModal;
end;

procedure TTestScoreFrm.SimMR(Sender: TObject);
Label cleanup;
var
   i, j : integer;
   determinant, df1, df2, StdErr, x : double;
   outline, valstring : string;
   CorrMat : DblDyneMat;
   ProdMat : DblDyneMat;
   R2s : DblDyneVec;
   W : DblDyneVec;
   FProbs : DblDyneVec;
   errorcode : boolean = false;
   title : string;
begin
    SetLength(CorrMat,NoVariables+1,NoVariables+1);
    SetLength(R2s,NoVariables);
    SetLength(W,NoVariables);
    SetLength(FProbs,NoVariables);
    SetLength(ProdMat,NoVariables+1,NoVariables+1);

    OutputFrm.RichEdit.Clear;
    if CorrsChk.Checked = false then Cors(self);
    determinant := 0.0;
    for i := 0 to NoItems-1 do
        for j := 0 to NoItems-1 do
            CorrMat[i,j] := CorMat[i,j];
    Determ(CorrMat,NoItems,NoItems,determinant,errorcode);
    if (determinant < 0.000001) then
    begin
        ShowMessage('ERROR! Matrix is singular!');
        goto cleanup;
    end;
     outline := format('Determinant of correlation matrix = %8.4f',[determinant]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');
    for i := 0 to NoItems-1 do
        for j := 0 to NoItems-1 do
            CorrMat[i,j] := CorMat[i,j];
     SVDinverse(CorrMat,NoItems);

     OutputFrm.RichEdit.Lines.Add('Multiple Correlation Coefficients for Each Variable');
     OutputFrm.RichEdit.Lines.Add('');
     outline := format('%10s%8s%10s%10s%12s%5s%5s',['Variable','R','R2','F','Prob.>F','DF1','DF2']);
     OutputFrm.RichEdit.Lines.Add(outline);

     df1 := NoItems - 1.0;
     df2 := NCases - NoItems;

    for i := 0  to NoItems-1 do
    begin   // R squared values
    	R2s[i] := 1.0 - (1.0 / CorrMat[i,i]);
        W[i] := (R2s[i] / df1) / ((1.0-R2s[i]) / df2);
        FProbs[i] := probf(W[i],df1,df2);
        valstring := format('%10s',[ColLabels[i]]);
        outline := format('%10s%10.3f%10.3f%10.3f%10.3f%5.0f%5.0f',
        		[valstring,sqrt(R2s[i]),R2s[i],W[i],FProbs[i],df1,df2]);
        OutputFrm.RichEdit.Lines.Add(outline);
        for j := 0 to NoItems-1 do
        begin  // betas
        	ProdMat[i,j] := -CorrMat[i,j] / CorrMat[j,j];
        end;
    end;
    title := 'Betas in Columns';
    MAT_PRINT(ProdMat,NoItems,NoItems,title,RowLabels,ColLabels,NCases);
    OutputFrm.RichEdit.Lines.Add('Standard Errors of Prediction');
    OutputFrm.RichEdit.Lines.Add('Variable     Std.Error');
    for i := 0 to NoItems-1 do
    begin
    	StdErr := (NCases-1) * Variances[i] * (1.0 / CorrMat[i,i]);
        StdErr := sqrt(StdErr / (NCases - NoItems));
        valstring := format('%10s',[ColLabels[i]]);
        outline := format('%10s%10.3f',[valstring,StdErr]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;

    for i := 0 to NoItems-1 do
    	for j := 0 to NoItems-1 do
        	if (i <> j) then ProdMat[i,j] := ProdMat[i,j] * (StdDevs[j]/StdDevs[i]);
    title := 'Raw Regression Coefficients';
    MAT_PRINT(ProdMat,NoItems,NoItems,title,RowLabels,ColLabels,NCases);
    OutputFrm.RichEdit.Lines.Add('Variable   Constant');
    for i := 0 to NoItems-1 do
    begin
    	x := 0.0;
        for j := 0 to NoItems-1 do
        begin
        	if (i <> j) then x := x + (ProdMat[j,i] * Means[j]);
        end;
        x := Means[i] - x;
        valstring := format('%10s',[ColLabels[i]]);
        outline := format('%10s%10.3f',[valstring,x]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;

cleanup:
    ProdMat := nil;
    FProbs := nil;
    W := nil;
    R2s := nil;
    CorrMat := nil;

    OutputFrm.ShowModal;
end;

procedure TTestScoreFrm.Hoyt(Sender: TObject);
var
   i, j: integer;
   Hoyt1, Hoyt2, Hoyt3, Hoyt4, SEMeas1, SEMeas2, SEMeas3, SEMeas4 : double;
   SSError, SSCases, SSItems, SSWithin, TotalSS, TotalX, Constant : double;
   MSItems, MSWithin, MSTotal, MSCases, MSError, score, ItemTotal : double;
   F1, F2, prob1, prob2, dfcases, dfwithin, dferror, dftotal : double;
   dfitems : double;
   outline : string;
begin
    if CorrsChk.Checked = false then Cors(self);
     OutputFrm.RichEdit.clear;
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
     OutputFrm.RichEdit.Lines.Add('Analysis of Variance for Hoyt Reliabilities');
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('SOURCE    D.F.          SS        MS        F        PROB');
     outline := format('Subjects  %3.0f       %8.2f  %8.2f  %8.2f  %8.2f',
                [dfcases,SSCases,MSCases,F1,prob1]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('Within    %3.0f       %8.2f  %8.2f',
                [dfwithin,SSWithin,MSWithin]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('Items     %3.0f       %8.2f  %8.2f  %8.2f  %8.2f',
                [dfitems,SSItems,MSItems,F2,prob2]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('Error     %3.0f       %8.2f  %8.2f',
                [dferror,SSerror,MSerror]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('Total     %3.0f       %8.2f',
                [dftotal,TotalSS, MSTotal]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');
     Hoyt1 := 1.0 - (MSWithin / MSCases);
     Hoyt2 := (MSCases - MSError) / MSCases;
     Hoyt4 := (MSCases - MSError) /
              (MSCases + (NoItems-1.0)*MSError);
     Hoyt3 := (MSCases - MSWithin) /
                (MSCases + (NoItems-1.0) * MSWithin);
     SEMeas1 := stddevs[NoItems] * sqrt(1.0 - Hoyt1);
     outline := format('Hoyt Unadjusted Test Rel. for scale %s  = %6.4f  S.E. of Measurement = %8.3f',
                [ColLabels[NoItems],Hoyt1,SEMeas1]);
     OutputFrm.RichEdit.Lines.Add(outline);
     SEMeas2 := stddevs[NoItems] * sqrt(1.0 - Hoyt2);
     outline := format('Hoyt Adjusted Test Rel. for scale %s    = %6.4f  S.E. of Measurement = %8.3f',
                [ColLabels[NoItems],Hoyt2,SEMeas2]);
     OutputFrm.RichEdit.Lines.Add(outline);
     SEMeas3 := stddevs[NoItems] * sqrt(1.0 - Hoyt3);
     outline := format('Hoyt Unadjusted Item Rel. for scale %s  = %6.4f  S.E. of Measurement = %8.3f',
              [ColLabels[NoItems],Hoyt3,SEMeas3]);
     OutputFrm.RichEdit.Lines.Add(outline);
     SEMeas4 := stddevs[NoItems] * sqrt(1.0 - Hoyt4);
     outline := format('Hoyt Adjusted Item Rel. for scale %s    = %6.4f  S.E. of Measurement = %8.3f',
              [ColLabels[NoItems],Hoyt4,SEMeas4]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.ShowModal;
end;

procedure TTestScoreFrm.StepKR(Sender: TObject);
var
   i, j, col : integer;
   score, KR20, meanscore, scorevar, sumvars, hicor : double;
   selected : IntDyneVec;
   v1, v2, nselected, incount : integer;
   invalues : IntDyneVec;
   PtBis : DblDyneVec;
   outline : string;
   done : boolean;
begin
     SetLength(selected,NoVariables);
     SetLength(invalues,NoVariables);
     SetLength(PtBis,NoVariables);
     Cors(self);
     OutputFrm.RichEdit.Clear;
     v1 := 0;
     v2 := 0;
     nselected := NoItems;
     for i := 1 to nselected do selected[i-1] := i;
     // pick highest correlation for items to start
     hicor := -1.0;
     for i := 1 to nselected - 1 do
     begin
          for j := i + 1 to nselected do
          begin
               if CorMat[i-1,j-1] > hicor then
               begin
                    hicor := CorMat[i-1,j-1];
                    v1 := i;
                    v2 := j;
               end;
          end;
     end;
     invalues[0] := v1; // cor matrix col
     invalues[1] := v2; // cor matrix row
     incount := 2;
     // now add items based on highest pt.bis. with subscores
     done := false;
     repeat
     begin
          meanscore := 0.0;
          scorevar := 0.0;
          sumvars := 0.0;
          for j := 1 to nselected do PtBis[j-1] := 0.0;
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
               end else PtBis[j-1] := 0.0;
          end;
          meanscore := meanscore / NCases;
          // get sum of item variances
          for j := 1 to incount do sumvars := sumvars + Variances[invalues[j-1]-1];
          KR20 := (incount / (incount - 1)) * (1.0 - sumvars / scorevar);
          outline := format('KR#20 = %6.4f for the test with mean = %6.3f and variance = %6.3f',
                    [KR20,meanscore, scorevar]);
          OutputFrm.RichEdit.Lines.Add(outline);
          outline := 'Item  Mean    Variance   Pt.Bis.r';
          OutputFrm.RichEdit.Lines.Add(outline);
          for j := 1 to incount do
          begin
               outline := format('%3d   %6.3f  %6.3f     %6.4f',
                           [selected[invalues[j-1]-1],Means[invalues[j-1]-1],Variances[invalues[j-1]-1],PtBis[invalues[j-1]-1]]);
               OutputFrm.RichEdit.Lines.Add(outline);
          end;
          if incount = nselected then done := true else
          begin
               hicor := -1.0;
               for j := 1 to incount do PtBis[invalues[j-1]-1] := -2.0;
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
     end;
     until done;
     OutputFrm.ShowModal;

     // cleanup
     PtBis := nil;
     invalues := nil;
     selected := nil;
end;


procedure TTestScoreFrm.PlotScores(Sender: TObject);
var
   rowvar : DblDyneVec;
   totscrs : DblDyneVec;
   i, j : integer;
   temp : double;

begin
       SetLength(rowvar,NoCases);
       SetLength(totscrs,NoCases);
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
                      temp := totscrs[j-1];
                      totscrs[j-1] := totscrs[i-1];
                      totscrs[i-1] := temp;
                      temp := rowvar[j-1];
                      rowvar[j-1] := rowvar[i-1];
                      rowvar[i-1] := temp;
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
//       GraphFrm.Ypoints[1] := totscrs;
//       GraphFrm.Xpoints[1] := rowvar;
       GraphFrm.barwideprop := 0.5;
       GraphFrm.AutoScaled := true;
       GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
       GraphFrm.BackColor := clYellow;
       GraphFrm.WallColor := clBlack;
       GraphFrm.FloorColor := clLtGray;
       GraphFrm.ShowBackWall := true;
       GraphFrm.ShowModal;

       rowvar := nil;
       totscrs := nil;
       GraphFrm.Xpoints := nil;
       GraphFrm.Ypoints := nil;
end;


procedure TTestScoreFrm.PlotMeans(Sender: TObject);
var
   rowvar : DblDyneVec;
   i : integer;
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
       GraphFrm.BackColor := clYellow;
       GraphFrm.WallColor := clBlack;
       GraphFrm.FloorColor := clLtGray;
       GraphFrm.ShowBackWall := true;
       GraphFrm.ShowModal;

       rowvar := nil;
       GraphFrm.Xpoints := nil;
       GraphFrm.Ypoints := nil;
end;



initialization
  {$I testscoreunit.lrs}

end.

