unit TwoPropUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, StdCtrls, ComCtrls, MainUnit, Globals,
  FunctionsLib, OutPutUnit, DataProcs, contexthelpunit;

type

  { TTwoPropFrm }

  TTwoPropFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    HelpBtn: TButton;
    LabelCorner: TLabel;
    Notebook1: TNotebook;
    Page1: TPage;
    Page2: TPage;
    Page3: TPage;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DepFreq00: TEdit;
    DepFreq10: TEdit;
    DepFreq01: TEdit;
    DepFreq11: TEdit;
    CInterval: TEdit;
    Grp: TEdit;
    GrpLabel: TLabel;
    ConfLabel: TLabel;
    Var2: TEdit;
    SecdVarLabel: TLabel;
    Var1: TEdit;
    IndSize2: TEdit;
    IndSize1: TEdit;
    IndFreq2: TEdit;
    IndFreq1: TEdit;
    Samp1Label: TLabel;
    Samp21Label: TLabel;
    Label11: TLabel;
    FirstVarLabel: TLabel;
    Samp2Label: TLabel;
    Samp1SizeLabel: TLabel;
    Samp2SizeLabel: TLabel;
    DepSamp2Label: TLabel;
    DepSamp1Label: TLabel;
    Samp10Label: TLabel;
    Samp11Label: TLabel;
    Samp20Label: TLabel;
    VarList: TListBox;
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
  TwoPropFrm: TTwoPropFrm;

implementation

uses
  Math;

{ TTwoPropFrm }

procedure TTwoPropFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  CInterval.Text := FormatFloat('0.0', DEFAULT_CONFIDENCE_LEVEL_PERCENT);

  RadioGroup1.ItemIndex := 0;
  RadioGroup2.ItemIndex := 0;
  VarList.Clear;
  Var1.Text := '';
  Var2.Text := '';
  independent := true;
  griddata := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  GrpLabel.Visible := true;
  Grp.Visible := true;
  Grp.Text := '';
  Var2.Visible := false;
  SecdVarLabel.Visible := false;
  DepFreq00.Text := '';
  DepFreq01.Text := '';
  DepFreq10.Text := '';
  DepFreq11.Text := '';
  IndFreq1.Text := '';
  IndFreq2.Text := '';
  IndSize1.Text := '';
  IndSize2.Text := '';

  Notebook1.PageIndex := 1;
end;

procedure TTwoPropFrm.VarListClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if not independent then
  begin
    if Var1.Text <> '' then
      Var2.Text := VarList.Items[index]
    else
      Var1.Text := VarList.Items[index];
  end;

  if independent then
  begin
    if Var1.Text <> '' then
      Grp.Text := VarList.Items[index]
    else
      Var1.Text := VarList.Items[index];
  end;
end;

