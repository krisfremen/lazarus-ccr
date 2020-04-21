unit BartlettTestUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit, DataProcs,
  MatrixLib, ContextHelpUnit;

type

  { TBartlettTestForm }

  TBartlettTestForm = class(TForm)
    AllBtn: TBitBtn;
    Bevel1: TBevel;
    Memo1: TLabel;
    Panel1: TPanel;
    CloseBtn: TButton;
    ChiSqrEdit: TEdit;
    DFEdit: TEdit;
    Label5: TLabel;
    ProbEdit: TEdit;
    HelpBtn: TButton;
    InBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ComputeBtn: TButton;
    OutBtn: TBitBtn;
    ResetBtn: TButton;
    SelList: TListBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
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
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  BartlettTestForm: TBartlettTestForm;

implementation

uses
  Math, Utils;

{ TBartlettTestForm }

procedure TBartlettTestForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  ChiSqrEdit.Text := '';
  ProbEdit.Text := '';
  DFEdit.Text := '';
  VarList.Clear;
  SelList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TBartlettTestForm.InBtnClick(Sender: TObject);
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

procedure TBartlettTestForm.AllBtnClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to VarList.Items.Count-1 do
    SelList.Items.Add(VarList.Items[i]);
  VarList.Clear;
  UpdateBtnStates;
end;

procedure TBartlettTestForm.ComputeBtnClick(Sender: TObject);
VAR
  matrix: DblDyneMat;
  means, variances, stddevs: DblDyneVec;
  determinant, chisquare, probability: double;
  i, j, df, p, ncases, colno: integer;
  title: string;
  ColNoSelected: IntDyneVec;
  dblvalue: double;
  DataGrid: DblDyneMat;
  RowLabels, ColLabels: StrDyneVec;
  errorcode: boolean;
  lReport: TStrings;
begin
  p := SelList.Count;
  SetLength(matrix, p+1, p+1);
  SetLength(means, p+1);
  SetLength(stddevs, p+1);
  SetLength(variances, p+1);
  SetLength(ColNoSelected, p+1);
  SetLength(DataGrid, NoCases, p+1);
  SetLength(RowLabels, p+1);
  SetLength(ColLabels, p+1);

  for j := 0 to p-1 do
  begin
    for i := 1 to NoVariables do
    begin
      if SelList.Items.Strings[j] = OS3MainFrm.DataGrid.Cells[i,0] then
      begin
        ColNoSelected[j] := i;
        RowLabels[j] := OS3MainFrm.DataGrid.Cells[i,0];
        ColLabels[j] := OS3MainFrm.DataGrid.Cells[i,0];
      end;
    end;
  end;

  ncases := 0;
  errorcode := false;

  // get data into the datagrid
  for j := 0 to p-1 do
  begin
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i, p, ColNoSelected) then continue;
      colno := ColNoSelected[j];
      dblvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[colno, i]);
      DataGrid[i-1,j] := dblvalue;
      ncases := ncases + 1;
    end;
  end;

  lReport := TStringList.Create;
  try
    ncases := 0;
    Correlations(p, ColNoSelected, matrix, means, variances, stddevs, errorcode, ncases);

    title := 'CORRELATION MATRIX';
    MatPrint(matrix, p, p, title, RowLabels, ColLabels, ncases, lReport);
    lReport.Add('');

    Determ(matrix, p, p, determinant, errorcode);
    lReport.Add('Determinant of matrix: %8.3f', [determinant]);
    lReport.Add('');

    chisquare := -((ncases-1) - (2.0*p-5)/6) * ln(determinant);
    df := ((p * p) - p) div 2;
    probability := chisquaredprob(chisquare,df);

    //chivalue := format('%8.3f',[chisquare]);
    ChiSqrEdit.Text := Format('%.3f', [chisquare]);;
    ProbEdit.Text := Format('%.3f', [1.0-probability]);
    DFEdit.Text := IntToStr(df);

    lReport.Add('ChiSquare:             %8.3f', [chisquare]);
    lReport.Add('Degrees of Freedom:    %8d', [df]);
    lReport.Add('Probability > value:   %8.3f', [1.0 - probability]);

    DisplayReport(lReport);

  finally
    lReport.Free;
    ColLabels := nil;
    RowLabels := nil;
    DataGrid := nil;
    ColNoSelected := nil;
    variances := nil;
    stddevs := nil;
    means := nil;
    matrix := nil;
  end;
end;

procedure TBartlettTestForm.FormActivate(Sender: TObject);
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

  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TBartlettTestForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TBartlettTestForm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TBartlettTestForm.OutBtnClick(Sender: TObject);
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
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TBartlettTestForm.UpdateBtnStates;
begin
  InBtn.Enabled := AnySelected(VarList);
  OutBtn.Enabled := AnySelected(SelList);
  AllBtn.Enabled := VarList.Items.Count > 0;
end;

procedure TBartlettTestForm.VarListSelectionChange(Sender: TObject;
  User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I bartletttestunit.lrs}

end.

