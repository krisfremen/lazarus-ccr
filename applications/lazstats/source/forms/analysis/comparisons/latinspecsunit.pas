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
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
    procedure PrepareForPlan(APlan: integer);
  end; 

var
  LatinSpecsFrm: TLatinSpecsFrm;

implementation

uses
  Math,
  Utils, LatinSqrsUnit;


{ TLatinSpecsFrm }

procedure TLatinSpecsFrm.PrepareForPlan(APlan: Integer);
begin
  ResetBtnClick(nil);
  case APlan of
    1: begin
         PanelD.Visible := false;
         PanelGrp.Visible := false;
       end;
    2: begin
         PanelD.Visible := true;
         PanelGrp.Visible := false;
       end;
    3: begin
         PanelD.Visible := true;
         PanelGrp.Visible := false;
       end;
    4: begin
         PanelD.Visible := true;
         PanelGrp.Visible := false;
       end;
    5: begin
         PanelD.Visible := false;
         PanelGrp.Visible := true;
        end;
    6: begin
         PanelD.Visible := false;
         PanelGrp.Visible := true;
       end;
    7: begin
         PanelD.Visible := true;
         PanelGrp.Visible := true;
       end;
    9: begin
         PanelD.Visible := true;
         PanelGrp.Visible := true;
       end;
  end;
end;

procedure TLatinSpecsFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  ACodeEdit.Text := '';
  BCodeEdit.Text := '';
  CCodeEdit.Text := '';
  DCodeEdit.Text := '';
  GrpCodeEdit.Text := '';
  DepVarEdit.Text := '';
  nPerCellEdit.Text := '';
  UpdatebtnStates;
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

procedure TLatinSpecsFrm.AInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (ACodeEdit.Text = '') then
  begin
    ACodeEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.AOutBtnClick(Sender: TObject);
begin
  if ACodeEdit.Text <> '' then
  begin
    VarList.Items.Add(ACodeEdit.Text);
    ACodeEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.BInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (BCodeEdit.Text = '') then
  begin
    BCodeEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.BOutBtnClick(Sender: TObject);
begin
  if BCodeEdit.Text <> '' then
  begin
    VarList.Items.Add(BCodeEdit.Text);
    BCodeEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.CInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (CCodeEdit.Text = '') then
  begin
    CCodeEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.COutBtnClick(Sender: TObject);
begin
  if CCodeEdit.Text <> '' then
  begin
    VarList.Items.Add(CCodeEdit.Text);
    CCodeEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.DataInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DepVarEdit.Text = '') then
  begin
    DepVarEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.DataOutBtnClick(Sender: TObject);
begin
  if DepVarEdit.Text <> '' then
  begin
    VarList.Items.Add(DepVarEdit.Text);
    DepVarEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.DInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (DCodeEdit.Text = '') then
  begin
    DCodeEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.DOutBtnClick(Sender: TObject);
begin
  if DCodeEdit.Text <> '' then
  begin
    VarList.Items.Add(DCodeEdit.Text);
    DCodeEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.GrpInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (GrpCodeEdit.Text = '') then
  begin
    GrpCodeEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.GrpOutBtnClick(Sender: TObject);
begin
  if GrpCodeEdit.Text <> '' then
  begin
    VarList.Items.Add(GrpCodeEdit.Text);
    GrpCodeEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TLatinSpecsFrm.OKBtnClick(Sender: TObject);
var
  C: TWinControl;
  msg: String;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    ErrorMsg(msg);
    ModalResult := mrNone;
  end;
end;

procedure TLatinSpecsFrm.UpdateBtnStates;
begin
  AInBtn.Enabled := (VarList.ItemIndex > -1) and (ACodeEdit.Text = '');
  BInBtn.Enabled := (VarList.ItemIndex > -1) and (BCodeEdit.Text = '');
  CInBtn.Enabled := (VarList.ItemIndex > -1) and (CCodeEdit.Text = '');
  DInBtn.Enabled := (VarList.ItemIndex > -1) and (DCodeEdit.Text = '');
  GrpInBtn.Enabled := (VarList.ItemIndex > -1) and (GrpCodeEdit.Text = '');
  DataInBtn.Enabled := (VarList.ItemIndex > -1) and (DepVarEdit.Text = '');

  AOutBtn.Enabled := (ACodeEdit.Text <> '');
  BOutBtn.Enabled := (BCodeEdit.Text <> '');
  COutBtn.Enabled := (CCodeEdit.Text <> '');
  DOutBtn.Enabled := (DCodeEdit.Text <> '');
  GrpOutBtn.Enabled := (GrpCodeEdit.Text <> '');
  DataOutBtn.Enabled := (DepVarEdit.Text <> '');
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
  if not TryStrToInt(nPerCellEdit.Text, n) or (n <= 0) then begin
    AMsg := 'Please specify a valid (positive) number for the cases per cell.';
    AControl := nPercellEdit;
    exit;
  end;

  if PanelA.Visible and (ACodeEdit.Text = '') then
  begin
    AMsg := 'Factor A code variable is not specified.';
    AControl := ACodeEdit;
    exit;
  end;
  if PanelB.Visible and (BCodeEdit.Text = '') then
  begin
    AMsg := 'Factor B code variable is not specified.';
    Acontrol := BCodeEdit;
    exit;
  end;
  if PanelC.Visible and (CCodeEdit.Text = '') then
  begin
    AMsg := 'Factor C code variable is not specified.';
    Acontrol := CCodeEdit;
    exit;
  end;
  if PanelD.Visible and (DCodeEdit.Text = '') then
  begin
    AMsg := 'Factor D code variable is not specified.';
    Acontrol := DCodeEdit;
    exit;
  end;
  if PanelGrp.Visible and (GrpCodeEdit.Text = '') then
  begin
    AMsg := 'Group code variable is not specified.';
    Acontrol := GrpCodeEdit;
    exit;
  end;
  if PanelDep.Visible and (DepVarEdit.Text = '') then
  begin
    AMsg := 'Dependent variable is not specified.';
    Acontrol := DepVarEdit;
    exit;
  end;

  Result := true;
end;

procedure TLatinSpecsFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;


initialization
  {$I latinspecsunit.lrs}

end.

