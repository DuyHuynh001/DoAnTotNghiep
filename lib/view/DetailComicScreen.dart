import 'package:flutter/material.dart';
import 'package:manga_application_1/model/function.dart';

class ComicDetailScreen extends StatefulWidget {
  final String storyId;

  ComicDetailScreen({required this.storyId});

  @override
  _ComicDetailScreenState createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  late Story story;
  bool isFavorited = false;
  int favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    // Lấy thông tin chi tiết của truyện từ StoryService
    story = StoryService.getStoryById(widget.storyId);
    favoriteCount = 10; // or whatever the initial favorite count is
  }

  void toggleFavorite() {
    setState(() {
      if (isFavorited) {
        favoriteCount--;
        isFavorited = false;
      } else {
        favoriteCount++;
        isFavorited = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  // Hình ảnh truyện
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      story.imageUrl,
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  // Thông tin truyện
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: isFavorited ? Colors.red : Colors.grey,
                              ),
                              onPressed: toggleFavorite,
                            ),
                            SizedBox(width: 4.0),
                            Text('$favoriteCount'),
                            SizedBox(width: 16.0),
                            Icon(Icons.remove_red_eye, color: Colors.grey),
                            SizedBox(width: 4.0),
                            Text('${1000}'),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Text('Tình trạng: ${story.Status}'),
                        SizedBox(height: 8.0),
                        Text('Thể loại: ${"Đang cập nhật"}'),
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
                indicatorSize:TabBarIndicatorSize.label ,
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
                      child: Text('Chapters ( '+ story.chapter+ ' )', style: TextStyle(fontSize: 16)),
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
                        ],
                      ),
                    ),
                  ),
                  // Tab Chapters
                  ListView.builder(
                    itemCount: 10, // Số lượng phần tử trong danh sách
                    itemBuilder: (context, index) {
                      final chapterNumber = index + 1; // Số chương bắt đầu từ 1
                      return Column(
                        children: [
                          ListTile(
                            leading: Image.asset(
                              'assets/img/reading.png',
                              width: 40,
                            ), // Đường dẫn đến hình ảnh
                            title: Text('Chương $chapterNumber'), // Tiêu đề chương
                            subtitle: Text('Ngày 20/06/2024'), // Ngày của chương
                            onTap: () {
                              // Điều hướng tới màn hình chi tiết chapter
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChapterDetailScreen(
                                    chapterId: '$chapterNumber', // Chương ID (ở đây là số chương)
                                    title: "Chương $chapterNumber", // Tiêu đề màn hình chi tiết
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey), // Đường viền dưới
                        ],
                      );
                    },
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

class ChapterDetailScreen extends StatelessWidget {
  final String chapterId;
  final String title;

  ChapterDetailScreen({required this.chapterId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            // Các thông tin chi tiết khác của chapter
          ],
        ),
      ),
    );
  }
}
