import 'package:flutter/material.dart';

// ignore: must_be_immutable
class header extends StatelessWidget {
  header({super.key, required this.title});
  String title;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 50, 0, 50),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  color: Color.fromARGB(255, 248, 200, 27),
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.width / 10),
            ),
          ],
        ));
  }
}
