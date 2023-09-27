import 'package:flutter/material.dart';
import 'package:game_quiz/callvideo/call.dart';

class myroom extends StatelessWidget {
  const myroom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyCall(callID: "1")));
          },
          child: Text("Join Call"),
        ),
      ),
    );
  }
}