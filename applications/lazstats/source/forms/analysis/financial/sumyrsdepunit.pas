unit SumYrsDepUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Math, ContextHelpUnit;

type

  { TSumYrsDepFrm }

  TSumYrsDepFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    CostEdit: TEdit;
    SalvageEdit: TEdit;
    LifeEdit: TEdit;
    PeriodEdit: TEdit;
    DepreciationEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    function SYDDepreciation(Cost, Salvage: Extended; Life, Period: Integer): Extended;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  SumYrsDepFrm: TSumYrsDepFrm;

implementation

{ TSumYrsDepFrm }

procedure TSumYrsDepFrm.ResetBtnClick(Sender: TObject);
begin
     CostEdit.Text := '';
     SalvageEdit.Text := '';
     LifeEdit.Text := '';
     DepreciationEdit.Text := '';
     PeriodEdit.Text := '';
end;

procedure TSumYrsDepFrm.ComputeBtnClick(Sender: TObject);
VAR
  Cost, Depreciation, Salvage: Extended;
  Life, Period: integer;
  msg: String;
  C: TWinControl;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    ModalResult := mrNone;
    exit;
  end;

  Cost := StrToFloat(CostEdit.Text);
  Salvage := StrToFloat(SalvageEdit.Text);
  Life := StrToInt(LifeEdit.Text);
  Period := StrToInt(PeriodEdit.Text);
  Depreciation := SYDDepreciation(Cost, Salvage, Life, Period);

  DepreciationEdit.Text := FormatFloat('0.00', Depreciation);
end;

procedure TSumYrsDepFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;
  Constraints.MinWidth := Width;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure TSumYrsDepFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TSumYrsDepFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

function TSumYrsDepFrm.SYDDepreciation(Cost, Salvage: Extended; Life, Period: Integer): Extended;
{ SYD = (cost - salvage) * (life - period + 1) / (life*(life + 1)/2) }
{ Note: life*(life+1)/2 = 1+2+3+...+life "sum of years"
				The depreciation factor varies from life/sum_of_years in first period = 1
																			 downto  1/sum_of_years in last period = life.
				Total depreciation over life is cost-salvage.}
var
  X1, X2: Extended;
begin
  Result := 0;
  if (Period < 1) or (Life < Period) or (Cost <= Salvage) then Exit;
  X1 := 2 * (Life - Period + 1);
  X2 := Life * (Life + 1);
  Result := (Cost - Salvage) * X1 / X2
end;

function TSumYrsDepFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
  n: Integer;
begin
  Result := false;

  if (CostEdit.Text = '') then
  begin
    AControl := CostEdit;
    AMsg := 'Initial cost not specified.';
    exit;
  end;
  if not TryStrToFloat(CostEdit.Text, x) then
  begin
    AControl := CostEdit;
    AMsg := 'No valid number for initial cost.';
    exit;
  end;

  if (LifeEdit.Text = '') then
  begin
    AControl := LifeEdit;
    AMsg := 'Life expectancy not specified.';
    exit;
  end;
  if not TryStrToInt(LifeEdit.Text, n) or (n <= 0) then
  begin
    AControl := LifeEdit;
    AMsg := 'Life expectancy can only be a positive number.';
    exit;
  end;

  if (SalvageEdit.Text = '') then
  begin
    AControl := SalvageEdit;
    AMsg := 'Salvage value not specified.';
    exit;
  end;
  if not TryStrToFloat(SalvageEdit.Text, x) then
  begin
    AControl := SalvageEdit;
    AMsg := 'No valid number given for salvage value.';
    exit;
  end;

  if (PeriodEdit.Text = '') then
  begin
    AControl := PeriodEdit;
    AMsg := 'Depreciation period not specified.';
    exit;
  end;
  if not TryStrToInt(PeriodEdit.Text, n) or (n <= 0) then
  begin
    AControl := PeriodEdit;
    AMsg := 'Depreciation period can only be a positive number.';
    exit;
  end;

  Result := true;
end;

initialization
  {$I sumyrsdepunit.lrs}

end.

