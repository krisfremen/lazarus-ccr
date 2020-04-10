// Sample file for testing: cansas.laz, use all variiables.

unit HierarchUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, Globals, MatrixLib, GraphLib, DataProcs;

type

  { THierarchFrm }

  THierarchFrm = class(TForm)
    Bevel1: TBevel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    MaxGrps: TEdit;
    STDChk: TCheckBox;
    ReplaceChk: TCheckBox;
    StatsChk: TCheckBox;
    PlotChk: TCheckBox;
    MaxGrpsChk: TCheckBox;
    MembersChk: TCheckBox;
    VarChk: TCheckBox;
    GroupBox1: TGroupBox;
    PredIn: TBitBtn;
    PredOut: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    PredList: TListBox;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PredInClick(Sender: TObject);
    procedure PredOutClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  HierarchFrm: THierarchFrm;

implementation

uses
  Math, Utils;

{ THierarchFrm }

procedure THierarchFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  PredList.Clear;
  StdChk.Checked := false;
  ReplaceChk.Checked := false;
  StatsChk.Checked := false;
  PlotChk.Checked := false;
  MaxGrpsChk.Checked := false;
  VarChk.Checked := false;
  MaxGrps.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure THierarchFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;
  VarList.Constraints.MinWidth := PredList.Width;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure THierarchFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

procedure THierarchFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure THierarchFrm.ComputeBtnClick(Sender: TObject);
label next1;
var
  varlabels, rowlabels : StrDyneVec;
  cellstring : string;
  i, j, k, k1, k3, L, w3, n3, n4, n5, M, col, count: integer;
  GrpCnt, Nrows, Ncols, NoSelected: integer;
  w2, k4, k5, L1 : IntDyneVec;
  ColSelected : IntDyneVec;
  X, Y, d1, x1, MaxError : double;
  W, XAxis, YAxis, means, variances, stddevs : DblDyneVec;
  Distance : DblDyneMat;
  lReport: TStrings;
begin
  if MaxGrpsChk.Checked then
  begin
    if MaxGrps.Text = '' then
    begin
      MessageDlg('Maximum number of groups not specified.', mtError, [mbOK], 0);
      exit;
    end;
    if not TryStrToInt(MaxGrps.Text, k1) or (k1 < 1) then
    begin
      Messagedlg('No valid number of groups given.', mtError, [mbOK], 0);
      exit;
    end;
  end;

  MaxError := 0.0;
  GrpCnt := 0;
  NoSelected  :=  PredList.Items.Count;
  if not VarChk.Checked then
  begin
    SetLength(w2,NoCases);
    SetLength(k4,NoCases);
    SetLength(k5,NoCases);
    SetLength(L1,NoCases);
    SetLength(W,NoSelected);
    SetLength(XAxis,NoCases);
    SetLength(YAxis,NoCases);
    SetLength(means,NoSelected);
    SetLength(variances,NoSelected);
    SetLength(stddevs,NoSelected);
    SetLength(Distance,NoCases,NoCases);
    SetLength(varlabels,NoSelected);
    SetLength(rowlabels,NoCases);
    SetLength(ColSelected,NoSelected);
    Ncols  :=  NoSelected;
    Nrows  :=  NoCases;
    for i := 0 to Ncols - 1 do
    begin
      cellstring := PredList.Items.Strings[i];
      for j := 1 to NoVariables do
      begin
        if (cellstring = OS3MainFrm.DataGrid.Cells[j,0]) then
        begin
          varlabels[i] := cellstring;
          ColSelected[i] := j;
        end;
      end;
    end;
    for i := 0 to NoCases-1 do rowlabels[i] := IntToStr(i);
  end else
  begin
    SetLength(w2,NoSelected);
    SetLength(k4,NoSelected);
    SetLength(k5,NoSelected);
    SetLength(L1,NoSelected);
    SetLength(W,NoCases);
    SetLength(XAxis,NoSelected);
    SetLength(YAxis,NoSelected);
    SetLength(means,NoCases);
    SetLength(variances,NoCases);
    SetLength(stddevs,NoCases);
    SetLength(Distance,NoSelected,NoCases);
    SetLength(varlabels,NoCases);
    SetLength(rowlabels,NoSelected);
    SetLength(ColSelected,NoSelected);
    Ncols := NoCases;
    Nrows := NoSelected;
    //Get labels of selected variables
    for i := 0 to Nrows - 1 do
    begin
      cellstring := PredList.Items.Strings[i];
      for j := 1 to NoVariables do
      begin
        if (cellstring = OS3MainFrm.DataGrid.Cells[j,0]) then
        begin
          ColSelected[i] := j;
          rowlabels[i] := cellstring;
        end;
      end;
    end;
    for i := 0 to NoCases-1 do
      varlabels[i] := IntToStr(i);
  end;

  if MembersChk.Checked then k3 := 1 else k3 := 0;

  for j := 0 to Ncols-1 do
  begin
    means[j] := 0.0;
    variances[j] := 0.0;
    stddevs[j] := 0.0;
  end;

  if VarChk.Checked = false then
  begin
    // Get labels of rows
