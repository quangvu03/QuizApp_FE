import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/account/forgot_password.dart';
import 'package:quizapp_fe/Page/account/register.dart';
import 'package:quizapp_fe/Page/wellcome.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/account_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  String? _usernamerr;
  String? _passworderr;

  final AccountApi account_api = AccountApi();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset(
                    "assets/images/home/imageHome2.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF4F7FA),
                        hintText: 'Username',
                        hintStyle: const TextStyle(
                          fontSize: 15,
                        ),
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _usernameFocusNode,
                      controller: username,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF4F7FA),
                        // mã màu #42A5F5
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          fontSize: 15,
                        ),
                        prefixIcon:
                            const Icon(Icons.lock, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      focusNode: _passwordFocusNode,
                      controller: password,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const RegisterPage(); // Trả về instance của RegisterPage
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              "Đăng ký",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.blue),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context)
                                => ForgotPasswordPage(),
                              ));
                            },
                            child: const Text(
                              "Quên mật khẩu",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.blue),
                            )),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _Login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4F7FA),
                          foregroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                            endIndent: 10, // khoảng cách với chữ
                          ),
                        ),

                        Text(
                          "Hoặc tiếp tục với",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold, // ✅ in đậm
                          ),
                        ),

                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                            indent: 10, // khoảng cách với chữ
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9FCBFA),
                            foregroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.google, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                "Google",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _Login() async {
    if (username.text.trim().length < 6) {
      _usernamerr = "Vui lòng nhập đúng username hay email";
      ToastHelper.showError(
        _usernamerr!,
        duration: const Duration(seconds: 2),
      );
    } else if (password.text.trim().length < 4) {
      _passworderr = "Mật khẩu phải trên 4 kí tự";
      ToastHelper.showError(
        _passworderr!,
        duration: const Duration(seconds: 2),
      );
    } else {
      try {
        User user = await account_api.Login(username.text.trim(), password.text.trim());
        ToastHelper.showInfo("Đăng nhập thành công");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', user.userName!);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('avatar_path', user.avatar!);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        if (e.toString().contains("Login failed")) {
          ToastHelper.showError("Tài khoản hoặc mật khẩu không đúng.");
        } else {
          ToastHelper.showError("Có lỗi xảy ra: $e");
        }
      }
    }
  }
}
