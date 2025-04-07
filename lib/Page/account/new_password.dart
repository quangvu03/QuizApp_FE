import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/account/login.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/model/account_api.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;

  NewPasswordPage({super.key, required this.email});

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  var accountApi = AccountApi();

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ToastHelper.showError(
        'Vui lòng nhập mật khẩu và xác nhận mật khẩu',
        duration: const Duration(seconds: 2),
      );
    } else if (password != confirmPassword) {
      ToastHelper.showError(
        'Mật khẩu không khớp',
        duration: const Duration(seconds: 2),
      );
    } else {
      var result = await accountApi.ChangePassword(
          widget.email, BCrypt.hashpw(password, BCrypt.gensalt()));
      if (result == "successfully") {
        ToastHelper.showSuccess(
          "Đặt lại mật khẩu thành công",
          duration: const Duration(seconds: 2),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
      } else {
        ToastHelper.showError(
          'Lỗi + $result',
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
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu',
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
