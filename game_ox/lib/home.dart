import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_quiz/chat/chat_screen.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [Row(children: [
             IconButton(
          onPressed: () {
            _signOut(context);
          },
          icon: Icon(
            Icons.output,
            color: Colors.black,size: 35,
          ),
        ), 
          SizedBox(width: 20,)
           ],
          )
        ],
      ),
      body: Column(children: [ 
        Expanded(
          child:_buildUserList()
          ),
      ],)
    );
  }
    void _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, 'signin', (route) => false);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget _buildUserList(){
    return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').snapshots(),
    builder: (context,snapshot){
        if(snapshot.hasError){
          return Text('error');
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return Text('Loading...');
        }
        return ListView(
          children: snapshot.data!.docs
          .map<Widget>((doc) => buildUserListItem(doc))
          .toList(),
        );
      },
    );
  }
Widget buildUserListItem(DocumentSnapshot document) {
  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Container(
          padding: EdgeInsets.only(top: 24,left: 50),
          height: 70,
          decoration: BoxDecoration(
            borderRadius:BorderRadius.circular(5),
           border: Border.all(width: 1,color: Colors.grey)
          ),
          child: Text(data['email'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),), 
        ),
        onTap: () {
          Navigator.push(
            context ,
            MaterialPageRoute(
              builder: (context) => Chat_Screen(
                receiverEmail: data['email'],
                receiverId: data['uid'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
