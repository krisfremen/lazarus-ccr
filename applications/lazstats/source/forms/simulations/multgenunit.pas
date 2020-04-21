unit MultGenUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Grids, ExtCtrls, Math,
  Globals, MainUnit, OutputUnit, DictionaryUnit, MatrixLib, ContextHelpUnit;

type

  { TMultGenFrm }

  TMultGenFrm = class(TForm)
    Bevel1: TBevel;
    HelpBtn: TButton;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    PerturbChk: TCheckBox;
    SampleChk: TCheckBox;
    ParmsChk: TCheckBox;
    NoObsEdit: TEdit;
    Label2: TLabel;
    NoVarsEdit: TEdit;
    Label1: TLabel;
    Grid: TStringGrid;
    procedure CancelBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridKeyPress(Sender: TObject; var Key: char);
    procedure GridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure HelpBtnClick(Sender: TObject);
    procedure NoObsEditExit(Sender: TObject);
    procedure NoObsEditKeyPress(Sender: TObject; var Key: char);
    procedure NoVarsEditExit(Sender: TObject);
    procedure NoVarsEditKeyPress(Sender: TObject; var Key: char);
    procedure ResetBtnClick(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
  private
    { private declarations }
    NoVars : integer;
    NoObs  : integer;
    gridrow, gridcol : integer;

  public
    { public declarations }
  end; 

var
  MultGenFrm: TMultGenFrm;

implementation

{ TMultGenFrm }

procedure TMultGenFrm.ResetBtnClick(Sender: TObject);
VAR i, j : integer;
begin
    NoVarsEdit.Text := '';
    NoObsEdit.Text := '';
    ParmsChk.Checked := true;
    SampleChk.Checked := true;
    Grid.RowCount := 2;
    Grid.ColCount := 2;
    for i := 0 to 1 do
        for j := 0 to 1 do Grid.Cells[i,j] := '';
    //CancelBtn.SetFocus;   // <-- is this needed?
end;

procedure TMultGenFrm.ReturnBtnClick(Sender: TObject);
begin
  exit;
end;

procedure TMultGenFrm.FormShow(Sender: TObject);
begin
    ResetBtnClick(self);
end;

procedure TMultGenFrm.ComputeBtnClick(Sender: TObject);
var
    RhoMat : DblDyneMat;
    SampMat : DblDyneMat;
    Mus : DblDyneVec;
    means : DblDyneVec;
    Sigmas : DblDyneVec;
    stddevs : DblDyneVec;
    i, j, k, i1, i2, n2, k1 : integer;
    determ, n3, r1, s8, s9, d2, x, y, mean : double;
    linestring : string;
    cellstring : string;
    title : string;
    RowLabels: StrDyneVec;
    ColLabels: StrDyneVec;
begin
    OutputFrm.RichEdit.Clear;

    // get memory allocations
    SetLength(RhoMat,NoVars,NoVars);
    SetLength(SampMat,NoVars,NoVars);
    SetLength(Mus,NoVars);
    SetLength(means,NoVars);
    SetLength(Sigmas,NoVars);
    SetLength(stddevs,NoVars);
    SetLength(RowLabels,NoVars);
    SetLength(ColLabels,NoVars);

    // get data from grid into arrays
    for i := 1 to NoVars do
        for j := 1 to NoVars do
            begin
                 RhoMat[i-1,j-1] := StrToFloat(Grid.Cells[i,j]);
            end;
    for i := 1 to NoVars do
    begin
        Mus[i-1] := StrToFloat(Grid.Cells[i,NoVars+1]);
        Sigmas[i-1] := StrToFloat(Grid.Cells[i,NoVars+2]);
        RowLabels[i-1] := Grid.Cells[i,0];
        ColLabels[i-1] := RowLabels[i-1];
    end;

    // get determinant of Rho matrix, i.e. check for singularity
     for i := 0 to NoVars-1 do
     begin
         for j := 0 to NoVars - 1 do
         begin
              SampMat[i,j] := RhoMat[i,j] * Sigmas[i] * Sigmas[j];
              RhoMat[i,j] := SampMat[i,j];
         end;
     end;

     n2 := 1;
     i1 := 0;
     while (n2 < NoVars) do
     begin
        for i := n2 to NoVars - 1 do
        begin
            n3 := RhoMat[i,i1] / RhoMat[i1,i1];
            for j := n2 to NoVars - 1 do RhoMat[i,j] := RhoMat[i,j] - (RhoMat[i1,j] * n3);
        end;
        i1 := n2;
        n2 := N2 + 1;
     end;
     determ := 1.0;
     for i := 0 to NoVars - 1 do determ := determ * RhoMat[i,i];
     linestring := format('Determinant of the population matrix = %10.4f',[determ]);
     OutputFrm.RichEdit.Lines.Add(linestring);

     // triangular factorization
     if (abs(determ) > 0.00001) then
     begin
        if (SampMat[0,0] < 0.0) then SampMat[0,0] := 1.0;
        r1 := sqrt(SampMat[0,0]);
        for i := 0 to NoVars - 1 do
        begin
            RhoMat[i,0] := SampMat[i,0] / r1;
            for j := 1 to NoVars - 1 do RhoMat[i,j] := 0.0;
        end;
        for i := 1 to NoVars - 1 do
        begin
            s9 := 0.0;
            k1 := i - 1;
            for k := 0 to k1 - 1 do s9 := s9  + (RhoMat[i,k] * RhoMat[i,k]);
            d2 := SampMat[i,i] - s9;
            if (d2 > 0.0) then
            begin
                RhoMat[i,i] := sqrt(d2);
                for j := 1 to i - 1 do
                begin
                    if (j <> i) then
                    begin
                        s8 := 0.0;
                        k1 := j - 1;
                        for k := 0 to k1 - 1 do s8 := s8 + (RhoMat[i,k] * RhoMat[j,k]);
                        RhoMat[i,j] := (SampMat[i,j] - s8) / RhoMat[j,j];
                    end;
                end; // end j loop
            end; // end if d2 > 0
        end; // end i loop
//        title := 'Triangularized Matrix';
//        MAT_PRINT(RhoMat,NoVars,NoVars,title,RowLabels,ColLabels,NoObs);

        // initialize variables for mainform grid
        NoVariables := 0;
        DictionaryFrm.DictGrid.RowCount := 1;
        DictionaryFrm.DictGrid.ColCount := 8;
        if not PerturbChk.Checked then
        begin
             for i := 1 to NoVars do
             begin
                  DictionaryFrm.NewVar(i);
//                  NoVariables := NoVariables + 1;
             end;
             NoCases := NoObs;
             OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVars);
             OS3MainFrm.NoCasesEdit.Text := IntToStr(NoObs);
        end else
        begin
             for i := 1 to NoVars*2 do
             begin
                  DictionaryFrm.NewVar(i);
