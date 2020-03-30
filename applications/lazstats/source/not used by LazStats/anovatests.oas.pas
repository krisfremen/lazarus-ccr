unit ANOVATests.oas;

{$MODE Delphi}

Interface

uses LCLIntf, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     FUNCTIONSLIB, OUTPUTUNIT, GLOBALS;


procedure TUKEY(error_ms : double;  { mean squared for residual }
                error_df : double;  { deg. freedom for residual }
                value    : double;  { size of smallest group }
                group_total : DblDyneVec;  { sum of scores in a group }
                group_count : DblDyneVec;  { no. of cases in a group }
                min_grp     : integer;    { minimum group code }
                max_grp     : integer);    { maximum group code }

procedure SCHEFFETEST(error_ms   : double;   { mean squared residual }
                  group_total : DblDyneVec; { sum of scores in a group }
                  group_count : DblDyneVec; { count of cases in a group }
                  min_grp     : integer;   { code of first group }
                  max_grp     : integer;   { code of last group  }
                  total_n     : double);      { total number of cases }

procedure Newman_Keuls(error_ms    : double;      { residual mean squared }
                       error_df    : double;      { deg. freedom for error }
                       value       : double;      { number in smallest group }
                       group_total : DblDyneVec; { sum of scores in a group }
                       group_count : DblDyneVec; { count of cases in a group }
                       min_grp     : integer;   { lowest group code }
                       max_grp     : integer);   { largest group code }

procedure TUKEY_KRAMER(error_ms      : double;   { residual mean squared }
                       error_df      : double;   { deg. freedom for error }
                       value         : double;   { number in smallest group }
                       group_total   : DblDyneVec; { sum of scores in group }
                       group_count   : DblDyneVec; { number of caes in group }
                       min_grp       : integer;   { code of lowest group }
                       max_grp       : integer);   { code of highst group }

procedure CONTRASTS(error_ms         : double;          { residual ms }
                    error_df         : double;          { residual df }
                    group_total      : DblDyneVec;     { group sums  }
                    group_count      : DblDyneVec;     { group cases }
                    min_grp          : integer;       { lowest code }
                    max_grp          : integer;       { highest code }
                    overall_probf    : double);          { prob of overall test }

procedure Bonferroni(  group_total   : DblDyneVec; { sum of scores in group }
                       group_count   : DblDyneVec; { number of caes in group }
                       group_var     : DblDyneVec; { group variances }
                       min_grp       : integer;   { code of lowest group }
                       max_grp       : integer);   { code of highst group }

procedure TUKEYBTEST(ErrorMS : double;       // within groups error
                     ErrorDF : double;       // degrees of freedom within
                     group_total : DblDyneVec;  // vector of group sums
                     group_count : DblDyneVec;  // vector of group n's
                     min_grp     : integer;  // smallest group code
                     max_grp     : integer;  // largest group code
                     groupsize   : double); // size of groups (all equal)

{ --------------------------------------------------------------------- }

Implementation

Uses BLKANOVAUNIT;

procedure TUKEY(error_ms : double;  { mean squared for residual }
                error_df : double;  { deg. freedom for residual }
                value    : double;  { size of smallest group }
                group_total : DblDyneVec;  { sum of scores in a group }
                group_count : DblDyneVec;  { no. of cases in a group }
                min_grp     : integer;    { minimum group code }
                max_grp     : integer);    { maximum group code }
var
   sig : boolean;
   divisor : double;
   df1 : integer;
   alpha : double;
   contrast, mean1, mean2 : double;
   q_stat : double;
   i,j : integer;
   outline : string;

begin
     alpha := StrToFloat(BlksAnovaFrm.PostAlpha.Text);
     OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
     OutPutFrm.RichEdit.Lines.Add('             Tukey HSD Test for Differences Between Means');
     outline := format('                            alpha selected = %4.2f',[alpha]);
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('Groups     Difference  Statistic      Probability  Significant?');
     OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
     divisor := sqrt(error_ms / value );
     for i := min_grp to max_grp - 1 do
         for j := i + 1 to max_grp do
         begin
              outline := format('%2d - %2d     ',[i,j]);
              mean1 := group_total[i-1] / group_count[i-1];
              mean2 := group_total[j-1] / group_count[j-1];
              contrast := mean1 - mean2;
              outline := outline + format('%7.3f     q = ',[contrast]);
              contrast := abs(contrast / divisor) ;
              outline := outline + format('%6.3f  ',[contrast]);
              df1 := max_grp - min_grp + 1;
              q_stat := STUDENT(contrast,error_df,df1);
              outline := outline + format('       %6.4f',[q_stat]);
              if alpha >= q_stat then sig := TRUE else sig := FALSE;
              if sig = TRUE then  outline := outline + '       YES '
              else outline := outline + '       NO';
              OutPutFrm.RichEdit.Lines.Add(outline);
         end;
         OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
