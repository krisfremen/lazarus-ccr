unit DifUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, OutputUnit, MatrixLib, FunctionsLib, GraphLib, ContextHelpUnit;

type
  DynamicCharArray = array of char;

  { TDIFFrm }

  TDIFFrm = class(TForm)
    Bevel1: TBevel;
    GroupBox2: TGroupBox;
    HelpBtn: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    ItemStatsChk: TCheckBox;
    TestStatsChk: TCheckBox;
    ItemCorrsChk: TCheckBox;
    ItemTestChk: TCheckBox;
    AlphaChk: TCheckBox;
    MHChk: TCheckBox;
    LogisticChk: TCheckBox;
    CurvesChk: TCheckBox;
    CountsChk: TCheckBox;
    RefGrpEdit: TEdit;
    TrgtGrpEdit: TEdit;
    LevelsEdit: TEdit;
    LevelNoEdit: TEdit;
    LowBoundEdit: TEdit;
    UpBoundEdit: TEdit;
    GroupBox1: TGroupBox;
    ItemInBtn: TBitBtn;
    ItemOutBtn: TBitBtn;
    AllBtn: TBitBtn;
    GrpInBtn: TBitBtn;
    GrpOutBtn: TBitBtn;
    GroupVarEdit: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    UpBoundlabel: TLabel;
    Label2: TLabel;
    ItemsList: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LevelScroll: TScrollBar;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure UpBoundEditExit(Sender: TObject);
    procedure GrpInBtnClick(Sender: TObject);
    procedure GrpOutBtnClick(Sender: TObject);
    procedure ItemInBtnClick(Sender: TObject);
    procedure ItemOutBtnClick(Sender: TObject);
    procedure LevelScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure LevelsEditExit(Sender: TObject);
    procedure LowBoundEditExit(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
  private
    { private declarations }
   FAutoSized: Boolean;
   NoItems : integer;
   nolevels : integer;
   tmean, tvar, tsd : double;
   ColNoSelected : IntDyneVec;
   ColLabels, RowLabels : StrDyneVec;
   Means, Variances, StdDevs : DblDyneVec;
   CorMat : DblDyneMat; // correlations among items and total score
   Data : IntDyneMat; //store item scores and total score
   Ubounds : IntDyneVec; // upper and lower bounds of score groups
   Lbounds : IntdyneVec;
   Code : DynamicCharArray; // blank, A, B or C ETS codes
   Level10OK : IntdyneMat; // check that each item category >= 10
   RMHRight : IntDyneMat; // no. right for items by score group in reference group
   RMHWrong : IntDyneMat; // no. wrong for items by score group in reference group
   FMHRight : IntDyneMat; // no. right for items by score group in focus group
   FMHWrong : IntDyneMat; // no. wrong for items by score group in focus group
   RScrGrpCnt : IntDyneMat; // total responses for score groups in reference group
   FScrGrpCnt : IntDyneMat; // total responses for score groups in focus group
   NT : IntDyneMat; // total right and wrong in each category of each item
   Alpha : DblDyneVec;
   AlphaNum : DblDyneVec;
   AlphaDen : DblDyneVec;
   MHDiff : DblDyneVec;
   ExpA : DblDyneMat;
   VarA : DblDyneMat;
   SumA : DblDyneVec;
   SumExpA : DblDyneVec;
   SumVarA : DblDyneVec;
   ChiSqr : DblDyneVec;
   Prob : DblDyneVec;
   SEMHDDif : DblDyneVec;
   Aster : StrDyneVec;
   C : DblDyneVec;
   CodeRF : DynamicCharArray;
   Tot : IntDyneVec;
   procedure AlphaRel(Sender: TObject);
   procedure ItemCorrs(Sender: TObject);
   procedure ItemTestCorrs(Sender: TObject);
   procedure ItemCurves(Sender: TObject);

  public
    { public declarations }
  end; 

var
  DIFFrm: TDIFFrm;

implementation

uses
  Math;

{ TDIFFrm }

procedure TDIFFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     ItemsList.Clear;
     GroupVarEdit.Text := '';
     ItemInBtn.Enabled := true;
     ItemOutBtn.Enabled := false;
     AllBtn.Visible := true;
     GrpInBtn.Enabled := true;
     GrpOutBtn.Enabled := false;
     ItemStatsChk.Checked := true;
     TestStatsChk.Checked := false;
     ItemCorrsChk.Checked := false;
     ItemTestChk.Checked := false;
     MHChk.Checked := true;
     LogisticChk.Checked := false;
     RefGrpEdit.Text := '';
     TrgtGrpEdit.Text := '';
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     if NoVariables > 0 then LevelScroll.Max := NoVariables;
     LevelNoEdit.Text := '1';
     LowBoundEdit.Text := '0';
     UpBoundEdit.Text := '2';
     //allocate space on heap
     SetLength(ColLabels,NoVariables+1);
     SetLength(RowLabels,NoVariables+1);
     SetLength(Means,NoVariables);
     SetLength(Variances,NoVariables);
     SetLength(StdDevs,NoVariables);
     SetLength(CorMat,NoVariables,NoVariables);
     SetLength(Data,NoCases,NoVariables+3); //group, items, total, flag
     SetLength(Lbounds,NoVariables);
     SetLength(Ubounds,NoVariables);
     SetLength(Tot,NoCases);
     SetLength(ColNoSelected,NoVariables);
end;

procedure TDIFFrm.ReturnBtnClick(Sender: TObject);
begin
     ColNoSelected := nil;
     C := nil;
     SEMHDDif := nil;
     Aster := nil;
     Prob := nil;
     ChiSqr := nil;
     SumVarA := nil;
     SumExpA := nil;
     SumA := nil;
     VarA := nil;
     ExpA := nil;
     CodeRF := nil;
     MHDiff := nil;
     AlphaDen := nil;
     AlphaNum := nil;
     Alpha := nil;
     NT := nil;
     Level10OK := nil;
     Code := nil;
     FScrGrpCnt := nil;
     RScrGrpCnt := nil;
     FMHWrong := nil;
     FMHRight := nil;
     RMHWrong := nil;
     RMHRight := nil;
     Tot := nil;
     Ubounds := nil;
     Lbounds := nil;
     Data := nil;
     CorMat := nil;
     StdDevs := nil;
     Variances := nil;
     Means := nil;
     RowLabels := nil;
     ColLabels := nil;
     DIFfrm.Hide;
end;

procedure TDIFFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinWidth := GroupVarEdit.Width;
  Panel1.Constraints.MinHeight := GroupBox1.Height - Label1.Height;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TDIFFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TDIFFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TDIFFrm.GrpInBtnClick(Sender: TObject);
VAR index : integer;
begin
     if VarList.ItemIndex < 0 then
     begin
          GrpInBtn.Enabled := false;
          exit;
     end;
     index := VarList.ItemIndex;
     GroupVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     GrpInBtn.Enabled := false;
     GrpOutBtn.Enabled := true;
end;

procedure TDIFFrm.GrpOutBtnClick(Sender: TObject);
begin
   VarList.Items.Add(GroupVarEdit.Text);
   GroupVarEdit.Text := '';
   GrpInBtn.Enabled := true;
   GrpOutBtn.Enabled := false;
end;

procedure TDIFFrm.ItemInBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     if VarList.ItemIndex < 0 then
     begin
          ItemInBtn.Enabled := false;
          exit;
     end;
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            ItemsList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     ItemOutBtn.Enabled := true;
end;

procedure TDIFFrm.ItemOutBtnClick(Sender: TObject);
VAR index : integer;
begin
   index := ItemsList.ItemIndex;
   if index < 0 then
   begin
        ItemOutBtn.Enabled := false;
        exit;
   end;
   VarList.Items.Add(ItemsList.Items.Strings[index]);
   ItemsList.Items.Delete(index);
   ItemInBtn.Enabled := true;
end;

procedure TDIFFrm.LevelScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
var
   scrlpos : integer;
   level : integer;
begin
     level := StrToInt(LevelNoEdit.Text);
     scrlpos := LevelScroll.Position;
     if ((scrlpos > level) and (level <= StrToInt(LevelsEdit.Text))) then
     begin
          LevelNoEdit.Text := IntToStr(scrlpos);
          LowBoundEdit.SetFocus;
          exit;
     end;
     if scrlpos < level then
     begin
          level := scrlpos;
          if level > 0 then
          begin
               LevelNoEdit.Text := IntToStr(level);
               LowBoundEdit.Text := IntToStr(Lbounds[level-1]);
               UpBoundEdit.Text := IntToStr(Ubounds[level-1]);
          end;
          LowBoundEdit.SetFocus;
     end;
end;

procedure TDIFFrm.LevelsEditExit(Sender: TObject);
begin
     LevelScroll.Max := StrToInt(LevelsEdit.Text);
     LowBoundEdit.SetFocus;
end;

procedure TDIFFrm.LowBoundEditExit(Sender: TObject);
VAR i : integer;
begin
     i := StrToInt(LevelNoEdit.Text);
     Lbounds[i-1] := StrToInt(LowBoundEdit.Text);
     UpBoundEdit.SetFocus;
end;

procedure TDIFFrm.ComputeBtnClick(Sender: TObject);
Label LoopStart;
var
   i, j, k : integer;
   itm : integer;
   grpvar : integer;
   subjgrp : integer;
   value : integer;
   subjscore : integer;
   sum : integer;
   cellstring : string;
   title : string;
   nsize : array [1..2] of integer;
   Rtm, Wtm : double;
   TotPurge : integer;
   LoopIt : integer;
   RItem: integer;
begin
     LoopIt := 0;
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Mantel-Haenszel DIF Analysis adapted by Bill Miller from');
     OutputFrm.RichEdit.Lines.Add('EZDIF written by Niels G. Waller');
     OutputFrm.RichEdit.Lines.Add('');

     NoItems := ItemsList.Items.Count;
     for k := 1 to 2 do nsize[k] := 0;

     // get items to analyze and their labels
     for i := 1 to NoItems do // items to analyze
     begin
          for j := 1 to NoVariables do // variables in grid
          begin
               cellstring := OS3MainFrm.DataGrid.Cells[j,0];
               if cellstring = ItemsList.Items.Strings[i-1] then
               begin // matched - save info
                     ColNoSelected[i-1] := j;
                     ColLabels[i-1] := cellstring;
                     RowLabels[i-1] := cellstring;
               end; // end match
          end; // next j
     end; // next i
     ColLabels[NoItems] := 'TOTAL';
     RowLabels[NoItems] := 'TOTAL';

     // get the variable number of the grouping code
     grpvar := 0;
     for i := 1 to NoVariables do
     begin
          cellstring := OS3MainFrm.DataGrid.Cells[i,0];
          if cellstring = GroupVarEdit.Text then grpvar := i;
     end;
     if grpvar = 0 then
     begin
          ShowMessage('Error - No group variable found.');
          exit;
     end;

     // get number of test score levels
     nolevels := StrToInt(LevelsEdit.Text);

     // read data (score group and items)
     for i := 1 to NoCases do
     begin
          subjscore := 0;
          value := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[grpvar,i])));
          subjgrp := 0;
          if value = StrToInt(RefGrpEdit.Text) then subjgrp := 1; // reference grp
          if value = StrToInt(TrgtGrpEdit.Text) then subjgrp := 2; // target group
          if subjgrp = 0 then
          begin
               ShowMessage('Error - Bad group code for a subject.');
               exit;
          end;
          Data[i-1,0] := subjgrp;
          nsize[subjgrp] := nsize[subjgrp] + 1;
          for j := 1 to NoItems do
          begin
               itm := ColNoSelected[j-1];
               value := Round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[itm,i])));
               if value = 1 then subjscore := subjscore + 1;
               Data[i-1,j] := value;
          end;
          Tot[i-1] := subjscore;
     end;

     // obtain item means, variances, standard deviations for total subjects
     for i := 0 to NoItems-1 do
     begin
          Means[i] := 0.0;
          Variances[i] := 0.0;
          StdDevs[i] := 0.0;
          for j := 0 to NoCases - 1 do
          begin
               Means[i] := Means[i] + Data[j,i+1];
               Variances[i] := Variances[i] + (Data[j,i+1] * Data[j,i+1]);
          end;
          Variances[i] := (Variances[i] - (Means[i] * Means[i] / NoCases)) / (NoCases - 1);
          if Variances[i] <= 0 then
          begin
               cellstring := format('Item %d has zero variance. Unselect the item.',
                    [i+1]);
               ShowMessage(cellstring);
               ResetBtnClick(Self);
               exit;
          end;
          StdDevs[i] := sqrt(Variances[i]);
          Means[i] := Means[i] / NoCases;
     end;

     // obtain total score mean, variance and stddev
     tmean := 0.0;
     tvar := 0.0;
     tsd := 0.0;
     for i := 0 to NoCases - 1 do
     begin
          tmean := tmean + Tot[i];
          tvar := tvar + (Tot[i] * Tot[i]);
     end;
     tvar := (tvar - (tmean * tmean / NoCases)) / (NoCases - 1);
     tsd := sqrt(tvar);
     tmean := tmean / NoCases;

     // print descriptives if checked
     if ItemStatsChk.Checked then
     begin
          title := 'Total Means';
          DynVectorPrint(Means,NoItems,title,ColLabels,NoCases);
          title := 'Total Variances';
          DynVectorPrint(Variances,NoItems,title,ColLabels,NoCases);
          title := 'Total Standard Deviations';
          DynVectorPrint(StdDevs,NoItems,title,ColLabels,NoCases);
     end;

     // Show total test score statistics if checked
     if TestStatsChk.Checked then
     begin
          cellstring := format('Total Score: Mean = %10.3f, Variance = %10.3f, Std.Dev. = %10.3f',
               [tmean, tvar, tsd]);
          OutputFrm.RichEdit.Lines.Add(cellstring);
          OutputFrm.RichEdit.Lines.Add('');
          OutputFrm.ShowModal;
          OutputFrm.RichEdit.Clear;
     end;
     cellstring := format('Reference group size = %d, Focus group size = %d',
          [nsize[1],nsize[2]]);
     OutputFrm.RichEdit.Lines.Add(cellstring);
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;

     // get Cronbach alpha for total group if checked
     if AlphaChk.Checked then AlphaRel(Self);

     // Get item intercorrelations for total group if checked
     if ItemCorrsChk.Checked then
     begin
          ItemCorrs(Self);
          OutputFrm.ShowModal;
          OutputFrm.RichEdit.Clear;
     end;

     // Get item-total score correlations for total group if checked
     if ItemTestChk.Checked then
     begin
          ItemTestCorrs(Self);
          OutputFrm.ShowModal;
          OutputFrm.RichEdit.Clear;
     end;

     // Show upper and lower bounds for score group bins
     OutputFrm.RichEdit.Lines.Add('Conditioning Levels');
     OutputFrm.RichEdit.Lines.Add('Lower        Upper');
     for i := 0 to nolevels-1 do
     begin
          cellstring := format('%5d        %5d',[Lbounds[i],Ubounds[i]]);
          OutputFrm.RichEdit.Lines.Add(cellstring);
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.ShowModal;

     // check for zero variance in each group
     for k := 1 to 2 do // group
     begin
          for i := 0 to NoItems-1 do // item
          begin
               sum := 0;
               for j := 0 to NoCases-1 do // subject
               begin
                    if Data[j,0] = k then  // group match ?
                    begin
                         sum := sum + Data[j,i+1];
                    end;
               end;
          end;
          if ((sum = 0) or (sum = NoVariables)) then
          begin
               cellstring := format('Item %d in group %d has zero variance.',
                   [i+1,k]);
               ShowMessage(cellstring);
               exit;
          end;
     end;

     // Get count of no. right and wrong for each item in each group
     SetLength(RMHRight,nolevels,NoItems);
     SetLength(RMHWrong,nolevels,NoItems);
     SetLength(FMHRight,nolevels,NoItems);
     SetLength(FMHWrong,nolevels,NoItems);
     SetLength(RScrGrpCnt,nolevels,NoItems);
     SetLength(FScrGrpCnt,nolevels,NoItems);
     SetLength(Code,NoItems);
     SetLength(Level10OK,nolevels,NoItems);
     SetLength(NT,nolevels,NoItems);
     SetLength(Alpha,NoItems);
     SetLength(AlphaNum,NoItems);
     SetLength(AlphaDen,NoItems);
     SetLength(MHDiff,NoItems);
     SetLength(CodeRF,NoItems);
     SetLength(ExpA,nolevels,NoItems);
     SetLength(VarA,nolevels,NoItems);
     SetLength(SumA,NoItems);
     SetLength(SumExpA,NoItems);
     SetLength(SumVarA,NoItems);
     SetLength(ChiSqr,NoItems);
     SetLength(Prob,NoItems);
     SetLength(Aster,NoItems);
     SetLength(SEMHDDif,NoItems);
     SetLength(C,NoItems);

