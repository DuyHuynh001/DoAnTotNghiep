// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA-h7OHMNwcghs_CHwlZj8fTZx6yMjEbT4',
    appId: '1:1023902310841:web:5c7a80f28af82b05e05668',
    messagingSenderId: '1023902310841',
    projectId: 'appdoctruyentranhonline',
    authDomain: 'appdoctruyentranhonline.firebaseapp.com',
    storageBucket: 'appdoctruyentranhonline.appspot.com',
    measurementId: 'G-1FWTW4EYYL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYhFOsgizpCtLVVKGZ8Yyf27deGTGtVYw',
    appId: '1:1023902310841:android:6e3a78a35a0e6ce9e05668',
    messagingSenderId: '1023902310841',
    projectId: 'appdoctruyentranhonline',
    storageBucket: 'appdoctruyentranhonline.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDByPiwAKVkWJtzsb503FFkcyu9ely7BCA',
    appId: '1:1023902310841:ios:62531add52a696a2e05668',
    messagingSenderId: '1023902310841',
    projectId: 'appdoctruyentranhonline',
    storageBucket: 'appdoctruyentranhonline.appspot.com',
    androidClientId: '1023902310841-3ahkbktnkgl2vkiga8lak5esumkd67b1.apps.googleusercontent.com',
    iosClientId: '1023902310841-s2gtgih9i1bbjgkbl3egdrnumjn56dag.apps.googleusercontent.com',
    iosBundleId: 'com.example.mangaApplication1',
  );
}