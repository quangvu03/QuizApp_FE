import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/account/verify.dart';
import '../../entities/user.dart';
import '../../helpers/MailHeper.dart';
import '../../helpers/Randomcode.dart';
import '../../model/account_api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

  final AccountApi account_api = AccountApi();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text("Đăng kí"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 100,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Full Name TextField
                  TextFormField(
                    controller: _fullNameController,
                    focusNode: _fullNameFocusNode,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      setState(() => _fullNameError = _validateFullName(value));
                    },
                    onEditingComplete: () => _usernameFocusNode.requestFocus(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Full Name',
                      errorText: _fullNameError,
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: _validateFullName,
                  ),
                  const SizedBox(height: 10),

                  // Username TextField
                  TextFormField(
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
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Username',
                      errorText: _usernameError,
                      prefixIcon: const Icon(Icons.label, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Email TextField
                  TextFormField(
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
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Email',
                      errorText: _emailError,
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Password TextField
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    textInputAction: TextInputAction.next,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() => _passwordError = _validatePassword(value));
                    },
                    onEditingComplete: () {
                      _phoneFocusNode.requestFocus();
                      setState(() => _passwordError =
                          _validatePassword(_passwordController.text));
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Password',
                      errorText: _passwordError,
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 10),

                  // Phone TextField
                  TextFormField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() => _phoneError = _validatePhone(value));
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Phone',
                      errorText: _phoneError,
                      prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Login Link
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
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

  // VALIDATION FUNCTIONS

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

    // Async check
    setState(() => _usernameError = 'Đang kiểm tra...');
    try {
      await account_api.checkUsername(value); // Không cần gán vào biến user nếu không sử dụng
      setState(() => _usernameError = 'Username đã tồn tại');
    } catch (e) {
      if (e.toString().contains("Username not found")) {
        setState(() => _usernameError = null); // Username không tồn tại, hợp lệ
      } else {
        setState(() => _usernameError = 'Lỗi kiểm tra username: $e');
      }
    }
  }

  Future<void> _validateEmail(String value) async {
    // Basic validation
    if (value.isEmpty) {
      setState(() => _emailError = 'Vui lòng nhập email');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      setState(() => _emailError = 'Email không hợp lệ');
      return;
    }

    // Async check
    setState(() => _emailError = 'Đang kiểm tra...');
    try {
      final exists = await account_api.checkEmail(value);
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
      setState(() => _isSubmitting = true);

      // Tạo user và OTP
      final code = generateSixDigitCode();
      final user = User(
          fullName: _fullNameController.text,
          userName: _usernameController.text,
          email: _emailController.text,
          password: BCrypt.hashpw(_passwordController.text, BCrypt.gensalt()),
          phone: _phoneController.text,
          avatar: "unknown.png",
          id: null,
          status: true);

      // Gửi OTP và đợi hoàn thành
      final otpSent = await sendOTP(code, _emailController.text, _usernameController.text);

      if (!otpSent) {
        throw Exception('Gửi OTP thất bại');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyPage(
            user: user,
            verificationCode: code,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng ký thất bại: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
      debugPrint('Lỗi đăng ký: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
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
