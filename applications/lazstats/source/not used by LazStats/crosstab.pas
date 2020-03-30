unit CrossTab;

{$MODE Delphi}

interface

uses
  LCLIntf, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, GLOBALS, OUTPUTUNIT, OS3MainUnit, DATAPROCS, FUNCTIONSLIB,
  MATRIXLIB, LResources;

type
  TCrossTabFrm = class(TForm)
    Label1: TLabel;
    VarList: TListBox;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    Label2: TLabel;
    ListBox1: TListBox;
    ResetBtn: TButton;
    CancelBtn: TButton;
    OKBtn: TButton;
    Memo1: TMemo;
    procedure ResetBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
  private
    { Private declarations }
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

    procedure INITIALIZE(Sender: TObject);
    procedure GET_Levels(Sender: TObject);
    function INDEX_POSITION( x : IntDyneVec; Sender: TObject ) : integer;
    Procedure TABULATE(Sender : TObject);
    procedure BREAKDOWN(Sender : TObject);

  public
    { Public declarations }
  end;

var
  CrossTabFrm: TCrossTabFrm;

implementation


procedure TCrossTabFrm.ResetBtnClick(Sender: TObject);
var
   i : integer;

begin
     VarList.Clear;
     ListBox1.Clear;
     OutBtn.Enabled := false;
     InBtn.Enabled := true;
     NV := NoVariables;
     NC := NoCases;
     for i := 1 to NV do
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;
//----------------------------------------------------------------------

procedure TCrossTabFrm.FormShow(Sender: TObject);
begin
     ResetBtnClick(self);
end;
//----------------------------------------------------------------------

procedure TCrossTabFrm.CancelBtnClick(Sender: TObject);
begin
     CrossTabFrm.Hide;
end;
//----------------------------------------------------------------------

procedure TCrossTabFrm.OKBtnClick(Sender: TObject);
label CleanUp;
var
   cellvalue : string;
   i, j : integer;
   outline : string;
begin
     SetLength(var_list,NV);
     SetLength(min_value,NV);
     SetLength(max_value,NV);
     SetLength(levels,NC);
     SetLength(displace,NC);
     SetLength(subscript,NC);
     SetLength(ColNoSelected,NV);

     OutPutFrm.RichEdit.Clear;
//     OutPutFrm.RichEdit.ParaGraph.Alignment := taLeftJustify;
     OutPutFrm.RichEdit.Lines.Add('CROSSTAB RESULTS');
     OutPutFrm.RichEdit.Lines.Add('');
     outline :=  '       Analyzed data is from file : ';
     outline := outline + OS3MainFrm.FileNameEdit.Text;
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('');
     INITIALIZE(self);
     if ListBox1.Items.Count = 0 then
     begin
          ShowMessage('ERROR! No variables selected for analysis.');
          goto CleanUp;
     end;

     NoSelected := 0;
     for i := 0 to ListBox1.Items.Count-1 do
     begin
          for j := 1 to NV do
          begin
               cellvalue := OS3MainFrm.DataGrid.Cells[j,0];
               if cellvalue = ListBox1.Items.Strings[i] then
               begin
                    var_list[i] := j;
                    ColNoSelected[i] := j;
                    NoSelected := NoSelected + 1;
                    break;
               end;
          end;
     end;
     no_in_list := ListBox1.Items.Count;
     GET_LEVELS(self);
     TABULATE(self);
     BREAKDOWN(self);
     OutPutFrm.RichEdit.Lines.Add('');
     cellvalue := format('Grand sum accross all categories = %3d',[grandsum]);
     OutPutFrm.RichEdit.Lines.Add(cellvalue);
     OutPutFrm.ShowModal;

CleanUp:
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
     CrossTabFrm.Hide;
end;
//---------------------------------------------------------------------

procedure TCrossTabFrm.InBtnClick(Sender: TObject);
var
   index, i : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            ListBox1.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     OutBtn.Enabled := true;
end;
//-----------------------------------------------------------------------

procedure TCrossTabFrm.OutBtnClick(Sender: TObject);
var
   index: integer;
begin
   index := ListBox1.ItemIndex;
   VarList.Items.Add(ListBox1.Items.Strings[index]);
   ListBox1.Items.Delete(index);
   InBtn.Enabled := true;
   if ListBox1.Items.Count = 0 then OutBtn.Enabled := false;
end;
//-----------------------------------------------------------------------

procedure TCrossTabFrm.INITIALIZE(Sender: TObject);
var
   i : integer;

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
//-----------------------------------------------------------------------

procedure TCrossTabFrm.GET_Levels(Sender: TObject);
var
   i, j, k : integer;
   value : double;
   outline : string;

