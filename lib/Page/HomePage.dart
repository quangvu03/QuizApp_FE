import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/discoverCourse.dart';
import 'package:quizapp_fe/Page/home/Carousel.dart';
import 'package:quizapp_fe/Page/home/Feeback.dart';
import 'package:quizapp_fe/Page/home/achievementCarousel.dart';
import 'package:quizapp_fe/Page/home/favoritetestCourse.dart';
import 'package:quizapp_fe/Page/home/menuCarousel.dart';
import 'package:quizapp_fe/Page/home/recentTestsCarousel.dart';
import 'package:quizapp_fe/Page/home/collectionsCarousel.dart';
import 'package:quizapp_fe/Page/infor.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String name = "Noname";
  String imageUrl = "unknown.png";
  List<Map<String, dynamic>> achievements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchAchievements();
  }

  void _onItemTapped(int index) async {
    if (index == 4) {
      setState(() {
        _selectedIndex = 4;
      });
      print("select: $_selectedIndex");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      setState(() {
        _selectedIndex = 1;
      });
      print("select: $_selectedIndex");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DiscoverCourse()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? avatar = prefs.getString('avatar_path');
    print('Loaded username: $username, avatar: $avatar');

    setState(() {
      name = username ?? "Noname";
      imageUrl = avatar ?? "unknown.png";
    });
  }

  Future<void> _fetchAchievements() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('YOUR_API_ENDPOINT_HERE'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          achievements = data.map((item) {
            return {
              'title': item['title'] ?? 'Thành tựu không xác định',
              'averageLabel': item['averageLabel'] ?? 'Điểm trung bình',
              'averageScore': item['averageScore'].toString() ?? '0.0',
              'totalScore': item['totalScore'].toString() ?? '0',
              'icon': _mapIcon(item['icon'] ?? 'emoji_events'),
              'iconColor': _mapColor(item['iconColor'] ?? 'yellow'),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load achievements');
      }
    } catch (e) {
      print('Error fetching achievements: $e');
      setState(() {
        isLoading = false;
        achievements = [
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
      });
    }
  }

  IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'star':
        return Icons.star;
      case 'school':
        return Icons.school;
      default:
        return Icons.emoji_events;
    }
  }

  Color _mapColor(String colorName) {
    switch (colorName) {
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent,
              Colors.purpleAccent,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: imageUrl != "unknown.png"
                            ? ClipOval(
                          child: Image.network(
                            "${BaseUrl.urlImage}/$imageUrl",
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.school_outlined,
                              size: 30,
                              color: Colors.blueAccent,
                            ),
                          ),
                        )
                            : const Icon(
                          Icons.school_outlined,
                          size: 30,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "Học sinh/ sinh viên",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications_none, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : achievements.isEmpty
                      ? const Center(
                    child: Text(
                      'Không có dữ liệu thành tựu',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : const AchievementCarousel(),
                  const SizedBox(height: 20),
                  const MenuCarousel(),
                  const SizedBox(height: 20),
                  const CourseCarousel(),
                  const SizedBox(height: 20),
                  const FavoriteTestsCarousel(),
                  const SizedBox(height: 20),
                  const RecentTestsCarousel(),
                  const SizedBox(height: 20),
                  const CollectionsCarousel(),
                  const SizedBox(height: 20),
                  const FeedbackCarousel(),
                  const SizedBox(height: 20),
                  // Tùy chỉnh Container với shadow và bo góc
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.pink[100]?.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Nội dung khác',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.green[100]?.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Nội dung khác',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Kênh',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        backgroundColor: Colors.white.withOpacity(0.9), // Nền mờ cho bottom bar
      ),
    );
  }
}