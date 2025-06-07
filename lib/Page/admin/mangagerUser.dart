import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/account/login.dart';
import 'package:quizapp_fe/Page/admin/CourseManager.dart';
import 'package:quizapp_fe/Page/admin/addUser.dart';
import 'package:quizapp_fe/Page/admin/editUser.dart';
import 'package:quizapp_fe/Page/admin/mangagerUser.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/Page/admin/MenuAdmin.dart'; // Import SharedDrawer
import 'package:shared_preferences/shared_preferences.dart';

class UsersListPage extends StatefulWidget {
  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  List<User> users = []; // Danh sách người dùng từ API
  List<User> filteredUsers = []; // Danh sách người dùng sau khi lọc
  String name = "Noname";
  String imageUrl = "unknown.png";
  String role = "user";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadUsers(); // Load danh sách người dùng
    _searchController.addListener(_filterUsers); // Lắng nghe thay đổi trong ô tìm kiếm
  }

  @override
  void dispose() {
    _searchController.dispose(); // Giải phóng controller
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
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

  Future<void> _loadUsers() async {
    try {
      AccountApi accountApi = AccountApi();
      List<User> fetchedUsers = await accountApi.findAll();
      setState(() {
        users = fetchedUsers;
        filteredUsers = fetchedUsers; // Khởi tạo danh sách lọc
      });
    } catch (e) {
      print('Error loading users: $e');
      // Có thể hiển thị thông báo lỗi cho người dùng
    }
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        return user.userName?.toLowerCase().contains(query) ?? false;
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
            // Header section with menu icon
            Container(
              padding: EdgeInsets.all(20),
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
                            child: Icon(
                              Icons.menu,
                              size: 24,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi Admin!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Quản lý người dùng!',
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
                              'Tổng: ${filteredUsers.length}', // Hiển thị tổng số người dùng sau lọc
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${filteredUsers.length} người dùng', // Số người dùng cụ thể
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'June 2025',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Danh sách người dùng',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên người dùng...',
                      prefixIcon: Icon(Icons.search),
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

            // Users list section
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: filteredUsers.isEmpty && users.isNotEmpty
                    ? Center(child: Text('Không tìm thấy người dùng')) // Thông báo khi không có kết quả
                    : filteredUsers.isEmpty
                    ? Center(child: CircularProgressIndicator()) // Hiển thị loading nếu chưa có dữ liệu
                    : ListView.builder(
                  padding: EdgeInsets.all(15),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue[100],
                            ),
                            child: ClipOval(
                              child: filteredUsers[index].avatar != null &&
                                  filteredUsers[index].avatar!.isNotEmpty
                                  ? Image.network(
                                "${BaseUrl.urlImage}/${filteredUsers[index].avatar}",
                                fit: BoxFit.cover,
                                width: 45,
                                height: 45,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                  size: 25,
                                ),
                              )
                                  : Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 25,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),

                          // User info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filteredUsers[index].userName ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  filteredUsers[index].fullName ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  filteredUsers[index].role ?? 'N/A', // email
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    overflow: TextOverflow.visible, // Cho phép xuống hàng
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action buttons
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUserPage(
                                        username: filteredUsers[index].userName ?? '',
                                      ),
                                    ),
                                  );
                                  // Edit action
                                  print('Edit ${filteredUsers[index].userName}');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Delete action
                                  print('Delete ${filteredUsers[index].userName}');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUserPage()),
          );
          print('Add new user');
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}