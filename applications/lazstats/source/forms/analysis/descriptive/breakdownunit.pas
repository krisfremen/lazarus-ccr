// Use "twoway.laz" for testing

unit BreakDownUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, FunctionsLib, OutputUnit, DataProcs, ContextHelpUnit;

type

  { TBreakDownFrm }

  TBreakDownFrm = class(TForm)
    Bevel1: TBevel;
    ComputeBtn: TButton;
    HelpBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    Panel2: TPanel;
    SelVarInBtn: TBitBtn;
    SelVarOutBtn: TBitBtn;
    ResetBtn: TButton;
    CloseBtn: TButton;
    CheckGroup1: TCheckGroup;
    DepVar: TEdit;
    AvailLabel: TLabel;
    AnalLabel: TLabel;
    SelLabel: TLabel;
    SelList: TListBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure SelListSelectionChange(Sender: TObject; User: boolean);
    procedure SelVarInBtnClick(Sender: TObject);
    procedure SelVarOutBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: Boolean;
    Minimum, Maximum, levels, displace, subscript : IntDyneVec;
    Freq : IntDyneVec;
    Selected : IntDyneVec;
    mean, variance, Stddev, SS : DblDyneVec;
    index, NoSelected, ListSize, Dependentvar, X, length_array : integer;
    ptr1, ptr2, sum, grandsum : integer;
    xsumtotal, xsqrtotal, grandsumx, grandsumx2, value, SD : double;
    SST, SSW, SSB, MSW, MSB, F, FProb, DF1, DF2 : double;
    cellstring : string;
    outline : string;
    valstr : string;
    dataread : boolean;
    function Index_Pos(var X1: IntDyneVec; var displace1: IntDyneVec; ListSize1: integer): Integer;
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  BreakDownFrm: TBreakDownFrm;

implementation

uses
  Math;

{ TBreakDownFrm }

procedure TBreakDownFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;

begin
  VarList.Clear;
  SelList.Clear;
  DepVar.Text := '';
  InBtn.Enabled := true;
  OutBtn.Enabled := false;
  SelVarInBtn.Enabled := true;
  SelVarOutBtn.Enabled := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TBreakDownFrm.SelListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TBreakDownFrm.SelVarInBtnClick(Sender: TObject);
var
  index1 : integer;
begin
  index1 := VarList.ItemIndex;
  if (index1 > -1) and (DepVar.Text = '') then
  begin
    DepVar.Text := VarList.Items[index1];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TBreakDownFrm.SelVarOutBtnClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
    VarList.Items.Add(DepVar.Text);
  UpdateBtnStates;
end;

procedure TBreakDownFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TBreakDownFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TBreakDownFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  //Panel2.Constraints.MinWidth := SelLabel.Width * 2 + InBtn.Width + 2 * VarList.BorderSpacing.Right;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TBreakDownFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TBreakDownFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TBreakDownFrm.InBtnClick(Sender: TObject);
var
   i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if (VarList.Selected[i]) then
    begin
      SelList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TBreakDownFrm.ComputeBtnClick(Sender: TObject);
label
  Label1, Label3, Label4, NextStep, FirstOne, SecondOne, ThirdOne, LastStep;
var
  i, j: integer;
  tempval: string;
  lReport: TStrings;
