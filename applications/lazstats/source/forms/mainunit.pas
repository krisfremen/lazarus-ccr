// File for testing: "GeneChips.laz"
//   Y     --> Dependent
//   Chip  --> Factor 1
//   Probe --> Factor 2 (Factor 3 empty)

{ ToDo:
  - Help system:
     - LHelp reports "no response" a while after LHelp was opened. LazStats is
       not reacting during this time.
     - LHelp window does not close when lazStats is closed.

  - Diagram windows are incomplete in Linux --> Replace by TAChart?
}

unit MainUnit;

{$mode objfpc}{$H+}

{$include ../LazStats.inc}

interface

uses
  LCLType, Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, Menus, ExtCtrls, StdCtrls, Grids,
 {$IFDEF USE_EXTERNAL_HELP_VIEWER}
  {$IFDEF MSWINDOWS}
  HtmlHelp,
  {$ENDIF}
 {$ELSE}
  LazHelpIntf, LazHelpCHM,
 {$ENDIF}
  Globals, DataProcs, DictionaryUnit, MainDM;

type

  { TOS3MainFrm }

  TOS3MainFrm = class(TForm)
    ColEdit: TEdit;
    FilterEdit: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    MenuItem10: TMenuItem;
    MenuItem100: TMenuItem;
    MenuItem101: TMenuItem;
    MenuItem102: TMenuItem;
    MenuItem103: TMenuItem;
    MenuItem104: TMenuItem;
    MenuItem105: TMenuItem;
    MenuItem106: TMenuItem;
    MenuItem107: TMenuItem;
    MenuItem108: TMenuItem;
    MenuItem109: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem110: TMenuItem;
    MenuItem111: TMenuItem;
    MenuItem112: TMenuItem;
    MenuItem113: TMenuItem;
    MenuItem114: TMenuItem;
    MenuItem115: TMenuItem;

    mnuAnalysis: TMenuItem;
    mnuAnalysisSPC: TMenuItem;
    mnuAnalysisSPC_CChart: TMenuItem;
    mnuAnalysisSPC_CUSUM: TMenuItem;
    mnuAnalysisSPC_PChart: TMenuItem;
    mnuAnalysisSPC_Range: TMenuItem;
    mnuAnalysisSPC_SChart: TMenuItem;
    mnuAnalysisSPC_UChart: TMenuItem;
    mnuAnalysisSPC_XBar: TMenuItem;

    mnuEdit: TMenuItem;
    mnuEditCopyCells: TMenuItem;
    mnuEditCopyCol: TMenuItem;
    mnuEditCopyRow: TMenuItem;
    mnuEditCutCells: TMenuItem;
    mnuEditCutCol: TMenuItem;
    mnuEditCutRow: TMenuItem;
    mnuEditDIVIDER1: TMenuItem;
    mnuEditDIVIDER2: TMenuItem;
    mnuEditNewCol: TMenuItem;
    mnuEditNewRow: TMenuItem;
    mnuEditPasteCells: TMenuItem;
    mnuEditPasteCol: TMenuItem;
    mnuEditPasteRow: TMenuItem;

    mnuFileClose: TMenuItem;
    mnuFileExport: TMenuItem;
    mnuFileExportCSV: TMenuItem;
    mnuFileExportSSV: TMenuItem;
    mnuFileExportTab: TMenuItem;
    mnuFileExit: TMenuItem;
    mnuFileImport: TMenuItem;
    mnuFileImportCSV: TMenuItem;
    mnuFileImportSSV: TMenuItem;
    mnuFileImportTAB: TMenuItem;
    mnuFileNew: TMenuItem;
    mnuFileOpen: TMenuItem;
    mnuFileSave: TMenuItem;

    mnuHelpAbout: TMenuItem;
    mnuHelpLicense: TMenuItem;
    mnuHelpShowTOC: TMenuItem;
    mnuHelpUsingGrid: TMenuItem;

    mnuIOptions: TMenuItem;

    mnuSimulations: TMenuItem;
    mnuSimBivarScatterPlot: TMenuItem;
    mnuSimChiSqProb: TMenuItem;
    mnuSimDistPlots: TMenuItem;
    mnuSimFProb: TMenuItem;
    mnuSimGenerateRandomValues: TMenuItem;
    mnuSimGenerateSeqValues: TMenuItem;
    mnuSimHyperGeomProb: TMenuItem;
    mnuSimInverseZ: TMenuItem;
    mnuSimMultiVarDists: TMenuItem;
    mnuSimPowerCurves: TMenuItem;
    mnuSimProbabilities: TMenuItem;
    mnuSimProbBetween: TMenuItem;
    mnuSimProbDIVIDER: TMenuItem;
    mnuSimProbGreaterZ: TMenuItem;
    mnuSimProbLessZ: TMenuItem;
    mnuSimStudentTProb: TMenuItem;
    mnuSimTypeErrorCurves: TMenuItem;

    mnuTools: TMenuItem;
    mnuToolsCalculator: TMenuItem;
    mnuToolsFormatGrid: TMenuItem;
    mnuToolsJPEGViewer: TMenuItem;
    mnuToolsLoadSubFile: TMenuItem;
    mnuToolsOutputForm: TMenuItem;
    mnuToolsPrintGrid: TMenuItem;
    mnuToolsSelectCases: TMenuItem;
    mnuToolsSmooth: TMenuItem;
    mnuToolsSortCases: TMenuItem;
    mnuToolsStrToInt: TMenuItem;
    mnuToolsSwapDecType: TMenuItem;
    mnuToolsSwapRowsCols: TMenuItem;

    mnuVariables: TMenuItem;
    mnuVariablesDefine: TMenuItem;
    mnuVariablesEquationEditor: TMenuItem;
    mnuVariablesPrintDefs: TMenuItem;
    mnuVariablesRecode: TMenuItem;
    mnuVariablesTransform: TMenuItem;

    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem33: TMenuItem;
    GenKappa: TMenuItem;
    MatManMnu: TMenuItem;
    GrdBkMnu: TMenuItem;
    BinA: TMenuItem;
    BartlettTest: TMenuItem;
    Correspondence: TMenuItem;
    KSTest: TMenuItem;
    MedianPolish: TMenuItem;
    ItemBankMenuItem: TMenuItem;
    lifetable: TMenuItem;
    LSMRitem: TMenuItem;
    MenuItem42: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem45: TMenuItem;
    MenuItem46: TMenuItem;
    MenuItem47: TMenuItem;
    MenuItem50: TMenuItem;
    MenuItem51: TMenuItem;
    MenuItem52: TMenuItem;
    SimpChiSqr: TMenuItem;
    SRHItem: TMenuItem;
    OneCaseAnova: TMenuItem;
    Sens: TMenuItem;
    RunsTest: TMenuItem;
    NestedABC: TMenuItem;
    PicView: TMenuItem;
    mnuShowOptions: TMenuItem;
    WghtedKappa: TMenuItem;
    WLSReg: TMenuItem;
    TwoSLSReg: TMenuItem;
    RiditAnalysis: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    MenuItem71: TMenuItem;
    MenuItem72: TMenuItem;
    MenuItem73: TMenuItem;
    MenuItem74: TMenuItem;
    MenuItem75: TMenuItem;
    MenuItem76: TMenuItem;
    MenuItem77: TMenuItem;
    MenuItem78: TMenuItem;
    MenuItem79: TMenuItem;
    MenuItem80: TMenuItem;
    MenuItem81: TMenuItem;
    MenuItem82: TMenuItem;
    MenuItem83: TMenuItem;
    MenuItem84: TMenuItem;
    MenuItem85: TMenuItem;
    MenuItem86: TMenuItem;
    MenuItem87: TMenuItem;
    MenuItem88: TMenuItem;
    MenuItem89: TMenuItem;
    MenuItem90: TMenuItem;
    MenuItem91: TMenuItem;
    MenuItem92: TMenuItem;
    MenuItem93: TMenuItem;
    MenuItem94: TMenuItem;
    MenuItem95: TMenuItem;
    MenuItem96: TMenuItem;
    MenuItem97: TMenuItem;
    MenuItem98: TMenuItem;
    MenuItem99: TMenuItem;
    RowEdit: TEdit;
    FileNameEdit: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    NoVarsEdit: TEdit;
    Label2: TLabel;
    NoCasesEdit: TEdit;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    OneSampTests: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem39: TMenuItem;
    MenuItem40: TMenuItem;

    mnuAnalysisDescr: TMenuItem;
    mnuAnalysisDescr_Breakdown: TMenuItem;
    mnuAnalysisDescr_BoxPlot: TMenuItem;
    mnuAnalysisDescr_BubblePlot: TMenuItem;
    mnuAnalysisDescr_CompareDists: TMenuItem;
    mnuAnalysisDescr_CrossTabs: TMenuItem;
    mnuAnalysisDescr_DataSmooth: TMenuItem;
    mnuAnalysisDescr_DistribStats: TMenuItem;
    mnuAnalysisDescr_Freq: TMenuItem;
    mnuAnalysisDescr_GrpFreq: TMenuItem;
    mnuAnalysisDescr_HomogeneityTest: TMenuItem;
    mnuAnalysisDescr_MultXvsY: TMenuItem;
    mnuAnalysisDescr_Normality: TMenuItem;
    mnuAnalysisDescr_PlotXvsY: TMenuItem;
    mnuAnalysisDescr_ResistanceLine: TMenuItem;
    mnuAnalysisDescr_StemLeaf: TMenuItem;
    mnuAnalysisDescr_ThreeDRotate: TMenuItem;
    mnuAnalysisDescr_XvsMultY: TMenuItem;

    PropDiff: TMenuItem;
    CorrDiff: TMenuItem;
    ttests: TMenuItem;
    Anova: TMenuItem;
    WithinAnova: TMenuItem;
    AxSAnova: TMenuItem;
    ABSAnova: TMenuItem;
    Ancova: TMenuItem;
    GLM: TMenuItem;
    LatinSquares: TMenuItem;
    MenuItem8: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    DataGrid: TStringGrid;

    // Form event handlers
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);

    // Menu "Analysis" / "Descriptive"
    procedure mnuAnalysisDescr_BoxPlotClick(Sender: TObject);
    procedure mnuAnalysisDescr_BreakdownClick(Sender: TObject);
    procedure mnuAnalysisDescr_BubblePlotClick(Sender: TObject);
    procedure mnuAnalysisDescr_CompareDistsClick(Sender: TObject);
    procedure mnuAnalysisDescr_CrossTabsClick(Sender: TObject);
    procedure mnuAnalysisDescr_DataSmoothClick(Sender: TObject);
    procedure mnuAnalysisDescr_DistribStatsClick(Sender: TObject);
    procedure mnuAnalysisDescr_FreqClick(Sender: TObject);
    procedure mnuAnalysisDescr_GrpFreqClick(Sender: TObject);
    procedure mnuAnalysisDescr_HomogeneityTestClick(Sender: TObject);
    procedure mnuAnalysisDescr_MultXvsYClick(Sender: TObject);
    procedure mnuAnalysisDescr_NormalityClick(Sender: TObject);
    procedure mnuAnalysisDescr_PlotXvsYClick(Sender: TObject);
    procedure mnuAnalysisDescr_ResistanceLineClick(Sender: TObject);
    procedure mnuAnalysisDescr_StemLeafClick(Sender: TObject);
    procedure mnuAnalysisDescr_ThreeDRotateClick(Sender: TObject);
    procedure mnuAnalysisDescr_XvsMultYClick(Sender: TObject);

    // Menu 'Analysis" / "Statistical Process Control"
    procedure mnuAnalysisSPC_CChartClick(Sender: TObject);
    procedure mnuAnalysisSPC_CUSUMClick(Sender: TObject);
    procedure mnuAnalysisSPC_PChartClick(Sender: TObject);
    procedure mnuAnalysisSPC_RangeClick(Sender: TObject);
    procedure mnuAnalysisSPC_SChartClick(Sender: TObject);
    procedure mnuAnalysisSPC_UChartClick(Sender: TObject);
    procedure mnuAnalysisSPC_XBarClick(Sender: TObject);

    // Menu "Edit"
    procedure mnuEditCopyCellsClick(Sender: TObject);
    procedure mnuEditCopyColClick(Sender: TObject);
    procedure mnuEditCopyRowClick(Sender: TObject);
    procedure mnuEditCutColClick(Sender: TObject);
    procedure mnuEditCutRowClick(Sender: TObject);
    procedure mnuEditNewColClick(Sender: TObject);
    procedure mnuEditNewRowClick(Sender: TObject);
    procedure mnuEditPasteCellsClick(Sender: TObject);
    procedure mnuEditPasteColClick(Sender: TObject);
    procedure mnuEditPasteRowClick(Sender: TObject);

    // Menu "File"
    procedure mnuFileCloseClick(Sender: TObject);
    procedure mnuFileExitClick(Sender: TObject);
    procedure mnuFileExportCSVClick(Sender: TObject);
    procedure mnuFileExportSSVClick(Sender: TObject);
    procedure mnuFileExportTabClick(Sender: TObject);
    procedure mnuFileImportCSVClick(Sender: TObject);
    procedure mnuFileImportSSVClick(Sender: TObject);
    procedure mnuFileImportTABClick(Sender: TObject);
    procedure mnuFileNewClick(Sender: TObject);
    procedure mnuFileOpenClick(Sender: TObject);
    procedure mnuFileSaveClick(Sender: TObject);

    // Menu "Help"
    procedure mnuHelpAboutClick(Sender: TObject);
    procedure mnuHelpLicenseClick(Sender: TObject);
    procedure mnuHelpShowTOCClick(Sender: TObject);
    procedure mnuHelpUsingGridClick(Sender: TObject);

    // Menu "Options"
    procedure mnuShowOptionsClick(Sender: TObject);

    // Menu "Simulations"
    procedure mnuSimBivarScatterPlotClick(Sender: TObject);
    procedure mnuSimChiSqProbClick(Sender: TObject);
    procedure mnuSimDistPlotsClick(Sender: TObject);
    procedure mnuSimFProbClick(Sender: TObject);
    procedure mnuSimGenerateRandomValuesClick(Sender: TObject);
    procedure mnuSimGenerateSeqValuesClick(Sender: TObject);
    procedure mnuSimHyperGeomProbClick(Sender: TObject);
    procedure mnuSimInverseZClick(Sender: TObject);
    procedure mnuSimMultiVarDistsClick(Sender: TObject);
    procedure mnuSimPowerCurvesClick(Sender: TObject);
    procedure mnuSimProbBetweenClick(Sender: TObject);
    procedure mnuSimProbGreaterZClick(Sender: TObject);
    procedure mnuSimProbLessZClick(Sender: TObject);
    procedure mnuSimStudentTProbClick(Sender: TObject);
    procedure mnuSimTypeErrorCurvesClick(Sender: TObject);

    // Menu "Tools"
    procedure mnuToolsCalculatorClick(Sender: TObject);
    procedure mnuToolsFormatGridClick(Sender: TObject);
    procedure mnuToolsJPEGViewerClick(Sender: TObject);
    procedure mnuToolsOutputFormClick(Sender: TObject);
    procedure mnuToolsPrintGridClick(Sender: TObject);
    procedure mnuToolsSelectCasesClick(Sender: TObject);
    procedure mnuToolsSmoothClick(Sender: TObject);
    procedure mnuToolsSortCasesClick(Sender: TObject);
    procedure mnuToolsStrToIntClick(Sender: TObject);
    procedure mnuToolsSwapDecTypeClick(Sender: TObject);
    procedure mnuToolsSwapRowsColsClick(Sender: TObject);


    // Menu "Variables"
    procedure mnuVariablesDefineClick(Sender: TObject);
    procedure mnuVariablesEquationEditorClick(Sender: TObject);
    procedure mnuVariablesPrintDefsClick(Sender: TObject);
    procedure mnuVariablesRecodeClick(Sender: TObject);
    procedure mnuVariablesTransformClick(Sender: TObject);


    procedure ABSAnovaClick(Sender: TObject);
    procedure AncovaClick(Sender: TObject);
    procedure AnovaClick(Sender: TObject);
