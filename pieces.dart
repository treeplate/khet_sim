import 'dart:io';

enum Player { red, white }

enum PieceType {
  none, pharaoh, obelisk, stackedobelisk, ltmirror, trmirror, rbmirror, blmirror, ltrbdjed, trbldjed, eol
}

enum Direction {
  left, right, up, down
}

enum Action {
  moveN, moveNE, moveE, moveSE, moveS, moveSW, moveW, moveNW,
  unstackN, unstackNE, unstackE, unstackSE, unstackS, unstackSW, unstackW, unstackNW,
  rotateClockwise, rotateAnticlockwise,
}

class Pair<A, B> {
  const Pair(this.a, this.b);
  final A a;
  final B b;
}

class Position {
  const Position(this.x, this.y);
  final int x;
  final int y;

  Position apply(Position other) => Position(x + other.x, y + other.y);
}

class GameOver implements Exception {
  GameOver(this.message);
  final String message;
  String toString() => message;
}

abstract class Piece {
  Piece._(this.position, this.player);

  final Position position;

  final Player player;

  factory Piece(Position position, PieceType type, [ Player player]) {
    switch (type) {
      case PieceType.none:
        return EmptyPiece(position);
      case PieceType.obelisk:
        return Obelisk(position, player, 1);
      case PieceType.stackedobelisk:
        return Obelisk(position, player, 2);
      case PieceType.pharaoh:
        return Pharaoh(position, player);
      case PieceType.ltmirror:
        return LTMirror(position, player);
      case PieceType.trmirror:
        return TRMirror(position, player);
      case PieceType.rbmirror:
        return RBMirror(position, player);
      case PieceType.blmirror:
        return BLMirror(position, player);
      case PieceType.ltrbdjed:
        return LTRBDjed(position, player);
      case PieceType.trbldjed:
        return TRBLDjed(position, player);
      case PieceType.eol:
        return EOL(position);
    }
  }

  Pair<Position, Direction> handleLaser(Direction direction);

  String get plainToken => "ER";

  String get coloredToken {
    switch (player) {
      case Player.red: return "\u001b[31m$plainToken\u001b[0m";
      case Player.white: return plainToken;
    }
    return plainToken;
  }

  bool canMoveTo(Piece piece) => piece is EmptyPiece;
  bool canRotate() => false;
  bool canUnstack() => false;
  Piece wasShot() => EmptyPiece(position);

  Pair<Piece, Piece> move(Piece other, bool unstack);
  Piece rotateClockwise() => throw UnsupportedError("");
  Piece rotateAnticlockwise() => throw UnsupportedError("");
}

class EmptyPiece extends Piece {
  EmptyPiece(Position position) : super._(position, null);

  Pair<Position, Direction> handleLaser(Direction direction) {
    Position newPosition;
    //print("EmptyPiece at ${position.x + 1}, ${position.y + 1} got signal from $direction");
    switch (direction) {
      case Direction.up:
        newPosition = Position(position.x, position.y - 1);
        break;
      case Direction.down:
        newPosition = Position(position.x, position.y + 1);
        break;
      case Direction.left:
        newPosition = Position(position.x - 1, position.y);
        break;
      case Direction.right:
        newPosition = Position(position.x + 1, position.y);
    }
    return Pair(newPosition, direction);
  }

  String toString() => "nothing";

  String get coloredToken => "__";

  bool canMoveTo(Piece piece) => false;
  Pair<Piece, Piece> move(Piece other, bool unstack) => throw UnsupportedError("");
}

class Obelisk extends Piece {
  Obelisk(Position position, Player player, this.stack) : super._(position, player);
  
  final int stack;

  Pair<Position, Direction> handleLaser(Direction direction) {
    return Pair(Position(position.x, position.y), direction);
  }
  
  Piece wasShot() {
    if (stack == 1)
      return super.wasShot();
    return Obelisk(position, player, stack-1);
  }

  String toString() => "obelisk: stack $stack";
  String get plainToken => "O$stack";

