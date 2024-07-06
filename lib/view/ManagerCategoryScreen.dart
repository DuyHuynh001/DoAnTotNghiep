import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbols.dart';
import 'package:comicz/model/Category.dart';
import 'package:comicz/view/AddCategoryScreen.dart';

class ManagerCategory extends StatefulWidget {
  const ManagerCategory({Key? key}) : super(key: key);

  @override
  State<ManagerCategory> createState() => _ManagerCategoryState();
}

class _ManagerCategoryState extends State<ManagerCategory> {
  CollectionReference categories = FirebaseFirestore.instance.collection('Category');
  List<Category> categoryList = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    List<Category> category = await Category.fetchAllCategories();
    setState(() {
      categoryList = category;
    });
  }

  void _navigateToAddCategoryScreen() {
     Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AddCategoryScreen(),
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
    ).then((_) {
     loadCategories();
    });
  }

  Future<void> editCategory(Category category) async {
    TextEditingController _controller =TextEditingController(text:category.title);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category.categoryName),
          content: TextField(
            controller: _controller,
            maxLines: null,
          ),
          actions:[
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Lưu'),
              onPressed: () async {
                String newtitle = _controller.text.trim();
                if (newtitle.isNotEmpty) {
                  await categories.doc(category.id).update({
                    'Title': newtitle,
                  });
                  loadCategories();
                  Navigator.of(context).pop();
                }
                else
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar( content: Text('Vui lòng nhập thông tin'),),
                );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void deleteCategory(Category category) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thể loại "${category.categoryName}" không?'),
        actions: <Widget>[
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Xóa'),
            onPressed: () async {
              await categories.doc(category.id).delete();
              loadCategories();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý thể loại truyện'),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 70,),
        child:ListView.builder(
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                    spreadRadius: 0.5,
                    blurRadius: 3,
                  ),
                 ],
                ),
              child:ListTile(
              onTap: () {
                 editCategory(categoryList[index]);
              },
              title: Text(categoryList[index].categoryName),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red,),
                onPressed: () {
                  deleteCategory(categoryList[index]);
                },
              ),
             ),
            ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCategoryScreen,
        child: Icon(Icons.add, size: 50,),
      ),
    );
  }
}