begin
  // Identify columns of variables to analyze and the dependent var.
  NoSelected := SelList.Items.Count;

  if NoSelected = 0 then
  begin
     MessageDlg('No variables selected.', mtError, [mbOK], 0);
     exit;
  end;

  // Get column no. of dependent variable
  dependentVar := 0;
  cellstring := DepVar.Text;
  for i := 1 to NoVariables do
    if cellstring = OS3MainFrm.DataGrid.Cells[i,0] then dependentvar := i;

  if dependentVar = 0 then
  begin
     MessageDlg('Continuous variable is not specified.', mtError, [mbOK], 0);
     exit;
  end;

  // Allocate heap
  SetLength(Minimum,NoVariables);
  SetLength(Maximum,NoVariables);
  SetLength(levels,NoVariables);
  SetLength(displace,NoVariables);
  SetLength(subscript,NoVariables);
  SetLength(Selected,NoVariables);

  // Get selected variables
  for i := 1 to NoSelected do
  begin
    cellstring := SelList.Items.Strings[i-1];
    for j := 1 to NoVariables do
      if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then Selected[i-1] := j;
  end;
  Selected[NoSelected] := dependentvar;
  ListSize := NoSelected;

  // Get maximum and minimum levels in each variable
  for i := 1 to ListSize do
  begin
    index := Selected[i-1];
    Minimum[i-1] := round(StrToFloat(OS3MainFrm.DataGrid.Cells[index,1]));
    Maximum[i-1] := Minimum[i-1];
    for j := 1 to NoCases do
    begin
      if GoodRecord(j,NoSelected,Selected) then
      begin
        X := round(StrToFloat(OS3MainFrm.DataGrid.Cells[index,j]));
        if X < Minimum[i-1] then Minimum[i-1] := X;
        if X > Maximum[i-1] then Maximum[i-1] := X;
      end;
    end;
  end;

  // Calculate number of levels for each variable
  for i := 1 to  ListSize do
    levels[i-1] := Maximum[i-1] - Minimum[i-1] + 1;
  displace[ListSize-1] := 1;
  if ListSize > 1 then
    for i := ListSize-1 downto 1 do
      displace[i-1] := levels[i] * displace[i];

  // Now, tabulate
  length_array := 1;
  for i := 1 to ListSize do
    length_array := Length_array * levels[i-1];

  // initialize values
  SetLength(Freq, length_array+1);
  SetLength(mean, length_array+1);
  SetLength(variance, length_array+1);
  SetLength(Stddev, length_array+1);
  SetLength(SS, length_array+1);

  for i := 0 to length_array do
  begin
    Freq[i] := 0;
    mean[i] := 0.0;
    variance[i] := 0.0;
    Stddev[i] := 0.0;
    SS[i] := 0.0;
  end;

  // tabulate
  for i := 1 to NoCases do
  begin
    dataread := false;
    if GoodRecord(i,NoSelected,Selected) then
    begin
      for j := 1 to ListSize do
      begin
        index := Selected[j-1];
        X := round(StrToFLoat(OS3MainFrm.DataGrid.Cells[index,i]));
        X := X - Minimum[j-1] + 1;
        subscript[j-1] := X;
        dataread := true;
      end;
    end;
    if dataread then
    begin
      j := Index_Pos(subscript,displace,ListSize);
      Freq[j] := Freq[j] + 1;
      index := dependentvar;
      tempval := Trim(OS3MainFrm.DataGrid.Cells[index,i]);
      if tempval <> '' then
      begin
        value := StrToFloat(tempval);
        mean[j] := mean[j] + value;
        variance[j] := variance[j] + (value * value);
      end;
    end;
  end;

  // setup the output
  lReport := TStringList.Create;
  try
    lReport.Add('BREAKDOWN ANALYSIS PROGRAM');
    lReport.Add('');
    lReport.Add('VARIABLE SEQUENCE FOR THE BREAKDOWN:');
    for i := 1 to ListSize do
    begin
      index := Selected[i-1];
      lReport.Add('%-10s (Variable %3d) Lowest level = %2d Highest level = %2d', [
        OS3MainFrm.DataGrid.Cells[index,0],i, Minimum[i-1], Maximum[i-1]
      ]);
    end;

    // Breakdown the data
    ptr1 := ListSize - 1;
    ptr2 := ListSize;
    for i := 1 to ListSize do
      subscript[i-1] := 1;
    sum := 0;
    xsumtotal := 0.0;
    xsqrtotal := 0.0;
    grandsum := 0;
    grandsumx := 0.0;
    grandsumx2 := 0.0;

  Label1:
    index := Index_Pos(subscript, displace, ListSize);
    lReport.Add('Variable levels:');
    for i := 1 to ListSize do
    begin
      j := Selected[i-1];
      lReport.Add('%-10s level = %3d', [
        OS3MainFrm.DataGrid.Cells[j,0], Minimum[i-1] + subscript[i-1] - 1
      ]);
    end;
    lReport.Add('');

    sum := sum + Freq[index];
    xsumtotal := xsumtotal + mean[index];
    xsqrtotal := xsqrtotal + variance[index];

    lReport.Add('Freq.     Mean     Std. Dev.');
    outline := Format('%3d', [Freq[index]]);
    if Freq[index] > 0 then
    begin
      valstr := Format('     %8.3f ',[mean[index] / Freq[index]]);
      outline := outline + valstr;
    end
    else
      outline := outline +'    ********  ';

    if Freq[index] > 1 then
    begin
      SS[index] := variance[index];
      variance[index] := variance[index] - (mean[index] * mean[index] / Freq[index]);
      variance[index] := variance[index] / (Freq[index] - 1);
      Stddev[index] := sqrt(variance[index]);
      valstr := Format('%8.3f ', [Stddev[index]]);
      outline := outline + valstr;
    end else
      outline := outline + '********';

    lReport.Add(outline);
    lReport.Add('');

    subscript[ptr2-1] := subscript[ptr2-1] + 1;
    if subscript[ptr2-1] <= levels[ptr2-1] then goto Label1;
    lReport.Add('Number of observations across levels = %d',[sum]);
    if sum > 0 then
      lReport.Add('Mean across levels = %8.3f',[ xsumtotal / sum])
    else
      lReport.Add('Mean across levels = ********');

    if sum > 1 then
    begin
      SD := sqrt( (xsqrtotal - (xsumtotal * xsumtotal) / sum) / (sum - 1));
      lReport.Add('Std. Dev. across levels = %8.3f', [SD]);
    end else
      lReport.Add('Std. Dev. across levels = *******');

    lReport.Add('');
    lReport.Add('===============================================================');
    lReport.Add('');
    //OutputFrm.ShowModal;
    //OutputFrm.Clear;

    grandsum := grandsum + sum;
    grandsumx := grandsumx + xsumtotal;
    grandsumx2 := grandsumx2 + xsqrtotal;
    sum := 0;
    xsumtotal := 0.0;
    xsqrtotal := 0.0;
    if ptr1 < 1 then
      goto NextStep;

    subscript[ptr1-1] :=subscript[ptr1-1] + 1;
    if subscript[ptr1-1] <= levels[ptr1-1] then
      goto Label4;

  Label3:
    ptr1 := ptr1 - 1;
    if ptr1 < 1 then
      goto NextStep;
    if subscript[ptr1-1] > levels[ptr1-1] then
      goto Label3;

    subscript[ptr1-1] := subscript[ptr1-1] + 1;
    if subscript[ptr1-1] > levels[ptr1-1] then
      goto Label3;

  Label4:
    for i := ptr1+1 to ListSize do subscript[i-1] := 1;
    ptr1 := ListSize - 1;
    if ptr1 < 1 then goto
      NextStep;
    goto Label1;

  NextStep:
    lReport.Add('Grand number of observations across all categories = %3d', [grandsum]);
    if grandsum > 0 then
      lReport.Add('Overall Mean = %8.3f', [grandsumx / grandsum]);
    if grandsum > 1 then
    begin
      SD := sqrt((grandsumx2 - (grandsumx * grandsumx) / grandsum) / (grandsum - 1));
      lReport.Add('Overall standard deviation = %8.3f', [SD]);
    end;

    lReport.Add('');
    lReport.Add('===============================================================');
    lReport.Add('');
    //OutputFrm.ShowModal;
    //OutputFrm.Clear;

    // Do ANOVA's if requested
    if CheckGroup1.CheckEnabled[0] then
    begin
      lReport.Add('ANALYSES OF VARIANCE SUMMARY TABLES');
      lReport.Add('');
      ptr1 := ListSize - 1;
      ptr2 := ListSize;
      for i := 1 to ListSize do subscript[i-1] := 1;
      SSB := 0.0;
      SSW := 0.0;
      MSB := 0.0;
      MSW := 0.0;
      grandsum := 0;
      grandsumx := 0.0;
      grandsumx2 := 0.0;
      DF1 := 0.0;
      DF2 := 0.0;

    FirstOne:
      index := Index_Pos(subscript, displace, ListSize);
      if Freq[index] > 0 then
      begin
        lReport.Add('Variable levels: ');
        for i := 1 to  ListSize do
        begin
          j := Selected[i-1];
          lReport.Add('%-10s level = %3d', [
            OS3MainFrm.DataGrid.Cells[j,0], Minimum[i-1] + subscript[i-1] - 1
          ]);
        end;
        lReport.Add('');

        // build sumsof squares for this set
        DF1  := DF1 + 1;
        DF2  := DF2 + Freq[index] - 1;
        grandsum := grandsum + Freq[index];
        grandsumx := grandsumx + mean[index];
        grandsumx2 := grandsumx2 + SS[index];
        SSW := SSW + SS[index] - (mean[index] * mean[index] / Freq[index]);
      end;
      subscript[ptr2-1] := subscript[ptr2-1] + 1;
      if subscript[ptr2-1] <= levels[ptr2-1] then
        goto FirstOne;

      if ((grandsum > 0.0) and (DF1 > 1) and (DF2 > 1) and (SSW > 0.0)) then
      begin
        // build and show anova table
        SST := grandsumx2 - (grandsumx * grandsumx / grandsum);
        SSB := SST - SSW;
        DF1 := DF1 - 1.0; // no. of groups - 1
        MSB := SSB / DF1;
        MSW := SSW / DF2;
        F := MSB / MSW;
        FProb := probf(DF1,DF2,F);
        lReport.Add('SOURCE    D.F.        SS        MS        F       Prob.>F');
        lReport.Add('GROUPS    %2.0f        %8.2f  %8.2f  %8.3f  %6.4f', [DF1,SSB,MSB,F,FProb]);
        lReport.Add('WITHIN    %2.0f        %8.2f  %8.2f', [DF2,SSW,MSW]);
        lReport.Add('TOTAL     %2d        %8.2f', [grandsum-1,SST]);
        //OutputFrm.ShowModal;
        //OutputFrm.Clear;
      end else
      begin
        lReport.Add('Insufficient data for ANOVA');
        //OutputFrm.ShowModal;
        //OutputFrm.Clear;
      end;
      lReport.Add('');
      lReport.Add('=============================================================');
      lReport.Add('');

      SSB := 0.0;
      SSW := 0.0;
      MSB := 0.0;
      MSW := 0.0;
      grandsum := 0;
      grandsumx := 0.0;
      grandsumx2 := 0.0;
      DF1 := 0.0;
      DF2 := 0.0;
      if ptr1 < 1 then
        goto LastStep;

      subscript[ptr1-1] := subscript[ptr1-1] + 1;
      if subscript[ptr1-1] <= levels[ptr1-1] then
        goto ThirdOne;

  SecondOne:
      ptr1 := ptr1 - 1;
      if ptr1 < 1 then goto LastStep;
      if subscript[ptr1-1] > levels[ptr1-1] then
        goto SecondOne;

      subscript[ptr1-1] := subscript[ptr1-1] + 1;
      if subscript[ptr1-1] > levels[ptr1-1] then
        goto SecondOne;

  ThirdOne:
      for i := ptr1+1 to ListSize do subscript[i-1] := 1;
      ptr1 := ListSize - 1;
      if ptr1 < 1 then
        goto LastStep;

      goto FirstOne;

  LastStep:
      // do anova for all cells
      lReport.Add('ANOVA FOR ALL CELLS');
      lReport.Add('');
      SST := 0.0;
      SSW := 0.0;
      DF2 := 0.0;
      DF1 := 0.0;
      grandsumx := 0.0;
      grandsum := 0;
      for i := 1 to length_array do
      begin
        if Freq[i] > 0 then
        begin
          SST  := SST + SS[i];
          grandsum := grandsum + Freq[i];
          grandsumx := grandsumx + mean[i];
          SSW := SSW + (SS[i] - (mean[i] * mean[i] / Freq[i]));
          DF1 := DF1 + 1.0;
          DF2 := DF2 + (Freq[i] - 1);
        end;
      end;

      if ( (DF1 > 1.0) and (DF2 > 1.0) and (SSW > 0.0)) then
      begin
        SST := SST - (grandsumx * grandsumx / grandsum);
        SSB := SST - SSW;
        DF1 := DF1 - 1;
        MSB := SSB / DF1;
        MSW := SSW / DF2;
        F := MSB / MSW;
        FProb := probf(DF1, DF2, F);
        lReport.Add('SOURCE    D.F.        SS        MS        F       Prob.>F');
        lReport.Add('GROUPS    %2.0f        %8.2f  %8.2f  %8.3f  %6.4f', [DF1, SSB, MSB, F, FProb]);
        lReport.Add('WITHIN    %2.0f        %8.2f  %8.2f', [DF2, SSW, MSW]);
        lReport.Add('TOTAL     %2d        %8.2f', [grandsum-1, SST]);
        lReport.Add('FINISHED');
      end else
      begin
        lReport.Add('Only 1 group.  No ANOVA possible.');
      end;
    end;

    // Show report in output form
    DisplayReport(lReport);

  finally
    lReport.Free;

    SS := nil;
    Stddev := nil;
    variance := nil;
    mean := nil;
    Freq := nil;
    selected := nil;
    subscript := nil;
    displace := nil;
    levels := nil;
    Maximum := nil;
    Minimum := nil;
  end;
end;

procedure TBreakDownFrm.OutBtnClick(Sender: TObject);
var
   i: integer;
begin
  i := 0;
  while i < SelList.Items.Count do
  begin
    if (SelList.Selected[i]) then
    begin
      VarList.Items.Add(SelList.Items[i]);
      SelList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

function TBreakDownFrm.Index_Pos(var X1: IntDyneVec; var displace1: IntDyneVec;
  ListSize1: integer): integer;
var
  i: integer;
begin
  Result := X1[ListSize-1];
  for i := 1 to ListSize - 1 do
    Result := Result + ((X1[i-1] - 1) * displace[i-1]);
end;

procedure TBreakDownFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  lSelected := false;
  for i := 0 to VarList.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to SelList.Count-1 do
    if SelList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;

  SelVarInBtn.Enabled := (VarList.ItemIndex > -1) and (DepVar.Text = '');
  SelVarOutBtn.Enabled := (DepVar.Text <> '');
end;

initialization
  {$I breakdownunit.lrs}

end.

