import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/DetailComicScreen.dart';

class RecommendComic extends StatefulWidget {
 const  RecommendComic({super.key});
  @override
  State<RecommendComic> createState() => _RecommendComicState();
}
class _RecommendComicState extends State<RecommendComic> {

  List<Comics> listRecommendComic=[];
  void _load() async {   
    List<Comics>list = await Comics.fetchComicsList();
      setState(() {
      listRecommendComic =list;
      });
      print("all productsale : ${listRecommendComic}");
    
  }
  @override
  void initState() {
    super.initState();
    _load();
  
   
  }
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = listRecommendComic[index];
            print("Id: "+ listRecommendComic[index].id);
            return GestureDetector(
               onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    
                    builder: (context) => ComicDetailScreen(storyId: listRecommendComic[index].id),
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
                        image: NetworkImage(listRecommendComic[index].image),
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
          childCount: listRecommendComic.length,
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
