unit CalculatorUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Math,
  FunctionsLib, Globals;

type

  { TCalculatorForm }

  TCalculatorForm = class(TForm)
    ReturnBtn: TButton;
    NEdit: TEdit;
    Label1: TLabel;
    sevenbtn: TButton;
    dividebtn: TButton;
    multbtn: TButton;
    subtractbtn: TButton;
    Addbtn: TButton;
    ZeroBtn: TButton;
    ChangeSignBtn: TButton;
    PeriodBtn: TButton;
    MemInBtn: TButton;
    MemOutBtn: TButton;
    MemPlusBtn: TButton;
    eightbtn: TButton;
    EqualBtn: TButton;
    sinbtn: TButton;
    cosbtn: TButton;
    tanbtn: TButton;
    Combobtn: TButton;
    ClearEntryBtn: TButton;
    MeanBtn: TButton;
    VarBtn: TButton;
    StdDevBtn: TButton;
    natlogbtn: TButton;
    ninebtn: TButton;
    log10btn: TButton;
    sqrbtn: TButton;
    sqrtbtn: TButton;
    ytopowerxbtn: TButton;
    etoxbtn: TButton;
    tentoxbtn: TButton;
    expbtn: TButton;
    absbtn: TButton;
    PiBtn: TButton;
    nPrbtn: TButton;
    fourbtn: TButton;
    nfactorialbtn: TButton;
    fivebtn: TButton;
    sixbtn: TButton;
    onebtn: TButton;
    twobtn: TButton;
    threebtn: TButton;
    XEdit: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    procedure absbtnClick(Sender: TObject);
    procedure AddbtnClick(Sender: TObject);
    procedure ChangeSignBtnClick(Sender: TObject);
    procedure etoxbtnClick(Sender: TObject);
    procedure PiBtnClick(Sender: TObject);
    procedure VarBtnClick(Sender: TObject);
    procedure MeanBtnClick(Sender: TObject);
    procedure StdDevBtnClick(Sender: TObject);
    procedure ClearEntryBtnClick(Sender: TObject);
    procedure CombobtnClick(Sender: TObject);
    procedure cosbtnClick(Sender: TObject);
    procedure dividebtnClick(Sender: TObject);
    procedure eightbtnClick(Sender: TObject);
    procedure EqualBtnClick(Sender: TObject);
    procedure expbtnClick(Sender: TObject);
    procedure fivebtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure fourbtnClick(Sender: TObject);
    procedure log10btnClick(Sender: TObject);
    procedure MemInBtnClick(Sender: TObject);
    procedure MemOutBtnClick(Sender: TObject);
    procedure MemPlusBtnClick(Sender: TObject);
    procedure multbtnClick(Sender: TObject);
    procedure natlogbtnClick(Sender: TObject);
    procedure nfactorialbtnClick(Sender: TObject);
    procedure ninebtnClick(Sender: TObject);
    procedure nPrbtnClick(Sender: TObject);
    procedure onebtnClick(Sender: TObject);
    procedure PeriodBtnClick(Sender: TObject);
    procedure ReturnBtnClick(Sender: TObject);
    procedure sevenbtnClick(Sender: TObject);
    procedure sinbtnClick(Sender: TObject);
    procedure sixbtnClick(Sender: TObject);
    procedure sqrbtnClick(Sender: TObject);
    procedure sqrtbtnClick(Sender: TObject);
    procedure subtractbtnClick(Sender: TObject);
    procedure tanbtnClick(Sender: TObject);
    procedure tentoxbtnClick(Sender: TObject);
    procedure threebtnClick(Sender: TObject);
    procedure twobtnClick(Sender: TObject);
    procedure XEditKeyPress(Sender: TObject; var Key: char);
    procedure ytopowerxbtnClick(Sender: TObject);
    procedure ZeroBtnClick(Sender: TObject);
  private
    { private declarations }
    Xmemory : double; // value in the memory
    X : double; // value in register
    TempX : double; // temporary storage of last entry
    keyentered : double;  // numeric key press value
    operation : integer; // operation to be performed upon press of equal sign
    NoStack : integer; // no. in memory stack
    stack : DblDyneVec;
    Xint, Xint2 : integer;
  public
    { public declarations }
  end; 

var
  CalculatorForm: TCalculatorForm;

implementation

{ TCalculatorForm }

procedure TCalculatorForm.FormShow(Sender: TObject);
begin
  XEdit.Text := '';
  Xmemory := 0.0;
  X := 0.0;
  keyentered := 0.0;
  NoStack := 0;
  SetLength(stack,1000);
  NEdit.Text := '0';
  XEdit.SetFocus;
