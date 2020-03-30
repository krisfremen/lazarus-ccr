// Use "cansas.laz" for testing.

unit FreqUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Globals, MainUnit, OutputUnit, FunctionsLib, GraphLib, DataProcs;

type

  { TFreqFrm }

  TFreqFrm = class(TForm)
    Bevel1: TBevel;
    ComputeBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    CloseBtn: TButton;
    NormPltChk: TCheckBox;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    SelList: TListBox;
    PlotOptionsGroup: TRadioGroup;
    BarTypeGroup: TRadioGroup;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure PlotOptionsGroupSelectionChanged(Sender: TObject);
    procedure SelListSelectionChange(Sender: TObject; User: boolean);
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
  FreqFrm: TFreqFrm;

implementation

uses
  Math,
  FreqSpecsUnit;

{ TFreqFrm }

procedure TFreqFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;

begin
  VarList.Clear;
  SelList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  BarTypeGroup.ItemIndex := 0;
  PlotOptionsGroup.ItemIndex := 0;
  NormPltChk.Checked := false;
  UpdateBtnStates;
end;

procedure TFreqFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
  Panel1.Constraints.MinHeight := BarTypeGroup.Top + BarTypeGroup.Height - Panel1.Top;
  Panel1.Constraints.MinWidth := Label2.Width * 2 + AllBtn.Width + 2 * VarList.BorderSpacing.Right;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  FAutoSized := true;
end;

procedure TFreqFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  if FreqSpecsFrm = nil then
    Application.CreateForm(TFreqSpecsFrm, FreqSpecsFrm);

  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TFreqFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TFreqFrm.AllBtnClick(Sender: TObject);
var
  count, index : integer;
