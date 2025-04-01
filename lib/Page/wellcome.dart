import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wellcome extends StatefulWidget {
  const Wellcome({super.key});

  @override
  _WellcomeState createState() => _WellcomeState();
}

class _WellcomeState extends State<Wellcome> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late Future<bool> firstOpen;

  @override
  void initState() {
    super.initState();
    firstOpen = _isFirstTime(); // Gọi async hàm kiểm tra lần đầu
  }

  Future<bool> _isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;
    if (isFirstTime) {
      await prefs.setBool('first_time', false);
    }
    return isFirstTime;
  }

  void _goHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: firstOpen,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Hiển thị loading khi đang chờ
        }

        if (snapshot.hasData && snapshot.data == false) {
          // Nếu không phải lần đầu, chuyển luôn tới HomeScreen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _goHomeScreen();
          });
          return Container(); // Không hiển thị gì trong khi đang chuyển hướng
        }

        // Nếu là lần đầu mở app, hiển thị Onboarding
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
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                        (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 20,
                child: TextButton(
                  onPressed: () async {
                    await saveFirstTimeTrue;  // Gọi hàm saveData() đúng cách
                    _goHomeScreen;   // Gọi hàm _goHomeScreen() đúng cách
                  },
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    "Bỏ qua",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
              if (_currentPage == onboardingData.length - 1)
                Positioned(
                  bottom: 20,
                  left: 40,
                  right: 40,
                  child: TextButton(
                    onPressed: () async {
                      await saveFirstTimeTrue();  // Gọi hàm saveData() đúng cách
                      _goHomeScreen();   // Gọi hàm _goHomeScreen() đúng cách
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Bắt đầu", style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveFirstTimeTrue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', true);
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
}
