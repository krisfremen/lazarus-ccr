// Use file "anova2.laz" for testing

unit BoxPlotUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Printers,
  MainUnit, Globals, DataProcs, OutputUnit, BlankFrmUnit, ContextHelpUnit;


type

  { TBoxPlotFrm }

  TBoxPlotFrm = class(TForm)
    HorCenterBevel: TBevel;
    Bevel2: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    ShowChk: TCheckBox;
    GroupBox1: TGroupBox;
    MeasEdit: TEdit;
    GroupEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure VarListClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    function Percentile(nscrgrps : integer;
                     pcnt : double;
                     VAR freq : DblDyneVec;
                     VAR cumfreq : DblDyneVec;
                     VAR scores : DblDyneVec) : double;
    {
    procedure pBoxPlot(nbars : integer;
                    max, min : double;
                    VAR lowqrtl : DblDyneVec;
                    VAR hiqrtl : DblDyneVec;
                    VAR tenpcnt : DblDyneVec;
                    VAR ninetypcnt : DblDyneVec;
                    VAR means : DblDyneVec;
                    VAR median : DblDyneVec);
    }
    procedure BoxPlot(nbars : integer;
                    max, min : double;
                    VAR lowqrtl : DblDyneVec;
                    VAR hiqrtl : DblDyneVec;
                    VAR tenpcnt : DblDyneVec;
                    VAR ninetypcnt : DblDyneVec;
                    VAR means : DblDyneVec;
                    VAR median : DblDyneVec);

  public
    { public declarations }
  end; 

var
  BoxPlotFrm: TBoxPlotFrm;

implementation

uses
  Math;

{ TBoxPlotFrm }

procedure TBoxPlotFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  GroupEdit.Text := '';
  MeasEdit.Text := '';
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TBoxPlotFrm.VarListClick(Sender: TObject);
var
  index: integer;

begin
  index := VarList.ItemIndex;
  if index > -1 then
  begin
    if (GroupEdit.Text = '') then
      GroupEdit.Text := VarList.Items[index]
    else
      MeasEdit.Text := VarList.Items[index];
  end;
end;

procedure TBoxPlotFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TBoxPlotFrm.ComputeBtnClick(Sender: TObject);
var
  i, j, k, GrpVar, MeasVar, mingrp, maxgrp, G, NoGrps, cnt : integer;
  nscrgrps : integer;
  X, tenpcnt, ninepcnt, qrtile1, qrtile2, qrtile3 : double;
  minscr, maxscr, intvlsize, lastX : double;
  cellstring: string;
  means, lowqrtl, hiqrtl, tenpcntile, ninetypcntile, median : DblDyneVec;
  freq : DblDyneVec;
  Scores : DblDyneVec;
  cumfreq : DblDyneVec;
  prank : DblDyneVec;
  grpsize : IntDyneVec;
  done : boolean;
  NoSelected : integer;
  ColNoSelected : IntDyneVec;
  lReport: TStrings;