//    procedure AvgLinkClusterClick(Sender: TObject);
    procedure AxSAnovaClick(Sender: TObject);
    procedure BartlettTestClick(Sender: TObject);
    procedure BinAClick(Sender: TObject);
    procedure CorrDiffClick(Sender: TObject);
    procedure CorrespondenceClick(Sender: TObject);
    procedure DataGridClick(Sender: TObject);
    procedure DataGridKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure DataGridKeyPress(Sender: TObject; var Key: char);
    procedure DataGridPrepareCanvas(sender: TObject; aCol, {%H-}aRow: Integer; {%H-}aState: TGridDrawState);
    procedure GenKappaClick(Sender: TObject);
    procedure GLMClick(Sender: TObject);
    procedure GrdBkMnuClick(Sender: TObject);
    //procedure HelpContentsClick(Sender: TObject);
    procedure ItemBankMenuItemClick(Sender: TObject);
    procedure KSTestClick(Sender: TObject);
    procedure LatinSquaresClick(Sender: TObject);
    procedure lifetableClick(Sender: TObject);
    procedure LSMRitemClick(Sender: TObject);
    procedure MatManMnuClick(Sender: TObject);
    procedure MedianPolishClick(Sender: TObject);
    procedure MenuItem100Click(Sender: TObject);
    procedure MenuItem101Click(Sender: TObject);
    procedure MenuItem102Click(Sender: TObject);
    procedure MenuItem103Click(Sender: TObject);
    procedure MenuItem104Click(Sender: TObject);
    procedure MenuItem105Click(Sender: TObject);
    procedure MenuItem106Click(Sender: TObject);
    procedure MenuItem107Click(Sender: TObject);
    procedure MenuItem108Click(Sender: TObject);
    procedure MenuItem109Click(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem110Click(Sender: TObject);
    procedure MenuItem111Click(Sender: TObject);
    procedure MenuItem112Click(Sender: TObject);
    procedure MenuItem113Click(Sender: TObject);
    procedure MenuItem114Click(Sender: TObject);
    procedure MenuItem115Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem27Click(Sender: TObject);
    procedure MenuItem29Click(Sender: TObject);
    procedure MenuItem31Click(Sender: TObject);
    procedure MenuItem33Click(Sender: TObject);
    procedure MenuItem71Click(Sender: TObject);
    procedure MenuItem72Click(Sender: TObject);
    procedure MenuItem73Click(Sender: TObject);
    procedure MenuItem74Click(Sender: TObject);
    procedure MenuItem75Click(Sender: TObject);
    procedure MenuItem76Click(Sender: TObject);
    procedure MenuItem77Click(Sender: TObject);
    procedure MenuItem78Click(Sender: TObject);
    procedure MenuItem79Click(Sender: TObject);
    procedure MenuItem80Click(Sender: TObject);
    procedure MenuItem81Click(Sender: TObject);
    procedure MenuItem82Click(Sender: TObject);
    procedure MenuItem83Click(Sender: TObject);
    procedure MenuItem84Click(Sender: TObject);
    procedure MenuItem85Click(Sender: TObject);
    procedure MenuItem86Click(Sender: TObject);
    procedure MenuItem87Click(Sender: TObject);
    procedure MenuItem88Click(Sender: TObject);
    procedure MenuItem89Click(Sender: TObject);
    procedure MenuItem90Click(Sender: TObject);
    procedure MenuItem91Click(Sender: TObject);
    procedure MenuItem92Click(Sender: TObject);
    procedure MenuItem93Click(Sender: TObject);
    procedure MenuItem94Click(Sender: TObject);
    procedure MenuItem95Click(Sender: TObject);
    procedure MenuItem96Click(Sender: TObject);
    procedure MenuItem97Click(Sender: TObject);
    procedure MenuItem98Click(Sender: TObject);
    procedure MenuItem99Click(Sender: TObject);
    procedure NestedABCClick(Sender: TObject);
    procedure OneCaseAnovaClick(Sender: TObject);
    procedure OneSampTestsClick(Sender: TObject);
//    procedure PicViewClick(Sender: TObject);
    procedure PropDiffClick(Sender: TObject);
    procedure RiditAnalysisClick(Sender: TObject);
    procedure RunsTestClick(Sender: TObject);
    procedure SensClick(Sender: TObject);
    procedure SimpChiSqrClick(Sender: TObject);
    procedure SRHItemClick(Sender: TObject);
    procedure TTestsClick(Sender: TObject);
    procedure TwoSLSRegClick(Sender: TObject);
    procedure WghtedKappaClick(Sender: TObject);
    procedure WithinAnovaClick(Sender: TObject);
    procedure WLSRegClick(Sender: TObject);
  private
    { private declarations }
   {$IFDEF USE_EXTERNAL_HELP_VIEWER}
    function HelpHandler(Command: Word; Data: PtrInt; var CallHelp: Boolean): Boolean;
    {$ELSE}
    CHMHelpDatabase: TCHMHelpDatabase;
    LHelpConnector: TLHelpConnector;
    {$ENDIF}
    procedure Init;
  public
    { public declarations }
  end; 

var
  OS3MainFrm: TOS3MainFrm;
  PrevRow : integer;
  PrevCol : integer;

implementation

uses
  Utils, OptionsUnit, OutputUnit, LicenseUnit, TransFrmUnit, DescriptiveUnit,
  FreqUnit, CrossTabUnit, BreakDownUnit, BoxPlotUnit, NormalityUnit, Rot3DUnit,
  PlotXYUnit, BubblePlotUnit, StemLeafUnit, MultXvsYUnit, OneSampUnit,
  TwoCorrsUnit, TwoPropUnit, TtestUnit, BlkAnovaUnit, WithinANOVAUnit,
  AxSAnovaUnit, ABRAnovaUnit, ANCOVAUNIT, LatinSqrsUnit, RMatUnit, PartialsUnit,
  AutoCorUnit, CanonUnit, GLMUnit, StepFwdMRUnit, BlkMRegUnit, BackRegUnit,
  BestRegUnit, SimultRegUnit, CoxRegUnit, LogRegUnit, LinProUnit, DiscrimUnit,
  FactorUnit, HierarchUnit, PathUnit, LogLinScreenUnit, TwoWayLogLinUnit,
  ABCLogLinUnit, TestGenUnit, TestScoreUnit, RaschUnit, SuccIntUnit, GuttmanUnit,
  CompRelUnit, KR21Unit, SpBrUnit, RelChangeUnit, DIFUnit, PolyDIFUnit,
  ChiSqrUnit, SpearmanUnit, MannWhitUUnit, ExactUnit, ConcordanceUnit,
  KWAnovaUnit, WilcoxonUnit, CochranQUnit, SignTestUnit, FriedmanUnit,
  BinomialUnit, KendallTauUnit, KaplanMeierUnit,

  // Statistical process control
  XBarChartUnit, RChartUnit, SChartUnit, CUSUMUnit, CChartUnit,
  PChartUnit, UChartUnit,

  CorSimUnit,
  ErrorCurvesUnit, PCurvesUnit, DistribUnit, GenSeqUnit, GenRndValsUnit,
  MultGenUnit, LoanItUnit, SumYrsDepUnit, SLDUnit, DblDeclineUnit,
  RIDITUnit, TwoSLSUnit, WLSUnit, SortCasesUnit,
  SelectCasesUnit, GridHelpUnit, RecodeUnit, KappaUnit, AvgLinkUnit, kmeansunit,
  SingleLinkUnit, GenKappaUnit, CompareDistUnit, matmanunit, gradebookunit,
  ProbzUnit, ProbSmallerzUnit, TwozProbUnit, InversezUnit, ProbChiSqrUnit,
  TprobUnit, FProbUnit, HyperGeoUnit, BNestAUnit, ABCNestedUnit, BartlettTestUnit,
  DataSmoothUnit, GroupFreqUnit, RunsTestUnit, XvsMultYUnit, SensUnit,
  CorrespondenceUnit, EquationUnit, CalculatorUnit, JPEGUnit, ResistanceLineUnit,
  MedianPolishUnit, OneCaseAnovaUnit, SmoothDataUnit, SRHTestUnit, AboutUnit,
  ItemBankingUnit, ANOVATESTSUnit, SimpleChiSqrUnit, LifeTableUnit, LSMRunit;

const
  HELP_KEYWORD_PREFIX = 'html';

{ TOS3MainFrm }

procedure TOS3MainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  res: TModalResult;
begin
  res := MessageDlg('Do you really want to close LazStats?', mtConfirmation, [mbYes, mbNo], 0);
  CanClose := (res = mrYes);
end;

procedure TOS3MainFrm.FormCreate(Sender: TObject);
var
  helpfn: String;
  {$IFNDEF USE_EXTERNAL_HELP_VIEWER}
  lhelpfn: String;
  {$ENDIF}
begin
  // Reduce ultra-wide width of Inputbox windows
  cInputQueryEditSizePercents := 0;

  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);

  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);

  helpfn := Application.Location + 'LazStats.chm';
  if FileExists(helpfn) then
  begin
    Application.HelpFile := helpfn;
   {$IFDEF USE_EXTERNAL_HELP_VIEWER}
     Application.OnHelp := @HelpHandler;
   {$ELSE}
    lhelpfn := Options.LHelpPath;
    if lhelpfn = '<default>' then
      lhelpfn := Application.Location + 'lhelp' + GetExeExt;
    if FileExists(lhelpfn) then
    begin
      CHMHelpDatabase := TCHMHelpDatabase.Create(self);
      CHMHelpDatabase.KeywordPrefix := HELP_KEYWORD_PREFIX;
      CHMHelpDatabase.AutoRegister := true;
      CHMHelpDatabase.Filename := helpfn;

      LHelpConnector := TLHelpConnector.Create(self);
      LHelpConnector.AutoRegister := true;
      LHelpConnector.LHelpPath := lhelpfn;

      //CreateLCLHelpSystem;
    end else
      MessageDlg('Help viewer LHelp.exe not found.' + LineEnding +
        'Please copy this program to the LazStats directory to access the help system.',
        mtError, [mbOK], 0
      );
   {$ENDIF}
  end
  else
    MessageDlg('LazStats help file not found.', mtError, [mbOK], 0);
