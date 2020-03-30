unit FactorUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, OutputUnit, FunctionsLib, GraphLib, Globals, MatrixLib,
  DataProcs, DictionaryUnit;

type

  { TFactorFrm }

  TFactorFrm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    ReturnBtn: TButton;
    MinRootEdit: TEdit;
    MaxItersEdit: TEdit;
    MaxFactorsEdit: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    SaveCorsBtn: TCheckBox;
    SaveDialog1: TSaveDialog;
    SaveFactBtn: TCheckBox;
    SortBtn: TCheckBox;
    ScreeBtn: TCheckBox;
    ComUnBtn: TCheckBox;
    PlotBtn: TCheckBox;
    ScoresBtn: TCheckBox;
    DescBtn: TCheckBox;
    RMatBtn: TCheckBox;
    UnrotBtn: TCheckBox;
    PcntTrBtn: TCheckBox;
    GroupBox1: TGroupBox;
    InBtn: TBitBtn;
    OutBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    FactorList: TListBox;
    RotateGroup: TRadioGroup;
    TypeGroup: TRadioGroup;
    VarList: TListBox;
    procedure ComputeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure OutBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    procedure FACTORS(VAR eigenvalues : DblDyneVec;
                      VAR d2 : DblDyneVec;
                      VAR A : DblDyneMat;
                      N : integer;
                      factorchoice : integer);

    procedure factREORDER(VAR d : DblDyneVec;
                          VAR A : DblDyneMat;
                          VAR var_label : StrDyneVec;
                          N : integer);

    procedure SORT_LOADINGS(VAR v : DblDyneMat;
                            n1, n2 : integer;
                            VAR High_Factor : IntDyneVec;
                            VAR A : DblDyneVec;
                            VAR b : DblDyneVec;
                            VAR var_label : StrDyneVec;
                            order : IntDyneVec);

    procedure VARIMAX(VAR v : DblDyneMat;
                      n1, n2 : integer;
                      VAR RowLabels : StrDyneVec;
                      VAR ColLabels : StrDyneVec;
                      VAR order : IntDyneVec);

    procedure PROCRUST(VAR b : DblDyneMat;
                       nv, nb : integer;
                       VAR RowLabels : StrDyneVec;
                       VAR ColLabels : StrDyneVec);

    procedure LSFactScores(VAR F : DblDyneMat;
                           NoVars, NoFacts, NCases : integer;
                           VAR ColNoSelected : IntDyneVec;
                           VAR RowLabels : StrDyneVec);

    procedure QUARTIMAX(VAR v : DblDyneMat;
                        n1, n2 : integer;
                        VAR RowLabels : StrDyneVec;
                        VAR ColLabels : StrDyneVec;
                        VAR order : IntDyneVec);

    procedure ManualRotate(VAR v : DblDyneMat;
                           n1, n2 : integer;
                           VAR RowLabels : StrDyneVec;
                           VAR ColLabels : StrDyneVec;
                           VAR order : IntDyneVec;
                           Sender : TObject);

  public
    { public declarations }
  end; 

var
  FactorFrm: TFactorFrm;

implementation

uses
  Math, RotateUnit;

{ TFactorFrm }

procedure TFactorFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     FactorList.Clear;
     OutBtn.Enabled := false;
     InBtn.Enabled := true;
     TypeGroup.ItemIndex := 0;
     RotateGroup.ItemIndex := 0;
     DescBtn.Checked := false;
     RMatBtn.Checked := false;
     UnrotBtn.Checked := false;
     PcntTrBtn.Checked := false;
     ScreeBtn.Checked := false;
     ComUnBtn.Checked := false;
     PlotBtn.Checked := false;
     ScoresBtn.Checked := false;
     SaveCorsBtn.Checked := false;
     SaveFactBtn.Checked := false;
     SortBtn.Checked := false;
     MinRootEdit.Text := '1';
     MaxItersEdit.Text := '25';
     MaxFactorsEdit.Text := '';
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TFactorFrm.ComputeBtnClick(Sender: TObject);
label again;
var
   i, j, k, L, Nroots, noiterations, NoSelected, factorchoice : integer;
   maxiters, prtopts, maxnoroots, count : integer;
   TempMat, V, corrmat, ainverse, Loadings : DblDyneMat;
   Eigenvector, pcnttrace, b, communality, xvector, yvector, d2 : DblDyneVec;
   means, variances, stddevs, W : DblDyneVec;
   MaxRoot,  criterion, Difference, minroot, maxk, trace : double;
   cellstring, outline, xtitle, ytitle : string;
   ColNoSelected : IntDyneVec;
   RowLabels, ColLabels : StrDyneVec;
   MatInput : boolean;
   Title : string;
   filename : string;
   Save_Cursor : TCursor;
   errorcode : boolean = false;
begin
     MaxRoot := 0.0;
     noiterations := 0;
     maxnoroots := 0;
     prtopts := 0;

    criterion := 0.0001; //Convergence of communality estimates
    factorchoice := 1;  // assume principal component
    if (TypeGroup.ItemIndex = 1) then factorchoice := 2;
    if (TypeGroup.ItemIndex = 2) then factorchoice := 3;
    if (TypeGroup.ItemIndex = 3) then factorchoice := 4;
    if (TypeGroup.ItemIndex = 4) then factorchoice := 5;
    if (TypeGroup.ItemIndex = 5) then factorchoice := 6;
    if (TypeGroup.ItemIndex = 6) then factorchoice := 7;
    if (RMatBtn.Checked) then prtopts := 3;
    if (RMatBtn.Checked) then prtopts := 2;
    if ((RMatBtn.Checked) and (DescBtn.Checked)) then prtopts := 1;
    maxiters := StrToInt(MaxItersEdit.Text);
    if (MaxFactorsEdit.Text <> '') then
       maxnoroots := StrToInt(MaxFactorsEdit.Text);

    // Setup the output
    OutputFrm.RichEdit.Clear;
    OutputFrm.RichEdit.Lines.Add('Factor Analysis');
    OutputFrm.RichEdit.Lines.Add('See Rummel, R.J., Applied Factor Analysis');
    OutputFrm.RichEdit.Lines.Add('Northwestern University Press, 1970');
    OutputFrm.RichEdit.Lines.Add('');

    if  FactorList.Items.Count = 0 then MatInput := true
    else begin
         NoSelected := FactorList.Items.Count;
         MatInput := false;
    end;

    // Allocate space on heap
    SetLength(corrmat,NoVariables+1,NoVariables+1);
    SetLength(TempMat,NoVariables,NoVariables);
    SetLength(ainverse,NoVariables,NoVariables);
    SetLength(V,NoVariables,NoVariables);
    SetLength(W,NoVariables);
    SetLength(Loadings,NoVariables,NoVariables);
    SetLength(Eigenvector,NoVariables);
    SetLength(communality,NoVariables);
    SetLength(pcnttrace,NoVariables);
    SetLength(b,NoVariables);
    SetLength(d2,NoVariables);
    SetLength(xvector,NoVariables);
    SetLength(yvector,NoVariables);
    SetLength(means,NoVariables);
    SetLength(variances,NoVariables);
    SetLength(stddevs,NoVariables);
    SetLength(RowLabels,NoVariables);
    SetLength(ColLabels,NoVariables);
    SetLength(ColNoSelected,NoVariables);

    if MatInput then // matrix input
    begin
         OpenDialog1.Filter := 'Matrix files (*.MAT)|*.MAT|All files (*.*)|*.*';
         OpenDialog1.FilterIndex := 1;
         OpenDialog1.Title := 'INPUT MATRIX:';
         OpenDialog1.Execute;
         filename := OpenDialog1.FileName;
         MATREAD(corrmat,NoSelected,NoSelected,means,stddevs,count,RowLabels,
                 ColLabels,filename);
         for i := 1 to NoSelected do
         begin
              variances[i-1] := sqr(stddevs[i-1]);
              FactorList.Items.Add(RowLabels[i-1]);
              ColNoSelected[i-1] := i;
         end;
         NoCases := count;
    end

    else
    begin
        for i := 1 to NoSelected do
        begin
            cellstring := FactorList.Items.Strings[i-1];
            for j := 1 to NoVariables do
            begin
                if (cellstring = OS3MainFrm.DataGrid.Cells[j,0]) then
                begin
                   ColNoSelected[i-1] := j;
                   ColLabels[i-1] := cellstring;
                   RowLabels[i-1] := cellstring;
                end;
            end;
        end;
    end;

    count := NoCases;
    //Obtain correlation matrix and, if required simultaneous Multiple Correlations
    if (MatInput = false) then