begin
  lReport := TStringList.Create;
  try
    lReport.Add('BOX PLOTS OF GROUPS');
    lReport.Add('');

    GrpVar := 0;
    MeasVar := 0;
    for i := 1 to NoVariables do
    begin
      cellstring := OS3MainFrm.DataGrid.Cells[i,0];
      if cellstring = GroupEdit.Text then GrpVar := i;
      if cellstring = MeasEdit.Text then MeasVar := i;
    end;
    if GrpVar = 0 then
    begin
      MessageDlg('Group variable not selected.', mtError, [mbOK], 0);
      exit;
    end;
    if MeasVar = 0 then
    begin
      MessageDlg('Measurement variable not selected.', mtError, [mbOK], 0);
      exit;
    end;

    NoSelected := 2;
    SetLength(ColNoSelected, NoSelected);
    ColNoSelected[0] := GrpVar;
    ColNoSelected[1] := MeasVar;

    // get minimum and maximum group values
    mingrp := 10000;
    maxgrp := -10000;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      G := round(StrToFloat(OS3MainFrm.DataGrid.Cells[GrpVar,i]));
      if G < mingrp then mingrp := G;
      if G > maxgrp then maxgrp := G;
    end;
    NoGrps := maxgrp - mingrp + 1;
    if NoGrps > 30 then
    begin
      MessageDlg('Too many groups for a meaningful plot.', mtError, [mbOK], 0);
      exit;
    end;

    SetLength(freq,2 * NoCases + 1);
    SetLength(Scores,2 * NoCases + 1);
    SetLength(cumfreq,2 * NoCases + 1);
    SetLength(prank,2 * NoCases + 1);

    SetLength(grpsize,NoGrps+1);
    SetLength(means,NoGrps+1);
    SetLength(lowqrtl,NoGrps+1);
    SetLength(hiqrtl,NoGrps+1);
    SetLength(tenpcntile,NoGrps+1);
    SetLength(ninetypcntile,NoGrps+1);
    SetLength(median,NoGrps+1);

    // initialize
    for j := 1 to NoGrps do
    begin
      means[j-1] := 0.0;
      grpsize[j-1] := 0;
    end;

    // get minimum and maximum scores and score interval
    intvlsize := 10000.0;
    lastX := 0.0;
    X := StrToFloat(OS3MainFrm.DataGrid.Cells[MeasVar,1]);
    minscr := X;
    maxscr := X;
    for i := 1 to NoCases do
    begin
      if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
      X := StrToFloat(OS3MainFrm.DataGrid.Cells[MeasVar,i]);
      if X > maxscr then maxscr := X;
      if X < minscr then minscr := X;
      if i > 1 then // get interval size as minimum difference between 2 scores
      begin
        if (X <> lastX) and (abs(X - lastX) < intvlsize) then
          intvlsize := abs(X - lastX);
        lastX := X;
      end else
        lastX := X;
    end;

    //  check for excess no. of intervals and reset if needed
    nscrgrps := round((maxscr - minscr) / intvlsize);
    if nscrgrps > 2 * NoCases then
      intvlsize := (maxscr - minscr) / NoCases;

    // setup score groups
    done := false;
    Scores[0] := minscr - intvlsize / 2.0;
    nscrgrps := 0;
    lastX := maxscr + intvlsize + intvlsize / 2.0;

    while not done do
    begin
      nscrgrps := nscrgrps + 1;
      Scores[nscrgrps] := minscr + (nscrgrps * intvlsize) - intvlsize / 2.0;
      if Scores[nscrgrps] > lastX then done := true;
    end;
    Scores[nscrgrps+1] := Scores[nscrgrps] + intvlsize;
    if Scores[0] < minscr then minscr := Scores[0];
    if Scores[nscrgrps] > maxscr then maxscr := Scores[nscrgrps];

    // do analysis for each group
    for j := 1 to NoGrps do // group
    begin
      // get score groups for this group j
      for i := 0 to nscrgrps do
      begin
        cumfreq[i] := 0.0;
        freq[i] := 0.0;
      end;
      cnt := 0;
      for i := 1 to NoCases do
      begin // get scores for this group j
        if not GoodRecord(i,NoSelected,ColNoSelected) then continue;
        G := round(StrToFloat(OS3MainFrm.DataGrid.Cells[GrpVar,i]));
        G := G - mingrp + 1;
        if G = j then // subject in this group
        begin
          cnt := cnt + 1;
          X := StrToFloat(OS3MainFrm.DataGrid.Cells[MeasVar,i]);
          means[j-1] := means[j-1] + X;
          // find score interval and add to the frequency
          for k := 0 to nscrgrps do
            if (X >= Scores[k]) and (X < Scores[k+1]) then
              freq[k] := freq[k] + 1;
        end;
      end;
      grpsize[j-1] := cnt;
      if grpsize[j-1] > 0 then means[j-1] := means[j-1] / grpsize[j-1];

      // accumulate frequencies
      cumfreq[0] := freq[0];
      for i := 1 to nscrgrps-1 do
        cumfreq[i] := cumfreq[i-1] + freq[i];
      cumfreq[nscrgrps] := cumfreq[nscrgrps-1];

      // get percentile ranks
      prank[0] := ((cumfreq[0] / 2.0) / grpsize[j-1]) * 100.0;
      for i := 1 to nscrgrps-1 do
        prank[i] := ((cumfreq[i-1] + (freq[i] / 2.0)) / grpsize[j-1]) * 100.0;

      // get centiles required.
      tenpcnt := 0.10 * grpsize[j-1];
      tenpcntile[j-1] := Percentile(nscrgrps,tenpcnt,freq,cumfreq,scores);
      ninepcnt := 0.90 * grpsize[j-1];
      ninetypcntile[j-1] := Percentile(nscrgrps,ninepcnt,freq,cumfreq,scores);
      qrtile1 := 0.25 * grpsize[j-1];
      lowqrtl[j-1] := Percentile(nscrgrps,qrtile1,freq,cumfreq,scores);
      qrtile2 := 0.50 * grpsize[j-1];
      median[j-1] := Percentile(nscrgrps,qrtile2,freq,cumfreq,scores);
      qrtile3 := 0.75 * grpsize[j-1];
      hiqrtl[j-1] := Percentile(nscrgrps,qrtile3,freq,cumfreq,scores);

      if ShowChk.Checked then
      begin
        if j > 1 then lReport.Add('');
        lReport.Add('RESULTS FOR GROUP %d, MEAN = %.3f', [j, means[j-1]]);
        lReport.Add('');
        lReport.Add('Centile       Value');
        lReport.Add('------------ ------');
        lReport.Add('Ten          %6.3f', [tenpcntile[j-1]]);
        lReport.Add('Twenty five  %6.3f', [lowqrtl[j-1]]);
        lReport.Add('Median       %6.3f', [median[j-1]]);
        lReport.Add('Seventy five %6.3f', [hiqrtl[j-1]]);
        lReport.Add('Ninety       %6.3f', [ninetypcntile[j-1]]);
        lReport.Add('');
        lReport.Add('Score Range     Frequency Cum.Freq. Percentile Rank');
        lReport.Add('--------------- --------- --------- ---------------');
        for i := 0 to nscrgrps-1 do
          lReport.Add('%6.2f - %6.2f    %6.2f    %6.2f     %6.2f', [
            Scores[i], Scores[i+1], freq[i], cumfreq[i], prank[i]
          ]);
        lReport.Add('');
      end;
    end; // get values for next group

    if ShowChk.Checked then
      DisplayReport(lReport);

    // plot the boxes
    BoxPlot(NoGrps, maxscr, minscr, lowqrtl, hiqrtl, tenpcntile, ninetypcntile, means, median);

  finally
    lReport.Free;

    // Clean up
    median := nil;
    ninetypcntile := nil;
    tenpcntile := nil;
    hiqrtl := nil;
    lowqrtl := nil;
    means := nil;
    grpsize := nil;
    cumfreq := nil;
    scores := nil;
    freq := nil;
    ColNoSelected := nil;
  end;
