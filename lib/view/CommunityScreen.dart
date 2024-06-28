import 'package:flutter/material.dart';
import 'package:manga_application_1/component/CommunityItem.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/AddPostScreen.dart';

class CommunityScreen extends StatefulWidget {
  final String UserId;
  const CommunityScreen({super.key, required this.UserId});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late Future<List<Map<String, dynamic>>> futurePostsWithUsers;

  @override
  void initState() {
    super.initState();
    futurePostsWithUsers = fetchPosts();
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    return await Community.fetchCommunityPostsWithUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futurePostsWithUsers,
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
                      return CommunityItem(
                        message: post,
                        user: user,
                        comic: comic,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  AddPost(
                UserId: widget.UserId,
                onPostAdded: () {
                  setState(() {
                    futurePostsWithUsers = fetchPosts();
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
          setState(() {
            futurePostsWithUsers = fetchPosts();
          });
        },
        child: Icon(
          Icons.create_outlined,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
