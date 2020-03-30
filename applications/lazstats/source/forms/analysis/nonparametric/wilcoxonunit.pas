unit WilcoxonUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, Globals, DataProcs, ContextHelpUnit;

type

  { TWilcoxonFrm }

  TWilcoxonFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    Var1Edit: TEdit;
    Var2Edit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Var1In: TBitBtn;
    Var1Out: TBitBtn;
    Var2In: TBitBtn;
    Var2Out: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure Var1InClick(Sender: TObject);
    procedure Var1OutClick(Sender: TObject);
    procedure Var2InClick(Sender: TObject);
    procedure Var2OutClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  WilcoxonFrm: TWilcoxonFrm;

implementation

uses
  Math;

{ TWilcoxonFrm }

procedure TWilcoxonFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  Var1Edit.Text := '';
  Var2Edit.Text := '';
  VarList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TWilcoxonFrm.Var1InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Var1Edit.Text = '') then
  begin
    Var1Edit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TWilcoxonFrm.Var1OutClick(Sender: TObject);
begin
  if Var1Edit.Text <> '' then
  begin
    VarList.Items.Add(Var1Edit.Text);
    Var1Edit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TWilcoxonFrm.Var2InClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (Var2Edit.Text = '') then
  begin
    Var2Edit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TWilcoxonFrm.Var2OutClick(Sender: TObject);
begin
  if Var2Edit.Text <> '' then
  begin
    VarList.Items.Add(Var2Edit.Text);
    Var2Edit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TWilcoxonFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TWilcoxonFrm.FormActivate(Sender: TObject);
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

procedure TWilcoxonFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TWilcoxonFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TWilcoxonFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TWilcoxonFrm.ComputeBtnClick(Sender: TObject);
var
    zprob, numerator, denominator, z, negsum : double;
    possum, t, sum, Avg : double;
    A, b, d, r : DblDyneVec;
    M,  N, i, j, itemp, col1, col2, NoSelected: integer;
    index : IntdyneVec;
    ColNoSelected : IntDyneVec;
    labelone, labeltwo, cellstring: string;
    lReport: TStrings;
    negcnt: Integer = 0;
    poscnt: Integer = 0;
