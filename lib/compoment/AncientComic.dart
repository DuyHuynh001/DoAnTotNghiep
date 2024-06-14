import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/DetailComicScreen.dart';

class AccientComic extends StatelessWidget {
  final List<Story> AccientComicData  = [
    Story(title: 'Ta Đem Hoàng Tử Dưỡng Thành Hắc Hóa', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-dem-hoang-tu-duong-thanh-hac-hoa.jpg',id: '7',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Khánh Dư Niên', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/khanh-du-nien.jpg',id: '8',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Ta Là Đại Thần Tiên', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-la-dai-than-tien.jpg',id: '9',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Tiên Đế Võ Tôn', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/tien-vo-de-ton.jpg',id: '10',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Dục Huyết Thương Hậu', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/duc-huyet-thuong-hau.jpg',id: '11',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Vương Gia Khắc Thê', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/vuong-gia-khac-the.jpg',id: '12',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = AccientComicData[index];
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
