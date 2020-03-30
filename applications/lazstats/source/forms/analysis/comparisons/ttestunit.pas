unit TTestUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit, DataProcs;

type

  { TTtestFrm }

  TTtestFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    GroupBox1: TGroupBox;
    GroupCodeBtn: TCheckBox;
    Grp1Code: TEdit;
    Grp2Code: TEdit;
    GrpCodeLabel1: TLabel;
    GrpCodeLabel2: TLabel;
    Memo1: TLabel;
    Notebook1: TNotebook;
    Page1: TPage;
    Page2: TPage;
    RadioGroup3: TRadioGroup;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    CorBetweenLabel: TLabel;
    Cor12: TEdit;
    CInterval: TEdit;
    Grp: TEdit;
    Label1: TLabel;
    Var2: TEdit;
    Var1: TEdit;
    FirstVarLabel: TLabel;
    GrpLabel: TLabel;
    SecdVarLabel: TLabel;
    ListBox1: TListBox;
    SelVarLabel: TLabel;
    N2: TEdit;
    N1: TEdit;
    SampSize2Label: TLabel;
    SampSize1Label: TLabel;
    SD2: TEdit;
    SD1: TEdit;
    SD2Label: TLabel;
    SD1Label: TLabel;
    Mean2: TEdit;
    Mean1: TEdit;
    Mean2Label: TLabel;
    Mean1Label: TLabel;
    Panel2: TPanel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GroupCodeBtnChange(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure RadioGroup2Click(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    independent: boolean;
    griddata: boolean;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;

  public
    { public declarations }
  end; 

var
  TtestFrm: TTtestFrm;

implementation

uses
  Math;

{ TTtestFrm }

procedure TTtestFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  CInterval.Text := FormatFloat('0.0', DEFAULT_CONFIDENCE_LEVEL_PERCENT);
  RadioGroup1.ItemIndex := 0;
   RadioGroup2.ItemIndex := 0;
   Notebook1.PageIndex := RadioGroup1.ItemIndex;
   ListBox1.Clear;
   Var1.Text := '';
   Var2.Text := '';
   Mean1.Text := '';
   Mean2.Text := '';
   SD1.Text := '';
   SD2.Text := '';
   N1.Text := '';
   N2.Text := '';
   Cor12.Text := '';
   independent := true;
   griddata := false;
   GroupCodeBtn.Checked := false;
   Grp.Text := '';
   for i := 1 to NoVariables do
     ListBox1.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
   Grp.Text := '';
   Grp1Code.Text := '';
   Grp2Code.Text := '';
end;

procedure TTtestFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := CInterval.Left + CInterval.Width + (Width - ResetBtn.Left) + ResetBtn.BorderSpacing.Left;

  Bevel5.Width := SecdVarLabel.Canvas.TextWidth(SecdVarlabel.Caption);
  //ListBox1.Constraints.MinHeight := Grp2Code.Top + Grp2Code.Height - Listbox1.Top - Var2.Height - Var2.BorderSpacing.Top;

  //Constraints.MinHeight := ListBox1.Top + ListBox1.Constraints.MinHeight + Bevel2.Height + CloseBtn.Height + CloseBtn.BorderSpacing.Top*2;
  FAutoSized := true;
end;

procedure TTtestFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TTtestFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TTtestFrm.GroupCodeBtnChange(Sender: TObject);
begin
  Grp1Code.Enabled := GroupCodeBtn.Checked;
  Grp2Code.Enabled := GroupCodeBtn.Checked;
  GrpCodeLabel1.Enabled := GroupCodeBtn.Checked;
  GrpCodeLabel2.Enabled := GroupCodeBtn.Checked;
end;

procedure TTtestFrm.ComputeBtnClick(Sender: TObject);
var
  M1, M2, Dif, stddev1, stddev2, r12, stderr1, stderr2: double;
  tequal, tunequal, cov12, lowci, hici, F, Fp, df1, df2: double;
  tprobability, value1, value2: double;
  variance1, variance2, pooled, sedif, df, ConfInt, tconfint: double;
  i, v1, v2, ncases1, ncases2, NoSelected: integer;
  group, min, max: integer;
  ColNoSelected: IntDyneVec;
  label1Str, label2Str: string;
  msg: String;
  C: TWinControl;
  lReport: TStrings;
begin
  if not Validate(msg, C) then
  begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    ModalResult := mrNone;
    exit;
  end;

  SetLength(ColNoSelected,NoVariables);
  ncases1 := 0;
  ncases2 := 0;
  variance1 := 0.0;
  variance2 := 0.0;
  M1 := 0.0;
  M2 := 0.0;
  Dif := 0.0;
  r12 := 0.0;
  v1 := 0;
  v2 := 0;
  stddev1 := 0.0;
  stddev2 := 0.0;

  ConfInt := (100.0 - StrToFloat(CInterval.Text)) / 2.0 ;
  ConfInt := (100.0 - ConfInt) / 100.0; // one tail

  if independent then
    Var2.Text := Grp.Text;

  // data read from grid
  if griddata then
  begin
    for i := 1 to NoVariables do
    begin
      if Var1.Text = OS3MainFrm.DataGrid.Cells[i,0] then
      begin
        v1 := i;
        ColNoSelected[0] := i;
        label1Str := Var1.Text;
      end;
      if Var2.Text = OS3MainFrm.DataGrid.Cells[i,0] then
      begin
        v2 := i;
        ColNoSelected[1] := i;
        label2Str := Var2.Text;
      end;
    end; // next variable

    ncases1 := 0;
    ncases2 := 0;
    NoSelected := 2;
    M1 := 0.0;
    M2 := 0.0;
    variance1 := 0.0;
    variance2 := 0.0;
    r12 := 0.0;
    if not independent then // correlated data
    begin
      for i := 1 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        ncases1 := ncases1 + 1;
        value1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v1,i]));
        value2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,i]));
        M1 := M1 + value1;
        M2 := M2 + value2;
        variance1 := variance1 + value1 * value1;
        variance2 := variance2 + value2 * value2;
        r12 := r12 + value1 * value2;
      end;

      ncases2 := ncases1;
      variance1 := variance1 - (M1 * M1 / ncases1);
      variance1 := variance1 / (ncases1 - 1);
      stddev1 := sqrt(variance1);
      variance2 := variance2 - (M2 * M2 / ncases2);
      variance2 := variance2 / (ncases2 - 1);
      stddev2 := sqrt(variance2);
      r12 := r12 - (M1 * M2 / ncases1);
      r12 := r12 / (ncases1 - 1);
      cov12 := r12;
      r12 := r12 / (stddev1 * stddev2);
      M1 := M1 / ncases1;
      M2 := M2 / ncases2;
      Dif := M1 - M2;
    end; //if not independent

    if independent then
    begin
      if GroupCodeBtn.Checked then
      begin
        min := StrToInt(Grp1Code.Text);
        max := StrToInt(Grp2Code.Text);
                    {
                    response := InputBox('Group 1','Enter the code for group 1','1');
                    min := StrToInt(response);
                    response := InputBox('Group 2','Enter the code for group 2','2');
                    max := StrToInt(response);
                    }
      end else
      begin
        min := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,1])));
        max := min;
      end;

      for i := 2 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,i])));
        if GroupCodeBtn.Checked = false then
        begin
          if group < min then min := group;
          if group > max then max := group;
        end;
      end;

      for i := 1 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        value1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v1,i]));
        value2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,i]));
        group := round(value2);
        if group = min then
        begin
          M1 := M1 + value1;
          variance1 := variance1 + (value1 * value1);
          ncases1 := ncases1 + 1;
        end else if group = max then
        begin
          M2 := M2 + value1;
          variance2 := variance2 + (value1 * value1);
          ncases2 := Ncases2 + 1;
        end;
      end; // next case

      variance1 := variance1 - ((M1 * M1) / ncases1);
      variance1 := variance1 / (ncases1 - 1);
      stddev1 := sqrt(variance1);
      variance2 := variance2 - ((M2 * M2) / ncases2);
      variance2 := variance2 / (ncases2 - 1);
      stddev2 := sqrt(variance2);
      M1 := M1 / ncases1;
      M2 := M2 / ncases2;
      Dif := M1 - M2;
      Label1Str := format('Group %d',[min]);
      Label2Str := format('Group %d',[max]);
    end; // if independent data
  end; // if reading grid data

  if not griddata then // data read from form
  begin
    M1 := StrToFloat(Mean1.Text);
    M2 := StrToFloat(Mean2.Text);
    stddev1 := StrToFloat(SD1.Text);
    stddev2 := StrToFloat(SD2.Text);
    ncases1 := round(StrToFloat(N1.Text));
    ncases2 := round(StrToFloat(N2.Text));
    variance1 := stddev1 * stddev1;
    variance2 := stddev2 * stddev2;
    Label1Str := 'Group 1';
    Label2Str := 'Group 2';
    Dif := M1 - M2;
    if not independent then
    begin
      r12 := StrToFloat(Cor12.Text);
      cov12 := r12 * stddev1 * stddev2;
    end;
  end;


  // Initialize output form
  lReport := TStringList.Create;
  try
    lReport.Add('COMPARISON OF TWO MEANS');
    lReport.Add('');

    // Calculate pooled and independent t and z values and test statistic
    if independent then
    begin
      stderr1 := sqrt(variance1 / ncases1);
      Stderr2 := sqrt(variance2 / ncases2);
      lReport.Add('Variable    Mean    Variance  Std.Dev.  S.E.Mean  N');
      lReport.Add('%-10s%8.2f  %8.2f  %8.2f  %8.2f  %d', [Label1Str, M1, variance1, stddev1, stderr1, ncases1]);
      lReport.Add('%-10s%8.2f  %8.2f  %8.2f  %8.2f  %d', [Label2Str, M2, variance2, stddev2, stderr2, ncases2]);
      lReport.Add('');

      pooled := ((ncases1-1) * variance1) + ((ncases2-1) * variance2);
      pooled := pooled / (ncases1 + ncases2 - 2);
      pooled := pooled * ( 1.0 / ncases1 + 1.0 / ncases2);
      sedif := sqrt(pooled);
      tequal := dif / sedif;
      df := ncases1 + ncases2 - 2;
      tprobability := probt(tequal,df);
      if RadioGroup3.ItemIndex = 1 then tprobability := 0.5 * tprobability;
      lReport.Add('Assuming equal variances, t = %.3f with probability = %.4f and %.0f degrees of freedom', [
        tequal, tprobability, df
      ]);
      lReport.Add('Difference = %.2f and Standard Error of difference = %.2f', [dif, sedif]);

      tconfint := inverset(ConfInt,df);
      lowci := dif - tconfint * sedif;
      hici := dif + tconfint * sedif;
      lReport.Add('Confidence interval = (%.2f ... %.2f)', [lowci, hici]);

      // now for unequal variances
      sedif := sqrt((variance1 / ncases1) + (variance2 / ncases2));
      tunequal := dif / sedif;
      df := sqr((variance1 / ncases1) + (variance2 / ncases2));
      df := df / (sqr(variance1 / ncases1) / (ncases1 - 1) + sqr(variance2 / ncases2) / (ncases2 - 1) );
      tprobability := probt(tequal,df);
      if RadioGroup3.ItemIndex = 1 then tprobability := 0.5 * tprobability;
      lReport.Add('Assuming unequal variances, t = %.3f with probability = %.4f and %.0f degrees of freedom', [
        tunequal, tprobability, df
      ]);
      lReport.Add('Difference = %.2f and Standard Error of difference = %.2f', [dif, sedif]);

      tconfint := inverset(ConfInt,df);
      lowci := dif - tconfint * sedif;
      hici := dif + tconfint * sedif;
      lReport.Add('Confidence interval = (%.2f ... %.2f)', [lowci, hici]);

      df1 := ncases1 - 1;
      df2 := ncases2 - 1;
      if variance1 > variance2 then
      begin
        F := variance1 / variance2;
        Fp := probf(F,df1,df2);
      end else
      begin
        F := variance2 / variance1;
        Fp := probf(F,df2,df1);
      end;
      lReport.Add('F test for equal variances = %.3f, Probability = %.4f', [F, fp]);
     end
    else
    // dependent t test
    begin
      stderr1 := sqrt(variance1 / ncases1);
      Stderr2 := sqrt(variance2 / ncases2);
      lReport.Add('Variable    Mean    Variance  Std.Dev.  S.E.Mean  N');
      lReport.Add('%-10s%8.2f  %8.2f  %8.2f  %8.2f  %d', [Label1Str, M1, variance1, stddev1, stderr1, ncases1]);
      lReport.Add('%-10s%8.2f  %8.2f  %8.2f  %8.2f  %d', [Label2Str,M2, variance2, stddev2, stderr2, ncases2]);
      lReport.Add('');
      sedif := variance1 + variance2 - (2.0 * cov12);
      sedif := sqrt(sedif / ncases1);
      tequal := Dif / sedif;
      df := ncases1 - 1;
      tprobability := probt(tequal,df);
      lReport.Add('Assuming dependent samples, t = %.3f with probability = %.4f and %.0f degrees of freedom', [
        tequal, tprobability, df
      ]);
      lReport.Add('Correlation between %s and %s = %.3f', [Label1Str, Label2Str, r12]);
      lReport.Add('Difference = %.2f and Standard Error of difference = %.2f', [dif, sedif]);

      tconfint := inverset(ConfInt,df);
      lowci := dif - tconfint * sedif;
      hici := dif + tconfint * sedif;
      lReport.Add('Confidence interval = (%.2f ... %.2f)', [lowci, hici]);

      tequal := variance1 - variance2;
      tequal := tequal / sqrt( (4 * variance1 * variance2)/(ncases1 - 2) * (1.0 - sqr(r12)) );
      df := ncases1 - 2;
      tprobability := probt(tequal,df);
      lReport.Add('t for test of equal variances = %.3f with probability = %.4f', [tequal, tprobability]);
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;
    ColNoSelected := nil;
  end;
