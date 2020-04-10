unit FactorUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, GraphLib, Globals, MatrixLib,
  DataProcs, DictionaryUnit;

type

  { TFactorFrm }

  TFactorFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    MinRootEdit: TEdit;
    MaxItersEdit: TEdit;
    MaxFactorsEdit: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    SaveCorsBtn: TCheckBox;
    SaveDialog1: TSaveDialog;
    SaveFactBtn: TCheckBox;
    SortBtn: TCheckBox;
    ScreeBtn: TCheckBox;
    ComUnBtn: TCheckBox;
    PlotBtn: TCheckBox;
    ScoresBtn: TCheckBox;
    DescBtn: TCheckBox;
    RMatBtn: TCheckBox;
    UnrotBtn: TCheckBox;
    PcntTrBtn: TCheckBox;
    GroupBox1: TGroupBox;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    FactorList: TListBox;
    RotateGroup: TRadioGroup;
    TypeGroup: TRadioGroup;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;

    procedure Factors(const eigenvalues, d2: DblDyneVec;
      const A: DblDyneMat; N: integer; factorchoice: integer);

    procedure FactReorder(const d: DblDyneVec; const A: DblDyneMat;
      const var_label: StrDyneVec; N: integer);

    procedure SortLoadings(const v: DblDyneMat; n1, n2: integer;
      const High_Factor : IntDyneVec; const A, b: DblDyneVec;
      const var_label: StrDyneVec; const Order: IntDyneVec);

    procedure VariMax(const v: DblDyneMat; n1, n2: integer;
      const RowLabels, ColLabels: StrDyneVec; const Order: IntDyneVec; AReport: TStrings);

    procedure PROCRUST(const B: DblDyneMat; nv, nb: integer;
      const RowLabels,ColLabels : StrDyneVec; AReport: TStrings);

    procedure LSFactScores(const F: DblDyneMat; NoVars, NoFacts, NCases: integer;
      const ColNoSelected: IntDyneVec; const RowLabels: StrDyneVec;
      AReport: TStrings);

    procedure QuartiMax(const v: DblDyneMat; n1, n2: integer;
      const RowLabels, ColLabels: StrDyneVec; const Order: IntDyneVec;
      AReport: TStrings);

    procedure ManualRotate(const v: DblDyneMat; n1, n2: integer;
      const RowLabels, ColLabels: StrDyneVec; const Order: IntDyneVec;
      AReport: TStrings);

  public
    { public declarations }
  end; 

var
  FactorFrm: TFactorFrm;

implementation

uses
  Math, Utils, RotateUnit;

{ TFactorFrm }

procedure TFactorFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  FactorList.Clear;
  TypeGroup.ItemIndex := 0;
  RotateGroup.ItemIndex := 0;
  DescBtn.Checked := false;
  RMatBtn.Checked := false;
  UnrotBtn.Checked := false;
  PcntTrBtn.Checked := false;
  ScreeBtn.Checked := false;
  ComUnBtn.Checked := false;
  PlotBtn.Checked := false;
  ScoresBtn.Checked := false;
  SaveCorsBtn.Checked := false;
  SaveFactBtn.Checked := false;
  SortBtn.Checked := false;
  MinRootEdit.Text := '1';
  MaxItersEdit.Text := '25';
  MaxFactorsEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TFactorFrm.ComputeBtnClick(Sender: TObject);
label again;
var
   i, j, k, L, Nroots, noiterations, NoSelected, factorchoice : integer;
   maxiters, prtopts, maxnoroots, count : integer;
   TempMat, V, corrmat, ainverse, Loadings : DblDyneMat;
   Eigenvector, pcnttrace, b, communality, xvector, yvector, d2 : DblDyneVec;
   means, variances, stddevs, W : DblDyneVec;
   MaxRoot,  criterion, Difference, minroot, maxk, trace : double;
   cellstring, outline, xtitle, ytitle : string;
   ColNoSelected : IntDyneVec;
   RowLabels, ColLabels : StrDyneVec;
   MatInput : boolean;
   Title : string;
   filename : string;
   errorcode: boolean = false;
   lReport: TStrings;
   msg: String;
   C: TWinControl;
