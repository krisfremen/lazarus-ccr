unit LatinSqrsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  LatinSpecsUnit, MainUnit, Globals, FunctionsLib, OutputUnit, GraphLib,
  MatrixLib, ContextHelpUnit;

type

  { TLatinSqrsFrm }

  TLatinSqrsFrm = class(TForm)
    ComputeBtn: TButton;
    HelpBtn: TButton;
    CloseBtn: TButton;
    Plan: TRadioGroup;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    { private declarations }
    function CheckDataCol(ACol: Integer): boolean;
    function GetRange(ACol: Integer; out ARange, AMin, AMax: Integer): boolean;
    procedure Plan1;
    procedure Plan2;
    procedure Plan3;
    procedure Plan4;
    procedure Plan5;
    procedure Plan6;
    procedure Plan7;
//       procedure Plan8;
    procedure Plan9;

  public
    { public declarations }
  end; 

var
  LatinSqrsFrm: TLatinSqrsFrm;

implementation

uses
  Math, Utils;

const
  NO_VALID_NUMBER_ERROR = 'No valid number in row %d of variable "%s"';

{ TLatinSqrsFrm }

function TLatinSqrsFrm.CheckDataCol(ACol: Integer): Boolean;
var
  i: Integer;
  value: Double;
begin
  Result := false;
  for i := 1 to NoCases do
    if not TryStrToFloat(OS3MainFrm.DataGrid.Cells[ACol, i], value) then
    begin
      ErrorMsg(NO_VALID_NUMBER_ERROR, [i, OS3MainFrm.DataGrid.Cells[ACol, 0]]);
      exit;
    end;
  Result := true;
end;

procedure TLatinSqrsFrm.ComputeBtnClick(Sender: TObject);
var
  btn: Integer;
begin
  btn := Plan.ItemIndex + 1;
  case btn of
    1: Plan1;
    2: Plan2;
    3: Plan3;
    4: Plan4;
    5: Plan5;
    6: Plan6;
    7: Plan7;
    8: Plan9;
  end;
end;

procedure TLatinSqrsFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
end;

procedure TLatinSqrsFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if LatinSpecsFrm = nil then
    Application.CreateForm(TLatinSpecsFrm, LatinSpecsFrm);
end;

function TLatinSqrsFrm.GetRange(ACol: Integer; out ARange, AMin, AMax: Integer): boolean;
var
  i: Integer;
  mn, mx, value: Double;
begin
  Result := true;
  mn := MaxInt;
  mx := -MaxInt;
  for i := 1 to NoCases do
  begin
    if TryStrToFloat(OS3MainFrm.DataGrid.Cells[ACol, i], value) then
    begin
      if value < mn then mn := value;
      if value > mx then mx := value;
    end else
    begin
      ErrorMsg(NO_VALID_NUMBER_ERROR, [i, OS3MainFrm.DataGrid.Cells[ACol, 0]]);
      Result := false;
      exit;
    end;
  end;
  AMin := round(mn);
  AMax := round(mx);
  ARange := AMax - AMin + 1;
end;

procedure TLatinSqrsFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TLatinSqrsFrm.Plan1;
var
  n: integer; // no. of subjects per cell
  Acol, Bcol, Ccol, DataCol: integer; // variable columns in grid
  FactorA: string;
  FactorB: string;
  FactorC: string;
  DataVar: string;
  cellstring: string;
  i, j, rangeA, rangeB, rangeC, mn, mx: integer;
  cellcnts: IntDyneMat;
  celltotals: DblDyneMat;
  Ctotals: DblDyneVec;
  design: StrDyneMat;
  G, term1, term2, term3, term4, term5, term6, sumxsqr: double;
  sumAsqr, sumBsqr, sumCsqr, sumABCsqr, SSA, SSB, SSC: double;
  SSwithin, SSres, SStotal: double;
  MSa, MSb, MSc, MSres, MSwithin: double;
  data, GrandMean: double;
  p, row, col, slice: integer;
  dfa, dfb, dfc, dfres, dfwithin, dftotal, fa, fb, fc, fpartial: double;
  proba, probb, probc, probpartial: double;
  lReport: TStrings;

begin
  LatinSpecsFrm.PrepareForPlan(1);
  if LatinSpecsFrm.ShowModal <> mrOK then
    exit;

  n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
  FactorA := LatinSpecsFrm.ACodeEdit.Text;
  FactorB := LatinSpecsFrm.BCodeEdit.Text;
  FactorC := LatinSpecsFrm.CCodeEdit.Text;
  DataVar := LatinSpecsFrm.DepVarEdit.Text;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = FactorA) then ACol := i;
    if (cellstring = FactorB) then BCol := i;
    if (cellstring = FactorC) then Ccol := i;
    if (cellstring = DataVar) then DataCol := i;
  end;

  // determine no. of levels in A, B and C
  if not GetRange(ACol, rangeA, mn, mx) then exit;
  if not GetRange(BCol, rangeB, mn, mx) then exit;
  if not GetRange(CCol, rangeC, mn, mx) then exit;
  if not CheckDataCol(Datacol) then exit;

  // check for squareness
  if  (rangeA <> rangeB) or (rangeA <> rangeC) or (rangeB <> rangeC) then
  begin
    ErrorMsg('In a Latin square the range of values should all be equal.');
    exit;
  end;
  p := rangeA;

  // set up an array for cell counts and for cell sums and marginal sums
  SetLength(cellcnts, rangeA+1, rangeB+1);
  SetLength(celltotals, rangeA+1, rangeB+1);
  SetLength(Ctotals, rangeC+1);
  SetLength(Design, rangeA, rangeB);

  // initialize arrays and values
  for i := 0 to rangeA do
    for j := 0 to rangeB do
    begin
      cellcnts[i,j] := 0;
      celltotals[i,j] := 0.0;
    end;
  for i := 0 to rangeC-1 do
    Ctotals[i] := 0;

  G := 0.0;
  sumxsqr := 0.0;
  sumAsqr := 0.0;
  sumBsqr := 0.0;
  sumCsqr := 0.0;
  sumABCsqr := 0.0;
  term1 := 0.0;
  term2 := 0.0;
  term3 := 0.0;
  term4 := 0.0;
  term5 := 0.0;
  term6 := 0.0;
  GrandMean := 0.0;

  //  Read in the data
  for i := 1 to NoCases do
  begin
    row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
    col := Round(StrTofloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
    slice := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i]));
    data := StrToFloat(OS3MainFrm.DataGrid.Cells[DataCol,i]);
    cellcnts[row-1,col-1] := cellcnts[row-1,col-1] + 1;
    celltotals[row-1,col-1] := celltotals[row-1,col-1] + data;
    Ctotals[slice-1] := Ctotals[slice-1] + data;
    sumxsqr := sumxsqr + (data * data);
    GrandMean := GrandMean + data;
  end;

  // check for equal cell counts
  for i := 0 to p-1 do
    for j := 0 to p-1 do
    begin
      if cellcnts[i,j] <> n then
      begin
        ErrorMsg('Cell sizes are not equal.');
        exit;
      end;
    end;

  // calculate values
  for i := 0 to p - 1 do // get row and column sums
  begin
    for j := 0 to p-1 do
    begin
      celltotals[i,p] := celltotals[i,p] + celltotals[i,j];
      celltotals[p,j] := celltotals[p,j] + celltotals[i,j];
      sumABCsqr := sumABCsqr + (celltotals[i,j] * celltotals[i,j]);
    end;
  end;

  for i := 0 to p-1 do
    G := G + Ctotals[i];

  term1 := (G * G) / (n * p * p);
  term2 := sumxsqr;

  for i := 0 to p-1 do // sum of squared A's
    sumAsqr := sumAsqr + (celltotals[i,p] * celltotals[i,p]);
  for i := 0 to p-1 do // sum of squared B's
    sumBsqr := sumBsqr + (celltotals[p,i] * celltotals[p,i]);
  for i := 0 to p-1 do // sum of squared C's
    sumCsqr := sumCsqr + (Ctotals[i] * Ctotals[i]);

  term3 := sumAsqr / (n * p);
  term4 := sumBsqr / (n * p);
  term5 := sumCsqr / (n * p);
  term6 := sumABCsqr / n;
  SSA := term3 - term1;
  SSB := term4 - term1;
  SSC := term5 - term1;
  SSwithin := term2 - term6;
  SSres := term6 - term3 - term4 - term5 + 2 * term1;
  SStotal := SSA + SSB + SSC + SSres + SSwithin;
  dfa := p-1;
  dfb := p-1;
  dfc := p-1;
  dfres := (p-1) * (p-2);
  dfwithin := (p * p) * (n - 1);
  dftotal := n * p * p - 1;
  MSa := SSA / dfa;
  MSb := SSB / dfb;
  MSc := SSC / dfc;
  MSres := SSres / dfres;
  MSwithin := SSwithin / dfwithin;
  fa := MSa / MSwithin;
  fb := MSb / MSwithin;
  fc := MSc / MSwithin;
  fpartial := MSres / MSwithin;
  proba := probf(fa,dfa,dfwithin);
  probb := probf(fb,dfb,dfwithin);
  probc := probf(fc,dfc,dfwithin);
  probpartial := probf(fpartial,dfres,dfwithin);

  // show ANOVA table results
  lReport := TStringList.Create;
  try
    lReport.Add('LATIN SQUARE ANALYSIS Plan 1 Results');
    lReport.Add('');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Source         SS        DF        MS        F      Prob.>F');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Factor A  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSA, dfa, MSa, fa, proba]);
    lReport.Add('Factor B  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSB, dfb, MSb, fb, probb]);
    lReport.Add('Factor C  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSC, dfc, MSc, fc, probc]);
    lReport.Add('Residual  %9.3f %9.0f %9.3f %9.3f %9.3f',[SSres, dfres, MSres, fpartial, probpartial]);
    lReport.Add('Within    %9.3f %9.0f %9.3f', [SSwithin,  dfwithin,  MSwithin]);
    lReport.Add('Total     %9.3f %9.0f', [SStotal, dftotal]);
    lReport.Add('-----------------------------------------------------------');

    // show design
    lReport.Add('');
    lReport.Add('Experimental Design');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);
    cellstring := Format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format(' %3d ',[i]);
    lReport.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);
    lReport.Add('%10s', [FactorA]);
    for i := 1 to NoCases do
    begin
      row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
      col := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
      slice := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i]));
      Design[row-1, col-1] := 'C' + IntToStr(slice);
    end;
    for i := 0 to p - 1 do
    begin
      cellstring := Format('   %3d    ',[i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format('%5s', [Design[i,j]]);
      lReport.Add(cellstring);
    end;
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    // show table cell means
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        celltotals[i,j] := celltotals[i,j] / n;
    for i := 0 to p-1 do
    begin
      celltotals[i,p] := celltotals[i,p] / (p * n);
      celltotals[p,i] := celltotals[p,i] / (p * n);
    end;
    GrandMean := GrandMean / (p * p * n);
    for i := 0 to p-1 do
      Ctotals[i] := Ctotals[i] / (p * n);

    lReport.Add('');
    lReport.Add('');
    lReport.Add('Cell means and totals');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    cellstring := format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    cellstring := Format('%10s', [FactorA]);
    lReport.Add(cellstring);
    for i := 0 to p-1 do
    begin
      cellstring := Format('   %3d    ', [i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format(' %8.3f ', [celltotals[i,j]]);
      cellstring := cellstring + Format(' %8.3f ', [celltotals[i,p]]);
      lReport.Add(cellstring);
    end;
    cellstring := 'Total     ';
    for j := 0 to p-1 do
      cellstring := cellstring + Format(' %8.3f ', [celltotals[p,j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    // show category means
    lReport.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    cellstring := Format('%10s', [FactorC]);
    for i := 1 to p do
      cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Ctotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellString);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    DisplayReport(lReport);
  finally
    lReport.Free;

    Design := nil;
    Ctotals := nil;
    celltotals := nil;
    cellcnts := nil;
  end;
end;

procedure TLatinSqrsFrm.Plan2;
var
  n: integer; // no. of subjects per cell
  Acol, Bcol, Ccol, Dcol, DataCol: integer; // variable columns in grid
  FactorA: string;
  FactorB: string;
  FactorC: string;
  FactorD: string;
  DataVar: string;
  cellstring: string;
  i, j, k: integer;
  rangeA, rangeB, rangeC, rangeD: integer;
  mn, mx, minD: Integer;
  cellcnts: IntDyneCube;
  celltotals: DblDyneCube;
  Ctotals: DblDyneVec;
  design: StrDyneMat;
  G, term1, term2, term3, term4, term5, term6, term7, term8: double;
  term9, sumxsqr: double;
  sumAsqr, sumBsqr, sumCsqr, sumDsqr, SSA, SSB, SSC, SSD: double;
  sumADsqr, sumBDsqr, sumCDsqr: double;
  ADmat, BDmat, CDmat: DblDyneMat;
  SSAD, SSBD, SSCD, SSwithin, SSres, SStotal: double;
  MSa, MSb, MSc, MSd, MSAD, MSBD, MSCD, MSres, MSwithin: double;
  data, GrandMean: double;
  p, row, col, slice, block: integer;
  dfa, dfb, dfc, dfres, dfwithin, dftotal, fa, fb, fc, fpartial: double;
  dfd, fd, fad, fbd, fcd, dfad, dfbd, dfcd: double;
  proba, probb, probc, probd, probpartial: double;
  probad, probbd, probcd: double;
  lReport: TStrings;

begin
  LatinSpecsFrm.PrepareForPlan(2);
  if LatinSpecsFrm.ShowModal <> mrOK then
    exit;

  n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
  FactorA := LatinSpecsFrm.ACodeEdit.Text;
  FactorB := LatinSpecsFrm.BCodeEdit.Text;
  FactorC := LatinSpecsFrm.CCodeEdit.Text;
  FactorD := LatinSpecsFrm.DCodeEdit.Text;
  DataVar := LatinSpecsFrm.DepVarEdit.Text;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = FactorA) then ACol := i;
    if (cellstring = FactorB) then BCol := i;
    if (cellstring = FactorC) then Ccol := i;
    if (cellstring = FactorD) then Dcol := i;
    if (cellstring = DataVar) then DataCol := i;
  end;

  // determine no. of levels in A, B and C
  if not GetRange(ACol, rangeA, mn, mx) then exit;
  if not GetRange(BCol, rangeB, mn, mx) then exit;
  if not GetRange(CCol, rangeC, mn, mx) then exit;
  if not GetRange(DCol, rangeD, mn, mx) then exit;
  if not CheckDataCol(DataCol) then exit;
  minD := mn;
  p := rangeA;

  // check for squareness
  if (rangeA <> rangeB) or (rangeA <> rangeC) or (rangeB <> rangeC) then
  begin
    ErrorMsg('In a Latin square the range of values should all be equal.');
    exit;
  end;

  // set up an array for cell counts and for cell sums and marginal sums
  SetLength(cellcnts, rangeA+1, rangeB+1, rangeD+1);
  SetLength(celltotals, rangeA+1, rangeB+1, rangeD+1);
  SetLength(ADmat, rangeA+1, rangeD+1);
  SetLength(BDmat, rangeB+1, rangeD+1);
  SetLength(CDmat, rangeC+1, rangeD+1);
  SetLength(Ctotals, rangeC+1);
  SetLength(Design, rangeA, rangeB);

  // initialize arrays and values
  for i := 0 to rangeA do
    for j := 0 to rangeB do
      for k := 0 to rangeD do
      begin
        cellcnts[i, j, k] := 0;
        celltotals[i, j, k] := 0.0;
      end;
  for i := 0 to rangeA do
    for j := 0 to rangeD do
      ADmat[i,j] := 0.0;
  for i := 0 to rangeB do
    for j := 0 to rangeD do
      BDmat[i,j] := 0.0;
  for i := 0 to rangeC do
    for j := 0 to rangeD do
      CDmat[i,j] := 0.0;
  for i := 0 to rangeC-1 do
    Ctotals[i] := 0;
  G := 0.0;
  sumxsqr := 0.0;
  sumAsqr := 0.0;
  sumBsqr := 0.0;
  sumCsqr := 0.0;
  sumDsqr := 0.0;
  sumADsqr := 0.0;
  sumBDsqr := 0.0;
  sumCDsqr := 0.0;
  term1 := 0.0;
  term2 := 0.0;
  term3 := 0.0;
  term4 := 0.0;
  term5 := 0.0;
  term6 := 0.0;
  term7 := 0.0;
  term8 := 0.0;
  term9 := 0.0;
  GrandMean := 0.0;
  SSwithin := 0.0;

  //  Read in the data
  for i := 1 to NoCases do
  begin
    row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
    col := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
    slice := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i]));
    block := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Dcol,i]));
    data := StrToFloat(OS3MainFrm.DataGrid.Cells[DataCol,i]);
    cellcnts[row-1,col-1,block-1] := cellcnts[row-1,col-1,block-1] + 1;
    celltotals[row-1,col-1,block-1] := celltotals[row-1,col-1,block-1] + data;
    ADmat[row-1,block-1] := ADmat[row-1,block-1] + data;
    BDmat[col-1,block-1] := BDmat[col-1,block-1] + data;
    CDmat[slice-1,block-1] := CDmat[slice-1,block-1] + data;
    Ctotals[slice-1] := Ctotals[slice-1] + data;
    sumxsqr := sumxsqr + (data * data);
    GrandMean := GrandMean + data;
  end;

  // check for equal cell counts
  for i := 0 to p-1 do
    for j := 0 to p-1 do
      for k := 0 to rangeD - 1 do
        if cellcnts[i,j,k] <> n then
        begin
          ErrorMsg('Cell sizes are not equal.');
          exit;
        end;

  // calculate values
  for i := 0 to p - 1 do // get row, column and block sums
    for j := 0 to p-1 do
      for k := 0 to rangeD - 1 do
      begin
        celltotals[i,p,k] := celltotals[i,p,k] + celltotals[i,j,k];
        celltotals[p,j,k] := celltotals[p,j,k] + celltotals[i,j,k];
        celltotals[i,j,rangeD] :=celltotals[i,j,rangeD] + celltotals[i,j,k];
      end;

  // get interaction AD
  for i := 0 to rangeA-1 do
    for j := 0 to rangeD-1 do
    begin
      sumADsqr := sumADsqr + (ADmat[i,j] * ADmat[i,j]);
      ADmat[i,rangeD] := ADmat[i,rangeD] + ADmat[i,j];
      ADmat[rangeA,j] := ADmat[rangeA,j] + ADmat[i,j];
    end;
  for i := 0 to rangeA-1 do
    sumAsqr := sumAsqr + (ADmat[i,rangeD] * ADmat[i,rangeD]);
  for i := 0 to rangeD-1 do
    sumDsqr := sumDsqr + (ADmat[rangeA,i] * ADmat[rangeA,i]);

  // get interaction BD
  for i := 0 to rangeB-1 do
    for j := 0 to rangeD-1 do
    begin
      sumBDsqr := sumBDsqr + (BDmat[i,j] * BDmat[i,j]);
      BDmat[i,rangeD] := BDmat[i,rangeD] + BDmat[i,j];
      BDmat[rangeB,j] := BDmat[rangeB,j] + BDmat[i,j];
    end;
  for i := 0 to rangeB-1 do
    sumBsqr := sumBsqr + (BDmat[i,rangeD] * BDmat[i,rangeD]);

  // get interaction CD
  for i := 0 to rangeC-1 do
    for j := 0 to rangeD-1 do
    begin
      sumCDsqr := sumCDsqr + (CDmat[i,j] * CDmat[i,j]);
      CDmat[i,rangeD] := CDmat[i,rangeD] + CDmat[i,j];
      CDmat[rangeC,j] := CDmat[rangeC,j] + CDmat[i,j];
    end;
  for i := 0 to rangeC-1 do
    sumCsqr := sumCsqr + (CDmat[i,rangeD] * CDmat[i,rangeD]);

  G := GrandMean;
  term1 := (G * G) / (n * p * p * rangeD);
  term2 := sumxsqr;
  term3 := sumAsqr / (n * p * rangeD);
  term4 := sumBsqr / (n * p * rangeD);
  term5 := sumCsqr / (n * p * rangeD);
  term6 := sumADsqr / (n * p);
  term7 := SumBDsqr / (n * p);
  term8 := SumCDsqr / (n * p);
  term9 := sumDsqr / (n * p * p);
  SSA := term3 - term1;
  SSD := term9 - term1;
  SSAD := term6 - term3 - term9 + term1;
  SSB := term4 - term1;
  SSBD := term7 - term4 - term9 + term1;
  SSC := term5 - term1;
  SSCD := term8 - term5 - term9 + term1;

  // get ss within
  for i := 0 to rangeA - 1 do
    for j := 0 to rangeB - 1 do
      for k := 0 to rangeD - 1 do
        SSwithin := SSwithin + (celltotals[i,j,k] * celltotals[i,j,k]);
  SSwithin := sumXsqr - (SSwithin / n);

  // get SS residual
  SStotal := sumXsqr - term1;
  SSres := SStotal - SSA - SSB - SSC - SSD - SSAD - SSBD - SSCD - SSwithin;
  dfa := p-1;
  dfb := p-1;
  dfc := p-1;
  dfd := rangeD - 1;
  dfad := (p-1) * (rangeD - 1);
  dfbd := dfad;
  dfcd := dfad;
  dfres := rangeD * (p-1) * (p-2);
  dfwithin := (p * p) * rangeD * (n - 1);
  dftotal := n * p * p * rangeD - 1;
  MSa := SSA / dfa;
  MSb := SSB / dfb;
  MSc := SSC / dfc;
  MSd := SSD / dfd;
  MSad := SSAD / dfad;
  MSbd := SSBD / dfbd;
  MScd := SSCD / dfcd;
  MSres := SSres / dfres;
  MSwithin := SSwithin / dfwithin;
  fa := MSa / MSwithin;
  fb := MSb / MSwithin;
  fc := MSc / MSwithin;
  fd := MSd / MSwithin;
  fad := MSad / MSwithin;
  fbd := MSbd / MSwithin;
  fcd := MScd / MSwithin;
  fpartial := MSres / MSwithin;
  proba := ProbF(fa, dfa, dfwithin);
  probb := ProbF(fb, dfb, dfwithin);
  probc := ProbF(fc, dfc, dfwithin);
  probd := ProbF(fd, dfd, dfwithin);
  probad := ProbF(fad, dfad, dfwithin);
  probbd := ProbF(fbd, dfbd, dfwithin);
  probcd := ProbF(fcd, dfcd, dfwithin);
  probpartial := ProbF(fpartial, dfres, dfwithin);

  // show ANOVA table results
  lReport := TStringList.Create;
  try
    lReport.Add('');
    lReport.Add('LATIN SQUARE ANALYSIS Plan 2 Results');
    lReport.Add('');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Source         SS        DF        MS        F      Prob.>F');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Factor A  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSA, dfa, MSa, fa, proba]);
    lReport.Add('Factor B  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSB, dfb, MSb, fb, probb]);
    lReport.Add('Factor C  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSC, dfc, MSc, fc, probc]);
    lReport.Add('Factor D  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSD, dfd, MSd, fd, probd]);
    lReport.Add('A x D     %9.3f %9.0f %9.3f %9.3f %9.3f', [SSAD, dfad, MSad, fad, probad]);
    lReport.Add('B x D     %9.3f %9.0f %9.3f %9.3f %9.3f', [SSBD, dfbd, MSbd, fbd, probbd]);
    lReport.Add('C x D     %9.3f %9.0f %9.3f %9.3f %9.3f', [SSCD, dfcd, MScd, fcd, probcd]);
    lReport.Add('Residual  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSres, dfres, MSres, fpartial, probpartial]);
    lReport.Add('Within    %9.3f %9.0f %9.3f', [SSwithin,  dfwithin,  MSwithin]);
    lReport.Add('Total     %9.3f %9.0f', [SStotal, dftotal]);
    lReport.Add('-----------------------------------------------------------');

    // show design for each block
    for k := 0 to rangeD - 1 do
    begin
      lReport.Add('');
      lReport.Add('Experimental Design for block %d', [k+1]);

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '-----';
      lReport.Add(cellstring);

      cellstring := Format('%10s', [FactorB]);
      for i := 1 to p do cellstring := cellstring + Format(' %3d ',[i]);
      lReport.Add(cellstring);

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '-----';
      lReport.Add(cellstring);

      lReport.Add('%10s', [FactorA]);
      for i := 1 to NoCases do
      begin
        row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol, i]));
        col := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol, i]));
        slice := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol, i]));
        block := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Dcol, i]));
        if block = minD + k then
          Design[row-1, col-1] := 'C' + IntToStr(slice);
      end;
      for i := 0 to p - 1 do
      begin
        cellstring := Format('   %3d    ', [i+1]);
        for j := 0 to p - 1 do
          cellstring := cellstring + Format('%5s', [Design[i,j]]);
        lReport.Add(cellstring);
      end;
      cellstring := '----------';
      for i := 1 to p + 1 do
        cellstring := cellstring + '-----';
      lReport.Add(cellstring);
    end;

    // get cell means
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        for k := 0 to rangeD - 1 do
          celltotals[i,j,k] := celltotals[i,j,k] / n;
    for i := 0 to p-1 do
      for k := 0 to rangeD - 1 do
      begin
        celltotals[i,p,k] := celltotals[i,p,k] / (p * n);
        celltotals[p,i,k] := celltotals[p,i,k] / (p * n);
      end;
    GrandMean := GrandMean / (p * p * n * rangeD);
    for i := 0 to p-1 do
      Ctotals[i] := Ctotals[i] / (p * n * rangeD);

    // show table of means for each block
    for k := 0 to rangeD-1 do
    begin
      lReport.Add('');
      lReport.Add('BLOCK %d', [k+1]);
      lReport.Add('');
      lReport.Add('Cell means and totals');
      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '----------';
      lReport.Add(cellstring);

      cellstring := Format('%10s', [FactorB]);
      for i := 1 to p do cellstring := cellstring + Format('   %3d    ',[i]);
      cellstring := cellstring + '    Total';
      lReport.Add(cellstring);

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '----------';
      lReport.Add(cellstring);
      cellstring := Format('%10s', [FactorA]);
      lReport.Add(cellstring);
      for i := 0 to p-1 do
      begin
        cellstring := Format('   %3d    ', [i+1]);
        for j := 0 to p - 1 do
          cellstring := cellstring + Format(' %8.3f ', [celltotals[i, j, k]]);
        cellstring := cellstring + Format(' %8.3f ', [celltotals[i, p, k]]);
        lReport.Add(cellstring);
      end;

      cellstring := 'Total     ';
      for j := 0 to p-1 do
        cellstring := cellstring + Format(' %8.3f ', [celltotals[p, j, k]]);
      cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
      lReport.Add(cellstring);

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '----------';
      lReport.Add(cellstring);
    end;

    // show category means
    lReport.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorC]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Ctotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    DisplayReport(lReport);

  finally
    lReport.Free;

    Design := nil;
    Ctotals := nil;
    CDmat := nil;
    BDmat := nil;
    ADmat := nil;
    celltotals := nil;
    cellcnts := nil;
  end;
