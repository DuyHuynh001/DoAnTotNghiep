import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String Id;
  final String Name;
  final String Image;
  final bool Status;
  final String Email;
  final int Points;
  final int IsRead;
  final String Gender;

  User({
    required this.Id,
    required this.Name,
    required this.Image,
    required this.Email,
    required this.Status,
    required this.Points,
    required this.IsRead,
    required this.Gender
  });

  factory User.fromJson(String Id, Map<String, dynamic> json) {
    return User(
      Id: Id,
      Name: json['Name'],
      Email: json['Email'],
      Status: json['Status'],
      Image: json['Image'],
      Points: json['Points'],
      IsRead: json['IsRead'],
      Gender: json['Gender']
    );
  }

   static Future<User> fetchUserById(String id) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw Exception('Không tìm thấy người dùng với id: $id');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return User.fromJson(doc.id, data);
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin người dùng theo id: $e');
    }
  }

  static Stream<User> getUserStream(String id) {
    return FirebaseFirestore.instance
        .collection('User')
        .doc(id)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Không tìm thấy người dùng với id: $id');
      }
      return User.fromJson(snapshot.id, snapshot.data() as Map<String, dynamic>);
    });
  }
}
  