begin
  count := VarList.Items.Count;
  for index := 0 to count-1 do
    SelList.Items.Add(VarList.Items[index]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TFreqFrm.InBtnClick(Sender: TObject);
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
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TFreqFrm.SelListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TFreqFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k : integer;
   freq : DblDyneVec;
   pcnt : DblDyneVec;
   cumpcnt : DblDyneVec;
   pcntilerank : DblDyneVec;
   cumfreq : DblDyneVec;
   XValue : DblDyneVec;
   value : double;
   NoVars : integer;
   plottype : integer;
   cellval : string;
   col : integer;
   min, max : double;
   range : double;
   incrsize : double;
   nointervals : double;
   nints : integer;
//   ColNoSelected : IntDyneVec;
   NormDist : boolean;
   Histogram : boolean;
   Sumx, Sumx2, Mean, Variance, StdDev, zlow, zhi : double;
   X, zproplow, zprophi, zfreq : double;
   Ncases : integer;
   lReport: TStrings;

begin
  if BarTypeGroup.ItemIndex = 1 then Histogram := true else Histogram := false;
  if NormPltChk.Checked = true then NormDist := true else NormDist := false;

  SetLength(freq,NoCases);
  SetLength(pcnt,NoCases);
  SetLength(cumpcnt,NoCases);
  SetLength(pcntilerank,NoCases);
  SetLength(cumfreq,NoCases);
  SetLength(XValue,NoCases);

  lReport := TStringList.Create;
  try
    lReport.Add('FREQUENCY ANALYSIS BY BILL MILLER');
    lReport.Add('');

    { Analyze each variable }
    NoVars := SelList.Items.Count;
    for i := 1 to NoVars do
    begin
      { get column no. of variable }
      col := 1;
      cellval := SelList.Items.Strings[i-1];
      for j := 1 to NoVariables do
      begin
        if OS3MainFrm.DataGrid.Cells[j,0] = cellval then
        begin
          col := j;
          lReport.Add('Frequency Analysis for Variable "%s"', [cellval]);
          break;
        end;
      end;

      { get min and max values for variable in col }
      min := 1.0e32;
      max := -1.0e32;
      for j := 1 to NoCases do
      begin
        if not ValidValue(j,col) then continue;
        value := StrToFloat(OS3MainFrm.DataGrid.Cells[col,j]);
        if value > max then max := value;
        if value < min then min := value;
      end;
      range := max - min + 1.0;
      incrsize := 1.0;
      { if too many increments, set increment size for 15 increments }
      if range > 200.0 then incrsize := range / 15;
      nointervals := range / incrsize;
      nints := round(nointervals);

      { Get user's approval and / or changes }
      FreqSpecsFrm.VarName.Text := cellval;
      FreqSpecsFrm.Minimum.Text := FloatToStr(min);
      FreqSpecsFrm.Maximum.Text := FloatToStr(max);
      FreqSpecsFrm.range.Text := FloatToStr(range);
      FreqSpecsFrm.IntSize.Text := FloatToStr(incrsize);
      FreqSpecsFrm.NoInts.Text := IntToStr(nints);
      FreqSpecsFrm.NoCases := NoCases;
      if FreqSpecsFrm.ShowModal <> mrOK then
        exit;

      incrsize := StrToFloat(FreqSpecsFrm.IntSize.Text);
      nints := StrToInt(FreqSpecsFrm.NoInts.Text);
      if nints > 200 then
        nints := 200;

      {Now, get frequency of cases in each interval }
      for j := 1 to nints+1 do
        freq[j-1] := 0;
      Ncases := 0;
      for j := 1 to NoCases do
      begin
        if not ValidValue(j,col) then continue;
        inc(Ncases);
        value := StrToFloat(OS3MainFrm.DataGrid.Cells[col,j]);
        for k := 1 to nints do
        begin
          if (value >= min + ((k-1) * incrsize)) and
             (value < min + (k * incrsize)) then freq[k-1] := freq[k-1] + 1;
        end;
      end;
      for j := 1 to nints+1 do
        XValue[j-1] := min + (j-1) * incrsize;

      { get cumulative frequencies and percents to midpoints }
      cumfreq[0] := freq[0];
      pcnt[0] := freq[0] / Ncases;
      cumpcnt[0] := cumfreq[0] / Ncases;
      pcntilerank[0] := (freq[0] / 2.0) / Ncases;
      for k := 2 to nints do
      begin
        cumfreq[k-1] := cumfreq[k-2] + freq[k-1];
        pcnt[k-1] := freq[k-1] / Ncases;
        cumpcnt[k-1] := cumfreq[k-1] / Ncases;
        pcntilerank[k-1] := (cumfreq[k-2] + freq[k-1] / 2.0) / Ncases;
      end;

      { Now, print results to report }
      lReport.Add('    FROM    TO      FREQ.   PCNT    CUM.FREQ. CUM.PCNT. %ILE RANK');
      lReport.Add('');
      for k := 1 to nints do
        lReport.Add('%8.2f%8.2f%8.0f%8.2f  %8.2f  %8.2f  %8.2f', [
          min+(k-1)*incrsize,    // from
          min+k*incrsize,        // to
          freq[k-1],             // freq
          pcnt[k-1],             // pcnt
          cumfreq[k-1],          // cum.freq.
          cumpcnt[k-1],          // cum.pcnt.
          pcntilerank[k-1]       // %ile rank
        ]);

      { Now, prepare plot values as indicated in options list }
      if NormDist = false then
        SetLength(GraphFrm.Ypoints,1,nints+1)
      else
        SetLength(GraphFrm.Ypoints,2,nints+1);
      SetLength(GraphFrm.Xpoints,1,nints+1);
      for k := 1 to nints+1 do
      begin
        GraphFrm.Ypoints[0,k-1] := freq[k-1];
        GraphFrm.Xpoints[0,k-1] := XValue[k-1];
      end;

      // Create ND plot if checked.
      // BUT: Only 3D-vertical plots when normal curve is desired
      if NormDist then
      begin
        lReport.Add('');
        lReport.Add('Interval ND Freq.');
        // Only use 3Dvertical plots when normal curve desired
        PlotOptionsGroup.ItemIndex := 1;
        // get mean and standard deviation of xvalues, then height of
        // the normal curve for each Normally distributed corresponding z score
        sumx := 0.0;
        sumx2 := 0.0;
        for k := 1 to nints do
        begin
          sumx := sumx + (XValue[k-1] * freq[k-1]);
          sumx2 := sumx2 + ((XValue[k-1] * XValue[k-1]) * freq[k-1]);
        end;
        Mean := sumx / Ncases;
        Variance := sumx2 - ((sumx * sumx) / Ncases);
        Variance := Variance / (Ncases - 1);
        StdDev := sqrt(Variance);
        for k := 1 to nints+1 do
        begin
          X := XValue[k-1] - (incrsize / 2.0);
          if StdDev > 0.0 then
            zlow := (X - Mean) / StdDev
          else
            zlow := 0.0;
          X := XValue[k-1] + (incrsize / 2.0);
          if StdDev > 0.0 then
            zhi := (X - Mean) / StdDev
          else
            zhi := 0.0;

          // get cum. prop. for this z and translate to frequency
          zproplow := probz(zlow);
          zprophi := probz(zhi);
          zfreq := NoCases * abs(zprophi - zproplow);
          GraphFrm.Ypoints[1,k-1] := zfreq;
          lReport.Add('    %2d      %6.2f', [k, GraphFrm.Ypoints[1,k-1]]);
        end;
      end;

      // Show report in form
      DisplayReport(lReport);

      // Plot data
      plottype := PlotOptionsGroup.ItemIndex + 1;
      if Histogram then
        GraphFrm.barwideprop := 1.0
      else
        GraphFrm.barwideprop := 0.5;
      if NormDist then
        GraphFrm.nosets := 2
      else
        GraphFrm.nosets := 1;
      GraphFrm.nbars := nints+1;
      GraphFrm.Heading := cellval;
      GraphFrm.XTitle := 'Lower Limit Values';
      GraphFrm.YTitle := 'Frequency';
      GraphFrm.AutoScaled := true;
      GraphFrm.GraphType := plotType;
      GraphFrm.BackColor := clCream;
      GraphFrm.WallColor := clDkGray;
      GraphFrm.FloorColor := clLtGray;
      GraphFrm.ShowBackWall := true;
      if plotType in [2, 6, 8, 10] then
      begin
        GraphFrm.ShowLeftWall := true;
        GraphFrm.ShowRightWall := true;
        GraphFrm.ShowBottomWall := true;
      end;
      GraphFrm.ShowModal;
      GraphFrm.Xpoints := nil;
      GraphFrm.Ypoints := nil;
    end; // for novars list

  finally
    lReport.Free;
    XValue := nil;
    cumfreq := nil;
    pcntilerank := nil;
    cumpcnt := nil;
    pcnt := nil;
    freq := nil;
  end;
end;

procedure TFreqFrm.OutBtnClick(Sender: TObject);
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
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TFreqFrm.PlotOptionsGroupSelectionChanged(Sender: TObject);
begin
   BarTypeGroup.Enabled := PlotOptionsGroup.ItemIndex in [0, 1, 8, 9];  // Bar series only
end;

procedure TFreqFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  lSelected := false;
  for i := 0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      Break;
    end;
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to SelList.Items.Count-1 do
    if SelList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;

  AllBtn.Enabled := VarList.Items.Count > 0;
end;

procedure TFreqFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I frequnit.lrs}

end.

