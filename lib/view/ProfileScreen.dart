import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/AddCategoryScreen.dart';
import 'package:manga_application_1/view/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  double currentIsRead = 1000;
  double requiredIsRead = 10000;
  double progressPercentage = 0.0;
  int userLevel = 1;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _calculateProgress();
  }

  Future<void> _fetchUserData() async {
    User user = await User.fetchUserById(widget.userId);
    if (user != null) {
      setState(() {
        _user = user;
      });
    } else {
      // Handle when user data cannot be loaded
    }
  }

  void _calculateProgress() {
    setState(() {
      progressPercentage = currentIsRead / requiredIsRead;
    });
  }

  void _calculateLevel() {
    setState(() {
      if (currentIsRead >= 1000) {
        userLevel = 3;
      } else if (currentIsRead >= 100) {
        userLevel = 2;
      } else {
        userLevel = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _calculateLevel();

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
                MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
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
                    backgroundImage: AssetImage('assets/img/hinh1.jpg'),
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
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.1),
                          spreadRadius: 3,
                          blurRadius: 7,
                        
                        ),
                      ],
                    ),
                    child: Text(
                      'Level: $userLevel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black45,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiến độ đọc:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width - 100,
                            animation: true,
                            lineHeight: 20.0,
                            animationDuration: 2000,
                            percent: progressPercentage,
                            center: Text(
                              "${(progressPercentage * 100).toStringAsFixed(1)}%",
                              style: TextStyle(color: Colors.white),
                            ),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: Colors.greenAccent,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
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
