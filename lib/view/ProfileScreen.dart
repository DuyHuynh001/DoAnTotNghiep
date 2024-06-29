import 'package:manga_application_1/view/DetailprofileScreen.dart';
import 'package:manga_application_1/model/load_data.dart';
import 'package:manga_application_1/view/IntroduceScreen.dart';
import 'package:manga_application_1/view/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:manga_application_1/view/AttendanceScreen.dart';

class ProfileScreen extends StatefulWidget {
  final String UserId;

  const ProfileScreen({Key? key, required this.UserId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _MyHomeScreen();
}

class _MyHomeScreen extends State<ProfileScreen> {
  User? _user;
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
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Màn Hình cá nhân"),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/img/hinh1.jpg') as ImageProvider,
                  radius: 50,
                ),
                const SizedBox(width: 20),
                _user != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biệt danh: ${_user!.Name}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Email: ${_user!.Email}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            _user != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_user!.Points}',
                            style:
                                TextStyle(color: Colors.blue, fontSize: 20.0),
                          ),
                          Text(
                            " Xu của tôi ",
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 100,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${_user!.Level}",
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 20.0)),
                          Text(
                            "Level của tôi",
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ],
                      )
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
            const SizedBox(
              height: 10,
            ),
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Chức năng thành viên",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.5),
                            spreadRadius: 0.5,
                            blurRadius: 7,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Expanded(
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                          onPressed: () {
                                            AlertDialog(
                                              title: Text('Title'),
                                              content: Text('Content'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {},
                                                  child: Text('Button'),
                                                ),
                                              ],
                                            );
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.today,
                                                color: Colors.blue,
                                              ),
                                              Text(
                                                " Điểm danh",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              )
                                            ],
                                          )),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DTProfileScreen(
                                                      userId: widget.UserId,
                                                    )),
                                          );
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.blue,
                                            ),
                                            Text(
                                              " Thông tin cá nhân",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            )
                                          ],
                                        )),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           const Bookcase()),
                                          // );
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.favorite_border,
                                              color: Colors.blue,
                                            ),
                                            Text(
                                              " Danh sách yêu thích",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            )
                                          ],
                                        )),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    TextButton(
                                        onPressed: () {},
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.add_chart_rounded,
                                              color: Colors.blue,
                                            ),
                                            Text(
                                              " Xếp hạng",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    "Cài đặt",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.5),
                            spreadRadius: 0.5,
                            blurRadius: 7,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const IntroduceScreen()),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          " Giới thiệu sản phẩm",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black),
                                        )
                                      ],
                                    )),
                                const SizedBox(
                                  height: 2,
                                ),
                                TextButton(
                                    onPressed: () {},
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.vpn_key,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          " Đổi mật khẩu",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black),
                                        )
                                      ],
                                    )),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()),
                                        (route) =>
                                            false, // Xóa hết các màn hình khỏi stack khi chuyển hướng
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          " Đăng xuất",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black),
                                        )
                                      ],
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
