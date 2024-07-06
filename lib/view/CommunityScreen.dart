import 'package:flutter/material.dart';
import 'package:comicz/component/CommunityItem.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';
import 'package:comicz/model/User.dart';
import 'package:comicz/view/AddPostScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _refreshPosts() async {
    setState(() {
      futurePostsWithUsers = fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: futurePostsWithUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Map<String, dynamic>> postsWithUsers = snapshot.data!;
              return ListView.builder(
                itemCount: postsWithUsers.length,
                itemBuilder: (context, index) {
                  var postWithUser = postsWithUsers[index];
                  Community post = postWithUser['post'];
                  User user = postWithUser['user'];
                  Comics? comic = postWithUser['comic'];
                  if (comic == null || post.ComicId.isEmpty) {
                    comic = null;
                  }
                  return CommunityItem(
                    message: post,
                    user: user,
                    comic: comic,
                    UserId: widget.UserId,
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => AddPost(
                UserId: widget.UserId,
                onPostAdded: () {
                  _refreshPosts();
                },
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
        child: const Icon(
          Icons.create_outlined,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
