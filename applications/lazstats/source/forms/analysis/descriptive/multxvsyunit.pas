// Use file "BubblePlot2.laz" for testing

unit MultXvsYUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Clipbrd,
  MainUnit, Globals, OutputUnit, DataProcs, DictionaryUnit, ContextHelpUnit;

type

  { TMultXvsYFrm }

  TMultXvsYFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    XInBtn: TBitBtn;
    XOutBtn: TBitBtn;
    YInBtn: TBitBtn;
    YOutBtn: TBitBtn;
    GroupInBtn: TBitBtn;
    GroupOutBtn: TBitBtn;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DescChk: TCheckBox;
    LinesChk: TCheckBox;
    XEdit: TEdit;
    YEdit: TEdit;
    GroupEdit: TEdit;
    GroupBox1: TGroupBox;
    LabelEdit: TEdit;
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
    procedure GroupInBtnClick(Sender: TObject);
    procedure GroupOutBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure XInBtnClick(Sender: TObject);
    procedure XOutBtnClick(Sender: TObject);
    procedure YInBtnClick(Sender: TObject);
    procedure YOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure PlotXY(var XValues: DblDyneMat; YValues: DblDyneMat;
      MaxX, MinX, MaxY, MinY: double; N, NoY, MinGrp: integer);
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  MultXvsYFrm: TMultXvsYFrm;

implementation

uses
  Math,
  BlankFrmUnit;

{ TMultXvsYFrm }

procedure TMultXvsYFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
        VarList.Clear;
        for i := 1 to NoVariables do
          VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
        XEdit.Text := '';
        YEdit.Text := '';
        GroupEdit.Text := '';
        DescChk.Checked := false;
        LinesChk.Checked := false;
        XInBtn.Enabled := true;
        YInBtn.Enabled := true;
        GroupInBtn.Enabled := true;
        XOutBtn.Enabled := false;
        YOutBtn.Enabled := false;
        GroupOutBtn.Enabled := false;
end;

procedure TMultXvsYFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TMultXvsYFrm.GroupInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := VarList.ItemIndex;
  if (i > -1) and (GroupEdit.Text = '') then
  begin
    GroupEdit.Text := VarList.Items[i];
    VarList.Items.Delete(i);
  end;
  UpdateBtnStates;
end;

procedure TMultXvsYFrm.ComputeBtnClick(Sender: TObject);
var
  i, j, k, N, NoGrps, XCol, YCol, GrpCol, Grp, MinGrp, MaxGrp: integer;
  NoSelected, MaxGrpSize: integer;
  selected, NoInGrp: IntDyneVec;
  YValues, XValues: DblDyneMat;
  Means, StdDevs: DblDyneVec;
  MinX, MaxX, MinY, MaxY, X, Y, temp: double;
  cellstring: string;
  lReport: TStrings;
