unit GroupFreqUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, GraphLib, Globals, DataProcs;

type

  { TGroupFreqForm }

  TGroupFreqForm = class(TForm)
    Bevel1: TBevel;
    GrpInBtn: TBitBtn;
    GrpOutBtn: TBitBtn;
    ComputeBtn: TButton;
    GrpVarEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TLabel;
    PlotOptionsBox: TRadioGroup;
    ResetBtn: TButton;
    CloseBtn: TButton;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GrpInBtnClick(Sender: TObject);
    procedure GrpOutBtnClick(Sender: TObject);
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
  GroupFreqForm: TGroupFreqForm;

implementation

uses
  Math;

{ TGroupFreqForm }

procedure TGroupFreqForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  GrpVarEdit.Text := '';
  UpdateBtnStates;
end;

procedure TGroupFreqForm.GrpInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (GrpVarEdit.Text = '') then
  begin
    GrpVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TGroupFreqForm.ComputeBtnClick(Sender: TObject);
VAR
  nogroups, mingrp, maxgrp, grpcol, value, minfreq, maxfreq: integer;
  labelstr: string;
  i: integer;
  strvalue: string;
  freq: IntDyneVec;
  plottype: integer;
begin
  // get the variable to analyze
  grpcol := 0;
  for i := 1 to NoVariables do
  begin
    strvalue := OS3MainFrm.DataGrid.Cells[i,0];
    if GrpVarEdit.Text = strvalue then
    begin
      grpcol := i;
      break;
    end;
  end;
  if grpcol = 0 then
  begin
     MessageDlg('No variable selected.', mtError, [mbOK], 0);
     exit;
  end;

  labelstr := GrpVarEdit.Text;
  mingrp := 1000;
  maxgrp := -1000;
  for i := 1 to NoCases do
  begin
    if not ValidValue(i,grpcol) then continue;
    value := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[grpcol,i])));
    if value < mingrp then mingrp := value;
    if value > maxgrp then maxgrp := value;
  end;
  nogroups := maxgrp - mingrp + 1;
  if nogroups < 2 then
  begin
    MessageDlg('One or fewer groups found.', mtError, [mbOK], 0);
    exit;
  end;

  // setup frequency array and count cases in each group
  SetLength(freq,NoGroups+1);
  for i := 0 to NoGroups do
    freq[i] := 0;
  for i := 1 to NoCases do
  begin
    if not ValidValue(i,grpcol) then continue;
    value := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[grpcol,i])));
    value := value - mingrp;
    freq[value] := freq[value] + 1;
  end;

  // get min and max frequencies and check for existence of a range
  minfreq := 10000;
  maxfreq := -10000;
  for i := 0 to NoGroups-1 do
  begin
    if freq[i] < minfreq then minfreq := freq[i];
    if freq[i] > maxfreq then maxfreq := freq[i];
  end;
  if minfreq = maxfreq then
  begin
    MessageDlg('All groups have equal frequencies.  Cannot plot.', mtInformation, [mbOK], 0);
    freq := nil;
    exit;
  end;

  case PlotOptionsBox.ItemIndex of
    0: plottype := 9;
    1: plottype := 10;
    2: plottype := 1;
    3: plottype := 2;
  end;

  // plot the frequencies
  SetLength(GraphFrm.Xpoints,1,nogroups+1);
  SetLength(GraphFrm.Ypoints,1,nogroups+1);
  GraphFrm.nosets := 1;
  GraphFrm.nbars := nogroups;
  GraphFrm.Heading := 'Frequency Distribution';
  GraphFrm.XTitle := 'Values of ' + labelstr;
  GraphFrm.YTitle := 'Frequency';
  GraphFrm.barwideprop := 0.5;
  GraphFrm.AutoScaled := false;
  GraphFrm.miny := 0.0;
  GraphFrm.maxy := maxfreq;
  GraphFrm.GraphType := plottype;
  GraphFrm.BackColor := clCream; // clYellow;
  GraphFrm.WallColor := clDkGray; //Black;
  GraphFrm.FloorColor := clLtGray;
  GraphFrm.ShowBackWall := true;
  for i := 0 to nogroups do
  begin
    GraphFrm.Ypoints[0,i] := freq[i];
    GraphFrm.Xpoints[0,i] := mingrp + i;
  end;
  GraphFrm.ShowModal;
  GraphFrm.Xpoints := nil;
  GraphFrm.Ypoints := nil;
end;

procedure TGroupFreqForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := PlotOptionsBox.Top + PlotOptionsBox.Height - VarList.Top;
  Varlist.Constraints.MinWidth := Label1.Width * 3 div 2;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TGroupFreqForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure TGroupFreqForm.GrpOutBtnClick(Sender: TObject);
begin
  if GrpVarEdit.Text <> '' then
  begin
    VarList.Items.Add(GrpVarEdit.Text);
    GrpVarEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TGroupFreqForm.UpdateBtnStates;
begin
  GrpInBtn.Enabled := VarList.ItemIndex > -1;
  GrpOutBtn.Enabled := (GrpVarEdit.Text <> '');
end;

procedure TGroupFreqForm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I groupfrequnit.lrs}

end.

