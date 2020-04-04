unit SignTestUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, Globals, DataProcs;

type

  { TSignTestFrm }

  TSignTestFrm = class(TForm)
    Bevel1: TBevel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    Var1In: TBitBtn;
    Var1Out: TBitBtn;
    Var2In: TBitBtn;
    Var2Out: TBitBtn;
    Var1Edit: TEdit;
    Var2Edit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
  SignTestFrm: TSignTestFrm;

implementation

uses
  Math;

{ TSignTestFrm }

procedure TSignTestFrm.ResetBtnClick(Sender: TObject);
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

procedure TSignTestFrm.Var1InClick(Sender: TObject);
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

procedure TSignTestFrm.Var1OutClick(Sender: TObject);
begin
  if Var1Edit.Text <> '' then
  begin
    VarList.Items.Add(Var1Edit.Text);
    Var1Edit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TSignTestFrm.Var2InClick(Sender: TObject);
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

procedure TSignTestFrm.Var2OutClick(Sender: TObject);
begin
  if Var2Edit.Text <> '' then
  begin
    VarList.Items.Add(Var2Edit.Text);
    Var2Edit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TSignTestFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TSignTestFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := 4*w; //Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TSignTestFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TSignTestFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TSignTestFrm.ComputeBtnClick(Sender: TObject);
var
   i, k, col1, col2, X, N, A, b, Temp : integer;
   ColNoSelected : IntDyneVec;
   DifSigns : IntDyneVec;
   p, Q, Probability, z, NoDiff, CorrectedA, x1, x2 : double;
   SumProb : double;
   cellstring: string;
   lReport: TStrings;
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

     SumProb := 0.0;
     SetLength(DifSigns,NoCases);
     SetLength(ColNoSelected,NoVariables);
     k := 2;

    // Get column numbers and labels of variables selected
    for i := 1 to NoVariables do
    begin
        cellstring := OS3MainFrm.DataGrid.Cells[i,0];
        if cellstring = Var1Edit.Text then ColNoSelected[0] := i;
        if cellstring = Var2Edit.Text then ColNoSelected[1] := i;
    end;

    p := 0.5;
    Q := 0.5;

    // Get sign of difference between pairs '(-1 := - ; 0 := no difference; +1 := +
    A := 0;
    b := 0;
    NoDiff := 0.0;
    for i := 1 to NoCases do
    begin
        if (not GoodRecord(i,k,ColNoSelected)) then continue;
        col1 := ColNoSelected[0];
        col2 := ColNoSelected[1];
        x1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col1,i]));
        x2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col2,i]));
        if (x1 > x2) then
        begin
            DifSigns[i-1] := 1;
            A := A + 1;
        end;
        if (x1 < x2) then
        begin
            DifSigns[i-1] := -1;
            b  := b + 1;
        end;
        if (x1 = x2) then
        begin
            DifSigns[i-1] := 0;
            NoDiff := NoDiff + 1.0;
        end;
    end;

    // Show results
    lReport := TStringList.Create;
    try
      lReport.Add('RESULTS FOR THE SIGN TEST');
      lReport.Add('');
      lReport.Add('Frequency of %d out of %d observed + sign differences.', [A, NoCases]);
      lReport.Add('Frequency of %d out of %d observed - sign differences.', [b, NoCases]);
      lReport.Add('Frequency of %.0f out of %d observed no differences.', [NoDiff, NoCases]);
      lReport.Add('');
      lReport.Add('The theoretical proportion expected for +''s or -''s is 0.5 ');
      lReport.Add('The test is for the probability of the +''s or -''s (which ever is fewer)');;
      lReport.Add('as small or smaller than that observed given the expected proportion.');
      lReport.Add('');

      // Swap A and B around if A > B
      if (A > b) then
      begin
        Temp := A;
        A := b;
        b := Temp;
      end;

      N := A + b;
      if (N > 25) then // Use normal distribution approximation
      begin
        CorrectedA := A;
        if (A < N * p) then  CorrectedA := A + 0.5;
        if (A > N * p) then CorrectedA := A - 0.5;
        z := (CorrectedA - N * p) / sqrt(N * p * Q);
        lReport.Add('Z value for Normal Distribution approximation: %.3f', [z]);
        Probability := probz(z);
        lReport.Add('Probability: %.4f', [Probability]);
    end
    else // Use binomial fomula
    begin
      X := 0;
      while X <= A do
      begin
        Probability := combos(X, N) * Power(p,X) * Power(Q,(N - X));
        lReport.Add('Binary Probability of %3d: %6.4f', [X, Probability]);
        SumProb := SumProb +  Probability;
        X := X + 1;
      end;
      lReport.Add('Binomial Probability of %d or smaller out of %d: %.4f', [A, N, SumProb]);
    end;

    DisplayReport(lReport);
  finally
    lReport.Free;
    DifSigns := nil;
    ColNoSelected := nil;
  end;
end;

procedure TSignTestFrm.UpdateBtnStates;
begin
  Var1In.Enabled := (VarList.ItemIndex > -1) and (Var1Edit.Text = '');
  Var2In.Enabled := (VarList.ItemIndex > -1) and (Var2Edit.Text = '');
  Var1Out.Enabled := (Var1Edit.Text <> '');
  Var2Out.Enabled := (Var2Edit.Text <> '');
end;


initialization
  {$I signtestunit.lrs}

end.

