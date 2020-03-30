// File for testing: manwhitU.laz

unit MannWhitUUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionslIB, Globals, DataProcs;

type

  { TMannWhitUFrm }

  TMannWhitUFrm = class(TForm)
    Bevel2: TBevel;
    Bevel3: TBevel;
    GrpIn: TBitBtn;
    GrpOut: TBitBtn;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    GrpEdit: TEdit;
    DepEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GrpInClick(Sender: TObject);
    procedure GrpOutClick(Sender: TObject);
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
  MannWhitUFrm: TMannWhitUFrm;

implementation

uses
  Math;

{ TMannWhitUFrm }

procedure TMannWhitUFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  GrpEdit.Text := '';
  DepEdit.Text := '';
  VarList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TMannWhitUFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := (Label3.Width + GrpIn.Width + 2 * VarList.BorderSpacing.Left + Bevel3.Width div 2) * 2;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TMannWhitUFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TMannWhitUFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TMannWhitUFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, ind_var, dep_var, min_grp, max_grp, group, total_n : integer;
   NoTies, NoTieGroups, n1, n2, nogroups, largestn : integer;
   NoSelected : integer;
   ColNoSelected : IntDyneVec;
   group_count : IntdyneVec;
   Ranks, X : DblDyneMat;
   RankSums : DblDyneVec;
   TieSum, score, t, SumT, Avg, z, prob, U, U2, SD, Temp : double;
   cellstring, outline : string;
   lReport: TStrings;