end;

procedure TOS3MainFrm.FormDestroy(Sender: TObject);
begin
  SaveOptions;
  TempStream.Free;
  TempVarItm.Free;
end;

procedure TOS3MainFrm.FormShow(Sender: TObject);
begin
  Init;
  if ParamCount > 0 then begin
    OpenOS2File(ParamStr(1), false);
    NoVarsEdit.Text := IntToStr(DataGrid.ColCount-1);
    NoCasesEdit.Text := IntToStr(DataGrid.RowCount-1);
  end;
end;

procedure TOS3MainFrm.MenuItem2Click(Sender: TObject);
begin
  {
  if SChartForm = nil then
    Application.CreateForm(TSChartForm, SChartForm);
  SChartForm.ShowModal;
  }
end;

// Menu "Analysis" > "Financial" > "Double Declining Value"
procedure TOS3MainFrm.MenuItem27Click(Sender: TObject);
begin
  if DblDeclineFrm = nil then
    Application.CreateForm(TDblDeclineFrm, DblDeclineFrm);
  DblDeclineFrm.ShowModal;
end;

// Menu" "Analysis" > "Multivariate" >  "Average Link Clustering"
procedure TOS3MainFrm.MenuItem29Click(Sender: TObject);
begin
  if AvgLinkFrm = nil then
    Application.CreateForm(TAvgLinkFrm, AvgLinkFrm);
  AvgLinkFrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "K Means Clustering"
procedure TOS3MainFrm.MenuItem31Click(Sender: TObject);
begin
  if KMeansFrm = nil then
    Application.CreateForm(TKMeansFrm, KMeansFrm);
  kmeansfrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "Single Link Clustering"
procedure TOS3MainFrm.MenuItem33Click(Sender: TObject);
begin
  if SingleLinkFrm = nil then
    Application.CreateForm(TSingleLinkFrm, SingleLinkFrm);
  SingleLinkFrm.ShowModal;
end;

// Menu "Correlation" > "Product-Moment"
procedure TOS3MainFrm.MenuItem71Click(Sender: TObject);
begin
  if RMatFrm = nil then
    Application.CreateForm(TRMatFrm, RMatFrm);
  RMatFrm.ShowModal;
end;

// Menu "Correlation" > "Partial, Semipartial"
procedure TOS3MainFrm.MenuItem72Click(Sender: TObject);
begin
  if PartialsFrm = nil then
    Application.CreateForm(TPartialsFrm, PartialsFrm);
  PartialsFrm.ShowModal;
end;

procedure TOS3MainFrm.MenuItem73Click(Sender: TObject);
begin
  if AutoCorrFrm = nil then
    Application.CreateForm(TAutoCorrFrm, AutoCorrFrm);
  AutocorrFrm.ShowModal;
end;

procedure TOS3MainFrm.MenuItem74Click(Sender: TObject);
begin
  if CannonFrm = nil then
    Application.CreateForm(TCannonFrm, CannonFrm);
  CannonFrm.ShowModal;
end;

// Menu "Analysis" > "Multiple Regression" > "Forward Stepwise"
procedure TOS3MainFrm.MenuItem75Click(Sender: TObject);
begin
  if StepFwdFrm = nil then
    Application.CreateForm(TStepFwdFrm, StepFwdFrm);
  StepFwdFrm.ShowModal;
end;

// Menu "Analysis" > "Multiple Regression" > "Backward Stepwise"
procedure TOS3MainFrm.MenuItem76Click(Sender: TObject);
begin
  if BackRegFrm = nil then
    Application.CreateForm(TBackRegFrm, BackRegFrm);
  BackRegFrm.ShowModal;
end;

// Menu "Analysis" > "Multiple Regression" > "Simultaneous"
procedure TOS3MainFrm.MenuItem77Click(Sender: TObject);
begin
  if SimultFrm = nil then
    Application.CreateForm(TSimultFrm, SimultFrm);
  SimultFrm.ShowModal;
