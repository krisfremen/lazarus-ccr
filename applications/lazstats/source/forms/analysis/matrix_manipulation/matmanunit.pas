unit MatManUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Menus, StdCtrls, Grids, ExtCtrls,
  ScriptEditorUnit, RootMethodUnit, ScriptOptsUnit, ColInsertUnit,
  RowInsertUnit, OutputUnit, Globals;

type
    DynMat = array of array of double;
    DynVec = array of double;
    DynIntVec = array of integer;
    Dynstrarray = array of string;
    Scaler = double;
    ObjectNames = array of string;

type

  { TMatManFrm }

  TMatManFrm = class(TForm)
    ColVecsBox: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    keyBdmnu: TMenuItem;
    MatInmnu: TMenuItem;
    ImportFileMnu: TMenuItem;
    CommaFileInMnu: TMenuItem;
    ExportFileMnu: TMenuItem;
    CommaFileOutMnu: TMenuItem;
    ExitMnu: TMenuItem;
    IdentMnu: TMenuItem;
    ColAugMnu: TMenuItem;
    ColDelMnu: TMenuItem;
    ColInstMnu: TMenuItem;
    ExtractColVecMnu: TMenuItem;
    Diagtovecmnu: TMenuItem;
    DetermMnu: TMenuItem;
    EigenMnu: TMenuItem;
    MatSumMnu: TMenuItem;
    MatSubMnu: TMenuItem;
    MatPrintMnu: TMenuItem;
    ColxRowVecMnu: TMenuItem;
    AboutMnu: TMenuItem;
    MainGridMnu: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    SaveDialog1: TSaveDialog;
    ScriptOpsMnu: TMenuItem;
    ScrExeMnu: TMenuItem;
    ScrSavMnu: TMenuItem;
    ScriptLoadMnu: TMenuItem;
    ScriptEditMnu: TMenuItem;
    ScriptClearMnu: TMenuItem;
    ScriptPrintMnu: TMenuItem;
    PrintScalMnu: TMenuItem;
    ScalxScalMnu: TMenuItem;
    ScalRecipMnu: TMenuItem;
    ScalSqrtMnu: TMenuItem;
    RowxColVecMnu: TMenuItem;
    Splitter1: TSplitter;
    VecPrintMnu: TMenuItem;
    VecRecipMnu: TMenuItem;
    VecSqrtMnu: TMenuItem;
    VecXscalarMnu: TMenuItem;
    VecTransMnu: TMenuItem;
    TraceMnu: TMenuItem;
    TransMnu: TMenuItem;
    PostScalarMnu: TMenuItem;
    PostMatMnu: TMenuItem;
    PostColVMnu: TMenuItem;
    PostMultMnu: TMenuItem;
    PreScalarMnu: TMenuItem;
    PreMatMnu: TMenuItem;
    PrebyRowVmnu: TMenuItem;
    PreMultMnu: TMenuItem;
    NormColsMnu: TMenuItem;
    NormRowsMnu: TMenuItem;
    Vec2DiagMnu: TMenuItem;
    ULDecompMnu: TMenuItem;
    TriDiagMnu: TMenuItem;
    SVDInvMnu: TMenuItem;
    RowInstMnu: TMenuItem;
    RowDelMnu: TMenuItem;
    RowAugMnu: TMenuItem;
    ResetMnu: TMenuItem;
    ScriptSaveMnu: TMenuItem;
    ScriptFileInMnu: TMenuItem;
    SpaceFileOutMnu: TMenuItem;
    TabFileOutMnu: TMenuItem;
    SpaceFileInMnu: TMenuItem;
    TabFileInmnu: TMenuItem;
    PrintFileMnu: TMenuItem;
    SaveFileMnu: TMenuItem;
    OpenFileMnu: TMenuItem;
    ScalarInmnu: TMenuItem;
    VecInmnu: TMenuItem;
    Op1Edit: TEdit;
    Op2Edit: TEdit;
    Op3Edit: TEdit;
    Op4Edit: TEdit;
    MatFourEdit: TEdit;
    MatThreeEdit: TEdit;
    MatTwoEdit: TEdit;
    MatOneEdit: TEdit;
    GridNoEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ScriptList: TListBox;
    ScalarsBox: TComboBox;
    RowVecsBox: TComboBox;
    MatricesBox: TComboBox;
    MainMenu1: TMainMenu;
    FilesMenu: TMenuItem;
    MatOpsMnu: TMenuItem;
    HelpMnu: TMenuItem;
    ScriptOptMnu: TMenuItem;
    ScalarOpsMnu: TMenuItem;
    Grid1: TStringGrid;
    Grid2: TStringGrid;
    Grid3: TStringGrid;
    Grid4: TStringGrid;
    VecOpsMnu: TMenuItem;
    procedure AboutMnuClick(Sender: TObject);
    procedure ColAugMnuClick(Sender: TObject);
    procedure ColDelMnuClick(Sender: TObject);
    procedure ColInstMnuClick(Sender: TObject);
    procedure ColVecsBoxClick(Sender: TObject);
    procedure ColxRowVecMnuClick(Sender: TObject);
    procedure DetermMnuClick(Sender: TObject);
    procedure DiagtovecmnuClick(Sender: TObject);
    procedure EigenMnuClick(Sender: TObject);
    procedure ExitMnuClick(Sender: TObject);
    procedure ExtractColVecMnuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Grid1Click(Sender: TObject);
    procedure Grid1KeyPress(Sender: TObject; var Key: char);
    procedure Grid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Grid2Click(Sender: TObject);
    procedure Grid2KeyPress(Sender: TObject; var Key: char);
    procedure Grid2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Grid3Click(Sender: TObject);
    procedure Grid3KeyPress(Sender: TObject; var Key: char);
    procedure Grid3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Grid4Click(Sender: TObject);
    procedure Grid4KeyPress(Sender: TObject; var Key: char);
    procedure Grid4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IdentMnuClick(Sender: TObject);
    procedure MainGridMnuClick(Sender: TObject);
    procedure MatInmnuClick(Sender: TObject);
    procedure MatPrintMnuClick(Sender: TObject);
    procedure MatricesBoxClick(Sender: TObject);
    procedure MatSubMnuClick(Sender: TObject);
    procedure MatSumMnuClick(Sender: TObject);
    procedure NormColsMnuClick(Sender: TObject);
    procedure NormRowsMnuClick(Sender: TObject);
    procedure OpenFileMnuClick(Sender: TObject);
    procedure PostColVMnuClick(Sender: TObject);
    procedure PostMatMnuClick(Sender: TObject);
    procedure PrebyRowVmnuClick(Sender: TObject);
    procedure PreMatMnuClick(Sender: TObject);
    procedure PreScalarMnuClick(Sender: TObject);
    procedure PrintFileMnuClick(Sender: TObject);
    procedure PrintScalMnuClick(Sender: TObject);
    procedure ResetMnuClick(Sender: TObject);
    procedure RowAugMnuClick(Sender: TObject);
    procedure RowDelMnuClick(Sender: TObject);
    procedure RowInstMnuClick(Sender: TObject);
    procedure RowVecsBoxClick(Sender: TObject);
    procedure RowxColVecMnuClick(Sender: TObject);
    procedure SaveFileMnuClick(Sender: TObject);
    procedure ScalarInmnuClick(Sender: TObject);
    procedure ScalarsBoxClick(Sender: TObject);
    procedure ScalRecipMnuClick(Sender: TObject);
    procedure ScalSqrtMnuClick(Sender: TObject);
    procedure ScalxScalMnuClick(Sender: TObject);
    procedure ScrExeMnuClick(Sender: TObject);
    procedure ScriptClearMnuClick(Sender: TObject);
    procedure ScriptEditMnuClick(Sender: TObject);
    procedure ScriptFileInMnuClick(Sender: TObject);
    procedure ScriptListClick(Sender: TObject);
    procedure ScriptLoadMnuClick(Sender: TObject);
    procedure ScriptOpsMnuClick(Sender: TObject);
    procedure ScriptPrintMnuClick(Sender: TObject);
    procedure ScriptSaveMnuClick(Sender: TObject);
    procedure ScrSavMnuClick(Sender: TObject);
    procedure SVDInvMnuClick(Sender: TObject);
    procedure TraceMnuClick(Sender: TObject);
    procedure TransMnuClick(Sender: TObject);
    procedure TriDiagMnuClick(Sender: TObject);
    procedure ULDecompMnuClick(Sender: TObject);
    procedure Vec2DiagMnuClick(Sender: TObject);
    procedure VecInmnuClick(Sender: TObject);
    procedure VecPrintMnuClick(Sender: TObject);
    procedure VecRecipMnuClick(Sender: TObject);
    procedure VecSqrtMnuClick(Sender: TObject);
    procedure VecTransMnuClick(Sender: TObject);
    procedure VecXscalarMnuClick(Sender: TObject);
  private
    { private declarations }
    procedure GetFile(Sender: TObject);
    procedure GetGridData(gridno : integer);
    FUNCTION sign(a,b: double): double;
    FUNCTION max(a,b: double): double;
    PROCEDURE matinv(a, vtimesw, v, w: DynMat; n: integer);
    procedure ResetGrids(Sender : TObject);
    function DuplicateMat(str : string): boolean;
    function DuplicateColVec(str : string): boolean;
    function DuplicateRowVec(str : string): boolean;
    function DuplicateScaler(str : string): boolean;
    procedure tred2(VAR a: DynMat; n: integer; VAR d,e: DynVec);
    procedure ludcmp(VAR a: DynMat; n: integer; VAR indx: DynIntVec; VAR d: double);
    procedure DynMatPrint(VAR xmat : DynMat ; rows, cols : integer;
                          VAR title : string; VAR ColHeadings : Dynstrarray);
    procedure ComboAdd(FileName : String);
    procedure tqli(VAR d : DynVec; VAR e : DynVec; n : integer; VAR z : DynMat);
    procedure xtqli(VAR a : DynMat; NP : integer; VAR d : DynVec; VAR f : DynVec; VAR e : DynVec);
    function SEVS(nv, nf : integer; C : double; VAR r : DynMat; VAR v : DynMat; VAR e : DynVec; VAR p : DynVec; nd : integer) : integer;
    procedure nonsymroots(VAR a : DynMat; nv : integer; VAR nf : integer; c : double; VAR v : DynMat; VAR e : DynVec; VAR x : DynVec; VAR t : double; VAR ev : double);
    procedure OPRINC(S : DynVec; M, IA : integer; VAR EVAL : DynVec; VAR EVEC : DynMat; VAR COMP : DynMat; VAR VARPCNT : DynVec; VAR CL : DynVec; VAR CU : DynVec; VAR IER : integer);
    procedure EHOUSS(VAR A : DynVec; N : integer; VAR D : DynVec; VAR E : DynVec; VAR E2 : DynVec);
    function DSIGN(X, Y : double) : double;
    FUNCTION isign(a,b : integer): integer;
    procedure EQRT2S(VAR D : DynVec; VAR E : DynVec; N : integer; VAR Z : DynMat; VAR IZ : integer; VAR IER : integer);
    procedure EHOBKS(VAR A : DynVec; N, M1, M2 : integer; VAR Z : DynMat; IZ : integer);
    procedure UERTST(IER : integer; aNAME : string);
    procedure Roots(VAR RMat : DynMat; NITEMS : integer; VAR EIGENVAL : DynVec;
          VAR EIGENVEC : DynMat);
    procedure SymMatRoots(A : DynMat; M : integer; VAR E : DynVec; VAR V : DynMat);
    function OpParse(VAR Operation : string; OpStr : string;
                      VAR Op1 : string; VAR Op2 : string; VAR Op3 : string;
                      VAR Opergrid : integer; VAR Op1grid : integer;
                      VAR Op2grid : integer; VAR Op3grid : integer) : integer;
    procedure OperExec;

    private
    Opstr, Operation, Op1, Op2, Op3 : string;
    Opergrid, Op1grid, Op2grid, Op3grid : integer;
    ScriptName : string;

  public
    { public declarations }
    CurrentObjType : integer;
    CurrentObjName : string;
    MatCount : integer;
    ColVecCount : integer;
    RowVecCount : integer;
    ScaCount : integer;
    Matrix1 : DynMat;
    Matrix2 : DynMat;
    Matrix3 : DynMat;
    Matrix4 : DynMat;
    ScriptOp : boolean;
    LastScript : integer;
    LastGridNo : integer;
    CurrentGrid : integer;
    Rows1, Rows2, Rows3, Rows4 : integer;
    Cols1, Cols2, Cols3, Cols4 : integer;
    Rows, Cols : integer;
    Saved : boolean;

  end; 

var
  MatManFrm: TMatManFrm;

implementation

uses
  MainUnit;

{ TMatManFrm }


procedure TMatManFrm.FormCreate(Sender: TObject);
begin
  if ScriptEditorFrm <> nil then
    Application.CreateForm(TScriptEditorFrm, ScriptEditorFrm);
  if ScriptOptsFrm <> nil then
    Application.CreateForm(TScriptOptsFrm, ScriptOptsFrm);
  if OutputFrm <> nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TMatManFrm.FormShow(Sender: TObject);
var
  count, index : integer;
  filename, matext, cvecext, rvecext, scaext, extstr : string;
  scriptopts : TextFile;
  checked : integer;
begin
  ResetGrids(Self);
  matext := '.MAT';
  cvecext := '.CVE';
  rvecext := '.RVE';
  scaext := '.SCA';
  scripteditorfrm.FileListBox1.Directory := Options.DefaultDataPath;
  scripteditorfrm.FileListBox1.Update;
  count := scripteditorfrm.FileListBox1.Items.Count;
  for index := 0 to count-1 do
  begin
    filename := scripteditorfrm.FileListBox1.Items.Strings[index];
    filename := ExtractFileName(filename);
    extstr := copy(filename,Length(filename)-3,4);
    if extstr = matext then MatricesBox.Items.Add(filename);
    if extstr = cvecext then ColVecsBox.Items.Add(filename);
    if extstr = rvecext then RowVecsBox.Items.Add(filename);
    if extstr = scaext then ScalarsBox.Items.Add(filename);
  end;
  if FileExists('Options.SCR') then
  begin
    AssignFile(scriptopts, 'Options.SCR');
    Reset(scriptopts);
    Readln(scriptopts,checked);
    if checked = 1 then scriptoptsfrm.CheckGroup1.Checked[0] := true;
    Readln(scriptopts,checked);
    if checked = 1 then scriptoptsfrm.CheckGroup1.Checked[1] := true;
    CloseFile(scriptopts);
  end;
end;

procedure TMatManFrm.Grid1Click(Sender: TObject);
begin
     CurrentGrid := 1;
     CurrentObjName := MatOneEdit.Text;
     GridNoEdit.Text := IntToStr(1);
     if ((Rows1 > 2) and (Cols1 > 2)) then CurrentObjType := 1;
     if ((Rows1 > 2) and (Cols1 = 2)) then CurrentObjType := 2;
     if ((Rows1 = 2) and (Cols1 > 2)) then CurrentObjType := 3;
     if ((Rows1 = 2) and (Cols1 = 2)) then CurrentObjType := 4;
end;

procedure TMatManFrm.Grid1KeyPress(Sender: TObject; var Key: char);
var
   instr : string;

begin
     if Ord(Key) = 13 then  // return pressed
     begin
          if ((Grid1.Row = Rows) and (Grid1.Col = Cols)) then
          begin
               instr := InputBox('SAVE','Save object?','Yes');
               if instr = 'Yes' then SaveFileMnuClick(Self);
          end;
     end;
end;

procedure TMatManFrm.Grid1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i, j : integer;

begin
     if Button = mbRight then // reset the grid
     begin
          for i := 1 to rows1 do
              for j := 1 to cols1 do
                  Grid1.Cells[j,i] := '';
          Grid1.RowCount := 5;
          Grid1.ColCount := 5;
          for i := 1 to 4 do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
          for i := 1 to 4 do Grid1.Cells[0,i] := 'Row' + IntToStr(i);
          rows1 := 4;
          cols1 := 4;
          Grid1.RowCount := 5;
          Grid1.ColCount := 5;
          MatOneEdit.Text := '';
     end;
end;

procedure TMatManFrm.Grid2Click(Sender: TObject);
begin
     CurrentGrid := 2;
     CurrentObjName := MatTwoEdit.Text;
     GridNoEdit.Text := IntToStr(2);
     if ((Rows2 > 2) and (Cols2 > 2)) then CurrentObjType := 1;
     if ((Rows2 > 2) and (Cols2 = 2)) then CurrentObjType := 2;
     if ((Rows2 = 2) and (Cols2 > 2)) then CurrentObjType := 3;
     if ((Rows2 = 2) and (Cols2 = 2)) then CurrentObjType := 4;
end;

procedure TMatManFrm.Grid2KeyPress(Sender: TObject; var Key: char);
var
   instr : string;

begin
     CurrentGrid := 2;
     if Ord(Key) = 13 then  // return pressed
     begin
          if ((Grid2.Row = Rows) and (Grid2.Col = Cols)) then
          begin
               instr := InputBox('SAVE','Save object?','Yes');
               if instr = 'Yes' then SaveFileMnuClick(Self);
          end;
     end;
end;

procedure TMatManFrm.Grid2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i, j : integer;

begin
     if Button = mbRight then // reset the grid
     begin
          for i := 1 to rows2 do
              for j := 1 to cols2 do
                  Grid2.Cells[j,i] := '';
          Grid2.RowCount := 5;
          Grid2.ColCount := 5;
          for i := 1 to 4 do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
          for i := 1 to 4 do Grid2.Cells[0,i] := 'Row' + IntToStr(i);
          rows2 := 4;
          cols2 := 4;
          Grid2.RowCount := 5;
          Grid2.ColCount := 5;
          MatTwoEdit.Text := '';
     end;
end;

procedure TMatManFrm.Grid3Click(Sender: TObject);
begin
     CurrentGrid := 3;
     CurrentObjName := MatThreeEdit.Text;
     GridNoEdit.Text := IntToStr(3);
     if ((Rows3 > 2) and (Cols3 > 2)) then CurrentObjType := 1;
     if ((Rows3 > 2) and (Cols3 = 2)) then CurrentObjType := 2;
     if ((Rows3 = 2) and (Cols3 > 2)) then CurrentObjType := 3;
     if ((Rows3 = 2) and (Cols3 = 2)) then CurrentObjType := 4;
end;

procedure TMatManFrm.Grid3KeyPress(Sender: TObject; var Key: char);
var
   instr : string;

begin
     CurrentGrid := 3;
     if Ord(Key) = 13 then  // return pressed
     begin
          if ((Grid3.Row = Rows) and (Grid3.Col = Cols)) then
          begin
               instr := InputBox('SAVE','Save object?','Yes');
               if instr = 'Yes' then SaveFileMnuClick(Self);
          end;
     end;
end;

procedure TMatManFrm.Grid3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i, j : integer;

begin
     if Button = mbRight then // reset the grid
     begin
          for i := 1 to rows3 do
              for j := 1 to cols3 do
                  Grid3.Cells[j,i] := '';
          Grid3.RowCount := 5;
          Grid3.ColCount := 5;
          for i := 1 to 4 do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
          for i := 1 to 4 do Grid3.Cells[0,i] := 'Row' + IntToStr(i);
          rows3 := 4;
          cols3 := 4;
          Grid3.RowCount := 5;
          Grid3.ColCount := 5;
          MatThreeEdit.Text := '';
     end;
end;

procedure TMatManFrm.Grid4Click(Sender: TObject);
begin
     CurrentGrid := 4;
     CurrentObjName := MatFourEdit.Text;
     GridNoEdit.Text := IntToStr(4);
     if ((Rows4 > 2) and (Cols4 > 2)) then CurrentObjType := 1;
     if ((Rows4 > 2) and (Cols4 = 2)) then CurrentObjType := 2;
     if ((Rows4 = 2) and (Cols4 > 2)) then CurrentObjType := 3;
     if ((Rows4 = 2) and (Cols4 = 2)) then CurrentObjType := 4;
end;

procedure TMatManFrm.Grid4KeyPress(Sender: TObject; var Key: char);
var
   instr : string;

begin
     CurrentGrid := 4;
     if Ord(Key) = 13 then  // return pressed
     begin
          if ((Grid4.Row = Rows) and (Grid4.Col = Cols)) then
          begin
               instr := InputBox('SAVE','Save object?','Yes');
               if instr = 'Yes' then SaveFileMnuClick(Self);
          end;
     end;
end;

procedure TMatManFrm.Grid4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i, j : integer;

begin
     if Button = mbRight then // reset the grid
     begin
          for i := 1 to rows4 do
              for j := 1 to cols4 do
                  Grid4.Cells[j,i] := '';
          Grid4.RowCount := 5;
          Grid4.ColCount := 5;
          for i := 1 to 4 do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
          for i := 1 to 4 do Grid4.Cells[0,i] := 'Row' + IntToStr(i);
          rows4 := 4;
          cols4 := 4;
          Grid4.RowCount := 5;
          Grid4.ColCount := 5;
          MatFourEdit.Text := '';
     end;
end;

procedure TMatManFrm.IdentMnuClick(Sender: TObject);
var
   info, prmptstr, newstring : string;
   i, j, nsize, gridno : integer;
   wasclicked : boolean;
begin
     prmptstr := 'Enter the number of rows and columns:';
     info := InputBox('MATRIX SIZE',prmptstr,'4');
     nsize := StrToInt(info);
     if nsize <= 0 then exit;
     prmptstr := 'Place the matrix in grid:';
     info := InputBox('GRID NO.',prmptstr,IntToStr(CurrentGrid));
     gridno := StrToInt(info);
     case gridno of
     1 : begin
              Grid1.RowCount := nsize + 1;
              Grid1.ColCount := nsize + 1;
              for i := 1 to nsize do
              begin
                   for j := 1 to nsize do
                   begin
                        if i <> j then Grid1.Cells[i,j] := FloatToStr(0.0)
                        else Grid1.Cells[i,j] := FloatToStr(1.0);
                        Grid1.Cells[j,0] := 'Col.' + IntToStr(j);
                   end;
                   Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
              end;
              Rows1 := nsize;
              Cols1 := nsize;
         end;
     2 : begin
              Grid2.RowCount := nsize + 1;
              Grid2.ColCount := nsize + 1;
              for i := 1 to nsize do
              begin
                   for j := 1 to nsize do
                   begin
                        if i <> j then Grid2.Cells[i,j] := FloatToStr(0.0)
                        else Grid2.Cells[i,j] := FloatToStr(1.0);
                        Grid2.Cells[j,0] := 'Col.' + IntToStr(j);
                   end;
                   Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
              end;
              Rows2 := nsize;
              Cols2 := nsize;
         end;
     3 : begin
              Grid3.RowCount := nsize + 1;
              Grid3.ColCount := nsize + 1;
              for i := 1 to nsize do
              begin
                   for j := 1 to nsize do
                   begin
                        if i <> j then Grid3.Cells[i,j] := FloatToStr(0.0)
                        else Grid3.Cells[i,j] := FloatToStr(1.0);
                        Grid3.Cells[j,0] := 'Col.' + IntToStr(j);
                   end;
                   Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
              end;
              Rows3 := nsize;
              Cols3 := nsize;
         end;
     4 : begin
              Grid4.RowCount := nsize + 1;
              Grid4.ColCount := nsize + 1;
              for i := 1 to nsize do
              begin
                   for j := 1 to nsize do
                   begin
                        if i <> j then Grid4.Cells[i,j] := FloatToStr(0.0)
                        else Grid4.Cells[i,j] := FloatToStr(1.0);
                        Grid4.Cells[j,0] := 'Col.' + IntToStr(j);
                   end;
                   Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
              end;
              Rows4 := nsize;
              Cols4 := nsize;
         end;
     end;
     CurrentGrid := gridno;
     CurrentObjType := 1;
     CurrentObjName := 'IDMAT';
     Op1Edit.Text := Operation;
     Op2Edit.Text := 'IDMAT';
     if scriptop = false then
     begin
          prmptstr := 'Save identity matrix as ';
          newstring := 'IDMAT';
          wasclicked := InputQuery('MATRIX NAME',prmptstr,newstring);
          if wasclicked then info := newstring else info := 'IDMAT';
          CurrentObjName := info;
          Op2Edit.Text := info;
          opstr := IntToStr(gridno) + '-IDMAT:';
          opstr := opstr + IntToStr(gridno) + '-' + Op2Edit.Text;
          ScriptList.Items.Add(opstr);
          if wasclicked then SaveFileMnuClick(Self);
          ComboAdd(CurrentObjName);
     end;
     case gridno of
     1 : MatOneEdit.Text := Op2Edit.Text;
     2 : MatTwoEdit.Text := Op2Edit.Text;
     3 : MatThreeEdit.Text := Op2Edit.Text;
     4 : MatFourEdit.Text := Op2Edit.Text;
     end;
end;

procedure TMatManFrm.MainGridMnuClick(Sender: TObject);
VAR
   mrows,mcols,i,j : integer;
   titlestr, instr : string;
   FName : string;
begin
     mrows := OS3MainFrm.DataGrid.RowCount;
     mcols := OS3MainFrm.DataGrid.ColCount;
     titlestr := OS3MainFrm.FileNameEdit.Text;
     instr := InputBox('GRID?','Which grid no. (1-4):','1');
     CurrentGrid := StrToInt(instr);
     if ((CurrentGrid < 1) or (CurrentGrid > 4)) then CurrentGrid := 1;
     GridNoEdit.Text := IntToStr(CurrentGrid);
     CurrentObjName := 'MainGridData.MAT'; //titlestr;
     Rows := mrows-1;
     Cols := mcols-1;
     case CurrentGrid of
     1 : begin
              Rows1 := Rows;
              Cols1 := Cols;
              MatOneEdit.Text := CurrentObjName;
              Grid1.RowCount := Rows1+1;
              Grid1.ColCount := Cols1+1;
              for i := 0 to Rows1 do
                  for j := 0 to Cols1 do
                      Grid1.Cells[j,i] := '';
              for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row' + IntToStr(i);
              for i := 1 to Rows1 do
                  for j := 1 to Cols1 do
                      Grid1.Cells[j,i] := OS3MainFrm.DataGrid.Cells[j,i];
         end;
     2 : begin
              Rows2 := Rows;
              Cols2 := Cols;
              MatTwoEdit.Text := CurrentObjName;
              Grid2.RowCount := Rows2+1;
              Grid2.ColCount := Cols2+1;
              for i := 0 to Rows2 do
                  for j := 0 to Cols2 do
                      Grid2.Cells[j,i] := '';
              for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row' + IntToStr(i);
              for i := 1 to Rows2 do
                  for j := 1 to Cols2 do
                      Grid2.Cells[j,i] := OS3MainFrm.DataGrid.Cells[j,i];
         end;
     3 : begin
              Rows3 := Rows;
              Cols3 := Cols;
              MatThreeEdit.Text := CurrentObjName;
              Grid3.RowCount := Rows3+1;
              Grid3.ColCount := Cols3+1;
              for i := 0 to Rows3 do
                  for j := 0 to Cols3 do
                      Grid3.Cells[j,i] := '';
              for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row' + IntToStr(i);
              for i := 1 to Rows3 do
                  for j := 1 to Cols3 do
                      Grid3.Cells[j,i] := OS3MainFrm.DataGrid.Cells[j,i];
         end;
     4 : begin
              Rows4 := Rows;
              Cols4 := Cols;
              MatFourEdit.Text := CurrentObjName;
              Grid4.RowCount := Rows4+1;
              Grid4.ColCount := Cols4+1;
              for i := 0 to Rows4 do
                  for j := 0 to Cols4 do
                      Grid4.Cells[j,i] := '';
              for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row' + IntToStr(i);
              for i := 1 to Rows4 do
                  for j := 1 to Cols4 do
                      Grid4.Cells[j,i] := OS3MainFrm.DataGrid.Cells[j,i];
         end;
     end; // case
     CurrentObjType := 1;
     MatCount := MatCount + 1;
     Op1Edit.Text := 'KeyMatInput';
     Op2Edit.Text := CurrentObjName;
     Op3Edit.Text := '';
     FName := ExtractFileName(CurrentObjName);
     SaveFileMnuClick(self);
     ComboAdd(FName);
     case CurrentGrid of
          1 : Grid1.SetFocus;
          2 : Grid2.SetFocus;
          3 : Grid3.SetFocus;
          4 : Grid4.SetFocus;
     end;
end;

procedure TMatManFrm.MatInmnuClick(Sender: TObject);
var
   instr : string;
   i, j : integer;

begin
     instr := InputBox('GRID?','Which grid no. (1-4):','1');
     CurrentGrid := StrToInt(instr);
     if ((CurrentGrid < 1) or (CurrentGrid > 4)) then CurrentGrid := 1;
     GridNoEdit.Text := IntToStr(CurrentGrid);
     instr := InputBox('NAME','Object name:','AMatrix');
     CurrentObjName := instr;
     instr := InputBox('ROWS','No. of Rows = ','3');
     Rows := StrToInt(instr);
     instr := InputBox('COLS','No. of Columns = ','3');
     Cols := StrToInt(instr);
     case CurrentGrid of
     1 : begin
              Rows1 := Rows;
              Cols1 := Cols;
              MatOneEdit.Text := CurrentObjName;
              Grid1.RowCount := Rows1 + 1;
              Grid1.ColCount := Cols1 + 1;
              for i := 0 to Rows1 do
                  for j := 0 to Cols1 do
                      Grid1.Cells[j,i] := '';
              for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row' + IntToStr(i);
         end;
     2 : begin
              Rows2 := Rows;
              Cols2 := Cols;
              MatTwoEdit.Text := CurrentObjName;
              Grid2.RowCount := Rows2 + 1;
              Grid2.ColCount := Cols2 + 1;
              for i := 0 to Rows2 do
                  for j := 0 to Cols2 do
                      Grid2.Cells[j,i] := '';
              for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row' + IntToStr(i);
         end;
     3 : begin
              Rows3 := Rows;
              Cols3 := Cols;
              MatThreeEdit.Text := CurrentObjName;
              Grid3.RowCount := Rows3 + 1;
              Grid3.ColCount := Cols3 + 1;
              for i := 0 to Rows3 do
                  for j := 0 to Cols3 do
                      Grid3.Cells[j,i] := '';
              for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row' + IntToStr(i);
         end;
     4 : begin
              Rows4 := Rows;
              Cols4 := Cols;
              MatFourEdit.Text := CurrentObjName;
              Grid4.RowCount := Rows4 + 1;
              Grid4.ColCount := Cols4 + 1;
              for i := 0 to Rows4 do
                  for j := 0 to Cols4 do
                      Grid4.Cells[j,i] := '';
              for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row' + IntToStr(i);
         end;
     end; // case
     CurrentObjType := 1;
     MatCount := MatCount + 1;
     Op1Edit.Text := 'KeyMatInput';
     Op2Edit.Text := CurrentObjName;
     Op3Edit.Text := '';
     case CurrentGrid of
          1 : Grid1.SetFocus;
          2 : Grid2.SetFocus;
          3 : Grid3.SetFocus;
          4 : Grid4.SetFocus;
     end;
