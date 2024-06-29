import 'package:flutter/material.dart';
import 'package:manga_application_1/view/CommunityScreen.dart';
import 'package:manga_application_1/view/HistoryScreen.dart';
import 'package:manga_application_1/view/HomeScreen.dart';
import 'package:manga_application_1/view/ProfileScreen.dart';

class NavigationScreen extends StatefulWidget {
  final String UserId;

  const NavigationScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedScreen = 0; // mặc định là trang chủ (HomeScreen)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        //IndexedStack được sử dụng để hiển thị một trong bốn trang tương ứng với chỉ mục được chọn
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
    );
  }
}
