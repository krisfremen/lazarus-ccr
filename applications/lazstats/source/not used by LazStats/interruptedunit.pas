unit InterruptedUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, MainUnit, Globals, DataProcs, OutPutUnit,
  AutoPlotUnit, GraphLib;

type

  { TInterruptedFrm }

  TInterruptedFrm = class(TForm)
    CorrChk: TCheckBox;
    PreInBtn: TBitBtn;
    PreOutBtn: TBitBtn;
    PostInBtn: TBitBtn;
    PostOutBtn: TBitBtn;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    VarList: TListBox;
    PreList: TListBox;
    PostList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PostInBtnClick(Sender: TObject);
    procedure PostOutBtnClick(Sender: TObject);
    procedure PreInBtnClick(Sender: TObject);
    procedure PreOutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure matinverse(Sender: TObject);
    procedure plotit( Sender: TObject);
    procedure PlotFuncs(Sender: TObject);

  private
    { private declarations }
   z : DblDyneVec;
   y : DblDyneVec;
   x : DblDyneMat;
   x1 : array[1..4,1..4] of double;
   x2 : array[1..4,1..4] of double;
   x3 : array[1..4] of double;
   t : array[1..4] of double;
   p : array[1..100] of double;
   p1 : array[1..4] of double;
   ii3 : array[1..4,1..3] of double;
   p2 : array[1..4] of double;
   s : array[1..4] of double;
   t2 : array[1..4] of double;
   b : array[1..4,1..1] of double;
   x4 : array[1..50,1..10] of double;
   d : array[1..50,1..5] of double;
   r : array[1..50] of double;
   x5 : array[1..50,1..11] of double;
   a1 : array[1..10] of double;
   a2 : array[1..10] of double;
   r2 : array[1..10] of double;
   e : array[1..10] of double;
   f2 : array[1..5,1..10] of double;
   pl : string;
   f1s, g1s, g2s, g3s, g4s, g5s, g6s, g7s, g8s : string;
   c9, g, c, g1, t3, t4, t5, t6, f4, n7, d7, y1, xx3, f1, f2x, s1 : double;
   s3, s4, h, f3, y2, a, det, amax : double;
   col, n, n1, n2, n4, n5, n6, m, l1, l2, i3, t1, NoGoodCases : integer;
   n3, j1, m1, i1, R1 : integer;

  public
    { public declarations }
  end; 

var
  InterruptedFrm: TInterruptedFrm;

implementation

{ TInterruptedFrm }

procedure TInterruptedFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     PreList.Clear;
     PostList.Clear;
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
     PreOutBtn.Visible := false;
     PostOutBtn.Visible := false;
     PreInBtn.Visible := true;
     PostInBtn.Visible := true;
end;

procedure TInterruptedFrm.FormShow(Sender: TObject);
begin
     ResetBtnClick(Self);
end;

procedure TInterruptedFrm.ComputeBtnClick(Sender: TObject);
label 300;
var
   i, i2, j, j2, j3, k : integer;
   ColNoSelected : IntDyneVec;
   rxy : DblDyneVec;
   heading : string;