begin
  if not Validate(msg, C) then
  begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  MaxRoot := 0.0;
  NoIterations := 0;
  MaxNoRoots := 0;
  PrtOpts := 0;

  criterion := 0.0001; //Convergence of communality estimates
  //factorchoice := 1;  // assume principal component
  factorChoice := TypeGroup.ItemIndex + 1;
    {
    if (TypeGroup.ItemIndex = 1) then factorchoice := 2;
    if (TypeGroup.ItemIndex = 2) then factorchoice := 3;
    if (TypeGroup.ItemIndex = 3) then factorchoice := 4;
    if (TypeGroup.ItemIndex = 4) then factorchoice := 5;
    if (TypeGroup.ItemIndex = 5) then factorchoice := 6;
    if (TypeGroup.ItemIndex = 6) then factorchoice := 7;
    }
  if RMatBtn.Checked then prtopts := 3;                    // wp: why changed in next line?
  if RMatBtn.Checked then prtopts := 2;
  if RMatBtn.Checked and DescBtn.Checked then prtopts := 1;
  maxiters := StrToInt(MaxItersEdit.Text);
  if (MaxFactorsEdit.Text <> '') then
    MaxNoRoots := StrToInt(MaxFactorsEdit.Text);

  // Setup the output
  lReport := TStringList.Create;
  try
    lReport.Add('FACTOR ANALYSIS');
    lReport.Add('See Rummel, R.J., Applied Factor Analysis');
    lReport.Add('Northwestern University Press, 1970');
    lReport.Add('');

    if FactorList.Items.Count = 0 then
      MatInput := true
    else begin
      NoSelected := FactorList.Items.Count;
      MatInput := false;
    end;

    // Allocate space on heap
    SetLength(corrmat, NoVariables + 1, NoVariables + 1);
    SetLength(TempMat, NoVariables, NoVariables);
    SetLength(ainverse, NoVariables, NoVariables);
    SetLength(V, NoVariables, NoVariables);
    SetLength(W, NoVariables);
    SetLength(Loadings, NoVariables, NoVariables);
    SetLength(Eigenvector, NoVariables);
    SetLength(communality, NoVariables);
    SetLength(pcnttrace, NoVariables);
    SetLength(b, NoVariables);
    SetLength(d2, NoVariables);
    SetLength(xvector, NoVariables);
    SetLength(yvector, NoVariables);
    SetLength(means, NoVariables);
    SetLength(variances, NoVariables);
    SetLength(stddevs, NoVariables);
    SetLength(RowLabels, NoVariables);
    SetLength(ColLabels, NoVariables);
    SetLength(ColNoSelected, NoVariables);

    if MatInput then // matrix input
    begin
      OpenDialog1.Filter := 'Matrix files (*.mat)|*.mat;*.MAT|All files (*.*)|*.*';
      OpenDialog1.FilterIndex := 1;
      OpenDialog1.Title := 'Input Matrix';
      if not OpenDialog1.Execute then
        exit;
      filename := OpenDialog1.FileName;
      MatRead(corrmat, NoSelected, NoSelected, means, stddevs, count, RowLabels, ColLabels, filename);
      for i := 1 to NoSelected do
      begin
        variances[i-1] := sqr(stddevs[i-1]);
        FactorList.Items.Add(RowLabels[i-1]);
        ColNoSelected[i-1] := i;
      end;
      NoCases := count;
    end else
    begin
      for i := 1 to NoSelected do
      begin
        cellstring := FactorList.Items.Strings[i-1];
        for j := 1 to NoVariables do
        begin
          if (cellstring = OS3MainFrm.DataGrid.Cells[j,0]) then
          begin
            ColNoSelected[i-1] := j;
            ColLabels[i-1] := cellstring;
            RowLabels[i-1] := cellstring;
          end;
        end;
      end;
    end;
    count := NoCases;

    //Obtain correlation matrix and, if required simultaneous Multiple Correlations
    if not MatInput then
      Correlations(NoSelected, ColNoSelected, corrmat, means, variances, stddevs, errorcode, count);

    // print correlation matrix
    if RMatBtn.Checked then
    begin
      Title := 'Total Correlation Matrix';
      MatPrint(corrmat, NoSelected, NoSelected, Title, RowLabels, ColLabels, count, lReport);
    end;

    // print descriptives
    if DescBtn.Checked then
    begin
      // print mean, variance and std. dev.s for variables
      outline := 'MEANS';
      DynVectorPrint(Means, NoSelected, outline, RowLabels, count, lReport);
      outline := 'VARIANCES';
      DynVectorPrint(Variances, NoSelected, outline, RowLabels, count, lReport);
      outline := 'STANDARD DEVIATIONS';
      DynVectorPrint(StdDevs, NoSelected, outline, RowLabels, count, lReport);
    end;
    k := NoSelected;

    // Save correlation matrix if checked
    if SaveCorsBtn.Checked then
    begin
      SaveDialog1.Filter := 'Matrix files (*.mat)|(*.mat;*.MAT)|All files (*.*)|(*.*)';
      SaveDialog1.FilterIndex := 1;
      SaveDialog1.Title := 'Save Matrix';
      if SaveDialog1.Execute then
      begin
        filename := SaveDialog1.FileName;
        MatSave(corrmat, NoSelected, NoSelected, means, stddevs, count, RowLabels, ColLabels, filename);
      end;
    end;
    maxk := k;
    Nroots := k;

    //not a principal component analysis
    if factorChoice <> 1 then
    begin
      //get matrix inverse, squared Multiple Correlations
      //Uniqueness (1-squared multiple Correlations, and
      //variance of residuals (D squared)
      for i := 1 to NoSelected do
        for j := 1 to NoSelected do
          ainverse[i-1,j-1] := corrmat[i-1,j-1];
      SVDinverse(ainverse,k);
      for i := 1 to k do
      begin
        d2[i-1] := 1.0 / ainverse[i-1,i-1];
        communality[i-1] := 1.0 - d2[i-1];
      end;

      case factorchoice of
        2: begin
             lReport.Add('Partial Image Analysis');
             // Save corrmat in TempMat for temporary use
             for i := 1 to k do
               for j := 1 to k do TempMat[i-1,j-1] := corrmat[i-1,j-1];
             for i := 1 to k do corrmat[i-1,i-1] := communality[i-1];
             if RMatBtn.Checked then
             begin
               lReport.Add('Communality Estimates are Squared Multiple Correlations.');
               Title := 'Partial Image Matrix';
               MatPrint(corrmat, k, k, Title, RowLabels, ColLabels, count, lReport);
               lReport.Add('');
               lReport.Add(DIVIDER);
               lReport.Add('');
             end;
           end;
        3: begin
             lReport.Add('Guttman Image Analysis');
             //pre and post multiply inverse of R by D2 to obtain anti-image matrix
             for i := 1 to k do
               for j := 1 to k do
                 ainverse[i-1,j-1] := d2[i-1] * ainverse[i-1,j-1] * d2[j-1];
             if RMatBtn.Checked then
             begin
               Title := 'Anti-image covariance matrix';
               MatPrint(ainverse, k, k, Title, RowLabels, ColLabels, count, lReport);
               lReport.Add('');
               lReport.Add(DIVIDER);
               lReport.Add('');
             end;
             for i := 1 to k do
               for j := 1 to k do
                 corrmat[i-1,j-1] := corrmat[i-1,j-1] + ainverse[i-1,j-1];
             for i := 1 to k do
               corrmat[i-1,i-1] := corrmat[i-1,i-1] - (2.0 * d2[i-1]);
             if RmatBtn.Checked then
             begin
               Title := 'Image Covariance Matrix Analyzed';
               MatPrint(corrmat, k, k, Title, RowLabels, ColLabels, count, lReport);
               lReport.Add('');
               lReport.Add(DIVIDER);
               lReport.Add('');
             end;
           end;
        4: begin
             //pre and post multiply inverse of R by D2 to obtain anti-image matrix
             for i := 1 to k do
               for j := 1 to k do
                 ainverse[i-1,j-1] := d2[i-1] * ainverse[i-1,j-1] * d2[j-1];
             for i := 1 to k do
               for j := 1 to k do
                 corrmat[i-1,j-1] := corrmat[i-1,j-1] + ainverse[i-1,j-1];
             for i := 1 to k do
               corrmat[i-1,i-1] := corrmat[i-1,i-1] - (2.0 * d2[i-1]);
             lReport.Add('Harris Scaled Image Analysis');
             for i := 1 to k do
               for j := 1 to k do
                 corrmat[i-1,j-1] := (1.0 / sqrt(d2[i-1]) * corrmat[i-1,j-1] * (1.0 / sqrt(d2[j-1])));
             if RMatBtn.Checked then
             begin
               Title := 'Harris Scaled Image Covariance Matrix';
               MatPrint(corrmat, k, k, Title, RowLabels, ColLabels, count, lReport);
               lReport.Add('');
               lReport.Add(DIVIDER);
               lReport.Add('');
             end;
           end;
        5: begin
             lReport.Add('Canonical Factor Analysis');
             for i := 1 to k do corrmat[i-1,i-1] := communality[i-1];
             for i := 1 to k do
               for j := 1 to k do
                 corrmat[i-1,j-1] := (1.0 / sqrt(d2[i-1])) * corrmat[i-1,j-1] * (1.0 / sqrt(d2[j-1]));
             if RMatBtn.Checked then
             begin
               Title := 'Canonical Covariance Matrix';
               MatPrint(corrmat, k, k, Title, RowLabels, ColLabels, count, lReport);
               lReport.Add('');
               lReport.Add(DIVIDER);
               lReport.Add('');
             end;
           end;
        6: begin
             lReport.Add('Alpha Factor Analysis');
             // Save corrmat in TempMat for temporary use
             for i := 1 to k do
               for j := 1 to k do TempMat[i-1,j-1] := corrmat[i-1,j-1];
             for i := 1 to k do corrmat[i-1,i-1] := communality[i-1];
             for i := 1 to k do
               for j := 1 to k do
                 corrmat[i-1,j-1] := (1.0 / sqrt(communality[i-1])) * corrmat[i-1,j-1] * (1.0 / sqrt(communality[j-1]));
             if RmatBtn.Checked then
             begin
               Title := 'Initial Alpha Factor Matrix';
               MatPrint(corrmat, k, k, Title, RowLabels, ColLabels, count, lReport);
               lReport.Add('');
               lReport.Add(DIVIDER);
               lReport.Add('');
             end;
           end;
        7: begin // Principal Axis Factor Analysis
             // Save corrmat in TempMat for temporary use
             for i := 1 to k do
               for j := 1 to k do TempMat[i-1,j-1] := corrmat[i-1,j-1];
             for i := 1 to k do corrmat[i-1,i-1] := communality[i-1];
             if RMatBtn.Checked then
             begin
               lReport.Add('Initial Communality Estimates are Squared Multiple Correlations.');
               Title := 'Principals Axis Factor Analysis Matrix';
               MatPrint(corrmat, k, k, Title, RowLabels, ColLabels, count, lReport);
               lReport.Add('');
               lReport.Add(DIVIDER);
               lReport.Add('');
             end;
           end;
      end; // end case
    end // end if factor choice not equal to 1 (Principals Components)
    else
    begin
      lReport.Add('Principal Components Analysis');
      if RMatBtn.Checked then
      begin
        Title := 'Correlation Matrix Factor Analyzed';
        MatPrint(corrmat, k, k, Title, RowLabels, ColLabels, count, lReport);
        lReport.Add('');
        lReport.Add(DIVIDER);
        lReport.Add('');
      end;
    end;

    //Calculate trace of the matrix to be analyzed
    trace := 0.0;
    for i := 1 to k do trace := trace  + corrmat[i-1,i-1];
    outline := format('Original matrix trace: %6.2f', [trace]);
    OutputFrm.RichEdit.Lines.Add(outline);

