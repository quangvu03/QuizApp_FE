import 'package:flutter/material.dart';

class QuestionDialog extends StatefulWidget {
  final int totalQuestion;
  final int initialQuestionIndex; // Thay vì number, dùng index để chọn câu hỏi ban đầu
  final List<Map<String, dynamic>> questions; // Danh sách câu hỏi từ API (detailsAnswer)

  const QuestionDialog({
    Key? key,
    required this.totalQuestion,
    required this.initialQuestionIndex,
    required this.questions,
  }) : super(key: key);

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  late List<AnswerOption> options;
  late Map<String, dynamic> currentQuestion;
  late String userAnswer;
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    currentQuestionIndex = widget.initialQuestionIndex;
    _updateQuestionAndOptions();
  }

  void _updateQuestionAndOptions() {
    if (widget.questions.isNotEmpty && currentQuestionIndex < widget.questions.length) {
      currentQuestion = widget.questions[currentQuestionIndex];
      userAnswer = currentQuestion['answerId']?.toString() ?? '';

      options = (currentQuestion['demoAnswers'] as List<dynamic>).map((answer) {
        bool isCorrect = answer['correct'] == true;
        String answerId = answer['id'].toString();
        bool isSelected = userAnswer == answerId;
        return AnswerOption(
          id: answerId,
          text: answer['content'].toString(),
          isCorrect: isCorrect,
          isSelected: isSelected,
        );
      }).toList();
    } else {
      // Dữ liệu mặc định nếu không có câu hỏi
      options = [
        AnswerOption(
          id: 'A',
          text: 'Không có dữ liệu',
          isCorrect: false,
          isSelected: false,
        ),
      ];
      currentQuestion = {
        'content': 'Không có câu hỏi',
        'answerId': '',
      };
    }
  }

  void _onQuestionSelected(int index) {
    setState(() {
      currentQuestionIndex = index;
      _updateQuestionAndOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBBA9E1), Color(0xFFF7BFD3)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
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
                              Navigator.of(context).pop();
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
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    width: 80,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.totalQuestion,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () => _onQuestionSelected(index),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentQuestionIndex == index
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: currentQuestionIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 28, color: Colors.grey),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: userAnswer.isNotEmpty &&
                                    options.any((opt) => opt.isCorrect && opt.isSelected)
                                    ? const Color(0xFF1BC45D)
                                    : const Color(0xFFFF3B30),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                userAnswer.isNotEmpty &&
                                    options.any((opt) => opt.isCorrect && opt.isSelected)
                                    ? Icons.check
                                    : Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              userAnswer.isNotEmpty &&
                                  options.any((opt) => opt.isCorrect && opt.isSelected)
                                  ? 'Bạn trả lời đúng!'
                                  : 'Bạn trả lời sai!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: userAnswer.isNotEmpty &&
                                    options.any((opt) => opt.isCorrect && opt.isSelected)
                                    ? const Color(0xFF1BC45D)
                                    : const Color(0xFFFF3B30),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Câu ${currentQuestionIndex + 1}:',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(right: 20.0),
                      //     child: Text(
                      //       '${options.length} đáp án',
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         color: Colors.grey[600],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          currentQuestion['content'] ?? 'Không có câu hỏi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: options.map((option) {
                                bool isUserCorrectAnswer =
                                    option.isCorrect && option.isSelected;
                                bool isUserWrongAnswer =
                                    !option.isCorrect && option.isSelected;
                                bool isCorrectAnswer = option.isCorrect;

                                Color borderColor = Colors.grey[300]!;
                                Color? fillColor;
                                Widget? leadingIcon;

                                if (isUserCorrectAnswer) {
                                  borderColor = const Color(0xFF1BC45D);
                                  fillColor = const Color(0xFFE6F9EE);
                                  leadingIcon = const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF1BC45D),
                                    size: 24,
                                  );
                                } else if (isUserWrongAnswer) {
                                  borderColor = const Color(0xFFFF3B30);
                                  fillColor = const Color(0xFFFEEAE9);
                                  leadingIcon = const Icon(
                                    Icons.cancel,
                                    color: Color(0xFFFF3B30),
                                    size: 24,
                                  );
                                } else if (isCorrectAnswer) {
                                  borderColor = const Color(0xFF1BC45D);
                                  fillColor = const Color(0xFFE6F9EE);
                                  leadingIcon = const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF1BC45D),
                                    size: 24,
                                  );
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor, width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                    color: fillColor,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: option.isSelected || option.isCorrect
                                        ? leadingIcon
                                        : Radio<bool>(
                                      value: true,
                                      groupValue: option.isSelected,
                                      onChanged: null,
                                      activeColor: Colors.transparent,
                                    ),
                                    title: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${option.id}. ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isUserWrongAnswer
                                                  ? const Color(0xFFFF3B30)
                                                  : isCorrectAnswer
                                                  ? const Color(0xFF1BC45D)
                                                  : Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: option.text,
                                            style: TextStyle(
                                              color: isUserWrongAnswer
                                                  ? const Color(0xFFFF3B30)
                                                  : isCorrectAnswer
                                                  ? const Color(0xFF1BC45D)
                                                  : Colors.black,
                                              fontSize: 16,
                                              fontWeight:
                                              option.isCorrect || option.isSelected
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class AnswerOption {
  final String id;
  final String text;
  final bool isCorrect;
  final bool isSelected;

  AnswerOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.isSelected,
  });
}