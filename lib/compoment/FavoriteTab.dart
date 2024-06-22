import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/DetailComicScreen.dart';

class FavoriteTab extends StatefulWidget {
  final String UserId;
  const FavoriteTab({super.key, required this.UserId});

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  List<History> listFavorite = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  // Lấy danh sách truyện yêu thích
  void _loadFavorite() async {
    try {
      List<History>? list = await History.fetchFavoritesList(widget.UserId);
      if (list != null) {
        setState(() {
          listFavorite = list;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Xử lý lỗi (ví dụ: hiển thị thông báo lỗi)
      print('Error loading Favorite: $e');
    }
  }
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime); // Định dạng thời gian
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : listFavorite.isEmpty ?const Center(child: Text('Không có dữ liệu yêu thích '))
        : CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final Favorite = listFavorite[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => ComicDetailScreen(
                              storyId: Favorite.id,
                              UserId: widget.UserId,
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
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 175,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(Favorite.image),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  Favorite.name,
                                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Text("Chương"),
                                    const SizedBox(width: 4.0),
                                    Expanded(
                                      child: Text(
                                        Favorite.chapterId,
                                        style: const TextStyle(fontSize: 14.0),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                        childCount: listFavorite.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.45,
                      ),
                    ),
                  ),
                ],
              );
  }
}
