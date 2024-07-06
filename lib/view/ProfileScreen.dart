import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:comicz/model/User.dart';
import 'package:comicz/component/EditProfile.dart';
import 'package:comicz/view/ChangePasswordScreen.dart';
import 'package:comicz/view/HistoryScreen.dart';
import 'package:comicz/view/LoginScreen.dart';
import 'package:comicz/view/ManagerCategoryScreen.dart';
import 'package:comicz/view/ManagerComicsScreen.dart';
import 'package:comicz/view/MyCommentScreen.dart';
import 'package:comicz/view/UsedTimeScreen.dart';
import 'package:comicz/view/SpinScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileScreen extends StatefulWidget {
  final String UserId;

  const ProfileScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int requiredIsRead = 0;
  double progressPercentage = 0;
  int userLevel = 1;
  bool _isMarked= false ;
  User _user = User(Id: "", Name: "", Image: "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b", Email: "", Status: false, Points: 0, IsRead: 0, Gender: "Không được đặt");
  @override
  void initState() {
    super.initState();
    _fetchUserData();
   
  }
  Future<void> _fetchUserData() async {
    User user = await User.fetchUserById(widget.UserId);
    if (user != null) {
      setState(() {
        _user = user;
        _calculateLevel(_user.IsRead);
        _calculateProgress(_user.IsRead);
      });
      _checkAttendanceStatus(); 
    }
  }

  Future<void> _checkAttendanceStatus() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final docId = widget.UserId;
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

  void _calculateProgress(int currentIsRead) {
      progressPercentage = currentIsRead / requiredIsRead;
  }

  Future<void> _markAttendance() async {
    if (_isMarked) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      await FirebaseFirestore.instance.collection('Attendance').doc(widget.UserId).set({
        'UserId':widget.UserId,
        'date': FieldValue.serverTimestamp(),
        'status': true,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection("User").doc(widget.UserId).update({
        'Points': FieldValue.increment(200),
      });
      setState(() {
        _isMarked = true;
      });
    } catch (e) {
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

  void _calculateLevel(int currentIsRead) {
      if (currentIsRead <= 0) {
        userLevel = 1;
        requiredIsRead = 100;
      } else if (currentIsRead <= 100) {
        userLevel = 1;
        requiredIsRead = 100;
      } else if (currentIsRead <= 500) {
        userLevel = 2;
        requiredIsRead = 500;
      } else if (currentIsRead <= 1000) {
        userLevel = 3;
        requiredIsRead = 1000;
      }else if (currentIsRead <= 2000) {
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
        requiredIsRead=100000;
      } else {
        userLevel = 10;
        requiredIsRead = 999999;
      } 
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
              stream: User.getUserStream(widget.UserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                _user = snapshot.data!;
                _calculateLevel(_user.IsRead);
                _calculateProgress(_user.IsRead);
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
                                        "${_user.IsRead}/${requiredIsRead}",
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
              icon: Icons.menu_book,
              label: "Quản lý truyện",
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>  Managercomics(),
                    transitionsBuilder:(context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
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
            const SizedBox(height: 2),
            _buildFunctionButton(
              icon: Icons.category,
              label: "Quản lý thể loại",
              onPressed: () { 
                 Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>  ManagerCategory(),
                    transitionsBuilder:(context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
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
                  pageBuilder: (context, animation, secondaryAnimation) =>EditProfile(name: _user.Name,image: _user.Image,id:widget.UserId, gender: _user.Gender),
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
                  pageBuilder: (context, animation, secondaryAnimation) => HistoryScreen(UserId:widget.UserId),
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
              icon: Icons.comment,
              label: "Bình luận của tôi",
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MyCommentScreen(UserId:widget.UserId),
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
              icon: Icons.bar_chart_outlined,
              label: "Thời gian hoạt động",
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => UsedTimeScreen(UserId:widget.UserId),
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
            //   icon: Icons.attractions,
            //   label: "Vòng quay may mắn",
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       PageRouteBuilder(
            //       pageBuilder: (context, animation, secondaryAnimation) => SpinWheelPage(),
            //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
            //         const begin = Offset(1.0, 0.0);
            //         const end = Offset.zero;
            //         const curve = Curves.easeInOut;
            //         var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            //         var offsetAnimation = animation.drive(tween);
            //         return SlideTransition(
            //           position: offsetAnimation,
            //           child: child,
            //         );
            //       },
            //     ),
            //     );
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
              icon: Icons.vpn_key,
              label: "Đổi mật khẩu",
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ChangePasswordScreen(email:_user.Email),
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
            const SizedBox(height: 2),
            _buildFunctionButton(
              icon: Icons.logout,
              label: "Đăng xuất",
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLoggedIn', false);
                prefs.setString('UserId', "");
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