again:

    for i := 1 to k do
      for j := 1 to k do ainverse[i-1,j-1] := corrmat[i-1,j-1];

    eigens(ainverse,Eigenvector,k);

    //iteratively solve for communalities
    if (factorchoice = 6) or (factorchoice = 7) then
    begin
      //denormalize eigenvectors
      for i := 1 to k do
      begin
        for j := 1 to k do
        begin
          if ( Eigenvector[j-1] > 0.0) then
            ainverse[i-1,j-1] := ainverse[i-1,j-1] * sqrt(Eigenvector[j-1])
          else
          begin
            ainverse[i-1,j-1] := 0.0;
            Eigenvector[j-1] := 0.0;
          end;
        end;
        b[i-1] := 0.0;
      end;

      //get communality estimate from sum of squared loadings in TempMat
      for j := 1 to k do
        for i := 1 to k do
          b[i-1] := b[i-1] + (ainverse[i-1,j-1] * ainverse[i-1,j-1]);
      for i := 1 to k do
      begin
        if (b[i-1] > 1.0) then
        begin
          b[i-1] := 1.0;
          lReport.Add('WARNING! A communality estimate greater than 1.0 found.');
          lReport.Add('Value replaced by 1.0.  View results with skepticism.');
        end;
      end;

      Difference := 0.0;
      for i := 1 to k do Difference := Difference + abs(b[i-1] - communality[i-1]);
      if ((Difference > criterion) and (noiterations < maxiters)) then
      begin
        // restore original r matrix
        for i := 1 to k do
          for j := 1 to k do corrmat[i-1,j-1] := TempMat[i-1,j-1];

        // Place new communalities in the diagonal
        for i := 1 to k do corrmat[i-1,i-1] := b[i-1];

        // scale for alpha analysis
        if (factorchoice = 6) then
        begin
          for i := 1 to k do
            for j := 1 to k do
              corrmat[i-1,j-1] := (1.0 / sqrt(b[i-1])) * corrmat[i-1,j-1] * (1.0 / sqrt(b[j-1]));
        end;

        // Save new communality estimates
        for i := 1 to k do communality[i-1] := b[i-1];
        noiterations := noiterations + 1;
        goto again;                           // wp: HOW TO EXIT THIS LOOP ???
      end
      else
      begin
        if (noiterations >= maxiters) then
          lReport.Add('Factor Analysis failed to converge in %d iterations.', [maxiters]);
        FactReorder(Eigenvector, ainverse, RowLabels, k);
      end;
    end
    else //principal components
    begin
      Factors(Eigenvector, d2, ainverse, k, factorchoice);
      FactReorder(Eigenvector, ainverse, RowLabels, k);
    end;

    for i := 1 to k do
      for j := 1 to k do
        Loadings[i-1,j-1] := ainverse[i-1,j-1];

    if ScreeBtn.Checked then
    begin
      SetLength(GraphFrm.Ypoints,1,k);
      SetLength(GraphFrm.Xpoints,1,k);
      for i := 1 to k do
      begin
        xvector[i-1] := i;
        GraphFrm.Xpoints[0,i-1] := i;
        GraphFrm.Ypoints[0,i-1] := Eigenvector[i-1];
      end;
      GraphFrm.nosets := 1;
      GraphFrm.nbars := k;
      GraphFrm.Heading := 'PLOT OF EIGENVALUES EXTRACTED';
      GraphFrm.XTitle := 'ROOT NUMBER';
      GraphFrm.YTitle := 'EIGENVALUE';
