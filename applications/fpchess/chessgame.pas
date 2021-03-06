unit chessgame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpimage, dateutils,
  Forms, Controls, Graphics, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, Buttons, Spin;

const
  colA = 1;
  colB = 2;
  colC = 3;
  colD = 4;
  colE = 5;
  colF = 6;
  colG = 7;
  colH = 8;

  INT_CHESSTILE_SIZE = 40;
  INT_CHESSBOARD_SIZE = 40 * 8;

  FPCOLOR_TRANSPARENT_TILE: TFPColor = (Red: $0000; Green: $8100; Blue: $8100; Alpha: alphaOpaque); //+/-colTeal

type

  TPacketKind = (pkConnect, pkStartGameClientAsWhite, pkStartGameClientAsBlack, pkMove);

  { TPacket }

  TPacket = class
  public
    // Packet Data
    ID: Cardinal;
    Kind: TPacketKind;
    MoveStartX, MoveStartY, MoveEndX, MoveEndY: Byte;
    Next: TPacket; // To build a linked list
  end;

  TChessTile = (ctEmpty,
    ctWPawn, ctWKnight, ctWBishop, ctWRook, ctWQueen, ctWKing,
    ctBPawn, ctBKnight, ctBBishop, ctBRook, ctBQueen, ctBKing
    );

const
  WhitePieces = [ctWPawn, ctWKnight, ctWBishop, ctWRook, ctWQueen, ctWKing];
  BlackPieces = [ctBPawn, ctBKnight, ctBBishop, ctBRook, ctBQueen, ctBKing];
  WhitePiecesOrEmpty = [ctEmpty, ctWPawn, ctWKnight, ctWBishop, ctWRook, ctWQueen, ctWKing];
  BlackPiecesOrEmpty = [ctEmpty, ctBPawn, ctBKnight, ctBBishop, ctBRook, ctBQueen, ctBKing];

type
  {@@
    The index [1][1] refers to the left-bottom corner of the table,
    also known as A1.
    The first index is the column, to follow the same standard used to
    say coordinates, for example: C7 = [3][7]
  }
  TChessBoard = array[1..8] of array[1..8] of TChessTile;

  TChessMove = record
    From, To_: TPoint;
    PieceMoved, PieceCaptured: TChessTile;
  end;

  TOnMoveCallback = procedure (AFrom, ATo: TPoint);
  TPawnPromotionCallback = function (APawn: TChessTile): TChessTile of object;

  { TChessGame }

  TChessGame = class
  private
    function WillKingBeInCheck(AFrom, ATo, AEnpassantToClear: TPoint): Boolean;
    function IsKingInCheck(AKingPos: TPoint): Boolean;
    procedure DoMovePiece(AFrom, ATo, AEnpassantToClear: TPoint);
    function ValidateRookMove(AFrom, ATo: TPoint) : boolean;
    procedure ResetCastleVar(AFrom : TPoint);
    function ValidateKnightMove(AFrom, ATo: TPoint) : boolean;
    function ValidateBishopMove(AFrom, ATo: TPoint) : boolean;
    function ValidateQueenMove(AFrom, ATo: TPoint) : boolean;
    function ValidateKingMove(AFrom, ATo: TPoint) : boolean;
    function CheckPassageSquares(side: boolean; AFrom, ATo : TPoint) : boolean;
    procedure DoCastle();
    function ValidatePawnMove(AFrom, ATo: TPoint;
      var AEnpassantSquare, AEnpassantSquareToClear: TPoint) : boolean;
    function ValidatePawnSimpleCapture(AFrom,ATo: TPoint): Boolean;
    function RookHasValidMove(ASquare: TPoint): boolean;
    function BishopHasValidMove(ASquare: TPoint): boolean;
    function QueenHasValidMove(ASquare: TPoint): boolean;
    function KnightHasValidMove(ASquare: TPoint): boolean;
    function KingHasValidMove(ASquare: TPoint): boolean;
    function PawnHasValidMove(ASquare, AEnPassantToClear: TPoint): boolean;
    function verifyIfHasValidMoves(AEnPassantToClear: TPoint): boolean;
    function makeMoveAndValidate(AFrom, Ato, AEnPassantToClear: TPoint): boolean;
    function willBeCheckMate(AEnpassantToClear: TPoint): boolean;
    function willBeStalemate(AEnpassantToClear: TPoint): boolean;
    function IsSquareOccupied(ASquare: TPoint): Boolean;
    procedure doPromotion(Position: TPoint);
  public
    Board: TChessBoard;
    msg : String;
    PlayerName: string;
    FirstPlayerIsWhite, IsWhitePlayerTurn: Boolean;
    Dragging: Boolean;
    DragStart, MouseMovePos: TPoint;
    UseTimer: Boolean;
    Enabled: Boolean;
    WhitePlayerTime: Integer; // milisseconds
    BlackPlayerTime: Integer; // milisseconds
    MoveStartTime: TDateTime;
    // Last move (might in the future store all history)
    PreviousMove: TChessMove;
    // Data for Enpassant
    EnpassantSquare: TPoint; // Negative coords indicate that it is not allowed
    // Flags for castling
    IsWhiteLeftCastlePossible, IsWhiteRightCastlePossible: Boolean;
    IsBlackLeftCastlePossible, IsBlackRightCastlePossible: Boolean;
    Castle:boolean;//If the move will be a castle.
    CastleCord: TPoint;
    eraseCastleFlags: Integer; // 1=no, 2=yes, 3=flags already erased
    // Callbacks
    OnAfterMove: TOnMoveCallback;  // For the modules
    OnBeforeMove: TOnMoveCallback; // For the UI
    OnPawnPromotion: TPawnPromotionCallback;
    //
    constructor Create;
    procedure StartNewGame(APlayAsWhite: Boolean; AUseTimer: Boolean; APlayerTime: Integer); overload;
    procedure StartNewGame(APlayAsWhite: Integer; AUseTimer: Boolean; APlayerTime: Integer); overload;
    function ClientToBoardCoords(AClientCoords: TPoint): TPoint;
    class function BoardPosToChessCoords(APos: TPoint): string;
    class function ChessCoordsToBoardPos(AStr: string): TPoint;
    class procedure ChessMoveCoordsToBoardPos(AMoveStr: string; var AFrom, ATo: TPoint);
    class function ColumnNumToLetter(ACol: Integer): string;
    function CheckStartMove(AFrom: TPoint): Boolean;
    function CheckEndMove(ATo: TPoint): Boolean;
    function FindKing(): TPoint;
    function MovePiece(AFrom, ATo: TPoint): Boolean;
    procedure UpdateTimes();
    function GetCurrentPlayerName(): string;
    function GetCurrentPlayerColor(): string;
  end;

