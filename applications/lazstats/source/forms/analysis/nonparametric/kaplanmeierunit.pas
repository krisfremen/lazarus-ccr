unit KaplanMeierUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Clipbrd,
  MainUnit, Globals, FunctionsLib, OutputUnit, ContextHelpUnit;

type

  { TKaplanMeierFrm }

  TKaplanMeierFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    Panel1: TPanel;
    ResetBtn: TButton;
    ComputeBtn: TButton;
    CloseBtn: TButton;
    PlotChk: TCheckBox;
    PrintChk: TCheckBox;
    GroupBox1: TGroupBox;
    TimeInBtn: TBitBtn;
    TimeOutBtn: TBitBtn;
    EventInBtn: TBitBtn;
    EventOutBtn: TBitBtn;
    GroupInBtn: TBitBtn;
    GroupOutBtn: TBitBtn;
    TimeEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    EventEdit: TEdit;
    GroupEdit: TEdit;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure EventInBtnClick(Sender: TObject);
    procedure EventOutBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GroupInBtnClick(Sender: TObject);
    procedure GroupOutBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure TimeInBtnClick(Sender: TObject);
    procedure TimeOutBtnClick(Sender: TObject);
    procedure VarListSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure PlotXY(var Xpoints : IntDyneVec;
                     var Ypoints : DblDyneVec;
                     var Dropped : IntDyneVec;
                     var Dropped2 : IntDyneVec;
                     Xmax, Xmin, Ymax, Ymin : double;
                     N : integer;
                     XEdit : string;
                     YEdit : string;
                     curveno : integer);
    procedure UpdateBtnStates;
  public
    { public declarations }
  end; 

var
  KaplanMeierFrm: TKaplanMeierFrm;

implementation

uses
  Math, BlankFrmUnit;

{ TKaplanMeierFrm }

procedure TKaplanMeierFrm.ResetBtnClick(Sender: TObject);
var
  i: integer;
begin
  VarList.Clear;
  for i := 1 to NoVariables do
    VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
  TimeEdit.Text := '';
  EventEdit.Text := '';
  GroupEdit.Text := '';
  UpdateBtnStates;
  PlotChk.Checked := false;
  PrintChk.Checked := false;
end;

procedure TKaplanMeierFrm.TimeInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := VarList.ItemIndex;
  if (i > -1) and (TimeEdit.Text = '') then
  begin
    TimeEdit.Text := VarList.Items[i];
    VarList.Items.Delete(i);
  end;
  UpdateBtnStates;
end;

procedure TKaplanMeierFrm.TimeOutBtnClick(Sender: TObject);
begin
  if TimeEdit.Text <> '' then
  begin
    VarList.Items.Add(TimeEdit.Text);
    TimeEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TKaplanMeierFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  Panel1.Constraints.MinWidth := 2 * GroupBox1.Width + VarList.BorderSpacing.Left;

  w := MaxValue([HelpBtn.Width, ResetBtn.Width, ComputeBtn.Width, CloseBtn.Width]);
  HelpBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  CloseBtn.Constraints.MinWidth := w;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TKaplanMeierFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if BlankFrm = nil then
    Application.CreateForm(TBlankFrm, BlankFrm);
end;

procedure TKaplanMeierFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TKaplanMeierFrm.GroupInBtnClick(Sender: TObject);
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

procedure TKaplanMeierFrm.GroupOutBtnClick(Sender: TObject);
begin
  if GroupEdit.Text <> '' then
  begin
    VarList.Items.Add(GroupEdit.Text);
    GroupEdit.Text := '';
  end;
  UpdateBtnStates;
end;

procedure TKaplanMeierFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).tag);
end;

procedure TKaplanMeierFrm.EventInBtnClick(Sender: TObject);
var
  i: integer;
begin
  i := VarList.ItemIndex;
  if (i > -1) and (EventEdit.Text = '') then
  begin
    EventEdit.Text := VarList.Items[i];
    VarList.Items.Delete(i);
  end;
  UpdateBtnStates;
end;

procedure TKaplanMeierFrm.EventOutBtnClick(Sender: TObject);
begin
  if EventEdit.Text <> '' then
  begin
    VarList.Items.Add(EventEdit.Text);
    EventEdit.Text := '';
  end;
  UpdateBtnStates;
end;


procedure TKaplanMeierFrm.ComputeBtnClick(Sender: TObject);
var
     TwoGroups : boolean;
     Size1, Size2, TotalSize, NoDeaths, ThisTime: integer;
     mintime, maxtime, tempint, nopoints, tempvalue : integer;
     NoCensored, nocats, i, j, k, icase, oldtime, pos, first, last : integer;
     noinexp, noincntrl, count, TimeCol, DeathsCol: integer;
     GroupCol : integer;
     cumprop, proportion, term1, term2, term3 : double;
     E1, E2, O1, O2, Chisquare, ProbChi, Risk, LogRisk, SELogRisk : double;
     HiConf, LowConf, HiLogLevel, LowLogLevel, lastexp, lastctr : double;
     TimePlot, Dropped, Dropped2, Time, AtRisk, Dead, SurvivalTimes : IntDyneVec;
     ExpCnt, CntrlCnt, TotalatRisk, ExpatRisk, CntrlatRisk : IntDyneVec;
     Deaths, Group, Censored : IntDyneVec;
     ProbPlot, ProbPlot2, CondProb, ExpProp, CntrlProp : DblDyneVec;
     CumPropExp, CumPropCntrl : DblDyneVec;
     TimeLabel, GroupLabel, DeathsLabel : string;
     lReport: TStrings;
