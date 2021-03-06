{
  Chess Engine licensed under public domain obtained from:

  http://www.csbruce.com/~csbruce/chess/
}
unit mod_kcchess;

{$mode objfpc}

interface

uses
  Classes, SysUtils,
  StdCtrls, Forms, Controls, Spin,
  chessgame, chessmodules, chessdrawer;

const HIGH = 52;  WIDE = 52;  SINGLE_IMAGE_SIZE = 1500;
      BOARD_SIZE = 8;  ROW_NAMES = '12345678';  COL_NAMES = 'ABCDEFGH';
      BOARD_X1 = 19;  BOARD_Y1 = 4;  BOARD_X2 = 434;  BOARD_Y2 = 419;
      INSTR_LINE = 450;  MESSAGE_X = 460;
      NULL_MOVE = -1;  STALE_SCORE = -1000;
      MOVE_LIST_LEN = 300;  GAME_MOVE_LEN = 500;
      MAX_LOOKAHEAD = 9;  PLUNGE_DEPTH = -1;  NON_DEV_MOVE_LIMIT = 50;

      {*** pixel rows to print various messages in the conversation area ***}
      MSG_MOVE = 399;  MSG_BOXX1 = 464;    MSG_BOXX2 = 635;   MSG_MIDX = 550;
      MSG_WHITE = 165; MSG_BLACK = 54;     MSG_MOVENUM = 358; MSG_PLHI = 90;
      MSG_TURN = 375;  MSG_SCAN = 416;     MSG_CHI = 17;      MSG_HINT = 416;
      MSG_CONV = 40;   MSG_WARN50 = 277;   MSG_TIME_LIMIT = 258;
      MSG_SCORE = 318; MSG_POS_EVAL = 344; MSG_ENEMY_SCORE = 331;