//                  NoVariables := NoVariables + 1;
             end;
             NoCases := NoObs;
             OS3MainFrm.NoVarsEdit.Text := IntToStr(NoVars*2);
             OS3MainFrm.NoCasesEdit.Text := IntToStr(NoObs);
        end;

        // Now generate score vectors
        for i2 := 0 to NoObs - 1 do // rows
        begin // label case heading
            cellstring := format('Case%d',[i2+1]);
            OS3MainFrm.DataGrid.Cells[0,i2+1] := cellstring;
            for i := 0 to NoVars -1 do stddevs[i] := RandG(0.0,1.0);
            for i := 0 to NoVars - 1 do
            begin
                x := 0.0;
                for j := 0 to i do x := x + (RhoMat[i,j] * stddevs[j]);
                mean := StrToFloat(Grid.Cells[i+1,NoVars+1]);
                cellstring := format('%10.3f',[x+mean]);
                OS3MainFrm.DataGrid.Cells[i+1,i2+1] := cellstring;
            end; // next variable
        end;  // next observation
     end; // if abs(determ > .00001)

     // if perturbation elected, convert generated data to z scores and perturb
     // with the selected perturbation coefficients
     if PerturbChk.Checked then
     begin
          for i := 1 to NoVars do
          begin
               means[i-1] := 0.0;
               stddevs[i-1] := 0.0;
          end;
          for i := 1 to NoVars do
          begin
               for j := 1 to NoObs do
               begin
                    x := StrToFloat(OS3MainFrm.DataGrid.Cells[i,j]);
                    means[i-1] := means[i-1] + x;
                    stddevs[i-1] := stddevs[i-1] + (x * x);
               end;
               stddevs[i-1] := stddevs[i-1] - (means[i-1] * means[i-1] / NoObs);
               stddevs[i-1] := stddevs[i-1] / (NoObs - 1);
               stddevs[i-1] := sqrt(stddevs[i-1]);
               means[i-1] := means[i-1] / NoObs;
               OS3MainFrm.DataGrid.Cells[NoVars+i,0] := OS3MainFrm.DataGrid.Cells[i,0] + 'Z';
          end;
          for i := 1 to NoVars do
          begin
               for j := 1 to NoObs do
               begin
                    x := StrToFloat(OS3MainFrm.DataGrid.Cells[i,j]);
                    x := (x - means[i-1]) / stddevs[i-1];
                    OS3MainFrm.DataGrid.Cells[NoVars+i,j] := FloatToStr(x);
               end;
          end;
          // Now, show perturbation options form and select coefficients

     end; // end if perturbchk is checked

    // print parameters if checked
    if ParmsChk.Checked then
    begin
        for i := 1 to NoVars do
            for j := 1 to NoVars do RhoMat[i-1,j-1] := StrToFloat(Grid.Cells[i,j]);
        for i := 1 to NoVars do
        begin
            Mus[i-1] := StrToFloat(Grid.Cells[i,NoVars+1]);
            Sigmas[i-1] := StrToFloat(Grid.Cells[i,NoVars+2]);
        end;
        title := 'Rho Matrix';
        MAT_PRINT(RhoMat,NoVars,NoVars,title,RowLabels,ColLabels,NoObs);
        title := 'Population Means';
        DynVectorPrint(Mus,NoVars,title,RowLabels,NoObs);
        title := 'Sigmas';
        DynVectorPrint(Sigmas,NoVars,title,RowLabels,NoObs);
        OutputFrm.ShowModal;
    end;

    // do sample values if checked
    if SampleChk.Checked then
    begin
        OutputFrm.RichEdit.Clear;
        for i := 1 to NoVars do
        begin
            for j := 1 to NoVars do SampMat[i-1,j-1] := 0.0;
            means[i-1] := 0.0;
            stddevs[i-1] := 0.0;
        end;
        for i := 1 to NoObs do
        begin
            for j := 0 to NoVars - 1 do
            begin
                x := StrToFloat(OS3MainFrm.DataGrid.Cells[j+1,i]);
                for k := 0 to NoVars - 1 do
                begin // cross-products matrix
                    y := StrToFloat(OS3MainFrm.DataGrid.Cells[k+1,i]);
                    SampMat[j,k] := SampMat[j,k] + (x * y);
                end;
                means[j] := means[j] + x;
            end;
        end;
        // variance - covariance matrix
        for i := 0 to NoVars - 1 do
        begin
            for j := 0 to NoVars - 1 do
            begin
                SampMat[i,j] := SampMat[i,j] - (means[i] * means[j] / NoObs);
                SampMat[i,j] := SampMat[i,j] / (NoObs - 1.0);
            end;
            stddevs[i] := sqrt(SampMat[i][i]);
        end;
        for i := 0 to NoVars - 1 do
        begin
            for j := 0 to NoVars - 1 do
            begin  // correlation matrix
                SampMat[i,j] := SampMat[i,j] / (stddevs[i] * stddevs[j]);
            end;
            means[i] := means[i] / NoObs;
        end;
        title := 'Sample r Matrix';
        MAT_PRINT(SampMat,NoVars,NoVars,title,RowLabels,ColLabels,NoObs);
        title := 'Sample Means';
        DynVectorPrint(means,NoVars,title,RowLabels,NoObs);
        title := 'Standard Deviations';
        DynVectorPrint(stddevs,NoVars,title,RowLabels,NoObs);
        OutputFrm.ShowModal;
    end;

    // dispose of arrays
    ColLabels := nil;
    RowLabels := nil;
    stddevs := nil;
    Sigmas := nil;
    means := nil;
    Mus := nil;
    SampMat := nil;
    RhoMat := nil;