begin
  // get variable columns and labels
  TimeLabel := TimeEdit.Text;
  GroupLabel := GroupEdit.Text;
  DeathsLabel := EventEdit.Text;
  TimeCol := 0;
  DeathsCol := 0;
  GroupCol := 0;
  for i := 1 to NoVariables do
  begin
    if (TimeLabel = OS3MainFrm.DataGrid.Cells[i,0]) then TimeCol := i;
    if (DeathsLabel = OS3MainFrm.DataGrid.Cells[i,0]) then DeathsCol := i;
    if (GroupLabel = OS3MainFrm.DataGrid.Cells[i,0]) then GroupCol := i;
  end;

  if (TimeCol = 0) or (DeathsCol = 0) then
  begin
    MessageDlg('One or more variables not selected.', mtError, [mbOK], 0);
    exit;
  end;

  if (GroupEdit.Text = '') then
  begin
    TwoGroups := false;
    Size1 := NoCases;
    Size2 := 0;
  end else
  begin
    Size1 := 0;
    Size2 := 0;
    TwoGroups := true;
    for i := 1 to NoCases do
    begin
      if (StrToInt(OS3MainFrm.DataGrid.Cells[GroupCol,i]) = 1) then
        Size1 := Size1 + 1
      else Size2 := Size2 + 1;
    end;
  end;

  // allocate space for the data
  SetLength(SurvivalTimes, NoCases+2);
  SetLength(ExpCnt, NoCases+2);
  SetLength(CntrlCnt, NoCases+2);
  SetLength(TotalatRisk, NoCases+2);
  SetLength(ExpatRisk, NoCases+2);
  SetLength(CntrlatRisk, NoCases+2);
  SetLength(ExpProp, NoCases+2);
  SetLength(CntrlProp, NoCases+2);
  SetLength(Deaths, NoCases+2);
  SetLength(Group, NoCases+2);
  SetLength(Censored, NoCases+2);
  SetLength(CumPropExp, NoCases+2);
  SetLength(CumPropCntrl, NoCases+2);

  // initialize arrays
  for i := 0 to NoCases+1 do
  begin
    SurvivalTimes[i] := 0;
    ExpCnt[i] := 0;
    CntrlCnt[i] := 0;
    TotalatRisk[i] := 0;
    ExpatRisk[i] := 0;
    CntrlatRisk[i] := 0;
    ExpProp[i] := 0.0;
    CntrlProp[i] := 0.0;
    Deaths[i] := 0;
    Group[i] := 0;
    Censored[i] := 0;
    CumPropExp[i] := 0.0;
    CumPropCntrl[i] := 0.0;
  end;

  // Get Data
  mintime := 0;
  maxtime := 0;

  if not TwoGroups then
  begin
    for i := 1 to NoCases do
    begin
      SurvivalTimes[i] := StrToInt(OS3MainFrm.DataGrid.Cells[TimeCol,i]);
      if (SurvivalTimes[i] > maxtime) then
        maxtime := SurvivalTimes[i];
      tempvalue := StrToInt(OS3MainFrm.DataGrid.Cells[DeathsCol,i]);
      if (tempvalue = 1) then
        Deaths[i] := 1
      else
        Deaths[i] := 0;
      if (tempvalue = 2) then
        Censored[i] := 1
      else
        Censored[i] := 0;
    end;

    // sort cases by time
    for i := 0 to NoCases - 1 do
    begin
      for j := i + 1 to NoCases do
      begin
        if (SurvivalTimes[i] > SurvivalTimes[j]) then
        begin
          tempint := SurvivalTimes[i];
          SurvivalTimes[i] := SurvivalTimes[j];
          SurvivalTimes[j] := tempint;
          tempint := Censored[i];
          Censored[i] := Censored[j];
          Censored[j] := tempint;
          tempint := Deaths[i];
          Deaths[i] := Deaths[j];
          Deaths[j] := tempint;
        end;
      end;
    end;

    // get number censored in each time slot
    nopoints := maxtime + 1;
    SetLength(Dropped,nopoints+2);
    SetLength(Dropped2,nopoints+2);
    for j := 0 to nopoints do
    begin
      Dropped[j] := 0;
      Dropped2[j] := 0;
    end;
    ThisTime := SurvivalTimes[0];
    for i := 0 to NoCases do
    begin
      if (ThisTime = SurvivalTimes[i]) then
      begin
        if(Censored[i] > 0) then
        begin
          tempint := SurvivalTimes[i] - mintime;
          Dropped[tempint] := Dropped[tempint] + Censored[i];
        end;
      end
      else // new time
      begin
        ThisTime := SurvivalTimes[i];
        if(Censored[i] > 0) then
        begin
          tempint := SurvivalTimes[i] - mintime;
          Dropped[tempint] := Dropped[tempint] + Censored[i];
        end;
      end;
    end;

    // calculate expected proportions and adjust survival counts
    cumprop := 1.0;
    ExpCnt[0] := NoCases;
    ExpProp[0] := 1.0;
    CumPropExp[0] := 1.0;

    // collapse deaths and censored into first time occurance
    icase := 0;
    oldtime := SurvivalTimes[0];
    for i := 1 to NoCases do
    begin
         if (SurvivalTimes[i] <> oldtime) then
         begin
              oldtime := SurvivalTimes[i];
              icase := i;
         end;

         // find no. of deaths at this time
         NoDeaths := Deaths[i];
         for j := i+1 to NoCases do
         begin
                ThisTime := SurvivalTimes[j];
                if ((Deaths[j] > 0) and (oldtime = ThisTime)) then
                begin
                   NoDeaths := NoDeaths + Deaths[j];
                   Deaths[icase] := Deaths[icase] + Deaths[j];
                   Deaths[j] := 0;
                end;
         end;
         // find no. of censored at this time
         NoCensored := Censored[i];
         for j := i+1 to NoCases do
         begin
                ThisTime := SurvivalTimes[j];
                if((Censored[j] > 0) and (oldtime = ThisTime)) then
                begin
                   NoCensored := NoCensored + Censored[j];
                   Censored[icase] := Censored[icase] + Censored[j];
                   Censored[j] := 0;
                end;
         end;
     end;
{
    // debug check
    FrmOutPut.RichOutPut.Clear();
    for (int i := 0; i <= NoCases; i++)
    begin
          sprintf(outline,'case %d  Day %d  Deaths %d  Censored  %d',
             i,SurvivalTimes[i], Deaths[i],Censored[i]);
          FrmOutPut.RichOutPut.Lines.Add(outline);
    end;
    FrmOutPut.ShowModal();
}
    // get no. of categories
    for i := 0 to NoCases do
              if ((Deaths[i] > 0) or (Censored[i] > 0)) then nocats := nocats + 1;
    SetLength(Time,nocats+2);
    SetLength(AtRisk,nocats+2);
    SetLength(Dead,nocats+2);
    SetLength(CondProb,nocats+2);
    for i := 0 to nocats do
    begin
      Time[i] := 0;
      AtRisk[i] := 0;
      Dead[i] := 0;
      CondProb[i] := 0.0;
    end;
    pos := 0;
    for i := 0 to NoCases do
    begin
      if (Deaths[i] > 0) or (Censored[i] > 0) then
      begin
        pos := pos + 1;
        Time[pos] := SurvivalTimes[i];
        Dead[pos] := Deaths[i];
        Dropped[pos] := Censored[i];
      end;
    end;

    Time[0] := 0;
    AtRisk[0] := NoCases;
    Dead[0] := 0;
    Dropped[0] := 0;
    CondProb[0] := 0.0;

    lReport := TStringList.Create;
    try
      lReport.Add('   Time  Censored    Dead   At Risk  Probability');
      for i := 1 to nocats do
      begin
        AtRisk[i] := AtRisk[i-1] - Dead[i-1] - Dropped[i-1];
        CondProb[i-1] := 1.0 - Dead[i-1] / AtRisk[i-1];
      end;
      for i := 0 to nocats do
        lReport.Add(' %3d        %3d      %3d      %3d     %6.3f', [Time[i],Dropped[i],Dead[i],AtRisk[i],CondProb[i]]);
      DisplayReport(lReport);
    finally
      lReport.Free;
    end;

    // Get cumulative proportions
    for i := 0 to nocats do
    begin
      if (AtRisk[i] > 0) then
      begin
        CumPropExp[i] := cumprop * CondProb[i];
        cumprop := CumPropExp[i];
      end;
    end;
    cumprop := 1.0;

    lReport := TStringList.Create;
    try
      lReport.Add('KAPLAN-MEIER SURVIVAL TEST');
      lReport.Add('');
      lReport.Add('No Control Group Method');
      lReport.Add('');
      lReport.Add('TIME  NO.ALIVE  CENSORED DEATHS  COND. PROB.  CUM.PROP.SURVIVING');
      for i := 0 to nocats do
        lReport.Add(' %4d %4d     %4d     %4d   %7.4f        %7.4f', [
          Time[i], AtRisk[i], Dropped[i], Deaths[i], CondProb[i], CumPropExp[i]
        ]);
      DisplayReport(lReport);
    finally
      lReport.Free;
    end;

    if PlotChk.Checked then // plot Y := cumulative proportion surviving, x := time
    begin
      // Get points to plot
      nopoints := maxtime + 1;
      SetLength(TimePlot,nocats+2);
      SetLength(ProbPlot,nocats+2);
      ProbPlot[0] := 1.0;
      for j := 0 to nocats do
      begin
        TimePlot[j] := Time[j];
        ProbPlot[j] := CumPropExp[j];
      end;
      BlankFrm.Show;
      PlotXY(TimePlot, ProbPlot, Dropped, Dropped2, maxtime, 0, 1.0, 0.0, nocats, 'TIME', 'PROBABILITY', 1);
    end; // end if graph1

    ProbPlot := nil;
    TimePlot := nil;
    CondProb := nil;
    Dead := nil;
    AtRisk := nil;
    Time := nil;
  end // end if not two groups
