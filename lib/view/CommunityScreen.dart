import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  final String UserId;
  const CommunityScreen({super.key, required this.UserId});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Diễn đàn'),
      ),
      body: Center(
        child: Text('Đây là màn hình diễn đàn'),
      ),
    );
  }
}
