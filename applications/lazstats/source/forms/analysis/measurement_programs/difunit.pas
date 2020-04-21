// Data file not 100% clear, bus seems to be: DIFData.laz
// - Reference Group Code: 1
// - Focal Group Code: 2
// - No. of Score Levels: 11
// - Lower/Upper Bounds: 0-3, 4-7, 8-11, 12-15, 16-19, 20-23, 24-27, 28-31, 32-35, 36-39, 40-43
// The result obtained this way match the pdf file.

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
    NextBtn: TButton;
    LevelNoEdit: TStaticText;
    LevelsGroup: TGroupBox;
    HelpBtn: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
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
    LowBoundEdit: TEdit;
    UpBoundEdit: TEdit;
    OptionsGroup: TGroupBox;
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
    procedure LevelScrollChange(Sender: TObject);
    procedure LevelsEditEditingDone(Sender: TObject);
    procedure LowBoundEditEditingDone(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
    procedure UpBoundEditEditingDone(Sender: TObject);
    procedure GrpInBtnClick(Sender: TObject);
    procedure GrpOutBtnClick(Sender: TObject);
    procedure ItemInBtnClick(Sender: TObject);
    procedure ItemOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    NoItems: integer;
    NoLevels: integer;
    tmean, tvar, tsd: double;
    ColNoSelected: IntDyneVec;
    ColLabels, RowLabels: StrDyneVec;
    Means, Variances, StdDevs: DblDyneVec;
    CorMat: DblDyneMat; // correlations among items and total score
    Data: IntDyneMat; //store item scores and total score
    Ubounds: IntDyneVec; // upper and lower bounds of score groups
    Lbounds: IntdyneVec;
    Code: DynamicCharArray; // blank, A, B or C ETS codes
    Level10OK: IntdyneMat; // check that each item category >= 10
    RMHRight: IntDyneMat; // no. right for items by score group in reference group
    RMHWrong: IntDyneMat; // no. wrong for items by score group in reference group
    FMHRight: IntDyneMat; // no. right for items by score group in focus group
    FMHWrong: IntDyneMat; // no. wrong for items by score group in focus group
    RScrGrpCnt: IntDyneMat; // total responses for score groups in reference group
    FScrGrpCnt: IntDyneMat; // total responses for score groups in focus group
    NT: IntDyneMat; // total right and wrong in each category of each item
    Alpha: DblDyneVec;
    AlphaNum: DblDyneVec;
    AlphaDen: DblDyneVec;
    MHDiff: DblDyneVec;
    ExpA: DblDyneMat;
    VarA: DblDyneMat;
    SumA: DblDyneVec;
    SumExpA: DblDyneVec;
    SumVarA: DblDyneVec;
    ChiSqr: DblDyneVec;
    Prob: DblDyneVec;
    SEMHDDif: DblDyneVec;
    Aster: StrDyneVec;
    C: DblDyneVec;
    CodeRF: DynamicCharArray;
    Tot: IntDyneVec;

    FAutoSized: Boolean;
    procedure UpdateBtnStates;
    function ValidNumEdit(AEdit: TEdit; AName: String; out AValue: Integer): Boolean;

    procedure AlphaRel(AReport: TStrings);
    procedure ItemCorrs(AReport: TStrings);
    procedure ItemTestCorrs(AReport: TStrings);
    procedure ItemCurves;

  public
    { public declarations }
  end; 

var
  DIFFrm: TDIFFrm;

implementation

uses
  Math, Utils;

{ TDIFFrm }

procedure TDIFFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  //allocate space on heap
  SetLength(ColLabels, NoVariables + 1);
  SetLength(RowLabels, NoVariables + 1);
  SetLength(Means, NoVariables);
  SetLength(Variances, NoVariables);
  SetLength(StdDevs, NoVariables);
  SetLength(CorMat, NoVariables, NoVariables);
  SetLength(Data, NoCases, NoVariables + 3); //group, items, total, flag
  SetLength(Lbounds, NoVariables);
  SetLength(Ubounds, NoVariables);
  SetLength(Tot, NoCases);
  SetLength(ColNoSelected, NoVariables);
  for i:=0 to High(LBounds) do LBounds[i] := -1;
  for i:=0 to High(UBounds) do UBounds[i] := -1;

  VarList.Clear;
  ItemsList.Clear;
  GroupVarEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);

  ItemStatsChk.Checked := true;
  TestStatsChk.Checked := false;
  ItemCorrsChk.Checked := false;
  ItemTestChk.Checked := false;
  MHChk.Checked := true;
  LogisticChk.Checked := false;

  RefGrpEdit.Text := '';
  TrgtGrpEdit.Text := '';

  LevelScroll.Min := 0;
  LevelScroll.Max := 0;
  LevelScroll.Position := 0;

  LevelsEdit.Text := '';
  LevelNoEdit.Caption := '';
  LowBoundEdit.Text := '';
  UpBoundEdit.Text := '';

  UpdateBtnStates;
