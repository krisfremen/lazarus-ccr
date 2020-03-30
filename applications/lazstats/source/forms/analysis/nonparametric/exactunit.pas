unit ExactUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, MainUnit, OutPutUnit, FunctionsLib,
  Globals, DataProcs, Math;

type

  { TFisherFrm }

  TFisherFrm = class(TForm)
    Bevel1: TBevel;
    Label5: TLabel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    RC11Edit: TEdit;
    RC12Edit: TEdit;
    RC21Edit: TEdit;
    RC22Edit: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    NCasesEdit: TEdit;
    NCasesLabel: TLabel;
    Panel2: TPanel;
    RowIn: TBitBtn;
    RowOut: TBitBtn;
    ColIn: TBitBtn;
    ColOut: TBitBtn;
    DepIn: TBitBtn;
    DepOut: TBitBtn;
    ColEdit: TEdit;
    DepEdit: TEdit;
    RowEdit: TEdit;
    InputGrp: TRadioGroup;
    Label1: TLabel;
    RowLabel: TLabel;
    ColLabel: TLabel;
    DepLabel: TLabel;
    VarList: TListBox;
    Panel1: TPanel;
    procedure ColInClick(Sender: TObject);
    procedure ColOutClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure DepInClick(Sender: TObject);
    procedure DepOutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InputGrpClick(Sender: TObject);
    procedure RC11EditKeyPress(Sender: TObject; var Key: char);
    procedure RC12EditKeyPress(Sender: TObject; var Key: char);
    procedure RC21EditKeyPress(Sender: TObject; var Key: char);
    procedure RC22EditKeyPress(Sender: TObject; var Key: char);
    procedure ResetBtnClick(Sender: TObject);
    procedure RowInClick(Sender: TObject);
    procedure RowOutClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure PrintFisherTable(AList: TStrings; A, B, C, D: integer; P, SumP: double);
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  FisherFrm: TFisherFrm;

implementation

{ TFisherFrm }

procedure TFisherFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  RowEdit.Text := '';
  ColEdit.Text := '';
  DepEdit.Text := '';
  DepEdit.Visible := false;
  DepIn.Visible := false;
  DepOut.Visible := false;
  NCasesLabel.Visible := false;
  DepLabel.Visible := false;
  NCasesEdit.Text := '';
  NCasesEdit.Visible := false;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  Panel1.Visible := false;
  Panel2.Visible := false;
  RC11Edit.Text := '';
  RC12Edit.Text := '';
  RC21Edit.Text := '';
  RC22Edit.Text := '';
  UpdateBtnStates;
end;

procedure TFisherFrm.RowInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (RowEdit.Text = '') then
  begin
     RowEdit.Text := VarList.Items[index];
     VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TFisherFrm.RowOutClick(Sender: TObject);
begin
  if RowEdit.Text <> '' then
  begin
    VarList.Items.Add(RowEdit.Text);
    RowEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TFisherFrm.FormActivate(Sender: TObject);
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

procedure TFisherFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TFisherFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TFisherFrm.ColInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (ColEdit.Text = '') then
  begin
     ColEdit.Text := VarList.Items[index];
     VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TFisherFrm.ColOutClick(Sender: TObject);
begin
  if ColEdit.Text <> '' then
  begin
    VarList.Items.Add(ColEdit.Text);
    ColEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TFisherFrm.ComputeBtnClick(Sender: TObject);
var
  i, j, row, col, caserow, casecol, A, B, C, D, Largest: integer;
  N, APlusB, APlusC, BPlusD, CPlusD, NoSelected, dep: integer;
  FirstP, p, SumProb, Tocher, Alpha, X: double;
  obs: array[1..2, 1..2] of integer;
  ColNoSelected: IntDyneVec;
  done, ok: boolean;
  response: string;
  lReport: TStrings;
