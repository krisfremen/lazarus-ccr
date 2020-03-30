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
    ReturnBtn: TButton;
    CancelBtn: TButton;
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
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  BartlettTestForm: TBartlettTestForm;

implementation

uses
  Math;

{ TBartlettTestForm }

procedure TBartlettTestForm.ResetBtnClick(Sender: TObject);
VAR i :integer;
begin
     ChiSqrEdit.Text := '';
     ProbEdit.Text := '';
     DFEdit.Text := '';
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
     VarList.Clear;
     SelList.Clear;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TBartlettTestForm.InBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            SelList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     OutBtn.Enabled := true;
end;

procedure TBartlettTestForm.AllBtnClick(Sender: TObject);
VAR i : integer;
begin
     for i := 0 to VarList.Items.Count-1 do
          SelList.Items.Add(VarList.Items.Strings[i]);
     VarList.Clear;
     OutBtn.Enabled := true;
     InBtn.Enabled := false;
end;

procedure TBartlettTestForm.ComputeBtnClick(Sender: TObject);
VAR
  matrix, temp, eigenvectors : DblDyneMat;
  eigenvalues, means, variances, stddevs : DblDyneVec;
  determinant, chisquare, probability, natlogp : double;
  i, j, df, p, ncases, colno : integer;
  aline, strvalue, ytitle, title, probvalue, chivalue : string;
  ColNoSelected : IntDyneVec;
  dblvalue : double;
  DataGrid : DblDyneMat;
  RowLabels, ColLabels : StrDyneVec;
  errorcode : boolean;
begin
     p := SelList.Count;
     SetLength(matrix,p+1,p+1);
     SetLength(temp,p+1,p+1);
     SetLength(eigenvectors,p,p);
     SetLength(eigenvalues,p);
     SetLength(means,p+1);
     SetLength(stddevs,p+1);
     SetLength(variances,p+1);
     SetLength(ColNoSelected,p+1);
     SetLength(DataGrid,NoCases,p+1);
     SetLength(RowLabels,p+1);
     SetLength(ColLabels,p+1);

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
     ytitle := 'Variable';
     errorcode := false;

     // get data into the datagrid
     for j := 0 to p-1 do
          begin
              for i := 1 to NoCases do
                   begin
                       if not GoodRecord(i,p,ColNoSelected) then continue;
                       colno := ColNoSelected[j];
                       dblvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[colno,i]);
                       DataGrid[i-1,j] := dblvalue;
                       ncases := ncases + 1;
                   end;
          end;
     OutputFrm.RichEdit.Clear;
     ncases := 0;
     Correlations(p,ColNoSelected,matrix,means,variances,stddevs,errorcode,ncases);
     title := 'CORRELATION MATRIX';
     MAT_PRINT(matrix,p,p,title,RowLabels,ColLabels,ncases);
     OutputFrm.RichEdit.Lines.Add('');
     DETERM(matrix,p,p,determinant,errorcode);
     strvalue := format('Determinant of matrix = %8.3f',[determinant]);
     OutputFrm.RichEdit.Lines.Add(strvalue);
     OutputFrm.RichEdit.Lines.Add('');
     natlogp := ln(1.0 / p);
     chisquare := -((ncases-1) - (2.0*p-5)/6) * ln(determinant);
     df := ((p * p) - p) div 2;
     probability := chisquaredprob(chisquare,df);
     chivalue := format('%8.3f',[chisquare]);
     probvalue := format('%8.3f',[1.0-probability]);
     chisqrEdit.Text := chivalue;
     ProbEdit.Text := probvalue;
     DFEdit.Text := IntToStr(df);
     aline := format('chisquare = %s, D.F. = %D, Proabability greater value = %s',
          [chivalue,df,probvalue]);
     OutputFrm.RichEdit.Lines.Add(aline);
     ColLabels := nil;
     RowLabels := nil;
     DataGrid := nil;
     ColNoSelected := nil;
     variances := nil;
     stddevs := nil;
     means := nil;
     eigenvalues := nil;
     eigenvectors := nil;
     temp := nil;
     matrix := nil;
     OutputFrm.ShowModal;
end;

procedure TBartlettTestForm.FormActivate(Sender: TObject);
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
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TBartlettTestForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TBartlettTestForm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TBartlettTestForm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := SelList.ItemIndex;
     VarList.Items.Add(SelList.Items.Strings[index]);
     SelList.Items.Delete(index);
     InBtn.Enabled := true;
     if SelList.Items.Count = 0 then OutBtn.Enabled := false;

end;

initialization
  {$I bartletttestunit.lrs}

end.