//       for i := 1 to Nrows do rowlabels[i-1] := MainFrm.Grid.Cells[0,i];

    // Get data into the distance matrix
    count := 0;
    for i := 1 to Nrows do
    begin
      if (not GoodRecord(i,NoSelected,ColSelected)) then continue;
      count := count + 1;
      for j := 1 to Ncols do
      begin
        col := ColSelected[j-1];
        X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,i]));
        means[j-1] := means[j-1] + X;
        variances[j-1] := variances[j-1] + (X * X);
        Distance[i-1,j-1] := X;
      end;
    end;
  end else
  begin // cluster variables
    // Get labels of columns
//       for i := 1 to Nrows do rowlabels[i-1] := MainFrm.Grid.Cells[i,0];

    // Get data into the distance matrix
    count := 0;
    for i := 1 to Nrows do // actually grid column in this case
    begin
//           if (not GoodRecord(i,NoSelected,ColSelected)) then continue;
      count := count + 1;
      for j := 1 to Ncols do // actually grid rows in this case
      begin
//                if (not GoodRecord(j,NoSelected,ColSelected)) then continue;
        col := ColSelected[i-1];
        X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[col,j]));
        means[j-1] := means[j-1] + X;
        variances[j-1] := variances[j-1] + (X * X);
        Distance[i-1,j-1] := X;
      end;
    end;
  end;

  // Calculate means and standard deviations of variables
  for j := 0 to Ncols-1 do
  begin
    variances[j] := variances[j] - (means[j] * means[j] / count);
    variances[j] := variances[j] / (count - 1);
    stddevs[j] := sqrt(variances[j]);
    means[j] := means[j] / count;
  end;

  // Ready the output form
  lReport := TStringList.Create;
  try
    lReport.Add('HIERARCHICAL CLUSTER ANALYSIS');
    lReport.Add('');
    lReport.Add('Number of objects to cluster: %d on %d variables.', [Nrows, Ncols]);
    lReport.Add('');

    if StatsChk.Checked then
    begin
      DynVectorPrint(means, Ncols, 'Variable Means', varlabels, count, lReport);
      DynVectorPrint(variances, Ncols, 'Variable Variances', varlabels, count, lReport);
      DynVectorPrint(stddevs, Ncols, 'Variable Standard Deviations', varlabels, count, lReport);
      lReport.Add(DIVIDER);
      lReport.Add('');
    end;

    // Standardize the distance scores if elected
    if StdChk.Checked then
    begin
      for j := 0 to Ncols-1 do
        for i := 0 to Nrows-1 do
          Distance[i,j] := (Distance[i,j] - means[j]) / stddevs[j];
    end;

    // replace original values in grid with z scores if elected
    if ReplaceChk.Checked then
    begin
      for i := 1 to Nrows do
      begin
        if not GoodRecord(i,NoSelected,ColSelected) then continue;
        for j := 1 to Ncols do
        begin
          col := ColSelected[j-1];
          OS3MainFrm.DataGrid.Cells[col,i] := Format('%6.4f', [Distance[i-1,j-1]]);
        end;
      end;
    end;

    // Convert data matrix to initial matrix of error potentials
    for i := 1 to Nrows do
    begin
//    if (not GoodRecord(i,NoSelected,ColSelected)) then continue;
      for j := 1 to Ncols do
        W[j-1] := Distance[i-1,j-1];
      for j := i to Nrows do
      begin
//      if (not GoodRecord(i,NoSelected,ColSelected)) then continue;
        Distance[i-1,j-1] := 0.0;
        for k := 1 to Ncols do
          Distance[i-1,j-1] := Distance[i-1,j-1] + (Distance[j-1,k-1] - W[k-1]) * (Distance[j-1,k-1] - W[k-1]);
        Distance[i-1,j-1] := Distance[i-1,j-1] / 2.0;
      end;
    end;
    for i := 1 to Nrows do
      for j := i to Nrows do Distance[j-1,i-1] := 0.0;

    // Now, group the cases for maximum groups down
    if MaxGrpsChk.Checked then
    begin
      k1 := StrToInt(MaxGrps.Text);
      n3 := Nrows;
    end else
    begin
      k1 := 2;
      n3 := Nrows;
    end;

    // Initialize group membership and group-n vectors
    for i := 0 to Nrows-1 do
    begin
      k4[i] := i+1;
      k5[i] := i+1;
      w2[i] := 1;
    end;

    // Locate optimal combination, if more than 2 groups remain