end;

procedure TDIFFrm.FormActivate(Sender: TObject);
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

  VarList.Constraints.MinWidth := GroupVarEdit.Width;
  Panel1.Constraints.MinHeight := OptionsGroup.Height - Label1.Height;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TDIFFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then GraphFrm := TGraphFrm.Create(Application);
end;

procedure TDIFFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TDIFFrm.GrpInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (GroupVarEdit.Text = '') then
  begin
    GroupVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TDIFFrm.GrpOutBtnClick(Sender: TObject);
begin
  if GroupVarEdit.Text <> '' then
  begin
    VarList.Items.Add(GroupVarEdit.Text);
    GroupVarEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TDIFFrm.ItemInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      ItemsList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TDIFFrm.ItemOutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < ItemsList.Items.Count do
  begin
    if ItemsList.Selected[i] then
    begin
      VarList.Items.Add(ItemsList.Items[i]);
      ItemsList.Items.Delete(i);
      i := 0;
    end
    else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TDIFFrm.LevelScrollChange(Sender: TObject);
var
  level: Integer;
begin
  level := LevelScroll.Position;
  LevelNoEdit.Caption := IntToStr(level + 1);

  if LBounds[level] = -1 then
    LowBoundEdit.Text := ''
  else
    LowBoundEdit.Text := IntToStr(LBounds[level]);

  if UBounds[level] = -1 then
    UpBoundEdit.Text := ''
  else
    UpBoundEdit.Text := IntToStr(UBounds[level]);
end;

procedure TDIFFrm.LevelsEditEditingDone(Sender: TObject);
var
  L: Integer;
begin
  if ValidNumEdit(LevelsEdit, 'No. of Score Levels', L) then
  begin
    LevelScroll.Max := Max(L - 1, 0);
    LevelScroll.Min := 0;
    LevelNoEdit.Caption := IntToStr(LevelScroll.Position + 1);
  end;
end;

procedure TDIFFrm.LowBoundEditEditingDone(Sender: TObject);
var
  level: Integer;
  n: Integer;
begin
  level := LevelScroll.Position;
  if TryStrToInt(LowBoundEdit.Text, n) then
    LBounds[level] := n
  else
    MessageDlg(Format('No valid number in lower bound at level #%d.', [level+1]), mtError, [mbOK], 0);
end;

procedure TDIFFrm.NextBtnClick(Sender: TObject);
begin
  LevelScroll.Position := LevelScroll.Position + 1;
end;

procedure TDIFFrm.ComputeBtnClick(Sender: TObject);
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
  lReport: TStrings;
