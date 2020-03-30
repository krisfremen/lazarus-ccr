// Use file "bubbleplot2.laz" for testing.

unit BubblePlotUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Clipbrd, Buttons, ExtCtrls, Math,
  MainUnit, Globals, OutputUnit, DataProcs, DictionaryUnit, ContextHelpUnit;


type

  { TBubbleForm }

  TBubbleForm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    TransformChk: TCheckBox;
    YLabelEdit: TEdit;
    Label8: TLabel;
    XLabelEdit: TEdit;
    Label7: TLabel;
    TitleEdit: TEdit;
    Label6: TLabel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    IDInBtn: TBitBtn;
    IDOutBtn: TBitBtn;
    XInBtn: TBitBtn;
    XOutBtn: TBitBtn;
    YInBtn: TBitBtn;
    YOutBtn: TBitBtn;
    SizeInBtn: TBitBtn;
    SizeOutBtn: TBitBtn;
    BubbleEdit: TEdit;
    SizeEdit: TEdit;
    YEdit: TEdit;
    XEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure IDInBtnClick(Sender: TObject);
    procedure IDOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure SizeInBtnClick(Sender: TObject);
    procedure SizeOutBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure XInBtnClick(Sender: TObject);
    procedure XOutBtnClick(Sender: TObject);
    procedure YInBtnClick(Sender: TObject);
    procedure YOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: boolean;
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  BubbleForm: TBubbleForm;

implementation

uses
  BlankFrmUnit;

{ TBubbleForm }

