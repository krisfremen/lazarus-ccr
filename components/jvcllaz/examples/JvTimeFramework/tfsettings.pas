unit tfSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ButtonPanel, StdCtrls,
  ExtCtrls, JvTFDays;

type
  TGlobalSettings = record
    Hr2400: Boolean;
  end;

  { TSettingsForm }

  TSettingsForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    cbTimeFormat: TComboBox;
    lblTimeFormat: TLabel;
    Panel1: TPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    FOKPressed: Boolean;
    procedure ControlsToSettings;
    procedure SettingsToControls;

  end;

var
  SettingsForm: TSettingsForm;

  GlobalSettings: TGlobalSettings = (
    Hr2400: false
  );

implementation

{$R *.lfm}

procedure TSettingsForm.ControlsToSettings;
begin
  GlobalSettings.Hr2400 := cbTimeFormat.ItemIndex = 0;
end;

procedure TSettingsForm.SettingsToControls;
begin
  if GlobalSettings.Hr2400 then
    cbTimeFormat.ItemIndex := 0
  else
    cbTimeFormat.ItemIndex := 1;
end;

procedure TSettingsForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if FOKPressed then
    ControlsToSettings;
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

