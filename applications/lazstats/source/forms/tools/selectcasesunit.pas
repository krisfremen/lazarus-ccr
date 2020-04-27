unit SelectCasesUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  MainUnit, OutputUnit, Globals, DataProcs,
  DictionaryUnit, SelectIfUnit, RandomSampUnit, RangeSelectUnit;

type

  { TSelectFrm }

  TSelectFrm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    FiltVarEdit: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    AllCasesBtn: TRadioButton;
    IfCondBtn: TRadioButton;
    FilterBtn: TRadioButton;
    Label2: TLabel;
    FilterOutBtn: TRadioButton;
    DeleteBtn: TRadioButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ExpListBox: TListBox;
    JoinList: TListBox;
    NotList: TListBox;
    OpsList: TListBox;
    RandomBtn: TRadioButton;
    RangeBtn: TRadioButton;
    VarList: TListBox;
    procedure AllCasesBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FilterBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IfCondBtnClick(Sender: TObject);
    procedure RandomBtnClick(Sender: TObject);
    procedure RangeBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    selectstr: string;
  public
    { public declarations }
  end; 

var
  SelectFrm: TSelectFrm;

implementation

uses
  Math;

{ TSelectFrm }

procedure TSelectFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     NOTList.Clear;
     ExpListBox.Clear;
     JoinList.Clear;
     OpsList.Clear;
     AllCasesBtn.Checked := true;
     FilterOutBtn.Checked := true;
     FiltVarEdit.Text := '';
     AllCasesBtn.Checked := true;
     IfCondBtn.Checked := false;
     RandomBtn.Checked := false;
     RangeBtn.Checked := false;
     FilterBtn.Checked := false;
     FilterOutBtn.Checked := true;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TSelectFrm.FormActivate(Sender: TObject);
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

  FAutoSized := True;
end;

procedure TSelectFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryfrm, DictionaryFrm);
  if SelectIFFrm = nil then
    Application.CreateForm(TSelectIfFrm, SelectIfFrm);
  if RandomSampFrm = nil then
    Application.CreateForm(TRandomSampFrm, RandomSampFrm);
  if RangeSelectFrm = nil then
    Application.CreateForm(TRangeSelectFrm, RangeSelectFrm);
end;

procedure TSelectFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TSelectFrm.IfCondBtnClick(Sender: TObject);
begin
  if SelectIfFrm.ShowModal = mrCancel then
    exit;
  SelectStr := SelectIfFrm.IFString;
end;

procedure TSelectFrm.RandomBtnClick(Sender: TObject);
begin
  if RandomSampFrm.ShowModal = mrCancel then exit;
end;

procedure TSelectFrm.RangeBtnClick(Sender: TObject);
begin
  if RangeSelectFrm.ShowModal = mrCancel then
    exit;
end;

procedure TSelectFrm.AllCasesBtnClick(Sender: TObject);
begin
  FilterOutBtn.Checked := false;
  DeleteBtn.Checked := false;
end;

procedure TSelectFrm.ComputeBtnClick(Sender: TObject);
var
   cellstring, outline, FirstCase, LastCase, filtvar : string;
   FilterVar : boolean;
   FilterDel : boolean;
   IfFilter : boolean;
   RandomFilter : boolean;
   RangeFilter : boolean;
   AllCases : boolean;
   testresult, Truth : boolean;
   TValue : array[1..20] of boolean;
   i, j, filtcol, firstrow, lastrow, norndm, caserow, cases : integer;
   NoExpr, delrow : integer;
   pcntrndm : double;
   Expression : string;  // main select if string
   leftstr, rightstr, opstr : string;
   ExpList, LeftValue, RightValue, JoinOps, Ops, VarLabels : StrDyneVec;
begin
   FilterVar := false; // true if a filter variable is selected to use
   FilterDel := false; // true if deleting non-selected cases
   IfFilter := false; // true if a select if option is used
   FilterOn := false; // set to no filtering
   RandomFilter := false; // true if random selected cases is used
   RangeFilter := false; // true if a range of cases are selected
   AllCases := true; // default when selecting all cases
   outline := '';
   filtcol := 0;
   lastrow := 0;
   if FilterCol > 0 then filtcol := FilterCol;

   if AllCasesBtn.Checked then
   begin
        FilterOn := false;
        OS3MainFrm.FilterEdit.Text := 'OFF';
        exit;
   end;

   if FilterBtn.Checked then // use filter variable
   begin
        cellstring := FiltVarEdit.Text;
        FilterVar := true;
        AllCases := false;
        FilterOn := true; // global value
        OS3MainFrm.FilterEdit.Text := 'ON';
        FilterDel := false;
        if DeleteBtn.Checked then FilterDel := true;
   end;

   if IfCondBtn.Checked then
   begin
        IfFilter := true;
