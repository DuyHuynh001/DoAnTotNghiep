import 'package:flutter/material.dart';
import 'package:comicz/component/TopItem.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';

class TopFavorite extends StatefulWidget {
  final String UserId;
  const TopFavorite({super.key, required this.UserId});

  @override
  State<TopFavorite> createState() => _TopFavoriteState();
}

class _TopFavoriteState extends State<TopFavorite> {
  List<Comics> comics = [];

  @override
  void initState() {
    super.initState();
    _loadComic();
  }

  // Load danh sách comics
  void _loadComic() async {
    List<Comics> list = await Comics.fetchHotComicsList();
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
            image: AssetImage("assets/img/background1.jpg"),
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
