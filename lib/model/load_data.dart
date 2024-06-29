import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  static Future<List<Map<String, dynamic>>> fetchChapters(
      String comicId) async {
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

        if (!uniqueIds.contains(chapterId)) {
          uniqueIds.add(chapterId);
          chapters.add({
            'id': chapterId,
            'time': chapterTime,
          });
        }
      });

      print(chapters);
      return chapters;
    } catch (e) {
      throw Exception('Failed to load chapters: $e');
    }
  }

  static Future<List<String>> fetchDataChapters(
      String comicId, String chapterId) async {
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
        // Lấy dữ liệu từ DocumentSnapshot
        Map<String, dynamic> data =
            chapterSnapshot.data() as Map<String, dynamic>;
        List<dynamic> images = data['chapter_images'];
        List<String> imageUrls = images.cast<String>();
        return imageUrls;
      } else {
        throw Exception('Chapter not found');
      }
    } catch (e) {
      throw Exception('Failed to load chapter: $e');
    }
  }
}

class Comics {
  String id;
  String name;
  String description;
  List<String> genre;
  String image;
  String source;
  String status;
  List<Chapters> chapters;
  int favorites;
  int view;

  Comics(
      {required this.id,
      required this.name,
      required this.description,
      required this.genre,
      required this.image,
      required this.source,
      required this.status,
      required this.chapters,
      required this.favorites,
      required this.view});

  factory Comics.fromJson(String id, Map<String, dynamic> json) {
    List<String> genreList = List<String>.from(json['genre']);

    List<Chapters> chaptersList = [];
    if (json['chapters'] != null) {
      chaptersList = List<Chapters>.from(
        json['chapters'].map((chapterJson) => Chapters.fromJson(chapterJson)),
      );
    }

    return Comics(
      id: id, // Lấy id từ JSON
      name: json['name'],
      description: json['description'],
      genre: genreList,
      image: json['image'],
      source: json['source'],
      status: json['status'],
      favorites: json['favorites'],
      view: json['view'],
      chapters: chaptersList,
    );
  }
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  // lấy danh sách truyện đề cử
  static Future<List<Comics>> fetchRecomendComicsList() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('Comics')
          .where('recommend', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();
    } catch (e) {
      print("Error fetching comics list: $e");
      return [];
    }
  }

  // lấy danh sách truyện hành động
  static Future<List<Comics>> fetchActionComicsList() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('Comics')
          .where('recommend', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();
    } catch (e) {
      print("Error fetching comics list: $e");
      return [];
    }
  }

  // lấy danh sách truyện full
  static Future<List<Comics>> fetchFullComicsList() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('Comics')
          .where('status', isEqualTo: "Hoàn thành")
          .get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();
    } catch (e) {
      print("Error fetching comics list: $e");
      return [];
    }
  }

  // lấy danh sách truyện hot
  static Future<List<Comics>> fetchHotComicsList() async {
    try {
      QuerySnapshot querySnapshot =
          await _db.collection('Comics').where('hot', isEqualTo: true).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();
    } catch (e) {
      print("Error fetching comics list: $e");
      return [];
    }
  }

  // Phương thức tải thông tin truyện từ Firestore dựa trên ID
  static Future<Comics> fetchComicsById(String id) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('Comics').doc(id).get();

      if (!doc.exists) {
        throw Exception('Không tìm thấy truyện với id: $id');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Comics.fromJson(doc.id, data);
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin truyện theo id: $e');
    }
  }

  static Future<List<Comics>> fetchComicsByCategory(String name) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('Comics')
          .where('genre', arrayContains: name);

      QuerySnapshot querySnapshot = await query.get();
      List<Comics> comicsList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();
      return comicsList;
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin truyện theo thể loại $e');
    }
  }

  static Future<List<Comics>?> fetchComicsByCategoryAndStatus(
      String name, String status) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('Comics')
          .where('genre', arrayContains: name);

      if (status != "Tất cả") {
        query = query.where('status', isEqualTo: status);
      }

      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      List<Comics> comicsList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();

      return comicsList;
    } catch (e) {
      throw Exception(
          'Lỗi khi tải thông tin truyện theo thể loại và trạng thái: $e');
    }
  }
}

