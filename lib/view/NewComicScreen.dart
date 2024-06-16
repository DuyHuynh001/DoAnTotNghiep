import 'package:flutter/material.dart';

class NewTruyenScreen extends StatefulWidget {
  const NewTruyenScreen({super.key});

  @override
  State<NewTruyenScreen> createState() => _NewTruyenScreenState();
}

class _NewTruyenScreenState extends State<NewTruyenScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Truyện mới'),
      ),
      body: Center(
        child: Text('Đây là màn hình danh sách truyện mới'),
      ),
    );
  }
}
