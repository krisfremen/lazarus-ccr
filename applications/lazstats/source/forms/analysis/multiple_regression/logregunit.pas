unit LogRegUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Globals, MainUnit, OutputUnit;

type

  { TLogRegFrm }

  TLogRegFrm = class(TForm)
    Bevel1: TBevel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DepInBtn: TBitBtn;
    DepOutBtn: TBitBtn;
    MaxItsEdit: TEdit;
    InBtn: TBitBtn;
    Label4: TLabel;
    OutBtn: TBitBtn;
    DescChk: TCheckBox;
    ProbsChk: TCheckBox;
    ItersChk: TCheckBox;
    DepVar: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BlockList: TListBox;
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
  LogRegFrm: TLogRegFrm;

implementation

uses
  Math;

{ TLogRegFrm }

procedure TLogRegFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     BlockList.Clear;
     VarList.Clear;
     for i := 1 to NoVariables do
     begin
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     end;
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
     DepInBtn.Enabled := true;
     DepOutBtn.Enabled := false;
     ProbsChk.Checked := true;
     DescChk.Checked := true;
     DepVar.Text := '';
     MaxItsEdit.Text := '20';
end;

procedure TLogRegFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TLogRegFrm.InBtnClick(Sender: TObject);
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
    end
    else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TLogRegFrm.DepInBtnClick(Sender: TObject);
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

