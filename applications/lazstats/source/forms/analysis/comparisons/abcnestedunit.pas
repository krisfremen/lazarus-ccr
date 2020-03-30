unit ABCNestedUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, GraphLib, Globals;

type

  { TABCNestedForm }

  TABCNestedForm = class(TForm)
    Bevel1: TBevel;
    FactorCEdit: TEdit;
    FactorAEdit: TEdit;
    AInBtn: TBitBtn;
    AOutBtn: TBitBtn;
    FactorBEdit: TEdit;
    BInBtn: TBitBtn;
    BOutBtn: TBitBtn;
    ComputeBtn: TButton;
    DepEdit: TEdit;
    DepInBtn: TBitBtn;
    CInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    COutBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TLabel;
    OptionsBox: TRadioGroup;
    Panel1: TPanel;
    ResetBtn: TButton;
    CloseBtn: TButton;
    VarList: TListBox;
    procedure AInBtnClick(Sender: TObject);
    procedure AOutBtnClick(Sender: TObject);
    procedure BInBtnClick(Sender: TObject);
    procedure BOutBtnClick(Sender: TObject);
    procedure CInBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure COutBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: Boolean;
    CellCount: IntDyneCube;
    ASS, BSS, CSS, ASumSqr, BSumSqr, CSumSqr, AMeans, BMeans, ASDs : DblDyneVec;
    CMeans, BSDs, CSDs : DblDyneVec;
    ACSS,ACSumSqr, ACMeans, ACSDs, ABSS, ABSumSqr, ABMeans, ABSDs : DblDyneMat;
    ACount, BCount, CCount : IntDyneVec;
    ACCount, ABCount : IntDyneMat;
    CellSDs, SS, SumSqr, CellMeans : DblDyneCube;
    MinA, MinB, MaxA, MaxB, NoALevels, NoBLevels, ACol, BCol, YCol : integer;
    CCol, MinC, MaxC, NoCLevels : integer;
    DepVar, FactorA, FactorB, FactorC : string;
    SSTot, SumSqrTot, TotMean, MSTot, SSA, MSA, SSB, MSB, SSW, MSW : double;
    SSC, MSC, SSAC, MSAC, SSBwAC, SSAB, MSBwAC : double;
    TotN, dfA, dfBwA, dfwcell, dftotal, dfC, dfAC, dfBwAC : integer;
    ColNoSelected : IntDyneVec;

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
  ABCNestedForm: TABCNestedForm;

implementation

uses
  Math;

{ TABCNestedForm }

procedure TABCNestedForm.ResetBtnClick(Sender: TObject);
VAR
  i : integer;
begin
  VarList.Items.Clear;
  FactorAEdit.Text := '';
  FactorBEdit.Text := '';
  FactorCEdit.Text := '';
  DepEdit.Text := '';
  AInBtn.Enabled := true;
  AOutBtn.Enabled := false;
  BInBtn.Enabled := true;
  BOutBtn.Enabled := false;
  CInBtn.Enabled := true;
  COutBtn.Enabled := false;
  DepInBtn.Enabled := true;
  DepoutBtn.Enabled := false;
  OptionsBox.ItemIndex := 3;
  for i := 1 to NoVariables do
      VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  OptionsBox.ItemIndex := 3;
end;

procedure TABCNestedForm.AInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (FactorAEdit.Text = '') then
  begin
    FactorAEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TABCNestedForm.AOutBtnClick(Sender: TObject);
begin
  if FactorAEdit.Text <> '' then
  begin
    VarList.Items.Add(FactorAEdit.Text);
    FactorAEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TABCNestedForm.BInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (FactorBEdit.Text = '') then
  begin
    FactorBEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TABCNestedForm.BOutBtnClick(Sender: TObject);
begin
  if FactorBEdit.Text <> '' then
  begin
    VarList.Items.Add(FactorBEdit.Text);
    FactorBEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TABCNestedForm.CInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (FactorCEdit.Text = '') then
  begin
    FactorCEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TABCNestedForm.ComputeBtnClick(Sender: TObject);
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
      TwoWayPlot;
      ReleaseMemory;
    end;
  finally
    lReport.Free;
  end;
end;

procedure TABCNestedForm.COutBtnClick(Sender: TObject);
begin
  if FactorCEdit.Text <> '' then
  begin
    VarList.Items.Add(FactorCEdit.Text);
    FactorCEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TABCNestedForm.DepInBtnClick(Sender: TObject);
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