begin
     total_n := 0;
     NoTieGroups := 0;
     NoSelected := 2;
     SumT := 0.0;

    // Check for data
    if (NoVariables < 1) then
    begin
        MessageDlg('You must have grid data!', mtError, [mbOK], 0);
        exit;
    end;

    // allocate space
    SetLength(ColNoSelected,NoVariables);

    // Get column numbers of the independent and dependent variables
    ind_var := 0;
    dep_var := 0;
    for i := 1 to NoVariables do
    begin
        cellstring := GrpEdit.Text;
        if (cellstring = OS3MainFrm.DataGrid.Cells[i,0]) then ind_var := i;
        cellstring := DepEdit.Text;
        if (cellstring = OS3MainFrm.DataGrid.Cells[i,0]) then dep_var := i;
    end;
    ColNoSelected[0] := ind_var;
    ColNoSelected[1] := dep_var;
    if ind_var = 0 then
    begin
      MessageDlg('No group variable.', mtError, [mbOK], 0);
      exit;
    end;
    if dep_var = 0 then
    begin
      MessageDlg('No dependent variable.', mtError, [mbOk], 0);
      exit;
    end;

    //get minimum and maximum group codes
    min_grp := 10000;
    max_grp := -10000;
    for i := 1 to NoCases do
    begin
        if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ind_var,i])));
        if (group < min_grp) then min_grp := group;
        if (group > max_grp) then max_grp := group;
        total_n := total_n + 1;
    end;
    nogroups := max_grp - min_grp + 1;

    // Initialize arrays
    SetLength(RankSums,nogroups);
    SetLength(Ranks,NoCases,2);
    SetLength(X,NoCases,2);
    SetLength(group_count,nogroups);
    for i := 0 to nogroups-1 do
    begin
        group_count[i] := 0;
        RankSums[i] := 0.0;
    end;

    // Setup for printer output
    lReport := TStringList.Create;
    try
      lReport.Add('MANN-WHITNEY U TEST');
      lReport.Add('See pages 116-127 in S. Siegel: Nonparametric Statistics for the Behavioral Sciences');
      lReport.Add('');

      // Get data
      for i := 1 to NoCases do
      begin
        if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        score := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[dep_var,i]));
        group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ind_var,i])));
        group := group - min_grp + 1;
        if (group > 2) then
        begin
          MessageDlg('Group codes must be 1 and 2!', mtError, [mbOk], 0);
          exit;
        end;
        group_count[group-1] := group_count[group-1] + 1;
        X[i-1,0] := score;
        X[i-1,1] := group;
      end;

      //Sort all scores in ascending order
      for i := 1 to total_n - 1 do
      begin
        for j := i + 1 to total_n do
        begin
            if (X[i-1,0] > X[j-1,0]) then
            begin
                Temp := X[i-1,0];
                X[i-1,0] := X[j-1,0];
                X[j-1,0] := Temp;
                Temp := X[i-1,1];
                X[i-1,1] := X[j-1,1];
                X[j-1,1] := Temp;
            end;
        end;
      end;

      // Store ranks
      for i := 1 to total_n do
      begin
        Ranks[i-1,0] := i;
        Ranks[i-1,1] := X[i-1,1];
      end;

      //Check for ties in ranks - replace with average rank and calculate
      //T for each tie and sum of the T's
      i := 1;
      while i < total_n do
      begin
        j := i + 1;
        TieSum := 0;
        NoTies := 0;
        while (j < total_n) do
        begin
            if (X[j-1,0] > X[i-1,0]) then
              break;
            if (X[j-1,0] = X[i-1,0]) then // match
            begin
                TieSum := TieSum + round(Ranks[j-1,0]);
                NoTies := NoTies + 1;
            end;
            j := j + 1;
        end;

        if (NoTies > 0) then //At least one tie found
        begin
            TieSum := TieSum + Ranks[i-1,0];
            NoTies := NoTies + 1;
            Avg := TieSum / NoTies;
            for j := i to i + NoTies - 1 do Ranks[j-1,0] := Avg;
            t := Power(NoTies,3) - NoTies;
            SumT := SumT + t;
            NoTieGroups := NoTieGroups + 1;
            i := i + (NoTies - 1);
        end;
        i := i + 1;
      end; // next i

      // Calculate sum of ranks in each group
      for i := 1 to total_n do
      begin
        group := round(Ranks[i-1,1]);
        RankSums[group-1] := RankSums[group-1] + Ranks[i-1,0];
      end;

      //Calculate U for larger and smaller groups
      n1 := group_count[0];
      n2 := group_count[1];
      if (n1 > n2) then
        U := n1 * n2 + n1 * (n1 + 1) / 2.0 - RankSums[0]
      else
         U := n1 * n2 + n2 * (n2 + 1) / 2.0 - RankSums[1];
      U2 := n1 * n2 - U;
      SD := n1 * n2 * (n1 + n2 + 1) / 12.0;
      SD := sqrt(SD);
      if (U2 > U) then
        z := (U2 - n1 * n2 / 2) / SD
      else
        z := (U - n1 * n2 / 2) / SD;
      prob := 1.0 - probz(z);

      //Report results
      lReport.Add('     Score       Rank      Group');
      lReport.Add('');
      for i := 1 to total_n do
        lReport.Add('%10.2f %10.2f %10.0f', [X[i-1,0], Ranks[i-1,0], Ranks[i-1,1]]);
      lReport.Add('');
      lReport.Add('Sum of Ranks in each Group');
      lReport.Add('Group   Sum    No. in Group');
      for i := 1 to nogroups do
        lReport.Add('%3d  %10.2f %5d',  [i+min_grp-1, RankSums[i-1], group_count[i-1]]);
      lReport.Add('');
      lReport.Add('No. of tied rank groups:        %10d', [NoTieGroups]);
      if (n1 > n2) then
        largestn := n1
      else
        largestn := n2;
      if (largestn < 20) then
          outline := format('Statistic U:    %26.4f',[U])
      else
      begin
          if (U > U2) then
            outline := format('Statistic U:    %26.4f',[U])
          else
            outline := format('Statistic U:    %26.4f',[U2]);
      end;
      lReport.Add(outline);
      lReport.Add('z Statistic (corrected for ties): %8.4f', [z]);
      lReport.Add('     Probability > z:             %8.4f', [prob]);
      if (n2 < 20) then
      begin
        lReport.Add('z test is approximate.  Use tables of exact probabilities in Siegel.');
        lReport.Add('(Table J or K, pages 271-277)');
      end;
      DisplayReport(lReport);

    finally
      lReport.Free;
      group_count := nil;
      X := nil;
      Ranks := nil;
      RankSums := nil;
      ColNoSelected := nil;
    end;
end;

procedure TMannWhitUFrm.DepInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepEdit.Text = '') then
  begin
    DepEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TMannWhitUFrm.DepOutClick(Sender: TObject);
begin
  if DepEdit.Text <> '' then
  begin
    VarList.Items.Add(DepEdit.Text);
    DepEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TMannWhitUFrm.GrpInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (GrpEdit.Text = '') then
  begin
    GrpEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TMannWhitUFrm.GrpOutClick(Sender: TObject);
begin
  if GrpEdit.Text <> '' then
  begin
    VarList.Items.Add(GrpEdit.Text);
    GrpEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TMannWhitUFrm.UpdateBtnStates;
begin
  GrpIn.Enabled := (VarList.ItemIndex > -1) and (GrpEdit.Text = '');
  DepIn.Enabled := (VarList.ItemIndex > -1) and (DepEdit.Text = '');
  GrpOut.Enabled := GrpEdit.Text <> '';
  DepOut.Enabled := DepEdit.Text <> '';
end;

procedure TMannWhitUFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I mannwhituunit.lrs}

end.