//        GraphFrm.Ypoints[1] := Eigenvector;
//        GraphFrm.Xpoints[1] := xvector;
      GraphFrm.AutoScaled := true;
      GraphFrm.PtLabels := false;
      GraphFrm.GraphType := 7; // 2d points
      GraphFrm.BackColor := clCream;
      GraphFrm.ShowBackWall := true;
      GraphFrm.ShowModal;
    end;

    // Setup labels for factors
    for i := 1 to k do
      ColLabels[i-1] := Format('Factor %d', [i]);

    //print results if requested
    if UnrotBtn.Checked then
    begin
      lReport.Add('Roots (Eigenvalues) Extracted:');
      for i := 1 to Nroots do
        lReport.Add('%4d %6.3f', [i, Eigenvector[i-1]]);
      lReport.Add('');
      lReport.Add('Unrotated Factor Loadings');
      Title := 'FACTORS';
      MatPrint(Loadings, k, Nroots, Title, RowLabels, ColLabels, count, lReport);
      lReport.Add('Percent of Trace In Each Root:');
      for i := 1 to Nroots do
        lReport.Add('%4d   Root: %6.3f   Trace: %6.3f   Percent: %7.3f',
          [i, Eigenvector[i-1], trace, (Eigenvector[i-1]/ trace) * 100.0]
        );
      lReport.Add('');
      lReport.Add(DIVIDER);
      lReport.Add('');
    end;

    // final communality estimates
    trace := 0.0;
    for i := 1 to k do
    begin
      b[i-1] := 0.0;
      for j := 1 to Nroots do b[i-1] := b[i-1] + (Loadings[i-1,j-1] * Loadings[i-1,j-1]);
      trace := trace + b[i-1];
    end;

    if ComUnBtn.Checked then
    begin
      lReport.Add('');
      lReport.Add('COMMUNALITY ESTIMATES');
      for i := 1 to k do
        lReport.Add('%3d %-10s %6.3f', [i, RowLabels[i-1], b[i-1]]);
      lReport.Add('');
      lReport.Add('');
      lReport.Add(DIVIDER);
      lReport.Add('');
    end;

    if (Nroots > 1) then
    begin
      minroot := StrToFloat(MinRootEdit.Text);
      Nroots := 0;
      for i := 1 to k do
        if (Eigenvector[i-1] > minroot) then
          Nroots := Nroots + 1;
      if (maxnoroots = 0) then
        maxnoroots := Nroots;
      if (Nroots > maxnoroots) then
        Nroots := maxnoroots;

      if (RotateGroup.ItemIndex = 0) then
        VariMax(Loadings, k, Nroots, RowLabels, ColLabels, ColNoSelected, lReport);

      if (RotateGroup.ItemIndex = 1) then
        MessageDlg('Oblimax not available - sorry!', mtInformation, [mbOK], 0);

      if (RotateGroup.ItemIndex = 2) then
        QuartiMax(Loadings, k, Nroots, RowLabels, ColLabels, ColNoSelected, lReport);

      // graphical (manual) rotation
      if (RotateGroup.ItemIndex = 3) then
        ManualRotate(Loadings, k, Nroots, RowLabels, ColLabels, ColNoSelected, lReport);

      // Procrustean rotation to target
      if (RotateGroup.ItemIndex = 4) then
        ProCrust(Loadings, k, Nroots, RowLabels, ColLabels, lReport);
    end;

    if (factorchoice = 6) or (factorchoice = 7) then
      lReport.Add('No. of iterations: %d', [noiterations]);

    if (Nroots > 1) and PlotBtn.Checked then
    begin
      for i := 1 to Nroots - 1 do
      begin
        for j := i + 1 to Nroots do
        begin
          for L := 1 to k do
          begin
            xvector[L-1] := Loadings[L-1,i-1];
            yvector[L-1] := Loadings[L-1,j-1];
          end;
          xtitle := format('Factor %d',[i]);
          ytitle := format('Factor %d',[j]);
          ScatPlot(xvector, yvector, k, 'FACTOR PLOT', xtitle, ytitle, -1.0, 1.0, -1.0, 1.0, RowLabels, lReport);
          lReport.Add('');
          lReport.Add(DIVIDER);
          lReport.Add('');
        end;  //Next j
      end; //Next i
    end;

    // Compute factor scores if checked
    if ScoresBtn.Checked then
    begin
      if MatInput then
        MessageDlg('Original subject scores unavailable (matrix input.)', mtInformation, [mbOK], 0)
      else
        LSFactScores(Loadings, k, Nroots, NoCases, ColNoSelected, RowLabels, lReport);
    end;

    // Save loadings if checked
    if SaveFactBtn.Checked then
    begin
      SaveDialog1.Filter := 'Matrix File (*.mat)|*.mat;*.MAT|Any File (*.*)|*.*';
      SaveDialog1.FilterIndex := 1;
      SaveDialog1.Title := 'Save Factor Loadings';
      if SaveDialog1.Execute then
      begin
        filename := SaveDialog1.FileName;
        MatSave(Loadings,k,Nroots,means,stddevs,count,RowLabels,ColLabels,filename);
      end;
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;

    ColNoSelected := nil;
    ColLabels := nil;
    RowLabels := nil;
    stddevs := nil;
    variances := nil;
    means := nil;
    yvector := nil;
    xvector := nil;
    d2 := nil;
    b := nil;
    pcnttrace := nil;
    communality := nil;
    Eigenvector := nil;
    Loadings := nil;
    W := nil;
    V := nil;
    ainverse := nil;
    TempMat := nil;
    corrmat := nil;
    GraphFrm.Ypoints := nil;
    GraphFrm.Xpoints := nil;
  end;
end;

procedure TFactorFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      FactorList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TFactorFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < FactorList.Items.Count do
  begin
    if FactorList.Selected[i] then
    begin
      VarList.Items.Add(FactorList.Items[i]);
      FactorList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

//eigenvalues is the vector of N roots, a is the matrix of column eigenvectors, n is the order of the vector
//and matrix, factorchoice is an integer indicating the type of factor analysis, and d2 is
//a scaling weight for scaled factor analysis types
//The results are the normalized factor loadings returned in a.
procedure TFactorFrm.FACTORS(const eigenvalues, d2: DblDyneVec;
  const A: DblDyneMat; N: integer; factorchoice: integer);
{procedure TFactorFrm.FACTORS(var eigenvalues: DblDyneVec; var d2: DblDyneVec;
    var A: DblDyneMat; N: integer; factorchoice: integer); }
var
  i, j: integer;
begin
  for i := 1 to N do
    for j := 1 to N do
      if (eigenvalues[j-1] > 0) then
        A[i-1,j-1] := A[i-1,j-1] * sqrt(eigenvalues[j-1])
      else
        A[i-1,j-1] := 0.0;

  if (factorchoice = 4) or (factorchoice = 5) then
    for i := 1 to N do
      for j := 1 to N do
        if (d2[i-1] > 0) then
          A[i-1,j-1] := A[i-1,j-1] * sqrt(d2[i-1])
        else
          A[i-1,j-1] := 0.0;

  //alpha factor analysis
  if ( factorchoice = 6) then
    for i := 1 to N do
      for j := 1 to N do
        if ( eigenvalues[j-1] > 0 ) then
          A[i-1,j-1] := A[i-1,j-1] * sqrt(1.0 - d2[i-1])
        else
          A[i-1,j-1] := 0.0;
end;

// d is the vector of eigenvalues, A is the eigenvalues matrix,
// var_label is the array of variable labels and
// n is the vector and matrix order.
procedure TFactorFrm.FactReorder(const d: DblDyneVec; const A: DblDyneMat;
  const var_label: StrDyneVec; N: integer);
// procedure TFactorFrm.FactReorder(var d: DblDyneVec; var A: DblDyneMat;
//   var var_label: StrDyneVec; N: integer);
var
  i, j, k: integer;
  Temp: double;
begin
  for i := 1 to N - 1 do
  begin
    for j := i + 1 to N do
    begin
      if ( d[i-1] < d[j-1]) then
      begin
        Temp := d[i-1];   // swap eigenvectors
        d[i-1] := d[j-1];
        d[j-1] := Temp;
        for k := 1 to N do  // swap columns in iegenvector matrix
        begin
          Temp := A[k-1,i-1];
          A[k-1,i-1] := A[k-1,j-1];
          A[k-1,j-1] := Temp;
        end;
      end;
    end;
  end;
