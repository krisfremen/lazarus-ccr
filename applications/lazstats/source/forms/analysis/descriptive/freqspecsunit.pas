unit FreqSpecsUnit; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  ContextHelpUnit;

type

  { TFreqSpecsFrm }

  TFreqSpecsFrm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    HelpBtn: TButton;
    Memo1: TLabel;
    OKBtn: TButton;
    VarName: TEdit;
    Minimum: TEdit;
    Maximum: TEdit;
    Range: TEdit;
    IntSize: TEdit;
    NoInts: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure IntSizeKeyPress(Sender: TObject; var Key: char);
    procedure OKBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    FNoCases: Integer;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
    property NoCases: Integer read FNoCases write FNoCases;
  end; 

var
  FreqSpecsFrm: TFreqSpecsFrm;

implementation

uses
  Math;

{ TFreqSpecsFrm }

procedure TFreqSpecsFrm.IntSizeKeyPress(Sender: TObject; var Key: char);
var
   rangeval : double;
   increment : double;
begin
     if ord(Key) <> 13 then exit;
     rangeval := StrToFloat(Range.Text);
     increment := StrToFloat(IntSize.Text);
     NoInts.Text := FloatToStr(rangeval / increment);
end;

procedure TFreqSpecsFrm.OKBtnClick(Sender: TObject);
var
  msg: String;
  C: TWinControl;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    ModalResult := mrNone;
  end;
end;

function TFreqSpecsFrm.Validate(out AMsg: String;
  out AControl: TWinControl): Boolean;
var
   NoIntervals: Integer;
   f: Double;
begin
  Result := False;
  if IntSize.Text = '' then
  begin
    AControl := IntSize;
    AMsg := 'Interval size is not specified.';
    exit;
  end;
  if not TryStrToFloat(IntSize.Text, f) then
  begin
    AControl := IntSize;
    AMsg := 'No valid number given for interval size.';
    exit;
  end;
  if NoInts.Text = '' then
  begin
    AControl := NoInts;
    AMsg := 'Number of intervals not specified.';
    exit;
  end;
  if not TryStrToInt(NoInts.Text, NoIntervals) then
  begin
    AControl := NoInts;
    AMsg := 'No valid number given for number of intervals.';
    exit;
  end;
  if NoIntervals + 1 > NoCases then begin
    AControl := NoInts;
    AMsg := Format('Number of intervals cannot be greater than the number of cases (%d).', [NoCases]);
    exit;
  end;
  Result := true;
end;

procedure TFreqSpecsFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([OKBtn.Width, CancelBtn.Width, HelpBtn.Width]);
  OKBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  HelpBtn.Constraints.MinWidth := w;
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;
  HelpBtn.BorderSpacing.Left := NoInts.Left;

  FAutoSized := true;
end;

procedure TFreqSpecsFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

initialization
  {$I freqspecsunit.lrs}

end.