end;

procedure TMultGenFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
end;

procedure TMultGenFrm.CancelBtnClick(Sender: TObject);
begin
  exit;
end;

procedure TMultGenFrm.GridKeyPress(Sender: TObject; var Key: char);
begin
    gridrow := Grid.Row;
    gridcol := Grid.Col;
    if ord(Key) = 13 then
    begin
         if (gridrow <= gridcol) then
         begin
            grid.Cells[gridrow,gridcol] := grid.Cells[gridcol,gridrow];
         end;
    end;
end;

procedure TMultGenFrm.GridSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
         if (gridrow <= gridcol) then
         begin
            grid.Cells[gridrow,gridcol] := grid.Cells[gridcol,gridrow];
         end;
end;

procedure TMultGenFrm.HelpBtnClick(Sender: TObject);
begin
  if ContextHelpForm = nil then
    Application.CreateForm(TContextHelpForm, ContextHelpForm);
  ContextHelpForm.HelpMessage((Sender as TButton).Tag);
end;

procedure TMultGenFrm.NoObsEditExit(Sender: TObject);
var
    i, j : integer;
    cellstring : string;
begin
    NoObs := StrToInt(NoObsEdit.Text);
    if NoObs > 0 then
    begin
        OS3MainFrm.DataGrid.RowCount := NoObs + 1;
        OS3MainFrm.DataGrid.ColCount := NoVars + 1;
        for i := 1 to NoObs do
        begin
            for j := 1 to NoVars do
            begin
                 OS3MainFrm.DataGrid.Cells[j,i] := '';
            end;
        end;
     end;

     for j := 1 to NoVars do
     begin
          cellstring := format('VAR%d',[j]);
          OS3MainFrm.DataGrid.Cells[j,0] := cellstring;
     end;

    Grid.Cells[0,0] := 'Variable';
    Grid.Cells[0,NoVars+1] := 'Mean';
    Grid.Cells[0,NoVars+2] := 'Std.Dev.';
end;

procedure TMultGenFrm.NoObsEditKeyPress(Sender: TObject; var Key: char);
begin
    if ord(Key) = 13 then NoObsEditExit(self);
end;

procedure TMultGenFrm.NoVarsEditExit(Sender: TObject);
var
    i: integer;
    cellstring : string;
begin
    NoVars := StrToInt(NoVarsEdit.Text);
    if NoVars > 0 then
    begin
        Grid.RowCount := NoVars + 3;
        Grid.ColCount := NoVars + 1;
        for i := 1 to NoVars do
        begin
            Grid.Cells[i,i] := FloatToStr(1.0);
            cellstring := format('VAR%d',[i]);
            Grid.Cells[i,0] := cellstring;
{            for j := 1 to NoVars do
            begin
                if i <> j then
                begin
                    Grid.Cells[i,j] := '';
                    Grid.Cells[j,i] := '';
                end;
            end; // for j := 1 to NoVars }
        end; // for i := 1 to NoVars

    end; // if NoVars > 0
end;

procedure TMultGenFrm.NoVarsEditKeyPress(Sender: TObject; var Key: char);
begin
    if ord(Key) = 13 then NoVarsEditExit(self);
end;

initialization
  {$I multgenunit.lrs}

end.

