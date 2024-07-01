import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/model/User.dart';
import 'package:manga_application_1/component/EditProfile.dart';
import 'package:manga_application_1/view/HistoryScreen.dart';
import 'package:manga_application_1/view/IntroduceScreen.dart';
import 'package:manga_application_1/view/LoginScreen.dart';
import 'package:manga_application_1/view/MyCommentScreen.dart';
import 'package:manga_application_1/view/tam1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentIsRead =0;
  int requiredIsRead = 0;
  double progressPercentage = 0;
  int userLevel = 1;
  bool _isMarked= false ;
  User _user = User(Id: "", Name: "", Image: "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b", Email: "", Status: false, Points: 0, IsRead: 0);
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
    }
    currentIsRead=_user.IsRead;
    _checkAttendanceStatus(); 
    _calculateLevel();
    _calculateProgress();
  }

  Future<void> _checkAttendanceStatus() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final docId = widget.userId;
    try {
      final doc = await FirebaseFirestore.instance.collection('Attendance').doc(docId).get();
      if (doc.exists) {
        final serverTimestamp = (doc['date'] as Timestamp).toDate();
        final docDate = DateTime(serverTimestamp.year, serverTimestamp.month, serverTimestamp.day);
        setState(() {
          _isMarked = today == docDate;
        });
      } else {
        setState(() {
          _isMarked = false;
        });
      }
    } catch (e) {
      setState(() {
        _isMarked = false;
      });
    }
  }

  void _calculateProgress() {
    setState(() {
      progressPercentage = currentIsRead / requiredIsRead;
    });
  }

  Future<void> _markAttendance() async {
    if (_isMarked) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      await FirebaseFirestore.instance.collection('Attendance').doc(widget.userId).set({
        'userId':widget.userId,
        'date': FieldValue.serverTimestamp(),
        'status': true,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection("User").doc(widget.userId).update({
        'Points': FieldValue.increment(200),
      });
      setState(() {
        _isMarked = true;
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  void _showNotification(String messenger) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông báo'),
          content: Text(messenger),
          actions: <Widget>[
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );  
  }

  void _calculateLevel() {
    setState(() {
      if (currentIsRead>0 && currentIsRead <= 100) {
        userLevel = 1;
        requiredIsRead = 500;
      } else if (currentIsRead <= 500) {
        userLevel = 2;
        requiredIsRead = 1000;
      } else if (currentIsRead <= 1000) {
        userLevel = 3;
        requiredIsRead = 2000;
      }else if (currentIsRead <= 2000) {
        userLevel = 4;
        requiredIsRead = 5000;
      } else if (currentIsRead <= 5000) {
        userLevel = 5;
        requiredIsRead = 10000;
      } else if (currentIsRead <= 10000) {
        userLevel = 6;
        requiredIsRead = 20000;
      } else if (currentIsRead <= 20000) {
        userLevel = 7;
        requiredIsRead = 30000;
      } else if (currentIsRead <= 30000) {
        userLevel = 8;
        requiredIsRead = 50000;
      } else if (currentIsRead <= 50000) {
        userLevel = 9;
      } else {
        userLevel = 10;
        requiredIsRead = 999999;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: SafeArea( 
      child:SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StreamBuilder<User>(
              stream: User.getUserStream(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                _user = snapshot.data!;
                return Container(
                  decoration:  BoxDecoration(
                    image: const DecorationImage(
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
                                    backgroundImage: NetworkImage(_user.Image),
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
                                        "${currentIsRead}/${requiredIsRead}",
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
                          padding: EdgeInsets.only(top: 10, left: 50, right: 50, bottom: 10),
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
                              Column(
                                children: [
                                  Text(
                                    _user.Points.toString(),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
                                  ),
                                  const Text(
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
                );
              }
            }
          ),
          if(_user.Status) _buildAdminFunctions(),
          _buildMenberFunctions(),
          _buildSettings(),
         ],
        ),
      ),
      ),
    );
  }

  Widget _buildAdminFunctions() {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Chức năng quản lý",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildAdminFunctionCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminFunctionCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFunctionButton(
              icon: Icons.today,
              label: "Quản lý truyện",
              onPressed: () {
              },
            ),
            const SizedBox(height: 2),
            _buildFunctionButton(
              icon: Icons.favorite_border,
              label: "Quản lý thể loại",
              onPressed: () {
                // Implement navigation to favorites list
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Cài đặt",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSettingsCard(),
          ),
        ],
      ),
    );
  }
  Widget _buildMenberFunctions() {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Chức năng người dùng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildMemberFunctionCard(),
          ),
        ],
      ),
    );
  }
   Widget _buildMemberFunctionCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFunctionButton(
              icon: Icons.today,
              label: _isMarked? "Đã điểm danh": "Điểm danh",
              onPressed: (){
                if(_isMarked)
                {
                  _showNotification("Bạn đã điểm danh hôm nay rồi");
                }
                else{
                  _showNotification("Chúc mừng bạn nhận được 200 xu");
                  _markAttendance();
                }

              }
            ),
            _buildFunctionButton( 
              icon: Icons.person,
              label: "Đổi thông tin cá nhân",
              onPressed: () async {
                final result = await  Navigator.push(
                 context,
                  PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>EditProfile(name: _user.Name,image: _user.Image,id:widget.userId),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
                );
                if (result == true) {
                  _fetchUserData();
                }
              },
            ),
            _buildFunctionButton(
              icon: Icons.access_time_outlined,
              label: "Lịch sử của tôi",
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => HistoryScreen(UserId:widget.userId),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
                );
              },
            ),
            _buildFunctionButton(
              icon: Icons.messenger,
              label: "Bình luận của tôi",
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MyCommentScreen(UserId:widget.userId),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
                );
              },
            ),
            _buildFunctionButton(
              icon: Icons.attractions,
              label: "Vòng quay may mắn",
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => SpinWheelPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
                );
              },
            ),
            // _buildFunctionButton(
            //   icon: Icons.account_box_sharp,
            //   label: "Khung avatar của tôi",
            //   onPressed: () {
               
            //   },
            // ),
            // _buildFunctionButton(
            //   icon: Icons.accessibility,
            //   label: "Level của tôi",
            //   onPressed: () {
               
            //   },
            // ),
          ],
        ),
      ),
    );
  }


  Widget _buildSettingsCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFunctionButton(
              icon: Icons.error_outline_rounded,
              label: "Giới thiệu sản phẩm",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IntroduceScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            _buildFunctionButton(
              icon: Icons.vpn_key,
              label: "Đổi mật khẩu",
              onPressed: () {
                
              },
            ),
            const SizedBox(height: 2),
            _buildFunctionButton(
              icon: Icons.logout,
              label: "Đăng xuất",
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLoggedIn', false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}