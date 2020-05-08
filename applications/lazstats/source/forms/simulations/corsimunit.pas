unit CorSimUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Math,
  Globals, OutputUnit;

type

  { TCorSimFrm }

  TCorSimFrm = class(TForm)
    Bevel1: TBevel;
    Nobs: TEdit;
    Image1: TImage;
    Label6: TLabel;
    CloseBtn: TButton;
    ComputeBtn: TButton;
    Corr: TEdit;
    Label5: TLabel;
    SDY: TEdit;
    Label4: TLabel;
    SDX: TEdit;
    Label3: TLabel;
    MeanY: TEdit;
    Label2: TLabel;
    MeanX: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    procedure ComputeBtnClick(Sender: TObject);
    procedure CorrKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure MeanXKeyPress(Sender: TObject; var Key: char);
    procedure MeanYKeyPress(Sender: TObject; var Key: char);
    procedure NobsKeyPress(Sender: TObject; var Key: char);
    procedure SDXKeyPress(Sender: TObject; var Key: char);
    procedure SDYKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
    xmean, ymean, xsd, ysd, corxy, corsqr, yvariance, predvar : double;
    errvariance, stderror, b, constant, newxmean, newymean : double;
    newxsd, newysd, newcorr, randomerror, newb, newconstant : double;
    x, y: DblDyneVec;
    freqx, freqy: IntDyneVec;
    N: integer;
    procedure Plot;
    function Validate(out AMsg: String; out AControl: TWinControl): Boolean;
  public
    { public declarations }
  end; 

var
  CorSimFrm: TCorSimFrm;

implementation

{ TCorSimFrm }

procedure TCorSimFrm.MeanXKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then MeanY.SetFocus;
end;

procedure TCorSimFrm.CorrKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then Nobs.SetFocus;
end;

procedure TCorSimFrm.ComputeBtnClick(Sender: TObject);
var
  i: integer;
  msg: String;
  C: TWinControl;
  lReport: TStrings;
begin
  if not Validate(msg, C) then begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOk], 0);
    exit;
  end;

  N :=  StrToInt(NObs.Text);
  xmean := StrToFloat(MeanX.Text);
  ymean := StrToFloat(MeanY.Text);
  xsd := StrToFloat(SDX.Text);
  ysd := StrToFloat(SDY.Text);
  corxy := StrToFloat(Corr.Text);

  Randomize;

  SetLength(freqx, N + 1);
  SetLength(freqy, N + 1);
  SetLength(x, N + 1);
  SetLength(y, N + 1);

  // generate x and y data observations
  corsqr :=  corxy * corxy;
  yvariance :=  ysd * ysd;
  predvar :=  corsqr * yvariance;
  errvariance :=  yvariance - predvar;
  stderror :=  sqrt(errvariance);
  b :=  corxy * (ysd / xsd);
  constant :=  ymean - b * xmean;

  newxmean :=  0.0;
  newymean :=  0.0;
  newxsd :=  0.0;
  newysd :=  0.0;
  newcorr :=  0.0;
  for i := 1 to N do
  begin
    x[i] :=  RandG(xmean, xsd);
    randomerror :=  RandG(0.0, stderror);
    y[i] :=  b * x[i] + constant + randomerror;
    newxmean := newxmean + x[i];
    newymean := newymean + y[i];
    newxsd := newxsd + sqr(x[i]);
    newysd := newysd + sqr(y[i]);
    newcorr := newcorr + x[i] * y[i];
  end;

  newxsd := newxsd - sqr(newxmean) / N;
  newxsd := newxsd / (N - 1);
  newxsd := sqrt(newxsd);

  newysd := newysd - sqr(newymean) / N;
  newysd := newysd / (N - 1);
  newysd := sqrt(newysd);

  newcorr := newcorr - newxmean * newymean / N;
  newcorr := newcorr / (N - 1);
  newcorr := newcorr / (newxsd * newysd);

  newxmean := newxmean / N;
  newymean := newymean / N;
  newb :=  newcorr * (newysd / newxsd);
  newconstant :=  newymean - newb * newxmean;

  lReport := TStringList.Create;
  try
    lReport.Add('POPULATION PARAMETERS FOR THE SIMULATION');
    lReport.Add('');
    lReport.Add('Mean X:                      %8.3f', [xmean]);
    lReport.Add('Std. Dev. X:                 %8.3f', [xsd]);
    lReport.Add('');
    lReport.Add('Mean Y:                      %8.3f', [ymean]);
    lReport.Add('Std. Dev. Y:                 %8.3f', [ysd]);
    lReport.Add('');
    lReport.Add('Product-Moment Correlation:  %8.3f', [corxy]);
    lReport.Add('Regression line slope:       %8.3f', [b]);
    lReport.Add('                constant:    %8.3f', [constant]);
    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');
    lReport.Add('SAMPLE STATISTICS FOR %d OBSERVATIONS FROM THE POPULATION', [N]);
    lReport.Add('');
    lReport.Add('Mean X:                      %8.3f', [newxmean]);
    lReport.Add('Std. Dev. X:                 %8.3f', [newxsd]);
    lReport.Add('');
    lReport.Add('Mean Y:                      %8.3f', [newymean]);
    lReport.Add('Std. Dev. Y:                 %8.3f', [newysd]);
    lReport.Add('');
    lReport.Add('Product-Moment Correlation:  %8.3f', [newcorr]);
    lReport.Add('Regression line slope:       %8.3f', [newb]);
    lReport.Add('                constant:    %8.3f', [newconstant]);
    lReport.Add('');
    lReport.Add(DIVIDER);
    lReport.Add('');
    lReport.Add('Pair No.      X          Y     ');
    lReport.Add('--------  ---------  ---------');
    for i := 1 to N do
      lReport.Add('  %4d    %8.3f   %8.3f', [i, x[i], y[i]]);

    DisplayReport(lReport);

    Plot();

  finally
    lReport.Free;
    freqx := nil;
    freqy := nil;
    x := nil;
    y := nil;
  end;
