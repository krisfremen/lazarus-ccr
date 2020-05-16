unit SelectIfUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  MainUnit, Globals, DataProcs, OptionsUnit;

type

  { TSelectIfFrm }

  TSelectIfFrm = class(TForm)
    Bevel1: TBevel;
    LeftParenBtn: TBitBtn;
    FourBtn: TBitBtn;
    FiveBtn: TBitBtn;
    SixBtn: TBitBtn;
    EQBtn: TBitBtn;
    NotBtn: TBitBtn;
    MinusBatn: TBitBtn;
    OneBtn: TBitBtn;
    TwoBtn: TBitBtn;
    ThreeBtn: TBitBtn;
    PlusBtn: TBitBtn;
    LessBtn: TBitBtn;
    ZeroBtn: TBitBtn;
    DotBtn: TBitBtn;
    AndBtn: TBitBtn;
    OrBtn: TBitBtn;
    LNotBtn: TBitBtn;
    InBtn: TBitBtn;
    GreaterBtn: TBitBtn;
    SevenBtn: TBitBtn;
    EightBtn: TBitBtn;
    NineBtn: TBitBtn;
    RightParenBtn: TBitBtn;
    LEBtn: TBitBtn;
    GEBtn: TBitBtn;
    ResetBtn: TButton;
    CancelBtn: TButton;
    OKBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    SelectMemo: TMemo;
    VarList: TListBox;
    procedure AndBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure DotBtnClick(Sender: TObject);
    procedure EightBtnClick(Sender: TObject);
    procedure EQBtnClick(Sender: TObject);
    procedure FiveBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FourBtnClick(Sender: TObject);
    procedure GEBtnClick(Sender: TObject);
    procedure GreaterBtnClick(Sender: TObject);
    procedure InBtnClick(Sender: TObject);
    procedure LEBtnClick(Sender: TObject);
    procedure LeftParenBtnClick(Sender: TObject);
    procedure LessBtnClick(Sender: TObject);
    procedure LNotBtnClick(Sender: TObject);
    procedure MinusBatnClick(Sender: TObject);
    procedure NineBtnClick(Sender: TObject);
    procedure NotBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure OneBtnClick(Sender: TObject);
    procedure OrBtnClick(Sender: TObject);
    procedure PlusBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure RightParenBtnClick(Sender: TObject);
    procedure SevenBtnClick(Sender: TObject);
    procedure SixBtnClick(Sender: TObject);
    procedure ThreeBtnClick(Sender: TObject);
    procedure TwoBtnClick(Sender: TObject);
    procedure ZeroBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    ifstring : string;
    procedure  CheckParens(VAR LeftCnt : integer;
                       VAR RightCnt : integer;
                       VAR Expression : string);

    procedure GetExpression(const Expression: string; var SubExpr: string;
      out LeftParen, RightParen: integer);

    procedure DelSubSt(VAR Expression : string;
                   FromPos, ToPos : integer);

    procedure TrimParens(VAR Expression : string);

    function LeadOp(VAR Expression : string) : integer;

    function OpPosition(VAR Expression : string;
                        VAR chr : string;
                        VAR OpLong : integer) : integer;

    procedure RemoveBlanks(VAR Expression : string);

    procedure GetLeftSt(VAR Expression : string;
                    VAR LeftSt : string;
                    FromPos : integer);

    procedure GetRightSt(VAR Expression : string;
                     VAR RightSt : string;
                     FromPos : integer;
                     OpLong : integer);

    function isnumeric(VAR Expression : string) : integer;

    function GetVarIndex(VAR varstring : string;
                         VAR VarLabels : StrDyneVec;
                         NoVars : integer) : integer;

    procedure BuildIfList(VAR Expression : string;
                      VAR ExprList : StrDyneVec;
                      VAR NoExpr : integer;
                      VAR JoinOps : StrDyneVec);

    procedure parse(VAR Expression : string;
                VAR ExprList : StrDyneVec;
                VAR NoExpr : integer;
                VAR Ops : StrDyneVec;
                VAR LeftValue : StrDyneVec;
                VAR RightValue : StrDyneVec;
                VAR JoinOps : StrDyneVec);

    function TruthValue(caseno, ExpNo : integer;
                    VAR LeftStr : string;
                    VAR RightStr : string;
                    VAR OpCode : string;
                    VAR VarLabels : StrDyneVec;
                    NoVars : integer) : boolean;
  end; 

