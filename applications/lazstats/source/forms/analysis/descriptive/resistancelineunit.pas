// Use file "Sickness.laz" for testing

unit ResistanceLineUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Printers,
  MainUnit, Globals, FunctionsLib, OutputUnit, DataProcs, DictionaryUnit,
  ContextHelpUnit, BlankFrmUnit;

type

  { TResistanceLineForm }

  TResistanceLineForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    HorCenterBevel: TBevel;
    GridChk: TCheckBox;
    Memo1: TLabel;
    PlotMediansChk: TCheckBox;
    StdCorChk: TCheckBox;
    PointsChk: TCheckBox;
    ConfChk: TCheckBox;
    ConfEdit: TEdit;
    DescChk: TCheckBox;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    LineChk: TCheckBox;
    VarList: TListBox;
    MeansChk: TCheckBox;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    XInBtn: TBitBtn;
    YInBtn: TBitBtn;
    XOutBtn: TBitBtn;
    YOutBtn: TBitBtn;
    XEdit: TEdit;
    YEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure StdCorChkChange(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure XInBtnClick(Sender: TObject);
    procedure XOutBtnClick(Sender: TObject);
    procedure YInBtnClick(Sender: TObject);
    procedure YOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    function Median(var X: DblDyneVec; ASize: integer): double;
    procedure PlotXY(var Xpoints, YPoints, UpConf, LowConf: DblDyneVec;
      ConfBand: double; Xmean, Ymean, R, Slope, Intercept: double;
      Xmax, Xmin, Ymax, Ymin: double; N, PlotNo: integer);
    procedure UpdateBtnStates;

  public
    { public declarations }
  end; 

var
  ResistanceLineForm: TResistanceLineForm;

implementation

uses
  Math;

{ TResistanceLineForm }

procedure TResistanceLineForm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  StdCorChk.Checked := false;
  GridChk.Checked := false;
  PlotMediansChk.Checked := false;
  XEdit.Text := '';
  YEdit.Text := '';
  VarList.Clear;
  ConfEdit.Text := FormatFloat('0.0', DEFAULT_CONFIDENCE_LEVEL_PERCENT);
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TResistanceLineForm.StdCorChkChange(Sender: TObject);
begin
  if StdCorChk.Checked then GroupBox1.Enabled := true else GroupBox1.Enabled := false;
end;

procedure TResistanceLineForm.ComputeBtnClick(Sender: TObject);
var
  XYPoints : DblDyneMat;
  XMedians : DblDyneVec;
  YMedians : DblDyneVec;
  XVector, YVector : DblDyneVec;
  cellstring, outline : string;
  ColNoSelected : IntDyneVec;
  UpConf  : DblDyneVec;
  lowConf : DblDyneVec;
  GrpSize : IntDyneVec;
  Xcol, Ycol, N, NoSelected, i, j, size, size1, size2, size3 : integer;
  X, Y, tempX, tempY : double;
  Xmin, Xmax, Ymin, Ymax, SSx, t, DF : double;
  Xmean, Ymean, Xvariance, Yvariance, Xstddev, Ystddev, ConfBand : double;
  R, SEPred, Slope, Intercept, predicted, sedata : double;
  slope1, slope2 : double;
  c, c1, c2, c3 : double; // constants obtained from control points
  lReport: TStrings;
begin
  SetLength(XYPoints, NoCases, NoCases);
  SetLength(XMedians, 3);
  SetLength(YMedians, 3);
  SetLength(XVector, NoCases);
  SetLength(YVector, NoCases);
  SetLength(ColNoSelected, NoVariables);
  SetLength(UpConf, NoCases + 1);
  SetLength(lowConf, NoCases + 1);
  SetLength(GrpSize, 3);
  Xcol := 0;
  Ycol := 0;
  Xmax := -1.0e20;
  Xmin := 1.0e20;
  Ymax := -1.0e20;
  Ymin := 1.0e20;
  Xmean := 0.0;
  Ymean := 0.0;
  Xvariance := 0.0;
  Yvariance := 0.0;
  R := 0.0;

  for i := 1 to Novariables do
  begin
    cellstring := OS3MainFrm.DataGrid.Cells[i,0];
    if cellstring = XEdit.Text then Xcol := i;
    if cellstring = YEdit.Text then Ycol := i;
  end;
  NoSelected := 2;
  ColNoSelected[0] := Xcol;
  ColNoSelected[1] := Ycol;
  N := 0;
  for i := 1 to NoCases do
  begin
    if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
    X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[Xcol,i]));
    Y := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[Ycol,i]));
    if X > Xmax then Xmax := X;
    if X < Xmin then Xmin := X;
    if Y > Ymax then Ymax := Y;
    if Y < Ymin then Ymin := Y;
    Xmean := Xmean + X;
    Ymean := Ymean + Y;
    Xvariance := Xvariance + X * X;
    Yvariance := Yvariance + Y * Y;
    R := R + X * Y;
    XYPoints[N,0] := X;
    XYPoints[N,1] := Y;
    inc(N);
  end;

  // sort on X values
  for i := 0 to N-2 do
  begin
    for j := i + 1 to N-1 do
    begin
      if XYPoints[i,0] > XYPoints[j,0] then // swap
      begin
        tempX := XYPoints[i,0];
        tempY := XYPoints[i,1];
        XYPoints[i,0] := XYPoints[j,0];
        XYPoints[i,1] := XYPoints[j,1];
        XYPoints[j,0] := tempX;
        XYPoints[j,1] := tempY;
      end;
    end;
  end;

  // calculate statistics
  Xvariance := Xvariance - Xmean * Xmean / N;
  SSx := Xvariance;
  Xvariance := Xvariance / (N - 1);
  Xstddev := sqrt(Xvariance);

  Yvariance := Yvariance - Ymean * Ymean / N;
  Yvariance := Yvariance / (N - 1);
  Ystddev := sqrt(Yvariance);

  R := R - (Xmean * Ymean / N);
  R := R / (N - 1);
  R := R / (Xstddev * Ystddev);

  SEPred := sqrt(1.0 - (R * R)) * Ystddev;
  SEPred := SEPred * sqrt((N - 1) / (N - 2));

  Xmean := Xmean / N;
  Ymean := Ymean / N;
  Slope := R * Ystddev / Xstddev;
  Intercept := Ymean - Slope * Xmean;

  // Now, print the descriptive statistics if requested
  lReport := TStringList.Create;
  try
    if DescChk.Checked then
    begin
      lReport.Add('Original X versus Y Plot Data');
      lReport.Add('');
      lReport.Add('X = %s, Y = %s from file: %s',[
        Xedit.Text, YEdit.Text, OS3MainFrm.FileNameEdit.Text
      ]);
      lReport.Add('');
      lReport.Add('Variable     Mean   Variance  Std.Dev.');
      lReport.Add('%-10s%8.2f  %8.2f  %8.2f', [XEdit.Text, Xmean, Xvariance, Xstddev]);
      lReport.Add('%-10s%8.2f  %8.2f  %8.2f', [YEdit.Text, Ymean, Yvariance, Ystddev]);
      lReport.Add('');
      lReport.Add('Correlation:                %8.4f', [R]);
      lReport.Add('Slope:                      %8.2f', [Slope]);
      lReport.Add('Intercept:                  %8.2f', [Intercept]);
      lReport.Add('Standard Error of Estimate: %8.2f', [SEPred]);
      lReport.Add('Number of good cases:       %8d', [N]);
      lReport.Add('');
    end;

    // get upper and lower confidence points for each X value
    if ConfChk.Checked then
    begin
      ConfBand := StrToFloat(ConfEdit.Text) / 100.0;
      DF := N - 2;
      t := inverset(ConfBand,DF);
      for i := 1 to N do
      begin
        X := XYpoints[i-1,0];
        predicted := slope * X + intercept;
        sedata := SEPred * sqrt(1.0 + (1.0 / N) + (sqr(X - Xmean) / SSx));
        UpConf[i] := predicted + (t * sedata);
        lowConf[i] := predicted - (t * sedata);
        if UpConf[i] > Ymax then Ymax := UpConf[i];
        if lowConf[i] < Ymin then Ymin := lowConf[i];
      end;
    end else
      ConfBand := 0.0;

    // plot the values (and optional line and confidence band if elected)
    if PointsChk.Checked then
    begin
      for i := 0 to N-1 do
      begin
        XVector[i] := XYPoints[i,0];
        YVector[i] := XYPoints[i,1];
      end;
      PlotXY(
        XVector, YVector, UpConf, LowConf, ConfBand, Xmean, Ymean, R,
        Slope, Intercept, Xmax, Xmin, Ymax, Ymin, N, 1
      );
    end;
    //LineChk.Checked := false;
    //ConfChk.Checked := false;
    ConfBand := 0.0;

    // Now do the resistant line analysis
    // obtain 1/3 size
    size := n div 3;
    size1 := size;
    size3 := size;
    size2 := n - size1 - size3;
    GrpSize[0] := size1;
    GrpSize[1] := size2;
    GrpSize[2] := size3;

    // get median for each group of x and y values
    // first group:
    for i := 0 to size1-1 do
    begin
      XVector[i] := XYPoints[i,0];
      YVector[i] := XYPoints[i,1];
    end;
    XMedians[0] := Median(XVector,size1);
    YMedians[0] := Median(YVector,size1);

    // second group
    j := 0;
    for i := size1 to size1 + size2 - 1 do
    begin
      XVector[j] := XYPoints[i,0];
      YVector[j] := XYPoints[i,1];
      inc(j);
    end;
    XMedians[1] := Median(XVector,size2);
    YMedians[1] := Median(YVector,size2);

    // third group
    j := 0;
    for i := (size1 + size2) to N-1 do
    begin
      XVector[j] := XYPoints[i,0];
      YVector[j] := XYPoints[i,1];
      inc(j);
    end;
    XMedians[2] := Median(XVector,size3);
    YMedians[2] := Median(YVector,size3);

    lReport.Add('Group   X Median    Y Median    Size');
    for i := 0 to 2 do
      lReport.Add('%3d     %5.3f     %5.3f     %d', [i+1, XMedians[i], YMedians[i], GrpSize[i]]);
    lReport.Add('');

    slope1 := (YMedians[1] - YMedians[0]) / (XMedians[1] - XMedians[0]);
    slope2 := (YMedians[2] - YMedians[1]) / (XMedians[2] - XMedians[1]);
    lReport.Add('Half Slopes:          %10.3f and %.3f', [slope1, slope2]);

    Slope := (YMedians[2] - YMedians[0]) / (XMedians[2] - XMedians[0]);
    lReport.Add('Slope:                %10.3f', [Slope]);

    tempx := slope2 / slope1;
    lReport.Add('Ratio of half slopes: %10.3f',[tempx]);

    // obtain estimate of the constant for the prediction equation
    c1 := slope * XMedians[0] - YMedians[0];
    c2 := slope * XMedians[1] - YMedians[1];
    c3 := slope * XMedians[2] - YMedians[2];
    c := (c1 + c2 + c3) / 3.0;
    lReport.Add('Equation:  y := %.3f * X + (%.3f)', [slope, c]);

    if GridChk.Checked then
    begin
      // Get the residuals (Y - predicted Y) for each X value and place in the grid
      outline := 'Pred.' + OS3MainFrm.DataGrid.Cells[Ycol,0];
      DictionaryFrm.NewVar(NoVariables+1);
      DictionaryFrm.DictGrid.Cells[1,NoVariables] := outline;
      OS3MainFrm.DataGrid.Cells[NoVariables,0] := outline;

      outline := 'Residual';
      DictionaryFrm.NewVar(NoVariables+1);
      DictionaryFrm.DictGrid.Cells[1,NoVariables] := outline;
      OS3MainFrm.DataGrid.Cells[NoVariables,0] := outline;

      for i := 1 to NoCases do
      begin
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[Xcol,i]));
        Y := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[Ycol,i]));
        if c >= 0 then
          predicted := slope * X + c
        else
          predicted := slope * X - c;
        Y := Y - predicted;  // residual
        outline := Format('%9.3f',[predicted]);
        OS3MainFrm.DataGrid.Cells[NoVariables-1,i] := outline;
        outline := Format('%9.3f',[Y]);
        OS3MainFrm.DataGrid.Cells[NoVariables,i] := outline;
      end;
    end;

    DisplayReport(lReport);

    // plot the values (and optional line and confidence band if elected)
    if PlotMediansChk.Checked then
      PlotXY(
        XMedians, YMedians, UpConf, LowConf, ConfBand, Xmean, Ymean, R,
        Slope, Intercept, Xmax, Xmin, Ymax, Ymin, 3, 2
      );

  finally
     lReport.Free;
     GrpSize := nil;
     LowConf := nil;
     UpConf := nil;
     ColNoSelected := nil;
     YVector := nil;
     XVector := nil;
     YMedians := nil;
     XMedians := nil;
     XYPoints := nil;
  end;