end;

procedure TFactorFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TFactorFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
  if RotateFrm = nil then
    Application.CreateForm(TRotateFrm, RotateFrm);
end;

procedure TFactorFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TFactorFrm.SortLoadings(const v: DblDyneMat; n1, n2: integer;
  const High_Factor: IntDyneVec; const A, B: DblDyneVec;
  const var_label: StrDyneVec; const Order: IntDyneVec);
var
  i, j, k, itemp: integer;
  NoInFact: IntDyneVec;
  maxval, Temp: double;
  tempstr: string;
begin
  SetLength(NoInFact, NoVariables);

  // Reorder factors in descending sequence ( left to right )
  for j := 1 to n2 - 1 do
  begin                                 // factor j
    for k := j + 1 to n2 do
    begin                            // factor k
      if ( A[j-1] < A[k-1]) then
      begin                       // variance and factors need swapping
        for i := 1 to n1 do
        begin                  // swap factors
          Temp := v[i-1,j-1];
          v[i-1,j-1] := v[i-1,k-1];
          v[i-1,k-1] := Temp;
        end;
        Temp := A[j-1];          // variance swap
        A[j-1] := A[k-1];
        A[k-1] := Temp;
      end;
    end;
  end;

  // Now select largest loading in each variable
  for j := 1 to n2 do
    NoInFact[j-1] := 0;
  for i := 1 to n1 do
  begin
    High_Factor[i-1] := 0;
    maxval := 0.0;
    for j := 1 to n2 do
    begin
      if abs(v[i-1,j-1]) > abs(maxval) then
      begin
        maxval := abs(v[i-1,j-1]);
        High_Factor[i-1] := j;
      end;
    end;
  end;

  // Now sort matrix loadings
  for i := 1 to n1 - 1 do
  begin
    for j := i + 1 to n1 do
    begin
      if (High_Factor[i-1] > High_Factor[j-1]) then
      begin
        itemp := High_Factor[i-1];
        High_Factor[i-1] := High_Factor[j-1];
        High_Factor[j-1] := itemp;
        for k := 1 to n2 do
        begin                            // loading swap
          Temp := v[i-1,k-1];
          v[i-1,k-1] := v[j-1,k-1];
          v[j-1,k-1] := Temp;
        end;
        tempstr := var_label[i-1];         // label swap
        var_label[i-1] := var_label[j-1];
        var_label[j-1] := tempstr;
        Temp := B[i-1];                    // communality swap
        B[i-1] := B[j-1];
        B[j-1] := Temp;
        itemp := order[i-1];
        order[i-1] := order[j-1];
        order[j-1] := itemp;
      end;
    end;
  end;

  NoInFact := nil;
end;

procedure TFactorFrm.VariMax(const v: DblDyneMat; n1, n2: integer;
  const RowLabels, ColLabels: StrDyneVec; const Order: IntDyneVec;
  AReport: TStrings);
//label nextone;
var
  pi: double;
  A, B, C: DblDyneVec;
  i, j, k, M, N, minuscount: integer;
  High_Factor: IntDyneVec;
  a1, b1, c1, c2, c3, c4, d1, x1, x2, Y, s1, Q, TotalPercent, t: double;
  Title: string;
begin
  pi := 3.14159265358979;
  t := n1;

  SetLength(A,NoVariables);
  SetLength(b,NoVariables);
  SetLength(C,NoVariables);
  SetLength(High_Factor,NoVariables);

  // calculate proportion of variance accounted for by each factor before rotation
  for j := 1 to n2 do
  begin
    A[j-1] := 0.0;
    for i := 1 to n1 do
      A[j-1] := A[j-1] + (v[i-1,j-1] * v[i-1,j-1]);
    A[j-1] := A[j-1] / t * 100.0;
  end;

  if PcntTrBtn.Checked then
  begin
    AReport.Add('Proportion of variance in unrotated factors');
    AReport.Add('');
    for  j := 1 to n2 do
      AReport.Add('%3d %6.3f', [j, A[j-1]]);
    AReport.Add('');
  end;

  for i := 1 to n1 do
  begin
    B[i-1] := 0.0;
    High_Factor[i-1] := 0;
  end;

  // Reflect factors 180 degrees if more negative than positive loadings
  for j := 1 to n2 do
  begin
    minuscount := 0;
    for i := 1 to n1 do
      if v[i-1,j-1] < 0 then minuscount := minuscount + 1;

    if minuscount > (n1 / 2) then
      for i := 1 to n1 do  v[i-1,j-1] := v[i-1,j-1] * -1.0;
  end;

  // normalize rows of v
  for i := 1 to n1 do
  begin
    for j := 1 to n2 do
      B[i-1] := B[i-1] + (v[i-1,j-1] * v[i-1,j-1]);
    B[i-1] := sqrt(B[i-1]);
    for j := 1 to n2 do
      v[i-1,j-1] := v[i-1,j-1] / B[i-1];
  end;

//nextone:

  repeat
    k := 0;
    for M := 1 to n2 do
    begin
      for N := M to n2 do
      begin
        if M <> N then // compute angle of rotation
        begin
          for i := 1 to n1 do
          begin
            A[i-1] := (v[i-1,M-1] * v[i-1,M-1]) - (v[i-1,N-1] * v[i-1,N-1]);
            C[i-1] := 2.0 * v[i-1,M-1] * v[i-1,N-1];
          end;

          a1 := 0.0;
          for i := 1 to n1 do a1 := a1 + A[i-1];

          b1 := 0.0;
          for i := 1 to n1 do b1 := b1 + C[i-1];

          c1 := 0.0;
          for i :=  1 to n1 do c1 := c1 + (A[i-1] * A[i-1]);

          c2 := 0.0;
          for i := 1 to n1 do c2 := c2 + (C[i-1] * C[i-1]);

          c3 := c1 - c2;

          d1 := 0.0;
          for i := 1 to n1 do d1 := d1 + A[i-1] * C[i-1];
          d1 := 2 * d1;

          x1 := d1 - 2.0 * a1 * b1 / t;
          x2 := c3 - ((a1 * a1) - (b1 * b1)) / t;
          Y := ArcTan(x1 / x2);
          if x2 < 0 then
          begin
            if x1 >= 0.0 then
              Y := Y + 2.0 * pi;
            Y := Y - pi;
          end;

          Y := Y / 4.0;

          //if (fabs(Y) >= 0.0175) // rotate pair of axes
          if abs(Y) >= 0.000001 then
          begin
            c4 := cos(Y);
            s1 := sin(Y);
            k := 1;
            for i := 1 to n1 do
            begin
              Q := v[i-1,M-1] * c4 + v[i-1,N-1] * s1;
              v[i-1,N-1] := v[i-1,N-1] * c4 - v[i-1,M-1] * s1;
              v[i-1,M-1] := Q;
            end;
          end; // if y
        end;  // if m <> n
      end; // next n
    end;  // next m
  until k <= 0;