type PieceImageType = (BLANK, PAWN, BISHOP, KNIGHT, ROOK, QUEEN, KING);
     PieceColorType = (C_WHITE, C_BLACK);
     {*** the color of the actual square ***}
     SquareColorType = (S_LIGHT, S_DARK, S_CURSOR);
     {*** which instructions to print at bottom of screen ***}
     InstructionType = (INS_MAIN, INS_GAME, INS_SETUP, INS_PLAYER, INS_SETUP_COLOR,
                        INS_SETUP_MOVED, INS_SETUP_MOVENUM, INS_FILE, INS_FILE_INPUT,
                        INS_WATCH, INS_GOTO, INS_OPTIONS, INS_PAWN_PROMOTE);
     {*** there is a two-thick border of 'dead squares' around the main board ***}
     RowColType = -1..10;
     {*** Turbo Pascal requires that parameter string be declared like this ***}
     string2 = string[2];
     string10 = string[10];
     string80 = string[80];
     {*** memory for a 52*52 pixel image ***}
     SingleImageType = array [1..SINGLE_IMAGE_SIZE] of byte;
     {*** images must be allocated on the heap because the stack is not large enough ***}
     ImageTypePt = ^ImageType;
     ImageType = array [PieceImageType, PieceColorType, SquareColorType] of SingleImageType;
     {*** text file records for help mode ***}
     HelpPageType = array [1..22] of string80;

     {*** directions to scan when looking for all possible moves of a piece ***}
     PossibleMovesType = array [PieceImageType] of record
                             NumDirections : 1..8;
                             MaxDistance : 1..7;
                             UnitMove : array [1..8] of record
                                 DirRow, DirCol: -2..2;
                             end;
                         end;

     {*** attributes for a piece or board square ***}
     PieceType = record
                     image : PieceImageType;
                     color : PieceColorType;
                     HasMoved : boolean;
                     ValidSquare : boolean;
                 end;

     BoardType = array [RowColType, RowColType] of PieceType;

     {*** representation of the movement of a piece, or 'ply' ***}
     MoveType = record
                    FromRow, FromCol, ToRow, ToCol : RowColType;
                    PieceMoved : PieceType;
                    PieceTaken : PieceType;
                    {*** image after movement - used for pawn promotion ***}
                    MovedImage : PieceImageType;
                end;

     {*** string of moves - used to store list of all possible moves ***}
     MoveListType = record
                       NumMoves : 0..MOVE_LIST_LEN;
                       Move : array [1..MOVE_LIST_LEN] of MoveType;
                   end;

     {*** attributes of both players ***}
     PlayerType = array [PieceColorType] of record
                      Name : string[20];
                      IsHuman : boolean;
                      LookAhead : 0..MAX_LOOKAHEAD;
                      PosEval : boolean;                  {*** Position Evaluation On / Off ***}
                      ElapsedTime : LongInt;
                      LastMove : MoveType;
                      InCheck : boolean;
                      KingRow, KingCol : RowColType;
                      CursorRow, CursorCol : RowColType;
                  end;

     {*** attributes to represent an entire game ***}
     GameType = record
                   MovesStored : 0..GAME_MOVE_LEN;   {*** number of moves stored ***}
                   MovesPointer : 0..GAME_MOVE_LEN;  {*** move currently displayed - for Takeback, UnTakeback ***}
                   MoveNum : 1..GAME_MOVE_LEN;       {*** current move or 'ply' number ***}
                   Player : PlayerType;
                   Move : array [1..GAME_MOVE_LEN] of MoveType;
                   InCheck : array [0..GAME_MOVE_LEN] of boolean;  {*** if player to move is in check ***}
                   FinalBoard : BoardType;
                   GameFinished : boolean;
                   TimeOutWhite, TimeOutBlack : boolean;  {*** reasons for a game... ***}
                   Stalemate, NoStorage : boolean;        {***   being finished ***}
                   NonDevMoveCount : array [0..GAME_MOVE_LEN] of byte;  {*** since pawn push or take - Stalemate-50 ***}
                   EnPassentAllowed : boolean;
                   SoundFlag : boolean;
                   FlashCount : integer;
                   WatchDelay : integer;
                   TimeLimit : longint;
               end;

    {*** global variables ***}
var Game : GameType;
    Board : BoardType;      {*** current board setup ***}
    Player : PlayerType;    {*** current player attributes ***}
    CapturePoints : array [PieceImageType] of integer;      {*** for taking enemy piece ***}
    EnemyColor : array [PieceColorType] of PieceColorType;  {*** opposite of given color ***}
    PossibleMoves : PossibleMovesType;
    LastTime : longint;         {*** last read system time-of-day clock value ***}
    DefaultFileName : string80; {*** for loading and saving games ***}
    ImageStore : ImageTypePt;
    GraphDriver, GraphMode : integer;   {*** for Turbo Pascal graphics ***}

type
  TKCChessThread = class;

  { TKCChessModule }

  TKCChessModule = class(TChessModule)
  private
    textDifficulty: TStaticText;
    spinDifficulty: TSpinEdit;
    PlayerColor, ComputerColor: PieceColorType;
    KCChessThread: TKCChessThread;
    class function FPChessPieceToKCChessImage(APos: TPoint): PieceImageType;
    class function FPChessPieceToKCChessColor(APos: TPoint): PieceColorType;
  public
    constructor Create(); override;
    procedure CreateUserInterface(); override;
    procedure ShowUserInterface(AParent: TWinControl); override;
    procedure HideUserInterface(); override;
    procedure FreeUserInterface(); override;
    procedure PrepareForGame(); override;
    function GetSecondPlayerName(): ansistring; override;
    procedure HandleOnMove(AFrom, ATo: TPoint); override;
  end;

  { TKCChessThread }

  TKCChessThread = class(TThread)
  protected
    procedure Execute; override;
  public
    AFrom, ATo: TPoint;
    PlayerColor, ComputerColor: PieceColorType;
  end;

