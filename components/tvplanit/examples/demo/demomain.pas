unit demoMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, LCLTranslator, Menus,
  VpBaseDS, VpDayView, VpWeekView, VpTaskList, VpAbout,
  VpContactGrid, VpMonthView, VpResEditDlg, VpContactButtons, VpBufDS, VpNavBar;

type

  { TMainForm }

  TMainForm = class(TForm)
    BtnNewRes: TButton;
    BtnEditRes: TButton;
    BtnDeleteRes: TButton;
    CbLanguages: TComboBox;
    CbGranularity: TComboBox;
    CbTimeFormat: TComboBox;
    CbFirstDayOfWeek: TComboBox;
    CbAllowInplaceEditing: TCheckBox;
    Cb3D: TCheckBox;
    Img: TImage;
    ImageList1: TImageList;
    LblFirstDayOfWeek: TLabel;
    LblTimeFormat: TLabel;
    LblGranularity: TLabel;
    LblLanguage: TLabel;
    LblVisibleDays: TLabel;
    TitleLbl: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MnuSettings: TMenuItem;
    MnuAbout: TMenuItem;
    MnuMaintenance: TMenuItem;
    MnuQuit: TMenuItem;
    MnuResources: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    LeftPanel: TPanel;
    DaySelectorPanel: TPanel;
    HeaderPanel: TPanel;
    Panel6: TPanel;
    RbAllTasks: TRadioButton;
    RbHideCompletedTasks: TRadioButton;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    TabEvents: TTabSheet;
    TabContacts: TTabSheet;
    TabResources: TTabSheet;
    TabSettings: TTabSheet;
    TabTasks: TTabSheet;
    DaysTrackBar: TTrackBar;
    VpBufDSDataStore1: TVpBufDSDataStore;
    VpContactButtonBar1: TVpContactButtonBar;
    VpContactGrid1: TVpContactGrid;
    VpControlLink1: TVpControlLink;
    VpDayView1: TVpDayView;
    VpMonthView1: TVpMonthView;
    VpNavBar1: TVpNavBar;
    VpResourceCombo1: TVpResourceCombo;
    VpResourceEditDialog1: TVpResourceEditDialog;
    VpTaskList1: TVpTaskList;
    VpWeekView1: TVpWeekView;
    procedure BtnDeleteResClick(Sender: TObject);
    procedure BtnNewResClick(Sender: TObject);
    procedure BtnEditResClick(Sender: TObject);
    procedure Cb3DChange(Sender: TObject);
    procedure CbAllowInplaceEditingChange(Sender: TObject);
    procedure CbFirstDayOfWeekChange(Sender: TObject);
    procedure CbGranularityChange(Sender: TObject);
    procedure CbLanguagesChange(Sender: TObject);
    procedure CbTimeFormatChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure MnuQuitClick(Sender: TObject);
    procedure MnuResourcesClick(Sender: TObject);
    procedure MnuSettingsClick(Sender: TObject);
    procedure MnuAboutClick(Sender: TObject);
    procedure RbAllTasksChange(Sender: TObject);
    procedure RbHideCompletedTasksChange(Sender: TObject);
    procedure DaysTrackBarChange(Sender: TObject);
    procedure VpNavBar1ItemClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; Index: Integer);
  private
    { private declarations }
    FLang: String;
    FActiveView: Integer;
    FVisibleDays: Integer;
    procedure PopulateLanguages;
    procedure SetActiveView(AValue: Integer);
    procedure SetLanguage(ALang: String); overload;
    procedure SetLanguage(AIndex: Integer); overload;
    procedure ShowAllEvents;
    procedure ShowContacts;
    procedure ShowEventsPerDay;
    procedure ShowEventsPerMonth;
    procedure ShowEventsPerWeek;
    procedure ShowResources;
    procedure ShowSettings;
    procedure ShowTasks;

    procedure ReadIni;
    procedure WriteIni;
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
 {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
  LResources, LazUTF8, LazFileUtils, StrUtils, Translations, IniFiles, Math,
  VpMisc, VpBase, VpData;

const
  LANGUAGE_DIR = '..\..\languages\';

resourcestring
  RSConfirmDeleteRes = 'Do you really want to delete resource %s?';
  RSEventsOverview = 'Events overview';
  RSEventsPerMonth = 'Events per month';
  RSEventsPerWeek = 'Events per week';
  RSEventsPerDay = 'Events per day';
  RSTasks = 'Tasks';
  RSContacts = 'Contacts';
  RSResources = 'Resources';
  RSSettings = 'Program settings';
  RSSettings_short = 'Settings';
  RSPlanner = 'Planner';
  RSMaintenance = 'Maintenance';
  RS24Hours = '24 hours';
  RS12Hours = '12 hours AM/PM';
  RS5Min = '5 min';
  RS6Min = '6 min';
  RS10Min = '10 min';
  RS15Min = '15 min';
  RS20Min = '20 min';
  RS30Min = '30 min';
  RS60Min = '60 min';
  RSSunday = 'Sunday';
  RSMonday = 'Monday';
  RSTuesday = 'Tuesday';
  RSWednesday = 'Wednesday';
  RSThursday = 'Thursday';
  RSFriday = 'Friday';
  RSSaturday = 'Saturday';

{$IFDEF WINDOWS}
{ This function determines the LCID from the language code.
  Works only for Windows. }
function LangToLCID(ALang: String): Integer;
begin
 case lowercase(ALang) of
   ''     : Result := $0409;    // Default = englisch
   'ar'   : Result := $0401;    // Arabic
   'bg'   : Result := $0403;    // Bulgarian
   'ca'   : Result := $0403;    // Catalan
   'cs'   : Result := $0405;    // Czech
   'de'   : Result := $0407;    // German
   'en'   : Result := $0409;    // English  (US)
   'es'   : Result := $040A;    // Spanisch
   'fi'   : Result := $040B;    // Finnish
   'fr'   : Result := $040C;    // French
   'he'   : Result := $040D;    // Hebrew
   'hu'   : Result := $040E;    // Hungarian
   'it'   : Result := $0410;    // Italian
   'jp'   : Result := $0411;    // Japanese
   'pl'   : Result := $0415;    // Polish
   'pt'   : Result := $0816;    // Portuguese (Portugal)
   'ru'   : Result := $0419;    // Russian
   'tr'   : Result := $041F;    // Turkish
   'zh_cn', 'zh-cn': Result := $0804;    // Chinese (China)
   'zh_tw', 'zh-tw': Result := $0404;    // Chinese (Taiwan)
   // please complete if necessary. Language code and LCIDs can be found at
   // http://www.science.co.il/Language/Locale-codes.asp
   else  raise Exception.CreateFmt('Language "%s" not supported. Please add to GetLCIDFromLangCode.',[ALang]);
 end;
end;
{$ENDIF}

procedure UpdateFormatSettings(ALang: String);
{$IFDEF WINDOWS}
var
  LCID: Integer;
{$ENDIF}
begin
 {$IFDEF WINDOWS}
  // Determine the LCID for the requested language
  LCID := LangToLCID(ALang);

  // Now we update the format settings to the new language
  GetLocaleFormatSettingsUTF8(LCID, DefaultFormatSettings);
 {$ENDIF}
end;

function GetFirstDayOfWeek(ALang: String): TVpDayType;
// Don't know how to determine this from the OS
begin
   Result := dtSunday;
end;


{ TMainForm }

procedure TMainForm.BtnDeleteResClick(Sender: TObject);
var
  res: TVpResource;
begin
  res := VpControlLink1.Datastore.Resource;
  if res = nil then
    exit;

  if MessageDlg(Format(RSConfirmDeleteRes, [res.Description]), mtConfirmation, [mbYes, mbNo], 0) = mrOK then
    VpControlLink1.Datastore.Resources.RemoveResource(res);
end;

// Edits the currently selected resource
procedure TMainForm.BtnEditResClick(Sender: TObject);
begin
  // Open the resource editor dialog, everything is done here.
  VpResourceEditDialog1.Execute;
end;

// Adds a new resource
procedure TMainForm.BtnNewResClick(Sender: TObject);
begin
  VpResourceEditDialog1.AddNewResource;
end;

procedure TMainForm.Cb3DChange(Sender: TObject);
var
  ds: TVpDrawingStyle;
begin
 if Cb3D.Checked then ds := ds3d else ds := dsFlat;
 VpTaskList1.DrawingStyle := ds;
 VpContactGrid1.DrawingStyle := ds;
 VpDayView1.DrawingStyle := ds;
 VpWeekView1.DrawingStyle := ds;
 VpMonthView1.DrawingStyle := ds;
end;

procedure TMainForm.CbAllowInplaceEditingChange(Sender: TObject);
begin
  VpContactGrid1.AllowInplaceEditing := CbAllowInplaceEditing.Checked;
  VpDayView1.AllowInplaceEditing := CbAllowInplaceEditing.Checked;
  VpWeekView1.AllowInplaceEditing := CbAllowInplaceEditing.Checked;
  VpTaskList1.AllowInplaceEditing := CbAllowInplaceEditing.Checked;
end;

procedure TMainForm.CbFirstDayOfWeekChange(Sender: TObject);
begin
  VpWeekView1.WeekStartsOn := TVpDayType(CbFirstDayOfWeek.ItemIndex);
  VpMonthView1.WeekStartsOn := TVpDayType(CbFirstDayOfWeek.ItemIndex);
end;

procedure TMainForm.CbGranularityChange(Sender: TObject);
begin
  VpDayView1.Granularity := TVpGranularity(CbGranularity.ItemIndex);
end;

procedure TMainForm.CbLanguagesChange(Sender: TObject);
begin
  SetLanguage(CbLanguages.ItemIndex);
end;

procedure TMainForm.CbTimeFormatChange(Sender: TObject);
begin
  VpDayView1.TimeFormat := TVpTimeFormat(CbTimeFormat.ItemIndex);
  VpWeekView1.TimeFormat := TVpTimeFormat(CbTimeFormat.ItemIndex);
  VpMonthView1.TimeFormat := TVpTimeFormat(CbTimeFormat.ItemIndex);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if CanClose then
    try
      WriteIni;
    except
    end;
end;

// Load the last resource.
procedure TMainForm.FormCreate(Sender: TObject);
var
  lastRes: TVpResource;
  ds: TVpCustomDataStore;
begin
  PopulateLanguages;
  ReadIni;

  ds := VpControlLink1.Datastore;
  if ds.Resources.Count > 0 then
  begin
    lastRes := ds.Resources.Items[ds.Resources.Count-1];
    ds.ResourceID := lastRes.ResourceID;
  end;
end;

procedure TMainForm.MnuAboutClick(Sender: TObject);
var
  F: TfrmAbout;
begin
  F := TfrmAbout.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure TMainForm.MnuSettingsClick(Sender: TObject);
begin
  ShowSettings;
end;

procedure TMainForm.MnuQuitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.MnuResourcesClick(Sender: TObject);
begin
  ShowResources;
end;

procedure TMainForm.PopulateLanguages;

  function ExtractLanguage(s: String): String;
  var
    p: Integer;
  begin
    s := ChangeFileExt(s, '');
    p := RPos('.', s);
    if p > 0 then
      Result := Copy(s, p+1, Length(s))
    else
      Result := '';
  end;

var
  L: TStrings;
  po: TStringList;
  lang: String;
  i: Integer;
  langdir: String;
begin
  L := TStringList.Create;
  po := TStringList.Create;
  try
    langdir := ExpandFileName(AppendPathDelim(Application.Location) + LANGUAGE_DIR);
    FindAllFiles(L, langdir, '*.po');
    po.Sorted := true;
    po.Duplicates := dupIgnore;
    for i := 0 to L.Count-1 do begin
      lang := ExtractLanguage(L[i]);
      case lang of
        'de': po.Add('de - Deutsch');
        '',
        'en': po.Add('en - English');
        'es': po.Add('es - Español');
        'fr': po.Add('fr - Français');
        'he': po.Add('he - Hebrew');
        'hu': po.Add('hu - magyar');
        'it': po.Add('it - Italian');
        'ru': po.Add('ru - русский');
      end;
    end;

    CbLanguages.Items.Assign(po);
    SetLanguage(GetDefaultLang);

  finally
    po.Free;
    L.Free;
  end;
end;

procedure TMainForm.RbAllTasksChange(Sender: TObject);
begin
  VpTaskList1.DisplayOptions.ShowAll := RbAllTasks.Checked;
end;

procedure TMainForm.RbHideCompletedTasksChange(Sender: TObject);
begin
  VpTaskList1.DisplayOptions.ShowAll := not RbHideCompletedTasks.Checked;
end;

procedure TMainForm.ReadIni;
var
  ini: TCustomIniFile;
  lang: String;
  idx: Integer;
  L,T, W,H: Integer;
  R: TRect;
begin
  ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    WindowState := wsNormal;
    R := Screen.WorkAreaRect;
    L := ini.ReadInteger('Form', 'Left', Left);
    T := ini.ReadInteger('Form', 'Top', Top);
    W := ini.ReadInteger('Form', 'Width', Width);
    H := ini.ReadInteger('Form', 'Height', Height);
    if L < R.Left then L := R.Left;
    if L + W > R.Right then L := R.Right - W;
    if L < R.Left then W := R.Right - R.Left;
    if T < R.Top then T := R.Top;
    if T + H > R.Bottom then T := R.Bottom - H;
    if T < R.Top then H := R.Bottom - R.Top;
    SetBounds(L, T, W, H);

    w := ini.ReadInteger('Form', 'LeftPanel_Width', LeftPanel.Width);
    if w < 200 then w := 200;
    LeftPanel.Width := w;

    h := ini.ReadInteger('Form', 'BottomPanel_Height', VpMonthView1.Height);
    if h < 160 then h := 160;
    VpMonthView1.Height := h;

    lang := ini.ReadString('Settings', 'Language', GetDefaultLang);
    SetLanguage(lang);

    SetActiveView(ini.ReadInteger('Settings', 'ActiveView', 0));
    VpNavBar1.ActiveFolder := FActiveView div 1000;

    CbTimeFormat.ItemIndex := ini.ReadInteger('Settings', 'TimeFormat', ord(VpDayView1.TimeFormat));
    CbTimeFormatChange(nil);

    CbGranularity.ItemIndex := ini.ReadInteger('Settings', 'Granularity', ord(VpDayView1.Granularity));
    CbGranularityChange(nil);

    CbFirstDayOfWeek.ItemIndex := ini.ReadInteger('Settings', 'FirstDayOfWeek', ord(VpWeekView1.WeekStartsOn));
    CbFirstDayOfWeekChange(nil);

    if ini.ReadBool('Settings', 'AllTasks', VpTaskList1.DisplayOptions.ShowAll) then
      RbAllTasks.Checked := true else
      RbHideCompletedTasks.Checked := true;
    RbAllTasksChange(nil);

    FVisibleDays := ini.ReadInteger('Settings', 'VisibleDays', DaysTrackbar.Position);
    if FActiveView = 3 then begin  // DayView
      DaysTrackbar.Position := FVisibleDays;
      DaysTrackbarChange(nil);
    end;

    CbAllowInplaceEditing.Checked := ini.ReadBool('Settings', 'AllowInplaceEditing', CbAllowInplaceEditing.Checked);
    CbAllowInplaceEditingChange(nil);

  finally
    ini.Free;
  end;
end;

procedure TMainForm.WriteIni;
var
  ini: TCustomIniFile;
begin
  ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    if WindowState = wsNormal then begin
      ini.WriteInteger('Form', 'Width', Width);
      ini.WriteInteger('Form', 'Height', Height);
      ini.WriteInteger('Left', 'Left', Left);
      ini.WriteInteger('Form', 'Top', Top);
    end;
    if FActiveView = 0 then begin
      ini.WriteInteger('Form', 'LeftPanel_Width', LeftPanel.Width);
      ini.WriteInteger('Form', 'BottomPanel_Height', VpMonthView1.Height);
    end;

    ini.WriteString('Settings', 'Language', FLang);
    ini.WriteInteger('Settings', 'ActiveView', FActiveView);
    ini.WriteInteger('Settings', 'TimeFormat', ord(VpDayView1.TimeFormat));
    ini.WriteInteger('Settings', 'Granularity', ord(VpDayView1.Granularity));
    ini.WriteInteger('Settings', 'FirstDayOfWeek', ord(VpWeekView1.WeekStartsOn));
    ini.WriteInteger('Settings', 'VisibleDays', FVisibleDays);
    ini.WriteBool('Settings', 'AllTasks', VpTaskList1.DisplayOptions.ShowAll);
    ini.WriteBool('Settings', 'AllowInplaceEditing', CbAllowInplaceEditing.Checked);
  finally
    ini.Free;
  end;
end;

procedure TMainForm.SetLanguage(AIndex: Integer);
var
  p: Integer;
  lang: String;
begin
  p := pos(' - ', CbLanguages.Items[AIndex]);
  if p > 0 then
    lang := Copy(CbLanguages.Items[AIndex], 1, p-1)
  else
    raise Exception.Create('Incorrect structure of language combobox.');
  SetLanguage(lang);
end;

procedure TMainForm.SetLanguage(ALang: String);

  function GetTimeFormat: TVpTimeFormat;
  var
    s: String;
  begin
    s := lowercase(FormatDateTime('hh:nn ampm', 0.25));
    if pos(lowercase(FormatSettings.TimeAMString), s) = Length(s) - Length(FormatSettings.TimeAMString) then
      Result := tf12Hour else
      Result := tf24Hour;
  end;

var
  i: Integer;
  langdir: String;
  found: Boolean;
  tfmt: TVpTimeFormat;
  firstWeekDay: TVpDayType;
  translator: TUpdateTranslator;
  nf: TVpNavFolder;
  w: Integer;
begin
  langdir := ExpandFileName(AppendPathDelim(Application.Location) + LANGUAGE_DIR);

  // Select new language
  if ALang = 'en' then
    FLang := '' else
    FLang := ALang;

  // Translate VisualPlanIt strings.
  if FLang = '' then begin
    TranslateUnitResourceStrings('vpsr', langdir + 'vpsr.po');

    { NOTE: Translation of app strings back to english not working }

    TranslateUnitResourceStrings('demoMain', langDir + 'demo.po');
    TranslateUnitResourceStrings('lclstrconsts', langDir + 'lclstrconsts.po');
    translator := TPOTranslator.Create(langdir + 'demo.po');
    if Assigned(LRSTranslator) then
      LRSTranslator.Free;
    LRSTranslator := translator;
    for i := 0 to Screen.CustomFormCount-1 do
      translator.UpdateTranslation(Screen.CustomForms[i]);
  end else
  begin
    SetDefaultLang(FLang, langdir);
    TranslateUnitResourceStrings('vpsr', langdir + 'vpsr.' + FLang + '.po');
  end;
  VpDayView1.LoadLanguage;
  VpWeekView1.LoadLanguage;
  VpMonthView1.LoadLanguage;

  // Select language in language combobox.
  if ALang = '' then ALang := 'en';
  found := false;
  for i:=0 to CbLanguages.Items.Count-1 do
    if pos(ALang + ' ', CbLanguages.Items[i]) = 1 then begin
      CbLanguages.ItemIndex := i;
      found := true;
      break;
    end;
  if not found then
    CbLanguages.ItemIndex := 0;

  // Update UI strings
  nf := TVpNavFolder(VpNavBar1.FolderCollection.ItemByName('NFPlanner'));
  nf.Caption := RSPlanner;
  nf.ItemByName('NIEvents').Caption := RSEventsOverview;
  nf.ItemByName('NIEventsByMonth').Caption := RSEventsPerMonth;
  nf.ItemByName('NIEventsByWeek').Caption := RSEventsPerWeek;
  nf.ItemByName('NIEventsByDay').Caption := RSEventsPerDay;
  nf.ItemByName('NITasks').Caption := RSTasks;
  nf.ItemByName('NIContacts').Caption := RSContacts;

  nf := TVpNavFolder(VpNavBar1.FolderCollection.ItemByName('NFMaintenance'));
  nf.Caption := RSMaintenance;
  nf.ItemByname('NIResources').Caption := RSResources;
  nf.ItembyName('NISettings').Caption := RSSettings_short;

  CbTimeFormat.Items.Clear;
  CbTimeFormat.Items.Add(RS24hours);
  CbTimeFormat.Items.Add(RS12hours);

  CbGranularity.Items.Clear;
  CbGranularity.Items.Add(RS5Min);
  CbGranularity.Items.Add(RS6Min);
  CbGranularity.Items.Add(RS10Min);
  CbGranularity.Items.Add(RS15Min);
  CbGranularity.Items.Add(RS20Min);
  CbGranularity.Items.Add(RS30Min);
  CbGranularity.Items.Add(RS60Min);

  CbFirstDayOfWeek.Items.Clear;
  CbFirstDayOfWeek.Items.Add(RSSunday);
  CbFirstDayOfWeek.Items.Add(RSMonday);
  CbFirstDayOfWeek.Items.Add(RSTuesday);
  CbFirstDayOfWeek.Items.Add(RSWednesday);
  CbFirstDayOfWeek.Items.Add(RSThursday);
  CbFirstDayOfWeek.Items.Add(RSFriday);
  CbFirstDayOfWeek.Items.Add(RSSaturday);

  DaysTrackbar.Left := GetLabelWidth(LblVisibleDays) + LblVisibleDays.Left + 8;
  LblGranularity.Left := DaysTrackbar.Left + DaysTrackbar.Width + 32;
  CbGranularity.Left := LblGranularity.Left + GetLabelWidth(LblGranularity) + 8;
  w := MaxValue([GetLabelWidth(LblLanguage), GetLabelWidth(LblTimeFormat), GetLabelWidth(LblFirstDayOfWeek)]);
  CbLanguages.Left := 24 + w + 8;
  LblLanguage.Left := CbLanguages.Left - 8 - GetLabelWidth(LblLanguage);
  CbTimeFormat.Left := CbLanguages.Left;
  LblTimeFormat.Left := CbTimeFormat.Left - 8 - GetLabelWidth(LblTimeFormat);
  CbFirstDayOfWeek.Left := CbLanguages.Left;
  LblFirstDayOfWeek.Left := CbFirstDayOfWeek.Left - 8 - GetLabelWidth(LblFirstDayOfWeek);
  CbAllowInplaceEditing.Left := CbLanguages.Left + CbLanguages.Width + 32;
  Cb3D.Left := CbAllowInplaceEditing.Left;
  RbHideCompletedTasks.Left := RbAllTasks.Left + RbAllTasks.Width + 48;

  // Next settings work correctly only for Windows.
 {$IFDEF WINDOWS}
  UpdateFormatSettings(ALang);
  VpDayView1.DateLabelFormat := FormatSettings.LongDateFormat;
  VpWeekView1.DayHeadAttributes.DateFormat := FormatSettings.LongDateFormat;
  VpWeekView1.DateLabelFormat := FormatSettings.LongDateFormat;
  VpMonthView1.DateLabelFormat := 'mmmm yyyy';
  VpTaskList1.DisplayOptions.DueDateFormat := FormatSettings.ShortDateFormat;
  tfmt := GetTimeFormat;
  VpDayView1.TimeFormat := tfmt;
  VpWeekView1.TimeFormat := tfmt;
  VpMonthView1.TimeFormat := tfmt;
  firstWeekDay := GetFirstDayofWeek(ALang);   // not correct at the moment
  VpMonthView1.WeekStartsOn := firstWeekDay;
  VpWeekView1.WeekStartsOn := firstWeekDay;
 {$ENDIF}

  SetActiveView(FActiveView);
  Invalidate;
end;

procedure TMainForm.ShowAllEvents;
begin
  PageControl1.ActivePage := TabEvents;
  VpDayView1.Parent := LeftPanel;
  VpMonthView1.Parent := LeftPanel;
  VpMonthView1.Align := alBottom;
  VpDayview1.Show;
  VpMonthView1.Show;
  Splitter2.Top := 0;
  LeftPanel.Show;
  Splitter3.Show;
  Splitter3.Left := Width;
  VpWeekView1.Show;
  DaySelectorPanel.Hide;
  VpDayView1.NumDays := 1;
  TitleLbl.Caption := RSEventsOverview;
  ImageList1.GetBitmap(0, Img.Picture.Bitmap);
end;

procedure TMainform.ShowEventsPerMonth;
begin
  PageControl1.ActivePage := TabEvents;
  LeftPanel.Hide;
  Splitter3.Hide;
  VpWeekView1.Hide;
  VpMonthView1.Parent := TabEvents;
  VpMonthView1.Align := alClient;
  VpMonthView1.Show;
  DaySelectorPanel.Hide;

  TitleLbl.Caption := RSEventsPerMonth;
  ImageList1.GetBitmap(5, Img.Picture.Bitmap);
end;

procedure TMainForm.ShowEventsPerWeek;
begin
  PageControl1.ActivePage := TabEvents;
  LeftPanel.Hide;
  Splitter3.Hide;
  VpMonthView1.Hide;
  VpDayView1.Hide;
  VpWeekView1.Show;
  DaySelectorPanel.Hide;

  TitleLbl.Caption := RSEventsPerWeek;
  ImageList1.GetBitmap(4, Img.Picture.Bitmap);
end;

procedure TMainform.ShowEventsPerDay;
begin
  PageControl1.ActivePage := TabEvents;
  LeftPanel.Hide;
  Splitter3.Hide;
  VpWeekView1.Hide;
  VpDayView1.Parent := TabEvents;
  VpDayView1.Align := alClient;
  VpDayView1.Show;
  DaySelectorPanel.Parent := TabEvents;
  DaySelectorPanel.Show;
  DaysTrackbar.Position := FVisibleDays;
  VpDayView1.NumDays := DaysTrackBar.Position;

  TitleLbl.Caption := RSEventsPerDay;
  ImageList1.GetBitmap(3, Img.Picture.Bitmap);
end;

procedure TMainForm.ShowTasks;
begin
  Pagecontrol1.ActivePage := TabTasks;
  titleLbl.Caption := RSTasks;
  ImageList1.GetBitmap(1, Img.Picture.Bitmap);
end;

procedure TMainForm.ShowContacts;
begin
  PageControl1.ActivePage := TabContacts;
  TitleLbl.Caption := RSContacts;
  ImageList1.GetBitmap(2, Img.Picture.Bitmap);
end;

procedure TMainForm.ShowResources;
begin
  PageControl1.Activepage := TabResources;
  TitleLbl.Caption := RSResources;
  ImageList1.GetBitmap(7, Img.Picture.Bitmap);
end;

procedure TMainForm.ShowSettings;
begin
  PageControl1.ActivePage := TabSettings;
  TitleLbl.Caption := RSSettings;
  ImageList1.GetBitmap(8, Img.Picture.Bitmap);
end;

procedure TMainForm.DaysTrackBarChange(Sender: TObject);
begin
  if FActiveView = 3 then
    FVisibleDays := DaysTrackbar.Position;
  VpDayView1.NumDays := DaysTrackBar.Position;
end;

procedure TMainForm.VpNavBar1ItemClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; Index: Integer);
begin
 SetActiveView(VpNavBar1.ActiveFolder * 1000 + Index);
end;

procedure TMainForm.SetActiveView(AValue: Integer);
var
  folderIndex, itemIndex: Integer;
begin
  FActiveView := AValue;
  folderIndex := AValue div 1000;
  itemIndex := AValue mod 1000;
  case folderIndex of
   0: case itemIndex of          // All planner items
        0: ShowAllEvents;        // show all
        1: ShowEventsPerMonth;   // Month view only
        2: ShowEventsPerWeek;    // Week view only
        3: ShowEventsPerDay;     // Day view only
        4: ShowTasks;            // Tasks
        5: ShowContacts;         // Contacts
      end;
   1: case itemIndex of
        0: ShowResources;
        1: ShowSettings;
      end;
 end;
end;

end.

