unit TwoCorrsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit, DataProcs, ContextHelpUnit;

type

  { TTwoCorrsFrm }

  TTwoCorrsFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    Notebook1: TNotebook;
    Page1: TPage;
    Page2: TPage;
    Page3: TPage;
    Panel1: TPanel;
    PanelPage1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    CInterval: TEdit;
    Label14: TLabel;
    Xvar: TEdit;
    Yvar: TEdit;
    Zvar: TEdit;
    GroupVar: TEdit;
    xlabel: TLabel;
    ylabel: TLabel;
    zlabel: TLabel;
    GroupLabel: TLabel;
    SelVarLabel: TLabel;
    VarList: TListBox;
    PanelPage3: TPanel;
    rxy1: TEdit;
    Size1: TEdit;
    rxy2: TEdit;
    Size2: TEdit;
    firstcorlabel: TLabel;
    size1label: TLabel;
    SecdCorLabel: TLabel;
    Size2Label: TLabel;
    rxy: TEdit;
    rxz: TEdit;
    ryz: TEdit;
    SampSize: TEdit;
    corxylabel: TLabel;
    corxzlabel: TLabel;
    coryzlabel: TLabel;
    sampsizelabel: TLabel;
    PanelPage2: TPanel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure RadioGroup2Click(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListClick(Sender: TObject);
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
  TwoCorrsFrm: TTwoCorrsFrm;

implementation

uses
  Math;

{ TTwoCorrsFrm }

procedure TTwoCorrsFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  CInterval.Text := FormatFloat('0.0', DEFAULT_CONFIDENCE_LEVEL_PERCENT);

  RadioGroup1.ItemIndex := 0;
  RadioGroup2.ItemIndex := 0;
  Notebook1.PageIndex := 0;
  VarList.Clear;
  Xvar.Text := '';
  Yvar.Text := '';
  Zvar.Text := '';
  rxy.Text := '';
  rxz.Text := '';
  ryz.Text := '';
  SampSize.Text := '';
  rxy1.Text := '';
  rxy2.Text := '';
  Size1.Text := '';
  Size2.Text := '';
  zlabel.Visible := false;
  Zvar.Visible := false;
  GroupLabel.Visible := true;
  GroupVar.Text := '';
  GroupVar.Visible := true;
  independent := true;
  griddata := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TTwoCorrsFrm.VarListClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if Xvar.Text = '' then
  begin
    Xvar.Text := VarList.Items.Strings[index];
    exit;
  end;

  if Yvar.Text = '' then
  begin
    Yvar.Text := VarList.Items.Strings[index];
    exit;
  end;

  if not independent then
  begin
    if Zvar.Text = '' then
    begin
      Zvar.Text := VarList.Items.Strings[index];
      exit;
    end;
  end;

  if independent then
  begin
    if GroupVar.Text = '' then
    begin
      GroupVar.Text := VarList.Items.Strings[index];
      exit;
    end;
  end;
end;

procedure TTwoCorrsFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Width := Max(
    RadioGroup2.Left + RadioGroup2.Width + RadioGroup2.BorderSpacing.Right,
    Width - HelpBtn.Left + HelpBtn.BorderSpacing.Left
  );
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TTwoCorrsFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TTwoCorrsFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TTwoCorrsFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TTwoCorrsFrm.ComputeBtnClick(Sender: TObject);
var
  Corxy, Corxz, Coryz, Cor1, Cor2, alpha, tvalue, df1, df2: double;
  CorDif, zOne, zTwo, zDif, StdErr, zValue, zprobability: double;
  UCL, LCL, ztest, ConfLevel, tprobability, ttest: double;
  mean1, mean2, mean3, variance1, variance2, variance3: double;
  stddev1, stddev2, stddev3, value1, value2, value3: double;
  meanx1, meanx2, meany1, meany2, varx1, varx2, vary1, vary2: double;
  sdx1, sdx2, sdy1, sdy2: double;
  SSize1, SSize2, SSize, v1, v2, v3, grp, ncases, NoSelected: integer;
  min, max, grpval, ncases1, ncases2, i: integer;
  cellstring: string;
  ColNoSelected: IntDyneVec;
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
  Corxy := 0.0;
  Corxz := 0.0;
  Coryz := 0.0;
  Cor1 := 0.0;
  Cor2 := 0.0;
  mean1 := 0.0;
  mean2 := 0.0;
  mean3 := 0.0;
  variance1 := 0.0;
  variance2 := 0.0;
  variance3 := 0.0;
  meanx1 := 0.0;
  meanx2 := 0.0;
  meany1 := 0.0;
  ConfLevel := StrToFloat(CInterval.Text) / 100.0;

  // *** USE DATA ON THE FORM ***
  if not griddata then
  begin
    // read data from form and obtain results
    if independent then
    begin
      Cor1 := StrToFloat(rxy1.Text);
      Cor2 := StrToFloat(rxy2.Text);
      SSize1 := StrToInt(Size1.Text);
      SSize2 := StrToInt(Size2.Text);
      CorDif := Cor1 - Cor2;
      zOne := 0.5 * ln((1.0 + Cor1) / (1.0 - Cor1));
      zTwo := 0.5 * ln((1.0 + Cor2) / (1.0 - Cor2));
      zDif := zOne - zTwo;
      StdErr := sqrt((1.0 / (SSize1 - 3.0)) + (1.0 / (SSize2 -3.0)));
      zValue := zDif / StdErr;
      alpha := (1.0 - ConfLevel) / 2.0;
      zTest := inversez(1.0 - alpha);
      zprobability := 1.0 - probz(zValue);
      UCL := zDif + StdErr * zTest;
      LCL := zDif - StdErr * zTest;
      UCL := (exp(2.0 * UCL) - 1.0) / (exp(2.0 * UCL) + 1.0);
      LCL := (exp(2.0 * LCL) - 1.0) / (exp(2.0 * LCL) + 1.0);
    end;

    // obtain data from form and obtain results
    if not independent then
    begin
      Corxy := StrToFloat(rxy.Text);
      Corxz := StrToFloat(rxz.Text);
      Coryz := StrToFloat(ryz.Text);
      SSize := StrToInt(SampSize.Text);
      CorDif := Corxy - Corxz;
      alpha := (1.0 - ConfLevel) / 2.0;
      tvalue := CorDif * sqrt((SSize - 3.0) * (1.0 + Coryz)) / sqrt(2.0 * (1.0 - Corxy*Corxy - Corxz*Corxz - Coryz*Coryz + 2.0*Corxy*Corxz*Coryz));
      df1 := 1.0;
      df2 := SSize - 3.0;
      tprobability := probt(tvalue,df2);
      ttest := inverset(1.0 - alpha, df2);
    end;
  end;

  if griddata then
  begin
    v1 := 1;
    v2 := 1;
    grp := 1;

    // read grid data for independent r's
    if independent then
    begin
      for i := 1 to NoVariables do
      begin
        cellstring := OS3MainFrm.DataGrid.Cells[i,0];
        if cellstring = Xvar.Text then v1 := i;
        if cellstring = Yvar.Text then v2 := i;
        if cellstring = GroupVar.Text then grp := i;
      end;
      ColNoSelected[0] := v1;
      ColNoSelected[1] := v2;
      ColNoSelected[2] := grp;
      NoSelected := 3;
      meanx1 := 0.0;
      meany1 := 0.0;
      varx1 := 0.0;
      vary1 := 0.0;
      meanx2 := 0.0;
      meany2 := 0.0;
      varx2 := 0.0;
      vary2 := 0.0;
      Cor1 := 0.0;
      Cor2 := 0.0;
      ncases1 := 0;
      ncases2 := 0;
      min := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[grp,1])));
      max := min;
      for i := 2 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        grpval := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[grp,i])));
        if grpval > max then max := grpval;
        if grpval < min then min := grpval;
      end;
      for i := 1 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        grpval := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[grp,i])));
        if grpval = min then
        begin
          ncases1 := ncases1 + 1;
          value1 :=  StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v1,i]));
          meanx1 := meanx1 + value1;
          varx1 := varx1 + (value1 * value1);
          value2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,i]));
          meany1 := meany1 + value2;
          vary1 := vary1 + value2 * value2;
          Cor1 := Cor1 + value1 * value2;
        end;
        if grpval = max then
        begin
          ncases2 := ncases2 + 1;
          value1 :=  StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v1,i]));
          meanx2 := meanx2 + value1;
          varx2 := varx2 + (value1 * value1);
          value2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,i]));
          meany2 := meany2 + value2;
          vary2 := vary2 + value2 * value2;
          Cor2 := Cor2 + value1 * value2;
        end;
      end;  // next case
      varx1 := varx1 - meanx1 * meanx1 / ncases1;
      varx1 := varx1 / (ncases1 - 1.0);
      varx2 := varx2 - meanx2 * meanx2 / ncases2;
      varx2 := varx2 / (ncases2 - 1.0);
      vary1 := vary1 - meany1 * meany1 / ncases1;
      vary1 := vary1 / (ncases1 - 1.0);
      vary2 := vary2 - meany2 * meany2 / ncases2;
      vary2 := vary2 / (ncases2 - 1.0);
      Cor1 := Cor1 - meanx1 * meany1 / ncases1;
      Cor1 := Cor1 / (ncases1 - 1.0);
      Cor2 := Cor2 - meanx2 * meany2 / ncases2;
      Cor2 := Cor2 / (ncases2 - 1.0);
      sdx1 := sqrt(varx1);
      sdx2 := sqrt(varx2);
      sdy1 := sqrt(vary1);
      sdy2 := sqrt(vary2);
      Cor1 := Cor1 / (sdx1 * sdy1);
      Cor2 := Cor2 / (sdx2 * sdy2);
      meanx1 := meanx1 / ncases1;
      meany1 := meany1 / ncases1;
      meanx2 := meanx2 / ncases2;
      meany2 := meany2 / ncases2;
      SSize1 := ncases1;
      SSize2 := ncases2;
      CorDif := Cor1 - Cor2;
      zOne := 0.5 * ln((1.0 + Cor1) / (1.0 - Cor1));
      zTwo := 0.5 * ln((1.0 + Cor2) / (1.0 - Cor2));
      zDif := zOne - zTwo;
      StdErr := sqrt((1.0 / (SSize1 - 3.0)) + (1.0 / (SSize2 -3.0)));
      zValue := zDif / StdErr;
      alpha := (1.0 - ConfLevel) / 2.0;
      zTest := inversez(1.0 - alpha);
      zprobability := 1.0 - probz(zValue);
      UCL := zDif + StdErr * zTest;
      LCL := zDif - StdErr * zTest;
      UCL := (exp(2.0 * UCL) - 1.0) / (exp(2.0 * UCL) + 1.0);
      LCL := (exp(2.0 * LCL) - 1.0) / (exp(2.0 * LCL) + 1.0);
    end;

    // read grid data for dependent r's
    if not independent then
    begin
      mean1 := 0.0;
      mean2 := 0.0;
      mean3 := 0.0;
      variance1 := 0.0;
      variance2 := 0.0;
      variance3 := 0.0;
      Corxy := 0.0;
      Corxz := 0.0;
      Coryz := 0.0;
      ncases := 0;
      for i := 1 to NoVariables do
      begin
        cellstring := OS3MainFrm.DataGrid.Cells[i,0];
        if cellstring = Xvar.Text then v1 := i;
        if cellstring = Yvar.Text then v2 := i;
        if cellstring = ZVar.Text then v3 := i;
      end;
      ColNoSelected[0] := v1;
      ColNoSelected[1] := v2;
      ColNoSelected[2] := v3;
      NoSelected := 3;
      for i := 1 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        ncases := ncases + 1;
        value1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v1,i]));
        value2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,i]));
        value3 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v3,i]));
        mean1 := mean1 + value1;
        mean2 := mean2 + value2;
        mean3 := mean3 + value3;
        variance1 := variance1 + value1 * value1;
        variance2 := variance2 + value2 * value2;
        variance3 := variance3 + value3 * value3;
        Corxy := Corxy + value1 * value2;
        Corxz := Corxz + value1 * value3;
        Coryz := Coryz + value2 * value3;
      end;
      variance1 := variance1 - mean1 * mean1 / ncases;
      variance1 := variance1 / (ncases - 1.0);
      stddev1 := sqrt(variance1);
      variance2 := variance2 - mean2 * mean2 / ncases;
      variance2 := variance2 / (ncases - 1.0);
      stddev2 := sqrt(variance2);
      variance3 := variance3 - mean3 * mean3 / ncases;
      variance3 := variance3 / (ncases - 1.0);
      stddev3 := sqrt(variance3);
      Corxy := Corxy - mean1 * mean2 / ncases;
      Corxy := Corxy / (ncases - 1.0);
      Corxy := Corxy / (stddev1 * stddev2);
      Corxz := Corxz - mean1 * mean3 / ncases;
      Corxz := Corxz / (ncases - 1.0);
      Corxz := Corxz / (stddev1 * stddev3);
      Coryz := Coryz - mean2 * mean3 / ncases;
      Coryz := Coryz / (ncases - 1.0);
      Coryz := Coryz / (stddev2 * stddev3);
      mean1 := mean1 / ncases;
      mean2 := mean2 / ncases;
      mean3 := mean3 / ncases;
      SSize := ncases;
      CorDif := Corxy - Corxz;
      alpha := (1.0 - ConfLevel) / 2.0;
      tvalue := CorDif * sqrt((SSize - 3.0) * (1.0 + Coryz)) /
                sqrt(2.0 * (1.0 - Corxy * Corxy - Corxz * Corxz - Coryz * Coryz + 2.0 * Corxy * Corxz * Coryz));
      df1 := 1.0;
      df2 := SSize - 3.0;
      tprobability := probt(tvalue,df2);
      ttest := inverset(1.0 - alpha, df2);
    end;
  end;

  // Initialize output form
  lReport := TStringList.Create;
  try
    lReport.Add('COMPARISON OF TWO CORRELATIONS');
    lReport.Add('');
    if independent then
    begin
      lReport.Add('Correlation one:                 %6.3f', [Cor1]);
      lReport.Add('Sample size one:                 %6d', [SSize1]);
      lReport.Add('Correlation two:                 %6.3f', [Cor2]);
      lReport.Add('Sample size two:                 %6d', [SSize2]);
      lReport.Add('Difference between correlations: %6.3f', [CorDif]);
      lReport.Add('Confidence level selected:       %6s', [CInterval.Text]);
      lReport.Add('z for Correlation One:           %6.3f', [zOne]);
      lReport.Add('z for Correlation Two:           %6.3f', [zTwo]);
      lReport.Add('z difference:                    %6.3f', [zDif]);
      lReport.Add('Standard error of difference:    %6.3f', [StdErr]);
      lReport.Add('z test statistic:                %6.3f', [zValue]);
      lReport.Add('Probability > |z|:               %6.3f', [zprobability]);
      lReport.Add('z Required for significance:     %6.3f', [zTest]);
      lReport.Add('Note: above is a two-tailed test.');
      lReport.Add('Confidence Limits = (%.3f ... %.3f)', [LCL, UCL]);
      lReport.Add('');
      if griddata then
      begin
        lReport.Add('Mean X for group 1:           %9.3f', [meanx1]);
        lReport.Add('Mean X for group 2:           %9.3f', [meanx2]);
        lReport.Add('Std.Dev. X for group 1:       %9.3f', [sdx1]);
        lReport.Add('Std.Dev. X for group 2:       %9.3f', [sdx2]);
        lReport.Add('Mean y for group 1;           %9.3f', [meany1]);
        lReport.Add('Mean Y for group 2:           %9.3f', [meany2]);
        lReport.Add('Std.Dev. Y for group 1:       %9.3f', [sdy1]);
        lReport.Add('Std.Dev. Y for group 2:       %9.3f', [sdy2]);
      end;
    end;

    if not independent then
    begin
      lReport.Add('Correlation x with y:       %6.3f', [Corxy]);
      lReport.Add('Correlation x with z:       %6.3f', [Corxz]);
      lReport.Add('Correlation y with z:       %6.3f', [Coryz]);
      lReport.Add('Sample size:                %6d', [SSize]);
      lReport.Add('Confidence Level Selected:  %6s', [CInterval.Text]);
      lReport.Add('Difference r(x,y) - r(x,z): %6.3f', [CorDif]);
      lReport.Add('t test statistic:           %6.3f', [tvalue]);
      lReport.Add('Probability > |t|:          %6.3f', [tprobability]);
      lReport.Add('t value for significance:   %6.3f', [ttest]);
      lReport.Add('');
      if griddata then
      begin
        lReport.Add('Variable Mean  Variance  Std.Dev.');
        lReport.Add('   X     %9.3f %9.3f %9.3f', [mean1, variance1, stddev1]);
        lReport.Add('   Y     %9.3f %9.3f %9.3f', [mean2, variance2, stddev2]);
        lReport.Add('   Z     %9.3f %9.3f %9.3f', [mean3, variance3, stddev3]);
      end;
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;
    ColNoSelected := nil;
  end;
