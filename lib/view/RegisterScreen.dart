import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:comicz/view/LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuthServiceSignUp _auth = FirebaseAuthServiceSignUp();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;
  bool _isEmailVerified = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
      backgroundColor: const Color.fromARGB(255, 86, 84, 84),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool isValidEmail(String email) {
    RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email) && email.endsWith('@gmail.com');
  }

  void _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập đầy đủ thông tin');
      return;
    } else if (password != confirmPassword) {
      showSnackBar(context, 'Mật khẩu không trùng khớp');
      return;
    }

    bool isValidEmailFormat = isValidEmail(email);
    if (!isValidEmailFormat) {
      showSnackBar(context, 'Email không đúng định dạng');
      return;
    }
    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();
          _showVerificationDialog(user, name, email);
      }
    }
    catch(e)
    {
      String errorMessage = _parseFirebaseAuthError(e);
      showSnackBar(context, errorMessage);
    }
  }

  String _parseFirebaseAuthError(dynamic e) {
    String errorMessage = '';
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email đã được sử dụng';
          break;
      }
    } else {
      errorMessage = 'Đã xảy ra lỗi khi đăng ký: $e';
    }
    return errorMessage;
  }

  void _showVerificationDialog(User user, String name, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Xác thực email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Vui lòng kiểm tra email để xác thực tài khoản của bạn.'),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
    _timer = Timer.periodic(const Duration(seconds: 3), (_) =>checkEmailVerified());

    Timer(Duration(seconds: 60), () async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        Navigator.of(context).pop(); 
        showSnackBar(context, 'Xác thực email thất bại sau 60 giây. Vui lòng thử lại.');
        await FirebaseAuth.instance.currentUser?.delete(); 
      }
    });
  }

  void checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email đã được xác thực thành công")),
      );
      Navigator.of(context).pop();   
      _timer?.cancel();
      _auth.saveUserData (FirebaseAuth.instance.currentUser!.uid, _nameController.text.trim(), _emailController.text.trim());

      await Future.delayed(Duration(seconds: 3));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                padding: EdgeInsets.fromLTRB(0, 10, 0, 40),
                child: Text(
                  "Đăng Ký",
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng',
                  prefixIcon: Icon(Icons.person, size: 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: "xxxxx@gmail.com",
                  prefixIcon: Icon(Icons.email_rounded, size: 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: _obscureTextPassword,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: Icon(Icons.lock, size: 30),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextPassword = !_obscureTextPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureTextConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu",
                  prefixIcon: Icon(Icons.lock, size: 30),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  padding: const MaterialStatePropertyAll(
                    EdgeInsets.fromLTRB(120, 14, 120, 14),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                ),
                onPressed: _signUp,
                child: const Text(
                  "Đăng Ký",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: RichText(
                  text: TextSpan(
                    text: 'Đã có tài khoản? ',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Đăng nhập ngay',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class FirebaseAuthServiceSignUp {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailAndPassword(String username, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Lỗi khi đăng ký: $e");
      return null;
    }
  }

  void saveUserData(String uid, String username, String email) {
    final DocumentReference userRef = _firestore.collection('User').doc(uid);
    userRef.set({
      'Name': username,
      'Gender': "Không được đặt",
      'Points':0,
      'IsRead':0,
      'Email': email,
      'Image': "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b",
      'Status': false
    }, SetOptions(merge: true));
  }
}
