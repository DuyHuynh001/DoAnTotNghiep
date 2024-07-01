import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/User.dart';

class Community {
  final String Id;
  final String UserId;
  final String content;
  final String ComicId;
  int like;
  final String imageUrl;
  final Timestamp time;

  Community({ required this.imageUrl, required this.content, required this.UserId, required this.time, required this.ComicId, required this.like, required this.Id});
  factory Community.fromJson(String id, Map<String, dynamic> json) {
    return Community(
      Id: id,
      UserId: json['userId'],
      content: json['content'],
      ComicId: json['comicId'],
      imageUrl: json['image_url'],
      like: json['like'],
      time: json['timestamp']
    );
  }
  
  static Future<List<Map<String, dynamic>>> fetchCommunityPostsWithUsers() async {
    try {
      List<Map<String, dynamic>> postsWithUsersAndComics = [];
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Community')
          .orderBy('timestamp', descending: true)
          .get();

      for (var doc in snapshot.docs) {
        Community post = Community.fromJson(doc.id, doc.data() as Map<String, dynamic>);
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(post.UserId)
            .get();
        User user = User.fromJson(userSnapshot.id, userSnapshot.data() as Map<String, dynamic>);
        Comics? comic;
        if (post.ComicId.isNotEmpty) {
          DocumentSnapshot comicSnapshot = await FirebaseFirestore.instance
              .collection('Comics')
              .doc(post.ComicId)
              .get();

          if (comicSnapshot.exists) {
            comic = Comics.fromJson(comicSnapshot.id, comicSnapshot.data() as Map<String, dynamic>);
          }
        }
        Map<String, dynamic> postWithUserAndComic = {
          'post': post,
          'user': user,
          'comic': comic,
        };
        postsWithUsersAndComics.add(postWithUserAndComic);
      }
      return postsWithUsersAndComics;
    } catch (e) {
      print('Error fetching posts: $e');
      throw e; 
    }
  }
  static Future<List<Map<String, dynamic>>> fetchCommunityPostsWithUsersId(String UserId) async {
    try {
      List<Map<String, dynamic>> postsWithUsersAndComics = [];
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Community')
          .where('userId',isEqualTo: UserId)
          .orderBy('timestamp', descending: true)
          .get();

      for (var doc in snapshot.docs) {
        Community post = Community.fromJson(doc.id, doc.data() as Map<String, dynamic>);
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(post.UserId)
            .get();
        User user = User.fromJson(userSnapshot.id, userSnapshot.data() as Map<String, dynamic>);
        Comics? comic;
        if (post.ComicId.isNotEmpty) {
          DocumentSnapshot comicSnapshot = await FirebaseFirestore.instance
              .collection('Comics')
              .doc(post.ComicId)
              .get();

          if (comicSnapshot.exists) {
            comic = Comics.fromJson(comicSnapshot.id, comicSnapshot.data() as Map<String, dynamic>);
          }
        }
        Map<String, dynamic> postWithUserAndComic = {
          'post': post,
          'user': user,
          'comic': comic,
        };
        postsWithUsersAndComics.add(postWithUserAndComic);
      }
      return postsWithUsersAndComics;
    } catch (e) {
      print('Error fetching posts: $e');
      throw e; 
    }
  }

  static  Future<List<DocumentSnapshot>> fetchCommentsByCommunityId(String communityId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Community')
          .doc(communityId)
          .collection('Comment')
          .orderBy('time', descending: true)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching comments: $e');
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }
}