var
  vChessGame: TChessGame;

operator = (A, B: TPoint): Boolean;

implementation

operator=(A, B: TPoint): Boolean;
begin
  Result := (A.X = B.X) and (A.Y = B.Y);
end;

{ TChessGame }

constructor TChessGame.Create;
begin
  inherited Create;

end;

procedure TChessGame.StartNewGame(APlayAsWhite: Boolean; AUseTimer: Boolean; APlayerTime: Integer);
var
  lWPawnRow, lWMainRow, lBPawnRow, lBMainRow: Byte;
  i: Integer;
  j: Integer;
begin
  Enabled := True;
  UseTimer := AUseTimer;
  FirstPlayerIsWhite := APlayAsWhite;
  IsWhitePlayerTurn := True;
  WhitePlayerTime := APlayerTime * 60 * 1000; // minutes to milisseconds
  BlackPlayerTime := APlayerTime * 60 * 1000; // minutes to milisseconds
  MoveStartTime := Now;

  EnpassantSquare := Point(-1, -1); // Negative coords indicate that it is not allowed
  IsWhiteLeftCastlePossible := True;
  IsWhiteRightCastlePossible := True;
  IsBlackLeftCastlePossible := True;
  IsBlackRightCastlePossible := True;

  // Don't invert these, instead invert only in the drawer
  lWPawnRow := 2;
  lWMainRow := 1;
  lBPawnRow := 7;
  lBMainRow := 8;

  // First, clear the board
  for i := 1 to 8 do
   for j := 1 to 8 do
    Board[i][j] := ctEmpty;

  // White pawns
  for i := 1 to 8 do
   Board[i][lWPawnRow] := ctWPawn;

  // White main row
  Board[1][lWMainRow] := ctWRook;
  Board[2][lWMainRow] := ctWKnight;
  Board[3][lWMainRow] := ctWBishop;
  Board[4][lWMainRow] := ctWQueen;
  Board[5][lWMainRow] := ctWKing;
  Board[6][lWMainRow] := ctWBishop;
  Board[7][lWMainRow] := ctWKnight;
  Board[8][lWMainRow] := ctWRook;

  // White pawns
  for i := 1 to 8 do
   Board[i][lBPawnRow] := ctBPawn;

  // Black main row
  Board[1][lBMainRow] := ctBRook;
  Board[2][lBMainRow] := ctBKnight;
  Board[3][lBMainRow] := ctBBishop;
  Board[4][lBMainRow] := ctBQueen;
  Board[5][lBMainRow] := ctBKing;
  Board[6][lBMainRow] := ctBBishop;
  Board[7][lBMainRow] := ctBKnight;
  Board[8][lBMainRow] := ctBRook;
end;

procedure TChessGame.StartNewGame(APlayAsWhite: Integer; AUseTimer: Boolean; APlayerTime: Integer);
begin
  StartNewGame(APlayAsWhite = 0, AUseTimer, APlayerTime);
end;

{
  Returns: If the move is valid and was executed
}
function TChessGame.MovePiece(AFrom, ATo: TPoint): Boolean;
var
  i : integer;
  LEnpassantSquare, LEnpassantToClear: TPoint;
begin
  LEnpassantSquare := Point(-1, -1);
  LEnpassantToClear := Point(-1, -1);
  Castle:=false;
  eraseCastleFlags:=1;
  Result := False;

  // Verify what is in the start and destination squares
  if not CheckStartMove(AFrom) then Exit;
  if not CheckEndMove(ATo) then Exit;

  // Verify if the movement is in accordance to the rules for this piece
  if Board[AFrom.X][AFrom.Y] in [ctWPawn, ctBPawn] then result := ValidatePawnMove(AFrom,ATo, LEnpassantSquare, LEnpassantToClear)
  else if Board[AFrom.X][AFrom.Y] in [ctWRook, ctBRook] then result := ValidateRookMove(AFrom,ATo)
  else if Board[AFrom.X][AFrom.Y] in [ctWKnight, ctBKnight] then result := ValidateKnightMove(AFrom,ATo)
  else if Board[AFrom.X][AFrom.Y] in [ctWBishop, ctBBishop] then result := ValidateBishopMove(AFrom,ATo)
  else if Board[AFrom.X][AFrom.Y] in [ctWQueen, ctBQueen] then result := ValidateQueenMove(AFrom,ATo)
  else if Board[AFrom.X][AFrom.Y] in [ctWKing, ctBKing] then result := ValidateKingMove(AFrom,ATo);

  if not Result then Exit;

  // Check if the king will be left in check by this move
  if WillKingBeInCheck(AFrom, ATo, LEnpassantToClear) then Exit;

  // If we arrived here, this means that the move will be really executed

  // Store this move as the previously executed one
  PreviousMove.From := AFrom;
  PreviousMove.To_ := ATo;
  PreviousMove.PieceMoved := Board[AFrom.X][AFrom.Y];
  PreviousMove.PieceCaptured := Board[ATo.X][ATo.Y];
  EnpassantSquare := LEnpassantSquare;

  // Now we will execute the move
  DoMovePiece(AFrom, ATo, LEnpassantToClear);
  if Castle then DoCastle();

  if ((Board[ATo.X][Ato.Y]=ctWPawn) and (Ato.Y=8)) or ((Board[ATo.X][Ato.Y]=ctBPawn) and (ATo.Y=1)) then //If a pawn will be promoted
    doPromotion(Ato);
  //
  UpdateTimes();

  // Notify of the move
  if Assigned(OnBeforeMove) then OnBeforeMove(AFrom, ATo);

  // Change player
  IsWhitePlayerTurn := not IsWhitePlayerTurn;

  // Check if the player was checkmated
  if willBeCheckMate(EnpassantSquare) then
  begin
    if (IsWhitePlayerTurn) then
    begin
      ShowMessage('White checkmated, black wins');
      //TODO: need to stop the timers and set the result.
    end
    else
    begin
      ShowMessage('Black checkmated, white wins');
    end;
  end
  else
  begin
    if willBeStalemate(EnpassantSquare) then
    begin
      ShowMessage('Game draw');
    end;
  end;

  // Notify of the move
  if Assigned(OnAfterMove) then OnAfterMove(AFrom, ATo);
