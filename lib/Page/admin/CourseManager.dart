import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/account/login.dart';
import 'package:quizapp_fe/Page/admin/MenuAdmin.dart';
import 'package:quizapp_fe/Page/admin/mangagerUser.dart';
import 'package:quizapp_fe/Page/createExam/CreateExam.dart'; // Giả định import CreateExamScreen
import 'package:quizapp_fe/Page/details/details.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/model/quiz_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseManagementPage extends StatefulWidget {
  const CourseManagementPage({super.key});

  @override
  _CourseManagementPageState createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage> {
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> filteredCourses = [];
  String name = "Noname";
  String imageUrl = "unknown.png";
  String role = "user";
  int? _idUser; // Lưu idUser
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _searchController = TextEditingController();
  late QuizApiService quizApiService;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    quizApiService = QuizApiService();
    _loadUserInfo();
    _loadCourses();
    _searchController.addListener(_filterCourses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? avatar = prefs.getString('avatar_path');

    if (username != null) {
      try {
        AccountApi accountApi = AccountApi();
        final user = await accountApi.checkUsername(username);
        setState(() {
          name = username;
          imageUrl = avatar ?? "unknown.png";
          role = user.role ?? "admin";
          _idUser = user.id; // Lấy idUser từ User
        });
      } catch (e) {
        setState(() {
          name = username ?? "Noname";
          imageUrl = avatar ?? "unknown.png";
          role = "admin";
          _idUser = null;
          errorMessage = 'Lỗi khi tải thông tin người dùng: $e';
        });
      }
    } else {
      setState(() {
        name = "Noname";
        imageUrl = avatar ?? "unknown.png";
        role = "admin";
        _idUser = null;
      });
    }
  }

  Future<void> _loadCourses() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final quizzes = await quizApiService.fetchAllQuizz();
      setState(() {
        courses = quizzes;
        filteredCourses = quizzes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải danh sách khóa học: $e';
        isLoading = false;
      });
    }
  }

  void _filterCourses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredCourses = courses.where((course) {
        return course['title']?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('isLoggedIn');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.pop(context);
  }

  void _navigateToUserManagement() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UsersListPage()),
    );
  }

  void _navigateToQuizManagement() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseManagementPage()),
    );
  }

  void _showDeleteConfirmationDialog(int quizId, String courseTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa khóa học "$courseTitle" không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                try {
                  String result = await quizApiService.deleteQuiz(quizId);
                  if (mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                    if (result == 'success') {
                      ToastHelper.showSuccess("Đã xóa khóa học thành công");
                      await _loadCourses();
                    } else {
                      _scaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(content: Text(result)),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Có', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: SharedDrawer(
          userName: name,
          imageUrl: imageUrl,
          role: role,
          onLogout: () async {
            Navigator.pop(context);
            await _logout();
          },
          onNavigateToHome: _navigateToHome,
          onNavigateToProfile: _navigateToProfile,
          onNavigateToUserManagement: _navigateToUserManagement,
          onNavigateToQuizManagement: _navigateToQuizManagement,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: const Icon(
                                Icons.menu,
                                size: 24,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hi Admin!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quản lý khóa học!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tổng: ${filteredCourses.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '${filteredCourses.length} khóa học',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Text(
                                'June 2025',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Danh sách khóa học',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên khóa học...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: RefreshIndicator(
                    onRefresh: _loadCourses,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : errorMessage.isNotEmpty
                        ? Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                        : filteredCourses.isEmpty
                        ? const Center(child: Text('Không tìm thấy khóa học'))
                        : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: course['image'] != null &&
                                    course['image'].isNotEmpty
                                    ? Image.network(
                                  '${BaseUrl.urlImage}${course['image']}',
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        'assets/images/quiz/title.png',
                                        width: 45,
                                        height: 45,
                                        fit: BoxFit.cover,
                                      ),
                                )
                                    : Image.asset(
                                  'assets/images/quiz/title.png',
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course['title'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${course['numberquiz'] ?? 0} câu hỏi',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tạo bởi: ${course['userName'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => QuizDetailPage(
                                            idquiz: course['id'],
                                            showOption: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      _showDeleteConfirmationDialog(
                                        course['id'],
                                        course['title'] ?? 'Unknown',
                                      );
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_idUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateExamScreen(_idUser!)),
              ).then((_) {
                print("Popped back from CreateExamScreen");
                _loadCourses();
              });
            } else {
              ToastHelper.showError("Không thể tạo đề thi: Thông tin người dùng không hợp lệ");
            }
          },
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}