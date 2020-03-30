unit BNestAUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, GraphLib, Globals;

type

  { TBNestedAForm }

  TBNestedAForm = class(TForm)
    ACodes: TEdit;
    AInBtn: TBitBtn;
    AOutBtn: TBitBtn;
    BCodes: TEdit;
    Bevel1: TBevel;
    BInBtn: TBitBtn;
    BOutBtn: TBitBtn;
    Memo1: TLabel;
    RandomBChk: TCheckBox;
    DepInBtn: TBitBtn;
    ComputeBtn: TButton;
    DepOutBtn: TBitBtn;
    DepEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OptionsBox: TRadioGroup;
    ResetBtn: TButton;
    CloseBtn: TButton;
    VarList: TListBox;
    procedure AInBtnClick(Sender: TObject);
    procedure AOutBtnClick(Sender: TObject);
    procedure BInBtnClick(Sender: TObject);
    procedure BOutBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    SS, SumSqr, CellMeans, CellSDs : DblDyneMat;
    CellCount : IntDyneMat;
    ASS, BSS, ASumSqr, BSumSqr, AMeans, BMeans, ASDs : DblDyneVec;
    ACount, BCount : IntDyneVec;
    MinA, MinB, MaxA, MaxB, NoALevels, NoBLevels, ACol, BCol, YCol : integer;
    DepVar, FactorA, FactorB : string;
    SSTot, SumSqrTot, TotMean, MSTot, SSA, MSA, SSB, MSB, SSW, MSW : double;
    TotN, dfA, dfBwA, dfwcell, dftotal : integer;

    function GetVars: Boolean;
    procedure GetMemory;
    procedure GetSums;
    procedure ShowMeans(AReport: TStrings);
    procedure GetResults;
    procedure ShowResults(AReport: TStrings);
    procedure ReleaseMemory;
    procedure TwoWayPlot;

    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  BNestedAForm: TBNestedAForm;

implementation

uses
  Math;

{ TBNestedAForm }

procedure TBNestedAForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Items.Clear;
  ACodes.Text := '';
  BCodes.Text := '';
  DepEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TBNestedAForm.AInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (ACodes.Text = '') then
  begin
    ACodes.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TBNestedAForm.AOutBtnClick(Sender: TObject);
begin
  if ACodes.Text <> '' then
  begin
    VarList.Items.Add(ACodes.Text);
    ACodes.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TBNestedAForm.BInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (BCodes.Text = '') then
  begin
    BCodes.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TBNestedAForm.BOutBtnClick(Sender: TObject);
begin
  if BCodes.Text <> '' then
  begin
    VarList.Items.Add(BCodes.Text);
    BCodes.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TBNestedAForm.ComputeBtnClick(Sender: TObject);
var
  lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
    if GetVars then
    begin
      GetMemory;
      GetSums;
      ShowMeans(lReport);
      GetResults;
      ShowResults(lReport);
      DisplayReport(lReport);
      TwoWayPlot;
      ReleaseMemory;
    end;
  finally
    lReport.Free;
  end;
end;

procedure TBNestedAForm.DepInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepEdit.Text = '') then
  begin
    DepEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TBNestedAForm.DepOutBtnClick(Sender: TObject);
begin
  if DepEdit.Text <>  '' then
  begin
    VarList.Items.Add(DepEdit.Text);
    DepEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TBNestedAForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := DepOutBtn.Top + DepOutBtn.Height - VarList.Top;
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TBNestedAForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

function TBNestedAForm.GetVars: Boolean;
var
  i, group : integer;
  strvalue, cellstring : string;
begin
  Result := false;
  DepVar := DepEdit.Text;
  FactorA := ACodes.Text;
  FactorB := BCodes.Text;
  ACol := 0;
  BCol := 0;
  YCol := 0;
  MinA := 1000;
  MaxA := -1000;
  MinB := 1000;
  MaxB := -1000;
  for i := 1 to NoVariables do
      begin
        strvalue := Trim(OS3MainFrm.DataGrid.Cells[i,0]);
        if FactorA = strvalue then ACol := i;
        if FactorB = strvalue then BCol := i;
        if DepVar = strvalue then YCol := i;
      end;
  if (ACol = 0) or (BCol = 0) or (YCol = 0) then
     begin
          MessageDlg('Select a variable for each entry box.', mtError, [mbOK], 0);
          exit;
     end;
  // get number of levels for Factors
  for i := 1 to NoCases do
      begin
        cellstring := Trim(OS3MainFrm.DataGrid.Cells[ACol,i]);
        group := round(StrToFloat(cellstring));
        if (group > MaxA) then MaxA := group;
        if (group < MinA) then MinA := group;
        cellstring := Trim(OS3MainFrm.DataGrid.Cells[BCol,i]);
        group := round(StrToFLoat(cellstring));
        if (group > MaxB) then MaxB := group;
        if (group < MinB) then MinB := group;
      end;
  NoALevels := MaxA - MinA + 1;
  NoBLevels := MaxB - MinB + 1;

  Result := true;
