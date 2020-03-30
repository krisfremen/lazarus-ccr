unit SpearmanUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, Globals, DataProcs;

type

  { TSpearmanFrm }

  TSpearmanFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    XIn: TBitBtn;
    XOut: TBitBtn;
    YIn: TBitBtn;
    YOut: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    XEdit: TEdit;
    YEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
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
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  SpearmanFrm: TSpearmanFrm;

implementation

uses
  Math;

{ TSpearmanFrm }

procedure TSpearmanFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  XEdit.Text := '';
  YEdit.Text := '';
  VarList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TSpearmanFrm.XInClick(Sender: TObject);
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

procedure TSpearmanFrm.XOutClick(Sender: TObject);
begin
  if XEdit.Text <> '' then
  begin
    VarList.Items.Add(XEdit.Text);
    XEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TSpearmanFrm.YInClick(Sender: TObject);
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

procedure TSpearmanFrm.YOutClick(Sender: TObject);
begin
  if YEdit.Text <> '' then
  begin
    VarList.Items.Add(YEdit.Text);
    YEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TSpearmanFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TSpearmanFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, itemp, NoTies, NoSelected : integer;
   col1, col2, NCases : integer;
   index : IntDyneMat;
   Probability, sumsqrx, sumsqry, Temp, TieSum, Avg, t, SumT, r : double;
   z, sumdsqr, df : double;
   Ranks, X : DblDyneMat;
   d : DblDyneVec;
   cellstring: string;
   ColNoSelected : IntDyneVec;
   ColLabels : StrDyneVec;
   VarX, VarY, SDX, SDY, MeanX, MeanY, Rxy : double;
   lReport: TStrings;
