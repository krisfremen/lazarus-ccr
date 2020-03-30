// Use file "cansas.laz" for testing

unit CompareDistUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  OutputUnit, FunctionsLib, Globals, GraphLib, DataProcs, MainUnit;

type

  { TCompareDistFrm }

  TCompareDistFrm = class(TForm)
    Bevel1: TBevel;
    LinesChk: TRadioButton;
    PointsChk: TRadioButton;
    VerticalCenterBevel: TBevel;
    BothChk: TCheckBox;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    PlotTypeGrp: TGroupBox;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    CompareGroup: TRadioGroup;
    DistGroup: TRadioGroup;
    VarOneEdit: TEdit;
    VarTwoEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Var1InBtn: TBitBtn;
    Var1OutBtn: TBitBtn;
    Var2InBtn: TBitBtn;
    Var2OutBtn: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure CompareGroupClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DistGroupClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure Var1InBtnClick(Sender: TObject);
    procedure Var1OutBtnClick(Sender: TObject);
    procedure Var2InBtnClick(Sender: TObject);
    procedure Var2OutBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    compareto: integer;
    disttype: integer;
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  CompareDistFrm: TCompareDistFrm;

implementation

uses
  Math;

{ TCompareDistFrm }

procedure TCompareDistFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
   if FAutoSized then
     exit;

   w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Panel1.Constraints.MinWidth := Groupbox1.Width;
  Panel1.Constraints.MinHeight := PlotTypeGrp.Top + PlotTypeGrp.Height - GroupBox1.Height - Panel1.BorderSpacing.Bottom - Panel1.Top;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TCompareDistFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TCompareDistFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(nil);
end;

procedure TCompareDistFrm.CompareGroupClick(Sender: TObject);
begin
  compareTo := CompareGroup.ItemIndex;
  Label3.Enabled := (compareTo = 1);
  VarTwoEdit.Enabled := (compareTo = 1);
  Var2InBtn.Enabled := (compareTo = 1);
  Var2OutBtn.Enabled := (compareTo = 1);
end;

procedure TCompareDistFrm.ComputeBtnClick(Sender: TObject);
var
  Var1Freq : IntDyneVec;
  Var2Freq : IntDyneVec;
  XValue1 : DblDyneVec;
  XValue2 : DblDyneVec;
  Cumfreq1 : DblDyneVec;
  Cumfreq2 : DblDyneVec;
  i, j, k, col1, col2, Ncases, noints : integer;
  min1, max1, min2, max2, range1, range2, value : double;
  incrsize1, incrsize2, prob1,prob2, KS, mean, DegFree : double;
  cellval, name1, name2 : string;
  df1, df2 : integer;
  xtitle : string;
  msg: String;
  lReport: TStrings;
