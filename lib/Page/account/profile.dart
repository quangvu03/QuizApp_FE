import 'package:flutter/material.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  var accountApi = AccountApi();
  TextEditingController FullnameController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController usernameController = TextEditingController(text: "");
  User? user;
  bool isLoading = false;

  @override
  void dispose() {
    FullnameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      try {
        user = await accountApi.checkUsername(username);
        setState(() {
          FullnameController.text = user?.fullName ?? '';
          phoneController.text = user?.phone ?? '';
          emailController.text = user?.email ?? '';
          usernameController.text = user?.userName ?? '';
        });
      } catch (e) {
        print("Error loading user: $e");
        ToastHelper.showError("Không thể tải thông tin người dùng");
      }
    } else {
      print("usernull");
      ToastHelper.showError("Vui lòng đăng nhập lại");
    }
  }

  Future<void> updateAccount(int? id) async {
    // Validation
    if (FullnameController.text.trim().length < 4) {
      ToastHelper.showError("Tên phải lớn hơn 4 ký tự");
      return;
    }
    if (phoneController.text.trim().length < 9) {
      ToastHelper.showError("Số điện thoại phải lớn hơn 9 ký tự");
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(phoneController.text.trim())) {
      ToastHelper.showError("Số điện thoại chỉ được chứa số");
      return;
    }

    if (id == null) {
      ToastHelper.showError("Không thể cập nhật: ID người dùng không hợp lệ");
      return;
    }

    // Tạo User mới từ TextEditingController
    User updatedUser = User(
      fullName: FullnameController.text.trim(),
      phone: phoneController.text.trim(),
      email: user?.email, // Giữ nguyên vì readOnly
      userName: user?.userName, // Giữ nguyên vì readOnly
    );

    setState(() {
      isLoading = true;
    });

    try {
      // Gọi API để cập nhật
      User result = await accountApi.updateUser(id, updatedUser);

      // Cập nhật user và UI
      setState(() {
        user = result;
        FullnameController.text = result.fullName ?? '';
        phoneController.text = result.phone ?? '';
        emailController.text = result.email ?? '';
        usernameController.text = result.userName ?? '';
      });

      // Cập nhật SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (result.userName != null) {
        await prefs.setString('username', result.userName!);
      }

      // Hiển thị thông báo thành công
      ToastHelper.showSuccess("Cập nhật thông tin thành công");
    } catch (e) {
      print("updateAccount - Exception: $e");
      // Dịch lỗi thành thông báo thân thiện
      String errorMessage = "Lỗi khi cập nhật thông tin";
      if (e.toString().contains("FullName")) {
        errorMessage = "Tên không được để trống";
      } else if (e.toString().contains("Phone")) {
        errorMessage = "Số điện thoại không hợp lệ";
      }
      ToastHelper.showError(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE1BEE7),
              Color(0xFFBBDEFB),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildTextField(
                label: 'Tên của bạn *',
                controller: FullnameController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Số điện thoại',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Username',
                controller: usernameController,
                readOnly: true,
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFF06292),
                      Color(0xFF42A5F5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => updateAccount(user?.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Chỉnh sửa thông tin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? Colors.grey.shade200
                : Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: readOnly
                ? const Icon(Icons.lock, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }
}