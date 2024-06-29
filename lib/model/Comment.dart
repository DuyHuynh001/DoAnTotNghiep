 import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot>> fetchCommentsByComicId(String ComicId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Comments')
        .where('comicId', isEqualTo: ComicId)
        .get();
    List<DocumentSnapshot> comments = querySnapshot.docs;

    // Sắp xếp theo trường 'times' giảm dần
    comments.sort((a, b) {
      Timestamp timeA = a['times'];
      Timestamp timeB = b['times'];
      return timeB.compareTo(timeA);
    });
      return comments;
    
  } catch (e) {
    print('Error fetching comments: $e');
    return []; // Trả về danh sách rỗng nếu có lỗi
  }
}