import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:game_quiz/multiplay/board.dart';
import 'package:game_quiz/multiplay/findmatch.dart';
import 'package:game_quiz/ratings/ratings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_quiz/wel-log-regis-home/login.dart';

class homePage extends StatefulWidget {
  homePage({super.key});
  @override
  State<homePage> createState() => _homePage();
}

int highscore = 0;
late DatabaseReference _database;

class _homePage extends State<homePage> {
  final _auth = FirebaseAuth.instance;
  String id = '';

  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        id = user.uid;
        print('User UID: $id');
        _database = FirebaseDatabase.instance
            .reference()
            .child('users/${id}/HighScore');
        _database.onValue.listen((event) {
          final dynamic value = event.snapshot.value;
          if (value != null) {
            // Ensure the value is not null before updating highscore
            setState(() {
              highscore = value;
            });
          }
        });
      } else {
        print('Đăng nhập không thành công ');
      }
    });
  }

  void signOut() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
      print('Đăng Xuất Thành Công');
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
      // Xử lý lỗi nếu có
    }
  }

  String default_img = 'images/amthah.png';
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
        child: Container(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/logo.png'),
                  ),
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow, // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 2, // Border width
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(1), // Shadow color
                        spreadRadius: 5, // Spread radius
                        blurRadius: 7, // Blur radius
                        offset: Offset(0, 3), // Shadow offset
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 15,
                  child: Center(
                    child: Text(
                      'High Score: ' + highscore.toString(),
                      textAlign:
                          TextAlign.center, // Đặt thuộc tính textAlign ở đây
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold, // In đậm
                        fontSize: 18, // Cỡ chữ
                      ),
                    ),
                  )),
              Container(
                height: MediaQuery.of(context).size.height / 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/button.png'),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => GamePuzMultiPlayer(),
                                ),
                              );
                            },
                            child: Text(
                              'Chơi Đơn',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/button.png'),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WaitingListScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Đấu Trường',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/button.png'),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RankScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Xếp Hạng',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                // color: Colors.red,
                height: MediaQuery.of(context).size.height / 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Transform.rotate(
                      angle: 3.14159265359,
                      child: IconButton(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Thông Báo'),
                                content: Text('Bạn Có Chắc Muốn Đăng Xuất!!'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Text('Mời Bạn Tiếp Tục Trả Nghiệm Game!');
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Không'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      signOut();
                                    },
                                    child: const Text('Có'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Image.asset('images/exit.png'),
                        iconSize: MediaQuery.of(context).size.width / 6,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
