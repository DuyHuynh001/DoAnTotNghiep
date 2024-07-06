
import 'package:flutter/material.dart';
import 'package:comicz/model/Comic.dart';
import 'package:comicz/model/Community.dart';

class ComicSelection extends StatefulWidget {
  final Function(Comics) onComicSelected;

  ComicSelection({required this.onComicSelected});

  @override
  _ComicSelectionState createState() => _ComicSelectionState();
}
class _ComicSelectionState extends State<ComicSelection> {
  TextEditingController _post = TextEditingController();
  List<Comics> _comics = [];
  List<Comics> _allComics = [];
  List<Comics> _filteredComics = [];

  @override
  void initState() {
    super.initState();
    _fetchComics();
  }

  Future<void> _fetchComics() async {
    List<Comics> list = await Comics.fetchComics();
    setState(() {
      _comics = list;
      _allComics = list.toList(); // Tạo bản sao của danh sách comics
      _filteredComics = list.toList(); // Khởi tạo _filteredComics với toàn bộ danh sách
    });
  }

  void _filterComics(String searchText) {
    setState(() {
      _filteredComics = _allComics.where((comic) =>
          comic.name.toLowerCase().contains(searchText)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn truyện'),
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(10),
            child: TextField(
              controller: _post,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterComics(value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListBody(
                children: _filteredComics.map((comic) {
                  return GestureDetector(
                    onTap: () {
                      widget.onComicSelected(comic);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.network(
                            comic.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child:Text(comic.name,maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}