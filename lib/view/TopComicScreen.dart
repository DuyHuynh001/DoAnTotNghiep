import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TopTruyenScreen extends StatefulWidget {
  const TopTruyenScreen({super.key});

  @override
  State<TopTruyenScreen> createState() => _TopTruyenScreenState();
}

class _TopTruyenScreenState extends State<TopTruyenScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: Text('Top Truyện'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.blue,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              isScrollable: true,
              tabs: [
                Tab(text: 'Yêu Thích'),
                Tab(text: 'Theo Dõi'),
                Tab(text: 'Truyện Full'),
                Tab(text: 'Người Dùng'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RankingList(type: 'Yêu Thích'),
          RankingList(type: 'Theo Dõi'),
          RankingList(type: 'Truyện Full'),
          UserRankingList(),
        ],
      ),
    );
  }
}

class RankingList extends StatelessWidget {
  final String type;
  const RankingList({required this.type});

  @override
  Widget build(BuildContext context) {
    // Giả lập dữ liệu cho ví dụ
    final List<Map<String, dynamic>> items = [
      {'title': 'Truyện 1', 'progress': 0.9},
      {'title': 'Truyện 2', 'progress': 0.8},
      {'title': 'Truyện 3', 'progress': 0.7},
    ];

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item['title']),
          trailing: Container(
            width: 140.0,
            child: LinearPercentIndicator(
              lineHeight: 14.0,
              percent: item['progress'],
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
              center: Text(
                "${(item['progress'] * 100).toInt()}%",
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UserRankingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Giả lập dữ liệu cho ví dụ
    final List<Map<String, dynamic>> users = [
      {'name': 'Người Dùng 1', 'progress': 0.95},
      {'name': 'Người Dùng 2', 'progress': 0.85},
      {'name': 'Người Dùng 3', 'progress': 0.75},
    ];

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          title: Text(user['name']),
          trailing: Container(
            width: 140.0,
            child: LinearPercentIndicator(
              lineHeight: 14.0,
              percent: user['progress'],
              backgroundColor: Colors.grey,
              progressColor: Colors.green,
              center: Text(
                "${(user['progress'] * 100).toInt()}%",
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
