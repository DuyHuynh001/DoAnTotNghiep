
import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/DetailComicScreen.dart';

class ComicItem extends StatefulWidget {
  final Comics comic;
  final String UserId;
  const ComicItem({super.key, required this.comic, required this.UserId});

  @override
  State<ComicItem> createState() => _ComicItemState();
}

class _ComicItemState extends State<ComicItem> {
  List<Map<String, dynamic>> chapters = [];
  bool isButtonView = false;

  @override
  void initState() {
    super.initState();
   _loadChapters(); 
  }

  void _loadChapters() async {
    List<Map<String, dynamic>> fetchedChapters = await Chapters.fetchChapters(widget.comic.id);
    setState(() {
      chapters = fetchedChapters;
    });
  }

  @override
  Widget build(BuildContext context) {
    String maxChap = chapters.isNotEmpty ? chapters.map((chapter) => double.tryParse(chapter['id'].toString()) ?? -double.infinity).reduce((a, b) => a > b ? a : b).toString(): '0';
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ComicDetailScreen(storyId: widget.comic.id,UserId: widget.UserId,),
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
      child: Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              widget.comic.image,
              width: 120,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.comic.name,style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                SizedBox(height: 7),
                Text('Chương: $maxChap',style:const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                SizedBox(height: 7),
                Text(widget.comic.genre.join(' - '),style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),maxLines: 2,overflow: TextOverflow.ellipsis,),
                SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
