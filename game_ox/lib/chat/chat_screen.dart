import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_quiz/chat/chatservice.dart';

class Chat_Screen extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  const Chat_Screen({super.key,required this.receiverEmail,required this.receiverId});

  @override
  State<Chat_Screen> createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<Chat_Screen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController message_txt = TextEditingController();
  final chatservice _chatservice = chatservice();

  void sendMassage() async{
    if(message_txt.text.isNotEmpty){
      await _chatservice.sendMassage(widget.receiverId, message_txt.text);
      message_txt.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        actions: [Column(
          children: [
              IconButton(onPressed: () {
            Navigator.pushNamed(context, 'joinroom');
          }, icon: Icon(Icons.duo_outlined,size: 45,)
              ),
              SizedBox(width: 80,)
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _messagelist()),
          _messageinput()
        ],
      ),
    );
  }

  Widget _messagelist(){
    return StreamBuilder(
      stream: _chatservice.getMessage(widget.receiverId, _auth.currentUser!.uid), 
      builder: (context,snapshot){
        if(snapshot.hasError){
          return Text('error');
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Text('Loading ...');
        }

          return ListView(

            children: snapshot.data!.docs
                  .map((document) => _messageitem(document))
                  .toList(),
          ); 
      });
  }

  Widget _messageitem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String , dynamic>;

    var alignment = (data['senderId'] == _auth.currentUser!.uid)
    ? Alignment.centerRight
    : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _auth.currentUser!.uid)
          ?CrossAxisAlignment.end
          :CrossAxisAlignment.start,
          mainAxisAlignment:(data['senderId'] == _auth.currentUser!.uid)
          ?MainAxisAlignment.end
          :MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[400],
                borderRadius: BorderRadius.circular(15)
              ),
              child: Text(data['message'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),)),
          ],
        ),
      ),
    );
  }

  Widget _messageinput(){
    return Container(
      height: 50,
      decoration: BoxDecoration(
      border: Border.all(width: 1, color: Colors.grey),
      borderRadius: BorderRadius.circular(10)   
      ),
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(width: 15,),
          Expanded(
            child: TextField(
              controller: message_txt,
              decoration: InputDecoration(
                hintText: 'Chat đi đừng sợ',
                border: InputBorder.none
              ),
            ),
          ),
          IconButton(
          onPressed: sendMassage, 
          icon: const Icon(
            Icons.send_sharp,
            size: 40,
          ))
        ],
      ),
    );
  }
}