end;

procedure TOS3MainFrm.MenuItem78Click(Sender: TObject);
begin
  if BlkMregFrm = nil then
    Application.CreateForm(TBlkMregFrm, BlkMregFrm);
  BlkMregFrm.ShowModal;
end;

// Menu "Analysis" > "Multiple Regression" > "Best Combination"
procedure TOS3MainFrm.MenuItem79Click(Sender: TObject);
begin
  if BestRegFrm = nil then
    Application.CreateForm(TBestRegFrm, BestRegFrm);
  BestRegFrm.ShowModal;
end;

// Menu "Analysis" > "Multiple Regression" > "Binary Logistic"
procedure TOS3MainFrm.MenuItem80Click(Sender: TObject);
begin
  if LogRegFrm = nil then
    Application.CreateForm(TLogRegFrm, LogRegFrm);
  LogRegFrm.ShowModal;
end;

// Menu "Analysis" > "Multiple Regression" > "Cox Proportional Hazzards Survival Regression"
procedure TOS3MainFrm.MenuItem81Click(Sender: TObject);
begin
  if CoxRegFrm = nil then
    Application.CreateForm(TCoxRegFrm, CoxRegFrm);
  CoxRegFrm.ShowModal;
end;

// Menu "Analysis" > "Multiple Regression" > "Linear Programming"
procedure TOS3MainFrm.MenuItem82Click(Sender: TObject);
begin
  if LinProFrm = nil then
    Application.CreateForm(TLinProFrm, LinProFrm);
  LinProFrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "MANOVA / Discriminant Function"
procedure TOS3MainFrm.MenuItem83Click(Sender: TObject);
begin
  if DiscrimFrm = nil then
    Application.CreateForm(TDiscrimFrm, DiscrimFrm);
  DiscrimFrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "Hierarchical Analysis"
procedure TOS3MainFrm.MenuItem84Click(Sender: TObject);
begin
  if HierarchFrm = nil then
    Application.CreateForm(THierarchFrm, HierarchFrm);
  HierarchFrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "Path analysis"
procedure TOS3MainFrm.MenuItem85Click(Sender: TObject);
begin
  if PathFrm = nil then
    Application.CreateForm(TPathFrm, PathFrm);
  PathFrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "Factor analysis"
procedure TOS3MainFrm.MenuItem86Click(Sender: TObject);
begin
  if FactorFrm = nil then
    Application.CreateForm(TFactorFrm, FactorFrm);
  FactorFrm.ShowModal;
end;

procedure TOS3MainFrm.MenuItem87Click(Sender: TObject);
begin
  if CannonFrm = nil then
    Application.CreateForm(TCannonFrm, CannonFrm);
  CannonFrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "Generalized Kappa"
procedure TOS3MainFrm.MenuItem88Click(Sender: TObject);
begin
  if GLMFrm = nil then
    Application.CreateForm(TGLMFrm, GLMFrm);
  GLMFrm.ShowModal;
end;

// Menu "Analysis" > "Cross-classification" > "AxB Log Linear"
procedure TOS3MainFrm.MenuItem89Click(Sender: TObject);
begin
  if TwoWayLogLinFrm = nil then
    Application.CreateForm(TTwoWayLogLinFrm, TwoWayLogLinFrm);
  TwoWayLogLinFrm.ShowModal;
end;

// Menu "Analysis" > "Cross-Classification" > "AxBxC Log Linear"
procedure TOS3MainFrm.MenuItem90Click(Sender: TObject);
begin
  if ABCLogLinearFrm = nil then
    Application.CreateForm(TABCLogLinearFrm, ABCLogLinearFrm);
  ABCLogLinearFrm.ShowModal;
end;

// Menu "Analysis" > "Cross-classification" > "Log Linear Screen"
procedure TOS3MainFrm.MenuItem91Click(Sender: TObject);
begin
  if LogLinScreenFrm = nil then
    Application.CreateForm(TLogLinScreenFrm, LogLinScreenFrm);
  LogLinScreenFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Generate Sample Test Data"
procedure TOS3MainFrm.MenuItem92Click(Sender: TObject);
begin
  if TestGenFrm = nil then
    Application.CreateForm(TTestGenFrm, TestGenFrm);
  TestGenFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Classical Test Analysis"
procedure TOS3MainFrm.MenuItem93Click(Sender: TObject);
begin
  if TestScoreFrm = nil then
    Application.CreateForm(TTestScoreFrm, TestScoreFrm);
  TestScoreFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Rasch Test Calibration"
procedure TOS3MainFrm.MenuItem94Click(Sender: TObject);
begin
  if RaschFrm = nil then
    Application.CreateForm(TRaschFrm, RaschFrm);
  RaschFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Successive Interval Scaling"
procedure TOS3MainFrm.MenuItem95Click(Sender: TObject);
begin
  if SuccIntFrm = nil then
    Application.CreateForm(TSuccIntFrm, SuccIntFrm);
  SuccIntFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Guttman Scalogram Analysis
procedure TOS3MainFrm.MenuItem96Click(Sender: TObject);
begin
  if GuttmanFrm = nil then
    Application.CreateForm(TGuttmanFrm, GuttmanFrm);
  GuttmanFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Weighted Composite Reliability"
procedure TOS3MainFrm.MenuItem97Click(Sender: TObject);
begin
  if CompRelFrm = nil then
    Application.CreateForm(TCompRelFrm, CompRelFrm);
  CompRelFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Kuder-Richardson #21 Reliability"
procedure TOS3MainFrm.MenuItem98Click(Sender: TObject);
begin
  if KR21Frm = nil then
    Application.CreateForm(TKR21Frm, KR21Frm);
  KR21Frm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Spearman-Brown Prophecy Reliability"
procedure TOS3MainFrm.MenuItem99Click(Sender: TObject);
begin
  if SpBrFrm = nil then
    Application.CreateForm(TSpBrFrm, SpBrFrm);
  SpBrFrm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "ABC ANOVA with B Nested in A"
procedure TOS3MainFrm.NestedABCClick(Sender: TObject);
begin
  if ABCNestedForm = nil then
    Application.CreateForm(TABCNestedForm, ABCNestedForm);
  ABCNestedForm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "2 or 3 Way ANOVA with One Case Per Cell"
procedure TOS3MainFrm.OneCaseAnovaClick(Sender: TObject);
begin
  if OneCaseAnovaForm = nil then
    Application.CreateForm(TOneCaseAnovaForm, OneCaseAnovaForm);
  OneCaseAnovaForm.ShowModal;
end;

// Menu "Analysis" > "One sample tests"
procedure TOS3MainFrm.OneSampTestsClick(Sender: TObject);
begin
  if OneSampFrm = nil then
    Application.CreateForm(TOneSampFrm, OneSampFrm);
  OneSampFrm.ShowModal;
end;


// Menu "Analysis" > "Comparisons" > "Difference beween Proportions"
procedure TOS3MainFrm.PropDiffClick(Sender: TObject);
begin
  if TwoPropFrm = nil then
    Application.CreateForm(TTwoPropFrm, TwoPropFrm);
  TwoPropFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "RIDIT Analysis"
procedure TOS3MainFrm.RiditAnalysisClick(Sender: TObject);
begin
  if RIDITFrm = nil then
    Application.CreateForm(TRIDITFrm, RIDITFrm);
  RIDITFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Runs Test for Normality"
procedure TOS3MainFrm.RunsTestClick(Sender: TObject);
begin
  if RunsTestForm = nil then
    Application.CreateForm(TRunsTestForm, RunsTestForm);
  RunsTestForm.ShowModal;
end;


// Menu "Analysis" > "Nonparametric" > "Sens's Slope Analysis"
procedure TOS3MainFrm.SensClick(Sender: TObject);
begin
  if SensForm = nil then
    Application.CreateForm(TSensForm, SensForm);
  SensForm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Simple Chi Square for Categories"
procedure TOS3MainFrm.SimpChiSqrClick(Sender: TObject);
begin
  if SimpleChiSqrForm = nil then
    Application.CreateForm(TSimpleChiSqrForm, SimpleChiSqrForm);
  SimpleChiSqrForm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Schreier-Ray-Heart Two-Way ANOVA"
procedure TOS3MainFrm.SRHItemClick(Sender: TObject);
begin
  if SRHTest = nil then
    Application.CreateForm(TSRHTest, SRHTest);
  SRHTest.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "t-tests"
procedure TOS3MainFrm.TTestsClick(Sender: TObject);
begin
  if TTestFrm = nil then
    Application.CreateForm(TTTestFrm, TTestFrm);
  TTestFrm.ShowModal;
end;

// Menu "Analysis" > "Multiple Regression" > "Two Stage Least Squares Regression"
procedure TOS3MainFrm.TwoSLSRegClick(Sender: TObject);
begin
  if TwoSLSFrm = nil then
    Application.CreateForm(TTwoSLSFrm, TwoSLSFrm);
  TwoSLSFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Kappa and Weighted Kappa"
procedure TOS3MainFrm.WghtedKappaClick(Sender: TObject);
begin
  if WeightedKappaFrm = nil then
    Application.CreateForm(TWeightedKappaFrm, WeightedKappaFrm);
   WeightedKappaFrm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "Within Subjects ANOVA"
procedure TOS3MainFrm.WithinAnovaClick(Sender: TObject);
begin
  if WithinANOVAFrm = nil then
    Application.CreateForm(TWithinANOVAFrm, WithinANOVAFrm);
  WithinAnovaFrm.ShowModal;
end;

// Menu "Analysis" > "Multiple Regression" > "Weighted Least Squares Regression"
procedure TOS3MainFrm.WLSRegClick(Sender: TObject);
begin
  if WLSFrm = nil then
    Application.CreateForm(TWLSFrm, WLSFrm);
  WLSFrm.ShowModal;
end;


             {
procedure TOS3MainFrm.FormClick(Sender: TObject);
begin
  with TOptionsFrm.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
  (*
  if OptionsFrm = nil then
    Application.CreateForm(TOptionsFrm, OptionsFrm);
  OptionsFrm.ShowModal;
  *)
end;          }

