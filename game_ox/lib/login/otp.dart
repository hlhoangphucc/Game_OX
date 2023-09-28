import 'package:flutter/material.dart';
import 'package:game_quiz/login/phone.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Myotp extends StatefulWidget {
  const Myotp({Key? key}): super(key: key);

  @override
  State<Myotp> createState() => _MyotpState();
}

class _MyotpState extends State<Myotp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    var code = "";
   return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios,color: Colors.black,),
      ),
    ),
      body: Container(
        margin: EdgeInsets.only(left: 15,right: 15),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Text
              Text('Phone verifycation',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
              Text('We need to register your phone',style: TextStyle(fontSize: 16)),
              SizedBox(height: 10,),
              //TextInput
              Row(
                children: [
                  Pinput(
                    onChanged: (value) {
                      code = value;
                    },
                    length: 6,
                    showCursor: true,
                  )
                ],
              ),
              SizedBox(height: 10,),
              //Button
              SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(onPressed: ()async {
                            try {
                              PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                                verificationId: MyPhone.verify,
                                smsCode: code);
                              await auth.signInWithCredential(credential);
                              Navigator.pushNamedAndRemoveUntil(context, 'signup', (route) => false);
                            } catch (e) {
                              print('ERROR verify otp');
                            }
                          }, child: Text('Verify phone',style: TextStyle(fontSize: 16),),
                  style: ElevatedButton.styleFrom(primary: Colors.green.shade600,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}