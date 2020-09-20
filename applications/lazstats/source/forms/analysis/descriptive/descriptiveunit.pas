unit DescriptiveUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, FunctionsLib, ReportFrameUnit, DataProcs, DictionaryUnit, ContextHelpUnit;


type

  { TDescriptiveFrm }

  TDescriptiveFrm = class(TForm)
    Bevel1: TBevel;
    ComputeBtn: TButton;
    CaseChk: TCheckBox;
    ZScoresToGridChk: TCheckBox;
    AllQrtilesChk: TCheckBox;
    HelpBtn: TButton;
    Label2: TLabel;
    Label3: TLabel;
    ReportPanel: TPanel;
    ParamsPanel: TPanel;
    PcntileChk: TCheckBox;
    OptionsGroup: TGroupBox;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    ResetBtn: TButton;
    CloseBtn: TButton;
    CIEdit: TEdit;
    Label1: TLabel;
    Splitter1: TSplitter;
    VarList: TListBox;
    SelList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FReportFrame: TReportFrame;
    FAutoSized: Boolean;
    sum, variance, stddev, value, mean, min, max, range, skew, prob, df, CI : double;
    kurtosis, z, semean, seskew, sekurtosis, deviation, devsqr, M2, M3, M4 : double;
    procedure UpdateBtnStates;

  public
    { public declarations }
    procedure Reset;
  end; 

var
  DescriptiveFrm: TDescriptiveFrm;


implementation

{$R *.lfm}

uses
  Math;

{ TDescriptiveFrm }

procedure TDescriptiveFrm.AllBtnClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to VarList.Items.Count-1 do
    SelList.Items.Add(VarList.Items.Strings[i]);
  VarList.Clear;
  UpdateBtnStates;
end;


procedure TDescriptiveFrm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;


procedure TDescriptiveFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  ParamsPanel.AutoSize := true;
  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
  ParamsPanel.Constraints.MinHeight := AllBtn.Top + AllBtn.Height + OptionsGroup.Height +
    CIEdit.Height + Bevel1.Height + CloseBtn.Height + VarList.BorderSpacing.Bottom +
    OptionsGroup.BorderSpacing.Bottom + CloseBtn.BorderSpacing.Top;
  ParamsPanel.Constraints.MinWidth := Math.Max(
    4*w + 3*HelpBtn.BorderSpacing.Right,
    OptionsGroup.Width
  );
  ParamsPanel.AutoSize := false;

  Constraints.MinHeight := ParamsPanel.Constraints.MinHeight + ParamsPanel.BorderSpacing.Around*2;
  Constraints.MinWidth := ParamsPanel.Constraints.MinWidth + ParamsPanel.BorderSpacing.Around*2;

  Position := poDesigned;
  FAutoSized := true;
end;


procedure TDescriptiveFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);

  FReportFrame := TReportFrame.Create(self);
  FReportFrame.Parent := ReportPanel;
  FReportFrame.Align := alClient;
  FReportFrame.ReportToolBar.Align := alRight;
  FReportFrame.ReportToolbar.EdgeBorders := [];

  Reset;
end;


procedure TDescriptiveFrm.ComputeBtnClick(Sender: TObject);
var
  i, j, k, m: integer;
  nCases, noSelected: integer;
  Q1, Q2, Q3, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q22, Q23, Q24, Q25, Q26: double;
  Q27, Q28, Q32, Q33, Q34, Q35, Q36, Q37, Q38, IQrange: double;
  num, den, cases: double;
  values: DblDyneVec = nil;
  pcntRank: DblDyneVec = nil;
  selected: IntDyneVec = nil;
  cellString: String;
  lReport: TStrings;
