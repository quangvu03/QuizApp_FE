import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizapp_fe/model/quiz_api.dart';

class ExamQuestionScreen extends StatefulWidget {
  final int idquizd;

  const ExamQuestionScreen(this.idquizd, {Key? key}) : super(key: key);

  @override
  State<ExamQuestionScreen> createState() => _ExamQuestionScreenState();
}

class _ExamQuestionScreenState extends State<ExamQuestionScreen> {
  int? _selectedAnswer;
  bool _hasAnswered = false;
  Map<String, dynamic>? examapi;
  int? _number;
  int? totalQuestion;

  late QuizApiService _quizApiService;
  String? question;
  String? type;
  List<Map<String, dynamic>>? examQuizList;
  List<Map<String, dynamic>>? answers;

  // Lưu trữ lịch sử trả lời: Map với key là số câu hỏi, value là {selectedAnswer, hasAnswered}
  final Map<int, Map<String, dynamic>> _answerHistory = {};

  @override
  void initState() {
    super.initState();
    _number = 1;
    _quizApiService = QuizApiService();
    fetchAPIexam(widget.idquizd);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> fetchAPIexam(int idquiz) async {
    try {
      examapi = await _quizApiService.getExam(idquiz);

      setState(() {
        totalQuestion = examapi?["numberexamQuizDTO"] ?? 0;
        examQuizList = List<Map<String, dynamic>>.from(examapi?["examQuizDTO"] ?? []);

        if (examQuizList == null || examQuizList!.isEmpty) {
          print("Danh sách câu hỏi rỗng hoặc null");
          question = "Không có câu hỏi";
          type = "";
          answers = [];
          return;
        }

        // Đảm bảo _number hợp lệ
        if (_number! < 1 || _number! > examQuizList!.length) {
          print("Số câu hỏi không hợp lệ: $_number");
          _number = 1;
        }

        int questionIndex = _number! - 1;
        question = examQuizList![questionIndex]["content"] ?? "Không có nội dung";
        type = examQuizList![questionIndex]["type"] ?? "";
        answers = List<Map<String, dynamic>>.from(examQuizList![questionIndex]["answers"] ?? []);

        // Kiểm tra lịch sử trả lời cho câu hỏi hiện tại
        if (_answerHistory.containsKey(_number)) {
          _selectedAnswer = _answerHistory[_number]!['selectedAnswer'];
          _hasAnswered = _answerHistory[_number]!['hasAnswered'];
        } else {
          _selectedAnswer = null;
          _hasAnswered = false;
        }

        print("Answers: $answers");
        print("Answer History: $_answerHistory");
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu từ API: $e");
      setState(() {
        question = "Lỗi tải câu hỏi";
        type = "";
        answers = [];
      });
    }
  }

  // Hàm lưu đáp án vào lịch sử
  void _saveAnswerToHistory(int questionNumber, int? selectedAnswer, bool hasAnswered) {
    _answerHistory[questionNumber] = {
      'selectedAnswer': selectedAnswer,
      'hasAnswered': hasAnswered,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8BBD0),
              Color(0xFFFCE4EC),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black54,
                          size: 15,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 18, color: Colors.black54),
                          SizedBox(width: 4),
                          Text(
                            '00 : 10 : 09',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black54),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16, bottom: 0, top: 0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Câu $_number:',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF673AB7),
                              ),
                            ),
                            Text(
                              '$type',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$question",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        answers == null || answers!.isEmpty
                            ? const Text(
                          'Không có đáp án nào để hiển thị',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: answers?.length ?? 0,
                          itemBuilder: (context, index) {
                            final answer = answers![index];
                            bool isCorrect = answer["correct"] == true;
                            bool isSelected = _selectedAnswer == index;
                            Color backgroundColor = Colors.white;

                            if (_hasAnswered) {
                              if (isCorrect) {
                                backgroundColor = Colors.green[100]!; // Đáp án đúng: xanh
                              } else if (isSelected && !isCorrect) {
                                backgroundColor = Colors.red[100]!; // Đáp án sai: đỏ
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: RadioListTile<int>(
                                  title: Text(
                                    answer["content"]?.toString() ?? 'Không có dữ liệu',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  value: index,
                                  groupValue: _selectedAnswer,
                                  onChanged: _hasAnswered
                                      ? null
                                      : (int? value) {
                                    setState(() {
                                      _selectedAnswer = value;
                                      _hasAnswered = true;
                                      _saveAnswerToHistory(_number!, value, true);
                                      print("Đáp án được chọn: $value, Đúng: ${answers![value!]["correct"]}");
                                      print("Answer History: $_answerHistory");
                                    });
                                  },
                                  activeColor: const Color(0xFF673AB7),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF06292),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          if (_number! > 1) {
                            setState(() {
                              _number = _number! - 1;
                              fetchAPIexam(widget.idquizd);
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 18, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '$_number/$totalQuestion câu',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF06292),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: () {
                          if (_number! < totalQuestion!) {
                            setState(() {
                              _number = _number! + 1;
                              fetchAPIexam(widget.idquizd);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}