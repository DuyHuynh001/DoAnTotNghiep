import 'package:flutter/material.dart';
import 'package:comicz/component/FavoriteTab.dart';
import 'package:comicz/component/HistoryTab.dart';
import 'package:comicz/component/ViewTab.dart';

class HistoryScreen extends StatefulWidget  {
  final String UserId;

  const HistoryScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();

  static of(BuildContext context) {}
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
  }
   
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.blue[50],
                child: const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.blue,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3.0,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Text('Đã xem'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark),
                          SizedBox(width: 8),
                          Text('Theo dõi'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite),
                          SizedBox(width: 8),
                          Text('Yêu thích'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    HistoryTab( UserId: widget.UserId,),
                    ViewTab(UserId: widget.UserId),
                    FavoriteTab(UserId: widget.UserId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 