//============================================================================//
  else  // Experimental and control groups
  begin
    // obtain no. in experimental and control groups
    ExpCnt[0] := Size1;
    CntrlCnt[0] := Size2;
    TotalSize := Size1 + Size2;
    CumPropExp[0] := 1.0;
    CumPropCntrl[0] := 1.0;
    TotalatRisk[0] := TotalSize;
    O1 := 0;
    O2 := 0;
  {
    ShowMessage(Format('Total Group 1 = %d, Total Group 2 = %d, Grand Total = %d',
      [ ExpCnt[0], CntrlCnt[0], TotalSize ]));
  }
    // Now read values.  Note storage starts in 1, not 0!
    for i := 1 to NoCases do
    begin
      SurvivalTimes[i] := StrToInt(OS3MainFrm.DataGrid.Cells[TimeCol,i]);
      if (SurvivalTimes[i] > maxtime) then
        maxtime := SurvivalTimes[i];
      tempvalue := StrToInt(OS3MainFrm.DataGrid.Cells[DeathsCol,i]);
      if (tempvalue = 1) then
        Deaths[i] := 1
      else
        Deaths[i] := 0;
      if (tempvalue = 2) then
        Censored[i] := 1
      else
        Censored[i] := 0;
      Group[i] := StrToInt(OS3MainFrm.DataGrid.Cells[GroupCol,i]);
    end;

    // sort cases by time
    for i := 1 to NoCases - 1 do
    begin
      for j := i + 1 to NoCases do
      begin
        if (SurvivalTimes[i] > SurvivalTimes[j]) then
        begin
          tempint := SurvivalTimes[i];
          SurvivalTimes[i] := SurvivalTimes[j];
          SurvivalTimes[j] := tempint;
          tempint := Censored[i];
          Censored[i] := Censored[j];
          Censored[j] := tempint;
          tempint := Deaths[i];
          Deaths[i] := Deaths[j];
          Deaths[j] := tempint;
          tempint := Group[i];
          Group[i] := Group[j];
          Group[j] := tempint;
        end;
      end;
    end;

    // sort cases within each time slot by deaths first then censored
    ThisTime := SurvivalTimes[1];
    first := 1;
    last := 1;
    for i := 1 to NoCases do
    begin
      if (ThisTime = SurvivalTimes[i]) then
      begin
        last := i;
        continue;
      end
      else // sort the cases from first to last on event (descending)
      begin
        if (last > first) then // more than 1 to sort
        begin
          for j := first to last - 1 do
          begin
            for k := j + 1 to last do
            begin
              if (Deaths[j] < Deaths[k] ) then // swap
              begin
                tempint := Censored[j];
                Censored[j] := Censored[k];
                Censored[k] := tempint;
                tempint := Deaths[j];
                Deaths[j] := Deaths[k];
                Deaths[k] := tempint;
                tempint := Group[j];
                Group[j] := Group[k];
                Group[k] := tempint;
              end;
            end; // next k
          end; // next j
        end; // if last > first
      end; // end else sort

      first := last + 1;
      ThisTime := SurvivalTimes[first];
      last := first;
    end; // next i

    // get number censored in each time slot
    nopoints := maxtime + 1;
    SetLength(Dropped,nopoints+2);
    SetLength(Dropped2,nopoints+2);
    for j := 0 to nopoints do
    begin
      Dropped[j] := 0;
      Dropped2[j] := 0;
    end;
    ThisTime := SurvivalTimes[1];
    for i := 1 to NoCases do
    begin
      if (ThisTime = SurvivalTimes[i]) then
      begin
        if(Censored[i] > 0) then
        begin
          tempint := SurvivalTimes[i] - mintime;
          if (Group[i] = 1) then
            Dropped[tempint] := Dropped[tempint] + Censored[i]
          else
            Dropped2[tempint] := Dropped2[tempint] + Censored[i];
        end;
      end
      else // new time
      begin
        ThisTime := SurvivalTimes[i];
        if (Censored[i] > 0) then
        begin
          tempint := SurvivalTimes[i] - mintime;
          if (Group[i] = 1) then
            Dropped[tempint] := Dropped[tempint] + Censored[i]
          else Dropped2[tempint] := Dropped2[tempint] + Censored[i];
        end;
      end;
    end;

    for i := 0 to NoCases do
    begin
      noinexp := 0;
      noincntrl := 0;
      if (Deaths[i] > 0) then
      begin
        // find no. of deaths at this time
        NoDeaths := Deaths[i];
        ThisTime := SurvivalTimes[i];
        for j := i+1 to NoCases do
        begin
          if ((Deaths[j] > 0) and (SurvivalTimes[j] = ThisTime)) then
          begin
            NoDeaths := NoDeaths + Deaths[j];
            Deaths[i] := Deaths[i] + Deaths[j];
            Deaths[j] := 0;
          end;
        end;
        if (TotalatRisk[i] > 0) then
        begin
          term1 := ExpCnt[i];
          term2 := TotalatRisk[i];
          term3 := NoDeaths;
          ExpatRisk[i] := ceil((term1 / term2) * term3);
