unit OptionsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Clipbrd,
  Globals, ContextHelpUnit;

type

  { TOptionsFrm }

  TOptionsFrm = class(TForm)
    Bevel1: TBevel;
    BrowseBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    SaveBtn: TButton;
    FilePathEdit: TEdit;
    Label1: TLabel;
    FractionTypeGrp: TRadioGroup;
    MissValsGrp: TRadioGroup;
    JustificationGrp: TRadioGroup;
    SelDir: TSelectDirectoryDialog;
    procedure BrowseBtnClick(Sender: TObject);
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
  Math, LazFileUtils;

const
  OPTIONS_FILE = 'options.txt';

procedure LoadOptions;
var
  filename: String;
  pathname: string;
  F: TextFile;
  i: integer;
  approved: integer;
begin
  filename := AppendPathDelim(OpenStatPath) + OPTIONS_FILE;

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

  Close(F);
end;

procedure SaveOptions;
var
  filename: string;
  F: TextFile;
  approved: integer;
begin
  if LoggedOn then
    approved := 1
  else
    approved := 0;

  filename := AppendPathDelim(OpenStatPath) + OPTIONS_FILE;
  AssignFile(F, fileName);
  Rewrite(F);
  WriteLn(F, approved);
  WriteLn(F, ord(Options.FractionType));
  WriteLn(F, ord(Options.DefaultMiss));
  WriteLn(F, ord(Options.DefaultJust));
  WriteLn(F, Options.DefaultPath);
  CloseFile(F);

  DefaultFormatSettings.DecimalSeparator := FractionTypeChars[Options.FractionType];
end;


{ TOptionsFrm }

procedure TOptionsFrm.ControlsToOptions(var AOptions: TOptions);
begin
  AOptions.FractionType := TFractionType(FractionTypeGrp.ItemIndex);
  AOptions.DefaultMiss := TMissingValueCode(MissValsGrp.ItemIndex);
  AOptions.DefaultJust := TJustification(JustificationGrp.ItemIndex);
  if FilePathEdit.Text = '' then
    AOptions.DefaultPath := OpenStatPath
  else
    AOptions.DefaultPath := FilePathEdit.Text;
end;

procedure TOptionsFrm.OptionsToControls(const AOptions: TOptions);
begin
  FractionTypeGrp.ItemIndex := ord(AOptions.FractionType);
  MissValsGrp.ItemIndex := Ord(AOptions.DefaultMiss);
  JustificationGrp.ItemIndex := Ord(AOptions.DefaultJust);
  if AOptions.DefaultPath = '' then
    FilePathEdit.Text := OpenStatPath
  else
    FilePathEdit.Text := AOptions.DefaultPath;
end;

procedure TOptionsFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, BrowseBtn.Width, SaveBtn.Width, CancelBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  BrowseBtn.Constraints.MinWidth := w;
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

procedure TOptionsFrm.BrowseBtnClick(Sender: TObject);
begin
  with SelDir do
  begin
    InitialDir := FilePathEdit.Text;
    if Execute then
      FilePathEdit.text := FileName;
  end;
end;

procedure TOptionsFrm.CancelBtnClick(Sender: TObject);
begin
  Options := FSavedOptions;
end;

initialization
  {$I optionsunit.lrs}

end.
