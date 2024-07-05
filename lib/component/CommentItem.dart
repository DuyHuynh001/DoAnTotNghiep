import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/component/ShowUser.dart';
import 'package:manga_application_1/model/Community.dart';
import 'package:manga_application_1/model/User.dart'; 

class CommentItem extends StatefulWidget {
  final String userId;
  final String commentText;
  final Timestamp time;
  final String currentId;

  const CommentItem({Key? key,required this.userId,required this.commentText,required this.time, required this.currentId}) : super(key: key);
  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
 
  User userData= User(Id: "", Name: "", Image: "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b", Email: "", Status: false, Points: 0, IsRead: 0, Gender: "Không được đặt");
  @override
  void initState() {
    super.initState();
    _loadUser();
  }
  void _loadUser() async {
    try {
      User user = await User.fetchUserById(widget.userId);
      setState(() {
        userData = user;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy HH:mm:ss')
        .format(dateTime); // Định dạng thời gian
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => Show(UserId:widget.userId, currentId: widget.currentId),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(userData.Image),
              radius: 30,
            ),
          ),
         
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData.Name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(widget.commentText),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formatTimestamp(widget.time),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
