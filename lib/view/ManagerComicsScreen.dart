
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:comicz/model/Chapter.dart';
import 'package:comicz/view/EditComicScreen.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/view/AddComicScreen.dart';
import 'package:http/http.dart' as http;

class Managercomics extends StatefulWidget {
  const Managercomics({super.key});

  @override
  State<Managercomics> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Managercomics> {
  List<Comics> comicsList = [];
  double latestChapter = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchComics();
  }

  Future<void> _fetchComics() async {
    List<Comics> list = await Comics.fetchComics();
    setState(() {
     comicsList = list;
    });
  }
  Future<double> getLatestChapter(String comicId) async {
    try {
      double latestChapterNumber = await Chapters.fetchLatestChapterNumber(comicId);
      return latestChapterNumber;
    } catch (e) {
      print('Error: $e');
      return 0.0;
    }
  }
  void _navigateToAddComicsScreen() {
     Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AddComicScreen(),
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
    ).then((_) {
     _fetchComics();
    });
  }
  Future<void> _deleteComic(String comicId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      await FirebaseFirestore.instance.collection('Comics').doc(comicId).delete();

      final QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance.collection('Comments').where('comicId', isEqualTo: comicId).get();
      for (DocumentSnapshot commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.delete();
      }

      final QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('User').get();
      for (DocumentSnapshot userDoc in usersSnapshot.docs) {
        final QuerySnapshot favoritesSnapshot = await userDoc.reference
            .collection('FavoritesList')
            .where('comicId', isEqualTo: comicId)
            .get();
        for (DocumentSnapshot favoriteDoc in favoritesSnapshot.docs) {
          await favoriteDoc.reference.delete();
        }

        final QuerySnapshot historySnapshot = await userDoc.reference
            .collection('History').get();
        for (DocumentSnapshot historyDoc in historySnapshot.docs) {
          if(historyDoc.id==comicId)
          {
            await historyDoc.reference.delete();
          }
          
        }

        final QuerySnapshot viewListSnapshot = await userDoc.reference
            .collection('ViewList')
            .where('comicId', isEqualTo: comicId)
            .get();
        for (DocumentSnapshot viewListDoc in viewListSnapshot.docs) {
          await viewListDoc.reference.delete();
        }
      }

      final QuerySnapshot communitySnapshot = await FirebaseFirestore.instance
          .collection('Community')
          .where('comicId', isEqualTo: comicId)
          .get();
      for (DocumentSnapshot communityDoc in communitySnapshot.docs) {
        await communityDoc.reference.delete();
      }
      setState(() {
        _fetchComics();
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Truyện đã được xóa thành công')),
      );
      
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi xóa truyện: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(String ComicId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa truyện này không?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteComic(ComicId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> updateLatestChapters(String comicId) async {
    bool hasNewChapters = false;
    try {
      CollectionReference chaptersCollection = FirebaseFirestore.instance.collection('Comics').doc(comicId).collection('chapters');
      DocumentSnapshot comicDoc = await FirebaseFirestore.instance.collection('Comics').doc(comicId).get();
      if (comicDoc.exists) {
        var data = comicDoc.data() as Map<String, dynamic>?;
        String apiUrl = data?['api'] ?? '';
        if (apiUrl.isEmpty) {
          print('API URL is null or empty');
          return hasNewChapters;
        }

        var response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          // Lấy danh sách chương từ API
          var chapters = responseData['data']['item']['chapters'][0]['server_data'];
          for (var chapter in chapters) {
            String chapterName = chapter['chapter_name'];
            String chapterApiData = chapter['chapter_api_data'];

            // kiểm tra chương đã có chương trong firestore
            var existingChapter = await chaptersCollection.doc(chapterName).get();
            if (!existingChapter.exists) {
              hasNewChapters = true;
              DateTime now = DateTime.now();
              String formattedTime = DateFormat('dd-MM-yyyy HH:mm').format(now);
              // Dữ liệu của chương mới để thêm vào Firestore
              Map<String, dynamic> chapterData = {
                'chapterApiData': chapterApiData,
                'time': formattedTime,
                'vip': false
              };
              await chaptersCollection.doc(chapterName).set(chapterData);
            }
          }
        } else {
          print('Failed to fetch data from API for comic: $comicId');
        }
      } else {
        print('Comic not found: $comicId');
      }
    } catch (e) {
      print('Error updating latest chapters: $e');
    }
    return hasNewChapters;
  }

  void updateChaptersAndShowSnackBar(String comicId, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      bool hasNewChapters = await updateLatestChapters(comicId);
      if (hasNewChapters) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm chương mới'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chưa có chương mới'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi cập nhật chương mới'),
        ),
      );
    } finally {
      Navigator.pop(context);
      setState(() { });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý danh sách truyện"),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 70,),
        child:ListView.builder(
          itemCount: comicsList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(10,),
              child: Container(
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                    spreadRadius: 0.5,
                    blurRadius: 3,
                  ),
                 ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage( comicsList[index].image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:CrossAxisAlignment.start,
                        children: [
                          Text(
                            comicsList[index].name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                               maxLines: 1,
                              overflow:TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${comicsList[index].genre.join(' - ')}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black),
                              maxLines: 1,
                              overflow:TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          FutureBuilder<double>(
                            future: getLatestChapter(comicsList[index].id),
                            builder: (context, snapshot) {
                              return Text(
                                'Chương mới nhất: ${snapshot.data}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                     Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => EditComicScreen(comic: comicsList[index],),
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
                                    ).then((_) {
                                      _fetchComics();
                                    }); 
                                  },
                                  icon: Icon(Icons.edit),
                                  color: Colors.blue,
                                  iconSize: 27,
                                ),
                                IconButton(
                                  onPressed: () async {
                                    updateChaptersAndShowSnackBar(comicsList[index].id, context);
                                  },
                                  icon: Icon(Icons.system_update_alt_rounded),
                                  color: const Color.fromARGB(255, 198, 180, 21),
                                  iconSize: 27,
                                ),
                                IconButton(
                                  onPressed: () {
                                   _showDeleteConfirmationDialog(comicsList[index].id);
                                  },
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  iconSize: 27,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }        
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddComicsScreen,
        child: const Icon(
          Icons.add,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}