end;

procedure TTtestFrm.ListBox1Click(Sender: TObject);
VAR index : integer;
begin
     index := ListBox1.ItemIndex;
     if not independent then
     begin
          if Var1.Text <> '' then Var2.Text := ListBox1.Items.Strings[index]
          else Var1.Text := ListBox1.Items.Strings[index];
     end;
     if independent then
     begin
          if Var1.Text <> '' then Grp.Text := ListBox1.Items.Strings[index]
          else Var1.Text := ListBox1.Items.Strings[index];
     end;
end;

procedure TTtestFrm.RadioGroup1Click(Sender: TObject);
VAR
  index : integer;
begin
     index := RadioGroup1.ItemIndex;
     Notebook1.PageIndex := index;
     if index = 0 then
     begin
//          Panel2.Visible := true;
//          Panel1.Visible := false;
          griddata := false;
     end
     else
     begin
//          Panel1.Visible := true;
//          Panel2.Visible := false;
          griddata := true;
          if RadioGroup2.ItemIndex = 1 then
          begin
               SecdVarLabel.Visible := true;
               Var2.Visible := true;
               Grp.Visible := false;
               GrpLabel.Visible := false;
          end
          else
          begin
               SecdVarLabel.Visible := false;
               Var2.Visible := false;
               Grp.Visible := true;
               GrpLabel.Visible := true;
          end;
     end;