procedure TABCNestedForm.DepOutBtnClick(Sender: TObject);
begin
  if DepEdit.Text <> '' then
  begin
    VarList.Items.Add(DepEdit.Text);
    DepEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TABCNestedForm.FormActivate(Sender: TObject);
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

procedure TABCNestedForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

function TABCNestedForm.GetVars: Boolean;
var
  i, group: integer;
  strvalue, cellstring: string;
begin
  Result := false;

  SetLength(ColNoSelected,4);
  DepVar := DepEdit.Text;
  FactorA := FactorAEdit.Text;
  FactorB := FactorBEdit.Text;
  FactorC := FactorCEdit.Text;
  ACol := 0;
  BCol := 0;
  CCol := 0;
  YCol := 0;
  MinA := 1000;
  MaxA := -1000;
  MinB := 1000;
  MaxB := -1000;
  MinC := 1000;
  MaxC := -1000;
  for i := 1 to NoVariables do
  begin
    strvalue := Trim(OS3MainFrm.DataGrid.Cells[i,0]);
    if FactorA = strvalue then
    begin
      ACol := i;
      ColNoSelected[0] := i;
    end;
    if FactorB = strvalue then
    begin
      BCol := i;
      ColNoSelected[1] := i;
    end;
    if FactorC = strvalue then
    begin
      CCol := i;
      ColNoSelected[2] := i;
    end;
    if DepVar = strvalue then
    begin
      YCol := i;
      ColNoSelected[3] := i;
    end;
  end;
  if (ACol = 0) or (BCol = 0) or (CCol = 0) or (YCol = 0) then
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

    cellstring := Trim(OS3MainFrm.DataGrid.Cells[CCol,i]);
    group := round(StrToFLoat(cellstring));
    if (group > MaxC) then MaxC := group;
    if (group < MinC) then MinC := group;
  end;

  NoALevels := MaxA - MinA + 1;
  NoBLevels := MaxB - MinB + 1;
  NoCLevels := MaxC - MinC + 1;

  Result := true;
end;

procedure TABCNestedForm.GetMemory;
begin
  SetLength(SS,NoBLevels,NoALevels,NoCLevels);
  SetLength(SumSqr,NoBLevels,NoALevels,NoCLevels);
  SetLength(CellCount,NoBLevels,NoALevels,NoCLevels);
  SetLength(CellMeans,NoBLevels,NoALevels,NoCLevels);
  SetLength(CellSDs,NoBLevels,NoALevels,NoCLevels);
  SetLength(ASS,NoALevels);
  SetLength(BSS,NoBLevels);
  SetLength(CSS,NoCLevels);
  SetLength(ASumSqr,NoALevels);
  SetLength(BSumSqr,NoBLevels);
  SetLength(CSumSqr,NoCLevels);
  SetLength(AMeans,NoALevels);
  SetLength(BMeans,NoBLevels);
  SetLength(CMeans,NoCLevels);
  SetLength(ACount,NoALevels);
  SetLength(BCount,NoBLevels);
  SetLength(CCount,NoCLevels);
  SetLength(ASDs,NoALevels);
  SetLength(BSDs,NoBLevels);
  SetLength(CSDs,NoCLevels);
  SetLength(ACSS,NoALevels,NoCLevels);
  SetLength(ACSumSqr,NoALevels,NoCLevels);
  SetLength(ACCount,NoALevels,NoCLevels);
  SetLength(ACMeans,NoALevels,NoCLevels);
  SetLength(ACSDs,NoALevels,NoCLevels);
  SetLength(ABSS,NoALevels,NoBLevels);
  SetLength(ABSumSqr,NoALevels,NoBLevels);
  SetLength(ABMeans,NoALevels,NoBLevels);
  SetLength(ABCount,NoALevels,NoBLevels);
  SetLength(ABSDs,NoALevels,NoBLevels);
end;

procedure TABCNestedForm.GetSums;
VAR
  Aindex, Bindex, Cindex, i, j, k: integer;
  YValue: double;
  strvalue: string;
