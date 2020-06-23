// To do:
// - Remove overloads without AReport argument when OutFrm refactoring is done
// - Then remove dependence on OutputUnit.
// - Add parameter "Alpha" to remove dependence on BlkANOVAUnit

unit ANOVATestsUnit;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FunctionsLib, Globals, MainUnit, DataProcs;

procedure Tukey(
  error_ms      : double;      { mean squared for residual }
  error_df      : double;      { deg. freedom for residual }
  value         : double;      { size of smallest group }
  group_total   : DblDyneVec;  { sum of scores in a group }
  group_count   : IntDyneVec;  { no. of cases in a group }
  min_grp       : integer;     { minimum group code }
  max_grp       : integer;     { maximum group code }
  Alpha         : Double;      { alpha value }
  AReport       : TStrings
);

procedure ScheffeTest(
  error_ms      : double;      { mean squared residual }
  group_total   : DblDyneVec;  { sum of scores in a group }
  group_count   : IntDyneVec;  { count of cases in a group }
  min_grp       : integer;     { code of first group }
  max_grp       : integer;     { code of last group  }
  total_n       : double;      { total number of cases }
  Alpha         : double;      { alpha value for testing }
  AReport       : TStrings
);

procedure Newman_Keuls(
  error_ms      : double;      { residual mean squared }
  error_df      : double;      { deg. freedom for error }
  value         : double;      { number in smallest group }
  group_total   : DblDyneVec;  { sum of scores in a group }
  group_count   : IntDyneVec;  { count of cases in a group }
  min_grp       : integer;     { lowest group code }
  max_grp       : integer;     { largest group code }
  Alpha         : double;      { alpha value for testing }
  AReport       : TStrings
);

procedure Tukey_Kramer(
  error_ms      : double;      { residual mean squared }
  error_df      : double;      { deg. freedom for error }
  value         : double;      { number in smallest group }
  group_total   : DblDyneVec;  { sum of scores in group }
  group_count   : IntDyneVec;  { number of caes in group }
  min_grp       : integer;     { code of lowest group }
  max_grp       : integer;     { code of highst group }
  Alpha         : double;      { Alpha value for testing }
  AReport       : TStrings
);

procedure Contrasts(
  error_ms      : double;      { residual ms }
  error_df      : double;      { residual df }
  group_total   : DblDyneVec;  { group sums  }
  group_count   : IntDyneVec;  { group cases }
  min_grp       : integer;     { lowest code }
  max_grp       : integer;     { highest code }
  overall_probf : double;      { prob of overall test }
  Alpha         : Double;
  AReport       : TStrings
);

procedure Bonferroni(
  group_total   : DblDyneVec;  { sum of scores in group }
  group_count   : IntDyneVec;  { number of caes in group }
  group_var     : DblDyneVec;  { group variances }
  min_grp       : integer;     { code of lowest group }
  max_grp       : integer;     { code of highst group }
  Alpha         : Double;      { Alpha value for testing }
  AReport       : TStrings
);

