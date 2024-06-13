import 'package:flutter/material.dart';
import 'package:manga_application_1/model/function.dart';

class FullComic extends StatelessWidget {
  final List<Story> FullComicData  = [
    Story(title: 'Doraemon ', imageUrl: 'https://static.wikia.nocookie.net/dubbing9585/images/2/20/Doraemon_2005.png'),
    Story(title: 'One Piece ', imageUrl: 'https://upload.wikimedia.org/wikipedia/vi/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg'),
    Story(title: 'Doraemon', imageUrl: 'https://static.wikia.nocookie.net/dubbing9585/images/2/20/Doraemon_2005.png'),
    Story(title: 'One Piece', imageUrl: 'https://upload.wikimedia.org/wikipedia/vi/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg'),
    Story(title: 'Doraemon', imageUrl: 'https://static.wikia.nocookie.net/dubbing9585/images/2/20/Doraemon_2005.png'),
    Story(title: 'One Piece', imageUrl: 'https://upload.wikimedia.org/wikipedia/vi/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = FullComicData[index];
            return GestureDetector(
              onTap: () {
                print('Tapped on ${story.title}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 175,  // Chiều cao cố định cho hình ảnh
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(story.imageUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    story.title,
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
          childCount: 6,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.55,  // Điều chỉnh tỷ lệ sao cho phù hợp
        ),
      ),
    );
  }
}
