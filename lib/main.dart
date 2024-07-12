import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:comicz/component/CheckLoginStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug
  );
  String envFilePath = './.env';
  await dotenv.load(fileName: envFilePath);
  MyAppState myAppState = MyAppState();
  runApp(MyApp(myAppState: myAppState));
}

class MyApp extends StatefulWidget {
  final MyAppState myAppState;

  const MyApp({Key? key, required this.myAppState}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeUserId();
    widget.myAppState.trackAppUsage(); // Bắt đầu theo dõi thời gian sử dụng khi ứng dụng khởi động
  }

  Future<void> _initializeUserId() async {
    _userId = await widget.myAppState.checkLoginStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state ==AppLifecycleState.detached) {
      widget.myAppState.onAppPause(); // Gọi khi ứng dụng bị paused
    }
    else if
    (state ==AppLifecycleState.resumed)
    {
      widget.myAppState.onAppResume();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: CheckLogin(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  DateTime? _appOpenTime;
  int _currentUsage = 0; // Thời gian sử dụng hiện tại trong phiên ứng dụng

  Future<String> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('UserId') ?? '';
  }

  void trackAppUsage() {
    _appOpenTime = DateTime.now();
  }

  void onAppPause() {
    if (_appOpenTime != null) {
      _currentUsage = DateTime.now().difference(_appOpenTime!).inSeconds;
      _saveAppUsageToFirestore(); // Lưu thời gian sử dụng vào Firestore khi ứng dụng bị pause
    }
  }

  void onAppResume() {
    _appOpenTime = DateTime.now();
  }

  Future<void> _saveAppUsageToFirestore() async {
    if (_appOpenTime != null) {
      DateTime now = DateTime.now();
      String dateKey = '${now.year}-${now.month}-${now.day}';
      String userId = await checkLoginStatus();

      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        CollectionReference appUsageRef = firestore.collection('AppUsage').doc(userId).collection("DailyUsage");

        // Kiểm tra xem đã có tài liệu cho ngày hôm nay chưa
        DocumentReference docRef = appUsageRef.doc(dateKey);
        bool docExists = (await docRef.get()).exists;

        if (docExists) {
          await docRef.update({
            'app_usage_seconds': FieldValue.increment(_currentUsage),
          });
        } else {
          // Nếu chưa có, tạo tài liệu mới
          await docRef.set({
            'app_usage_seconds': _currentUsage,
            'user': userId,
            'date': FieldValue.serverTimestamp(),
          });
        }
        _currentUsage = 0;
      } catch (e) {
        print('Error saving app usage to Firestore: $e');
      }
    }
  }
}

