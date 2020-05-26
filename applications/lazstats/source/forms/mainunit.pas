// File for testing: "GeneChips.laz"
//   Y     --> Dependent
//   Chip  --> Factor 1
//   Probe --> Factor 2 (Factor 3 empty)

unit MainUnit;

{$mode objfpc}{$H+}

{$DEFINE USE_EXTERNAL_HELP_VIEWER}

interface

uses
  LCLType, Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, Menus, ExtCtrls, StdCtrls, Grids,
 {$IFDEF USE_EXTERNAL_HELP_VIEWER}
  {$IFDEF MSWINDOWS}
  HtmlHelp,
  {$ENDIF}
 {$ENDIF}
  Globals, DataProcs, DictionaryUnit;

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
    MenuItem116: TMenuItem;
    MenuItem117: TMenuItem;
    MenuItem118: TMenuItem;
    MenuItem119: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem120: TMenuItem;
    About: TMenuItem;
    CloseFileBtn: TMenuItem;
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
    blockcopy: TMenuItem;
    BlockPaste: TMenuItem;
    BlockCut: TMenuItem;
    GridUse: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem33: TMenuItem;
    GenKappa: TMenuItem;
    CompareDists: TMenuItem;
    MatManMnu: TMenuItem;
    GrdBkMnu: TMenuItem;
    inversez: TMenuItem;
    Chiprob: TMenuItem;
    Fprob: TMenuItem;
    HypergeoProb: TMenuItem;
    BinA: TMenuItem;
    BartlettTest: TMenuItem;
    GrpFreq: TMenuItem;
    Correspondence: TMenuItem;
    KSTest: TMenuItem;
    Equation: TMenuItem;
    Calculater: TMenuItem;
    JPEGView: TMenuItem;
    MedianPolish: TMenuItem;
    DataSmooth: TMenuItem;
    ItemBankMenuItem: TMenuItem;
    homotest: TMenuItem;
    lifetable: TMenuItem;
    LSMRitem: TMenuItem;
    MenuItem42: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem45: TMenuItem;
    MenuItem46: TMenuItem;
    LicenseMenu: TMenuItem;
    MenuItem47: TMenuItem;
    MenuItem48: TMenuItem;
    MenuItem49: TMenuItem;
    MenuItem50: TMenuItem;
    MenuItem51: TMenuItem;
    MenuItem52: TMenuItem;
    SimpChiSqr: TMenuItem;
    SRHItem: TMenuItem;
    OneCaseAnova: TMenuItem;
    ResistanceLine: TMenuItem;
    Sens: TMenuItem;
    XvsMultY: TMenuItem;
    RunsTest: TMenuItem;
    smooth: TMenuItem;
    NestedABC: TMenuItem;
    tprob: TMenuItem;
    probzbetween: TMenuItem;
    Probltz: TMenuItem;
    probgtz: TMenuItem;
    Probabilities: TMenuItem;
    StrToIntegers: TMenuItem;
    SwapDecType: TMenuItem;
    PicView: TMenuItem;
    ShowOpts: TMenuItem;
    WghtedKappa: TMenuItem;
    WLSReg: TMenuItem;
    TwoSLSReg: TMenuItem;
    RiditAnalysis: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem9: TMenuItem;
    pcontrochart: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    HelpContents: TMenuItem;
    InsNewCol: TMenuItem;
    CopyCol: TMenuItem;
    CutCol: TMenuItem;
    PasteCol: TMenuItem;
    NewRow: TMenuItem;
    CopyRowMenu: TMenuItem;
    CutRowMenu: TMenuItem;
    PasteRowMenu: TMenuItem;
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
    OpenFileBtn: TMenuItem;
    NewFileBtn: TMenuItem;
    MenuItem13: TMenuItem;
    TabFileOut: TMenuItem;
    MenuItem16: TMenuItem;
    TabFileInBtn: TMenuItem;
    CSVFileIn: TMenuItem;
    SSVFileIn: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    CSVFileOut: TMenuItem;
    SSVFileOut: TMenuItem;
    DefineVar: TMenuItem;
    PrintDefs: TMenuItem;
    Transform: TMenuItem;
    Recode: TMenuItem;
    FormatGrid: TMenuItem;
    SortCases: TMenuItem;
    PrintGrid: TMenuItem;
    MenuItem3: TMenuItem;
    SelectCases: TMenuItem;
    LoadSubFile: TMenuItem;
    MenuItem32: TMenuItem;
    OneSampTests: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem39: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem41: TMenuItem;
    Distributions: TMenuItem;
    FreqAnal: TMenuItem;
    CrossTabs: TMenuItem;
    Breakdown: TMenuItem;
    BoxPlot: TMenuItem;
    NormalityTests: TMenuItem;
    ThreeDRotate: TMenuItem;
    PlotXvsY: TMenuItem;
    MenuItem5: TMenuItem;
    BubblePlot: TMenuItem;
    StemLeaf: TMenuItem;
    MultXvsY: TMenuItem;
    PropDiff: TMenuItem;
    CorrDiff: TMenuItem;
    ttests: TMenuItem;
    Anova: TMenuItem;
    WithinAnova: TMenuItem;
    AxSAnova: TMenuItem;
    ABSAnova: TMenuItem;
    Option: TMenuItem;
    Ancova: TMenuItem;
    GLM: TMenuItem;
    LatinSquares: TMenuItem;
    ScatPlot: TMenuItem;
    MultDists: TMenuItem;
    TypeErrors: TMenuItem;
    Power: TMenuItem;
    DistPlots: TMenuItem;
    SeqValues: TMenuItem;
    MenuItem7: TMenuItem;
    RandomVals: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem30: TMenuItem;
    SaveFileBtn: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    DataGrid: TStringGrid;
    procedure AboutClick(Sender: TObject);
    procedure ABSAnovaClick(Sender: TObject);
    procedure AncovaClick(Sender: TObject);
    procedure AnovaClick(Sender: TObject);
