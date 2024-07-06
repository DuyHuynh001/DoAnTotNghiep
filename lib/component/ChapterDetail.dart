import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:comicz/model/User.dart';
import 'package:comicz/view/ProfileScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';


class ChapterDetail extends StatefulWidget {
  final String chapterId;
  final String UserId;
  final Comics comic;
  final List<Map<String, dynamic>> chapters;

  const ChapterDetail({Key? key,required this.chapterId,required this.comic,required this.chapters,required this.UserId}) : super(key: key);

  @override
  State<ChapterDetail> createState() => _ChapterDetailState();
}

class _ChapterDetailState extends State<ChapterDetail> {
  Timer readTimer = Timer(Duration.zero, () {});    // thời gian đọc
  int totalReadingSeconds=0;
  late DateTime fullreadTimer;    // thời gian đọc
  late DateTime startTime;  // tg bắt đầu đọc
  late String chapterId = widget.chapterId;
  late Map<String, dynamic> currentChapter;
  late bool isVipChapter;   // kiểm tra chương vip
  bool canRead=true;     // Biến để kiểm tra có thể đọc hay không 
  bool isReading = false;   
  bool isAutoUnlockEnabled = false;
  bool isLoading = true;
  bool showSettings = false;
  bool isSwitched = false;
  Timer? autoPlayTimer;
  List<String> imageUrls = [];
  ScrollController scrollController = ScrollController();
  final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();
  FlutterTts flutterTts = FlutterTts();
  List<String> recognizedTexts = [];
  bool isTTSPlaying = false;
  int userLevel = 1;
  User _user = User(Id: "", Name: "", Image: "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b", Email: "", Status: false, Points: 0, IsRead: 0, Gender: "Không được đặt");

  @override
  void initState() {
    super.initState();
    fetchDataChapterFromFirestore(widget.comic.id, widget.chapterId);
    saveReadingHistory(widget.UserId, widget.comic.id, widget.chapterId);
    sortChapters();
    setCurrentChapter();
    getCurrentChapter();
    autoUnlockVipChapter();
    _fetchUserData();
  }

  @override
  void dispose() {
    autoPlayTimer?.cancel();
    scrollController.dispose();
    readTimer.cancel();
    unsecureScreen();
    super.dispose();
    updateReadingTime();
    flutterTts.stop();
    textRecognizer.close();
  }
  // không cho chụp màn hình
  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
  // cho phép dc chụp màn hình
  Future<void> unsecureScreen() async {
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }
  
