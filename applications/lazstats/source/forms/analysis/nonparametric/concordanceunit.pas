unit ConcordanceUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, OutputUnit, DataProcs, FunctionsLib, ContextHelpUnit;

type

  { TConcordFrm }

  TConcordFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    SelList: TListBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  ConcordFrm: TConcordFrm;

implementation

uses
  Math;

{ TConcordFrm }

procedure TConcordFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     SelList.Clear;
     for i := 1 to NoVariables do
     begin
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     end;
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
end;

procedure TConcordFrm.FormActivate(Sender: TObject);
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

  FAutoSized := false;
end;

procedure TConcordFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TConcordFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TConcordFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TConcordFrm.AllBtnClick(Sender: TObject);
var
  index: integer;
begin
  for index := 0 to VarList.Count-1 do
    SelList.Items.Add(VarList.Items[index]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TConcordFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k, index, No_Judges, No_Objects, col, ties, start, last : integer;
   Temp, TotalCorrect, JudgeCorrect, ChiSquare, Probability : double;
   TotalRankSums, Concordance, AvgRankCorr, AvgTotalRanks : double;
   statistic : double;
   scorearray : DblDyneMat;
   temprank, ObjRankSums : DblDyneVec;
   tempindex : IntDyneVec;
   done : boolean;
   value, cellstring, outline : string;
   ColNoSelected : IntDyneVec;
   ColLabels : StrDyneVec;
   lReport: TStrings;
begin
  if SelList.Items.Count = 0 then
  begin
    MessageDlg('No variables selected.', mtError, [mbOK], 0);
    exit;
  end;

  No_Judges := 0;
  No_Objects := SelList.Items.Count;

  // Allocate space for selected variable column no.s
  SetLength(scorearray, NoCases, No_Objects);
  SetLength(tempindex, No_Objects);
  SetLength(temprank, No_Objects);
  SetLength(ObjRankSums, No_Objects);
  SetLength(ColLabels, NoVariables);
  SetLength(ColNoSelected, NoVariables);

  // get columns of variables selected
  for i := 0 to No_Objects - 1 do
  begin
      cellstring := SelList.Items.Strings[i];
      for index := 1 to NoVariables do
      begin
          if (cellstring = OS3MainFrm.DataGrid.Cells[index,0]) then
          begin
              ColNoSelected[i] := index;
              ColLabels[i] := cellstring;
          end;
      end;
  end;

  //Read data from grid
  for i := 1 to NoCases do
  begin
      if (not GoodRecord(i,No_Objects,ColNoSelected)) then continue;
      No_Judges := No_Judges + 1;
      for j := 1 to No_Objects do
      begin
          col := ColNoSelected[j-1];
          scorearray[i-1,j-1] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
      end;
  end;

  //Rank the scores in the rows for each judge (column)
  TotalCorrect := 0.0;
  for i := 0 to No_Judges-1 do
  begin
      JudgeCorrect := 0.0;
      for j := 0 to No_Objects-1 do
      begin
          tempindex[j] := j;
          temprank[j] := scorearray[i,j];
      end;
      //Sort the temp arrays
      for j := 0 to No_Objects - 2 do
      begin
          for k := j + 1 to No_Objects - 1 do
          begin
              if (temprank[j] > temprank[k]) then
              begin
                  Temp := temprank[j];
                  temprank[j] := temprank[k];
                  temprank[k] := Temp;
                  index := tempindex[j];
                  tempindex[j] := tempindex[k];
                  tempindex[k] := index;
              end;
          end;
      end;

      //Now convert temporary score array to ranks (correcting for ties)
      j := 0;
      while (j <= No_Objects-1) do
      begin
          ties := 0;
          k := j;
          done := false;
          while (not done) do
          begin
              k := k + 1;
              if (k <= No_Objects-1) then
              begin
                  if (temprank[j] = temprank[k]) then ties := ties + 1;
              end
              else done := true;
          end;
          if (ties = 0.0) then
          begin
              temprank[j] := j+1;
              j := j + 1;
          end
          else begin
              for k := j to j + ties do
              begin
                  temprank[k] := (j+1) + (ties / 2.0);
              end;
              j := j + ties + 1;
              ties := ties + 1;
              JudgeCorrect := JudgeCorrect + (Power(ties,3) - ties);
          end;
      end;

      //Now, restore ranks in their position equivalent to original scores
      for j := 0 to No_Objects-1 do
      begin
          k := tempindex[j];
          scorearray[i,k] := temprank[j];
      end;
      TotalCorrect := TotalCorrect + (JudgeCorrect / 12.0);
  end; // next judge i

  //Calculate statistics
  statistic := 0.0;
  TotalRankSums := 0.0;
  for j := 0 to No_Objects-1 do
  begin
      ObjRankSums[j] := 0.0;
      for i := 0 to No_Judges-1 do
        ObjRankSums[j] := ObjRankSums[j] + scorearray[i,j];
      TotalRankSums := TotalRankSums + ObjRankSums[j];
  end;
  AvgTotalRanks := TotalRankSums / No_Objects;
  for j := 0 to No_Objects-1 do
      statistic := statistic + Power((ObjRankSums[j] - AvgTotalRanks), 2);
  Concordance := statistic / ( ((No_Judges * No_Judges) / 12.0) *
     (Power(No_Objects,3) - No_Objects) - (No_Judges * TotalCorrect) );
  AvgRankCorr := (No_Judges * Concordance - 1.0) / (No_Judges - 1);
  ChiSquare := No_Judges * Concordance * (No_Objects - 1);
  Probability := 1.0 - chisquaredprob(ChiSquare, No_Objects - 1);

  //Report results
  lReport := TStringList.Create;
  try
    lReport.Add('KENDALL COEFFICIENT OF CONCORDANCE ANALYSIS');
    lReport.Add('');
    lReport.Add('Ranks Assigned to Judge Ratings of Objects');
    lReport.Add('');

    for i := 1 to No_Judges do
    begin
        done := false;
        start := 1;
        last := 10;
        while not done do
        begin
            if (last > No_Objects)then last := No_Objects;
            outline := format('Judge %3d',[i]);
            outline := outline + '            Objects';
            lReport.Add(outline);

            outline := ' ';
            for j := start to last do
            begin
                col := ColNoSelected[j-1];
                outline := outline + format('%8s',[ColLabels[col-1]]);
            end;
            lReport.Add(outline);

            outline := ' ';
            for j := start to last do
            begin
                value := format('%8.4f',[scorearray[i-1,j-1]]);
                outline := outline + value;
            end;
            lReport.Add(outline);
            if (last = No_Objects) then
                done := true
            else begin
                start := last;
                last := start + 10;
            end;
            outline := '';
        end; // while end
        lReport.Add('');
    end; // next i

    lReport.Add('');
    lReport.Add('Sum of Ranks for Each Object Judged');
    done := false;
    start := 1;
    last := 10;
    while (not done) do
    begin
        if (last > No_Objects) then last := No_Objects;
        lReport.Add('            Objects');
        outline := ' ';
        for j := start to last do
        begin
            col := ColNoSelected[j-1];
            value := Format('%8s', [ColLabels[col-1]]);
            outline := outline + value;
        end;
        lReport.Add(outline);
        outline := ' ';
        for j := start to last do
        begin
            value := Format('%8.4f',[ObjRankSums[j-1]]);
            outline := outline + value;
        end;
        lReport.Add(outline);
        lReport.Add('');
        if (last = No_Objects) then
            done := true
        else begin
            start := last;
            last := start + 10;
        end;
    end;
    lReport.Add('Coefficient of concordance:         %10.3f', [Concordance]);
    lReport.Add('Average Spearman Rank Correlation:  %10.3f', [AvgRankCorr]);
    lReport.Add('Chi-Square Statistic:               %10.3f', [ChiSquare]);
    lReport.Add('Probability of a larger Chi-Square: %11.4f',[Probability]);
    if (No_Objects < 7) then
        lReport.Add('Warning - Above Chi-Square is very approximate with 7 or fewer variables!');

    DisplayReport(lReport);

  finally
    lReport.Free;
    ColNoSelected := nil;
    ColLabels := nil;
    ObjRankSums := nil;
    temprank := nil;
    tempindex := nil;
    scorearray := nil;
  end;
end;

procedure TConcordFrm.InBtnClick(Sender: TObject);
var
   i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      SelList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TConcordFrm.OutBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := SelList.ItemIndex;
  if (index > -1) then
  begin
    VarList.Items.Add(SelList.Items[index]);
    SelList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TConcordFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  lSelected := false;
  for i := 0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to SelList.Items.Count-1 do
    if SelList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;
  AllBtn.Enabled := VarList.Count > 0;
end;

procedure TConcordFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I concordanceunit.lrs}

end.