//         Correlate(NoSelected,NoCases,ColNoSelected,means,variances,
//                   stddevs,corrmat,3,IER,count);
        Correlations(NoSelected,ColNoSelected,corrmat,means,variances,
                     stddevs,errorcode,count);
    if RmatBtn.Checked then // print correlation matrix
    begin
         Title := 'Total Correlation Matrix';
         MAT_PRINT(corrmat,NoSelected,NoSelected,Title,RowLabels,
              ColLabels,count);
    end;
    if DescBtn.Checked then // print descriptives
    begin
         // print mean, variance and std. dev.s for variables
         outline := 'MEANS';
         DynVectorPrint(Means,NoSelected,outline,RowLabels,count);
         outline := 'VARIANCES';
         DynVectorPrint(Variances,NoSelected,outline,RowLabels,count);
         outline := 'STANDARD DEVIATIONS';
         DynVectorPrint(StdDevs,NoSelected,outline,RowLabels,count);
    end;
    k := NoSelected;

    // Save correlation matrix if checked
    if (SaveCorsBtn.Checked) then
    begin
        SaveDialog1.Filter := 'Matrix files (*.MAT)|(*.MAT)|All files (*.*)|(*.*)';
        SaveDialog1.FilterIndex := 1;
        SaveDialog1.Title := 'SAVE MATRIX:';
        SaveDialog1.Execute;
        filename := SaveDialog1.FileName;
        MATSAVE(corrmat,NoSelected,NoSelected,means,stddevs,count,RowLabels,
                ColLabels,filename);
    end;
    maxk := k;
    Nroots := k;

    if ( factorchoice <> 1) then //not a principal component analysis
    begin
        //get matrix inverse, squared Multiple Correlations
        //Uniqueness (1-squared multiple Correlations, and
        //variance of residuals (D squared)
        for i := 1 to NoSelected do
            for j := 1 to NoSelected do
                ainverse[i-1,j-1] := corrmat[i-1,j-1];
        SVDinverse(ainverse,k);
        for i := 1 to k do
        begin
            d2[i-1] := 1.0 / ainverse[i-1,i-1];
            communality[i-1] := 1.0 - d2[i-1];
        end;

        case factorchoice of
         2: begin
               outline := 'Partial Image Analysis';
               OutputFrm.RichEdit.Lines.Add(outline);
                 // Save corrmat in TempMat for temporary use
                 for i := 1 to k do
                     for j := 1 to k do TempMat[i-1,j-1] := corrmat[i-1,j-1];
               for i := 1 to k do corrmat[i-1,i-1] := communality[i-1];
               if RmatBtn.Checked then
               begin
                  OutputFrm.RichEdit.Lines.Add('Communality Estimates are Squared Multiple Correlations.');
                  Title := 'Partial Image Matrix';
                  MAT_PRINT(corrmat,k,k,Title,RowLabels,ColLabels,count);
                  OutputFrm.ShowModal;
                  OutputFrm.RichEdit.Clear;
               end;
             end;
         3: begin
                  outline := 'Guttman Image Analysis';
                  OutputFrm.RichEdit.Lines.Add(outline);
                  //pre and post multiply inverse of R by D2 to obtain anti-image matrix
                  for i := 1 to k do
                      for j := 1 to k do
                          ainverse[i-1,j-1] := d2[i-1] * ainverse[i-1,j-1] * d2[j-1];
                  if RmatBtn.Checked then
                  begin
                     Title := 'Anti-image covariance matrix';
                     MAT_PRINT(ainverse,k,k,Title,RowLabels,ColLabels,count);
                     OutputFrm.ShowModal;
                     OutputFrm.RichEdit.Clear;
                  end;
                  for i := 1 to k do
                      for j := 1 to k do
                          corrmat[i-1,j-1] := corrmat[i-1,j-1] + ainverse[i-1,j-1];
                  for i := 1 to k do
                      corrmat[i-1,i-1] := corrmat[i-1,i-1] - (2.0 * d2[i-1]);
                  if RmatBtn.Checked then
                  begin
                     Title := 'Image Covariance Matrix Analyzed';
                     MAT_PRINT(corrmat,k,k,Title,RowLabels,ColLabels,count);
                     OutputFrm.ShowModal;
                     OutputFrm.RichEdit.Clear;
                  end;
              end;
         4:   begin
                  //pre and post multiply inverse of R by D2 to obtain anti-image matrix
                  for i := 1 to k do
                      for j := 1 to k do
                          ainverse[i-1,j-1] := d2[i-1] * ainverse[i-1,j-1] * d2[j-1];
                  for i := 1 to k do
                      for j := 1 to k do
                          corrmat[i-1,j-1] := corrmat[i-1,j-1] + ainverse[i-1,j-1];
                  for i := 1 to k do
                      corrmat[i-1,i-1] := corrmat[i-1,i-1] - (2.0 * d2[i-1]);
                  outline := 'Harris Scaled Image Analysis';
                  for i := 1 to k do
                      for j := 1 to k do
                          corrmat[i-1,j-1] := (1.0 / sqrt(d2[i-1]) *
                                corrmat[i-1,j-1] * (1.0 / sqrt(d2[j-1])));
                  if RmatBtn.Checked then
                  begin
                     Title := 'Harris Scaled Image Covariance Matrix';
                     MAT_PRINT(corrmat,k,k,Title,RowLabels,ColLabels,count);
                     OutputFrm.ShowModal;
                     OutputFrm.RichEdit.Clear;
                  end;
              end;
         5:  begin
                  outline := 'Canonical Factor Analysis';
                  OutputFrm.RichEdit.Lines.Add(outline);
                  for i := 1 to k do corrmat[i-1,i-1] := communality[i-1];
                  for i := 1 to k do
                      for j := 1 to k do
                          corrmat[i-1,j-1] := (1.0 / sqrt(d2[i-1])) *
                             corrmat[i-1,j-1] * (1.0 / sqrt(d2[j-1]));
                  if RmatBtn.Checked then
                  begin
                     Title := 'Canonical Covariance Matrix';
                     MAT_PRINT(corrmat,k,k,Title,RowLabels,ColLabels,count);
                     OutputFrm.ShowModal;
                     OutputFrm.RichEdit.Clear;
                  end;
              end;
        6:  begin
                 outline := 'Alpha Factor Analysis';
                 OutputFrm.RichEdit.Lines.Add(outline);
                 // Save corrmat in TempMat for temporary use
                 for i := 1 to k do
                     for j := 1 to k do TempMat[i-1,j-1] := corrmat[i-1,j-1];
                 for i := 1 to k do corrmat[i-1,i-1] := communality[i-1];
                 for i := 1 to k do
                     for j := 1 to k do
                         corrmat[i-1,j-1] := (1.0 / sqrt(communality[i-1])) *
                             corrmat[i-1,j-1] * (1.0 / sqrt(communality[j-1]));
                 if RmatBtn.Checked then
                 begin
                    Title := 'Initial Alpha Factor Matrix';
                    MAT_PRINT(corrmat,k,k,Title,RowLabels,ColLabels,count);
                    OutputFrm.ShowModal;
                    OutputFrm.RichEdit.Clear;
                 end;
             end;
        7:   begin // Principal Axis Factor Analysis
                 // Save corrmat in TempMat for temporary use
                 for i := 1 to k do
                     for j := 1 to k do TempMat[i-1,j-1] := corrmat[i-1,j-1];
               for i := 1 to k do corrmat[i-1,i-1] := communality[i-1];
               if RmatBtn.Checked then
               begin
                  OutputFrm.RichEdit.Lines.Add('Initial Communality Estimates are Squared Multiple Correlations.');
                  Title := 'Principals Axis Factor Analysis Matrix';
                  MAT_PRINT(corrmat,k,k,Title,RowLabels,ColLabels,count);
                  OutputFrm.ShowModal;
                  OutputFrm.RichEdit.Clear;
               end;
             end;
        end; // end case
    end // end if factor choice not equal to 1 (Principals Components)

    else
    begin
        outline := 'Principal Components Analysis';
        OutputFrm.RichEdit.Lines.Add(outline);
        if RmatBtn.Checked then
        begin
           Title := 'Correlation Matrix Factor Analyzed';
           MAT_PRINT(corrmat,k,k,Title,RowLabels,ColLabels,count);
           OutputFrm.ShowModal;
           OutputFrm.RichEdit.Clear;
        end;
    end;

    //Calculate trace of the matrix to be analyzed
    trace := 0.0;
    for i := 1 to k do trace := trace  + corrmat[i-1,i-1];
    outline := format('Original matrix trace = %6.2f',[trace]);
    OutputFrm.RichEdit.Lines.Add(outline);

