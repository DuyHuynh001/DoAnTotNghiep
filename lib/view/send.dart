// import 'dart:html';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
// Future<void> sendNotificationToUsers() async {
//   QuerySnapshot users = await FirebaseFirestore.instance.collection('users').get();

//   List<String> tokens = [];
//   users.docs.forEach((doc) {
//     if (doc.exists) {
//       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//       if (data.containsKey('token')) {
//         tokens.add(data['token']);
//       }
//     }
//   });

//   // Prepare notification payload
//   Notification notification = Notification(

//      'Tiêu đề thông báo',
//     body: 'Nội dung thông báo',
//   );

//   // Send notification to each token
//   await Future.forEach(tokens, (token) async {
//     await _firebaseMessaging.send(
//       to: token,
//       message: RemoteMessage(
//         notification: notification,
//       ),
//     );
//   });
// }