LoopStart:
     // clear arrays
     for j := 0 to NoItems-1 do
     begin
          for k := 0 to nolevels-1 do
          begin
               RMHRight[k,j] := 0;
               RMHWrong[k,j] := 0;
               RScrGrpCnt[k,j] := 0;
               FMHRight[k,j] := 0;
               FMHWrong[k,j] := 0;
               FScrGrpCnt[k,j] := 0;
               Level10OK[k,j] := 1;
               NT[k,j] := 0;
               ExpA[k,j] := 0.0;
               VarA[k,j] := 0.0;
          end;
          Alpha[j] := 0.0;
          AlphaNum[j] := 0.0;
          AlphaDen[j] := 0.0;
          MHDiff[j] := 0.0;
          CodeRF[j] := ' ';
          Prob[j] := 0.0;
     end;

     LoopIt := LoopIt + 1;
     OutputFrm.RichEdit.Clear;
     cellstring := format('COMPUTING M-H CHI-SQUARE, PASS # %d',[LoopIt]);
     OutputFrm.RichEdit.Lines.Add(cellstring);
     for k := 0 to nolevels-1 do
     begin
          for i := 0 to NoCases-1 do
          begin
               subjgrp := Data[i,0];
               for j := 0 to NoItems-1 do
               begin
                    RItem := 0;
                    value := Data[i,j+1];
                    if ((LoopIt = 2) and (Code[j] = 'C')) then RItem := value;
                    if value = 1 then
                    begin
                         if ((Tot[i]+RItem >= Lbounds[k]) and
                             (Tot[i]+RItem <= Ubounds[k])) then
                         begin
                              if subjgrp = 1 then
                              begin
                                   RMHRight[k,j] := RMHRight[k,j] + 1;
                                   RScrGrpCnt[k,j] := RScrGrpCnt[k,j] + 1;
                              end; // if reference group
                              if subjgrp = 2 then
                              begin
                                   FMHRight[k,j] := FMHRight[k,j] + 1;
                                   FScrGrpCnt[k,j] := FScrGrpCnt[k,j] + 1;
                              end; // if focus group
                         end; // end if () and ()
                    end; // value = 1
                    if value = 0 then
                    begin
                         if ((Tot[i]+RItem >= Lbounds[k]) and
                             (Tot[i]+RItem <= Ubounds[k])) then
                         begin
                              if subjgrp = 1 then
                              begin
                                   RMHWrong[k,j] := RMHWrong[k,j] + 1;
                                   RScrGrpCnt[k,j] := RScrGrpCnt[k,j] + 1;
                              end;
                              if subjgrp = 2 then
                              begin
                                   FMHWrong[k,j] := FMHWrong[k,j] + 1;
                                   FScrGrpCnt[k,j] := FScrGrpCnt[k,j] + 1;
                              end;
                         end;
                    end; // if value = 0
               end; // next j
          end; // next i
     end; // next k
     for j := 0 to NoItems-1 do Code[j] := 'Z'; // clean out ETS code

     // print score group counts for Reference and focus subjects
     if CountsChk.Checked then
     begin
          for i := 0 to nolevels-1 do
              RowLabels[i] := format('%3d-%3d',[Lbounds[i],Ubounds[i]]);
          DynIntMatPrint(RScrGrpCnt,nolevels,NoItems,'Score Level Counts by Item',RowLabels,ColLabels,
               'Cases in Reference Group');
          DynIntMatPrint(FScrGrpCnt,nolevels,NoItems,'Score Level Counts by Item',RowLabels,ColLabels,
               'Cases in Focus Group');
     end;

     // Plot Item curves if checked
     if ((CurvesChk.Checked) and (LoopIt = 1)) then ItemCurves(Self);

     // check for minimum of 10 per category in each item
     // compute NT
     for j := 0 to NoItems-1 do
     begin
          for k := 0 to nolevels-1 do
          begin
               if ((RScrGrpCnt[k,j] < 10) or (FScrGrpCnt[k,j] < 10)) then
                  Level10OK[k,j] := 0 // insufficient n
               else Level10OK[k,j] := 1;  // 10 or more - OK
               NT[k,j] := RScrGrpCnt[k,j] + FScrGrpCnt[k,j];
          end;
     end;

     for k := 0 to nolevels-1 do
     begin
          if Level10OK[k,0] = 0 then
          begin
               cellstring := format('Insufficient data found in level: %d - %d',
                   [Lbounds[k],Ubounds[k]]);
               OutputFrm.RichEdit.Lines.Add(cellstring);
          end;
     end;

     // compute alpha
     for j := 0 to NoItems - 1 do
     begin
          for k := 0 to nolevels-1 do
          begin
               if Level10OK[k,j] = 1 then
               begin
                    AlphaNum[j] := AlphaNum[j] + (RMHRight[k,j] * FMHWrong[k,j]) / NT[k,j];
                    AlphaDen[j] := AlphaDen[j] + (RMHWrong[k,j] * FMHRight[k,j]) / NT[k,j];
               end;
          end;
     end;

     for j := 0 to NoItems-1 do
     begin
          if AlphaDen[j] = 0.0 then
          begin
               cellstring := format('Window too small at item %d level %d',
                   [j+1,k+1]);
               ShowMessage(cellstring);
               exit;
          end
          else begin
               Alpha[j] := AlphaNum[j] / AlphaDen[j];
               MHDiff[j] := -2.35 * ln(Alpha[j]);
          end;
     end;

     // compute expected values
     for j := 0 to NoItems-1 do
     begin
          for k := 0 to nolevels-1 do
          begin
               if Level10OK[k,j] = 1 then
               begin
                    ExpA[k,j] := (RScrGrpCnt[k,j] * (RMHRight[k,j] + FMHRight[k,j] )) / NT[k,j];
               end;
          end;
     end;

     // compute variances
     for j := 0 to NoItems-1 do
     begin
          for k := 0 to nolevels-1 do
          begin
               if Level10OK[k,j] = 1 then
               begin
                    Rtm := RMHRight[k,j] + FMHRight[k,j];
                    Wtm := RMHWrong[k,j] + FMHWrong[k,j];
                    VarA[k,j] := (RScrGrpCnt[k,j] * FScrGrpCnt[k,j] * Rtm * Wtm) /
                        ( NT[k,j] * NT[k,j] * (NT[k,j]-1) );
               end;
          end;
     end;

     // compute chi-squares
     for j := 0 to NoItems-1 do
     begin
          SumA[j] := 0.0;
          SumExpA[j] := 0.0;
          SumVarA[j] := 0.0;
          for k := 0 to nolevels-1 do
          begin
               if Level10OK[k,j] = 1 then
               begin
                    SumA[j] := SumA[j] + RMHRight[k,j];
                    SumExpA[j] := SumExpA[j] + ExpA[k,j];
                    SumVarA[j] := SumVarA[j] + VarA[k,j];
               end;
          end;
     end;

     for j := 0 to NoItems-1 do
     begin
         ChiSqr[j] := (sqr((Abs(SumA[j] - SumExpA[j]) - 0.5))) / SumVarA[j];
         Prob[j] := 1.0 - chisquaredprob(ChiSqr[j],1);
         if Prob[j] > 0.05 then Aster[j] := '';
         if Prob[j] <= 0.05 then Aster[j] := '*';
         if Prob[j] <= 0.01 then Aster[j] := '**';
         if Prob[j] <= 0.005 then Aster[j] := '***';
     end;

     // compute std. errors
     for j := 0 to NoItems-1 do
     begin
          C[j] := 0.0;
          for k := 0 to nolevels-1 do
          begin
               if Level10OK[k,j] = 1 then
                  C[j] := C[j] + ((RMHRight[k,j] * FMHWrong[k,j]) / NT[k,j]);
          end;
     end;

     for j := 0 to NoItems - 1 do
     begin
          SEMHDDif[j] := 0.0;
          for k := 0 to nolevels-1 do
          begin
               if Level10OK[k,j] = 1 then
               begin
                    SEMHDDif[j] := SEMHDDif[j] + ( (RMHRight[k,j] * FMHWrong[k,j] )
                        + ( Alpha[j] * RMHWrong[k,j] * FMHRight[k,j])) *
                        ( RMHRight[k,j] + FMHWrong[k,j] + Alpha[j] *
                        ( RMHWrong[k,j]  + FMHRight[k,j] )) / ( 2.0 * NT[k,j] * NT[k,j]);
               end;
          end;
     end;

     for j := 0 to NoItems-1 do
         SEMHDDif[j] := (2.35 / C[j]) * sqrt(SEMHDDif[j]);

     // code results with ETS codes
     for j := 0 to NoItems-1 do
     begin
          if ( (abs(MHDiff[j]) > 1.5) and ((abs(MHDiff[j]) - (1.96 * SEMHDDif[j])
            > 1.0))) then Code[j] := 'C';
          if ((abs(MHDiff[j]) - (1.96 * SEMHDDif[j]) <= 0.0) or
              (abs(MHDiff[j]) <= 1.0)) then  code[j] := 'A';
          if ((code[j] <> 'A') and (code[j] <> 'C')) then code[j] := 'B';
     end;

     // purge
     TotPurge := 0;
     for j := 0 to NoItems-1 do
     begin
          if (code[j] = 'C') then
          begin
               TotPurge := TotPurge + 1;
               for i := 0 to NoCases - 1 do Tot[i] := Tot[i] - Data[i,j+1];
               if Alpha[j] > 1.0 then CodeRF[j] := 'R';
               if Alpha[j] < 1.0 then CodeRF[j] := 'F';
          end;
     end;

     // show results
