import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'Page/wellcome.dart';

// ✅ Khai báo routeObserver ở ngoài để có thể dùng lại
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(
    const OKToast(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Wellcome(),
      debugShowCheckedModeBanner: false,

      // ✅ THÊM DÒNG NÀY để RouteAware hoạt động
      navigatorObservers: [routeObserver],
    );
  }
}