begin
  // clear memory
  SSTot := 0.0;
  SumSqrTot := 0.0;
  for i := 0 to NoBLevels-1 do
      begin
        for j := 0 to NoALevels-1 do
            begin
              for k := 0 to NoCLevels-1 do
                  begin
                    SS[i,j,k] := 0.0;
                    SumSqr[i,j,k] := 0.0;
                    CellCount[i,j,k] := 0;
                    CellMeans[i,j,k] := 0.0;
                  end;
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
         BCount[j] := 0;
         BMeans[j] := 0.0;
         BSS[j] := 0.0;
         BSumSqr[j] := 0.0;
      end;
  for k := 0 to NoCLevels-1 do
      begin
        CCount[k] := 0;
        CMeans[k] := 0.0;
        CSS[k] := 0.0;
        CSumSqr[k] := 0.0;
      end;

  for i := 0 to NoALevels-1 do
      begin
        for j := 0 to NoBLevels-1 do
            begin
              ABSS[i,j] := 0.0;
              ABSumSqr[i,j] := 0.0;
              ABCount[i,j] := 0;
              ABSDs[i,j] := 0.0;
            end;
      end;
  for i := 0 to NoALevels-1 do
      begin
        for k := 0 to NoCLevels-1 do
            begin
              ACSS[i,k] := 0.0;
              ACSumSqr[i,k] := 0.0;
              ACCount[i,k] := 0;
              ACSDs[i,k] := 0.0;
            end;
      end;

  // accumulate sums and sums of squared values
  for i := 1 to NoCases do
      begin
         strvalue := Trim(OS3MainFrm.DataGrid.Cells[ACol,i]);
         Aindex := round(StrToFloat(strvalue));
         strvalue := Trim(OS3MainFrm.DataGrid.Cells[BCol,i]);
         Bindex := round(StrToFloat(strvalue));
         strvalue := Trim(OS3MainFrm.DataGrid.Cells[CCol,i]);
         Cindex := round(StrToFloat(strvalue));
         strvalue := Trim(OS3MainFrm.DataGrid.Cells[YCol,i]);
         YValue := StrToFloat(strvalue);
         Aindex := Aindex - MinA;
         Bindex := Bindex - MinB;
         Cindex := Cindex - MinC;
         SS[Bindex,Aindex,Cindex] := SS[Bindex,Aindex,Cindex] + YValue * YValue;
         SumSqr[Bindex,Aindex,Cindex] := SumSqr[Bindex,Aindex,Cindex] + YValue;
         CellCount[Bindex,Aindex,Cindex] := CellCount[Bindex,Aindex,Cindex] + 1;
         ACount[Aindex] := ACount[Aindex] + 1;
         BCount[Bindex] := BCount[Bindex] + 1;
         CCount[Cindex] := CCount[Cindex] + 1;
         ASS[Aindex] := ASS[Aindex] + YValue * YValue;
         BSS[Bindex] := BSS[Bindex] + YValue * YValue;
         CSS[Cindex] := CSS[Cindex] + YValue * YValue;
         ASumSqr[Aindex] := ASumSqr[Aindex] + YValue;
         BSumSqr[Bindex] := BSumSqr[Bindex] + YValue;
         CSumSqr[Cindex] := CSumSqr[Cindex] + YValue;
         ACSS[Aindex,Cindex] := ACSS[Aindex,Cindex] + YValue * YValue;
         ACSumSqr[Aindex,Cindex] := ACSumSqr[Aindex,Cindex] + YValue;
         ACCount[Aindex,Cindex] := ACCount[Aindex,Cindex] + 1;
         ABSS[Aindex,Bindex] := ABSS[Aindex,Bindex] + YValue * YValue;
         ABSumSqr[Aindex,Bindex] := ABSumSqr[Aindex,Bindex] + YValue;
         ABCount[Aindex,Bindex] := ABCount[Aindex,Bindex] + 1;
         SSTot := SSTot + YValue * YValue;
         SumSqrTot := SumSqrTot + YValue;
         TotN := TotN + 1;
      end;

    // get cell means and marginal means plus square of sums
   for i := 0 to NoBLevels-1 do
       begin
         for j := 0 to NoALevels-1 do
             begin
               for k := 0 to NoCLevels-1 do
                   begin
                     if CellCount[i,j,k] > 0 then
                        begin
                             CellMeans[i,j,k] := SumSqr[i,j,k] / CellCount[i,j,k];
                             SumSqr[i,j,k] := SumSqr[i,j,k] * SumSqr[i,j,k];
                             CellSDs[i,j,k] := SS[i,j,k] - (SumSqr[i,j,k] / CellCount[i,j,k]);
                             CellSDs[i,j,k] := CellSDs[i,j,k] / (CellCount[i,j,k] - 1);
                             CellSDs[i,j,k] := sqrt(CellSDs[i,j,k]);
                        end;
                   end;
             end;
       end;
   for i := 0 to NoBLevels-1 do
       begin
         if BCount[i] > 0 then
            begin
              BMeans[i] := BSumSqr[i] / BCount[i];
              BSumSqr[i] := BSumSqr[i] * BSumSqr[i];
              BSDs[i] := BSS[i] - (BSumSqr[i] / BCount[i]);
              BSDs[i] := BSDs[i] / (BCount[i] - 1);
              BSDs[i] := sqrt(BSDs[i]);
            end;
       end;
   for i := 0 to NoALevels-1 do
       begin
          AMeans[i] := ASumSqr[i] / ACount[i];
          ASumSqr[i] := ASumSqr[i] * ASumSqr[i];
          ASDs[i] := ASS[i] - (ASumSqr[i] / ACount[i]);
          ASDs[i] := ASDs[i] / (ACount[i] - 1);
          ASDs[i] := Sqrt(ASDs[i]);
       end;
   for i := 0 to NoCLevels-1 do
       begin
         CMeans[i] := CSumSqr[i] / CCount[i];
         CSumSqr[i] := CSumSqr[i] * CSumSqr[i];
         CSDs[i] := CSS[i] - (CSumSqr[i] / CCount[i]);
         CSDs[i] := CSDs[i] / (CCount[i] - 1);
         CSDs[i] := sqrt(CSDs[i]);
       end;
   for i := 0 to NoALevels-1 do
       begin
         for k := 0 to NoCLevels-1 do
             begin
               ACMeans[i,k] := ACMeans[i,k] / ACCount[i,k];
               ACSumSqr[i,k] := ACSumSqr[i,k] * ACSumSqr[i,k];
               ACSDs[i,k] := ACSS[i,k] - (ACSumSqr[i,k] / ACCount[i,k]);
               ACSDs[i,k] := ACSDs[i,k] / (ACCount[i,k] - 1);
               ACSDs[i,k] := sqrt(ACSDs[i,k]);
             end;
       end;
   for i := 0 to NoALevels-1 do
       begin
         for j := 0 to NoBLevels-1 do
             begin
               if ABCount[i,j] > 0 then
                  begin
                    ABMeans[i,j] := ABSumSqr[i,j] / ABCount[i,j];
                    ABSumSqr[i,j] := ABSumSqr[i,j] * ABSumSqr[i,j];
                    ABSDs[i,j] :=ABSS[i,j] - (ABSumSqr[i,j] / ABCount[i,j]);
                    ABSDs[i,j] := ABSDs[i,j] / (ABCount[i,j] - 1);
                    ABSDs[i,j] := sqrt(ABSDs[i,j]);
                  end;
             end;
       end;
   TotMean := SumSqrTot / TotN;
   SumSqrTot := SumSqrTot * SumSqrTot;
