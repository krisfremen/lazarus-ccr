// Use file "cansas.laz" for testing

unit NormalityUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, DataProcs, OutputUnit;


type

  { TNormalityFrm }

  TNormalityFrm = class(TForm)
    Bevel1: TBevel;
    ResetBtn: TButton;
    PrintBtn: TButton;
    ApplyBtn: TButton;
    CloseBtn: TButton;
    ConclusionEdit: TEdit;
    Label8: TLabel;
    Panel1: TPanel;
    StatEdit: TEdit;
    KurtosisEdit: TEdit;
    SkewEdit: TEdit;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ProbEdit: TEdit;
    Label4: TLabel;
    WEdit: TEdit;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    TestVarEdit: TEdit;
    Label2: TLabel;
    VarInBtn: TBitBtn;
    VarOutBtn: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure ApplyBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarInBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure VarOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: boolean;
    function Norm(z : double) : double;
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  NormalityFrm: TNormalityFrm;

implementation

uses
  Math;

{ TNormalityFrm }

procedure TNormalityFrm.PrintBtnClick(Sender: TObject);
var
  lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
    lReport.Add('NORMALITY TESTS FOR '+ TestVarEdit.Text);
    lReport.Add('');
    lReport.Add('Shapiro-Wilkes W = ' + WEdit.Text);
    lReport.Add('Shapiro-Wilkes Prob. = ' + ProbEdit.Text);
    lReport.Add('');
    lReport.Add('Skew = ' + SkewEdit.Text);
    lReport.Add('Kurtosis = ' + KurtosisEdit.Text);
    lReport.Add('Lilliefors Test Statistic = ' + StatEdit.Text);
    lReport.Add('Conclusion: ' + ConclusionEdit.Text);

    DisplayReport(lReport);
  finally
    lReport.Free;
  end;
end;

procedure TNormalityFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  TestVarEdit.Text := '';
  WEdit.Text := '';
  ProbEdit.Text := '';
  ConclusionEdit.Text := '';
  SkewEdit.Text := '';
  KurtosisEdit.Text := '';
  StatEdit.Text := '';
  VarList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TNormalityFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, PrintBtn.Width, ApplyBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  PrintBtn.Constraints.MinWidth := w;
  ApplyBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  FAutoSized := True;
end;

procedure TNormalityFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TNormalityFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(nil);
end;

procedure TNormalityFrm.ApplyBtnClick(Sender: TObject);
var
  w: Double = 0.0;
  temp, pw : double;
  skew, kurtosis : double;
  mean, variance, stddev, deviation, devsqr, M2, M3, M4 : double;
  i, j, n, n1, n2, ier : integer;
  varlabel : string;
  selcol : integer;
  data, a, z, x : DblDyneVec;
  freq : IntDyneVec;
  fval, jval, DP : DblDyneVec;
  F1, DPP, D, D1, A0, C1, D15, D10, D05, D025, t2 : double;
  init : boolean;
  msg : string;

  procedure Cleanup;
  begin
    DP := nil;
    jval := nil;
    fval := nil;
    data := nil;
    a := nil;
    freq := nil;
    z := nil;
    x := nil;
  end;

begin
  selcol := 0;
  for i := 1 to NoVariables do
    if OS3MainFrm.DataGrid.Cells[i,0] = TestVarEdit.Text then
    begin
      selcol := i;
      break;
    end;
  if selCol = 0 then
  begin
    MessageDlg('No variable selected.', mtError, [mbOK], 0);
    exit;
  end;

  init := false;
  n := 0;
  varlabel := TestVarEdit.Text;

  // place values into the data array
  SetLength(data, NoCases+1); // arrays start at 1
  SetLength(a, NoCases+1);
  SetLength(freq, NoCases+1);
  SetLength(z, NoCases+1);
  SetLength(x, NoCases+1);
  SetLength(fval, NoCases+1);
  SetLength(jval, NoCases+1);
  SetLength(DP, NoCases+1);
  for i := 1 to NoCases do
  begin
    if not ValidValue(i,selcol) then
      continue;
    n := n + 1;
    data[n] := StrToFloat(OS3MainFrm.DataGrid.Cells[selcol,i]);
  end;
  n1 := n;
  n2 := n div 2;

  // sort into ascending order
  for i := 1 to n - 1 do
  begin
    for j := i + 1 to n do
    begin
      if data[i] > data[j] then
      begin
        temp := data[i];
        data[i] := data[j];
        data[j] := temp;
      end;
    end;
  end;

  // call Shapiro-Wilks function
  swilk(init, data, n, n1, n2, a, w, pw, ier);
  if ier <> 0 then
  begin
    msg := 'Error encountered = ' + IntToStr(ier);
    MessageDlg(msg, mtError, [mbOK], 0);
    Cleanup;
    exit;
  end;
  WEdit.Text := Format('%8.4f', [w]);
  ProbEdit.Text := Format('%8.4f', [pw]);

  // Now do Lilliefors
  // Get unique scores and their frequencies
  n1 := 1;
  i := 1;
  freq[1] := 1;
  x[1] := data[1];
  repeat
