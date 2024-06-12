import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> searchHistory = [];      //tạo danh sách lịch sử tìm kiếm
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        iconTheme: const IconThemeData(color: Colors.black),
        title: Container(
          padding: EdgeInsets.only(left: 10),
          width: 300,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Nhập tên sản phẩm cần tìm',
              suffixIcon: _searchController.text.isNotEmpty   //kiểm tra nếu ko rỗng thì hiện icon x
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.black,),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();  //xóa dữ liệu ô tìm kiếm
                        });
                      },
                    )
                  : null,  //ngược lại không hiện icon x
            ),
          ),
        ),
        actions: [
         IconButton(
            padding: EdgeInsets.only(right: 20),
            icon: Icon(Icons.search, size: 35),
            onPressed: () {
              updateSearchHistory(_searchController.text);
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => Result(searchText: _searchController.text, id: widget.id,),
            //     ),
            //   ).then((_) {
            //     // Khối này sẽ được thực hiện khi màn hình SearchResult được đóng lại.
            //     _searchController.clear();
            //   });
           },
          ),
        ],
      ),
    ) ;
  }
  void updateSearchHistory(String searchText) {      //hàm sửa lịch sử tìm kiếm 
    setState(() {
      if (searchText.isNotEmpty && !searchHistory.contains(searchText)) {
        searchHistory.insert(0, searchText);
        if (searchHistory.length > 5) {
          searchHistory.removeLast();
        }
        saveSearchHistory();
      }
    });
  }
  void saveSearchHistory() async {   //lưu lịch sử tk
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', searchHistory);
  }
  void clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      searchHistory = [];
    });
  }

  void loadSearchHistory() async {   //load lên app
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }
}