//    procedure AvgLinkClusterClick(Sender: TObject);
    procedure AxSAnovaClick(Sender: TObject);
    procedure BartlettTestClick(Sender: TObject);
    procedure BinAClick(Sender: TObject);
    procedure blockcopyClick(Sender: TObject);
    procedure BlockPasteClick(Sender: TObject);
    procedure BoxPlotClick(Sender: TObject);
    procedure BreakdownClick(Sender: TObject);
    procedure BubblePlotClick(Sender: TObject);
    procedure CalculaterClick(Sender: TObject);
    procedure ChiprobClick(Sender: TObject);
    procedure CloseFileBtnClick(Sender: TObject);
    procedure CompareDistsClick(Sender: TObject);
    procedure CopyColClick(Sender: TObject);
    procedure CopyRowMenuClick(Sender: TObject);
    procedure CorrDiffClick(Sender: TObject);
    procedure CorrespondenceClick(Sender: TObject);
    procedure CrossTabsClick(Sender: TObject);
    procedure CSVFileInClick(Sender: TObject);
    procedure CSVFileOutClick(Sender: TObject);
    procedure CutColClick(Sender: TObject);
    procedure CutRowMenuClick(Sender: TObject);
    procedure DataGridClick(Sender: TObject);
    procedure DataGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure DataGridKeyPress(Sender: TObject; var Key: char);
    procedure DataGridPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure DataSmoothClick(Sender: TObject);
    procedure DefineVarClick(Sender: TObject);
    procedure DistPlotsClick(Sender: TObject);
    procedure DistributionsClick(Sender: TObject);
    procedure EquationClick(Sender: TObject);
    procedure FormatGridClick(Sender: TObject);
//    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FprobClick(Sender: TObject);
    procedure FreqAnalClick(Sender: TObject);
    procedure GenKappaClick(Sender: TObject);
    procedure GLMClick(Sender: TObject);
    procedure GrdBkMnuClick(Sender: TObject);
    procedure GridUseClick(Sender: TObject);
    procedure GrpFreqClick(Sender: TObject);
    procedure HelpContentsClick(Sender: TObject);
    procedure homotestClick(Sender: TObject);
    procedure HypergeoProbClick(Sender: TObject);
    procedure InsNewColClick(Sender: TObject);
    procedure inversezClick(Sender: TObject);
    procedure ItemBankMenuItemClick(Sender: TObject);
    procedure JPEGViewClick(Sender: TObject);
    procedure KSTestClick(Sender: TObject);
    procedure LatinSquaresClick(Sender: TObject);
    procedure LicenseMenuClick(Sender: TObject);
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
    procedure MenuItem116Click(Sender: TObject);
    procedure MenuItem117Click(Sender: TObject);
    procedure MenuItem118Click(Sender: TObject);
    procedure MenuItem119Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem120Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem27Click(Sender: TObject);
    procedure MenuItem28Click(Sender: TObject);
    procedure MenuItem29Click(Sender: TObject);
    procedure MenuItem31Click(Sender: TObject);
    procedure MenuItem33Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
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
    procedure MenuItem30Click(Sender: TObject);
    procedure MultDistsClick(Sender: TObject);
    procedure MultXvsYClick(Sender: TObject);
    procedure NestedABCClick(Sender: TObject);
    procedure NewFileBtnClick(Sender: TObject);
    procedure NewRowClick(Sender: TObject);
    procedure NormalityTestsClick(Sender: TObject);
    procedure OneCaseAnovaClick(Sender: TObject);
    procedure OneSampTestsClick(Sender: TObject);
    procedure OpenFileBtnClick(Sender: TObject);
    procedure OptionClick(Sender: TObject);
    procedure PasteColClick(Sender: TObject);
    procedure PasteRowMenuClick(Sender: TObject);
    procedure pcontrochartClick(Sender: TObject);
