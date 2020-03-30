// Test file: sucsintv.laz, use all variables.

unit SuccIntUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, Globals, DataProcs;

type

  { TSuccIntFrm }

  TSuccIntFrm = class(TForm)
    Bevel1: TBevel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
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
  SuccIntFrm: TSuccIntFrm;

implementation

uses
  Math;

{ TSuccIntFrm }

procedure TSuccIntFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  ItemList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TSuccIntFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Max(
    2*MaxValue([Label1.Width, Label2.Width]) + 2*AllBtn.Width + 4*VarList.BorderSpacing.Left,  // 2 * AllBtn.Width to avoid window to get too narrow
    3*w + 4*CloseBtn.BorderSpacing.Right
  );
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TSuccIntFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TSuccIntFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TSuccIntFrm.AllBtnClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to VarList.Items.Count - 1do
    ItemList.Items.Add(VarList.Items[i]);
  UpdateBtnStates;
end;

procedure TSuccIntFrm.ComputeBtnClick(Sender: TObject);
var
    i, j, k, col, X, NoSelected, MaxCat, count, subscript : integer;
    discrow : integer;
    CatCount : IntDyneVec;
    ColNoSelected : IntDyneVec;
    FreqMat : IntDyneMat;
    RowTots : IntDyneVec;
    PropMat, Zmatrix, WidthMat, TheorZMat, ThCumPMat, CumMat : DblDyneMat;
    DiscDisp, Mean, StdDev, CumWidth, ScaleValue : DblDyneVec;
    d1, d2, C1, L1, L2, t3, sum, discrep, z, prop, maxdiscrep : double;
    RowLabels, ColLabels : StrDyneVec;
    outline: string;
    Save_Cursor : TCursor;
    found : boolean;
    lReport: TStrings;
begin
    if ItemList.Items.Count = 0 then
    begin
      MessageDlg('No variables selected.', mtError, [mbOK], 0);
      exit;
    end;

    MaxCat := 0;
    L1 := 0.01;
    L2 := 0.99;
    maxdiscrep := 0.0;

    // Allocate space
    SetLength(DiscDisp,NoVariables);
    SetLength(ScaleValue,NoVariables);
    SetLength(RowLabels,NoVariables);
    SetLength(ColNoSelected,NoVariables);

    // Get items selected
    NoSelected := ItemList.Items.Count;
    for i := 1 to NoSelected do
    begin
         for j := 1 to NoVariables do
         begin
             outline := ItemList.Items.Strings[i-1];
             if outline = OS3MainFrm.DataGrid.Cells[j,0] then ColNoSelected[i-1] := j;
        end;
    end;