begin
   g1s := 't..change in level  ';
   g2s := 't..change in slope  ';
   g3s := 'scaled posterior    ';
   g4s := 'lower 99 percent    ';
   g5s := 'lower 95 percent    ';
   g6s := 'delta               ';
   g7s := 'upper 95 percent    ';
   g8s := 'upper 99 percent    ';
   c9 := 1.0E-15;
   n1 := 0;
   n2 := 0;
   g := 0.01;
   NoGoodCases := 0;
   OutPutFrm.RichEdit.Clear;
   OutPutFrm.RichEdit.Lines.Add('Interrupted Time Series Analysis');
   OutPutFrm.RichEdit.Lines.Add('');
   OutPutFrm.RichEdit.Lines.Add('Adapted from the Fortran program written by Glass and Maguire');
   OutPutFrm.RichEdit.Lines.Add('and based on Box and Tiao IMA(1,1) procedure.  Published in');
   OutPutFrm.RichEdit.Lines.Add('How To Do Psychotherapy and How to Evaluate It by');
   OutPutFrm.RichEdit.Lines.Add('John M. Gottman and Sandra R. Leiblum, Holt, Rinehart and ');
   OutPutFrm.RichEdit.Lines.Add('Winston, Inc., New York, 1974.');
   OutPutFrm.RichEdit.Lines.Add('');
   n1 := PreList.Items.Count;
   n2 := PostList.Items.Count;
   t1 := n1 + n2;
   if t1 < 5 then
   begin
        ShowMessage('There must be more than 4 total values in the series.');
        exit;
   end;
   // allocate space
   SetLength(z,t1);
   SetLength(y,t1);
   SetLength(x,t1,4);
   SetLength(ColNoSelected,t1);
   SetLength(rxy,t1);

   // Get column numbers of variables selected
   for i := 1 to n1 do
   begin
        for j := 1 to NoVariables do
        begin
             if PreList.Items.Strings[i-1] = OS3MainFrm.DataGrid.Cells[j,0] then
                  ColNoSelected[i-1] := j;
        end;
   end;
   for i := 1 to n2 do
   begin
        for j := 1 to NoVariables do
        begin
             if PostList.Items.Strings[i-1] = OS3MainFrm.DataGrid.Cells[j,0] then
                  ColNoSelected[n1+i-1] := j;
        end;
   end;

   // read pre and post values - average for the cases
   for j := 0 to t1-1 do z[j] := 0.0;
   for i := 1 to NoCases do
   begin
        if NOT GoodRecord(i,t1,ColNoSelected) then continue;
        for j := 0 to t1-1 do
        begin
             col := ColNoSelected[j];
             z[j] := z[j] + StrToFloat(OS3MainFrm.DataGrid.Cells[col,i]);
             NoGoodCases := NoGoodCases + 1;
        end;
   end;
   for j := 0 to t1-1 do z[j] := z[j] / NoGoodCases;

   // plot correlograms
   for j3 := 1 to 4 do
   begin
        case j3 of
        1 : begin
                 f1s := 'Pre-Treatment Data';
                 n4 := n1;
                 l1 := 1;
                 l2 := n1;
                 OutPutFrm.RichEdit.Lines.Add('Correlogram of Pre-Treatment Raw Data');
                 heading := 'Correlogram of Pre-Treatment Raw Data';
                 i2 := 0;
                 for i := l1 to l2 do
                 begin
                      i2 := i2 + 1;
                      y[i2-1] := z[i-1];
                 end;
            end;
        2 : begin
                 f1s := 'Post-Treatment Data';
                 n4 := n2;
                 l1 := n1 + 1;
                 l2 := t1;
                 OutPutFrm.RichEdit.Lines.Add('');
                 OutPutFrm.RichEdit.Lines.Add('Correlogram of Post-Treatment Raw Data');
                 heading := 'Correlogram of Post-Treatment Raw Data';
                 i2 := 0;
                 for i := l1 to l2 do
                 begin
                      i2 := i2 + 1;
                      y[i2-1] := z[i-1];
                 end;
            end;
        3 : begin
                 f1s := 'Pre-Treatment Data';
                 n4 := n1 - 1;
                 l1 := 1;
                 l2 := n1 - 1;
                 OutPutFrm.RichEdit.Lines.Add('');
                 OutPutFrm.RichEdit.Lines.Add('Correlogram of Pre-Treatment Differences');
                 heading := 'Correlogram of Pre-Treatment Differences';
                 i2 := 0;
                 for i := l1 to l2 do
                 begin
                      i2 := i2 + 1;
                      i3 := i + 1;
                      y[i2-1] := z[i3-1] - z[i-1];
                 end;
            end;
        4 : begin
                 f1s := 'Post-Treatment Data';
                 n4 := n2-1;
                 l1 := n1 + 1;
                 l2 := t1 - 1;
                 OutPutFrm.RichEdit.Lines.Add('');
                 OutPutFrm.RichEdit.Lines.Add('Correlogram of Post-Treatment Differences');
                 heading := 'Correlogram of Post-Treatment Differences';
                 i2 := 0;
                 for i := l1 to l2 do
                 begin
                      i2 := i2 + 1;
                      i3 := i + 1;
                      y[i2-1] := z[i3-1] - z[i-1];
                 end;
            end;
        end;
        j2 := n4 * 3 div 4;
        for k := 1 to j2 do
        begin
             n5 := n4 - k;
             c := 0.0;
             t3 := 0.0;
             t4 := 0.0;
             t5 := 0.0;
             t6 := 0.0;
             for i := 1 to n5 do
             begin
                  n6 := i + k;
                  c := c + y[i-1] * y[n6-1];
                  t3 := t3 + y[i-1];
                  t4 := t4 + y[n6-1];
                  t5 := t5 + y[i-1] * y[i-1];
                  t6 := t6 + y[n6-1] * y[n6-1];
             end;
             f4 := n5;
             n7 := c - (t3 * t4) / f4;
             d7 := (t5 - (t3 * t3) / f4) * (t6 - (t4 * t4) / f4);
             if d7 > 0.0 then
             begin
                  d7 := sqrt(d7);
                  r[k] := n7 / d7;
             end
             else r[k] := 1.0;
             pl := format('lag %3d   r %4.2f',[k,r[k]]);
             OutPutFrm.RichEdit.Lines.Add(pl);
        end; // next k
        s4 := 1;
        n := 1;
        m := j2;
        for i := 1 to j2 do x4[i,1] := r[i];
