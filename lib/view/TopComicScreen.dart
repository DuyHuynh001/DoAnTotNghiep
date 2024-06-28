import 'package:flutter/material.dart';
import 'package:manga_application_1/component/TopComicFullTab.dart';
import 'package:manga_application_1/component/TopFavoriteTab.dart';
import 'package:manga_application_1/component/TopUser.dart';
import 'package:manga_application_1/component/TopViewTab.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TopTruyenScreen extends StatefulWidget {
  final String UserId;
  const TopTruyenScreen({super.key, required this.UserId});

  @override
  State<TopTruyenScreen> createState() => _TopTruyenScreenState();
}

class _TopTruyenScreenState extends State<TopTruyenScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bảng Xếp Hạng Truyện'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
               
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              isScrollable: true,
              tabs: [
                Tab(text: 'BXH Yêu Thích'),
                Tab(text: 'BXH Theo Dõi'),
                Tab(text: 'BXH Truyện Full'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TopFavorite(UserId: widget.UserId,),
          TopView(UserId: widget.UserId),
          TopFullComic(UserId: widget.UserId),
        ],
      ),
    );
  }
}

