import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/view/ManagerComics.dart';

class EditComics extends StatefulWidget {
  final String name;
  final String id;
  final String description;

  EditComics({required this.name, required this.id, required this.description});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditComics> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;
  List<Comics> comicsList = [];
  @override
  void initState() {
    super.initState();
    loadComicsFromFirestore();
    _nameController.text = widget.name;
    _descriptionController.text = widget.description;
  }

  // lấy ảnh từ máy cá nhân
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _imageUrl = null;
      }
    });
  }

  void loadComicsFromFirestore() async {
    try {
      Query query = FirebaseFirestore.instance.collection('Comics');
      QuerySnapshot querySnapshot = await query.get();
      List<Comics> comics = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();
      setState(() {
        comicsList = comics;
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting documents: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // lưu ảnh vào stogare và firestore
  Future<void> _uploadImage(File image) async {
    setState(() {
      _isLoading = true;
    });

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('avatars/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() async {
      try {
        String downloadUrl = await storageReference.getDownloadURL();
        _saveComicsToFirestore(downloadUrl);
      } catch (onError) {
        print("Error");
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveComicsToFirestore(String imageUrl) async {
    await FirebaseFirestore.instance
        .collection('Comics')
        .doc(widget.id)
        .update({
      'name': _nameController.text,
      'description': _descriptionController.text,
    });
  }

  //lấy đường dẫn từ url
  Future<void> _setImageFromUrl(String url) async {
    if (!url.endsWith('.jpg') && !url.endsWith('.png')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL phải kết thúc bằng .jpg hoặc .png')),
      );
      return;
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      _saveComicsToFirestore(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải ảnh từ URL')),
      );
    }
  }

  void _saveComics() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên truyện trước khi lưu')),
      );
      return;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập giới thiệu trước khi lưu')),
      );
      return;
    }
    if (_imageFile != null) {
      _uploadImage(_imageFile!);
    } else if (_imageUrlController.text.isNotEmpty) {
      _setImageFromUrl(_imageUrlController.text);
    } else {
      _saveComicsToFirestore(_imageUrl ?? '');
    }
    Navigator.of(context).pop();
  }

  void deleteComic(String docId) async {
    try {
      await FirebaseFirestore.instance.collection("Comics").doc(docId).delete();
      print('Xóa tài liệu thành công');
    } catch (e) {
      print('Lỗi khi xóa tài liệu: $e');
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Thông báo",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          ),
          contentPadding: const EdgeInsets.only(top: 10.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Bạn có muốn xóa không?"),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          deleteComic(widget.id);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Khoảng cách giữa hai nút
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Đóng',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageUrlDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nhập URL ảnh'),
          content: TextField(
            controller: _imageUrlController,
            decoration: InputDecoration(labelText: 'URL'),
            onSubmitted: (value) {
              _setImageFromUrl(value);
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xác nhận'),
              onPressed: () {
                _setImageFromUrl(_imageUrlController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa thông tin truyện'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                ListTile(
                  title: Text('Tên truyện'),
                  subtitle: TextField(
                    controller: _nameController,
                  ),
                ),
                ListTile(
                  title: Text('Giới thiệu'),
                  subtitle: TextField(
                    controller: _descriptionController,
                  ),
                ),
                ListTile(
                  title: Text('ID'),
                  subtitle: Text(widget.id),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _saveComics,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.save,
                            color: Colors.blue,
                          ),
                          Text(
                            'Lưu',
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showDeleteDialog(context);
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.blue,
                          ),
                          Text(
                            'Xóa',
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
