import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/DetailComicScreen.dart';

class RecommendComic extends StatelessWidget {
  final List<Story> RecommendComicData  = [
    Story(title: 'Ta Bị Kẹt Cùng Một Ngày 1000 Năm ', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-bi-ket-cung-mot-ngay-1000-nam.jpg',id: '24',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Toàn Chức Pháp Sư', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/toan-chuc-phap-su.jpg',id: '25',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Ta Trời Sinh Đã Là Nhân Vật Phản Diện', imageUrl: 'https://img.nettruyenfull.com/story/2024/03/11/22924/avatar.png',id: '26',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Ta Là Tà Đế', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-la-ta-de.jpg',id: '26',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Đại Quản Gia Là Ma Hoàng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/dai-quan-gia-la-ma-hoang.jpg',id: '27',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Võ Luyện Đỉnh Phong', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/vo-luyen-dinh-phong.jpg',id: '28',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = RecommendComicData[index];
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
