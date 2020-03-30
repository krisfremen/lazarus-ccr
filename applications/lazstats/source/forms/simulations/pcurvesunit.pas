unit PCurvesUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  GraphLib, OutputUnit, FunctionsLib, Globals;

type

  { TPCurvesFrm }

  TPCurvesFrm = class(TForm)
    Panel1: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    Prob01: TCheckBox;
    Prob025: TCheckBox;
    Prob05: TCheckBox;
    Prob075: TCheckBox;
    Prob10: TCheckBox;
    Prob20: TCheckBox;
    NullEdit: TEdit;
    SDEdit: TEdit;
    NEdit: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  PCurvesFrm: TPCurvesFrm;

implementation

{ TPCurvesFrm }

procedure TPCurvesFrm.ResetBtnClick(Sender: TObject);
begin
     Prob01.Checked := false;
     Prob025.Checked := false;
     Prob05.Checked := false;
     Prob075.Checked := false;
     Prob10.Checked := false;
     Prob20.Checked := false;
     NullEdit.Text := '';
     SDEdit.Text := '';
     NEdit.Text := '';
     NullEdit.SetFocus;
end;

procedure TPCurvesFrm.FormShow(Sender: TObject);
begin
     ResetBtnClick(self);
end;

procedure TPCurvesFrm.ComputeBtnClick(Sender: TObject);
var
   mean, stddev, N, increment, althyp, power, zbeta, beta, StdErr : double;
   XMax, offset : double;
   ii : integer;
   j, NoPlots, SetNo : integer;
   alphas : array[1..6] of double;
   zalphas : array[1..6] of double;
   xalphas : array[1..6] of double;
   XPlotPts : DblDyneMat;
   YPlotPts : DblDyneMat;
   LabelStr, outline, xTitle, yTitle : string;
   oldCursor : TCursor;
begin
     SetLength(YPlotPts,6,80);
     SetLength(XPlotPts,1,80);

     XMax := 0.0;
     mean := StrToFloat(NullEdit.Text);
     stddev := StrToFloat(SDEdit.Text);
     N := StrToFloat(NEdit.Text);
     StdErr := stddev / sqrt(N);  // standard error of mean;
     increment := 4.0 * StdErr / 80.0;  //scale for 80 points

     // Initialize alternative type I error arrays
     for ii := 1 to 6 do
     begin
         alphas[ii] := 0.0;
         zalphas[ii] := 0.0;
         xalphas[ii] := 0.0;
     end;

     // Get the desired alpha (Beta) curve options
     if (Prob01.Checked) then alphas[1] := 0.01;
     if (Prob025.Checked) then alphas[2] := 0.025;
     if (Prob05.Checked) then alphas[3] := 0.05;
     if (Prob075.Checked) then alphas[4] := 0.075;
     if (Prob10.Checked) then  alphas[5] := 0.10;
     if (Prob20.Checked) then alphas[6] := 0.20;
     oldCursor := Screen.Cursor;
     Screen.Cursor := TCursor(crHourGlass);

     // For curves selected, obtain corresponding z and x values
     for ii := 1 to 6 do
     begin
         if (alphas[ii] <> 0.0) then
         begin
            zalphas[ii] := inversez(1.0 - alphas[ii]);
            xalphas[ii] := (zalphas[ii] * StdErr) + mean;
            if (xalphas[ii] > XMax) then XMax := xalphas[ii];
         end;
     end;

     // For each curve, obtain and plot 80 alternative hypotheses and
     // their corresponding probabilities
     NoPlots := 1;
     for ii := 1 to 6 do // possible curves
     begin
         if (alphas[ii] <> 0.0) then   // curve selected?
         begin
            Offset := 0.0;
            for  j := 1 to 80 do  //get points to plot
            begin
                althyp := mean + Offset;
                zbeta := (xalphas[ii] - althyp ) / StdErr;
                if ( abs(zbeta) < 5.0) then beta := probz(zbeta)
                else beta := 0.0;
                power := 1.0 - beta;
                XPlotPts[0,j-1] := althyp;
                YPlotPts[NoPlots-1,j-1] := power;
                Offset := offset + increment;
            end;
            NoPlots := NoPlots + 1;
         end; // if alphas[i] <> 0
     end; // next curve i

     // Plot the points
     GraphFrm.BackColor := clWhite;
     GraphFrm.ShowLeftWall := true;
     GraphFrm.ShowRightWall := true;
     GraphFrm.ShowBottomWall := true;
     GraphFrm.ShowBackWall := true;
     GraphFrm.BackColor := clYellow;
     GraphFrm.WallColor := clBlue;
     GraphFrm.FloorColor := clBlue;
     outline := format('z-Test Power. Pop. Mean := %6.2f, Sigma := %6.2f, N := %2.0f',[mean,stddev,N]);
     GraphFrm.Heading := outline;
     xTitle := format('%6.2f x INCREMENT ABOVE HYPOTHESIZED MEAN',[increment]);
     GraphFrm.XTitle := xTitle;
     yTitle := 'PROBABILITIES';
     GraphFrm.YTitle := yTitle;
     GraphFrm.nosets := NoPlots-1;
     GraphFrm.nbars := 80;
     GraphFrm.barwideprop := 0.5;
     GraphFrm.miny := 0.0;
     GraphFrm.maxy := 1.0;
     GraphFrm.AutoScaled := false;
     GraphFrm.GraphType := 5; // 2d line charts
     GraphFrm.PtLabels := false;

     SetNo := 1;
     for ii := 1 to 6 do
     begin
         if (alphas[ii] <> 0.0) then
         begin
            LabelStr := format('%4.2f',[alphas[ii]]);
            GraphFrm.SetLabels[SetNo] := LabelStr;
            SetNo := SetNo + 1;
         end;
     end;
     GraphFrm.Ypoints := YPlotPts;
     GraphFrm.Xpoints := XPlotPts;

     Screen.Cursor := oldCursor;
     GraphFrm.ShowModal;

     OutputFrm.RichEdit.Clear;
     OutputFrm.RichEdit.Lines.Add('Power of the z-test for Alternate Hypotheses');
     OutputFrm.RichEdit.Lines.Add('');
     outline := 'Alpha Levels: ';
     for ii := 1 to 6 do
     begin
         if (alphas[ii] <> 0.0) then
         begin
            LabelStr := format(' %4.2f ',[alphas[ii]]);
            outline := outline + LabelStr;
         end;
     end;
     OutputFrm.RichEdit.Lines.Add(outline);
     OutputFrm.RichEdit.Lines.Add('');
     outline := '';
     for ii := 1 to 80 do
     begin
         outline := format('X := %6.2f    ',[XPlotPts[0,ii-1]]);
         SetNo := 1;
         for j := 1 to 6 do
         begin
             if (alphas[j] <> 0.0) then
             begin
                LabelStr := format('%4.3f ',[YPlotPts[SetNo-1,ii-1]]);
                outline := outline + LabelStr;
                SetNo := SetNo + 1;
             end;
         end;
         OutputFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.ShowModal;

     // clean up the heap
     XPlotPts := nil;
     YPlotPts := nil;
end;

procedure TPCurvesFrm.FormCreate(Sender: TObject);
begin
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
end;

initialization
  {$I pcurvesunit.lrs}

end.

