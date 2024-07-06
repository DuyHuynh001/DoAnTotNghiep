import 'dart:async';
import 'package:flutter/material.dart';
import 'package:comicz/model/Chapter.dart';
import 'package:comicz/view/ComicDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comicz/model/Comic.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SearchScreen extends StatefulWidget {
  final String UserId;
  const SearchScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Comics> comicsList = [];
  List<Comics> searchResults = [];
  List<Comics> recommendComic=[];
  bool isLoading = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Timer? _speechTimeout;
  String _gender="";

  @override
  void initState() {
    super.initState();
    loadComicsFromFirestore();
    _speech = stt.SpeechToText();
    fetchGender();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    _speechTimeout?.cancel(); 
    super.dispose();
  }
  
  void performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }
    List<Comics> results = comicsList.where( (comic) => comic.name.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      searchResults = results;
    });
  }
  Future<void> fetchGender() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('User').doc(widget.UserId).get();
    if (userDoc.exists) {
      setState(() {
        _gender = userDoc['Gender'];
        loadRecommendedComicsByGender();
      });
    }
  }
  
  void _loadActionComic() async {   
    List<Comics>list = await Comics.fetchComicsByCategory("Action");
      setState(() {
      recommendComic =list;
    });
  }
   void _loadRomanceComic() async {   
    List<Comics>list = await Comics.fetchComicsByCategory("Ngôn Tình");
      setState(() {
      recommendComic =list;
    });
  }
   void _loadHotComic() async {   
    List<Comics>list = await Comics.fetchHotComicsList();
      setState(() {
      recommendComic =list;
    });
  }
  String getRecommendedTitle() {
    if (_gender == 'Nam') {
      return 'Danh sách truyện hành động đề cử theo nam';
    } else if (_gender == 'Nữ') {
      return 'Danh sách truyện ngôn tình đề cử theo nữ';
    } else {
      return 'Danh sách truyện hot đề cử ';
    }
  }

  void loadRecommendedComicsByGender() {
    if (_gender == 'Nam') {
      _loadActionComic();
    } else if (_gender == 'Nữ') {
      _loadRomanceComic();
    } else {
      _loadHotComic();
    }
  }

  Future<double> getLatestChapter(String comicId) async {
    try {
      double latestChapterNumber = await Chapters.fetchLatestChapterNumber(comicId);
      return latestChapterNumber;
    } catch (e) {
      print('Error: $e');
      return 0.0;
    }
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

  void _listen() async {
    await _checkPermissions();
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _showListeningDialog(); // Hiển thị Dialog khi bắt đầu nghe
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
            performSearch(_searchController.text); // Thêm dòng này
          }),
        );
        // Thiết lập timer để dừng lắng nghe sau 3 giây
        _speechTimeout = Timer(Duration(seconds: 3), () {
          _speech.stop();
          setState(() => _isListening = false);
          Navigator.pop(context); // Đóng Dialog khi hết thời gian
        });
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
      _speechTimeout?.cancel(); // Hủy timer nếu đang lắng nghe
      Navigator.pop(context); // Đóng Dialog khi ngừng lắng nghe
    }
  }

  void _showListeningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Không đóng khi chạm ngoài
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic, size: 64, color: Colors.blue),
                SizedBox(height: 20),
                Text(
                  'Đang nghe...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              hintText: 'Nhập truyện cần tìm',
              suffixIcon: _searchController.text.isNotEmpty?
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    performSearch('');
                  });
                },
              ): null,
            ),
          ),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 20),
            icon: _isListening ? Icon(Icons.mic, size: 32) : Icon(Icons.mic_none),
            onPressed: _listen,
          ),
        ],
      ),
      body: isLoading? Center(child: CircularProgressIndicator())
      : searchResults.isNotEmpty
        ? ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              Comics comic = searchResults[index];
              return FutureBuilder<double>(
                future: getLatestChapter(comic.id),
                builder: (context, snapshot) {
                  double chapterCount = snapshot.data ?? 0.0;
                  return TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                          (context, animation, secondaryAnimation) =>ComicDetailScreen( UserId: comic.description,storyId: comic.id, ),
                          transitionsBuilder: (context, animation,
                          secondaryAnimation, child) {
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
                          color:  Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                              spreadRadius: 0.5,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 60,
                                height: 100,
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
                                child: Column( crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Text( comic.name,style: const TextStyle( fontSize: 18,fontWeight: FontWeight.bold, color: Colors.black),),
                                    SizedBox(height: 5),
                                    Text('Thể loại: ${comic.genre.join(', ')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black),
                                    ),
                                    SizedBox(height: 5),
                                    Text('Chương: $chapterCount',
                                      style: const  TextStyle(
                                        fontSize: 14,
                                        color: const Color.fromARGB(255, 19, 14, 14)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    );
                  },
                );
              },
            )
        : Padding(
          padding: EdgeInsets.only(top: 10, left: 0, right: 0,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text("Không có truyện")),
              SizedBox(height: 10),
              Text(getRecommendedTitle(),style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: recommendComic.length,
                  itemBuilder: (context, index) {
                    Comics comic = recommendComic[index];
                    return FutureBuilder<double>(
                      future: getLatestChapter(comic.id),
                      builder: (context, snapshot) {
                        double chapterCount = snapshot.data ?? 0;
                        return TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                ComicDetailScreen(
                                  UserId: comic.description,
                                  storyId: comic.id,
                                ),
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
                              color:  Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                                  spreadRadius: 0.5,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 100,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comic.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Thể loại: ${comic.genre.join(', ')}',
                                        style: const TextStyle(fontSize: 14, color: Colors.black),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Chương: $chapterCount',
                                        style: const TextStyle(
                                            fontSize: 14, color: Color.fromARGB(255, 19, 14, 14)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
    );
  }
}
