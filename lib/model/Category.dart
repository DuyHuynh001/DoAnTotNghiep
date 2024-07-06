import 'package:cloud_firestore/cloud_firestore.dart';

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
  static Future<void> saveCategory(String name,String title) async {
    try {
      CollectionReference comicsCollection = FirebaseFirestore.instance.collection('Category');
      Map<String, dynamic> comicDetails = {
        'Name': name,
        'Title': title,
      };
     
      DocumentReference comicDoc = await comicsCollection.add(comicDetails);
      print('Thêm thể loại thành công');
    } catch (e) {
      print('Lỗi khi thêm thể loại: $e');
    }
  }
  
}