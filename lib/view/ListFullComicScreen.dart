import 'package:flutter/material.dart';
import 'package:manga_application_1/component/ComicItem.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/Community.dart';

class ListFullComicScreen extends StatefulWidget {
  final String UserId; // Thay đổi UserId thành userId để tuân thủ conventions
  ListFullComicScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  _ListfullComicScreenState createState() => _ListfullComicScreenState();
}

class _ListfullComicScreenState extends State<ListFullComicScreen> {
  List<Comics> fullComicsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataFull();
  }

  void fetchDataFull() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Comics>? fetchedComics =
          await Comics.fetchFullComicsList();
      setState(() {
        fullComicsList = fetchedComics ?? [];
      });
    } catch (e) {
      print('Error fetching comics: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Truyện Hoàn Thành"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          isLoading
            ? Center(child: CircularProgressIndicator())
            : fullComicsList.isEmpty
                ? Center(
                    child: Text('Không có truyện theo thể loại và trạng thái này'),
                  )
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: fullComicsList.length,
                      itemBuilder: (context, index) {
                        Comics comic = fullComicsList[index];
                        return ComicItem(
                          comic: comic,
                          UserId: widget.UserId,
                        );
                      },
                    ),
                  ),
        ],
      ),
    );
  }
}