end;

procedure TABCNestedForm.ShowMeans(AReport: TStrings);
var
  i, j, k : integer;
begin
  AReport.Add('Nested ANOVA by Bill Miller');
  AReport.Add('File Analyzed = %s', [OS3MainFrm.FileNameEdit.Text]);
  AReport.Add('');

  AReport.Add('CELL MEANS');
  AReport.Add('A LEVEL     BLEVEL       CLEVEL       MEAN       STD.DEV.');
  for i := 0 to NoALevels-1 do
    for j := 0 to NoBLevels-1 do
      for k := 0 to NoCLevels-1 do
        if CellCount[j,i,k] > 0 then
          AReport.Add('%5d       %5d       %5d    %10.4f    %10.4f', [i+MinA, j+MinB, k+MinC, CellMeans[j,i,k], CellSDs[j,i,k]]);
  AReport.Add('');

  AReport.Add('A MARGIN MEANS');
  AReport.Add('A LEVEL       MEAN       STD.DEV.');
  for i := 0 to NoALevels-1 do
    AReport.Add('%5d     %10.3f    %10.3f', [i+MinA, AMeans[i], ASDs[i]]);
  AReport.Add('');

  AReport.Add('B MARGIN MEANS');
  AReport.Add('B LEVEL       MEAN       STD.DEV.');
  for i := 0 to NoBLevels-1 do
    if BCount[i] > 0 then
      AReport.Add('%5d     %10.3f    %10.3f', [i+MinB, BMeans[i], BSDs[i]]);
  AReport.Add('');

  AReport.Add('C MARGIN MEANS');
  AReport.Add('C LEVEL       MEAN       STD.DEV.');
  for i := 0 to NoCLevels-1 do
    if CCount[i] > 0 then
      AReport.Add('%5d     %10.3f    %10.3f', [i+MinC, CMeans[i], CSDs[i]]);

  AReport.Add('');
  AReport.Add('AB MARGIN MEANS');
  AReport.Add('A LEVEL   B LEVEL       MEAN       STD.DEV.');
  for i := 0 to NoALevels-1 do
    for j := 0 to NoBLevels-1 do
      if ABCount[i,j] > 0 then
        AReport.Add('%5d     %5D     %10.3f    %10.3f', [i+MinA, j+MinB, ABMeans[i,j], ABSDs[i,j]]);
  AReport.Add('');

  AReport.Add('AC MARGIN MEANS');
  AReport.Add('A LEVEL   C LEVEL       MEAN       STD.DEV.');
  for i := 0 to NoALevels-1 do
    for j := 0 to NoCLevels-1 do
      if ACCount[i,j] > 0 then
        AReport.Add('%5d     %5D     %10.3f    %10.3f',[i+MinA, j+MinC, ACMeans[i,j], ACSDs[i,j]]);
  AReport.Add('');

  AReport.Add('GRAND MEAN = %10.3f', [TotMean]);
  AReport.Add('');