end;

procedure TResistanceLineForm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  //VarList.Constraints.MinWidth := XEdit.Width;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TResistanceLineForm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);

  if BlankFrm = nil then Application.CreateForm(TBlankFrm, BlankFrm);
  if DictionaryFrm = nil then Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TResistanceLineForm.XInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (XEdit.Text = '') then
  begin
    XEdit.Text := VarList.items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TResistanceLineForm.XOutBtnClick(Sender: TObject);
begin
  if XEdit.Text <> '' then
  begin
    VarList.Items.Add(XEdit.Text);
    XEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TResistanceLineForm.YInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (YEdit.Text = '') then
  begin
    YEdit.Text := VarList.items[index];
    VarList.Items.Delete(index);
  end;
  UpdateBtnStates;
end;

procedure TResistanceLineForm.YOutBtnClick(Sender: TObject);
begin
  if YEdit.Text <> '' then
  begin
    VarList.Items.Add(YEdit.Text);
    YEdit.Text := '';
  end;
  UpdateBtnStates;
end;

function TResistanceLineForm.Median(VAR X: DblDyneVec; ASize: integer): double;
var
  midpt: integer;
  value: double;
  i, j: integer;
begin
  // sort values
  for i := 0 to ASize-2 do
  begin
    for j := i + 1 to ASize-1 do
    begin
      if X[i] > X[j] then // swap
      begin
        value := X[i];
        X[i] := X[j];
        X[j] := value;
      end;
    end;
  end;

  if ASize > 2 then
  begin
    midpt := ASize div 2;
    if 2 * midpt = ASize then  // even no. of values
    begin
      value := (X[midpt-1] + X[midpt]) / 2;
    end else
      value := X[midpt];  // odd no. of values
    Median := value;
  end else
  if ASize = 2 then
    Median := (X[0] + X[1]) / 2;

  Result := Median;
