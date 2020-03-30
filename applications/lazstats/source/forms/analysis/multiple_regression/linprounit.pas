unit LinProUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Grids, ExtCtrls,
  OutputUnit, Globals;

type

  { TLinProFrm }

  TLinProFrm = class(TForm)
    Bevel1: TBevel;
    ExitBtn: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    ResetBtn: TButton;
    CancelBtn: TButton;
    ComputeBtn: TButton;
    LoadBtn: TButton;
    SaveBtn: TButton;
    OpenDialog1: TOpenDialog;
    ResultsEdit: TEdit;
    Label11: TLabel;
    NoEqualEdit: TEdit;
    Label9: TLabel;
    NoMinEdit: TEdit;
    Label7: TLabel;
    NoMaxEdit: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    NoVarsEdit: TEdit;
    FileNameEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ObjectiveGrid: TStringGrid;
    MaxGrid: TStringGrid;
    MinGrid: TStringGrid;
    EqualGrid: TStringGrid;
    MaxConstraintsGrid: TStringGrid;
    MinConstraintsGrid: TStringGrid;
    EqualConstraintsGrid: TStringGrid;
    MinMaxGrp: TRadioGroup;
    SaveDialog1: TSaveDialog;
    procedure CancelBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure NoEqualEditExit(Sender: TObject);
    procedure NoEqualEditKeyPress(Sender: TObject; var Key: char);
    procedure NoMaxEditExit(Sender: TObject);
    procedure NoMaxEditKeyPress(Sender: TObject; var Key: char);
    procedure NoMinEditExit(Sender: TObject);
    procedure NoMinEditKeyPress(Sender: TObject; var Key: char);
    procedure NoVarsEditExit(Sender: TObject);
    procedure NoVarsEditKeyPress(Sender: TObject; var Key: char);
    procedure ResetBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
  private
    { private declarations }
    FAutoSized: Boolean;
    NoVars, NoMax, NoMin, NoEql, MinMax, NoCoefs : integer;
    Objective : DblDyneVec;
    MaxConstraints : DblDyneVec;
    MinConstraints : DblDyneVec;
    EqlConstraints : DblDyneVec;
    Coefficients : DblDyneMat;

    PROCEDURE simplx(VAR a: DblDyneMat; m,n,mp,np,m1,m2,m3: integer;
       VAR icase: integer; VAR izrov: IntDyneVec;
       VAR iposv: IntDyneVec);
    PROCEDURE simp1(VAR a: DblDyneMat; mp,np,mm: integer;
      ll: IntDyneVec; nll,iabf: integer;
      VAR kp: integer; VAR bmax: double);
    PROCEDURE simp2(VAR a: DblDyneMat; m,n,mp,np: integer;
      l2: IntDyneVec; nl2: integer; VAR ip: integer;
      kp: integer; VAR q1: double);
    PROCEDURE simp3(VAR a: DblDyneMat; mp,np,i1,k1,ip,kp: integer);
    procedure LoadArrayData(Sender: TObject);

  public
    { public declarations }
  end; 

var
  LinProFrm: TLinProFrm;

implementation

uses
  Math;

{ TLinProFrm }

procedure TLinProFrm.ResetBtnClick(Sender: TObject);
begin
     NoVarsEdit.Text := '0';
     NoMaxEdit.Text := '';
     NoMinEdit.Text := '';
     NoEqualEdit.Text := '';
     MinMaxGrp.ItemIndex := 0;
     FileNameEdit.Text := '';
     MaxConstraintsGrid.RowCount := 1;
     MaxConstraintsGrid.ColCount := 1;
     MaxConstraintsGrid.Cells[0,0] := '';
     MinConstraintsGrid.RowCount := 1;
     MinConstraintsGrid.ColCount := 1;
     MinConstraintsGrid.Cells[0,0] := '';
     EqualConstraintsGrid.RowCount := 1;
     EqualConstraintsGrid.ColCount := 1;
     EqualConstraintsGrid.Cells[0,0] := '';
     ObjectiveGrid.RowCount := 1;
     ObjectiveGrid.ColCount := 1;
     ObjectiveGrid.Cells[0,0] := '';
     MaxGrid.RowCount := 1;
     MaxGrid.ColCount := 1;
     MaxGrid.Cells[0,0] := '';
     MinGrid.RowCount := 1;
     MinGrid.ColCount := 1;
     MinGrid.Cells[0,0] := '';
     EqualGrid.RowCount := 1;
     EqualGrid.ColCount := 1;
     EqualGrid.Cells[0,0] := '';
     ResultsEdit.Text := '';
