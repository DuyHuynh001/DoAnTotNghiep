import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/compoment/Navigation.dart';
import 'package:manga_application_1/view/HomeScreen.dart';
import 'package:manga_application_1/view/RegisterScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == 'abc' && password == '123') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => NavigationScreen()));
    } else {
      showSnackBar(context, 'Tài khoản hoặc mật khẩu không đúng');
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
                  "MANGA APP",
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