end;

procedure TTtestFrm.RadioGroup2Click(Sender: TObject);
var
  index: integer;
begin
  index := RadioGroup2.ItemIndex;
  independent := (index = 0);
  Grp.Visible := independent;
  GrpLabel.Visible := independent;
  GroupCodeBtn.Visible := independent;
  GroupBox1.Visible := independent;
  SecdVarLabel.Visible := not independent;
  Var2.Visible := not independent;
  {
     if index = 0 then
     begin
          independent := true;
          CorBetweenLabel.Visible := false;
          Cor12.Visible := false;
          Grp.Visible := true;
          GrpLabel.Visible := true;
          GroupCodeBtn.Visible := true;
          Groupbxo1.Visible := true;
          SecdVarLabel.Visible := false;
          Var2.Visible := false;
     end
     else
     begin
          independent := false;
          CorBetweenLabel.Visible := true;
          Cor12.Visible := true;
          GrpLabel.Visible := false;
          Grp.Visible := false;
          GroupCodeBtn.Visible := false;
          SecdVarLabel.Visible := true;
          Var2.Visible := true;
     end;
     }
end;

function TTtestFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
  x: Double;
begin
  Result := false;
  AControl := nil;
  AMsg := '';
  if Notebook1.PageIndex = 0 then
  begin
    if (Mean1.Text = '') or not TryStrToFloat(Mean1.Text, x) then
    begin
      AControl := Mean1;
      AMsg := 'Invalid input for the mean of sample 1';
      exit;
    end;
    if (SD1.Text = '') or not TryStrToFloat(SD1.Text, x) or (x <= 0) then
    begin
      AControl := SD1;
      AMsg := 'Invald input for the standard deviation of sample 1';
      exit;
    end;
    if (N1.Text = '') or not TryStrToInt(N1.Text, n) or (n <= 0) then
    begin
      AControl := N1;
      AMsg := 'Invald input for the size of sample 1';
      exit;
    end;
    if (Mean2.Text = '') or not TryStrToFloat(Mean2.Text, x) then
    begin
      AControl := Mean2;
      AMsg := 'Invalid input for the mean of sample 2';
      exit;
    end;
    if (SD2.Text = '') or not TryStrToFloat(SD2.Text, x) or (x <= 0) then
    begin
      AControl := SD2;
      AMsg := 'Invald input for the standard deviation of sample 2';
      exit;
    end;
    if (N2.Text = '') or not TryStrToInt(N2.Text, n) or (n <= 0) then
    begin
      AControl := N2;
      AMsg := 'Invald input for the size of sample 2';
      exit;
    end;
  end else
  if Notebook1.PageIndex = 1 then
  begin
    if (Var1.Text = '')  then
    begin
      AControl := Var1;
      AMsg := 'Variable 1 not specified.';
      exit;
    end;
    if Var2.Visible and (Var2.Text = '') then
    begin
      AControl := Var2;
      AMsg := 'Variable 2 not specified.';
      exit;
    end;
    if Grp.Visible and (Grp.Text = '') then
    begin
      AControl := Grp;
      AMsg := 'Group variable not specified.';
      exit;
    end;
    if Grp1Code.Visible and ((Grp1Code.Text = '') or not TryStrToInt(Grp1Code.Text, n))then
    begin
      AControl := Grp1Code;
      AMsg := 'Code for group 1 missing.';
      exit;
    end;
    if Grp2Code.Visible and ((Grp2Code.Text = '') or not TryStrToInt(Grp2Code.Text, n))then
    begin
      AControl := Grp2Code;
      AMsg := 'Code for group 2 missing.';
      exit;
    end;
  end;
  Result := true;
end;

initialization
  {$I ttestunit.lrs}

end.