procedure TBubbleForm.IDInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (BubbleEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if (VarList.Selected[i]) then
    begin
      BubbleEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TBubbleForm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TBubbleForm.ComputeBtnClick(Sender: TObject);
var
  BubbleCol, XCol, YCol, SizeCol, i, j, LabelWide, TextHi, Xpos: integer;
  ImageWide, ImageHi, Xstart, Xend, Ystart, Yend, Yincr, cell: integer;
  Xmin, Xmax, Xrange, Xstep, intcell, noreplications, minrep, maxrep: integer;
  nobubbles, yprop: integer;
  varname, Xlabel, Ylabel, astring, Title: string;
  Ymin, Ymax, Yrange, Ystep, cellvalue, xvalue: double;
  BubMin, BubMax, BubRange, ratio, value: double;
  valstr: string;
  BubColor, place: integer;
  X1, Y1, X2, Y2: integer;
  dx, dy: Integer;
  Data: DblDyneMat;
  ncases, ncols, BubbleID, newcol : integer;
  GrandYMean, GrandSizeMean, sizevalue, yvalue: double;
  Ymeans: DblDyneVec;
  CaseYMeans: DblDyneVec;
  SizeMeans: DblDyneVec;
  CaseSizeMeans: DblDyneVec;
  outline: string;
  labels: StrDyneVec;
  lReport: TStrings;
begin
  BubbleCol := 0;
  XCol := 0;
  YCol := 0;
  SizeCol := 0;
  for i := 1 to NoVariables do
  begin
    varname := OS3MainFrm.DataGrid.Cells[i,0];
    if (varname = BubbleEdit.Text) then BubbleCol := i;
    if (varname = XEdit.Text) then XCol := i;
    if (varname = YEdit.Text) then YCol := i;
    if (varname = SizeEdit.Text) then SizeCol := i;
  end;
  if ((BubbleCol = 0) or (XCol = 0) or (YCol = 0) or (SizeCol = 0)) then
  begin
    MessageDlg('One or more variables not found.', mtError, [mbOK], 0);
    ModalResult := mrNone;
    Exit;
  end;

  // get number of bubbles and replications per bubble (number of bubble id's)
  minrep := 1000;
  maxrep := -1;
  for i := 1 to NoCases do
  begin
    intcell := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
    if (intcell > maxrep) then maxrep := intcell;
    if (intcell < minrep) then minrep := intcell;
  end;
  nobubbles := maxrep - minrep + 1;
  noreplications := 1;
  intcell := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,1]);
  for i := 2 to NoCases do
  begin
    cell := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
    if (cell = intcell) then noreplications := noreplications + 1;
  end;

  // get min, max and range of Y
  Ymin := 1.0e308;
  Ymax := -1.0e308;
  for i := 1 to NoCases do
  begin
    cellvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
    if (cellvalue > Ymax) then Ymax := cellvalue;
    if (cellvalue < Ymin) then Ymin := cellvalue;
  end;
  Yrange := Ymax - Ymin;
  Ystep := Yrange / 10;

  // get min, max and range of X
  Xmin := 10000;
  Xmax := -1;
  for i := 1 to NoCases do
  begin
    intcell := StrToInt(OS3MainFrm.DataGrid.Cells[XCol,i]);
    if (intcell > Xmax) then Xmax := intcell;
    if (intcell < Xmin) then Xmin := intcell;
  end;
  Xrange := Xmax - Xmin;
  Xstep := Xrange div (noreplications-1);

  // get min, max, range, and increment of bubble sizes
  BubMin := 1.0e308;
  BubMax := -1.0e308;
  for i := 1 to NoCases do
  begin
    cellvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[SizeCol,i]);
    if (cellvalue > BubMax) then BubMax := cellvalue;
    if (cellvalue < BubMin) then BubMin := cellvalue;
  end;
  BubRange := BubMax - BubMin;

  // Display basic statistics
  ncases := NoCases div noreplications;
  GrandYMean := 0.0;
  GrandSizeMean := 0.0;
  SetLength(CaseYMeans,ncases);
  SetLength(CaseSizeMeans,ncases);
  SetLength(Ymeans,noreplications);
  SetLength(SizeMeans,noreplications);
  for i := 0 to ncases - 1 do
  begin
    CaseYMeans[i] := 0.0;
    CaseSizeMeans[i] := 0.0;
  end;
  for i := 0 to noreplications - 1 do
  begin
    Ymeans[i] := 0.0;
    SizeMeans[i] := 0.0;
  end;

  i := 1;
  while (i <= NoCases) do
  begin
    for j := 1 to noreplications do
    begin
      bubbleID := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
      yvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
      sizevalue := StrToFloat(OS3MainFrm.DataGrid.Cells[SizeCol,i]);
      GrandYMean := GrandYMean + yvalue;
      GrandSizeMean := GrandSizeMean + sizevalue;
      Ymeans[j-1] := Ymeans[j-1] + yvalue;
      SizeMeans[j-1] := SizeMeans[j-1] + sizevalue;
      CaseYMeans[bubbleID-1] := CaseYMeans[bubbleID-1] + yvalue;
      CaseSizeMeans[bubbleID-1] := CaseSizeMeans[bubbleID-1] + sizevalue;
      inc(i);
    end;
  end;

  GrandYMean := GrandYMean / (ncases * noreplications);
  GrandSizeMean := GrandSizeMean  / (ncases * noreplications);
  for j := 0 to noreplications - 1 do
  begin
    Ymeans[j] := Ymeans[j] / ncases;
    SizeMeans[j] := SizeMeans[j] / ncases;
  end;
  for i := 0 to ncases - 1 do
  begin
    CaseYMeans[i] := CaseYMeans[i] / noreplications;
    CaseSizeMeans[i] := CaseSizeMeans[i] / noreplications;
  end;

  lReport := TStringList.Create;
  try
    lReport.Add('MEANS FOR Y AND SIZE VARIABLES');
    lReport.Add('');
    lReport.Add('Grand Mean for Y := %8.3f', [GrandYMean]);
    lReport.Add('Grand Mean for Size := %8.3f', [GrandSizeMean]);
    lReport.Add('');
    lReport.Add('REPLICATION MEAN Y VALUES (ACROSS OBJECTS)');
    for j := 0 to noreplications - 1 do
      lReport.Add('Replication %5d Mean := %8.3f', [j+1, Ymeans[j]]);
    lReport.Add('');
    lReport.Add('REPLICATION MEAN SIZE VALUES (ACROSS OBJECTS)');
    for j := 0 to noreplications - 1 do
      lReport.Add('Replication %5d Mean := %8.3f', [j+1, SizeMeans[j]]);
    lReport.Add('');
    lReport.Add('MEAN Y VALUES FOR EACH BUBBLE (OBJECT)');
    for i := 0 to ncases - 1 do
      lReport.Add('Object %5d Mean := %8.3f', [i+1, CaseYMeans[i]]);
    lReport.Add('');
    lReport.Add('MEAN SIZE VALUES FOR EACH BUBBLE (OBJECT)');
    for i := 0 to ncases - 1 do
       lReport.Add('Object %5d Mean := %8.3f', [i+1, CaseSizeMeans[i]]);

    DisplayReport(lReport);

  finally
    lReport.Free;
    SizeMeans := nil;
    Ymeans := nil;
    CaseSizeMeans := nil;
    CaseYMeans := nil;
  end;

