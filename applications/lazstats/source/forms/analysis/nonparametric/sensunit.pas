unit SensUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit,
  ContextHelpUnit, MatrixLib, GraphLib;

type

  { TSensForm }

  TSensForm = class(TForm)
    AllBtn: TBitBtn;
    AlphaEdit: TEdit;
    Bevel1: TBevel;
    CancelBtn: TButton;
    Memo1: TLabel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    InBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SelectedList: TListBox;
    OutBtn: TBitBtn;
    VarList: TListBox;
    PrtRanksChk: TCheckBox;
    PrtSlopesChk: TCheckBox;
    PrtDataChk: TCheckBox;
    GroupBox3: TGroupBox;
    SlopesChk: TCheckBox;
    PlotChk: TCheckBox;
    GroupBox2: TGroupBox;
    StandardizeChk: TCheckBox;
    AvgSlopeChk: TCheckBox;
    GroupBox1: TGroupBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  SensForm: TSensForm;

implementation

uses
  Math;

{ TSensForm }

procedure TSensForm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     AlphaEdit.Text := '0.05';
     StandardizeChk.Checked := false;
     PlotChk.Checked := false;
     SlopesChk.Checked := false;
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
     AvgSlopeChk.Checked := false;
     SelectedList.Clear;
     VarList.Clear;
     for i := 1 to NoVariables do VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TSensForm.InBtnClick(Sender: TObject);
VAR index, i : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            SelectedList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     OutBtn.Enabled := true;
end;

procedure TSensForm.AllBtnClick(Sender: TObject);
VAR count, i : integer;
begin
     count := VarList.Items.Count;
     if count <= 0 then exit;
     for i := 0 to VarList.Items.Count-1 do
          SelectedList.Items.Add(VarList.Items.Strings[i]);
     VarList.Clear;
     OutBtn.Enabled := true;
     InBtn.Enabled := false;
end;

procedure TSensForm.ComputeBtnClick(Sender: TObject);
VAR
  NoVars, noselected, count, half, q, tp, low, hi, col : integer;
  Values, Slopes, AvgSlopes : DblDyneMat;
  RankedQ, Sorted : DblDyneVec;
  RowLabels, ColLabels, RankLabels : StrDyneVec;
  selected : IntDyneVec;
  temp, MedianSlope, MannKendall, Z, C, M1, M2, Alpha, mean, stddev : double;
  cellstring, outline : string;
  i, j, k, no2do : integer;
  Standardize, Plot, SlopePlot, AvgSlope : boolean;

