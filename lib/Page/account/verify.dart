import 'package:flutter/material.dart';

class VerifyPage extends StatefulWidget {
  final String? username;

  const VerifyPage({super.key, this.username});

  @override
  _VerifyPageState createState() => _VerifyPageState();
}


class _VerifyPageState extends State<VerifyPage> {
  // Xóa controllers và focusNodes
  String verificationCode = '';

  @override
  void initState() {
    super.initState();
    print(widget.username!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _submitCode() async {
    // Handle verification code submission
    print("Verification code: $verificationCode");
    // Giả lập mã code để kiểm tra
    String correctCode = "123456"; // Ví dụ mã xác thực
    if (verificationCode == correctCode) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thành Công'),
            content: Text('Xác thực tài khoản thành công, mời đăng nhập!'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thất bại'),
            content: Text('Sai mã xác thực'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      print("code sai");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Account'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Enter the 6-digit code sent to your account",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Giả lập phần nhập mã
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    child: TextField(
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          verificationCode = value;
                        });
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitCode,
                child: Text("Verify"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
