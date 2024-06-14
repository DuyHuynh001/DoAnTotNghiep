import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/DetailComicScreen.dart';

class ActionComic extends StatelessWidget {
  final List<Story> ActionComicData  = [
    Story(title: 'Naruto', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/naruto.jpg',id: '1',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: '7 Viên Ngọc Rồng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/7-vien-ngoc-rong.jpg',id: '2',Status:'Đang cập nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Fantasista', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/fantasista.jpg',id: '3',Status:'Đang cập nhật',chapter: "12", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Onepunch Man', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/defense-devil.jpg',id: '4',Status:'Đang cập nhật',chapter: "13", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Defense-devil', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/black-clover-the-gioi-phep-thuat.jpg',id: '5',Status:'Đang cập nhật',chapter: "15", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Phong Vân', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/phong-van.jpg',id: '6',Status:'Đang cập nhật',chapter: "19", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = ActionComicData[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComicDetailScreen(storyId: story.id),
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
