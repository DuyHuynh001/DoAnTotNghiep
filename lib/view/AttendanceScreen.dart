import 'package:comicz/model/User.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInScreen extends StatefulWidget {
  final String userId;
  const CheckInScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> checkInData = {};
  bool isTodayChecked = false;
  int points=0;

  @override
  void initState() {
    super.initState();
    _checkAndResetWeek();
    _loadCheckInData();
    _fetchUserData();
  }
  
  Future<void> _fetchUserData() async {
    User user = await User.fetchUserById(widget.userId);
    if (user != null) {
      setState(() {
        points= user.Points;
      });
    }
  }

  int weekOfYear(DateTime dateTime) {
    var firstDayOfYear = DateTime(dateTime.year, 1, 1);
    var days = dateTime.difference(firstDayOfYear).inDays;
    return ((days + firstDayOfYear.weekday) / 7).ceil();
  }

  //lấy dử liệu điểm danh và kiểm tra xem đã điểm danh chưa
  void _loadCheckInData() async {
    DocumentSnapshot snapshot = await _firestore.collection('Attendance').doc(widget.userId).collection('checkIn').doc('currentWeek').get();
    if (snapshot.exists) {
      setState(() {
        checkInData = snapshot.data() as Map<String, dynamic>;
        isTodayChecked = checkInData['day${DateTime.now().weekday}'] ?? false;
      });
    } else {
      setState(() {
        checkInData = {};
        isTodayChecked = false;
      });
    }
  }

  Future<void> _checkIn(int day) async {
    DateTime today = DateTime.now();
    int todayIndex = today.weekday;
    if (day != todayIndex) return;

    if (isTodayChecked) {
      _showNotification('Bạn đã điểm danh hôm nay!');
      return;
    }  
    setState(() {
      checkInData['day$day'] = true;
      isTodayChecked = true; 
    });

    await _firestore.collection('Attendance').doc(widget.userId).collection('checkIn').doc('currentWeek').set({
      'day$day': true,
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection("User").doc(widget.userId).update({
      'Points': FieldValue.increment(200),
    });
    _showNotification('Bạn đã nhận được 200 xu!');
    _fetchUserData();
  }

  void _checkAndResetWeek() async {
    DateTime now = DateTime.now();
    int currentWeek = weekOfYear(now);

    DocumentReference userDocRef = _firestore.collection('Attendance').doc(widget.userId);
    DocumentSnapshot userDoc = await userDocRef.get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    int lastWeek = userData?['lastCheckInWeek'] ?? currentWeek;

    if (currentWeek != lastWeek) {
      await userDocRef.set({
        'lastCheckInWeek': currentWeek,
        'checkIn': {
          'currentWeek': {
            'day1': false,
            'day2': false,
            'day3': false,
            'day4': false,
            'day5': false,
            'day6': false,
            'day7': false,
          }
        }
      }, SetOptions(merge: true));
    }
  }

  void _showNotification(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông báo'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return Scaffold(
      appBar: AppBar(
        title: Text('Điểm Danh Hàng Tuần'),
      ),
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.grey.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.5, 0.5],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 45,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${points.toString()} Xu',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 0.35,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          DateTime date = startOfWeek.add(Duration(days: index));
                          int day = index + 1;
                          bool isToday = today.day == date.day &&
                            today.month == date.month &&
                            today.year == date.year;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: isToday? () {
                                  _checkIn(day);
                                }: null,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(7, 14, 7, 14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isToday
                                      ? Border.all(color: Colors.red.shade300, width: 2.0)
                                      : Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('+200',style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold,),),
                                      SizedBox(height: 10.0),
                                      Icon(
                                        checkInData['day$day'] == true ? Icons.check_circle : Icons.monetization_on,
                                        color: checkInData['day$day'] == true ? Colors.green : Colors.orange,
                                        size: 35,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                isToday ? 'Hôm nay' : 'Ngày $day',
                                style: TextStyle(
                                  color: isToday ? Colors.red : Colors.black,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 45, vertical: 16),
                        ),
                        onPressed: () {
                          _checkIn(today.weekday);
                        },
                        child: const Text('Nhận ngay 200 xu', style: TextStyle(fontSize: 16),),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

