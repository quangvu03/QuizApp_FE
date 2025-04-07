import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';

import 'Page/wellcome.dart';

void main() {
  runApp(
    const OKToast(
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Wellcome(),
      debugShowCheckedModeBanner: false
      ,
    );
  }
}
