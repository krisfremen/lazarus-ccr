unit DiscrimUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, GraphLib, Globals, DataProcs,
  MatrixLib, DictionaryUnit;

type

  { TDiscrimFrm }

  TDiscrimFrm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    Panel2: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    DescChk: TCheckBox;
    PCovChk: TCheckBox;
    CentroidsChk: TCheckBox;
    ScoresChk: TCheckBox;
    CorrsChk: TCheckBox;
    InvChk: TCheckBox;
    PlotChk: TCheckBox;
    ClassChk: TCheckBox;
    AnovaChk: TCheckBox;
    CrossChk: TCheckBox;
    DevCPChk: TCheckBox;
    EigensChk: TCheckBox;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    OptionsGroup: TGroupBox;
    PredIn: TBitBtn;
    PredOut: TBitBtn;
    GroupVar: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PredList: TListBox;
    ClassSizeGroup: TRadioGroup;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PredInClick(Sender: TObject);
    procedure PredOutClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    MaxGrp : integer;
    MinGrp : integer;
    procedure PlotPts(Sender: TObject; RawCMat : DblDyneMat;
                              Constants : DblDyneVec;
                              ColNoSelected : IntDyneVec;
                              NoSelected : integer;
                              noroots : integer;
                              NoCases : integer;
                              GrpVar : integer;
                              NoGrps : integer;
                              NoInGrp : IntDyneVec);

    procedure Classify(Sender: TObject; PooledW : DblDyneMat;
                               GrpMeans : DblDyneMat;
                               ColNoSelected : IntDyneVec;
                               NoSelected : integer;
                               NoCases : integer;
                               GrpVar : integer;
                               NoGrps : integer;
                               NoInGrp : IntDyneVec;
                               VarLabels : StrDyneVec);

    procedure ClassIt(Sender: TObject; PooledW : DblDyneMat;
                              ColNoSelected : IntDyneVec;
                              GrpMeans : DblDyneMat;
                              Roots : DblDyneVec;
                              noroots : integer;
                              GrpVar : integer;
                              NoGrps : integer;
                              NoInGrp : IntDyneVec;
                              NoSelected : integer;
                              NoCases : integer;
                              RawCmat : DblDyneMat;
                              Constants : DblDyneVec);
  public
    { public declarations }
  end; 

var
  DiscrimFrm: TDiscrimFrm;

implementation

uses
  Math;

{ TDiscrimFrm }

procedure TDiscrimFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     PredList.Clear;
     PredOut.Enabled := false;
     PredIn.Enabled := true;
     DepOut.Enabled := false;
     DepIn.Enabled := true;
     GroupVar.Text := '';
     DescChk.Checked := false;
     CorrsChk.Checked := false;
     InvChk.Checked := false;
     PlotChk.Checked := false;
     ClassChk.Checked := false;
     AnovaChk.Checked := false;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TDiscrimFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
  Panel1.Constraints.MinWidth := OptionsGroup.Width * 2 + DepIn.Width;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := True;
end;

procedure TDiscrimFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TDiscrimFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TDiscrimFrm.DepInClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     GroupVar.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     DepOut.Enabled := true;
     DepIn.Enabled := false;
end;

procedure TDiscrimFrm.ComputeBtnClick(Sender: TObject);
var
    i, j, k, grp, grpvalue, matrow, matcol, noroots, dfchi, n2, k2 : integer;
    NoSelected : integer;
    outline, GroupLabel, ColHead : string;
    Title : string;
    GrpVar, NoGrps, nowithin, TotalCases, value, grpno : integer;
    ColNoSelected : IntDyneVec;
    CaseNo, NoInGrp : IntDyneVec;
    VarLabels, ColLabels, GrpNos : StrDyneVec;
    X, Y, GroupSS, ErrorSS, GroupMS, ErrorMS, TotalSS, num, s, v2, den : double;
    Lambda, ChiSquare, Pillia, TotChi, p, Rc, chi, chiprob, m, L2, F, Fprob : double;
    DFGroup, DFError, DFTotal, Fratio, prob, minroot, trace, pcnttrace : double;
    probchi : double;
    WithinMat, WithinInv, WinvB, v, PooledW, TotalMat, BetweenMat : DblDyneMat;
    EigenVectors, EigenTrans, TempMat, Theta, DiagMat, CoefMat : DblDyneMat;
    RawCMat, GrpMeans, GrpSDevs, Centroids, Structure : DblDyneMat;
    Constants, ScoreVar, Roots, Pcnts, TotalMeans, TotalVariances : DblDyneVec;
    TotalStdDevs, WithinMeans, WithinVariances, WithinStdDevs, w : DblDyneVec;
    errorcode : boolean = false;