//    procedure PicViewClick(Sender: TObject);
    procedure PlotXvsYClick(Sender: TObject);
    procedure PowerClick(Sender: TObject);
    procedure PrintDefsClick(Sender: TObject);
    procedure PrintGridClick(Sender: TObject);
    procedure probgtzClick(Sender: TObject);
    procedure ProbltzClick(Sender: TObject);
    procedure probzbetweenClick(Sender: TObject);
    procedure PropDiffClick(Sender: TObject);
    procedure RandomValsClick(Sender: TObject);
    procedure RecodeClick(Sender: TObject);
    procedure ResistanceLineClick(Sender: TObject);
    procedure RiditAnalysisClick(Sender: TObject);
    procedure RunsTestClick(Sender: TObject);
    procedure SaveFileBtnClick(Sender: TObject);
    procedure ScatPlotClick(Sender: TObject);
    procedure SelectCasesClick(Sender: TObject);
    procedure SensClick(Sender: TObject);
    procedure SeqValuesClick(Sender: TObject);
    procedure SimpChiSqrClick(Sender: TObject);
    procedure smoothClick(Sender: TObject);
    procedure SortCasesClick(Sender: TObject);
    procedure SRHItemClick(Sender: TObject);
    procedure SSVFileInClick(Sender: TObject);
    procedure SSVFileOutClick(Sender: TObject);
    procedure StemLeafClick(Sender: TObject);
    procedure StrToIntegersClick(Sender: TObject);
    procedure SwapDecTypeClick(Sender: TObject);
    procedure TabFileInBtnClick(Sender: TObject);
    procedure ThreeDRotateClick(Sender: TObject);
    procedure tprobClick(Sender: TObject);
    procedure TransformClick(Sender: TObject);
    procedure TTestsClick(Sender: TObject);
    procedure TwoSLSRegClick(Sender: TObject);
    procedure TypeErrorsClick(Sender: TObject);
    procedure WghtedKappaClick(Sender: TObject);
    procedure WithinAnovaClick(Sender: TObject);
    procedure WLSRegClick(Sender: TObject);
    procedure XvsMultYClick(Sender: TObject);
  private
    { private declarations }
   {$IFDEF USE_EXTERNAL_HELP_VIEWER}
    {$IFDEF MSWINDOWS}
    function HelpHandler(Command: Word; Data: PtrInt; var CallHelp: Boolean): Boolean;
    {$ENDIF}
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
  Utils,
  OptionsUnit, OutputUnit, LicenseUnit, TransFrmUnit, DescriptiveUnit,
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
  BinomialUnit, KendallTauUnit, KaplanMeierUnit, XBarUnit, RChartUnit,
  SigmaChartUnit, CUMSUMUNIT, CCHARTUNIT, PChartUnit, UChartUnit, CorSimUnit,
  ErrorCurvesUnit, PCurvesUnit, DistribUnit, GenSeqUnit, GenRndValsUnit,
  MultGenUnit, LoanItUnit, SumYrsDepUnit, SLDUnit, DblDeclineUnit,
  RIDITUnit, TwoSLSUnit, WLSUnit, HelpUnit, SortCasesUnit,
  SelectCasesUnit, GridHelpUnit, RecodeUnit, KappaUnit, AvgLinkUnit, kmeansunit,
  SingleLinkUnit, GenKappaUnit, CompareDistUnit, matmanunit, gradebookunit,
  ProbzUnit, ProbSmallerzUnit, TwozProbUnit, InversezUnit, ProbChiSqrUnit,
  TprobUnit, FProbUnit, HyperGeoUnit, BNestAUnit, ABCNestedUnit, BartlettTestUnit,
  DataSmoothUnit, GroupFreqUnit, RunsTestUnit, XvsMultYUnit, SensUnit,
  CorrespondenceUnit, EquationUnit, CalculatorUnit, JPEGUnit, ResistanceLineUnit,
  MedianPolishUnit, OneCaseAnovaUnit, SmoothDataUnit, SRHTestUnit, AboutUnit,
  ItemBankingUnit, ANOVATESTSUnit, SimpleChiSqrUnit, LifeTableUnit, LSMRunit;

