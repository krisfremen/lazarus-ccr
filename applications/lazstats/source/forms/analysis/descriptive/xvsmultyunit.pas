// Use file "SchoolsData.laz" for testing

unit XvsMultYUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Printers,
  MainUnit, Globals, OutputUnit, DataProcs, BlankFrmUnit, MatrixLib;

type

  { TXvsMultYForm }

  TXvsMultYForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    LinesBox: TCheckBox;
    DescChk: TCheckBox;
    GroupBox1: TGroupBox;
    Memo1: TLabel;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    PlotTitleEdit: TEdit;
    Label4: TLabel;
    YBox: TListBox;
    XEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    XInBtn: TBitBtn;
    YInBtn: TBitBtn;
    Label1: TLabel;
    XOutBtn: TBitBtn;
    YOutBtn: TBitBtn;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure XInBtnClick(Sender: TObject);
    procedure XOutBtnClick(Sender: TObject);
    procedure YInBtnClick(Sender: TObject);
    procedure YOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    selected: IntDyneVec;
    procedure PlotXY(XValues : DblDyneVec; YValues : DblDyneMat; MaxX, MinX,
       MaxY, MinY : double; N, NoY : integer);
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  XvsMultYForm: TXvsMultYForm;

implementation

uses
  Math;

{ TXvsMultYForm }

procedure TXvsMultYForm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     YBox.Clear;
     XEdit.Clear;
     XInBtn.Enabled := true;
     XOutBtn.Enabled := false;
     YInBtn.Enabled := true;
     YOutBtn.Enabled := false;
     PlotTitleEdit.Text := '';
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TXvsMultYForm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TXvsMultYForm.ComputeBtnClick(Sender: TObject);
var
  i, j, k, N, NoY, XCol, NoSelected: integer;
  YValues, RMatrix: DblDyneMat;
  XValues, Means, Variances, StdDevs: DblDyneVec;
  MinX, MaxX, MinY, MaxY, temp: double;
  Title: string;
  RowLabels, ColLabels: StrDyneVec;
  lReport: TStrings;
  errorcode: boolean = false;
  Ncases: integer = 0;
