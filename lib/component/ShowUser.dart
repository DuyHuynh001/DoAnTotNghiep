import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/component/MyCommentTab.dart';
import 'package:manga_application_1/component/MyPostTab.dart';
import 'package:manga_application_1/component/YourCommentTab.dart';
import 'package:manga_application_1/component/YourPostTab.dart';
import 'package:manga_application_1/model/User.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Show extends StatefulWidget {
  final String UserId;
  final String currentId;
  const Show({Key? key, required this.UserId, required this.currentId}) : super(key: key);

  @override
  State<Show> createState() => _ShowState();
}

class _ShowState extends State<Show> {
  int countView = 0;
  int countFavorite = 0;
  int requiredIsRead = 0;
  double progressPercentage = 0;
  int userLevel = 1;
  User user= User(Id: "", Name: "", Image: "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b", Email: "", Status: false, Points: 0, IsRead: 0, Gender: "Không được đặt");

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchFollowerCount();
    _fetchFavoriteCount();
  }

  Future<void> _fetchUserData() async {
    User _user = await User.fetchUserById(widget.UserId);
    if (_user != null) {
      setState(() {
        user = _user;
        _calculateLevel(_user.IsRead);
        _calculateProgress(_user.IsRead);
      });
    }
  }

  Future<void> _fetchFollowerCount() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.UserId)
          .collection('ViewList')
          .get();
      setState(() {
        countView = querySnapshot.size;
      });
    } catch (e) {
      setState(() {
        countView = 0;
      });
    }
  }

  Future<void> _fetchFavoriteCount() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.UserId)
          .collection('FavoritesList')
          .get();
      setState(() {
        countFavorite = querySnapshot.size;
      });
    } catch (e) {
      setState(() {
        countFavorite = 0;
      });
    }
  }

  void _calculateProgress(int currentIsRead) {
    progressPercentage = currentIsRead / requiredIsRead;
  }

  void _calculateLevel(int currentIsRead) {
    if (currentIsRead <= 100) {
      userLevel = 1;
      requiredIsRead = 100;
    } else if (currentIsRead <= 500) {
      userLevel = 2;
      requiredIsRead = 500;
    } else if (currentIsRead <= 1000) {
      userLevel = 3;
      requiredIsRead = 1000;
    } else if (currentIsRead <= 2000) {
      userLevel = 4;
      requiredIsRead = 2000;
    } else if (currentIsRead <= 5000) {
      userLevel = 5;
      requiredIsRead = 5000;
    } else if (currentIsRead <= 10000) {
      userLevel = 6;
      requiredIsRead = 10000;
    } else if (currentIsRead <= 20000) {
      userLevel = 7;
      requiredIsRead = 20000;
    } else if (currentIsRead <= 50000) {
      userLevel = 8;
      requiredIsRead = 50000;
    } else if (currentIsRead <= 100000) {
      userLevel = 9;
      requiredIsRead = 100000;
    } else {
      userLevel = 10;
      requiredIsRead = 999999;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông tin cá nhân"),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                  spreadRadius: 0.5,
                  blurRadius: 7,
                ),
              ],
              borderRadius: BorderRadius.circular(10),
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/img/khungavt.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(user.Image),
                            radius: 35,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      user.Name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 10),
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
                      Row(
                        children: [
                          LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width / 1.5,
                            animation: true,
                            lineHeight: 20.0,
                            animationDuration: 2000,
                            percent: progressPercentage,
                            center: Text(
                              "${user.IsRead}/${requiredIsRead}",
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
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Xu', user.Points.toString()),
                    _buildStatItem('Theo dõi', countView.toString()),
                    _buildStatItem('Yêu thích', countFavorite.toString()),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const PreferredSize(
                    preferredSize: Size.fromHeight(48.0),
                    child: TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.black,
                      indicatorColor: Colors.blue,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 3.0,
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text('Bài viết', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text('Bình luận', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        YourPostTab(UserId: widget.UserId, CurrentUserId: widget.currentId ,),
                        YourCommentTab(UserId: widget.UserId, CurrentUserId: widget.currentId ,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
      ),
      
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