end;

{ ------------------------------------------------------------------------ }

procedure SCHEFFETEST(error_ms   : double;   { mean squared residual }
                  group_total : DblDyneVec; { sum of scores in a group }
                  group_count : DblDyneVec; { count of cases in a group }
                  min_grp     : integer;   { code of first group }
                  max_grp     : integer;   { code of last group  }
                  total_n     : double);      { total number of cases }

var
   statistic, stat_var, stat_sd : double;
   mean1, mean2, alpha, difference, prob_scheffe, f_prob, df1, df2 : double;
   outline : string;
   i, j : integer;
begin
     alpha := StrToFloat(BlksAnovaFrm.PostAlpha.Text);
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('----------------------------------------------------------------');
     OutPutFrm.RichEdit.Lines.Add('                 Scheffe contrasts among pairs of means.');
     outline := format('                            alpha selected = %4.2f',[alpha]);
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('Group vs Group  Difference   Scheffe    Critical  Significant?');
     OutPutFrm.RichEdit.Lines.Add('                             Statistic  Value');
     OutPutFrm.RichEdit.Lines.Add('----------------------------------------------------------------');
     alpha := 1.0 - alpha ;
     for i:= min_grp to max_grp - 1 do
         for j := i + 1 to max_grp do
         begin
              outline := format('%2d        %2d      ',[i,j]);
              mean1 := group_total[i-1] / group_count[i-1];
              mean2 := group_total[j-1] / group_count[j-1];
              difference := mean1 - mean2;
              outline := outline + format('%8.2f ',[difference]);
              stat_var := error_ms *
                  ( 1.0 / group_count[i-1] + 1.0 / group_count[j-1]);
              stat_sd := sqrt(stat_var);
              statistic := abs(difference / stat_sd);
              outline := outline + format('%8.2f   ',[statistic]);
              df1 := max_grp - min_grp;
              df2 := total_n - df1 + 1;
              f_prob := fpercentpoint(alpha,round(df1),round(df2) );
              prob_scheffe := sqrt(df1 * f_prob);
              outline := outline + format('%8.3f     ',[prob_scheffe]);
              if statistic > prob_scheffe then outline := outline + 'YES'
              else outline := outline + 'NO';
              OutPutFrm.RichEdit.Lines.Add(outline);
        end;
        OutPutFrm.RichEdit.Lines.Add('----------------------------------------------------------------');
end;

{ ----------------------------------------------------------------------- }

procedure Newman_Keuls(error_ms    : double;      { residual mean squared }
                       error_df    : double;      { deg. freedom for error }
                       value       : double;      { number in smallest group }
                       group_total : DblDyneVec; { sum of scores in a group }
                       group_count : DblDyneVec; { count of cases in a group }
                       min_grp     : integer;   { lowest group code }
                       max_grp     : integer);   { largest group code }
var
    i, j : integer;
    temp1, temp2 : double;
    groupno : IntDyneVec;
    alpha : double;
    contrast, mean1, mean2 : double;
    q_stat : double;
    divisor : double;
    tempno : integer;
    df1 : integer;
    sig : boolean;
    outline : string;