//                 ExpatRisk[i] := (ExpCnt[i]) / TotalatRisk[i]) * NoDeaths;
          term1 := CntrlCnt[i];
          CntrlatRisk[i] := ceil((term1 / term2) * term3);
//                 CntrlatRisk[i] := (CntrlCnt[i] / TotalatRisk[i]) *  NoDeaths;
        end;
        if (i < NoCases-1) then
          TotalAtRisk[i+1] := TotalAtRisk[i] - Deaths[i];
        // find no. in exp. or control groups and decrement their counts
        for j := 1 to NoCases do
        begin
          if (ThisTime = SurvivalTimes[j]) and (Censored[j] = 0) then
          begin
            if (Group[j] = 1) then
            begin
              noinexp := noinexp + 1;
              O1 := O1 + 1;
            end;
            if (Group[j] = 2) then
            begin
              noincntrl := noincntrl + 1;
              O2 := O2 + 1;
            end;
          end;
        end;
        if (i < NoCases) and (noinexp > 0) then
        begin
          term1 := ExpCnt[i];
          term2 := noinexp;
          term3 := ExpCnt[i];
          ExpProp[i] := (term1 - term2) / term3;
//                 ExpProp[i] := (ExpCnt[i] - noinexp) / ExpCnt[i];
          if (i > 0) then
            CumPropExp[i] := CumPropExp[i-1] * ExpProp[i];
          ExpCnt[i+1] := ExpCnt[i] - noinexp;
          CumPropExp[i+1] := CumPropExp[i];
        end;
        if (i < NoCases) and (noinexp = 0) then
        begin
          ExpCnt[i+1] := ExpCnt[i];
          CumPropExp[i+1] := CumPropExp[i];
        end;
        if (i < NoCases) and (noincntrl > 0) then
        begin
          term1 := CntrlCnt[i];
          term2 := noincntrl;
          term3 := CntrlCnt[i];
          CntrlProp[i] := (term1 - term2) / term3;
