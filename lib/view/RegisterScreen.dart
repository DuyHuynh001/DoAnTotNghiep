import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/view/LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const  RegisterScreen({super.key});

   @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
    bool _obscureTextPassword = true;
    bool _obscureTextComfirmPassword=true;
    final  FirebaseAuthServiceSignUp _auth = FirebaseAuthServiceSignUp();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();

    void showSnackBar(BuildContext context, String message) {
      final snackBar = SnackBar(
        content: Text(message,style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
        backgroundColor: const Color.fromARGB(255, 86, 84, 84));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    bool isValidEmail(String email) {
      RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return emailRegex.hasMatch(email) && email.endsWith('@gmail.com');
    }

   Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty; // Trả về true nếu có phương thức đăng nhập được liên kết với email này
    } catch (e) {
      print('Đã xảy ra lỗi khi kiểm tra email: $e');
      return false; // Trả về false nếu có lỗi xảy ra
    }
  }
  
  void _SignUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String name= _nameController.text.trim();
    if(email.isEmpty || password.isEmpty||confirmPassword.isEmpty||name.isEmpty)
    {
      showSnackBar(context, 'Vui lòng nhập đầy đủ thông tin');
      return;
    }
    else if (password != confirmPassword) {
      showSnackBar(context, 'Mật khẩu không trùng khớp');
      return;
    }
    bool isvalidEmail = await isValidEmail(email);
    if (!isvalidEmail) {
      showSnackBar(context, 'Email không đúng định dạng');
      return;
    }
    bool isEmailUsed = await isEmailAlreadyRegistered(email);
    if (isEmailUsed) {
      showSnackBar(context, 'Email đã được sử dụng');
      return;
    }
    
    try {
      // Tạo tài khoản người dùng trên Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;

    _auth.signUpWithEmailAndPassword(name,email,password);
    _auth.saveUserData(uid,name,email);
      showSnackBar(context, 'Đăng ký thành công. Bạn có thể đăng nhập');

      Navigator.pop(context); 
    } catch (e) {
      print('Đăng ký thất bại: $e');
      showSnackBar(context, 'Đã xảy ra lỗi khi đăng ký');
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
                    fontSize: 40.0),
                ),
              ),
              TextField(
                controller: _nameController,
                decoration:const InputDecoration(
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
                decoration:const InputDecoration(
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
                  border:const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureTextComfirmPassword,
                decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu",
                  prefixIcon: Icon(Icons.lock, size: 30),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextComfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextComfirmPassword = !_obscureTextComfirmPassword;
                      });
                    },
                  ),
                  border:const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                ),
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  padding:const MaterialStatePropertyAll(
                      EdgeInsets.fromLTRB(120, 14, 120, 14)),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.lightBlue),
                ),
                onPressed: _SignUp,
                child:const  Text("Đăng Ký",
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()),);
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
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailAndPassword(String username,String email, String password ) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
        
    return userCredential.user;
  } catch (e) {
    print("Error during registration: $e");
    return null;
  }
}
// Lưu thông tin người dùng vào  Database fire store
void saveUserData(String uid, String username,String email) {
  final DocumentReference userRef = _firestore.collection('User').doc(uid);
  userRef.set({
      'Name': username,
      'Gender':"Không được đặt",
      'Email': email,
      'Image': "https://firebasestorage.googleapis.com/v0/b/appdoctruyentranhonline.appspot.com/o/No-Image-Placeholder.svg.webp?alt=media&token=319ebc86-9ec0-4a16-a877-b477564b212b",
      'Status': false
    }, SetOptions(merge: true));
  }
}
