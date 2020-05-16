unit DblDeclineUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  ContextHelpUnit;

type

  { TDblDeclineFrm }

  TDblDeclineFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    CostEdit: TEdit;
    LifeEdit: TEdit;
    EndEdit: TEdit;
    PeriodEdit: TEdit;
    DeprecEdit: TEdit;
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
    function DoubleDecliningBalance(Cost, Salvage: Extended; Life, Period: Integer): Extended;
  private
    { private declarations }
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  DblDeclineFrm: TDblDeclineFrm;

implementation

{ TDblDeclineFrm }

uses
  Math;

procedure TDblDeclineFrm.ResetBtnClick(Sender: TObject);
begin
  CostEdit.Text := '';
  LifeEdit.Text := '';
  EndEdit.Text := '';
  PeriodEdit.Text := '';
  DeprecEdit.Text := '';
end;

procedure TDblDeclineFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TDblDeclineFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TDblDeclineFrm.ComputeBtnClick(Sender: TObject);
VAR
  Depreciation, Cost, Salvage: Extended;
  Life, Period: integer;
  msg: String;
  C: TWinControl;
begin
  if not Validate(msg, C) then
  begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    ModalResult := mrNone;
    exit;
  end;

  Cost := StrToFloat(CostEdit.Text);
  Salvage := StrToFloat(EndEdit.Text);
  Life := StrToInt(LifeEdit.Text);
  Period := StrToInt(PeriodEdit.Text);
  Depreciation := DoubleDecliningBalance(Cost, Salvage, Life, Period);

  DeprecEdit.Text := FormatFloat('0.00', Depreciation);
end;

function TDblDeclineFrm.DoubleDecliningBalance(Cost, Salvage: Extended; Life, Period: Integer): Extended;
{ dv := cost * (1 - 2/life)**(period - 1)
  DDB = (2/life) * dv
  if DDB > dv - salvage then DDB := dv - salvage
  if DDB < 0 then DDB := 0
}
var
  DepreciatedVal, Factor: Extended;
begin
  Result := 0;
	if (Period < 1) or (Life < Period) or (Life < 1) or (Cost <= Salvage) then
    Exit;

	{depreciate everything in period 1 if life is only one or two periods}
	if ( Life <= 2 ) then
  begin
		if ( Period = 1 ) then
      DoubleDecliningBalance:=Cost-Salvage
		else
			DoubleDecliningBalance:=0; {all depreciation occurred in first period}
		exit;
  end;
  Factor := 2.0 / Life;

  DepreciatedVal := Cost * IntPower((1.0 - Factor), Period - 1);
	   {DepreciatedVal is Cost-(sum of previous depreciation results)}

  Result := Factor * DepreciatedVal;
	   {Nominal computed depreciation for this period.  The rest of the
			function applies limits to this nominal value. }

	{Only depreciate until total depreciation equals cost-salvage.}
  if Result > DepreciatedVal - Salvage then
    Result := DepreciatedVal - Salvage;

	{No more depreciation after salvage value is reached.  This is mostly a nit.
	 If Result is negative at this point, it's very close to zero.}
  if Result < 0.0 then
    Result := 0.0;
end;

procedure TDblDeclineFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

function TDblDeclineFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
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

  if (EndEdit.Text = '') then
  begin
    AControl := EndEdit;
    AMsg := 'End value not specified.';
    exit;
  end;
  if not TryStrToFloat(EndEdit.Text, x) then
  begin
    AControl := EndEdit;
    AMsg := 'No valid number given for end value.';
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
  {$I dbldeclineunit.lrs}

end.

