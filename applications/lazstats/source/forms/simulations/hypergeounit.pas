unit HyperGeoUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  FunctionsLib, OutputUnit;

type

  { THyperGeoForm }

  THyperGeoForm = class(TForm)
    Bevel1: TBevel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    SampSizeEdit: TEdit;
    SampObsEdit: TEdit;
    PopSizeEdit: TEdit;
    PopObsEdit: TEdit;
    ProbXEdit: TEdit;
    ProbGTEdit: TEdit;
    ProbLEEdit: TEdit;
    ProbGEEdit: TEdit;
    ProbLTEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure FisherTable(A,B,C,D, p, SumP : double);
  private
    { private declarations }

  public
    { public declarations }
  end; 

var
  HyperGeoForm: THyperGeoForm;

implementation

uses
  Math;

{ THyperGeoForm }

procedure THyperGeoForm.ResetBtnClick(Sender: TObject);
begin
  SampSizeEdit.Text := '';
  SampObsEdit.Text := '';
  PopSizeEdit.Text := '';
  PopObsEdit.Text := '';
  ProbXEdit.Text := '';
  ProbGEEdit.Text := '';
  ProbLTEdit.Text := '';
  ProbLEEdit.Text := '';
  ProbGTEdit.Text := '';
  label5.Enabled := false;
  label6.Enabled := false;
  label7.Enabled := false;
  label8.Enabled := false;
  label9.Enabled := false;
  ProbXEdit.Enabled := false;
  ProbGEEdit.Enabled := false;
  ProbLTEdit.Enabled := false;
  ProbLEEdit.Enabled := false;
  ProbGTEdit.Enabled := false;
end;

procedure THyperGeoForm.ComputeBtnClick(Sender: TObject);
VAR
  SampObs, PopObs, SampSize, PopSize, N : double;
  A, B, C, D, APlusC, BPlusD, APlusB, CPlusD : double;
  ProbX, Prob, SumProb, ProbGE, ProbGT, ProbLT, ProbLE : double;
  done : boolean;
  outvalue : string;
begin
  done := false;
  SumProb := 0.0;
  label5.Enabled := true;
  label6.Enabled := true;
  label7.Enabled := true;
  label8.Enabled := true;
  label9.Enabled := true;
  ProbXEdit.Enabled := true;
  ProbGEEdit.Enabled := true;
  ProbLTEdit.Enabled := true;
  ProbLEEdit.Enabled := true;
  ProbGTEdit.Enabled := true;
  SampObs := StrToFloat(SampObsEdit.Text);
  PopObs := StrToFloat(PopObsEdit.Text);
  SampSize := StrToFloat(SampSizeEdit.Text);
  PopSize := StrToFloat(PopSizeEdit.Text);
  A := SampObs;
  B := SampSize - A;
  C := PopObs;
  D := PopSize - C;
  APlusC := A + C;
  BPlusD := B + D;
  APlusB := A + B;
  CPlusD := C + D;
  N := A + B + C + D;

//  largest := 1;
  OutputFrm.RichEdit.Clear;
  OutputFrm.RichEdit.Lines.Add('Hypergeometric Distribution Calculations');
  OutputFrm.RichEdit.Lines.Add('');
  OutputFrm.RichEdit.Lines.Add('Accumulating Values of the distribution');
  OutputFrm.RichEdit.Lines.Add('');
  ProbX := combos(A,C) * combos(B,D) / combos(APlusB,CPlusD);
  outvalue := format('%6.4f',[ProbX]);
  ProbXEdit.Text := outvalue;
  SumProb := SumProb + ProbX;
  FisherTable(A,B,C,D,ProbX,SumProb);

  // get more extreme probabilities
  while not done do
  begin
           if A = APlusB then done := true
           else begin
             A := A + 1;
             B := B - 1;
             if (A < 0) or (B < 0) or (C < 0) or (D < 0) then done := true;
           end;
    if not done then
    begin
      Prob := combos(A,C) * combos(B,D) / combos(APlusB,CPlusD);
      SumProb := SumProb + Prob;
      FisherTable(A,B,C,D,Prob,SumProb);
    end;
  end; // end while not done
  OutputFrm.ShowModal;
  ProbGE := SumProb;
  ProbGT := SumProb - ProbX;
  ProbLT := 1.0 - ProbGE;
  ProbLE := ProbLT + ProbX;
  outvalue := format('%6.4f',[ProbGE]);
  ProbGEEdit.Text := outvalue;
  outvalue := format('%6.4f',[ProbLE]);
  ProbLEEdit.Text := outvalue;
  outvalue := format('%6.4f',[ProbGT]);
  ProbGTEdit.Text := outvalue;
  outvalue := format('%6.4f',[ProbLT]);
  ProbLTEdit.Text := outvalue;
  OutputFrm.RichEdit.Clear;
end;

procedure THyperGeoForm.FisherTable(A,B,C,D, p, SumP : double);
VAR
  outline : string;
begin
  OutputFrm.RichEdit.Lines.Add('');
  OutputFrm.RichEdit.Lines.Add('Table for Hypergeometric Probabilities');
  OutputFrm.RichEdit.Lines.Add('                 Column');
  OutputFrm.RichEdit.Lines.Add('Row             1           2');
  outline := format(' 1      %10.0f %10.0f',[A,B]);
  OutputFrm.RichEdit.Lines.Add(outline);
  outline := format(' 2      %10.0f %10.0f',[C,D]);
  OutputFrm.RichEdit.Lines.Add(outline);
  outline := format('Probability = %6.4f',[p]);
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.RichEdit.Lines.Add('');
  outline := format('Cumulative Probability = %6.4f',[SumP]);
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.RichEdit.Lines.Add('');
end;

procedure THyperGeoForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure THyperGeoForm.FormCreate(Sender: TObject);
begin
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

initialization
  {$I hypergeounit.lrs}

end.