procedure TLogRegFrm.ComputeBtnClick(Sender: TObject);
var
   i, j, k    : integer;
   cellstring : string;
   outline    : string;
   nR         : integer; // no. independent variables
   ColNoSelected : IntDyneVec;
   nC         : integer; // no. cases
   nP         : integer; // total no. variables
   RowLabels, ColLabels : StrDyneVec;
   nP1        : integer; // total no. variables plus 1
   sY0, sY1   : integer; // sum of cases with dependent of 0 or 1
   sC         : integer; // total count of cases with 0 or 1
   X          : DblDyneVec; // data matrix for independent variables
   Y0, Y1     : DblDyneVec; // data array for dependent data
   xM         : DblDyneVec; // variable means
   xSD        : DblDyneVec; // variable standard deviations
   Par        : DblDyneVec; // work array
   SEP        : DblDyneVec; // work array;
   Arr        : DblDyneVec; // work array;
   indx, indx2, indx3 : integer; // indexes for arrays
   value      : double;
   LLp, LL, LLn : double; // log likelihood
   q          : double; // work values
   xij, s     : double; // work value
   CSq        : double; // chi square statistic
   prob       : double; // probability of chi square
   ORc, OR1, ORh : double; // Odds ratio values
   iters      : integer;
   Table : array[1..3,1..3] of integer;
   row, col : integer;
   maxIts: Integer;
   lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
     lReport.Add('LOGISTIC REGRESSION, adapted from John C. Pezzullo');
     lReport.Add('Java program at http://members.aol.com/johnp71/logistic.html');

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
                  ColNoSelected[i] := j;
                  RowLabels[i] := cellstring;
                  ColLabels[i] := cellstring;
              end;
         end;
     end;

     { get dependendent variable column }
     if DepVar.Text = '' then
     begin
         MessageDlg('No dependent variable selected.', mtError, [mbOK], 0);
         exit;
     end;

     if MaxItsEdit.Text = '' then begin
       MaxItsEdit.Setfocus;
       MessageDlg('Maximum iterations not specified.', mtError, [mbOK], 0);
       exit;
     end;

     if not TryStrToInt(MaxItsEdit.Text, maxIts) then
     begin
       MaxItsEdit.SetFocus;
       MessageDlg('No valid number given for maximum iterations.', mtError, [mbOK], 0);
       exit;
     end;


     nP := nR + 1;
     nP1 := nP + 1;
     for j := 1 to NoVariables do
     begin
         if DepVar.Text = OS3MainFrm.DataGrid.Cells[j,0] then
         begin
             ColNoSelected[nP] := j;
             RowLabels[nP] := OS3MainFrm.DataGrid.Cells[j,0];
             ColLabels[nP] := RowLabels[nP];
         end;
     end;

     sY0 := 0;
     sY1 := 0;
     sC := 0;
     SetLength(X,(nC + 1) * (nR + 1));
     SetLength(Y0,nC + 1);
     SetLength(Y1,nC + 1);
     SetLength(xM,nR + 2);
     SetLength(xSD,nR + 2);
     SetLength(Par,nP + 1);
     SetLength(SEP,nP + 1);
     SetLength(Arr,(nP + 1) * (nP1 + 1));

     // get data
     for i := 0 to nC - 1 do
     begin
          indx := ix(i,0,nR+1);
          X[indx] := 1;
          for j := 1 to nR do
          begin
               indx := ColNoSelected[j];
               value := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[indx,i+1]));
               indx := ix(i,j,nR + 1);
               X[indx] := value;
          end;
          indx := ColNoSelected[nP];
          value := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[indx,i+1]));
          if value = 0 then
          begin
               Y0[i] := 1;
               sY0 := sY0 + 1;
          end
          else begin
               Y1[i] := 1;
               sY1 := sY1 + 1;
          end;
          sC := sC + round(Y0[i] + Y1[i]);
          for j := 1 to nR do
          begin
               indx := ix(i,j,nR + 1);
               value := X[indx];
               xM[j] := xM[j] + (Y0[i] + Y1[i]) * value;
               xSD[j] := xSD[j] + (Y0[i] + Y1[i]) * value * value;
          end;
     end; // next case i

     // print descriptive statistics
     lReport.Add('');
     if DescChk.Checked then
        lReport.Add('Descriptive Statistics');
     lReport.Add('%d cases have Y=0; %d cases have Y=1.', [sY0, sY1]);
     lReport.Add('');
     lReport.Add('Variable  Label            Average     Std.Dev.');
     for j := 1 to nR do
     begin
          xM[j] := xM[j] / sC;
          xSD[j] :=xSD[j] / sC;
          xSD[j] := sqrt( abs(xSD[j] - xM[j] * xM[j]));
          if DescChk.Checked then
               lReport.Add('   %3d %15s %10.4f %10.4f',[j,RowLabels[j],xM[j],xSD[j]]);
     end;
     lReport.Add('------------------------------------------------------------------');
     lReport.Add('');
     xM[0] := 0.0;
     xSD[0] := 1.0;
     //OutputFrm.ShowModal;

     // convert independent variable values to z scores
     for i := 0 to nC - 1 do
     begin
          for j := 1 to nR do
          begin
               indx := ix(i,j,nR + 1);
               X[indx] := (X[indx] - xM[j]) / xSD[j];
          end;
     end;

     // begin iterations
     iters := 0;
     if ItersChk.Checked then
        lReport.Add('Iteration History');
     Par[0] := ln(sY1 / sY0);
     for j := 1 to nR do Par[j] := 0.0;
     LLp := 2e10;
     LL := 1e10;
     while abs(LLp-LL) > 0.00001 do
     begin
          iters := iters + 1;
          if iters > StrToInt(MaxItsEdit.Text) then break;
          LLp := LL;
          LL := 0.0;
          for j := 0 to nR do
          begin
               for k := j to nR + 1 do
               begin
                    indx := ix(j,k,nR+2);
                    Arr[indx] := 0.0;
               end;
          end;
          for i := 0 to nC - 1 do
          begin
               value := Par[0];
               for j := 1 to nR do
               begin
                    indx := ix(i,j,nR + 1);
                    value := value + Par[j] * X[indx];
               end;
               value := 1.0 / (1.0 + exp(-value));
               q := value * (1.0 - value);
               LL := LL - 2.0 * Y1[i] * ln(value) - 2.0 * Y0[i] * ln(1.0 - value);
               for j := 0 to nR do
               begin
                    indx := ix(i,j,nR + 1);
                    xij := X[indx];
                    indx := ix(j,nR + 1, nR + 2);
                    Arr[indx] := Arr[indx] + xij * ( Y1[i] * (1.0 - value) + Y0[i] * (-value));
                    for k := j to nR do
                    begin
                         indx := ix(j,k,nR + 2);
                         indx2 := ix(i,k,nR + 1);
                         Arr[indx] := Arr[indx] + xij * X[indx2] * q * (Y0[i] + Y1[i]);
                    end;
               end; // next j
          end; // next i
          outline := format('-2 Log Likelihood = %10.4f ',[LL]);
          if LLp = 1.0e10 then
          begin
               LLn := LL;
               outline := outline + ' (Null Model)';
          end;
          if ItersChk.Checked then lReport.Add(outline);
          for j := 1 to nR do
          begin
               for k := 0 to j-1 do
               begin
                    indx := ix(j,k,nR + 2);
                    indx2 := ix(k,j,nR + 2);
                    Arr[indx] := Arr[indx2];
               end;
          end;
          for i := 0 to nR do
          begin
               indx := ix(i,i,nR + 2);
               s := Arr[indx];
               Arr[indx] := 1.0;
               for k := 0 to nR + 1 do
               begin
                    indx := ix(i,k,nR + 2);
                    Arr[indx] := Arr[indx] / s;
               end;
               for j := 0 to nR do
               begin
                    if i <> j then
                    begin
                         indx := ix(j,i,nR + 2);
                         s := Arr[indx];
                         Arr[indx] := 0.0;
                         for k := 0 to nR + 1 do
                         begin
                              indx2 := ix(j,k,nR + 2);
                              indx3 := ix(i,k,nR + 2);
                              Arr[indx2] := Arr[indx2] - s * Arr[indx3];
                         end; // next k
                    end; // if i not equal j
               end; // next j
          end; // next i
          for j := 0 to nR do
          begin
               indx := ix(j,nR + 1,nR + 2);
               Par[j] := Par[j] + Arr[indx];
          end;
     end; // iteration
     lReport.Add('Converged');
     lReport.Add('');
     lReport.Add('------------------------------------------------------------------');
     lReport.Add('');

     CSq := LLn - LL;
     prob := ChiSq(CSq,nR);
     lReport.Add('Overall Model Fit... Chi Square = %8.4f with df = %3d and prob. = %8.4f', [Csq, nR, prob]);
     lReport.Add('');
     lReport.Add('Coefficients and Standard Errors...');
     lReport.Add('Variable        Label     Coeff.     StdErr     p');
     for j := 1 to nR do
     begin
          Par[j] := Par[j] / xSD[j];
          indx := ix(j,j,nP + 1);
          SEP[j] := sqrt(Arr[indx]) / xSD[j];
          Par[0] := Par[0] - Par[j] * xM[j];
          prob := Norm(abs(Par[j] / SEP[j]));
          lReport.Add('  %3d %15s %10.4f %10.4f %10.4f', [j, RowLabels[j], Par[j], SEP[j], prob]);
     end;
     lReport.Add('');