end;

procedure TBoxPlotFrm.FormActivate(Sender: TObject);
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

procedure TBoxPlotFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if BlankFrm = nil then Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TBoxPlotFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

function TBoxPlotFrm.Percentile(nscrgrps: integer;
                                pcnt: double;
                                var freq: DblDyneVec;
                                var cumfreq: DblDyneVec;
                                var scores: DblDyneVec) : double;
var
  i, interval: integer;
  pcntile, Llimit, Ulimit, cumlower, intvlfreq: double;
begin
  interval := 0;
  for i := 0 to nscrgrps-1 do
  begin
    if cumfreq[i] > pcnt then
    begin
      interval := i;
      Break;
    end;
  end;

  if interval > 0 then
  begin
    Llimit := Scores[interval];
    Ulimit := Scores[interval+1];
    cumlower := cumfreq[interval-1];
    intvlfreq := freq[interval];
  end
  else
  begin // Percentile in first interval
    Llimit := Scores[0];
    Ulimit := Scores[1];
    cumlower := 0.0;
    intvlfreq := freq[0];
  end;

  if intvlfreq > 0 then
    pcntile := Llimit + ((pcnt - cumlower) / intvlfreq) * (Ulimit- Llimit)
  else
    pcntile := Llimit;

  Result := pcntile;
end;
//-------------------------------------------------------------------