end;

{ Actually move the piece (without doing any check) }
procedure TChessGame.DoMovePiece(AFrom, ATo, AEnpassantToClear: TPoint);
begin
  // col, row
  Board[ATo.X][ATo.Y] := Board[AFrom.X][AFrom.Y];
  Board[AFrom.X][AFrom.Y] := ctEmpty;

  // If Enpassant, clear the remaining pawn
  if AEnpassantToClear.X <> -1 then
    Board[AEnpassantToClear.X][AEnpassantToClear.Y] := ctEmpty;

  if (eraseCastleFlags=2) then
    if   IsWhitePlayerTurn then ResetCastleVar(Point(5,1))
    else                        ResetCastleVar(Point(5,8));

end;

procedure TChessGame.doPromotion(Position: TPoint);
var
  lNewPiece: TChessTile;
begin
  if Assigned(OnPawnPromotion) then
  begin
    lNewPiece := OnPawnPromotion(Board[position.X][position.Y]);
    Board[position.X][position.Y] := lNewPiece;
  end;
end;

procedure TChessGame.DoCastle();
begin
  if CastleCord.X=8 then
    Board[6][CastleCord.Y]:=Board[8][CastleCord.Y]
  else
    Board[4][CastleCord.Y]:=Board[1][CastleCord.Y];
  Board[CastleCord.X][CastleCord.Y]:=ctEmpty;
end;

//return true if the move of a Rook is valid.
function TChessGame.ValidateRookMove(AFrom, ATo: TPoint): boolean;
var
  i: Integer;
begin
  Result := False;

  //////////////////////////////////////UP////////////////////////////////////////
  if (AFrom.X = ATo.X) and (AFrom.Y < ATo.Y) then
  begin
    // Check if there are pieces in the middle of the way
    for i := AFrom.Y + 1 to ATo.Y - 1 do
      if Board[AFrom.X][i] <> ctEmpty then Exit;
    ResetCastleVar(AFrom);
    Exit(True);
  end;
///////////////////////////////////DOWN/////////////////////////////////////////
  if (AFrom.X = ATo.X) and (AFrom.Y > ATo.Y) then
  begin
    // Check if there are pieces in the middle of the way
    for i := AFrom.Y - 1 downto ATo.Y + 1 do
      if Board[AFrom.X][i] <> ctEmpty then Exit;
    ResetCastleVar(AFrom);
    Exit(True);
  end;
////////////////////////////////////RIGHT////////////////////////////////////////
  if (AFrom.X < ATo.X) and (AFrom.Y = ATo.Y) then
  begin
    // Check if there are pieces in the middle of the way
    for i := AFrom.X + 1 to ATo.X - 1 do
      if Board[i][AFrom.Y] <> ctEmpty then Exit;
    ResetCastleVar(AFrom);
    Exit(True);
  end;
///////////////////////////////////LEFT/////////////////////////////////////////
  if (AFrom.X > ATo.X) and (AFrom.Y = ATo.Y) then
  begin
    // Check if there are pieces in the middle of the way
    for i := AFrom.X - 1 downto ATo.X + 1 do
      if Board[i][AFrom.Y] <> ctEmpty then Exit;
    ResetCastleVar(AFrom);
    Exit(True);
  end;
end;

//turn false the possibility of castle.
procedure TChessGame.ResetCastleVar(AFrom : TPoint);
begin
  // Verify if it was the rook that was moved
  if ((AFrom.X=1) and (AFrom.Y=1) and (IsWhiteLeftCastlePossible)) then IsWhiteLeftCastlePossible:=false;
  if ((AFrom.X=8) and (AFrom.Y=1) and (IsWhiteRightCastlePossible)) then IsWhiteRightCastlePossible:=false;
  if ((AFrom.X=1) and (AFrom.Y=8) and (IsBlackLeftCastlePossible)) then IsBlackLeftCastlePossible:=false;
  if ((AFrom.X=8) and (AFrom.Y=8) and (IsBlackLeftCastlePossible)) then IsBlackRightCastlePossible:=false;
  // Verify if it was the king that was moved
  if ((AFrom.X=5) and (AFrom.Y=1)) then begin
    IsWhiteLeftCastlePossible:=false;
    IsWhiteRightCastlePossible:=false;
  end;
  if ((AFrom.X=5) and (AFrom.Y=8)) then begin
    IsBlackLeftCastlePossible:=false;
    IsBlackRightCastlePossible:=false;
  end;
end;

{
  The knight has 8 possible destinations only:

        [X][ ][X]
     [X][ ][ ][ ][X]
     [ ][ ][K][ ][ ]
     [X][ ][ ][ ][X]
        [X]   [X]
}
function TChessGame.ValidateKnightMove(AFrom, ATo: TPoint): Boolean;
begin
  Result := (AFrom.X = ATo.X + 1) and (AFrom.Y + 2 = ATo.Y); // upper left corner
  Result := Result or ((AFrom.X = ATo.X + 2) and (AFrom.Y + 1 = ATo.Y)); // upper left corner
  Result := Result or ((AFrom.X = ATo.X + 2) and (AFrom.Y - 1 = ATo.Y)); // lower left corner
  Result := Result or ((AFrom.X = ATo.X + 1) and (AFrom.Y - 2 = ATo.Y)); // lower left corner
  Result := Result or ((AFrom.X = ATo.X - 1) and (AFrom.Y - 2 = ATo.Y)); // lower right corner
  Result := Result or ((AFrom.X = ATo.X - 2) and (AFrom.Y - 1 = ATo.Y)); // lower right corner
  Result := Result or ((AFrom.X = ATo.X - 2) and (AFrom.Y + 1 = ATo.Y)); // upper right corner
  Result := Result or ((AFrom.X = ATo.X - 1) and (AFrom.Y + 2 = ATo.Y)); // upper right corner
