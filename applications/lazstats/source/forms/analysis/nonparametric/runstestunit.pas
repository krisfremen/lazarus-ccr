// File for testing: RunTest.laz, use VAR1

unit RunsTestUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, DataProcs;

type

  { TRunstestform }

  Trunstestform = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    ComputeBtn: TButton;
    MeanEdit: TEdit;
    Memo1: TLabel;
    ResetBtn: TButton;
    CloseBtn: TButton;
    StdDevEdit: TEdit;
    NUpEdit: TEdit;
    NDownEdit: TEdit;
    NRunsEdit: TEdit;
    StatEdit: TEdit;
    ProbEdit: TEdit;
    ConclusionEdit: TEdit;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    Label10: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    TestVarEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
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
  runstestform: Trunstestform;

implementation

uses
  Math, Utils;

{ Trunstestform }

procedure Trunstestform.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  TestVarEdit.Text := '';
  MeanEdit.Text := '';
  StdDevEdit.Text := '';
  NUpEdit.Text := '';
  NDownEdit.Text := '';
  StatEdit.Text := '';
  ProbEdit.Text := '';
  ConclusionEdit.Text := '';
  NRunsEdit.Text := '';
  UpdateBtnStates;
end;

procedure Trunstestform.ComputeBtnClick(Sender: TObject);
var
  a, i, col, N, N1, N2, NLess, Nmore, R: integer;
  Mean, ExpMean, SD1, SD2, SD3, SD4, SD, z1, z2, z, t, p1, p: double;
  strvalue: string;
  values: DblDyneVec;
begin
  col := 0;
  N := 0;
  N1 := 0;
  N2 := 0;
  Nless := 0;
  Nmore := 0;
  R := 1;
  Mean := 0.0;
  for i := 1 to NoVariables do
  begin
    strvalue := Trim(OS3MainFrm.DataGrid.Cells[i,0]);
    if TestVarEdit.Text = strvalue then col := i;
  end;
  if col = 0 then
  begin
    MessageDlg('No variable was selected.', mtError, [mbOK], 0);
    exit;
  end;

  SetLength(Values, NoCases);
  for i := 1 to NoCases do
  begin
    if not ValidValue(i, col) then continue;
    Values[i-1] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
    N := N + 1;
  end;

  if N <= 10 then
  begin
    MessageDlg('Insufficient data. You must have at least 11 values.', mtError, [mbOK], 0);
    Values := nil;
    exit;
  end;

  for i := 0 to N-1 do
    Mean := Mean + values[i];
  Mean := Mean / N;

  // run through each value and compare with the mean
  for i := 0 to N-1 do
  begin  // check and discard the ties with the mean
    if Mean <> Values[i] then
    begin // check if it is greater than the mean
      if Values[i] > mean then
      begin
        N1 := N1 + 1;
        a := i;
        while a > 0 do
        begin
          a := a - 1;
          if Values[a] <> Mean then break;
        end;
        if Values[a] < Mean then
        begin
          R := R + 1;
          NLess := NLess + 1;
        end;
      end
      else // check to see if it is less than the mean
      if Values[i] < Mean then
      begin
        N2 := N2 + 1;
        a := i;
        while a > 0 do
        begin
          a := a - 1;
          if Values[a] <> Mean then break;
        end;
        if Values[a] > Mean then
        begin
          R := R + 1;
          Nmore := Nmore + 1;
        end;
      end; // close of else i
    end; // end of if values[i] not equal to the mean
  end; // end of i loop

  // compute the expected mean and variance of R
  ExpMean := 1.0 + ((2 * N1 * N2) / (N1 + N2)); // mean mu
  SD1 := 2 * N1 * N2 * (2 * N1 * N2 - N1 - N2);
  SD2 := power((N1 + N2), 2);
  SD3 := N1 + N2 - 1;
  SD4 := SD1 / (SD2 * SD3); // standard deviation "sigma"
  SD := sqrt(SD4);

  // calculating P Value
  z1 := (R - ExpMean) / SD;
  z2 := abs(z1);
  z := z2;
  if z > 0 then
    t := z
  else
    t := -z;
  p1 := power(
          (1 + t * (0.049867347 + t * (0.0211410061 + t * (0.0032776283 +
            t * (0.0000380036 + t * (0.0000488906 + t * (0.000005383))))))),
          -16
        );
  p := 1.0 - p1 / 2.0;
  if z > 0.0 then
    t := 1.0 - p
  else
    t := 1.0 - (1.0 - p); // this is P value

  // show results
  MeanEdit.Text := Format('%.3f', [Mean]);
  StdDevEdit.Text := Format('%.3f', [SD]);
  NUpEdit.Text := IntToStr(N1);
  NDownEdit.Text := IntToStr(N2);
  NRunsEdit.Text := IntToStr(R);
  StatEdit.Text := Format('%.3f', [z]);
  ProbEdit.Text := Format('%.3f', [z]);

  // determine the conclusion
  if t < 0.01 then
    ConclusionEdit.Text := 'Very strong evidence against randomness (trend or seasonality'
  else if (t < 0.05) and (t >= 0.01) then
    ConclusionEdit.Text := 'Moderate evidence against randomness'
  else if (t < 0.10) and (t >= 0.05) then
    ConclusionEdit.Text := 'Suggestive evidence against normality'
  else if t >= 0.10 then
    ConclusionEdit.Text := 'Little or no real evidence against randomness'
  else
    ConclusionEdit.Text := 'Strong evidence against randomness (trend or seasonality exists)';

  Values := nil;
end;

procedure Trunstestform.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure Trunstestform.FormCreate(Sender: TObject);
begin
  Assert(OS3Mainfrm <> nil);
end;

procedure Trunstestform.InBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (TestVarEdit.Text = '') then
  begin
    TestVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure Trunstestform.OutBtnClick(Sender: TObject);
begin
  if TestVarEdit.Text <> '' then
  begin
    VarList.Items.Add(TestVarEdit.Text);
    TestVarEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TRunsTestForm.UpdateBtnStates;
begin
  InBtn.Enabled := AnySelected(VarList) and (TestVarEdit.Text = '');
  OutBtn.Enabled := TestVarEdit.Text <> '';
end;

procedure Trunstestform.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I runstestunit.lrs}

end.

