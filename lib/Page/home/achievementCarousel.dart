import 'dart:async';
import 'package:flutter/material.dart';

class AchievementCarousel extends StatefulWidget {
  const AchievementCarousel({Key? key}) : super(key: key);

  @override
  _AchievementCarouselState createState() => _AchievementCarouselState();
}

class _AchievementCarouselState extends State<AchievementCarousel> {
  int _currentPage = 0;
  // Khởi tạo trực tiếp thay vì dùng late
  PageController _pageController = PageController(initialPage: 0);
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Tự động chuyển trang sau mỗi 3 giây
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 2) { // Số lượng trang - 1 (vì index bắt đầu từ 0)
        _currentPage++;
      } else {
        _currentPage = 0; // Quay lại trang đầu nếu đến trang cuối
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Hủy timer khi widget bị dispose
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> achievements = [
      {
        'title': 'Thành tựu trong tháng (Thử thách)',
        'averageLabel': 'Điểm trung bình',
        'averageScore': '0.10',
        'totalScore': '39',
        'icon': Icons.emoji_events,
        'iconColor': Colors.yellow,
      },
      {
        'title': 'Thành tựu tuần này',
        'averageLabel': 'Điểm trung bình',
        'averageScore': '8.50',
        'totalScore': '15',
        'icon': Icons.star,
        'iconColor': Colors.orange,
      },
      {
        'title': 'Thành tựu năm nay',
        'averageLabel': 'Điểm trung bình',
        'averageScore': '7.20',
        'totalScore': '120',
        'icon': Icons.school,
        'iconColor': Colors.blue,
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController, // Sử dụng PageController
            itemCount: achievements.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index; // Cập nhật trang hiện tại
              });
            },
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width - 32,
                margin: const EdgeInsets.only(right: 8.0),
                child: _buildAchievementSection(
                  title: achievements[index]['title'],
                  averageLabel: achievements[index]['averageLabel'],
                  averageScore: achievements[index]['averageScore'],
                  totalScore: achievements[index]['totalScore'],
                  icon: achievements[index]['icon'],
                  iconColor: achievements[index]['iconColor'],
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
            achievements.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 8.0,
              height: 8.0,
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

  // Widget để hiển thị từng ô thành tựu
  Widget _buildAchievementSection({
    required String title,
    required String averageLabel,
    required String averageScore,
    required String totalScore,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    averageLabel,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    averageScore,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 26,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    totalScore,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}