procedure TukeyBTest(
  ErrorMS       : double;      { within groups error }
  ErrorDF       : double;      { degrees of freedom within }
  group_total   : DblDyneVec;  { vector of group sums }
  group_count   : IntDyneVec;  { vector of group n's }
  min_grp       : integer;     { smallest group code }
  max_grp       : integer;     { largest group code }
  groupsize     : double;      { size of groups (all equal) }
  Alpha         : Double;      { Alpha value for testing }
  AReport       : TStrings
);

procedure HomogeneityTest(
  GroupCol      : integer;
  VarColumn     : integer;
  NoCases       : integer
);


implementation

uses
//  OutputUnit,
  //BlkAnovaUnit,
  Utils;

procedure Tukey(error_ms    : double;      { mean squared for residual }
                error_df    : double;      { deg. freedom for residual }
                value       : double;      { size of smallest group }
                group_total : DblDyneVec;  { sum of scores in a group }
                group_count : IntDyneVec;  { no. of cases in a group }
                min_grp     : integer;     { minimum group code }
                max_grp     : integer;     { maximum group code }
                Alpha       : double;      { alpha value }
                AReport     : TStrings);
var
  divisor: double;
  df1: integer;
  contrast, mean1, mean2: double;
  q_stat: double;
  i,j: integer;
  outline: string;
begin
  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('TUKEY HSD TEST FOR DIFFERENCES BETWEEN MEANS');
  AReport.Add('Alpha selected: %.2f', [Alpha]);
  AReport.Add('');
  AReport.Add('Groups    Difference    Statistic     Probability   Significant?');
  AReport.Add('-------   ----------    ----------    ------------  ------------');
  //           xx - xx     xxxxxxx     q = xxxxxx       xxxxxx         YES

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
      outline := outline + format('%6.3f',[contrast]);
      df1 := max_grp - min_grp + 1;
      q_stat := STUDENT(contrast,error_df,df1);
      outline := outline + format('       %6.4f',[q_stat]);

      if alpha >= q_stat then
        outline := outline + '         YES'
      else
        outline := outline + '         NO';

      AReport.Add(outline);
    end;

  AReport.Add(DIVIDER);
end;

procedure ScheffeTest(error_ms   : double;     { mean squared residual }
                     group_total : DblDyneVec; { sum of scores in a group }
                     group_count : IntDyneVec; { count of cases in a group }
                     min_grp     : integer;    { code of first group }
                     max_grp     : integer;    { code of last group  }
                     total_n     : double;     { total number of cases }
                     alpha       : double;     { alpha value for testing }
                     AReport     : TStrings);
var
  statistic, stat_var, stat_sd: double;
  mean1, mean2, difference, prob_scheffe, f_prob, df1, df2: double;
  outline: string;
  i, j: integer;
begin
  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('SCHEFFE CONTRASTS AMONG PAIRS OF MEANS');
  AReport.Add('Alpha selected: %.2f', [alpha]);
  AReport.Add('');
  AReport.Add('Group vs Group  Difference    Scheffe   Critical  Significant?');
  AReport.Add('                             Statistic   Value');
  AReport.Add('--------------  -----------  ---------  --------  ------------');

  alpha := 1.0 - alpha;
  for i:= min_grp to max_grp - 1 do
    for j := i + 1 to max_grp do
    begin
      outline := Format('%2d        %2d      ',[i,j]);
      mean1 := group_total[i-1] / group_count[i-1];
      mean2 := group_total[j-1] / group_count[j-1];
      difference := mean1 - mean2;
      outline := outline + Format('%8.2f ',[difference]);
      stat_var := error_ms * (1.0 / group_count[i-1] + 1.0 / group_count[j-1]);
      stat_sd := sqrt(stat_var);
      statistic := abs(difference / stat_sd);
      outline := outline + Format('%8.2f   ',[statistic]);
      df1 := max_grp - min_grp;
      df2 := total_n - df1 + 1;
      f_prob := fpercentpoint(alpha,round(df1),round(df2) );
      prob_scheffe := sqrt(df1 * f_prob);
      outline := outline + Format('%8.3f         ',[prob_scheffe]);
      if statistic > prob_scheffe then
        outline := outline + 'YES'
      else
        outline := outline + 'NO';
      AReport.Add(outline);
    end;

  AReport.Add(DIVIDER);
end;


procedure Newman_Keuls(error_ms    : double;     { residual mean squared }
                       error_df    : double;     { deg. freedom for error }
                       value       : double;     { number in smallest group }
                       group_total : DblDyneVec; { sum of scores in a group }
                       group_count : IntDyneVec; { count of cases in a group }
                       min_grp     : integer;    { lowest group code }
                       max_grp     : integer;    { largest group code }
                       alpha       : double;     { alpha value for testing }
                       AReport     : TStrings);
var
  i, j: integer;
  temp1: double;
  temp2: Integer;
  groupno : IntDyneVec;
  contrast, mean1, mean2 : double;
  q_stat : double;
  divisor : double;
  tempno : integer;
  df1 : integer;
  outline : string;
begin
  SetLength(groupno, max_grp-min_grp+1);
  for i := min_grp to max_grp do
    groupno[i-1] := i;

  for i := min_grp to max_grp - 1 do
  begin
    for j := i + 1 to max_grp do
    begin
      if group_total[i-1] / group_count[i-1] > group_total[j-1] / group_count[j-1] then
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

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('NEUMAN_KEULS TEST FOR CONTRASTS ON ORDERED MEANS');
  AReport.Add('Alpha selected: %.2f', [alpha]);
  AReport.Add('');
  AReport.Add('Group    Mean');
  AReport.Add('-----  ---------');
  //            xxx   xxxxxxx
  for i := 1 to max_grp do
    AReport.Add('%3d   %8.3f', [groupno[i-1], group_total[i-1] / group_count[i-1]]);
  AReport.Add('');

  AReport.Add('Groups     Difference    Statistic     d.f.    Probability  Significant?');
  AReport.Add('-------    ----------    ----------   ------   -----------  ------------');
  //           xx - xx     xxxxxxx      q = xxxxxx   xx xxx     xxxxxx        YES
  divisor := sqrt(error_ms / value);
  for i := min_grp to max_grp - 1 do
  begin
    for j := i + 1 to max_grp do
    begin
      outline := Format('%2d - %2d     ', [groupno[i-1], groupno[j-1]]);
      mean1 := group_total[i-1] / group_count[i-1];
      mean2 := group_total[j-1] / group_count[j-1];
      contrast := mean1 - mean2;
      outline := outline + Format('%7.3f      q = ', [contrast]);
      contrast := abs(contrast / divisor );
      df1 := j - i + 1;
      outline := outline + Format('%6.3f   %2d %3.0f  ', [contrast, df1, error_df]);
      q_stat := STUDENT(contrast, error_df, df1);
      outline := outline + Format('   %6.4f', [q_stat]);
      if alpha > q_stat then
        outline := outline + '        YES'
      else
        outline := outline + '        NO';
      AReport.Add(outline);
    end;
  end;

  AReport.Add(DIVIDER);
  groupno := nil;
end;

{ ----------------------------------------------------------------------- }

procedure Tukey_Kramer(error_ms      : double;     { residual mean squared }
                       error_df      : double;     { deg. freedom for error }
                       value         : double;     { number in smallest group }
                       group_total   : DblDyneVec; { sum of scores in group }
                       group_count   : IntDyneVec; { number of caes in group }
                       min_grp       : integer;    { code of lowest group }
                       max_grp       : integer;    { code of highst group }
                       Alpha         : Double;     { Alpha value for testing }
                       AReport       : TStrings);
var
   divisor : double;
   df1 : integer;
   contrast, mean1, mean2 : double;
   q_stat : double;
   outline : string;
   i, j : integer;

begin
  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('TUKEY-KRAMER TEST FOR DIFFERENCES BETWEEN MEANS');
  AReport.Add('Alpha selected: %.2f', [Alpha]);
  AReport.Add('');
  AReport.Add('Groups    Difference   Statistic     Probability  Significant?');
  AReport.Add('------    ----------  -------------  -----------  -------------');
  //           xx -xx     xxxxxxx     q = xxxxxx         xxxxxx       yes

  for i := min_grp to max_grp - 1 do
    for j := i + 1 to max_grp do
    begin
      outline := format('%2d - %2d     ',[i,j]);
      mean1 := group_total[i-1] / group_count[i-1];
      mean2 := group_total[j-1] / group_count[j-1];
      contrast := mean1 - mean2;
      outline := outline + format('%7.3f     q = ',[contrast]);
      divisor := sqrt(error_ms * ( ( 1.0/group_count[i-1] + 1.0/group_count[j-1] ) / 2 ) );
      contrast := abs(contrast / divisor) ;
      outline := outline + format('%6.3f  ',[contrast]);
      df1 := max_grp - min_grp + 1;
      q_stat := STUDENT(contrast,error_df,df1);
      outline := outline + format('       %6.4f',[q_stat]);
      if alpha >= q_stat then
        outline := outline + '       YES '
      else
        outline := outline + '       NO';
      AReport.Add(outline);
    end;
  AReport.Add(DIVIDER);
end;


procedure Contrasts(error_ms         : double;         { residual ms }
                    error_df         : double;         { residual df }
                    group_total      : DblDyneVec;     { group sums  }
                    group_count      : IntDyneVec;     { group cases }
                    min_grp          : integer;        { lowest code }
                    max_grp          : integer;        { highest code }
                    overall_probf    : double;         { prob of overall test }
                    Alpha            : Double;         { prob of posthoc test }
                    AReport          : TStrings);
var
   nocontrasts, i, j, k: integer;
   df1, df2, probstat, statistic: double;
   coefficients: array[1..20,1..20] of double;
   nonorthog: boolean;
   weight, sumcross: double;
   response: string[5];
   outline: string;
   prompt: string;

begin
  outline := format('Enter the number of contrasts (less than %d or 0:', [max_grp-min_grp+1]);
  response := InputBox('ORTHOGONAL CONTRASTS', outline, '0');
  nocontrasts := StrToInt(response);

  if nocontrasts > 0 then
  begin
    for i := 1 to nocontrasts do
    begin
      outline := format('Contrast number %2d',[i]);
      for j := 1 to (max_grp - min_grp+1) do
      begin
        prompt := format('Group %2d coefficient: ',[j]);
        response := InputBox(outline, prompt, '1');
        coefficients[i,j] := StrToFloat(response);
      end;
    end;

    { Check for orthogonality }
    nonorthog := false;
    for i := 1 to nocontrasts - 1 do
    begin
      for j := i + 1 to nocontrasts do
      begin
        sumcross := 0;
        for k := 1 to (max_grp - min_grp + 1) do
          sumcross := sumcross + coefficients[i,k]*coefficients[j,k];
        if sumcross <> 0 then
        begin
          nonorthog := true;
          MessageDlg(Format('Contrasts %2d and %2d not orthogonal.', [i,j]), mtError, [mbOK], 0);;
        end;
      end;
    end;

    if not nonorthog then
    begin
      if overall_probf > Alpha then
      begin
        AReport.Add('No contrasts significant.');
        exit;
      end;

      AReport.Add('');
      AReport.Add(DIVIDER);
      AReport.Add('ORTHOGONAL CONTRASTS');
      AReport.Add('');
      AReport.Add('Contrast  Statistic  Probability  Critical Value  Significant?');
      AReport.Add('---------------------------------------------------------------');

      for i := 1 to nocontrasts do
      begin
        statistic := 0.0;
        weight := 0.0;
        for j := 1 to (max_grp - min_grp + 1) do
        begin
          statistic := statistic + (coefficients[i,j] * (group_total[j-1] / group_count[j-1]));
          weight := weight + (sqr(coefficients[i,j]) / group_count[j-1]);
        end;
        statistic := sqr(statistic);
        statistic := statistic / (error_ms * weight);
        outline := Format('%3d       %9.4f    ', [i, statistic]);
        df1 := 1;
        df2 := error_df;
        probstat := probf(statistic, round(df1), round(df2)) / 2;
        outline := outline + Format('%8.3f       %5.2f          ', [probstat, alpha]);
        if probstat < alpha then
          outline := outline + 'YES'
        else
          outline := outline + 'NO';
        AReport.Add(outline);
      end;
      AReport.Add('');
      AReport.Add('Contrast Coefficients Used:');
      for i := 1 to nocontrasts do
      begin
        outline := format('Contrast %2d ',[i]);
        for j := 1 to (max_grp - min_grp + 1) do
          outline := outline + format('%4.1f ',[coefficients[i,j]]);
        AReport.Add(outline);
      end;
    end; { if orthogonal }
    AReport.Add(DIVIDER);
  end; { if nocontrasts > 0 }
end; { of procedure CONTRASTS }


procedure Bonferroni(  group_total   : DblDyneVec; { sum of scores in group }
                       group_count   : IntDyneVec; { number of cases in group }
                       group_var     : DblDyneVec; { group variances }
                       min_grp       : integer;    { code of lowest group }
                       max_grp       : integer;    { code of highst group }
                       Alpha         : double;     { Alpha value for testing }
                       AReport       : TStrings);
var
  i, j : integer;
  contrast, mean1, mean2 : double;
  divisor : double;
  df2 : integer;
  testalpha : double;
  NoGrps : integer;
  tprob : double;
  sig : string;
  SS1, SS2 : double;
begin
  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('BONFERRONI TEST FOR DIFFERENCES BETWEEN MEANS');
  AReport.Add('Overall alpha selected: %.2f', [alpha]);
  AReport.Add('');

  NoGrps := max_grp - min_grp + 1;
  testalpha := alpha / ( (NoGrps * (NoGrps-1)) / 2.0 );
  AReport.Add('Comparisons made at alpha / no. comparisons: %5.3f', [testalpha]);
  AReport.Add('');
  AReport.Add('Groups   Difference    Statistic  Prob > Value  Significant?');
  AReport.Add('-------  ------------  ---------  ------------  ------------');
  //           xx - xx  xxxxxxxxxx  xxxxxxxxxx  xxxxxxxxxx         YES
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
      AReport.Add('%2d - %2d  %10.3f  %10.3f  %10.3f         %s', [
        min_grp+i-1, min_grp+j-1, mean1-mean2, contrast, tprob, sig
      ]);
    end;
  end;

  AReport.Add(DIVIDER);
end;
//-------------------------------------------------------------------

procedure TukeyBTest(ErrorMS : double;         { within groups error }
                     ErrorDF : double;         { degrees of freedom within }
                     group_total : DblDyneVec; { vector of group sums }
                     group_count : IntDyneVec; { vector of group n's }
                     min_grp     : integer;    { smallest group code }
                     max_grp     : integer;    { largest group code }
                     groupsize   : double;     { size of groups (all equal) }
                     Alpha       : double;     { Alpha value for testing }
                     AReport     : TStrings);
var
  i, j: integer;
  df1: double;
  qstat: double;
  tstat: double;
  groupno: IntDyneVec;
  temp1: Double;
  temp2: Integer;
  tempno: integer;
  NoGrps: integer;
  contrast: double;
  mean1, mean2: double;
  sig: string;
  groups: double;
  divisor: double;

begin
  SetLength(groupno,max_grp-min_grp+1);

  AReport.Add('');
  AReport.Add(DIVIDER);
  AReport.Add('TUKEY B TEST FOR CONTRASTS ON ORDERED MEANS');
  AReport.Add('Alpha selected: %.2f',[alpha]);
  AReport.Add('');
  AReport.Add('Groups    Difference  Statistic    d.f.    Prob.>value  Significant?');
  AReport.Add('-------  -----------  ---------  --------  -----------  ------------');
  //           xx - xx  xxxxxxxxxx  xxxxxxxxxx   xxx,xxx   xxxxxxxx          YES

  divisor := sqrt(ErrorMS / groupsize);
  NoGrps := max_grp - min_grp + 1;
  for i := min_grp to max_grp do groupno[i-1] := i;
  for i := 1 to NoGrps - 1 do
  begin
    for j := i + 1 to NoGrps do
    begin
      if group_total[i-1] / group_count[i-1] > group_total[j-1] / group_count[j-1] then
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
      AReport.Add('%2d - %2d  %10.3f  %10.3f  %3.0f,%3.0f   %8.3f          %s', [
        groupno[i-1], groupno[j-1], mean1-mean2, contrast, df1, ErrorDF, qstat, sig
      ]);
    end;
  end;

  AReport.Add(DIVIDER);
  groupno := nil;
end;

procedure HomogeneityTest(GroupCol: integer; VarColumn: integer; NoCases: integer);
var
  i, j, k, intvalue, Nf1cells: integer;
  min, max: integer;
  zscores: DblDyneMat;
  medians: DblDyneVec;
  cellcnts: IntDyneVec;
  X: Double;
begin
  if GroupCol >= OS3MainFrm.DataGrid.ColCount then
  begin
    ErrorMsg('Invalid index of group column');
    exit;
  end;

  if VarColumn >= OS3MainFrm.DataGrid.ColCount then
  begin
    ErrorMsg('Invalid index of variable column');
    exit;
  end;

  // complete a one-way anova on z scores obtained as the absolute difference
  // between between the observed score and the median of a group.

  // get min and max group codes
  min := MaxInt;
  max := -MaxInt;

  for i := 1 to NoCases do
  begin
    intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GroupCol,i])));
    if intvalue < min then min := intvalue;
    if intvalue > max then max := intvalue;
  end;
  Nf1cells := max - min + 1;

  SetLength(zscores, Nf1cells, NoCases);
  SetLength(medians, Nf1cells);
  SetLength(cellcnts, Nf1cells);

  // Get cell counts
  for i := 0 to NoCases-1 do
  begin
    intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GroupCol,i])));
    intvalue := intvalue - min;
    cellcnts[intvalue] := cellcnts[intvalue] + 1;
  end;

  // get working totals
  for j := 0 to Nf1cells do
  begin
    k := 0;
    for i := 1 to NoCases do
    begin
      if not ValidValue(i,VarColumn) then continue;
      intvalue := round(StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[GroupCol,i])));
      intvalue := intvalue - min;
      if intvalue <> j then continue;
      X := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[VarColumn,i]));
      zscores[intvalue, k] := X;
      k := k + 1;
    end;
  end;

  //sort on z scores and obtain the median for each group
  for i := 0 to Nf1cells-1 do // sort scores in each group
    for j := 0 to cellcnts[i]-2 do
      for k := j+1 to cellcnts[i]-1 do
        if zscores[i, j] < zscores[i, k] then // swap
          Exchange(zscores[i, j], zscores[i, k]);

  for i := 0 to Nf1cells-1 do
    medians[i] := zscores[i, cellcnts[i] div 2];

  // Get deviations from the medians
  for i := 0 to Nf1cells-1 do
    for j := 0 to cellcnts[i]-1 do
      zscores[i,j] := zscores[i,j] - medians[i];

  // place group membership and z deviation scores in columns and
  // do a regular one-way ANOVA
  k := 0;
  for i := 0 to Nf1cells-1 do
    for j := 0 to cellcnts[i]-1 do
    begin
      k := k +1;
      OS3MainFrm.DataGrid.Cells[GroupCol,k] := IntToStr(i+1);
      OS3MainFrm.DataGrid.Cells[VarColumn,k] := FloatToStr(abs(zscores[i,j]));
    end;

  MessageDlg('Data have been placed in the grid.  Do a one-way ANOVA.', mtInformation, [mbOK], 0);
end;

end.