//        plotit(Self);
        if CorrChk.Checked then
        begin
             rxy[0] := 0.0;
             for i := 1 to j2 do rxy[i] := r[i];
             AutoPlotFrm.PlotPartCors := false;
             AutoPlotFrm.PlotLimits := false;
             AutoPlotFrm.correlations := rxy;
             AutoPlotFrm.partcors := rxy;
             AutoPlotFrm.uplimit := 0.99;
             AutoPlotFrm.lowlimit := -0.99;
             AutoPlotFrm.npoints := j2+1;
             AutoPlotFrm.DepVarEdit := heading;
             AutoPlotFrm.ShowModal;
        end;
   end; // next j3
   OutPutFrm.ShowModal;
   OutPutFrm.RichEdit.Clear;

   // Now do the analysis
   OutPutFrm.RichEdit.Lines.Add('');
   OutPutFrm.RichEdit.Lines.Add('             residual             t for    change in  t for');
   OutPutFrm.RichEdit.Lines.Add('    gamma    variance    level    level    level      change');
300:
   y[0] := z[0];
   for i := 1 to t1-1 do
   begin
        i1 := i - 1;
        y1 := abs(y[i1]);
        if (y1 - c9) <= 0.0 then y[i] := z[i] - z[i1]
        else if (y1 - 0.000001) > 0 then y[i] := (z[i] - z[i1]) + (1.0 - g) * y[i1];
        g1 := abs(1.0 - g);
        if (g1 - 0.001) > 0 then y[i] := (z[i] - z[i1]) + (1.0 - g) * y[i1]
        else y[i] := z[i] - z[i1];
   end;
   for i := 0 to t1 - 1 do x[i,0] := 1;
   for i := 1 to n1 do x[i-1,1] := 0.0;
   for i := n1 + 1 to t1 do x[i-1,1] := 1.0;
   x[0,2] := 1.0;
   x[1,2] := 1.0 - g;
   for i := 2 to t1-1 do
   begin
        i1 := i - 1;
        x[i,2] := x[1,2] * x[i1,2];
        xx3 := abs(x[i,2]);
        if (c9 - xx3) <= 0.0 then continue;
        x[i,2] := 0.0;
   end;
   for i := 1 to n1 do x[i-1,3] := 0.0;
   for i := n1 to t1-1 do
   begin
        i1 := i-n1;
        x[i,3] := x[i1,2];
        xx3 := abs(x[i,3]);
        if (c9 - xx3) <= 0.0 then continue;
        x[i,3] := 0.0;
   end;
   for i := 1 to 4 do
   begin
        for j := 1 to 4 do
        begin
             x2[i,j] := 0.0;
             x1[i,j] := 0.0;
        end;
   end;
   for i := 1 to 4 do
       for j := 1 to 4 do
           for k := 1 to t1 do
               x2[i,j] := x2[i,j] + x[k-1,i-1] * x[k-1,j-1];
   for i := 1 to 4 do
       for j := 1 to 4 do
           x1[i,j] := x2[i,j];
   for i := 1 to 4 do x3[i] := 0.0;
   for i := 1 to 4 do
       for j := 1 to t1 do
           x3[i] := x3[i] + x[j-1,i-1] * y[j-1];
   for i := 1 to 4 do b[i,1] := x3[i];
   matinverse(Self);
   for i := 1 to 4 do t[i] := b[i,1];
   for i := 1 to 4 do s[i] := x1[i,i];
   f1 := t1;
   y1 := 0.0;
   for i := 0 to t1-1 do
   begin
        y1 := y1 + y[i] * y[i];
   end;
   for i := 1 to 4 do x3[i] := 0.0;
   for j := 1 to 4 do
       for i := 1 to 4 do
       begin
           x3[j] := x3[j] + t[i] * x2[i,j];
       end;
   f2x := 0.0;
   for i := 1 to 4 do
   begin
        f2x := f2x + x3[i] * t[i];
   end;
   s1 := y1 - f2x;
   s1 := s1 / (f1 - 4.0);
   for i := 1 to 4 do
   begin
        s[i] := sqrt(s1 * s[i]);
        t2[i] := t[i] / s[i];
   end;
   s3 := ln(s1);
   det := ln(det);
   h := (-0.5 * det) - (0.5 * (f1 - 4.0) * s3);
   h := 0.4342945 * h;
   j1 := j1 + 1;
   x5[j1,1] := g;
   x5[j1,2] := s1;
   x5[j1,3] := t[3];
   x5[j1,4] := t2[3];
   x5[j1,5] := t[4];
   x5[j1,6] := t2[4];
   x5[j1,7] := t[1];
   x5[j1,8] := t2[1];
   x5[j1,9] := t[2];
   x5[j1,10] := t2[2];
   if (t1 - 30) >= 0 then
   begin
        d[j1,1] := t[4] - 2.58 * s[4];
        d[j1,2] := t[4] - 1.96 * s[4];
        d[j1,3] := t[4];
        d[j1,4] := t[4] + 1.96 * s[4];
        d[j1,5] := t[4] + 2.58 * s[4];
   end;
   n3 := n3 + 1;
   p[n3] := h;
   g := g + 0.04;
   if (n3 - 49) <= 0 then goto 300;
   f3 := p[1];
   for i := 2 to 49 do if (f3 - p[i]) < 0 then f3 := p[i];
   for i := 1 to 49 do
   begin
        p[i] := p[i] - f3;
        y2 := abs(p[i]);
        if (y2 - 35) >= 0 then p[i] := 0.0
        else begin
             p[i] := p[i] / 0.4342945;
             p[i] := exp(p[i]);
        end;
   end;
   a := 0.0;
   for i := 2 to 49 do
   begin
        i2 := i - 1;
        a := a + 0.005 * (p[i] + p[i1]);
   end;
   for i := 1 to 49 do p[i] := p[i] / a;
   for i := 1 to 49 do x5[i,11] := p[i];
   for i := 1 to 49 do
   begin
        pl := format('%2d    ',[i]);
        for j := 1 to 6 do
             pl := pl + format('%6.2f   ',[x5[i,j]]);
        OutPutFrm.RichEdit.Lines.Add(pl);
   end;

   OutPutFrm.ShowModal;
   OutPutFrm.RichEdit.Clear;
   OutPutFrm.RichEdit.Lines.Add('');
   OutPutFrm.RichEdit.Lines.Add('');
   pl := '                    t for     change in   t for      scaled';
   OutPutFrm.RichEdit.Lines.Add(pl);
   pl := '         slope      slope     slope       change     posterior';
   OutPutFrm.RichEdit.Lines.Add(pl);
   for i := 1 to 49 do
   begin
        pl := format('%2d    ',[i]);
        for j := 7 to 11 do
            pl := pl + format('%6.2f      ',[x5[i,j]]);
        OutPutFrm.RichEdit.Lines.Add(pl);
   end;

   OutPutFrm.ShowModal;
   OutPutFrm.RichEdit.Clear;
   OutPutFrm.RichEdit.Lines.Add('');
   OutPutFrm.RichEdit.Lines.Add('');
   OutPutFrm.RichEdit.Lines.Add('');
   for i := 1 to 49 do
   begin
        x4[i,1] := x5[i,5];
        x4[i,2] := x5[i,9];
        x4[i,3] := x5[i,11];
   end;
   m := 49;
   n := 3;
   i3 := 1;
   f1s := g1s + g2s + g3s;
   PlotFuncs(Self);
   plotit(Self); // plot the f[i,j] values
   OutPutFrm.ShowModal;
   OutPutFrm.RichEdit.Clear;
   n := 5;
   if (t1 - 30) >= 0 then
   begin // do confidence intervals around delta
         for i := 1 to 49 do
             for j := 1 to 5 do
                 x4[i,j] := d[i,j];
         f1s := g4s + g5s + g6s + g7s + g8s;
         pl := 'Confidence Intervals Around Delta';
         OutPutFrm.RichEdit.Lines.Add(pl);
         pl := 'gamma          lower 99      lower 95      delta       upper 95      upper 99';
         OutPutFrm.RichEdit.Lines.Add(pl);
         for i := 1 to 49 do
         begin
              pl := format('%6.2f        ',[x5[i,1]]);
              for j := 1 to 5 do
                  pl := pl + format('%6.2f        ',[d[i,j]]);
              OutPutFrm.RichEdit.Lines.Add(pl);
         end;
         OutPutFrm.RichEdit.Lines.Add('');
         pl := 'Graph of Confidence Intervals Around Delta Hat';
         OutPutFrm.RichEdit.Lines.Add(pl);
         plotit(Self); // plot f matrix
   end;

   OutPutFrm.ShowModal;

   // clean up
   rxy := nil;
   ColNoSelected := nil;
   x := nil;
   y := nil;
   z := nil;
