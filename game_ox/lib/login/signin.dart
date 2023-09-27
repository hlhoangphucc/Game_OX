import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Sign_In extends StatefulWidget {
  const Sign_In({Key? key}) : super(key: key);

  @override
  State<Sign_In> createState() => _Sign_InState();
}



class _Sign_InState extends State<Sign_In> {
  TextEditingController Email =TextEditingController();
  TextEditingController Password = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  
  Widget build(BuildContext context) {
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
      title: Text('SignIN',style: TextStyle(color: Colors.black,),),
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
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: SizedBox(
                width: 350,
                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: Email,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email'
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15,),
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: SizedBox(
                width: 350,
                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        obscureText: true,
                       controller: Password,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password'
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15,),
            SizedBox(
              width: 300,
              height: 50,
              
              child: ElevatedButton(
                onPressed: ()async {
                  try {
                  final _user = await _auth.signInWithEmailAndPassword(
                    email: Email.text, 
                    password: Password.text);

                    _firestore.collection('users').doc(_user.user!.uid).set({
                      'uid': _user.user!.uid,
                      'email': Email.text, // Lấy giá trị từ trường Email.text
                      // Các trường dữ liệu khác của người dùng
                    },SetOptions(merge: true));
                    
                    _auth.authStateChanges()
                          .listen((event) {
                            if(event != null){
                              Email.clear();
                              Password.clear();
                              Navigator.pushNamed(context, 'home');
                            }else{
                            }
                          });
                  }catch(e){
                    final snackBar = SnackBar(
                       content: Text('Có Lỗi Ở Sever!'));
                       ScaffoldMessenger.of(context)
                      .showSnackBar(snackBar);
                  }
                },
                child: Text('Sign Ip',style: TextStyle(fontSize: 20)),
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
