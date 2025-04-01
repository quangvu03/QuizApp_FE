import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chính')),
      body: Center(child: ElevatedButton(
        onPressed: () async {
          await resetFirstTime();
          print('Đã reset, bạn có thể restart app để test onboarding lại');
        },
        child: const Text("Reset first_time"),
      ),
      ),
    );
  }

  Future<void> resetFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('first_time');
    print('✅ Đã xóa key "first_time"');
  }

}