begin
  NoItems := ItemsList.Items.Count;
  if NoItems = 0 then
  begin
    MessageDlg('No items selected.', mtError, [mbOK], 0);
    exit;
  end;

  if GroupVarEdit.Text = '' then
  begin
    MessageDlg('No Grouping Variable selected.', mtError, [mbOK], 0);
    exit;
  end;

  if not ValidNumEdit(RefGrpEdit, 'Reference Group Code', i) then
    exit;
  if not ValidNumEdit(TrgtGrpEdit, 'Focus Group Code', i) then
    exit;
  if not ValidNumEdit(LevelsEdit, 'Number of Grouping Levels', noLevels) then
    exit;

  for i:=0 to StrToInt(LevelsEdit.Caption) - 1 do
  begin
    if LBounds[i] = -1 then begin
      MessageDlg(Format('Lower bound not specified for level #%d.', [i+1]), mtError, [mbOK], 0);
      exit;
    end;
    if UBounds[i] = -1 then begin
      MessageDlg(Format('Upper bound not specified for level #%d.', [i+1]), mtError, [mbOk], 0);
      exit;
    end;
    if LBounds[i] > UBounds[i] then begin
      MessageDlg(Format('Upper bound must be larger than the lower bound (level #%d).', [i+1]), mtError, [mbOK], 0);
      exit;
    end;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('MANTEL-HAENSZELl DIF ANALYSIS adapted by Bill Miller from');
    lReport.Add('EZDIF written by Niels G. Waller');
    lReport.Add('');

    for k := 1 to 2 do
      nsize[k] := 0;

    // get items to analyze and their labels
    for i := 1 to NoItems do // items to analyze
    begin
      for j := 1 to NoVariables do // variables in grid
      begin
        cellstring := OS3MainFrm.DataGrid.Cells[j,0];
        if cellstring = ItemsList.Items[i-1] then
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
      if cellstring = GroupVarEdit.Text then
        grpvar := i;
    end;
    if grpvar = 0 then
    begin
      MessageDlg('No group variable found.', mtError, [mbOK], 0);
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
        MessageDlg('Bad group code for a subject.', mtError, [mbOK], 0);
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
        Variances[i] := Variances[i] + sqr(Data[j,i+1]);
      end;
      Variances[i] := (Variances[i] - (Means[i] * Means[i] / NoCases)) / (NoCases - 1);
      if Variances[i] <= 0 then
      begin
        MessageDlg(Format('Item %d has zero variance. Unselect the item.', [i+1]), mtError, [mbOk], 0);
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
      DynVectorPrint(Means, NoItems, title, ColLabels, NoCases, lReport);
      title := 'Total Variances';
      DynVectorPrint(Variances, NoItems, title, ColLabels, NoCases, lReport);
      title := 'Total Standard Deviations';
      DynVectorPrint(StdDevs, NoItems, title, ColLabels, NoCases, lReport);
    end;

    // Show total test score statistics if checked
    if TestStatsChk.Checked then
    begin
      lReport.Add('Total Score:  Mean     %10.3f', [tmean]);
      lReport.Add('              Variance %10.3f', [tvar]);
      lReport.Add('              Std.Dev. %10.3f', [tsd]);
      lReport.Add('');
    end;

    lReport.Add(DIVIDER);
    lReport.Add('');

    lReport.Add('Reference group size: %7d', [nsize[1]]);
    lReport.Add('Focus group size:     %7d', [nsize[2]]);
    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // get Cronbach alpha for total group if checked
    if AlphaChk.Checked then
      AlphaRel(lReport);

    // Get item intercorrelations for total group if checked
    if ItemCorrsChk.Checked then
    begin
      ItemCorrs(lReport);
      lReport.Add(DIVIDER);
      lReport.Add('');
    end;

    // Get item-total score correlations for total group if checked
    if ItemTestChk.Checked then
    begin
      ItemTestCorrs(lReport);
      lReport.Add(DIVIDER);
      lReport.Add('');
    end;

    // Show upper and lower bounds for score group bins
    lReport.Add  ('Conditioning Levels');
    lReport.Add  ('');
    lReport.Add  ('Lower        Upper');
    lReport.Add  ('-----        -----');
    for i := 0 to nolevels-1 do
      lReport.Add('%5d        %5d', [Lbounds[i], Ubounds[i]]);
    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

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
      if (sum = 0) or (sum = NoVariables) then
      begin
        MessageDlg(Format('Item %d in group %d has zero variance.', [i+1, k]), mtError, [mbOK], 0);
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

    LoopIt := 0;

    repeat
      LoopIt := LoopIt + 1;

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

      lReport.Add('COMPUTING M-H CHI-SQUARE, PASS #%d', [LoopIt]);

      for k := 0 to nolevels-1 do
      begin
        for i := 0 to NoCases-1 do
        begin
          subjgrp := Data[i,0];
          for j := 0 to NoItems-1 do
          begin
            RItem := 0;
            value := Data[i,j+1];
            if (LoopIt = 2) and (Code[j] = 'C') then
              RItem := value;

            if value = 1 then
            begin
              if ((Tot[i]+RItem >= Lbounds[k]) and (Tot[i]+RItem <= Ubounds[k])) then
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
              if ((Tot[i]+RItem >= Lbounds[k]) and (Tot[i]+RItem <= Ubounds[k])) then
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
          RowLabels[i] := format('%3d-%3d', [Lbounds[i], Ubounds[i]]);
        DynIntMatPrint(RScrGrpCnt, nolevels, NoItems, 'Score Level Counts by Item', RowLabels, ColLabels,
          'Cases in Reference Group', lReport);
        DynIntMatPrint(FScrGrpCnt, nolevels, NoItems, 'Score Level Counts by Item', RowLabels, ColLabels,
          'Cases in Focus Group', lReport);
      end;

      // Plot Item curves if checked
      if CurvesChk.Checked and (LoopIt = 1) then
        ItemCurves;

      // check for minimum of 10 per category in each item
      // compute NT
      for j := 0 to NoItems-1 do
      begin
        for k := 0 to nolevels-1 do
        begin
          if ((RScrGrpCnt[k,j] < 10) or (FScrGrpCnt[k,j] < 10)) then
            Level10OK[k,j] := 0 // insufficient n
          else
            Level10OK[k,j] := 1;  // 10 or more - OK
          NT[k,j] := RScrGrpCnt[k,j] + FScrGrpCnt[k,j];
        end;
      end;

      for k := 0 to nolevels-1 do
      begin
        if Level10OK[k, 0] = 0 then
          lReport.Add('Insufficient data found in level: %3d - %3d', [Lbounds[k], Ubounds[k]]);
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
          MessageDlg(Format('Window too small at item %d level %d', [j+1, k+1]), mtError, [mbOK], 0);
          exit;
        end else
        begin
          Alpha[j] := AlphaNum[j] / AlphaDen[j];
          MHDiff[j] := -2.35 * ln(Alpha[j]);
        end;
      end;

      // compute expected values
      for j := 0 to NoItems-1 do
      begin
        for k := 0 to nolevels-1 do
          if Level10OK[k,j] = 1 then
            ExpA[k,j] := (RScrGrpCnt[k,j] * (RMHRight[k,j] + FMHRight[k,j] )) / NT[k,j];
      end;

      // compute variances
      for j := 0 to NoItems-1 do
        for k := 0 to nolevels-1 do
          if Level10OK[k,j] = 1 then
          begin
            Rtm := RMHRight[k,j] + FMHRight[k,j];
            Wtm := RMHWrong[k,j] + FMHWrong[k,j];
            VarA[k,j] := (RScrGrpCnt[k,j] * FScrGrpCnt[k,j] * Rtm * Wtm) / (NT[k,j] * NT[k,j] * (NT[k,j]-1));
          end;

      // compute chi-squares
      for j := 0 to NoItems-1 do
      begin
        SumA[j] := 0.0;
        SumExpA[j] := 0.0;
        SumVarA[j] := 0.0;
        for k := 0 to nolevels-1 do
          if Level10OK[k,j] = 1 then
          begin
            SumA[j] := SumA[j] + RMHRight[k,j];
            SumExpA[j] := SumExpA[j] + ExpA[k,j];
            SumVarA[j] := SumVarA[j] + VarA[k,j];
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
          if Level10OK[k,j] = 1 then
            C[j] := C[j] + ((RMHRight[k,j] * FMHWrong[k,j]) / NT[k,j]);
      end;

      for j := 0 to NoItems - 1 do
      begin
        SEMHDDif[j] := 0.0;
        for k := 0 to nolevels-1 do
        begin
          if Level10OK[k,j] = 1 then
          begin
            SEMHDDif[j] := SEMHDDif[j]
              + ( (RMHRight[k,j] * FMHWrong[k,j] ) + ( Alpha[j] * RMHWrong[k,j] * FMHRight[k,j]))
              * ( RMHRight[k,j] + FMHWrong[k,j] + Alpha[j] * ( RMHWrong[k,j]  + FMHRight[k,j] )) / ( 2.0 * NT[k,j] * NT[k,j]);
          end;
        end;
      end;

      for j := 0 to NoItems-1 do
        SEMHDDif[j] := (2.35 / C[j]) * sqrt(SEMHDDif[j]);

      // code results with ETS codes
      for j := 0 to NoItems-1 do
      begin
        if ( (abs(MHDiff[j]) > 1.5) and ((abs(MHDiff[j]) - (1.96 * SEMHDDif[j]) > 1.0))) then
          Code[j] := 'C';
        if ((abs(MHDiff[j]) - (1.96 * SEMHDDif[j]) <= 0.0) or (abs(MHDiff[j]) <= 1.0)) then
          Code[j] := 'A';
        if ((code[j] <> 'A') and (code[j] <> 'C')) then
          Code[j] := 'B';
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
      lReport.Add(
          'CODES  ITEM   SIG.    ALPHA      CHI2    P-VALUE   MH D-DIF  S.E. MH D-DIF');
      lReport.Add(
          '-----  ----   ----   -------  ---------  -------   --------  -------------');
       for j := 0 to noitems-1 do
       begin
         lReport.Add(' %1s %1s  %4d      %3s  %7.3f  %9.3f  %7.3f  %9.3f      %9.3f', [
           code[j],CodeRF[j], j+1, Aster[j],Alpha[j],ChiSqr[j],Prob[j],MHDiff[j], SEMHDDif[j]
         ]);
       end;
       lReport.Add('');

      if LoopIt = 1 then
      begin
        lReport.Add('No. of items purged in pass 1: %d', [TotPurge]);
        lReport.Add('Item Numbers:');
         for j := 0 to NoItems-1 do
         begin
           if Code[j] = 'C' then
             lReport.Add('  %d', [j+1]);
         end;
      end;

      lReport.Add('');
      lReport.Add(DIVIDER);
      lReport.Add('');
    until LoopIt = 2;

    DisplayReport(lReport);
  finally
    lReport.Free;
  end;