again:
    for i := 1 to k do
        for j := 1 to k do ainverse[i-1,j-1] := corrmat[i-1,j-1];
    eigens(ainverse,Eigenvector,k);
    if ((factorchoice = 6)or (factorchoice = 7))then  //iteratively solve for communalities
    begin
        //denormalize eigenvectors
        for i := 1 to k do
        begin
            for j := 1 to k do
            begin
                if ( Eigenvector[j-1] > 0.0) then
                    ainverse[i-1,j-1] := ainverse[i-1,j-1] * sqrt(Eigenvector[j-1])
                else
                begin
                    ainverse[i-1,j-1] := 0.0;
                    Eigenvector[j-1] := 0.0;
                end;
            end;
            b[i-1] := 0.0;
        end;

        //get communality estimate from sum of squared loadings in TempMat
        for j := 1 to k do
            for i := 1 to k do
                b[i-1] := b[i-1] + (ainverse[i-1,j-1] * ainverse[i-1,j-1]);
        for i := 1 to k do
        begin
            if (b[i-1] > 1.0) then
            begin
               b[i-1] := 1.0;
               outline := 'WARNING! A communality estimate greater than 1.0 found.';
               OutputFrm.RichEdit.Lines.Add(outline);
               outline := 'Value replaced by 1.0.  View results with skepticism.';
               OutputFrm.RichEdit.Lines.Add(outline);
            end;
        end;
        Difference := 0.0;
        for i := 1 to k do Difference := Difference + abs(b[i-1] - communality[i-1]);
        if ((Difference > criterion) and (noiterations < maxiters)) then
        begin
           for i := 1 to k do // restore original r matrix
               for j := 1 to k do corrmat[i-1,j-1] := TempMat[i-1,j-1];
           // Place new communalities in the diagonal
           for i := 1 to k do corrmat[i-1,i-1] := b[i-1];
           // scale for alpha analysis
           if (factorchoice = 6) then
           begin
                  for i := 1 to k do
                     for j := 1 to k do
                         corrmat[i-1,j-1] := (1.0 / sqrt(b[i-1])) *
                             corrmat[i-1,j-1] * (1.0 / sqrt(b[j-1]));
           end;
           // Save new communality estimates
           for i := 1 to k do communality[i-1] := b[i-1];
            noiterations := noiterations + 1;
            goto again;
        end

        else
        begin
            if (noiterations >= maxiters) then
            begin
               outline := format('Factor Analysis failed to converge in %d iterations.',[maxiters]);
               OutputFrm.RichEdit.Lines.Add(outline);
            end;
            factREORDER(Eigenvector,ainverse,RowLabels,k);
        end;
    end

    else //principal components
    begin
        FACTORS(Eigenvector, d2, ainverse, k, factorchoice);
        factREORDER(Eigenvector, ainverse, RowLabels, k);
    end;
    Screen.Cursor := Save_Cursor;  // restore regular cursor

    for i := 1 to k do
        for j := 1 to k do
            Loadings[i-1,j-1] := ainverse[i-1,j-1];

    if (ScreeBtn.Checked) then
    begin
        SetLength(GraphFrm.Ypoints,1,k);
        SetLength(GraphFrm.Xpoints,1,k);
        for i := 1 to k do
        begin
            xvector[i-1] := i;
            GraphFrm.Xpoints[0,i-1] := i;
            GraphFrm.Ypoints[0,i-1] := Eigenvector[i-1];
        end;
        GraphFrm.nosets := 1;
        GraphFrm.nbars := k;
        GraphFrm.Heading := 'PLOT OF EIGENVALUES EXTRACTED';
        GraphFrm.XTitle := 'ROOT NUMBER';
        GraphFrm.YTitle := 'EIGENVALUE';
