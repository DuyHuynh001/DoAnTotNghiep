import 'package:cloud_firestore/cloud_firestore.dart';

class Chapters {
  final String Id;
  final String chapterName;
  final DateTime dateTime;
  final String chapterApiData;
  Chapters({
    required this.Id,
    required this.chapterName,
    required this.dateTime,
    required this.chapterApiData,

  });

  factory Chapters.fromJson(Map<String, dynamic> json) {
    String id = '${json['chapter_name']}';
    return Chapters(
      Id: id,
      chapterName: json['chapter_name'],
      dateTime: json['datetime'],
      chapterApiData: json['chapter_api_data'],
    );
  }
  
  static Future<List<Map<String, dynamic>>> fetchChapters(String comicId) async {
    try {
      QuerySnapshot chaptersSnapshot = await FirebaseFirestore.instance
          .collection('Comics')
          .doc(comicId)
          .collection('chapters')
          .get();
        Set<String> uniqueIds = {};
        List<Map<String, dynamic>> chapters = [];

        chaptersSnapshot.docs.forEach((doc) {
          String chapterId = doc.id; // Keep the chapter ID as a string
          String chapterTime = doc.get('time') ?? '';
          bool Isvip= doc.get('vip')?? false;

          if (!uniqueIds.contains(chapterId)) {
            uniqueIds.add(chapterId);
            chapters.add({
              'id': chapterId,
              'time': chapterTime,
              'vip':Isvip
            });
          }
        });
      return chapters;
    } catch (e) {
      throw Exception('lỗi khi load chapters: $e');
    }
  }

  static Future<List<String>> fetchDataChapters(String comicId, String chapterId) async {
    try {
      // Lấy dữ liệu từ Firestore
      DocumentSnapshot chapterSnapshot = await FirebaseFirestore.instance
          .collection('Comics')
          .doc(comicId)
          .collection('chapters')
          .doc(chapterId)
          .get();

      // Kiểm tra xem tài liệu có tồn tại không
      if (chapterSnapshot.exists) {
        Map<String, dynamic> data = chapterSnapshot.data() as Map<String, dynamic>;
        List<dynamic> images = data['chapter_images'];
        List<String> imageUrls = images.cast<String>();
        return imageUrls;
      } else {
        throw Exception('Không tìm thấy chapters theo comic');
      }
    } catch (e) {
      throw Exception('lỗi khi load chapters: $e');
    }
  }

  static Future<double> fetchLatestChapterNumber(String comicId) async {
    try {
      QuerySnapshot chaptersSnapshot = await FirebaseFirestore.instance
          .collection('Comics')
          .doc(comicId)
          .collection('chapters')
          .get();

      // Tìm chương mới nhất dựa trên ID của chương
      if (chaptersSnapshot.docs.isNotEmpty) {
        double latestChapterNumber = chaptersSnapshot.docs
            .map((doc) => double.tryParse(doc.id.toString()) ?? -double.infinity)
            .reduce((a, b) => a > b ? a : b);

        return latestChapterNumber;
      } else {
        return 0.0; 
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy chương mới nhất: $e');
    }
  }
}

