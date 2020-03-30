unit SortCasesUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, DictionaryUnit;

type

  { TSortCasesFrm }

  TSortCasesFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    VarInBtn: TBitBtn;
    VarOutBtn: TBitBtn;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    OrderGroup: TRadioGroup;
    SortVarEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure VarInBtnClick(Sender: TObject);
    procedure VarOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
  public
    { public declarations }
  end; 

var
  SortCasesFrm: TSortCasesFrm;

implementation

uses
  Math;

{ TSortCasesFrm }

procedure TSortCasesFrm.ComputeBtnClick(Sender: TObject);
label strvals, lastplace;
var
   temp : string;
   i, j, k : integer;
   selcol : integer;
begin
   selcol := 0;
   for i := 1 to NoVariables do
        if OS3MainFrm.DataGrid.Cells[i,0] = SortVarEdit.Text then selcol := i;
   if DictionaryFrm.DictGrid.Cells[4,selcol] = 'S' then goto strvals;
   if selcol > 0 then
   begin
        if OrderGroup.ItemIndex = 0 then // sort ascending
        begin
             for i := 1 to NoCases-1 do
             begin
                  for j := i+1 to NoCases do
                  begin
                       if StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[selcol,i])) > StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[selcol,j])) then
                       begin
                            for k := 1 to NoVariables do
                            begin
                                 temp := OS3MainFrm.DataGrid.Cells[k,i];
                                 OS3MainFrm.DataGrid.Cells[k,i] := OS3MainFrm.DataGrid.Cells[k,j];
                                 OS3MainFrm.DataGrid.Cells[k,j] := temp;
                            end;
                       end;
                  end; // next j
             end; // next i
        end // if ascending sort
        else begin // descending sort
             for i := 1 to NoCases-1 do
             begin
                  for j := i+1 to NoCases do
                  begin
                       if StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[selcol,i]))
                        < StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[selcol,j])) then
                       begin
                            for k := 1 to NoVariables do
                            begin
                                 temp := OS3MainFrm.DataGrid.Cells[k,i];
                                 OS3MainFrm.DataGrid.Cells[k,i] := OS3MainFrm.DataGrid.Cells[k,j];
                                 OS3MainFrm.DataGrid.Cells[k,j] := temp;
                            end;
                       end;
                  end; // next j
             end; // next i
        end; // if descending sort
   end; // if selcol > 0
   goto lastplace;
strvals:
   if selcol > 0 then
   begin
        if OrderGroup.ItemIndex = 0 then // sort ascending
        begin
             for i := 1 to NoCases-1 do
             begin
                  for j := i+1 to NoCases do
                  begin
                       if Trim(OS3MainFrm.DataGrid.Cells[selcol,i]) > Trim(OS3MainFrm.DataGrid.Cells[selcol,j]) then
                       begin
                            for k := 1 to NoVariables do
                            begin
                                 temp := OS3MainFrm.DataGrid.Cells[k,i];
                                 OS3MainFrm.DataGrid.Cells[k,i] := OS3MainFrm.DataGrid.Cells[k,j];
                                 OS3MainFrm.DataGrid.Cells[k,j] := temp;
                            end;
                       end;
                  end; // next j
             end; // next i
        end // if ascending sort
        else begin // descending sort
             for i := 1 to NoCases-1 do
             begin
                  for j := i+1 to NoCases do
                  begin
                       if Trim(OS3MainFrm.DataGrid.Cells[selcol,i])
                        < Trim(OS3MainFrm.DataGrid.Cells[selcol,j]) then
                       begin
                            for k := 1 to NoVariables do
                            begin
                                 temp := OS3MainFrm.DataGrid.Cells[k,i];
                                 OS3MainFrm.DataGrid.Cells[k,i] := OS3MainFrm.DataGrid.Cells[k,j];
                                 OS3MainFrm.DataGrid.Cells[k,j] := temp;
                            end;
                       end;
                  end; // next j
             end; // next i
        end; // if descending sort
   end; // if selcol > 0
lastplace:
 end;

procedure TSortCasesFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TSortCasesFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <>nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TSortCasesFrm.FormShow(Sender: TObject);
VAR i : integer;
begin
     SortVarEdit.Text := '';
     VarOutBtn.Enabled := false;
     VarInBtn.Enabled := true;
     VarList.Items.Clear;
     for i := 1 to NoVariables do
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TSortCasesFrm.VarInBtnClick(Sender: TObject);
var i : integer;
begin
   i := VarList.ItemIndex;
   if i < 0 then exit;
   SortVarEdit.Text := VarList.Items.Strings[i];
   VarList.Items.Delete(i);
   VarInBtn.Enabled := false;
   VarOutBtn.Enabled := true;
end;

procedure TSortCasesFrm.VarOutBtnClick(Sender: TObject);
begin
     if SortVarEdit.Text = '' then exit;
     VarList.Items.Add(SortVarEdit.Text);
     SortVarEdit.Text := '';
     VarOutBtn.Enabled := false;
     VarInBtn.Enabled := true;
end;

initialization
  {$I sortcasesunit.lrs}

end.

