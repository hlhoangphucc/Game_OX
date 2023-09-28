// import 'dart:math'as math;
// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// final String localUserID = math.Random().nextInt(10000).toString();

// class videocalling extends StatefulWidget {
//   const videocalling({super.key});

//   @override
//   State<videocalling> createState() => _videocallingState();
// }

// class _videocallingState extends State<videocalling> {
//   TextEditingController call_id = TextEditingController();
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: Column(
//           children: [
//             TextField(
//               controller: call_id,
//               decoration: InputDecoration(
//                 hintText: 'call id',
//                 border: OutlineInputBorder()
//               ),
//             ),
//             SizedBox(height: 20,),
//             ElevatedButton(onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => CallPge(callingID: call_id.text.toString()),));
//             }, child: Text('Submit'))
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CallPge extends StatelessWidget {
//   final String callingID;
//   const CallPge({super.key,required this.callingID});

//   @override
//   Widget build(BuildContext context) {
//     return  SafeArea(
//       child: ZegoUIKitPrebuiltCall(
//         appID: 1784878323, 
//         appSign: '5f59f92274995ef2aaf4cb7612bdaea2eaa511964ecc896867bc281e76c6b407', 
//         callID: callingID, 
//         userID: localUserID, 
//         userName: 'user_$localUserID', 
//         config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()..onOnlySelfInRoom=(context){
//           Navigator.pop(context);
//         },
//       )
//     );
//   }
// }