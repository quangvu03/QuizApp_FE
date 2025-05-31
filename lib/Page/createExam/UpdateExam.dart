import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quizapp_fe/entities/quiz.dart';
import 'package:quizapp_fe/model/quiz_api.dart';
import 'package:quizapp_fe/helpers/Url.dart';

class UpdateExamScreen extends StatefulWidget {
  final int idQuiz;

  const UpdateExamScreen(this.idQuiz, {Key? key}) : super(key: key);

  @override
  State<UpdateExamScreen> createState() => _UpdateExamScreenState();
}

class _UpdateExamScreenState extends State<UpdateExamScreen> {
  int _selectedImageIndex = 1;
  File? _pickedImage;
  int? _idQuiz;
  String? _currentImage;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, dynamic>? _quizData;

  @override
  void initState() {
    super.initState();
    _idQuiz = widget.idQuiz;
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      final quizData = await QuizApiService().fetchQuizDetailRaw(widget.idQuiz);
      setState(() {
        _quizData = quizData;
        _titleController.text = quizData['title'] ?? '';
        _descriptionController.text = quizData['content'] ?? '';
        _currentImage = quizData['image'];

        const imagePaths = ['bgrQuiz1.png', 'bgrQuiz2.png', 'bgrQuiz3.png'];
        int index = imagePaths.indexOf(_currentImage ?? '') + 1;
        _selectedImageIndex = index > 0 ? index : 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu đề thi: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          status = await Permission.camera.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quyền truy cập camera bị từ chối')),
            );
            return;
          }
        }
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
          _selectedImageIndex = 0;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có ảnh được chọn')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quizData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCFBCFF), Color(0xFFE6E6FF)],
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFAB47BC), Color(0xFFCE93D8)],
                      ),
                      border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: _buildAppBar(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildThongTinCoBan(),
                        const SizedBox(height: 16),
                        _buildImagePreview(),
                        const SizedBox(height: 16),
                        _buildImageSelector(),
                        const SizedBox(height: 32),
                        _buildTenDeThiField(),
                        const SizedBox(height: 24),
                        _buildMoTaDeThiField(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildLuuButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Row(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Sửa đề thi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildThongTinCoBan() {
    return const Text(
      'Thông tin cơ bản',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333366),
      ),
    );
  }

  Widget _buildImagePreview() {
    const imagePaths = [
      'assets/images/quiz/bgrQuiz1.png',
      'assets/images/quiz/bgrQuiz2.png',
      'assets/images/quiz/bgrQuiz3.png',
    ];

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 2),
      ),
      child: _pickedImage != null
          ? Image.file(_pickedImage!, fit: BoxFit.cover)
          : _selectedImageIndex == 0 && _currentImage != null
          ? Image.network(
        '${BaseUrl.urlImage}$_currentImage',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          imagePaths[0],
          fit: BoxFit.cover,
        ),
      )
          : Image.asset(
        imagePaths[_selectedImageIndex.clamp(1, 3) - 1],
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildImageSelector() {
    const imagePaths = ['bgrQuiz1.png', 'bgrQuiz2.png', 'bgrQuiz3.png'];
    bool isCurrentImageDefault = _currentImage != null && imagePaths.contains(_currentImage);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildUploadImageOption(),
        if (!isCurrentImageDefault) _buildCurrentImageOption(),
        _buildImageOption(1),
        _buildImageOption(2),
        if (isCurrentImageDefault) _buildImageOption(3),
      ],
    );
  }

  Widget _buildUploadImageOption() {
    return GestureDetector(
      onTap: _showImageSourceSelection,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(8),
          image: _pickedImage != null
              ? DecorationImage(image: FileImage(_pickedImage!), fit: BoxFit.cover)
              : null,
        ),
        child: _pickedImage == null
            ? const Center(child: Icon(Icons.camera_alt, size: 24, color: Colors.grey))
            : null,
      ),
    );
  }

  Widget _buildCurrentImageOption() {
    final bool isSelected = _selectedImageIndex == 0;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImageIndex = 0;
          _pickedImage = null;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          image: _currentImage != null
              ? DecorationImage(
            image: NetworkImage('${BaseUrl.urlImage}$_currentImage'),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) => const AssetImage('assets/images/quiz/bgrQuiz1.png'),
          )
              : null,
        ),
        child: _currentImage == null
            ? const Center(child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey))
            : isSelected
            ? Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.indigo,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildImageOption(int index) {
    final bool isSelected = _selectedImageIndex == index;
    const imagePaths = [
      'assets/images/quiz/bgrQuiz1.png',
      'assets/images/quiz/bgrQuiz2.png',
      'assets/images/quiz/bgrQuiz3.png',
    ];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImageIndex = index;
          _pickedImage = null;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage(imagePaths[index - 1]),
            fit: BoxFit.cover,
          ),
        ),
        child: isSelected
            ? Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.indigo,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildTenDeThiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Tên đề thi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333366),
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'VD: Đề thi Tiếng Anh chuyên ngành 1',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoTaDeThiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Mô tả đề thi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333366),
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập mô tả cho đề thi...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLuuButton() {
    return InkWell(
      onTap: () async {
        if (_titleController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng nhập tên đề thi')),
          );
          return;
        }
        if (_descriptionController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng nhập mô tả đề thi')),
          );
          return;
        }
        if (_quizData == null || _idQuiz == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dữ liệu đề thi không hợp lệ')),
          );
          return;
        }
        if (_pickedImage != null && !await _pickedImage!.exists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File ảnh không tồn tại')),
          );
          return;
        }

        final String title = _titleController.text;
        final String description = _descriptionController.text;

        const imagePaths = [
          'bgrQuiz1.png',
          'bgrQuiz2.png',
          'bgrQuiz3.png',
        ];

        String? image;
        File? avatar;
        if (_pickedImage != null) {
          avatar = _pickedImage;
          image = null;
        } else if (_selectedImageIndex > 0 && _selectedImageIndex <= 3) {
          image = imagePaths[_selectedImageIndex - 1];
          avatar = null;
        } else {
          image = _currentImage;
          avatar = null;
        }

        final quiz = Quiz(
          id: _idQuiz,
          content: description,
          title: title,
          image: image,
        );

        try {
          print('Sending quiz: id=${quiz.id}, title=${quiz.title}, content=${quiz.content}, image=${quiz.image}, avatar=${avatar?.path}');
          final data = await QuizApiService().updateQuiz(quiz, avatar);
          print('Response data: $data');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật đề thi thành công')),
          );
          // Đợi 2 giây để SnackBar hiển thị, sau đó pop về trang trước
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context);
        } catch (e) {
          print('Error updating quiz: $e');
          String errorMessage = 'Lỗi khi cập nhật đề thi';
          if (e.toString().contains('SocketException')) {
            errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối.';
          } else if (e.toString().contains('FormatException')) {
            errorMessage = 'Lỗi định dạng dữ liệu từ server.';
          } else if (e.toString().contains('Failed to update quiz')) {
            errorMessage = e.toString().split('Error: ').last;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$errorMessage')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF5E5CE6), Color(0xFF7B68EE)],
          ),
        ),
        child: const Center(
          child: Text(
            'Sửa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}