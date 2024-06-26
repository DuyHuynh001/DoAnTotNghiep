import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:manga_application_1/model/load_data.dart';

class AddComicScreen extends StatefulWidget {
  const AddComicScreen({super.key});

  @override
  State<AddComicScreen> createState() => _AddComicScreenState();
}

class _AddComicScreenState extends State<AddComicScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _urlImage = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _chapterUrl = TextEditingController();

  String statusValue = 'Đang cập nhật';
  bool isLoading = false;
  bool isNew = false;

  List<String> categories = [];
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Category').get();
      final List<String> loadedCategories = snapshot.docs.map((doc) => doc['Name'] as String).toList();
      setState(() {
        categories = loadedCategories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void _handleStatusChange(String? value) {
    setState(() {
      statusValue = value ?? 'Đang cập nhật';
    });
  }

  Future<void> _saveComic() async {
    if (_name.text.trim().isEmpty || _urlImage.text.trim().isEmpty || _description.text.trim().isEmpty || selectedCategories.isEmpty || _chapterUrl.text.trim().isEmpty) {
      _showErrorDialog("Vui lòng nhập đầy đủ thông tin");
      return;
    }
    setState(() {
      isLoading = true;
    });
    final String name = _name.text;
    final String urlImage = _urlImage.text;
    final String description = _description.text;
    final String chaptersUrl = _chapterUrl.text;

    try {
      final response = await http.get(Uri.parse(chaptersUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        await saveComicAndChaptersToFirestore(name, statusValue, urlImage, description, isNew, selectedCategories, data['data']['item']);
        
        setState(() {
          isLoading = false;
          isNew = false;
          _name.clear();
          _urlImage.clear();
          _description.clear();
          selectedCategories.clear();
          _chapterUrl.clear();
          statusValue = 'Đang cập nhật';
        });
        showSnackBar('Thêm truyện thành công');
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
      showSnackBar('Đã xảy ra lỗi khi thêm truyện');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
           shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),),
          title: Text('THÔNG BÁO!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16),),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Comic'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Tên truyện'),
                  ),
                  TextField(
                    controller: _urlImage,
                    decoration: InputDecoration(labelText: 'Ảnh bìa'),
                  ),
                  TextField(
                    controller: _description,
                    decoration: const InputDecoration(labelText: 'Giới thiệu'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: TextEditingController(text: selectedCategories.join(',')),
                          decoration: const InputDecoration(labelText: 'Thể loại'),
                          readOnly: true,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Expanded(
                          flex: 0,
                          child: MultiSelectDialogField(
                            items: categories.map((e) => MultiSelectItem(e, e)).toList(),
                            title: Text('Thể loại'),
                            selectedColor: Colors.blue,
                            buttonText: Text(' ', style: TextStyle(fontSize: 16)),
                            onConfirm: (results) {
                              setState(() {
                                selectedCategories = List<String>.from(results);
                              });
                            },
                            chipDisplay: MultiSelectChipDisplay.none(),
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _chapterUrl,
                    decoration: const InputDecoration(labelText: 'Đường dẫn danh sách chương'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Trạng thái:",style: TextStyle(fontSize: 16),),
                      Row(
                        children: [
                          Radio(
                            value: 'Đang cập nhật',
                            groupValue: statusValue,
                            onChanged: _handleStatusChange,
                          ),
                          Text('Đang cập nhật'),
                          Radio(
                            value: 'Hoàn thành',
                            groupValue: statusValue,
                            onChanged: _handleStatusChange,
                          ),
                          Text('Hoàn Thành'),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 1),
                  Row(
                    children: [
                      const Text("Truyện Mới: ",style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Checkbox(
                              value: isNew,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  isNew = newValue ?? false;
                                });
                              },
                              checkColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 1),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveComic,
                          icon: const Icon(
                            Icons.save_as_sharp,
                            size: 25,
                            color: Colors.black,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Độ cong của góc
                            ),
                            primary: Colors.blue,
                            side: const BorderSide(color: Colors.black),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          label: const Text(
                            "Lưu Truyện",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
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
