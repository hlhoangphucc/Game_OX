import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_quiz/chat/message.dart';

class chatservice extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMassage(String receiverId, String message) async { 
    final String userID = _auth.currentUser!.uid;
    final String userEmail = _auth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

   Message newMassage = Message(
    senderId: userID, 
    senderEmail: userEmail, 
    receiverId: receiverId, 
    timestamp: timestamp, 
    message: message
    );
    List<String> ids =[userID,receiverId];
    ids.sort();
    String chatRoomId = ids.join(
      "_"
    );
    await _firestore.collection('chat_rooms')
                    .doc(chatRoomId)
                    .collection('messages')
                    .add(newMassage.toMap());
  }
  Stream<QuerySnapshot> getMessage(String userID,String oderuserID ){
    List<String> ids = [userID,oderuserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp',descending: false)
          .snapshots();
  }

}