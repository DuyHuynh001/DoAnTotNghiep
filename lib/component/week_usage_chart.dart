import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeekUsageChart extends StatefulWidget {
  final String UserId;
  WeekUsageChart({required this.UserId});
  @override
  _WeekUsageChartState createState() => _WeekUsageChartState();
}

class _WeekUsageChartState extends State<WeekUsageChart> {
  String formatDateString(String dateString) {
    List<String> parts = dateString.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);
    return '$year-$month-$day';
  }

  Future<List<BarChartGroupData>> fetchWeekUsage(String userId) async {
    List<BarChartGroupData> barChartData = [];
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    for (int i = 0; i <= today.weekday - 1; i++) {
      DateTime date = startOfWeek.add(Duration(days: i));
      String dateString = date.toIso8601String().substring(0, 10);
      String formattedDateString = formatDateString(dateString);

      DocumentSnapshot appUsageSnapshot = await FirebaseFirestore.instance
          .collection('AppUsage')
          .doc(userId)
          .collection('DailyUsage')
          .doc(formattedDateString)
          .get();

      int usageTime = 0;
      if (appUsageSnapshot.exists) {
        Map<String, dynamic>? appUsageData = appUsageSnapshot.data() as Map<String, dynamic>?;
        usageTime = appUsageData?['app_usage_seconds'] ?? 0;
      }

      DocumentSnapshot readingSnapshot = await FirebaseFirestore.instance
          .collection('AppUsage')
          .doc(userId)
          .collection('DailyReading')
          .doc(formattedDateString)
          .get();

      int readingTime = 0;
      if (readingSnapshot.exists) {
        Map<String, dynamic>? readingData = readingSnapshot.data() as Map<String, dynamic>?;
        readingTime = readingData?['totalReadingTime'] ?? 0;
      }
  
     double usageTimeInHours = usageTime / 3600.0;    
     double readingTimeInHours = readingTime / 3600.0;
      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: usageTimeInHours,
              width: 15, 
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ), 
              color: Colors.blue),
            BarChartRodData(
              toY: readingTimeInHours,
              width:15,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              color: Colors.yellow),
          ],
        ),
      );
    }
    return barChartData;
  }

  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String secondsStr = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secondsStr';
  }
  double calculateMaxY(List<BarChartGroupData> data) {
    double maxY = 0;
    for (var groupData in data) {
      for (var rodData in groupData.barRods) {
        if (rodData.toY > maxY) {
          maxY = rodData.toY;
        }
      }
    }
    return maxY;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BarChartGroupData>>(
      future: fetchWeekUsage(widget.UserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          double maxY = calculateMaxY(snapshot.data!);
          return Column(
            children: [
              const Padding(padding: EdgeInsets.only(right: 10, top: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text("(Giờ)"),
                ),
              ),
              Container(
                height: 560,
                child: BarChart(
                  BarChartData(
                    barGroups: snapshot.data!,
                    maxY: maxY.ceilToDouble()+1,
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
                          reservedSize: 20,
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
                          reservedSize:20,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1, 
                          getTitlesWidget: (double value, TitleMeta meta) { 
                            Widget text;
                            switch (value.toInt()) {
                              case 0:
                                text = const Text('Thứ 2');
                                break;
                              case 1:
                                text = const Text('Thứ 3');
                                break;
                              case 2:
                                text = const Text('Thứ 4');
                                break;
                              case 3:
                                text = const Text('Thứ 5');
                                break;
                              case 4:
                                text = const Text('Thứ 6');
                                break;
                              case 5:
                                text = const Text('Thứ 7');
                                break;
                              case 6:
                                text = const Text('Chủ nhật');
                                break;
                              default:
                                text = const Text('');
                                break;
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8,
                              child: text,
                            );
                          },
                        ),    
                      ),
                    ),
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
              SizedBox(height: 15,),
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

