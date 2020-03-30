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
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
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
    LevelNoEdit: TEdit;
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
    procedure CancelBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GrpInBtnClick(Sender: TObject);
    procedure GrpOutBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ItemInBtnClick(Sender: TObject);
    procedure ItemOutBtnClick(Sender: TObject);
    procedure LevelScrollScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure LevelsEditExit(Sender: TObject);
    procedure LowBoundEditExit(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
    procedure UpBoundEditExit(Sender: TObject);
  private
    { private declarations }
     NoItems : integer;
     FAutoSized: Boolean;
   nocats : integer;
   ColNoSelected : IntDyneVec;
   ColLabels, RowLabels : StrDyneVec;
   Ubounds : IntDyneVec; // upper and lower bounds of score groups
   Lbounds : IntdyneVec;

  public
    { public declarations }
  end; 

var
  PolyDIFFrm: TPolyDIFFrm;

implementation

uses
  Math;

{ TPolyDIFFrm }

procedure TPolyDIFFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     ItemsList.Clear;
     GroupVarEdit.Text := '';
     ItemInBtn.Enabled := true;
     ItemOutBtn.Enabled := false;
     AllBtn.Enabled := true;
     GrpInBtn.Enabled := true;
     GrpOutBtn.Enabled := false;
//     MHChk.Checked := true;
     RefGrpEdit.Text := '';
     TrgtGrpEdit.Text := '';
     LowScoreEdit.Text := '';
     HiScoreEdit.Text := '';
     LevelsEdit.Text := '';
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     if NoVariables > 0 then LevelScroll.Max := NoVariables;
     LevelNoEdit.Text := '1';
     LowBoundEdit.Text := '0';
     UpBoundEdit.Text := '2';
     LevelScroll.Min := 1;
     LevelScroll.Position := 1;
     //allocate space on heap
     SetLength(ColLabels,NoVariables+1);
     SetLength(RowLabels,NoVariables+1);
     SetLength(ColNoSelected,NoVariables);
     SetLength(Lbounds,NoVariables * 10);
     SetLength(Ubounds,NoVariables * 10);
end;

procedure TPolyDIFFrm.ReturnBtnClick(Sender: TObject);
begin
     Ubounds := nil;
     Lbounds := nil;
     ColNoSelected := nil;
     RowLabels := nil;
     ColLabels := nil;
     Close;
end;

procedure TPolyDIFFrm.UpBoundEditExit(Sender: TObject);
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

procedure TPolyDIFFrm.FormActivate(Sender: TObject);
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

  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TPolyDIFFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TPolyDIFFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TPolyDIFFrm.GrpInBtnClick(Sender: TObject);
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

procedure TPolyDIFFrm.GrpOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(GroupVarEdit.Text);
     GroupVarEdit.Text := '';
     GrpOutBtn.Enabled := false;
     GrpInBtn.Enabled := true;
end;

procedure TPolyDIFFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TPolyDIFFrm.ItemInBtnClick(Sender: TObject);
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

procedure TPolyDIFFrm.ItemOutBtnClick(Sender: TObject);
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

procedure TPolyDIFFrm.LevelScrollScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
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

procedure TPolyDIFFrm.LevelsEditExit(Sender: TObject);
begin
     LevelScroll.Max := StrToInt(LevelsEdit.Text);
     LowBoundEdit.SetFocus;
end;

procedure TPolyDIFFrm.LowBoundEditExit(Sender: TObject);
VAR i : integer;
begin
     i := StrToInt(LevelNoEdit.Text);
     Lbounds[i-1] := StrToInt(LowBoundEdit.Text);
     UpBoundEdit.SetFocus;
end;

procedure TPolyDIFFrm.CancelBtnClick(Sender: TObject);
begin
     Ubounds := nil;
     Lbounds := nil;
     ColNoSelected := nil;
     RowLabels := nil;
     ColLabels := nil;
     Close;
end;

procedure TPolyDIFFrm.AllBtnClick(Sender: TObject);
VAR i : integer;
begin
     if VarList.Items.Count < 1 then exit;
     for i := 0 to VarList.Items.Count - 1 do
          ItemsList.Items.Add(VarList.Items.Strings[i]);
     VarList.Clear;
     ItemInBtn.Enabled := false;
     ItemOutBtn.Enabled := true;
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
begin
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Polytomous Item DIF Analysis adapted by Bill Miller from');
     OutputFrm.RichEdit.Lines.Add('Procedures for extending item bias detection techniques');
     OutputFrm.RichEdit.Lines.Add('by Catherine Welch and H.D. Hoover, 1993');
     OutputFrm.RichEdit.Lines.Add('Applied Measurement in Education 6(1), pages 1-19.');
     OutputFrm.RichEdit.Lines.Add('');

     NoItems := ItemsList.Items.Count;
     loscore := StrToInt(LowScoreEdit.Text);
     hiscore := StrToInt(HiScoreEdit.Text);
     nocats := hiscore - loscore + 1; // 0 to highest score
     nolevels := StrToInt(LevelsEdit.Text);
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

     // read data (score group and items)
     for i := 1 to NoCases do
     begin
          subjtot := 0;
          // Get group (reference or target)
          value := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[grpvar,i])));
          subjgrp := 0;
          if value = StrToInt(RefGrpEdit.Text) then subjgrp := 1; // reference grp
          if value = StrToInt(TrgtGrpEdit.Text) then subjgrp := 2; // target group
          if subjgrp = 0 then
          begin
               ShowMessage('Error - Bad group code for a subject.');
               exit;
          end;
          nsize[subjgrp] := nsize[subjgrp] + 1;

          for j := 1 to NoItems do // get item score and subject total
          begin
               itm := ColNoSelected[j-1];
               value := Round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[itm,i])));
               subjtot := subjtot + value;
          end;

          level := 0;
          for k := 0 to NoLevels-1 do   // get score level category
          begin
               if ((subjtot >= Lbounds[k]) and (subjtot <= Ubounds[k])) then
                  level := k;
          end;

          for j := 1 to NoItems do // add to data
          begin
               itm := ColNoSelected[j-1];
               value := Round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[itm,i])));
               value := value - loscore;
               if subjgrp = 1 then
                    RData[j-1,value,level] := RData[j-1,value,level] + 1
               else FData[j-1,value,level] := FData[j-1,value,level] + 1;
                    TotData[j-1,value,level] := TotData[j-1,value,level] + 1;
          end;
     end; // next case i

     // Show upper and lower bounds for score group bins
     OutputFrm.RichEdit.Lines.Add('Conditioning Levels');
     OutputFrm.RichEdit.Lines.Add('Lower        Upper');
     for i := 0 to nolevels-1 do
     begin
          cellstring := format('%5d        %5d',[Lbounds[i],Ubounds[i]]);
          OutputFrm.RichEdit.Lines.Add(cellstring);
     end;
     OutputFrm.RichEdit.Lines.Add('');

     // obtain statistics and print frequency in categories for each item
     for i := 1 to NoItems do
     begin
          OutputFrm.RichEdit.Lines.Add('Observed Category Frequencies');
          OutputFrm.RichEdit.Lines.Add('Item  Group  Level  Category Number');
          Title := '               ';
          for j := 0 to nocats-1 do Title := Title + format('%10d',[j+loscore]);
          OutputFrm.RichEdit.Lines.Add(Title);
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
               Title := format('%3d   Ref.  %3d',[i,k+1]);
               for j := 0 to nocats-1 do
               begin
                   Title := Title + format('%10d',[RData[i-1,j,k]]);
                   X := RData[i-1,j,k] * (j+loscore);
                   Mb[k] := Mb[k] + X;
                   Sb[k] := Sb[k] +  (X * X);
                   Nb[k] := Nb[k] + RData[i-1,j,k];
               end;
               OutputFrm.RichEdit.Lines.Add(Title);
               Title := format('%3d   Focal %3d',[i,k+1]);
               for j := 0 to nocats-1 do
               begin
                   Title := Title + format('%10d',[FData[i-1,j,k]]);
                   X := FData[i-1,j,k] * (j + loscore);
                   Mf[k] := Mf[k] + X;
                   Sf[k] := Sf[k] + (X * X);
                   Nf[k] := Nf[k] + FData[i-1,j,k];
               end;
               OutputFrm.RichEdit.Lines.Add(Title);
               Title := format('%3d   Total %3d',[i,k+1]);
               for j := 0 to nocats-1 do
                   Title := Title + format('%10d',[TotData[i-1,j,k]]);
               OutputFrm.RichEdit.Lines.Add(Title);
               OutputFrm.RichEdit.Lines.Add('');
               for j := 0 to nocats-1 do
               begin
                    Term1 := Term1 + FData[i-1,j,k] * (j+loscore);
                    X := TotData[i-1,j,k] * (j+loscore);
                    E := E + X;
                    Ti := Ti + TotData[i-1,j,k];
                    MY := MY + TotData[i-1,j,k] * (j + loscore);
                    VarE := VarE + TotData[i-1,j,k] * (j + loscore)*(j + loscore);
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
          Title := 't-test values for Reference and Focus Means for each level';
          OutputFrm.RichEdit.Lines.Add(Title);
          for k := 0 to nolevels-1 do
          begin
               Title := format('Mean Reference = %10.3f SD = %10.3f N = %5.0f',[Mb[k],sqrt(Sb[k]),Nb[k]]);
               OutputFrm.RichEdit.Lines.Add(Title);
               Title := format('Mean Focal     = %10.3f SD = %10.3f N = %5.0f',[Mf[k],sqrt(Sf[k]),Nf[k]]);
               OutputFrm.RichEdit.Lines.Add(Title);
               Title := format('Level %3d t = %8.3f with deg. freedom = %5.0f',[k+1,t[k],df[k]]);
               OutputFrm.RichEdit.Lines.Add(Title);
          end;
          Zc := Zc / dftot; // HW1 statistic
          prob := 1.0 - probz(Zc);
          Title := format('Composite z statistic = %6.3f. Prob. > |z| = %6.3f',[Zc, prob]);
          OutputFrm.RichEdit.Lines.Add(Title);
          BigD := BigDnum / BigDden;
          BigDS := 1.0 / sqrt(BigDden);
          Zd := BigD / BigDS; // HW3 statistic
          prob := 1.0 - probz(Zd);
          Title := format('Weighted Composite z statistic = %6.3f. Prob. > |z| = %6.3f',[Zd, prob]);
          OutputFrm.RichEdit.Lines.Add(Title);
          prob := 1.0 - chisquaredprob(M2,1);
          Title := format('Generalized Mantel-Haenszel = %10.3f with D.F. = 1 and Prob. > Chi-Sqr. = %6.3f',[M2, prob]);
          OutputFrm.RichEdit.Lines.Add(Title);
          OutputFrm.ShowModal;
          OutputFrm.RichEdit.Clear;
          if GraphChk.Checked then
          begin
               GraphFrm.nosets := 2;
               GraphFrm.nbars := nolevels;
               GraphFrm.Heading := 'Level Means';
               GraphFrm.XTitle := 'Level';
               GraphFrm.YTitle := 'Mean';
               SetLength(GraphFrm.Ypoints,2,nolevels+1);
               SetLength(GraphFrm.Xpoints,1,nolevels+1);
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
               GraphFrm.BackColor := clYellow;
               GraphFrm.WallColor := clBlack;
               GraphFrm.ShowModal;
          end;
     end; // next item

     // clean up the heap
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


initialization
  {$I polydifunit.lrs}

end.