{ INIT.PAS }
procedure InitPossibleMoves;
procedure StartupInitialize;
{ MOVES.PAS }
procedure AttackedBy (row, col : RowColType; var Attacked, _Protected : integer);
procedure GenMoveList (Turn : PieceColorType; var Movelist : MoveListType);
procedure MakeMove (Movement : MoveType; PermanentMove : boolean; var Score : integer);
procedure UnMakeMove (var Movement: Movetype);
procedure TrimChecks (Turn : PieceColorType; var MoveList : MoveListType);
procedure RandomizeMoveList (var MoveList : MoveListType);
procedure GotoMove (GivenMoveTo : integer);
{ SETUP.PAS }
procedure DefaultBoardSetPieces;
procedure DefaultBoard;
//procedure SetupBoard;
{ PLAY.PAS }
procedure GetComputerMove (Turn : PieceColorType; Display : boolean;
                             var HiMovement : MoveType; var Escape : boolean);
// procedure GetHumanMove (Turn : PieceColorType; var Movement : MoveType;
//                          var Escape : boolean);
//  procedure GetPlayerMove (var Movement : MoveType; var Escape : boolean);
//  procedure PlayGame;
//  procedure CheckFinishStatus;
//    procedure CheckHumanPawnPromotion (var Movement : MoveType);

implementation

{.$define KCCHESS_VERBOSE}

{*** include files ***}

//{$I MISC.PAS}     {*** miscellaneous functions ***}
{$I INIT.PAS}     {*** initialization of global variables ***}
//{$I DISPLAY.PAS}  {*** display-oriented routines ***}
//{$I INPUT.PAS}    {*** keyboard input routines ***}
{$I MOVES.PAS}    {*** move generation and making routines ***}
{$I SETUP.PAS}    {*** default board and custom setup routines ***}
{$I PLAY.PAS}     {*** computer thinking and player input routines ***}
//{$I MENU.PAS}     {*** main menu routines ***}

{ TKCChessThread }

procedure TKCChessThread.Execute;
var
  UserMovement, AIMovement: MoveType;
  Escape: boolean;
  Score: Integer;
  lMoved: Boolean;
  lAnimation: TChessMoveAnimation;
begin
  // initialization
  Escape := False;
  Score := 0;

  { First write the movement of the user }
  UserMovement.FromRow := AFrom.Y;
  UserMovement.FromCol := AFrom.X;
  UserMovement.ToRow := ATo.Y;
  UserMovement.ToCol := ATo.X;
  UserMovement.PieceMoved.image := TKCChessModule.FPChessPieceToKCChessImage(ATo);
  UserMovement.PieceMoved.color := PlayerColor;
//                     HasMoved : boolean;
//                     ValidSquare : boolean;
  UserMovement.PieceTaken.image := BLANK;
  UserMovement.PieceTaken.color := ComputerColor;
//                     HasMoved : boolean;
//                     ValidSquare : boolean;
  UserMovement.MovedImage := BLANK;

  MakeMove(UserMovement, True, Score);

  { Now get the computer move }
  GetComputerMove(ComputerColor, False, AIMovement, Escape);
  MakeMove(AIMovement, True, Score);

  { And write it to our board }

  lAnimation := TChessMoveAnimation.Create;
  lAnimation.AFrom := Point(AIMovement.FromCol, AIMovement.FromRow);
  lAnimation.ATo := Point(AIMovement.ToCol, AIMovement.ToRow);
  vChessDrawer.AddAnimation(lAnimation);

{  lMoved := vChessGame.MovePiece(
    Point(AIMovement.FromCol, AIMovement.FromRow),
    Point(AIMovement.ToCol, AIMovement.ToRow));

  if not lMoved then raise Exception.Create(Format('Moving failed from %s to %s',
    [vChessGame.BoardPosToChessCoords(AFrom), vChessGame.BoardPosToChessCoords(ATo)]));}
