import 'package:flutter/material.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/Community.dart';
import 'package:manga_application_1/view/ComicDetailScreen.dart';

class TopComicItem extends StatelessWidget {
  final Comics comics;
  final int rank;
  final String UserId;
  final String status;
  final Color colors;
  final IconData icon;

  TopComicItem({
    required this.comics,
    required this.rank,
    required this.UserId,
    required this.status,
    required this.colors,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    Widget rankWidget;
 
    String rankImagePath = 'assets/img/rank$rank.png';
    // Kiểm tra nếu rank nằm trong khoảng từ 1 đến 10 và thiết lập rankWidget
    if (rank >= 1 && rank <= 10) {
      rankWidget = Image.asset(rankImagePath, width: 50, height: 50);
    } else {
      rankWidget  = Padding(
        padding: EdgeInsets.only(right: 5),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[350],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ComicDetailScreen(storyId:comics.id,UserId: UserId,),
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
        child: Container(
          color: Colors.lightBlue[50],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                child: Image.network(
                  comics.image,
                  width: 60,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comics.name,
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 7),
                    Text(
                      comics.genre.join(' - '),
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 10),
                  rankWidget,
                  SizedBox(height: 13),
                  Padding(padding: EdgeInsets.only(right: 5),
                  child: Row(
                    children: [
                      Icon(icon, color: colors,size: 20,),
                      SizedBox(width: 5),
                      Text(
                        status,
                        style:  TextStyle(fontSize: 16, color: colors, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  )
                 
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