end;

procedure TResistanceLineForm.PlotXY(var Xpoints, Ypoints, UpConf, LowConf: DblDyneVec;
  ConfBand, XMean, YMean, R, Slope, Intercept: double;
  Xmax, Xmin, Ymax, Ymin: double; N, PlotNo: integer);
var
  i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide: integer;
  vhi, hwide, offset, strhi, imagehi: integer;
  valincr, Yvalue, Xvalue: double;
  Title: string;
  YU, YL, XU, XL: double;
begin
     BlankFrm.Image1.Canvas.Clear;
     if PlotNo = 1 then
     begin
          Title := 'X versus Y PLOT Using File: ' + OS3MainFrm.FileNameEdit.Text;
          BlankFrm.Caption := Title;
     end
     else
     begin
          Title := 'Median Plot for three groups';
          BlankFrm.Caption := Title;
     end;
     imagewide := BlankFrm.Image1.Width;
     imagehi := BlankFrm.Image1.Height;
     vtop := 40;
     vbottom := round(imagehi) - 80;
     vhi := vbottom - vtop;
     hleft := 100;
     hright := imagewide - 80;
     hwide := hright - hleft;
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;

     // Draw chart border
     BlankFrm.Image1.Canvas.Rectangle(0,0,imagewide,imagehi);

     // draw Means
     if MeansChk.Checked then
     begin
          ypos := round(vhi * ( (Ymax - Ymean) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          xpos := hright;
          BlankFrm.Image1.Canvas.Pen.Color := clGreen;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          Title := 'MEAN ';
          Title := Title + YEdit.Text;
          strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
          ypos := ypos - strhi div 2;
          BlankFrm.Image1.Canvas.Brush.Color := clWhite;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

          xpos := round(hwide * ( (Xmean - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          ypos := vtop;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          ypos := vbottom;
          BlankFrm.Image1.Canvas.Pen.Color := clGreen;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          Title := 'MEAN ';
          Title := Title + XEdit.Text;
          strhi := BlankFrm.Image1.Canvas.TextWidth(Title);
          xpos := xpos - strhi div 2;
          ypos := vtop - BlankFrm.Image1.Canvas.TextHeight(Title);
          BlankFrm.Image1.Canvas.Brush.Color := clWhite;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
     end;

     // draw slope line
     if LineChk.Checked then
     begin
          BlankFrm.Image1.Canvas.Pen.Color := clBlack;
          Yvalue := (Xpoints[0] * slope) + intercept; // predicted score
          ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[0]- Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          Yvalue := (Xpoints[N-1] * slope) + intercept; // predicted score
          ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[N-1] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     end;

     // draw horizontal axis
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.MoveTo(hleft,vbottom);
     BlankFrm.Image1.Canvas.LineTo(hright,vbottom);
     valincr := (Xmax - Xmin) / 10.0;
     for i := 1 to 11 do
     begin
          ypos := vbottom;
          Xvalue := Xmin + valincr * (i - 1);
          xpos := round(hwide * ((Xvalue - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          ypos := ypos + 10;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          Title := format('%.2f',[Xvalue]);
          offset := BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
          xpos := xpos - offset;
          BlankFrm.Image1.Canvas.Pen.Color := clBlack;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
     end;
     if PlotNo = 1 then
     begin
          xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(XEdit.Text) div 2);
          ypos := vbottom + 20;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,XEdit.Text);
          Title := format('R(X,Y) = %.3f, Slope = %.2f, Intercept = %.2f',
              [R,Slope,Intercept]);
          xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(Title) div 2);
          ypos := ypos + 15;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
     end;

     // Draw vertical axis
     Title := YEdit.Text;
     xpos := hleft - BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
     ypos := vtop - BlankFrm.Image1.Canvas.TextHeight(Title) - 10;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,YEdit.Text);
     xpos := hleft;
     ypos := vtop;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     ypos := vbottom;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     valincr := (Ymax - Ymin) / 10.0;
     for i := 1 to 11 do
     begin
          Title := format('%.2f',[Ymax - ((i-1)*valincr)]);
          strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
          xpos := hLeft - 20 - BlankFrm.Image1.Canvas.TextWidth(Title); //10;
          Yvalue := Ymax - (valincr * (i-1));
          ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
          ypos := ypos + vtop - strhi div 2;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
          xpos := hleft;
          ypos := ypos + strhi div 2;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          xpos := hleft - 10;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     end;

     // draw points for x and y pairs
     for i := 0 to N-1 do
     begin
          ypos := round(vhi * ( (Ymax - Ypoints[i]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.Brush.Color := clYellow;
          BlankFrm.Image1.Canvas.Brush.Style := bsSolid;
          BlankFrm.Image1.Canvas.Pen.Color := clNavy;
          BlankFrm.Image1.Canvas.Ellipse(xpos,ypos,xpos+5,ypos+5);
          if ((PlotNo = 2) and (i = 0)) then
          begin
               BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
               BlankFrm.Image1.Canvas.TextOut(xpos,ypos,'M1');
          end;
          if ((PlotNo = 2) and (i > 0)) then
          begin
               BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
               Title := format('M%d',[i+1]);
               BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
          end;
     end;
     if ((PlotNo = 2) and (i > 0)) then
     begin // draw slope line
          BlankFrm.Image1.Canvas.Pen.Color := clRed;
          ypos := round(vhi * ( (Ymax - Ypoints[0]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[0] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          YL := Ypoints[0];
          XL := xpoints[0];
          ypos := round(vhi * ( (Ymax - Ypoints[2]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[2] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          YU := Ypoints[2];
          XU := xpoints[2];
          slope := (YU - YL) / (XU - XL);
          ypos := vbottom + 20;
          BlankFrm.Image1.Canvas.Brush.Color := clYellow;
          Title := format('Slope = %.2f',[Slope]);
          xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(Title) div 2);
          ypos := ypos + 15;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
     end;

     // draw confidence bands if requested
     if ConfBand <> 0.0 then
     begin
          BlankFrm.Image1.Canvas.Pen.Color := clRed;
          ypos := round(vhi * ((Ymax - UpConf[1]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[0] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          for i := 2 to N do
          begin
               ypos := round(vhi * ((Ymax - UpConf[i]) / (Ymax - Ymin)));
               ypos := ypos + vtop;
               xpos := round(hwide * ( (Xpoints[i-1] - Xmin) / (Xmax - Xmin)));
               xpos := xpos + hleft;
               BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          end;
          ypos := round(vhi * ((Ymax - lowConf[1]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[0] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          for i := 2 to N do
          begin
               ypos := round(vhi * ((Ymax - lowConf[i]) / (Ymax - Ymin)));
               ypos := ypos + vtop;
               xpos := round(hwide * ( (Xpoints[i-1] - Xmin) / (Xmax - Xmin)));
               xpos := xpos + hleft;
               BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          end;
     end;
     BlankFrm.ShowModal;
end;

procedure TResistanceLineForm.UpdateBtnStates;
begin
  XInBtn.Enabled := (VarList.ItemIndex > -1) and (XEdit.Text = '');
  YInBtn.Enabled := (VarList.ItemIndex > -1) and (YEdit.Text = '');
  XOutBtn.Enabled := (XEdit.Text <> '');
  YOutBtn.Enabled := (YEdit.Text <> '');
end;

procedure TResistanceLineForm.VarListSelectionChange(Sender: TObject;
  User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I resistancelineunit.lrs}

end.

