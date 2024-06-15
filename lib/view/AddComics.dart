import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
class AddComic extends StatefulWidget {
  const AddComic({super.key});

  @override
  State<AddComic> createState() => _AddComicState();
}

class _AddComicState extends State<AddComic> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _urlImageController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _chaptersUrlController = TextEditingController();

  bool isLoading = false;

  Future<void> _saveComic() async {
    setState(() {
      isLoading = true;
    });

    final String name = _nameController.text;
    final String status = _statusController.text;
    final String urlImage = _urlImageController.text;
    final String content = _contentController.text;
    final List<String> categories = _categoryController.text.split(','); // Tách các thể loại
    final String chaptersUrl = _chaptersUrlController.text;

    try {
      final response = await http.get(Uri.parse(chaptersUrl));
      if (response.statusCode == 200) {
        // Decode JSON
        Map<String, dynamic> data = json.decode(response.body);

        // Lưu thông tin truyện tranh và các chương vào Firestore
        await saveComicAndChaptersToFirestore(name, status, urlImage, content, categories, data['data']['item']);

        setState(() {
          isLoading = false;
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

  Future<void> saveComicAndChaptersToFirestore(String name, String status, String urlImage, String content, List<String> categories, Map<String, dynamic> comicData) async {
    try {
      CollectionReference comicsCollection = FirebaseFirestore.instance.collection('Comics');

      // Data to be added for the comic
      Map<String, dynamic> comicDetails = {
        'name': name,
        'status': status,
        'image': urlImage,
        'description': content,
        'source': 'otruyen', // Thêm nguồn nếu cần
        'genre': categories,
      };

      // Add comic details to 'comics' collection
      DocumentReference comicDoc = await comicsCollection.add(comicDetails);

      // Add chapters to a subcollection of the comic document
      CollectionReference chaptersCollection = comicDoc.collection('chapters');
      for (var server in comicData['chapters']) {
        for (var chapter in server['server_data']) {
          // Data to be added for each chapter
          Map<String, dynamic> chapterData = {
            'chapterApiData': chapter['chapter_api_data'] ?? '',
          };
       
        // Sắp xếp các chương theo thuộc tính chapter_name hoặc một thuộc tính khác nếu có
         String chapterId = "C"+ chapter['chapter_name'];
         
        await chaptersCollection.doc(chapterId).set(chapterData);
        }
      }

      print('Comic and chapters added to Firestore successfully!');
    } catch (e) {
      print('Error adding comic and chapters to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Comic'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _statusController,
                    decoration: InputDecoration(labelText: 'Status'),
                  ),
                  TextField(
                    controller: _urlImageController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                  ),
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(labelText: 'Content'),
                  ),
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(labelText: 'Category (comma separated)'),
                  ),
                  TextField(
                    controller: _chaptersUrlController,
                    decoration: InputDecoration(labelText: 'Chapters Data URL'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveComic,
                    child: Text('Save Comic'),
                  ),
                ],
              ),
            ),
    );
  }
}
