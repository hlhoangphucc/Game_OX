import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_quiz/piece.dart';
import 'package:game_quiz/pixel.dart';
import 'package:game_quiz/values.dart';

/*

GAME BOARD 

THIS IS A 2X2 GRID WITH NULL REPRESENTING AN EMPTY SPACE.
A NON EMPTY SPACE WILL THE COLOR TO REPRESENT THE LANDED PIECES


*/

List<List<Tetromino?>> gameBoard =
    List.generate(columLength, (i) => List.generate(rowLength, (j) => null));

class GamePuz extends StatefulWidget {
  @override
  State<GamePuz> createState() => _GamePuzState();
}

class _GamePuzState extends State<GamePuz> {
  int rowLength = 10;
  int columLength = 12;
  int currentScore = 0;

  bool gameOver = false;

  //current tetris piece
  Piece currentPiece = Piece(type: Tetromino.T);

  @override
  void initState() {
    super.initState();

    // start game when app starts
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();

    // frame refesh rate
    Duration frameRate = const Duration(milliseconds: 800);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        clearLines();
        //check landing
        checkLanding();
        // move current piece down

        if (gameOver) {
          timer.cancel();
          showGameOVerDiaLog();
        }
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  void showGameOVerDiaLog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Game Over'),
              content: Text('Your score is: $currentScore'),
              actions: [
                TextButton(
                    onPressed: () {
                      resetGame();
                      Navigator.pop(context);
                    },
                    child: Text('Play Again'))
              ],
            ));
  }

  void resetGame() {
    gameBoard = List.generate(
        columLength, (i) => List.generate(rowLength, (j) => null));

    gameOver = false;
    currentScore = 0;

    createNewPiece();
    startGame();
  }
  // check for collision in a future position
  // return true -> there is a collision
  // return false -> there is no collision

  bool checkCollision(Direction direction) {
    // loop through each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      //calculate the row and column of the current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = (currentPiece.position[i] % rowLength);

      // adjust the row and col based on the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }
      // Check if the piece is out of bounds (either too low or too far to the left or right)
      if (row >= columLength || col < 0 || col >= rowLength) {
        return true;
      }
      // Check if the position is occupied on the game board
      if (row >= 0 && col >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    // if no collisions are detected, return false
    return false;
  }

  void checkLanding() {
    // if going down is occupied
    if (checkCollision(Direction.down)) {
      // mark position as occupied on the gameboard
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      createNewPiece();
    }
  }

  void createNewPiece() {
    Random rand = Random();

    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  void clearLines() {
    for (int row = columLength - 1; row >= 0; row--) {
      bool rowIsFull = true;

      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] = List.generate(row, (index) => null);

        currentScore++;
      }
    }
  }

  bool isGameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: GridView.builder(
                  itemCount: rowLength * columLength,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowLength),
                  itemBuilder: (context, index) {
                    int row = (index / rowLength).floor();
                    int col = index % rowLength;
                    if (currentPiece.position.contains(index)) {
                      return Pixel(color: Colors.yellow);
                    } else if (gameBoard[row][col] != null) {
                      final Tetromino? tetrominoType = gameBoard[row][col];
                      return Pixel(color: tetrominoColors[tetrominoType]);
                    } else {
                      return Pixel(color: Colors.grey[900]);
                    }
                  }),
            ),
            Text(
              'Score: ' + currentScore.toString(),
              style: TextStyle(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: moveLeft,
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                  ),
                  IconButton(
                      onPressed: rotatePiece,
                      icon: Icon(Icons.rotate_right),
                      color: Colors.white),
                  IconButton(
                      onPressed: moveRight,
                      icon: Icon(Icons.arrow_forward_ios),
                      color: Colors.white)
                ],
              ),
            )
          ],
        ));
  }
}