//                 CntrlProp[i] := (CntrlCnt[i] - noincntrl) / CntrlCnt[i];
          if (i > 0) then
            CumPropCntrl[i] := CumPropCntrl[i-1] * CntrlProp[i];
          CntrlCnt[i+1] := CntrlCnt[i] - noincntrl;
          CumPropCntrl[i+1] := CumPropCntrl[i];
        end;
        if ( (i < NoCases) and (noincntrl = 0) ) then
        begin
          CntrlCnt[i+1] := CntrlCnt[i];
          CumPropCntrl[i+1] := CumPropCntrl[i];
        end;
      end;  // end if deaths[i] > 0

      if ( (Censored[i] > 0) and (i < NoCases) ) then
      begin
        if (Group[i] = 1) then
        begin
          ExpCnt[i+1] := ExpCnt[i] - 1;
          CntrlCnt[i+1] := CntrlCnt[i];
          ExpProp[i+1] := ExpProp[i];
          CumPropExp[i+1] := CumPropExp[i];
          CumPropCntrl[i+1] := CumPropCntrl[i];
        end;
        if (Group[i] = 2) then
        begin
          CntrlCnt[i+1] := CntrlCnt[i] - 1;
          ExpCnt[i+1] := ExpCnt[i];
          CntrlProp[i+1] := CntrlProp[i];
          CumPropCntrl[i+1] := CumPropCntrl[i];
          CumPropExp[i+1] := CumPropExp[i];
        end;
        TotalatRisk[i+1] := TotalatRisk[i] - 1;
      end;

      if (Deaths[i] = 0) and (Censored[i] = 0) and (i < NoCases) then
      begin
        ExpCnt[i+1] := ExpCnt[i];
        CntrlCnt[i+1] := CntrlCnt[i];
        CumPropExp[i+1] := CumPropExp[i];
        CumPropCntrl[i+1] := CumPropCntrl[i];
        TotalatRisk[i+1] := TotalatRisk[i];
      end;
    end; // next case i

    // Now calculate chisquare, relative risk (r), logr, and S.E. of log risk
    E1 := 0.0;
    for i := 0 to NoCases do E1 := E1 + ExpatRisk[i];
    E2 := (O1 + O2) - E1;
    Chisquare := ((O1 - E1) * (O1 - E1)) / E1 + ((O2 - E2) * (O2 - E2)) / E2;
    ProbChi := chisquaredprob(Chisquare,1);
    Risk := (O1 / E1) / (O2 / E2);
    LogRisk := ln(Risk);
    SELogRisk := sqrt(1.0/E1 + 1.0/E2);
    HiConf := LogRisk + (inversez(0.975) * SELogRisk);
    LowConf := LogRisk - (inversez(0.975) * SELogRisk);
    HiLogLevel := exp(HiConf);
    LowLogLevel := exp(LowConf);
  end;

  // Print Results
  if (TwoGroups and PrintChk.Checked) then // both experimental and control groups
  begin
    lReport := TStringList.Create;
    try
      lReport.Add('KAPLAN-MEIER SURVIVAL TEST');
      lReport.Add('');
      lReport.Add('Comparison of Two Groups Methd');
      lReport.Add('');
      lReport.Add('TIME GROUP CENSORED  TOTAL AT  EVENTS  AT RISK IN  EXPECTED NO.  AT RISK IN  EXPECTED NO.');
      lReport.Add('                     RISK              GROUP 1     EVENTS IN 1     GROUP 2   EVENTS IN 2');

      for i := 1 to NoCases+1 do
        lReport.Add('%4d %4d     %4d     %4d     %4d      %4d      %7d        %4d        %7d', [
          SurvivalTimes[i-1], Group[i-1], Censored[i-1], TotalAtRisk[i-1],
          Deaths[i-1], ExpCnt[i-1], ExpAtRisk[i-1], CntrlCnt[i-1], CntrlAtRisk[i-1]
        ]);

      lReport.Add('');
      lReport.Add('');
      lReport.Add('TIME  DEATHS  GROUP  AT RISK  PROPORTION  CUMULATIVE');
      lReport.Add('                              SURVIVING   PROP.SURVIVING');

      for i := 1 to NoCases do
      begin
        if (Group[i] = 1) then
        begin
          count := ExpCnt[i];
          proportion := ExpProp[i];
          cumprop := CumPropExp[i];
        end else
        begin
          count := CntrlCnt[i];
          proportion := CntrlProp[i];
          cumprop := CumPropCntrl[i];
        end;
        lReport.Add('%4d   %4d   %4d     %4d     %7.4f       %7.4f', [
          SurvivalTimes[i], Deaths[i], Group[i], count, proportion, cumprop
        ]);
      end;

      lReport.Add('');
      lReport.Add('Total Expected Events for Experimental Group: %8.3f', [E1]);
      lReport.Add('Observed Events for Experimental Group:       %8.3f', [O1]);
      lReport.Add('Total Expected Events for Control Group:      %8.3f', [E2]);
      lReport.Add('Observed Events for Control Group:            %8.3f', [O2]);
      lReport.Add('Chisquare:                                    %8.3f', [ChiSquare]);
      lReport.Add('  with probability:                           %8.3f', [ProbChi]);
      lReport.Add('Risk:                                         %8.3f', [Risk]);
      lReport.Add('Log Risk:                                     %8.3f', [LogRisk]);
      lReport.Add('Std.Err. Log Risk:                            %8.3f', [SELogRisk]);
      lReport.Add('95 Percent Confidence interval for Log Risk:  (%.3f ... %.3f)', [LowConf, HiConf]);
      lReport.Add('95 Percent Confidence interval for Risk:      (%.3f ... %.3f)', [LowLogLevel, HiLogLevel]);

      // Plot data output
      lReport.Add('');
      lReport.Add('============================================================================');
      lReport.Add('');
      lReport.Add('EXPERIMENTAL GROUP CUMULATIVE PROBABILITY');
      lReport.Add('CASE TIME DEATHS CENSORED CUM.PROB.');
      for i := 1 to NoCases do
        if (Group[i] = 1) then
          lReport.Add('%3d    %3d   %3d     %3d      %5.3f',[
            i, SurvivalTimes[i], Deaths[i], Censored[i], CumPropExp[i]
          ]);
      lReport.Add('');
      lReport.Add('============================================================================');
      lReport.Add('');
      lReport.Add('CONTROL GROUP CUMULATIVE PROBABILITY');
      lReport.Add('CASE TIME DEATHS CENSORED CUM.PROB.');
      for i := 1 to NoCases do
        if (Group[i] = 2) then
          lReport.Add('%3d    %3d   %3d     %3d      %5.3f', [
            i, SurvivalTimes[i], Deaths[i], Censored[i], CumPropCntrl[i]
          ]);
      lReport.Add('');

      DisplayReport(lReport);
    finally
      lReport.Free;
    end;
  end; // if 2 groups and printit

  if PlotChk.Checked then // plot cumulative proportion surviving (Y) against time (X)
  begin
    nopoints := maxtime + 1;
    SetLength(TimePlot,nopoints+2);
    SetLength(ProbPlot,nopoints+2);
    SetLength(ProbPlot2,nopoints+2);
    ProbPlot[0] := 1.0;
    ProbPlot2[0] := 1.0;
    lastexp := 1.0;
    lastctr := 1.0;
    for i := 0 to nopoints do
    begin
      TimePlot[i] := 0;
      ProbPlot[i] := 1.0;
      ProbPlot2[i] := 1.0;
    end;
    TimePlot[0] := 0;
    mintime := 0;
    for i := 1 to nopoints do
    begin
      TimePlot[i] := i;
      for j := 1 to NoCases do
      begin
        if (SurvivalTimes[j] = i) then
        begin
          if (Group[j] = 1) then
          begin
            ProbPlot[i] := CumPropExp[j]; // ExpProp[j];
            lastexp := CumPropExp[j]; // ExpProp[j];
          end;
          if (Group[j] = 2) then
          begin
            ProbPlot2[i] := CumPropCntrl[j]; //CntrlProp[j];
            lastctr := CumPropCntrl[j]; // CntrlProp[j];
          end;
        end
        else
        begin
          if (Group[j] = 1) then ProbPlot[i] := lastexp;
          if (Group[j] = 2) then ProbPlot2[i] := lastctr;
        end;
      end;
    end;

    BlankFrm.Image1.Canvas.Clear;
    BlankFrm.Show;
    PlotXY(TimePlot, ProbPlot,  Dropped, Dropped2, maxtime, 0, 1.0, 0.0, nopoints, 'TIME', 'PROBABILITY', 1);
    PlotXY(TimePlot, ProbPlot2, Dropped, Dropped2, maxtime, 0, 1.0, 0.0, nopoints, 'TIME', 'PROBABILITY', 2);

    ProbPlot2 := nil;
    ProbPlot := nil;
    TimePlot := nil;
  end; // if graph plot := 1

  Dropped2 := nil;
  Dropped := nil;

  // clean up memory
  Dropped2 := nil;
  Dropped := nil;
  CumPropCntrl := nil;
  CumPropExp := nil;
  Censored := nil;
  Group := nil;
  Deaths := nil;
  CntrlProp := nil;
  ExpProp := nil;
  CntrlatRisk := nil;
  ExpatRisk := nil;
  TotalatRisk := nil;
  CntrlCnt := nil;
  ExpCnt := nil;
  SurvivalTimes := nil;