end;

procedure TLatinSqrsFrm.Plan3;
var
  n : integer; // no. of subjects per cell
  Acol, Bcol, Ccol, Dcol, DataCol: integer; // variable columns in grid
  FactorA: string;
  FactorB: string;
  FactorC: string;
  FactorD: string;
  DataVar: string;
  cellstring: string;
  i, j, k, m: integer;
  rangeA, rangeB, rangeC, rangeD: integer;
  minD, mn, mx: Integer;
  cellcnts: IntDyneCube;
  celltotals: DblDyneQuad;
  ABmat, ACmat, BCmat: DblDyneMat;
  ABCmat: DblDyneCube;
  Atotals: DblDyneVec;
  Btotals: DblDyneVec;
  Ctotals: DblDyneVec;
  Dtotals: DblDyneVec;
  design: StrDyneMat;
  G, term1, term2, term3, term4, term5, term6, term7, term8: double;
  term9, term10, sumxsqr: double;
  sumAsqr, sumBsqr, sumCsqr, sumDsqr, SSA, SSB, SSC, SSD: double;
  sumABsqr, sumACsqr, sumBCsqr, sumABCsqr: double;
  SSAB, SSAC, SSBC, SSABC, SSwithin, SStotal: double;
  MSa, MSb, MSc, MSd, MSAB, MSAC, MSBC, MSABC, MSwithin: double;
  data, GrandMean: double;
  p, row, col, slice, block: integer;
  dfa, dfb, dfc, dfwithin, dftotal, fa, fb, fc: double;
  dfd, fd, fab, fac, fbc, fabc, dfab, dfac, dfbc, dfabc: double;
  proba, probb, probc, probd: double;
  probab, probac, probbc, probabc: double;
  lReport: TStrings;
