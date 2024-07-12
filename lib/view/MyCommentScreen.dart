import 'package:flutter/material.dart';
import 'package:comicz/component/MyCommentTab.dart';
import 'package:comicz/component/MyPostTab.dart';
import 'package:comicz/component/YourPostTab.dart';

class MyCommentScreen extends StatefulWidget {
  final String UserId;
  
  const MyCommentScreen({Key? key, required this.UserId}) : super(key: key);

 @override
  State<MyCommentScreen> createState() => _MyCommentScreenState();
}

class _MyCommentScreenState extends State<MyCommentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bình luận"),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.blue,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3.0,
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('Bài viết', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('Bình luận', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MyPostTab(UserId: widget.UserId),
                  MyCommentTab(UserId: widget.UserId),       
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
