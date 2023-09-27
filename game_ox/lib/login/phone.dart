import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPhone extends StatefulWidget {
  static String verify = "";
  const MyPhone({Key? key}): super(key: key);

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  TextEditingController Coutry = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    Coutry.text = "+84";
    super.initState();
  }
  var phone = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Container(
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(width: 1,color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    SizedBox(width: 15),
                    SizedBox(        
                      width: 40,
                      child: TextField(
                        controller: Coutry,
                        decoration: InputDecoration(
                          border: InputBorder.none
                        ),
                      ),
                    ),
                    Text('|',style: TextStyle(fontSize: 40,color: Colors.grey),),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          phone = value;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Phone number'
                        ),
                      )
                      )
                  ],
                ),
              ),
              SizedBox(height: 10,),
              //Button
              SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(onPressed: ()async {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: '${Coutry.text + phone}',
                    verificationCompleted:
                    (PhoneAuthCredential credential) {},
                      verificationFailed: (FirebaseAuthException e) {},
                      codeSent:
                       (String verificationId, int? resendToken) {
                                MyPhone.verify = verificationId;
                                Navigator.pushNamed(context, 'otp');
                              },
                      codeAutoRetrievalTimeout:
                          (String verificationId) {},
                    );
                            // Navigator.pushNamed(context, 'otp');
                }, 
                child: Text('Send the code',style: TextStyle(fontSize: 16),),
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