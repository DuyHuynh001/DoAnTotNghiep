import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/compoment/CommentItem.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/compoment/ChapterDetail.dart';
import 'package:manga_application_1/view/FullCommentScreen.dart';
import 'package:google_translator/google_translator.dart';
import 'package:http/http.dart' as http;

class ComicDetailScreen extends StatefulWidget {
  final String storyId;
  final String UserId;
  ComicDetailScreen({required this.storyId, required this.UserId});

  @override
  _ComicDetailScreenState createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  bool isButtonFavorite = false;
  bool isButtonView = false;
  bool isFavorited = false;
  bool isView = false;
  List<Map<String, dynamic>> chapters = [];

  bool showOldest = true; // Biến để theo dõi trạng thái cũ nhất hay mới nhất
  Comics story = Comics(
      id: "",
      name: '',
      description: "",
      genre: [],
      image:
          "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png",
      source: "",
      status: "",
      chapters: [],
      favorites: 0,
      view: 0);
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComic();
    _loadChapters();
    checkFavoriteStatus();
    checkViewStatus();
  }

  void _loadComic() async {
    Comics fetchedComic = await Comics.fetchComicsById(widget.storyId);
    setState(() {
      story = fetchedComic;
    });
  }

  void _loadChapters() async {
    List<Map<String, dynamic>> fetchedChapters =
        await Chapters.fetchChapters(widget.storyId);
    setState(() {
      chapters = fetchedChapters;
      if (chapters.isNotEmpty) {
        // Sắp xếp bằng cách chuyển 'id' thành kiểu double để so sánh
        chapters.sort((a, b) {
          double idA =
              double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
          double idB =
              double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
          return idA.compareTo(idB);
        });
      }
    });
  }

  Future<void> checkFavoriteStatus() async {
    try {
      DocumentReference favoriteRef = FirebaseFirestore.instance
          .collection('User')
          .doc(widget.UserId)
          .collection('FavoritesList')
          .doc(widget.storyId);

      DocumentSnapshot doc = await favoriteRef.get();
      if (doc.exists) {
        setState(() {
          isFavorited = true;
          isButtonFavorite = true;
        });
      }
    } catch (e) {
      print('Lỗi khi kiểm tra trạng thái yêu thích: $e');
    }
  }

  Future<void> checkViewStatus() async {
    try {
      DocumentReference viewRef = FirebaseFirestore.instance
          .collection('User')
          .doc(widget.UserId)
          .collection('ViewList')
          .doc(widget.storyId);
      DocumentSnapshot doc = await viewRef.get();
      if (doc.exists) {
        setState(() {
          isView = true;
          isButtonView = true;
        });
      }
    } catch (e) {
      print('Lỗi khi kiểm tra trạng thái theo dõi: $e');
    }
  }

  void updateChapterOrder() {
    setState(() {
      if (showOldest) {
        chapters.sort((a, b) {
          double idA =
              double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
          double idB =
              double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
          return idA.compareTo(idB);
        });
      } else {
        chapters.sort((a, b) {
          double idA =
              double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
          double idB =
              double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
          return idB.compareTo(idA);
        });
      }
    });
  }

  void toggleFavorite() async {
    try {
      DocumentReference comicRef =
          FirebaseFirestore.instance.collection('Comics').doc(widget.storyId);
      DocumentReference favoriteRef = FirebaseFirestore.instance
          .collection('User')
          .doc(widget.UserId)
          .collection('FavoritesList')
          .doc(widget.storyId);
      if (isFavorited) {
        // Giảm số lượt yêu thích và cập nhật Firestore
        await comicRef.update({
          'favorites': FieldValue.increment(-1),
        });
        await favoriteRef.delete();
        setState(() {
          isFavorited = false;
          isButtonFavorite = false;
        });
      } else {
        // Tăng số lượt yêu thích và cập nhật Firestore
        await comicRef.update({
          'favorites': FieldValue.increment(1),
        });
        await favoriteRef.set({
          'comicId': widget.storyId,
          'timestamp': Timestamp.now(),
        });
        setState(() {
          isFavorited = true;
          isButtonFavorite = true;
        });
      }
      _loadComic();
    } catch (e) {
      print('Lỗi khi cập nhật số lượt yêu thích: $e');
    }
  }

  void toggleView() async {
    try {
      DocumentReference comicRef =
          FirebaseFirestore.instance.collection('Comics').doc(widget.storyId);
      DocumentReference viewRef = FirebaseFirestore.instance
          .collection('User')
          .doc(widget.UserId)
          .collection('ViewList')
          .doc(widget.storyId);
      if (isView) {
        await comicRef.update({
          'view': FieldValue.increment(-1),
        });
        // Xóa khỏi danh sách theo dõi
        await viewRef.delete();
        setState(() {
          isView = false;
          isButtonView = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn đã bỏ theo dõi truyện ' + story.name),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await comicRef.update({
          'view': FieldValue.increment(1),
        });
        // Thêm vào danh sách theo dõi
        await viewRef.set({
          'comicId': widget.storyId,
          'timestamp': Timestamp.now(),
        });
        setState(() {
          isView = true;
          isButtonView = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã theo dõi truyện ' + story.name),
            duration: Duration(seconds: 2),
            elevation: 4.0,
          ),
        );
      }
      _loadComic();
    } catch (e) {
      print('Lỗi khi cập nhật danh sách theo dõi: $e');
    }
  }

