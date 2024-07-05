import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/model/Community.dart'; // Import History class
import 'package:manga_application_1/model/History.dart';
import 'package:manga_application_1/view/ComicDetailScreen.dart'; 

class FavoriteTab extends StatefulWidget {
  final String UserId;

  const FavoriteTab({Key? key, required this.UserId}) : super(key: key);

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  late final Stream<List<History>> _FavoriteListStream;
   final List<History> _selectedFavoriteList = [];

  @override
  void initState() {
    super.initState();
    _FavoriteListStream = History.fetchFavoriteList(widget.UserId);
  }
   void _toggleSelectComic(History history) {
    setState(() {
      if (_selectedFavoriteList.contains(history)) {
       _selectedFavoriteList.remove(history);
      } else {
        _selectedFavoriteList.add(history);
      }
    });
  }
  void _deleteSelectedComics() {
    for (var history in _selectedFavoriteList) {
     History.deleteFavoriteComic(widget.UserId, history.id);
    }
    setState(() {
      _selectedFavoriteList.clear();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<History>>(
          stream: _FavoriteListStream,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Lỗi khi tải dữ liệu'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có truyện đã theo dõi'));
            } else {
              final FavoriteList = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final Favorite = FavoriteList[index];
                          final isSelected = _selectedFavoriteList.contains(Favorite);
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
                            onLongPress: () => _toggleSelectComic(Favorite),
                            child: Stack(
                              children: [
                                Column(
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
                                  ],
                                ),
                                Positioned(
                                  left: -10,
                                  top: -10,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      _toggleSelectComic(Favorite);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: FavoriteList.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.55,
                      ),
                    ),
                  ),
                ],
              );
            } 
          },
        ),
        if (_selectedFavoriteList.isNotEmpty)
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _deleteSelectedComics,
              child: const Icon(Icons.delete),
              backgroundColor: Colors.red,
            ),
          ),
      ],
    );
  }
}