end;

procedure TBNestedAForm.GetMemory;
begin
  SetLength(SS,NoBLevels,NoALevels);
  SetLength(SumSqr,NoBLevels,NoALevels);
  SetLength(CellCount,NoBLevels,NoALevels);
  SetLength(CellMeans,NoBLevels,NoALevels);
  SetLength(CellSDs,NoBLevels,NoALevels);
  SetLength(ASS,NoALevels);
  SetLength(BSS,NoBLevels);
  SetLength(ASumSqr,NoALevels);
  SetLength(BSumSqr,NoBLevels);
  SetLength(AMeans,NoALevels);
  SetLength(BMeans,NoBLevels);
  SetLength(ACount,NoALevels);
  SetLength(BCount,NoBLevels);
  SetLength(ASDs,NoALevels);
end;

procedure TBNestedAForm.GetSums;
VAR
  Aindex, Bindex, i, j : integer;
  YValue : double;
  strvalue : string;
begin
  // initialize memory
  for i := 0 to NoBLevels-1 do
      begin
           for j := 0 to NoALevels-1 do
               begin
                  SS[i,j] := 0.0;
                  SumSqr[i,j] := 0.0;
                  CellCount[i,j] := 0;
               end;
      end;
  for i := 0 to NoALevels-1 do
      begin
         ACount[i] := 0;
         AMeans[i] := 0.0;
         ASS[i] := 0.0;
         ASumSqr[i] := 0.0;
      end;
  for j := 0 to NoBLevels-1 do
      begin
         BCount[i] := 0;
         BMeans[i] := 0.0;
         BSS[i] := 0.0;
         BSumSqr[i] := 0.0;
      end;
  // Accumulate sums and sums of squared values
  for i := 1 to NoCases do
      begin
         strvalue := Trim(OS3MainFrm.DataGrid.Cells[ACol,i]);
         Aindex := round(StrToFloat(strvalue));
         strvalue := Trim(OS3MainFrm.DataGrid.Cells[BCol,i]);
         Bindex := round(StrToFloat(strvalue));
         strvalue := Trim(OS3MainFrm.DataGrid.Cells[YCol,i]);
         YValue := StrToFloat(strvalue);
         Aindex := Aindex - MinA;
         Bindex := Bindex - MinB;
         SS[Bindex,Aindex] := SS[Bindex,Aindex] + YValue * YValue;
         SumSqr[Bindex,Aindex] := SumSqr[Bindex,Aindex] + YValue;
         CellCount[Bindex,Aindex] := CellCount[Bindex,Aindex] + 1;
         ACount[Aindex] := ACount[Aindex] + 1;
         BCount[Bindex] := BCount[Bindex] + 1;
         ASS[Aindex] := ASS[Aindex] + YValue * YValue;
         BSS[Bindex] := BSS[Bindex] + YValue * YValue;
         ASumSqr[Aindex] := ASumSqr[Aindex] + YValue;
         BSumSqr[Bindex] := BSumSqr[Bindex] + YValue;
         SSTot := SSTot + YValue * YValue;
         SumSqrTot := SumSqrTot + YValue;
         TotN := TotN + 1;
      end;
  //get cell means and marginal means, SDs plus square of sums
  for i := 0 to NoBlevels-1 do
      begin
         for j := 0 to NoALevels-1 do
             begin
                if CellCount[i,j] > 0 then
                   begin
                     CellMeans[i,j] := SumSqr[i,j] / CellCount[i,j];
                     SumSqr[i,j] := SumSqr[i,j] * SumSqr[i,j];
                     CellSDs[i,j] := SS[i,j] - (SumSqr[i,j] / CellCount[i,j]);
                     CellSDs[i,j] := CellSDs[i,j] / (CellCount[i,j] - 1);
                     CellSDs[i,j] := Sqrt(CellSDs[i,j]);
                   end;
             end;
      end;
  for i := 0 to NoBLevels-1 do
      begin
         BMeans[i] := BSumSqr[i] / BCount[i];
         BSumSqr[i] := BSumSqr[i] * BSumSqr[i];
      end;
  for i := 0 to NoALevels-1 do
      begin
         AMeans[i] := ASumSqr[i] / ACount[i];
         ASumSqr[i] := ASumSqr[i] * ASumSqr[i];
         ASDs[i] := ASS[i] - (ASumSqr[i] / ACount[i]);
         ASDs[i] := ASDs[i] / (ACount[i] - 1);
         ASDs[i] := Sqrt(ASDs[i]);
      end;
  TotMean := SumSqrTot / TotN;
  SumSqrTot := SumSqrTot * SumSqrTot;