begin
  Randomize; // initialize random number generator
  row := 0;
  col := 0;
  dep := 0;

  // get column no.s of row and col variables
  if InputGrp.ItemIndex <> 3 then
  begin
    for i := 1 to NoVariables do
    begin
      if RowEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then row := i;
      if ColEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then col := i;
      if InputGrp.ItemIndex = 2 then
      begin
        if DepEdit.Text = OS3MainFrm.DataGrid.Cells[i,0] then dep := i;
      end;
    end;
  end;

  SetLength(ColNoSelected,3);
  ColNoSelected[0] := row;
  ColNoSelected[1] := col;
  if InputGrp.ItemIndex = 2 then
  begin
    ColNoSelected[2] := dep;
    NoSelected := 3;
  end else
    NoSelected := 2;

  //initialize observed matrix
  for i := 1 to 2 do
    for j := 1 to 2 do obs[i,j] := 0;

  if InputGrp.ItemIndex = 3 then // get freq. from form
  begin
    if (RC11Edit.Text = '') or not TryStrToInt(RC11Edit.Text, obs[1, 1]) then
    begin
      RC11Edit.SetFocus;
      MessageDlg('No valid input.', mtError, [mbOK], 0);
      exit;
    end;
    if (RC12Edit.Text = '') or not TryStrToInt(RC12Edit.Text, obs[1, 2]) then
    begin
      RC12Edit.SetFocus;
      MessageDlg('No valid input', mtError, [mbOK], 0);
      exit;
    end;
    if (RC21Edit.Text = '') or not TryStrToInt(RC21Edit.Text, obs[2, 1]) then
    begin
      RC21Edit.SetFocus;
      MessageDlg('No valid input.', mtError, [mbOK], 0);
      exit;
    end;
    if (RC22Edit.Text = '') or not TryStrToInt(RC22Edit.Text, obs[2, 2]) then
    begin
      RC22Edit.SetFocus;
      MessageDlg('No valid input', mtError, [mbOK], 0);
      exit;
    end;
  end;

  if InputGrp.ItemIndex = 0 then // count no. in row/col combinations
  begin
    for j := 1 to NoCases do
    begin
      if (not GoodRecord(j,NoSelected,ColNoSelected)) then continue;
      caserow := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[row,j])));
      casecol := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,j])));
      if (caserow > 2) or (caserow < 1) then
      begin
        MessageDlg('Row < 1 or > 2 found. Case ignored.', mtInformation, [mbOK], 0);
        continue;
      end;
      if (casecol > 2) or (casecol < 1) then
      begin
        MessageDlg('Column < 1 or > 2 found. Case ignored.', mtInformation, [mbOK], 0);
        continue;
      end;
      obs[caserow, casecol] := obs[caserow, casecol] + 1;
    end;
  end;

  if (InputGrp.ItemIndex = 1) or (InputGrp.ItemIndex = 2) then // Grid has frequencies for row/col
  begin
    for j := 1 to NoCases do
    begin
      if (not GoodRecord(j,NoSelected,ColNoSelected)) then continue;
      caserow := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[row,j])));
      casecol := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,j])));
      if (caserow > 2) or (caserow < 1) then
      begin
        MessageDlg('Row < 1 or > 2 found. Case ignored.', mtInformation, [mbOk], 0);
        continue;
      end;
      if (casecol > 2) or (casecol < 1) then
      begin
        MessageDlg('Column < 1 or > 2 found. Case ignored.', mtError, [mbOK], 0);
        continue;
      end;
      obs[caserow, casecol] := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[dep,j])));
      if InputGrp.ItemIndex = 2 then
        obs[caserow,casecol] := obs[caserow,casecol] * StrToInt(NCasesEdit.Text);
    end;
  end;

  //Find smallest value
  A := obs[1, 1];
  B := obs[1, 2];
  C := obs[2, 1];
  D := obs[2, 2];
  APlusB := A + B;
  CPlusD := C + D;
  BPlusD := B + D;
  APlusC := A + C;
  N := A + B + C + D;
  Largest := 1;
  if (B > A) then largest := 2;
  if ((B > A) and (B > C) and (B > D)) then Largest := 2;
  if ((C > A) and (C > B) and (C > D)) then Largest := 3;
  if ((D > A) and (D > B) and (D > C)) then Largest := 4;

  // Ready for output
  lReport := TStringList.Create;
  try
    lReport.Add('FISHER EXACT PROBABILITY TEST');
    lReport.Add('');

    //Get first probability
    FirstP := combos(A, APlusC) * combos(B, BPlusD) / combos(APlusB, N);
    SumProb := FirstP;
    PrintFisherTable(lReport, A, B, C, D, FirstP, SumProb);
    lReport.Add('');

    //Get more extreme probabilities
    done := false;
    while (not done) do
    begin
      case Largest of
        1: begin// top row, first col
             if (A = APlusB) then
               done := true
             else
             begin
               inc(A);
               dec(B);
               dec(C);
               inc(D);
             end;
           end;
        2: begin// top row, second column
             if (B = APlusB) then
               done := true
             else
             begin
               dec(A);
               inc(B);
               inc(C);
               dec(D);
             end;
           end;
        3: begin // second row, first column
             if (C = CPlusD) then
               done := true
             else
             begin
               dec(A);
               inc(B);
               inc(C);
               dec(D);
             end;
           end;
        4: begin // second row, second column
             if (D = CPlusD) then
               done := true
             else
             begin
               inc(A);
               dec(B);
               dec(C);
               inc(D);
             end;
           end;
      end; // end case

      if (not done) then
      begin
        p := combos(A, APlusC) * combos(b, BPlusD) / combos(APlusB, N);
        SumProb := SumProb + p;
        PrintFisherTable(lReport, A, B, C, D, p, SumProb);
        lReport.Add('');
      end;
    end;

    //Tocher's modification
    repeat
      response := FormatFloat('0.00', DEFAULT_ALPHA_LEVEL);
      ok := InputQuery('Alpha', 'Enter your Alpha level (Type I Error rate): ', response);
      if not ok then
        exit;
      if TryStrToFloat(response, Alpha) then
        break
      else
        MessageDlg('Not a valid number.', mtError, [mbOk], 0);
    until false;

    if ((SumProb - FirstP) > Alpha) then //Extreme values > alpha - accept null hypothesis
      lReport.Add('Null hypothesis accepted.')
    else
    begin//Extreme values significant - is total probability significant?
      if (SumProb >= Alpha) then    //No, so apply Tocher's rule
      begin
        Tocher := ( Alpha - (SumProb - FirstP)) / FirstP;
        X := random(1000) / 1000.0; //Select a random value between 0 and num - 1
        lReport.Add('Tocher ratio computed: %5.3f', [Tocher]);
        if (X < Tocher) then //Call it significant
        begin
          lReport.Add('A random value of %5.3f selected was less than the Tocher value.', [X]);
          lReport.Add('Conclusion: Reject the null Hypothesis');
        end else
        begin //Call it non-significant
          lReport.Add('A random value of %5.3f selected was greater than the Tocher value.', [X]);
          lReport.Add('Conclusion: Accept the null Hypothesis');
        end;
      end else
      begin //Total probability < alpha - reject null
        lReport.Add('Probability less than alpha - reject null hypothesis.');
      end; // end if-else
    end; // end if-else

    OutputFrm.Clear;
    OutputFrm.AddLines(lReport);
    OutputFrm.ShowModal;
  finally
    lReport.Free;
  end;
