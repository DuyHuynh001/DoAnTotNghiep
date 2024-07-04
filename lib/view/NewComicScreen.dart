import 'package:flutter/material.dart';
import 'package:manga_application_1/component/ComicItem.dart';
import 'package:manga_application_1/model/Comic.dart';
import 'package:manga_application_1/model/Community.dart';

class ListNewComicScreen extends StatefulWidget {
  final String UserId; 
  ListNewComicScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  _ListNewComicScreenState createState() => _ListNewComicScreenState();
}

class _ListNewComicScreenState extends State<ListNewComicScreen> {
  String selectedFilter = 'Tất cả';
  List<Comics> NewComicsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataNew();
  }

  void fetchDataNew() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Comics>? fetchedComics =await Comics.fetchNewComicsList(selectedFilter);
      setState(() {
        NewComicsList = fetchedComics ?? [];
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
    fetchDataNew();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Truyện Mới"),
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
            : NewComicsList.isEmpty
            ? Center(
                child: Text('Không có truyện theo trạng thái này'),
              )
            : Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: NewComicsList.length,
                  itemBuilder: (context, index) {
                    Comics comic = NewComicsList[index];
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