end;

{ TKCChessModule }

class function TKCChessModule.FPChessPieceToKCChessImage(APos: TPoint): PieceImageType;
begin
  case vChessGame.Board[APos.X][APos.Y] of
  ctEmpty:              Result := BLANK;
  ctWPawn, ctBPawn:     Result := PAWN;
  ctWKnight, ctBKnight: Result := KNIGHT;
  ctWBishop, ctBBishop: Result := BISHOP;
  ctWRook, ctBRook:     Result := ROOK;
  ctWQueen, ctBQueen:   Result := QUEEN;
  ctWKing, ctBKing:     Result := KING;
  end;
end;

class function TKCChessModule.FPChessPieceToKCChessColor(APos: TPoint): PieceColorType;
begin
  case vChessGame.Board[APos.X][APos.Y] of
  ctEmpty, ctWPawn, ctWKnight, ctWBishop, ctWRook, ctWQueen, ctWKing: Result := C_WHITE;
  ctBPawn, ctBKnight, ctBBishop, ctBRook, ctBQueen, ctBKing:          Result := C_BLACK;
  end;
end;

constructor TKCChessModule.Create;
begin
  inherited Create;

  Name := 'mod_kcchess.pas';
  SelectionDescription := 'Play against the computer - KCChess Engine';
  PlayingDescription := 'Playing against the computer - KCChess Engine';
  Kind := cmkAgainstComputer;
end;

procedure TKCChessModule.CreateUserInterface;
begin
  textDifficulty := TStaticText.Create(nil);
  textDifficulty.SetBounds(10, 10, 180, 50);
  textDifficulty.Caption := 'Difficulty (3=easiest, 9=hardest and slowest)';

  spinDifficulty := TSpinEdit.Create(nil);
  spinDifficulty.SetBounds(200, 20, 50, 50);
  spinDifficulty.Value := 6;
  spinDifficulty.MinValue := 3;
  spinDifficulty.MaxValue := 9;
end;

procedure TKCChessModule.ShowUserInterface(AParent: TWinControl);
begin
  textDifficulty.Parent := AParent;
  spinDifficulty.Parent := AParent;
end;

procedure TKCChessModule.HideUserInterface();
begin
  textDifficulty.Parent := nil;
  spinDifficulty.Parent := nil;
end;

procedure TKCChessModule.FreeUserInterface();
begin
  textDifficulty.Free;
  spinDifficulty.Free;
end;

procedure TKCChessModule.PrepareForGame;
begin
  StartupInitialize();
  DefaultBoard();

  Game.GameFinished := false;

  if vChessGame.FirstPlayerIsWhite then
  begin
    ComputerColor := C_BLACK;
    PlayerColor := C_WHITE;
  end
  else
  begin
    ComputerColor := C_WHITE;
    PlayerColor := C_BLACK;
  end;

  Player[ComputerColor].LookAhead := spinDifficulty.Value;
  if ComputerColor = C_WHITE then
  begin
    KCChessThread := TKCChessThread.Create(True);
    KCChessThread.FreeOnTerminate := True;
    KCChessThread.PlayerColor := PlayerColor;
    KCChessThread.ComputerColor := ComputerColor;
    KCChessThread.Resume();
  end;
end;

function TKCChessModule.GetSecondPlayerName: ansistring;
begin
  Result := 'KCChess Engine';
end;

procedure TKCChessModule.HandleOnMove(AFrom, ATo: TPoint);
begin
  KCChessThread := TKCChessThread.Create(True);
  KCChessThread.FreeOnTerminate := True;
  KCChessThread.AFrom := AFrom;
  KCChessThread.ATo := ATo;
  KCChessThread.PlayerColor := PlayerColor;
  KCChessThread.ComputerColor := ComputerColor;
  KCChessThread.Resume();
end;

initialization
  RegisterChessModule(TKCChessModule.Create);
end.

