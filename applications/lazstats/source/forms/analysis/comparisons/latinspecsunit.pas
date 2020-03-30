unit LatinSpecsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals;

type

  { TLatinSpecsFrm }

  TLatinSpecsFrm = class(TForm)
    AInBtn: TBitBtn;
    nPerCellEdit: TEdit;
    GrpOutBtn: TBitBtn;
    DataInBtn: TBitBtn;
    DataOutBtn: TBitBtn;
    AOutBtn: TBitBtn;
    BInBtn: TBitBtn;
    BOutBtn: TBitBtn;
    CInBtn: TBitBtn;
    COutBtn: TBitBtn;
    DInBtn: TBitBtn;
    DOutBtn: TBitBtn;
    GrpInBtn: TBitBtn;
    Label8: TLabel;
    PanelA: TPanel;
    PanelB: TPanel;
    PanelC: TPanel;
    PanelD: TPanel;
    PanelGrp: TPanel;
    PanelDep: TPanel;
    Panel7: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    OKBtn: TButton;
    ACodeEdit: TEdit;
    BCodeEdit: TEdit;
    CCodeEdit: TEdit;
    DCodeEdit: TEdit;
    GrpCodeEdit: TEdit;
    DepVarEdit: TEdit;
    Label1: TLabel;
    ACodeLabel: TLabel;
    BCodeLabel: TLabel;
    CCodeLabel: TLabel;
    DCodeLabel: TLabel;
    GrpCodeLabel: TLabel;
    DepVarLabel: TLabel;
    VarList: TListBox;
    Bevel1: TBevel;
    procedure AInBtnClick(Sender: TObject);
    procedure AOutBtnClick(Sender: TObject);
    procedure BInBtnClick(Sender: TObject);
    procedure BOutBtnClick(Sender: TObject);
    procedure CInBtnClick(Sender: TObject);
    procedure COutBtnClick(Sender: TObject);
    procedure DataInBtnClick(Sender: TObject);
    procedure DataOutBtnClick(Sender: TObject);
    procedure DInBtnClick(Sender: TObject);
    procedure DOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GrpInBtnClick(Sender: TObject);
    procedure GrpOutBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  LatinSpecsFrm: TLatinSpecsFrm;

implementation

uses
  Math,
  LatinSqrsUnit;


{ TLatinSpecsFrm }

procedure TLatinSpecsFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TLatinSpecsFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;
  w := MaxValue([ResetBtn.Width, CancelBtn.Width, OKBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  OKBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := Panel7.Height;

  Constraints.MinWidth := nPerCellEdit.Left + nPerCellEdit.Width + Width - ResetBtn.Left + ResetBtn.BorderSpacing.Left;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TLatinSpecsFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TLatinSpecsFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TLatinSpecsFrm.GrpInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     GrpCodeEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     GrpInBtn.Enabled := false;
     GrpOutBtn.Enabled := true;
end;

procedure TLatinSpecsFrm.GrpOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(GrpCodeEdit.Text);
     GrpCodeEdit.Text := '';
     GrpInBtn.Enabled := true;
     GrpOutBtn.Enabled := false;
end;

procedure TLatinSpecsFrm.AInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     ACodeEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     AinBtn.Enabled := false;
     AOutBtn.Enabled := true;
end;

procedure TLatinSpecsFrm.AOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(ACodeEdit.Text);
     ACodeEdit.Text := '';
     AinBtn.Enabled := true;
     AOutBtn.Enabled := false;
end;

procedure TLatinSpecsFrm.BInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     BCodeEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     BinBtn.Enabled := false;
     BOutBtn.Enabled := true;
end;

procedure TLatinSpecsFrm.BOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(BCodeEdit.Text);
     BCodeEdit.Text := '';
     BinBtn.Enabled := true;
     BOutBtn.Enabled := false;
end;

procedure TLatinSpecsFrm.CInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     CCodeEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     CinBtn.Enabled := false;
     COutBtn.Enabled := true;
end;

procedure TLatinSpecsFrm.COutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(CCodeEdit.Text);
     CCodeEdit.Text := '';
     CinBtn.Enabled := true;
     COutBtn.Enabled := false;
end;

procedure TLatinSpecsFrm.DataInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     DepVarEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     DataInBtn.Enabled := false;
     DataOutBtn.Enabled := true;
end;

procedure TLatinSpecsFrm.DataOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(DepVarEdit.Text);
     DepVarEdit.Text := '';
     DataInBtn.Enabled := true;
     DataOutBtn.Enabled := false;
end;

procedure TLatinSpecsFrm.DInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     DCodeEdit.Text := VarList.Items.Strings[index];
     VarList.Items.Delete(index);
     DinBtn.Enabled := false;
     DOutBtn.Enabled := true;
end;

procedure TLatinSpecsFrm.DOutBtnClick(Sender: TObject);
begin
     VarList.Items.Add(DCodeEdit.Text);
     DCodeEdit.Text := '';
     DinBtn.Enabled := true;
     DOutBtn.Enabled := false;
end;

procedure TLatinSpecsFrm.OKBtnClick(Sender: TObject);
var
  C: TWinControl;
  msg: String;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    ModalResult := mrNone;
  end;
end;

function TLatinSpecsFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
var
  n: Integer;
begin
  Result := false;
  if (nPerCellEdit.Text = '') then begin
    AMsg := 'Please specify the number of cases per cell.';
    AControl := nPercellEdit;
    exit;
  end;
  if not TryStrToInt(nPercellEdit.Text, n) or (n <= 0) then begin
    AMsg := 'Please specify a valid number for the cases per cell.';
    AControl := nPercellEdit;
    exit;
  end;
  Result := true;
end;


initialization
  {$I latinspecsunit.lrs}

end.

