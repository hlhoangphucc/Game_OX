import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:game_quiz/multiplay/board.dart';
import 'package:game_quiz/multiplay/coutdown.dart';

class WaitingListScreen extends StatefulWidget {
  @override
  _WaitingListScreenState createState() => _WaitingListScreenState();
}

class _WaitingListScreenState extends State<WaitingListScreen> {
  final _auth = FirebaseAuth.instance;
  late DatabaseReference _database;
  final DatabaseReference _waitingListRef =
      FirebaseDatabase.instance.reference().child('waiting_list');
  List<String> waitingList = [];
  bool isPairCreated = false;
  List<bool> eventStates = [];
  String id = '';
  String email = '';
  int n = 0;
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      eventStates.add(false);
    }
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        id = user.uid;
        print('User UID: $id');
        _database =
            FirebaseDatabase.instance.reference().child('users/${id}/email');
        _database.onValue.listen((event) {
          final dynamic value = event.snapshot.value;
          if (value != null) {
            // Ensure the value is not null before updating highscore
            setState(() {
              email = value;
            });
          }
        });
      } else {
        print('Đăng nhập không thành công ');
      }
    });
  }

  void addToWaitingList(String email) {
    _waitingListRef.push().set({'email': email});
    _waitingListRef.onValue.listen((event) {
      if (!eventStates[0] && !isPairCreated) {
        eventStates[0] = true;
      }

      if (event.snapshot != null &&
          event.snapshot.value is Map<dynamic, dynamic>) {
        final dynamic value = event.snapshot.value;
        Map<dynamic, dynamic> waitingListData = value;
        if (waitingListData != null) {
          setState(() {
            waitingList.clear();
            waitingListData.forEach((key, value) {
              String email = value['email'];
              waitingList.add(email);
            });
          });
          if (waitingList.length >= 2) {
            String player1 = email.toString();
            String player2 = waitingList[n];

            if (player1 != player2) {
              createGamePair(player1, player2);
              isPairCreated = true;
              removeFromWaitingList(player1);
              removeFromWaitingList(player2);
            } else {
              print('Hai người chơi giống nhau.');
            }
            n++;
          }
          if (n >= waitingList.length) {
            n = 0;
          }
        }
      } else {
        print('Dữ liệu danh sách chờ không hợp lệ.');
      }
    });
  }

  void createGamePair(String player1, String player2) {
    DatabaseReference _gamePairsRef =
        FirebaseDatabase.instance.reference().child('game_pairs');
    DatabaseReference gamePairRef = _gamePairsRef.push();
    gamePairRef.child('player1').set({
      'email': player1,
      'state': 'playing',
      'score': 0,
    });
    gamePairRef.child('player2').set({
      'email': player2,
      'state': 'playing',
      'score': 0,
    });
    print('Đã tạo cặp trò chơi giữa $player1 và $player2');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePuzMultiPlayer(),
      ),
    );
  }

  void removeFromWaitingList(String email) {
    DatabaseReference usersRef =
        FirebaseDatabase.instance.reference().child('waiting_list');
    usersRef
        .orderByChild('email')
        .equalTo(email)
        .once()
        .then((DatabaseEvent snap) {
      final data = snap.snapshot.value;
      if (data != null && data is Map) {
        data.forEach((key, userData) {
          usersRef.child(key).remove().then((_) {
            print('Đã xóa người dùng có email $email thành công.');
          }).catchError((error) {
            print('Lỗi khi xóa người dùng có email $email: $error');
          });
        });
      } else {
        print('Không tìm thấy người dùng có email $email.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              String userEmail = email;
              addToWaitingList(email);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CountdownScreen(email: email)),
              );
            },
            child: Text('Tìm trận'),
          ),
        ),
      ),
    );
  }
}