begin
     for i := 1 to no_in_list do
     begin
          j := var_list[i-1];
          if Not GoodRecord(1,NoSelected,ColNoSelected) then continue;
          value := StrToFloat(OS3MainFrm.DataGrid.Cells[j,1]);
          min_value[i-1] := round(value);
          max_value[i-1] := round(value);
          for k := 2 to NC do
          begin
               if Not GoodRecord(k,NoSelected,ColNoSelected) then continue;
               value := StrToFloat(OS3MainFrm.DataGrid.Cells[j,k]);
               if value < min_value[i-1] then min_value[i-1] :=
                    round(value);
               if value > max_value[i-1] then max_value[i-1] :=
                    round(value);
          end;
     end;
     for i := 1 to no_in_list do
     begin
          j := var_list[i-1];
          levels[i-1] := max_value[i-1] - min_value[i-1] + 1;
          outline := format('%s min.=%3d, max.=%3d, no. levels = %3d',
             [OS3MainFrm.DataGrid.Cells[j,0],min_value[i-1],max_value[i-1],levels[i-1]]);
          OutPutFrm.RichEdit.Lines.Add(outline);
     end;
     OutPutFrm.RichEdit.Lines.Add('');
     displace[no_in_list-1] := 1;
     if no_in_list > 1 then
     begin
     for i := (no_in_list - 1) downto 1 do
              displace[i-1] := levels[i] * displace[i];
     end;
end;
//-----------------------------------------------------------------------
function TCrossTabFrm.INDEX_POSITION( x : IntDyneVec; Sender: TObject ) : integer;

var index : integer;
    i : integer;

begin
     index := x[no_in_list-1];
     if no_in_list > 1 then
     begin
        for i := 1 to no_in_list - 1 do
             index := index + (x[i-1] -1) * displace[i-1];
     end;
     index_position := index;
end;  { function INDEX_POSITION }
//------------------------------------------------------------------------
Procedure TCrossTabFrm.TABULATE(Sender : TObject);
var
   i, j, k : integer;
   value : double;
   x : integer;
begin
     length_array := 1;
     for i := 1 to no_in_list do length_array := length_array * levels[i-1];
     SetLength(freq,length_array+1);
     for i := 0 to length_array do freq[i] := 0;
     for i := 1 to NC do
     begin
          if IsFiltered(i) then continue;
          for j := 1 to no_in_list do
          begin
               if Not GoodRecord(i,NoSelected,ColNoSelected) then continue;
               k := var_list[j-1];
               value := StrToFloat(OS3MainFrm.DataGrid.Cells[k,i]);
               x := round(value);
               x := x - min_value[j-1] + 1;
               subscript[j-1] := x;
          end;
          j := index_position(subscript,self);

          if (j < 1) or (j > length_array) then
          begin
               ShowMessage('ERROR! subscript out of range.');
               continue;
          end
          else  freq[j] := freq[j] + 1;
     end;
end; { procedure TABULATE }
//---------------------------------------------------------------------
procedure TCrossTabFrm.BREAKDOWN(Sender : TObject);

label 1,2,3,4, printgrid;
var
   i, j, row, col, bigmax : integer;
   outline : string;
   value : string;
   title : String;
begin
     bigmax := -1;
     for i := 0 to no_in_list-1 do
         if Levels[i] > bigmax then bigmax := Levels[i];
     SetLength(colLabels,bigmax);
     SetLength(outgrid,length_array,bigmax);
     SetLength(rowlabels,length_array);
     outline := OS3MainFrm.DataGrid.Cells[var_list[no_in_list-1],0];
     for col := 1 to Levels[no_in_list-1] do
         collabels[col-1] := outline + format(':%3d',[min_value[no_in_list-1] + col - 1]);
     for row := 1 to length_array do rowlabels[row-1] := '';
     ptr1 := no_in_list - 1;
     ptr2 := no_in_list;
     for i := 1 to no_in_list do subscript[i-1] := 1;
     OutPutFrm.RichEdit.Lines.Add('FREQUENCIES BY LEVEL:');
     sum := 0;
     col := 1;
     row := 1;
 1:  index := index_position(subscript,self);
     outline := 'For cell levels: ';
     for i := 1 to no_in_list do
     begin
          j := var_list[i-1];
          value := format('%s:%3d  ',[OS3MainFrm.DataGrid.Cells[j,0],
                   min_value[i-1] + subscript[i-1] - 1]);
          outline := outline + value;
     end;
     sum := sum + freq[index];
     outgrid[row-1,col-1] := freq[index];
     outline := outline + format(' Frequency = %3d',[freq[index]]);
     OutPutFrm.RichEdit.Lines.Add(outline);
     subscript[ptr2-1] := subscript[ptr2-1] + 1;
     col := col + 1;
     IF subscript[ptr2-1] <= levels[ptr2-1] then goto 1;
     outline := format('Sum accross levels = %3d',[sum]);
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('');
     grandsum := grandsum + sum;
     sum := 0;
     row := row + 1;
 2:  if ptr1 < 1 then goto printgrid;
     subscript[ptr1-1] := subscript[ptr1-1] + 1;
     if subscript[ptr1-1] <= levels[ptr1-1] then  goto 4;
 3:  ptr1 := ptr1 - 1;
     if ptr1 < 1 then goto printgrid;
     if subscript[ptr1-1] >= levels[ptr1-1] then goto 3;
     subscript[ptr1-1] := subscript[ptr1-1] + 1;
 4:  for i := ptr1 + 1 to no_in_list do subscript[i-1] := 1;
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
     MAT_PRINT(outgrid,row-1,Levels[no_in_list-1],title,rowlabels,collabels,NC);

end; { Procedure BREAKDOWN }
//---------------------------------------------------------------------


initialization
  {$i CROSSTAB.lrs}
  {$i CROSSTAB.lrs}

end.