Future<void> saveComicAndChaptersToFirestore(
    String name,
    String status,
    String urlImage,
    String content,
    bool IsHot,
    bool IsNew,
    bool IsRecommend,
    List<String> categories,
    Map<String, dynamic> comicData) async {
  try {
    CollectionReference comicsCollection =
        FirebaseFirestore.instance.collection('Comics');

    Map<String, dynamic> comicDetails = {
      'name': name,
      'status': status,
      'image': urlImage,
      'description': content,
      'source': 'otruyen',
      'genre': categories,
      'recommend': IsRecommend,
      'new': IsNew,
      'hot': IsHot,
      'favorites': 0,
      'view': 0
    };
    // Add comic details to 'comics' collection
    DocumentReference comicDoc = await comicsCollection.add(comicDetails);
    DateTime now = DateTime.now();
    String formattedToday = DateFormat('dd-MM-yyyy hh:mm').format(now);

    // Add chapters to a subcollection of the comic document
    CollectionReference chaptersCollection = comicDoc.collection('chapters');
    for (var server in comicData['chapters']) {
      for (var chapter in server['server_data']) {
        // Data to be added for each chapter
        Map<String, dynamic> chapterData = {
          'chapterApiData': chapter['chapter_api_data'] ?? '',
          'time': formattedToday,
        };

        // Sắp xếp các chương theo thuộc tính chapter_name hoặc một thuộc tính khác nếu có
        String chapterId = chapter['chapter_name'];

        await chaptersCollection.doc(chapterId).set(chapterData);
      }
    }

    print('Comic and chapters added to Firestore successfully!');
  } catch (e) {
    print('Error adding comic and chapters to Firestore: $e');
  }
}

Future<void> saveCategory(String name, String title) async {
  try {
    CollectionReference comicsCollection =
        FirebaseFirestore.instance.collection('Category');
    Map<String, dynamic> comicDetails = {
      'Name': name,
      'Title': title,
    };

    DocumentReference comicDoc = await comicsCollection.add(comicDetails);
    print('Comic and chapters added to Firestore successfully!');
  } catch (e) {
    print('Error adding comic and chapters to Firestore: $e');
  }
}

class User {
  String Id;
  String Name;
  String Image;
  bool Status;
  String Email;
  int? Points;
  int? Level;

  User(
      {required this.Id,
      required this.Name,
      required this.Image,
      required this.Email,
      required this.Status,
      required this.Level,
      required this.Points});

  factory User.fromJson(String Id, Map<String, dynamic> json) {
    return User(
      Id: Id,
      Name: json['Name'],
      Email: json['Email'],
      Status: json['Status'],
      Image: json['Image'],
      Points: json['Points'],
      Level: json['Level'],
    );
  }
  static Future<User> fetchUserById(String id) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('User').doc(id).get();

      if (!doc.exists) {
        throw Exception('Không tìm thấy người dùng với id: $id');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return User.fromJson(doc.id, data);
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin người dùng theo id: $e');
    }
  }
}

Future<List<DocumentSnapshot>> fetchCommentsByComicId(String ComicId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Comments')
        .where('comicId', isEqualTo: ComicId)
        // .orderBy("times", descending: true)
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

class Category {
  final String id;
  final String categoryName;
  final String title;

  Category({
    required this.id,
    required this.categoryName,
    required this.title,
  });

  factory Category.fromJson(String id, Map<String, dynamic> json) {
    return Category(
      id: id,
      categoryName: json['Name'],
      title: json['Title'],
    );
  }

  static Future<List<Category>> fetchAllCategories() async {
    List<Category> categories = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Category')
          .orderBy('Name')
          .get();

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        categories.add(Category.fromJson(doc.id, data));
      });
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách thể loại: $e');
    }

    return categories;
  }
}