end;

procedure TDIFFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TDIFFrm.UpBoundEditEditingDone(Sender: TObject);
var
  level: Integer;
  n: Integer;
begin
  level := LevelScroll.Position;
  if TryStrToInt(UpBoundEdit.Text, n) then
  begin
    UBounds[level] := n;
    if level + 1 = StrToInt(LevelsEdit.Text) then
      exit;
    if LBounds[level+1] = -1 then
      LBounds[level+1] := UBounds[level] + 1;
  end else
    MessageDlg(Format('No valid number in upper bound at level #%d.', [level+1]), mtError, [mbOK], 0);
end;

procedure TDIFFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TDIFFrm.AllBtnClick(Sender: TObject);
var
  i: integer;
begin
  if VarList.Items.Count > 0 then
  begin
    for i := 0 to VarList.Items.Count - 1 do
      ItemsList.Items.Add(VarList.Items[i]);
    VarList.Clear;
    UpdateBtnStates;
  end;
end;

procedure TDIFfrm.AlphaRel(AReport: TStrings);
var
  i: integer;
  Alpha1, SEMeas: double;
begin
  Alpha1 := 0.0;
  for i := 0 to NoItems-1 do
    Alpha1 := Alpha1 + variances[i]; // sum of item variances
  Alpha1  := Alpha1 / tvar;
  Alpha1 := 1.0 - Alpha1;
  Alpha1 := (NoItems / (NoItems - 1.0)) * Alpha1;

  SEMeas := tsd * sqrt(1.0 - Alpha1);
  AReport.Add('Alpha Reliability Estimate for Test: %8.4f', [Alpha1]);
  AReport.Add('S.E. of Measurement:                 %8.4f', [SEMeas]);
  AReport.Add('');
