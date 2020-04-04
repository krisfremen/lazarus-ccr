// File for testing: "kwanova.laz"

unit KWANOVAUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, Globals, DataProcs;

type

  { TKWAnovaFrm }

  TKWAnovaFrm = class(TForm)
    AlphaEdit: TEdit;
    Bevel1: TBevel;
    Label4: TLabel;
    Label5: TLabel;
    MWUChk: TCheckBox;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    GrpEdit: TEdit;
    DepEdit: TEdit;
    GrpIn: TBitBtn;
    GrpOut: TBitBtn;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
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
  KWAnovaFrm: TKWAnovaFrm;

implementation

uses
  Math;

{ TKWAnovaFrm }

procedure TKWAnovaFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  GrpEdit.Text := '';
  DepEdit.Text := '';
  AlphaEdit.Text := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
  MWUChk.Checked := false;
  VarList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TKWAnovaFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := MWUChk.Top + MWUChk.Height - VarList.Top;

  Constraints.MinWidth := Label4.Width * 2 + GrpIn.Width + 4* VarList.BorderSpacing.Left;
  Constraints.MinHeight := Height;

  FAutoSized := True;
end;

procedure TKWAnovaFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3Mainfrm <> nil);
end;

procedure TKWAnovaFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TKWAnovaFrm.ComputeBtnClick(Sender: TObject);
var
    i, j, k, m, ind_var, dep_var, min_grp, max_grp, group, total_n : integer;
    NoTies, NoTieGroups, nogroups, NoSelected, npairs, n1, n2 : integer;
    largestn : integer;
    ColNoSelected : IntdyneVec;
    group_count : IntDyneVec;
    score, t, SumT, Avg, Probchi, H, CorrectedH, value : double;
    Correction, Temp, TieSum, alpha, U, U2, SD, z, prob : double;
    Ranks, X : DblDyneMat;
    RankSums : DblDyneVec;
    cellstring, outline: string;
    lReport: TStrings;