end;

procedure TBNestedAForm.ShowMeans(AReport: TStrings);
var
  i, j: integer;
begin
  AReport.Add('NESTED ANOVA by Bill Miller');
  AReport.Add('');
  AReport.Add('File Analyzed: %s', [OS3MainFrm.FileNameEdit.Text]);
  AReport.Add('');
  AReport.Add('CELL MEANS');
  AReport.Add('A LEVEL     BLEVEL         MEAN       STD.DEV.');
  for i := 0 to NoALevels-1 do
    for j := 0 to NoBLevels-1 do
      if CellCount[j,i] > 0 then
        AReport.Add('%5d     %5d        %10.3f     %10.3f', [i+MinA, j+MinB, CellMeans[j,i], CellSDs[j,i]]);
  AReport.Add('');
  AReport.Add('A MARGIN MEANS');
  AReport.Add('A LEVEL       MEAN       STD.DEV.');
  for i := 0 to NoALevels-1 do
    AReport.Add('%5d     %10.3f       %10.3f', [i+MinA, AMeans[i], ASDs[i]]);
  AReport.Add('');
  AReport.Add('GRAND MEAN: %0.3f', [TotMean]);
  AReport.Add('');
  AReport.Add('');
end;

procedure TBNestedAForm.GetResults;
VAR
  temp, constant : double;
  NoBLevelsInA, BLevCount, i, j, celln : integer;
begin
  celln := 0;
  for i := 0 to NoALevels-1 do
      begin
         for j := 0 to NoBLevels-1 do
             begin
                if CellCount[j,i] > celln then celln := CellCount[j,i];
             end;
      end;
  // assume all cells have same n size
  // get no. of levels in A
  BLevCount := 0;
  for i := 0 to NoALevels-1 do
      begin
         NoBLevelsInA := 0;
         for j := 0 to NoBLevels-1 do
             begin
                if CellCount[j,i] > 0 then NoBLevelsInA := NoBLevelsInA + 1;
             end;
         if NoBLevelsInA > BLevCount then BLevCount := NoBLevelsInA;
      end;
  dfA := NoALevels - 1;
  dfBwA := NoALevels * (BLevCount - 1);
  dfwcell := NoALevels * BLevCount * (celln - 1);
  dftotal := TotN - 1;
  constant := SumSqrTot / TotN;
  SSTot := SSTot - constant;
  MSTot := SSTot / dftotal;
  SSA := 0.0;
  for i := 0 to NoALevels-1 do SSA := SSA + (ASumSqr[i] / ACount[i]);
  temp := SSA;
  SSA := SSA - constant;
  MSA := SSA / dfA;
  SSB := 0.0;
  for i := 0 to NoALevels - 1 do
      begin
         for j := 0 to NoBLevels-1 do
             begin
                if CellCount[j,i] > 0 then SSB := SSB + (SumSqr[j,i] / CellCount[j,i]);
             end;
      end;
  SSB := SSB - temp;
  MSB := SSB / dfBwA;
  SSW := SSTot - SSA - SSB;
  MSW := SSW / dfwcell;
 (*
  OutputFrm.RichEdit.Clear;
  strvalue := format('SSA = %10.3f  MSA = %10.3f  SSB = %10.3f  MSB = %10.3f',
     [SSA,MSA,SSB,MSB]);
  OutputFrm.RichEdit.Lines.Add(strvalue);
  strvalue := format('SSW = %10.3f  MSW = %10.3f',[SSW,MSW]);
  OutputFrm.RichEdit.Lines.Add(strvalue);
  OutputFrm.ShowModal;
*)
end;

