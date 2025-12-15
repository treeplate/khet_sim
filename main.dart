import 'pieces.dart';
import 'board.dart';
import 'dart:io';

//const laser = Position(0, -1); red
//const laser = Position(9, 8); white
//const startdir = Direction.down; red
//const startdir = Direction.up; white

void main() {
  try {
    Board board = Board.from('in.khet');
    while (true) {
      playTurn(board, Player.red);
      playTurn(board, Player.white);
    }
  } on GameOver catch (status) {
    print('Game Over');
    print('Winner: $status');
  }
}

void playTurn(Board board, Player player) {
  board.print();
  var piece = selectPiece(board, player);
  var action = selectAction(board, player, piece);
  board.apply(piece, action);
  board.fireLaser(player);
}

Piece selectPiece(Board board, Player player) {
  print("\n");
  switch (player) {
    case Player.red: print('Red player!'); break;
    case Player.white: print('White player!'); break;
  }
  print("Select a piece. X coordinates are from 0 to ${Board.width - 2}, Y coordinates are from 0 to ${Board.height - 1}.");
  while (true) {
    print("Piece X coordinate:");
    int x = int.tryParse(stdin.readLineSync());
    print("Piece Y coordinate:");
    int y = int.tryParse(stdin.readLineSync());
    if (x != null && y != null && x >= 0 && x < Board.width - 1 && y >= 0 && y < Board.height) {
      Piece piece = board.pieceAt(Position(x, y));
      if (piece is EmptyPiece) {
        print("No piece at that location.");
      } else if (piece.player != player) {
        print("Piece does not belong to this player.");
      } else {
        return piece;
      }
    } else {
      print("Invalid position.");
    }
  }
}

Action selectAction(Board board, Player player, Piece piece) {
  Set<Action> validOptions = board.validActions(piece).toSet();
  List<Action> options = <Action>[];
  void consider(Action action, String label) {
    if (validOptions.contains(action)) {
      options.add(action);
      print('${options.length}: $label');
    }
  }
  print("Select an action for $piece. Options are:");
  consider(Action.moveN, 'move north');
  consider(Action.moveNE, 'move northeast');
  consider(Action.moveE, 'move east');
  consider(Action.moveSE, 'move southeast');
  consider(Action.moveS, 'move south');
  consider(Action.moveSW, 'move southwest');
  consider(Action.moveW, 'move west');
  consider(Action.moveNW, 'move northwest');
  consider(Action.unstackN, 'unstack north');
  consider(Action.unstackNE, 'unstack northeast');
  consider(Action.unstackE, 'unstack east');
  consider(Action.unstackSE, 'unstack southeast');
  consider(Action.unstackS, 'unstack south');
  consider(Action.unstackSW, 'unstack southwest');
  consider(Action.unstackW, 'unstack west');
  consider(Action.unstackNW, 'unstack northwest');
  consider(Action.rotateClockwise, 'rotate clockwise');
  consider(Action.rotateAnticlockwise, 'rotate anticlockwise');
  while (true) {
    print("Choose the number of the one you want:");
    int choice = int.tryParse(stdin.readLineSync());
    if (choice != null && (choice >= 1 || choice <= options.length)) {
      return options[choice-1];
    }
    print('Choice is not valid.');
  }
}

