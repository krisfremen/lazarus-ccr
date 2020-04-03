unit CoxRegUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Globals, MainUnit, OutputUnit;


type

  { TCoxRegFrm }

  TCoxRegFrm = class(TForm)
    Bevel1: TBevel;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    StatusInBtn: TBitBtn;
    StatusOutBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DescChk: TCheckBox;
    MaxItsEdit: TEdit;
    Label5: TLabel;
    ProbsChk: TCheckBox;
    ItersChk: TCheckBox;
    DepVar: TEdit;
    GroupBox1: TGroupBox;
    StatusEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    BlockList: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInBtnClick(Sender: TObject);
    procedure DepOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure StatusInBtnClick(Sender: TObject);
    procedure StatusOutBtnClick(Sender: TObject);
    function ChiSq(x : double; n : integer) : double;
    function Norm(z : double): double;
    function ix(j, k, nCols : integer): integer;
    procedure VarListSelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  CoxRegFrm: TCoxRegFrm;

implementation

uses
  Math;

{ TCoxRegFrm }

procedure TCoxRegFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  BlockList.Clear;
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  ProbsChk.Checked := true;
  DescChk.Checked := true;
  DepVar.Text := '';
  StatusEdit.Text := '';
  MaxItsEdit.Text := '20';
end;

procedure TCoxRegFrm.StatusInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (StatusEdit.Text = '') then
  begin
    StatusEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TCoxRegFrm.StatusOutBtnClick(Sender: TObject);
begin
  if (StatusEdit.Text <> '') then
  begin
    VarList.Items.Add(StatusEdit.Text);
    StatusEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TCoxRegFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TCoxRegFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TCoxRegFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TCoxRegFrm.DepInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepVar.Text = '') then
  begin
    DepVar.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TCoxRegFrm.DepOutBtnClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TCoxRegFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k    : integer;
   indx       : integer;
   cellstring : string;
   outline    : string;
   nR         : integer; // no. independent variables
   ColNoSelected : IntDyneVec;
   nC         : integer; // no. cases
   nP         : integer; // survival time variable
   nS         : integer; // survival status variable
   zX         : double;
   v          : double;
   Eps        : double;
   iBig       : integer;
   LLp, LL    : double;
   LLn        : double;
   s0         : double;
   StatI      : double;
   Sf         : double;
   RowLabels, ColLabels : StrDyneVec;
   CSq        : double; // chi square statistic
   prob       : double; // probability of chi square
   SurvT      : DblDyneVec;
   Stat       : DblDyneVec;
   Dupl       : DblDyneVec;
   Alpha      : DblDyneVec;
   a          : DblDyneVec;
   b          : DblDyneVec;
   s1         : DblDyneVec;
   s2         : DblDyneVec;
   s          : DblDyneVec;
   Av         : DblDyneVec;
   SD         : DblDyneVec;
   SE         : DblDyneVec;
   x          : DblDyneVec; // data matrix for independent variables
   Lo95       : double;
   Hi95       : double;
   d          : double;
   iters      : integer;
   lReport: TStrings;

