import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game_quiz/callvideo/joinroom.dart';
import 'package:game_quiz/callvideo/room.dart';
import 'package:game_quiz/home.dart';
import 'package:game_quiz/login/phone.dart';
import 'package:game_quiz/login/otp.dart';
import 'package:game_quiz/login/signin.dart';
import 'package:game_quiz/login/signup.dart';
import 'package:game_quiz/welcome.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'welcome',
    routes: { 'welcome':(context)=> welcome_page(),
    'signin':(context)=>Sign_In(),
    'phone':(context)=> MyPhone(),
    'otp':(context)=> Myotp(),
    'home':(context)=>MyHome(),
    'signup':(context)=>Sign_Up(),
    'room':(context) => myroom(),
    'joinroom':(context) => joinroom(),
    },
  ));
}