end;

function TChessGame.ValidateBishopMove(AFrom, ATo: TPoint): Boolean;
var
  i,j : Integer;
begin
  result :=false;
  //Up left
  if (AFrom.X>ATo.X) and (AFrom.Y<ATo.Y) and (AFrom.X-ATo.X=ATo.Y-AFrom.Y)then
  begin
    i := AFrom.X-1;
    j := AFrom.Y+1;
    while (i>=ATo.X+1) and (j<=ATo.Y-1) do
    begin
      if Board[i][j] <> ctEmpty then Exit;
      i := i - 1;
      j := j + 1;
    end;
    exit(True);
  end;
  //Up right
  if (AFrom.X<ATo.X) and (AFrom.Y<ATo.Y) and (ATo.X-AFrom.X=ATo.Y-AFrom.Y) then
  begin
    i := AFrom.X+1;
    j := AFrom.Y+1;
    while (i<=ATo.X-1) and (j<=ATo.Y-1) do
    begin
      if Board[i][j] <> ctEmpty then Exit;
      i := i + 1;
      j := j + 1;
    end;
    exit(True);
  end;
  //Down left
  if (AFrom.X>ATo.X) and (AFrom.Y>ATo.Y) and (AFrom.X-ATo.X=AFrom.Y-ATo.Y) then
  begin
    i := AFrom.X-1;
    j := AFrom.Y-1;
    while (i>=ATo.X+1) and (j>=ATo.Y+1) do
    begin
      if Board[i][j] <> ctEmpty then Exit;
      i := i - 1;
      j := j - 1;
    end;
    exit(True);
  end;
  //Down right
  if (AFrom.X<ATo.X) and (AFrom.Y>ATo.Y) and (ATo.X-AFrom.X=AFrom.Y-ATo.Y)then
  begin
    i := AFrom.X+1;
    j := AFrom.Y-1;
    while (i<=ATo.X-1) and (j>=ATo.Y+1) do
    begin
      if Board[i][j] <> ctEmpty then Exit;
      i := i + 1;
      j := j - 1;
    end;
    exit(True);
  end;
end;

function TChessGame.ValidateQueenMove(AFrom, ATo: TPoint): Boolean;
begin
  Result := ValidateRookMove(AFrom, ATo) or ValidateBishopMove(AFrom, ATo);
end;

function TChessGame.ValidateKingMove(AFrom, ATo: TPoint): Boolean;
var passage : boolean;
begin
  Result := False;

  // Verify the possibility of castling
  if IsWhitePlayerTurn then
  begin
    // Castle to the right
    if IsWhiteRightCastlePossible and (AFrom.X = 5) and (AFrom.Y = 1)
      and (ATo.X = 7) and (ATo.Y = 1) and (board[6][1]=ctEmpty) then
    begin
      if not(CheckPassageSquares(true,AFrom,ATo)) then exit(false);
      Castle:=true;
      CastleCord.X:=8;
      CastleCord.Y:=1;
      result:= True;
    end;
    // Castle to the left
    if IsWhiteLeftCastlePossible and (AFrom.X = 5) and (AFrom.Y = 1)
      and (ATo.X = 3) and (ATo.Y = 1) and (board[2][1]=ctEmpty) and (board[4][1]=ctEmpty) then
    begin
      if not(CheckPassageSquares(false,AFrom,ATo)) then exit(false);
      Castle:=true;
      CastleCord.X:=1;
      CastleCord.Y:=1;
      result:= True;
    end;
  end
  else
  begin
  // Castle to the right
    if IsBlackRightCastlePossible and (AFrom.X = 5) and (AFrom.Y = 8)
      and (ATo.X = 7) and (ATo.Y = 8) and (board[6][8]=ctEmpty) then
    begin
      if not(CheckPassageSquares(true,AFrom,ATo)) then exit(false);
      Castle:=true;
      CastleCord.X:=8;
      CastleCord.Y:=8;
      result:= True;
    end;
    // Castle to the left
    if IsBlackLeftCastlePossible and (AFrom.X = 5) and (AFrom.Y = 8)
      and (ATo.X = 3) and (ATo.Y = 8) and (board[2][8]=ctEmpty) and (board[4][8]=ctEmpty) then
    begin
      if not(CheckPassageSquares(false,AFrom,ATo)) then exit(false);
      Castle:=true;
      CastleCord.X:=1;
      CastleCord.Y:=8;
      result:= True;
    end;
  end;

  // Simple move
  if (AFrom.X > ATo.X + 1) or (AFrom.X + 1 < ATo.X) then Exit;
  if (AFrom.Y > ATo.Y + 1) or (AFrom.Y + 1 < ATo.Y) then Exit;

  if (eraseCastleFlags<3) then inc(eraseCastleFlags);
  Result := True;
end;

//Return false if during the passage the king will be in check
function TChessGame.CheckPassageSquares(side : boolean; AFrom, ATo : TPoint) : boolean; //Left=false;Right=true;
var
  LocalBoard : TChessBoard;
  kingPos : TPoint;