begin
  if XEdit.Text = '' then
  begin
    MessageDlg('No X variable selected.', mtError, [mbOK], 0);
    exit;
  end;

  if YBox.Items.Count = 0 then
  begin
    MessageDlg('No Y variables selected.', mtError, [mbOK], 0);
    exit;
  end;

  NoY := YBox.Items.Count;
  MaxX := -10000;
  MinX := 10000;
  MaxY := -1000;
  MinY := 1000;
  N := 0;

  SetLength(selected, NoY + 1);
  SetLength(RowLabels,NoVariables);
  SetLength(ColLabels,NoVariables);

  XCol := 0;
  for i := 1 to NoVariables do
    if Trim(XEdit.Text) = Trim(OS3MainFrm.DataGrid.Cells[i,0]) then
    begin
      XCol := i;
      break;
    end;

  for j := 0 to NoY-1 do
  begin
    selected[j] := 0;
    for i := 1 to NoVariables do
      if Trim(YBox.Items.Strings[j]) = Trim(OS3MainFrm.DataGrid.Cells[i,0]) then
      begin
        selected[j] := i;
        Break;
      end;
  end;

  selected[NoY] := XCol;
  NoSelected := NoY + 1;
  for i := 0 to NoSelected-1 do
  begin
    RowLabels[i] := Trim(OS3MainFrm.DataGrid.Cells[selected[i],0]);
    ColLabels[i] := RowLabels[i];
  end;

  Caption := RowLabels[0] + ' ' + RowLabels[1];

  lReport := TStringList.Create;
  try
    lReport.Add('X VERSUS MULTIPLE Y VALUES PLOT');
    lReport.Add('');

    SetLength(YValues, NoCases+1, NoY+1);
    SetLength(XValues, NoCases+1);
    SetLength(Means, NoSelected+1);
    SetLength(Variances, NoSelected+1);
    SetLength(StdDevs, NoSelected+1);
    SetLength(RMatrix, NoSelected+1, NoSelected+1);
    SetLength(selected, NoVariables);

    for i := 0 to NoSelected - 1 do
    begin
      Means[i] := 0.0;
      StdDevs[i] := 0.0;
      for j := 0 to NoSelected-1 do RMatrix[i,j] := 0.0;
    end;

    for i := 1 to NoCases do
    begin
      if not GoodRecord(i,NoSelected,selected) then continue;
      XValues[i] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[XCol,i]));
      if XValues[i] > MaxX then MaxX := XValues[i];
      if XValues[i] < MinX then MinX := XValues[i];
      for j := 0 to NoY - 1 do
      begin
        YValues[i-1,j] := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[selected[j],i]));
        if YValues[i-1,j] > MaxY then MaxY := YValues[i-1,j];
        if YValues[i-1,j] < MinY then MinY := YValues[i-1,j];
      end;
    end;

    // get descriptive data
    if DescChk.Checked then
    begin
      Correlations(NoSelected,selected,RMatrix,Means,Variances,StdDevs,errorcode,Ncases);
      N := Ncases;
      Title := 'CORRELATIONS';
      MatPrint(RMatrix, NoSelected, NoSelected, Title, RowLabels, ColLabels, N, lReport);
      Title := 'Means';
      DynVectorPrint(Means, NoSelected, Title, RowLabels, N, lReport);
      Title := 'Variances';
      DynVectorPrint(Variances, NoSelected, Title, RowLabels, N, lReport);
      Title := 'Standard Deviations';
      DynVectorPrint(StdDevs, NoSelected, Title, RowLabels, N, lReport);
    end;

    DisplayReport(lReport);

    // sort on X
    for i := 0 to N-2 do
    begin
      for j := i+1 to N-1 do
      begin
        if XValues[i] > XValues[j] then // swap
        begin
          temp := XValues[i];
          XValues[i] := XValues[j];
          XValues[j] := temp;
          for k := 0 to NoY-1 do
          begin
            temp := YValues[i,k];
            YValues[i,k] := YValues[j,k];
            YValues[j,k] := temp;
          end;
        end;
      end;
    end;
    PlotXY(XValues, YValues, MaxX, MinX, MaxY, MinY, N, NoY);

  finally
    lReport.Free;
    RMatrix := nil;
    StdDevs := nil;
    Variances := nil;
    Means := nil;
    XValues := nil;
    YValues := nil;
    selected := nil;
    ColLabels := nil;
    RowLabels := nil;
  end;
end;

procedure TXvsMultYForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TXvsMultYForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TXvsMultYForm.XInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (XEdit.Text = '') then
  begin
    XEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TXvsMultYForm.XOutBtnClick(Sender: TObject);
begin
  if (XEdit.Text <> '') then
  begin
    VarList.Items.Add(XEdit.Text);
    XEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TXvsMultYForm.YInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < VarList.Items.Count do
  begin
    if VarList.Selected[i] then
    begin
      YBox.Items.Add(VarList.Items[i]);
      VarList.Items.Delete(i);
      i := 0;
    end else
      inc(i);
  end;
  UpdateBtnStates;
end;

procedure TXvsMultYForm.YOutBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := 0;
  while i < YBox.Items.Count do
  begin
    if (YBox.Selected[i]) then
    begin
      VarList.Items.Add(YBox.Items[i]);
      YBox.Items.Delete(i);
      i := 0;
    end else
      i := i + 1;
  end;
  UpdateBtnStates;
end;

// routine to plot X versus multiple Y values
procedure TXvsMultYForm.PlotXY(XValues: DblDyneVec; YValues: DblDyneMat;
   MaxX, MinX, MaxY, MinY: double; N, NoY: integer);
var
  i, j, xpos, ypos, hleft, hright, vtop, vbottom, imagewide: integer;
  vhi, hwide, offset, strhi, imagehi: integer;
  valincr, Yvalue, Xvalue: double;
  Title: string;
