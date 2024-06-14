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
  late Story story;
  bool isFavorited = false;
  int favoriteCount = 0;
  late List<int> chapters = [];
  late int oldestChapterIndex;
  late int newestChapterIndex;
  bool showOldest = true; // Biến để theo dõi trạng thái cũ nhất hay mới nhất

  
 @override
  void initState() {
    super.initState();
    // Simulate getting chapter data
   
    chapters.sort(); // Sắp xếp danh sách chương theo thứ tự tăng dần
    story = StoryService.getStoryById(widget.storyId);
    favoriteCount = 10; // or whatever the initial favorite count is
    chapters = List.generate(10, (index) => index + 1); // Danh sách chương từ 1 đến 10
    oldestChapterIndex = 0; // Chương cũ nhất là 1
    newestChapterIndex = chapters.length-1; // Chương mới nhất là 10
  }
  void updateChapterOrder() {
    setState(() {
      if (showOldest) {
        chapters.sort(); // Sắp xếp lại theo thứ tự tăng dần (cũ nhất)
      } else {
        chapters.sort((a, b) => b.compareTo(a)); // Sắp xếp lại theo thứ tự giảm dần (mới nhất)
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
            content: Text('Bạn đã bỏ theo dõi truyện'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        favoriteCount++;
        isFavorited = true;
        isButtonPressed =true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã theo dõi truyện'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            elevation: 4.0,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> genres = [
      'Cổ đại',
      'Huyền huyễn',
      'Kinh dị',
      'Ngôn tình',
    ];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(story.title, style: TextStyle(fontSize: 16)),
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
                      story.imageUrl,
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
                          story.title,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 4.0,
                          children: genres.map((genre) => GenreChip(genre: genre)).toList(),
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
                            Text('${story.Status}'),
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
                            story.Introduce,
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
                                        builder: (context) => ChapterDetailScreen(
                                          chapterId: '1',
                                          title: "Chương 1",
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
                          // Container(
                          //   padding: EdgeInsets.all(8),
                          //   child: Column(

                          //     children: [
                          //       Row(
                          //         children: [
                          //         Text("Đánh giá", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)
                          //       ],),
                          //       Row(
                          //         children: [
                          //           Expanded(
                          //             child: ElevatedButton.icon(
                          //               onPressed: () {
                          //               },
                          //               icon: Icon(Icons.auto_stories, size: 25,color: Colors.black,),
                          //               style: ElevatedButton.styleFrom(
                          //               shape: RoundedRectangleBorder(
                          //                   borderRadius: BorderRadius.circular(30.0), // Độ cong của góc
                          //                 ),
                          //                 primary: Colors.blue[400],
                          //                 side: const BorderSide(color: Colors.black),
                                          
                          //                 padding: const EdgeInsets.symmetric(vertical: 15),
                          //               ),
                          //               label: Text("Viết bình luận",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // )
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
                           Text("Cập nhất đến chương 10"),
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
                              final chapterNumber = chapters[index];
                              return Column(
                                children: [
                                  ListTile(
                                    leading: Image.asset(
                                      'assets/img/reading.png',
                                      width: 40,
                                    ),
                                    title: Text('Chương $chapterNumber'),
                                    subtitle: Text('20/06/2024'),
                                    onTap: () {
                                      // Điều hướng đến trang chi tiết chương
                                     Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChapterDetailScreen(
                                    chapterId: '$chapterNumber',
                                    title: "Chương $chapterNumber",
                                  ),
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
                  )
                  
                  ,
                  // ListView.builder(
                  //   itemCount: 10,
                  //   itemBuilder: (context, index) {
                  //     final chapterNumber = index + 1;
                  //     return Column(
                  //       children: [
                  //         ListTile(
                  //           leading: Image.asset(
                  //             'assets/img/reading.png',
                  //             width: 40,
                  //           ),
                  //           title: Text('Chương $chapterNumber'),
                  //           subtitle: Text('20/06/2024'),
                  //           onTap: () {
                  //             Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                 builder: (context) => ChapterDetailScreen(
                  //                   chapterId: '$chapterNumber',
                  //                   title: "Chương $chapterNumber",
                  //                 ),
                  //               ),
                  //             );
                  //           },
                  //         ),
                  //         Divider(height: 1, color: Colors.grey),
                  //       ],
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
            // ButtonBar hoặc Row cho các nút ở dưới cùng
            
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