end;

procedure TKaplanMeierFrm.PlotXY(var Xpoints: IntDyneVec;
  var Ypoints: DblDyneVec; var Dropped: IntDyneVec; var Dropped2: IntDyneVec;
  Xmax, Xmin, Ymax, Ymin: double; N: integer; XEdit: string; YEdit: string;
  curveno: integer);
var
     i, xpos, ypos, hleft, hright, vtop, vbottom, imagewide : integer;
     vhi, hwide, offset, strhi, imagehi : integer;
     noxvalues, digitwidth, Xvalue, xvalincr, oldxpos : integer;
     valincr, Yvalue, value, oldypos, term1, term2, term3 : double;
     Title, outline : string;
label again, second;

begin
     if (curveno = 2) then goto second;
     BlankFrm.Image1.Canvas.Font.Color := clBlack;
     Title := 'SURVIVAL CURVE';
     BlankFrm.Caption := Title;
     imagewide := BlankFrm.Image1.Width;
     imagehi := BlankFrm.Image1.Height;
     BlankFrm.Image1.Canvas.FloodFill(0,0,clWhite,fsBorder);
     vtop := 20;
     vbottom := ceil(imagehi) - 130;
     vhi := vbottom - vtop;
     hleft := 100;
     hright := imagewide - 80;
     hwide := hright - hleft;
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.Brush.Color := clWhite;

     // Draw chart border