begin
    // Check for data
    if (NoVariables < 1) then
    begin
        MessageDlg('You must have grid data!', mtError, [mbOK], 0);
        exit;
    end;

    if GrpEdit.Text = '' then
    begin
        MessageDlg('Group variable not specified.', mtError, [mbOK], 0);
        exit;
    end;

    if DepEdit.Text = '' then
    begin
        MessageDlg('Dependent variable not selected.', mtError, [mbOK], 0);
        exit;
    end;

    if AlphaEdit.Text = '' then
    begin
        AlphaEdit.SetFocus;
        MessageDlg('Alpha level not specified.', mtError, [mbOK], 0);
        exit;
    end;
    if not TryStrToFloat(AlphaEdit.Text, alpha) or (alpha <= 0) or (alpha >= 1) then
    begin
        AlphaEdit.Setfocus;
        MessageDlg('Alpha level must be a valid number between 0 and 1.', mtError, [mbOK], 0);
    end;


    // allocate space
    SetLength(ColNoSelected,NoVariables);
    SetLength(Ranks,NoCases,2);
    SetLength(X,NoCases,2);

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

    //get minimum and maximum group codes
    total_n := 0;
    NoSelected := 2;
    min_grp := 10000; //atoi(MainForm.Grid.Cells[ind_var,1].c_str);
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
    NoTieGroups := 0;
    SumT := 0.0;
    H := 0.0;

    // Initialize arrays
    SetLength(RankSums,nogroups);
    SetLength(group_count,nogroups);
    for i := 0 to nogroups-1 do
    begin
        group_count[i] := 0;
        RankSums[i] := 0.0;
    end;

    // Setup for printer output
    lReport := TStringList.Create;
    try
      lReport.Add('KRUSKAL-WALLIS ONE-WAY ANALYSIS OF VARIANCE');
      lReport.Add('See pages 184-194 in S. Siegel: Nonparametric Statistics for the Behavioral Sciences');
      lReport.Add('');

      // Get data
      for i := 1 to NoCases do
      begin
        if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        score := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[dep_var,i]));
        group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ind_var,i])));
        group := group - min_grp + 1;
        if (group > nogroups) then
        begin
            MessageDlg('Group codes must be sequential like 1 and 2!', mtError, [mbOk], 0);
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
      for i := 0 to total_n-1 do
      begin
        Ranks[i,0] := i+1;
        Ranks[i,1] := X[i,1];
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

      // Calculate statistics
      for j := 0 to nogroups-1 do H := H + (RankSums[j] * RankSums[j] / (group_count[j]));
      H := H * (12.0 / ( total_n * (total_n + 1)) );
      H := H - (3.0 * (total_n + 1));
      Correction := 1.0 - ( SumT / (Power(total_n,3) - total_n) );
      CorrectedH := H / Correction;
      k := max_grp - min_grp;
      Probchi := 1.0 - chisquaredprob(H, k);

      // Report results
      lReport.Add('     Score     Rank      Group');
      lReport.Add('');
      for i := 1 to total_n do
        lReport.Add('%10.2f %10.2f %10.0f', [X[i-1,0], Ranks[i-1,0], Ranks[i-1,1]]);
      lReport.Add('');
      lReport.Add('Sum of Ranks in each Group');
      lReport.Add('Group   Sum    No. in Group');
      for i := 1 to nogroups do
        lReport.Add('%3d  %10.2f %5d', [i+min_grp-1, RankSums[i-1], group_count[i-1]]);
      lReport.Add('');
      lReport.Add('No. of tied rank groups = %3d', [NoTieGroups]);
      lReport.Add('Statistic H uncorrected for ties: %8.4f', [H]);
      lReport.Add('Correction for Ties:              %8.4f', [Correction]);
      lReport.Add('Statistic H corrected for ties:   %8.4f', [CorrectedH]);
      lReport.Add('Corrected H is approx. chi-square with %d D.F. and probability %.4f', [k, Probchi]);

      if MWUChk.Checked then
      begin
        lReport.Add('');
        lReport.Add('------------------------------------------------------------------------');
        lReport.Add('');
        // do Mann-Whitney U tests on group pairs
        alpha := StrToFloat(AlphaEdit.Text);
        npairs := nogroups * (nogroups - 1) div 2;
        alpha := alpha / npairs;
        lReport.Add('New alpha for %d paired comparisons: %.3f', [npairs, alpha]);
        for i := 1 to nogroups - 1 do
        begin
          for j := i + 1 to nogroups do
          begin
            // Setup for printer output
            lReport.Add('');
            lReport.Add('');
            lReport.Add('MANN-WHITNEY U TEST');
            lReport.Add('See pages 116-127 in S. Siegel: Nonparametric Statistics for the Behavioral Sciences');
            lReport.Add('');
            lReport.Add('Comparison of group %d with group %d', [i, j]);

            group_count[0] := 0;
            group_count[1] := 0;
            RankSums[0] := 0;
            RankSums[1] := 0;
            total_n := 0;
            for k := 1 to NoCases do
            begin
                if (not GoodRecord(k,NoSelected,ColNoSelected)) then continue;
                score := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[dep_var,k]));
                value := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ind_var,k]));
                if round(value) = i then
                begin
                     X[total_n,0] := score;
                     X[total_n,1] := value;
                     group_count[0] := group_count[0] + 1;
                     total_n := total_n + 1;
                end;
                if round(value) = j then
                begin
                     X[total_n,0] := score;
                     X[total_n,1] := value;
                     group_count[1] := group_count[1] + 1;
                     total_n := total_n + 1;
                end;
            end; // next case k

            //Sort all scores in ascending order
            for k := 1 to total_n - 1 do
            begin
                for m := k + 1 to total_n do
                begin
                    if (X[k-1,0] > X[m-1,0]) then
                    begin
                        Temp := X[k-1,0];
                        X[k-1,0] := X[m-1,0];
                        X[m-1,0] := Temp;
                        Temp := X[k-1,1];
                        X[k-1,1] := X[m-1,1];
                        X[m-1,1] := Temp;
                    end;
                end;
            end;

            // get ranks for these two groups
            for k := 1 to total_n do
            begin
                Ranks[k-1,0] := k;
                Ranks[k-1,1] := X[k-1,1];
            end;

            //Check for ties in ranks - replace with average rank and calculate
            //T for each tie and sum of the T's
            NoTieGroups := 0;
            k := 1;
            while k < total_n do
            begin
                m := k + 1;
                TieSum := 0;
                NoTies := 0;
                while (m < total_n) do
                begin
                    if (X[m-1,0] > X[k-1,0]) then
                      Break;
                    if (X[m-1,0] = X[k-1,0]) then // match
                    begin
                        TieSum := TieSum + round(Ranks[m-1,0]);
                        NoTies := NoTies + 1;
                    end;
                    m := m + 1;
                end;
                if (NoTies > 0) then //At least one tie found
                begin
                    TieSum := TieSum + Ranks[k-1,0];
                    NoTies := NoTies + 1;
                    Avg := TieSum / NoTies;
                    for m := k to k + NoTies - 1 do Ranks[m-1,0] := Avg;
                    t := Power(NoTies,3) - NoTies;
                    SumT := SumT + t;
                    NoTieGroups := NoTieGroups + 1;
                    k := k + (NoTies - 1);
                end;
                k := k + 1;
            end; // next k

            // Calculate sum of ranks in each group
            for k := 1 to total_n do
            begin
                group := round(Ranks[k-1,1]);
                RankSums[group-1] := RankSums[group-1] + Ranks[k-1,0];
            end;

            //Calculate U for larger and smaller groups
            n1 := group_count[0];
            n2 := group_count[1];
            if (n1 > n2) then
            begin
                group := i-1;
                U := (n1 * n2) + ((n1 * (n1 + 1)) / 2.0) - RankSums[group];
            end
            else
            begin
                group := j - 1;
                U := (n1 * n2) + ((n2 * (n2 + 1)) / 2.0) - RankSums[group];
            end;
            U2 := (n1 * n2) - U;
            SD := (n1 * n2 * (n1 + n2 + 1)) / 12.0;
            SD := sqrt(SD);
            if (U2 > U) then z := (U2 - (n1 * n2 / 2)) / SD
            else z := (U - (n1 * n2 / 2)) / SD;
            prob := 1.0 - probz(z);

            //Report results
            lReport.Add('     Score     Rank      Group');
            lReport.Add('');
            for k := 1 to total_n do
                lReport.Add('%10.2f %10.2f %10.0f', [X[k-1,0], Ranks[k-1,0], Ranks[k-1,1]]);
            lReport.Add('');
            lReport.Add('Sum of Ranks in each Group');
            lReport.Add('Group   Sum    No. in Group');
            group := i - 1;
            lReport.Add('%3d  %10.3f %5d', [i, RankSums[group], group_count[0]]);
            group := j - 1;
            lReport.Add('%3d  %10.3f %5d', [j, RankSums[group], group_count[1]]);
            lReport.Add('');
            lReport.Add(            'No. of tied rank groups:          %8d', [NoTieGroups]);
            if (n1 > n2) then largestn := n1 else largestn := n2;
            if (largestn < 20) then
                outline := Format(  'Statistic U:                      %8.4f',[U])
            else
            begin
                if (U > U2) then
                  outline := Format('Statistic U:                      %8.4f',[U])
                else
                  outline := Format('Statistic U:                      %8.4f',[U2]);
            end;
            lReport.Add(outline);
            lReport.Add(            'z Statistic (corrected for ties): %8.4f', [z]);
            lReport.Add(            'Prob. > z:                        %8.4f', [prob]);
            if (n2 < 20) then
            begin
                lReport.Add('z test is approximate.  Use tables of exact probabilities in Siegel.');
                lReport.Add('(Table J or K, pages 271-277)');
            end;
          end; // next group j
        end; // next group i
      end;

      if lReport.Count > 0 then
        DisplayReport(lReport);

    finally
      lReport.Free;
      group_count := nil;
      RankSums := nil;
      X := nil;
      Ranks := nil;
      ColNoSelected := nil;
    end;
end;

procedure TKWAnovaFrm.DepInClick(Sender: TObject);
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

procedure TKWAnovaFrm.DepOutClick(Sender: TObject);
begin
  if DepEdit.Text <> '' then
  begin
    VarList.Items.Add(DepEdit.Text);
    DepEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TKWAnovaFrm.GrpInClick(Sender: TObject);
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

procedure TKWAnovaFrm.GrpOutClick(Sender: TObject);
begin
  if GrpEdit.Text <> '' then
  begin
    VarList.Items.Add(GrpEdit.Text);
    GrpEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TKWAnovaFrm.UpdateBtnStates;
begin
  GrpIn.Enabled := (VarList.Items.Count > 0) and (GrpEdit.Text = '');
  DepIn.Enabled := (VarList.Items.Count > 0) and (DepEdit.Text = '');
  GrpOut.Enabled := (GrpEdit.Text <> '');
  DepOut.Enabled := (DepEdit.Text <> '');
end;

procedure TKWAnovaFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I kwanovaunit.lrs}

end.