begin
    TotalCases := 0;
    OutputFrm.RichEdit.Clear();
    OutputFrm.RichEdit.Lines.Add('MULTIVARIATE ANOVA / DISCRIMINANT FUNCTION');
    OutputFrm.RichEdit.Lines.Add('Reference: Multiple Regression in Behavioral Research');
    OutputFrm.RichEdit.Lines.Add('Elazar J. Pedhazur, 1997, Chapters 20-21');
    OutputFrm.RichEdit.Lines.Add('Harcourt Brace College Publishers');
    NoSelected := PredList.Items.Count + 1;
    SetLength(ColNoSelected,NoVariables);
    SetLength(VarLabels,NoVariables);
    SetLength(ColLabels,NoVariables);
    SetLength(CaseNo,NoVariables);

    // Get items selected
    for i := 1 to NoSelected - 1 do
    begin
        for j := 1 to NoVariables do
        begin
            if (PredList.Items.Strings[i-1] = OS3MainFrm.DataGrid.Cells[j,0]) then
            begin
                ColNoSelected[i-1] := j;
                VarLabels[i-1] := OS3MainFrm.DataGrid.Cells[j,0];
            end;
            if GroupVar.Text = OS3MainFrm.DataGrid.Cells[j,0] then
            begin
                GrpVar := j;
                GroupLabel := OS3MainFrm.DataGrid.Cells[j,0];
                ColNoSelected[NoSelected-1] := j;
            end;
        end; // next j variable
    end; // next i predictor

    //Allocate memory for analyses
    SetLength(WithinMat,NoVariables,NoVariables);
    SetLength(WithinInv,NoVariables,NoVariables);
    SetLength(WinvB,NoVariables,NoVariables);
    SetLength(v,NoVariables,NoVariables);
    SetLength(PooledW,NoVariables,NoVariables);
    SetLength(TotalMat,NoVariables,NoVariables);
    SetLength(BetweenMat,NoVariables,NoVariables);
    SetLength(EigenVectors,NoVariables,NoVariables);
    SetLength(EigenTrans,NoVariables,NoVariables);
    SetLength(TempMat,NoVariables,NoVariables);
    SetLength(Theta,NoVariables,NoVariables);
    SetLength(DiagMat,NoVariables,NoVariables);
    SetLength(CoefMat,NoVariables,NoVariables);
    SetLength(RawCMat,NoVariables,NoVariables);
    SetLength(Structure,NoVariables,NoVariables);
    SetLength(Constants,NoVariables);
    SetLength(ScoreVar,NoVariables);
    SetLength(Roots,NoVariables);
    SetLength(Pcnts,NoVariables);
    SetLength(TotalMeans,NoVariables);
    SetLength(TotalVariances,NoVariables);
    SetLength(TotalStdDevs,NoVariables);
    SetLength(WithinMeans,NoVariables);
    SetLength(WithinVariances,NoVariables);
    SetLength(WithinStdDevs,NoVariables);
    SetLength(w,NoVariables);

    // Initialize arrays
    for i := 0 to NoSelected-1 do
    begin
        TotalMeans[i] := 0.0;
        TotalVariances[i] := 0.0;
        WithinMeans[i] := 0.0;
        WithinVariances[i] := 0.0;
        for j := 0 to NoSelected-1 do
        begin
            TotalMat[i,j] := 0.0;
            WithinMat[i,j] := 0.0;
            PooledW[i,j] := 0.0;
        end;
    end;

    //Get minimum and maximum group numbers (and no. of groups)
    MinGrp := 1000;
    MaxGrp := 0;
    for i := 1 to NoCases do
    begin
        if (GoodRecord(i,NoSelected,ColNoSelected)) then
        begin
            value := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpVar,i])));
            if (value < MinGrp) then MinGrp := value;
            if (value > MaxGrp) then MaxGrp := value;
        end;
    end; // next case
    NoGrps := MaxGrp - MinGrp + 1;

    //Allocate space for group means, standard deviations and centroids
    SetLength(GrpMeans,NoGrps,NoSelected);
    SetLength(GrpSDevs,NoGrps,NoSelected);
    SetLength(Centroids,NoGrps,NoSelected);
    SetLength(GrpNos,NoGrps);
    SetLength(NoInGrp,NoGrps);

    //Initialize group variables
    for i := 0 to NoGrps-1 do
    begin
        for j := 0 to NoSelected-1 do
        begin
            Centroids[i,j] := 0.0;
            GrpMeans[i,j] := 0.0;
            GrpSDevs[i,j] := 0.0;
        end;
    end;

    OutputFrm.RichEdit.Lines.Add('');
    outline := format('Total Cases := %d, Number of Groups := %d',
            [NoCases, NoGrps]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');

    //Read the data for each group, accumulating cross-products and sums
    for grp := 1 to NoGrps do
    begin
        nowithin := 0;
        grpvalue := grp;
        for i := 1 to NoCases do
        begin
            if (GoodRecord(i,NoSelected,ColNoSelected)) then
            begin
                grpno := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpVar,i])));
                grpno := NoGrps - (MaxGrp - grpno);
                if (grpno = grpvalue) then // case belongs to this group
                begin
                    GrpNos[grp-1] := IntToStr(grpno);
                    nowithin := nowithin + 1;
                    TotalCases := TotalCases + 1;
                    for j := 1 to NoSelected - 1 do // matrix row
                    begin
                        matrow := ColNoSelected[j-1];
                        X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[matrow,i]));
                        for k := 1 to NoSelected - 1 do // matrix col.
                        begin
                            matcol := ColNoSelected[k-1];
                            Y := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[matcol,i]));
                            WithinMat[j-1,k-1] := WithinMat[j-1,k-1] + (X * Y);
                            TotalMat[j-1,k-1] := TotalMat[j-1,k-1] + (X * Y);
                        end;
                        WithinMeans[j-1] := WithinMeans[j-1] + X;
                        WithinVariances[j-1] := WithinVariances[j-1] + (X * X);
                        TotalMeans[j-1] := TotalMeans[j-1] + X;
                        TotalVariances[j-1] := TotalVariances[j-1] + (X * X);
                    end; // next variable j
                end; // if group number match
            end; // end if valid record
        end; // next case

        // Does user want cross-products matrices ?
        if (CrossChk.Checked = true) then
        begin
            // print within matrix
            ColHead := format('Group %d, N = %d',[grp,nowithin]);
            Title := 'SUM OF CROSS-PRODUCTS for ' + ColHead;
            MAT_PRINT(WithinMat,NoSelected-1,NoSelected-1,Title,VarLabels,VarLabels,nowithin);
        end;

        // Convert to deviation cross-products and pool
        for j := 1 to NoSelected - 1 do
        begin
            for k := 1 to NoSelected - 1 do
            begin
                WithinMat[j-1,k-1] := WithinMat[j-1,k-1] -
                    (WithinMeans[j-1] * WithinMeans[k-1] / nowithin);
                PooledW[j-1,k-1] := PooledW[j-1,k-1] + WithinMat[j-1,k-1];
            end;
        end;

        // Does user want deviation cross-products?
        if (DevCPChk.Checked = true) then
        begin
            // print within matrix
            ColHead := format('Group %d, N := %d',[grpvalue,nowithin]);
            Title := 'WITHIN GROUP SUM OF DEVIATION CROSS-PRODUCTS ' + ColHead;
            MAT_PRINT(WithinMat,NoSelected-1,NoSelected-1,Title,VarLabels,
                      VarLabels,nowithin);
        end;

        // Compute descriptives from sums and sums of squares
        for j := 1 to NoSelected - 1 do
        begin
            WithinVariances[j-1] := WithinVariances[j-1] -
               (WithinMeans[j-1] * WithinMeans[j-1] / nowithin);
            WithinVariances[j-1] := WithinVariances[j-1] / (nowithin-1);
            WithinStdDevs[j-1] := sqrt(WithinVariances[j-1]);
            WithinMeans[j-1] := WithinMeans[j-1] / nowithin;
        end;

        // Does user want descriptives ?
        if DescChk.Checked then
        begin
            // print mean, variance and std. dev.s for variables
            outline := format('MEANS FOR GROUP %d, N := %d',[grp,nowithin]);
            DynVectorPrint(WithinMeans,NoSelected-1,outline,VarLabels,nowithin);
            outline := format('VARIANCES FOR GROUP %d',[grp]);
            DynVectorPrint(WithinVariances,NoSelected-1,outline,VarLabels,nowithin);
            outline := format('STANDARD DEVIATIONS FOR GROUP %d',[grp]);
            DynVectorPrint(WithinStdDevs,NoSelected-1,outline,VarLabels,nowithin);
        end;
        if (DescChk.Checked) or (DevCPChk.Checked) or (CrossChk.Checked) then
        begin
             OutputFrm.ShowModal;
             OutputFrm.RichEdit.Clear();
        end;

        // Now initialize for the next group and save descriptives
        for j := 1 to NoSelected - 1 do
        begin
            GrpMeans[grp-1,j-1] := WithinMeans[j-1];
            WithinMeans[j-1] := 0.0;
            GrpSDevs[grp-1,j-1] := WithinStdDevs[j-1];
            WithinVariances[j-1] := 0.0;
            for k := 1 to NoSelected - 1 do WithinMat[j-1,k-1] := 0.0;
        end;
        NoInGrp[grp-1] := nowithin;
    end; // next group

    // Does user want cross-products matrices ?
    if CrossChk.Checked then
    begin
        // print Total cross-products matrix
        Title := 'TOTAL SUM OF CROSS-PRODUCTS';
        MAT_PRINT(TotalMat,NoSelected-1,NoSelected-1,Title,VarLabels,VarLabels,TotalCases);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();
    end;

    //Obtain Total deviation cross-products
    for j := 1 to NoSelected - 1 do
        for k := 1 to NoSelected - 1 do
            TotalMat[j-1,k-1] := TotalMat[j-1,k-1] -
               (TotalMeans[j-1] * TotalMeans[k-1] / TotalCases);

    // Does user want deviation cross-products?
    if DevCPChk.Checked then
    begin
        // print total deviation cross-products matrix
        Title := 'TOTAL SUM OF DEVIATION CROSS-PRODUCTS';
        MAT_PRINT(TotalMat,NoSelected-1,NoSelected-1,Title,VarLabels,VarLabels,TotalCases);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();
    end;
    for j := 1 to NoSelected - 1 do
    begin
        TotalVariances[j-1] := TotalVariances[j-1] -
           (TotalMeans[j-1] * TotalMeans[j-1] / TotalCases);
        TotalVariances[j-1] := TotalVariances[j-1] / (TotalCases - 1);
        TotalStdDevs[j-1] := sqrt(TotalVariances[j-1]);
        TotalMeans[j-1] := TotalMeans[j-1] / TotalCases;
    end;

    // Does user want descriptives ?
    if DescChk.Checked then
    begin
        // print mean, variance and std. dev.s for variables
        Title := 'MEANS';
        DynVectorPrint(TotalMeans,NoSelected-1,Title,VarLabels,TotalCases);
        Title := 'VARIANCES';
        DynVectorPrint(TotalVariances,NoSelected-1,Title,VarLabels,TotalCases);
        Title := 'STANDARD DEVIATIONS';
        DynVectorPrint(TotalStdDevs,NoSelected-1,Title,VarLabels,TotalCases);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();
    end;

    // Obtain between groups deviation cross-products matrix
    MATSUB(BetweenMat,TotalMat,PooledW,NoSelected-1,NoSelected-1,
           NoSelected-1,NoSelected-1,errorcode);

    // Does user want deviation cross-products?
    if DevCPChk.Checked then
    begin
        // print between groups deviation cross-products matrix
        Title := 'BETWEEN GROUPS SUM OF DEV. CPs';
        MAT_PRINT(BetweenMat,NoSelected-1,NoSelected-1,Title,VarLabels,
                  VarLabels,TotalCases);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();
    end;

    // Do univariate ANOVA's for each variable
    if AnovaChk.Checked then
    begin
        for j := 1 to NoSelected - 1 do
        begin
            outline := format('UNIVARIATE ANOVA FOR VARIABLE %s',
                              [VarLabels[j-1]]);
            OutputFrm.RichEdit.Lines.Add(outline);
            OutputFrm.RichEdit.Lines.Add('SOURCE    DF       SS        MS        F         PROB > F');
            GroupSS := BetweenMat[j-1,j-1];
            ErrorSS := PooledW[j-1,j-1];
            TotalSS := TotalMat[j-1,j-1];
            DFGroup := NoGrps - 1;
            DFError := TotalCases - NoGrps;
            DFTotal := TotalCases - 1;
            GroupMS := GroupSS / DFGroup;
            ErrorMS := ErrorSS / DFError;
            Fratio  := GroupMS / ErrorMS;
            prob := probf(Fratio,DFGroup,DFError);
            outline := format('BETWEEN   %3.0f%10.3f%10.3f%10.3f%10.3f',
                [DFGroup,GroupSS,GroupMS,Fratio,prob]);
            OutputFrm.RichEdit.Lines.Add(outline);
            outline := format('ERROR     %3.0f%10.3f%10.3f',
                [DFError,ErrorSS,ErrorMS]);
            OutputFrm.RichEdit.Lines.Add(outline);
            outline := format('TOTAL     %3.0f%10.3f',[DFTotal,TotalSS]);
            OutputFrm.RichEdit.Lines.Add(outline);
            OutputFrm.RichEdit.Lines.Add('');
        end;
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();
    end;

    // Get roots of the product of the within group inverse times between
    // Inverse routine starts at 1, not 0.  Setup temps for inverse
    for i := 1 to NoSelected - 1 do
        for j := 1 to NoSelected - 1 do
            WithinInv[i-1,j-1] := PooledW[i-1,j-1];
    SVDinverse(WithinInv,NoSelected-1);

    // Does user want inverse of pooled within deviation cross-products?
    if InvChk.Checked then
    begin
        Title := 'Inv. of Pooled Within Dev. CPs Matrix';
        MAT_PRINT(WithinInv,NoSelected-1,NoSelected-1,Title,VarLabels,VarLabels,TotalCases);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();
    end;

    // Get roots of the W inverse times Betweeen matrices
    MATAxB(WinvB,WithinInv,BetweenMat,NoSelected-1,NoSelected-1,NoSelected-1,NoSelected-1,errorcode);
    minroot := 0.0;
    noroots := 0;
    if (NoGrps <= NoSelected-1) then noroots := NoGrps-1 else noroots := NoSelected-1;
    trace := 0.0;
    pcnttrace := 0.0;
    nonsymroots(WinvB,NoSelected-1,noroots,minroot,EigenVectors,Roots,Pcnts,trace,pcnttrace);
    outline := format('Number of roots extracted := %d',[noroots]);
    OutputFrm.RichEdit.Lines.Add(outline);
    outline := format('Percent of trace extracted := %10.4f',[pcnttrace]);
    OutputFrm.RichEdit.Lines.Add(outline);
    outline := 'Roots of the W inverse time B Matrix';
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('');
    outline := 'No.       Root   Proportion   Canonical R    Chi-Squared  D.F.    Prob.';
    OutputFrm.RichEdit.Lines.Add(outline);
    Lambda := 1.0;
    ChiSquare := 0.0;
    Pillia := 0.0;
    for i := 1 to noroots do
    begin
        Lambda  := Lambda * (1.0 / (1.0 + Roots[i-1]));
        ChiSquare := ChiSquare + ln(1.0 + Roots[i-1]);
        Pillia := Pillia + (Roots[i-1] / (1.0 + Roots[i-1]));
    end;
    TotChi := ChiSquare;
    for i := 1 to noroots do
    begin
        p := Roots[i-1] / trace;
        Rc := sqrt(Roots[i-1] / (1.0 + Roots[i-1]));
        dfchi := (NoSelected - i) * (NoGrps - i );
        chi := TotChi * (TotalCases - 1.0 - 0.5 * (NoSelected + NoGrps));
        chiprob := 1.0 - chisquaredprob(chi,dfchi);
        outline := format('%2d  %10.4f   %6.4f        %6.4f        %10.4f   %3d    %6.3f',
                [i,Roots[i-1],p,Rc,chi,dfchi,chiprob]);
        OutputFrm.RichEdit.Lines.Add(outline);
        TotChi := TotChi - ln(1.0 + Roots[i-1]);
    end;
    ChiSquare := ChiSquare * ((TotalCases - 1) - (0.5 * (NoSelected - 1 + NoGrps)));
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear();

    for i := 1 to noroots do ColLabels[i-1] := IntToStr(i);
    if EigensChk.Checked then
    begin
        Title := 'Eigenvectors of the W inverse x B Matrix';
        MAT_PRINT(EigenVectors,NoSelected-1,noroots,Title,VarLabels,ColLabels,TotalCases);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();
    end;

    // Now get covariance matrices for the total and within
    for i := 1 to NoSelected - 1 do
    begin
        for j := 1 to NoSelected - 1 do
        begin
            TotalMat[i-1,j-1] := TotalMat[i-1,j-1] / (TotalCases - 1);
            PooledW[i-1,j-1] := PooledW[i-1,j-1] / (TotalCases - NoGrps);
        end;
    end;

    if PCovChk.Checked then
    begin
        Title := 'Pooled Within-Groups Covariance Matrix';
        MAT_PRINT(PooledW,NoSelected-1,NoSelected-1,Title,VarLabels,VarLabels,TotalCases);
        Title := 'Total Covariance Matrix';
        MAT_PRINT(TotalMat,NoSelected-1,NoSelected-1,Title,VarLabels,VarLabels,TotalCases);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();
    end;

    //Get the pooled within groups variance-covariance of disc. scores matrix v'C v
    MATTRN(EigenTrans,EigenVectors, NoSelected-1,noroots); // v'
    MATAxB(TempMat,EigenTrans,PooledW,noroots,NoSelected-1,NoSelected-1,
           NoSelected-1,errorcode);//v'C
    MATAxB(Theta,TempMat,EigenVectors,noroots,NoSelected-1,NoSelected-1,
           noroots, errorcode); //v'C v

    //Create a diagonal matrix with square roots of the diagonal of the Within
    for i := 1 to NoSelected - 1 do
    begin
        for j := 1 to NoSelected - 1 do
        begin
            if (i <> j) then DiagMat[i-1,j-1] := 0.0
            else DiagMat[i-1,j-1] := sqrt(PooledW[i-1,j-1]);
        end;
    end;

    // Get recipricol of standard deviations of each function
    for i := 1 to noroots do
        ScoreVar[i-1] := 1.0 / sqrt(Theta[i-1,i-1]);

    // Divide coefficients by their standard deviations
    for i := 1 to NoSelected - 1 do
    begin
        for j := 1 to noroots do
        begin
            RawCMat[i-1,j-1] := EigenVectors[i-1,j-1] * ScoreVar[j-1]; // raw coeff.
            CoefMat[i-1,j-1] := RawCMat[i-1,j-1] * sqrt(PooledW[i-1,i-1]);
        end;
    end;

    // Get constants for raw score equations
    for i := 1 to noroots do
    begin
        Constants[i-1] := 0.0;
        for j := 1 to NoSelected - 1 do
        begin
            Constants[i-1] := Constants[i-1] - (RawCMat[j-1,i-1] * TotalMeans[j-1]);
        end;
    end;

    // Plot discriminant scores?
    if PlotChk.Checked then
    begin
        PlotPts(self,RawCMat,Constants,ColNoSelected,NoSelected,
            noroots,NoCases,GrpVar,NoGrps,NoInGrp);
    end;

    // print discrim functions
        Title := 'Raw Function Coeff.s from Pooled Cov.';
        MAT_PRINT(RawCMat,NoSelected-1,noroots,Title,VarLabels,ColLabels,TotalCases);
        Title := 'Raw Discriminant Function Constants';
        DynVectorPrint(Constants,noroots,Title,ColLabels,TotalCases);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();

    //Does user want to classify cases using canonical functions?
    if ClassChk.Checked then
    begin
        Classify(self,PooledW, GrpMeans, ColNoSelected, NoSelected-1, NoCases,
                 GrpVar, NoGrps, NoInGrp, VarLabels);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear;
        ClassIt(self,PooledW,ColNoSelected,GrpMeans,Roots,noroots, GrpVar,
                NoGrps,NoInGrp,NoSelected-1,NoCases,RawCMat,Constants);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear;
    end;

    // print standardized discrim function coefficients
    Title := 'Standardized Coeff. from Pooled Cov.';
    MAT_PRINT(CoefMat,NoSelected-1,noroots,Title,VarLabels,ColLabels,TotalCases);
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear();

    // Calculate centroids
    for k := 1 to NoGrps do
    begin
        for i := 1 to noroots do
        begin
            for j := 1 to NoSelected - 1 do
            begin
                Centroids[k-1,i-1] := Centroids[k-1,i-1] + (RawCMat[j-1,i-1] * GrpMeans[k-1,j-1]);
            end;
            Centroids[k-1,i-1] := Centroids[k-1,i-1] + Constants[i-1];
        end;
    end;

    if CentroidsChk.Checked then
    begin
        Title := 'Centroids';
        MAT_PRINT(Centroids,NoGrps,noroots,Title,GrpNos,ColLabels,TotalCases);
        OutputFrm.ShowModal;
        OutputFrm.RichEdit.Clear();
    end;

    // Get variance-covariance matrix of functions (theta)
    MATTRN(EigenTrans,EigenVectors,NoSelected-1,noroots);
    MATAxB(TempMat,EigenTrans,TotalMat,noroots,NoSelected-1,NoSelected-1,
           NoSelected-1,errorcode);
    MATAxB(Theta,TempMat,EigenVectors,noroots,NoSelected-1,NoSelected-1,
           noroots,errorcode);

    // Create a diagonal matrix with square roots of the Total covariance diagonal
    for i := 1 to NoSelected - 1 do
    begin
        for j := 1 to NoSelected - 1 do
        begin
            if (i <> j) then DiagMat[i-1,j-1] := 0.0
            else DiagMat[i-1,j-1] := sqrt(TotalMat[i-1,j-1]);
        end;
    end;

    // Get recipricol of standard deviations of each function
    for i := 1 to noroots do ScoreVar[i-1] := 1.0 / sqrt(Theta[i-1,i-1]);

    // Divide coefficients by score standard deviations
    for i := 1 to NoSelected - 1 do
    begin
        for j := 1 to noroots do
        begin
            RawCMat[i-1,j-1] := EigenVectors[i-1,j-1] * ScoreVar[j-1];
            CoefMat[i-1,j-1] := RawCMat[i-1,j-1] * sqrt(TotalMat[i-1,i-1]);
        end;
    end;

    // print functions obtained from total matrix
    Title := 'Raw Coefficients from Total Cov.';
    MAT_PRINT(RawCMat,NoSelected-1,noroots,Title,VarLabels,ColLabels,TotalCases);
    Title := 'Raw Discriminant Function Constants';
    DynVectorPrint(Constants,noroots,Title,ColLabels,TotalCases);
