import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';

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
  String? _avatarUrl; // Lưu URL hoặc tên file ảnh từ SharedPreferences

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
    _loadAvatar();
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

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    String? avatarPath = prefs.getString('avatar_path');
    if (avatarPath != null && avatarPath.isNotEmpty) {
      setState(() {
        _avatarUrl = avatarPath; // Lưu tên file hoặc URL
      });
    }
  }

  Future<void> _saveAvatar(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', path);
  }

  // Hàm chọn ảnh từ thư viện hoặc camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          status = await Permission.camera.request();
          if (!status.isGranted) {
            ToastHelper.showError("Quyền truy cập máy ảnh bị từ chối");
            return;
          }
        }
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        File avatarFile = File(pickedFile.path);
        // Upload ảnh lên server
        if (user?.userName != null) {
          final result = await accountApi.uploadAvatar(user!.userName!, avatarFile);
          if (result.containsKey('avatarUrl')) {
            setState(() {
              _avatarUrl = result['avatarUrl']; // Cập nhật URL ảnh
            });
            await _saveAvatar(result['avatarUrl']); // Lưu vào SharedPreferences
            ToastHelper.showSuccess("Cập nhật ảnh đại diện thành công");
          } else {
            ToastHelper.showError(result['error'] ?? "Lỗi khi tải ảnh lên");
          }
        } else {
          ToastHelper.showError("Không tìm thấy tên người dùng");
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ToastHelper.showError("Không thể chọn ảnh: $e");
    }
  }

  // Hàm hiển thị bottom sheet để chọn nguồn ảnh
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateAccount(int? id) async {
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

    User updatedUser = User(
      fullName: FullnameController.text.trim(),
      phone: phoneController.text.trim(),
      email: user?.email,
      userName: user?.userName,
    );

    setState(() {
      isLoading = true;
    });

    try {
      User result = await accountApi.updateUser(id, updatedUser);
      setState(() {
        user = result;
        FullnameController.text = result.fullName ?? '';
        phoneController.text = result.phone ?? '';
        emailController.text = result.email ?? '';
        usernameController.text = result.userName ?? '';
      });

      final prefs = await SharedPreferences.getInstance();
      if (result.userName != null) {
        await prefs.setString('username', result.userName!);
      }

      ToastHelper.showSuccess("Cập nhật thông tin thành công");
    } catch (e) {
      print("updateAccount - Exception: $e");
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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _avatarUrl != null
                        ? NetworkImage('${BaseUrl.urlImage}$_avatarUrl')
                        : null,
                    child: _avatarUrl == null
                        ? const Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.blueAccent,
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceSelection,
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