//        GraphFrm.Ypoints[1] := Eigenvector;
//        GraphFrm.Xpoints[1] := xvector;
        GraphFrm.AutoScaled := true;
        GraphFrm.PtLabels := false;
        GraphFrm.GraphType := 7; // 2d points
        GraphFrm.BackColor := clYellow;
        GraphFrm.ShowBackWall := true;
        GraphFrm.ShowModal;
    end;

    // Setup labels for factors
    for i := 1 to k do
    begin
        outline := format('Factor %d',[i]);
        ColLabels[i-1] := outline;
    end;

    //print results if requested
    if (UnrotBtn.Checked) then
    begin
       OutputFrm.RichEdit.Lines.Add('Roots (Eigenvalues) Extracted:');
       for i := 1 to Nroots do
       begin
            outline := format('%4d %6.3f',[i, Eigenvector[i-1]]);
            OutputFrm.RichEdit.Lines.Add(outline);
       end;
       OutputFrm.RichEdit.Lines.Add('');
       outline := 'Unrotated Factor Loadings';
       OutputFrm.RichEdit.Lines.Add(outline);
       Title := 'FACTORS';
       MAT_PRINT(Loadings,k,Nroots,Title,RowLabels,ColLabels,count);
       OutputFrm.RichEdit.Lines.Add('Percent of Trace In Each Root:');
       for i := 1 to Nroots do
       begin
           outline := format('%4d Root := %6.3f Trace := %6.3f Percent := %7.3f',
                [i, Eigenvector[i-1], trace, (Eigenvector[i-1]/ trace) * 100.0]);
           OutputFrm.RichEdit.Lines.Add(outline);
       end;
       OutputFrm.ShowModal;
       OutputFrm.RichEdit.Clear;
    end;

    // final communality estimates
    trace := 0.0;
    for i := 1 to k do
    begin
        b[i-1] := 0.0;
        for j := 1 to Nroots do b[i-1] := b[i-1] + (Loadings[i-1,j-1] * Loadings[i-1,j-1]);
        trace := trace + b[i-1];
    end;

    if (ComUnBtn.Checked) then
    begin
       OutputFrm.RichEdit.Lines.Add('');
       OutputFrm.RichEdit.Lines.Add('COMMUNALITY ESTIMATES');
       for i := 1 to k do
       begin
           outline := format('%3d %-10s %6.3f',[i,RowLabels[i-1],b[i-1]]);
           OutputFrm.RichEdit.Lines.Add(outline);
       end;
       OutputFrm.RichEdit.Lines.Add('');
       OutputFrm.ShowModal;
       OutputFrm.RichEdit.Clear;
    end;

    if ( Nroots > 1) then
    begin
        minroot := StrToFloat(MinRootEdit.Text);
        Nroots := 0;
        for i := 1 to k do
           if ( Eigenvector[i-1] > minroot) then Nroots := Nroots + 1;
        if (maxnoroots = 0) then maxnoroots := Nroots;
        if (Nroots > maxnoroots) then Nroots := maxnoroots;
        if (RotateGroup.ItemIndex = 0) then
           VARIMAX(Loadings, k, Nroots, RowLabels, ColLabels, ColNoSelected);
        if (RotateGroup.ItemIndex = 1) then
           ShowMessage('Oblimax not available - sorry!');
        if (RotateGroup.ItemIndex = 2) then
           QUARTIMAX(Loadings, k, Nroots, RowLabels, ColLabels, ColNoSelected);
        if (RotateGroup.ItemIndex = 3) then // graphical (manual) rotation
            ManualRotate(Loadings, k, Nroots, RowLabels, ColLabels, ColNoSelected,self);
        if (RotateGroup.ItemIndex = 4) then // Procrustean rotation to target
        begin // procrustean rotation
            PROCRUST(Loadings,k,Nroots,RowLabels,ColLabels);
        end;
    end;
    if (( factorchoice = 6) or (factorchoice = 7)) then
    begin
        outline := format('No. of iterations := %d',[noiterations]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;

    if (( Nroots > 1) and (PlotBtn.Checked)) then
    begin
        for i := 1 to Nroots - 1 do
        begin
            for j := i + 1 to Nroots do
            begin
                for L := 1 to k do
                begin
                    xvector[L-1] := Loadings[L-1,i-1];
                    yvector[L-1] := Loadings[L-1,j-1];
                end;
                xtitle := format('Factor %d',[i]);
                ytitle := format('Factor %d',[j]);
                scatplot(xvector, yvector, k, 'FACTOR PLOT', xtitle,
                         ytitle, -1.0, 1.0, -1.0, 1.0, RowLabels);
            end;  //Next j
        end; //Next i
    end;

    // Compute factor scores if checked
    if (ScoresBtn.Checked) then
    begin
        if (MatInput = true) then
            ShowMessage('Original subject scores unavailable (matrix input.)')
        else LSFactScores(Loadings,k,Nroots,NoCases,ColNoSelected,RowLabels);
    end;

    // Save loadings if checked
    if (SaveFactBtn.Checked) then
    begin
         SaveDialog1.Filter := 'Matrix File (*.MAT)|*.MAT|Any File (*.*)|*.*';
         SaveDialog1.FilterIndex := 1;
         SaveDialog1.Title := 'Save Factor Loadings';
         SaveDialog1.Execute;
         filename := SaveDialog1.FileName;
         MATSAVE(Loadings,k,Nroots,means,stddevs,count,RowLabels,ColLabels,filename);
    end;

    // Clean up the heap
    ColNoSelected := nil;
    ColLabels := nil;
    RowLabels := nil;
    stddevs := nil;
    variances := nil;
    means := nil;
    yvector := nil;
    xvector := nil;
    d2 := nil;
    b := nil;
    pcnttrace := nil;
    communality := nil;
    Eigenvector := nil;
    Loadings := nil;
    W := nil;
    V := nil;
    ainverse := nil;
    TempMat := nil;
    corrmat := nil;
    GraphFrm.Ypoints := nil;
    GraphFrm.Xpoints := nil;
end;

procedure TFactorFrm.InBtnClick(Sender: TObject);
VAR i, index : integer;
begin
     index := VarList.Items.Count;
     i := 0;
     while i < index do
     begin
         if (VarList.Selected[i]) then
         begin
            FactorList.Items.Add(VarList.Items.Strings[i]);
            VarList.Items.Delete(i);
            index := index - 1;
            i := 0;
         end
         else i := i + 1;
     end;
     OutBtn.Enabled := true;
end;

procedure TFactorFrm.OutBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := FactorList.ItemIndex;
     if index < 0 then
     begin
          OutBtn.Enabled := false;
          exit;
     end;
     VarList.Items.Add(FactorList.Items.Strings[index]);
     FactorList.Items.Delete(index);
end;

procedure TFactorFrm.FACTORS(var eigenvalues: DblDyneVec; var d2: DblDyneVec;
  var A: DblDyneMat; N: integer; factorchoice: integer);
var i, j : integer;

begin
     //eigenvalues is the vector of N roots, a is the matrix of column eigenvectors, n is the order of the vector
     //and matrix, factorchoice is an integer indicating the type of factor analysis, and d2 is
     //a scaling weight for scaled factor analysis types
     //The results are the normalized factor loadings returned in a.

     for i := 1 to N do
     begin
         for j := 1 to N do
         begin
             if ( eigenvalues[j-1] > 0) then A[i-1,j-1] := A[i-1,j-1] * sqrt(eigenvalues[j-1])
             else  A[i-1,j-1] := 0.0;
         end;
     end;
     if ((factorchoice = 4) or (factorchoice = 5)) then
     begin
         for i := 1 to N do
         begin
             for j := 1 to N do
             begin
                 if (d2[i-1] > 0) then  A[i-1,j-1] := A[i-1,j-1] * sqrt(d2[i-1])
                 else  A[i-1,j-1] := 0.0;
             end;
         end;
     end;
     if ( factorchoice = 6) then //alpha factor analysis
     begin
        for i := 1 to N do
        begin
            for j := 1 to N do
            begin
                if ( eigenvalues[j-1] > 0 ) then A[i-1,j-1] := A[i-1,j-1] * sqrt(1.0 - d2[i-1])
                else A[i-1,j-1] := 0.0;
            end;
        end;
     end;
end;

procedure TFactorFrm.factREORDER(var d: DblDyneVec; var A: DblDyneMat;
  var var_label: StrDyneVec; N: integer);
var
   i, j, k : integer;
   Temp : double;
begin
     // d is the vector of eigenvalues, A is the eigenvalues matrix,
     // var_label is the array of variable labels and
     // n is the vector and matrix order.

     for i := 1 to N - 1 do
     begin
          for j := i + 1 to N do
          begin
               if ( d[i-1] < d[j-1]) then
               begin
                    Temp := d[i-1];   // swap eigenvectors
                    d[i-1] := d[j-1];
                    d[j-1] := Temp;
                    for k := 1 to N do  // swap columns in iegenvector matrix
                    begin
                         Temp := A[k-1,i-1];
                         A[k-1,i-1] := A[k-1,j-1];
                         A[k-1,j-1] := Temp;
                    end;
               end;
          end;
     end;
end;

procedure TFactorFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ReturnBtn.Width]);
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  FAutoSized := true;
end;