  bool canMoveTo(Piece piece) => piece is EmptyPiece ||piece is Obelisk;
  bool canUnstack() => stack > 1;

  Pair<Piece, Piece> move(Piece other, bool unstack) {
    if (unstack && stack <= 1)
      throw UnsupportedError("");
    if (other is Obelisk) {
      if (unstack)
        return Pair(Obelisk(position, player, stack-1), Obelisk(other.position, player, other.stack+1));
      return Pair(EmptyPiece(position), Obelisk(other.position, player, other.stack+stack));
    }
    if (other is! EmptyPiece)
      throw UnsupportedError("");
    if (unstack)
      return Pair(Obelisk(position, player, stack-1), Obelisk(other.position, player, 1));
    return Pair(EmptyPiece(position), Obelisk(other.position, player, stack));
  }
}

class Pharaoh extends Piece {
  Pharaoh(Position position, Player player) : super._(position, player);

  Pair<Position, Direction> handleLaser(Direction direction) {
    return Pair(Position(position.x, position.y), direction);
  }

  Piece wasShot() {
    switch (player) {
      case Player.red: throw GameOver('White wins!');
      case Player.white: throw GameOver('Red wins!');
    }
  }

  String toString() => "pharaoh";
  String get plainToken => "PH";

  Pair<Piece, Piece> move(Piece other, bool unstack) {
    if (unstack)
       throw UnsupportedError("");
    if (other is! EmptyPiece)
       throw UnsupportedError("");
    return Pair(Pharaoh(other.position, player), EmptyPiece(position));
  }
}

abstract class Mirror extends Piece {
  Mirror(Position position, Player player) : super._(position, player);

  bool canRotate() => true;

  Pair<Piece, Piece> move(Piece other, bool unstack) {
    if (unstack)
       throw UnsupportedError("");
    if (other is! EmptyPiece)
       throw UnsupportedError("");
    return Pair(moveTo(other.position), EmptyPiece(position));
  }

  Mirror moveTo(Position position);
}

class LTMirror extends Mirror {
  LTMirror(Position position, Player player) : super(position, player);

  Pair<Position, Direction> handleLaser(Direction direction) {
    switch (direction) {
      case Direction.right:
        return Pair(Position(position.x, position.y - 1), Direction.up);
      case Direction.down:
        return Pair(Position(position.x - 1, position.y), Direction.left);
      default:
        return Pair(Position(position.x, position.y), direction);
    }
  }

  String toString() => "north-west mirror";

  String get plainToken => "/|";

  Mirror moveTo(Position position) => LTMirror(position, player);

  Piece rotateClockwise() {
    return TRMirror(position, player);
  }

  Piece rotateAnticlockwise() {
    return BLMirror(position, player);
  }
}

class TRMirror extends Mirror {
  TRMirror(Position position, Player player) : super(position, player);

  Pair<Position, Direction> handleLaser(Direction direction) {
    switch (direction) {
      case Direction.left:
        return Pair(Position(position.x, position.y - 1), Direction.up);
      case Direction.down:
        return Pair(Position(position.x + 1, position.y), Direction.right);
      default:
        return Pair(Position(position.x, position.y), direction);
    }
  }

  String toString() => "north-east mirror";

  String get plainToken => "|\\";

  Mirror moveTo(Position position) => TRMirror(position, player);

  Piece rotateClockwise() {
    return RBMirror(position, player);
  }

  Piece rotateAnticlockwise() {
    return LTMirror(position, player);
  }
}

class RBMirror extends Mirror {
  RBMirror(Position position, Player player) : super(position, player);

  Pair<Position, Direction> handleLaser(Direction direction) {
    switch (direction) {
      case Direction.left:
        return Pair(Position(position.x, position.y + 1), Direction.down);
      case Direction.up:
        return Pair(Position(position.x + 1, position.y), Direction.right);
      default:
        return Pair(Position(position.x, position.y), direction);
    }
  }

  String toString() => "south-east mirror";

