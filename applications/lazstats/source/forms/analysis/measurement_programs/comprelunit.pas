unit CompRelUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, Globals, DataProcs, MatrixLib,
  DictionaryUnit, ContextHelpUnit;

type

  { TCompRelFrm }

  TCompRelFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    AllBtn: TBitBtn;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    RMatChk: TCheckBox;
    GridScrChk: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    ItemList: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    WeightList: TListBox;
    RelList: TListBox;
    VarList: TListBox;
    procedure AllBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure RelListClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure WeightListClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  CompRelFrm: TCompRelFrm;

implementation

uses
  Math;
{ TCompRelFrm }

procedure TCompRelFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     ItemList.Clear;
     RelList.Clear;
     WeightList.Clear;
     OutBtn.Enabled := false;
     InBtn.Enabled := true;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TCompRelFrm.WeightListClick(Sender: TObject);
var
   response : string;
   index : integer;
begin
     response := InputBox('Test Weight','Test weight = ','1.0');
     index := WeightList.ItemIndex;
     WeightList.Items.Strings[index] := response;
end;

procedure TCompRelFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  w := Max(Label1.Width, Label3.Width);
  VarList.Constraints.MinWidth := w;
  ItemList.constraints.MinWidth := w;
  RelList.Constraints.MinWidth := w;
  WeightList.Constraints.MinWidth := 2;

  //AutoSize := false;
  Constraints.MinHeight := Height;
  Width := 4 * w + AllBtn.Width + 6 * VarList.BorderSpacing.Left;
  Constraints.MinWidth := Width;

  FAutoSized := True;
end;

procedure TCompRelFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TCompRelFrm.FormResize(Sender: TObject);
var
  w: Integer;
begin
  w := (Width - AllBtn.Width - 6*VarList.BorderSpacing.Left) div 4;
  VarList.Width := w;
  ItemList.Width := w;
  RelList.Width := w;
  WeightList.Width := w;
end;

procedure TCompRelFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TCompRelFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContexthelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TCompRelFrm.AllBtnClick(Sender: TObject);
var
   i, count : integer;
   cellstring : string;
begin
     count := VarList.Items.Count;
     for i := 1 to count do
     begin
         ItemList.Items.Add(VarList.Items.Strings[i-1]);
         cellstring := '1.0';
         RelList.Items.Add(cellstring);
         WeightList.Items.Add(cellstring);
     end;
     VarList.Clear;
     InBtn.Enabled := false;
     OutBtn.Enabled := true;
end;

procedure TCompRelFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, NoVars, count, col : integer;
   Rmat, RelMat : DblDyneMat;
   Weights, Reliabilities, VectProd, means, variances, stddevs : DblDyneVec;
   CompRel, numerator, denominator, compscore : double;
   colnoselected : IntDyneVec;
   outline, cellstring : string;
   title : string;
   RowLabels : StrDyneVec;
   errorcode : boolean = false;
