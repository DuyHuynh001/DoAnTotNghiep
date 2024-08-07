import 'package:flutter/material.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';
import 'package:comicz/view/ComicDetailScreen.dart';

class AdventureComic extends StatefulWidget {
  final String UserId;
  final bool shouldResetData;
  const AdventureComic({super.key, required this.UserId, required this.shouldResetData});
  @override
  State<AdventureComic> createState() => _AdventureComicState();
}
class _AdventureComicState extends State<AdventureComic> {
  List<Comics> listAdventureComic=[];
  @override
  void initState() {
    super.initState();
    _loadAdventureComic();
  }
   @override
  void didUpdateWidget(covariant AdventureComic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldResetData) {
      _loadAdventureComic();
    }
  }
  // lấy danh sách truyện phiêu lưu 
  void _loadAdventureComic() async {   
    List<Comics>list = await Comics.fetchComicsByCategory("Adventure");
      setState(() {
      listAdventureComic =list;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = listAdventureComic[index];
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
                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
          childCount: listAdventureComic.length <=6? listAdventureComic.length : 6,
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
