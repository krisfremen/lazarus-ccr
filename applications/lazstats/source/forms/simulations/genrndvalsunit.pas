unit GenRndValsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls,
  StdCtrls, Globals, MainUnit, DictionaryUnit;

type

  TDistType = (dtUnknown, dtFlatInt, dtFlatReal, dtNormal, dtChiSq, dtF);

  { TGenRndValsFrm }

  TGenRndValsFrm = class(TForm)
    Bevel1: TBevel;
    GroupBox1: TGroupBox;
    NoCasesEdit: TEdit;
    Label11: TLabel;
    Panel1: TPanel;
    rbFDistributionValues: TRadioButton;
    rbChiSquaredValues: TRadioButton;
    rbNormalZValues: TRadioButton;
    rbFlatInteger: TRadioButton;
    rbFlatFloatingPoint: TRadioButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    ChiDFEdit: TEdit;
    FDF2Edit: TEdit;
    FDF1Edit: TEdit;
    FDF2Label: TLabel;
    ChiSqDFLabel: TLabel;
    FDF1Label: TLabel;
    zSDEdit: TEdit;
    zMeanEdit: TEdit;
    HiRealEdit: TEdit;
    AndRealLabel: TLabel;
    MeanLabel: TLabel;
    SDLabel: TLabel;
    LowRealEdit: TEdit;
    LowRealLabel: TLabel;
    LowIntEdit: TEdit;
    HiIntEdit: TEdit;
    LowIntLabel: TLabel;
    AndIntLabel: TLabel;
    LabelEdit: TEdit;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FDF1EditKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LowIntEditKeyPress(Sender: TObject; var Key: char);
    procedure LowRealEditKeyPress(Sender: TObject; var Key: char);
    procedure NoCasesEditExit(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure DistTypeChange(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure zMeanEditKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
    Ncases: integer;
    DistType: TDistType;
    function Validate(out AMsg: String; out AControl: TWinControl): boolean;
  public
    { public declarations }
  end; 

var
  GenRndValsFrm: TGenRndValsFrm;

implementation

uses
  Math;

{ TGenRndValsFrm }

procedure TGenRndValsFrm.RadioGroup1Click(Sender: TObject);
begin
  (*
  if RadioGroup1.ItemIndex = 1 then
  begin
    if NoCases <= 0 then
    begin
      MessageDlg('There are currently no cases!', mtError, [mbOK], 0);
      exit;
    end
    else
      Ncases := NoCases
  end else
    NoCasesEdit.SetFocus;
    *)
end;

procedure TGenRndValsFrm.LowIntEditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then HiIntEdit.SetFocus;
end;

procedure TGenRndValsFrm.FDF1EditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then FDF2Edit.SetFocus;
end;

procedure TGenRndValsFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TGenRndValsFrm.ComputeBtnClick(Sender: TObject);
var
  i, j : integer;
  col : integer;
  RndNo : integer;
  RealRnd : double;
  Range : integer;
  MinReal, MaxReal : double;
  Mean, StdDev : double;
  SumX1, SumX2 : double;
  df1, df2 : integer;
  C: TWinControl;
  msg: String;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    exit;
  end;

  if (RadioGroup1.ItemIndex = 1) then
    if NoCases < Ncases then
    begin
      OS3MainFrm.DataGrid.RowCount := NCases + 1;
      OS3MainFrm.NoCasesEdit.Text := IntToStr(NCases);
      NoCases := Ncases;
    end;

  if NoCases <= 0 then
  begin
    MessageDlg('There are currently no cases.', mtError, [mbOK], 0);
    exit;
  end;

  DictionaryFrm.DictGrid.ColCount := 8;
  if NoVariables <= 0 then // a new data file
  begin
    OS3MainFrm.DataGrid.ColCount := 2;
    for i := 1 to Ncases do
      OS3MainFrm.DataGrid.Cells[0,i] := Format('Case %d',[i]);
    col := 1;
    DictionaryFrm.DictGrid.RowCount := 1;
    DictionaryFrm.NewVar(col);
    DictionaryFrm.DictGrid.Cells[1,col] := LabelEdit.Text;
    OS3MainFrm.DataGrid.Cells[col,0] := LabelEdit.Text;
  end
  else // existing data file
  begin
    col := NoVariables + 1;
    DictionaryFrm.NewVar(col);
    DictionaryFrm.DictGrid.Cells[1,col] := LabelEdit.Text;
    OS3MainFrm.DataGrid.Cells[col,0] := LabelEdit.Text;
  end;

  Randomize;

  case DistType of
    dtFlatInt:
      begin // range of integers
        Range := StrToInt(HiIntEdit.Text) - StrToInt(LowIntEdit.Text);
        for i := 1 to Ncases do
        begin
          RndNo := random(Range);
          RndNo := RndNo + StrToInt(LowIntEdit.Text);
          OS3MainFrm.DataGrid.Cells[col,i] := IntToStr(RndNo);
        end;
      end;
    dtFlatReal:
      begin // range of real random numbers
        MinReal := StrToFloat(LowRealEdit.Text);
        MaxReal := StrToFloat(HiRealEdit.Text);
        Range := round(MaxReal - MinReal);
        for i := 1 to Ncases do
        begin
          RealRnd := random;
          RndNo := random(Range);
          RealRnd := RndNo + RealRnd + MinReal;
          OS3MainFrm.DataGrid.Cells[col,i] := format('%.3f',[RealRnd]);
        end;
      end;
    dtNormal:
      begin // normally distributed z score
        Mean := StrToFloat(zMeanEdit.Text);
        StdDev := StrToFloat(zSDEdit.Text);
        for i := 1 to Ncases do
        begin
          RealRnd := RandG(Mean, StdDev);
          OS3MainFrm.DataGrid.Cells[col,i] := format('%.3f',[RealRnd]);
        end;
      end;
    dtChiSq:
      begin // Chi square is a sum of df squared normally distributed z scores
        df1 := StrToInt(ChiDFEdit.Text);
        for i := 1 to Ncases do
        begin
          SumX1 := 0.0;
          for j := 1 to df1 do
          begin
            RealRnd := RandG(0.0, 1.0);
            SumX1 := SumX1 + sqr(RealRnd);
          end;
          OS3MainFrm.DataGrid.Cells[col,i] := format('%.3f', [SumX1]);
        end;
      end;
    dtF:
      begin   // F ratio is a ratio of two independent chi-squares
        df1 := StrToInt(FDF1Edit.Text);
        df2 := StrToInt(FDF2Edit.Text);
        for i := 1 to Ncases do
        begin
          SumX1 := 0.0;
          SumX2 := 0.0;
          for j := 1 to df1 do
          begin
            RealRnd := RandG(0.0, 1.0);
            SumX1 := SumX1 + sqr(RealRnd);
          end;
          for j := 1 to df2 do
          begin
            RealRnd := RandG(0.0, 1.0);
            SumX2 := SumX2 + sqr(RealRnd);
          end;
          RealRnd := SumX1 / SumX2;
          OS3MainFrm.DataGrid.Cells[col,i] := format('%.3f',[RealRnd]);
        end;
      end;
  end;

  NoVariables := col;
  OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
  OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);

  MessageDlg(Format('%d random cases added to grid.', [NCases]), mtInformation, [mbOK], 0);
end;

procedure TGenRndValsFrm.FormShow(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  ResetBtnClick(self);
end;

procedure TGenRndValsFrm.LowRealEditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then HiRealEdit.SetFocus;
end;

procedure TGenRndValsFrm.NoCasesEditExit(Sender: TObject);
begin
  if RadioGroup1.ItemIndex = 1 then Ncases := StrToInt(NoCasesEdit.Text);
end;

procedure TGenRndValsFrm.DistTypeChange(Sender: TObject);
var
  i: Integer;
  selTag: Integer;
begin
  if (Sender = nil) then
  begin
    DistType := dtUnknown;
    selTag := -1;
  end else
  begin
    DistType := TDistType((Sender as TRadioButton).Tag);
    selTag := (Sender as TRadioButton).Tag;
  end;

  for i := 0 to GroupBox1.ControlCount-1 do
    if not (GroupBox1.Controls[i] is TRadioButton) then
      GroupBox1.Controls[i].Enabled := GroupBox1.Controls[i].Tag = selTag;

  case DistType of
    dtFlatInt:
      LowIntEdit.SetFocus;
    dtFlatReal:
      LowRealEdit.SetFocus;
    dtNormal:
      zMeanEdit.SetFocus;
    dtChiSq:
      ChiDFEdit.SetFocus;
    dtF:
      FDF1Edit.SetFocus;
    dtUnknown:
      ;
    {
      begin
        MessageDlg('Please select a distribution type before pressing Compute.', mtError, [mbOK], 0);
        exit;
      end;
      }
    else
      raise Exception.Create('Unsupported distribution type.');
  end;
end;

procedure TGenRndValsFrm.ResetBtnClick(Sender: TObject);
begin
  NoCasesEdit.Text := '';

  RadioGroup1.ItemIndex := -1;
  rbFlatInteger.Checked := false;
  rbFlatFloatingPoint.Checked := false;
  rbNormalZValues.Checked := false;
  rbChiSquaredValues.Checked := false;
  rbFDistributionValues.Checked := false;

  LabelEdit.Text := '';
  LowIntEdit.Text := '';
  HiIntEdit.Text := '';
  LowRealEdit.Text := '';
  HiRealEdit.Text := '';
  zMeanEdit.Text := '';
  zSDEdit.Text := '';
  ChiDFEdit.Text := '';
  FDF1Edit.Text := '';
  FDF2Edit.Text := '';

  DistType := dtUnknown;
  DistTypeChange(nil);
end;

procedure TGenRndValsFrm.zMeanEditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then zSDEdit.SetFocus;
end;

function TGenRndvalsFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
  n: Integer;
begin
  Result := false;

  if LabelEdit.Text = '' then
  begin
    AControl := LabelEdit;
    AMsg := 'Enter a label for the variable.';
    exit;
  end;

  if RadioGroup1.ItemIndex < 0 then
  begin
    AControl := RadioGroup1;
    AMsg := 'Select an option for the number of values to generate.';
    exit;
  end;

  if (RadioGroup1.ItemIndex = 1) then
  begin
    if (NoCasesEdit.Text = '') then
    begin
      AControl := NoCasesEdit;
      AMsg := 'Number of cases not specified.';
      exit;
    end;
    if not TryStrToInt(NoCasesEdit.Text, NCases) or (NCases <= 0) then
    begin
      AControl := NoCasesEdit;
      AMsg := 'Valid positive number required.';
      exit;
    end;
  end;

  case DistType of
    dtUnknown:
      begin
        AControl := GroupBox1;
        AMsg := 'Select a distribution type.';
        exit;
      end;

    dtFlatInt:
      begin
        if (LowIntEdit.Text = '') or (HiIntEdit.Text = '') then
        begin
          if LowIntEdit.Text = '' then
            AControl := LowIntEdit
          else
            AControl := HiIntEdit;
          AMsg := 'Value required.';
          exit;
        end;
        if not TryStrToInt(LowIntEdit.Text, n) then
        begin
          AControl := LowIntEdit;
          AMsg := 'Valid integer number required.';
          exit;
        end;
        if not TryStrToInt(HiIntEdit.Text, n) then
        begin
          AControl := HiIntEdit;
          AMsg := 'Valid integer number required.';
          exit;
        end;
      end;

    dtFlatReal:
      begin
        if (LowRealEdit.Text = '') or (HiRealEdit.Text = '') then
        begin
          if LowRealEdit.Text = '' then
            AControl := LowRealEdit
          else
            AControl := HiRealEdit;
          AMsg := 'Value required.';
          exit;
        end;
        if not TryStrToFloat(LowRealEdit.Text, x) then
        begin
          AControl := LowRealEdit;
          AMsg := 'Valid number required.';
          exit;
        end;
        if not TryStrToFloat(HiRealEdit.Text, x) then
        begin
          AControl := HiRealEdit;
          AMsg := 'Valid number required.';
          exit;
        end;
      end;

    dtNormal:
      begin
        if (zMeanEdit.Text = '') or (zSDEdit.Text = '') then
        begin
          if zMeanEdit.Text = '' then
            AControl := zMeanEdit
          else
            AControl := zSDEdit;
          AMsg := 'Value required.';
          exit;
        end;
        if not TryStrToFloat(zMeanEdit.Text, x) then
        begin
          AControl := zMeanEdit;
          AMsg := 'Valid number required.';
          exit;
        end;
        if not TryStrToFloat(zSDEdit.Text, x) or (x <= 0) then
        begin
          AControl := zSDEdit;
          AMsg := 'Valid positive number required.';
          exit;
        end;
      end;

    dtChiSq:
      begin
        if (ChiDFEdit.Text = '') then
        begin
          AControl := ChiDFEdit;
          AMsg := 'Value required.';
          exit;
        end;
        if not TryStrToInt(ChiDFEdit.Text, n) or (n <= 0)then
        begin
          AControl := ChiDFEdit;
          AMsg := 'Valid positive number required.';
          exit;
        end;
      end;

    dtF:
      begin
        if (FDF1Edit.Text = '') or (FDF2Edit.Text = '') then
        begin
          if (FDF1Edit.Text = '') then
            AControl := FDF1Edit
          else
            AControl := FDF2Edit;
          AMsg := 'Value required.';
          exit;
        end;
        if not TryStrToInt(FDF1Edit.Text, n) or (n <= 0)then
        begin
          AControl := FDF1Edit;
          AMsg := 'Valid positive number required.';
          exit;
        end;
        if not TryStrToInt(FDF2Edit.Text, n) or (n <= 0)then
        begin
          AControl := FDF2Edit;
          AMsg := 'Valid positive number required.';
          exit;
        end;
      end;
  end;

  Result := true;
end;

initialization
  {$I genrndvalsunit.lrs}

end.

