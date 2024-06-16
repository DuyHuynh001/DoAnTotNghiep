import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/DetailChapter.dart';

class ComicDetailScreen extends StatefulWidget {
  final String storyId;

  ComicDetailScreen({required this.storyId});

  @override
  _ComicDetailScreenState createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  bool isButtonPressed = false;
  bool isFavorited = false;
  int favoriteCount = 0;
  List<Map<String, dynamic>> chapters = [];
  late int oldestChapterIndex;
  late int newestChapterIndex;
  bool showOldest = true; // Biến để theo dõi trạng thái cũ nhất hay mới nhất
  Comics story= Comics(id: "", name: '', description: "", genre: [], image: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png", source: "", status: "", chapters: []);
  
  
 @override
  void initState() {
    super.initState();
   _loadComic();
   _loadChapters(); 
    favoriteCount = 10; // or whatever the initial favorite count is
    oldestChapterIndex = 0; 
    newestChapterIndex = chapters.length-1; 
  }
  void _loadComic() async {
      try {
        Comics fetchedComic = await Comics.fetchComicsById(widget.storyId);
        setState(() {
          story = fetchedComic;
        });
      } catch (e) {
        print('Error loading comic: $e');
        // Xử lý lỗi, ví dụ hiển thị thông báo cho người dùng
      }
    }
   void _loadChapters() async {
    try {
      List<Map<String, dynamic>> fetchedChapters = await Comics.fetchChapters(widget.storyId);
      setState(() {
        chapters = fetchedChapters;
        print(chapters.length);
        if (chapters.isNotEmpty) {
          // Sắp xếp bằng cách chuyển 'id' thành kiểu double để so sánh
          chapters.sort((a, b) {
            double idA = double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
            double idB = double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
            return idA.compareTo(idB);
          });
        }
      });
    } catch (e) {
      print('Error loading chapters: $e');
      // Xử lý lỗi, ví dụ, hiển thị thông báo cho người dùng
    }
  }

  void updateChapterOrder() {
    setState(() {
      if (showOldest) {
        chapters.sort((a, b) {
            double idA = double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
            double idB = double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
            return idA.compareTo(idB);
          });
      } else {
         chapters.sort((a, b) {
            double idA = double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
            double idB = double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
            return idB.compareTo(idA);
          });
      }
    });
  }
  void toggleFavorite() {
    setState(() {
      if (isFavorited) {
        favoriteCount--;
        isFavorited = false;
        isButtonPressed =false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn đã bỏ theo dõi truyện '+ story.name),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        favoriteCount++;
        isFavorited = true;
        isButtonPressed =true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã theo dõi truyện '+ story.name),
            duration: Duration(seconds: 1),
          
            elevation: 4.0,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String maxChap = chapters.isNotEmpty ? chapters.map((chapter) => double.tryParse(chapter['id'].toString()) ?? -double.infinity).reduce((a, b) => a > b ? a : b).toString(): '0';
    String minChap = chapters.isNotEmpty ? chapters.map((chapter) => double.tryParse(chapter['id'].toString()) ?? -double.infinity).reduce((a, b) => a > b ? a : b).toString():'0';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(story.name, style: TextStyle(fontSize: 16)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      story.image,
                      width: 125,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.name,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 4.0,
                          children: story.genre.map((genre) => GenreChip(genre: genre)).toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.remove_red_eye, color: Colors.blue),
                            SizedBox(width: 4.0),
                            Text('${1000}'),
                            SizedBox(width: 30.0),
                            IconButton(
                              icon: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: isFavorited ? Colors.red : Colors.grey,
                              ),
                              onPressed: toggleFavorite,
                            ),
                            Text('$favoriteCount'),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Tình trạng:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Text('${story.status}'),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Text('Nguồn:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Text('${story.source}'),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      isButtonPressed = !isButtonPressed;
                                      toggleFavorite();
                                    });
                                  },
                                  icon: Icon(Icons.bookmark, color: Colors.black),
                                  label: Text(
                                    "Theo dõi",
                                    style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: isButtonPressed ? Colors.blue : Colors.grey[200], // Thay đổi màu nền của nút
                                      side: BorderSide(color: Colors.black),
                                      padding: EdgeInsets.symmetric(vertical: 9),
                                    ),
                                ),
                              ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                
                                },
                                icon: const Icon(Icons.share, color: Colors.black),
                                label: const Text("Chia sẻ", style: TextStyle(color: Colors.black, fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.grey[200],
                                  side: const BorderSide(color: Colors.black),
                                  padding: const EdgeInsets.symmetric(vertical: 9,),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 8.0,
              color: Colors.grey[300],
              margin: EdgeInsets.symmetric(vertical: 5.0),
            ),
            PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.blue,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3.0,
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('Thông Tin', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('Danh sách chương', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab Thông Tin
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông Tin Truyện',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            story.description,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Container(
                            height: 8.0,
                            color: Colors.grey[300],
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => 
                                        ChapterDetailScreen(
                                          ChapterId: minChap,
                                          comicId: story.id,
                                          MaxChap: double.parse(maxChap),
                                          MinChap: double.parse(minChap) ,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.auto_stories, size: 25,color: Colors.black,),
                                  style: ElevatedButton.styleFrom(
                                   shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0), // Độ cong của góc
                                    ),
                                    primary: Colors.blue,
                                    side: const BorderSide(color: Colors.black),
                                     
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  label: Text("Bắt đầu xem",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ),
                          
                          Container(
                            height: 1.0,
                            color: const Color.fromARGB(255, 2, 2, 2),
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                          ),
                         
                        ],
                      ),
                    ),
                  ),
                  
                  // Tab Chapters
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                           Text("Cập nhất đến chương "+ maxChap.toString()),
                           Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showOldest = true; // Chuyển sang hiển thị cũ nhất
                                    updateChapterOrder();
                                  });
                                },
                                child: Text(
                                  'Cũ nhất',
                                  style: TextStyle(
                                    color: showOldest ? Colors.red : Colors.black,
                                    decoration: showOldest ? TextDecoration.underline : null,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showOldest = false; // Chuyển sang hiển thị mới nhất
                                    updateChapterOrder();
                                  });
                                },
                                child: Text(
                                  'Mới nhất',
                                  style: TextStyle(
                                    color: !showOldest ? Colors.red : Colors.black,
                                    decoration: !showOldest ? TextDecoration.underline : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                          ],
                        ),
                        Divider(height: 1, color: Colors.grey),
                        
                        Expanded(
                          child: ListView.builder(
                            itemCount: chapters.length,
                            itemBuilder: (context, index) {
                              final chapterNumber = chapters[index]['id'];
                              return Column(
                                children: [
                                  ListTile(
                                    leading: Image.asset(
                                      'assets/img/reading.png',
                                      width: 40,
                                    ),
                                    title: Text('Chương $chapterNumber'),
                                    subtitle: Text(chapters[index]['time'].toString()),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => 
                                           ChapterDetailScreen(
                                              ChapterId:chapterNumber.toString(),
                                              comicId: story.id,
                                              MaxChap: double.parse(maxChap),
                                              MinChap: double.parse(minChap),
                                            ),
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
                                  Divider(height: 1, color: Colors.grey),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenreChip extends StatelessWidget {
  final String genre;

  GenreChip({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        genre,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.0,
        ),
      ),
    );
  }
}