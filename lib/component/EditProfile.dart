import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  final String name;
  final String image;
  final String id;
  final String gender;

  EditProfile({required this.name, required this.image, required this.id, required this.gender});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;
  String? _gender; // Biến để lưu giới tính đã chọn

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _imageUrl = widget.image;
    _gender = widget.gender;
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

  // lưu ảnh vào stogare và firestore
  Future<void> _uploadImage(File image) async {
    setState(() {
      _isLoading = true;
    });
   
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('avatars/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() async {
      try {
        String downloadUrl = await storageReference.getDownloadURL();
        _saveProfileToFirestore(downloadUrl);
      } catch (onError) {
        print("Error");
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfileToFirestore(String imageUrl) async {
    await FirebaseFirestore.instance.collection('User').doc(widget.id).update({
      'Name': _nameController.text,
      'Image': imageUrl,
      'Gender': _gender, // Cập nhật giới tính vào Firestore
    });
    setState(() {
      _imageUrl = imageUrl;
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
      _saveProfileToFirestore(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải ảnh từ URL')),
      );
    }
  }

  void _saveProfile() {
     if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập biệt danh trước khi lưu')),
      );
      return; 
    }
    if (_imageFile != null) {
      _uploadImage(_imageFile!);
    } else if (_imageUrlController.text.isNotEmpty) {
      _setImageFromUrl(_imageUrlController.text);
    } else {
      _saveProfileToFirestore(_imageUrl ?? '');
    }
    Navigator.of(context).pop(true);
  }

  void _showImageSourceBottomSheet() {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa thông tin cá nhân'),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator())
        : ListView(
            padding: EdgeInsets.all(16.0),
            children: [
            ListTile(
              title: Text('Ảnh đại diện'),
              trailing: GestureDetector(
                onTap: _showImageSourceBottomSheet,
                child: Column(
                  children: [
                    Container(
                      width: 56.0, 
                      height: 56.0, 
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
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
            ),
            ListTile(
              title: Text('Biệt danh'),
              subtitle: TextField(
                controller: _nameController,
              ),
            ),
            ListTile(
              title: Text('Giới tính'),
              trailing: DropdownButton<String>(
                value: _gender,
                
                onChanged: (String? value) {
                  setState(() {
                    _gender = value;
                  });
                },
                items: <String>['Nam', 'Nữ', 'Không được đặt'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text('ID'),
              subtitle: Text(widget.id),
            ),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Lưu'),
            ),
          ],
        ),
    );
  }
}
