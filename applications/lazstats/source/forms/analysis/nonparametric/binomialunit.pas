unit BinomialUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  OutputUnit, FunctionsLib, GraphLib;

type

  { TBinomialFrm }

  TBinomialFrm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    PlotChk: TCheckBox;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    FreqAEdit: TEdit;
    FreqBEdit: TEdit;
    PropAEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
    { private declarations }
  public
    { public declarations }
  end; 

var
  BinomialFrm: TBinomialFrm;

implementation

uses
  Math;

{ TBinomialFrm }

procedure TBinomialFrm.ResetBtnClick(Sender: TObject);
begin
  FreqAEdit.Text := '';
  FreqBEdit.Text := '';
  PropAEdit.Text := '';
  FreqAEdit.SetFocus;
end;

procedure TBinomialFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure TBinomialFrm.FormCreate(Sender: TObject);
begin
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TBinomialFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TBinomialFrm.ComputeBtnClick(Sender: TObject);
var
  p, Q, Probability, z, CorrectedA, SumProb : double;
  A, b, N, X, i: integer;
  lReport: TStrings;
  msg: String;
  C: TWinControl;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError,[mbOK], 0);
    ModalResult := mrNone;
    exit;
  end;

  SumProb := 0.0;
  A := round(StrToFloat(FreqAEdit.Text));
  b := round(StrToFloat(FreqBEdit.Text));
  p := StrToFloat(PropAEdit.Text);
  N := A + b;
  Q := 1.0 - p;

  lReport := TStringList.Create;
  try
    lReport.Add('BINOMIAL PROBABILITY TEST');
    lReport.Add('');
    lReport.Add('Frequency of %d out of %d observed', [A, N]);
    lReport.Add('The theoretical proportion expected in category A is %.3f', [p]);
    lReport.Add('');
    lReport.Add('The test is for the probability of a value in category A as small or smaller');
    lReport.Add('than that observed given the expected proportion.');

    if (N > 35) then //Use normal distribution approximation
    begin
      CorrectedA := A;
      if A < N * p then CorrectedA := A + 0.5;
      if A > N * p then CorrectedA := A - 0.5;
      z := (CorrectedA - N * p) / sqrt(N * p * Q);
      lReport.Add('Z value for Normal Distribution approximation: %.3f', [z]);
      Probability := probz(z);
      lReport.Add('Probability: %.4f', [Probability]);
    end
    else //Use binomial fomula
    begin
      for X := 0 to A do
      begin
        Probability := combos(X, N) * Power(p,X) * Power(Q,(N - X));
        lReport.Add('Probability of %d = %6.4f', [X, Probability]);
        SumProb := SumProb + Probability;
      end;
      lReport.Add('Binomial Probability of %d or less out of %d: %.4f', [A, N, SumProb]);
    end;

    DisplayReport(lReport);
  finally
    lReport.Free;
  end;

  if PlotChk.Checked then
  begin
    if N <= 35 then
    begin
      SetLength(GraphFrm.Xpoints,1,N+1);
      SetLength(GraphFrm.Ypoints,1,N+1);
      for i := 0 to N do
      begin
        GraphFrm.Xpoints[0,i] := i;
        Probability := combos(i,N) * power(p,i) * power(Q,(N-i));
        GraphFrm.Ypoints[0,i] := Probability;
      end;
      GraphFrm.GraphType := 2;
      GraphFrm.nosets := 1;
      GraphFrm.nbars := N;
      GraphFrm.BackColor := clCream;
      GraphFrm.WallColor := clDkGray;
      GraphFrm.FloorColor := clGray;
      GraphFrm.Heading := 'Binomial Distribution';
      GraphFrm.XTitle := 'Values';
      GraphFrm.YTitle := 'Probability';
      GraphFrm.barwideprop := 0.5;
      GraphFrm.AutoScaled := true;
      GraphFrm.ShowLeftWall := true;
      GraphFrm.ShowRightWall := true;
      GraphFrm.ShowBottomWall := true;
      GraphFrm.ShowModal;
      GraphFrm.Xpoints := nil;
      GraphFrm.Ypoints := nil;
    end else
      MessageDlg('Cannot plot for N > 35', mtInformation, [mbOK], 0);
  end;
end;

function TBinomialFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  x: Double;
begin
  Result := false;
  if (FreqAEdit.Text = '') or (FreqBEdit.Text = '') or (PropAEdit.Text = '') then
  begin
    AMsg := 'Value not specified.';
    if FreqAEdit.Text = '' then AControl := FreqAEdit;
    if FreqBEdit.Text = '' then AControl := FreqBEdit;
    if PropAEdit.Text = '' then AControl := PropAEdit;
    exit;
  end;
  if not TryStrToFloat(FreqAEdit.Text, x) then
  begin
    AMsg := 'No valid number.';
    AControl := FreqAEdit;
    exit;
  end;
  if not TryStrToFloat(FreqBEdit.Text, x) then
  begin
    AMsg := 'No valid number.';
    AControl := FreqBEdit;
    exit;
  end;
  if not TryStrToFloat(PropAEdit.Text, x) then
  begin
    AMsg := 'No valid number.';
    AControl := PropAEdit;
    exit;
  end;

  Result := true;
end;

initialization
  {$I binomialunit.lrs}

end.

