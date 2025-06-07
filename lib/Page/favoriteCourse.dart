import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/discoverCourse.dart';
import 'package:quizapp_fe/Page/details/details.dart';
import 'package:quizapp_fe/Page/infor.dart';
import 'package:quizapp_fe/Page/managementCourse.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/model/favorite_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCourses extends StatefulWidget {
  const FavoriteCourses({super.key});

  @override
  _FavoriteCoursesState createState() => _FavoriteCoursesState();
}

class _FavoriteCoursesState extends State<FavoriteCourses> {
  int _selectedIndex = 2; // Tab "Yêu thích" được chọn
  List<Map<String, dynamic>> dsfavorite = [];
  late FavoriteApi favoriteApi;
  int? _userId;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    favoriteApi = FavoriteApi();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      try {
        AccountApi accountApi = AccountApi();
        final user = await accountApi.checkUsername(username);
        setState(() {
          _userId = user.id;
        });
        _fetchFavorites();
      } catch (e) {
        setState(() {
          errorMessage = 'Lỗi khi tải thông tin người dùng: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Vui lòng đăng nhập để xem danh sách yêu thích';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFavorites() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final favorites = _userId != null ? await favoriteApi.getFavoritesByUserId(_userId!) : <Map<String, dynamic>>[];
      setState(() {
        dsfavorite = favorites != null
            ? favorites.map((item) => Map<String, dynamic>.from(item)).toList()
            : <Map<String, dynamic>>[];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải danh sách yêu thích: $e';
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) async {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      setState(() => _selectedIndex = 2);
    } else if (index == 1) {
      setState(() => _selectedIndex = 1);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DiscoverCourse()),
      );
      setState(() => _selectedIndex = 2);
    } else if (index == 3) {
      setState(() => _selectedIndex = 3);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const managementCourse()),
      );
    } else if (index == 4) {
      setState(() => _selectedIndex = 4);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
      setState(() => _selectedIndex = 2);
    } else {
      setState(() => _selectedIndex = index);
    }
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
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Yêu thích',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black54,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
                    : dsfavorite.isEmpty
                    ? const Center(
                  child: Text(
                    'Không tìm thấy khóa học yêu thích',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dsfavorite.length,
                  itemBuilder: (context, index) {
                    final test = dsfavorite[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizDetailPage(idquiz: test['id']),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                BorderRadius.circular(8),
                                child: test['image'] != null &&
                                    test['image'].isNotEmpty
                                    ? Image.network(
                                  '${BaseUrl.urlImage}${test['image']}',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context,
                                      error,
                                      stackTrace) =>
                                      Image.asset(
                                        'assets/images/quiz/title.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                )
                                    : Image.asset(
                                  'assets/images/quiz/title.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      test['title'] ?? 'No title',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${test['numberquiz'] ?? 0} câu',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.blue,
                                              width: 2,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundImage:
                                            NetworkImage(
                                              '${BaseUrl.urlImage}${test['imageUser']}',
                                            ),
                                            backgroundColor:
                                            Colors.grey[200],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          test['userName'] ??
                                              'Unknown',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
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