   Future<void> _fetchUserData() async {
    User user = await User.fetchUserById(widget.UserId);
    if (user != null) {
      setState(() {
        _user = user;
        _calculateLevel(_user.IsRead);
      });
    }
  }
  void _calculateLevel(int currentIsRead) {
      if (currentIsRead>0 && currentIsRead <= 100) {
        userLevel = 1;
      } else if (currentIsRead <= 500) {
        userLevel = 2;
      } else if (currentIsRead <= 1000) {
        userLevel = 3;
      }else if (currentIsRead <= 2000) {
        userLevel = 4;
      } else if (currentIsRead <= 5000) {
        userLevel = 5;
      } else if (currentIsRead <= 10000) {
        userLevel = 6;
      } else if (currentIsRead <= 20000) {
        userLevel = 7;
      } else if (currentIsRead <= 50000) {
        userLevel = 8;
      } else if (currentIsRead <= 100000) {
        userLevel = 9;
      } else {
        userLevel = 10;
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

      if (!chapterSnapshot.exists) {
        throw Exception('Chapter not found');
      }

      Map<String, dynamic> data = chapterSnapshot.data() as Map<String, dynamic>;
      isVipChapter = data['vip'];

      if (!isVipChapter) {
        setState(() {
          canRead = true;
        });
        await unsecureScreen();
        await fetchData(data['chapterApiData']);
      } else {
        DocumentSnapshot unlockedChapterSnapshot = await FirebaseFirestore.instance.collection('User').doc(widget.UserId).collection('UnlockedChapters').doc(comicId + chapterId).get();

        if (unlockedChapterSnapshot.exists) {
          Timestamp unlockedAt = unlockedChapterSnapshot['unlockedAt'];
          DateTime unlockedAtDate = unlockedAt.toDate();
          DateTime now = DateTime.now();

          if (unlockedChapterSnapshot['chapterId'] == chapterId && now.difference(unlockedAtDate).inHours < 24) {
            setState(() {
              canRead = true;
            });
            await secureScreen();
            await fetchData(data['chapterApiData']);
            // startTTS();
          } else {
            setState(() {
              canRead = false;
            });
            await unsecureScreen();
          }
        } else {
          setState(() {
            canRead = false;
          });
          await unsecureScreen();
        }
      }
    } catch (e) {
      print('Error fetching chapter data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
 
Future<void> fetchData(String apiUrl) async {
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> images = data['data']['item']['chapter_image'];
      List<String> urls = images.map((image) => '${data['data']['domain_cdn']}/${data['data']['item']['chapter_path']}/${image['image_file']}').toList();

      urls.sort((a, b) {
        int pageNumberA = int.parse(a.split('/').last.split('_').last.split('.').first);
        int pageNumberB = int.parse(b.split('/').last.split('_').last.split('.').first);
        return pageNumberA.compareTo(pageNumberB);
      });

      if (urls.length > 2) {
        urls = urls.sublist(2);
      }
      setState(() {
        recognizedTexts.clear();
        imageUrls = urls;
        isLoading = false;
        startReadingTimer();
        fullreadTimer = DateTime.now();
      });
      for( int i =0; i< imageUrls.length; i++)
      {
         await extractTextFromImage(imageUrls[i]);
      }
    } else {
      throw Exception('Failed to load images');
    }
  } catch (e) {
    print('Error fetching images: $e');
    setState(() {
      isLoading = true;
    });
  }
}

Future<void> extractTextFromImage(String imageUrl) async {
  try {
    var response = await http.get(Uri.parse(imageUrl));
    var imageData = response.bodyBytes;
    final tempDir = await getTemporaryDirectory();
    final tempImagePath = '${tempDir.path}/temp_image.jpg';
    final file = await File(tempImagePath).writeAsBytes(imageData);
    final inputImage = InputImage.fromFilePath(file.path);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    setState(() {
      recognizedTexts.add(recognizedText.text);
    });

    await deleteTemporaryImage(tempImagePath);
    await textRecognizer.close();
  } catch (e) {
    print('Error extracting text from image: $e');
  }
}
  Future<void> deleteTemporaryImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    } else {
      print('Temporary image file does not exist: $imagePath');
    }
  }

  void startTTS() async {
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setPitch(1.0);
    String fullText = recognizedTexts.join(' ');
    await flutterTts.speak(fullText);

    flutterTts.setErrorHandler((error) {
      setState(() {
        isTTSPlaying = false; // Khi gặp lỗi, cập nhật trạng thái về false
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        isTTSPlaying = false; // Khi hoàn thành, cập nhật trạng thái về false
      });
    });
  }

  void toggleTTS(bool newTTSState) {
    setState(() {
      isTTSPlaying = newTTSState; 
    });
    if (newTTSState) {
      startTTS(); 
    } else {
      flutterTts.stop(); // Dừng TTS
    }
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

  void sortChapters() {
    widget.chapters.sort((a, b) {
      double idA = double.tryParse(a['id'].toString()) ?? double.negativeInfinity;
      double idB = double.tryParse(b['id'].toString()) ?? double.negativeInfinity;
      return idA.compareTo(idB);
    });
  }

  void toggleSettings() {
    setState(() {
      showSettings = !showSettings;
    });
  }

  void toggleAutoUnlock(bool value) {
    setState(() {
      isAutoUnlockEnabled = value;
      if (value) {
        autoUnlockVipChapter(); // Kích hoạt tự động mở chương VIP
      }
    });
  }
  
  void startReadingTimer() {
    setState(() {
      isReading = true;
      startTime = DateTime.now();
    });
    readTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (DateTime.now().difference(startTime).inSeconds >= 30) {
        updateIsRead();
        timer.cancel(); 
      }
    });
  }
   
  void updateReadingTime() async {
    try {
      int _current = DateTime.now().difference(fullreadTimer).inSeconds;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference readRef = firestore.collection('AppUsage').doc(widget.UserId).collection("DailyReading");
      DateTime now = DateTime.now();
      String dateKey= '${now.year}-${now.month}-${now.day}';

      // Tạo một document dựa trên ngày hiện tại nếu chưa tồn tại
       DocumentReference docRef = readRef.doc(dateKey);
      bool docExists = (await docRef.get()).exists;

      if (docExists) {
        await docRef.update({
          'totalReadingTime': FieldValue.increment(_current),
        });
      } else {
        // Nếu chưa có, tạo tài liệu mới
        await docRef.set({
          'totalReadingTime': _current,
          'user': widget.UserId,
          'date':FieldValue.serverTimestamp(),
        });
      }

    } catch (e) {
      print('Error updating reading time: $e');
    }
  }

  void updateIsRead() async {
    try {
      final CollectionReference usersCollection = FirebaseFirestore.instance.collection('User');
      DocumentReference userRef = usersCollection.doc(widget.UserId);
      await userRef.update({
        'IsRead': FieldValue.increment(1),
      });
      readTimer.cancel(); // Hủy bỏ timer sau khi cập nhật thành công
    } catch (e) {
      print('Lỗi khi cập nhật trường isRead: $e');
    }
  }

  void autoUnlockVipChapter() async {
    if (isAutoUnlockEnabled) {
      try {
        Map<String, dynamic>? currentChapter = getCurrentChapter(); 
        
        if (currentChapter != null && currentChapter['vip'] ) {
          bool success = await unlockVipChapter(currentChapter['id']);
          if (!success) {
            setState(() {
              isAutoUnlockEnabled = false;
            });
          }
        }
      } catch (e) {
        print('Error auto unlocking VIP chapter: $e');
      }
    }
  }

  void autoScroll() {
    if (scrollController.hasClients) {
      final maxScrollExtent = scrollController.position.maxScrollExtent;
      final currentScrollPosition = scrollController.position.pixels;

      if (currentScrollPosition < maxScrollExtent) {
        scrollController.animateTo(
          currentScrollPosition + 12.0,
          duration: Duration(milliseconds: 30),
          curve: Curves.linear,
        );
      } else {
        fetchAndScrollToNextChapter();
      }
    }
  }
  Future<void> fetchAndScrollToNextChapter() async {
    updateReadingTime();
    setState(() {
      currentChapter = getNextChapter() ?? {};
      chapterId = currentChapter['id'];
    });
    await fetchDataChapterFromFirestore(widget.comic.id, chapterId);
    saveReadingHistory(widget.UserId, widget.comic.id, chapterId);
    autoUnlockVipChapter();
    // Cuộn lại đầu trang sau khi chuyển chương và tải xong dữ liệu
    scrollController.jumpTo(0);
    Future.delayed(Duration(milliseconds: 500), () {
      autoPlayTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
        autoScroll();
      });
    });
  }

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

  Future<bool> unlockVipChapter(String chapterId) async {
    try {
      final CollectionReference usersCollection = FirebaseFirestore.instance.collection('User');
      DocumentSnapshot userSnapshot = await usersCollection.doc(widget.UserId).get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      int userPoints = userData['Points'];

      if (userPoints >= 100) {
        await updateUserPoints(widget.UserId, -100, chapterId);
        await fetchDataChapterFromFirestore(widget.comic.id, chapterId);
        return true;
      } else {
        showInsufficientPointsDialog();
        return false;
      }
    } catch (e) {
      print('Error unlocking VIP chapter: $e');
      return false;
    }
  }

  void showInsufficientPointsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        title:Row(
          mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child:const Row(
                  children: [
                    Icon(Icons.notification_important_outlined,color: Colors.black,),
                    Text("Thông báo"),
                  ],
                )
              ),
            ],
          ),
          content: Text('Bạn không đủ điểm để mở khóa chương VIP.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserPoints(String userId, int points, String chapterId) async {
    try {
      final CollectionReference usersCollection = FirebaseFirestore.instance.collection('User');
      DocumentReference userRef = usersCollection.doc(userId);
      await userRef.update({
        'Points': FieldValue.increment(points),
      });
      // Lưu trữ thông tin về chương đã mở khóa
      await userRef.collection('UnlockedChapters').doc(widget.comic.id + chapterId).set({
        'unlockedAt': FieldValue.serverTimestamp(),
        'chapterId':chapterId,
      });

    } catch (e) {
      print('Lỗi : $e');
    }
  }

  void setCurrentChapter() {
    currentChapter = widget.chapters.firstWhere(
      (chapter) => chapter['id'] == widget.chapterId,
      orElse: () => {},
    );
    chapterId = widget.chapterId;
  }

   Map<String, dynamic>? getCurrentChapter() {
    return currentChapter;
  }
  
  Map<String, dynamic>? getPreviousChapter() {
    int currentIndex = widget.chapters.indexWhere((chapter) => chapter['id'] == currentChapter['id']);
    if (currentIndex > 0) {
      return widget.chapters[currentIndex - 1];
    }
    return null;
  }

  Map<String, dynamic>? getNextChapter() {
    int currentIndex = widget.chapters.indexWhere((chapter) => chapter['id'] == currentChapter['id']);
    if (currentIndex != -1 && currentIndex < widget.chapters.length - 1) {
      return widget.chapters[currentIndex + 1];
    }
    return null;
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
      body:Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,  
            onTap: toggleSettings,
            child: Column(
              children: [
                if (canRead == true)
                 Expanded(
                  child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollController,
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
                if(canRead==false)
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/img/lock.png',
                                width: 170, 
                                height: 170, 
                                fit: BoxFit.cover, 
                              ),
                              SizedBox(height: 16),
                              const Text(
                                'Thông Báo',
                                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              const Column(
                                children: [
                                  Text(
                                    'Nội dung hình ảnh của chương này bị khóa',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Để mở khóa, vui lòng click vào nút mở khóa ở dưới để xem chương này',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        unlockVipChapter(chapterId);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0), 
                                        ),
                                        primary: Colors.blue,
                                        side: const BorderSide(color: Colors.black),
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      icon: Icon(Icons.lock_open),
                                      label: Text('Mở Khóa (100 Xu)', style: TextStyle(fontSize: 16),),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Mở chương vip tự động', style: TextStyle(fontSize: 16)),
                                  Switch(
                                    value: isAutoUnlockEnabled,
                                    onChanged: toggleAutoUnlock,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                height: 1.0,
                                color: const Color.fromARGB(255, 2, 2, 2),
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                         Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>  ProfileScreen(UserId: widget.UserId ),
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
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0), 
                                        ),
                                        primary: Colors.blue,
                                        side: const BorderSide(color: Colors.black),
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      icon: Icon(Icons.assignment_add),
                                      label: Text('Làm nhiệm vụ kiếm xu', style: TextStyle(fontSize: 16),),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
                        updateReadingTime();
                        currentChapter = getPreviousChapter() ?? {};
                        chapterId = currentChapter['id'];
                        fetchDataChapterFromFirestore(widget.comic.id, chapterId);
                        saveReadingHistory(widget.UserId, widget.comic.id, chapterId);
                        autoUnlockVipChapter();
                        flutterTts.stop();
                        textRecognizer.close();
                        isTTSPlaying=false;
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
                              height: 170,
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [ const Text('Cài đặt',style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                                SizedBox(height: 20.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tự động cuộn', style: TextStyle(fontSize: 16),),
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
                                 SizedBox(height: 10,),
                                 if(userLevel>3)...[
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Nghe đọc truyện', style: TextStyle(fontSize: 16),),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          toggleTTS(!isTTSPlaying); 
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: isTTSPlaying ? Colors.green : Colors.grey,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: isTTSPlaying ? Alignment.centerRight : Alignment.centerLeft,
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                  child: isTTSPlaying ? Icon(Icons.check, color: Colors.green): Icon(Icons.close, color: Colors.grey),),
                                              ),
                                            ),
                                          ],
                                    
                                        ),
                                    ),
                                  ),
                                  ],
                                 ),
                                 ]
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
                        updateReadingTime();
                        currentChapter = getNextChapter() ?? {};
                        chapterId = currentChapter['id'];
                        fetchDataChapterFromFirestore(widget.comic.id, chapterId);
                        saveReadingHistory(widget.UserId, widget.comic.id, chapterId);
                        autoUnlockVipChapter();
                        flutterTts.stop();
                        textRecognizer.close();
                        isTTSPlaying=false;
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
}
