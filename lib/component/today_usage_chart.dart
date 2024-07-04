import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TodayUsageChart extends StatefulWidget {
  final String UserId;

  TodayUsageChart({required this.UserId});

  @override
  _TodayUsageChartState createState() => _TodayUsageChartState();
}

class _TodayUsageChartState extends State<TodayUsageChart> {
  String selectedDay = "0"; 
  String formatDateString(String dateString) {
    List<String> parts = dateString.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);
    return '$year-$month-$day';
  }

  Future<Map<String, int>> fetchTimeUsage(String userId, int daysAgo) async {
    DateTime date = DateTime.now().subtract(Duration(days: daysAgo));
    String dateString = date.toIso8601String().substring(0, 10);
    String formattedDateString = formatDateString(dateString);

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('AppUsage')
        .doc(userId)
        .collection('DailyUsage')
        .doc(formattedDateString)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? usageData = snapshot.data() as Map<String, dynamic>?;
      int appUsageSeconds = usageData?['app_usage_seconds'] ?? 0;

    DocumentSnapshot readingSnapshot = await FirebaseFirestore.instance
        .collection('AppUsage')
        .doc(userId)
        .collection('DailyReading')
        .doc(formattedDateString)
        .get();

      if (readingSnapshot.exists) {
        Map<String, dynamic>? readingData = readingSnapshot.data() as Map<String, dynamic>?;
        int readingMinutes = readingData?['totalReadingTime'] ?? 0;
        return {
          'app_usage_seconds': appUsageSeconds,
          'totalReadingTime': readingMinutes,
        };
      } else {
        return {
          'app_usage_seconds': appUsageSeconds,
          'totalReadingTime': 0,
        };
      }
    }
    return {
      'app_usage_seconds': 0,
      'totalReadingTime': 0,
    };
  }

  String formatUsageTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '$hours:$minutes:$remainingSeconds';
  }
  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String secondsStr = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedDay,
          onChanged: (String? newValue) {
            setState(() {
              selectedDay = newValue!;
            });
          },
          items: [
           const DropdownMenuItem<String>(
              value: '0',
              child: Text('Hôm nay'),
            ),
            ...List.generate(6, (index) {
              return DropdownMenuItem<String>(
                value: (index + 1).toString(),
                child: Text('${index + 1} ngày trước'),
              );
            }).toList(),
          ],
        ),
        FutureBuilder<Map<String,int>>(
          future: fetchTimeUsage(widget.UserId, int.parse(selectedDay)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (!snapshot.hasData || snapshot.data == 0) {
              return Text('Không có dữ liệu');
            } else {
              int usageTimeInSeconds = snapshot.data!['app_usage_seconds']!;
              double usageTimeInHours = usageTimeInSeconds / 3600.0;
              int readingTimeInSeconds = snapshot.data!['totalReadingTime']!;
              double readingTimeInHours =  readingTimeInSeconds / 3600.0;
              return Column(
                children: [
                 const Padding(padding: EdgeInsets.only(right: 20),
                 child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("(Giờ)"),
                    ),
                  ),
                  Container(
                    height: 560,
                    child: BarChart(
                      BarChartData(
                        maxY: (usageTimeInHours > readingTimeInHours? usageTimeInHours : readingTimeInHours).ceilToDouble() + 1, 
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1, // Hiển thị các nhãn giá trị với khoảng cách 1 đơn vị
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value.toInt() % 1 == 0) {
                                return Padding(padding: EdgeInsets.only(left: 10),
                                  child:Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                  );
                                }
                                return Container();
                              },
                              reservedSize: 40,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1, // Hiển thị các nhãn giá trị với khoảng cách 1 đơn vị
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value.toInt() % 1 == 0) {
                                  return Padding(padding: EdgeInsets.only(left: 10),
                                  child:Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                  );
                                }
                                return Container();
                              },
                              reservedSize:40,
                            ),
                          ),
                        ),
                        barGroups: [
                          // Cột màu xanh (thời gian sử dụng)
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: usageTimeInHours,
                                width: 40,
                                color: Colors.blue,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                            ],
                           
                          ),
                          // Cột màu vàng (thời gian đọc truyện)
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: readingTimeInHours,
                                width: 40,
                                color: Colors.yellow,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                            ],
                           
                          ),
                        ],
                        barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,) {
                            return BarTooltipItem(
                              formatDuration((rod.toY.toDouble()*3600).toInt()),
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(color: Colors.blue, label: 'Thời gian sử dụng'),
                      SizedBox(width: 20),
                      _buildLegend(color: Colors.yellow, label: 'Thời gian đọc truyện'),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
