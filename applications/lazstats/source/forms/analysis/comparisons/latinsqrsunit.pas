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
    CancelBtn: TButton;
    HelpBtn: TButton;
    OKBtn: TButton;
    Plan: TRadioGroup;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure PlanClick(Sender: TObject);
  private
    { private declarations }
       Btn : integer;
       procedure Plan1(Sender: TObject);
       procedure Plan2(Sender: TObject);
       procedure Plan3(Sender: TObject);
       procedure Plan4(Sender: TObject);
       procedure Plan5(Sender: TObject);
       procedure Plan6(Sender: TObject);
       procedure Plan7(Sender: TObject);
//       procedure Plan8(Sender: TObject);
       procedure Plan9(Sender: TObject);

  public
    { public declarations }
  end; 

var
  LatinSqrsFrm: TLatinSqrsFrm;

implementation

uses
  Math;

{ TLatinSqrsFrm }

procedure TLatinSqrsFrm.OKBtnClick(Sender: TObject);
begin
     case Btn of
     1 :  begin
               Plan1(Self);
          end;
     2 :  begin
               Plan2(Self);
          end;
     3 :  begin
               Plan3(Self);
          end;
     4 :  begin
               Plan4(Self);
          end;
     5 :  begin
               Plan5(Self);
          end;
     6 :  begin
               Plan6(Self);
          end;
     7 :  begin
               Plan7(Self);
          end;
     8 :  begin
               Plan9(Self);
          end;
     end;
     Close;
end;