procedure TTwoPropFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TTwoPropFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TTwoPropFrm.ComputeBtnClick(Sender: TObject);
var
  ConfInt, Prop1, Prop2, zstatistic, zprobability: double;
  PropDif, stderr, UCL, LCL, value1, value2, ztest: double;
  P, Q: double;
  i, v1, v2, NoSelected, f1, f2, f3, f4, ncases1, ncases2: integer;
  min, max, group, AB, AC, CD, BD: integer;
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

  // Initialize output form
  stderr := 0.0;
  PropDif := 0.0;
  v2 := 0;
  ztest := 0.0;
  Prop1 := 0.0;
  Prop2 := 0.0;
  NoSelected := 0;
  v1 := 0;
  zstatistic := 0.0;
  zprobability := 0.0;
  UCL := 0.0;
  LCL := 0.0;

  SetLength(ColNoSelected,NoVariables);

  ConfInt := (100.0 - StrToFloat(CInterval.Text)) / 2.0 ;
  ConfInt := (100.0 - ConfInt) / 100.0; // one tail
  ncases1 := 0;
  ncases2 := 0;
  f1 := 0;
  f2 := 0;
  f3 := 0;
  f4 := 0;
  if independent then
    Var2.Text := Grp.Text;

  if griddata then // data read from grid
  begin
    for i := 1 to NoVariables do
    begin
      if Var1.Text = OS3MainFrm.DataGrid.Cells[i,0] then
      begin
        v1 := i;
        ColNoSelected[0] := i;
      end;

      if Var2.Text = OS3MainFrm.DataGrid.Cells[i,0] then
      begin
        v2 := i;
        ColNoSelected[1] := i;
      end;
    end; // next variable

    if not independent then // correlated data
    begin
      for i := 1 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        ncases1 := ncases1 + 1;
        value1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v1,i]));
        value2 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,i]));
        f1 := f1 + round(value1);
        f2 := f2 + round(value2);
      end; // next case
      f3 := ncases1 - f1;
      f4 := ncases1 - f2;
      AB := f1 + f2;
      AC := f1 + f3;
      CD := f3 + f4;
      BD := f2 + f4;
      Prop1 := BD / ncases1;
      Prop2 := AB / ncases1;
      stderr := sqrt((f1 / ncases1 + f4 / ncases1) / ncases1);
      PropDif := Prop1 - Prop2;
      zstatistic := PropDif / stderr;
      ztest := inversez(ConfInt);
      zprobability := 1.0 - probz(abs(zstatistic));
      UCL := PropDif + stderr * ztest;
      LCL := PropDif - stderr * ztest;
    end; // if not independent

    if independent then
    begin
      min := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,1])));
      max := min;
      for i := 2 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,i])));
        if group < min then min := group;
        if group > max then max := group;
      end;

      for i := 1 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        value1 := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v1,i]));
        group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[v2,i])));
        if group = min then
        begin
          f1 := f1 + round(value1);
          ncases1 := ncases1 + 1;
        end else
        begin
          f2 := f2 + round(value1);
          ncases2 := ncases2 + 1;
        end;
      end; // next case

      Prop1 := f1 / ncases1;
      Prop2 := f2 / ncases2;
      PropDif := Prop1 - Prop2;
      P := (f1 + f2) / (ncases1 + ncases2);
      Q := 1.0 - P;
      stderr := sqrt(P * Q * ((1.0 / ncases1) + (1.0 / ncases2)));
      zstatistic := (Prop1 - Prop2) / stderr;
      zprobability := 1.0 - probz(abs(zstatistic));
      ztest := inversez(ConfInt);
      UCL := PropDif + ztest * stderr;
      LCL := PropDif - ztest * stderr;
    end; // end if independent
  end; // if reading grid data

  if not griddata then // data read from form
  begin
    if not independent then // correlated data
    begin
      f1 := round(StrToFloat(DepFreq00.Text));
      f2 := round(StrToFloat(DepFreq10.Text));
      f3 := round(StrToFloat(DepFreq01.Text));
      f4 := round(StrToFloat(DepFreq11.Text));
      ncases1 := f1 + f2 + f3 + f4;
      AB := f1 + f2;
      AC := f1 + f3;
      CD := f3 + f4;
      BD := f2 + f4;
      Prop1 := BD / ncases1;
      Prop2 := AB / ncases1;
      stderr := sqrt((f1 / ncases1 + f4 / ncases1) / ncases1);
      PropDif := Prop1 - Prop2;
      zstatistic := PropDif / stderr;
      ztest := inversez(ConfInt);
      zprobability := 1.0 - probz(abs(zstatistic));
      UCL := PropDif + stderr * ztest;
      LCL := PropDif - stderr * ztest;
    end; // if not independent

    if independent then // independent data
    begin
      f1 := StrToInt(IndFreq1.Text);
      f2 := StrToInt(IndFreq2.Text);
      ncases1 := StrToInt(IndSize1.Text);
      ncases2 := StrToInt(IndSize2.Text);
      Prop1 := f1 / ncases1;
      Prop2 := f2 / ncases2;
      PropDif := Prop1 - Prop2;
      P := (f1 + f2) / (ncases1 + ncases2);
      Q := 1.0 - P;
      stderr := sqrt(P * Q * ((1.0 / ncases1) + (1.0 / ncases2)));
      zstatistic := (Prop1 - Prop2) / stderr;
      zprobability := 1.0 - probz(abs(zstatistic));
      ztest := inversez(ConfInt);
      UCL := PropDif + ztest * stderr;
      LCL := PropDif - ztest * stderr;
    end;
  end;

  // Print the results
  lReport := TStringList.Create;
  try
    lReport.Add('COMPARISON OF TWO PROPORTIONS');
    lReport.Add('');
    if not independent then
    begin
      lReport.Add('Test for Difference Between Two Dependent Proportions');
      lReport.Add('');
      lReport.Add('Entered Values');
      lReport.Add('');
      lReport.Add('Sample               1');
      lReport.Add('                 0      1    sum');
      lReport.Add('           -----------------------');
      lReport.Add('       0  |%5d   %5d   %5d |', [f1, f2, AB]);
      lReport.Add('  2        --------|-------|------');
      lReport.Add('       1  |%5d   %5d   %5d |', [f3, f4, CD]);
      lReport.Add('           --------|-------|------');
      lReport.Add(' sum      | %5d  %5d   %5d |', [AC, BD, ncases1]);
      lReport.Add('');
      lReport.Add('Confidence Level selected: %s', [CInterval.Text]);
      lReport.Add('Proportion 1 = %.3f and Proportion 2 = %.3f with %d cases', [Prop1, Prop2, ncases1]);
      lReport.Add('Difference in proportions:       %9.3f', [PropDif]);
      lReport.Add('Standard Error of Difference:    %9.3f', [stderr]);
      lReport.Add('z test statistic:                %9.3f with probability = %.4f', [zstatistic, zprobability]);
      lReport.Add('z value for confidence interval: %9.3f', [ztest]);
      lReport.Add('Confidence Interval: (%.3f, %.3f)', [LCL, UCL]);
    end;

    if independent then
    begin
      lReport.Add('Test for Difference Between Two Independent Proportions');
      lReport.Add('');
      lReport.Add('Entered Values');
      lReport.Add('');
      lReport.Add('Sample 1: Frequency = %5d for %5d cases.', [f1, ncases1]);
      lReport.Add('Sample 2: Frequency = %5d for %5d cases.', [f2, ncases2]);
      lReport.Add('');
      lReport.Add('Proportion 1:                    %9.3f', [Prop1]);
      lReport.Add('Proportion 2:                    %9.3f', [Prop2]);
      lReport.Add('Difference:                      %9.3f', [PropDif]);
      lReport.Add('Standard Error of Difference:    %9.3f', [stderr]);
      lReport.Add('Confidence Level selected:       %9s', [CInterval.Text]);
      lReport.Add('z test statistic:                %9.3f with probability = %.4f', [zstatistic, zprobability]);
      lReport.Add('z value for confidence interval: %9.3f', [ztest]);
      lReport.Add('Confidence Interval: (%.3f, %.3f)', [LCL, UCL]);
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;
    ColNoSelected := nil;
  end;
