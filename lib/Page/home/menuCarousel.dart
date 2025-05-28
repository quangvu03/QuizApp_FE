import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/discoverCourse.dart';

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
      [
        {'icon': Icons.leaderboard, 'label': 'Bảng xếp hạng', 'color': Colors.yellow},
        {'icon': Icons.quiz, 'label': 'Đề thi', 'color': Colors.blue},
        {'icon': Icons.account_balance_wallet, 'label': 'Ví sử dụng', 'color': Colors.green},
        {'icon': Icons.class_, 'label': 'Lớp học tập', 'color': Colors.orange},
        {'icon': Icons.school, 'label': 'Phòng thi', 'color': Colors.purple},
        {'icon': Icons.assessment, 'label': 'Kết quả của tôi', 'color': Colors.red},
      ],
      [
        {'icon': Icons.chat_bubble, 'label': 'Kênh đề', 'color': Colors.teal},
        {'icon': Icons.download, 'label': 'Đề thi tải xuống', 'color': Colors.indigo},
      ]
    ];

    return Column(
      children: [
        SizedBox(
          height: 300,
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
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Semi-transparent white background
                  borderRadius: BorderRadius.circular(10), // Optional: rounded corners
                ),
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 0.65,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 15.0,
                  physics: const NeverScrollableScrollPhysics(),
                  children: menuPages[index].map((menuItem) {
                    return _buildMenuItem(
                      menuItem['icon'],
                      menuItem['label'],
                      menuItem['color'],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
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

  Widget _buildMenuItem(IconData icon, String label, Color color) {
    bool isHot = label == 'Bảng xếp hạng';
    return InkWell(
      onTap: () {
        if (label == 'Đề thi') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscoverCourse()));
        } else if (label == 'Phòng thi') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn đã nhấn vào Phòng thi!')),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.8),
                      color.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    child: Icon(icon, size: 30, color: Colors.white),
                  ),
                ),
              ),
              if (isHot)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Hot',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}