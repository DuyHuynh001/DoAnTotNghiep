import 'package:flutter/material.dart';
class ChapterDetailScreen extends StatelessWidget {
  final String chapterId;
  final String title;

  ChapterDetailScreen({required this.chapterId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            // Các thông tin chi tiết khác của chapter
          ],
        ),
      ),
    );
  }
}