begin
  SetLength(Var1Freq, NoCases + 1);
  SetLength(Var2Freq, NoCases + 1);
  SetLength(XValue1,  NoCases + 1);
  SetLength(XValue2,  NoCases + 1);
  SetLength(Cumfreq1, NoCases + 1);
  SetLength(Cumfreq2, NoCases + 1);

  // Get columns of the variables
  col1 := 0;
  col2 := 0;
  for i := 1 to NoVariables do
  begin
    if VarOneEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then col1 := i;
    if compareto = 1 then
    begin
      if VarTwoEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then col2 := i;
    end;
  end;

  msg := '';
  case CompareTo of
    0: if col1 = 0 then
         msg := 'Variable not specified.';
    1: if col1 = 0 then
         msg := 'Variable One is not specified.'
       else if col2 = 0 then
         msg := 'Variable Two is not specified.';
  end;
  if msg <> '' then
  begin
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  // get min and max values for variable in col1
  min1 := 1.0e308;
  max1 := -1.0e308;
  Ncases := 0;
  for j := 1 to NoCases do
  begin
    if not ValidValue(j,col1) then continue;
    value := StrToFloat(OS3MainFrm.DataGrid.Cells[col1,j]);
    if value > max1 then max1 := value;
    if value < min1 then min1 := value;
    inc(Ncases);
  end;

  noints := NoCases - 1;   // number of intervals
  if noints > 20 then noints := 20;
  range1 := max1 - min1 + 1.0;
  incrsize1 := range1 / noints;
  name1 := VarOneEdit.Text;

  if compareTo = 1 then
  begin
    min2 := 1.0e32;
    max2 := -1.0e32;
    for j := 1 to NoCases do
    begin
      if Not ValidValue(j,col2) then continue;
      value := StrToFloat(OS3MainFrm.DataGrid.Cells[col2,j]);
      if value > max2 then max2 := value;
      if value < min2 then min2 := value;
    end;
    range2 := max2 - min2 + 1.0;
    incrsize2 := range2 / noints;
    name2 := VarTwoEdit.Text;
  end;

  //Now, get frequency of cases in each interval
  for j := 1 to noints+1 do
    Var1Freq[j-1] := 0;
  for j := 1 to NoCases do
  begin
    if Not ValidValue(j,col1) then continue;
    value := StrToFloat(OS3MainFrm.DataGrid.Cells[col1,j]);
    for k := 1 to noints do
    begin
      if (value >= min1 + ((k-1) * incrsize1)) and
         (value < min1 + (k * incrsize1))
      then
        Var1Freq[k-1] := Var1Freq[k-1] + 1;
    end;
  end;
  Cumfreq1[0] := Var1Freq[0];
  for j := 1 to noints+1 do
    XValue1[j-1] := min1 + (j-1) * incrsize1;
  for j := 1 to noints do
    Cumfreq1[j] := Cumfreq1[j-1] + Var1Freq[j];
  if compareTo = 1 then // do same for second variable
  begin
    for j := 1 to noints+1 do
      Var2Freq[j-1] := 0;
    for j := 1 to NoCases do
    begin
      if Not ValidValue(j,col2) then continue;
      value := StrToFloat(OS3MainFrm.DataGrid.Cells[col2,j]);
      for k := 1 to noints do
      begin
        if (value >= min2 + ((k-1) * incrsize2)) and
           (value < min2 + (k * incrsize2))
        then
          Var2Freq[k-1] := Var2Freq[k-1] + 1;
      end;
    end;
    Cumfreq2[0] := Var2Freq[0];
    for j := 1 to noints+1 do
      XValue2[j-1] := min2 + (j-1) * incrsize2;
    for j := 1 to noints do
      Cumfreq2[j] := Cumfreq2[j-1] + Var2Freq[j];
  end;

  // Get theoretical distribution frequencies for selected dist.
  if compareTo = 0 then
  begin
    if DistGroup.ItemIndex = 0 then // normal curve
    begin
      name2 := 'Normal';
      min2 := -3.0;
      max2 := 3.0;
      range2 := max2 - min2;
      incrsize2 := range2 / noints;
      Xvalue2[0] := min2;
      Xvalue2[noints] := max2;
      for i := 1 to noints do
      begin
        Xvalue2[i-1] := min2 + (i-1) * incrsize2;
        Xvalue2[i] := min2 + (i) * incrsize2;
        prob1 := probz(abs(Xvalue2[i-1]));
        prob2 := probz(abs(Xvalue2[i]));
        if prob1 > prob2 then
          Var2Freq[i-1] := round((prob1-prob2) * Ncases)
        else
          Var2Freq[i-1] := round((prob2-prob1) * Ncases)
      end;
      Cumfreq2[0] := Var2Freq[0];
      for i := 1 to noints do
        Cumfreq2[i] := Cumfreq2[i-1] + Var2Freq[i];
    end
    else
    if DistGroup.ItemIndex = 1 then // t-distribution
    begin
      name2 := 't-Dist.';
      min2 := -3.0;
      max2 := 3.0;
      df1 := Ncases - 1;
      range2 := max2 - min2;
      incrsize2 := range2 / noints;
      Xvalue2[0] := min2;
      Xvalue2[noints] := max2;
      for i := 1 to noints do
      begin
        Xvalue2[i-1] := min2 + (i-1) * incrsize2;
        Xvalue2[i] := min2 + (i) * incrsize2;
        prob1 := 0.5 * probt(Xvalue2[i-1],df1);
        prob2 := 0.5 * probt(Xvalue2[i],df1);
        if prob1 > prob2 then
          Var2Freq[i-1] := round((prob1-prob2) * Ncases)
        else
          Var2Freq[i-1] := round((prob2-prob1) * Ncases)
      end;
      Cumfreq2[0] := Var2Freq[0];
      for i := 1 to noints do
        Cumfreq2[i] := Cumfreq2[i-1] + Var2Freq[i];
    end
    else
    if DistGroup.ItemIndex = 2 then // chi squared distribution
    begin
      cellval := InputBox('Deg. Freedom 1 Entry','DF 1','');
      df1 := StrToInt(cellval);
      name2 := 'Chi Sqrd';
      min2 := 0.0;
      max2 := 20.0;
      range2 := max2 - min2;
      incrsize2 := range2 / noints;
      Xvalue2[0] := min2;
      Xvalue2[noints] := max2;
      for i := 1 to noints do
      begin
        Xvalue2[i-1] := min2 + (i-1) * incrsize2;
        Xvalue2[i] := min2 + (i) * incrsize2;
        prob1 := chisquaredprob(Xvalue2[i-1],df1);
        prob2 := chisquaredprob(Xvalue2[i],df1);
        if prob1 > prob2 then
          Var2Freq[i-1] := round((prob1-prob2) * Ncases)
        else
          Var2Freq[i-1] := round((prob2-prob1) * Ncases)
      end;
      Cumfreq2[0] := Var2Freq[0];
      for i := 1 to noints do
        Cumfreq2[i] := Cumfreq2[i-1] + Var2Freq[i];
    end
    else
    if DistGroup.ItemIndex = 3 then // F distribution
    begin
      // get degrees of freedom
      cellval := InputBox('Deg. Freedom 1 Entry','DF 1','');
      df1 := StrToInt(cellval);
      cellval := InputBox('Deg. Freedom 2 Entry','DF 2','');
      df2 := StrToInt(cellval);
      name2 := 'F Dist.';
      min2 := 0.0;
      max2 := 3.0;
      range2 := max2 - min2;
      incrsize2 := range2 / noints;
      Xvalue2[0] := min2;
      Xvalue2[noints] := max2;
      for i := 1 to noints do
      begin
        Xvalue2[i-1] := min2 + (i-1) * incrsize2;
        Xvalue2[i] := min2 + (i) * incrsize2;
        prob1 := probf(Xvalue2[i-1],df1,df2);
        prob2 := probf(Xvalue2[i],df1,df2);
        if prob1 > prob2 then
          Var2Freq[i-1] := round((prob1-prob2) * Ncases)
        else
          Var2Freq[i-1] := round((prob2-prob1) * Ncases)
      end;
      Cumfreq2[0] := Var2Freq[0];
      for i := 1 to noints do
        Cumfreq2[i] := Cumfreq2[i-1] + Var2Freq[i];
    end
    else
    if DistGroup.ItemIndex = 4 then // Poisson distribution
    begin
      name2 := 'Poisson';
      mean := 0; // use as parameter a in pdf call
      min2 := min1;
      max2 := max1;
      if max2 > 13 then
      begin
        MessageDlg('Value > 13 found. Factorial too large - exiting.', mtError, [mbOK], 0);
        exit;
      end;
      for i := 1 to Ncases do
        mean := mean + StrToFloat(OS3MainFrm.DataGrid.Cells[col1,i]);
      mean := mean / Ncases;
      cellval := IntToStr(round(mean));
      cellval := InputBox('Parameter Entry (mean)','DF 1',cellval);
      degfree := StrToFloat(cellval);
      range2 := max2 - min2;
      incrsize2 := range2 / noints;