end;

procedure TFisherFrm.DepInClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepEdit.Text = '') then
  begin
     DepEdit.Text := VarList.Items[index];
     VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TFisherFrm.DepOutClick(Sender: TObject);
begin
  if DepEdit.Text <> '' then
  begin
    VarList.Items.Add(DepEdit.Text);
    DepEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TFisherFrm.InputGrpClick(Sender: TObject);
begin
  if InputGrp.ItemIndex = 3 then
  begin
    Panel2.Visible := true;
    Panel1.Visible := false;
    RC11Edit.SetFocus;
  end else
  begin
    Panel1.Visible := true;
    Panel2.Visible := false;
    ColIn.Enabled := true;
    ColOut.Enabled := false;
    if InputGrp.ItemIndex = 2 then
    begin
      NCasesLabel.Visible := true;
      NCasesEdit.Visible := true;
    end
    else begin
      NCasesLabel.Visible := false;
      NCasesEdit.Visible := false;
    end;
    if InputGrp.ItemIndex = 0 then
    begin
      DepLabel.Visible := false;
      DepEdit.Visible := false;
      DepIn.Visible := false;
      DepOut.Visible := false;
    end
    else begin  // InputGrp = 1
      DepLabel.Visible := true;
      DepEdit.Visible := true;
      DepIn.Visible := true;
      DepOut.Visible := true;
      DepIn.Enabled := true;
      DepOut.Enabled := false;
    end;
  end;
end;

procedure TFisherFrm.RC11EditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then RC12Edit.SetFocus;
end;

procedure TFisherFrm.RC12EditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then RC21Edit.SetFocus;
end;

procedure TFisherFrm.RC21EditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then RC22Edit.SetFocus;
end;

procedure TFisherFrm.RC22EditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then ComputeBtn.SetFocus;
end;

procedure TFisherFrm.PrintFisherTable(AList: TStrings;
  A, B, C, D: integer; P, SumP: double);
begin
  AList.Add('Contingency Table for Fisher Exact Test');
  AList.Add('                 Column');
  AList.Add('Row             1          2');
  AList.Add(' 1     %10d %10d', [A, B]);
  AList.Add(' 2     %10d %10d', [C, D]);
  AList.Add('');
  AList.Add('Probability = %6.4f', [P]);
  AList.Add('Cumulative Probability = %6.4f', [SumP]);
  AList.Add('');
end;

procedure TFisherFrm.UpdateBtnStates;
begin
  RowIn.Enabled := VarList.ItemIndex > -1;
  ColIn.Enabled := VarList.ItemIndex > -1;
  DepIn.Enabled := VarList.ItemIndex > -1;
  RowOut.Enabled := RowEdit.Text <> '';
  ColOut.Enabled := ColEdit.Text <> '';
  DepOut.Enabled := DepEdit.Text <> '';
end;

initialization
  {$I exactunit.lrs}

end.

