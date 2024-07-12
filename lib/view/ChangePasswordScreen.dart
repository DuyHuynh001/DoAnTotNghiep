import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  const ChangePasswordScreen({Key? key, required this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _changePassword() async {
  String oldPassword = _oldPasswordController.text.trim();
  String newPassword = _newPasswordController.text.trim();
  String confirmPassword = _confirmPasswordController.text.trim();

  if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng điền đầy đủ thông tin'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  if ( newPassword.length <6 || confirmPassword.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mật khẩu phải lớn hơn 6 ký tự'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  if (newPassword != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mật khẩu mới và xác nhận mật khẩu không khớp'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: widget.email, password: oldPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công'),
          duration: Duration(seconds: 2),
        ),
      );
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      FocusScope.of(context).unfocus();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng kiểm tra lại mật khẩu cũ'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đổi mật khẩu"),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Nhập mật khẩu cũ",
                  prefixIcon: Icon(Icons.password, size: 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureTextPassword,
                decoration: InputDecoration(
                  labelText: "Nhập mật khẩu mới",
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
                  border: OutlineInputBorder(
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
                  prefixIcon: Icon(Icons.check_circle_rounded, size: 30),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.fromLTRB(120, 14, 120, 14),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                ),
                onPressed: _changePassword,
                child: const Text(
                  "Thay đổi",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
