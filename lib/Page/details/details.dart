import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/details/ExamSettingDialog.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/quiz_api.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert'; // Để parse JSON

class QuizDetailPage extends StatefulWidget {
  final int idquiz;

  const QuizDetailPage({Key? key, required this.idquiz}) : super(key: key);

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  late Future<Map<String, dynamic>> _quizDetail;
  late Future<List<Map<String, dynamic>>> _questions;

  @override
  void initState() {
    super.initState();
    _quizDetail = QuizApiService().fetchQuizDetailRaw(widget.idquiz);
    _questions = QuizApiService().fetchQuizdemoQuiz(widget.idquiz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBDEFB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Quiz image
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
                        // Quiz title
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
                        // Quiz details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${quiz['numberQuestion'] ?? 0} câu',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              _buildStatItem(quiz['numberfavorite']?.toString() ?? '0', 'Lượt thích'),
                            ],
                          ),
                        ),
                        // Date
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
                        // Action buttons
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
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
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _questions,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(child: Text('Lỗi khi tải câu hỏi'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('Không có câu hỏi'));
                            }

                            final questions = snapshot.data!;
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
              // readOnly: true,
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
                  const quill.VerticalSpacing(2, 2),         // spacing
                  const quill.VerticalSpacing(0, 0),         // lineSpacing
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
                // readOnly: true,
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
                    const quill.VerticalSpacing(2, 2),         // spacing
                    const quill.VerticalSpacing(0, 0),         // lineSpacing
                    null,                   // padding
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