end;

procedure TTwoCorrsFrm.RadioGroup1Click(Sender: TObject);
var
  index: integer;
begin
  index := RadioGroup1.ItemIndex;
  if index = 0 then
  begin
    griddata := false;
    if independent then
      Notebook1.PageIndex := 0
    else
      Notebook1.PageIndex := 1;
  end else
  begin
    griddata := true;
    Notebook1.PageIndex := 2;
  end;
end;

procedure TTwoCorrsFrm.RadioGroup2Click(Sender: TObject);
var
  index1, index2: integer;
begin
  index1 := RadioGroup1.ItemIndex;
  index2 := RadioGroup2.ItemIndex;

  // form input with independent corrs
  if ((index2 = 0) and (index1 = 0)) then
  begin
    independent := true;
    Notebook1.PageIndex := 0;
  end;

  // grid data for independent corrs
  if ((index2 = 0) and (index1 = 1)) then
  begin
    Notebook1.PageIndex := 2;
    zlabel.Visible := false;
    zvar.Visible := false;
    grouplabel.Visible := true;
    groupvar.Visible := true;
  end;

  // form data for dependent corrs
  if ((index2 = 1) and (index1 = 0)) then
  begin
    Notebook1.PageIndex := 1;
  end;

  // grid data for dependent corrs
  if ((index2 = 1) and (index1 = 1)) then
  begin
    Notebook1.PageIndex := 2;
    independent := false;
    zlabel.Visible := true;
    Zvar.Visible := true;
    GroupLabel.Visible := false;
    GroupVar.Visible := false;
  end;
