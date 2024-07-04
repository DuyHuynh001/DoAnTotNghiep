import 'package:flutter/material.dart';
import 'package:manga_application_1/view/ComicDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _tamp = TextEditingController();
  List<String> searchHistory = [];
  List<Comics> comicsList = [];
  List<Comics> searchResults = [];
  bool isLoading = false;
  int a = 0;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Map<String, int> chapterAttributeCounts = {};
  @override
  void initState() {
    super.initState();
    loadSearchHistory();
    loadComicsFromFirestore();
    Comics.fetchComics();
    _speech = stt.SpeechToText();
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

  Future<void> _checkPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      print("Microphone permission granted");
    } else {
      print("Microphone permission denied");
    }
  }

  Future<int> countChapter(String docId) async {
    Query query = FirebaseFirestore.instance
        .collection('Comics')
        .doc(docId)
        .collection('chapters');
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.length;
  }

  void _listen() async {
    await _checkPermissions();
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
            performSearch(_searchController.text); // Thêm dòng này
          }),
        );
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
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
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _listen,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isNotEmpty
              ? ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    Comics comic = searchResults[index];
                    return FutureBuilder<int>(
                      future: countChapter(comic.id),
                      builder: (context, snapshot) {
                        int chapterCount = snapshot.data ?? 0;
                        return TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ComicDetailScreen(
                                  UserId: comic.description,
                                  storyId: comic.id,
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
                                  Container(
                                    width: 60,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(comic.image),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comic.name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Thể loại: ${comic.genre.join(', ')}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Chương: $chapterCount',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: const Color.fromARGB(
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
                    );
                  },
                )
              : Center(child: Text('Không có truyện')),
    );
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