var
  SelectIfFrm: TSelectIfFrm;

implementation

uses
  Math,
  SelectCasesUnit;

{ TSelectIfFrm }

procedure TSelectIfFrm.ResetBtnClick(Sender: TObject);
VAR i : integer;
begin
     VarList.Clear;
     SelectMemo.Clear;
     ifstring := '(';
     SelectMemo.Lines.Add(ifstring);
     for i := 1 to NoVariables do
         VarList.Items.Add(OS3MainFrm.DataGrid.Cells[i,0]);
end;

procedure TSelectIfFrm.RightParenBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' ) ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.SevenBtnClick(Sender: TObject);
begin
     ifstring := ifstring + '7';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.SixBtnClick(Sender: TObject);
begin
     ifstring := ifstring + '6';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.ThreeBtnClick(Sender: TObject);
begin
     ifstring := ifstring + '3';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.TwoBtnClick(Sender: TObject);
begin
     ifstring := ifstring + '2';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.ZeroBtnClick(Sender: TObject);
begin
     ifstring := ifstring + '0';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([ResetBtn.Width, CancelBtn.Width, OKBtn.Width]);
  CancelBtn.Constraints.MinWidth := w;
  OkBtn.Constraints.MinWidth := w;
end;

procedure TSelectIfFrm.FormCreate(Sender: TObject);
begin
  Assert(OS3MainFrm <> nil);
end;

procedure TSelectIfFrm.FormShow(Sender: TObject);
begin
  ResetBtnClick(self);
  DotBtn.Caption := FractionTypeChars[Options.FractionType];
end;

procedure TSelectIfFrm.FourBtnClick(Sender: TObject);
begin
  ifstring := ifstring + '4';
  SelectMemo.Clear;
  SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.EQBtnClick(Sender: TObject);
begin
  ifstring := ifstring + ' = ';
  SelectMemo.Clear;
  SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.FiveBtnClick(Sender: TObject);
begin
     ifstring := ifstring + '5';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.AndBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' & ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.CancelBtnClick(Sender: TObject);
begin
  ResetBtnClick(self) ;
end;

procedure TSelectIfFrm.DotBtnClick(Sender: TObject);
begin
  ifstring := ifstring + FractionTypeChars[Options.FractionType];
  SelectMemo.Clear;
  SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.EightBtnClick(Sender: TObject);
begin
     ifstring := ifstring + '8';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.GEBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' >= ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.GreaterBtnClick(Sender: TObject);
begin
  ifstring := ifstring + ' > ';
  SelectMemo.Clear;
  SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.InBtnClick(Sender: TObject);
VAR index : integer;
begin
     index := VarList.ItemIndex;
     ifstring := ifstring + ' ' + VarList.Items.Strings[index] + ' ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.LEBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' <= ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.LeftParenBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' ( ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.LessBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' < ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.LNotBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' ! ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.MinusBatnClick(Sender: TObject);
begin
     ifstring := ifstring + ' -';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.NineBtnClick(Sender: TObject);
begin
     ifstring := ifstring + '9';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.NotBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' <> ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.OKBtnClick(Sender: TObject);
begin
  SelectFrm.FilterOutBtn.Checked := true;
end;

procedure TSelectIfFrm.OneBtnClick(Sender: TObject);
begin
     ifstring := ifstring + '1';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.OrBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' | ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.PlusBtnClick(Sender: TObject);
begin
     ifstring := ifstring + ' + ';
     SelectMemo.Clear;
     SelectMemo.Lines.Add(ifstring);
end;

procedure TSelectIfFrm.CheckParens(var LeftCnt: integer; var RightCnt: integer;
  var Expression: string);
VAR i : integer;
begin
     LeftCnt := 0;
     RightCnt := 0;

     for i := 1 to Length(Expression) do
     begin
    	if Expression[i] = '(' then LeftCnt := LeftCnt + 1;
        if Expression[i] = ')' then RightCnt := RightCnt + 1;
     end;
end;


{ Search from left for first right paren.
  Search back for first left paren (corresponding paren.)
  Extract sub string. }
procedure TSelectIfFrm.GetExpression(const Expression: string;
  var SubExpr: string; out LeftParen, RightParen: integer);
