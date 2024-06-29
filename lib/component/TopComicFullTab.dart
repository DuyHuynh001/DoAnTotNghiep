import 'package:flutter/material.dart';
import 'package:manga_application_1/component/TopItem.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/Community.dart';

class TopFullComic extends StatefulWidget {
  final UserId;
  const TopFullComic({super.key, required this.UserId});

  @override
  State<TopFullComic> createState() => _TopFullComicState();
}

class _TopFullComicState extends State<TopFullComic> {
 List<Comics> comics = [];

  @override
  void initState() {
    super.initState();
    _loadComic();
  }

  // Load danh sách comics
  void _loadComic() async {
    List<Comics> list = await Comics.fetchFullComicsListAndFavorite();
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
            image: AssetImage("assets/img/background4.jpg"),
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
              status: comic.favorites.toString(),
              colors: Colors.red,
              icon: Icons.favorite,
            );
          },
        ),
      ),
    );
  }
}