end;

procedure TTwoPropFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  RadioGroup2.Constraints.MinWidth := RadioGroup1.Width;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Width := Max(
    RadioGroup2.Left + RadioGroup2.Width + RadioGroup2.BorderSpacing.Right,
    Width - HelpBtn.Left + HelpBtn.BorderSpacing.Left
  );
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TTwoPropFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TTwoPropFrm.RadioGroup1Click(Sender: TObject);
begin
     griddata := RadioGroup1.ItemIndex = 1;
     RadioGroup2Click(nil);
end;

procedure TTwoPropFrm.RadioGroup2Click(Sender: TObject);
begin
     case RadioGroup2.ItemIndex of
       0: begin
            independent := true;
            if griddata then begin
              Notebook1.PageIndex := 0;
              Var2.Visible := false;
              Grp.Visible := true;
              SecdVarLabel.Visible := Var2.Visible;
              GrpLabel.Visible := Grp.Visible;
            end else
              Notebook1.PageIndex := 1;
          end;
       1: begin
            independent := false;
            if griddata then begin
              Notebook1.PageIndex := 0;
              Var2.Visible := true;
              Grp.Visible := false;
              SecdVarLabel.Visible := Var2.Visible;
              GrpLabel.Visible := Grp.Visible;
            end else
              Notebook1.PageIndex := 2;
          end;
     end;
end;

function TTwoPropFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
begin
  Result := false;
  AControl := nil;
  AMsg := '';
  if Notebook1.PageIndex = 0 then
  begin
    if Var1.Text = '' then
    begin
      AControl := Var1;
      AMsg := 'First variable not specified.';
      exit;
    end;
    case RadioGroup2.ItemIndex of
      0: if (Grp.Text = '') then
         begin
           AControl := Grp;
           AMsg := 'Group code not specified';
           exit;
         end;
      1: if (Var2.Text = '') then begin
           AControl := Var2;
           AMsg := 'Second variable not specified.';
           exit;
         end;
    end;
  end else
  if Notebook1.PageIndex = 1 then
  begin
    if (IndFreq1.Text = '') or not TryStrToInt(IndFreq1.Text, n) or (n < 0) then
    begin
      AControl := IndFreq1;
      AMsg := 'Invalid input for Sample 1 frequency';
      exit;
    end;
    if (IndFreq2.Text = '') or not TryStrToInt(IndFreq2.Text, n) or (n < 0) then
    begin
      AControl := IndFreq2;
      AMsg := 'Invalid input for Sample 2 frequency';
      exit;
    end;
    if (IndSize1.Text = '') or not TryStrToInt(IndSize1.Text, n) or (n <= 0) then
    begin
      AControl := IndSize1;
      AMsg := 'Invald input for size of sample 1';
      exit;
    end;
    if (IndSize2.Text = '') or not TryStrToInt(IndSize2.Text, n) or (n <= 0) then
    begin
      AControl := IndSize2;
      AMsg := 'Invalud input for size of sample 2';
      exit;
    end;
  end else
  if Notebook1.PageIndex = 2 then
  begin
    if (DepFreq00.Text = '') or not TryStrToInt(DepFreq00.Text, n) or (n < 0) then
      AControl := DepFreq00
    else
    if (DepFreq01.Text = '') or not TryStrToInt(DepFreq01.Text, n) or (n < 0) then
      AControl := DepFreq01
    else
    if (DepFreq10.Text = '') or not TryStrToInt(DepFreq10.Text, n) or (n < 0) then
      AControl := DepFreq10
    else
    if (DepFreq11.Text = '') or not TryStrToInt(DepFreq11.Text, n) or (n < 0) then
      AControl := DepFreq11;
    if AControl <> nil then
    begin
      AMsg := 'Invalid input.';
      exit;
    end;
  end;
  Result := true;
end;


initialization
  {$I twopropunit.lrs}

end.