begin
  if (XEdit.Text = '') then begin
    MessageDlg('X variable is not selected.', mtError, [mbOK], 0);
    exit;
  end;
  if (YEdit.Text = '') then begin
    MessageDlg('Y variable is not selected.', mtError, [mbOK], 0);
    exit;
  end;

  // Allocate memory
  SetLength(ColNoSelected, NoVariables);
  SetLength(index, NoCases, 2);
  SetLength(Ranks, NoCases, 2);
  SetLength(X, NoCases, 2);
  SetLength(d, NoCases);
  SetLength(ColLabels, NoVariables);

  // Get column numbers and labels of variables selected
  for j := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[j,0];
    if cellstring = Xedit.Text then
    begin
      ColNoSelected[0] := j;
      ColLabels[0] := cellstring;
    end;
    if cellstring = Yedit.Text then
    begin
      ColNoSelected[1] := j;
      ColLabels[1] := cellstring;
    end;
  end;
  NoSelected := 2;

  lReport := TStringList.Create;
  try
    lReport.Add('SPEARMAN RANK CORRELATION BETWEEN %s AND %s', [ColLabels[0], ColLabels[1]]);;
    lReport.Add('');

    // Get scores
    NCases := 0;
    MeanX := 0.0;
    MeanY := 0.0;
    VarX := 0.0;
    VarY := 0.0;
    Rxy := 0.0;
    NoTies := 0;

    for i := 1 to NoCases do
    begin
        if ( not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        NCases := NCases + 1;
        col1 := ColNoSelected[0];
        col2 := ColNoSelected[1];
        X[NCases-1,0] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col1,i]));
        Ranks[NCases-1,0] := X[NCases-1,0];
        X[NCases-1,1] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col2,i]));
        Ranks[NCases-1,1] := X[NCases-1,1];
        index[NCases-1,0] := NCases;
        index[NCases-1,1] := NCases;
        VarX := VarX + X[NCases-1,0] * X[NCases-1,0];
        VarY := VarY + X[NCases-1,1] * X[NCases-1,1];
        MeanX := MeanX + X[NCases-1,0];
        MeanY := MeanY + X[NCases-1,1];
        Rxy := Rxy + X[NCases-1,0] * X[NCases-1,1];
    end;

    // Rank the first variable
    for i := 1 to NCases - 1 do
    begin
         for j := i + 1 to NCases do
         begin
            if (Ranks[i-1,0] > Ranks[j-1,0]) then // swap
            begin
                Temp := Ranks[i-1,0];
                Ranks[i-1,0] := Ranks[j-1,0];
                Ranks[j-1,0] := Temp;
                itemp := index[i-1,0];
                index[i-1,0] := index[j-1,0];
                index[j-1,0] := itemp;
                Temp := X[i-1,0];
                X[i-1,0] := X[j-1,0];
                X[j-1,0] := Temp;
            end;
        end;
    end;

    // Assign ranks
    for i := 1 to NCases do Ranks[i-1,0] := i;

    // Check for ties in each
    //    NoTieGroups := 0;
    SumT := 0.0;
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
            t := ( Power(NoTies,3) - NoTies) / 12.0;
            SumT := SumT + t;
    //            NoTieGroups := NoTieGroups + 1;
            i := i + (NoTies-1);
        end;
        i := i + 1;
    end;
    sumsqrx := ( (Power(NCases,3) - NCases) / 12.0) - SumT;
    lReport.Add('Tied ranks correction for X = %8.2f for %d ties', [sumsqrx, NoTies]);

    // Repeat sort for second variable
    for i := 1 to NCases - 1 do
    begin
        for j := i + 1 to NCases do
        begin
            if (Ranks[i-1,1] > Ranks[j-1,1]) then // swap
            begin
                Temp := Ranks[i-1,1];
                Ranks[i-1,1] := Ranks[j-1,1];
                Ranks[j-1,1] := Temp;
                itemp := index[i-1,1];
                index[i-1,1] := index[j-1,1];
                index[j-1,1] := itemp;
                Temp := X[i-1,1];
                X[i-1,1] := X[j-1,1];
                X[j-1,1] := Temp;
            end;
        end;
    end;

    // Assign ranks
    for i := 1 to NCases do Ranks[i-1,1] := i;

    // Check for ties in each
    SumT := 0.0;
    //    NoTieGroups := 0;
    i := 1;
    while (i < NCases) do
    begin
        j := i+1;
        TieSum := 0.0;
        NoTies := 0;
        while (j <= NCases) do
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
            t := ( Power(NoTies,3) - NoTies) / 12.0;
            SumT := SumT + t;
    //            NoTieGroups := NoTieGroups + 1;
            i := i + (NoTies-1);
        end;
        i := i + 1;
    end;
    sumsqry := ( (Power(NCases,3) - NCases) / 12.0) - SumT;
    lReport.Add('Tied ranks correction for Y = %8.2f for %d ties', [sumsqry, NoTies]);

    // arrange scores in order of first variable
    for i := 1 to Ncases - 1 do
    begin
         for j := i + 1 to Ncases do
         begin
              if (index[i-1,0] > index[j-1,0]) then // swap all
              begin
                   itemp := index[i-1,0];
                   index[i-1,0] := index[j-1,0];
                   index[j-1,0] := itemp;
                   Temp := X[i-1,0];
                   X[i-1,0] := X[j-1,0];
                   X[j-1,0] := Temp;
                   Temp := Ranks[i-1,0];
                   Ranks[i-1,0] := Ranks[j-1,0];
                   Ranks[j-1,0] := Temp;
              end; // end swap
         end; // next j
    end; // next i

    // arrange scores of the second variable
    for i := 1 to Ncases - 1 do
    begin
         for j := i + 1 to Ncases do
         begin
              if (index[i-1,1] > index[j-1,1]) then // swap all
              begin
                   itemp := index[i-1,1];
                   index[i-1,1] := index[j-1,1];
                   index[j-1,1] := itemp;
                   Temp := X[i-1,1];
                   X[i-1,1] := X[j-1,1];
                   X[j-1,1] := Temp;
                   Temp := Ranks[i-1,1];
                   Ranks[i-1,1] := Ranks[j-1,1];
                   Ranks[j-1,1] := Temp;
              end; // end swap
         end; // next j
    end; // next i

    // Calculate difference scores
    sumdsqr := 0.0;
    for i := 1 to NCases do
    begin
        d[i-1] := Ranks[i-1,0] - Ranks[i-1,1];
        sumdsqr := sumdsqr + (d[i-1] * d[i-1]);
    end;

    // Calculate corrected spearman rank correlation
    r := (sumsqrx + sumsqry - sumdsqr) / (2.0 * sqrt(sumsqrx * sumsqry));

    // Calculate Pearson correlation
    VarX := VarX - (MeanX * MeanX) / NCases;
    VarX := VarX / (NCases-1);
    VarY := VarY - (MeanY * MeanY) / NCases;
    VarY := VarY / (NCases - 1);
    SDX := sqrt(VarX);
    SDY := sqrt(VarY);
    Rxy := Rxy - (MeanX * MeanY) / NCases;
    Rxy := Rxy / (NCases - 1);
    Rxy := Rxy / (SDX * SDY);
    MeanX := MeanX / NCases;
    MeanY := MeanY / NCases;

    // Output the results
    lReport.Add('');
    lReport.Add('Observed scores, their ranks and differences between ranks');
    lReport.Add('CASE %10s    Ranks %10s     Ranks Rank Difference', [ColLabels[0], ColLabels[1]]);
    for i := 1 to NCases do
      lReport.Add('%4d %10.2f%10.2f%10.2f%10.2f%10.2f',
        [i, X[i-1,0], Ranks[i-1,0], X[i-1,1], Ranks[i-1,1], d[i-1]]);
    lReport.Add('Spearman Rank Correlation: %6.3f',[r]);
    lReport.Add('');

    if (NCases > 10) then// Use normal distribution approximation
    begin
        z := r * sqrt((NCases - 2) / (1.0 - (r * r)));
        lReport.Add('t-test value for hypothesis r = 0 is %.3f', [z]);
        df := NCases - 2;
        Probability := probt(z,df);
        lReport.Add('Probability > t: %6.4f', [Probability]);
    end
    else
        lReport.Add('Use table P, page 284 in Siegel for testing significance of r.');

    lReport.Add('');
    lReport.Add('Pearson r for original scores: %.3f', [Rxy]);
    lReport.Add('For the Original Scores:');
    lReport.Add('Mean X  Variance X  Std.Dev. X  Mean Y  Variance Y  Std.Dev. Y');
    lReport.Add('%8.2f  %8.2f  %8.2f  %8.2f  %8.2f  %8.2f', [MeanX, VarX, SDX, MeanY, VarY, SDY]);

    DisplayReport(lReport);

  finally
    lReport.Free;

    ColLabels := nil;
    d := nil;
    X := nil;
    Ranks := nil;
    index := nil;
    ColNoSelected := nil;
  end;
end;

procedure TSpearmanFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := 4*w;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TSpearmanFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TSpearmanFrm.UpdateBtnStates;
begin
  XIn.Enabled := (VarList.Count > 0) and (XEdit.Text = '');
  YIn.Enabled := (Varlist.Count > 0) and (YEdit.Text = '');
  XOut.Enabled := XEdit.Text <> '';
  YOut.Enabled := YEdit.Text <> '';
end;

procedure TSpearmanFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I spearmanunit.lrs}

end.

