import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/createExam/TextEditorPage.dart';

class QuestionEditorPage extends StatefulWidget {
  const QuestionEditorPage({Key? key}) : super(key: key);

  @override
  State<QuestionEditorPage> createState() => _QuestionEditorPageState();
}

class _QuestionEditorPageState extends State<QuestionEditorPage> {
  List<String> options = ["Đáp án 1"];
  List<TextEditingController> optionControllers = [
    TextEditingController(text: "Đáp án 1")
  ];
  TextEditingController questionController = TextEditingController();
  TextEditingController explanationController = TextEditingController();
  int? selectedOption;
  bool isProcessing = false;

  @override
  void dispose() {
    for (var controller in optionControllers) {
      controller.dispose();
    }
    questionController.dispose();
    explanationController.dispose();
    super.dispose();
  }

  void _syncLists() {
    if (options.length != optionControllers.length) {
      print("Warning: Lists out of sync! Syncing now...");
      while (optionControllers.length > options.length) {
        optionControllers.last.dispose();
        optionControllers.removeLast();
      }
      while (optionControllers.length < options.length) {
        optionControllers.add(
            TextEditingController(text: options[optionControllers.length]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncLists();

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
                      Navigator.pop(context);
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
                  const SizedBox(width: 48),
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
                        child: const Row(
                          children: [
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
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TextEditorPage(
                                initialContent: questionController.text,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              questionController.text = result;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            questionController.text.isEmpty
                                ? "Nhập nội dung câu hỏi"
                                : questionController.text,
                            style: TextStyle(
                              color: questionController.text.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          if (index >= optionControllers.length) {
                            return const SizedBox.shrink();
                          }
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
                                  child: GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TextEditorPage(
                                            initialContent:
                                            optionControllers[index].text,
                                          ),
                                        ),
                                      );
                                      if (result != null) {
                                        setState(() {
                                          optionControllers[index].text = result;
                                          options[index] = result;
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
                                      child: Text(
                                        optionControllers[index].text.isEmpty
                                            ? "Nhập nội dung câu trả lời"
                                            : optionControllers[index].text,
                                        style: TextStyle(
                                          color: optionControllers[index]
                                              .text.isEmpty
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: isProcessing || options.length <= 1
                                      ? null
                                      : () {
                                    setState(() {
                                      isProcessing = true;
                                      options.removeAt(index);
                                      optionControllers[index].dispose();
                                      optionControllers.removeAt(index);
                                      if (selectedOption == index) {
                                        selectedOption = null;
                                      } else if (selectedOption != null &&
                                          selectedOption! > index) {
                                        selectedOption =
                                            selectedOption! - 1;
                                      }
                                      isProcessing = false;
                                    });
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
                          onPressed: isProcessing
                              ? null
                              : () {
                            setState(() {
                              isProcessing = true;
                              options.add("Đáp án ${options.length + 1}");
                              optionControllers.add(TextEditingController(
                                  text: "Đáp án ${options.length}"));
                              isProcessing = false;
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
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TextEditorPage(
                                initialContent: explanationController.text,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              explanationController.text = result;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            explanationController.text.isEmpty
                                ? "Nhập nội dung giải thích cho câu hỏi này"
                                : explanationController.text,
                            style: TextStyle(
                              color: explanationController.text.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 16,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                onPressed: () {
                  if (questionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Vui lòng nhập nội dung câu hỏi")),
                    );
                    return;
                  }
                  if (selectedOption == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Vui lòng chọn một đáp án đúng")),
                    );
                    return;
                  }
                  Navigator.pop(context, {
                    'question': questionController.text,
                    'options': options,
                    'correctOption': selectedOption,
                    'explanation': explanationController.text,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}