{ TOS3MainFrm }

// Menu "Options" > "Exit"
procedure TOS3MainFrm.MenuItem16Click(Sender: TObject);
begin
  SaveOptions;
  TempStream.Free;
  TempVarItm.Free;
  Close;
end;

procedure TOS3MainFrm.MenuItem20Click(Sender: TObject);
begin
  SaveTabFile;
end;

// Menu "Analysis" > "Financial" > "Double Declining Value"
procedure TOS3MainFrm.MenuItem27Click(Sender: TObject);
begin
  if DblDeclineFrm = nil then
    Application.CreateForm(TDblDeclineFrm, DblDeclineFrm);
  DblDeclineFrm.ShowModal;
end;

// Menu "Tools" > "Show Output Form"
procedure TOS3MainFrm.MenuItem28Click(Sender: TObject);
begin
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  OutputFrm.ShowModal;
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

// Menu "Analysis" > "Statistical Process Control" > "CUMSUM Chart"
procedure TOS3MainFrm.MenuItem6Click(Sender: TObject);
begin
  if CUMSUMFrm = nil then
    Application.CreateForm(TCUMSUMFrm, CUMSUMFrm);
  CUMSUMFrm.ShowModal;
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

// Menu "Simulations" > "Multivariate Distribution"
procedure TOS3MainFrm.MultDistsClick(Sender: TObject);
begin
  if MultGenFrm = nil then
    Application.CreateForm(TMultGenFrm, MultGenFrm);
  MultGenFrm.ShowModal;
end;

//Menu "Analysis" > "Descriptive" > "Multiple Group X vs Y Plot"
procedure TOS3MainFrm.MultXvsYClick(Sender: TObject);
begin
  if MultXvsYFrm = nil then
    Application.CreateForm(TMultXvsYFrm, MultXvsYFrm);
  MultXvsYFrm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "ABC ANOVA with B Nested in A"
procedure TOS3MainFrm.NestedABCClick(Sender: TObject);
begin
  if ABCNestedForm = nil then
    Application.CreateForm(TABCNestedForm, ABCNestedForm);
  ABCNestedForm.ShowModal;
end;

procedure TOS3MainFrm.NewFileBtnClick(Sender: TObject);
begin
  ClearGrid;
end;

procedure TOS3MainFrm.NewRowClick(Sender: TObject);
begin
  InsertRow;
end;

// Menu "Analysis" > "Descriptive" > "Normality Tests"
procedure TOS3MainFrm.NormalityTestsClick(Sender: TObject);
begin
  if NormalityFrm = nil then
    Application.CreateForm(TNormalityFrm, NormalityFrm);
  NormalityFrm.ShowModal;
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

procedure TOS3MainFrm.OpenFileBtnClick(Sender: TObject);
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

procedure TOS3MainFrm.OptionClick(Sender: TObject);
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

procedure TOS3MainFrm.PasteColClick(Sender: TObject);
begin
  PasteColumn;
end;

procedure TOS3MainFrm.PasteRowMenuClick(Sender: TObject);
begin
  PasteRow;
end;

// Menu "Analysis" > "Statistical Process Control" > "p Control Chart"
procedure TOS3MainFrm.pcontrochartClick(Sender: TObject);
begin
  if pChartFrm = nil then
    Application.CreateForm(TpChartFrm, pChartFrm);
  pChartFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Plot X vs Y"
procedure TOS3MainFrm.PlotXvsYClick(Sender: TObject);
begin
  if PlotXYFrm = nil then
    Application.CreateForm(TPlotXYFrm, PlotXYFrm);
  PlotXYFrm.ShowModal;
end;

// Menu "Simulations" > "Power Curves for a z test"
procedure TOS3MainFrm.PowerClick(Sender: TObject);
begin
  if PCurvesFrm = nil then
    Application.CreateForm(TPCurvesFrm, PCurvesFrm);
  PCurvesFrm.ShowModal;
end;

procedure TOS3MainFrm.PrintDefsClick(Sender: TObject);
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

procedure TOS3MainFrm.PrintGridClick(Sender: TObject);
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

// Menu "Simulations" > "Probability > z"
procedure TOS3MainFrm.probgtzClick(Sender: TObject);
begin
  if ProbzForm = nil then
    Application.CreateForm(TProbZForm, ProbZForm);
  ProbzForm.ShowModal;
end;

