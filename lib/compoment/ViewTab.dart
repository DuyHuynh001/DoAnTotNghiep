import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/model/load_data.dart'; // Import History class
import 'package:manga_application_1/view/ComicDetailScreen.dart'; 

class ViewTab extends StatefulWidget {
  final String UserId;

  const ViewTab({Key? key, required this.UserId}) : super(key: key);

  @override
  State<ViewTab> createState() => _ViewTabState();
}

class _ViewTabState extends State<ViewTab> {
  late final Stream<List<History>> _viewListStream;
   final List<History> _selectedViewList = [];

  @override
  void initState() {
    super.initState();
    _viewListStream = History.fetchViewList(widget.UserId);
  }
   void _toggleSelectComic(History history) {
    setState(() {
      if (_selectedViewList.contains(history)) {
       _selectedViewList.remove(history);
      } else {
        _selectedViewList.add(history);
      }
    });
  }
  void _deleteSelectedComics() {
    for (var history in _selectedViewList) {
     History.deleteViewComic(widget.UserId, history.id);
    }
    setState(() {
      _selectedViewList.clear();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<History>>(
          stream: _viewListStream,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Lỗi khi tải dữ liệu'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có truyện đã theo dõi'));
            } else {
              final viewList = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final view = viewList[index];
                          final isSelected = _selectedViewList.contains(view);
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => ComicDetailScreen(
                                    storyId: view.id,
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
                            onLongPress: () => _toggleSelectComic(view),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 175,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(view.image),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      view.name,
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
                                          _toggleSelectComic(view);
                                        },
                                      ),
                                    ),
                              ],
                            ),
                          );
                        },
                        childCount: viewList.length,
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
        if (_selectedViewList.isNotEmpty)
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