var
  i, j : integer;
begin
  RightParen := 0;
  LeftParen := 0;
  for i := 1 to Length(Expression) do
  begin
    if Expression[i] = ')' then
    begin
      RightParen := i;
      break;
    end;
  end;

  for i := RightParen downto 1 do
  begin
    if Expression[i] = '(' then
    begin
      LeftParen := i;
      break;
    end;
  end;

  if RightParen = 0 then  // no parentheses - take whole expression
  begin
    SubExpr := Expression;
    exit;
  end;

  j := 0;
  for i := LeftParen to RightParen do
  begin
    j := j + 1;
    SubExpr := SubExpr + Expression[i];
  end;
  SetLength(SubExpr,j);
end;

procedure TSelectIfFrm.DelSubSt(var Expression: string; FromPos, ToPos: integer
  );
var
   stlength : integer;
   awidth : integer;

begin
//     tempstr := '';
     stlength := Length(Expression);
     if stlength <= (ToPos - FromPos+1) then exit; // whole expression
     awidth := ToPos - FromPos + 1;
     Delete(Expression,FromPos,awidth);
end;

procedure TSelectIfFrm.TrimParens(var Expression: string);
var
   stlength, i : integer;

begin
     stlength := Length(Expression);
     if Expression[stlength] = ')' then // paren at right end of string
          SetLength(Expression,stlength-1);


     stlength := Length(Expression);
     if Expression[1] = '(' then // left paren
     begin
    	  for i := 1 to stlength - 1 do // copy including null char
        	Expression[i] := Expression[i+1];
          SetLength(Expression,stlength-1);
     end;
end;

function TSelectIfFrm.LeadOp(var Expression: string): integer;
VAR chr : char;
begin
     chr := Expression[1];
    if ( (chr = '|') or (chr = '&') or (chr = '!') )then Result := 1
    else Result := 0;
end;

function TSelectIfFrm.OpPosition(var Expression: string; var chr: string;
  var OpLong: integer): integer;
var
   i, pos : integer;
   achar : char;

begin
     pos := -1;
     chr := '';
     for i := 1 to Length(Expression) do
     begin
    	  achar := Expression[i];
          if (achar = '<') or (achar = '>') or (achar = '=') or (achar = '+') or (achar = '-')
                 then
          begin
               pos := i;
               chr := chr + achar;
               // check for second character
               achar := Expression[i+1];
               if (achar = '=') or (achar = '<') or (achar = '>') then
                  chr := chr + achar;
               OpLong := Length(chr);
               break;
          end;
    end;
    Result := pos;
end;

procedure TSelectIfFrm.RemoveBlanks(var Expression: string);
var
   stlength, i : integer;
   tempstr : string;

begin
     tempstr := '';
     stlength := Length(Expression);
     for i := 1 to stlength do
     begin
          if Expression[i] <> ' ' then tempstr := tempstr + Expression[i];
     end;
     Expression := tempstr;
end;

procedure TSelectIfFrm.GetLeftSt(var Expression: string; var LeftSt: string;
  FromPos: integer);
VAR i : integer;
begin
        LeftSt := '';
	for i := 1 to FromPos - 1 do
    	if Expression[i] <> ' ' then LeftSt := LeftSt + Expression[i];
end;

procedure TSelectIfFrm.GetRightSt(var Expression: string; var RightSt: string;
  FromPos: integer; OpLong: integer);
  VAR i : integer;
begin
    RightSt := '';
    for i := FromPos + OpLong to Length(Expression) do
    begin
    	 RightSt := RightSt + Expression[i];
    end;
end;

function TSelectIfFrm.isnumeric(var Expression: string): integer;
var
   valid : boolean;
   i : integer;

begin
     valid := false;
     for i := 1 to Length(Expression) do
     begin
    	  if ( (Expression[i] >= '0') and (Expression[i] <= '9') ) or
        	(Expression[i] = '.') or (Expression[i] = '-') or
            (Expression[i] = '+') or (Expression[i] = ',') then  valid := true
          else begin
              valid := false;
              break;
          end;
    end;
    if valid = true then Result := 1 else Result := 0;
end;

function TSelectIfFrm.GetVarIndex(var varstring: string;
  var VarLabels: StrDyneVec; NoVars: integer): integer;
