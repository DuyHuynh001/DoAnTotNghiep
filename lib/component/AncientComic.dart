import 'package:flutter/material.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/Community.dart';
import 'package:manga_application_1/view/ComicDetailScreen.dart';

class AncientComic extends StatefulWidget {
  final String UserId;
  const AncientComic({super.key, required this.UserId});
  @override
  State<AncientComic> createState() => _AncientComicState();
}
class _AncientComicState extends State<AncientComic> {
  List<Comics> listAncientComic=[];
  @override
  void initState() {
    super.initState();
    _loadAncientComic();
  }
  // load danh sách cổ đại
  void _loadAncientComic() async {   
    List<Comics>list = await Comics.fetchComicsByCategory("Cổ Đại");
      setState(() {
      listAncientComic =list;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = listAncientComic[index];
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
                    height: 175, 
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
          childCount: listAncientComic.length <=6? listAncientComic.length : 6,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.55, 
        ),
      ),
    );
  }
}