(*
    OutputFrm.RichEdit.Lines.Add('check of parameters');
    outline := format('No Selected = %3d',[NoSelected]);
    OutputFrm.RichEdit.Lines.Add(outline);
    for i := 1 to NoSelected do
    begin
         outline := format('ItemList %d = %s',[i-1,ItemList.Items.Strings[i-1]]);
         OutputFrm.RichEdit.Lines.Add(outline);
         outline := format('Col. No. Selected %3d = %3d',[i-1,ColNoSelected[i-1]]);
         OutputFrm.RichEdit.Lines.Add(outline);
    end;
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear;
*)
    //Find largest category value in data
    for i := 1 to NoCases do
    begin
        if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        for j := 1 to NoSelected do
        begin
            col := ColNoSelected[j-1];
            X := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i])));
            if (X > MaxCat) then MaxCat := X;
        end;
    end;

    // Initialize arrays
    SetLength(CatCount,MaxCat);
    SetLength(FreqMat,NoVariables,MaxCat);
    SetLength(RowTots,NoVariables);
    SetLength(PropMat,NoVariables,MaxCat);
    SetLength(Zmatrix,NoVariables,MaxCat);
    SetLength(WidthMat,NoVariables,MaxCat);
    SetLength(TheorZMat,NoVariables,MaxCat);
    SetLength(ThCumPMat,NoVariables,MaxCat);
    SetLength(CumMat,NoVariables,MaxCat);
    SetLength(Mean,MaxCat);
    SetLength(StdDev,MaxCat);
    SetLength(CumWidth,MaxCat);
    SetLength(ColLabels,MaxCat);

    for i := 0 to NoSelected-1 do
    begin
        RowTots[i] := 0;
        DiscDisp[i] := 0.0;
        ScaleValue[i] := 0.0;
        for  j := 0 to MaxCat-1 do
        begin
            FreqMat[i,j] := 0;
            PropMat[i,j] := 0.0;
            CumMat[i,j] := 0.0;
            Zmatrix[i,j] := 0.0;
            WidthMat[i,j] := 0.0;
            TheorZMat[i,j] := 0.0;
            ThCumPMat[i,j] := 0.0;
        end;
    end;
    for j := 0 to MaxCat-1 do
    begin
        CumWidth[j] := 0.0;
        StdDev[j] := 0.0;
        Mean[j] := 0.0;
        CatCount[j] := 0;
    end;

    Save_Cursor := Screen.Cursor; // save current cursor
    Screen.Cursor := crHourGlass;    // Show hourglass cursor

    //Build frequency matrix
    for i := 1 to NoCases do
    begin
        if (not GoodRecord(i,NoSelected,ColNoSelected)) then continue;
        for j := 1 to NoSelected do
        begin
            col := ColNoSelected[j-1];
            X := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i])));
            if ((X > 0) and (X <= MaxCat)) then
              FreqMat[j-1,X-1] := FreqMat[j-1,X-1] + 1;
        end;
    end;

    // Get row totals of the frequency matrix
    for i := 0 to NoSelected-1 do
    begin
        RowTots[i] := 0;
        for j := 0 to MaxCat-1 do
        begin
            RowTots[i] := RowTots[i] + FreqMat[i,j];
        end;
    end;

    // Convert frequencies to proportions of the row totals
    for i := 0 to NoSelected-1 do
        for j := 0 to MaxCat-1 do
            PropMat[i,j] := FreqMat[i,j] / RowTots[i];

    // Accumulate the proportions accross the categories
    for i := 1 to NoSelected do
    begin
        CumMat[i-1,0] := PropMat[i-1,0];
        for j := 2 to MaxCat do
        begin
            CumMat[i-1,j-1] := CumMat[i-1,j-2] + PropMat[i-1,j-1];
            if (j = MaxCat) then CumMat[i-1,j-1] := 1.0;
        end;
    end;

    // Convert cumulative proportions to z scores
    for i := 0 to NoSelected-1 do
    begin
        for j := 0 to MaxCat-1 do
        begin
            if (CumMat[i,j] < L1) then Zmatrix[i,j] := 99.0; //flag  -infinity
            if (CumMat[i,j] > L2) then Zmatrix[i,j] := 99.0; //flag +infinity
            if ((CumMat[i,j] >= L1) and (CumMat[i,j] <= L2)) then
                 Zmatrix[i,j] := inversez(CumMat[i,j]);
        end;
    end;

    // Obtain discriminal dispersions of the items
    t3 := 0.0;
    for i := 1 to NoSelected do
    begin
        d1 := 0.0;
        d2 := 0.0;
        C1 := 0.0;
        for j := 1 to MaxCat - 1 do
        begin
            if (Zmatrix[i-1,j-1] <> 99.0) then
            begin
                d1 := d1 + Zmatrix[i-1,j-1];
                d2 := d2 + (Zmatrix[i-1,j-1] * Zmatrix[i-1,j-1]);
                C1 := C1 + 1.0;
            end;
        end;
        if (C1 > 1) then
        begin
            DiscDisp[i-1] := d2 - ((d1 * d1) / C1);
            DiscDisp[i-1] := DiscDisp[i-1] / (C1-1.0);
            DiscDisp[i-1] := sqrt(DiscDisp[i-1]);
        end
        else DiscDisp[i-1] := 99.0;
        if ((DiscDisp[i-1] > 0) and (DiscDisp[i-1] <> 99.0))then t3 := t3 + (1.0 / DiscDisp[i-1]);
    end;

    //Constant t3 =No. items / recipricols of std.dev.s of item z scores
    t3 := NoSelected / t3;
    for i := 0 to NoSelected-1 do
    begin
        if ((DiscDisp[i] > 0.0) and (t3 > 0)) then
          DiscDisp[i] := (1.0 / DiscDisp[i]) * t3
        else
          DiscDisp[i] := 99.0;
    end;

    // Now, calculate interval widths
    for j := 2 to MaxCat - 1 do
    begin
        for i := 1 to NoSelected do
        begin
            if ((Zmatrix[i-1,j-1] <> 99.0) and (Zmatrix[i-1,j-2] <> 99.0)) then
              WidthMat[i-1,j-2] := Zmatrix[i-1,j-1] - Zmatrix[i-1,j-2]
            else
              WidthMat[i-1,j-2] := 99.0;
        end;
    end;

    //Calculate Means and Standard Deviations of category Widths
    for j := 1 to MaxCat-2 do
    begin
        for i := 1 to NoSelected do
        begin
            if (WidthMat[i-1,j-1] <> 99.0) then
            begin
                CatCount[j-1] := CatCount[j-1] + 1;
                Mean[j-1] := Mean[j-1] + WidthMat[i-1,j-1];
                StdDev[j-1] := StdDev[j-1] + (WidthMat[i-1,j-1] * WidthMat[i-1,j-1]);
            end;
        end;
        if (CatCount[j-1] > 1) then
        begin
            Mean[j-1] := Mean[j-1] / CatCount[j-1];
            StdDev[j-1] := (StdDev[j-1] / CatCount[j-1]) - (Mean[j-1] * Mean[j-1]);
            StdDev[j-1] := StdDev[j-1] * (CatCount[j-1] / (CatCount[j-1] - 1));
        end;
    end;

    // Calculate cumulative widths
    CumWidth[0] := Mean[0];
    for j := 2 to MaxCat - 1 do
        CumWidth[j-1] := CumWidth[j-2] + Mean[j-1];

    // Calculate scale item scale values
    for i := 1 to NoSelected do
    begin
        found := false;
        count := 1;
        while (not found) do
        begin
            if (CumMat[i-1,count-1] >= 0.5) then
            begin
                found := true;
                subscript := count;
            end;
            if (count = (MaxCat)) then
            begin
                found := true;
                subscript := count;
            end;
            count := count + 1;
        end;

        if ((subscript > 2) and (subscript < MaxCat)) then
        begin
            ScaleValue[i-1] := Mean[subscript-2] * ((0.5 - CumMat[i-1,subscript-2]) / PropMat[i-1,subscript-1]);
            if (subscript > 1) then
              ScaleValue[i-1] := ScaleValue[i-1] + CumWidth[subscript-3];
        end
        else
        begin  //extreme value - get average of z scores in first cat. and / 2
            sum := 0.0;
            for k := 1 to NoSelected do sum := sum + Zmatrix[i-1,0];
            sum := sum / abs(NoSelected * 2);
            ScaleValue[i-1] := sum * ((0.5 - (CumMat[i-1,0] / 2.0)) / (CumMat[i-1,0] / 2.0));
        end;

    end;

    //Calculate Theoretical z scores from the scale values
    discrep := 0.0;
    count := 0;
    for i := 1 to NoSelected do
    begin
        z := -ScaleValue[i-1];
        TheorZMat[i-1,0] := z;
        prop := probz(z);
        ThCumPMat[i-1,0] := prop;
        for j := 2 to MaxCat - 1 do
        begin
            z := CumWidth[j-2] - ScaleValue[i-1];
            if (z < -3) then z := -3.0;
            if (z > 3) then z := 3.0;
            prop := probz(z);
            TheorZMat[i-1,j-1] := z;
            ThCumPMat[i-1,j-1] := prop;
            discrep := discrep + abs(CumMat[i-1,j-1] - prop);
            if abs(CumMat[i-1,j-1] - prop) > maxdiscrep then
            begin
                 maxdiscrep := abs(CumMat[i-1,j-1] - prop);
                 discrow := i;
            end;
            count := count + 1;
        end;
        ThCumPMat[i-1,MaxCat-1] := 1.0;
    end;
    discrep := discrep / count; // average discrepency between theoretical and observed

    // Report results
    lReport := TStringList.Create;
    try
      lReport.Add('          SUCCESSIVE INTERVAL SCALING RESULTS');
      lReport.Add('');
      for i := 1 to NoSelected do
        RowLabels[i-1] := OS3MainFrm.DataGrid.Cells[ColNoSelected[i-1],0];
      for i := 1 to MaxCat do
        ColLabels[i-1] := Format(' %2d-%2d ', [i-1, i]);

      outline := '            ';
      for i := 1 to MaxCat do outline := outline + ColLabels[i-1];
      lReport.Add(outline);

      for i := 1 to NoSelected do
      begin
        lReport.Add('%10s', [RowLabels[i-1]]);

        outline := 'Frequency  ';
        for j := 1 to MaxCat do
          outline := outline + Format('%7d', [FreqMat[i-1,j-1]]);
        lReport.Add(outline);

        outline := 'Proportion ';
        for j := 1 to MaxCat do
          outline := outline + Format('%7.3f', [PropMat[i-1,j-1]]);
        lReport.Add(outline);

        outline := 'Cum. Prop. ';
        for j := 1 to MaxCat do
          outline := outline + Format('%7.3f', [CumMat[i-1,j-1]]);
        lReport.Add(outline);

        outline := 'Normal z   ';
        for j := 1 to MaxCat do
        begin
          if (Zmatrix[i-1,j-1] <> 99.0) then
            outline := outline + Format('%7.3f', [Zmatrix[i-1,j-1]])
          else
            outline := outline + '   -   ';
        end;
        lReport.Add(outline);
      end;

      lReport.Add('');
      lReport.Add('                  INTERVAL WIDTHS');
      outline := '          ';
      for i := 1 to MaxCat - 2 do
        outline := outline + Format(' %2d-%2d ', [i+1,i]);
      lReport.Add(outline);

      outline := '';
      for i := 1 to NoSelected do
      begin
        outline := outline + Format('%10s', [RowLabels[i-1]]);
        for j := 1 to MaxCat-2 do
        begin
          if (WidthMat[i-1,j-1] <> 99.0) then
            outline := outline + Format('%7.3f', [WidthMat[i-1,j-1]])
          else
            outline := outline + '   -   ';
        end;
        lReport.Add(outline);
        outline := '';
      end;
      lReport.Add('');

      outline := 'Mean Width';
      for i := 1 to MaxCat - 2 do
        outline := outline + Format('%7.2f', [Mean[i-1]]);
      lReport.Add(outline);

      outline := 'No. Items ';
      for i := 1 to MaxCat - 2 do
        outline := outline + Format('%7d', [CatCount[i-1]]);
      lReport.Add(outline);

      outline := 'Std. Dev.s';
      for i := 1 to MaxCat - 2 do
        outline := outline + Format('%7.2f', [StdDev[i-1]]);;
      lReport.Add(outline);

      outline := 'Cum. Means';
      for i := 1 to MaxCat - 2 do
        outline := outline + Format('%7.2f', [CumWidth[i-1]]);
      lReport.Add(outline);
      lReport.Add('');

      lReport.Add('ESTIMATES OF SCALE VALUES AND THEIR DISPERSIONS');
      lReport.Add('Item       No. Ratings Scale Value  Discriminal Dispersion');
      for i := 0 to NoSelected-1 do
        lReport.Add('%10s     %3d        %6.3f      %6.3f', [RowLabels[i], RowTots[i], ScaleValue[i], DiscDisp[i]]);
      lReport.Add('');

      lReport.Add('Z scores Estimated from Scale values');
      outline := '           ';
      for i := 0 to MaxCat-1 do outline := outline + ColLabels[i];
      lReport.Add(outline);
      for i := 1 to NoSelected do
      begin
        outline :=  Format('%10s', [RowLabels[i-1]]);
        for j := 1 to MaxCat - 1 do
          outline := outline + Format('%7.3f', [TheorZMat[i-1,j-1]]);
        lReport.Add(outline);
      end;
      lReport.Add('');

      lReport.Add('Cumulative Theoretical Proportions');
      outline := '           ';
      for i := 1 to MaxCat do outline := outline + ColLabels[i-1];
      lReport.Add(outline);
      for i := 1 to NoSelected do
      begin
        outline :=  Format('%10s', [RowLabels[i-1]]);
        for j := 1 to MaxCat do
          outline := outline + Format('%7.3f', [ThCumPMat[i-1,j-1]]);
        OutputFrm.RichEdit.Lines.Add(outline);
      end;
      lReport.Add('');

      outline := 'Average Discrepancy Between Theoretical and Observed Cumulative Proportions: ';
      outline := outline + Format('%.3f', [discrep]);
      lReport.Add(outline);

      lReport.Add('Maximum discrepancy %.3f found in item %s', [maxdiscrep, RowLabels[discrow-1]]);

      Screen.Cursor := Save_Cursor;
      DisplayReport(lReport);

    finally
      lReport.Free;

      ColLabels := nil;
      RowLabels := nil;
      ScaleValue := nil;
      CumWidth := nil;
      StdDev := nil;
      Mean := nil;
      DiscDisp := nil;
      CumMat := nil;
      ThCumPMat := nil;
      TheorZMat := nil;
      WidthMat := nil;
      Zmatrix := nil;
      PropMat := nil;
      RowTots := nil;
      FreqMat := nil;
      CatCount := nil;
      ColNoSelected := nil;
    end;
end;

procedure TSuccIntFrm.InBtnClick(Sender: TObject);
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
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TSuccIntFrm.OutBtnClick(Sender: TObject);
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
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TSuccIntFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  lSelected := false;
  for i := 0 to VarList.Items.Count - 1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to ItemList.Items.Count -1 do
    if ItemList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;

  AllBtn.Enabled := VarList.Items.Count > 0;
end;

procedure TSuccIntFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I succintunit.lrs}

end.