begin
  NoSelected := SelList.Items.Count;
  if noSelected = 0 then
  begin
    MessageDlg('No variables selected.', mtError, [mbOK], 0);
    exit;
  end;

  SetLength(selected, noSelected);

  // Get selected variables
  for i := 1 to noselected do
  begin
    cellstring := SelList.Items.Strings[i-1];
    for j := 1 to NoVariables do
      if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then selected[i-1] := j;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('DISTRIBUTION PARAMETER ESTIMATES');
    lReport.Add('');

    SetLength(Values, NoCases);
    SetLength(pcntRank, NoCases);

    for j := 1 to noSelected do
    begin
      deviation := 0.0;
      devsqr := 0.0;
      M2 := 0.0;
      M3 := 0.0;
      M4 := 0.0;
      sum := 0.0;
      variance := 0.0;
      stddev := 0.0;
      range := 0.0;
      skew := 0.0;
      kurtosis := 0.0;
      ncases := 0;
      df := 0.0;
      seskew := 0.0;
      kurtosis := 0.0;
      sekurtosis := 0.0;
      k := selected[j-1];
      CI := StrToFloat(CIEdit.Text) / 100.0;
      prob := CI;
      CI := (1.0 - CI) / 2.0;
      CI := 1.0 - CI;

      if ZScoresToGridChk.Checked then // add a new column to the grid
      begin
        cellstring := OS3MainFrm.DataGrid.Cells[k,0] + 'z';
        DictionaryFrm.NewVar(NoVariables + 1);
        DictionaryFrm.DictGrid.Cells[1, NoVariables] := cellstring;
        OS3MainFrm.DataGrid.Cells[NoVariables, 0] := cellstring;
      end;

      // Accumulate sums of squares, sums, etc. for variable j
      min := 1.0e308;
      max := -1.0e308;
      for i := 1 to NoCases do
      begin
        if not GoodRecord(i, noSelected, selected) then
          continue;

        if CaseChk.Checked then
        begin
          if not ValidValue(i, selected[j-1]) then
            continue;
        end
        else if not GoodRecord(i, noselected, selected) then
          continue;

        value := StrToFloat(OS3MainFrm.DataGrid.Cells[k,i]);
        ncases := ncases + 1;
        values[ncases-1] := value;
        df := df + 1.0;
        sum := sum + value;
        variance := variance + (value * value);
        if (value < min) then min := value;
        if (value > max) then max := value;
      end;

      if ncases > 0 then
      begin
        mean := sum / ncases;
        range := max - min;
      end;

      if ncases > 1 then
      begin
        variance := variance - (sum * sum) / ncases;
        variance := variance / (ncases - 1);
        stddev := sqrt(variance);
        semean := sqrt(variance / ncases);
        if ncases < 120 then
          CI := semean * inverset(CI,df)
        else
          CI := semean * inversez(CI);
      end;

      if variance = 0.0 then
      begin
        cellstring := OS3MainFrm.DataGrid.Cells[k,0];
        MessageDlg('No Variability in '+ cellstring + ' variable - ending analysis.', mtInformation, [mbOK], 0);
        exit;
      end;

      if ncases > 3 then // obtain skew, kurtosis and z scores
      begin
        for i := 1 to NoCases do
        begin
          if CaseChk.Checked then
          begin
            if not ValidValue(i, selected[j-1]) then continue;
          end else
            if not GoodRecord(i, noselected, selected) then continue;

          value := StrToFloat(OS3MainFrm.DataGrid.Cells[k,i]);
          if stddev > 0.0 then
          begin
            deviation := value - mean;
            devsqr := deviation * deviation;
            M2 := M2 + devsqr;
            M3 := M3 + (deviation * devsqr);
            M4 := M4 + (devsqr * devsqr);
            z := (value - mean) / stddev;
            if ZScoresToGridChk.Checked then
            begin
              cellstring := format('%8.5f',[z]);
              OS3MainFrm.DataGrid.Cells[NoVariables,i] := cellstring;
            end;
          end;
        end;

        if ncases > 2 then
        begin
          skew := (ncases * M3) / ((ncases - 1) * (ncases - 2) * stddev * variance);
          cases := ncases;
          num := 6.0 * cases * (cases - 1.0);
          den := (cases - 2.0) * (cases + 1.0) * (cases + 3.0);
          seskew := sqrt(num / den);
        end;

        if ncases > 3 then
        begin
          kurtosis := (ncases * (ncases + 1) * M4) - (3 * M2 * M2 * (ncases - 1));
          kurtosis := kurtosis / ( (ncases - 1) * (ncases - 2) * (ncases - 3) * (variance * variance) );
          sekurtosis := sqrt((4.0 * (ncases * ncases - 1) * (seskew * seskew)) / ((ncases - 3) * (ncases + 5)));
        end;
      end;

      // output results for the kth variable
      cellstring := OS3MainFrm.DataGrid.Cells[k,0];
      if j > 1 then lReport.Add('');
      lReport.Add('VARIABLE:                  %10s', ['"' + cellString + '"']);
      lReport.Add('');
      lReport.Add('Number of cases:           %10d', [nCases]);
      lReport.Add('Sum:                       %10.3f', [sum]);
      lReport.Add('Mean:                      %10.3f', [mean]);
      lReport.Add('Variance:                  %10.3f', [variance]);
      lReport.Add('Std.Dev.:                  %10.3f', [stddev]);
      lReport.Add('Std.Error of Mean          %10.3f', [seMean]);
      lReport.Add('%.2f%% Conf.Interval Mean: %10.3f to %.3f', [prob*100.0, mean - CI, mean + CI]);
      lReport.Add('Range:                     %10.3f', [range]);
      lReport.Add('Minimum:                   %10.3f', [min]);
      lReport.Add('Maximum:                   %10.3f', [max]);
      lReport.Add('Skewness:                  %10.3f', [skew]);
      lReport.Add('Std.Error of Skew:         %10.3f', [seSkew]);
      lReport.Add('Kurtosis:                  %10.3f', [kurtosis]);
      lReport.Add('Std. Error of Kurtosis:    %10.3f', [seKurtosis]);
      lReport.Add('');

      if ncases > 4 then  // get percentiles and quartiles
      begin
        // get percentile ranks
        if pcntileChk.Checked then PRank(k, pcntRank, lReport);

        // sort values and get quartiles
        for i := 0 to ncases - 2 do
        begin
          for m := i + 1 to ncases -1 do
          begin
            if values[i] > values[m] then
            begin
              value := values[i];
              values[i] := values[m];
              values[m] := value;
            end;
          end;
        end;
        Q1 := Quartiles(2,0.25,ncases,values);
        Q2 := Quartiles(2,0.5,ncases,values);
        Q3 := Quartiles(2,0.75,ncases,values);
        IQrange := Q3 - Q1;
        lReport.Add('First Quartile:            %10.3f', [Q1]);
        lReport.Add('Median:                    %10.3f', [Q2]);
        lReport.Add('Third Quartile:            %10.3f', [Q3]);
        lReport.Add('Interquartile range:       %10.3f', [IQrange]);
        lReport.Add('');
      end;

      if (AllQrtilesChk.Checked) then
      begin
        lReport.Add('Alternative Methods for Obtaining Quartiles');
        lReport.Add('    Method 1    2       3       4       5       6       7       8');
        lReport.Add('Pcntile');
        Q1 := Quartiles(1,0.25,ncases,values);
        Q12 := Quartiles(2,0.25,ncases,values);
        Q13 := Quartiles(3,0.25,ncases,values);
        Q14 := Quartiles(4,0.25,ncases,values);
        Q15 := Quartiles(5,0.25,ncases,values);
        Q16 := Quartiles(6,0.25,ncases,values);
        Q17 := Quartiles(7,0.25,ncases,values);
        Q18 := Quartiles(8,0.25,ncases,values);
        lReport.Add('Q1   %8.3f%8.3f%8.3f%8.3f%8.3f%8.3f%8.3f%8.3f', [Q1,Q12,Q13,Q14,Q15,Q16,Q17,Q18]);
        Q2 := Quartiles(1,0.5,ncases,values);
        Q22 := Quartiles(2,0.5,ncases,values);
        Q23 := Quartiles(3,0.5,ncases,values);
        Q24 := Quartiles(4,0.5,ncases,values);
        Q25 := Quartiles(5,0.5,ncases,values);
        Q26 := Quartiles(6,0.5,ncases,values);
        Q27 := Quartiles(7,0.5,ncases,values);
        Q28 := Quartiles(8,0.5,ncases,values);
        lReport.Add('Q2   %8.3f%8.3f%8.3f%8.3f%8.3f%8.3f%8.3f%8.3f', [Q2,Q22,Q23,Q24,Q25,Q26,Q27,Q28]);
        Q3 := Quartiles(1,0.75,ncases,values);
        Q32 := Quartiles(2,0.75,ncases,values);
        Q33 := Quartiles(3,0.75,ncases,values);
        Q34 := Quartiles(4,0.75,ncases,values);
        Q35 := Quartiles(5,0.75,ncases,values);
        Q36 := Quartiles(6,0.75,ncases,values);
        Q37 := Quartiles(7,0.75,ncases,values);
        Q38 := Quartiles(8,0.75,ncases,values);
        lReport.Add('Q3   %8.3f%8.3f%8.3f%8.3f%8.3f%8.3f%8.3f%8.3f', [Q3,Q32,Q33,Q34,Q35,Q36,Q37,Q38]);
        lReport.Add('');
        lReport.Add('NOTES:');
        lReport.Add('Method 1 is the weighted average at X[np] where ');
        lReport.Add('  n is no. of cases, p is percentile / 100');
        lReport.Add('Method 2 is the weighted average at X[(n+1)p] This is used in this program.');
        lReport.Add('Method 3 is the empirical distribution function.');
        lReport.Add('Method 4 is called the empirical distribution function - averaging.');
        lReport.Add('Method 5 is called the empirical distribution function = Interpolation.');
        lReport.Add('Method 6 is the closest observation method.');
        lReport.Add('Method 7 is from the TrueBasic Statistics Graphics Toolkit.');
        lReport.Add('Method 8 was used in an older Microsoft Excel version.');
        lReport.Add('See the internet site http://www.xycoon.com/ for the above.');
        lReport.Add('');
      end;  // end of experimental alternatives
      lReport.Add(DIVIDER_AUTO);
    end; // next j variable

    FReportFrame.DisplayReport(lReport);

  finally
    lReport.Free;
    Selected := nil;
    Values := nil;
    pcntrank := nil;
  end;
end;


procedure TDescriptiveFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;


procedure TDescriptiveFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      SelList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;


procedure TDescriptiveFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < SelList.Items.Count do
  begin
    if SelList.Selected[i] then
    begin
      VarList.Items.Add(SelList.Items[i]);
      SelList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TDescriptiveFrm.Reset;
var
  i: integer;
begin
  CIEdit.Text := FormatFloat('0.0', DEFAULT_CONFIDENCE_LEVEL_PERCENT);
  VarList.Clear;
  SelList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
  FReportFrame.Clear;
end;

procedure TDescriptiveFrm.ResetBtnClick(Sender: TObject);
begin
  Reset;
end;

procedure TDescriptiveFrm.UpdateBtnStates;
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
  for i := 0 to SelList.Items.Count-1 do
    if SelList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;

  AllBtn.Enabled := VarList.Count > 0;
end;


procedure TDescriptiveFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


end.

