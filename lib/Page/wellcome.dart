import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/account/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wellcome extends StatefulWidget {
  const Wellcome({super.key});

  @override
  _WellcomeState createState() => _WellcomeState();
}

class _WellcomeState extends State<Wellcome> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late Future<String> initialRoute;

  @override
  void initState() {
    super.initState();
    initialRoute = _determineInitialRoute();
  }

  Future<String> _determineInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isFirstTime) {
      return 'welcome'; // Hiển thị onboarding
    } else if (!isLoggedIn) {
      return 'login'; // Chưa đăng nhập, về LoginScreen
    } else {
      return 'home'; // Đã đăng nhập, về HomeScreen
    }
  }

  void _goToLoginScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _goToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(),)
    );
  }

  Future<void> _markFirstTimeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false); // Đánh dấu không còn là lần đầu
  }

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Luyện thi mọi lúc',
      'desc': 'Làm bài trắc nghiệm ngay trên điện thoại mọi lúc, mọi nơi.',
      'image': 'assets/images/Wcimg1.png'
    },
    {
      'title': 'Theo dõi tiến độ',
      'desc': 'Xem lại kết quả, phân tích điểm mạnh/yếu của bạn.',
      'image': 'assets/images/Wcimg2.png'
    },
    {
      'title': 'Sẵn sàng cho kỳ thi',
      'desc': 'Tự tin chinh phục kỳ thi với kiến thức vững chắc!',
      'image': 'assets/images/Wcimg3.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: initialRoute,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          if (snapshot.data == 'login') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _goToLoginScreen();
            });
            return Container();
          } else if (snapshot.data == 'home') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _goToHomeScreen();
            });
            return Container();
          }
        }

        // Hiển thị Welcome (onboarding) nếu là first_time
        return Scaffold(
          body: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        onboardingData[index]['image']!,
                        height: 300,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        onboardingData[index]['title']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                        child: Text(
                          onboardingData[index]['desc']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Dot + Arrow Navigation
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currentPage == 1
                        ? IconButton(
                      onPressed: () {
                        _controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
                    )
                        : const SizedBox(width: 48),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    _currentPage < onboardingData.length - 1
                        ? IconButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    )
                        : const SizedBox(width: 48),
                  ],
                ),
              ),

              // Nút "Bắt đầu" ở trang cuối
              if (_currentPage == onboardingData.length - 1)
                Positioned(
                  bottom: 20,
                  left: 40,
                  right: 40,
                  child: TextButton(
                    onPressed: () async {
                      await _markFirstTimeCompleted();
                      _goToLoginScreen(); // Sau onboarding, đi đến LoginScreen
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Bắt đầu",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}