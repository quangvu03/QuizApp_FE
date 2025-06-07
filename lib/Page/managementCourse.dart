import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/createExam/createExam.dart';
import 'package:quizapp_fe/Page/discoverCourse.dart';
import 'package:quizapp_fe/Page/exam/ListCourseByUser.dart';
import 'package:quizapp_fe/Page/favoriteCourse.dart';
import 'package:quizapp_fe/Page/infor.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/model/quiz_api.dart';
import 'package:quizapp_fe/model/take_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizapp_fe/Page/details/details.dart';

class managementCourse extends StatefulWidget {
  const managementCourse({super.key});

  @override
  _managementCoursePageState createState() => _managementCoursePageState();
}

class _managementCoursePageState extends State<managementCourse> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  final GlobalKey _thongTinKey = GlobalKey();
  final GlobalKey _quanLyKey = GlobalKey();
  final GlobalKey _deThiMoiNhatKey = GlobalKey();
  final GlobalKey _danhMucDeThiKey = GlobalKey();
  List<Map<String, dynamic>> dataCourse = [];

  String name = "Noname";
  String imageUrl = "unknownUser.png";
  int _numberQuiz = 0;
  int? countTakesByQuizCreator = 0;
  int? _idUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("AppLifecycleState: $state");
    if (state == AppLifecycleState.resumed && mounted) {
      print("Refreshing data on resume");
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    try {
      await _loadUser().then((_) => _fetchData());
      if (mounted) {
        print("Data refreshed successfully: $dataCourse");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi làm mới dữ liệu: $e')),
        );
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      QuizApiService quizApiService = QuizApiService();
      final courses = await quizApiService.fetchQuizzesByUsername(name);
      if (mounted) {
        setState(() {
          dataCourse = courses;
        });
      }
      print("dataCourse: $dataCourse");
    } catch (e) {
      if (mounted) {
        setState(() {
          dataCourse = [];
        });
      }
      print("Error fetching data: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero).dy;
      _scrollController.animateTo(
        position + _scrollController.offset - 100,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollTabToCenter(int index) {
    const double tabWidth = 120;
    final double offset = index * tabWidth -
        (MediaQuery.of(context).size.width / 2) +
        (tabWidth / 2);
    _tabScrollController.animateTo(
      offset.clamp(0, _tabScrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? avatar = prefs.getString('avatar_path');
    print('Loaded username: $username, avatar: $avatar');
    QuizApiService quizApiService = QuizApiService();
    AccountApi accountApi = AccountApi();
    TakeApi takeApi = TakeApi();
    User datausser = await accountApi.checkUsername(username!);

    final data = await quizApiService.findAllbyUserId(datausser.id!);
    final _countTakesByQuizCreator = await takeApi.countTakesByQuizCreator(datausser.id!);
    print("object: ${data.length}");
    if (mounted) {
      setState(() {
        _idUser = datausser.id;
        name = username ?? "Noname";
        imageUrl = avatar ?? "unknownUser.png";
        _numberQuiz = data.length;
        countTakesByQuizCreator = _countTakesByQuizCreator as int?;
      });
    }
  }

  void _onItemTapped(int index) async {
    if (index == 3) {
      setState(() {
        _selectedIndex = 3;
      });
      print("select: $_selectedIndex");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      ).then((_) {
        print("Popped back from ProfilePage");
        _refreshData();
      });
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
      ).then((_) {
        print("Popped back from DiscoverCourse");
        _refreshData();
      });
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 2) {
      setState(() {
        _selectedIndex = 1;
      });
      print("select: $_selectedIndex");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FavoriteCourses()),
      ).then((_) {
        print("Popped back from DiscoverCourse");
        _refreshData();
      });
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 0) {
      setState(() {
        _selectedIndex = 1;
      });
      print("select: $_selectedIndex");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      ).then((_) {
        print("Popped back from DiscoverCourse");
        _refreshData();
      });
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
      ).then((_) {
        print("Popped back from DiscoverCourse");
        _refreshData();
      });
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
      ).then((_) {
        print("Popped back from DiscoverCourse");
        _refreshData();
      });
      setState(() {
        _selectedIndex = 0;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
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
          child: Column(
            children: [
              _buildTopHeader(),
              _buildUserStatsRow(),
              _buildNavigationTabs(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          key: _thongTinKey,
                          child: _buildThongTinSection(),
                        ),
                        Container(
                          key: _quanLyKey,
                          child: _buildQuanLySection(),
                        ),
                        Container(
                          key: _deThiMoiNhatKey,
                          child: _buildDeThiMoiNhatSection(),
                        ),
                        Container(
                          key: _danhMucDeThiKey,
                          child: _buildDanhMucDeThiSection(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
        currentIndex: 3,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        backgroundColor: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: imageUrl != "unknownUser.png"
                ? ClipOval(
              child: Image.network(
                "${BaseUrl.urlImage}/$imageUrl",
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) => const Icon(
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
    );
  }

  Widget _buildUserStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.remove_red_eye, '4', 'Lượt xem'),
          _buildStatItem(Icons.check_circle_outline, '${countTakesByQuizCreator}', 'Lượt ôn thi'),
          _buildStatItem(Icons.article_outlined, '$_numberQuiz', 'Đề thi'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationTabs() {
    return Container(
      color: Colors.purple[50],
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildNavTab('Thông tin', _selectedTabIndex == 0, () {
                setState(() {
                  _selectedTabIndex = 0;
                });
                _scrollToSection(_thongTinKey);
                _scrollTabToCenter(0);
              }),
              const SizedBox(width: 8),
              _buildNavTab('Quản lý', _selectedTabIndex == 1, () {
                setState(() {
                  _selectedTabIndex = 1;
                });
                _scrollToSection(_quanLyKey);
                _scrollTabToCenter(1);
              }),
              const SizedBox(width: 8),
              _buildNavTab('Đề thi mới nhất', _selectedTabIndex == 2, () {
                setState(() {
                  _selectedTabIndex = 2;
                });
                _scrollToSection(_deThiMoiNhatKey);
                _scrollTabToCenter(2);
              }),
              const SizedBox(width: 8),
              _buildNavTab('Danh mục đề thi', _selectedTabIndex == 3, () {
                setState(() {
                  _selectedTabIndex = 3;
                });
                _scrollToSection(_danhMucDeThiKey);
                _scrollTabToCenter(3);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildThongTinSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.purple[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ví sử dụng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.7)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý lượt sử dụng của bạn:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildUsageItem(Icons.checklist, 'Lượt ôn thi'),
                    _buildUsageItem(Icons.create_outlined, 'Lượt tạo đề thi'),
                    _buildUsageItem(Icons.quiz_outlined, 'Lượt tạo câu hỏi'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuanLySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quản lý',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Row(
            children: [
              Expanded(
                  child: _buildActionCard(
                      Icons.edit, 'Chỉnh sửa thông tin', Colors.blue, () {
                    print("Chỉnh sửa thông tin");
                  })),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildActionCard(
                      Icons.grid_view, 'Quản lý danh mục', Colors.purple, () {
                    print("Quản lý danh mục");
                  })),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionCard(
              Icons.lightbulb_outline, 'Tạo đề thi', Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateExamScreen(_idUser))).then((_) {
              print("Popped back from CreateExamScreen");
              _refreshData();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildDeThiMoiNhatSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đề thi mới nhất',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          dataCourse.isEmpty
              ? const Center(
            child: Text(
              'Không có đề thi nào',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          )
              : Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dataCourse.length > 6 ? 6 : dataCourse.length,
                itemBuilder: (context, index) {
                  final course = dataCourse[index];
                  return InkWell(
                    onTap: () {
                      print("course['id']: ${course['id']}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizDetailPage(idquiz: course['id'], showOption: true),
                        ),
                      ).then((value) {
                        print("Popped back from QuizDetailPage with value: $value");
                        // Refresh nếu xóa đề thi thành công
                        if (value == true) {
                          _refreshData();
                        }
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: course['image'] != null && course['image'].isNotEmpty
                                  ? Image.network(
                                '${BaseUrl.urlImage}${course['image']}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course['title'] ?? 'No title',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${course['numberquiz'] ?? 0} câu',
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
                                          backgroundImage: course['imageUser'] != null &&
                                              course['imageUser'].isNotEmpty
                                              ? NetworkImage('${BaseUrl.urlImage}${course['imageUser']}')
                                              : null,
                                          backgroundColor: Colors.grey[200],
                                          child: course['imageUser'] == null || course['imageUser'].isEmpty
                                              ? const Icon(Icons.person, size: 12, color: Colors.grey)
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        course['userName'] ?? 'Unknown',
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
              if (dataCourse.isNotEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.white),
                  ),
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListCourseByUserScreen(Username: name, showOption: true),
                        ),
                      ).then((value) {
                        print("Popped back from ListCourseByUserScreen with value: $value");
                        // Refresh nếu xóa đề thi từ ListCourseByUserScreen
                        if (value == true) {
                          _refreshData();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.pink[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          Text(
                            'Xem thêm',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDanhMucDeThiSection() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Danh mục đề thi sẽ được hiển thị tại đây.',
          style: TextStyle(fontSize: 16, color: Colors.white70)),
    );
  }

  Widget _buildActionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}