begin
     SetLength(groupno,max_grp-min_grp+1);
     for i := min_grp to max_grp do groupno[i-1] := i;
     for i := min_grp to max_grp - 1 do
     begin
         for j := i + 1 to max_grp do
         begin
              if group_total[i-1] / group_count[i-1] >
                 group_total[j-1] / group_count[j-1] then
              begin
                   temp1 := group_total[i-1];
                   temp2 := group_count[i-1];
                   tempno := groupno[i-1];
                   group_total[i-1] := group_total[j-1];
                   group_count[i-1] := group_count[j-1];
                   groupno[i-1] := groupno[j-1];
                   group_total[j-1] := temp1;
                   group_count[j-1] := temp2;
                   groupno[j-1] := tempno;
              end;
         end;
     end;
     alpha := StrToFloat(BlksAnovaFrm.PostAlpha.Text);
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('----------------------------------------------------------------------');
     OutPutFrm.RichEdit.Lines.Add('            Neuman-Keuls Test for Contrasts on Ordered Means');
     outline := format('                            alpha selected = %4.2f',[alpha]);
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('Group     Mean');
     for i := 1 to max_grp do
     begin
          outline := format('%3d  %10.3f',[groupno[i-1],group_total[i-1] / group_count[i-1]]);
          OutPutFrm.RichEdit.Lines.Add(outline);
     end;
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('Groups     Difference  Statistic      d.f.   Probability  Significant?');
     OutPutFrm.RichEdit.Lines.Add('----------------------------------------------------------------------');
     divisor := sqrt(error_ms / value);
     for i := min_grp to max_grp - 1 do
     begin
         for j := i + 1 to max_grp do
         begin
              outline := format('%2d - %2d     ',[groupno[i-1],groupno[j-1]]);
              mean1 := group_total[i-1] / group_count[i-1];
              mean2 := group_total[j-1] / group_count[j-1];
              contrast := mean1 - mean2;
              outline := outline + format('%7.3f      q = ',[contrast]);
              contrast := abs(contrast / divisor );
              df1 := j - i + 1;
              outline := outline + format('%6.3f   %2d  %3.0f  ',[contrast,df1,error_df]);
              q_stat := STUDENT(contrast,error_df,df1);
              outline := outline + format('   %6.4f',[q_stat]);
              if alpha > q_stat then sig := TRUE else sig := FALSE;
              if sig = TRUE then outline := outline + '       YES'
                 else outline := outline + '       NO';
              OutPutFrm.RichEdit.Lines.Add(outline);
         end;
     end;
     OutPutFrm.RichEdit.Lines.Add('----------------------------------------------------------------------');
     groupno := nil;
end;

{ ----------------------------------------------------------------------- }

procedure TUKEY_KRAMER(error_ms      : double;   { residual mean squared }
                       error_df      : double;   { deg. freedom for error }
                       value         : double;   { number in smallest group }
                       group_total   : DblDyneVec; { sum of scores in group }
                       group_count   : DblDyneVec; { number of caes in group }
                       min_grp       : integer;   { code of lowest group }
                       max_grp       : integer);   { code of highst group }
var
   sig : boolean;
   divisor : double;
   df1 : integer;
   alpha : double;
   contrast, mean1, mean2 : double;
   q_stat : double;
   outline : string;
   i, j : integer;

begin
     alpha := StrToFloat(BlksAnovaFrm.PostAlpha.Text);
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
     OutPutFrm.RichEdit.Lines.Add('           Tukey-Kramer Test for Differences Between Means');
     outline := format('                     alpha selected = %4.2f',[alpha]);
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('Groups     Difference  Statistic      Probability  Significant?');
     OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
     for i := min_grp to max_grp - 1 do
         for j := i + 1 to max_grp do
         begin
              outline := format('%2d - %2d    ',[i,j]);
              mean1 := group_total[i-1] / group_count[i-1];
              mean2 := group_total[j-1] / group_count[j-1];
              contrast := mean1 - mean2;
              outline := outline + format('%7.3f     q = ',[contrast]);
              divisor := sqrt(error_ms *
                 ( ( 1.0/group_count[i-1] + 1.0/group_count[j-1] ) / 2 ) );
              contrast := abs(contrast / divisor) ;
              outline := outline + format('%6.3f  ',[contrast]);
              df1 := max_grp - min_grp + 1;
              q_stat := STUDENT(contrast,error_df,df1);
              outline := outline + format('       %6.4f',[q_stat]);
              if alpha >= q_stat then sig := TRUE else sig := FALSE;
              if sig = TRUE then outline := outline + '       YES '
              else outline := outline + '       NO';
              OutPutFrm.RichEdit.Lines.Add(outline);
         end;
         OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
end;

{ ------------------------------------------------------------------------ }

procedure CONTRASTS(error_ms         : double;          { residual ms }
                    error_df         : double;          { residual df }
                    group_total      : DblDyneVec;     { group sums  }
                    group_count      : DblDyneVec;     { group cases }
                    min_grp          : integer;       { lowest code }
                    max_grp          : integer;       { highest code }
                    overall_probf    : double);          { prob of overall test }
var
   nocontrasts, i, j, k : integer;
   df1, df2, probstat, statistic, alpha : double;
   coefficients : array[1..20,1..20] of double;
   nonorthog : boolean;
   weight, sumcross : double;
   response : string[5];
   outline : string;
   prompt : string;