end;

procedure TMatManFrm.MatPrintMnuClick(Sender: TObject);
var
   Matrix : DynMat;
   ColHeadings : DynStrarray;
   i, j : integer;
   nrows, ncols : integer;
   title : string;

begin
     OutputFrm.RichEdit.Clear;
     case currentgrid of
     1 : begin
              SetLength(Matrix,Rows1,Cols1);
              SetLength(ColHeadings,Cols1);
              nrows := rows1;
              ncols := cols1;
              for i := 0 to rows1-1 do
                  for j := 0 to cols1-1 do
                      Matrix[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              for i := 1 to Cols1 do ColHeadings[i-1] := Grid1.Cells[i,0];
              title := MatOneEdit.Text;
         end;
     2 : begin
              SetLength(Matrix,Rows2,Cols2);
              SetLength(ColHeadings,Cols2);
              nrows := rows2;
              ncols := cols2;
              for i := 0 to rows2-1 do
                  for j := 0 to cols2-1 do
                      Matrix[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              for i := 1 to Cols2 do ColHeadings[i-1] := Grid2.Cells[i,0];
              title := MatTwoEdit.Text;
         end;
     3 : begin
              SetLength(Matrix,Rows3,Cols3);
              SetLength(ColHeadings,Cols3);
              nrows := rows3;
              ncols := cols3;
              for i := 0 to rows3-1 do
                  for j := 0 to cols3-1 do
                      Matrix[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              for i := 1 to Cols3 do ColHeadings[i-1] := Grid3.Cells[i,0];
              title := MatThreeEdit.Text;
         end;
     4 : begin
              SetLength(Matrix,Rows4,Cols4);
              SetLength(ColHeadings,Cols4);
              nrows := rows4;
              ncols := cols4;
              for i := 0 to rows4-1 do
                  for j := 0 to cols4-1 do
                      Matrix[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              for i := 1 to Cols4 do ColHeadings[i-1] := Grid4.Cells[i,0];
              title := MatFourEdit.Text;
         end;
     end;
     title := title + format(' From Grid Number %d',[currentgrid]);
     DynMatPrint(Matrix,nrows,ncols,title,ColHeadings);
     OutputFrm.ShowModal;
     ColHeadings := nil;
     Matrix := nil;
end;

procedure TMatManFrm.MatricesBoxClick(Sender: TObject);
var
   matstr : string;
   answer : string;
   indexno : integer;
   gridno : integer;

begin
     indexno := MatricesBox.ItemIndex;
     if indexno < 0 then exit;
     matstr := MatricesBox.Items.Strings[indexno];
     answer := InputBox('PLACEMENT','Place in which Grid?','1');
     gridno := StrToInt(answer);
     if ((gridno < 1) or (gridno > 4)) then
     begin
          ShowMessage('Error - Grid number must be between 1 and 4.');
          exit;
     end;
     CurrentGrid := gridno;
     CurrentObjType := 1;
     CurrentObjName := matstr;
     OpenDialog1.FileName := matstr;
     GetFile(Self);
     MatricesBox.Text := 'MATRICES';
     MatricesBox.ItemIndex := -1;
end;

procedure TMatManFrm.MatSubMnuClick(Sender: TObject);
// Subtraction of two matrices
var
   i, j : integer;
   precols, postcols, prerows, postrows : integer;
   info : string;
   pregrid, postgrid, resultgrid : integer;
   prmptstr : string;
   premat, postmat, prodmat : DynMat;
   clickedok : boolean;
   defaultstr : string;

begin
     if ScriptOp = false then
     begin
          prmptstr := 'The first matrix is in ';
          info := inputbox('GRID A',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          pregrid := StrToInt(info);
          prmptstr := 'The second matrix is in ';
          info := InputBox('GRID B',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          postgrid := StrToInt(info);
          info := inputbox('RESULTS INTO','Place results in grid :','3');
          if info = '' then exit;
          resultgrid := StrToInt(info);
     end
     else begin // executing the script
          pregrid := 1;
          postgrid := 2;
          resultgrid := 3;
     end;
     case pregrid of
     1 : begin
              precols := Cols1;
              prerows := Rows1;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
         Op2Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              precols := Cols2;
              prerows := Rows2;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         Op2Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              precols := Cols3;
              prerows := Rows3;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         Op2Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              precols := Cols4;
              prerows := Rows4;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         Op2Edit.Text := ExtractFileName(MatFourEdit.Text);
         end;
     end;
     case postgrid of
     1 : begin
              postcols := Cols1;
              postrows := Rows1;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              postcols := Cols2;
              postrows := Rows2;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              postcols := Cols3;
              postrows := Rows3;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              postcols := Cols4;
              postrows := Rows4;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatFourEdit.Text);
          end;
     end;
     SetLength(prodmat,prerows,precols);
     for i := 0 to prerows-1 do
         for j := 0 to precols-1 do
                 prodmat[i,j] := premat[i,j] - postmat[i,j];
     case resultgrid of
     1 : begin
              Grid1.RowCount := prerows+1;
              Grid1.ColCount := precols+1;
              Rows1 := prerows;
              Cols1 := precols;
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      Grid1.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              MatOneEdit.Text := 'MatrixDiff';
              Op4Edit.Text := MatOneEdit.Text;
              for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
         end;
     2 : begin
              Grid2.RowCount := prerows+1;
              Grid2.ColCount := precols+1;
              Rows2 := prerows;
              Cols2 := precols;
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      Grid2.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              MatTwoEdit.Text := 'MatrixDiff';
              Op4Edit.Text := MatTwoEdit.Text;
              for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
         end;
     3 : begin
              Grid3.RowCount := prerows+1;
              Grid3.ColCount := precols+1;
              Rows3 := prerows;
              Cols3 := precols;
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      Grid3.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              MatThreeEdit.Text := 'MatrixDiff';
              Op4Edit.Text := MatThreeEdit.Text;
              for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
         end;
     4 : begin
              Grid4.RowCount := prerows+1;
              Grid4.ColCount := precols+1;
              Rows4 := prerows;
              Cols4 := precols;
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      Grid4.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              MatFourEdit.Text := 'MatrixDiff';
              Op4Edit.Text := MatFourEdit.Text;
              for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
         end;
     end;
     Op1Edit.Text := 'MatMinusMat';
     opstr := IntToStr(CurrentGrid) + '-' + 'MatMinusMat:'+ IntToStr(pregrid) + '-' + Op2Edit.Text;
     opstr := opstr + ':' + IntToStr(postgrid) + '-' + Op3Edit.Text;
     if ScriptOp = false then
     begin
          prmptstr := 'Save difference as: ';
          defaultstr := 'MatMinusMat';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'MatMinusMat';
          if Length(info) > 0 then
          begin
               Op4Edit.Text := info;
          end
          else  begin
               Op4Edit.Text := 'MatMinusMat';
               info := 'MatMinusMat';
          end;
          opstr := opstr + ':' + IntToStr(resultgrid) + '-' + Op4Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 1;
          CurrentGrid := resultgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case resultgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
     // deallocate memory
     prodmat := nil;
     postmat := nil;
     premat := nil;
end;

procedure TMatManFrm.MatSumMnuClick(Sender: TObject);
// Addition of two matrices
var
   i, j : integer;
   precols, postcols, prerows, postrows : integer;
   info : string;
   pregrid, postgrid, resultgrid : integer;
   prmptstr : string;
   premat, postmat, prodmat : DynMat;
   clickedok : boolean;
   defaultstr : string;

begin
     if ScriptOp = false then
     begin
          prmptstr := 'The First Matrix in grid: ';
          info := InputBox('MATRIX A',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          pregrid := StrToInt(info);
          prmptstr := 'The second Matrix is in grid: ';
          info := inputbox('MATRIX B',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          postgrid := StrToInt(info);
          info := inputbox('RESULTS INTO','Place results in grid :','3');
          if info = '' then exit;
          resultgrid := StrToInt(info);
     end
     else begin // executing the script
          pregrid := 1;
          postgrid := 2;
          resultgrid := 3;
     end;
     case pregrid of
     1 : begin
              precols := Cols1;
              prerows := Rows1;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
         Op2Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              precols := Cols2;
              prerows := Rows2;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         Op2Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              precols := Cols3;
              prerows := Rows3;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         Op2Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              precols := Cols4;
              prerows := Rows4;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         Op2Edit.Text := ExtractFileName(MatFourEdit.Text);
         end;
     end;
     case postgrid of
     1 : begin
              postcols := Cols1;
              postrows := Rows1;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              postcols := Cols2;
              postrows := Rows2;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              postcols := Cols3;
              postrows := Rows3;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              postcols := Cols4;
              postrows := Rows4;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatFourEdit.Text);
          end;
     end;
     SetLength(prodmat,prerows,precols);
     for i := 0 to prerows-1 do
         for j := 0 to precols-1 do
                 prodmat[i,j] := premat[i,j] + postmat[i,j];
     case resultgrid of
     1 : begin
              Grid1.RowCount := prerows+1;
              Grid1.ColCount := postcols+1;
              Rows1 := prerows;
              Cols1 := precols;
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      Grid1.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
              MatOneEdit.Text := 'MatrixSum';
              Op4Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              Grid2.RowCount := prerows+1;
              Grid2.ColCount := postcols+1;
              Rows2 := prerows;
              Cols2 := precols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid2.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
              MatTwoEdit.Text := 'MatrixSum';
              Op4Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              Grid3.RowCount := prerows+1;
              Grid3.ColCount := postcols+1;
              Rows3 := prerows;
              Cols3 := precols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid3.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
              MatThreeEdit.Text := 'MatrixSum';
              Op4Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              Grid4.RowCount := prerows+1;
              Grid4.ColCount := postcols+1;
              Rows4 := prerows;
              Cols4 := precols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid4.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
              MatFourEdit.Text := 'MatrixSum';
              Op4Edit.Text := MatFourEdit.Text;
         end;
     end;
     Op1Edit.Text := 'MatPlusMat';
     opstr := IntToStr(CurrentGrid) + '-';
     opstr := opstr + 'MatPlusMat:'+ IntToStr(pregrid) + '-' + Op2Edit.Text;
     opstr := opstr + ':' + IntToStr(postgrid) + '-' + Op3Edit.Text;
     if ScriptOp = false then
     begin
          prmptstr := 'Save sum as: ';
          defaultstr := 'MatPlusMat';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'MatPlusMat';
          if Length(info) > 0 then
          begin
               Op4Edit.Text := info;
          end
          else  begin
               Op4Edit.Text := 'MatPlusMat';
               info := 'MatPlusMat';
          end;
          opstr := opstr + ':' + IntToStr(resultgrid) + '-' + Op4Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 1;
          CurrentGrid := resultgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case resultgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
     // deallocate memory
     prodmat := nil;
     postmat := nil;
     premat := nil;
end;

procedure TMatManFrm.NormColsMnuClick(Sender: TObject);
var
   i, j : integer;
   sum : double;
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
begin
     case CurrentGrid of
     1 : for j := 1 to Grid1.ColCount - 1 do
         begin
              sum := 0.0;
              for i := 1 to Grid1.RowCount - 1 do
              begin
                   sum := sum + sqr(StrToFloat(Grid1.Cells[j,i]));
              end;
              sum := sqrt(sum);
              for i := 1 to Grid1.RowCount - 1 do
              begin
                   Grid1.Cells[j,i] := FloatToStr(StrToFloat(Grid1.Cells[j,i]) / sum);
              end;
              Op2Edit.Text := MatOneEdit.Text;
         end;
     2 : for j := 1 to Grid2.ColCount - 1 do
         begin
              sum := 0.0;
              for i := 1 to Grid2.RowCount - 1 do
              begin
                   sum := sum + sqr(StrToFloat(Grid2.Cells[j,i]));
              end;
              sum := sqrt(sum);
              for i := 1 to Grid2.RowCount - 1 do
              begin
                   Grid2.Cells[j,i] := FloatToStr(StrToFloat(Grid2.Cells[j,i]) / sum);
              end;
              Op2Edit.Text := MatTwoEdit.Text;
         end;
     3 : for j := 1 to Grid3.ColCount - 1 do
         begin
              sum := 0.0;
              for i := 1 to Grid3.RowCount - 1 do
              begin
                   sum := sum + sqr(StrToFloat(Grid3.Cells[j,i]));
              end;
              sum := sqrt(sum);
              for i := 1 to Grid3.RowCount - 1 do
              begin
                   Grid3.Cells[j,i] := FloatToStr(StrToFloat(Grid3.Cells[j,i]) / sum);
              end;
              Op2Edit.Text := MatThreeEdit.Text;
         end;
     4 : for j := 1 to Grid4.ColCount - 1 do
         begin
              sum := 0.0;
              for i := 1 to Grid4.RowCount - 1 do
              begin
                   sum := sum + sqr(StrToFloat(Grid4.Cells[j,i]));
              end;
              sum := sqrt(sum);
              for i := 1 to Grid4.RowCount - 1 do
              begin
                   Grid4.Cells[j,i] := FloatToStr(StrToFloat(Grid4.Cells[j,i]) / sum);
              end;
              Op2Edit.Text := MatFourEdit.Text;
         end;
     end;

     if ScriptOp = false then
     begin
          prmptstr := 'Save normalized vectors matrix as: ';
          defaultstr := 'normalvectors';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'normalvectors';
          if Length(info) > 0 then
          begin
               Op3Edit.Text := ':' + IntToStr(CurrentGrid) + '-' + info;
          end
          else  begin
               Op3Edit.Text := 'normalvectors';
               info := 'normalvecs';
          end;
          case CurrentGrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
         opstr := IntToStr(CurrentGrid) + '-';
         Op2Edit.Text :=  ExtractFileName(Op2Edit.Text);
         opstr := opstr + 'NormalizeCols:' + Op2Edit.Text;
         opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
         ScriptList.Items.Add(opstr);
         CurrentObjName := info;
         CurrentObjType := 1;
         ComboAdd(CurrentObjName);
         if clickedok then SaveFileMnuClick(Self);
     end;
end;

procedure TMatManFrm.NormRowsMnuClick(Sender: TObject);
var
   i, j : integer;
   sum : double;
   prmptstr, info : string;
   defaultstr : string;
   clickedok : boolean;
begin
     case CurrentGrid of
     1 : for i := 1 to Grid1.RowCount - 1 do
         begin
              sum := 0.0;
              for j := 1 to Grid1.ColCount - 1 do
              begin
                   sum := sum + sqr(StrToFloat(Grid1.Cells[j,i]));
              end;
              sum := sqrt(sum);
              for j := 1 to Grid1.ColCount - 1 do
              begin
                   Grid1.Cells[j,i] := FloatToStr(StrToFloat(Grid1.Cells[j,i]) / sum);
              end;
              Op2Edit.Text := MatOneEdit.Text;
         end;
     2 : for i := 1 to Grid2.RowCount - 1 do
         begin
              sum := 0.0;
              for j := 1 to Grid2.ColCount - 1 do
              begin
                   sum := sum + sqr(StrToFloat(Grid2.Cells[j,i]));
              end;
              sum := sqrt(sum);
              for j := 1 to Grid2.ColCount - 1 do
              begin
                   Grid2.Cells[j,i] := FloatToStr(StrToFloat(Grid2.Cells[j,i]) / sum);
              end;
              Op2Edit.Text := MatTwoEdit.Text;
         end;
     3 : for i := 1 to Grid3.RowCount - 1 do
         begin
              sum := 0.0;
              for j := 1 to Grid3.ColCount - 1 do
              begin
                   sum := sum + sqr(StrToFloat(Grid3.Cells[j,i]));
              end;
              sum := sqrt(sum);
              for j := 1 to Grid3.ColCount - 1 do
              begin
                   Grid3.Cells[j,i] := FloatToStr(StrToFloat(Grid3.Cells[j,i]) / sum);
              end;
              Op2Edit.Text := MatThreeEdit.Text;
         end;
     4 : for i := 1 to Grid4.RowCount - 1 do
         begin
              sum := 0.0;
              for j := 1 to Grid4.ColCount - 1 do
              begin
                   sum := sum + sqr(StrToFloat(Grid4.Cells[j,i]));
              end;
              sum := sqrt(sum);
              for j := 1 to Grid4.ColCount - 1 do
              begin
                   Grid4.Cells[j,i] := FloatToStr(StrToFloat(Grid4.Cells[j,i]) / sum);
              end;
              Op2Edit.Text := MatFourEdit.Text;
         end;
     end;
     if ScriptOp = false then
     begin
          prmptstr := 'Save normalized rows matrix as: ';
          defaultstr := 'RowNormMat';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'RowNormMat';
          if Length(info) > 0 then
          begin
               Op3Edit.Text := info;
          end
          else  begin
               Op3Edit.Text := 'RowNormMat';
               info := 'RowNormMat';
          end;
         opstr := IntToStr(CurrentGrid) + '-';
         opstr := opstr + 'NormalizeRows:' + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
         opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
         ScriptList.Items.Add(opstr);
         CurrentObjName := info;
         CurrentObjType := 1;
         ComboAdd(CurrentObjName);
         if clickedok then SaveFileMnuClick(Self);
         case CurrentGrid of
         1 : MatOneEdit.Text := info;
         2 : MatTwoEdit.Text := info;
         3 : MatThreeEdit.Text := info;
         4 : MatFourEdit.Text := info;
         end;
     end;
end;

procedure TMatManFrm.OpenFileMnuClick(Sender: TObject);
begin
     OpenDialog1.Filter := 'Matrix (*.mat)|*.MAT|Col.Vector (*.CVE)|*.CVE|RowVector (*.RVE)|*.RVE|Scaler (*.scl)|*.SCA|All (*.*)|*.*';
     OpenDialog1.FilterIndex := CurrentObjType;
     case CurrentObjType of
          1 : OpenDialog1.DefaultExt := '.MAT';
          2 : OpenDialog1.DefaultExt := '.CVE';
          3 : OpenDialog1.DefaultExt := '.RVE';
          4 : OpenDialog1.DefaultExt := '.SCA';
          else OpenDialog1.DefaultExt := '.MAT';
     end;
     GridNoEdit.Text := IntToStr(CurrentGrid);
     GetGridData(CurrentGrid);
end;

procedure TMatManFrm.PostColVMnuClick(Sender: TObject);
// postmultiplication of a matrix by a column vector
var
   i, j, k : integer;
   precols, postcols, prerows, postrows : integer;
   info : string;
   pregrid, postgrid, resultgrid : integer;
   prmptstr : string;
   premat, postmat, prodmat : DynMat;
   clickedok : boolean;
   defaultstr : string;

begin
     if ScriptOp = false then
     begin
          prmptstr := 'Multiply the pre-matrix in grid ';
          info := InputBox('PRE MATRIX',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          pregrid := StrToInt(info);
          prmptstr := 'By the post-vector in grid ';
          info := inputbox('POST VECTOR',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          postgrid := StrToInt(info);
          info := inputbox('RESULTS INTO','Place results in grid :','3');
          if info = '' then exit;
          resultgrid := StrToInt(info);
     end
     else begin // executing the script
          pregrid := 1;
          postgrid := 2;
          resultgrid := 3;
     end;
     case pregrid of
     1 : begin
              precols := Cols1;
              prerows := Rows1;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
         Op2Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              precols := Cols2;
              prerows := Rows2;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         Op2Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              precols := Cols3;
              prerows := Rows3;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         Op2Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              precols := Cols4;
              prerows := Rows4;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         Op2Edit.Text := MatFourEdit.Text;
         end;
     end;
     case postgrid of
     1 : begin
              postcols := Cols1;
              postrows := Rows1;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op3Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              postcols := Cols2;
              postrows := Rows2;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op3Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              postcols := Cols3;
              postrows := Rows3;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op3Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              postcols := Cols4;
              postrows := Rows4;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op3Edit.Text := MatFourEdit.Text;
          end;
     end;
     SetLength(prodmat,prerows,postcols);
     for i := 0 to prerows-1 do
         for j := 0 to postcols-1 do
             for k := 0 to precols-1 do
                 prodmat[i,j] := prodmat[i,j] + (premat[i,k]*postmat[k,j]);
     case resultgrid of
     1 : begin
              Grid1.RowCount := prerows+1;
              Grid1.ColCount := postcols+1;
              Rows1 := prerows;
              Cols1 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid1.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
         end;
     2 : begin
              Grid2.RowCount := prerows+1;
              Grid2.ColCount := postcols+1;
              Rows2 := prerows;
              Cols2 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid2.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
         end;
     3 : begin
              Grid3.RowCount := prerows+1;
              Grid3.ColCount := postcols+1;
              Rows3 := prerows;
              Cols3 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid3.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
         end;
     4 : begin
              Grid4.RowCount := prerows+1;
              Grid4.ColCount := postcols+1;
              Rows4 := prerows;
              Cols4 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid4.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
         end;
     end;
     Op1Edit.Text := 'PreMatxPostVec';
     if ScriptOp = false then
     begin
          prmptstr := 'Save product vector as: ';
          defaultstr := 'MatxVec';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'MatxVec';
          if Length(info) > 0 then Op4Edit.Text := info
          else Op4Edit.Text := 'MatxVec';
          Op2Edit.Text := ExtractFileName(Op2Edit.Text);
          Op3Edit.Text := ExtractFileName(Op3Edit.Text);
          opstr := IntToStr(CurrentGrid) + '-';
          opstr := opstr + 'PreMatxPostVec:' + IntToStr(pregrid) + '-' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(postgrid) + '-' + Op3Edit.Text;
          opstr := opstr + ':' + IntToStr(resultgrid) + '-' + Op4Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 2;
          CurrentGrid := resultgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case resultgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
     // deallocate memory
     prodmat := nil;
     postmat := nil;
     premat := nil;
end;

procedure TMatManFrm.PostMatMnuClick(Sender: TObject);
begin
     PreMatMnuClick(Self);
end;

procedure TMatManFrm.PrebyRowVmnuClick(Sender: TObject);
// premultiplication of a matrix by a row vector
var
   i, j, k : integer;
   precols, postcols, prerows, postrows : integer;
   info : string;
   pregrid, postgrid, resultgrid : integer;
   prmptstr : string;
   premat, postmat, prodmat : DynMat;
   clickedok : boolean;
   defaultstr : string;

begin
     if ScriptOp = false then
     begin
          prmptstr := 'The row vector is in grid: ';
          info := InputBox('VECTOR GRID',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          pregrid := StrToInt(info);
          prmptstr := 'The post-matrix is in grid:';
          info := inputbox('POST MATRIX',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          postgrid := StrToInt(info);
          info := inputbox('RESULTS INTO','Place results in grid :','3');
          if info = '' then exit;
          resultgrid := StrToInt(info);
     end
     else begin // executing the script
          pregrid := 1;
          postgrid := 2;
          resultgrid := 3;
     end;
     case pregrid of  // row vector
     1 : begin
              precols := Cols1;
              prerows := Rows1;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op2Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              precols := Cols2;
              prerows := Rows2;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op2Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              precols := Cols3;
              prerows := Rows3;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op2Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              precols := Cols4;
              prerows := Rows4;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op2Edit.Text := MatFourEdit.Text;
         end;
     end;
     case postgrid of
     1 : begin
              postcols := Cols1;
              postrows := Rows1;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op3Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              postcols := Cols2;
              postrows := Rows2;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op3Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              postcols := Cols3;
              postrows := Rows3;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op3Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              postcols := Cols4;
              postrows := Rows4;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op3Edit.Text := MatFourEdit.Text;
          end;
     end;
     SetLength(prodmat,prerows,postcols);
     for i := 0 to prerows-1 do
         for j := 0 to postcols-1 do
             for k := 0 to precols-1 do
                 prodmat[i,j] := prodmat[i,j] + (premat[i,k]*postmat[k,j]);
     case resultgrid of
     1 : begin
              Grid1.RowCount := prerows+1;
              Grid1.ColCount := postcols+1;
              Rows1 := prerows;
              Cols1 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid1.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
              MatOneEdit.Text := 'Product';
              Op4Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              Grid2.RowCount := prerows+1;
              Grid2.ColCount := postcols+1;
              Rows2 := prerows;
              Cols2 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid2.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
              MatTwoEdit.Text := 'Product';
              Op4Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              Grid3.RowCount := prerows+1;
              Grid3.ColCount := postcols+1;
              Rows3 := prerows;
              Cols3 := postrows;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid3.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
              MatThreeEdit.Text := 'Product';
              Op4Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              Grid4.RowCount := prerows+1;
              Grid4.ColCount := postcols+1;
              Rows4 := prerows;
              Cols4 := postrows;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid4.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
              MatFourEdit.Text := 'Product';
              Op4Edit.Text := MatFourEdit.Text;
         end;
     end;
     Op1Edit.Text := 'PreVecxPostMat';
     if ScriptOp = false then
     begin
          prmptstr := 'Save product as: ';
          defaultstr := 'RowxMat';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'RowxMat';
          if Length(info) > 0 then Op4Edit.Text := info
          else  begin
               Op4Edit.Text := 'RowxMat';
               info := 'RowxMat';
          end;
          opstr := IntToStr(CurrentGrid) + '-';
          Op2Edit.Text := ExtractFileName(Op2Edit.Text);
          opstr := opstr + 'PreVecxPostMat:' + IntToStr(pregrid) + '-' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(postgrid) + '-' + ExtractFileName(Op3Edit.Text);
          opstr := opstr + ':' + IntToStr(resultgrid) + '-' + ExtractFileName(Op4Edit.Text);
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 3;
          CurrentGrid := resultgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case resultgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
     // deallocate memory
     prodmat := nil;
     postmat := nil;
     premat := nil;
end;

procedure TMatManFrm.PreMatMnuClick(Sender: TObject);
// premultiplication of a matrix by another matrix
var
   i, j, k : integer;
   precols, postcols, prerows, postrows : integer;
   info : string;
   pregrid, postgrid, resultgrid : integer;
   prmptstr : string;
   premat, postmat, prodmat : DynMat;
   clickedok : boolean;
   defaultstr : string;

begin
     if ScriptOp = false then
     begin
          prmptstr := 'Multiply the pre-matrix in grid ';
          info := InputBox('PRE MAT GRID',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          pregrid := StrToInt(info);
          prmptstr := 'Times the post-matrix in grid';
          info := InputBox('POST MAT GRID',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          postgrid := StrToInt(info);
          info := inputbox('RESULTS INTO','Place results in grid :','3');
          if info = '' then exit;
          resultgrid := StrToInt(info);
     end
     else begin // executing the script
          pregrid := 1;
          postgrid := 2;
          resultgrid := 3;
     end;
     case pregrid of
     1 : begin
              precols := Cols1;
              prerows := Rows1;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op2Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              precols := Cols2;
              prerows := Rows2;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op2Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              precols := Cols3;
              prerows := Rows3;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op2Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              precols := Cols4;
              prerows := Rows4;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op2Edit.Text := MatFourEdit.Text;
         end;
     end;
     case postgrid of
     1 : begin
              postcols := Cols1;
              postrows := Rows1;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op3Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              postcols := Cols2;
              postrows := Rows2;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op3Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              postcols := Cols3;
              postrows := Rows3;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op3Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              postcols := Cols4;
              postrows := Rows4;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op3Edit.Text := MatFourEdit.Text;
          end;
     end;

     SetLength(prodmat,prerows,postcols);
     for i := 0 to prerows-1 do
         for j := 0 to postcols-1 do
             for k := 0 to precols-1 do
                 prodmat[i,j] := prodmat[i,j] + (premat[i,k]*postmat[k,j]);

     case resultgrid of
     1 : begin
              Grid1.RowCount := prerows+1;
              Grid1.ColCount := postcols+1;
              Rows1 := prerows;
              Cols1 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid1.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to prerows do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to postcols do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
         end;
     2 : begin
              Grid2.RowCount := prerows+1;
              Grid2.ColCount := postcols+1;
              Rows2 := prerows;
              Cols2 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid2.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to prerows do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to postcols do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
         end;
     3 : begin
              Grid3.RowCount := prerows+1;
              Grid3.ColCount := postcols+1;
              Rows3 := prerows;
              Cols3 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid3.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to prerows do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to postcols do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
         end;
     4 : begin
              Grid4.RowCount := prerows+1;
              Grid4.ColCount := postcols+1;
              Rows4 := prerows;
              Cols4 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid4.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to prerows do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to postcols do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
         end;
     end;
     Op1Edit.Text := 'PreMatxPostMat';
     if ScriptOp = false then
     begin
          prmptstr := 'Save result as: ';
          defaultstr := 'MatxMat';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'MatxMat';
          if Length(info) > 0 then
          begin
               Op4Edit.Text := info;
               Op4Edit.Text := IntToStr(resultgrid) + '-' + Op4Edit.Text;
          end
          else Op4Edit.Text := '';
          opstr := IntToStr(CurrentGrid) + '-';
          Op2Edit.Text := ExtractFileName(Op2Edit.Text);
          Op2Edit.Text := IntToStr(pregrid) + '-' + Op2Edit.Text;
          opstr := opstr + 'PreMatxPostMat:'+ Op2Edit.Text;
          Op3Edit.Text := ExtractFileName(Op3Edit.Text);
          Op3Edit.Text := IntToStr(postgrid) + '-' + Op3Edit.Text;
          opstr := opstr + ':' + Op3Edit.Text;
          if Length(info) > 0 then opstr := opstr + ':' + Op4Edit.Text;
          ScriptList.Items.Add(opstr);
          if Length(info) > 0 then
          begin
               case resultgrid of
               1 : MatOneEdit.Text := info;
               2 : MatTwoEdit.Text := info;
               3 : MatThreeEdit.Text := info;
               4 : MatFourEdit.Text := info;
               end;
               CurrentObjName := info;
               CurrentObjType := 1;
               CurrentGrid := resultgrid;
               if clickedok then SaveFileMnuClick(Self);
          end;
          ComboAdd(CurrentObjName);
     end;
     // deallocate memory
     prodmat := nil;
     postmat := nil;
     premat := nil;
end;

procedure TMatManFrm.PreScalarMnuClick(Sender: TObject);
// premultiplication of a matrix by a scaler
var
   i, j : integer;
   precols, postcols, prerows, postrows : integer;
   info : string;
   pregrid, postgrid, resultgrid : integer;
   prmptstr : string;
   premat, postmat, prodmat : DynMat;
   clickedok : boolean;
   defaultstr : string;

begin
     if ScriptOp = false then
     begin
          prmptstr := 'The scalar is in grid: ';
          info := InputBox('SCALAR GRID',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          pregrid := StrToInt(info);
          prmptstr := 'The matrix is in grid: ';
          info := InputBox('MATRIX GRID',prmptstr,IntToStr(CurrentGrid));
          postgrid := StrToInt(info);
          info := inputbox('RESULTS INTO','Place results in grid :','3');
          if info = '' then exit;
          resultgrid := StrToInt(info);
     end
     else begin // executing the script
          pregrid := 1;
          postgrid := 2;
          resultgrid := 3;
     end;
     case pregrid of
     1 : begin
              precols := Cols1;
              prerows := Rows1;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op2Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              precols := Cols2;
              prerows := Rows2;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op2Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              precols := Cols3;
              prerows := Rows3;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op2Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              precols := Cols4;
              prerows := Rows4;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op2Edit.Text := ExtractFileName(MatFourEdit.Text);
         end;
     end;
     case postgrid of
     1 : begin
              postcols := Cols1;
              postrows := Rows1;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              postcols := Cols2;
              postrows := Rows2;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              postcols := Cols3;
              postrows := Rows3;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              postcols := Cols4;
              postrows := Rows4;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op3Edit.Text := ExtractFileName(MatFourEdit.Text);
          end;
     end;
     SetLength(prodmat,postrows,postcols);
     for i := 0 to postrows-1 do
         for j := 0 to postcols-1 do
                 prodmat[i,j] := premat[0,0]*postmat[i,j];
     case resultgrid of
     1 : begin
              Grid1.RowCount := postrows+1;
              Grid1.ColCount := postcols+1;
              Rows1 := postrows;
              Cols1 := postcols;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      Grid1.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
              MatOneEdit.Text := 'Product';
         end;
     2 : begin
              Grid2.RowCount := postrows+1;
              Grid2.ColCount := postcols+1;
              Rows2 := postrows;
              Cols2 := postcols;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      Grid2.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
              MatTwoEdit.Text := 'Product';
         end;
     3 : begin
              Grid3.RowCount := postrows+1;
              Grid3.ColCount := postcols+1;
              Rows3 := postrows;
              Cols3 := postcols;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      Grid3.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
              MatThreeEdit.Text := 'Product';
         end;
     4 : begin
              Grid4.RowCount := postrows+1;
              Grid4.ColCount := postcols+1;
              Rows4 := postrows;
              Cols4 := postcols;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      Grid4.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
              MatFourEdit.Text := 'Product';
         end;
     end;
     Op1Edit.Text := 'ScalerxPostMat';
     opstr := IntToStr(CurrentGrid) + '-';
     opstr := opstr + 'ScalerxPostMat:' + IntToStr(pregrid) + '-' + Op2Edit.Text;
     opstr := opstr + ':' + IntToStr(postgrid) + '-' + Op3Edit.Text;
     if ScriptOp = false then
     begin
          prmptstr := 'Save product as: ';
          defaultstr := 'ScalarxMat';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'ScalarxMat';
          if Length(info) > 0 then
          begin
               Op4Edit.Text := info;
          end
          else  begin
               Op4Edit.Text := 'ScalerxMat';
               info := 'ScalarxMat';
          end;
          opstr := opstr + ':' + IntToStr(resultgrid) + '-' + Op4Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 1;
          CurrentGrid := resultgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case resultgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
     // deallocate memory
     prodmat := nil;
     postmat := nil;
     premat := nil;
end;

procedure TMatManFrm.PrintFileMnuClick(Sender: TObject);
begin
  MatPrintMnuClick(self);
end;

procedure TMatManFrm.PrintScalMnuClick(Sender: TObject);
begin
  MatPrintMnuClick(self);
end;

procedure TMatManFrm.ExitMnuClick(Sender: TObject);
begin
     Matrix1 := nil;
     Matrix2 := nil;
     Matrix3 := nil;
     Matrix4 := nil;
     Close;
end;

procedure TMatManFrm.ExtractColVecMnuClick(Sender: TObject);
var
   i, excol, togrid : integer;
   prmptstr, info, collabel : string;
   clickedok : boolean;
   defaultstr : string;
begin
     case CurrentGrid of
     1 : begin
              Op2Edit.Text := MatOneEdit.Text;
              excol := Grid1.Col;
              prmptstr := 'Extract which column (1 - ' + IntToStr(excol) + ')?';
              info := InputBox('EXTRACT',prmptstr,IntToStr(excol));
              excol := StrToInt(info);
              collabel := Grid1.Cells[excol,0];
              prmptstr := 'Place vector into grid ';
              info := InputBox('GRID?',prmptstr,'2');
              togrid := StrToInt(info);
              case togrid of
              2 : begin
                     Grid2.RowCount := Grid1.RowCount;
                     Grid2.ColCount := 2;
                  end;
              3 : begin
                     Grid3.RowCount := Grid1.RowCount;
                     Grid3.ColCount := 2;
                  end;
              4: begin
                     Grid4.RowCount := Grid1.RowCount;
                     Grid4.ColCount := 2;
                  end;
              end;
              for i := 1 to rows1 do
              begin
                   case togrid of
                   2 : Grid2.Cells[1,i] := Grid1.Cells[excol,i];
                   3 : Grid3.Cells[1,i] := Grid1.Cells[excol,i];
                   4 : Grid4.Cells[1,i] := Grid1.Cells[excol,i];
                   end;
              end;
              case togrid of
              2 : begin
                       Grid2.Cells[1,0] := collabel;
                       Grid2.RowCount := Grid1.RowCount;
                       Rows2 := Grid2.RowCount - 1;
                       Grid2.ColCount := 2;
                       Cols2 := 1;
                       MatTwoEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              3 : begin
                       Grid3.Cells[1,0] := collabel;
                       Grid3.RowCount := Grid1.RowCount;
                       Rows3 := Grid3.RowCount - 1;
                       Grid3.ColCount := 2;
                       Cols3 := 1;
                       MatThreeEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              4 : begin
                       Grid4.Cells[1,0] := collabel;
                       Grid4.RowCount := Grid1.RowCount;
                       Rows4 := Grid4.RowCount - 1;
                       Grid4.ColCount := 2;
                       Cols4 := 1;
                       MatFourEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              end; // end case togrid
         end; // end case currentgrid = 1
     2 : begin
              Op2Edit.Text := MatTwoEdit.Text;
              excol := Grid2.Col;
              prmptstr := 'Extract which column (1 - ' + IntToStr(excol) + ')?';
              info := InputBox('EXTRACT',prmptstr,IntToStr(excol));
              excol := StrToInt(info);
              collabel := Grid2.Cells[excol,0];
              prmptstr := 'Place vector into grid ';
              info := InputBox('GRID?',prmptstr,'3');
              togrid := StrToInt(info);
              case togrid of
              3 : begin
                     Grid3.RowCount := Grid2.RowCount;
                     Grid3.ColCount := 2;
                  end;
              4 : begin
                     Grid4.RowCount := Grid2.RowCount;
                     Grid4.ColCount := 2;
                  end;
              1: begin
                     Grid1.RowCount := Grid2.RowCount;
                     Grid1.ColCount := 2;
                  end;
              end;
              for i := 1 to rows2 do
              begin
                   case togrid of
                   3 : Grid3.Cells[1,i] := Grid2.Cells[excol,i];
                   4 : Grid4.Cells[1,i] := Grid2.Cells[excol,i];
                   1 : Grid1.Cells[1,i] := Grid2.Cells[excol,i];
                   end;
              end;
              case togrid of
              3 : begin
                       Grid3.Cells[1,0] := collabel;
                       Grid3.RowCount := Grid2.RowCount;
                       Rows3 := Grid3.RowCount - 1;
                       Grid3.ColCount := 2;
                       Cols3 := 1;
                       MatThreeEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              4 : begin
                       Grid4.Cells[1,0] := collabel;
                       Grid4.RowCount := Grid2.RowCount;
                       Rows4 := Grid4.RowCount - 1;
                       Grid4.ColCount := 2;
                       Cols4 := 1;
                       MatFourEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              1 : begin
                       Grid1.Cells[1,0] := collabel;
                       Grid1.RowCount := Grid2.RowCount;
                       Rows1 := Grid1.RowCount - 1;
                       Grid1.ColCount := 2;
                       Cols1 := 1;
                       MatOneEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              end;
         end;
     3 : begin
              Op2Edit.Text := MatThreeEdit.Text;
              excol := Grid3.Col;
              prmptstr := 'Extract which column (1 - ' + IntToStr(excol) + ')?';
              info := InputBox('EXTRACT',prmptstr,IntToStr(excol));
              excol := StrToInt(info);
              collabel := Grid3.Cells[excol,0];
              prmptstr := 'Place vector into grid ';
              info := InputBox('GRID?',prmptstr,'4');
              togrid := StrToInt(info);
              case togrid of
              4 : begin
                     Grid4.RowCount := Grid3.RowCount;
                     Grid4.ColCount := 2;
                  end;
              1 : begin
                     Grid1.RowCount := Grid3.RowCount;
                     Grid1.ColCount := 2;
                  end;
              2: begin
                     Grid2.RowCount := Grid3.RowCount;
                     Grid2.ColCount := 2;
                  end;
              end;
              for i := 1 to rows3 do
              begin
                   case togrid of
                   4 : Grid4.Cells[1,i] := Grid3.Cells[excol,i];
                   1 : Grid1.Cells[1,i] := Grid3.Cells[excol,i];
                   2 : Grid2.Cells[1,i] := Grid3.Cells[excol,i];
                   end;
              end;
              case togrid of
              4 : begin
                       Grid4.Cells[1,0] := collabel;
                       Grid4.RowCount := Grid3.RowCount;
                       Rows4 := Grid4.RowCount - 1;
                       Grid4.ColCount := 2;
                       Cols4 := 1;
                       MatFourEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              1 : begin
                       Grid1.Cells[1,0] := collabel;
                       Grid1.RowCount := Grid3.RowCount;
                       Rows1 := Grid1.RowCount - 1;
                       Grid1.ColCount := 2;
                       Cols1 := 1;
                       MatOneEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              2 : begin
                       Grid2.Cells[1,0] := collabel;
                       Grid2.RowCount := Grid3.RowCount;
                       Rows2 := Grid2.RowCount - 1;
                       Grid2.ColCount := 2;
                       Cols2 := 1;
                       MatTwoEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              end;
         end;
     4 : begin
              Op2Edit.Text := MatFourEdit.Text;
              excol := Grid4.Col;
              prmptstr := 'Extract which column (1 - ' + IntToStr(excol) + ')?';
              info := InputBox('EXTRACT',prmptstr,IntToStr(excol));
              excol := StrToInt(info);
              collabel := Grid4.Cells[excol,0];
              prmptstr := 'Place vector into grid ';
              info := InputBox('GRID?',prmptstr,'1');
              togrid := StrToInt(info);
              case togrid of
              1 : begin
                     Grid1.RowCount := Grid4.RowCount;
                     Grid1.ColCount := 2;
                  end;
              2 : begin
                     Grid2.RowCount := Grid4.RowCount;
                     Grid2.ColCount := 2;
                  end;
              3: begin
                     Grid3.RowCount := Grid4.RowCount;
                     Grid3.ColCount := 2;
                  end;
              end;
              for i := 1 to rows4 do
              begin
                   case togrid of
                   1 : Grid1.Cells[1,i] := Grid4.Cells[excol,i];
                   2 : Grid2.Cells[1,i] := Grid4.Cells[excol,i];
                   3 : Grid3.Cells[1,i] := Grid4.Cells[excol,i];
                   end;
              end;
              case togrid of
              1 : begin
                       Grid1.Cells[1,0] := collabel;
                       Grid1.RowCount := Grid4.RowCount;
                       Rows1 := Grid1.RowCount - 1;
                       Grid1.ColCount := 2;
                       Cols1 := 1;
                       MatOneEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              2 : begin
                       Grid2.Cells[1,0] := collabel;
                       Grid2.RowCount := Grid4.RowCount;
                       Rows2 := Grid2.RowCount - 1;
                       Grid2.ColCount := 2;
                       Cols2 := 1;
                       MatTwoEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              3 : begin
                       Grid3.Cells[1,0] := collabel;
                       Grid3.RowCount := Grid4.RowCount;
                       Rows3 := Grid3.RowCount - 1;
                       Grid3.ColCount := 2;
                       Cols3 := 1;
                       MatThreeEdit.Text := 'ExtractVec';
                       Op3Edit.Text := 'ExtractVec';
                       for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Case' + IntToStr(i);
                  end;
              end; // end case togrid = 3
         end; // end case currentgrid = 4
     end; // end case currentgrid
     ColDelMnuClick(Self);

     if ScriptOp = false then
     begin
          prmptstr := 'Save Extracted vector as ';
          defaultstr := 'ExtractVector';
          clickedok := InputQuery('VECTOR NAME',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'ExtractVector';
          if Length(info) > 0 then Op3Edit.Text := info;
          opstr := IntToStr(CurrentGrid) + '-' + 'ExtractVector:';
          opstr := opstr + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(togrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentGrid := togrid;
          CurrentObjName := Op3Edit.Text;
          CurrentObjType := 2; // column vector
          if clickedok then SaveFileMnuClick(Self);
          ComboAdd(CurrentObjName);
     end;
end;

procedure TMatManFrm.ColAugMnuClick(Sender: TObject);
var
   i : integer;
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
begin
   if CurrentObjType <> 1 then
   begin
        ShowMessage('Error - Grid does not contain a matrix.');
        exit;
   end;
   if CurrentGrid = 0 then exit;
   case CurrentGrid of
   1 : begin
            Cols1 := Cols1 + 1;
            Grid1.ColCount := Cols1 + 1;
            Grid1.Cells[Cols1,0] := 'Col' + IntToStr(Cols1);
            for i := 1 to Rows1 do Grid1.Cells[Cols1,i] := FloatToStr(1.0);
            Op2Edit.Text := MatOneEdit.Text;
       end;
   2 : begin
            Cols2 := Cols2 + 1;
            Grid2.ColCount := Cols2 + 1;
            Grid2.Cells[Cols2,0] := 'Col' + IntToStr(Cols2);
            for i := 1 to Rows2 do Grid1.Cells[Cols2,i] := FloatToStr(1.0);
            Op2Edit.Text := MatTwoEdit.Text;
       end;
   3 : begin
            Cols3 := Cols3 + 1;
            Grid3.ColCount := Cols3 + 1;
            Grid3.Cells[Cols3,0] := 'Col' + IntToStr(Cols3);
            for i := 1 to Rows3 do Grid3.Cells[Cols3,i] := FloatToStr(1.0);
            Op2Edit.Text := MatThreeEdit.Text;
       end;
   4 : begin
            Cols4 := Cols4 + 1;
            Grid4.ColCount := Cols4 + 1;
            Grid4.Cells[Cols4,0] := 'Col' + IntToStr(Cols4);
            for i := 1 to Rows4 do Grid4.Cells[Cols4,i] := FloatToStr(1.0);
            Op2Edit.Text := MatFourEdit.Text;
       end;
   end; // case
   Op4Edit.Text := '';
   Op1Edit.Text := 'ColAugment';
   CurrentObjType := 1;
   if ScriptOp = false then
   begin
          prmptstr := 'Save result as: ';
          defaultstr := 'ColAugMat';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'ColAugMat';
          if Length(info) > 0 then Op3Edit.Text := ':' + IntToStr(CurrentGrid) + '-' + info
          else Op3Edit.Text := '';
          opstr := IntToStr(CurrentGrid) + '-';
          opstr := opstr + 'ColAugment:' + Op2Edit.Text;
          opstr := opstr + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          if Length(info) > 0 then
          begin
               CurrentObjName := info;
               CurrentObjType := 1;
               if clickedok then SaveFileMnuClick(Self);
          end;
          ComboAdd(CurrentObjName);
          if Length(info) > 0 then
          begin
               case CurrentGrid of
               1 : MatOneEdit.Text := info;
               2 : MatTwoEdit.Text := info;
               3 : MatThreeEdit.Text := info;
               4 : MatFourEdit.Text := info;
               end;
          end;
   end;
end;

procedure TMatManFrm.AboutMnuClick(Sender: TObject);
begin
  ShowMessage('Copyright 2010 by Bill Miller');
end;

procedure TMatManFrm.ColDelMnuClick(Sender: TObject);
var
   i, j : integer;
   delcol : integer;
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
begin
   if CurrentObjType <> 1 then
   begin
        ShowMessage('Error - Grid does not contain a matrix.');
        exit;
   end;
   if CurrentGrid = 0 then exit;
   case CurrentGrid of
   1 : begin
            delcol := Grid1.Col;
            for i := delcol + 1 to Grid1.ColCount - 1 do
                for j := 1 to Grid1.RowCount - 1 do
                    Grid1.Cells[i-1,j] := Grid1.Cells[i,j];
            Grid1.ColCount := Grid1.ColCount - 1;
            Cols1 := Cols1 - 1;
            Op2Edit.Text := MatOneEdit.Text;
       end;
   2 : begin
            delcol := Grid2.Col;
            for i := delcol + 1 to Grid2.ColCount - 1 do
                for j := 1 to Grid2.RowCount - 1 do
                    Grid2.Cells[i-1,j] := Grid2.Cells[i,j];
            Grid2.ColCount := Grid2.ColCount - 1;
            Cols2 := Cols2 - 1;
            Op2Edit.Text := MatTwoEdit.Text;
       end;
   3 : begin
            delcol := Grid3.Col;
            for i := delcol + 1 to Grid3.ColCount - 1 do
                for j := 1 to Grid3.RowCount - 1 do
                    Grid3.Cells[i-1,j] := Grid3.Cells[i,j];
            Grid3.ColCount := Grid3.ColCount - 1;
            Cols3 := Cols3 - 1;
            Op2Edit.Text := MatThreeEdit.Text;
       end;
   4 : begin
            delcol := Grid4.Col;
            for i := delcol + 1 to Grid4.ColCount - 1 do
                for j := 1 to Grid4.RowCount - 1 do
                    Grid4.Cells[i-1,j] := Grid4.Cells[i,j];
            Grid4.ColCount := Grid4.ColCount - 1;
            Cols4 := Cols4 - 1;
            Op2Edit.Text := MatFourEdit.Text;
       end;
   end;
   Op1Edit.Text := 'DeleteCol';
   CurrentObjType := 1;
   if ScriptOp = false then
   begin
          prmptstr := 'Save result as: ';
          defaultstr := 'ColDel';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'ColDel';
          if Length(info) > 0 then Op3Edit.Text := info
          else Op3Edit.Text := 'ColDel';
          opstr := IntToStr(CurrentGrid) + '-';
          Op2Edit.Text := ExtractFileName(Op2Edit.Text);
          opstr := opstr + 'DeleteCol:' + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := Op3Edit.Text;
          CurrentObjType := 1;
          if clickedok then SaveFileMnuClick(Self);
          ComboAdd(CurrentObjName);
          case CurrentGrid of
          1 : MatOneEdit.Text := Op3Edit.Text;
          2 : MatTwoEdit.Text := Op3Edit.Text;
          3 : MatThreeEdit.Text := Op3Edit.Text;
          4 : MatFourEdit.Text := Op3Edit.Text;
          end;
   end;
end;

procedure TMatManFrm.ColInstMnuClick(Sender: TObject);
var
   inscol, insgrid, i, j, showresult : integer;
   before : boolean;

begin
   if ColInsertFrm = nil then
     Application.CreateForm(TColInsertFrm, ColInsertFrm);

   showresult := ColInsertFrm.ShowModal;
   if showresult = mrCancel then exit;
   insgrid := StrToInt(ColInsertFrm.GridNoEdit.Text);
   if (insgrid < 1) or (insgrid > 4) then exit;
   if ColInsertFrm.BeforeColEdit.Text = '' then before := false else before := true;
   if before then inscol := StrToInt(ColInsertFrm.BeforeColEdit.Text)
   else inscol := StrToInt(ColInsertFrm.AfterColEdit.Text);
   case insgrid of
        1 : begin
                 Grid1.ColCount := Grid1.ColCount + 1;
                 if before then
                 begin // insert a column before inscol
                       for i := Cols1 downto inscol-1 do
                           for j := 1 to Rows1 do
                               Grid1.Cells[i+1,j] := Grid1.Cells[i,j];
                       if inscol > 1 then
                          for j := 1 to Rows1 do Grid1.Cells[inscol-1,j] := ''
                       else for j := 1 to Rows1 do Grid1.Cells[1,j] := '';
                 end
                 else begin // insert a row after insrow
                       for i := Cols1 downto inscol+1 do
                           for j := 1 to Rows1 do
                               Grid1.Cells[i+1,j] := Grid1.Cells[i,j];
                       for j := 1 to Rows1 do Grid1.Cells[inscol+1,j] := ''
                 end;
                 Cols1 := Cols1 + 1;
                 for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
            end; // end case grid 1
        2 : begin
                 Grid2.ColCount := Grid2.ColCount + 1;
                 if before then
                 begin // insert a column before inscol
                       for i := Cols2 downto inscol-1 do
                           for j := 1 to Rows2 do
                               Grid2.Cells[i+1,j] := Grid2.Cells[i,j];
                       if inscol > 1 then
                          for j := 1 to Rows2 do Grid2.Cells[inscol-1,j] := ''
                       else for j := 1 to Rows2 do Grid2.Cells[1,j] := '';
                 end
                 else begin // insert a row after inscol
                       for i := Cols2 downto inscol+1 do
                           for j := 1 to Rows2 do
                               Grid2.Cells[i+1,j] := Grid2.Cells[i,j];
                       for j := 1 to Rows2 do Grid2.Cells[inscol+1,j] := ''
                 end;
                 Cols2 := Cols2 + 1;
                 for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
            end;
        3 : begin
                 Grid3.ColCount := Grid3.ColCount + 1;
                 if before then
                 begin // insert a column before inscol
                       for i := Cols3 downto inscol-1 do
                           for j := 1 to Rows3 do
                               Grid3.Cells[i+1,j] := Grid3.Cells[i,j];
                       if inscol > 1 then
                          for j := 1 to Rows3 do Grid3.Cells[inscol-1,j] := ''
                       else for j := 1 to Rows3 do Grid3.Cells[1,j] := '';
                 end
                 else begin // insert a row after inscol
                       for i := Cols3 downto inscol+1 do
                           for j := 1 to Rows3 do
                               Grid3.Cells[i+1,j] := Grid3.Cells[i,j];
                       for j := 1 to Rows3 do Grid3.Cells[inscol+1,j] := ''
                 end;
                 Cols3 := Cols3 + 1;
                 for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
            end;
        4 : begin
                 Grid4.ColCount := Grid4.ColCount + 1;
                 if before then
                 begin // insert a column before inscol
                       for i := Cols4 downto inscol-1 do
                           for j := 1 to Rows4 do
                               Grid4.Cells[i+1,j] := Grid4.Cells[i,j];
                       if inscol > 1 then
                          for j := 1 to Rows4 do Grid4.Cells[inscol-1,j] := ''
                       else for j := 1 to Rows4 do Grid4.Cells[1,j] := '';
                 end
                 else begin // insert a row after inscol
                       for i := Cols4 downto inscol+1 do
                           for j := 1 to Rows4 do
                               Grid4.Cells[i+1,j] := Grid4.Cells[i,j];
                       for j := 1 to Rows4 do Grid4.Cells[inscol+1,j] := ''
                 end;
                 Cols4 := Cols4 + 1;
                 for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
            end;
   end; // case insgrid
end;

procedure TMatManFrm.ColVecsBoxClick(Sender: TObject);
var
   vecstr : string;
   answer : string;
   indexno : integer;
   gridno : integer;

begin
     indexno := ColVecsBox.ItemIndex;
     if indexno < 0 then exit;
     vecstr := ColVecsBox.Items.Strings[indexno];
     answer := InputBox('PLACEMENT','Place in which Grid?','1');
     gridno := StrToInt(answer);
     if ((gridno < 1) or (gridno > 4)) then
     begin
          ShowMessage('Error - Grid number must be between 1 and 4.');
          exit;
     end;
     CurrentGrid := gridno;
     CurrentObjType := 2;
     CurrentObjName := vecstr;
     OpenDialog1.FileName := vecstr;
     GetFile(Self);
     ColVecsBox.Text := 'COLUMN VECTORS';
     ColVecsBox.ItemIndex := -1;
end;

procedure TMatManFrm.ColxRowVecMnuClick(Sender: TObject);
begin
       RowxColVecMnuClick(Self);
end;

procedure TMatManFrm.DetermMnuClick(Sender: TObject);
label emsg;
var
   i, j, size, nextgrid : integer;
   prmptstr, info : string;
   intvector : DynIntVec;
   determ : double;
   clickedok : boolean;
   defaultstr : string;
begin
     if CurrentObjType <> 1 then
emsg:
     begin
          ShowMessage('Error - Selected grid does not contain a symetric matrix.');
          exit;
     end;

     case CurrentGrid of
     1 : begin
              if Rows1 <> Cols1 then goto emsg;
              size := Rows1;
              Op2Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              if Rows2 <> Cols2 then goto emsg;
              size := Rows2;
              Op2Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              if Rows3 <> Cols3 then goto emsg;
              size := Rows3;
              Op2Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              if Rows4 <> Cols4 then goto emsg;
              size := Rows4;
              Op2Edit.Text := ExtractFileName(MatFourEdit.Text);
         end;
     end;

     // allocate memory
     setlength(Matrix1,size,size);
     setlength(intvector,size);

     // store data to be decomposed in Matrix1
     case CurrentGrid of
     1 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
         nextgrid := 2;
         end;
     2 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         nextgrid := 3;
         end;
     3 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         nextgrid := 4;
         end;
     4 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         nextgrid := 1;
         end;
     end;

     // decompose
     LUDCMP(Matrix1,size,intvector,determ);
     for i := 0 to size-1 do determ := determ * Matrix1[i,i];

     // place results in next grid
     case nextgrid of
     1 : begin
              Grid1.RowCount := 2;
              Grid1.ColCount := 2;
              Rows1 := 1;
              Cols1 := 1;
              MatOneEdit.Text := 'Determinant';
              Grid1.Cells[1,1] := FloatToStr(determ);
              CurrentObjName := MatOneEdit.Text;
         end;
     2 : begin
              Grid2.RowCount := 2;
              Grid2.ColCount := 2;
              Rows2 := 1;
              Cols2 := 1;
              MatTwoEdit.Text := 'Determinant';
              Grid2.Cells[1,1] := FloatToStr(determ);
              CurrentObjName := MatTwoEdit.Text;
         end;
     3 : begin
              Grid3.RowCount := 2;
              Grid3.ColCount := 2;
              Rows3 := 1;
              Cols3 := 1;
              MatThreeEdit.Text := 'Determinant';
              Grid3.Cells[1,1] := FloatToStr(determ);
              CurrentObjName := MatThreeEdit.Text;
         end;
     4 : begin
              Grid4.RowCount := 2;
              Grid4.ColCount := 2;
              Rows4 := 1;
              Cols4 := 1;
              MatFourEdit.Text := 'Determinant';
              Grid4.Cells[1,1] := FloatToStr(determ);
              CurrentObjName := MatFourEdit.Text;
         end;
     end;
     if ScriptOp = false then
     begin
          prmptstr := 'Save determinant as: ';
          defaultstr := 'determinant';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'determinant';
          if Length(info) > 0 then Op3Edit.Text := info
          else  begin
               Op3Edit.Text := 'determinant';
               info := 'determinant';
          end;
          Op1Edit.Text := 'Determinant';
          opstr := IntToStr(CurrentGrid) + '-' + 'Determinant:';
          opstr := opstr + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(nextgrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 4;
          CurrentGrid := nextgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case nextgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;

     // deallocate memory
     intvector := nil;
     Matrix1 := nil;
end;

procedure TMatManFrm.DiagtovecmnuClick(Sender: TObject);
var
   i, j, size, matgrid, nextgrid : integer;
   diag : DynVec;
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
label emsg;

begin
     if CurrentGrid = 0 then exit;
     prmptstr := 'The matrix is in grid: ';
     info := InputBox('MATRIX GRID',prmptstr,IntToStr(CurrentGrid));
     if info = '' then exit;
     matgrid := StrToInt(info);
     if CurrentObjType <> 1 then
emsg:
     begin
          ShowMessage('Error - Selected grid does not contain a symetric matrix.');
          exit;
     end;

     case matgrid of
     1 : begin
              if Rows1 <> Cols1 then goto emsg;
              size := Rows1;
              SetLength(diag,size);
              for i := 0 to size-1 do diag[i] := StrToFloat(Grid1.Cells[i+1,i+1]);
              nextgrid := 2;
              Op2Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              if Rows2 <> Cols2 then goto emsg;
              size := Rows2;
              SetLength(diag,size);
              for i := 0 to size-1 do diag[i] := StrToFloat(Grid2.Cells[i+1,i+1]);
              nextgrid := 3;
              Op2Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              if Rows3 <> Cols3 then goto emsg;
              size := Rows3;
              SetLength(diag,size);
              for i := 0 to size-1 do diag[i] := StrToFloat(Grid3.Cells[i+1,i+1]);
              nextgrid := 4;
              Op2Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              if Rows4 <> Cols4 then goto emsg;
              size := Rows4;
              SetLength(diag,size);
              for i := 0 to size-1 do diag[i] := StrToFloat(Grid4.Cells[i+1,i+1]);
              nextgrid := 1;
              Op2Edit.Text := ExtractFileName(MatFourEdit.Text);
         end;
     end;

     // place diagonal elements in next available grid
     case nextgrid of
     1: begin
              for i := 0 to size-1 do
                  for j := 0 to size-1 do
                      Grid1.Cells[j+1,i+1] := '';
              for i := 0 to size-1 do Grid1.Cells[1,i+1] := FloatToStr(diag[i]);
              cols1 := 1;
              rows1 := size;
              Grid1.ColCount := 2;
              Grid1.RowCount := size + 1;
              MatOneEdit.Text := 'DiagVec';
        end;
     2: begin
              for i := 0 to size-1 do
                  for j := 0 to size-1 do
                      Grid2.Cells[j+1,i+1] := '';
              for i := 0 to size-1 do Grid2.Cells[1,i+1] := FloatToStr(diag[i]);
              cols2 := 1;
              rows2 := size;
              Grid2.ColCount := 2;
              Grid2.RowCount := size + 1;
              MatTwoEdit.Text := 'DiagVec';
        end;
     3: begin
              for i := 0 to size-1 do
                  for j := 0 to size-1 do
                      Grid3.Cells[j+1,i+1] := '';
              for i := 0 to size-1 do Grid3.Cells[1,i+1] := FloatToStr(diag[i]);
              cols3 := 1;
              rows3 := size;
              Grid3.ColCount := 2;
              Grid3.RowCount := size + 1;
              MatThreeEdit.Text := 'DiagVec';
        end;
     4: begin
              for i := 0 to size-1 do
                  for j := 0 to size-1 do
                      Grid4.Cells[j+1,i+1] := '';
              for i := 0 to size-1 do Grid4.Cells[1,i+1] := FloatToStr(diag[i]);
              cols4 := 1;
              rows4 := size;
              Grid4.ColCount := 2;
              Grid4.RowCount := size + 1;
              MatFourEdit.Text := 'DiagVec';
        end;
     end;

     Op1Edit.Text := 'DiagToVec:';
     opstr := IntToStr(matgrid) + '-' + 'DiagToVec:';
     opstr := opstr + IntToStr(matgrid) + '-' + Op2Edit.Text;
     if ScriptOp = false then
     begin
          prmptstr := 'Save diagonal vector as: ';
          defaultstr := 'diagvec';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'diagvec';
          if Length(info) > 0 then Op3Edit.Text := info
          else  begin
               Op3Edit.Text := 'diagvec';
               info := 'diagvec';
          end;
          opstr := opstr + ':' + IntToStr(nextgrid) + '-' + info;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 2;
          CurrentGrid := nextgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case nextgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
     diag := nil;
end;

procedure TMatManFrm.EigenMnuClick(Sender: TObject);
label emsg, finish;
var
   i, j, nfactors, size, choice : integer;
   rootsvec, avector, bvector : DynVec;
   c, trace, pcnttrace, sum : double;
   prmptstr, info : string;
   rootname, vectname : string;
   clickedok1, clickedok2 : boolean;
   defaultstr : string;
begin
     if RootMethodFrm = nil then
       Application.CreateForm(TRootMethodFrm, RootMethodFrm);

     if CurrentObjType <> 1 then
emsg:
     begin
          ShowMessage('Error - Selected grid does not contain a symetric matrix.');
          exit;
     end;
     case CurrentGrid of
     1 : begin
              if Rows1 <> Cols1 then goto emsg;
              size := Rows1;
              Op2Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              if Rows2 <> Cols2 then goto emsg;
              size := Rows2;
              Op2Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              if Rows3 <> Cols3 then goto emsg;
              size := Rows3;
              Op2Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              if Rows4 <> Cols4 then goto emsg;
              size := Rows4;
              Op2Edit.Text := ExtractFileName(MatFourEdit.Text);
         end;
     end;

     // allocate memory
     setlength(Matrix1,size,size);
     setlength(Matrix2,size,size);
     setlength(rootsvec,size);
     setlength(bvector,size);
     setlength(avector,size);

     // store data in Matrix1 to be analyzed
     case CurrentGrid of
     1 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
         end;
     2 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         end;
     3 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         end;
     4 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         end;
     end;

     c := 0.0;
     nfactors := size;
     trace := 0.0;
     sum := 0.0;
     for i := 0 to size-1 do trace := trace + Matrix1[i,i];

     // select the desired method
     if rootmethodfrm.ShowModal <> mrCancel then
          choice := rootmethodfrm.Choice
     else goto finish;
     case choice of
     1 : begin
              for i := 0 to size-1 do
                  for j := 0 to size-1 do
                      Matrix2[i,j] := Matrix1[i,j];
              sevs(size,size,c,Matrix1,Matrix2,rootsvec,bvector,size); // works! (vectors not normalized)
         end;
     2 : nonsymroots(Matrix1,size,nfactors,c,Matrix2,
                 rootsvec,bvector,trace,pcnttrace); // works (vectors not normalized)
     3 : begin
              SymMatRoots(Matrix1,size,rootsvec,Matrix2); // works! (vectors normalized)
              for i := 0 to size - 1 do bvector[i] := rootsvec[i] / trace * 100.0;
         end;
//     4 : HOWS(size,size,size,Matrix1,rootsvec,Matrix2);
     4 : begin
              xtqli(Matrix1, size, rootsvec, bvector, avector); // works! (vectors normalized)
              for i := 0 to size-1 do
                  for j := 0 to size-1 do
                      Matrix2[i,j] := Matrix1[i,j];
         end;
     5 : begin
             ROOTS(Matrix1,size,rootsvec,Matrix2); // works! (vectors normalized)
             for i := 0 to size - 1 do bvector[i] := rootsvec[i] / trace * 100.0;
         end;
     end;

     for i := 0 to size-1 do sum := sum + rootsvec[i];
     pcnttrace := (trace / sum) * 100.0;

     // Place results in the four grids
     Grid1.RowCount := Size + 1; // diagonal roots matrix in first grid
     Grid1.ColCount := Size + 1;
     Grid2.RowCount := Size + 1; // column vectors matrix in second
     Grid2.Colcount := Size + 1;
     Grid3.RowCount := Size + 1; // percentage vector in each root in 3
     Grid3.ColCount := 2;
     Grid4.RowCount := 3; // trace and %trace in 4
     Grid4.ColCount := 2;
     Rows1 := Size;
     Cols1 := Size;
     Rows2 := Size;
     Cols2 := Size;
     Rows3 := Size;
     Cols3 := 1;
     Rows4 := 2;
     Cols4 := 1;
     for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
     for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col ' + IntToStr(i);
     for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
     for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col ' + IntToStr(i);
     for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
     for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col ' + IntToStr(i);
     for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
     for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col ' + IntToStr(i);
     Grid4.Cells[0,1] := 'Trace';
     Grid4.Cells[0,2] := '%Extract';
     MatOneEdit.Text := 'Roots';
     MatTwoEdit.Text := 'vectors';
     MatThreeEdit.Text := 'RootPcnts';
     MatFourEdit.Text := 'Trace&Pcnt';
     for i := 0 to size - 1 do
     begin
          for j := 0 to size - 1 do
          begin
               if i = j then
               begin
                    Grid1.Cells[i+1,i+1] := FloatToStr(rootsvec[i]);
               end
               else Grid1.Cells[j+1,i+1] := FloatToStr(0.0);
          end;
     end;
     for i := 0 to size - 1 do
          for j := 0 to size - 1 do
               Grid2.Cells[j+1,i+1] := FloatToStr(Matrix2[i,j]);
     for i := 0 to size - 1 do Grid3.Cells[1,i+1] := FloatToStr(bvector[i]);
     Grid4.Cells[1,1] := FloatToStr(trace);
     Grid4.Cells[1,2] := FloatToStr(pcnttrace);
     Op1Edit.Text := 'MatrixRoots';
     opstr := IntToStr(CurrentGrid) + '-';
     opstr := opstr + 'MatrixRoots:' + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;

     if ScriptOp = false then
     begin
          prmptstr := 'Save roots diagonal matrix as: ';
          defaultstr := 'roots';
          clickedok1 := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok1 then info := defaultstr else info := 'roots';
          if Length(info) > 0 then rootname := info
          else rootname := 'roots';
          prmptstr := 'Save eigenvectors as: ';
          defaultstr := 'eigenvectors';
          clickedok2 := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok2 then info := defaultstr else info := 'eigenvectors';
          if Length(info) > 0 then vectname := info
          else vectname := 'eigenvectors';
          MatOneEdit.Text := rootname;
          MatTwoEdit.Text := vectname;
          opstr := opstr + ':' + IntToStr(1) + '-' + rootname;
          opstr := opstr + ':' + IntToStr(2) + '-' + vectname;
          ScriptList.Items.Add(opstr);
          // save roots
          CurrentObjName := rootname;
          CurrentObjType := 1;
          CurrentGrid := 1;
          MatOneEdit.Text := rootname;
          ComboAdd(CurrentObjName);
          if clickedok1 then SaveFileMnuClick(Self);
          // save vectors
          CurrentObjName := vectname;
          CurrentObjType := 1;
          CurrentGrid := 2;
          ComboAdd(CurrentObjName);
          if clickedok2 then SaveFileMnuClick(Self);
          MatTwoEdit.Text := vectname;
     end;
finish:
     // deallocate memory
     avector := nil;
     bvector := nil;
     Matrix2 := nil;
     Matrix1 := nil;
     rootsvec := nil;
end;

procedure TMatManFrm.ResetMnuClick(Sender: TObject);
begin
     FormShow(Self);
end;

procedure TMatManFrm.RowAugMnuClick(Sender: TObject);
var
   i : integer;
   prmptstr, info, defaultstr : string;
   clickedok : boolean;
begin
   if CurrentObjType <> 1 then
   begin
        ShowMessage('Error - Grid does not contain a matrix.');
        exit;
   end;
   if CurrentGrid = 0 then exit;
   case CurrentGrid of
   1 : begin
            Rows1 := Rows1 + 1;
            Grid1.RowCount := Rows1 + 1;
            Grid1.Cells[0,Rows1] := 'Row' + IntToStr(Rows1);
            for i := 1 to Cols1 do Grid1.Cells[i,Rows1] := FloatToStr(1.0);
            Op2Edit.Text := MatOneEdit.Text;
       end;
   2 : begin
            Rows2 := Rows2 + 1;
            Grid2.RowCount := Rows2 + 1;
            Grid2.Cells[0,Rows2] := 'Row' + IntToStr(Rows2);
            for i := 1 to Cols2 do Grid2.Cells[i,Rows2] := FloatToStr(1.0);
            Op2Edit.Text := MatTwoEdit.Text;
       end;
   3 : begin
            Rows3 := Rows3 + 1;
            Grid3.RowCount := Rows3 + 1;
            Grid3.Cells[0,Rows3] := 'Row' + IntToStr(Rows3);
            for i := 1 to Cols3 do Grid3.Cells[i,Rows3] := FloatToStr(1.0);
            Op2Edit.Text := MatThreeEdit.Text;
       end;
   4 : begin
            Rows4 := Rows4 + 1;
            Grid4.RowCount := Rows4 + 1;
            Grid4.Cells[0,Rows4] := 'Row' + IntToStr(Rows4);
            for i := 1 to Cols4 do Grid4.Cells[i,Rows4] := FloatToStr(1.0);
            Op2Edit.Text := MatFourEdit.Text;
       end;
   end; // case
   Op1Edit.Text := 'RowAugment';
   CurrentObjType := 1;
   opstr := IntToStr(CurrentGrid) + '-';
   Op2Edit.Text := ExtractFileName(Op2Edit.Text);
   opstr := opstr + 'RowAugment:' + Op2Edit.Text;
   if ScriptOp = false then
   begin
       prmptstr := 'Save result as: ';
       defaultstr := 'RowAugMat';
       clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
       if clickedok then info := defaultstr else info := 'RowAugMat';
       if Length(info) > 0 then Op3Edit.Text := info
       else Op3Edit.Text := 'RowAugMat';
       case CurrentGrid of
       1 : MatOneEdit.Text := Op3Edit.Text;
       2 : MatTwoEdit.Text := Op3Edit.Text;
       3 : MatThreeEdit.Text := Op3Edit.Text;
       4 : MatFourEdit.Text := Op3Edit.Text;
       end;
       opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
       ScriptList.Items.Add(opstr);
       CurrentObjName := Op3Edit.Text;
       CurrentObjType := 1;
       if clickedok then SaveFileMnuClick(Self);
       ComboAdd(CurrentObjName);
   end;
end;

procedure TMatManFrm.RowDelMnuClick(Sender: TObject);
var
   i, j : integer;
   delrow : integer;
   prmptstr, info, defaultstr : string;
   clickedok : boolean;
begin
   if CurrentObjType <> 1 then
   begin
        ShowMessage('Error - Grid does not contain a matrix.');
        exit;
   end;
   if CurrentGrid = 0 then exit;
   case CurrentGrid of
   1 : begin
            delrow := Grid1.Row;
            for i := delrow + 1 to Grid1.RowCount - 1 do
                for j := 1 to Grid1.ColCount - 1 do
                    Grid1.Cells[j,i-1] := Grid1.Cells[j,i];
            Grid1.RowCount := Grid1.RowCount - 1;
            Rows1 := Rows1 - 1;
            Op2Edit.Text := MatOneEdit.Text;
       end;
   2 : begin
            delrow := Grid2.Row;
            for i := delrow + 1 to Grid2.RowCount - 1 do
                for j := 1 to Grid2.ColCount - 1 do
                    Grid2.Cells[j,i-1] := Grid2.Cells[j,i];
            Grid2.RowCount := Grid2.RowCount - 1;
            Rows2 := Rows2 - 1;
            Op2Edit.Text := MatTwoEdit.Text;
       end;
   3 : begin
            delrow := Grid3.Row;
            for i := delrow + 1 to Grid3.RowCount - 1 do
                for j := 1 to Grid3.ColCount - 1 do
                    Grid3.Cells[j,i-1] := Grid3.Cells[j,i];
            Grid3.RowCount := Grid3.RowCount - 1;
            Rows3 := Rows3 - 1;
            Op2Edit.Text := MatThreeEdit.Text;
       end;
   4 : begin
            delrow := Grid4.Row;
            for i := delrow + 1 to Grid4.RowCount - 1 do
                for j := 1 to Grid4.ColCount - 1 do
                    Grid4.Cells[j,i-1] := Grid4.Cells[j,i];
            Grid4.RowCount := Grid4.RowCount - 1;
            Rows4 := Rows4 - 1;
            Op2Edit.Text := MatFourEdit.Text;
       end;
   end;
   Op1Edit.Text := 'DeleteRow';
   CurrentObjType := 1;
   if ScriptOp = false then
   begin
          prmptstr := 'Save result as: ';
          defaultstr := 'RowDeleted';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'RowDeleted';
          if Length(info) > 0 then Op3Edit.Text := info
          else Op3Edit.Text := 'RowDeleted';
          opstr := IntToStr(CurrentGrid) + '-';
          Op2Edit.Text := ExtractFileName(Op2Edit.Text);
          opstr := opstr + 'DeleteRow:' + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := Op3Edit.Text;
          CurrentObjType := 1;
          if clickedok then SaveFileMnuClick(Self);
          ComboAdd(CurrentObjName);
          case CurrentGrid of
          1 : MatOneEdit.Text := Op3Edit.Text;
          2 : MatTwoEdit.Text := Op3Edit.Text;
          3 : MatThreeEdit.Text := Op3Edit.Text;
          4 : MatFourEdit.Text := Op3Edit.Text;
          end;
   end;
end;

procedure TMatManFrm.RowInstMnuClick(Sender: TObject);
var
   insrow, insgrid, i, j, showresult : integer;
   before : boolean;

begin
  if RowInsertFrm = nil then
    Application.CreateForm(TRowInsertFrm, RowInsertFrm);

  showresult := RowInsertFrm.ShowModal;
  if showresult = mrCancel then exit;
  insgrid := StrToInt(RowInsertFrm.GridNoEdit.Text);
  if (insgrid < 1) or (insgrid > 4) then exit;
  if RowInsertFrm.BeforeEdit.Text = '' then before := false else before := true;
  if before then insrow := StrToInt(RowInsertFrm.BeforeEdit.Text)
  else insrow := StrToInt(RowInsertFrm.AfterEdit.Text);
  case insgrid of
      1 : begin
               Grid1.RowCount := Grid1.RowCount + 1;
               if before then
               begin // insert a row before insrow
                     for i := Rows1 downto insrow-1 do
                         for j := 1 to Cols1 do
                             Grid1.Cells[j,i+1] := Grid1.Cells[j,i];
                     if insrow > 1 then
                        for j := 1 to Cols1 do Grid1.Cells[j,insrow-1] := ''
                     else for j := 1 to Cols1 do Grid1.Cells[j,1] := '';
               end
               else begin // insert a row after insrow
                     for i := Rows1 downto insrow+1 do
                         for j := 1 to Cols1 do
                             Grid1.Cells[j,i+1] := Grid1.Cells[j,i];
                     for j := 1 to Cols1 do Grid1.Cells[j,insrow+1] := ''
               end;
               Rows1 := Rows1 + 1;
               for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
          end; // end case grid 1
      2 : begin
               Grid2.RowCount := Grid2.RowCount + 1;
               if before then
               begin // insert a row before insrow
                     for i := Rows2 downto insrow-1 do
                         for j := 1 to Cols2 do
                             Grid2.Cells[j,i+1] := Grid2.Cells[j,i];
                     if insrow > 1 then
                        for j := 1 to Cols2 do Grid2.Cells[j,insrow-1] := ''
                     else for j := 1 to Cols2 do Grid2.Cells[j,1] := '';
               end
               else begin // insert a row after insrow
                     for i := Rows2 downto insrow+1 do
                         for j := 1 to Cols2 do
                             Grid2.Cells[j,i+1] := Grid2.Cells[j,i];
                     for j := 1 to Cols2 do Grid2.Cells[j,insrow+1] := ''
               end;
               Rows2 := Rows2 + 1;
               for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
          end;
      3 : begin
               Grid3.RowCount := Grid3.RowCount + 1;
               if before then
               begin // insert a row before insrow
                     for i := Rows3 downto insrow-1 do
                         for j := 1 to Cols3 do
                             Grid3.Cells[j,i+1] := Grid3.Cells[j,i];
                     if insrow > 1 then
                        for j := 1 to Cols3 do Grid3.Cells[j,insrow-1] := ''
                     else for j := 1 to Cols3 do Grid3.Cells[j,1] := '';
               end
               else begin // insert a row after insrow
                     for i := Rows3 downto insrow+1 do
                         for j := 1 to Cols3 do
                             Grid3.Cells[j,i+1] := Grid3.Cells[j,i];
                     for j := 1 to Cols3 do Grid3.Cells[j,insrow+1] := ''
               end;
               Rows3 := Rows3 + 1;
               for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
          end;
      4 : begin
               Grid4.RowCount := Grid4.RowCount + 1;
               if before then
               begin // insert a row before insrow
                     for i := Rows4 downto insrow-1 do
                         for j := 1 to Cols4 do
                             Grid4.Cells[j,i+1] := Grid4.Cells[j,i];
                     if insrow > 1 then
                        for j := 1 to Cols4 do Grid4.Cells[j,insrow-1] := ''
                     else for j := 1 to Cols4 do Grid4.Cells[j,1] := '';
               end
               else begin // insert a row after insrow
                     for i := Rows4 downto insrow+1 do
                         for j := 1 to Cols4 do
                             Grid4.Cells[j,i+1] := Grid4.Cells[j,i];
                     for j := 1 to Cols4 do Grid4.Cells[j,insrow+1] := ''
               end;
               Rows4 := Rows4 + 1;
               for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
          end;
  end; // case insgrid
end;

procedure TMatManFrm.RowVecsBoxClick(Sender: TObject);
var
   vecstr : string;
   answer : string;
   indexno : integer;
   gridno : integer;

begin
     indexno := RowVecsBox.ItemIndex;
     if indexno < 0 then exit;
     vecstr := RowVecsBox.Items.Strings[indexno];
     answer := InputBox('PLACEMENT','Place in which Grid?','1');
     gridno := StrToInt(answer);
     if ((gridno < 1) or (gridno > 4)) then
     begin
          ShowMessage('Error - Grid number must be between 1 and 4.');
          exit;
     end;
     CurrentGrid := gridno;
     CurrentObjType := 3;
     CurrentObjName := vecstr;
     OpenDialog1.FileName := vecstr;
     GetFile(Self);
     RowVecsBox.Text := 'ROW VECTORS';
     RowVecsBox.ItemIndex := -1;
end;

procedure TMatManFrm.RowxColVecMnuClick(Sender: TObject);
// premultiplication of a vector by another vector
var
   i, j, k, resulttype : integer;
   precols, postcols, prerows, postrows : integer;
   info : string;
   pregrid, postgrid, resultgrid : integer;
   prmptstr : string;
   premat, postmat, prodmat : DynMat;
   clickedok : boolean;
   defaultstr : string;

begin
     if ScriptOp = false then
     begin
          prmptstr := 'The pre-vector is in grid: ';
          info := InputBox('PRE-VECTOR',prmptstr,IntToStr(CurrentGrid));
          if info = '' then exit;
          pregrid := StrToInt(info);
          prmptstr := 'The post-vector is in grid: ';
          info := InputBox('POST-VECTOR',prmptstr,IntToStr(CurrentGrid));
          postgrid := StrToInt(info);
          if info = '' then exit;
          info := inputbox('RESULTS INTO','Place results in grid :','3');
          if info = '' then exit;
          resultgrid := StrToInt(info);
     end
     else begin // executing the script
          pregrid := 1;
          postgrid := 2;
          resultgrid := 3;
     end;
     case pregrid of
     1 : begin
              precols := Cols1;
              prerows := Rows1;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
         Op2Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              precols := Cols2;
              prerows := Rows2;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         Op2Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              precols := Cols3;
              prerows := Rows3;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         Op2Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              precols := Cols4;
              prerows := Rows4;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         Op2Edit.Text := MatFourEdit.Text;
         end;
     end;
     case postgrid of
     1 : begin
              postcols := Cols1;
              postrows := Rows1;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op3Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              postcols := Cols2;
              postrows := Rows2;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op3Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              postcols := Cols3;
              postrows := Rows3;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op3Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              postcols := Cols4;
              postrows := Rows4;
              SetLength(postmat,postrows,postcols);
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op3Edit.Text := MatFourEdit.Text;
          end;
     end;
     SetLength(prodmat,prerows,postcols);
     if prerows > 1 then resulttype := 1 else resulttype := 4;
     for i := 0 to prerows-1 do
         for j := 0 to postcols-1 do
             for k := 0 to precols-1 do
                 prodmat[i,j] := prodmat[i,j] + (premat[i,k]*postmat[k,j]);
     case resultgrid of
     1 : begin
              Grid1.RowCount := prerows+1;
              Grid1.ColCount := postcols+1;
              Rows1 := prerows;
              Cols1 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid1.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
              MatOneEdit.Text := 'Product';
              Op4Edit.Text := MatOneEdit.Text;
              if Rows1 = Cols1 then CurrentObjType := 1;
              if Rows1 > Cols1 then CurrentObjType := 2;
              if Cols1 > Rows1 then CurrentObjType := 3;
         end;
     2 : begin
              Grid2.RowCount := prerows+1;
              Grid2.ColCount := postcols+1;
              Rows2 := prerows;
              Cols2 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid2.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
              MatTwoEdit.Text := 'Product';
              Op4Edit.Text := MatTwoEdit.Text;
              if Rows2 = Cols2 then CurrentObjType := 1;
              if Rows2 > Cols2 then CurrentObjType := 2;
              if Cols2 > Rows2 then CurrentObjType := 3;
         end;
     3 : begin
              Grid3.RowCount := prerows+1;
              Grid3.ColCount := postcols+1;
              Rows3 := prerows;
              Cols3 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid3.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
              MatThreeEdit.Text := 'Product';
              Op4Edit.Text := MatThreeEdit.Text;
              if Rows3 = Cols3 then CurrentObjType := 1;
              if Rows3 > Cols3 then CurrentObjType := 2;
              if Cols3 > Rows3 then CurrentObjType := 3;
         end;
     4 : begin
              Grid4.RowCount := prerows+1;
              Grid4.ColCount := postcols+1;
              Rows4 := prerows;
              Cols4 := postcols;
              for i := 0 to prerows-1 do
                  for j := 0 to postcols-1 do
                      Grid4.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
              MatFourEdit.Text := 'Product';
              Op4Edit.Text := MatFourEdit.Text;
              if Rows4 = Cols4 then CurrentObjType := 1;
              if Rows4 > Cols4 then CurrentObjType := 2;
              if Cols4 > Rows4 then CurrentObjType := 3;
         end;
     end;
     Op1Edit.Text := 'VecxVec';
     opstr := IntToStr(CurrentGrid) + '-';
     Op2Edit.Text := ExtractFileName(Op2Edit.Text);
     Op2Edit.Text := IntToStr(postgrid) + '-' + Op2Edit.Text;
     opstr := opstr + 'VecxVec:'+ Op2Edit.Text;
     Op3Edit.Text := ExtractFileName(Op3Edit.Text);
     Op3Edit.Text := IntToStr(pregrid) + '-' + Op3Edit.Text;
     opstr := opstr + ':' + Op3Edit.Text;
     if ScriptOp = false then
     begin
          prmptstr := 'Save product as: ';
          defaultstr := 'VectorProd';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'VectorProd';
          if Length(info) > 0 then Op4Edit.Text := info
          else  begin
               Op4Edit.Text := 'VectorProd';
               info := 'VectorProd';
          end;
          opstr := opstr + ':' + IntToStr(resultgrid) + '-' + Op4Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := resulttype;
          ComboAdd(CurrentObjName);
          CurrentGrid := resultgrid;
          if clickedok then SaveFileMnuClick(Self);
     end;
     // deallocate memory
     prodmat := nil;
     postmat := nil;
     premat := nil;
end;

procedure TMatManFrm.SaveFileMnuClick(Sender: TObject);
var
   SaveFile : TextFile;
   i, j : integer;
//   OpStr : string;
   BackUpName : string;

begin
     SaveDialog1.Filter := 'Matrix (*.mat)|*.MAT|Col.Vector (*.CVE)|*.CVE|RowVector (*.RVE)|*.RVE|Scaler (*.scl)|*.SCA|All (*.*)|*.*';
     SaveDialog1.FilterIndex := CurrentObjType;
     case CurrentObjType of
          1 : SaveDialog1.DefaultExt := '.MAT';
          2 : SaveDialog1.DefaultExt := '.CVE';
          3 : SaveDialog1.DefaultExt := '.RVE';
          4 : SaveDialog1.DefaultExt := '.SCA';
     end;
     BackUpName := ExtractFileName(CurrentObjName);
     SaveDialog1.FileName := BackUpName;

     if SaveDialog1.Execute then
     begin
          Op2Edit.Text := SaveDialog1.FileName;
          CurrentObjName := ExtractFileName(SaveDialog1.FileName);
          Op1Edit.Text := 'FileSave';
          Op3Edit.Text := '';
          Op4Edit.Text := '';
          AssignFile(SaveFile, SaveDialog1.FileName);
          Rewrite(SaveFile);
          Writeln(SaveFile,CurrentObjType);
          Writeln(SaveFile,CurrentObjName);
          case CurrentGrid of
          1 : begin
              MatOneEdit.Text := CurrentObjName;
              Writeln(SaveFile,Rows1);
              Writeln(SaveFile,Cols1);
              for i := 1 to Rows1 do
                  for j := 1 to Cols1 do
                      Writeln(SaveFile,Grid1.Cells[j,i]);
              end;
          2 : begin
              MatTwoEdit.Text := CurrentObjName;
              Writeln(SaveFile,Rows2);
              Writeln(SaveFile,Cols2);
              for i := 1 to Rows2 do
                  for j := 1 to Cols2 do
                      Writeln(SaveFile,Grid2.Cells[j,i]);
              end;
          3 : begin
              MatThreeEdit.Text := CurrentObjName;
              Writeln(SaveFile,Rows3);
              Writeln(SaveFile,Cols3);
              for i := 1 to Rows3 do
                  for j := 1 to Cols3 do
                      Writeln(SaveFile,Grid3.Cells[j,i]);
              end;
          4 : begin
              MatFourEdit.Text := CurrentObjName;
              Writeln(SaveFile,Rows4);
              Writeln(SaveFile,Cols4);
              for i := 1 to Rows4 do
                  for j := 1 to Cols4 do
                      Writeln(SaveFile,Grid4.Cells[j,i]);
              end;
          end; // case
          CloseFile(SaveFile);
          Saved := true;
          if ScriptOp = false then
          begin
               OpStr := IntToStr(CurrentGrid) + '-';
               OpStr := OpStr + 'FileSave:' + IntToStr(CurrentGrid) + '-' + CurrentObjName;
               if scriptoptsfrm.CheckGroup1.Checked[1] <> true then ScriptList.Items.Add(OpStr);
          end;
     end; // if savedialog1 executed
end;

procedure TMatManFrm.ScalarInmnuClick(Sender: TObject);
var
   instr : string;

begin
     instr := InputBox('GRID?','Which grid no. (1-4):','1');
     CurrentGrid := StrToInt(instr);
     if ((CurrentGrid < 1) or (CurrentGrid > 4)) then CurrentGrid := 1;
     GridNoEdit.Text := IntToStr(CurrentGrid);
     ScaCount := ScaCount + 1;
     instr := InputBox('Scaler Name','Object name:','Ascaler');
     CurrentObjName := instr;
     CurrentObjType := 4;
     case CurrentGrid of
     1 : begin
              Rows1 := 1;
              Cols1 := 1;
              Grid1.RowCount := 2;
              Grid1.ColCount := 2;
              Grid1.Cells[1,0] := 'Col.1';
              Grid1.Cells[0,1] := 'Row.1';
              Grid1.Cells[1,1] := '';
              MatOneEdit.Text := CurrentObjName;
         end;
     2 : begin
              Rows2 := 1;
              Cols2 := 1;
              Grid2.RowCount := 2;
              Grid2.ColCount := 2;
              Grid2.Cells[1,0] := 'Col.1';
              Grid2.Cells[0,1] := 'Row.1';
              Grid2.Cells[1,1] := '';
              MatTwoEdit.Text := CurrentObjName;
         end;
     3 : begin
              Rows3 := 1;
              Cols3 := 1;
              Grid3.RowCount := 2;
              Grid3.ColCount := 2;
              Grid3.Cells[1,0] := 'Col.1';
              Grid3.Cells[0,1] := 'Row.1';
              Grid3.Cells[1,1] := '';
              MatThreeEdit.Text := CurrentObjName;
         end;
     4 : begin
              Rows4 := 1;
              Cols4 := 1;
              Grid4.RowCount := 2;
              Grid4.ColCount := 2;
              Grid4.Cells[1,0] := 'Col.1';
              Grid4.Cells[0,1] := 'Row.1';
              Grid4.Cells[1,1] := '';
              MatFourEdit.Text := CurrentObjName;
         end;
     end; // case
     case CurrentGrid of
          1 : Grid1.SetFocus;
          2 : Grid2.SetFocus;
          3 : Grid3.SetFocus;
          4 : Grid4.SetFocus;
     end;
end;

procedure TMatManFrm.ScalarsBoxClick(Sender: TObject);
var
   scalerstr : string;
   answer : string;
   indexno : integer;
   gridno : integer;

begin
     indexno := ScalarsBox.ItemIndex;
     if indexno < 0 then exit;
     scalerstr := ScalarsBox.Items.Strings[indexno];
     answer := InputBox('PLACEMENT','Place in which Grid?','1');
     gridno := StrToInt(answer);
     if ((gridno < 1) or (gridno > 4)) then
     begin
          ShowMessage('Error - Grid number must be between 1 and 4.');
          exit;
     end;
     CurrentGrid := gridno;
     CurrentObjType := 4;
     CurrentObjName := scalerstr;
     OpenDialog1.FileName := scalerstr;
     GetFile(Self);
     ScalarsBox.Text := 'SCALARS';
     ScalarsBox.ItemIndex := -1;
end;

procedure TMatManFrm.ScalRecipMnuClick(Sender: TObject);
var
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
begin
     Op1Edit.Text := 'ScalerRecip';
     case CurrentGrid of
     1 :  begin
               if StrToFloat(Grid1.Cells[1,1]) = 0.0 then
               begin
                  ShowMessage('Attempt to divide by zero.');
                  exit;
               end;
               Grid1.Cells[1,1] := FloatToStr(1.0 / StrToFloat(Grid1.Cells[1,1]));
               Op2Edit.Text := MatOneEdit.Text;
               MatOneEdit.Text := 'ScalerRecip';
               Op3Edit.Text := MatOneEdit.Text;
               CurrentObjName := MatOneEdit.Text;
          end;
     2 :  begin
               if StrToFloat(Grid2.Cells[1,1]) = 0.0 then
               begin
                  ShowMessage('Attempt to divide by zero.');
                  exit;
               end;
               Grid2.Cells[1,1] := FloatToStr(1.0 / StrToFloat(Grid2.Cells[1,1]));
               Op2Edit.Text := MatTwoEdit.Text;
               MatTwoEdit.Text := 'ScalerRecip';
               Op3Edit.Text := MatTwoEdit.Text;
               CurrentObjName := MatTwoEdit.Text;
          end;
     3 :  begin
               if StrToFloat(Grid3.Cells[1,1]) = 0.0 then
               begin
                  ShowMessage('Attempt to divide by zero.');
                  exit;
               end;
               Grid3.Cells[1,1] := FloatToStr(1.0 / StrToFloat(Grid3.Cells[1,1]));
               Op2Edit.Text := MatThreeEdit.Text;
               MatThreeEdit.Text := 'ScalerRecip';
               Op3Edit.Text := MatThreeEdit.Text;
               CurrentObjName := MatThreeEdit.Text;
          end;
     4 :  begin
               if StrToFloat(Grid4.Cells[1,1]) = 0.0 then
               begin
                  ShowMessage('Attempt to divide by zero.');
                  exit;
               end;
               Grid4.Cells[1,1] := FloatToStr(1.0 / StrToFloat(Grid4.Cells[1,1]));
               Op2Edit.Text := MatFourEdit.Text;
               MatFourEdit.Text := 'ScalerRecip';
               Op3Edit.Text := MatFourEdit.Text;
               CurrentObjName := MatFourEdit.Text;
          end;
     end;
     if ScriptOp = false then
     begin
          opstr := IntToStr(CurrentGrid) + '-' + 'ScalerRecip:';
          opstr := opstr + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
          prmptstr := 'Save reciprocal of scaler as: ';
          defaultstr := 'ScalarRecip';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'ScalarRecip';
          if Length(info) > 0 then Op3Edit.Text := info
          else  begin
               Op3Edit.Text := 'ScalarRecip';
               info := 'ScalarRecip';
          end;
          opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 4;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case CurrentGrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
end;

procedure TMatManFrm.ScalSqrtMnuClick(Sender: TObject);
var
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
begin
     Op1Edit.Text := 'SqrtScalar';
     case CurrentGrid of
     1 :  begin
               if StrToFloat(Grid1.Cells[1,1]) < 0.0 then
                  ShowMessage('Attempt to take square root of a negative value.')
               else Grid1.Cells[1,1] := FloatToStr(sqrt(StrToFloat(Grid1.Cells[1,1])));
               Op2Edit.Text := MatOneEdit.Text;
               MatOneEdit.Text := 'SqrtScaler';
          end;
     2 :  begin
               if StrToFloat(Grid2.Cells[1,1]) < 0.0 then
                  ShowMessage('Attempt to take square root of a negative value.')
               else Grid2.Cells[1,1] := FloatToStr(sqrt(StrToFloat(Grid2.Cells[1,1])));
               Op2Edit.Text := MatTwoEdit.Text;
               MatTwoEdit.Text := 'SqrtScaler';
          end;
     3 :  begin
               if StrToFloat(Grid3.Cells[1,1]) < 0.0 then
                  ShowMessage('Attempt to take square root of a negative value.')
               else Grid3.Cells[1,1] := FloatToStr(sqrt(StrToFloat(Grid3.Cells[1,1])));
               Op2Edit.Text := MatThreeEdit.Text;
               MatThreeEdit.Text := 'SqrtScaler';
          end;
     4 :  begin
               if StrToFloat(Grid4.Cells[1,1]) < 0.0 then
                  ShowMessage('Attempt to take square root of a negative value.')
               else Grid4.Cells[1,1] := FloatToStr(sqrt(StrToFloat(Grid4.Cells[1,1])));
               Op2Edit.Text := MatFourEdit.Text;
               MatFourEdit.Text := 'SqrtScaler';
          end;
     end;
     if ScriptOp = false then
     begin
          prmptstr := 'Save scalar square root as: ';
          defaultstr := 'SqrtScalar';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'SqrtScalar';
          if Length(info) > 0 then Op3Edit.Text := info
          else  begin
               Op3Edit.Text := 'SqrtScalar';
               info := 'SqrtScaler';
          end;
          opstr := IntToStr(CurrentGrid) + '-' + 'SqrtScaler:';
          opstr := opstr + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 4;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case CurrentGrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
end;

procedure TMatManFrm.ScalxScalMnuClick(Sender: TObject);
var
   multiplier : double;
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
begin
     prmptstr := 'Multiply the scalar by ' ;
     info := inputbox('MULTIPLY BY ',prmptstr,'');
     if info = '' then exit
     else multiplier := StrToFloat(info);
     Op1Edit.Text := 'ScalarxScalar';
     case CurrentGrid of
     1 : begin
              Op2Edit.Text := MatOneEdit.Text;
              Grid1.Cells[1,1] := FloatToStr(StrToFloat(Grid1.Cells[1,1]) * multiplier);
              MatOneEdit.Text := 'ScalarProd';
         end;
     2 : begin
              Op2Edit.Text := MatTwoEdit.Text;
              Grid2.Cells[1,1] := FloatToStr(StrToFloat(Grid2.Cells[1,1]) * multiplier);
              MatTwoEdit.Text := 'ScalarProd';
         end;
     3 : begin
              Op2Edit.Text := MatThreeEdit.Text;
              Grid3.Cells[1,1] := FloatToStr(StrToFloat(Grid3.Cells[1,1]) * multiplier);
              MatThreeEdit.Text := 'ScalarProd';
         end;
     4 : begin
              Op2Edit.Text := MatFourEdit.Text;
              Grid4.Cells[1,1] := FloatToStr(StrToFloat(Grid4.Cells[1,1]) * multiplier);
              MatFourEdit.Text := 'ScalarProd';
         end;
     end;

     if ScriptOp = false then
     begin
          prmptstr := 'Save product of scalars as: ';
          defaultstr := 'ScalarProd';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'ScalarProd';
          if Length(info) > 0 then Op3Edit.Text := ':' + IntToStr(CurrentGrid) + '-' + info
          else  begin
               Op3Edit.Text := 'ScalarProd';
               info := 'ScalarProd';
          end;
          opstr := IntToStr(CurrentGrid) + '-' + 'ScalerProd:';
          opstr := opstr + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 4;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case CurrentGrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
end;

procedure TMatManFrm.ScrExeMnuClick(Sender: TObject);
var
   i, Count : integer;
//   Operation, Op1, Op2, Op3 : string;
   parseresult : integer;
//   Opergrid, Op1grid, Op2grid, Op3grid : integer;
begin
   Count := ScriptList.Items.Count;
   if Count < 1 then
   begin
        ShowMessage('No script loaded to execute!');
        exit;
   end;
   ScriptOp := true;
   for i := 0 to Count - 1 do
   begin
        OpStr := ScriptList.Items.Strings[i];

        parseresult := OpParse(Operation, OpStr, Op1, Op2, Op3, Opergrid, Op1grid,
                          Op2grid, Op3grid);
        if parseresult = 0 then
        begin
             ShowMessage('Operation code not found in a script entry.');
             ScriptOp := false;
             exit;
        end;

        // Now, execute the operation
        OperExec; //(Operation, Op1, Op2, Op3, Opergrid, Op1grid, Op2grid, Op3grid);
        if i = Count - 1 then ScriptOp := false;
        LastScript := i;
   end; // next i
end;

procedure TMatManFrm.ScriptClearMnuClick(Sender: TObject);
begin
     ScriptList.Clear;
end;

procedure TMatManFrm.ScriptEditMnuClick(Sender: TObject);
var count, i : integer;

begin
     count := ScriptList.Items.Count;
     ScriptEditorFrm.ScriptList.Clear;
     for i := 0 to count-1 do ScriptEditorFrm.ScriptList.Items.Add(ScriptList.Items.Strings[i]);
     ScriptEditorFrm.ShowModal;
end;

procedure TMatManFrm.ScriptFileInMnuClick(Sender: TObject);
var
   SaveFile : TextFile;
   i, Count : integer;
   cellstring : string;
//   ScriptName : string;
begin
     OpenDialog1.FileName := 'Script';
     OpenDialog1.Filter := 'Script (*.SCP)|*.SCP|(*.*)|*.*';
     OpenDialog1.DefaultExt := '.SCP';
     if OpenDialog1.Execute then
     begin
          ScriptName := ExtractFileName(OpenDialog1.FileName);
          ScriptList.Clear;
          scripteditorfrm.ScriptList.Clear;
          scripteditorfrm.ScriptFileEdit.Text := OpenDialog1.FileName;
          AssignFile(SaveFile, OpenDialog1.FileName);
          Reset(SaveFile);
          Readln(SaveFile,CurrentObjType);
          if CurrentObjType <> 5 then
          begin
               ShowMessage('Not a script file!');
               CloseFile(SaveFile);
               exit;
          end;
          Readln(SaveFile,CurrentObjName);
          Op2Edit.Text := OpenDialog1.FileName;
          Readln(SaveFile,Count);
          for i := 0 to Count - 1 do
          begin
               Readln(SaveFile,cellstring);
               ScriptList.Items.Add(cellstring);
               scripteditorfrm.ScriptList.Items.Add(cellstring);
          end;
          CloseFile(SaveFile);
          Op1Edit.Text := 'OpenScript';
          Op3Edit.Text := '';
     end;
end;

procedure TMatManFrm.ScriptListClick(Sender: TObject);
var
   i, Count : integer;
   parseresult : integer;

begin
   Count := ScriptList.Items.Count;
   if Count < 1 then
   begin
        ShowMessage('No script loaded to execute!');
        exit;
   end;
   ScriptOp := true;
   i := ScriptList.ItemIndex;
   OpStr := ScriptList.Items.Strings[i];
   parseresult := OpParse(Operation, OpStr, Op1, Op2, Op3, Opergrid, Op1grid,
                          Op2grid, Op3grid);
   if parseresult = 0 then
   begin
        ShowMessage('Operation code not found in a script entry.');
        ScriptOp := false;
        exit;
   end;

   // Now, execute the operation
   OperExec; //(Operation, Op1, Op2, Op3, Opergrid, Op1grid, Op2grid, Op3grid);
   ScriptOp := false;
end;

procedure TMatManFrm.ScriptLoadMnuClick(Sender: TObject);
begin
     ScriptFileInMnuClick(Self);
end;

procedure TMatManFrm.ScriptOpsMnuClick(Sender: TObject);
begin
  ScriptOptsFrm.ShowModal;
end;

procedure TMatManFrm.ScriptPrintMnuClick(Sender: TObject);
var i : integer;

begin
     if ScriptList.Items.Count = 0 then exit;
     OutputFrm.RichEdit.Lines.Add('CURRENT LISTING FOR SCRIPT ' + ScriptName);
     OutputFrm.RichEdit.Lines.Add('');
     for i := 0 to ScriptList.Items.Count - 1 do
          OutputFrm.RichEdit.Lines.Add(ScriptList.Items.Strings[i]);
     OutputFrm.ShowModal;
end;

procedure TMatManFrm.ScriptSaveMnuClick(Sender: TObject);
var
   SaveFile : TextFile;
   i, Count : integer;

begin
     Count := ScriptList.Items.Count;
     if Count < 1 then exit;
     CurrentObjType := 5; // a script file
     SaveDialog1.FileName := 'Script';
     SaveDialog1.Filter := 'Script (*.SCP)|*.SCP|(*.*)|*.*';
     SaveDialog1.DefaultExt := '.SCP';
     if SaveDialog1.Execute then
     begin
         AssignFile(SaveFile, SaveDialog1.FileName);
         CurrentObjName := SaveDialog1.FileName;
         Rewrite(SaveFile);
         Writeln(SaveFile,CurrentObjType);
         Writeln(SaveFile,CurrentObjName);
         Writeln(SaveFile,Count);
         for i := 0 to Count - 1 do
             Writeln(SaveFile,ScriptList.Items.Strings[i]);
         CloseFile(SaveFile);
         Op1Edit.Text := 'SaveScript';
         Op2Edit.Text := SaveDialog1.FileName;
         Op3Edit.Text := '';
     end;
end;

procedure TMatManFrm.ScrSavMnuClick(Sender: TObject);
begin
     ScriptSaveMnuClick(Self);
end;

procedure TMatManFrm.SVDInvMnuClick(Sender: TObject);
label emsg;
var
   size : integer;
   i, j : integer;
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
begin
     if CurrentObjType <> 1 then
emsg:
     begin
          ShowMessage('Error - Selected grid does not contain a symetric matrix.');
          exit;
     end;
     case CurrentGrid of
     1 : begin
              if Rows1 <> Cols1 then goto emsg;
              size := Rows1;
              Op2Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              if Rows2 <> Cols2 then goto emsg;
              size := Rows2;
              Op2Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              if Rows3 <> Cols3 then goto emsg;
              size := Rows3;
              Op2Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              if Rows4 <> Cols4 then goto emsg;
              size := Rows4;
              Op2Edit.Text := MatFourEdit.Text;
         end;
     end;

     // allocate memory
     setlength(Matrix1,size,size);
     setlength(Matrix2,size,size);
     setlength(Matrix3,size,size);
     setlength(Matrix4,size,size);

     case CurrentGrid of
     1 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
         end;
     2 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         end;
     3 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         end;
     4 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         end;
     end;
     matinv(Matrix1, Matrix2, Matrix3, Matrix4, size);

     // Place results in the four grids
     Grid1.RowCount := Size + 1;
     Grid1.ColCount := Size + 1;
     Grid2.RowCount := Size + 1;
     Grid2.Colcount := Size + 1;
     Grid3.RowCount := Size + 1;
     Grid3.ColCount := Size + 1;
     Grid4.RowCount := Size + 1;
     Grid4.ColCount := Size + 1;
     Rows1 := Size;
     Cols1 := Size;
     Rows2 := Size;
     Cols2 := Size;
     Rows3 := Size;
     Cols3 := Size;
     Rows4 := Size;
     Cols4 := Size;
//     Obj1NameEdit.Text := 'Inverse';
     MatTwoEdit.Text := 'vtimesw ';
     MatThreeEdit.Text := 'v';
     MatFourEdit.Text := 'w';
     for i := 0 to size - 1 do
     begin
          for j := 0 to size - 1 do
          begin
               Grid1.Cells[j+1,i+1] := FloatToStr(Matrix1[i,j]);
               Grid2.Cells[j+1,i+1] := FloatToStr(Matrix2[i,j]);
               Grid3.Cells[j+1,i+1] := FloatToStr(Matrix3[i,j]);
               Grid4.Cells[j+1,i+1] := FloatToStr(Matrix4[i,j]);
          end;
     end;

     Op1Edit.Text := 'SVDInverse';
     if ScriptOp = false then
     begin
          prmptstr := 'Save result as: ';
          defaultstr := 'SVDInverse';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'SVDInverse';
          if Length(info) > 0 then MatOneEdit.Text := info;
          opstr := IntToStr(CurrentGrid) + '-';
          Op2Edit.Text := ExtractFileName(Op2Edit.Text);
          Op2Edit.Text := IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
          opstr := opstr + 'SVDInverse:' + Op2Edit.Text;
          if Length(info) > 0 then Op3Edit.Text := ':' + IntToStr(1) + '-' + info
          else Op3Edit.Text := '';
          opstr := opstr + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          if Length(info) > 0 then
          begin
               CurrentObjName := info;
               CurrentObjType := 1;
               CurrentGrid := 1;
               if clickedok then SaveFileMnuClick(Self);
          end;
          ComboAdd(CurrentObjName);
     end;
     // deallocate memory
     Matrix4 := nil;
     Matrix3 := nil;
     Matrix2 := nil;
     Matrix1 := nil;
end;

procedure TMatManFrm.TraceMnuClick(Sender: TObject);
label emsg;
var
   i, nextgrid : integer;
   sum : double;
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
begin
     if CurrentObjType <> 1 then
emsg:
     begin
          ShowMessage('Error - Selected grid does not contain a matrix.');
          exit;
     end;
     sum := 0.0;

     case CurrentGrid of
     1 : begin
              for i := 1 to Grid1.ColCount - 1 do
                  sum := sum + StrToFloat(Grid1.Cells[i,i]);
              Op2Edit.Text := MatOneEdit.Text;
              nextgrid := 2;
         end;
     2 : begin
              for i := 1 to Grid2.ColCount - 1 do
                  sum := sum + StrToFloat(Grid2.Cells[i,i]);
              Op2Edit.Text := MatTwoEdit.Text;
              nextgrid := 3;
         end;
     3 : begin
              for i := 1 to Grid3.ColCount - 1 do
                  sum := sum + StrToFloat(Grid3.Cells[i,i]);
              Op2Edit.Text := MatThreeEdit.Text;
              nextgrid := 4;
         end;
     4 : begin
              for i := 1 to Grid4.ColCount - 1 do
                  sum := sum + StrToFloat(Grid4.Cells[i,i]);
              Op2Edit.Text := MatFourEdit.Text;
              nextgrid := 1;
         end;
     end;

     // place results in next grid
     case nextgrid of
     1 : begin
              Grid1.RowCount := 2;
              Grid1.ColCount := 2;
              MatOneEdit.Text := 'Trace';
              Grid1.Cells[1,1] := FloatToStr(sum);
              CurrentObjName := MatOneEdit.Text;
         end;
     2 : begin
              Grid2.RowCount := 2;
              Grid2.ColCount := 2;
              MatTwoEdit.Text := 'Trace';
              Grid2.Cells[1,1] := FloatToStr(sum);
              CurrentObjName := MatTwoEdit.Text;
         end;
     3 : begin
              Grid3.RowCount := 2;
              Grid3.ColCount := 2;
              MatThreeEdit.Text := 'Trace';
              Grid3.Cells[1,1] := FloatToStr(sum);
              CurrentObjName := MatThreeEdit.Text;
         end;
     4 : begin
              Grid4.RowCount := 2;
              Grid4.ColCount := 2;
              MatFourEdit.Text := 'Trace';
              Grid4.Cells[1,1] := FloatToStr(sum);
              CurrentObjName := MatFourEdit.Text;
         end;
     end;

     Op1Edit.Text := 'MatTrace';
     if ScriptOp = false then
     begin
          prmptstr := 'Save trace as: ';
          defaultstr := 'trace';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'trace';
          if Length(info) > 0 then
          begin
               Op3Edit.Text := info;
          end
          else  begin
               Op3Edit.Text := 'trace';
               info := 'trace';
          end;
          case nextgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
          Op2Edit.Text := IntToStr(CurrentGrid) + '-' + ExtractFileName(Op2Edit.Text);
          opstr := IntToStr(CurrentGrid) + '-' + 'MatTrace:' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(nextgrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 4;
          CurrentGrid := nextgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
     end;
end;

procedure TMatManFrm.TransMnuClick(Sender: TObject);
label emsg;
var
   i, j, nextgrid : integer;
   prmptstr, info: string;
   clickedok : boolean;
   defaultstr : string;
begin
     if CurrentObjType <> 1 then
emsg:
     begin
          ShowMessage('Error - Selected grid does not contain a matrix.');
          exit;
     end;
     case CurrentGrid of
     1 : begin
              Op2Edit.Text := MatOneEdit.Text;
              nextgrid := 2;
              Grid2.RowCount := Cols1 + 1;
              Grid2.ColCount := Rows1 + 1;
              for i := 1 to Rows1 do
                  for j := 1 to Cols1 do
                      Grid2.Cells[i,j] := Grid1.Cells[j,i];
              for i := 1 to Rows1 do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
              for i := 1 to Cols1 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
              Grid2.RowCount := Cols1 + 1;
              Grid2.ColCount := Rows1 + 1;
              Rows2 := Cols1;
              Cols2 := Rows1;
         end;
     2 : begin
              Op2Edit.Text := MatTwoEdit.Text;
              nextgrid := 3;
              Grid3.RowCount := Cols2 + 1;
              Grid3.ColCount := Rows2 + 1;
               for i := 1 to Rows2 do
                  for j := 1 to Cols2 do
                      Grid3.Cells[i,j] := Grid2.Cells[j,i];
              for i := 1 to Rows2 do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
              for i := 1 to Cols2 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
             Rows3 := Cols2;
              Cols3 := Rows2;
         end;
     3 : begin
              Op2Edit.Text := MatThreeEdit.Text;
              nextgrid := 4;
              Grid4.RowCount := Cols3 + 1;
              Grid4.ColCount := Rows3 + 1;
              for i := 1 to Rows3 do
                  for j := 1 to Cols3 do
                      Grid4.Cells[i,j] := Grid3.Cells[j,i];
              for i := 1 to Rows3 do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
              for i := 1 to Cols3 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
              Rows4 := Cols3;
              Cols4 := Rows3;
         end;
     4 : begin
              Op2Edit.Text := MatFourEdit.Text;
              nextgrid := 1;
              Grid1.RowCount := Cols4 + 1;
              Grid1.ColCount := Rows4 + 1;
              for i := 1 to Rows4 do
                  for j := 1 to Cols4 do
                      Grid1.Cells[i,j] := Grid4.Cells[j,i];
              for i := 1 to Rows4 do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
              for i := 1 to Cols4 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
              Rows1 := Cols4;
              Cols1 := Rows4;
         end;
     end;
     Op1Edit.Text := 'MatTranspose';
     Op4Edit.Text := '';
     if ScriptOp = false then
     begin
          prmptstr := 'Save transpose matrix as: ';
          defaultstr := 'transpose';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'transpose';
          opstr := IntToStr(CurrentGrid) + '-';
          Op2Edit.Text := ExtractFileName(Op2Edit.Text);
          Op2Edit.Text := IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
          opstr := opstr + 'MatTranspose:' + Op2Edit.Text;
          if Length(info) > 0 then
               Op3Edit.Text := ':' + IntToStr(nextgrid) + '-' + info
          else begin
               Op3Edit.Text := ':' + IntToStr(nextgrid) + '-' + 'transpose';
               info := 'transpose';
          end;
          opstr := opstr + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := 1;
          CurrentGrid := nextgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case nextgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
end;

procedure TMatManFrm.TriDiagMnuClick(Sender: TObject);
label emsg;
var
   size : integer;
   i, j : integer;
   prmptstr, info : string;
   avector, bvector : DynVec;
   clickedok : boolean;
   defaultstr : string;
begin
     if CurrentGrid = 0 then exit;
     if CurrentObjType <> 1 then
emsg:
     begin
          ShowMessage('Error - Selected grid does not contain a symetric matrix.');
          exit;
     end;
     case CurrentGrid of
     1 : begin
              if Rows1 <> Cols1 then goto emsg;
              size := Rows1;
              Op2Edit.Text := ExtractFileName(MatOneEdit.Text);
         end;
     2 : begin
              if Rows2 <> Cols2 then goto emsg;
              size := Rows2;
              Op2Edit.Text := ExtractFileName(MatTwoEdit.Text);
         end;
     3 : begin
              if Rows3 <> Cols3 then goto emsg;
              size := Rows3;
              Op2Edit.Text := ExtractFileName(MatThreeEdit.Text);
         end;
     4 : begin
              if Rows4 <> Cols4 then goto emsg;
              size := Rows4;
              Op2Edit.Text := ExtractFileName(MatFourEdit.Text);
         end;
     end;

     // allocate memory
     setlength(Matrix1,size,size);
     setlength(Matrix2,size,size);
     setlength(avector,size);
     setlength(bvector,size);

     // store data in Matrix1 to be inverted
     case CurrentGrid of
     1 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
         end;
     2 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         end;
     3 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         end;
     4 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         end;
     end;
     TRED2(Matrix1,size,avector,bvector);
     for i := 0 to size-1 do
     begin
          for j := 0 to size-1 do
          begin
               Matrix2[i,j] := 0.0;
               if i = j then Matrix2[i,j] := avector[i];
               if i < size-1 then Matrix2[i,i+1] := bvector[i+1];
               if i > 0 then Matrix2[i,i-1] := bvector[i];
          end;
     end;

     // Replace original matrix with tridiagonalized matrix
     case CurrentGrid of
     1 :  begin
               for i := 0 to size-1 do
                   for j := 0 to size-1 do
                       Grid1.Cells[j+1,i+1] := FloatToStr(Matrix2[i,j]);
          end;
     2 :  begin
               for i := 0 to size-1 do
                   for j := 0 to size-1 do
                       Grid2.Cells[j+1,i+1] := FloatToStr(Matrix2[i,j]);
          end;
     3 :  begin
               for i := 0 to size-1 do
                   for j := 0 to size-1 do
                       Grid3.Cells[j+1,i+1] := FloatToStr(Matrix2[i,j]);
          end;
     4 :  begin
               for i := 0 to size-1 do
                   for j := 0 to size-1 do
                       Grid4.Cells[j+1,i+1] := FloatToStr(Matrix2[i,j]);
          end;
     end;

     Op1Edit.Text := 'Tridiagonalize';
     opstr := IntToStr(CurrentGrid) + '-';
     Op2Edit.Text := Op2Edit.Text;
     opstr := opstr + 'Tridiagonalize:' + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
     if ScriptOp = false then
     begin
          prmptstr := 'Save result as: ';
          defaultstr := 'TriDiag';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'TriDiag';
          if Length(info) > 0 then Op3Edit.Text := info
          else Op3Edit.Text := 'TriDiag';
          opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := Op3Edit.Text;
          CurrentObjType := 1;
          if clickedok then SaveFileMnuClick(Self);
          case CurrentGrid of
          1 : MatOneEdit.Text := Op3Edit.Text;
          2 : MatTwoEdit.Text := Op3Edit.Text;
          3 : MatThreeEdit.Text := Op3Edit.Text;
          4 : MatFourEdit.Text := Op3Edit.Text;
          end;
          ComboAdd(CurrentObjName);
     end;
     // deallocate memory
     Matrix4 := nil;
     Matrix3 := nil;
     avector := nil;
     bvector := nil;
end;

procedure TMatManFrm.ULDecompMnuClick(Sender: TObject);
label emsg;
var
   size : integer;
   i, j : integer;
   prmptstr, info : string;
   intvector : DynIntVec;
   scaler : double;
   lowername, uppername : string;
   clickedok1, clickedok2 : boolean;
   defaultstr : string;
begin
     if CurrentGrid = 0 then exit;
     if CurrentObjType <> 1 then
emsg:
     begin
          ShowMessage('Error - Selected grid does not contain a symetric matrix.');
          exit;
     end;
     case CurrentGrid of
     1 : begin
              if Rows1 <> Cols1 then goto emsg;
              size := Rows1;
              Op2Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              if Rows2 <> Cols2 then goto emsg;
              size := Rows2;
              Op2Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              if Rows3 <> Cols3 then goto emsg;
              size := Rows3;
              Op2Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              if Rows4 <> Cols4 then goto emsg;
              size := Rows4;
              Op2Edit.Text := MatFourEdit.Text;
         end;
     end;

     // allocate memory
     setlength(Matrix1,size,size);
     setlength(Matrix2,size,size);
     setlength(Matrix3,size,size);
     setlength(Matrix4,size,size);
     setlength(intvector,size);

     // store data to be decomposed in Matrix1
     case CurrentGrid of
     1 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
         end;
     2 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         end;
     3 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         end;
     4 : begin
         for i := 0 to size - 1 do
             for j := 0 to size - 1 do
                 Matrix1[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         end;
     end;

     // decompose
     LUDCMP(Matrix1,size,intvector,scaler);
     for i := 0 to size-1 do
         for j := 0 to size-1 do
             Matrix2[i,j] := Matrix1[i,j];
     { store in left and right triangular matrices }
     for i := 0 to size-1 do
     begin
          for j := 0 to size-1 do
          begin
               Matrix3[i,j] := 0.0;
               Matrix4[i,j] := 0.0;
          end;
     end;
     for i := 0 to size-1 do // row
     begin
          for j := 0 to i do
              Matrix3[i,j] := Matrix2[i,j]; // lower matrix
          Matrix3[i,i] := 1.0;
     end;
     for i := 0 to size -1 do
         for j := i to Size-1 do
             Matrix4[i,j] := Matrix2[i,j]; // upper matrix

     // Place lower in grid1
     Grid1.RowCount := size + 1;
     Grid1.ColCount := size + 1;
     Rows1 := size;
     Cols1 := size;
     for i := 0 to size-1 do
         for j := 0 to size-1 do
             Grid1.Cells[j+1,i+1] := FloatToStr(Matrix3[i,j]);
     MatOneEdit.Text := 'LowerDecomp';
     // place upper in grid2
     Grid2.RowCount := size + 1;
     Grid2.ColCount := size + 1;
     Rows2 := size;
     Cols2 := size;
     for i := 0 to size-1 do
         for j := 0 to size-1 do
             Grid2.Cells[j+1,i+1] := FloatToStr(Matrix4[i,j]);
     MatTwoEdit.Text := 'UpperDecomp';
     //save combined upper and lower in grid3
     Grid3.RowCount := size + 1;
     Grid3.ColCount := size + 1;
     Rows3 := size;
     Cols3 := size;
     for i := 0 to size - 1 do
         for j := 0 to size-1 do
             Grid3.Cells[j+1,i+1] := FloatToStr(Matrix2[i,j]);
     MatThreeEdit.Text := 'LUMatrix';
     // save permutations in grid4
     grid4.RowCount := size + 1;
     Grid4.ColCount := 2;
     Rows4 := size;
     Cols4 := 1;
     for i := 0 to size-1 do Grid4.Cells[1,i+1] := IntToStr(intvector[i] + 1);
     MatFourEdit.Text := 'RowPermutations';

     Op1Edit.Text := 'UpLowDecomp';
     opstr := IntToStr(CurrentGrid) + '-';
     Op2Edit.Text := ExtractFileName(Op2Edit.Text);
     opstr := opstr + 'UpLowDecomp:' + IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
     if ScriptOp = false then
     begin
          prmptstr := 'Save lower matrix as: ';
          defaultstr := 'lowermat';
          clickedok1 := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok1 then info := defaultstr else info := 'lowermat';
          if Length(info) > 0 then lowername := info
          else lowername := 'lowermat';
          prmptstr := 'Save upper matrix as: ';
          defaultstr := 'uppermat';
          clickedok2 := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok2 then info := defaultstr else info := 'uppermat';
          if Length(info) > 0 then uppername := info
          else uppername := 'uppermat';
          opstr := opstr + ':' + IntToStr(1) + '-' + lowername;
          opstr := opstr + ':' + IntToStr(2) + '-' + uppername;
         ScriptList.Items.Add(opstr);
         CurrentObjName := lowername;
         CurrentObjType := 1;
         CurrentGrid := 1;
         MatOneEdit.Text := lowername;
         ComboAdd(CurrentObjName);
         if clickedok1 then SaveFileMnuClick(Self);
         CurrentObjName := uppername;
         CurrentObjType := 1;
         CurrentGrid := 2;
         MatTwoEdit.Text := uppername;
         ComboAdd(CurrentObjName);
         if clickedok2 then SaveFileMnuClick(Self);
     end;
     // deallocate memory
     intvector := nil;
     Matrix4 := nil;
     Matrix3 := nil;
     Matrix2 := nil;
     Matrix1 := nil;
end;

procedure TMatManFrm.Vec2DiagMnuClick(Sender: TObject);
var
   i, vecgrid, matgrid : integer;
   info, prmptstr : string;
begin
     if scriptop = true then
     begin
          vecgrid := 1;
          matgrid := 2;
     end
     else begin
          prmptstr := 'Insert the vector from grid ';
          info := InputBox('VECTOR GRID',prmptstr,IntToStr(CurrentGrid));
          vecgrid := StrToInt(info);
          prmptstr := 'into the matrix diagonal in grid ';
          info := InputBox('MATRIX GRID',prmptstr,IntToStr(CurrentGrid));
          matgrid := StrToInt(info);
     end;
     case vecgrid of
     1 : Op2Edit.Text := MatOneEdit.Text;
     2 : Op2Edit.Text := MatTwoEdit.Text;
     3 : Op2Edit.Text := MatThreeEdit.Text;
     4 : Op2Edit.Text := MatFourEdit.Text;
     end;

     case matgrid of
     1 : begin
              Op3Edit.Text := MatOneEdit.Text;
              case vecgrid of
              2 : begin
                       if Rows2 > Cols2 then
                          for i := 1 to Rows2 do Grid1.Cells[i,i] := Grid2.Cells[1,i]
                       else for i := 1 to Cols2 do Grid1.Cells[i,i] := Grid2.Cells[i,1];
                  end;
              3 : begin
                       if Rows3 > Cols3 then
                          for i := 1 to Rows3 do Grid1.Cells[i,i] := Grid3.Cells[1,i]
                       else for i := 1 to Cols3 do Grid1.Cells[i,i] := Grid3.Cells[i,1];
                  end;
              4 : begin
                       if Rows4 > Cols4 then
                          for i := 1 to Rows4 do Grid1.Cells[i,i] := Grid4.Cells[1,i]
                       else for i := 1 to Cols4 do Grid1.Cells[i,i] := Grid4.Cells[i,1];
                  end;
              end;
         end;
         2 : begin
              Op3Edit.Text := MatTwoEdit.Text;
              case vecgrid of
              1 : begin
                       if Rows1 > Cols1 then
                          for i := 1 to Rows1 do Grid2.Cells[i,i] := Grid1.Cells[1,i]
                       else for i := 1 to Cols1 do Grid2.Cells[i,i] := Grid1.Cells[i,1];
                  end;
              3 : begin
                       if Rows3 > Cols3 then
                          for i := 1 to Rows3 do Grid2.Cells[i,i] := Grid3.Cells[1,i]
                       else for i := 1 to Cols3 do Grid2.Cells[i,i] := Grid3.Cells[i,1];
                  end;
              4 : begin
                       if Rows4 > Cols4 then
                          for i := 1 to Rows4 do Grid2.Cells[i,i] := Grid4.Cells[1,i]
                       else for i := 1 to Cols4 do Grid2.Cells[i,i] := Grid4.Cells[i,1];
                  end;
              end;
         end;
         3 : begin
              Op3Edit.Text := MatThreeEdit.Text;
              case vecgrid of
              1 : begin
                       if Rows1 > Cols1 then
                          for i := 1 to Rows1 do Grid3.Cells[i,i] := Grid1.Cells[1,i]
                       else for i := 1 to Cols1 do Grid3.Cells[i,i] := Grid1.Cells[i,1];
                  end;
              2 : begin
                       if Rows2 > Cols2 then
                          for i := 1 to Rows2 do Grid3.Cells[i,i] := Grid2.Cells[1,i]
                       else for i := 1 to Cols2 do Grid3.Cells[i,i] := Grid2.Cells[i,1];
                  end;
              4 : begin
                       if Rows4 > Cols4 then
                          for i := 1 to Rows4 do Grid3.Cells[i,i] := Grid4.Cells[1,i]
                       else for i := 1 to Cols4 do Grid3.Cells[i,i] := Grid4.Cells[i,1];
                  end;
              end;
         end;
         4 : begin
              Op3Edit.Text := MatFourEdit.Text;
              case vecgrid of
              1 : begin
                       if Rows1 > Cols1 then
                          for i := 1 to Rows1 do Grid4.Cells[i,i] := Grid1.Cells[1,i]
                       else for i := 1 to Cols1 do Grid4.Cells[i,i] := Grid1.Cells[i,1];
                  end;
              2 : begin
                       if Rows2 > Cols2 then
                          for i := 1 to Rows2 do Grid4.Cells[i,i] := Grid2.Cells[1,i]
                       else for i := 1 to Cols2 do Grid4.Cells[i,i] := Grid2.Cells[i,1];
                  end;
              3 : begin
                       if Rows3 > Cols3 then
                          for i := 1 to Rows3 do Grid4.Cells[i,i] := Grid3.Cells[1,i]
                       else for i := 1 to Cols3 do Grid4.Cells[i,i] := Grid3.Cells[i,1];
                  end;
              end;
         end;
     end; // case matgrid
     Op1Edit.Text := 'VecToDiag';

     if scriptop = false then
     begin
          opstr := IntToStr(CurrentGrid) + '-' + 'VecToDiag:';
          Op2Edit.Text := IntToStr(vecgrid) + '-' + Op2Edit.Text;
          opstr := opstr + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(matgrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentGrid := matgrid;
          CurrentObjName := Op3Edit.Text;
          CurrentObjType := 1; // column vector
          SaveFileMnuClick(Self);
          ComboAdd(CurrentObjName);
     end;
end;

procedure TMatManFrm.VecInmnuClick(Sender: TObject);
var
   instr : string;
   i, j : integer;

begin
     instr := InputBox('GRID?','Which grid no. (1-4):','1');
     CurrentGrid := StrToInt(instr);
     if ((CurrentGrid < 1) or (CurrentGrid > 4)) then CurrentGrid := 1;
     GridNoEdit.Text := IntToStr(CurrentGrid);
     instr := InputBox('TYPE','Row or Column Vector','Column');
     if instr = 'Column' then CurrentObjType := 2 else CurrentObjType := 3;
     if CurrentObjType = 3 then // row vector
     begin
          instr := InputBox('NAME','Object name:','ARowVector');
          CurrentObjName := instr;
          Rows := 1;
          instr := InputBox('RowVector','No. of elements = ','3');
          Cols := StrToInt(instr);
          RowVecCount := RowVecCount + 1;
          RowVecsBox.Items.Add(CurrentObjName);
          case CurrentGrid of
          1 : begin
                   Rows1 := Rows;
                   Cols1 := Cols;
                   Grid1.ColCount := Cols1 + 1;
                   Grid1.RowCount := 2;
                   MatOneEdit.Text := CurrentObjName;
                   for i := 0 to Rows1 do
                       for j := 0 to Cols1 do
                           Grid1.Cells[j,i] := '';
                   for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.'+ IntToStr(i);
                   for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row' + IntToStr(i);
              end;
          2 : begin
                   Rows2 := Rows;
                   Cols2 := Cols;
                   Grid2.ColCount := Cols2 + 1;
                   Grid2.RowCount := 2;
                   MatTwoEdit.Text := CurrentObjName;
                   for i := 0 to Rows2 do
                       for j := 0 to Cols2 do
                           Grid2.Cells[j,i] := '';
                   for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.'+ IntToStr(i);
                   for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row' + IntToStr(i);
              end;
          3 : begin
                   Rows3 := Rows;
                   Cols3 := Cols;
                   Grid3.ColCount := Cols3 + 1;
                   Grid3.RowCount := 2;
                   MatThreeEdit.Text := CurrentObjName;
                   for i := 0 to Rows3 do
                       for j := 0 to Cols3 do
                           Grid3.Cells[j,i] := '';
                   for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.'+ IntToStr(i);
                   for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row' + IntToStr(i);
              end;
          4 : begin
                   Rows4:= Rows;
                   Cols4:= Cols;
                   Grid4.ColCount := Cols4+ 1;
                   Grid4.RowCount := 2;
                   MatFourEdit.Text := CurrentObjName;
                   for i := 0 to Rows4 do
                       for j := 0 to Cols4 do
                           Grid4.Cells[j,i] := '';
                   for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.'+ IntToStr(i);
                   for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row' + IntToStr(i);
              end;
          end; // case
          Op1Edit.Text := 'RowVecInput';
          Op2Edit.Text := CurrentObjName;
          Op3Edit.Text := '';
     end
     else // column vector input
     begin
          instr := InputBox('NAME','Object name:','AColVector');
          CurrentObjName := instr;
          Cols := 1;
          instr := InputBox('ColumnVector','No. of elements = ','3');
          Rows := StrToInt(instr);
          case CurrentGrid of
          1 : begin
                   MatOneEdit.Text := CurrentObjName;
                   Cols1 := Cols;
                   Rows1 := Rows;
                   Grid1.ColCount := 2;
                   Grid1.RowCount := Rows1 + 1;
                   for i := 0 to Rows1 do
                       for j := 0 to Cols1 do
                           Grid1.Cells[j,i] := '';
                   for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.'+ IntToStr(i);
                   for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row' + IntToStr(i);
              end;
          2 : begin
                   MatTwoEdit.Text := CurrentObjName;
                   Cols2 := Cols;
                   Rows2 := Rows;
                   Grid2.ColCount := 2;
                   Grid2.RowCount := Rows2 + 1;
                   for i := 0 to Rows2 do
                       for j := 0 to Cols2 do
                           Grid2.Cells[j,i] := '';
                   for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.'+ IntToStr(i);
                   for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row' + IntToStr(i);
              end;
          3 : begin
                   MatThreeEdit.Text := CurrentObjName;
                   Cols3 := Cols;
                   Rows3 := Rows;
                   Grid3.ColCount := 2;
                   Grid3.RowCount := Rows3 + 1;
                   for i := 0 to Rows3 do
                       for j := 0 to Cols3 do
                           Grid3.Cells[j,i] := '';
                   for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.'+ IntToStr(i);
                   for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row' + IntToStr(i);
              end;
          4 : begin
                   MatFourEdit.Text := CurrentObjName;
                   Cols4 := Cols;
                   Rows4 := Rows;
                   Grid4.ColCount := 2;
                   Grid4.RowCount := Rows4 + 1;
                   for i := 0 to Rows4 do
                       for j := 0 to Cols4 do
                           Grid4.Cells[j,i] := '';
                   for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.'+ IntToStr(i);
                   for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row' + IntToStr(i);
              end;
          end; // case
          ColVecCount := ColVecCount + 1;
          ColVecsBox.Items.Add(CurrentObjName);
          Op1Edit.Text := 'ColVecInput';
          Op2Edit.Text := CurrentObjName;
          Op3Edit.Text := '';
     end;
     case CurrentGrid of
          1 : Grid1.SetFocus;
          2 : Grid2.SetFocus;
          3 : Grid3.SetFocus;
          4 : Grid4.SetFocus;
     end;
end;

procedure TMatManFrm.VecPrintMnuClick(Sender: TObject);
begin
     MatPrintMnuClick(Self);
end;

procedure TMatManFrm.VecRecipMnuClick(Sender: TObject);
var
   vectype, i, j : integer;
   prmptstr, info, priorobjname : string;
   clickedok : boolean;
   defaultstr : string;
begin
     CurrentObjName := 'VectorRecips';
     case Currentgrid of
     1 : begin
              priorobjname := MatOneEdit.Text;
              if Rows1 > Cols1 then vectype := 2 else vectype := 3;
              for i := 1 to Rows1 do
              begin
                   for j := 1 to Cols1 do
                   begin
                        if StrToFloat(Grid1.Cells[j,i]) = 0.0 then
                           ShowMessage('ERROR - attempt to divide by zero!')
                        else
                            Grid1.Cells[j,i] := FloatToStr(1.0 /StrToFloat(Grid1.Cells[j,i]));
                   end;
              end;
              MatOneEdit.Text := CurrentObjName;
         end;
     2 : begin
              priorobjname := MatTwoEdit.Text;
              if Rows2 > Cols2 then vectype := 2 else vectype := 3;
              for i := 1 to Rows2 do
              begin
                   for j := 1 to Cols2 do
                   begin
                        if StrToFloat(Grid2.Cells[j,i]) = 0.0 then
                           ShowMessage('ERROR - attempt to divide by zero!')
                        else
                            Grid2.Cells[j,i] := FloatToStr(1.0 /StrToFloat(Grid2.Cells[j,i]));
                   end;
              end;
              MatTwoEdit.Text := CurrentObjName;
         end;
     3 : begin
              priorobjname := MatThreeEdit.Text;
              if Rows3 > Cols3 then vectype := 2 else vectype := 3;
              for i := 1 to Rows3 do
              begin
                   for j := 1 to Cols3 do
                   begin
                        if StrToFloat(Grid3.Cells[j,i]) = 0.0 then
                           ShowMessage('ERROR - attempt to divide by zero!')
                        else
                            Grid3.Cells[j,i] := FloatToStr(1.0 /StrToFloat(Grid3.Cells[j,i]));
                   end;
              end;
              MatThreeEdit.Text := CurrentObjName;
         end;
     4 : begin
              priorobjname := MatFourEdit.Text;
              if Rows4 > Cols4 then vectype := 2 else vectype := 3;
              for i := 1 to Rows4 do
              begin
                   for j := 1 to Cols4 do
                   begin
                        if StrToFloat(Grid4.Cells[j,i]) = 0.0 then
                           ShowMessage('ERROR - attempt to divide by zero!')
                        else
                            Grid4.Cells[j,i] := FloatToStr(1.0 /StrToFloat(Grid4.Cells[j,i]));
                   end;
              end;
              MatFourEdit.Text := CurrentObjName;
          end;
     end; // end case

     if ScriptOp = false then
     begin
          opstr := IntToStr(Currentgrid) + '-' + 'VectorRecip:';
          opstr := opstr + IntToStr(Currentgrid) + '-' + priorobjname;
          prmptstr := 'Save recipricol of vector as: ';
          defaultstr := 'VectorRecip';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'VectorRecip';
          if Length(info) > 0 then  Op3Edit.Text := info
          else  begin
               Op3Edit.Text := 'VectorRecip';
               info := 'VectorRecip';
          end;
          opstr := opstr + ':' + IntToStr(CurrentGrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := vectype;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
     end;
end;

procedure TMatManFrm.VecSqrtMnuClick(Sender: TObject);
var
   vectype, i, j : integer;
   prmptstr, info, priorobjname : string;
   clickedok : boolean;
   defaultstr : string;
begin
     CurrentObjName := 'sqrtvector';
     case Currentgrid of
     1 : begin
              priorobjname := MatOneEdit.Text;
              if ExtractFileExt(priorobjname) = '.RVE' then vectype := 3 else vectype := 2;
              for i := 1 to Rows1 do
              begin
                   for j := 1 to Cols1 do
                   begin
                        if StrToFloat(Grid1.Cells[j,i]) < 0.0 then
                           ShowMessage('ERROR - attempt to take root of a negative value!')
                        else
                            Grid1.Cells[j,i] := FloatToStr(sqrt(abs(StrToFloat(Grid1.Cells[j,i]))));
                   end;
              end;
              MatOneEdit.Text := CurrentObjName;
         end;
     2 : begin
              priorobjname := MatTwoEdit.Text;
              if ExtractFileExt(priorobjname) = '.RVE' then vectype := 3 else vectype := 2;
              for i := 1 to Rows2 do
              begin
                   for j := 1 to Cols2 do
                   begin
                        if StrToFloat(Grid2.Cells[j,i]) < 0.0 then
                           ShowMessage('ERROR - attempt to take root of a negative value!')
                        else
                            Grid2.Cells[j,i] := FloatToStr(sqrt(abs(StrToFloat(Grid2.Cells[j,i]))));
                   end;
              end;
              MatTwoEdit.Text := CurrentObjName;
         end;
     3 : begin
              priorobjname := MatThreeEdit.Text;
              if ExtractFileExt(priorobjname) = '.RVE' then vectype := 3 else vectype := 2;
              for i := 1 to Rows3 do
              begin
                   for j := 1 to Cols3 do
                   begin
                        if StrToFloat(Grid3.Cells[j,i]) < 0.0 then
                           ShowMessage('ERROR - attempt to take root of a negative value!')
                        else
                            Grid3.Cells[j,i] := FloatToStr(sqrt(abs(StrToFloat(Grid3.Cells[j,i]))));
                   end;
              end;
              MatThreeEdit.Text := CurrentObjName;
         end;
     4 : begin
              priorobjname := MatFourEdit.Text;
              if ExtractFileExt(priorobjname) = '.RVE' then vectype := 3 else vectype := 2;
              for i := 1 to Rows4 do
              begin
                   for j := 1 to Cols4 do
                   begin
                        if StrToFloat(Grid4.Cells[j,i]) < 0.0 then
                           ShowMessage('ERROR - attempt to take root of a negative value!')
                        else
                            Grid4.Cells[j,i] := FloatToStr(sqrt(abs(StrToFloat(Grid4.Cells[j,i]))));
                   end;
              end;
              MatFourEdit.Text := CurrentObjName;
          end;
     end; // end case

     if ScriptOp = false then
     begin
          prmptstr := 'Save square root of vector as: ';
          defaultstr := 'SqrtVec';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'SqrtVec';
          if Length(info) > 0 then
          begin
               Op3Edit.Text := ':' + IntToStr(CurrentGrid) + '-' + info;
          end
          else  begin
               Op3Edit.Text := 'SqrtVec';
               info := 'SqrtVec';
          end;
          opstr := IntToStr(Currentgrid) + '-' + 'sqrtvector:';
          opstr := opstr + IntToStr(Currentgrid) + '-' + priorobjname;
          opstr := opstr + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := vectype;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case CurrentGrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
end;

procedure TMatManFrm.VecTransMnuClick(Sender: TObject);
label emsg;
var
   i, j, transgrid, vectype : integer;
   prmptstr, info : string;
   clickedok : boolean;
   defaultstr : string;
begin
     if CurrentGrid = 0 then exit;
     if ((CurrentObjType = 1) or (CurrentObjType = 4)) then
emsg:
     begin
          ShowMessage('Error - Selected grid does not contain a vector.');
          exit;
     end;
     if ScriptOp = true then CurrentGrid := 1;
     transgrid := CurrentGrid + 1;
     if transgrid > 4 then transgrid := 1;
     case CurrentGrid of
     1 : begin
              Op2Edit.Text := MatOneEdit.Text;
              // get type of resulting vector
              if Rows1 = 1 then vectype := 2 else vectype := 3;
              Grid2.RowCount := Grid1.ColCount;
              Grid2.ColCount := Grid1.RowCount;
              Rows2 := Grid2.RowCount-1;
              Cols2 := Grid2.ColCount-1;
              MatTwoEdit.Text := 'VectorTrans';
              for i := 1 to rows1 do
                  for j := 1 to cols1 do
                      Grid2.Cells[i,j] := Grid1.Cells[j,i];
         end;
     2 : begin
              Op2Edit.Text := MatTwoEdit.Text;
              if Rows2 = 1 then vectype := 2 else vectype := 3;
              Grid3.RowCount := Grid2.ColCount;
              Grid3.ColCount := Grid2.RowCount;
              Rows3 := Grid3.RowCount-1;
              Cols3 := Grid3.ColCount-1;
              MatThreeEdit.Text := 'VectorTrans';
              for i := 1 to rows2 do
                  for j := 1 to cols2 do
                      Grid3.Cells[i,j] := Grid2.Cells[j,i];
         end;
     3 : begin
              Op2Edit.Text := MatThreeEdit.Text;
              if Rows3 = 1 then vectype := 2 else vectype := 3;
              Grid4.RowCount := Grid3.ColCount;
              Grid4.ColCount := Grid3.RowCount;
              Rows4 := Grid4.RowCount-1;
              Cols4 := Grid4.ColCount-1;
              MatFourEdit.Text := 'VectorTrans';
              for i := 1 to rows3 do
                  for j := 1 to cols3 do
                      Grid4.Cells[i,j] := Grid3.Cells[j,i];
         end;
     4 : begin
              Op2Edit.Text := MatFourEdit.Text;
              if Rows4 = 1 then vectype := 2 else vectype := 3;
              Grid1.RowCount := Grid4.ColCount;
              Grid1.ColCount := Grid4.RowCount;
              Rows1 := Grid4.RowCount-1;
              Cols1 := Grid4.ColCount-1;
              MatOneEdit.Text := 'VectorTrans';
              for i := 1 to rows4 do
                  for j := 1 to cols4 do
                      Grid1.Cells[i,j] := Grid4.Cells[j,i];
         end;
     end;
     Op1Edit.Text := 'Vec.Transpose';
     opstr := IntToStr(CurrentGrid) + '-' + 'VectorTranspose:';
     opstr := opstr +  IntToStr(CurrentGrid) + '-' + Op2Edit.Text;
     if ScriptOp = false then
     begin
          prmptstr := 'Save vector transpose as: ';
          defaultstr := 'VecTrans';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'VecTrans';
          if Length(info) > 0 then
          begin
               Op3Edit.Text := info;
          end
          else  begin
               Op3Edit.Text := 'VecTrans';
               info := 'VecTrans';
          end;
          opstr := opstr + ':' + IntToStr(transgrid) + '-' + Op3Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := vectype;
          CurrentGrid := transgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case transgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
end;

procedure TMatManFrm.VecXscalarMnuClick(Sender: TObject);
// multiplication of a scaler times a vector
var
   i, j, vectype : integer;
   precols, postcols, prerows, postrows : integer;
   info : string;
   pregrid, postgrid, resultgrid : integer;
   prmptstr : string;
   premat, postmat, prodmat : DynMat;
   clickedok : boolean;
   defaultstr : string;
begin
     if ScriptOp = false then
     begin
          prmptstr := 'The scaler is in grid ' + IntToStr(CurrentGrid);
          info := inputbox('SCALER',prmptstr,'2');
          if info = '' then exit;
          pregrid := StrToInt(info);
          prmptstr := 'The vector is in grid ' + IntToStr(CurrentGrid);
          info := inputbox('VECTOR',prmptstr,'2');
          if info = '' then exit;
          postgrid := StrToInt(info);
          info := inputbox('RESULTS INTO','Place results in grid :','3');
          if info = '' then exit;
          resultgrid := StrToInt(info);
     end
     else begin // executing the script
          pregrid := 1;
          postgrid := 2;
          resultgrid := 3;
     end;
     case pregrid of
     1 : begin
              precols := Cols1;
              prerows := Rows1;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op2Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              precols := Cols2;
              prerows := Rows2;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
         Op2Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              precols := Cols3;
              prerows := Rows3;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
         Op2Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              precols := Cols4;
              prerows := Rows4;
              SetLength(premat,prerows,precols);
              for i := 0 to prerows-1 do
                  for j := 0 to precols-1 do
                      premat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
         Op2Edit.Text := MatFourEdit.Text;
         end;
     end;
     case postgrid of
     1 : begin
              postcols := Cols1;
              postrows := Rows1;
              SetLength(postmat,postrows,postcols);
              if Cols1 > Rows1 then vectype := 3 else vectype := 2;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid1.Cells[j+1,i+1]);
              Op3Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              postcols := Cols2;
              postrows := Rows2;
              SetLength(postmat,postrows,postcols);
              if Cols2 > Rows2 then vectype := 3 else vectype := 2;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid2.Cells[j+1,i+1]);
              Op3Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              postcols := Cols3;
              postrows := Rows3;
              SetLength(postmat,postrows,postcols);
              if Cols3 > Rows3 then vectype := 3 else vectype := 2;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid3.Cells[j+1,i+1]);
              Op3Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              postcols := Cols4;
              postrows := Rows4;
              SetLength(postmat,postrows,postcols);
              if Cols4 > Rows4 then vectype := 3 else vectype := 2;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      postmat[i,j] := StrToFloat(Grid4.Cells[j+1,i+1]);
              Op3Edit.Text := MatFourEdit.Text;
          end;
     end;
     SetLength(prodmat,postrows,postcols);
     for i := 0 to postrows-1 do
         for j := 0 to postcols-1 do
                 prodmat[i,j] := premat[0,0]*postmat[i,j];
     case resultgrid of
     1 : begin
              Grid1.RowCount := postrows+1;
              Grid1.ColCount := postcols+1;
              Rows1 := postrows;
              Cols1 := postcols;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      Grid1.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows1 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols1 do Grid1.Cells[i,0] := 'Col.' + IntToStr(i);
              MatOneEdit.Text := 'Product';
              Op4Edit.Text := MatOneEdit.Text;
         end;
     2 : begin
              Grid2.RowCount := postrows+1;
              Grid2.ColCount := postcols+1;
              Rows2 := postrows;
              Cols2 := postcols;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      Grid2.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows2 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols2 do Grid2.Cells[i,0] := 'Col.' + IntToStr(i);
              MatTwoEdit.Text := 'Product';
              Op4Edit.Text := MatTwoEdit.Text;
         end;
     3 : begin
              Grid3.RowCount := postrows+1;
              Grid3.ColCount := postcols+1;
              Rows3 := postrows;
              Cols3 := postcols;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      Grid3.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows3 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols3 do Grid3.Cells[i,0] := 'Col.' + IntToStr(i);
              MatThreeEdit.Text := 'Product';
              Op4Edit.Text := MatThreeEdit.Text;
         end;
     4 : begin
              Grid4.RowCount := postrows+1;
              Grid4.ColCount := postcols+1;
              Rows4 := postrows;
              Cols4 := postcols;
              for i := 0 to postrows-1 do
                  for j := 0 to postcols-1 do
                      Grid4.Cells[j+1,i+1] := format('%10.5f',[prodmat[i,j]]);
              for i := 1 to Rows4 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
              for i := 1 to Cols4 do Grid4.Cells[i,0] := 'Col.' + IntToStr(i);
              MatFourEdit.Text := 'Product';
              Op4Edit.Text := MatFourEdit.Text;
         end;
     end;
     Op1Edit.Text := 'ScalerxVector';
     if ScriptOp = false then
     begin
          Op2Edit.Text := ExtractFileName(Op2Edit.Text);
          Op3Edit.Text := ExtractFileName(Op3Edit.Text);
          Op4Edit.Text := ExtractFileName(Op4Edit.Text);
          opstr := IntToStr(CurrentGrid) + '-';
          opstr := opstr + 'ScalerxVector:' + IntToStr(pregrid) + '-' + Op2Edit.Text;
          opstr := opstr + ':' + IntToStr(postgrid) + '-' + Op3Edit.Text;
          prmptstr := 'Save product as: ';
          defaultstr := 'ScalerxVec';
          clickedok := InputQuery('SAVE AS',prmptstr,defaultstr);
          if clickedok then info := defaultstr else info := 'ScalerxVec';
          if Length(info) > 0 then
          begin
               Op4Edit.Text := info;
          end
          else  begin
               Op4Edit.Text := 'ScalerxVec';
               info := 'ScalerxVec';
          end;
          opstr := opstr + ':' + IntToStr(resultgrid) + '-' + Op4Edit.Text;
          ScriptList.Items.Add(opstr);
          CurrentObjName := info;
          CurrentObjType := vectype;
          CurrentGrid := resultgrid;
          ComboAdd(CurrentObjName);
          if clickedok then SaveFileMnuClick(Self);
          case resultgrid of
          1 : MatOneEdit.Text := info;
          2 : MatTwoEdit.Text := info;
          3 : MatThreeEdit.Text := info;
          4 : MatFourEdit.Text := info;
          end;
     end;
     // deallocate memory
     prodmat := nil;
     postmat := nil;
     premat := nil;
end;

procedure TMatManFrm.GetFile(Sender: TObject);
begin
     OpenDialog1.Filter := 'Matrix (*.mat)|*.MAT|Col.Vector (*.CVE)|*.CVE|RowVector (*.RVE)|*.RVE|Scaler (*.scl)|*.SCA|All (*.*)|*.*';
     OpenDialog1.FilterIndex := CurrentObjType;
     case CurrentObjType of
          1 : OpenDialog1.DefaultExt := '.MAT';
          2 : OpenDialog1.DefaultExt := '.CVE';
          3 : OpenDialog1.DefaultExt := '.RVE';
          4 : OpenDialog1.DefaultExt := '.SCA';
          else OpenDialog1.DefaultExt := '.MAT';
     end;
     GridNoEdit.Text := IntToStr(CurrentGrid);
     GetGridData(CurrentGrid);
end;

procedure TMatManFrm.GetGridData(gridno: integer);
var
   SaveFile : TextFile;
   i, j, iRows, iCols : integer;
   cellstring : string;
//   OpStr : string;
   FName : string;

begin
     if OpenDialog1.Execute then
     begin
          AssignFile(SaveFile, OpenDialog1.FileName);
          Reset(SaveFile);
          Readln(SaveFile,CurrentObjType);
          Readln(SaveFile,CurrentObjName);
          CurrentObjName := ExtractFileName(CurrentObjName);
          Readln(SaveFile,iRows);
          Readln(SaveFile,iCols);
          SetLength(Matrix1,iRows,iCols);
          for i := 1 to iRows do
          begin
               for j := 1 to iCols do
               begin
                    Readln(SaveFile,cellstring);
                    Matrix1[i-1,j-1] := StrToFloat(cellstring);
               end;
          end;
          CloseFile(SaveFile);
     end else exit;

     case gridno of
     1 : begin
              MatOneEdit.Text := CurrentObjName;
              Rows1 := iRows;
              Cols1 := iCols;
              Grid1.RowCount := iRows + 1;
              Grid1.ColCount := iCols + 1;
              for i := 1 to iCols do Grid1.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to iRows do Grid1.Cells[0,i] := 'Row' + IntToStr(i);
              for i := 1 to iRows do
                  for j := 1 to iCols do
                      Grid1.Cells[j,i] := FloatToStr(Matrix1[i-1,j-1]);
         end;
     2 : begin
              MatTwoEdit.Text := CurrentObjName;
              Rows2 := iRows;
              Cols2 := iCols;
              Grid2.RowCount := iRows + 1;
              Grid2.ColCount := iCols + 1;
              for i := 1 to iCols do Grid2.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to iRows do Grid2.Cells[0,i] := 'Row' + IntToStr(i);
              for i := 1 to iRows do
                  for j := 1 to iCols do
                      Grid2.Cells[j,i] := FloatToStr(Matrix1[i-1,j-1]);
         end;
     3 : begin
              MatThreeEdit.Text := CurrentObjName;
              Rows3 := iRows;
              Cols3 := iCols;
              Grid3.RowCount := iRows + 1;
              Grid3.ColCount := iCols + 1;
              for i := 1 to iCols do Grid3.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to iRows do Grid3.Cells[0,i] := 'Row' + IntToStr(i);
              for i := 1 to iRows do
                  for j := 1 to iCols do
                      Grid3.Cells[j,i] := FloatToStr(Matrix1[i-1,j-1]);
         end;
     4 : begin
              MatFourEdit.Text := CurrentObjName;
              Rows4 := iRows;
              Cols4 := iCols;
              Grid4.RowCount := iRows + 1;
              Grid4.ColCount := iCols + 1;
              for i := 1 to iCols do Grid4.Cells[i,0] := 'Col.'+ IntToStr(i);
              for i := 1 to iRows do Grid4.Cells[0,i] := 'Row' + IntToStr(i);
              for i := 1 to iRows do
                  for j := 1 to iCols do
                      Grid4.Cells[j,i] := FloatToStr(Matrix1[i-1,j-1]);
         end;
     end;
     FName := ExtractFileName(CurrentObjName);
     ComboAdd(FName);

     if ScriptOp = false then
     begin
          FName := IntToStr(CurrentGrid) + '-' + FName;
          OpStr := IntToStr(CurrentGrid) + '-' + 'FileOpen:' + FName;
          if ScriptOptsFrm.CheckGroup1.Checked[0] <> true then ScriptList.Items.Add(OpStr);
          Op1Edit.Text := 'FileOpen';
          Op2Edit.Text := CurrentObjName;
          Op3Edit.Text := '';
          Op4Edit.Text := '';
     end;

     Matrix1 := nil;
end;

function TMatManFrm.sign(a, b: double): double;
begin
      IF (b >= 0.0) THEN sign := abs(a) ELSE sign := -abs(a)
end;

function TMatManFrm.max(a, b: double): double;
begin
      IF (a > b) THEN max := a ELSE max := b
end;

procedure TMatManFrm.matinv(a, vtimesw, v, w: DynMat; n: integer);
LABEL 1,2,3;

VAR
   ainverse : array of array of double;
   m,mp,np,nm,l,k,j,its,i: integer;
   z,y,x,scale,s,h,g,f,c,anorm: double;
   rv1: array of double;

begin
   setlength(rv1,n);
   setlength(ainverse,n,n);
   m := n;
   mp := n;
   np := n;
   g := 0.0;
   scale := 0.0;
   anorm := 0.0;
   FOR i := 0 to n-1 DO BEGIN
      l := i+1;
      rv1[i] := scale*g;
      g := 0.0;
      s := 0.0;
      scale := 0.0;
      IF (i <= m-1) THEN BEGIN
         FOR k := i to m-1 DO BEGIN
            scale := scale+abs(a[k,i])
         END;
         IF (scale <> 0.0) THEN BEGIN
            FOR k := i to m-1 DO BEGIN
               a[k,i] := a[k,i]/scale;
               s := s+a[k,i]*a[k,i]
            END;
            f := a[i,i];
            g := -sign(sqrt(s),f);
            h := f*g-s;
            a[i,i] := f-g;
            IF (i <> n-1) THEN BEGIN
               FOR j := l to n-1 DO BEGIN
                  s := 0.0;
                  FOR k := i to m-1 DO BEGIN
                     s := s+a[k,i]*a[k,j]
                  END;
                  f := s/h;
                  FOR k := i to m-1 DO BEGIN
                     a[k,j] := a[k,j]+
                        f*a[k,i]
                  END
               END
            END;
            FOR k := i to m-1 DO BEGIN
               a[k,i] := scale*a[k,i]
            END
         END
      END;
      w[i,i] := scale*g;
      g := 0.0;
      s := 0.0;
      scale := 0.0;
      IF ((i <= m-1) AND (i <> n-1)) THEN BEGIN
         FOR k := l to n-1 DO BEGIN
            scale := scale+abs(a[i,k])
         END;
         IF (scale <> 0.0) THEN BEGIN
            FOR k := l to n-1 DO BEGIN
               a[i,k] := a[i,k]/scale;
               s := s+a[i,k]*a[i,k]
            END;
            f := a[i,l];
            g := -sign(sqrt(s),f);
            h := f*g-s;
            a[i,l] := f-g;
            FOR k := l to n-1 DO BEGIN
               rv1[k] := a[i,k]/h
            END;
            IF (i <> m-1) THEN BEGIN
               FOR j := l to m-1 DO BEGIN
                  s := 0.0;
                  FOR k := l to n-1 DO BEGIN
                     s := s+a[j,k]*a[i,k]
                  END;
                  FOR k := l to n-1 DO BEGIN
                     a[j,k] := a[j,k]
                        +s*rv1[k]
                  END
               END
            END;
            FOR k := l to n-1 DO BEGIN
               a[i,k] := scale*a[i,k]
            END
         END
      END;
      anorm := max(anorm,(abs(w[i,i])+abs(rv1[i])))
   END;
   FOR i := n-1 DOWNTO 0 DO BEGIN
      IF (i < n-1) THEN BEGIN
         IF (g <> 0.0) THEN BEGIN
            FOR j := l to n-1 DO BEGIN
               v[j,i] := (a[i,j]/a[i,l])/g
            END;
            FOR j := l to n-1 DO BEGIN
               s := 0.0;
               FOR k := l to n-1 DO BEGIN
                  s := s+a[i,k]*v[k,j]
               END;
               FOR k := l to n-1 DO BEGIN
                  v[k,j] := v[k,j]+s*v[k,i]
               END
            END
         END;
         FOR j := l to n-1 DO BEGIN
            v[i,j] := 0.0;
            v[j,i] := 0.0
         END
      END;
      v[i,i] := 1.0;
      g := rv1[i];
      l := i
   END;
   FOR i := n-1 DOWNTO 0 DO BEGIN
      l := i+1;
      g := w[i,i];
      IF (i < n-1) THEN BEGIN
         FOR j := l to n-1 DO BEGIN
            a[i,j] := 0.0
         END
      END;
      IF (g <> 0.0) THEN BEGIN
         g := 1.0/g;
         IF (i <> n-1) THEN BEGIN
            FOR j := l to n-1 DO BEGIN
               s := 0.0;
               FOR k := l to m-1 DO BEGIN
                  s := s+a[k,i]*a[k,j]
               END;
               f := (s/a[i,i])*g;
               FOR k := i to m-1 DO BEGIN
                  a[k,j] := a[k,j]+f*a[k,i]
               END
            END
         END;
         FOR j := i to m-1 DO BEGIN
            a[j,i] := a[j,i]*g
         END
      END ELSE BEGIN
         FOR j := i to m-1 DO BEGIN
            a[j,i] := 0.0
         END
      END;
      a[i,i] := a[i,i]+1.0
   END;
   FOR k := n-1 DOWNTO 0 DO BEGIN
      FOR its := 1 to 30 DO BEGIN
         FOR l := k DOWNTO 0 DO BEGIN
            nm := l-1;
            IF ((abs(rv1[l])+anorm) = anorm) THEN GOTO 2;
            IF ((abs(w[nm,nm])+anorm) = anorm) THEN GOTO 1
         END;
1:       c := 0.0;
         s := 1.0;
         FOR i := l to k DO BEGIN
            f := s*rv1[i];
            IF ((abs(f)+anorm) <> anorm) THEN BEGIN
               g := w[i,i];
               h := sqrt(f*f+g*g);
               w[i,i] := h;
               h := 1.0/h;
               c := (g*h);
               s := -(f*h);
               FOR j := 0 to m-1 DO BEGIN
                  y := a[j,nm];
                  z := a[j,i];
                  a[j,nm] := (y*c)+(z*s);
                  a[j,i] := -(y*s)+(z*c)
               END
            END
         END;
2:         z := w[k,k];
         IF (l = k) THEN BEGIN
            IF (z < 0.0) THEN BEGIN
               w[k,k] := -z;
               FOR j := 0 to n-1 DO BEGIN
               v[j,k] := -v[j,k]
            END
         END;
         GOTO 3
         END;
         IF (its = 30) THEN BEGIN
            showmessage('No convergence in 30 SVDCMP iterations');
            exit;
         END;
         x := w[l,l];
         nm := k-1;
         y := w[nm,nm];
         g := rv1[nm];
         h := rv1[k];
         f := ((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y);
         g := sqrt(f*f+1.0);
         f := ((x-z)*(x+z)+h*((y/(f+sign(g,f)))-h))/x;
         c := 1.0;
         s := 1.0;
         FOR j := l to nm DO BEGIN
            i := j+1;
            g := rv1[i];
            y := w[i,i];
            h := s*g;
            g := c*g;
            z := sqrt(f*f+h*h);
            rv1[j] := z;
            c := f/z;
            s := h/z;
            f := (x*c)+(g*s);
            g := -(x*s)+(g*c);
            h := y*s;
            y := y*c;
            FOR nm := 0 to n-1 DO BEGIN
               x := v[nm,j];
               z := v[nm,i];
               v[nm,j] := (x*c)+(z*s);
               v[nm,i] := -(x*s)+(z*c)
            END;
            z := sqrt(f*f+h*h);
            w[j,j] := z;
            IF (z <> 0.0) THEN BEGIN
               z := 1.0/z;
               c := f*z;
               s := h*z
            END;
            f := (c*g)+(s*y);
            x := -(s*g)+(c*y);
            FOR nm := 0 to m-1 DO BEGIN
               y := a[nm,j];
               z := a[nm,i];
               a[nm,j] := (y*c)+(z*s);
               a[nm,i] := -(y*s)+(z*c)
            END
         END;
         rv1[l] := 0.0;
         rv1[k] := f;
         w[k,k] := x
      END;
3:   END;
{     mat_print(m,a,'U matrix');
     mat_print(n,v,'V matrix');
     writeln(lst,'Diagonal values of W inverse matrix');
      for i := 1 to n do
         write(lst,1/w[i]:6:3);
     writeln(lst);  }
     for i := 0 to n-1 do
         for j := 0 to n-1 do
         begin
              if w[i,i] < 1.0e-6 then vtimesw[i,j] := 0
              else vtimesw[i,j] := v[i,j] * (1.0 / w[j,j] );
         end;
{     mat_print(n,vtimesw,'V matrix times w inverse ');  }
     for i := 0 to m-1 do
         for j := 0 to n-1 do
         begin
             ainverse[i,j] := 0.0;
             for k := 0 to m-1 do
             begin
                  ainverse[i,j] := ainverse[i,j] + vtimesw[i,k] * a[j,k]
             end;
         end;
{     mat_print(n,ainverse,'Inverse Matrix'); }
     for i := 0 to n-1 do
         for j := 0 to n-1 do
             a[i,j] := ainverse[i,j];
     ainverse := nil;
     rv1 := nil;
end;

procedure TMatManFrm.ResetGrids(Sender: TObject);
var
   i, j : integer;

begin
       rows1 := 4;
       cols1 := 4;
       Grid1.RowCount := 5;
       Grid1.ColCount := 5;
       for i := 0 to Rows1 do
           for j := 0 to Cols1 do
               Grid1.Cells[j,i] := '';
       Grid1.Cells[0,0] := 'Row/Col';
       for i := 1 to rows1 do Grid1.Cells[0,i] := 'Row ' + IntToStr(i);
       for i := 1 to cols1 do Grid1.Cells[i,0] := 'Col ' + IntToStr(i);

       rows2 := 4;
       cols2 := 4;
       Grid2.RowCount := 5;
       Grid2.ColCount := 5;
       for i := 0 to Rows2 do
           for j := 0 to Cols2 do
               Grid2.Cells[j,i] := '';
       Grid2.Cells[0,0] := 'Row/Col';
       for i := 1 to rows2 do Grid2.Cells[0,i] := 'Row ' + IntToStr(i);
       for i := 1 to cols2 do Grid2.Cells[i,0] := 'Col ' + IntToStr(i);

       rows3 := 4;
       cols3 := 4;
       Grid3.RowCount := 5;
       Grid3.ColCount := 5;
       for i := 0 to Rows3 do
           for j := 0 to Cols3 do
               Grid3.Cells[j,i] := '';
       Grid3.Cells[0,0] := 'Row/Col';
       for i := 1 to rows3 do Grid3.Cells[0,i] := 'Row ' + IntToStr(i);
       for i := 1 to cols3 do Grid3.Cells[i,0] := 'Col ' + IntToStr(i);

       rows4 := 4;
       cols4 := 4;
       Grid4.RowCount := 5;
       Grid4.ColCount := 5;
       for i := 0 to Rows4 do
           for j := 0 to Cols4 do
               Grid4.Cells[j,i] := '';
       Grid4.Cells[0,0] := 'Row/Col';
       for i := 1 to rows4 do Grid4.Cells[0,i] := 'Row ' + IntToStr(i);
       for i := 1 to cols4 do Grid4.Cells[i,0] := 'Col ' + IntToStr(i);

//     ScriptList.Clear;
     CurrentObjName := '';
     CurrentObjType := 0;
     CurrentGrid := 1;
     CurrentObjType := 1;
     Op4Edit.Text := '';
     Op1Edit.Text := '';
     Op2Edit.Text := '';
     Op3Edit.Text := '';
     MatOneEdit.Text := '';
     MatTwoEdit.Text := '';
     MatThreeEdit.Text := '';
     MatFourEdit.Text := '';
     MatCount := 0;
     ColVecCount := 0;
     RowVecCount := 0;
     ScaCount := 0;
     Saved := true;
     ScriptOp := false;
     LastScript := 0;
     LastGridNo := 1;
     GridNoEdit.Text := '1';
     MatricesBox.Clear;
     MatricesBox.Text := 'Matrices';
     ColVecsBox.Clear;
     ColVecsBox.Text := 'Col.Vectors';
     RowVecsBox.Clear;
     RowVecsBox.Text := 'RowVectors';
     ScalarsBox.Clear;
     ScalarsBox.Text := 'Scalers';
//     PrntForm.RichEdit.Clear;
end;

function TMatManFrm.DuplicateMat(str: string): boolean;
var
   itemcnt : integer;
   i : integer;
   rslt : boolean;

begin
     rslt := false;
     itemcnt := MatricesBox.Items.Count;
     if itemcnt > 0 then
     begin
          for i := 0 to itemcnt - 1 do
              if MatricesBox.Items.Strings[i] = str then rslt := true;
     end;
     Result := rslt;
end;

function TMatManFrm.DuplicateColVec(str: string): boolean;
var
   itemcnt : integer;
   i : integer;
   rslt : boolean;

begin
     rslt := false;
     itemcnt := ColVecsbox.Items.Count;
     if itemcnt > 0 then
     begin
          for i := 0 to itemcnt - 1 do
              if ColVecsBox.Items.Strings[i] = str then rslt := true;
     end;
     Result := rslt;
end;

function TMatManFrm.DuplicateRowVec(str: string): boolean;
var
   itemcnt : integer;
   i : integer;
   rslt : boolean;

begin
     rslt := false;
     itemcnt := RowVecsBox.Items.Count;
     if itemcnt > 0 then
     begin
          for i := 0 to itemcnt - 1 do
              if RowVecsBox.Items.Strings[i] = str then rslt := true;
     end;
     Result := rslt;
end;

function TMatManFrm.DuplicateScaler(str: string): boolean;
var
   itemcnt : integer;
   i : integer;
   rslt : boolean;

begin
     rslt := false;
     itemcnt := scalarsBox.Items.Count;
     if itemcnt > 0 then
     begin
          for i := 0 to itemcnt - 1 do
              if ScalarsBox.Items.Strings[i] = str then rslt := true;
     end;
     Result := rslt;
end;

procedure TMatManFrm.tred2(var a: DynMat; n: integer; var d, e: DynVec);
VAR
   L,k,j,i: integer;
   scale,hh,h,g,f: double;

begin
   IF (n > 1) THEN
   BEGIN
      FOR i := n-1 DOWNTO 1 DO
      BEGIN
         L := i-1;
         h := 0.0;
         scale := 0.0;
         IF (L > 0) THEN
         BEGIN
            FOR k := 0 to L DO scale := scale+abs(a[i,k]);
            IF (scale = 0.0) THEN e[i] := a[i,L]
            ELSE BEGIN
               FOR k := 0 to L DO
               BEGIN
                  a[i,k] := a[i,k]/scale;
                  h := h+sqr(a[i,k])
               END;
               f := a[i,L];
               g := -sign(sqrt(h),f);
               e[i] := scale*g;
               h := h-f*g;
               a[i,L] := f-g;
               f := 0.0;
               FOR j := 0 to L DO
               BEGIN
                  (* Next statement can be omitted if eigenvectors not wanted *)
                  a[j,i] := a[i,j]/h;
                  g := 0.0;
                  FOR k := 0 to j DO g := g+a[j,k]*a[i,k];
                  IF (L > j) THEN FOR k := j+1 to L DO g := g+a[k,j]*a[i,k];
                  e[j] := g/h;
                  f := f+e[j]*a[i,j]
               END;
               hh := f/(h+h);
               FOR j := 0 to L DO
               BEGIN
                  f := a[i,j];
                  g := e[j]-hh*f;
                  e[j] := g;
                  FOR k := 0 to j DO a[j,k] := a[j,k]-(f*e[k]+g*a[i,k]);
               END;
            END;
         END ELSE e[i] := a[i,L];
         d[i] := h;
      END;
   END;
   (* Next statement can be omitted if eigenvectors not wanted *)
   d[0] := 0.0;
   e[0] := 0.0;
   FOR i := 0 to n-1 DO
   BEGIN
       (* Contents of this loop can be omitted if eigenvectors not wanted,
          except for statement d[i] := a[i,i]; *)
      L := i-1;
      IF (d[i] <> 0.0) THEN
      BEGIN
         FOR j := 0 to L DO
         BEGIN
            g := 0.0;
            FOR k := 0 to L DO g := g+a[i,k]*a[k,j];
            FOR k := 0 to L DO a[k,j] := a[k,j]-g*a[k,i];
         END;
      END;
      d[i] := a[i,i];
      a[i,i] := 1.0;
      IF (L >= 0) THEN
      BEGIN
         FOR j := 0 to L DO BEGIN
            a[i,j] := 0.0;
            a[j,i] := 0.0;
         END;
      END;
   END;
end;

procedure TMatManFrm.ludcmp(var a: DynMat; n: integer; var indx: DynIntVec;
  var d: double);
CONST   tiny=1.0e-20;

VAR   k,j,imax,i: integer;
      sum,dum,big: double;
      vv: DynVec;

begin
   SetLength(vv,n);
   d := 1.0;
   FOR i := 0 to n-1 DO BEGIN
      big := 0.0;
      FOR j := 0 to n-1 DO IF (abs(a[i,j]) > big) THEN big := abs(a[i,j]);
      IF (big = 0.0) THEN BEGIN
         ShowMessage('Error - Singular matrix!');
         vv := nil;
         exit;
      END;
      vv[i] := 1.0/big;
   END;
   FOR j := 0 to n-1 DO BEGIN
      IF (j > 0) THEN BEGIN
         FOR i := 0 to j-1 DO BEGIN
            sum := a[i,j];
            IF (i > 0) THEN BEGIN
               FOR k := 0 to i-1 DO sum := sum-a[i,k]*a[k,j];
               a[i,j] := sum;
            END;
         END;
      END;
      big := 0.0;
      FOR i := j to n-1 DO BEGIN
         sum := a[i,j];
         IF (j > 0) THEN BEGIN
            FOR k := 0 to j-1 DO sum := sum-a[i,k]*a[k,j];
            a[i,j] := sum;
         END;
         dum := vv[i]*abs(sum);
         IF (dum >= big) THEN BEGIN
            big := dum;
            imax := i;
         END;
      END;
      IF (j <> imax) THEN BEGIN
         FOR k := 0 to n-1 DO BEGIN
            dum := a[imax,k];
            a[imax,k] := a[j,k];
            a[j,k] := dum;
         END;
         d := -d;
         vv[imax] := vv[j];
      END;
      indx[j] := imax;
      IF (a[j,j] = 0.0) THEN a[j,j] := tiny;
      IF (j <> n-1) THEN BEGIN
         dum := 1.0/a[j,j];
         FOR i := j+1 to n-1 DO a[i,j] := a[i,j]*dum;
      END
   END;
   IF (a[n-1,n-1] = 0.0) THEN a[n-1,n-1] := tiny;
   vv := nil;
end;

procedure TMatManFrm.DynMatPrint(var xmat: DynMat; rows, cols: integer;
  var title: string; var ColHeadings: Dynstrarray);
var
   i, j, first, last, nflds : integer;
   done : boolean;
   outline: string;
   valstring: string;

begin
     OutputFrm.RichEdit.Lines.Add(title);
     OutputFrm.RichEdit.Lines.Add('');
     nflds := 4;
     done := FALSE;
     first := 0;
     while not done do
     begin
          OutputFrm.RichEdit.Lines.Add('');
          OutputFrm.RichEdit.Lines.Add('                   Columns');
          outline := '          ';
          last := first + nflds;
          if last >= cols - 1 then
          begin
               done := TRUE;
               last := cols - 1
          end;
          for i := first to last do
          begin
               outline := outline + format('%12s ',[ColHeadings[i]]);
          end;
          OutputFrm.RichEdit.Lines.Add(outline);
          OutputFrm.RichEdit.Lines.Add('Rows');
          for i := 0 to rows-1 do
          begin
               outline := format('%5d     ',[i+1]);
               for j := first to last do
               begin
                    valstring := format('%12.3f ',[xmat[i,j]]);
                    outline := outline + valstring;
               end;
               OutputFrm.RichEdit.Lines.Add(outline);
          end;
          OutputFrm.RichEdit.Lines.Add('');
          first := last + 1
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('');
end;

procedure TMatManFrm.ComboAdd(FileName: String);
var
   rslt : boolean;

begin
     if CurrentObjType = 1 then // matrix
     begin
          rslt := DuplicateMat(FileName);
          if rslt = false then
          begin
               MatricesBox.Items.Add(FileName);
               MatCount := MatCount + 1;
          end;
     end;

     if (CurrentObjType = 2) then // column vector
     begin
          rslt := DuplicateColVec(FileName);
          if rslt = false then
          begin
               ColVecsBox.Items.Add(FileName);
               ColVecCount := ColVecCount + 1;
          end;
     end;

     if CurrentObjType = 3 then // row vector
     begin
          rslt := DuplicateRowVec(FileName);
          if rslt = false then
          begin
               RowVecsBox.Items.Add(FileName);
               RowVecCount := RowVecCount + 1;
          end;
     end;

     if CurrentObjType = 4 then // scaler
     begin
          rslt := DuplicateScaler(FileName);
          if rslt = false then
          begin
               ScalarsBox.Items.Add(FileName);
               ScaCount := ScaCount + 1;
          end;
     end;
end;

procedure TMatManFrm.tqli(var d: DynVec; var e: DynVec; n: integer;
  var z: DynMat);
LABEL 1,2;
VAR
   m,L,iter,i,k: integer;
   s,r,p,g,f,dd,c,b: double;

begin
   IF  (n > 1)  THEN
   BEGIN
      FOR i := 1 to n-1 DO  e[i-1] := e[i];
      e[n-1] := 0.0;
      FOR L := 0 to n-1 DO
      BEGIN
           iter := 0;
1:         FOR m := L to n-2 DO
           BEGIN
               dd := abs(d[m])+abs(d[m+1]);
               IF  ((abs(e[m])+ dd) = dd) THEN  GOTO 2
           END;
           m := n-1;
2:         IF (m <> L) THEN
           BEGIN
               IF (iter = 30) THEN
               BEGIN
                    showmessage('Too many iterations in routine tqli-returning');
                    exit;
               END;
               iter := iter+1;
               g := (d[L+1]-d[L])/(2.0*e[L]);
               r := sqrt(sqr(g)+1.0);
               g := d[m]-d[L]+e[L]/(g+sign(r,g));
               s := 1.0;
               c := 1.0;
               p := 0.0;
               FOR i := m-1 DOWNTO L DO
               BEGIN
                   f := s*e[i];
                   b := c*e[i];
                   IF (abs(f) >= abs(g)) THEN
                   BEGIN
                       c := g/f;
                       r := sqrt(sqr(c)+1.0);
                       e[i+1] := f*r;
                       s := 1.0/r;
                       c := c*s
                   END
                   ELSE BEGIN
                       s := f/g;
                       r := sqrt(sqr(s)+1.0);
                       e[i+1] := g*r;
                       c := 1.0/r;
                       s := s*c
                   END;
                   g := d[i+1]-p;
                   r := (d[i]-g)*s+2.0*c*b;
                   p := s*r;
                   d[i+1] := g+p;
                   g := c*r-b;
                   (* Next loop can be omitted if eigenvectors not wanted *)
                   FOR k := 0 to n-1 DO
                   BEGIN
                       f := z[k,i+1];
                       z[k,i+1] := s*z[k,i]+c*f;
                       z[k,i] := c*z[k,i]-s*f
                   END
               END;
              d[L] := d[L]-p;
              e[L] := g;
              e[m] := 0.0;
              GOTO 1
           END;
      END;
   END;
end;

procedure TMatManFrm.xtqli(var a: DynMat; NP: integer; var d: DynVec;
  var f: DynVec; var e: DynVec);
var
   i : integer;
   sum : double;

begin
     sum := 0.0;
     tred2(a, NP, d, e);
     tqli(d, e, NP, a);
     for i := 0 to NP-1 do
     begin
          f[i] := 0.0;
          sum := sum + d[i];
     end;
     for i := 0 to NP-1 do f[i] := (d[i] / sum) * 100.0;
end;

function TMatManFrm.SEVS(nv, nf: integer; C: double; var r: DynMat;
  var v: DynMat; var e: DynVec; var p: DynVec; nd: integer): integer;
Label Label12, Label13;
var
     i, j, k, M : integer;
     t, ee, ev, sum : double;

begin
     // extracts roots and denormal vectors from a symetric matrix.
     // Veldman, 1967, page 209

     t := 0.0;
     for i := 0 to nv-1 do t := t + r[i,i];
     for k := 0 to nf-1 do // roots in e(k) and vector in v(.k)
     begin
          for i := 0 to nv-1 do p[i] := 1.0;
          e[k] := 1.0;
          for M := 0 to 99 do
          begin
             for i := 0 to nv-1 do v[i,k] := p[i] / e[k];
             for i := 0 to nv-1 do
             begin
                 sum := 0.0;
                 for j := 0 to nv-1 do
                 begin
                     sum := sum + (r[i,j] * v[j,k]);
                 end;
                 p[i] := sum;
             end;
             ee := 0.0;
             for j := 0 to nv-1 do ee := ee + p[j] * v[j,k];
             e[k] := sqrt(abs(ee));
          end;
          if (ee < (C * C)) then goto label12;
          for i := 0 to nv-1 do
          begin
                for j := 0 to nv - 1 do r[i,j] := r[i,j] - (v[i,k] * v[j,k]);
          end;
     end;
     goto label13;
label12:
     nf := k - 1;
label13:
     for i := 0 to nf-1 do p[i] := e[i] / t * 100.0;
     ev := 0.0;
     for i := 0 to nf-1 do ev := ev + p[i];
     //outform.list1.AddItem "Trace := " & fmtstring(t, 6, 3) & " " &
     //fmtstring(ev, 6, 3) & " Pct. of trace extracted by " & fmtstring
     //(nf, 3, 0) & " roots."
     //lineno := lineno + 1
     result := nf;
end;

procedure TMatManFrm.nonsymroots(var a: DynMat; nv: integer; var nf: integer;
  c: double; var v: DynMat; var e: DynVec; var x: DynVec; var t: double;
  var ev: double);
Label endit;
var
     y, z : DynVec;
     ek, e2, d : double;
     i, j, k, m : integer;

begin
     // roots and vectors of a non symetric matrix.  a is square matrix
     // entered and is destroyed in process.  nv is number of variables
     // (rows and columns )of a.  nf is the number of factors to be
     // extracted - is output as the number which exceeded c, the
     // minimum eigenvalue to be extracted.  v is the output matrix of
     // column vectors of loadings.  e is the output vector of roots. x
     // is the percentages of trace for factors. t is the trace of the
     // matrix and ev is the percent of trace extracted.

     e2 := 0.0;
     setlength(y,nv);
     setlength(z,nv);
     t := 0.0;
     for i := 0 to nv-1 do t := t + a[i,i];
     for k := 0 to nf-1 do
     begin
          for i := 0 to nv-1 do
          begin
               x[i] := 1.0;
               y[i] := 1.0;
          end;
          e[k] := 1.0;
          ek := 1.0;
          for m := 0 to 99 do
          begin
               for i := 0 to nv-1 do
               begin
                    v[i,k] := x[i] / e[k];
                    z[i] := y[i] / ek;
               end;
               for i := 0 to nv-1 do
               begin
                    x[i] := 0.0;
                    for j := 0 to nv-1 do x[i] := x[i] + a[i,j] * v[j,k];
                    y[i] := 0.0;
                    for j := 0 to nv-1 do y[i] := y[i] + a[j,i] * z[j];
               end;
               e2 := 0.0;
               for j := 0 to nv-1 do e2 := e2 + x[j] * v[j,k];
               e[k] := sqrt(abs(e2));
               ek := 0.0;
               for j := 0 to nv-1 do ek := ek + y[j] * z[j];
               ek := sqrt(abs(ek));
          end;
          if (e2 >= (c * c)) then
          begin
               d := 0.0;
               for j := 0 to nv-1 do d := d + v[j,k] * z[j];
               d := e[k] / d;
               for i := 0 to nv-1 do
                   for j := 0 to nv-1 do
                       a[i,j] := a[i,j] - v[i,k] * z[j] * d;
          end
          else
          begin
               nf := k - 1;
               goto endit;
          end;
     end;
endit:
     for i := 0 to nf-1 do x[i] := e[i] / t * 100.0;
     ev := 0.0;
     for i := 0 to nf-1 do ev := ev + x[i];
     z := nil;
     y := nil;
end;

procedure TMatManFrm.OPRINC(S: DynVec; M, IA: integer; var EVAL: DynVec;
  var EVEC: DynMat; var COMP: DynMat; var VARPCNT: DynVec; var CL: DynVec;
  var CU: DynVec; var IER: integer);
var
    i, j, k : integer;
    zero, one, rnine, hund, scale, an, sum, sumr, anp, anm : double;

begin
    // Adapted from the IMSL routine OPRINC.  S contains the lower half
    // of a covariance or correlation matrix (including the diagonal
    // values.) It returns eigenvalues in the EVAL vector, eigenvectors
    // in the matrix EVEC from the analysis of S.  The order of the
    // matrix is M and IA roots roots are extracted.  Comp is a
    // returned M by M component correlation matrix.  VARPCNT of length M
    // contains percentages of total variance associated with the
    // components, in the order of the eigenvalues.  On entry, CL is
    // the number of subjects on which S is based.  On return it
    // contains the left 95% confidence bounds on the eigenvalues.  CU
    // returns the right 95% confidence bounds on the eigenvalues. IER
    // is the error flag returned and is zero if there is no error.
    // NOTE!! Counting starts at 1, not 0!

    zero := 0.0;
    one := 1.0;
    rnine := 9.0;
    hund := 100.0;
    scale := 2.7718585822513;
    IER := 0;
    an := CL[1];
    for i := 1 to M do
    begin
        for j := 1 to M do EVEC[i,j] := 0.0;
        EVEC[i,i] := 1.0;
    end;
    k := 0;
    for i := 1 to M do
    begin
        k := k + i;
        CL[i] := sqrt(S[k]);
    end;
    EHOUSS(S, M, EVAL, VARPCNT, CU);
    EQRT2S(EVAL, VARPCNT, M, EVEC, IA, IER);
    if (IER <> 0) then
    begin
        UERTST(IER,'OPRINC');
        exit;
    end;
    EHOBKS(S, M, 1, M, EVEC, IA);
    sum := zero;
    for i := 1 to M do
    begin
        if (EVAL[i] < zero) then EVAL[i] := 0;
        sum := sum + EVAL[i];
    end;
    sumr := hund / sum;
    for i := 1 to M do VARPCNT[i] := EVAL[i] * sumr;
    // compute COMP (correlations) matrix
    for i := 1 to M do
    begin
        sumr := one / CL[i];
        for j := 1 to M do COMP[i,j] := sqrt(EVAL[j]) * EVEC[i,j] * sumr;
    end;
    if (an < rnine) then
    begin
        an := rnine;
        IER := 34;
    end;
    an := sqrt(an-one);
    // Compute vector CL
    anp := an / (an + scale);
    anm := an / (an - scale);
    for i := 1 to M do
    begin
        CL[i] := EVAL[i] * anp;
        CU[i] := EVAL[i] * anm;
    end;
    if (IER <> 0) then UERTST(IER,'OPRINC');
end;

procedure TMatManFrm.EHOUSS(var A: DynVec; N: integer; var D: DynVec;
  var E: DynVec; var E2: DynVec);
Label fifteen, sixtyfive;
var
	zero, h, scale, f, g, hh : double;
	np1, nn, nbeg, ii, i, j, L, nk, k, jk1, ik, jk, jp1 : integer;

begin
    //Called by OPRINC for obtaining eigenvalues and vectors
    // Adapted from the IMSL routine by the same name
    //NOTE! Subscripts start at 1, not 0!

    zero := 0.0;
    np1 := N + 1;
    nn := (N * np1) div 2 - 1;
    nbeg := nn + 1 - N;
    for ii := 1 to N do // major loop
    begin
        i := np1 - ii;
        L := i - 1;
        h := zero;
        scale := zero;
        if (L >= 1) then
        begin
            nk := nn;
            for k := 1 to L do
            begin
                scale := scale + abs(A[nk]);
                nk := nk - 1;
            end;
            if (scale <> 0.0) then goto fifteen;
        end;
        E[i] := zero;
        E2[i] := zero;
        goto sixtyfive;
fifteen: nk := nn;
        for k := 1 to L do
        begin
            A[nk] := A[nk] / scale;
            h := h + (A[nk] * A[nk]);
            nk := nk - 1;
        end;
        E2[i] := scale * scale * h;
        f := A[nn];
        g := -DSIGN(sqrt(h),f);
        E[i] := scale * g;
        h := h - (f * g);
        A[nn] := f - g;
        if (L <> 1) then
        begin
            f := zero;
            jk1 := 1;
            for j := 1 to L do
            begin
                g := zero;
                ik := nbeg + 1;
                jk := jk1;
                // form element of A * U
                for k := 1 to j do
                begin
                    g := g + (A[jk] * A[ik]);
                    jk := jk + 1;
                    ik := ik + 1;
                end;
                jp1 := j + 1;
                if (L >= jp1) then
                begin
                    jk := jk + (j - 1);
                    for k := jp1 to L do
                    begin
                        g := g + (A[jk] * A[ik]);
                        jk := jk + k;
                        ik := ik + 1;
                    end;
                end;
                E[j] := g / h;
                f := f + (E[j] * A[nbeg + j]);
                jk1 := jk1 + j;
            end; // 40
            hh := f / (h + h);
            // form reduced A
            jk := 1;
            for j := 1 to L do
            begin
                f := A[nbeg + j];
                g := E[j] - hh * f;
                E[j] := g;
                for k := 1 to j do
                begin
                    A[jk] := A[jk] - (f * E[k]) - (g * A[nbeg + k]);
                    jk := jk + 1;
                end;
            end;
        end; // end if L <> 1
        for k := 1 to L do A[nbeg+k] := A[nbeg+k] * scale;
sixtyfive: D[i] := A[nbeg+i];
        A[nbeg+i] := h * scale * scale;
        nbeg := nbeg - i + 1;
        nn := nn - i;
    end; // 70
end;

function TMatManFrm.DSIGN(X, Y: double): double;
begin
    if (Y < 0.0) then result := -abs(X)
    else result := abs(X);
end;

function TMatManFrm.isign(a, b: integer): integer;
begin
     IF (b >= 0) then isign := abs(a) ELSE isign := -abs(a)
end;

procedure TMatManFrm.EQRT2S(var D: DynVec; var E: DynVec; N: integer;
  var Z: DynMat; var IZ: integer; var IER: integer);
Label twenty, fiftyfive, fifty, thirtyfive;
var
    B, C, F, G, H, P, R, S, RDELP, ONE, ZERO : double;
    i1, I, II, J, K, L, L1, M, MM1, MM1PL, IP1 : integer;

begin
    // Adapted from the IMSL routine by the same name
    // NOTE! Subscripts start at 1, not 0!
    // On input, the vector D of length N contains the diagonal
    // elements of the symmetric tridiagonal matrix T.  On output, D
    // contains the eigenvalues of T in ascending order. On input, the
    // vector e of length N contains the sub-diagonal elements of T in
    // position 2,...,N. On output, E is destroyed. N -order of
    // tridiagonal matrix T. (input) Z -On input, z contains the
    // identity matrix of order N.  On output, Z contains the
    // eigenvector in column J of Z corresponding to the eigenvalue
    // D[j].
    // -Input row dimension of matrix Z exactly as specified in the
    // calling program.  If IZ is less than N, the eigenvectors are not
    // computed.  In this case, Z is not used.
    // IER - Error parameter.

    RDELP := 0.222045E-15;
    ONE := 1.0;
    ZERO := 0.0;

    // Move the last N-1 elements of E into the first N-1 locations
    IER := 0;
    if (N = 1) then exit;
    for i1 := 2 to N do E[i1-1] := E[i1];
    E[N] := ZERO;
    B := ZERO;
    F := ZERO;
    for L := 1 to N do
    begin
        J := 0;
        H := RDELP * (abs(D[L]) + abs(E[L]));
        if (B < H) then B := H;
        // Look for small sub-diagonal element
        for M := 1 to N do
        begin
            K := M;
            if (abs(E[K]) <= B) then continue;
        end;
        M := K;
        if (M = L) then goto fiftyfive;
twenty: if (J = 30) then
        begin
            IER := 128 + L;
            UERTST(IER,'EQR2S');
            exit;
        end;
        J := J + 1;
        L1 := L + 1;
        G := D[L];
        P := (D[L1] - G) / (E[L] + E[L]);
        R := abs(P);
        if (RDELP * abs(P) < 1.0) then R := sqrt(P * P + ONE);
        D[L] := E[L] / (P + DSIGN(R,P));
        H := G - D[L];
        for I := L1 to N do D[I] := D[I] - H;
        F := F + H;
        // QL Transformation
        P := D[M];
        C := ONE;
        S := ZERO;
        MM1 := M - 1;
        MM1PL := MM1 + L;
        if (L > MM1) then goto fifty;
        for II := L to MM1 do
        begin
            I := MM1PL - II;
            G := C * E[I];
            H := C * P;
            if (abs(P) >= abs(E[I])) then
            begin
                C := E[I] / P;
                R := sqrt(C * C + ONE);
                E[I + 1] := S * P * R;
                S := C / R;
                C := ONE / R;
                goto thirtyfive;
            end;
            C := P / E[I];
            R := sqrt(C * C + ONE);
            E[I + 1] := S * E[I] * R;
            S := ONE / R;
            C := C * S;
thirtyfive: P := C * D[I] - S * G;
            D[I + 1] := H + S * (C * G + S * D[I]);
            if (IZ >= N) then
            begin
                // Form vector
                for K := 1 to N do
                begin
                    H := Z[K,I+1];
                    Z[K,I+1] := S * Z[K,I] + C * H;
                    Z[K,I] := C * Z[K,I] - S * H;
                end;
            end;
        end; // next II
fifty:  E[L] := S * P;
        D[L] := C * P;
        if (abs(E[L]) > B) then goto twenty;
fiftyfive: D[L] := D[L] + F;
    end; // next L
    // Order Eigenvalues and Eigenvectors
    for I := 1 to N do
    begin
        K := I;
        P := D[I];
        IP1 := I + 1;
        if (IP1 <= N) then
        begin
            for J := IP1 to N do
            begin
                if (D[J] >= P) then continue;
                K := J;
                P := D[J];
            end;
        end;
        if (K = I) then exit;
        D[K] := D[I];
        D[I] := P;
        if (IZ < N) then exit;
        for J := 1 to N do
        begin
            P := Z[J,I];
            Z[J,I] := Z[J,K];
            Z[J,K] := P;
        end;
    end; // next I
end;

procedure TMatManFrm.EHOBKS(var A: DynVec; N, M1, M2: integer; var Z: DynMat;
  IZ: integer);
var
    H, S : double;
    I, L, J, K, IA : integer;

begin
    // IMSL routine by the same name
    if (N = 1) then exit;
    for I := 2 to N do
    begin
        L := I - 1;
        IA := (I * L) div 2;
        H := A[IA+I];
        if (H = 0.0) then exit;
        // Derives eigenvectors M1 to M2 of the original matrix from
        // M1 to M2 of the symmetric tridiagonal matrix
        for J := M1 to M2 do
        begin
            S := 0.0;
            for K := 1 to L do S := S + (A[IA+K] * Z[K,J]);
            S := S / H;
            for K := 1 to L do Z[K,J] := Z[K,J] - (S * A[IA+K]);
        end;
    end;
end;

procedure TMatManFrm.UERTST(IER: integer; aNAME: string);
var
    IEQDF, LEVEL: integer;
    IEQ, NAMSET, NAMUPK, NAMEQ, ASTRING : string;

begin
    // Substitute for the IMSL routine by the same name
    // IER is input error parameter where IER := I + J where
    // I := 128 implies terminal error message,
    // I := 64 implies warning with fix message,
    // I := 32 implies warning message,
    // J := error code relevant to calling routine.
    // NAME is a character string providing the name of the calling
    // routine output is displayed as an application message box

    IEQDF := 0;
    LEVEL := 4;
    IEQ := '=';
    NAMSET := 'UERSET';
    NAMEQ := '      ';

    NAMUPK := NAME;
    if (IER <= 999) then
    begin
        if (LEVEL < 4) then
        begin
            IEQDF := 0;
            exit;
        end;
    end;
    if (IER < -32) then
    begin
        IEQDF := 1;
        NAMEQ := NAMUPK;
        exit;
    end;
    if (IER < 128) then
    begin

    end;

    astring := 'Routine ';
    astring := astring + NAME;
    astring := astring + ' called UERTST with the error code = ';
    astring := astring + IntToStr(IER);
    ShowMessage(astring);
end;

procedure TMatManFrm.Roots(var RMat: DynMat; NITEMS: integer;
  var EIGENVAL: DynVec; var EIGENVEC: DynMat);
var
    i, j, L, IER, size, size2, NSUBS : integer;
    EVAL : DynVec;
    DCORR : DynVec;
    PERVAR : DynVec;
    ICL  : DynVec;
    CU   : DynVec;
    COMP : DynMat;
    EVEC : DynMat;
    response : string;

begin
    size := ((NITEMS * (NITEMS - 1)) div 2) + NITEMS + 1;
    size2 := (NITEMS + 1) * (NITEMS + 1);
    setlength(DCORR,size);
    setlength(EVAL,size);
    setlength(PERVAR,size);
    setlength(ICL,size);
    setlength(CU,size);
    setlength(COMP,size2,size2);
    setlength(EVEC,size2,size2);
    // Move values up one subscript in array since the roots routine
    // counts from 1, not zero. Store only lower half matrix
    L := 1;
    response := inputbox('Sample Size','No. of cases :','1000');
    NSUBS := StrToInt(response); // number of cases
    for i := 0 to NITEMS-1 do
    begin
        for j := 0 to i do
        begin
            DCORR[L] := RMat[i,j];
            L := L + 1;
        end;
    end;
    DCORR[0] := 0.0;

    // Get the iegenvalues and vectors of the correlation matrix.
    // EVAL holds the values and EVEC holds the vectors
    ICL[1] := NSUBS;
    OPRINC(DCORR,NITEMS,NITEMS,EVAL,EVEC,COMP,PERVAR,ICL,CU,IER);
    for i := 1 to NITEMS do
    begin
         EIGENVAL[i-1] := EVAL[i];
         for j := 1 to NITEMS do
         begin
              EIGENVEC[i-1,j-1] := EVEC[i,j];
         end;
    end;
    EVEC := nil;
    COMP := nil;
    CU := nil;
    ICL := nil;
    PERVAR := nil;
    DCORR := nil;
    EVAL := nil;
end;

procedure TMatManFrm.SymMatRoots(A: DynMat; M: integer; var E: DynVec;
  var V: DynMat);
Label one, three, nine, fifteen;
var
   L, IT, j, k : integer;
   Test, sum1, sum2 : double;
   X, Y, Z : DynVec;

begin
//  Adapted from: "Multivariate Data Analysis" by William W. Cooley and Paul
//  R. Lohnes, 1971, page 121
     SetLength(X, M);
     SetLength(Y, M);
     SetLength(Z, M);
     sum2 := 0.0;
     L := 0;
     Test := 0.00000001;
one:
     IT := 0;
     for j := 0 to M-1 do Y[j] := 1.0;
three:
     IT := IT + 1;
     for j := 0 to M-1 do
     begin
          X[j] := 0.0;
          for k := 0 to M-1 do X[j] := X[j] + (A[j,k] * Y[k]);
     end;
     E[L] := X[0];
     Sum1 := 0.0;
     for j := 0 to M-1 do
     begin
          V[j,L] := X[j] / X[0];
          Sum1 := Sum1 + abs(Y[j] - V[j,L]);
          Y[j] := V[j,L];
     end;
     if (IT - 10) <> 0 then goto nine;
     if (Sum2 - Sum1) > 0 then goto nine
     else
     begin
          showmessage('Root not converging. Exiting.');
          exit;
     end;
nine:
     Sum2 := Sum1;
     if (Sum1 - Test) > 0 then goto three;
     Sum1 := 0.0;
     for j := 0 to M-1 do Sum1 := Sum1 + (V[j,L] * V[j,L]);
     Sum1 := sqrt(Sum1);
     for j := 0 to M-1 do V[j,L] := V[j,L] / Sum1;
     for j := 0 to M-1 do
         for k := 0 to M-1 do
             A[j,k] := A[j,k] - (V[j,L] * V[k,L] * E[L]);
     if ((M-1)-L) <= 0 then goto fifteen;
     L := L + 1;
     goto one;
fifteen:
     Z := nil;
     Y := nil;
     X := nil;
end;

function TMatManFrm.OpParse(var Operation: string; OpStr: string;
  var Op1: string; var Op2: string; var Op3: string; var Opergrid: integer;
  var Op1grid: integer; var Op2grid: integer; var Op3grid: integer): integer;
var
   colonpos, dashpos : integer;

begin
     Operation := '';
     Op1 := '';
     Op2 := '';
     Op3 := '';
     colonpos := AnsiPos(':',OpStr);
     if colonpos = 0 then
     begin
          ShowMessage('Operation code not found in a script entry.');
          result := 0;
          exit;
     end;
     Operation := copy(OpStr,1,colonpos-1);
     OpStr := copy(OpStr,colonpos+1,length(OpStr));
     colonpos := AnsiPos(':',OpStr);

     if colonpos > 0 then // more than one operand
     begin
          Op1 := copy(OpStr,1,colonpos-1);
          OpStr := copy(OpStr,colonpos+1,length(OpStr));
          colonpos := AnsiPos(':',OpStr);
          if colonpos > 0 then // more than two operands
          begin
               Op2 := copy(OpStr,1,colonpos-1);
               Op3 := copy(OpStr,colonpos+1,length(OpStr));
          end
          else Op2 := copy(OpStr,1,length(OpStr));
     end
     else if length(OpStr) > 0 then Op1 := OpStr;

     // Now, strip the grid number for each part (n-)
     // first, set defaults
     Opergrid := 0;
     Op1grid := 0;
     Op2grid := 0;
     Op3grid := 0;
     dashpos := AnsiPos('-',Operation);
     if dashpos > 0 then
     begin
          Opergrid := StrToInt(copy(Operation,dashpos-1,1));
          Operation := copy(Operation,dashpos+1,length(Operation));
     end;
     dashpos := AnsiPos('-',Op1);
     if dashpos > 0 then
     begin
          Op1grid := StrToInt(copy(Op1,dashpos-1,1));
          Op1 := copy(Op1,dashpos+1,length(Op1));
     end;

     dashpos := AnsiPos('-',Op2);
     if dashpos > 0 then
     begin
          Op2grid := StrToInt(copy(Op2,dashpos-1,1));
          Op2 := copy(Op2,dashpos+1,length(Op2));
     end;

     dashpos := AnsiPos('-',Op3);
     if dashpos > 0 then
     begin
          Op3grid := StrToInt(copy(Op3,dashpos-1,1));
          Op3 := copy(Op3,dashpos+3,length(Op3));
     end;

     Op1Edit.Text := Operation;
     Op2Edit.Text := Op1;
     Op3Edit.Text := Op2;
     Op4Edit.Text := Op3;
     result := 1;
end;

procedure TMatManFrm.OperExec;
var
   prompt, response : string;
   SaveFile : TextFile;

begin
     if Opergrid > 0 then CurrentGrid := Opergrid;
     Op2Edit.Text := '';
     Op2Edit.Text := '';
     Op4Edit.Text := '';
{
     if Operation = 'FileOpen' then
     begin
          if Op1grid > 0 then Currentgrid := Op1grid;
          OpenDialog1.FileName := Op1;
          GetFile(Self);
     end;

     if Operation = 'FileSave' then
     begin
          if Op1grid > 0 then Currentgrid := Op1grid;
          SaveDialog1.FileName := Op1;
          CurrentObjName := Op1;
          mnuSaveClick(Self);
     end;

     if Operation = 'KeyMatInput' then
     begin
          prompt := 'Input data matrix for ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then KeyMatClick(Self);
     end;

     if Operation = 'KeyVecInput' then
     begin
          prompt := 'Input vector for ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then KeyVectClick(Self);
     end;

     if Operation = 'KeyScalerInput' then
     begin
          prompt := 'Input the scaler ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then KeyScalerClick(Self);
     end;
}
     if Operation = 'RowAugment' then
     begin
          prompt := 'Row augment the matrix ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               RowAugMnuClick(Self);
          end;
     end;

     if Operation = 'ColAugment' then
     begin
          prompt := 'Column augment the matrix ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               ColAugMnuClick(Self);
          end;
     end;

     if Operation = 'DeleteRow' then
     begin
          prompt := 'Delete matrix row in ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               RowDelMnuClick(Self);
          end;
     end;

     if Operation = 'DeleteCol' then
     begin
          prompt := 'Delete matrix column in ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               ColDelMnuClick(Self);
          end;
     end;

     if Operation = 'SVDInverse' then
     begin
          prompt := 'Invert the matrix ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               SVDInvMnuClick(Self);
          end;
     end;

     if Operation = 'PreMatxPostMat' then
     begin
          prompt := 'Premultiply ' + Op1 + ' by ' + Op2 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               CurrentGrid := 1;
               CurrentObjType := 1;
               OpenDialog1.FileName := Op1;
               GetFile(Self);
               CurrentGrid := 2;
               Op3Edit.Text := Op2;
               OpenDialog1.FileName := Op2;
               CurrentObjType := 1;
               GetFile(Self);
               Op4Edit.Text := Op3;
               PreMatMnuClick(Self);
          end;
     end;

     if Operation = 'Tridiagonalize' then
     begin
          prompt := 'Tridiagonalize the matrix ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               TriDiagMnuClick(Self);
          end;
     end;

     if Operation = 'UpLowDecomp' then
     begin
          prompt := 'Obtain upper and lower decompositon of ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               ULDecompMnuClick(Self);
          end;
     end;

     if Operation = 'DiagToVec' then
     begin
          prompt := 'Copy diagonal of ' + Op1 + ' to vector ' + Op2 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               DiagtovecmnuClick(Self);
          end;
     end;

     if Operation = 'Determinant' then
     begin
          prompt := 'Obtain determinant of matrix ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               DetermMnuClick(Self);
          end;
     end;

     if Operation = 'MatTranspose' then
     begin
          prompt := 'Obtain transpose of matrix ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               TransMnuClick(Self);
          end;
     end;

     if Operation = 'MatrixRoots' then
     begin
          prompt := 'Obtain eigenvalues and vectors of matrix ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               EigenMnuClick(Self);
          end;
     end;

     if Operation = 'MatTrace' then
     begin
          prompt := 'Obtain trace of matrix ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               TraceMnuClick(Self);
          end;
     end;

     if Operation = 'NormalizeRows' then
     begin
          prompt := 'Normalize rows of matrix ' + Op1 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               NormRowsMnuClick(Self);
          end;
     end;

     if Operation = 'NormalizeCols' then
     begin
          prompt := 'Normalize columns of matrix ' + Op1 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if Op1grid > 0 then CurrentGrid := Op1grid;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               NormColsMnuClick(Self);
          end;
     end;

     if Operation = 'MatMinusMat' then
     begin
          prompt := 'Subtract matrix ' + Op2 + ' from ' + Op1 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               CurrentGrid := 1;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               CurrentGrid := 2;
               OpenDialog1.FileName := Op2;
               CurrentObjType := 1;
               GetFile(Self);
               MatSubMnuClick(Self);
          end;
     end;

     if Operation = 'MatPlusMat' then
     begin
          prompt := 'Add matrix ' + Op1 + ' to ' + Op2 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               Currentgrid := 1;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               CurrentGrid := 2;
               OpenDialog1.FileName := Op2;
               CurrentObjType := 1;
               GetFile(Self);
               MatSumMnuClick(Self);
          end;
     end;

     if Operation = 'PreVecxPostMat' then
     begin
          prompt := 'Multiply matrix ' + Op1 + ' by row vector ' + Op2 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op2;
               Currentgrid := 1;
               OpenDialog1.FileName := Op2;
               CurrentObjType := 3;
               GetFile(Self);
               CurrentGrid := 2;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               PrebyRowVmnuClick(Self);
          end;
     end;

     if Operation = 'ScalerxPostMat' then
     begin
          prompt := 'Multiply scaler ' + Op1 + ' times matrix ' + Op2 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               Currentgrid := 1;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 4;
               GetFile(Self);
               CurrentGrid := 2;
               Op3Edit.Text := Op2;
               OpenDialog1.FileName := Op2;
               CurrentObjType := 1;
               GetFile(Self);
               PreScalarMnuClick(Self);
          end;
     end;

     if Operation = 'PreMatxPostVec' then
     begin
          prompt := 'Multiply matrix ' + Op1 + ' by col.Vector ' + Op2 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               Currentgrid := 1;
               CurrentObjType := 1;
               OpenDialog1.FileName := Op1;
               GetFile(Self);
               CurrentGrid := 2;
               Op3Edit.Text := Op2;
               OpenDialog1.FileName := Op2;
               CurrentObjType := 2;
               GetFile(Self);
               PostColVMnuClick(Self);
          end;
     end;

     if Operation = 'MatxPostMat' then
     begin
          prompt := 'Multiply matrix ' + Op1 + ' by matrix ' + Op2 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               Currentgrid := 1;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               CurrentGrid := 2;
               Op3Edit.Text := Op2;
               OpenDialog1.FileName := Op2;
               CurrentObjType := 1;
               GetFile(Self);
               PostMatMnuClick(Self);
          end;
     end;

     if Operation = 'VectorTranspose' then
     begin
          prompt := 'Transpose vector ' + Op1  + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               Currentgrid := 1;
               OpenDialog1.FileName := Op1;
               if FileExists(Op1) then
               begin
                    AssignFile(SaveFile, Op1);
                    Reset(SaveFile);
                    Readln(SaveFile,CurrentObjType);
                    CloseFile(SaveFile);
               end;
               GetFile(Self);
               VecTransMnuClick(Self);
          end;
     end;

     if Operation = 'ScalerxVector' then
     begin
          prompt := 'Multiply vector ' + Op2  + ' by scaler ' + Op1 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op2;
               if FileExists(Op2) then
               begin
                    AssignFile(SaveFile, Op2);
                    Reset(SaveFile);
                    Readln(SaveFile,CurrentObjType);
                    CloseFile(SaveFile);
               end;
               Currentgrid := 1;
               OpenDialog1.FileName := Op2;
               GetFile(Self);
               Op3Edit.Text := Op1;
               CurrentGrid := 2;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 4;
               GetFile(Self);
               VecXscalarMnuClick(Self);
          end;
     end;

     if Operation = 'sqrtvector' then
     begin
          prompt := 'Square root of elements in vector ' + Op1 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if FileExists(Op1) then
               begin
                    AssignFile(SaveFile, Op1);
                    Reset(SaveFile);
                    Readln(SaveFile,CurrentObjType);
                    CloseFile(SaveFile);
               end;
               Currentgrid := 1;
               OpenDialog1.FileName := Op1;
               GetFile(Self);
               VecSqrtMnuClick(Self);
          end;
     end;

     if Operation = 'VectorRecip' then
     begin
          prompt := 'Recipricol of elements in vector ' + Op1 + '?';
          response := InputBox('EXECUTE',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               if FileExists(Op1) then
               begin
                    AssignFile(SaveFile, Op1);
                    Reset(SaveFile);
                    Readln(SaveFile,CurrentObjType);
                    CloseFile(SaveFile);
               end;
               Currentgrid := 1;
               OpenDialog1.FileName := Op1;
               GetFile(Self);
               VecRecipMnuClick(Self);
          end;
     end;

     if Operation = 'VecxVec' then
     begin
          prompt := 'Multiply ' + Op1 + ' times ' + Op2 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               CurrentGrid := 1;
               OpenDialog1.FileName := Op1;
               if ExtractFileExt(Op1) = '.CVE' then
                  CurrentObjType := 2
               else CurrentObjType := 3;
               GetFile(Self);
               CurrentGrid := 2;
               Op3Edit.Text := Op2;
               OpenDialog1.FileName := Op2;
               if ExtractFileExt(Op2) = '.CVE' then
                  CurrentObjType := 2
               else CurrentObjType := 3;
               GetFile(Self);
               Op4Edit.Text := Op3;
               RowxColVecMnuClick(Self);
          end;
     end;

     if Operation = 'SqrtScaler' then
     begin
          prompt := 'Square root of scaler ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               CurrentGrid := 1;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 4;
               GetFile(Self);
               ScalSqrtMnuClick(Self);
          end;
     end;

     If Operation = 'ScalerRecip' then
     begin
          prompt := 'Recipricol of scaler ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               CurrentGrid := 1;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 4;
               GetFile(Self);
               ScalRecipMnuClick(Self);
          end;
     end;

     if Operation = 'ScalerProd' then
     begin
          prompt := 'Multiply ' + Op1 + ' by a value?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               CurrentGrid := 1;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 4;
               GetFile(Self);
               ScalxScalMnuClick(Self);
          end;
     end;

     if Operation = 'ExtractVector' then
     begin
          prompt := 'Extract ' + Op2 + ' from ' + Op1 + '?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               CurrentGrid := 1;
               OpenDialog1.FileName := Op1;
               CurrentObjType := 1;
               GetFile(Self);
               ExtractColVecMnuClick(Self);
          end;
     end;

     if Operation = 'VecToDiag' then
     begin
          prompt := 'Place ' + Op1 + ' into diagonal of matrix' + Op2 +'?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then
          begin
               Op1Edit.Text := Operation;
               Op2Edit.Text := Op1;
               CurrentGrid := 1;
               OpenDialog1.FileName := Op1;
               if ExtractFileExt(Op1) = '.CVE' then
                  CurrentObjType := 2
               else if ExtractFileExt(Op1) = '.RVE' then
                  CurrentObjType := 3
               else exit;
               GetFile(Self);
               Op3Edit.Text := Op2;
               CurrentGrid := 2;
               OpenDialog1.FileName := Op2;
               CurrentObjType := 1;
               GetFile(Self);
               Vec2DiagMnuClick(Self);
          end;
     end;

     if Operation = 'IDMAT' then
     begin
          prompt := 'Create an Identity Matrix?';
          response := InputBox('EXECUTE?',prompt,'Y');
          if response = 'Y' then IdentMnuClick(Self);
     end;

     Operation := '';
end;

initialization
  {$I matmanunit.lrs}

end.