//    OutputFrm.ShowModal;
//    OutputFrm.RichEdit.Clear();

    // print std. disc coefficients from total matrix
    Title := 'Standardized Coeff.s from Total Cov.';
    MAT_PRINT(CoefMat,NoSelected-1,noroots,Title,VarLabels,ColLabels,TotalCases);
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear();

    // Get correlations from Total covariance matrix
    for i := 1 to NoSelected - 1 do
        for j := 1 to NoSelected - 1 do
            TempMat[i-1,j-1] := TotalMat[i-1,j-1] /
                (TotalStdDevs[i-1] * TotalStdDevs[j-1]);

    if CorrsChk.Checked then
    begin
       Title := 'Total Correlation Matrix';
       MAT_PRINT(TempMat,NoSelected-1,NoSelected-1,Title,VarLabels,VarLabels,TotalCases);
//       OutputFrm.ShowModal;
//       OutputFrm.RichEdit.Clear();
    end;

    // Obtain structure coefficients
    MATAxB(Structure,TempMat,CoefMat,NoSelected-1,NoSelected-1,NoSelected-1,noroots,errorcode);
    Title := 'Corr.s Between Variables and Functions';
    MAT_PRINT(Structure,NoSelected-1,noroots,Title,VarLabels,ColLabels,TotalCases);

    //Compute and print overall statistics for equal group centroids
    n2 := (NoSelected-1) * (NoSelected-1);
    k2 := (NoGrps-1) * (NoGrps-1);
    num := (NoSelected-1) * (NoGrps - 1);
    s := sqrt((n2 * k2 - 4) / (n2 + k2 - 5));
    v2 := (num  - 2.0) / 2.0;
    m := ((2 * TotalCases) - (NoSelected - 1) - NoGrps - 2) / 2.0;
    den := m * s - v2;
    L2 := Power(Lambda,1.0 / s);
    F := ((1.0 - L2)/ L2) * (den / num);
    Fprob := probf(F,num,den);
    outline := format('Wilk''s Lambda = %10.4f.',[Lambda]);
    OutputFrm.RichEdit.Lines.Add(outline);
    outline := format('F = %10.4f with D.F. %5.0f and %5.0f .  Prob > F = %6.4f',
            [F,num,den,Fprob]);
    OutputFrm.RichEdit.Lines.Add(outline);
    dfchi := (NoSelected - 1) * noroots;
    probchi := 1.0 - chisquaredprob(ChiSquare,dfchi);
    outline := format('Bartlett Chi-Squared = %10.4f with %d D.F. and prob. = %6.4f',
                     [ChiSquare,dfchi,probchi]);
    OutputFrm.RichEdit.Lines.Add(outline);
    outline := format('Pillai Trace = %10.4f',[Pillia]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear();

    // Clean up heap
    ColNoSelected := nil;
    NoInGrp := nil;
    GrpNos := nil;
    Centroids := nil;
    GrpSDevs := nil;
    GrpMeans := nil;
    w := nil;
    WithinStdDevs := nil;
    WithinVariances := nil;
    WithinMeans := nil;
    TotalStdDevs := nil;
    TotalVariances := nil;
    TotalMeans := nil;
    Pcnts := nil;
    Roots := nil;
    ScoreVar := nil;
    Constants := nil;
    Structure := nil;
    RawCMat := nil;
    CoefMat := nil;
    DiagMat := nil;
    Theta := nil;
    TempMat := nil;
    EigenTrans := nil;
    EigenVectors := nil;
    BetweenMat := nil;
    TotalMat := nil;
    PooledW := nil;
    v := nil;
    WinvB := nil;
    WithinInv := nil;
    WithinMat := nil;
    CaseNo := nil;
    ColLabels := nil;
    VarLabels := nil;
end;

procedure TDiscrimFrm.DepOutClick(Sender: TObject);
begin
     VarList.Items.Add(GroupVar.Text);
     GroupVar.Text := '';
     DepOut.Enabled := false;
     DepIn.Enabled := true;
end;

procedure TDiscrimFrm.PredInClick(Sender: TObject);
VAR i, index : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            PredList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     PredOut.Enabled := true;
end;

procedure TDiscrimFrm.PredOutClick(Sender: TObject);
VAR index : integer;
begin
     index := PredList.ItemIndex;
     if index < 0 then
     begin
          PredOut.Enabled := false;
          exit;
     end;
     VarList.Items.Add(PredList.Items.Strings[index]);
     PredList.Items.Delete(index);
end;

procedure TDiscrimFrm.PlotPts(Sender: TObject; RawCMat: DblDyneMat;
  Constants: DblDyneVec; ColNoSelected: IntDyneVec; NoSelected: integer;
  noroots: integer; NoCases: integer; GrpVar: integer; NoGrps: integer;
  NoInGrp: IntDyneVec);
var
   i, j, k, m, grp, matrow, group : integer;
   X, Y, XScore, YScore, temp : double;
   xpts : DblDyneVec;
   ypts : DblDyneVec;

begin
    SetLength(xpts,NoCases);
    SetLength(ypts,NoCases);
    SetLength(GraphFrm.Ypoints,1,NoCases);
    SetLength(GraphFrm.Xpoints,1,NoCases);
    if (noroots > 1) then
    begin
        for i := 1 to noroots - 1 do
        begin
            for j := i + 1 to noroots do
            begin
                 for k := 1 to NoCases do
                 begin
                      XScore := 0.0;
                      YScore := 0.0;
                      for grp := 1 to NoGrps do
                      begin
                           if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
                           group := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpVar,k])));
                           group := NoGrps - (MaxGrp - group);
                           if group = grp then
                           begin
                                XScore := Constants[i-1];
                                YScore := Constants[j-1];
                                for m := 1 to NoSelected do
                                begin
                                     matrow := ColNoSelected[m-1];
                                     X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[matrow,k]));
                                     X := X * RawCMat[m-1,i-1];
                                     XScore := XScore + X;
                                end;
                                for m := 1 to NoSelected do
                                begin
                                     matrow := ColNoSelected[m-1];
                                     Y := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[matrow,k]));
                                     Y := Y * RawCMat[m-1,j-1];
                                     YScore := YScore + Y;
                                end;
                                GraphFrm.PointLabels[k] := IntToStr(grp);
                           end; // if group = grp
                      end; // next group
                      xpts[k-1] := XScore;
                      ypts[k-1] := YScore;
                 end; // next case k
                 // sort into ascending X order
                 for k := 1 to NoCases - 1 do
                 begin
                      for m := k + 1 to NoCases do
                      begin
                           if xpts[k-1] > xpts[m-1] then
                           begin
                                temp := xpts[k-1];
                                xpts[k-1] := xpts[m-1];
                                xpts[m-1] := temp;
                                temp := ypts[k-1];
                                ypts[k-1] := ypts[m-1];
                                ypts[m-1] := temp;
                           end;
                      end;
                 end;
                 for k := 1 to NoCases do
                 begin
                    GraphFrm.Ypoints[0,k-1] := ypts[k-1];
                    GraphFrm.Xpoints[0,k-1] := xpts[k-1];
                 end;
                 GraphFrm.nosets := 1;
                 GraphFrm.nbars := NoCases;
                 GraphFrm.Heading := 'CASES IN THE DISCRIMINANT SPACE';
                 GraphFrm.XTitle := 'Function ' + IntToStr(i);
                 GraphFrm.YTitle := 'Function ' + IntToStr(j);
