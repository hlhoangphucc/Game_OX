import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:game_quiz/singleplay/piece.dart';
import 'package:game_quiz/singleplay/pixel.dart';
import 'package:game_quiz/singleplay/values.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:game_quiz/wel-log-regis-home/home.dart';

List<List<Tetromino?>> gameBoard =
    List.generate(columLength, (i) => List.generate(rowLength, (j) => null));

class GamePuz extends StatefulWidget {
  @override
  State<GamePuz> createState() => _GamePuzState();
}

class _GamePuzState extends State<GamePuz> {
  int rowLength = 10;
  int columLength = 11;
  int currentScore = 0;
  int frameRateMilliseconds = 500;
  int levelThreshold = 10;
  bool gameOver = false;

  final _auth = FirebaseAuth.instance;

  String id = '';
  late DatabaseReference _database;
  bool isGameLoopActive = true;
  //current tetris piece
  Piece currentPiece = Piece(type: Tetromino.T);

  @override
  void initState() {
    super.initState();

    // start game when app starts
    startGame();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        id = user.uid;
        _database = FirebaseDatabase.instance.ref().child('users/${id}');
      } else {
        final snackBar = SnackBar(
          content: Text('Đăng nhập không thành công!!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  void _updateHighScore(int newHighScore) {
    // ignore: unnecessary_null_comparison
    if (_database != null) {
      _database.update({'HighScore': newHighScore}).then((_) {
        print('Điểm số cao nhất đã được cập nhật thành công');
      }).catchError((error) {
        print('Lỗi khi cập nhật điểm số cao nhất: $error');
      });
    } else {
      print('Database reference is not initialized yet.');
    }
  }

  void startGame() {
    currentPiece.initializePiece();

    // frame refesh rate
    Duration frameRate = Duration(milliseconds: frameRateMilliseconds);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      if (!isGameLoopActive) {
        timer.cancel();
        return;
      }

      setState(() {
        clearLines();
        if (currentScore >= levelThreshold) {
          frameRateMilliseconds -= 50;
          levelThreshold += 10;
        }
        //check landing
        checkLanding();
        // move current piece down

        if (gameOver) {
          timer.cancel();
          showGameOVerDiaLog();
          isGameLoopActive = false;
        }
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  @override
  void dispose() {
    isGameLoopActive = false;
    super.dispose();
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
              _updateHighScore(currentScore);
              Navigator.pop(context);
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    gameBoard = List.generate(
        columLength, (i) => List.generate(rowLength, (j) => null));

    gameOver = false;
    currentScore = 0;

    createNewPiece();
    isGameLoopActive = true;
    startGame();
  }

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
            Container(
              height: MediaQuery.of(context).size.height / 4,
              margin: EdgeInsets.only(right: 10, left: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Transform.rotate(
                        angle: 3.14159265359, // Góc xoay 180 độ (rad)
                        child: IconButton(
                          onPressed: rotatePiece,
                          icon: IconButton(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Thông Báo'),
                                    content:
                                        Text('Bạn có chắc muốn thoát không ? '),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Không'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.popUntil(
                                              context, (route) => false);

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    homePage(),
                                              ));
                                          resetGame();
                                        },
                                        child: const Text('Có'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Image.asset('images/exit.png'),
                          ),
                          iconSize: MediaQuery.of(context).size.width / 7,
                        ),
                      ),
                      Text(
                        'Score: ' + currentScore.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: moveLeft,
                        icon: Image.asset('images/move.png'),
                        iconSize: MediaQuery.of(context).size.width / 8,
                        color: Colors.white,
                      ),
                      IconButton(
                          onPressed: rotatePiece,
                          icon: Image.asset('images/reset.png'),
                          iconSize: MediaQuery.of(context).size.width / 8,
                          color: Colors.white),
                      Transform.rotate(
                        angle: 3.14159265359,
                        child: IconButton(
                            onPressed: moveRight,
                            icon: Image.asset('images/move.png'),
                            iconSize: MediaQuery.of(context).size.width / 8,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