begin
  if MaxItsEdit.Text = '' then
  begin
    MaxItsEdit.Setfocus;
    MessageDlg('Maximum iterations not specified.', mtError, [mbOK], 0);
    exit;
  end;

  if not TryStrToInt(MaxItsEdit.Text, iters) then
  begin
    MaxItsEdit.SetFocus;
    MessageDlg('Valid number required.', mtError, [mbOK], 0);
    exit;
  end;

  { get independent item columns }
  nR := BlockList.Items.Count;
  nC := NoCases;
  SetLength(ColNoSelected,nR + 2);
  SetLength(RowLabels,nR + 2);
  SetLength(ColLabels,nR + 2);
  if nR < 1 then
  begin
      MessageDlg('No independent variables selected.', mtError, [mbOK], 0);
      exit;
  end;

  for i := 1 to nR do
  begin
     cellstring := BlockList.Items.Strings[i-1];
     for j := 1 to NoVariables do
     begin
          if cellstring = OS3MainFrm.DataGrid.Cells[j,0] then
          begin
              ColNoSelected[i-1] := j;
              RowLabels[i-1] := cellstring;
              ColLabels[i-1] := cellstring;
          end;
     end;
  end;

  { get survival time variable column and survival status var. column }
  if DepVar.Text = '' then
  begin
     MessageDlg('No Survival time variable selected.', mtError, [mbOK], 0);
     exit;
  end;
  if StatusEdit.Text = '' then
  begin
      MessageDlg('No Survival Status variable selected.', mtError, [mbOK], 0);
      exit;
  end;
  nP := nR + 1;
  nS := nP + 1;
  for j := 1 to NoVariables do
  begin
     if DepVar.Text = OS3MainFrm.DataGrid.Cells[j,0] then
     begin
         ColNoSelected[nP-1] := j;
         RowLabels[nP-1] := OS3MainFrm.DataGrid.Cells[j,0];
         ColLabels[nP-1] := RowLabels[nP-1];
     end;
     if StatusEdit.Text = OS3MainFrm.DataGrid.Cells[j,0] then
     begin
          ColNoSelected[nS-1] := j;
          RowLabels[nS-1] := OS3MainFrm.DataGrid.Cells[j,0];
          ColLabels[nS-1] := RowLabels[nS-1];
     end;
  end;

  SetLength(SurvT,nC + 1);
  SetLength(Stat,nC + 1);
  SetLength(Dupl,nC + 1);
  SetLength(Alpha,nC + 1);
  SetLength(x,(nC + 1) * (nR + 1));
  SetLength(b,nC + 1);
  SetLength(a,(nR + 1) * (nR + 1));
  SetLength(s1,nR + 1);
  SetLength(s2,(nR + 1) * (nR + 1));
  SetLength(s,nR + 1);
  SetLength(Av,nR + 1);
  SetLength(SD,nR + 1);
  SetLength(SE,nR + 1);

  // get data
  for i := 0 to nC - 1 do
  begin
      indx := ix(i,0,nR+1);
      X[indx] := 1;
      for j := 0 to nR-1 do
      begin
           indx := ColNoSelected[j];
           zX := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[indx,i+1]));
           indx := ix(i,j,nR);
           x[indx] := zX;
           Av[j] := Av[j] + zX;
           SD[j] := SD[j] + (zX * zX);
      end;
      // get survival time
      indx := ColNoSelected[nP-1];
      zX := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[indx,i+1]));
      SurvT[i] := zX;
      // get survival status
      indx := ColNoSelected[nS-1];
      zX := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[indx,i+1]));
      Stat[i] := zX;
  end; // next case i

  // print descriptive statistics
  lReport := TStringList.Create;
  try
    lReport.Add('COX PROPORTIONAL HARARDS SURVIVAL REGRESSION adapted from John C. Pezzullo');
    lReport.Add('Java program at http://members.aol.com/johnp71/prophaz.html');
    lReport.Add('');

    if DescChk.Checked then
    begin
      lReport.Add('Descriptive Statistics');
      lReport.Add('Variable  Label            Average     Std.Dev.');
    end;
    for j := 0 to nR-1 do
    begin
      Av[j] := Av[j] / nC;
      SD[j] := SD[j] / nC;
      SD[j] := sqrt( abs(SD[j] - Av[j] * Av[j]));
      if DescChk.Checked then
        lReport.Add('   %3d %15s %11.4f %11.4f', [j+1, RowLabels[j], Av[j], SD[j]]);
    end;
    lReport.Add('');

    d := 0.0;
    Eps := 1.0 / 1024.0;
    for i := 0 to nC-2 do
    begin
      iBig := i;
      for j := i+1 to nC-1 do
        if (SurvT[j] - Eps * Stat[j]) > (SurvT[iBig]-Eps * Stat[iBig]) then
          iBig := j;
      if iBig <> i then
      begin
        v := SurvT[i];
        SurvT[i] := SurvT[iBig];
        SurvT[iBig] := v;
        v := Stat[i];
        Stat[i] := Stat[iBig];
        Stat[iBig] := v;
        for j := 0 to nR-1 do
        begin
          v := x[ix(i,j,nR)];
          x[ix(i,j,nR)] := x[ix(iBig,j,nR)];
          x[ix(iBig,j,nR)] := v;
        end;
      end;
    end;

    if Stat[0] > 0 then
      Stat[0] := Stat[0] + 2;

    for i := 1 to nC-1 do
    begin
      if (Stat[i] > 0) and ((Stat[i-1] = 0) or (SurvT[i-1] <> SurvT[i])) then
           Stat[i] := Stat[i] + 2;
    end;
    if Stat[nC-1] > 0 then
      Stat[nC-1] := Stat[nC-1] + 4;

    for i := nC-2 downto 0 do
    begin
      if (Stat[i] > 0) and ((Stat[i+1] = 0) or (SurvT[i+1] <> Survt[i])) then
           Stat[i] := Stat[i] + 4;
    end;

    for i := 0 to nC-1 do
    begin
      for j := 0 to nR-1 do
      begin
           x[ix(i,j,nR)] := (x[ix(i,j,nR)] - Av[j]) / SD[j];
      end;
    end;

    if ItersChk.Checked then
      lReport.Add('Iteration History...');

    for j := 0 to nR-1 do b[j] := 0;
    LLp := 2.0e30;
    LL := 1.0e30;

    // start iterations
    iters := 0;
    while (Abs(LLp-LL) > 0.0001) do
    begin
      iters := iters + 1;
      if iters > StrToInt(MaxItsEdit.Text) then break;
      LLp := LL;
      LL := 0.0;
      s0 := 0.0;
      for j := 0 to nR-1 do
      begin
           s1[j] := 0.0;
           a[ix(j,nR,nR+1)] := 0.0;
           for k := 0 to nR-1 do
           begin
                s2[ix(j,k,nR)] := 0.0;
                a[ix(j,k,nR+1)] := 0.0;
           end;
      end;
      for i := 0 to nC-1 do
      begin
           Alpha[i] := 1.0;
           v := 0.0;
           for j := 0 to nR-1 do v := v + b[j] * x[ix(i,j,nR)];
           v := exp(v);
           s0 := s0 + v;
           for j := 0 to nR-1 do
           begin
                s1[j] := s1[j] + x[ix(i,j,nR)] * v;
                for k := 0 to nR-1 do
                    s2[ix(j,k,nR)] := s2[ix(j,k,nR)] + x[ix(i,j,nR)] * x[ix(i,k,nR)] * v;
           end;
           StatI := Stat[i];
           if (StatI = 2) or (StatI = 3) or (StatI = 6) or (StatI = 7) then
           begin
                d := 0.0;
                for j := 0 to nR-1 do s[j] := 0.0;
           end;
           if (StatI = 1) or (StatI = 3) or (StatI = 5) or (StatI = 7) then
           begin
                d := d + 1;
                for j := 0 to nR-1 do s[j] := s[j] + x[ix(i,j,nR)];
           end;
           if (StatI = 4) or (StatI = 5) or (StatI = 6) or (StatI = 7) then
           begin
                for j := 0 to nR-1 do
                begin
                     LL := LL + s[j] * b[j];
                     a[ix(j,nR,nR+1)] := a[ix(j,nR,nR+1)] + s[j] - d * s1[j] / s0;
                     for k := 0 to nR-1 do
                     begin
                          a[ix(j,k,nR+1)] := a[ix(j,k,nR+1)] + d * (s2[ix(j,k,nR)] / s0 -
                               s1[j] * s1[k] / (s0 * s0));
                     end;
                end;
                LL := LL - d * Ln(s0);
                if d = 1 then Alpha[i] := Power((1.0 - v / s0),(1.0 / v))
                else Alpha[i] := exp(-d / s0);
           end;
      end;
      LL := -2.0 * LL;
      outline := format('-2 Log Likelihood: %.4f',[LL]);
      if iters = 1 then
      begin
           LLn := LL;
           if ItersChk.Checked then
              outline := outline + ' (Null Model)';
      end;
      if ItersChk.Checked then
         lReport.Add(outline);
      for i := 0 to nR-1 do
      begin
           v := a[ix(i,i,nR+1)];
           a[ix(i,i,nR+1)] := 1.0;
           for k := 0 to nR do
           a[ix(i,k,nR+1)] := a[ix(i,k,nR+1)] / v;
           for j := 0 to nR-1 do
           begin
                if i <> j then
                begin
                     v := a[ix(j,i,nR+1)];
                     a[ix(j,i,nR+1)] := 0.0;
                     for k := 0 to nR do
                         a[ix(j,k,nR+1)] := a[ix(j,k,nR+1)] - v * a[ix(i,k,nR+1)];
                end;
           end;
      end;
      for j := 0 to nR-1 do b[j] := b[j] + a[ix(j,nR,nR+1)];
    end;

    lReport.Add('Converged');
    Csq := LLn - LL;
    lReport.Add('');
    lReport.Add('Overall Model Fit...');
    if Csq > 0.0 then prob := ChiSq(Csq,nR) else prob := 1.0;

    lReport.Add('Chi Square:        %8.4f', [csq]);
    lReport.Add('  with d.f.   %8d', [nR]);
    lReport.Add('  and probability: %8.4f', [prob]);
    lReport.Add('');
    lReport.Add('Coefficients, Std Errs, Signif, and Confidence Intervals');
    lReport.Add('');
    lReport.Add('Var             Coeff.    StdErr       p      Lo95%    Hi95%');
    for j := 0 to nR-1 do
    begin
      b[j] := b[j] / SD[j];
      SE[j] := sqrt(a[ix(j,j,nR+1)]) / SD[j];
      prob := Norm(Abs(b[j] / SE[j]));
      Lo95 := b[j] - 1.96 * SE[j];
      Hi95 := b[j] + 1.96 * SE[j];
      lReport.Add('%10s %10.4f %10.4f %8.4f %8.4f %8.4f',
                  [RowLabels[j], b[j], SE[j], prob, Lo95, Hi95]);
    end;
    lReport.Add('');
    lReport.Add('Risk Ratios and Confidence Intervals');
    lReport.Add('');
    lReport.Add('Variable      Risk Ratio   Lo95%     Hi95%');
    for j := 0 to nR-1 do
      lReport.Add('%10s %10.4f %10.4f %10.4f',
          [RowLabels[j], exp(b[j]), exp(b[j]-1.96*SE[j]), exp(b[j]+1.96*SE[j])]);
    lReport.Add('');
    if ProbsChk.Checked then
      lReport.Add('Baseline Survivor Function (at predictor means)...');
    SF := 1.0;
    for i := nC-1 downto 0 do
    begin
      Sf := Sf * Alpha[i];
      if Alpha[i] < 1.0 then
      begin
           if ProbsChk.Checked then
                lReport.Add('%10.4f %10.4f', [SurvT[i], Sf]);
      end;
    end;

    DisplayReport(lReport);

  finally
    lReport.Free;

    SurvT := nil;
    Stat := nil;
    Dupl := nil;
    Alpha := nil;
    x := nil;
    b := nil;
    a := nil;
    s1 := nil;
    s2 := nil;
    s := nil;
    Av := nil;
    SD := nil;
    SE := nil;
    RowLabels := nil;
    ColLabels := nil;
    ColNoSelected := nil;
  end;
