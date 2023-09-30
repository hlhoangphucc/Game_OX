import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:game_quiz/ratings/header.dart';

// ignore: camel_case_types
class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreen();
}

class _RankScreen extends State<RankScreen> {
  List<Map<dynamic, dynamic>> highScores = [];
  late DatabaseReference _databaseRef;
  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.reference().child('users');
    setState(() {
      highScores.clear();
    });

    // Lắng nghe sự kiện khi có thay đổi dữ liệu
    _databaseRef.onValue.listen((event) {
      final dynamic data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          highScores.clear();
        });

        Map<dynamic, dynamic> userData = data;
        userData.forEach((key, value) {
          setState(() {
            highScores
                .add({'name': value['email'], 'highScore': value['HighScore']});
          });
        });

        // Sắp xếp danh sách highScores theo high score từ cao đến thấp
        highScores.sort((a, b) => b['highScore'].compareTo(a['highScore']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
            decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background.png"),
            fit: BoxFit.cover,
          ),
        )),
        SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => home(),
                            //     ));
                          },
                          icon: Image.asset('images/back.png'),
                          iconSize: MediaQuery.of(context).size.width / 8,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/cauhoi.png"),
                      ),
                    ),
                    child: header(title: 'Bảng Xếp Hạng'),
                  ),
                  Container(
                      child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: ListView.builder(
                      itemCount: highScores.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: Colors.yellow, // Background color
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                              border: Border.all(
                                color: Colors.black, // Border color
                                width: 2, // Border width
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.8), // Shadow color
                                  spreadRadius: 5, // Spread radius
                                  blurRadius: 7, // Blur radius
                                  offset: Offset(0, 3), // Shadow offset
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                'Email: ${highScores[index]['name']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              subtitle: Text(
                                  'High Score: ${highScores[index]['highScore']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ));
                      },
                    ),
                  )),

                  // Container(
                  //   child: Container(
                  //       height: MediaQuery.of(context).size.height / 2,
                  //       child:),
                  // ),
                ],
              )),
        ),
      ],
    ));
  }
}