end;

procedure TLinProFrm.SaveBtnClick(Sender: TObject);
var
   F : TextFile;
   i, j : integer;
   FName : string;
begin
     LoadArrayData(Self);
     SaveDialog1.DefaultExt := 'LPR';
     SaveDialog1.Filter := 'Linear Programming File (*.LPR)|*.LPR|All Files (*.*)|*.*';
     SaveDialog1.FilterIndex := 1;
     if SaveDialog1.Execute then
     begin
        FName := SaveDialog1.FileName;
        AssignFile(F,FName);
        Rewrite(F);
        writeln(F,NoVars);
        writeln(F,NoMax);
        writeln(F,NoMin);
        writeln(F,NoEql);
        writeln(F,MinMax);
        NoCoefs := NoMax + NoMin + NoEql;
        for i := 1 to NoVars do writeln(F,Objective[i]);
        for i := 1 to NoMax do writeln(F,MaxConstraints[i]);
        for i := 1 to NoMin do writeln(F,MinConstraints[i]);
        for i := 1 to NoEql do writeln(F,EqlConstraints[i]);
        for i := 1 to NoCoefs do
            for j := 1 to NoVars do writeln(F,Coefficients[i,j]);
        CloseFile(F);
     end;
end;

procedure TLinProFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  if FAutoSized then
    exit;

  w := MaxValue([LoadBtn.Width, SaveBtn.Width, ResetBtn.Width, CancelBtn.Width, ComputeBtn.Width, ExitBtn.Width]);
  LoadBtn.Constraints.MinWidth := w;
  SaveBtn.Constraints.MinWidth := w;
  ResetBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ComputeBtn.Constraints.MinWidth := w;
  ExitBtn.Constraints.MinWidth := w;

  FAutoSized := true;
end;

procedure TLinProFrm.FormCreate(Sender: TObject);
begin
  if OutputFrm = nil then Application.CreateForm(TOutputFrm, OutputFrm);
end;

procedure TLinProFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(Self);
end;

procedure TLinProFrm.LoadBtnClick(Sender: TObject);
var
   i, j : integer;
   FName : string;
   F : TextFile;
begin
     // load values
     OpenDialog1.DefaultExt := 'LPR';
     OpenDialog1.Filter := 'Linear Programming File (*.LPR)|*.LPR|All Files (*.*)|*.*';
     OpenDialog1.FilterIndex := 1;
     if OpenDialog1.Execute then
     begin
        FName := OpenDialog1.FileName;
        AssignFile(F,FName);
        FileMode := 0;  {Set file access to read only }
        Reset(F);
        readln(F,NoVars);
        readln(F,NoMax);
        readln(F,NoMin);
        readln(F,NoEql);
        readln(F,MinMax);
        NoCoefs := NoMax + NoMin + NoEql;

        // allocate space
        SetLength(Objective,NoVars + 1);
        SetLength(MaxConstraints,NoMax + 1);
        SetLength(MinConstraints,NoMin + 1);
        SetLength(EqlConstraints,NoEql+1);
        SetLength(Coefficients,NoCoefs+1,NoVars+1);

        for i := 1 to NoVars do readln(F,Objective[i]);
        for i := 1 to NoMax do readln(F,MaxConstraints[i]);
        for i := 1 to NoMin do readln(F,MinConstraints[i]);
        for i := 1 to NoEql do readln(F,EqlConstraints[i]);
        for i := 1 to NoCoefs do
            for j := 1 to NoVars do readln(F,Coefficients[i,j]);
        CloseFile(F);
     end;
     //     GetFileData(FName);
     FileNameEdit.Text := FName;
     NoVarsEdit.Text := IntToStr(NoVars);
     NoMaxEdit.Text := IntToStr(NoMax);
     NoMinEdit.Text := IntToStr(NoMin);
     NoEqualEdit.Text := IntToStr(NoEql);
     MinMaxGrp.ItemIndex := MinMax;
     MaxConstraintsGrid.RowCount := NoMax;
     MinConstraintsGrid.RowCount := NoMin;
     EqualConstraintsGrid.RowCount := NoEql;
     ObjectiveGrid.ColCount := NoVars;
     MaxGrid.RowCount := NoMax;
     MaxGrid.ColCount := NoVars;
     MinGrid.RowCount := NoMin;
     MinGrid.ColCount := NoVars;
     EqualGrid.RowCount := NoEql;
     EqualGrid.ColCount := NoVars;

     // Place objectives in grid
     for i := 1 to NoVars do
         ObjectiveGrid.Cells[i-1,0] := FloatToStr(Objective[i]);

     // Place Maximum constraints in grid
     for i := 1 to NoMax do
     begin
         MaxConstraintsGrid.Cells[0,i-1] := FloatToStr(MaxConstraints[i]);
         for j := 1 to NoVars do MaxGrid.Cells[j-1,i-1] := FloatToStr(Coefficients[i,j]);
     end;

     // Place Minimum constraints in grid
     for i := 1 to NoMin do
     begin
          MinConstraintsGrid.Cells[0,i-1] := FloatToStr(MinConstraints[i]);
          for j := 1 to NoVars do
              MinGrid.Cells[j-1,i-1] := FloatToStr(Coefficients[NoMax+i,j]);
     END;

     // Place Equal constraints in grid
     for i := 1 to NoEql do
     begin
          EqualConstraintsGrid.Cells[0,i-1] := FloatToStr(EqlConstraints[i]);
          for j := 1 to NoVars do
              EqualGrid.Cells[j-1,i-1] := FloatToStr(Coefficients[NoMax+NoMin+i,j]);
     end;
     ComputeBtn.SetFocus;
