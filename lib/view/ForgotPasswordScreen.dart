import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_application_1/view/LoginScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

   Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link đặt lại mật khẩu đã được gửi đến bạn! Kiểm tra Email của bạn.')),
      );
      // Sau khi gửi email thành công, quay về màn hình đăng nhập
      Navigator.pop(context); // Quay về màn hình trước đó (đã được đăng nhập)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ' + e.toString())),
      );
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                child: Text(
                  "QUÊN MẬT KHẨU",
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 40.0),
                ),
              ),
            SizedBox(height: 20),
            Center(
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock, color: Colors.grey,size: 50,),
                        Expanded(child: Text("Vui lòng nhập email và chúng tôi sẽ gửi cho bạn một liên kết để đặt lại mật khẩu của bạn.",style: TextStyle(fontSize: 16), )
                      ),
                     ],
                    ),
                    SizedBox(height: 10,),
                    Container(
                      height: 1.0,
                      color:  Colors.grey,
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                         Text("Địa chỉ Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      ],),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration:const InputDecoration(
                        hintText: "xxxxx@gmail.com",
                        prefixIcon: Icon(Icons.email_rounded, size: 30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.fromLTRB(85, 14, 85, 14)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.lightBlue),
                        ),
                        onPressed: _resetPassword,
                        child:const  Text("Đặt lại mật khẩu",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Đã có tài khoản? ',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          children: <TextSpan>[
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
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
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
          ],
        ),
      ),
    );
  }
}
