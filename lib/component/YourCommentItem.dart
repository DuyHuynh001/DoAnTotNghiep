import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:comicz/model/User.dart';
import 'package:comicz/view/ComicDetailScreen.dart';

class YourCommentItem extends StatefulWidget {
  final String CommentId;
  final String UserId;
  final String commentText;
  final Timestamp time;
  final String ComicId;
  final String Name;
  final String CurrentUserId;

  const YourCommentItem({
    Key? key,
    required this.CommentId,
    required this.UserId,
    required this.commentText,
    required this.time,
    required this.ComicId,
    required this.Name,
    required this.CurrentUserId
  }) : super(key: key);

  @override
  _YourCommentItemState createState() => _YourCommentItemState();
}

class _YourCommentItemState extends State<YourCommentItem> {
  User userData = User(Id: "", Name: "", Image: "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b", Email: "", Status: false, Points: 0, IsRead: 0,Gender: "Không được đặt",UserCategory: []);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      User user = await User.fetchUserById(widget.UserId);
      setState(() {
        userData = user;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(userData.Image),
            radius: 30,
          ),
          SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                    ComicDetailScreen(
                      storyId: widget.ComicId,
                      UserId: widget.CurrentUserId,
                    ),
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
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userData.Name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),            
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(widget.commentText, style: const TextStyle(fontSize: 16), ),
                    SizedBox(height: 5),
                    Text(
                      "Truyện tranh: " + widget.Name,
                      style: const TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        formatTimestamp(widget.time),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