next1:

    n3 := n3 - 1;
    if (n3 > 1) then
    begin
      x1 := 100000000000.0;
      for i := 1 to Nrows do
      begin
        if (k5[i-1] = i) then
        begin
          for j := i to Nrows do
          begin
            if ((i <> j) and (k5[j-1] = j)) then
            begin
              d1 := Distance[i-1,j-1] - Distance[i-1,i-1] - Distance[j-1,j-1];
              if (d1 < x1) then
              begin
                x1 := d1;
                L := i;
                M := j;
              end; // end if
            end; // end if
          end; // next j
        end; // end if
      end; // next i
      n4 := w2[L-1];
      n5 := w2[M-1];

      GrpCnt := GrpCnt + 1;
      XAxis[GrpCnt-1] := n3;
      YAxis[GrpCnt-1] := x1;
      if (x1 > MaxError) then MaxError := x1;
      lReport.Add('%2.d groups after combining group %2.d (n = %2.d) and group %2.d (n = %2.d), error: %7.3f', [n3, L, n4, M, n5, x1]);

      w3 := w2[L-1] + w2[M-1];
      x1 := Distance[L-1,M-1] * w3;
      Y := Distance[L-1,L-1] * w2[L-1] + Distance[M-1,M-1] * w2[M-1];
      Distance[L-1,L-1] := Distance[L-1,M-1];
      for i := 1 to Nrows do
        if (k5[i-1] = M) then k5[i-1] := L;
      for i := 1 to Nrows do
      begin
        if ((i <> L) and (k5[i-1] = i)) then
        begin
          if (i <= L) then
          begin
            Distance[i-1,L-1] := Distance[i-1,L-1] * (w2[i-1] + w2[L-1])
              + Distance[i-1,M-1] * (w2[i-1] + w2[M-1])
              + x1 - Y - Distance[i-1,i-1] * w2[i-1];
            Distance[i-1,L-1] := Distance[i-1,L-1] / (w2[i-1] + w3);
          end else
          begin
            Distance[L-1,i-1] := Distance[L-1,i-1] * (w2[L-1] + w2[i-1])
              + (Distance[M-1,i-1] + Distance[i-1,M-1]) * (w2[M-1] + w2[i-1]);
            Distance[L-1,i-1] := (Distance[L-1,i-1]+ x1 - Y
              - Distance[i-1,i-1] * w2[i-1]) / (w2[i-1] + w3);
          end;
        end;
      end;
      w2[L-1] := w3;
      if (n3 > k1) then goto next1;

      // print group memberships of all objects, if optioned
      for i := 1 to Nrows do
      begin
        if (k5[i-1] = i) then
        begin
          L := 0;
          for j := 1 to Nrows do
          begin
            if (k5[j-1] = i) then
            begin
              L := L + 1;
              L1[L-1] := k4[j-1];
              if k3 = 1 then L1[L-1] := j;
            end;
          end;
          if k3 = 1 then
          begin
            lReport.Add('Group %d (n = %d)', [i, L]);
            for j := 1 to L do
               lReport.Add('  Object: %s', [rowlabels[L1[j-1]-1]]);
          end; // end if
        end; // end if
      end; // next i
      goto next1;
    end; // end if

    DisplayReport(lReport);

    if PlotChk.Checked then
    begin
      SetLength(GraphFrm.Ypoints,1,GrpCnt);
      SetLength(GraphFrm.Xpoints,1,GrpCnt);
      for i := 1 to GrpCnt do
      begin
        GraphFrm.Ypoints[0,i-1] := YAxis[i-1];
        GraphFrm.Xpoints[0,i-1] := XAxis[i-1];
      end;
      GraphFrm.nosets := 1;
      GraphFrm.nbars := GrpCnt;
      GraphFrm.Heading := 'NO. GROUPS VERSUS GROUPING ERROR';
      GraphFrm.XTitle := 'NO. GROUPS';
      GraphFrm.YTitle := 'ERROR';
//       GraphFrm.Ypoints[1] := YAxis;
//       GraphFrm.Xpoints[1] := XAxis;
      GraphFrm.AutoScaled := true;
      GraphFrm.PtLabels := false;
      GraphFrm.GraphType := 7; // 2d points
      GraphFrm.BackColor := clCream;
      GraphFrm.ShowBackWall := true;
      GraphFrm.ShowModal;
    end;

  finally
    lReport.Free;
    ColSelected := nil;
    rowlabels := nil;
    varlabels := nil;
    Distance := nil;
    stddevs := nil;
    variances := nil;
    means := nil;
    YAxis := nil;
    XAxis := nil;
    W := nil;
    L1 := nil;
    k5 := nil;
    k4 := nil;
    w2 := nil;
    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
  end;
end;

procedure THierarchFrm.PredInClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      PredList.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure THierarchFrm.PredOutClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < PredList.Items.Count do
  begin
    if PredList.Selected[i] then
    begin
      VarList.Items.Add(PredList.Items[i]);
      PredList.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

procedure THierarchFrm.UpdateBtnStates;
begin
  PredIn.Enabled := AnySelected(VarList);
  PredOut.Enabled := AnySelected(PredList);
end;

procedure THierarchFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I hierarchunit.lrs}

end.

