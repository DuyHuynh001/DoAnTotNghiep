import 'package:flutter/material.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/Community.dart';
import 'package:manga_application_1/view/ComicDetailScreen.dart';
class ActionComic extends StatefulWidget {
  final String UserId;
  const ActionComic({super.key, required this.UserId});
  @override
  State<ActionComic> createState() => _ActionComicState();
}
class _ActionComicState extends State<ActionComic> {
  List<Comics> listActionComic=[];
  @override
  void initState() {
    super.initState();
    _loadActionComic();
  }
  // lấy danh sách truyện tranh hành động
  void _loadActionComic() async {   
    List<Comics>list = await Comics.fetchComicsByCategory("Action");
      setState(() {
      listActionComic =list;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = listActionComic[index];
            return GestureDetector(
               onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => ComicDetailScreen(storyId: story.id, UserId: widget.UserId,),
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
                    height: 175,  // Chiều cao cố định cho hình ảnh
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(story.image),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    story.name,
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
          childCount: listActionComic.length <=6? listActionComic.length : 6,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,  // số comic tối đa 1 dòng
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.55,  
        ),
      ),
    );
  }
}
