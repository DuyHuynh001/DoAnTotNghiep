import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final TextEditingController _categoryName = TextEditingController();
  final TextEditingController _title = TextEditingController();
  bool isLoading = false;
  Future<void> _saveCategory() async {
    // if (_categoryName.text.trim().isEmpty || _title.text.trim().isEmpty) 
    // {
    //   _showErrorDialog("Vui lòng nhập đầy đủ thông tin");
    //   return;
    // }
    setState(() {
      isLoading = true;
    });

    final String name = _categoryName.text;
    final String title = _title.text;
    try{
        await saveCategory(name, title);
        setState(() {
           isLoading = false;
           _categoryName.clear();
           _title.clear();
        });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
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
        title: Text('Add Category'),
      ),
      body: isLoading? Center(child: CircularProgressIndicator()): 
          SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _categoryName,
                    decoration: InputDecoration(labelText: 'Tên thể loại'),
                  ),
                  TextField(
                    controller: _title,
                    decoration: InputDecoration(labelText: 'Mô tả'),
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
                        onPressed:_saveCategory,
                        icon: Icon(Icons.save_as_sharp, size: 25,color: Colors.black,),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Độ cong của góc
                          ),
                          primary: Colors.blue,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          label: Text("Lưu ",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
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

