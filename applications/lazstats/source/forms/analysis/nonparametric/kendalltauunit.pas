// Use file "taudata.laz" for testing.

unit KendallTauUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, Globals, DataProcs, MatrixLib;

type

  { TKendallTauFrm }

  TKendallTauFrm = class(TForm)
    Bevel1: TBevel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    RanksChk: TCheckBox;
    OptionsGroup: TGroupBox;
    XEdit: TEdit;
    YEdit: TEdit;
    ZEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    XIn: TBitBtn;
    XOut: TBitBtn;
    YIn: TBitBtn;
    YOut: TBitBtn;
    ZIn: TBitBtn;
    ZOut: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure XInClick(Sender: TObject);
    procedure XOutClick(Sender: TObject);
    procedure YInClick(Sender: TObject);
    procedure YOutClick(Sender: TObject);
    procedure ZInClick(Sender: TObject);
    procedure ZOutClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  KendallTauFrm: TKendallTauFrm;

implementation

uses
  Math;

{ TKendallTauFrm }

procedure TKendallTauFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  XEdit.Text := '';
  YEdit.Text := '';
  ZEdit.Text := '';
  RanksChk.Checked := false;
  VarList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TKendallTauFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TKendallTauFrm.XInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (XEdit.Text = '') then
  begin
    XEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TKendallTauFrm.XOutClick(Sender: TObject);
begin
  if XEdit.Text <> '' then
  begin
    VarList.Items.Add(XEdit.Text);
    XEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TKendallTauFrm.YInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (YEdit.Text = '') then
  begin
    YEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TKendallTauFrm.YOutClick(Sender: TObject);
begin
  if YEdit.Text <> '' then
  begin
    VarList.Items.Add(YEdit.Text);
    YEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TKendallTauFrm.ZInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (ZEdit.Text = '') then
  begin
    ZEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TKendallTauFrm.ZOutClick(Sender: TObject);
begin
  if ZEdit.Text <> '' then
  begin
    VarList.Items.Add(YEdit.Text);
    ZEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TKendallTauFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
  VarList.Constraints.MinHeight := OptionsGroup.Top + OptionsGroup.Height - VarList.Top;

  Constraints.MinWidth := OptionsGroup.Width * 2 + XIn.Width + 4 * VarList.BorderSpacing.Left;
  Constraints.MinHeight := Height;

  FAutoSized := True;
end;

procedure TKendallTauFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TKendallTauFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TKendallTauFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k, itemp, NoTies, NoSelected : integer;
   col1, col2, col3, NCases : integer;
   index : IntDyneMat;
   Probability, Temp, TieSum, Avg, SumT: double;
   z, denominator, stddev : double;
   Ranks, X : DblDyneMat;
   cellstring: string;
   ColNoSelected : IntdyneVec;
   ColLabels : StrDyneVec;
   RowLabels : StrDyneVec;
   TauXY, TauXZ, TauYZ : double;
   Tx, Ty, Tz : double;
   Term1, Term2 : double;
   PartialTau : double;
   title : string;
   lReport: TStrings;
