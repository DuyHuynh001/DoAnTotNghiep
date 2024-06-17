import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/compoment/Navigation.dart';
import 'package:manga_application_1/view/HomeScreen.dart';
import 'package:manga_application_1/view/RegisterScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isSigning = false;
  bool _obscureText = true;

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
        content: Text(message,
            style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
          backgroundColor: const Color.fromARGB(255, 86, 84, 84));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
void _signIn() async {
    String email = _usernameController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập tài khoản và mật khẩu.');
      return;
    }
    setState(() {
      _isSigning = true;
    });
    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
       
      if( user!=null)
      {
        String userId = user.uid;
        prefs.setString('UserId', userId);
        print("Id:"+ userId);
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => NavigationScreen(UserId: userId)), );
        
      }
    } catch (e) {
        showSnackBar(context, 'Tài khoản hoặc mật khẩu không đúng');
    } finally {
      setState(() {
        _isSigning = false;
      });
    }
  }
  
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/backgroundlogin.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
                child: Text(
                  "COMICZ APP",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 40.0),
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration:const InputDecoration(
                  labelText: 'Tài khoản',
                  prefixIcon: Icon(Icons.person, size: 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0,20, 0, 0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    prefixIcon: Icon(Icons.lock, size: 30),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border:const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    padding: MaterialStatePropertyAll(
                        EdgeInsets.fromLTRB(110, 14, 110, 14)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightBlue),
                  ),
                  onPressed: _signIn,
                  child:const  Text( "Đăng Nhập",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: RichText(
                  text: TextSpan(
                    text: 'Bạn chưa có tài khoản? ',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Đăng ký',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
class FirebaseAuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<User?> signUpWithEmailAndPassword(String username, String phoneNumber,
      String email, String password, bool status) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user?.uid ?? "";
      return userCredential.user;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Some Error $e");
    }
  }
  Future<bool> getUserStatus(String userId) async {
  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();

    if (userDoc.exists) {
      // Lấy giá trị trường 'status' trong tài liệu người dùng
      bool status = userDoc['status'] ?? false;
      return status;
    } else {
      print('User document not found for ID: $userId');
      return false;
    }
  } catch (e) {
    print("Error getting user status: $e");
    return false;
  }
}
}
