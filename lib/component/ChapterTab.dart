import 'package:flutter/material.dart';
import 'package:comicz/component/ChapterDetail.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';

class ChapterTab extends StatefulWidget {
  final String UserId;
  final Comics story;
  final String maxChap;
  final List<Map<String, dynamic>> chapters;
  const ChapterTab({super.key, required this.UserId, required this.chapters, required this.maxChap, required this.story});

  @override
  State<ChapterTab> createState() => _ChapterTabState();
}

class _ChapterTabState extends State<ChapterTab> {
  bool showOldest = true; // Biến để theo dõi trạng thái cũ nhất hay mới nhất
  
  void updateChapterOrder() {
    setState(() {
      if (showOldest) {    
        widget.chapters.sort((a, b) {
            double idA = double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
            double idB = double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
            return idA.compareTo(idB); 
          });
      } else {
        widget.chapters.sort((a, b) {
            double idA = double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
            double idB = double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
            return idB.compareTo(idA);
          });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.all(8),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Cập nhất đến chương "+  widget.maxChap.toString()),
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showOldest = true; // Chuyển sang hiển thị cũ nhất
                      updateChapterOrder();
                    });
                  },
                  child: Text(
                    'Cũ nhất',
                    style: TextStyle(
                      color: showOldest ? Colors.red : Colors.black,
                      decoration: showOldest ? TextDecoration.underline : null,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showOldest = false; // Chuyển sang hiển thị mới nhất
                      updateChapterOrder();
                    });
                  },
                  child: Text(
                    'Mới nhất',
                    style: TextStyle(
                      color: !showOldest ? Colors.red : Colors.black,
                      decoration: !showOldest ? TextDecoration.underline : null,
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
              itemCount:  widget.chapters.length,
              itemBuilder: (context, index) {
                final chapterNumber =  widget.chapters[index]['id'];
                final isVip =  widget.chapters[index]['vip'];
                return Column(
                  children: [
                    ListTile(
                      leading: Image.asset(
                        'assets/img/reading.png',
                        width: 40,
                      ),
                     title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[ 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chương $chapterNumber'),
                            SizedBox(height: 4),
                            Text( widget.chapters[index]['time'].toString(), style: TextStyle(fontSize: 15, color: Colors.grey),),
                          ],
                        ),
                        if(isVip)
                          Image.network("https://cdn-icons-png.freepik.com/512/2384/2384341.png",width: 40,)
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => 
                              ChapterDetail(
                                chapterId: chapterNumber.toString(),
                                chapters:  widget.chapters,
                                comic:  widget.story,
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
                    ),
                    Divider(height: 1, color: Colors.grey),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}