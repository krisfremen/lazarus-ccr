unit FriedmanUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, OutPutUnit, DataProcs, FunctionsLib, MatrixLib,
  ContextHelpUnit;

type

  { TFriedmanFrm }

  TFriedmanFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    GrpVar: TEdit;
    GrpIn: TBitBtn;
    GrpOut: TBitBtn;
    Label2: TLabel;
    Label3: TLabel;
    TreatVars: TListBox;
    TrtIn: TBitBtn;
    TrtOut: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GrpInClick(Sender: TObject);
    procedure GrpOutClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure TrtInClick(Sender: TObject);
    procedure TrtOutClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutosized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  FriedmanFrm: TFriedmanFrm;

implementation

uses
  Math, Utils;

{ TFriedmanFrm }

procedure TFriedmanFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Items.Clear;
  TreatVars.Items.Clear;
  GrpVar.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TFriedmanFrm.TrtInClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      TreatVars.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end
    else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TFriedmanFrm.TrtOutClick(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while i < TreatVars.Items.Count do
  begin
    if TreatVars.Selected[i] then
    begin
      VarList.Items.Add(TreatVars.Items[i]);
      TreatVars.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TFriedmanFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TFriedmanFrm.FormActivate(Sender: TObject);
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

  FAutoSized := true;
end;

procedure TFriedmanFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TFriedmanFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TFriedmanFrm.ComputeBtnClick(Sender: TObject);
Var
   i, j, k, L, col, itemp, GrpCol, mingrp, maxgrp : integer;
   tiestart, tieend, NoSelected, NCases, group, nogrps : integer;
   s, t, TotRanks, chisqr, probchi, score : double;
   X, ColRanks : DblDyneVec;
   Ranks, means : DblDyneMat;
   RowLabels, ColLabels : StrDyneVec;
   index : IntDyneVec;
   GrpNo : IntdyneMat;
   cellstring: string;
   title : string;
   ties : boolean;
   ColNoSelected : IntDyneVec;
   lReport: TStrings;
begin
     if GrpVar.Text = '' then begin
       MessageDlg('Group variable not selected.', mtError, [mbOK], 0);
       exit;
     end;

     if TreatVars.Items.Count = 0 then
     begin
       MessageDlg('No treatment variable selected.', mtError, [mbOK], 0);
       exit;
     end;

     k := TreatVars.Items.Count;
     NoSelected := k + 1;
     SetLength(ColNoSelected,NoVariables);
     SetLength(ColLabels,NoVariables);

     // get group variable and treatment variables
     GrpCol := 0;
     for i := 1 to NoVariables do
     begin
          cellstring := OS3MainFrm.DataGrid.Cells[i,0];
          if cellstring = GrpVar.Text then
          begin
               ColNoSelected[0] := i;
               GrpCol := i;
          end;
          for j := 1 to k do
          begin
               if cellstring = TreatVars.Items.Strings[j-1] then
               begin
                    ColNoSelected[j] := i;
                    ColLabels[j-1] := cellstring;
               end;
          end;
     end;

     // get minimum and maximum group codes
     NCases := 0;
     mingrp := 10000;
     maxgrp := -10000;
     for i := 1 to NoCases do
     begin
          if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
          NCases := NCases + 1;
          group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpCol,i])));
          if group > maxgrp then maxgrp := group;
          if group < mingrp then mingrp := group;
     end;
     nogrps := maxgrp - mingrp + 1;

    // Initialize arrays
     SetLength(RowLabels,nogrps);
     SetLength(index,k);
     SetLength(GrpNo,nogrps,k);
     SetLength(Ranks,nogrps,k);
     SetLength(means,nogrps,k);
     SetLength(X,k);
     SetLength(ColRanks,k);
    for j := 0 to k-1 do
    begin
        for i := 0 to nogrps-1 do
        begin
            means[i,j] := 0.0;
            Ranks[i,j] := 0.0;
            GrpNo[i,j] := 0;
        end;
        ColRanks[j] := 0.0;
        X[j] := 0.0;
        index[j] := j+1;
    end;

    // Initialize labels
    for i := 1 to nogrps do
    begin
        cellstring := format('Group %d',[mingrp + i - 1]);
        RowLabels[i-1] := cellstring;
    end;

    // Setup for printing results
    lReport := TStringList.Create;
    try
      lReport.Add('FRIEDMAN TWO-WAY ANOVA ON RANKS');
      lReport.Add('See pages 166-173 in S. Siegel''s Nonparametric Statistics');
      lReport.Add('for the Behavioral Sciences, McGraw-Hill Book Co., New York, 1956');
      lReport.Add('');

      // Obtain mean score for each cell
      for i := 1 to NoCases do
      begin
        if ( not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpCol,i])));
        group := group - mingrp + 1;
        for j := 1 to k do // treatment values
        begin
             col := ColNoSelected[j];
             score := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
             means[group-1,j-1] := means[group-1,j-1]  + score;
             GrpNo[group-1,j-1]  := GrpNo[group-1,j-1] + 1;
        end;
      end;
      for i := 1 to nogrps do
        for j := 1 to k do
            means[i-1,j-1] := means[i-1,j-1] / GrpNo[i-1,j-1];

      // Print means and group size arrays
      title := 'Treatment means - values to be ranked.';
      MatPrint(means,nogrps,k,title,RowLabels,ColLabels,NCases, lReport);
      title := 'Number in each group''s treatment.';
      IntArrayPrint(GrpNo,nogrps,k,'GROUP',RowLabels,ColLabels,title, lReport);

      // Gather row data in X array and rank within rows
      for i := 0 to nogrps-1 do
      begin
        for j := 0 to k-1 do
        begin
            X[j] := means[i,j];
            index[j] := j+1;
        end;

        //rank scores in this row i
        for j := 1 to k - 1 do
        begin
            for L := j + 1 to k do
            begin
                if (X[j-1] > X[L-1]) then
                begin
                    t := X[j-1];
                    X[j-1] := X[L-1];
                    X[L-1] := t;
                    itemp := index[j-1];
                    index[j-1] := index[L-1];
                    index[L-1] := itemp;
                end;
            end;
        end;
        for j := 1 to k do
        begin
            Ranks[i,index[j-1]-1] := j;
        end;

        //Check for tied ranks and use average if desired here
        tiestart := 0;
        tieend := 0;
        ties := false;
        j := 1;
        while j < k do
        begin
            for L := j + 1 to k do
            begin
                if (means[i,j-1] = means[i,L-1]) then
                begin
                    ties := true;
                    tiestart := j;
                    tieend := L;
                end;
            end;
            if (ties = true) then
            begin
                s := 0.0;
                for L := tiestart to tieend do s := s + Ranks[i,L-1];
                for L := tiestart to tieend do
                     Ranks[i,L-1] := s / (tieend - tiestart + 1);
                j := tieend;
                ties := false;
            end;
            j := j + 1;
        end; // next j
      end; // next group i

      //Get sum of ranks in columns
      for i := 1 to nogrps do
        for j := 1 to k do
            ColRanks[j-1] := ColRanks[j-1] + Ranks[i-1,j-1];

      //Calculate Statistics
      TotRanks := 0;
      for j := 1 to k do TotRanks := TotRanks + (ColRanks[j-1] * ColRanks[j-1]);
      chisqr := TotRanks * 12.0 / (nogrps * k * (k + 1));
      chisqr := chisqr - (3 * nogrps * (k + 1));
      probchi := 1.0 - chisquaredprob(chisqr, k - 1);

      //Now, show results
      title := 'Score Rankings Within Groups';
      MatPrint(Ranks,nogrps,k,title,RowLabels,ColLabels,NCases, lReport);
      title := 'TOTAL RANKS';
      DynVectorPrint(ColRanks,k,title,ColLabels,NCases, lReport);
      lReport.Add('');
      lReport.Add('Chi-square with %d D.F.: %.3f with probability %.4f', [k-1, chisqr, probchi]);
      if ((k < 5) and (nogrps < 10)) then
      begin
        lReport.Add('Chi-square too approximate-use exact table (TABLE N)');
        lReport.Add('page 280-281 in Siegel');
      end;

      DisplayReport(lReport);

    finally
      lReport.Free;
      ColRanks := nil;
      X := nil;
      means := nil;
      Ranks := nil;
      GrpNo := nil;
      index := nil;
      RowLabels := nil;
      ColLabels := nil;
      ColNoSelected := nil;
    end;
end;

procedure TFriedmanFrm.GrpInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (GrpVar.Text = '') then
  begin
    GrpVar.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TFriedmanFrm.GrpOutClick(Sender: TObject);
begin
  if GrpVar.Text <> '' then
  begin
    VarList.Items.Add(GrpVar.Text);
    GrpVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TFriedmanFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TFriedmanFrm.UpdateBtnStates;
var
  lSelected: Boolean;
begin
  lSelected := AnySelected(VarList);
  GrpIn.Enabled := lSelected and (GrpVar.Text = '');
  TrtIn.Enabled := lSelected;
  GrpOut.Enabled := GrpVar.Text <> '';
  TrtOut.Enabled := AnySelected(TreatVars)
end;


initialization
  {$I friedmanunit.lrs}

end.

