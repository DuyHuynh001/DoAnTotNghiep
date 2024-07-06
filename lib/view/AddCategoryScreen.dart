import 'package:flutter/material.dart';
import 'package:comicz/model/Category.dart';
import 'package:comicz/model/Community.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _categoryName = TextEditingController();
  final TextEditingController _title = TextEditingController();

  Future<void> _saveCategory() async {
    final String name = _categoryName.text;
    final String title = _title.text;
    if (name.trim().isEmpty || title.trim().isEmpty) {
      _showErrorDialog("Vui lòng nhập đầy đủ thông tin");
      return;
    }
    await Category.saveCategory(name, title);
    setState(() {
      _categoryName.clear();
      _title.clear();
    });
    Navigator.of(context).pop(true);
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
        title: Text('Thêm thể loại'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _categoryName,
                decoration: const InputDecoration(labelText: 'Tên thể loại'),
              ),
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: null,
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveCategory,
                      icon: const Icon(
                        Icons.save_as_sharp,
                        size: 25,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      label: const Text("Lưu ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
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
