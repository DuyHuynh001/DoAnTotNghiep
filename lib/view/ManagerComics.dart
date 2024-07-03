import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/component/EditComics.dart';
import 'package:manga_application_1/model/Comic.dart';

class Managercomics extends StatefulWidget {
  const Managercomics({super.key});

  @override
  State<Managercomics> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Managercomics> {
  List<Comics> comicsList = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    loadComicsFromFirestore();
    Comics.fetchComics();
  }

  void loadComicsFromFirestore() async {
    try {
      Query query = FirebaseFirestore.instance.collection('Comics');
      QuerySnapshot querySnapshot = await query.get();
      List<Comics> comics = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comics.fromJson(doc.id, data);
      }).toList();
      setState(() {
        comicsList = comics;
        isLoading = false;
      });
    } catch (e) {
      print('Error getting documents: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditDeleteDialog(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý truyện"),
      ),
      body: Container(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : comicsList.isNotEmpty
                ? ListView.builder(
                    itemCount: comicsList.length,
                    itemBuilder: (context, index) {
                      return TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      EditComics(
                                name: comicsList[index].name,
                                id: comicsList[index].id,
                                description: comicsList[index].description,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
                          child: Container(
                            color: const Color.fromARGB(255, 175, 219, 255),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hình ảnh của id

                                Container(
                                  width: 60,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(comicsList[index]
                                          .image), // Đường dẫn đến hình ảnh của id
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Thông tin của Comics
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comicsList[index].name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Thể loại: ${comicsList[index].genre.join(', ')}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Chương: ${comicsList[index].chapters}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 19, 14, 14)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text('Không có truyện'),
                  ),
      ),
    );
  }
}