//  if k > 0 then goto nextone;

  // denormalize rows of v
  for j := 1 to n2 do
  begin
    for i := 1 to n1 do
      v[i-1,j-1] := v[i-1,j-1] * B[i-1];
    A[j-1] := 0.0;
    for i := 1 to n1 do
      A[j-1] := A[j-1] + (v[i-1,j-1] * v[i-1,j-1]);
    A[j-1] := A[j-1] / t * 100.0;
  end;

  for i := 1 to n1 do
    B[i-1] := (B[i-1] * B[i-1]) * 100.0;

  if ComUnBtn.Checked then
  begin
    AReport.Add('');
    AReport.Add('Communality Estimates as percentages:');

    for i := 1 to n1 do
      AReport.Add('%3d %6.3f',[i,b[i-1]]);
    AReport.Add('');
  end;

  if SortBtn.Checked then
    SortLoadings(v, n1, n2, High_Factor, A, B, RowLabels, order);

  // Reflect factors 180 degrees if more negative than positive loadings
  for j := 1 to n2 do
  begin
    minuscount := 0;
    for i := 1 to n1 do
      if ( v[i-1,j-1] < 0) then  minuscount := minuscount + 1;
    if minuscount > (n1 / 2) then
      for i := 1 to n1 do v[i-1,j-1] := v[i-1,j-1] * -1.0;
  end;

  // recalculate proportion of variance accounted for by each factor
  for j := 1 to n2 do
  begin
    A[j-1] := 0.0;
    for i := 1 to n1 do
      A[j-1] := A[j-1] + (v[i-1,j-1] * v[i-1,j-1]);
    A[j-1] := A[j-1] / t * 100.0;
  end;

  // print results
  Title := 'Varimax Rotated Loadings';
  MatPrint(v, n1, n2, Title, RowLabels, ColLabels, NoCases, AReport);
  TotalPercent := 0.0;
  AReport.Add('Percent of Variation in Rotated Factors');
  for j := 1 to n2 do
  begin
    AReport.Add('Factor %3d %6.3f', [j, A[j-1]]);
    TotalPercent := TotalPercent + A[j-1];
  end;
  AReport.Add('');
  AReport.Add('Total Percent of Variance in Factors: %6.3f', [TotalPercent]);
  AReport.Add('Communalities as Percentages');
  for i := 1 to n1 do
    AReport.Add('%3d for %15s %6.3f', [i, RowLabels[i-1], b[i-1]]);
  AReport.Add('');

  AReport.Add(DIVIDER);
  AReport.Add('');

  // clean up heap
  High_Factor := nil;
  C := nil;
  B := nil;
  A := nil;
end;

procedure TFactorFrm.PROCRUST(const b: DblDyneMat; nv, nb: integer;
  const RowLabels, ColLabels: StrDyneVec; AReport: TStrings);
//label cleanup;
var
   i, j, k, na, nf, nd, nv2: integer;
   ee, p, sum : double;
   A, C, d, v, trans : DblDyneMat;
   e, f, g, means, stddevs : DblDyneVec;
   outline : string;
   Title : string;
   ColALabels : StrDyneVec ;
   filename : string;
   errorcode : boolean = false;
   count: Integer = 0;
begin
  // nv is the no. of variables, nb the number of factors in the loadings
  // matrix.
  // na is the number of factors in target matrix
  // nf is the no. of roots and vectors extracted from routine sevs
  // b is the obtained factor matrix
  // A is the target factor matrix
  // ColLabels is the set of labels for the obtained factors
  // ColALabels is the set of labels for the target factor matrix

  Title := 'Source Factor Loadings';
  MatPrint(b, nv, nb, title, RowLabels, ColLabels, NoCases, AReport);

  nd := nv;

  SetLength(A,NoVariables,NoVariables);
  SetLength(C,NoVariables,NoVariables);
  SetLength(d,NoVariables,NoVariables);
  SetLength(v,NoVariables,NoVariables);
  SetLength(trans,NoVariables,NoVariables);
  SetLength(e,NoVariables);
  SetLength(f,NoVariables);
  SetLength(g,NoVariables);
  SetLength(means,NoVariables);
  SetLength(stddevs,NoVariables);
  SetLength(ColALabels,NoVariables);

  // read target matrix into A
  OpenDialog1.Filter := 'Matrix File (*.mat)|*.mat;*.MAT|Any File (*.*)|*.*';
  OpenDialog1.FilterIndex := 1;
  OpenDialog1.Title := 'Target Matrix';
  OpenDialog1.DefaultExt := 'mat';
  if not OpenDialog1.Execute then
    exit;
  filename := OpenDialog1.FileName;
  MatRead(A, nv2, na, means, stddevs, count, RowLabels, ColALabels, filename);
  Title := 'Target Factor Loadings';
  MatPrint(A, nv2, na, Title, RowLabels, ColALabels, count, AReport);
  if nv2 <> nv then
  begin
    MessageDlg('No. of variables do not match.', mtError, [mbOK], 0);
    exit;
  end;

  // normalize matrix A by rows.
  for i := 1 to nv do
  begin
    sum := 0.0;
    for j := 1 to na do sum := sum  + (A[i-1,j-1] * A[i-1,j-1]);
    p := 1.0 / sqrt(sum);
    for j := 1 to na do A[i-1,j-1] := A[i-1,j-1] * p;
  end;

  for i := 1 to nv do // normalize matrix b by rows. Save lengths in g.
  begin
    sum := 0.0;
    for j := 1 to nb do sum  := sum + (b[i-1,j-1] * b[i-1,j-1]);
    g[i-1] := sqrt(sum);
    for j := 1 to nb do b[i-1,j-1] := b[i-1,j-1] / g[i-1];
  end;

  // compute cosines between factor axes and print results
  // get A transpose x B into C
  MatTrn(trans, A, nv, na);
  MatAxB(C, trans, B, na, nv, nv, nb, errorcode);

  // get D := C x C transpose
  MatTrn(trans, C, na, nb);
  MatAxB(d, C, trans, na, nb, nb, na, errorcode);

  // get roots and vectors of D.
  nf := SEVS(na, na, 0.0, d, v, e, f, nd); //nf is new no. of factors returned in na
  nb := nf;

  // get d := C transpose x V end;
  MatTrn(trans, C, na, nb);
  MatAxB(d, trans, v, nb, na, na, nb, errorcode);
  for j := 1 to nb do
  begin
    ee := Power(e[j-1],-1.5);
    for i := 1 to nb do d[i-1,j-1] := d[i-1,j-1] * ee;
  end;

  // get D x V' end;
  MatTrn(trans, v, na, nb);
  MatAxB(C, d, trans, nb, nb, nb, na, errorcode);
  AReport.Add('Factor Pattern Comparison:');
  Title := 'Cosines Among Factor Axis';
  MatPrint(C, na, nb, Title, ColALabels, ColLabels, NoCases, AReport);

  // get B x C
  for  i := 1 to nv do
  begin
    for j := 1 to na do
    begin
      d[i-1,j-1] := 0.0;
      for k := 1 to nb do d[i-1,j-1] := d[i-1,j-1] + (b[i-1,k-1] * C[j-1,k-1]);
    end;
  end;
  for i := 1 to nv do
    for j := 1 to na do
      v[i-1,j-1] := d[i-1,j-1] * g[i-1];
  Title := 'Factors Rotated to Conguence With Target';
  MatPrint(v, nv, na, Title, RowLabels, ColALabels, NoCases, AReport);
  for i := 1 to nv do
  begin
    sum := 0.0; // Get column products of the two matrices
    for j := 1 to na do
      sum := sum + A[i-1,j-1] * d[i-1,j-1];
    g[i-1] := sum;
  end;

  AReport.Add('Cosines (Correlations) Between Corresponding Variables');
  AReport.Add('');
  for i := 1 to nv do
    AReport.Add('%-10s %8.6f',[RowLabels[i-1],g[i-1]]);

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  ColALabels := nil;
  stddevs := nil;
  means := nil;
  g := nil;
  f := nil;
  e := nil;
  trans := nil;
  v := nil;
  d := nil;
  C := nil;
  A := nil;