end;

procedure TCorSimFrm.FormShow(Sender: TObject);
begin
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Rectangle(0, 0, Image1.Width, Image1.Height);

  MeanX.Text := '100';
  MeanY.Text := '100';
  SDX.Text := '15';
  SDY.Text := '15';
  Corr.Text := '.8';
  Nobs.Text := '100';
end;

procedure TCorSimFrm.MeanYKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then SDX.SetFocus;
end;

procedure TCorSimFrm.NobsKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then ComputeBtn.SetFocus;
end;

procedure TCorSimFrm.SDXKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then SDY.SetFocus;
end;

procedure TCorSimFrm.SDYKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then Corr.SetFocus;
end;

procedure TCorSimFrm.Plot;
var
  minx, maxx, miny, maxy, xincrement, yincrement: double;
  predy1, predy2, lowerx, upperx, frange, prop: double;
  charlabel: string;
  xpos, ypos, xpos1, ypos1, xpos2, ypos2: integer;
  i, winwidth, winheight, xoffset, yoffset, xaxislong, yaxislong: integer;
  j, xspacing, yspacing, labelwidth, minfreq, maxfreq: integer;
  flength, theight, lowery, uppery: integer;
begin
  // get min and max of x and y points
  minx :=  x[1];
  maxx :=  minx;
  miny :=  y[1];
  maxy :=  miny;
  for i := 1 to N do
  begin
    if (minx > x[i]) then minx :=  x[i];
    if (maxx < x[i]) then maxx :=  x[i];
    if (miny > y[i]) then miny :=  y[i];
    if (maxy < y[i]) then maxy :=  y[i];
  end;
  xincrement :=  (maxx - minx) / 10;
  yincrement :=  (maxy - miny) / 10;

  winwidth :=  Image1.Width;
  winheight :=  Image1.Height;
  xoffset := winwidth div 5;
  yoffset := winheight div 5;
  xaxislong :=  winwidth - xoffset- winwidth div 10;
  yaxislong :=  winheight - yoffset - winheight div 10;
  xspacing := xaxislong div 10;
  yspacing := yaxislong div 10;

  Image1.Canvas.Pen.Color :=  clBlack;
  Image1.Canvas.Line(xoffset, yaxislong, winwidth, yaxislong);
  Image1.canvas.Line(xoffset, yaxislong, xoffset, 0);

  // do xaxis
  for i := 0 to 11 do
  begin
    Image1.Canvas.Line(xoffset + i * xspacing, yaxislong, xoffset + i * xspacing, yaxislong + 10);
    charlabel := Format('%.3f', [minx + i * xincrement]);
    labelwidth :=  Image1.Canvas.TextWidth(charlabel);
    xpos :=  xoffset + i * xspacing - labelwidth div 2;
    ypos :=  yaxislong + 12;
    Image1.Canvas.TextOut(xpos, ypos, charlabel);
  end;

  // do yaxis
  for i := 0 to 11 do
  begin
    Image1.Canvas.Line(xoffset, yaxislong - i * yspacing, xoffset-10, yaxislong - i * yspacing);
    charlabel := Format('%.3f', [miny + i * yincrement]);
    labelwidth :=  Image1.Canvas.TextWidth(charlabel);
    xpos :=  xoffset - 10 - labelwidth;
    ypos :=  yaxislong - i * yspacing;
    Image1.Canvas.TextOut(xpos, ypos, charlabel);
  end;

  // plot points
  Image1.Canvas.Pen.Color :=  clRed;
  for i := 1 to N do
  begin
    xpos :=  round(xoffset + ((x[i] - minx) / (maxx - minx) * xaxislong));
    ypos :=  round(yaxislong - ((y[i] - miny) / (maxy - miny) * yaxislong));
    Image1.Canvas.Ellipse(xpos, ypos, xpos+5, ypos+5);
  end;

  // draw regression line
  Image1.Canvas.Pen.Color :=  clBlack;
  predy1 :=  newb * minx + newconstant;
  predy2 :=  newb * maxx + newconstant;
  xpos1 :=  xoffset;
  xpos2 :=  xoffset + xaxislong;
  ypos1 :=  round(yaxislong - ((predy1 - miny) / (maxy - miny) * yaxislong));
  ypos2 :=  round(yaxislong - ((predy2 - miny) / (maxy - miny) * yaxislong));
  Image1.Canvas.Line(xpos1, ypos1, xpos2, ypos2);

  // do x frequency distribution
  xincrement := (maxx - minx) / 50.0;
  xspacing :=  xaxislong div 50;
  for j := 1 to 51 do
    freqx[j] :=  0;
  for i := 1 to N do
  begin
    for j := 1 to 51 do
    begin
      lowerx :=  minx + j * xincrement;
      upperx :=  minx + (j+1) * xincrement;
      if (x[i] >= lowerx) and (x[i] < upperx) then
        freqx[j] := freqx[j] + 1;
    end;
  end;

  // plot the x frequencies
  minfreq :=  N;
  maxfreq :=  0;
  for j := 1 to 51 do
  begin
    if (freqx[j] > maxfreq) then
      maxfreq :=  freqx[j];
    if (freqx[j] < minfreq) then
      minfreq :=  freqx[j];
  end;
  flength :=  winheight - (yaxislong + 25) - Panel1.Height;
  for j := 1 to 51 do
  begin
    xpos :=  xoffset + j * xspacing;
    ypos1 :=  round(yaxislong + 25 + (freqx[j] - minfreq)/ (maxfreq-minfreq) * flength);
    ypos2 :=  yaxislong + 25;
    Image1.Canvas.Line(xpos, ypos1, xpos, ypos2);
  end;
  Image1.Canvas.Line(xoffset, yaxislong+25, winwidth, yaxislong+25);

  xpos :=  20;
  ypos :=  yaxislong+30;
  Image1.Canvas.TextOut(xpos, ypos, 'X DISTRIBUTION');

  theight :=  Image1.Canvas.TextHeight('X');
  ypos := ypos + theight;
  charlabel := Format('Correlation: %.3f', [newcorr]);
  Image1.Canvas.TextOut(xpos, ypos, charlabel);
  ypos := ypos + theight;
  charlabel := Format('Mean X: %.3f; Mean Y: %.3f', [newxmean, newymean]);
  Image1.Canvas.TextOut(xpos, ypos, charlabel);
  charlabel := Format('SD X: %.3f; SD Y: %.3f', [newxsd, newysd]);
  ypos := ypos + theight;
  Image1.Canvas.TextOut(xpos,ypos,charlabel);

  // do y frequency distribution
  yincrement :=  (maxy-miny) / 50.0;
  yspacing :=  yaxislong div 50;
  for j := 1 to 51 do
    freqy[j] :=  0;
  for i := 1 to N do
  begin
    for j := 1 to 51 do
    begin
      lowery :=  round(miny + j * yincrement);
      uppery :=  round(miny + ((j+1) * yincrement));
      if (y[i] >= lowery) and (y[i] < uppery) then
        freqy[j] := freqy[j] + 1;
    end;
  end;

  // plot the y frequencies
  minfreq :=  N;
  maxfreq :=  0;
  for j := 1 to 51 do
  begin
    if (freqy[j] > maxfreq) then maxfreq :=  freqy[j];
    if (freqy[j] < minfreq) then minfreq :=  freqy[j];
  end;
  flength :=  winwidth - (xaxislong + 150);
  for j := 1 to 51 do
  begin
    ypos :=  yaxislong - j * yspacing;
    frange :=  maxfreq - minfreq;
    prop :=  (freqy[j] - minfreq) / frange;
    xpos1 :=  round(xoffset - 50 - prop * flength);
    xpos2 :=  xoffset - 50;
    Image1.Canvas.Line(xpos1, ypos, xpos2, ypos);
  end;
  Image1.Canvas.Line(xoffset - 50, yaxislong, xoffset - 50, 0);
  Image1.Canvas.TextOut(0,0,'Y DISTRIBUTION');