//     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add(
          'CODES ITEM     SIG.  ALPHA   CHI2    P-VALUE    MH D-DIF   S.E. MH D-DIF');
     for j := 0 to noitems-1 do
     begin
          cellstring := format('%1s %1s %4d      %3s %6.3f   %7.3f  %6.3f     %6.3f       %6.3f',
              [code[j],CodeRF[j], j+1, Aster[j],Alpha[j],ChiSqr[j],Prob[j],MHDiff[j],
              SEMHDDif[j]]);
          OutputFrm.RichEdit.Lines.Add(cellstring);
     end;
     OutputFrm.RichEdit.Lines.Add('');
     if LoopIt = 1 then
     begin
          cellstring := format('No. of items purged in pass 1 = %d',[TotPurge]);
          OutputFrm.RichEdit.Lines.Add(cellstring);
          OutputFrm.RichEdit.Lines.Add('Item Numbers:');
          for j := 0 to NoItems-1 do
          begin
               if Code[j] = 'C' then
               begin
                    cellstring := format('%d',[j+1]);
                    OutputFrm.RichEdit.Lines.Add(cellstring);
               end;
          end;
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.ShowModal;
     if LoopIt < 2 then goto LoopStart;
end;

procedure TDIFFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TDIFFrm.UpBoundEditExit(Sender: TObject);
VAR i : integer;
begin
     i := StrToInt(LevelNoEdit.Text);
     Ubounds[i-1] := StrToInt(UpBoundEdit.Text);
     if i = StrToInt(LevelsEdit.Text) then
     begin
          ComputeBtn.SetFocus;
          exit;
     end;
     LowBoundEdit.Text := IntToStr(Ubounds[i-1] + 1);
     LowBoundEdit.SetFocus;
