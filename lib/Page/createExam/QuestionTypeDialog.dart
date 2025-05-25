import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/createExam/QuestionEditorPage.dart';

class QuestionTypeDialog extends StatefulWidget {
  final Map<String, dynamic>? dataQuiz;

  const QuestionTypeDialog({super.key, this.dataQuiz});

  @override
  State<QuestionTypeDialog> createState() => _QuestionTypeDialogState();
}

class _QuestionTypeDialogState extends State<QuestionTypeDialog> {
  int? selectedAnswerIndex; // Dùng cho "1 đáp án" và "True/False"
  List<int> selectedAnswerIndices = []; // Dùng cho "Nhiều đáp án"
  String selectedQuestionType = '1 đáp án'; // Loại câu hỏi mặc định

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.only(top: 50),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chọn loại câu hỏi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Loại câu hỏi',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedQuestionType,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: ['1 đáp án', 'Nhiều đáp án', 'True/False']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    const Icon(Icons.article_outlined),
                                    const SizedBox(width: 8),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedQuestionType = newValue;
                                  // Reset trạng thái chọn khi thay đổi loại câu hỏi
                                  selectedAnswerIndex = null;
                                  selectedAnswerIndices = [];
                                  if (newValue == 'True/False') {
                                    selectedAnswerIndex = 0; // Mặc định chọn "Đúng"
                                  } else if (newValue == '1 đáp án') {
                                    selectedAnswerIndex = 2; // Mặc định chọn đáp án thứ 3
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getDescription(selectedQuestionType),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Xem trước',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildPreviewContent(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B6EF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Truyền dataQuiz và selectedQuestionType sang QuestionEditorPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionEditorPage(
                          dataQuiz: widget.dataQuiz,
                          questionType: selectedQuestionType,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Xác nhận',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Phương thức hỗ trợ lấy mô tả dựa trên loại câu hỏi
  String _getDescription(String questionType) {
    switch (questionType) {
      case '1 đáp án':
        return 'Cho phép tạo câu hỏi có nhiều câu trả lời và chỉ được chọn 1 đáp án đúng';
      case 'Nhiều đáp án':
        return 'Cho phép tạo câu hỏi có nhiều câu trả lời và có thể chọn nhiều đáp án đúng';
      case 'True/False':
        return 'Cho phép tạo câu hỏi với hai đáp án: Đúng hoặc Sai';
      default:
        return '';
    }
  }

  // Phương thức hỗ trợ xây dựng nội dung xem trước dựa trên loại câu hỏi
  List<Widget> _buildPreviewContent() {
    if (selectedQuestionType == 'True/False') {
      return [
        const Text(
          'Câu hỏi: Triết học ra đời ở Hy Lạp cổ đại?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _buildAnswerOption(0, 'Đúng'),
        const SizedBox(height: 8),
        _buildAnswerOption(1, 'Sai'),
      ];
    } else {
      return [
        const Text(
          'Chọn câu trả lời đúng: Triết học ra đời ở đâu?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _buildAnswerOption(0, 'Chỉ ở phương Đông'),
        const SizedBox(height: 8),
        _buildAnswerOption(1, 'Chỉ ở phương Tây'),
        const SizedBox(height: 8),
        _buildAnswerOption(2, 'Cả phương Đông và phương Tây'),
        const SizedBox(height: 8),
        _buildAnswerOption(3, 'Cả 3 đáp án còn lại đều sai'),
      ];
    }
  }

  Widget _buildAnswerOption(int index, String text) {
    final bool isSelected = selectedQuestionType == 'Nhiều đáp án'
        ? selectedAnswerIndices.contains(index)
        : selectedAnswerIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedQuestionType == 'Nhiều đáp án') {
            // Chọn hoặc bỏ chọn nhiều đáp án
            if (selectedAnswerIndices.contains(index)) {
              selectedAnswerIndices.remove(index);
            } else {
              selectedAnswerIndices.add(index);
            }
          } else {
            // Chọn một đáp án duy nhất cho "1 đáp án" hoặc "True/False"
            selectedAnswerIndex = index;
            selectedAnswerIndices = []; // Đảm bảo danh sách rỗng
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Hiển thị Checkbox cho "Nhiều đáp án", Radio cho "1 đáp án" và "True/False"
            if (selectedQuestionType == 'Nhiều đáp án')
              Checkbox(
                value: selectedAnswerIndices.contains(index),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedAnswerIndices.add(index);
                    } else {
                      selectedAnswerIndices.remove(index);
                    }
                  });
                },
                activeColor: Colors.green,
                checkColor: Colors.white,
              )
            else
              Radio<int>(
                value: index,
                groupValue: selectedAnswerIndex,
                onChanged: (int? value) {
                  setState(() {
                    selectedAnswerIndex = value;
                    selectedAnswerIndices = []; // Đảm bảo danh sách rỗng
                  });
                },
                activeColor: Colors.green,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected ? Colors.green : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}