import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/Community.dart';
import 'package:manga_application_1/model/User.dart';
import 'package:manga_application_1/view/CommunityDetailScreen.dart';
import 'package:manga_application_1/view/ComicDetailScreen.dart' ;

class MyCommunityItem extends StatefulWidget {
 final Community message;
 final User user;
 final Comics? comic;
 final VoidCallback onDelete;

  const MyCommunityItem({Key? key,required this.message, required this.user, required this.comic, required this.onDelete}) : super(key: key);
  @override
  _MyCommunityItemState createState() => _MyCommunityItemState();
}
class _MyCommunityItemState extends State<MyCommunityItem> {
  bool isLiked=false;
  int commentCount = 0;
  @override
  void initState() {
    super.initState();
    checkLike();
    _loadComments();
  }
  void _loadComments() async {
    List<DocumentSnapshot> fetchedComments = await Community.fetchCommentsByCommunityId(widget.message.Id);
    setState(() {
      commentCount = fetchedComments.length; // Đếm số lượng bình luận
    });
  }
  void deleteCommunity() async {
    try {
      DocumentReference communityRef = FirebaseFirestore.instance.collection('Community').doc(widget.message.Id);
      await communityRef.delete();
      widget.onDelete(); 
    } catch (e) {
      print('Error deleting community: $e');
    }
  }
  Future<void> checkLike() async {
    try {
      DocumentReference likeRef = FirebaseFirestore.instance.collection('Community').doc(widget.message.Id) .collection('IsLike').doc(widget.user.Id);

      DocumentSnapshot doc = await likeRef.get();
      if (doc.exists) {
        setState(() {
          isLiked= true;
        });
      }
    } catch (e) {
      print('Lỗi khi kiểm tra trạng thái yêu thích: $e');
    }
  }
   void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa bài viết"),
          content: Text("Bạn có chắc chắn muốn xóa bài viết này không?"),
          actions: [
            TextButton(
              child: Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Xóa"),
              onPressed: () {
                setState(() {
                  deleteCommunity();
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void toggleLike() async {
  try {
    DocumentReference communityRef =FirebaseFirestore.instance.collection('Community').doc(widget.message.Id);
     DocumentReference likeRef = FirebaseFirestore.instance.collection('Community').doc(widget.message.Id) .collection('IsLike').doc(widget.user.Id);
    DocumentSnapshot communityDoc = await communityRef.get();
    int currentLikes = communityDoc['like'];
    if (isLiked) {
      // Giảm số lượt yêu thích và cập nhật Firestore nếu giá trị hiện tại lớn hơn 0
      if (currentLikes > 0) {
        await communityRef.update({'like': FieldValue.increment(-1)});
      }
      await likeRef.delete();
      setState(() {
        isLiked = false;
        widget.message.like = currentLikes > 0 ? currentLikes - 1 : 0;
      });
    } else {
      // Tăng số lượt yêu thích và cập nhật Firestore
      await communityRef.update({'like': FieldValue.increment(1),});
      await likeRef.set({
        'UserId': widget.user.Id,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        isLiked = true;
      });
    }
     DocumentSnapshot updatedDoc = await communityRef.get();
      setState(() {
        widget.message.like = updatedDoc['like'];
      });
  } catch (e) {
    print('Lỗi khi cập nhật số lượt yêu thích: $e');
  }
}
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime); // Định dạng thời gian
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
      bool? shouldReload = await Navigator.push(
          context,
            PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => CommunityDetailScreen(
              message: widget.message,
              user: widget.user,
              comic: widget.comic,
              IsLike: isLiked,
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
        if (shouldReload == true) {
          _loadComments();
        }
      },
      child: Padding(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 15),
      child: Container( 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.lightBlue[50],
          border: Border.all(color: Colors.grey, width: 0.5)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.Image),
                  radius: 30,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      widget.user.Name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        formatTimestamp(widget.message.time),
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:EdgeInsets.only(left: 130),
                  child:IconButton(
                  onPressed: () {
                    showDeleteConfirmationDialog();
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                ) ,
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                widget.message.content,
                style: TextStyle(fontSize: 16),
                maxLines: null,
              ),
            ),
            if (widget.comic != null)
               GestureDetector(
                onTap: () {
                 Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => ComicDetailScreen(
                      storyId: widget.comic!.id,
                      UserId: widget.user.Id,
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
              child:Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blue[100],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      child: Image.network(
                        widget.comic!.image,
                        width: 50,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        widget.comic!.name,
                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.message.imageUrl != "")
              Padding(
                padding: EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.message.imageUrl,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                         toggleLike();
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.thumb_up,size: 25,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        Text('${widget.message.like} Thích'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      bool? shouldReload = await Navigator.push(
                      context,
                        PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => CommunityDetailScreen(
                          message: widget.message,
                          user: widget.user,
                          comic: widget.comic,
                          IsLike: isLiked,
                          
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
                    if (shouldReload == true) {
                      _loadComments();
                    }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.comment,
                          color: Colors.blue,
                          size: 30,
                        ),
                        SizedBox(width: 8.0),
                        Text('$commentCount Bình luận'),
                      ],
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

