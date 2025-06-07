import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/details/details.dart';
import 'package:quizapp_fe/Page/exam/ListCourseByUser.dart';
import 'package:quizapp_fe/Page/favoriteCourse.dart';
import 'package:quizapp_fe/Page/infor.dart';
import 'package:quizapp_fe/Page/managementCourse.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/quiz_api.dart';

class DiscoverCourse extends StatefulWidget {
  const DiscoverCourse({super.key});

  @override
  _DiscoverCourseState createState() => _DiscoverCourseState();
}

class _DiscoverCourseState extends State<DiscoverCourse> {
  int _selectedIndex = 1;
  String _selectedCard = 'Đề thi';
  List<Map<String, dynamic>> dsde = [];
  List<Map<String, dynamic>> dsnguoitao = [];
  late QuizApiService quizApiService;
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _deThiController = TextEditingController();
  final TextEditingController _nguoiTaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    quizApiService = QuizApiService();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final quizzes = await quizApiService.fetchAllQuizz();
      final userQuizzes = await quizApiService.fetchAllQuizzesByUser();
      setState(() {
        dsde = quizzes;
        dsnguoitao = userQuizzes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
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
      setState(() => _selectedIndex = 1);
    } else if (index == 2) {
      setState(() => _selectedIndex = 2);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoriteCourses()),
      );
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
      setState(() => _selectedIndex = 1);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void search(String value, String selectedCard) async {
    final quizApiService = QuizApiService();

    if (selectedCard == 'Đề thi') {
      final data = await quizApiService.findQuizByname(value);
      setState(() {
        dsde = data;
      });
    } else {
      final data = await quizApiService.findByUserName(value);
      setState(() {
        dsnguoitao = data;
      });
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
                      'Khám phá',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Visibility(
                      visible: _selectedCard == 'Đề thi',
                      child: TextField(
                        controller: _deThiController,
                        onChanged: (value) => search(value, 'Đề thi'),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm đề thi...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _selectedCard != 'Đề thi',
                      child: TextField(
                        controller: _nguoiTaoController,
                        onChanged: (value) => search(value, 'Người tạo'),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm kênh đề thi...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.white),
                  ),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCard = 'Đề thi'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedCard == 'Đề thi'
                                  ? Colors.pink[300]
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.list, color: Colors.white, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Đề thi',
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCard = 'Kênh'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedCard == 'Kênh'
                                  ? Colors.pink[300]
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, color: Colors.white, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Kênh đề thi',
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
                    : _selectedCard == 'Đề thi'
                    ? dsde.isEmpty
                    ? const Center(
                  child: Text(
                    'Không tìm thấy đề',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dsde.length,
                  itemBuilder: (context, index) {
                    final test = dsde[index];
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
                                        fontWeight:
                                        FontWeight.bold,
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
                                            shape:
                                            BoxShape.circle,
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
                                          style:
                                          const TextStyle(
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
                )
                    : dsnguoitao.isEmpty
                    ? const Center(
                  child: Text(
                    'Không tìm thấy đề',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dsnguoitao.length,
                  itemBuilder: (context, index) {
                    final channel = dsnguoitao[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListCourseByUserScreen(Username: channel['username'],),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            children: [
                              const SizedBox(width: 1),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        channel['image'],
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Image.asset(
                                              'assets/images/home/imageHome.png',
                                              width: double.infinity,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundImage: NetworkImage(
                                              '${BaseUrl.urlImage}${channel['image']}',
                                            ),
                                            backgroundColor: Colors.grey[200],
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            channel['username'] ?? 'No username',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.book, size: 15),
                                          const SizedBox(width: 10),
                                          Text(
                                            '${channel['numberquiz'] ?? 0} đề',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
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