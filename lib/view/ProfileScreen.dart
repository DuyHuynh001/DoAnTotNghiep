import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/IntroduceScreen.dart';
import 'package:manga_application_1/view/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String UserId;

  const ProfileScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  String _newName = '';
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User user = await User.fetchUserById(widget.UserId);
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  TextEditingController _nameController = TextEditingController();

  void _showEditNameDialog() {
    _nameController.text = _user?.Name ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Chỉnh sửa biệt danh',
          style: const TextStyle(color: Colors.blue, fontSize: 20.0),
        ),
        content:
            // TextField(
            //   controller: _nameController,
            //   decoration: InputDecoration(
            //     hintText: 'Nhập tên mới',
            //   ),
            // ),
            TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Nhập tên mới',
            prefixIcon: Icon(
              Icons.account_box_rounded,
              size: 30,
              color: Colors.blue,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                  color: Colors.blue, width: 2.0), // Đường viền khi focus
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Hủy',
              style: const TextStyle(color: Colors.blue, fontSize: 15.0),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _newName = _nameController.text;
                _saveChanges();
              });
              Navigator.of(context).pop();
            },
            child: Text(
              'Lưu',
              style: const TextStyle(color: Colors.blue, fontSize: 15.0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_newName.isNotEmpty) {
      // Update user name locally
      setState(() {
        _user?.Name = _newName;
      });

      try {
        // Update user name in Firestore
        await FirebaseFirestore.instance
            .collection('User')
            .doc(_user?.Id)
            .update({'Name': _newName});

        print('User name updated successfully in Firestore!');
      } catch (e) {
        print('Failed to update user name in Firestore: $e');
        // Rollback local changes if update fails
        setState(() {
          _user?.Name = _nameController.text; // Reset to previous name
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Màn Hình cá nhân"),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildUserInfo(),
              const SizedBox(height: 15),
              _buildMemberFunctions(),
              const SizedBox(height: 10),
              _buildSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return _user != null
        ? Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/img/hinh1.jpg'),
                    radius: 50,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Biệt danh: ${_user!.Name}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              onPressed: _showEditNameDialog,
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ))
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Email: ${_user!.Email}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoColumn(_user!.Points.toString(), 'Xu của tôi'),
                  const SizedBox(width: 100),
                  _buildInfoColumn(_user!.Level.toString(), 'Level của tôi'),
                ],
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildInfoColumn(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.blue, fontSize: 20.0),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 20.0),
        ),
      ],
    );
  }

  Widget _buildMemberFunctions() {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Chức năng thành viên",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildMemberFunctionCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberFunctionCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            spreadRadius: 0.5,
            blurRadius: 7,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFunctionButton(
              icon: Icons.today,
              label: "Điểm danh",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Title'),
                    content: const Text('Content'),
                    actions: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Button'),
                      ),
                    ],
                  ),
                );
              },
            ),
            // const SizedBox(height: 2),
            // _buildFunctionButton(
            //   icon: Icons.person,
            //   label: "Thông tin cá nhân",
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) =>
            //             DTProfileScreen(userId: widget.UserId),
            //       ),
            //     );
            //   },
            // ),
            const SizedBox(height: 2),
            _buildFunctionButton(
              icon: Icons.favorite_border,
              label: "Danh sách yêu thích",
              onPressed: () {
                // Implement navigation to favorites list
              },
            ),
            const SizedBox(height: 2),
            _buildFunctionButton(
              icon: Icons.add_chart_rounded,
              label: "Xếp hạng",
              onPressed: () {
                // Implement navigation to ranking
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Cài đặt",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSettingsCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            spreadRadius: 0.5,
            blurRadius: 7,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFunctionButton(
              icon: Icons.error_outline_rounded,
              label: "Giới thiệu sản phẩm",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IntroduceScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            _buildFunctionButton(
              icon: Icons.vpn_key,
              label: "Đổi mật khẩu",
              onPressed: () {
                // Implement change password
              },
            ),
            const SizedBox(height: 2),
            _buildFunctionButton(
              icon: Icons.logout,
              label: "Đăng xuất",
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
