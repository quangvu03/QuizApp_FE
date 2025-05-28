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
import 'package:quizapp_fe/Page/managementCourse.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String name = "Noname";
  String imageUrl = "unknown.png";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _onItemTapped(int index) async {
    if (index == 4) {
      setState(() {
        _selectedIndex = 4;
      });
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
    } else if (index == 3) {
      setState(() {
        _selectedIndex = 3;
      });
      print("select: $_selectedIndex");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const managementCourse()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    }
    else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/bgrhome2.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white70,
              BlendMode.overlay,
            ),
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
                  const AchievementCarousel(),
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
        backgroundColor: Colors.white.withOpacity(0.9),
      ),
    );
  }
}