procedure TLatinSqrsFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([HelpBtn.Width, CancelBtn.Width, OKBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  OKBtn.Constraints.MinWidth := w;
end;

procedure TLatinSqrsFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if LatinSpecsFrm = nil then
    Application.CreateForm(TLatinSpecsFrm, LatinSpecsFrm);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TLatinSqrsFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TLatinSqrsFrm.PlanClick(Sender: TObject);
begin
     Btn := Plan.ItemIndex + 1;
end;

procedure TLatinSqrsFrm.Plan1(Sender: TObject);
label cleanup;
var
   NoFactors : integer;
   n : integer; // no. of subjects per cell
   Acol, Bcol, Ccol, DataCol : integer; // variable columns in grid
   FactorA : string;
   FactorB : string;
   FactorC : string;
   DataVar : string;
   cellstring : string;
   i, j, minA, minB, minC, maxA, maxB, maxC, rangeA, rangeB, rangeC : integer;
   value : integer;
   cellcnts : IntDyneMat;
   celltotals : DblDyneMat;
   Ctotals : DblDyneVec;
   design : StrDyneMat;
   G, term1, term2, term3, term4, term5, term6, sumxsqr : double;
   sumAsqr, sumBsqr, sumCsqr, sumABCsqr, SSA, SSB, SSC : double;
   SSbetween, SSwithin, SSres, SStotal : double;
   MSa, MSb, MSc, MSres, MSwithin : double;
   data, GrandMean : double;
   p, row, col, slice : integer;
   dfa, dfb, dfc, dfres, dfwithin, dftotal, fa, fb, fc, fpartial : double;
   proba, probb, probc, probpartial : double;

begin
     NoFactors := 3;
     LatinSpecsFrm.PanelD.Visible := false;
     LatinSpecsFrm.PanelGrp.Visible := false;
     LatinSpecsFrm.AinBtn.Enabled := true;
     LatinSpecsFrm.AoutBtn.Enabled := false;
     LatinSpecsFrm.BinBtn.Enabled := true;
     LatinSpecsFrm.BoutBtn.Enabled := false;
     LatinSpecsFrm.CinBtn.Enabled := true;
     LatinSpecsFrm.CoutBtn.Enabled := false;
//     LatinSpecsFrm.DCodeLabel.Visible := false;
//     LatinSpecsFrm.GrpCodeLabel.Visible := false;
//     LatinSpecsFrm.DinBtn.Visible := false;
//     LatinSpecsFrm.DoutBtn.Visible := false;
     LatinSpecsFrm.ACodeEdit.Text := '';
     LatinSpecsFrm.BCodeEdit.Text := '';
     LatinSpecsFrm.CCodeEdit.Text := '';
     LatinSpecsFrm.DCodeEdit.Text := '';
     LatinSpecsFrm.GrpCodeEdit.Text := '';
     LatinSpecsFrm.DepVarEdit.Text := '';
     LatinSpecsFrm.nPerCellEdit.Text := '';
//     LatinSpecsFrm.DCodeEdit.Visible := false;
//     LatinSpecsFrm.GrpInBtn.Visible := false;
//     LatinSpecsFrm.GrpOutBtn.Visible := false;
//     LatinSpecsFrm.GrpCodeEdit.Visible := false;
     LatinSpecsFrm.DataInBtn.Enabled := true;
     LatinSpecsFrm.DataOutBtn.Enabled := false;

     if LatinSpecsFrm.ShowModal = mrCancel then
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
    minA := 1000;
    minB := 1000;
    minC := 1000;
    maxA := -1000;
    maxB := -1000;
    maxC := -1000;
    for i := 1 to NoCases do
    begin
         value := StrToInt(OS3MainFrm.DataGrid.Cells[ACol,i]);
         if value < minA then minA := value;
         if value > maxA then maxA := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[BCol,i]);
         if value < minB then minB := value;
         if value > maxB then maxB := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         if value < minC then minC := value;
         if value > maxC then maxC := value;
    end;
    rangeA := maxA - minA + 1;
    rangeB := maxB - minB + 1;
    rangeC := maxC - minC + 1;

    // check for squareness
    if ( (rangeA <> rangeB) or (rangeA <> rangeC) or (rangeB <> rangeC)) then
    begin
         ShowMessage('ERROR! In a Latin square the range of values should all be equal!');
         exit;
    end;
    p := rangeA;

    // set up an array for cell counts and for cell sums and marginal sums
    SetLength(cellcnts,rangeA+1,rangeB+1);
    SetLength(celltotals,rangeA+1,rangeB+1);
    SetLength(Ctotals,rangeC+1);
    SetLength(Design,rangeA,rangeB);

    // initialize arrays and values
    for i := 0 to rangeA do
    begin
        for j := 0 to rangeB do
        begin
             cellcnts[i,j] := 0;
             celltotals[i,j] := 0.0;
        end;
    end;
    for i := 0 to rangeC-1 do Ctotals[i] := 0;
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
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         data := StrToFloat(OS3MainFrm.DataGrid.Cells[DataCol,i]);
         cellcnts[row-1,col-1] := cellcnts[row-1,col-1] + 1;
         celltotals[row-1,col-1] := celltotals[row-1,col-1] + data;
         Ctotals[slice-1] := Ctotals[slice-1] + data;
         sumxsqr := sumxsqr + (data * data);
         GrandMean := GrandMean + data;
    end;

    // check for equal cell counts
    for i := 0 to p-1 do
    begin
         for j := 0 to p-1 do
         begin
              if cellcnts[i,j] <> n then
              begin
                   ShowMessage('cell sizes are not equal!');
                   goto cleanup;
              end;
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
    for i := 0 to p-1 do G := G + Ctotals[i];
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
    SSbetween := term6 - term1;
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
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Latin Square Analysis Plan 1 Results');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    OutputFrm.RichEdit.Lines.Add('Source         SS        DF        MS        F      Prob.>F');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    cellstring := 'Factor A  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSA,dfa,MSa,fa,proba]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Factor B  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSB,dfb,MSb,fb,probb]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Factor C  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSC,dfc,MSc,fc,probc]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Residual  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSres,dfres,MSres,fpartial,probpartial]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Within    ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSwithin, dfwithin, MSwithin]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Total     ';
    cellstring := cellstring + format('%9.3f %9.0f',[SStotal, dftotal]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');

    // show design
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Experimental Design');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format(' %3d ',[i]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 1 to NoCases do
    begin
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         Design[row-1,col-1] := 'C' + IntToStr(slice);
    end;
    for i := 0 to p - 1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
         begin
              cellstring := cellstring + format('%5s',[Design[i,j]]);
         end;
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);

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
    for i := 0 to p-1 do Ctotals[i] := Ctotals[i] / (p * n);

    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Cell means and totals');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 0 to p-1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
         begin
              cellstring := cellstring + format(' %8.3f ',[celltotals[i,j]]);
         end;
         cellstring := cellstring + format(' %8.3f ',[celltotals[i,p]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := 'Total     ';
    for j := 0 to p-1 do
        cellstring := cellstring + format(' %8.3f ',[celltotals[p,j]]);
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    // show category means
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorC]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Ctotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.ShowModal;

cleanup:
    Design := nil;
    Ctotals := nil;
    celltotals := nil;
    cellcnts := nil;
end;

procedure TLatinSqrsFrm.Plan2(Sender: TObject);
label cleanup;
var
   NoFactors : integer;
   n : integer; // no. of subjects per cell
   Acol, Bcol, Ccol, Dcol, DataCol : integer; // variable columns in grid
   FactorA : string;
   FactorB : string;
   FactorC : string;
   FactorD : string;
   DataVar : string;
   cellstring : string;
   i, j, k, minA, minB, minC, maxA, maxB, maxC : integer;
   minD, maxD, rangeD, rangeA, rangeB, rangeC : integer;
   value : integer;
   cellcnts : IntDyneCube;
   celltotals : DblDyneCube;
   Ctotals : DblDyneVec;
   design : StrDyneMat;
   G, term1, term2, term3, term4, term5, term6, term7, term8 : double;
   term9, sumxsqr : double;
   sumAsqr, sumBsqr, sumCsqr, sumDsqr, SSA, SSB, SSC, SSD : double;
   sumADsqr, sumBDsqr, sumCDsqr : double;
   ADmat, BDmat, CDmat : DblDyneMat;
   SSAD, SSBD, SSCD, SSwithin, SSres, SStotal : double;
   MSa, MSb, MSc, MSd, MSAD, MSBD, MSCD, MSres, MSwithin : double;
   data, GrandMean : double;
   p, row, col, slice, block : integer;
   dfa, dfb, dfc, dfres, dfwithin, dftotal, fa, fb, fc, fpartial : double;
   dfd, fd, fad, fbd, fcd, dfad, dfbd, dfcd : double;
   proba, probb, probc, probd, probpartial : double;
   probad, probbd, probcd: double;

begin
     NoFactors := 4;
     LatinSpecsFrm.PanelD.Visible := true;
     LatinSpecsFrm.PanelGrp.Visible := false;
     LatinSpecsFrm.AinBtn.Enabled := true;
     LatinSpecsFrm.AoutBtn.Enabled := false;
     LatinSpecsFrm.BinBtn.Enabled := true;
     LatinSpecsFrm.BoutBtn.Enabled := false;
     LatinSpecsFrm.CinBtn.Enabled := true;
     LatinSpecsFrm.CoutBtn.Enabled := false;
     LatinSpecsFrm.DCodeEdit.Visible := true;
     LatinSpecsFrm.ACodeEdit.Text := '';
     LatinSpecsFrm.BCodeEdit.Text := '';
     LatinSpecsFrm.CCodeEdit.Text := '';
     LatinSpecsFrm.DCodeEdit.Text := '';
     LatinSpecsFrm.GrpCodeEdit.Text := '';
     LatinSpecsFrm.DepVarEdit.Text := '';
     LatinSpecsFrm.nPerCellEdit.Text := '';
     LatinSpecsFrm.DinBtn.Enabled := true;
     LatinSpecsFrm.DoutBtn.Enabled := false;
     LatinSpecsFrm.DataInBtn.Enabled := true;
     LatinSpecsFrm.DataOutBtn.Enabled := false;
     LatinSpecsFrm.ShowModal;
     if LatinSpecsFrm.ModalResult = mrCancel then exit;
     n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
     if n <= 0 then
     begin
          ShowMessage('Please specify the number of cases per cell.');
          exit;
     end;
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
    minA := 1000;
    minB := 1000;
    minC := 1000;
    minD := 1000;
    maxA := -1000;
    maxB := -1000;
    maxC := -1000;
    maxD := -1000;
    for i := 1 to NoCases do
    begin
         value := StrToInt(OS3MainFrm.DataGrid.Cells[ACol,i]);
         if value < minA then minA := value;
         if value > maxA then maxA := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[BCol,i]);
         if value < minB then minB := value;
         if value > maxB then maxB := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         if value < minC then minC := value;
         if value > maxC then maxC := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
         if value < minD then minD := value;
         if value > maxD then maxD := value;
    end;
    rangeA := maxA - minA + 1;
    rangeB := maxB - minB + 1;
    rangeC := maxC - minC + 1;
    rangeD := maxD - minD + 1;

    // check for squareness
    if ( (rangeA <> rangeB) or (rangeA <> rangeC) or (rangeB <> rangeC)) then
    begin
         ShowMessage('ERROR! In a Latin square the range of values should all be equal!');
         exit;
    end;
    p := rangeA;

    // set up an array for cell counts and for cell sums and marginal sums
    SetLength(cellcnts,rangeA+1,rangeB+1,rangeD+1);
    SetLength(celltotals,rangeA+1,rangeB+1,rangeD+1);
    SetLength(ADmat,rangeA+1,rangeD+1);
    SetLength(BDmat,rangeB+1,rangeD+1);
    SetLength(CDmat,rangeC+1,rangeD+1);
    SetLength(Ctotals,rangeC+1);
    SetLength(Design,rangeA,rangeB);

    // initialize arrays and values
    for i := 0 to rangeA do
    begin
        for j := 0 to rangeB do
        begin
             for k := 0 to rangeD do
             begin
                  cellcnts[i,j,k] := 0;
                  celltotals[i,j,k] := 0.0;
             end;
        end;
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
    for i := 0 to rangeC-1 do Ctotals[i] := 0;
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
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         block := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
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
    begin
         for j := 0 to p-1 do
         begin
              for k := 0 to rangeD - 1 do
              begin
                   if cellcnts[i,j,k] <> n then
                   begin
                        ShowMessage('cell sizes are not equal!');
                        goto cleanup;
                   end;
              end;
         end;
    end;

    // calculate values
    for i := 0 to p - 1 do // get row, column and block sums
    begin
         for j := 0 to p-1 do
         begin
              for k := 0 to rangeD - 1 do
              begin
                   celltotals[i,p,k] := celltotals[i,p,k] + celltotals[i,j,k];
                   celltotals[p,j,k] := celltotals[p,j,k] + celltotals[i,j,k];
                   celltotals[i,j,rangeD] :=celltotals[i,j,rangeD] + celltotals[i,j,k];
              end;
         end;
    end;
    // get interaction AD
    for i := 0 to rangeA-1 do
    begin
         for j := 0 to rangeD-1 do
         begin
              sumADsqr := sumADsqr + (ADmat[i,j] * ADmat[i,j]);
              ADmat[i,rangeD] := ADmat[i,rangeD] + ADmat[i,j];
              ADmat[rangeA,j] := ADmat[rangeA,j] + ADmat[i,j];
         end;
    end;
    for i := 0 to rangeA-1 do
        sumAsqr := sumAsqr + (ADmat[i,rangeD] * ADmat[i,rangeD]);
    for i := 0 to rangeD-1 do
        sumDsqr := sumDsqr + (ADmat[rangeA,i] * ADmat[rangeA,i]);

    // get interaction BD
    for i := 0 to rangeB-1 do
    begin
         for j := 0 to rangeD-1 do
         begin
              sumBDsqr := sumBDsqr + (BDmat[i,j] * BDmat[i,j]);
              BDmat[i,rangeD] := BDmat[i,rangeD] + BDmat[i,j];
              BDmat[rangeB,j] := BDmat[rangeB,j] + BDmat[i,j];
         end;
    end;
    for i := 0 to rangeB-1 do
        sumBsqr := sumBsqr + (BDmat[i,rangeD] * BDmat[i,rangeD]);

    // get interaction CD
    for i := 0 to rangeC-1 do
    begin
         for j := 0 to rangeD-1 do
         begin
              sumCDsqr := sumCDsqr + (CDmat[i,j] * CDmat[i,j]);
              CDmat[i,rangeD] := CDmat[i,rangeD] + CDmat[i,j];
              CDmat[rangeC,j] := CDmat[rangeC,j] + CDmat[i,j];
         end;
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
    proba := probf(fa,dfa,dfwithin);
    probb := probf(fb,dfb,dfwithin);
    probc := probf(fc,dfc,dfwithin);
    probd := probf(fd,dfd,dfwithin);
    probad := probf(fad,dfad,dfwithin);
    probbd := probf(fbd,dfbd,dfwithin);
    probcd := probf(fcd,dfcd,dfwithin);
    probpartial := probf(fpartial,dfres,dfwithin);

    // show ANOVA table results
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Latin Square Analysis Plan 2 Results');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    OutputFrm.RichEdit.Lines.Add('Source         SS        DF        MS        F      Prob.>F');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    cellstring := 'Factor A  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSA,dfa,MSa,fa,proba]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Factor B  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSB,dfb,MSb,fb,probb]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Factor C  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSC,dfc,MSc,fc,probc]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Factor D  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSD,dfd,MSd,fd,probd]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'A x D     ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSAD,dfad,MSad,fad,probad]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'B x D     ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSBD,dfbd,MSbd,fbd,probbd]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'C x D     ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSCD,dfcd,MScd,fcd,probcd]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Residual  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSres,dfres,MSres,fpartial,probpartial]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Within    ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSwithin, dfwithin, MSwithin]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Total     ';
    cellstring := cellstring + format('%9.3f %9.0f',[SStotal, dftotal]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');

    // show design for each block
    for k := 0 to rangeD - 1 do
    begin
         OutputFrm.RichEdit.Lines.Add('');
         cellstring := 'Experimental Design for block ' + format('%d',[k+1]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '-----';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := format('%10s',[FactorB]);
         for i := 1 to p do cellstring := cellstring + format(' %3d ',[i]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '-----';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := format('%10s',[FactorA]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         for i := 1 to NoCases do
         begin
              row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
              col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
              slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
              block := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
              if block = minD + k then
                 Design[row-1,col-1] := 'C' + IntToStr(slice);
         end;
         for i := 0 to p - 1 do
         begin
              cellstring := format('   %3d    ',[i+1]);
              for j := 0 to p - 1 do
              begin
                   cellstring := cellstring + format('%5s',[Design[i,j]]);
              end;
              OutputFrm.RichEdit.Lines.Add(cellstring);
         end;
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '-----';
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;

    // get cell means
    for i := 0 to p-1 do
         for j := 0 to p-1 do
             for k := 0 to rangeD - 1 do
             celltotals[i,j,k] := celltotals[i,j,k] / n;
    for i := 0 to p-1 do
    begin
         for k := 0 to rangeD - 1 do
         begin
              celltotals[i,p,k] := celltotals[i,p,k] / (p * n);
              celltotals[p,i,k] := celltotals[p,i,k] / (p * n);
         end;
    end;
    GrandMean := GrandMean / (p * p * n * rangeD);
    for i := 0 to p-1 do Ctotals[i] := Ctotals[i] / (p * n * rangeD);

    // show table of means for each block
    for k := 0 to rangeD-1 do
    begin
         OutputFrm.RichEdit.Lines.Add('');
         cellstring := format('BLOCK %d',[k+1]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         OutputFrm.RichEdit.Lines.Add('');
         OutputFrm.RichEdit.Lines.Add('Cell means and totals');
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '----------';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := format('%10s',[FactorB]);
         for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
         cellstring := cellstring + '    Total';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '----------';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := format('%10s',[FactorA]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         for i := 0 to p-1 do
         begin
              cellstring := format('   %3d    ',[i+1]);
              for j := 0 to p - 1 do
              begin
                   cellstring := cellstring + format(' %8.3f ',[celltotals[i,j,k]]);
              end;
              cellstring := cellstring + format(' %8.3f ',[celltotals[i,p,k]]);
              OutputFrm.RichEdit.Lines.Add(cellstring);
         end;
         cellstring := 'Total     ';
         for j := 0 to p-1 do
             cellstring := cellstring + format(' %8.3f ',[celltotals[p,j,k]]);
         cellstring := cellstring + format(' %8.3f ',[GrandMean]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '----------';
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;

    // show category means
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorC]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Ctotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.ShowModal;

cleanup:
    Design := nil;
    Ctotals := nil;
    CDmat := nil;
    BDmat := nil;
    ADmat := nil;
    celltotals := nil;
    cellcnts := nil;
end;

procedure TLatinSqrsFrm.Plan3(Sender: TObject);
label cleanup;
var
   NoFactors : integer;
   n : integer; // no. of subjects per cell
   Acol, Bcol, Ccol, Dcol, DataCol : integer; // variable columns in grid
   FactorA : string;
   FactorB : string;
   FactorC : string;
   FactorD : string;
   DataVar : string;
   cellstring : string;
   i, j, k, m, minA, minB, minC, maxA, maxB, maxC : integer;
   minD, maxD, rangeA, rangeB, rangeC, rangeD : integer;
   value : integer;
   cellcnts : IntDyneCube;
   celltotals : DblDyneQuad;
   ABmat, ACmat, BCmat : DblDyneMat;
   ABCmat : DblDyneCube;
   Atotals : DblDyneVec;
   Btotals : DblDyneVec;
   Ctotals : DblDyneVec;
   Dtotals : DblDyneVec;
   design : StrDyneMat;
   G, term1, term2, term3, term4, term5, term6, term7, term8 : double;
   term9, term10, sumxsqr : double;
   sumAsqr, sumBsqr, sumCsqr, sumDsqr, SSA, SSB, SSC, SSD : double;
   sumABsqr, sumACsqr, sumBCsqr, sumABCsqr : double;
   SSAB, SSAC, SSBC, SSABC, SSwithin, SStotal : double;
   MSa, MSb, MSc, MSd, MSAB, MSAC, MSBC, MSABC, MSwithin : double;
   data, GrandMean : double;
   p, row, col, slice, block : integer;
   dfa, dfb, dfc, dfwithin, dftotal, fa, fb, fc: double;
   dfd, fd, fab, fac, fbc, fabc, dfab, dfac, dfbc, dfabc : double;
   proba, probb, probc, probd: double;
   probab, probac, probbc, probabc : double;

begin
     NoFactors := 4;
     LatinSpecsFrm.PanelD.Visible := true;
     LatinSpecsFrm.PanelGrp.Visible := false;
     LatinSpecsFrm.AinBtn.Enabled := true;
     LatinSpecsFrm.AoutBtn.Enabled := false;
     LatinSpecsFrm.BinBtn.Enabled := true;
     LatinSpecsFrm.BoutBtn.Enabled := false;
     LatinSpecsFrm.CinBtn.Enabled := true;
     LatinSpecsFrm.CoutBtn.Enabled := false;
//     LatinSpecsFrm.DCodeEdit.Visible := true;
     LatinSpecsFrm.ACodeEdit.Text := '';
     LatinSpecsFrm.BCodeEdit.Text := '';
     LatinSpecsFrm.CCodeEdit.Text := '';
     LatinSpecsFrm.DCodeEdit.Text := '';
     LatinSpecsFrm.GrpCodeEdit.Text := '';
     LatinSpecsFrm.DepVarEdit.Text := '';
     LatinSpecsFrm.nPerCellEdit.Text := '';
//     LatinSpecsFrm.GrpCodeEdit.Visible := false;
//     LatinSpecsFrm.DCodeLabel.Visible := true;
//     LatinSpecsFrm.GrpCodeLabel.Visible := false;
//     LatinSpecsFrm.DinBtn.Visible := true;
//     LatinSpecsFrm.DoutBtn.Visible := true;
     LatinSpecsFrm.DinBtn.Enabled := true;
     LatinSpecsFrm.DoutBtn.Enabled := false;
//     LatinSpecsFrm.GrpInBtn.Visible := false;
//     LatinSpecsFrm.GrpOutBtn.Visible := false;
     LatinSpecsFrm.DataInBtn.Enabled := true;
     LatinSpecsFrm.DataOutBtn.Enabled := false;
     LatinSpecsFrm.ShowModal;
     if LatinSpecsFrm.ModalResult = mrCancel then exit;
     n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
     if n <= 0 then
     begin
          ShowMessage('Please specify the number of cases per cell.');
          exit;
     end;
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
    minA := 1000;
    minB := 1000;
    minC := 1000;
    minD := 1000;
    maxA := -1000;
    maxB := -1000;
    maxC := -1000;
    maxD := -1000;
    for i := 1 to NoCases do
    begin
         value := StrToInt(OS3MainFrm.DataGrid.Cells[ACol,i]);
         if value < minA then minA := value;
         if value > maxA then maxA := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[BCol,i]);
         if value < minB then minB := value;
         if value > maxB then maxB := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         if value < minC then minC := value;
         if value > maxC then maxC := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
         if value < minD then minD := value;
         if value > maxD then maxD := value;
    end;
    rangeA := maxA - minA + 1;
    rangeB := maxB - minB + 1;
    rangeC := maxC - minC + 1;
    rangeD := maxD - minD + 1;

    // check for squareness
    if ( (rangeA <> rangeB) or (rangeA <> rangeC) or (rangeB <> rangeC) or (rangeA <> rangeD) ) then
    begin
         ShowMessage('ERROR! In a Latin square the range of values should all be equal!');
         exit;
    end;
    p := rangeA;

    // set up an array for cell counts and for cell sums and marginal sums
    SetLength(cellcnts,p+1,p+1,p+1);
    SetLength(celltotals,p+1,p+1,p+1,p+1);
    SetLength(ABmat,p+1,p+1);
    SetLength(ACmat,p+1,p+1);
    SetLength(BCmat,p+1,p+1);
    SetLength(ABCmat,p+1,p+1,p+1);
    SetLength(Atotals,p);
    SetLength(Btotals,p);
    SetLength(Ctotals,p);
    SetLength(Dtotals,p);
    SetLength(Design,p,p);

    // initialize arrays and values
    for i := 0 to p do
        for j := 0 to p do
             for k := 0 to p do
                  for m := 0 to p do
                       celltotals[i,j,k,m] := 0.0;
    for i := 0 to p do
    begin
        for j := 0 to p do
        begin
            ABmat[i,j] := 0.0;
            ACmat[i,j] := 0.0;
            BCmat[i,j] := 0.0;
        end;
    end;
    for i := 0 to p do
    begin
        for j := 0 to p do
        begin
            for k := 0 to p do
            begin
                ABCmat[i,j,k] := 0.0;
                cellcnts[i,j,k] := 0;
            end;
        end;
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
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         block := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
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
    begin
         for j := 0 to p-1 do
         begin
              for k := 0 to p - 1 do
              begin
                   if cellcnts[i,j,k] <> n then
                   begin
                        ShowMessage('cell sizes are not  equal!');
                        goto cleanup;
                   end;
              end;
         end;
    end;

    // calculate values
    for i := 0 to p - 1 do // get row, column, slice and block sums
    begin
         for j := 0 to p-1 do
         begin
              for k := 0 to p - 1 do
              begin
                   for m := 0 to p - 1 do
                   begin
                        celltotals[p,j,k,m] := celltotals[p,j,k,m] + celltotals[i,j,k,m];
                        celltotals[i,p,k,m] := celltotals[i,p,k,m] + celltotals[i,j,k,m];
                        celltotals[i,j,p,m] := celltotals[i,j,p,m] + celltotals[i,j,k,m];
                        celltotals[i,j,k,p] := celltotals[i,j,k,p] + celltotals[i,j,k,m];
                   end;
              end;
         end;
    end;
    for i := 0 to p - 1 do // get row, column and slice sums in ABC matrix
    begin
         for j := 0 to p-1 do
         begin
              for k := 0 to p-1 do
              begin
                   ABCmat[p,j,k] := ABCmat[p,j,k] + ABCmat[i,j,k];
                   ABCmat[i,p,k] := ABCmat[i,p,k] + ABCmat[i,j,k];
                   ABCmat[i,j,p] := ABCmat[i,j,p] + ABCmat[i,j,k];
              end;
         end;
    end;

    // get 2-way interactions
    for i := 0 to p-1 do
    begin
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
    dfabc := ( (p-1) * (p-1) * (p-1) ) - (p-1);
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
    proba := probf(fa,dfa,dfwithin);
    probb := probf(fb,dfb,dfwithin);
    probc := probf(fc,dfc,dfwithin);
    probd := probf(fd,dfd,dfwithin);
    probab := probf(fab,dfab,dfwithin);
    probac := probf(fac,dfac,dfwithin);
    probbc := probf(fbc,dfbc,dfwithin);
    probabc := probf(fabc,dfabc,dfwithin);

    // show ANOVA table results
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Latin Square Analysis Plan 3 Results');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    OutputFrm.RichEdit.Lines.Add('Source         SS        DF        MS        F      Prob.>F');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    cellstring := 'Factor A  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSA,dfa,MSa,fa,proba]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Factor B  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSB,dfb,MSb,fb,probb]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Factor C  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSC,dfc,MSc,fc,probc]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Factor D  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSD,dfd,MSd,fd,probd]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'A x B     ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSAB,dfab,MSab,fab,probab]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'A x C     ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSAC,dfac,MSac,fac,probac]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'B x C     ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSBC,dfbc,MSbc,fbc,probbc]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'A x B x C ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSABC,dfabc,MSabc,fabc,probabc]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Within    ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSwithin, dfwithin, MSwithin]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Total     ';
    cellstring := cellstring + format('%9.3f %9.0f',[SStotal, dftotal]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');

    // show design for each block
    for k := 0 to rangeD - 1 do
    begin
         OutputFrm.RichEdit.Lines.Add('');
         cellstring := 'Experimental Design for block ' + format('%d',[k+1]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '-----';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := format('%10s',[FactorB]);
         for i := 1 to p do cellstring := cellstring + format(' %3d ',[i]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '-----';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := format('%10s',[FactorA]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         for i := 1 to NoCases do
         begin
              row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
              col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
              slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
              block := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
              if block = minD + k then
                 Design[row-1,col-1] := 'C' + IntToStr(slice);
         end;
         for i := 0 to p - 1 do
         begin
              cellstring := format('   %3d    ',[i+1]);
              for j := 0 to p - 1 do
              begin
                   cellstring := cellstring + format('%5s',[Design[i,j]]);
              end;
              OutputFrm.RichEdit.Lines.Add(cellstring);
         end;
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '-----';
         OutputFrm.RichEdit.Lines.Add(cellstring);
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
         OutputFrm.RichEdit.Lines.Add('');
         cellstring := format('BLOCK %d',[k+1]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         OutputFrm.RichEdit.Lines.Add('');
         OutputFrm.RichEdit.Lines.Add('Cell means and totals');
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '----------';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := format('%10s',[FactorB]);
         for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
         cellstring := cellstring + '    Total';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '----------';
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := format('%10s',[FactorA]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         for i := 0 to p-1 do
         begin
              cellstring := format('   %3d    ',[i+1]);
              for j := 0 to p - 1 do
              begin
                   cellstring := cellstring + format(' %8.3f ',[ABCmat[i,j,k]]);
              end;
              cellstring := cellstring + format(' %8.3f ',[ABCmat[i,p,k]]);
              OutputFrm.RichEdit.Lines.Add(cellstring);
         end;
         cellstring := 'Total     ';
         for j := 0 to p-1 do
             cellstring := cellstring + format(' %8.3f ',[ABCmat[p,j,k]]);
         cellstring := cellstring + format(' %8.3f ',[GrandMean]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '----------';
         for i := 1 to p + 1 do cellstring := cellstring + '----------';
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;

    // show category means
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Means for each variable');
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Atotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Btotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorC]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Ctotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorD]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Dtotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.ShowModal;

cleanup:
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

procedure TLatinSqrsFrm.Plan4(Sender: TObject);
label cleanup;
var
   NoFactors : integer;
   n : integer; // no. of subjects per cell
   Acol, Bcol, Ccol, Dcol, DataCol : integer; // variable columns in grid
   FactorA : string;
   FactorB : string;
   FactorC : string;
   FactorD : string;
   DataVar : string;
   cellstring : string;
   i, j, k, minA, minB, minC, maxA, maxB, maxC : integer;
   minD, maxD, rangeA, rangeB, rangeC, rangeD : integer;
   value : integer;
   cellcnts : IntDyneMat;
   ABmat : DblDyneMat;
   ABCmat : DblDyneCube;
   Atotals : DblDyneVec;
   Btotals : DblDyneVec;
   Ctotals : DblDyneVec;
   Dtotals : DblDyneVec;
   design : StrDyneMat;
   G, term1, term2, term3, term4, term5, term6, term7 : double;
   sumxsqr : double;
   sumAsqr, sumBsqr, sumCsqr, sumDsqr, SSA, SSB, SSC, SSD : double;
   SSwithin, SSres, SStotal : double;
   MSa, MSb, MSc, MSd, MSres, MSwithin : double;
   data, GrandMean : double;
   p, row, col, slice, block : integer;
   dfa, dfb, dfc, dfres, dfwithin, dftotal, fa, fb, fc : double;
   dfd, fd, fres : double;
   proba, probb, probc, probd, probres : double;

begin
     NoFactors := 4;
     LatinSpecsFrm.PanelD.Visible := true;
     LatinSpecsFrm.PanelGrp.Visible := false;
     LatinSpecsFrm.AinBtn.Enabled := true;
     LatinSpecsFrm.AoutBtn.Enabled := false;
     LatinSpecsFrm.BinBtn.Enabled := true;
     LatinSpecsFrm.BoutBtn.Enabled := false;
     LatinSpecsFrm.CinBtn.Enabled := true;
     LatinSpecsFrm.CoutBtn.Enabled := false;
//     LatinSpecsFrm.DCodeEdit.Visible := true;
     LatinSpecsFrm.ACodeEdit.Text := '';
     LatinSpecsFrm.BCodeEdit.Text := '';
     LatinSpecsFrm.CCodeEdit.Text := '';
     LatinSpecsFrm.DCodeEdit.Text := '';
     LatinSpecsFrm.GrpCodeEdit.Text := '';
     LatinSpecsFrm.DepVarEdit.Text := '';
     LatinSpecsFrm.nPerCellEdit.Text := '';
//     LatinSpecsFrm.GrpCodeEdit.Visible := false;
//     LatinSpecsFrm.DCodeLabel.Visible := true;
//     LatinSpecsFrm.GrpCodeLabel.Visible := false;
//     LatinSpecsFrm.DinBtn.Visible := true;
//     LatinSpecsFrm.DoutBtn.Visible := true;
     LatinSpecsFrm.DinBtn.Enabled := true;
     LatinSpecsFrm.DoutBtn.Enabled := false;
//     LatinSpecsFrm.GrpInBtn.Visible := false;
//     LatinSpecsFrm.GrpOutBtn.Visible := false;
     LatinSpecsFrm.DataInBtn.Enabled := true;
     LatinSpecsFrm.DataOutBtn.Enabled := false;
     LatinSpecsFrm.ShowModal;
     if LatinSpecsFrm.ModalResult = mrCancel then exit;
     n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
     if n <= 0 then
     begin
          ShowMessage('Please specify the number of cases per cell.');
          exit;
     end;
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
    minA := 1000;
    minB := 1000;
    minC := 1000;
    minD := 1000;
    maxA := -1000;
    maxB := -1000;
    maxC := -1000;
    maxD := -1000;
    for i := 1 to NoCases do
    begin
         value := StrToInt(OS3MainFrm.DataGrid.Cells[ACol,i]);
         if value < minA then minA := value;
         if value > maxA then maxA := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[BCol,i]);
         if value < minB then minB := value;
         if value > maxB then maxB := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         if value < minC then minC := value;
         if value > maxC then maxC := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
         if value < minD then minD := value;
         if value > maxD then maxD := value;
    end;
    rangeA := maxA - minA + 1;
    rangeB := maxB - minB + 1;
    rangeC := maxC - minC + 1;
    rangeD := maxD - minD + 1;

    // check for squareness
    if ( (rangeA <> rangeB) or (rangeA <> rangeC) or (rangeB <> rangeC) ) then
    begin
         ShowMessage('ERROR! In a Latin square the range of values should be equal for A,B and C!');
         exit;
    end;
    p := rangeA;

    // set up an array for cell counts and for cell sums and marginal sums
    SetLength(ABmat,p+1,p+1);
    SetLength(ABCmat,p+1,p+1,p+1);
    SetLength(cellcnts,p+1,p+1);
    SetLength(Atotals,p);
    SetLength(Btotals,p);
    SetLength(Ctotals,p);
    SetLength(Dtotals,p);
    SetLength(Design,p,p);

    for i := 0 to p do
        for j := 0 to p do
            for k := 0 to p do
                ABCmat[i,j,k] := 0.0;

    for i := 0 to p-1 do
    begin
        for j := 0 to p-1 do
        begin
            cellcnts[i,j] := 0;
            ABmat[i,j] := 0.0;
        end;
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
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         block := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
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
    begin
         for j := 0 to p-1 do
         begin
              if cellcnts[i,j] <> n then
              begin
                   ShowMessage('cell sizes are not  equal!');
                   goto cleanup;
              end;
         end;
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
    SSres := term7 - term3 - term4 - term5 - term6 + (3 * term1);
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
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Greco-Latin Square Analysis (No Interactions)');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    OutputFrm.RichEdit.Lines.Add('Source         SS        DF        MS        F      Prob.>F');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    cellstring := 'Factor A  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSA,dfa,MSa,fa,proba]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Factor B  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSB,dfb,MSb,fb,probb]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Latin Sqr.';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSC,dfc,MSc,fc,probc]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Greek Sqr.';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSD,dfd,MSd,fd,probd]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Residual  ';
    if dfres > 0 then
         cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSres,dfres,MSres,fres,probres])
    else cellstring := cellstring + '    -         -          -         -         -';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Within    ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSwithin, dfwithin, MSwithin]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Total     ';
    cellstring := cellstring + format('%9.3f %9.0f',[SStotal, dftotal]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');

    // show design for Latin Square
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Experimental Design for Latin Square ';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format(' %3d ',[i]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 1 to NoCases do
    begin
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         Design[row-1,col-1] := 'C' + IntToStr(slice);
    end;
    for i := 0 to p - 1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
              cellstring := cellstring + format('%5s',[Design[i,j]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    // show design for Greek Square
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Experimental Design for Greek Square ';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format(' %3d ',[i]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 1 to NoCases do
    begin
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         block := StrToInt(OS3MainFrm.DataGrid.Cells[Dcol,i]);
         Design[row-1,col-1] := 'C' + IntToStr(block);
    end;
    for i := 0 to p - 1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
              cellstring := cellstring + format('%5s',[Design[i,j]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);

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
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Cell means and totals');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 0 to p-1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
             cellstring := cellstring + format(' %8.3f ',[ABmat[i,j]]);
         cellstring := cellstring + format(' %8.3f ',[ABmat[i,p]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := 'Total     ';
    for j := 0 to p-1 do
        cellstring := cellstring + format(' %8.3f ',[ABmat[p,j]]);
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    // show category means
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Means for each variable');
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Atotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Btotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorC]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Ctotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to rangeD + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorD]);
    for i := 1 to rangeD do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to rangeD + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to rangeD - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Dtotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to rangeD + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.ShowModal;

cleanup:
    Design := nil;
    Dtotals := nil;
    Ctotals := nil;
    Btotals := nil;
    Atotals := nil;
    cellcnts := nil;
    ABCmat := nil;
    ABmat := nil;
end;

procedure TLatinSqrsFrm.Plan5(Sender: TObject);
label cleanup;
var
   NoFactors : integer;
   n : integer; // no. of subjects per cell
   Acol, Bcol, SbjCol, Grpcol, DataCol : integer; // variable columns in grid
   FactorA : string;
   FactorB : string;
   SubjectFactor : string;
   GroupFactor : string;
   DataVar : string;
   cellstring : string;
   i, j, k, minA, minB, minGrp, maxA, maxB, maxGrp : integer;
   rangeA, rangeB, rangeGrp : integer;
   value : integer;
   cellcnts : IntDyneMat;
   ABmat : DblDyneMat;
   ABCmat : DblDyneCube;
   GBmat : DblDyneMat;
   Atotals : DblDyneVec;
   Btotals : DblDyneVec;
   Grptotals : DblDyneVec;
   Subjtotals : DblDyneMat;
   design : StrDyneMat;
   G, term1, term2, term3, term4, term5, term6, term7 : double;
   sumxsqr : double;
   SSbetsubj, SSgroups, SSsubwGrps, SSwithinsubj, SSa, SSb, SSab : double;
   SSerrwithin, SStotal, MSgroups, MSsubwGrps, MSa, MSb, MSab : double;
   MSerrwithin, DFbetsubj, DFgroups, DFsubwGrps, DFwithinsubj : double;
   DFa, DFb, DFab, DFerrwithin, DFtotal : double;
   data, GrandMean : double;
   p, row, col, subject, group : integer;
   proba, probb, probab, probgrps : double;
   fa, fb, fab, fgroups : double;
   RowLabels, ColLabels : StrDyneVec;
   Title : string;

begin
     NoFactors := 3;
     LatinSpecsFrm.PanelD.Visible := false;
     LatinSpecsFrm.PanelGrp.Visible := true;
     LatinSpecsFrm.AinBtn.Enabled := true;
     LatinSpecsFrm.AoutBtn.Enabled := false;
     LatinSpecsFrm.BinBtn.Enabled := true;
     LatinSpecsFrm.BoutBtn.Enabled := false;
     LatinSpecsFrm.CinBtn.Enabled := true;
     LatinSpecsFrm.CoutBtn.Enabled := false;
//     LatinSpecsFrm.DCodeEdit.Visible := false;
     LatinSpecsFrm.ACodeEdit.Text := '';
     LatinSpecsFrm.BCodeEdit.Text := '';
     LatinSpecsFrm.CCodeEdit.Text := '';
     LatinSpecsFrm.DCodeEdit.Text := '';
     LatinSpecsFrm.GrpCodeEdit.Text := '';
     LatinSpecsFrm.DepVarEdit.Text := '';
     LatinSpecsFrm.nPerCellEdit.Text := '';
//     LatinSpecsFrm.GrpCodeEdit.Visible := true;
//     LatinSpecsFrm.DCodeLabel.Visible := false;
//     LatinSpecsFrm.GrpCodeLabel.Visible := true;
//     LatinSpecsFrm.DinBtn.Visible := false;
//     LatinSpecsFrm.DoutBtn.Visible := false;
//     LatinSpecsFrm.GrpInBtn.Visible := true;
//     LatinSpecsFrm.GrpOutBtn.Visible := true;
     LatinSpecsFrm.GrpInBtn.Enabled := true;
     LatinSpecsFrm.GrpOutBtn.Enabled := false;
     LatinSpecsFrm.DataInBtn.Enabled := true;
     LatinSpecsFrm.DataOutBtn.Enabled := false;
     LatinSpecsFrm.ShowModal;
     if LatinSpecsFrm.ModalResult = mrCancel then exit;
     n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
     if n <= 0 then
     begin
          ShowMessage('Please specify the number of cases per cell.');
          exit;
     end;
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
    minA := 1000;
    minB := 1000;
    minGrp := 1000;
    maxA := -1000;
    maxB := -1000;
    maxGrp := -1000;
    for i := 1 to NoCases do
    begin
         value := StrToInt(OS3MainFrm.DataGrid.Cells[ACol,i]);
         if value < minA then minA := value;
         if value > maxA then maxA := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[BCol,i]);
         if value < minB then minB := value;
         if value > maxB then maxB := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]);
         if value < minGrp then minGrp := value;
         if value > maxGrp then maxGrp := value;
    end;
    rangeA := maxA - minA + 1;
    rangeB := maxB - minB + 1;
    rangeGrp := maxGrp - minGrp + 1;

    // check for squareness
    if  (rangeA <> rangeGrp) then
    begin
         ShowMessage('ERROR! In a Latin square the range of values should be equal for A,B and C!');
         exit;
    end;
    p := rangeA;

    // set up an array for cell counts and for cell sums and marginal sums
    SetLength(ABmat,p+1,p+1);
    SetLength(ABCmat,p+1,p+1,n+1);
    SetLength(cellcnts,p+1,p+1);
    SetLength(Atotals,p+1);
    SetLength(Btotals,p+1);
    SetLength(Grptotals,p+1);
    SetLength(Design,p,p);
    SetLength(Subjtotals,p+1,n+1);
    SetLength(RowLabels,p+1);
    SetLength(ColLabels,n+1);
    SetLength(GBmat,p+1,p+1);

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
    begin
        for j := 0 to p do
        begin
            cellcnts[i,j] := 0;
            ABmat[i,j] := 0.0;
            GBmat[i,j] := 0.0;
        end;
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

    G := 0.0;
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
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         group := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]);
         subject := StrToInt(OS3MainFrm.DataGrid.Cells[Sbjcol,i]);
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
    begin
         for j := 0 to p-1 do
         begin
              if cellcnts[i,j] <> n then
              begin
                   ShowMessage('cell sizes are not  equal!');
                   goto cleanup;
              end;
         end;
    end;

    // collapse subjects's into group x a matrix
    for i := 0 to p-1 do // group
         for j := 0 to p-1 do // factor a
              for k := 0 to n-1 do // subject
                  ABmat[i,j] := ABmat[i,j] + ABCmat[i,j,k];

    // get marginal totals for ABmat and GBmat
    for i := 0 to p-1 do
    begin
        for j := 0 to p-1 do
        begin
            ABmat[p,j] := ABmat[p,j] + ABmat[i,j];
            ABmat[i,p] := ABmat[i,p] + ABmat[i,j];
            GBmat[p,j] := GBmat[p,j] + GBmat[i,j];
            GBmat[i,p] := GBmat[i,p] + GBmat[i,j];
        end;
    end;

    // get grand total for ABmat and GBmat
    for i := 0 to p-1 do
    begin
         ABmat[p,p] := ABmat[p,p] + ABmat[p,i];
         GBmat[p,p] := GBmat[p,p] + GBmat[p,i];
    end;

    // Get marginal totals for Subjtotals
    for i := 0 to p-1 do
    begin
         for j := 0 to n-1 do
         begin
              Subjtotals[p,j] := Subjtotals[p,j] + Subjtotals[i,j];
              Subjtotals[i,n] := Subjtotals[i,n] + Subjtotals[i,j];
         end;
    end;
    for i := 0 to p-1 do Subjtotals[p,n] := Subjtotals[p,n] + Subjtotals[i,n];
    // test block
    OutputFrm.RichEdit.Lines.Add('Sums for ANOVA Analysis');
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Group (rows) times A Factor (columns) sums';
    MAT_PRINT(ABmat,p+1,p+1,cellstring,RowLabels,ColLabels,(n*p*p));
    cellstring := 'Group (rows) times B (cells Factor) sums';
    MAT_PRINT(GBmat,p+1,p+1,cellstring,RowLabels,ColLabels,(n*p*p));
    Title := 'Groups (rows) times Subjects (columns) matrix';
    for i := 0 to n-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[n] := 'Total';
    Mat_Print(Subjtotals,p+1,n+1,Title,RowLabels,ColLabels,(n*p*p));
    OutputFrm.ShowModal;

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
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Latin Squares Repeated Analysis Plan 5 (Partial Interactions)');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    OutputFrm.RichEdit.Lines.Add('Source         SS        DF        MS        F      Prob.>F');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    cellstring := 'Betw.Subj.';
    cellstring := cellstring + format('%9.3f %9.0f',[SSbetsubj,dfbetsubj]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Groups   ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSgroups,dfgroups,MSgroups,fgroups,probgrps]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Subj.w.g.';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSsubwgrps,dfsubwgrps,MSsubwgrps]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Within Sub';
    cellstring := cellstring + format('%9.3f %9.0f',[SSwithinsubj,dfwithinsubj]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor A ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSa,dfa,MSa,fa,proba]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor B ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSb,dfb,MSb,fb,probb]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor AB';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSab,dfab,MSab,fab,probab]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Error w. ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSerrwithin,dferrwithin,MSerrwithin]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Total     ';
    cellstring := cellstring + format('%9.3f %9.0f',[SStotal, dftotal]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');

    // show design for Square
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Experimental Design for Latin Square ';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format(' %3d ',[i]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[GroupFactor]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 1 to NoCases do
    begin
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]); // A (column) effect
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]); // B (cell) effect
         group := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]); // group (row)
         Design[group-1,row-1] := 'B' + IntToStr(col);
    end;
    for i := 0 to p - 1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
              cellstring := cellstring + format('%5s',[Design[i,j]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);

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
//         Dtotals[i] := Dtotals[i] / (p * n);
    end;

    // show table of means for ABmat
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Cell means and totals');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[GroupFactor]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 0 to p-1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
             cellstring := cellstring + format(' %8.3f ',[ABmat[i,j]]);
         cellstring := cellstring + format(' %8.3f ',[ABmat[i,p]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := 'Total     ';
    for j := 0 to p-1 do
        cellstring := cellstring + format(' %8.3f ',[ABmat[p,j]]);
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    // show category means
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Means for each variable');
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Atotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Btotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[GroupFactor]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Grptotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.ShowModal;

cleanup:
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

procedure TLatinSqrsFrm.Plan6(Sender: TObject);
label cleanup;
var
   NoFactors : integer;
   n : integer; // no. of subjects per cell
   Acol, Bcol, SbjCol, Grpcol, DataCol : integer; // variable columns in grid
   FactorA : string;
   FactorB : string;
   SubjectFactor : string;
   GroupFactor : string;
   DataVar : string;
   cellstring : string;
   i, j, k, minA, minB, minGrp, maxA, maxB, maxGrp : integer;
   rangeA, rangeB, rangeGrp : integer;
   value : integer;
   cellcnts : IntDyneMat;
   ABmat : DblDyneMat;
   ABCmat : DblDyneCube;
   GBmat : DblDyneMat;
   Atotals : DblDyneVec;
   Btotals : DblDyneVec;
   Grptotals : DblDyneVec;
   Subjtotals : DblDyneMat;
   design : StrDyneMat;
   G, term1, term2, term3, term4, term5, term6, term7 : double;
   sumxsqr : double;
   SSbetsubj, SSgroups, SSsubwGrps, SSwithinsubj, SSa, SSb, SSab : double;
   SSerrwithin, SStotal, MSgroups, MSsubwGrps, MSa, MSb, MSab : double;
   MSerrwithin, DFbetsubj, DFgroups, DFsubwGrps, DFwithinsubj : double;
   DFa, DFb, DFab, DFerrwithin, DFtotal : double;
   data, GrandMean : double;
   p, row, col, subject, group : integer;
   proba, probb, probab, probgrps : double;
   fa, fb, fab, fgroups : double;
   RowLabels, ColLabels : StrDyneVec;
   Title : string;

begin
     NoFactors := 3;
     LatinSpecsFrm.PanelD.Visible := false;
     LatinSpecsFrm.PanelGrp.Visible := true;
     LatinSpecsFrm.AinBtn.Enabled := true;
     LatinSpecsFrm.AoutBtn.Enabled := false;
     LatinSpecsFrm.BinBtn.Enabled := true;
     LatinSpecsFrm.BoutBtn.Enabled := false;
     LatinSpecsFrm.CinBtn.Enabled := true;
     LatinSpecsFrm.CoutBtn.Enabled := false;
//     LatinSpecsFrm.DCodeEdit.Visible := false;
     LatinSpecsFrm.ACodeEdit.Text := '';
     LatinSpecsFrm.BCodeEdit.Text := '';
     LatinSpecsFrm.CCodeEdit.Text := '';
     LatinSpecsFrm.DCodeEdit.Text := '';
     LatinSpecsFrm.GrpCodeEdit.Text := '';
     LatinSpecsFrm.DepVarEdit.Text := '';
     LatinSpecsFrm.nPerCellEdit.Text := '';
//     LatinSpecsFrm.GrpCodeEdit.Visible := true;
//     LatinSpecsFrm.DCodeLabel.Visible := false;
//     LatinSpecsFrm.GrpCodeLabel.Visible := true;
//     LatinSpecsFrm.DinBtn.Visible := false;
//     LatinSpecsFrm.DoutBtn.Visible := false;
//     LatinSpecsFrm.GrpInBtn.Visible := true;
//     LatinSpecsFrm.GrpOutBtn.Visible := true;
     LatinSpecsFrm.GrpInBtn.Enabled := true;
     LatinSpecsFrm.GrpOutBtn.Enabled := false;
     LatinSpecsFrm.DataInBtn.Enabled := true;
     LatinSpecsFrm.DataOutBtn.Enabled := false;
     LatinSpecsFrm.ShowModal;
     if LatinSpecsFrm.ModalResult = mrCancel then exit;
     n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
     if n <= 0 then
     begin
          ShowMessage('Please specify the number of cases per cell.');
          exit;
     end;
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
    minA := 1000;
    minB := 1000;
    minGrp := 1000;
    maxA := -1000;
    maxB := -1000;
    maxGrp := -1000;
    for i := 1 to NoCases do
    begin
         value := StrToInt(OS3MainFrm.DataGrid.Cells[ACol,i]);
         if value < minA then minA := value;
         if value > maxA then maxA := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[BCol,i]);
         if value < minB then minB := value;
         if value > maxB then maxB := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]);
         if value < minGrp then minGrp := value;
         if value > maxGrp then maxGrp := value;
    end;
    rangeA := maxA - minA + 1;
    rangeB := maxB - minB + 1;
    rangeGrp := maxGrp - minGrp + 1;

    // check for squareness
    if  (rangeA <> rangeGrp) then
    begin
         ShowMessage('ERROR! In a Latin square the range of values should be equal for A,B and C!');
         exit;
    end;
    p := rangeA;

    // set up an array for cell counts and for cell sums and marginal sums
    SetLength(ABmat,p+1,p+1);
    SetLength(ABCmat,p+1,p+1,n+1);
    SetLength(cellcnts,p+1,p+1);
    SetLength(Atotals,p+1);
    SetLength(Btotals,p+1);
    SetLength(Grptotals,p+1);
    SetLength(Design,p,p);
    SetLength(Subjtotals,p+1,n+1);
    SetLength(RowLabels,p+1);
    SetLength(ColLabels,n+1);
    SetLength(GBmat,p+1,p+1);

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
    begin
        for j := 0 to p do
        begin
            cellcnts[i,j] := 0;
            ABmat[i,j] := 0.0;
            GBmat[i,j] := 0.0;
        end;
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

    G := 0.0;
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
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         group := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]);
         subject := StrToInt(OS3MainFrm.DataGrid.Cells[Sbjcol,i]);
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
    begin
         for j := 0 to p-1 do
         begin
              if cellcnts[i,j] <> n then
              begin
                   ShowMessage('cell sizes are not  equal!');
                   goto cleanup;
              end;
         end;
    end;

    // collapse subjects's into group x a matrix
    for i := 0 to p-1 do // group
         for j := 0 to p-1 do // factor a
              for k := 0 to n-1 do // subject
                  ABmat[i,j] := ABmat[i,j] + ABCmat[i,j,k];

    // get marginal totals for ABmat and GBmat
    for i := 0 to p-1 do
    begin
        for j := 0 to p-1 do
        begin
            ABmat[p,j] := ABmat[p,j] + ABmat[i,j];
            ABmat[i,p] := ABmat[i,p] + ABmat[i,j];
            GBmat[p,j] := GBmat[p,j] + GBmat[i,j];
            GBmat[i,p] := GBmat[i,p] + GBmat[i,j];
        end;
    end;

    // get grand total for ABmat and GBmat
    for i := 0 to p-1 do
    begin
         ABmat[p,p] := ABmat[p,p] + ABmat[p,i];
         GBmat[p,p] := GBmat[p,p] + GBmat[p,i];
    end;

    // Get marginal totals for Subjtotals
    for i := 0 to p-1 do
    begin
         for j := 0 to n-1 do
         begin
              Subjtotals[p,j] := Subjtotals[p,j] + Subjtotals[i,j];
              Subjtotals[i,n] := Subjtotals[i,n] + Subjtotals[i,j];
         end;
    end;
    for i := 0 to p-1 do Subjtotals[p,n] := Subjtotals[p,n] + Subjtotals[i,n];

    // test block
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('Latin Squares Repeated Analysis Plan 6');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Sums for ANOVA Analysis');
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Group - C (rows) times A Factor (columns) sums';
    MAT_PRINT(ABmat,p+1,p+1,cellstring,RowLabels,ColLabels,(n*p*p));
    cellstring := 'Group - C (rows) times B (cells Factor) sums';
    MAT_PRINT(GBmat,p+1,p+1,cellstring,RowLabels,ColLabels,(n*p*p));
    Title := 'Group - C (rows) times Subjects (columns) matrix';
    for i := 0 to n-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[n] := 'Total';
    Mat_Print(Subjtotals,p+1,n+1,Title,RowLabels,ColLabels,(n*p*p));
    OutputFrm.ShowModal;

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
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Latin Squares Repeated Analysis Plan 6');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    OutputFrm.RichEdit.Lines.Add('Source         SS        DF        MS        F      Prob.>F');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    cellstring := 'Betw.Subj.';
    cellstring := cellstring + format('%9.3f %9.0f',[SSbetsubj,dfbetsubj]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor C ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSgroups,dfgroups,MSgroups,fgroups,probgrps]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Subj.w.g.';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSsubwgrps,dfsubwgrps,MSsubwgrps]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Within Sub';
    cellstring := cellstring + format('%9.3f %9.0f',[SSwithinsubj,dfwithinsubj]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor A ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSa,dfa,MSa,fa,proba]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor B ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSb,dfb,MSb,fb,probb]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Residual ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSab,dfab,MSab,fab,probab]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Error w. ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSerrwithin,dferrwithin,MSerrwithin]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Total     ';
    cellstring := cellstring + format('%9.3f %9.0f',[SStotal, dftotal]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');

    // show design for Square
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Experimental Design for Latin Square ';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format(' %3d ',[i]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '  G    C  ';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 1 to NoCases do
    begin
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]); // A (column) effect
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]); // B (cell) effect
         group := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]); // group (row)
         Design[group-1,row-1] := 'B' + IntToStr(col);
    end;
    for i := 0 to p - 1 do
    begin
         cellstring := format('%3d  %3d  ',[i+1,i+1]);
         for j := 0 to p - 1 do
              cellstring := cellstring + format('%5s',[Design[i,j]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);

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
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Cell means and totals');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[GroupFactor]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 0 to p-1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
             cellstring := cellstring + format(' %8.3f ',[ABmat[i,j]]);
         cellstring := cellstring + format(' %8.3f ',[ABmat[i,p]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := 'Total     ';
    for j := 0 to p-1 do
        cellstring := cellstring + format(' %8.3f ',[ABmat[p,j]]);
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    // show category means
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Means for each variable');
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Atotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Btotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[GroupFactor]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Grptotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.ShowModal;

cleanup:
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

procedure TLatinSqrsFrm.Plan7(Sender: TObject);
label cleanup;
var
   NoFactors : integer;
   n : integer; // no. of subjects per cell
   Acol, Bcol, Ccol, SbjCol, Grpcol, DataCol : integer; // variable columns in grid
   FactorA : string;
   FactorB : string;
   SubjectFactor : string;
   FactorC : string;
   GroupFactor : string;
   DataVar : string;
   cellstring : string;
   i, j, k, minA, minB, minC, minGrp, maxA, maxB, maxC, maxGrp : integer;
   rangeA, rangeB, rangeC, rangeGrp : integer;
   value : integer;
   cellcnts : IntDyneMat;
   ABmat : DblDyneMat;
   ABCmat : DblDyneCube;
   GBmat : DblDyneMat;
   GCmat : DblDyneMat;
   Atotals : DblDyneVec;
   Btotals : DblDyneVec;
   Ctotals : DblDyneVec;
   Grptotals : DblDyneVec;
   Subjtotals : DblDyneMat;
   design : StrDyneMat;
   G, term1, term2, term3, term4, term5, term6, term7, term8, term9 : double;
   sumxsqr : double;
   SSbetsubj, SSgroups, SSsubwGrps, SSwithinsubj, SSa, SSb, SSc, SSab : double;
   SSerrwithin, SStotal, MSgroups, MSsubwGrps, MSa, MSb, MSc, MSab : double;
   MSerrwithin, DFbetsubj, DFgroups, DFsubwGrps, DFwithinsubj : double;
   DFa, DFb, DFc, DFab, DFerrwithin, DFtotal : double;
   data, GrandMean : double;
   p, row, col, slice, subject, group : integer;
   proba, probb, probc, probab, probgrps : double;
   fa, fb, fc, fab, fgroups : double;
   RowLabels, ColLabels : StrDyneVec;
   Title : string;

begin
     NoFactors := 4;
     LatinSpecsFrm.PanelD.Visible := true;
     LatinSpecsFrm.PanelGrp.Visible := true;
     LatinSpecsFrm.AinBtn.Enabled := true;
     LatinSpecsFrm.AoutBtn.Enabled := false;
     LatinSpecsFrm.BinBtn.Enabled := true;
     LatinSpecsFrm.BoutBtn.Enabled := false;
     LatinSpecsFrm.CinBtn.Enabled := true;
     LatinSpecsFrm.CoutBtn.Enabled := false;
//     LatinSpecsFrm.DCodeEdit.Visible := true;
     LatinSpecsFrm.ACodeEdit.Text := '';
     LatinSpecsFrm.BCodeEdit.Text := '';
     LatinSpecsFrm.CCodeEdit.Text := '';
     LatinSpecsFrm.DCodeEdit.Text := '';
     LatinSpecsFrm.GrpCodeEdit.Text := '';
     LatinSpecsFrm.DepVarEdit.Text := '';
     LatinSpecsFrm.nPerCellEdit.Text := '';
//     LatinSpecsFrm.GrpCodeEdit.Visible := true;
//     LatinSpecsFrm.DCodeLabel.Visible := true;
//     LatinSpecsFrm.GrpCodeLabel.Visible := true;
//     LatinSpecsFrm.DinBtn.Visible := true;
//     LatinSpecsFrm.DoutBtn.Visible := true;
     LatinSpecsFrm.DinBtn.Enabled := true;
     LatinSpecsFrm.DoutBtn.Enabled := false;
//     LatinSpecsFrm.GrpInBtn.Visible := true;
//     LatinSpecsFrm.GrpOutBtn.Visible := true;
     LatinSpecsFrm.GrpInBtn.Enabled := true;
     LatinSpecsFrm.GrpOutBtn.Enabled := false;
     LatinSpecsFrm.DataInBtn.Enabled := true;
     LatinSpecsFrm.DataOutBtn.Enabled := false;
     LatinSpecsFrm.ShowModal;
     if LatinSpecsFrm.ModalResult = mrCancel then exit;
     n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text);
     if n <= 0 then
     begin
          ShowMessage('Please specify the number of cases per cell.');
          exit;
     end;
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
    minA := 1000;
    minB := 1000;
    minGrp := 1000;
    maxA := -1000;
    maxB := -1000;
    minC := 1000;
    maxC := -1000;
    maxGrp := -1000;
    for i := 1 to NoCases do
    begin
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         if value < minA then minA := value;
         if value > maxA then maxA := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         if value < minB then minB := value;
         if value > maxB then maxB := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         if value < minC then minC := value;
         if value > maxC then maxC := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]);
         if value < minGrp then minGrp := value;
         if value > maxGrp then maxGrp := value;
    end;
    rangeA := maxA - minA + 1;
    rangeB := maxB - minB + 1;
    rangeC := maxC - minC + 1;
    rangeGrp := maxGrp - minGrp + 1;

    // check for squareness
    if  ((rangeA <> rangeB) or (rangeA <> rangeC) or (rangeA <> rangeGrp)) then
    begin
         ShowMessage('ERROR! In a Latin square the range of values should be equal for A,B and C!');
         exit;
    end;
    p := rangeA;

    // set up an array for cell counts and for cell sums and marginal sums
    SetLength(ABmat,p+1,p+1);
    SetLength(ABCmat,p+1,p+1,n+1);
    SetLength(cellcnts,p+1,p+1);
    SetLength(Atotals,p+1);
    SetLength(Btotals,p+1);
    SetLength(Ctotals,p+1);
    SetLength(Grptotals,p+1);
    SetLength(Design,p,p);
    SetLength(Subjtotals,p+1,n+1);
    SetLength(RowLabels,p+1);
    SetLength(ColLabels,n+1);
    SetLength(GBmat,p+1,p+1);
    SetLength(GCmat,p+1,p+1);

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
    begin
        for j := 0 to p do
        begin
            cellcnts[i,j] := 0;
            ABmat[i,j] := 0.0;
            GBmat[i,j] := 0.0;
            GCmat[i,j] := 0.0;
        end;
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

    G := 0.0;
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
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         group := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]);
         subject := StrToInt(OS3MainFrm.DataGrid.Cells[Sbjcol,i]);
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
    begin
         for j := 0 to p-1 do
         begin
              if cellcnts[i,j] <> n then
              begin
                   ShowMessage('cell sizes are not  equal!');
                   goto cleanup;
              end;
         end;
    end;

    // collapse slices into group x a matrix
    // result is the group times A matrix with BC cells containing n cases each
    for i := 0 to p-1 do // group
         for j := 0 to p-1 do // factor a
              for k := 0 to n-1 do // factor c
                  ABmat[i,j] := ABmat[i,j] + ABCmat[i,j,k];

    // get marginal totals for ABmat, GBmat and GCmat
    for i := 0 to p-1 do
    begin
        for j := 0 to p-1 do
        begin
            ABmat[p,j] := ABmat[p,j] + ABmat[i,j];
            ABmat[i,p] := ABmat[i,p] + ABmat[i,j];
            GBmat[p,j] := GBmat[p,j] + GBmat[i,j];
            GBmat[i,p] := GBmat[i,p] + GBmat[i,j];
            GCmat[p,j] := GCmat[p,j] + GCmat[i,j];
            GCmat[i,p] := GCmat[i,p] + GCmat[i,j];
        end;
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
    begin
         for j := 0 to n-1 do // subjects 1-n
         begin
              Subjtotals[p,j] := Subjtotals[p,j] + Subjtotals[i,j];
              Subjtotals[i,n] := Subjtotals[i,n] + Subjtotals[i,j];
         end;
    end;
    for i := 0 to p-1 do Subjtotals[p,n] := Subjtotals[p,n] + Subjtotals[i,n];

    // test block
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('Latin Squares Repeated Analysis Plan 7 (superimposed squares)');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Sums for ANOVA Analysis');
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Group (rows) times A Factor (columns) sums';
    MAT_PRINT(ABmat,p+1,p+1,cellstring,RowLabels,ColLabels,(n*p*p));
    cellstring := 'Group (rows) times B (cells Factor) sums';
    MAT_PRINT(GBmat,p+1,p+1,cellstring,RowLabels,ColLabels,(n*p*p));
    cellstring := 'Group (rows) times C (cells Factor) sums';
    MAT_PRINT(GCmat,p+1,p+1,cellstring,RowLabels,ColLabels,(n*p*p));
    for i := 0 to n-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[n] := 'Total';
    Title := 'Group (rows) times Subjects (columns) sums';
    Mat_Print(Subjtotals,p+1,n+1,Title,RowLabels,ColLabels,(n*p*p));
    OutputFrm.ShowModal;

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
    term1 := (GrandMean * GrandMean) / (n * p * p);
    term2 := sumxsqr;

    // get sum of squared groups for term4 of sum of squares for groups
    for i := 0 to p-1 do
        term4 := term4 + (Grptotals[i] * Grptotals[i]);
    term4 := term4 / (n * p);

    // get sum of squared a's for term3
    for j := 0 to p-1 do // levels of a
        term3 := term3 + (Atotals[j] * Atotals[j]);
    term3 := term3 / (n * p);

    // get squared sum of b's (across groups) for term5 of sum of squares b
    for j := 0 to p-1 do
        term5 := term5 + (Btotals[j] * Btotals[j]);
    term5 := term5 / (n * p);

    // get squared sum of c's (across groups) for term8 of SS for c
    for j := 0 to p-1 do
        term8 := term8 + (Ctotals[j] * Ctotals[j]);
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
            term6 := term6 + (ABmat[i,j] * ABmat[i,j]);
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
    probgrps := probf(fgroups,dfgroups,dfsubwgrps);
    proba := probf(fa,dfa,dferrwithin);
    probb := probf(fb,dfb,dferrwithin);
    probc := probf(fc,dfc,dferrwithin);
    probab := probf(fab,dfab,dferrwithin);

    // show ANOVA table results
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Latin Squares Repeated Analysis Plan 7 (superimposed squares)');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    OutputFrm.RichEdit.Lines.Add('Source         SS        DF        MS        F      Prob.>F');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    cellstring := 'Betw.Subj.';
    cellstring := cellstring + format('%9.3f %9.0f',[SSbetsubj,dfbetsubj]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Groups   ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSgroups,dfgroups,MSgroups,fgroups,probgrps]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Subj.w.g.';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSsubwgrps,dfsubwgrps,MSsubwgrps]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Within Sub';
    cellstring := cellstring + format('%9.3f %9.0f',[SSwithinsubj,dfwithinsubj]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor A ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSa,dfa,MSa,fa,proba]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor B ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSb,dfb,MSb,fb,probb]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor C ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSc,dfc,MSc,fc,probc]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' residual ';
    if dfab > 0 then
       cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSab,dfab,MSab,fab,probab])
    else
       cellstring := cellstring + format('     -    %9.0f      -',[dfab]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Error w. ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSerrwithin,dferrwithin,MSerrwithin]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Total     ';
    cellstring := cellstring + format('%9.3f %9.0f',[SStotal, dftotal]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');

    // show design for Square
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Experimental Design for Latin Square ';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format(' %3d ',[i]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[GroupFactor]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 1 to NoCases do
    begin
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]); // A (column) effect
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]); // B (cell) effect
         slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]); // C (cell) effect
         group := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]); // group (row)
         Design[group-1,row-1] := 'BC' + IntToStr(col) + IntToStr(slice);
    end;
    for i := 0 to p - 1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
              cellstring := cellstring + format('%5s',[Design[i,j]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);

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
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Cell means and totals');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[GroupFactor]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 0 to p-1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
             cellstring := cellstring + format(' %8.3f ',[ABmat[i,j]]);
         cellstring := cellstring + format(' %8.3f ',[ABmat[i,p]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := 'Total     ';
    for j := 0 to p-1 do
        cellstring := cellstring + format(' %8.3f ',[ABmat[p,j]]);
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    // show category means
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Means for each variable');
    OutputFrm.RichEdit.Lines.Add('');

    // factor A means
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Atotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    // means for B
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorB]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Btotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    // C means
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorC]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Ctotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);

    // Group means
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[GroupFactor]);
    for i := 1 to p do cellstring := cellstring + format('   %3d    ',[i]);
    cellstring := cellstring + '    Total';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '          ';
    for j := 0 to p - 1 do
    begin
         cellstring := cellstring + format(' %8.3f ',[Grptotals[j]]);
    end;
    cellstring := cellstring + format(' %8.3f ',[GrandMean]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '----------';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.ShowModal;

cleanup:
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

procedure TLatinSqrsFrm.Plan9(Sender: TObject);
label cleanup;
var
   NoFactors, row, col, slice, group, index : integer;
   Acol, Bcol, Ccol, SbjCol, Grpcol, DataCol : integer; // variable columns in grid
   FactorA : string;
   FactorB : string;
   FactorC : string;
   SubjectFactor : string;
   GroupFactor : string;
   DataVar : string;
   cellstring : string;
   i, j, k, m, minA, minB, minC, minGrp, maxA, maxB, maxC, maxGrp : integer;
   n, subject, nosubjects, rangeA, rangeB, rangeC, rangeGrp : integer;
   p, q, rows, value : integer;
   ABC, AGC : DblDyneCube;
   AB, AC, BC, RC : DblDyneMat;
   A, B, C, Persons, Gm, R : DblDyneVec;
   cellcnts : IntDyneVec;
   Design : StrDyneMat;
   RowLabels : StrDyneVec;
   ColLabels : StrDyneVec;
   G, sumxsqr, sumAsqr, sumBsqr, sumABsqr, sumACsqr : double;
   sumBCsqr, sumABCsqr, sumPsqr, sumGmsqr, sumRsqr : double;
   SSbetsubj, SSc, SSrows, SScxrow, SSsubwgrps, SSa : double;
   SSwithinsubj, SSerrwithin : double;
   SSb, SSac, SSbc, SSabprime, SSABCprime, SStotal : double;
   term1, term2, term3, term4, term5, term6, term7, term8, term9, term10 : double;
   term11, term12 : double;
   dfc, dfrows, dfcxrow, dfsubwgrps, dfwithinsubj, dfa, dfb,dfac : double;
   dfbc, dfabprime, dfabcprime,dferrwithin, dftotal, dfbetsubj : double;
   MSc, MSrows, MScxrow, MSsubwgrps, MSa : double;
   MSb, MSac, MSbc, MSabprime, MSabcprime, MSerrwithin: double;
   fc, frows, fcxrow, fsubwgrps, fa, fb, fac, fbc, fabprime, fabcprime : double;
   probc, probrows, probcxrow, probsubwgrps, proba, probb : double;
   probac, probbc, probabprime, probabcprime : double;
   data : double;

begin
     NoFactors := 4;
     cellstring := LatinSpecsFrm.DCodeLabel.Caption; // get current label
     LatinSpecsFrm.DCodeLabel.Caption := 'Subject No.'; // set new label
     LatinSpecsFrm.PanelD.Visible := true;
     LatinSpecsFrm.PanelGrp.Visible := true;
     LatinSpecsFrm.AinBtn.Enabled := true;
     LatinSpecsFrm.AoutBtn.Enabled := false;
     LatinSpecsFrm.BinBtn.Enabled := true;
     LatinSpecsFrm.BoutBtn.Enabled := false;
     LatinSpecsFrm.CinBtn.Enabled := true;
     LatinSpecsFrm.CoutBtn.Enabled := false;
//     LatinSpecsFrm.DCodeEdit.Visible := true;
     LatinSpecsFrm.ACodeEdit.Text := '';
     LatinSpecsFrm.BCodeEdit.Text := '';
     LatinSpecsFrm.CCodeEdit.Text := '';
     LatinSpecsFrm.DCodeEdit.Text := '';
     LatinSpecsFrm.GrpCodeEdit.Text := '';
     LatinSpecsFrm.DepVarEdit.Text := '';
     LatinSpecsFrm.nPerCellEdit.Text := '';
//     LatinSpecsFrm.GrpCodeEdit.Visible := true;
//     LatinSpecsFrm.DCodeLabel.Visible := true;
//     LatinSpecsFrm.GrpCodeLabel.Visible := true;
//     LatinSpecsFrm.DinBtn.Visible := true;
//     LatinSpecsFrm.DoutBtn.Visible := true;
     LatinSpecsFrm.DinBtn.Enabled := true;
     LatinSpecsFrm.DoutBtn.Enabled := false;
//     LatinSpecsFrm.GrpInBtn.Visible := true;
//     LatinSpecsFrm.GrpOutBtn.Visible := true;
     LatinSpecsFrm.GrpInBtn.Enabled := true;
     LatinSpecsFrm.GrpOutBtn.Enabled := false;
     LatinSpecsFrm.DataInBtn.Enabled := true;
     LatinSpecsFrm.DataOutBtn.Enabled := false;
     LatinSpecsFrm.ShowModal;
     if LatinSpecsFrm.ModalResult = mrCancel then exit;
     LatinSpecsFrm.DCodeLabel.Caption := cellstring; // restore label
     n := StrToInt(LatinSpecsFrm.nPerCellEdit.Text); // no. persons per cell
     if n <= 0 then
     begin
          ShowMessage('Please specify the number of subjects per group.');
          exit;
     end;
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
    minA := 1000;
    minB := 1000;
    minGrp := 1000;
    maxA := -1000;
    maxB := -1000;
    minC := 1000;
    maxC := -1000;
    maxGrp := -1000;
    nosubjects := 0;
    for i := 1 to NoCases do
    begin
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]);
         if value < minA then minA := value;
         if value > maxA then maxA := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]);
         if value < minB then minB := value;
         if value > maxB then maxB := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]);
         if value < minC then minC := value;
         if value > maxC then maxC := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[sbjcol,i]);
         if value > nosubjects then nosubjects := value;
         value := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]);
         if value < minGrp then minGrp := value;
         if value > maxGrp then maxGrp := value;
    end;
    rangeA := maxA - minA + 1;
    rangeB := maxB - minB + 1;
    rangeC := maxC - minC + 1;
    rangeGrp := maxGrp - minGrp + 1;

    // check for squareness
    if (rangeA <> rangeB) then
    begin
         ShowMessage('ERROR! In a Latin square the range of values should be equal for A,B and C!');
         exit;
    end;
    p := rangeA;
    q := rangeC;

    // set up an array for cell counts and for cell sums and marginal sums
    SetLength(ABC,p+1,p+1,q+1);
    SetLength(AGC,p+1,rangegrp+1,q+1);
    SetLength(AB,p+1,p+1);
    SetLength(AC,p+1,q+1);
    SetLength(BC,p+1,q+1);
    SetLength(RC,(rangegrp div q)+1,q+1);
    SetLength(A,p+1);
    SetLength(B,p+1);
    SetLength(C,q+1);
    SetLength(Persons,nosubjects+1);
    SetLength(Gm,rangegrp+1);
    SetLength(R,p+1);
    SetLength(cellcnts,p+1);
    SetLength(Design,rangegrp,p);
    SetLength(RowLabels,100);
    SetLength(ColLabels,100);

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
         i := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,index]);
         j := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,index]);
         k := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,index]);
         m := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,index]);
         subject := StrToInt(OS3MainFrm.DataGrid.Cells[Sbjcol,index]);
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
    begin
         if cellcnts[i-1] <> cellcnts[i] then
         begin
              ShowMessage('cell sizes are not  equal!');
              goto cleanup;
         end;
    end;

    // get sums in the RC matrix
    rows := rangegrp div q;
    for i := 0 to rows - 1 do
    begin
        for j := 0 to q-1 do
        begin