//     OutputFrm.ShowModal;

     lReport.Add('Intercept %10.4f', [Par[0]]);
     lReport.Add('');
     lReport.Add('Odds Ratios and 95% Confidence Intervals...');
     lReport.Add('Variable            O.R.       Low   --   High');
     for j := 1 to nR do
     begin
          ORc := exp(Par[j]);
          OR1 := exp(Par[j] - 1.96 * SEP[j]);
          ORh := exp(Par[j] + 1.96 * SEP[j]);
          lReport.Add('%15s %10.4f %10.4f %10.4f', [RowLabels[j], ORc, OR1, ORh]);
     end;
     for i := 1 to 3 do
         for j := 1 to 3 do Table[i,j] := 0;
     lReport.Add('');
     outline := '';
     if ProbsChk.Checked then
     begin
          for j := 1 to nR do outline := outline + '      X     ';
          outline := outline + '   Y       Prob';
          lReport.Add(outline);
          for i := 0 to nC - 1 do
          begin
               value := Par[0];
               outline := '';
               for j := 1 to nR do
               begin
                    indx := ix(i,j,nR + 1);
                    xij := xM[j] + xSD[j] * X[indx];
                    value := value + Par[j] * xij;
                    outline := outline + format(' %10.4f ',[xij]);
               end;
               value := 1.0 / (1.0 + exp( -value));
               outline := outline + format('%4.0f %10.4f',[Y1[i],value]);
               lReport.Add(outline);
               if round(Y1[i]) = 0 then row := 1 else row := 2;
               if round(value) = 0 then col := 1 else col := 2;
               Table[row,col] := Table[row,col] + 1;
          end; // next i
     end;
     for i := 1 to 2 do
     begin
          for j := 1 to 2 do
          begin
               Table[i,3] := Table[i,3] + Table[i,j];
               Table[3,j] := Table[3,j] + Table[i,j];
          end;
     end;
     for i := 1 to 2 do Table[3,3] := Table[3,3] + Table[i,3];
     lReport.Add('');
     lReport.Add('Classification Table');
     lReport.Add('           Predicted');
     lReport.Add('        --------------- ');
     lReport.Add('Observed    0      1     Total');
     lReport.Add('        --------------- ');
     for i := 1 to 2 do
     begin
          outline := format('   %d    ',[i-1]);
          for j := 1 to 3 do outline := outline + format('| %3d  ',[Table[i,j]]);
          outline := outline + '|';
          lReport.Add(outline);
     end;
     lReport.Add('        --------------- ');
     Outline := 'Total   ';
     for j := 1 to 3 do outline := outline + format('| %3d  ',[Table[3,j]]);
     outline := outline + '';
     lReport.Add(outline);
     lReport.Add('        --------------- ');

     DisplayReport(lReport);

  finally
     lReport.Free;
     Arr := nil;
     SEP := nil;
     Par := nil;
     xSD := nil;
     xM := nil;
     Y1 := nil;
     Y0 := nil;
     X := nil;
     RowLabels := nil;
     ColLabels := nil;
     ColNoSelected := nil;
  end;