  String get plainToken => "|/";

  Mirror moveTo(Position position) => RBMirror(position, player);

  Piece rotateClockwise() {
    return BLMirror(position, player);
  }

  Piece rotateAnticlockwise() {
    return TRMirror(position, player);
  }
}

class BLMirror extends Mirror {
  BLMirror(Position position, Player player) : super(position, player);

  Pair<Position, Direction> handleLaser(Direction direction) {
    switch (direction) {
      case Direction.right:
        return Pair(Position(position.x, position.y + 1), Direction.down);
      case Direction.up:
        return Pair(Position(position.x - 1, position.y), Direction.left);
      default:
        return Pair(Position(position.x, position.y), direction);
    }
  }

  String toString() => "south-west mirror";

  String get plainToken => "\\|";

  Mirror moveTo(Position position) => BLMirror(position, player);

  Piece rotateClockwise() {
    return LTMirror(position, player);
  }

  Piece rotateAnticlockwise() {
    return RBMirror(position, player);
  }
}

abstract class Djed extends Piece {
  Djed(Position position, Player player) : super._(position, player);

  bool canMoveTo(Piece piece) {
    return piece is EmptyPiece
        || piece is Obelisk
        || piece is Mirror;
  }

  bool canRotate() => true;

  Pair<Piece, Piece> move(Piece other, bool unstack) {
    if (unstack)
       throw UnsupportedError("");
    if (other is EmptyPiece)
      return Pair(moveTo(other.position), EmptyPiece(position));
    if (other is Obelisk)
      return Pair(moveTo(other.position), Obelisk(position, other.player, other.stack));
    if (other is Mirror)
      return Pair(moveTo(other.position), other.moveTo(position));
    throw UnsupportedError("");
  }

  Djed moveTo(Position position);
}

class LTRBDjed extends Djed {
  LTRBDjed(Position position, Player player) : super(position, player);

  Pair<Position, Direction> handleLaser(Direction direction) {
    switch (direction) {
      case Direction.left:
        return Pair(Position(position.x, position.y + 1), Direction.down);
      case Direction.up:
        return Pair(Position(position.x + 1, position.y), Direction.right);
      case Direction.right:
        return Pair(Position(position.x, position.y - 1), Direction.up);
      case Direction.down:
        return Pair(Position(position.x - 1, position.y), Direction.left);
    }
  }

  String toString() => "north-west and south-east djed";

  String get plainToken => "//";

  Djed moveTo(Position position) => LTRBDjed(position, player);

  Piece rotateClockwise() {
    return TRBLDjed(position, player);
  }

  Piece rotateAnticlockwise() {
    return TRBLDjed(position, player);
  }
}

class TRBLDjed extends Djed {
  TRBLDjed(Position position, Player player) : super(position, player);

  Pair<Position, Direction> handleLaser(Direction direction) {
    switch (direction) {
      case Direction.right:
        return Pair(Position(position.x, position.y + 1), Direction.down);
      case Direction.up:
        return Pair(Position(position.x - 1, position.y), Direction.left);
      case Direction.left:
        return Pair(Position(position.x, position.y - 1), Direction.up);
      case Direction.down:
        return Pair(Position(position.x + 1, position.y), Direction.right);
    }
  }

  String toString() => "north-east and south-west djed";

  String get plainToken => "\\\\";

  Piece rotateClockwise() {
    return LTRBDjed(position, player);
  }

  Piece rotateAnticlockwise() {
    return LTRBDjed(position, player);
  }

  Djed moveTo(Position position) => TRBLDjed(position, player);
}

class EOL extends Piece {
  EOL(Position position) : super._(position, null);

  Pair<Position, Direction> handleLaser(Direction direction) {
    return Pair(Position(position.x, position.y), direction);
  }

  String toString() => "wall";

  String get plainToken => "|=|";

  Pair<Piece, Piece> move(Piece other, bool unstack) => throw UnsupportedError("");
  Piece wasShot() => this;
}