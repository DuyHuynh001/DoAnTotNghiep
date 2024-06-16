import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:manga_application_1/model/load_data.dart';
class AddComic extends StatefulWidget {
  const AddComic({super.key});

  @override
  State<AddComic> createState() => _AddComicState();
}
class _AddComicState extends State<AddComic> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _urlImage = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _category = TextEditingController();
  final TextEditingController _chapterUrl = TextEditingController();

  String statusValue = 'Đang cập nhật'; // Giá trị mặc định cho radio button
  bool isLoading = false;
  bool isRecommend = false;
  bool isHot = false;
  bool isNew = false;

  Future<void> _saveComic() async {
    if (_name.text.trim().isEmpty || _urlImage.text.trim().isEmpty || _description.text.trim().isEmpty || _category.text.trim().isEmpty || _chapterUrl.text.trim().isEmpty) 
    {
      _showErrorDialog("Vui lòng nhập đầy đủ thông tin");
      return;
    }
    setState(() {
      isLoading = true;
    });
    
    final String name = _name.text;
    final String urlImage = _urlImage.text;
    final String description = _description.text;
    final List<String> categories = _category.text.split(','); // Tách các thể loại
    final String chaptersUrl = _chapterUrl.text;
    try {
      final response = await http.get(Uri.parse(chaptersUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        await saveComicAndChaptersToFirestore(name, statusValue, urlImage, description, isHot, isNew, isRecommend, categories, data['data']['item']);
        setState(() {
           isLoading = false;
           isHot = false;
           isRecommend = false;
           isNew = false;
          _name.clear();
          _urlImage.clear();
          _description.clear();
          _category.clear();
          _chapterUrl.clear();
          statusValue = 'Đang cập nhật';
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  void _handleStatusChange(String? value) {
    setState(() {
      statusValue = value ?? 'Đang cập nhật'; 
    });
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Comic'),
      ),
      body: isLoading? Center(child: CircularProgressIndicator()): 
          SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(labelText: 'Tên truyện'),
                  ),
                  TextField(
                    controller: _urlImage,
                    decoration: InputDecoration(labelText: 'Ảnh bìa'),
                  ),
                  TextField(
                    controller: _description,
                    decoration: InputDecoration(labelText: 'Giới thiệu'),
                  ),
                  TextField(
                    controller: _category,
                    decoration: InputDecoration(labelText: 'Thể loại'),
                  ),
                  TextField(
                    controller: _chapterUrl,
                    decoration: InputDecoration(labelText: 'Đường dẫn danh sách chương'),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Trạng thái:", style: TextStyle(fontSize: 16),),
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
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                 Row(
                  children: [
                    Text("Truyện Đề Cử: ",style: TextStyle(fontSize: 16),),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Checkbox(
                            value: isRecommend,
                            onChanged: (bool? newValue) {
                              setState(() {
                                isRecommend = newValue ?? false;
                              });
                            },
                            checkColor: Colors.white, 
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Row(
                  children: [
                    Text("Truyện Hot: ",style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Checkbox(
                            value: isHot,
                            onChanged: (bool? newValue) {
                              setState(() {
                                isHot = newValue ?? false;
                              });
                            },
                            checkColor: Colors.white, 
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Row(
                  children: [ 
                    Text("Truyện Mới: ",style: TextStyle(fontSize: 16),),
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
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:_saveComic,
                        icon: Icon(Icons.save_as_sharp, size: 25,color: Colors.black,),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Độ cong của góc
                          ),
                          primary: Colors.blue,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          label: Text("Lưu Truyện",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
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

