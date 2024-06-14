import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/DetailComicScreen.dart';

class FullComic extends StatelessWidget {
  final List<Story> FullComicData  = [
    Story(title: '7 Viên Ngọc Rồng ', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/7-vien-ngoc-rong.jpg',id: '2',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Vương Gia Khắc Thê', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/vuong-gia-khac-the.jpg',id: '12',Status:'Hoàn Thành',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Doraemon ', imageUrl: 'https://tuoitho.mobi/upload/doc-truyen/doraemon-truyen-ngan/anh-dai-dien.jpg',id: '13',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Thám Tử Lừng Danh Conan', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/tham-tu-conan.jpg',id: '14',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Cuộc Chơi Trên Núi Tử Thần', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/cuoc-choi-tren-nui-tu-than.jpg',id: '15',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'One Piece', imageUrl: 'https://upload.wikimedia.org/wikipedia/vi/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg',id: '16',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
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