//     ImageFrm.Image.Canvas.Rectangle(0,0,imagewide,imagehi);

     // draw horizontal axis
     noxvalues := N;
     xvalincr :=  1;
     digitwidth := BlankFrm.Image1.Canvas.TextWidth('9');
again:
     if ( (noxvalues * 4 * digitwidth) > hwide) then
     begin
         noxvalues := noxvalues div 2;
         xvalincr := 2 * xvalincr;
         goto again;
     end;
     BlankFrm.Image1.Canvas.Pen.Style := psSolid;
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     BlankFrm.Image1.Canvas.MoveTo(hleft,vbottom);
     BlankFrm.Image1.Canvas.LineTo(hright,vbottom);
     for i := 1 to noxvalues do
     begin
          ypos := vbottom;
          Xvalue := Xpoints[1] + xvalincr * (i - 1); // Xmin + xvalincr * (i - 1);
          term1 := (Xvalue - Xmin) / (Xmax - Xmin);
          term2 := hwide;
          term3 := hleft;
          xpos := floor((term1 * term2) + term3);
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          ypos := ypos + 10;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
          outline := format('%d',[Xvalue]);
          Title := outline;
          offset := BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
          xpos := xpos - offset;
          BlankFrm.Image1.Canvas.Pen.Color := clBlack;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
     end;
     xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(XEdit) div 2);
     ypos := vbottom + 22;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,XEdit);

     // Draw vertical axis
     Title := YEdit;
     xpos := hleft - BlankFrm.Image1.Canvas.TextWidth(Title) div 2;
     ypos := vtop - BlankFrm.Image1.Canvas.TextHeight(Title);
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,YEdit);
     xpos := hleft;
     ypos := vtop;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
     ypos := vbottom;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     valincr := (Ymax - Ymin) / 10.0;
     for i := 1 to 11 do
     begin
          value := Ymax - ((i-1) * valincr);
          outline := format('%8.2f',[value]);
          Title := outline;
          strhi := BlankFrm.Image1.Canvas.TextHeight(Title);
          xpos := 10;
          Yvalue := Ymax - (valincr * (i-1));
          ypos := ceil(vhi * ( (Ymax - Yvalue) / (Ymax - Ymin)));
          ypos := ypos + vtop - strhi div 2;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
          xpos := hleft;
          ypos := ypos + strhi div 2;
          BlankFrm.Image1.Canvas.MoveTo(xpos,ypos);
          xpos := hleft - 10;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     end;

     // get xpos and ypos for first point to second point