end;

function TTwoCorrsFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
  x: Double;
begin
  Result := false;
  AControl := nil;
  AMsg := '';
  if Notebook1.PageIndex = 0 then
  begin
    if (rxy1.Text = '') or not TryStrToFloat(rxy1.Text, x) then
    begin
      AControl := rxy1;
      AMsg := 'Invalid input for first correlation';
      exit;
    end;
    if (Size1.Text = '') or not TryStrToInt(Size1.Text, n) or (n <= 0) then
    begin
      AControl := Size1;
      AMsg := 'Invald input for size of sample 1';
      exit;
    end;
    if (rxy2.Text = '') or not TryStrToFloat(rxy2.Text, x) then
    begin
      AControl := rxy2;
      AMsg := 'Invalid input for second correlation';
      exit;
    end;
    if (Size2.Text = '') or not TryStrToInt(Size2.Text, n) or (n <= 0) then
    begin
      AControl := Size2;
      AMsg := 'Invalud input for size of sample 2';
      exit;
    end;
  end else
  if Notebook1.PageIndex = 1 then
  begin
    if (rxy.Text = '') or not TryStrToFloat(rxy.Text, x) then
      AControl := rxy
    else
    if (rxz.Text = '') or not TryStrToFloat(rxz.Text, x) then
      AControl := rxz
    else
    if (ryz.Text = '') or not TryStrToFloat(ryz.Text, x) then
      AControl := ryz
    else
    if (SampSize.Text = '') or not TryStrToInt(SampSize.Text, n) or (n < 0) then
      AControl := SampSize;
    if AControl <> nil then
    begin
      AMsg := 'Invalid input.';
      exit;
    end;
  end else
  if Notebook1.PageIndex = 2 then
  begin
    if XVar.Text = '' then
    begin
      AControl := XVar;
      AMsg := 'X variable not specified.';
      exit;
    end;
    if YVar.Text = '' then
    begin
      AControl := YVar;
      AMsg := 'Y variable not specified.';
      exit;
    end;
    case RadioGroup2.ItemIndex of
      0: if (GroupVar.Text = '') then
         begin
           AControl := GroupVar;
           AMsg := 'Group variable not specified';
           exit;
         end;
      1: if (ZVar.Text = '') then begin
           AControl := ZVar;
           AMsg := 'Z variable not specified.';
           exit;
         end;
    end;
  end;
  Result := true;
end;

initialization
  {$I twocorrsunit.lrs}

end.