begin
     Standardize := false;
     Plot := false;
     SlopePlot := false;
     AvgSlope := false;

     if StandardizeChk.Checked then Standardize := true;
     if PlotChk.Checked then Plot := true;
     if SlopesChk.Checked then SlopePlot := true;
     if AvgSlopeChk.Checked then AvgSlope := true;
     Alpha := 1.0 - StrToFloat(AlphaEdit.Text);
     noselected := SelectedList.Items.Count;
     if noselected = 0 then
     begin
        ShowMessage('ERROR!  First select variables to analyze.');
        exit;
     end;
     SetLength(RowLabels,NoCases);
     SetLength(ColLabels,NoCases);
     SetLength(selected,noselected);
     SetLength(Values,NoCases,noselected+1);
     SetLength(Slopes,NoCases,NoCases);
     SetLength(RankedQ,NoVars);
     SetLength(Sorted,NoCases);
     SetLength(AvgSlopes,NoCases,NoCases);

     for i := 0 to NoCases-1 do
          begin
              RowLabels[i] := OS3MainFrm.DataGrid.Cells[0,i+1];
              ColLabels[i] := RowLabels[i];
              for j := 0 to NoCases-1 do Slopes[i,j] := 0.0;
          end;

     // get selected variables
     for i := 1 to noselected do
          begin
              cellstring := SelectedList.Items.Strings[i-1];
              for j := 1 to NoVariables do
                   if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
                      selected[i-1] := j;
          end;

     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Sens Detection and Estimation of Trends');
     outline := format('Number of data points = %d, Confidence Interval = %4.2f',
        [NoCases,Alpha]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');

     //Get the data
     if AvgSlope then for i := 0 to NoCases-1 do Values[i,noselected] := 0.0;
     for j := 0 to noselected-1 do
          begin
              col := selected[j];
              for i := 1 to NoCases do
                   begin
                       Values[i-1,j] := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i])));
                       if AvgSlope then Values[i-1,noselected] := Values[i-1,noselected] +
                          Values[i-1,j];
                   end;
          end;

     if PrtDataChk.Checked then
     begin
        outline:= 'CASE';
        MAT_PRINT(Values,NoCases,noselected,outline,RowLabels,ColLabels,NoCases);
        OutputFrm.ShowModal;
     end;

     // standardize if more than one variable and standardization elected
     if (noselected > 1) and (standardize = true) then
     begin
        for j := 0 to noselected-1 do
             begin
                  mean := 0.0;
                  stddev := 0.0;
                  for i := 0 to NoCases-1 do
                       begin
                           mean := mean + Values[i,j];
                           stddev := stddev + (Values[i,j] * Values[i,j]);
                       end;
                       stddev := stddev - (mean * mean) / NoCases;
                       stddev := stddev / (NoCases -  1);
                       stddev := sqrt(stddev);
                       mean := mean / NoCases;
                       for i := 0 to NoCases-1 do
                                Values[i,j] := (Values[i,j] - mean)/ stddev;
                       col := selected[j];
                       outline := format('Variable = %s, mean = %8.3f, standard deviation = %8.3f',
                               [OS3MainFrm.DataGrid.Cells[col,0],mean,stddev]);
                       OutputFrm.RichEdit.Lines.Add(outline);
             end;
     end;

     // average the values if elected
     if AvgSlope then for i := 0 to NoCases - 1 do Values[i,noselected] :=
        Values[i,noselected] / noselected;

     // get interval slopes
     no2do := noselected;
     if AvgSlope then no2do := no2do + 1;
     for j := 0 to no2do - 1 do
          begin
              if j < noselected then
              begin
                 col := selected[j];
                 cellstring := OS3MainFrm.DataGrid.Cells[col,0];
              end
              else
              begin
                  col := 0;
                  cellstring := 'Combined Scores';
              end;
              for i := 0 to NoCases-2 do
                   begin
                       for k := i + 1 to NoCases-1 do
                            Slopes[i,k] := (Values[k,j] - Values[i,j]) / (k-i);
                   end;
              if PrtSlopesChk.Checked then
              begin
                   outline := 'CASE';
                   MAT_PRINT(Slopes,NoCases,NoCases,outline,RowLabels,ColLabels,NoCases);
              end;

              // get ranked slopes and median estimator
              count := 0;
              for i := 0 to NoCases-2 do
                  begin
                       for k := i+1 to NoCases-1 do
                           begin
                                RankedQ[count] := Slopes[i,k];
                                count := count + 1;
                           end;
                  end;

              //sort into ascending order
              for i := 0 to count - 2 do
                  begin
                       for k := i + 1 to count-1 do
                       begin
                            if RankedQ[i] > RankedQ[k] then
                            begin
                                 temp := RankedQ[i];
                                 RankedQ[i] := RankedQ[k];
                                 RankedQ[k] := temp;
                            end;
                       end;
                  end;

              if PrtRanksChk.Checked then
              begin
                   SetLength(RankLabels,count);
                   for k := 0 to count-1 do RankLabels[k] := IntToStr(k+1);
                   OutputFrm.RichEdit.Lines.Add('Ranked Slopes');
                   for i := 0 to count-1 do
                   begin
                        outline := format('Label = %s, Ranked Q = %8.3f',
                                [RankLabels[i],RankedQ[i]]);
                        OutputFrm.RichEdit.Lines.Add(outline);
                   end;
                   OutputFrm.ShowModal;
                   RankLabels := nil;
              end;

              // get median slope
              half := count div 2;
              if (2 * half) < count then MedianSlope := RankedQ[half]
              else MedianSlope := (RankedQ[half-1] + RankedQ[half]) / 2.0;

              // get Mann-Kendall statistic based on tied values
              for i := 0 to NoCases-1 do Sorted[i] := Values[i,j];
              for i := 0 to NoCases-2 do
                  begin
                       for k := i+1 to NoCases-1 do
                           begin
                               if Sorted[i] > Sorted[k] then
                               begin
                                 temp := Sorted[i];
                                 Sorted[i] := Sorted[k];
                                 Sorted[k] := temp;
                               end;
                           end;
                  end;

                  MannKendall := 0.0;
                  q := 0;
                  i := -1;
                  while (i < NoCases-2) do
                      begin
                          i := i + 1;
                          tp := 1; // no. of ties for pth (i) value
                          for k := i + 1 to NoCases-1 do
                              begin
                                  if Sorted[k] <> Sorted[i] then
                                  begin
                                    i := k-1;
                                    break;
                                  end
                                  else tp := tp + 1;
                              end; // next k
                          if tp > 1 then
                          begin
                            q := q + 1;
                            MannKendall := MannKendall + (tp * (tp-1) * (2 * tp + 5));
                          end;
                      end; // end next i
                  MannKendall := (NoCases * (NoCases-1) * (2 * NoCases + 5) -
                     MannKendall) / 18.0;
                  Z := inversez(Alpha);
                  if MannKendall > 0 then
                  begin
                    C := Z * sqrt(MannKendall);
                    M1 := (count - C) / 2.0;
                    M2 := (count + C) / 2.0;
                  end
                  else begin
                      outline := format('Error: z = %8.3f, Mann-Kendall = %8.3f',
                         [Z,MannKendall]);
                      OutputFrm.RichEdit.Lines.Add(outline);
                  end;

                  // show results
                  if j < noselected then
                  begin
                     outline := format('Results for %s',[cellstring]);
                     OutputFrm.RichEdit.Lines.Add(outline);
                  end
                  else
                    OutputFrm.RichEdit.Lines.Add('Results for Averaged Values');
                  if (noselected > 1) and (Standardize = true) then
                  begin
                    mean := 0.0;
                    stddev := 0.0;
                    for i := 0 to NoCases-1 do
                        begin
                            mean := mean + Values[i,j];
                            stddev := stddev + (Values[i,j] * Values[i,j]);
                        end;
                    stddev := stddev - (mean * mean) / NoCases;
                    stddev := stddev / (NoCases - 1);
                    stddev := sqrt(stddev);
                    mean := mean / NoCases;
                    outline := format('Mean = %8.3f, Standard Deviation = %8.3f',
                      [mean,stddev]);
                    OutputFrm.RichEdit.Lines.Add(outline);
                  end;
                  outline := format('Median Slope for %d values = %8.3f',
                    [count,MedianSlope]);
                  OutputFrm.RichEdit.Lines.Add(outline);
                  outline := format('Mann-Kendall Variance statistic = %8.3f (%d ties)',
                    [MannKendall,q]);
                  OutputFrm.RichEdit.Lines.Add(outline);
                  outline := format('Ranks of the lower and upper confidence = %8.3f, %8.3f',
                    [M1, M2+1]);
                  OutputFrm.RichEdit.Lines.Add(outline);
                  low := round(M1 - 1.0);
                  if ((M1-1) - low) > 0.5 then low := round(M1-1);
                  hi := round(M2);
                  if (M2 - hi) > 0.5 then hi := round(M2);
                  if (low > 0) or (hi <= count) then
                  begin
                    outline := format('Corresponding lower and upper slopes = %8.3f, %8.3f',
                      [RankedQ[low],RankedQ[hi]]);
                    OutputFrm.RichEdit.Lines.Add(outline);
                  end
                  else begin
                      outline := format('ERROR! low rank = %d, hi rank = %d',
                        [low, hi]);
                      OutputFrm.RichEdit.Lines.Add(outline);
                  end;
                  OutputFrm.RichEdit.Lines.Add('');

                  // plot slopes if elected
                  if Plot then
                  begin
                    SetLength(GraphFrm.Xpoints,1,NoCases+1);
                    SetLength(GraphFrm.Ypoints,1,NoCases+1);
                    GraphFrm.GraphType := 2;
                    GraphFrm.nosets := 1;
                    GraphFrm.nbars := NoCases;
                    GraphFrm.BackColor := clYellow;
                    GraphFrm.WallColor := clBlue;
                    GraphFrm.FloorColor := clGray;
                    if j < noselected then GraphFrm.Heading := OS3MainFrm.DataGrid.Cells[col,0]
                    else GraphFrm.Heading := 'Average Values';
                    GraphFrm.barwideprop := 1.0;
                    GraphFrm.AutoScaled := true;
                    GraphFrm.ShowLeftWall := true;
                    GraphFrm.ShowRightWall := true;
                    GraphFrm.ShowBottomWall := true;
                    GraphFrm.YTitle := 'Measure';
                    GraphFrm.XTitle := 'Time';
                    for k := 0 to NoCases - 1 do
                        begin
                            GraphFrm.Ypoints[0,k] := Values[k,j];
                            GraphFrm.Xpoints[0,k] := k+1;
                        end;
                    GraphFrm.ShowModal;
                    GraphFrm.Ypoints := nil;
                    GraphFrm.Xpoints := nil;
                  end;

                  // plot ranked slopes if elected
                  if SlopePlot then
                  begin
                    SetLength(GraphFrm.Xpoints,1,count+1);
                    SetLength(GraphFrm.Ypoints,1,count+1);
                    GraphFrm.GraphType := 2;
                    GraphFrm.nosets := 1;
                    GraphFrm.nbars := count;
                    GraphFrm.BackColor := clYellow;
                    GraphFrm.WallColor := clBlue;
                    GraphFrm.FloorColor := clGray;
                    GraphFrm.Heading := 'Ranked Slopes';
                    GraphFrm.barwideprop := 1.0;
                    GraphFrm.AutoScaled := true;
                    GraphFrm.ShowLeftWall := true;
                    GraphFrm.ShowRightWall := true;
                    GraphFrm.ShowBottomWall := true;
                    GraphFrm.YTitle := 'Slope';
                    GraphFrm.XTitle := 'Rank';
                    for k := 0 to count - 1 do
                        begin
                            GraphFrm.Ypoints[0,k] := RankedQ[k];
                            GraphFrm.Xpoints[0,k] := k+1;
                        end;
                    GraphFrm.ShowModal;
                    GraphFrm.Ypoints := nil;
                    GraphFrm.Xpoints := nil;
                  end;
                  OutputFrm.ShowModal;
                  OutputFrm.RichEdit.Clear;
          end; // next variable j

     if AvgSlope then
     begin
       for i := 0 to NoCases-2 do
           begin
           for k := i + 1 to NoCases-1 do
               begin
                    AvgSlopes[i,k] := AvgSlopes[i,k] + Slopes[i,k];
               end;
           end;
     end;

     // Average multiple measures
     if AvgSlope then
     begin
       OutputFrm.RichEdit.Lines.Add('Results for Averaged Slopes');
       for i := 0 to NoCases-2 do
           begin
               for k := i + 1 to NoCases-1 do
                   AvgSlopes[i,k] := AvgSlopes[i,k] / noselected;
           end;

           // get ranked slopes and median estimator
           count := 0;
           for i := 0 to NoCases-2 do
           begin
                for j := i + 1 to NoCases-1 do
                    begin
                         RankedQ[count] := AvgSlopes[i,j];
                         count := count + 1;
                    end;
           end;
           for i := 0 to Count-2 do
               begin
                    for j := i + 1 to count - 1 do
                        begin
                             if RankedQ[i] > RankedQ[j] then
                                begin
                                     temp := RankedQ[i];
                                     RankedQ[i] := RankedQ[j];
                                     RankedQ[j] := temp;
                                end;
                        end;
               end;
           // get median slope
           half := count div 2;
           if (2 * half) < count then MedianSlope := RankedQ[half + 1]
           else MedianSlope := (RankedQ[half] + RankedQ[half+1]) / 2.0;
           // get Mann-Kendall statistic based on tied values
           MannKendall := 0.0;
           q := 0;
           i := -1;
           while (i < count-1) do
              begin
                   i := i + 1;
                   tp := 1; // no. of ties for pth (i) value
                   for j := i + 1 to count-1 do
                       begin
                            if RankedQ[j] <> RankedQ[i] then
                               begin
                                    i := j - 1;
                                    break;
                               end
                               else tp := tp + 1;
                       end;
                       if tp > 1 then
                          begin
                               q := q + 1;
                               MannKendall := MannKendall + (tp * (tp-1) * (2 * tp + 5));
                          end;
              end; // end do while
              MannKendall := (NoCases * (NoCases-1) * (2 * NoCases + 5) - MannKendall) / 18.0;
              Z := inversez(Alpha);
              if MannKendall < 0.0 then
                 begin
                       outline := format('Error in calculating Mann-Kendall = %8.3f',
                         [MannKendall]);
                       ShowMessage(outline);
                 end;
              if MannKendall > 0.0 then C := Z * sqrt(MannKendall)
              else C := Z;
              M1 := (count - C) / 2.0;
              M2 := (count + C) / 2.0;
              // Show results
              outline := format('Median Slope for %d values = %8.3f for averaged measures',
                [count,MedianSlope]);
              OutputFrm.RichEdit.Lines.Add(outline);
              outline := format('Mann-Kendall Variance statistic = %8.3f (%d ties observed)',
                  [MannKendall,q]);
              OutputFrm.RichEdit.Lines.Add(outline);
              outline := format('Ranks of the lower and upper confidence = (%8.3f, %8.3f)',
                    [M1, M2]);
              OutputFrm.RichEdit.Lines.Add(outline);
              low := round(M1) - 1;
              if ((M1-1) - low) > 0.5 then low := round(M1 - 1);
              hi := round(M2);
              if (M2 - hi) > 0.5 then hi := round(M2);
              outline := format('Corresponding lower and upper slopes = (%8.3f, %8.3f)',
                    [RankedQ[low],RankedQ[hi]]);
              OutputFrm.RichEdit.Lines.Add(outline);
     end; // end if average slope
     OutputFrm.ShowModal;

     // cleanup
     AvgSlopes := nil;
     Sorted := nil;
     RankedQ := nil;
     Slopes := nil;
     Values := nil;
     selected := nil;
     ColLabels := nil;
     RowLabels := nil;
end;

procedure TSensForm.FormActivate(Sender: TObject);
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

procedure TSensForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TSensForm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := SelectedList.ItemIndex;
     VarList.Items.Add(SelectedList.Items.Strings[index]);
     SelectedList.Items.Delete(index);
     InBtn.Enabled := true;
     if SelectedList.Items.Count = 0 then OutBtn.Enabled := false;
end;

initialization
  {$I sensunit.lrs}

end.

