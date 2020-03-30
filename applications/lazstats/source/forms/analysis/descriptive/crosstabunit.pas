// Use file "twoway.laz" for testing

unit CrossTabUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Globals, OutputUnit, MainUnit, DataProcs, MatrixLib, ContextHelpUnit;

type

  { TCrossTabFrm }

  TCrossTabFrm = class(TForm)
    ComputeBtn: TButton;
    VertCenterBevel: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    Panel2: TPanel;
    ResetBtn: TButton;
    CloseBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    VarList: TListBox;
    SelList: TListBox;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    grandsum, sum, index : integer;
    no_in_list, length_array, ptr1, ptr2 : integer ;
    var_list, min_value, max_value, levels, displace, subscript : IntDyneVec;
    freq : IntDyneVec;
    outgrid : DblDyneMat;
    rowlabels : StrDyneVec;
    colLabels : StrDyneVec;
    ColNoSelected : IntDyneVec;
    NoSelected : integer;
    NV, NC : integer;

    procedure Initialize;
    procedure GetLevels(AReport: TStrings);
    function IndexPosition(x: IntDyneVec): integer;
    Procedure Tabulate;
    procedure BreakDown(AReport: TStrings);
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  CrossTabFrm: TCrossTabFrm;

implementation

uses
  Math;

{ TCrossTabFrm }

procedure TCrossTabFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  SelList.Clear;
  NV := NoVariables;
  NC := NoCases;
  for i := 1 to NV do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TCrossTabFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TCrossTabFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TCrossTabFrm.InBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      SelList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TCrossTabFrm.ComputeBtnClick(Sender: TObject);
var
  cellvalue: string;
  i, j: integer;
  lReport: TStrings;
begin
  if SelList.Items.Count = 0 then
  begin
    MessageDlg('No variables selected for analysis.', mtError, [mbOK], 0);
    exit;
  end;

  SetLength(var_list, NV);
  SetLength(min_value, NV);
  SetLength(max_value, NV);
  SetLength(levels, NC);
  SetLength(displace, NC);
  SetLength(subscript,NC);
  SetLength(ColNoSelected, NV);

  lReport := TStringList.Create;
  try
    lReport.Add('CROSSTAB RESULTS');
    lReport.Add('');
    lReport.Add('Analyzed data is from file ' + OS3MainFrm.FileNameEdit.Text);
    lReport.Add('');

    Initialize;

    NoSelected := 0;
    for i := 0 to SelList.Items.Count-1 do
    begin
      for j := 1 to NV do
      begin
        cellvalue := OS3MainFrm.DataGrid.Cells[j,0];
        if cellvalue = SelList.Items[i] then
        begin
          var_list[i] := j;
          ColNoSelected[i] := j;
          NoSelected := NoSelected + 1;
          break;
        end;
      end;
    end;

    no_in_list := SelList.Items.Count;
    GetLevels(lReport);
    Tabulate;
    BreakDown(lReport);

    lReport.Add('');
    lReport.Add('Grand sum across all categories = %d', [grandsum]);

    DisplayReport(lReport);

  finally
    lReport.Free;

    ColNoSelected := nil;
    freq := nil;
    collabels := nil;
    rowlabels := nil;
    outgrid := nil;
    subscript := nil;
    displace := nil;
    levels := nil;
    max_value := nil;
    min_value := nil;
    var_list := nil;
  end;
end;

procedure TCrossTabFrm.OutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < SelList.Items.Count do
  begin
    if SelList.Selected[i] then
    begin
      VarList.Items.Add(SelList.Items[i]);
      SelList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TCrossTabFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
   if FAutoSized then
     exit;

   w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
   HelpBtn.Constraints.MinWidth := w;
   ResetBtn.Constraints.MinWidth := w;
   ComputeBtn.Constraints.MinWidth := w;
   CloseBtn.Constraints.MinWidth := w;

   Constraints.MinWidth := Width;
   Constraints.MinHeight := Height;

   FAutoSized := true;
end;

procedure TCrossTabFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TCrossTabFrm.Initialize;
var
  i: integer;
begin
  no_in_list := 0;
  for i := 1 to NV do
  begin
    var_list[i-1] := 0;
    min_value[i-1] := 0;
    max_value[i-1] := 0;
    levels[i-1] := 0;
    displace[i-1] := 0;
    subscript[i-1] := 0;
  end;
  index := 0;
  length_array := 0;
  grandsum := 0;
end; { initialize procedure }

procedure TCrossTabFrm.GetLevels(AReport: TStrings);
var
  i, j, k: integer;
  value: double;