begin
  kingPos := FindKing();
  Result := IsKingInCheck(kingPos);
  if (result) then exit(false);

  LocalBoard:=Board;

  if IsWhitePlayerTurn then
  begin
    if side then
    begin
      Board[5][1]:=ctEmpty;
      Board[6][1]:=ctWKing;
      kingPos := FindKing();
      Result := IsKingInCheck(kingPos);
      Board:=LocalBoard;
      Exit(not Result);
    end
    else
    begin
      Board[5][1]:=ctEmpty;
      Board[4][1]:=ctWKing;
      kingPos := FindKing();
      Result := IsKingInCheck(kingPos);
      Board:=LocalBoard;
      Exit(not Result);
    end;
  end
  else
  begin
    if side then
    begin
      Board[5][8]:=ctEmpty;
      Board[6][8]:=ctBKing;
      kingPos := FindKing();
      Result := IsKingInCheck(kingPos);
      Board:=LocalBoard;
      Exit(not Result);
    end
    else
    begin
      Board[5][8]:=ctEmpty;
      Board[4][8]:=ctBKing;
      kingPos := FindKing();
      Result := IsKingInCheck(kingPos);
      Board:=LocalBoard;
      Exit(not Result);
    end;
  end;
end;

{
  The white is always in the bottom at the moment,
  which means the smallest x,y values

  If positive coords are feed to AEnpassantSquare, this means that
  enpassant will be allowed in the next move

  If positive coords are feed to AEnpassantSquareToClear, then we
  made an enpassant capture and a square is to be cleared from the
  captured pawn. This isn't done yet because the check verification
  wasn't made yet, so it is not certain that the move will take place.
}
function TChessGame.ValidatePawnMove(AFrom, ATo: TPoint;
  var AEnpassantSquare, AEnpassantSquareToClear: TPoint): Boolean;
begin
  AEnpassantSquare := Point(-1, -1);
  AEnpassantSquareToClear := Point(-1, -1);
  Result := False;

  if IsWhitePlayerTurn then
  begin
    // Normal move forward
    if (AFrom.X = ATo.X) and (AFrom.Y = ATo.Y - 1) then
    begin
      Result := not IsSquareOccupied(ATo);
    end
    // Initial double move forward
    else if (AFrom.X = ATo.X) and (AFrom.Y = 2) and (AFrom.Y = ATo.Y - 2) and (not IsSquareOccupied(Point(AFrom.X,AFrom.Y+1))) then
    begin
      Result := not IsSquareOccupied(ATo);
      AEnpassantSquare := Point(AFrom.X, ATo.Y - 1);
    end
    // Normal capture in the left
    else if (ATo.X = AFrom.X-1) and (ATo.Y = AFrom.Y+1) and (Board[ATo.X][ATo.Y] in BlackPieces) then
    begin
      Result := True;
    end
    // Normal capture in the right
    else if (ATo.X = AFrom.X+1) and (ATo.Y = AFrom.Y+1) and (Board[ATo.X][ATo.Y] in BlackPieces) then
    begin
      Result := True;
    end
    // En Passant Capture in the left
    else if (EnPassantSquare = ATo) and
      (ATo.X = AFrom.X-1) and (ATo.Y = AFrom.Y+1) then
    begin
      Result := True;
      AEnpassantSquareToClear := Point(ATo.X, ATo.Y-1);
    end
    // En Passant Capture in the right
    else if (EnPassantSquare = ATo) and
      (ATo.X = AFrom.X+1) and (ATo.Y = AFrom.Y+1) then
    begin
      Result := True;
      AEnpassantSquareToClear := Point(ATo.X, ATo.Y-1);
    end;
  end
  else
  begin
    // Normal move forward
    if (AFrom.X = ATo.X) and (AFrom.Y = ATo.Y + 1) then
    begin
      Result := not IsSquareOccupied(ATo);
    end
    // Initial double move forward
    else if (AFrom.X = ATo.X) and (AFrom.Y = 7) and (AFrom.Y = ATo.Y + 2) and (not IsSquareOccupied(Point(AFrom.X,AFrom.Y-1))) then
    begin
      Result := not IsSquareOccupied(ATo);
      AEnpassantSquare := Point(AFrom.X, ATo.Y + 1);
    end
    // Capture a piece in the left
    else if (ATo.X = AFrom.X-1) and (ATo.Y = AFrom.Y-1) and (Board[ATo.X][ATo.Y] in WhitePieces) then
    begin
      Result := True;
    end
    // Capture a piece in the right
    else if (ATo.X = AFrom.X+1) and (ATo.Y = AFrom.Y-1) and (Board[ATo.X][ATo.Y] in WhitePieces) then
    begin
      Result := True;
    end
    // En Passant Capture in the left
    else if (EnPassantSquare = ATo) and
      (ATo.X = AFrom.X-1) and (ATo.Y = AFrom.Y-1) then
    begin
      Result := True;
      AEnpassantSquareToClear := Point(ATo.X, ATo.Y+1);
    end
    // En Passant Capture in the right
    else if (EnPassantSquare = ATo) and
      (ATo.X = AFrom.X+1) and (ATo.Y = AFrom.Y-1) then
    begin
      Result := True;
      // Don't clear immediately because we haven't yet checked for kind check
      AEnpassantSquareToClear := Point(ATo.X, ATo.Y+1);
    end;
  end;
end;

//This function is used by IsKingInCheck. It makes the verification reversed
//(verify a black move in white turn and vice-versa) and don't change the enpassant
//variables.
function TChessGame.ValidatePawnSimpleCapture(AFrom,ATo: TPoint): Boolean;
begin
  result:=false;
  if not IsWhitePlayerTurn then
  begin
    // Normal capture in the left
    if (ATo.X = AFrom.X-1) and (ATo.Y = AFrom.Y+1) and IsSquareOccupied(ATo) then
    begin
      Result := True;
    end
    // Normal capture in the right
    else if (ATo.X = AFrom.X+1) and (ATo.Y = AFrom.Y+1) and IsSquareOccupied(ATo) then
    begin
      Result := True;
    end;
  end
  else
  begin
    // Capture a piece in the left
    if (ATo.X = AFrom.X-1) and (ATo.Y = AFrom.Y-1) and IsSquareOccupied(ATo) then
    begin
      Result := True;
    end
    // Capture a piece in the right
    else if (ATo.X = AFrom.X+1) and (ATo.Y = AFrom.Y-1) and IsSquareOccupied(ATo) then
    begin
      Result := True;
    end
  end;
end;

