import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/component/ChapterDetail.dart';
import 'package:manga_application_1/component/CommentItem.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/FullCommentScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class DetalTab extends StatefulWidget {
  final String UserId;
  final Comics story;
  final List<Map<String, dynamic>> chapters;
  const DetalTab({super.key, required this.UserId, required this.story, required this.chapters});

  @override
  State<DetalTab> createState() => _DetalTabState();
}

class _DetalTabState extends State<DetalTab> {
  final TextEditingController commentController = TextEditingController();
  @override
    void initState() {
    super.initState();
  }
  // Google Perspective API: API này cung cấp các công cụ để phân tích 
  // và đánh giá tính độc hại của văn bản, bao gồm phân loại những nội dung có thể gây phản cảm, thiếu văn hóa.
  
  Future<Map<String, dynamic>> analyzeComment(String comment) async {
    final apiKey = dotenv.env['API_KEY']; // Replace with your actual API key
    final url = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=$apiKey';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'comment': {'text': comment},
          'requestedAttributes': {'TOXICITY': {}},
          'languages':['en'],  // chỉ hỗ trợ tiếng anh
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze comment');
      }
    } catch (e) {
      throw Exception('Failed to analyze comment');
    }
  }

  // Sử dụng api google dịch để chuyển binhf luận sang tiếng anh
  Future<String> translateText(String textToTranslate) async {
    final apiTranslate = dotenv.env['API_TRANSLATE'];
    const endpoint = 'https://google-translator9.p.rapidapi.com/v2'; 
    final url = Uri.parse(endpoint);

    try {
      final Map<String, dynamic> body = {
        'q': textToTranslate,
        'source': 'vi',
        'target': 'en',
        'format': 'text'
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-RapidAPI-Key': apiTranslate!,
          'X-RapidAPI-Host': 'google-translator9.p.rapidapi.com',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final translatedText = responseBody['data']['translations'][0]['translatedText'];
        return translatedText;
      } else {  
        throw Exception('Failed to translate text');
      }
      } catch (e) {
        throw Exception('Failed to translate text');
      }
  }

  Future<void> handleComment(String comment) async {
  try {

    String englishComment = await translateText(comment);  
    final analysisResult = await analyzeComment(englishComment );
    final double toxicityScore = analysisResult['attributeScores']['TOXICITY']['summaryScore']['value'];

    if (toxicityScore < 0.5) {
      SaveComment(comment);
    } else {
      // Bình luận không hợp lệ, thông báo cho người dùng
      _showErrorDialog(context, 'Tin nhắn của bạn chứa các từ ngữ không phù hợp!');
    }
    } catch (e) {
      // Xử lý lỗi
      print('Error: $e');
      throw e;
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void SaveComment(String comment) async {
    await FirebaseFirestore.instance.collection('Comments').add({
      'comicId': widget.story.id,
      'comment': comment,
      'times': FieldValue.serverTimestamp(),
      'UserId': widget.UserId
    });
    setState(() {});
    // Xóa nội dung trong TextField sau khi gửi comment thành công
    commentController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // Đảm bảo luôn có thể scroll
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Text(
                  widget.story.description,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                Container(
                  height: 1.0,
                  color: const Color.fromARGB(255, 2, 2, 2),
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => 
                                ChapterDetail(
                                  chapterId: widget.chapters.first['id'],
                                  chapters:widget.chapters,
                                  comic: widget.story,
                                  UserId: widget.UserId,
                                
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
                          icon: Icon(Icons.auto_stories, size: 25, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), // Độ cong của góc
                            ),
                            primary: Colors.blue,
                            side: const BorderSide(color: Colors.black),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          label: Text(
                            "Bắt đầu xem",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1.0,
                  color: const Color.fromARGB(255, 2, 2, 2),
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bình luận của bạn:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Nhập bình luận của bạn...',
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              String comment = commentController.text.trim();
                              if (comment.isNotEmpty) {
                              handleComment(comment);
                               
                                FocusScope.of(context).unfocus();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng nhập bình luận'),
                                    duration: Duration(seconds: 1),
                                    elevation: 4.0,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(8),
                                backgroundColor: Colors.grey[200],
                                side: BorderSide(color: Colors.black)),
                            child: const Row(children: [
                              Icon(
                                Icons.send,
                                size: 30,
                                color: Colors.black,
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1.0,
                  color: const Color.fromARGB(255, 2, 2, 2),
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                ),
                FutureBuilder<List<DocumentSnapshot>>(
                  future: fetchCommentsByComicId(widget.story.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    List<DocumentSnapshot> comments = snapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        const Text(
                          'Danh sách bình luận:',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        if(comments.isEmpty)
                        const Center(
                          child: Text("Chưa có bình luận")
                        )
                        else

                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(), // Tắt scroll của ListView trong SingleChildScrollView
                          shrinkWrap: true,
                          itemCount: comments.length <=4? comments.length : 4,
                          itemBuilder: (context, index) {
                            var comment = comments[index];
                            return CommentItem(
                              userId: comment['UserId'],
                              commentText: comment['comment'],
                              time: comment['times']!,
                            );
                          },
                        ),
                        if (comments.length >= 4)
                          Center(
                            child: TextButton(
                              onPressed: ()
                              {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => FullCommentsScreen(storyId:widget.story.id, UserId: widget.UserId),
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
                              child: Text('Xem thêm'),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }
}
