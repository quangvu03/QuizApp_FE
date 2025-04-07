import 'dart:math';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String? _otp;
  DateTime? _otpExpiration;
  bool _isLoading = false;

  void _sendOTP() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập email')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Giả lập tạo OTP (thay vì gọi API)
    final random = Random();
    _otp = '';
    for (int i = 0; i < 6; i++) {
      _otp = _otp! + random.nextInt(10).toString();
    }
    _otpExpiration = DateTime.now().add(Duration(seconds: 30));

    // Giả lập gửi email (hiển thị OTP trong console để test)
    print('OTP đã gửi đến $email: $_otp');

    setState(() {
      _isLoading = false;
    });

    _showOTPDialog();
  }

  void _showOTPDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nhập OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mã OTP đã được gửi đến email của bạn.'),
              Text('(Kiểm tra console/log để xem OTP)'), // Hướng dẫn debug
              SizedBox(height: 10),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'OTP'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: _verifyOTP,
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _verifyOTP() {
    final enteredOTP = _otpController.text;

    if (_otp == null || _otpExpiration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP không hợp lệ')),
      );
      return;
    }

    if (DateTime.now().isAfter(_otpExpiration!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP đã hết hạn')),
      );
      return;
    }

    if (enteredOTP == _otp) {
      Navigator.pop(context); // Đóng dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xác thực thành công!')),
      );
      // Điều hướng đến trang đặt lại mật khẩu ở đây nếu cần
      // Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP không chính xác')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quên mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _sendOTP,
              child: Text('Gửi OTP'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}