begin
  LatinSpecsFrm.PrepareForPlan(3);
  if LatinSpecsFrm.ShowModal <> mrOK then
    exit;

  n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
  FactorA := LatinSpecsFrm.ACodeEdit.Text;
  FactorB := LatinSpecsFrm.BCodeEdit.Text;
  FactorC := LatinSpecsFrm.CCodeEdit.Text;
  FactorD := LatinSpecsFrm.DCodeEdit.Text;
  DataVar := LatinSpecsFrm.DepVarEdit.Text;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = FactorA) then ACol := i;
    if (cellstring = FactorB) then BCol := i;
    if (cellstring = FactorC) then Ccol := i;
    if (cellstring = FactorD) then Dcol := i;
    if (cellstring = DataVar) then DataCol := i;
  end;

  // determine no. of levels in A, B and C
  if not GetRange(ACol, rangeA, mn, mx) then exit;
  if not GetRange(BCol, rangeB, mn, mx) then exit;
  if not GetRange(CCol, rangeC, mn, mx) then exit;
  if not GetRange(DCol, rangeD, mn, mx) then exit;
  if not CheckDataCol(DataCol) then exit;
  minD := mn;
  p := rangeA;

  // check for squareness
  if (rangeA <> rangeB) or (rangeA <> rangeC) or (rangeB <> rangeC) or (rangeA <> rangeD) then
  begin
    ErrorMsg('In a Latin square the range of values should all be equal.');
    exit;
  end;

  // set up an array for cell counts and for cell sums and marginal sums
  SetLength(cellcnts, p+1, p+1, p+1);
  SetLength(celltotals, p+1, p+1, p+1, p+1);
  SetLength(ABmat, p+1, p+1);
  SetLength(ACmat, p+1, p+1);
  SetLength(BCmat, p+1, p+1);
  SetLength(ABCmat, p+1, p+1, p+1);
  SetLength(Atotals, p);
  SetLength(Btotals, p);
  SetLength(Ctotals, p);
  SetLength(Dtotals, p);
  SetLength(Design,p, p);

  // initialize arrays and values
  for i := 0 to p do
    for j := 0 to p do
      for k := 0 to p do
        for m := 0 to p do
          celltotals[i,j,k,m] := 0.0;
  for i := 0 to p do
    for j := 0 to p do
    begin
      ABmat[i,j] := 0.0;
      ACmat[i,j] := 0.0;
      BCmat[i,j] := 0.0;
    end;

  for i := 0 to p do
    for j := 0 to p do
      for k := 0 to p do
      begin
        ABCmat[i,j,k] := 0.0;
        cellcnts[i,j,k] := 0;
      end;

  for i := 0 to p-1 do
  begin
    Atotals[i] := 0.0;
    Btotals[i] := 0.0;
    Ctotals[i] := 0.0;
    Dtotals[i] := 0.0;
  end;
  G := 0.0;
  sumxsqr := 0.0;
  sumAsqr := 0.0;
  sumBsqr := 0.0;
  sumCsqr := 0.0;
  sumDsqr := 0.0;
  sumABsqr := 0.0;
  sumACsqr := 0.0;
  sumBCsqr := 0.0;
  sumABCsqr := 0.0;
  term1 := 0.0;
  term2 := 0.0;
  term3 := 0.0;
  term4 := 0.0;
  term5 := 0.0;
  term6 := 0.0;
  term7 := 0.0;
  term8 := 0.0;
  term9 := 0.0;
  term10 := 0.0;
  GrandMean := 0.0;
  SSwithin := 0.0;

  //  Read in the data
  for i := 1 to NoCases do
  begin
    row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
    col := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
    slice := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i]));
    block := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Dcol,i]));
    data := StrToFloat(OS3MainFrm.DataGrid.Cells[DataCol,i]);
    cellcnts[row-1,col-1,slice-1] := cellcnts[row-1,col-1,slice-1] + 1;
    celltotals[row-1,col-1,slice-1,block-1] := celltotals[row-1,col-1,slice-1,block-1] + data;
    ABmat[row-1,col-1] := ABmat[row-1,col-1] + data;
    ACmat[row-1,slice-1] := ACmat[row-1,slice-1] + data;
    BCmat[col-1,slice-1] := BCmat[col-1,slice-1] + data;
    ABCmat[row-1,col-1,slice-1] := ABCmat[row-1,col-1,slice-1] + data;
    Atotals[row-1] := Atotals[row-1] + data;
    Btotals[col-1] := Btotals[col-1] + data;
    Ctotals[slice-1] := Ctotals[slice-1] + data;
    Dtotals[block-1] := Dtotals[block-1] + data;
    sumxsqr := sumxsqr + (data * data);
    GrandMean := GrandMean + data;
  end;

  // check for equal cell counts in ABCmat
  for i := 0 to p-1 do
    for j := 0 to p-1 do
      for k := 0 to p - 1 do
        if cellcnts[i,j,k] <> n then
        begin
          ErrorMsg('Cell sizes are not equal.');
          exit;
        end;

  // calculate values
  for i := 0 to p - 1 do // get row, column, slice and block sums
    for j := 0 to p-1 do
      for k := 0 to p - 1 do
        for m := 0 to p - 1 do
        begin
          celltotals[p,j,k,m] := celltotals[p,j,k,m] + celltotals[i,j,k,m];
          celltotals[i,p,k,m] := celltotals[i,p,k,m] + celltotals[i,j,k,m];
          celltotals[i,j,p,m] := celltotals[i,j,p,m] + celltotals[i,j,k,m];
          celltotals[i,j,k,p] := celltotals[i,j,k,p] + celltotals[i,j,k,m];
        end;

  for i := 0 to p - 1 do // get row, column and slice sums in ABC matrix
    for j := 0 to p-1 do
      for k := 0 to p-1 do
      begin
        ABCmat[p,j,k] := ABCmat[p,j,k] + ABCmat[i,j,k];
        ABCmat[i,p,k] := ABCmat[i,p,k] + ABCmat[i,j,k];
        ABCmat[i,j,p] := ABCmat[i,j,p] + ABCmat[i,j,k];
      end;

  // get 2-way interactions
  for i := 0 to p-1 do
    for j := 0 to p-1 do
    begin
      sumABsqr := sumABsqr + (ABmat[i,j] * ABmat[i,j]);
      sumACsqr := sumACsqr + (ACmat[i,j] * ACmat[i,j]);
      sumBCsqr := SumBCsqr + (BCmat[i,j] * BCmat[i,j]);
      ABmat[i,p] := ABmat[i,p] + ABmat[i,j];
      ABmat[p,j] := ABmat[p,j] + ABmat[i,j];
      ACmat[i,p] := ACmat[i,p] + ACmat[i,j];
      ACmat[p,j] := ACmat[p,j] + ACmat[i,j];
      BCmat[i,p] := BCmat[i,p] + BCmat[i,j];
      BCmat[p,j] := BCmat[p,j] + BCmat[i,j];
      for k := 0 to p-1 do
        sumABCsqr := sumABCsqr + (ABCmat[i,j,k] * ABCmat[i,j,k]);
    end;

  for i := 0 to p-1 do
  begin
    sumAsqr := sumAsqr + (Atotals[i] * Atotals[i]);
    sumBsqr := sumBsqr + (Btotals[i] * Btotals[i]);
    SumCsqr := sumCsqr + (Ctotals[i] * Ctotals[i]);
    sumDsqr := sumDsqr + (Dtotals[i] * Dtotals[i]);
  end;

  G := GrandMean;
  term1 := (G * G) / (n * p * p * p);
  term2 := sumxsqr;
  term3 := sumAsqr / (n * p * p);
  term4 := sumBsqr / (n * p * p);
  term5 := sumCsqr / (n * p * p);
  term9 := sumDsqr / (n * p * p);
  term6 := sumABsqr / (n * p);
  term7 := SumACsqr / (n * p);
  term8 := SumBCsqr / (n * p);
  term10 := sumABCsqr / n;
  SSA := term3 - term1;
  SSB := term4 - term1;
  SSC := term5 - term1;
  SSD := term9 - term1;
  SSAB := term6 - term3 - term4 + term1;
  SSAC := term7 - term3 - term5 + term1;
  SSBC := term8 - term4 - term5 + term1;
  SSABC := term10 - term6 - term7 - term8 + term3 + term4 + term5 - term1;
  SSABC := SSABC - (term9 - term1);

  // get ss within
  for i := 0 to p - 1 do
    for j := 0 to p - 1 do
      for k := 0 to p - 1 do
        for m := 0 to p - 1 do
          SSwithin := SSwithin + (celltotals[i,j,k,m] * celltotals[i,j,k,m]);
  SSwithin := sumXsqr - (SSwithin / n);

  // get SS residual
  SStotal := sumXsqr - term1;
  dfa := p-1;
  dfb := p-1;
  dfc := p-1;
  dfd := p-1;
  dfab := (p - 1) * (p - 1);
  dfac := dfab;
  dfbc := dfab;
  dfabc := (p-1) * (p-1) * (p-1) - (p-1);
  dfwithin := p * p * p * (n - 1);
  dftotal := n * p * p * p - 1;
  MSa := SSA / dfa;
  MSb := SSB / dfb;
  MSc := SSC / dfc;
  MSd := SSD / dfd;
  MSab := SSAB / dfab;
  MSac := SSAC / dfac;
  MSbc := SSBC / dfbc;
  MSabc := SSABC / dfabc;
//    MSres := SSres / dfres;
  MSwithin := SSwithin / dfwithin;
  fa := MSa / MSwithin;
  fb := MSb / MSwithin;
  fc := MSc / MSwithin;
  fd := MSd / MSwithin;
  fab := MSab / MSwithin;
  fac := MSac / MSwithin;
  fbc := MSbc / MSwithin;
  fabc := MSabc / MSwithin;
  proba := ProbF(fa,dfa,dfwithin);
  probb := ProbF(fb,dfb,dfwithin);
  probc := ProbF(fc,dfc,dfwithin);
  probd := ProbF(fd,dfd,dfwithin);
  probab := ProbF(fab,dfab,dfwithin);
  probac := ProbF(fac,dfac,dfwithin);
  probbc := ProbF(fbc,dfbc,dfwithin);
  probabc := ProbF(fabc,dfabc,dfwithin);

  // show ANOVA table results
  lReport := TStringList.Create;
  try
    lReport.Add('LATIN SQUARE ANALYSIS Plan 3 Results');
    lReport.Add('');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Source         SS        DF        MS        F      Prob.>F');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Factor A  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSA, dfa, MSa, fa, proba]);
    lReport.Add('Factor B  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSB, dfb, MSb, fb, probb]);
    lReport.Add('Factor C  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSC, dfc, MSc, fc, probc]);
    lReport.Add('Factor D  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSD, dfd, MSd, fd, probd]);
    lReport.Add('A x B     %9.3f %9.0f %9.3f %9.3f %9.3f', [SSAB, dfab, MSab, fab, probab]);
    lReport.Add('A x C     %9.3f %9.0f %9.3f %9.3f %9.3f', [SSAC, dfac, MSac, fac, probac]);
    lReport.Add('B x C     %9.3f %9.0f %9.3f %9.3f %9.3f', [SSBC, dfbc, MSbc, fbc, probbc]);
    lReport.Add('A x B x C %9.3f %9.0f %9.3f %9.3f %9.3f', [SSABC, dfabc, MSabc, fabc, probabc]);
    lReport.Add('Within    %9.3f %9.0f %9.3f', [SSwithin, dfwithin, MSwithin]);
    lReport.Add('Total     %9.3f %9.0f', [SStotal, dftotal]);
    lReport.Add('-----------------------------------------------------------');

    // show design for each block
    for k := 0 to rangeD - 1 do
    begin
      lReport.Add('');
      lReport.Add('Experimental Design for block %d', [k+1]);

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '-----';
      lReport.Add(cellstring);

      cellstring := Format('%10s', [FactorB]);
      for i := 1 to p do cellstring := cellstring + Format(' %3d ', [i]);
      lReport.Add(cellstring);

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '-----';
      lReport.Add(cellstring);

      lReport.Add('%10s', [FactorA]);

      for i := 1 to NoCases do
      begin
        row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
        col := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
        slice := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i]));
        block := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Dcol,i]));
        if block = minD + k then
          Design[row-1,col-1] := 'C' + IntToStr(slice);
      end;

      for i := 0 to p - 1 do
      begin
        cellstring := format('   %3d    ',[i+1]);
        for j := 0 to p - 1 do
          cellstring := cellstring + format('%5s',[Design[i,j]]);
        lReport.Add(cellstring);
      end;

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '-----';
      lReport.Add(cellstring);
    end;

    // get cell means
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        for k := 0 to p - 1 do
          for m := 0 to p - 1 do
            celltotals[i,j,k,m] := celltotals[i,j,k,m] / n;

    for i := 0 to p-1 do
    begin
      for j := 0 to p - 1 do
      begin
        for k := 0 to p - 1 do
        begin
          for m := 0 to p - 1 do
          begin
            celltotals[p,j,k,m] := celltotals[p,j,k,m] / (p * n);
            celltotals[i,p,k,m] := celltotals[i,p,k,m] / (p * n);
            celltotals[i,j,p,m] := celltotals[i,j,p,m] / (p * n);
            celltotals[i,j,k,p] := celltotals[i,j,k,p] / (p * n);
          end;
        end;
      end;
    end;

    for i := 0 to p-1 do
      for j := 0 to p-1 do
        for k := 0 to p-1 do
          ABCmat[i,j,k] := ABCmat[i,j,k] / n;
    for j := 0 to p-1 do
      for k := 0 to p-1 do
        ABCmat[p,j,k] := ABCmat[p,j,k] / (p * n);
    for i := 0 to p-1 do
      for k := 0 to p-1 do
        ABCmat[i,p,k] := ABCmat[i,p,k] / (p * n);
    for i := 0 to p - 1 do
      for j := 0 to p - 1 do
        ABCmat[i,j,p] := ABCmat[i,j,p] / (p * n);

    GrandMean := GrandMean / (p * p * p * n );
    for i := 0 to p-1 do
    begin
      Atotals[i] := Atotals[i] / (p * p * n);
      Btotals[i] := Btotals[i] / (p * p * n);
      Ctotals[i] := Ctotals[i] / (p * p * n);
      Dtotals[i] := Dtotals[i] / (p * p * n);
    end;

    // show table of means for each block
    for k := 0 to p-1 do
    begin
      lReport.Add('');
      lReport.Add('BLOCK %d', [k+1]);
      lReport.Add('');
      lReport.Add('Cell means and totals');

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '----------';
      lReport.Add(cellstring);

      cellstring := Format('%10s', [FactorB]);
      for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
      cellstring := cellstring + '    Total';
      lReport.Add(cellstring);

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '----------';
      lReport.Add(cellstring);

      lReport.Add('%10s', [FactorA]);
      for i := 0 to p-1 do
      begin
        cellstring := Format('   %3d    ', [i+1]);
        for j := 0 to p - 1 do
          cellstring := cellstring + Format(' %8.3f ', [ABCmat[i,j,k]]);
        cellstring := cellstring + Format(' %8.3f ', [ABCmat[i,p,k]]);
        lReport.Add(cellstring);
      end;

      cellstring := 'Total     ';
      for j := 0 to p-1 do
        cellstring := cellstring + Format(' %8.3f ', [ABCmat[p,j,k]]);
      cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
      lReport.Add(cellstring);

      cellstring := '----------';
      for i := 1 to p + 1 do cellstring := cellstring + '----------';
      lReport.Add(cellstring);
    end;

    // show category means
    lReport.Add('');
    lReport.Add('Means for each variable');
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Atotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Btotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorC]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Ctotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorD]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Dtotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    DisplayReport(lReport);

  finally
    LReport.Free;

    Design := nil;
    Dtotals := nil;
    Ctotals := nil;
    Btotals := nil;
    Atotals := nil;
    ABmat := nil;
    ACmat := nil;
    BCmat := nil;
    ABCmat := nil;
    celltotals := nil;
    cellcnts := nil;
  end;
end;

procedure TLatinSqrsFrm.Plan4;
var
  n: integer; // no. of subjects per cell
  Acol, Bcol, Ccol, Dcol, DataCol: integer; // variable columns in grid
  FactorA: string;
  FactorB: string;
  FactorC: string;
  FactorD: string;
  DataVar: string;
  cellstring: string;
  i, j, k: integer;
  rangeA, rangeB, rangeC, rangeD: integer;
  mn, mx: Integer;
  cellcnts: IntDyneMat;
  ABmat: DblDyneMat;
  ABCmat: DblDyneCube;
  Atotals: DblDyneVec;
  Btotals: DblDyneVec;
  Ctotals: DblDyneVec;
  Dtotals: DblDyneVec;
  design: StrDyneMat;
  G, term1, term2, term3, term4, term5, term6, term7: double;
  sumxsqr: double;
  sumAsqr, sumBsqr, sumCsqr, sumDsqr, SSA, SSB, SSC, SSD: double;
  SSwithin, SSres, SStotal: double;
  MSa, MSb, MSc, MSd, MSres, MSwithin: double;
  data, GrandMean: double;
  p, row, col, slice, block: integer;
  dfa, dfb, dfc, dfres, dfwithin, dftotal, fa, fb, fc: double;
  dfd, fd, fres: double;
  proba, probb, probc, probd, probres: double;
  lReport: TStrings;

