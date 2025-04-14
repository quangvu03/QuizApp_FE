import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/account/login.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  User? user;

  bool _isLoading = false;
  final accountApi = AccountApi();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

    if (username != null) {
      final result = await accountApi.checkUsername(username);
      if (result != null && result is User) {
        setState(() {
          user = result;
        });
      } else {
        ToastHelper.showError(
          'Không tìm thấy thông tin người dùng',
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      ToastHelper.showError(
        'Vui lòng đăng nhập lại',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (user == null) {
      ToastHelper.showError(
        'Không tìm thấy thông tin người dùng. Vui lòng thử lại.',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (user!.email == null) {
      ToastHelper.showError(
        'Thông tin email không hợp lệ. Vui lòng thử lại.',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final password = _passwordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ToastHelper.showError(
        'Vui lòng nhập đầy đủ mật khẩu',
        duration: const Duration(seconds: 2),
      );
    } else if (newPassword != confirmPassword) {
      ToastHelper.showError(
        'Mật khẩu mới và xác nhận mật khẩu không khớp',
        duration: const Duration(seconds: 2),
      );
    } else {
      try {
        final result = await accountApi.newPassword(
          user!.email!,
          password,
          newPassword,
        );
        if (result == "successfully") {
          ToastHelper.showSuccess(
            'Đặt lại mật khẩu thành công',
            duration: const Duration(seconds: 2),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          ToastHelper.showError(
            result, // Hiển thị lỗi từ backend
            duration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        ToastHelper.showError(
          'Đã xảy ra lỗi: $e',
          duration: const Duration(seconds: 2),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Đặt lại mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}