//                 GraphFrm.Ypoints[1] := ypts;
//                 GraphFrm.Xpoints[1] := xpts;
                 GraphFrm.AutoScaled := true;
                 GraphFrm.PtLabels := true;
                 GraphFrm.GraphType := 7; // 2d points
                 GraphFrm.BackColor := clYellow;
                 GraphFrm.ShowBackWall := true;
                 GraphFrm.ShowModal;
            end; // next i
        end;  // next j
    end; // if noroots > 1
    ypts := nil;
    xpts := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;

procedure TDiscrimFrm.Classify(Sender: TObject; PooledW: DblDyneMat;
  GrpMeans: DblDyneMat; ColNoSelected: IntDyneVec; NoSelected: integer;
  NoCases: integer; GrpVar: integer; NoGrps: integer; NoInGrp: IntDyneVec;
  VarLabels: StrDyneVec);
var
   i, j, k, grp : integer;
   outline : string;
   Constant, T : DblDyneVec;
   S : double;
   Coeff, WithinInv : DblDyneMat;

begin
//     SetLength(NoInGrp,NoGrps);
     SetLength(T,NoSelected);
     SetLength(Coeff,NoGrps,NoSelected);
     SetLength(WithinInv,NoSelected,NoSelected);
     SetLength(Constant,NoGrps);

    // Get inverse of pooled within variance-covariance matrix
    for i := 0 to NoSelected-1 do
        for j := 0 to NoSelected-1 do
            WithinInv[i,j] := PooledW[i,j];
    SVDinverse(WithinInv,NoSelected);

    // Get Fisher Discrim Functions and probabilities
    OutputFrm.RichEdit.Lines.Add('Fisher Discriminant Functions');
    for grp := 0 to NoGrps-1 do
    begin
        Constant[grp] := 0.0;
        S := 0.0;
        for j := 0 to NoSelected-1 do
            for k := 0 to NoSelected-1 do
                S := S + WithinInv[j,k] * GrpMeans[grp,j] * GrpMeans[grp,k];
        Constant[grp] := -S / 2.0;
        for j := 0 to NoSelected-1 do
        begin
            T[j] := 0.0;
            for k := 0 to NoSelected-1 do
                T[j] := T[j] + WithinInv[j,k] * GrpMeans[grp,k];
        end;
        for j := 0 to NoSelected-1 do Coeff[grp,j] := T[j];
        outline := format('Group %3d Constant := %6.3f',[grp+1,Constant[grp]]);
        OutputFrm.RichEdit.Lines.Add(outline);
        OutputFrm.RichEdit.Lines.Add('Variable  Coefficient');
        for i := 0 to NoSelected-1 do
        begin
            outline := format('   %3d    %6.3f',[i+1,T[i]]);
            OutputFrm.RichEdit.Lines.Add(outline);
        end;
        OutputFrm.RichEdit.Lines.Add('');
    end; // next group

    // clean up the heap
    Constant := nil;
    WithinInv := nil;
    Coeff := nil;
    T := nil;
