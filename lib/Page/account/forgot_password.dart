import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/account/new_password.dart';
import 'package:quizapp_fe/helpers/MailHeper.dart';
import 'package:quizapp_fe/helpers/Randomcode.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/model/account_api.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String? _otp;
  bool _isLoading = false;
  var accountapi = AccountApi();


  @override
  void initState() {
    _otp = generateSixDigitCode();
  }

  void _showOTPDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Phần header với icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user,
                    size: 36,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Xác thực OTP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng nhập mã OTP 6 số đã gửi đến email của bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _otpController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 4, // Giãn cách các số cho đẹp
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      hintText: '------',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nút xác nhận
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Hủy',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _verifyOTP,
                        child: const Text('Xác nhận'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verifyOTP() {
    final enteredOTP = _otpController.text;

    if (enteredOTP == _otp) {
      Navigator.pop(context);
      ToastHelper.showSuccess(
        "Xác thực thành công",
        duration: const Duration(seconds: 2),
      );
      // Điều hướng đến trang đặt lại mật khẩu ở đây nếu cần
      Navigator.push(context,
        MaterialPageRoute(builder: (context) =>
          NewPasswordPage( email: _emailController.text.trim()),
      ),
      );
    } else {
      ToastHelper.showError(
        "OTP không chính xác",
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Độ dày của đường gạch
          child: Divider(
            height: 1, // Chiều cao của Divider
            thickness: 1, // Độ dày đường gạch
            color: Colors.grey[300], // Màu đường gạch
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _sendOTP,
              child: const Text('Gửi OTP'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ToastHelper.showError("Vui lòng nhập email");
    } else if (await accountapi.checkEmail(email) == false) {
      ToastHelper.showError("Tài khoản không tồn tại");
    } else {
      setState(() {
        _isLoading = true;
      });
      final otpSent = await sendOTP(_otp, _emailController.text, ".....");

      if (!otpSent) {
        throw Exception('Gửi OTP thất bại');
      } else {
        ToastHelper.showSuccess("Email được gửi thành công");
        setState(() {
          _isLoading = false;
        });
        _showOTPDialog();
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }


}

Future<bool> sendOTP(var code, String email, String username) async {
  try {
    final otpHelper = EmailOTPHelper.gmail(
      username: 'vutran08012k3@gmail.com',
      password: 'qqzk lfom xowt efsq', // Dùng App Password nếu bật 2FA
      senderName: 'Verify quiz app',
    );

    final otpCode = code.toString(); // Tạo mã OTP ngẫu nhiên trong thực tế
    final emailNhan = email;
    final tennguoiDung = username;

    final success = await otpHelper.sendOTPEmail(
      recipientEmail: emailNhan,
      recipientName: tennguoiDung,
      otpCode: otpCode,
      otpExpiryMinutes: 5,
    );

    return success; // Trả về true/false
  } catch (e) {
    debugPrint('Error sending OTP: $e');
    return false; // Trả về false nếu có lỗi
  }
}
