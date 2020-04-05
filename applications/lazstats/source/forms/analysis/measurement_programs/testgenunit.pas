unit TestGenUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Math,
  MainUnit, Globals, DictionaryUnit;

type

  { TTestGenFrm }

  TTestGenFrm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    NoItemsEdit: TEdit;
    NoCasesEdit: TEdit;
    MeanEdit: TEdit;
    SDEdit: TEdit;
    RelEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Options: TRadioGroup;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MeanEditKeyPress(Sender: TObject; var Key: char);
    procedure NoCasesEditKeyPress(Sender: TObject; var Key: char);
    procedure NoItemsEditKeyPress(Sender: TObject; var Key: char);
    procedure RelEditKeyPress(Sender: TObject; var Key: char);
    procedure ResetBtnClick(Sender: TObject);
    procedure SDEditKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  TestGenFrm: TTestGenFrm;

implementation

{ TTestGenFrm }

procedure TTestGenFrm.ResetBtnClick(Sender: TObject);
begin
     Options.ItemIndex := 0;
     NoItemsEdit.Text := '';
     NoCasesEdit.Text := '';
     MeanEdit.Text := '';
     SDEdit.Text := '';
     RelEdit.Text := '';
     NoItemsEdit.SetFocus;
end;

procedure TTestGenFrm.SDEditKeyPress(Sender: TObject; var Key: char);
begin
     if Ord(Key) = 13 then RelEdit.SetFocus;
end;

procedure TTestGenFrm.FormShow(Sender: TObject);
begin
     ResetBtnClick(self);
end;

procedure TTestGenFrm.ComputeBtnClick(Sender: TObject);
Var
    test_var, true_var, total_item_var, true_item_var : double;
    error_item_var, true_score, reliability, tempmean : double;
    test_stddev, test_mean, X, error_score : double;
    random_mean : DblDyneVec;
    i, k, no_cases, no_items, itemtype, col : integer;
    outline : string;

begin
    if ((NoCases > 0) or (NoVariables > 0)) then
    begin
        ShowMessage('You must first close the current file.');
        exit;
    end;

    itemtype := Options.ItemIndex; // 0 = T-F, 1 = continuous
    test_stddev := StrToFloat(SDEdit.Text);
    test_var := test_stddev * test_stddev;
    reliability := StrToFloat(RelEdit.Text);
    true_var := test_var * reliability;
    no_items := StrToInt(NoItemsEdit.Text);
    no_cases := StrToInt(NoCasesEdit.Text);
    test_mean := StrToFloat(MeanEdit.Text);
    total_item_var := (test_var / no_items) * (1.0 -
        ((no_items - 1) / no_items) * reliability);
    true_item_var := total_item_var * reliability;
    error_item_var := total_item_var - true_item_var;
    tempmean := test_mean / no_items;

    SetLength(random_mean,no_items);

    OS3MainFrm.DataGrid.RowCount := no_cases + 1;
//    OS3MainFrm.DataGrid.ColCount := no_items + 1;
    NoVariables := 0;
    NoCases := 0;
    DictionaryFrm.DictGrid.ColCount := 8;
    OS3MainFrm.DataGrid.ColCount := 2;
    for i := 1 to no_items do
    begin
        col := i;
        outline := format('Item%d',[i]);
        DictionaryFrm.DictGrid.RowCount := i;
        DictionaryFrm.NewVar(col);
        DictionaryFrm.DictGrid.Cells[1,col] := outline;
        OS3MainFrm.DataGrid.Cells[col,0] := outline;
    end;
    for i := 1 to no_cases do
    begin
        outline := format('CASE %d',[i]);
        OS3MainFrm.DataGrid.Cells[0,i] := outline;
    end;
    for i := 0 to no_items-1 do
    begin
        random_mean[i] := RandG(tempmean,sqrt(total_item_var));
    end;
    for k := 1 to no_cases do
    begin
        true_score := RandG(0.0,sqrt(true_var));
        true_score := true_score / no_items;
        for i := 1 to no_items do
        begin
            error_score := RandG(0.0,sqrt(error_item_var));
            X := true_score + error_score + random_mean[i-1];
            if (itemtype = 0) then // dichotomous item
            begin
                if (X >= random_mean[i-1]) then  X := 1.0
                else X := 0.0;
            end;
            if (itemtype = 0) then outline := format('%2.0f',[X])
            else outline := format('%6.4f',[X]);
            OS3MainFrm.DataGrid.Cells[i,k] := outline;
        end; // end item loop
    end; // end case loop

    NoVariables := no_items;
    NoCases := no_cases;
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
    OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
    OS3MainFrm.DataGrid.Row := 1;
    OS3MainFrm.DataGrid.Col := 1;
    OS3MainFrm.RowEdit.Text := IntToStr(no_cases);
    OS3MainFrm.ColEdit.Text := IntToStr(no_items);
    OS3MainFrm.FileNameEdit.Text := 'GenTest.LAZ';
    // clean up the heap
    random_mean := nil;
end;

procedure TTestGenFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;
end;

procedure TTestGenFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TTestGenFrm.MeanEditKeyPress(Sender: TObject; var Key: char);
begin
     if Ord(Key) = 13 then SDEdit.SetFocus;
end;

procedure TTestGenFrm.NoCasesEditKeyPress(Sender: TObject; var Key: char);
begin
     if Ord(Key) = 13 then MeanEdit.SetFocus;
end;

procedure TTestGenFrm.NoItemsEditKeyPress(Sender: TObject; var Key: char);
begin
     if Ord(Key) = 13 then NoCasesEdit.SetFocus;
end;

procedure TTestGenFrm.RelEditKeyPress(Sender: TObject; var Key: char);
begin
     if Ord(Key) = 13 then ComputeBtn.SetFocus;
end;

initialization
  {$I testgenunit.lrs}

end.