function TChessGame.RookHasValidMove(ASquare: TPoint): boolean;
var i,j : integer;
    nullPoint: TPoint; // makeMoveandValidate needs an en passant point, as rooks
                       // can't capture en passant, pass a dummy negative point
    bkpWhiteLeftCastle, bkpWhiteRightCastle, bkpBlackLeftRook, bkpBlackRightRook : boolean;
begin
  Result:=false;
  nullPoint:=Point(-1,-1);

  bkpWhiteLeftCastle :=IsWhiteLeftCastlePossible;
  bkpWhiteRightCastle:=IsWhiteRightCastlePossible;
  bkpBlackLeftRook   :=IsBlackLeftCastlePossible;
  bkpBlackRightRook  :=IsBlackRightCastlePossible;

  for i:=1 to 8 do
  begin
    if (CheckEndMove(Point(ASquare.X,i)) and ValidateRookMove(ASquare,Point(ASquare.X,i))) then  //check the vertical
      if (makeMoveAndValidate(ASquare,Point(ASquare.X,i),nullPoint)) then
      begin
        IsWhiteLeftCastlePossible:=bkpWhiteLeftCastle;
        IsWhiteRightCastlePossible:=bkpWhiteRightCastle;
        IsBlackLeftCastlePossible:=bkpBlackLeftRook;
        IsBlackRightCastlePossible:=bkpBlackRightRook;
        exit(true);
      end;
    if (CheckEndMove(Point(i,ASquare.Y)) and ValidateRookMove(ASquare, Point(i,ASquare.Y))) then //check the horizontal
      if (makeMoveAndValidate(ASquare,Point(i,ASquare.Y),nullPoint)) then
      begin
        IsWhiteLeftCastlePossible:=bkpWhiteLeftCastle;
        IsWhiteRightCastlePossible:=bkpWhiteRightCastle;
        IsBlackLeftCastlePossible:=bkpBlackLeftRook;
        IsBlackRightCastlePossible:=bkpBlackRightRook;
        exit(true);
      end;
  end;
end;

function TChessGame.KnightHasValidMove(ASquare: TPoint): boolean;
var nullPoint: TPoint;
    ATo: TPoint;
begin
  Result:=false;
  nullPoint:=Point(-1,-1);

  ATo:=Point(ASquare.X+1,ASquare.Y+2);
  if (ASquare.X+1<=8) and (ASquare.Y+2<=8) and (CheckEndMove(ATo)) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X+2,ASquare.Y+1);
  if (ASquare.X+2<=8) and (ASquare.Y+1<=8) and (CheckEndMove(ATo)) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X+2,ASquare.Y-1);
  if (ASquare.X+2<=8) and (ASquare.Y-1>=1) and (CheckEndMove(ATo)) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X+1,ASquare.Y-2);
  if (ASquare.X+1<=8) and (ASquare.Y-2>=1) and (CheckEndMove(ATo)) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X-1,ASquare.Y-2);
  if (ASquare.X-1>=1) and (ASquare.Y-2>=1) and (CheckEndMove(ATo)) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X-2,ASquare.Y-1);
  if (ASquare.X-2>=1) and (ASquare.Y-1>=1) and (CheckEndMove(ATo)) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X-2,ASquare.Y+1);
  if (ASquare.X-2>=1) and (ASquare.Y+1<=8) and (CheckEndMove(ATo)) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X-1,ASquare.Y+2);
  if (ASquare.X-1>=1) and (ASquare.Y+2<=8) and (CheckEndMove(ATo)) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

end;

function TChessGame.BishopHasValidMove(ASquare: TPoint): boolean;
var i : integer;
    nullPoint: TPoint;
    ATo : TPoint;
begin
  Result:=false;
  nullPoint:=Point(-1,-1);
  for i:=1 to 8 do
  begin

    ATo := Point(ASquare.X+i,ASquare.Y+i);
    if (ASquare.X+i<=8) and (ASquare.Y+i<=8) and (CheckEndMove(ATo)) and (ValidateBishopMove(ASquare,ATo)) then //check the upper right diagonal
      if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

    ATo := Point(ASquare.X-i,ASquare.Y-i);
    if (ASquare.X-i>=1) and (ASquare.Y-i>=1) and (CheckEndMove(ATo)) and (ValidateBishopMove(ASquare,ATo)) then //check the lower left diagonal
      if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

    ATo := Point(ASquare.X+i,ASquare.Y-i);
    if (ASquare.X+i<=8) and (ASquare.Y-i>=1) and (CheckEndMove(ATo)) and (ValidateBishopMove(ASquare,ATo)) then //check the lower right diagonal
      if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

    ATo := Point(ASquare.X-i,ASquare.Y+i);
    if (ASquare.X-i>=1) and (ASquare.Y+i<=8) and (CheckEndMove(ATo)) and (ValidateBishopMove(ASquare,ATo)) then //check the upper left diagonal
      if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);
  end;
  result:=false;
end;

function TChessGame.QueenHasValidMove(ASquare: TPoint): boolean;
begin
  Result:=false;
  if (RookHasValidMove(ASquare) or BishopHasValidMove(ASquare)) then exit(true);
end;

function TChessGame.KingHasValidMove(ASquare: TPoint): boolean;
var nullPoint : TPoint;
    ATo       : TPoint;
begin
  Result:=false;
  nullPoint:=Point(-1,-1);

  ATo:=Point(ASquare.X+1,ASquare.Y);
  if (ASquare.X+1<=8) and CheckEndMove(ATo) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X+1,ASquare.Y+1);
  if (ASquare.X+1<=8) and (ASquare.Y+1<=8) and CheckEndMove(ATo) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X,ASquare.Y+1);
  if (ASquare.Y+1<=8) and CheckEndMove(ATo) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X-1,ASquare.Y+1);
  if (ASquare.X-1>=1) and (ASquare.Y+1<=8) and CheckEndMove(ATo) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X-1,ASquare.Y);
  if (ASquare.X-1>=1) and CheckEndMove(ATo) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X-1,ASquare.Y-1);
  if (ASquare.X-1>=1) and (ASquare.Y-1>=1) and CheckEndMove(ATo) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X,ASquare.Y-1);
  if (ASquare.Y-1>=1) and CheckEndMove(ATo) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);

  ATo:=Point(ASquare.X+1,ASquare.Y-1);
  if (ASquare.X+1<=8) and (ASquare.Y-1>=1) and CheckEndMove(ATo) then
    if (makeMoveAndValidate(ASquare,ATo,nullPoint)) then exit(true);