end;

procedure TInterruptedFrm.PostInBtnClick(Sender: TObject);
VAR i, index : integer;
begin
   index := VarList.Items.Count;
   i := 0;
   while i < index do
   begin
         if (VarList.Selected[i]) then
         begin
              PostList.Items.Add(VarList.Items.Strings[i]);
              VarList.Items.Delete(i);
              index := index - 1;
              i := 0;
         end
         else i := i + 1;
   end;
   PostOutBtn.Visible := true;
   if VarList.Items.Count = 0 then PostInBtn.Visible := false;
end;

procedure TInterruptedFrm.PostOutBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := PostList.ItemIndex;
     if index >= 0 then
     begin
          VarList.Items.Add(PostList.Items.Strings[index]);
          PostList.Items.Delete(index);
          PostInBtn.Visible := true;
          if PostList.Items.Count = 0 then PostOutBtn.Visible := false;
     end;
end;

procedure TInterruptedFrm.PreInBtnClick(Sender: TObject);
VAR i, index : integer;
begin
   index := VarList.Items.count;
   i := 0;
   while i < index do
   begin
         if (VarList.Selected[i]) then
         begin
              PreList.Items.Add(VarList.Items.Strings[i]);
              VarList.Items.Delete(i);
              index := index - 1;
              i := 0;
         end
         else i := i + 1;
   end;
   PreOutBtn.Visible := true;
   if VarList.Items.Count = 0 then PreInBtn.Visible := false;