//  OutputFrm.ShowModal;
end;

procedure TABCNestedForm.GetResults;
VAR
  temp, temp2, temp3, temp4, constant : double;
  NoBLevelsInA, BLevCount, i, j, k, celln : integer;
begin
  celln := 0;
  for i := 0 to NoALevels-1 do
      begin
         for j := 0 to NoBLevels-1 do
             begin
               for k := 0 to NoCLevels-1 do
                   begin
                        if CellCount[j,i,k] > celln then celln := CellCount[j,i,k];
                   end;
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
                if CellCount[j,i,0] > 0 then NoBLevelsInA := NoBLevelsInA + 1;
             end;
         if NoBLevelsInA > BLevCount then BLevCount := NoBLevelsInA;
      end;
  dfA := NoALevels - 1;
  dfBwA := NoALevels * (BLevCount - 1);
  dfC := NoCLevels - 1;
  dfAC := (NoALevels-1) * (NoCLevels-1);
  dfBwAC := NoALevels * (BLevCount-1) * (NoCLevels -1);
  dfwcell := NoALevels * BLevCount * NoCLevels * (celln - 1);
  dftotal := TotN - 1;

  constant := SumSqrTot / TotN;
  SSTot := SSTot - constant;
  MSTot := SSTot / dftotal;

  // get A Effects
  SSA := 0.0;
  for i := 0 to NoALevels-1 do SSA := SSA + (ASumSqr[i] / ACount[i]);
  temp := SSA;
  SSA := SSA - constant;
  MSA := SSA / dfA;

  //Get C Effects
  SSC := 0.0;
  for i := 0 to NoCLevels-1 do SSC := SSC + (CSumSqr[i] / CCount[i]);
  temp2 := SSC;
  SSC := SSC - constant;
  MSC := SSC / dfC;

  // get B within A
  SSB := 0.0;
  for i := 0 to NoALevels - 1 do
      begin
         for j := 0 to NoBLevels-1 do
             begin
                if ABCount[i,j] > 0 then SSB := SSB + (ABSumSqr[i,j] / ABCount[i,j]);
             end;
      end;
  temp3 := SSB;
  SSB := SSB - temp;
  MSB := SSB / dfBwA;

  // get AC interaction
  SSAC := 0.0;
  for i := 0 to NoALevels-1 do
      begin
         for j := 0 to NoCLevels-1 do SSAC := SSAC + ACSumSqr[i,j] / ACCount[i,j]
      end;
  temp4 := SSAC;
  SSAC := SSAC - temp - temp2 + constant;
  MSAC := SSAC / dfAC;

  // get B within A x C interaction
  SSBwAC := 0.0;
  for i := 0 to NoALevels-1 do
      begin
         for j := 0 to NoBLevels-1 do
             begin
                for k := 0 to NoCLevels-1 do
                    begin
                       if CellCount[j,i,k] > 0 then SSBwAC := SSBwAC +
                         (SumSqr[j,i,k] / CellCount[j,i,k]);
                    end;
             end;
      end;
  SSBwAC := SSBwAC - temp3 - temp4 + temp;
  MSBwAC := SSBwAC / dfBwAC;

  SSW := SSTot - SSA - SSB - SSAB - SSAC - SSBwAC;
  MSW := SSW / dfwcell;