end;

function TCorSimFrm.Validate(out AMsg: String; out AControl: TWinControl): Boolean;
begin
  Result := false;

  if (MeanX.Text = '') or (MeanY.Text = '') or
     (SDX.Text = '') or (SDY.Text = '') or
     (Corr.Text = '') or (NObs.Text = '') then
  begin
    if MeanX.Text = '' then
      AControl := MeanX
    else if MeanY.Text = '' then
      AControl := MeanY
    else if SDX.Text = '' then
      AControl := SDX
    else if SDY.Text = '' then
      AControl := SDY
    else if Corr.Text = '' then
      AControl := Corr
    else if NObs.Text = '' then
      AControl := NObs;
    AMsg := 'Input cannot be empty.';
    exit;
  end;

  if not TryStrToFloat(MeanX.Text, xMean) then
  begin
    AControl := MeanX;
    AMsg := 'Mean X must be a valid number.';
    exit;
  end;

  if not TryStrToFloat(MeanY.Text, yMean) then
  begin
    AControl := MeanY;
    AMsg := 'Mean Y must be a valid number.';
    exit;
  end;

  if not TryStrToFloat(SDX.Text, xSD) or (xSD <= 0) then
  begin
    AControl := SDX;
    AMsg := 'Std.Dev X must be a valid positive number.';
    exit;
  end;

  if not TryStrToFloat(SDY.Text, ySD) or (ySD <= 0) then
  begin
    AControl := SDY;
    AMsg := 'Std.Dev Y must be a valid positive number.';
    exit;
  end;

  if not TryStrToFloat(Corr.Text, corXY) then
  begin
    AControl := Corr;
    AMsg := 'Correlation XY must be a valid number.';
    exit;
  end;

  if not TryStrToInt(NObs.Text, N) or (N <= 0) then
  begin
    AControl := NObs;
    AMsg := 'Number of observations must be a valid positive integer.';
    exit;
  end;

  Result := true;
end;

initialization
  {$I corsimunit.lrs}

end.