//             Xvalue2[0] := min2;
      Xvalue2[noints] := max2;
      for i := 1 to noints do
      begin
        Xvalue2[i-1] := min2 + (i-1) * incrsize2;
        Xvalue2[i] := min2 + (i) * incrsize2;
        poisson_pdf ( round(Xvalue2[i-1]), degfree, prob1 );
//                  prob1 := (Xvalue2[i-1],df1);
//                  prob2 := chisquaredprob(Xvalue2[i],df1);
//                  if prob1 > prob2 then
       Var2Freq[i-1] := round((prob1) * Ncases);
//                  else Var2Freq[i-1] := round((prob2-prob1) * Ncases)
      end;
      Cumfreq2[0] := Var2Freq[0];
      for i := 1 to noints do
        Cumfreq2[i] := Cumfreq2[i-1] + Var2Freq[i];
    end;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('DISTRIBUTION COMPARISON by Bill Miller');
    lReport.Add('');
    lReport.Add('%10s   %10s   %10s   %10s   %10s   %10s', [
      name1, name1, name1, name2, name2, name2
    ]);
    lReport.Add('%10s   %10s   %10s   %10s   %10s   %10s', [
      'X1 Value','Frequency','Cum. Freq.','X2 Value','Frequency','Cum. Freq.'
    ]);
    for i := 1 to noints do
      lReport.Add('%10.3f   %10d   %10.3f   %10.3f   %10d   %10.3f', [
        XValue1[i-1],Var1Freq[i-1],Cumfreq1[i-1],XValue2[i-1],Var2Freq[i-1],Cumfreq2[i-1]
      ]);
    cellval := 'D';
    KS := KolmogorovTest(noints, Cumfreq1,noints, Cumfreq2, cellval);
  // lReport.Add('Kolmogorov-Smirnov statistic := %5.3f', [KS]);

    DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  // plot the cdfs
  xtitle := 'Red = ' + VarOneEdit.Text + ' Blue = ' + name2;
  cellval := 'Plot of Cumulative Distributions';
  if LinesChk.Checked then
    GraphFrm.barwideprop := 1.0
  else
    GraphFrm.barwideprop := 0.5;

  GraphFrm.nosets := 2;
  GraphFrm.nbars := noints+1;
  GraphFrm.Heading := cellval;
  GraphFrm.XTitle := xtitle;
  GraphFrm.YTitle := 'Frequency';
  SetLength(GraphFrm.Ypoints,2,noints+1);
  SetLength(GraphFrm.Xpoints,1,noints+1);
  for k := 1 to noints+1 do
  begin
    GraphFrm.Ypoints[0,k-1] := Cumfreq1[k-1];
    GraphFrm.Ypoints[1,k-1] := CumFreq2[k-1];
    GraphFrm.Xpoints[0,k-1] := k;
  end;
  GraphFrm.AutoScaled := true;
  if LinesChk.Checked then
    GraphFrm.GraphType := 6 // 3d lines
  else
    GraphFrm.GraphType := 8;  // 3D points
  GraphFrm.BackColor := clYellow;
  GraphFrm.WallColor := clBlue;
  GraphFrm.FloorColor := clGray;
  GraphFrm.ShowLeftWall := true;
  GraphFrm.ShowRightWall := true;
  GraphFrm.ShowBottomWall := true;
  GraphFrm.ShowBackWall := true;
  GraphFrm.ShowModal;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;

  if BothChk.Checked then // plot the frequencies
  begin
    xtitle := 'Red = ' + VarOneEdit.Text + ' Blue = ' + name2;
    cellval := 'Plot of Cumulative Distributions';
    if LinesChk.Checked then
      GraphFrm.BarWideProp := 1.0
    else
      GraphFrm.BarWideProp := 0.5;
    GraphFrm.nosets := 2;
    GraphFrm.nbars := noints+1;
    GraphFrm.Heading := cellval;
    GraphFrm.XTitle := xtitle;
    GraphFrm.YTitle := 'Frequency';
    SetLength(GraphFrm.Ypoints,2,noints+1);
    SetLength(GraphFrm.Xpoints,1,noints+1);
    for k := 1 to noints+1 do
    begin
      GraphFrm.Ypoints[0,k-1] := Var1Freq[k-1];
      GraphFrm.Ypoints[1,k-1] := Var2Freq[k-1];
      GraphFrm.Xpoints[0,k-1] := k;
    end;
    GraphFrm.AutoScaled := true;
    if LinesChk.Checked then
      GraphFrm.GraphType := 6 // 3d lines
    else
      GraphFrm.GraphType := 8;  // 3D points
    GraphFrm.BackColor := clYellow;
    GraphFrm.WallColor := clBlue;
    GraphFrm.FloorColor := clGray;
    GraphFrm.ShowLeftWall := true;
    GraphFrm.ShowRightWall := true;
    GraphFrm.ShowBottomWall := true;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
  end;

  // clean up
  Cumfreq2 := nil;
  Cumfreq1 := nil;
  XValue1 := nil;
  XValue2 := nil;
  Var2Freq := nil;
  Var1Freq := nil;