begin
  for i := 1 to no_in_list do
  begin
    j := var_list[i-1];
    if not GoodRecord(1,NoSelected,ColNoSelected) then continue;
    value := StrToFloat(OS3MainFrm.DataGrid.Cells[j,1]);
    min_value[i-1] := round(value);
    max_value[i-1] := round(value);
    for k := 2 to NC do
    begin
      if not GoodRecord(k,NoSelected,ColNoSelected) then continue;
      value := StrToFloat(OS3MainFrm.DataGrid.Cells[j,k]);
      if value < min_value[i-1] then
        min_value[i-1] := round(value);
      if value > max_value[i-1] then
        max_value[i-1] := round(value);
    end;
  end;

  for i := 1 to no_in_list do
  begin
    j := var_list[i-1];
    levels[i-1] := max_value[i-1] - min_value[i-1] + 1;
    AReport.Add('%s min.=%3d, max.=%3d, no. levels = %3d', [
      OS3MainFrm.DataGrid.Cells[j,0],min_value[i-1],max_value[i-1],levels[i-1]
    ]);
  end;
  AReport.Add('');

  displace[no_in_list-1] := 1;
  if no_in_list > 1 then
    for i := (no_in_list - 1) downto 1 do
      displace[i-1] := levels[i] * displace[i];
end;

function TCrossTabFrm.IndexPosition(x: IntDyneVec): integer;
var
  i: integer;
begin
  Result := x[no_in_list-1];
  if no_in_list > 1 then
  begin
    for i := 1 to no_in_list - 1 do
      Result := Result + (x[i-1] -1) * displace[i-1];
  end;
end;

procedure TCrossTabFrm.Tabulate;
var
  i, j, k: integer;
  value: double;
  x: integer;
begin
  length_array := 1;
  for i := 1 to no_in_list do
    length_array := length_array * levels[i-1];
  SetLength(freq,length_array+1);

  for i := 0 to length_array do
    freq[i] := 0;
  for i := 1 to NC do
  begin
    if IsFiltered(i) then
      continue;
    for j := 1 to no_in_list do
    begin
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      k := var_list[j-1];
      value := StrToFloat(OS3MainFrm.DataGrid.Cells[k,i]);
      x := round(value);
      x := x - min_value[j-1] + 1;
      subscript[j-1] := x;
    end;
    j := IndexPosition(subscript);

    if (j < 1) or (j > length_array) then
      continue
    else
      freq[j] := freq[j] + 1;
  end;
end; { procedure TABULATE }

procedure TCrossTabFrm.BreakDown(AReport: TStrings);
label 1,2,3,4, printgrid;
var
  i, j, row, col, bigmax: integer;
  outline: string;
  value: string;
  title: String;
begin
  bigmax := -1;
  for i := 0 to no_in_list-1 do
    if Levels[i] > bigmax then bigmax := Levels[i];

  SetLength(colLabels,bigmax);
  SetLength(outgrid,length_array,bigmax);
  SetLength(rowlabels,length_array);
  outline := OS3MainFrm.DataGrid.Cells[var_list[no_in_list-1], 0];
  for col := 1 to Levels[no_in_list-1] do
    collabels[col-1] := outline + Format(':%3d', [min_value[no_in_list-1] + col - 1]);
  for row := 1 to length_array do
    rowlabels[row-1] := '';
  ptr1 := no_in_list - 1;
  ptr2 := no_in_list;
  for i := 1 to no_in_list do
    subscript[i-1] := 1;

  AReport.Add('FREQUENCIES BY LEVEL:');
  sum := 0;
  col := 1;
  row := 1;

 1:
   index := IndexPosition(subscript);
   outline := 'For cell levels: ';
   for i := 1 to no_in_list do
   begin
     j := var_list[i-1];
     value := Format('%s:%3d  ',[OS3MainFrm.DataGrid.Cells[j,0], min_value[i-1] + subscript[i-1] - 1]);
     outline := outline + value;
   end;
   sum := sum + freq[index];
   outgrid[row-1,col-1] := freq[index];
   outline := outline + Format(' Frequency = %3d', [freq[index]]);
   AReport.Add(outline);

   subscript[ptr2-1] := subscript[ptr2-1] + 1;
   col := col + 1;
   if subscript[ptr2-1] <= levels[ptr2-1] then
     goto 1;

   AReport.Add('Sum across levels = %3d', [sum]);
   AReport.Add('');
   AReport.Add('');

   grandsum := grandsum + sum;
   sum := 0;
   row := row + 1;

 2:
   if ptr1 < 1 then
     goto printgrid;

   subscript[ptr1-1] := subscript[ptr1-1] + 1;
   if subscript[ptr1-1] <= levels[ptr1-1] then
     goto 4;

 3:
   ptr1 := ptr1 - 1;
   if ptr1 < 1 then
     goto printgrid;
   if subscript[ptr1-1] >= levels[ptr1-1] then
     goto 3;
   subscript[ptr1-1] := subscript[ptr1-1] + 1;

 4:
   for i := ptr1 + 1 to no_in_list do
     subscript[i-1] := 1;
   ptr1 := no_in_list - 1;
   col := 1;

   goto 1;

printgrid:
  title := 'Cell Frequencies by Levels';
  for i := 1 to row - 1 do
  begin
    value := format('Block %d',[i]);
    rowlabels[i-1] := value;
  end;

  MatPrint(outgrid,row-1,Levels[no_in_list-1],title,rowlabels,collabels,NC, AReport);
end; { Procedure BREAKDOWN }

procedure TCrossTabFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  lSelected := false;
  for i := 0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  InBtn.Enabled := lSelected;

  lSelected := false;
  for i := 0 to SelList.Items.Count-1 do
    if SelList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  OutBtn.Enabled := lSelected;
end;

procedure TCrossTabFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I crosstabunit.lrs}

end.

