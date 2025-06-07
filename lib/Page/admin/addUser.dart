import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/account/login.dart';
import 'package:quizapp_fe/Page/admin/mangagerUser.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/Page/admin/MenuAdmin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Validation states
  String? _fullNameError;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _phoneError;

  // Focus nodes
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  final AccountApi accountApi = AccountApi();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;
  String name = "Noname";
  String imageUrl = "unknown.png";
  String role = "user";

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();

    _fullNameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
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

  // Validation functions
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (value.length < 4) {
      return 'Họ tên phải có ít nhất 4 ký tự';
    }
    return null;
  }

  Future<void> _validateUsername(String value) async {
    if (value.isEmpty) {
      setState(() => _usernameError = 'Vui lòng nhập tên đăng nhập');
      return;
    }
    if (value.length < 6) {
      setState(() => _usernameError = 'Tên đăng nhập phải có ít nhất 6 ký tự');
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      setState(() => _usernameError = 'Chỉ chứa chữ cái, số và dấu gạch dưới');
      return;
    }

    setState(() => _usernameError = 'Đang kiểm tra...');
    try {
      await accountApi.checkUsername(value);
      setState(() => _usernameError = 'Username đã tồn tại');
    } catch (e) {
      if (e.toString().contains("Username not found")) {
        setState(() => _usernameError = null);
      } else {
        setState(() => _usernameError = 'Lỗi kiểm tra username: $e');
      }
    }
  }

  Future<void> _validateEmail(String value) async {
    if (value.isEmpty) {
      setState(() => _emailError = 'Vui lòng nhập email');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      setState(() => _emailError = 'Email không hợp lệ');
      return;
    }

    setState(() => _emailError = 'Đang kiểm tra...');
    try {
      final exists = await accountApi.checkEmail(value);
      setState(() => _emailError = exists ? 'Email đã được sử dụng' : null);
    } catch (e) {
      setState(() => _emailError = 'Lỗi kiểm tra email');
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (value.length < 9) {
      return 'Số điện thoại phải có ít nhất 9 ký tự';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Số điện thoại chỉ được chứa số';
    }
    return null;
  }

  Future<void> _submitForm() async {
    final fullNameValid = _validateFullName(_fullNameController.text) == null;
    final passwordValid = _validatePassword(_passwordController.text) == null;
    final phoneValid = _validatePhone(_phoneController.text) == null;

    if (!fullNameValid ||
        !passwordValid ||
        !phoneValid ||
        _usernameError != null ||
        _emailError != null) {
      setState(() {
        _fullNameError = _validateFullName(_fullNameController.text);
        _passwordError = _validatePassword(_passwordController.text);
        _phoneError = _validatePhone(_phoneController.text);
      });
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = User(
        fullName: _fullNameController.text,
        userName: _usernameController.text,
        email: _emailController.text,
        password: BCrypt.hashpw(_passwordController.text, BCrypt.gensalt()),
        phone: _phoneController.text,
        avatar: "unknown.png",
        id: null,
        status: true,
      );

      final success = await accountApi.create(user);
      if (success) {
        ToastHelper.showSuccess('Thêm tài khoản thành công');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UsersListPage()),
        );
      } else {
        ToastHelper.showError('Thêm tài khoản thất bại');
      }
    } catch (e) {
      ToastHelper.showError('Thêm tài khoản thất bại: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
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
            child: Form(
              key: _formKey,
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
                        'Thêm tài khoản mới',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    label: 'Họ và tên *',
                    controller: _fullNameController,
                    focusNode: _fullNameFocusNode,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      setState(() => _fullNameError = _validateFullName(value));
                    },
                    onEditingComplete: () => _usernameFocusNode.requestFocus(),
                    errorText: _fullNameError,
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Tên đăng nhập *',
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      _validateUsername(value);
                    },
                    onEditingComplete: () {
                      _emailFocusNode.requestFocus();
                      _validateUsername(_usernameController.text);
                    },
                    errorText: _usernameError,
                    prefixIcon: const Icon(Icons.label, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Email *',
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      _validateEmail(value);
                    },
                    onEditingComplete: () {
                      _passwordFocusNode.requestFocus();
                      _validateEmail(_emailController.text);
                    },
                    errorText: _emailError,
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Mật khẩu *',
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    textInputAction: TextInputAction.next,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() => _passwordError = _validatePassword(value));
                    },
                    onEditingComplete: () {
                      _phoneFocusNode.requestFocus();
                      setState(() => _passwordError = _validatePassword(_passwordController.text));
                    },
                    errorText: _passwordError,
                    prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Số điện thoại *',
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() => _phoneError = _validatePhone(value));
                    },
                    errorText: _phoneError,
                    prefixIcon: const Icon(Icons.phone, color: Colors.blue),
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
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Thêm tài khoản',
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? errorText,
    Widget? prefixIcon,
    void Function(String)? onChanged,
    void Function()? onEditingComplete,
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
          focusNode: focusNode,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: prefixIcon,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}