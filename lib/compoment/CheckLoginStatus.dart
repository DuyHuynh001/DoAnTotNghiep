import 'package:flutter/material.dart';
import 'package:manga_application_1/compoment/Navigation.dart';
import 'package:manga_application_1/view/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CheckLogin extends StatefulWidget {
  @override
  _CheckLoginState createState() => _CheckLoginState();
}

class _CheckLoginState extends State<CheckLogin> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }
  // kiểm tra xem đã đăng nhập trước đó chưa
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String isUserId = prefs.getString('UserId')??"";
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) =>NavigationScreen(UserId: isUserId,)));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}