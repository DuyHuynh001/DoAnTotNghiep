class Story {
  final String title;
  final String imageUrl;
  final String id; 
  final String chapter;
  final String Introduce;
  final String Status;
  Story({required this.title, required this.imageUrl,required this.Introduce, required this.id, required this.chapter, required this.Status });
}

class StoryService {
  // Giả sử có một list các truyện từ một nguồn dữ liệu khác
  static List<Story> allStories = [
    Story(title: 'Naruto', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/naruto.jpg',id: '1',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: '7 Viên Ngọc Rồng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/7-vien-ngoc-rong.jpg',id: '2',Status:'Đang cập nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Fantasista', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/fantasista.jpg',id: '3',Status:'Đang cập nhật',chapter: "12", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Onepunch Man', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/defense-devil.jpg',id: '4',Status:'Đang cập nhật',chapter: "13", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Defense-devil', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/black-clover-the-gioi-phep-thuat.jpg',id: '5',Status:'Đang cập nhật',chapter: "15", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Phong Vân', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/phong-van.jpg',id: '6',Status:'Đang cập nhật',chapter: "19", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Ta Đem Hoàng Tử Dưỡng Thành Hắc Hóa', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-dem-hoang-tu-duong-thanh-hac-hoa.jpg',id: '7',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Khánh Dư Niên', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/khanh-du-nien.jpg',id: '8',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Ta Là Đại Thần Tiên', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-la-dai-than-tien.jpg',id: '9',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Tiên Đế Võ Tôn', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/tien-vo-de-ton.jpg',id: '10',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Dục Huyết Thương Hậu', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/duc-huyet-thuong-hau.jpg',id: '11',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Vương Gia Khắc Thê', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/vuong-gia-khac-the.jpg',id: '12',Status:'Đang cập nhật',chapter: "10", Introduce: " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"),
    Story(title: 'Doraemon ', imageUrl: 'https://tuoitho.mobi/upload/doc-truyen/doraemon-truyen-ngan/anh-dai-dien.jpg',id: '13',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Thám Tử Lừng Danh Conan', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/tham-tu-conan.jpg',id: '14',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Cuộc Chơi Trên Núi Tử Thần', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/cuoc-choi-tren-nui-tu-than.jpg',id: '15',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'One Piece', imageUrl: 'https://upload.wikimedia.org/wikipedia/vi/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg',id: '16',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Nguyên Tôn', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/nguyen-ton.jpg',id: '17',Status:'Đang Cập Nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Ma Thú Siêu Thần', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ma-thu-sieu-than.jpg',id: '18',Status:'Đang Cập Nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Đại Phụng Đả Canh Nhân', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/dai-phung-da-canh-nhan.jpg',id: '19',Status:'Đang Cập Nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Người Nuôi Rồng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/nguoi-nuoi-rong.jpg',id: '20',Status:'Đang Cập Nhật',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Thất Hình Đại Tội', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/that-hinh-dai-toi.jpg',id: '21',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Cuộc Chiến Ẩm Thực', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/cuoc-chien-am-thuc.jpg',id: '22',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Đại Vương Tha Mạng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/dai-vuong-tha-mang.jpg',id: '23',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Ta Bị Kẹt Cùng Một Ngày 1000 Năm ', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-bi-ket-cung-mot-ngay-1000-nam.jpg',id: '24',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Toàn Chức Pháp Sư', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/toan-chuc-phap-su.jpg',id: '25',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Ta Trời Sinh Đã Là Nhân Vật Phản Diện', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-troi-sinh-da-la-nhan-vat-phan-dien.jpg',id: '26',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Ta Là Tà Đế', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/ta-la-ta-de.jpg',id: '26',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Đại Quản Gia Là Ma Hoàng', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/dai-quan-gia-la-ma-hoang.jpg',id: '27',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
    Story(title: 'Võ Luyện Đỉnh Phong', imageUrl: 'https://cdnnvd.com/nettruyen/thumb/vo-luyen-dinh-phong.jpg',id: '28',Status:'Hoàn Thành',chapter: "11", Introduce: " bbbbbbbbbbbbbbbbbbbbbbbbb"),
  ];

  // Phương thức để lấy thông tin chi tiết của một truyện dựa trên ID
  static Story getStoryById(String id) {
    return allStories.firstWhere((story) => story.id == id);
  }
}