end;

procedure TDIFFrm.AllBtnClick(Sender: TObject);
VAR i : integer;
begin
     if VarList.Items.Count < 1 then exit;
     for i := 0 to VarList.Items.Count - 1 do
          ItemsList.Items.Add(VarList.Items.Strings[i]);
     VarList.Clear;
     ItemInBtn.Enabled := false;
     ItemOutBtn.Enabled := true;
end;

procedure TDIFfrm.AlphaRel(Sender: TObject);
var
   i : integer;
   Alpha1, SEMeas : double;
   outline : string;
begin
     OutPutFrm.RichEdit.Clear;
     OutPutFrm.RichEdit.Lines.Add('');
     Alpha1 := 0.0;

     for i := 0 to NoItems-1 do
          Alpha1 := Alpha1 + variances[i]; // sum of item variances
     Alpha1  := Alpha1 / tvar;
     Alpha1 := 1.0 - Alpha1;
     Alpha1 := (NoItems / (NoItems - 1.0)) * Alpha1;
     SEMeas := tsd * sqrt(1.0 - Alpha1);
     outline := format('Alpha Reliability Estimate for Test = %6.4f  S.E. of Measurement = %8.3f',
                [Alpha1,SEMeas]);
     OutPutFrm.RichEdit.Lines.Add(outline);