end;

procedure TInterruptedFrm.PreOutBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := PreList.ItemIndex;
     if index >= 0 then
     begin
          VarList.Items.Add(PreList.Items.Strings[index]);
          PreList.Items.Delete(index);
          PreInBtn.Visible := true;
          if PreList.Items.Count = 0 then PreOutBtn.Visible := false;
     end;
end;

procedure TInterruptedFrm.matinverse(Sender: TObject);
var
   i, j, j2, j4, k, L, Lc : integer;
   temp : double;
begin
    //Matrix inverse and determinant

    det := 1;
    m1 := 1;
    N := 4;
    For i := 1 To 4 do
    begin
        p1[i] := 0.0;
        For j := 1 To 2 do ii3[i, j] := 0.0;
    end;
    For i := 1 To N do
    begin
        amax := 0.0;
        For j := 1 To N do
        begin
            If (p1[j] - 1) <> 0 Then
            begin
                For k := 1 To N do
                begin
                    If (p1[k] - 1) <> 0 Then
                    begin
                        If (p1[k] - 1) > 0 Then Exit;
                        If Abs(amax) - Abs(x1[j, k]) <= 0 Then
                        begin
                            R1 := j;
                            i1 := k;
                            amax := x1[j, k];
                        End;
                    End;
                end;
            End;
        end;
        p1[i1] := p1[i1] + 1;
        If (R1 - i1) <> 0 Then //Swap
        begin
            det := -det;
            For L := 1 To N do
            begin
                s4 := x1[R1, L];
                x1[R1, L] := x1[i1, L];
                x1[i1, L] := s4;
            end;
            If m1 > 0 Then //Swap
            begin
                For L := 1 To m1 do
                begin
                    s4 := b[R1, L];
                    b[R1, L] := b[i1, L];
                    b[i1, L] := s4;
                end;
            End;
        End;
        ii3[i, 1] := R1;
        ii3[i, 2] := i1;
        p2[i] := x1[i1, i1];
        det := det * p2[i];
        If p2[i] = 0 Then
        begin
            ShowMessage('A singular matrix was found.');
            Exit;
        End;
        x1[i1, i1] := 1;
        For L := 1 To N do
        begin
            x1[i1, L] := x1[i1, L] / p2[i];
        end;
        If m1 > 0 Then
        begin
            For L := 1 To m1 do
            begin
                b[i1, L] := b[i1, L] / p2[i];
            end;
        End;
        For Lc := 1 To N do
        begin
            If (Lc - i1) <> 0 Then
            begin
                temp := x1[Lc,i1];
                x1[L1,i1] := 0.0;
                For L := 1 To N do
                begin
                    x1[Lc,L] := x1[Lc,L] - x1[i1,L] * temp;
                end;
                If m1 > 0 Then
                begin
                    For L := 1 To m1 do
                        b[L1, L] := b[L1, L] - b[i1, L] * temp;
                End;
            End;
        end;
    end;
    For i := 1 To N do
    begin
        L := N + 1 - i;
        If (ii3[L, 1] - ii3[L, 2]) <> 0 Then
        begin
            j2 := round(ii3[L, 1]);
            j4 := round(ii3[L, 2]);
            For k := 1 To N do
            begin
                s4 := x1[k, j2];
                x1[k, j2] := x1[k, j4];
                x1[k, j4] := s4;
            end;
        End;
    end;
