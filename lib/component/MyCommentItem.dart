import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/model/User.dart';
import 'package:manga_application_1/view/ComicDetailScreen.dart';

class MyCommentItem extends StatefulWidget {
  final String CommentId;
  final String UserId;
  final String commentText;
  final Timestamp time;
  final String ComicId;
  final String Name;
  final VoidCallback onDelete;

  const MyCommentItem({
    Key? key,
    required this.CommentId,
    required this.UserId,
    required this.commentText,
    required this.time,
    required this.ComicId,
    required this.Name,
    required this.onDelete,
  }) : super(key: key);

  @override
  _MyCommentItemState createState() => _MyCommentItemState();
}

class _MyCommentItemState extends State<MyCommentItem> {
  User userData =
      User(Id: "", Name: "", Image: "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b", Email: "", Status: false, Points: 0, IsRead: 0);

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

  void deleteComment() async {
    try {
      DocumentReference commentRef =
          FirebaseFirestore.instance.collection('Comments').doc(widget.CommentId);
      await commentRef.delete();
      widget.onDelete(); // Notify parent widget to update the comment list
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa bình luận"),
          content: Text("Bạn có chắc chắn muốn xóa bình luận này không?"),
          actions: [
            TextButton(
              child: Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Xóa"),
              onPressed: () {
                setState(() {
                  deleteComment();
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
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
                      UserId: widget.UserId,
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
                        IconButton(
                          onPressed: () {
                            showDeleteConfirmationDialog();
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(widget.commentText),
                    SizedBox(height: 5),
                    Text(
                      "Truyện tranh: " + widget.Name,
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
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