var
   i, varno : integer;
   tempstr : string;

begin
    // find a match, if any, between varstring and a VarLabel.  Return the
    // sequence number of the matching VarLabel if found, else -1.
    varno := -1;
    for i := 1 to NoVars do
    begin
         tempstr := VarLabels[i-1];
         RemoveBlanks(tempstr);
         if varstring = tempstr then
         begin
              varno := i;
              break;
         end;
    end;
    Result := varno;
end;

procedure TSelectIfFrm.BuildIfList(var Expression: string;
  var ExprList: StrDyneVec; var NoExpr: integer; var JoinOps: StrDyneVec);
var
   stlength, LeftCnt, RightCnt, LeftParen, RightParen, i  : integer;
   SubExpr : string;
   done, found : boolean;
   delpos : integer;

begin
     //This routine parses a compound expression into a list of sub-expressions
     // and joining logical operations
     done := false;
     NoExpr := 0;
     RemoveBlanks(Expression);
     stlength := Length(Expression);
     if stlength = 0 then exit;
     CheckParens(LeftCnt, RightCnt, Expression);
     if LeftCnt <> RightCnt then
     begin
    	  ShowMessage('ERROR! Unmatched parentheses');
          ResetBtnClick(self);
          exit;
     end;
     while not done do
     begin
          SubExpr := '';
          GetExpression(Expression, SubExpr, LeftParen, RightParen);
    	  if LeftParen < RightParen then
          begin
               TrimParens(SubExpr);
               LeftCnt := LeftCnt - 1;
               RightCnt := RightCnt - 1;
          end;
          stlength := Length(SubExpr);
          if stlength = 0 then
          begin
               ShowMessage('Warning! Empty expression found (extraneous parentheses)');
               ResetBtnClick(self);
               exit;
          end;
          NoExpr := NoExpr + 1;
          ExprList[NoExpr-1] := SubExpr;
          if LeftCnt > 0 then // more than one set of parentheses
          begin
               // Look for a logical connection to next subexpression, if any
    	       found := false;
               delpos := RightParen;
               if RightParen > 0 then
	       begin
    	   	     for i := RightParen+1 to Length(Expression) do
	    	     begin
    	    	   	if Expression[i] = '(' then break // start of expression
                        else begin
                             if (Expression[i] = '|') or (Expression[i] = '&') or (Expression[i] = '!') then
                             begin
                                  JoinOps[NoExpr-1] := JoinOps[NoExpr-1] + Expression[i];
    		                  found := true;
                                  delpos := i;
                             end;
                        end; // end if Expession[i] = '('
                     end; // next i
               end; // if RightParen > 0

               if found = false then JoinOps[NoExpr-1] := ' '
               else JoinOps[NoExpr-1] := Trim(JoinOps[NoExpr-1]);
               if RightParen = 1 then //whole expression left
               begin
                    Expression := ''; // make empty
                    done := true;
               end;
               //delete both the substring and the adjacent operator
               if done = false then
               begin
                     if found = true then// join operation was found
                     RightParen := delpos;
                     DelSubSt(Expression, LeftParen, RightParen);
               end;
               if (LeftCnt = 1) then // single expression left
               begin
                     TrimParens(Expression);
                     LeftCnt := LeftCnt - 1;
                     RightCnt := RightCnt - 1;
               end;

               if Length(Expression) = 0 then done := true;
          end // end if LeftCnt > 0
          else done := true;
     end; // end while not done
end;

procedure TSelectIfFrm.parse(var Expression: string; var ExprList: StrDyneVec;
  var NoExpr: integer; var Ops: StrDyneVec; var LeftValue: StrDyneVec;
  var RightValue: StrDyneVec; var JoinOps: StrDyneVec);
var
   OpPos, i, OpLong : integer;
   tempstr: String;
   tempstr2: string = '';
   chr: string = '';