end;

// true = the move is valid
function TChessGame.makeMoveAndValidate(AFrom, ATo,AEnpassantToClear: TPoint): boolean;
begin
  result:= not WillKingBeInCheck(AFrom,ATo,AEnpassantToClear);
end;

function TChessGame.PawnHasValidMove(ASquare, AEnPassantToClear: TPoint): boolean;
var AEnPassantSquare, nullPoint: TPoint;
    ATo: TPoint;
begin
  Result:=false;
  nullPoint:=Point(-1,-1); //used when we know that the point does not matter.

  if IsWhitePlayerTurn then
  begin
    ATo:=Point(ASquare.X,ASquare.Y+2);
    if (ASquare.Y+2<=8) and (CheckEndMove(ATo)) and ValidatePawnMove(ASquare,ATo,nullPoint,nullPoint) then //try to move 2 squares
      if (makeMoveAndValidate(ASquare,ATo,Point(-1,-1))) then exit(true);

    ATo:=Point(ASquare.X,ASquare.Y+1);
    if (ASquare.Y+1<=8) and (Board[ATo.X][ATo.Y]=ctEmpty) then //try to move 1 square
      if (makeMoveAndValidate(ASquare,ATo,Point(-1,-1))) then exit(true);

    ATo:=Point(ASquare.X-1,ASquare.Y+1);
    if (ASquare.X-1>=1) and (ASquare.Y+1<=8) and (CheckEndMove(ATo)) and (ValidatePawnMove(ASquare,ATo,nullPoint,nullPoint)) then //try to capture to the left
      if (makeMoveAndValidate(ASquare,ATo,Point(AEnPassantToClear.X,AEnPassantToClear.Y-1))) then exit(true);

    ATo:=Point(ASquare.X+1,ASquare.Y+1);
    if (ASquare.X+1<=8) and (ASquare.Y+1<=8) and (CheckEndMove(ATo)) and (ValidatePawnMove(ASquare,ATo,nullPoint,nullPoint)) then //try to capture to the right
      if (makeMoveAndValidate(ASquare,ATo,Point(AEnPassantToClear.X,AEnPassantToClear.Y-1))) then exit(true);
  end
  else
  begin
    ATo:=Point(ASquare.X,ASquare.Y-2);
    if (ASquare.Y-2>=1) and (CheckEndMove(ATo)) and (ValidatePawnMove(ASquare,ATo,nullPoint,nullPoint)) then //try to move 2 squares
      if (makeMoveAndValidate(ASquare,ATo,Point(-1,-1))) then exit(true);

    ATo:=Point(ASquare.X,ASquare.Y-1);
    if (ASquare.Y-1>=1) and (Board[ATo.X][ATo.Y] = ctEmpty) then //try to move 1 square
      if (makeMoveAndValidate(ASquare,ATo,Point(-1,-1))) then exit(true);

    ATo:=Point(ASquare.X-1,ASquare.Y-1);
    if (ASquare.X-1>=1) and (ASquare.Y-1>=1) and (CheckEndMove(ATo)) and (ValidatePawnMove(ASquare,ATo,nullPoint,nullPoint)) then //try to capture to the left
      if (makeMoveAndValidate(ASquare,ATo,Point(AEnPassantToClear.X,AEnPassantToClear.Y+1))) then exit(true);

    ATo:=Point(ASquare.X+1,ASquare.Y-1);
    if (ASquare.X+1<=8) and (ASquare.Y-1>=1) and (CheckEndMove(ATo)) and (ValidatePawnMove(ASquare,ATo,nullPoint,nullPoint)) then //try to capture to the right
      if (makeMoveAndValidate(ASquare,ATo,Point(AEnPassantToClear.X,AEnPassantToClear.Y+1))) then exit(true);
  end;

end;

function TChessgame.verifyIfHasValidMoves(AEnPassantToClear: TPoint): boolean;
var i, j : integer;
begin
  Result:=false;
  if (IsWhitePlayerTurn) then
  begin
    for i:=1 to 8 do
    begin
      for j:=1 to 8 do
      begin
        if (Board[i][j]=ctWRook) then
          if RookHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctWBishop) then
          if BishopHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctWKnight) then
          if KnightHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctWKing) then
          if KingHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctWQueen) then
          if QueenHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctWPawn) then
          if PawnHasValidMove(Point(i,j),AEnPassantToClear) then exit(true);
      end;
    end;
  end
  else
  begin
    for i:=1 to 8 do
    begin
      for j:=1 to 8 do
      begin
        if (Board[i][j]=ctBRook) then
          if RookHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctBBishop) then
          if BishopHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctBKnight) then
          if KnightHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctBKing) then
          if KingHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctBQueen) then
          if QueenHasValidMove(Point(i,j)) then exit(true);
        if (Board[i][j]=ctBPawn) then
          if PawnHasValidMove(Point(i,j),AEnPassantToClear) then exit(true);
      end;
    end;
  end;
end;

function TChessGame.willBeCheckMate(AEnpassantToClear: TPoint): boolean;
var
  kingPos: TPoint;
begin
  Result := false;

  kingPos := FindKing();

  if IsKingInCheck(kingPos) then
  begin
    if not verifyIfHasValidMoves(AEnpassantToClear) then exit(true);
  end;
end;

function TChessGame.willBeStalemate(AEnpassantToClear: TPoint): boolean;
begin
  Result:= not verifyIfHasValidMoves(AEnpassantToClear);
end;

function TChessGame.IsSquareOccupied(ASquare: TPoint): Boolean;
begin
  Result := Board[ASquare.X][ASquare.Y] <> ctEmpty;
end;