procedure TOS3MainFrm.DataGridKeyPress(Sender: TObject; var Key: char);
var
   row, col : integer;
begin
     NoVarsEdit.Text := IntToStr(DataGrid.ColCount-1);
     if ord(Key) = 13 then exit;
     col := DataGrid.Col;
     row := DataGrid.Row;
     if StrToInt(NoCasesEdit.Text) < row then
     begin
          NoCasesEdit.Text := IntToStr(row);
          NoCases := row;
     end;
     if DataGrid.Cells[0,row] = '' then
     begin
         NoCases := row;
         DataGrid.Cells[0,row] := 'CASE ' + IntToStr(row);
     end;
     if NoVariables < col then
     begin
          NoVariables := col;
     end;
     if ((PrevCol <> col) or (PrevRow <> row)) then
          if DataGrid.Cells[PrevCol,PrevRow] <> '' then FormatCell(PrevCol,PrevRow);
     PrevCol := col;
     PrevRow := row;
end;

procedure TOS3MainFrm.DataGridPrepareCanvas(sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
var
  ts: TTextStyle;
  justif: String;
begin
  if not (Sender = DataGrid) then
    exit;

  ts := DataGrid.Canvas.TextStyle;
  justif := DictionaryFrm.DictGrid.Cells[7, aCol];
  if justif = '' then justif := 'L';
  case justif[1] of
    'L': ts.Alignment := taLeftJustify;
    'C': ts.Alignment := taCenter;
    'R': ts.Alignment := taRightJustify;
  end;
  DataGrid.Canvas.Textstyle := ts;
end;

procedure TOS3MainFrm.DataGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   x, y, v : integer;

begin
     x := DataGrid.Row;
     y := DataGrid.Col;
     v := ord(Key);

     case v of
     13 : begin // return key
               if y =DataGrid.ColCount - 1 then
               begin
{                   DataGrid.ColCount := DataGrid.ColCount + 1;
                    DataGrid.Col := y + 1;}
               end;
          end;
     40 : begin   // arrow down
               if x =DataGrid.RowCount - 1 then
               begin
                   DataGrid.RowCount := DataGrid.RowCount + 1;
                   DataGrid.Cells[0,x+1] := 'CASE ' + IntToStr(x+1);
                   NoCasesEdit.Text := IntToStr(x+1);
                   NoCases := DataGrid.RowCount - 1;
                   DataGrid.SetFocus;
               end;
          end;
     end;
     RowEdit.Text := IntToStr(DataGrid.RowCount - 1);
     ColEdit.Text := IntToStr(DataGrid.ColCount - 1);
     if ((PrevCol <> y) or (PrevRow <> x)) then
          if DataGrid.Cells[PrevCol,PrevRow] <> '' then FormatCell(PrevCol,PrevRow);
end;

// Menu "Analysis" > "Comparisons" > "1,2 or 3 Way ANOVAs"
procedure TOS3MainFrm.AnovaClick(Sender: TObject);
begin
  if BlksAnovaFrm = nil then
    Application.CreateForm(TBlksAnovaFrm, BlksAnovaFrm);
  BlksAnovaFrm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "A x B x S ANOVA"
procedure TOS3MainFrm.ABSAnovaClick(Sender: TObject);
begin
  if ABRAnovaFrm = nil then
    Application.CreateForm(TABRAnovaFrm, ABRAnovaFrm);
  ABRAnovaFrm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "ANCOVA by Regression"
procedure TOS3MainFrm.AncovaClick(Sender: TObject);
begin
  if ANCOVAfrm = nil then
    Application.CreateForm(TANCOVAfrm, ANCOVAfrm);
  ANCOVAFRM.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "A x S ANOVA"
procedure TOS3MainFrm.AxSAnovaClick(Sender: TObject);
begin
  if AxSAnovaFrm = nil then
    Application.CreateForm(TAxSAnovaFrm, AxSAnovaFrm);
  AxSAnovaFrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "Bartlett Test of Sphericity"
procedure TOS3MainFrm.BartlettTestClick(Sender: TObject);
begin
  if BartlettTestForm = nil then
    Application.CreateForm(TBartlettTestForm, BartlettTestform);
  BartlettTestForm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "B Nested in A ANOVA"
procedure TOS3MainFrm.BinAClick(Sender: TObject);
begin
  if BNestedAForm = nil then
    Application.CreateForm(TBNestedAForm, BNestedAForm);
  BNestedAForm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "Difference Between Correlations"
procedure TOS3MainFrm.CorrDiffClick(Sender: TObject);
begin
  if TwoCorrsFrm = nil then
    Application.CreateForm(TTwoCorrsFrm, TwoCorrsFrm);
  TwoCorrsFrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "Correspondence Analysis"
procedure TOS3MainFrm.CorrespondenceClick(Sender: TObject);
begin
  if CorrespondenceForm = nil then
    Application.CreateForm(TCorrespondenceForm, CorrespondenceForm);
  CorrespondenceForm.ShowModal;
end;

procedure TOS3MainFrm.DataGridClick(Sender: TObject);
begin
  RowEdit.Text := IntToStr(DataGrid.Row);
  ColEdit.Text := IntToStr(DataGrid.Col);
end;


{$IFDEF USE_EXTERNAL_HELP_VIEWER}
// Call HTML help (.chm file)
function TOS3MainFrm.HelpHandler(Command: Word; Data: PtrInt;
  var CallHelp: Boolean): Boolean;
{$IFDEF MSWINDOWS}
var
  s: String;
  ws: UnicodeString;
  res: Integer;
begin
  if Command = HELP_CONTEXT then
  begin
    // see: http://www.helpware.net/download/delphi/hh_doc.txt
    ws := UnicodeString(Application.HelpFile);
    res := htmlhelp.HtmlHelpW(0, PWideChar(ws), HH_HELP_CONTEXT, Data);  // Data is HelpContext here
  end else
  if Command = HELP_COMMAND then
  begin
    s := {%H-}PChar(Data);
    // Data is pointer to HelpKeyword here, but the Windows help viewer does
    // not want the KeywordPrefix required for LHelp.
    if pos(HELP_KEYWORD_PREFIX + '/', s) = 1 then
      Delete(s, 1, Length(HELP_KEYWORD_PREFIX) + 1);
    ws := UnicodeString(Application.HelpFile + '::/' + s);
    res := htmlhelp.HtmlHelpW(0, PWideChar(ws), HH_DISPLAY_TOPIC, 0);
  end;

  // Don't call regular help
  CallHelp := False;

  Result := res <> 0;
end;
{$ELSE}
begin
  Result := false;
end;
{$ENDIF}
{$ENDIF}

procedure TOS3MainFrm.Init;
var
  i: integer;
begin
  NoVariables := 0;  // global variable for no. of variables (columns)
  NoCases := 0;      // global variable for no. of cases (rows)
  TempStream := TMemoryStream.Create; // global variable (simulate clipboard)
  TempVarItm := TMemoryStream.Create; // global var. for dictionary clips
  FilterOn := false; // global variable = true when a filter variable selected
  DictLoaded := false; // global variable = true when a dictionary file read
  RowEdit.Text := '1';
  ColEdit.Text := '1';
  FileNameEdit.Text := 'TempFile.TAB';
  FilterEdit.Text := 'OFF';
  DataGrid.RowCount := 2;
  DataGrid.ColCount := 2;
  DataGrid.Cells[0,0] := 'CASE/VAR.';
  DataGrid.Cells[0,1] := 'CASE ' + IntToStr(1);
  DataGrid.Cells[1,1] := '';
  PrevRow := 1;
  PrevCol := 1;
  NoCasesEdit.Text := '0';
  NoVarsEdit.Text := '0';
  DictionaryFrm.DictGrid.RowCount := DictionaryFrm.DictGrid.FixedRows;
  for i := 1 to 500 do
    VarDefined[i] := false;

  DictionaryFrm.Init;
  {
  DictionaryFrm.Show;
  DictionaryFrm.ReturnBtnClick(self) ;
  DictionaryFrm.Hide;
  }

  NoVarsEdit.Text := IntToStr(DataGrid.ColCount-1);
  NoCasesEdit.Text := IntToStr(DataGrid.RowCount-1);
end;

// Menu "Edit" > "Copy Block of Cells"
procedure TOS3MainFrm.mnuEditCopyCellsClick(Sender: TObject);
begin
  CopyCellBlock;
end;

// Menu "Edit" > "Copy Column"
procedure TOS3MainFrm.mnuEditCopyColClick(Sender: TObject);
begin
  CopyColumn;
end;

// Menu "Edit" > "Copy Row"
procedure TOS3MainFrm.mnuEditCopyRowClick(Sender: TObject);
begin
  CopyRow;
end;

// Menu "Edit" > "Cut column"
procedure TOS3MainFrm.mnuEditCutColClick(Sender: TObject);
begin
  DeleteCol;
end;

// Menu "Edit" > "Cut row"
procedure TOS3MainFrm.mnuEditCutRowClick(Sender: TObject);
begin
  CutRow;
end;

// Menu "Edit" > "Insert new column"
procedure TOS3MainFrm.mnuEditNewColClick(Sender: TObject);
begin
  InsertCol;
end;

// Menu "Edit" > "Insert new row"
procedure TOS3MainFrm.mnuEditNewRowClick(Sender: TObject);
begin
  InsertRow;
end;

// Menu "Edit" > "Paste cell block"
procedure TOS3MainFrm.mnuEditPasteCellsClick(Sender: TObject);
begin
  PasteCellBlock;
end;

// Menu "Edit" > "Paste column"
procedure TOS3MainFrm.mnuEditPasteColClick(Sender: TObject);
begin
  PasteColumn;
end;

// Menu "Edit" > "Paste row"
procedure TOS3MainFrm.mnuEditPasteRowClick(Sender: TObject);
begin
  PasteRow;
end;

// Menu "File" > "Close"
procedure TOS3MainFrm.mnuFileCloseClick(Sender: TObject);
begin
  NoCases := 0;
  NoVariables := 0;
  Init;
  DataGrid.Cells[1, 0] := '';
end;

// Menu "File" > "Exit"
procedure TOS3MainFrm.mnuFileExitClick(Sender: TObject);
begin
  Close;
end;

// Menu "File" > "Export" > "COMMA File"
procedure TOS3MainFrm.mnuFileExportCSVClick(Sender: TObject);
begin
  SaveCommaFile;
end;

// Menu "File" > "Export" > "SPACE File"
procedure TOS3MainFrm.mnuFileExportSSVClick(Sender: TObject);
begin
  SaveSpaceFile;
end;

// Menu "File" > "Export" > "TAB format"
procedure TOS3MainFrm.mnuFileExportTabClick(Sender: TObject);
begin
  SaveTabFile;
end;

// Menu "File" > "Import" > "COMMA File"
procedure TOS3MainFrm.mnuFileImportCSVClick(Sender: TObject);
begin
  OpenCommaFile;
end;

// Menu "File" > "Import" > "SPACE File"
procedure TOS3MainFrm.mnuFileImportSSVClick(Sender: TObject);
begin
  OpenSpaceFile;
end;

// Menu "File" > "Import" > "TAB File"
procedure TOS3MainFrm.mnuFileImportTABClick(Sender: TObject);
begin
  OpenTabFile;
end;

// Menu "File" > "New"
procedure TOS3MainFrm.mnuFileNewClick(Sender: TObject);
begin
  ClearGrid;
end;

// Menu "File" > "Open"
procedure TOS3MainFrm.mnuFileOpenClick(Sender: TObject);
{
var
  i : integer;
  filename : string;
  }
begin
  OpenOS2File;
  SaveOptions;
  (*
  filename := FileNameEdit.Text;
     // move all down 1 and add new one at the top
{     for i := 8 downto 1 do
     begin
          MainMenu1.Items[0].Items[11].Items[i].Caption :=
                    MainMenu1.Items[0].Items[11].Items[i-1].Caption;
          MainMenu1.Items[0].Items[11].Items[i-1].Caption := ' ';
     end;
     MainMenu1.Items[0].Items[11].Items[0].Caption := filename;}
  if OptionsFrm = nil then
    Application.CreateForm(TOptionsFrm, OptionsFrm);
  OptionsFrm.SaveBtnClick(Self);
  *)
end;

// Menu "File" > "Save"
procedure TOS3MainFrm.mnuFileSaveClick(Sender: TObject);
(*
var
  i : integer;
  filename : string;
    *)
begin
  SaveOS2File;
  SaveOptions;
  (*
  filename := FileNameEdit.Text;
     // move all down 1 and add new one at the top
{     for i := 8 downto 1 do
     begin
          MainMenu1.Items[0].Items[11].Items[i].Caption :=
                    MainMenu1.Items[0].Items[11].Items[i-1].Caption;
          MainMenu1.Items[0].Items[11].Items[i-1].Caption := ' ';
     end;
     MainMenu1.Items[0].Items[11].Items[0].Caption := filename;}
  if OptionsFrm = nil then
    Application.CreateForm(TOptionsFrm, OptionsFrm);
  OptionsFrm.SaveBtnClick(Self);
  *)
end;

// Menu "Help" > "About"
procedure TOS3MainFrm.mnuHelpAboutClick(Sender: TObject);
begin
  ShowAboutBox;
end;

// Menu "Help" > "License"
procedure TOS3MainFrm.mnuHelpLicenseClick(Sender: TObject);
begin
  ShowLicense(false);
end;

// Menu "Help" > "Table of contents"
procedure TOS3MainFrm.mnuHelpShowTOCClick(Sender: TObject);
begin
  Application.HelpKeyword('html/TableofContents.htm');
//  Application.HelpContext(mnuHelpShowTOC.HelpContext);
end;

// Menu "Help" > "Using the Grid"
procedure TOS3MainFrm.mnuHelpUsingGridClick(Sender: TObject);
begin
  if GridHelpfrm = nil then
    Application.CreateForm(TGridHelpFrm, GridHelpFrm);
  GridHelpFrm.ShowModal;
end;

// Menu "Options" > "Show options"
procedure TOS3MainFrm.mnuShowOptionsClick(Sender: TObject);
begin
  with TOptionsFrm.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
  {
  if OptionsFrm = nil then
    Application.CreateForm(TOptionsFrm, OptionsFrm);
  OptionsFrm.ShowModal;
  }
end;


// Menu "Simulations" > "Bivariate Scatter Plot"
procedure TOS3MainFrm.mnuSimBivarScatterPlotClick(Sender: TObject);
begin
  if CorSimFrm = nil then
    Application.CreateForm(TCorSimFrm, CorSimFrm);
  CorSimFrm.ShowModal;
end;

// Menu "Simulations" > "Chisquare Probability"
procedure TOS3MainFrm.mnuSimChiSqProbClick(Sender: TObject);
begin
  if ChiSqrProbForm = nil then
    Application.CreateForm(TChiSqrProbForm, ChiSqrProbForm);
  ChiSqrProbForm.ShowModal;
end;

// Menu "Simulations" > "Distribution Plots and Critical Values"
procedure TOS3MainFrm.mnuSimDistPlotsClick(Sender: TObject);
begin
  if DistribFrm = nil then
    Application.CreateForm(TDistribFrm, DistribFrm);
  DistribFrm.Show;
end;

// Menu "Simulations" > "F probability"
procedure TOS3MainFrm.mnuSimFProbClick(Sender: TObject);
begin
  if FForm = nil then
    Application.CreateForm(TFForm, FForm);
  FForm.ShowModal;
end;

// Menu "Simulations" > "Random Theoretical Values"
procedure TOS3MainFrm.mnuSimGenerateRandomValuesClick(Sender: TObject);
begin
  if GenRndValsFrm = nil then
    Application.CreateForm(TGenRndValsFrm, GenRndValsFrm);
  GenRndValsFrm.ShowModal;
end;

// Menu "Simulations" > "Generate Sequential Values"
procedure TOS3MainFrm.mnuSimGenerateSeqValuesClick(Sender: TObject);
begin
  if GenSeqFrm = nil then
    Application.CreateForm(TGenSeqFrm, GenSeqFrm);
  GenSeqFrm.ShowModal;
end;

// Menu "Simulations" > "Hypergeometric probability"
procedure TOS3MainFrm.mnuSimHyperGeomProbClick(Sender: TObject);
begin
  if HyperGeoForm = nil then
    Application.CreateForm(THyperGeoForm, HyperGeoForm);
  HyperGeoForm.ShowModal;
end;

// Menu "Simulations" > "z for a given cum. Probability"
procedure TOS3MainFrm.mnuSimInverseZClick(Sender: TObject);
begin
  if InverseZForm = nil then
    Application.CreateForm(TInverseZForm, InverseZForm);
  InverseZForm.ShowModal;
end;

// Menu "Simulations" > "Multivariate Distribution"
procedure TOS3MainFrm.mnuSimMultiVarDistsClick(Sender: TObject);
begin
  if MultGenFrm = nil then
    Application.CreateForm(TMultGenFrm, MultGenFrm);
  MultGenFrm.ShowModal;
end;

// Menu "Simulations" > "mnuSimPowerCurves Curves for a z test"
procedure TOS3MainFrm.mnuSimPowerCurvesClick(Sender: TObject);
begin
  if PCurvesFrm = nil then
    Application.CreateForm(TPCurvesFrm, PCurvesFrm);
  PCurvesFrm.ShowModal;
end;

// Menu "Simulations" > "Prob between 2 z values"
procedure TOS3MainFrm.mnuSimProbBetweenClick(Sender: TObject);
begin
  if TwoZProbForm = nil then
    Application.CreateForm(TTwoZProbForm, TwoZProbForm);
  TwozProbForm.ShowModal;
end;

// Menu "Simulations" > "Probability > z"
procedure TOS3MainFrm.mnuSimProbGreaterZClick(Sender: TObject);
begin
  if ProbzForm = nil then
    Application.CreateForm(TProbZForm, ProbZForm);
  ProbzForm.ShowModal;
end;

// Menu "Simulations" > "Probability < z"
procedure TOS3MainFrm.mnuSimProbLessZClick(Sender: TObject);
begin
  if ProbSmallerZForm = nil then
    Application.CreateForm(TProbSmallerZForm, ProbSmallerZForm);
  ProbSmallerzForm.ShowModal;
end;

// Menu "Simulations" > "Student t probability"
procedure TOS3MainFrm.mnuSimStudentTProbClick(Sender: TObject);
begin
  if TProbForm = nil then
    Application.CreateForm(TTProbForm, TProbForm);
  TprobForm.ShowModal;
end;

// Menu "Simulations" > "Type 1 and Type 2 Error Curves"
procedure TOS3MainFrm.mnuSimTypeErrorCurvesClick(Sender: TObject);
begin
  if ErrorCurvesFrm = nil then
    Application.CreateForm(TErrorCurvesFrm, ErrorCurvesFrm);
  ErrorCurvesFrm.ShowModal;
end;

// Menu "Tools" > "Calculator"
procedure TOS3MainFrm.mnuToolsCalculatorClick(Sender: TObject);
begin
  if CalculatorForm = nil then
    Application.CreateForm(TCalculatorForm, CalculatorForm);
  CalculatorForm.ShowModal;
end;

// Menu "Tools" > "Format grid"
procedure TOS3MainFrm.mnuToolsFormatGridClick(Sender: TObject);
begin
  DataProcs.FormatGrid;
end;

// Menu "Tools" > "JPEG Image Viewer"
procedure TOS3MainFrm.mnuToolsJPEGViewerClick(Sender: TObject);
begin
  if JPEGForm = nil then
    Application.CreateForm(TJPEGForm, JPEGForm);
  JPEGForm.ShowModal;
end;

// Menu "Tools" > "Show Output Form"
procedure TOS3MainFrm.mnuToolsOutputFormClick(Sender: TObject);
begin
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  OutputFrm.ShowModal;
end;

// Menu "Tools" > "Print grid"
procedure TOS3MainFrm.mnuToolsPrintGridClick(Sender: TObject);
var
  lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
    PrintData(lReport);
  finally
    lReport.Free;
  end;
end;

// Menu "Tools" > "Select cases"
procedure TOS3MainFrm.mnuToolsSelectCasesClick(Sender: TObject);
begin
  if SelectFrm = nil then
    Application.CreateForm(TSelectFrm, SelectFrm);
  SelectFrm.ShowModal;
end;

// Menu "Tools" > "Smooth Data in a Variable"
procedure TOS3MainFrm.mnuToolsSmoothClick(Sender: TObject);
begin
  if SmoothDataForm = nil then
    Application.CreateForm(TSmoothDataForm, SmoothDataForm);
  SmoothDataForm.ShowModal;
end;

// Menu "Tools" > "Sort Cases"
procedure TOS3MainFrm.mnuToolsSortCasesClick(Sender: TObject);
begin
  if SortCasesFrm = nil then
    Application.CreateForm(TSortCasesFrm, SortCasesFrm);
  SortCasesFrm.ShowModal;
end;

// Menu "Tools" > "Convert strings to integer codes"
procedure TOS3MainFrm.mnuToolsStrToIntClick(Sender: TObject);
var
  results, prompt: boolean;
  col: integer;
begin
  col := DataGrid.Col;
  DataGrid.Row := 1;
  prompt := true;
  results := DataProcs.StringsToInt(col,col, prompt);
  DataGrid.Col := col;
  if not results then DeleteCol;
end;

// Menu "Tools" > "Change English to European or vice versa"
procedure TOS3MainFrm.mnuToolsSwapDecTypeClick(Sender: TObject);
var
   i, j, k: integer;
   newDecSep: Char;
   cellStr: String;
begin
  case Options.FractionType of
    ftPoint: newDecSep := ',';  // Current type is English - switch to European
    ftComma: newDecSep := '.';  // Current type is European - switch to English
  end;

  for i := 1 to DataGrid.RowCount-1 do
    for j := 1 to DataGrid.ColCount - 1 do
    begin
      cellstr := DataGrid.Cells[j,i];
      for k := 1 to Length(cellStr) do
        if cellstr[k] = DefaultFormatSettings.DecimalSeparator then
          cellstr[k] := newDecSep;
      DataGrid.Cells[j,i] := cellstr;
    end;
end;

// Menu "Tools" > "Swap Rows and Columns of Grid"
procedure TOS3MainFrm.mnuToolsSwapRowsColsClick(Sender: TObject);
begin
  RowColSwap;
end;

// Menu "Variables" > "Define ..."
procedure TOS3MainFrm.mnuVariablesDefineClick(Sender: TObject);
begin
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
  DictionaryFrm.ShowModal;
end;

// Menu "Variables" > "Equation Editor"
procedure TOS3MainFrm.mnuVariablesEquationEditorClick(Sender: TObject);
begin
  if EquationForm = nil then
    Application.CreateForm(TEquationForm, EquationForm);
  EquationForm.ShowModal;
end;

// Menu "Variables" > "Print Definitions"
procedure TOS3MainFrm.mnuVariablesPrintDefsClick(Sender: TObject);
var
  lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
    PrintDict(lReport);
    DisplayReport(lReport);
  finally
    lReport.Free;
  end;
end;

// Menu "Variables" > "Recode Variables"
procedure TOS3MainFrm.mnuVariablesRecodeClick(Sender: TObject);
begin
  if RecodeFrm = nil then
    Application.CreateForm(TRecodeFrm, RecodeFrm);
  RecodeFrm.ShowModal;
end;

// Menu "Variables" > "Transform Variables"
procedure TOS3MainFrm.mnuVariablesTransformClick(Sender: TObject);
var
  err: string;
begin
  try
    if TransFrm = nil then
      Application.CreateForm(TTransFrm, TransFrm);
    TransFrm.ShowModal;
  except
    err := 'Error in showing transformations';
    ErrorMsg(err);
  end;
end;



// Menu "Analysis" > "Nonparametric" > "Generalized Kappa"
procedure TOS3MainFrm.GenKappaClick(Sender: TObject);
begin
  if GenKappaFrm = nil then
    Application.CreateForm(TGenKappaFrm, GenKappaFrm);
  GenKappaFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "General Linear Model"
procedure TOS3MainFrm.GLMClick(Sender: TObject);
begin
  if GLMFrm = nil then
    Application.CreateForm(TGLMFrm, GLMFrm);
  GLMFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Grade Book"
procedure TOS3MainFrm.GrdBkMnuClick(Sender: TObject);
begin
  if GradeBookFrm = nil then
    Application.CreateForm(TGradeBookFrm, GradeBookFrm);
  GradebookFrm.ShowModal;
end;

(*  replaced by ShowTOC
// Menu "Help" > "General Help"
procedure TOS3MainFrm.HelpContentsClick(Sender: TObject);
begin
  if HelpFrm = nil then
    Application.CreateForm(THelpFrm, HelpFrm);
  HelpFrm.ShowModal;
end;
*)
// Menu "Analysis" > "Measurement Programs" > "Item Banking"
procedure TOS3MainFrm.ItemBankMenuItemClick(Sender: TObject);
begin
  if ItemBankFrm = nil then
    Application.CreateForm(TItemBankFrm, ItembankFrm);
  ItemBankFrm.ShowModal;
end;

procedure TOS3MainFrm.KSTestClick(Sender: TObject);
begin
  if CompareDistFrm = nil then
    Application.CreateForm(TCompareDistFrm, CompareDistFrm);
  CompareDistFrm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "Latin and Greco-Latin Squares"
procedure TOS3MainFrm.LatinSquaresClick(Sender: TObject);
begin
  if LatinSqrsFrm = nil then
    Application.CreateForm(TLatinSqrsFrm, LatinSqrsFrm);
  LatinSqrsFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Life table"
procedure TOS3MainFrm.lifetableClick(Sender: TObject);
begin
  if LifeTableForm = nil then
    Application.CreateForm(TLifeTableForm, LifeTableForm);
  LifeTableForm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Least Squares Multiple Regression"
procedure TOS3MainFrm.LSMRitemClick(Sender: TObject);
begin
  if LSMRegForm = nil then
    Application.CreateForm(TLSMregForm, LSMregForm);
  LSMregForm.ShowModal;
end;

procedure TOS3MainFrm.MatManMnuClick(Sender: TObject);
begin
  if MatManFrm = nil then
    Application.CreateForm(TMatManFrm, MatManFrm);
  MatManFrm.ShowModal;
end;

// Menu "Analysis" > "Multivariate" > "Median Polishing for a 2x2 Table".
procedure TOS3MainFrm.MedianPolishClick(Sender: TObject);
begin
  if MedianPolishForm = nil then
    Application.CreateForm(TMedianPolishForm, MedianPolishForm);
  MedianPolishForm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Reliability Due to Test Variance Change"
procedure TOS3MainFrm.MenuItem100Click(Sender: TObject);
begin
  if RelChangeFrm = nil then
    Application.CreateForm(TRelChangeFrm, RelChangeFrm);
  RelChangeFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Differential Item Functioning"
procedure TOS3MainFrm.MenuItem101Click(Sender: TObject);
begin
  if DIFFrm = nil then
    Application.CreateForm(TDIFFrm, DIFFrm);
  DIFFrm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Polytomous DIF Analysis"
procedure TOS3MainFrm.MenuItem102Click(Sender: TObject);
begin
  if PolyDIFFrm = nil then
    Application.CreateForm(TPolyDIFFrm, PolyDIFFrm);
  PolyDIFFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Contingency Chi Square"
procedure TOS3MainFrm.MenuItem103Click(Sender: TObject);
begin
  if ChiSqrFrm = nil then
    Application.CreateForm(TChiSqrFrm, ChiSqrFrm);
  ChiSqrFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Spearman Rank Correlation"
procedure TOS3MainFrm.MenuItem104Click(Sender: TObject);
begin
  if SpearmanFrm = nil then
    Application.CreateForm(TSpearmanFrm, SpearmanFrm);
  SpearmanFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Mann-Whitney U Test"
procedure TOS3MainFrm.MenuItem105Click(Sender: TObject);
begin
  if MannWhitUFrm = nil then
    Application.CreateForm(TMannWhitUFrm, MannWhitUFrm);
  MannWhitUFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Fisher's Exact Text"
procedure TOS3MainFrm.MenuItem106Click(Sender: TObject);
begin
  if FisherFrm = nil then
    Application.CreateForm(TFisherFrm, FisherFrm);
  FisherFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Kendall's Coefficient of Concordance"
procedure TOS3MainFrm.MenuItem107Click(Sender: TObject);
begin
  if ConcordFrm = nil then
    Application.CreateForm(TConcordFrm, ConcordFrm);
  ConcordFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Kruskal-Wallis One-Way ANOVA"
procedure TOS3MainFrm.MenuItem108Click(Sender: TObject);
begin
  if KWAnovaFrm = nil then
    Application.CreateForm(TKWAnovaFrm, KWAnovaFrm);
  KWAnovaFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Matched Pairs Signed Ranks Test"
procedure TOS3MainFrm.MenuItem109Click(Sender: TObject);
begin
  if WilcoxonFrm = nil then
    Application.CreateForm(TWilcoxonFrm, WilcoxonFrm);
  WilcoxonFrm.ShowModal;
end;

// Menu "Analysis" > "Financial" > "Loan Amortization Schedule"
procedure TOS3MainFrm.MenuItem10Click(Sender: TObject);
begin
  if LoanItFrm = nil then
    Application.CreateForm(TLoanItFrm, LoanItFrm);
  LoanItFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Cochran Q Test"
procedure TOS3MainFrm.MenuItem110Click(Sender: TObject);
begin
  if CochranQFrm = nil then
    Application.CreateForm(TCochranQFrm, CochranQFrm);
  CochranQFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Sign Test"
procedure TOS3MainFrm.MenuItem111Click(Sender: TObject);
begin
  if SignTestFrm = nil then
    Application.CreateForm(TSignTestFrm, SignTestFrm);
  SignTestFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Friedman Two-Way ANOVA"
procedure TOS3MainFrm.MenuItem112Click(Sender: TObject);
begin
  if FriedmanFrm = nil then
    Application.CreateForm(TFriedmanFrm, FriedmanFrm);
  FriedmanFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Probability of a Binomial Event"
procedure TOS3MainFrm.MenuItem113Click(Sender: TObject);
begin
  if BinomialFrm = nil then
    Application.CreateForm(TBinomialFrm, BinomialFrm);
  BinomialFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > Kendall's Tau and Partial Tau"
procedure TOS3MainFrm.MenuItem114Click(Sender: TObject);
begin
  if KendallTauFrm = nil then
    Application.CreateForm(TKendallTauFrm, KendallTauFrm);
  KendallTauFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Kaplan-Meier Survival Analysis"
procedure TOS3MainFrm.MenuItem115Click(Sender: TObject);
begin
  if KaplanMeierFrm = nil then
    Application.CreateForm(TKaplanMeierFrm, KaplanMeierFrm);
  KaplanMeierFrm.ShowModal;
end;


{ Descriptive statistics commands }

// Menu "Analysis" > "Descriptive" > "Box Plot"
procedure TOS3MainFrm.mnuAnalysisDescr_BoxPlotClick(Sender: TObject);
begin
  if BoxPlotFrm = nil then
  begin
    Application.CreateForm(TBoxPlotFrm, BoxPlotFrm);
    BoxPlotFrm.Position := poMainFormCenter;
  end;
  BoxPlotFrm.Show;
end;

// Menu "Analysis" > "Descriptive" > "mnuAnalysisDescr_Breakdown"
procedure TOS3MainFrm.mnuAnalysisDescr_BreakdownClick(Sender: TObject);
begin
  if BreakDownFrm = nil then
    Application.CreateForm(TBreakDownFrm, BreakDownFrm);
  BreakDownFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Repeated Measures Bubble Plot"
procedure TOS3MainFrm.mnuAnalysisDescr_BubblePlotClick(Sender: TObject);
begin
  if BubbleForm = nil then
    Application.CreateForm(TBubbleForm, BubbleForm);
  BubbleForm.Show;
end;

// Menu "Analysis" > "Descriptive" > "Compare mnuAnalysisDescr_DistribStats"
procedure TOS3MainFrm.mnuAnalysisDescr_CompareDistsClick(Sender: TObject);
begin
  if CompareDistFrm = nil then
    Application.CreateForm(TCompareDistFrm, CompareDistFrm);
  CompareDistFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Cross tabulation"
procedure TOS3MainFrm.mnuAnalysisDescr_CrossTabsClick(Sender: TObject);
begin
  if CrossTabFrm = nil then
    Application.CreateForm(TCrossTabFrm, CrossTabFrm);
  CrossTabFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Data Smoothing"
procedure TOS3MainFrm.mnuAnalysisDescr_DataSmoothClick(Sender: TObject);
begin
  if DataSmoothingForm = nil then
    Application.CreateForm(TDataSmoothingForm, DataSmoothingForm);
  DataSmoothingForm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Distribution Statistics"
procedure TOS3MainFrm.mnuAnalysisDescr_DistribStatsClick(Sender: TObject);
begin
  if DescriptiveFrm = nil then
    Application.CreateForm(TDescriptiveFrm, DescriptiveFrm);
  DescriptiveFrm.Show;
end;

// Menu "Analysis" > "Descriptive" > "Frequency Analysis"
procedure TOS3MainFrm.mnuAnalysisDescr_FreqClick(Sender: TObject);
begin
  if FreqFrm = nil then
    Application.CreateForm(TFreqFrm, FreqFrm);
  FreqFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Plot Group Frequencies"
procedure TOS3MainFrm.mnuAnalysisDescr_GrpFreqClick(Sender: TObject);
begin
  if GroupFreqForm = nil then
    Application.CreateForm(TGroupFreqForm, GroupFreqForm);
  GroupFreqForm.ShowModal;
end;

// Menu "Analyses" > "Brown-Forsythe test for homogeneity of variance"
procedure TOS3MainFrm.mnuAnalysisDescr_HomogeneityTestClick(Sender: TObject);
Var
  response: string;
  GroupCol, VarCol, NoCases: integer;
begin
  response := '1';
  repeat
    if not InputQuery('Column of group codes', 'Column index', response) then
      exit;
    if TryStrToInt(response, GroupCol) and (GroupCol > 0) then
      break
    else
      ErrorMsg('Illegal value entered for index of group column.');
  until false;

  response := '2';
  repeat
    if not InputQuery('Column of dependent variable', 'Column index', response) then
      exit;
    if TryStrToInt(response, VarCol) then
      break
    else
      ErrorMsg('Illegal value entered for index of variable column.');
  until false;

  NoCases := StrToInt(NoCasesEdit.text);
  HomogeneityTest(GroupCol, VarCol, NoCases);
end;

//Menu "Analysis" > "Descriptive" > "Multiple Group X vs Y Plot"
procedure TOS3MainFrm.mnuAnalysisDescr_MultXvsYClick(Sender: TObject);
begin
  if MultXvsYFrm = nil then
    Application.CreateForm(TMultXvsYFrm, MultXvsYFrm);
  MultXvsYFrm.Show;
end;

// Menu "Analysis" > "Descriptive" > "Normality Tests"
procedure TOS3MainFrm.mnuAnalysisDescr_NormalityClick(Sender: TObject);
begin
  if NormalityFrm = nil then
    Application.CreateForm(TNormalityFrm, NormalityFrm);
  NormalityFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Plot X vs Y"
procedure TOS3MainFrm.mnuAnalysisDescr_PlotXvsYClick(Sender: TObject);
begin
  if PlotXYFrm = nil then
    Application.CreateForm(TPlotXYFrm, PlotXYFrm);
  PlotXYFrm.Show;
end;

procedure TOS3MainFrm.mnuAnalysisDescr_ResistanceLineClick(Sender: TObject);
begin
  if ResistanceLineForm = nil then
    Application.CreateForm(TResistanceLineForm, ResistanceLineForm);
  ResistanceLineForm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Stem and Leaf Plot"
procedure TOS3MainFrm.mnuAnalysisDescr_StemLeafClick(Sender: TObject);
begin
  if StemLeafFrm = nil then
    Application.CreateForm(TStemLeafFrm, StemLeafFrm);
  StemLeafFrm.ShowModal;
end;


// Menu "Analysis" > "Descriptive" > "3-D Variable Rotation"
procedure TOS3MainFrm.mnuAnalysisDescr_ThreeDRotateClick(Sender: TObject);
begin
  if Rot3DFrm = nil then
    Application.CreateForm(TRot3DFrm, Rot3DFrm);
  Rot3DFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "X versus Multiple Y Plot"
procedure TOS3MainFrm.mnuAnalysisDescr_XvsMultYClick(Sender: TObject);
begin
  if XvsMultYForm = nil then
    Application.CreateForm(TXvsMultYForm, XvsMultYForm);
  XvsMultYForm.ShowModal;
end;


{ SPC commands }

// Menu "Analysis" > "Statistical Process Control" > "Defect (nonconformity) c Chart"
procedure TOS3MainFrm.mnuAnalysisSPC_CChartClick(Sender: TObject);
begin
  if CChartForm = nil then
    Application.CreateForm(TCChartForm, CChartForm);
  CChartForm.Show;
end;


// Menu "Analysis" > "Statistical Process Control" > "CUSUM Chart"
procedure TOS3MainFrm.mnuAnalysisSPC_CUSUMClick(Sender: TObject);
begin
  if CUSUMChartForm = nil then
    Application.CreateForm(TCUSUMChartForm, CUSUMChartForm);
  CUSUMChartForm.Show;
end;


// Menu "Analysis" > "Statistical Process Control" > "p Control Chart"
procedure TOS3MainFrm.mnuAnalysisSPC_PChartClick(Sender: TObject);
begin
  if PChartForm = nil then
    Application.CreateForm(TPChartForm, PChartForm);
  PChartForm.Show;
end;


// Menu "Analysis" > "Statistical Process Control" > "Range Chart"
procedure TOS3MainFrm.mnuAnalysisSPC_RangeClick(Sender: TObject);
begin
  if RChartForm = nil then
    Application.CreateForm(TRChartForm, RChartForm);
  RChartForm.Show;
end;


// Menu "Analysis" > "Statistical Process Control" > "S Control Chart"
procedure TOS3MainFrm.mnuAnalysisSPC_SChartClick(Sender: TObject);
begin
  if SChartForm = nil then
    Application.CreateForm(TSChartForm, SChartForm);
  SChartForm.Show;
end;


// Menu "Analysis" > "Statistical Process Control" > "Defects per Unit u Chart"
procedure TOS3MainFrm.mnuAnalysisSPC_UChartClick(Sender: TObject);
begin
  if UChartForm = nil then
    Application.CreateForm(TUChartForm, UChartForm);
  UChartForm.Show;
end;


// Menu "Analysis" > "Statistical Process Control" > "XBAR Chart"
procedure TOS3MainFrm.mnuAnalysisSPC_XBarClick(Sender: TObject);
begin
  if XBarChartForm = nil then
    Application.CreateForm(TXBarChartForm, XBarChartForm);
  XBarChartForm.Show;
end;


// Menu "Analysis" > "Financial" > "Sum of years digits depreciation"
procedure TOS3MainFrm.MenuItem11Click(Sender: TObject);
begin
  if SumYrsDepFrm = nil then
    Application.CreateForm(TSumYrsDepFrm, SumYrsDepFrm);
  SumYrsDepFrm.ShowModal;
end;

// Menu "Analysis" > "Financial" > "Straight line depreciation"
procedure TOS3MainFrm.MenuItem14Click(Sender: TObject);
begin
  if SLDepFrm = nil then
    Application.CreateForm(TSLDepFrm, SLDepFrm);
  SLDepFrm.ShowModal;
end;




initialization
  {$I mainunit.lrs}

end.

