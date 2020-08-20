unit OptionsUnit;

{$mode objfpc}{$H+}
{$include ../../LazStats.inc}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Clipbrd, EditBtn,
  Globals, ContextHelpUnit;

type

  { TOptionsFrm }

  TOptionsFrm = class(TForm)
    Bevel1: TBevel;
    CancelBtn: TButton;
    FilePathEdit: TDirectoryEdit;
    LHelpPathEdit: TFileNameEdit;
    HelpBtn: TButton;
    Label2: TLabel;
    SaveBtn: TButton;
    Label1: TLabel;
    FractionTypeGrp: TRadioGroup;
    MissValsGrp: TRadioGroup;
    JustificationGrp: TRadioGroup;
    procedure CancelBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);

  private
    { private declarations }
    FAutoSized: Boolean;
    FSavedOptions: TOptions;
  public
    { public declarations }
    procedure ControlsToOptions(var AOptions: TOptions);
    procedure OptionsToControls(const AOptions: TOptions);
  end; 

var
  OptionsFrm: TOptionsFrm;

procedure LoadOptions;
procedure SaveOptions;


implementation

uses
  Math, FileUtil, LazFileUtils;

const
  OPTIONS_FILE = 'options.txt';

function GetOptionsPath: String;
begin
  Result := GetAppConfigDirUTF8(false, true) + OPTIONS_FILE;
end;

procedure LoadOptions;
var
  filename: String;
  pathname: string;
  F: TextFile;
  i: integer;
  approved: integer;
begin
  filename := GetOptionsPath;
  if not FileExists(fileName) then
    exit;

  AssignFile(F, fileName);
  Reset(F);

  // approved
  ReadLn(F, approved);
  LoggedOn := (approved <> 0);

  // Fraction type
  ReadLn(F, i);
  Options.FractionType := TFractionType(i);
  DefaultFormatSettings.DecimalSeparator := FractionTypeChars[Options.FractionType];

  // Default missing value
  ReadLn(F, i);
  Options.DefaultMiss := TMissingValueCode(i);

  // Default justification
  ReadLn(F, i);
  Options.DefaultJust := TJustification(i);

  // Default path
  ReadLn(F, pathName);
  if (pathname = '') or (not DirectoryExists(pathname)) then
    Options.DefaultPath := GetCurrentDir
  else
    Options.Defaultpath := pathname;

  // LHelp path
  Readln(F, pathName);
  Options.LHelpPath := pathname;

  Close(F);
end;

procedure SaveOptions;
var
  filename: string;
  F: TextFile;
begin
  filename := GetOptionsPath;
  AssignFile(F, fileName);
  Rewrite(F);
  WriteLn(F, ord(LoggedOn));
  WriteLn(F, ord(Options.FractionType));
  WriteLn(F, ord(Options.DefaultMiss));
  WriteLn(F, ord(Options.DefaultJust));
  WriteLn(F, Options.DefaultPath);
  WriteLn(F, Options.LHelpPath);
  CloseFile(F);
end;


{ TOptionsFrm }

procedure TOptionsFrm.ControlsToOptions(var AOptions: TOptions);
begin
  AOptions.FractionType := TFractionType(FractionTypeGrp.ItemIndex);
  AOptions.DefaultMiss := TMissingValueCode(MissValsGrp.ItemIndex);
  AOptions.DefaultJust := TJustification(JustificationGrp.ItemIndex);
  if FilePathEdit.Text = '' then
    AOptions.DefaultPath := GetCurrentDir
  else
    AOptions.DefaultPath := FilePathEdit.Text;
  if LHelpPathEdit.FileName = Application.Location + 'lhelp' + GetExeExt then
    AOptions.LHelpPath := '<default>'
  else
    AOptions.LHelpPath := LHelpPathEdit.FileName;
end;

procedure TOptionsFrm.OptionsToControls(const AOptions: TOptions);
begin
  FractionTypeGrp.ItemIndex := ord(AOptions.FractionType);
  MissValsGrp.ItemIndex := Ord(AOptions.DefaultMiss);
  JustificationGrp.ItemIndex := Ord(AOptions.DefaultJust);
  if AOptions.DefaultPath = '' then
    FilePathEdit.Text := GetCurrentDir
  else
    FilePathEdit.Text := AOptions.DefaultPath;
  if AOptions.LHelpPath = '<default>' then
    LHelpPathEdit.FileName := Application.Location + 'lhelp' + GetExeExt
  else
    LHelpPathEdit.FileName := AOptions.LHelpPath;
end;

procedure TOptionsFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  {$IFDEF USE_EXTERNAL_HELP_VIEWER}
  Label2.Visible := false;
  LHelpPathEdit.Visible := false;
  {$ENDIF}

  w := MaxValue([HelpBtn.Width, SaveBtn.Width, CancelBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  SaveBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;

  FAutoSized := true;
end;

procedure TOptionsFrm.FormShow(Sender: TObject);
begin
  OptionsToControls(Options);
  ControlsToOptions(FSavedOptions);
end;

procedure TOptionsFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TOptionsFrm.SaveBtnClick(Sender: TObject);
begin
  ControlsToOptions(Options);
  SaveOptions;
end;

procedure TOptionsFrm.CancelBtnClick(Sender: TObject);
begin
  Options := FSavedOptions;
end;

initialization
  {$I optionsunit.lrs}

end.