end;

procedure TLinProFrm.CancelBtnClick(Sender: TObject);
begin
   Coefficients := nil;
   EqlConstraints := nil;
   MinConstraints := nil;
   MaxConstraints := nil;
   Objective := nil;
   Close;
end;

procedure TLinProFrm.ComputeBtnClick(Sender: TObject);
var
   m1, m2, m3, m, mp, n, np, nm1m2 : integer;
   i,icase,j : integer;
   izrov : IntDyneVec;
   iposv : IntDyneVec;
   a : DblDyneMat;
   txt : StrDyneVec;
   outline : string;

begin
   n := NoVars;
   m1 := NoMax;
   m2 := NoMin;
   m3 := NoEql;
   m := m1 + m2 + m3;
   np := n+1;   (* np >= n+1 *)
   mp := m + 2;   (* mp >= m+2 *)
   nm1m2 := n + m1 + m2;   (* nm1m2=n+m1+m2 *)
   SetLength(izrov,n+1);
   SetLength(iposv,m+1);
   SetLength(a,mp+1,np+1);
   SetLength(txt,nm1m2+1);

   // Initialize labels
   for i := 1 to NoVars do txt[i] := 'X' + IntToStr(i);
   for i := NoVars + 1 to nm1m2 do txt[i] := 'Y' + IntToStr(i-NoVars);

   // Fill array data from grid
   LoadArrayData(Self);
   for i := 1 to NoVars do a[1,i+1] := Objective[i];
   a[1,1] := 0.0;
   for i := 1 to NoMax do
   begin
        a[i+1,1] := MaxConstraints[i];
        for j := 1 to NoVars do a[i+1,j+1] := coefficients[i,j];
   end;
   for i := 1 to NoMin do
   begin
        a[i+1+NoMax,1] := MinConstraints[i];
        for j := 1 to NoVars do a[i+1+NoMax,j+1] := Coefficients[i+NoMax,j];
   end;
   for i := 1 to NoEql do
   begin
        a[i+1+NoMax+NoMin,1] := EqlConstraints[i];
        for j := 1 to NoVars do
             a[i+1+NoMax+NoMin,j+1] := coefficients[i+NoMax+NoMin,j];
   end;
   if MinMaxGrp.ItemIndex = 1 then
   begin
        MinMax := 1;
        for i := 1 to NoVars do a[1,i+1] := -1.0 * a[1,i+1];
   end;

   // Do analysis
   simplx(a,m,n,mp,np,m1,m2,m3,icase,izrov,iposv);
   if MinMax = 1 then a[1,1] := -a[1,1];

   // Report results
   OutputFrm.RichEdit.Clear;
   OutputFrm.RichEdit.Lines.Add('Linear Programming Results');
   OutputFrm.RichEdit.Lines.Add('');


   outline := '';
   IF (icase = 1) THEN
   BEGIN
      ResultsEdit.Text := 'Unbounded objective function.';
      OutputFrm.RichEdit.Lines.Add('Unbounded object function.')
   END
   ELSE IF (icase = -1) THEN
   BEGIN
      ResultsEdit.Text := 'No solutions satisfy constraints given.';
      OutputFrm.RichEdit.Lines.Add('No solutions satisfy constraints given')
   END ELSE
   BEGIN
      ResultsEdit.Text := 'Solution found.';
      outline := '           ';
      FOR i := 1 to n DO
      BEGIN
         IF (izrov[i] <= nm1m2) THEN
         BEGIN
            outline := outline + format('%10s',[txt[izrov[i]]]);
         END;
      END;
      OutputFrm.RichEdit.Lines.Add(outline);
      OutputFrm.RichEdit.Lines.Add('');
      outline := '';
      FOR i := 1 to m+1 DO
      BEGIN
         IF (i > 1) THEN
         BEGIN
            outline := outline + format('%3s',[txt[iposv[i-1]]]);
         END
         ELSE BEGIN
             outline := outline + '  z';
         END;
         FOR j := 1 to (n+1) DO
         BEGIN
            IF (j=1) THEN
               outline := outline + format('%10.4f',[a[i,j]]);
            IF (j>1) THEN
            BEGIN
               IF (izrov[j-1] <= nm1m2) THEN
                  outline := outline + format('%10.4f',[a[i,j]]);
            END;
         END;
         OutputFrm.RichEdit.Lines.Add(outline);
         outline := '';
      END;
   END;
   OutputFrm.ShowModal;

