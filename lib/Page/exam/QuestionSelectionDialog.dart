import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/exam/QuestionButton.dart';

class QuestionSelectionDialog extends StatefulWidget {
  final int? number;
  final int? questionAt;
  final List<Map<String, dynamic>> answerHistory;
  final List<Map<String, dynamic>>? examQuizList;

  const QuestionSelectionDialog({
    super.key,
    required this.number,
    required this.questionAt,
    required this.answerHistory,
    required this.examQuizList,
  });

  @override
  State<QuestionSelectionDialog> createState() => _QuestionSelectionDialogState();
}

class _QuestionSelectionDialogState extends State<QuestionSelectionDialog> {
  int? _numberquestion;
  int? _question;

  @override
  void initState() {
    super.initState();
    _numberquestion = widget.number;
    _question = widget.questionAt;
  }

  Map<String, dynamic> getQuestionStatus(int questionNumber) {
    if (widget.examQuizList == null || questionNumber < 1 || questionNumber > widget.examQuizList!.length) {
      return {'status': 'unanswered', 'borderColor': Colors.grey[300]!};
    }

    // Lấy questionId từ examQuizList
    final questionId = widget.examQuizList![questionNumber - 1]["id"];
    final answers = List<Map<String, dynamic>>.from(widget.examQuizList![questionNumber - 1]["answers"] ?? []);

    // Tìm lịch sử trả lời dựa trên questionId
    final historyEntry = widget.answerHistory.firstWhere(
          (entry) => entry['questionId'] == questionId,
      orElse: () => {},
    );

    // Nếu không có lịch sử hoặc answerId là null, coi như chưa trả lời
    if (historyEntry.isEmpty || !historyEntry.containsKey('answerId') || historyEntry['answerId'] == null) {
      return {'status': 'unanswered', 'borderColor': Colors.grey[300]!};
    }

    // Lấy answerId từ lịch sử
    final answerId = historyEntry['answerId'] as int?;

    // Tìm đáp án trong danh sách answers
    final selectedAnswer = answers.firstWhere(
          (answer) => answer["id"] == answerId,
      orElse: () => {},
    );

    // Nếu không tìm thấy đáp án, coi như chưa trả lời
    if (selectedAnswer.isEmpty) {
      return {'status': 'unanswered', 'borderColor': Colors.grey[300]!};
    }

    // Xác định đúng/sai dựa trên correct
    final isCorrect = selectedAnswer["correct"] == true;
    return {
      'status': isCorrect ? 'correct' : 'incorrect',
      'borderColor': isCorrect ? Colors.green : Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.only(top: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Chọn câu hỏi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // Grid of question numbers
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _numberquestion,
                  itemBuilder: (context, index) {
                    final questionNumber = index + 1;
                    final status = getQuestionStatus(questionNumber);
                    return QuestionButton(
                      number: questionNumber,
                      isHighlighted: questionNumber == _question,
                      status: status['status'],
                      borderColor: status['borderColor'],
                      onTap: () {
                        Navigator.of(context).pop(questionNumber);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}