//     OutPutFrm.ShowModal;
end;

procedure TDIFfrm.ItemCorrs(Sender: TObject);
var
   i, j, k : integer;
   title : string;
begin
     // cross-products
     for i := 0 to NoItems-1 do
          for j := 0 to NoItems-1 do
               for k := 0 to NoCases-1 do
                    CorMat[i,j] := CorMat[i,j] + (Data[k,i+1] * Data[k,j+1]);
     // covariances
     for i := 0 to NoItems-1 do
          for j := 0 to NoItems-1 do
              CorMat[i,j] := (CorMat[i,j] - (NoCases * Means[i] * Means[j])) /
                   (NoCases-1);

     // correlations
     for i := 0 to NoItems-1 do
          for j := 0 to NoItems-1 do
              CorMat[i,j] := CorMat[i,j] / (StdDevs[i] * StdDevs[j]);

     // show results
     OutPutFrm.RichEdit.Clear;
     title := 'Correlations Among Items';
     MAT_PRINT(CorMat,NoItems,NoItems,title,RowLabels,ColLabels,NoCases);
end;

procedure TDIFfrm.ItemTestCorrs(Sender: TObject);
var
   i, j : integer;
   Cors : DblDyneVec;
   title : string;
begin
     SetLength(Cors,NoItems);
     // cross-products
     for i := 0 to NoItems-1 do
          for j := 0 to NoCases-1 do
               Cors[i] := Cors[i] + (Data[j,i+1] * Tot[j]);
     // covariances
     for i := 0 to NoItems-1 do
          Cors[i] := (Cors[i] - (NoCases * Means[i] * tmean)) / (NoCases-1);
     // correlations
     for i := 0 to NoItems-1 do
         Cors[i] := Cors[i] / (StdDevs[i] * tsd);
     // show results
