import 'package:flutter/material.dart';
import 'package:manga_application_1/component/ComicItem.dart';
import 'package:manga_application_1/model/load_data.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String Name;
  final String Title;
  final String UserId;
  CategoryDetailScreen({super.key, required this.Name, required this.Title, required this.UserId});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}
class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  String selectedFilter = 'Tất cả';
  List<Comics> comicsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    setState(() { isLoading = true;});
    try {
      List<Comics>? fetchedComics = await Comics.fetchComicsByCategoryAndStatus(widget.Name, selectedFilter);
      setState(() {
        comicsList = fetchedComics!;
      });
    } catch (e) {
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
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.Name),
        leading: Icon( Icons.close),
      ),
      body: Container(
        child: Column(
          children: [ 
            widget.Title != null && widget.Title.isNotEmpty?
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Align(
                  alignment:Alignment.centerLeft,
                  child:Text(
                    widget.Title,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ):  SizedBox.shrink(), // Trả về một widget rỗng nếu Title rỗng hoặc null
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onFilterChanged('Tất cả'),
                      child: Text('Tất cả',style: TextStyle(fontSize: 14),),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selectedFilter == 'Tất cả' ? Colors.blue : Colors.white,
                        primary: selectedFilter == 'Tất cả' ? Colors.white : Colors.black,
                        side: BorderSide(color: selectedFilter == 'Tất cả' ? Colors.blue : Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onFilterChanged('Hoàn thành'),
                      child: Text('Hoàn thành',style: TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selectedFilter == 'Hoàn thành' ? Colors.blue : Colors.white,
                        primary: selectedFilter == 'Hoàn thành' ? Colors.white : Colors.black,
                        side: BorderSide(color: selectedFilter == 'Hoàn thành' ? Colors.blue : Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onFilterChanged('Đang cập nhật'),
                      child: Text('Đang cập nhật',style: TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selectedFilter == 'Đang cập nhật' ? Colors.blue : Colors.white,
                        primary: selectedFilter == 'Đang cập nhật' ? Colors.white : Colors.black,
                        side: BorderSide(color: selectedFilter == 'Đang cập nhật' ? Colors.blue : Colors.black),
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
            isLoading? const Center(
              child: CircularProgressIndicator())
              : comicsList == null || comicsList.isEmpty? 
              const Center(
                child: Text('Không có truyện theo thể loại và trạng thái này'))
              : Expanded( 
                  child :ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: comicsList.length,
                    itemBuilder: (context, index) {
                      Comics comic = comicsList[index];
                      return ComicItem( 
                        comic: comic,
                         UserId: widget.UserId,
                      );
                    },
                  ),
                ),       
          ],
        ),
      ),
    );
  }
}