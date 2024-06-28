import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manga_application_1/model/load_data.dart'; // Import your User model 

class CommunityItem extends StatefulWidget {
 final Community message;
 final User user;
 final Comics? comic;

  const CommunityItem({Key? key,required this.message, required this.user, required this.comic}) : super(key: key);
  @override
  _CommunityItemState createState() => _CommunityItemState();
}
class _CommunityItemState extends State<CommunityItem> {
  bool isLiked=false;
  @override
  void initState() {
    super.initState();
    checkLike();
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

  void toggleLike() async {
  try {
    DocumentReference communityRef =FirebaseFirestore.instance.collection('Community').doc(widget.message.Id);
     DocumentReference likeRef = FirebaseFirestore.instance.collection('Community').doc(widget.message.Id) .collection('IsLike').doc(widget.user.Id);
    if (isLiked) {
      // Giảm số lượt yêu thích và cập nhật Firestore
      await communityRef.update({'like': FieldValue.increment(-1),});
      await likeRef.delete();
      setState(() {
        isLiked=false;
      });
    } else {
      // Tăng số lượt yêu thích và cập nhật Firestore
      await communityRef.update({'like': FieldValue.increment(1),});
      await likeRef.set({
        'UserId': widget.user.Id,
        'timestamp': Timestamp.now(),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 15),
      child: Container( 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.lightBlue[50]
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
              Container(
                padding: EdgeInsets.all(5),
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
                        width: 60,
                        height: 100,
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
            if (widget.message.imageUrl != "")
              Padding(
                padding: EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.message.imageUrl,
                    width: 200,
                    height: 200,
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
                    onTap: () {
                      // Xử lý sự kiện bình luận
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => CommentDetailScreen(),
                      //   ),
                      // );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: Colors.blue,size: 30,),
                        SizedBox(width: 8.0),
                        Text('0 Bình luận'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

