import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/component/CommentItem.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/User.dart';
import 'package:manga_application_1/model/comment_analyzer.dart';
import 'package:manga_application_1/model/Community.dart'; 
import 'package:manga_application_1/model/text_translator.dart';
import 'package:manga_application_1/view/ComicDetailScreen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final Community message;
  final User user;
  final Comics? comic;
  final bool IsLike;
  const CommunityDetailScreen({
    Key? key,
    required this.message,
    required this.user,
    required this.comic,
    required this.IsLike,
  });

  @override
  State<CommunityDetailScreen> createState() => CommunityDetailScreenState();
}

class CommunityDetailScreenState extends State<CommunityDetailScreen> {
  TextEditingController commentController = TextEditingController();
  List<DocumentSnapshot> comments = [];
  int commentCount = 0;
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime); // Định dạng thời gian
  }

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() async {
    List<DocumentSnapshot> fetchedComments = await Community.fetchCommentsByCommunityId(widget.message.Id);
    setState(() {
      comments = fetchedComments;
      commentCount = fetchedComments.length; // Đếm số lượng bình luận
    });
  }

  Future<void> handleComment(String comment) async {
  try {

    String englishComment = await translateText(comment);  
    final analysisResult = await analyzeComment(englishComment );
    final double toxicityScore = analysisResult['attributeScores']['TOXICITY']['summaryScore']['value'];

    if (toxicityScore < 0.5) {
      Comment(comment);
    } else {
      // Bình luận không hợp lệ, thông báo cho người dùng
      _showErrorDialog(context, 'Tin nhắn của bạn chứa các từ ngữ không phù hợp!');
    }
    } catch (e) {
      // Xử lý lỗi
      print('Error: $e');
      throw e;
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        title:Row(
          mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child:const Row(
                  children: [
                    Icon(Icons.notification_important_outlined,color: Colors.black,),
                    Text("Thông báo"),
                  ],
                )
              ),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void Comment(String comment) async {
    await FirebaseFirestore.instance.collection('Community') .doc(widget.message.Id) .collection('Comment') .add({
      'comment': comment,
      'time': FieldValue.serverTimestamp(),
      'userId': widget.user.Id,
    });
    commentController.clear();
    FocusScope.of(context).unfocus(); // Đóng bàn phím
    _loadComments(); // Hàm để tải lại bình luận
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return Future.value(false);
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text('Bài đăng của ' + widget.user.Name),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 5, right: 5, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.lightBlue[50],
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(widget.user.Image),
                              radius: 30,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.user.Name,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  formatTimestamp(widget.message.time),
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.message.content,
                          style: TextStyle(fontSize: 16),
                          maxLines: null,
                        ),
                        if (widget.comic != null)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        ComicDetailScreen(
                                      storyId: widget.comic!.id,
                                      UserId: widget.user.Id,
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
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.blue[100],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      child: Image.network(
                                        widget.comic!.image,
                                        width: 50,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10.0),
                                    Expanded(
                                      child: Text(
                                        widget.comic!.name,
                                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (widget.message.imageUrl != "")
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.message.imageUrl,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    size: 25,
                                    color: widget.IsLike ? Colors.red : Colors.grey,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text('${widget.message.like} Thích'),
                                ],
                              ),
                              Row(
                                children: [
                                 const Icon(
                                    Icons.comment,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text('$commentCount Bình luận'),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey, thickness: 1),
                  const Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Text(
                      'Bình luận mới',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      var comment = comments[index];
                      return CommentItem(
                        userId: comment['userId'],
                        commentText: comment['comment'],
                        time: comment['time'],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              color: Colors.blue[100],
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(20.0),
                          right: Radius.circular(20.0),
                        ),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(20.0),
                              right: Radius.circular(20.0),
                            ),
                          ),
                          hintText: 'Nhập bình luận của bạn...',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      String comment = commentController.text.trim();
                      if (comment.isNotEmpty) {
                        handleComment(comment);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập bình luận'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(8),
                      backgroundColor: Colors.grey[200],
                      side: BorderSide(color: Colors.black),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
