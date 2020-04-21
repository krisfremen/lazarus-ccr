// Data file not clear, probably PolyDIFData.laz
//  - lowest item score 1
//  - highest item score 5
//  - reference group score 1
//  - focus group score 2
//  - No of grouping levels 3
//  - Level 1: lower bound 0, upper bound 1
//  - Level 2: lower bound 2, upper bound 3
//  - Level 3: lower bound 4, upper bound 5
// The results obtained this way match the pdf file.

unit PolyDifUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, OutputUnit, FunctionsLib, GraphLib, ContextHelpUnit;

type

  { TPolyDIFFrm }

  TPolyDIFFrm = class(TForm)
    Bevel1: TBevel;
    GroupBox2: TGroupBox;
    HelpBtn: TButton;
    LevelNoEdit: TStaticText;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    LowScoreEdit: TEdit;
    HiScoreEdit: TEdit;
    RefGrpEdit: TEdit;
    TrgtGrpEdit: TEdit;
    GraphChk: TCheckBox;
    GroupBox1: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    LowBoundEdit: TEdit;
    UpBoundEdit: TEdit;
    Label10: TLabel;
    Label9: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    LevelsEdit: TEdit;
    ItemInBtn: TBitBtn;
    ItemOutBtn: TBitBtn;
    AllBtn: TBitBtn;
    GrpInBtn: TBitBtn;
    GrpOutBtn: TBitBtn;
    GroupVarEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ItemsList: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    LevelScroll: TScrollBar;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GrpInBtnClick(Sender: TObject);
    procedure GrpOutBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ItemInBtnClick(Sender: TObject);
    procedure ItemOutBtnClick(Sender: TObject);
    procedure LevelScrollChange(Sender: TObject);
    procedure LevelsEditEditingDone(Sender: TObject);
    procedure LowBoundEditEditingDone(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure UpBoundEditEditingDone(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    NoItems: integer;
    nocats: integer;
    ColNoSelected: IntDyneVec;
    ColLabels, RowLabels: StrDyneVec;
    Ubounds: IntDyneVec;      // upper and lower bounds of score groups
    Lbounds: IntdyneVec;
    procedure UpdateBtnStates;
    function ValidNumEdit(AEdit: TEdit; AName: String; out AValue: Integer): Boolean;

  public
    { public declarations }
  end; 

var
  PolyDIFFrm: TPolyDIFFrm;

implementation

uses
  Math, StrUtils, Utils;

{ TPolyDIFFrm }

procedure TPolyDIFFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  //allocate space on heap
  SetLength(ColLabels, NoVariables + 1);
  SetLength(RowLabels, NoVariables + 1);
  SetLength(ColNoSelected, NoVariables);
  SetLength(Lbounds, NoVariables * 10);
  SetLength(Ubounds, NoVariables * 10);
  for i:=0 to High(LBounds) do LBounds[i] := -1;
  for i:=0 to High(UBounds) do UBounds[i] := -1;

  VarList.Clear;
  ItemsList.Clear;
  GroupVarEdit.Text := '';
  RefGrpEdit.Text := '';
  TrgtGrpEdit.Text := '';
  LowScoreEdit.Text := '';
  HiScoreEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  LevelScroll.Min := 0; //1;
  LevelScroll.Max := 0; //LevelScroll.Min;
  LevelScroll.Position := 0; //1;
  {
  if NoVariables > 0 then
    LevelScroll.Max := NoVariables;
    }
  LevelsEdit.Text := ''; //IntToStr(NoVariables);
  LevelNoEdit.Caption := ''; //'1';
  LowBoundEdit.Text := ''; //'0';
  UpBoundEdit.Text := ''; //'2';
  ComputeBtn.Enabled := false;

  UpdateBtnStates;
end;

procedure TPolyDIFFrm.UpBoundEditEditingDone(Sender: TObject);
var
  level: Integer;
begin
  level := StrToInt(LevelNoEdit.Caption) - 1;
  Ubounds[level] := StrToInt(UpBoundEdit.Text);
  if level + 1 = StrToInt(LevelsEdit.Text) then
  begin
    ComputeBtn.Enabled := true;
    exit;
  end;
  LowBoundEdit.Text := IntToStr(UBounds[level]); //IntToStr(Ubounds[level] + 1);
//  LowBoundEdit.SetFocus;
end;

procedure TPolyDIFFrm.FormActivate(Sender: TObject);
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

  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TPolyDIFFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TPolyDIFFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TPolyDIFFrm.GrpInBtnClick(Sender: TObject);
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

procedure TPolyDIFFrm.GrpOutBtnClick(Sender: TObject);
begin
  if GroupVarEdit.Text <> '' then
  begin
    VarList.Items.Add(GroupVarEdit.Text);
    GroupVarEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TPolyDIFFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TPolyDIFFrm.ItemInBtnClick(Sender: TObject);
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
  LevelsEdit.Text := IntToStr(ItemsList.Count);
  LevelsEditEditingDone(nil);
end;

procedure TPolyDIFFrm.ItemOutBtnClick(Sender: TObject);
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
  LevelsEdit.Text := IntToStr(ItemsList.Count);
  LevelsEditEditingDone(nil);
end;

procedure TPolyDIFFrm.LevelScrollChange(Sender: TObject);
var
  level: integer;
begin
  level := LevelScroll.Position;
  LevelNoEdit.Caption := IntToStr(level + 1);

  if LBounds[level] = -1 then
    LowBoundEdit.Text := ''
  else
    LowBoundEdit.Text :=IntToStr(LBounds[level]);

  if UBounds[level] = -1 then
    UpBoundEdit.Text := ''
  else
    UpBoundEdit.Text := IntToStr(UBounds[level]);
end;

  // wp: Setting focus to other controls makes the form very difficult to use.

{
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
}

procedure TPolyDIFFrm.LevelsEditEditingDone(Sender: TObject);
var
  L: Integer;
begin
  if ValidNumEdit(LevelsEdit, 'No. of Grouping Levels', L) then
  begin
    LevelScroll.Max := Max(L - 1, 0);
    LevelScroll.Min := 0;
    LevelNoEdit.Caption := IntToStr(LevelScroll.Position + 1);
    //LevelScroll.Enabled := true;
    //LowBoundEdit.SetFocus;
  end;
end;

procedure TPolyDIFFrm.LowBoundEditEditingDone(Sender: TObject);
var
  level: integer;
begin
  level := LevelScroll.Position;
//  level := StrToInt(LevelNoEdit.Caption) - 1;
  Lbounds[level] := StrToInt(LowBoundEdit.Text);
  //UpBoundEdit.Set
end;

procedure TPolyDIFFrm.AllBtnClick(Sender: TObject);
var
  i: integer;
begin
  if VarList.Items.Count < 1 then
    exit;
  for i := 0 to VarList.Items.Count - 1 do
    ItemsList.Items.Add(VarList.Items[i]);
  VarList.Clear;
  UpdateBtnStates;
  LevelsEdit.Text := IntToStr(ItemsList.Count);
  LevelsEditEditingDone(nil);
end;

procedure TPolyDIFFrm.ComputeBtnClick(Sender: TObject);
var
  i, j, k : integer;
  itm, nolevels, level : integer;
  grpvar : integer;
  subjgrp : integer;
  subjtot : integer;
  value : integer;
  cellstring : string;
  title : string;
  nsize : array [1..2] of integer;
  FData : IntDyneCube; //no. of category values within item for focal group
  RData : IntDyneCube; //no. of category values within item for reference group
  TotData : IntDyneCube; // sum of the above two
  t, Mf, Mb, Sf, Sb, Nb, Nf, df, d, Sd : DblDyneVec;
  Zc, Vart, BigJ, SumE, SumV, Term1, MY, prob : double;
  X, BigDnum, BigDden, BigD, BigDS, Zd, M2, E, VarE, Ti, dftot : double;
  loscore, hiscore : integer;
  lReport: TStrings;
begin
  NoItems := ItemsList.Items.Count;
  if NoItems = 0 then
  begin
    MessageDlg('No items selected.', mtError, [mbOK], 0);
    exit;
  end;

  if not ValidNumEdit(LevelsEdit, 'Number of Grouping Levels', noLevels) then
    exit;
  if not ValidNumEdit(LowScoreEdit, 'Lowest Item Score', loscore) then
    exit;
  if not ValidNumEdit(HiScoreEdit, 'Highest Item Score', hiscore) then
    exit;
  if not ValidNumEdit(RefGrpEdit, 'Reference Group Code', i) then
    exit;
  if not ValidNumEdit(TrgtGrpEdit, 'Focus Group Code', i) then
    exit;

  lReport := TStringList.Create;
  try
    lReport.Add('POLYTOMOUS ITEM DIF ANALYSIS');
    lReport.Add('adapted by Bill Miller from');
    lReport.Add('Procedures for extending item bias detection techniques');
    lReport.Add('by Catherine Welch and H.D. Hoover, 1993');
    lReport.Add('Applied Measurement in Education 6(1), pages 1-19.');
    lReport.Add('');

    nocats := hiscore - loscore + 1; // 0 to highest score

    SetLength(FData,NoItems,hiscore+10,nolevels+10);
    SetLength(RData,NoItems,hiscore+10,nolevels+10);
    SetLength(TotData,NoItems,hiscore+10,nolevels+10);
    SetLength(t,nolevels);
    SetLength(Mf,nolevels);
    SetLength(Mb,nolevels);
    SetLength(Sf,nolevels);
    SetLength(Sb,nolevels);
    SetLength(Nb,nolevels);
    SetLength(Nf,nolevels);
    SetLength(df,nolevels);
    SetLength(d,nolevels);
    SetLength(Sd,nolevels);

    for k := 1 to 2 do
      nsize[k] := 0;

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
      MessageDlg('No group variable found.', mtError, [mbOK], 0);
      exit;
    end;

    // read data (score group and items)
    for i := 1 to NoCases do
    begin
      // Get group (reference or target)
      value := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[grpvar,i])));
      subjgrp := 0;
      if value = StrToInt(RefGrpEdit.Text) then subjgrp := 1; // reference grp
      if value = StrToInt(TrgtGrpEdit.Text) then subjgrp := 2; // target group
      if subjgrp = 0 then
      begin
        MessageDlg('Bad group code for a subject.', mtError, [mbOK], 0);
        exit;
      end;
      nsize[subjgrp] := nsize[subjgrp] + 1;

      // get item score and subject total
      subjtot := 0;
      for j := 1 to NoItems do
      begin
        itm := ColNoSelected[j-1];
        value := Round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[itm,i])));
        subjtot := subjtot + value;
      end;

      // get score level category
      level := 0;
      for k := 0 to NoLevels-1 do
        if ((subjtot >= Lbounds[k]) and (subjtot <= Ubounds[k])) then
          level := k;

      // add to data
      for j := 1 to NoItems do
      begin
        itm := ColNoSelected[j-1];
        value := Round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[itm,i])));
        value := value - loscore;
        if subjgrp = 1 then
          RData[j-1,value,level] := RData[j-1,value,level] + 1
        else
          FData[j-1,value,level] := FData[j-1,value,level] + 1;
        TotData[j-1,value,level] := TotData[j-1,value,level] + 1;
      end;
    end; // next case i

     // Show upper and lower bounds for score group bins
    lReport.Add('Conditioning Levels');
    lReport.Add('');
    lReport.Add('Lower     Upper');
    lReport.Add('-----     -----');
    for i := 0 to nolevels-1 do
      lReport.Add('%5d     %5d', [Lbounds[i], Ubounds[i]]);
    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // obtain statistics and print frequency in categories for each item
    for i := 1 to NoItems do
    begin
      lReport.Add('ITEM ' + IntToStr(i));
      lReport.Add('');
      lReport.Add('Observed Category Frequencies');
      lReport.Add('Item  Group  Level  Category Number');
      Title :=    '                  ';
      for j := 0 to nocats-1 do
        Title := Title + Format('%10d', [j+loscore]);
      lReport.Add(Title);
      lReport.Add('----  -----  -----  ' + DupeString('-', 10*NoCats)); //---------------');

      Zc := 0.0;
      dftot := 0.0;
      BigDnum := 0.0;
      BigDden := 0.0;
      M2 := 0.0;
      SumE := 0.0; // second term of M2 numerator
      SumV := 0.0; // denominator of M2
      Term1 := 0.0; // first term of M2 numerator
      for k := 0 to nolevels-1 do
      begin
        Mf[k] := 0.0;
        Mb[k] := 0.0;
        Sf[k] := 0.0;
        Sb[k] := 0.0;
        t[k] := 0.0;
        Nb[k] := 0.0;
        Nf[k] := 0.0;
        df[k] := 0.0;
        d[k] := 0.0;
        Sd[k] := 0.0;
        VarE := 0.0;
        E := 0.0;
        Ti := 0.0;
        MY := 0.0;
        Title := Format('%3d   Ref.    %3d ', [i, k+1]);
        for j := 0 to nocats-1 do
        begin
          Title := Title + Format('%10d', [RData[i-1,j,k]]);
          X := RData[i-1,j,k] * (j+loscore);
          Mb[k] := Mb[k] + X;
          Sb[k] := Sb[k] +  (X * X);
          Nb[k] := Nb[k] + RData[i-1,j,k];
        end;
        lReport.Add(Title);

        Title := Format('%3d   Focal   %3d ', [i, k+1]);
        for j := 0 to nocats-1 do
        begin
          Title := Title + Format('%10d', [FData[i-1,j,k]]);
          X := FData[i-1,j,k] * (j + loscore);
          Mf[k] := Mf[k] + X;
          Sf[k] := Sf[k] + (X * X);
          Nf[k] := Nf[k] + FData[i-1,j,k];
        end;
        lReport.Add(Title);

        Title := Format('%3d   Total   %3d ', [i, k+1]);
        for j := 0 to nocats-1 do
          Title := Title + Format('%10d', [TotData[i-1,j,k]]);
        lReport.Add(Title);
        lReport.Add('');

        for j := 0 to nocats-1 do
        begin
          Term1 := Term1 + FData[i-1,j,k] * (j+loscore);
          X := TotData[i-1,j,k] * (j+loscore);
          E := E + X;
          Ti := Ti + TotData[i-1,j,k];
          MY := MY + TotData[i-1,j,k] * (j + loscore);
          VarE := VarE + TotData[i-1,j,k] * (j + loscore)*(j + loscore);
        end;

        if Ti = 0 then  // wp: added to avoid crash when Ti is 0. Not clear why this happens in my test...
        begin
          lReport.Add('Ti = zero --> skip to avoid division by zero');
          Continue;
        end;

        E := E / Ti;
        E := Nf[k] * E;
        SumE := SumE + E; // second term of num. of m2
        VarE := (Ti * VarE) - (MY * MY);
        VarE := ((Nf[k] * Nb[k]) / (Ti * Ti * (Ti - 1.0))) * VarE;
        SumV := SumV + VarE; // den. of M2
        if (Nf[k] + Nb[k]) < 5 then continue;
        Sf[k] := Sf[k] - (Mf[k] * Mf[k] / Nf[k]);
        Sf[k] := Sf[k] / (Nf[k] - 1.0);
        Sb[k] := Sb[k] - (Mb[k] * Mb[k] / Nb[k]);
        Sb[k] := Sb[k] / (Nb[k] - 1.0);
        Mf[k] := Mf[k] / Nf[k];
        Mb[k] := Mb[k] / Nb[k];
        t[k] := Mf[k] - Mb[k];
        df[k] := Nb[k] + Nf[k] - 2.0;
        Vart := ((Sf[k] * Nf[k]) + (Sb[k] * Nb[k])) / df[k];
        Vart := sqrt(Vart * ((1.0 / Nf[k]) + (1.0 / Nb[k])));
        t[k] := t[k] / Vart;
        Zc := Zc + t[k];
        dftot := dftot + (df[k] / (df[k] - 2.0));
        BigJ := 1.0 - (3.0 / (4.0 * df[k] - 1.0));
        d[k] := BigJ * sqrt((Nb[k] * Nf[k]) / (Nb[k] * Nf[k]));
        d[k] := d[k] * t[k];
        Sd[k] := (BigJ * BigJ) * (df[k] / (df[k] - 2.0));
        Sd[k] := Sd[k] * (Nb[k] + Nf[k]) / (Nb[k] * Nf[k]);
        Sd[k] := Sd[k] + (d[k] * d[k]) * ((BigJ * BigJ * df[k])/(df[k]-2.0) - 1.0);
        BigDnum := BigDnum + d[k] / Sd[k];
        BigDden := BigDden + 1.0 / Sd[k];
      end; // next level k
      M2 := (Term1 - SumE) * (Term1 - SumE) / SumV;

      lReport.Add('');
      lReport.Add('t-test values for Reference and Focus Means for each level');
      lReport.Add('');
      for k := 0 to nolevels-1 do
      begin
        lReport.Add('Level %d', [k+1]);
        lReport.Add('  Mean Reference:               %10.3f    SD: %10.3f    N: %5.0f', [Mb[k], sqrt(Sb[k]), Nb[k]]);
        lReport.Add('  Mean Focal:                   %10.3f    SD: %10.3f    N: %5.0f', [Mf[k], sqrt(Sf[k]), Nf[k]]);
        lReport.Add('  t:                            %10.3f    with %.f degrees of freedom', [t[k], df[k]]);
        lReport.Add('');
      end;

      Zc := Zc / dftot; // HW1 statistic
      prob := 1.0 - probz(Zc);
      lReport.Add(  'Composite z statistic:          %10.3f    Probability > |z|: %6.3f', [Zc, prob]);

      BigD := BigDnum / BigDden;
      BigDS := 1.0 / sqrt(BigDden);
      Zd := BigD / BigDS; // HW3 statistic
      prob := 1.0 - probz(Zd);
      lReport.Add(  'Weighted Composite z statistic: %10.3f    Probability > |z|: %6.3f', [Zd, prob]);

      prob := 1.0 - chisquaredprob(M2, 1);
      lReport.Add(  'Generalized Mantel-Haenszel:    %10.3f    with D.F. = 1 and Prob. > Chi-Sqr. %.3f', [M2, prob]);

      lReport.Add('');
      lReport.Add(DIVIDER);
      lReport.Add('');

      if GraphChk.Checked then
      begin
        GraphFrm.nosets := 2;
        GraphFrm.nbars := nolevels;
        GraphFrm.Heading := 'Level Means';
        GraphFrm.XTitle := 'Level';
        GraphFrm.YTitle := 'Mean';
        SetLength(GraphFrm.Ypoints, 2, nolevels+1);
        SetLength(GraphFrm.Xpoints, 1, nolevels+1);
        for k := 0 to nolevels-1 do
        begin
          GraphFrm.Ypoints[0,k] := Mb[k];
          GraphFrm.Xpoints[0,k] := k+1;
          GraphFrm.Ypoints[1,k] := Mf[k];
        end;
        GraphFrm.barwideprop := 0.5;
        GraphFrm.AutoScaled := true;
        GraphFrm.GraphType := 2; // 3d Vertical Bar Chart
        GraphFrm.ShowLeftWall := true;
        GraphFrm.ShowRightWall := true;
        GraphFrm.ShowBottomWall := true;
        GraphFrm.ShowBackWall := true;
        GraphFrm.BackColor := GRAPH_BACK_COLOR;
        GraphFrm.WallColor := GRAPH_WALL_COLOR;
        GraphFrm.FloorColor := GRAPH_FLOOR_COLOR;
        GraphFrm.ShowModal;
      end;
    end; // next item

    DisplayReport(lReport);

  finally
    lReport.Free;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
    FData := nil;
    RData := nil;
    TotData := nil;
    t := nil;
    Mf := nil;
    Mb := nil;
    Sf := nil;
    Sb := nil;
    Nb := nil;
    Nf := nil;
    df := nil;
    d := nil;
    Sd:= nil;
  end;
end;

procedure TPolyDIFFrm.UpdateBtnStates;
var
  lSelected: Boolean;
begin
  lSelected := AnySelected(VarList);
  ItemInBtn.Enabled := lSelected;
  GrpInBtn.Enabled := lSelected and (GroupVarEdit.Text = '');

  ItemOutBtn.Enabled := AnySelected(ItemsList);
  GrpOutBtn.Enabled := GroupVarEdit.Text <> '';

  AllBtn.Enabled := VarList.Items.Count > 0;
end;

function TPolyDIFFrm.ValidNumEdit(AEdit: TEdit; AName: String;
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

procedure TPolyDIFFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I polydifunit.lrs}

end.