begin
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);

  SetLength(colnoselected,NoVariables);
  SetLength(Rmat,NoVariables+1,NoVariables+1);
  SetLength(RelMat,NoVariables+1,NoVariables+1);
  SetLength(Weights,NoVariables);
  SetLength(Reliabilities,NoVariables);
  SetLength(VectProd,NoVariables);
  SetLength(means,NoVariables);
  SetLength(variances,NoVariables);
  SetLength(stddevs,NoVariables);
  SetLength(RowLabels,NoVariables);

  OutputFrm.RichEdit.Clear;
  // get variable col. no.s selected
  NoVars := ItemList.Items.Count;
  for i := 1 to NoVars do
  begin
    cellstring := ItemList.Items.Strings[i-1];
    for j := 1 to NoVariables do
    begin
        if (cellstring = OS3MainFrm.DataGrid.Cells[j,0]) then
        begin
             colnoselected[i-1] := j;
             RowLabels[i-1] := cellstring;
        end;
    end;
  end;
  count := NoCases;

  OutputFrm.RichEdit.Lines.Add('Composite Test Reliability');
  OutputFrm.RichEdit.Lines.Add('');
  outline := 'File Analyzed: ' + OS3MainFrm.FileNameEdit.Text;
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.RichEdit.Lines.Add('');
  // get correlation matrix
  Correlations(NoVars,colnoselected,Rmat,means,variances,stddevs,errorcode,count);
  if (errorcode) then
    ShowMessage('ERROR! Zero variance found for a variable.');
  if RmatChk.Checked then
  begin
     title := 'Correlations Among Tests';
     MAT_PRINT(Rmat,NoVars,NoVars,title,RowLabels,RowLabels,count);
     title := 'Means';
     DynVectorPrint(means,NoVars,title,RowLabels,count);
     title := 'Variances';
     DynVectorPrint(variances,NoVars,title,RowLabels,count);
     title := 'Standard Deviations';
     DynVectorPrint(stddevs,NoVars,title,RowLabels,count);
  end;
  for i := 1 to NoVars do
    for j := 1 to NoVars do
        RelMat[i-1,j-1] := Rmat[i-1,j-1];
  for i := 1 to NoVars do
  begin
    Reliabilities[i-1] := StrToFloat(RelList.Items.Strings[i-1]);
    RelMat[i-1,i-1] := Reliabilities[i-1];
    Weights[i-1] := StrToFloat(WeightList.Items.Strings[i-1]);
  end;
  // get numerator and denominator of composite reliability
  for i := 1 to NoVars do VectProd[i-1] := 0.0;
  numerator := 0.0;
  denominator := 0.0;
  for i := 1 to NoVars do
    for j := 1 to NoVars do
        VectProd[i-1] := VectProd[i-1] + (Weights[i-1] * RelMat[j-1,i-1]);
  for i := 1 to NoVars do numerator := numerator + (VectProd[i-1] * Weights[i-1]);

  for i := 1 to NoVars do VectProd[i-1] := 0.0;
  for i := 1 to NoVars do
    for j := 1 to NoVars do
        VectProd[i-1] := VectProd[i-1] + (Weights[i-1] * Rmat[j-1,i-1]);
  for i := 1 to NoVars do denominator := denominator +
    (VectProd[i-1] * Weights[i-1]);
  CompRel := numerator / denominator;
  OutputFrm.RichEdit.Lines.Add('');
  title := 'Test Weights';
  DynVectorPrint(Weights,NoVars,title,RowLabels,count);
  title := 'Test Reliabilities';
  DynVectorPrint(Reliabilities,NoVars,title,RowLabels,count);
  outline := format('Composite reliability = %6.3f',[CompRel]);
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.ShowModal;
  if GridScrChk.Checked then
  begin
     cellstring := 'Composite';
     col := NoVariables + 1;
     DictionaryFrm.NewVar(col);
     DictionaryFrm.DictGrid.Cells[1,col] := cellstring;
     col := NoVariables;
     OS3MainFrm.DataGrid.Cells[col,0] := cellstring;
     col := NoVariables;
     for i := 1 to NoCases do
     begin
           compscore := 0.0;
           if not GoodRecord(i,NoVars,ColNoSelected) then continue;
           for j := 1 to NoVars do
           begin
                compscore := compscore + (Weights[j-1] *
                   StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[colnoselected[j-1],i])));
           end;
           OS3MainFrm.DataGrid.Cells[col,i] := FloatToStr(compscore);
     end;
  end;

  RowLabels := nil;
  stddevs := nil;
  variances := nil;
  means := nil;
  VectProd := nil;
  Reliabilities := nil;
  Weights := nil;
  RelMat := nil;
  Rmat := nil;
  colnoselected := nil;
end;

procedure TCompRelFrm.InBtnClick(Sender: TObject);
var
   index, i : integer;
   cellstring : string;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            ItemList.Items.Add(VarList.Items.Strings[i]);
            cellstring := '1.0';
            RelList.Items.Add(cellstring);
            WeightList.Items.Add(cellstring);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     OutBtn.Enabled := true;
end;

procedure TCompRelFrm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := ItemList.ItemIndex;
     if index < 0 then
     begin
          OutBtn.Enabled := false;
          exit;
     end;
     VarList.Items.Add(ItemList.Items.Strings[index]);
     ItemList.Items.Delete(index);
     RelList.Items.Delete(index);
     WeightList.Items.Delete(index);
end;

procedure TCompRelFrm.RelListClick(Sender: TObject);
var
   response : string;
   index : integer;
begin
     response := InputBox('Reliability','Reliability estimate = ','1.0');
     index := RelList.ItemIndex;
     RelList.Items.Strings[index] := response;
end;

initialization
  {$I comprelunit.lrs}

end.

