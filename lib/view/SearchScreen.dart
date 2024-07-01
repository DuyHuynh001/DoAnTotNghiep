import 'package:flutter/material.dart';
import 'package:manga_application_1/view/ComicDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manga_application_1/model/Comic.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> searchHistory = [];
  List<Comics> comicsList = [];
  List<Comics> searchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSearchHistory();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.pink[50],
          iconTheme: const IconThemeData(color: Colors.black),
          title: Container(
            padding: EdgeInsets.only(left: 10),
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                performSearch(value);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Nhập tên sản phẩm cần tìm',
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            performSearch('');
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          actions: [
            IconButton(
              padding: EdgeInsets.only(right: 20),
              icon: Icon(Icons.search, size: 35),
              onPressed: () {
                updateSearchHistory(_searchController.text);
              },
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return TextButton(
                        onPressed: () {
                          // Xử lý khi người dùng nhấn vào mỗi item
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ComicDetailScreen(
                                UserId: searchResults[index].description,
                                storyId: searchResults[index].id,
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
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(searchResults[index]
                                          .image), // Đường dẫn đến hình ảnh của id
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                // Thông tin của Comics
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        searchResults[index].name,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Genre: ${searchResults[index].genre}',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Chapters: ${searchResults[index].chapters}',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black),
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
                : Center(
                    child: Text('Không có dữ liệu Comics'),
                  ));
  }

  void performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    List<Comics> results = comicsList
        .where(
            (comic) => comic.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      searchResults = results;
    });
  }

  void updateSearchHistory(String searchText) {
    if (searchText.isNotEmpty && !searchHistory.contains(searchText)) {
      setState(() {
        searchHistory.insert(0, searchText);
        if (searchHistory.length > 5) {
          searchHistory.removeLast();
        }
      });
      saveSearchHistory();
    }
  }

  void saveSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', searchHistory);
  }

  void clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      searchHistory = [];
    });
  }

  void loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }
}