procedure TBNestedAForm.ShowResults(AReport: TStrings);
var
  F, PF: double;
begin
  AReport.Add('ANOVA TABLE');
  AReport.Add('SOURCE     D.F.        SS        MS        F         PROB.');

  if RandomBChk.Checked then
  begin
    F := MSA / MSB;
    PF := probf(F, dfA, dfBwA);
  end else
  begin
    F := MSA / MSW;
    PF := probf(F, dfA, dfwcell);
  end;
  AReport.Add('A         %4d  %10.3f%10.3f%10.3f%10.3f', [dfA, SSA, MSA, F, PF]);

  F := MSB / MSW;
  PF := probf(F,dfBwA,dfwcell);
  AReport.Add('B(W)      %4d  %10.3f%10.3f%10.3f%10.3f', [dfBwA, SSB, MSB, F, PF]);

  AReport.Add('w.cells   %4d  %10.3f%10.3f', [dfwcell, SSW, MSW]);
  AReport.Add('Total     %4d  %10.3f', [dftotal, SSTot]);
end;

procedure TBNestedAForm.ReleaseMemory;
begin
  ASDs := nil;
  BCount := nil;
  ACount := nil;
  BMeans := nil;
  AMeans := nil;
  BSumSqr := nil;
  ASumSqr := nil;
  BSS := nil;
  ASS := nil;
  CellSDs := nil;
  CellMeans := nil;
  CellCount := nil;
  SumSqr := nil;
  SS := nil;
end;

procedure TBNestedAForm.TwoWayPlot;
VAR
  plottype, i: integer;
  maxmean: double;
  title: string;
  XValue : DblDyneVec;
begin
  case OptionsBox.ItemIndex of
    0: plotType := 9;
    1: plotType := 10;
    2: plotType := 1;
    3: plotType := 2;
    else raise Exception.Create('Plot type not supported.');
  end;

  GraphFrm.SetLabels[1] := 'FACTOR A';

  maxmean := -1000.0;
  SetLength(XValue,NoALevels+NoBLevels);
  SetLength(GraphFrm.Xpoints,1,NoALevels);
  SetLength(GraphFrm.Ypoints,1,NoALevels);
  for i := 1 to NoALevels do
      begin
        GraphFrm.Ypoints[0,i-1] := AMeans[i-1];
        if AMeans[i-1] > maxmean then maxmean := AMeans[i-1];
        XValue[i-1] := MinA + i -1;
        GraphFrm.Xpoints[0,i-1] := XValue[i-1];
      end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := NoALevels;
  GraphFrm.Heading := FactorA;
  GraphFrm.XTitle := FactorA + ' Group Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clCream;
  GraphFrm.WallColor := clDkGray;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;

  // Factor B next
  maxmean := 0.0;
  GraphFrm.SetLabels[1] := 'FACTOR B';
  SetLength(GraphFrm.Xpoints,1,NoBLevels);
  SetLength(GraphFrm.Ypoints,1,NoBLevels);
  for i := 1 to NoBLevels do
      begin
        GraphFrm.Ypoints[0,i-1] := BMeans[i-1];
        if BMeans[i-1] > maxmean then maxmean := BMeans[i-1];
        XValue[i-1] := MinB + i - 1;
        GraphFrm.Xpoints[0,i-1] := XValue[i-1];
      end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := NoBLevels;
  GraphFrm.Heading := 'FACTOR B';
  GraphFrm.XTitle := FactorB + ' Group Codes';
  GraphFrm.YTitle := 'Mean';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxmean;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clCream;
  GraphFrm.WallColor := clDkGray;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
  XValue := nil;
end;

procedure TBNestedAForm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TBNestedAForm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i := 0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;

  AInBtn.Enabled := lSelected and (ACodes.Text = '');
  BInBtn.Enabled := lSelected and (BCodes.Text = '');
  DepInBtn.Enabled := lSelected and (DepEdit.Text = '');
  AOutBtn.Enabled := (ACodes.Text <> '');
  BOutBtn.Enabled := (BCodes.Text <> '');
  DepOutBtn.Enabled := (DepEdit.Text <> '');
end;

initialization
  {$I bnestaunit.lrs}

end.