{
procedure TBoxPlotFrm.pBoxPlot(nbars : integer;
                    max, min : double;
                    VAR lowqrtl : DblDyneVec;
                    VAR hiqrtl : DblDyneVec;
                    VAR tenpcnt : DblDyneVec;
                    VAR ninetypcnt : DblDyneVec;
                    VAR means : DblDyneVec;
                    VAR median : DblDyneVec);
var
   i, HTickSpace, imagewide, imagehi, vtop, vbottom, offset : integer;
   vhi, hleft, hright, hwide, barwidth, Xpos, Ypos, strhi, strwide : integer;
//   coords : array [1..5] of TPoint;
   X, Y, colcycle : integer;
   X1, X2, X3, X9, X10 : integer; // X coordinates for box and lines
   Y1, Y2, Y3, Y4, Y9 : integer; // Y coordinates for box and lines
   Title : string;
   valincr, Yvalue : double;

begin
     Printer.Orientation := poLandscape;
     Printer.BeginDoc;
     Title := 'BOXPLOT FOR : ' + OS3MainFrm.FileNameEdit.Text;
     imagewide := Printer.PageWidth;
     imagehi := Printer.PageHeight;
     vtop := 400;
     vbottom := round(imagehi) - 400;
//     vhi := vbottom - vtop;
     hleft := 400;
     hright := imagewide - 40;
     hwide := hright - hleft;

     // show title
     Printer.Canvas.Brush.Color := clWhite;
     strhi := Printer.Canvas.TextWidth(Title) div 2;
     strhi := imagewide div 2 - strhi;
     Printer.Canvas.TextOut(strhi,50,Title);

     // show legend
     Y := Printer.Canvas.TextHeight(Title) * 2;
     Y := Y + 50;
     Title := 'RED: mean, BLACK: median, BOX: 25th to 75th percentile, WISKERS: 10th and 90th percentile';
     X := imagewide div 2 - Printer.Canvas.TextWidth(Title) div 2;
     Printer.Canvas.TextOut(X,Y,Title);

     Printer.Canvas.Pen.Color := clBlack;
     Printer.Canvas.Brush.Color := clWhite;

     // Draw chart border
     Printer.Canvas.Rectangle(hleft,vtop,hright,vbottom);
     vbottom := vbottom - 400; // decrease bottom
     vhi := vbottom - vtop;

     // Draw vertical axis
     valincr := (max - min) / 20.0;
     for i := 1 to 21 do
     begin
          Title := format('%8.2f',[max - ((i-1)*valincr)]);
          strwide := Printer.Canvas.TextWidth(Title);
          strhi := Printer.Canvas.TextHeight(Title);
          xpos := 20 + hleft;
          Yvalue := max - (valincr * (i-1));
          ypos := round(vhi * ( (max - Yvalue) / (max - min)));
          ypos := ypos + vtop - strhi div 2;
          Printer.Canvas.TextOut(xpos,ypos,Title);
     end;
     Printer.Canvas.MoveTo(hleft + strwide + 50,vtop);
     Printer.Canvas.LineTo(hleft + strwide + 50,vbottom+20);
     hwide := hwide - (strwide + 50);
     hleft := hleft + strwide + 50;
     HTickSpace := hwide div (nbars + 1);
     barwidth := HTickSpace div 2;

     // draw horizontal axis
     Printer.Canvas.MoveTo(hleft,vbottom + 20);
     Printer.Canvas.LineTo(hright,vbottom + 20);
     for i := 1 to nbars do
     begin
          ypos := vbottom + 10;
          xpos := round((hwide / (nbars+1))* i + hleft);
          Printer.Canvas.MoveTo(xpos,ypos);
          ypos := ypos + 10;
          Printer.Canvas.LineTo(xpos,ypos);
          Title := format('%d',[i]);
          offset := Printer.Canvas.TextWidth(Title) div 2;
          strhi := Printer.Canvas.TextHeight(Title);
          xpos := xpos - offset;
          ypos := ypos + strhi;
          Printer.Canvas.Pen.Color := clBlack;
          Printer.Canvas.TextOut(xpos,ypos,Title);
          xpos := hleft;
          Printer.Canvas.TextOut(xpos,ypos,'GROUPS:');
     end;

    for i := 1 to nbars do
    begin
        colcycle := i mod 4; // select a color for box
        if (colcycle = 0) then Printer.Canvas.Brush.Color := clBlue;
        if (colcycle = 1) then Printer.Canvas.Brush.Color := clGreen;
        if (colcycle = 2) then Printer.Canvas.Brush.Color := clFuchsia;
        if (colcycle = 3) then Printer.Canvas.Brush.Color := clLime;

        // plot the box front face
        X9 := round(hleft + ((i) * HTickSpace) - (barwidth / 2));
        X10 := X9 + barwidth;
        X1 := X9;
        X2 := X10;
        Ypos:= round((((max - hiqrtl[i-1]) / (max - min)) * vhi) + vtop);
        Y1 := Ypos;
        Ypos := round((((max - lowqrtl[i-1]) / (max - min)) * vhi) + vtop);
        Y2 := Ypos;
        Printer.Canvas.Rectangle(X1,Y1,X2,Y2);

        // draw upper 90th percentile line and end
        X3 := round(X1 + barwidth / 2);
        Printer.Canvas.MoveTo(X3,Y1);
        Ypos := round((((max - ninetypcnt[i-1]) / (max - min)) * vhi) + vtop);
        Y3 := Ypos;
        Printer.Canvas.LineTo(X3,Y3);
        Printer.Canvas.MoveTo(X1,Y3);
        Printer.Canvas.LineTo(X2,Y3);

        // draw lower 10th percentile line and end
        Printer.Canvas.MoveTo(X3,Y2);
        Ypos := round((((max - tenpcnt[i-1]) / (max - min)) * vhi) + vtop);
        Y4 := Ypos;
        Printer.Canvas.LineTo(X3,Y4);
        Printer.Canvas.MoveTo(X1,Y4);
        Printer.Canvas.LineTo(X2,Y4);

        //plot the mean line
        Printer.Canvas.Pen.Width := 10;
        Printer.Canvas.Pen.Color := clRed;
        Printer.Canvas.Pen.Style := psDot;
        Ypos := round((((max - means[i-1]) / (max - min)) * vhi) + vtop);
        Y9 := Ypos;
        Printer.Canvas.MoveTo(X9,Y9);
        Printer.Canvas.LineTo(X10,Y9);
        Printer.Canvas.Pen.Color := clBlack;
        Printer.Canvas.Pen.Style := psSolid;

        //plot the median line
        Printer.Canvas.Pen.Color := clBlack;
        Ypos := round((((max - median[i-1]) / (max - min)) * vhi) + vtop);
        Y9 := Ypos;
        Printer.Canvas.MoveTo(X9,Y9);
        Printer.Canvas.LineTo(X10,Y9);
        Printer.Canvas.Pen.Color := clBlack;

    end;
    Printer.EndDoc;
    Printer.Orientation := poPortrait;
end;
}

