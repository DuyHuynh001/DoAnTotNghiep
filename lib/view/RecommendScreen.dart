import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';
import 'package:comicz/view/ComicDetailScreen.dart';


class RecommendComic extends StatefulWidget {
  final String userId;
  final bool shouldResetData;

  const RecommendComic({
    Key? key,
    required this.userId,
    required this.shouldResetData,
  }) : super(key: key);

  @override
  State<RecommendComic> createState() => _RecommendComicState();
}

class _RecommendComicState extends State<RecommendComic> {
  List<Comics> listRecommendComic = [];
  List<Comics> randomComics=[];
  List<String> selectedCategories = []; 

  @override
  void initState() {
    super.initState();
    _loadRecommendComic();
    fetchUserCategories();
  }

  @override
  void didUpdateWidget(covariant RecommendComic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldResetData) {
      _loadRecommendComic();
      fetchUserCategories();
      
    }
  }
   Future<void> fetchUserCategories() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('User').doc(widget.userId).get();
      setState(() {
        selectedCategories = List<String>.from(userSnapshot.get('Category'));
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
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final comic = listRecommendComic[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>ComicDetailScreen(storyId: comic.id, UserId: widget.userId),
                    transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 175,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(comic.image),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    comic.name,
                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
          childCount: listRecommendComic.length <= 6 ? listRecommendComic.length : 6,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.53,
        ),
      ),
    );
  }
}