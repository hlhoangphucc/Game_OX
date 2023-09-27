import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CountdownScreen extends StatefulWidget {
  final String email;

  CountdownScreen({required this.email});
  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _seconds = 15; // Thời gian đếm ngược ban đầu
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
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

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          // Đếm ngược đã hoàn thành, điều hướng về màn hình trước đó
          removeFromWaitingList(widget.email);
          Navigator.pop(context);
          _timer.cancel();
        }
      });
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
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đang Tìm Người Chơi',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          Text(
            '$_seconds giây',
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
        ],
      )),
    ));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
