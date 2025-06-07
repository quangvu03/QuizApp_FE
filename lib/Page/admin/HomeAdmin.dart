import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/account/login.dart';
import 'package:quizapp_fe/Page/admin/CourseManager.dart';
import 'package:quizapp_fe/Page/admin/mangagerUser.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/Page/admin/MenuAdmin.dart'; // Import SharedDrawer
import 'package:shared_preferences/shared_preferences.dart';

class AdminQuizHomePage extends StatefulWidget {
  final String? userName; // Nhận userName từ ProfilePage

  AdminQuizHomePage({this.userName});

  @override
  _AdminQuizHomePageState createState() => _AdminQuizHomePageState();
}

class _AdminQuizHomePageState extends State<AdminQuizHomePage> {
  String name = "Noname";
  String imageUrl = "unknown.png";
  String role = "user";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = widget.userName ?? prefs.getString('username');
    String? avatar = prefs.getString('avatar_path');
    print('Loaded username: $username, avatar: $avatar'); // Debug

    AccountApi accountApi = AccountApi();
    final data = await accountApi.checkUsername(username ?? "");
    setState(() {
      name = username ?? "Noname";
      imageUrl = avatar ?? "unknown.png";
      role = data.role ?? "user";
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
    Navigator.pop(context); // Đóng Drawer
    // Đã ở ProfilePage, không cần điều hướng lại
  }

  void _navigateToUserManagement() {
    Navigator.pop(context); // Đóng Drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UsersListPage()),
    );
  }

  void _navigateToQuizManagement() {
    Navigator.pop(context); // Đóng Drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseManagementPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: SharedDrawer(
        userName: name,
        imageUrl: imageUrl,
        role: role,
        onLogout: () async {
          Navigator.pop(context); // Đóng Drawer
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
            // Header with hamburger menu
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer(); // Mở Drawer bên trái
                    },
                    child: Icon(
                      Icons.menu,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Well Come ${name} to Admin\nQuiz App',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Icon(
                      Icons.celebration,
                      size: 48,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}