end;

procedure TDIFfrm.ItemCorrs(AReport: TStrings);
var
  i, j, k: integer;
  title: string;
begin
  // cross-products
  for i := 0 to NoItems-1 do
    for j := 0 to NoItems-1 do
      for k := 0 to NoCases-1 do
        CorMat[i,j] := CorMat[i,j] + (Data[k,i+1] * Data[k,j+1]);

  // covariances
  for i := 0 to NoItems-1 do
    for j := 0 to NoItems-1 do
      CorMat[i,j] := (CorMat[i,j] - (NoCases * Means[i] * Means[j])) / (NoCases-1);

  // correlations
  for i := 0 to NoItems-1 do
    for j := 0 to NoItems-1 do
      CorMat[i,j] := CorMat[i,j] / (StdDevs[i] * StdDevs[j]);

  // show results
  title := 'Correlations Among Items';
  MatPrint(CorMat, NoItems, NoItems, title, RowLabels, ColLabels, NoCases, AReport);
end;

procedure TDIFfrm.ItemTestCorrs(AReport: TStrings);
var
  i, j: integer;
  Cors: DblDyneVec;
  title: string;
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
  title := 'Item-Total Correlations';
  DynVectorPrint(Cors, NoItems, title, ColLabels, NoCases, AReport);

  // release memory
  Cors := nil;
