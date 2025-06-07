import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/account/login.dart';
import 'package:quizapp_fe/Page/admin/mangagerUser.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/Page/admin/MenuAdmin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class EditUserPage extends StatefulWidget {
  final String? username;
  const EditUserPage({Key? key, this.username}) : super(key: key);

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var accountApi = AccountApi();
  User? user;
  bool isLoading = false;
  String? _avatarUrl;
  String name = "Noname";
  String imageUrl = "unknown.png";
  String role = "user";

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    _loadUser();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? avatar = prefs.getString('avatar_path');
    print('Loaded admin username: $username, avatar: $avatar'); // Debug

    AccountApi accountApi = AccountApi();
    final data = await accountApi.checkUsername(username ?? "");
    setState(() {
      name = username ?? "Noname";
      imageUrl = avatar ?? "unknown.png";
      role = data.role ?? "user";
    });
  }

  Future<void> _loadUser() async {
    if (widget.username != null) {
      try {
        user = await accountApi.checkUsername(widget.username!);
        setState(() {
          _fullnameController.text = user?.fullName ?? '';
          _phoneController.text = user?.phone ?? '';
          _emailController.text = user?.email ?? '';
          _usernameController.text = user?.userName ?? '';
          _avatarUrl = user?.avatar;
        });
      } catch (e) {
        print("Error loading user: $e");
        ToastHelper.showError("Không thể tải thông tin người dùng");
      }
    } else {
      print("Username is null");
      ToastHelper.showError("Không tìm thấy thông tin người dùng");
    }
  }

  Future<void> _saveAvatar(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', path);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          status = await Permission.camera.request();
          if (!status.isGranted) {
            ToastHelper.showError("Quyền truy cập máy ảnh bị từ chối");
            return;
          }
        }
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        File avatarFile = File(pickedFile.path);
        if (user?.userName != null) {
          final result = await accountApi.uploadAvatar(user!.userName!, avatarFile);
          if (result.containsKey('avatarUrl')) {
            setState(() {
              _avatarUrl = result['avatarUrl'];
            });
            await _saveAvatar(result['avatarUrl']);
            ToastHelper.showSuccess("Cập nhật ảnh đại diện thành công");
          } else {
            ToastHelper.showError(result['error'] ?? "Lỗi khi tải ảnh lên");
          }
        } else {
          ToastHelper.showError("Không tìm thấy tên người dùng");
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ToastHelper.showError("Không thể chọn ảnh: $e");
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateAccount(int? id) async {
    if (_fullnameController.text.trim().length < 4) {
      ToastHelper.showError("Tên phải lớn hơn 4 ký tự");
      return;
    }
    if (_phoneController.text.trim().length < 9) {
      ToastHelper.showError("Số điện thoại phải lớn hơn 9 ký tự");
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(_phoneController.text.trim())) {
      ToastHelper.showError("Số điện thoại chỉ được chứa số");
      return;
    }

    if (id == null) {
      ToastHelper.showError("Không thể cập nhật: ID người dùng không hợp lệ");
      return;
    }

    User updatedUser = User(
      fullName: _fullnameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: user?.email,
      userName: user?.userName,
    );

    setState(() {
      isLoading = true;
    });

    try {
      User result = await accountApi.updateUser(id, updatedUser);
      setState(() {
        user = result;
        _fullnameController.text = result.fullName ?? '';
        _phoneController.text = result.phone ?? '';
        _emailController.text = result.email ?? '';
        _usernameController.text = result.userName ?? '';
      });

      ToastHelper.showSuccess("Cập nhật thông tin thành công");
    } catch (e) {
      print("updateAccount - Exception: $e");
      String errorMessage = "Lỗi khi cập nhật thông tin";
      if (e.toString().contains("FullName")) {
        errorMessage = "Tên không được để trống";
      } else if (e.toString().contains("Phone")) {
        errorMessage = "Số điện thoại không hợp lệ";
      }
      ToastHelper.showError(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
    // Điều hướng đến ProfilePage nếu cần
  }

  void _navigateToUserManagement() {
    Navigator.pop(context); // Đóng Drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UsersListPage()),
    );
  }

  void _navigateToQuizManagement() {
    Navigator.pop(context); // Đóng Drawer
    print('Điều hướng đến Quản lý đề thi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE1BEE7),
              Color(0xFFBBDEFB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
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
                    const Text(
                      'Chỉnh sửa người dùng',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _avatarUrl != null
                          ? NetworkImage('${BaseUrl.urlImage}$_avatarUrl')
                          : null,
                      child: _avatarUrl == null
                          ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.blueAccent,
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceSelection,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  label: 'Tên của bạn *',
                  controller: _fullnameController,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Số điện thoại',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Username',
                  controller: _usernameController,
                  readOnly: true,
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFF06292),
                        Color(0xFF42A5F5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => updateAccount(user?.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Cập nhật thông tin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? Colors.grey.shade200
                : Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: readOnly
                ? const Icon(Icons.lock, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }
}