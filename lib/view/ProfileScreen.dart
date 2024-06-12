
import 'package:manga_application_1/view/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _MyHomeScreen();
}

class _MyHomeScreen extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Màn Hình cá nhân"),
       
      ),
     body: Center(
        child: Text('Màn hình cá nhân'),
      ),
    );
    
  }
}