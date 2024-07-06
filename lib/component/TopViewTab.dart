import 'package:flutter/material.dart';
import 'package:comicz/component/TopItem.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';

class TopView extends StatefulWidget {
  final String UserId;
  const TopView({super.key, required this.UserId});

  @override
  State<TopView> createState() => _TopViewState();
}

class _TopViewState extends State<TopView> {
  List<Comics> comics = [];

  @override
  void initState() {
    super.initState();
    _loadComic();
  }

  // Load danh sách comics
  void _loadComic() async {
    List<Comics> list = await Comics.fetchViewComicsList();
    setState(() {
      comics = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/background3.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: comics.length,
          itemBuilder: (context, index) {
            var comic = comics[index];
            return TopComicItem(
              comics: comic,
              rank: index + 1,
              UserId:widget.UserId,
              status: comic.view.toString(),
              colors: Colors.deepPurple,
              icon: Icons.bookmark,
            );
          },
        ),
      ),
    );
  }
}
