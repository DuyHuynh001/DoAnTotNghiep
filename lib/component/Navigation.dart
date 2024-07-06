import 'dart:async';
import 'package:flutter/material.dart';
import 'package:comicz/view/CommunityScreen.dart';
import 'package:comicz/view/HistoryScreen.dart';
import 'package:comicz/view/HomeScreen.dart';
import 'package:comicz/view/ProfileScreen.dart';

class NavigationScreen extends StatefulWidget {
  final String UserId;

  const NavigationScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedScreen = 0; // mặc định là trang chủ (HomeScreen)
  int _backButtonPressCount = 0;
  late DateTime _lastBackButtonPressTime;

  @override
  void initState() {
    super.initState();
    _lastBackButtonPressTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_backButtonPressCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nhấn lần nữa để thoát khỏi ứng dụng'),
              duration: Duration(seconds: 5),
            ),
          );
          _lastBackButtonPressTime = DateTime.now();
          _backButtonPressCount++;
          return false;
        } else {
          if (DateTime.now().difference(_lastBackButtonPressTime) < Duration(seconds: 3)) {
            return true;
          } else {
            _backButtonPressCount = 0;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Nhấn lần nữa để thoát khỏi ứng dụng'),
                duration: Duration(seconds: 3),
              ),
            );
            return false;
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          children: [
            HomeScreen(UserId: widget.UserId),
            CommunityScreen(UserId: widget.UserId),
            HistoryScreen(UserId: widget.UserId),
            ProfileScreen(UserId: widget.UserId),
          ],
          index: _selectedScreen,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervisor_account_rounded),
              label: 'Cộng đồng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Lịch Sử',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Tôi',
            ),
          ],
          backgroundColor: Color.fromARGB(255, 255, 254, 254),
          currentIndex: _selectedScreen,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (value) {
            if (value != _selectedScreen) {
              setState(() {
                _selectedScreen = value;
              });
            }
          },
        ),
      ),
    );
  }
}
