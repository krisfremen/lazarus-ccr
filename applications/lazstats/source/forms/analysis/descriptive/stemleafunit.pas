unit StemLeafUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Math, Clipbrd,
  MainUnit, Globals, OutputUnit, DataProcs, ContextHelpUnit;

type

  { TStemLeafFrm }

  TStemLeafFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    TestChk: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    VarList: TListBox;
    SelectList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
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
  StemLeafFrm: TStemLeafFrm;

implementation

{ TStemLeafFrm }

procedure TStemLeafFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  SelectList.Clear;
  UpdateBtnStates;
end;

procedure TStemLeafFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TStemLeafFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TStemLeafFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TStemLeafFrm.AllBtnClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to VarList.Items.Count-1 do
    SelectList.Items.Add(VarList.Items[i]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TStemLeafFrm.ComputeBtnClick(Sender: TObject);
var
  i, j, k, L, ncases, noselected, largest, smallest: integer;
  minsize, maxsize, stem, minstem, maxstem, bin, index: integer;
  leafvalue, counter, smallcount, testvalue, largestcount: integer;
  cellstring, outline, astring: string;
  selected: IntDyneVec;
  bins: IntDyneVec;
  frequency: IntDyneVec;
  ValueString: StrDyneVec;
  values: DblDyneVec;
  leafcount: IntDyneMat;
  min, max, temp, X, stemsize: double;
  lReport: TStrings;
begin
  noselected := SelectList.Items.Count;
  if (noselected = 0) then
  begin
     MessageDlg('No variables were selected.', mtError, [mbOK], 0);
     exit;
  end;

  SetLength(selected,noselected);
  SetLength(values,NoCases);
  SetLength(bins,100);
  SetLength(frequency,100);
  SetLength(ValueString,NoCases);
  SetLength(leafcount,100,10);

  // Get selected variables
  for i := 1 to noselected do
  begin
    cellstring := SelectList.Items.Strings[i-1];
    for j := 1 to NoVariables do
      if (cellstring = OS3MainFrm.DataGrid.Cells[j,0]) then selected[i-1] := j;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('STEM AND LEAF PLOTS');
    lReport.Add('');

    // Analyze each variable selected
    for j := 0 to noselected - 1 do
    begin
      k := selected[j];
      lReport.Add('Stem and Leaf Plot for variable: %s', [OS3MainFrm.DataGrid.Cells[k,0]]);
      ncases := 0;
      min := 1.0e308;
      max := -1.0e308;
      minsize := 1000;
      maxsize := -1000;

      // Store values of the variable
      for i := 1 to NoCases do
      begin
        if not ValidValue(i,k) then continue;
        values[ncases] := StrToFloat(OS3MainFrm.DataGrid.Cells[k,i]);
        ValueString[ncases] := Trim(OS3MainFrm.DataGrid.Cells[k,i]);
        if (values[ncases] < min) then min := values[ncases];
        if (values[ncases] > max) then max := values[ncases];
        if Length(ValueString[ncases]) > maxsize then maxsize := Length(ValueString[ncases]);
        if Length(ValueString[ncases]) < minsize then minsize := Length(ValueString[ncases]);
        ncases := ncases + 1;
      end;

      largest := ceil(max);
      smallest := ceil(min);
      stemsize := 1.0;
      if ((largest > 0) and (largest > 10)) then
      begin
        while (largest > 10)do
        begin
          largest := largest div 10;
          stemsize := stemsize * 10.0;
        end;
      end else
      if ((largest < 0) and (smallest < -10)) then  // largest value is less than 0.0
      begin
        while (smallest < -10)do
        begin
          smallest := smallest * 10;
          stemsize := stemsize / 10.0;
        end;
      end;

      // rescale values by stemsize
      for i := 0 to ncases - 1 do
        values[i] := values[i] / stemsize;

      // multiply values by 10, round and save value divided by 10
      for i := 0 to ncases - 1 do
      begin
        temp := floor(values[i] * 10);
        temp := temp / 10.0;
        values[i] := temp;
        astring := format('%4.1f',[values[i]]);
        ValueString[i] := astring;
      end;

      // get max and min stem values for creating bins for stem values
      minstem := 999;
      maxstem := -999;
      for i := 0 to ncases - 1 do
      begin
        stem := floor(values[i]);
        if (stem < minstem) then minstem := stem;
        if (stem > maxstem) then maxstem := stem;
      end;

      // create arrays for stem and leaf plot
      for i := 0 to 19 do
        frequency[i] := 0;

      // sort values into ascending order
      for i := 0 to ncases-2 do
      begin
        for k := i+1 to ncases - 1 do
        begin
          if (values[i] > values[k]) then // swap values
          begin
            X := values[i];
            values[i] := values[k];
            values[k] := X;
            cellstring := ValueString[i];
            ValueString[i] := ValueString[k];
            ValueString[k] := cellstring;
          end;
        end;
      end;
(*
         // check sizes - delete if ok
         outline := format('maxsize, minsize,stemsize: %10d %10d %10.2f',[maxsize, minsize, stemsize]);
         OutputFrm.RichEdit.Lines.Add(outline);
         OutputFrm.ShowModal;
         OutputFrm.RichEdit.Clear;
*)
      if TestChk.Checked then
      begin   // test output
        lReport.Add('value     ValueString');
        for i := 0 to ncases - 1 do
          lReport.Add('%10.1f %s',[values[i],ValueString[i]]);
      end;

      lReport.Add('');
      lReport.Add('Frequency  Stem & Leaf');

      // initialize leaf count for the bins
      for i := 0 to 99 do // bins
        for k := 0 to 9 do leafcount[i,k] := 0;  // leafs 0 to 9

      // count leafs in each bin
      for i := 0 to ncases - 1 do
      begin
        bin := floor(values[i]); // truncate to get stem value
        bin := bin - minstem; // get the bin number between 0 and 100
        if (bin < 100) and (bin >= 0) then
        begin
          bins[bin] := floor(values[i]);
          frequency[bin] := frequency[bin] + 1; // count number of stem values
        end else
        begin
          MessageDlg('Error in bin value', mtError, [mbOK], 0);
          exit;
        end;

        // get leaf value
        astring := ValueString[i];
        index := Pos('.',astring);
        leafvalue := StrToInt(astring[index+1]);
        if (leafvalue < 10) and (leafvalue >= 0) then
           leafcount[bin,leafvalue] := leafcount[bin,leafvalue] + 1
        else
        begin
          MessageDlg('Error in leafvalue', mtError, [mbOK], 0);
          exit;
        end;
      end;

      // get max leaf counters
      largestcount := 0;
      for i := 0 to 99 do // bin
      begin
        if frequency[i] = 0 then continue; // skip empty bins
        counter := 0;
        for k := 0 to 9 do // leaf counts
          counter := counter + leafcount[i,k];
        if counter > largestcount then
          largestcount := counter;
      end;

      // determine leaf depth needed to get counter <= 50
      if (largestcount > 50) then
      begin
        smallcount := 2;
        testvalue := largestcount;
        while (testvalue > 50) do
        begin
          testvalue := largestcount div smallcount;
          smallcount := smallcount + 1;
        end;
        smallcount := smallcount - 1; // leaf depth needed to reduce line lengths to 50 or less
      end else
        smallcount := 1;

      // rescale leafs
      for i := 0 to 99 do // bin
        for k := 0 to 9 do // leaf
          leafcount[i,k] := leafcount[i,k] div smallcount;

      // plot results
      for i := 0 to 99 do
      begin
        if frequency[i] = 0 then continue; // skip empty bins
        outline := format('%6d     %3d    ',[frequency[i], bins[i]]);
        for k := 0 to 9 do
        begin
          if leafcount[i,k] = 0 then continue;
          for L := 1 to leafcount[i,k] do
            outline := outline + Format('%d',[k]);
        end;
        lReport.Add(outline);
      end;

      // summarize values
      lReport.Add('');
      lReport.Add('Stem Width:        %8.3f', [stemSize]);
      lReport.Add('Max. Leaf Depth:   %8d', [smallcount]);
      lReport.Add('Min. Value:        %8.3f', [min]);
      lReport.Add('Max. Value:        %8.3f', [max]);
      lReport.Add('No. of good cases: %8d', [ncases]);
      lReport.Add('');
      lReport.Add('-------------------------------------------------------------');
      lReport.Add('');
    end;  // next jth variable

    DisplayReport(lReport);

  finally
    lReport.Free;
    frequency := nil;
    bins := nil;
    ValueString := nil;
    values := nil;
    selected := nil;
    leafcount := nil;
  end;
end;

procedure TStemLeafFrm.FormActivate(Sender: TObject);
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

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TStemLeafFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      SelectList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TStemLeafFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < SelectList.Items.Count do
  begin
    if SelectList.Selected[i] then
    begin
      VarList.Items.Add(SelectList.Items[i]);
      SelectList.items.Delete(i);
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TStemLeafFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
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
  for i := 0 to SelectList.Items.Count-1 do
    if SelectList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;
end;

procedure TStemLeafFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I stemleafunit.lrs}

end.