//     OutPutFrm.RichEdit.Clear;
     title := 'Item-Total Correlations';
     DynVectorPrint(Cors,NoItems,title,ColLabels,NoCases);
     // release memory
     Cors := nil;
end;

procedure TDIFfrm.ItemCurves(Sender: TObject);
var
   i, ii, j : integer;
   XPlotPts : DblDyneMat;
   YPlotPts : DblDyneMat;
   LabelStr, outline, xTitle, yTitle : string;
   max : integer;
begin
     SetLength(YPlotPts,2,nolevels);
     SetLength(XPlotPts,1,nolevels);

     // get maximum no. of scores in either groups bins
     for i := 0 to NoItems-1 do
     begin
          max := 0;
          for j := 0 to nolevels-1 do
          begin
               if RMHRight[j,i] > max then max := RMHRight[j,i];
               if FMHRight[j,i] > max then max := FMHRight[j,i];
          end;

          // Plot reference group in blue, focus group in red
          for ii := 1 to 2 do // possible group curves
          begin
               for  j := 0 to nolevels-1 do  //get points to plot
               begin
                    XPlotPts[0,j] := Lbounds[j];
                    if ii = 1 then YPlotPts[ii-1,j] := RMHRight[j,i];
                    if ii = 2 then YPlotPts[ii-1,j] := FMHRight[j,i];
               end;
          end; // next group

          // Plot the points
          GraphFrm.BackColor := clWhite;
          GraphFrm.ShowLeftWall := true;
          GraphFrm.ShowRightWall := true;
          GraphFrm.ShowBottomWall := true;
          GraphFrm.ShowBackWall := true;
          GraphFrm.BackColor := clYellow;
          GraphFrm.WallColor := clBlue;
          GraphFrm.FloorColor := clBlue;
          outline := format('Blue = Reference, Red = Focus for item %d',[i+1]);
          GraphFrm.Heading := outline;
          xTitle := 'Lower bounds of levels';
          GraphFrm.XTitle := xTitle;
          yTitle := 'Frequencies';
          GraphFrm.YTitle := yTitle;
          GraphFrm.nosets := 2;
          GraphFrm.nbars := nolevels;
          GraphFrm.barwideprop := 0.5;
          GraphFrm.miny := 0.0;
          GraphFrm.maxy := max;
          GraphFrm.AutoScaled := false;
          GraphFrm.GraphType := 5; // 2d line charts
          GraphFrm.PtLabels := false;
          for ii := 1 to 2 do
          begin
               if ii = 1 then LabelStr := 'Reference';
               if ii = 2 then LabelStr := 'Focus';
               GraphFrm.SetLabels[ii] := LabelStr;
          end;
          GraphFrm.Ypoints := YPlotPts;
          GraphFrm.Xpoints := XPlotPts;
          GraphFrm.ShowModal;
     end; // next item

     XPlotPts := nil;
     YPlotPts := nil;
end;

initialization
  {$I difunit.lrs}

end.

