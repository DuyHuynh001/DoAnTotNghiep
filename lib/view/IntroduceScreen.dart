import 'package:flutter/material.dart';

class IntroduceScreen extends StatelessWidget {
  const IntroduceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Introduce"),
        ),
        body: Container(
          child: const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Giới thiệu sản phẩm",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "I. Giới thiệu chung:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Column(
                      children: [
                        Text(
                            "Sản phẩm đọc truyện online là một nền tảng kỹ thuật số cho phép người dùng truy cập và đọc các loại truyện từ nhiều thể loại khác nhau như tiểu thuyết, truyện tranh, truyện ngắn, truyện dài kỳ, và nhiều loại hình văn học khác. Đây là một giải pháp tiện lợi cho những ai yêu thích đọc truyện mà không cần phải mang theo sách giấy hay tìm kiếm cửa hàng sách."),
                      ],
                    ),
                  ),
                  Text(
                    "II. Tính năng chính của sản phẩm đọc truyện online:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Column(
                      children: [
                        Text(
                            "1. Thư viện đa dạng: Cung cấp một thư viện rộng lớn với hàng ngàn đầu sách và truyện thuộc nhiều thể loại như hành động, lãng mạn, kinh dị, khoa học viễn tưởng, phiêu lưu, kỳ ảo, v.v."),
                        Text(
                            "2. Giao diện người dùng thân thiện: Giao diện được thiết kế dễ sử dụng, cho phép người dùng dễ dàng tìm kiếm, duyệt và đọc truyện. Các tính năng như điều chỉnh cỡ chữ, màu nền và chế độ đọc đêm giúp nâng cao trải nghiệm đọc."),
                        Text(
                            "3. Cập nhật thường xuyên: Thêm các chương mới và cập nhật truyện một cách định kỳ để đảm bảo người dùng luôn có nội dung mới để đọc."),
                        Text(
                            "4. Tương tác cộng đồng: Người dùng có thể đánh giá, bình luận và chia sẻ cảm nhận về các truyện họ đã đọc, tạo nên một cộng đồng người yêu sách."),
                        Text(
                            "5. Đồng bộ đa nền tảng: Đồng bộ dữ liệu đọc giữa các thiết bị khác nhau, cho phép người dùng tiếp tục đọc từ điểm dừng trước đó trên bất kỳ thiết bị nào."),
                        Text(
                            "6. Tùy chỉnh cá nhân: Người dùng có thể tạo danh sách yêu thích, theo dõi các tác giả hoặc bộ truyện mà họ quan tâm để nhận thông báo khi có chương mới."),
                      ],
                    ),
                  ),
                  Text(
                    "III. Lợi ích của việc sử dụng sản phẩm đọc truyện online:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Column(
                      children: [
                        Text(
                            "1. Tiện lợi và linh hoạt: Người dùng có thể đọc truyện ở bất cứ đâu và bất cứ khi nào, chỉ cần có thiết bị kết nối internet."),
                        Text(
                            "2. Tiết kiệm chi phí: Nhiều nền tảng cung cấp truyện miễn phí hoặc với chi phí rất thấp so với việc mua sách giấy"),
                        Text(
                            "3. Bảo vệ môi trường: Giảm nhu cầu in ấn sách giấy, góp phần bảo vệ tài nguyên thiên nhiên."),
                        Text(
                            "4. Trải nghiệm tương tác: Nhiều nền tảng cho phép người dùng tham gia vào cộng đồng, chia sẻ ý kiến và thảo luận về các truyện yêu thích."),
                      ],
                    ),
                  ),
                  Text(
                    "IV. Xu hướng phát triển của sản phẩm đọc truyện online:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Column(
                      children: [
                        Text(
                            "1. Cá nhân hóa trải nghiệm: Sử dụng trí tuệ nhân tạo để đề xuất truyện dựa trên sở thích và hành vi đọc của người dùng."),
                        Text(
                            "2. Nội dung phong phú: Mở rộng nội dung không chỉ dừng lại ở truyện chữ mà còn bao gồm truyện tranh, sách nói (audiobooks), và video truyện."),
                        Text(
                            "3. Kết hợp công nghệ thực tế ảo (VR): Tạo ra các trải nghiệm đọc truyện sống động và tương tác hơn bằng công nghệ VR."),
                        Text(
                            "4. Tích hợp thanh toán và dịch vụ thuê bao: Cung cấp các gói thuê bao với nhiều quyền lợi và tính năng đặc biệt dành cho người dùng cao cấp."),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "V. Kết luận",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                        "Sản phẩm đọc truyện online đã và đang trở thành một phần không thể thiếu trong cuộc sống của những người yêu thích đọc sách, mở ra một thế giới văn học mới với vô vàn tiện ích và trải nghiệm thú vị."),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