end;

procedure TFactorFrm.LSFactScores(const F: DblDyneMat; NoVars, NoFacts,
  NCases: integer; const ColNoSelected: IntDyneVec; const RowLabels: StrDyneVec;
  AReport: TStrings);
var
   R, Rinv, Beta : DblDyneMat;
   Means, Variances, StdDevs : DblDyneVec;
   Score, Sigma, x, z : double;
   i, j, k, m, col, colno, oldnovars : integer;
   ColLabels : StrDyneVec;
   outline : string;
   Title : string;
   errcode : boolean = false;
   //errorcode: Boolean = false;

begin
  SetLength(R,NoVariables+1,NoVariables+1);
  SetLength(Rinv,NoVariables+1,NoVariables+1);
  SetLength(Beta,NoVariables,NoVariables);
  SetLength(Means,NoVariables);
  SetLength(Variances,NoVariables);
  SetLength(StdDevs,NoVariables);
  SetLength(ColLabels,NoVariables);

  // setup labels and print routine
  for i := 1 to NoFacts do
  begin
    outline := format('Factor %d',[i]);
    ColLabels[i-1] := outline;
  end;
  AReport.Add('');
  AReport.Add('SUBJECT FACTOR SCORE RESULTS');

  // Obtain correlations
  Correlations(NoVars, ColNoSelected, R, Means, Variances, StdDevs, errcode, NCases);
  for i := 1 to NoVars do
    for j := 1 to NoVars do
      Rinv[i-1,j-1] := R[i-1,j-1];

  // Get inverse of the correlation matrix
  // Note - offset by one for inverse routine
  SVDinverse(Rinv, NoVars);

  // Multiply the inverse matrix times the factor loadings matrix
  MatAxB(Beta,Rinv,F,NoVars,NoVars,NoVars,NoFacts,errcode);
  Title := 'Regression Coefficients';
  MatPrint(Beta, NoVars, NoFacts, Title, RowLabels, ColLabels, NCases, AReport);

  // Calculate standard errors of factor scores
  AReport.Add('');
  AReport.Add('Standard Error of Factor Scores:');
  for i := 1 to NoFacts do
  begin
    Sigma := 0.0;
    for j := 1 to NoVars do
    begin
      Sigma := Sigma + (Beta[j-1,i-1] * F[j-1,i-1]);
    end;
    Sigma := sqrt(Sigma);
    AReport.Add('%-10s %6.3f', [ColLabels[i-1], Sigma]);
  end;
  AReport.Add('');

  //Calculate subject factor scores and place in the data grid
  // place labels in new grid columns and define
  oldnovars := NoVariables;
  for i := 1 to NoFacts do
  begin
    col := NoVariables + 1;
    outline := format('Fact.%d Scr.',[i]);
    DictionaryFrm.NewVar(col);
    DictionaryFrm.DictGrid.Cells[1,col] := outline;
    OS3MainFrm.DataGrid.Cells[col,0] := outline;
  end;

  for i := 1 to NoCases do // subject
  begin
    if (not GoodRecord(i,NoVars,ColNoSelected)) then
      continue;
    for j := 1 to NoFacts do // variables
    begin
      Score := 0.0;
      for k := 1 to NoVars do
      begin
        m := ColNoSelected[k-1];
        x := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[m,i]));
        z := (x - Means[k-1]) / StdDevs[k-1];
        Score := Score + (z * Beta[k-1,j-1]);
      end;
      colno := oldnovars + j;
      outline := format('%6.4f',[Score]);
      OS3MainFrm.DataGrid.Cells[colno,i] := outline;
    end;
  end;

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  ColLabels := nil;
  StdDevs := nil;
  Variances := nil;
  Means := nil;
  Beta := nil;
  Rinv := nil;
  R := nil;
end;

procedure TFactorFrm.QuartiMax(const v: DblDyneMat; n1, n2: integer;
  const RowLabels, ColLabels: StrDyneVec; const Order: IntDyneVec;
  AReport: TStrings);
var
  i, j, M, N, minuscount, NoIters : integer;
  A, b, C : DblDyneVec;
  High_Factor : IntDyneVec;
  c4, s1, Q, NewQ, TotalPercent, t : double;
  theta, tan4theta, ssqrp, ssqrj, prodjp, numerator, denominator : double;
  done : boolean;
  Title : string;