//    NoInGrp := nil;
end;

procedure TDiscrimFrm.ClassIt(Sender: TObject; PooledW: DblDyneMat;
  ColNoSelected: IntDyneVec; GrpMeans: DblDyneMat; Roots: DblDyneVec;
  noroots: integer; GrpVar : integer; NoGrps: integer; NoInGrp: IntDyneVec;
  NoSelected: integer; NoCases: integer; RawCmat: DblDyneMat;
  Constants: DblDyneVec);
var
   i, j, k, grp, j1, InGrp, Largest, SecdLarge, oldcolcnt, linecount : integer;
   numberstr, prompt, outline, cellname : string;
   Table : IntDyneMat;
   ProdVec, Dev, D2, Density, ProbGrp, Apriori, Discrim : DblDyneVec;
   SumD2, Determinant, LargestProb, SecdProb, X : double;
   RowLabels, ColLabels : StrDyneVec;
   WithinInv : DblDyneMat;
   col : integer;

begin
    SumD2 := 0.0;
    oldcolcnt := NoVariables;
    SetLength(Table,NoGrps+1,NoGrps+1);
    SetLength(ProdVec,NoSelected);
    SetLength(Dev,NoSelected);
    SetLength(D2,NoGrps);
    SetLength(Density,NoGrps);
    SetLength(ProbGrp,NoGrps);
    SetLength(Apriori,NoGrps);
    SetLength(Discrim,noroots);
    SetLength(RowLabels,NoGrps+1);
    SetLength(ColLabels,NoGrps+1);
    SetLength(WithinInv,NoSelected,NoSelected);

    // Does user want to save scores?  If yes, add columns to grid
    if ScoresChk.Checked then
    begin
        //Add grid headings for discrim scores
        for j := 1 to noroots do
        begin
            cellname := 'Disc ';
            cellname := cellname + IntToStr(j);
            col := oldcolcnt + j;
            DictionaryFrm.newvar(col);
            DictionaryFrm.DictGrid.Cells[1,col] := cellname;
            OS3MainFrm.DataGrid.Cells[col,0] := cellname;