procedure TFactorFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
  if OutputFrm = nil then
    Application.CreateForm(TOutputFrm, OutputFrm);
  if GraphFrm = nil then
    Application.CreateForm(TGraphFrm, GraphFrm);
  if DictionaryFrm = nil then
    Application.CreateForm(TDictionaryFrm, DictionaryFrm);
  if RotateFrm = nil then
    Application.CreateForm(TRotateFrm, RotateFrm);
end;

procedure TFactorFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
end;

procedure TFactorFrm.SORT_LOADINGS(var v: DblDyneMat; n1, n2: integer;
  var High_Factor: IntDyneVec; var A: DblDyneVec; var b: DblDyneVec;
  var var_label: StrDyneVec; order: IntDyneVec);
var
   i, j, k, itemp : integer;
   NoInFact : IntDyneVec;
   maxval, Temp : double;
   tempstr : string;

begin
     SetLength(NoInFact,NoVariables);

     // Reorder factors in descending sequence ( left to right )
     for j := 1 to n2 - 1 do
     begin                                 // factor j
          for k := j + 1 to n2 do
          begin                            // factor k
               if ( A[j-1] < A[k-1]) then
               begin                       // variance and factors need swapping
                    for i := 1 to n1 do
                    begin                  // swap factors
                         Temp := v[i-1,j-1];
                         v[i-1,j-1] := v[i-1,k-1];
                         v[i-1,k-1] := Temp;
                    end;
                    Temp := A[j-1];          // variance swap
                    A[j-1] := A[k-1];
                    A[k-1] := Temp;
               end;
          end;
     end;
     // Now select largest loading in each variable
     for j := 1 to n2 do NoInFact[j-1] := 0;
     for i := 1 to n1 do
     begin
          High_Factor[i-1] := 0;
          maxval := 0.0;
          for j := 1 to n2 do
          begin
               if ( abs(v[i-1,j-1]) > abs(maxval)) then
               begin
                    maxval := abs(v[i-1,j-1]);
                    High_Factor[i-1] := j;
               end;
          end;
     end;
     // Now sort matrix loadings
     for i := 1 to n1 - 1 do
     begin
          for j := i + 1 to n1 do
          begin
               if ( High_Factor[i-1] > High_Factor[j-1]) then
               begin
                    itemp := High_Factor[i-1];
                    High_Factor[i-1] := High_Factor[j-1];
                    High_Factor[j-1] := itemp;
                    for k := 1 to n2 do
                    begin                            // loading swap
                         Temp := v[i-1,k-1];
                         v[i-1,k-1] := v[j-1,k-1];
                         v[j-1,k-1] := Temp;
                    end;
                    tempstr := var_label[i-1];         // label swap
                    var_label[i-1] := var_label[j-1];
                    var_label[j-1] := tempstr;
                    Temp := b[i-1];                    // communality swap
                    b[i-1] := b[j-1];
                    b[j-1] := Temp;
                    itemp := order[i-1];
                    order[i-1] := order[j-1];
                    order[j-1] := itemp;
               end;
          end;
     end;
     NoInFact := nil;
end;

procedure TFactorFrm.VARIMAX(var v: DblDyneMat; n1, n2: integer;
  var RowLabels: StrDyneVec; var ColLabels: StrDyneVec; var order: IntDyneVec);
label nextone;
var
   pi : double;
   A, b, C : DblDyneVec;
   i, j, k, M, N, minuscount : integer;
   High_Factor : IntDyneVec;
   a1, b1, c1, c2, c3, c4, d1, x1, x2, Y, s1, Q, TotalPercent, t : double;
   outline : string;
   Title : string;
begin
     pi := 3.14159265358979;
     t := n1;
     SetLength(A,NoVariables);
     SetLength(b,NoVariables);
     SetLength(C,NoVariables);
     SetLength(High_Factor,NoVariables);
    // calculate proportion of variance accounted for by each factor
    //before rotation
    for j := 1 to n2 do
    begin
         A[j-1] := 0.0;
         for i := 1 to n1 do  A[j-1] := A[j-1] + (v[i-1,j-1] * v[i-1,j-1]);
         A[j-1] := A[j-1] / t * 100.0;
    end;
    if (PcntTrBtn.Checked) then
    begin
         OutputFrm.RichEdit.Lines.Add('Proportion of variance in unrotated factors');
         OutputFrm.RichEdit.Lines.Add('');
         for  j := 1 to n2 do
         begin
             outline := format('%3d %6.3f',[j, A[j-1]]);
             OutputFrm.RichEdit.Lines.Add(outline);
         end;
         OutputFrm.RichEdit.Lines.Add('');
    end;
    for i := 1 to n1 do
    begin
         b[i-1] := 0.0;
         High_Factor[i-1] := 0;
    end;
    // Reflect factors 180 degrees if more negative than positive loadings
     for j := 1 to n2 do
     begin
          minuscount := 0;
          for i := 1 to n1 do
          begin
              if ( v[i-1,j-1] < 0) then minuscount := minuscount + 1;
          end;
          if ( minuscount > (n1 / 2)) then
          begin
             for i := 1 to n1 do  v[i-1,j-1] := v[i-1,j-1] * -1.0;
          end;
     end;

     // normalize rows of v
     for i := 1 to n1 do
     begin
         for j := 1 to n2 do
         begin
             b[i-1] := b[i-1] + (v[i-1,j-1] * v[i-1,j-1]);
         end;
         b[i-1] := sqrt(b[i-1]);
         for j := 1 to n2 do v[i-1,j-1] := v[i-1,j-1] / b[i-1];
     end;

