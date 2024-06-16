import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:manga_application_1/compoment/ActionComic.dart';
import 'package:manga_application_1/compoment/AncientComic.dart';
import 'package:manga_application_1/compoment/FullComic.dart';
import 'package:manga_application_1/compoment/HotComic.dart';
import 'package:manga_application_1/compoment/HumorousComic.dart';
import 'package:manga_application_1/compoment/RecommendComic.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/AddComics.dart';
import 'package:manga_application_1/view/CategoryScreen.dart';
import 'package:manga_application_1/view/NewComicScreen.dart';
import 'package:manga_application_1/view/TopComicScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart'; // Cập nhật đường dẫn tới LoginScreen
import 'SearchScreen.dart'; // Cập nhật đường dẫn tới SearchScreen

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
                    pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
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
                      child: Icon(Icons.search, color: Colors.grey),
                    ),
                    Text(
                      'Tìm kiếm ....',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // IconButton(
              //   icon: const Icon(Icons.logout, color: Colors.black),
              //   onPressed: () async {
              //     SharedPreferences prefs = await SharedPreferences.getInstance();
              //     prefs.setBool('isLoggedIn', false);
              //     Navigator.pushReplacement(
              //       context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: ()  {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>AddComic(),
                    ),
                  );
                },
              ),
            ],
          
          ),
          SliverToBoxAdapter(
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
                        Image.asset('assets/img/hinh1.jpg', fit: BoxFit.cover),
                        Image.asset('assets/img/hinh2.jpg', fit: BoxFit.cover),
                        Image.asset('assets/img/sao.jpg', fit: BoxFit.cover),
                        Image.asset('assets/img/doremon.jpg', fit: BoxFit.cover),
                        Image.asset('assets/img/onepice.jpg', fit: BoxFit.cover),
                      ],
                      onPageChanged: (value) {
                       
                      },
                      autoPlayInterval: 7000,
                      isLoop: true,
                    ),
                  ),
                ),
                 Wrap(
                  children: [
                    ProductCategory(
                      image: "assets/img/bullets.png", 
                      text: "Thể Loại", 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CategoryScreen()),
                        );
                      }),
                    ProductCategory(
                      image: "assets/img/brand.png", 
                      text: "Top Truyện",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TopTruyenScreen()),
                        );
                      },),
                    ProductCategory(
                      image: "assets/img/new.png",
                      text: "Mới Nhất",onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NewTruyenScreen()),
                        );
                      },),
                    ProductCategory(
                      image: "assets/img/reward.png", 
                      text: "Điểm Của Tôi",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CategoryScreen()),
                        );
                      },),
                  ],
                ),
              ],
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(top: 15),
            sliver: const ComicHeader(
              text: 'Truyện Đề Cử',
              icon: Icons.back_hand_rounded,
              color: Colors.blueAccent,
            ),
          ),
          RecommendComic(),
          const ComicHeader(
              text: 'Truyện Hot',
              icon: Icons.local_fire_department_sharp,
              color: Colors.red,
          ),
          HotComic(),
          const ComicHeader(
              text: 'Truyện Hoàn',
              icon: Icons.library_add_check_rounded,
              color: Color.fromARGB(255, 187, 187, 8),
          ),
          FullComic(),
          const ComicHeader(
              text: 'Truyện Hài Hước',
              icon: Icons.add_reaction_rounded,
              color: Colors.green
          ),
          HumorousComic(),
          const ComicHeader(
              text: 'Truyện Hành Động',
              icon: Icons.sports_gymnastics_outlined,
              color: Colors.black
          ),
          ActionComic(),
          const ComicHeader(
              text: 'Truyện Cổ Đại',
              icon: Icons.access_time,
              color: Color.fromARGB(255, 146, 52, 18)
          ),
          AccientComic()
        ],
      ),
    );
  }
}

class ProductCategory extends StatelessWidget {
  final String image;
  final String text;
  final VoidCallback onTap;
  const ProductCategory({Key? key, required this.image, required this.text, required this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 4.5,
        height: 70,
        margin: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: 51,
              height: 51,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 5),
            Text(
              text,
              softWrap: true,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
class ComicHeader extends StatelessWidget {
  final String text;
  final  IconData icon;
  final Color color;
    const ComicHeader({Key? key, required this.icon, required this.text, required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon , color: color, size: 25,),
                const SizedBox(width: 8.0),
                Text(
                  text,
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
             const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey,),
          ],
        ),
      ),
    );
  }
}