//   ShowOutPut(m1, m2, m3, m, n, icase, a, iposv, izrov, Self);

   // cleanup
   txt := nil;
   a := nil;
   iposv := nil;
   izrov := nil;
end;

procedure TLinProFrm.ExitBtnClick(Sender: TObject);
begin
   Coefficients := nil;
   EqlConstraints := nil;
   MinConstraints := nil;
   MaxConstraints := nil;
   Objective := nil;
   Close;
end;

procedure TLinProFrm.NoEqualEditExit(Sender: TObject);
VAR value : integer;
begin
     value := StrToInt(NoEqualEdit.Text);
     if value = 0 then exit;
     EqualConstraintsGrid.RowCount := value;
     EqualGrid.RowCount := value;
     NoEql := value;
     SetLength(EqlConstraints,value + 1);
     NoCoefs := NoMax + NoMin + NoEql;
     SetLength(Coefficients,NoCoefs+1,NoVars+1);
end;

procedure TLinProFrm.NoEqualEditKeyPress(Sender: TObject; var Key: char);
begin
     if ord(Key) = 13 then ObjectiveGrid.SetFocus;
end;

procedure TLinProFrm.NoMaxEditExit(Sender: TObject);
VAR value : integer;
begin
     value := StrToInt(NoMaxEdit.Text);
     if value = 0 then exit;
     MaxConstraintsGrid.RowCount := value;
     MaxGrid.RowCount := value;
     NoMax := value;
     SetLength(MaxConstraints,NoMax + 1);
end;

procedure TLinProFrm.NoMaxEditKeyPress(Sender: TObject; var Key: char);
begin
     if ord(Key) = 13 then NoMinEdit.SetFocus;
end;

procedure TLinProFrm.NoMinEditExit(Sender: TObject);
VAR value : integer;
begin
     value := StrToInt(NoMinEdit.Text);
     if value = 0 then exit;
     MinConstraintsGrid.RowCount := value;
     MinGrid.RowCount := value;
     NoMin := value;
     SetLength(MinConstraints,NoMin + 1);
end;

procedure TLinProFrm.NoMinEditKeyPress(Sender: TObject; var Key: char);
begin
     if ord(Key) = 13 then NoEqualEdit.SetFocus;
end;

procedure TLinProFrm.NoVarsEditExit(Sender: TObject);
var value : integer;
begin
     value := StrToInt(NoVarsEdit.Text);
     if value = 0 then exit;
     ObjectiveGrid.ColCount := value;
     MaxGrid.ColCount := value;
     MinGrid.ColCount := value;
     EqualGrid.ColCount := value;
     NoVars := value;
     SetLength(Objective,NoVars + 1);
end;

procedure TLinProFrm.NoVarsEditKeyPress(Sender: TObject; var Key: char);
begin
     if ord(Key) = 13 then NoMaxEdit.SetFocus;
end;

PROCEDURE TLinProFrm.simplx(VAR a: DblDyneMat; m,n,mp,np,m1,m2,m3: integer;
       VAR icase: integer; VAR izrov: IntDyneVec;
       VAR iposv: IntDyneVec);
LABEL 1,2,10,20,30,99;
CONST eps=1.0e-6;
VAR
   nl2,nl1,m12,kp,kh,k,is1,ir,ip,i: integer;
   q1,bmax: double;
   l1: IntDyneVec;
   l2,l3: IntDyneVec;
