// Use file "cansas.laz" for testing

unit PlotXYUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  MainUnit, Globals, OutputUnit, FunctionsLib, DataProcs, BlankFrmUnit;

type

  { TPlotXYFrm }

  TPlotXYFrm = class(TForm)
    Bevel1: TBevel;
    ConfEdit: TEdit;
    Label4: TLabel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    DescChk: TCheckBox;
    LineChk: TCheckBox;
    MeansChk: TCheckBox;
    ConfChk: TCheckBox;
    GroupBox1: TGroupBox;
    YEdit: TEdit;
    Label3: TLabel;
    XEdit: TEdit;
    Label2: TLabel;
    XinBtn: TBitBtn;
    XOutBtn: TBitBtn;
    YInBtn: TBitBtn;
    YOutBtn: TBitBtn;
    Label1: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
    procedure XinBtnClick(Sender: TObject);
    procedure XOutBtnClick(Sender: TObject);
    procedure YInBtnClick(Sender: TObject);
    procedure YOutBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure PlotXY(VAR Xpoints : DblDyneVec;
                     VAR Ypoints : DblDyneVec;
                     VAR UpConf : DblDyneVec;
                     VAR LowConf : DblDyneVec;
                     ConfBand : double;
                     Xmean, Ymean , R : double;
                     Slope, Intercept : double;
                     Xmax, Xmin, Ymax, Ymin : double;
                     N : integer);

    {
    procedure pplotxy(VAR Xpoints : DblDyneVec;
                      VAR Ypoints : DblDyneVec;
                      VAR UpConf : DblDyneVec;
                      VAR LowConf : DblDyneVec;
                      ConfBand : double;
                      Xmean, Ymean , R : double;
                      Slope, Intercept : double;
                      Xmax, Xmin, Ymax, Ymin : double;
                      N : integer);
    }
    procedure UpdateBtnStates;

    function Validate(out AMsg: String; out AControl: TWinControl;
      Xcol,Ycol: Integer): Boolean;
  public
    { public declarations }
  end; 

var
  PlotXYFrm: TPlotXYFrm;

implementation

uses
  Math;

{ TPlotXYFrm }

procedure TPlotXYFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  XEdit.Text := '';
  YEdit.Text := '';
  ConfEdit.Text := FormatFloat('0.0', DEFAULT_CONFIDENCE_LEVEL_PERCENT);
  DescChk.Checked := false;
  LineChk.Checked := false;
  MeansChk.Checked := false;
  ConfChk.Checked := false;
  //PrintChk.Checked := false;
  VarList.Items.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  UpdateBtnStates;
end;

procedure TPlotXYFrm.XinBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (XEdit.Text = '') then
  begin
    XEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TPlotXYFrm.XOutBtnClick(Sender: TObject);
begin
  if XEdit.Text <> '' then
  begin
    VarList.Items.Add(XEdit.Text);
    XEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TPlotXYFrm.YInBtnClick(Sender: TObject);
var
  index: integer;
begin
  index := VarList.ItemIndex;
  if (index > -1) and (YEdit.Text = '') then
  begin
    YEdit.Text := VarList.Items[index];
    VarList.Items.Delete(index);
    UpdateBtnStates;
  end;
end;

procedure TPlotXYFrm.YOutBtnClick(Sender: TObject);
begin
  if YEdit.Text <> '' then
  begin
    VarList.Items.Add(YEdit.Text);
    YEdit.Text := '';
    UpdateBtnStates;
  end;
end;

procedure TPlotXYFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TPlotXYFrm.ComputeBtnClick(Sender: TObject);
var
   Xmin, Xmax, Ymin, Ymax, SSx, t, DF : double;
   Xmean, Ymean, Xvariance, Yvariance, Xstddev, Ystddev, ConfBand : double;
   X, Y, R, temp, SEPred, Slope, Intercept, predicted, sedata : double;
   i, j : integer;
   Xcol, Ycol, N, NoSelected : integer;
   Xpoints : DblDyneVec;
   Ypoints : DblDyneVec;
   UpConf  : DblDyneVec;
   lowConf : DblDyneVec;
   cellstring : string;
   ColNoSelected : IntDyneVec;
   C: TWinControl;
   msg: String;
   lReport: TStrings;
