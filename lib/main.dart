
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/component/CheckLoginStatus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String envFilePath = './.env';
  await dotenv.load(fileName:envFilePath);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
         primaryColor: Colors.black
      ),
      home: CheckLogin(),
    );
  }
}