//again:
    for j := i + 1 to n do
    begin
      if data[j] = x[n1] then freq[n1] := freq[n1] + 1;
    end;
    i := i + freq[n1];
    if i <= n then
    begin
      n1 := n1 + 1;
      x[n1] := data[i];
      freq[n1] := 1;
      //goto again;
    end;
  until i > n;

  // now get skew and kurtosis of scores
  mean := 0.0;
  variance := 0.0;
  for i := 1 to n do
  begin
    mean := mean + data[i];
    variance := variance + (data[i] * data[i]);
  end;
  variance := variance - (mean * mean) / n;
  variance := variance / (n - 1);
  stddev := sqrt(variance);
  mean := mean / n;

  // obtain skew, kurtosis and z scores
  M2 := 0.0;
  M3 := 0.0;
  M4 := 0.0;
  for i := 1 to n do
  begin
    deviation := data[i] - mean;
    devsqr := deviation * deviation;
    M2 := M2 + devsqr;
    M3 := M3 + (deviation * devsqr);
    M4 := M4 + (devsqr * devsqr);
    z[i] := (data[i] - mean) / stddev;
  end;
  for i := 1 to n1 do x[i] := (x[i] - mean) / stddev;
    skew := (n * M3) / ((n - 1) * (n - 2) * stddev * variance);
  kurtosis := (n * (n + 1) * M4) - (3 * M2 * M2 * (n - 1));
  kurtosis := kurtosis /( (n - 1) * (n - 2) * (n - 3) * (variance * variance) );
  SkewEdit.Text := Format('%8.3f', [skew]);
  KurtosisEdit.Text := Format('%8.3f', [kurtosis]);

  // obtain the test statistic
  for i := 1 to n1 do
  begin
    F1 := Norm(x[i]);
    if x[i] >= 0 then
      fval[i] := 1.0 - (F1 / 2.0)
    else
      fval[i] := F1 / 2.0;
  end;

  // cumulative proportions
  jval[1] := freq[1] / n;
  for i := 2 to n1 do jval[i] := jval[i-1] + freq[i] / n;
  for i := 1 to n1 do DP[i] := abs(jval[i] - fval[i]);

  // sort DP
  for i := 1 to n1-1 do
  begin
    for j := i+1 to n1 do
    begin
      if DP[j] < DP[i] then
      begin
        temp := DP[i];
        DP[i] := DP[j];
        DP[j] := temp;
      end;
    end;
  end;
  DPP := DP[n1];
  D := DPP;
  D1 := D;
  StatEdit.Text := Format('%8.3f', [D]);
  A0 := sqrt(n);
  C1 := A0 - 0.01 + (0.85 / A0);
  D15 := 0.775 / C1;
  D10 := 0.819 / C1;
  D05 := 0.895 / C1;
  D025 := 0.995 / C1;
  t2 := D;
  if t2 > D025 then ConclusionEdit.Text := 'Strong evidence against normality.';
  if ((t2 <= D025) and (t2 > D05)) then ConclusionEdit.Text := 'Sufficient evidence against normality.';
  if ((t2 <= D05) and (t2 > D10)) then ConclusionEdit.Text := 'Suggestive evidence against normality.';
  if ((t2 <= D10) and (t2 > D15)) then ConclusionEdit.Text := 'Little evidence against normality.';
  if (t2 <= D15) then ConclusionEdit.Text := 'No evidence against normality.';

  Cleanup;
end;

procedure TNormalityFrm.VarInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := VarList.ItemIndex;
  if (i > -1) and (TestVarEdit.Text = '') then
  begin
    TestVarEdit.Text := VarList.Items.Strings[i];
    VarList.Items.Delete(i);
  end;
  UpdateBtnStates;
end;

procedure TNormalityFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TNormalityFrm.VarOutBtnClick(Sender: TObject);
begin
  if TestVarEdit.Text <> '' then
  begin
    VarList.Items.Add(TestVarEdit.Text);
    TestVarEdit.Text := '';
  end;
  UpdateBtnStates;
end;

function TNormalityFrm.Norm(z : double) : double;
var
   p : double;
begin
     z := abs(z);
     p := 1.0 + z * (0.04986735 + z * (0.02114101 + z * (0.00327763 +
          z * (0.0000380036 + z * (0.0000488906 + z * 0.000005383)))));
     p := p * p;
     p := p * p;
     p := p * p;
     Result := 1.0 / (p * p);
end;

procedure TNormalityFrm.UpdateBtnStates;
begin
  VarInBtn.Enabled := (VarList.ItemIndex > -1) and (TestVarEdit.Text = '');
  VarOutBtn.Enabled := (TestVarEdit.Text <> '');
end;

initialization
  {$I normalityunit.lrs}

end.

