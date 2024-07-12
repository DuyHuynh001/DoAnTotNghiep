import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:comicz/component/ActionComic.dart';
import 'package:comicz/component/AncientComic.dart';
import 'package:comicz/component/FullComic.dart';
import 'package:comicz/component/HotComic.dart';
import 'package:comicz/component/AdventureComic.dart';
import 'package:comicz/component/ToolItem.dart';
import 'package:comicz/view/CategoryDetailScreen.dart';
import 'package:comicz/view/CategoryScreen.dart';
import 'package:comicz/view/ListFullComicScreen.dart';
import 'package:comicz/view/ListHotComicScreen.dart';
import 'package:comicz/view/NewComicScreen.dart';
import 'package:comicz/view/ProfileScreen.dart';
import 'package:comicz/view/SearchScreen.dart';
import 'package:comicz/view/TopComicScreen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String UserId;
  const HomeScreen({super.key, required this.UserId});

  @override
  State<HomeScreen> createState() => _MyHomeScreen();
}

class _MyHomeScreen extends State<HomeScreen> {
  bool _shouldResetData=false;

  @override
  void initState() {
    super.initState();
    refreshData();
  }
  void resetData() {
    setState(() {
      _shouldResetData = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _shouldResetData = false;
      });
    });
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    resetData(); 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:RefreshIndicator(
      onRefresh: refreshData,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            title: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(UserId: widget.UserId),
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
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: ()  {},
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
                      onPageChanged: (value) {},
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
                      text: "Xu Của Tôi",
                      onTap: () {
                         Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => ProfileScreen(UserId: widget.UserId,),
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
                SizedBox(height: 10,),
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
          HotComic(UserId: widget.UserId,shouldResetData: _shouldResetData,),
          ComicHeader(
              text: 'Truyện Hoàn',
              icon: Icons.library_add_check_rounded,
              color: Color.fromARGB(255, 187, 187, 8),
              UserId: widget.UserId,
              name: "Hoàn",
          ),
          FullComic(UserId: widget.UserId,shouldResetData: _shouldResetData,),
          ComicHeader(
              text: 'Truyện Phiêu Lưu',
              icon: Icons.add_reaction_rounded,
              color: Colors.green,
              name: "Adventure",
              UserId: widget.UserId,
          ),
          AdventureComic(UserId: widget.UserId,shouldResetData: _shouldResetData,),
          ComicHeader(
              text: 'Truyện Hành Động',
              icon: Icons.sports_gymnastics_outlined,
              color: Colors.black,
              name: "Action",
              UserId: widget.UserId,
          ),
          ActionComic(UserId: widget.UserId,shouldResetData: _shouldResetData,),
          ComicHeader(
              text: 'Truyện Cổ Đại',
              icon: Icons.access_time,
              color: Color.fromARGB(255, 146, 52, 18),
              name:"Cổ Đại",
              UserId: widget.UserId,
          ),
          AncientComic(UserId: widget.UserId,shouldResetData: _shouldResetData,),
         
        ],
      ),
      )
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