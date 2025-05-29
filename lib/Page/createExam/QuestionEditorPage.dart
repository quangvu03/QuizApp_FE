import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:quizapp_fe/Page/createExam/TextEditorPage.dart';
import 'package:quizapp_fe/entities/answer.dart';
import 'package:quizapp_fe/entities/question.dart';
import 'package:quizapp_fe/model/answer_api.dart';
import 'package:quizapp_fe/model/question_api.dart';
import 'package:quizapp_fe/model/quiz_api.dart';

class QuestionEditorPage extends StatefulWidget {
  final Map<String, dynamic>? dataQuiz;
  final String questionType;

  const QuestionEditorPage({
    Key? key,
    required this.dataQuiz,
    required this.questionType,
  }) : super(key: key);

  @override
  State<QuestionEditorPage> createState() => _QuestionEditorPageState();
}

class _QuestionEditorPageState extends State<QuestionEditorPage> {
  List<String> options = []; // Lưu Delta JSON cho các đáp án
  List<QuillController> optionControllers = [];
  QuillController questionController = QuillController(
    document: Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );
  QuillController explanationController = QuillController(
    document: Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );
  int? selectedOption; // Dùng cho "1 đáp án"
  List<int> selectedOptions = []; // Dùng cho "Nhiều đáp án"
  bool? selectedTrueFalse; // Dùng cho "True/False"
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    print("dsdsdsd: ${widget.dataQuiz?['id']}");