// Menu "Simulations" > "Probability < z"
procedure TOS3MainFrm.ProbltzClick(Sender: TObject);
begin
  if ProbSmallerZForm = nil then
    Application.CreateForm(TProbSmallerZForm, ProbSmallerZForm);
  ProbSmallerzForm.ShowModal;
end;

// Menu "Simulations" > "Prob between 2 z values"
procedure TOS3MainFrm.probzbetweenClick(Sender: TObject);
begin
  if TwoZProbForm = nil then
    Application.CreateForm(TTwoZProbForm, TwoZProbForm);
  TwozProbForm.ShowModal;
end;

// Menu "Analysis" > "Comparisons" > "Difference beween Proportions"
procedure TOS3MainFrm.PropDiffClick(Sender: TObject);
begin
  if TwoPropFrm = nil then
    Application.CreateForm(TTwoPropFrm, TwoPropFrm);
  TwoPropFrm.ShowModal;
end;

// Menu "Simulations" > "Random Theoretical Values"
procedure TOS3MainFrm.RandomValsClick(Sender: TObject);
begin
  if GenRndValsFrm = nil then
    Application.CreateForm(TGenRndValsFrm, GenRndValsFrm);
  GenRndValsFrm.ShowModal;
end;

// Menu "Variables" > "Recode Variables"
procedure TOS3MainFrm.RecodeClick(Sender: TObject);
begin
  if RecodeFrm = nil then
    Application.CreateForm(TRecodeFrm, RecodeFrm);
  RecodeFrm.ShowModal;
end;

procedure TOS3MainFrm.ResistanceLineClick(Sender: TObject);
begin
  if ResistanceLineForm = nil then
    Application.CreateForm(TResistanceLineForm, ResistanceLineForm);
  ResistanceLineForm.ShowModal;
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

procedure TOS3MainFrm.SaveFileBtnClick(Sender: TObject);
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

// Menu "Simulations" > "Bivariate Scatter Plot"
procedure TOS3MainFrm.ScatPlotClick(Sender: TObject);
begin
  if CorSimFrm = nil then
    Application.CreateForm(TCorSimFrm, CorSimFrm);
  CorSimFrm.ShowModal;
end;

// Menu "Tools" > "Select cases"
procedure TOS3MainFrm.SelectCasesClick(Sender: TObject);
begin
  if SelectFrm = nil then
    Application.CreateForm(TSelectFrm, SelectFrm);
  SelectFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Sens's Slope Analysis"
procedure TOS3MainFrm.SensClick(Sender: TObject);
begin
  if SensForm = nil then
    Application.CreateForm(TSensForm, SensForm);
  SensForm.ShowModal;
end;

// Menu "Simulations" > "Generate Sequential Values"
procedure TOS3MainFrm.SeqValuesClick(Sender: TObject);
begin
  if GenSeqFrm = nil then
    Application.CreateForm(TGenSeqFrm, GenSeqFrm);
  GenSeqFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Simple Chi Square for Categories"
procedure TOS3MainFrm.SimpChiSqrClick(Sender: TObject);
begin
  if SimpleChiSqrForm = nil then
    Application.CreateForm(TSimpleChiSqrForm, SimpleChiSqrForm);
  SimpleChiSqrForm.ShowModal;
end;

// Menu "Tools" > "Smooth Data in a Variable"
procedure TOS3MainFrm.smoothClick(Sender: TObject);
begin
  if SmoothDataForm = nil then
    Application.CreateForm(TSmoothDataForm, SmoothDataForm);
  SmoothDataForm.ShowModal;
end;

// Menu "Tools" > "Sort Cases"
procedure TOS3MainFrm.SortCasesClick(Sender: TObject);
begin
  if SortCasesFrm = nil then
    Application.CreateForm(TSortCasesFrm, SortCasesFrm);
  SortCasesFrm.ShowModal;
end;

// Menu "Analysis" > "Nonparametric" > "Schreier-Ray-Heart Two-Way ANOVA"
procedure TOS3MainFrm.SRHItemClick(Sender: TObject);
begin
  if SRHTest = nil then
    Application.CreateForm(TSRHTest, SRHTest);
  SRHTest.ShowModal;
end;

procedure TOS3MainFrm.SSVFileInClick(Sender: TObject);
begin
  OpenSpaceFile;
end;

procedure TOS3MainFrm.SSVFileOutClick(Sender: TObject);
begin
  SaveSpaceFile;
end;

// Menu "Analysis" > "Descriptive" > "Stem and Leaf Plot"
procedure TOS3MainFrm.StemLeafClick(Sender: TObject);
begin
  if StemLeafFrm = nil then
    Application.CreateForm(TStemLeafFrm, StemLeafFrm);
  StemLeafFrm.ShowModal;
