import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizapp_fe/Page/discoverCourse.dart';
import 'package:quizapp_fe/Page/favoriteCourse.dart';
import 'package:quizapp_fe/Page/home/AchievementCarousel.dart';
import 'package:quizapp_fe/Page/home/Feeback.dart';
import 'package:quizapp_fe/Page/home/favoritetestCourse.dart';
import 'package:quizapp_fe/Page/home/menuCarousel.dart';
import 'package:quizapp_fe/Page/infor.dart';
import 'package:quizapp_fe/Page/managementCourse.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
    } else if (index == 2) {
      setState(() {
        _selectedIndex = 2;
      });
      print("select: $_selectedIndex");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FavoriteCourses()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    }
    else if (index == 3) {
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
      isLoading = false;
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
                            "${BaseUrl.urlImage}$imageUrl",
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
                  const NewsCarousel(),
                  const SizedBox(height: 20),
                  const FavoriteTestsCarousel(),
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

class NewsCarousel extends StatefulWidget {
  const NewsCarousel({super.key});

  @override
  _NewsCarouselState createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<NewsCarousel> {
  List<Map<String, dynamic>> newsItems = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http
          .get(Uri.parse('${BaseUrl.url}/account/vnexpress'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data.isEmpty) {
          throw Exception('Danh sách tin tức rỗng');
        }
        setState(() {
          newsItems = data.cast<Map<String, dynamic>>().take(5).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Lỗi khi tải tin tức: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Không thể tải tin tức: $e';
        print('Fetch error: $e');
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link bài báo không hợp lệ')),
        );
      }
      return;
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở bài báo: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tin tức THPT Quốc gia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        )
            : SizedBox(
          height: 200,
          child: newsItems.isEmpty
              ? const Center(
            child: Text(
              'Không có tin tức',
              style: TextStyle(color: Colors.white),
            ),
          )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              final news = newsItems[index];
              return GestureDetector(
                onTap: () => _launchUrl(news['url'] ?? ''),
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: news['image'] != null &&
                            news['image'].isNotEmpty
                            ? Image.network(
                          news['image'],
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error,
                              stackTrace) =>
                              Image.asset(
                                'assets/images/quiz/title.png',
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        )
                            : Image.asset(
                          'assets/images/quiz/title.png',
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   news['title'] ??
                            //       'Không có tiêu đề',
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: const TextStyle(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            const SizedBox(height: 4),
                            Text(
                              news['description'] ??
                                  'Không có mô tả',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}