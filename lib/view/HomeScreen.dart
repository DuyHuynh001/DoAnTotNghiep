import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:manga_application_1/view/SearchScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart'; // Cập nhật đường dẫn tới LoginScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomeScreen();
}

class _MyHomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBar(
        backgroundColor: Colors.transparent,
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(),
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
          child: Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.search,color: Colors.grey,),
                ),
                Text('Tìm kiếm ....', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black,),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
        floating: true, // Đặt giá trị này thành true nếu bạn muốn AppBar hiển thị khi cuộn
        snap: true, // Đặt giá trị này thành true nếu bạn muốn AppBar tự động cuộn vào hoặc ra
      ),
      SliverToBoxAdapter(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: ImageSlideshow(
                  width: double.infinity,
                  height: 200,
                  initialPage: 0,
                  indicatorColor: Colors.blue,
                  indicatorBackgroundColor: Colors.grey,
                  children: [
                    Image.asset(
                      'assets/img/hinh1.jpg',
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/img/hinh2.jpg',
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/img/sao.jpg',
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/img/doremon.jpg',
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/img/onepice.jpg',
                      fit: BoxFit.cover,
                    ),
                  ],
                  onPageChanged: (value) {
                    print('Page changed: $value');
                  },
                  autoPlayInterval: 7000,
                  isLoop: true,
                ),
              ),
            )
            ],
          ),
        ),
      ),
      ],
    ),
    );
  }
}