//--------------------------------------------------------------------------

procedure TBoxPlotFrm.BoxPlot(nbars: integer;
                              max, min: double;
                              var lowqrtl: DblDyneVec;
                              var hiqrtl: DblDyneVec;
                              var tenpcnt: DblDyneVec;
                              var ninetypcnt: DblDyneVec;
                              var means: DblDyneVec;
                              var median: DblDyneVec);
const
  BOX_COLORS: Array[0..3] of TColor = (clBlue, clGreen, clFuchsia, clLime);
var
  i, HTickSpace, imagewide, imagehi, vtop, vbottom, offset: integer;
  vhi, hleft, hright, hwide, barwidth, Xpos, Ypos, strhi: integer;
  XOffset, YOffset: integer;
  X, Y: integer;
  X1, X2, X3, X9, X10: integer; // X coordinates for box and lines
  Y1, Y2, Y3, Y4, Y9: integer; // Y coordinates for box and lines
  Title: string;
  valincr, Yvalue: double;
begin
  BlankFrm.Show;
  //BlankFrm.Image1.Canvas.Clear;

  imagewide := BlankFrm.Image1.width;
  imagehi := BlankFrm.Image1.Height;
  XOffset := imagewide div 10;
  YOffset := imagehi div 10;

  vtop := YOffset;
  vbottom := imagehi - YOffset;
  vhi := vbottom - vtop;
  hleft := XOffset;
  hright := imagewide - hleft - XOffset;
  hwide := hright - hleft;
  HTickSpace := hwide div nbars;
  barwidth := HTickSpace div 2;


  // Show title
  Title := 'BOXPLOT FOR : ' + OS3MainFrm.FileNameEdit.Text;
  BlankFrm.Caption := Title;
