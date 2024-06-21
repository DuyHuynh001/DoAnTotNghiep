import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final String UserId;
  const HistoryScreen({super.key, required this.UserId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Màn Hình Lịch Sử"),
        
      ),
     body: Center(
        child: Text('Lịch sử dọc truyện'),
      ),
    );
  }
}