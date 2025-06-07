import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/admin/mangagerUser.dart';
import 'package:quizapp_fe/helpers/Url.dart';

class SharedDrawer extends StatelessWidget {
  final String userName;
  final String imageUrl;
  final String role;
  final VoidCallback onLogout;
  final VoidCallback onNavigateToHome;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToUserManagement;
  final VoidCallback onNavigateToQuizManagement;

  const SharedDrawer({
    required this.userName,
    required this.imageUrl,
    required this.role,
    required this.onLogout,
    required this.onNavigateToHome,
    required this.onNavigateToProfile,
    required this.onNavigateToUserManagement,
    required this.onNavigateToQuizManagement,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        Icons.person,
                        size: 30,
                        color: Colors.blueAccent,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  role == "admin" ? 'Quản trị viên' : 'Học sinh/ sinh viên',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Trang chủ'),
            onTap: onNavigateToHome,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Cá nhân'),
            onTap: onNavigateToProfile,
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Quản lý người dùng'),
            onTap: onNavigateToUserManagement,
          ),
          ListTile(
            leading: Icon(Icons.quiz),
            title: Text('Quản lý đề thi'),
            onTap: onNavigateToQuizManagement,
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Đăng xuất'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}