//            k := (i * q) + j;
            k := i + q * j;
            RC[i,j] := Gm[k];
        end;
    end;

    // get marginal totals for RC array
    for i := 0 to rows -1 do
    begin
        for j := 0 to q-1 do
        begin
            RC[i,q] := RC[i,q] + RC[i,j];
            RC[rows,j] := RC[rows,j] + RC[i,j];
        end;
    end;

    // get marginal totals for arrays ABC and AGC
    for i := 0 to p-1 do
    begin
         for j := 0 to p-1 do
         begin
              for k := 0 to q-1 do
              begin
                   ABC[i,j,q] := ABC[i,j,q] + ABC[i,j,k];
                   ABC[i,p,k] := ABC[i,p,k] + ABC[i,j,k];
                   ABC[p,j,k] := ABC[p,j,k] + ABC[i,j,k];
              end;
         end;
    end;

    for i := 0 to p-1 do
    begin
         for j := 0 to rangegrp - 1 do
         begin
              for k := 0 to q-1 do
              begin
                   AGC[i,j,q] := AGC[i,j,q] + AGC[i,j,k];
                   AGC[i,rangegrp,k] := AGC[i,rangegrp,k] + AGC[i,j,k];
                   AGC[p,j,k] := AGC[p,j,k] + AGC[i,j,k];
              end;
         end;
    end;

    for i := 0 to p-1 do
    begin
        for j := 0 to q-1 do
        begin
            AC[p,j] := AC[p,j] + AC[i,j];
            AC[i,q] := AC[i,q] + AC[i,j];
            BC[p,j] := BC[p,j] + BC[i,j];
            BC[i,q] := BC[i,q] + BC[i,j];
        end;
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
    begin
         for j := 0 to p-1 do
         begin
              AB[p,j] := AB[p,j] + AB[i,j];
              AB[i,p] := AB[i,p] + AB[i,j];
         end;
    end;
    for i := 0 to p-1 do AB[p,p] := AB[p,p] + AB[i,p];

    // get total for groups
    for m := 0 to rangegrp - 1 do Gm[rangegrp] := Gm[rangegrp] + Gm[m];

    // test block
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('Latin Squares Repeated Analysis Plan 9');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Sums for ANOVA Analysis');
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'ABC matrix';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('');
    for k := 0 to q-1 do
    begin
         cellstring := format('C level %d',[k+1]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '          ';
         for j := 0 to p-1 do cellstring := cellstring + format('  %3d     ',[j+1]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         for i := 0 to p-1 do // row
         begin
              cellstring := format('  %3d     ',[i+1]);
              for j := 0 to p-1 do
              begin
                   cellstring := cellstring + format('%9.3f ',[ABC[i,j,k]]);
              end;
              OutputFrm.RichEdit.Lines.Add(cellstring);
         end;
         OutputFrm.RichEdit.Lines.Add('');
         OutputFrm.RichEdit.Lines.Add('');
    end;
    cellstring := 'AB sums';
    MAT_PRINT(AB,p+1,p+1,cellstring,RowLabels,ColLabels,(n*p*q));
    cellstring := 'AC sums';
    MAT_PRINT(AC,p+1,q+1,cellstring,RowLabels,ColLabels,(n*p*q));
    cellstring := 'BC sums';
    MAT_PRINT(BC,p+1,q+1,cellstring,RowLabels,ColLabels,(n*p*q));
    cellstring := 'RC sums';
    MAT_PRINT(RC,rows+1,q+1,cellstring,RowLabels,ColLabels,(n*p*q));
    cellstring := 'Group totals';
    for i := 0 to rangegrp-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[rangegrp] := 'Total';
    DynVectorPrint(Gm,rangegrp+1,cellstring,ColLabels,(n*p*q));
    for i := 0 to nosubjects-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[nosubjects] := 'Total';
    cellstring := 'Subjects sums';
    DynVectorPrint(Persons,nosubjects+1,cellstring,ColLabels,(n*p*q));
    OutputFrm.ShowModal;

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
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Computation Terms');
    cellstring := format('Term1 = %9.3f',[term1]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term2 = %9.3f',[term2]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term3 = %9.3f',[term3]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term4 = %9.3f',[term4]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term5 = %9.3f',[term5]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term6 = %9.3f',[term6]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term7 = %9.3f',[term7]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term8 = %9.3f',[term8]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term9 = %9.3f',[term9]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term10 = %9.3f',[term10]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term11 = %9.3f',[term11]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('term12 = %9.3f',[term12]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear;

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
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Latin Squares Repeated Analysis Plan 9');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    OutputFrm.RichEdit.Lines.Add('Source         SS        DF        MS        F      Prob.>F');
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    cellstring := 'Betw.Subj.';
    cellstring := cellstring + format('%9.3f %9.0f',[SSbetsubj,dfbetsubj]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor C ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSc,dfc,MSc,fc,probc]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Rows     ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSrows,dfrows,MSrows,frows,probrows]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' C x row  ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SScxrow,dfcxrow,MScxrow,fcxrow,probcxrow]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Subj.w.g.';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSsubwgrps,dfsubwgrps,MSsubwgrps]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Within Sub';
    cellstring := cellstring + format('%9.3f %9.0f',[SSwithinsubj,dfwithinsubj]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor A ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSa,dfa,MSa,fa,proba]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor B ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSb,dfb,MSb,fb,probb]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor AC';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSac,dfac,MSac,fac,probac]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Factor BC';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSbc,dfbc,MSbc,fbc,probbc]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' AB prime ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSabprime,dfabprime,MSabprime,fabprime,probabprime]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' ABC prime';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f %9.3f %9.3f',[SSabcprime,dfabcprime,MSabcprime,fabcprime,probabcprime]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := ' Error w. ';
    cellstring := cellstring + format('%9.3f %9.0f %9.3f',[SSerrwithin,dferrwithin,MSerrwithin]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := 'Total     ';
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := cellstring + format('%9.3f %9.0f',[SStotal, dftotal]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('-----------------------------------------------------------');
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear;

    // show design for Squares c1, c2, etc.
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'Experimental Design for Latin Square ';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[FactorA]);
    for i := 1 to p do cellstring := cellstring + format(' %3d ',[i]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    cellstring := format('%10s',[GroupFactor]);
    OutputFrm.RichEdit.Lines.Add(cellstring);
    for i := 1 to NoCases do
    begin
         row := StrToInt(OS3MainFrm.DataGrid.Cells[Acol,i]); // A (column) effect
         col := StrToInt(OS3MainFrm.DataGrid.Cells[Bcol,i]); // B (cell) effect
         slice := StrToInt(OS3MainFrm.DataGrid.Cells[Ccol,i]); // C (cell) effect
         group := StrToInt(OS3MainFrm.DataGrid.Cells[Grpcol,i]); // group (row)
         Design[group-1,row-1] := 'B' + IntToStr(col);
    end;
    for i := 0 to rangegrp - 1 do
    begin
         cellstring := format('   %3d    ',[i+1]);
         for j := 0 to p - 1 do
             cellstring := cellstring + format('%5s',[Design[i,j]]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
    end;
    cellstring := '----------';
    for i := 1 to p + 1 do cellstring := cellstring + '-----';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear;

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

    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('Latin Squares Repeated Analysis Plan 9');
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.RichEdit.Lines.Add('Means for ANOVA Analysis');
    OutputFrm.RichEdit.Lines.Add('');
    cellstring := 'ABC matrix';
    OutputFrm.RichEdit.Lines.Add(cellstring);
    OutputFrm.RichEdit.Lines.Add('');
    for k := 0 to q-1 do
    begin
         cellstring := format('C level %d',[k+1]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         cellstring := '          ';
         for j := 0 to p-1 do cellstring := cellstring + format('  %3d     ',[j+1]);
         OutputFrm.RichEdit.Lines.Add(cellstring);
         for i := 0 to p-1 do // row
         begin
              cellstring := format('  %3d     ',[i+1]);
              for j := 0 to p-1 do
              begin
                   cellstring := cellstring + format('%9.3f ',[ABC[i,j,k]]);
              end;
              OutputFrm.RichEdit.Lines.Add(cellstring);
         end;
         OutputFrm.RichEdit.Lines.Add('');
         OutputFrm.RichEdit.Lines.Add('');
    end;
    cellstring := 'AB Means';
    MAT_PRINT(AB,p+1,p+1,cellstring,RowLabels,ColLabels,(n*p*p*q));
    cellstring := 'AC Means';
    MAT_PRINT(AC,p+1,q+1,cellstring,RowLabels,ColLabels,(n*p*p*q));
    cellstring := 'BC Means';
    MAT_PRINT(BC,p+1,q+1,cellstring,RowLabels,ColLabels,(n*p*p*q));
    cellstring := 'RC Means';
    MAT_PRINT(RC,rows+1,q+1,cellstring,RowLabels,ColLabels,(n*p*p*q));
    cellstring := 'Group Means';
    for i := 0 to rangegrp-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[rangegrp] := 'Total';
    DynVectorPrint(Gm,rangegrp+1,cellstring,ColLabels,(n*p*p*q));
    for i := 0 to nosubjects-1 do ColLabels[i] := IntToStr(i+1);
    ColLabels[nosubjects] := 'Total';
    cellstring := 'Subjects Means';
    DynVectorPrint(Persons,nosubjects+1,cellstring,ColLabels,(n*p*p*q));
    OutputFrm.ShowModal;

cleanup:
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

initialization
  {$I latinsqrsunit.lrs}

end.

