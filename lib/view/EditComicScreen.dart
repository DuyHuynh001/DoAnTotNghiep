import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comicz/model/Comic.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
class EditComicScreen extends StatefulWidget {
  final Comics comic;
  const EditComicScreen({Key? key, required this.comic}) : super(key: key);

  @override
  _EditComicScreenState createState() => _EditComicScreenState();
}

class _EditComicScreenState extends State<EditComicScreen> {
  late TextEditingController _name = TextEditingController();
  late TextEditingController _urlImage = TextEditingController();
  late TextEditingController _description = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  late String statusValue;
  late List<String> selectedCategories;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _imageUrl;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.comic.name);
    _description = TextEditingController(text: widget.comic.description);
    _imageUrl = widget.comic.image;
    statusValue = widget.comic.status;
    selectedCategories = widget.comic.genre.toList();
    loadCategories();
  }
  @override
  void dispose() {
    _name.dispose();
    _urlImage.dispose();
    _description.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
  Future<void> _saveComicToFirestore(String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('Comics').doc(widget.comic.id).update({
        'name': _name.text,
        'image': imageUrl,
        'status': statusValue,
        'description': _description.text,
        'genre': selectedCategories
      });
      setState(() {
        _imageUrl = imageUrl;
      });

      if (_name.text != widget.comic.name) {
        _updateComicNameInComments(widget.comic.id, _name.text);
      }
      Navigator.of(context).pop();
    } catch (e) {}
  }

  Future<void> _updateComicNameInComments(String comicId, String newComicName) async {
    try {
      final QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
          .collection('Comments')
          .where('comicId', isEqualTo: comicId)
          .get();

      for (DocumentSnapshot commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.update({'comicName': newComicName});
      }
    } catch (e) {
      print('Error updating comic name in comments: $e');
    }
  }
  void _saveComic() {
    if (_name.text.isEmpty|| _description.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return; 
    }
    if (_imageFile != null) {
      _uploadImage(_imageFile!);
    } else if (_imageUrlController.text.isNotEmpty) {
      _setImageFromUrl(_imageUrlController.text);
    } else {
      _saveComicToFirestore(_imageUrl ?? '');
    }
  }
  void StatusChange(String? value) {
    if (value != null) {
      setState(() {
        statusValue = value;
      });
    }
  }

  Future<void> loadCategories() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Category').get();
      final List<String> loadedCategories =snapshot.docs.map((doc) => doc['Name'] as String).toList();
      setState(() {
        categories = loadedCategories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Chọn từ máy'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.link),
                title: Text('Nhập URL ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showImageUrlDialog();
                },
              ),
            ],
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
          actions: [
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
                _imageUrl=_imageUrlController.text;
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _imageUrl = null; 
      }
    });
  }

  Future<void> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('avatars/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() async {
      try {
        String downloadUrl = await storageReference.getDownloadURL();
         _saveComicToFirestore(downloadUrl);
      } catch (onError) {
        print("Error");
      }
    });
  }
  Future<void> _setImageFromUrl(String url) async {
    if (!url.endsWith('.jpg') && !url.endsWith('.png')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL phải kết thúc bằng .jpg hoặc .png')),
      );
      return;
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      _saveComicToFirestore(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải ảnh từ URL')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa truyện'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImageSourceBottomSheet,
              child: Column(
                children: [
                  Container(
                    width: 140.0, 
                    height: 220.0, 
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _imageFile != null ? FileImage(_imageFile!): (_imageUrl != null ? NetworkImage(_imageUrl!)
                          : const NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png')) as ImageProvider,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey, thickness: 1),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Tên truyện'),
            ),
            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Giới thiệu'),
              maxLines: null,
            ),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: TextField(
                      controller: TextEditingController(text: selectedCategories.join(',')),
                      decoration:const InputDecoration(labelText: 'Thể loại'),
                      readOnly: true,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(top: 30, left: 8.0),
                    child: MultiSelectDialogField(
                      items: categories.map((e) => MultiSelectItem(e, e)).toList(),
                      initialValue: selectedCategories,
                      title: Text('Thể loại'),
                      selectedColor: Colors.blue,
                      buttonText: const Text(' ',style: TextStyle(fontSize: 16)),
                      onConfirm: (results) {
                        setState(() {
                          selectedCategories =List<String>.from(results);
                        });
                      },
                      chipDisplay: MultiSelectChipDisplay.none(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Trạng thái:"),
                Row(
                  children: [
                    Radio(
                      value: 'Đang cập nhật',
                      groupValue: statusValue,
                      onChanged: StatusChange,
                    ),
                    const Text('Đang cập nhật'),
                    Radio(
                      value: 'Hoàn thành',
                      groupValue: statusValue,
                      onChanged: StatusChange,
                    ),
                    const Text('Hoàn thành'),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveComic,
                    icon: const Icon(
                      Icons.save,
                      size: 25,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Lưu thay đổi",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      primary: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