end;

procedure TOS3MainFrm.StrToIntegersClick(Sender: TObject);
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

procedure TOS3MainFrm.SwapDecTypeClick(Sender: TObject);
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

procedure TOS3MainFrm.TabFileInBtnClick(Sender: TObject);
begin
  OpenTabFile;
end;

// Menu "Analysis" > "Descriptive" > "3-D Variable Rotation"
procedure TOS3MainFrm.ThreeDRotateClick(Sender: TObject);
begin
  if Rot3DFrm = nil then
    Application.CreateForm(TRot3DFrm, Rot3DFrm);
  Rot3DFrm.ShowModal;
end;

// Menu "Simulations" > "Student t probability"
procedure TOS3MainFrm.tprobClick(Sender: TObject);
begin
  if TProbForm = nil then
    Application.CreateForm(TTProbForm, TProbForm);
  TprobForm.ShowModal;
end;

// Menu "Variables" > "Transform Variables"
procedure TOS3MainFrm.TransformClick(Sender: TObject);
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

// Menu "Simulations" > "Type 1 and Type 2 Error Curves"
procedure TOS3MainFrm.TypeErrorsClick(Sender: TObject);
begin
  if ErrorCurvesFrm = nil then
    Application.CreateForm(TErrorCurvesFrm, ErrorCurvesFrm);
  ErrorCurvesFrm.ShowModal;
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

// Menu "Analysis" > "Descriptive" > "X versus Multiple Y Plot"
procedure TOS3MainFrm.XvsMultYClick(Sender: TObject);
begin
  if XvsMultYForm = nil then
    Application.CreateForm(TXvsMultYForm, XvsMultYForm);
  XvsMultYForm.ShowModal;
end;

procedure TOS3MainFrm.DefineVarClick(Sender: TObject);
begin
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
  DictionaryFrm.ShowModal;
end;

// Menu "Simulations" > "Distribution Plots and Critical Values"
procedure TOS3MainFrm.DistPlotsClick(Sender: TObject);
begin
  if DistribFrm = nil then
    Application.CreateForm(TDistribFrm, DistribFrm);
  DistribFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Distribution Statistics"
procedure TOS3MainFrm.DistributionsClick(Sender: TObject);
begin
  if DescriptiveFrm = nil then
    Application.CreateForm(TDescriptiveFrm, DescriptiveFrm);
  DescriptiveFrm.ShowModal;
end;

// Menu "Variables" > "Equation Editor"
procedure TOS3MainFrm.EquationClick(Sender: TObject);
begin
  if EquationForm = nil then
    Application.CreateForm(TEquationForm, EquationForm);
  EquationForm.ShowModal;
end;

procedure TOS3MainFrm.FormatGridClick(Sender: TObject);
begin
  DataProcs.FormatGrid;
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

procedure TOS3MainFrm.FormCreate(Sender: TObject);
begin
  // Reduce ultra-wide width of Inputbox windows
  cInputQueryEditSizePercents := 0;

  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);

  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);

 {$IFDEF USE_EXTERNAL_HELP_VIEWER}
  {$IFDEF MSWINDOWS}
  Application.HelpFile := Application.Location + 'LazStats.chm';
  if FileExists(Application.HelpFile) then
    Application.OnHelp := @HelpHandler
  else
    Application.HelpFile := '';
  {$ENDIF}
 {$ENDIF}
end;

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

// Menu "Analysis" > "Descriptive" > "Data Smoothing"
procedure TOS3MainFrm.DataSmoothClick(Sender: TObject);
begin
  if DataSmoothingForm = nil then
    Application.CreateForm(TDataSmoothingForm, DataSmoothingForm);
  DataSmoothingForm.ShowModal;
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

procedure TOS3MainFrm.CSVFileInClick(Sender: TObject);
begin
     OpenCommaFile;
end;

procedure TOS3MainFrm.CloseFileBtnClick(Sender: TObject);
begin
  NoCases := 0;
  NoVariables := 0;
  Init;
  DataGrid.Cells[1, 0] := '';
end;

// Menu "Analysis" > "Descriptive" > "Compare Distributions"
procedure TOS3MainFrm.CompareDistsClick(Sender: TObject);
begin
  if CompareDistFrm = nil then
    Application.CreateForm(TCompareDistFrm, CompareDistFrm);
  CompareDistFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Breakdown"
procedure TOS3MainFrm.BreakdownClick(Sender: TObject);
begin
  if BreakDownFrm = nil then
    Application.CreateForm(TBreakDownFrm, BreakDownFrm);
  BreakDownFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Repeated Measures Bubble Plot"