end;

procedure TCalculatorForm.fourbtnClick(Sender: TObject);
begin
  XEdit.Text := XEdit.Text + '4';
end;

procedure TCalculatorForm.log10btnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := log10(X);
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.MemInBtnClick(Sender: TObject);
begin
  Xmemory := StrToFloat(XEdit.Text);
  XEdit.Text := '';
end;

procedure TCalculatorForm.MemOutBtnClick(Sender: TObject);
begin
  XEdit.Text := FloatToStr(Xmemory);
end;

procedure TCalculatorForm.MemPlusBtnClick(Sender: TObject);
begin
  stack[NoStack] := stack[NoStack] + StrToFloat(XEdit.Text);
  NoStack := NoStack + 1;
  NEdit.Text := IntToStr(NoStack);
  XEdit.Text := '';
end;

procedure TCalculatorForm.multbtnClick(Sender: TObject);
begin
  TempX := StrToFloat(XEdit.Text);
  XEdit.Text := '';
  operation := 2; // multiply
end;

procedure TCalculatorForm.natlogbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := ln(X);
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.nfactorialbtnClick(Sender: TObject);
var n : integer;
begin
     n := StrToInt(XEdit.Text);
     n := factorial(n);
     XEdit.Text := IntToStr(n);
end;

procedure TCalculatorForm.ninebtnClick(Sender: TObject);
begin
  XEdit.Text := XEdit.Text + '9';
end;

procedure TCalculatorForm.nPrbtnClick(Sender: TObject);
begin
  operation := 7;
  Xint := StrToInt(XEdit.Text);
  XEdit.Text := '';
end;

procedure TCalculatorForm.onebtnClick(Sender: TObject);
begin
XEdit.Text := XEdit.Text + '1';
end;

procedure TCalculatorForm.PeriodBtnClick(Sender: TObject);
begin
  XEdit.Text := XEdit.Text + '.';
end;

procedure TCalculatorForm.ReturnBtnClick(Sender: TObject);
begin
  stack := nil;
end;

procedure TCalculatorForm.sevenbtnClick(Sender: TObject);
begin
  XEdit.Text := XEdit.Text + '7';
end;

procedure TCalculatorForm.sinbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := sin(DegToRad(X));
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.sixbtnClick(Sender: TObject);
begin
  XEdit.Text := XEdit.Text + '6';
end;

procedure TCalculatorForm.sqrbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := X * X;
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.sqrtbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := sqrt(X);
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.subtractbtnClick(Sender: TObject);
begin
  TempX := StrToFloat(XEdit.Text);
  XEdit.Text := '';
  operation := 3;  // subtract
end;

procedure TCalculatorForm.tanbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := tan(DegToRad(X));
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.tentoxbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := power(10,X);
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.threebtnClick(Sender: TObject);
begin
  XEdit.Text := XEdit.Text + '3';
end;

procedure TCalculatorForm.twobtnClick(Sender: TObject);
begin
  XEdit.Text := XEdit.Text + '2';
end;

procedure TCalculatorForm.XEditKeyPress(Sender: TObject; var Key: char);
begin
//  XEdit.Text := XEdit.Text + Key;
end;

procedure TCalculatorForm.ytopowerxbtnClick(Sender: TObject);
begin
  operation := 5;
  tempX := StrToFloat(XEdit.Text);
  XEdit.Text := '';
end;

procedure TCalculatorForm.ZeroBtnClick(Sender: TObject);
begin
XEdit.text := XEdit.Text + '0';
end;

procedure TCalculatorForm.ClearEntryBtnClick(Sender: TObject);
begin
  XEdit.Text := '';
end;

procedure TCalculatorForm.CombobtnClick(Sender: TObject);
begin
  operation := 6;
  tempX := StrToFloat(XEdit.Text);
  XEdit.Text := '';
end;

procedure TCalculatorForm.cosbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := cos(DegToRad(X));
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.AddbtnClick(Sender: TObject);
begin
  TempX := StrToFloat(XEdit.Text);
  XEdit.Text := '';
  operation := 4; // add
end;

procedure TCalculatorForm.ChangeSignBtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := -1.0 * X;
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.etoxbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := power(2.71828182845905,X);
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.PiBtnClick(Sender: TObject);
begin
  X := Pi;
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.absbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := abs(X);
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.VarBtnClick(Sender: TObject);
VAR
  Sum, SSQ : double;
  Ncount : double;
  i, index : integer;