end;
//--------------------------------------------------------------------

procedure TInterruptedFrm.plotit( Sender: TObject);
label 2180, 2660;
var
   i, i2, ip, j, k, L, n8 : integer;
   bstr, p1str, p2str : string;
   c5, z2 : double;

begin
    For i := 1 To N do
    begin
        a1[i] := 1E+37;
        a2[i] := -1E+37;
    end;
    bstr := '153510cmha';
    For i := 1 To M do
    begin
        For j := 1 To N do
        begin
            c5 := x4[i, j] - a1[j];
            If c5 >= 0 Then goto 2180;
            a1[j] := x4[i, j];
2180:       c5 := x4[i, j] - a2[j];
            If c5 <= 0 Then continue;
            a2[j] := x4[i, j];
        end;
    end;
    If (N - 5) = 0 Then
    begin
        For j := 1 To 5 do
        begin
            a2[j] := a2[5];
            a1[j] := a1[1];
        end;
    End;
    n8 := N;
    For j := 1 To N do
    begin
        r2[j] := (a2[j] - a1[j]) / 55;
    end;
    For j := 1 To N do
    begin
        e[j] := (a2[j] - a1[j]) / 4;
        f2[1, j] := a1[j] + 0.05;
        c5 := a1[j];
        If c5 < 0 Then
        begin
            f2[1, j] := f2[1, j] - 0.1;
        End;
        f2[5, j] := a2[j] - 0.05;
        c5 := a2[j];
        If c5 < 0 Then
        begin
            f2[5, j] := f2[5, j] - 0.1;
        End;
        f2[2, j] := a1[j] + e[j] + 0.05;
        c5 := f2[2, j];
        If c5 < 0 Then
        begin
            f2[2, j] := f2[2, j] - 0.1;
        End;
        f2[3, j] := a1[j] + e[j] * 2 + 0.05;
        c5 := f2[3, j];
        If c5 < 0 Then
        begin
            f2[3, j] := f2[3, j] - 0.1;
        End;
        f2[4, j] := a2[j] - e[j] + 0.05;
        c5 := f2[4, j];
        If c5 < 0 Then
        begin
            f2[4, j] := f2[4, j] - 0.1;
        End;
    end;

    For j := 1 To n8 do
    begin
        pl := bstr[j] + ' ';
        For i := 1 To 5 do
        begin
            pl := pl + format('%6.2f        ',[f2[i,j]]);
        end;
        pl := pl + copy(bstr, j, 1);
        OutPutFrm.RichEdit.Lines.Add(pl);
    end;
    pl := '';
    OutPutFrm.RichEdit.Lines.Add('----------------------------------------------------------------------');

    for i2 := 1 to 73 do
    begin
         p2str := p2str + ' ';
         p1str := p1str + ' ';
    end;
    For i := 1 To M do
    begin
        For i2 := 1 To 72 do p1str[i2] := ' ';
        k := 0;
        p1str[1] := '.';
        For i2 := 1 To 5 do
        begin
            k := k + 14;
            p1str[k] := '.';
        end;
        n7 := i;
        while N7 >= 0 do
        begin
            n7 := n7 - 10;
        end;
        If n7 >= 0 Then
        begin
            k := 3;
            p1str[k] := '-';
            For i2 := 3 To 30 do
            begin
                k := k + 2;
                p1str[k] := '-';
            end;
        End;
        For k := 1 To N do
        begin
            If r2[k] > 0 Then
                z2 := (x4[i, k] - a1[k]) / r2[k] + 1
            Else z2 := 0;
            L := round(z2);
            If (L - 1) < 0 Then L := 1;
            If (55 - L) < 0 Then L := 55;
            If (p1str[L] = ' ') Or (p1str[L] = '.') Or (p1str[L] = '-') Then
            begin
                p2str[k] := bstr[k];
                p1str[L] := p2str[k];
            end
            Else begin
                p1str[L] := '+';
            End;
        end;
        If (s4 - 1) = 0 Then goto 2660;
        OutPutFrm.RichEdit.Lines.Add('');
