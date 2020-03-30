unit GuttmanUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, Globals, DataProcs;

type

  { TGuttmanFrm }

  TGuttmanFrm = class(TForm)
    Bevel1: TBevel;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ItemList: TListBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
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
  public
    { public declarations }
  end; 

var
  GuttmanFrm: TGuttmanFrm;

implementation

uses
  Math;

{ TGuttmanFrm }

procedure TGuttmanFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  ItemList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TGuttmanFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TGuttmanFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width + w;  // make form a bit wider...
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TGuttmanFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TGuttmanFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TGuttmanFrm.AllBtnClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to VarList.Items.Count - 1 do
    ItemList.Items.Add(VarList.Items[i-1]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TGuttmanFrm.ComputeBtnClick(Sender: TObject);
var
    i, j, k, col, X, e0, e1, e2, e3, first, last, errors : integer;
    totalerrors, rowno : integer;
    FreqMat0 : IntDyneMat; // Pointer to array of 0 responses for each item by score group
    FreqMat1 : IntDyneMat; // Pointer to array of 1 responses for each item by score group
    RowTots : IntDyneVec; // Pointer to vector of total score frequencies for items
    ColTots : IntDyneMat; // Pointer to array of 0 and 1 column totals
    ColProps : DblDyneVec; // Pointer to array of proportions correct in columns
    ColNoSelected : IntDyneVec; // Pointer to vector of item Grid columns
    CaseVector : IntDyneVec; // Pointer to vector of subject's item responses
    TotalScore : integer; // Total score of a subject
    temp : integer; // temporary variable used in sorting
    CutScore : IntDyneVec; // Optimal cut scores for each item
    ErrorMat : IntDyneMat; // matrix of errors above and below cut scores
    sequence : IntDyneVec; // original and sorted sequence no. of items
    CaseNo : IntDyneVec; // ID number for each case
    ModalArray : IntDyneMat; // Array of modal item responses
    NoSelected : integer;
    VarLabels : StrDyneVec; // variable labels
    outline, astring : string;
    done : boolean;
    CoefRepro : double;
    Min_Coeff : double;
    lReport: TStrings;
begin
  if ItemList.Count = 0 then
  begin
    MessageDlg('No variable(s) selected.', mtError, [mbOK], 0);
    exit;
  end;

   // allocate heap space for arrays
   SetLength(ColNoSelected,NoVariables);
   SetLength(FreqMat0,NoCases,NoVariables);
   SetLength(FreqMat1,NoCases,NoVariables);
   SetLength(RowTots,NoCases);
   SetLength(ColTots,NoVariables,2);
   SetLength(ColProps,NoVariables);
   SetLength(CaseVector,NoCases);
   SetLength(CutScore,NoCases);
   SetLength(ErrorMat,NoVariables,2);
   SetLength(sequence,NoVariables);
   SetLength(CaseNo,NoCases);
   SetLength(ModalArray,NoVariables+1,NoVariables+1);
   SetLength(VarLabels,NoVariables);

   // get variables used for the analysis
   NoSelected := ItemList.Items.Count;
   for i := 1 to NoVariables do
   begin
        for j := 1 to NoSelected do
        begin
             if OS3MainFrm.DataGrid.Cells[i,0] = ItemList.Items.Strings[j-1] then
             begin
                  ColNoSelected[j-1] := i;
                  VarLabels[j-1] := OS3MainFrm.DataGrid.Cells[i,0];
             end;
        end;
   end;

  // Initialize sequence
  for i := 1 to NoSelected do  sequence[i-1] := i;

  // Initialize arrays
  for i := 0 to NoSelected-1 do
  begin
      ColTots[i,0] := 0;
      ColTots[i,1] := 0;
      ColProps[i] := 0.0;
      ErrorMat[i,0] := 0;
      ErrorMat[i,1] := 0;
  end;
  for i := 0 to NoCases-1 do
  begin
      RowTots[i] := 0;
      CutScore[i] := 0;
      CaseNo[i] := i+1;
      for j := 0 to NoSelected-1 do
      begin
          FreqMat0[i,j] := 0;
          FreqMat1[i,j] := 0;
      end;
  end;
  if (NoCases > NoSelected) then
  begin
      for i := 1 to NoCases do CaseVector[i-1] := 0;
  end
  else begin
      for i := 1 to NoSelected do CaseVector[i-1] := 0;
  end;

  // Get data into the frequency matrices of 0 and 1 responses
  for i := 1 to NoCases do
  begin
      if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
      TotalScore := 0;
      for j := 1 to NoSelected do
      begin
          col := ColNoSelected[j-1];
          X := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i])));
          CaseVector[j-1] := X;
          TotalScore := TotalScore + X;
      end;
      for j := 1 to NoSelected do
      begin
          if (CaseVector[j-1] = 0) then  FreqMat0[i-1,j-1] := 1
          else FreqMat1[i-1,j-1] := 1;
      end;
  end;

  // Get Row Totals for each score group (rows of FreqMat1)
  for i := 1 to NoCases do
  begin
      if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
      for j := 1 to NoSelected do
      begin
         RowTots[i-1] := RowTots[i-1] + FreqMat1[i-1,j-1];
      end;
  end;

  // Get Column Totals for item scores of 1 and 0
  for i := 1 to NoSelected do //columns
  begin
      for j := 1 to NoCases do // rows
      begin
          if (not GoodRecord(j,NoSelected,ColNoSelected)) then continue;
          ColTots[i-1,0] := ColTots[i-1,0] + FreqMat0[j-1,i-1];
          ColTots[i-1,1] := ColTots[i-1,1] + FreqMat1[j-1,i-1];
      end;
  end;

  //Sort frequency matrices into descending order
  for i := 1 to NoCases - 1 do
  begin
      if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
      for j := i + 1 to NoCases do
      begin
          if (not GoodRecord(j,NoSelected,ColNoSelected)) then continue;
          if (RowTots[i-1] < RowTots[j-1]) then //swap
          begin
              for k := 1 to NoSelected do
              begin // carry all columns in the swap
                  temp := FreqMat0[i-1,k-1];
                  FreqMat0[i-1,k-1] := FreqMat0[j-1,k-1];
                  FreqMat0[j-1,k-1] := temp;
                  temp := FreqMat1[i-1,k-1];
                  FreqMat1[i-1,k-1] := FreqMat1[j-1,k-1];
                  FreqMat1[j-1,k-1] := temp;
              end;
              // Also swap row totals
              temp := RowTots[i-1];
              RowTots[i-1] := RowTots[j-1];
              RowTots[j-1] := temp;
              // And case number
              temp := CaseNo[i-1];
              CaseNo[i-1] := CaseNo[j-1];
              CaseNo[j-1] := temp;
          end; // end if
      end; // Next j
  end; // next i

  // Now sort the columns into ascending order of number right
  for i := 1 to NoSelected - 1 do
  begin
      for j := i + 1 to NoSelected do
      begin
          if (ColTots[i-1,1] > ColTots[j-1,1]) then //swap
          begin
              for k := 1 to NoCases do
              begin
                  if (not GoodRecord(k,NoSelected,ColNoSelected)) then continue;
                  temp := FreqMat0[k-1,i-1];
                  FreqMat0[k-1,i-1] := FreqMat0[k-1,j-1];
                  FreqMat0[k-1,j-1] := temp;
                  temp := FreqMat1[k-1,i-1];
                  FreqMat1[k-1,i-1] := FreqMat1[k-1,j-1];
                  FreqMat1[k-1,j-1] := temp;
              end; // next k
              // swap column totals also
              temp := ColTots[i-1,0];
              ColTots[i-1,0] := ColTots[j-1,0];
              ColTots[j-1,0] := temp;
              temp := ColTots[i-1,1];
              ColTots[i-1,1] := ColTots[j-1,1];
              ColTots[j-1,1] := temp;
              // swap label pointers
              temp := sequence[i-1];
              sequence[i-1] := sequence[j-1];
              sequence[j-1] := temp;
          end; // end if
      end; // next j
  end; // next i

  //For each item (column), find the optimal cutting value
  for i := 1 to NoSelected do
  begin
      CutScore[i-1] := 0;
      for j := 1 to NoCases do // j is the trial cut point
      begin
          if (not GoodRecord(j,NoSelected,ColNoSelected)) then continue;
          e0 := 0;
          e1 := 0;
          //Get errors prior to the cut point
          for k := 1 to j do
          begin
              if (not GoodRecord(k,NoSelected,ColNoSelected)) then continue;
              if (FreqMat0[k-1,i-1] = 1) then e0 := e0 + 1;
          end;
          //Get errors following the cut point
          for k := j + 1 to NoCases do
          begin
              if (not GoodRecord(k,NoSelected,ColNoSelected)) then continue;
              if (FreqMat1[k-1,i-1] = 1) then e1 := e1 + 1;
          end;
          //Save errors for each cut
          CaseVector[j-1] := e0 + e1;
      end; // next j
      // Save minimum cut score index
      e2 := 32000;
      e3 := 0;
      for j := 1 to NoCases do
      begin
          if (not GoodRecord(j,NoSelected,ColNoSelected)) then continue;
          if (CaseVector[j-1] < e2) then
          begin
              e2 := CaseVector[j-1];
              e3 := j;
          end;
      end;
      CutScore[i-1] := e3; //Position of optimal cut for item i
  end;

  // Get error counts;
  for i := 1 to NoSelected do
  begin
      for j := 1 to CutScore[i-1] do
      begin
          if (not GoodRecord(j,NoSelected,ColNoSelected)) then continue;
          if ((FreqMat0[j-1,i-1] > 0) or (FreqMat1[j-1,i-1] > 0)) then
              ErrorMat[i-1,0] := ErrorMat[i-1,0] + FreqMat0[j-1,i-1];
      end;
      for j := CutScore[i-1] + 1 to NoCases do
      begin
          if (not GoodRecord(j,NoSelected,ColNoSelected)) then continue;
          if ((FreqMat0[j-1,i-1] > 0) or (FreqMat1[j-1,i-1] > 0)) then
              ErrorMat[i-1,1] := ErrorMat[i-1,1] + FreqMat1[j-1,i-1];
      end;
  end;

  // Print results
  lReport := TStringList.Create;
  try
    lReport.Add('                  GUTTMAN SCALOGRAM ANALYSIS');
    lReport.Add('                        Cornell Method');
    lReport.Add('');
    lReport.Add('No. of Cases: %5d', [NoCases]);
    lReport.Add('No. of items: %5d', [NoSelected]);
    lReport.Add('');
    lReport.Add('RESPONSE MATRIX');
    lReport.Add('');
    first := 1;
    last := first + 5; // column (item) index
    if (last > NoSelected) then last := NoSelected;
    done := false;

    while (not done) do  //loop through all of the score groups
    begin
      lReport.Add('Subject Row                    Item Number');
      outline := 'Label Sum';
      for i := first to last do
          outline := outline + Format('%10s', [VarLabels[sequence[i-1]-1]]);
      lReport.Add(outline);

      outline := '           ';
      for i := first to last do
        outline := outline + '   0    1 ';
      lReport.Add(outline);
      lReport.Add('');
      for i := 1 to NoCases do // rows
      begin
        if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        outline := Format(' %3d  %3d  ', [CaseNo[i-1], RowTots[i-1]]);
        for j := first to last do
          outline := outline + Format(' %3d  %3d ', [FreqMat0[i-1,j-1], FreqMat1[i-1,j-1]]);
        lReport.Add(outline);

        // check for optimal cut point for this score
        outline := '           ';
        for j := first to last do
          if (CutScore[j-1] = i) then
            outline := outline + '   -cut-  '
          else
            outline := outline + '          ';
        lReport.Add(outline);
      end; // Next row (score group)
      lReport.Add('');

      outline := 'TOTALS     ';
      for j := first to last do
        outline := outline + Format(' %3d  %3d ', [ColTots[j-1,0], ColTots[j-1,1]]);
      lReport.Add(outline);

      outline := 'ERRORS     ';
      for j := first to last do
        outline := outline + Format(' %3d  %3d ', [ErrorMat[j-1,0], ErrorMat[j-1,1]]);
      lReport.Add(outline);
      if (last < NoSelected) then
      begin
          first := last + 1;
          last := first + 5; // column (item) index
          if (last > NoSelected) then last := NoSelected;
      end
      else done := true;
      lReport.Add('');
    end;

    lReport.Add('');
    CoefRepro := 0.0;
    for j := 1 to NoSelected do
        CoefRepro := CoefRepro + ErrorMat[j-1,0] + ErrorMat[j-1,1];
    CoefRepro := 1.0 - (CoefRepro / (NoCases * NoSelected));
    lReport.Add('Coefficient of Reproducibility := %6.3f',[CoefRepro]);
    lReport.Add('');


    //-----------------------------GOODENOUGH----------------------------------
    // Complete Goodenough method and print results
    lReport.Add('');
    lReport.Add('                  GUTTMAN SCALOGRAM ANALYSIS');
    lReport.Add('          Goodenough Modification Using Modal Responses');
    lReport.Add('');
    totalerrors := 0;
    Min_Coeff := 0.0;
    for i := 1 to NoSelected + 1 do
      for j := 1 to NoSelected do ModalArray[i-1,j-1] := 0;
    for i := 1 to NoSelected do // column
    begin
      ColProps[i-1] := ColTots[i-1,1] / NoCases;
      ErrorMat[i-1,0] := 0;
      ErrorMat[i-1,1] := 0;
    end;
    // Get the cut scores for each score row based on rounded proportions
    for i := 1 to NoSelected do
    begin
      CutScore[i-1] := Trunc(ColProps[i-1] * (NoSelected+1));
    end;

    // Build modal response array for the total scores by items
    lReport.Add('');
    lReport.Add('       MODAL ITEM RESPONSES');
    lReport.Add('');
    lReport.Add('TOTAL                 ITEMS');
    outline := '     ';
    for i := 1 to NoSelected do
    begin
      astring := format('%10s',[VarLabels[sequence[i-1]-1]]);
      outline := outline + astring;
    end;
    lReport.Add(outline);
    for i := 0 to NoSelected do
    begin
      for j := 1 to NoSelected do
        if (CutScore[j-1] > i) then
          ModalArray[i,j-1] := 1
        else
          ModalArray[i,j-1] := 0;
      astring := format(' %3d ',[NoSelected - i]);
      outline := astring;
      for j := 1 to NoSelected do
      begin
          astring := format('    %3d   ',[ModalArray[i,j-1]]);
          outline := outline + astring;
      end;
      lReport.Add(outline);
    end;

    lReport.Add('');
    lReport.Add('No. of Cases := %3d.  No. of items := %3d',[NoCases,NoSelected]);
    lReport.Add('');
    lReport.Add('RESPONSE MATRIX');
    first := 1;
    last := first + 5; // column (item) index
    if (last > NoSelected) then last := NoSelected;

    done := false;
    while (not done) do  //loop through all of the score groups
    begin
      lReport.Add('Subject Row Error                    Item Number');
      outline := 'Label  Sum Count';
      for i := first to last do
        outline := outline + Format('%10s', [VarLabels[sequence[i-1]-1]]);
      lReport.Add(outline);
      outline := '                 ';
      for i := first to last do
        outline := outline + '   0    1 ';
      lReport.Add(outline);
      lReport.Add('');
      for i := 1 to NoCases do // rows
      begin
          if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
          errors := 0;
          for j := first to last do
          begin
              rowno := NoSelected - RowTots[i-1] + 1;
              if (FreqMat1[i-1,j-1] <> ModalArray[rowno-1,j-1]) then  errors := errors + 1;
          end;

          outline := format(' %3d  %3d  %3d   ',[CaseNo[i-1],RowTots[i-1],errors]);
          for j := first to last do
          begin
              astring := format(' %3d  %3d ',[FreqMat0[i-1,j-1],FreqMat1[i-1,j-1]]);
              outline := outline + astring;
          end;
          lReport.Add(outline);
          totalerrors := totalerrors + errors;
      end; // Next row (score group)
      lReport.Add('');

      outline :='TOTALS           ';
      for j := first to last do
        outline := outline + Format(' %3d  %3d ',[ColTots[j-1,0], ColTots[j-1,1]]);
      lReport.Add(outline);

      outline := 'PROPORTIONS      ';
      for j := first to last do
        outline := outline + Format('%4.2f %4.2f ',[(1.0-ColProps[j-1]), ColProps[j-1]]);
      lReport.Add(outline);

      if (last < NoSelected) then
      begin
        first := last + 1;
        last := first + 5; // column (item) index
        if (last > NoSelected) then last := NoSelected;
      end
      else
        done := true;
      lReport.Add('');
    end;
    lReport.Add('');
    CoefRepro := 1.0 - (totalerrors / (NoCases * NoSelected));
    lReport.Add('Coefficient of Reproducibility := %6.3f', [CoefRepro]);

    for j := 1 to NoSelected do
      if (ColProps[j-1] > (1.0 - ColProps[j-1])) then
        Min_Coeff := Min_Coeff + ColProps[j-1]
      else
        Min_Coeff := Min_Coeff + (1.0 - ColProps[j-1]);
    Min_Coeff := Min_coeff / NoSelected;

    lReport.Add('Minimal Marginal Reproducibility := %6.3f', [Min_Coeff]);

    DisplayReport(lReport);
  finally
    lReport.Free;

    // Clean up the heap
    VarLabels := nil;
    ModalArray := nil;
    CaseNo := nil;
    sequence := nil;
    ErrorMat := nil;
    CutScore := nil;
    CaseVector := nil;
    ColProps := nil;
    ColTots := nil;
    RowTots := nil;
    FreqMat1 := nil;
    FreqMat0 := nil;
    ColNoSelected := nil;
  end;
end;

procedure TGuttmanFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      ItemList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end
    else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TGuttmanFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < ItemList.Items.Count do
  begin
    if ItemList.Selected[i] then
    begin
      VarList.Items.Add(ItemList.Items[i]);
      ItemList.Items.Delete(i);
      i := 0;
    end
    else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TGuttmanFrm.UpdateBtnStates;
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
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to ItemList.Items.Count-1 do
    if ItemList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;

  AllBtn.Enabled := VarList.Items.Count > 0;
end;

initialization
  {$I guttmanunit.lrs}

end.

