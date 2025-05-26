import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/exam/QuestionButton.dart';
import 'package:quizapp_fe/Page/exam/QuestionDialog.dart';
import 'package:quizapp_fe/model/take_api.dart';

class TestResultScreen extends StatefulWidget {
  final int? idTake;
  final String? time;

  const TestResultScreen({Key? key, required this.idTake, required this.time}) : super(key: key);

  @override
  _TestResultScreenState createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  Map<String, dynamic>? data;
  int? _idTake;
  late TakeApi _takeApi;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _takeApi = TakeApi();
    _idTake = widget.idTake;
    _loadData();
  }

  void _loadData() async {
    if (_idTake != null) {
      try {
        final result = await _takeApi.getDetailstakeExam(_idTake!);
        setState(() {
          data = result;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showQuestionDialog(int questionIndex) {
    final detailsAnswer = data!['detailsAnswer'] as List<dynamic>? ?? [];
    final questions = detailsAnswer.asMap().entries.where((entry) {
      final item = entry.value;
      return item is Map<String, dynamic>;
    }).map((entry) {
      final item = entry.value as Map<String, dynamic>;
      return item;
    }).toList();

    if (questionIndex >= 0 && questionIndex < questions.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionDialog(
            totalQuestion: questions.length,
            initialQuestionIndex: questionIndex,
            questions: questions,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở câu hỏi: Chỉ số không hợp lệ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không thể tải dữ liệu kết quả thi.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _loadData();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final detailsAnswer = data!['detailsAnswer'] as List<dynamic>? ?? [];
    final totalQuestions = detailsAnswer.length;
    final correctCount = detailsAnswer.where((q) {
      if (q is! Map<String, dynamic>) return false;
      final userAnswerId = q['answerId'];
      final answers = q['demoAnswers'] as List<dynamic>? ?? [];
      return answers.any(
            (a) =>
        a is Map<String, dynamic> &&
            a['id'] == userAnswerId &&
            (a['correct'] as bool? ?? false),
      );
    }).length;
    final incorrectCount = totalQuestions - correctCount;
    final score = totalQuestions > 0 ? (correctCount * 10.0 / totalQuestions) : 0.0;
    final duration = widget.time ?? '00:00:00';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color(0xFFBBA9E1), Color(0xFFF7BFD3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Chi tiết phần thi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      score.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Điểm',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Đúng: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      Text(
                                        '$correctCount câu',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF1BC45D),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'Sai: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      Text(
                                        '$incorrectCount câu',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFFF3B30),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Thời gian làm: $duration',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                'Số câu: $totalQuestions câu',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: totalQuestions,
                              itemBuilder: (context, index) {
                                if (index >= detailsAnswer.length) {
                                  return const SizedBox.shrink();
                                }
                                final question = detailsAnswer[index];
                                if (question is! Map<String, dynamic>) {
                                  return const SizedBox.shrink();
                                }
                                final isCorrect = question['demoAnswers'] != null &&
                                    (question['demoAnswers'] as List<dynamic>).any(
                                          (answer) =>
                                      answer is Map<String, dynamic> &&
                                          answer['id'] == question['answerId'] &&
                                          (answer['correct'] as bool? ?? false),
                                    );

                                return QuestionButton(
                                  number: index + 1,
                                  isHighlighted: false,
                                  status: isCorrect ? 'correct' : 'incorrect',
                                  borderColor:
                                  isCorrect ? const Color(0xFF1BC45D) : const Color(0xFFFF3B30),
                                  onTap: () => _showQuestionDialog(index),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
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
}