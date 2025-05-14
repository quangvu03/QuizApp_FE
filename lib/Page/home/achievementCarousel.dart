import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/model/take_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementCarousel extends StatefulWidget {
  const AchievementCarousel({super.key});

  @override
  _AchievementCarouselState createState() => _AchievementCarouselState();
}

class _AchievementCarouselState extends State<AchievementCarousel> {
  var takeApi;
  int _currentPage = 0;
  final _pageController = PageController(initialPage: 0);
  late Timer _timer;
  Map<String, dynamic>? dataAchievement;
  User? _user;
  AccountApi? accountApi;

  @override
  void initState() {
    super.initState();
    takeApi = TakeApi();
    // Delay timer setup until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) return; // Ensure the widget is still mounted
        if (_pageController.hasClients) { // Check if controller is attached
          if (_currentPage < 2) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });
    _loadUserAndFetchData();
  }

  Future<void> _loadUserAndFetchData() async {
    await _loadUser();
    if (_user != null) {
      await fetchdataAchivement(_user!.id);
    }
  }

  Future<void> fetchdataAchivement(var userId) async {
    if (userId == null) {
      ToastHelper.showError("Không thể tải thành tựu: User ID không hợp lệ");
      return;
    }
    try {
      final data = await takeApi.getAchievement(userId);
      if (data != null) {
        setState(() {
          dataAchievement = data;
        });
      } else {
        ToastHelper.showError("Không có dữ liệu thành tựu");
      }
    } catch (e) {
      print("Error fetching achievement: $e");
      ToastHelper.showError("Không thể tải thành tựu");
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      try {
        accountApi = AccountApi();
        User? user = await accountApi?.checkUsername(username);
        setState(() {
          _user = user;
        });
      } catch (e) {
        print("Error loading user: $e");
        ToastHelper.showError("Không thể tải thông tin người dùng");
      }
    } else {
      print("usernull");
      ToastHelper.showError("Vui lòng đăng nhập lại");
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null || dataAchievement == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Map<String, dynamic>> achievements = [
      {
        'title': 'Thành tựu trong tháng (Thử thách)',
        'averageLabel': 'Điểm trung bình',
        'averageScore': dataAchievement != null ? '${dataAchievement!["avgScore"]}' : '0.0',
        'totalScore': dataAchievement != null ? '${dataAchievement!["totalScore"]}' : '0',
        'icon': Icons.emoji_events,
        'iconColor': Colors.yellow,
        'backgroundImage': 'assets/images/home/bgr1.jpg',
      },
      {
        'title': 'Thành tựu tuần này',
        'averageLabel': 'Thời gian làm bài',
        'averageScore': dataAchievement != null ? '${dataAchievement!["avgtime"]}' : '0',
        'totalScore': '15',
        'icon': Icons.timer,
        'iconColor': Colors.orange,
        'backgroundImage': 'assets/images/home/bgr1.jpg',
      },
      {
        'title': 'Thành tựu năm nay',
        'averageLabel': 'Số bài đã làm',
        'averageScore': dataAchievement != null ? '${dataAchievement!["totalTake"]}' : '0',
        'totalScore': '120',
        'icon': Icons.school,
        'iconColor': Colors.blue,
        'backgroundImage': 'assets/images/home/bgr1.jpg',
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: achievements.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width - 32,
                margin: const EdgeInsets.only(right: 8),
                child: _buildAchievementSection(
                  title: achievements[index]['title'],
                  averageLabel: achievements[index]['averageLabel'],
                  averageScore: achievements[index]['averageScore'],
                  totalScore: achievements[index]['totalScore'],
                  icon: achievements[index]['icon'],
                  iconColor: achievements[index]['iconColor'],
                  backgroundImage: achievements[index]['backgroundImage'],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            achievements.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
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

  Widget _buildAchievementSection({
    required String title,
    required String averageLabel,
    required String averageScore,
    required String totalScore,
    required IconData icon,
    required Color iconColor,
    required String backgroundImage,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.7),
            BlendMode.srcOver,
          ),
        ),
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}