begin
     // An Expression string should contain one or more parenthetical substrings.
     // Each substring should contain an arithmetic or logical operation and have
     // a variable or numeric value to the left and right of the operand.  The
     // substrings should have a logical operand between them (&, |, or !).
     // The parse routine first obtains a list of subexpressions and their
     // logical seperators (operands).  It then parses each subexpression and
     // builds a list of operations, left values and right values.
     BuildIfList(Expression, ExprList, NoExpr, JoinOps);
     for i := 1 to NoExpr do
     begin
          tempstr := ExprList[i-1];
    	  OpPos := OpPosition(tempstr, chr, OpLong);
     	  if (OpPos = -1) then
          begin
               ShowMessage('ERROR! Expression missing an operator');
	       exit;
          end;
         Ops[i-1] := Ops[i-1] + chr;
         tempstr := ExprList[i-1];
         GetLeftSt(tempstr, tempstr2, OpPos);
         LeftValue[i-1] := tempstr2;
         tempstr := ExprList[i-1];
         GetRightSt(tempstr,tempstr2, OpPos, OpLong);
         RightValue[i-1] := tempstr2;
     end;
end;

function TSelectIfFrm.TruthValue(caseno, ExpNo: integer; var LeftStr: string;
  var RightStr: string; var OpCode: string; var VarLabels: StrDyneVec;
  NoVars: integer): boolean;
var
    TempValueLeft, TempValueRight : double;
    typeresult, LeftVarPos, RightVarPos : integer;
    LeftIsNo, RightIsNo, Truth, badvalue : boolean;

begin
     badvalue := false;
     TempValueLeft := 0.0;
     TempValueRight := 0.0;
     LeftVarPos := 0;
     RightVarPos := 0;

    typeresult := isnumeric(LeftStr);
    if typeresult = 1 then
    begin
    	TempValueLeft := StrToFloat(LeftStr);
        LeftIsNo := true;
    end
    else begin //check for a variable label
    	LeftIsNo := false;
        LeftVarPos := GetVarIndex(LeftStr, VarLabels, NoVars);
        if LeftVarPos = -1 then
        begin
           ShowMessage('ERROR! Invalid variable label');
           Result := false;
           exit;
        end;
    end;

    typeresult := isnumeric(RightStr);
    if typeresult = 1 then
    begin
    	TempValueRight := StrToFloat(RightStr);
        RightIsNo := true;
    end
    else begin //check for a variable label
    	RightIsNo := false;
        RightVarPos := GetVarIndex(LeftStr, VarLabels, NoVars);
        if RightVarPos = -1 then
        begin
             ShowMessage('ERROR! Invalid variable label');
             Result :=  false;
             exit;
        end;
    end;

    // Now evaluate record truth or falseness
    if (RightIsNo) and (not LeftIsNo) then // Left is variable, right is value
    begin
     if ValidValue(caseno,LeftVarPos) then
	    TempValueLeft := StrToFloat(OS3MainFrm.DataGrid.Cells[LeftVarPos,caseno])
     else badvalue := true;
    end;
    if (Not RightIsNo) and (LeftIsNo) then // Left is value, right is variable
    begin
     if ValidValue(caseno,RightVarPos) then
    	TempValueRight := StrToFloat(OS3MainFrm.DataGrid.Cells[RightVarPos,caseno])
     else badvalue := true;
    end;
    if ( Not RightIsNo) and ( Not LeftIsNo) then // Both are variables
    begin
     if ValidValue(caseno,LeftVarPos) then
       TempValueLeft := StrToFloat(OS3MainFrm.DataGrid.Cells[LeftVarPos,caseno])
     else badvalue := true;
     if ValidValue(caseno,RightVarPos) then
       TempValueRight := StrToFloat(OS3MainFrm.DataGrid.Cells[RightVarPos,caseno])
     else badvalue := true;
    end;

    Truth := false;
    if OpCode = '=' then
    begin
         if (TempValueLeft = TempValueRight) then Truth := true;
    end;
    if OpCode = '<' then
    begin
          if (TempValueLeft < TempValueRight) then Truth := true;
    end;
    if OpCode = '>' then
    begin
         if (TempValueLeft > TempValueRight) then Truth := true;
    end;
    if OpCode = '>=' then
    begin
         if (TempValueLeft >= TempValueRight) then Truth := true;
    end;
    if OpCode = '<=' then
    begin
         if (TempValueLeft <= TempValueRight) then Truth := true;
    end;
    if OpCode = '<>' then
    begin
         if (TempValueLeft <> TempValueRight) then Truth := true;
    end;
    if badvalue then Truth := false;
    Result := Truth;
end;

initialization
  {$I selectifunit.lrs}

end.

