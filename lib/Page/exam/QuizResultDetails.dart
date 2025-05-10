import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/exam/QuestionSelectionDialog.dart';
import 'package:quizapp_fe/entities/Takeanswer.dart';

class QuizResultScreen extends StatefulWidget {
  final int totalQuestion;
  final int countCorrect;
  final String time;
  final List<TakeAnswer> listTake;
  final List<Map<String, dynamic>>? examQuizList;

  const QuizResultScreen(
      this.totalQuestion,
      this.countCorrect,
      this.time,
      this.listTake,
      this.examQuizList, {
        Key? key,
      }) : super(key: key);

  @override
  _QuizResultScreenState createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  int? _totalQuestion;
  int? countCorrect;
  double? score;
  String? time;
  List<TakeAnswer>? _listTake;
  int? _number;
  List<Map<String, dynamic>>? _examQuizList;

  @override
  void initState() {
    super.initState();
    _totalQuestion = widget.totalQuestion;
    countCorrect = widget.countCorrect;
    score = (10 / _totalQuestion!) * countCorrect!;
    time = widget.time;
    _listTake = widget.listTake;
    _number = 1;
    _examQuizList = widget.examQuizList;
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
              Color(0xFFE0B0FF), // Light purple pink
              Color(0xFFADD8E6), // Light blue
            ],
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black54),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Kết quả',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 100,
                    ),
                    child: Column(
                      children: [
                        // Result card
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            color: const Color(0xFFFEF0F5),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // Score circle
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFD6A4E0),
                                          Color(0xFF87CEFA),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            score!.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Text(
                                            'Điểm',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Rating section
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Xếp loại: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: score! < 5.0
                                              ? Colors.red
                                              : score! < 7.0
                                              ? Colors.orange
                                              : Colors.green,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          score! < 5.0
                                              ? 'Yếu'
                                              : score! < 7.0
                                              ? 'Trung bình'
                                              : 'Khá',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Statistics - Using GridView
                                  GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 12,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    childAspectRatio: 1.8,
                                    children: [
                                      _buildStatItem(
                                          'Tổng số câu',
                                          '$_totalQuestion',
                                          Icons.question_mark,
                                          Colors.amber.shade200),
                                      _buildStatItem('Bỏ trống', '0', Icons.warning, Colors.amber.shade200),
                                      _buildStatItem(
                                          'Đúng',
                                          '$countCorrect',
                                          Icons.check_circle,
                                          Colors.green.shade200),
                                      _buildStatItem(
                                          'Sai',
                                          '${_totalQuestion! - countCorrect!}',
                                          Icons.close,
                                          Colors.red.shade200),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Detailed results section
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Kết quả từng phần thi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Section result card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              score!.toStringAsFixed(2),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Text(
                                              'Điểm',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Đã hoàn thành',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Thời gian: $time',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          'Số câu: $_totalQuestion câu',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(fontSize: 14, color: Colors.black),
                                            children: [
                                              const TextSpan(text: 'Đúng: '),
                                              TextSpan(
                                                text: '$countCorrect câu',
                                                style: const TextStyle(
                                                    color: Colors.green, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(fontSize: 14, color: Colors.black),
                                            children: [
                                              const TextSpan(text: 'Sai: '),
                                              TextSpan(
                                                text: '${_totalQuestion! - countCorrect!} câu',
                                                style: const TextStyle(
                                                    color: Colors.red, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_listTake != null && _examQuizList != null) {
                                        showQuestionSelectionDialog(
                                          context,
                                          _totalQuestion,
                                          _number,
                                          _listTake!.map((takeAnswer) => takeAnswer.toMap()).toList(),
                                          _examQuizList,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Dữ liệu không hợp lệ')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 40),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.blue,
                                      elevation: 0,
                                      side: const BorderSide(color: Colors.blue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Xem chi tiết'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 240),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF48FB1),
                          Color(0xFF90CAF9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Làm lại bài thi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Làm lại câu sai',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color iconBgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<int?> showQuestionSelectionDialog(
      BuildContext context,
      int? totalQuestion,
      int? number,
      List<Map<String, dynamic>> answerHistory,
      List<Map<String, dynamic>>? examQuizList,
      ) async {
    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return QuestionSelectionDialog(
          number: totalQuestion,
          questionAt: number,
          answerHistory: answerHistory,
          examQuizList: examQuizList,
        );
      },
    );
  }
}