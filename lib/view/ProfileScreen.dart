import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/AddCategory.dart';
import 'package:manga_application_1/view/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Adjust import path as per your project structure

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User user = await User.fetchUserById(widget.userId);
    if (user != null) {
      setState(() {
        _user = user;
      });
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Màn Hình cá nhân"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCategory()),
              );
            },
          ),
        ],

        
      ),
      body: _user != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: 
                        AssetImage('assets/img/hinh1.jpg') as ImageProvider,
                    radius: 50,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Username: ${_user!.Name}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${_user!.Email}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
