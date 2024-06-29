import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  final String id;
  final String name;
  final String image;
  final String chapterId;
  final Timestamp timestamp;

 History({
    required this.id,
    required this.name,
    required this.image,
    required this.chapterId,
    required this.timestamp,
  });

  factory History.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return  History(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      chapterId: data['chapterId'] ?? '',
      timestamp: (data['timestamp'] )
    );
  }

  static Stream<List<History>> fetchHistoryList(String userId) {
    return FirebaseFirestore.instance
      .collection('User')
      .doc(userId)
      .collection('History')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => History.fromFirestore(doc)).toList());
  }
  
  static Future<void> deleteHistoryComic(String userId, String comicId) {
    return FirebaseFirestore.instance .collection('User') .doc(userId).collection('History').doc(comicId).delete();
  }

  // lấy lịch sử yeu thích 
  static Stream<List<History>> fetchFavoriteList(String userId) {
    return FirebaseFirestore.instance
      .collection('User')
      .doc(userId)
      .collection('FavoritesList')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => History.fromFirestore(doc)).toList());
  }
  static Future<void> deleteFavoriteComic(String userId, String comicId) {
    return FirebaseFirestore.instance .collection('User') .doc(userId).collection('FavoritesList').doc(comicId).delete();
  }
  
  //lấy lịch sử theo dõi
  static Stream<List<History>> fetchViewList(String userId) {
    return FirebaseFirestore.instance
      .collection('User')
      .doc(userId)
      .collection('ViewList')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => History.fromFirestore(doc)).toList());
  }
  static Future<void> deleteViewComic(String userId, String comicId) {
    return FirebaseFirestore.instance .collection('User') .doc(userId).collection('ViewList').doc(comicId).delete();
  }
}
