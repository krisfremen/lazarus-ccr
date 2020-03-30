unit EquationUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Math,
  MainUnit, Globals, OutputUnit, DataProcs, DictionaryUnit;

type

  { TEquationForm }

  TEquationForm = class(TForm)
    Bevel1: TBevel;
    FinishedBtn: TButton;
    Memo1: TLabel;
    NextBtn: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBnt: TButton;
    VarCombo: TComboBox;
    FunctionCombo: TComboBox;
    OpsCombo: TComboBox;
    VarEdit: TEdit;
    FuncEdit: TEdit;
    OpEdit: TEdit;
    Label2: TLabel;
    NewVarEdit: TEdit;
    Label1: TLabel;
    procedure CancelBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FinishedBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FunctionComboClick(Sender: TObject);
    procedure FunctionComboSelect(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
    procedure OpsComboClick(Sender: TObject);
    procedure OpsComboSelect(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure ReturnBntClick(Sender: TObject);
    procedure VarComboClick(Sender: TObject);
    procedure VarComboSelect(Sender: TObject);
  private
    { private declarations }
    operations, functions, variables : StrDyneVec;
    NoEntries : integer;
    selected : IntDyneVec;
  public
    { public declarations }
  end; 

var
  EquationForm: TEquationForm;

implementation

{ TEquationForm }

procedure TEquationForm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
  NewVarEdit.Text := '';
  OpEdit.Text := '';
  FuncEdit.Text := '';
  VarEdit.Text := '';
  OpsCombo.Text := 'Operations';
  FunctionCombo.Text := 'Functions';
  VarCombo.Clear;
  for i := 1 to NoVariables do
      VarCombo.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  VarCombo.Text := 'Variables';
  VarCombo.DropDownCount := NoVariables;
  SetLength(operations,NoVariables);
  SetLength(functions,NoVariables);
  SetLength(variables,NoVariables);
  NoEntries := 0;
end;

procedure TEquationForm.ReturnBntClick(Sender: TObject);
begin
  variables := nil;
  functions := nil;
  operations := nil;
end;

procedure TEquationForm.VarComboClick(Sender: TObject);
VAR index : integer;
begin
  index := VarCombo.ItemIndex;
  if index < 0 then exit;
  VarEdit.Text := VarCombo.Items.Strings[index];
  VarCombo.ItemIndex := -1;
end;

procedure TEquationForm.VarComboSelect(Sender: TObject);
VAR index : integer;
begin
  index := VarCombo.ItemIndex;
  if index < 0 then exit;
  VarEdit.Text := VarCombo.Items.Strings[index];
  VarCombo.ItemIndex := -1;
end;

procedure TEquationForm.NextBtnClick(Sender: TObject);
begin
  operations[NoEntries] := OpEdit.Text;
  if ((NoEntries > 0) and (operations[NoEntries] = '') )then
  begin
     ShowMessage('ERROR-No operation selected - enter again!');
     exit;
  end;
  functions[NoEntries] := FuncEdit.Text;
  variables[NoEntries] := VarEdit.Text;
  if (variables[NoEntries] = '') then
  begin
     ShowMessage('ERROR-No variable entered - enter again!');
     exit;
  end;
  NoEntries := NoEntries + 1;
  OpEdit.Text := '';
  FuncEdit.Text := '';
  VarEdit.Text := '';
  OpsCombo.Text := 'Operations';
  FunctionCombo.Text := 'Functions';
  VarCombo.Text := 'Variables';
end;

procedure TEquationForm.OpsComboClick(Sender: TObject);
VAR index : integer;
begin
  index := OpsCombo.ItemIndex;
  if index < 0 then exit;
  OpEdit.Text := OpsCombo.Items.Strings[index];
  OpsCombo.ItemIndex := -1;
end;

procedure TEquationForm.OpsComboSelect(Sender: TObject);
VAR index : integer;
begin
  index := OpsCombo.ItemIndex;
  if index < 0 then exit;
  OpEdit.Text := OpsCombo.Items.Strings[index];
  OpsCombo.ItemIndex := -1;
end;

procedure TEquationForm.FinishedBtnClick(Sender: TObject);
begin
  operations[NoEntries] := OpEdit.Text;
  if ((NoEntries > 0) and (operations[NoEntries] = '')) then
  begin
     ShowMessage('ERROR-No operation selected - enter again!');
     exit;
  end;
  functions[NoEntries] := FuncEdit.Text;
  variables[NoEntries] := VarEdit.Text;
  if (variables[NoEntries] = '') then
  begin
     ShowMessage('ERROR-No variable entered - enter again!');
     exit;
  end;
  NoEntries := NoEntries + 1;
  OpsCombo.Text := 'Operations';
  FunctionCombo.Text := 'Functions';
  VarCombo.Text := 'Variables';
end;

procedure TEquationForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TEquationForm.FunctionComboClick(Sender: TObject);
VAR index : integer;
begin
  index := FunctionCombo.ItemIndex;
  if index < 0 then exit;
  FuncEdit.Text := FunctionCombo.Items.Strings[index];
  FunctionCombo.ItemIndex := -1;
end;

procedure TEquationForm.FunctionComboSelect(Sender: TObject);
VAR index : integer;
begin
  index := FunctionCombo.ItemIndex;
  if index < 0 then exit;
  FuncEdit.Text := FunctionCombo.Items.Strings[index];
  FunctionCombo.ItemIndex := -1;
end;

procedure TEquationForm.ComputeBtnClick(Sender: TObject);
VAR
	cellstring, outline : string;
	opsitem, funcsitem, col, newcol, i, j, k : integer;
	newvalue, xvalue : double;
begin
  // get position of selected variables from the main grid
  SetLength(selected,NoEntries);
  for i := 1 to NoVariables do
  begin
      cellstring := Trim(OS3MainFrm.DataGrid.Cells[i,0]);
      for j := 0 to NoEntries - 1 do
          if (cellstring = variables[j]) then selected[j] := i;
  end;

  // create a new variable in the main grid
  col := NoVariables + 1;
  newcol := col;
  DictionaryFrm.NewVar(col);
  OS3MainFrm.DataGrid.Cells[col,0] := NewVarEdit.Text;
  DictionaryFrm.DictGrid.Cells[1,col] := NewVarEdit.Text;

  // for each subject obtain selected variable values and add to newvalue
  for i := 1 to NoCases do  // subject loop
  begin
      newvalue := 0.0;
      for j := 0 to NoEntries - 1 do // list loop
      begin
          col := selected[j];
          xvalue := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
          if (functions[j] <> '') then // do the function
          begin
              for k := 0 to 11 do // get function number
              begin
                  if (functions[j] = FunctionCombo.Items.Strings[k]) then funcsitem := k;
              end;
              case (funcsitem) of
                  0: xvalue *= xvalue;
                  1: xvalue := sqrt(xvalue);
                  2: xvalue := sin(xvalue);
                  3: xvalue := cos(xvalue);
                  4: xvalue := tan(xvalue);
                  5: xvalue := arcsin(xvalue);
                  6: xvalue := arccos(xvalue);
                  7: xvalue := arctan(xvalue);
                  8: xvalue := log10(xvalue);
                  9: xvalue := ln(xvalue);
                  10: xvalue := exp(xvalue);
                  11: xvalue := 1.0 / xvalue;
              end;
          end; // end if function
          if (operations[j] = '') then newvalue := newvalue + xvalue
          else // find operation
          begin
               for k := 0 to 3 do
               begin
                   if (operations[j] = OpsCombo.Items.Strings[k]) then opsitem := k;
               end;
               case (opsitem) of
                   0: newvalue += xvalue;
                   1: newvalue -= xvalue;
                   2: newvalue *= xvalue;
                   3: newvalue /= xvalue;
               end;
          end; // end else
      end; // end jth variable
      OS3MainFrm.DataGrid.Cells[newcol,i] := floattostr(newvalue);
      FormatCell(newcol,i);
  end; // next subject

  OutputFrm.RichEdit.Clear;
  OutputFrm.RichEdit.Lines.Add('Equation Used for the New Variable');
  OutputFrm.RichEdit.Lines.Add('');
  outline := NewVarEdit.Text;
  outline := outline +' = ';
  for j := 0 to NoEntries - 1 do
  begin
      outline := outline + functions[j];
      outline := outline + ' ';
      outline := outline + variables[j];
      outline := outline + ' ';
      if (j < NoEntries-1) then
      begin
         outline := outline + operations[j+1];
         outline := outline + ' ';
      end;
  end;
  OutputFrm.RichEdit.Lines.Add(outline);
  OutputFrm.ShowModal;
end;

procedure TEquationForm.CancelBtnClick(Sender: TObject);
begin
  variables := nil;
  functions := nil;
  operations := nil;
end;

initialization
  {$I equationunit.lrs}

end.