begin
  MaxGrpSize := 0;
  SetLength(selected, 3);
  MaxX := -1.0e308;
  MinX := 1.0e308;
  MaxY := -1.0e308;
  MinY := 1.0e308;
  MinGrp := MaxInt;
  MaxGrp := -MaxInt;
  XCol := 0;
  YCol := 0;
  GrpCol := 0;
  N := 0;

  // Get selected variables
  for i := 1 to NoVariables do
  begin
    cellstring  :=  OS3MainFrm.DataGrid.Cells[i,0];
    if (cellstring = XEdit.Text) then selected[0] := i;
    if (cellstring = YEdit.Text) then selected[1] := i;
    if (cellstring = GroupEdit.Text) then selected[2] := i;
  end;

  XCol := selected[0];
  YCol := selected[1];
  GrpCol := selected[2];
  NoSelected := 3;

  if (XCol = 0) or (YCol = 0) or (GrpCol = 0) then
  begin
    MessageDlg('No variable selected.', mtError, [mbOK], 0);
    exit;
  end;

  // Get number of groups
  for i := 1 to NoCases do
  begin
    Grp := StrToInt(OS3MainFrm.DataGrid.Cells[GrpCol,i]);
    if (Grp > MaxGrp) then MaxGrp := Grp;
    if (Grp < MinGrp) then MinGrp := Grp;
  end;
  NoGrps := (MaxGrp - MinGrp) + 1;

  lReport := TStringList.Create;
  try
    lReport.Add('X VERSUS Y FOR GROUPS PLOT');
    lReport.Add('');

    SetLength(YValues, NoCases+1, NoGrps+1);
    SetLength(XValues, NoCases+1, NoGrps+1);
    SetLength(Means, 2);
    SetLength(StdDevs, 2);
    SetLength(NoInGrp, NoGrps);

    for i := 0 to 1 do
    begin
      Means[i] := 0.0;
      StdDevs[i] := 0.0;
    end;
    for i := 0 to NoGrps - 1 do
      NoInGrp[i] := 0;

    for i := 1 to NoCases do
    begin
      if (not GoodRecord(i,NoSelected,selected))then continue;
      inc(N);
      X := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol,i]);
      if (X > MaxX) then MaxX := X;
      if (X < MinX) then MinX := X;

      Y := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
      if (Y > MaxY) then MaxY := Y;
      if (Y < MinY) then MinY := Y;

      Grp := StrToInt(OS3MainFrm.DataGrid.Cells[GrpCol,i]);
      Grp := Grp - MinGrp;
      NoInGrp[Grp] := NoInGrp[Grp] + 1;
      if (NoInGrp[Grp] > MaxGrpSize) then MaxGrpSize := NoInGrp[Grp];
      YValues[NoInGrp[Grp]-1,Grp] := Y;
      XValues[NoInGrp[Grp]-1,Grp] := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol,i]);
    end;

    // get descriptive data
    if (DescChk.Checked) then
    begin
      for i := 1 to NoCases do
      begin
        if (not GoodRecord(i,NoSelected,selected)) then continue;
        Y := StrToFloat(OS3MainFrm.DataGrid.Cells[YCol,i]);
        X := StrToFloat(OS3MainFrm.DataGrid.Cells[XCol,i]);
        Means[0] := Means[0] + X;
        StdDevs[0] := StdDevs[0] + X * X;
        Means[1] :=  Means[1] + Y;
        StdDevs[1] := StdDevs[1] + Y * Y;
      end;

      for i := 0 to 1 do
      begin
        StdDevs[i] := StdDevs[i] - (Means[i] * Means[i]) / N;
        StdDevs[i] := sqrt(StdDevs[i] / (N - 1));
        Means[i] := Means[i] / N;
      end;

      lReport.Add('VARIABLE    MEAN   STANDARD DEVIATION');
      lReport.Add('   X   %9.3f %14.3f', [Means[0], StdDevs[0]]);
      lReport.Add('   Y   %9.3f %14.3f', [Means[1], StdDevs[1]]);
      lReport.Add('');

      DisplayReport(lReport);
    end;

    // sort on X
    for i := 0 to NoGrps - 1 do
    begin
      for j := 0 to MaxGrpSize-2 do
      begin
        for k := j+1 to MaxGrpSize - 1 do
        begin
          if (XValues[j,i] > XValues[k,i]) then // swap
          begin
            temp := XValues[j,i];
            XValues[j,i] := XValues[k,i];
            XValues[k,i] := temp;
            temp := YValues[j,i];
            YValues[j,i] := YValues[k,i];
            YValues[k,i] := temp;
          end;
        end;
      end;
    end;

    BlankFrm.Image1.Canvas.Clear;
    BlankFrm.Show;
    PlotXY(XValues, YValues, MaxX, MinX, MaxY, MinY, MaxGrpSize, NoGrps, MinGrp);

  finally
    lReport.Free;
    NoInGrp := nil;
    StdDevs := nil;
    Means := nil;
    XValues := nil;
    YValues := nil;
  end;
end;

procedure TMultXvsYFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TMultXvsYFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
  if BlankFrm = nil then Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TMultXvsYFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TMultXvsYFrm.GroupOutBtnClick(Sender: TObject);
begin
  if GroupEdit.Text <> '' then
  begin
    VarList.Items.Add(GroupEdit.Text);
    GroupEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TMultXvsYFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TMultXvsYFrm.XInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := VarList.ItemIndex;
  if (i > -1) and (XEdit.Text = '') then
  begin
    XEdit.Text := VarList.Items[i];
    VarList.Items.Delete(i);
  end;
  UpdateBtnStates;
end;

procedure TMultXvsYFrm.XOutBtnClick(Sender: TObject);
begin
  if XEdit.Text <> '' then
  begin
    VarList.Items.Add(XEdit.Text);
    XEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TMultXvsYFrm.YInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := VarList.ItemIndex;
  if (i > -1) and (YEdit.Text = '') then
  begin
    YEdit.Text := VarList.Items[i];
    VarList.Items.Delete(i);
  end;
  UpdateBtnStates;
end;

procedure TMultXvsYFrm.YOutBtnClick(Sender: TObject);
begin
  if YEdit.Text <> '' then
  begin
    VarList.Items.Add(YEdit.Text);
    YEdit.Text := '';
  end;
  UpdateBtnStates;
end;

