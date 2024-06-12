import 'package:flutter/material.dart';
import 'package:manga_application_1/compoment/CheckLoginStatus.dart';


void main() {
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
      home: SplashScreen()
    );
  }
}


