import 'package:flutter/material.dart';
import 'package:comicz/component/ComicItem.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';

class ListHotComicScreen extends StatefulWidget {
  final String UserId; // Thay đổi UserId thành userId để tuân thủ conventions
  ListHotComicScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  _ListHotComicScreenState createState() => _ListHotComicScreenState();
}

class _ListHotComicScreenState extends State<ListHotComicScreen> {
  String selectedFilter = 'Tất cả';
  List<Comics> hotComicsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataHot();
  }

  void fetchDataHot() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Comics>? fetchedComics =
          await Comics.fetchHotComicsListByStatus(selectedFilter);
      setState(() {
        hotComicsList = fetchedComics ?? [];
      });
    } catch (e) {
      print('Error fetching comics: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    fetchDataHot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Truyện Hot"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onFilterChanged('Tất cả'),
                    child: Text( 'Tất cả',style: TextStyle(fontSize: 14),),
                    style: OutlinedButton.styleFrom(
                      backgroundColor:selectedFilter == 'Tất cả' ? Colors.blue : Colors.white,
                      primary: selectedFilter == 'Tất cả' ? Colors.white : Colors.black,
                      side: BorderSide(color: selectedFilter == 'Tất cả' ? Colors.blue: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onFilterChanged('Hoàn thành'),
                    child: Text('Hoàn thành', style: TextStyle(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedFilter == 'Hoàn thành'? Colors.blue: Colors.white,
                      primary:selectedFilter == 'Hoàn thành' ? Colors.white : Colors.black,
                      side: BorderSide(color: selectedFilter == 'Hoàn thành'? Colors.blue: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onFilterChanged('Đang cập nhật'),
                    child: Text('Đang cập nhật', style: TextStyle(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedFilter == 'Đang cập nhật'? Colors.blue: Colors.white,
                      primary: selectedFilter == 'Đang cập nhật'? Colors.white: Colors.black,
                      side: BorderSide(color: selectedFilter == 'Đang cập nhật'? Colors.blue: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 1,
          ),
          isLoading
            ? Center(child: CircularProgressIndicator())
            : hotComicsList.isEmpty
            ? Center(
                child: Text('Không có truyện theo trạng thái này'),
              )
            : Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: hotComicsList.length,
                  itemBuilder: (context, index) {
                    Comics comic = hotComicsList[index];
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