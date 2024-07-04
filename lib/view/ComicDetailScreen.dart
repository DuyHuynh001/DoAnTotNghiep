import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/component/ChapterTab.dart';
import 'package:manga_application_1/component/DetailAndCommentTab.dart';
import 'package:manga_application_1/model/Chapter.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/Community.dart';
import 'package:manga_application_1/component/ChapterDetail.dart';

class ComicDetailScreen extends StatefulWidget {
  final String storyId;
  final String UserId;
  ComicDetailScreen({required this.storyId, required this.UserId});

  @override
  _ComicDetailScreenState createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  bool isButtonFavorite = false;
  bool isButtonView=false;
  bool isFavorited = false;
  bool isView = false;
  List<Map<String, dynamic>> chapters = [];
  Comics story= Comics(id: "", name: '', description: "", genre: [], image: "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b", source: "", status: "", chapters: [],favorites:0, view:0, addtime:Timestamp.now());
 
 @override
  void initState() {
    super.initState();
    _loadComic();
    _loadChapters(); ;
    checkFavoriteStatus();
    checkViewStatus();
  }

  void _loadComic() async {
    Comics fetchedComic = await Comics.fetchComicsById(widget.storyId);
    setState(() { story = fetchedComic; });
  }
  void _loadChapters() async {
    List<Map<String, dynamic>> fetchedChapters = await Chapters.fetchChapters(widget.storyId);
    setState(() {
      chapters = fetchedChapters;
      if (chapters.isNotEmpty) {

        chapters.sort((a, b) {
          double idA = double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
          double idB = double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
          return idA.compareTo(idB);
        });
      }
    });
  }
  Future<void> checkFavoriteStatus() async {
  try {
    DocumentReference favoriteRef = FirebaseFirestore.instance.collection('User').doc(widget.UserId) .collection('FavoritesList').doc(widget.storyId);

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
    DocumentReference viewRef = FirebaseFirestore.instance.collection('User').doc(widget.UserId).collection('ViewList').doc(widget.storyId);
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
  
void toggleFavorite() async {
  try {
    DocumentReference comicRef =FirebaseFirestore.instance.collection('Comics').doc(widget.storyId);
    DocumentReference favoriteRef = FirebaseFirestore.instance.collection('User').doc(widget.UserId).collection('FavoritesList').doc(widget.storyId);
    if (isFavorited) {
      // Giảm số lượt yêu thích và cập nhật Firestore
      await comicRef.update({'favorites': FieldValue.increment(-1),});
      await favoriteRef.delete();
      setState(() {
        isFavorited = false;
        isButtonFavorite = false;
      });
    } else {
      // Tăng số lượt yêu thích và cập nhật Firestore
      await comicRef.update({'favorites': FieldValue.increment(1),});
      await favoriteRef.set({
        'comicId': widget.storyId,
        'timestamp': Timestamp.now(),
        'name': story.name,
        'image':story.image
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
      DocumentReference comicRef =FirebaseFirestore.instance.collection('Comics').doc(widget.storyId);
      DocumentReference viewRef = FirebaseFirestore.instance .collection('User').doc(widget.UserId).collection('ViewList').doc(widget.storyId);
      if (isView) {
        await comicRef.update({'view': FieldValue.increment(-1),});
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
        await comicRef.update({'view': FieldValue.increment(1),});
        // Thêm vào danh sách theo dõi
        await viewRef.set({
          'comicId': widget.storyId,
          'timestamp': Timestamp.now(),
          'name': story.name,
          'image':story.image
        });
      
        setState(() {
          isView = true;
          isButtonView = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã theo dõi truyện ' + story.name),
            duration: Duration(seconds:2),
            elevation: 4.0,
          ),
        );
      }
      _loadComic();
    } catch (e) {
      print('Lỗi khi cập nhật danh sách theo dõi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String maxChap = chapters.isNotEmpty ? chapters.map((chapter) => double.tryParse(chapter['id'].toString()) ?? -double.infinity).reduce((a, b) => a > b ? a : b).toString(): '0';
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
                    child: Image.network( story.image, width: 130,height: 250, fit: BoxFit.cover ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text( story.name, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), ),
                        SizedBox(height: 5),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 4.0,
                          children: story.genre.map((genre) => CategoryItem(Item: genre)).toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(
                                isView ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                                color: isView ? Colors.blue : Colors.grey,
                              ),
                              onPressed: toggleView,
                            ),
                             Text(story.view.toString()),
                            SizedBox(width: 30.0),
                            IconButton(
                              icon: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: isFavorited ? Colors.red : Colors.grey,
                              ),
                              onPressed: toggleFavorite,
                            ),
                            Text(story.favorites.toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Tình trạng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 10),
                            Text('${story.status}',style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Text('Nguồn:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 10),
                            Text('${story.source}',style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                     toggleView();      
                                  },
                                  icon: Icon(Icons.bookmark, color: Colors.black),
                                  label: Text( "Theo dõi",
                                    style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: isButtonView ? Colors.blue[300] : Colors.grey[200], // Thay đổi màu nền của nút
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
                                icon: const Icon(Icons.favorite, color: Colors.black),
                                label: Text( "Yêu Thích", style: TextStyle(color: Colors.black, fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  primary:  isButtonFavorite? Colors.blue[300] : Colors.grey[200],
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
                      child: Text('Danh sách chương', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                DetailTab(UserId: widget.UserId, chapters: chapters,story: story),
                ChapterTab(UserId: widget.UserId, chapters: chapters, maxChap: maxChap, story: story)
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