end;

procedure TABCNestedForm.ShowResults(AReport: TStrings);
VAR
  F, PF : double;
begin
  AReport.Add('');
  AReport.Add('ANOVA TABLE');
  AReport.Add('SOURCE     D.F.        SS        MS        F         PROB.');

  F := MSA / MSW;
  PF := probf(F,dfA,dfwcell);
  AReport.Add('A         %4D  %10.3f%10.3f%10.3f%10.3f', [dfA, SSA, MSA, F, PF]);

  F := MSB / MSW;
  PF := probf(F,dfBwA,dfwcell);
  AReport.Add('B(A)      %4D  %10.3f%10.3f%10.3f%10.3f', [dfBwA, SSB, MSB, F, PF]);

  F := MSC / MSW;
  PF := probf(F,dfC,dfwcell);
  AReport.Add('C         %4D  %10.3f%10.3f%10.3f%10.3f', [dfC, SSC, MSC, F, PF]);

  F := MSAC / MSW;
  PF := probf(F,dfAC,dfwcell);
  AReport.Add('AxC       %4D  %10.3f%10.3f%10.3f%10.3f', [dfAC, SSAC, MSAC, F, PF]);

  F := MSBwAC / MSW;
  PF := probf(F,dfBwAC,dfwcell);
  AReport.Add('B(A)xC    %4D  %10.3f%10.3f%10.3f%10.3f', [dfBwAC, SSBwAC, MSBwAC, F, PF]);

  AReport.Add('w.cells   %4D  %10.3f%10.3f', [dfwcell, SSW, MSW]);
  AReport.Add('Total     %4D  %10.3f', [dftotal, SSTot]);

  DisplayReport(AReport);
end;

procedure TABCNestedForm.ReleaseMemory;
begin
  ColNoSelected := nil;
  ABSDs := nil;
  ABCount := nil;
  ABMeans := nil;
  ABSumSqr := nil;
  ABSS := nil;
  ACSDs := nil;
  ACMeans := nil;
  ACCount := nil;
  ACSumSqr := nil;
  ACSS := nil;
  CSDs := nil;
  BSDs := nil;
  ASDs := nil;
  CCount := nil;
  BCount := nil;
  ACount := nil;
  CMeans := nil;
  BMeans := nil;
  AMeans := nil;
  CSumSqr := nil;
  BSumSqr := nil;
  ASumSqr := nil;
  CSS := nil;
  BSS := nil;
  ASS := nil;
  CellSDs := nil;
  CellMeans := nil;
  CellCount := nil;
  SumSqr := nil;
  SS := nil;
end;

procedure TABCNestedForm.TwoWayPlot;
VAR
  plottype, i, j, k : integer;
  maxmean, XBar : double;
  title, setstring : string;
  XValue : DblDyneVec;
