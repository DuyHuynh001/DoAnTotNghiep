import 'package:flutter/material.dart';

class TopUser extends StatefulWidget {
  const TopUser({super.key});

  @override
  State<TopUser> createState() => _TopUserState();
}

class _TopUserState extends State<TopUser> {
  @override
  Widget build(BuildContext context) {
    return  Center(
        child: Text("đây là màn hình top user"),
      );
    
  }
}