//            NoVariables := NoVariables + 1;
        end;
    end;
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);

    // Initialize arrays that need it
    for i := 1 to NoSelected do ProdVec[i-1] := 0.0;
    for i := 1 to NoGrps do D2[i-1] := 0.0;
    for i := 1 to NoGrps + 1 do
        for j := 1 to NoGrps + 1 do Table[i-1,j-1] := 0;

    // Get inverse of pooled within variance-covariance matrix
    for i := 1 to NoSelected do
        for j := 1 to NoSelected do
            WithinInv[i-1,j-1] := PooledW[i-1,j-1];
    SVDinverse(WithinInv,NoSelected);

    // Calculate determinant (product of roots)
    Determinant := 1.0;
    for i := 1 to noroots do Determinant := Determinant * Roots[i-1];

    linecount := 0;
    // Print Heading
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    outline := 'CLASSIFICATION OF CASES';
    OutputFrm.RichEdit.Lines.Add(outline);
    outline := 'SUBJECT ACTUAL HIGH  PROBABILITY   SEC.D HIGH   DISCRIM';
    OutputFrm.RichEdit.Lines.Add(outline);
    outline := 'ID NO.  GROUP  IN    GROUP P(G/D)  GROUP P(G/D) SCORE';
    OutputFrm.RichEdit.Lines.Add(outline);
    linecount := linecount + 4;

    //Get selected priors
    // Default priors are equal proportions
    for j := 1 to NoGrps do Apriori[j-1] := 1.0 / NoGrps;
    if ClassSizeGroup.ItemIndex = 1 then
    begin
        // Get apriori probabilities
        for j := 1 to NoGrps do
            Apriori[j-1] := NoInGrp[j-1] / NoCases;
    end;
    if ClassSizeGroup.ItemIndex = 2 then // get apriori sizes
    begin
        for j := 1 to NoGrps do
        begin
            prompt := 'Group ' + IntToStr(j);
            outline := FloatToStr(Apriori[j-1]);
            numberstr := InputBox('GROUP PROPORTION:',prompt,outline);
            Apriori[j-1] := StrToFloat(numberstr);
        end;
    end;

    // Calculate group probabilities for each case
    for i := 1 to NoCases do
    begin
        if (linecount >= 59) then
        begin
           OutputFrm.ShowModal;
           OutputFrm.RichEdit.Clear;
           linecount := 0;
        end;
        if (not GoodRecord(i,NoSelected,ColNoSelected))then  continue;
        InGrp := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GrpVar,i])));
        InGrp := NoGrps - (MaxGrp - InGrp);
        for grp := 1 to NoGrps do // group loop
        begin
            for j := 1 to NoSelected do ProdVec[j-1] := 0.0;
            D2[grp-1] := 0.0;
            for j := 1 to NoSelected do // variables loop
            begin
                X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ColNoSelected[j-1],i]));
                Dev[j-1] := X - GrpMeans[grp-1,j-1];
            end;
            // Get squared distance as [X - M]' * inv[S] * [X - M]
            for j := 1 to NoSelected do // deviation * S inverse
                for k := 1 to NoSelected do
                    ProdVec[j-1] := ProdVec[j-1] + (Dev[k-1] * WithinInv[k-1,j-1]);
            for j := 1 to NoSelected do // Product * deviation
                D2[grp-1] := D2[grp-1] + Dev[j-1] * ProdVec[j-1]; // distance from group
            D2[grp-1] := D2[grp-1] - 2.0 * ln(Apriori[grp-1]); ///generalized distance
            SumD2 := SumD2 + exp(-0.5 * D2[grp-1]);
        end; // end of group loop
        for j := 1 to NoGrps do
            ProbGrp[j-1] := exp(-0.5 * D2[j-1]) / SumD2;

        // Get Discrim functions
        for j := 1 to noroots do Discrim[j-1] := 0.0;
        for j := 1 to NoSelected do // variables loop
        begin
            X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[ColNoSelected[j-1],i]));
            for j1 := 1 to noroots do
                Discrim[j1-1] := Discrim[j1-1] + (X * RawCmat[j-1,j1-1]);
        end;
        for j := 1 to noroots do Discrim[j-1] := Discrim[j-1] + Constants[j-1];

        // Does user want to save Discrim scores in grid?
        if ScoresChk.Checked then
        begin
            for j := 1 to noroots do
            begin
                 numberstr := format('%8.3f',[Discrim[j-1]]);
                 OS3MainFrm.DataGrid.Cells[oldcolcnt+j,i] := numberstr;
            end;
        end;

        // Get largest and next largest group probabilities
        Largest := 1;
        LargestProb := ProbGrp[0];
        for grp := 2 to NoGrps do
        begin
            if (ProbGrp[grp-1] > LargestProb) then
            begin
                Largest := grp;
                LargestProb := ProbGrp[grp-1];
            end;
        end;

        ProbGrp[Largest-1] := 0.0;
        SecdLarge := 1;
        SecdProb := ProbGrp[0];
        for grp := 2 to NoGrps do
        begin
            if (ProbGrp[grp-1] > SecdProb) then
            begin
                SecdLarge := grp;
                SecdProb := ProbGrp[grp-1];
            end;
        end;

        // Print results for this case i
        outline := format('%3d    %3d    %3d      %6.4f      %3d   %6.4f %7.4f',
                [i,InGrp,Largest,LargestProb,SecdLarge,SecdProb,
                Discrim[0]]);
        OutputFrm.RichEdit.Lines.Add(outline);
        linecount := linecount + 1;
        for j := 2 to noroots do
        begin
            outline := format('                                                %7.4f',
                    [Discrim[j-1]]);
            OutputFrm.RichEdit.Lines.Add(outline);
            linecount := linecount + 1;
        end;
        Table[InGrp-1,Largest-1] := Table[InGrp-1,Largest-1] + 1;
        // initialize variables for next case
        SumD2 := 0.0;
    end; // end of case loop i

    // Get table column and row totals
    for i := 1 to NoGrps do // table rows
        for j := 1 to NoGrps do Table[i-1,NoGrps] := Table[i-1,NoGrps] + Table[i-1,j-1];
    for j := 1 to NoGrps do // table columns
        for i := 1 to NoGrps do Table[NoGrps,j-1] := Table[NoGrps,j-1] + Table[i-1,j-1];
    Table[NoGrps,NoGrps] := NoCases;

    if (linecount > 0) then
    begin
         OutputFrm.ShowModal();
         OutputFrm.RichEdit.Clear;
    end;
    // Print table of classifications
    for i := 1 to NoGrps + 1 do
    begin
        RowLabels[i-1] := IntToStr(i);
        ColLabels[i-1] := IntToStr(i);
    end;
    RowLabels[NoGrps] := 'TOTAL';
    ColLabels[NoGrps] := 'TOTAL';
    IntArrayPrint(Table, NoGrps+1,NoGrps+1, 'PREDICTED GROUP',
                  RowLabels, ColLabels, 'CLASSIFICATION TABLE');

    // Clean up the heap
    WithinInv := nil;
    ColLabels := nil;
    RowLabels := nil;
    Discrim := nil;
    Apriori := nil;
    ProbGrp := nil;
    Density := nil;
    D2 := nil;
    Dev := nil;
    ProdVec := nil;
    Table := nil;
end;

initialization
  {$I discrimunit.lrs}

end.