// routine to plot X versus multiple Y values
procedure TMultXvsYFrm.plotxy(var XValues: DblDyneMat; YValues: DblDyneMat;
  MaxX, MinX, MaxY, MinY: double;  N, NoY, MinGrp: integer);
var
  xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
  vhi, hwide, offset, strhi, imagehi, i, j, Grp : integer;
  valincr, Yvalue, Xvalue, value : double;
  Title: string;
begin
  Title := LabelEdit.Text;
  BlankFrm.Caption := Title;
  BlankFrm.Show;

  imagewide := BlankFrm.Image1.Width;
  imagehi := BlankFrm.Image1.Height;
  vtop := 40;
  vbottom := ceil(imagehi) - 60;
  vhi := vbottom - vtop;
  hleft := 100;
  hright := imagewide - 80;
  hwide := hright - hleft;

  // Draw chart border and background
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Rectangle(0, 0, imagewide, imagehi);

  // Draw title
  if Title <> '' then
  begin
    xpos := (imagewide - BlankFrm.Image1.Canvas.TextWidth(Title)) div 2;
    yPos := 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  end;

  // draw horizontal axis
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.MoveTo(hleft, vbottom);
  BlankFrm.Image1.Canvas.LineTo(hright, vbottom);
  valincr := (MaxX - MinX) / 10.0;
  for i := 1 to 11 do
  begin
    ypos := vbottom;
    Xvalue := MinX + valincr * (i - 1);
    xpos := hLeft + ceil(hwide * ((Xvalue - MinX) / (MaxX - MinX)));
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

  // Draw vertical axis
  Title := 'Y VALUES';
  xpos := hleft - BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
  ypos := 8;
  BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  xpos := hleft;
  ypos := vtop;
  BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
  ypos := vbottom;
  BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
  valincr := (MaxY - MinY) / 10.0;
  for i := 1 to 11 do
  begin
    value := MaxY - ((i-1) * valincr);
    Title := Format('%.2f',[value]);
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    xpos := hleft - 20 - BlankFrm.Image1.Canvas.TextWidth(Title);
    Yvalue := MaxY - (valincr * (i-1));
    ypos := ceil(vhi * ( (MaxY - Yvalue) / (MaxY - MinY)));
    ypos := ypos + vtop - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
    xpos := hleft;
    ypos := ypos + strhi div 2;
    BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
    xpos := hleft - 10;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
  end;

  // draw points for x and y pairs
  for j := 0 to NoY - 1 do
  begin
    BlankFrm.Image1.Canvas.Brush.Style := bsSolid;
    BlankFrm.Image1.Canvas.Brush.Color := DATA_COLORS[j mod Length(DATA_COLORS)];
    BlankFrm.Image1.Canvas.Pen.Color := DATA_COLORS[j mod Length(DATA_COLORS)];
    BlankFrm.Image1.Canvas.Font.Color := DATA_COLORS[j mod Length(DATA_COLORS)];
    Grp := MinGrp + j;
    Title := 'GROUP ' + IntToStr(Grp);
    for i := 1 to N do
    begin
      ypos := vtop + ceil(vhi * ( (MaxY - YValues[i-1,j]) / (MaxY - MinY)));
      xpos := hleft + ceil(hwide * ( (XValues[i-1,j] - MinX) / (MaxX - MinX)));
      if (i = 1) then
        BlankFrm.Image1.Canvas.MoveTo(xpos, ypos);
      if LinesChk.Checked then
        BlankFrm.Image1.Canvas.LineTo(xpos, ypos);
      BlankFrm.Image1.Canvas.Ellipse(xpos, ypos, xpos+5, ypos+5);
    end;
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    BlankFrm.Image1.Canvas.Brush.Color := clWhite;
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    xpos := hwide + hleft;
    BlankFrm.Image1.Canvas.MoveTo(xpos, ypos-strhi);
    BlankFrm.Image1.Canvas.TextOut(xpos, ypos, Title);
  end;

  BlankFrm.Image1.Canvas.Font.Color := clBlack;
end;

procedure TMultXvsYFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  lSelected := false;
  for i:=0 to VarList.Items.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;

  XInBtn.Enabled := lSelected and (XEdit.Text = '');
  YInBtn.Enabled := lSelected and (YEdit.Text = '');
  GroupInBtn.Enabled := lSelected and (GroupEdit.Text = '');
  XOutBtn.Enabled := (XEdit.Text <> '');
  YOutBtn.Enabled := (YEdit.Text <> '');
  GroupOutBtn.Enabled := (GroupEdit.Text <> '');
end;

initialization
  {$I multxvsyunit.lrs}

end.