//--------------------------------------------------------------------------
// Plotting Section
//---------------------------------------------------------------------------
  //BlankFrm.Image1.Canvas.Clear;
  BlankFrm.Show;
  BlankFrm.Caption := 'BUBBLE PLOT of ' + OS3MainFrm.FileNameEdit.Text;
  Xlabel := XlabelEdit.Text;
  Ylabel := YlabelEdit.Text;
  Title := TitleEdit.Text;
  ImageHi := BlankFrm.Image1.Height;
  ImageWide := BlankFrm.Image1.Width;
  Xstart := ImageWide div 10;
  Xend := (ImageWide * 9) div 10;
  Ystart := ImageHi div 10;
  Yend := (ImageHi * 8) div 10;
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Rectangle(0,0,ImageWide,ImageHi);
  BlankFrm.Image1.Canvas.FloodFill(0,0,clWhite,fsBorder);
  BlankFrm.Image1.Canvas.TextOut(Xstart-10,Ystart-30,Ylabel);
  LabelWide := BlankFrm.Image1.Canvas.TextWidth(Xlabel);
  BlankFrm.Image1.Canvas.TextOut((Xend-Xstart) div 2 - LabelWide,Yend + 40,Xlabel);
  LabelWide := BlankFrm.Image1.Canvas.TextWidth(Title);
  BlankFrm.Image1.Canvas.TextOut((Xend-Xstart) div 2 - LabelWide div 2, Ystart - 40,Title);

  // draw axis lines
  BlankFrm.Image1.Canvas.MoveTo(Xstart,Yend);
  BlankFrm.Image1.Canvas.LineTo(Xend,Yend);
  BlankFrm.Image1.Canvas.MoveTo(Xstart,Yend);
  BlankFrm.Image1.Canvas.LineTo(Xstart,Ystart);

  // create y axis values
  Yincr := (Yend - Ystart) div 10;
  for i := 0 to 10 do  // print Y axis values
  begin
    place := Yend - (i * Yincr);
    value := Ymin + (Ystep * i);
    valstr := format('%.2f',[value]);
    astring := valstr;
    TextHi := BlankFrm.Image1.Canvas.TextHeight(astring);
    BlankFrm.Image1.Canvas.TextOut(Xstart-30,place-TextHi,astring);
  end;

  // create x axis values
  for i := 1 to noreplications do  // print x axis
  begin
    value := Xmin + ((i-1) * Xstep);
    ratio := i / noreplications;
    Xpos := round(ratio * (Xend - Xstart));
    valstr := format('%.0f',[value]);
    astring := valstr;
    BlankFrm.Image1.Canvas.TextOut(Xpos,Yend + 20,astring);
  end;

  // Plot the bubbles
  for i := 1 to NoCases do
  begin
    intcell := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
    xvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol,i]);
    cellvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
    yprop := Yend - round(((cellvalue-Ymin) / Yrange) * (Yend - Ystart));
    cellvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[SizeCol,i]);
    astring := Trim(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
    cellvalue := ((cellvalue - BubMin) / BubRange) * 20;
    cellvalue := cellvalue + 10;
    ratio := ((xvalue - Xmin) / Xstep) + 1;
    ratio := (ratio / noreplications) * (Xend - Xstart);
    Xpos := ceil(ratio);
    BubColor := intcell - 1;
    while (Bubcolor > 11) do Bubcolor := 12 - Bubcolor;
    BlankFrm.Image1.Canvas.Brush.Color := DATA_COLORS[Bubcolor];
    X1 := Xpos - ceil(cellvalue);
    Y1 := yprop - ceil(cellvalue);
    X2 := Xpos + ceil(cellvalue);
    Y2 := yprop + ceil(cellvalue);
    BlankFrm.Image1.Canvas.Ellipse(X1,Y1,X2,Y2);
    BlankFrm.Image1.Canvas.Brush.Color := clWhite;
    dx := BlankFrm.Image1.Canvas.TextWidth(astring) div 2;
    dy := BlankFrm.Image1.Canvas.TextHeight(astring) div 2;
    BlankFrm.Image1.Canvas.TextOut(Xpos-dx, yprop-dy, astring);
  end;

  // Transform data matrix if elected
  if (TransformChk.Checked = true) then
  begin
    ncases := nobubbles;
    ncols := noreplications * 3 + 1;

    // Note - columns: 1:=object ID, 2 to noreplications := X,
    // next noreplications := Y, next noreplications := size
    SetLength(Data,ncases,ncols);
    i := 1;
    while (i <= NoCases) do
    begin
      for j := 1 to noreplications do
      begin
        bubbleID := StrToInt(OS3MainFrm.DataGrid.Cells[BubbleCol,i]);
        xvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol,i]);
        yvalue := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
        sizevalue := StrToFloat(OS3MainFrm.DataGrid.Cells[SizeCol,i]);
        Data[bubbleID-1,0] := bubbleID;
        Data[bubbleID-1,j] := xvalue;
        Data[bubbleID-1,noreplications+j] := yvalue;
        Data[bubbleID-1,noreplications*2+j] := sizevalue;
        inc(i);
      end;
    end;

    SetLength(labels,NoVariables+1);
    for i := 1 to NoVariables do labels[i] := OS3MainFrm.DataGrid.Cells[i,0];
    ClearGrid;
    OS3MainFrm.DataGrid.RowCount := ncases + 1;
    OS3MainFrm.DataGrid.ColCount := ncols + 1;

    for i := 1 to ncases do
    begin
      OS3MainFrm.DataGrid.Cells[0,i] := IntToStr(i);
      for j := 1 to ncols do
        OS3MainFrm.DataGrid.Cells[j,i] := FloatToStr(Data[i-1,j-1]);
    end;
    OS3MainFrm.DataGrid.Cells[1,0] := labels[1];

    for j := 2 to NoVariables do // clear dictionary
    begin
      for i := 0 to 7 do DictionaryFrm.DictGrid.Cells[i,j] := '';
      DictionaryFrm.DictGrid.RowCount := DictionaryFrm.DictGrid.RowCount - 1;
      VarDefined[j] := false;
    end;
    DictionaryFrm.DictGrid.Cells[1,1] := labels[1];

    for j := 1 to noreplications do
    begin
      outline := labels[2] + IntToStr(j);
      newcol := j + 1;
      if (newcol+1 > DictionaryFrm.DictGrid.RowCount) then
        DictionaryFrm.DictGrid.RowCount := DictionaryFrm.DictGrid.RowCount + 1;
      DictionaryFrm.Defaults(Self,newcol);
      VarDefined[newcol] := true;
      DictionaryFrm.DictGrid.Cells[1,newcol] := outline;
      OS3MainFrm.DataGrid.Cells[newcol,0] := outline;
    end;

    for j := 1 to noreplications do
    begin
      outline := labels[3] + IntToStr(j);
      newcol := j + 1 + noreplications;
      OS3MainFrm.DataGrid.Cells[newcol,0] := outline;
      if (newcol+1 > DictionaryFrm.DictGrid.RowCount) then
        DictionaryFrm.DictGrid.RowCount := DictionaryFrm.DictGrid.RowCount + 1;
      DictionaryFrm.Defaults(Self,newcol);
      VarDefined[newcol] := true;
      DictionaryFrm.DictGrid.Cells[1,newcol] := outline;
    end;

    for j := 1 to noreplications do
    begin
      outline := labels[4] + IntToStr(j);
      newcol := j + 1 + noreplications * 2;
      OS3MainFrm.DataGrid.Cells[newcol,0] := outline;

      if (newcol+1 > DictionaryFrm.DictGrid.RowCount) then
        DictionaryFrm.DictGrid.RowCount := DictionaryFrm.DictGrid.RowCount + 1;
      DictionaryFrm.Defaults(Self,newcol);
      VarDefined[newcol] := true;

      DictionaryFrm.DictGrid.Cells[1,newcol] := outline;
    end;

    NoVariables := ncols;
    NoCases := ncases;
    OS3MainFrm.NoCasesEdit.Text := IntToStr(NoCases);
    OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVariables);
    Data := nil;
    labels := nil;
  end;
