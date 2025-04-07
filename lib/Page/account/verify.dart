import 'package:flutter/material.dart';
import 'package:quizapp_fe/entities/user.dart';
import '../../model/account_api.dart';
import 'login.dart';

class VerifyPage extends StatefulWidget {
  final User user;
  final String verificationCode;

  const VerifyPage({
    super.key,
    required this.user,
    required this.verificationCode,
  });

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;
  String verificationCode = '';
  final AccountApi userAPI = AccountApi();

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(6, (_) => FocusNode());
    _controllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {
      verificationCode = _controllers.map((c) => c.text).join();
    });
  }

  Future<void> _submitCode() async {
    if (verificationCode != widget.verificationCode) {
      _showErrorDialog('Mã xác thực không chính xác');
      return;
    }

    try {
      final success = await userAPI.create(widget.user);
      print(widget.user);
      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Tạo tài khoản thất bại');
      }
    } catch (e) {
      _showErrorDialog('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Thành công'),
        content: const Text('Xác thực thành công! Bạn có thể đăng nhập ngay bây giờ.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực tài khoản'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Nhập mã xác thực 6 chữ số đã gửi đến bạn',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) => _onChanged(value, index),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Xác thực',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}