import 'package:flutter/material.dart';

class TopTruyenScreen extends StatefulWidget {
  const TopTruyenScreen({super.key});

  @override
  State<TopTruyenScreen> createState() => _TopTruyenScreenState();
}

class _TopTruyenScreenState extends State<TopTruyenScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Top Truyện'),
      ),
      body: Center(
        child: Text('Đây là màn hình Top Truyện'),
      ),
    );
  }
}