second: xpos := hleft;
     ypos := vtop;
     BlankFrm.Image1.Canvas.MoveTo(xpos,ypos); // Probability := 1 at time 0
     if (curveno = 1) then BlankFrm.Image1.Canvas.Pen.Color := clNavy
     else BlankFrm.Image1.Canvas.Pen.Color := clRed;
     ypos := ceil(vhi * ( (Ymax - Ypoints[0]) / (Ymax - Ymin)));
     ypos := ypos + vtop;
     xpos := ceil(hwide * ( (Xpoints[1] - Xmin) / (Xmax - Xmin)));
     xpos := xpos + hleft;
     BlankFrm.Image1.Canvas.LineTo(xpos,ypos);

     // draw points for x and y pairs
     oldxpos := xpos;
     oldypos := ypos;
     for i := 1 to N - 1 do
     begin
          ypos := ceil(vhi * ( (Ymax - Ypoints[i]) / (Ymax - Ymin)));
          ypos := ypos + vtop;
          if (ypos <> oldypos) then // draw line down to new ypos using old xpos
          begin
              if (curveno = 1) then BlankFrm.Image1.Canvas.Pen.Style := psSolid
              else BlankFrm.Image1.Canvas.Pen.Style := psDot;
              BlankFrm.Image1.Canvas.LineTo(oldxpos,ypos);
          end;
          xpos := ceil(hwide * ( (Xpoints[i] - Xmin) / (Xmax - Xmin)));
          xpos := xpos + hleft;
          oldxpos := xpos;
          oldypos := ypos;
          BlankFrm.Image1.Canvas.Pen.Style := psSolid;
          BlankFrm.Image1.Canvas.LineTo(xpos,ypos);
     end;

     // show censored
     BlankFrm.Image1.Canvas.Pen.Style := psSolid;
     BlankFrm.Image1.Canvas.Pen.Color := clBlack;
     for i := 1 to N do
     begin
          if ((Dropped[i] = 0) and (curveno = 1)) then continue;
          if ((Dropped2[i] = 0) and (curveno = 2)) then continue;
          if (curveno = 1) then
          begin
                BlankFrm.Image1.Canvas.Font.Color := clNavy;
                ypos := vbottom + 35;
                xpos := ceil(hwide * ((Xpoints[i] - Xmin) / (Xmax - Xmin)));
                xpos := xpos + hleft;
                outline := format('%d',[Dropped[i]]);
                Title := outline;
                BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
          end
          else
          begin
                BlankFrm.Image1.Canvas.Font.Color := clRed;
                ypos := vbottom + 48;
                xpos := ceil(hwide * ((Xpoints[i] - Xmin) / (Xmax - Xmin)));
                xpos := xpos + hleft;
                outline := format('%d',[Dropped2[i]]);
                Title := outline;
                BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
          end;
     end;

     BlankFrm.Image1.Canvas.Font.Color := clBlack;
     ypos := vbottom + 60;
     Title := 'NUMBER CENSORED';
     xpos := hleft + (hwide div 2) - (BlankFrm.Image1.Canvas.TextWidth(Title) div 2);
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);

     BlankFrm.Image1.Canvas.Font.Color := clNavy;
     Title := 'EXPERIMENTAL';
     xpos := 5;
     ypos := vbottom + 35;
     BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
     if (curveno = 2) then
     begin
          BlankFrm.Image1.Canvas.Font.Color := clRed;
          Title := 'CONTROL';
          xpos := 5;
          ypos := vbottom + 48;
          BlankFrm.Image1.Canvas.TextOut(xpos,ypos,Title);
     end;
end;

procedure TKaplanMeierFrm.UpdateBtnStates;
var
  lSelected: Boolean;
  i: Integer;
begin
  lSelected := false;
  for i := 0 to VarList.Count-1 do
    if VarList.Selected[i] then
    begin
      lSelected := true;
      break;
    end;
  TimeInBtn.Enabled := lSelected and (TimeEdit.Text = '');
  EventInBtn.Enabled := lSelected and (EventEdit.Text = '');
  GroupInBtn.Enabled := lSelected and (GroupEdit.Text = '');
  TimeOutBtn.Enabled := (TimeEdit.Text <> '');
  EventOutBtn.Enabled := (EventEdit.Text <> '');
  GroupOutBtn.Enabled := (GroupEdit.Text <> '');
end;

procedure TKaplanMeierFrm.VarListSelectionChange(Sender: TObject; User: boolean);
begin
  UpdateBtnStates;
end;

initialization
  {$I kaplanmeierunit.lrs}

end.