end;

procedure TCoxRegFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
  if VarList.Selected[i] then
  begin
    BlockList.Items.Add(VarList.Items[i]);
    VarList.Items.Delete(i);
    i := 0;
  end else
    i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure TCoxRegFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < BlockList.Items.Count do
  begin
  if BlockList.Selected[i] then
  begin
    VarList.Items.Add(BlockList.Items[i]);
    BlockList.Items.Delete(i);
    i := 0;
  end else
    i := i + 1;
  end;
  UpdateBtnStates;
end;

function TCoxRegFrm.ChiSq(x: double; n: integer): double;
var
  p, t, a: double;
  k: integer;
begin
  p := exp(-0.5 * x);
  if n mod 2 = 1 then
    p := p * sqrt(2 * x / Pi);

  k := n;
  while K >= 2 do
  begin
    p := p * x / k;
    k := k - 2;
  end;

  t := p;
  a := n;
  while t > 0.000001 * p do
  begin
    a := a + 2;
    t := t * x / a;
    p := p + t;
  end;
  Result := (1 - p);
end;

function TCoxRegFrm.Norm(z: double): double;
begin
  Result := ChiSq(z*z, 1);
end;
//-------------------------------------------------------------------

function TCoxRegFrm.ix(j, k, nCols : integer): integer;
begin
  Result := j*nCols + k;
end;

procedure TCoxRegFrm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i := 0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  InBtn.Enabled := lSelected;
  DepInBtn.Enabled := lSelected and (DepVar.Text = '');
  StatusInBtn.Enabled := lSelected and (StatusEdit.Text = '');

  lSelected := false;
  for i := 0 to BlockList.Items.Count-1 do
    if BlockList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;
  DepOutBtn.Enabled := DepVar.Text <> '';
  StatusOutBtn.Enabled := StatusEdit.Text <> '';
end;

procedure TCoxRegFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I coxregunit.lrs}

end.