begin
  SetLength(A,NoVariables);
  SetLength(b,NoVariables);
  SetLength(C,NoVariables);
  SetLength(High_Factor,NoVariables);
  NoIters := 0;

  // calculate proportion of variance accounted for by each factor
  //before rotation
  t := n1;
  for j := 1 to n2 do
  begin
    A[j-1] := 0.0;
    for i := 1 to n1 do
      A[j-1] := A[j-1] + (v[i-1,j-1] * v[i-1,j-1]);
    A[j-1] := A[j-1] / t * 100.0;
  end;

  if PcntTrBtn.Checked then
  begin
    AReport.Add('Proportion of variance in unrotated factors');
    AReport.Add('');
    for j := 1 to n2 do
      AReport.Add('%3d %6.3f',[j, A[j-1]]);
    AReport.Add('');
  end;

  for i := 0 to n1-1 do
  begin
    b[i] := 0.0;
    High_Factor[i] := 0;
  end;

  // Reflect factors 180 degrees if more negative than positive loadings
   for j := 0 to n2-1 do
   begin
     minuscount := 0;
     for i := 0 to n1 - 1 do
       if  v[i,j] < 0 then  minuscount := minuscount + 1;
     if minuscount > n1 / 2 then
       for i := 0 to n1-1 do v[i,j] := v[i,j] * -1.0;
   end;

   t := n1;
   // normalize rows of v
   for i := 0 to n1-1 do
   begin
     for j := 0 to n2-1 do
       b[i] := b[i] + (v[i,j] * v[i,j]);
     b[i] := sqrt(b[i]);
   end;

   done := false;
   Q := 0.0;
   for i := 1 to n1 do
     for j := 1 to n2 do
       Q := Q + Power(v[i-1,j-1],4.0);

   while (not done) do
   begin
     for M := 1 to n2-1 do
     begin
       for N := M + 1 to n2 do
       begin
         // compute angle of rotation for this pair of factors
         numerator := 0.0;
         denominator := 0.0;
         for i := 1 to n1 do
         begin
           ssqrp := v[i-1,M-1] * v[i-1,M-1];
           ssqrj := v[i-1,N-1] * v[i-1,N-1];
           prodjp := 2.0 * v[i-1,M-1] * v[i-1,N-1];
           numerator := numerator + prodjp * (ssqrp - ssqrj);
           denominator := denominator + (Power(ssqrp - ssqrj,2.0) - Power(prodjp,2));
         end;
         tan4theta := (2.0 * numerator) / denominator;
         theta := ArcTan(tan4theta) / 4.0;
         c4 := cos(theta);
         s1 := sin(theta);
         // transform factor loadings
         for i := 1 to n1 do
         begin
           v[i-1,M-1] := v[i-1,M-1] * c4 + v[i-1,N-1] * s1;
           v[i-1,N-1] := v[i-1,N-1] * c4 - v[i-1,M-1] * s1;
         end;
       end; // next n
     end;  // next m
     NewQ := 0.0;
     for i := 1 to n1 do
       for j := 1 to n2 do
         NewQ := NewQ + Power(v[i-1,j-1],4.0);
     if (abs(Q - NewQ) < 0.00001) then done := true;
     if (n2 < 3) then done := true;
     if (not done) then
     begin
       NoIters := NoIters + 1;
       if (NoIters > 25) then
       begin
         AReport.Add('Quartimax failed to converge in 25 iterations.');
         done := true;
       end;
       Q := NewQ;
     end;
   end; // while not done
{
  // denormalize rows of v
  for ( j := 0; j < n2; j++)
  begin
       for ( i := 0; i < n1; i++) v[i,j] *= b[i];
       A[j] := 0.0;
       for ( i := 0; i < n1; i++) A[j] += (v[i,j] * v[i,j]);
       A[j] := A[j] / t * 100.0;
  end;
}
  for i :=  1 to n1 do
    b[i-1] := (b[i-1] * b[i-1]) * 100.0;

  if SortBtn.Checked then
    SortLoadings(v, n1, n2, High_Factor, A, b, RowLabels, order);

  // Reflect factors 180 degrees if more negative than positive loadings
  for j := 1 to n2 do
  begin
    minuscount := 0;
    for i := 1 to n1 do
      if v[i-1,j-1] < 0 then minuscount := minuscount  + 1;
    if minuscount > n1 / 2 then
      for i := 1 to n1 do
        v[i-1,j-1] := v[i-1,j-1] * -1.0;
  end;

  // recalculate proportion of variance accounted for by each factor
  for j := 0 to n2-1 do
  begin
    A[j] := 0.0;
    for i := 0 to n1-1 do
      A[j] := A[j] + (v[i,j] * v[i,j]);
    A[j] := A[j] / t * 100.0;
  end;

  // print results
  TotalPercent := 0.0;
  Title := 'Quartimax Rotated Loadings';
  MatPrint(v, n1, n2, Title, RowLabels, ColLabels, NoCases, AReport);
  AReport.Add('Percent of Variation in Rotated Factors');
  for j := 0 to n2-1 do
  begin
    AReport.Add('Factor %3d %6.3f', [j+1, A[j]]);
    TotalPercent := TotalPercent + A[j];
  end;

  if ComUnBtn.Checked then
  begin
    AReport.Add('');
    AReport.Add('Total Percent of Variance in Factors: %6.3f', [TotalPercent]);
    AReport.Add('Communalities as Percentages');
    for i := 1 to n1 do
      AReport.Add('%3d for %s %6.3f', [i, RowLabels[i-1], b[i-1]]);
    AReport.Add('');
  end;

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');

  High_Factor := nil;
  C := nil;
  b := nil;
  A := nil;
end;

procedure TFactorFrm.ManualRotate(const v: DblDyneMat; n1, n2: integer;
  const RowLabels, ColLabels: StrDyneVec; const order: IntDyneVec;
  AReport: TStrings);
var
  cols, rows: integer;
  Title: string;
  i, j: integer;
begin
// Passed: Loadings, k, Nroots, RowLabels, ColLabels, ColNoSelected,self
  SetLength(RotateFrm.Loadings, NoVariables, NoVariables);
  RotateFrm.Loadings := v;
  RotateFrm.NoVars := n1;
  RotateFrm.NoRoots := n2;
  RotateFrm.RowLabels := RowLabels;
  RotateFrm.ColLabels := ColLabels;
  RotateFrm.Order := order;
  RotateFrm.ShowModal;
  for i := 1 to n1 do
    for j := 1 to n2 do v[i-1,j-1] := RotateFrm.Loadings[i-1,j-1];
  RotateFrm.Loadings := nil;

  cols := n2; // no. of roots
  rows := n1; // no. of variables
  AReport. Add('Rotated Factor Loadings');
  Title := 'FACTORS';
  MatPrint(v, rows, cols, Title, RowLabels, ColLabels, NoCases, AReport);

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('');
end;

procedure TFactorFrm.UpdateBtnStates;
begin
  InBtn.Enabled := AnySelected(VarList);
  OutBtn.Enabled := AnySelected(FactorList);
end;

function TFactorFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
  x: Double;
begin
  Result := false;

  if MinRootEdit.Text = '' then
  begin
    AControl := MinRootEdit;
    AMsg := 'Value required.';
    exit;
  end;
  if not TryStrToFloat(MinRootEdit.Text, x) then
  begin
    AControl := MinRootEdit;
    AMsg := 'No valid number.';
    exit;
  end;

  if MaxItersEdit.Text = '' then
  begin
    AControl := MaxItersEdit;
    AMsg := 'Value required.';
    exit;
  end;
  if not (TryStrToInt(MaxItersEdit.Text, n) and (n > 0)) then
  begin
    AControl := MaxItersEdit;
    AMsg := 'No valid number (> 0)';
    exit;
  end;

  // MaxFactorsEdit can be empty, case is handled.
  if (MaxFactorsEdit.Text <> '') and not (TryStrToInt(MaxFactorsEdit.Text, n) and (n > 0)) then
  begin
    AControl := MaxFactorsEdit;
    AMsg := 'No valid number (> 0)';
    exit;
  end;

  Result := true;
end;

procedure TFactorFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I factorunit.lrs}

end.

