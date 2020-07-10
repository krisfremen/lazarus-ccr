unit TransfrmUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Math,
  Globals, FunctionsLib, DataProcs, DictionaryUnit, ContextHelpUnit;

type

  { TTransFrm }

  TTransFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Label7: TLabel;
    Label8: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    ConstantEdit: TEdit;
    Splitter1: TSplitter;
    TransEdit: TEdit;
    Label6: TLabel;
    SaveEdit: TEdit;
    Label5: TLabel;
    TransList: TListBox;
    V2Edit: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    V1Edit: TEdit;
    Label2: TLabel;
    V1InBtn: TBitBtn;
    V1OutBtn: TBitBtn;
    V2InBtn: TBitBtn;
    V2OutBtn: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure TransListClick(Sender: TObject);
    procedure V1InBtnClick(Sender: TObject);
    procedure V1OutBtnClick(Sender: TObject);
    procedure V2InBtnClick(Sender: TObject);
    procedure V2OutBtnClick(Sender: TObject);

  private
    { private declarations }
    FAutoSized: boolean;

  public
    { public declarations }
  end; 

var
  TransFrm: TTransFrm;

implementation

uses
  MainUnit, OutputUnit, Utils;

procedure TTransFrm.ResetBtnClick(Sender: TObject);
var i : integer;
begin
     VarList.Clear;
     V1Edit.Text := '';
     V2Edit.Text := '';
     ConstantEdit.Text := '';
     SaveEdit.Text := '';
     TransEdit.Text := '';
     V1InBtn.Enabled := true;
     V2InBtn.Enabled := true;
     V1OutBtn.Enabled := false;
     V2OutBtn.Enabled := false;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TTransFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

//-------------------------------------------------------------------

procedure TTransFrm.CancelBtnClick(Sender: TObject);
begin
     TransFrm.Close;
end;
//-------------------------------------------------------------------

procedure TTransFrm.ReturnBtnClick(Sender: TObject);
begin
     TransFrm.Close;
end;
//-------------------------------------------------------------------

procedure TTransFrm.ComputeBtnClick(Sender: TObject);
var
  i, TIndex, v1col, v2col, gridcol : integer;
  index, pcntile : DblDyneVec;
  cellstring : string;
  TwoArgs : boolean;
  constant, mean, stddev, N, X, Y, Z : double;
  lReport: TStrings;
begin
  constant := 0.0;
  TwoArgs := false;
  v1col := 1;
  v2col := 2;
  Y := 0.0;
  Z := 0.0;
  mean := 0.0;
  stddev := 0.0;

  lReport := TStringList.Create;
  try
    if (TransEdit.Text = '') then
    begin
      ErrorMsg('First click on the desired transformation.');
      exit;
    end;
    if (V1Edit.Text = '') then
    begin
      ErrorMsg('First click on a variable to transform.');
      exit;
    end;
    if (SaveEdit.Text = '') then
    begin
      ErrorMsg('Enter a label for the new variable.');
      exit;
    end;

    // Check to see if the transformation requires two variables
    TIndex := TransList.ItemIndex;
    if ((TIndex > 4) and (TIndex < 10)) then
    begin
        TwoArgs := true;
        if (V2Edit.Text = '') then
        begin
            ErrorMsg('Select a variable for the V2 arguement.');
            exit;
        end;
    end;

    // Find column of variable one and two (if selected)
    for i := 1 to NoVariables do
    begin
         cellstring := OS3MainFrm.DataGrid.Cells[i,0];
         if V1Edit.Text = cellstring then v1col := i;
         if (TwoArgs) then
         begin
              if cellstring = v2Edit.Text then v2col := i;
         end;
    end;

    // Check for a constant
    if (ConstantEdit.Text <> '') then
        constant := StrToFloat(ConstantEdit.Text);

    // Add new column to grid
    gridcol := NoVariables + 1;
    DictionaryFrm.NewVar(gridcol);
    DictionaryFrm.DictGrid.Cells[1,gridcol] := SaveEdit.Text;
    OS3MainFrm.DataGrid.Cells[gridcol,0] := SaveEdit.Text;
    cellstring := SaveEdit.Text;
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);

