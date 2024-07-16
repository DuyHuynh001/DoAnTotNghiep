import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:comicz/component/ComicItem.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';

class ListRecommendComicScreen extends StatefulWidget {
  final String UserId;
  ListRecommendComicScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  _ListRecommendComicScreenState createState() => _ListRecommendComicScreenState();
}

class _ListRecommendComicScreenState extends State<ListRecommendComicScreen> {
  List<Comics> listRecommendComic = [];
  List<Comics> randomComics=[];
  List<String> selectedCategories = []; 

  @override
  void initState() {
    super.initState();
    fetchUserCategories();
  }

   Future<void> fetchUserCategories() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('User').doc(widget.UserId).get();
      setState(() {
        selectedCategories = List<String>.from(userSnapshot.get('Category'));
            _loadRecommendComic();
      });
    } catch (e) {
      print('Lỗi khi lấy thể loại người dùng: $e');
    }
  }
  Future<List<Comics>> fetchRandomComics(int count) async {
    List<Comics> comics = await Comics.fetchComics();
    comics.shuffle();
    List<Comics> randomComics = comics.take(count).toList();
    return randomComics;
  }

  void _loadRecommendComic() async {
    List<Comics> comics;
    if (selectedCategories.isNotEmpty) {
      comics = await Comics.fetchComicsByListCategories(selectedCategories);
    } else {
      comics = await fetchRandomComics(20); // Đề xuất ngẫu nhiên 20 truyện nếu không có thể loại
    }
    setState(() {
      listRecommendComic = comics;
    });
  }

  double calculateJaccardIndex(List<String> set1, List<String> set2) {
    final intersection = set1.toSet().intersection(set2.toSet()).length;
    final union = set1.toSet().union(set2.toSet()).length;
    return intersection / union;
  }

  Future<void> recommendComicsBasedOnCategory() async {
    if (selectedCategories.isEmpty) {
      _loadRecommendComic();
      return;
    }
    List<Comics> allComics = await Comics.fetchComics();

    List<Comics> recommendedComics = [];
    for (var comic in allComics) {
      double similarity = calculateJaccardIndex(selectedCategories, comic.genre);
      if (similarity > 0.5) {
        recommendedComics.add(comic);
      }
    }

    recommendedComics.sort((a, b) => calculateJaccardIndex(selectedCategories, b.genre)
      .compareTo(calculateJaccardIndex(selectedCategories, a.genre)));
    setState(() {
      listRecommendComic = recommendedComics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Truyện Đề Cử"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
         
           Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: listRecommendComic.length,
              itemBuilder: (context, index) {
                Comics comic = listRecommendComic[index];
                return ComicItem(
                  comic: comic,
                  UserId: widget.UserId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}