procedure TOS3MainFrm.BubblePlotClick(Sender: TObject);
begin
  if BubbleForm = nil then
    Application.CreateForm(TBubbleForm, BubbleForm);
  BubbleForm.ShowModal;
end;

// Menu "Tools" > "Calculator"
procedure TOS3MainFrm.CalculaterClick(Sender: TObject);
begin
  if CalculatorForm = nil then
    Application.CreateForm(TCalculatorForm, CalculatorForm);
  CalculatorForm.ShowModal;
end;

// Menu "Simulations" > "Chisquare Probability"
procedure TOS3MainFrm.ChiprobClick(Sender: TObject);
begin
  if ChiSqrProbForm = nil then
    Application.CreateForm(TChiSqrProbForm, ChiSqrProbForm);
  ChiSqrProbForm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Box Plot"
procedure TOS3MainFrm.BoxPlotClick(Sender: TObject);
begin
  if BoxPlotFrm = nil then
    Application.CreateForm(TBoxPlotFrm, BoxPlotFrm);
  BoxPlotFrm.ShowModal;
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

// Menu "Help" > "About"
procedure TOS3MainFrm.AboutClick(Sender: TObject);
begin
  ShowAboutBox;
//  ShowMessage('Copyright November 1, 2011 by Bill Miller');
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

procedure TOS3MainFrm.blockcopyClick(Sender: TObject);
begin
  CopyIt;
end;

procedure TOS3MainFrm.BlockPasteClick(Sender: TObject);
begin
  PasteIt;
end;

procedure TOS3MainFrm.CopyColClick(Sender: TObject);
begin
  CopyColumn;
end;

procedure TOS3MainFrm.CopyRowMenuClick(Sender: TObject);
begin
  CopyRow;
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

// Menu "Analysis" > "Descriptive" > "Cross tabulation"
procedure TOS3MainFrm.CrossTabsClick(Sender: TObject);
begin
  if CrossTabFrm = nil then
    Application.CreateForm(TCrossTabFrm, CrossTabFrm);
  CrossTabFrm.ShowModal;
end;

procedure TOS3MainFrm.CSVFileOutClick(Sender: TObject);
begin
  SaveCommaFile;
end;

procedure TOS3MainFrm.CutColClick(Sender: TObject);
begin
  DeleteCol;
end;

procedure TOS3MainFrm.CutRowMenuClick(Sender: TObject);
begin
  CutRow;
end;

procedure TOS3MainFrm.DataGridClick(Sender: TObject);
begin
  RowEdit.Text := IntToStr(DataGrid.Row);
  ColEdit.Text := IntToStr(DataGrid.Col);
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

{$IFDEF USE_EXTERNAL_HELP_VIEWER}
{$IFDEF MSWINDOWS}
// Call HTML help (.chm file)
function TOS3MainFrm.HelpHandler(Command: Word; Data: PtrInt;
  var CallHelp: Boolean): Boolean;
var
  topic: UnicodeString;
  res: Integer;
  fn: UnicodeString;
begin
  if Command = HELP_CONTEXT then
  begin
    // see: http://www.helpware.net/download/delphi/hh_doc.txt
    fn := UnicodeString(Application.HelpFile);
    res := htmlhelp.HtmlHelpW(0, PWideChar(fn), HH_HELP_CONTEXT, Data);
  end else
  if Command = HELP_COMMAND then
  begin
    topic := Application.HelpFile + '::/' + PChar(Data);
    res := htmlhelp.HtmlHelpW(0, PWideChar(topic), HH_DISPLAY_TOPIC, 0);
  end;

  // Don't call regular help
  CallHelp := False;

  Result := res <> 0;
end;
{$ENDIF}
{$ENDIF}

procedure TOS3MainFrm.Init;
var
  i: integer;
begin
  OpenStatPath := GetCurrentDir;
//  OptionsFrm.InitOptions(Self);
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

// Menu "Simulations" > "F probability"
procedure TOS3MainFrm.FprobClick(Sender: TObject);
begin
  if FForm = nil then
    Application.CreateForm(TFForm, FForm);
  FForm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Frequency Analysis"
procedure TOS3MainFrm.FreqAnalClick(Sender: TObject);
begin
  if FreqFrm = nil then
    Application.CreateForm(TFreqFrm, FreqFrm);
  FreqFrm.ShowModal;
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

procedure TOS3MainFrm.GridUseClick(Sender: TObject);
begin
  if GridHelpfrm = nil then
    Application.CreateForm(TGridHelpFrm, GridHelpFrm);
  GridHelpFrm.ShowModal;
end;

