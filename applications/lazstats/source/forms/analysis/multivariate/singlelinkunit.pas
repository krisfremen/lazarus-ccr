unit SingleLinkUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, OutputUnit;

type

  { TSingleLinkFrm }

  TSingleLinkFrm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    StdChkBox: TCheckBox;
    RepChkBox: TCheckBox;
    DescChkBox: TCheckBox;
    PlotChkBox: TCheckBox;
    DendoChk: TCheckBox;
    GroupBox1: TGroupBox;
    VarSelEdit: TEdit;
    Label2: TLabel;
    VarInBtn: TBitBtn;
    VarOutBtn: TBitBtn;
    Label1: TLabel;
    ListBox1: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarInBtnClick(Sender: TObject);
    procedure VarOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure TreePlot(VAR Clusters : IntDyneMat;
                                  VAR Lst : IntDyneVec;
                                  NoPoints : integer);
    procedure scatplot(var x : DblDyneVec;
                   var y : DblDyneVec;
                   nocases : integer;
                   titlestr : string;
                   x_axis, y_axis : string;
                   x_min, x_max, y_min, y_max : double;
                   VAR VarLabels : StrDyneVec);

  public
    { public declarations }
  end; 

var
  SingleLinkFrm: TSingleLinkFrm;

implementation

uses
  Math;

{ TSingleLinkFrm }

procedure TSingleLinkFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
    cellstring : string;
begin
     ListBox1.Clear;
     VarSelEdit.Text := '';
     for i := 1 to NoVariables do
     begin
         cellstring := OS3MainFrm.DataGrid.Cells[i,0];
         ListBox1.Items.Add(cellstring);
     end;
     RepChkBox.Checked := false;
     StdChkBox.Checked := false;
     VarOutBtn.Enabled := false;
     DescChkBox.Checked := false;
     PlotChkBox.Checked := false;
end;

procedure TSingleLinkFrm.VarInBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := ListBox1.ItemIndex;
     VarSelEdit.Text := ListBox1.Items.Strings[index];
     VarOutBtn.Enabled := true;
end;

procedure TSingleLinkFrm.VarOutBtnClick(Sender: TObject);
begin
     ListBox1.Items.Add(VarSelEdit.Text);
     VarSelEdit.Text := '';
end;

procedure TSingleLinkFrm.FormActivate(Sender: TObject);
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

  FAutoSized := true;
end;

procedure TSingleLinkFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TSingleLinkFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TSingleLinkFrm.ComputeBtnClick(Sender: TObject);
VAR
     NoInGrp : IntDyneVec;       // no. of subjects in a grouping
     i, j, NoGroups, ID, ID1, ID2, col, startat, endat : integer;
     ColSelected : integer;
     NoScores : integer;
     varlabel : string;
//     outline : array[1..501] of char;
//     astring : array[0..5] of char;
     outline : string;
     astring : string;
     Scores : DblDyneVec;      // subject scores
     Distance : DblDyneMat;  // distance between objects
     SubjectIDs : IntDyneVec;    // subject ids - sorted with Distance
     X1: double;      // grid values of two subjects
     Groups : IntDyneMat;       // subjects in each group
     GrpErrors : DblDyneVec;
     Smallest, Mean, Variance, StdDev : double;
     clusters : IntDyneMat;
     Lst : IntDyneVec;
     done : boolean;
     average : double;
     XAxis, YAxis : DblDyneVec;
     MaxError : double;
     GrpLabels : StrDyneVec;

label labels1, labels2;

