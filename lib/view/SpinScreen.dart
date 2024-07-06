import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class SpinWheelPage extends StatefulWidget {
  @override
  _SpinWheelPageState createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage>

  with SingleTickerProviderStateMixin {
  double _angle = 0;
  double _targetAngle = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<int> points = [100, 200, 300, 400, 500, 600, 700, 800];
  int _selectedPoint = 0;
  final _audioCache = AudioPlayer();
  int _stopIndex = 0; 
  int _SpinCount=3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _stopIndex = points.indexOf(100); 
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          _angle = _animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _calculateSelectedPoint();
          _showCongratulationsDialog();
          _playNotificationSound();
          _SpinCount--; // Giảm số lần quay sau mỗi lần quay thành công
          // if (_SpinCount <= 0) {
          //   _showNoSpinLeftDialog(); // Hiển thị thông báo hết lượt quay
          // }
        }
      });
    _animation = Tween<double>(begin: 0, end: 8 * 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _spinWheel() {
     if (_SpinCount > 0) {
    _controller.reset();
    double random = Random().nextDouble();
    if (random < 0.60) {
      _stopIndex = points.indexOf(100);
    } else if (random < 0.30) {
      _stopIndex = points.indexOf(200);
    } else {
      _stopIndex = Random().nextInt(points.length - 2) + 2;
    }
    double targetAngle =_stopIndex * (2 * pi / points.length) + (pi / points.length);
    _targetAngle = targetAngle + 8 * 2 * pi; 
    _animation = Tween<double>(begin: _angle, end: _targetAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    } else {
      _showNoSpinLeftDialog(); // Hiển thị thông báo hết lượt quay
    }
  }

  void _calculateSelectedPoint() {
    int index = (_stopIndex) % points.length;
    _selectedPoint = points[index];
  }

  void _playSpinSound() {
    _audioCache.play(AssetSource('audio/spin_sound.mp3'), volume: 0.7);
  }

  void _playNotificationSound() {
     _audioCache.play(AssetSource('audio/notification_sound.mp3'), volume: 0.3);
  }

  void _showCongratulationsDialog() {
    _playNotificationSound();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chúc mừng'),
          content: Text('Chúc mừng bạn nhận được $_selectedPoint điểm'),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showNoSpinLeftDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông báo'),
          content: Text('Bạn đã hết lượt quay'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vòng Quay Điểm Thưởng'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/background2.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(0, 10, 10,140),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text('Lượt quay miễn phí: '+_SpinCount.toString(),
                    style:const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
            
          Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _angle,
                    child: CustomPaint(
                      size: Size(320, 320),
                      painter: WheelPainter(points),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), // Đặt bán kính bo góc là 20
                ),
                child:  ElevatedButton(
                  onPressed: () {
                    if(_SpinCount>0)
                    {
                       _playSpinSound();
                       _spinWheel();
                    }
                    else  _showNoSpinLeftDialog(); // Hiển thị thông báo hết lượt quay
                    
                  },
                  child: Text('Quay',style: TextStyle(fontSize: 23, ),),
                ),
              ),
            ],
          ),
        ),

          ],
        )
       
      ),
    );
  }
}
class WheelPainter extends CustomPainter {
  final List<int> points;

  WheelPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.indigo,
      Colors.amber
    ];
    for (int i = 0; i < points.length; i++) {
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        (i - 1.7) * 2 * pi / points.length,
        2 * pi / points.length,
        true,
        paint,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: points[i].toString(),
          style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(i * 2 * pi / points.length + pi / points.length);
      canvas.translate(0, -size.height / 2 + textPainter.height / 2 + 10);
      textPainter.paint(canvas,Offset(30 + textPainter.width / -2, textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
