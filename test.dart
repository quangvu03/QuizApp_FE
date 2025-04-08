import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Phần tiêu đề cố định
          SliverAppBar(
            pinned: true, // Cố định thanh tiêu đề khi cuộn
            expandedHeight: 150.0, // Chiều cao mở rộng của SliverAppBar
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Hình nền hoa anh đào
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1588391287449-8a4e9c2a7a41?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80', // URL hình nền hoa anh đào
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Nội dung trên hình nền
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Ảnh đại diện, tên và mô tả
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                'https://example.com/profile_image.png', // Thay bằng URL ảnh đại diện của bạn
                              ),
                              child: Icon(Icons.school,
                                  size: 30,
                                  color: Colors
                                      .white), // Icon mặc định nếu không có ảnh
                            ),
                            SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'vvuuvvuuvvu',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Học sinh/ Sinh viên',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Nhân vật hoạt hình bên phải
                        Image.network(
                          'https://example.com/character_image.png', // Thay bằng URL nhân vật hoạt hình
                          height: 80,
                          width: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error,
                                size:
                                50); // Hiển thị icon lỗi nếu không tải được ảnh
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Phần nội dung bên dưới
          SliverList(
            delegate: SliverChildListDelegate([
              // Tiêu đề "Cá nhân"
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Cá nhân',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              // Các mục tùy chọn
              const ListTile(
                leading: Icon(Icons.person, color: Colors.black54),
                title: Text('Chỉnh sửa thông tin'),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black54),
              ),
              const ListTile(
                leading: Icon(Icons.card_giftcard, color: Colors.black54),
                title: Text('Mã nhắn thưởng'),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black54),
              ),
              const ListTile(
                leading: Icon(Icons.lock, color: Colors.black54),
                title: Text('Thay đổi mật khẩu'),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black54),
              ),
              const ListTile(
                leading: Icon(Icons.language, color: Colors.black54),
                title: Text('Ngôn ngữ'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                        'https://flagcdn.com/w40/vn.png', // URL cờ Việt Nam
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Tiếng Việt', style: TextStyle(color: Colors.black54)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.black54),
                  ],
                ),
              ),
              const ListTile(
                leading: Icon(Icons.brightness_6, color: Colors.black54),
                title: Text('Giao diện'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wb_sunny, size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Sáng', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              // Phần "Liên hệ chúng tôi"
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Liên hệ chúng tôi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Góp ý của bạn rất quan trọng với chúng tôi',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[100], // Màu nền nút
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Liên hệ',
                        style: TextStyle(color: Colors.pink),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      // Thanh điều hướng dưới cùng
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.black54,
        currentIndex: 3, // Đặt mục "Tài khoản" là mục được chọn
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Kênh của tôi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