begin
     NoScores := NoCases;
     Mean := 0.0;
     Variance := 0.0;
     varlabel := VarSelEdit.Text;

     //Get selected variable
     ColSelected := 0;
     for j := 1 to NoVariables do
         if (VarSelEdit.Text = OS3MainFrm.DataGrid.Cells[j,0]) then ColSelected := j;
     if (ColSelected = 0) then
     begin
        ShowMessage('ERROR!  No variable selected to analyze.');
        exit;
     end;

     // Allocate memory
     SetLength(Distance,NoCases+1,NoCases+1);
     SetLength(SubjectIDs,NoCases+1);
     SetLength(NoInGrp,NoCases+1);
     SetLength(Groups,NoCases+1,NoCases+1);
     SetLength(Scores,NoCases+1);
     SetLength(GrpErrors,NoCases+1);
     SetLength(clusters,NoCases+1,3);
     SetLength(Lst,NoCases+1);

     // initialize arrays
     for i := 0 to NoCases-1 do
     begin
         NoInGrp[i] := 1;
         SubjectIDs[i] := i+1;
         for j := 0 to NoCases-1 do
         begin
             Groups[i,j] := 0;
             Distance[i,j] := 0.0;
         end;
         for j := 0 to 2 do clusters[i,j] := 0;
     end;
     NoGroups := 0;

     // Get data into the distance matrix
     for i := 0 to NoCases - 1 do
     begin
         col := ColSelected;
         Scores[i] := StrToFloat(OS3MainFrm.DataGrid.Cells[col,i+1]);
         Mean := Mean + Scores[i];
         Variance := Variance + (Scores[i] * Scores[i]);
     end;
     Variance := Variance - ((Mean * Mean) / NoCases);
     Variance := Variance / (NoCases - 1);
     StdDev := sqrt(Variance);
     Mean := Mean / NoCases;

     // sort the scores and ids in distance and subjed ids
     for i := 0 to NoCases - 2 do
     begin
         for j := i+1 to NoCases - 1 do
         begin
             if (Scores[i] > Scores[j]) then // swap
             begin
                X1 := Scores[i];
                Scores[i] := Scores[j];
                Scores[j] := X1;
                ID := SubjectIDs[i];
                SubjectIDs[i] := SubjectIDs[j];
                SubjectIDs[j] := ID;
             end;
         end;
     end;
     for i := 0 to NoCases - 1 do Lst[i+1] := SubjectIDs[i];

     // Show results
     OutputFrm.RichEdit.Lines.Add('Single Linkage Clustering by Bill Miller');
     outline := format('FILE: %s',[OS3MainFrm.FileNameEdit.Text]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('Variable := %s',[varlabel]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('Number of cases := %d',[NoCases]);
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := format('Mean := %8.3f, Variance := %8.3f, Std.Dev. := %8.3f',[Mean, Variance, StdDev]);
     OutputFrm.RichEdit.Lines.Add(outline);

    // Standardize the distance scores if elected
    if (StdChkBox.Checked) then
    begin
        for i := 0 to NoCases - 1 do Scores[i] := (Scores[i] - Mean) / StdDev;
        if (RepChkBox.Checked) then // replace original values in DataGrid with z scores if elected
        begin
            for i := 0 to NoCases - 1 do
            begin
                col := ColSelected;
                outline := format('%6.4f',[Scores[i]]);
                OS3MainFrm.DataGrid.Cells[col,i+1] := outline;
            end;
        end;
    end;

     OutputFrm.RichEdit.Lines.Add('');
     if (DescChkBox.Checked) then
     begin
           done := false;
           startat := 0;
           endat := NoScores;
           if (endat > 20) then endat := 20;
//           ptr := outline;
           while (not done) do
           begin
              outline := 'GROUP ID';
              for i := startat to endat - 1 do
              begin
                  astring := format('%4d',[SubjectIDs[i]]);
                  outline := outline + astring;
//                  strcat(@outline,@astring);
              end;
              OutputFrm.RichEdit.Lines.Add(outline);
              startat := endat;
              if (startat >= NoScores) then done := true;
              endat := startat + 20;
              if (endat > NoScores) then endat := NoScores;
           end;
     end;

     // calculate Distances and smallest Distance
labels1:
     Smallest := abs(Scores[0] - Scores[1]); // initial values
     for i := 0 to NoScores - 2 do
     begin
         for j := i+1 to NoScores - 1 do
         begin
             Distance[i,j] := abs(Scores[i] - Scores[j]);
             Distance[j,i] := Distance[i,j];
             if (Distance[i,j] <= Smallest) then
             begin
                Smallest := Distance[i,j];
                ID1 := i;
                ID2 := j;
             end;
         end;
     end;

     if (NoGroups < NoCases-1) then
     begin
         if (DescChkBox.Checked) then
         begin
            outline := format('        Group %d is combined with Group %d',
                [SubjectIDs[ID1],SubjectIDs[ID2]]);
            OutputFrm.RichEdit.Lines.Add(outline);
            OutputFrm.RichEdit.Lines.Add('');
         end;
     end;

     // eliminate second score and replace first with average
     NoInGrp[ID1] := NoInGrp[ID1] + 1;
     NoInGrp[ID2] := NoInGrp[ID2] - 1;
     clusters[NoGroups+1,1] := SubjectIDs[ID1];
     clusters[NoGroups+1,2] := SubjectIDs[ID2];

     // record results for this grouping
labels2:
     Groups[NoGroups,ID1] := 1;  // set flags for those objects grouped
     Groups[NoGroups,ID2] := 1;

     if (NoGroups < NoCases-1) then // eliminate second score and replace first with average
     begin
        average := abs(Scores[ID1] + Scores[ID2]) / 2.0;
        Scores[ID1] := average;
        for i := ID2 to NoScores - 2 do
        begin
            Scores[i] := Scores[i+1];
            SubjectIDs[i] := SubjectIDs[i+1];
        end;
        NoScores := NoScores - 1;
        for i := 0 to NoScores - 1 do Groups[NoGroups,SubjectIDs[i]] := 1;
        if (DescChkBox.Checked) then
        begin
           done := false;
           startat := 0;
           endat := NoScores;
           if (endat > 20) then endat := 20;
           while (not done) do
           begin
              outline := 'GROUP ID';
              for i := startat to endat - 1 do
              begin
                  astring := format('%4d',[SubjectIDs[i]]);
                  outline := outline + astring;
              end;
              OutputFrm.RichEdit.Lines.Add(outline);
              startat := endat;
              if (startat >= NoScores) then done := true;
              endat := startat + 20;
              if (endat > NoScores) then endat := NoScores;
           end;
        end;

        // get errors
        GrpErrors[NoGroups] := GrpErrors[NoGroups] + Distance[ID1,ID2];
        NoGroups := NoGroups + 1;
        goto labels1;
     end;

     // show errors
     if (DescChkBox.Checked) then
     begin
        OutputFrm.RichEdit.Lines.Add('');
        OutputFrm.RichEdit.Lines.Add('GROUPING STEP    ERROR');
        for i := 0 to NoGroups - 1 do
        begin
            outline := format('     %3d          %10.3f',[i+1,GrpErrors[i]]);
            OutputFrm.RichEdit.Lines.Add(outline);
        end;
     end;

     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
    if (PlotChkBox.Checked) then
    begin
       MaxError := GrpErrors[NoGroups-1];
       SetLength(XAxis,NoCases);
       SetLength(YAxis,NoCases);
       SetLength(GrpLabels,NoGroups+1);
       for i := 0 to NoGroups - 1 do
       begin
           XAxis[i] := NoGroups - i;
           YAxis[i] := GrpErrors[i];
           GrpLabels[i] := IntToStr(i + 1);
       end;
       scatplot(XAxis, YAxis, NoGroups, 'Plot of Error vs No. of Groups',
             'No. of Groups', 'Size of Error', 2.0, NoCases, 0.0, MaxError,GrpLabels);
       GrpLabels := nil;
       YAxis := nil;
       XAxis := nil;
    end;
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear;
    if (DendoChk.Checked) then
    begin
       OutputFrm.RichEdit.Clear;
       TreePlot(clusters,Lst,NoGroups+1);
       OutputFrm.ShowModal;
    end;
    OutputFrm.RichEdit.Clear;
     //clean up the memory
    Lst := nil;
    clusters := nil;
    GrpErrors := nil;
    Scores := nil;
    Groups := nil;
    NoInGrp := nil;
    SubjectIDs := nil;
    Distance := nil;
end;

procedure TSingleLinkFrm.TreePlot(VAR Clusters : IntDyneMat;
                                  VAR Lst : IntDyneVec;
                                  NoPoints : integer);
VAR
     outline : array[0..501] of char;
     aline : array[0..82] of char;
     valstr : string;
     tempstr : string;
     plotline : string;
     star : char;
     blank : char;
     col1, col2, colpos1, colpos2 : integer;
     noparts, startcol, endcol : integer;
     Results : StrDyneVec;
     ColPos : IntDyneVec;
     i, j, k, L, linecount, newcol, howlong, count: integer;
     done : boolean;
begin
     linecount := 1;
     star := '*';
     blank := ' ';
     SetLength(ColPos,NoPoints+2);
     SetLength(Results,NoPoints*2+3);
     OutputFrm.RichEdit.Lines.Add('');
     done := false;
     // store initial column positions of vertical linkages
     for i := 1 to NoPoints do ColPos[Lst[i]] := 4 + (i * 5);

     // create column heading indented 10 spaces
     tempstr := 'UNIT ';
     for i := 1 to NoPoints do
     begin
         valstr := format('%5d',[Lst[i]]);
         tempstr := tempstr + valstr;
     end;
     Results[linecount] := tempstr;
     linecount := linecount + 1;

     // create beginning of vertical linkages
     plotline := 'STEP ';
     for i := 1 to NoPoints do  plotline := plotline + '    *';
     Results[linecount] := plotline;
     linecount := linecount + 1;

     // start dendoplot
     for i := 1 to NoPoints - 1 do
     begin
         outline := '';
         valstr := format('%5d',[i]); // put step no. first
         outline := valstr;
         // clear remainder of outline
         for j := 5 to (5 + NoPoints * 5) do outline[j] := ' ';
         outline[6 + NoPoints * 5] := #0;
         col1 := Clusters[i,1];
         col2 := Clusters[i,2];
         // find column positions for each variable
         colpos1 := ColPos[col1];
         colpos2 := ColPos[col2];

         for k := colpos1 to colpos2 do outline[k] := star;
         // change column positions 1/2 way between the matched ones
         newcol := colpos1 + ((colpos2 - colpos1) div 2);
         for k := 1 to NoPoints do
            if ((ColPos[k] = colpos1) or (ColPos[k] = colpos2)) then ColPos[k] := newcol;
         for k := 1 to NoPoints do
         begin
             L := ColPos[k];
             if ((L <> colpos1) and (L <> colpos2)) then outline[L] := star;
         end;
         Results[linecount] := outline;
         linecount := linecount + 1;

         // add a line of connectors to next grouping
         outline := '     ';
         for j := 5 to (5 + NoPoints * 5) do outline[j] := blank;
         for j := 1 to NoPoints do
         begin
             colpos1 := ColPos[j];
             outline[colpos1] := star;
         end;
         Results[linecount] := outline;
         linecount := linecount + 1;
     end;

     // output the Results in parts
     // determine number of pages needed for whole plot
     noparts := 0;
     howlong := Length(Results[1]);
     noparts := round(howlong / 80.0);
     if (noparts <= 0) then noparts := 1;

     if (noparts = 1) then // simply print the list
     begin
         for i := 0 to linecount - 1 do
         begin
             OutputFrm.RichEdit.Lines.Add(Results[i]);
         end;
     end
     else // break lines into strings of 15 units
     begin
         startcol := 0;
         endcol := 80;
         for i := 1 to noparts do
         begin
             outline := format('PART %d OUTPUT',[i]);
             OutputFrm.RichEdit.Lines.Add(outline);
             for j := 0 to 80 do aline[j] := blank;

             for j := 0 to linecount - 1 do
             begin
                 count := 0;
                 outline := Results[j];
                 for k := startcol to endcol do
                 begin
                     aline[count] := outline[k];
                     count := count + 1;
                 end;
                 aline[count+1] := #0;
                 OutputFrm.RichEdit.Lines.Add(aline);
             end;
             OutputFrm.RichEdit.Lines.Add('');
             startcol := endcol + 1;
             endcol := endcol + 80;
             if (endcol > howlong) then endcol := howlong;
         end;
     end;
     Results := nil;
     ColPos := nil;
end;

procedure TSingleLinkFrm.scatplot(var x : DblDyneVec;
                   var y : DblDyneVec;
                   nocases : integer;
                   titlestr : string;
                   x_axis, y_axis : string;
                   x_min, x_max, y_min, y_max : double;
                   VAR VarLabels : StrDyneVec);

var
   i, j, l, row, xslot : integer;
   xdelta, maxy: double;
   incrementx, incrementy, rangex, rangey, swap : double;
   plotstring  : array[0..51,0..61] of char;
   ymed, xmed  : double;
   aheight      : integer;
   overlap     : boolean;
   valuestring : string[2];
   howlong     : integer;
   outline     : string;
   Labels      : StrDyneVec;
begin
     SetLength(Labels,nocases);
     for i := 1 to nocases do Labels[i-1] := VarLabels[i-1];
     aheight := 40;
     rangex := x_max - x_min ;
     incrementx := rangex / 15.0;
     xdelta := rangex / 60;
     xmed := rangex / 2;
     rangey := y_max - y_min;
     incrementy := rangey / aheight;
     ymed := rangey / 2;

     { sort in descending order }
     for i := 1 to (nocases - 1) do
     begin
          for j := (i + 1) to nocases do
          begin
               if y[i-1] < y[j-1] then
               begin
                    swap := y[i-1];
                    y[i-1] := y[j-1];
                    y[j-1] := swap;
                    swap := x[i-1];
                    x[i-1] := x[j-1];
                    x[j-1] := swap;
                    outline := Labels[i-1];
                    Labels[i-1] := Labels[j-1];
                    Labels[j-1] := outline;
               end;
          end;
     end;
     outline :=  '             SCATTERPLOT - ' + titlestr;
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add(y_axis);
     maxy := y_max;
     for i := 1 to 60 do
          for j := 1 to aheight+1 do plotstring[j,i] := ' ';

     { Set up the plot strings with the data }
     row := 0;
     while maxy >  y_min  do
     begin
          row := row + 1;
          plotstring[row,30] := '|';
          if (row = (aheight / 2)) then
          begin
               for i := 1 to 60 do plotstring[row,i] := '-';
          end;
          for i := 1 to nocases do
          begin
               if ((maxy >= y[i-1]) and (y[i-1] > (maxy - incrementy))) then
               begin
                    xslot := round(((x[i-1] - x_min) / rangex) * 60);
                    if xslot < 1 then xslot := 1;
                    if xslot > 60 then xslot := 60;
                    overlap := false;
                    str(i:2,valuestring);
                    howlong := 1;
                    if (valuestring[1] <> ' ') then howlong := 2;
                    for l := xslot to (xslot + howlong - 1) do
                      if (plotstring[row,l] = '*') then overlap := true;
                    if (overlap) then plotstring[row,xslot] := '*'
                    else
                    begin
                      if (howlong < 2) then
                        plotstring[row,xslot] := valuestring[2]
                      else for l := 1 to 2 do
                         plotstring[row,xslot + l - 1] := valuestring[l];
                    end;
               end;
          end;
          maxy := maxy - incrementy;
     end;
     { print the plot }
     for i := 1 to row do
     begin
          outline := ' |';
          for j := 1 to 60 do outline := outline + format('%1s',[plotstring[i,j]]);
          outline := outline + format('|-%6.2f-%6.2f',
              [(y_max - i * incrementy),(y_max - i * incrementy + incrementy)]);
          OutputFrm.RichEdit.Lines.Add(outline);
     end;
     outline := '';
     for i := 1 to 63 do outline := outline + '-';
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := '';
     for i := 1 to 16 do outline := outline + '  | ';
     outline := outline + x_axis;
     OutputFrm.RichEdit.Lines.Add(outline);
     outline := '';
     for i := 1 to 16 do outline := outline + format('%4.1f',[(x_min + i * incrementx - incrementx)]);
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Labels:');
     for i := 1 to nocases do
     begin
          outline := format('%2d = %s',[i,Labels[i-1]]);
          OutputFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
     Labels := nil;
end; { of scatplot procedure }


initialization
  {$I singlelinkunit.lrs}

end.