procedure TChessGame.UpdateTimes();
var
  lNow: TDateTime;
  lTimeDelta: Integer;
begin
  lNow := Now;

  lTimeDelta := MilliSecondsBetween(lNow, MoveStartTime);
  MoveStartTime := lNow;

  if IsWhitePlayerTurn then WhitePlayerTime := WhitePlayerTime - lTimeDelta
  else BlackPlayerTime := BlackPlayerTime - lTimeDelta;
end;

function TChessGame.GetCurrentPlayerName: string;
begin
  if IsWhitePlayerTurn then Result := 'White'
  else Result := 'Black';
end;

function TChessGame.GetCurrentPlayerColor: string;
begin
  if IsWhitePlayerTurn then Result := 'White'
  else Result := 'Black';
end;

function TChessGame.ClientToBoardCoords(AClientCoords: TPoint): TPoint;
begin
  Result.X := 1 + AClientCoords.X div INT_CHESSTILE_SIZE;
  Result.Y := 1 + (INT_CHESSBOARD_SIZE - AClientCoords.Y) div INT_CHESSTILE_SIZE;
end;

class function TChessGame.BoardPosToChessCoords(APos: TPoint): string;
var
  lStr: string;
begin
  lStr := ColumnNumToLetter(APos.X);
  Result := Format('%s%d', [lStr, APos.Y]);
end;

class function TChessGame.ChessCoordsToBoardPos(AStr: string): TPoint;
var
  lStr: string;
begin
  if Length(AStr) < 2 then raise Exception.Create('[TChessGame.ChessCoordsToBoardPos] Length(AStr) < 2');
  lStr := Copy(AStr, 1, 1);
  lStr := LowerCase(lStr);
  Result.X := Byte(lStr[1]) - 96;
  lStr := Copy(AStr, 2, 1);
  Result.Y := StrToInt(lStr);
end;

class procedure TChessGame.ChessMoveCoordsToBoardPos(AMoveStr: string;
  var AFrom, ATo: TPoint);
var
  lStr: String;
begin
  WriteLn('[TChessGame.ChessMoveCoordsToBoardPos] ' + AMoveStr);
  lStr := Copy(AMoveStr, 1, 2);
  AFrom := TChessGame.ChessCoordsToBoardPos(lStr);
  lStr := Copy(AMoveStr, 4, 2);
  ATo := TChessGame.ChessCoordsToBoardPos(lStr);
  WriteLn(Format('[TChessGame.ChessMoveCoordsToBoardPos] AFrom.X=%d,%d ATo=%d,%d', [AFrom.X, AFrom.Y, ATo.X, ATo.Y]));
end;

class function TChessGame.ColumnNumToLetter(ACol: Integer): string;
begin
  Result := Char(ACol + 96);
end;

// Check if we are moving to either an empty space or to an enemy piece
function TChessGame.CheckEndMove(ATo: TPoint): Boolean;
begin
  if IsWhitePlayerTurn then
    Result := Board[ATo.X][ATo.Y] in BlackPiecesOrEmpty
  else
    Result := Board[ATo.X][ATo.Y] in WhitePiecesOrEmpty;
end;

{@@
  Check if we are moving one of our own pieces

  AFrom - The start move position in board coordinates
}
function TChessGame.CheckStartMove(AFrom: TPoint): Boolean;
begin
  if IsWhitePlayerTurn then
    Result := Board[AFrom.X][AFrom.Y] in WhitePieces
  else
    Result := Board[AFrom.X][AFrom.Y] in BlackPieces;
end;

// True  - The King will be in check
function TChessGame.WillKingBeInCheck(AFrom, ATo, AEnpassantToClear: TPoint): Boolean;
var
  kingPos: TPoint;
  localBoard: TChessBoard;
begin
  Result := false;

  localBoard := Board;

  DoMovePiece(AFrom, ATo, AEnpassantToClear);

  kingPos := FindKing();

  Result := IsKingInCheck(kingPos);

  Board:=localBoard;
end;

function TChessGame.IsKingInCheck(AKingPos: TPoint): Boolean;
var
  i,j : integer;
  piecePos : TPoint;
begin
  Result := False;

  for i:=1 to 8 do
    for j:=1 to 8 do
    begin
      piecePos := Point(i, j);
      if not (IsWhitePlayerTurn) then
      begin
        case Board[i][j] of
        ctWRook:   Result:= ValidateRookMove(piecePos,AKingPos);
        ctWKnight: Result:= ValidateKnightMove(piecePos,AKingPos);
        ctWBishop: Result:= ValidateBishopMove(piecePos,AKingPos);
        ctWQueen:  Result:= ValidateQueenMove(piecePos,AKingPos);
        ctWKing:   Result:= ValidateKingMove(piecePos,AKingPos);
        ctWPawn:   Result:= ValidatePawnSimpleCapture(piecePos,AKingPos);
        end;
      end
      else
      begin
        case Board[i][j] of
        ctBRook:   Result:= ValidateRookMove(piecePos,AKingPos);
        ctBKnight: Result:= ValidateKnightMove(piecePos,AKingPos);
        ctBBishop: Result:= ValidateBishopMove(piecePos,AKingPos);
        ctBQueen:  Result:= ValidateQueenMove(piecePos,AKingPos);
        ctBKing:   Result:= ValidateKingMove(piecePos,AKingPos);
        ctBPawn:   Result:= ValidatePawnSimpleCapture(piecePos,AKingPos);
        end;
      end;
      if (result) then exit();
    end;
end;

{ Negative coords indicate that the king is not in the game }
function TChessGame.FindKing(): TPoint;
var
  i,j : integer;
begin
  Result := Point(-1, -1);

  for i:=1 to 8 do
    for j:=1 to 8 do
    if (IsWhitePlayerTurn) and (Board[i][j]=ctWKing) then
    begin
      Result := Point(i, j);
      Exit;
    end
    else if (not IsWhitePlayerTurn) and (Board[i][j]=ctBKing) then
    begin
      Result := Point(i, j);
      Exit;
    end;
end;

initialization

vChessGame := TChessGame.Create;

finalization

vChessGame.Free;

end.

