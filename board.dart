import 'filestream.dart';
import 'pieces.dart';
import 'dart:core' hide print;
import 'dart:core' as core show print;

class Board {
  static const int width = 11; // 11th for EOL
  static const int height = 8;

  Board.from(String filename) {
    FileStream file = FileStream("in.khet");
  	ys: for (int y = 0; true; y++) {
      String line = file.getLine();
      xs: for (int x = 0; true; x+=3) {
        Player player = line[x] == "[" ? Player.red : Player.white;
        switch (line[x + 1] + line[x + 2]) {
          case "__":
            ///print("$x $y is EmptyPiece");
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.none);
            break;
          case "/\\":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.obelisk, player);
            break;
          case "PH":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.pharaoh, player);
            break;
          case "O2":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.stackedobelisk, player);
            break;
          case "|\\":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.trmirror, player);
            break;
          case "\\|":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.blmirror, player);
            break;
          case "|/":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.rbmirror, player);
            break;
          case "/|":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.ltmirror, player);
            break;
          case "//":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.ltrbdjed, player);
            break;
          case "\\\\":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.trbldjed, player);
            break;
          case "=|":
            //print("x=${(x/3).round()} y=$y width=$width position=${(y * width) + (x / 3).round()}(eol)")  ;
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.eol);
            break xs;
          case " |":
            _board[((y * width) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.eol);
            break ys;
          default:
            throw UnsupportedError("Unknown piece \"${line[x] + line[x + 1] + line[x + 2]}\" at line ${y + 1} column ${x + 1}");
        }
      }
    }
  }

  Iterable<Piece> get board => _board;
  final List<Piece> _board = List(height * width);

  Piece pieceAt(Position position) => _board[position.y * width + position.x];

  void print() {
    int y = 0;
    core.print("\x1b[2J  00 01 02 03 04 05 06 07 08 09\n0|${board.fold('', (String x, Piece piece) {
       if (piece is EOL) {
         y++;
         x += "\n$y|";
       }
       return x+''+(piece.coloredToken == "|=|" ? "" : piece.coloredToken + "|");
    })} WALL...");
  }

  static const List<Pair<Position, Pair<Action, Action>>> moveActions = <Pair<Position, Pair<Action, Action>>>[
    Pair(Position(-1, -1), Pair(Action.moveNW, Action.unstackNW)),
    Pair(Position(-1,  0), Pair(Action.moveW,  Action.unstackW)),
    Pair(Position(-1,  1), Pair(Action.moveSW, Action.unstackSW)),
    Pair(Position( 0, -1), Pair(Action.moveN,  Action.unstackN)),
    Pair(Position( 0,  1), Pair(Action.moveS,  Action.unstackS)),
    Pair(Position( 1, -1), Pair(Action.moveNE, Action.unstackNE)),
    Pair(Position( 1,  0), Pair(Action.moveE,  Action.unstackE)),
    Pair(Position( 1,  1), Pair(Action.moveSE, Action.unstackSE)),
  ];

  Iterable<Action> validActions(Piece piece) sync* {
    Position currentPosition = piece.position;
    for (Pair<Position, Pair<Action, Action>> move in moveActions) {
      Position otherPosition = currentPosition.apply(move.a);
      if (otherPosition.x < 0 || otherPosition.x >= width || otherPosition.y < 0 || otherPosition.y >= height)
        continue;
      Piece otherPiece = pieceAt(otherPosition);
      if (piece.canMoveTo(otherPiece)) {
        yield move.b.a;
        if (piece.canUnstack())
          yield move.b.b;
      }
    }
    if (piece.canRotate()) {
      yield Action.rotateClockwise;
      yield Action.rotateAnticlockwise;
    }
  }

  void apply(Piece piece, Action action) {
    switch (action) {
      case Action.moveN:
        return _applyMove(piece, Position(0, -1), unstack: false);
      case Action.moveNE:
        return _applyMove(piece, Position(1, -1), unstack: false);
      case Action.moveE:
        return _applyMove(piece, Position(1, 0), unstack: false);
      case Action.moveSE:
        return _applyMove(piece, Position(1, 1), unstack: false);
      case Action.moveS: 
        return _applyMove(piece, Position(0, 1), unstack: false);
      case Action.moveSW:
        return _applyMove(piece, Position(-1, 1), unstack: false);
      case Action.moveW:
        return _applyMove(piece, Position(-1, 0), unstack: false);
      case Action.moveNW:
        return _applyMove(piece, Position(-1, -1), unstack: false);
      case Action.unstackN:
        return _applyMove(piece, Position(0, -1), unstack: true);
      case Action.unstackNE:
        return _applyMove(piece, Position(1, -1), unstack: true);
      case Action.unstackE:
        return _applyMove(piece, Position(1, 0), unstack: true);
      case Action.unstackSE:
        return _applyMove(piece, Position(1, 1), unstack: true);
      case Action.unstackS: 
        return _applyMove(piece, Position(0, 1), unstack: true);
      case Action.unstackSW:
        return _applyMove(piece, Position(-1, 1), unstack: true);
      case Action.unstackW:
        return _applyMove(piece, Position(-1, 0), unstack: true);
      case Action.unstackNW:
        return _applyMove(piece, Position(-1, -1), unstack: true);
      case Action.rotateClockwise:
        return _replacePiece(piece.rotateClockwise());
      case Action.rotateAnticlockwise:
        return _replacePiece(piece.rotateAnticlockwise());
    }
    throw UnsupportedError("");
  }

  void _applyMove(Piece piece, Position delta, { bool unstack }) {
    Position otherPosition = piece.position.apply(delta);
    Piece otherPiece = pieceAt(otherPosition);
    Pair<Piece, Piece> newPieces = piece.move(otherPiece, unstack);
    _replacePiece(newPieces.a);
    _replacePiece(newPieces.b);
  }

  void _replacePiece(Piece newPiece) {
    _board[newPiece.position.y * width + newPiece.position.x] = newPiece;
  }

  void fireLaser(Player player) {
    Direction startDirection = player == Player.red ? Direction.down : Direction.up; 
    var laserEnd = _path(player == Player.red ? Position(0, -1) : Position(9, 8), startDirection, board);
    var offBoard = false;
    if (laserEnd.x == width) {
      offBoard = true;
    }
    if (laserEnd.x < 0) {
      offBoard = true;
    }
    if (laserEnd.y == height) {
      offBoard = true;
    }
    if (laserEnd.y < 0) {
      offBoard = true;
    }
    Piece piece = offBoard ? EOL(laserEnd) : _board[(laserEnd.y * width) + laserEnd.x];
    if (!offBoard) {
      core.print('Shot piece at (${laserEnd.x}, ${laserEnd.y})');
      _board[(laserEnd.y * width) + laserEnd.x] = piece.wasShot();
    } else {
      core.print('Off board at (${laserEnd.x}, ${laserEnd.y})');
    }
  }

  Position _path(Position laser, Direction startDirection, List<Piece> board) {
    bool done = false;
    Position position = EmptyPiece(laser).handleLaser(startDirection).a;
    Direction direction = startDirection;
    while(!done) {
      Piece piece = board[(position.y * width) + position.x];
      //print("$piece: ${piece?.coloredToken} at ${position.x}, ${position.y} (${(position.y * width) + position.x})");
      Pair<Position, Direction> pair = piece.handleLaser(direction);
      position = pair.a;
      direction = pair.b;
      if (position.x == width) {
        done = true;
      }
      if (position.x < 0) {
        done = true;
      }
      if (position.y == height) {
        done = true;
      }
      if (position.y < 0) {
        done = true;
      }
      if (!done && board[(position.y * width) + position.x] == piece) {
        done = true;
      }
    }
    return position;
  }
}
