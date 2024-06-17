import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manga_application_1/compoment/CommentItem.dart';
import 'package:manga_application_1/model/load_data.dart';

class FullCommentsScreen extends StatefulWidget {
  final String storyId;
  final String UserId;

  const FullCommentsScreen({Key? key, required this.storyId, required this.UserId}) : super(key: key);

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

  void _loadComments() async {
      List<DocumentSnapshot> fetchedComments = await fetchCommentsByComicId(widget.storyId);
      setState(() {
        comments = fetchedComments;
      });
  }

  void _postComment(String comment) async {
      await FirebaseFirestore.instance.collection('Comments').add({
        'comicId': widget.storyId,
        'comment': comment,
        'times': FieldValue.serverTimestamp(),
        'UserId': widget.UserId
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
                      _postComment(comment);
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
