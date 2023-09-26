import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game_quiz/home.dart';
import 'package:game_quiz/phone.dart';
import 'package:game_quiz/otp.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'phone',
    routes: {'phone':(context)=> MyPhone(),'otp':(context)=> Myotp(),'home':(context)=>MyHome()},
  ));
}
