import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/component/CommentItem.dart';
import 'package:manga_application_1/component/MyCommentItem.dart';
import 'package:manga_application_1/model/Comment.dart';

class MyCommentTab extends StatefulWidget {
  final String UserId;
  const MyCommentTab({super.key, required this.UserId});

  @override
  State<MyCommentTab> createState() => _MyCommentTabState();
}

class _MyCommentTabState extends State<MyCommentTab> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchCommentsByUserId(widget.UserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              List<Map<String, dynamic>> comments = snapshot.data ?? [];
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(), 
                shrinkWrap: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var commentData = comments[index];
                  return MyCommentItem(
                    CommentId: commentData['id'],
                    UserId: commentData['UserId'],
                    commentText: commentData['comment'],
                    time: commentData['times'],
                    ComicId: commentData['comicId'],
                    Name: commentData['comicName'],
                    onDelete: () {
                      setState(() {
                        fetchCommentsByUserId(widget.UserId);
                      });
                    },
                  );
                },
              );
            },
          ),
        ],
      )
    );
  }
}


