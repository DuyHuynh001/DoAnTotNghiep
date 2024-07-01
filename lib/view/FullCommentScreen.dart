import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manga_application_1/component/CommentItem.dart';
import 'package:manga_application_1/model/Comment.dart';
import 'package:manga_application_1/model/comment_analyzer.dart';
import 'package:manga_application_1/model/Community.dart';
import 'package:manga_application_1/model/text_translator.dart';

class FullCommentsScreen extends StatefulWidget {
  final String storyId;
  final String UserId;
  final String Name;

  const FullCommentsScreen({Key? key, required this.storyId, required this.UserId, required this.Name}) : super(key: key);

  @override
  _FullCommentsScreenState createState() => _FullCommentsScreenState();
}

class _FullCommentsScreenState extends State<FullCommentsScreen> {
  List<DocumentSnapshot> comments = [];
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }
  Future<void> handleComment(String comment) async {
  try {

    String englishComment = await translateText(comment);  
    final analysisResult = await analyzeComment(englishComment );
    final double toxicityScore = analysisResult['attributeScores']['TOXICITY']['summaryScore']['value'];

    if (toxicityScore < 0.5) {
      SaveComment(comment);
    } else {
      _showErrorDialog(context, 'Tin nhắn của bạn chứa các từ ngữ không phù hợp!');
    }
    } catch (e) {
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

  void _loadComments() async {
      List<DocumentSnapshot> fetchedComments = await fetchCommentsByComicId(widget.storyId);
      setState(() {
        comments = fetchedComments;
      });
  }

  void SaveComment(String comment) async {
    await FirebaseFirestore.instance.collection('Comments').add({
      'comicId': widget.storyId,
      'comment': comment,
      'times': FieldValue.serverTimestamp(),
      'UserId': widget.UserId,
      'comicName':widget.Name
    });
    setState(() {});
    commentController.clear();
      FocusScope.of(context).unfocus(); // Close the keyboard
    _loadComments();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tất cả bình luận'),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                var comment = comments[index];
                return CommentItem(
                  userId: comment['UserId'],
                  commentText: comment['comment'],
                  time: comment['times'],
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                 topLeft: Radius.circular(20.0),
                 topRight: Radius.circular(20.0),
              ),
              color: Colors.blue[100]
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
                      color: Colors.white
                     ), 
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(20.0),
                            right: Radius.circular(20.0),
                         )
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
                    side: BorderSide(color: Colors.black)),
                    child: const Row(children: [
                      Icon(
                        Icons.send,
                        size: 30,
                        color: Colors.black,
                      ),
                    ]
                  ),
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
