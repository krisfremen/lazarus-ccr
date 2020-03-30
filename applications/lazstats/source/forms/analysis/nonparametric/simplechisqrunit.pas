unit SimpleChiSqrUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Grids, ExtCtrls,
  MainUnit, Globals, FunctionsLib, OutputUnit;

type

  { TSimpleChiSqrForm }

  TSimpleChiSqrForm = class(TForm)
    Bevel1: TBevel;
    ComputeBtn: TButton;
    Memo1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    ProbEdit: TEdit;
    Label6: TLabel;
    TotChiSqrEdit: TEdit;
    Label5: TLabel;
    ResetBtn: TButton;
    ReturnBtn: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    NcatsEdit: TEdit;
    Label1: TLabel;
    ObservedGrid: TStringGrid;
    ExpectedGrid: TStringGrid;
    ChiSqrGrid: TStringGrid;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure NcatsEditExit(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    NoCats: integer;
  public
    { public declarations }
  end; 

var
  SimpleChiSqrForm: TSimpleChiSqrForm;

implementation

uses
  Math;

{ TSimpleChiSqrForm }

procedure TSimpleChiSqrForm.NcatsEditExit(Sender: TObject);
begin
     NoCats := StrToInt(NcatsEdit.Text);
     ObservedGrid.RowCount := NoCats+1;
     ExpectedGrid.RowCount := NoCats+1;
     ChiSqrGrid.RowCount := NoCats+1;
end;

procedure TSimpleChiSqrForm.ComputeBtnClick(Sender: TObject);
var
  TotalChiSqr : double;
  ChiSqr, Obs, Exp, ChiProb, NObs, NExp : double;
  i : integer;
  outline : string;
begin
     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Simple Chi-Square Analysis Results');
     OutputFrm.RichEdit.Lines.Add('Category  ChiSquare');
     TotalChiSqr := 0.0;
     NObs := 0.0;
     NExp := 0.0;
     for i := 1 to NoCats do
     begin
          Obs := StrToFloat(ObservedGrid.Cells[0,i]);
          NObs := NObs + 1;
          Exp := StrToFloat(ExpectedGrid.Cells[0,i]);
          NExp := NExp + 1;
          chisqr := sqr(Obs - Exp) / Exp;
          outline := format('%8.3f',[chisqr]);
          ChiSqrGrid.Cells[0,i] := outline;
          TotalChiSqr := TotalChiSqr + chisqr;
          outline := format('    %2d   %8.3f',[i,chisqr]);
          OutputFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.RichEdit.Lines.Add('');
     TotChiSqrEdit.Text := FloatToStr(TotalChiSqr);
     ChiProb := 1.0 - ChiSquaredProb(TotalChiSqr,NoCats);
     ProbEdit.Text := FloatToStr(ChiProb);
     outline := format('Number Observed = %8.3f',[NObs]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('Number Expected = %8.3f',[NExp]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('ChiSquare = %8.3f with Probability of a larger value = %8.3f',
        [TotalChiSqr,ChiProb]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
end;

procedure TSimpleChiSqrForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  FAutoSized := true;
end;

procedure TSimpleChiSqrForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TSimpleChiSqrForm.FormResize(Sender: TObject);
var
  w: Integer;
  dist: Integer;
begin
  dist := ObservedGrid.BorderSpacing.Left + ChiSqrGrid.BorderSpacing.Right;
  w := Width div 3 - dist;
  ObservedGrid.Width := w;
  ExpectedGrid.Width := w;
  ChiSqrGrid.Width := w;
end;

procedure TSimpleChiSqrForm.ResetBtnClick(Sender: TObject);
begin
  NoCats := 1;
  ObservedGrid.RowCount := NoCats + 1;
  ExpectedGrid.RowCount := NoCats + 1;
  ChiSqrGrid.RowCount := NoCats + 1;
  NCatsEdit.Text := '1';
  ObservedGrid.Cells[0,0] := 'Observed';
  ExpectedGrid.Cells[0,0] := 'Expected';
  ChiSqrGrid.Cells[0,0] := 'ChiSquared';
end;

initialization
  {$I simplechisqrunit.lrs}

end.

