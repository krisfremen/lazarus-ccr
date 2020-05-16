unit SLDUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  ContextHelpUnit;

type

  { TSLDepFrm }

  TSLDepFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    CostEdit: TEdit;
    SalvageEdit: TEdit;
    PeriodsEdit: TEdit;
    DepreciationEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    function SLNDepreciation(Cost, Salvage: Extended; Life: Integer): Extended;
  private
    { private declarations }
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  SLDepFrm: TSLDepFrm;

implementation

uses
  Math;

{ TSLDepFrm }

procedure TSLDepFrm.ResetBtnClick(Sender: TObject);
begin
     CostEdit.Text := '';
     SalvageEdit.Text := '';
     PeriodsEdit.Text := '';
     DepreciationEdit.Text := '';
end;

procedure TSLDepFrm.FormShow(Sender: TObject);
begin
     ResetBtnClick(self);
end;

procedure TSLDepFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.Createform(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TSLDepFrm.ComputeBtnClick(Sender: TObject);
var
  Cost, Depr, Salvage: Extended;
  Life: integer;
  msg: String;
  C: TWinControl;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    ModalResult := mrNone;
    exit;
  end;

  // Obtain results
  Cost := StrToFloat(CostEdit.Text);
  Salvage := StrToFloat(SalvageEdit.Text);
  Life := StrToInt(PeriodsEdit.Text);
  if Life < 1 then
    MessageDlg('Life is less than 1.', mtError, [mbOK], 0)
  else
  begin
    Depr := SLNDepreciation(Cost, Salvage, Life);
    DepreciationEdit.Text := FormatFloat('0.00', Depr);
  end;
end;

procedure TSLDepFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, HelpBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  HelpBtn.Constraints.MinWidth := w;
end;

{ Spreads depreciation linearly over life. }
function TSLDepFrm.SLNDepreciation(Cost, Salvage: Extended; Life: Integer): Extended;
begin
  Result := (Cost - Salvage) / Life
end;

function TSLDepFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
  n: Integer;
begin
  Result := false;

  if CostEdit.Text = '' then
  begin
    AControl := CostEdit;
    AMsg := 'Initial cost cannot be empty.';
    exit;
  end;
  if not TryStrToFloat(CostEdit.Text, x) then
  begin
    AControl := CostEdit;
    AMsg := 'No valid number given as initial cost.';
    exit;
  end;

  if PeriodsEdit.Text = '' then
  begin
    AControl := PeriodsEdit;
    AMsg := 'Number of periodes cannot be empty.';
    exit;
  end;
  if (not TryStrToInt(PeriodsEdit.Text, n)) or (n <= 0) then
  begin
    AControl := PeriodsEdit;
    AMsg := 'The number of periods must not be zero or negative.';
    exit;
  end;

  if SalvageEdit.Text = '' then
  begin
    AControl := SalvageEdit;
    AMsg := 'Savage value cannot be empty.';
    exit;
  end;
  if not TryStrToFloat(SalvageEdit.Text, x) then
  begin
    AControl := SalvageEdit;
    AMsg := 'No valid number given as salvage value.';
    exit;
  end;

  Result := true;
end;

initialization
  {$I sldunit.lrs}

end.

