import 'package:flutter/material.dart';
import 'package:manga_application_1/model/Community.dart';
import 'package:manga_application_1/model/User.dart';
import 'package:manga_application_1/view/AddCategoryScreen.dart';
import 'package:manga_application_1/view/LoginScreen.dart';
import 'package:manga_application_1/view/tam.dart';
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
           Container(
            decoration:  BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/background5.jpg'),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/img/khungavt.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(_user!.Image),
                            radius: 35,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${_user!.Name}',style: const TextStyle( fontSize: 20,   fontWeight: FontWeight.bold, ),),
                          ],
                        ),
                        SizedBox(height: 17),
                        Row(
                          children: [
                            LinearPercentIndicator(
                              width: MediaQuery.of(context).size.width / 1.8,
                              animation: true,
                              lineHeight: 20.0,
                              animationDuration: 2000,
                              percent: progressPercentage,
                              center: Text(
                                "${(progressPercentage * 100).toStringAsFixed(1)}%",
                                style: TextStyle(color: Colors.white),
                              ),
                              linearStrokeCap: LinearStrokeCap.roundAll,
                              progressColor: Color.fromARGB(255, 58, 144, 255),
                              backgroundColor: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 40, right: 40, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
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
                          style: const TextStyle(
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
                      const Column(
                        children: [
                          Text(
                            "300",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Xu của tôi",
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider(color: Colors.grey, thickness: 1),
          Header()
          ],
        
        ),
      ),
    );
  }
}