// Future<Map<String, dynamic>> analyzeComment(String comment) async {
//   final apiKey = 'AIzaSyBsy0xeUF7MF8nCBehb7i_aI3IYUGG9THU'; // Replace with your actual API key
//   final url = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=$apiKey';

//   try {
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'comment': {'text': comment},
//         'requestedAttributes': {'TOXICITY': {}},
//         'languages': 'en',
//       }),
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       print('Failed to analyze comment. Status code: ${response.statusCode}');
//       throw Exception('Failed to analyze comment');
//     }
//   } catch (e) {
//     print('Error analyzing comment: $e');
//     throw Exception('Failed to analyze comment');
//   }
// }

// Future<void> handleComment(String comment) async {
//   try {
//     // Analyze the English comment using Google Perspective API
//     final analysisResult = await analyzeComment(comment);
//     final double toxicityScore = analysisResult['attributeScores']['TOXICITY']['summaryScore']['value'];

//     if (toxicityScore < 0.5) {
//       // Bình luận hợp lệ, lưu vào Firestore
//       postComment(comment);
//     } else {
//       // Bình luận không hợp lệ, thông báo cho người dùng
//       throw Exception('Comment is too toxic');
//     }
//     } catch (e) {
//       // Xử lý lỗi
//       print('Error: $e');
//       throw e;
//     }
//   }

  void postComment(String comment) async {
    await FirebaseFirestore.instance.collection('Comments').add({
      'comicId': widget.storyId,
      'comment': comment,
      'times': FieldValue.serverTimestamp(),
      'UserId': widget.UserId
    });
    setState(() {});
    // Xóa nội dung trong TextField sau khi gửi comment thành công
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    String maxChap = chapters.isNotEmpty
        ? chapters
            .map((chapter) =>
                double.tryParse(chapter['id'].toString()) ?? -double.infinity)
            .reduce((a, b) => a > b ? a : b)
            .toString()
        : '0';
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
                    child: Image.network(story.image,
                        width: 130, height: 250, fit: BoxFit.cover),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.name,
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 4.0,
                          children: story.genre
                              .map((genre) => CategoryItem(Item: genre))
                              .toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(
                                isView
                                    ? Icons.remove_red_eye
                                    : Icons.remove_red_eye_outlined,
                                color: isView ? Colors.blue : Colors.grey,
                              ),
                              onPressed: toggleView,
                            ),
                            Text(story.view.toString()),
                            SizedBox(width: 30.0),
                            IconButton(
                              icon: Icon(
                                isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorited ? Colors.red : Colors.grey,
                              ),
                              onPressed: toggleFavorite,
                            ),
                            Text(story.favorites.toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Tình trạng:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 10),
                            Text('${story.status}',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text('Nguồn:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 10),
                            Text('${story.source}',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  toggleView();
                                },
                                icon: Icon(Icons.bookmark, color: Colors.black),
                                label: Text(
                                  "Theo dõi",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isButtonView
                                      ? Colors.blue[300]
                                      : Colors.grey[
                                          200], // Thay đổi màu nền của nút
                                  side: BorderSide(color: Colors.black),
                                  padding: EdgeInsets.symmetric(vertical: 9),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  toggleFavorite();
                                },
                                icon: const Icon(Icons.favorite,
                                    color: Colors.black),
                                label: Text("Yêu Thích",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isButtonFavorite
                                      ? Colors.blue[300]
                                      : Colors.grey[200],
                                  side: const BorderSide(color: Colors.black),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
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
            const PreferredSize(
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
                      child: Text('Chi tiết', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('Danh sách chương',
                          style: TextStyle(fontSize: 16)),
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
                      physics:
                          AlwaysScrollableScrollPhysics(), // Đảm bảo luôn có thể scroll
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.0),
                            Text(
                              story.description,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              height: 1.0,
                              color: const Color.fromARGB(255, 2, 2, 2),
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
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                ChapterDetail(
                                              ChapterId: chapters.first['id'],
                                              chapters: chapters,
                                              comicId: story.id,
                                              UserId: widget.UserId,
                                            ),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = Offset(1.0, 0.0);
                                              const end = Offset.zero;
                                              const curve = Curves.easeInOut;
                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));
                                              var offsetAnimation =
                                                  animation.drive(tween);
                                              return SlideTransition(
                                                position: offsetAnimation,
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.auto_stories,
                                          size: 25, color: Colors.white),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              30.0), // Độ cong của góc
                                        ),
                                        backgroundColor: Colors.blue,
                                        side: const BorderSide(
                                            color: Colors.black),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                      ),
                                      label: Text(
                                        "Bắt đầu xem",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
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
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bình luận của bạn:',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: commentController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText:
                                                'Nhập bình luận của bạn...',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 8),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      ElevatedButton(
                                        onPressed: () {
                                          String comment =
                                              commentController.text.trim();
                                          if (comment.isNotEmpty) {
                                            // handleComment(comment);
                                            postComment(comment);
                                            FocusScope.of(context).unfocus();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Vui lòng nhập bình luận'),
                                                duration: Duration(seconds: 1),
                                                elevation: 4.0,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(8),
                                            backgroundColor: Colors.grey[200],
                                            side: BorderSide(
                                                color: Colors.black)),
                                        child: const Row(children: [
                                          Icon(
                                            Icons.send,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 1.0,
                              color: const Color.fromARGB(255, 2, 2, 2),
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                            ),
                            FutureBuilder<List<DocumentSnapshot>>(
                              future: fetchCommentsByComicId(widget.storyId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                List<DocumentSnapshot> comments =
                                    snapshot.data ?? [];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    const Text(
                                      'Danh sách bình luận:',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 20),
                                    if (comments.isEmpty)
                                      Center(child: Text("Chưa có bình luận"))
                                    else
                                      ListView.builder(
                                        physics:
                                            NeverScrollableScrollPhysics(), // Tắt scroll của ListView trong SingleChildScrollView
                                        shrinkWrap: true,
                                        itemCount: comments.length <= 4
                                            ? comments.length
                                            : 4,
                                        itemBuilder: (context, index) {
                                          var comment = comments[index];
                                          return CommentItem(
                                            userId: comment['UserId'],
                                            commentText: comment['comment'],
                                            time: comment['times'],
                                          );
                                        },
                                      ),
                                    if (comments.length >= 4)
                                      Center(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    FullCommentsScreen(
                                                        storyId: widget.storyId,
                                                        UserId: widget.UserId),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  const begin =
                                                      Offset(1.0, 0.0);
                                                  const end = Offset.zero;
                                                  const curve =
                                                      Curves.easeInOut;
                                                  var tween = Tween(
                                                          begin: begin,
                                                          end: end)
                                                      .chain(CurveTween(
                                                          curve: curve));
                                                  var offsetAnimation =
                                                      animation.drive(tween);
                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Text('Xem thêm'),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
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
                            Text("Cập nhất đến chương " + maxChap.toString()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showOldest =
                                            true; // Chuyển sang hiển thị cũ nhất
                                        updateChapterOrder();
                                      });
                                    },
                                    child: Text(
                                      'Cũ nhất',
                                      style: TextStyle(
                                        color: showOldest
                                            ? Colors.red
                                            : Colors.black,
                                        decoration: showOldest
                                            ? TextDecoration.underline
                                            : null,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showOldest =
                                            false; // Chuyển sang hiển thị mới nhất
                                        updateChapterOrder();
                                      });
                                    },
                                    child: Text(
                                      'Mới nhất',
                                      style: TextStyle(
                                        color: !showOldest
                                            ? Colors.red
                                            : Colors.black,
                                        decoration: !showOldest
                                            ? TextDecoration.underline
                                            : null,
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
                                    subtitle: Text(
                                        chapters[index]['time'].toString()),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              ChapterDetail(
                                            ChapterId: chapterNumber.toString(),
                                            chapters: chapters,
                                            comicId: story.id,
                                            UserId: widget.UserId,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));
                                            var offsetAnimation =
                                                animation.drive(tween);
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

class CategoryItem extends StatelessWidget {
  final String Item;

  CategoryItem({required this.Item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        Item,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.0,
        ),
      ),
    );
  }
}
