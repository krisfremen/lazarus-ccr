unit tfSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ButtonPanel, StdCtrls,
  ExtCtrls, EditBtn, JvTFUtils, JvTFDays;

type
  TGlobalSettings = record
    Hr2400: Boolean;               // 24 hour or 12 hour AM/PM format
    FirstDayOfWeek: TTFDayOfWeek;
    PrimeTimeStart: TTime;
    PrimeTimeEnd: TTime;
    PrimeTimeColor: TColor;
  end;

var
  GlobalSettings: TGlobalSettings = (
    Hr2400: false;
    FirstDayOfWeek: dowSunday;
    PrimeTimeStart: 8 * ONE_HOUR;
    PrimeTimeEnd: 17 * ONE_HOUR;
    PrimeTimeColor: $00C4FFFF;
  );

type
  { TSettingsForm }

  TSettingsForm = class(TForm)
    Bevel1: TBevel;
    ButtonPanel1: TButtonPanel;
    cbTimeFormat: TComboBox;
    cbFirstDayOfWeek: TComboBox;
    clbPrimeTimeColor: TColorButton;
    lblPrimeTimeStart: TLabel;
    lblPrimeTimeEnd: TLabel;
    lblFirstDayOfWeek: TLabel;
    lblTimeFormat: TLabel;
    Panel1: TPanel;
    edPrimeTimeStart: TTimeEdit;
    edPrimeTimeEnd: TTimeEdit;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    FOKPressed: Boolean;
    procedure ControlsToSettings;
    procedure SettingsToControls;

  end;

var
  SettingsForm: TSettingsForm;

implementation

{$R *.lfm}

procedure TSettingsForm.ControlsToSettings;
begin
  GlobalSettings.Hr2400 := cbTimeFormat.ItemIndex = 0;
  GlobalSettings.FirstDayOfWeek := TTFDayOfWeek(cbFirstDayOfWeek.ItemIndex);
  GlobalSettings.PrimeTimeStart := frac(edPrimeTimeStart.Time);
  GlobalSettings.PrimeTimeEnd := frac(edPrimeTimeEnd.Time);
  GlobalSettings.PrimeTimeColor := clbPrimeTimeColor.ButtonColor;
end;

procedure TSettingsForm.SettingsToControls;
begin
  cbTimeFormat.ItemIndex := ord(not GlobalSettings.Hr2400);

  cbFirstDayOfWeek.ItemIndex := ord(GlobalSettings.FirstDayOfWeek);
  edPrimeTimeStart.Time := GlobalSettings.PrimeTimeStart;
  edPrimeTimeEnd.Time := GlobalSettings.PrimeTimeEnd;
  clbPrimeTimeColor.ButtonColor := GlobalSettings.PrimeTimeColor;
end;

procedure TSettingsForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if FOKPressed then
    ControlsToSettings;
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  cbFirstDayOfWeek.Items.BeginUpdate;
  try
    cbFirstDayOfWeek.Clear;
    for i:=1 to 7 do
      cbFirstDayOfWeek.Items.Add(DefaultFormatSettings.LongDayNames[i]);
  finally
    cbFirstDayOfWeek.Items.EndUpdate;
  end;
end;

procedure TSettingsForm.FormShow(Sender: TObject);
begin
  FOKPressed := false;
  SettingsToControls;
end;

procedure TSettingsForm.OKButtonClick(Sender: TObject);
begin
  FOKPressed := true;
end;


end.