begin
  Ncount := StrToFloat(NEdit.Text);
  index := StrToInt(NEdit.Text);
  Sum := 0.0;
  SSQ := 0.0;
  if Ncount < 1 then
  begin
    ShowMessage('No values in stack memory');
    exit;
  end
  else
  begin
      for i := 0 to index - 1 do
      begin
          Sum := Sum + stack[i];
          SSQ := SSQ + (stack[i] * stack[i]);
      end;
//      Sum := Sum / Ncount;  // mean
//      SSQ := SSQ / Ncount;
      SSQ := SSQ - (Sum * Sum) / Ncount;
      SSQ := SSQ / (Ncount - 1.0);
      XEdit.Text := FloatToStr(SSQ);
  end;
end;

procedure TCalculatorForm.MeanBtnClick(Sender: TObject);
Var
  Sum : double;
  Ncount : double;
  i, index : integer;
begin
  Ncount := StrToFloat(NEdit.Text);
  index := StrToInt(NEdit.Text);
  Sum := 0.0;
  if Ncount < 1 then
  begin
    ShowMessage('No values in stack memory');
    exit;
  end
  else
  begin
       for i := 0 to index - 1 do Sum := Sum + stack[i];
       Sum := Sum / Ncount;
       XEdit.Text := FloatToStr(Sum);
  end;
end;

procedure TCalculatorForm.StdDevBtnClick(Sender: TObject);
VAR
  Sum, SSQ : double;
  Ncount : double;
  i, index : integer;
begin
  Ncount := StrToFloat(NEdit.Text);
  index := StrToInt(NEdit.Text);
  Sum := 0.0;
  SSQ := 0.0;
  if Ncount < 1 then
  begin
    ShowMessage('No values in stack memory');
    exit;
  end
  else
  begin
      for i := 0 to index - 1 do
      begin
          Sum := Sum + stack[i];
          SSQ := SSQ + (stack[i] * stack[i]);
      end;
//      Sum := Sum / Ncount;  // mean
//      SSQ := SSQ / Ncount;
      SSQ := SSQ - (Sum * Sum) / Ncount;
      SSQ := SSQ / (Ncount - 1.0);
      SSQ := sqrt(SSQ);
      XEdit.Text := FloatToStr(SSQ);
  end;
end;

procedure TCalculatorForm.dividebtnClick(Sender: TObject);
begin
  TempX := StrToFloat(XEdit.Text);
  XEdit.Text := '';
  operation := 1; // //divide
end;

procedure TCalculatorForm.eightbtnClick(Sender: TObject);
begin
  XEdit.Text := XEdit.Text + '8';
end;

procedure TCalculatorForm.EqualBtnClick(Sender: TObject);
Var x1, x2 : double;
begin
  case (operation) of
       1 : begin // divide operation
         x1 := tempX;
         x2 := x1 / StrToFloat(XEdit.Text);
         XEdit.Text := FloatToStr(x2);
       end;
       2 : begin // nultiply operation
         x1 := tempX;
         x2 := x1 * StrToFloat(XEdit.Text);
         XEdit.Text := FloatToStr(x2);
       end;
       3 : begin
         x1 := tempX; // subtract operation
         x2 := x1 - StrToFloat(XEdit.Text);
         XEdit.Text := FloatToStr(x2);
       end;
       4 : begin
         x1 := tempX; // Add operation
         x2 := x1 + StrToFloat(XEdit.Text);
         XEdit.Text := FloatToStr(x2);
       end;
       5 : begin  // y to the X power (Y stored in tempx first, x in register)
         X := StrToFloat(XEdit.Text);
         X := power(tempX,X);
         XEdit.Text := FloatToStr(X);
       end;
       6 : begin  // combinations of x things out of N
           X := StrToFloat(XEdit.Text);
           X := combos(X,tempX);
           XEdit.Text := FloatToStr(X);
       end;
       7 : begin // permutations of x things out of N
           Xint2 := StrToInt(XEdit.Text);
           Xint := factorial(Xint) div (factorial(Xint - Xint2));
           XEdit.Text := IntToStr(Xint);
       end;
  end;
end;

procedure TCalculatorForm.expbtnClick(Sender: TObject);
begin
  X := StrToFloat(XEdit.Text);
  X := exp(X);
  XEdit.Text := FloatToStr(X);
end;

procedure TCalculatorForm.fivebtnClick(Sender: TObject);
begin
  XEdit.Text := XEdit.Text + '5';
end;

initialization
  {$I calculatorunit.lrs}

end.

