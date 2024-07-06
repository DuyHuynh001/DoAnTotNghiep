import 'package:flutter/material.dart';
import 'package:comicz/component/CommunityItem.dart';
import 'package:comicz/component/MyCommunityItem.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';
import 'package:comicz/model/User.dart';
import 'package:comicz/view/AddPostScreen.dart';

class MyPostTab extends StatefulWidget {
  final String UserId;
  const MyPostTab({super.key, required this.UserId});

  @override
  State<MyPostTab> createState() => _MyPostTabState();
}

class _MyPostTabState extends State<MyPostTab> {
  late Future<List<Map<String, dynamic>>> PostsWithUserId;
  
  @override
  void initState() {
    super.initState();
    PostsWithUserId = fetchPosts();
  }
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    return await Community.fetchCommunityPostsWithUsersId(widget.UserId);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: PostsWithUserId,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          else {
            List<Map<String, dynamic>> postsWithUsers = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: postsWithUsers.length,
                    itemBuilder: (context, index) {
                      var postWithUser = postsWithUsers[index];
                      Community post = postWithUser['post'];
                      User user = postWithUser['user'];
                      Comics? comic = postWithUser['comic'];
                      if (comic == null || post.ComicId.isEmpty) {
                        comic = null; // Gán comic là null nếu không có thông tin truyện
                      }
                      return MyCommunityItem(
                        message: post,
                        user: user,
                        comic: comic,
                        UserId:widget.UserId,
                        onDelete: () {
                         setState(() {
                          PostsWithUserId = fetchPosts();
                        });
                       },
                      );
                    },
                  ),
                  SizedBox(height: 70),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton:  FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  AddPost(
                UserId: widget.UserId,
                onPostAdded: () {
                  setState(() {
                    PostsWithUserId = fetchPosts();
                  });
                },
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
        child: const Icon(
          Icons.create_outlined,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}