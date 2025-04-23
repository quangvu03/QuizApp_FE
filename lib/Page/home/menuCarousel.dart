import 'package:flutter/material.dart';

class MenuCarousel extends StatefulWidget {
  const MenuCarousel({Key? key}) : super(key: key);

  @override
  _MenuCarouselState createState() => _MenuCarouselState();
}

class _MenuCarouselState extends State<MenuCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<List<Map<String, dynamic>>> menuPages = [
      // Trang 1
      [
        {'icon': Icons.star, 'label': 'Bảng xếp hạng'},
        {'icon': Icons.edit, 'label': 'Đề thi'},
        {'icon': Icons.book, 'label': 'Ví sử dụng'},
        {'icon': Icons.class_, 'label': 'Lớp học tập'},
        {'icon': Icons.school, 'label': 'Phòng thi'},
        {'icon': Icons.abc, 'label': 'Kết quả của tói'},
      ],
      // Trang 2
      [
        {'icon': Icons.message, 'label': 'Kênh đề'},
        {'icon': Icons.download, 'label': 'Đề thi tải xuổng'},
      ]
    ];

    return Column(
      children: [
        SizedBox(
          height: 300, // Tăng chiều cao để chứa 2 hàng và tiêu đề đầy đủ
          child: PageView.builder(
            itemCount: menuPages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GridView.count(
                  crossAxisCount: 3, // 3 cột
                  childAspectRatio: 0.65, // Giảm tỷ lệ để tăng chiều cao của mỗi item
                  mainAxisSpacing: 15.0, // Khoảng cách giữa các hàng
                  crossAxisSpacing: 15.0, // Khoảng cách giữa các cột
                  physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của GridView
                  children: menuPages[index].map((menuItem) {
                    return _buildMenuItem(
                      menuItem['icon'],
                      menuItem['label'],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            menuPages.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 10.0,
              height: 10.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.pink : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[100],
          child: Icon(icon, size: 30, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2, // Cho phép xuống dòng nếu tiêu đề dài
            overflow: TextOverflow.ellipsis, // Hiển thị dấu chấm lửng nếu văn bản quá dài
          ),
        ),
      ],
    );
  }
}