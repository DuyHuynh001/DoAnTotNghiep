// lib/category_screen.dart
import 'package:flutter/material.dart';
import 'DetailCategoryScreen.dart';

class CategoryScreen extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'name': 'Shoujo', 'icon': '🐸'},
    {'name': 'Boylove', 'icon': '💗'},
    {'name': 'Webtoon', 'icon': '🍄'},
    {'name': 'Harem', 'icon': '💥'},
    {'name': 'Co Dai', 'icon': '❗'},
    {'name': 'Truyen Tranh', 'icon': '🌸'},
    {'name': 'Kich Tinh', 'icon': '🌻'},
    {'name': 'Historical', 'icon': '🌵'},
    {'name': 'Doujinshi', 'icon': '🥟'},
    {'name': 'Truyen Mau', 'icon': '🍁'},
    {'name': 'Fantasy', 'icon': '🔥'},
    {'name': 'Abo', 'icon': '📚'},
    {'name': 'Boy Love', 'icon': '🐸'},
    {'name': 'Mystery', 'icon': '💗'},
    {'name': 'Oneshot', 'icon': '🍄'},
    {'name': 'Ngon Tinh', 'icon': '💥'},
    {'name': 'Manhwa', 'icon': '❗'},
    {'name': 'Yaoi', 'icon': '💡'},
    {'name': 'Lang Man', 'icon': '🌸'},
    {'name': 'Hai Huoc', 'icon': '🌻'},
    {'name': '18', 'icon': '🌵'},
    {'name': 'Nguoi Thu', 'icon': '🥟'},
    {'name': 'Tinh Cam', 'icon': '🍁'},
    {'name': 'Drama', 'icon': '🔥'},
    {'name': 'Dam My', 'icon': '📚'},
    {'name': 'Romance', 'icon': '💗'},
    {'name': 'Manga', 'icon': '🍄'},
    {'name': 'Psychological', 'icon': '💥'},
    {'name': 'Hanh Dong', 'icon': '❗'},
    {'name': 'Chuyen Sinh', 'icon': '💡'},
    {'name': 'Phieu Luu', 'icon': '🌻'},
    {'name': 'Xuyen Khong', 'icon': '🌵'},
    {'name': 'Adventure', 'icon': '🥟'},
    {'name': 'Comedy', 'icon': '🍁'},
    {'name': 'Manhua', 'icon': '🔥'},
    {'name': 'Action', 'icon': '🐸'},
    {'name': 'School Life', 'icon': '📚'},
    {'name': 'Soft Yaoi', 'icon': '🌸'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thể loại'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 3 / 1.5, // Điều chỉnh tỷ lệ khung hình ở đây
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailScreen(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      categories[index]['icon']!,
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 8),
                    Text(
                      categories[index]['name']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