end;

procedure TBubbleForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;

  Panel1.Constraints.MinHeight := SizeOutBtn.Top + SizeOutBtn.Height;
  Panel1.Constraints.MinWidth := 2*Label2.Width + IDInBtn.Width + 2*VarList.BorderSpacing.Right;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := True;
end;

procedure TBubbleForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
  if BlankFrm = nil then Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TBubbleForm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TBubbleForm.IDOutBtnClick(Sender: TObject);
begin
  if BubbleEdit.Text <> '' then
    VarList.Items.Add(BubbleEdit.Text);
  UpdateBtnStates;
end;

procedure TBubbleForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  BubbleEdit.Text := '';
  XEdit.Text := '';
  YEdit.Text := '';
  SizeEdit.Text := '';
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TBubbleForm.SizeInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (SizeEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] then
    begin
      SizeEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TBubbleForm.SizeOutBtnClick(Sender: TObject);
begin
  if SizeEdit.Text <> '' then
     VarList.Items.Add(SizeEdit.Text);
  UpdateBtnStates;
end;

procedure TBubbleForm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TBubbleForm.XInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (XEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] then
    begin
      XEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TBubbleForm.XOutBtnClick(Sender: TObject);
begin
  if XEdit.Text <> '' then
    VarList.Items.Add(XEdit.Text);
  UpdateBtnStates;
end;

procedure TBubbleForm.YInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while (YEdit.Text = '') and (i < VarList.Items.Count) do
  begin
    if VarList.Selected[i] then
    begin
      YEdit.Text := VarList.Items[i];
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TBubbleForm.YOutBtnClick(Sender: TObject);
begin
  if YEdit.Text <> '' then
    VarList.Items.Add(YEdit.Text);
  UpdateBtnStates;
end;

procedure TBubbleForm.UpdateBtnStates;
var
  i: Integer;
  lSelected: Boolean;
begin
  lSelected := false;
  for i:=0 to VarList.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;

  IDInBtn.Enabled := lSelected and (BubbleEdit.Text = '');
  XInBtn.Enabled := lSelected and (XEdit.Text = '');
  YInBtn.Enabled := lSelected and (YEdit.Text = '');
  SizeInBtn.Enabled := lSelected and (SizeEdit.Text = '');
  IDOutBtn.Enabled := BubbleEdit.Text <> '';
  XOutBtn.Enabled := XEdit.Text <> '';
  YOutBtn.Enabled := YEdit.Text <> '';
  SizeOutBtn.Enabled := SizeEdit.Text <> '';
end;


initialization
  {$I bubbleplotunit.lrs}

end.

