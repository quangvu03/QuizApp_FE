import 'package:flutter/material.dart';

class QuestionTypeDialog extends StatefulWidget {
  const QuestionTypeDialog({super.key});

  @override
  State<QuestionTypeDialog> createState() => _QuestionTypeDialogState();
}

class _QuestionTypeDialogState extends State<QuestionTypeDialog> {
  int selectedAnswerIndex = 2; // Mặc định chọn đáp án thứ ba (index 2)

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.only(top: 50), // Padding tối đa phía trên
      child: Container(
        width: double.infinity,
        constraints:
        const BoxConstraints(maxWidth: 600), // Giới hạn chiều rộng tối đa
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nội dung cuộn
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      16, 24, 16, 0), // Padding tối đa cho nội dung
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề và nút đóng
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

                      // Nhãn loại câu hỏi
                      const Text(
                        'Loại câu hỏi',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dropdown
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
                            value: '1 đáp án',
                            icon: const Icon(Icons.arrow_drop_down),
                            items: ['1 đáp án']
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
                            onChanged: (String? newValue) {},
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mô tả
                      const Text(
                        'Cho phép tạo câu hỏi có nhiều câu trả lời và chỉ được chọn 1 đáp án đúng',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Phần xem trước
                      const Text(
                        'Xem trước',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Container xem trước
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
                          children: [
                            // Câu hỏi
                            const Text(
                              'Chọn câu trả lời đúng: Triết học ra đời ở đâu?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Các đáp án
                            _buildAnswerOption(0, 'Chỉ ở phương Đông'),
                            const SizedBox(height: 8),
                            _buildAnswerOption(1, 'Chỉ ở phương Tây'),
                            const SizedBox(height: 8),
                            _buildAnswerOption(
                                2, 'Cả phương Đông và phương Tây'),
                            const SizedBox(height: 8),
                            _buildAnswerOption(
                                3, 'Cả 3 đáp án còn lại đều sai'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24), // Khoảng cách trước nút
                    ],
                  ),
                ),
              ),
            ),
            // Nút xác nhận cố định
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 0, 16, 24), // Padding tối đa cho nút
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
                    Navigator.of(context).pop();
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

  Widget _buildAnswerOption(int index, String text) {
    final bool isSelected = selectedAnswerIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswerIndex = index;
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
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected ? null : Border.all(color: Colors.grey),
                color: isSelected ? Colors.green : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
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
