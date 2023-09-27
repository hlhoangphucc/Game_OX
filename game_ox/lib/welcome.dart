import 'package:flutter/material.dart';

class welcome_page extends StatefulWidget {
  const welcome_page({super.key});

  @override
  State<welcome_page> createState() => _welcome_pageState();
}

class _welcome_pageState extends State<welcome_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'signin');
                },
                child: Text('Sign In',style: TextStyle(fontSize: 20),),
                style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 300,
              height: 50,
              
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'signup');
                },
                child: Text('Sign Up',style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}