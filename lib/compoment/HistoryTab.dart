import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/model/load_data.dart'; // Import History class
import 'package:manga_application_1/view/DetailComicScreen.dart'; 

class HistoryTab extends StatefulWidget {
  final String UserId;

  const HistoryTab({Key? key, required this.UserId}) : super(key: key);

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late final Stream<List<History>> _historyListStream;
  final List<History> _selectedHistoryList = [];

  @override
  void initState() {
    super.initState();
    _historyListStream = History.fetchHistoryList(widget.UserId);
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }

  void _toggleSelectComic(History history) {
    setState(() {
      if (_selectedHistoryList.contains(history)) {
        _selectedHistoryList.remove(history);
      } else {
        _selectedHistoryList.add(history);
      }
    });
  }

  void _deleteSelectedComics() {
    for (var history in _selectedHistoryList) {
     History.deleteHistoryComic(widget.UserId, history.id);
    }
    setState(() {
      _selectedHistoryList.clear();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<History>>(
          stream: _historyListStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Lỗi khi tải dữ liệu'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có truyện đã xem'));
            } else {
              final historyList = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final history = historyList[index];
                          final isSelected = _selectedHistoryList.contains(history);
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => ComicDetailScreen(
                                    storyId: history.id,
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
                            onLongPress: () => _toggleSelectComic(history),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 175,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(history.image),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Expanded(
                                      child: Text(
                                        history.name,
                                        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(formatTimestamp(history.timestamp)),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        const Text("Đến chương: "),
                                        Text(history.chapterId),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  left: -10,
                                  top: -10,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      _toggleSelectComic(history);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: historyList.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 15.0,
                        childAspectRatio: 0.47,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
        if (_selectedHistoryList.isNotEmpty)
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
