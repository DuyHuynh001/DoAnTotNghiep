import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:manga_application_1/component/ActionComic.dart';
import 'package:manga_application_1/component/AncientComic.dart';
import 'package:manga_application_1/component/FullComic.dart';
import 'package:manga_application_1/component/HotComic.dart';
import 'package:manga_application_1/component/AdventureComic.dart';
import 'package:manga_application_1/component/ToolItem.dart';
import 'package:manga_application_1/view/AddComicScreen.dart';
import 'package:manga_application_1/view/CategoryDetailScreen.dart';
import 'package:manga_application_1/view/CategoryScreen.dart';
import 'package:manga_application_1/view/ListFullComicScreen.dart';
import 'package:manga_application_1/view/ListHotComicScreen.dart';
import 'package:manga_application_1/view/NewComicScreen.dart';
import 'package:manga_application_1/view/ProfileScreen.dart';
import 'package:manga_application_1/view/SearchScreen.dart';
import 'package:manga_application_1/view/TopComicScreen.dart';

class HomeScreen extends StatefulWidget {
  final String UserId;
  const HomeScreen({super.key, required this.UserId});

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
                    Text('Tìm kiếm ....', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: ()  {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>AddComicScreen(),
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
                    ToolItem(
                      image: "assets/img/bullets.png", 
                      text: "Thể Loại", 
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => CategoryScreen(UserId: widget.UserId,),
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
                      }
                    ),
                    ToolItem(
                      image: "assets/img/brand.png", 
                      text: "Top Truyện",
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => TopTruyenScreen(UserId: widget.UserId,),
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
                    ToolItem(
                      image: "assets/img/new.png",
                      text: "Mới Nhất",onTap: () {
                         Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => ListNewComicScreen(UserId: widget.UserId,),
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
                    ToolItem(
                      image: "assets/img/reward.png", 
                      text: "Điểm Của Tôi",
                      onTap: () {
                         Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => ProfileScreen(userId: widget.UserId,),
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
                      },),
                  ],
                ),
              ],
            ),
          ),
          ComicHeader(
              text: 'Truyện Hot',
              icon: Icons.local_fire_department_sharp,
              color: Colors.red,
              UserId: widget.UserId,
              name: "Hot"
          ),
          HotComic(UserId: widget.UserId,),
          ComicHeader(
              text: 'Truyện Hoàn',
              icon: Icons.library_add_check_rounded,
              color: Color.fromARGB(255, 187, 187, 8),
              UserId: widget.UserId,
              name: "Hoàn",
          ),
          FullComic(UserId: widget.UserId,),
          ComicHeader(
              text: 'Truyện Phiêu Lưu',
              icon: Icons.add_reaction_rounded,
              color: Colors.green,
              name: "Adventure",
              UserId: widget.UserId,
          ),
          AdventureComic(UserId: widget.UserId,),
          ComicHeader(
              text: 'Truyện Hành Động',
              icon: Icons.sports_gymnastics_outlined,
              color: Colors.black,
              name: "Action",
              UserId: widget.UserId,
          ),
          ActionComic(UserId: widget.UserId,),
          ComicHeader(
              text: 'Truyện Cổ Đại',
              icon: Icons.access_time,
              color: Color.fromARGB(255, 146, 52, 18),
              name:"Cổ Đại",
              UserId: widget.UserId,
          ),
          AncientComic(UserId: widget.UserId,)
        ],
      ),
    );
  }
}



class ComicHeader extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final String name; 
  final String UserId;

  const ComicHeader({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.UserId,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          navigateToCategory(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 25),
                  const SizedBox(width: 8.0),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToCategory(BuildContext context) {
    Widget destinationWidget;
    switch (name) {
      case 'Hot':
        destinationWidget = ListHotComicScreen(UserId: UserId);
        break;
      case 'Hoàn':
        destinationWidget = ListFullComicScreen(UserId: UserId);
        break;
      default:
       destinationWidget = CategoryDetailScreen(Name: name, Title: "", UserId: UserId);
        break;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destinationWidget,
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
  }
}