begin
  Title := PlotTitleEdit.Text;
  BlankFrm.Caption := Title;
  BlankFrm.Show;

  imagewide := BlankFrm.Image1.Width;
  imagehi := BlankFrm.Image1.Height;
  vtop := 40;
  vbottom := round(imagehi) - 60;
  vhi := vbottom - vtop;
  hleft := 100;
  hright := imagewide - 80;
  hwide := hright - hleft;

  // Draw chart border and background
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Rectangle(0, 0, imagewide, imagehi);

  // Draw title
  Title := PlotTitleEdit.Text;
  if Title <> '' then
  begin
    xpos := (imagewide - BlankFrm.Image1.Canvas.TextWidth(Title)) div 2;
    yPos := 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  end;

  // draw horizontal axis
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.MoveTo(hleft,vbottom);
  BlankFrm.Image1.Canvas.LineTo(hright,vbottom);
  valincr := (maxX - minX) / 10.0;
  for i := 1 to 11 do
  begin
    ypos := vbottom;
    Xvalue := minX + valincr * (i - 1);
    xpos := hleft + round(hwide * ((Xvalue - minX) / (maxX - minX)));
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    ypos := ypos + 10;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
    Title := Format('%.2f', [Xvalue]);
    offset := BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
    xpos := xpos - offset;
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  end;
  xpos := hleft + (hwide - BlankFrm.Image1.Canvas.TextWidth(XEdit.Text)) div 2;
  ypos := vbottom + 30;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos, XEdit.Text);

  // draw vertical axis
  Title := 'Y VALUES';
  xpos := hleft - BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
  ypos := 8;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  xpos := hleft;
  ypos := vtop;
  BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
  ypos := vbottom;
  BlankFrm.Image1.Canvas.LineTo(xpos, ypos);
  valincr := (maxY - minY) / 10.0;
  for i := 1 to 11 do
  begin
    Title := Format('%.2f',[maxY - ((i-1)*valincr)]);
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    xpos := hleft - 20 - BlankFrm.Image1.Canvas.TextWidth(Title);
    Yvalue := maxY - (valincr * (i-1));
    ypos := round(vhi * ( (maxY - Yvalue) / (maxY - minY)));
    ypos := ypos + vtop - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
    xpos := hleft;
    ypos := ypos + strhi div 2;
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    xpos := hleft - 10;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
  end;

  // draw points for x and y pairs
  for j := 0 to NoY-1 do
  begin
    BlankFrm.Image1.Canvas.Brush.Style := bsSolid;
    BlankFrm.Image1.Canvas.Brush.Color := DATA_COLORS[j mod Length(DATA_COLORS)];
    BlankFrm.Image1.Canvas.Pen.Color := DATA_COLORS[j mod Length(DATA_COLORS)];
    BlankFrm.Image1.Canvas.Font.Color := DATA_COLORS[j mod Length(DATA_COLORS)];
    Title := Trim(OS3MainFrm.DataGrid.Cells[selected[j],0]);
    for i := 1 to N do
    begin
      ypos := vtop + round(vhi * ( (maxY - YValues[i-1,j]) / (maxY - minY)));
      xpos := hleft + round(hwide * ( (XValues[i-1]-minX) / (maxX - minX)));
      if xpos < hleft then xpos := hleft;
      if i = 1 then
        BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
      if LinesBox.Checked then
        BlankFrm.Image1.Canvas.LineTo(xpos, ypos);
      BlankFrm.Image1.Canvas.Ellipse(xpos, ypos, xpos+5, ypos+5);
    end;
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    BlankFrm.Image1.Canvas.Brush.Color := clWhite;
    xpos := hwide + hleft;
    BlankFrm.Image1.Canvas.MoveTo(xpos, ypos-strhi);
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  end;

  BlankFrm.Image1.Canvas.Font.Color := clBlack;
end;

procedure TXvsMultYForm.UpdateBtnStates;
begin
end;

initialization
  {$I xvsmultyunit.lrs}

end.