begin
     outline := format('Enter the number of contrasts (less than %2d or 0:',[max_grp-min_grp+1]);
     response := InputBox('ORTHOGONAL CONTRASTS',outline,'0');
     nocontrasts := StrToInt(response);
     if nocontrasts > 0 then
     begin
          for i := 1 to nocontrasts do
          begin
               outline := format('Contrast number %2d',[i]);
               for j := 1 to (max_grp - min_grp+1) do
               begin
                    prompt := format('Group %2d coefficient = ',[j]);
                    response := InputBox(outline,prompt,'1');
                    coefficients[i,j] := StrToFloat(response);
               end;
          end;
          { Check for orthogonality }
          nonorthog := FALSE;
          for i := 1 to nocontrasts - 1 do
          begin
               for j := i + 1 to nocontrasts do
               begin
                    sumcross := 0;
                    for k := 1 to (max_grp - min_grp + 1) do
                    begin
                         sumcross := sumcross +
                               coefficients[i,k]*coefficients[j,k];
                    end;
                    if sumcross <> 0 then nonorthog := TRUE;
                    if sumcross <> 0 then
                    begin
                       outline := format('contrasts %2d and %2d not orthogonal.',[i,j]);
                       ShowMessage('ERROR!' + outline);
                    end;
               end;
          end;
          if NOT nonorthog then
          begin
               alpha := StrToFloat(BlksAnovaFrm.PostAlpha.Text);
               if overall_probf > alpha then
               begin
                    OutPutFrm.RichEdit.Lines.Add('No contrasts significant.');
                    exit;
               end;
               OutPutFrm.RichEdit.Lines.Add('');
               OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
               OutPutFrm.RichEdit.Lines.Add('                  ORTHOGONAL CONTRASTS');
               OutPutFrm.RichEdit.Lines.Add('Contrast  Statistic  Probability  Critical Value  Significant?');
               OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
               for i := 1 to nocontrasts do
               begin
                    statistic := 0.0;
                    weight := 0.0;
                    for j := 1 to (max_grp - min_grp + 1) do
                    begin
                         statistic := statistic + (coefficients[i,j] *
                            (group_total[j-1] / group_count[j-1]));
                         weight := weight + (sqr(coefficients[i,j]) /
                            group_count[j-1]);
                    end;
                    statistic := sqr(statistic);
                    statistic := statistic / (error_ms * weight);
                    outline := format('%3d       %9.4f    ',[i,statistic]);
                    df1 := 1;
                    df2 := error_df;
                    probstat := probf(statistic,round(df1),round(df2)) / 2;
                    outline := outline + format('%8.3f       %5.2f          ',[probstat,alpha]);
                    if probstat < alpha then outline := outline + 'YES'
                    else outline := outline + 'NO';
                    OutPutFrm.RichEdit.Lines.Add(outline);
               end;
               OutPutFrm.RichEdit.Lines.Add('');
               OutPutFrm.RichEdit.Lines.Add('Contrast Coefficients Used:');
               for i := 1 to nocontrasts do
               begin
                    outline := format('Contrast %2d ',[i]);
                    for j := 1 to (max_grp - min_grp + 1) do
                       outline := outline + format('%4.1f ',[coefficients[i,j]]);
                    OutPutFrm.RichEdit.Lines.Add(outline);
               end;
          end; { if orthogonal }
          OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
     end; { if nocontrasts > 0 }
end; { of procedure CONTRASTS }
{ ----------------------------------------------------------------------- }

procedure Bonferroni(  group_total   : DblDyneVec; { sum of scores in group }
                       group_count   : DblDyneVec; { number of cases in group }
                       group_var     : DblDyneVec; { group variances }
                       min_grp       : integer;   { code of lowest group }
                       max_grp       : integer);   { code of highst group }
var
    i, j : integer;
    alpha : double;
    contrast, mean1, mean2 : double;
    divisor : double;
    df2 : integer;
    outline : string;
    testalpha : double;
    NoGrps : integer;
    tprob : double;
    sig : string[6];
    SS1, SS2 : double;
