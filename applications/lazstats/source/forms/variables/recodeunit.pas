unit RecodeUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  MainUnit, Globals, DataProcs, DictionaryUnit;


type

  { TRecodeFrm }

  TRecodeFrm = class(TForm)
    AllButEdit: TEdit;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    ReturnBtn: TButton;
    HiDownToEdit: TEdit;
    LowToEdit: TEdit;
    RangeToEdit: TEdit;
    Label2: TLabel;
    RangeFromEdit: TEdit;
    OldValEdit: TEdit;
    GroupBox2: TGroupBox;
    NewValEdit: TEdit;
    GroupBox1: TGroupBox;
    OldValBtn: TRadioButton;
    OldBlnkBtn: TRadioButton;
    RangeBtn: TRadioButton;
    LowToBtn: TRadioButton;
    DownToBtn: TRadioButton;
    AllButBtn: TRadioButton;
    ValueBtn: TRadioButton;
    BlankBtn: TRadioButton;
    TargetList: TRadioGroup;
    varnameedit: TEdit;
    Label1: TLabel;
    procedure ApplyBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    oldcol : integer;
    newplace : boolean;
    newcol :integer;
  public
    { public declarations }
  end; 

var
  RecodeFrm: TRecodeFrm;

implementation

{ TRecodeFrm }

procedure TRecodeFrm.ResetBtnClick(Sender: TObject);
begin
     varnameEdit.Text := '';
     NewValEdit.Text := '';
     OldValEdit.Text := '';
     RangeFromEdit.Text := '';
     RangeToEdit.Text := '';
     LowToEdit.Text := '';
     HiDownToEdit.Text := '';
     AllButEdit.Text := '';
     TargetList.ItemIndex := 0;
     ValueBtn.Checked := true;
     OldValBtn.Checked := true;
     oldcol := OS3MainFrm.DataGrid.Col;
     varnameEdit.Text := OS3MainFrm.DataGrid.Cells[oldcol,0];
     newplace := false;
end;

procedure TRecodeFrm.FormShow(Sender: TObject);
begin
     ResetBtnClick(self);
end;

procedure TRecodeFrm.ApplyBtnClick(Sender: TObject);
label gohere;
var
   i, oldchoice, typedata, comparison : integer;
   cellstring, oldvalue, newvalue, lowrange, hirange, upto : string;
   hidown, allbut : string;
   dblX1, dblX2, dblold : double;

begin
     oldchoice := 0;
     if newplace = true then
     begin
          oldcol := newcol;
          goto gohere;
     end;

     // get target of where the recode will be placed
     if TargetList.ItemIndex = 0 then
     begin
          newcol := oldcol;
          newplace := false;
     end
     else begin
          newplace := true;
          DictionaryFrm.NewVar(NoVariables+1);
          newcol := NoVariables;
          cellstring := 'New' + OS3MainFrm.DataGrid.Cells[oldcol,0];
          OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
          DictionaryFrm.DictGrid.Cells[1,newcol] := cellstring;
          OS3MainFrm.DataGrid.Cells[newcol,0] := cellstring;
          for i := 2 to 7 do
               DictionaryFrm.DictGrid.Cells[i,newcol] := DictionaryFrm.DictGrid.Cells[i,oldcol];
     end;
gohere:
     // get value to recode to
     if ValueBtn.Checked then newvalue := NewValEdit.Text
     else newvalue := '';

     // get type of value and value to be recoded
     if OldValBtn.Checked then
     begin
          oldvalue := Trim(OldValEdit.Text);
          oldchoice := 1;
     end;
     if OldBlnkBtn.Checked then
     begin
          oldvalue := '';
          oldchoice := 2;
     end;
     if RangeBtn.Checked then
     begin
          lowrange := Trim(RangeFromEdit.Text);
          hirange := Trim(RangeToEdit.Text);
          oldchoice := 3;
     end;
     if LowToBtn.Checked then
     begin
          upto := Trim(LowToEdit.Text);
          oldchoice := 4;
     end;
     if DownToBtn.Checked then
     begin
          hidown := Trim(HiDownToEdit.Text);
          oldchoice := 5;
     end;
     if AllButBtn.Checked then
     begin
          allbut := Trim(AllButEdit.Text);
          oldchoice := 6;
     end;

     // Now, do the recoding
     for i := 1 to NoCases do
     begin
          if not ValidValue(i,oldcol) then continue;
          cellstring := Trim(OS3MainFrm.DataGrid.Cells[oldcol,i]);
          // check for a string value.  If true set datatype to string
          if IsNumeric(cellstring) = false then typedata := 1
          else typedata := 0; // type is string if 1 else numeric
          OS3MainFrm.DataGrid.Cells[newcol,i] := cellstring;
          case oldchoice of
               1 : if cellstring = oldvalue then
                      OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
               2 : if cellstring = '' then
                      OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
               3 : begin
                        if typedata = 0 then // numeric
                        begin
                             dblX1 := StrToFloat(lowrange);
                             dblX2 := StrToFloat(hirange);
                             dblold := StrToFloat(cellstring);
                             if (dblold >= dblX1) and (dblold <= dblX2) then
                                OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
                        end
                        else begin // string compare
                             comparison := CompareStr(cellstring,lowrange);
                             if comparison >= 0 then
                             begin
                                  comparison := CompareStr(hirange,cellstring);
                                  if comparison <= 0 then
                                     OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
                             end;
                        end;
                   end;
               4 : begin
                        if typedata = 0 then // numeric
                        begin
                             dblX1 := StrToFloat(upto);
                             dblold := StrToFloat(cellstring);
                             if (dblold <= dblX1)  then
                                OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
                        end
                        else begin // string compare
                             if length(upto) = length(cellstring) then
                             begin
                                  comparison := CompareStr(cellstring,upto);
                                  if comparison <= 0 then
                                     OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
                             end;
                        end;
                   end;
               5 : begin
                        if typedata = 0 then // numeric
                        begin
                             dblX1 := StrToFloat(hidown);
                             dblold := StrToFloat(cellstring);
                             if (dblold >= dblX1)  then
                                OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
                        end
                        else begin // string compare
                             if length(hidown) = length(cellstring) then
                             begin
                                  comparison := CompareStr(cellstring,hidown);
                                  if comparison >= 0 then
                                     OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
                             end;
                        end;
                   end;
               6 : begin
                        if typedata = 0 then // numeric
                        begin
                             dblX1 := StrToFloat(allbut);
                             dblold := StrToFloat(cellstring);
                             if (dblold <> dblX1)  then
                                OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
                        end
                        else begin // string compare
                             if length(allbut) = length(cellstring) then
                             begin
                                  comparison := CompareStr(cellstring,allbut);
                                  if comparison <> 0 then
                                     OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
                             end
                             else OS3MainFrm.DataGrid.Cells[newcol,i] := newvalue;
                        end;
                   end;
          end; // end case
          FormatCell(newcol,i);
     end;
end;

procedure TRecodeFrm.FormActivate(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MaxWidth := Width;
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;
end;

procedure TRecodeFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

initialization
  {$I recodeunit.lrs}

end.