//        FilterOn := true;
        OS3MainFrm.FilterEdit.Text := 'ON';
        AllCases := false;
        if DeleteBtn.Checked then FilterDel := true
        else FilterDel := false;
   end;

   if RandomBtn.Checked then
   begin
        RandomFilter := true;
        AllCases := false;
        FilterOn := true;
        OS3MainFrm.FilterEdit.Text := 'ON';
        if DeleteBtn.Checked then FilterDel := true else FilterDel := false;
   end;

   if RangeBtn.Checked then
   begin
        RangeFilter := true;
        FilterOn := true;
        OS3MainFrm.FilterEdit.Text := 'ON';
        AllCases := false;
        if DeleteBtn.Checked then FilterDel := true else FilterDel := false;
   end;

   if FilterOutBtn.Checked then
   begin
//        FilterOn := true;
        OS3MainFrm.FilterEdit.Text := 'ON';
   end;

   if Not FilterOn and AllCases then exit // no current filtering
   else
   begin
        if (RangeFilter) or (RandomFilter) or (IfFilter) then
        begin
             if filtcol = 0 then
             begin
                  // create a filter variable and select cases
                  filtcol := NoVariables + 1;
                  outline := format('Filter%d',[NoVariables]);
                  OS3MainFrm.DataGrid.ColCount := OS3MainFrm.DataGrid.ColCount + 1;
                  OS3MainFrm.DataGrid.Cells[filtcol,0] := outline;
                  // update the dictionary
                  DictionaryFrm.DictGrid.RowCount := filtcol + 1;
                  DictionaryFrm.DictGrid.Cells[0,filtcol] := IntToStr(filtcol);
                  DictionaryFrm.DictGrid.Cells[2,filtcol] := 'Filter';
                  DictionaryFrm.DictGrid.Cells[3,filtcol] := '3';
                  DictionaryFrm.DictGrid.Cells[4,filtcol] := 'S';
                  DictionaryFrm.DictGrid.Cells[5,filtcol] := '0';
                  DictionaryFrm.DictGrid.Cells[6,filtcol] := ' ';
                  DictionaryFrm.DictGrid.Cells[7,filtcol] := 'L';
                  varDefined[filtcol] := true;
                  OS3MainFrm.NoVarsEdit.Text := IntToStr(filtcol);
                  NoVariables := filtcol;
             end;
        end;

        // select cases using the method selected
        if RangeFilter then
        begin
             FirstCase := Trim(RangeSelectFrm.FirstCaseEdit.Text);
             LastCase := Trim(RangeSelectFrm.LastCaseEdit.Text);
             outline := 'RangeFilter';
             OS3MainFrm.DataGrid.Cells[filtcol,0] := outline;
             DictionaryFrm.DictGrid.Cells[1,filtcol] := outline;
             // find first case
             firstrow := NoCases;
             for i := 1 to NoCases do
             begin
                  if FirstCase = Trim(OS3MainFrm.DataGrid.Cells[0,i]) then // matched!
                  begin
                       OS3MainFrm.DataGrid.Cells[filtcol,i] := 'YES';
                       firstrow := i;
                       break;
                  end
                  else OS3MainFrm.DataGrid.Cells[filtcol,i] := 'NO';
             end;
             for i := firstrow + 1 to NoCases do
             begin
                  if LastCase = Trim(OS3MainFrm.DataGrid.Cells[0,i]) then //matched
                  begin
                       OS3MainFrm.DataGrid.Cells[filtcol,i] := 'YES';
                       lastrow := i;
                       break;
                  end
                  else OS3MainFrm.DataGrid.Cells[filtcol,i] := 'YES';
             end;
             for i := lastrow + 1 to NoCases do
                 OS3MainFrm.DataGrid.Cells[filtcol,i] := 'NO';
        end; // end if range filtering

        if RandomFilter then
        begin
             outline := 'RandomFilter';
             OS3MainFrm.DataGrid.Cells[filtcol,0] := outline;
             DictionaryFrm.DictGrid.Cells[1,filtcol] := outline;
             Randomize;
             if RandomSampFrm.ApproxBtn.Checked then
             begin
                  pcntrndm := StrToFloat(RandomSampFrm.PcntEdit.Text);
                  norndm := round((pcntrndm / 100.0) * NoCases);
                  i := norndm;
                  while i > 0 do
                  begin
                       caserow := random(NoCases-1) + 1;
                       if OS3MainFrm.DataGrid.Cells[filtcol,caserow] <> 'YES' then
                       begin
                          OS3MainFrm.DataGrid.Cells[filtcol,caserow] := 'YES';
                          i := i - 1;
                       end;
                  end;
             end
             else // exact no from first N cases
             begin
                  norndm := StrToInt(RandomSampFrm.ExactEdit.Text);
                  cases := StrToInt(RandomSampFrm.CasesEdit.Text);
                  i := norndm;
                  while i > 0 do
                  begin
                       caserow := random(cases-1) + 1;
                       if OS3MainFrm.DataGrid.Cells[filtcol,caserow] <> 'YES' then
                       begin
                            OS3MainFrm.DataGrid.Cells[filtcol,caserow] := 'YES';
                            i := i - 1;
                       end;
                  end;
             end;
             // put No in all without a Yes
             for i := 1 to NoCases do
                 if OS3MainFrm.DataGrid.Cells[filtcol,i] <> 'YES' then
                    OS3MainFrm.DataGrid.Cells[filtcol,i] := 'NO';
        end; // end if random filtering

        if FilterVar then // use an existing filter variable
        begin
             filtvar := Trim(FiltVarEdit.Text);
             // find column of the variable
             filtcol := 0;
             for i := 1 to NoVariables do
             begin
                  cellstring := Trim(OS3MainFrm.DataGrid.Cells[i,0]);
                  if cellstring = filtvar then
                  begin
                       filtcol := i;
                       break;
                  end;
             end;
             FilterCol := filtcol;
             if filtcol = 0 then
             begin
                  FilterOn := false; // bad filter column
                  OS3MainFrm.FilterEdit.Text := 'OFF';
             end;
        end; // end if filter variable

        if IfFilter then // user chose the select if button
        begin
             SetLength(ExpList, 20);
             SetLength(LeftValue, 20);
             SetLength(RightValue, 20);
             SetLength(JoinOps, 20);
             SetLength(Ops, 20);
             SetLength(VarLabels, NoVariables);
             for i := 0 to 19 do
             begin
                  ExpList[i] := '';
                  LeftValue[i] := '';
                  RightValue[i] := '';
                  JoinOps[i] := '';
                  Ops[i] := '';
             end;
             for i := 0 to NoVariables-1 do
                 VarLabels[i] := OS3MainFrm.DataGrid.Cells[i+1,0];
             outline := 'IfFilter';
             OS3MainFrm.DataGrid.Cells[filtcol,0] := outline;
             DictionaryFrm.DictGrid.Cells[1,filtcol] := outline;
             Expression := SelectIfFrm.ifstring;
             SelectIfFrm.parse(Expression,ExpList,NoExpr,Ops,LeftValue,RightValue,JoinOps);
             // Now, for each sub-expression, check left and right values for
             // matches to a variable or numeric value and apply the operation
             // to each record in the grid.
             for i := 0 to NoExpr-1 do
             begin
                  ExpListBox.Items.Add(Ops[i]);
                  NOTList.Items.Add(LeftValue[i]);
                  JoinList.Items.Add(RightValue[i]);
                  OpsList.Items.Add(JoinOps[i]);
             end;

             for i := 1 to NoCases do
             begin
                  Truth := false;
                  TestResult := false;
                  for j := 0 to NoExpr-1 do
                  begin
                       leftstr := LeftValue[j];
                       rightstr := RightValue[j];
                       opstr := Ops[j];
                       TValue[j+1] := SelectIfFrm.TruthValue(i,j,leftstr,rightstr,
                            opstr, VarLabels, NoVariables);
                  end;

                  // now evalute the truth table using joing operations
                  if NoExpr > 0 then
                  begin
                       Truth := false;
                       for j := 0 to NoExpr-1 do
                       begin
                            if JoinOps[j] = '&' then
                            begin
                                 if TValue[j+1] and TValue[j+2] then
                                         TestResult := true;
                            end;
                            if JoinOps[j] = '|' then
                            begin
                                 if TValue[j+1] or TValue[j+2] then
                                         TestResult := true;
                            end;
                            if JoinOps[j] = '!' then
                            begin
                                if TValue[j+1] <> TValue[j+2] then
                                        TestResult := true;
                            end;
                            if (JoinOps[j] = '') and
                             (NoExpr = 1) then // no join operation
                            begin
                                 if TValue[j+1] then TestResult := true;
                            end;
                            Truth := TestResult;
                       end; // next jth expression
                  end; // last jth expression if NoExpr > 0

                  if Truth then OS3MainFrm.DataGrid.Cells[filtcol,i] := 'YES'
                            else OS3MainFrm.DataGrid.Cells[filtcol,i] := 'NO';
             end; // next case

             VarLabels := nil;
             Ops := nil;
             JoinOps := nil;
             RightValue := nil;
             LeftValue := nil;
             ExpList := nil;
             FilterCol := filtcol;
             FilterOn := true;
        end; // select if filtering

        // should we delete the 'NO' cases ?
        if FilterDel then
        begin
             delrow := 1;
             while delrow < OS3MainFrm.DataGrid.RowCount do
             begin
                  if OS3MainFrm.DataGrid.Cells[filtcol,delrow] = 'NO' then
                  begin
                       OS3MainFrm.DataGrid.Row := delrow;
                       CutRow;
                  end
                  else delrow := delrow + 1;
             end;
        end;
   end; // else filtering
//   SelectFrm.Hide;
end;

procedure TSelectFrm.FilterBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     index := VarList.ItemIndex;
     if index >= 0 then FiltVarEdit.Text := VarList.Items.Strings[index];
     if FiltVarEdit.Text = '' then
     begin
        ShowMessage('ERROR! First, click the name of a filter variable');
        exit;
     end;
     FilterOn := true;
     for i := 1 to NoVariables do
       if OS3MainFrm.DataGrid.Cells[i,0] = FiltVarEdit.Text then FilterCol := i;
end;


initialization
  {$I selectcasesunit.lrs}

end.