begin
     SetLength(Xpoints,NoCases + 1);
     SetLength(Ypoints,NoCases + 1);
     SetLength(UpConf,NoCases + 1);
     SetLength(lowConf,NoCases + 1);
     SetLength(ColNoSelected,NoVariables);

     Xcol := 0;
     Ycol := 0;

     for i := 1 to Novariables do
     begin
          cellstring := OS3MainFrm.DataGrid.Cells[i,0];
          if cellstring = XEdit.Text then Xcol := i;
          if cellstring = YEdit.Text then Ycol := i;
     end;

     // Validation
     if not Validate(msg, C, Xcol, Ycol) then
     begin
       C.SetFocus;
       MessageDlg(msg, mtError, [mbOK], 0);
       ModalResult := mrNone;
       exit;
     end;

     NoSelected := 2;
     ColNoSelected[0] := Xcol;
     ColNoSelected[1] := Ycol;
     N := 0;
     Xmax := -1.0e20;
     Xmin := 1.0e20;
     Ymax := -1.0e20;
     Ymin := 1.0e20;
     Xmean := 0.0;
     Ymean := 0.0;
     Xvariance := 0.0;
     Yvariance := 0.0;
     R := 0.0;

     for i := 1 to NoCases do
     begin
          if Not GoodRecord(i,NoSelected,ColNoSelected) then continue;
          N := N + 1;
          X := StrToFloat(OS3MainFrm.DataGrid.Cells[Xcol,i]);
          Y := StrToFloat(OS3MainFrm.DataGrid.Cells[Ycol,i]);
          Xpoints[N] := X;
          Ypoints[N] := Y;
          if X > Xmax then Xmax := X;
          if X < Xmin then Xmin := X;
          if Y > Ymax then Ymax := Y;
          if Y < Ymin then Ymin := Y;
          Xmean := Xmean + X;
          Ymean := Ymean + Y;
          Xvariance := Xvariance + (X * X);
          Yvariance := Yvariance + (Y * Y);
          R := R + (X * Y);
     end;

     // sort on X
     for i := 1 to N - 1 do
     begin
          for j := i + 1 to N do
          begin
               if Xpoints[i] > Xpoints[j] then //swap
               begin
                    temp := Xpoints[i];
                    Xpoints[i] := Xpoints[j];
                    Xpoints[j] := temp;
                    temp := Ypoints[i];
                    Ypoints[i] := Ypoints[j];
                    Ypoints[j] := temp;
               end;
          end;
     end;

     // calculate statistics
     Xvariance := Xvariance - (Xmean * Xmean / N);
     SSx := Xvariance;
     Xvariance := Xvariance / (N - 1);
     Xstddev := sqrt(Xvariance);

     Yvariance := Yvariance - (Ymean * Ymean / N);
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

     // Now, print the descriptive statistics to the output form if requested
     if DescChk.Checked then
     begin
       lReport := TStringList.Create;
       try
         lReport.Add('X vs. Y PLOT');
         lReport.Add('');
         lReport.Add('X = %s, Y = %s from file: %s',[Xedit.Text, YEdit.Text,OS3MainFrm.FileNameEdit.Text]);
         lReport.Add('');
         lReport.Add('Variable     Mean   Variance  Std.Dev.');
         lReport.Add('%-10s%8.2f  %8.2f  %8.2f', [XEdit.Text,Xmean,Xvariance,Xstddev]);
         lReport.Add('%-10s%8.2f  %8.2f  %8.2f', [YEdit.Text,Ymean,Yvariance,Ystddev]);
         lReport.Add('');
         lReport.Add('Correlation:                %8.3f', [R]);
         lReport.Add('Slope:                      %8.3f', [Slope]);
         lReport.Add('Intercept:                  %8.3f', [Intercept]);
         lReport.Add('Standard Error of Estimate: %8.3f', [SEPred]);
         lReport.Add('Number of good cases:       %8d', [N]);

         DisplayReport(lReport);
       finally
         lReport.Free;
       end;
     end;

     // get upper and lower confidence points for each X value
     if ConfChk.Checked then
     begin
          ConfBand := StrToFloat(ConfEdit.Text) / 100.0;
          DF := N - 2;
          t := inverset(ConfBand,DF);
          for i := 1 to N do
          begin
               X := Xpoints[i];
               predicted := slope * X + intercept;
               sedata := SEPred * sqrt(1.0 + (1.0 / N) + (sqr(X - Xmean) / SSx));
               UpConf[i] := predicted + (t * sedata);
               lowConf[i] := predicted - (t * sedata);
               if UpConf[i] > Ymax then Ymax := UpConf[i];
               if lowConf[i] < Ymin then Ymin := lowConf[i];
          end;
     end
     else ConfBand := 0.0;

     // plot the values (and optional line and confidence band if elected)
     plotxy(Xpoints, Ypoints, UpConf, LowConf, ConfBand, Xmean, Ymean, R,
            Slope, Intercept, Xmax, Xmin, Ymax, Ymin, N);
     Application.ProcessMessages;

     {
     // print the same if elected
     if PrintChk.Checked then
        pplotxy(Xpoints, Ypoints, UpConf, LowConf, ConfBand, Xmean, Ymean,
                R, Slope, Intercept, Xmax, Xmin, Ymax, Ymin, N);
     }

     // cleanup
     ColNoSelected := nil;
     lowConf := nil;
     UpConf := nil;
     Ypoints := nil;
     Xpoints := nil;
