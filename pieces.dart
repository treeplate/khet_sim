import 'dart:io';
enum PieceType {
  none, obelisk, ltmirror, trmirror, rbmirror, blmirror, ltrbdjed, trbldjed
}
enum Direction {
  left, right, up, down
}
class Pair<A, B> {
  const Pair(this.a, this.b);
  final A a;
  final B b;
}
class Position {
  const Position(this.x, this.y);
  final  int x;
  final  int y;
}
abstract class Piece {
  Piece._Piece(this.pos);
  final Position pos;
  factory Piece(Position position, PieceType type) {
    switch(type) {
      case PieceType.none:
        return EmptyPiece(position);
      case PieceType.obelisk:
        return Obelisk(position);
      case PieceType.ltmirror:
        return LTMirror(position);
      case PieceType.trmirror:
        return TRMirror(position);
      case PieceType.rbmirror:
        return RBMirror(position);
      case PieceType.blmirror:
        return BLMirror(position);
      case PieceType.ltrbdjed:
        return LTRBDjed(position);
      case PieceType.trbldjed:
        return TRBLDjed(position);
    }
  }
  Pair<Position, Direction> interact(Direction dir);
}

class EmptyPiece extends Piece {
  EmptyPiece(Position pos):super._Piece(pos);
  Pair<Position, Direction> interact(Direction dir) {
    Position npos;
    //print("EmptyPiece at ${pos.x + 1}, ${pos.y + 1} got signal from $dir");
    switch(dir) {
      case Direction.up:
        npos = Position(pos.x, pos.y - 1);
        break;
      case Direction.down:
        npos = Position(pos.x, pos.y + 1);
        break;
      case Direction.left:
        npos = Position(pos.x - 1, pos.y);
        break;
      case Direction.right:
        npos = Position(pos.x + 1, pos.y);
    }
    return Pair(npos, dir);
  }
}
class Obelisk extends Piece{
  Obelisk(Position pos):super._Piece(pos);
  Pair<Position, Direction> interact(Direction dir) {
    return Pair(Position(pos.x, pos.y), dir);
  }
}
class LTMirror extends Piece{
  LTMirror(Position pos):super._Piece(pos);
  Pair<Position, Direction> interact(Direction dir) {
    switch(dir) {
      case Direction.right:
        return Pair(Position(pos.x, pos.y - 1), Direction.up);
      case Direction.down:
        return Pair(Position(pos.x - 1, pos.y), Direction.left);
      default:
        return Pair(Position(pos.x, pos.y), dir);
    }
  }
}
class TRMirror extends Piece{
  TRMirror(Position pos):super._Piece(pos);
  Pair<Position, Direction> interact(Direction dir) {
    switch(dir) {
      case Direction.left:
        return Pair(Position(pos.x, pos.y - 1), Direction.up);
      case Direction.down:
        return Pair(Position(pos.x + 1, pos.y), Direction.right);
      default:
        return Pair(Position(pos.x, pos.y), dir);
    }
  }
}
class RBMirror extends Piece{
  RBMirror(Position pos):super._Piece(pos);
  Pair<Position, Direction> interact(Direction dir) {
    switch(dir) {
      case Direction.left:
        return Pair(Position(pos.x, pos.y + 1), Direction.down);
      case Direction.up:
        return Pair(Position(pos.x + 1, pos.y), Direction.right);
      default:
        return Pair(Position(pos.x, pos.y), dir);
    }
  }
}
class BLMirror extends Piece{
  BLMirror(Position pos):super._Piece(pos);
  Pair<Position, Direction> interact(Direction dir) {
    switch(dir) {
      case Direction.right:
        return Pair(Position(pos.x, pos.y + 1), Direction.down);
      case Direction.up:
        return Pair(Position(pos.x - 1, pos.y), Direction.left);
      default:
        return Pair(Position(pos.x, pos.y), dir);
    }
  }
}
class LTRBDjed extends Piece{
  LTRBDjed(Position pos):super._Piece(pos);
  Pair<Position, Direction> interact(Direction dir) {
    switch(dir) {
      case Direction.left:
        return Pair(Position(pos.x, pos.y + 1), Direction.down);
      case Direction.up:
        return Pair(Position(pos.x + 1, pos.y), Direction.right);
      case Direction.right:
        return Pair(Position(pos.x, pos.y - 1), Direction.up);
      case Direction.down:
        return Pair(Position(pos.x - 1, pos.y), Direction.left);
    }
  }
}
class TRBLDjed extends Piece{
  TRBLDjed(Position pos):super._Piece(pos);
  Pair<Position, Direction> interact(Direction dir) {
    switch(dir) {
      case Direction.right:
        return Pair(Position(pos.x, pos.y + 1), Direction.down);
      case Direction.up:
        return Pair(Position(pos.x - 1, pos.y), Direction.left);
      case Direction.left:
        return Pair(Position(pos.x, pos.y - 1), Direction.up);
      case Direction.down:
        return Pair(Position(pos.x + 1, pos.y), Direction.right);
    }
  }
}
class FileStream {
  FileStream(this.filepath);
  final String filepath;
  List<String> get fileAsList => File(filepath).readAsLinesSync();
  int line = 0;
  String getLine() {
    line++;
    return fileAsList[line - 1];
  }
}