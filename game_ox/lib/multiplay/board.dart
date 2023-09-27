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

class GamePuzMultiPlayer extends StatefulWidget {
  @override
  State<GamePuzMultiPlayer> createState() => _GamePuzMultiPlayerState();
}

class _GamePuzMultiPlayerState extends State<GamePuzMultiPlayer> {
  int rowLength = 10;
  int columLength = 11;
  int currentScore = 0;
  int frameRateMilliseconds = 500;
  int levelThreshold = 10;
  bool gameOver = false;
  bool gameOverFlag = false;

  final _auth = FirebaseAuth.instance;

  String id = '';
  late DatabaseReference _database;
  bool isGameLoopActive = true;
  //current tetris piece
  Piece currentPiece = Piece(type: Tetromino.T);
  String email = '';
  String emailP1 = '';
  String emailP2 = '';
  int scoreP1 = 0;
  int scoreP2 = 0;
  String state = '';
  String stateP1 = '';
  String stateP2 = '';

  final DatabaseReference gamePairsRef =
      FirebaseDatabase.instance.reference().child('game_pairs');
  @override
  void initState() {
    super.initState();
    startGame();
    listenToGamePairs();
    listenState();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        id = user.uid;
        _database = FirebaseDatabase.instance.ref().child('users/${id}/email');
        _database.onValue.listen((event) {
          final dynamic value = event.snapshot.value;

          if (value != null && !gameOverFlag) {
            // Ensure the value is not null before updating highscore
            setState(() {
              fetchGameData(value);
            });
          }
        });
      } else {
        final snackBar = SnackBar(
          content: Text('Đăng nhập không thành công!!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  void listenToGamePairs() {
    gamePairsRef.onChildChanged.listen((event) {
      final key = event.snapshot.key;
      final value = event.snapshot.value;

      if (value != null && value is Map) {
        if (value['player1'] != null) {
          // Cập nhật điểm số của người chơi 1 (Player 1)
          final player1Score = value['player1']['score'];
          setState(() {
            scoreP1 = player1Score;
          });
        }

        if (value['player2'] != null) {
          // Cập nhật điểm số của người chơi 2 (Player 2)
          final player2Score = value['player2']['score'];
          setState(() {
            scoreP2 = player2Score;
          });
        }
      }
    });
  }

  void listenState() {
    gamePairsRef.onChildChanged.listen((event) {
      final key = event.snapshot.key;
      final value = event.snapshot.value;

      if (value != null && value is Map) {
        if (value['player1'] != null) {
          final statePlayer1 = value['player1']['state'];
          final player1Score = value['player1']['score'];
          final player1Email = value['player1']['email'];
          setState(() {
            stateP1 = statePlayer1;
            scoreP1 = player1Score;
            emailP1 = player1Email;
          });
        }

        if (value['player2'] != null) {
          final statePlayer2 = value['player2']['state'];
          final player2Score = value['player2']['score'];
          final player2Email = value['player2']['email'];
          setState(() {
            stateP2 = statePlayer2;
            scoreP2 = player2Score;
            emailP2 = player2Email;
          });
        }
        if (stateP1 == stateP2) {
          if (scoreP1 > scoreP2) {
            if (emailP2 == email) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Kết Thúc'),
                  content: Row(
                    children: [
                      Text('Your Lose!!'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => homePage()),
                        );
                        Navigator.pop(context);
                      },
                      child: Text('Wait'),
                    ),
                  ],
                ),
              );
            } else if (emailP1 == email) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Kết Thúc'),
                  content: Row(
                    children: [
                      Text('Your Win!!'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => homePage()),
                        );
            
                      },
                      child: Text('Wait'),
                    ),
                  ],
                ),
              );
            }
          } else {
            if (emailP2 == email) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Kết Thúc'),
                  content: Row(
                    children: [
                      Text('Your Win!!'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => homePage()),
                        );
                      },
                      child: Text('Wait'),
                    ),
                  ],
                ),
              );
            } else if (emailP1 == email) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Kết Thúc'),
                  content: Row(
                    children: [
                      Text('Your Lose!!'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => homePage()),
                        );
                        Navigator.pop(context);
                      },
                      child: Text('Wait'),
                    ),
                  ],
                ),
              );
            }
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Thông Báo'),
              content: Row(
                children: [
                  Text('Đợi người chơi còn lại'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Đợi'),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  void fetchGameData(String userEmail) {
    gamePairsRef.once().then((DatabaseEvent snap) {
      final data = snap.snapshot.value;
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value != null && value is Map) {
            if (value['player1'] != null &&
                value['player1']['email'] == userEmail) {
              email = value['player1']['email'];
              state = value['player1']['state'];
            }
            if (value['player2'] != null &&
                value['player2']['email'] == userEmail) {
              email = value['player2']['email'];
              state = value['player2']['state'];
            }
          }
        });
      } else {
        print('Không tìm thấy dữ liệu trong node game_pairs.');
      }
    }).catchError((error) {
      print('Lỗi khi đọc dữ liệu: $error');
    });
  }

  void _updateHighScore(int newHighScore) {
    if (email.isNotEmpty) {
      gamePairsRef.once().then((DatabaseEvent snap) {
        final data = snap.snapshot.value;
        if (data != null && data is Map) {
          data.forEach((key, value) {
            if (value != null && value is Map) {
              if (value['player1'] != null &&
                  value['player1']['email'] == email) {
                String gameId = key;
                DatabaseReference player1Ref =
                    gamePairsRef.child(gameId).child('player1');

                player1Ref.update({'score': newHighScore}).then((_) {
                  print('Điểm số đã được cập nhật thành công cho $email');
                }).catchError((error) {
                  print('Lỗi khi cập nhật điểm số: $error');
                });
              }
              if (value['player2'] != null &&
                  value['player2']['email'] == email) {
                String gameId = key;
                DatabaseReference player2Ref =
                    gamePairsRef.child(gameId).child('player2');

                player2Ref.update({'score': newHighScore}).then((_) {
                  print('Điểm số đã được cập nhật thành công cho $email');
                }).catchError((error) {
                  print('Lỗi khi cập nhật điểm số: $error');
                });
              }
            }
          });
        } else {
          print('Không tìm thấy dữ liệu trong node game_pairs.');
        }
      });
    } else {
      print('Email của người chơi hiện tại không được xác định.');
    }
  }

  void updateGameState(String newState) {
    if (email.isNotEmpty) {
      gamePairsRef.once().then((DatabaseEvent snap) {
        final data = snap.snapshot.value;
        if (data != null && data is Map) {
          data.forEach((key, value) {
            if (value != null && value is Map) {
              if (value['player1'] != null &&
                  value['player1']['email'] == email) {
                String gameId = key;
                DatabaseReference player1Ref =
                    gamePairsRef.child(gameId).child('player1');

                player1Ref.update({'state': newState}).then((_) {
                  print('Trạng thái đã được cập nhật thành công cho $email');
                }).catchError((error) {
                  print('Lỗi khi cập nhật trạng thái: $error');
                });
              }
              if (value['player2'] != null &&
                  value['player2']['email'] == email) {
                String gameId = key;
                DatabaseReference player2Ref =
                    gamePairsRef.child(gameId).child('player2');

                player2Ref.update({'state': newState}).then((_) {
                  print('Trạng thái đã được cập nhật thành công cho $email');
                }).catchError((error) {
                  print('Lỗi khi cập nhật trạng thái: $error');
                });
              }
            }
          });
        } else {
          print('Không tìm thấy dữ liệu trong node game_pairs.');
        }
      });
    } else {
      print('Email của người chơi hiện tại không được xác định.');
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
          updateGameState('gameover');
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
        title: Text('Kết Thúc'),
        content: Row(
          children: [
            Text('Your score is: ' + scoreP1.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateHighScore(currentScore);
              Navigator.pop(context);
            },
            child: Text('Wait'),
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
    gameOverFlag = false;
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
        _updateHighScore(currentScore);
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
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    homePage()),
                                          );
                                          Navigator.pop(context);
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
                        'Score P1: ' + scoreP1.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Score P2: ' + scoreP2.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        email,
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