begin
  case OptionsBox.ItemIndex of
    0: plottype := 9;
    1: plottype := 10;
    2: plottype := 1;
    3: plottype := 2;
  end;

  // Factor A first
  maxmean := -1000.0;
  SetLength(XValue,NoALevels);
  setstring := 'FACTOR A';
  GraphFrm.SetLabels[1] := setstring;
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
  title := FactorA + ' Group Codes';
  GraphFrm.XTitle := title;
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

  // Factor B next
  SetLength(XValue,NoBLevels);
  setstring := 'FACTOR B';
  GraphFrm.SetLabels[1] := setstring;
  maxmean := -1000.0;
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
  title := FactorB + ' Group Codes';
  GraphFrm.XTitle := title;
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

  // Factor C next
  SetLength(XValue,NoCLevels);
  setstring := 'FACTOR C';
  GraphFrm.SetLabels[1] := setstring;
  maxmean := -1000.0;
  SetLength(GraphFrm.Xpoints,1,NoCLevels);
  SetLength(GraphFrm.Ypoints,1,NoCLevels);
  for i := 0 to NoCLevels-1 do
      begin
        GraphFrm.Ypoints[0,i] := CMeans[i];
        if CMeans[i] > maxmean then maxmean := CMeans[i];
        XValue[i] := MinC + i - 1;
        GraphFrm.Xpoints[0,i] := XValue[i];
      end;
  GraphFrm.nosets := 1;
  GraphFrm.nbars := NoCLevels;
  GraphFrm.Heading := 'FACTOR C';
  title := FactorB + ' Group Codes';
  GraphFrm.XTitle := title;
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

  // Factor A x B interaction within each slice next
  SetLength(XValue,NoALevels + NoBLevels);
  SetLength(GraphFrm.Ypoints,NoALevels,NoBLevels);
  SetLength(GraphFrm.Xpoints,1,NoBLevels);
  for k := 0 to NoCLevels-1 do
      begin
        maxmean := -1000.0;
        for i := 0 to NoALevels-1 do
            begin
              setstring := 'FACTOR A ' + IntToStr(i+1);
              GraphFrm.SetLabels[i+1] := setstring;
              for j := 0 to NoBLevels-1 do
                  begin
                    if ABCount[i,j] > 0 then
                    begin
                      if ABMeans[i,j] > maxmean then maxmean := ABMeans[i,j];
                      GraphFrm.Ypoints[i,j] := ABMeans[i,j];
                    end;
                  end;
            end;
            for j := 0 to NoBLevels-1 do
            begin
                 XValue[j] := MinB + j - 1;
                 GraphFrm.Xpoints[0,j] := XValue[j];
            end;
            GraphFrm.nosets := NoALevels;
            GraphFrm.nbars := NoBLevels;
            GraphFrm.Heading := 'FACTOR A x Factor B within C' + IntToStr(k+1);
            title := FactorB + ' Group Codes';
            GraphFrm.XTitle := title;
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
      end;
      GraphFrm.Xpoints := nil;
      GraphFrm.Ypoints := nil;
      XValue := nil;

      //Factor A x C Interaction within each column next
      setLength(XValue,NoALevels+NoCLevels);
      SetLength(GraphFrm.Xpoints,1,NoCLevels);
      SetLength(GraphFrm.Ypoints,NoALevels,NoCLevels);
      for j := 0 to NoBLevels-1 do
      begin
        maxmean := 0.0;
        for i := 0 to NoALevels-1 do
        begin
             setstring := 'Factor A ' + IntToStr(i+1);
             GraphFrm.SetLabels[i+1] := setstring;
             for k := 0 to NoCLevels-1 do
             begin
               XBar := ACMeans[i,k];
               if XBar > maxmean then maxmean := XBar;
               GraphFrm.Ypoints[i,k] := XBar;
             end;
        end;
        for k := 0 to NoCLevels-1 do
        begin
          XValue[k] := MinC + k - 1;
          GraphFrm.Xpoints[0,k] := XValue[k];
        end;
        GraphFrm.nosets := NoALevels;
        GraphFrm.nbars := NoCLevels;
        GraphFrm.Heading := 'FACTOR A x Factor C within B ' + IntToStr(j+1);
        title := FactorC + ' Group Codes';
        GraphFrm.XTitle := title;
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
//        GraphFrm.ShowModal;
      end;
      GraphFrm.Xpoints := nil;
      GraphFrm.Ypoints := nil;
      XValue := nil;
  end;

procedure TABCNestedForm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TABCNestedForm.UpdateBtnStates;
begin
  AInBtn.Enabled := (VarList.ItemIndex > -1) and (FactorAEdit.Text = '');
  BInBtn.Enabled := (VarList.ItemIndex > -1) and (FactorBEdit.Text = '');
  CInBtn.Enabled := (VarList.ItemIndex > -1) and (FactorCEdit.Text = '');
  DepInBtn.Enabled := (VarList.ItemIndex > -1) and (DepEdit.Text = '');
  AOutBtn.Enabled := (FactorAEdit.Text <> '');
  BOutBtn.Enabled := (FactorBEdit.Text <> '');
  COutBtn.Enabled := (FactorCEdit.Text <> '');
  DepOutBtn.Enabled := (DepEdit.Text <> '');
end;

initialization
  {$I abcnestedunit.lrs}

end.