//    OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;

    SetLength(index,NoCases);
    SetLength(pcntile, NoCases);

    // Do the appropriate transformation
    if (TIndex = 21) then Rank(v1col, index); // get ranks

    // get percentile ranks
    if (TIndex = 22) or (TIndex = 24) then
      PRank(v1col, pcntile, lReport);

    if (TIndex = 20) or (TIndex = 23) then // z transformation - need mean and stddev
    begin
        mean := 0.0;
        stddev := 0.0;
        for i := 1 to NoCases do
        begin
            if IsFiltered(i) then continue;
            X := StrToFloat(OS3MainFrm.DataGrid.Cells[v1col,i]);
            mean := mean + X;
            stddev := stddev + (X * X);
        end;
        N := NoCases;
        stddev := stddev - (mean * mean) / N;
        stddev := stddev / (N - 1.0);
        stddev := sqrt(stddev);
        mean := mean / N;
    end;

    for i := 1 to NoCases do // cases
    begin
         if IsFiltered(i) then continue;
         cellstring := Trim((OS3MainFrm.DataGrid.Cells[v1col,i]));
         if cellstring = '' then continue;
        X := StrToFloat(cellstring);
        if TwoArgs then Y := StrToFloat(OS3MainFrm.DataGrid.Cells[v2col,i]);
        case TIndex of
            0 : Z := X + constant;// V1 + C
            1 : Z := X - constant;// V1 - C
            2 : Z := X * constant;// V1 * C
            3 : Z := X / constant;// V1 / C
            4 : Z := power(X,constant);// v1 ** C
            5 : Z := X + Y;// V1 + V2
            6 : Z := X - Y;// V1 - V2
            7 : Z := X * Y;// V1 * V2
            8 : Z := X / Y;// V1 / V2
            9 : Z := power(X,Y);// V1 ** V2
            10: Z := ln(X);// ln(V1)
            11: Z := log10(X);// log(V1)
            12: Z := exp(X);// exp(V1)
            13: Z := power(10.0,X);// exp(V1) base 10
            14: Z := sin(X);// sin(V1)
            15: Z := cos(X);// cos(V1)
            16: Z := tan(X);// tan(V1)
            17: Z := arcsin(X);// arcsin(V1)
            18: Z := arccos(X);// arccos(V1)
            19: Z := arctan(X);// arctan(V1)
            20: Z := (X - mean) / stddev;// z(V1)
            21: Z := index[i-1];// Rank(V1)
            22: Z := pcntile[i-1] * 100.0;// %ilerank(V1)
            23: // probz(V1)
            begin
                Y := (X - mean) / stddev;
                Z := probz(Y);
            end;
            24: // inversez(V1) - convert to %ile ranks first
            begin
                Y := pcntile[i-1]; // y is %ile rank of X
                Z := inversez(Y);
            end;
            25: Z := abs(X);// absolute value of V1: (abs(V1)
            26: // New := C
            begin
                Z := constant;
            end;
            27: Z := constant - X;// New := C - V1
            28: Z := constant / X;// New := C / V1
        end;
        OS3MainFrm.DataGrid.Cells[gridcol,i] := FloatToStr(Z);
    end;
    OS3MainFrm.DataGrid.Cells[gridcol,0] := SaveEdit.Text;

    DisplayReport(lReport);
  finally
    lReport.Free;

    index := nil;
    pcntile := nil;
  end;
end;

procedure TTransFrm.FormActivate(Sender: TObject);
begin
  if FAutoSized then
    exit;

  Panel4.Constraints.MinWidth := 2 * Panel5.Width;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TTransFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

//-------------------------------------------------------------------
procedure TTransFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

//--------------------------------------------------------------------
procedure TTransFrm.TransListClick(Sender: TObject);
var
   index : integer;
begin
     index := TransList.ItemIndex;
     TransEdit.Text := TransList.Items.Strings[index];
end;
//--------------------------------------------------------------------

procedure TTransFrm.V1InBtnClick(Sender: TObject);
var
   index : integer;
begin
     index := VarList.ItemIndex;
     V1Edit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     V1OutBtn.Enabled := true;
     V1InBtn.Enabled := false;
end;
//--------------------------------------------------------------------

procedure TTransFrm.V1OutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(V1Edit.Text);
     V1Edit.Text := '';
     V1InBtn.Enabled := true;
     V1OutBtn.Enabled := false;
end;
//--------------------------------------------------------------------

procedure TTransFrm.V2InBtnClick(Sender: TObject);
var
   index : integer;
begin
     index := VarList.ItemIndex;
     V2Edit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     V2OutBtn.Enabled := true;
     V2InBtn.Enabled := false;
end;
//--------------------------------------------------------------------

procedure TTransFrm.V2OutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(V2Edit.Text);
     V2Edit.Text := '';
     V2InBtn.Enabled := true;
     V2OutBtn.Enabled := false;
end;
//--------------------------------------------------------------------

initialization
  {$I transfrmunit.lrs}

end.

