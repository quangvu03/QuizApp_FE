import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/exam/QuestionButton.dart';
import 'package:quizapp_fe/Page/exam/QuestionDialog.dart';
import 'package:quizapp_fe/model/take_api.dart';

class TestResultScreen extends StatefulWidget {
  final int? idTake;

  const TestResultScreen({Key? key, required this.idTake}) : super(key: key);

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
        print("-------------------------------------");
        print("::_idtake:: $_idTake");
        print("::result:: $result");

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
    // Ép kiểu List<dynamic> thành List<Map<String, dynamic>>
    final questions = detailsAnswer.map((item) => item as Map<String, dynamic>).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDialog(
          totalQuestion: detailsAnswer.length,
          initialQuestionIndex: questionIndex,
          questions: questions,
        ),
      ),
    );
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
    final correctCount = detailsAnswer.where((q) {
      final userAnswerId = q['answerId'];
      final answers = q['demoAnswers'] as List<dynamic>? ?? [];
      return answers.any(
            (a) => a['id'] == userAnswerId && (a['correct'] as bool? ?? false),
      );
    }).length;
    final totalQuestions = detailsAnswer.length;
    final incorrectCount = totalQuestions - correctCount;
    final score = (totalQuestions/10)*correctCount;
    final duration = data!['duration']?.toString() ?? '00:00:00';

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
              // App bar
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
              // Result card
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
                        // Score section
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
                                      score.toString(),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: GridView.builder(
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: totalQuestions,
                              itemBuilder: (context, index) {
                                final questionNumber = index + 1;
                                final question = detailsAnswer.firstWhere(
                                      (q) => q['questionId'] == questionNumber,
                                  orElse: () => null,
                                );
                                final isCorrect = question != null &&
                                    (question['demoAnswers'] as List<dynamic>? ?? [])
                                        .any(
                                          (answer) =>
                                      answer['id'] == question['answerId'] &&
                                          (answer['correct'] as bool? ?? false),
                                    );

                                return QuestionButton(
                                  number: questionNumber,
                                  isHighlighted: false,
                                  status: isCorrect ? 'correct' : 'incorrect',
                                  borderColor: isCorrect
                                      ? const Color(0xFF1BC45D)
                                      : const Color(0xFFFF3B30),
                                  onTap: question != null
                                      ? () {
                                    _showQuestionDialog(index);
                                  }
                                      : null,
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