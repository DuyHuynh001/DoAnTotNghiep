import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manga_application_1/component/ComicSelection.dart';
import 'package:manga_application_1/model/load_data.dart';

class AddPost extends StatefulWidget {
  final String UserId;
   final Function()? onPostAdded;
  AddPost({Key? key,required this.UserId, required this.onPostAdded});

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _postContentController = TextEditingController();
  Comics? _selectedComic;
  File? _image; // Thay đổi kiểu dữ liệu thành File
 
 @override
  void dispose() {
    _postContentController.dispose();
    super.dispose();
  }
  
  void _removeImage() {
    setState(() {
      _image = null;
    });
  }
  
  void _selectComic() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ComicSelection(
          onComicSelected: (selectedComic) {
            setState(() {
              _selectedComic = selectedComic;
              print(_selectedComic);
            });
            Navigator.of(context).pop(); 
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
    

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
  try {
    Map<String, dynamic> postData = {
      'content': _postContentController.text,
      'userId': widget.UserId,
      'timestamp': FieldValue.serverTimestamp(),
      'like': 0,

    };

    if (_image != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('Post').child(fileName);
      UploadTask uploadTask = storageReference.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      postData['image_url'] = imageUrl;
    } else {
      postData['image_url'] = "";
    }

    if (_selectedComic != null) {
      postData['comicId'] = _selectedComic!.id;
    } else {
      postData['comicId'] = "";
    }

    await FirebaseFirestore.instance.collection('Community').add(postData);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng bài thành công!')));
    if (widget.onPostAdded != null) {
        widget.onPostAdded!();
      }

      // Navigate back
      Navigator.of(context).pop();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng bài thất bại: $e')));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng bài'),
        actions: [
          Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.red.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.lightBlue, width: 2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(5, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Đăng',style: TextStyle(color: Colors.white, fontSize: 16), ),
                  onPressed: () {
                    _uploadPost();
                  },
                ),
              ],
            ),
          )
        ],
      ),
      body:SingleChildScrollView(
       child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _postContentController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Viết bài...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Column(children: [
            const Align(alignment: Alignment.centerLeft,child: Text("Gắn thẻ truyện", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),),
            Row(
              children: [
                GestureDetector(
                  onTap: _selectComic,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      image: _selectedComic != null? DecorationImage(image: NetworkImage(_selectedComic!.image),fit: BoxFit.cover,): null,
                    ),
                    child: _selectedComic == null ?const Center( child: Icon(Icons.add), ) : null,
                  ),
                ),
                if (_selectedComic != null)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: Text(_selectedComic!.name),),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedComic = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              const Align(alignment: Alignment.centerLeft,child: Text("Chọn ảnh từ máy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),),
              Row( children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _image != null? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file( _image!, fit: BoxFit.cover, ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: const Icon( Icons.cancel,color: Colors.red),
                          ),
                        ),
                      ],
                    ): Center(child: Icon(Icons.add)),
                  ), 
                ),
              ],),
              ],
            ),
          ],
        ),   
      ),
    ),
  ); 
  }
}