end;

procedure TLogRegFrm.DepOutBtnClick(Sender: TObject);
begin
  if DepVar.Text <> '' then
  begin
    VarList.Items.Add(DepVar.Text);
    DepVar.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TLogRegFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := OutBtn.Top + OutBtn.Height - VarList.Top;

  Constraints.MinHeight := Height;
  Constraints.MinWidth := MaxItsEdit.Left + MaxItsEdit.Width + MaxItsEdit.BorderSpacing.Right;
//  Constraints.MinWidth := Width;

  FAutoSized := true;
end;

procedure TLogRegFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TLogRegFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TLogRegFrm.OutBtnClick(Sender: TObject);
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
    end
    else
      inc(i);
  end;
  UpdateBtnStates;
end;

function TLogRegFrm.ChiSq(x : double; n : integer) : double;
var
   p, t, a : double;
   k : integer;

begin
     p := exp(-0.5 * x);
     if n mod 2 = 1 then p := p * sqrt(2 * x / Pi);
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
     ChiSq := (1 - p);
end;

function TLogRegFrm.Norm(z : double): double;
begin
     Norm := ChiSq(z * z, 1);
end;

function TLogRegFrm.ix(j, k, nCols : integer): integer;
begin
     ix := j * nCols + k;
end;

procedure TLogRegFrm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i:=0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  DepInBtn.Enabled := lSelected and (DepVar.Text = '');
  InBtn.Enabled := lSelected;
  DepOutBtn.Enabled := DepVar.Text <> '';

  lSelected := false;
  for i := 0 to BlockList.Items.Count-1 do
    if BlockList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;
end;


initialization
  {$I logregunit.lrs}

end.