begin
  LatinSpecsFrm.PrepareForPlan(4);
  if LatinSpecsFrm.ShowModal <> mrOK then
    exit;

  n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
  FactorA := LatinSpecsFrm.ACodeEdit.Text;
  FactorB := LatinSpecsFrm.BCodeEdit.Text;
  FactorC := LatinSpecsFrm.CCodeEdit.Text;
  FactorD := LatinSpecsFrm.DCodeEdit.Text;
  DataVar := LatinSpecsFrm.DepVarEdit.Text;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = FactorA) then ACol := i;
    if (cellstring = FactorB) then BCol := i;
    if (cellstring = FactorC) then Ccol := i;
    if (cellstring = FactorD) then Dcol := i;
    if (cellstring = DataVar) then DataCol := i;
  end;

  // determine no. of levels in A, B and C
  if not GetRange(ACol, rangeA, mn, mx) then exit;
  if not GetRange(BCol, rangeB, mn, mx) then exit;
  if not GetRange(CCol, rangeC, mn, mx) then exit;
  if not GetRange(DCol, rangeD, mn, mx) then exit;
  if not CheckDataCol(DataCol) then exit;
  p := rangeA;

  // check for squareness
  if (rangeA <> rangeB) or (rangeA <> rangeC) or (rangeB <> rangeC) then
  begin
    ErrorMsg('In a Latin square the range of values should be equal for A,B and C.');
    exit;
  end;

  // set up an array for cell counts and for cell sums and marginal sums
  SetLength(ABmat, p+1, p+1);
  SetLength(ABCmat, p+1, p+1, p+1);
  SetLength(cellcnts, p+1, p+1);
  SetLength(Atotals, p);
  SetLength(Btotals, p);
  SetLength(Ctotals, p);
  SetLength(Dtotals, p);
  SetLength(Design, p, p);

  for i := 0 to p do
    for j := 0 to p do
      for k := 0 to p do
        ABCmat[i,j,k] := 0.0;

  for i := 0 to p-1 do
    for j := 0 to p-1 do
    begin
      cellcnts[i,j] := 0;
      ABmat[i,j] := 0.0;
    end;

  for i := 0 to p-1 do
  begin
    Atotals[i] := 0.0;
    Btotals[i] := 0.0;
    Ctotals[i] := 0.0;
    Dtotals[i] := 0.0;
  end;

  G := 0.0;
  sumxsqr := 0.0;
  sumAsqr := 0.0;
  sumBsqr := 0.0;
  sumCsqr := 0.0;
  sumDsqr := 0.0;
  SSwithin := 0.0;
  term1 := 0.0;
  term2 := 0.0;
  term3 := 0.0;
  term4 := 0.0;
  term5 := 0.0;
  term6 := 0.0;
  term7 := 0.0;
  GrandMean := 0.0;

  //  Read in the data
  for i := 1 to NoCases do
  begin
    row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
    col := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
    slice := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i]));
    block := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Dcol,i]));
    data := StrToFloat(OS3MainFrm.DataGrid.Cells[DataCol,i]);
    cellcnts[row-1,col-1] := cellcnts[row-1,col-1] + 1;
    ABCmat[row-1,col-1,slice-1] := ABCmat[row-1,col-1,slice-1] + data;
    Atotals[row-1] := Atotals[row-1] + data;
    Btotals[col-1] := Btotals[col-1] + data;
    Ctotals[slice-1] := Ctotals[slice-1] + data;
    Dtotals[block-1] := Dtotals[block-1] + data;
    sumxsqr := sumxsqr + (data * data);
    GrandMean := GrandMean + data;
  end;

  // collapse c's into a x b
  for k := 0 to p-1 do
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        ABmat[i,j] := ABmat[i,j] + ABCmat[i,j,k];

  // get sum of squared cells
  for i := 0 to p - 1 do
    for j := 0 to p - 1 do
      SSwithin := SSwithin + (ABmat[i,j] * ABmat[i,j]);

  // check for equal cell counts
  for i := 0 to p-1 do
    for j := 0 to p-1 do
      if cellcnts[i,j] <> n then
      begin
        ErrorMsg('Cell sizes are not  equal,');
        Exit;
      end;

  for i := 0 to p-1 do
  begin
    sumAsqr := sumAsqr + (Atotals[i] * Atotals[i]);
    sumBsqr := sumBsqr + (Btotals[i] * Btotals[i]);
    sumCsqr := sumCsqr + (Ctotals[i] * Ctotals[i]);
    sumDsqr := sumDsqr + (Dtotals[i] * Dtotals[i]);
  end;

  G := GrandMean;
  term1 := (G * G) / (n * p * p);
  term2 := sumxsqr;
  term3 := sumAsqr / (n * p);
  term4 := sumBsqr / (n * p);
  term5 := sumCsqr / (n * p);
  term6 := sumDsqr / (n * p);
  term7 := SSwithin / n;
  SSA := term3 - term1;
  SSB := term4 - term1;
  SSC := term5 - term1;
  SSD := term6 - term1;
  SSres := term7 - term3 - term4 - term5 - term6 + 3 * term1;
  SSwithin := term2 - term7;
  SStotal := term2 - term1;

  dfa := p-1;
  dfb := p-1;
  dfc := p-1;
  dfd := p-1;
  dfres := (p-1) * (p-3);
  dfwithin := p * p * (n - 1);
  dftotal := n * p * p - 1;
  MSa := SSA / dfa;
  MSb := SSB / dfb;
  MSc := SSC / dfc;
  MSd := SSD / dfd;
  if dfres > 0 then MSres := SSres / dfres;
  MSwithin := SSwithin / dfwithin;
  fa := MSa / MSwithin;
  fb := MSb / MSwithin;
  fc := MSc / MSwithin;
  fd := MSd / MSwithin;
  if dfres > 0 then fres := MSres / MSwithin;
  proba := probf(fa,dfa,dfwithin);
  probb := probf(fb,dfb,dfwithin);
  probc := probf(fc,dfc,dfwithin);
  probd := probf(fd,dfd,dfwithin);
  if dfres > 0 then probres := probf(fres,dfres,dfwithin);

  // show ANOVA table results
  lReport := TStringList.Create;
  try
    lReport.Add('GRECO-LATIN SQUARE ANALYSIS (No Interactions)');
    lReport.Add('');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Source         SS        DF        MS        F      Prob.>F');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Factor A  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSA, dfa, MSa, fa, proba]);
    lReport.Add('Factor B  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSB, dfb, MSb, fb, probb]);
    lReport.Add('Latin Sqr.%9.3f %9.0f %9.3f %9.3f %9.3f', [SSC, dfc, MSc, fc, probc]);
    lReport.Add('Greek Sqr.%9.3f %9.0f %9.3f %9.3f %9.3f', [SSD, dfd, MSd, fd, probd]);
    if dfres > 0 then
      lReport.Add('Residual  %9.3f %9.0f %9.3f %9.3f %9.3f', [SSres, dfres, MSres, fres, probres])
    else
      lReport.Add('Residual      -         -          -         -         -');
    lReport.Add('Within    %9.3f %9.0f %9.3f', [SSwithin, dfwithin, MSwithin]);
    lReport.Add('Total     %9.3f %9.0f', [SStotal, dftotal]);
    lReport.Add('-----------------------------------------------------------');

    // show design for Latin Square
    lReport.Add('');
    lReport.Add('Experimental Design for Latin Square ');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format(' %3d ', [i]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    lReport.Add('%10s', [FactorA]);

    for i := 1 to NoCases do
    begin
      row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
      col := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
      slice := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i]));
      Design[row-1,col-1] := 'C' + IntToStr(slice);
    end;
    for i := 0 to p - 1 do
    begin
      cellstring := Format('   %3d    ', [i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format('%5s', [Design[i,j]]);
      lReport.Add(cellstring);
    end;

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    // show design for Greek Square
    lReport.Add('');
    lReport.Add('Experimental Design for Greek Square ');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format(' %3d ', [i]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    lReport.Add(cellstring);

    for i := 1 to NoCases do
    begin
      row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
      col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
      block := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
      Design[row-1,col-1] := 'C' + IntToStr(block);
    end;

    for i := 0 to p - 1 do
    begin
      cellstring := Format('   %3d    ', [i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format('%5s', [Design[i,j]]);
      lReport.Add(cellstring);
    end;

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    for i := 0 to p-1 do
    begin
      for j := 0 to p - 1 do
      begin
        ABmat[i,p] := ABmat[i,p] + ABmat[i,j];
        ABmat[p,j] := ABmat[p,j] + ABmat[i,j];
      end;
    end;

    for i := 0 to p-1 do
      for j := 0 to p-1 do
        ABmat[i,j] := ABmat[i,j] / n;
    for i := 0 to p-1 do
      ABmat[i,p] := ABmat[i,p] / (n * p);
    for j := 0 to p-1 do
      ABmat[p,j] := ABmat[p,j] / (n * p);

    GrandMean := GrandMean / (p * p * n );
    for i := 0 to p-1 do
    begin
      Atotals[i] := Atotals[i] / (p * n);
      Btotals[i] := Btotals[i] / (p * n);
      Ctotals[i] := Ctotals[i] / (p * n);
      Dtotals[i] := Dtotals[i] / (p * n);
    end;

    // show table of means for ABmat
    lReport.Add('');
    lReport.Add('Cell means and totals');
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    lReport.Add(cellstring);

    for i := 0 to p-1 do
    begin
      cellstring := Format('   %3d    ', [i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format(' %8.3f ', [ABmat[i,j]]);
      cellstring := cellstring + Format(' %8.3f ', [ABmat[i,p]]);
      lReport.Add(cellstring);
    end;

    cellstring := 'Total     ';
    for j := 0 to p-1 do
      cellstring := cellstring + Format(' %8.3f ', [ABmat[p,j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    // show category means
    lReport.Add('');
    lReport.Add('Means for each variable');
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Atotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    lReport.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Btotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    cellstring := Format('%10s', [FactorC]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Ctotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    lReport.Add('');

    cellstring := '----------';
    for i := 1 to rangeD + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorD]);
    for i := 1 to rangeD do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to rangeD + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to rangeD - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Dtotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to rangeD + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    DisplayReport(lReport);

  finally
    lReport.Free;

    Design := nil;
    Dtotals := nil;
    Ctotals := nil;
    Btotals := nil;
    Atotals := nil;
    cellcnts := nil;
    ABCmat := nil;
    ABmat := nil;
  end;
end;

procedure TLatinSqrsFrm.Plan5;
var
  n: integer; // no. of subjects per cell
  Acol, Bcol, SbjCol, Grpcol, DataCol: integer; // variable columns in grid
  FactorA: string;
  FactorB: string;
  SubjectFactor: string;
  GroupFactor: string;
  DataVar: string;
  cellstring: string;
  i, j, k: integer;
  mn, mx: Integer;
  rangeA, rangeB, rangeGrp: integer;
  cellcnts: IntDyneMat;
  ABmat: DblDyneMat;
  ABCmat: DblDyneCube;
  GBmat: DblDyneMat;
  Atotals: DblDyneVec;
  Btotals: DblDyneVec;
  Grptotals: DblDyneVec;
  Subjtotals: DblDyneMat;
  design: StrDyneMat;
  term1, term2, term3, term4, term5, term6, term7: double;
  sumxsqr: double;
  SSbetsubj, SSgroups, SSsubwGrps, SSwithinsubj, SSa, SSb, SSab: double;
  SSerrwithin, SStotal, MSgroups, MSsubwGrps, MSa, MSb, MSab: double;
  MSerrwithin, DFbetsubj, DFgroups, DFsubwGrps, DFwithinsubj: double;
  DFa, DFb, DFab, DFerrwithin, DFtotal: double;
  data, GrandMean: double;
  p, row, col, subject, group: integer;
  proba, probb, probab, probgrps: double;
  fa, fb, fab, fgroups: double;
  RowLabels, ColLabels: StrDyneVec;
  Title: string;
  lReport: TStrings;

begin
  LatinSpecsFrm.PrepareForPlan(5);
  if LatinSpecsFrm.ShowModal <> mrOK then
    exit;

  n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
  FactorA := LatinSpecsFrm.ACodeEdit.Text;
  FactorB := LatinSpecsFrm.BCodeEdit.Text;
  SubjectFactor := LatinSpecsFrm.CCodeEdit.Text;
  GroupFactor := LatinSpecsFrm.GrpCodeEdit.Text;
  DataVar := LatinSpecsFrm.DepVarEdit.Text;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = FactorA) then ACol := i;
    if (cellstring = FactorB) then BCol := i;
    if (cellstring = GroupFactor) then Grpcol := i;
    if (cellstring = SubjectFactor) then Sbjcol := i;
    if (cellstring = DataVar) then DataCol := i;
  end;

  // determine no. of levels in A, B and Group
  if not GetRange(ACol, rangeA, mn, mx) then exit;
  if not GetRange(BCol, rangeB, mn, mx) then exit;
  if not GetRange(GrpCol, rangeGrp, mn, mx) then exit;
  if not CheckDataCol(DataCol) then exit;
  p := rangeA;

  // check for squareness
  if (rangeA <> rangeGrp) then
  begin
    ErrorMsg('ERROR! In a Latin square the range of values should be equal for A,B and C.');
    exit;
  end;

  // set up an array for cell counts and for cell sums and marginal sums
  SetLength(ABmat, p+1, p+1);
  SetLength(ABCmat, p+1, p+1, n+1);
  SetLength(cellcnts, p+1, p+1);
  SetLength(Atotals, p+1);
  SetLength(Btotals, p+1);
  SetLength(Grptotals, p+1);
  SetLength(Design, p, p);
  SetLength(Subjtotals ,p+1, n+1);
  SetLength(RowLabels, p+1);
  SetLength(ColLabels, n+1);
  SetLength(GBmat, p+1, p+1);

  for i := 0 to p-1 do
  begin
    RowLabels[i] := IntToStr(i+1);
    ColLabels[i] := RowLabels[i];
  end;
  RowLabels[p] := 'Total';
  ColLabels[p] := 'Total';

  for i := 0 to p do
    for j := 0 to p do
      for k := 0 to n do
        ABCmat[i,j,k] := 0.0;

  for i := 0 to p do
    for j := 0 to p do
    begin
      cellcnts[i,j] := 0;
      ABmat[i,j] := 0.0;
      GBmat[i,j] := 0.0;
    end;

  for i := 0 to p do
  begin
    Atotals[i] := 0.0;
    Btotals[i] := 0.0;
    Grptotals[i] := 0.0;
  end;

  for i := 0 to p do
    for j := 0 to n do
      Subjtotals[i,j] := 0.0;

  sumxsqr := 0.0;
  term1 := 0.0;
  term2 := 0.0;
  term3 := 0.0;
  term4 := 0.0;
  term5 := 0.0;
  term6 := 0.0;
  term7 := 0.0;
  GrandMean := 0.0;

  //  Read in the data
  for i := 1 to NoCases do
  begin
    row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
    col := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
    group := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Grpcol,i]));
    subject := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Sbjcol,i]));
    data := StrToFloat(OS3MainFrm.DataGrid.Cells[DataCol,i]);
    cellcnts[group-1,row-1] := cellcnts[group-1,row-1] + 1;
    ABCmat[group-1,row-1,subject-1] := ABCmat[group-1,row-1,subject-1] + data;
    Subjtotals[group-1,subject-1] := Subjtotals[group-1,subject-1] + data;
    GBmat[group-1,col-1] := GBmat[group-1,col-1] + data;
    Atotals[col-1] := Atotals[col-1] + data;
    Btotals[group-1] := Btotals[group-1] + data;
    Grptotals[group-1] := Grptotals[group-1] + data;
    sumxsqr := sumxsqr + (data * data);
    GrandMean := GrandMean + data;
  end;

  // check for equal cell counts
  for i := 0 to p-1 do
    for j := 0 to p-1 do
      if cellcnts[i,j] <> n then
      begin
        ErrorMsg('Cell sizes are not  equal.');
        Exit;
      end;

  // collapse subjects's into group x a matrix
  for i := 0 to p-1 do // group
    for j := 0 to p-1 do // factor a
      for k := 0 to n-1 do // subject
        ABmat[i,j] := ABmat[i,j] + ABCmat[i,j,k];

  // get marginal totals for ABmat and GBmat
  for i := 0 to p-1 do
    for j := 0 to p-1 do
    begin
      ABmat[p,j] := ABmat[p,j] + ABmat[i,j];
      ABmat[i,p] := ABmat[i,p] + ABmat[i,j];
      GBmat[p,j] := GBmat[p,j] + GBmat[i,j];
      GBmat[i,p] := GBmat[i,p] + GBmat[i,j];
    end;

  // get grand total for ABmat and GBmat
  for i := 0 to p-1 do
  begin
    ABmat[p,p] := ABmat[p,p] + ABmat[p,i];
    GBmat[p,p] := GBmat[p,p] + GBmat[p,i];
  end;

  // Get marginal totals for Subjtotals
  for i := 0 to p-1 do
    for j := 0 to n-1 do
    begin
      Subjtotals[p,j] := Subjtotals[p,j] + Subjtotals[i,j];
      Subjtotals[i,n] := Subjtotals[i,n] + Subjtotals[i,j];
    end;

  for i := 0 to p-1 do
    Subjtotals[p,n] := Subjtotals[p,n] + Subjtotals[i,n];

  // test block
  lReport := TStringList.Create;
  try
    lReport.Add('Sums for ANOVA Analysis');
    lReport.Add('');

    cellstring := 'Group (rows) times A Factor (columns) sums';
    MatPrint(ABmat, p+1, p+1, cellstring, RowLabels, ColLabels, n*p*p, lReport);

    cellstring := 'Group (rows) times B (cells Factor) sums';
    MatPrint(GBmat, p+1, p+1, cellstring, RowLabels, ColLabels, n*p*p, lReport);

    Title := 'Groups (rows) times Subjects (columns) matrix';
    for i := 0 to n-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[n] := 'Total';
    MatPrint(Subjtotals, p+1, n+1, Title, RowLabels, ColLabels, n*p*p, lReport);

    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // get squared sum of subject's totals in each group
    for i := 0 to p-1 do // group
      term7 := term7 + sqr(Subjtotals[i,n]);
    term7 := term7 / (n*p); // Sum G^2 sub k

    // now square each person score in each group and get sum for group
    for i := 0 to p-1 do
      for j := 0 to n-1 do
        Subjtotals[i,j] := Subjtotals[i,j] * Subjtotals[i,j];
    for i := 0 to p-1 do
      Subjtotals[i,n] := 0.0;
    for i := 0 to p-1 do
      for j := 0 to n-1 do
        Subjtotals[i,n] := Subjtotals[i,n] + Subjtotals[i,j];
    for i := 0 to p-1 do term6 := term6 + Subjtotals[i,n];
    SSsubwgrps := term6 / p - term7;

    // get correction term
    term1 := (GrandMean * GrandMean) / (n * p * p);
    term2 := sumxsqr;

    // get sum of squared a's for term3
    for j := 0 to p-1 do
      term3 := term3 + (ABmat[p,j] * ABmat[p,j]);
    term3 := term3 / (n * p);

    // get sum of squared groups for term4
    for i := 0 to p-1 do
      term4 := term4 + (ABmat[i,p] * ABmat[i,p]);
    term4 := term4 / (n * p);

    // get squared sum of b's (across groups) for term5
    for j := 0 to p-1 do
      term5 := term5 + (GBmat[p,j] * GBmat[p,j]);
    term5 := term5 / (n * p);

    SSgroups := term4 - term1;
    SSbetsubj := SSgroups + SSsubwgrps;
    SStotal := sumxsqr - term1;
    SSwithinsubj := SStotal - SSbetsubj;
    SSa := term3 - term1;
    SSb := term5 - term1;

    // get sum of squared AB cells for term6
    term6 := 0.0;
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        term6 := term6 + (ABmat[i,j] * ABmat[i,j]);
    term6 := term6 / n;
    SSab := term6 - term3 - term5 + term1;
    SSab := SSab - SSgroups;
    SSerrwithin := ( sumxsqr - term6) - SSsubwgrps;

    // record degrees of freedom for sources
    dfbetsubj := n * p - 1;
    dfsubwgrps := p * (n-1);
    dfgroups := p - 1;
    dftotal := n * p * p - 1;
    dfwithinsubj := n * p * (p-1);
    dfa := p - 1;
    dfb := p - 1;
    dfab := (p - 1) * (p - 2);
    dferrwithin := p * (n - 1) * (p - 1);

    MSsubwgrps := SSsubwgrps / dfsubwgrps;
    MSgroups := SSgroups / dfgroups;
    MSa := SSa / dfa;
    MSb := SSb / dfb;
    MSab := SSab / dfab;
    MSerrwithin := SSerrwithin / dferrwithin;
    fgroups := MSgroups / MSsubwgrps;
    fa := MSa / MSerrwithin;
    fb := MSb / MSerrwithin;
    fab := MSab / MSerrwithin;
    probgrps := probf(fgroups,dfgroups,dfsubwgrps);
    proba := probf(fa,dfa,dferrwithin);
    probb := probf(fb,dfb,dferrwithin);
    probab := probf(fab,dfab,dferrwithin);

    // show ANOVA table results
    lReport.Add('LATIN SQUARES REPEATED ANALYSIS Plan 5 (Partial Interactions)');
    lReport.Add('');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Source         SS        DF        MS        F      Prob.>F');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Betw.Subj.%9.3f %9.0f', [SSbetsubj, dfbetsubj]);
    lReport.Add(' Groups   %9.3f %9.0f %9.3f %9.3f %9.3f', [SSgroups, dfgroups, MSgroups, fgroups, probgrps]);
    lReport.Add(' Subj.w.g.%9.3f %9.0f %9.3f', [SSsubwgrps, dfsubwgrps, MSsubwgrps]);
    lReport.Add('');
    lReport.Add('Within Sub%9.3f %9.0f', [SSwithinsubj, dfwithinsubj]);
    lReport.Add(' Factor A %9.3f %9.0f %9.3f %9.3f %9.3f', [SSa, dfa, MSa, fa, proba]);
    lReport.Add(' Factor B %9.3f %9.0f %9.3f %9.3f %9.3f', [SSb, dfb, MSb, fb, probb]);
    lReport.Add(' Factor AB%9.3f %9.0f %9.3f %9.3f %9.3f', [SSab, dfab, MSab, fab, probab]);
    lReport.Add(' Error w. %9.3f %9.0f %9.3f', [SSerrwithin, dferrwithin, MSerrwithin]);
    lReport.Add('Total     %9.3f %9.0f', [SStotal, dftotal]);
    lReport.Add('-----------------------------------------------------------');

    // show design for Square
    lReport.Add('');
    lReport.Add('Experimental Design for Latin Square ');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format(' %3d ', [i]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [GroupFactor]);
    lReport.Add(cellstring);

    for i := 1 to NoCases do
    begin
      row := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i])); // A (column) effect
      col := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i])); // B (cell) effect
      group := Round(StrToFloat(OS3MainFrm.DataGrid.Cells[Grpcol,i])); // group (row)
      Design[group-1,row-1] := 'B' + IntToStr(col);
    end;

    for i := 0 to p - 1 do
    begin
      cellstring := Format('   %3d    ', [i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format('%5s', [Design[i,j]]);
      lReport.Add(cellstring);
    end;

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    for i := 0 to p-1 do
      for j := 0 to p-1 do
        ABmat[i,j] := ABmat[i,j] / n;
    for i := 0 to p-1 do
      ABmat[i,p] := ABmat[i,p] / (n * p);
    for j := 0 to p-1 do
      ABmat[p,j] := ABmat[p,j] / (n * p);

    GrandMean := GrandMean / (p * p * n );
    for i := 0 to p-1 do
    begin
      Atotals[i] := Atotals[i] / (p * n);
      Btotals[i] := Btotals[i] / (p * n);
      Grptotals[i] := Grptotals[i] / (p * n);
    end;

    // show table of means for ABmat
    lReport.Add('');
    lReport.Add('Cell means and totals');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [GroupFactor]);
    lReport.Add(cellstring);

    for i := 0 to p-1 do
    begin
      cellstring := Format('   %3d    ', [i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format(' %8.3f ', [ABmat[i,j]]);
      cellstring := cellstring + Format(' %8.3f ', [ABmat[i,p]]);
      lReport.Add(cellstring);
    end;

    cellstring := 'Total     ';
    for j := 0 to p-1 do
      cellstring := cellstring + Format(' %8.3f ', [ABmat[p,j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    // show category means
    lReport.Add('');
    lReport.Add('Means for each variable');
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Atotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Btotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [GroupFactor]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Grptotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    DisplayReport(lReport);

  finally
    lReport.Free;

    GBmat := nil;
    ColLabels := nil;
    RowLabels := nil;
    Subjtotals := nil;
    Design := nil;
    Grptotals := nil;
    Btotals := nil;
    Atotals := nil;
    cellcnts := nil;
    ABCmat := nil;
    ABmat := nil;
  end;
end;

procedure TLatinSqrsFrm.Plan6;
var
  n: integer; // no. of subjects per cell
  Acol, Bcol, SbjCol, GrpCol, DataCol: Integer;    // variable columns in grid
  FactorA: string;
  FactorB: string;
  SubjectFactor: string;
  GroupFactor: string;
  DataVar: string;
  cellstring: string;
  i, j, k: integer;
  rangeA, rangeB, rangeGrp: integer;
  mn, mx: Integer;
  cellcnts: IntDyneMat;
  ABmat: DblDyneMat;
  ABCmat: DblDyneCube;
  GBmat: DblDyneMat;
  Atotals: DblDyneVec;
  Btotals: DblDyneVec;
  Grptotals: DblDyneVec;
  Subjtotals: DblDyneMat;
  design: StrDyneMat;
  term1, term2, term3, term4, term5, term6, term7: double;
  sumxsqr: double;
  SSbetsubj, SSgroups, SSsubwGrps, SSwithinsubj, SSa, SSb, SSab: double;
  SSerrwithin, SStotal, MSgroups, MSsubwGrps, MSa, MSb, MSab: double;
  MSerrwithin, DFbetsubj, DFgroups, DFsubwGrps, DFwithinsubj: double;
  DFa, DFb, DFab, DFerrwithin, DFtotal: double;
  data, GrandMean: double;
  p, row, col, subject, group: integer;
  proba, probb, probab, probgrps: double;
  fa, fb, fab, fgroups: double;
  RowLabels, ColLabels: StrDyneVec;
  Title: string;
  lReport: TStrings;

begin
  LatinSpecsFrm.PrepareForPlan(6);
  if LatinSpecsFrm.ShowModal <> mrOK then
    exit;

  n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
  FactorA := LatinSpecsFrm.ACodeEdit.Text;
  FactorB := LatinSpecsFrm.BCodeEdit.Text;
  SubjectFactor := LatinSpecsFrm.CCodeEdit.Text;
  GroupFactor := LatinSpecsFrm.GrpCodeEdit.Text;
  DataVar := LatinSpecsFrm.DepVarEdit.Text;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = FactorA) then ACol := i;
    if (cellstring = FactorB) then BCol := i;
    if (cellstring = GroupFactor) then Grpcol := i;
    if (cellstring = SubjectFactor) then Sbjcol := i;
    if (cellstring = DataVar) then DataCol := i;
  end;

  // determine no. of levels in A, B and Group
  if not GetRange(ACol, rangeA, mn, mx) then exit;
  if not GetRange(BCol, rangeB, mn, mx) then exit;
  if not GetRange(GrpCol, rangeGrp, mn, mx) then exit;
  if not CheckDataCol(DataCol) then exit;
  p := rangeA;

  // check for squareness
  if  (rangeA <> rangeGrp) then
  begin
    ErrorMsg('In a Latin square the range of values should be equal for A, B and C.');
    exit;
  end;

  // set up an array for cell counts and for cell sums and marginal sums
  SetLength(ABmat, p+1, p+1);
  SetLength(ABCmat, p+1, p+1, n+1);
  SetLength(cellcnts, p+1, p+1);
  SetLength(Atotals, p+1);
  SetLength(Btotals, p+1);
  SetLength(Grptotals, p+1);
  SetLength(Design, p, p);
  SetLength(Subjtotals, p+1, n+1);
  SetLength(RowLabels, p+1);
  SetLength(ColLabels, n+1);
  SetLength(GBmat, p+1, p+1);

  for i := 0 to p-1 do
  begin
    RowLabels[i] := IntToStr(i+1);
    ColLabels[i] := RowLabels[i];
  end;
  RowLabels[p] := 'Total';
  ColLabels[p] := 'Total';

  for i := 0 to p do
    for j := 0 to p do
      for k := 0 to n do
        ABCmat[i,j,k] := 0.0;

  for i := 0 to p do
    for j := 0 to p do
    begin
      cellcnts[i,j] := 0;
      ABmat[i,j] := 0.0;
      GBmat[i,j] := 0.0;
    end;

  for i := 0 to p do
  begin
    Atotals[i] := 0.0;
    Btotals[i] := 0.0;
    Grptotals[i] := 0.0;
  end;

  for i := 0 to p do
    for j := 0 to n do
      Subjtotals[i,j] := 0.0;

  sumxsqr := 0.0;
  term1 := 0.0;
  term2 := 0.0;
  term3 := 0.0;
  term4 := 0.0;
  term5 := 0.0;
  term6 := 0.0;
  term7 := 0.0;
  GrandMean := 0.0;

  //  Read in the data
  for i := 1 to NoCases do
  begin
    row := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
    col := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
    group := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Grpcol,i]));
    subject := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Sbjcol,i]));
    data := StrToFloat(OS3MainFrm.DataGrid.Cells[DataCol,i]);

    cellcnts[group-1,row-1] := cellcnts[group-1,row-1] + 1;
    ABCmat[group-1,row-1,subject-1] := ABCmat[group-1,row-1,subject-1] + data;
    Subjtotals[group-1,subject-1] := Subjtotals[group-1,subject-1] + data;
    GBmat[group-1,col-1] := GBmat[group-1,col-1] + data;
    Atotals[col-1] := Atotals[col-1] + data;
    Btotals[group-1] := Btotals[group-1] + data;
    Grptotals[group-1] := Grptotals[group-1] + data;
    sumxsqr := sumxsqr + (data * data);
    GrandMean := GrandMean + data;
  end;

  // check for equal cell counts
  for i := 0 to p-1 do
    for j := 0 to p-1 do
      if cellcnts[i,j] <> n then
      begin
        ErrorMsg('Cell sizes are not equal.');
        exit;
      end;

  // collapse subjects's into group x a matrix
  for i := 0 to p-1 do // group
    for j := 0 to p-1 do // factor a
      for k := 0 to n-1 do // subject
        ABmat[i,j] := ABmat[i,j] + ABCmat[i,j,k];

  // get marginal totals for ABmat and GBmat
  for i := 0 to p-1 do
    for j := 0 to p-1 do
    begin
      ABmat[p,j] := ABmat[p,j] + ABmat[i,j];
      ABmat[i,p] := ABmat[i,p] + ABmat[i,j];
      GBmat[p,j] := GBmat[p,j] + GBmat[i,j];
      GBmat[i,p] := GBmat[i,p] + GBmat[i,j];
    end;

  // get grand total for ABmat and GBmat
  for i := 0 to p-1 do
  begin
    ABmat[p,p] := ABmat[p,p] + ABmat[p,i];
    GBmat[p,p] := GBmat[p,p] + GBmat[p,i];
  end;

  // Get marginal totals for Subjtotals
  for i := 0 to p-1 do
    for j := 0 to n-1 do
    begin
      Subjtotals[p,j] := Subjtotals[p,j] + Subjtotals[i,j];
      Subjtotals[i,n] := Subjtotals[i,n] + Subjtotals[i,j];
    end;
  for i := 0 to p-1 do
    Subjtotals[p,n] := Subjtotals[p,n] + Subjtotals[i,n];

  // test block
  lReport := TStringList.Create;
  try
    lReport.Add('LATIN SQUARES REPEATED ANALYSIS Plan 6');
    lReport.Add('');
    lReport.Add('Sums for ANOVA Analysis');
    lReport.Add('');

    cellstring := 'Group - C (rows) times A Factor (columns) sums';
    MatPrint(ABmat, p+1, p+1, cellstring, RowLabels, ColLabels,n*p*p, lReport);

    cellstring := 'Group - C (rows) times B (cells Factor) sums';
    MatPrint(GBmat, p+1, p+1, cellstring, RowLabels, ColLabels, n*p*p, lReport);

    Title := 'Group - C (rows) times Subjects (columns) matrix';
    for i := 0 to n-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[n] := 'Total';
    MatPrint(Subjtotals, p+1, n+1, Title, RowLabels, ColLabels, n*p*p, lReport);

    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // get squared sum of subject's totals in each group
    for i := 0 to p-1 do // group
      term7 := term7 + (Subjtotals[i,n] * Subjtotals[i,n]);
    term7 := term7 / (n*p); // Sum G^2 sub k

    // now square each person score in each group and get sum for group
    for i := 0 to p-1 do
      for j := 0 to n-1 do
        Subjtotals[i,j] := Subjtotals[i,j] * Subjtotals[i,j];
    for i := 0 to p-1 do Subjtotals[i,n] := 0.0;
    for i := 0 to p-1 do
      for j := 0 to n-1 do
        Subjtotals[i,n] := Subjtotals[i,n] + Subjtotals[i,j];
    for i := 0 to p-1 do term6 := term6 + Subjtotals[i,n];
    SSsubwgrps := term6 / p - term7;

    // get correction term
    term1 := sqr(GrandMean) / (n * p * p);
    term2 := sumxsqr;

    // get sum of squared a's for term3
    for j := 0 to p-1 do
      term3 := term3 + sqr(ABmat[p,j]);
    term3 := term3 / (n * p);

    // get sum of squared groups for term4
    for i := 0 to p-1 do
      term4 := term4 + sqr(ABmat[i,p]);
    term4 := term4 / (n * p);

    // get squared sum of b's (across groups) for term5
    for j := 0 to p-1 do
      term5 := term5 + sqr(GBmat[p,j]);
    term5 := term5 / (n * p);

    SSgroups := term4 - term1;
    SSbetsubj := SSgroups + SSsubwgrps;
    SStotal := sumxsqr - term1;
    SSwithinsubj := SStotal - SSbetsubj;
    SSa := term3 - term1;
    SSb := term5 - term1;

    // get sum of squared AB cells for term6
    term6 := 0.0;
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        term6 := term6 + sqr(ABmat[i,j]);
    term6 := term6 / n;
    SSab := term6 - term3 - term5 + term1;
    SSab := SSab - SSgroups;
    SSerrwithin := ( sumxsqr - term6) - SSsubwgrps;

    // record degrees of freedom for sources
    dfbetsubj := n * p - 1;
    dfsubwgrps := p * (n-1);
    dfgroups := p - 1;
    dftotal := n * p * p - 1;
    dfwithinsubj := n * p * (p-1);
    dfa := p - 1;
    dfb := p - 1;
    dfab := (p - 1) * (p - 2);
    dferrwithin := p * (n - 1) * (p - 1);

    MSsubwgrps := SSsubwgrps / dfsubwgrps;
    MSgroups := SSgroups / dfgroups;
    MSa := SSa / dfa;
    MSb := SSb / dfb;
    MSab := SSab / dfab;
    MSerrwithin := SSerrwithin / dferrwithin;
    fgroups := MSgroups / MSsubwgrps;
    fa := MSa / MSerrwithin;
    fb := MSb / MSerrwithin;
    fab := MSab / MSerrwithin;
    probgrps := probf(fgroups,dfgroups,dfsubwgrps);
    proba := probf(fa,dfa,dferrwithin);
    probb := probf(fb,dfb,dferrwithin);
    probab := probf(fab,dfab,dferrwithin);

    // show ANOVA table results
    lReport.Add('LATIN SQUARES REPEATED ANALYSIS Plan 6');
    lReport.Add('');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Source         SS        DF        MS        F      Prob.>F');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Betw.Subj.%9.3f %9.0f', [SSbetsubj, dfbetsubj]);
    lReport.Add(' Factor C %9.3f %9.0f %9.3f %9.3f %9.3f', [SSgroups, dfgroups, MSgroups, fgroups, probgrps]);
    lReport.Add(' Subj.w.g.%9.3f %9.0f %9.3f', [SSsubwgrps, dfsubwgrps, MSsubwgrps]);
    lReport.Add('');
    lReport.Add('Within Sub%9.3f %9.0f',[ SSwithinsubj, dfwithinsubj]);
    lReport.Add(' Factor A %9.3f %9.0f %9.3f %9.3f %9.3f', [SSa, dfa, MSa, fa, proba]);
    lReport.Add(' Factor B %9.3f %9.0f %9.3f %9.3f %9.3f', [SSb, dfb, MSb, fb, probb]);
    lReport.Add(' Residual %9.3f %9.0f %9.3f %9.3f %9.3f', [SSab, dfab, MSab, fab, probab]);
    lReport.Add(' Error w. %9.3f %9.0f %9.3f', [SSerrwithin, dferrwithin, MSerrwithin]);
    lReport.Add('Total     %9.3f %9.0f', [SStotal, dftotal]);
    lReport.Add('-----------------------------------------------------------');

    // show design for Square
    lReport.Add('');
    lReport.Add('Experimental Design for Latin Square ');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format(' %3d ', [i]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    lReport.Add('  G    C  ');

    for i := 1 to NoCases do
    begin
      row := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i])); // A (column) effect
      col := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i])); // B (cell) effect
      group := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Grpcol,i])); // group (row)
      Design[group-1,row-1] := 'B' + IntToStr(col);
    end;

    for i := 0 to p - 1 do
    begin
      cellstring := Format('%3d  %3d  ', [i+1,i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format('%5s', [Design[i,j]]);
      lReport.Add(cellstring);
    end;

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    for i := 0 to p-1 do
      for j := 0 to p-1 do
        ABmat[i,j] := ABmat[i,j] / n;
    for i := 0 to p-1 do
      ABmat[i,p] := ABmat[i,p] / (n * p);
    for j := 0 to p-1 do
      ABmat[p,j] := ABmat[p,j] / (n * p);

    GrandMean := GrandMean / (p * p * n );
    for i := 0 to p-1 do
    begin
      Atotals[i] := Atotals[i] / (p * n);
      Btotals[i] := Btotals[i] / (p * n);
      Grptotals[i] := Grptotals[i] / (p * n);
    end;

    // show table of means for ABmat
    lReport.Add('');
    lReport.Add('Cell means and totals');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [GroupFactor]);
    lReport.Add(cellstring);

    for i := 0 to p-1 do
    begin
      cellstring := Format('   %3d    ', [i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format(' %8.3f ', [ABmat[i,j]]);
      cellstring := cellstring + Format(' %8.3f ', [ABmat[i,p]]);
      lReport.Add(cellstring);
    end;

    cellstring := 'Total     ';
    for j := 0 to p-1 do
      cellstring := cellstring + Format(' %8.3f ', [ABmat[p,j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    // show category means
    lReport.Add('');
    lReport.Add('Means for each variable');
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Atotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Btotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [GroupFactor]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Grptotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    DisplayReport(lReport);

  finally
    lReport.Free;

    GBmat := nil;
    ColLabels := nil;
    RowLabels := nil;
    Subjtotals := nil;
    Design := nil;
    Grptotals := nil;
    Btotals := nil;
    Atotals := nil;
    cellcnts := nil;
    ABCmat := nil;
    ABmat := nil;
  end;
end;

procedure TLatinSqrsFrm.Plan7;
var
  n: integer; // no. of subjects per cell
  Acol, Bcol, Ccol, SbjCol, Grpcol, DataCol: integer; // variable columns in grid
  FactorA: string;
  FactorB: string;
  SubjectFactor: string;
  FactorC: string;
  GroupFactor: string;
  DataVar: string;
  cellstring: string;
  i, j, k: integer;
  rangeA, rangeB, rangeC, rangeGrp: integer;
  mn, mx: Integer;
  cellcnts: IntDyneMat;
  ABmat: DblDyneMat;
  ABCmat: DblDyneCube;
  GBmat: DblDyneMat;
  GCmat: DblDyneMat;
  Atotals: DblDyneVec;
  Btotals: DblDyneVec;
  Ctotals: DblDyneVec;
  Grptotals: DblDyneVec;
  Subjtotals: DblDyneMat;
  design: StrDyneMat;
  term1, term2, term3, term4, term5, term6, term7, term8, term9: double;
  sumxsqr: double;
  SSbetsubj, SSgroups, SSsubwGrps, SSwithinsubj, SSa, SSb, SSc, SSab: double;
  SSerrwithin, SStotal, MSgroups, MSsubwGrps, MSa, MSb, MSc, MSab: double;
  MSerrwithin, DFbetsubj, DFgroups, DFsubwGrps, DFwithinsubj: double;
  DFa, DFb, DFc, DFab, DFerrwithin, DFtotal: double;
  data, GrandMean: double;
  p, row, col, slice, subject, group: integer;
  proba, probb, probc, probab, probgrps: double;
  fa, fb, fc, fab, fgroups: double;
  RowLabels, ColLabels: StrDyneVec;
  Title: string;
  lReport: TStrings;

begin
  LatinSpecsFrm.PrepareForPlan(7);
  if LatinSpecsFrm.ShowModal <> mrOK then
    exit;

  n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
  FactorA := LatinSpecsFrm.ACodeEdit.Text;
  FactorB := LatinSpecsFrm.BCodeEdit.Text;
  FactorC := LatinSpecsFrm.CCodeEdit.Text;
  SubjectFactor := LatinSpecsFrm.DCodeEdit.Text;
  GroupFactor := LatinSpecsFrm.GrpCodeEdit.Text;
  DataVar := LatinSpecsFrm.DepVarEdit.Text;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = FactorA) then Acol := i;
    if (cellstring = FactorB) then Bcol := i;
    if (cellstring = FactorC) then Ccol := i;
    if (cellstring = GroupFactor) then Grpcol := i;
    if (cellstring = SubjectFactor) then Sbjcol := i;
    if (cellstring = DataVar) then DataCol := i;
  end;

  // determine no. of levels in A, B, C and Group
  if not GetRange(ACol, rangeA, mn, mx) then exit;
  if not GetRange(BCol, rangeB, mn, mx) then exit;
  if not GetRange(CCol, rangeC, mn, mx) then exit;
  if not GetRange(GrpCol, rangeGrp, mn, mx) then exit;
  if not CheckDataCol(DataCol) then exit;
  p := rangeA;

  // check for squareness
  if (rangeA <> rangeB) or (rangeA <> rangeC) or (rangeA <> rangeGrp) then
  begin
    ErrorMsg('In a Latin square the range of values should be equal for A, B and C.');
    exit;
  end;

  // set up an array for cell counts and for cell sums and marginal sums
  SetLength(ABmat, p+1, p+1);
  SetLength(ABCmat, p+1, p+1, n+1);
  SetLength(cellcnts, p+1, p+1);
  SetLength(Atotals, p+1);
  SetLength(Btotals, p+1);
  SetLength(Ctotals, p+1);
  SetLength(Grptotals, p+1);
  SetLength(Design, p, p);
  SetLength(Subjtotals, p+1, n+1);
  SetLength(RowLabels, p+1);
  SetLength(ColLabels, n+1);
  SetLength(GBmat, p+1, p+1);
  SetLength(GCmat, p+1, p+1);

  for i := 0 to p-1 do
  begin
    RowLabels[i] := IntToStr(i+1);
    ColLabels[i] := RowLabels[i];
  end;
  RowLabels[p] := 'Total';
  ColLabels[p] := 'Total';

  for i := 0 to p do
    for j := 0 to p do
      for k := 0 to n do
        ABCmat[i,j,k] := 0.0;

  for i := 0 to p do
    for j := 0 to p do
    begin
      cellcnts[i,j] := 0;
      ABmat[i,j] := 0.0;
      GBmat[i,j] := 0.0;
      GCmat[i,j] := 0.0;
    end;

  for i := 0 to p do
  begin
    Atotals[i] := 0.0;
    Btotals[i] := 0.0;
    Ctotals[i] := 0.0;
    Grptotals[i] := 0.0;
  end;

  for i := 0 to p do
    for j := 0 to n do
      Subjtotals[i,j] := 0.0;

  sumxsqr := 0.0;
  term1 := 0.0;
  term2 := 0.0;
  term3 := 0.0;
  term4 := 0.0;
  term5 := 0.0;
  term6 := 0.0;
  term7 := 0.0;
  term8 := 0.0;
  term9 := 0.0;
  GrandMean := 0.0;

  //  Read in the data
  for i := 1 to NoCases do
  begin
    row := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i]));
    col := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i]));
    slice := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i]));
    group := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Grpcol,i]));
    subject := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Sbjcol,i]));
    data := StrToFloat(OS3MainFrm.DataGrid.Cells[DataCol,i]);
    cellcnts[group-1,row-1] := cellcnts[group-1,row-1] + 1;
    ABCmat[group-1,row-1,slice-1] := ABCmat[group-1,row-1,slice-1] + data;
    Subjtotals[group-1,subject-1] := Subjtotals[group-1,subject-1] + data;
    GBmat[group-1,col-1] := GBmat[group-1,col-1] + data;
    GCmat[group-1,slice-1] := GCmat[group-1,slice-1] + data;
    Atotals[row-1] := Atotals[row-1] + data;
    Btotals[col-1] := Btotals[col-1] + data;
    Ctotals[slice-1] := Ctotals[slice-1] + data;
    Grptotals[group-1] := Grptotals[group-1] + data;
    sumxsqr := sumxsqr + (data * data);
    GrandMean := GrandMean + data;
  end;

  // check for equal cell counts
  for i := 0 to p-1 do
    for j := 0 to p-1 do
      if cellcnts[i,j] <> n then
      begin
        ErrorMsg('Cell sizes are not  equal.');
        exit;
      end;

  // collapse slices into group x a matrix
  // result is the group times A matrix with BC cells containing n cases each
  for i := 0 to p-1 do // group
    for j := 0 to p-1 do // factor a
      for k := 0 to n-1 do // factor c
        ABmat[i,j] := ABmat[i,j] + ABCmat[i,j,k];

  // get marginal totals for ABmat, GBmat and GCmat
  for i := 0 to p-1 do
    for j := 0 to p-1 do
    begin
      ABmat[p,j] := ABmat[p,j] + ABmat[i,j];
      ABmat[i,p] := ABmat[i,p] + ABmat[i,j];
      GBmat[p,j] := GBmat[p,j] + GBmat[i,j];
      GBmat[i,p] := GBmat[i,p] + GBmat[i,j];
      GCmat[p,j] := GCmat[p,j] + GCmat[i,j];
      GCmat[i,p] := GCmat[i,p] + GCmat[i,j];
    end;

  // get grand total for ABmat, GBmat and GCmat
  for i := 0 to p-1 do
  begin
    ABmat[p,p] := ABmat[p,p] + ABmat[p,i];
    GBmat[p,p] := GBmat[p,p] + GBmat[p,i];
    GCmat[p,p] := GCmat[p,p] + GCmat[p,i];
  end;

  // Get marginal totals for Subjtotals
  for i := 0 to p-1 do // groups 1-p
    for j := 0 to n-1 do // subjects 1-n
    begin
      Subjtotals[p,j] := Subjtotals[p,j] + Subjtotals[i,j];
      Subjtotals[i,n] := Subjtotals[i,n] + Subjtotals[i,j];
    end;

  for i := 0 to p-1 do
    Subjtotals[p,n] := Subjtotals[p,n] + Subjtotals[i,n];

  lReport := TStringList.Create;
  try
    // test block
    lReport.Add('LATIN SQUARES REPEATED ANALYSIS Plan 7 (superimposed squares)');
    lReport.Add('');
    lReport.Add('Sums for ANOVA Analysis');
    lReport.Add('');

    cellstring := 'Group (rows) times A Factor (columns) sums';
    MatPrint(ABmat, p+1, p+1, cellstring, RowLabels, ColLabels, n*p*p, lReport);

    cellstring := 'Group (rows) times B (cells Factor) sums';
    MatPrint(GBmat, p+1, p+1, cellstring, RowLabels, ColLabels, n*p*p, lReport);

    cellstring := 'Group (rows) times C (cells Factor) sums';
    MatPrint(GCmat, p+1, p+1, cellstring, RowLabels, ColLabels, n*p*p, lReport);

    for i := 0 to n-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[n] := 'Total';

    Title := 'Group (rows) times Subjects (columns) sums';
    MatPrint(Subjtotals, p+1, n+1, Title, RowLabels, ColLabels, n*p*p, lReport);

    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // get squared sum of subject's totals in each group
    for i := 0 to p-1 do // group
      term7 := term7 + (Subjtotals[i,n] * Subjtotals[i,n]);
    term7 := term7 / (n*p); // Sum G^2 sub k

    // now square each person score in each group and get sum for group
    for i := 0 to p-1 do // groups
      for j := 0 to n-1 do // subjects
        Subjtotals[i,j] := Subjtotals[i,j] * Subjtotals[i,j];
    for i := 0 to p-1 do Subjtotals[i,n] := 0.0; // clear group totals

    // get sum of squared person scores in each group
    for i := 0 to p-1 do // groups
      for j := 0 to n-1 do // subjects
        Subjtotals[i,n] := Subjtotals[i,n] + Subjtotals[i,j];

    // get sum of squares for subjects within groups
    for i := 0 to p-1 do term6 := term6 + Subjtotals[i,n];
    SSsubwgrps := (term6 / p) - term7;

    // get correction term and term for total sum of squares
    term1 := sqr(GrandMean) / (n * p * p);
    term2 := sumxsqr;

    // get sum of squared groups for term4 of sum of squares for groups
    for i := 0 to p-1 do
      term4 := term4 + sqr(Grptotals[i]);
    term4 := term4 / (n * p);

    // get sum of squared a's for term3
    for j := 0 to p-1 do // levels of a
      term3 := term3 + sqr(Atotals[j]);
    term3 := term3 / (n * p);

    // get squared sum of b's (across groups) for term5 of sum of squares b
    for j := 0 to p-1 do
      term5 := term5 + sqr(Btotals[j]);
    term5 := term5 / (n * p);

    // get squared sum of c's (across groups) for term8 of SS for c
    for j := 0 to p-1 do
      term8 := term8 + sqr(Ctotals[j]);
    term8 := term8 / (n * p);

    SSgroups := term4 - term1;
    SSbetsubj := SSgroups + SSsubwgrps;
    SStotal := term2 - term1;
    SSwithinsubj := SStotal - SSbetsubj;
    SSa := term3 - term1;
    SSb := term5 - term1;
    SSc := term8 - term1;

    // get sum of squared AB cells for term6
    term6 := 0.0;
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        term6 := term6 + sqr(ABmat[i,j]);
    term9 := term6 / n - term1;
    term6 := sumxsqr - (term6 / n); // SS within cells from sum squared x's
    SSerrwithin := term6 - SSsubwgrps;
    SSab := term9 - (SSa + SSb + SSc + SSgroups); // residual

    // record degrees of freedom for sources
    dfbetsubj := n * p - 1;
    dfsubwgrps := p * (n-1);
    dfgroups := p - 1;
    dftotal := n * p * p - 1;
    dfwithinsubj := n * p * (p-1);
    dfa := p - 1;
    dfb := p - 1;
    dfc := p - 1;
    dfab := (p - 1) * (p - 3);
    dferrwithin := p * (n - 1) * (p - 1);

    MSsubwgrps := SSsubwgrps / dfsubwgrps;
    MSgroups := SSgroups / dfgroups;
    MSa := SSa / dfa;
    MSb := SSb / dfb;
    MSc := SSc / dfc;
    if dfab > 0 then MSab := SSab / dfab;
    MSerrwithin := SSerrwithin / dferrwithin;
    fgroups := MSgroups / MSsubwgrps;
    fa := MSa / MSerrwithin;
    fb := MSb / MSerrwithin;
    fc := MSc / MSerrwithin;
    if dfab > 0 then fab := MSab / MSerrwithin;
    probgrps := probf(fgroups, dfgroups, dfsubwgrps);
    proba := probf(fa, dfa, dferrwithin);
    probb := probf(fb, dfb, dferrwithin);
    probc := probf(fc, dfc, dferrwithin);
    probab := probf(fab, dfab, dferrwithin);

    // show ANOVA table results
    lReport.Add('LATIN SQUARES REPEATED ANALYSIS Plan 7 (superimposed squares)');
    lReport.Add('');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Source         SS        DF        MS        F      Prob.>F');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Betw.Subj.%9.3f %9.0f', [SSbetsubj, dfbetsubj]);
    lReport.Add(' Groups   %9.3f %9.0f %9.3f %9.3f %9.3f', [SSgroups, dfgroups, MSgroups, fgroups, probgrps]);
    lReport.Add(' Subj.w.g.%9.3f %9.0f %9.3f', [SSsubwgrps, dfsubwgrps, MSsubwgrps]);
    lReport.Add('');
    lReport.Add('Within Sub%9.3f %9.0f', [SSwithinsubj, dfwithinsubj]);
    lReport.Add(' Factor A %9.3f %9.0f %9.3f %9.3f %9.3f', [SSa, dfa, MSa, fa, proba]);
    lReport.Add(' Factor B %9.3f %9.0f %9.3f %9.3f %9.3f', [SSb, dfb, MSb, fb, probb]);
    lReport.Add(' Factor C %9.3f %9.0f %9.3f %9.3f %9.3f', [SSc, dfc, MSc, fc, probc]);
    if dfab > 0 then
      lReport.Add(' residual %9.3f %9.0f %9.3f %9.3f %9.3f', [SSab, dfab, MSab, fab, probab])
    else
       lReport.Add(' residual      -    %9.0f      -', [dfab]);
    lReport.Add(' Error w. %9.3f %9.0f %9.3f', [SSerrwithin, dferrwithin, MSerrwithin]);
    lReport.Add('Total     %9.3f %9.0f', [SStotal, dftotal]);
    lReport.Add('-----------------------------------------------------------');

    // show design for Square
    lReport.Add('');
    lReport.Add('Experimental Design for Latin Square ');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format(' %3d ', [i]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [GroupFactor]);
    lReport.Add(cellstring);

    for i := 1 to NoCases do
    begin
      row := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i])); // A (column) effect
      col := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i])); // B (cell) effect
      slice := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i])); // C (cell) effect
      group := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Grpcol,i])); // group (row)
      Design[group-1,row-1] := 'BC' + IntToStr(col) + IntToStr(slice);
    end;

    for i := 0 to p - 1 do
    begin
      cellstring := Format('   %3d    ', [i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format('%5s', [Design[i,j]]);
      lReport.Add(cellstring);
    end;

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    // get means
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        ABmat[i,j] := ABmat[i,j] / n;
    for i := 0 to p-1 do
      ABmat[i,p] := ABmat[i,p] / (n * p);
    for j := 0 to p-1 do
      ABmat[p,j] := ABmat[p,j] / (n * p);

    GrandMean := GrandMean / (p * p * n );
    for i := 0 to p-1 do
    begin
      Atotals[i] := Atotals[i] / (p * n);
      Btotals[i] := Btotals[i] / (p * n);
      Ctotals[i] := Ctotals[i] / (p * n);
      Grptotals[i] := Grptotals[i] / (p * n);
    end;

    // show table of means for ABmat
    // means for Groups by A matrix
    lReport.Add('');
    lReport.Add('Cell means and totals');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [GroupFactor]);
    lReport.Add(cellstring);

    for i := 0 to p-1 do
    begin
      cellstring := Format('   %3d    ', [i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + Format(' %8.3f ', [ABmat[i,j]]);
        cellstring := cellstring + Format(' %8.3f ', [ABmat[i,p]]);
        lReport.Add(cellstring);
    end;

    cellstring := 'Total     ';
    for j := 0 to p-1 do
      cellstring := cellstring + Format(' %8.3f ', [ABmat[p,j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    // show category means
    lReport.Add('');
    lReport.Add('Means for each variable');
    lReport.Add('');

    // factor A means
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorA]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);

    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Atotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    // means for B
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorB]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Btotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    // C means
    lReport.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := Format('%10s', [FactorC]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Ctotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    // Group means
    lReport.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);
    cellstring := Format('%10s', [GroupFactor]);
    for i := 1 to p do cellstring := cellstring + Format('   %3d    ', [i]);
    cellstring := cellstring + '    Total';
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    cellstring := '          ';
    for j := 0 to p - 1 do
      cellstring := cellstring + Format(' %8.3f ', [Grptotals[j]]);
    cellstring := cellstring + Format(' %8.3f ', [GrandMean]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    lReport.Add(cellstring);

    DisplayReport(lReport);

  finally
    lReport.Free;

    GCmat := nil;
    GBmat := nil;
    ColLabels := nil;
    RowLabels := nil;
    Subjtotals := nil;
    Design := nil;
    Grptotals := nil;
    Ctotals := nil;
    Btotals := nil;
    Atotals := nil;
    cellcnts := nil;
    ABCmat := nil;
    ABmat := nil;
  end;
end;

procedure TLatinSqrsFrm.Plan9;
var
  row, col, slice, group, index: integer;
  Acol, Bcol, Ccol, SbjCol, Grpcol, DataCol: integer; // variable columns in grid
  FactorA: string;
  FactorB: string;
  FactorC: string;
  SubjectFactor: string;
  GroupFactor: string;
  DataVar: string;
  cellstring: string;
  i, j, k, m: integer;
  mn, mx: Integer;
  n, subject, nosubjects, rangeA, rangeB, rangeC, rangeGrp: integer;
  p, q, rows: integer;
  ABC, AGC: DblDyneCube;
  AB, AC, BC, RC: DblDyneMat;
  A, B, C, Persons, Gm, R: DblDyneVec;
  cellcnts: IntDyneVec;
  Design: StrDyneMat;
  RowLabels: StrDyneVec;
  ColLabels: StrDyneVec;
  G, sumxsqr, sumAsqr, sumBsqr, sumABsqr, sumACsqr: double;
  sumBCsqr, sumABCsqr, sumPsqr, sumGmsqr, sumRsqr: double;
  SSbetsubj, SSc, SSrows, SScxrow, SSsubwgrps, SSa: double;
  SSwithinsubj, SSerrwithin: double;
  SSb, SSac, SSbc, SSabprime, SSABCprime, SStotal: double;
  term1, term2, term3, term4, term5, term6, term7, term8, term9, term10: double;
  term11, term12: double;
  dfc, dfrows, dfcxrow, dfsubwgrps, dfwithinsubj, dfa, dfb,dfac: double;
  dfbc, dfabprime, dfabcprime,dferrwithin, dftotal, dfbetsubj: double;
  MSc, MSrows, MScxrow, MSsubwgrps, MSa: double;
  MSb, MSac, MSbc, MSabprime, MSabcprime, MSerrwithin: double;
  fc, frows, fcxrow, fsubwgrps, fa, fb, fac, fbc, fabprime, fabcprime: double;
  probc, probrows, probcxrow, probsubwgrps, proba, probb: double;
  probac, probbc, probabprime, probabcprime: double;
  data, value: double;
  lReport: TStrings;

begin
  cellstring := LatinSpecsFrm.DCodeLabel.Caption; // get current label
  LatinSpecsFrm.DCodeLabel.Caption := 'Subject No.'; // set new label
  LatinSpecsFrm.PrepareForPlan(9);
  if LatinSpecsFrm.ShowModal <> mrOK then
    exit;

  LatinSpecsFrm.DCodeLabel.Caption := cellstring; // restore label

  n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text); // no. persons per cell
  FactorA := LatinSpecsFrm.ACodeEdit.Text;
  FactorB := LatinSpecsFrm.BCodeEdit.Text;
  FactorC := LatinSpecsFrm.CCodeEdit.Text;
  SubjectFactor := LatinSpecsFrm.DCodeEdit.Text;
  GroupFactor := LatinSpecsFrm.GrpCodeEdit.Text;
  DataVar := LatinSpecsFrm.DepVarEdit.Text;

  for i := 1 to NoVariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = FactorA) then Acol := i;
    if (cellstring = FactorB) then Bcol := i;
    if (cellstring = FactorC) then Ccol := i;
    if (cellstring = GroupFactor) then Grpcol := i;
    if (cellstring = SubjectFactor) then Sbjcol := i;
    if (cellstring = DataVar) then DataCol := i;
  end;

  // determine no. of levels in A, B, C and Group
  if not GetRange(ACol, rangeA, mn, mx) then exit;
  if not GetRange(BCol, rangeB, mn, mx) then exit;
  if not GetRange(CCol, rangeC, mn, mx) then exit;
  if not GetRange(GrpCol, rangeGrp, mn, mx) then exit;
  if not CheckDataCol(DataCol) then exit;
  p := rangeA;
  q := rangeC;

  nosubjects := 0;
  for i := 1 to NoCases do
  begin
    if TryStrToFloat(OS3MainFrm.DataGrid.Cells[SbjCol,i], value) then
    begin
      if value > nosubjects then nosubjects := round(value);
    end else
    begin
      ErrorMsg(NO_VALID_NUMBER_ERROR, [i, SubjectFactor]);
      exit;
    end;
  end;

  // check for squareness
  if (rangeA <> rangeB) then
  begin
    ErrorMsg('In a Latin square the range of values should be equal for A,B and C.');
    exit;
  end;

  // set up an array for cell counts and for cell sums and marginal sums
  SetLength(ABC, p+1, p+1, q+1);
  SetLength(AGC, p+1, rangegrp+1, q+1);
  SetLength(AB, p+1, p+1);
  SetLength(AC, p+1, q+1);
  SetLength(BC, p+1, q+1);
  SetLength(RC, (rangegrp div q)+1, q+1);
  SetLength(A, p+1);
  SetLength(B, p+1);
  SetLength(C, q+1);
  SetLength(Persons, nosubjects+1);
  SetLength(Gm, rangegrp+1);
  SetLength(R, p+1);
  SetLength(cellcnts, p+1);
  SetLength(Design, rangegrp, p);
  SetLength(RowLabels, MaxValue([n, p, rangegrp, nosubjects])+1);
  SetLength(ColLabels, MaxValue([n, p, rangeGrp, nosubjects])+1);

  // initialize arrays
  for i := 0 to p-1 do
  begin
    RowLabels[i] := IntToStr(i+1);
    ColLabels[i] := RowLabels[i];
  end;
  RowLabels[p] := 'Total';
  ColLabels[p] := 'Total';

  for i := 0 to p do
    for j := 0 to p do
      for k := 0 to q do
        ABC[i,j,k] := 0.0;

  for i := 0 to p do
    for j := 0 to rangegrp do
      for k := 0 to q do
        AGC[i,j,k] := 0.0;

  for i := 0 to p do
    for j := 0 to p do
      AB[i,j] := 0.0;

  for i := 0 to p do
    for j := 0 to q do
      AC[i,j] := 0.0;

  for i := 0 to p do
    for j := 0 to q do
      BC[i,j] := 0.0;

  for i := 0 to p do
    for j := 0 to q do
      RC[i,j] := 0.0;

  for i := 0 to p do A[i] := 0.0;
  for i := 0 to p do B[i] := 0.0;
  for i := 0 to q do C[i] := 0.0;
  for i := 0 to nosubjects do Persons[i] := 0.0;
  for i := 0 to rangegrp do Gm[i] := 0.0;
  for i := 0 to p do R[i] := 0.0;
  for i := 0 to p do cellcnts[i] := 0;

  // initialize single values
  G := 0.0;
  sumxsqr := 0.0;
  sumAsqr := 0.0;
  sumBsqr := 0.0;
  sumABsqr := 0.0;
  sumACsqr := 0.0;
  sumBCsqr := 0.0;
  sumABCsqr := 0.0;
  sumRsqr := 0.0;
  sumGmsqr := 0.0;
  sumRsqr := 0.0;
  sumPsqr := 0.0;
  term2 := 0.0;
  term3 := 0.0;
  term4 := 0.0;
  term5 := 0.0;
  term6 := 0.0;
  term7 := 0.0;
  term8 := 0.0;
  term9 := 0.0;
  term10 := 0.0;
  term11 := 0.0;
  term12 := 0.0;

  //  Read in the data
  for index := 1 to NoCases do
  begin
    i := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,index]));
    j := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,index]));
    k := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,index]));
    m := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Grpcol,index]));
    subject := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Sbjcol,index]));
    data := StrToFloat(OS3MainFrm.DataGrid.Cells[DataCol,index]);
    cellcnts[j-1] := cellcnts[j-1] + 1;
    ABC[i-1,j-1,k-1] := ABC[i-1,j-1,k-1] + data;
    AGC[i-1,m-1,k-1] := AGC[i-1,m-1,k-1] + data;
    AB[i-1,j-1] := AB[i-1,j-1] + data;
    AC[i-1,k-1] := AC[i-1,k-1] + data;
    BC[j-1,k-1] := BC[j-1,k-1] + data;
    A[i-1] := A[i-1] + data;
    B[j-1] := B[j-1] + data;
    C[k-1] := C[k-1] + data;
    Gm[m-1] := Gm[m-1] + data;
    Persons[subject-1] := Persons[subject-1] + data;
    sumxsqr := sumxsqr + (data * data);
    G := G + data;
  end;

  // check for equal cell counts in b treatments
  for i := 1 to p-1 do
    if cellcnts[i-1] <> cellcnts[i] then
    begin
      ErrorMsg('Cell sizes are not  equal.');
      exit;
    end;

  // get sums in the RC matrix
  rows := rangegrp div q;
  for i := 0 to rows - 1 do
    for j := 0 to q-1 do
    begin
