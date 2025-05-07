import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/exam/ExamQuestionScreen.dart';

class ExamSettingsDialog extends StatefulWidget {
  final int idquiz;
  final VoidCallback onClose;

  const ExamSettingsDialog({required this.idquiz, Key? key, required this.onClose})
      : super(key: key);

  @override
  State<ExamSettingsDialog> createState() => _ExamSettingsDialogState();
}


class _ExamSettingsDialogState extends State<ExamSettingsDialog> {
  int _selectedExamModeIndex = 0;
  bool _noTimeLimit = true;
  bool _showAnswersImmediately = true;
  bool _shuffleQuestions = false;
  bool _shuffleAnswers = false;
  String _selectedTime = '15s';
  late int idquiz;

  @override
  void initState() {
    super.initState();
    idquiz = widget.idquiz;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView( // Thêm scroll để tránh tràn
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9, // Giới hạn 90% chiều rộng màn hình
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chọn chế độ thi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),

                // Exam mode selection
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildRadioOption(0, 'Ôn thi'),
                      _buildRadioOption(1, 'Thi thử'),
                    ],
                  ),
                ),

                // Checkboxes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckboxOption(
                      'Không giới hạn thời gian làm đề thi',
                      _noTimeLimit,
                          (val) {
                        setState(() {
                          _noTimeLimit = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildCheckboxOption(
                      'Hiển thị đáp án ngay',
                      _showAnswersImmediately,
                          (val) {
                        setState(() {
                          _showAnswersImmediately = val!;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Settings section
                Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Cài đặt đề thi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // More checkboxes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckboxOption(
                      'Tự động đảo câu hỏi',
                      _shuffleQuestions,
                          (val) {
                        setState(() {
                          _shuffleQuestions = val!;
                        });
                      },
                      checkColor: Colors.grey[400]!,
                    ),
                    const SizedBox(height: 8),
                    _buildCheckboxOption(
                      'Tự động đảo câu trả lời',
                      _shuffleAnswers,
                          (val) {
                        setState(() {
                          _shuffleAnswers = val!;
                        });
                      },
                      checkColor: Colors.grey[400]!,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Auto move question timing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tự động chuyển câu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity, // Đảm bảo Dropdown chiếm toàn bộ chiều rộng
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTime,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          items: <String>['2s', '5s', '10s', '15s', '30s']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTime = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Start button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => examquestionscreen(idquiz), // Đóng dialog khi nhấn Bắt đầu
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE991A5), Color(0xFF809FFF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Bắt đầu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(int index, String label) {
    return Row(
      children: [
        Radio<int>(
          value: index,
          groupValue: _selectedExamModeIndex,
          activeColor: index == 0 ? const Color(0xFFE991A5) : Colors.grey,
          onChanged: (int? value) {
            setState(() {
              _selectedExamModeIndex = value!;
            });
          },
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: _selectedExamModeIndex == index
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(
      String label,
      bool value,
      Function(bool?) onChanged, {
        Color checkColor = Colors.green,
      }) {
    return Row(
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: checkColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Expanded( // Sử dụng Expanded để tránh tràn chiều rộng
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

   examquestionscreen(int idquiz) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ExamQuestionScreen(idquiz),));
  }
}