// Menu "Analysis" > "Descriptive" > "Plot Group Frequencies"
procedure TOS3MainFrm.GrpFreqClick(Sender: TObject);
begin
  if GroupFreqForm = nil then
    Application.CreateForm(TGroupFreqForm, GroupFreqForm);
  GroupFreqForm.ShowModal;
end;

// Menu "Help" > "General Help"
procedure TOS3MainFrm.HelpContentsClick(Sender: TObject);
begin
  if HelpFrm = nil then
    Application.CreateForm(THelpFrm, HelpFrm);
  HelpFrm.ShowModal;
end;

// Menu "Analyses" > "Brown-Forsythe test for homogeneity of variance"
procedure TOS3MainFrm.homotestClick(Sender: TObject);
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

// Menu "Simulations" > "Hypergeometric probability"
procedure TOS3MainFrm.HypergeoProbClick(Sender: TObject);
begin
  if HyperGeoForm = nil then
    Application.CreateForm(THyperGeoForm, HyperGeoForm);
  HyperGeoForm.ShowModal;
end;

procedure TOS3MainFrm.InsNewColClick(Sender: TObject);
begin
  InsertCol;
end;

// Menu "Simulations" > "z for a given cum. Probability"
procedure TOS3MainFrm.InverseZClick(Sender: TObject);
begin
  if InverseZForm = nil then
    Application.CreateForm(TInverseZForm, InverseZForm);
  InverseZForm.ShowModal;
end;

// Menu "Analysis" > "Measurement Programs" > "Item Banking"
procedure TOS3MainFrm.ItemBankMenuItemClick(Sender: TObject);
begin
  if ItemBankFrm = nil then
    Application.CreateForm(TItemBankFrm, ItembankFrm);
  ItemBankFrm.ShowModal;
end;

// Menu "Tools" > "JPEG Image Viewer"
procedure TOS3MainFrm.JPEGViewClick(Sender: TObject);
begin
  if JPEGForm = nil then
    Application.CreateForm(TJPEGForm, JPEGForm);
  JPEGForm.ShowModal;
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

procedure TOS3MainFrm.LicenseMenuClick(Sender: TObject);
begin
  ShowLicense(false);
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

// Menu "Analysis" > "Statistical Process Control" > "XBAR Chart"
procedure TOS3MainFrm.MenuItem116Click(Sender: TObject);
begin
  if XBarFrm = nil then
    Application.CreateForm(TXBarFrm, XBarFrm);
  XBarFrm.ShowModal;
end;

// Menu "Analysis" > "Statistical Process Control" > "Range Chart"
procedure TOS3MainFrm.MenuItem117Click(Sender: TObject);
begin
  if RChartFrm = nil then
    Application.CreateForm(TRChartFrm, RChartFrm);
  RChartFrm.ShowModal;
end;

// Menu "Analysis" > "Statistical Process Control" > "S Control Chart"
procedure TOS3MainFrm.MenuItem118Click(Sender: TObject);
begin
  if SigmaChartFrm = nil then
    Application.CreateForm(TSigmaChartFrm, SigmaChartFrm);
  SigmaChartFrm.ShowModal;
end;

// Menu "Analysis" > "Statistical Process Control" > "Defect (nonconformity) c Chart"
procedure TOS3MainFrm.MenuItem119Click(Sender: TObject);
begin
  if CChartFrm = nil then
    Application.CreateForm(TCChartFrm, CChartFrm);
  CChartFrm.ShowModal;
end;

// Menu "Analysis" > "Financial" > "Sum of years digits depreciation"
procedure TOS3MainFrm.MenuItem11Click(Sender: TObject);
begin
  if SumYrsDepFrm = nil then
    Application.CreateForm(TSumYrsDepFrm, SumYrsDepFrm);
  SumYrsDepFrm.ShowModal;
end;

// Menu "Analysis" > "Statistical Process Control" > "Defects per Unit u Chart"
procedure TOS3MainFrm.MenuItem120Click(Sender: TObject);
begin
  if UChartFrm = nil then
    Application.CreateForm(TUChartFrm, UChartFrm);
  UChartFrm.ShowModal;
end;

// Menu "Analysis" > "Financial" > "Straight line depreciation"
procedure TOS3MainFrm.MenuItem14Click(Sender: TObject);
begin
  if SLDepFrm = nil then
    Application.CreateForm(TSLDepFrm, SLDepFrm);
  SLDepFrm.ShowModal;
end;

procedure TOS3MainFrm.MenuItem30Click(Sender: TObject);
begin
   RowColSwap;
end;

initialization
  {$I mainunit.lrs}

end.