//            k := (i * q) + j;
      k := i + q * j;
      RC[i,j] := Gm[k];
    end;

  // get marginal totals for RC array
  for i := 0 to rows -1 do
    for j := 0 to q-1 do
    begin
      RC[i,q] := RC[i,q] + RC[i,j];
      RC[rows,j] := RC[rows,j] + RC[i,j];
    end;

  // get marginal totals for arrays ABC and AGC
  for i := 0 to p-1 do
    for j := 0 to p-1 do
    begin
      for k := 0 to q-1 do
      begin
        ABC[i,j,q] := ABC[i,j,q] + ABC[i,j,k];
        ABC[i,p,k] := ABC[i,p,k] + ABC[i,j,k];
        ABC[p,j,k] := ABC[p,j,k] + ABC[i,j,k];
      end;
    end;

  for i := 0 to p-1 do
    for j := 0 to rangegrp - 1 do
      for k := 0 to q-1 do
      begin
        AGC[i,j,q] := AGC[i,j,q] + AGC[i,j,k];
        AGC[i,rangegrp,k] := AGC[i,rangegrp,k] + AGC[i,j,k];
        AGC[p,j,k] := AGC[p,j,k] + AGC[i,j,k];
      end;

  for i := 0 to p-1 do
    for j := 0 to q-1 do
    begin
      AC[p,j] := AC[p,j] + AC[i,j];
      AC[i,q] := AC[i,q] + AC[i,j];
      BC[p,j] := BC[p,j] + BC[i,j];
      BC[i,q] := BC[i,q] + BC[i,j];
    end;

  // get grand total for AC, BC and RC
  for i := 0 to q-1 do
  begin
    AC[p,q] := AC[p,q] + AC[p,i];
    BC[p,q] := BC[p,q] + BC[p,i];
    RC[p,q] := RC[p,q] + RC[p,i];
  end;

  // get margins and totals in AB matrix
  for i := 0 to p-1 do
    for j := 0 to p-1 do
    begin
      AB[p,j] := AB[p,j] + AB[i,j];
      AB[i,p] := AB[i,p] + AB[i,j];
    end;
  for i := 0 to p-1 do
    AB[p,p] := AB[p,p] + AB[i,p];

  // get total for groups
  for m := 0 to rangegrp - 1 do
    Gm[rangegrp] := Gm[rangegrp] + Gm[m];

  // test block
  lReport := TStringList.Create;
  try
    lReport.Add('LATIN SQUARES REPEATED ANALYSIS Plan 9');
    lReport.Add('');
    lReport.Add('Sums for ANOVA Analysis');
    lReport.Add('');
    lReport.Add('ABC matrix');
    lReport.Add('');
    for k := 0 to q-1 do
    begin
      lReport.Add('C level %d', [k+1]);
      cellstring := '          ';
      for j := 0 to p-1 do cellstring := cellstring + Format('  %3d     ', [j+1]);
      lReport.Add(cellstring);

      // row
      for i := 0 to p-1 do
      begin
        cellstring := Format('  %3d     ', [i+1]);
        for j := 0 to p-1 do
          cellstring := cellstring + Format('%9.3f ', [ABC[i,j,k]]);
        lReport.Add(cellstring);
      end;
      lReport.Add('');
      lReport.Add('');
    end;

    cellstring := 'AB sums';
    MatPrint(AB, p+1, p+1, cellstring, RowLabels, ColLabels, n*p*q, lReport);

    cellstring := 'AC sums';
    MatPrint(AC, p+1, q+1, cellstring, RowLabels, ColLabels, n*p*q, lReport);

    cellstring := 'BC sums';
    MatPrint(BC, p+1, q+1, cellstring, RowLabels, ColLabels, n*p*q, lReport);

    cellstring := 'RC sums';
    MatPrint(RC, rows+1, q+1, cellstring, RowLabels, ColLabels, n*p*q, lReport);

    cellstring := 'Group totals';
    for i := 0 to rangegrp-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[rangegrp] := 'Total';
    DynVectorPrint(Gm, rangegrp+1, cellstring, ColLabels, n*p*q, lReport);
    for i := 0 to nosubjects-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[nosubjects] := 'Total';
    cellstring := 'Subjects sums';
    DynVectorPrint(Persons, nosubjects+1, cellstring, ColLabels, n*p*q, lReport);

    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    term1 := (G * G) / (n * p * p * q);
    term2 := sumXsqr;
    for i := 0 to p-1 do term3 := term3 + (A[i] * A[i]);
    term3 := term3 / (n * p * q);
    for i := 0 to p-1 do term4 := term4 + (B[i] * B[i]);
    term4 := term4 / (n * p * q);
    for i := 0 to q-1 do term5 := term5 + (C[i] * C[i]);
    term5 := term5 / (n * p * p);
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        term6 := term6 + (AB[i,j] * AB[i,j]);
    term6 := term6 / (n * q);
    for i := 0 to p-1 do
      for j := 0 to q-1 do
        term7 := term7 + (AC[i,j] * AC[i,j]);
    term7 := term7 / (n * p);
    for i := 0 to p-1 do
      for j := 0 to q-1 do
        term8 := term8 + (BC[i,j] * BC[i,j]);
    term8 := term8 / (n * p);
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        for k := 0 to q-1 do
          term9 := term9 + (ABC[i,j,k] * ABC[i,j,k]);
    term9 := term9 / n;
    for i := 0 to nosubjects-1 do term10 := term10 + (persons[i] * persons[i]);
    term10 := term10 / p;
    for i := 0 to rangegrp-1 do term11 := term11 + (Gm[i] * Gm[i]);
    term11 := term11 / (n * p);
    for i := 0 to rows-1 do term12 := term12 + (RC[i,q] * RC[i,q]);
    term12 := term12 / (n * p * q);

    // term check
    lReport.Add('COMPUTATION TERMS');
    lReport.Add('Term1:  %9.3f', [term1]);
    lReport.Add('Term2:  %9.3f', [term2]);
    lReport.Add('Term3:  %9.3f', [term3]);
    lReport.Add('Term4:  %9.3f', [term4]);
    lReport.Add('Term5:  %9.3f', [term5]);
    lReport.Add('Term6:  %9.3f', [term6]);
    lReport.Add('Term7:  %9.3f', [term7]);
    lReport.Add('Term8:  %9.3f', [term8]);
    lReport.Add('Term9:  %9.3f', [term9]);
    lReport.Add('Term10: %9.3f', [term10]);
    lReport.Add('Term11: %9.3f', [term11]);
    lReport.Add('Term12: %9.3f', [term12]);

    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // now get sums of squares
    SSbetsubj := term10 - term1;
    SSc := term5 - term1;
    SSrows := term12 - term1;
    SScxrow := term11 - term5 - term12 + term1;
    SSsubwgrps := term10 - term11;
    SSwithinsubj := term2 - term10;
    SSa := term3 - term1;
    SSb := term4 - term1;
    SSac := term7 - term3 - term5 + term1;
    SSbc := term8 - term4 - term5 + term1;
    SSabprime := (term6 - term3 - term4 + term1) - (term12 - term1);
    SSabcprime := (term9 - term6 - term7 - term8 + term3 + term4 + term5 - term1)
         - (term11 - term5 - term12 + term1);
    SSerrwithin := term2 - term10 - term9 + term11;
    SStotal := term2 - term1;

    // record degrees of freedom for sources
    dfbetsubj := n * p * q - 1;
    dfc := q - 1;
    dfrows := p - 1;
    dfcxrow := (p-1) * (q-1);
    dfsubwgrps := p * q * (n-1);
    dfwithinsubj := n * p * q * (p-1);
    dfa := p - 1;
    dfb := p - 1;
    dfac := (p - 1) * (q - 1);
    dfbc := (p - 1) * (q - 1);
    dfabprime := (p - 1) * (p - 2);
    dfabcprime := (p - 1) * (p - 2) * (q - 1);
    dferrwithin := p * q * (n - 1) * (p - 1);
    dftotal := n * p * p * q  - 1;

    MSc := SSc / dfc;
    MSrows := SSrows / dfrows;
    MScxrow := SScxrow / dfcxrow;
    MSsubwgrps := SSsubwgrps / dfsubwgrps;
    MSa := SSa / dfa;
    MSb := SSb / dfb;
    MSac := SSac / dfac;
    MSbc := SSbc / dfbc;
    MSabprime := SSabprime / dfabprime;
    MSabcprime := SSabcprime / dfabcprime;
    MSerrwithin := SSerrwithin / dferrwithin;

    fc := MSc / MSsubwgrps;
    frows := MSrows / MSsubwgrps;
    fcxrow := MScxrow / MSsubwgrps;
    fsubwgrps := MSsubwgrps / MSerrwithin;
    fa := MSa / MSerrwithin;
    fb := MSb / MSerrwithin;
    fac := MSac / MSerrwithin;
    fbc := MSbc / MSerrwithin;
    fabprime := MSabprime / MSerrwithin;
    fabcprime := MSabcprime / MSerrwithin;

    probc := probf(fc,dfc,dfsubwgrps);
    probrows := probf(frows,dfrows,dfsubwgrps);
    probcxrow := probf(fcxrow,dfcxrow,dfsubwgrps);
    probsubwgrps := probf(fsubwgrps,dfsubwgrps,dferrwithin);
    proba := probf(fa,dfa,dferrwithin);
    probb := probf(fb,dfb,dferrwithin);
    probac := probf(fac,dfac,dferrwithin);
    probbc := probf(fbc,dfbc,dferrwithin);
    probabprime := probf(fabprime,dfabprime,dferrwithin);
    probabcprime := probf(fabcprime,dfabcprime,dferrwithin);

    // show ANOVA table results
    lReport.Add('LATIN SQUARES REPEATED ANALYSIS Plan 9');
    lReport.Add('');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Source         SS        DF        MS        F      Prob.>F');
    lReport.Add('-----------------------------------------------------------');
    lReport.Add('Betw.Subj.%9.3f %9.0f', [SSbetsubj, dfbetsubj]);
    lReport.Add(' Factor C %9.3f %9.0f %9.3f %9.3f %9.3f', [SSc, dfc, MSc, fc, probc]);
    lReport.Add(' Rows     %9.3f %9.0f %9.3f %9.3f %9.3f', [SSrows, dfrows, MSrows, frows, probrows]);
    lReport.Add(' C x row  %9.3f %9.0f %9.3f %9.3f %9.3f', [SScxrow, dfcxrow, MScxrow, fcxrow, probcxrow]);
    lReport.Add(' Subj.w.g.%9.3f %9.0f %9.3f', [SSsubwgrps, dfsubwgrps, MSsubwgrps]);
    lReport.Add('');
    lReport.Add('Within Sub%9.3f %9.0f', [SSwithinsubj, dfwithinsubj]);
    lReport.Add(' Factor A %9.3f %9.0f %9.3f %9.3f %9.3f', [SSa, dfa, MSa, fa, proba]);
    lReport.Add(' Factor B %9.3f %9.0f %9.3f %9.3f %9.3f', [SSb, dfb, MSb, fb, probb]);
    lReport.Add(' Factor AC%9.3f %9.0f %9.3f %9.3f %9.3f', [SSac, dfac, MSac, fac, probac]);
    lReport.Add(' Factor BC%9.3f %9.0f %9.3f %9.3f %9.3f', [SSbc, dfbc, MSbc, fbc, probbc]);
    lReport.Add(' AB prime %9.3f %9.0f %9.3f %9.3f %9.3f', [SSabprime, dfabprime, MSabprime, fabprime, probabprime]);
    lReport.Add(' ABC prime%9.3f %9.0f %9.3f %9.3f %9.3f', [SSabcprime, dfabcprime, MSabcprime, fabcprime, probabcprime]);
    lReport.Add(' Error w. %9.3f %9.0f %9.3f', [SSerrwithin, dferrwithin, MSerrwithin]);
    lReport.Add('');
    lReport.Add('Total     %9.3f %9.0f', [SStotal,  dftotal]);
    lReport.Add('-----------------------------------------------------------');

    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // show design for Squares c1, c2, etc.
    lReport.Add('Experimental Design for Latin Square ');
    lReport.Add('');

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + Format(' %3d ', [i]);
    lReport.Add(cellstring);

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    lReport.Add('%10s', [GroupFactor]);
    for i := 1 to NoCases do
    begin
      row := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Acol,i])); // A (column) effect
      col := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Bcol,i])); // B (cell) effect
      slice := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Ccol,i])); // C (cell) effect
      group := round(StrToFloat(OS3MainFrm.DataGrid.Cells[Grpcol,i])); // group (row)
      Design[group-1, row-1] := 'B' + IntToStr(col);
    end;

    for i := 0 to rangegrp - 1 do
    begin
      cellstring := format('   %3d    ',[i+1]);
      for j := 0 to p - 1 do
        cellstring := cellstring + format('%5s', [Design[i,j]]);
      lReport.Add(cellstring);
    end;

    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    lReport.Add(cellstring);

    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');

    // get means
    G := G / (p * p * q * n );
    for i := 0 to p-1 do
      for j := 0 to p-1 do
        for k := 0 to q-1 do
          ABC[i,j,k] := ABC[i,j,k] / n;

    for i := 0 to p-1 do
      for j := 0 to p-1 do
        AB[i,j] := AB[i,j] / (n * p);
    for i := 0 to p-1 do AB[i,p] := AB[i,p] / (n * p * p);
    for j := 0 to p-1 do AB[p,j] := AB[p,j] / (n * p * p);
    AB[p,p] := G;

    for i := 0 to p-1 do
      for j := 0 to q-1 do
        AC[i,j] := AC[i,j] / (n * p);
    for i := 0 to p-1 do AC[i,q] := AC[i,q] / (n * p * p);
    for j := 0 to q-1 do AC[p,j] := AC[p,j] / (n * p * p);
    AC[p,q] := G;

    for i := 0 to p-1 do
      for j := 0 to q-1 do
        BC[i,j] := BC[i,j] / (n * p);
    for i := 0 to p-1 do BC[i,q] := BC[i,q] / (n * p * p);
    for j := 0 to q-1 do BC[p,j] := BC[p,j] / (n * p * p);
    BC[p,q] := G;

    for i := 0 to rows-1 do
      for j := 0 to q-1 do
        RC[i,j] := RC[i,j] / (p * n);
    for i := 0 to rows-1 do RC[i,q] := RC[i,q] / (p * q * n);
    for j := 0 to q-1 do RC[p,j] := RC[p,j] / (q * p * n);
    RC[p,q] := G;

    for i := 0 to p-1 do
    begin
      A[i] := A[i] / (p * n * q);
      B[i] := B[i] / (p * n * q);
    end;
    A[p] := G;
    B[p] := G;

    for i := 0 to q-1 do C[i] := C[i] / (p * q * n);
    C[q] := G;

    for i := 0 to rangegrp-1 do Gm[i] := Gm[i] / (p * n);
    Gm[rangegrp] := G;

    for i := 0 to nosubjects-1 do Persons[i] := Persons[i] / n;
    Persons[nosubjects] := G;

    lReport.Add('LATIN SQUARES REPEATED ANALYSIS PLAN 9');
    lReport.Add('');
    lReport.Add('Means for ANOVA Analysis');
    lReport.Add('');
    lReport.Add('ABC matrix');
    lReport.Add('');
    for k := 0 to q-1 do
    begin
      lReport.Add('C level %d', [k+1]);

      cellstring := '          ';
      for j := 0 to p-1 do cellstring := cellstring + Format('  %3d     ', [j+1]);
      lReport.Add(cellstring);

      for i := 0 to p-1 do // row
      begin
        cellstring := Format('  %3d     ', [i+1]);
        for j := 0 to p-1 do
          cellstring := cellstring + Format('%9.3f ', [ABC[i,j,k]]);
        lReport.Add(cellstring);
      end;
      lReport.Add('');
      lReport.Add('');
    end;

    cellstring := 'AB Means';
    MatPrint(AB, p+1, p+1, cellstring, RowLabels, ColLabels, n*p*p*q, lReport);

    cellstring := 'AC Means';
    MatPrint(AC, p+1, q+1, cellstring, RowLabels, ColLabels, n*p*p*q, lReport);

    cellstring := 'BC Means';
    MatPrint(BC, p+1, q+1, cellstring, RowLabels, ColLabels, n*p*p*q, lReport);

    cellstring := 'RC Means';
    MatPrint(RC, rows+1, q+1, cellstring, RowLabels, ColLabels, n*p*p*q, lReport);

    cellstring := 'Group Means';
    for i := 0 to rangegrp-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[rangegrp] := 'Total';
    DynVectorPrint(Gm, rangegrp+1, cellstring, ColLabels, n*p*p*q, lReport);
    for i := 0 to nosubjects-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[nosubjects] := 'Total';
    cellstring := 'Subjects Means';
    DynVectorPrint(Persons, nosubjects+1, cellstring, ColLabels, n*p*p*q, lReport);

    DisplayReport(lReport);

  finally
    lReport.Free;

    ColLabels := nil;
    RowLabels := nil;
    Design := nil;
    cellcnts := nil;
    R := nil;
    Gm := nil;
    Persons := nil;
    C := nil;
    B := nil;
    A := nil;
    RC := nil;
    BC := nil;
    AC := nil;
    AB := nil;
    AGC := nil;
    ABC := nil;
  end;
end;

initialization
  {$I latinsqrsunit.lrs}

end.

