unit GenRndValsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls,
  StdCtrls, Globals, MainUnit, DictionaryUnit;

type

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
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    ChiDFEdit: TEdit;
    FDF2Edit: TEdit;
    FDF1Edit: TEdit;
    Label10: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    zSDEdit: TEdit;
    zMeanEdit: TEdit;
    HiRealEdit: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LowRealEdit: TEdit;
    Label4: TLabel;
    LowIntEdit: TEdit;
    HiIntEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
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
    Ncases : integer;
    DistType : integer;
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
    if RadioGroup1.ItemIndex = 1 then
    begin
        if NoCases <= 0 then
        begin
            ShowMessage('Error! There are currently no cases!');
            exit;
        end
        else Ncases := NoCases
    end
    else NoCasesEdit.SetFocus;
end;

procedure TGenRndValsFrm.LowIntEditKeyPress(Sender: TObject; var Key: char);
begin
    if Ord(Key) = 13 then HiIntEdit.SetFocus;
end;

procedure TGenRndValsFrm.FDF1EditKeyPress(Sender: TObject; var Key: char);
begin
    if Ord(Key) = 13 then FDF2Edit.SetFocus;
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
begin
    if LabelEdit.Text = '' then
    begin
        ShowMessage('Error.  Enter a label for the variable.');
        exit;
    end;
    if DistType <= 0 then
    begin
        ShowMessage('First, select a distribution type.');
        exit;
    end;
    if RadioGroup1.ItemIndex < 0 then
    begin
        ShowMessage('Select an option for the number of values to generate.');
        exit;
    end;
    if (RadioGroup1.ItemIndex = 1) and (NoCasesEdit.Text = '') then
    begin
        ShowMessage('Error! Number of cases not specified.');
        exit;
    end
    else Ncases := StrToInt(NoCasesEdit.Text);
    if NoCases < Ncases then
    begin
        OS3MainFrm.DataGrid.RowCount := NCases + 1;
        OS3MainFrm.NoCasesEdit.Text := IntToStr(NCases);
        NoCases := Ncases;
    end;
    DictionaryFrm.DictGrid.ColCount := 8;
    if NoVariables <= 0 then // a new data file
    begin
        OS3MainFrm.DataGrid.ColCount := 2;
        for i := 1 to Ncases do
            OS3MainFrm.DataGrid.Cells[0,i] := format('Case %d',[i]);
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
    randomize;
    case DistType of
    1 : begin // range of integers
            Range := StrToInt(HiIntEdit.Text) - StrToInt(LowIntEdit.Text);
            for i := 1 to Ncases do
            begin
                RndNo := random(Range);
                RndNo := RndNo + StrToInt(LowIntEdit.Text);
                OS3MainFrm.DataGrid.Cells[col,i] := IntToStr(RndNo);
            end;
        end;
    2 : begin // range of real random numbers
            MinReal := StrToFloat(LowRealEdit.Text);
            MaxReal := StrToFloat(HiRealEdit.Text);
            Range := round(MaxReal - MinReal);
            for i := 1 to Ncases do
            begin
                RealRnd := random;
                RndNo := random(Range);
                RealRnd := RndNo + RealRnd + MinReal;
                OS3MainFrm.DataGrid.Cells[col,i] := format('%8.3f',[RealRnd]);
            end;
        end;
    3 : begin // normally distributed z score
            Mean := StrToFloat(zMeanEdit.Text);
            StdDev := StrToFloat(zSDEdit.Text);
            for i := 1 to Ncases do
            begin
                RealRnd := RandG(Mean,StdDev);
                OS3MainFrm.DataGrid.Cells[col,i] := format('%8.3f',[RealRnd]);
            end;
        end;
    4 : begin // Chi square is a sum of df squared normally distributed z scores
            df1 := StrToInt(ChiDFEdit.Text);
            for i := 1 to Ncases do
            begin
                SumX1 := 0.0;
                for j := 1 to df1 do
                begin
                    RealRnd := RandG(0.0,1.0);
                    SumX1 := SumX1 + (RealRnd * RealRnd);
                end;
                OS3MainFrm.DataGrid.Cells[col,i] := format('%8.3f',[SumX1]);
            end;
        end;
    5 : begin   // F ratio is a ratio of two independent chi-squares
            df1 := StrToInt(FDF1Edit.Text);
            df2 := StrToInt(FDF2Edit.Text);
            for i := 1 to Ncases do
            begin
                SumX1 := 0.0;
                SumX2 := 0.0;
                for j := 1 to df1 do
                begin
                    RealRnd := RandG(0.0,1.0);
                    SumX1 := SumX1 + (RealRnd * RealRnd);
                end;
                for j := 1 to df2 do
                begin
                    RealRnd := RandG(0.0,1.0);
                    SumX2 := SumX2 + (RealRnd * RealRnd);
                end;
                RealRnd := SumX1 / SumX2;
                OS3MainFrm.DataGrid.Cells[col,i] := format('%8.3f',[RealRnd]);
            end;
        end;
    end;
    NoVariables := col;
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
    OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
end;

procedure TGenRndValsFrm.FormShow(Sender: TObject);
var
    w: Integer;
begin
    w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
    ResetBtn.Constraints.MinWidth := w;
    CancelBtn.Constraints.MinWidth := w;
    ComputeBtn.Constraints.MinWidth := w;
    ReturnBtn.Constraints.MinWidth := w;

    ResetBtnClick(self);
end;

procedure TGenRndValsFrm.LowRealEditKeyPress(Sender: TObject; var Key: char);
begin
    if Ord(Key) = 13 then HiRealEdit.SetFocus;
end;

procedure TGenRndValsFrm.NoCasesEditExit(Sender: TObject);
begin
    if RadioGroup1.ItemIndex = 1 then Ncases := StrToInt(NoCasesEdit.Text);
end;

procedure TGenRndValsFrm.DistTypeChange(Sender: TObject);
begin
  DistType := (Sender as TRadioButton).Tag;
  case DistType of
  1 : LowIntEdit.SetFocus;
  2 : LowRealEdit.SetFocus;
  3 : zMeanEdit.SetFocus;
  4 : ChiDFEdit.SetFocus;
  5 : FDF1Edit.SetFocus;
  else
      begin
          ShowMessage('Please select a distribution type before pressing Compute.');
          exit;
      end;
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
//    RadioGroup2.ItemIndex := -1;
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
    DistType := 0;
end;

procedure TGenRndValsFrm.zMeanEditKeyPress(Sender: TObject; var Key: char);
begin
    if Ord(Key) = 13 then zSDEdit.SetFocus;
end;

initialization
  {$I genrndvalsunit.lrs}

end.

