 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comicz/model/Comic.dart';

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


Future<List<Map<String, dynamic>>> fetchCommentsByUserId(String userId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Comments')
        .where('UserId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> comments = [];

    querySnapshot.docs.forEach((doc) {
      // Extract document data
      Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;
      
      // Add document ID to the data
      commentData['id'] = doc.id;

      comments.add(commentData);
    });

    // Sort comments by 'times' field in descending order
    comments.sort((a, b) {
      Timestamp timeA = a['times'];
      Timestamp timeB = b['times'];
      return timeB.compareTo(timeA);
    });

    return comments;
  } catch (e) {
    print('Error fetching comments: $e');
    return []; // Return an empty list if there's an error
  }
}