begin
     alpha := StrToFloat(BlksAnovaFrm.PostAlpha.Text);
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
     OutPutFrm.RichEdit.Lines.Add('           Bonferroni Test for Differences Between Means');
     outline := format('                     Overall alpha selected = %4.2f',[alpha]);
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
     NoGrps := max_grp - min_grp + 1;
     testalpha := alpha / ( (NoGrps * (NoGrps-1)) / 2.0 );
     outline := format('Comparisons made at alpha / no. comparisons = %5.3f',[testalpha]);
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('Groups    Difference  Statistic  Prob > Value  Significant?');
     for i := 1 to NoGrps - 1 do
     begin
          for j := i+1 to NoGrps do
          begin
               mean1 := group_total[i-1] / group_count[i-1];
               mean2 := group_total[j-1] / group_count[j-1];
               SS1 := group_var[i-1] * (group_count[i-1] - 1.0);
               SS2 := group_var[j-1] * (group_count[j-1] - 1.0);
               divisor := (SS1 + SS2) / (group_count[i-1] + group_count[j-1] - 2.0);
               divisor := sqrt(divisor * ( 1.0 / group_count[i-1] + 1.0 / group_count[j-1]));
               contrast := abs(mean1-mean2) / divisor;
               df2 := round(group_count[i-1] + group_count[j-1] - 2.0);
               tprob := probt(contrast,df2);
               if testalpha >= tprob then sig := 'YES' else sig := 'NO';
               outline := format('%3d - %3d %10.3f  %10.3f %10.3f        %s',
                           [min_grp+i-1,min_grp+j-1,mean1-mean2,contrast,tprob,sig]);
               OutPutFrm.RichEdit.Lines.Add(outline);
          end;
     end;
end;
//-------------------------------------------------------------------

procedure TUKEYBTEST(ErrorMS : double;       // within groups error
                     ErrorDF : double;       // degrees of freedom within
                     group_total : DblDyneVec;  // vector of group sums
                     group_count : DblDyneVec;  // vector of group n's
                     min_grp     : integer;  // smallest group code
                     max_grp     : integer;  // largest group code
                     groupsize   : double); // size of groups (all equal)
var
   alpha  : double;
   outline : string;
   i, j : integer;
   df1 : double;
   qstat : double;
   tstat : double;
   groupno : IntDyneVec;
   temp1, temp2 : double;
   tempno : integer;
   NoGrps : integer;
   contrast : double;
   mean1, mean2 : double;
   sig : string[6];
   groups : double;
   response : string[5];
   divisor : double;

begin
     SetLength(groupno,max_grp-min_grp+1);
     alpha := StrToFloat(BlksAnovaFrm.PostAlpha.Text);
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
     OutPutFrm.RichEdit.Lines.Add('           Tukey B Test for Contrasts on Ordered Means');
     outline := format('                          alpha selected = %4.2f',[alpha]);
     OutPutFrm.RichEdit.Lines.Add(outline);
     OutPutFrm.RichEdit.Lines.Add('---------------------------------------------------------------');
     OutPutFrm.RichEdit.Lines.Add('');
     OutPutFrm.RichEdit.Lines.Add('Groups    Difference  Statistic   d.f.     Prob.>value  Significant?');
     divisor := sqrt(ErrorMS / groupsize);
     NoGrps := max_grp - min_grp + 1;
     for i := min_grp to max_grp do groupno[i-1] := i;
     for i := 1 to NoGrps - 1 do
     begin
         for j := i + 1 to NoGrps do
         begin
              if group_total[i-1] / group_count[i-1] >
                 group_total[j-1] / group_count[j-1] then
              begin
                   temp1 := group_total[i-1];
                   temp2 := group_count[i-1];
                   tempno := groupno[i-1];
                   group_total[i-1] := group_total[j-1];
                   group_count[i-1] := group_count[j-1];
                   groupno[i-1] := groupno[j-1];
                   group_total[j-1] := temp1;
                   group_count[j-1] := temp2;
                   groupno[j-1] := tempno;
              end;
         end;
     end;

     for i := 1 to NoGrps-1 do
     begin
          for j := i+1 to NoGrps do
          begin
               mean1 := group_total[i-1] / group_count[i-1];
               mean2 := group_total[j-1] / group_count[j-1];
               contrast := abs((mean1 - mean2) / divisor);
               df1 := j - i + 1.0;
               qstat := STUDENT(contrast,ErrorDF,df1);
               groups := NoGrps;
               tstat := STUDENT(contrast,ErrorDF,groups);
               qstat := (qstat + tstat) / 2.0;
               if alpha >= qstat then sig := 'YES' else sig := 'NO';
               outline := format('%3d - %3d %10.3f  %10.3f  %4.0f,%4.0f  %5.3f       %s',
                      [groupno[i-1],groupno[j-1],
                      mean1-mean2,contrast,df1,ErrorDF,qstat,sig]);
               OutPutFrm.RichEdit.Lines.Add(outline);
          end;
     end;
     groupno := nil;
end;
//-------------------------------------------------------------------

end.