nextone:
     k := 0;
     for M := 1 to n2 do
     begin
         for N := M to n2 do
         begin
              if ( M <> N) then // compute angle of rotation
              begin
                   for i := 1 to n1 do
                   begin
                        A[i-1] := (v[i-1,M-1] * v[i-1,M-1]) - (v[i-1,N-1] * v[i-1,N-1]);
                        C[i-1] := 2.0 * v[i-1,M-1] * v[i-1,N-1];
                   end;
                   a1 := 0.0;
                   for i := 1 to n1 do a1 := a1 + A[i-1];
                   b1 := 0.0;
                   for i := 1 to n1 do b1 := b1 + C[i-1];
                   c1 := 0.0;
                   for i :=  1 to n1 do c1 := c1 + (A[i-1] * A[i-1]);
                   c2 := 0.0;
                   for i := 1 to n1 do c2 := c2 + (C[i-1] * C[i-1]);
                   c3 := c1 - c2;
                   d1 := 0.0;
                   for i := 1 to n1 do d1 := d1 + A[i-1] * C[i-1];
                   d1 := 2 * d1;
                   x1 := d1 - 2.0 * a1 * b1 / t;
                   x2 := c3 - ((a1 * a1) - (b1 * b1)) / t;
                   Y := ArcTan(x1 / x2);
                   if ( x2 < 0) then
                   begin
                        if ( x1 >= 0.0) then Y := Y + 2.0 * pi;
                        Y := Y - pi;
                   end;
                   Y := Y / 4.0;
                   //if (fabs(Y) >= 0.0175) // rotate pair of axes
                   if ( abs(Y) >= 0.000001) then
                   begin
                        c4 := cos(Y);
                        s1 := sin(Y);
                        k := 1;
                        for i := 1 to n1 do
                        begin
                             Q := v[i-1,M-1] * c4 + v[i-1,N-1] * s1;
                             v[i-1,N-1] := v[i-1,N-1] * c4 - v[i-1,M-1] * s1;
                             v[i-1,M-1] := Q;
                        end;
                   end; // if y
              end;  // if m <> n
         end; // next n
    end;  // next m
    if ( k > 0) then goto nextone;
    // denormalize rows of v
    for j := 1 to n2 do
    begin
         for i := 1 to n1 do v[i-1,j-1] := v[i-1,j-1] * b[i-1];
         A[j-1] := 0.0;
         for i := 1 to n1 do A[j-1] := A[j-1] + (v[i-1,j-1] * v[i-1,j-1]);
         A[j-1] := A[j-1] / t * 100.0;
    end;
    for i := 1 to n1 do b[i-1] := (b[i-1] * b[i-1]) * 100.0;
    if (ComUnBtn.Checked) then
    begin
         OutputFrm.RichEdit.Lines.Add('');
         OutputFrm.RichEdit.Lines.Add('Communality Estimates as percentages:');
         for i := 1 to n1 do
         begin
             outline := format('%3d %6.3f',[i,b[i-1]]);
             OutputFrm.RichEdit.Lines.Add(outline);
         end;
         OutputFrm.RichEdit.Lines.Add('');
    end;
    if (SortBtn.Checked)then
        SORT_LOADINGS(v, n1, n2, High_Factor, A, b, RowLabels, order);
    // Reflect factors 180 degrees if more negative than positive loadings
    for j := 1 to n2 do
    begin
         minuscount := 0;
         for i := 1 to n1 do
         begin
              if ( v[i-1,j-1] < 0) then  minuscount := minuscount + 1;
         end;
         if ( minuscount > (n1 / 2)) then
         begin
            for i := 1 to n1 do v[i-1,j-1] := v[i-1,j-1] * -1.0;
         end;
    end;
    // recalculate proportion of variance accounted for by each factor
    for j := 1 to n2 do
    begin
         A[j-1] := 0.0;
         for i := 1 to n1 do A[j-1] := A[j-1] + (v[i-1,j-1] * v[i-1,j-1]);
         A[j-1] := A[j-1] / t * 100.0;
    end;
    // print results
    Title := 'Varimax Rotated Loadings';
    MAT_PRINT(v,n1,n2,Title,RowLabels,ColLabels,NoCases);
    TotalPercent := 0.0;
    OutputFrm.RichEdit.Lines.Add('Percent of Variation in Rotated Factors');
    for j := 1 to n2 do
    begin
        outline := format('Factor %3d %6.3f', [j,A[j-1]]);
        OutputFrm.RichEdit.Lines.Add(outline);
        TotalPercent := TotalPercent + A[j-1];
    end;
    OutputFrm.RichEdit.Lines.Add('');
    outline := format('Total Percent of Variance in Factors : %6.3f',[TotalPercent]);
    OutputFrm.RichEdit.Lines.Add(outline);
    OutputFrm.RichEdit.Lines.Add('Communalities as Percentages');
    for i := 1 to n1 do
    begin
        outline := format('%3d for %15s %6.3f',[i, RowLabels[i-1], b[i-1]]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;
    OutputFrm.RichEdit.Lines.Add('');
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear;

    // clean up heap
    High_Factor := nil;
    C := nil;
    b := nil;
    A := nil;
end;

procedure TFactorFrm.PROCRUST(var b: DblDyneMat; nv, nb: integer;
  var RowLabels: StrDyneVec; var ColLabels: StrDyneVec);
label cleanup;
var
   i, j, k, na, nf, nd, nv2: integer;
   ee, p, sum : double;
   A, C, d, v, trans : DblDyneMat;
   e, f, g, means, stddevs : DblDyneVec;
   outline : string;
   Title : string;
   ColALabels : StrDyneVec ;
   filename : string;
   errorcode : boolean = false;
   count: Integer = 0;
begin
     // nv is the no. of variables, nb the number of factors in the loadings
     // matrix.
     // na is the number of factors in target matrix
     // nf is the no. of roots and vectors extracted from routine sevs
     // b is the obtained factor matrix
     // A is the target factor matrix
     // ColLabels is the set of labels for the obtained factors
     // ColALabels is the set of labels for the target factor matrix
     Title := 'Source Factor Loadings';
     MAT_PRINT(b,nv,nb,title,RowLabels,ColLabels,NoCases);
     nd := nv;
     SetLength(A,NoVariables,NoVariables);
     SetLength(C,NoVariables,NoVariables);
     SetLength(d,NoVariables,NoVariables);
     SetLength(v,NoVariables,NoVariables);
     SetLength(trans,NoVariables,NoVariables);
     SetLength(e,NoVariables);
     SetLength(f,NoVariables);
     SetLength(g,NoVariables);
     SetLength(means,NoVariables);
     SetLength(stddevs,NoVariables);
     SetLength(ColALabels,NoVariables);

     // read target matrix into A
     OpenDialog1.Filter := 'Matrix File (*.MAT)|*.MAT|Any File (*.*)|*.*';
     OpenDialog1.FilterIndex := 1;
     OpenDialog1.Title := 'Target Matrix';
     OpenDialog1.DefaultExt := 'MAT';
     OpenDialog1.Execute;
     filename := OpenDialog1.FileName;
     MATREAD(A,nv2,na,means,stddevs,count,RowLabels,ColALabels,filename);
     Title := 'Target Factor Loadings';
     MAT_PRINT(A,nv2,na,Title,RowLabels,ColALabels,count);
     if nv2 <> nv then
     begin
          ShowMessage('ERROR! No. of variables do not match.');
          goto cleanup;
     end;

    // normalize matrix A by rows.
    for i := 1 to nv do
    begin
        sum := 0.0;
        for j := 1 to na do sum := sum  + (A[i-1,j-1] * A[i-1,j-1]);
        p := 1.0 / sqrt(sum);
        for j := 1 to na do A[i-1,j-1] := A[i-1,j-1] * p;
    end;
    for i := 1 to nv do // normalize matrix b by rows. Save lengths in g.
    begin
        sum := 0.0;
        for j := 1 to nb do sum  := sum + (b[i-1,j-1] * b[i-1,j-1]);
        g[i-1] := sqrt(sum);
        for j := 1 to nb do b[i-1,j-1] := b[i-1,j-1] / g[i-1];
    end;
    // compute cosines between factor axes and print results
    // get A transpose x B into C
    MATTRN(trans,A,nv,na);
    MatAxB(C,trans,b,na,nv,nv,nb,errorcode);
    // get D := C x C transpose
    MATTRN(trans,C,na,nb);
    MatAxB(d,C,trans,na,nb,nb,na,errorcode);
    // get roots and vectors of D.
    nf := SEVS(na, na, 0.0, d, v, e, f, nd); //nf is new no. of factors returned in na
    nb := nf;
    // get d := C transpose x V end;
    MATTRN(trans,C,na,nb);
    MatAxB(d,trans,v,nb,na,na,nb,errorcode);
    for j := 1 to nb do
    begin
        ee := Power(e[j-1],-1.5);
        for i := 1 to nb do d[i-1,j-1] := d[i-1,j-1] * ee;
    end;
    // get D x V' end;
    MATTRN(trans,v,na,nb);
    MatAxB(C,d,trans,nb,nb,nb,na,errorcode);
    OutputFrm.RichEdit.Lines.Add('Factor Pattern Comparison:');
    Title := 'Cosines Among Factor Axis';
    MAT_PRINT(C,na,nb,Title,ColALabels,ColLabels,NoCases);
    // get B x C
    for  i := 1 to nv do
    begin
        for j := 1 to na do
        begin
            d[i-1,j-1] := 0.0;
            for k := 1 to nb do d[i-1,j-1] := d[i-1,j-1] + (b[i-1,k-1] * C[j-1,k-1]);
        end;
    end;
    for i := 1 to nv do
        for j := 1 to na do
            v[i-1,j-1] := d[i-1,j-1] * g[i-1];
    Title := 'Factors Rotated to Conguence With Target';
    MAT_PRINT(v,nv,na,Title,RowLabels,ColALabels,NoCases);
    for i := 1 to nv do
    begin
        sum := 0.0; // Get column products of the two matrices
        for j := 1 to na do sum := sum  + (A[i-1,j-1] * d[i-1,j-1]);
        g[i-1] := sum;
    end;
    OutputFrm.RichEdit.Lines.Add('Cosines (Correlations) Between Corresponding Variables');
    OutputFrm.RichEdit.Lines.Add('');
    for i := 1 to nv do
    begin
        outline := format('%-10s %8.6f',[RowLabels[i-1],g[i-1]]);
        OutputFrm.RichEdit.Lines.Add(outline);
    end;
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;

     // cleanup
cleanup:
     ColALabels := nil;
     stddevs := nil;
     means := nil;
     g := nil;
     f := nil;
     e := nil;
     trans := nil;
     v := nil;
     d := nil;
     C := nil;
     A := nil;
end;

procedure TFactorFrm.LSFactScores(var F: DblDyneMat; NoVars, NoFacts,
  NCases: integer; var ColNoSelected: IntDyneVec; var RowLabels: StrDyneVec);
var
   R, Rinv, Beta : DblDyneMat;
   Means, Variances, StdDevs : DblDyneVec;
   Score, Sigma, x, z : double;
   i, j, k, m, col, colno, oldnovars : integer;
   ColLabels : StrDyneVec;
   outline : string;
   Title : string;
   errcode : boolean = false;
   //errorcode: Boolean = false;

begin
     SetLength(R,NoVariables+1,NoVariables+1);
     SetLength(Rinv,NoVariables+1,NoVariables+1);
     SetLength(Beta,NoVariables,NoVariables);
     SetLength(Means,NoVariables);
     SetLength(Variances,NoVariables);
     SetLength(StdDevs,NoVariables);
     SetLength(ColLabels,NoVariables);

     // setup labels and print routine
     for i := 1 to NoFacts do
     begin
         outline := format('Factor %d',[i]);
         ColLabels[i-1] := outline;
     end;
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('SUBJECT FACTOR SCORE RESULTS:');

     // Obtain correlations
//     Correlate(NoVars,NoCases,ColNoSelected,Means,Variances,StdDevs,R,3,errorcode,NCases);
     Correlations(NoVars,ColNoSelected,R,Means,Variances,StdDevs,errcode,NCases);
     for i := 1 to NoVars do
         for j := 1 to NoVars do
             Rinv[i-1,j-1] := R[i-1,j-1];

     // Get inverse of the correlation matrix
     // Note - offset by one for inverse routine
     SVDinverse(Rinv, NoVars);

     // Multiply the inverse matrix times the factor loadings matrix
     MatAxB(Beta,Rinv,F,NoVars,NoVars,NoVars,NoFacts,errcode);
     Title := 'Regression Coefficients';
     MAT_PRINT(Beta,NoVars,NoFacts,Title,RowLabels,ColLabels,NCases);

     // Calculate standard errors of factor scores
     OutputFrm.RichEdit.Lines.Add('');
     OutputFrm.RichEdit.Lines.Add('Standard Error of Factor Scores:');
     for i := 1 to NoFacts do
     begin
         Sigma := 0.0;
         for j := 1 to NoVars do
         begin
             Sigma := Sigma + (Beta[j-1,i-1] * F[j-1,i-1]);
         end;
         Sigma := sqrt(Sigma);
         outline := format('%-10s %6.3f',[ColLabels[i-1],Sigma]);
         OutputFrm.RichEdit.Lines.Add(outline);
     end;
     OutputFrm.RichEdit.Lines.Add('');

     //Calculate subject factor scores and place in the data grid
     // place labels in new grid columns and define
     oldnovars := NoVariables;
     for i := 1 to NoFacts do
     begin
         col := NoVariables + 1;
         outline := format('Fact.%d Scr.',[i]);
//         MakeVar(col,outline);
         DictionaryFrm.NewVar(col);
         DictionaryFrm.DictGrid.Cells[1,col] := outline;
         OS3MainFrm.DataGrid.Cells[col,0] := outline;
//         NoVariables := NoVariables + 1;
     end;
     for i := 1 to NoCases do // subject
     begin
          if (not GoodRecord(i,NoVars,ColNoSelected)) then continue;
          for j := 1 to NoFacts do // variables
          begin
               Score := 0.0;
               for k := 1 to NoVars do
               begin
                    m := ColNoSelected[k-1];
                    x := StrToFloat(Trim(OS3MainFrm.DataGrid.Cells[m,i]));
                    z := (x - Means[k-1]) / StdDevs[k-1];
                    Score := Score + (z * Beta[k-1,j-1]);
               end;
             colno := oldnovars + j;
             outline := format('%6.4f',[Score]);
             OS3MainFrm.DataGrid.Cells[colno,i] := outline;
         end;
     end;
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;

     // clean up the heap
     ColLabels := nil;
     StdDevs := nil;
     Variances := nil;
     Means := nil;
     Beta := nil;
     Rinv := nil;
     R := nil;
end;

procedure TFactorFrm.QUARTIMAX(var v: DblDyneMat; n1, n2: integer;
  var RowLabels: StrDyneVec; var ColLabels: StrDyneVec; var order: IntDyneVec);
var
   i, j, M, N, minuscount, NoIters : integer;
   A, b, C : DblDyneVec;
   High_Factor : IntDyneVec;
   c4, s1, Q, NewQ, TotalPercent, t : double;
   theta, tan4theta, ssqrp, ssqrj, prodjp, numerator, denominator : double;
   outline : string;
   done : boolean;
   Title : string;
begin
     SetLength(A,NoVariables);
     SetLength(b,NoVariables);
     SetLength(C,NoVariables);
     SetLength(High_Factor,NoVariables);
     NoIters := 0;

    // calculate proportion of variance accounted for by each factor
    //before rotation
    t := n1;
    for j := 1 to n2 do
    begin
         A[j-1] := 0.0;
         for i := 1 to n1 do A[j-1] := A[j-1] + (v[i-1,j-1] * v[i-1,j-1]);
         A[j-1] := A[j-1] / t * 100.0;
    end;
    if PcntTrBtn.Checked then
    begin
         OutputFrm.RichEdit.Lines.Add('Proportion of variance in unrotated factors');
         OutputFrm.RichEdit.Lines.Add('');
         for j := 1 to n2 do
         begin
             outline := format('%3d %6.3f',[j, A[j-1]]);
             OutputFrm.RichEdit.Lines.Add(outline);
         end;
         OutputFrm.RichEdit.Lines.Add('');
    end;
    for i := 0 to n1-1 do
    begin
         b[i] := 0.0;
         High_Factor[i] := 0;
    end;

    // Reflect factors 180 degrees if more negative than positive loadings
     for j := 0 to n2-1 do
     begin
          minuscount := 0;
          for i := 0 to n1-1 do
          begin
              if  v[i,j] < 0 then  minuscount := minuscount + 1;
          end;
          if minuscount > (n1 / 2) then
          begin
             for i := 0 to n1-1 do v[i,j] := v[i,j] * -1.0;
          end;
     end;

     t := n1;
     // normalize rows of v
     for i := 0 to n1-1 do
     begin
         for j := 0 to n2-1 do
         begin
             b[i] := b[i] + (v[i,j] * v[i,j]);
         end;
         b[i] := sqrt(b[i]);
     end;

     done := false;
     Q := 0.0;
     for i := 1 to n1 do
         for j := 1 to n2 do
             Q := Q + Power(v[i-1,j-1],4.0);
     while (not done) do
     begin
         for M := 1 to n2-1 do
         begin
             for N := M + 1 to n2 do
             begin
                 // compute angle of rotation for this pair of factors
                 numerator := 0.0;
                 denominator := 0.0;
                 for i := 1 to n1 do
                 begin
                     ssqrp := v[i-1,M-1] * v[i-1,M-1];
                     ssqrj := v[i-1,N-1] * v[i-1,N-1];
                     prodjp := 2.0 * v[i-1,M-1] * v[i-1,N-1];
                     numerator := numerator + prodjp * (ssqrp - ssqrj);
                     denominator := denominator + (Power(ssqrp - ssqrj,2.0) - Power(prodjp,2));
                 end;
                 tan4theta := (2.0 * numerator) / denominator;
                 theta := ArcTan(tan4theta) / 4.0;
                 c4 := cos(theta);
                 s1 := sin(theta);
                 // transform factor loadings
                 for i := 1 to n1 do
                begin
                    v[i-1,M-1] := v[i-1,M-1] * c4 + v[i-1,N-1] * s1;
                    v[i-1,N-1] := v[i-1,N-1] * c4 - v[i-1,M-1] * s1;
                end;
             end; // next n
         end;  // next m
         NewQ := 0.0;
         for i := 1 to n1 do
             for j := 1 to n2 do
                 NewQ := NewQ + Power(v[i-1,j-1],4.0);
         if (abs(Q - NewQ) < 0.00001) then done := true;
         if (n2 < 3) then done := true;
         if (not done) then
         begin
            NoIters := NoIters + 1;
            if (NoIters > 25) then
            begin
               outline := 'Quartimax failed to converge in 25 iterations.';
               OutputFrm.RichEdit.Lines.Add(outline);
               done := true;
            end;
            Q := NewQ;
         end;
     end; // while not done
{
    // denormalize rows of v
    for ( j := 0; j < n2; j++)
    begin
         for ( i := 0; i < n1; i++) v[i,j] *= b[i];
         A[j] := 0.0;
         for ( i := 0; i < n1; i++) A[j] += (v[i,j] * v[i,j]);
         A[j] := A[j] / t * 100.0;
    end;
}
    for i :=  1 to n1 do b[i-1] := (b[i-1] * b[i-1]) * 100.0;
    if (SortBtn.Checked) then
        SORT_LOADINGS(v, n1, n2, High_Factor, A, b, RowLabels, order);
    // Reflect factors 180 degrees if more negative than positive loadings
    for j := 1 to n2 do
    begin
         minuscount := 0;
         for i := 1 to n1 do
         begin
              if ( v[i-1,j-1] < 0) then minuscount := minuscount  + 1;
         end;
         if ( minuscount > (n1 / 2)) then
         begin
            for i := 1 to n1 do v[i-1,j-1] := v[i-1,j-1] * -1.0;
         end;
    end;
    // recalculate proportion of variance accounted for by each factor
    for j := 0 to n2-1 do
    begin
         A[j] := 0.0;
         for i := 0 to n1-1 do A[j] := A[j] + (v[i,j] * v[i,j]);
         A[j] := A[j] / t * 100.0;
    end;
    // print results
    TotalPercent := 0.0;
    Title := 'Quartimax Rotated Loadings';
    MAT_PRINT(v,n1,n2,Title,RowLabels,ColLabels,NoCases);
    OutputFrm.RichEdit.Lines.Add('Percent of Variation in Rotated Factors');
    for j := 0 to n2-1 do
    begin
        outline := format('Factor %3d %6.3f',[j+1,A[j]]);
        OutputFrm.RichEdit.Lines.Add(outline);
        TotalPercent := TotalPercent + A[j];
    end;
    if (ComUnBtn.Checked) then
    begin
       OutputFrm.RichEdit.Lines.Add('');
       outline := format('Total Percent of Variance in Factors : %6.3f',[TotalPercent]);
       OutputFrm.RichEdit.Lines.Add(outline);
       OutputFrm.RichEdit.Lines.Add('Communalities as Percentages');
       for i := 1 to n1 do
       begin
           outline := format('%3d for %s %6.3f',[i, RowLabels[i-1], b[i-1]]);
           OutputFrm.RichEdit.Lines.Add(outline);
       end;
       OutputFrm.RichEdit.Lines.Add('');
    end;
    OutputFrm.ShowModal;
    OutputFrm.RichEdit.Clear;

    // clean up heap
     High_Factor := nil;
     C := nil;
     b := nil;
     A := nil;
end;

procedure TFactorFrm.ManualRotate(var v: DblDyneMat; n1, n2: integer;
  var RowLabels: StrDyneVec; var ColLabels: StrDyneVec; var order: IntDyneVec;
  Sender: TObject);
var
   cols, rows : integer;
   outline : string;
   Title : string;
   i, j : integer;
begin
// Passed: Loadings, k, Nroots, RowLabels, ColLabels, ColNoSelected,self
     SetLength(RotateFrm.Loadings,NoVariables,NoVariables);
     RotateFrm.Loadings := v;
     RotateFrm.NoVars := n1;
     RotateFrm.NoRoots := n2;
     RotateFrm.RowLabels := RowLabels;
     RotateFrm.ColLabels := ColLabels;
     RotateFrm.Order := order;
     RotateFrm.ShowModal;

     for i := 1 to n1 do
         for j := 1 to n2 do v[i-1,j-1] := RotateFrm.Loadings[i-1,j-1];
     RotateFrm.Loadings := nil;
     cols := n2; // no. of roots
     rows := n1; // no. of variables
     outline := 'Rotated Factor Loadings';
     OutputFrm.RichEdit.Lines.Add(outline);
     Title := 'FACTORS';
     MAT_PRINT(v,rows,cols,Title,RowLabels,ColLabels,NoCases);
     OutputFrm.ShowModal;
     OutputFrm.RichEdit.Clear;
end;

initialization
  {$I factorunit.lrs}

end.

