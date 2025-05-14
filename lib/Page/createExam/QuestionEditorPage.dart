import 'package:flutter/material.dart';

class QuestionEditorPage extends StatefulWidget {
  const QuestionEditorPage({Key? key}) : super(key: key);

  @override
  State<QuestionEditorPage> createState() => _QuestionEditorPageState();
}

class _QuestionEditorPageState extends State<QuestionEditorPage> {
  List<String> options = ["Đáp án 1"];
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFFCFBEFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () {
                      // Xử lý sự kiện khi nhấn nút quay lại
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Chỉnh sửa câu hỏi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Để cân bằng với nút quay lại
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Loại câu hỏi
                      const Text(
                        "Loại câu hỏi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        child: Row(
                          children: const [
                            Icon(Icons.list_alt, size: 20),
                            SizedBox(width: 12),
                            Text(
                              "1 đáp án",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nội dung câu hỏi
                      const Text(
                        "Nội dung câu hỏi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Nhập nội dung câu hỏi",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Đáp án
                      const Text(
                        "Đáp án",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Danh sách đáp án
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Radio<int>(
                                  value: index,
                                  groupValue: selectedOption,
                                  onChanged: (int? value) {
                                    setState(() {
                                      selectedOption = value;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Nhập nội dung câu trả lời",
                                        hintStyle:
                                        const TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                      controller: TextEditingController(
                                          text: options[index]),
                                      onChanged: (value) {
                                        options[index] = value;
                                      },
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    if (options.length > 1) {
                                      setState(() {
                                        options.removeAt(index);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Nút thêm đáp án
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          label: const Text(
                            "Thêm đáp án",
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {
                            setState(() {
                              options.add("Đáp án ${options.length + 1}");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            overlayColor: const Color(0xFFEEF3FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Giải thích
                      const Text(
                        "Giải thích",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText:
                            "Nhập nội dung giải thích cho câu hỏi này",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Nút Lưu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                child: const Text(
                  "Lưu",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  overlayColor: const Color(0xFF6A5AE0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Xử lý sự kiện khi nhấn nút Lưu
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
