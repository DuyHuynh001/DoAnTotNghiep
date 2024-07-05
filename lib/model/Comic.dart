import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/model/Chapter.dart';

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
  Timestamp addtime;
  String api;


  Comics({
    required this.id,
    required this.name,
    required this.description,
    required this.genre,
    required this.image,
    required this.source,
    required this.status,
    required this.chapters,
    required this.favorites,
    required this.view,
    required this.addtime,
    required this.api
  });

  factory Comics.fromJson(String id,Map<String, dynamic> json) {
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
      favorites:json['favorites'],
      view:json['view'],
      addtime: json['addtime'],
      api: json['api'],
      chapters: chaptersList,
    );
  }

  static FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<List<Comics>?> fetchNewComicsList(String status) async {
    try {
      Query query = _db.collection('Comics');

      if (status != "Tất cả") {
        query = query.where('status', isEqualTo: status);
      }

      QuerySnapshot querySnapshot = await query.orderBy('addtime', descending: true).get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      List<Comics> comicsList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();

      return comicsList; 
    } catch (e) {
      print("Error fetching comics list: $e");
      return []; 
    }
  }

  // lấy danh sách truyện full
  static Future<List<Comics>> fetchFullComicsList() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('Comics').where('status', isEqualTo: "Hoàn thành").get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();
    } catch (e) {
      print("Error fetching comics list: $e");
      return [];
    }
  }

  // lấy danh sách truyện full được yêu thích nhất
  static Future<List<Comics>> fetchFullComicsListAndFavorite() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('Comics')
      .where('status', isEqualTo: "Hoàn thành") 
      .orderBy('favorites', descending: true).get(); // Sắp xếp theo lượt yêu thích giảm dần
      
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();
    } catch (e) {
      print("Error fetching comics list: $e");
      return [];
    }
  }

  //lấy danh sách truyện hot
  static Future<List<Comics>> fetchHotComicsList() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('Comics')
          .orderBy('favorites', descending: true) // Sắp xếp theo lượt yêu thích giảm dần
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

  // lấy danh sách truyện theo dõi
  static Future<List<Comics>> fetchViewComicsList() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('Comics')
          .orderBy('view', descending: true)
          .limit(50) // Sắp xếp theo lượt yêu thích giảm dần
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

  // lấy danh sách comic hot theo trạng thái
  static Future<List<Comics>?> fetchHotComicsListByStatus(String status) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('Comics');
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
      throw Exception('Lỗi khi tải thông tin truyện theo trạng thái: $e');
    }
  }

  // lấy thông tin truyện từ Firestore dựa trên ID
  static Future<Comics> fetchComicsById(String id) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Comics')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw Exception('Không tìm thấy truyện với id: $id');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Comics.fromJson(doc.id, data);
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin truyện theo id: $e');
    }
  }

  //lấy danh sách comic theo thể loại
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
  //lấy danh sách comic theo thể loại và trạng thái truyện
  static Future<List<Comics>?> fetchComicsByCategoryAndStatus(String name, String status) async {
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
      throw Exception('Lỗi khi tải thông tin truyện theo thể loại và trạng thái: $e');
    }
  }
  
  // lấy tất cả danh sách truyện
  static Future<List<Comics>> fetchComics() async {
    try {
      Query query = FirebaseFirestore.instance.collection('Comics');
      QuerySnapshot querySnapshot = await query.get();
      List<Comics> comicsList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();

      return comicsList;
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin truyện $e');
    }
  }

  static Future<void> saveComicAndChaptersToFirestore(String name, String status, String urlImage, String content ,List<String> categories, Map<String, dynamic> comicData,String api) 
   async {
    
    try {
      CollectionReference comicsCollection = FirebaseFirestore.instance.collection('Comics');
      Map<String, dynamic> comicDetails = {
        'name': name,
        'status': status,
        'image': urlImage,
        'description': content,
        'source': 'otruyen', 
        'genre': categories,
        'favorites':0,
        'view':0,
        'api':api,
        'addtime':FieldValue.serverTimestamp()
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
            'vip': false
          };

          // Sắp xếp các chương theo thuộc tính chapter_name
          String chapterId = chapter['chapter_name'];
          await chaptersCollection.doc(chapterId).set(chapterData);
        }
      }
      print('Comic and chapters added to Firestore successfully!');
    } catch (e) {
      print('Error adding comic and chapters to Firestore: $e');
    }
  }
}