2660:
            pl := format('%2d.          ',[i]);
            For ip := 1 To 55 do pl := pl + p1str[ip];
            pl := pl + format('.  %2d',[i]);
            OutPutFrm.RichEdit.Lines.Add(pl);
    end;
    OutPutFrm.RichEdit.Lines.Add('----------------------------------------------------------------------');
    OutPutFrm.RichEdit.Lines.Add('');
    For j := 1 To n8 do
    begin
        pl := bstr[j] + ' ';
        For i := 1 To 5 do
        begin
            pl := pl + format('%6.2f        ',[f2[i,j]]);
        end;
        pl := pl + bstr[j];
        OutPutFrm.RichEdit.Lines.Add(pl);
    end;
    OutPutFrm.RichEdit.Lines.Add('');
    OutPutFrm.RichEdit.Lines.Add('');
    OutPutFrm.RichEdit.Lines.Add('          Plot Description');
    OutPutFrm.RichEdit.Lines.Add('title               character           minimum        maximum    resolution');

    For j := 1 To N do
    begin
        pl := copy(f1s,j*20-19,20);
        pl := pl + '     ' + bstr[j];
        pl := pl + '               ' + format('%6.2f',[a1[j]]);
        pl := pl + '     ' + format('%6.2f',[a2[j]]);
        pl := pl + '     ' + format('%6.2f',[r2[j]]);
        OutPutFrm.RichEdit.Lines.Add(pl);
    end;
    OutPutFrm.RichEdit.Lines.Add('');
    OutPutFrm.RichEdit.Lines.Add('');
end;
//-------------------------------------------------------------------

procedure TInterruptedFrm.PlotFuncs(Sender: TObject);
var
   i, j : integer;
   title : string;
   gamma : double;
begin
    // Allocate space for point sets of means
    SetLength(GraphFrm.Ypoints,3,50);
    SetLength(GraphFrm.Xpoints,3,50);
    // store points for means
    gamma := 0.0;
    for i := 1 to 49 do
    begin
         for j := 1 to 3 do
         begin
              GraphFrm.Ypoints[j-1,i-1] := x4[i,j];
              GraphFrm.Xpoints[j-1,i-1] := gamma;
         end;
         gamma := gamma + 0.04;
    end;
    title := 'Plot of ts for change in level and slope and posterior';
    GraphFrm.nosets := 3;
    GraphFrm.nbars := 49;
    GraphFrm.Heading := title;
    GraphFrm.SetLabels[1] := 'level';
    GraphFrm.SetLabels[2] := 'slope';
    GraphFrm.SetLabels[3] := 'posterior';
    GraphFrm.XTitle := 'Gamma Increment';
    GraphFrm.YTitle := 't';
    GraphFrm.barwideprop := 0.5;
    GraphFrm.AutoScale := true;
    GraphFrm.GraphType := 5; // 2d line chart
    GraphFrm.BackColor := clYellow;
    GraphFrm.WallColor := clBlack;
    GraphFrm.FloorColor := clLtGray;
    GraphFrm.ShowBackWall := true;
    GraphFrm.ShowModal;

    GraphFrm.Xpoints := nil;
    GraphFrm.Ypoints := nil;
end;

initialization
  {$I interruptedunit.lrs}

end.