end;

procedure TDIFfrm.ItemCurves;
var
  i, j: integer;
  XPlotPts: DblDyneMat;
  YPlotPts: DblDyneMat;
  max: integer;
begin
  SetLength(XPlotPts, 1, nolevels);
  SetLength(YPlotPts, 2, nolevels);

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
    for j := 0 to nolevels-1 do  //get points to plot
    begin
      XPlotPts[0, j] := Lbounds[j];
      YPlotPts[0, j] := RMHRight[j,i];
      YPlotPts[1, j] := FMHRight[j,i];
    end;

    // Plot the points
    GraphFrm.BackColor := clWhite;
    GraphFrm.ShowLeftWall := true;
    GraphFrm.ShowRightWall := true;
    GraphFrm.ShowBottomWall := true;
    GraphFrm.ShowBackWall := true;
    GraphFrm.BackColor := GRAPH_BACK_COLOR;
    GraphFrm.WallColor := GRAPH_WALL_COLOR;
    GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
    GraphFrm.Heading := Format('Blue: Reference, Red: Focus for item %d', [i+1]);
    GraphFrm.XTitle := 'Lower bounds of levels';
    GraphFrm.YTitle := 'Frequencies';
    GraphFrm.nosets := 2;
    GraphFrm.nbars := nolevels;
    GraphFrm.barwideprop := 0.5;
    GraphFrm.miny := 0.0;
    GraphFrm.maxy := max;
    GraphFrm.AutoScaled := false;
    GraphFrm.GraphType := 5; // 2d line charts
    GraphFrm.PtLabels := false;
    GraphFrm.SetLabels[1] := 'Reference';
    GraphFrm.SetLabels[2] := 'Focus';
    GraphFrm.Ypoints := YPlotPts;
    GraphFrm.Xpoints := XPlotPts;

    if (GraphFrm.ShowModal <> mrOK) then
      exit;
  end; // next item

  XPlotPts := nil;
  YPlotPts := nil;
end;

procedure TDIFfrm.UpdateBtnStates;
var
  lSelected: Boolean;
begin
  lSelected := AnySelected(VarList);
  ItemInBtn.Enabled := lSelected;
  GrpInBtn.Enabled := lSelected;
  ItemOutBtn.Enabled := AnySelected(ItemsList) and (GroupVarEdit.Text = '');
  GrpOutBtn.Enabled := GroupVarEdit.Text <> '';
  AllBtn.Enabled := VarList.Items.Count > 0;
end;

function TDIFFrm.ValidNumEdit(AEdit: TEdit; AName: String;
  out AValue: Integer): Boolean;
begin
  Result := false;
  if AEdit.Text = '' then
  begin
    AEdit.SetFocus;
    MessageDlg(AName + ' not specified.', mtError, [mbOK], 0);
    exit;
  end;
  if not TryStrToInt(AEdit.Text, AValue) then
  begin
    AEdit.SetFocus;
    MessageDlg(AName + ' is not a valid number.', mtError, [mbOk], 0);
    exit;
  end;
  Result := true;
end;


initialization
  {$I difunit.lrs}

end.

