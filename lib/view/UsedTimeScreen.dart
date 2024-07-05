import 'package:flutter/material.dart';
import 'package:manga_application_1/component/TodayChart.dart';
import 'package:manga_application_1/component/WeekChart.dart';

class UsedTimeScreen extends StatefulWidget {
  final String UserId;
  const UsedTimeScreen({super.key, required this.UserId});

  @override
  State<UsedTimeScreen> createState() => _UsedTimeScreenState();
}

class _UsedTimeScreenState extends State<UsedTimeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê thời gian'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Theo ngày'),
            Tab(text: 'Theo tuần'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TodayUsageChart(UserId: widget.UserId),
          WeekUsageChart(UserId:  widget.UserId,),
        ],
      ),
    );
  }
}