end;

procedure TPlotXYFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  VarList.Constraints.MinHeight := GroupBox1.Top + GroupBox1.Height - VarList.Top;
  VarList.Constraints.MinWidth := GroupBox1.Width;

  Constraints.MinWidth := GroupBox1.Width * 2 + XInBtn.Width + 4 * VarList.BorderSpacing.Left;
  Constraints.MinHeight := Height;

  FAutoSized := True;
end;

procedure TPlotXYFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if BlankFrm = nil then Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TPlotXYFrm.plotxy(VAR Xpoints : DblDyneVec;
                            VAR Ypoints : DblDyneVec;
                            VAR UpConf : DblDyneVec;
                            VAR LowConf : DblDyneVec;
                            ConfBand : double;
                            Xmean, Ymean , R : double;
                            Slope, Intercept : double;
                            Xmax, Xmin, Ymax, Ymin : double;
                            N : integer);
var
   i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
   vhi, hwide, offset, strhi, imagehi : integer;
   valincr, Yvalue, Xvalue : double;
   Title : string;

begin
     BlankFrm.Image1.Canvas.Clear;
     BlankFrm.Show;
     Title := 'X versus Y PLOT Using File: ' + OS3MainFrm.FileNameEdit.Text;
     BlankFrm.Caption := Title;
     imagewide := BlankFrm.Image1.Width;
     imagehi := BlankFrm.Image1.Height;
     vtop := 20;
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
          Yvalue := (Xpoints[1] * slope) + intercept; // predicted score
          ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[1]- Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          Yvalue := (Xpoints[N] * slope) + intercept; // predicted score
          ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[N] - Xmin) / (Xmax - Xmin)));
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
     xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(XEdit.Text) div 2);
     ypos := vbottom + 20;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,XEdit.Text);
     Title := format('R(X,Y) = %5.3f, Slope = %6.2f, Intercept = %6.2f',
              [R,Slope,Intercept]);
     xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(Title) div 2);
     ypos := ypos + 15;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

     // Draw vertical axis
     Title := YEdit.Text;
     xpos := hleft - BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
     ypos := vtop - BlankFrm.Image1.Canvas.TextHeight(Title);
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,YEdit.Text);
     xpos := hleft;
     ypos := vtop;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     ypos := vbottom;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     valincr := (Ymax - Ymin) / 10.0;
     for i := 1 to 11 do
     begin
          Title := format('%8.2f',[Ymax - ((i-1)*valincr)]);
          strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
          xpos := 10;
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
     for i := 1 to N do
     begin
          ypos := round(vhi * ( (Ymax - Ypoints[i]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.Brush.Color := clNavy;
          BlankFrm.Image1.Canvas.Brush.Style := bsSolid;
          BlankFrm.Image1.Canvas.Pen.Color := clNavy;
          BlankFrm.Image1.Canvas.Ellipse(xpos,ypos,xpos+5,ypos+5);
     end;

     // draw confidence bands if requested
     if ConfBand <> 0.0 then
     begin
          BlankFrm.Image1.Canvas.Pen.Color := clRed;
          ypos := round(vhi * ((Ymax - UpConf[1]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[1] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          for i := 2 to N do
          begin
               ypos := round(vhi * ((Ymax - UpConf[i]) / (Ymax - Ymin)));
               ypos := ypos + vtop;
               xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
               xpos := xpos + hleft;
               BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          end;
          ypos := round(vhi * ((Ymax - lowConf[1]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          xpos := round(hwide * ( (Xpoints[1] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          for i := 2 to N do
          begin
               ypos := round(vhi * ((Ymax - lowConf[i]) / (Ymax - Ymin)));
               ypos := ypos + vtop;
               xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
               xpos := xpos + hleft;
               BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          end;
     end;
end;
//-------------------------------------------------------------------
(*
procedure TPlotXYFrm.pplotxy(VAR Xpoints : DblDyneVec;
                             VAR Ypoints : DblDyneVec;
                             VAR UpConf : DblDyneVec;
                             VAR LowConf : DblDyneVec;
                             ConfBand : double;
                             Xmean, Ymean , R : double;
                             Slope, Intercept : double;
                             Xmax, Xmin, Ymax, Ymin : double;
                             N : integer);
var
   i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
   vhi, hwide, offset, strhi : integer;
   imagehi, maxval, minval, valincr, Yvalue, Xvalue : double;
   Title : string;

begin
  if not PrintDialog.Execute then
    exit;

  Printer.Orientation := poLandscape;
  Printer.BeginDoc;
  Title := 'X versus Y PLOT Using File: ' + OS3MainFrm.FileNameEdit.Text;
  strhi := Printer.Canvas.TextWidth(Title) div 2;
  Printer.Canvas.TextOut(strhi,5,Title);
  imagewide := Printer.PageWidth - 100;
  imagehi := Printer.PageHeight - 100;
  vtop := 120;
  vbottom := round(imagehi) - 100;
  vhi := vbottom - vtop;
  hleft := 300;
  hright := imagewide - 200;
  hwide := hright - hleft;
  Printer.Canvas.Pen.Color := clBlack;
  Printer.Canvas.Brush.Color := clWhite;

  // draw Means
  if MeansChk.Checked then
  begin
      ypos := round(vhi * ( (Ymax - Ymean) / (Ymax - Ymin)));
      ypos := ypos + vtop;
      xpos := hleft;
      Printer.Canvas.MoveTo(xpos,ypos);
      xpos := hright;
      Printer.Canvas.Pen.Color := clGreen;
      Printer.Canvas.LineTo(xpos,ypos);
      Title := 'MEAN ';
      Title := Title + YEdit.Text;
      strhi := Printer.Canvas.TextHeight(Title);
      ypos := ypos - strhi div 2;
      Printer.Canvas.Brush.Color := clWhite;
      Printer.Canvas.TextOut(xpos,ypos,Title);

      xpos := round(hwide * ( (Xmean - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      ypos := vtop;
      Printer.Canvas.MoveTo(xpos,ypos);
      ypos := vbottom;
      Printer.Canvas.Pen.Color := clGreen;
      Printer.Canvas.LineTo(xpos,ypos);
      Title := 'MEAN ';
      Title := Title + XEdit.Text;
      strhi := Printer.Canvas.TextWidth(Title);
      xpos := xpos - strhi div 2;
      ypos := vtop - Printer.Canvas.TextHeight(Title);
      Printer.Canvas.Brush.Color := clWhite;
      Printer.Canvas.TextOut(xpos,ypos,Title);
  end;

  // draw slope line
  if LineChk.Checked then
  begin
      Printer.Canvas.Pen.Color := clBlack;
      Yvalue := (Xpoints[1] * slope) + intercept; // predicted score
      ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
      ypos := ypos + vtop;
      xpos := round(hwide * ( (Xpoints[1]- Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      Printer.Canvas.MoveTo(xpos,ypos);
      Yvalue := (Xpoints[N] * slope) + intercept; // predicted score
      ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
      ypos := ypos + vtop;
      xpos := round(hwide * ( (Xpoints[N] - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      Printer.Canvas.LineTo(xpos,ypos);
  end;

  // draw horizontal axis
  Printer.Canvas.Pen.Color := clBlack;
  Printer.Canvas.MoveTo(hleft,vbottom);
  Printer.Canvas.LineTo(hright,vbottom);
  valincr := (Xmax - Xmin) / 10.0;
  for i := 1 to 11 do
  begin
      ypos := vbottom;
      Xvalue := Xmin + valincr * (i - 1);
      xpos := round(hwide * ((Xvalue - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      Printer.Canvas.MoveTo(xpos,ypos);
      ypos := ypos + 10;
      Printer.Canvas.LineTo(xpos,ypos);
      Title := format('%6.2f',[Xvalue]);
      offset := Printer.Canvas.TextWidth(Title) div 2;
      xpos := xpos - offset;
      Printer.Canvas.Pen.Color := clBlack;
      Printer.Canvas.TextOut(xpos,ypos,Title);
  end;
  xpos := hleft + (hwide div 2) - (Printer.Canvas.TextWidth(XEdit.Text) div 2);
  ypos := vbottom + 40;
  Printer.Canvas.TextOut(xpos,ypos,XEdit.Text);
  Title := format('R(X,Y) = %5.3f, Slope = %6.2f, Intercept = %6.2f',
          [R,Slope,Intercept]);
  xpos := hleft + (hwide div 2) - (Printer.Canvas.TextWidth(Title) div 2);
  ypos := ypos + 40;
  Printer.Canvas.TextOut(xpos,ypos,Title);

  // Draw vertical axis
  Title := YEdit.Text;
  xpos := hleft - Printer.Canvas.TextWidth(Title) div 2;
  ypos := vtop - Printer.Canvas.TextHeight(Title);
  Printer.Canvas.TextOut(xpos,ypos,YEdit.Text);
  xpos := hleft;
  ypos := vtop;
  Printer.Canvas.MoveTo(xpos,ypos);
  ypos := vbottom;
  Printer.Canvas.LineTo(xpos,ypos);
  valincr := (Ymax - Ymin) / 10.0;
  for i := 1 to 11 do
  begin
      Title := format('%8.2f',[Ymax - ((i-1)*valincr)]);
      strhi := Printer.Canvas.TextHeight(Title);
      xpos := 10;
      Yvalue := Ymax - (valincr * (i-1));
      ypos := round(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
      ypos := ypos + vtop - strhi div 2;
      Printer.Canvas.TextOut(xpos,ypos,Title);
      xpos := hleft;
      ypos := ypos + strhi div 2;
      Printer.Canvas.MoveTo(xpos,ypos);
      xpos := hleft - 10;
      Printer.Canvas.LineTo(xpos,ypos);
  end;

  // draw points for x and y pairs
  for i := 1 to N do
  begin
      ypos := round(vhi * ( (Ymax - Ypoints[i]) / (Ymax - Ymin)));
      ypos := ypos + vtop;
      xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      Printer.Canvas.Pen.Color := clBlack;
      Printer.Canvas.Ellipse(xpos,ypos,xpos+15,ypos+15);
  end;

  // draw confidence bands if requested
  if ConfBand <> 0.0 then
  begin
      Printer.Canvas.Pen.Color := clRed;
      ypos := round(vhi * ((Ymax - UpConf[1]) / (Ymax - Ymin)));
      ypos := ypos + vtop;
      xpos := round(hwide * ( (Xpoints[1] - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      Printer.Canvas.MoveTo(xpos,ypos);
      for i := 2 to N do
      begin
           ypos := round(vhi * ((Ymax - UpConf[i]) / (Ymax - Ymin)));
           ypos := ypos + vtop;
           xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
           xpos := xpos + hleft;
           Printer.Canvas.LineTo(xpos,ypos);
      end;
      ypos := round(vhi * ((Ymax - lowConf[1]) / (Ymax - Ymin)));
      ypos := ypos + vtop;
      xpos := round(hwide * ( (Xpoints[1] - Xmin) / (Xmax - Xmin)));
      xpos := xpos + hleft;
      Printer.Canvas.MoveTo(xpos,ypos);
      for i := 2 to N do
      begin
           ypos := round(vhi * ((Ymax - lowConf[i]) / (Ymax - Ymin)));
           ypos := ypos + vtop;
           xpos := round(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
           xpos := xpos + hleft;
           Printer.Canvas.LineTo(xpos,ypos);
      end;
  end;

  Printer.EndDoc;
  Printer.Orientation := poPortrait;
end;
//-------------------------------------------------------------------
*)
function TPlotXYFrm.Validate(out AMsg: String; out AControl: TWinControl;
  Xcol, Ycol: Integer): Boolean;
begin
  Result := false;

  if (Xcol = 0) then
  begin
    AControl := XEdit;
    AMsg := 'No case selected for X.';
    exit;
  end;

  if (Ycol = 0) then
  begin
    AControl := YEdit;
    AMsg := 'No case selected for Y.';
    exit;
  end;
  Result := true;
end;

procedure TPlotXYFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

procedure TPlotXYFrm.UpdateBtnStates;
begin
  XinBtn.Enabled := (VarList.ItemIndex > -1) and (XEdit.Text = '');
  XoutBtn.Enabled := (XEdit.Text <> '');
  YinBtn.Enabled := (VarList.ItemIndex > -1) and (YEdit.Text = '');
  YoutBtn.Enabled := (YEdit.Text <> '');
end;

initialization
  {$I plotxyunit.lrs}

end.