    // Khởi tạo danh sách đáp án dựa trên loại câu hỏi
    if (widget.questionType == 'True/False') {
      options = [
        jsonEncode(Document().toDelta().toJson()), // Ô trống cho "Đúng"
        jsonEncode(Document().toDelta().toJson()), // Ô trống cho "Sai"
      ];
      optionControllers = [
        QuillController(
          document: Document(),
          selection: const TextSelection.collapsed(offset: 0),
        ),
        QuillController(
          document: Document(),
          selection: const TextSelection.collapsed(offset: 0),
        ),
      ];
    } else {
      options = [
        jsonEncode(Document().toDelta().toJson()), // Ô đáp án trống
      ];
      optionControllers = [
        QuillController(
          document: Document(),
          selection: const TextSelection.collapsed(offset: 0),
        ),
      ];
    }
  }

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
      print("Cảnh báo: Danh sách không đồng bộ! Đang đồng bộ...");
      while (optionControllers.length > options.length) {
        optionControllers.last.dispose();
        optionControllers.removeLast();
      }
      while (optionControllers.length < options.length) {
        try {
          final deltaJson = jsonDecode(options[optionControllers.length]);
          optionControllers.add(
            QuillController(
              document: Document.fromJson(deltaJson),
              selection: const TextSelection.collapsed(offset: 0),
            ),
          );
        } catch (e) {
          print("Lỗi đồng bộ: $e");
          optionControllers.add(
            QuillController(
              document: Document(),
              selection: const TextSelection.collapsed(offset: 0),
            ),
          );
        }
      }
    }
  }

  // Ánh xạ widget.questionType sang type trong database
  String _mapQuestionType(String questionType) {
    switch (questionType) {
      case '1 đáp án':
        return 'tracnghiem';
      case 'Nhiều đáp án':
        return 'nhieudapan';
      case 'True/False':
        return 'dungsai';
      default:
        return 'tracnghiem'; // Mặc định nếu có lỗi
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
                  Expanded(
                    child: Text(
                      "Chỉnh sửa câu hỏi - ${widget.questionType}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
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
                          children: [
                            const Icon(Icons.list_alt, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              widget.questionType,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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
                          final initialContent = jsonEncode(
                              questionController.document.toDelta().toJson());
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TextEditorPage(
                                initialContent: initialContent,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              try {
                                final deltaJson = jsonDecode(result);
                                questionController = QuillController(
                                  document: Document.fromJson(deltaJson),
                                  selection:
                                  const TextSelection.collapsed(offset: 0),
                                );
                              } catch (e) {
                                print("Lỗi xử lý câu hỏi: $e");
                                questionController = QuillController(
                                  document: Document()..insert(0, result),
                                  selection:
                                  const TextSelection.collapsed(offset: 0),
                                );
                              }
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
                          child: QuillEditor.basic(
                            configurations: QuillEditorConfigurations(
                              controller: questionController,
                              autoFocus: false,
                              enableInteractiveSelection: false,
                              scrollable: false,
                              padding: EdgeInsets.zero,
                              expands: false,
                            ),
                            scrollController: ScrollController(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (widget.questionType == '1 đáp án')
                                      Radio<int>(
                                        value: index,
                                        groupValue: selectedOption,
                                        onChanged: (int? value) {
                                          setState(() {
                                            selectedOption = value;
                                          });
                                        },
                                      ),
                                    if (widget.questionType == 'Nhiều đáp án')
                                      Checkbox(
                                        value: selectedOptions.contains(index),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedOptions.add(index);
                                            } else {
                                              selectedOptions.remove(index);
                                            }
                                          });
                                        },
                                      ),
                                    if (widget.questionType == 'True/False')
                                      Radio<bool>(
                                        value: index == 0,
                                        groupValue: selectedTrueFalse,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            selectedTrueFalse = value;
                                          });
                                        },
                                      ),
                                    Text(
                                      'Đáp án ${index + 1}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    if (widget.questionType != 'True/False')
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: isProcessing ||
                                            options.length <= 1
                                            ? null
                                            : () {
                                          setState(() {
                                            isProcessing = true;
                                            options.removeAt(index);
                                            optionControllers[index]
                                                .dispose();
                                            optionControllers
                                                .removeAt(index);
                                            if (widget.questionType ==
                                                '1 đáp án') {
                                              if (selectedOption ==
                                                  index) {
                                                selectedOption = null;
                                              } else if (selectedOption !=
                                                  null &&
                                                  selectedOption! > index) {
                                                selectedOption =
                                                    selectedOption! - 1;
                                              }
                                            } else if (widget.questionType ==
                                                'Nhiều đáp án') {
                                              selectedOptions.remove(index);
                                              selectedOptions =
                                                  selectedOptions
                                                      .map((i) => i > index
                                                      ? i - 1
                                                      : i)
                                                      .toList();
                                            }
                                            isProcessing = false;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final initialContent = jsonEncode(
                                        optionControllers[index]
                                            .document
                                            .toDelta()
                                            .toJson());
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TextEditorPage(
                                          initialContent: initialContent,
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        try {
                                          final deltaJson = jsonDecode(result);
                                          options[index] = result;
                                          optionControllers[index] =
                                              QuillController(
                                                document:
                                                Document.fromJson(deltaJson),
                                                selection: const TextSelection
                                                    .collapsed(offset: 0),
                                              );
                                        } catch (e) {
                                          print("Lỗi xử lý đáp án $index: $e");
                                          options[index] = jsonEncode(
                                            (Document()..insert(0, result))
                                                .toDelta()
                                                .toJson(),
                                          );
                                          optionControllers[index] =
                                              QuillController(
                                                document: Document()
                                                  ..insert(0, result),
                                                selection: const TextSelection
                                                    .collapsed(offset: 0),
                                              );
                                        }
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    child: QuillEditor.basic(
                                      configurations: QuillEditorConfigurations(
                                        controller: optionControllers[index],
                                        autoFocus: false,
                                        enableInteractiveSelection: false,
                                        scrollable: false,
                                        padding: EdgeInsets.zero,
                                        expands: false,
                                      ),
                                      scrollController: ScrollController(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (widget.questionType != 'True/False')
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
                                options.add(
                                  jsonEncode(
                                    Document().toDelta().toJson(),
                                  ),
                                );
                                optionControllers.add(
                                  QuillController(
                                    document: Document(),
                                    selection: const TextSelection
                                        .collapsed(offset: 0),
                                  ),
                                );
                                isProcessing = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
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
                          final initialContent = jsonEncode(
                              explanationController.document.toDelta().toJson());

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TextEditorPage(
                                initialContent: initialContent,
                              ),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              try {
                                final deltaJson = jsonDecode(result);
                                explanationController = QuillController(
                                  document: Document.fromJson(deltaJson),
                                  selection:
                                  const TextSelection.collapsed(offset: 0),
                                );
                              } catch (e) {
                                print("Lỗi xử lý giải thích: $e");
                                explanationController = QuillController(
                                  document: Document()..insert(0, result),
                                  selection:
                                  const TextSelection.collapsed(offset: 0),
                                );
                              }
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
                          child: QuillEditor.basic(
                            configurations: QuillEditorConfigurations(
                              controller: explanationController,
                              autoFocus: false,
                              scrollable: false,
                              enableInteractiveSelection: false,
                              padding: EdgeInsets.zero,
                              expands: false,
                            ),
                            scrollController: ScrollController(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  print("dâtaaQuiz: ${widget.dataQuiz}");
                  if (questionController.document.isEmpty()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng nhập nội dung câu hỏi")),
                    );
                    return;
                  }
                  if (widget.questionType == '1 đáp án' && selectedOption == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng chọn một đáp án đúng")),
                    );
                    return;
                  }
                  if (widget.questionType == 'Nhiều đáp án' && selectedOptions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng chọn ít nhất một đáp án đúng")),
                    );
                    return;
                  }
                  if (widget.questionType == 'True/False' && selectedTrueFalse == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng chọn đáp án Đúng hoặc Sai")),
                    );
                    return;
                  }

                  // Tạo danh sách Answer (chưa có questionId)
                  List<Answer> listanswer = [];
                  for (int index = 0; index < options.length; index++) {
                    bool correct;
                    if (widget.questionType == '1 đáp án') {
                      correct = index == selectedOption;
                    } else if (widget.questionType == 'Nhiều đáp án') {
                      correct = selectedOptions.contains(index);
                    } else {
                      correct = (index == 0 && selectedTrueFalse == true) ||
                          (index == 1 && selectedTrueFalse == false);
                    }

                    listanswer.add(
                      Answer(
                        id: null,
                        quizId: widget.dataQuiz?['id'],
                        questionId: null,
                        correct: correct,
                        content: options[index],
                        createdAt: DateTime.now().toIso8601String(),
                      ),
                    );
                  }

                  // Tạo đối tượng Question
                  Question question = Question(
                    id: null,
                    quizId: widget.dataQuiz?['id'],
                    content: jsonEncode(questionController.document.toDelta().toJson()),
                    title: "Câu ${widget.dataQuiz?['questionCount'] != null ? widget.dataQuiz!['questionCount'] + 1 : 1}",
                    type: _mapQuestionType(widget.questionType), // Sử dụng type đã ánh xạ
                  );

                  try {
                    // Lưu câu hỏi trước
                    final questionApi = QuestionApi();
                    final questionResult = await questionApi.saveQuestion(question);
                    if (questionResult == null || questionResult['idQuestion'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lưu câu hỏi thất bại")),
                      );
                      return;
                    }

                    // Lấy questionId từ kết quả
                    final questionId = questionResult['idQuestion'] as int;

                    // Cập nhật questionId cho listanswer
                    listanswer = listanswer.map((answer) => Answer(
                      id: answer.id,
                      quizId: answer.quizId,
                      questionId: questionId,
                      correct: answer.correct,
                      content: answer.content,
                      createdAt: answer.createdAt,
                    )).toList();

                    // Lưu danh sách đáp án
                    final answerApi = AnswerApi();
                    final answerResult = await answerApi.saveAnswers(listanswer);
                    if (answerResult != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lưu câu hỏi và đáp án thành công: ID $questionId")),
                      );
                      Navigator.pop(context, {
                        'question': questionResult,
                        'answers': answerResult,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lưu đáp án thất bại")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi khi lưu: $e")),
                    );
                  }
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