BEGIN
   setlength(l1,np+1);
   setlength(l2,mp + 1);
   setlength(l3,mp + 1);
   IF (m <> (m1+m2+m3)) THEN BEGIN
      writeln('pause in routine SIMPLX');
      writeln('bad input constraint counts'); readln
   END;
   nl1 := n;
   FOR k := 1 TO n DO BEGIN
      l1[k] := k;
      izrov[k] := k
   END;
   nl2 := m;
   FOR i := 1 TO m DO BEGIN
      IF (a[i+1,1] < 0.0) THEN BEGIN
         writeln('pause in routine SIMPLX');
         writeln('bad input tableau'); readln
      END;
      l2[i] := i;
      iposv[i] := n+i
   END;
   FOR i := 1 TO m2 DO BEGIN
      l3[i] := 1
   END;
   ir := 0;
   IF ((m2+m3) = 0) THEN GOTO 30;
   ir := 1;
   FOR k := 1 TO n+1 DO BEGIN
      q1 := 0.0;
      FOR i := m1+1 TO m DO BEGIN
         q1 := q1+a[i+1,k]
      END;
      a[m+2,k] := -q1
   END;
10:   simp1(a,mp,np,m+1,l1,nl1,0,kp,bmax);
   IF ((bmax <= eps) AND (a[m+2,1] < -eps)) THEN BEGIN
      icase := -1; GOTO 99 END
   ELSE IF ((bmax <= eps) AND (a[m+2,1] <= eps)) THEN BEGIN
      m12 := m1+m2+1;
      IF (m12 <= m) THEN BEGIN
         FOR ip := m12 TO m DO BEGIN
            IF (iposv[ip] = (ip+n)) THEN BEGIN
               simp1(a,mp,np,ip,l1,nl1,1,kp,bmax);
               IF (bmax > 0.0) THEN GOTO 1
            END
         END
      END;
      ir := 0;
      m12 := m12-1;
      IF ((m1+1) > m12) THEN GOTO 30;
      FOR i := m1+1 TO m12 DO BEGIN
         IF (l3[i-m1] = 1) THEN BEGIN
            FOR k := 1 TO n+1 DO BEGIN
               a[i+1,k] := -a[i+1,k]
            END
         END
      END;
      GOTO 30
   END;
   simp2(a,m,n,mp,np,l2,nl2,ip,kp,q1);
   IF (ip = 0) THEN BEGIN
      icase := -1; GOTO 99
   END;
1:   simp3(a,mp,np,m+1,n,ip,kp);
   IF (iposv[ip] >= (n+m1+m2+1)) THEN BEGIN
      FOR k := 1 TO nl1 DO BEGIN
         IF (l1[k] = kp) THEN GOTO 2
      END;
2:      nl1 := nl1-1;
      FOR is1 := k TO nl1 DO BEGIN
         l1[is1] := l1[is1+1]
      END
   END ELSE BEGIN
      IF (iposv[ip] < (n+m1+1)) THEN GOTO 20;
      kh := iposv[ip]-m1-n;
      IF (l3[kh] = 0) THEN GOTO 20;
      l3[kh] := 0
   END;
   a[m+2,kp+1] := a[m+2,kp+1]+1.0;
   FOR i := 1 TO m+2 DO BEGIN
      a[i,kp+1] := -a[i,kp+1]
   END;
20:   is1 := izrov[kp];
   izrov[kp] := iposv[ip];
   iposv[ip] := is1;
   IF (ir <> 0) THEN GOTO 10;
30:   simp1(a,mp,np,0,l1,nl1,0,kp,bmax);
   IF (bmax <= 0.0) THEN BEGIN
      icase := 0; GOTO 99
   END;
   simp2(a,m,n,mp,np,l2,nl2,ip,kp,q1);
   IF (ip = 0) THEN BEGIN
      icase := 1; GOTO 99
   END;
   simp3(a,mp,np,m,n,ip,kp);
   GOTO 20;
99:
   l1 := nil;
   l2 := nil;
   l3 := nil;
END;


PROCEDURE TLinProFrm.simp1(VAR a: DblDyneMat; mp,np,mm: integer;
      ll: IntDyneVec; nll,iabf: integer;
      VAR kp: integer; VAR bmax: double);
LABEL 99;
VAR
   k: integer;
   test: real;
