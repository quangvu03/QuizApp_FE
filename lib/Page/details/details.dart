import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/createExam/QuestionScreen.dart';
import 'package:quizapp_fe/Page/createExam/UpdateExam.dart';
import 'package:quizapp_fe/Page/details/ExamSettingDialog.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/model/quiz_api.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert'; // Để parse JSON

class QuizDetailPage extends StatefulWidget {
  final int idquiz;
  final bool showOption;

  const QuizDetailPage({Key? key, required this.idquiz, this.showOption = false}) : super(key: key);

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  late Future<Map<String, dynamic>> _quizDetail;
  late Future<List<Map<String, dynamic>>> _questions;
  final QuizApiService _quizService = QuizApiService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  User? _user;

  @override
  void initState() {
    super.initState();
    _quizDetail = QuizApiService().fetchQuizDetailRaw(widget.idquiz);
    _questions = QuizApiService().fetchQuizdemoQuiz(widget.idquiz);
    printDebugInfo();
    _loadUser();
  }

  void printDebugInfo() async {
    final quizDetail = await _quizDetail;
    final questions = await _questions;

    print("_quizDetail : $quizDetail"); // Đây là Map<String, dynamic>
    print("_questions : $questions");   // Đây là List<Map<String, dynamic>>
  }

  Future<void> _loadUser() async {
    final detail = await _quizDetail;

    String? username = detail['username'];
    if (username != null) {
      try {
        AccountApi accountApi = AccountApi();
        User? user = await accountApi?.checkUsername(username);
        setState(() {
          _user = user;
        });
      } catch (e) {
        print("Error loading user: $e");
        ToastHelper.showError("Không thể tải thông tin người dùng");
      }
    } else {
      print("usernull");
      ToastHelper.showError("Vui lòng đăng nhập lại");
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.grey),
                  title: const Text('Chỉnh sửa đề thi'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateExamScreen(widget.idquiz),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.grey),
                  title: const Text('Chỉnh sửa phần thi'),
                    onTap: () async {
                      final quizDetail = await _quizDetail;
                      final questions = await _questions;
                      if (_user != null) {
                        final Map<String, dynamic> dataQuiz = {
                          'image': quizDetail['image'],
                          'id': quizDetail['id'],
                          'userId': _user!.id,
                          'title': quizDetail['title'],
                          'createdAt': DateTime.now(),
                          'content': quizDetail['content'],
                        };
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionScreen(
                              dataQuiz: dataQuiz,
                            ),
                          ),
                        );
                      } else {
                        ToastHelper.showError("Chưa tải xong dữ liệu quiz hoặc user");
                      }
                    }
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Xóa đề thi'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmationDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa đề thi này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng dialog xác nhận
                // Hiển thị loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                try {
                  String result = await _quizService.deleteQuiz(widget.idquiz);
                  // Đóng loading dialog
                  Navigator.of(context, rootNavigator: true).pop();
                  if (result == 'success') {
                    ToastHelper.showSuccess("Đã xóa đề thi thành công");
                    if (mounted) {
                      Navigator.pop(context, true); // Trả về true khi xóa thành công
                    }
                  } else {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  }
                } catch (e) {
                  Navigator.of(context, rootNavigator: true).pop();
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Có', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey, // Gắn GlobalKey cho ScaffoldMessenger
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8BBD0), Color(0xFFE1F5FE)],
            ),
          ),
          child: SafeArea(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _quizDetail,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print("Lỗi FutureBuilder: ${snapshot.error}");
                  return const Center(child: Text('Lỗi khi tải dữ liệu'));
                } else if (!snapshot.hasData) {
                  print("Lỗi FutureBuilder: ${snapshot.error}");
                  return const Center(child: Text('Không có dữ liệu'));
                }

                final quiz = snapshot.data!;
                final numberQuestion = quiz['numberQuestion'] ?? 0;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // App bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF8BBD0), Color(0xFFE1BEE7)],
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Navigate back
                            },
                            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Chi tiết đề thi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (widget.showOption)
                            GestureDetector(
                              onTap: _showOptionsDialog,
                              child: const Icon(Icons.more_vert, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                    // Quiz details container
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBDEFB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            height: 180,
                            child: Stack(
                              children: [
                                Center(
                                  child: quiz['image'] != null && quiz['image'].toString().isNotEmpty
                                      ? Image.network(
                                    '${BaseUrl.urlImage}${quiz['image']}',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                      : const SizedBox(),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              quiz['title'] ?? 'Không có tiêu đề',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$numberQuestion câu',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Spacer(),
                                _buildStatItem(quiz['numberfavorite']?.toString() ?? '0', 'Lượt thích'),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  quiz['createdAt'] ?? '05/05/2025',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: numberQuestion == 0
                                        ? null // Vô hiệu hóa nếu không có câu hỏi
                                        : () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            insetPadding: EdgeInsets.zero,
                                            backgroundColor: Colors.transparent,
                                            child: ExamSettingsDialog(
                                              idquiz: widget.idquiz,
                                              onClose: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.check_circle_outline),
                                    label: const Text('Bắt đầu'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF8BBD0),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.bookmark_border),
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.favorite_border),
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // User info container
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: quiz['avataUser'] != null && quiz['avataUser'].toString().isNotEmpty
                                    ? Image.network(
                                  '${BaseUrl.urlImage}${quiz['avataUser']}',
                                  height: 25,
                                  width: 25,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 25,
                                    width: 25,
                                    decoration: const BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person, color: Colors.white, size: 16),
                                  ),
                                )
                                    : Container(
                                  height: 25,
                                  width: 25,
                                  decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white, size: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quiz['username'] ?? 'Nguyen quoc minh',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.file_download_outlined, color: Colors.blue),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.thumb_up_outlined, color: Colors.grey),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.share, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    // Questions section
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tabs
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                _buildTab('Xem trước', true),
                                _buildTab('Đánh giá', false),
                                _buildTab('Kết quả của tôi', false),
                              ],
                            ),
                          ),
                          _buildSection('Phần 1'),
                          if (numberQuestion == 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Không có câu hỏi cho đề thi',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _questions,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(child: Text('Lỗi khi tải câu hỏi'));
                                }

                                final questions = snapshot.data ?? [];
                                if (questions.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'Không có câu hỏi',
                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: questions.length,
                                  itemBuilder: (context, index) {
                                    final question = questions[index];
                                    final answers = List<Map<String, dynamic>>.from(question['answers'] ?? []);
                                    return _buildQuestionItem(
                                      index + 1,
                                      question['content'] ?? '[]',
                                      answers.map((answer) => answer['content']?.toString() ?? '[]').toList(),
                                    );
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
            bottom: BorderSide(color: Colors.blue, width: 2),
          )
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuestionItem(int number, String questionJson, List<String> optionsJson) {
    // Parse JSON content của câu hỏi
    late quill.Document doc;
    try {
      final deltaJson = jsonDecode(questionJson);
      doc = quill.Document.fromJson(deltaJson);
    } catch (e) {
      doc = quill.Document()..insert(0, 'Nội dung câu hỏi không hợp lệ');
    }
    final questionController = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Câu $number',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Hiển thị nội dung câu hỏi bằng QuillEditor.basic
          quill.QuillEditor.basic(
            configurations: quill.QuillEditorConfigurations(
              controller: questionController,
              autoFocus: false,
              enableInteractiveSelection: false,
              scrollable: false,
              padding: EdgeInsets.zero,
              expands: false,
              customStyles: quill.DefaultStyles(
                paragraph: quill.DefaultTextBlockStyle(
                  const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  const quill.VerticalSpacing(2, 2), // spacing
                  const quill.VerticalSpacing(0, 0), // lineSpacing
                  null,
                ),
              ),
            ),
            scrollController: ScrollController(),
          ),
          const SizedBox(height: 8),
          // Hiển thị các đáp án
          ...List.generate(
            optionsJson.length,
                (index) => _buildOptionItem(
              String.fromCharCode(65 + index), // A, B, C, D...
              optionsJson[index],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(String prefix, String optionJson) {
    // Parse JSON content của đáp án
    late quill.Document doc;
    try {
      final deltaJson = jsonDecode(optionJson);
      doc = quill.Document.fromJson(deltaJson);
    } catch (e) {
      doc = quill.Document()..insert(0, 'Đáp án không hợp lệ');
    }
    final optionController = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $prefix. ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: quill.QuillEditor.basic(
              configurations: quill.QuillEditorConfigurations(
                controller: optionController,
                autoFocus: false,
                enableInteractiveSelection: false,
                scrollable: false,
                padding: EdgeInsets.zero,
                expands: false,
                customStyles: quill.DefaultStyles(
                  paragraph: quill.DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    const quill.VerticalSpacing(2, 2), // spacing
                    const quill.VerticalSpacing(0, 0), // lineSpacing
                    null, // padding
                  ),
                ),
              ),
              scrollController: ScrollController(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên
    super.dispose();
  }
}