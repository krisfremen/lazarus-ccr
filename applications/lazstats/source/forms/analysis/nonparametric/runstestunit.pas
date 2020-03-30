unit RunsTestUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, Globals, DataProcs;

type

  { Trunstestform }

  Trunstestform = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    MeanEdit: TEdit;
    Memo1: TLabel;
    ResetBtn: TButton;
    ReturnBtn: TButton;
    StdDevEdit: TEdit;
    NUpEdit: TEdit;
    NDownEdit: TEdit;
    NRunsEdit: TEdit;
    StatEdit: TEdit;
    ProbEdit: TEdit;
    ConclusionEdit: TEdit;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    Label10: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    TestVarEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  runstestform: Trunstestform;

implementation

uses
  Math;

{ Trunstestform }

procedure Trunstestform.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     TestVarEdit.Text := '';
     MeanEdit.Text := '';
     StdDevEdit.Text := '';
     NUpEdit.Text := '';
     NDownEdit.Text := '';
     StatEdit.Text := '';
     ProbEdit.Text := '';
     ConclusionEdit.Text := '';
     NRunsEdit.Text := '';
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
end;

procedure Trunstestform.ComputeBtnClick(Sender: TObject);
VAR
  a, i, col, N, N1, N2, NLess, Nmore, R : integer;
  Mean, ExpMean, SD1, SD2, SD3, SD4, SD, z1, z2, z, t, p1, p : double;
  strvalue, outstr, astring : string;
  values : DblDyneVec;

begin
     col := 0;
     N := 0;
     N1 := 0;
     N2 := 0;
     Nless := 0;
     Nmore := 0;
     R := 1;
     Mean := 0.0;
     for i := 1 to NoVariables do
         begin
           strvalue := Trim(OS3MainFrm.DataGrid.Cells[i,0]);
           if TestVarEdit.Text = strvalue then col := i;
         end;
     if col = 0 then
     begin
       ShowMessage('No variable was selected. Returning.');
       exit;
     end;
     SetLength(values,NoCases);
     for i := 1 to NoCases do
         begin
           if not ValidValue(i,col) then continue;
           values[i-1] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
           N := N + 1;
         end;
     if N <= 10 then
     begin
       ShowMessage('Insufficient data.  You must have at least 11 values.');
       values := nil;
       exit;
     end;
     for i := 0 to N-1 do Mean := Mean + values[i];
     Mean := Mean / N;
     // run through each value and compare with the mean
     for i := 0 to N-1 do
         begin  // check and discard the ties with the mean
           if Mean <> values[i] then
           begin // check if it is greater than the mean
                if values[i] > mean then
                begin
                     N1 := N1 + 1;
                     a := i;
                     while a > 0 do
                     begin
                          a := a - 1;
                          if values[a] <> Mean then break;
                     end;
                     if values[a] < Mean then
                     begin
                          R := R + 1;
                          NLess := NLess + 1;
                     end;
                end
                // check to see if it is less than the mean
                else if values[i] < Mean then
                begin
                     N2 := N2 + 1;
                     a := i;
                     while a > 0 do
                     begin
                          a := a - 1;
                          if values[a] <> Mean then break;
                     end;
                     if values[a] > Mean then
                     begin
                          R := R + 1;
                          Nmore := Nmore + 1;
                     end;
                end; // close of else i
           end; // end of if values[i] not equal to the mean
         end; // end of i loop
     // compute the expected mean and variance of R
     ExpMean := 1.0 + ((2 * N1 * N2) / (N1 + N2)); // mean mu
     SD1 := 2 * N1 * N2 * (2 * N1 * N2 - N1 - N2);
     SD2 := power((N1 + N2),2);
     SD3 := N1 + N2 - 1;
     SD4 := SD1 / (SD2 * SD3); // standard deviation "sigma"
     SD := sqrt(SD4);
     // calculating P Value
     z1 := (R - ExpMean) / SD;
     z2 := abs(z1);
     z := z2;
     if z > 0 then t := z else t := -z;
     p1 := power((1 + t * (0.049867347 + t * (0.0211410061 + t * (0.0032776283 +
        t * (0.0000380036 + t * (0.0000488906 + t * (0.000005383))))))), -16);
     p := 1.0 - p1 / 2.0;
     if z > 0.0 then t := 1.0 - p
     else t := 1.0 - (1.0 - p); // this is P value
     // show results
     outstr := format('%8.3f',[Mean]);
     MeanEdit.Text := outstr;
     outstr := format('%8.3f',[SD]);
     StdDevEdit.Text := outstr;
     NUpEdit.Text := IntToStr(N1);
     NDownEdit.Text := IntToStr(N2);
     NRunsEdit.Text := IntToStr(R);
     outstr := format('%8.3f',[z]);
     StatEdit.Text := outstr;
//     if t < 0.0001 then astring := 'Almost Zero'
//     else
//     begin
          outstr := format('%6.4f',[t]);
          ProbEdit.Text := outstr;
//     end;
     // determine the conclusion
     if t < 0.01 then
     begin
          astring := 'Very strong evidence against randomness (trend or seasonality';
          ConclusionEdit.Text := astring;
     end
     else if (t < 0.05) and (t >= 0.01) then
     begin
          astring := 'Moderate evidence against randomness';
          ConclusionEdit.Text := astring;
     end
     else if (t < 0.10) and (t >= 0.05) then
     begin
          astring := 'Suggestive evidence against normality';
          ConclusionEdit.Text := astring;
     end
     else if t >= 0.10 then
     begin
          astring := 'Little or no real evidence against randomness';
          ConclusionEdit.Text := astring;
     end
     else
     begin
          astring := 'Strong evidence against randomness (trend or seasonality exists)';
          ConclusionEdit.Text := astring;
     end;
     values := nil;
end;

procedure Trunstestform.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure Trunstestform.FormCreate(Sender: TObject);
begin
  Assert(OS3Mainfrm <> nil);
end;

procedure Trunstestform.InBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     if index < 0 then exit;
     TestVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     InBtn.Enabled := false;
     OutBtn.Enabled := true;
end;

procedure Trunstestform.OutBtnClick(Sender: TObject);
begin
     if TestVarEdit.Text = '' then exit;
     VarList.Items.Add(TestVarEdit.Text);
     TestVarEdit.Text := '';
     InBtn.Enabled := true;
     OutBtn.Enabled := false;
end;

initialization
  {$I runstestunit.lrs}

end.