BEGIN
   kp := ll[1];
   bmax := a[mm+1,kp+1];
   IF (nll < 2) THEN GOTO 99;
   FOR k := 2 TO nll DO BEGIN
      IF (iabf = 0) THEN BEGIN
         test := a[mm+1,ll[k]+1]-bmax
      END ELSE BEGIN
         test := abs(a[mm+1,ll[k]+1])-abs(bmax)
      END;
      IF (test > 0.0) THEN BEGIN
         bmax := a[mm+1,ll[k]+1];
         kp := ll[k]
      END
   END;
99:   END;


PROCEDURE TLinProFrm.simp2(VAR a: DblDyneMat; m,n,mp,np: integer;
      l2: IntDyneVec; nl2: integer; VAR ip: integer;
      kp: integer; VAR q1: double);
LABEL 2,6,99;
VAR
   k,ii,i: integer;
   qp,q0,q: double;
BEGIN
   ip := 0;
   IF (nl2 < 1) THEN GOTO 99;
   FOR i := 1 TO nl2 DO BEGIN
      IF (a[l2[i]+1,kp+1] < 0.0) THEN GOTO 2
   END;
   GOTO 99;
2:   q1 := -a[l2[i]+1,1]/a[l2[i]+1,kp+1];
   ip := l2[i];
   IF ((i+1) > nl2) THEN GOTO 99;
   FOR i := i+1 TO nl2 DO BEGIN
      ii := l2[i];
      IF (a[ii+1,kp+1] < 0.0) THEN BEGIN
         q := -a[ii+1,1]/a[ii+1,kp+1];
         IF (q < q1) THEN BEGIN
            ip := ii;
            q1 := q
         END ELSE IF (q = q1) THEN BEGIN
            FOR k := 1 TO n DO BEGIN
               qp := -a[ip+1,k+1]/a[ip+1,kp+1];
               q0 := -a[ii+1,k+1]/a[ii+1,kp+1];
               IF (q0 <> qp) THEN GOTO 6
            END;
6:          IF (q0 < qp) THEN ip := ii
         END
      END
   END;
99:
end;


PROCEDURE TLinProFrm.simp3(VAR a: DblDyneMat; mp,np,i1,k1,ip,kp: integer);
(* Programs using routine SIMP3 must define the type
TYPE
   glmpbynp = ARRAY [1..mp,1..np] OF real;
in the main routine. *)
VAR
   kk,ii: integer;
   piv: double;
BEGIN
   piv := 1.0/a[ip+1,kp+1];
   IF (i1 >= 0) THEN BEGIN
      FOR ii := 1 TO (i1+1) DO BEGIN
         IF ((ii-1) <> ip) THEN BEGIN
            a[ii,kp+1] := a[ii,kp+1]*piv;
            FOR kk := 1 TO k1+1 DO BEGIN
               IF ((kk-1) <> kp) THEN BEGIN
                  a[ii,kk] := a[ii,kk]
                   -a[ip+1,kk]*a[ii,kp+1]
               END
            END
         END
      END
   END;
   FOR kk := 1 TO k1+1 DO BEGIN
      IF ((kk-1) <> kp) THEN a[ip+1,kk] := -a[ip+1,kk]*piv
   END;
   a[ip+1,kp+1] := piv
END;


procedure TLinProFrm.LoadArrayData(Sender: TObject);
var
   i, j : integer;
begin
   // load objectives
   for i := 1 to NoVars do Objective[i] := StrToFloat(ObjectiveGrid.Cells[i-1,0]);

   // load constraints
   for i := 1 to NoMax do
   begin
        MaxConstraints[i] := StrToFloat(MaxConstraintsGrid.Cells[0,i-1]);
        for j := 1 to NoVars do coefficients[i,j] := StrToFloat(MaxGrid.Cells[j-1,i-1]);
   end;
   for i := 1 to NoMin do
   begin
        MinConstraints[i] := StrToFloat(MinConstraintsGrid.Cells[0,i-1]);
        for j := 1 to NoVars do coefficients[i+NoMax,j] := StrToFloat(MinGrid.Cells[j-1,i-1]);
   end;
   for i := 1 to NoEql do
   begin
        EqlConstraints[i] := StrToFloat(EqualConstraintsGrid.Cells[0,i-1]);
        for j := 1 to NoVars do coefficients[i+NoMax+NoMin,j] := StrToFloat(EqualGrid.Cells[j-1,i-1]);
   end;

   // Set for minimization if requested
   if MinMaxGrp.ItemIndex = 1 then MinMax := 1;
end;


initialization
  {$I linprounit.lrs}

end.

