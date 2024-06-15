import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String title;
  final String imageUrl;
  final String id; 
  final String chapter;
  final String Introduce;
  final String Status;
  Story({required this.title, required this.imageUrl,required this.Introduce, required this.id, required this.chapter, required this.Status });
}
 final List<Map<String, String>> categories = [
    {'name': 'Shoujo', 'icon': '🐸'},
    {'name': 'Boylove', 'icon': '💗'},
    {'name': 'Webtoon', 'icon': '🍄'},
    {'name': 'Harem', 'icon': '💥'},
    {'name': 'Co Dai', 'icon': '❗'},
  ];
class StoryService {
  // Giả sử có một list các truyện từ một nguồn dữ liệu khác
  static List<Story> allStories = [
    Story(title: 'Naruto', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/naruto.jpg',id: '1',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: '7 Viên Ngọc Rồng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/7-vien-ngoc-rong.jpg',id: '2',Status:'Đang cập nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Fantasista', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/fantasista.jpg',id: '3',Status:'Đang cập nhật',chapter: "12", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Onepunch Man', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/defense-devil.jpg',id: '4',Status:'Đang cập nhật',chapter: "13", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Defense-devil', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/black-clover-the-gioi-phep-thuat.jpg',id: '5',Status:'Đang cập nhật',chapter: "15", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Phong Vân', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/phong-van.jpg',id: '6',Status:'Đang cập nhật',chapter: "19", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Ta Đem Hoàng Tử Dưỡng Thành Hắc Hóa', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-dem-hoang-tu-duong-thanh-hac-hoa.jpg',id: '7',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Khánh Dư Niên', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/khanh-du-nien.jpg',id: '8',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Ta Là Đại Thần Tiên', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-la-dai-than-tien.jpg',id: '9',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Tiên Đế Võ Tôn', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/tien-vo-de-ton.jpg',id: '10',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Dục Huyết Thương Hậu', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/duc-huyet-thuong-hau.jpg',id: '11',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Vương Gia Khắc Thê', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/vuong-gia-khac-the.jpg',id: '12',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Doraemon ', imageUrl: 'https://tuoitho.mobi/upload/doc-truyen/doraemon-truyen-ngan/anh-dai-dien.jpg',id: '13',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Thám Tử Lừng Danh Conan', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/tham-tu-conan.jpg',id: '14',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Cuộc Chơi Trên Núi Tử Thần', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/cuoc-choi-tren-nui-tu-than.jpg',id: '15',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'One Piece', imageUrl: 'https://upload.wikimedia.org/wikipedia/vi/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg',id: '16',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Nguyên Tôn', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/nguyen-ton.jpg',id: '17',Status:'Đang Cập Nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Ma Thú Siêu Thần', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ma-thu-sieu-than.jpg',id: '18',Status:'Đang Cập Nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Đại Phụng Đả Canh Nhân', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/dai-phung-da-canh-nhan.jpg',id: '19',Status:'Đang Cập Nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Người Nuôi Rồng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/nguoi-nuoi-rong.jpg',id: '20',Status:'Đang Cập Nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Thất Hình Đại Tội', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/that-hinh-dai-toi.jpg',id: '21',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Cuộc Chiến Ẩm Thực', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/cuoc-chien-am-thuc.jpg',id: '22',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Đại Vương Tha Mạng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/dai-vuong-tha-mang.jpg',id: '23',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Ta Bị Kẹt Cùng Một Ngày 1000 Năm ', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-bi-ket-cung-mot-ngay-1000-nam.jpg',id: '24',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Toàn Chức Pháp Sư', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/toan-chuc-phap-su.jpg',id: '25',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"),
     Story(title:'Ta Trời Sinh Đã Là Nhân Vật Phản Diện', imageUrl: 'https://img.nettruyenfull.com/story/2024/03/11/22924/avatar.png',id: '26',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Ta Là Tà Đế', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-la-ta-de.jpg',id: '26',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Đại Quản Gia Là Ma Hoàng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/dai-quan-gia-la-ma-hoang.jpg',id: '27',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Võ Luyện Đỉnh Phong', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/vo-luyen-dinh-phong.jpg',id: '28',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
  ];

  // Phương thức để lấy thông tin chi tiết của một truyện dựa trên ID
  static Story getStoryById(String id) {
    return allStories.firstWhere((story) => story.id == id);
  }
}
class Chapters {
  final String Id;
  final String chapterName;
  final String chapterTitle;
  final String chapterApiData;

  Chapters({
    required this.Id,
    required this.chapterName,
    required this.chapterTitle,
    required this.chapterApiData,
  });

  factory Chapters.fromJson(Map<String, dynamic> json) {
    String id = 'C${json['chapter_name']}';
    return Chapters(
      Id: id,
      chapterName: json['chapter_name'],
      chapterTitle: json['chapter_title'],
      chapterApiData: json['chapter_api_data'],
    );
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

  Comics({
    required this.id,
    required this.name,
    required this.description,
    required this.genre,
    required this.image,
    required this.source,
    required this.status,
    required this.chapters,
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
      chapters: chaptersList,
    );
  }
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  static Future<List<Comics>> fetchComicsList() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('Comics').get();

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
  static Future<List<int>> fetchChapters(String comicId) async {
    try {
      // Lấy dữ liệu từ Firestore
      QuerySnapshot chaptersSnapshot = await FirebaseFirestore.instance
          .collection('Comics')
          .doc(comicId)
          .collection('chapters')
          .get();

      // Chuyển đổi danh sách ID từ String sang int
      List<int> chapters = chaptersSnapshot.docs
          .map((doc) => int.tryParse(doc.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
          .toList();

      return chapters;
    } catch (e) {
      throw Exception('Failed to load chapters: $e');
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
      // Lấy dữ liệu từ DocumentSnapshot
      Map<String, dynamic> data = chapterSnapshot.data() as Map<String, dynamic>;

      // Giả định rằng dữ liệu của bạn có một trường 'chapter_images' là danh sách các URL hình ảnh
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