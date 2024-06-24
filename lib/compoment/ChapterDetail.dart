import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:path_provider/path_provider.dart';

class ChapterDetail extends StatefulWidget {
  final String ChapterId;
  final String UserId;
  final Comics comic;
  final List<Map<String, dynamic>> chapters;

  const ChapterDetail({Key? key,required this.ChapterId,required this.comic,required this.chapters,required this.UserId}) : super(key: key);

  @override
  State<ChapterDetail> createState() => _ChapterDetailState();
}

class _ChapterDetailState extends State<ChapterDetail> {
  late Timer _readTimer;
  late DateTime _startTime;
  bool _isReading = false;
  FlutterTts flutterTts = FlutterTts();
  ScrollController _scrollController = ScrollController();
  final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();

  late String chapterId;
  late Map<String, dynamic> currentChapter;
  bool isLoading = true;
  bool showSettings = false;
  bool isSwitched = false;
  bool isTTSPlaying = false;
  Timer? autoPlayTimer;
  List<String> recognizedTexts = [];
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    sortChapters();
    startReadingTimer();
    setCurrentChapter();
    fetchDataChapterFromFirestore(widget.comic.id, chapterId);
    saveReadingHistory(widget.UserId, widget.comic.id, chapterId);
  }
  void startReadingTimer() {
  setState(() {
    _isReading = true;
    _startTime = DateTime.now();

  });

    _readTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (DateTime.now().difference(_startTime).inSeconds >= 30) {
      updateIsRead();
      timer.cancel(); // Hủy bỏ định kỳ
    }
  });
}
void updateIsRead() async {
  try {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('User');
    DocumentReference userRef = usersCollection.doc(widget.UserId);

    // Cập nhật trường isRead trong tài liệu của User
    await userRef.update({
      'IsRead': FieldValue.increment(1),
    });
    _readTimer.cancel(); // Hủy bỏ timer sau khi cập nhật thành công

    print('Đã cập nhật trường isRead thành công');
  } catch (e) {
    print('Lỗi khi cập nhật trường isRead: $e');
  }
}
  
  void sortChapters() {
    widget.chapters.sort((a, b) {
      double idA = double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
      double idB = double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
      return idA.compareTo(idB);
    });
  }

  void setCurrentChapter() {
    currentChapter = widget.chapters.firstWhere(
      (chapter) => chapter['id'] == widget.ChapterId,
      orElse: () => {},
    );
    chapterId = widget.ChapterId;
  }
  // lấy dử liệu của 1 chương theo đường dẫn
  Future<void> fetchData(String apiUrl) async {
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> images = data['data']['item']['chapter_image'];
      List<String> urls = images.map((image) => '${data['data']['domain_cdn']}/${data['data']['item']['chapter_path']}/${image['image_file']}').toList();
      setState(() {
        imageUrls = urls;
        isLoading = false;
      });
      //  imageUrls.forEach((url) => print(imageUrls));
      // Clear recognizedTexts before extracting text
      // recognizedTexts.clear();
      // for (int i = 0; i < imageUrls.length; i++) {
      //    await extractTextFromImage(imageUrls[i]);
      // }
    } else {
      throw Exception('Failed to load images');
    }
  } catch (e) {
      print('Error fetching images: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDataChapterFromFirestore(String comicId, String chapterId) async {
    setState(() {
      isLoading = true;
      imageUrls = [];
      recognizedTexts = [];
    });
    try {
      DocumentSnapshot chapterSnapshot = await FirebaseFirestore.instance.collection('Comics').doc(comicId).collection('chapters').doc(chapterId).get();

      if (chapterSnapshot.exists) {
        Map<String, dynamic> data = chapterSnapshot.data() as Map<String, dynamic>;
        String apiUrl = data['chapterApiData'];
         _readTimer.cancel(); // Hủy bỏ timer hiện tại trước khi tải chương mới
        await fetchData(apiUrl);
        startReadingTimer(); // Khởi động lại timer cho chương mới
        // startTTS();  // Bắt đầu đọc văn bản của chương mới sau khi tải xong
      } else {
        throw Exception('Chapter not found');
      }
    } catch (e) {
      print('Error fetching chapter data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

//   Future<void> extractTextFromImage(String imageUrl) async {
//     try {
//       var response = await http.get(Uri.parse(imageUrl)); // Tải hình ảnh từ URL
//       var imageData = response.bodyBytes;
//       // Lưu hình ảnh vào bộ nhớ tạm
//       final tempDir = await getTemporaryDirectory();
//       final tempImagePath = '${tempDir.path}/temp_image.jpg';
//       final file = await File(tempImagePath).writeAsBytes(imageData);
//       // Tạo InputImage từ đường dẫn tệp
//       final inputImage = InputImage.fromFilePath(file.path);
//       // Nhận diện văn bản
//       final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

//       setState(() {
//         recognizedTexts.add(recognizedText.text);
//       });
//       await deleteTemporaryImage(tempImagePath);  
//       // Giải phóng tài nguyên của TextRecognizer
//       await textRecognizer.close();
//     } catch (e) {
//       print('Error extracting text from image: $e');
//     }
//  }

//  Future<void> deleteTemporaryImage(String imagePath) async {
//     final file = File(imagePath);
//     if (await file.exists()) {
//       await file.delete();
//     } else {
//       print('Temporary image file does not exist: $imagePath');
//     }
//   }

  Map<String, dynamic>? getPreviousChapter() {
    int currentIndex =
        widget.chapters.indexWhere((chapter) => chapter['id'] == currentChapter['id']);
    if (currentIndex > 0) {
      return widget.chapters[currentIndex - 1];
    }
    return null;
  }

  Map<String, dynamic>? getNextChapter() {
    int currentIndex =
        widget.chapters.indexWhere((chapter) => chapter['id'] == currentChapter['id']);

    if (currentIndex != -1 && currentIndex < widget.chapters.length - 1) {
      return widget.chapters[currentIndex + 1];
    }
    return null;
  }

  void toggleSettings() {
    setState(() {
      showSettings = !showSettings;
    });
  }

  void toggleAutoPlay(bool value) {
    setState(() {
      isSwitched = value;
      if (isSwitched) {
        autoPlayTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
          autoScroll();
        });
      } else {
        autoPlayTimer?.cancel();
      }
    });
  }

  void autoScroll() {
    if (_scrollController.hasClients) {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentScrollPosition = _scrollController.position.pixels;

      if (currentScrollPosition < maxScrollExtent) {
        _scrollController.animateTo(
          currentScrollPosition + 8.0,
          duration: Duration(milliseconds: 30),
          curve: Curves.linear,
        );
      } else {
        autoPlayTimer?.cancel();  // Dừng tự động cuộn khi đến cuối trang
        setState(() {
          currentChapter = getNextChapter() ?? {};
          chapterId = currentChapter['id'];
          fetchDataChapterFromFirestore(widget.comic.id, chapterId);
          saveReadingHistory(widget.UserId, widget.comic.id, chapterId);
        });
      }
    }
  }

  // void startTTS() async {
  //   setState(() {
  //     isTTSPlaying = true;
  //   });
  //   await flutterTts.setLanguage("vi-VN");
  //   await flutterTts.setPitch(1.0);
  //   String fullText="";
  //   fullText += recognizedTexts.join(' ');

  //   await flutterTts.speak(fullText);
  //   setState(() {
  //     isTTSPlaying = false;
  //   });
  // }

  // void toggleTTS() {
  //   if (isTTSPlaying) {
  //     flutterTts.stop();
  //   } else {
  //     if (recognizedTexts.isNotEmpty) {
  //       startTTS();
  //     }
  //   }
  //   setState(() {
  //     isTTSPlaying = !isTTSPlaying;
  //   });
  // }
  
  void saveReadingHistory(String userId, String comicId, String chapterId) async {
    try {
    DocumentReference historyRef = FirebaseFirestore.instance.collection('User').doc(userId).collection('History').doc(comicId);
    DocumentSnapshot historySnapshot = await historyRef.get();
    if (historySnapshot.exists) {
      Map<String, dynamic> historyData = historySnapshot.data() as Map<String, dynamic>;
      String lastChapterId = historyData['chapterId'];

      if (double.parse(chapterId) > double.parse(lastChapterId)) {
      // Cập nhật chương mới nhất khi đọc đến chương mới
        await historyRef.update({
          'chapterId': chapterId,
          'timestamp': Timestamp.now(),
          'image':widget.comic.image,
          'name':widget.comic.name

        });
      }
    } else {
      await historyRef.set({   // Nếu lịch sử không tồn tại, tạo mới
        'chapterId': chapterId,
        'timestamp': Timestamp.now(),
        'image':widget.comic.image,
        'name':widget.comic.name
      });
    }
  } catch (e) {
      print('Lỗi khi lưu lịch sử xem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canNavigatePrevious = getPreviousChapter() != null;
    bool canNavigateNext = getNextChapter() != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text('Chương $chapterId', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: toggleSettings,
            child: Column(
              children: [
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: imageUrls[index],
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (showSettings)
            Positioned(bottom: 0,left: 0,right: 0,
            child: Container(
              color: Colors.white54,
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: canNavigatePrevious? () {
                      setState(() {
                        currentChapter = getPreviousChapter() ?? {};
                        chapterId = currentChapter['id'];
                        fetchDataChapterFromFirestore(widget.comic.id, chapterId);
                        saveReadingHistory(widget.UserId, widget.comic.id, chapterId);
                      });
                    }: null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios),
                        SizedBox(width: 5.0),
                        Text('Chương trước'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      showModalBottomSheet(context: context,builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              height: 200,
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [ const Text('Cài đặt',style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                                SizedBox(height: 20.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tự động cuộn'),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          toggleAutoPlay(!isSwitched); 
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: isSwitched ? Colors.green : Colors.grey,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: isSwitched ? Alignment.centerRight : Alignment.centerLeft,
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                  child: isSwitched ? Icon(Icons.check, color: Colors.green): Icon(Icons.close, color: Colors.grey),),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ),
                                  ),
                                  ],
                                ),
                                // ElevatedButton(
                                //   onPressed: toggleTTS,
                                //  child: Text(isTTSPlaying ? 'Dừng đọc' : 'Nghe đọc'),
                                // ),
                                //  ...recognizedTexts.map((text) => Text(text)).toList(),
                              ],
                            ),
                          );
                        },
                        );
                      },
                    );
                    },
                  ),
                  ElevatedButton(
                    onPressed: canNavigateNext? () {
                      setState(() {
                        currentChapter = getNextChapter() ?? {};
                        chapterId = currentChapter['id'];
                        fetchDataChapterFromFirestore(widget.comic.id, chapterId);
                          saveReadingHistory(widget.UserId, widget.comic.id, chapterId);
                      });
                    }: null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text('Chương sau'),
                        SizedBox(width: 5.0),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    autoPlayTimer?.cancel();
    _scrollController.dispose();
     _readTimer.cancel(); // Hủy bỏ timer khi widget bị dispose
    super.dispose();
    flutterTts.stop();
    textRecognizer.close();
  }
}