begin
    if Var1Edit.Text = '' then
    begin
      MessageDlg('Variable 1 not selected.', mtError, [mbOK], 0);
      exit;
    end;

    if Var2Edit.Text = '' then
    begin
      MessageDlg('Variable 2 not selected.', mtError, [mbOK], 0);
      exit;
    end;

    negsum := 0.0;
    possum := 0.0;
    NoSelected := 2;

    // Allocate memory
    SetLength(ColNoSelected,NoVariables);
    SetLength(A,NoCases);
    SetLength(b,NoCases);
    SetLength(d,NoCases);
    SetLength(index,NoCases);
    SetLength(r,NoCases);

    // Get column numbers and labels of variables selected
    for i := 1 to NoVariables do
    begin
        cellstring := OS3MainFrm.DataGrid.Cells[i,0];
        if cellstring = Var1Edit.Text then
        begin
             ColNoSelected[0] := i;
             labelone := cellstring;
        end;
        if cellstring = Var2Edit.Text then
        begin
             ColNoSelected[1] := i;
             labeltwo := cellstring;
        end;
    end;

    // Get scores and differences
    N := 0;
    for i := 1 to NoCases do
    begin
        if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        N := N + 1;
        index[i-1] := N;
        col1 := ColNoSelected[0];
        col2 := ColNoSelected[1];
        A[N-1] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col1,i]));
        b[N-1] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col2,i]));
        d[N-1] := A[N-1] - b[N-1];
    end;

    // Rank on absolute score differences
    for i := 1 to N - 1 do
    begin
        for j := i + 1 to N do
        begin
            if (abs(d[i-1]) > abs(d[j-1])) then
            begin
                t := d[i-1];
                d[i-1] := d[j-1];
                d[j-1] := t;
                t := A[i-1];
                A[i-1] := A[j-1];
                A[j-1] := t;
                t := b[i-1];
                b[i-1] := b[j-1];
                b[j-1] := t;
                itemp := index[i-1];
                index[i-1] := index[j-1];
                index[j-1] := itemp;
            end;
        end;
    end;

    // Eliminate cases with 0 score differences
    i := 1;
    while (i <= N) do
    begin
        if (d[i-1] = 0.0) then // found a 0 score difference - move all up one
        begin
            if i < N then
            begin
                 for j := i + 1 to N do
                 begin
                      d[j] := d[j-1];
                      A[j] := A[j-1];
                      b[j] := b[j-1];
                      index[j] := index[j-1];
                 end;
                 N := N - 1;
                 i := 1;
            end
            else begin
                 N := N - 1;
                 i := 1;
            end;
        end
        else i := i + 1;
    end;

    // Assign ranks
    for i := 1 to N do r[i-1] := i;

    // Find matching differences and assign common rank
    i := 1;
    while (i < N) do
    begin
        M := 0;
        sum := 0;
        for j := i + 1 to N do
        begin
            if ( abs(d[j-1]) = abs(d[i-1]) ) then
            begin
                M := M + 1;
                sum := sum + r[j-1];
            end;
        end;
        if (M > 0) then //matched differences found - assign average rank
        begin
            sum := sum + r[i-1]; // add the ith value too
            Avg := sum / (M + 1); // count the ith value too
            for j := i to (i + M) do r[j-1] := Avg;
            i := i + M + 1;
        end
        else i := i + 1;
    end;

    // Assign sign of difference to ranks
    for i := 1 to N do if (d[i-1] < 0.0) then  r[i-1] := -r[i-1];

    // Get sum of negative and positive difference ranks
    for i := 1 to N do
    begin
        if (d[i-1] < 0.0) then
        begin
            negsum := negsum + abs(r[i-1]);
            negcnt := negcnt + 1;
        end
        else
        begin
            possum := possum + abs(r[i-1]);
            poscnt := poscnt + 1;
        end;
    end;
    if (negsum < possum) then t := negsum
    else t := possum;
    numerator := t - ((N * (N + 1)) / 4.0);
    denominator := sqrt((N * (N + 1) * (2 * N + 1)) / 24.0);
    z := abs(numerator / denominator);
    zprob := 1.0 - probz(z);

    // Now, display results
    lReport := TStringList.Create;
    try
      lReport.Add('WILCONXON MATCHED-PAIRS SIGNED-RANKS TEST');
      lReport.Add('See pages 75-83 in S. Seigel: Nonparametric Statistics for the Social Sciences');
      lReport.Add('');
      lReport.Add('Ordered Cases with cases having 0 differences eliminated:');
      lReport.Add('Number of cases with absolute differences greater than 0: %d', [N]);
      lReport.Add('CASE %10s  %10s    Difference   Signed Rank', [labelone, labeltwo]);
      for i := 1 to N do
        lReport.Add('%3d      %6.2f      %6.2f    %6.2f    %6.2f', [index[i-1], A[i-1], b[i-1], d[i-1], r[i-1]]);
      lReport.Add('');
      lReport.Add('Smaller sum of ranks (T):                    %8.2f', [t]);
      lReport.Add('Approximately normal z for test statistic T: %8.4f', [z]);
      lReport.Add('Probability (1-tailed) of greater z:         %8.4f', [zprob]);
      lReport.Add('');
      lReport.Add('NOTE: For N < 25 use tabled values for Wilcoxon Test');

      DisplayReport(lReport);

    finally
      lReport.Free;
      r := nil;
      index := nil;
      d := nil;
      b := nil;
      A := nil;
      ColNoSelected := nil;
    end;
end;

procedure TWilcoxonFrm.UpdateBtnStates;
begin
  Var1In.Enabled := (VarList.ItemIndex > -1) and (Var1Edit.Text = '');
  Var2In.Enabled := (VarList.ItemIndex > -1) and (Var2Edit.Text = '');
  Var1Out.Enabled := (Var1Edit.Text <> '');
  Var2Out.Enabled := (Var2Edit.Text <> '');
end;


initialization
  {$I wilcoxonunit.lrs}

end.