begin
    if XEdit.Text = '' then
    begin
      MessageDlg('X variable not selected.', mtError, [mbOK], 0);
      exit;
    end;
    if YEdit.Text = '' then
    begin
      MessageDlg('Y variable not selected.', mtError, [mbOK], 0);
      exit;
    end;

    // Allocate memory
    SetLength(index,NoCases,3);
    SetLength(Ranks,NoCases,3);
    SetLength(X,NoCases,3);
    SetLength(ColLabels,3);
    SetLength(RowLabels,NoCases);
    SetLength(ColNoSelected,NoVariables);
    Tx := 0.0;
    Ty := 0.0;
    Tz := 0.0;

    // Get column numbers and labels of variables selected
    NoSelected := 0;
    for j := 1 to NoVariables do
    begin
         cellstring := OS3MainFrm.DataGrid.Cells[j,0];
         if cellstring = Xedit.Text then
         begin
              ColNoSelected[0] := j;
              ColLabels[0] := cellstring;
              NoSelected := NoSelected + 1;
         end;
         if cellstring = Yedit.Text then
         begin
              ColNoSelected[1] := j;
              ColLabels[1] := cellstring;
              NoSelected := NoSelected + 1;
         end;
         if cellstring = Zedit.Text then
         begin
              ColNoSelected[2] := j;
              ColLabels[2] := cellstring;
              NoSelected := NoSelected + 1;
         end;
    end;

    // Get scores
    NCases := 0;
    for i := 1 to NoCases do
    begin
        if ( not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        NCases := NCases + 1;
        col1 := ColNoSelected[0];
        col2 := ColNoSelected[1];
        if NoSelected = 3 then col3 := ColNoSelected[2];
        X[NCases-1,0] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col1,i]));
        Ranks[NCases-1,0] := X[NCases-1,0];
        X[NCases-1,1] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col2,i]));
        Ranks[NCases-1,1] := X[NCases-1,1];
        if NoSelected = 3 then
        begin
           X[NCases-1,2] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col3,i]));
           Ranks[NCases-1,2] := X[NCases-1,2];
        end;
        index[NCases-1,0] := NCases;
        index[NCases-1,1] := NCases;
        if NoSelected = 3 then index[NCases-1,2] := NCases;
    end;

    for i := 0 to NCases - 1 do RowLabels[i] := IntToStr(i+1);
    // Rank the first variable (X)
    for i := 0 to NCases - 2 do
    begin
         for j := i + 1 to NCases-1 do
         begin
            if (Ranks[i,0] > Ranks[j,0]) then // swap
            begin
                Temp := Ranks[i,0];
                Ranks[i,0] := Ranks[j,0];
                Ranks[j,0] := Temp;
                itemp := index[i,0];
                index[i,0] := index[j,0];
                index[j,0] := itemp;
            end;
        end;
    end;

    // Assign ranks
    for i := 0 to NCases-1 do Ranks[i,0] := i+1;

    // Check for ties in each
    i := 1;
    while (i < NCases) do
    begin
        j := i+1;
        TieSum := 0.0;
        NoTies := 0;
        while (j <= NCases) do
        begin
            if (X[j-1,0] > X[i-1,0]) then
              Break;
            if (X[j-1,0] = X[i-1,0]) then
            begin
                TieSum := TieSum + Ranks[j-1,0];
                NoTies := NoTies + 1;
            end;
            j := j + 1;
        end;

        if (NoTies > 0) then // at least one tie found
        begin
            TieSum := TieSum + Ranks[i-1,0];
            NoTies := NoTies + 1;
            Avg := TieSum / NoTies;
            for j := i to i + NoTies - 1 do Ranks[j-1,0] := Avg;
            i := i + (NoTies-1);
            Tx := Tx + NoTies *(NoTies-1);
        end;
        i := i + 1;
    end;
    Tx := Tx / 2.0;

    // Repeat sort for second variable Y
    for i := 0 to NCases - 2 do
    begin
        for j := i + 1 to NCases-1 do
        begin
            if (Ranks[i,1] > Ranks[j,1]) then // swap
            begin
                Temp := Ranks[i,1];
                Ranks[i,1] := Ranks[j,1];
                Ranks[j,1] := Temp;
                itemp := index[i,1];
                index[i,1] := index[j,1];
                index[j,1] := itemp;
            end;
        end;
    end;

    // Assign ranks
    for i := 0 to NCases-1 do Ranks[i,1] := i+1;

    // Check for ties in each
    i := 1;
    while (i < NCases) do
    begin
        j := i+1;
        TieSum := 0.0;
        NoTies := 0;
        while (j <= NoCases) do
        begin
            if (X[j-1,1] > X[i-1,1]) then
              Break;
            if (X[j-1,1] = X[i-1,1]) then
            begin
                TieSum := TieSum + Ranks[j-1,1];
                NoTies := NoTies + 1;
            end;
            j := j + 1;
        end;

        if (NoTies > 0) then // at least one tie found
        begin
            TieSum := TieSum + Ranks[i-1,1];
            NoTies := NoTies + 1;
            Avg := TieSum / NoTies;
            for j := i to i + NoTies - 1 do Ranks[j-1,1] := Avg;
            i := i + (NoTies-1);
            Ty := Ty + NoTies * (NoTies - 1);
        end;
        i := i + 1;
    end;
    Ty := Ty / 2.0;

    // Repeat for z variable
    if NoSelected > 2 then // z was entered
    begin
         for i := 0 to NCases - 2 do
         begin
              for j := i + 1 to NCases-1 do
              begin
                   if (Ranks[i,2] > Ranks[j,2]) then // swap
                   begin
                        Temp := Ranks[i,2];
                        Ranks[i,2] := Ranks[j,2];
                        Ranks[j,2] := Temp;
                        itemp := index[i,2];
                        index[i,2] := index[j,2];
                        index[j,2] := itemp;
                   end;
              end;
         end;

         // Assign ranks
         for i := 0 to NCases-1 do Ranks[i,2] := i+1;

         // Check for ties in each
         i := 1;
         while (i < NCases) do
         begin
              j := i+1;
              TieSum := 0.0;
              NoTies := 0;
              while (j <= NoCases) do
              begin
                   if (X[j-1,2] > X[i-1,2]) then
                     Break;
                   if (X[j-1,2] = X[i-1,2]) then
                   begin
                        TieSum := TieSum + Ranks[j-1,2];
                        NoTies := NoTies + 1;
                   end;
                   j := j + 1;
              end;

              if (NoTies > 0) then // at least one tie found
              begin
                   TieSum := TieSum + Ranks[i-1,2];
                   NoTies := NoTies + 1;
                   Avg := TieSum / NoTies;
                   for j := i to i + NoTies - 1 do Ranks[j-1,2] := Avg;
                   i := i + (NoTies-1);
                   Tz := Tz + NoTies * (NoTies - 1);
              end;
              i := i + 1;
         end;
         Tz := Tz / 2.0;
    end;

    // Rearrange ranks into original score order
    for k := 1 to 3 do
    begin
         for i := 1 to NCases - 1 do
         begin
              for j := i + 1 to NCases do
              begin
                   if (index[i-1,k-1] > index[j-1,k-1]) then // swap
                   begin
                        itemp := index[i-1,k-1];
                        index[i-1,k-1] := index[j-1,k-1];
                        index[j-1,k-1] := itemp;
                        Temp := Ranks[i-1,k-1];
                        Ranks[i-1,k-1] := Ranks[j-1,k-1];
                        Ranks[j-1,k-1] := Temp;
                   end;
              end;
         end;
    end;

    // compute Tau for X and Y
    // sort on X and obtain SumT for Y ranks
    SumT := 0.0;
    for i := 0 to NCases - 2 do
    begin
         for j := i + 1 to NCases-1 do
         begin
            if (Ranks[i,0] > Ranks[j,0]) then // swap
            begin
                Temp := Ranks[i,0];
                Ranks[i,0] := Ranks[j,0];
                Ranks[j,0] := Temp;
                Temp := Ranks[i,1];
                Ranks[i,1] := Ranks[j,1];
                Ranks[j,1] := Temp;
                if NoSelected = 3 then
                begin
                     Temp := Ranks[i,2];
                     Ranks[i,2] := Ranks[j,2];
                     Ranks[j,2] := Temp;
                end;
                itemp := index[i,0];
                index[i,0] := index[j,0];
                index[j,0] := itemp;
            end;
        end;
    end;
    for i := 0 to NCases - 2 do
         for j := i + 1 to NCases - 1 do
              if Ranks[i,1] < Ranks[j,1] then SumT := SumT + 1.0
              else if Ranks[i,1] > Ranks[j,1] then SumT := SumT - 1.0;
    Term1 := sqrt((NCases * (NCases-1)) / 2.0 - Tx);
    Term2 := sqrt((NCases * (Ncases-1)) / 2.0 - Ty);
    denominator := Term1 * Term2;
    TauXY := SumT / denominator;

    if NoSelected > 2 then // get tau values for partial
    begin
         // Get TauXZ
         SumT := 0.0;
         for i := 0 to NCases - 2 do
             for j := i + 1 to NCases - 1 do
                 if Ranks[i,2] < Ranks[j,2] then SumT := SumT + 1.0
                 else if Ranks[i,2] > Ranks[j,2] then SumT := SumT - 1.0;
         Term1 := sqrt((NCases * (NCases-1)) / 2.0 - Tx);
         Term2 := sqrt((NCases * (Ncases-1)) / 2.0 - Tz);
         denominator := Term1 * Term2;
         TauXZ := SumT / denominator;

         // get back to original order then sort on Y
         for i := 0 to NCases - 2 do
         begin
              for j := i + 1 to NCases - 1 do
              begin
                   if index[i,0] > index[j,0] then // swap
                   begin
                        Temp := Ranks[i,0];
                        Ranks[i,0] := Ranks[j,0];
                        Ranks[j,0] := temp;
                        Temp := Ranks[i,1];
                        Ranks[i,1] := Ranks[j,1];
                        Ranks[j,1] := Temp;
                        Temp := Ranks[i,2];
                        Ranks[i,2] := Ranks[j,2];
                        Ranks[j,2] := Temp;
                        itemp := index[i,0];
                        index[i,0] := index[j,0];
                        index[j,0] := itemp;
                   end;
              end;
         end;

         // Get TauYZ
         for i := 0 to NCases - 2 do // sort on Y variable
         begin
              for j := i + 1 to NCases-1 do
              begin
                   if (Ranks[i,1] > Ranks[j,1]) then // swap
                   begin
                        Temp := Ranks[i,1];
                        Ranks[i,1] := Ranks[j,1];
                        Ranks[j,1] := Temp;
                        Temp := Ranks[i,2];
                        Ranks[i,2] := Ranks[j,2];
                        Ranks[j,2] := Temp;
                        itemp := index[i,1];
                        index[i,1] := index[j,1];
                        index[j,1] := itemp;
                   end;
              end;
         end;

         SumT := 0.0;
         for i := 0 to NCases - 2 do
             for j := i + 1 to NCases - 1 do
                 if Ranks[i,2] < Ranks[j,2] then SumT := SumT + 1.0
                 else if Ranks[i,2] > Ranks[j,2] then SumT := SumT - 1.0;
         Term1 := sqrt((NCases * (NCases-1)) / 2.0 - Ty);
         Term2 := sqrt((NCases * (Ncases-1)) / 2.0 - Tz);
         denominator := Term1 * Term2;
         TauYZ := SumT / denominator;
         PartialTau := (TauXY - TauXZ * TauYZ) /
            (sqrt(1.0 - sqr(TauXZ)) * sqrt(1.0 - sqr(TauYZ)));
    end;

    lReport := TStringList.Create;
    try
      lReport.Add('Kendall Tau for File ' + OS3MainFrm.FileNameEdit.Text);
      lReport.Add('');
      lReport.Add('Kendall Tau for Variables ' + ColLabels[0] + ' and ' + ColLabels[1]);

      // do significance tests
      stddev := sqrt( (2.0 * ( 2.0 * NCases + 5)) / (9.0 * NCases * (NCases - 1.0)));
      z := abs(TauXY / stddev);
      probability := 1.0 - probz(z);
      lReport.Add('Tau = %8.4f  z = %8.3f probability > |z| = %4.3f', [TauXY, z, probability]);
      if NoSelected > 2 then
      begin
         lReport.Add('');
         z := abs(TauXZ / stddev);
         probability := 1.0 - probz(z);
         lReport.Add('Kendall Tau for variables ' + ColLabels[0] + ' and ' + ColLabels[2]);
         lReport.Add('Tau = %8.4f  z = %8.3f probability > |z| = %4.3f', [TauXZ, z, probability]);
         z := abs(TauYZ / stddev);
         probability := 1.0 - probz(z);
         lReport.Add('');
         lReport.Add('Kendall Tau for variables ' + ColLabels[1] + ' and ' + ColLabels[2]);
         lReport.Add('Tau = %8.4f  z = %8.3f probability > |z| = %4.3f', [TauYZ, z, probability]);
         lReport.Add('');
         lReport.Add('Partial Tau = %8.4f', [PartialTau]);
      end;
      lReport.Add('');
      lReport.Add('NOTE: Probabilities are for large N (>10)');

      // print data matrix if option is elected
      if RanksChk.Checked then
      begin
         lReport.Add('');
         lReport.Add('-----------------------------------------------------------------');
         lReport.Add('');
         title := 'Ranks';
         if NoSelected = 2 then
           MatPrint(Ranks, NCases, 2, title, RowLabels, ColLabels, NCases, lReport)
         else
           MatPrint(Ranks, NCases, 3, title, RowLabels, ColLabels, NCases, lReport);
      end;

      DisplayReport(lReport);
    finally
      lReport.Free;
      ColNoSelected := nil;
      RowLabels := nil;
      ColLabels := nil;
      X := nil;
      Ranks := nil;
      index := nil;
    end;
end;

procedure TKendallTauFrm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i:=0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  XIn.Enabled := lSelected and (XEdit.Text = '');
  YIn.Enabled := lSelected and (YEdit.Text = '');
  ZIn.Enabled := lSelected and (ZEdit.Text = '');
  XOut.Enabled := (XEdit.Text <> '');
  YOut.Enabled := (YEdit.Text <> '');
  ZOut.Enabled := (ZEdit.Text <> '');
end;

initialization
  {$I kendalltauunit.lrs}

end.