end;

procedure TCompareDistFrm.DistGroupClick(Sender: TObject);
begin
  disttype := DistGroup.ItemIndex;
end;

procedure TCompareDistFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  VarOneEdit.Text := '';
  VarTwoEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  Label3.Enabled := false;
  CompareGroup.ItemIndex := 0;
  DistGroup.ItemIndex := 0;
  LinesChk.Checked := false;
  PointsChk.Checked := true;
end;

procedure TCompareDistFrm.Var1InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (VarOneEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] then
    begin
      VarOneEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TCompareDistFrm.Var1OutBtnClick(Sender: TObject);
begin
  if VarOneEdit.Text <> '' then
  begin
    VarList.Items.Add(VarOneEdit.Text);
    VarOneEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TCompareDistFrm.Var2InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (VarTwoEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] then
    begin
      VarTwoEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TCompareDistFrm.Var2OutBtnClick(Sender: TObject);
begin
  if VarTwoEdit.Text <> '' then
  begin
    VarList.Items.Add(VarTwoEdit.Text);
    VarTwoEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TCompareDistFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TCompareDistFrm.UpdateBtnStates;
begin
  Var1InBtn.Enabled := (VarList.ItemIndex > -1) and (VarOneEdit.Text = '');
  Var2InBtn.Enabled := (VarList.ItemIndex > -1) and (VarTwoEdit.Text = '');
  Var1OutBtn.Enabled := VarOneEdit.Text <> '';
  Var2OutBtn.Enabled := VarTwoEdit.Text <> '';
end;

initialization
  {$I comparedistunit.lrs}

end.

