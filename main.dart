import 'pieces.dart';
const w = 10;
const h = 8;
const laser =  Position(0, -1);
const startdir = Direction.down;

class Pear<A, B> {
  Pear(this.a, this.b);
  final A a;
  final B b;
}

void main() {
  FileStream file = FileStream("in.khet");
  List<Piece> board = List(h * w);
	for (int y = 0; y < h; y++) {
    String line = file.getLine();
    xs: for (int x = 0; true; x+=3) {
      switch(line[x] + line[x + 1] + line[x + 2]) {
        case "|  ":
          ///print("$x $y is EmptyPiece");
          board[((y * w) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.none);
          break;
        case "|/\\":
          board[((y * w) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.obelisk);
          break;
        case "|TR":
          board[((y * w) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.trmirror);
          break;
        case "|BL":
          board[((y * w) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.blmirror);
          break;
        case "|RB":
          board[((y * w) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.rbmirror);
          break;
        case "|LT":
          board[((y * w) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.ltmirror);
          break;
        case "|//":
          board[((y * w) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.ltrbdjed);
          break;
        case "|\\\\":
          board[((y * w) + (x / 3).round())] = Piece(Position((x/3).round(), y), PieceType.trbldjed);
          break;
        case "|=|":
          break xs;
        default:
          throw "Unknown piece ${line[x] + line[x + 1] + line[x + 2]} at line ${y + 1} column ${x + 1}";
      }
    }
  }
  bool done = false;
  Position pos = EmptyPiece(laser).interact(startdir).a;
  Direction dir = startdir;
  while(!done) {
    Piece piece = board[(pos.y * w) + pos.x];
    Pair<Position, Direction> pair = piece.interact(dir);
    pos = pair.a;
    dir = pair.b;
    print("${piece.runtimeType}");//${board[(pos.y * w) + pos.x].runtimeType}");
    if(pos.x == w) {
      done = true;
    }
    if(pos.x < 0) {
      done = true;
    }
    if(pos.y == h) {
      done = true;
    }
    if(pos.y < 0) {
      done = true;
    }
    if(!done && board[(pos.y * w) + pos.x] == piece) {
      done = true;
    }
  }
  print("${pos.x + 1}, ${pos.y + 1}");
}