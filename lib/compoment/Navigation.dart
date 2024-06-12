
import 'package:flutter/material.dart';
import 'package:manga_application_1/view/HistoryScreen.dart';
import 'package:manga_application_1/view/HomeScreen.dart';
import 'package:manga_application_1/view/ProfileScreen.dart';
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedScreen = 0;      // mặc định là trang chủ (HomeScreen)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(        //IndexedStack được sử dụng để hiển thị một trong ba trang tương ứng với chỉ mục được chọn
        children: [
          HomeScreen(),
          HistoryScreen(),
          ProfileScreen()
        ],
        index: _selectedScreen,
      ),
     bottomNavigationBar:BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Truyện Tranh',
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
        currentIndex:_selectedScreen,
        selectedItemColor: Colors.blue,
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