(*
  // show legend
  Y := BlankFrm.Image1.Canvas.TextHeight(Title) * 2;
  Y := Y + vtop;
  Title := 'RED: mean, BLACK: median, BOX: 25th to 75th percentile, WISKERS: 10th and 90th percentile';
  X := imagewide div 2 - BlankFrm.Canvas.TextWidth(Title) div 2;
  BlankFrm.Image1.Canvas.TextOut(X,Y,Title);
  *)

  // Draw chart background and border
  BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  BlankFrm.Image1.Canvas.Brush.Color := clWhite;
  BlankFrm.Image1.Canvas.Rectangle(0,0,imagewide,imagehi);

  // show legend
  Y := 2;
  Title := 'RED: mean, BLACK: median, BOX: 25th to 75th percentile, WISKERS: 10th and 90th percentile';
  X := imagewide div 2 - BlankFrm.Canvas.TextWidth(Title) div 2;
  BlankFrm.Image1.Canvas.TextOut(X,Y,Title);

  // Draw vertical axis
  valincr := (max - min) / 20.0;
  for i := 1 to 21 do
  begin
    Title := format('%8.2f',[max - ((i-1)*valincr)]);
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    xpos := XOffset;
    Yvalue := max - (valincr * (i-1));
    ypos := round(vhi * ( (max - Yvalue) / (max - min)));
    ypos := ypos + vtop - strhi div 2;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
  end;
  BlankFrm.Image1.Canvas.MoveTo(hleft,vtop);
  BlankFrm.Image1.Canvas.LineTo(hleft,vbottom);

  // draw horizontal axis
  BlankFrm.Image1.Canvas.MoveTo(hleft,vbottom + 10 );
  BlankFrm.Image1.Canvas.LineTo(hright,vbottom + 10);
  for i := 1 to nbars do
  begin
    ypos := vbottom + 10;
    xpos := round((hwide / nbars)* i + hleft);
    BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
    ypos := ypos + 10;
    BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
    Title := format('%d',[i]);
    offset := BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
    strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
    xpos := xpos - offset;
    ypos := ypos + strhi - 2;
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
    xpos := 20;
    BlankFrm.Image1.Canvas.TextOut(xpos,ypos,'GROUPS:');
  end;

  for i := 1 to nbars do
  begin
    BlankFrm.Image1.Canvas.Brush.Color := BOX_COLORS[i mod 4];

    // plot the box front face
    X9 := round(hleft + ((i) * HTickSpace) - (barwidth / 2));
    X10 := X9 + barwidth;
    X1 := X9;
    X2 := X10;
    Y1 := round((((max - hiqrtl[i-1]) / (max - min)) * vhi) + vtop);
    Y2 := round((((max - lowqrtl[i-1]) / (max - min)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.Rectangle(X1,Y1,X2,Y2);

    // draw upper 90th percentile line and end
    X3 := round(X1 + barwidth / 2);
    BlankFrm.Image1.Canvas.MoveTo(X3,Y1);
    Y3 := round((((max - ninetypcnt[i-1]) / (max - min)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.LineTo(X3,Y3);
    BlankFrm.Image1.Canvas.MoveTo(X1,Y3);
    BlankFrm.Image1.Canvas.LineTo(X2,Y3);

    // draw lower 10th percentile line and end
    BlankFrm.Image1.Canvas.MoveTo(X3,Y2);
    Y4 := round((((max - tenpcnt[i-1]) / (max - min)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.LineTo(X3,Y4);
    BlankFrm.Image1.Canvas.MoveTo(X1,Y4);
    BlankFrm.Image1.Canvas.LineTo(X2,Y4);

    //plot the means line
    BlankFrm.Image1.Canvas.Pen.Color := clRed;
    BlankFrm.Image1.Canvas.Pen.Style := psDot;
    Y9 := round((((max - means[i-1]) / (max - min)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.MoveTo(X9,Y9);
    BlankFrm.Image1.Canvas.LineTo(X10,Y9);
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    BlankFrm.Image1.Canvas.Pen.Style := psSolid;

    //plot the median line
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
    Y9 := round((((max - median[i-1]) / (max - min)) * vhi) + vtop);
    BlankFrm.Image1.Canvas.MoveTo(X9,Y9);
    BlankFrm.Image1.Canvas.LineTo(X10,Y9);
    BlankFrm.Image1.Canvas.Pen.Color := clBlack;
  end;
end;


initialization
  {$I boxplotunit.lrs}

end.

