unit Concordance;

{$MODE Delphi}

interface

uses
  LCLIntf, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, OS3MainUnit, GLOBALS, OUTPUTUNIT, DATAPROCS, Math,
  FUNCTIONSLIB, LResources;

type
  TConcordFrm = class(TForm)
    Label1: TLabel;
    VarList: TListBox;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    Label2: TLabel;
    ListBox1: TListBox;
    ResetBtn: TButton;
    CancelBtn: TButton;
    OKBtn: TButton;
    ComputeBtn: TButton;
    Memo1: TMemo;
    procedure ResetBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConcordFrm: TConcordFrm;

implementation


procedure TConcordFrm.ResetBtnClick(Sender: TObject);
var
   i: integer;
begin
     VarList.Clear;
     ListBox1.Clear;
     for i := 1 to NoVariables do
     begin
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     end;
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
end;
//-------------------------------------------------------------------

procedure TConcordFrm.FormShow(Sender: TObject);
begin
     ResetBtnClick(self);
end;
//-------------------------------------------------------------------

procedure TConcordFrm.CancelBtnClick(Sender: TObject);
begin
     ConcordFrm.Hide;
end;
//-------------------------------------------------------------------

procedure TConcordFrm.OKBtnClick(Sender: TObject);
begin
     ConcordFrm.Hide;
end;
//-------------------------------------------------------------------

procedure TConcordFrm.InBtnClick(Sender: TObject);
var
   index, i : integer;

begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            ListBox1.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;

     OutBtn.Enabled := true;
end;
//-------------------------------------------------------------------

procedure TConcordFrm.OutBtnClick(Sender: TObject);
var
   index: integer;

begin
   index := ListBox1.ItemIndex;
   VarList.Items.Add(ListBox1.Items.Strings[index]);
   ListBox1.Items.Delete(index);
   InBtn.Enabled := true;
end;
//-------------------------------------------------------------------

procedure TConcordFrm.AllBtnClick(Sender: TObject);
var
   count, index : integer;
begin
     count := VarList.Items.Count;
     if count = 0 then exit;
     for index := 0 to count-1 do
     begin
          ListBox1.Items.Add(VarList.Items.Strings[index]);
     end;
     VarList.Clear;
     InBtn.Visible := false;
     OutBtn.Visible := true;
end;
//-------------------------------------------------------------------

procedure TConcordFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k, index, No_Judges, No_Objects, col, ties, start, last : integer;
   NoSelected : integer;
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

begin
    No_Judges := 0;
    No_Objects := ListBox1.Items.Count;

    // Allocate space for selected variable column no.s
    SetLength(scorearray,NoCases,No_Objects);
    SetLength(tempindex,No_Objects);
    SetLength(temprank,No_Objects);
    SetLength(ObjRankSums,No_Objects);
    SetLength(ColLabels,NoVariables);
    SetLength(ColNoSelected,NoVariables);

    // get columns of variables selected
    for i := 0 to No_Objects - 1 do
    begin
        cellstring := ListBox1.Items.Strings[i];
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
        for i := 0 to No_Judges-1 do ObjRankSums[j] := ObjRankSums[j] + scorearray[i,j];
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
    OutPutFrm.RichEdit.Clear;
    OutPutFrm.RichEdit.Lines.Add('Kendall Coefficient of Concordance Analysis');
    OutPutFrm.RichEdit.Lines.Add('');
    OutPutFrm.RichEdit.Lines.Add('Ranks Assigned to Judge Ratings of Objects');
    OutPutFrm.RichEdit.Lines.Add('');

    for i := 1 to No_Judges do
    begin
        done := false;
        start := 1;
        last := 10;
        while (not done) do
        begin
            if (last > No_Objects)then last := No_Objects;
            outline := format('Judge %3d',[i]);
            outline := outline + '            Objects';
            OutPutFrm.RichEdit.Lines.Add(outline);
            outline := ' ';
            for j := start to last do
            begin
                col := ColNoSelected[j-1];
                outline := outline + format('%8s',[ColLabels[col-1]]);
            end;
            OutPutFrm.RichEdit.Lines.Add(outline);
            outline := ' ';
            for j := start to last do
            begin
                value := format('%8.4f',[scorearray[i-1,j-1]]);
                outline := outline + value;
            end;
            OutPutFrm.RichEdit.Lines.Add(outline);
            if (last = No_Objects) then done := true
            else begin
                start := last;
                last := start + 10;
            end;
            outline := '';
        end; // while end
        OutPutFrm.RichEdit.Lines.Add('');
    end; // next i

    OutPutFrm.RichEdit.Lines.Add('');
    OutPutFrm.RichEdit.Lines.Add('Sum of Ranks for Each Object Judged');
    done := false;
    start := 1;
    last := 10;
    while (not done) do
    begin
        if (last > No_Objects) then last := No_Objects;
        OutPutFrm.RichEdit.Lines.Add('            Objects');
        outline := ' ';
        for j := start to last do
        begin
            col := ColNoSelected[j-1];
            value := format('%8s',[ColLabels[col-1]]);
            outline := outline + value;
        end;
        OutPutFrm.RichEdit.Lines.Add(outline);
        outline := ' ';
        for j := start to last do
        begin
            value := format('%8.4f',[ObjRankSums[j-1]]);
            outline := outline + value;
        end;
        OutPutFrm.RichEdit.Lines.Add(outline);
        OutPutFrm.RichEdit.Lines.Add('');
        if (last = No_Objects) then done := true
        else begin
            start := last;
            last := start + 10;
        end;
    end;
    outline := format('Coefficient of concordance := %10.3f',[Concordance]);
    OutPutFrm.RichEdit.Lines.Add(outline);
    outline := format('Average Spearman Rank Correlation := %10.3f',[AvgRankCorr]);
    OutPutFrm.RichEdit.Lines.Add(outline);
    outline := format('Chi-Square Statistic := %8.3f',[ChiSquare]);
    OutPutFrm.RichEdit.Lines.Add(outline);
    outline := format('Probability of a larger Chi-Square := %6.4f',[Probability]);
    OutPutFrm.RichEdit.Lines.Add(outline);
    if (No_Objects < 7) then
        OutPutFrm.RichEdit.Lines.Add('Warning - Above Chi-Square is very approximate with 7 or fewer variables!');
    OutPutFrm.ShowModal;

    // cleanup
    ColNoSelected := nil;
    ColLabels := nil;
    ObjRankSums := nil;
    temprank := nil;
    tempindex := nil;
    scorearray := nil;
end;
//-------------------------------------------------------------------

initialization
  {$i concordance.lrs}
  {$i CONCORDANCE.lrs}

end.
