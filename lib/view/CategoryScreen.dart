import 'package:flutter/material.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'CategoryDetailScreen.dart';

class CategoryScreen extends StatefulWidget {
  final String UserId;
  const CategoryScreen({super.key, required this.UserId});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late List<Category> listCategory=[];

  @override
  void initState() {
    super.initState();
    loadCategorydata();
  }

  void loadCategorydata() async {
    List<Category> category = await Category.fetchAllCategories();
    if (category != null) {
      setState(() {
        listCategory = category;
      });
    } else {
      print("Không có danh sách thể loại");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thể loại'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            GridView.builder(
              shrinkWrap: true, // Đảm bảo GridView sẽ co lại theo nội dung bên trong
              physics: const NeverScrollableScrollPhysics(), // Ngăn cuộn lăn ở mức GridView, để cuộn toàn bộ màn hình
              gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 3 /1, // Điều chỉnh tỷ lệ khung hình ở đây
              ),
              itemCount: listCategory.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => 
                        CategoryDetailScreen(Name: listCategory[index].categoryName, Title: listCategory[index].title,UserId: widget.UserId,),
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
                    decoration: BoxDecoration(
                      color: Colors.grey[300], 
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          listCategory[index].categoryName,
                          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
